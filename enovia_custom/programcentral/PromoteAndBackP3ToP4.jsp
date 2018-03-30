<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page language="java" pageEncoding="UTF-8"%>
<% 

	String mode=emxGetParameter(request,"mode");
	if(mode.equals("confirm"))
	{
		String[] emxTableRowId= emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue=emxTableRowId[i].split("\\|");
			String strObjectId=splitValue[1];
			DomainObject strObj=new DomainObject(strObjectId);
			ContextUtil.pushContext(context);
			strObj.setAttributeValue(context,"SEM Edit Status","P4");	
			ContextUtil.popContext(context);
		}
	%>
<script>
    alert("\u786E\u8BA4\u6210\u529F!");
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
			strObj.setAttributeValue(context,"SEM Edit Status","P2");	
			ContextUtil.popContext(context);
		}	
%>
<script>
     alert("\u9000\u56DE\u6210\u529F!");
	parent.location.href=parent.location.href;
</script>
<%
	}
%>
