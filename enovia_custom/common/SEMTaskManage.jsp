<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@page language="java" pageEncoding="UTF-8"%>

<%
	StringList busList = new StringList("id");
    StringList relList = new StringList(DomainRelationship.SELECT_ID);
    String mode=(String)emxGetParameter(request,"mode");

	if("AssignedTask".equals(mode))
    {
		String taskId=(String)emxGetParameter(request,"taskId");
		DomainObject taskObj = new DomainObject(taskId);
		String tableId=(String)emxGetParameter(request,"tableId");
		MapList personList = taskObj.getRelatedObjects(context,"Assigned Tasks","Person",busList,relList,true,false,(short)1,"","");
		Iterator it = personList.iterator();
		while(it.hasNext())
		{
			Map personMap = (Map)it.next();
			String relId = (String)personMap.get("id[connection]");
			DomainRelationship.disconnect(context, relId);
		}
		String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue = emxTableRowId[i].split("\\|");
			String personId = splitValue[1];
			DomainObject personObj = new DomainObject(personId);			 
			ContextUtil.pushContext(context);	
			DomainRelationship del = personObj.connectTo(context,"Assigned Tasks",taskObj); 			
			ContextUtil.popContext(context);
		}
%>
	<script>
		
		window.top.opener.emxEditableTable.refreshRowByRowId("<%=tableId%>");
		window.top.close();
	</script>
<%		
	}else if("removePerson".equals(mode))
    {
		String taskId=(String)emxGetParameter(request,"taskId");
		DomainObject taskObj = new DomainObject(taskId);
		MapList personList = taskObj.getRelatedObjects(context,"Assigned Tasks","Person",busList,relList,true,false,(short)1,"","");
		Iterator it = personList.iterator();
		while(it.hasNext())
		{
			Map personMap = (Map)it.next();
			String relId = (String)personMap.get("id[connection]");
			DomainRelationship.disconnect(context, relId);
		}	
	}else if("TaskReviewer".equals(mode)){
		
		String taskId=(String)emxGetParameter(request,"taskId");
		DomainObject taskObj = new DomainObject(taskId);
		String tableId=(String)emxGetParameter(request,"tableId");
		MapList personList = taskObj.getRelatedObjects(context,"SEM Task Reviewer","Person",busList,relList,false,true,(short)1,"","");
		Iterator it = personList.iterator();
		while(it.hasNext())
		{
			Map personMap = (Map)it.next();
			String relId = (String)personMap.get("id[connection]");
			DomainRelationship.disconnect(context, relId);
		}
		String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue = emxTableRowId[i].split("\\|");
			String personId = splitValue[1];
			DomainObject personObj = new DomainObject(personId);			 
			ContextUtil.pushContext(context);	
			DomainRelationship del = taskObj.connectTo(context,"SEM Task Reviewer",personObj); 			
			ContextUtil.popContext(context);
		}
%>
	<script>		
		window.top.opener.emxEditableTable.refreshRowByRowId("<%=tableId%>");
		window.top.close();
	</script>
<%			
	}else if("removeReviewer".equals(mode)){
		String taskId=(String)emxGetParameter(request,"taskId");
		DomainObject taskObj = new DomainObject(taskId);
		MapList personList = taskObj.getRelatedObjects(context,"SEM Task Reviewer","Person",busList,relList,false,true,(short)1,"","");
		Iterator it = personList.iterator();
		while(it.hasNext())
		{
			Map personMap = (Map)it.next();
			String relId = (String)personMap.get("id[connection]");
			DomainRelationship.disconnect(context, relId);
		}	
	}else if("RelatedTask".equals(mode)){
		String objectId=(String)emxGetParameter(request,"objectId");
		DomainObject taskObj = new DomainObject(objectId);
		StringList connectedList = connectedIdList(context,objectId,"SEM Related Task");
		String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue = emxTableRowId[i].split("\\|");
			String subTaskId = splitValue[1];
			DomainObject subTaskObj = new DomainObject(subTaskId);	
			String strType = subTaskObj.getType(context);
			if(strType.equals("Project Space"))
			{
				continue;
			}
			if(!connectedList.contains(subTaskId))
			{
				ContextUtil.pushContext(context);	
				DomainRelationship del = taskObj.connectTo(context,"SEM Related Task",subTaskObj); 			
				ContextUtil.popContext(context);
			}
			
		}
%>
	<script>
		window.top.opener.location.href=window.top.opener.location.href;
		window.top.close();
	</script>
<%		
	}else if("RemoveRelatedTask".equals(mode)){
		
		try{
			String objectId = emxGetParameter(request,"objectId");
			DomainObject assetObj = new DomainObject(objectId);
			String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
			for(int i=0;i<emxTableRowId.length;i++)
			{
				String[] splitValue = emxTableRowId[i].split("\\|");			
				String sRelationshipIds = splitValue[0];
				ContextUtil.pushContext(context);
				DomainRelationship.disconnect(context, sRelationshipIds);
				ContextUtil.popContext(context);				
			}
		}catch(Exception e){
			throw new Exception(e.getMessage());
		}
%>
	<script>
		parent.location.href =parent.location.href ;
	</script>
<%	
	}else if("CostItemRelatedTask".equals(mode)){
		String objectId=(String)emxGetParameter(request,"objectId");
		DomainObject CostItemObj = new DomainObject(objectId);
		StringList connectedList = connectedIdList(context,objectId,"Affected Item");
		String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue = emxTableRowId[i].split("\\|");
			String subTaskId = splitValue[1];
			DomainObject subTaskObj = new DomainObject(subTaskId);	
			String strType = subTaskObj.getType(context);
			if(strType.equals("Project Space"))
			{
				continue;
			}
			if(!connectedList.contains(subTaskId))
			{
				ContextUtil.pushContext(context);	
				DomainRelationship del =CostItemObj.connectTo(context,"Affected Item",subTaskObj); 			
				ContextUtil.popContext(context);
			}
			
		}
%>
	<script>
		window.top.opener.location.href=window.top.opener.location.href;
		window.top.close();
	</script>
<%		
	}else if("RiskRelatedTask".equals(mode)){
		String objectId=(String)emxGetParameter(request,"objectId");
		//System.out.println("objectId123--"+objectId);
		DomainObject RiskObj = new DomainObject(objectId);
		StringList connectedList = connectedIdList(context,objectId,"Risk");
		String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue = emxTableRowId[i].split("\\|");
			String subTaskId = splitValue[1];
			DomainObject subTaskObj = new DomainObject(subTaskId);	
			String strType = subTaskObj.getType(context);
			if(strType.equals("Project Space"))
			{
				continue;
			}
			try{
			if(!connectedList.contains(subTaskId))
			{
				ContextUtil.pushContext(context);	
				DomainRelationship del=RiskObj.connectTo(context,"Risk",subTaskObj); 			
				ContextUtil.popContext(context);
			}
			}catch(Exception e){
			   e.printStackTrace();
		    }
			
		}
%>
	<script>
		window.top.opener.location.href=window.top.opener.location.href;
		window.top.close();
	</script>
<%		
	}
%>




<%!
	public StringList connectedIdList(Context context,String fromId,String relationship)throws Exception
	{
		StringList busList = new StringList("id");
		StringList connectedIdList = new StringList();
		try{
			DomainObject strObject = new DomainObject(fromId);
			MapList mapList = strObject.getRelatedObjects(context,relationship,"*",busList,null,false,true,(short)1,null,null);
			
			for(int i = 0 ; i < mapList.size(); i++)
			{
				Map map = (Map)mapList.get(i);
				String personId = (String)map.get("id");
				connectedIdList.add(personId);
			}		
		}catch(Exception e){
			e.printStackTrace();
		}
		return connectedIdList;
	}
%>
