<%--  emxCommonDocumentCreateDialog.jsp
    Copyright (c) 1992-2015 Dassault Systemes.
    All Rights Reserved  This program contains proprietary and trade secret
    information of MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

    Description : Document Create Wizard, Step 1

    static const char RCSID[] = "$Id: emxCommonDocumentCreateDialog.jsp.rca 1.41.2.1 Tue Dec 23 05:40:19 2008 ds-hkarthikeyan Experimental $";
--%>

<%
  // This is added because adding emxUICommonHeaderEndInclude.inc add
  request.setAttribute("warn", "false");
%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>  

<script language="javascript">
	function chooseOwner_onclick() {
		var objCommonAutonomySearch = new emxCommonAutonomySearch();
		
		objCommonAutonomySearch.txtType = "type_Person";
		objCommonAutonomySearch.selection = "single";
		objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitSelectedOwner"; 
					
		objCommonAutonomySearch.open();
	}
	
	function submitSelectedOwner (arrSelectedObjects) {
	    for (var i = 0; i < arrSelectedObjects.length; i++) {
	        var objSelection = arrSelectedObjects[i];
	        if (document.forms[0].person) {
	        	document.forms[0].person.value = objSelection.name;
	        }
	        break;
	    }
	}
	
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%

  Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");

  if(emxCommonDocumentCheckinData == null)
  {
    emxCommonDocumentCheckinData = new HashMap();
  }

  String objectId = emxGetParameter(request,"parentId");
  Enumeration enumParam = request.getParameterNames();

  // Loop through the request elements and
  // stuff into emxCommonDocumentCheckinData
  while (enumParam.hasMoreElements())
  {
    String name  = (String) enumParam.nextElement();
    String value = emxGetParameter(request,name);
    emxCommonDocumentCheckinData.put(name, value);
  }

  // retrive previously entered values, if any, which are stored in FormBean
  String documentName        = (String) emxCommonDocumentCheckinData.get("name");
  String documentAutoName    = (String) emxCommonDocumentCheckinData.get("AutoName");
  String documentType        = (String) emxCommonDocumentCheckinData.get("documentType");
 
  String documentPolicy      = (String) emxCommonDocumentCheckinData.get("policy");
  String documentRevision    = (String) emxCommonDocumentCheckinData.get("revision");
  String documentTitle       = (String) emxCommonDocumentCheckinData.get("title");
  String documentDescription = (String) emxCommonDocumentCheckinData.get("description");
  String documentOwner       = (String) emxCommonDocumentCheckinData.get("person");
  String documentAccessType  = (String) emxCommonDocumentCheckinData.get("AccessType");
  // Bug 301712 fix - previously entered folder name is not retained.
  String wsFolder            = (String) emxCommonDocumentCheckinData.get("txtWSFolder");
  String wsFolderId          = (String) emxCommonDocumentCheckinData.get("folderId");

  //  Reading request parameters and storing into variables
  String showName            = (String) emxCommonDocumentCheckinData.get("showName");
  String showDescription     = (String) emxCommonDocumentCheckinData.get("showDescription");
  String showTitle           = (String) emxCommonDocumentCheckinData.get("showTitle");
  String showOwner           = (String) emxCommonDocumentCheckinData.get("showOwner");
  String showType            = (String) emxCommonDocumentCheckinData.get("showType");
  // added for the Bug 344426
  String showTypeChooser     = (String) emxCommonDocumentCheckinData.get("typeChooser");
  String showPolicy          = (String) emxCommonDocumentCheckinData.get("showPolicy");
  String showAccessType      = (String) emxCommonDocumentCheckinData.get("showAccessType");
  String showRevision        = (String) emxCommonDocumentCheckinData.get("showRevision");
  String showFolder          = (String) emxCommonDocumentCheckinData.get("showFolder");
  String folderURL           = (String) emxCommonDocumentCheckinData.get("folderURL");
  String defaultType         = (String) emxCommonDocumentCheckinData.get("defaultType");
  String reloadPage          = (String) emxCommonDocumentCheckinData.get("reloadPage");
  String typeChanged         = (String) emxCommonDocumentCheckinData.get("typeChanged");
  String objectAction = (String) emxCommonDocumentCheckinData.get("objectAction");
  String disableFileFolder   = "false";

  String path = (String)emxCommonDocumentCheckinData.get("path");
  String vcDocumentType = (String)emxCommonDocumentCheckinData.get("vcDocumentType");
  String selector = (String)emxCommonDocumentCheckinData.get("selector");
  String server = (String)emxCommonDocumentCheckinData.get("server");
  String defaultFormat = (String)emxCommonDocumentCheckinData.get("format");
  String populateDefaults = (String)emxCommonDocumentCheckinData.get("populateDefaults");
  String showFormat = (String) emxCommonDocumentCheckinData.get("showFormat");
  String fromPage = (String)emxCommonDocumentCheckinData.get("fromPage");

  // Bug 303724 fix, list of coma delimited symbolic type names only included in type chooser
  String includeTypes        = (String) emxCommonDocumentCheckinData.get("includeTypes");

  // Bug 303724 fix, list of coma delimited symbolic policy names to be excluded being displayed in policy list
  String excludePolicies     = (String) emxCommonDocumentCheckinData.get("excludePolicies");
  // added for the Bug 344426
  //  Validating the request parameter values and setting to defaults
  //  if showTypeChooser is not passed from the command setting the value to true
  if (showTypeChooser == null || "".equals(showTypeChooser) || "null".equals(showTypeChooser) || "true".equalsIgnoreCase(showTypeChooser))
  {
      showTypeChooser = "true";
  }
  //  Validating the request parameter values and setting to defaults
  //  if not defined in request
  //  Description, Title are set true if null
  if (showName == null || "".equals(showName) || "null".equals(showName) || "true".equalsIgnoreCase(showName))
  {
      showName = "required";
  }

  if (showDescription == null || showDescription.equals("") )
  {
      showDescription = "true";
  }

  if (showTitle == null || showTitle.equals("") )
  {
      showTitle = "true";
  }

  // all other parameters are set to false if null
  if (showOwner == null || showOwner.equals("") )
  {
      showOwner = "false";
  }

  if (showType == null || showType.equals("") )
  {
      showType = "false";
  }

  if (showPolicy == null || showPolicy.equals("") )
  {
      showPolicy = "required";
  }

  if( objectAction.equals(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER))
  {
      showPolicy = "required";
      disableFileFolder = "true";
  }

  if (showAccessType == null || showAccessType.equals("") )
  {
      showAccessType = "false";
  }

  if (showRevision == null || showRevision.equals("") )
  {
      showRevision = "false";
  }

  if (showFolder == null || showFolder.equals("") )
  {
        showFolder = "false";
  }

  if( documentName == null || documentName.equals("null"))
  {
      documentName = "";
  }

  if( documentAutoName == null || documentAutoName.equals("null"))
  {
      documentAutoName = "";
  }

  if(reloadPage != null && "true".equals(reloadPage))
  {
      documentType = (String) emxCommonDocumentCheckinData.get("realType");
      BusinessType docType = new BusinessType(documentType, context.getVault());
      StringList parents = docType.getParents(context);
      if ((parents.contains(DomainObject.TYPE_IC_DOCUMENT)) || (documentType.equals(DomainObject.TYPE_IC_DOCUMENT)))
        vcDocumentType = "File";
      else if ((parents.contains(DomainObject.TYPE_IC_FOLDER)) || (documentType.equals(DomainObject.TYPE_IC_FOLDER)))
        vcDocumentType = "Folder";
  }

  // Bug 301712 fix - previously entered folder name is not retained.
  if (wsFolder == null || "".equals(wsFolder) || "null".equals(wsFolder))
  {
      wsFolder="";
  }

  // Bug 301712 fix - previously entered folder name is not retained.
  if (wsFolderId == null || "".equals(wsFolderId) || "null".equals(wsFolderId))
  {
      wsFolderId="";
  }


  // Bug 303724 fix, prepare string list of excluded policies
  StringList listExcludePolicies = new StringList();
  if( excludePolicies != null && !"null".equals(excludePolicies) && !"".equals(excludePolicies.trim()))
  {
      StringList listSymExcludePolicies = FrameworkUtil.split(excludePolicies, ",");
      Iterator itr = listSymExcludePolicies.iterator();
      while(itr.hasNext())
      {
        // get the aboslute policy name
        listExcludePolicies.add(PropertyUtil.getSchemaProperty(context, (String)itr.next()));
      }
  }

  boolean bTypeChanged = false;
  if(typeChanged != null && "true".equals(typeChanged))
  {
    bTypeChanged = true;
    //defaultType = FrameworkUtil.getAliasForAdmin(context, "type", documentType, true);
    //Above statement is commented to fix 371838. 
    //When type is changed through Type chooser, should not change 'defaultType' value.
  }

  // default to defaultType, first time
  if( documentType == null || documentType.equals("null"))
  {
   /* if( defaultType != null)
    {
      try
      {
        documentType = PropertyUtil.getSchemaProperty(context, defaultType);
      }
      catch (Exception exp)
      {
        // if there is any error default to "Document" type
        documentType = PropertyUtil.getSchemaProperty(context, "type_Document");
      }
    }
    else
    {
        documentType = PropertyUtil.getSchemaProperty(context, "type_Document");
    }
	*/
	  //add by wangyitao show default doc type;
	  DomainObject strObject = new DomainObject(objectId);
	  String strType = strObject.getType(context);
	  if(strType.equals("Workspace Vault"))
	  {
		   documentType ="SEM Project Document";

	  }else if(strObject.isKindOf(context, "Task Management")){
		  
		   documentType ="SEM Project Document";
	  }else if(strType.equals("Meeting")){
		  
			documentType ="SEM Meeting Document";
	  }else{
		  documentType ="Document";
	  }
  }
  String actualType  = PropertyUtil.getSchemaProperty(context, documentType);
  documentType       = !com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(actualType)?actualType:documentType;
  BusinessType bType = new BusinessType(documentType, context.getVault());
  boolean isAbstract = bType.isAbstract(context);

  // type chooser needs Symbolic name to pass,
  // if no default type passed then the type chooser displayes the subtypes of type DOCUMENTS
  String symbolicDocumentType = "";
  
 
  if( defaultType != null)
  {
    symbolicDocumentType = FrameworkUtil.getAliasForAdmin(context, "type", PropertyUtil.getSchemaProperty(context,defaultType), true);
  }
  else
  {
    symbolicDocumentType = FrameworkUtil.getAliasForAdmin(context, "type", PropertyUtil.getSchemaProperty(context, "type_DOCUMENTS"), true);
  }

  if( documentPolicy == null || "null".equals(documentPolicy) || "".equals(documentPolicy) || bTypeChanged)
  {
      // If no policy passed then read the default policy (symbolic name) defined for the current type
      // in properties
      try
      {
        documentPolicy = EnoviaResourceBundle.getProperty(context,"emxComponents.DefaultPolicy." + symbolicDocumentType);

        if( documentPolicy != null && !"".equals(documentPolicy.trim()))
        {
          documentPolicy = PropertyUtil.getSchemaProperty(context, documentPolicy);
        }
        else
        {
          documentPolicy = null;
        }
      }
      catch (Exception e)
      {
        documentPolicy = null;
      }
  }

  // Bug 303724 fix
  // if Inclusion list is not passed then include DOCUMENTS type by default
  if( includeTypes == null || includeTypes.equals("null") || "".equals(includeTypes.trim()))
  {
      includeTypes = symbolicDocumentType;
  }

  String sAllowChangePolicy   = EnoviaResourceBundle.getProperty(context,"emxComponents.AllowChangePolicy");
  boolean bAllowChangePolicy  = true;
  if(sAllowChangePolicy != null && "false".equalsIgnoreCase(sAllowChangePolicy))
  {
    bAllowChangePolicy =  false;
  }

  MapList documentPolicies         = mxType.getPolicies( context, documentType, false);
  Map defaultDocumentPolicyMap     = null;
  Map documentPolicyMap            = new HashMap();
  String defaultDocumentPolicyName = null;
  StringList documentPolicyNames   = new StringList();
  Iterator documentPolicyItr       = null;
  String policyName = null;

  if ( documentPolicies != null && !documentPolicies.isEmpty())
  {
      documentPolicyItr = documentPolicies.iterator();
      while( documentPolicyItr.hasNext())
      {
        documentPolicyMap = (Map)documentPolicyItr.next();
        policyName        = (String)documentPolicyMap.get("name");

        if(!listExcludePolicies.contains(policyName))
           documentPolicyNames.add(policyName);
        else
           documentPolicyItr.remove();

        if(documentPolicy == null)
        {
          defaultDocumentPolicyMap = (Map) documentPolicies.get(0);
        }
        else if (policyName.equals(documentPolicy))
        {
          defaultDocumentPolicyMap = documentPolicyMap;
        }
      }

      if(defaultDocumentPolicyMap == null)
      {
        defaultDocumentPolicyMap = (Map) documentPolicies.get(0);
      }

      defaultDocumentPolicyName = (String)defaultDocumentPolicyMap.get("name");

      documentRevision = (String)defaultDocumentPolicyMap.get("revision");
  }
  if( documentPolicy != null && !"".equals(documentPolicy))
  {
      defaultDocumentPolicyName = documentPolicy;
  }

  String states = MqlUtil.mqlCommand(context, "print policy $1 select $2 dump $3", defaultDocumentPolicyName,"state","|");
  StringList stateList = FrameworkUtil.split(states, "|");

  String txtLable = "label";
%>
<script language="javascript">

  // function to close the window and refresh the parent window.
  function closeWindow()
  {
    window.location.href = "emxCommonDocumentCancelCreateProcess.jsp";
  }

  // function to truncate the blank values.
  function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }

<%
  if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ON_DEMAND))
    {
%>
  function onFileFolderSelect(folderObject){
<%
   if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ON_DEMAND)){
%>
    if(folderObject.value == "Folder"){
       document.frmMain.vcDocumentType.value = "Folder";
    }
    else if(folderObject.value == "Module")
    {
      
        document.frmMain.vcDocumentType.value = "Module";
        
    }
    else {
       document.frmMain.vcDocumentType.value = "File";
    }
<% } else
    {
%>
    if(folderObject.value == "Folder"){
       document.frmMain.format.disabled= true;
       document.frmMain.vcDocumentType.value = "Folder";
       document.frmMain.selector.value = "Trunk:Latest";
    }
    else if(folderObject.value == "Module") 
    {
    	document.frmMain.format.disabled = true;
    	document.frmMain.vcDocumentType.value = "Module";
    	 //DSFA added for selector change Nov 13 2008
       document.frmMain.selector.value = "DSFA:Latest";
    }
    else { 
    	document.frmMain.vcDocumentType.value = "File"; 
    	document.frmMain.format.disabled= false;   
    	 //DSFA added for selector change Nov 13 2008
       document.frmMain.selector.value = "Trunk:Latest"; 
    	}
<%} %>
  }
<%
    }
 %>

  function submitForm()
  {
<%
     if ( isAbstract )
     {
%>
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.InValidType</emxUtil:i18nScript>");
        return;
<%
     }
	
%>
	
	if(document.getElementById("forlderName").value == "")
	{
		alert("\u6587\u4EF6\u5939\u4E0D\u80FD\u4E3A\u7A7A\u3002");
		return; 
	} 
<%
	if("SEM Project Document".equals(documentType) || "SEM Meeting Document".equals(documentType))
	{
%>	
	if(document.getElementById("unit").value == "")
	{
		alert("\u8BF7\u9009\u62E9\u7F16\u5236\u90E8\u95E8\u3002");
		return; 
	} 
	
	if(document.getElementById("subType").value == "")
	{
		alert("\u8BF7\u9009\u62E9\u6587\u6863\u5206\u7C7B\u3002");
		return; 
	} 
	
	if(document.getElementById("secret").value == "")
	{
		alert("\u8BF7\u9009\u62E9\u6587\u6863\u5BC6\u7EA7\u3002");
		return; 
	} 
	
  
<%
	}
    if ( showRevision.equalsIgnoreCase("required") )
    {
%>
		alert("showRevision");
      if ( document.frmMain.revision.value == "" ) {
        document.frmMain.revision.focus();
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.RevisionError</emxUtil:i18nScript>");
        return;
      }
<%
    }

    if ( showDescription.equalsIgnoreCase("required") )
    {
%>
      if ( document.frmMain.description.value == "" )
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.FillDescription</emxUtil:i18nScript>");
        document.frmMain.description.focus();
        return;
      }
<%
    }
    if ( showOwner.equalsIgnoreCase("required") )
    {
%>

      if (trim(document.frmMain.person.value) == "")
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.OwnerError</emxUtil:i18nScript>");
        document.frmMain.person.focus();
        return;
      }
<%
    }



    if ( showDescription.equalsIgnoreCase("true") || showDescription.equalsIgnoreCase("required") )
    {
%>
      var descriptionBadCharName = checkForBadChars(document.frmMain.description);      
      if (descriptionBadCharName.length != 0)
      {
      	var descriptionAllBadCharName = getAllBadChars(document.frmMain.description);
      	
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+descriptionBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInvalidInput</emxUtil:i18nScript>"+descriptionAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
        document.frmMain.description.focus();
        return;
      }
<%
    }



    if ( showFolder.equalsIgnoreCase("required") )
    {
%>
      if ( document.frmMain.txtWSFolder.value == "" ) {
        document.frmMain.txtWSFolder.focus();
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Checkin.SelectFolder</emxUtil:i18nScript>");
        return;
      }
<%
    }
%>
    j = 0;
    for ( var i = 0; i < document.frmMain.elements.length; i++ ) {
        j = document.frmMain.elements[i].name.length;
        k = j - 6;
        if (document.frmMain.elements[i].type == "hidden" && document.frmMain.elements[i].name.substring(k,j) == "Number"  ){

            j = i;
            j--;
            if ( !isNumeric(document.frmMain.elements[j].value) )
            {
                alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.PleaseTypeNumbers</emxUtil:i18nScript>" + document.frmMain.elements[j].name);
                document.frmMain.elements[j].focus();
                return;
            }
        }
        // Trim leading and trailing white spaces from title field - 353717
		else if ( document.frmMain.elements[i].type == "text" && document.frmMain.elements[i].name == "title" )
		{
		document.frmMain.elements[i].value = trim(document.frmMain.elements[i].value);
		}
<%
  if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ZIP_TAR_GZ) )
    {
%>
        if ((document.frmMain.elements[i].type == "radio") && (document.frmMain.elements[i].name=="vcDocumentTmp") && (document.frmMain.elements[i].checked)){
          if(document.frmMain.elements[i].value == "Folder"){
            var path = document.frmMain.path.value;
            path = path.substring(path.length-1, path.length);
            if (path == ";")
            {
               alert("<emxUtil:i18n localize = "i18nId">emxComponents.CommonDocument.FolderPathError</emxUtil:i18n>");
               return;
            }
          }
<%
         if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) || objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER)) {
%>
            if(document.frmMain.elements[i].value == "File") {
                var path = document.frmMain.path.value;
                path = path.substring(path.length-1, path.length);
                if (path == "/")
                {
                   alert("<emxUtil:i18n localize = "i18nId">emxComponents.CommonDocument.FilePathError</emxUtil:i18n>");
                   return;
                }
            }
            if(document.frmMain.elements[i].value == "Module")
            {
            	var path = document.frmMain.path.value;
            	path = "ModuleName";
            	if(path == "")
            	{
            		alert("<emxUtil:i18n localize = "i18nId">emxComponents.CommonDocument.FilePathError</emxUtil:i18n>");
            	}
            }
<%
        }
%>
        }
<%
    }
%>
<%
    if (objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER))
    {
%>
       var path = document.frmMain.path.value;
       var server = document.frmMain.server.value;
       if(path.length <= 0 || path==" ")
       {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.PathEmpty</emxUtil:i18nScript>");
          return;
       }
      
       
       	if(path=="Modules/" || path=="Modules")
       	{
        	  alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.ModulePathInvalid</emxUtil:i18nScript>");
         	  return;
       	}
       

<%
    }
    if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
          objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) ||
          objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
          objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
          objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ZIP_TAR_GZ) )
    {
        String emxFilePathBadChars = EnoviaResourceBundle.getProperty(context,"emxComponents.VCFile.PathBadChars");
        String emxFolderPathBadChars = EnoviaResourceBundle.getProperty(context,"emxComponents.VCFolder.PathBadChars");
        String emxSelectorBadChars = EnoviaResourceBundle.getProperty(context,"emxComponents.VCFileFolder.SelectorBadChars");
%>
       if(document.frmMain.elements[i].name== "path"){
         var FILE_CHARS = "<%= emxFilePathBadChars.trim() %>";
         var FOLDER_CHARS = "<%= emxFolderPathBadChars.trim() %>";
         var STR_PATH_BAD_CHARS = "";
         if(document.frmMain.vcDocumentTmp[1].checked){
           STR_PATH_BAD_CHARS = FOLDER_CHARS;
         }
         else{
           STR_PATH_BAD_CHARS = FILE_CHARS;
         }
         var ARR_PATH_BAD_CHARS = "";
         if (STR_PATH_BAD_CHARS != "")
         {
          ARR_PATH_BAD_CHARS = STR_PATH_BAD_CHARS.split(" ");
         }
         var strResult = checkFieldForChars(document.frmMain.path,ARR_PATH_BAD_CHARS,false);
         if (strResult.length > 0) {
           //XSSOK	 
           var msg = "<%= i18nNow.getI18nString("emxComponents.Alert.InvalidChars","emxComponentsStringResource",request.getHeader("Accept-Language")) %>";
           msg += STR_PATH_BAD_CHARS;
         //XSSOK
           msg += "<%= i18nNow.getI18nString("emxComponents.Alert.RemoveInvalidChars", "emxComponentsStringResource",request.getHeader("Accept-Language")) %> ";
           msg += document.frmMain.path.name;
           alert(msg);
           document.frmMain.path.focus();
           return;
         }
       }
       if(document.frmMain.elements[i].name== "selector"){
         var selector = document.frmMain.selector.value;
         if(selector.length <= 0)
         {
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.SelectorEmpty</emxUtil:i18nScript>");
            return;
         }
         var STR_SELECTOR_BAD_CHARS = "<%= emxSelectorBadChars.trim() %>";
         var ARR_SELECTOR_BAD_CHARS = "";
         if (STR_SELECTOR_BAD_CHARS != "")
         {
           ARR_SELECTOR_BAD_CHARS = STR_SELECTOR_BAD_CHARS.split(" ");
         }
         var strSelectorResult = checkFieldForChars(document.frmMain.selector,ARR_SELECTOR_BAD_CHARS,false);
         if (strSelectorResult.length > 0) {
           alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.InvalidChars</emxUtil:i18nScript>\n"
                 + STR_SELECTOR_BAD_CHARS + "\n<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript>\n"
                 +document.frmMain.selector.name);
          document.frmMain.selector.focus();
          return;
        }
      }
<%
    }
%>
    }

    // Make sure user doesnt double clicks on create document
    if (jsDblClick())
    {
      startProgressBar(false);
      document.frmMain.submit();
      return;
    }
  }

<%
     String excludeTypes = EnoviaResourceBundle.getProperty(context, "emxComponents.CreateDocument.ExcludeTypeList");
%>
  function showTypeSelector()
  {
    document.frmMain.typeChanged.value="true";
    var strURL="../common/emxTypeChooser.jsp?fieldNameDisplay=type&fieldNameActual=realType&formName=frmMain&ShowIcons=true&InclusionList=<%=XSSUtil.encodeForURL(context, includeTypes)%>&ExclusionList=<%=excludeTypes%>&ObserveHidden=true&SelectType=singleselect&ReloadOpener=true";
    var win = showModalDialog(strURL, 450, 500, true);
  }
  
  function showWorkForderSelector(strURL)
  {
    //document.frmMain.typeChanged.value="true";
    var win = showModalDialog(strURL, 450, 500, true);
  }

  // this function is called by type chooser, everytime a type is selected
  // this reloads the page, and populates the policy chooser correctly
  function reload() {
      document.frmMain.target="";
      document.frmMain.action="../components/emxCommonDocumentCreateDialog.jsp?reloadPage=true&contentPageIsDialog=true";
      document.frmMain.submit();
  }
  
  function reloadSubType() {
	  var selectObjValue = document.getElementById("unit").value;
	  var strUrl = "../common/SEMCreateDocument.jsp?mode=reloadSubType&unitValue="+selectObjValue;
	strUrl = encodeURI(strUrl);
	var xmlHttp = getAjaxObj();
	var subType=document.getElementById("subType");
	var secret=document.getElementById("secret");
	var policy=document.getElementById("policy");
	var policyDisplay=document.getElementById("policyDisplay");

	xmlHttp.onreadystatechange=function(){
		if(xmlHttp.readyState == 4){
			if(xmlHttp.status==200 || xmlHttp.status==304){
				var content = xmlHttp.responseText;
				content = content.substring(content.lastIndexOf("script>"),content.length);
				content = content.substring(9);
				content = content.trim();				
				var str = content.split(",");
				
				subType.options.length=0;
				secret.options.length=0;  
				var splitStr = str[0];
				var strPolicy= splitStr.split("_")[2];
				policy.value=strPolicy.split(";")[0];
				policyDisplay.value=strPolicy.split(";")[1];
				var strSecret="";
				for(var i = 0; i < str.length; i++)
				{
					var splitValue = str[i];
					var strSubType= splitValue.split("_")[0];
					strSecret= str[0].split("_")[1];
					
					var op=document.createElement("option");      
					op.setAttribute("value",strSubType);          
					op.appendChild(document.createTextNode(strSubType)); 
					subType.appendChild(op); 
					
																					
				}
				if(strSecret!="HID")
				{
					var op1=document.createElement("option");      
					op1.setAttribute("value",strSecret);          
					op1.appendChild(document.createTextNode(strSecret)); 
					secret.appendChild(op1);  		
				}
			}
		} 
	};
	xmlHttp.open("Get",strUrl,true);
	xmlHttp.send(null);
  }
  
  
   function reloadSubSecret() 
   {
		var selectObjValue = document.getElementById("subType").value;
	    var strUrl = "../common/SEMCreateDocument.jsp?mode=reloadSubSecret&subType="+selectObjValue;
		strUrl = encodeURI(strUrl);
		var xmlHttp = getAjaxObj();
		var policy=document.getElementById("policy");
		var policyDisplay=document.getElementById("policyDisplay");
	
		xmlHttp.onreadystatechange=function()
		{
			if(xmlHttp.readyState == 4)
			{
				if(xmlHttp.status==200 || xmlHttp.status==304)
				{
					var content = xmlHttp.responseText;
					content = content.substring(content.lastIndexOf("script>"),content.length);
					content = content.substring(9);
					content = content.trim();				
					var str = content.split(",");
					

					secret.options.length=0;  
					var splitStr = str[0];
					var strPolicy= splitStr.split("_")[1];
					policy.value=strPolicy.split(";")[0];
					policyDisplay.value=strPolicy.split(";")[1];

					for(var i = 0; i < str.length; i++)
					{
						var splitValue = str[i];
						
						var strSecret= splitValue.split("_")[0];

						if(strSecret!="HID")
						{
							var op1=document.createElement("option");      
							op1.setAttribute("value",strSecret);          
							op1.appendChild(document.createTextNode(strSecret)); 
							secret.appendChild(op1);  		
						}																
					}
				}
			} 
		};
		xmlHttp.open("Get",strUrl,true);
		xmlHttp.send(null);		
   }
  
    function reloadPolicy() 
	{
	    var selectObjValue = document.getElementById("secret").value;
	    var strUrl = "../common/SEMCreateDocument.jsp?mode=reloadPolicy&secret="+selectObjValue;
		strUrl = encodeURI(strUrl);
		var xmlHttp = getAjaxObj();
		var policy=document.getElementById("policy");
		var policyDisplay=document.getElementById("policyDisplay");
	
		xmlHttp.onreadystatechange=function()
		{
			if(xmlHttp.readyState == 4)
			{
				if(xmlHttp.status==200 || xmlHttp.status==304)
				{
					var content = xmlHttp.responseText;
					content = content.substring(content.lastIndexOf("script>"),content.length);
					content = content.substring(9);
					content = content.trim();
					policy.value=content.split(";")[0];
					policyDisplay.value=content.split(";")[1];
				}
			} 
		};
		xmlHttp.open("Get",strUrl,true);
		xmlHttp.send(null);
	}
  
  
  function getAjaxObj()
  {
		var xmlHttp;
		if(window.XMLHttpRequest){
			xmlHttp=new XMLHttpRequest();
		}else{
			xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
		return xmlHttp;
}

  //function  to move the focus from AutoName to Name, when AutoName checkBox is Unchecked.
  function txtNameFocus()
  {
    if(!document.frmMain.AutoName.checked )
    {
      document.frmMain.AutoName.value = "";
      document.frmMain.name.focus();
    }
    else
    {
      autoNameValue();
    }
    return;
  }

  function autoNameValue()
  {
    if(document.frmMain.AutoName.checked )
    {
      document.frmMain.name.value = "";
      document.frmMain.AutoName.value = "checked";
      document.frmMain.AutoName.focus();
    }
    return;
  }

  function  folderlist() {
    emxShowModalDialog("../common/emxIndentedTable.jsp?expandProgram=emxWorkspace:getWorkspaceVaults&table=TMCSelectFolder&program=emxWorkspace:getDisabledWorkspaces&displayView=details&header=emxFramework.IconMail.Common.SelectOneFolder&submitURL=../components/emxCommonSelectWorkspaceFolderProcess.jsp&cancelLabel=emxFramework.Button.Cancel&submitLabel=emxFramework.FormComponent.Done",575,575);
  }

  </script>
<%
  String actionURL = (String) emxCommonDocumentCheckinData.get("actionURL");
  if (actionURL == null )
  {
      actionURL = "emxCommonDocumentCheckinDialogFS.jsp";
  }
  String requiredText = ComponentsUtil.i18nStringNow("emxComponents.Commom.RequiredText",request.getHeader("Accept-Language"));

%>
<form name="frmMain" method="post" action="<%= XSSUtil.encodeForHTML(context, actionURL) %>" target="_parent" onsubmit="submitForm(); return false">
  <input type="hidden" name="folderId" value="<xss:encodeForHTMLAttribute><%=wsFolderId%></xss:encodeForHTMLAttribute>"/>

<table>
  <tr>     
    <!-- //XSSOK -->  
    <td class="requiredNotice"><%=requiredText%></td>
  </tr>
</table>
   <table>
<%
  // Start of display of Name depending on the parametes passed in
  // If showName parameter came as required it will display with labelrequired
  // If showName parameter came as null or true, description field will be displayed as optional
  // If showName parameter came as false, description field will NOT be displayed
 /* txtLable = "label";
  if ( showName.equalsIgnoreCase("true") || showName.equalsIgnoreCase("required") )
  {
     if ( showName.equalsIgnoreCase("required") )
     {
         txtLable = "labelRequired";
     }*/
%>
 <tr>
  
  <!--  <td class="<%=txtLable%>" >
      <emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n>
    </td>

    <td class="inputField" >
<%
   //  if("".equals(documentName))
  //   {
%>
        <input type="text" name="name" size="20" onfocus="autoNameValue()" onkeypress="autoNameValue()" onclick="autoNameValue()" onselect="autoNameValue()" onkeydown="autoNameValue()" onchange="autoNameValue()" value="<xss:encodeForHTMLAttribute><%=documentName%></xss:encodeForHTMLAttribute>"/>
        <input type="checkbox" name="AutoName" value="<xss:encodeForHTMLAttribute><%=documentAutoName%></xss:encodeForHTMLAttribute>" onClick="txtNameFocus()" checked />&nbsp;
        <emxUtil:i18n localize="i18nId">emxComponents.Common.AutoName</emxUtil:i18n>
<%
   //   } else {
%>
        <input type="text" name="name" size="20" value="<xss:encodeForHTMLAttribute><%=documentName%></xss:encodeForHTMLAttribute>"   onFocus="autoNameValue()" onKeyPress="autoNameValue()" onClick="autoNameValue()" onSelect="autoNameValue()" onKeyDown="autoNameValue()" onChange="autoNameValue()"/>
        <input type="checkbox" name="AutoName" value="<xss:encodeForHTMLAttribute><%=documentAutoName%></xss:encodeForHTMLAttribute>" onClick="txtNameFocus()"/>&nbsp;
        <emxUtil:i18n localize="i18nId">emxComponents.Common.AutoName</emxUtil:i18n>
<%
    //  }
%>
      </td>
    </tr>	-->
<%
  //}
  //added for the Bug 344426
  txtLable = "label";
  if (!showTypeChooser.equalsIgnoreCase("false") )
  {
    txtLable = "labelRequired";
  }
%>
    <tr><!--//XSSOK-->
      <td class = "<%=txtLable%>" >
        <emxUtil:i18n localize = "i18nId">emxComponents.Common.Type</emxUtil:i18n>
      </td>
      <td class = "inputField" >
<%
        // added for the Bug 344426
        if( "false".equalsIgnoreCase(showTypeChooser))
        {
			String strDefaultDocType = documentType == null ? i18nNow.getTypeI18NString("Document",sLanguage) : i18nNow.getTypeI18NString(documentType,sLanguage);
%>
 		<!-- //XSSOK -->
        <%=  strDefaultDocType %>
		<!-- //XSSOK -->
		<input type="hidden" name="type" size="20" readonly value="<%=strDefaultDocType%>"/>
<%
        }
        else
        {
%>
          <!-- //XSSOK -->
          <input type="text" name="type" value="<%= documentType == null ? i18nNow.getTypeI18NString("Document",sLanguage):i18nNow.getTypeI18NString(documentType,sLanguage)%>" size="20" readonly />
          <input type="button" name="FieldButton" value=".." size="5" onClick="showTypeSelector()"/>
<%
        }
%>
          <!-- //XSSOK -->
          <input type="hidden" name="realType" value="<%= documentType == null ? "Document":documentType%>" />
      </td>

    </tr>
<%
    Iterator policyItr = documentPolicyNames.iterator();

    if(!"false".equalsIgnoreCase(showPolicy) && bAllowChangePolicy)
    {
		if("SEM Project Document".equals(documentType) || "SEM Meeting Document".equals(documentType))
		{
%>
    <tr>
      <td class="labelRequired" >
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Policy</emxUtil:i18n>
      </td>
      <td class="inputField" >
<%
		String i18nPolicyName1  = i18nNow.getMXI18NString("SEM Document","",sLanguage,"Policy");

%>
       		<input type="hidden" name="policy" id="policy" value="SEM Document"/>
			<input type="text" name="policyDisplay" id="policyDisplay" size="20" disabled="true" value="<%=i18nPolicyName1%>"/>
      </td>
    </tr>
<%				
		}else{
%>
    <tr>
      <td class="labelRequired" >
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Policy</emxUtil:i18n>
      </td>
      <td class="inputField" >
          <select name = "policy" id="policy"  onChange=reload()>
<%
          String docPolicy = "";
          String i18nPolicy = "";
          while( policyItr.hasNext())
          {
            docPolicy = (String)policyItr.next();

            // Bug 303724 fix, do not list the excluded policy
            if(!listExcludePolicies.contains(docPolicy))
            {
              i18nPolicy  = i18nNow.getMXI18NString(docPolicy,"",sLanguage,"Policy");
%>
              <!-- //XSSOK -->
              <option value="<%=docPolicy%>" <%=docPolicy.equals(defaultDocumentPolicyName)?"selected":""%> ><%=i18nPolicy%></option>
<%
            }
         }
%>
        </select>
      </td>
    </tr>
<%
    }
	}
    else if( objectAction.equals(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER))
    {
%>
    <tr>
      <td class="labelRequired" >
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Policy</emxUtil:i18n>
      </td>
      <!-- //XSSOK -->
      <td class="inputField" ><%=defaultDocumentPolicyName%></td>
    </tr>
<%
    }
    else
    {
      // pass the default Policy as a hidden variable
%>  
    <!-- //XSSOK -->
      <input type="hidden" name="policy" id="policy" value="<%=defaultDocumentPolicyName%>"/>
<%
    }

    if( objectAction.equals(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER))
    {
%>
    <tr>
      <td class="labelRequired" >
        <emxUtil:i18n localize="i18nId">emxComponents.Common.CompletionState</emxUtil:i18n>
      </td>
      <td class="inputField" >
          <select name = "state" >
<%
          Iterator stateItr = stateList.iterator();
          String state = "";
          String i18nState= "";
          while( stateItr.hasNext())
          {
            state = (String)stateItr.next();
            i18nState = i18nNow.getMXI18NString(state, defaultDocumentPolicyName, sLanguage, "State");
%>
			<!-- //XSSOK -->
            <option value="<%=state%>" ><%=i18nState%></option>
<%
         }
%>
        </select>
      </td>
    </tr>
<%
    }

    // Start of display of Revision field depending on the parametes passed in
    // If showRevision parameter came as required it will display with labelrequired
    // If showRevision parameter came as true it will display as optional field
    // If showRevision parameter came as null or false, Revision field will not be displayed
    txtLable = "label";
    if ( showRevision.equalsIgnoreCase("true") || showRevision.equalsIgnoreCase("required") )
    {
        if ( showRevision.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
    <tr><!--//XSSOK-->
      <td class="<%=txtLable%>" >
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Revision</emxUtil:i18n>
      </td>

      <td class="inputField" >
      <!-- //XSSOK -->
        <input type="text" readonly name="revision" size="20" value="<%=documentRevision==null?"0":XSSUtil.encodeForHTMLAttribute(context, documentRevision)%>" />
      </td>
    </tr>
<%
    }

    // Start of display of Title depending on the parametes passed in
    // If showTitle parameter came as required it will display with labelrequired
    // If showTitle parameter came as null or true, description field will be displayed as optional
    // If showTitle parameter came as false, description field will NOT be displayed
    txtLable = "label";
    if ( showTitle.equalsIgnoreCase("true") || showTitle.equalsIgnoreCase("required") )
    {

        if ( showTitle.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
   <!-- <tr>//XSSOK
      <td class="<%=txtLable%>" >
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Title</emxUtil:i18n>
      </td>

      <td class="inputField" >
        <input type="text" name="title" size="20" value="<xss:encodeForHTMLAttribute><%=documentTitle==null?"":documentTitle%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>
-->
<%
    }

    // Start of display of Description depending on the parametes passed in
    // If showDescription parameter came as required it will display with labelrequired
    // If showDescription parameter came as null or true, description field will be displayed as optional
    // If showDescription parameter came as false, description field will NOT be displayed
    txtLable = "label";
    if ( showDescription.equalsIgnoreCase("true") || showDescription.equalsIgnoreCase("required") )
    {
        if ( showDescription.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
    <tr>
	<!-- //XSSOK -->
      <td class="<%=txtLable%>"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n> &nbsp;</td>
      <td class="inputField">
        <textarea name="description" rows="5" cols="36" wrap><xss:encodeForHTML><%=documentDescription==null?"":documentDescription%></xss:encodeForHTML></textarea>
      </td>
    </tr>
<%
    }
	
	String projectLabel = "\u9879\u76EE";
	String forlderLabel = "\u6587\u4EF6\u5939";
	String unit = "\u7F16\u5236\u90E8\u95E8";
	String projectName="";
	String projectId="";
	String forderName="";
	String forderId="";
	StringList busList = new StringList("id");
	if( objectId == null || objectId.equals("null"))
	{
		projectId = (String) emxCommonDocumentCheckinData.get("projectId");
		projectName = (String) emxCommonDocumentCheckinData.get("projectName");
		forderId = (String) emxCommonDocumentCheckinData.get("forderId");
		forderName = (String) emxCommonDocumentCheckinData.get("forlderName");
	}else{
		DomainObject strObject = new DomainObject(objectId);
		String strType = strObject.getType(context);
		if(strType.equals("Workspace Vault"))
		{
			
			MapList mapList = strObject.getRelatedObjects(context,"Sub Vaults,Data Vaults","*",busList,null,true,false,(short)0,null,null);
			for(int i = 0 ; i < mapList.size(); i++)
			{
				Map map = (Map)mapList.get(i);
				String strProjectId = (String)map.get("id");	
				DomainObject strObj = new DomainObject(strProjectId);
				String strProjectType = strObj.getType(context);
				if(strProjectType.equals("Project Space"))
				{
					projectId = strProjectId;
					projectName =  strObj.getName(context);
				}
			}
	
			forderName = strObject.getName(context);
			forderId = objectId;

			
		}else if(strObject.isKindOf(context, "Task Management")){
			
			MapList mapList = strObject.getRelatedObjects(context,"Subtask","*",busList,null,true,false,(short)0,null,null);
			for(int i = 0 ; i < mapList.size(); i++)
			{
				Map map = (Map)mapList.get(i);
				String strProjectId = (String)map.get("id");	
				DomainObject strObj = new DomainObject(strProjectId);
				String strProjectType = strObj.getType(context);
				if(strProjectType.equals("Project Space"))
				{
					projectId = strProjectId;
					projectName =  strObj.getName(context);
				}
			}
			//projectName = strObject.getInfo(context,"to[Subtask].from.name");
			//projectId = strObject.getInfo(context,"to[Subtask].from.id");
		}else if(strType.equals("Meeting")){
			//mod by zs 4/1/2017
			StringList relList = new StringList(DomainRelationship.SELECT_ID);
			MapList mapList=strObject.getRelatedObjects(context, "Meeting Context", "*",busList , relList, true, false, (short) 1, null, null);
			for(int i=0;i<mapList.size();i++){
				Map map = (Map)mapList.get(i);
			    String objId = (String)map.get("id");
				DomainObject strObj = new DomainObject(objId);
				String strProjectType = strObj.getType(context);
				if(strProjectType.equals("Project Space"))
				{
					projectId = objId;
					projectName =  strObj.getName(context);
				}else{
					MapList mapList1=strObj.getRelatedObjects(context, "Subtask", "*",busList , relList, true, false, (short) 0, null, null);
					for(int j=0;j<mapList1.size();j++){
						Map map1 = (Map)mapList1.get(j);
						String objproId = (String)map1.get("id");			
						DomainObject objSpace = DomainObject.newInstance(context,objproId);
						String strName1 = objSpace.getName(context);
						String strType1 = objSpace.getType(context);
						if(strType1.equals("Project Space")){
							projectName = strName1;
							projectId = objproId;
						}			
					}	
				}				
			}				
			//end by zs 4/1/2017
		}else{
			
			projectName = strObject.getInfo(context,"to[Issue].from.name");
			projectId = strObject.getInfo(context,"to[Issue].from.id");	
		}
	}
	String strURL="../common/emxFullSearch.jsp?field=TYPES=type_ProjectSpace&includeOIDprogram=emxProjectSpace:getIncludeProjectOID&expandProgram=emxProjectSpace:getWorkpaceVault&selection=single&showInitialResults=false&projectId="+projectId+"&table=PMCGenericProjectSpaceSearchResults&submitURL=../common/SEMCreateDocument.jsp?mode=SelectWorkSpaceVault";
			
%>
	
	 <tr><!--//XSSOK-->
      <td class="labelRequired" >
        <%=projectLabel%>
      </td>

      <td class="inputField" >
        <input type="text" name="projectName" size="20" readonly="true" value="<xss:encodeForHTMLAttribute><%=projectName%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="projectId" size="20" readonly="true" value="<%=projectId%>" />
      </td>  
    </tr>
    
<%
	if("SEM Project Document".equals(documentType) || "SEM Meeting Document".equals(documentType))
	{
		String typeValue = "";
		if("SEM Project Document".equals(documentType))
		{
			typeValue = "type_SEMProjectDocument";
		}else if("SEM Meeting Document".equals(documentType)){
			typeValue = "type_SEMMeetingDocument";
		}
		Map temMap = new HashMap();
		temMap.put("LS Add Route State", "Review"); 
		temMap.put("type", typeValue); 
		temMap.put("policy", "policy_FasttrackChange");
		temMap.put("LSRouteTemplate", "LSRouteTemplate");
		String[] param = JPO.packArgs(temMap);
		String ml = (String)JPO.invoke(context, "LSCreateRouteUtil", null, "getJSPObjectRouteTemplateHTML", param, String.class); 

%>	
	<tr><!--//XSSOK-->
		<td class="label" ><%="\u6D41\u7A0B\u6A21\u7248"%> </td>
		<td class="inputField"><%=ml%></td>
	</tr>
<%
	}
%>
	<tr><!--//XSSOK-->
      <td class="labelRequired" >
        <%=forlderLabel%>
      </td>

      <td class="inputField" >
        <input type="text" name="forlderName" id="forlderName" size="20"  readonly="true" value="<xss:encodeForHTMLAttribute><%=forderName%></xss:encodeForHTMLAttribute>" />
		 <input type="button" name="FieldButton" value=".." size="5" onClick="showWorkForderSelector('<%=strURL%>')"/>
		<input type="hidden" name="forderId" id="forderId" size="20" readonly="true" value="<%=forderId%>" />
      </td>
	  
    </tr>
<%
	if("SEM Project Document".equals(documentType) || "SEM Meeting Document".equals(documentType))
	{
%>
 <tr><!--//XSSOK-->
      <td class="labelRequired" >
        <%=unit%>
	  </td>
<%
	//StringList  busList = new StringList("id");	
	ContextUtil.pushContext(context);
	String strWhere="attribute[LS Index Key1]=='SEM File Compiled Department' && current=='Active'";
    MapList LSPropertyKeyList = DomainObject.findObjects(context,"LS Property Key","*","*",null,null,strWhere,null,true,busList,(short)0);
	
	StringList checkDuplicateList = new StringList();
	StringList subTypeList = new StringList();
	StringList secretList=new StringList();
	String please="--\u8BF7\u9009\u62E9--";
	if(LSPropertyKeyList.size()>0)
	{
%>
		<td class="inputField" >
        <select id="unit" name="unit" onChange=reloadSubType()>
			<option value =""><%=please%></option>
<%							
		Iterator it = LSPropertyKeyList.iterator();
		while(it.hasNext())
		{
			Map keyMap = (Map)it.next();
			String keyId = (String)keyMap.get("id");
			DomainObject strKeyObj = new DomainObject(keyId);
			String unitValue = strKeyObj.getAttributeValue(context,"LS Attribute1");			
			if(!checkDuplicateList.contains(unitValue)){
				checkDuplicateList.add(unitValue);
			
%>
			<option value ="<%=unitValue%>"><%=unitValue%></option>
<%			
			}
		}	
%>	
    </select>
	 </td>
<%	
		
	}else{
%>
<td class="inputField">
	 <select id="unit" name="unit"  >
			<option value =""><%=please%></option>
	</select>	
</td>	
<%		
		
	}	
%>	 
    </tr>

<%
	String subType = "\u6587\u6863\u5206\u7C7B";

%>	
	 <tr><!--//XSSOK-->
      <td class="labelRequired" >
        <%=subType%>
	  </td>
<%
	if(subTypeList.size()>0)
	{
%>
		<td class="inputField" >
        <select id="subType" name="subType" onChange=reloadSubSecret()>
		<option value =""><%=please%></option>
<%							
		for(int a=0; a< subTypeList.size();a++)
		{		
			String subTypeValue = (String)subTypeList.get(a);
%>
			<option value ="<%=subTypeValue%>"><%=subTypeValue%></option>
<%				
		}	
%>	
    </select>
	 </td>
<%			
	}else{
%>
	<td class="inputField">
	 <select id="subType" name="subType" onChange=reloadSubSecret()>
			<option value =""><%=please%></option>
			
	</select>	
	</td>
<%		
		
	}	
%>	 
    </tr>

<%	
	
	
	String secret = "\u6587\u6863\u5BC6\u7EA7";

%>	
	 <tr><!--//XSSOK-->
      <td class="labelRequired" >
        <%=secret%>
	  </td>
<%

	
	if(secretList.size()>0)
	{
%>
		<td class="inputField" >
        <select id="secret" name="secret"  onChange=reloadPolicy() >
		<option value =""><%=please%></option>
<%							
		for(int b=0; b< secretList.size();b++)
		{		
			String subSecretValue = (String)secretList.get(b);
%>
			<option value ="<%=subSecretValue%>"><%=subSecretValue%></option>
<%				
		}	
%>	
    </select>
	 </td>
<%			
	}else{
%>
	<td class="inputField">
	  <select id="secret" name="secret"   onChange=reloadPolicy()>
			<option value =""><%=please%></option>
	</select>	
		</td>
<%		
		
	}	
	
		ContextUtil.popContext(context);
%>	 
    </tr>
	
<%	
	
	
    }
    // Start of display of Owner field depending on the parametes passed in
    // If showOwner parameter came as required it will display with labelrequired
    // If showOwner parameter came as true it will display as optional field
    // If showOwner parameter came as null or false, Owner field will not be displayed
    txtLable = "label";

    if ("".equals(documentOwner) || "null".equals(documentOwner))
      documentOwner=null;

    if ( showOwner.equalsIgnoreCase("true") || showOwner.equalsIgnoreCase("required") )
    {
        if ( showOwner.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>

    <tr>
		<!-- //XSSOK -->
      <td class="<%=txtLable%>">
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Owner</emxUtil:i18n>
      </td>

      <td class="inputField" >
<%
    if (showOwner.equalsIgnoreCase("required")){
%>
        <input type="text" size="20" name="person" onfocus="document.frmMain.person.blur()" value="<xss:encodeForHTMLAttribute><%=documentOwner==null?context.getUser():documentOwner%></xss:encodeForHTMLAttribute>" />
<%
    }else{
%>
        <input type="text" size="20" name="person" onFocus="document.frmMain.person.blur()"  value="<xss:encodeForHTMLAttribute><%=documentOwner==null?"":documentOwner%></xss:encodeForHTMLAttribute>" />
<%
    }
%>

        <input type="button" value="..." name="btn" onclick="chooseOwner_onclick()" />
<%
    if ( !showOwner.equalsIgnoreCase("required")){
      //not required so show clear link
%>
        <a class="dialogClear" href="javascript:;" onclick="document.forms[0].person.value=''" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
<%
    }
%>

      </td>
    </tr>

<%
    }

    // Start of display of Folder field depending on the parametes passed in
    // If showFolder parameter came as required it will display with labelrequired
    // If showFolder parameter came as true it will display as optional field
    // If showFolder parameter came as null or false, Folder field will not be displayed
    // this parameter is used in TeamCentral, Sourcing Central
    txtLable = "label";
    if ( showFolder.equalsIgnoreCase("true") || showFolder.equalsIgnoreCase("required") )
    {
        if ( showFolder.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }

%>
      <tr>
		<!-- //XSSOK -->
        <td class="<%=txtLable%>"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.Common.WorkspaceFolder</emxUtil:i18n></label></td>
        <td class="field">

          <input type="text" name="txtWSFolder" size="20" onfocus="blur()" value="<xss:encodeForHTMLAttribute><%=wsFolder%></xss:encodeForHTMLAttribute>"/>
          <input type="button" name="folder" value="..." onclick="folderlist()"/>

        </td>
      </tr>
<%
    }

    // Start of display of AccessType field depending on the parametes passed in
    // If showAccessType parameter came as required it will display with labelrequired
    // If showAccessType parameter came as true it will display as optional field
    // If showAccessType parameter came as null or false, AccessType field will not be displayed
    txtLable = "label";
    if("true".equalsIgnoreCase( showAccessType ) || "required".equalsIgnoreCase( showAccessType) )
    {
      if ( showAccessType.equalsIgnoreCase("required") )
      {
         txtLable = "labelRequired";
      }

      String accessAttrStr       = PropertyUtil.getSchemaProperty(context, "attribute_AccessType");
      AttributeType accessAttrType      = new AttributeType(accessAttrStr);
      StringList    accessAttributes    = null;
      StringItr     accessAttributesItr = null;
      String        defaultAccess       = null;

      accessAttrType.open(context);
      accessAttributes = accessAttrType.getChoices();
      defaultAccess    = accessAttrType.getDefaultValue(context);
      accessAttrType.close(context);
      accessAttributesItr = new StringItr(accessAttributes);
      // this happens first time the page is loaded
      if (documentAccessType == null || "".equals(documentAccessType) || "null".equals(documentAccessType))
      {
        documentAccessType = defaultAccess;
      }
%>
      <tr>
       <!-- XSSOK -->
        <td class="<%=txtLable%>">
          <%= i18nNow.getAttributeI18NString(accessAttrStr,sLanguage)%>&nbsp;
        </td>
        <td class="inputField" align="left">

        <select name="AccessType" size="1">
<%

      MapList ml = AttributeUtil.sortAttributeRanges(context, accessAttrStr, accessAttributes, sLanguage);
      Iterator mlItr = ml.iterator();
      while (mlItr.hasNext())
      {
        Map choiceMap = (Map) mlItr.next();
        String choice = (String) choiceMap.get("choice");
        String translation = (String) choiceMap.get("translation");
%>
        <option value="<xss:encodeForHTMLAttribute><%= choice %></xss:encodeForHTMLAttribute>" <%=(documentAccessType.equals(choice)? "selected" : "")%>><%= XSSUtil.encodeForHTML(context, translation) %></option>
<%
      }
%>
        </select>
        </td>
      </tr>
<%
  }

  // dynamic attribute display for custom sub-types of DOCUMENTS
  // get the list of Attribute names, filter out the attributes defined

  // by the property
  String excludeAttributes = EnoviaResourceBundle.getProperty(context,"emxComponents.CreateDocument.ExcludeAttributeList");
  StringList excludeAttrList   = new StringList();

  if(excludeAttributes != null)
  {
    StringTokenizer excludeAttrTokenizer = new StringTokenizer(excludeAttributes,",");
    while (excludeAttrTokenizer.hasMoreTokens())
    {
      excludeAttrList.add(excludeAttrTokenizer.nextToken().trim());
    }

    if( !excludeAttrList.contains("attribute_Title"))
    {
      excludeAttrList.add("attribute_Title");
    }
    if( !excludeAttrList.contains("attribute_AccessType"))
    {
      excludeAttrList.add("attribute_AccessType");
    }
    if( !excludeAttrList.contains("attribute_CheckinReason"))
    {
      excludeAttrList.add("attribute_CheckinReason");
    }
  }
//added third parameter to get the multiline value for bug no 338579
  MapList attributeMapList = mxType.getAttributes( context, documentType,true);
  Locale locale = request.getLocale();
  Iterator i = attributeMapList.iterator();
  String attributeName = null;
  String attributeValue = null;
  String attributedefValue = null;
  StringList attributeChoices = null;

  String symbolicAttributeName = null;
  while(i.hasNext())
  {
    Map attributeMap = (Map)i.next();
    attributeName = (String)attributeMap.get("name");
    symbolicAttributeName = FrameworkUtil.getAliasForAdmin(context, "attribute", attributeName, true);

    if(!excludeAttrList.contains(symbolicAttributeName))
    {
      // UIUtil converts the date to formatted date, which will not be correct to display
      // to avoid this, do not use UiUtil for date fields
      if ("timestamp".equalsIgnoreCase((String)attributeMap.get("type")))
      {
%>
        <tr>
          <td class="label" >
            <%= XSSUtil.encodeForHTML(context, i18nNow.getAttributeI18NString(attributeName,sLanguage))%>
          </td>
          <td class="inputField">
              <input type="text" name="<xss:encodeForHTMLAttribute><%=attributeName%></xss:encodeForHTMLAttribute>"
                  value="<xss:encodeForHTMLAttribute><%=(String) emxCommonDocumentCheckinData.get(attributeName)==null?"":(String) emxCommonDocumentCheckinData.get(attributeName)%></xss:encodeForHTMLAttribute>"   />&nbsp;&nbsp;
                  <a href="javascript:showCalendar2('frmMain', '<xss:encodeForJavaScript><%=attributeName%></xss:encodeForJavaScript>','')">
                  <img src="../common/images/iconSmallCalendar.gif" border="0" /></a>&nbsp;
			  <!-- //XSSOK -->
              <a class="dialogClear" href="javascript:;" onclick="document.forms[0]['<%=attributeName%>'].value =''">
                <emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n>
              </a>
          </td>
        </tr>
<%
      }
      else
      {
        attributedefValue = (String)attributeMap.get("default");
        attributeChoices  = (StringList)attributeMap.get("choices");
        attributeValue    = (String) emxCommonDocumentCheckinData.get(attributeName);

        if((attributeChoices != null && attributeChoices.size() > 0) && (attributeValue == null || "".equals(attributeValue) || "null".equals(attributeValue)))
        {
           attributeValue = attributedefValue;
        }
        attributeMap.put("value", attributeValue);
%>
     <!--   <tr>
          <td class="label" >
            <%= XSSUtil.encodeForHTML(context, i18nNow.getAttributeI18NString(attributeName,sLanguage))%>
          </td>
          <!-- //XSSOK 
          <td class="inputField"><%=UIUtil.displayField(context,attributeMap,"edit",sLanguage,"frmMain",session,locale)%>&nbsp;</td>
        </tr>
		-->
<%
      }
    }
  }

    if("previous".equals(fromPage)) {
            showFormat = (String) emxCommonDocumentCheckinData.get("showFormatBkp");
    }else {
            emxCommonDocumentCheckinData.put("showFormatBkp", showFormat);
    }


  if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ZIP_TAR_GZ) )
    {

        emxCommonDocumentCheckinData.put("noOfFiles", "1");
        emxCommonDocumentCheckinData.put("isVcDoc", "true");
%>
<!-- //XSSOK -->
    <jsp:include page="../components/emxCommonDocumentVCInformation.jsp"><jsp:param name="path" value="<%=path%>"/><jsp:param name="vcDocumentType" value="<%=vcDocumentType%>"/><jsp:param name="selector" value="<%=selector%>"/><jsp:param name="server" value="<%=server%>"/><jsp:param name="format" value="<%=defaultFormat%>"/><jsp:param name="showFormat" value="<%=showFormat%>"/><jsp:param name="populateDefaults" value="<%=populateDefaults%>"/><jsp:param name="objectAction" value="<%=objectAction%>"/><jsp:param name="disableFileFolder" value="<%=disableFileFolder%>"/><jsp:param name="defaultDocumentPolicyName" value="<%=defaultDocumentPolicyName%>"/><jsp:param name="reloadPage" value="<%=reloadPage%>"/></jsp:include>
<%  }
  if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ON_DEMAND)) {
              emxCommonDocumentCheckinData.put("isVcDoc", "true");
%>
    <tr>
      <td width="10%" class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.VCDocument.DesignSync</emxUtil:i18n>&nbsp;
        </td>
       <td colspan="1" class="inputField">

<%
	if ( vcDocumentType != null && "File".equalsIgnoreCase(vcDocumentType) )
	{
%>
      <input type="radio" name="vcDocumentTmp" value="File" checked onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="radio" name="vcDocumentTmp" value="Folder" onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
      <input type="radio" name="vcDocumentTmp" value="Module" onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="hidden" name="vcDocumentType" value="File"/>
<% }
   else if(vcDocumentType != null && "Folder".equalsIgnoreCase(vcDocumentType) ) {
%>
      <input type="radio" name="vcDocumentTmp" value="File"  onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="radio" name="vcDocumentTmp" value="Folder" checked onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
      <input type="radio" name="vcDocumentTmp" value="Module" onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="hidden" name="vcDocumentType" value="Folder"/>
<% }
   else if(vcDocumentType != null && ("Module".equalsIgnoreCase(vcDocumentType) || "Version".equalsIgnoreCase(vcDocumentType)) ) {
       %>
             <input type="radio" name="vcDocumentTmp" value="File"  onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
             <input type="radio" name="vcDocumentTmp" value="Folder" onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
             <input type="radio" name="vcDocumentTmp" value="Module" checked onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
             <input type="hidden" name="vcDocumentType" value="Module"/>
<% }
   else{ %>
      <input type="radio" name="vcDocumentTmp" value="File" checked onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="radio" name="vcDocumentTmp" value="Folder" onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
      <input type="radio" name="vcDocumentTmp" value="Module" onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="hidden" name="vcDocumentType" value="File"/>
<% } %>
      </td>
      </tr>
<% } %>


    <tr>
      <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
      <td width="90%">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="typeChanged" value="" />
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

