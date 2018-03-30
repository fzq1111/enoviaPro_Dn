package com.teamcenter.custom.web.service;

import java.util.*;

import javax.jws.*;

import org.codehaus.jackson.map.ObjectMapper;

import com.teamcenter.rac.aif.*;
import com.teamcenter.rac.aif.kernel.AIFComponentContext;
import com.teamcenter.rac.kernel.*;

@WebService(serviceName = "TcService", endpointInterface = "com.teamcenter.custom.web.service.TcService")
public class TcServiceImpl implements TcService {

	private String[] objSelects = null;

	private String[] bomSelects = null;

	private String[] staSelects = null;

	private int recurseToLevel = 0;

	private String recurseToType = null;

	private static boolean isNullOrEmpty(String textString) {
		return (null == textString || textString.trim().length() <= 0);
	}

	private static String[] getStringList(String jsonString) throws Exception {
		if (isNullOrEmpty(jsonString)) {
			return new String[0];
		}
		@SuppressWarnings("unchecked")
		List<String> listString = (new ObjectMapper()).readValue(jsonString, ArrayList.class);
		return listString.toArray(new String[listString.size()]);
	}

	private Map<String, String> getPropertyValues(TCComponent component, String[] keys) throws Exception {
		Map<String, String> propertyValue = new HashMap<String, String>();
		if (null == keys || 0 == keys.length) {
			return propertyValue;
		}
		String[] values = component.getProperties(keys);
		for (int i = 0; i < keys.length; i++) {
			propertyValue.put(keys[i], values[i]);
		}
		return propertyValue;
	}

	private TCComponentBOMViewRevision getBOMViewRevision(TCComponentItemRevision itemRevision) throws Exception {
		if (null != itemRevision) {
			TCComponent[] components = itemRevision.getRelatedComponents("structure_revisions");
			for (TCComponent component : components) {
				if (component instanceof TCComponentBOMViewRevision) {
					return (TCComponentBOMViewRevision) component;
				}
			}
		}
		return null;
	}

	private TCComponentReleaseStatus getReleaseStatus(TCComponent component, String flag) throws Exception {
		TCComponent[] statuses = component.getRelatedComponents("release_status_list");
		for (TCComponent status : statuses) {
			TCComponentReleaseStatus releaseStatus = (TCComponentReleaseStatus) status;
			if (null != releaseStatus && (isNullOrEmpty(flag) || flag.contains(releaseStatus.toString()))) {
				return releaseStatus;
			}
		}
		return null;
	}

	private TCComponentItem getItem(TCSession session, String id, String type) throws Exception {
		if (isNullOrEmpty(id)) {
			throw new Exception("The item id can not be empty.");
		}
		if (isNullOrEmpty(type)) {
			type = "Item";
		}
		TCComponentItemType itemType = (TCComponentItemType) session.getTypeComponent(type);
		return itemType.find(id);
	}

	private TCComponentBOMWindow getBOMWindow(TCSession session) throws Exception {
		TCComponentBOMWindowType bomWindowType = (TCComponentBOMWindowType) session.getTypeComponent("BOMWindow");
		TCComponentRevisionRuleType revisionRuleType = (TCComponentRevisionRuleType) session.getTypeComponent("RevisionRule");
		return bomWindowType.create(revisionRuleType.getDefaultRule());
	}

	private TCComponentBOMLine getTopBOMLine(TCSession session, TCComponentBOMWindow bomWindow, TCComponentItemRevision itemRevision) throws Exception {
		TCComponentBOMViewRevision bomViewRevision = getBOMViewRevision(itemRevision);
		if (null == bomViewRevision) {
			return null;
		}
		TCComponentBOMView bomView = (TCComponentBOMView) bomViewRevision.getReferenceProperty("bom_view");
		bomWindow.setWindowTopLine(itemRevision.getItem(), itemRevision, bomView, bomViewRevision);
		return bomWindow.getTopBOMLine();
	}

	private void getBOM(TCComponentBOMLine parentBOMLine, int currentLevel, List<Map<String, String>> objects) throws Exception {
		AIFComponentContext[] contexts = parentBOMLine.getChildren();
		for (AIFComponentContext context : contexts) {
			TCComponentBOMLine childBOMLine = (TCComponentBOMLine) context.getComponent();
			if (null == childBOMLine) {
				continue;
			}
			TCComponent component = null;
			try {
				component = childBOMLine.getItemRevision();
			} catch (Exception ex) {
				ex.printStackTrace();
			}
			if (null == component) {
				// component = childBOMLine.getItem();
				// if (null == component) {
				continue;
				// }
			}
			Map<String, String> propertyValues = getPropertyValues(component, objSelects);
			propertyValues.put("level", Integer.toString(currentLevel));
			propertyValues.putAll(getPropertyValues(childBOMLine, bomSelects));
			objects.add(propertyValues);
			//if ((0 == recurseToLevel || currentLevel < recurseToLevel)) {
			//	int nextLevel = (isNullOrEmpty(recurseToType) || !recurseToType.contains(component.getType())) ? currentLevel : recurseToLevel;
			//	getBOM(childBOMLine, nextLevel + 1, objects);
			if ((0 == recurseToLevel || currentLevel < recurseToLevel) && (isNullOrEmpty(recurseToType) || !recurseToType.contains(component.getType()))) {
				getBOM(childBOMLine, currentLevel + 1, objects);
			}
		}
	}

	private List<Map<String, String>> getBOM(TCSession session, TCComponentItem item) throws Exception {
		TCComponentBOMWindow bomWindow = getBOMWindow(session);
		try {
			List<Map<String, String>> objects = new ArrayList<Map<String, String>>();
			TCComponentBOMLine topBOMLine = getTopBOMLine(session, bomWindow, item.getLatestItemRevision());
			if (null != topBOMLine) {
				getBOM(topBOMLine, 1, objects);
			}
			return objects;
		} catch (Exception ex) {
			throw ex;
		} finally {
			bomWindow.close();
		}
	}

	private TCComponent getLatestItemRevision(TCComponentItem item) {
		try {
			TCComponentItemRevision itemRevision = item.getLatestItemRevision();
			return (null == itemRevision ? item : itemRevision);
		} catch (Exception ex) {
			return item;
		}
	}

	private Map<String, String> getInfo(TCComponentItem item, int released) throws Exception {
		if (null == item) {
			return new HashMap<String, String>();
		}
		if (0 == released) {
			return getPropertyValues(getLatestItemRevision(item), objSelects);
		}
		TCComponentItemRevision[] itemRevisions = item.getReleasedItemRevisions();
		if (0 >= itemRevisions.length) {
			return getPropertyValues(getLatestItemRevision(item), objSelects);
		}
		return getPropertyValues(itemRevisions[0], objSelects);
	}

	private List<Map<String, String>> getRevisions(TCComponentItemRevision[] itemRevisions) throws Exception {
		List<Map<String, String>> objects = new ArrayList<Map<String, String>>();
		for (TCComponentItemRevision itemRevision : itemRevisions) {
			objects.add(getPropertyValues(itemRevision, objSelects));
		}
		return objects;
	}

	private List<Map<String, String>> getRevisions(TCComponentItem item, int released) throws Exception {
		List<Map<String, String>> objects = new ArrayList<Map<String, String>>();
		if (null == item) {
			return objects;
		}
		objects.addAll(getRevisions(item.getReleasedItemRevisions()));
		if (0 != released) {
			return objects;
		}
		objects.addAll(getRevisions(item.getInProcessItemRevisions()));
		objects.addAll(getRevisions(item.getWorkingItemRevisions()));
		return objects;
	}

	private TCComponent[] getWhereUsed(TCComponent component) throws Exception {
		try {
			return component.whereUsed(TCComponent.WHERE_USED_PRECISE);
		} catch (Exception ex) {
			try {
				return component.whereUsed(TCComponent.WHERE_USED_ALL);
			} catch (Exception ec) {
				return component.whereUsed(TCComponent.WHERE_USED_CONFIGURED);
			}
		}
	}

	private Map<String, String> getDeliverStatus(TCComponentItem item, String flag) throws Exception {
		Map<String, String> propertyValues = null;
		TCComponentItemRevision[] itemRevisions = item.getReleasedItemRevisions();
		Date date = null;
		TCComponentItemRevision revision = null;
		TCComponentReleaseStatus status = null;
		for (TCComponentItemRevision itemRevision : itemRevisions) {
			TCComponentReleaseStatus releaseStatus = getReleaseStatus(itemRevision, flag);
			if (null != releaseStatus) {
				Date releaseDate = releaseStatus.getDateProperty("date_released");
				if (null == date || releaseDate.before(date)) {
					date = releaseDate;
					revision = itemRevision;
					status = releaseStatus;
				}
			}
		}
		if (null != revision && null != status) {
			propertyValues = getPropertyValues(revision, objSelects);
			propertyValues.putAll(getPropertyValues(status, staSelects));
		}
		return propertyValues;
	}

//	private List<Map<String, String>> getDeliverStatus(TCComponentItem item, String typeWhereUsed, String flag) throws Exception {
//		List<Map<String, String>> objects = new ArrayList<Map<String, String>>();
//		if (null == item) {
//			return objects;
//		}
//		List<String> itemIds = new ArrayList<String>();
//		TCComponent[] components = getWhereUsed(getLatestItemRevision(item));
//		for (TCComponent component : components) {
//			if (component instanceof TCComponentItemRevision && (isNullOrEmpty(typeWhereUsed) || typeWhereUsed.contains(component.getType()))) {
//				TCComponentItemRevision itemRevision = (TCComponentItemRevision) component;
//				String id = itemRevision.getProperty("item_id");
//				if (itemIds.contains(id)) {
//					continue;
//				}
//				itemIds.add(id);
//				Map<String, String> object = getDeliverStatus(itemRevision.getItem(), flag);
//				if (null != object) {
//					objects.add(object);
//				}
//			}
//		}
//		return objects;
//	}

	private List<Map<String, String>> getDeliverStatus(TCComponentItem item, String typeWhereUsed, String flag) throws Exception {
		List<Map<String, String>> objects = new ArrayList<Map<String, String>>();
		if (null == item) {
			return objects;
		}
		Map<String, Date> typeDates = new HashMap<String, Date>();
		Map<String, TCComponentItemRevision> typeItemRevision = new HashMap<String,TCComponentItemRevision>();
		Map<String, TCComponentReleaseStatus> typeReleaseStatus = new HashMap<String,TCComponentReleaseStatus>();
		TCComponent[] components = getWhereUsed(getLatestItemRevision(item));
		for (TCComponent component : components) {
			if (component instanceof TCComponentItemRevision && (isNullOrEmpty(typeWhereUsed) || typeWhereUsed.contains(component.getType()))) {
				TCComponentItemRevision itemRevision = (TCComponentItemRevision) component;
				TCComponentReleaseStatus releaseStatus = getReleaseStatus(itemRevision, flag);
				if (null != releaseStatus) {
					Date releaseDate = releaseStatus.getDateProperty("date_released");
					String componentType = component.getType();
					if (!typeDates.containsKey(componentType) || releaseDate.before(typeDates.get(componentType))) {
						typeDates.put(componentType, releaseDate);
						typeItemRevision.put(componentType, itemRevision);
						typeReleaseStatus.put(componentType, releaseStatus);
					}
				}
			}
		}
		for(String componentType : typeDates.keySet()){
			Map<String, String> propertyValues = getPropertyValues(typeItemRevision.get(componentType), objSelects);
			propertyValues.putAll(getPropertyValues(typeReleaseStatus.get(componentType), staSelects));
			objects.add(propertyValues);
		}
		return objects;
	}
	
	private List<Map<String, String>> findObjects(String query, String[] keys, String[] values, int limit) throws Exception {
		TCSession session = getSession();
		TCComponentQueryType queryType = (TCComponentQueryType) session.getTypeComponent("ImanQuery");
		TCComponent[] components = ((TCComponentQuery) queryType.find(query)).execute(keys, values);
		int length = components.length;
		if (0 < limit && length > limit) {
			length = limit;
		}
		List<Map<String, String>> objects = new ArrayList<Map<String, String>>();
		for (int i = 0; i < length; i++) {
			objects.add(getPropertyValues(components[i], objSelects));
		}
		return objects;
	}

	private TCSession getSession() {
		return (TCSession) AIFDesktop.getActiveDesktop().getCurrentApplication().getSession();
	}

	// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	public String[] getObjSelects() {
		return objSelects;
	}

	public void setObjSelects(String[] objSelects) {
		this.objSelects = objSelects;
	}

	public String[] getBomSelects() {
		return bomSelects;
	}

	public void setBomSelects(String[] bomSelects) {
		this.bomSelects = bomSelects;
	}

	public String[] getStaSelects() {
		return staSelects;
	}

	public void setStaSelects(String[] staSelects) {
		this.staSelects = staSelects;
	}

	public int getRecurseToLevel() {
		return recurseToLevel;
	}

	public void setRecurseToLevel(int recurseToLevel) {
		this.recurseToLevel = recurseToLevel;
	}

	public String getRecurseToType() {
		return recurseToType;
	}

	public void setRecurseToType(String recurseToType) {
		this.recurseToType = recurseToType;
	}

	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	@Override
	public String getBOM(String id, String type, String objSelects, String bomSelects, int recurseToLevel, String recurseToType) throws Exception {
		TCSession session = getSession();
		TCComponentItem item = getItem(session, id, type);
		setObjSelects(getStringList(objSelects));
		setBomSelects(getStringList(bomSelects));
		setRecurseToLevel(recurseToLevel);
		setRecurseToType(recurseToType);
		return (new ObjectMapper()).writeValueAsString(getBOM(session, item));
	}

	@Override
	public String getInfo(String id, String type, String objSelects, int released) throws Exception {
		TCSession session = getSession();
		TCComponentItem item = getItem(session, id, type);
		setObjSelects(getStringList(objSelects));
		return (new ObjectMapper()).writeValueAsString(getInfo(item, released));
	}

	@Override
	public String getItem(String id, String type, String objSelects) throws Exception {
		TCSession session = getSession();
		TCComponentItem item = getItem(session, id, type);
		return (new ObjectMapper()).writeValueAsString(getPropertyValues(item, getStringList(objSelects)));
	}

	@Override
	public String getRevisions(String id, String type, String objSelects, int released) throws Exception {
		TCSession session = getSession();
		TCComponentItem item = getItem(session, id, type);
		setObjSelects(getStringList(objSelects));
		return (new ObjectMapper()).writeValueAsString(getRevisions(item, released));
	}

	@Override
	public String getDeliverStatus(String id, String type, String objSelects, String staSelects, String typeWhereUsed, String flag) throws Exception {
		TCSession session = getSession();
		TCComponentItem item = getItem(session, id, type);
		setObjSelects(getStringList(objSelects));
		setStaSelects(getStringList(staSelects));
		return (new ObjectMapper()).writeValueAsString(getDeliverStatus(item, typeWhereUsed, flag));
	}

	@Override
	public String findObjects(String query, String where, String objSelects, int limit) throws Exception {
		@SuppressWarnings("unchecked")
		Map<String, String> map = (new ObjectMapper()).readValue(where, HashMap.class);
		String[] keys = map.keySet().toArray(new String[map.size()]);
		String[] values = map.values().toArray(new String[map.size()]);
		setObjSelects(getStringList(objSelects));
		return (new ObjectMapper()).writeValueAsString(findObjects(query, keys, values, limit));
	}
}
