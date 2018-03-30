<%--  emxCreateProcess.jsp

   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCreateProcess.jsp.rca 1.6.2.2.1.4 Wed Oct 22 15:48:29 2008 przemek Experimental przemek $
--%>
<%@include file="emxNavigatorInclude.inc"%>

<html>


<%@include file="emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="createBean"
    class="com.matrixone.apps.framework.ui.UIForm" scope="session" />

<head>
<title>form processing</title>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="JavaScript" src="scripts/emxUIConstants.js"></script>
<script language="JavaScript" src="scripts/emxUICore.js"></script>
<script language="javascript" src="scripts/emxUIModal.js"></script>
<script language="javascript" src="scripts/emxUIFormUtil.js"></script>


</head>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    String portalMode 			= emxGetParameter(request, "portalMode");
    String form 				= emxGetParameter(request, "form");
    String timeStamp 			= emxGetParameter(request, "timeStamp");
    String postProcessURL 		= emxGetParameter(request, "postProcessURL");
    String postProcessJPO		= emxGetParameter(request, "postProcessJPO");
    String languageStr 			= request.getHeader("Accept-Language");
    String submitAction 		= emxGetParameter(request, "submitAction");
    String emxSuiteDirectory	= emxGetParameter(request, "emxSuiteDirectory");
    // if emxSuiteDirectory is null or empty , check for "SuiteDirectory" request Parameter 
    if(UIUtil.isNullOrEmpty(emxSuiteDirectory)){
        emxSuiteDirectory = emxGetParameter(request, "SuiteDirectory");
    }
    String suiteKey 			= emxGetParameter(request,"suiteKey");
    String targetLocation 		= emxGetParameter(request,"targetLocation");
    String openerFrame 			= emxGetParameter(request,"openerFrame");
    String newObjectId 			= "";
    String relId 				= "";
    String objectId = emxGetParameter(request, "objectId"); 	
    String strLanguage 			= request.getHeader("Accept-Language");
    String charSet 				= Framework.getCharacterEncoding(request);
    boolean isPortal 			= (portalMode != null && "true".equalsIgnoreCase(portalMode));

    // time zone to be used for the date fields
    String timeZone = (String) session.getAttribute("timeZone");
    String fieldallowKeyableDates="";

    boolean updateComplete = true;
    boolean errorFromDate = true;
    String invaliddate = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(languageStr), "emxFramework.Common.InvalidDate"); 
    String allowKeyableDates = "false";

    HashMap returnMap =  new HashMap();
    String action  = "CONTINUE"; // Default Action is Continue - Commits transaction
    String message = "";

    try {
        allowKeyableDates = EnoviaResourceBundle.getProperty(context, "emxFramework.AllowKeyableDates");
    } catch (Exception e) {
        allowKeyableDates = "false";
    }
    String typeAheadEnabled = "true";
    try
    {
        typeAheadEnabled = EnoviaResourceBundle.getProperty(context, "emxFramework.TypeAhead");
    }
    catch (Exception e)
    {
    }

    try {
        MapList fields 		= createBean.getFormFields(timeStamp);
        String fieldName	= "";
        for (int k = 0; k < fields.size(); k++) {
            HashMap field 	= (HashMap) fields.get(k);
            fieldName 		= createBean.getName(field);

            if (createBean.isDateField(field)&& createBean.isFieldEditable(field)) {
                fieldallowKeyableDates = (String) createBean
                        .getSetting(field, "Allow Manual Edit");
                if ((allowKeyableDates != null && "true".equalsIgnoreCase(allowKeyableDates)) || (fieldallowKeyableDates != null && 
                		"true".equalsIgnoreCase(fieldallowKeyableDates))) {
                    		java.text.DateFormat df = java.text.DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(),request.getLocale());
                    		df.setLenient(false);
                    		String fieldValue = emxGetParameter(request,fieldName);
                    		if ((fieldValue == null || fieldValue.equals(""))&& (!createBean.isFieldRequired(field)))
                        		continue;
                    		java.util.Date formattedDate = df.parse(fieldValue);
                }
            }
            String rangeHelperURL 		= createBean.getRangeHelperURL(field);
            String tagDisplayFieldValue	= "";
            String tagHiddenFieldValue 	= null;

            String strTypeAheadSetting	= createBean.getSetting(field,"TypeAhead");
            if (strTypeAheadSetting==null||"null".equals(strTypeAheadSetting)||"".equals(strTypeAheadSetting))
                {
                    strTypeAheadSetting="true";
                }
            if (((createBean.isTextBoxField(field) && createBean.isFieldEditable(field))
                ||(createBean.isFieldManualEditable(field) && rangeHelperURL != null && rangeHelperURL.length() > 0)
                || (createBean.isDateField(field) && createBean.isFieldManualEditable(field))) && "true".equalsIgnoreCase(typeAheadEnabled) && "true".equalsIgnoreCase(strTypeAheadSetting))
            {
                    if (rangeHelperURL != null && rangeHelperURL.length() > 0)
                    {
                        tagDisplayFieldValue = emxGetParameter(request, fieldName + "Display");
                        tagHiddenFieldValue = emxGetParameter(request, fieldName);
                    }
                    else
                    {
                            tagDisplayFieldValue = emxGetParameter(request, fieldName);
                            tagHiddenFieldValue = "";
                            if (createBean.isDateField(field))
                            {
                                tagHiddenFieldValue = emxGetParameter(request, fieldName+"_msvalue");
                                if ((fieldallowKeyableDates != null && "true".equalsIgnoreCase(fieldallowKeyableDates)))
                                    {
                                            int iDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
                                            double iClientTimeOffset = (new Double(timeZone)).doubleValue();
                                            long msvalue=DateUtil.getMilliseconds(context, tagDisplayFieldValue, iDateFormat, iClientTimeOffset, request.getLocale());
                                            Long lgMsvalue=new Long(msvalue);
                                            tagHiddenFieldValue=lgMsvalue.toString();
                                     }
                            }
                    }
                    String tagTypeAheadSavedValuesLimit = createBean.getSetting(field,"TypeAhead Saved Values Limit");
                    if(tagTypeAheadSavedValuesLimit.length()==0)
                    {
                        try
                        {
                            tagTypeAheadSavedValuesLimit = EnoviaResourceBundle.getProperty(context, "emxFramework.TypeAhead.SavedValuesLimit");
                        }
                        catch(Exception e)
                        {
                            tagTypeAheadSavedValuesLimit = "10";
                        }
                    }

%>
					<!-- XSSOK -->
                    <emxUtil:saveTypeAheadValues context="<%= context %>" form="<%=form%>" field="<%= fieldName %>" displayFieldValue="<%=tagDisplayFieldValue%>" hiddenFieldValue="<%=tagHiddenFieldValue%>" count="<%= tagTypeAheadSavedValuesLimit %>"/>
<%      }
    }
        errorFromDate = false;
%>
    <emxUtil:commitTypeAheadValues context="<%= context %>" />
<%

        HashMap requestMap 			= UINavigatorUtil.getRequestParameterMap(request);
        HashMap requestValuesMap 	= UINavigatorUtil.getRequestParameterValuesMap(request);
        requestMap.put("RequestValuesMap", requestValuesMap);

        ContextUtil.startTransaction(context, true);
		// add by zhangshuai 3/25/2017
		String LSvalidateExist = emxGetParameter(request, "LSvalidateExist");
		if((!"".equals(LSvalidateExist)) && (!"null".equals(LSvalidateExist)) && ("true".equals(LSvalidateExist))){  //mod by zs 3/26/2017
			requestMap.put("fields", fields);
			String createId = null;
			String str = null;
			String createClass = null;
			String createMethod = null;
			String createJpo = (String)requestMap.get("createJPO");
			if ((createJpo != null) && (!"".equals(createJpo)) && (!"null".equals(createJpo)))
			{
			  int i = createJpo.indexOf(":");
			  if (i > 0)
			  {
				createClass = createJpo.substring(0, i);
				createMethod = createJpo.substring(i + ":".length());
			  }
			}	  
			String[] arrayOfString = JPO.packArgs(requestMap);
			FrameworkUtil.validateMethodBeforeInvoke(context, createClass, createMethod, "createProcess");
			Map localMap = (Map)JPO.invoke(context, createClass, null, createMethod, arrayOfString, Map.class);

			String strMessage = (String)localMap.get("ErrorMessage");
			if (!UIUtil.isNullOrEmpty(strMessage)) {
			  throw new FrameworkException(strMessage);
			}
			createId = (String)localMap.get("id");
			str = (String)localMap.get("isExist");
			if ((createId != null) && (!"".equals(createId)) && (!"null".equals(createId)) && ("true".equals(str)))
			{
				newObjectId = createId;
			}else{
				newObjectId = createId;
				createBean.updateFiledValues(context,createId, requestMap, fields, timeZone);
			}
		}else{
			newObjectId = createBean.createObject(context, requestMap, fields, timeZone);
		}
		//end by zhangshuai
		
       // newObjectId = createBean.createObject(context, requestMap, fields, timeZone);
            
        // connect if objectId is passed.
        if (objectId != null && !"".equals(objectId)) {
            String relationship = emxGetParameter(request,"relationship");			
            if (relationship != null && !relationship.equals("") && !relationship.equals("*")) {
				DomainObject customaryObj = new DomainObject(objectId);	
				String customaryType = customaryObj.getType(context);
				if("SEM Contact Order".equals(customaryType) && "relationship_Decision".equals(relationship)){
					StringList busList = new StringList("id");
					StringList relList = new StringList(DomainRelationship.SELECT_ID);
					MapList resList = customaryObj.getRelatedObjects(context, "SEM Meeting ContactOrder", "Meeting", busList, relList, true, false, (short)1, null, null);
					for(int i = 0; i < resList.size(); i ++)
					{
						Map resMap = (Map)resList.get(i);
						objectId = (String)resMap.get("id");
					}
				}
                String relSymb = PropertyUtil.getSchemaProperty(context, relationship);
                if("".equals(relSymb))
                {
                    relSymb = relationship;
                }

                String direction = emxGetParameter(request, "direction");
                DomainObject obj = new DomainObject(newObjectId);

                PropertyUtil.setRPEValue(context, "MX_ALLOW_POV_STAMPING", "true", true); // FZS - Hitachi

                if("to".equalsIgnoreCase(direction))
                {
                    DomainRelationship domainRel = obj.addToObject(context, new RelationshipType(relSymb), objectId);
                    relId = domainRel + "";
                }
                else
                {
                    DomainRelationship domainRel = obj.addFromObject(context, new RelationshipType(relSymb), objectId);
                    relId = domainRel + "";
                }
  		        PropertyUtil.setRPEValue(context, "MX_ALLOW_POV_STAMPING", "false", true);
            }
        }
        ContextUtil.setSavePoint(context,"CreateObject");
    } catch (Exception ex) {
        PropertyUtil.setRPEValue(context, "MX_ALLOW_POV_STAMPING", "false", true);
        if (errorFromDate) {
            emxNavErrorObject.addMessage(invaliddate);
        } else if (ex.toString() != null && (ex.toString().trim()).length() > 0) {
        	String msg = ex.getMessage();
	    	String errorMessage = "";
	    	if(msg.indexOf("1500789") > 1){
	    		errorMessage = getI18NString("emxFrameworkStringResource", "emxFramework.Common.NotUniqueMsg", request.getHeader("Accept-Language"));
	    		emxNavErrorObject.addMessage(errorMessage);
	    	}else if(msg.contains("ORA-12899") || msg.contains("ORA-01461")){
	    		errorMessage = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Create.NameColumn", new Locale(request.getHeader("Accept-Language")));            		
	    	  	emxNavErrorObject.addMessage(errorMessage);
	    	}else{
	    		emxNavErrorObject.addMessage(ex.toString().trim());	
	    	}
        }
        action = "error";
        updateComplete = false;
        ContextUtil.abortTransaction(context);
    }

    if(!"error".equalsIgnoreCase(action))
    {
    try {
        //added condition to handle the postProcessURL parameter by Ranganath
            if (postProcessURL != null && !"".equals(postProcessURL) && updateComplete) {
                request.setAttribute("context", context);
                postProcessURL = UIUtil.addSecureTokeninURL(context, session, postProcessURL);

                try
                {
                %>
                <!-- //XSSOK -->
                <jsp:include page="<%=postProcessURL%>" flush="true"><jsp:param name="newObjectId" value="<%=newObjectId%>"/><jsp:param name="relId" value="<%=relId%>"/></jsp:include>
                <%
                }
                catch (ServletException se)
                {
//                 Rethrow the root cause exception
                Throwable ex = se.getRootCause();
                while (ex instanceof ServletException)
                {
                se = (ServletException)ex;
                ex = se.getRootCause();
                }
                throw (ex != null) ? ex : se;
                }


                if (emxNavErrorObject != null) {
                    String emxNavigatorErrorMsg = emxNavErrorObject.toString();
                    if (emxNavigatorErrorMsg != null && !"".equals(emxNavigatorErrorMsg)) {
                        action = "error";
                        updateComplete = false;
                    }
                }
            }
            //added condition to handle the postProcessJPO parameter by Ranganath
            if (postProcessJPO != null && !"".equals(postProcessJPO) && postProcessJPO.indexOf(":") > 0 && updateComplete) {
                HashMap programMap 	= new HashMap(6);
                HashMap paramMap 	= new HashMap(6);
                
                paramMap.put("objectId", newObjectId);
                paramMap.put("newObjectId", newObjectId);
                paramMap.put("relId", relId);
                paramMap.put("languageStr", languageStr);
                programMap.put("requestMap", UINavigatorUtil.getRequestParameterMap(pageContext));
                programMap.put("paramMap", paramMap);
                
                HashMap formMap = createBean.getFormData(timeStamp);
                programMap.put("formMap", formMap);

                String[] methodargs 	= JPO.packArgs(programMap);
                String strJPOName 		= postProcessJPO.substring(0,postProcessJPO.indexOf(":"));
                String strMethodName 	= postProcessJPO.substring(postProcessJPO.indexOf(":") + 1, postProcessJPO.length());
                FrameworkUtil.validateMethodBeforeInvoke(context, strJPOName, strMethodName,"postProcess");
                try {
                    returnMap = (HashMap)JPO.invoke(context, strJPOName, null, strMethodName, methodargs, Object.class);
                } catch (ClassCastException exJPO1) {
                    //DO NOTHING
                    /*it is observed that some existing customers using primitive data type (int, boolean etc)
                    as return types when they write the post process method.
                    To support their use case the ClassCastException block is added and exception is ignored*/
                } catch (Exception exJPO) {
                    throw (new FrameworkException(exJPO.toString()));
                }

                if(returnMap != null && returnMap.size() > 0)
                 {
                    message = (String)returnMap.get("Message");
                    action  = (String)returnMap.get("Action");
                    if(message != null && !"".equals(message))
                    {
                        String suiteDir = "";
                        String registeredSuite = suiteKey;

                        if (suiteKey != null && suiteKey.startsWith("eServiceSuite") )
                            registeredSuite = suiteKey.substring("eServiceSuite".length());

                        String stringResFileId = UINavigatorUtil.getStringResourceFileId(context,registeredSuite);
                        if(stringResFileId == null || stringResFileId.length()==0)
                            stringResFileId="emxFrameworkStringResource";

                        String alertMessage = EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(request.getHeader("Accept-Language")), message);
                        if ((alertMessage == null) || ("".equals(alertMessage)))
                        {
                            alertMessage = message;
                        }

                        alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\n","\\n");
                        alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\r","\\r");

%>
                        <script language="javascript" type="text/javaScript">
                            alert("<%=alertMessage%>");
                        </script>
<%
                    }
                }
            }

            if(action != null && (action.equalsIgnoreCase("continue") || action.equalsIgnoreCase("success")))
            {
                ContextUtil.commitTransaction(context);
                updateComplete = true;
            }
            else
            {
                ContextUtil.abortTransaction(context);
                updateComplete = false;
            }
        } catch (Exception ex) {
            updateComplete = false;
            ContextUtil.abortTransaction(context);
            String msg = ex.getMessage();
	    	int index = msg.lastIndexOf("ErrorCode:");
	    	String errorCode = msg.substring(index+10);
            String errorMessage = ex.toString();
            if (errorMessage != null && errorMessage.length() > 0) {
            	if(errorCode.equals("1500789")){
            		errorMessage = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.NotUniqueMsg", new Locale(request.getHeader("Accept-Language")));            		
            		emxNavErrorObject.addMessage(errorMessage);
            	}else {
            		emxNavErrorObject.addMessage(errorMessage);	
            	}
            }
        }
    }
%>
<script type="text/javascript" language="javascript">
 function submitPostToSelfSB(url,formFieldValues)
 {
	 try {
		 formFieldValues = topWindow.getKeyValuePairs(formFieldValues);
		   
		    var frame   = topWindow.frames["listHidden"];
		    var form    = frame.document.createElement('form');
		    form.name   = "emxHiddenForm";
		    form.id     = "emxHiddenForm";

		    frame.document.body.appendChild(form);

		    for(var index=0; index<formFieldValues.length; index++)
		    {
		 	  var input   = frame.document.createElement('input');
		 	  input.type  = "hidden";
		 	  input.name  = formFieldValues[index].name;
		 	  input.value = decodeURIComponent(formFieldValues[index].value);
		 	  form.appendChild(input);
		 	}
		 	
		     form.action = url;
		     form.method = "post"; 
		     form.target = "_parent";
		     form.submit();
	 } catch (e){
		 
	 }
 
    
 }
 </script>
<script>
var modalWin;
var topWindow = getTopWindow().getWindowOpener()? getTopWindow().getWindowOpener() : getTopWindow();
var tStamp=null;
<%if("slidein".equalsIgnoreCase(targetLocation)){%>
var openerFrame = "<xss:encodeForJavaScript><%=openerFrame%></xss:encodeForJavaScript>";
topWindow = findFrame(getTopWindow(),openerFrame);
topWindow = topWindow ? topWindow : findFrame(getTopWindow(),"detailsDisplay");
if(!topWindow){
	topWindow = findFrame(getTopWindow(),"content");
	
}

<%}%>
<%
	String addToCallerFrame = emxGetParameter(request,"addToCallerFrame");
    if(updateComplete)
    {
		if(addToCallerFrame != null && !"".equalsIgnoreCase(addToCallerFrame))
		{
%>			
			function closeSlideinIfRefreshFinished(){
				 if (!parent.isCheckinRefreshFinished){
					setTimeout(function(){
						closeSlideinIfRefreshFinished();
					}, 200);
				}
				else{
					var frameHandle = emxUICore.findFrame(getTopWindow(),'<%=addToCallerFrame%>');
					if(!frameHandle){
						frameHandle = getTopWindow().findFrame(getTopWindow(), 'content');
					}
					var oXM = frameHandle.sbPage.oXML;
				  	var rowID = emxUICore.selectSingleNode(oXM, "/mxRoot/rows//r[@o = '<%=objectId%>']");
				  	if(rowID){
				    	var selectSBrows = [];selectSBrows.push(rowID.getAttribute('id'));
				        var strXml="<mxRoot><action>add</action><data status='committed'><item oid= '<%=newObjectId%>' relId='<%=relId%>' pid='<%=objectId%>'/></data></mxRoot>";
						frameHandle.emxEditableTable.addToSelected(strXml, selectSBrows);
						//frameHandle.emxEditableTable.refreshStructureWithOutSort();
						parent.isCheckinRefreshFinished = true;
					}					
					getTopWindow().closeSlideInDialog();
				}
				
			}
			closeSlideinIfRefreshFinished();			

<%			
		} else if(submitAction != null && !"".equalsIgnoreCase(submitAction))
        {
            if("refreshCaller".equalsIgnoreCase(submitAction))
            {
%>            
                 var baseUrl = topWindow.document.location.href;
                 if(baseUrl.indexOf("emxIndentedTable.jsp") >= 0){
                	 topWindow.refreshSBTable(topWindow.configuredTableName);
    			} else {
						topWindow.document.location.href=topWindow.document.location.href;
					}
             	
           	 
               
<%
            }
            else if("refreshCallerParent".equalsIgnoreCase(submitAction))
            {
%>
                    topWindow.parent.document.location.href = topWindow.parent.document.location.href;
<%
            }
            else if("treeContent".equalsIgnoreCase(submitAction))
            {
%>

	var contentFrame;
	if(topWindow.getTopWindow){
	 contentFrame = findFrame(topWindow.getTopWindow(), "content"); 
	}
	else
		{
		contentFrame = findFrame(getTopWindow(), "content"); 
		}
	            if(contentFrame)
                {
                    contentFrame.document.location.href = "emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, newObjectId)%>&emxSuiteDirectory=<%=XSSUtil.encodeForURL(context, emxSuiteDirectory)%>";
                }


<%
            }
            else if("treePopup".equalsIgnoreCase(submitAction))
            {
%>
      		modalWin  = showModalDialog("emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, newObjectId)%>", 700, 600, true, true);      		
      		
<%
            }
        }
        else
        {
            String alertStr = UINavigatorUtil.parseHeader(context, pageContext, "emxFramework.Create.SuccessfullCreate", newObjectId, "eServiceSuiteFramework", strLanguage);
%>
            //XSSOK
            alert("<%=alertStr%>");
<%
        }
    }
%>
    parent.setFormSubmitAction(true);
    </script>
    <%@include file="emxNavigatorBottomErrorInclude.inc"%>
<%
	String isApply = emxGetParameter(request, "isApply");
	String LSvalidateCreate = emxGetParameter(request, "LSvalidateCreate");//add by zs 4/11/2017
    if (updateComplete && !isPortal && "false".equalsIgnoreCase(isApply) && (addToCallerFrame == null || "".equalsIgnoreCase(addToCallerFrame)))
    {
%>    
<script language="javascript">
<%if("slidein".equalsIgnoreCase(targetLocation)){%>
getTopWindow().closeSlideInDialog();
<%} else if (UIUtil.isNullOrEmpty(targetLocation) || "popup".equalsIgnoreCase(targetLocation)){	
	
		if((!"".equals(LSvalidateCreate)) && (!"null".equals(LSvalidateCreate)) && ("true".equals(LSvalidateCreate))){ 
			String newURL = "../common/emxNavigator.jsp?isPopup=true&mode=tree&objectId=" + newObjectId;
%>
// start -IR-214280V6R2014, below timeout condition is added for usecase which have submitAction as treePopup
// it needs to be fixed cleanly
 getTopWindow().open('<%= newURL%>','','width=990,height=690');
<%}%>
if (isIE)
{	
	closePopupWindow(getTopWindow());
}
else
{	
	getTopWindow().closeWindow();
}

// end-IR-214280V6R2014 
<%}%>    
 </script>
<%}%>
<script type="text/javascript" language="javascript">
      turnOffProgress();
</script>

</html>

