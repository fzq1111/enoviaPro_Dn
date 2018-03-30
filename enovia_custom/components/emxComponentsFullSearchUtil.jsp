<%--
  FullSearchUtil.jsp
  Copyright (c) 1993-2015 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../common/emxCompCommonUtilAppInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import="matrix.db.Context"%> 
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
	boolean bIsError = false;
    String typeAhead = emxGetParameter(request, "typeAhead");
    String frameName = emxGetParameter(request, "frameName");

    /* modifications for UI Adoption vh5 */

    String fromPage  = emxGetParameter(request, "fromPage");

	  if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(fromPage))
	  {
	      fromPage="";
	  }

    if(fromPage.equals("routeWizard"))
    {
    	String autoStopOnRejection = "";
    	String strRowId[] = request.getParameterValues("emxTableRowId");
    	strRowId  = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(strRowId);
    	String strSelectScope = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CreateRoute.SelectScope");
		String selObjId = strRowId[0];
    	DomainObject selObject = new DomainObject(selObjId);
    	String selObjName = selObject.getInfo(context, DomainConstants.SELECT_NAME);
    	String description = selObject.getInfo(context, DomainConstants.SELECT_DESCRIPTION);
    	description = description.replace("\r","\\r").replace("\n","\\n");
    	String sAttrRouteAutoStopOnRejection=PropertyUtil.getSchemaProperty(context, "attribute_AutoStopOnRejection");
		String SELECT_ROUTE_AUTO_STOP_ON_REJECTION = DomainObject.getAttributeSelect(sAttrRouteAutoStopOnRejection);
		autoStopOnRejection = selObject.getInfo(context, SELECT_ROUTE_AUTO_STOP_ON_REJECTION);
    	//get the route base purpose
    	String sAttrRouteBasePurpose = Framework.getPropertyValue( session, "attribute_RouteBasePurpose" );
    	String routeBasePurpose = selObject.getInfo(context,selObject.getAttributeSelect(sAttrRouteBasePurpose));
    	HashMap routeTemplateScopeMap = (HashMap) JPO.invoke(context, "emxRouteTemplate", null, "getRouteTemplateScopeInfo", JPO.packArgs(selObjId), HashMap.class);
    	String scopeType = (String) routeTemplateScopeMap.get("scopeType");
    	String scopeName = "";
    	String scopeID = "";
    	scopeName = (String) routeTemplateScopeMap.get("scopeName");
    	if(routeTemplateScopeMap.containsKey("scopeID")){
    		scopeID = (String) routeTemplateScopeMap.get("scopeID");
    	}

        %>

    <script language="javascript">

        var form = getTopWindow().getWindowOpener().document.forms[0];
        if (form) {
            if (form.templateName) {
                form.templateName.value="<%=XSSUtil.encodeForJavaScript(context, selObjName)%>";
            }
            if (form.template) {
                form.template.value="<%=XSSUtil.encodeForJavaScript(context, selObjName)%>";
            }
            if (form.templateId) {
                form.templateId.value="<%=XSSUtil.encodeForJavaScript(context, selObjId)%>";
            }
            if(form.txtdescription)
            {
            	form.txtdescription.value="<%=XSSUtil.encodeForJavaScript(context, description)%>";
            }
            if(form.routeBasePurpose)
            {
                form.routeBasePurpose.value="<%=XSSUtil.encodeForJavaScript(context, routeBasePurpose)%>";
            }
            if(form.routeAutoStop){
            	 form.routeAutoStop.value="<%=XSSUtil.encodeForJavaScript(context, autoStopOnRejection)%>";
            }
            var routeTemplateScopes = getTopWindow().getWindowOpener().document.getElementsByName("selscope");
            var scopeName = "<%=XSSUtil.encodeForJavaScript(context, scopeName)%>";
            var scopeID = "<%=XSSUtil.encodeForJavaScript(context, scopeID)%>";
            if(routeTemplateScopes){
            	if(form.workspaceFolder && form.workspaceFolder.type != "hidden"){
            		form.workspaceFolder.value = "<%=XSSUtil.encodeForJavaScript(context, strSelectScope)%>";
            		if(form.workspaceFolderId){
            			form.workspaceFolderId.value = "";
            		}
            	}
        		if(form.btnScope){
        			form.btnScope.disabled = false;
     		    }
            	if(scopeName == "All"){
            		routeTemplateScopes[0].checked = true;
            		form.routeTemplateScope.value = "All";
            	}else if(scopeName == "Organization"){
            		routeTemplateScopes[1].checked = true;
            		form.routeTemplateScope.value = "Organization";
            	}else{
            		routeTemplateScopes[2].checked = true;
            		if(form.workspaceFolder && form.workspaceFolder.type != "hidden"){
            			form.workspaceFolder.value = scopeName;
            			if(form.workspaceFolderId){
            				form.workspaceFolderId.value = scopeID;
            			}
            			if(form.routeTemplateScope){
            				form.routeTemplateScope.value = scopeName;
            			}
            		}
            	}
            	if(form.btnScope){
     			   form.btnScope.disabled = true;
     		   }
            }

        }
        getTopWindow().close();
        </script>
   <%
    }
    /* mod ends vh5*/

    else{
	try
	{
		String strMode = emxGetParameter(request,"mode");
		String strObjId = emxGetParameter(request, "objectId");
		DomainObject meetObj = new DomainObject(strObjId);
		String meetType = meetObj.getType(context);
		if("SEM Contact Order".equals(meetType)){
			StringList busList = new StringList("id");
			StringList relList = new StringList(DomainRelationship.SELECT_ID);
			MapList resList = meetObj.getRelatedObjects(context, "SEM Meeting ContactOrder", "Meeting", busList, relList, true, false, (short)1, null, null);
			for(int i = 0; i < resList.size(); i ++)
			{
				Map resMap = (Map)resList.get(i);
				strObjId = (String)resMap.get("id");
			}
		}
		String strRelName = request.getParameter("relName");
		String strDirection = request.getParameter("direction");
		String strRowId[] = request.getParameterValues("emxTableRowId");

		// Convert any internal relationship name to its display format:
		if (strRelName != null)
		{
			strRelName = PropertyUtil.getSchemaProperty(context, strRelName);
		}

		if (strRowId == null)
		{   
			%>
				<script language="javascript" type="text/javaScript">
					alert("<emxUtil:i18n localize='i18nId'>emxFramework.IconMail.FindResults.AlertMsg1</emxUtil:i18n>");
				</script>
			<%
		}
		else
		{
			if (strMode.equalsIgnoreCase("Connect"))
			{
				boolean preserve = false;  // to update the modified date on the root obj
				for (int i = 0; i < strRowId.length; i++)
				{
					String selObjId = strRowId[i].split("[|]")[1];

					if ("to".equalsIgnoreCase(strDirection))
					{
						// Create the named relationship to the selected obj from the root obj:
						DomainRelationship.connect(context, selObjId, strRelName, strObjId, preserve);
					}
					else
					{
						// Create the named relationship to the root obj from the selected obj:
						DomainRelationship.connect(context, strObjId, strRelName, selObjId, preserve);
					}
				}
				%>
					<script language="javascript" type="text/javaScript">
						window.parent.getTopWindow().getWindowOpener().location.href = window.parent.getTopWindow().getWindowOpener().location.href;
						getTopWindow().closeWindow();
					</script>
				<%
			}
			
			// Start:OEP:V6R2010:BUG 372490
			// Handled the Chooser condition for RangeHref passing from WebForm for Owner Field.
			String strSearchMode = emxGetParameter(request, "chooserType");
            String fieldNameActual = emxGetParameter(request, "fieldNameActual");
            String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
            
			if (strMode.equalsIgnoreCase("Chooser"))
            {
	            // When choosing a person, use the name/fullname instead...
			        if (strSearchMode.equals("PersonChooser"))
			        {
		            String fieldNameOID = emxGetParameter(request, "fieldNameOID");
		
		            // For most webform choosers, default to the object id/name...
		            String selObjId = strRowId[0].split("[|]")[1];
		            String strObjID = selObjId;
		            DomainObject selObject = new DomainObject(selObjId);
		            String selObjName = selObject.getInfo(context, DomainConstants.SELECT_NAME);
		
		            selObjId = selObjName;
		            selObjName = PersonUtil.getFullName(context, selObjName);
		            
				    %>
				    <script language="javascript" type="text/javaScript">
				    var typeAhead = "<%=XSSUtil.encodeForJavaScript(context, typeAhead)%>";
					var targetWindow = null;
					if(typeAhead == "true")	{
						var frameName = "<%=XSSUtil.encodeForJavaScript(context, frameName)%>";
						if(frameName == null || frameName == "null" || frameName == "") {
							targetWindow = window.parent;
						} else {
							targetWindow = getTopWindow().findFrame(window.parent, frameName);
						}
					} else	{
							targetWindow = getTopWindow().getWindowOpener();
					}
					var tmpFieldNameOID = "<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>" + "OID";				    
				   var vfieldNameActual = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>");
				   var vfieldNameDisplay = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>");
				   var vfieldNameOID = targetWindow.document.getElementsByName(tmpFieldNameOID);
				   
                   vfieldNameActual = vfieldNameActual == null ? targetWindow.document.forms[0]["<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>"] : vfieldNameActual;
                   vfieldNameDisplay = vfieldNameDisplay == null ? targetWindow.document.forms[0]["<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>"] : vfieldNameDisplay;
                   vfieldNameOID = vfieldNameOID == null ? targetWindow.document.forms[0][tmpFieldNameOID] : vfieldNameOID;
				   
				   
				   vfieldNameActual.value ="<%=XSSUtil.encodeForJavaScript(context, selObjId)%>" ;
				   vfieldNameDisplay.value ="<%=XSSUtil.encodeForJavaScript(context, selObjName)%>" ;
				   vfieldNameOID.value ="<%=XSSUtil.encodeForJavaScript(context, strObjID)%>" ;
				   if(typeAhead != "true")
				  	 getTopWindow().closeWindow();   
				   </script>
				   <%
		           }
            // if the chooser is in the Form
		            else if (strSearchMode.equals("CustomChooser"))
		            {
		                String fieldNameOID = emxGetParameter(request, "fieldNameOID");
		                String routeBasePurpose = "";
						String templateName = "";
						String description = "";
						String autoStopOnRejection = "";
		                StringTokenizer strTokenizer = new StringTokenizer(strRowId[0] , "|");
		                String strObjectId = strTokenizer.nextToken() ;
		
		                DomainObject objContext = new DomainObject(strObjectId);
		            	if(!strObjectId.equals(null) || !"".equals(strObjectId))
		          	{
		          		  String sAttrRouteBasePurpose = PropertyUtil.getSchemaProperty(context, "attribute_RouteBasePurpose" );
		          		  String SELECT_ROUTE_BASE_PURPOSE = DomainObject.getAttributeSelect(sAttrRouteBasePurpose);
		          		  String sAttrRouteAutoStopOnRejection=PropertyUtil.getSchemaProperty(context, "attribute_AutoStopOnRejection");
		          		  String SELECT_ROUTE_AUTO_STOP_ON_REJECTION = DomainObject.getAttributeSelect(sAttrRouteAutoStopOnRejection);
		          		  
		          		  SelectList selectStmts = new SelectList(3);
		          		  selectStmts.addElement(DomainObject.SELECT_NAME);
		          		  selectStmts.addElement(SELECT_ROUTE_BASE_PURPOSE);
		          		  selectStmts.addElement(DomainObject.SELECT_DESCRIPTION);
		          		  selectStmts.addElement(SELECT_ROUTE_AUTO_STOP_ON_REJECTION);
		
		          		DomainObject routeTemplateObj = new DomainObject(strObjectId);
		          		Map resultMap = routeTemplateObj.getInfo(context, selectStmts);
		          		templateName = (String) resultMap.get(routeTemplateObj.SELECT_NAME);
		          		routeBasePurpose = (String) resultMap.get(SELECT_ROUTE_BASE_PURPOSE);
		          		description = (String)resultMap.get(DomainObject.SELECT_DESCRIPTION);
		          		description = description.replace("\r","\\r").replace("\n","\\n");
		          		autoStopOnRejection = (String)resultMap.get(SELECT_ROUTE_AUTO_STOP_ON_REJECTION);
		          	}

		                %>
		                <script language="javascript" type="text/javaScript">
						    var typeAhead = "<%=XSSUtil.encodeForJavaScript(context, typeAhead)%>";
							var targetWindow = null;
							if(typeAhead == "true")	{
								var frameName = "<%=XSSUtil.encodeForJavaScript(context, frameName)%>";
								if(frameName == null || frameName == "null" || frameName == "") {
									targetWindow = window.parent;
								} else {
									targetWindow = getTopWindow().findFrame(window.parent, frameName);
								}
							} else	{
									targetWindow = getTopWindow().getWindowOpener();
							}	
							var tmpFieldNameOID = "<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>" + "OID";				    
		                    var vfieldNameActual = targetWindow.document.getElementById("<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>");
		                    var vfieldNameDisplay = targetWindow.document.getElementById("<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>");
		                    var vfieldNameOID = targetWindow.document.getElementById(tmpFieldNameOID);
		                    var vfieldDesc = targetWindow.document.getElementsByName("Description")[0];
		                    var vrouteBasePurpose = targetWindow.document.getElementById("RouteBasePurposeId");
		                    var vrouteAutoStopOnRejection = targetWindow.document.getElementById("AutoStopOnRejectionId");
		                    
		                    vfieldNameActual = vfieldNameActual == null ? targetWindow.document.forms[0]["<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>"] : vfieldNameActual;
		                    vfieldNameDisplay = vfieldNameDisplay == null ? targetWindow.document.forms[0]["<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>"] : vfieldNameDisplay;
		                    vfieldNameOID = vfieldNameOID == null ? targetWindow.document.forms[0][tmpFieldNameOID] : vfieldNameOID;
		                    vfieldDesc = vfieldDesc == null ? targetWindow.document.forms[0]["Description"] : vfieldDesc;
		                    vrouteBasePurpose = vrouteBasePurpose == null ? targetWindow.document.forms[0]["RouteBasePurpose"] : vrouteBasePurpose;
							vrouteAutoStopOnRejection = vrouteAutoStopOnRejection == null ? targetWindow.document.forms[0]["AutoStopOnRejectionId"] : vrouteAutoStopOnRejection;
		                    
		                    
		                    vfieldNameActual.value ="<%=XSSUtil.encodeForJavaScript(context, strObjectId)%>" ;
		                    vfieldNameDisplay.value ="<%=XSSUtil.encodeForJavaScript(context, templateName)%>" ;
		                    vfieldNameOID.value ="<%=XSSUtil.encodeForJavaScript(context, strObjectId)%>" ;
		                    vfieldDesc.value ="<%=XSSUtil.encodeForJavaScript(context, description)%>" ;
		                    vrouteBasePurpose.value ="<%=XSSUtil.encodeForJavaScript(context, routeBasePurpose)%>" ;
		                    vrouteAutoStopOnRejection.value = "<%=XSSUtil.encodeForJavaScript(context, autoStopOnRejection)%>" ;
		                    if(typeAhead != "true")
			                    getTopWindow().closeWindow();
		                  </script>
		             <%
		            }
		}
		// END:OEP:V6R2010:BUG 372490
		}
	}
	catch (Exception e)
	{
		bIsError = true;
		session.putValue("error.message", "" + e);
		//emxNavErrorObject.addMessage(e.toString().trim());
	}// End of main Try-catck block
  }//end of main else
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
