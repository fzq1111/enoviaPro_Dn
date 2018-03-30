<%--  LSemxLifecycleAddApproverFromTemplateProcess.jsp   -   Process page for Add Approver From Template functionality

   Copyright (c) 1992-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleAddApproverFromTemplateProcess.jsp.rca 1.3.3.2 Wed Oct 22 15:48:32 2008 przemek Experimental przemek $
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@page import=" com.matrixone.apps.common.*" %>
<%@include file="../emxUICommonHeaderEndInclude.inc"%>
<%@ page import = "org.apache.log4j.Logger"%>

<%
	Logger myLogger = Logger.getLogger(LSemxLifecycleAddApproverFromTemplateProcess_jsp.class);
    String strObjectId 			= emxGetParameter(request, "objectId");
    String[] strStateNewRoutes 	= emxGetParameterValues(request, "stateNewRoute");
    StringList slSplitedStrings = null;
    String strLanguage = request.getHeader("Accept-Language");
	String strMessage = "";
    try {
		
        //strStateNewRoutes = {StateName|RouteTemplateId, StateName|RouteTemplateId, StateName|RouteTemplateId}
        if(strStateNewRoutes != null){
        	//edit by heyanbo 2013-4-18
	    	DomainObject domObject = DomainObject.newInstance(context,strObjectId);
	    	StringList selObjectList = new StringList();
	    	selObjectList.addElement("id");
	    	selObjectList.addElement("name");
	    	selObjectList.addElement("attribute[Route Status]");
	    	StringList selRelList = new StringList();
	    	selRelList.addElement(DomainObject.SELECT_RELATIONSHIP_ID);
	    	selRelList.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_STATE+"]");
	    	selRelList.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_POLICY+"]");
	    	//edit by heyanbo end 2013-4-18
	        ContextUtil.startTransaction(context, true);
			boolean flag = true;
	        for (int i = 0; i < strStateNewRoutes.length; i++) {
	        	// StateName|RouteTemplateId
	            slSplitedStrings = FrameworkUtil.split(strStateNewRoutes[i], "|");
	            
		        String strStateName 		= (String)slSplitedStrings.get(0); //Get the state name
	    	    String strRouteTemplateId 	= (String)slSplitedStrings.get(1); //Get the Route Template Id
	    	  	
	    	    //edit by heyanbo 2013-4-18
	    	  //Lifecycle lifecycle = new Lifecycle();
	    	  //lifecycle.addApproverTaskFromTemplate(context, strObjectId, strStateName, strRouteTemplateId);
	    	  
	    	  	String strPolicyName =   domObject.getPolicy(context).getName();
	    	    String symbolicStateName = FrameworkUtil.reverseLookupStateName(context, strPolicyName, strStateName);
	    	    
	    	    String args [] = new String[]{strObjectId,symbolicStateName,strRouteTemplateId};
	    	    
	    	    String where = "relationship[Object Route].attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_STATE+"]=='"+symbolicStateName+"'";
	    	    MapList mlRoute = domObject.getRelatedObjects(context,
	    	    											"Object Route",
	    	    											"Route", 
	    	    											selObjectList, 
	    	    											selRelList,
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
	    	    			String msg = i18nNow.getI18nString("LS.AddApproverTaskFromTemplate.HaveStartedRoute.Msg", "emxFrameworkStringResource", strLanguage);
	    	    			String strStateMsg = i18nNow.getStateI18NString(strPolicyName, strStateName, strLanguage);
	    	    			strMessage = strStateMsg+msg;
	    	    			break;
	    	    		}else if(!attrRouteState.equals("Finished")){
	    	    			String routeObjeId = (String)tempMap.get("id");
	    	    			Route routeObj = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
	    	    			routeObj.setId(routeObjeId);
	    	    			String i18nType = i18nNow.getAdminI18NString("Type", routeObj.getType(context), strLanguage);
	    	    			/* StringBuffer buffer = new StringBuffer(50);
	    	                buffer.append(i18nType).append(" ").append(routeObj.getName(context)).append(" ").append(notificationSub); */
	    	    			routeObj.deleteRoute(context, "","");
	    	    		}
	    	    	}
	    	    	if(flag){
		    	    	JPO.invoke(context, "LSCreateRouteUtil", new String[]{}, "CreateRoutes", args);
		    	    }else{
		    	    	break;
		    	    }
	    	    }else{
		    	    JPO.invoke(context, "LSCreateRouteUtil", new String[]{}, "CreateRoutes", args);
	    	    }
	    	    
	        }
	        if(flag){
		    	ContextUtil.commitTransaction(context);
	        }else{
	        	ContextUtil.abortTransaction(context);
	        }
	      //edit by heyanbo 2013-4-18
        }
    } catch (Exception ex) {
    	ContextUtil.abortTransaction(context);
        emxNavErrorObject.addMessage(ex.toString());
        myLogger.error(ex.getMessage(), ex);
    }
 
    %>        
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>

	        <script language="JavaScript">
	        <!--
	        	var strMsg = '<%=strMessage%>';
	        	if(strMsg != "")
	        	{
	        		alert(strMsg);
	        	}
	            top.opener.parent.location.href = top.opener.parent.location.href;
	            window.top.close();
	        //-->
	    	</script> 
