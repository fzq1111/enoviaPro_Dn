<%--  emxLifecycleAddApprover.jsp   -   <description>

   Copyright (c) 1992-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: MJemxTaskAppointedParticipantsDialog.jsp.rca 1.11.3.2 Wed Oct 22 15:48:45 2008 przemek Experimental przemek $
--%>
<%-- <%@include file="../common/emxNavigatorInclude.inc"%> --%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%-- <%@include file = "../emxJSValidation.inc" %> --%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.DomainObject"%>
<%@ page import="java.util.List"%>

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
  <!-- <script type="text/javascript"> addStyleSheet("emxUITypeAhead"); </script></head> -->
<!-- Bug #345799: Type Ahead Implementation -->
<%
	String strParentObjectId = emxGetParameter(request, "objectId");
	  String stateAssigned    = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_INBOX_TASK, "state_Assigned");
      String stateReview      = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_INBOX_TASK, "state_Review");
      String stateTaskComplete      = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_INBOX_TASK, "state_Complete");
	  String timeStamp = emxGetParameter(request,"timeStamp");
	  String portalMode =  emxGetParameter(request,"portalMode");
	  String parentOID = emxGetParameter(request,"parentOID");
	  
	  String timeZone                       = (String)session.getValue("timeZone");
	  String fromPage                        = emxGetParameter(request,"fromPage");  
	String strAssignedPeopleCannotNull = getI18NString("emxComponentsStringResource","emxComponents.CreateDocument.AssignedPeopleCanotEmpty", sLanguage);
	  String roleI18N = "(" + getI18NString("emxComponentsStringResource","emxComponents.Common.Role", sLanguage) + ")";
	  String groupI18N = "(" + getI18NString("emxComponentsStringResource","emxComponents.Common.Group", sLanguage) + ")";
	String temp_hhrs_mmin                 = getAppProperty(context,application,"emxComponents.RouteScheduledCompletionTime");
	String sAttParallelNodeProcessionRule = PropertyUtil.getSchemaProperty(context, "attribute_ParallelNodeProcessionRule");
	String buttonAdd = getI18NString("emxFrameworkStringResource","LS.emxFramework.Common.AssignedToParticipants.button.Add", sLanguage);
	String buttonDelete = getI18NString("emxFrameworkStringResource","LS.emxFramework.Common.AssignedToParticipants.button.Delete", sLanguage);
	String buttonReplace = getI18NString("emxFrameworkStringResource","LS.emxFramework.Common.AssignedToParticipants.button.Replace", sLanguage);
	
	Calendar calendar                     = new GregorianCalendar();
	int intDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
	double clientTZOffset   = (new Double(timeZone)).doubleValue();
	boolean showDefaultDate     = false;  // flag shows date only for calendar option
	if(fromPage == null || "null".equals(fromPage)){
	    fromPage = "";
	  }

	  if("task".equals(fromPage)){
	    // set true only if this dialog page called from Route Summary page.
	    showDefaultDate = true;
	  }
	
	  int AllowDelegtionCount         = 0;
	  int NeedsReviewCount                  = 0;
	  String FinishChecker="";
	  String CH_AllowReAsign="";
	  String routeId = null;
	  String routeCurrent = null;
	  String attrBaseState = null;
	  String attrBasePolicy = null;
	  
	  String sAsigneeId        = "";
	  String sRelId            = "";
	  String sTypeName         = "";
	  String sRouteNodeID      = "";
	  String sSequence         = "";
	  String sConnectedRoute   = "";
	  String sName             = null;
	  String sAsignee          = null;
	  String sDueDate          = null;
	  String sAllowDelegation  = null;
	  String sAction           = null;
	  String sReviewTask       = null;
	  String sInstruction      = null;
	  String sRouteState       = null;
	  String sTaskId           = null;
	  String sAssigneeDueDate  = null;
	  String sSelected         = "";
	  String tempId            = "";
	  String sDisplayPersonName             = "";
	  String strDisabled = "";
	  int taskCount      = 0;
	  int xx             = 0;
	  int hhrs           = 0;
	  int mmin           = 0;
	  int intSeq         = 1;
	  String parentTaskDueDate = "";
	  SelectList selectStmts = new SelectList();
		String routeStatusValue = ""; 
	  //For creating a new revision of Route template
	  Pattern relPattern                          = null;
	  Pattern typePattern                         = null;
	  SelectList selectStmt                       = null;
	  SelectList selectRelStmt                    = null;
	  Vector vectTitles                     = new Vector();
	  Vector vectAssignedTitles             = new Vector(); //Added for Bug-310065
	  boolean bOwnerNotSetDate              = false;
	  boolean bAssigneeDueDate              = false;
	  boolean bDeltaDueDate                 = false;
	  boolean bDueDateEmpty                 = false;
	  Date maxDueDate                      = null;
	  String actualRouteNodeId             = null;
	  String maxOrder                      = "0";
	  String routeSequenceValueStr1         = null;
	  java.util.List tempTitleList = new ArrayList();
	  java.text.SimpleDateFormat USformatter = new java.text.SimpleDateFormat ("MM/dd/yyyy hh:mm:ss a");
	  BusinessObject boRouteNode = null;
	  StringList strRouteMembers = new StringList();
	  // looping into physical tasks - Complete and In progress.

%>

<form name="taskAppointedParticipants"  id="taskAppointedParticipants" method="post"
								action="LSTaskAppointedParticipantsRequired.jsp" target="pagehidden">
	<input type="hidden" name="actionType" value="">
	<input type="hidden" name="objectId" value="<%=routeId%>">
<table class="list"  id="taskList">
<tbody>	
		<tr>
        <th id = "required" width="20%" style="text-align:center;background-color:red;">
        	<emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.TitleActionOrder</emxUtil:i18n>
        	</th>
        <th id = "required" class="required" width="25%" style="text-align:center">
      	  <emxUtil:i18n localize="i18nId">emxComponents.Common.AssignedToParticipants.Assignee</emxUtil:i18n>
        </th>
        <th id = "required" class="required" width="25%" style="text-align:center">
        	<emxUtil:i18n localize="i18nId">emxComponents.Common.AssignedToParticipants.Instructions</emxUtil:i18n>
        </th>
         <th width="10%" style="text-align:center" class="required" id = "required"><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.ActionRequired</emxUtil:i18n></th>
        </tr>
<% 
	StringList routeIDList = new StringList();
try{
	String routeObjectIDS = emxGetParameter(request, "routeObjectIDS"); 
	String objectId = emxGetParameter(request,"objectId");
	
	if(routeObjectIDS == null || routeObjectIDS.equals("") || routeObjectIDS.equals("null")){
		routeIDList.add(objectId);
		DomainObject domObjectTemp = DomainObject.newInstance(context,objectId);
		if(!(domObjectTemp.getType(context).equals(DomainObject.TYPE_ROUTE))){
			throw new RuntimeException("No Route");
		}
	}else{
		routeIDList = FrameworkUtil.split(routeObjectIDS, "~");
	}
	Route routeObj = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
	selectStmts = new SelectList();
	selectStmts.addName();
	selectStmts.addId();
	selectStmts.addType();
	selectStmts.addAttribute(DomainObject.ATTRIBUTE_TEMPLATE_TASK);
	com.matrixone.apps.common.Person PersonObject = (com.matrixone.apps.common.Person) DomainObject.newInstance(context, DomainConstants.TYPE_PERSON);
	  typePattern = new Pattern(DomainObject.TYPE_PERSON);
	  typePattern.addPattern(DomainObject.TYPE_ROUTE_TASK_USER);
	  StringList relSelStmts = new StringList();
	  relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_ROUTE_TASK_USER+"]");
	  relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_ROUTE_SEQUENCE+"]");
	  relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_ALLOW_DELEGATION+"]");
	  relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_ROUTE_ACTION+"]");
	  relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_ROUTE_INSTRUCTIONS+"]");
	  relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_TITLE+"]");
	  relSelStmts.addElement("attribute["+routeObj.ATTRIBUTE_SCHEDULED_COMPLETION_DATE+"]");
	  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE+"]");
	  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_REVIEW_TASK+"]");
	  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
	  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_NODE_ID+"]");
	  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_DUEDATE_OFFSET+"]");
	  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_DATE_OFFSET_FROM+"]");
	  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_TEMPLATE_TASK+"]");
	  relSelStmts.addElement("attribute[HS Org Id]");
	//  relSelStmts.addElement("attribute[TMT Route Task Finish Checker]");
	  relSelStmts.addElement("attribute[LS Allow ReAssign]");
	  
	MapList routeNodeList = null;
	MapList inboxTaskList = null;
	
	SelectList taskSelectStmts = new SelectList();
	taskSelectStmts.addId();
	taskSelectStmts.addAttribute(DomainObject.ATTRIBUTE_TEMPLATE_TASK);
	taskSelectStmts.add("attribute["+Route.ATTRIBUTE_ROUTE_NODE_ID+"]");
	taskSelectStmts.add(DomainConstants.SELECT_ID); //Added for Bug-310065
	taskSelectStmts.add(DomainConstants.SELECT_CURRENT); //Added for Bug-310065
	taskSelectStmts.add("from[" + routeObj.RELATIONSHIP_PROJECT_TASK + "].to.id"); //Added for Bug-310065
	taskSelectStmts.addElement("attribute["+routeObj.ATTRIBUTE_ROUTE_SEQUENCE+"]");
	HashMap sequenceMap = new HashMap();
	String strSequence = "";
	// variables for date formatting scheduled dates below..
	Date taskDueDate = null;
	//converting the date to Lzdate format in java
	String finalLzDate = null;
	
	String routeSequence                        = null;
	
	String routeSequenceValueStr                = null;
	String routeAllowDelegationStr              = null;
	String routeInstructionsValueStr            = null;
	String taskNameValueStr                     = null;
	String personName                           = null;
	String routeScheduledCompletionDateValueStr = null;
	long routeScheduledCompletionDateValueMilli = 0;
	String routeActionValueStr                  = null;
	String routeAssigneeDueDateOptStr           = null;
	String taskReviewTaskStr                    = null;
	String routeDueDateDeltaStr                 = "";
	String routeDueDateOffsetFromStr            = "";
	String sRelId2 = "";
	DomainRelationship rel =null; 
	Map taskMap = null;
	String strType = "";
	String routeName = "";
	String sRoute = "";
	
	// Get route information
	  final String SELECT_ATTRIBUTE_ROUTE_STATUS = "attribute[" + DomainObject.ATTRIBUTE_ROUTE_STATUS + "]";
	  final String ATTRIBUTE_CURRENT_ROUTE_NODE = PropertyUtil.getSchemaProperty(context, "attribute_CurrentRouteNode");
	  final String SELECT_ATTRIBUTE_CURRENT_ROUTE_NODE = "attribute[" + ATTRIBUTE_CURRENT_ROUTE_NODE + "]";

	  StringList selStmt = new StringList();
	  selStmt.add(DomainObject.SELECT_CURRENT);
	  selStmt.add("from[" + DomainObject.RELATIONSHIP_INITIATING_ROUTE_TEMPLATE + "].to.id");
	  selStmt.add(SELECT_ATTRIBUTE_ROUTE_STATUS);
	  selStmt.add(SELECT_ATTRIBUTE_CURRENT_ROUTE_NODE);
	  StringList strSelObjRoute= new StringList();
	  strSelObjRoute.addElement(DomainObject.SELECT_ID);
	  StringList selRelItem = new StringList();
	  selRelItem.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_POLICY+"]");
	  selRelItem.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_STATE+"]");
	  selRelItem.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_BASE_PURPOSE+"]");
	for(int i = 0;i < routeIDList.size();i++){
		StringList routeTaskUserList = new StringList();
		routeId = (String)routeIDList.get(i);
		routeObj.setId(routeId);
		//add by ryan 2017-03-25
		String strCurrRouteStatus = routeObj.getAttributeValue(context, "Route Status");
		String strCurrState = routeObj.getInfo(context, "current");
		String strDisTaskEditable = "";
		if(strCurrRouteStatus.equals("Started") || strCurrState.equals("Complete"))
		{
			strDisTaskEditable = "disabled";
		}
		//add end
		routeName = routeObj.getName(context);
		MapList ObjectRoute =  routeObj.getRelatedObjects(context, DomainObject.RELATIONSHIP_OBJECT_ROUTE, "*",strSelObjRoute,selRelItem,true,false,(short)1,null,null);
		
		AttributeType attrRouteAction = new AttributeType(DomainConstants.ATTRIBUTE_ROUTE_ACTION);
	    attrRouteAction.open(context);
	   // Remove the Info Only and Investigate ranges which we no longer support - Bug 347955
	   StringList routeActionList = attrRouteAction.getChoices(context);
	   routeActionList.remove ("Information Only");
	   routeActionList.remove ("Investigate");
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
	//Modified for bug 359347
	  Collections.sort ((java.util.List)routeActionList); // To maintain order Approve, Comment, Notify Only
	  attrRouteAction.close(context);
		//get RouteNodeList
		
		routeNodeList = routeObj.getRelatedObjects(context, DomainObject.RELATIONSHIP_ROUTE_NODE,
												typePattern.getPattern(),
												selectStmts, relSelStmts, 
												false, true,
												(short)1, "",
												"",null,
												null,null);
		routeNodeList.sort("attribute["+routeObj.ATTRIBUTE_ROUTE_SEQUENCE+"]", "ascending","integer");
		%>
		<tr class = "routeName">
			<td ><br><h2><emxUtil:i18n localize="i18nId">emxComponents.Lable.RouteName</emxUtil:i18n></h2><br></td>
			<td ><h2><%=routeName%></h2></td>
			<input type = "hidden" name = "routeId" value="<%=routeId%>">
			<td><%=" "%></td>
		</tr>		
		<%
		 Map routeMap = routeObj.getInfo(context, selStmt);
		  sRouteState  = (String)routeMap.get(DomainObject.SELECT_CURRENT);
		  String strRouteStatus = (String)routeMap.get(SELECT_ATTRIBUTE_ROUTE_STATUS);
		  String strCurrentRouteLevel = (String)routeMap.get(SELECT_ATTRIBUTE_CURRENT_ROUTE_NODE);
		  Person routeOwner = Person.getPerson(context);
		  String routeOwnerName          ="Person~"+routeOwner.getObjectId();

		  tempId= (String)routeMap.get("from[" + DomainObject.RELATIONSHIP_INITIATING_ROUTE_TEMPLATE + "].to.id");
		
		  String strTemplateTaskSetting = getTaskSetting(context,tempId);
		
		//get task List
		inboxTaskList = routeObj.getRelatedObjects(context,DomainObject.RELATIONSHIP_ROUTE_TASK,
													DomainObject.TYPE_INBOX_TASK,taskSelectStmts,null,
													true,false,
													(short)1,"",
													"",null,
													null,null);
		
		 MapList mlFilteredTasks = new MapList();
		 Map mapTempTaskInfo = null;
		 for (Iterator itrInboxTasks = inboxTaskList.iterator(); itrInboxTasks.hasNext();) {
		     mapTempTaskInfo = (Map)itrInboxTasks.next();
		     if (mapTempTaskInfo.get("from[" + routeObj.RELATIONSHIP_PROJECT_TASK + "].to.id") != null) {
		         mlFilteredTasks.add(mapTempTaskInfo);
		     }
		 }
		inboxTaskList = mlFilteredTasks;
		inboxTaskList.sort("attribute["+routeObj.ATTRIBUTE_ROUTE_SEQUENCE+"]", "ascending","integer");
		
		StringList mergeList = new StringList();
		
		for(int orderIndex = 0 ;orderIndex < routeNodeList.size();orderIndex++)
		{
			Map tempSeqMap = (Map)routeNodeList.get(orderIndex);
			strSequence = (String)tempSeqMap.get("attribute["+routeObj.ATTRIBUTE_ROUTE_SEQUENCE+"]");
			String strTitle = (String) tempSeqMap.get("attribute["+routeObj.ATTRIBUTE_TITLE+"]");
			String strRouteAction = (String) tempSeqMap.get("attribute["+routeObj.ATTRIBUTE_ROUTE_ACTION+"]");
			String mergeStr = strSequence + strTitle + strRouteAction;
			if(!mergeList.contains(mergeStr))
			{
				mergeList.addElement(mergeStr);
			}
		}
		
		session.setAttribute("Sequence_"+routeId, mergeList);

		%>
		
		<input type ="hidden" id = "Sequence_<%=routeId%>" name = "Sequence_<%=routeId%>" value = "<%=mergeList%>">
		
<% 

		StringList tempSequenceList = new StringList();

		for(int mergeI = 0 ;mergeI < mergeList.size(); mergeI++)
		{
			boolean modifyFalge = true;
			String isTempTaskStr = "";
			
			String strMerge = (String) mergeList.get(mergeI);
			MapList mlMergeList = new MapList();
			
			for(int i2  = 0;i2 < routeNodeList.size(); i2++)
			{
				Map tempNodeMap = (Map) routeNodeList.get(i2);
				String tempSequence = (String)tempNodeMap.get("attribute["+routeObj.ATTRIBUTE_ROUTE_SEQUENCE+"]");
				String tempTitle = (String) tempNodeMap.get("attribute["+routeObj.ATTRIBUTE_TITLE+"]");
				String tempRouteAction = (String) tempNodeMap.get("attribute["+routeObj.ATTRIBUTE_ROUTE_ACTION+"]");
				String mergeStr = tempSequence + tempTitle + tempRouteAction;
				if(strMerge.equals(mergeStr)){
					mlMergeList.add(tempNodeMap);
				}
			}
			
		
			//add by heyanbo 2014-6-5
			String sAttrRouteStatusValue = routeObj.getAttributeValue(context, "Route Status");
			 String routeTaskUser=""; 
			if("Stopped".equals(sAttrRouteStatusValue))
			{
				modifyFalge = true;
			}
			//end add by heyanbo 2014-6-5
			HashMap personsMap = new HashMap();
			HashMap rolesMap = new HashMap();
			HashMap nobodyMap = new HashMap();
			String strRouteNodeIds = "";
			
			boolean filterFlag=true;
			String temRole="";
			 String temRouteTaskUser ="";
			for(int i4 = 0;i4<mlMergeList.size();i4++)
			{
				taskMap  = (Map)mlMergeList.get(i4);
				
				sRelId2 = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_NODE_ID+"]");
				  //Added for the Bug No:350789 starts
				  strSequence = (String)taskMap.get("attribute["+routeObj.ATTRIBUTE_ROUTE_SEQUENCE+"]");
				  
				  strType =(String) taskMap.get(DomainObject.SELECT_TYPE);
			      routeSequenceValueStr1                = (String)taskMap.get("attribute["+routeObj.ATTRIBUTE_ROUTE_SEQUENCE+"]");
			      sRelId                                = sRelId2;
			      routeActionValueStr                   = (String)taskMap.get("attribute["+routeObj.ATTRIBUTE_ROUTE_ACTION+"]");
			      routeInstructionsValueStr             = (String)taskMap.get("attribute["+routeObj.ATTRIBUTE_ROUTE_INSTRUCTIONS+"]");
			      taskNameValueStr                      = (String)taskMap.get("attribute["+routeObj.ATTRIBUTE_TITLE+"]");
				  strRouteNodeIds +=sRelId2+"|";
			      routeAllowDelegationStr               = (String)taskMap.get("attribute["+routeObj.ATTRIBUTE_ALLOW_DELEGATION+"]");
			      routeScheduledCompletionDateValueStr  = (String)taskMap.get("attribute["+routeObj.ATTRIBUTE_SCHEDULED_COMPLETION_DATE+"]");
			      routeAssigneeDueDateOptStr            = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE+"]");
			      taskReviewTaskStr                     = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_REVIEW_TASK+"]");
			      routeDueDateDeltaStr                  = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_DUEDATE_OFFSET+"]");
			      routeDueDateOffsetFromStr             = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_DATE_OFFSET_FROM+"]");
			      String sTemplateTask                  = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_TEMPLATE_TASK+"]");
			       routeTaskUser                  = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
			      //  FinishChecker = (String)taskMap.get("attribute[TMT Route Task Finish Checker]");
			      //  CH_AllowReAsign = (String)taskMap.get("attribute[CH_AllowReAsign]");
			      //add by caipan
			      StringList seltem = new StringList();
			      seltem.add("id");
			      StringList reltem = new StringList();
			      reltem.add("id");
			      reltem.add("attribute[Route Sequence]");
			      reltem.add("attribute[Route Task User]");
			      DomainObject temObj = new DomainObject(tempId);
			      MapList temList = temObj.getRelatedObjects(context,"Route Node",
							"Route Task User,Person",seltem,reltem,
							false,true,
							(short)1,null,"attribute[Route Sequence]=="+strSequence);
			       temRouteTaskUser ="";
			       
			   
			      if(temList.size()>0){
			    	   temRouteTaskUser = ((Map)temList.get(0)).get("attribute[Route Task User]").toString();
			    	 	
			      }
			      String HSOrgId = (String)taskMap.get("attribute[HS Org Id]");
			   
			
			      
			      //end
			      rel = DomainRelationship.newInstance(context, sRelId);
			      rel.open(context);
			      String typeName                       = rel.getTo().getTypeName();
			      personName                            = rel.getTo().getName();
			      sAsigneeId                            = rel.getTo().getObjectId();
			      if(typeName!=null && routeObj.TYPE_PERSON.equals(typeName)){
					    sAsignee   = rel.getTo().getName();
					    sAsigneeId = rel.getTo().getObjectId();
					    personsMap.put(sRelId, sAsigneeId);
					  }else{
					    sAsigneeId = "Role";
					    sAsignee   = routeTaskUser;
					    if (sAsignee!=null && !"".equals(sAsignee)){
					    	  rolesMap.put(sRelId, sAsignee);  
					        }else{
					        	nobodyMap.put(sRelId,"Route Task User");
					        }
					}
			      sAsignee                              = "";
			      if(DomainObject.TYPE_ROUTE_TASK_USER.equals(typeName) && routeTaskUser!=null && !"".equals(routeTaskUser)){
			          sAsignee = routeTaskUser;
			        }
			        rel.close(context);

			        boolean isTaskAssignedToUser = vectAssignedTitles.contains(sRelId2);
			        String checkDisabled = (isTaskAssignedToUser||
			                					(!"Modify/Delete Task List".equals(strTemplateTaskSetting)&&"Yes".equals(sTemplateTask))) ? "disabled" : "";
			        
			        boolean isTemplateTask = sTemplateTask != null && sTemplateTask.equals("Yes");
			        isTempTaskStr = isTemplateTask?taskNameValueStr+" (t)":taskNameValueStr;
			        
			        boolean canModDelTemplateTask = "Modify/Delete Task List".equals(strTemplateTaskSetting);
			        boolean canModTaskList = "Modify Task List".equals(strTemplateTaskSetting);
			}
			if(strRouteNodeIds.lastIndexOf("|") == strRouteNodeIds.length()-1){
				strRouteNodeIds = strRouteNodeIds.substring(0, strRouteNodeIds.length()-1);
			}
			%>
			<tr class='<framework:swap id="1"/>'>
			 <input type="hidden" name="strRouteNodeIds_<%=routeId%>_<%=strMerge%>" value="<%=strRouteNodeIds%>"/>
			 <input type="hidden" name="strType" value="<%=strType%>"/>
			 <input type="hidden" name="FinishChecker_<%=routeId%>_<%=strMerge%>" value="<%=FinishChecker%>"/> 
			 <input type="hidden" name="CH_AllowReAsign_<%=routeId%>_<%=strMerge%>" value="<%=CH_AllowReAsign%>"/> 
			 <input type = "hidden" name = "modifyTask_<%=routeId%>_<%=strMerge%>" value = "<%=modifyFalge%>">
			 <td style="vertical-align:top"> <!-- Title, Action & Number Column -->
		 	<table>
				<tbody>
                	<tr><!-- Title Field -->
                  		<td>
							<table>
       							<tr>
						 			<td>
		 									<input type="hidden" name="taskName_<%=routeId%>_<%=strMerge%>" value="<%=taskNameValueStr%>">
		 									<%=isTempTaskStr%>
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
<%-- 		 								<framework:ifExpr expr="<%=modifyFalge%>">
                								<select name="routeAction_<%=routeId%>_<%=strSequence%>">
<%
								                 for(int i5=0; i5< routeActionList.size() ; i5++) {
								                    String rangeValue = (String)routeActionList.get(i5);
								                    String i18nRouteAction=getRangeI18NString(PersonObject.ATTRIBUTE_ROUTE_ACTION, rangeValue, sLanguage);
                    								String selected = (routeActionValueStr != null) && routeActionValueStr.equals(rangeValue) ? "selected"  : "";
%>
													<option value="<%=rangeValue%>" <%=selected%>> <%=i18nRouteAction%> </option>
<%
                    							  }
%>
                </select>
                </framework:ifExpr> --%>
               <%--  <framework:ifExpr expr="<%=!modifyFalge%>"> --%>
                	<input type="hidden" name="routeAction_<%=routeId%>_<%=strMerge%>" value = "<%=routeActionValueStr%>">
                	<%=getRangeI18NString(DomainObject.ATTRIBUTE_ROUTE_ACTION,routeActionValueStr,sLanguage)%>
                <%-- </framework:ifExpr> --%>
            </td>
         </tr>
		 							<tr> <!-- Order Field -->
										<td>
											<table>
												<tbody>
      <tr>
											 			<td style="font-weight: bold;padding-top:10px;padding-bottom: 2px;">
           <emxUtil:i18n localize = "i18nId">emxComponents.RouteAction.Order</emxUtil:i18n>&nbsp;
       </td>
      </tr>
           <tr>
           <input type ="hidden" name = "sequence_<%=routeId%>_<%=strMerge%>" value = "<%=strSequence%>">
		 												<td><%=strSequence%>
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
			           <td style="min-height:50px;width:300px;height=120px">
			           		<select style="min-height:50px;width:300px;height:120px" name="personId_<%=routeId%>_<%=strMerge%>" id='personId_<%=routeId%>_<%=strMerge%>' multiple='multiple' size='6' >
			           					           			 <%
			           		
			           			String sDisplayPersonName2="";
			           			String Firstname="";
			           			String Lastname="";
			           			java.util.Set setKey =  personsMap.keySet(); 
			           			 Iterator perIter = setKey.iterator();
			           			 while(perIter.hasNext())
								 {
			           				 String sKeyNodeId =(String) perIter.next();
			           				 String sPersonId2 = (String)personsMap.get(sKeyNodeId);
			           				 Person busPerson2 = new Person();
			           				 busPerson2.setId(sPersonId2);
			           				 busPerson2.open(context);
			           				 sDisplayPersonName = com.matrixone.apps.domain.util.PersonUtil.getFullName(context, busPerson2.getName());
			           				 Firstname = busPerson2.getAttributeValue(context, "First Name");
			           				 Lastname = busPerson2.getAttributeValue(context, "Last Name");
			           				
			           				 busPerson2.close(context);
			           				 sPersonId2 = sKeyNodeId+"~Person~"+sPersonId2;
			           				sDisplayPersonName =busPerson2.getName(context)+"("+Lastname+" "+Firstname+")";
			           				 sDisplayPersonName2="";
	
										if(filterFlag){
											String strPersonRoleName = "";
											if(routeTaskUserList!=null){
												for(int c=0;c<routeTaskUserList.size();c++){
												String	strroleName = PropertyUtil.getSchemaProperty(context,(String)routeTaskUserList.get(c));
													if(busPerson2.hasRole(context,strroleName)){
														strPersonRoleName = strroleName;
														break;
													}
												}
											}
										String	routeTaskUserbak = PropertyUtil.getSchemaProperty(routeTaskUser);
										
												sDisplayPersonName2=i18nNow.getRoleI18NString(strPersonRoleName, sLanguage)+roleI18N;
										}
										sDisplayPersonName=sDisplayPersonName+sDisplayPersonName2;//caipan

			           				%>
						  			<option title="<%=sDisplayPersonName %>" value="<%=sPersonId2%>" ><%=sDisplayPersonName%></option>
<%
			           			 }
			           			java.util.Set setRoleKey =  rolesMap.keySet(); 
			           			 Iterator rolesIter = setRoleKey.iterator();
			           			 while(rolesIter.hasNext()){
			           				 String sKeyNodeId =(String)rolesIter.next();
			           				 String sroleId = (String)rolesMap.get(sKeyNodeId);
			           				 String sType = sroleId.substring(0, sroleId.indexOf("_"));
			                  		 boolean isRole = sType.equals("role");
			                  		 sDisplayPersonName=PropertyUtil.getSchemaProperty(context,sroleId);
			                  		sDisplayPersonName = isRole ?
	 				    			           getAdminI18NString("Role", sDisplayPersonName, sLanguage) + roleI18N:
				    			               getAdminI18NString("Group", sDisplayPersonName, sLanguage) + groupI18N;  
			                  		sroleId = isRole?sKeyNodeId+"~Role~"+sroleId:sKeyNodeId+"~Group~"+sroleId;
			           				%>
			           				<%--  <framework:ifExpr expr="<%=filterFlag%>"> --%>
						  			<option title="<%=sDisplayPersonName %>" value="<%=sroleId%>" ><%=sDisplayPersonName%></option>
						  			<%--  </framework:ifExpr> --%>  
						  			
<%
			           			 }
			           			 if(personsMap.size() < 1 && rolesMap.size()<1)
			           			 {
			           				 if(!routeActionValueStr.trim().equalsIgnoreCase("Notify Only"))
			           				 {
					           			java.util.Set setNobodyKey =  nobodyMap.keySet(); 
					           			 Iterator noBodyIter = setNobodyKey.iterator();
					           			 while(noBodyIter.hasNext()){
					           				 String sKeyNodeId =(String)noBodyIter.next();
					           				 String sroleId = (String)nobodyMap.get(sKeyNodeId);
					           				sroleId = sKeyNodeId+"~"+sroleId;
					           				sDisplayPersonName = getI18NString("emxFrameworkStringResource","CH.emxFramework.Common.AssignedToParticipants.Nobody",sLanguage);
					           				%>
					           				  <framework:ifExpr expr="<%=!filterFlag%>"> 
								  			<option title="<%=sDisplayPersonName %>" value="<%=sroleId%>" ><%=sDisplayPersonName%></option>
								  			 </framework:ifExpr> 
	<%
					           			 }
			           				 }else{
			           					 try{
				           					 String mqlSelectPerson = "temp query bus Person '"+ routeObj.getInfo(context, "owner") + "' * select id dump |";
				           					 String mqlResult = MqlUtil.mqlCommand(context, mqlSelectPerson);
				           					 StringList strPersonObjList = FrameworkUtil.split(mqlResult,"|");
				           					 String mqlPersonId = (String) strPersonObjList.get(strPersonObjList.size()-1);
				           					 Person ownerPerson = new Person(mqlPersonId);
				           					 ownerPerson.open(context);
				           					 String sDisplayOwnerName = com.matrixone.apps.domain.util.PersonUtil.getFullName(context, ownerPerson.getName());
				           					 ownerPerson.close(context);
					           				 String valueOwner = "~Person~"+mqlPersonId;
					           				%>
					           				 <framework:ifExpr expr="<%=!filterFlag%>"> 
								  			<option title="<%=sDisplayOwnerName %>" value="<%=valueOwner%>" ><%=sDisplayOwnerName%></option>
								  			 </framework:ifExpr> 
											<%
			           					 }catch(Exception e){
			           						 e.printStackTrace();
			           					 }
			           					 
			           				 }
			           			 }
%>
						    </select>
				       </td>
				       <td>
				    <% 
				    boolean actionflag = true;
				    
				    %>
				        <framework:ifExpr expr="<%=actionflag%>"> 
					   	
							<%
							String resultRouteTask = "";
							for(int u=0;u<routeTaskUserList.size();u++){
								if(u<routeTaskUserList.size()-1){
								resultRouteTask = (String)routeTaskUserList.get(u)+","+resultRouteTask;
								}else{
									resultRouteTask = resultRouteTask+(String)routeTaskUserList.get(u);
								}
							}
							routeTaskUserList.clear();
							Map programMap = new HashMap();
							programMap.put("routeNodeId",sRelId);
							String[] methodargs = JPO.packArgs(programMap);
							StringList result = (StringList)JPO.invoke(context, "LSCreateRouteUtil", null, "getLSApproverRange", methodargs, StringList.class);
							if(result.size()>0)
							{

							%>
								<input type = "button" <%=strDisTaskEditable %> name= "personId_<%=routeId%>_<%=strMerge%>" value = "<%=buttonAdd%>" onclick="javascript:showSearchWindow(this.name,'<%=routeActionValueStr%>','<%=routeId%>','<%=resultRouteTask%>')"><br>
							<%
							}else{
							%>
								<input type = "button" <%=strDisTaskEditable %> name= "personId_<%=routeId%>_<%=strMerge%>" value = "<%=buttonAdd%>" onclick="javascript:showSearchWindowWithoutInclude(this.name,'<%=routeActionValueStr%>','<%=routeId%>','<%=resultRouteTask%>')"><br>
					<%
							}
							%>
							<input type = "button" <%=strDisTaskEditable %> name = "personId_<%=routeId%>_<%=strMerge%>" value = "<%=buttonDelete%>" onclick="deleteSelectOption(this.name)"><br>
							<%
								Map programMapx = new HashMap();
								programMapx.put("routeNodeId",sRelId);
								programMapx.put("routeId",routeId);
								String[] methodarg = JPO.packArgs(programMapx);
								Boolean result1 = (Boolean)JPO.invoke(context, "LSCreateRouteUtil", null, "checkRouteNodeDelete", methodarg, Boolean.class);
								if(result1)
								{
							%>	
									<!-- <input type = "button" name = "personId_<%=routeId%>_<%=strMerge%>" value = "<%="\u5220\u9664\u6B64\u8282\u70B9"%>" onclick="deleteRouteNode(this.name)"><br> -->

							<%		
								}
							%>
							
						</framework:ifExpr> 
				       </td>
			        </tr>
	      </table>
	    </td>
  		<td>
	  
	     	<textarea style="min-height:50px;width:250px;" rows="6" id = "routeInstructions_<%=routeId%>_<%=strMerge%>" name="routeInstructions_<%=routeId%>_<%=strMerge%>" readonly="readonly"><%=routeInstructionsValueStr%></textarea>
	   
	    
	    </td>
  		
  	<%
          if(mlMergeList.size()>0){
        	  String strCheckedAny = "";
        	  String strCheckedAll = "";
        	  DomainRelationship routeNode =null;
              try{
                  routeNode = DomainRelationship.newInstance(context,sRelId);
              }catch(Exception ect){
                  System.out.println("EXCEPTION step4 Dialog radioSelectedMap :: "+ect.getMessage());
              }
             if(routeNode!=null){
	              String parallelNodeValue= routeNode.getAttributeValue(context,sAttParallelNodeProcessionRule);
	              if(parallelNodeValue.equalsIgnoreCase("Any")){
	                 strCheckedAny = "checked";
	              } else if(parallelNodeValue.equalsIgnoreCase("All")|| parallelNodeValue.trim().length()==0){
	                 strCheckedAll = "checked";
	              }
	              if(modifyFalge){
	           		strDisabled = "";
	           	}else{
	           		strDisabled = "disabled";
	           	}
			%>
          <td>
          	<%
          		if(!tempSequenceList.contains(strSequence)){
          	%>
	          	<table><tr>
	          			<td><input  type="radio" value="Any" disabled="disabled" name="radioAction_<%=routeId%>_<%=strSequence%>" <%=strCheckedAny%> /></td>
	                   <td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Any</emxUtil:i18n></td>
	                   <td><input  type="radio" disabled="disabled"  value="All" name="radioAction_<%=routeId%>_<%=strSequence%>" <%=strCheckedAll%> /> </td>
	                   <td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.All</emxUtil:i18n></td>
	                   </tr>
	            </table>
	            
	            <%
	            }
          	if(!tempSequenceList.contains(strSequence)){
       		 	tempSequenceList.addElement(strSequence);
       	 	}
	            %>
          </td>
          <%
             }
		}
%>
			</tr>
			
			<%
			
		}
	}
%>
  </tbody>	
</table>
</form>
		
		<%
}catch(Exception e){
	%>
        </tr>
        <tr><td>
        <emxUtil:i18n localize="i18nId">emxComponents.Common.AssignedToParticipants.NoTaskMsg</emxUtil:i18n>
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
	function showSearchWindow(selectId,actionType,routeId,routeTaskUser){
	
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
		//:USERROLE="+routeTaskUser+"
	    var strURL="../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&form=PMCCommonPersonSearchForm&queryLimit=500&"+
	    		"suiteKey=Components&hideHeader=true&selection=multiple&showInitialResults=true&type=PERSON_CHOOSER&table=AEFPersonChooserDetails&"+
	    		"submitURL=../common/LSCommonPersonSearchSubmit.jsp&onSubmit=top.opener.submitSearchPerson&"+
	    		"includeOIDprogram=LSCreateRouteUtil:getLSApproverRange&selectId="+selectId+"&excludeOIDS="+personIds+
	    		"&actionType="+actionType+"&routeId="+routeId+"&routeTaskUser="+routeTaskUser;
	    tempSelectId = selectId;
		showSearch(strURL);
	}
	
		function showSearchWindowWithoutInclude(selectId,actionType,routeId,routeTaskUser){
	
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
		//:USERROLE="+routeTaskUser+"
	    var strURL="../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&form=PMCCommonPersonSearchForm&queryLimit=500&"+
	    		"suiteKey=Components&hideHeader=true&selection=multiple&showInitialResults=false&type=PERSON_CHOOSER&table=PMCCommonPersonSearchTable&includeOIDprogram=LSCreateRouteUtil:includeRoutePerson&"+
	    		"submitURL=../common/LSCommonPersonSearchSubmit.jsp&onSubmit=top.opener.submitSearchPerson&"+
	    		"&selectId="+selectId+"&excludeOIDS="+personIds+
	    		"&actionType="+actionType+"&routeId="+routeId+"&routeTaskUser="+routeTaskUser;
	    tempSelectId = selectId;
		showSearch(strURL);
	}
	
	function submitSearchPerson(arrSelectedObjects,selectId,routeTaskUser,RoleI18n){
	
    	var selectObj = document.getElementById(tempSelectId);
    	for (var i = 0; i < arrSelectedObjects.length; i++) {
	        var objSelection = arrSelectedObjects[i];
			
	        var objForm = document.forms["taskAppointedParticipants"];
	        var personName =objSelection.name+"("+objSelection.lastName+", "+objSelection.firstName+")";
			if(routeTaskUser!="null"||routeTaskUser!=""){
				//personName = personName+objSelection.roleName+RoleI18n;
			}
	        var personValue ="~Person~"+objSelection.objectId;
	        var varItem = new Option(personName,personValue);      
	        selectObj.options.add(varItem);     
	    }
    	
    	for(var i = selectObj.options.length - 1;i >=0 ;i--)
    	{
    		var selValue = selectObj[i].value;
			
    		if(selValue.indexOf("Route Task User") > 0){
    			selectObj.remove(i);
    		}if(selValue.indexOf("Role") > 0){
    			selectObj.remove(i);
    		}
    	}
    }
	
	function deleteRouteNode(selectId)
	{
		var url = "../common/LSDeleteRouteNode.jsp?selectId="+selectId;
		showModalDialog(url, "600", "700",false,false);
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
    		alert("Plase Select");
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
    	for(var j = 0;j<strpersonDataaId.options.length;j++){
    		if(strpersonDataaId[j].selected !=true){
    			strpersonDataaId[j].selected=true;
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
