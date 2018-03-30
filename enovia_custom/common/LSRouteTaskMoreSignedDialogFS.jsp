<%--  emxLifecycleAddApproverFS.jsp   -   <description>

   Copyright (c) 1992-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleAddApproverFS.jsp.rca 1.6.3.2 Wed Oct 22 15:47:58 2008 przemek Experimental przemek $
--%>
<%@page import="com.matrixone.apps.common.InboxTask"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.DomainObject"%>

<%

 framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String suiteKey     = emxGetParameter(request,"suiteKey");
  String objectId = emxGetParameter(request, "objectId");
  fs.setDirectory(appDirectory);
  String emxTableRowId [] = emxGetParameterValues(request, "emxTableRowId");
  String sTaskId = "";
  if(emxTableRowId != null && emxTableRowId.length > 0)
  {
	  StringList splitRowId = FrameworkUtil.split(emxTableRowId[0], "|");
	  if(splitRowId.size() == 3)
	  {
		  sTaskId = (String) splitRowId.get(0);
	  }else{
		  sTaskId = (String) splitRowId.get(1);
	  }
  }else{
	  sTaskId = objectId;
  }
  String sRouteId = getTaskRelatedRouteId(context ,sTaskId);
  
  
  String model = emxGetParameter(request,"model");
  if(model == null || model.equals(""))
  {
	  model = "MoreSigned";
  }
  
  String timeStamp = emxGetParameter(request,"timeStamp");
  String portalMode =  emxGetParameter(request,"portalMode");
  String relId = emxGetParameter(request,"relId");
  String portalCmdName =  emxGetParameter(request,"portalCmdName");
  String parentOID = emxGetParameter(request,"parentOID");
  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer();
  contentURL.append("LSRouteTaskMoreSignedDialog.jsp");
  contentURL.append("?suiteKey=" + suiteKey + "&initSource=" + initSource);
  contentURL.append("&objectId=" + sTaskId);
  contentURL.append("&timeStamp=" + timeStamp);
  contentURL.append("&parentOID=" + sRouteId);
  contentURL.append("&routeId=" + sRouteId);
  contentURL.append("&model=" + model);
  
  // add these parameters to each content URL, and any others the App needs
  fs.setStringResourceFile("emxComponentsStringResource");
  // Page Heading - Internationalized
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpaddapprover";
  String strLanguage = request.getHeader("Accept-Language");

//  String PageHeading = getI18NString("emxFrameworkStringResource","emxComponents.Command.MassDistribution", strLanguage);
  String PageHeading = "DY.emxComponents.Common." + model;
	// Process subtitle's place holder macros

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);

/*   fs.createCommonLink("AddTask",
          "addTask()",
          "role_GlobalUser",
          false,
          true,
          "default",
          true,
          3);
	 */

  fs.createFooterLink("LS.emxFramework.Lifecycle.Done",
			          "done_onclick()",
			          "role_GlobalUser",
			          false,
			          true,
			          "common/images/buttonDialogDone.gif",
			          3);
  
  fs.createFooterLink("LS.emxFramework.Lifecycle.Cancel",
                      "cancel_onclick()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>

<%!
	public String getTaskRelatedRouteId(Context context, String sTaskId)throws Exception
	{
		DomainObject taskObject = DomainObject.newInstance(context, sTaskId);
		String sRouteId = taskObject.getInfo(context, "from[" + InboxTask.RELATIONSHIP_ROUTE_TASK + "].to.id");
		return sRouteId;
	}
%>
