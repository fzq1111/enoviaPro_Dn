<%--  emxRouteWizardAccessMembersDialog.jsp   -   Displays the AccessMembers Objects List
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteWizardAccessMembersDialog.jsp.rca 1.21 Wed Oct 22 16:18:39 2008 przemek Experimental przemek $

--%>
 <%@include file = "../emxUICommonAppInclude.inc" %>
 <%@include file = "emxRouteInclude.inc" %>
 <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
 <%@include file = "emxComponentsJavaScript.js" %>
 <%@include file = "../emxPaginationInclude.inc" %>
 <jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

 <%
 
 String keyValue=emxGetParameter(request,"keyValue");
 String relatedObjectId  =  (String)formBean.getElementValue("objectId");
 String templateId       =  (String) formBean.getElementValue("templateId");
 String scopeId          =  (String) formBean.getElementValue("scopeId");
 String templateName     =  (String) formBean.getElementValue("templateName");
 String routeId          =  (String) formBean.getElementValue("routeId");
 // flag to find if user coming back from step 4 to 3
 String toAccessPage    =  (String) formBean.getElementValue("toAccessPage");
 String workspaceId       =  (String) formBean.getElementValue("workspaceId");
 String folderId   =  (String) formBean.getElementValue("folderId");
 String suiteKey    =  (String) formBean.getElementValue("suiteKey");
 String jsTreeID    =  (String) formBean.getElementValue("jsTreeID");
 String portalMode  =  (String) formBean.getElementValue("portalMode");
 String supplierOrgId     =  (String) formBean.getElementValue("supplierOrgId");
 String routeAction    =  (String) formBean.getElementValue("selectedAction");
 Hashtable hashRouteWizFirst  =  (Hashtable)formBean.getElementValue("hashRouteWizFirst");
 String selscope = (String)  hashRouteWizFirst.get("selscope");

 String selscopeId       =  (String)  hashRouteWizFirst.get("selscopeId");
 String sUser = context.getUser();
  String attrTaskEditSetting  = PropertyUtil.getSchemaProperty(context,"attribute_TaskEditSetting");
  DomainObject routeTemplateObj  = null;
  String strTaskEditSetting   = getTaskSetting(context,templateId);

  String sReadWriteSelected = "";
  String sReadSelected      = "";
  String sAddSelected       = "";
  String sRemoveSelected    = "";
  String sAddRemoveSelected = "";
  String sAccess            = "";
  String sTargetId          = "";
  String userName          = "";
  String sTargetType        = "";
  String sTargetName        = "";
  String sDisplayTargetName = "";
  String sTargetOrganization = "";
  String sProjectLead       = "";
  String sCreateRoute       = "";
  String sProjectId         = null;
  String scope = "";
  String prjType = "";
  String fromRouteTemplate= "";
  int i=0;

   MapList routeMemberMapList = null;
       routeMemberMapList = (MapList)formBean.getElementValue("routeMemberMapList");

  String sParams = "jsTreeID="+ jsTreeID +"&suiteKey="+suiteKey+"&objectId="+relatedObjectId+"&routeId="+routeId;
  sParams += "&templateId=" +templateId+"&template="+templateName+"&toAccessPage="+toAccessPage+"&supplierOrgId=" + supplierOrgId + "&portalMode=" +portalMode;
  String sRoute  = i18nNow.getI18nString("emxComponents.Common.Route", "emxComponentsStringResource", sLanguage);

%>

<script language="Javascript" type="text/javascript">

  // function to close window
  function closeWindow() {
   submitWithCSRF("emxRouteWizardCancelProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>", window);
  }

  function goBack() {
    document.ContenForm.target = "_parent";
    document.ContenForm.action="emxRouteWizardCreateDialogFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&<%=XSSUtil.encodeForURL(context, sParams)%>&previousButtonClick=true";
    document.ContenForm.submit();
    return ;
  }

  function submitForm() {
    var checkedFlag = "false";
    // force to select atleast one member to add
    for( var i = 0; i < document.ContenForm.elements.length; i++ ){
      if (document.ContenForm.elements[i].type == "checkbox" && document.ContenForm.elements[i].name == "chkItem" ){
        checkedFlag = "true";
        break;
      }
    }
    if (checkedFlag == "false") {
      alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.PeopleSummary.SelectOneMember</emxUtil:i18nScript>");
      return;
    }
    document.ContenForm.target = "_parent";
    document.ContenForm.action="LSRouteWizardAccessMembersProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>";

    startProgressBar(true);
    document.ContenForm.submit();
    return;

  }
  function addMembers()
  {
  <%
    if( selscope.equals("ScopeName") ){
      scope = selscopeId;
      BusinessObject boScopeType = new BusinessObject(scope);
      boScopeType.open(context);
      if(boScopeType.getTypeName().equals(DomainObject.TYPE_WORKSPACE_VAULT)  )
      {
          String  sProjId = UserTask.getProjectId( context, scope);
          DomainObject sProjObject = new DomainObject(sProjId);
          prjType = sProjObject.getInfo(context, DomainObject.SELECT_TYPE);
      }
      if( boScopeType.getTypeName().equals(DomainObject.TYPE_WORKSPACE) || prjType.equals(DomainObject.TYPE_WORKSPACE)  )
      {
  %>
        emxShowModalDialog('emxRouteMembersSearch.jsp?fromPage=routeWizard&memberType=Person&objectId=<%=XSSUtil.encodeForURL(context, relatedObjectId)%>&scopeId=<%=XSSUtil.encodeForURL(context, scopeId)%>&routeId=<%=XSSUtil.encodeForURL(context, routeId)%>&noSearch=true&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>',775, 500);
  <%
      }
      else  if(prjType.equals(DomainObject.TYPE_PROJECT_SPACE) || mxType.isOfParentType(context,prjType,DomainConstants.TYPE_PROJECT_SPACE)) //Modified to handle Bug 330328 0
      {
  %>
        emxShowModalDialog('emxRouteSelectProjectFolderMembersFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, scope)%>&memberType=Person&projectId=<%=XSSUtil.encodeForURL(context, scope)%>',775, 500);
  <%
      }
      else if( boScopeType.getTypeName().equals(DomainObject.TYPE_PROJECT_SPACE) || mxType.isOfParentType(context,boScopeType.getTypeName(),DomainConstants.TYPE_PROJECT_SPACE)) //Modified to handle Bug 330328 0
      {
         String mode = "roleSearch";
         String searchableGroups = "All";
  %>
        emxShowModalDialog('emxRouteSelectProjectMembersFS.jsp?projectId=<%=XSSUtil.encodeForURL(context, scope)%>&hasTarget=true&multiSelect=true&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&memberType=Person',775, 500);
  <%
      }
    }
    else
    {
  %>
        emxShowModalDialog('emxRouteMembersSearch.jsp?memberType=Person&fromPage=routeWizard&supplierOrgId=<%=XSSUtil.encodeForURL(context, supplierOrgId)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&scopeId=<%=XSSUtil.encodeForURL(context, scopeId)%>&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>',600,500);
  <%
    }
  %>
 }

//added on 11nov
  function addRole()
  {
  <%
  if( selscope.equals("ScopeName") )
  {
    scope = selscopeId;
    BusinessObject boScopeType = new BusinessObject(scope);
    boScopeType.open(context);
    if(boScopeType.getTypeName().equals(DomainObject.TYPE_WORKSPACE_VAULT)  )
    {
      DomainObject sFoldObject = new DomainObject(scope);
      String  sProjId = UserTask.getProjectId( context, scope);
      DomainObject sProjObject = new DomainObject(sProjId);
      prjType = sProjObject.getInfo(context, DomainObject.SELECT_TYPE);
    }
    if( boScopeType.getTypeName().equals(DomainObject.TYPE_WORKSPACE) || prjType.equals(DomainObject.TYPE_WORKSPACE)  )
    {
  %>
      emxShowModalDialog('emxRouteMembersSearch.jsp?memberType=Role&fromPage=routeWizard&scopeId=<%=XSSUtil.encodeForURL(context, scopeId)%>&projectId=<%=XSSUtil.encodeForURL(context, scope)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>',775, 500);
  <%
    }else  if(prjType.equals(DomainObject.TYPE_PROJECT_SPACE) || mxType.isOfParentType(context,prjType,DomainConstants.TYPE_PROJECT_SPACE)) //Modified to handle Bug 330328 0
	{
  %>
      emxShowModalDialog('emxRouteSelectProjectFolderMembersFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, scope)%>&memberType=Role&projectId=<%=XSSUtil.encodeForURL(context, scope)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>',775, 500);
  <%
    }
    else if( boScopeType.getTypeName().equals(DomainObject.TYPE_PROJECT_SPACE) || mxType.isOfParentType(context,boScopeType.getTypeName(),DomainConstants.TYPE_PROJECT_SPACE)) //Modified to handle Bug 330328 0
	{
       String mode = "roleSearch";
       String searchableGroups = "All";
  %>
       emxShowModalDialog('emxRouteSelectProjectRolesOrGroupsFS.jsp?projectId=<%=XSSUtil.encodeForURL(context, scope)%>&memberType=Role&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>',775, 500);
  <%
     }
    }
    else
    {
  %>
       emxShowModalDialog('emxRouteMembersSearch.jsp?fromPage=routeWizard&memberType=Role&scopeId=<%=XSSUtil.encodeForURL(context, scopeId)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>',775, 500);
  <%
    }
  %>
   }

function addGroup()
{
  <%
    if( selscope.equals("ScopeName") )
    {
      scope = selscopeId;
      BusinessObject boScopeType = new BusinessObject(scope);
      boScopeType.open(context);
      if(boScopeType.getTypeName().equals(DomainObject.TYPE_WORKSPACE_VAULT)  )
      {
        String  sProjId = UserTask.getProjectId( context, scope);
        DomainObject sProjObject = new DomainObject(sProjId);
        prjType = sProjObject.getInfo(context, DomainObject.SELECT_TYPE);
      }
      if( boScopeType.getTypeName().equals(DomainObject.TYPE_WORKSPACE) || prjType.equals(DomainObject.TYPE_WORKSPACE)  )
      {
  %>
         emxShowModalDialog('emxRouteMembersSearch.jsp?memberType=Group&fromPage=routeWizard&scopeId=<%=XSSUtil.encodeForURL(context, scopeId)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>',775, 500);
  <%
      }else  if(prjType.equals(DomainObject.TYPE_PROJECT_SPACE)|| mxType.isOfParentType(context,prjType,DomainConstants.TYPE_PROJECT_SPACE)) //Modified to handle Bug 330328 0
	  {
  %>
         emxShowModalDialog('emxRouteSelectProjectFolderMembersFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, scope)%>&memberType=Group&projectId=<%=XSSUtil.encodeForURL(context, scope)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>',775, 500);
  <%
      }
      else  if( boScopeType.getTypeName().equals(DomainObject.TYPE_PROJECT_SPACE)  || mxType.isOfParentType(context,boScopeType.getTypeName(),DomainConstants.TYPE_PROJECT_SPACE)) //Modified to handle Bug 330328 0
	  {
        String mode = "groupSearch";
        String searchableGroups = "All";
  %>
         emxShowModalDialog('emxRouteSelectProjectRolesOrGroupsFS.jsp?projectId=<%=XSSUtil.encodeForURL(context, scope)%>&memberType=Group&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>',775, 500);
  <%
      }
    }
    else{
  %>
        emxShowModalDialog('emxRouteMembersSearch.jsp?memberType=Group&fromPage=routeWizard&scopeId=<%=XSSUtil.encodeForURL(context, scopeId)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>',775, 500);
  <%
    }
  %>
  }

function addMemberList()
{
  emxShowModalDialog('emxRouteMembersSearch.jsp?memberType=MemberList&fromPage=routeWizard&scopeId=<%=XSSUtil.encodeForURL(context, scopeId)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>',775, 500);
}


function removeMembers(removeMemTask) {
    var checkedFlag = "false";
    document.ContenForm.selRoles.value="";
        document.ContenForm.selGroup.value="";
    // force to select atleast one member to add
    for( var i = 0; i < document.ContenForm.elements.length; i++ ){
      if (document.ContenForm.elements[i].type == "checkbox" && document.ContenForm.elements[i].name == "chkItem"
          && document.ContenForm.elements[i].checked){
        checkedFlag = "true";
        break;
      }
    }
    // Sending all the selected roles and groups in input type hidden
        for( var i = 0; i < document.ContenForm.elements.length; i++ ){
          if ((document.ContenForm.elements[i].type == "checkbox") && (document.ContenForm.elements[i].name == "chkItem") && (document.ContenForm.elements[i].checked) && (document.ContenForm.elements[i].value == "Role") && (document.ContenForm.elements[i+1].name == "userRole")){
            document.ContenForm.selRoles.value = document.ContenForm.selRoles.value + document.ContenForm.elements[i+1].value + ";";
          }else if ((document.ContenForm.elements[i].type == "checkbox") && (document.ContenForm.elements[i].name == "chkItem") && (document.ContenForm.elements[i].checked) && (document.ContenForm.elements[i].value == "Group") && (document.ContenForm.elements[i+1].name == "userRole")){
            document.ContenForm.selGroup.value = document.ContenForm.selGroup.value + document.ContenForm.elements[i+1].value + ";";
          }
    }
    if (checkedFlag == "false") {
      alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.AccessMembersDialog.SelectRemove</emxUtil:i18nScript>");
      return;
    }
    else
    {
     if(confirm("<emxUtil:i18nScript  localize="i18nId">emxComponents.RouteMember.RemoveMsgConfirm</emxUtil:i18nScript>"))
      {
          //document.ContenForm.action="emxRouteWizardRemoveContentProcess.jsp?keyValue=<%=keyValue%>&removeMember=removeMember";
          		  document.ContenForm.action="emxRouteWizardRemoveContentProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&removeMember="+removeMemTask;
          document.ContenForm.submit();
      }
    }
    return ;
  }
  function ChangeAccess(accessChangedCount){
     var selectName = "selAccess"+accessChangedCount;
     var accessSelected=document.ContenForm.elements[selectName].options[document.ContenForm.elements[selectName].selectedIndex].value;
     document.location.href="emxRouteWizardAccessMembersProcess.jsp?changedAccessPage=changedAccessPage&changedAccess="+accessChangedCount+"&accessSelected="+accessSelected+"&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>";
  }
</script>
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>
<%@ include file = "../emxUICommonHeaderEndInclude.inc" %>
<form name="ContenForm" method="post" target="_parent" onSubmit="javascript:submitForm(); return false">
   <table class="list" id="routeMemberList">
    <framework:sortInit
       defaultSortKey="LastFirstName"
       defaultSortType="string"
       mapList="<%=routeMemberMapList%>"
       resourceBundle="emxComponentsStringResource"
       ascendText="emxComponents.Common.SortAscending"
       descendText="emxComponents.Common.SortDescending"
       params = "<%=XSSUtil.encodeForHTML(context, sParams)%>"  />

     <tr>
       <th width="2%" style="text-align: center;" >
        <span style="text-align: center;">
         <input type="checkbox" name="checkAll" id="checkAll" onclick="allSelected('ContenForm')"/>
        </span>
       </th>
       <th nowrap>
         <framework:sortColumnHeader
           title="emxComponents.Common.Name"
           sortKey="LastFirstName"
           sortType="string"/>
       </th>
       <th nowrap>
         <framework:sortColumnHeader
           title="emxComponents.Common.Type"
           sortKey="<%=DomainObject.SELECT_TYPE%>"
           sortType="string"/>
       </th>
       <th nowrap>
         <framework:sortColumnHeader
           title="emxComponents.Common.Organization"
           sortKey="OrganizationName"
           sortType="string"/>
      </th>
      <th nowrap>
         <framework:sortColumnHeader
           title="emxComponents.Route.Scope"
           sortKey="Scope"
           sortType="string"/>
      </th>
      <th><emxUtil:i18n localize="i18nId">emxComponents.Common.Access</emxUtil:i18n></th>
    </tr>
    <framework:ifExpr expr="<%=routeMemberMapList == null || (routeMemberMapList != null && routeMemberMapList.size() == 0)%>">
	      <tr>
	        <td align="center" colspan="13" class="error">
	          <emxUtil:i18n localize="i18nId">emxComponents.AddMembers.NoMembers</emxUtil:i18n>
	        </td>
	      </tr>
    </framework:ifExpr>
    <framework:ifExpr expr="<%=routeMemberMapList != null && routeMemberMapList.size() > 0%>">
    	<framework:mapListItr mapList="<%=routeMemberMapList%>" mapName="routeAccessMemberMap">
<%    
       StringList memberList = new StringList();
      sTargetId           = (String)routeAccessMemberMap.get(DomainConstants.SELECT_ID);
      userName            = (String)routeAccessMemberMap.get(DomainConstants.SELECT_NAME);
      sTargetType         = (String)routeAccessMemberMap.get(DomainConstants.SELECT_TYPE);
      sDisplayTargetName  = (String)routeAccessMemberMap.get("LastFirstName");
      //added for the bug no 339357 - Begin
      if("role".equalsIgnoreCase(sTargetType)){
        sDisplayTargetName= i18nNow.getAdminI18NString("Role",sDisplayTargetName,sLanguage);
     }else{
       sDisplayTargetName= i18nNow.getAdminI18NString("Group",sDisplayTargetName,sLanguage);
     }
     // End the bug no 339357
      sTargetOrganization = (String)routeAccessMemberMap.get("OrganizationName");
      sAccess             = (String)routeAccessMemberMap.get("access");
      fromRouteTemplate = "";
      if(routeAccessMemberMap.get("fromRouteTemplate")!= null)
         fromRouteTemplate   = (String)routeAccessMemberMap.get("fromRouteTemplate");
      if(!memberList.contains(userName)) {
%>
       <tr class='<framework:swap id ="1" />'>
          <td style="font-size: 8pt" align="center" >
<%
      if(fromRouteTemplate!= null && fromRouteTemplate.equals("Yes") && !strTaskEditSetting.equals("Modify/Delete Task List"))
      {
%>
            <input type="checkbox" name="chkItem" id="chkItem" disabled  value="<xss:encodeForHTMLAttribute><%=sTargetId%></xss:encodeForHTMLAttribute>"/>
            <input type="hidden" name="userRole" value="<xss:encodeForHTMLAttribute><%=userName%></xss:encodeForHTMLAttribute>"/>
            <input type="hidden" name="<%="personid"+i%>" value="<xss:encodeForHTMLAttribute><%=userName%></xss:encodeForHTMLAttribute>"/>
<%    }
      else
      {
%>
            <input type="checkbox" name="chkItem" id="chkItem" onclick="updateSelected('ContenForm')" value="<xss:encodeForHTMLAttribute><%=sTargetId%></xss:encodeForHTMLAttribute>"/>
            <input type="hidden" name="userRole" value="<xss:encodeForHTMLAttribute><%=userName%></xss:encodeForHTMLAttribute>"/>
            <input type="hidden" name='<%="personid"+i%>' value="<xss:encodeForHTMLAttribute><%=userName%></xss:encodeForHTMLAttribute>"/>
<%
      }
%>
          </td>
          <td><%=XSSUtil.encodeForHTML(context,sDisplayTargetName)%></td>
<%
          boolean showLabel = false;
          boolean isOwner = false;
          if("Role".equals(sTargetType) || "Group".equals(sTargetType))
          {
            showLabel = true;
          }else if(userName.equals(sUser)){
             isOwner = true;
          }
          if ("Role".equals(sTargetType))
             sTargetType=i18nNow.getI18nString("emxComponents.Common.Role","emxComponentsStringResource",
                                              request.getHeader("Accept-Language"));
          else if ("Group".equals(sTargetType))
             sTargetType=i18nNow.getI18nString("emxComponents.Common.Group","emxComponentsStringResource",
                                              request.getHeader("Accept-Language"));
          else
             sTargetType=i18nNow.getTypeI18NString(sTargetType, request.getHeader("Accept-Language"));

%>
    <td><%=XSSUtil.encodeForHTML(context, sTargetType)%>&nbsp;</td>
    <td><%=XSSUtil.encodeForHTML(context,sTargetOrganization)%>&nbsp;</td>
<%
	if(!selscope.equals("ScopeName"))
    {
%>
    <td><emxUtil:i18n localize="i18nId">emxComponents.Common.<%=XSSUtil.encodeForHTML(context, selscope)%></emxUtil:i18n>&nbsp;</td>
<%
	}
	else
    {
%>
    <td><%=XSSUtil.encodeForHTML(context, selscope)%>&nbsp;</td>
<%
    }
%>
    <td>
<%
    if(!showLabel && !isOwner)
    {
            if(sAccess.equals("Read")) {
              sReadSelected="selected";
            } else if(sAccess.equals("Read Write")) {
              sReadWriteSelected="selected";
            } else if(sAccess.equals("Add")) {
              sAddSelected="selected";
            } else if(sAccess.equals("Remove")) {
              sRemoveSelected="selected";
            } else if (sAccess.equals("Add Remove")) {
              sAddRemoveSelected="selected";
            }
%>
            <input type="hidden" name="<%="access"+i%>" value="<xss:encodeForHTMLAttribute><%=sAccess%></xss:encodeForHTMLAttribute>" />

            <select name=<%="selAccess"+i%> style="font-size:8pt" onChange="ChangeAccess(<%=i%>)">
              <!-- //XSSOK -->
              <option value="Read" <%=sReadSelected%> ><emxUtil:i18n localize="i18nId">emxComponents.Access.Read</emxUtil:i18n></option>
              <!-- //XSSOK -->
              <option value="Read Write" <%=sReadWriteSelected%> ><emxUtil:i18n localize="i18nId">emxComponents.Access.ReadWrite</emxUtil:i18n></option>
              <!-- //XSSOK -->
              <option value="Add" <%=sAddSelected%> ><emxUtil:i18n localize="i18nId">emxComponents.Access.Add</emxUtil:i18n></option>
              <!-- //XSSOK -->
              <option value="Remove" <%=sRemoveSelected%> ><emxUtil:i18n localize="i18nId">emxComponents.Access.Remove</emxUtil:i18n></option>
              <!-- //XSSOK -->
              <option value="Add Remove" <%=sAddRemoveSelected%> ><emxUtil:i18n localize="i18nId">emxComponents.Access.AddRemove</emxUtil:i18n></option>
            </select>
<%
    }else if(showLabel){
%><!-- //XSSOK -->
        <input type="hidden" name='<%="access"+i%>' value="<%=sAccess%>" />
        <input type="hidden" name='<%="selAccess"+i%>' value="Read" />
        <emxUtil:i18n localize="i18nId">emxComponents.Access.Read</emxUtil:i18n>
<%
      }else if(isOwner){
%><!-- //XSSOK -->
        <input type="hidden" name='<%="access"+i%>' value="<%=sAccess%>" />
        <input type="hidden" name='<%="selAccess"+i%>' value="Read" />
        <emxUtil:i18n localize="i18nId">emxComponents.Access.AddRemove</emxUtil:i18n>
<%
    }
%>
        </td>
    </tr>
<%
        sAccess            = "";
        sReadSelected      = "";
        sReadWriteSelected = "";
        sAddSelected       = "";
        sRemoveSelected    = "";
        sAddRemoveSelected = "";
        i++;
        memberList.addElement(userName);
     }
%>
   </framework:mapListItr>
</framework:ifExpr>   	
</table>
  <input type="hidden" name='count' value="<%=i%>" />
  <input type="hidden" name="routeId"    value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="objectId"   value="<xss:encodeForHTMLAttribute><%=relatedObjectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=templateName%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="toAccessPage" value="<xss:encodeForHTMLAttribute><%=toAccessPage%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="selRoles"   value=""/>
  <input type="hidden" name="selGroup"   value=""/>
  <input type="hidden" name="scopeId" value="<xss:encodeForHTMLAttribute><%=scopeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="selectedAction" value="<xss:encodeForHTMLAttribute><%=routeAction%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="supplierOrgId" value="<xss:encodeForHTMLAttribute><%=supplierOrgId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />

</form>
	<script>
		//add by tangfan 2015.4.20
		submitForm();
	</script>
<%@ include file = "../emxUICommonEndOfPageInclude.inc" %>
