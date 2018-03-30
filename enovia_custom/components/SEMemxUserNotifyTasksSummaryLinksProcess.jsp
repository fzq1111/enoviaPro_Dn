<%-- emxTasksSummaryLinksProcess.jsp -- for Opening the Window on clicking the Top links in Content Page.
  Copyright (c) 1992-2008 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxUserTasksSummaryLinksProcess.jsp.rca 1.2.2.1.7.4.26.2 Mon Nov  9 11:41:34 2009 ds-rgajjelli Experimental przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek przemek $
--%>
<%@ page import = "com.matrixone.apps.domain.*,com.matrixone.apps.framework.ui.UINavigatorUtil, com.matrixone.apps.common.*,com.matrixone.apps.domain.util.*,com.matrixone.apps.common.UserTask" %>

<%@ include file = "../emxUICommonAppInclude.inc"%>


<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%@include file = "emxRouteInclude.inc" %>
<%
	String sOutput = "";
	String errMsg = "";
	String objName = "";

	String isFDAEnabled = FrameworkProperties.getProperty(context,"emxFramework.Routes.EnableFDA");	
	
	formBean.processForm(session,request);
	
	String keyValue=emxGetParameter(request,"keyValue");
	if(keyValue == null)
	{
		keyValue = formBean.newFormKey(session);
	}	
	
	formBean.processForm(session, request, "keyValue");
	
	boolean blnAction=false;
	String jsTreeID   = emxGetParameter(request,"jsTreeID");
    String suiteKey   = emxGetParameter(request,"suiteKey");
	String isFDAEntered   = emxGetParameter(request,"isFDAEntered");
    String comments   = emxGetParameter(request,"txtComments");
	String sAction   = emxGetParameter(request,"fromPage");

    if( comments == null || comments.equals(""))
	{
        comments   = (String)formBean.getElementValue("txtComments");
	}

	String objectId[] = formBean.getElementValues("emxTableRowId");
	Map map = new HashMap();
	map.put("objectId", objectId);
	String[] args = JPO.packArgs(map);
	try{
		JPO.invoke(context, "emxInboxTask", null, "readNotifyOnlyTask", args);
	}catch(Exception e){
		e.printStackTrace();
	}
%>

<script type="text/javascript">
	if (parent.window.opener != null)
	{
		parent.window.opener.parent.location.href = parent.window.opener.parent.location.href;
		top.close();
	}
	else
	{
		parent.window.location.href = parent.window.location.href;
		//parent.location.reload();
	}
</script>