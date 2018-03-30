<%--  emxRouteWizardAccessMembersFS.jsp   -  Display Frameset for AccessMembers
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteWizardAccessMembersFS.jsp.rca 1.14 Wed Oct 22 16:18:49 2008 przemek Experimental przemek $
--%>


  <%@include file = "../emxUIFramesetUtil.inc"%>
  <%@include file = "emxRouteInclude.inc"%>

  <jsp:useBean id="emxRouteWizardAccessMembersFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
  <jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

  <%
  
  String keyValue=emxGetParameter(request,"keyValue");
  if(keyValue == null){
      keyValue = formBean.newFormKey(session);
  }
  formBean.processForm(session,request,"keyValue");
  formBean.setElementValue("toAccessPage","");
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.useCache(false);
  String initSource = (String)formBean.getElementValue("initSource");
  if(initSource == null || initSource.equals("null")){
      initSource = "";
  }
  String jsTreeID    =  (String) formBean.getElementValue("jsTreeID");
  String suiteKey    =  (String) formBean.getElementValue("suiteKey");
  String portalMode  =  (String) formBean.getElementValue("portalMode");
  String relatedObjectId  =  (String) formBean.getElementValue("objectId");
  String routeId          =  (String) formBean.getElementValue("routeId");
  String supplierOrgId    =  (String) formBean.getElementValue("supplierOrgId");
  String templateId  =  (String) formBean.getElementValue("templateId");
  String scopeId     =  (String) formBean.getElementValue("scopeId");
  String templateName  =  (String) formBean.getElementValue("templateName");
  String routeAction   =  (String) formBean.getElementValue("selectedAction");
  String toAccessPage  =  (String) formBean.getElementValue("toAccessPage");
  DomainObject routeTemplateObj  = null;
  String strTaskEditSetting   = getTaskSetting(context,templateId);

    String tableBeanName = "emxRouteWizardAccessMembersFS";
    // flag to find if user coming back from step 4 to 3
    // Specify URL to come in middle of frameset
    StringBuffer contentURL = new StringBuffer(128);
    contentURL.append("LSRouteWizardAccessMembersDialog.jsp");
    // add these parameters to each content URL, and any others the App needs
    contentURL.append("?suiteKey=");
    contentURL.append(suiteKey);
    contentURL.append("&initSource=");
    contentURL.append(initSource);
    contentURL.append("&jsTreeID=");
    contentURL.append(jsTreeID);
    contentURL.append("&objectId=");
    contentURL.append(relatedObjectId);
    contentURL.append("&routeId=");
    contentURL.append(routeId);
    contentURL.append("&templateId=");
    contentURL.append(templateId);
    contentURL.append("&scopeId=");
    contentURL.append(scopeId);
    contentURL.append("&templateName=");
    contentURL.append(XSSUtil.encodeForURL(context,templateName));
    contentURL.append("&selectedAction=");
    contentURL.append(routeAction);
    contentURL.append("&supplierOrgId=");
    contentURL.append(supplierOrgId);
    contentURL.append("&portalMode=");
    contentURL.append(portalMode);
    contentURL.append("&showWarning=false");
    contentURL.append("&keyValue=");
    contentURL.append(keyValue);
	
	//begin--------------------------- add by tangfan 2015.4.20
	contentURL.append("&baseState=");
	contentURL.append(emxGetParameter(request,"baseState"));
	//end   --------------------------- add by tangfan 2015.4.20
	
    contentURL.append("&beanName=");
    contentURL.append("emxRouteWizardAccessMembersFS");

    fs.setStringResourceFile("emxComponentsStringResource");
    // Page Heading - Internationalized
    String PageHeading = "emxComponents.AddMembersDialogFS.AddMembersforRW";
    // Marker to pass into Help Pages
    // icon launches new window with help frameset inside
    String HelpMarker= "emxhelpcreateroutewizard2";
    fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,true,false);
    fs.setBeanName(tableBeanName);

    if(strTaskEditSetting.equals("Extend Task List") || strTaskEditSetting.equals("Modify Task List") ||
            strTaskEditSetting.equals("Modify/Delete Task List") || strTaskEditSetting.equals(""))
    {
        fs.createCommonLink("emxComponents.AddMembersDialog.AddPeople",
                        "addMembers()",
                        "role_GlobalUser",
                        false,
                        true,
                        "default",
                        true,
                        3);

		// Bug 296093 - Modified javascript method for passing parameter      
        fs.createCommonLink("emxComponents.Button.RemoveSelected",
                      "removeMembers('removeMember')",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      false,
                      0);

        if(supplierOrgId == null || "null".equals(supplierOrgId) || supplierOrgId.trim().length() == 0)
        {
        	
        	fs.useCache(false);
        	String availability  = (String)formBean.getElementValue("selscope");
        	if(availability == null || ! availability.equals("ScopeName")){         
               fs.createCommonLink("emxComponents.AddMembersDialog.AddRole",
                                        "addRole()",
                                        "role_GlobalUser",
                                        false,
                                        true,
                                        "default",
                                        true,
                                        3);
                fs.createCommonLink("emxComponents.AddMembersDialog.AddGroup",
                                        "addGroup()",
                                        "role_GlobalUser",
                                        false,
                                        true,
                                        "default",
                                        true,
                                        3);
        	}
                fs.createCommonLink("emxComponents.AddMembersDialog.AddMemberList",
                                        "addMemberList()",
                                        "role_GlobalUser",
                                        false,
                                        true,
                                        "default",
                                        true,
                                        3);
        }
} else {
	fs.setMenu(new HashMap(), fs.getNameRoot() + "_top_menu");
}
    fs.createCommonLink("emxComponents.Button.Previous",
                      "goBack()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogPrevious.gif",
                      false,
                      3);

   fs.createCommonLink("emxComponents.Button.Next",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
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
    fs.removeDialogWarning();
    fs.writePage(out);
%>

