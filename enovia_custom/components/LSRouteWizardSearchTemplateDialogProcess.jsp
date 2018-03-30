<%-- emxRouteWizardSearchTemplateDialog.jsp --

  Copyright (c) 1992-2011 Dassault Systemes.All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteWizardSearchTemplateDialog.jsp.rca 1.15 Wed Oct 22 16:17:54 2008 przemek Experimental przemek $
--%>


<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<script language="javascript">
<%
   try {
   
		String strTableRowId = "";
		StringList slTokens = null;
		String strRouteTempId = null;
		String strObjLevel = null;		
		String strParentObjectId = null;
		String strMessage = "";
		
		String strLanguage = request.getHeader("Accept-Language");
		String notificationSub = ComponentsUtil.i18nStringNow("emxComponents.DeleteRoute.DeleteNotification", strLanguage);
		
        // Get request parameters. Selected objects and onsubmit function	
		String[] strEmxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
		String strOnSubmitCallback = emxGetParameter(request, "onSubmit");
		String srtOriRouteId = emxGetParameter(request, "strOriRouteId");
		String strConnObjId = emxGetParameter(request, "srtConnectedObjId");
		
		// If there are not objects selected

		if (strEmxTableRowIds == null || strEmxTableRowIds.length == 0) {
		    throw new Exception(getI18NString("emxComponentsStringResource", "emxComponents.Common.PleaseMakeASelection", strLanguage));
		}
		
		// If onSubmit parameter is not passed
		if (strOnSubmitCallback == null || "".equals(strOnSubmitCallback.trim())) {
		    throw new Exception("No onSubmit callback function provided.");                
		}
		
		for (int i = 0; i < strEmxTableRowIds.length; i++) {
		    strTableRowId = strEmxTableRowIds[i];
			if (strTableRowId == null || strTableRowId.length() == 0) {
		        continue;
		    }
			
			slTokens = split(strTableRowId, "|");
			
			strParentObjectId = (String)slTokens.get(0);
			strRouteTempId = (String)slTokens.get(1);

			strObjLevel = (String)slTokens.get(3);
			
			if(strRouteTempId != null && !"".equals(strRouteTempId) && srtOriRouteId != null && !"".equals(srtOriRouteId)){
				//edit by heyanbo 2012-12-16
				DomainObject routeTempObject = DomainObject.newInstance(context,strRouteTempId);
				DomainObject routeObject = DomainObject.newInstance(context,srtOriRouteId);
				DomainObject domObject = DomainObject.newInstance(context,strConnObjId);
				
				String strRrouteStateBaseName = routeObject.getInfo(context,"to[Object Route].attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_STATE+"]");
				
				ContextUtil.startTransaction(context, true);
				boolean flag = true;				
				
				//edit by heyanbo 2012-12-16
				
				StringList busSel = new StringList();
				busSel.add("attribute[Route Status]");
				busSel.add("id");
				String strPolicyName =   domObject.getPolicy(context).getName();
				//String symbolicStateName = FrameworkUtil.reverseLookupStateName(context, strPolicyName, strStateName);
				
				String args [] = new String[]{strConnObjId,strRrouteStateBaseName,strRouteTempId};
				
				String where = "relationship[Object Route].attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_STATE+"]=='"+strRrouteStateBaseName+"'";
				MapList mlRoute = domObject.getRelatedObjects(context,
															"Object Route",
															"Route", 
															busSel, 
															null,
															false,
															true, 
															(short)1, 
															where, 
															null);
				if(mlRoute != null && mlRoute.size()>0){
					for(int j = 0;j<mlRoute.size() ; j++)
					{
						Map tempMap = (Map)mlRoute.get(j);
						String attrRouteState = (String)tempMap.get("attribute[Route Status]");
						if(attrRouteState.equals("Started"))
						{
							flag = false;
							String msg = i18nNow.getI18nString("ENVISION.AddApproverTaskFromTemplate.HaveStartedRoute.Msg", "emxEngineeringCentralStringResource", strLanguage);
							String strStateMsg = i18nNow.getStateI18NString(strPolicyName, strRrouteStateBaseName, strLanguage);
							strMessage = strStateMsg+msg;
							break;
						}else if(!attrRouteState.equals("Finished")){
							String routeObjeId = (String)tempMap.get("id");
							Route routeObj = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
							routeObj.setId(routeObjeId);
							String i18nType = i18nNow.getAdminI18NString("Type", routeObj.getType(context), strLanguage);
							StringBuffer buffer = new StringBuffer(50);
							buffer.append(i18nType).append(" ").append(routeObj.getName(context)).append(" ").append(notificationSub);
							routeObj.deleteRoute(context, "","");
						}
					}
					if(flag){
						JPO.invoke(context, "ENVTypeCreateRouteUtil", new String[]{}, "CreateRoutes", args);
					}
				}else{
					JPO.invoke(context, "ENVTypeCreateRouteUtil", new String[]{}, "CreateRoutes", args);
				}
		
				if(flag){
					ContextUtil.commitTransaction(context);
				}else{
					ContextUtil.abortTransaction(context);
				}
			  //edit by heyanbo 2012-12-16
			}
		}
%>
		// Call the onSubmit function 
		if (true) {
		
			<%=strOnSubmitCallback%>();
		
			top.close();
		}
		else {
			alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.Common.AutonomySearch</emxUtil:i18nScript> <%=strOnSubmitCallback%>");
		}	
	
<%
	} catch (Exception ex) {
		ex.printStackTrace();
		String strExpMsg = ex.getMessage();
		if (strExpMsg != null && strExpMsg.length() != 0) {
			emxNavErrorObject.addMessage(strExpMsg);
		}
		else {
			emxNavErrorObject.addMessage(ex.toString());
		}
    } finally {
        // Add cleanup statements if required like object close, cleanup session, etc.
    }

%>
</script>
<%@include file="../emxUICommonHeaderEndInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

<%!
	private static StringList split(String strValue, String strDelimiter) throws Exception {
	    if (strValue == null) {
	        throw new Exception("Null strValue");
	    }
	    
	    if (strDelimiter == null) {
	        throw new Exception("Null strDelimiter");
	    }
	    
	    StringList slTokens = new StringList();
	    String strTempValue = strValue;
	    int nLengthOfDelimiter = strDelimiter.length();
	    int nIndex = 0;
	    boolean isFinished = false;
	    
	    while (!isFinished) {
		    nIndex = strTempValue.indexOf(strDelimiter);
		    if (nIndex == -1) {
		        slTokens.add(strTempValue);
		        isFinished = true;
		    }
		    else {
		        slTokens.add(strTempValue.substring(0, nIndex));
		        strTempValue = strTempValue.substring(nIndex+nLengthOfDelimiter);
		    }
	    }
	    
	    return slTokens;
	}

%>