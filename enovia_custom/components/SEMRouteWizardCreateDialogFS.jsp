<%--  emxRouteWizardCreateDialogFS.jsp   -   Create Frameset for Route Wizard
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>

<jsp:useBean id="emxRouteWizardCreateDialogFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
    String keyValue=emxGetParameter(request,"keyValue");
    if(keyValue == null){
       keyValue = formBean.newFormKey(session);
    }
    String firstTime=emxGetParameter(request,"init1");
    /*For the First time clear the Form Bean*/
    if(firstTime!=null && firstTime.equals("true"))
    {
           formBean.clear();
    }
        
    formBean.processForm(session,request,"keyValue");
    String tableBeanName = "emxRouteWizardCreateDialogFS";
    framesetObject fs    = new framesetObject();
    String initSource = (String)formBean.getElementValue("initSource");
    if(initSource == null){
       initSource = "";
    }
    String jsTreeID   =  (String)formBean.getElementValue("jsTreeID");
    String suiteKey   =  (String)formBean.getElementValue("suiteKey");
    String portalMode =  (String)formBean.getElementValue("portalMode");
    fs.setDirectory(appDirectory);
    fs.useCache(false);

  // ----------------- Do Not Edit Above ------------------------------

  //Customization for supplier review feature in spec
   String supplierOrgId = null;
   String tableRowId = emxGetParameter(request,"emxTableRowId");
   if(tableRowId != null && !"null".equals(tableRowId) && tableRowId.trim().length() > 0)
   {
     supplierOrgId = tableRowId;
   }
   else
   {
     supplierOrgId = emxGetParameter(request,"supplierOrgId");
   }
// till here for supplier review

   String searchDocId          =  (String)formBean.getElementValue("ContentID");
   String routeName            =  (String) formBean.getElementValue("routeName");
   String relatedObjectId      =  (String) formBean.getElementValue("objectId");
   String routeId              =  (String) formBean.getElementValue("routeId");
   String templateId           =  (String) formBean.getElementValue("templateId");
   String templateName         =  (String) formBean.getElementValue("templateName");
   String scopeId              =  (String) formBean.getElementValue("scopeId");
   String routeAction          =  (String) formBean.getElementValue("selectedAction");
   String documentID           =  (String) formBean.getElementValue("documentID");
   String sContentId           =  (String) formBean.getElementValue("contentId");
   String previousButtonClick  =  (String) formBean.getElementValue("previous");
   String selscope = (String) formBean.getElementValue("selscope");
   String workspaceId = (String) formBean.getElementValue("sourceWorkspaceId");

   String testingDOCID = null;

   try{

      testingDOCID = (String)(((Hashtable)formBean.getElementValue("hashRouteWizFirst")).get("documentID"));


    if(searchDocId != null){
    	if(testingDOCID != null)
    		  searchDocId += testingDOCID;
    }else{
      searchDocId = testingDOCID;
    }

     //TESTING THE VALUES OF HASHROUTEWIZFIRST

   }catch(Exception cet){ }


try{
  if (routeAction == null){
    routeAction = "false";
  }

  //the below code is used for storing the Seleted State condition of the content(Part)

  HashMap hashStateMap    =  new HashMap();

  // coded added for bug no 295687
  if((previousButtonClick !=  null || !"null".equals(previousButtonClick)) || "true".equals(previousButtonClick) ){
  //tiil here

     String stateSelect[]  =  emxGetParameterValues(request, "stateSelect");
     DomainObject domOb    =  DomainObject.newInstance(context);

    if(stateSelect != null){
      for(int i = 0 ; i < stateSelect.length; i++){
		 
        StringTokenizer sTok =  new StringTokenizer(stateSelect[i], "#");
        while(sTok.hasMoreTokens()){
          String obId = sTok.nextToken();
          if(obId != null && !"".equals(obId) && !"null".equals(obId)){
            hashStateMap.put(obId , sTok.nextToken());
          }
        }
      }

      formBean.setElementValue("hashStateMap",hashStateMap);
    }//if

  }else{

      formBean.setElementValue("hashStateMap",hashStateMap);

  }

   formBean.setFormValues(session);
 }catch(Exception cte){
   throw new Exception(cte.getMessage());
 }
 //till here

 //code to test whether teamcentral is installed or not.

  boolean bTeam = FrameworkUtil.isSuiteRegistered(context,"featureVersionTeamCentral",false,null,null);
  boolean bProgram = FrameworkUtil.isSuiteRegistered(context,"appVersionProgramCentral",false,null,null);


 // the below string is used to check whether the JTFile is configured or not.

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(175);
  contentURL.append("SEMRouteWizardCreateDialog.jsp");

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
  contentURL.append("&templateName=");
  contentURL.append(XSSUtil.encodeForURL(context,templateName));
  contentURL.append("&templateId=");
  contentURL.append(templateId);
  contentURL.append("&scopeId=");
  contentURL.append(scopeId);
  contentURL.append("&selectedAction=");
  contentURL.append(routeAction);
  contentURL.append("&documentId=");
  contentURL.append(documentID);
  contentURL.append("&contentId=");
  contentURL.append(sContentId);
  contentURL.append("&previous=");
  contentURL.append(previousButtonClick);
  contentURL.append("&routeName=");
  contentURL.append(XSSUtil.encodeForURL(context,routeName));
  contentURL.append("&supplierOrgId=");
  contentURL.append(supplierOrgId);
  contentURL.append("&portalMode=");
  contentURL.append(portalMode);
  contentURL.append("&searchDocId=");
  contentURL.append(searchDocId);
  contentURL.append("&beanName=");
  contentURL.append(tableBeanName);
  contentURL.append("&keyValue=");
  contentURL.append(keyValue);
  contentURL.append("&selscope=");
  contentURL.append(selscope);
  contentURL.append("&firstTime=");
  contentURL.append(firstTime);
//begin ---------------------------------------add by tangfan 2015.4.18
  contentURL.append("&baseState=" + emxGetParameter(request,"baseState"));
//begin ---------------------------------------add by tangfan 2015.4.18
  if(workspaceId != null && workspaceId.trim().length() > 0 ){
	  contentURL.append("&workspaceId=");
	  contentURL.append(workspaceId);
  }

  fs.setBeanName(tableBeanName);

  fs.setStringResourceFile("emxComponentsStringResource");



  // Page Heading - Internationalized
  String PageHeading = "emxComponents.CreateRouteWizardDialog.SpecifyDetailsRW";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside


  String HelpMarker = "emxhelpcreateroutewizard1";


  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);

  fs.createCommonLink("emxComponents.Common.AddContent",
            "AddContent()",
            "role_GlobalUser",
            false,
            true,
            "default",
            true,
            3);


  fs.createCommonLink("emxComponents.Button.RemoveSelected",
            "removeContentSelected()",
            "role_GlobalUser",
            false,
            true,
            "default",
            false,
              3);


   // show Upload only if TeamCentral or ProgramCentral is installed
   if ((bTeam == true) || (bProgram == true))
   {
      //Image Modified for Bug : 350816
      fs.createCommonLink("emxComponents.Common.Upload",
                          "uploadExternalFile()",
                          "role_GlobalUser",
                          false,
                          true,
                          "../common/images/iconActionUploadFile.png",
                          true,
                          3);

      /*if ((strEAIVismarkViewerEnabled != null) &&
          ("true".equals(strEAIVismarkViewerEnabled)))
      {
        fs.createCommonLink("emxTeamCentral.Button.UploadExternalJTFile",
        com.matrixone.apps.domain.util.XSSUtil.encodeForURL("showEditDialogPopup()"),
        "role_ExchangeUser,role_CompanyRepresentative",
        false,
        true,
        "default",
        true,
        3);
      }*/
   }


   fs.createFooterLink("emxComponents.Button.Next",
                       "submitForm()",
                       "role_GlobalUser",
                       false,
                       true,
                       "common/images/buttonDialogNext.gif",
                       3);

   fs.createFooterLink("emxComponents.Button.Cancel",
                       "closeWindow()",
                       "role_GlobalUser",
                       false,
                       true,
                       "common/images/buttonDialogCancel.gif",
                       3);

  // ----------------- Do Not Edit Below ------------------------------

   fs.writePage(out);

%>
