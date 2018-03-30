<%-- emxProgramCentralWBSHiddenProcess.jsp

  Displays the tasks/phases for a given project.

  Copyright (c) 1992-2015 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = "$Id: emxProgramCentralWBSHiddenProcess.jsp.rca 1.1.1.4.3.2.2.2 Fri Dec 19 05:48:40 2008 ds-panem Experimental $";
--%>
<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%

    com.matrixone.apps.common.Task task = (com.matrixone.apps.common.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK,"Common");
    //taskPolicy,activeState, sLanguage

    //Modified:26-Mar-2010:s2e:R209 PRG:IR-022896V6R2011
    boolean istypeProjectSpace = false;
    String isKindOfExperimentProject = DomainObject.EMPTY_STRING;
    //End:26-Mar-2010:s2e:R209 PRG:IR-022896V6R2011    
    String strMode = (String) emxGetParameter(request, "mode"); 
    strMode = XSSUtil.encodeURLForServer(context, strMode);
    String sLanguage = request.getHeader("Accept-Language");
    String showSel       = emxGetParameter(request, "mx.page.filter");
    String tableRowIdList[] = emxGetParameterValues(request, "emxTableRowId");
    String emxTableRowId=emxGetParameter(request, "emxTableRowId");    
    String objectId      = emxGetParameter(request, "objectId");
    objectId = XSSUtil.encodeURLForServer(context, objectId);
    String calledMethod      = emxGetParameter(request, "calledMethod");
    calledMethod = XSSUtil.encodeURLForServer(context, calledMethod);
    String suiteKey = emxGetParameter(request, "suiteKey");
    suiteKey = XSSUtil.encodeURLForServer(context, suiteKey);
    String strRootObjectId = emxGetParameter(request, "rootObjectId"); // [ADDED::PRG:rg6:Jan 1, 2011:IR-076444V6R2012 :R211]
    boolean isFromRMB = "true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB"));
    String edit = "false";
    boolean isECHInstalled = com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appVersionEnterpriseChange",false,null,null);
	String currentFrame = XSSUtil.encodeURLForServer(context, emxGetParameter(request, "portalCmdName"));

//Added for bug 358843           
    StringBuffer strAppendParameters = new StringBuffer(128);
    Enumeration params = emxGetParameterNames(request); 
    while (params.hasMoreElements()) 
    { 
        String strParamName = (String)params.nextElement(); 
        String[] strParamValues = emxGetParameterValues(request,strParamName); 

        for (int i = 0; i < strParamValues.length; i++) 
        { 
            if (strAppendParameters.length() > 0)
            {
                strAppendParameters.append("&");
            }
          //Added:11-Mar-10:rg6:R209:PRG Bug :030738
          /*
           the below condition is added in order to reset the csvData parameter 
           which is creating problem in executing javascript's which are 
           opening dailog box for different action commands of WBS Toolbar
           with url having 'strAppendParameters' in thier parameter.
           
          */
            if("csvData".equalsIgnoreCase(strParamName))
            {
                strParamValues[i]="";
            }
            //strParamValues[i] = XSSUtil.encodeForURL(context, strParamValues[i]);
          //End:11-Mar-10:rg6:R209:PRG Bug :030738
            strAppendParameters.append(strParamName).append("=").append(strParamValues[i]);
        } 
    } 
	strAppendParameters = new StringBuffer(XSSUtil.encodeURLForServer(context,strAppendParameters.toString()));

//End addition for bug 358843

    int selectCount = 0;
    String selectedTaskIds = "";
    String selectedTaskStates = "";
    String selectedTaskPolicys = "";
    String selectedTaskParentStates = "";
    String deletedTasks = "";
    String selectedTaskRelIds = "";
    String selectedRowIds = "";
    boolean parentSelected = false;
    boolean subProjectTasksSelected = false;

    DomainObject object = new DomainObject();

    StringList sList = new StringList(8);
    sList.addElement(DomainConstants.SELECT_CURRENT);
    sList.addElement(DomainConstants.SELECT_ID);
    sList.addElement(DomainConstants.SELECT_NAME);
    sList.addElement(DomainConstants.SELECT_POLICY);
    sList.addElement(DomainConstants.SELECT_TYPE);
    sList.addElement(Task.SELECT_TASK_REQUIREMENT);
    sList.addElement(Task.SELECT_HAS_PREDECESSORS);
    sList.addElement(Task.SELECT_HAS_SUCCESSORS);
    sList.addElement(ProgramCentralConstants.SELECT_KINDOF_EXPERIMENT_PROJECT);


    String dependencyCheck = "False";
    String mandatoryCheck = "";


   // Start For Deletion
   if(showSel == null || showSel.equalsIgnoreCase("null") || showSel.equalsIgnoreCase("")) {
      showSel = "";
    } else if(showSel.equalsIgnoreCase("Deleted")) {
      showSel = "deleted";
    } else {
      showSel = "all";
    }
   // End For Deletion

    String projectType       = DomainConstants.TYPE_PROJECT_SPACE;

   // String selectedIds = "";

    String strType = "";
    String strTaskRelId = "";
    boolean blProjSelected = false;
    boolean blTaskSelected = false;
    //ADDED:WQY:15-Jun-2011:IR-114965V6R2012x
    boolean isKindOfProjectSpace = false;    
    if(tableRowIdList != null){
        for(int i=0; i<tableRowIdList.length ; i++){
          String selectedId = tableRowIdList[i];

          StringTokenizer strtk = new StringTokenizer(selectedId,"|");
          strTaskRelId = strtk.nextToken();
          //strtk.nextToken();
          String taskId = strtk.nextToken();

          if(taskId.equals("0")){
              parentSelected = true;
              selectedTaskIds += objectId+",";
              object.setId(objectId);
              strTaskRelId = "";
            // Start For Delete Selected Feature
              selectedRowIds += "0"+"|";
            // End For Delete Selected Feature
          }
          else{
            object.setId(taskId);
            selectedTaskIds += taskId+",";
            selectedTaskRelIds += strTaskRelId+",";
            // Start For Delete Selected Feature
            strtk.nextToken();
            selectedRowIds+=strtk.nextToken()+"|";
            // End For Delete Selected Feature
          }
          selectCount++;
          Map objectInfoList = (Map)object.getInfo(context,sList);

          String strState = (String)objectInfoList.get(DomainConstants.SELECT_CURRENT);
          String strPolicy = (String)objectInfoList.get(DomainConstants.SELECT_POLICY);
          strType = (String)objectInfoList.get(DomainConstants.SELECT_TYPE);

        //Modified:26-Mar-2010:s2e:R209 PRG:IR-022896V6R2011
          istypeProjectSpace = object.isKindOf(context, DomainConstants.TYPE_PROJECT_SPACE);
          isKindOfExperimentProject =(String)objectInfoList.get(ProgramCentralConstants.SELECT_KINDOF_EXPERIMENT_PROJECT); 
        //End:26-Mar-2010:s2e:R209 PRG:IR-022896V6R2011
          
          if(Task.getAllTaskTypeNames(context).indexOf(strType)<0){
              blProjSelected = true;
          } else {
              blTaskSelected = true;
          }

          if (objectInfoList.get(Task.SELECT_HAS_PREDECESSORS).equals("True") || objectInfoList.get(Task.SELECT_HAS_SUCCESSORS).equals("True")) {
               dependencyCheck = "True";
          }

          mandatoryCheck = (String) objectInfoList.get(Task.SELECT_TASK_REQUIREMENT);

          selectedTaskStates += strState+",";
          selectedTaskPolicys += strPolicy+",";

          if(object.hasRelatedObjects(context,DomainConstants.RELATIONSHIP_DELETED_SUBTASK,false)){
            deletedTasks += "taskMarked"+",";
          }else {
            deletedTasks += "taskNotMarked"+",";
          }
          // Parent Info
          String strParentState = "";
          Map parentIdInfo = object.getRelatedObject(context,DomainConstants.RELATIONSHIP_SUBTASK, false, sList, null);
          if(parentIdInfo != null) {
              strParentState = (String) parentIdInfo.get(DomainConstants.SELECT_CURRENT);
          } else {
              strParentState = null;
          }
          selectedTaskParentStates += strParentState+",";

          if(!taskId.equals("0"))
          {
             task.setId(taskId);
             ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"),DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
             try 
             {
             DomainObject tasksProjectObject = task.getProjectObject(context);

             if(!tasksProjectObject.getId().equals(objectId))
             {
                subProjectTasksSelected = true;
             }
          }
             finally 
             {
                 ContextUtil.popContext(context); //pushpop
             }
          }
        }

          selectedRowIds = selectedRowIds.substring(0,selectedRowIds.length()-1);
          selectedTaskIds = selectedTaskIds.substring(0,selectedTaskIds.length()-1);
          selectedTaskStates = selectedTaskStates.substring(0,selectedTaskStates.length()-1);
          selectedTaskPolicys = selectedTaskPolicys.substring(0,selectedTaskPolicys.length()-1);
          deletedTasks = deletedTasks.substring(0,deletedTasks.length()-1);
          selectedTaskParentStates = selectedTaskParentStates.substring(0,selectedTaskParentStates.length()-1);
          if(!"".equalsIgnoreCase(selectedTaskRelIds)){
            selectedTaskRelIds = selectedTaskRelIds.substring(0,selectedTaskRelIds.length()-1);
          }
          //ADDED:WQY:15-Jun-2011:IR-114965V6R2012x
          isKindOfProjectSpace = new DomainObject(objectId).isKindOf(context, projectType);
    } else {
        // Setting Parent Type
        strType = projectType;
        object.setId(objectId);
    }

    // Start used for alert
    String taskPolicy = object.getDefaultPolicy(context,strType);
    String completeState     = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Complete");
    String reviewState       = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Review");
    String activeState       = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Active");
//Added:27-Feb-09:nr2:R207:PRG Bug :369101
    String archiveState       = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Archive");
//End:R207:PRG Bug :369101
    // End used for alert

    String sKey[] = { "dependencyType1","dependencyType2","dependencyType3","dependencyType4", };
    String sValue[] = { Task.START_TO_FINISH,Task.FINISH_TO_FINISH,Task.START_TO_FINISH,Task.FINISH_TO_FINISH };
    Map paramMap = new HashMap();
    paramMap.put("msgKey","emxProgramCentral.WBS.addSubtask.ConfirmToRemoveDependency");
    paramMap.put("placeHolderKeys",sKey);
    paramMap.put("placeHolderValues",sValue);
    String initArgs[] = JPO.packArgs(paramMap);
    String sDependencyWarningMsg = (String)JPO.invoke(context, "emxProgramCentralUtilBase", null, "geti18nString", initArgs, Object.class);

    String jsTreeID      = emxGetParameter(request, "jsTreeID");

    if(calledMethod.equalsIgnoreCase("submitDeleteTask")){
        selectedTaskIds = selectedTaskIds.replace(',','|');
    }
    if(calledMethod.equalsIgnoreCase("submitRemoveProject")){
        selectedTaskIds = selectedTaskRelIds;
    }
    if("submitInsertProject".equals(calledMethod) || "submitAddProject".equals(calledMethod)){%>
	  <script type="text/javascript" language="javascript" src="emxUIModal.js"></script>
<%}  
%>


<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="matrix.db.Context"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.util.Pattern"%>
<%@page import="matrix.db.RelationshipList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.program.ProjectSpace"%>
<%@page import="com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<form name="AddQuickWBS" method = "post" >
<script language="javascript" type="text/javaScript">//<![CDATA[
    var confirmMsg = null;
    var calledMethod = "<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>";
    if(parent.emxEditableTable.checkDataModified() && calledMethod != "submitDeliverableReport"){
        confirmMsg = confirm("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.DiscardChanges</framework:i18nScript>");
        if(confirmMsg){
          <%--XSSOK--%> 
 <%=calledMethod%>('<%=XSSUtil.encodeForJavaScript(context,objectId)%>','<%=XSSUtil.encodeForJavaScript(context, selectedTaskIds) %>','<%=selectCount%>','<%=parentSelected%>','<%=XSSUtil.encodeForJavaScript(context,showSel)%>','<%=XSSUtil.encodeForJavaScript(context,selectedTaskStates)%>','<%=XSSUtil.encodeForJavaScript(context,selectedTaskPolicys)%>','<%=XSSUtil.encodeForJavaScript(context,deletedTasks)%>','<%=XSSUtil.encodeForJavaScript(context,selectedTaskParentStates)%>');
        }
    } else {
    	<%--XSSOK--%> 
<%=calledMethod%>('<%=XSSUtil.encodeForJavaScript(context,objectId)%>','<%=XSSUtil.encodeForJavaScript(context,selectedTaskIds)%>','<%=selectCount%>','<%=parentSelected%>','<%=XSSUtil.encodeForJavaScript(context,showSel)%>','<%=XSSUtil.encodeForJavaScript(context,selectedTaskStates)%>','<%=XSSUtil.encodeForJavaScript(context,selectedTaskPolicys)%>','<%=XSSUtil.encodeForJavaScript(context,deletedTasks)%>','<%=XSSUtil.encodeForJavaScript(context,selectedTaskParentStates)%>');
    }

  //begin of the function
  function confirmModify(num) {
    if (num > 1) {
      alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.SelectOneTask</framework:i18nScript>");
      return false;
    }
    else{
        return true;
    }
  }


  // This function is called when the deliverables Report link of the WBS Structure browser
  //Modified:24-june-2010:s4e:R210 PRG:WBSEnhancement
  //Modified to remove Tasks which are "Marked as deleted" from Deliverable Report 
   <%
    if(calledMethod.equals("submitDeliverableReport") ){
   %>
  function submitDeliverableReport(projId,selectedIds,count,projectSelected) {
    var showAll = false;
    var selectedTaskIds = "";
     if(projectSelected == 'true'){
        showAll = true;
        selectedTaskIds ="";
     }
    if(selectedIds == "" && projectSelected == 'false'){
      alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.SelectTaskBeforeSubmitting</framework:i18nScript>");
    }
    else{
        <%     
        String taskIds=selectedTaskIds;
        StringList slTaskIdList= FrameworkUtil.split(taskIds,",");
        StringList slFinalList = new StringList(slTaskIdList);
        for(int nIndex=0;nIndex<slTaskIdList.size();nIndex++)
        {
            String taskId = (String)slTaskIdList.get(nIndex);
            DomainObject taskDo = DomainObject.newInstance(context,taskId);         
            String isDeltedSubtask = (String)taskDo.getInfo(context,"to["+DomainConstants.RELATIONSHIP_DELETED_SUBTASK+"]");
            if(isDeltedSubtask.equalsIgnoreCase("True"))
            {
                slFinalList.remove(taskId);
            }            
        }
        String strFinalList = slFinalList.toString().substring(1,slFinalList.toString().length()-1);
        %>
        var reportURL ="../common/emxIndentedTable.jsp?table=PMCProjectDeliverableReportSummary&freezePane=TaskName&suiteKey=<%=suiteKey%>&header=emxProgramCentral.Common.DeliverableReport&calculations=false&HelpMarker=emxhelpdeliverablesreport&program=emxProjectReport:getProjectWBSDeliverableList&taskIds=<%=strFinalList%>&objectId="+projId+"&showAll="+showAll;
     showModalDialog(reportURL, 930,650, true);
    }
 }
<%
 }
 %>
 //End:24-june-2010:s4e:R210 PRG:WBSEnhancement

 
<%
    if(isECHInstalled) {
%>
   function submitDeliverables(projId,selectedIds,count,projectSelected) {
    var showAll = false;
    var selectedTaskIds = "";
     if(projectSelected == 'true'){
        showAll = true;
        selectedTaskIds ="";
     }
    if(selectedIds == "" && projectSelected == 'false'){
      alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.SelectTaskBeforeSubmitting</framework:i18nScript>");
    }
    else{
     // To fix IR-185005V6R2014  expandProgramMenu=ECHAffectedItemReportMenu removed from URL
     var reportURL ="../common/emxIndentedTable.jsp?program=emxChangeProject:getProjectDeliverablesList&table=ECHAffectedItemSummary&suiteKey=<%=suiteKey%>&header=emxProgramCentral.EnterpriseChange.AffectedItemsReport&chart=false&calculations=false&pagination=0&HelpMarker=emxhelpdeliverablesreport&taskIds="+selectedIds+"&objectId="+projId+"&showAll="+showAll+"&emxExpandFilter=All";
     showModalDialog(reportURL, 930,650, true);
    }
 }
<%
    }
%>

    // This function is called when the Add Copy WBS link of the WBS Structure browser
    function importWBSURL(projId,selectedIds,count,projectSelected,showSel,selectedTaskStates,selectedTaskPolicys,deletedTasks,selectedTaskParentStates) {
    	if(selectedIds==""){    
    		    		   	
        emxShowModalDialog("emxProgramCentralProjectCreateDialogFS.jsp?objectId="+projId+"&fromWBS=true&suiteKey=<%=suiteKey%>",600,600);
    }

    		 else if(selectedTaskStates ==  '<%=completeState%>' || selectedTaskStates == '<%=reviewState%>' )
          	     {
          	     var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState1</framework:i18nScript>" +
                      " <%=i18nNow.getStateI18NString(taskPolicy,activeState, sLanguage)%> " +
                      "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState2</framework:i18nScript>";
          	         alert ( msg );
          	    }
                else if (confirmModify(count)) 
          	     { 
        	  
                 var taskObjId = selectedIds;
                 url = "emxProgramCentralProjectCreateDialogFS.jsp?objectId="+taskObjId+"&fromWBS=true&suiteKey=<%=suiteKey%>";
                 emxShowModalDialog(url,600,600);
              }
       	}
 
    // This function is called when the Delete Task link of the WBS Structure browser
   
   <%
    if(calledMethod.equals("submitDeleteTask") ){
   %>
    function submitDeleteTask(projId,selectedIds,count,projectSelected,showSel) {
     if (count > 1950) {
        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.TooManySelected</framework:i18nScript>");
        return;
      }
     <%--XSSOK--%>
 if('<%=blProjSelected%>' == "true"){
		alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CannotDelete</framework:i18nScript> <%=i18nNow.getAdminI18NString("type", strType, sLanguage)%>");
        return;
      }
      if(projectSelected == "true"){
         alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.CannotRemoveRoot</framework:i18nScript>");
      }
      else
      {
    	  var result = confirm("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ConfirmTaskDelete</framework:i18nScript>");
    	  if(result)
          {
       <%
        String strTaskIdsList=selectedTaskIds;
        StringList slTaskIds= FrameworkUtil.split(strTaskIdsList,"|");
        
        String taskIdArray[] = new String[slTaskIds.size()];
        StringList selectable = new StringList(DomainConstants.SELECT_NAME);
        selectable.add(Task.SELECT_TASK_REQUIREMENT);
        for(int i=0;i<slTaskIds.size();i++)
        {
        	taskIdArray[i]=(String)slTaskIds.get(i);
         }
        
        MapList taskInfoMapList = DomainObject.getInfo(context, taskIdArray, selectable);
      
        String strTempTaskId= (String)slTaskIds.get(0);
        Task temptask = new Task();
        temptask.setId(strTempTaskId);
        boolean isMandatory= temptask.isMandatoryTask(context,strTempTaskId);
     // [ADDED::PRG:rg6:Jan 3, 2011:IR-084173V6R2012 :R211::Start]
        if(isFromRMB){
        	if(strRootObjectId != null && !"".equalsIgnoreCase(strRootObjectId.trim())){
        %>
        		projId = "<%=XSSUtil.encodeForJavaScript(context,strRootObjectId)%>";
        <%		
        	}
        }
     // [ADDED::PRG:rg6:Jan 3, 2011:IR-084173V6R2012 :R211::End]   
         
             String strRowIdsList=selectedRowIds;
             StringList slRowIds= FrameworkUtil.split(strRowIdsList,"|");
             
             StringList slMandExcludeTaskNames = new StringList();
             StringList slFinalIdsList = new StringList(slTaskIds);
             StringList slFinalRowIdsList = new StringList();
             StringBuffer sbFinalIds= new StringBuffer();
             StringBuffer sbFinalRowIds= new StringBuffer();
             boolean blMandatoryFlag = false;
             
             StringBuffer sbTaskWithEfforts = new StringBuffer();
             boolean blTaskWithEffortsFlag = false;
             Task taskObj = new Task();
             int size = (null != slTaskIds)? slTaskIds.size() : 0;
             String strEnforceMandatoryTasks = EnoviaResourceBundle.getProperty(context,"emxProgramCentral.EnforceMandatoryTasks");
             for(int nCount=0; nCount<size; nCount++)
             {
                 String strTaskId=(String)slTaskIds.get(nCount);   
                 DomainObject taskDobj = DomainObject.newInstance(context,strTaskId);      
                 Map <String,String>taskMap = (Map)taskInfoMapList.get(nCount);
                 String strTaskRequirement=(String)taskMap.get(Task.SELECT_TASK_REQUIREMENT);
                 String strTaskName=(String)taskMap.get(DomainConstants.SELECT_NAME);
                 
                 if(("True".equalsIgnoreCase(strEnforceMandatoryTasks) && "Mandatory".equalsIgnoreCase(strTaskRequirement)))
                 {
                     if(!slMandExcludeTaskNames.contains(strTaskName))
                     {
                         slMandExcludeTaskNames.add(strTaskName);
                         if(slFinalIdsList.contains(strTaskId))
                         {
                             slFinalIdsList.remove(strTaskId);
                         }
                     }  
                     blMandatoryFlag = true;                 
                 }
                 
                 taskObj.setId(strTaskId);
                 boolean isToBlockDeleteTask = taskObj.hasConnectedEfforts(context);
                 if(isToBlockDeleteTask)
                 {
                	 sbTaskWithEfforts.append(strTaskName);
                	 if(slFinalIdsList.contains(strTaskId))
                     {
                         slFinalIdsList.remove(strTaskId);
                     }
                     blTaskWithEffortsFlag = true;
                 }
             }
             
             if(blMandatoryFlag)
             {
                 
          %> 
                      alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CannotDeleteMandatoryTask</framework:i18nScript>" +"<%= slMandExcludeTaskNames.toString()%>");         
         <%
              }
             
             if(blTaskWithEffortsFlag)
             {
                 
                 %>   
                      alert("<framework:i18nScript localize="i18nId">emxProgramCentral.WeeklyTimeSheet.DeleteTask.TaskWithEffortCannotBeDeleted</framework:i18nScript>" +"<%= sbTaskWithEfforts.toString()%>");         
                 <%              
             }        

				StringList slUsedInEffectivity = new StringList();
				if (!slFinalIdsList.isEmpty()) {
					boolean bCFF = false;
					bCFF = FrameworkUtil.isSuiteRegistered(context,"appVersionEffectivityFramework", false,null, null);
					if (bCFF) {
						for (int m = 0; m < slFinalIdsList.size(); m++) {
							String strMilestone = (String) slFinalIdsList
									.get(m);
							Milestone Mile = new Milestone();
							Boolean isUsed = false;
							isUsed = Mile.isMilestoneUsedinEffectivity(context,
									strMilestone);
							if (isUsed) {
								slFinalIdsList.remove(strMilestone);
								slUsedInEffectivity.add(strMilestone);
							}
						}
						if(slUsedInEffectivity.size() != 0 ){
					%>	
						  alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CannotDeleteMilestoneEffectivityTask</framework:i18nScript>" +"<%=slUsedInEffectivity.toString()%>");         
					<%
						}
					}
					if(slUsedInEffectivity.size() == 0){
					for (int i = 0; i < slFinalIdsList.size(); i++) {
						sbFinalIds.append((String) slFinalIdsList.get(i));
						int nIndex = slTaskIds.indexOf((String) slFinalIdsList
								.get(i));
						sbFinalRowIds.append((String) slRowIds.get(nIndex));
						if (i != slFinalIdsList.size() - 1) {
							sbFinalIds.append("|");
							sbFinalRowIds.append("|");
						}
					
					}%>     
	           
	          
	              var strURL = "emxProgramCentralWBSDeleteProcess.jsp?topId="+projId+"&objectIds=<%=sbFinalIds.toString()%>&mx.page.filter="+showSel+"&fromPage=StructureBrowser&rowIds=<%=sbFinalRowIds.toString()%>&portalCmdName=<%=currentFrame%>";
              if (<%=isFromRMB%>)
              {
                   strURL += "&isFromRMB=true";
              }

              var topFrame = findFrame(getTopWindow(), "<%=currentFrame%>");
              if(null == topFrame){
          		topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
          		if(null == topFrame)
          	    topFrame = findFrame(getTopWindow(), "detailsDisplay");	
          	   }
      			
              topFrame.toggleProgress('visible');
             
              document.location.href = strURL;
					
           <%}
				}
				// eof if%>  
     }
    }
    }


    <%
    }
   %>


    // This function is called when the Remove Project link of the WBS Structure browser
    function submitRemoveProject(projId,selectedIds,count,projectSelected,showSel) {
     var action = "remove";
     var isExpProject = '<%=XSSUtil.encodeForJavaScript(context,isKindOfExperimentProject)%>';
     <%--XSSOK--%> 
 if('<%=blTaskSelected%>' == "true"){
        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CannotRemoveTasks</framework:i18nScript>");
        return;
      }
      if(projectSelected == "true"){
         if("TRUE"==isExpProject || "true"==isExpProject){
        	alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Experiment.CannotRemoveParent</framework:i18nScript>");
        }else{
			alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CannotRemoveParent</framework:i18nScript>");
		}
      }
      else{
         document.location.href = "emxProgramCentralRemoveSubProjectItem.jsp?objectId="+projId+"&selectedIds="+selectedIds+"&action="+action+"&fromPage=StructureBrowser";
      }// eof if
    }

   // This function is called when the Mark For Delete link of the WBS Structure browser
    <%
    if(calledMethod.equals("submitMarkDeleteTask") ){
   %>
    function submitMarkDeleteTask(projId,selectedIds,count,projectSelected,showSel,selectedTaskStates,selectedTaskPolicys,deletedTasks,selectedTaskParentStates)  {
        var deleteTask = true;
        var confirmIfHasSubtask=true;
        var requirement = '<%=XSSUtil.encodeForJavaScript(context, mandatoryCheck)%>';
          var dependency = '<%=XSSUtil.encodeForJavaScript(context,dependencyCheck)%>';
        var taskObjId = selectedIds;
      //Modified:19-May-2010:s4e:R210 PRG:WBSEnhancement
      //Modified to allow multiple tasks to be marked as deleted,and to not allow "Mandatory" tasks to be marked as deleted 
      <%--XSSOK--%>
  if('<%=blProjSelected%>' == "true"){
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ProjectCannotMarkedForDeletion</framework:i18nScript>");
            return;
          }
        <%     
        String strTaskIdsList=selectedTaskIds;
        StringList slTaskIds= FrameworkUtil.split(strTaskIdsList,",");
    
        String taskIdArray[] = new String[slTaskIds.size()];
        StringList slBusSelect = new StringList(5);
        slBusSelect.add(DomainConstants.SELECT_NAME);
        slBusSelect.add(Task.SELECT_TASK_REQUIREMENT);
        slBusSelect.add(DomainConstants.SELECT_CURRENT);
        slBusSelect.add("to["+DomainConstants.RELATIONSHIP_DELETED_SUBTASK+"]");
        slBusSelect.add("from["+DomainConstants.RELATIONSHIP_SUBTASK+"]");

        for(int i=0;i<slTaskIds.size();i++)
        {
        	taskIdArray[i]=(String)slTaskIds.get(i);
         }
        
        MapList taskInfoMapList = DomainObject.getInfo(context, taskIdArray, slBusSelect);
       
        StringList slMandExcludeTaskNames = new StringList();
        StringList slCompleteExcludeTaskNames = new StringList();
        StringList slCompleteMandExcludeTaskNames = new StringList();
        StringList slDeletedTask= new StringList();
        StringList slHasSubtaskTask= new StringList();
        StringList slFinalIdsList = new StringList(slTaskIds);
        String strFinalId= ProgramCentralConstants.EMPTY_STRING;
        String strRowId= ProgramCentralConstants.EMPTY_STRING;
        StringList slManChildParentIdList = new StringList();
        boolean blMandatoryFlag = false;
        boolean blCompleteStateFlag = false;
        boolean blCompleteMandFlag = false;
        boolean blDeletedFlag = false;
        boolean blHasSubtaskTask = false;        
        
        String strTempTaskId= (String)slTaskIds.get(0);
        Task temptask = new Task();
        temptask.setId(strTempTaskId);
       
        boolean isMandatory= temptask.isMandatoryTask(context,strTempTaskId);
        String strEnforceMandatoryTasks = EnoviaResourceBundle.getProperty(context,"emxProgramCentral.EnforceMandatoryTasks");
        
        for(int nCount=0;nCount<slTaskIds.size();nCount++)
        {
            String strTaskId=(String)slTaskIds.get(nCount);  
            DomainObject taskDobj = DomainObject.newInstance(context,strTaskId);       
          
            Map <String,String>taskMap = (Map)taskInfoMapList.get(nCount);
            String strTaskRequirement=(String)taskMap.get(Task.SELECT_TASK_REQUIREMENT);
            String strTaskName=(String)taskMap.get(DomainConstants.SELECT_NAME);
            String strCurrent=(String)taskMap.get(DomainConstants.SELECT_CURRENT);
            String isDeltedSubtask = (String)taskMap.get("to["+DomainConstants.RELATIONSHIP_DELETED_SUBTASK+"]");
            String hasSubtask = (String)taskMap.get("from["+DomainConstants.RELATIONSHIP_SUBTASK+"]");
                        
            
            if(isDeltedSubtask.equals("True"))
            {               
                if(!slDeletedTask.contains(strTaskName))
                {
                    slDeletedTask.add(strTaskName);
                    if(slFinalIdsList.contains(strTaskId))
                    {
                        slFinalIdsList.remove(strTaskId);
                    }
                } 
                blDeletedFlag = true;
            }        

            if(("True".equalsIgnoreCase(strEnforceMandatoryTasks) && "Mandatory".equalsIgnoreCase(strTaskRequirement)))
            {
                if(!slMandExcludeTaskNames.contains(strTaskName))
                {
                    slMandExcludeTaskNames.add(strTaskName);
                    if(slFinalIdsList.contains(strTaskId))
                    {
                        slFinalIdsList.remove(strTaskId);
                    }
                }  
                blMandatoryFlag = true;
                 
            }           
            if("Complete".equalsIgnoreCase(strCurrent))
            {
                if(!slCompleteExcludeTaskNames.contains(strTaskName))
                {
                    slCompleteExcludeTaskNames.add(strTaskName);
                    if(slFinalIdsList.contains(strTaskId))
                    {
                        slFinalIdsList.remove(strTaskId);
                    }
                }  
                blCompleteStateFlag = true;
                 
            }
            if("True".equalsIgnoreCase(hasSubtask))
            {               
                if(!slHasSubtaskTask.contains(strTaskName)&&!slMandExcludeTaskNames.contains(strTaskName)&&!slCompleteExcludeTaskNames.contains(strTaskName))
                {
                    slHasSubtaskTask.add(strTaskName);
                    blHasSubtaskTask = true;
                } 
                
            }
                
                String strTypePattern = DomainConstants.TYPE_TASK_MANAGEMENT;
                String strRelPattern = DomainConstants.RELATIONSHIP_SUBTASK;
                StringList slRelSelect = new StringList();            
                boolean getFrom = true;
                boolean getTo = false;
                short recurseToLevel = 0;
                String strBusWhere = "";
                String strRelWhere = "";
                MapList mlRelatedTaskList = taskDobj.getRelatedObjects(context,
                        strRelPattern, //pattern to match relationships
                        strTypePattern, //pattern to match types
                        slBusSelect, //the eMatrix StringList object that holds the list of select statement pertaining to Business Objects.
                        null, //the eMatrix StringList object that holds the list of select statement pertaining to Relationships.
                        getTo, //get To relationships
                        getFrom, //get From relationships
                        recurseToLevel, //the number of levels to expand, 0 equals expand all.
                        strBusWhere, //where clause to apply to objects, can be empty ""
                        strRelWhere); //where clause to apply to relationship, can be empty ""
                              
                if(!mlRelatedTaskList.isEmpty())
                {
                    for(int i=0;i<mlRelatedTaskList.size();i++)
                    {
                         Map mapRealtedTaskId1 = (Map)mlRelatedTaskList.get(i);
                         String strRelatedTypeName =(String)mapRealtedTaskId1.get(DomainConstants.SELECT_NAME);                 
                         strTaskRequirement =(String)mapRealtedTaskId1.get(Task.SELECT_TASK_REQUIREMENT);
                         String strRelationshipName =(String)mapRealtedTaskId1.get(DomainConstants.SELECT_RELATIONSHIP_NAME);
                         strCurrent=(String)mapRealtedTaskId1.get(DomainConstants.SELECT_CURRENT);
              
                        /* if("Mandatory".equalsIgnoreCase(strTaskRequirement))
                         {
                             if(!slMandExcludeTaskNames.contains(strTaskName))
                             {
                                 slMandExcludeTaskNames.add(strTaskName);
                                 if(slFinalIdsList.contains(strTaskId))
                                 {
                                     slFinalIdsList.remove(strTaskId);
                                 }
                             }                           
                                 blMandatoryFlag = true;                                            
                         }*/
                         if("Complete".equalsIgnoreCase(strCurrent))
                         {
                             if(!slCompleteExcludeTaskNames.contains(strTaskName))
                             {
                                 slCompleteExcludeTaskNames.add(strTaskName);
                                 if(slFinalIdsList.contains(strTaskId))
                                 {
                                     slFinalIdsList.remove(strTaskId);
                                 }
                             }                           
                             blCompleteStateFlag = true;                                            
                         }
                     } 
                }
            
        }
       
        if(blDeletedFlag)
        {
            %>        
                alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.TaskIsDelted</framework:i18nScript>" +"<%= slDeletedTask.toString()%>");
            <%
        }
        //merge two lists for display..
        if(blMandatoryFlag && blCompleteStateFlag)
        {
            slCompleteMandExcludeTaskNames = new StringList(slMandExcludeTaskNames);
            for(int nIndex=0;nIndex<slCompleteExcludeTaskNames.size();nIndex++)
            {
                if(!slCompleteMandExcludeTaskNames.contains(slCompleteExcludeTaskNames.get(nIndex)))
                {
                    slCompleteMandExcludeTaskNames.add(slCompleteExcludeTaskNames.get(nIndex));
                }
            }
            
            %>   
                 alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ParentCannotBeMarkedAsDeleteAsChildIsMandatoryAndCompleted</framework:i18nScript>" +"<%= slCompleteMandExcludeTaskNames.toString()%>");       
            <%              
        } 
        else if(blMandatoryFlag)
        {
            
            %>   
                 alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.MandatoryTaskCannotBeMarkedAsDeleted</framework:i18nScript>" +"<%= slMandExcludeTaskNames.toString()%>");         
            <%              
        } 
        else if(blCompleteStateFlag)
        {
            
            %>   
                 alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ParentCannotBeMarkedAsDeleteAsChildIsComplete</framework:i18nScript>" +"<%= slCompleteExcludeTaskNames.toString()%>");         
            <%              
        } 
        for(int test=0;test<slFinalIdsList.size();test++)
        {
            String temptaskID= (String)slFinalIdsList.get(test);
            %>
            if(projId=='<%=temptaskID%>')
             {  
                 alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.CannotRemoveRoot</framework:i18nScript>");
                 return;         
             }  

            <%            
        }
        if(!slFinalIdsList.isEmpty() && blHasSubtaskTask)
        {
        	strRowId=slFinalIdsList.toString().substring(1,slFinalIdsList.toString().length()-1);
        	strFinalId=(String)slFinalIdsList.get(0);
        %>        
             confirmIfHasSubtask = confirm("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ConfirmMarkAsDeletedIfHasSubask</framework:i18nScript>" +"<%= slHasSubtaskTask.toString()%>");   
        <%
        }
        %>
        if(confirmIfHasSubtask){
        <%
        // error message is coming twice for task having subtasks so below check and else part added
        if(!slFinalIdsList.isEmpty() && !blHasSubtaskTask) // [MODIFIED::PRG:rg6:Dec 22, 2010:IR-073025V6R2012:R211]
        {
            strRowId=slFinalIdsList.toString().substring(1,slFinalIdsList.toString().length()-1);
            strFinalId=(String)slFinalIdsList.get(0);
        %>        
             var result = confirm("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ConfirmMarkAsDeleted</framework:i18nScript>");
        <%
        }else{ // [ADDED::PRG:rg6:Dec 22, 2010:IR-073025V6R2012 :R211::Start]
        %>
        	result = confirmIfHasSubtask;
        <%
        }  // [ADDED::PRG:rg6:Dec 22, 2010:IR-073025V6R2012 :R211::End]
        %>
             if(result) {
              if (dependency == "True") {
                var mandatoryDependencyResult = confirm("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ConfirmDependencyDelete</framework:i18nScript>");
                if(mandatoryDependencyResult) {
                    url="../common/emxForm.jsp?form=PMCTaskMarkAsDeletedComments&mode=edit&suiteKey=<%=suiteKey%>&formHeader=emxProgramCentral.Common.MarkDeleteSelected&HelpMarker=emxhelpmarkasdeleted&selectedObjectIds=<%=strRowId%>&objectId=<%=strFinalId%>&postProcessURL=../programcentral/emxProgramCentralMandatoryDiscussionProcess.jsp";
                    getTopWindow().showSlideInDialog(url,true);
                } else {
                  return;
                }
              } 
              else 
              {
                  <%
                    if(!slFinalIdsList.isEmpty())
                    {
                    	strRowId=slFinalIdsList.toString().substring(1,slFinalIdsList.toString().length()-1);
                    	strFinalId=(String)slFinalIdsList.get(0);
                       %>
                              url="../common/emxForm.jsp?form=PMCTaskMarkAsDeletedComments&mode=edit&suiteKey=<%=suiteKey%>&formHeader=emxProgramCentral.Common.MarkDeleteSelected&HelpMarker=emxhelpmarkasdeleted&selectedObjectIds=<%=strRowId%>&objectId=<%=strFinalId%>&postProcessURL=../programcentral/emxProgramCentralMandatoryDiscussionProcess.jsp";
                              getTopWindow().showSlideInDialog(url,true);
                       <%
                    }
                 %>
              }
              
            }
          }
          }
    <%
    }
 %>
  //End:19-May-2010:s4e:R210 PRG:WBSEnhancement
      
     



    // This function is called when the Add Task link of the WBS Structure browser Add Sibling
    function submitInsertTask(projId,selectedIds,count,projectSelected,showSel,selectedTaskStates,selectedTaskPolicys,deletedTasks,selectedTaskParentStates) {
        if(confirmModify(count)) {

          var taskObjId = selectedIds;
          var taskParentState = selectedTaskParentStates;
          var taskMarkedDeleted = deletedTasks;

          var allowParentInsert = "true";

        <%--XSSOK--%> 
 if(taskParentState == '<%=completeState%>' || taskParentState == '<%=reviewState%>' || taskParentState == "null") {
              allowParentInsert = "false";
          }
          <%
       // [ADDED::PRG:rg6:Jan 3, 2011:IR-076444V6R2012 :R211::Start]
          if(isFromRMB){
              if(strRootObjectId != null && !"".equalsIgnoreCase(strRootObjectId.trim())){
          %>
                  projId = "<%=XSSUtil.encodeForJavaScript(context,strRootObjectId)%>";
          <%      
              }
          }
       // [ADDED::PRG:rg6:Jan 3, 2011:IR-076444V6R2012 :R211::End] 
          %>

          if (taskObjId == projId ) {
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.CannotInsertOnRoot</framework:i18nScript>");
          } else if (taskMarkedDeleted == "taskMarked") {
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.TaskHasBeenMarkedForDeletion</framework:i18nScript>");
          } else if (allowParentInsert == "false") {
            var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState1</framework:i18nScript>" +
                      " <%=i18nNow.getStateI18NString(taskPolicy,activeState, sLanguage)%> " +
                      "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState2</framework:i18nScript>";
            alert ( msg );
          }
          else if("QuickWBS" == "<%=strMode%>" ) {
        	  
              var topFrame = findFrame(getTopWindow(), "<%=currentFrame%>");
              if(null == topFrame){
          		topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
          		if(null == topFrame)
          	    topFrame = findFrame(getTopWindow(), "detailsDisplay");	
          	   }
      			
              topFrame.toggleProgress('visible');

              
	<%--XSSOK--%>document.AddQuickWBS.action = "../programcentral/emxProgramCentralWBSInsertProcess.jsp?"+"<%=strAppendParameters%>";
              	 document.AddQuickWBS.submit();
       	}
                 
          else {        	
            url = "emxProgramCentralWBSInsertDialogFS.jsp?objectId="+projId+"&taskId="+taskObjId+"&fromPage=StructureBrowser&emxTableRowId="+"<%=XSSUtil.encodeForJavaScript(context,emxTableRowId)%>&portalCmdName=<%=currentFrame%>";
            //showDialog(encodeURI(url));
            getTopWindow().showSlideInDialog(encodeURI(url),true);
          }
        }
      }

    // This function is called when the Insert atTask link of the WBS Structure browser Add Child
    function submitAddTask(projId,selectedIds,count,projectSelected,showSel,selectedTaskStates,selectedTaskPolicys,deletedTasks) {
        if(confirmModify(count)) {

            var allowInsert = "true";
            var taskObjId = selectedIds;
            var taskState = selectedTaskStates;
            var taskMarkedDeleted = deletedTasks;

            //if(taskState == '<%=completeState%>' || taskState == '<%=reviewState%>') {
            //Added:27-Feb-09:nr2:R207:PRG Bug :369101
         <%--XSSOK--%>  
 if(taskState == '<%=completeState%>' || taskState == '<%=reviewState%>' || taskState == '<%=archiveState%>') {
                //End:R207:PRG Bug :369101
                allowInsert = "false";
          	}
          	//var strLanguage = '<%=sLanguage%>';
          	if (taskMarkedDeleted == "taskMarked") {
              	alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.TaskHasBeenMarkedForDeletion</framework:i18nScript>");
          	} else if ( allowInsert == "false") {
 				//Commented:24-Feb-09:nr2:R207:PRG Bug :369101           
            	//var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState1</framework:i18nScript>" +
            	//        " <%=i18nNow.getStateI18NString(taskPolicy,activeState, sLanguage)%> " +
            	//       "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState2</framework:i18nScript>";
				//End:R207:PRG Bug :369101            
				//Added:24-Feb-09:nr2:R207:PRG Bug :369101
            	var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState3</framework:i18nScript>";
				//End:R207:PRG Bug :369101            
            	alert ( msg );
          	} else {
              	var ajaxUrl="../programcentral/emxProgramCentralUIFreezePaneValidation.jsp?strmode=getForDep&taskId="+taskObjId;
              	var vtest=emxUICore.getData(ajaxUrl);
              	var isToContinue = true;
      	      	if("true".indexOf(vtest) != -1) {
          	      	var msg =  confirm("<%=XSSUtil.encodeForJavaScript(context,sDependencyWarningMsg)%>");
					if(!msg) {
						isToContinue = false;
				  	}
              	}
		if(isToContinue == true && "QuickWBS" == "<%=strMode%>" ) {
            	              var topFrame = findFrame(getTopWindow(), "<%=currentFrame%>");
		              if(null == topFrame){
		          		topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
		          		if(null == topFrame)
		          	    topFrame = findFrame(getTopWindow(), "detailsDisplay");	
		          	  }
		      			
		              topFrame.toggleProgress('visible');
			
	           document.AddQuickWBS.action = "../programcentral/emxProgramCentralWBSAddProcess.jsp?"+"<%=strAppendParameters%>";
                   document.AddQuickWBS.submit();
              	}
	      	 	else if (isToContinue == true ) {
		      	 	url = "emxProgramCentralWBSAddDialogFS.jsp?objectId="+taskObjId+"&busId="+projId+"&fromPage=StructureBrowser&isFromRMB=<%=isFromRMB%>&portalCmdName=<%=currentFrame%>";
                  	//showDialog(url);
                  	getTopWindow().showSlideInDialog(url,true);
              	}
          	}         	
     	 }
      }

    //MSDesktopIntegration-Start
    // function introduced for MSProject Integration related Action Link
    function launchForViewInMSProject(){
        launchInMSProject("false")
    }

    function launchForEditInMSProject(){
        launchInMSProject("true")
    }

    function launchInMSProject( edit ){
        //user clicks on edit link, but has no access to edit the project. This is a double check.
         <%
			try{
				    DomainObject project = DomainObject.newInstance(context, objectId);
					boolean editFlag = project.checkAccess(context, (short) AccessConstants.cModify);
					if(editFlag){
						edit = "true";
					}
			}catch(Exception e){
				
			}
          %>
        var IntegrationFrame = findFrame(getTopWindow(), "MSProjectIntegration");

        // If we didnt get the frame, may be because it is popup window,
        // Lets find the top most window which has opened the first window and search its hierarchy..IR-086619V6R2013
        if (!IntegrationFrame) 
        {
			//Added to fix CLink# 324790 - START
			var sframe = top; // variable to store the frames
			//initially assigned the current top frame

			var bpopupFound=false;  // boolean variable to store whether this is a pop-up
			//traversing bottom-up
			while(sframe.getWindowOpener()) {
				bpopupFound = true;
				//assigning the parent of the current frame to current frame
				sframe = sframe.getWindowOpener().getTopWindow();
			}
			//if this window was a popup then
			if(bpopupFound == true)
			{
				// finding the frame 'MSProjectIntegration'
				IntegrationFrame = findFrame(sframe, "MSProjectIntegration");
			}
        }
        
        //Added to fix CLink# 324790- END
        if(IntegrationFrame)
        {
            var msg = IntegrationFrame.document.MxMSPIApplet.callCommandHandler("MSProject", "getProjectForMSP", "<%=objectId%>|" + <%=edit%>);
            if(msg != "")
                alert(msg);
            return true;
         }
         else
            alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Project.IntegrationFrameNotFound</emxUtil:i18nScript>");
    }

//Added for bug 358843

// This function is called for Actions->Insert Existing Project Above
    function submitInsertProject (projId,selectedIds,count,projectSelected,showSel,selectedTaskStates,selectedTaskPolicys,deletedTasks,selectedTaskParentStates) {
        if (!confirmModify(count)) 
        {
            return;
        }

          var taskObjId = selectedIds;
          var taskParentState = selectedTaskParentStates;
          var taskMarkedDeleted = deletedTasks;

          var allowParentInsert = "true";

        <%--XSSOK--%> 
 if(taskParentState == '<%=completeState%>' || taskParentState == '<%=reviewState%>' || taskParentState == "null") 
          {
              allowParentInsert = "false";
          }

          if (taskObjId == projId ) 
          {
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.CannotInsertOnRoot</framework:i18nScript>");
          } 
          else if (taskMarkedDeleted == "taskMarked") 
          {
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.TaskHasBeenMarkedForDeletion</framework:i18nScript>");
          } 
          else if (allowParentInsert == "false") 
          {
            var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState1</framework:i18nScript>" +
                      " <%=i18nNow.getStateI18NString(taskPolicy,activeState, sLanguage)%> " +
                      "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState2</framework:i18nScript>";
            alert ( msg );
          } 
          else 
          {
        <%--XSSOK--%> 
   url = "emxProgramCentralProjectCreateDialogFS.jsp?fromSubProjects=true&wizardType=AddExistingSubProject&wizardPage=fromAddExistingSubProject&addType=Sibling&<%=strAppendParameters.toString()%>";
            var objModalDialog = showModalDialog(url,412,400,true);
      	    objModalDialog.show();
            //showDialog(url);
          }
      }
      
      // This function is called for Actions->Add Existing Project Below
    function submitAddProject (projId,selectedIds,count,projectSelected,showSel,selectedTaskStates,selectedTaskPolicys,deletedTasks,selectedTaskParentStates) {
        if (!confirmModify(count)) 
        {
            return;
        }

          var taskObjId = selectedIds;
          var taskParentState = selectedTaskParentStates;
          var taskMarkedDeleted = deletedTasks;

          var allowParentInsert = "true";

          <%--XSSOK--%> 
   if ( (taskObjId != projId ) && (taskParentState == '<%=completeState%>' || taskParentState == '<%=reviewState%>' || taskParentState == "null")) 
          {
              allowParentInsert = "false";
          }
          if (taskMarkedDeleted == "taskMarked") 
          {
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.TaskHasBeenMarkedForDeletion</framework:i18nScript>");
          } 
          <%--XSSOK--%> 
else if(selectedTaskStates ==  '<%=completeState%>' || selectedTaskStates == '<%=reviewState%>' )
          {
             var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState1</framework:i18nScript>" +
                      " <%=i18nNow.getStateI18NString(taskPolicy,activeState, sLanguage)%> " +
                      "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState2</framework:i18nScript>";
            alert ( msg );
          }
          else if (allowParentInsert == "false") 
          {
            var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState1</framework:i18nScript>" +
                      " <%=i18nNow.getStateI18NString(taskPolicy,activeState, sLanguage)%> " +
                      "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState2</framework:i18nScript>";
            alert ( msg );
          } 
          else 
          {
        	  <%--XSSOK--%>  
   url = "emxProgramCentralProjectCreateDialogFS.jsp?fromSubProjects=true&wizardType=AddExistingSubProject&wizardPage=fromAddExistingSubProject&addType=Child&<%=strAppendParameters.toString()%>";
          //Added:nr2:PRG:R212:07 July 2011:IR-091473V6R2012x
            try{
            var objModalDialog = showModalDialog(url,412,400,true);
      	    objModalDialog.show();
            showDialog(url);
          }
            catch(e){
                //alert(e);
            }
          //End:nr2:PRG:R212:07 July 2011:IR-091473V6R2012x
          }
      }
      
      // This function is called when the Copy WBS link of the WBS Structure browser
    function submitImport (projId,selectedIds,count,projectSelected,showSel,selectedTaskStates,selectedTaskPolicys,deletedTasks,selectedTaskParentStates) {
    	<%--XSSOK--%>  
    if(<%=blProjSelected%>==true){
    			var isExpProject = '<%=XSSUtil.encodeForJavaScript(context,isKindOfExperimentProject)%>';
			if("TRUE"==isExpProject || "true"==isExpProject){
				alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Experiment.CannotDoOperationOnExperiments</framework:i18nScript>");
			}else{
				alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CannotDoOperationOnProjects</framework:i18nScript>");
			}
          return false;
        }  
        else if (deletedTasks == "taskMarked") 
        {
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.TaskHasBeenMarkedForDeletion</framework:i18nScript>");
            return false;
        } 
        <%--XSSOK--%> 
 else if(selectedTaskStates ==  '<%=completeState%>' || selectedTaskStates == '<%=reviewState%>' )
          {
             var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState1</framework:i18nScript>" +
                      " <%=i18nNow.getStateI18NString(taskPolicy,activeState, sLanguage)%> " +
                      "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState2</framework:i18nScript>";
            alert ( msg );
          }
        else if (confirmModify(count)) 
        {
           var taskObjId = selectedIds;
           url = "emxProgramCentralProjectCreateDialogFS.jsp?objectId="+taskObjId+"&fromWBS=true&suiteKey=<%=suiteKey%>";
           emxShowModalDialog(url,600,600);
        }
      }
      
     // This function is called when the Assign By Project Role link of the WBS Structure browser
     function submitAssignByProjectRole(projId,selectedIds,count,projectSelected,showSel,selectedTaskStates,selectedTaskPolicys,deletedTasks,selectedTaskParentStates) {
    	 <%--XSSOK--%> 
    	 var istypProjectSpace = <%=istypeProjectSpace%>;

  if (<%=subProjectTasksSelected%>==true && istypProjectSpace == "true") 
        {
          alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CantReassignSubProjects</framework:i18nScript>");
          return false;
        } 
    	 <%--XSSOK--%> 
else if (<%=blProjSelected%>==true) 
        {
          alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CannotDoOperationOnProjects</framework:i18nScript>");
          return false;
        } 
        else if (deletedTasks == "taskMarked") 
        {
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.TaskHasBeenMarkedForDeletion</framework:i18nScript>");
            return false;
        } 
        <%--XSSOK--%> 
else if(selectedTaskStates ==  '<%=completeState%>' || selectedTaskStates == '<%=reviewState%>' )
          {
             var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState1</framework:i18nScript>" +
                      " <%=i18nNow.getStateI18NString(taskPolicy,activeState, sLanguage)%> " +
                      "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState2</framework:i18nScript>";
            alert ( msg );
          }
        else 
        {
          url = "emxProgramCentralAutomaticAssignmentDialogFS.jsp?objectId="+projId+"&selectedIds="+selectedIds;
          showDialog(url);
        }
      }
      
      
    // This function is called when the Add Dependency link of the WBS Structure browser
    function submitAddDependency(projId,selectedIds,count,projectSelected,showSel,selectedTaskStates,selectedTaskPolicys,deletedTasks,selectedTaskParentStates) 
    {
          if (confirmModify(count))
          {
            var taskObjId = selectedIds;
            //MODIFIED:WQY:15-Jun-2011:IR-114965V6R2012x
           <%--XSSOK--%>
 if ((taskObjId ==  projId) && <%=isKindOfProjectSpace%>) 
            {
                alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.CannotPerformAction</framework:i18nScript>");
            } 
            else if (deletedTasks == "taskMarked") 
            {
                alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.TaskHasBeenMarkedForDeletion</framework:i18nScript>");
            } 
            <%--XSSOK--%>  
      else if(selectedTaskStates ==  '<%=completeState%>' || selectedTaskStates == '<%=reviewState%>' )
          {
             var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState1</framework:i18nScript>" +
                      " <%=i18nNow.getStateI18NString(taskPolicy,activeState, sLanguage)%> " +
                      "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState2</framework:i18nScript>";
            alert ( msg );
          }
            else 
            {
                url = "emxProgramCentralDependencySummaryFS.jsp?objectId="+taskObjId+"&mode=popup";
                url += "&topTaskId="+projId+"&fromPage=StructureBrowser";
                showDetailsPopup(url);
            }
          }
    }

    // This function is called when the Assign Selected link of the WBS Structure browser
     <%
    if(calledMethod.equals("submitAssignTask") ){
   %>
    function submitAssignTask(projId,selectedIds,count,projectSelected,showSel,selectedTaskStates,selectedTaskPolicys,deletedTasks,selectedTaskParentStates) 
    {
        var isRoot = false;
        var taskInfoValues = selectedIds.split(',');
        
        //Modified:26-Mar-2010:s2e:R209 PRG:IR-022896V6R2011
        var isRootTypeProjectSpace = false;
       <%--XSSOK--%> 
var istypProjectSpace = <%=istypeProjectSpace%>;
        if(istypProjectSpace == "true"){
            isRootTypeProjectSpace = true;
            }
        
        for(var i=0; i< taskInfoValues.length ; i++){
          var taskObjId = taskInfoValues[i];
          if(projId == taskObjId){
            isRoot = true;
          }
          
        }
        if (isRoot && isRootTypeProjectSpace) 
        {
          alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.CannotAddAssignees</framework:i18nScript>");
          return false;
        } 
        //End:26-Mar-2010:s2e:R209 PRG:IR-022896V6R2011
        
       <%--XSSOK--%>
 else if(<%=blProjSelected%>==true)
        {
          alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CannotDoOperationOnProjects</framework:i18nScript>");
          return false;
        } 
        else if (deletedTasks == "taskMarked") 
        {
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.TaskHasBeenMarkedForDeletion</framework:i18nScript>");
        } 
        <%--XSSOK--%> 
  else if(selectedTaskStates ==  '<%=completeState%>')
          {
             var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState1</framework:i18nScript>" +
                      " <%=i18nNow.getStateI18NString(taskPolicy,reviewState, sLanguage)%> " +
                      "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState2</framework:i18nScript>";
            alert ( msg );
          }
        else if (count > 1) 
        {
        	<%
            session.setAttribute("selectedIds",selectedTaskIds);
            %>
            
            document.location.href = "emxProgramCentralAssigneeMultipleAddPreProcess.jsp?objectId="+projId;
        } 
        else 
        {
            var taskObjId = taskInfoValues[0];
         // [MODIFIED::PRG:RG6:Dec 30, 2010:IR-055926V6R2012:R211::OLD jsp is bypassed now redirected towards the search page]
           // url = "emxProgramCentralAssigneeSummaryFS.jsp?objectId=" + taskObjId;
            url = "emxProgramCentralTaskAssigneeActionsHidden.jsp?command=Add&fromPage=fromWBSMainSBPage&objectId="+ taskObjId;
            showDialog(url);
        }
      }
<% }
%>

    //This function is called when User wants Undo the tasks which are marked as deleted.
   <%
    if(calledMethod.equals("submitUndoMarkDeleted") ){
   %>  
    function submitUndoMarkDeleted(projId,selectedIds,count,projectSelected,showSel,selectedTaskStates,selectedTaskPolicys,deletedTasks,selectedTaskParentStates) 
    {   
    	<%--XSSOK--%> 
if('<%=blProjSelected%>' == "true"){
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ProjectCannotSelectedUndoMarkedForDeletion</framework:i18nScript>");
            return;
      }
     <%
       String strFinalIds= "";
       String strTaskIds=selectedTaskIds;
       StringList slTaskId= FrameworkUtil.split(strTaskIds,",");
       StringList slTaskNameList= new StringList();
       StringList slExcludeTaskNameList = new StringList();
       StringList slParentDeleteStateList = new StringList();
       StringList slFinalIdList = new StringList();
       StringList slRestoreParentList = new StringList();
       StringList slParentCompletedList = new StringList();
       boolean blParentFlag=false;
       //Added:30-07-2010:ak4:R210:ECH:Bug:064477
       boolean isChangeTask = false;
       boolean errorMsg=false;
       //End:30-07-2010:ak4:R210:ECH:Bug:064477
       for(int nCount=0;nCount<slTaskId.size();nCount++)
       {
          String strTaskId = (String)slTaskId.get(nCount);
          
          DomainObject taskDob = DomainObject.newInstance(context,strTaskId);
          String strTaskName= taskDob.getInfo(context,DomainConstants.SELECT_NAME);
          
          Pattern relPattern = new Pattern(DomainConstants.RELATIONSHIP_SUBTASK);
          relPattern.addPattern(DomainConstants.RELATIONSHIP_DELETED_SUBTASK);
          
		  //Modified:13-July-2010:s4e:R210 PRG:IR-062340V6R2011x
		 //Earlier type pattern was  TYPE_PROJECT_SPACE now it has been changed to //TYPE_PROJECT_MANAGEMENT which will give ProjectSpace/ProjectConcept/Task/Phase/Milestone/Gate
          //Pattern typePattern = new Pattern(DomainConstants.TYPE_TASK);
          //typePattern.addPattern(DomainConstants.TYPE_PROJECT_SPACE);
          Pattern typePattern = new Pattern(DomainConstants.TYPE_PROJECT_MANAGEMENT);
		  //End:Modified:13-July-2010:s4e:R210 PRG:IR-062340V6R2011x
          
          StringList slBusSelect = new StringList();
          slBusSelect.add(DomainConstants.SELECT_ID);
          slBusSelect.add(DomainConstants.SELECT_NAME);
          slBusSelect.add(DomainConstants.SELECT_TYPE);
          slBusSelect.add(DomainConstants.SELECT_CURRENT);          
          slBusSelect.add("to["+DomainRelationship.RELATIONSHIP_SUBTASK+"]");
          slBusSelect.add("to["+DomainRelationship.RELATIONSHIP_SUBTASK+"].from.id");
          slBusSelect.add("to["+DomainRelationship.RELATIONSHIP_DELETED_SUBTASK+"]");
          slBusSelect.add("to["+DomainRelationship.RELATIONSHIP_DELETED_SUBTASK+"].from.id");
          slBusSelect.add("to["+DomainRelationship.RELATIONSHIP_DELETED_SUBTASK+"].from.name");
          slBusSelect.add("to["+DomainRelationship.RELATIONSHIP_DELETED_SUBTASK+"].from.current");
          
          StringList slRelSelect = new StringList();          
          
          boolean getFrom = false;
          boolean getTo = true;
          short recurseToLevel = 0;
          String strBusWhere = "";
          String strRelWhere = "";
          
          MapList mlRelatedTaskList = taskDob.getRelatedObjects(context,
                  relPattern.getPattern(), //pattern to match relationships
                  typePattern.getPattern(), //pattern to match types
                  slBusSelect, //the eMatrix StringList object that holds the list of select statement pertaining to Business Objects.
                  null, //the eMatrix StringList object that holds the list of select statement pertaining to Relationships.
                  getTo, //get To relationships
                  getFrom, //get From relationships
                  recurseToLevel, //the number of levels to expand, 0 equals expand all.
                  strBusWhere, //where clause to apply to objects, can be empty ""
                  strRelWhere); //where clause to apply to relationship, can be empty ""
          Map mapParentMap = new HashMap();
          for(int i=0;i<mlRelatedTaskList.size();i++)
          {               
              Map mapRealtedTaskId = (Map)mlRelatedTaskList.get(i);
              String strParentId = (String)mapRealtedTaskId.get(DomainConstants.SELECT_ID);
              mapParentMap.put(strParentId,mapRealtedTaskId);
          }
          Map selfBusSelectMap =  taskDob.getInfo(context,slBusSelect);
          mapParentMap.put(strTaskId,selfBusSelectMap);
          boolean isImmediatedSubtask = true;   
          boolean isParentDeletedTask = false;
          boolean isParentCompleted = false;
          String strCheckTaskId = strTaskId;
          String strDelTaskName = "";
          Map tempMap= null;
          while(null!=strCheckTaskId)
          { 
        	//Added:03-08-2010:ak4:R210:ECH:Bug:064477
              if(taskDob.isKindOf(context,DomainConstants.TYPE_CHANGE_TASK))         
              {
                      isChangeTask=true;
                      errorMsg=true;
                      break;
              }else{
                  isChangeTask=false;
              }
            //End:03-08-2010:ak4:R210:ECH:Bug:064477 
          
             if(null!=mapParentMap.get(strCheckTaskId))
             {
                tempMap=(Map)mapParentMap.get(strCheckTaskId);
                String immediatedRelSubtask = (String)tempMap.get("to["+DomainRelationship.RELATIONSHIP_SUBTASK+"]");
                String immediatedRelDelSubTask = (String)tempMap.get("to["+DomainRelationship.RELATIONSHIP_DELETED_SUBTASK+"]");
                String strParentState = (String)selfBusSelectMap.get("to["+DomainRelationship.RELATIONSHIP_DELETED_SUBTASK+"].from.current");
                
                if("Complete".equalsIgnoreCase(strParentState))
                {
                    isParentCompleted =true;
                    slParentCompletedList.add(strTaskName);
                    break;
                }
                if("true".equalsIgnoreCase(immediatedRelSubtask))
                { 
                    if(null!=tempMap.get("to["+DomainRelationship.RELATIONSHIP_SUBTASK+"].from.id"))
                    {
                        String strParentObjectId = (String)tempMap.get("to["+DomainRelationship.RELATIONSHIP_SUBTASK+"].from.id");
                        strCheckTaskId = strParentObjectId;
                    }
                }
                else if("true".equalsIgnoreCase(immediatedRelDelSubTask))
                { 
                    
                    if(null!=tempMap.get("to["+DomainRelationship.RELATIONSHIP_DELETED_SUBTASK+"].from.id"))
                    {
                        String strParentObjectId = (String)tempMap.get("to["+DomainRelationship.RELATIONSHIP_DELETED_SUBTASK+"].from.id");
                        strDelTaskName = (String)tempMap.get("to["+DomainRelationship.RELATIONSHIP_DELETED_SUBTASK+"].from.name");
                        if(strCheckTaskId.equals(strTaskId))
                        {
                            isImmediatedSubtask = false;
                            strCheckTaskId = strParentObjectId;
                        }
                        else 
                        {
                            isParentDeletedTask = true;
                            break;
                        }
                    }
                }
                else
                {
                    break;
                }
             }
          }
          //Added:03-08-2010:ak4:R210:ECH:Bug:064477
          if(!isChangeTask){
          //End:03-08-2010:ak4:R210:ECH:Bug:064477 
          if(isParentDeletedTask)
          {
             if(!isImmediatedSubtask && (!isParentCompleted))
             {
                slParentDeleteStateList.add(strTaskName);
                slFinalIdList.add(strTaskId);
             }
             else
             {
                 slRestoreParentList.add(strTaskName);
             }
          }
          else if(!isParentCompleted)
          {
             slFinalIdList.add(strTaskId);
          }
       }
       }
       //Added:03-08-2010:ak4:R210:ECH:Bug:064477
       if(errorMsg)
       {
           %>
           alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CannotUndoChangeTask</framework:i18nScript>");                 
           <%
       }
       //End:03-08-2010:ak4:R210:ECH:Bug:064477
       if(!slRestoreParentList.isEmpty())
       {
           %>
           alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.PleaseSelectParentToRestoreSelectedTask</framework:i18nScript>"+"<%=slRestoreParentList.toString()%>");                 
           <%
       } 
       if(!slParentDeleteStateList.isEmpty())
       {
           %>
           alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ParentTaskInDeletedState</framework:i18nScript>"+"<%=slParentDeleteStateList.toString()%>");                 
           <%
       }
       if(!slParentCompletedList.isEmpty())
       {
           %>
           alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ParentIsInCompleteState</framework:i18nScript>"+"<%=slParentCompletedList.toString()%>");                 
           <%
       } 
           if(!slFinalIdList.isEmpty())
           {
               strFinalIds=slFinalIdList.toString().substring(1,slFinalIdList.toString().length()-1);          
               %>       
               var taskObjId = selectedIds;
               url = "emxProgramCentralMandatoryDiscussionProcess.jsp?fromWBS=true&objectId="+"<%=strFinalIds%>"+"&mode=UndoMarkDeleted&objectIds=<%=strTaskIds%>&rowIds=<%=XSSUtil.encodeForJavaScript(context,selectedRowIds)%>&emxTableRowId=<%=XSSUtil.encodeForJavaScript(context,emxTableRowId)%>";
               document.location.href =  url;
               <%
           }    
           %>
      }
    <%
    } if(calledMethod.equals("chainTask") ) {
%>
		function chainTask(projId,selectedIds) {
			url = "emxProgramCentralUtil.jsp?mode=chainTask&parentOID="+ projId + "&selectedIds=" + selectedIds;
			if(window.confirm("\u8BF7\u786E\u8BA4\u5C06\u9009\u62E9\u7684\u6240\u6709\u9879\u76EE\u4EFB\u52A1\u8BBE\u7F6E\u4E3A\u7D27\u524D\u7D27\u540E\u5173\u7CFB")){
                 //alert("确定");
				 window.location.href = url;
                 return true;
              }else{
                 //alert("取消");
				
                 return false;
             }
 			
 		}
<%
	}
%>
    
</script>

