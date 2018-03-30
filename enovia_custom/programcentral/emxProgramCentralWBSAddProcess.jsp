<%--  emxProgramCentralWBSAddProcess.jsp

  Performs the action to add a new task to a project

  Copyright (c) 1992-2015 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  Reviewed for Level III compliance by JDH 5/2/2002

  static const char RCSID[] = "$Id: emxProgramCentralWBSAddProcess.jsp.rca 1.32 Tue Oct 28 18:55:11 2008 przemek Experimental przemek $";
--%>

<%@ include file="emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
     <script language="javascript" type="text/javascript" src="emxUICore.js"></script>
</head>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%!
static public void addUpdate(Map tasks, String taskId, String attribute, Object value) {
    Map taskInfo = (Map) tasks.get(taskId);

    if(taskInfo == null) {
        taskInfo = (Map) new HashMap();
        tasks.put(taskId, taskInfo);
    }


    taskInfo.put(attribute, value);
}

%>

<%
  com.matrixone.apps.program.Task task =
    (com.matrixone.apps.program.Task) DomainObject.newInstance(context,
    DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);
  com.matrixone.apps.program.Task newTask =
    (com.matrixone.apps.program.Task) DomainObject.newInstance(context,
    DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);
  com.matrixone.apps.program.ProjectConcept concept =
    (com.matrixone.apps.program.ProjectConcept) DomainObject.newInstance(context,
    DomainConstants.TYPE_PROJECT_CONCEPT, DomainConstants.PROGRAM);
  com.matrixone.apps.program.ProjectSpace project =
    (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context,
    DomainConstants.TYPE_PROJECT_SPACE, DomainConstants.PROGRAM);
  com.matrixone.apps.program.ProjectTemplate template =
    (com.matrixone.apps.program.ProjectTemplate) DomainObject.newInstance(context,
    DomainConstants.TYPE_PROJECT_TEMPLATE, DomainConstants.PROGRAM);
  com.matrixone.apps.common.Person person =
    (com.matrixone.apps.common.Person) DomainObject.newInstance(context,
    DomainConstants.TYPE_PERSON);
  
    String parentTaskId    = (String) emxGetParameter(request, "taskId");
  //Added:2013:NZF:Quick WBS Functionality
  String busId           = (String) emxGetParameter(request, "busId");
  String projectID       = (String) emxGetParameter(request, "projectID");
  String objectId = (String) emxGetParameter(request, "objectId");
  if(null==busId && null!= projectID)
	  busId = projectID;
  else
	  busId = objectId;
  DomainObject dojParentTaskId = new DomainObject(busId);
  //End:2013:NZF:Quick WBS Functionality
  String duration        = (String) emxGetParameter(request, "duration");
  String[] memberIds     = (String[]) emxGetParameterValues( request, "txtAssignee" );
  String function        = (String) emxGetParameter( request, "function" );
  String selectedNodeId  = (String) emxGetParameter( request, "selectedNodeId" );
  boolean bAddSubtask = true;
  if ( function != null && function.equals( "Insert" ) ) bAddSubtask = false;
  String newUnit        = (String) emxGetParameter(request, "unitCB");
  String newDurationKeyword = (String) emxGetParameter(request, "durationKeyword");
  String memberId        = (String) emxGetParameter(request, "memberId");
  String makeOwner       = (String) emxGetParameter(request, "makeOwner");
   String taskEstimatedDuration = PropertyUtil.getSchemaProperty(context, "attribute_TaskEstimatedDuration");

  String txtOwner        = (String) emxGetParameter( request, "txtOwner" );
  String done            = (String) emxGetParameter(request, "done");
//Change for new Task subtype containing space in Type names
  String urlTaskType     = (String) emxGetParameter(request, "taskType");
  String taskType        =  XSSUtil.decodeFromURL(urlTaskType);
  String taskName        = (String) emxGetParameter(request, "taskName");
//Added:23-Jun-09:yox:R208:PRG:Project & Task Autonaming
  String taskAutoName = (String) emxGetParameter(request, "taskAutoName");
//End:R208:PRG :Project & Task Autonaming
  String taskDescription = (String) emxGetParameter(request, "taskDescription");
  String taskRequirement = (String) emxGetParameter(request, "taskRequirement");
  String selectedPolicy  = (String) emxGetParameter(request, "selectedPolicy");
  String strcalendar  = (String) emxGetParameter(request, "hideCalendar");
  String strOwnerCalendarID  = "";
  String fromPage  = (String) emxGetParameter(request, "fromPage");
  //Added:10-Nov-09:nzf:R209:PRG:WBS Task Constraint
  String strTaskConstraint = (String) emxGetParameter(request, "TaskConstraintType");
  String strTaskConstraintDate = (String) emxGetParameter(request, "TaskConstraintDate");
  //Added:18-Jan-10:nzf:R209:PRG:Bug:IR-033629
  //Added:2013:NZF:Quick WBS Functionality
  String strTasksToAdd = (String) emxGetParameter(request, "PMCWBSQuickTasksToAddBelow");  //XSSOK 
  String strTasksTypeToAdd = (String) emxGetParameter(request, "PMCWBSQuickTaskTypeToAddBelow");
  String strPortalCommandName = (String)emxGetParameter(request, "portalCmdName");
  
  int nTasksToAdd = 1;
  String currentframe = XSSUtil.encodeForJavaScript(context, (String)emxGetParameter(request, "portalCmdName"));
    
  String strMode = (String) emxGetParameter(request, "mode");
    
//Added for ECH
  boolean isECHInstalled = com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appVersionEnterpriseChange",false,null,null);
  //End Added for ECH
  
  //Start WBS AddProcess with SB Add/Remove Feture Implementation
  String attrTaskWBSId =  "to["+DomainConstants.RELATIONSHIP_SUBTASK+"].attribute["+DomainConstants.ATTRIBUTE_TASK_WBS+"]";
		  
  StringList busSelects = new StringList(3);
  busSelects.addElement(DomainConstants.SELECT_ID);
  busSelects.addElement(DomainConstants.SELECT_NAME);
  busSelects.addElement(attrTaskWBSId);
  
  StringList relSelects = new StringList(2);
  relSelects.addElement(DomainConstants.SELECT_RELATIONSHIP_ID);
  relSelects.addElement(DomainRelationship.SELECT_DIRECTION);
  String relType = DomainConstants.RELATIONSHIP_SUBTASK;
  try{
  boolean isFromRMB = "true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB"));
  if("QuickWBS".equalsIgnoreCase(strMode)){
	  
      String selectedObjectID = (String) emxGetParameter(request, "emxTableRowId");
      StringList idList = FrameworkUtil.splitString(selectedObjectID, "|");
      selectedNodeId = (String)idList.get(1);
      parentTaskId = selectedNodeId;
      dojParentTaskId =DomainObject.newInstance(context, parentTaskId);  
      
      StringList objectSelects = new StringList(2);
      objectSelects.add(DomainConstants.SELECT_CURRENT);
      objectSelects.add(DomainConstants.SELECT_POLICY);
      
      Map parentInfo = dojParentTaskId.getInfo(context,objectSelects);
      
      String strState = (String)parentInfo.get(DomainConstants.SELECT_CURRENT);
      String parentPolicy = (String)parentInfo.get(DomainConstants.SELECT_POLICY);
      
		StringList reviewTypelist = ProgramCentralUtil.getSubTypesList(context, ProgramCentralConstants.TYPE_GATE);
		reviewTypelist.addAll(ProgramCentralUtil.getSubTypesList(context, ProgramCentralConstants.TYPE_MILESTONE));
		
	      
	      if(ProgramCentralConstants.STATE_PROJECT_REVIEW_REVIEW.equalsIgnoreCase(strState) || ProgramCentralConstants.STATE_PROJECT_REVIEW_COMPLETE.equalsIgnoreCase(strState) || ProgramCentralConstants.STATE_PROJECT_REVIEW_ARCHIEVE.equalsIgnoreCase(strState)){
	    	  %>
<script language="javascript" type="text/javaScript">
	    	   alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState3</framework:i18nScript>");
	           </script>
<%
	    	  return;
	      }

		if(ProgramCentralConstants.POLICY_PROJECT_REVIEW.equalsIgnoreCase(parentPolicy) && !(reviewTypelist.contains(strTasksTypeToAdd)) )
		{
			%>
<script language="javascript" type="text/javaScript">
	    	   alert("<framework:i18nScript localize="i18nId">emxProgramCentral.WBS.TaskCannotAdded</framework:i18nScript>");
	           </script>
<%
	    	return;
		}
	  
	  try{
		  nTasksToAdd = Integer.parseInt(strTasksToAdd);
	  }catch(Exception e){
		  nTasksToAdd = 1;
	  }
      busId = objectId;
      taskAutoName = "checked";
	  //Change for new Task subtype containing space in Type names
      taskType = XSSUtil.decodeFromURL(strTasksTypeToAdd);
      
      StringList slGateSubType = ProgramCentralUtil.getSubTypesList(context, ProgramCentralConstants.TYPE_GATE);
      StringList slMileStoneSubType = ProgramCentralUtil.getSubTypesList(context, ProgramCentralConstants.TYPE_MILESTONE);
      
      if(slGateSubType.contains(taskType) || slMileStoneSubType.contains(taskType)){
    	  selectedPolicy = ProgramCentralConstants.POLICY_PROJECT_REVIEW;
    	  duration = "0";
      }else{
    	  selectedPolicy = ProgramCentralConstants.POLICY_PROJECT_TASK;
    	  duration = "1";
      }
      
      taskDescription ="";
      taskRequirement = "Mandatory";
     
      //strTaskConstraint = "As Soon As Possible";
      fromPage = "StructureBrowser";
      
      newUnit = "d";
      //Code to get Company Id of the person.
      String strPersonId = MqlUtil.mqlCommand(context, "temp query bus $1 $2 $3 select $4 dump $5",DomainConstants.TYPE_PERSON,context.getUser(),"*","id","|");
      StringList slResult = FrameworkUtil.splitString(strPersonId, "|");
      strPersonId = (String)slResult.lastElement();
      txtOwner = strPersonId;
      String selectedObjID = (String) emxGetParameter(request, "emxTableRowId");
      slResult = FrameworkUtil.splitString(selectedObjID, "|");
      selectedNodeId = (String)slResult.get(1);
      parentTaskId = selectedNodeId;
      
      //Code for checking if Task or Project is in Valid State 
      DomainObject dmo = DomainObject.newInstance(context);
      dmo.setId(parentTaskId);
      String strObjState = dmo.getInfo(context,DomainConstants.SELECT_CURRENT);
      
      if(ProgramCentralConstants.STATE_PROJECT_REVIEW_REVIEW.equalsIgnoreCase(strObjState) || ProgramCentralConstants.STATE_PROJECT_REVIEW_COMPLETE.equalsIgnoreCase(strObjState) || ProgramCentralConstants.STATE_PROJECT_REVIEW_ARCHIEVE.equalsIgnoreCase(strObjState)){
    	  %>
    	   <script language="javascript" type="text/javaScript">
    	   alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState3</framework:i18nScript>");
           </script>
    	  <%
    	  return;
      }
      
      dojParentTaskId =DomainObject.newInstance(context, parentTaskId);   
      isFromRMB =  false;
      done = "Done";
  }else{
	  dojParentTaskId =DomainObject.newInstance(context, busId);   
  }

  StringList slNewTAskIds = new StringList(nTasksToAdd);
  StringBuffer sBuff = new StringBuffer();
  
   String TaskConstraintDate_msValue = (String) emxGetParameter(request, "TaskConstraintDate_msvalue");
  if(null!=TaskConstraintDate_msValue && !"".equals(TaskConstraintDate_msValue) && !"null".equals(TaskConstraintDate_msValue) ){
	  TaskConstraintDate_msValue = TaskConstraintDate_msValue.trim();
	
	  Locale locale = request.getLocale();
	  context.setLocale(locale);
	  double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
	  strTaskConstraintDate = strTaskConstraintDate.trim();
	
	  long lngMS = Long.parseLong(TaskConstraintDate_msValue);
	  Date date = new Date(lngMS);
	
	  //DateFormat dateFmt = DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), Locale.US);
	  //strTaskConstraintDate = dateFmt.format(date);
	  SimpleDateFormat dateFmt = new SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(),Locale.US);
	  
	  Calendar constraintDate = Calendar.getInstance();
	  constraintDate.setTime(date);
	  if(strTaskConstraint.equals(DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_TYPE_RANGE_SNLT)|| strTaskConstraint.equals(DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_TYPE_RANGE_SNET) || strTaskConstraint.equals(DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_TYPE_RANGE_MSON))
	  {
		  constraintDate.set(Calendar.HOUR_OF_DAY, 8);
	  }else if(strTaskConstraint.equals(DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_TYPE_RANGE_MFON)|| strTaskConstraint.equals(DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_TYPE_RANGE_FNLT) || strTaskConstraint.equals(DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_TYPE_RANGE_FNET))
	  {
		  constraintDate.set(Calendar.HOUR_OF_DAY, 17);
	  }
	  constraintDate.set(Calendar.MINUTE, 0);
	  constraintDate.set(Calendar.SECOND, 0);
	  strTaskConstraintDate = dateFmt.format(constraintDate.getTime());
  }

MapList attrMapList    = (MapList) session.getAttribute("attributeMapCreate");
  session.removeAttribute("attributeMapCreate");
  String durnFromDB = "";
  DomainObject dojTestBus = new DomainObject(busId);
  String strTypeBus=(String)dojTestBus.getInfo(context,DomainConstants.SELECT_TYPE);

	ArrayList summaryTaskAL = new ArrayList();

StringList slBusSelect = new StringList(ProgramCentralConstants.SELECT_ID);
	 slBusSelect.add("from["+ProgramCentralConstants.RELATIONSHIP_SUBTASK+"]");

  MapList mlRelatedObjects = dojTestBus.getRelatedObjects(context,
				ProgramCentralConstants.RELATIONSHIP_SUBTASK, //pattern to match relationships
				ProgramCentralConstants.TYPE_TASK_MANAGEMENT, //pattern to match types
				slBusSelect, //the eMatrix StringList object that holds the list of select statement pertaining to Business Obejcts.
				new StringList(), //the eMatrix StringList object that holds the list of select statement pertaining to Relationships.
				false, //get To relationships
				true, //get From relationships
				(short)0, //the number of levels to expand, 0 equals expand all.
				ProgramCentralConstants.EMPTY_STRING, //where clause to apply to objects, can be empty ""
				ProgramCentralConstants.EMPTY_STRING, //where clause to apply to relationship, can be empty ""
				0);//limit

 task.setId(parentTaskId);
 String parentTaskType = task.getInfo(context, DomainConstants.SELECT_TYPE);

 // if policy is null or blank, get the default policy
 if (selectedPolicy == null || selectedPolicy.equals("") || selectedPolicy.equals("null")){
   selectedPolicy = task.getDefaultPolicy(context);
 }

 String projectType  = DomainConstants.TYPE_PROJECT_SPACE;
 String templateType = DomainConstants.TYPE_PROJECT_TEMPLATE;
 String conceptType  = DomainConstants.TYPE_PROJECT_CONCEPT;
 String sAttributeProjectRole = PropertyUtil.getSchemaProperty( context, "attribute_ProjectRole" );
 String sProjectRole    = (String) emxGetParameter( request, sAttributeProjectRole );	    
		
 String memberName = ProgramCentralConstants.EMPTY_STRING;
 if ( txtOwner != null && !txtOwner.equals( "" ) ) {
     person.setId(txtOwner);
     memberName = person.getName(context);
 }
 
 
 String query = "print bus $1 select $2 dump";
 String resultInputValue =  MqlUtil.mqlCommand(context, query,busId, "attribute["+taskEstimatedDuration+"].inputunit"); 
 
  for(int k=0;k<nTasksToAdd;k++){
//Added:23-Jun-09:yox:R208:PRG:Project & Task Autonaming
  if(taskName == null || "QuickWBS".equalsIgnoreCase(strMode)){
  //Updated type for seperate autonaming if available for the Task subtype
      String symTaskType = com.matrixone.apps.domain.util.PropertyUtil.getAliasForAdmin(context, "Type", taskType, true);
      taskName =  com.matrixone.apps.domain.util.FrameworkUtil.autoName(context,
              symTaskType,
              null,
              "policy_ProjectTask",
              null,
              null,
              true,
              true);
  }
//End:R208:PRG :Project & Task Autonaming
  

  
 
  Map tasks = (Map) new HashMap();

  Iterator iterator = mlRelatedObjects.iterator();
	 while(iterator.hasNext()){
		 Map taskMap = (Map)iterator.next();
		 String subtask = (String)taskMap.get("from["+ProgramCentralConstants.RELATIONSHIP_SUBTASK+"]");
		 String id = (String)taskMap.get(ProgramCentralConstants.SELECT_ID);

		 if("True".equalsIgnoreCase(subtask)){
			 summaryTaskAL.add(id);
			}
    }
  //code for retrieving hierarchy of summary tasks ends

  try {
    task.startTransaction(context, true);
  
    // create the new task
   
    if(parentTaskType.equals(projectType)) {
      project.setId(parentTaskId);
      if ( !bAddSubtask ) {
        newTask.create(context, taskType, taskName, selectedPolicy, project);
      } else {
        newTask.create(context, taskType, taskName, selectedPolicy, project, selectedNodeId);
      }

       } else if(parentTaskType.equals(templateType)) {
      template.setId(parentTaskId);
      if ( !bAddSubtask ) {
        newTask.create(context, taskType, taskName, selectedPolicy, template);
      } else {
        newTask.create(context, taskType, taskName, selectedPolicy, template, selectedNodeId);
      }

        } else if(parentTaskType.equals(conceptType)) {
      concept.setId(parentTaskId);
      if ( !bAddSubtask ) {
          newTask.create(context, taskType, taskName, selectedPolicy, concept);
      } else {
          newTask.create(context, taskType, taskName, selectedPolicy, concept, selectedNodeId);
      }

    } else {
      if ( !bAddSubtask ) {
          newTask.create(context, taskType, taskName, selectedPolicy, task);
      } else {
          newTask.create(context, taskType, taskName, selectedPolicy, task, selectedNodeId);
      }
   }

    ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"),DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
    try 
    {
    	//if loop added by ixe
    if (taskRequirement != null) {
    	 if(isECHInstalled){
    		 if(newTask.isKindOf(context, PropertyUtil.getSchemaProperty(context,"type_ChangeTask"))){
    			   taskRequirement = "Mandatory";
    		 }
     }
      newTask.setAttributeValue(context, task.ATTRIBUTE_TASK_REQUIREMENT, taskRequirement);
    }
    if (taskDescription != null && ! taskDescription.equals("")) {
      newTask.setDescription(context, taskDescription);
    }


    if ( sProjectRole != null ) {
        newTask.setAttributeValue( context, sAttributeProjectRole, sProjectRole );
    }
    //Added:10-Nov-09:nzf:R209:PRG:WBS Task Constraint

    //Add Task Constraint
    if ( strTaskConstraint != null ) {
        newTask.setAttributeValue( context, DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_TYPE, strTaskConstraint );
    }

    //Add Task Constraint Date
    if ( strTaskConstraintDate != null ) {
        newTask.setAttributeValue( context, DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_DATE, strTaskConstraintDate );
    }

    //END:nzf:R209:PRG:WBS Task Constraint


    if(attrMapList != null) {
      HashMap processMap      = new HashMap();
      Iterator attrMapListItr = attrMapList.iterator();
 
      while(attrMapListItr.hasNext())
      {
        Map item = (Map) attrMapListItr.next();
        String attrName  = (String) item.get("NAME");
        String attrType  = (String) item.get("TYPE");
        String attrValue = (String) emxGetParameter(request, attrName);
        //websphere's calendar issue with spaces
        if(attrType.equals("timestamp")){
            String attrDateinMS = (String) emxGetParameter(request, attrName + "_msvalue");
            if(ProgramCentralUtil.isNotNullString(attrDateinMS))
            {	
               Date dynamicAttrDate = new Date(Long.parseLong(attrDateinMS));
               DateFormat dateFmt = DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), Locale.US);
               attrValue = dateFmt.format(dynamicAttrDate);
            }
          attrName = attrName.replace('~',' ');
        }
        processMap.put(attrName, attrValue);
       }
      newTask.setAttributeValues(context, processMap);
    }


    // Set task owner
    if (ProgramCentralUtil.isNotNullString(memberName) ) {
        newTask.setOwner( context, memberName );
        strOwnerCalendarID = newTask.getOwnerCalendar(context);
    }

    // Set task assignees
    if ( memberIds != null ) {
        for ( int i=0; i<memberIds.length; i++ ) {
            String percentAllocation = (String) emxGetParameter(request, "PA"+memberIds[i]);
            newTask.addAssignee( context, memberIds[i], null, percentAllocation);
        }
     // [ADDED::PRG:RG6:Jan 13, 2011:IR-075151V6R2012 :R211::start] 
             //logic for promoting task  state to assinged 
	        String strAssignStateName = PropertyUtil.getSchemaProperty(context,"policy",DomainConstants.POLICY_PROJECT_TASK,"state_Assign");
	        
	        Map mapTaskParam = new HashMap();
	        mapTaskParam.put("taskPolicy",selectedPolicy);
	        
	        if(Task.isToMoveTaskInToAssignState(context,mapTaskParam)){
	        	newTask.setState(context,strAssignStateName);  
	        }
        
     // [ADDED::PRG:RG6:Jan 13, 2011:IR-075151V6R2012 :R211::end]        
    }

    // configurating the duration
    if (duration != null && "".equals(duration.trim()))
    {
      duration = "0";
    }
   // start: Added for Task calender feature
    if(strcalendar != null && !"".equals(strcalendar.trim())){
    	newTask.addCalendar(context,strcalendar);
    }
  //  end: Added for Task calender feature

    Double newDuration = new Double(Double.valueOf(duration).doubleValue());
    if(newDuration.doubleValue() < 0)
    {
       newDuration = new Double(Double.valueOf("0").doubleValue());
    }
 //Added:10-Dec-09:wqy:R209:PRG:Keyword Duration
    if(null!=newDurationKeyword && !"NotSelected".equalsIgnoreCase(newDurationKeyword))
    {
    	newDurationKeyword = newDurationKeyword.substring(0,newDurationKeyword.indexOf("|"));
        newTask.setAttributeValue(context,task.ATTRIBUTE_ESTIMATED_DURATION_KEYWORD,newDurationKeyword);
        if(bAddSubtask)
        {
        	if(task.isKindOf(context,DomainConstants.TYPE_TASK_MANAGEMENT))
            {
        		task.setAttributeValue(context,task.ATTRIBUTE_ESTIMATED_DURATION_KEYWORD,"");
            }
        }
    }
 //End:R209:PRG :Keyword Duration

	if(newUnit.equalsIgnoreCase("d"))
	{
		//fetch the previous inputunits of project and summary tasks
		//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start

         //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End

		StringList summaryTaskPrior = new StringList();
        String summaryTask[] = new String[summaryTaskAL.size()];
        
        StringList summaryTaskSelectables = new StringList(ProgramCentralConstants.SELECT_ID);
        summaryTaskSelectables.add("attribute["+taskEstimatedDuration+"].inputunit");
        
        for(int i=0 ; i<summaryTaskAL.size(); i++){
        	summaryTask[i] = (String)summaryTaskAL.get(i);
        }
		MapList summaryTaskInputUnitList = new MapList();
		if(summaryTask.length > 0){
			summaryTaskInputUnitList =	DomainObject.getInfo(context, summaryTask, summaryTaskSelectables);
		}
		Iterator itr = summaryTaskInputUnitList.iterator();
	
	  String resultInputValueTask ="";
		while(itr.hasNext())
		{
				Map summaryTaskMap = (Map) itr.next();
			        resultInputValueTask =  (String)summaryTaskMap.get("attribute["+taskEstimatedDuration+"].inputunit"); 
				summaryTaskPrior.add(resultInputValueTask);
		}
		//fetch the previous inputunits of project and summary tasks ends
		String tempnewDuration = newDuration+"";
	    String message = newTask.updateDuration(context,tempnewDuration);
		//set the project ans summary tasks with the previous input units starts
		//set Project with previous unit value starts
		if(resultInputValue.equalsIgnoreCase("h") )
		{
			//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
            query = "print bus $1 select $2 dump";
            String resultUnitValue =  MqlUtil.mqlCommand(context, query, busId, "attribute["+taskEstimatedDuration+"].unitvalue["+resultInputValue+"]"); 
            //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End

            resultUnitValue = resultUnitValue + " " + resultInputValue;

			dojTestBus.setAttributeValue(context,taskEstimatedDuration,resultUnitValue);
		}
		//set Project with previous unit value ends
        //set Summarytasks with previous unit value starts
		Iterator itrSummaryTasks = summaryTaskAL.iterator();
		
		int i=0;
		while(itrSummaryTasks.hasNext()){
			String summaryId =(String)itrSummaryTasks.next();
			String unitSummary = (String)summaryTaskPrior.get(i);
			//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
            query = "print bus $1 select $2 dump";
            String resultUnitSummaryValue =  MqlUtil.mqlCommand(context, query, summaryId, "attribute["+taskEstimatedDuration+"].unitvalue["+unitSummary+"]"); 
            //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
            
			resultUnitSummaryValue=resultUnitSummaryValue+" "+unitSummary;
			DomainObject dojSummary = new DomainObject(summaryId);
			dojSummary.setAttributeValue(context,taskEstimatedDuration,resultUnitSummaryValue);
			i++;
		}
		
		//set Summarytasks with previous unit value ends
		//set the project ans summary tasks with the previous input units starts

		//set the units and corresponding value of immediate parent task to hrs
		if(!parentTaskType.equals("Project Space") && strTypeBus.equals("Project Space"))
		{
			//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
            String queryProject = "print bus $1 select $2 dump";
            String resultProjectUnit =  MqlUtil.mqlCommand(context, queryProject, busId, "attribute["+taskEstimatedDuration+"].inputunit"); 
            //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
            
			//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
            String queryParent = "print bus $1 select $2 dump";
            String resultUnitSummaryValue =  MqlUtil.mqlCommand(context, queryParent, parentTaskId, "attribute["+taskEstimatedDuration+"].unitvalue["+resultProjectUnit+"]"); 
            //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
            
			resultUnitSummaryValue =resultUnitSummaryValue + " "+resultProjectUnit;
			dojParentTaskId.setAttributeValue(context,taskEstimatedDuration,resultUnitSummaryValue);
		}

    }
	else if(newUnit.equalsIgnoreCase("h")){
			DomainObject dojTask = new DomainObject((String)newTask.getObjectId(context));
			String durationWithUnit = duration+" "+newUnit;
			dojTask.setAttributeValue(context,taskEstimatedDuration,durationWithUnit);
			durnFromDB = (String)dojTask.getAttributeValue(context,taskEstimatedDuration);
			double durn1 = Double.parseDouble(durnFromDB);

			String durn = durationWithUnit;
			//Long durn = new Long(Double.valueOf(durnFromDB).longValue());
			//fetch the previous input units of project and summaryTasks starts
			//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start

	        //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
	        
	        StringList summaryTaskPrior = new StringList();
	
			Iterator itr = summaryTaskAL.iterator();
			String resultInputValueTask ="";
			while(itr.hasNext())
			{
				String value=(String) itr.next();
				//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
	            query = "print bus $1 select $2 dump";
	            resultInputValueTask = MqlUtil.mqlCommand(context, query, value, "attribute["+taskEstimatedDuration+"].inputunit"); 
	            //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
	            
				summaryTaskPrior.add(resultInputValueTask);
			}

			//fetch the previous input units of project and summaryTasks ends
			addUpdate(tasks, (String)newTask.getObjectId(context), "durationS", durn);
			task.updateDates(context, tasks);
			//set Summarytasks with previous unit value starts
			//set the project ans summary tasks with the previous input units starts
		//set Project with previous unit value starts
		if(resultInputValue.equalsIgnoreCase("h") )
		{
			//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
            query = "print bus $1 select $2 dump";
            String resultUnitValue = MqlUtil.mqlCommand(context, query, busId, "attribute["+taskEstimatedDuration+"].unitvalue["+resultInputValue+"]"); 
            //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
            
			resultUnitValue=resultUnitValue+" "+resultInputValue;
			dojTestBus.setAttributeValue(context,taskEstimatedDuration,resultUnitValue);
		}
		//set Project with previous unit value ends
        //set Summarytasks with previous unit value starts

		Iterator itrTask = summaryTaskAL.iterator();
		int i=0;
		while(itrTask.hasNext()){
			String summaryId =(String)itrTask.next();
			String unitSummary = (String)summaryTaskPrior.get(i);
			//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
            query = "print bus $1 select $2 dump";
            String resultUnitSummaryValue = MqlUtil.mqlCommand(context, query, summaryId, "attribute["+taskEstimatedDuration+"].unitvalue["+unitSummary+"]"); 
            //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
            
			resultUnitSummaryValue=resultUnitSummaryValue+" "+unitSummary;
			DomainObject dojSummary = new DomainObject(summaryId);
			dojSummary.setAttributeValue(context,taskEstimatedDuration,resultUnitSummaryValue);
			i++;
		}
		
		//set Summarytasks with previous unit value ends
		//set the project and summary tasks with the previous input units ends

		//set the units and corresponding value of immediate parent task to hrs

		if(!parentTaskType.equals("Project Space") && strTypeBus.equals("Project Space"))
		{
			//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
            String queryProject = "print bus $1 select $2 dump";
            String resultProjectUnit = MqlUtil.mqlCommand(context, queryProject, busId, "attribute["+taskEstimatedDuration+"].inputunit"); 
            //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
            
			//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
            String queryParent = "print bus $1 select $2 dump";
            String resultUnitSummaryValue = MqlUtil.mqlCommand(context, queryParent, parentTaskId, "attribute["+taskEstimatedDuration+"].unitvalue["+resultProjectUnit+"]"); 
            //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
            
			resultUnitSummaryValue =resultUnitSummaryValue + " "+resultProjectUnit;
			dojParentTaskId.setAttributeValue(context,taskEstimatedDuration,resultUnitSummaryValue);

		}
	}
 
      // commit the data
    ContextUtil.commitTransaction(context);
    //ADDED:1-Dec-09:nzf:R209:PRG:WBS Task Constraint
   // task.rollupAndSave(context);
    //END:NZF:R209:PRG:WBS Task Constraint
    
    String newTaskId = (String)newTask.getId();
    	    slNewTAskIds.add(newTaskId);

	

	//Change Discipline if Change Task
    if(isECHInstalled){
		if(newTask.isKindOf(context, PropertyUtil.getSchemaProperty(context,"type_ChangeTask"))){
			String taskId = newTask.getInfo(context, DomainConstants.SELECT_ID);

			
	    	if(taskId!=null && !taskId.equalsIgnoreCase("")){
	    		//add interface attribute for Change Discipline
	    		String strInterfaceName = PropertyUtil.getSchemaProperty(context,"interface_ChangeDiscipline");
	    		//Check if an the change discipline interface has been already connected
	    		//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
	            String strCommand = "print bus $1 select $2 dump";
	            String strMessage = MqlUtil.mqlCommand(context, strCommand, taskId, "interface["+ strInterfaceName + "]"); 
	            //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
	            
	    		//If no interface --> add one
	    		if(strMessage.equalsIgnoreCase("false")){
	    			//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
	                String strAddInterface = "modify bus $1 add interface $2";
	                String strAddInterfaceMessage = MqlUtil.mqlCommand(context, strAddInterface, taskId, strInterfaceName); 
	                //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
	    		}

	            BusinessInterface busInterface = new BusinessInterface(strInterfaceName, context.getVault());
	            AttributeTypeList listInterfaceAttributes = busInterface.getAttributeTypes(context);

	            java.util.Iterator listInterfaceAttributesItr = listInterfaceAttributes.iterator();
	            while(listInterfaceAttributesItr.hasNext()){
	          	  String attrName = ((AttributeType) listInterfaceAttributesItr.next()).getName();
	          	  String attrNameSmall = attrName.replaceAll(" ", "");
	          	  String attrNameSmallHidden = attrNameSmall + "Hidden";
	          	  String attrNameValue = emxGetParameter(request,attrNameSmallHidden);
	          	
	          	  if((ProgramCentralConstants.TYPE_CHANGE_TASK).equals(strTasksTypeToAdd)){
	          		newTask.setAttributeValue(context, attrName, "Yes");
	          	  }else{
	          		  if(attrNameValue!=null && !attrNameValue.equalsIgnoreCase("") && !attrNameValue.equalsIgnoreCase("No")){
	          			   newTask.setAttributeValue(context, attrName, attrNameValue);
	          		  }else{
	          			   newTask.setAttributeValue(context, attrName, "No");
	          		  }
	          	   }
	            }
	    	}
		}
    }//End of Change Discipline if Change Task

	//Added for Applicability Context
	if(isECHInstalled){
		Boolean showApplicabilityContext = false;
		try{
			//Boolean manageApplicability = Boolean.valueOf(FrameworkProperties.getProperty(context, "emxEnterpriseChange.ApplicabilityManagement.Enable"));
			Boolean manageApplicability = true;
			if(manageApplicability!=null){
				showApplicabilityContext = manageApplicability;
			}
		}catch(Exception e){
			showApplicabilityContext = false;
		}
		if (showApplicabilityContext) {
		if(newTask.isKindOf(context, PropertyUtil.getSchemaProperty(context,"type_ChangeTask"))){
			String applicabilityContexts = (String) emxGetParameter(request, "ApplicabilityContextsHidden");
			if (applicabilityContexts!= null && !applicabilityContexts.isEmpty()) {
				StringList applicabilityContextsList = FrameworkUtil.split(applicabilityContexts, ",");
				if (applicabilityContextsList!= null && !applicabilityContextsList.isEmpty()) {
					for(int i=0;i<applicabilityContextsList.size();i++){
						String applicabilityContext = (String)applicabilityContextsList.get(i);
						if (applicabilityContext!=null && !applicabilityContext.isEmpty()) {
							DomainRelationship domRel = DomainRelationship.connect(context,
									new DomainObject(newTaskId),
									PropertyUtil.getSchemaProperty(context,"relationship_ImpactedObject"),
									new DomainObject(applicabilityContext));
						}
					}
				}
			}
		}
		}else{
			String strImpactedObject = (String) emxGetParameter(request, "impactedObjectHidden");
			if(strImpactedObject != null && !strImpactedObject.equalsIgnoreCase("")){
				DomainRelationship domRel = DomainRelationship.connect(context,
						new DomainObject(newTaskId),
						PropertyUtil.getSchemaProperty(context,"relationship_ImpactedObject"),
						new DomainObject(strImpactedObject));
			}
		}
	}
	//End Added for Applicability Context
	
	
    // reset the task to the parent
    task.setId(parentTaskId);
    }finally 
    {
        ContextUtil.popContext(context); //pushpop
    }
    } catch(Exception e) {
    ContextUtil.abortTransaction(context);
    e.printStackTrace();
    throw e;
  }
  }//End Task Add for loop
  String strWhere = "(id matchlist \"" + FrameworkUtil.join(slNewTAskIds,",") +"\" \",\")";
    MapList utsList = task.getRelatedObjects(context,
                                relType,
                                DomainConstants.TYPE_TASK_MANAGEMENT,
                                busSelects,
                                relSelects, // relationshipSelects
                                false,      // getTo
                                true,       // getFrom
                                (short) 1,  // recurseToLevel
                                strWhere,// objectWhere
                                null);      // relationshipWhere
    String newTaskAction = "add";
    utsList.sortStructure(context, attrTaskWBSId, "ascending", "emxWBSColumnComparator");

    sBuff.append("<mxRoot>");
    sBuff.append("<action><![CDATA["+newTaskAction+"]]></action>");
			for(int j=0;j<utsList.size();j++){
				 Map map = (Map)utsList.get(j);
				 String newTaskId = (String)map.get(DomainConstants.SELECT_ID);
				 String newTaskRelId = (String)map.get(DomainConstants.SELECT_RELATIONSHIP_ID);
				 String newTaskRelDir = (String)map.get(DomainRelationship.SELECT_DIRECTION);

    if (isFromRMB) {
        sBuff.append("<data fromRMB=\"true\" status=\"committed\">");
    }
    else {
    sBuff.append("<data status=\"committed\">");
    }

    sBuff.append("<item oid=\""+newTaskId+"\" relId=\""+newTaskRelId+"\" pid=\""+parentTaskId+"\"  direction=\""+newTaskRelDir+"\" />");
    sBuff.append("</data>");
		}
    sBuff.append("</mxRoot>");
    // End WBS AddProcess with SB Add/Remove Feture Implementation
      
 %>


<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><html>
<%@page import="com.matrixone.apps.common.Person"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%><html>
  <body>
    <form name="wbsAddProcess" method="post">
      <input type="hidden" name="taskName" value="<xss:encodeForHTMLAttribute><%=newTask.getName(context)%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="taskType" value="<xss:encodeForHTMLAttribute><%=taskType%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="function" value="<xss:encodeForHTMLAttribute><%=function%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="selectedNodeId" value="<xss:encodeForHTMLAttribute><%=selectedNodeId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=parentTaskId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="busId" value="<xss:encodeForHTMLAttribute><%=busId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="taskId" value="<xss:encodeForHTMLAttribute><%=parentTaskId%></xss:encodeForHTMLAttribute>" />
      <%-- <input type="hidden" name="memberId" value="<%=memberId%>"> --%>
      <%-- <input type="hidden" name="makeOwner" value="<%=makeOwner%>"> --%>
      <input type="hidden" name="taskName" value="<xss:encodeForHTMLAttribute><%=taskName%></xss:encodeForHTMLAttribute>" />
<!-- Added:23-Jun-09:yox:R208:PRG:Project & Task Autonaming-->
      <input type="hidden" name="taskAutoName" value="<xss:encodeForHTMLAttribute><%=taskAutoName%></xss:encodeForHTMLAttribute>" />
<!--End:R208:PRG :Project & Task Autonaming-->

      <input type="hidden" name="taskDescription" value="<xss:encodeForHTMLAttribute><%=taskDescription%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="selectedPolicy" value="<xss:encodeForHTMLAttribute><%=selectedPolicy%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="duration" value="<xss:encodeForHTMLAttribute><%=duration%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="unitCB" value="<xss:encodeForHTMLAttribute><%=newUnit%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="durationKeyword" value="<xss:encodeForHTMLAttribute><%=newDurationKeyword%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="taskRequirement" value="<xss:encodeForHTMLAttribute><%=taskRequirement%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="fromPage" value="<xss:encodeForHTMLAttribute><%=fromPage%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="isFromRMB" value="<xss:encodeForHTMLAttribute><%=isFromRMB%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="contentPageIsDialog" value="true" />
      <input type="hidden" name="portalCmdName" value="<xss:encodeForHTMLAttribute><%=strPortalCommandName%></xss:encodeForHTMLAttribute>" />
	<!--Added:R212_HF3:ECH:Applicability Context-->
	<%if (isECHInstalled) {
		if (newTask.isKindOf(context, PropertyUtil.getSchemaProperty(context,"type_ChangeTask"))) {
			String applicabilityContexts = (String) emxGetParameter(request, "ApplicabilityContextsHidden");
			if (applicabilityContexts!=null && !applicabilityContexts.isEmpty()) {
				%><input type="hidden" name="applicabilityContext" value="<%=applicabilityContexts%>" /><%
			}
		}
	}%>
	<!--End:R212_HF3:ECH:Applicability Context-->
	  
    </form>
  </body>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
<%
	if(strOwnerCalendarID != null && !"".equals(strOwnerCalendarID)&& strcalendar != null && !"".equals(strcalendar)){
		if(!strOwnerCalendarID.equals(strcalendar)){
			// put Warning message
			%>
			alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CalendarMismatchWarning</framework:i18nScript>");
	       <%
		}
	}

%>

<%   if(fromPage!=null && "StructureBrowser".equalsIgnoreCase(fromPage)){
%>
		var topFrame = findFrame(getTopWindow(), "<%=currentframe%>");
		if(null == topFrame){
			topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
		if(null == topFrame)
			topFrame = findFrame(getTopWindow(), "detailsDisplay");	
		}
		topFrame.toggleProgress('hidden');

       topFrame.emxEditableTable.addToSelected('<%=XSSUtil.encodeForJavaScript(context,sBuff.toString())%>');
       topFrame.emxEditableTable.refreshStructureWithOutSort();
		
       <%--XSSOK--%>
 if(<%=done.equals("notDone")%>) {
          var curentTab = "<%= XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "portalCmdName"))%>";
          form = document.wbsAddProcess;
          form.action="emxProgramCentralWBSAddDialog.jsp"; 
          
          form.submit();
        }
        else{
		  // Start WBS AddProcess with SB Add/Remove Feture Implementation
            //XSSOK
          if(!(<%="QuickWBS".equals(strMode)%>))
          	getTopWindow().closeSlideInDialog();
  		  // End WBS AddProcess with SB Add/Remove Feture Implementation
        }
<%  }
    else{
%>
    parent.window.getWindowOpener().document.forms[0].taskId.value = '<%=XSSUtil.encodeForHTML(context,parentTaskId)%>';
    parent.window.getWindowOpener().reloadWBS();
    <%--XSSOK--%>
if(<%=done.equals("notDone")%>) {
	turnOffProgress();
      form = document.wbsAddProcess;
      form.action="emxProgramCentralWBSAddDialog.jsp";
      form.submit();
    }
    else {
      parent.window.closeWindow();
    }
<% } %>
    // Stop hiding here -->//]]>
  </script>
</html>
<%  } catch(Exception e) {
      ContextUtil.abortTransaction(context);
      e.printStackTrace();
%>
     <script language="Javascript">
          alert('<%=e.getMessage()%>');
          getTopWindow().closeSlideInDialog();
     </script>
<%
    }
%>
