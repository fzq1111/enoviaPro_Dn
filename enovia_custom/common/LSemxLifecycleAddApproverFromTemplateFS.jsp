<%--  LSemxLifecycleAddApproverFromTemplateFS.jsp  -   FS page for emxLifecycleAddApproverFromTemplate

   Copyright (c) 1992-2012 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleAddApproverFromTemplateFS.jsp.rca 1.6.3.2 Wed Oct 22 15:49:02 2008 przemek Experimental przemek $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.DomainObject"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  
  
 
  
  String suiteKey     = emxGetParameter(request,"suiteKey");

  fs.setDirectory(appDirectory);


  String objectId = emxGetParameter(request, "objectId");
  // Specify URL to come in middle of frameset
  String contentURL = "LSemxLifecycleAddApproverFromTemplate.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&objectId=" + objectId;

  fs.setStringResourceFile("emxFrameworkStringResource");

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.Heading.AddApproverFromTemplate";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emshelpaddapproverroutetemplate";
  
  String strLanguage = request.getHeader("Accept-Language");
  String strPageSubHeading = UINavigatorUtil.getI18nString(
			"emxFramework.SubHeading.TypeNameRevisionState",
			"emxFrameworkStringResource", strLanguage);
	//
	// Process subtitle's place holder macros
	//
	DomainObject domainObject = new DomainObject(objectId);
	StringList slBusSelect = new StringList();
	slBusSelect.add(DomainObject.SELECT_TYPE);
	slBusSelect.add(DomainObject.SELECT_NAME);
	slBusSelect.add(DomainObject.SELECT_REVISION);
	slBusSelect.add(DomainObject.SELECT_CURRENT);
	slBusSelect.add(DomainObject.SELECT_POLICY);

	Map mapObjectInfo = domainObject.getInfo(context, slBusSelect);

	String strType = (String) mapObjectInfo
			.get(DomainObject.SELECT_TYPE);
	String strName = (String) mapObjectInfo
			.get(DomainObject.SELECT_NAME);
	String strRevision = (String) mapObjectInfo
			.get(DomainObject.SELECT_REVISION);
	String strState = (String) mapObjectInfo
			.get(DomainObject.SELECT_CURRENT);
	String strPolicy = (String) mapObjectInfo
			.get(DomainObject.SELECT_POLICY);

	strType = i18nNow.getTypeI18NString(strType, strLanguage);
	strState = i18nNow.getStateI18NString(strPolicy, strState, strLanguage);

	strPageSubHeading = FrameworkUtil.findAndReplace(strPageSubHeading,
			"$<type>", strType);
	strPageSubHeading = FrameworkUtil.findAndReplace(strPageSubHeading,
			"$<name>", strName);
	strPageSubHeading = FrameworkUtil.findAndReplace(strPageSubHeading,
			"$<revision>", strRevision);
	strPageSubHeading = FrameworkUtil.findAndReplace(strPageSubHeading,
			"$<current>", strState);

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false, 4, strPageSubHeading);


  fs.createFooterLink("emxFramework.Lifecycle.Done",
			          "submitForm()",
			          "role_GlobalUser",
			          false,
			          true,
			          "common/images/buttonDialogDone.gif",
			          3);
  
  fs.createFooterLink("emxFramework.Lifecycle.Cancel",
                      "top.close()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
