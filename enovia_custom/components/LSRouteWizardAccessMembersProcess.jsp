<%--  emxRouteWizardAccessMembersProcess.jsp  --  Comnnecting Members to Route
  Copyright (c) 1992-2015 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $: Exp $

 --%>

  <%@include file = "../emxUICommonAppInclude.inc"%>
  <%@ include file = "emxRouteInclude.inc" %>

  <jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

  <%

  String keyValue=emxGetParameter(request,"keyValue");
  formBean.processForm(session,request,"keyValue");

  String projectId  =  (String)formBean.getElementValue("objectId");
  String templateId       =  (String) formBean.getElementValue("templateId");
  String count          =  (String) formBean.getElementValue("count");
  String templateName     =  (String) formBean.getElementValue("templateName");
  String routeId          =  (String) formBean.getElementValue("routeId");

  // flag to find if user coming back from step 4 to 3
  String toAccessPage   = emxGetParameter(request,"toAccessPage");
  String[] personID     = emxGetParameterValues(request, "chkItem1");

  String strProjectVaultType = PropertyUtil.getSchemaProperty(context, "type_ProjectVault");
  String strDocumentType     = PropertyUtil.getSchemaProperty(context, "type_Document");
  String relVaultedDocuments = PropertyUtil.getSchemaProperty(context, "relationship_VaultedDocuments");
  String relProjectVaults    = PropertyUtil.getSchemaProperty(context, "relationship_ProjectVaults");
  String relRouteNode        = PropertyUtil.getSchemaProperty(context, "relationship_RouteNode");

  RelationshipType relTypeRouteNode = null;
  AccessUtil accessUtil             = new AccessUtil();
  BusinessObject personToAdd        = null;
  BusinessObject routeObj           = null;
  String personId                   = "";
  String sOldAccess                 = "";
  String sAccess                    = "";
  String sPersonName                = "";
  String sTypePassed                = null;
  String sProjectId                 = null;

  String changedAccess  =  (String)formBean.getElementValue("changedAccess");
  String accessSelected       =  (String) formBean.getElementValue("accessSelected");
  String changedAccessPage       =  (String) formBean.getElementValue("changedAccessPage");

  if(changedAccessPage == null){
	  changedAccessPage = "";
  }


  if("changedAccessPage".equals(changedAccessPage))
  {


      MapList routeMemberMapList = (MapList)formBean.getElementValue("routeMemberMapList");
      Map changedMap=(Map)routeMemberMapList.get(Integer.parseInt(changedAccess));
      changedMap.remove("access");
      changedMap.put("access",accessSelected);
      formBean.setElementValue("routeMemberMapList",routeMemberMapList);
      formBean.setFormValues(session);
      formBean.removeElement("changedAccessPage");

	 %>
	 <script language="javascript">
	   parent.location.href=parent.location.href;
	 </script>
	<%
  }

%>
<html>
<body>
<form name="newForm" target="_parent">
  <input type="hidden" name="objectId"   value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="routeId"    value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=templateName%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="fromPage" value="<xss:encodeForHTMLAttribute><%="AccessMembersProcess"%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="toAccessPage" value="<xss:encodeForHTMLAttribute><%=toAccessPage%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>"/>
  <!-- begin  add by  tangfan 2015.4.20-->
   <input type="hidden" name="baseState" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"baseState")%></xss:encodeForHTMLAttribute>"/>
   <!--end  add by  tangfan 2015.4.20-->
   
</form>

<script language="javascript">

<%

 if(!"changedAccessPage".equals(changedAccessPage)){
%>
	   document.newForm.action = "LSRouteWizardAssignTaskFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>";
  	   document.newForm.submit();
<%
 }
%>


</script>
</html>
</body>

