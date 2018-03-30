 <%--  emxRouteWizardCreateDialog.jsp-  Create Dialog for Route Wizard
 Copyright (c) 1992-2015 Dassault Systemes.All Rights Reserved.
 This program contains proprietary and trade secret information of MatrixOne, Inc.
 Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

 static const char RCSID[] = $Id: emxRouteWizardCreateDialog.jsp.rca 1.64 Wed Oct 22 16:17:50 2008 przemek Experimental przemek $
 --%>

 <%@ include file = "../emxUICommonAppInclude.inc" %>
 <%@ include file = "../emxJSValidation.inc" %>
 <%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
 <%@ include file = "../components/emxComponentsJavaScript.js"%>
 <%@ include file = "../components/emxRouteInclude.inc" %>
 <%@ include file = "../emxPaginationInclude.inc" %>
 <%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
 <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<%!
// Modified by Infosys for bug no. 297904, dated 05/20/2005
public static String populateCombo1(Context context,String sAttrRouteCompletionAction,boolean bSupplier,boolean bShowRouteAction,HttpServletRequest request, String routeCompletionActionValue)
                throws FrameworkException,MatrixException
{
  // Not to show the option of 'Promote connected object if ONLY Supplier Central is installed
  // to check if SupplierCentral is installed
  //get applications installed and versions
  //EXECUTE THE TCL PROGRAM
   String Result = "";
   String sErrorCode = "";
   String prMQLString;
   MQLCommand prMQL  = new MQLCommand();
   prMQL.open(context);
   prMQLString = "execute program eServiceHelpAbout.tcl ";
   prMQL.executeCommand(context,prMQLString);
   Result = prMQL.getResult().trim();
   String error = prMQL.getError();
   StringBuffer strBuff  = new StringBuffer();
   if( Result.equals(""))//tcl program does not exist
   {
  //   session.putValue("Error",error);
   }
  StringTokenizer token = new StringTokenizer(Result, "|", false);
  sErrorCode = token.nextToken().trim();//first token
  if( sErrorCode.equals("1"))//internal failure of tcl program
  {
  token.nextToken().trim();//second token
  }
  StringList strApps = new StringList();
  while (token.hasMoreTokens()){
    strApps.addElement(token.nextToken()); //will store name of application
    token.nextToken(); //will have build number
  }
  String sAttrRange = "";

  if(strApps.size()==1 && bSupplier)
  {
    StringItr strItr = new StringItr(FrameworkUtil.getRanges(context,sAttrRouteCompletionAction));
    while(strItr.next())
    {
      sAttrRange = strItr.obj();
      if(sAttrRange.equals("Promote Connected Object"))
      {
        strBuff.append("<option value='"+XSSUtil.encodeForHTML(context,sAttrRange)+"' selected>"+i18nNow.getRangeI18NString(sAttrRouteCompletionAction, sAttrRange,request.getHeader("Accept-Language"))+"</option>");
        break;
      }
    }
 }
 else
 {
        StringItr strItr = new StringItr(FrameworkUtil.getRanges(context,sAttrRouteCompletionAction));
        // Begin of Modify by Infosys for bug no. 297904, dated 05/20/2005
        if(bShowRouteAction)
        {
            while(strItr.next())
            {
              sAttrRange = strItr.obj();
              strBuff.append("<option value='"+XSSUtil.encodeForHTML(context,sAttrRange)+"' ");
              if(!sAttrRange.equals(routeCompletionActionValue))
                strBuff.append("selected");
              strBuff.append(">");
              strBuff.append(" "+i18nNow.getRangeI18NString(sAttrRouteCompletionAction, sAttrRange,request.getHeader("Accept-Language"))+"</option>");
            }
        }
        else
        {
            while(strItr.next())
            {
              sAttrRange = strItr.obj();
              if(!sAttrRange.equals("Promote Connected Object"))
              {
                      strBuff.append("<option value='"+sAttrRange+"' ");
                      if(sAttrRange.equals(routeCompletionActionValue))
                        strBuff.append("selected");
                      strBuff.append(">");
                      strBuff.append(" "+i18nNow.getRangeI18NString(sAttrRouteCompletionAction, sAttrRange,request.getHeader("Accept-Language"))+"</option>");
              }

            }
            // End of Modify by Infosys for bug no. 297904, dated 05/20/2005

        }
 }
return strBuff.toString();
}

%>

 <jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

 <%

     String keyValue=emxGetParameter(request,"keyValue");
     String firstTime=emxGetParameter(request,"firstTime");
     if(keyValue == null){
       keyValue = formBean.newFormKey(session);
     }
     formBean.processForm(session,request,"keyValue");

     String strLanguage = request.getHeader("Accept-Language");
     String sAttrRestrictMembers  = PropertyUtil.getSchemaProperty(context, "attribute_RestrictMembers" );
     String sAttrRouteBasePurpose = PropertyUtil.getSchemaProperty(context, "attribute_RouteBasePurpose" );
     String sAttrAutoStopOnRejection = PropertyUtil.getSchemaProperty(context, "attribute_AutoStopOnRejection" );
     String sAttrRestartUponTaskRejection = PropertyUtil.getSchemaProperty(context, "attribute_RestartUponTaskRejection" );
     String SELECT_RESTRICT_MEMBERS= DomainObject.getAttributeSelect(sAttrRestrictMembers);
     String SELECT_ROUTE_BASE_PURPOSE = DomainObject.getAttributeSelect(sAttrRouteBasePurpose);
     String routeRestrictMembers = "";
     String routeBasePurpose = "Standard";
     String routeAutoStop = "Immediate";
     Route route = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
     String scopeChecking = EnoviaResourceBundle.getProperty(context,"emxComponentsRoutes.RouteUse");
     boolean bTeam = FrameworkUtil.isSuiteRegistered(context,"featureVersionTeamCentral",false,null,null);
     boolean bProgram = FrameworkUtil.isSuiteRegistered(context,"appVersionProgramCentral",false,null,null);
     boolean bSupplier= FrameworkUtil.isSuiteRegistered(context,"appVersionSupplierCentral",false,null,null);
     // Added by Infosys for bug no. 297904, dated 05/20/2005
     boolean bShowRouteAction = true;

     HashMap hashStateMap =  new HashMap();
     String relatedObjectId    =  (String) formBean.getElementValue("objectId");
     String routeId            =  (String) formBean.getElementValue("routeId");
     String routeTemplateId    =  (String) formBean.getElementValue("templateId");
     String template           =  (String) formBean.getElementValue("templateName");
     String scopeId            =  (String) formBean.getElementValue("scopeId");
     String routeAction        =  (String) formBean.getElementValue("selectedAction");
     String supplierOrgId      =  (String) formBean.getElementValue("supplierOrgId");
     String suiteKey           =  (String) formBean.getElementValue("suiteKey");
     String portalMode         =  (String) formBean.getElementValue("portalMode");
     String documentID         =  (String) formBean.getElementValue("documentID");
     String previousButtonClick  =  (String) formBean.getElementValue("previousButtonClick");
     String routeName          =  (String) formBean.getElementValue("routeName");
     String jsTreeID           =  (String) formBean.getElementValue("jsTreeID");
     String sContentId =  (String) formBean.getElementValue("contentID");
     String searchDocId  =  (String) formBean.getElementValue("searchDocId");
     String workspaceId  =  (String) formBean.getElementValue("workspaceId");
	 
	 // begin ----------------------------add by tangfan 2015.4.18
	 

	   String baseState = "Review";
	   
	    // end ----------------------------add by tangfan 2015.4.18
     //Error message for string length
     String errMessage=EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.Create.NameColumn");
     if (sContentId == null)
       sContentId = searchDocId;
     session.putValue("RouteContent",sContentId);

     String selectedAction=  (String) formBean.getElementValue("selectedAction");
     String routeDescription =  (String) formBean.getElementValue("routeDescription");
     String addContent=  (String) formBean.getElementValue("addContent");
     String removeContent=  (String) formBean.getElementValue("removeContent");
     if(formBean.getElementValue("hashStateMap") != null && !formBean.getElementValue("hashStateMap").equals(""))
       hashStateMap = (HashMap) formBean.getElementValue("hashStateMap");
     if(routeDescription == null){
       routeDescription = "";
     }
//begin ----------------------------------------------add by tangfan 2015.4.18

				HashMap programMap1 = new HashMap();
					programMap1.put("objectId", sContentId);
					programMap1.put("txtName", "*");
					programMap1.put("selScope", "Enterprise");
					if (emxGetParameter(request,"baseState")!=null && !"".equals(emxGetParameter(request,"baseState")))
						baseState = emxGetParameter(request,"baseState");
					programMap1.put("strState", baseState);
     
     MapList templateList = (MapList) JPO.invoke(context,"LSCreateRouteUtil", null , "getAllSearchRouteTemplates" ,  JPO.packArgs(programMap1), MapList.class);

     if (templateList.size() ==1 ) {

	template = (String)((Map)templateList.get(0)).get("name");
	routeTemplateId = (String)((Map)templateList.get(0)).get("id");
	routeDescription = (String)((Map)templateList.get(0)).get("description");
     }
 //end ----------------------------------------------add by tangfan 2015.4.18
     //start of code added for the bug 313531
     ArrayList contentSelectArray = new ArrayList();
     if(formBean.getElementValue("contentSelectArray") != null && !formBean.getElementValue("contentSelectArray").equals("")) {
       contentSelectArray = (ArrayList) formBean.getElementValue("contentSelectArray");
     }
      //end of code added for the bug 313531

  boolean boolHostCompanyEmployee=false;
     boolean isSupplierReview = (!"null".equals(supplierOrgId) && supplierOrgId.trim().length() > 0)?true:false;
     String sAttrRouteCompletionAction = PropertyUtil.getSchemaProperty(context, "attribute_RouteCompletionAction" );
     String relVaultedObject = PropertyUtil.getSchemaProperty(context, "relationship_VaultedObjects");
     String routeCompletionActionValue = "Notify Route Owner";
     String sAttrRange = "";
     String sGenericType  = "";
     String sGenericName  = "";
     String sType= null;
     String routeAutoName = "";
     String selscope= "All";
     if(scopeChecking.equals("Exchange")) {
         selscope="Organization";
     }
     String routeStart = "start";
     String visblToParent = "Yes";
     String selscopeId = "";
     String selscopeName  = "";
     String projectId  = relatedObjectId;
     String prjId              ="";
     Hashtable hashRouteWizFirst = new  Hashtable();
     MapList routeMemberMapList = new MapList();
     //To get the Stored value from the Session
     String relRTSQuotation = PropertyUtil.getSchemaProperty(context, "relationship_RTSQuotation");
     String relCompRFQ= PropertyUtil.getSchemaProperty(context, "relationship_CompanyRFQ");
     String relRFQHolder = PropertyUtil.getSchemaProperty(context, "relationship_RFQHolder");
     String strSelectScope = i18nNow.getI18nString("emxComponents.CreateRoute.SelectScope", "emxComponentsStringResource",
                                           request.getHeader("Accept-Language"));
     String strCantChangeScope = i18nNow.getI18nString("emxComponents.CreateRouteWizardDialog.CantChangeScope", "emxComponentsStringResource",
             request.getHeader("Accept-Language"));
     String sName  = strSelectScope;

     String buyerCompany = "";
     String sRev= "";
     String sVer= "";
     String sRotableIds  = "";
     String sPolicy= "";
     String sStates= "";
     String sNoneValue= "None";// i18nNow.getI18nString("emxComponentsStringResource", "emxComponents.AttachmentsDialog.none", sLanguage);
     if(previousButtonClick == null || previousButtonClick.equals("null")){
       previousButtonClick = "";
     }
     if(addContent == null || addContent.equals("null")){
       addContent = "";
     }
     if(removeContent == null || removeContent.equals("null")){
       removeContent = "";
     }


	  if(firstTime!=null && firstTime.equals("true")){
       formBean.setElementValue("hashRouteWizFirst","");
       formBean.setElementValue("routeMemberMapList",null);
       formBean.setElementValue("taskMapList",null);
       formBean.setElementValue("routeRoleMapList",null);
       formBean.setElementValue("routeGroupMapList",null);
       hashRouteWizFirst.put("routeName","");
       hashRouteWizFirst.put("templateId","");
       hashRouteWizFirst.put("routeAutoName","");
       hashRouteWizFirst.put("routeDescription","");
       hashRouteWizFirst.put("objectId","");
       hashRouteWizFirst.put("documentID","");
       hashRouteWizFirst.put("projectId","");
       hashRouteWizFirst.put("uploadedDocIDs",new MapList());
       hashRouteWizFirst.put("routeAutoStop",routeAutoStop);
       //added to track change in scope and route templates
       hashRouteWizFirst.put("prevRouteTemplateId","");
       hashRouteWizFirst.put("prevSelectedScope","");
       hashRouteWizFirst.put("prevSelectedScopeId","");
     // added on 16th March
     if( relatedObjectId != null && !relatedObjectId.equals("null") && !"".equals(relatedObjectId)) {
        DomainObject dobj = new DomainObject(relatedObjectId);

        // Begin of Add by Infosys for bug no. 297904, dated 05/20/2005

        // Checks whether the context user has access to promote the object connected to route.

        if(!FrameworkUtil.hasAccess(context, dobj, "promote"))
         {
            bShowRouteAction = false;
         }

        // End of Add by Infosys for bug no. 297904, dated 05/20/2005


        String typeName = dobj.getInfo(context,"type");
         if(typeName.equals(DomainObject.TYPE_TASK)) {
                 StringList busSelects = new StringList();
                 busSelects.addElement(DomainObject.SELECT_ID);
                 busSelects.addElement(DomainObject.SELECT_NAME);
                 busSelects.addElement(DomainObject.SELECT_TYPE);
                 com.matrixone.apps.common.Task task = new com.matrixone.apps.common.Task();
                 task.setId(relatedObjectId);
                 Map taskMap = (Map) task.getProject(context,busSelects);
                 String prjType =(String)taskMap.get(DomainObject.SELECT_TYPE);
                 //Modified to handle Bug 330327 0
                 if(prjType.equals(DomainObject.TYPE_PROJECT_SPACE) || mxType.isOfParentType(context,prjType,DomainConstants.TYPE_PROJECT_SPACE)) {
                     selscope= "ScopeName";
                  }else{
                     selscope= "All";
                 }
         }
         if( (typeName.equals(DomainObject.TYPE_WORKSPACE)) || (typeName.equals(DomainObject.TYPE_PROJECT_SPACE)) || (mxType.isOfParentType(context,typeName,DomainConstants.TYPE_PROJECT_SPACE)) || (typeName.equals(DomainObject.TYPE_WORKSPACE_VAULT))) {
             selscope= "ScopeName";
         }
     }
       // till here
     }else {
       hashRouteWizFirst = (Hashtable)formBean.getElementValue("hashRouteWizFirst");

       routeAutoName  = (String)hashRouteWizFirst.get("routeAutoName");
       if (routeAutoName == null)
         routeAutoName = "";
       routeName= (String)hashRouteWizFirst.get("routeName");
       if (routeName == null)
         routeName = "";
       // Commented for the Issue 336838
     //  if ((routeName.equals("")) && (routeAutoName.equals("")))
       //  routeAutoName = "checked";
       routeTemplateId= (String)hashRouteWizFirst.get("templateId");
       routeDescription  = (String)hashRouteWizFirst.get("routeDescription");
       template  = (String)hashRouteWizFirst.get("templateName");
       routeBasePurpose = (String)hashRouteWizFirst.get("routeBasePurpose");
       routeAutoStop = (String)hashRouteWizFirst.get("routeAutoStop");
       routeCompletionActionValue  = (String)hashRouteWizFirst.get("routeCompletionAction");
       selscope = (String)hashRouteWizFirst.get("selscope");
       if(selscope==null)
       {
    	   selscope="All";
    	}   
       if(selscope.equals("ScopeName")){
         selscopeId = (String)hashRouteWizFirst.get("selscopeId");
         selscopeName  = (String)hashRouteWizFirst.get("selscopeName");
       }
       routeStart  = (String)hashRouteWizFirst.get("routeStart");
       visblToParent  = (String)hashRouteWizFirst.get("visblToParent");
       //The below code is written for the bug fix 326102
    if(visblToParent == null || visblToParent.equals("null"))
       {
           visblToParent="";
       }
    //end of the code for the bug 326102
       formBean.removeElement("previousButtonClick");
       formBean.removeElement("addContent");
       formBean.removeElement("removeContent");

     }
     if(routeName.equals("null") || routeName == null) {
       routeName = "";
     }

     if("null".equals(template) || template == null) {
       template = "";
     }
     boolean assignRouteDescription = routeTemplateId != null && !"null".equals(routeTemplateId) && !"".equals(routeTemplateId) && !"Blank".equals(routeTemplateId);
     if(!assignRouteDescription) {
         routeTemplateId =  null; //"Blank";
     }
     if(projectId != null && !projectId.equals("null") && !"".equals(projectId)) {
       BusinessObject boGeneric = new BusinessObject(projectId);
       boGeneric.open(context);
       sGenericName = boGeneric.getName();
       sGenericType = boGeneric.getTypeName();
       scopeId = boGeneric.getObjectId();
      if( (!sGenericType.equals(DomainConstants.TYPE_PROJECT)) &&
                  (!sGenericType.equals(DomainObject.TYPE_PROJECT_VAULT)) &&
                             (!sGenericType.equals(DomainObject.TYPE_INBOX_TASK)))  {
          Pattern relPattern  = new Pattern(relVaultedObject);
          Pattern typePattern = new Pattern(DomainConstants.TYPE_PROJECT_VAULT);
          BusinessObject boWorkspaceVault = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,boGeneric,relPattern.getPattern(),typePattern.getPattern(),true,false);
          if(boWorkspaceVault != null){
             boWorkspaceVault.open(context);
             projectId  = boWorkspaceVault.getObjectId();
             sGenericName  = boWorkspaceVault.getName();
             boWorkspaceVault.close(context);
         }else {
           DomainObject domainObject = DomainObject.newInstance(context,boGeneric);
           String meetingId =  domainObject.getInfo(context, "to[" + DomainObject.RELATIONSHIP_MEETING_ATTACHMENTS + "].from.id");
           String messageId =  domainObject.getInfo(context, "to[" + DomainObject.RELATIONSHIP_MESSAGE_ATTACHMENTS + "].from.id");
           DomainObject domObj = DomainObject.newInstance(context);
           if(messageId != null && !"".equals(messageId)){
              Document doc = (Document)DomainObject.newInstance(context,domainObject,DomainConstants.TEAM);
              projectId = doc.getWorkspaceId(context);
              if(!"".equals(projectId))
              {
                 DomainObject domProj = DomainObject.newInstance(context,projectId);
                 sGenericType = domProj.getType(context);
                 sGenericName = domProj.getName();
              }
           }else if(meetingId != null && !"".equals(meetingId)) {
              domObj.setId(meetingId);
              //Modified for bug 374633 as per new design in Meetings management code
              projectId = domObj.getInfo(context,"to[" + DomainObject.RELATIONSHIP_MEETING_CONTEXT + "].from.id");
              //Modification ends for 374633
              domObj.setId(projectId);
              sGenericType = domObj.getType(context);
              sGenericName = domObj.getName();
          }
          domObj.setId(projectId);
       }// eof else
       scopeId = projectId;
       //At first step  parent document object is added to route
       if(firstTime!=null && firstTime.equals("true")){
           hashRouteWizFirst.put("documentID",relatedObjectId+"~");
        }
       }
      if(sGenericType.equals(DomainConstants.TYPE_WORKSPACE)){
         sType          = i18nNow.getI18nString("emxComponents.Common.Workspace", "emxComponentsStringResource", strLanguage);
      }
      else if(sGenericType.equalsIgnoreCase(DomainConstants.TYPE_INBOX_TASK)) {
         sType = i18nNow.getI18nString("emxComponents.Common.Workspace", "emxComponentsStringResource", strLanguage);
         String selectWorkspaceID  ="from["+DomainObject.RELATIONSHIP_ROUTE_TASK+"].to.to["+DomainObject.RELATIONSHIP_ROUTE_SCOPE+"].from.id";
         try {
            DomainObject domainObject =DomainObject.newInstance(context,boGeneric.getObjectId());
            prjId  =domainObject.getInfo(context,selectWorkspaceID);
            DomainObject wkspaceObject= DomainObject.newInstance(context, prjId);
            if(wkspaceObject.getType(context).equals("Workspace")) {
               scopeId=prjId;
               sGenericName=wkspaceObject.getName(context);
               //projectId=prjId;
            }else {
               scopeId=UserTask.getProjectId(context,prjId);
               wkspaceObject.setId(scopeId);
               sGenericName=wkspaceObject.getName(context);
               //projectId=scopeId;
            }
         }catch(Exception e){
         }
      }else {
         sType= i18nNow.getI18nString("emxComponents.Common.Folder", "emxComponentsStringResource", strLanguage);
      }
      boGeneric.close(context);
     }

     if(scopeId != null || !scopeId.equals("null")) {
       hashRouteWizFirst.put("scopeId",scopeId);
     }
     formBean.setElementValue("hashRouteWizFirst",hashRouteWizFirst);
     formBean.setFormValues(session);
//     String folderURL = "emxCommonSelectWorkspaceFolderDialogFS.jsp";
     String folderURL = "../common/emxIndentedTable.jsp?expandProgram=emxWorkspace:getWorkspaceVaults&table=TMCSelectFolder&program=emxWorkspace:getDisabledWorkspaces&header=emxFramework.IconMail.Common.SelectOneFolder&customize=false&objectCompare=false&HelpMarker=emxhelpsearch&displayView=details&multiColumnSort=false&submitURL=../components/emxCommonSelectWorkspaceFolderProcess.jsp&cancelLabel=Cancel&submitLabel=Done";
     String sParams = "jsTreeID=jsTreeID&suiteKey=suiteKey";

     String changeScope = (String) formBean.getElementValue("selscope");
     if((changeScope == null) || (changeScope.equals(""))) {
       changeScope = "null";
     }

     MapList routeMemberList = null;
     Hashtable hashRouteWiz  = null;
     String document = "";
     int size = 0;
     String Content= (String)formBean.getElementValue("ContentID");

 // BugNO:294573

     if (Content == null)
       Content = searchDocId;


 // BugNO:294573

     try {
       routeMemberList = (MapList)formBean.getElementValue("routeMemberMapList");
       if (routeMemberList != null) {
         size = routeMemberList.size();
       }
       hashRouteWiz = (Hashtable)formBean.getElementValue("hashRouteWizFirst");
       if (hashRouteWiz != null) {
         document = (String)hashRouteWiz.get("documentID");
       }
     }catch(Exception rml){ }

     boolean documentInRoute = false;
     if(size>0 || (document!=null && !document.equals("null") && !"".equals(document)) || (Content!=null && !Content.equals("null") && !"".equals(Content))) {
         documentInRoute = true;
     }
 %>
 <html>
 <body>
 <script language="javascript">

     // function to truncate the blank values.
     function trim (textBox) {
       while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" ) {
         textBox = textBox.substring(0,textBox.length - 1);
       }
       while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n") {
         textBox = textBox.substring(1,textBox.length);
       }
      return textBox;
     }

 function autoNameValue() {
     if(document.createDialog.routeAutoName.checked ) {
         document.createDialog.routeName.value = "";
         //document.createDialog.routeAutoName.focus();
         document.createDialog.routeAutoName.value="checked";
         document.createDialog.routeName.disabled=true;
     }else {
         document.createDialog.routeName.disabled=false;
         document.createDialog.routeAutoName.value="";
     }
      return;
 }

     function submitForm() {
       var namebadCharDescrption = checkForBadChars(document.createDialog.txtdescription);
         var checkedAutoname = false;
         var namebadCharName = checkForUnifiedNameBadChars(document.createDialog.routeName, true);
         var nameAllBadCharName = getAllNameBadChars(document.createDialog.routeName);
         var name = document.createDialog.routeName.name;
         var routeNameLengthCheck=checkValidLength(document.createDialog.routeName.value);
         if (namebadCharName.length != 0) {
             alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInvalidInput</emxUtil:i18nScript>"+nameAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript> "+name+" <emxUtil:i18nScript localize="i18nId">emxComponents.Alert.Field</emxUtil:i18nScript>");
           document.createDialog.routeName.focus();
           return;
       } 
         else if(!routeNameLengthCheck){
        	 alert("<%=errMessage%>");
        	 document.createDialog.routeName.focus();
             return;
         }
         else if (!document.createDialog.routeAutoName.checked ) {
            if(document.createDialog.routeName.value=="") {
              alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreateFolderDialog.EnterRouteName</emxUtil:i18nScript>");
              document.createDialog.routeName.focus();
              return;
            } else if(!(isValidLength(trim(document.createDialog.routeName.value), 1,127))) {
              alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreateFolderDialog.NameAlertMessage</emxUtil:i18nScript>");
              document.createDialog.routeName.focus();
              return;
        }
            document.createDialog.routeName.value = trim(document.createDialog.routeName.value);
         }

       for(var i=0; i < document.createDialog.selscope.length; i++) {
    	    if (document.createDialog.selscope[i].checked && document.createDialog.selscope[i].value == "ScopeName" && document.createDialog.workspaceFolder.value == "<%=XSSUtil.encodeForJavaScript(context, strSelectScope)%>") {
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreateRoute.EnterRouteScope</emxUtil:i18nScript>");
            return;
          }
       }
       if(namebadCharDescrption.length != 0) {
    	   alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.InvalidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
          document.createDialog.txtdescription.focus();
          return;
       } else if(trim(document.createDialog.txtdescription.value)=="") {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreateFolderDialog.EnterRouteDesc</emxUtil:i18nScript>");
          document.createDialog.txtdescription.focus();
          return;
       } else {
          // Make sure user doesnt double clicks on create route
          if (jsDblClick()) {
         for(var i=0; i < document.createDialog.selscope.length; i++) {
        		   if (document.createDialog.selscope[i].checked) {
        			    if(document.createDialog.selscope[i].value=="ScopeName") {
             document.createDialog.scopeId.value = document.createDialog.workspaceFolderId.value;
           } else {
           document.createDialog.scopeId.value = document.createDialog.selscope[i].value;
           }
         }
         }
   startProgressBar();
   document.createDialog.submit();
   return;
 }

 }


 }


   // function to close the window and refresh the parent window.
  function closeWindow() {
     submitWithCSRF("emxRouteWizardCancelProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>", window);
 }

 
 //function  to move the focus from routeAutoName to description,when tab is pressed in routeAutoName checkBox.
 function moveFocus(){
  document.createDialog.txtdescription.focus();
  return;
 }

 function clear() {

   if(trim(document.createDialog.templateName.value) !=null) {
  document.createDialog.templateName.value="";
  document.createDialog.templateId.value="";
   }

   return;
 }


  function uploadExternalFile() {
   var routeName1 = document.createDialog.routeName.value;
   var description1 = document.createDialog.txtdescription.value;
   //var routeStart1 = document.createDialog.routeStart.value;
   var routeStart1=null;
   var routeCompletionAction1 = document.createDialog.routeCompletionAction.value;
   var routeBasePurpose1 = document.createDialog.routeBasePurpose.value;
   var template1 = document.createDialog.template.value;
   var templateId1 = document.createDialog.templateId.value;
   var selscope1 = null;
   var workspaceFolderId1 = null;
   var workspaceFolder1 = null;
   var routeAutoStop1 = document.createDialog.routeAutoStop.value;
   for (var varj = 0; varj < document.createDialog.elements.length; varj++)
   {

         if (document.createDialog.elements[varj].type == "radio" && document.createDialog.elements[varj].name == "routeStart")
         {
                 if(document.createDialog.routeStart[0].checked==true){
                         routeStart1="start";
                 }else if (document.createDialog.routeStart[1].checked==true )
                 {
                         routeStart1="";
                 }
         }
         if (document.createDialog.elements[varj].type == "radio" && document.createDialog.elements[varj].name == "selscope")
         {
                 if(document.createDialog.selscope[0].checked==true)
                 {
                         selscope1 = document.createDialog.selscope[0].value;
                 }else if (document.createDialog.selscope[1].checked==true )
                 {
                         selscope1 = document.createDialog.selscope[1].value;
                         if(selscope1 == "ScopeName")
                         {
                                 workspaceFolder1 = document.createDialog.workspaceFolder.value;
                                 workspaceFolderId1 = document.createDialog.workspaceFolderId.value;
                         }
                 }else if (document.createDialog.selscope[2].checked==true)
                 {
                         selscope1 = document.createDialog.selscope[2].value;
                         workspaceFolder1 = document.createDialog.workspaceFolder.value;
                         workspaceFolderId1 = document.createDialog.workspaceFolderId.value;
                 }else if (document.createDialog.elements[varj].type == "hidden" && document.createDialog.elements[varj].name == "selscope")
                 {
                         selscope1 = document.createDialog.selscope.value;
                 }
         }
   }
   //jp char checkin fix
  showCheckinDialog("../components/emxCommonDocumentPreCheckin.jsp?showDescription=required&JPOName=emxRouteDocumentBase&showFolder=required&folderURL="+ encodeURIComponent('<%=folderURL%>')+ "&parentRelName=relationship_VaultedDocuments&objectAction=create&appDir=components&appProcessPage=emxRouteUploadPostProcess.jsp&parentId=RouteWizard&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&routeName="+encodeURIComponent(routeName1)+"&routeDescription="+encodeURIComponent(description1)+"&selscope="+selscope1+"&routeStart="+routeStart1+"&routeCompletionAction="+routeCompletionAction1+"&routeBasePurpose="+routeBasePurpose1+"&templateName="+escape(template1)+"&templateId="+templateId1+"&workspaceFolder="+workspaceFolder1+"&workspaceFolderId="+workspaceFolderId1+"&routeAutoStop="+routeAutoStop1,750,500);
  }
  function removeContentSelected() {
   var varChecked = "false";
   var objForm = document.createDialog;
   for (var i=0; i < objForm.elements.length; i++) {
     if (objForm.elements[i].type == "checkbox")
     {
       if ((objForm.elements[i].name.indexOf('chkItem1') > -1) && (objForm.elements[i].checked == true)) {
 varChecked = "true";
   }
   }
 }
 if (varChecked == "false") {
   alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AttachmentsDialog.SelectContent</emxUtil:i18nScript>");
   return;
 } else {
   if (confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.AttachmentsDialog.MsgConfirm</emxUtil:i18nScript>") != 0)  {
  document.createDialog.action="emxRouteWizardRemoveContentProcess.jsp?fromPage=routeWizard&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>";

  document.createDialog.submit();
  return;
   }
 }
  }
//Added  for the Bug :348854 Starts
function doCheck(){
    var objForm = document.forms[0];
    var chkList = objForm.chkList;

    for (var i=0; i < objForm.elements.length; i++)
      if (objForm.elements[i].name.indexOf('chkItem') > -1){
        objForm.elements[i].checked = chkList.checked;
      }

  }
  //Added  for the Bug :348854 Ends

  //Function to uncheck all the check box values.
  function updateCheck() {
 var objForm  = document.createDialog;
 var chkList  = objForm.chkList;
  chkList.checked = false;
  }




  function AddContent() {
   var routeName1 = document.createDialog.routeName.value;
   var description1 = document.createDialog.txtdescription.value;
   //var routeStart1 = document.createDialog.routeStart.value;
   var routeStart1 = null;
   // added for the Bug 336838
   autoNameValue();
   var routeAutoName1 = document.createDialog.routeAutoName.value;
   var routeCompletionAction1 = document.createDialog.routeCompletionAction.value;
   var routeBasePurpose1 = document.createDialog.routeBasePurpose.value;
   var template1 = document.createDialog.template.value;
   var templateId1 = document.createDialog.templateId.value;
   var selscope1 = null;
   var workspaceFolderId1 = null;
   var workspaceFolder1 = null;
   var visblToParent = null;
   var routeAutoStop1 = document.createDialog.routeAutoStop.value;
   for (var varj = 0; varj < document.createDialog.elements.length; varj++) {

         if (document.createDialog.elements[varj].type == "radio" && document.createDialog.elements[varj].name == "routeStart")
         {
                 if(document.createDialog.routeStart[0].checked==true){
                         routeStart1="start";
                 }else if (document.createDialog.routeStart[1].checked==true )
                 {
                         routeStart1="";
                 }
         }

   if (document.createDialog.elements[varj].type == "radio" && document.createDialog.elements[varj].name == "selscope")
   {

   if(document.createDialog.selscope[0].checked==true)
   {
     selscope1 = document.createDialog.selscope[0].value;
   }else if (document.createDialog.selscope[1].checked==true )
   {
     selscope1 = document.createDialog.selscope[1].value;

     if(selscope1 == "ScopeName")
     {
       workspaceFolder1 = document.createDialog.workspaceFolder.value;
       workspaceFolderId1 = document.createDialog.workspaceFolderId.value;

     }
   }
   else if (document.createDialog.selscope[2].checked==true)
   {
     selscope1 = document.createDialog.selscope[2].value;
     workspaceFolder1 = document.createDialog.workspaceFolder.value;
     workspaceFolderId1 = document.createDialog.workspaceFolderId.value;
   }

   else if (document.createDialog.elements[varj].type == "hidden" && document.createDialog.elements[varj].name == "selscope")
     {
        selscope1 = document.createDialog.selscope.value;
     }
   }
   if (document.createDialog.elements[varj].type == "checkbox" && document.createDialog.elements[varj].name == "visblToParent")
   {
     visblToParent = document.createDialog.visblToParent.value;
   }
   }//eof for loop
  if(workspaceFolder1 == "" || workspaceFolderId1 =="")
  {
    alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreateRoute.EnterRouteScope</emxUtil:i18nScript>");
    return;
  }
// added for the Bug 336838

// Added for IR-043275V6R2011 Dated 22nd Mar 2010 Begins.
var vRouteName1=routeName1;
// Added for IR-043275V6R2011 Dated 22nd Mar 2010 Ends.

routeName1=escape(routeName1);

// Added for IR-043275V6R2011 Dated 22nd Mar 2010 Begins.
var vDescription1=description1;
vDescription1=vDescription1.replace(/&/g,"|amp|amp");
vRouteName1=vRouteName1.replace(/&/g,"|amp|amp");
// Added for IR-043275V6R2011 Dated 22nd Mar 2010 Ends.

description1=escape(description1);
//Till Here

// Modified by adding two more parameters for IR-043275V6R2011 Dated 22nd Mar 2010 Begins.

 emxShowModalDialog("../common/emxFullSearch.jsp?queryType=Real Time&viewFormBased=true&formInclusionList=ORIGINATOR&contentID=<%=XSSUtil.encodeForURL(context,sContentId)%>&mode=addContentCreateRoute&table=AppFolderSearchResult&showInitialResults=true&submitURL=../components/emxContentSearchProcess.jsp&program=enoAddContentSearch:search&default=ADDCONTENTTYPE=Document&form=AddContentSearchForm&selection=multiple&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&objectId=<%=XSSUtil.encodeForURL(context, relatedObjectId)%>&visblToParent="+visblToParent+"&routeName="+routeName1+"&routeDescription="+description1+"&selscope="+selscope1+"&routeStart="+routeStart1+"&routeCompletionAction="+routeCompletionAction1+"&routeBasePurpose="+routeBasePurpose1+"&template="+escape(template1)+"&templateId="+templateId1+"&workspaceFolder="+workspaceFolder1+"&scopeId="+workspaceFolderId1+"&routeAutoName="+routeAutoName1+"&vDescription1="+vDescription1+"&vRouteName1="+vRouteName1+"&routeAutoStop="+routeAutoStop1,750,500);
// Modified by adding two more parameters for IR-043275V6R2011 Dated 22nd Mar 2010 Ends.

  }

  function showTypeSelector() {

   flag = false;
 //  if(document.createDialog.selscope != null && document.createDialog.selscope.type == "radio")  commented for bug 285171
 //  {  commented for bug 285171
   for(var i=0; i < document.createDialog.selscope.length; i++) {
   if (document.createDialog.selscope[i].checked && document.createDialog.selscope[i].value == "ScopeName") {
     flag = true;
   }
   }
 //  }  commented for bug 285171
   if(flag) {

  var workspaceChooserURL = "../common/emxIndentedTable.jsp?expandProgram=emxWorkspace:getWorkspaceFoldersForSelection&table=TMCSelectFolder&program=emxWorkspace:getDisabledWorkspaces&header=emxComponents.CreateRoute.SelectScope&type=Route&suiteKey=Components&customize=false&objectCompare=false&HelpMarker=emxhelpsearch&displayView=details&multiColumnSort=false&submitLabel=emxComponents.Common.Done&cancelLabel=emxComponents.Common.Cancel&submitURL=../components/emxCommonSelectWorkspaceFolderProcess.jsp?fromPage=routeWizard";
  showModalDialog(workspaceChooserURL, "400", "400", false, "Medium");

   }
  }

  function clearAll() {
   if (document.createDialog.template.value == "" && document.createDialog.workspaceFolder)
   {
    if (document.createDialog.workspaceFolder.value!="<%=XSSUtil.encodeForJavaScript(context, strSelectScope)%>")
      document.createDialog.workspaceFolder.value="<%=XSSUtil.encodeForJavaScript(context, strSelectScope)%>";
   }
  }


  function showSearchWindow() {

  <%
 // check for the number route template objects in the system.
 int Count  = 0;
 StringList objectSelects = new StringList(1);
 objectSelects.add(DomainObject.SELECT_NAME);

   try{

   com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
   Company company = person.getCompany(context);

 MapList resultRouteTemplateList = DomainObject.findObjects(context,DomainConstants.TYPE_ROUTE_TEMPLATE,
  "*",
  "*",
  "*",
  company.getAllVaults(context,true),
  "",
  false,
  objectSelects);

 Count = resultRouteTemplateList.size();
   }catch(Exception ex){}

  if ( Count > 0 ) {
	  
	     String firstContentId = null;
	   if (sContentId!=null && !sContentId.equals("")){
	   	matrix.util.StringList contentIds = com.matrixone.apps.domain.util.FrameworkUtil.split(sContentId, ",");
		firstContentId = (String)contentIds.get(0);
	   }
	   
	   if (emxGetParameter(request,"baseState")!=null && !"".equals(emxGetParameter(request,"baseState")) && !"null".equalsIgnoreCase(emxGetParameter(request,"baseState"))) 
	   baseState =  emxGetParameter(request,"baseState");
   
	  
 %>
	  var strURL="../common/emxFullSearch.jsp?field=TYPES=type_RouteTemplate:CURRENT=policy_RouteTemplate.state_Active:LATESTREVISION=TRUE&table=RouteTemplateSummary&selection=single&fieldNameActual=Template&fieldNameDisplay=TemplateDisplay&mode=Chooser&chooserType=CustomChooser&HelpMarker=emxhelpfullsearch&showInitialResults=false&includeOIDprogram=emxRouteTemplate:getRouteTemplateIncludeIDs&submitURL=../components/emxComponentsFullSearchUtil.jsp&fromPage=routeWizard&displayView=details";
	  emxShowModalDialog(strURL, 500, 500);
	  
  <% } else { %>

 alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreateRouteDialog.RouteTemplageNotExistsMessage</emxUtil:i18nScript>");
 return;
 
 <%
  }
 %>
}


   function checkRouteStart(){
   if(document.createDialog.routeStart.checked){
   document.createDialog.routeStart.value = "start";
 }else{
  document.createDialog.routeStart.value = "";
  }
   }

   function checkvisblToParent(){
     if(document.createDialog.visblToParent.checked){
         document.createDialog.visblToParent.value = "Yes";
    }else{

       document.createDialog.visblToParent.value = "";

  }
   }
  

  function previousValue()
   {
   var ind1=0;
   var ind2=0;
 <%
   if(scopeChecking.equals("Enterprise"))
   {
 %>
     ind1=1;


 <%
 //modified for the bug 340775 
     if(selscope.equals("ScopeName"))
   {
%>

        ind2=2;

<%
   }
   else if(selscope.equals("Organization")){
%>

       ind2=1;

<%
   }
  // till here

   }
   else if(scopeChecking.equals("Exchange"))
   {
 %>
     ind1=0;
     ind2=1;
 <%
   }

   if(UIUtil.isNullOrEmpty(routeStart))
   {
 %>
     document.createDialog.routeStart[1].checked = true;
     document.createDialog.routeStart[0].checked = false;
     //document.createDialog.routeStart.value = "";
 <%
   }
   else
   {
 %>
     //document.createDialog.routeStart.value = "start";
     document.createDialog.routeStart[0].checked = true;
     document.createDialog.routeStart[1].checked = false;
 <%
   }
 %>
 for (var varj = 0; varj < document.createDialog.elements.length; varj++)
 {
   if (document.createDialog.elements[varj].type == "radio" && document.createDialog.elements[varj].name == "selscope")
   {
 <%
  if(selscope.equals("All"))
  {
 %>
    document.createDialog.selscope[0].checked = true;
    enableOrDisableScopeButton(true);
 <%
  }
  else if(selscope.equals("Organization"))
  {
 %>
   eval("document.createDialog.selscope["+ind1+"].checked = true");
   enableOrDisableScopeButton(true);
 <%
   }
   else if(selscope.equals("ScopeName"))
   {
 %>
     eval("document.createDialog.selscope["+ind2+"].checked = true");
     if(document.createDialog.template.value != ""){
    	 enableOrDisableScopeButton(true);
     }else{
    	 enableOrDisableScopeButton(false);
     }
 <%
    if(selscopeId != null && !selscopeId.equals("") && !"null".equals(selscopeId))
    {
 %>
       document.createDialog.workspaceFolderId.value = "<%=XSSUtil.encodeForJavaScript(context, selscopeId)%>";
       document.createDialog.workspaceFolder.value = "<%=XSSUtil.encodeForJavaScript(context, selscopeName)%>";
 <%
    }
   }
 %>
   }
 }
 <%
  if(routeAutoName.equals("checked"))
  {
 %>
   document.createDialog.routeAutoName.checked = true;
   document.createDialog.routeAutoName.value = "checked";
 <%
  }

 if(sGenericType.equalsIgnoreCase(DomainConstants.TYPE_INBOX_TASK))
 {
   if(visblToParent.equals(""))
   {
 %>
     document.createDialog.visblToParent.checked = false;
     document.createDialog.visblToParent.value = "";
 <%
   }
   else
   {
 %>
     document.createDialog.visblToParent.value = "Yes";
 <%
   }
 }
 %>
  }


 function setScopeId(){
 document.createDialog.workspaceFolderId.value =document.createDialog.workspaceFolder.options[document.createDialog.workspaceFolder.selectedIndex].value ;
 }
 function deleteContent(scope,changeScope1)
 {
    <%

    if (documentInRoute)
    {
    %>

// Commented for IR-030694V6R2011 Dated 22nd Feb 2010 Begins.
//     var confirmScope = confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.common.AlertForChangingScope</emxUtil:i18nScript>");
//     if(confirmScope == true){
// Commented for IR-030694V6R2011 Dated 22nd Feb 2010 Ends.
       document.createDialog.action="emxRouteWizardRemoveContentProcess.jsp?fromPage=changeScope&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&selscope="+scope;
       document.createDialog.submit();
       return;

// Commented for IR-030694V6R2011 Dated 22nd Feb 2010 Begins.
/*     }
     else
     {
       for(var i=0; i < document.createDialog.selscope.length; i++) {
        if(changeScope1 == document.createDialog.selscope[i].value)
        {
          document.createDialog.selscope[i].checked= true;
    break;
        }
       }
     }*/
// Commented for IR-030694V6R2011 Dated 22nd Feb 2010 Ends.

    <% }%>
 }
 </script>
 
 <%@include file = "../emxUICommonHeaderEndInclude.inc" %>

 <form name="createDialog" method="post" onSubmit="javascript:submitForm(); return false" action="SEMRouteWizardCreateProcess.jsp" target="_parent">
 
  <!--begin  add by tangfan 2015.4.18-->
  <input type="hidden" name="baseState"value="<xss:encodeForHTMLAttribute><%=baseState%></xss:encodeForHTMLAttribute>" />
  <!--end  add by tangfan 2015.4.18-->
  
   <input type="hidden" name="objectId"value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=routeTemplateId%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="scopeId" value="<xss:encodeForHTMLAttribute><%=scopeId%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="selectedAction" value="<xss:encodeForHTMLAttribute><%=routeAction%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="supplierOrgId" value="<xss:encodeForHTMLAttribute><%=supplierOrgId%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />

   <input type="hidden" name="parentId" value="<xss:encodeForHTMLAttribute><%=relatedObjectId%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="documentId"  value="<xss:encodeForHTMLAttribute><%=documentID%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="contentId"value="<xss:encodeForHTMLAttribute><%=sContentId%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="previous" value="<xss:encodeForHTMLAttribute><%=previousButtonClick%></xss:encodeForHTMLAttribute>" />


   <input type="hidden" name="templateName" value="<xss:encodeForHTMLAttribute><%=template%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="selectedAction" value="<xss:encodeForHTMLAttribute><%=selectedAction%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>" />
   <%
       String routeTemplateScope = ((routeTemplateId == null) || ("null".equals(routeTemplateId)) || ("".equals(routeTemplateId))) ? "" : selscope;
   %>
   <input type="hidden" name="routeTemplateScope" value="<xss:encodeForHTMLAttribute><%=routeTemplateScope%></xss:encodeForHTMLAttribute>" />

   <table>


 <tr>
  <td width="150" nowrap  class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></label></td>
  <td nowrap style="font-size: 8pt" class="field">
  <%
   //modified for the bug 313531
   if(routeName.equals("") || routeAutoName.equals(""))
   {
  %>
  <input type="hidden" name="routeName" style="font-size: 8pt" size="20" onfocus="autoNameValue()" onkeypress="autoNameValue()" onclick="autoNameValue()" onblur="autoNameValue()" onselect="autoNameValue()" onkeydown="autoNameValue()" onchange="autoNameValue()" value="<xss:encodeForHTMLAttribute><%=routeName%></xss:encodeForHTMLAttribute>" />
  <%
   } else if(routeAutoName.equals("checked")) {
  %>

  <input type="hidden" disabled="disabled" name="routeAutoName" value="checked" />&nbsp;<emxUtil:i18n localize="i18nId">emxComponents.Common.AutoName</emxUtil:i18n>&nbsp;

  <input type="hidden" name="routeName"value="" />
  <%
   } else {
  %>
 <%=routeName%>
 <input type="hidden" name="routeName"value="<xss:encodeForHTMLAttribute><%=routeName%></xss:encodeForHTMLAttribute>" />
  <%
   }
//modified for the bug 313531
   if((routeAutoName == null || "".equals(routeAutoName) || "null".equals(routeAutoName)) && ("".equals(routeName) || "null".equals(routeName)) || "checked".equals(routeAutoName)) {
  %>
 <input type="checkbox" value="checked" disabled="disabled" name="routeAutoName" onClick="autoNameValue()" checked/>&nbsp;
 <emxUtil:i18n localize="i18nId">emxComponents.Common.AutoName</emxUtil:i18n>&nbsp;
  <%
   }
   else if(!"".equals(routeName) || !"null".equals(routeName)) {
  %>
 <input type="checkbox" value="checked" name="routeAutoName" onClick="autoNameValue()" />&nbsp;
 <emxUtil:i18n localize="i18nId">emxComponents.Common.AutoName</emxUtil:i18n>&nbsp;
  <% } %>
  </td>
  </tr>


  <tr>
 <td class="label" width="150"><label for="Template"><emxUtil:i18n localize="i18nId">emxComponents.CreateRouteWizardDialog.Template</emxUtil:i18n></label></td>
 <%
 if (!(routeId != null) && !(("").equals(routeId ))) {
 %>
   <td class="field">"<%=XSSUtil.encodeForHTML(context, template)%>"&nbsp;</td>
   <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=template%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=routeTemplateId%></xss:encodeForHTMLAttribute>" />
 <%
 } else {
 %>
   <td class="field">
  <input type="text" readonly="readonly" name="template" value="<xss:encodeForHTMLAttribute><%=template%></xss:encodeForHTMLAttribute>" size="20" />
  <input type="button" name="" id="" value="..." onClick="javascript:showSearchWindow()" />
  <a href="JavaScript:updateRouteTemplateScope('createDialog','template','templateId');" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
  
  
    <script>
	  //begin by tangfan 2015.4.18
	  function update(object){
		  if (object.value=="") {
		  document.createDialog.templateId.value="";
		  document.createDialog.template.value="";
		  document.createDialog.txtdescription.value="";
		  } else {
		  var arr1 = object.value.split("@@@");
		  document.createDialog.templateId.value=arr1[0];
		  document.createDialog.template.value=arr1[1];
		  document.createDialog.txtdescription.value=arr1[2];
		  }
	}
  </script>

  <select name="templateHelper" onchange=update(this);>
	<option value=""><%="\u8BF7\u9009\u62E9\u6D41\u7A0B\u6A21\u7248"%></option>
	<%
	System.out.println("templateList============="+templateList);
	for (int k=0;k<templateList.size();k++) {
		Map tempMap = (Map)templateList.get(k);
		String templateInternal = (String)tempMap.get("name");
		String routeTemplateIdInternal = (String)tempMap.get("id");
		String routeDescriptionInternal = (String)tempMap.get("description");
	%>
	<option value="<%=routeTemplateIdInternal%>@@@<%=templateInternal%>@@@<%=routeDescriptionInternal%>"><%=templateInternal%></option>

	<%

	}
	%>
	 //end by tangfan 2015.4.18
  </select>
  
  
  
   </td>
 <%
  }
 %>
  </tr>


  <tr>
 <td class="labelRequired" width="150"><label for="Description"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></label></td>
 <td class="field" ><textarea name="txtdescription" cols="30" rows="5" wrap><xss:encodeForHTML><%=routeDescription%></xss:encodeForHTML></textarea></td>
  </tr>
  <tr>
 <td class="label" width="150"><emxUtil:i18n localize="i18nId">emxComponents.Route.RouteBasePurpose</emxUtil:i18n></td>
 <td class="inputField">
 <%= getRangeI18NString(sAttrRouteBasePurpose, "Standard",request.getHeader("Accept-Language")) %>
 <input type=hidden name="routeBasePurpose" value="Standard">
 </td>
  </tr>

  <tr>

 <td width="150" class="label" width="150"><emxUtil:i18n localize="i18nId">emxComponents.Route.Scope</emxUtil:i18n></td>
 <td class="inputField">
 <%
 if(isSupplierReview)
 {
 %>
 <!--XSSOK-->
 <%=i18nNow.getRangeI18NString(sAttrRestrictMembers, "Organization",request.getHeader("Accept-Language"))%>
 <!--input type="hidden" name="restrictMembers" value="Organization"-->
   <input type="hidden" name="selscope" value="Organization" />
 <%
 }
 else
 {
 %>
   <table border="0">

 <%
      //modified for the bug 316267
    Person personObj=Person.getPerson(context);
   // Commented for Bug 371291
   // if((Company.getHostCompany(context)).equals(personObj.getCompanyId(context)))
   //         boolHostCompanyEmployee=true;
   //   modified for the bug 371291
 if(scopeChecking.equals("Enterprise"))
     //till here modified for the bug 316267
 {
 %>
 <tr>
 <td>
 	<input type="radio" name="selscope" value="All" checked onclick = "JavaScript:setScope('All');clearAll()" />
 	&nbsp;
 	<emxUtil:i18n localize="i18nId">emxComponents.Common.All</emxUtil:i18n>
 </td>
 </tr>
 <%
 }
 %>
  <tr>
 <td>
 <!-- modified for the Bug 316267 -->
 	<input type="radio" name="selscope" value="Organization" <% if(scopeChecking.equals("Exchange")||( !boolHostCompanyEmployee)){%>checked<%}%> onclick = "JavaScript:setScope('Organization');clearAll()" />
	<!-- modified for the Bug 316267 -->
	&nbsp;
	 <emxUtil:i18n localize="i18nId">emxComponents.Common.Organization</emxUtil:i18n>
 </td>
  </tr>

 <%
 if(scopeChecking.equals("Exchange"))
     {
 %><input type="hidden" name="selscope" value="" />
 <%
     }
 if( relatedObjectId != null && !relatedObjectId.equals("null") && !"".equals(relatedObjectId))
 {

  DomainObject boProject = new DomainObject(relatedObjectId);
  String sTypeName = boProject.getInfo(context,"type");
  sName = boProject.getInfo(context,"name");
  prjId=relatedObjectId;
  //Modified to handle Bug 330327 0
  if(sTypeName.equals(DomainObject.TYPE_WORKSPACE) || sTypeName.equals(DomainObject.TYPE_WORKSPACE_VAULT) ||  sTypeName.equals(DomainObject.TYPE_PROJECT_SPACE)  || mxType.isOfParentType(context,sTypeName,DomainConstants.TYPE_PROJECT_SPACE))
  {
  %>
   <tr>
   	<td>
   		<input type="radio" name="selscope" value="ScopeName" onclick = "JavaScript:setScope('ScopeName')"  checked/>
   		&nbsp;<%=XSSUtil.encodeForHTML(context, sName)%>
   		<input type="hidden" name="workspaceFolderId" value="<xss:encodeForHTMLAttribute><%=prjId%></xss:encodeForHTMLAttribute>" />
   		<input type="hidden" name="workspaceFolder" value="<xss:encodeForHTMLAttribute><%=sName%></xss:encodeForHTMLAttribute>" />
   </td>
 </tr>
  <%
   } //if type is WS, WSV, PS
  else if(sTypeName.equalsIgnoreCase("Inbox Task")){

 String selectWorkspaceID  ="from["+DomainObject.RELATIONSHIP_ROUTE_TASK+"].to.to["+DomainObject.RELATIONSHIP_ROUTE_SCOPE+"].from.id";
 DomainObject domainObject =DomainObject.newInstance(context,boProject.getObjectId());
 prjId              =domainObject.getInfo(context,selectWorkspaceID);
 if(prjId != null && !prjId.equals(""))
 {

 DomainObject wkspaceObject= DomainObject.newInstance(context, prjId);
 String Type = wkspaceObject.getType(context);

 if(wkspaceObject.getType(context).equals("Workspace")){
 sName=wkspaceObject.getName(context);
 }
 else{

 scopeId= UserTask.getProjectId(context,prjId);
 wkspaceObject.setId(scopeId);
 sName=wkspaceObject.getName(context);
 //projectId=scopeId;
 prjId=scopeId;
 }
 %>
 <tr>
 <td>
 	<input type="radio" name="selscope" value="ScopeName" onclick = "JavaScript:setScope('ScopeName')" />
	&nbsp;<%=XSSUtil.encodeForHTML(context, sName)%>&nbsp;Type:<%=XSSUtil.encodeForHTML(context, Type)%>
	 <input type="hidden" name=workspaceFolderId value="<xss:encodeForHTMLAttribute><%=prjId%></xss:encodeForHTMLAttribute>" />
	 <input type="hidden" name="workspaceFolder" value="<xss:encodeForHTMLAttribute><%=sName%></xss:encodeForHTMLAttribute>" />
 </td>
 </tr>
 <%
 }
 else
 relatedObjectId = null;
 }
 else if(sTypeName.equalsIgnoreCase("Task"))
 {
    StringList busSelects = new StringList();
    busSelects.addElement(DomainObject.SELECT_ID);
    busSelects.addElement(DomainObject.SELECT_NAME);
    busSelects.addElement(DomainObject.SELECT_TYPE);
    com.matrixone.apps.common.Task task = new com.matrixone.apps.common.Task();
    task.setId(relatedObjectId);
    Map taskMap = (Map) task.getProject(context,busSelects);
    prjId =(String)taskMap.get(DomainObject.SELECT_ID);
    String prjName =(String)taskMap.get(DomainObject.SELECT_NAME);
    String prjType =(String)taskMap.get(DomainObject.SELECT_TYPE);
    String strPrjType = i18nNow.getTypeI18NString(prjType, strLanguage);
    String strType = i18nNow.getI18nString("emxComponents.Common.Type", "emxComponentsStringResource", strLanguage);
    //Modified to handle Bug 330327 0
    if(prjType.equals(DomainObject.TYPE_PROJECT_SPACE) || mxType.isOfParentType(context,prjType,DomainConstants.TYPE_PROJECT_SPACE))
    {

 %>
         <tr>
         	<td>
         		<input type="radio" name="selscope" value="ScopeName" onclick = "JavaScript:setScope('ScopeName')" />
		        &nbsp;<%=XSSUtil.encodeForHTML(context, prjName)%>&nbsp;<%=XSSUtil.encodeForHTML(context, strType)%>:<%=XSSUtil.encodeForHTML(context, strPrjType)%>
		         <input type="hidden" name=workspaceFolderId value="<xss:encodeForHTMLAttribute><%=prjId%></xss:encodeForHTMLAttribute>" />
        		 <input type="hidden" name="workspaceFolder" value="<xss:encodeForHTMLAttribute><%=prjName%></xss:encodeForHTMLAttribute>" />
	         </td>
         </tr>
 <%
 }else{
         sName=strSelectScope;
         prjId="";
 %>
         <tr>
         	<td><input type="radio" name="selscope" value="ScopeName" onclick = "JavaScript:setScope('ScopeName')" />
	        	&nbsp;<input type="text" name="workspaceFolder" value="<xss:encodeForHTMLAttribute><%=strSelectScope%></xss:encodeForHTMLAttribute>" readonly="readonly" />
	         	&nbsp;<input type="button" name="btnScope" value="..." onclick= "showTypeSelector()" />&nbsp;
		         <input type="hidden" name=workspaceFolderId value="" />
 	       </td>
         </tr>
 <%
         }
 }
 else if(sTypeName.equals(DomainObject.TYPE_DOCUMENT) || sTypeName.equals(DomainObject.TYPE_PACKAGE) || sTypeName.equals(DomainObject.TYPE_RTS_QUOTATION) || sTypeName.equals(DomainObject.TYPE_REQUEST_TO_SUPPLIER))
 {
                 String sName1 = "";
                 String RELATIONSHIP_VAULTED_OBJECT = PropertyUtil.getSchemaProperty(context,"relationship_VaultedObjects");
                 String TYPE_PROJECT_VAULT = PropertyUtil.getSchemaProperty(context,"type_ProjectVault");

                 DomainObject doObj=new DomainObject(relatedObjectId);
                 doObj.open(context);

                 BusinessObject boWorkspace = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,doObj,RELATIONSHIP_VAULTED_OBJECT,TYPE_PROJECT_VAULT,true,false);

                  // If project Id is not null then the page is from workspace
                  if(boWorkspace!=null){
                 prjId=boWorkspace.getObjectId();
                 boWorkspace.open(context);
                 sName1 = boWorkspace.getName();


                 boWorkspace.close(context);
                  }


                 StringList objSelects = new StringList();
                 objSelects.addElement(DomainConstants.SELECT_ID);
                 objSelects.addElement(DomainConstants.SELECT_NAME);

                 StringList relSelects = new StringList();
                 short level = 1;


                 MapList scopeList = doObj.getRelatedObjects(context, "*", TYPE_PROJECT_VAULT, objSelects, relSelects, true, false, level, "", "");


                 if (scopeList.size()!=0){
                 %>
                 <tr>
                   <td>
                   	<input type="radio" name="selscope" value="ScopeName"  onclick = "JavaScript:setScope('ScopeName')" checked />
	                &nbsp;
                  <select name="workspaceFolder" onChange="javascript:setScopeId()">
                 <%
                 Map workspaceMap = null;
                 String scopeIds  = "";
                 String scopeNames = "";
                  Iterator scopeListItr = scopeList.iterator();

                 // get a list of workspace id's for the member
                  StringList scopeIdList = new StringList();
                  while(scopeListItr.hasNext())
                  {
                 workspaceMap = (Map)scopeListItr.next();
                 scopeIds = (String)workspaceMap.get(DomainObject.SELECT_ID);
                 scopeNames = (String)workspaceMap.get(DomainObject.SELECT_NAME);
                   %>
					<!-- //XSSOK -->
                   <option value="<%=  XSSUtil.encodeForHTMLAttribute(context, scopeIds)  %>" <%= scopeNames.equals(sName1)? "selected":""%> ><%=XSSUtil.encodeForHTML(context, scopeNames)%></option>
                   <%

                 }
           %>
         		</option>
	         </td>
           </tr>
          <input type="hidden" name="contentId" value="<xss:encodeForHTMLAttribute><%=relatedObjectId%></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name=workspaceFolderId value="<xss:encodeForHTMLAttribute><%=prjId%></xss:encodeForHTMLAttribute>" />
         <%
         }
         }//if type is doc, pac, rfq..
         else{
                 relatedObjectId = null;
         }
   }//if object id exists

  if((bTeam || bProgram) && (relatedObjectId == null || "null".equals(relatedObjectId) || "".equals(relatedObjectId) ) )
 {



   %>
   <!--
   <tr>
   		<td>
   			<input type="radio" name="selscope" value="ScopeName" onclick = "JavaScript:setScope('ScopeName')" />
			&nbsp;<input type="text" name="workspaceFolder" value="<xss:encodeForHTMLAttribute><%=strSelectScope%></xss:encodeForHTMLAttribute>" readonly="readonly" />
		    &nbsp;<input type="button" name="btnScope" value="..." onclick= "showTypeSelector()" />&nbsp;
				  <input type="hidden" name=workspaceFolderId value="" />
		</td>
   </tr>
   -->
 <%

  }

   %>

   </table>
   <%
  }
   %>

   </td>
  </tr>

  <tr>
 <td class="labelRequired" width="150"><emxUtil:i18n localize="i18nId">emxComponents.Route.RouteCompletionAction</emxUtil:i18n></td>
 <td class="inputField">
 <select name="routeCompletionAction" >
 <!-- Modified by Infosys for bug no. 297904, dated 05/20/2005 -->
 
 
  <%
  //begin -----------------------add by tangfan 2015.4.18
  // comments: if base state is same as current state, then set notify root owner as default and routeStart value as start

 boolean isCurrentState = false;
 try {
 
 	String rogerContentId = (String) session.getAttribute("contentObjectId");

	
 if (rogerContentId!=null && !rogerContentId.equals("")){
	   	matrix.util.StringList contentIds = com.matrixone.apps.domain.util.FrameworkUtil.split(rogerContentId, "~");
		

	if(contentIds.size()==1) {
	String firstContentId1 = (String)contentIds.get(0);
 	DomainObject routeRelatedObject = new DomainObject(firstContentId1);
	String relatedObjectState = routeRelatedObject.getInfo(context,"current");
	//System.out.println(" current state "  + relatedObjectState);
	if (relatedObjectState!=null && baseState!=null && baseState.equals(relatedObjectState))
		isCurrentState = true;	
        }		
 }
 
 	if (isCurrentState)
		routeCompletionActionValue = "";
 	//System.out.println(" isCurrentState = " + isCurrentState);
	
 }catch (Exception e){
 	e.printStackTrace();
 }
  isCurrentState = true; // "emxComponents.RouteStart.UponWizardCompletion"  is mode input_value "start" to "";
  
   //end -----------------------add by tangfan 2015.4.18
 %>
 
 
 
 <!-- //XSSOK -->
 <%= populateCombo1(context,sAttrRouteCompletionAction,bSupplier,bShowRouteAction,request , routeCompletionActionValue)%>
  </select>
 </td>
  </tr>

  <tr>
 <td class="label" width="150"><emxUtil:i18n localize="i18nId">emxComponents.Route.RouteStart</emxUtil:i18n></td>
 <td class="inputField">
         <table>
                 <tr>
                         <td><input type="radio" name="routeStart" id="routeStart" value="start" checked /><emxUtil:i18n localize="i18nId">emxComponents.RouteStart.UponWizardCompletion</emxUtil:i18n></td>
                 </tr>
                 <tr>
                         <td><input type="radio" name="routeStart" id="routeStart" value="" /><emxUtil:i18n localize="i18nId">emxComponents.RouteStart.Manually</emxUtil:i18n></td>
                 </tr>
         </table>

 </td>
 <%
 if(sGenericType.equalsIgnoreCase(DomainConstants.TYPE_INBOX_TASK))
   {
 %>
  <tr>
 <td class="labelRequired" width="150"><emxUtil:i18n localize="i18nId">emxComponents.OptionsDialog.SubrouteVisibleToParentRouteOwner</emxUtil:i18n></td>
 <td class="inputField"> <input type="checkbox" name="visblToParent" id="visblToParent" onclick="checkvisblToParent()" checked />&nbsp;
 <% } %>
 </td>

  </tr>
  <!-- Code for Auto stop -->
    <tr>
    <!--XSSOK-->
        <td class="label" width="150"><%=i18nNow.getI18nString("emxFramework.Attribute.Auto_Stop_On_Rejection", "emxFrameworkStringResource", sLanguage)%></td>
        <td class="inputField">
            <select name="routeAutoStop">
<%
            StringList slAutoStopOnRejectionRanges = FrameworkUtil.getRanges(context, sAttrAutoStopOnRejection);
            String strRange = "";
            String strTranslatedRange = "";
            // get default value for the attribute Auto Stop On Rejection
            //AttributeType attributeType = new AttributeType(sAttrAutoStopOnRejection);
           // String strDefaultValue = attributeType.getDefaultValue(context);

            // Internationalizing the attribute ranges
            for (Iterator itrRanges = slAutoStopOnRejectionRanges.iterator(); itrRanges.hasNext();) {
                strRange = (String)itrRanges.next();
                strTranslatedRange = i18nNow.getRangeI18NString(sAttrAutoStopOnRejection, strRange, sLanguage);
%><!-- //XSSOK -->
                <option value="<%=XSSUtil.encodeForHTMLAttribute(context, strRange)%>" <%=(routeAutoStop.equals(strRange))?"selected":""%>><%=XSSUtil.encodeForHTML(context, strTranslatedRange)%></option>
<%
            }
%>
            </select>
        </td>
    </tr>
   </table>
   </tr>
 <script language="javascript">
  function enableOrDisableScopeButton(btnVisibility){
	 if(document.createDialog.btnScope){
		 document.createDialog.btnScope.disabled = btnVisibility;
	 }
 }
   previousValue();
 </script>
 <tr>

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
  </tr>
  
  <%@include file = "emxRouteWizardDocumentSummary.inc" %>

  </table>
 <script language="javascript">
 function setScope(scope)
 {
   var bAll=false;
   var bOrganization=false;
   var bWorkspace=false;
   //if a route template is selected, then dont allow the user to change the scope
   var routeTemplateScope = document.createDialog.routeTemplateScope.value;
   if(routeTemplateScope != "" && routeTemplateScope != "null" && scope != routeTemplateScope){
	   if(routeTemplateScope == "All"){
		   $("input[name='selscope']")[0].checked = true;
		   enableOrDisableScopeButton(true);
	   }else if(routeTemplateScope == "Organization"){
		   $("input[name='selscope']")[1].checked = true;
		   enableOrDisableScopeButton(true);
	   }else{
		   $("input[name='selscope']")[2].checked = true;
		   enableOrDisableScopeButton(true);
	   }
	   alert("<%=XSSUtil.encodeForJavaScript(context,strCantChangeScope)%>");
	   return;
   }
   <%

     if(!isSupplierReview)
     {
   %>

   for(var i=0; i < document.createDialog.selscope.length; i++) {
         if(document.createDialog.selscope[i].value == "ScopeName") {
           bWorkspace=true;
         }
         if( (document.createDialog.selscope[i].type == "radio") && (document.createDialog.selscope[i].value == scope) ) {
           document.createDialog.selscope[i].checked=true;
           if(bWorkspace){
             document.createDialog.workspaceFolderId.value="";
           }
         }
      }// eof for
   <%

     if((bTeam || bProgram) && (relatedObjectId == null || "null".equals(relatedObjectId) || "".equals(relatedObjectId) ) )
     {
   %>
       document.createDialog.workspaceFolder.value="<%=XSSUtil.encodeForJavaScript(context, strSelectScope)%>";
   <%
     }
   }

   %>
   if(scope == "ScopeName"){
	   enableOrDisableScopeButton(false);
   }else{
	   enableOrDisableScopeButton(true);
   }
  var changeScope1 = "<%=XSSUtil.encodeForJavaScript(context, changeScope)%>";

  if( (changeScope1 == "All") && (scope !="All"))
  {
    deleteContent(scope, changeScope1);
     //BugNo:294573
      document.createDialog.workspaceFolderId.value="<%=XSSUtil.encodeForJavaScript(context, prjId)%>";
     //BugNo:294573
   }
   else if( (changeScope1 == "Organization") && (scope != "Organization" && scope !="All"))
   {
     deleteContent(scope, changeScope1);
     //BugNo:294573
      document.createDialog.workspaceFolderId.value="<%=XSSUtil.encodeForJavaScript(context, prjId)%>";
     //BugNo:294573
   }
   else if(scope == "ScopeName")
   {
    document.createDialog.workspaceFolder.value="<%=XSSUtil.encodeForJavaScript(context, sName)%>";
    document.createDialog.workspaceFolderId.value="<%=XSSUtil.encodeForJavaScript(context, prjId)%>";
   }

 }

 function updateRouteTemplateScope(formName, fieldName, idName){
	 //to update hidden routeTemplateScope if "Clear" link is used to clear the Template field
	 var operand = "document." + formName + "." + fieldName+".value = \"\";";
	 eval (operand);
	 if(idName != null){
	     var operand1 = "document." + formName + "." + idName+".value = \"\";";
	     eval (operand1);
	 }
	 if(document.createDialog.template.value == "" && document.createDialog.routeTemplateScope.value != ""){
		 if(document.createDialog.workspaceFolder.type != "hidden" && document.createDialog.routeTemplateScope.value != "All" && document.createDialog.routeTemplateScope.value != "Organization"){
			 document.createDialog.workspaceFolder.value="<%=XSSUtil.encodeForJavaScript(context,strSelectScope)%>";
			 document.createDialog.workspaceFolderId.value="";
		 }
		 document.createDialog.routeTemplateScope.value = "";
		 if(document.createDialog.workspaceFolder.type != "hidden"){
			 $("input[name='selscope']")[0].checked = true; 
		 }else{
			 $("input[name='selscope']")[2].checked = true;
		 }
		 enableOrDisableScopeButton(true);
	}
 }



 

 </script>
 
 </form>
    </body>
 </html>
 <%@include file = "../emxUICommonEndOfPageInclude.inc" %>

