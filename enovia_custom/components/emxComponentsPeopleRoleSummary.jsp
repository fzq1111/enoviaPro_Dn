<%--  emxComponentsPeopleRoleSummary.jsp   -   Display All Roles

   Copyright (c) 1992-2015 Dassault Systemes. All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPeopleRoleSummary.jsp.rca 1.27.2.2 Tue Dec 23 06:17:38 2008 ds-arsingh Experimental $
--%>
<%@page import = "com.matrixone.apps.domain.util.*"%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>

<%@ include file = "../emxJSValidation.inc" %>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  String keyPerson = emxGetParameter(request,"keyPerson");
  String languageStr        = request.getHeader("Accept-Language");
  String jsTreeID           = (String)formBean.getElementValue("jsTreeID");
  String suiteKey           = (String)formBean.getElementValue("suiteKey");
  String organizationId     = (String)formBean.getElementValue("objectId");
  String sRoleList          = (String)formBean.getElementValue("roleList");
  String sGroupList         = (String)formBean.getElementValue("groupList");
  String sCheckedRoleList   = (String)formBean.getElementValue("removedRoleList");
  String sCheckedGroupList  = (String)formBean.getElementValue("removedGroupList");
  
  String strCompanyRep      = (String)formBean.getElementValue("companyrep");
  if(strCompanyRep == null || "null".equals(strCompanyRep)){
    strCompanyRep = "";
  }

  String strVault      = (String)formBean.getElementValue("Vault");
  if(strVault == null || "null".equals(strVault)){
    strVault = "";
  }

  if (sRoleList == null || "null".equals(sRoleList)){
    sRoleList="";
  }
  if (sCheckedRoleList == null || "null".equals(sCheckedRoleList)){
    sCheckedRoleList="";
  }
  
  if (sGroupList == null || "null".equals(sGroupList)){
    sGroupList = "";
  }
  if (sCheckedGroupList == null || "null".equals(sCheckedGroupList)){
    sCheckedGroupList = "";
  }

  String rowClass = "even";

  String sParams = "?keyPerson=" + keyPerson + "&showWarning=false";
  
  String strCompanyRepresentative   = PropertyUtil.getSchemaProperty(context, "role_CompanyRepresentative");
  String strOrganizationManager     = PropertyUtil.getSchemaProperty(context, "role_OrganizationManager");
  // Get the current person from the context.
  
  String strCompanyType             = PropertyUtil.getSchemaProperty(context, "type_Company");
  String strBusinessUnitType        = PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");
  
  //
  //Added sRoleList check for bug 364050
  //
  if((sRoleList == null || "".equals(sRoleList)) && (strCompanyType.equals(strCompanyRep) || strBusinessUnitType.equals(strCompanyRep)))
  {
    sRoleList = sRoleList + "|" + strCompanyRepresentative;
  }

  // if Company Representative role is removed, then remove the companyrep value from the session
  if(sCheckedRoleList.indexOf(strCompanyRepresentative) != -1)
  {
    formBean.setElementValue("companyrep","");
  }
  
  com.matrixone.apps.common.Person busLoggedPerson = com.matrixone.apps.common.Person.getPerson(context);  
  if("".equals(strVault)) strVault = busLoggedPerson.getVaultName(context);
  //BusinessObject busLoggedPerson = JSPUtil.getPerson(context,session);
  
  busLoggedPerson.open(context);
  boolean isHostRep = Company.isHostRep(context, busLoggedPerson);
  busLoggedPerson.close(context);
  
  MapList roleMapList =  new MapList();
  MapList assignmentMapList = new MapList();

  StringTokenizer rolesToken = new StringTokenizer(sRoleList, "|");
  StringTokenizer rolesCheckedToken = null;

  String roleNameAdd = "";
  String sCheckedRoleName = "";
  boolean ishRep = false;
  boolean isRemovedRole = false;
  MQLCommand mqlCmd = new MQLCommand();
  StringList listOfRoles = new StringList();
  sRoleList = "";

  boolean showAlert = false;
  while (rolesToken.hasMoreTokens())
  {
    ishRep = false;
    isRemovedRole = false;
    Hashtable roleHashTable = new Hashtable();
    roleNameAdd = rolesToken.nextToken();
    if ((sCheckedRoleList != null) && (!sCheckedRoleList.equals("null")) && (sCheckedRoleList.length() > 0)){
      rolesCheckedToken = new StringTokenizer(sCheckedRoleList, "|");
    }

    //Checking for roles which are removed
    if(rolesCheckedToken != null) {
      while (rolesCheckedToken.hasMoreTokens()) {
        sCheckedRoleName = rolesCheckedToken.nextToken();
        if(sCheckedRoleName.equals(roleNameAdd)) {
          isRemovedRole = true;
          break;
        }
      }
    }

    // If logged in person in non host rep don't add comprep role to hashtable
    if (!isHostRep && (roleNameAdd.equals(strCompanyRepresentative) || roleNameAdd.equals(strOrganizationManager) ) ){
      ishRep = true;
      showAlert = true;
    }

    if(!ishRep && !isRemovedRole && !listOfRoles.contains(roleNameAdd) ) {
      String mqlCmdStr = "print role " + "\"" + roleNameAdd + "\"" + " select description dump";

      mqlCmd.executeCommand(context, mqlCmdStr);

      String sDesc = mqlCmd.getResult();

      roleHashTable.put("assignment", roleNameAdd);
      roleHashTable.put("description", sDesc);
      roleHashTable.put("type","role");
      assignmentMapList.add(roleHashTable);
      listOfRoles.add(roleNameAdd);
      sRoleList += roleNameAdd +"|" ;
      }
   }
  sCheckedRoleList = "";

   formBean.setElementValue("roleList",sRoleList);
   formBean.setElementValue("removedRoleList",sCheckedRoleList);
   
  // for Groups   

  StringTokenizer groupsToken = new StringTokenizer(sGroupList, "|");
  StringTokenizer groupsCheckedToken = null;

  String groupNameAdd = "";
  String sCheckedGroupName = "";
  boolean isRemovedGroup = false;
  //MQLCommand mqlCmd = new MQLCommand();
  StringList listOfGroups = new StringList();
  sGroupList = "";

  //boolean showAlert = false;
  Hashtable groupHashTable = null;
  while (groupsToken.hasMoreTokens())
  {
    isRemovedGroup = false;
    groupHashTable = new Hashtable();
    groupNameAdd = groupsToken.nextToken();
    if ((sCheckedGroupList != null) && (!sCheckedGroupList.equals("null")) && (sCheckedGroupList.length() > 0)){
      groupsCheckedToken = new StringTokenizer(sCheckedGroupList, "|");
    }

    //Checking for roles which are removed
    if(groupsCheckedToken != null) {
      while (groupsCheckedToken.hasMoreTokens()) {
        sCheckedGroupName = groupsCheckedToken.nextToken();
        if(sCheckedGroupName.equals(groupNameAdd)) {
          isRemovedGroup = true;
          break;
        }
      }
    }

    if(!isRemovedGroup && !listOfGroups.contains(groupNameAdd) ) {
      String mqlCmdStr = "print group " + "\"" + groupNameAdd + "\"" + " select description dump";

      mqlCmd.executeCommand(context, mqlCmdStr);

      String sDesc = mqlCmd.getResult();

      groupHashTable.put("assignment", groupNameAdd);
      groupHashTable.put("description", sDesc);
      groupHashTable.put("type","group");
      assignmentMapList.add(groupHashTable);
      listOfGroups.add(groupNameAdd);
      sGroupList += groupNameAdd+"|";
      }
   }
   sCheckedGroupList = "";
   formBean.setElementValue("groupList",sGroupList);
   formBean.setElementValue("removedGroupList",sCheckedGroupList);
   
   boolean bFound = false;
%>

<script language="JavaScript">
    var clicked = false;
<%
if(showAlert) {
%>
  alert("<emxUtil:i18nScript localize="i18nId">emxComponents.PeopleRoleSummary.RoleAlertMessage</emxUtil:i18nScript>");
<%
}
%>
  function doCheck() {
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    //var reChkName = /chkRole/gi;
    for (var i=0; i < objForm.elements.length; i++)
    if (objForm.elements[i].name.indexOf('chkRole') > -1 || objForm.elements[i].name.indexOf('chkGroup') > -1){
      objForm.elements[i].checked = chkList.checked;
    }
  }

  function updateCheck() {
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    chkList.checked = false;
  }

  function removeSelected() {
    var objForm = document.forms[0];
    var bFlag = "false";
        var sFinal = "";
        var iCount = 0;
        document.CreatePeople.removedRoleList.value = "";
        document.CreatePeople.removedGroupList.value = "";
        for( var i = 0; i < document.CreatePeople.elements.length; i++ ){
          if (document.CreatePeople.elements[i].type == "checkbox") {
            checkedvalue = document.CreatePeople.elements[i].value;
            if(checkedvalue != "on") {
              iCount++;
            }
          }
        }
        // Getting the Removed Roles List
        for( var i = 0; i < document.CreatePeople.elements.length; i++ ){
         if (document.CreatePeople.elements[i].type == "checkbox" &&
           document.CreatePeople.elements[i].checked )
           {
            bFlag = "true";
            checkedvalue = document.CreatePeople.elements[i].value;
            if (objForm.elements[i].name.indexOf('chkRole') > -1 )
            {
                document.CreatePeople.removedRoleList.value +=  checkedvalue + "|";
            }
            else
            {
                document.CreatePeople.removedGroupList.value +=  checkedvalue + "|";
            }
         }
        }
        // If no Roles are there don't alert
        if(iCount ==0) {
          return;
        }
        if(bFlag == "false"){
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePerson.SelectRolesOrGroups</emxUtil:i18nScript>");
          return;
        }

        document.CreatePeople.action =  "emxComponentsPeopleRoleSummaryFS.jsp";
        document.CreatePeople.submit();
    return;
  }

  function submitForm() {

    if(clicked == false) {
      clicked=true;
    // Create an alias for the form.
    document.CreatePeople.action =  "<%= XSSUtil.encodeForURL(context, "emxComponentsCreatePeopleDialogProcess.jsp")%>";
    document.CreatePeople.submit();
    }
  }
  
  function closeWindow() 
  {
    getTopWindow().location.href="emxComponentsCreatePeopleDialogClose.jsp?keyPerson=<%=XSSUtil.encodeForURL(context, keyPerson)%>";
  }

  function goBack() {
    document.CreatePeople.action =  "emxComponentsCreatePeopleDialogFS.jsp";
    document.CreatePeople.submit();
  }

  function addRoles() {
   showModalDialog('../common/emxIndentedTable.jsp?selection=multiple&expandLevelFilterMenu=false&customize=false&Export=false&multiColumnSort=false&PrinterFriendly=false&showPageURLIcon=false&showRMB=false&showClipboard=false&objectCompare=false&displayView=details&submitLabel=emxComponents.Common.Done&cancelLabel=emxComponents.Common.Cancel&cancelButton=true&header=emxComponents.AddRoles.SelectRoles&program=emxRoleUtil:getRolesSearchResults&toolbar=APPRoleSearchToolbar&suiteKey=Components&table=APPRoleSummary&HelpMarker=emxhelpcreateperson2&objectId='+"<%=XSSUtil.encodeForURL(context, organizationId)%>"+'&submitURL=../components/emxComponentsAddRole.jsp?fromPage=CreatePerson&keyPerson='+"<%=XSSUtil.encodeForURL(context, keyPerson)%>", 550, 550);

  }
  function addGroups() {
   // showModalDialog('../common/emxIndentedTable.jsp?selection=multiple&expandLevelFilterMenu=false&customize=false&Export=false&multiColumnSort=false&PrinterFriendly=false&showPageURLIcon=false&showRMB=false&showClipboard=false&objectCompare=false&displayView=details&submitLabel=emxComponents.Common.Done&cancelLabel=emxComponents.Common.Cancel&cancelButton=true&header=emxComponents.AddGroups.SelectGroups&table=APPGroupSummary&suiteKey=Components&program=emxGroupUtil:getGroupSearchResults&HelpMarker=emxhelpselectuser&toolbar=APPGroupSearchToolbar&submitURL=../components/emxComponentsAddGroup.jsp?fromPage=CreatePerson&keyPerson='+"<%=XSSUtil.encodeForURL(context, keyPerson)%>", 550, 550);
  }


</script>
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="CreatePeople" method="post" action="" target="_parent">

  <input type="hidden" name="removedRoleList" value="<xss:encodeForHTMLAttribute><%=sCheckedRoleList%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="removedGroupList" value="<xss:encodeForHTMLAttribute><%=sCheckedGroupList%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="keyPerson" value="<xss:encodeForHTMLAttribute><%=keyPerson%></xss:encodeForHTMLAttribute>" />
  
<table class="list" id="UITable">
  <framework:sortInit
     defaultSortKey="assignment"
     defaultSortType="string"
     mapList="<%=assignmentMapList%>"
     resourceBundle="emxComponentsStringResource"
     ascendText="emxComponents.Common.SortAscending"
     descendText="emxComponents.Common.SortDescending"
     params = "<%=XSSUtil.encodeForHTML(context, sParams)%>"  />
   <tr>
<%   
    if(assignmentMapList.size() != 0) 
    {
%>
      <th width="5%" style="text-align:center">
        <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" checked/>
      </th>
<%
    }
%>
    <th nowrap>
      <framework:sortColumnHeader
        title="emxComponents.Common.Name"
        sortKey="assignment"
        sortType="string"/>
    </th>
    <th nowrap>
      <framework:sortColumnHeader
        title="emxComponents.Common.Description"
        sortKey="description"
        sortType="string"/>
    </th>
  </tr>

<%
    String strAssignmentType = "";
    String strName           = "";
    String strDesc           = "";
%>

  <framework:mapListItr mapList="<%=assignmentMapList%>" mapName="assignmentMap">
<%
        bFound = true;
        strAssignmentType = (String)assignmentMap.get("type");
        strName = "";
        strDesc = "";
%>
    <tr class='<framework:swap id ="1" />'>
      
<%        
        if("role".equals(strAssignmentType))
        {
            strName = (String)assignmentMap.get("assignment");
            strDesc = i18nNow.getRoleDescriptionI18NString(strName, languageStr);
%>            
            <td><input type="checkbox" name="chkRole"  onclick="updateCheck()" value="<xss:encodeForHTMLAttribute><%=strName%></xss:encodeForHTMLAttribute>" checked /></td>
            <td><img src="../common/images/iconRole.gif" name="imgRole" id="imgRole" alt="<%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Role",strName,languageStr))%>" /><%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Role",strName,languageStr))%></td>
<%
        }
        else
        {
            strName = (String)assignmentMap.get("assignment");
            strDesc = i18nNow.getAdminDescriptionI18NString(strName,"Group", languageStr);
%>            
            <td><input type="checkbox" name="chkGroup"  onclick="updateCheck()" value="<xss:encodeForHTMLAttribute><%=strName%></xss:encodeForHTMLAttribute>" checked /></td>
            <td><img src="../common/images/iconSmallGroup.gif" name="imgGroup" id="imgGroup" alt="<%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Group",strName,languageStr))%>" /><%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Group",strName,languageStr))%></td>
<%            
        }
%>
          <td><%=XSSUtil.encodeForHTML(context, strDesc)%>&nbsp;</td>
        </tr>
    </framework:mapListItr>
<%
      if (!bFound) {
%>
        <tr>
          <td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxComponents.CreatePerson.NoRolesAndGroups</emxUtil:i18n></td>
        </tr>
<%
      }
%>
  </table>

<%
    // if still RoleList contains Company Representative role and strCompanyRep is blank, then provide
    // strCompanyType value to comapnyRep
    if((sRoleList.indexOf(strCompanyRepresentative) != -1) && "".equals(strCompanyRep))
    {
        formBean.setElementValue("companyrep",strCompanyType);
    }
%>
  <input type="hidden" name="roleList" value="<xss:encodeForHTMLAttribute><%=sRoleList%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="groupList" value="<xss:encodeForHTMLAttribute><%=sGroupList%></xss:encodeForHTMLAttribute>" />
  
</form>
<%
    formBean.setFormValues(session);
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
