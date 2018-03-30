<%--  emxLifecycleAddApproverFS.jsp   -   <description>

   Copyright (c) 1992-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleAddApproverFS.jsp.rca 1.6.3.2 Wed Oct 22 15:47:58 2008 przemek Experimental przemek $
--%>
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

  fs.setDirectory(appDirectory);

  String objectId = emxGetParameter(request, "objectId");
  String timeStamp = emxGetParameter(request,"timeStamp");
  String portalMode =  emxGetParameter(request,"portalMode");
  String relId = emxGetParameter(request,"relId");
  String portalCmdName =  emxGetParameter(request,"portalCmdName");
  String objectName = emxGetParameter(request,"objectName");
  String parentOID = emxGetParameter(request,"parentOID");
  String routeObjectIDS = emxGetParameter(request,"routeObjectIDS");
  if(routeObjectIDS.length()>0 && (routeObjectIDS.lastIndexOf("~") == routeObjectIDS.length()-1))
  {
	 routeObjectIDS = routeObjectIDS.substring(0, routeObjectIDS.length()-1);
  }
  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer();
  contentURL.append("LSTaskAppointedParticipantsDialog.jsp");
  contentURL.append("?suiteKey=" + suiteKey + "&initSource=" + initSource);
  contentURL.append("&objectId=" + objectId);
  contentURL.append("&timeStamp=" + timeStamp);
  contentURL.append("&parentOID=" + parentOID);
  contentURL.append("&objectName=" + objectName);
  contentURL.append("&routeObjectIDS=" + routeObjectIDS);
  
  // add these parameters to each content URL, and any others the App needs
  fs.setStringResourceFile("emxFrameworkStringResource");
  // Page Heading - Internationalized
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpaddapprover";
  String strLanguage = request.getHeader("Accept-Language");

//  String PageHeading = getI18NString("emxFrameworkStringResource","emxComponents.Command.MassDistribution", strLanguage);
  String PageHeading = "\u6307\u6D3E\u53C2\u4E0E\u8005";
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

  fs.createFooterLink("emxFramework.Lifecycle.Done",
			          "done_onclick()",
			          "role_GlobalUser",
			          false,
			          true,
			          "common/images/buttonDialogDone.gif",
			          3);
  
  fs.createFooterLink("emxFramework.Lifecycle.Cancel",
                      "cancel_onclick()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
