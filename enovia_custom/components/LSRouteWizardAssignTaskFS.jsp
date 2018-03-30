<%--  emxRouteWizardAssignTaskFS.jsp   -   Assign Tasks Frameset for Route Wizard
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteWizardAssignTaskFS.jsp.rca 1.8 Wed Oct 22 16:18:48 2008 przemek Experimental przemek $
--%>

<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%

     String keyValue=emxGetParameter(request,"keyValue");
      framesetObject fs = new framesetObject();

      //String initSource = emxGetParameter(request,"initSource");
      String initSource = (String)formBean.getElementValue("initSource");

      if (initSource == null){
        initSource = "";
      }

       String jsTreeID   =  (String)formBean.getElementValue("jsTreeID");
       String suiteKey   =  (String)formBean.getElementValue("suiteKey");
       String portalMode =  (String)formBean.getElementValue("portalMode");

      fs.setDirectory(appDirectory);
      fs.useCache(false);

  // ----------------- Do Not Edit Above ------------------------------


       String projectId     =  (String) formBean.getElementValue("objectId");
       String routeId       =  (String) formBean.getElementValue("routeId");
       String templateId    =  (String) formBean.getElementValue("templateId");
       String templateName  =  (String) formBean.getElementValue("templateName");
       String scopeId       =  (String) formBean.getElementValue("scopeId");
       String actionName    =  (String) formBean.getElementValue("selectedAction");
       String sortName      =  (String) formBean.getElementValue("sortName");
       String supplierOrgId =  (String) formBean.getElementValue("supplierOrgId");


       String fromPageStr  =  (String) formBean.getElementValue("fromPage");
       String toAccessPage =  (String) formBean.getElementValue("toAccessPage");
       String slctdd    =  (String) formBean.getElementValue("slctdd");
       String slctmm    =  (String) formBean.getElementValue("slctmm");
       String slctyy    =  (String) formBean.getElementValue("slctyy");


       if ( sortName == null ) {
            sortName = "false";
       }

       DomainObject routeTemplateObj  = null;

       Hashtable hashRouteWizFirst =(Hashtable)formBean.getElementValue("hashRouteWizFirst");

       String routeTemplateId = (String)hashRouteWizFirst.get("templateId");

       String strTaskEditSetting   = getTaskSetting(context,templateId);


       // Specify URL to come in middle of frameset
       StringBuffer contentURL = new StringBuffer(128);

       contentURL.append("LSRouteWizardAssignTaskDialog.jsp");

       // add these parameters to each content URL, and any others the App needs
       contentURL.append("?suiteKey=");
       contentURL.append(suiteKey);
       contentURL.append("&initSource=");
       contentURL.append(initSource);
       contentURL.append("&jsTreeID=");
       contentURL.append(jsTreeID);
       contentURL.append("&objectId=");
       contentURL.append(projectId);
       contentURL.append("&routeId=");
       contentURL.append(routeId);
       contentURL.append("&templateId=");
       contentURL.append(templateId);
       contentURL.append("&templateName=");
       contentURL.append(XSSUtil.encodeForURL(context,templateName));
       contentURL.append("&sortName=");
       contentURL.append(sortName);
       contentURL.append("&scopeId=");
       contentURL.append(scopeId);
       contentURL.append("&selectedAction=");
       contentURL.append(actionName);
       contentURL.append("&supplierOrgId=");
       contentURL.append(supplierOrgId);
       contentURL.append("&portalMode=");
       contentURL.append(portalMode);
       contentURL.append("&slctdd=");
       contentURL.append(slctdd);
       contentURL.append("&slctmm=");
       contentURL.append(slctmm);
       contentURL.append("&slctyy=");
       contentURL.append(slctyy);
       contentURL.append("&fromPage=");
       contentURL.append(fromPageStr);
       contentURL.append("&toAccessPage=");
       contentURL.append(toAccessPage);
       contentURL.append("&keyValue=");
       contentURL.append(keyValue);
	   
		//begin---------------------------------add by tangfan 2015.4.2008   
		contentURL.append("&baseState=");
        contentURL.append(emxGetParameter(request,"baseState"));
	   //end ---------------------------------add by tangfan 2015.4.2008  

       fs.setStringResourceFile("emxComponentsStringResource");
       // Page Heading - Internationalized
       String PageHeading = "emxComponents.AssignTasksDialog.AssignTasksWS";

       // Marker to pass into Help Pages
       // icon launches new window with help frameset inside
       String HelpMarker = "emxhelpcreateroutewizard3";

       // PageHeading, HelpMarker, middleFrameURL, UsePrinterFriendly, IsDialogPage,
       // ShowPagination, ShowConversion
       fs.initFrameset(PageHeading, HelpMarker, contentURL.toString(), false, true,
                       false, false);
       fs.removeDialogWarning();



  if(strTaskEditSetting.equals("Modify/Delete Task List") || strTaskEditSetting.equals("Extend Task List") || strTaskEditSetting.equals("Modify Task List")){

      fs.createCommonLink("emxComponents.Button.AddTask",
                          "addTask()",
                          "role_GlobalUser",
                          false,
                          true,
                          "default",
                          true,
                          3);

      fs.createCommonLink("emxComponents.Button.SortTaskList",
                          "sortTaskList()",
                          "role_GlobalUser",
                          false,
                          true,
                          "default",
                          true,
                          3);

      fs.createCommonLink("emxComponents.Button.RemoveSelected",
                          "removeSelected()",
                          "role_GlobalUser",
                          false,
                          true,
                          "default",
                          false,
                          3);
     fs.createCommonLink("emxComponents.Common.AssignSelected",
                     "AssignSelected()",
                     "role_GlobalUser",
                     false,
                     true,
                     "default",
                     false,
                     3);
 } else if(strTaskEditSetting.equals("Maintain Exact Task List")){

        //Give no links
     fs.setMenu(new HashMap(), fs.getNameRoot() + "_top_menu");

  }else if(strTaskEditSetting.equals("None")){


  }else{ //THIS IS AN EXTRA CONDITION WHICH IS UNNECESSARY

      fs.createCommonLink("emxComponents.Button.AddTask",
                          "addTask()",
                          "role_GlobalUser",
                          false,
                          true,
                          "default",
                          true,
                          3);

      fs.createCommonLink("emxComponents.Button.SortTaskList",
                          "sortTaskList()",
                          "role_GlobalUser",
                          false,
                          true,
                          "default",
                          true,
                          3);

      fs.createCommonLink("emxComponents.Button.RemoveSelected",
                          "removeSelected()",
                          "role_GlobalUser",
                          false,
                          true,
                          "default",
                          false,
                          3);
     fs.createCommonLink("emxComponents.Common.AssignSelected",
                     "AssignSelected()",
                     "role_GlobalUser",
                     false,
                     true,
                     "default",
                     false,
                     3);

  }//till here

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


  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
