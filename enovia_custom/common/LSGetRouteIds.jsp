<%--  emxLifecycleAddApproverFS.jsp   -   <description>

   Copyright (c) 1992-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: ENVemxGetRouteIds.jsp 1.6.3.2 Wed Oct 22 15:47:58 2008 przemek Experimental przemek $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.DomainObject"%>

<%

	String initSource = emxGetParameter(request,"initSource");
	if (initSource == null){
	  initSource = "";
	}
	boolean showWindow = true;
	  
	String objectId = emxGetParameter(request, "objectId");
	String timeStamp = emxGetParameter(request,"timeStamp");
	String portalMode =  emxGetParameter(request,"portalMode");
	String relId = emxGetParameter(request,"relId");
	String portalCmdName =  emxGetParameter(request,"portalCmdName");
	String objectName = emxGetParameter(request,"objectName");
	String parentOID = emxGetParameter(request,"parentOID");
	String suiteKey     = emxGetParameter(request,"suiteKey");
	String targetLocation = emxGetParameter(request,"targetLocation");
	if(targetLocation == null || targetLocation.equals("") || targetLocation.equals("null")){
		targetLocation = "popup";
	}
	if(!targetLocation.equalsIgnoreCase("popup")){
		showWindow = false;
	}
	
	String routeObjectIDS="";
	
	String emxTableRowId [] = emxGetParameterValues(request, "emxTableRowId");
	if(emxTableRowId != null && emxTableRowId.length>0){
		for(int i=0;i < emxTableRowId.length;i++){
			try{
				String strObjType = MqlUtil.mqlCommand(context, "print bus "+emxTableRowId[i] +" select type dump |");
				if(strObjType.trim().equals(DomainObject.TYPE_ROUTE)){
					routeObjectIDS+=emxTableRowId[i]+"~";
				}
			}catch(Exception e){
				continue;
			}
		}
	}else{
		StringList routeSelect = new StringList();
		routeSelect.addElement(DomainObject.SELECT_ID);
		DomainObject domObject  = new DomainObject(objectId);
		String strType = domObject.getTypeName();
		if(strType != null && strType.equals(DomainObject.TYPE_ROUTE)){
			routeObjectIDS = objectId;
		
		}else{
			MapList routeMapList = domObject.getRelatedObjects(context,
										DomainObject.RELATIONSHIP_OBJECT_ROUTE,
										DomainObject.TYPE_ROUTE, 
										routeSelect, 
										null, 
										false, 
										true,
										(short)1,
										null,
										null);
			if(routeMapList != null && routeMapList.size()>0){
				String strRouteId = "";
				for(int i=0;i<routeMapList.size();i++){
					Map routeMap = (Map)routeMapList.get(i);
					strRouteId = (String)routeMap.get(DomainObject.SELECT_ID);
					routeObjectIDS += strRouteId+"~";
				}
			}
		}
	}
	
   	if(routeObjectIDS.length()>0 && (routeObjectIDS.lastIndexOf("~") == routeObjectIDS.length()-1))
   	{
 	  routeObjectIDS = routeObjectIDS.substring(0, routeObjectIDS.length()-1);
   	}
	StringBuffer strURL = new StringBuffer();
	strURL.append("../common/LSTaskAppointedParticipantsDialogFS.jsp?");
	strURL.append("objectId="+objectId);
	strURL.append("&timeStamp="+timeStamp);
	strURL.append("&relId="+relId);
	strURL.append("&parentOID="+parentOID);
	strURL.append("&suiteKey="+suiteKey);
	strURL.append("&routeObjectIDS="+routeObjectIDS);
	String forwardURL = strURL.toString();
%>

<script type = "text/javascript">
	var openWindow = "<%=showWindow%>";
	if(openWindow=="true"){
		document.location.href="<%=forwardURL%>";
	}else{
		top.showModalDialog("<%=forwardURL%>",800,900,true);
	}
</script>