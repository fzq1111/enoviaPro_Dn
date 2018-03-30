<%--  emxComponentsAddMeetingAttendees.jsp  --  Process page for the add attendees to the meeting

  Copyright (c) 1992-2015 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] =  $Id: emxComponentsAddMeetingAttendees.jsp.rca 1.1 Wed Nov 26 11:27:59 2008 ds-lmanukonda Experimental $
 --%>
 <%@include file = "../emxUICommonAppInclude.inc"%>
 <%@page import="java.util.* "%>
<%@page import="matrix.util.* "%>
<%@page import="matrix.db.*"%>
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.apps.common.Person"%>
<%@page import="com.matrixone.apps.common.Company"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
 <%
  
 boolean openSearchWindow =  "openAttendeeSearchWindow".equalsIgnoreCase(emxGetParameter(request, "commandAction"));
 String searchURL = null;
 if(openSearchWindow) {
     String strUserName = context.getUser();
     Person personObj =      Person.getPerson(context, strUserName);
     Company company = personObj.getCompany(context);
     String compName = company.getName();
     String hostCompanyName = PropertyUtil.getSchemaProperty(context, "role_CompanyName");
     StringBuffer buffer = new StringBuffer();
     Map map = new HashMap(2);
	 map.put("table","PMCCommonPersonSearchTable");
     map.put("submitURL", "../components/emxComponentsAddMeetingAttendees.jsp");
     if(!compName.equals(hostCompanyName)) {
    	map.put("field", "TYPES=type_Person:CURRENT=policy_Person.state_Active:MEMBER=" + compName);
     }
     buffer.append(com.matrixone.apps.common.util.ComponentsUIUtil.getPersonSearchFTSURL(map)); 
	 buffer.append("&header=emxComponents.Common.SelectPerson");
	 buffer.append("&includeOIDprogram=emxMeeting:includeMeetingPerson");

	 Enumeration eNumParameters = emxGetParameterNames(request);
	 while( eNumParameters.hasMoreElements() ) {
	 	String strParamName = (String)eNumParameters.nextElement();
	 	
	 	if(strParamName.equals("commandAction"))
	 	    continue;
	 	
	 	buffer.append('&').append(strParamName).append('=').append(emxGetParameter(request, strParamName));
	 }
	 searchURL = buffer.toString();
 } else {
 %>
 <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
 <%
     String strMeetingId             = emxGetParameter(request, "objectId");
     String strMemberIds[]  = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));
     com.matrixone.apps.common.Meeting busobj = new com.matrixone.apps.common.Meeting(strMeetingId);
     busobj.addAttendees(context, strMemberIds);
 }
 if(openSearchWindow) {
 %>
 <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
 <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
 <script language="javascript" src="../common/scripts/emxUICore.js"></script>
 <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
 	<script language="javascript">
		showModalDialog('<%=XSSUtil.encodeForJavaScript(context, searchURL)%>');
	</script>	
<%
 }
 if(!openSearchWindow){
%> 
<html>
<head>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
</head>
<body>
	<script language="javascript">
		 var frameToRefresh = getTopWindow().findFrame(getTopWindow().getWindowOpener().parent, "detailsDisplay");
		 frameToRefresh.location.href = frameToRefresh.location.href; 
  		 getTopWindow().closeWindow();
  	</script>
 </body>
 </html> 		 
<%}%>
 

