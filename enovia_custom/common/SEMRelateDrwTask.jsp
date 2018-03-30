<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.SetUtil"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%@page import="java.util.Iterator"%>
<%
    StringList busList = new StringList("id");
  StringList relList = new StringList(DomainRelationship.SELECT_ID);
  String mode=(String)emxGetParameter(request,"mode");
  String strRelName = emxGetParameter(request,"SEM Related DrwTask");
  if("addDrwTask".equals(mode))
  {
	    strRelName=PropertyUtil.getSchemaProperty(context,strRelName);
		String errorMsg = "";
		try{
			String objectId=(String)emxGetParameter(request,"objectId");
			DomainObject strFromObj = new DomainObject(objectId);
			String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
			for(int i=0;i<emxTableRowId.length;i++)
			{
				String[] splitValue = emxTableRowId[i].split("\\|");
			    Map<String,String> mplist=new HashMap<String,String>();
				String strObjId = splitValue[1];
				DomainObject strObj = new DomainObject(strObjId);
				String strName = strObj.getName(context);
				MapList mapList = strObj.getRelatedObjects(context,"SEM Related DrwTask", "*", busList, relList,true,false,(short)1, null, null);
				if(mapList.size()>0)
				{
					Iterator it = mapList.iterator();
					while(it.hasNext()){
						Map map = (Map)it.next();
						String id=(String)map.get("id");
						mplist.put(id,id);
					}
				}
				if(mplist.containsValue(objectId)){
					
				}else{
					ContextUtil.pushContext(context);
					DomainRelationship rel=strFromObj.connectTo(context,"SEM Related DrwTask",strObj);				
					ContextUtil.popContext(context);
				}
			}
		}catch(Exception e){
			String msg = e.getMessage();
			throw new Exception(msg);
		}
%>
	<script>
		 window.top.opener.location.href = window.top.opener.location.href;
		 window.top.close();
		</script>
<%		 
		 
	}
 %>