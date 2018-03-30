<%--  emxRouteWizardActionRequiredFS.jsp   -   Frameset for Action required
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteWizardActionRequiredFS.jsp.rca 1.11 Tue Oct 28 19:01:05 2008 przemek Experimental przemek $
--%>

	<%@include file = "../emxUIFramesetUtil.inc"%>
	<%@include file = "emxRouteInclude.inc"%>

	<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

	<%
     String keyValue=emxGetParameter(request,"keyValue");
   	formBean.processForm(session,request,"keyValue");


    framesetObject fs = new framesetObject();

  //String initSource = emxGetParameter(request,"initSource");
   String initSource = (String)formBean.getElementValue("initSource");

   if (initSource == null){
    initSource = "";
   }
   String newTaskIds=emxGetParameter(request,"newTaskIds");
   if (newTaskIds == null) 
       newTaskIds="";
   String jsTreeID = (String)formBean.getElementValue("jsTreeID");
   String suiteKey = (String)formBean.getElementValue("suiteKey");
   String portalMode = (String)formBean.getElementValue("portalMode");


   fs.setDirectory(appDirectory);
   fs.useCache(false);

  // ----------------- Do Not Edit Above ------------------------------


    String sourcePage = "";
	//Added for bug 356917
	 Map mapRouteDetails = (Map) session.getAttribute("routeDetailsMap");
	 session.removeAttribute("routeDetailsMap");
	 if(mapRouteDetails != null)
	     formBean.setElementValue("mapRouteDetails", mapRouteDetails);
	// Ended
     Enumeration paramNames = request.getParameterNames();

     Map paramMap = new HashMap();
     while(paramNames.hasMoreElements()) {
      String paramName = (String)paramNames.nextElement();
      String paramValue = emxGetParameter(request,paramName);
      paramMap.put(paramName, paramValue);
      if (paramName.equals("sourcePage")){
        sourcePage = paramValue;
      }
     }
//Bug No:306217  Dt:20-Jun-2005
//############################
String test =(String)session.getAttribute("RouteInstructions"); 
session.removeAttribute("RouteInstructions");
paramMap.put("RouteInstructions", test);
//############################
//Bug No:306217  Dt:20-Jun-2005

     formBean.setElementValue("strParams", paramMap);
     formBean.setFormValues(session);

     fs.setStringResourceFile("emxComponentsStringResource");

     // Page Heading - Internationalized
     String PageHeading = "";

     if (sourcePage==null){
       sourcePage = "";
     }

     if (sourcePage.equals("EditAllTasks")){
       PageHeading = "emxComponents.EditAllTasks.StepActionRequired";
     }else{
       PageHeading = "emxComponents.ActionRequiredDialog.StepActionRequiredRW";
     }


  // Specify URL to come in middle of frameset
  String contentURL = "LSRouteWizardActionRequiredDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+ "&portalMode=" + portalMode + "&keyValue=" + keyValue +"&sourcePage="+sourcePage+"&newTaskIds="+newTaskIds;

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcreateroutewizard4";
  fs.removeDialogWarning();
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

   //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
/*   fs.createCommonLink("emxComponents.Button.Previous",
                      "goBack()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogPrevious.gif",
                      false,
                      3); */


    fs.createCommonLink("emxComponents.Button.Done",
                          "submitForm()",
                          "role_GlobalUser",
                          false,
                          true,
                          "common/images/buttonDialogDone.gif",
                          false,
                          3);


  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

  %>
