<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page language="java" pageEncoding="UTF-8"%>
<% 

	String mode=emxGetParameter(request,"mode");
	if(mode.equals("Closed"))
	{
		String[] emxTableRowId= emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue=emxTableRowId[i].split("\\|");
			String strObjectId=splitValue[1];
			DomainObject strObj=new DomainObject(strObjectId);
			ContextUtil.pushContext(context);
			MqlUtil.mqlCommand(context, "trigger off", true);
			int objState=strObj.setState(context,"Closed");
			MqlUtil.mqlCommand(context, "trigger on", true);
			ContextUtil.popContext(context);
		}	
	%>
<script>
	parent.location.href=parent.location.href;
</script>
<%
	}else if(mode.equals("rollback"))
	{
		String[] emxTableRowId= emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue=emxTableRowId[i].split("\\|");
			String strObjectId=splitValue[1];
			DomainObject strObj=new DomainObject(strObjectId);
			ContextUtil.pushContext(context);
		//	strObj.setAttributeValue(context,"Percent Complete","90");	
			int objState=strObj.setState(context,"Assign");
			ContextUtil.popContext(context);
		}	
%>
<script>
	parent.location.href=parent.location.href;
</script>
<%
	}
%>
