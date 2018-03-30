<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page language="java" pageEncoding="UTF-8"%>
<% 

	String mode=emxGetParameter(request,"mode");
	if(mode.equals("submit"))
	{
		String[] emxTableRowId= emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue=emxTableRowId[i].split("\\|");
			String strObjectId=splitValue[1];
			DomainObject strObj=new DomainObject(strObjectId);
			StringList busList = new StringList("id");
			StringList relList = new StringList(DomainRelationship.SELECT_ID);
			boolean flag=true;
			MapList mapList=strObj.getRelatedObjects(context, "Subtask", "Task Management", busList, relList, false, true, (short)3, null, null);
			Iterator items=mapList.iterator();
			while(items.hasNext())
			{
			Map map=(Map)items.next();
			String taskId=(String)map.get("id");
			DomainObject taskObj = new DomainObject(taskId);
			StringList personIdList = taskObj.getInfoList(context,"to[Assigned Tasks].from.id");
			if(personIdList.size()>0){
				flag=true;
			}else{
				flag=false;
				break;
			}
		}
		if(flag){
		ContextUtil.pushContext(context);
		strObj.setAttributeValue(context,"SEM Edit Status","P3");	
		ContextUtil.popContext(context);
		
	%>
<script>
    alert("\u63D0\u4EA4\u6210\u529F!");
	parent.location.href=parent.location.href;
</script>
<%
		}else{
%>
<script>
    alert("\u5B50\u4EFB\u52A1\u4E2D\u6CA1\u6709\u4EFB\u52A1\u8D1F\u8D23\u4EBA\uFF0C\u4E0D\u5141\u8BB8\u63D0\u4EA4\u64CD\u4F5C!");
</script>

<%
		}
	}
	}else if(mode.equals("submit1")){
		String strObjectId=emxGetParameter(request,"objectId");
		DomainObject strObj=new DomainObject(strObjectId);
		StringList busList = new StringList("id");
	    StringList relList = new StringList(DomainRelationship.SELECT_ID);
		boolean flag=true;
		MapList mapList=strObj.getRelatedObjects(context, "Subtask", "Task Management", busList, relList, false, true, (short)3, null, null);
		Iterator items=mapList.iterator();
		while(items.hasNext()){
			Map map=(Map)items.next();
			String taskId=(String)map.get("id");
			DomainObject taskObj = new DomainObject(taskId);
			StringList personIdList = taskObj.getInfoList(context,"to[Assigned Tasks].from.id");
			if(personIdList.size()>0){
				flag=true;
			}else{
				flag=false;
				break;
			}
		}
		if(flag){
		ContextUtil.pushContext(context);
		strObj.setAttributeValue(context,"SEM Edit Status","P3");	
		ContextUtil.popContext(context);
%>
<script>
    alert("\u63D0\u4EA4\u6210\u529F!");
	parent.location.href=parent.location.href;
</script>
<%
		}else{
%>
<script>
    alert("\u5B50\u4EFB\u52A1\u4E2D\u6CA1\u6709\u4EFB\u52A1\u8D1F\u8D23\u4EBA\uFF0C\u4E0D\u5141\u8BB8\u63D0\u4EA4\u64CD\u4F5C!");
</script>
<%			
		}
	}else if(mode.equals("confirm1")){
		String strObjectId=emxGetParameter(request,"objectId");
		DomainObject strObj=new DomainObject(strObjectId);
		ContextUtil.pushContext(context);
		strObj.setAttributeValue(context,"SEM Edit Status","P4");	
		ContextUtil.popContext(context);
%>
<script>
    alert("\u786E\u8BA4\u6210\u529F!");
	parent.location.href=parent.location.href;
</script>
<%
	}else if(mode.equals("rollback1")){
		String strObjectId=emxGetParameter(request,"objectId");
		DomainObject strObj=new DomainObject(strObjectId);
		ContextUtil.pushContext(context);
		strObj.setAttributeValue(context,"SEM Edit Status","P2");	
		ContextUtil.popContext(context);
%>
<script>
    alert("\u9000\u56DE\u6210\u529F!");
	parent.location.href=parent.location.href;
</script>
<%
	}
%>

