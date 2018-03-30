<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page language="java" pageEncoding="UTF-8"%>
<% 

	String mode=emxGetParameter(request,"mode");
	if(mode.equals("alterYes"))
	{
		String[] emxTableRowId= emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue=emxTableRowId[i].split("\\|");
			String strObjectId=splitValue[1];
			String tableRowId = splitValue[3];
			DomainObject strObj=new DomainObject(strObjectId);
			//add by guozhaohui 10/26/2017
			if(!strObj.isKindOf(context,"Task"))
			{
				continue;
			}
			//add end
			StringList busList = new StringList("id");
			StringList relList = new StringList(DomainRelationship.SELECT_ID);
			MapList mapList=strObj.getRelatedObjects(context,"Dependency", "Task", busList, relList,false,true,(short)1,"", null);
			String taskStartDateValue = strObj.getAttributeValue(context,"Task Estimated Start Date");
    		String taskFinishDateValue = strObj.getAttributeValue(context,"Task Estimated Finish Date");
			if(mapList.size()>0){	
				Map map=(Map) mapList.get(0);
				String relId = (String)map.get("id[connection]");	
				ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"),DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
				try {
					MqlUtil.mqlCommand(context, "trigger off", true);	
				} finally {			
					ContextUtil.popContext(context);			
				}				
				DomainRelationship.disconnect(context,relId);
				ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"),DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
				try {
					MqlUtil.mqlCommand(context, "trigger on", true);	
				} finally {			
					ContextUtil.popContext(context);			
				}
			}
			strObj.setAttributeValue(context,"Task Constraint Type","Start No Earlier Than");
			strObj.setAttributeValue(context,"Task Constraint Date",taskStartDateValue);
    		
			ContextUtil.pushContext(context);
			strObj.setAttributeValue(context,"SEM Is Locked","YES");
			strObj.setAttributeValue(context,"SEM Lock StartTime",taskStartDateValue);
			strObj.setAttributeValue(context,"SEM Lock FinishTime",taskFinishDateValue);

			ContextUtil.popContext(context);
%>
	<script>
		//parent.location.href=parent.location.href;
		parent.emxEditableTable.refreshRowByRowId("<%=tableRowId%>");
	</script>
<%			
		}

	}else if(mode.equals("alterNo"))
	{
		String[] emxTableRowId= emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue=emxTableRowId[i].split("\\|");
			String strObjectId=splitValue[1];
			String tableRowId = splitValue[3];
			DomainObject strObj=new DomainObject(strObjectId);
			ContextUtil.pushContext(context);
			strObj.setAttributeValue(context,"SEM Is Locked","NO");
			strObj.setAttributeValue(context,"SEM Lock StartTime","");
			strObj.setAttributeValue(context,"SEM Lock FinishTime","");
			ContextUtil.popContext(context);
%>
<script>
	//parent.location.href=parent.location.href;
	parent.emxEditableTable.refreshRowByRowId("<%=tableRowId%>");
</script>
<%
		}
	

	}
%>


