<%@page import="com.matrixone.apps.common.Route"%>
<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "../components/emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%
	String sModel = emxGetParameter(request, "model");
	String sTaskId = emxGetParameter(request, "objectId");
	String routeId = emxGetParameter(request, "routeId");
	String textTitle = emxGetParameter(request, "textTitle");
	String routeAction = emxGetParameter(request, "routeAction");
	String sRouteOrder = emxGetParameter(request, "routeOrder");
	String assignPerson[] = emxGetParameterValues(request, "assignPerson");
	String routeInstructions = emxGetParameter(request, "routeInstructions");
	String radioAction = emxGetParameter(request, "radioAction");
	String pageHeadingKey = "SEM.emxComponents.Common." + sModel;
	String sSourceKey = "emxComponentsStringResource";
	String i18nHead = i18nNow.getI18nString(pageHeadingKey, sSourceKey, sLanguage);
	String sMessage = i18nHead + " " + i18nNow.getI18nString("LS.emxComponents.AssignTask.SignedSuccess", sSourceKey, sLanguage);
	try{
		ContextUtil.pushContext(context);
		
		DomainObject taskObject = DomainObject.newInstance(context, sTaskId);
		Route routeObj = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
		routeObj.setId(routeId);
		
		String sCurrentRouteNode = routeObj.getAttributeValue(context, "Current Route Node");
		
		Pattern  typePattern = new Pattern(DomainObject.TYPE_PERSON);
	  	typePattern.addPattern(DomainObject.TYPE_ROUTE_TASK_USER);
		
	  	
	  	SelectList selectStmts = new SelectList();
		selectStmts.addName();
		selectStmts.addId();
		selectStmts.addType();
		selectStmts.addAttribute(DomainObject.ATTRIBUTE_TEMPLATE_TASK);
	  	
		StringList relSelStmts = new StringList();
	  	relSelStmts.addElement(DomainConstants.SELECT_RELATIONSHIP_ID);
	  	relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_ROUTE_TASK_USER+"]");
	  	relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_ROUTE_SEQUENCE+"]");
	  	relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_ALLOW_DELEGATION+"]");
	  	relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_ROUTE_ACTION+"]");
	  	relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_ROUTE_INSTRUCTIONS+"]");
	  	relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_TITLE+"]");
	  	relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_SCHEDULED_COMPLETION_DATE+"]");
	  	relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE+"]");
	  	relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_REVIEW_TASK+"]");
	  	relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
	  	relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_NODE_ID+"]");
	  	relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_DUEDATE_OFFSET+"]");
	  	relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_DATE_OFFSET_FROM+"]");
	  	relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_TEMPLATE_TASK+"]");
	  	String sAttParallelNodeProcessionRule = PropertyUtil.getSchemaProperty(context, "attribute_ParallelNodeProcessionRule");
	  	
	  	//增加在任务之后，后面任务sequence增加1
	  	if("After".equalsIgnoreCase(sRouteOrder) && "MoreSigned".equals(sModel))
	  	{
			MapList routeNodeList = routeObj.getRelatedObjects(context, DomainObject.RELATIONSHIP_ROUTE_NODE,
					typePattern.getPattern(),
					selectStmts, relSelStmts, 
					false, true,
					(short)1, "",
					"",null,
					null,null);
			routeNodeList.sort("attribute["+routeObj.ATTRIBUTE_ROUTE_SEQUENCE+"]", "ascending","integer");
			
			Map tempMap = null;
			String sRouteNodeSeq = "";
			String sRouteNodeId = "";
			DomainRelationship routeNodeObject = null;
			for(int i = 0; i < routeNodeList.size(); i++)
			{
				tempMap = (Map) routeNodeList.get(i);
				sRouteNodeSeq = (String) tempMap.get("attribute["+routeObj.ATTRIBUTE_ROUTE_SEQUENCE+"]");
				int routeSeqIndex = Integer.parseInt(sRouteNodeSeq);
				if(Integer.parseInt(sRouteNodeSeq) > Integer.parseInt(sCurrentRouteNode))
				{
					routeSeqIndex++;
					sRouteNodeId = (String) tempMap.get(DomainConstants.SELECT_RELATIONSHIP_ID);
					routeNodeObject = new DomainRelationship(sRouteNodeId);
					routeNodeObject.open(context);
					routeNodeObject.setAttributeValue(context, routeObj.ATTRIBUTE_ROUTE_SEQUENCE, String.valueOf(routeSeqIndex));
					routeNodeObject.close(context);
				}
			}
	  	}
	  	
	
	  	Map<String, String> attrMap = new HashMap<String, String>();
	  	String sAttrRouteSeq = "";
	  	if("After".equalsIgnoreCase(sRouteOrder))
	  	{
	  		sAttrRouteSeq = String.valueOf((Integer.parseInt(sCurrentRouteNode) + 1));
	  	}else{
	  		radioAction = "All";
	  		sAttrRouteSeq = sCurrentRouteNode;
	  	}
	  	attrMap.put(routeObj.ATTRIBUTE_TITLE, textTitle);
	  	attrMap.put(routeObj.ATTRIBUTE_ROUTE_SEQUENCE, sAttrRouteSeq);
	  	attrMap.put(routeObj.ATTRIBUTE_ROUTE_ACTION, routeAction);
	  	attrMap.put(routeObj.ATTRIBUTE_ROUTE_INSTRUCTIONS, routeInstructions);
	  	attrMap.put(routeObj.ATTRIBUTE_ASSIGNEE_SET_DUEDATE, "Yes");
	  	attrMap.put(routeObj.ATTRIBUTE_ALLOW_DELEGATION, "true");
	  	if("MoreSigned".equals(sModel))
	  	{
		  	attrMap.put(sAttParallelNodeProcessionRule, radioAction);
	  	}
	  	
	  	StringList newRouteNodeId = new StringList();
	  	for(int i = 0; i < assignPerson.length; i++)
	  	{
	  		StringList sSplitAssignPerson = FrameworkUtil.split(assignPerson[i], "~");
	  		String sPersonId = (String) sSplitAssignPerson.get(sSplitAssignPerson.size() - 1);
	  		String sNewRouteNodeId = CreateRouteNode(context, sPersonId, routeId, attrMap);
	  		newRouteNodeId.addElement(sNewRouteNodeId);
	  	}
	 	if("Parallel".equalsIgnoreCase(sRouteOrder)){
	  		//create object
	 		if("MoreSigned".equals(sModel))
		  	{
		 		routeObj.startTasksOnCurrentLevel(context);
		 		//taskObject.setAttributeValue(context, sAttParallelNodeProcessionRule, radioAction);
		 		String sTaskRouteNodeId = taskObject.getAttributeValue(context, routeObj.ATTRIBUTE_ROUTE_NODE_ID);
		 		DomainRelationship.setAttributeValue(context, sTaskRouteNodeId, sAttParallelNodeProcessionRule, radioAction);
		  	}else{
		  		 String sRouteType = routeObj.getInfo(context, "type");
		  		 String sRouteName = routeObj.getInfo(context, "name");
		  		 String sRouteRev = routeObj.getInfo(context, "revision");
		  		 String arguments [] = new String[5];
                 arguments[0]=sRouteType;
                 arguments[1]=sRouteName;
                 arguments[2]=sRouteRev;
                 arguments[3]= ""+sCurrentRouteNode;
                 arguments[4]="0";
                 Integer outStr1 = (Integer) JPO.invoke(context, "emxCommonInitiateRoute", null, "InitiateRoute", arguments,Integer.class);
		  	}
	  	}
	}catch(Exception e)
	{
		e.printStackTrace();
		sMessage = i18nHead + " " + i18nNow.getI18nString("LS.emxComponents.AssignTask.SignedFailed", sSourceKey, sLanguage) + e.getMessage();
		sMessage.replace("\"", "'");
	}finally{
		ContextUtil.popContext(context);
	}
%>
	<script type="text/javascript">
		alert("<%=sMessage%>");
		top.opener.location.href = top.opener.location.href;
		window.top.close();
	</script>
<%!
	public String CreateRouteNode(Context context,String personId,String routeId,Map attrMap)throws Exception{
	
		Route routeObject = new Route();
		DomainObject personObject     = DomainObject.newInstance(context);
		routeObject.setId(routeId);
		routeObject.open(context);
		personObject.setId(personId);
		personObject.open(context);
		
		MapList tskMapList = null;
	   StringList existedMemberList = new StringList();
	   String sRouteNode = PropertyUtil.getSchemaProperty(context, "relationship_RouteNode");
	   Pattern typePattern = new Pattern(DomainObject.TYPE_PERSON);
	    typePattern.addPattern(DomainObject.TYPE_ROUTE_TASK_USER);
	    Pattern relPattern = new Pattern(sRouteNode);
	    StringList selectTypeStmts = new StringList();
	    selectTypeStmts.add(DomainObject.SELECT_ID);
	    selectTypeStmts.add(DomainObject.SELECT_TYPE);
	    StringList selectRelStmts = new StringList();
	    selectRelStmts.add(DomainObject.SELECT_RELATIONSHIP_ID);
	    selectRelStmts.add("attribute["+DomainObject.ATTRIBUTE_ROUTE_SEQUENCE+"]");
	    selectRelStmts.add("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
	   tskMapList = routeObject.getRelatedObjects(context,
									               relPattern.getPattern(),  //String relPattern
									               typePattern.getPattern(), //String typePattern
									               selectTypeStmts,          //StringList objectSelects,
									               selectRelStmts,                     //StringList relationshipSelects,
									               false,                    //boolean getTo,
									               true,                     //boolean getFrom,
									               (short)1,                 //short recurseToLevel,
									               "",                       //String objectWhere,
									               "",                       //String relationshipWhere,
									               null,                     //Pattern includeType,
									               null,                     //Pattern includeRelationship,
									               null);                    //Map includeMap
	
		tskMapList.sort("attribute["+DomainObject.ATTRIBUTE_ROUTE_SEQUENCE+"]","ascending","integer");
		Iterator tskMapListItr = tskMapList.iterator();
		while(tskMapListItr.hasNext()){
			Map taskMap = (Map)tskMapListItr.next();
			if(DomainConstants.TYPE_ROUTE_TASK_USER.equals(taskMap.get(DomainConstants.SELECT_TYPE))){
				existedMemberList.add(PropertyUtil.getSchemaProperty(context,taskMap.get("attribute["+DomainConstants.ATTRIBUTE_ROUTE_TASK_USER+"]").toString()));
			}else{
				existedMemberList.add(taskMap.get(DomainConstants.SELECT_ID));
			}
		}
					
		DomainRelationship taskRouteNode = routeObject.connectTo(context,DomainObject.RELATIONSHIP_ROUTE_NODE, personObject);
		taskRouteNode.setAttributeValues(context, attrMap);
		if(!existedMemberList.contains(personId)){
	       	addPesonToRoute(context,"Person",routeObject,null,routeObject.getTypeName(),new String[]{personId},routeId);
		}
		routeObject.close(context);
		personObject.close(context);
		return taskRouteNode.toString();
	}
	public void addPesonToRoute(matrix.db.Context context,String memberType, Route routeObject, RouteTemplate routeTemplateObject, String objType, String[] memberID, String sRouteId) throws MatrixException
	{
 		try
	 	{
			DomainObject personObject = null;
	  		if(DomainConstants.TYPE_PERSON.equals(memberType))
	  		{
	      		//<Fix 372839>
	      		java.util.Set granteeSet = new HashSet();
	      		//</Fix 372839>
	    		for(int count =0; count < memberID.length; count++ ) {
		      		String typePersonId = memberID[count];
			      	personObject = DomainObject.newInstance(context , typePersonId);
	             	//<Fix 372839>
	             	granteeSet.add(personObject.getName(context));
			   	//</Fix 372839>                   
		     	}
			  	//<Fix 372839>
			  	if(objType.equals(DomainConstants.TYPE_ROUTE)) {
			      	routeObject.setId(sRouteId);
			      	routeObject.grantAccessOnContent(context, (String[])granteeSet.toArray(new String []{}));
			  	}
			  	//</Fix 372839>    
	  		}
		}catch(Exception e){}
	}// End method
%>