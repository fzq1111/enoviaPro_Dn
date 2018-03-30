<%--  LSemxLifecycleAddApproverFromTemplate.jsp   -    Dialog page for Add Approver From Template functionality

   Copyright (c) 1992-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleAddApproverFromTemplate.jsp.rca 1.5.3.2 Wed Oct 22 15:48:19 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@ page import = "com.matrixone.apps.domain.*" %>
<%@ page import = "org.apache.log4j.Logger"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
	Logger myLogger = Logger.getLogger(LSemxLifecycleAddApproverFromTemplate_jsp.class);
    try {
        String keyValue=emxGetParameter(request,"keyValue");
        String strObjectId = emxGetParameter(request, "objectId");
        if(keyValue == null){
          keyValue = formBean.newFormKey(session);
        }
        formBean.processForm(session,request,"keyValue");
        String template           =  (String) formBean.getElementValue("templateName");
        if("null".equals(template) || template == null) {
            template = "";
        }
       
 %>
<script language="javascript">

function submitForm() {

        var form = document.formManageRouteApproval;
        var divForm = document.getElementById("divFormManageRouteApproval");
        var strHTMLBuffer = "";
        divForm.innerHTML = "";

        // Convert the data in formManageRouteApprovalData to be more useful for process page
        var nCount = 1;
        while (true) {

            // Search an element with value templateId_<nCount>
            var element = null;
            var strKey = "templateId_"+nCount;
            var strStateName = "";
            var strRouteTemplateId = "";

            for (var i = 0; i < form.elements.length; i++) {
                if (form.elements[i].value == strKey) {
                    element = form.elements[i];
                }
            }

            if (element == null) {
                break;
            }
            else {
                // Generate the hidden element in div tag
                strStateName = element.name;
                strRouteTemplateId = form.elements[strKey].value;

                if (strRouteTemplateId != "") {
                    strHTMLBuffer += "<input type='hidden' name='stateNewRoute' value='" + strStateName + "|" + strRouteTemplateId + "'>";
                }
            }

            // Next count
            nCount++;
        }//while true

        divForm.innerHTML = strHTMLBuffer;
		
        form.submit();
    }
    
function clear_onclick(strFieldName) {
        var form = document.formManageRouteApproval;
        if (strFieldName != "") {
            var element = form.elements[strFieldName];
            if (element) {
                element.value = "";
            }
        }
}

function showSearchWindow() {
		 var strFeatures = "width=600,height=500,resizable=yes";
		 var strURL="../components/emxRouteWizardSearchTemplateDialogFS.jsp?objectId=<%=strObjectId%>";
		 var win = window.open(strURL, "RouteTemplate", strFeatures);
 }
 
function routeTemplateChooser_onclick(strFieldHiddenName, strFieldDisplayName, strFieldHiddenObjId) {
     var strURL="../components/emxRouteWizardSearchTemplateDialogFS.jsp?form=formManageRouteApproval&field=" + strFieldHiddenName + "&fieldDisp=" + strFieldDisplayName + "&fieldDispObjId=" + strFieldHiddenObjId;
        showSearch(strURL);
    }
    
</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>
 <form name="formManageRouteApproval"  id="formManageRouteApproval" method="post" action="LSemxLifecycleAddApproverFromTemplateProcess.jsp">
	<input type="hidden" name="objectId" value="<%=strObjectId%>">
	<table border="0" cellpadding="3" cellspacing="2" width="100%">
	<%
	DomainObject dmoObject = new DomainObject(strObjectId);
	String strCurrentParentState = dmoObject.getInfo(context, com.matrixone.apps.domain.DomainObject.SELECT_CURRENT);
	String strPolicyName = dmoObject.getInfo(context, com.matrixone.apps.domain.DomainObject.SELECT_POLICY);
	String type = dmoObject.getTypeName();
	type = FrameworkUtil.getAliasForAdmin(context, 
			"Type", type, true);
	String PolicyName = FrameworkUtil.getAliasForAdmin(context, 
			"Policy", strPolicyName, true);

	//add by heyanbo 2012-11-9
	StringList showStateList =  new StringList();
	try{
		//include state
		String strShowState = FrameworkProperties.getProperty(context, "LS.emxComponents.NeedRouteState."+ strPolicyName.replace(" ", "_"));
		if(strShowState != null && !strShowState.equals("") && !strShowState.equals("null"))
		{
			StringTokenizer strToken = new StringTokenizer(strShowState,",");	
			while(strToken.hasMoreTokens())
			{
				showStateList.addElement(strToken.nextToken().trim());
			}
		}
	}catch(Exception e ){
		showStateList = new StringList();
	}
	
	//end by heyanbo 2012-11-9
	
	
	// add by wangyitao 2016-6-24
	String strCH_doc_min_class=dmoObject.getAttributeValue(context,"CH_doc_min_class");
	
	//end by wangyitao
	
	State state = null;
	String strState = "";
	int  nCount = 0; 
	StateList stateList = dmoObject.getStates(context);
	StateItr stateItr = new StateItr(stateList);
	boolean isPastState = false;
    boolean isLastState = false;
    
	while (stateItr.next()) {
	    state = stateItr.obj();
            strState = state.getName();
            isPastState = isPastState(strState, strCurrentParentState, stateList);
            isLastState = isLastState(strState, stateList);
			String chstrPolicy = PropertyUtil.getSchemaProperty(PolicyName);
			String chstrType = PropertyUtil.getSchemaProperty(type);
		     
            Map programMap1 = new HashMap();
            programMap1.put("objectId", strObjectId);
            programMap1.put("txtName", "*");
			programMap1.put("selScope", "Enterprise");
			programMap1.put("strState", strState);
			programMap1.put("CHpolicy", chstrPolicy);
			programMap1.put("CHtype", chstrType);
			programMap1.put("CH_doc_min_class", strCH_doc_min_class);

           String[] param1 = JPO.packArgs(programMap1);
           MapList templateList = (MapList) JPO.invoke(context,"LSCreateRouteUtil", null , "getRouteTemplatesList" ,  param1, MapList.class);
		   
		   int length = templateList.size();

              //edit by heyanbo 2013-4-18
			  
              if(showStateList != null && showStateList.size() > 0){
            	  if(showStateList.contains(strState))
            	  {
		              if(!isPastState && !isLastState){
		                  nCount++;
		                  //edit by caipan 2016-1-27
		                  Map temMap = new HashMap();
		                  temMap.put("objectId", strObjectId);
		                  temMap.put("CH Add Route State", strState);
		                  temMap.put("type", type); 
		                  temMap.put("policy", PolicyName);
		                  temMap.put("CHRouteTemplate", "templateId_"+nCount);
		                  temMap.put("CHRouteTemplateName", "template_"+nCount);
						  temMap.put("CH_doc_min_class", strCH_doc_min_class);

		                  String[] param = JPO.packArgs(temMap);
		                  String ml = (String)JPO.invoke(context, "LSCreateRouteUtil", null, "getJSPRouteTemplateHTML", param, String.class); 
						  
					//end
					if(length>0){
				
		              %>
		              <tr>
	                  <td class="label" width="150"><label for="<%=strState%>"><%=getStateI18NString(strPolicyName, strState, lStr)%></label></td>
	                  <td class="Field">
					  <input type="text" readonly="readonly"  id="template_<%=nCount%>" name="template_<%=nCount%>" value="" size="20">
	                  <input type="hidden" id="templateId_<%=nCount%>" name="templateId_<%=nCount%>" >
					  <!--The mapping between state and the route template value-->
	                  <input type="hidden" name="<%=strState%>" value="templateId_<%=nCount%>">
					  <!--The route template chooser button-->
	                   <!-- <input type="button" name="routeTemplateChooser" value="..." onClick="javascript:routeTemplateChooser_onclick('template_<%=nCount%>', 'template_<%=nCount%>', 'templateId_<%=nCount%>')"> --> 
	                 <!-- edit by caipan 2016-1-27-->
	                  <%=ml %> 
	                  <a href="JavaScript:clear_onclick('template_<%=nCount%>'); clear_onclick('templateId_<%=nCount%>');" ><%=getI18NString("emxFrameworkStringResource", "emxFramework.Common.Clear", lStr)%></a>
				</td>
	                </tr>  
		              <%
		              }else if (length==0) {
	%>
					<tr>
	                  	<td class="label" width="150"><label for="<%=strState%>"><%=getStateI18NString(strPolicyName, strState, lStr)%></label></td>
						<td class="Field"><%=getI18NString("emxFrameworkStringResource", "CH.emxFramework.Common.NotAllowedForState", lStr)%></td>
					</tr>
	<%        	          
	              }
					  }
		              else if (isLastState) {
		%>
						<tr>
		                  	<td class="label" width="150"><label for="<%=strState%>"><%=getStateI18NString(strPolicyName, strState, lStr)%></label></td>
							<td class="Field"><%=getI18NString("emxFrameworkStringResource", "emxFramework.Common.NotAllowedForLastState", lStr)%></td>
						</tr>
		<%        	          
		              }
            	  }else if (isLastState) {
		%>
						<tr>
		                  	<td class="label" width="150"><label for="<%=strState%>"><%=getStateI18NString(strPolicyName, strState, lStr)%></label></td>
							<td class="Field"><%=getI18NString("emxFrameworkStringResource", "emxFramework.Common.NotAllowedForLastState", lStr)%></td>
						</tr>
		<%        	          
		              }
              }else{
            	  if(!isPastState && !isLastState){
	                  nCount++;
	                  Map temMap = new HashMap();
	                  temMap.put("objectId", strObjectId);
	                  temMap.put("CH Add Route State", strState);
	                  temMap.put("type", type); 
	                  temMap.put("policy", PolicyName);
	                  temMap.put("CHRouteTemplate", "templateId_"+nCount);
	                  temMap.put("CHRouteTemplateName", "template_"+nCount);
					  temMap.put("CH_doc_min_class", strCH_doc_min_class);

	                  String[] param = JPO.packArgs(temMap);
	                  String ml = (String)JPO.invoke(context, "LSCreateRouteUtil", null, "getJSPRouteTemplateHTML", param, String.class); 
					  
	                if(length>0){
	              %>
	              <tr>
	                  <td class="label" width="150"><label for="<%=strState%>"><%=getStateI18NString(strPolicyName, strState, lStr)%></label></td>
	                  <td class="Field">
					  <input type="text" readonly="readonly"  id="template_<%=nCount%>" name="template_<%=nCount%>" value="" size="20">
	                  <input type="hidden" id="templateId_<%=nCount%>" name="templateId_<%=nCount%>" >
					  <!--The mapping between state and the route template value-->
	                  <input type="hidden" name="<%=strState%>" value="templateId_<%=nCount%>">
					  <!--The route template chooser button-->
	                   <!-- <input type="button" name="routeTemplateChooser" value="..." onClick="javascript:routeTemplateChooser_onclick('template_<%=nCount%>', 'template_<%=nCount%>', 'templateId_<%=nCount%>')"> --> 
	                 <!-- edit by caipan -->
	                  <%=ml %> 
	                  <a href="JavaScript:clear_onclick('template_<%=nCount%>'); clear_onclick('templateId_<%=nCount%>');" ><%=getI18NString("emxFrameworkStringResource", "emxFramework.Common.Clear", lStr)%></a>
				</td>
	                </tr>  
	              <%
	              }
				         else if (length==0) {
	%>
					<tr>
	                  	<td class="label" width="150"><label for="<%=strState%>"><%=getStateI18NString(strPolicyName, strState, lStr)%></label></td>
						<td class="Field"><%=getI18NString("emxFrameworkStringResource", "CH.emxFramework.Common.NotAllowedForState", lStr)%></td>
					</tr>
	<%        	          
	              }
	              else if (isLastState) {
	%>
					<tr>
	                  	<td class="label" width="150"><label for="<%=strState%>"><%=getStateI18NString(strPolicyName, strState, lStr)%></label></td>
						<td class="Field"><%=getI18NString("emxFrameworkStringResource", "emxFramework.Common.NotAllowedForLastState", lStr)%></td>
					</tr>
	<%        	          
	              }
            	  }
              }
              //end by heyanbo 2013-4-18
    }
			  %>
	</table>
	  <div id="divFormManageRouteApproval"></div>
 </form>
<%     
    } catch (Exception ex) {
    	myLogger.error(ex.getMessage(), ex);
         if (ex.toString() != null && ex.toString().length() > 0) {
            emxNavErrorObject.addMessage(ex.toString());
         }
    } finally {
        // Add cleanup statements if required like object close, cleanup session, etc.
    }
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>
<%!

/**
 * Returns if the given state is the past state with respect to the list of states
 * @param strState The state to be checked if it is past
 * @param strObjectCurrentState The current state of the object
 * @param stateList List of all the state of the object in ascending order
 * @return true if the strState comes before strObjectCurrentState in stateList
 * @throws Exception if operation fails
 */
public static boolean isPastState(String strState, String strObjectCurrentState, StateList stateList) throws Exception {
    if (strState == null || "".equals(strState)) {
        throw new Exception("Invalid value for strState");
    }
    if (strObjectCurrentState == null || "".equals(strObjectCurrentState)) {
        throw new Exception("Invalid value for strObjectCurrentState");
    }
    if (stateList == null) {
        throw new Exception("Null stateList");
    }

    int nGivenStateIndex = -1;
    int nCurrentStateIndex = -1;
    int nCurrentIndex = 0;

    for (StateItr itrStates = new StateItr(stateList); itrStates.next(); nCurrentIndex++) {
        State state = itrStates.obj();
        if (strState.equals(state.getName())) {
            nGivenStateIndex = nCurrentIndex;

            if (nCurrentStateIndex != -1) {
                break;
            }
        }

        if (strObjectCurrentState.equals(state.getName())) {
            nCurrentStateIndex = nCurrentIndex;

            if (nGivenStateIndex != -1) {
                break;
            }
        }
    }//for

    if (nGivenStateIndex == -1) {
        throw new Exception("Given state is not found in stateList");
    }
    if (nCurrentStateIndex == -1) {
        throw new Exception("Current state is not found in stateList");
    }
    if (nGivenStateIndex < nCurrentStateIndex) {
        return true;
    }
    else {
        return false;
    }
}

/**
 * Returns if the given state is the last state with respect to the list of states
 * @param strState The state to be checked if it is past
 * @param stateList List of all the state of the object in ascending order
 * @return true if the strState is last in stateList
 * @throws Exception if operation fails
 */
public static boolean isLastState(String strState, StateList stateList) throws Exception {
    if (strState == null || "".equals(strState)) {
        throw new Exception("Invalid value for strState");
    }
    if (stateList == null || stateList.size() == 0) {
        throw new Exception("Null/Empty stateList");
    }

    int nLength = stateList.size();
    int nLastStateIndex = nLength -1;
    State lastState = (State)stateList.get(nLastStateIndex);
    if (strState.equals(lastState.getName())) {
        return true;
    }
    else {
        return false;
    }
}

%>


