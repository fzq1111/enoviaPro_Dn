<%--  emxLifecycleAddApprover.jsp   -   <description>

   Copyright (c) 1992-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: LSTaskAppointedParticipantsDialog.jsp.rca 1.11.3.2 Wed Oct 22 15:48:45 2008 przemek Experimental przemek $
--%>
<%-- <%@include file="../common/emxNavigatorInclude.inc"%> --%>

<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@ page import="com.matrixone.apps.domain.DomainObject"%>
<%@ page import="java.util.List"%>
<%@ page import="com.matrixone.apps.common.RouteTemplate"%>
<%@ page import="com.matrixone.apps.common.Route"%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "../components/emxRouteInclude.inc"%>
<%@include file = "../components/emxComponentsJavaScript.js"%>
<%@ page import = "com.matrixone.apps.framework.ui.UIUtil"%>

<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
</head>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<!-- Page display code here -->
<style type="text/css">
	#required{
		color:#FFFFFF;
   		font-style: italic;
   		filter: progid:DXImageTransform.Microsoft.Gradient(startColorStr='#F23433',endColorStr='#930303',gradientType='0');
		background: -moz-linear-gradient(center top , #F23433, #930303) repeat scroll 0 0 transparent;
    	border-right: 1px solid #4E6E90;
	}
	#routeName{
		font-size:60px;
		background-color: #F23433, #930303;
		padding: 20px;
	}
</style>
<!-- Bug #345799: Type Ahead Implementation -->
  <script language="javascript" src="../common/scripts/emxTypeAhead.js"></script>
  <script type="text/javascript"> addStyleSheet("emxUITypeAhead"); </script></head>
<!-- Bug #345799: Type Ahead Implementation -->
<%
	String ATTR_Approver_Range = PropertyUtil.getSchemaProperty(context, "attribute_LSApproverRange");

	String sTaskId = emxGetParameter(request, "objectId");
	String stateAssigned    	= FrameworkUtil.lookupStateName(context, DomainObject.POLICY_INBOX_TASK, "state_Assigned");
	String stateReview     		= FrameworkUtil.lookupStateName(context, DomainObject.POLICY_INBOX_TASK, "state_Review");
	String stateTaskComplete    = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_INBOX_TASK, "state_Complete");
	String timeStamp 			= emxGetParameter(request,"timeStamp");
	String portalMode			= emxGetParameter(request,"portalMode");
	String parentOID 			= emxGetParameter(request,"parentOID");
	String timeZone				= (String)session.getValue("timeZone");
	String fromPage				= emxGetParameter(request,"fromPage");  
	
	String autoStartRouteFlag	= emxGetParameter(request,"autoStartRoute");
 
	String strAssignedPeopleCannotNull = getI18NString("emxComponentsStringResource","LS.emxComponents.CreateDocument.AssignedPeopleCanotEmpty", sLanguage);
	String strAutoStartRoute = getI18NString("emxComponentsStringResource","LS.emxComponents.InitiateRoute.AutoStartRoute", sLanguage);
	String roleI18N = "(" + getI18NString("emxComponentsStringResource","emxComponents.Common.Role", sLanguage) + ")";
	String groupI18N = "(" + getI18NString("emxComponentsStringResource","emxComponents.Common.Group", sLanguage) + ")";
	String temp_hhrs_mmin                 = getAppProperty(context,application,"emxComponents.RouteScheduledCompletionTime");
	String sAttParallelNodeProcessionRule = PropertyUtil.getSchemaProperty(context, "attribute_ParallelNodeProcessionRule");
	String buttonAdd = getI18NString("emxComponentsStringResource","LS.emxComponents.Common.MassDistribution.button.Add", sLanguage);
	String buttonDelete = getI18NString("emxComponentsStringResource","LS.emxComponents.Common.MassDistribution.button.Delete", sLanguage);
	
	String routeInstructions = "";
	String sTaskTitle = "";
	String routeStatus = ""; 
	String sModel = emxGetParameter(request, "model"); 
	String routeId = emxGetParameter(request, "routeId"); 
	Route routeObj = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
	routeObj.setId(routeId);
	String routeName = routeObj.getName(context);
	StringList strSelObjRoute= new StringList();
  	strSelObjRoute.addElement(DomainObject.SELECT_ID);
  	StringList selRelItem = new StringList();
  	selRelItem.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_POLICY+"]");
  	selRelItem.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_STATE+"]");
  	selRelItem.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_PURPOSE+"]");
  	
  	
  	//获取Route Action Range
  	MapList ObjectRoute =  routeObj.getRelatedObjects(context, DomainObject.RELATIONSHIP_OBJECT_ROUTE, "*",strSelObjRoute,selRelItem,true,false,(short)1,null,null);
	AttributeType attrRouteAction = new AttributeType(DomainConstants.ATTRIBUTE_ROUTE_ACTION);
    attrRouteAction.open(context);
    StringList routeActionList = attrRouteAction.getChoices(context);
    attrRouteAction.close(context);
    routeActionList.remove ("Information Only");
    routeActionList.remove ("Investigate");
    String sRoute = "";
    if(ObjectRoute != null && ObjectRoute.size()>0){
	   Map tempObjectRouteMap = (Map)ObjectRoute.get(0);
		sRoute = (String)tempObjectRouteMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_PURPOSE+"]");
	}
	if("Approval".equals(sRoute))
	{
	    routeActionList = new StringList(1);
	    routeActionList.add("Approve");
	}
	else if("Review".equals(sRoute))
	{
	    routeActionList = new StringList(1);
	    routeActionList.add("Comment");
	}
	if(sModel.equals("MoreSignFor"))
	{
		DomainObject taskObject = DomainObject.newInstance(context, sTaskId);
		//sTaskTitle = taskObject.getAttributeValue(context, routeObj.ATTRIBUTE_TITLE);
		sTaskTitle = getI18NString("emxComponentsStringResource","SEM.emxComponents.Common.MoreSignFor", sLanguage);
		routeInstructions = getI18NString("emxComponentsStringResource","SEM.emxComponents.MoreSignFor.Instructions", sLanguage);
		String sLoginUser = context.getUser();
		Person  personObj = Person.getPerson(context);
		String sFirstName = personObj.getAttributeValue(context, Person.ATTRIBUTE_FIRST_NAME);
		if(sFirstName != null && !sFirstName.equals(""))
		{
			sLoginUser = sFirstName;
		}
		routeInstructions = routeInstructions.replace("${PERSON}", sLoginUser);
		
		routeActionList = new StringList(1);
	    routeActionList.add("Notify Only");
	}else if(sModel.equals("MoreSigned")){
		sTaskTitle = getI18NString("emxComponentsStringResource","SEM.emxComponents.Common.MoreSigned", sLanguage);
	}
  	Collections.sort ((java.util.List)routeActionList); // To maintain order Approve, Comment, Notify Only
  	StringList sOrderList = new StringList();
  	
  	if(!sModel.equals("MoreSignFor"))
	{
  		sOrderList.addElement("After");
	}
  	sOrderList.addElement("Parallel");
  	
	try{
%>

<form name="taskAppointedParticipants"  id="taskAppointedParticipants" method="post"
								action="LSRouteTaskMoreSignedProcess.jsp" target="pagehidden">
	<input type="hidden" name="actionType" value="">
	<input type="hidden" name="objectId" value="<%=sTaskId%>">
	<input type="hidden" name=model value="<%=sModel%>">
<table class="list"  id="taskList">
<tbody>	
		<tr>
        <th id = "required" width="12%" style="text-align:center;background-color:red;">
        	<emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.TitleActionOrder</emxUtil:i18n>
        	</th>
        <th id = "required" class="required" width="25%" style="text-align:center">
      	  <emxUtil:i18n localize="i18nId">LS.emxComponents.Common.MassDistribution.Assignee</emxUtil:i18n>
        </th>
        <th id = "required" class="required" width="25%" style="text-align:center">
        	<emxUtil:i18n localize="i18nId">LS.emxComponents.Common.MassDistribution.Instructions</emxUtil:i18n>
        </th>
         <th width="10%" style="text-align:center" class="required" id = "required"><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.ActionRequired</emxUtil:i18n></th>
        </tr>
        <tr class = "routeName">
			<td ><br><h2><emxUtil:i18n localize="i18nId">LS.emxComponents.Lable.RouteName</emxUtil:i18n></h2><br></td>
			<td ><h2><%=routeName%></h2></td>
			<input type = "hidden" name = "startedRouteExist" value="<%=routeStatus%>">
			<input type = "hidden" name = "routeId" value="<%=routeId%>">
			<td><%=" "%></td>
		</tr>		
        <tr class='odd'>
        	<td style="vertical-align:top"> <!-- Title, Action & Number Column -->
		 	<table>
				<tbody>
                	<tr><!-- Title Field -->
                  		<td>
							<table>
       							<tr>
						 			<td>
										<td><input type="text" name="textTitle" value="<%=sTaskTitle %>"></td>		
		 							</td>
       							</tr>
		 					</table>
		 				</td>
		 			</tr>		 				
		 			<tr><!-- Action -->
                   		<td>
							<table>
								<tbody>						
									<tr>
										<td style="font-weight: bold;padding-top:10px;padding-bottom: 2px;">
											<emxUtil:i18n localize = "i18nId">emxComponents.common.Action</emxUtil:i18n>
        								</td>
      								</tr>
        							<tr>
		 								<td>
                								<select name="routeAction">
<%
								                 for(int i5=0; i5< routeActionList.size() ; i5++) {
								                    String rangeValue = (String)routeActionList.get(i5);
								                    String sChecked = "";
								                    if(rangeValue.equals("Approve"))
								                    {
								                    	sChecked = "selected=\"true\"";
								                    }
								                    String i18nRouteAction= getRangeI18NString(routeObj.ATTRIBUTE_ROUTE_ACTION, rangeValue, sLanguage);
%>
													<option value="<%=rangeValue%>" <%=sChecked%>> <%=i18nRouteAction%> </option>
<%
								                 }
%>
												</select>
											
										</td>
									</tr>
		 							<tr> <!-- Order Field -->
										<td>
											<table>
												<tbody>
												  <tr>
												  <td style="font-weight: bold;padding-top:10px;padding-bottom: 2px;">
													<emxUtil:i18n localize = "i18nId">emxComponents.RouteAction.Order</emxUtil:i18n>
        											</td>
												  </tr>
												   <tr>
													   <td>
			                								<select name="routeOrder">
															<%
											                 for(int i5=0; i5< sOrderList.size() ; i5++) {
											                    String rangeValue = (String)sOrderList.get(i5);
											                    String i18nOrder= getI18NString("emxComponentsStringResource","LS.emxComponents.Common.MoreSigned." + rangeValue, sLanguage);
															%>
																<option value="<%=rangeValue%>"> <%=i18nOrder%> </option>
															<%
											                 }
															%>
															</select>
														</td>
													</tr>
												</tbody>
											</table>
										</td>
									</tr>
								</tbody>
							</table>
						</td>
					</tr>						
				</tbody>
			</table>
  		</td>
        	<td class="inputField">
	      <table border="0">
		           <tr>
			           <td>
			           		<select style="min-height:150px;width:240px;" id="assignPerson" name="assignPerson" multiple='multiple' size='6' >
						    </select>
				       </td>
				       <td>
							<input type = "button" name= "assignPerson" value = "<%=buttonAdd%>" onclick="javascript:showSearchWindow(this.name,'','', '')"><br>
							<input type = "button" name = "assignPerson" value = "<%=buttonDelete%>" onclick="deleteSelectOption(this.name)"><br>
				       </td>
			        </tr>
	      </table>
	    </td>
        	<td>
        	<textarea style="min-height:150px;width:250px;" rows="6" id = "routeInstructions" name="routeInstructions" ><%=routeInstructions %></textarea>
        	</td>
        	<td>
        		<table>
        			<tr>
         				<td><input type="radio" value="Any" name="radioAction"/></td>
	                   <td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Any</emxUtil:i18n></td>
	                   <td><input type="radio"  value="All" name="radioAction"/ checked="checked"> </td>
	                   <td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.All</emxUtil:i18n></td>
                   </tr>
	            </table>
        	</td>
        </tr>
        
        
        
  </tbody>	
</table>
</form>
		
		<%
}catch(Exception e){
	%>
        </tr>
        <tr><td>
        <emxUtil:i18n localize="i18nId">LS.emxComponents.Common.MassDistribution.NoTaskMsg</emxUtil:i18n>
        </td></tr>
	</tbody>
	</table>
	</form>
	
	<%
}
%>
	
<!-- Java script functions -->
<script type = "text/javascript">

	var tempSelectId = "";
	function showSearchWindow(selectId,actionType,routeId,sSequence){
		var personIds = "";
		var selectObj = document.getElementById(selectId);
		
		for(var j = 0;j<selectObj.options.length;j++){
			var selectPeopleId = selectObj[j].value;
			selectPeopleId = selectPeopleId.substring(selectPeopleId.lastIndexOf("~")+1,selectPeopleId.length);
			if(j == selectObj.options.length-1){
				personIds = personIds + selectPeopleId;
			}else{
				personIds = personIds + selectPeopleId +"|";
			}
		}
		
	    var strURL="../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&form=AEFSearchPersonForm&"+
	    		"suiteKey=Components&hideHeader=true&selection=multiple&type=PERSON_CHOOSER&table=AEFPersonChooserDetails&"+
	    		"submitURL=../common/LSPersonSaerchSubmit.jsp&onSubmit=top.opener.submitSearchPerson&showInitialResults=false&"+
	    		"selectId="+selectId+"&excludeOIDS="+personIds+ "&routeSequence=" + sSequence + 
	    		"&actionType="+actionType+"&routeId="+routeId;
	    tempSelectId = selectId;
		showSearch(strURL);
	}
	
	
	function routeTemplateChooser_onclick(strFieldHiddenName, strFieldDisplayName, strFieldHiddenObjId,strOriRouteId,srtConnectObjId) {
	
     	var strURL="../common/emxFullSearch.jsp?field=TYPES=type_RouteTemplate:CURRENT=policy_RouteTemplate.state_Active:LATESTREVISION=TRUE&"+
	    		"suiteKey=Components&hideHeader=true&selection=single&showInitialResults=true&table=APPECRouteTemplateSearchList&"+
	    		"submitURL=../components/LSRouteWizardSearchTemplateDialogProcess.jsp&onSubmit=top.opener.refrechPaticipatePage&strOriRouteId=" + strOriRouteId +
				"&srtConnectedObjId=" + srtConnectObjId;	 
		showSearch(strURL);
    }
	
	function refrechPaticipatePage(){
		var strURL = "../common/LSRouteTaskMoreSignedDialogFS?objectId=<%=sTaskId%>";
		window.parent.parent.location.href = strURL;
	}
	
	function submitSearchPerson(arrSelectedObjects,selectId){
    	var selectObj = document.getElementById(tempSelectId);
    	for (var i = 0; i < arrSelectedObjects.length; i++) {
	        var objSelection = arrSelectedObjects[i];
	        var objForm = document.forms["taskAppointedParticipants"];
	        var personName =objSelection.lastName+", "+objSelection.firstName;
	        var personValue ="~Person~"+objSelection.objectId;
	        var varItem = new Option(personName,personValue);      
	        selectObj.options.add(varItem);     
	    }
    	
    	for(var i = selectObj.options.length - 1;i >=0 ;i--)
    	{
    		var selValue = selectObj[i].value;
    		if(selValue.indexOf("Route Task User") > 0){
    			selectObj.remove(i);
    		}
    	}
    }
	
	
	function deleteSelectOption(selectId){
    	var selectObj = document.getElementById(selectId);
    	var selectedFalge = false;
    	for(var i= 0;i<selectObj.options.length;i++){
    		if(selectObj[i].selected == true){
    			selectedFalge = true;
    			break;
    		}
    	}
    	
    	if(!selectedFalge){
    		alert("<emxUtil:i18nScript localize="i18nId">LS.emxComponents.AssignTask.PleaseSelectPerson</emxUtil:i18nScript>");
    		return;
    	}
    	//edit for delete all people
    	/* var flage= true; 
    	flage = delSelectValidate(selectId);
    	if(!flage){
    		return false;
    	} */
    	var selectObj = document.getElementById(selectId);
    	for(var i = selectObj.options.length-1;i>=0;i--){
    		if(selectObj[i].selected == true){
    			selectObj.remove(i);
    		}
    	}
    }
    
    function delSelectValidate(selectId){
    	var selectObj = document.getElementById(selectId);
    	var content = 0;
    	for(var i = 0;i<selectObj.options.length;i++){
    		if(selectObj[i].selected == true){
    			content++;
    		}
    	}
    	if(content == selectObj.options.length){
    		alert("Dont delete all");
    		return false;
    	}
    	return true;
    }
	
	function cancel_onclick() {
	    window.top.close();
		
	}
	
</script>

<script type="text/javascript">

   function done_onclick() {
	   
	   var textTitle = document.getElementsByName("textTitle")[0];
	   
	   if(textTitle.value == "")
	   {
		   alert("<emxUtil:i18nScript localize="i18nId">LS.emxComponents.AssignTask.InputTitle</emxUtil:i18nScript>");	
		   textTitle.focus();
		   return;
	   }
	   
	   var selectList = document.getElementsByTagName("select");
	   var textarerList = document.getElementsByTagName("textarea");
	   
	   for(var i = 0;i < selectList.length; i++){
		   var objSelect  = selectList[i];
		   if(objSelect.options.length == 0){
	    		alert("<%=strAssignedPeopleCannotNull%>");	
	    		return;
	    	}
	   }
	   
	  for(var i = 0;i<textarerList.length;i++){
		 var strRouteInst = textarerList[i];
	   	 if(trimtext(strRouteInst.value).length==0){
    		alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTask.AlertInstruction</emxUtil:i18nScript>");
    		routeInstructionsObj.value="";
    		routeInstructionsObj.focus();
    		return;
    	 }
	  }	
	 
      var objForm = document.taskAppointedParticipants;
        
      objForm.actionType.value = "Done";
      for(var i1 = 0;i1<selectList.length;i1++){
      	var strpersonDataaId = selectList[i1];
      	if(strpersonDataaId.name == "assignPerson")
     	{
      		for(var j = 0;j<strpersonDataaId.options.length;j++){
        		if(strpersonDataaId[j].selected !=true){
        			strpersonDataaId[j].selected=true;
        		}
        	}
    	}
      }

	  objForm.submit();
	  return;
   
   }
   //-----------------------------------------------------------------------------------
   // Function to trim strings
   //-----------------------------------------------------------------------------------

   function trimtext (str) {
     return str.replace(/\s/gi, "");
   }
   
   function   Trim(value){ 
	   var   res   =   value.replace(/^[\s]+|[\s]+$/g,""); 
	   return   res; 
	}
</script>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>
