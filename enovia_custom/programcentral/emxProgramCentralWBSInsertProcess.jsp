<%--  emxProgramCentralWBSInsertProcess.jsp

   Performs the action to add a new task to a project

  Copyright (c) 2007 Dassault Systemes, Inc.
  Copyright (c) 1992-2015 MatrixOne, Inc.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  Reviewed for Level III compliance by JDH 5/2/2002

  static const char RCSID[] = "$Id: emxProgramCentralWBSInsertProcess.jsp.rca 1.27 Tue Oct 28 18:55:12 2008 przemek Experimental przemek $";
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
     <script language="javascript" type="text/javascript" src="emxUICore.js"></script>
</head>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>


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
  String taskEstimatedDuration = PropertyUtil.getSchemaProperty(context, "attribute_TaskEstimatedDuration");
  String parentTaskId    = (String) emxGetParameter(request, "parentTaskId");

  String busId           = (String) emxGetParameter(request, "busId");
  String projectID       = (String) emxGetParameter(request, "projectID");
  String objectId = (String) emxGetParameter(request, "objectId");
  String strMode = (String) emxGetParameter(request, "mode");
  String strLevel = "";
  String strTasksTypeToAdd = (String) emxGetParameter(request, "PMCWBSQuickTaskTypeToAddBelow");
  if(busId ==null){
      busId = objectId;
  }
  //End::2013:NZF:Quick WBS Functionality
  String emxTableRowId   =  emxGetParameter(request, "emxTableRowId");
  String[] memberIds     = (String[]) emxGetParameterValues( request, "txtAssignee" );
  String selectedNodeId  = (String) emxGetParameter(request, "taskId");
  //Added:2013:NZF:Quick WBS Functionality
  if("QuickWBS".equalsIgnoreCase(strMode)){
	  String selectedObjectID = (String) emxGetParameter(request, "emxTableRowId");
      StringList slResult = FrameworkUtil.splitString(selectedObjectID, "|");
      selectedNodeId = (String)slResult.get(1);
      strLevel = (String)slResult.get(3);
	  parentTaskId = (String)slResult.get(2);
	  //Do not insert Task Above on root node.
	  if ("0".equals(strLevel)) {
    	  %>
    	     <script language="Javascript">
    	     alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.CannotInsertOnRoot</framework:i18nScript>");
    	     </script>
    	  <%
	      return;
	  }
	  
	  //Code for checking if Task or Project is in Valid State 
      DomainObject dmo = DomainObject.newInstance(context,parentTaskId);
      StringList objectSelects = new StringList(2);
      objectSelects.add(DomainConstants.SELECT_CURRENT);
      objectSelects.add(DomainConstants.SELECT_POLICY);
      
      Map parentInfo = dmo.getInfo(context,objectSelects);
      
      String strState = (String)parentInfo.get(DomainConstants.SELECT_CURRENT);
      String parentPolicy = (String)parentInfo.get(DomainConstants.SELECT_POLICY);
      
      if(ProgramCentralConstants.STATE_PROJECT_REVIEW_REVIEW.equalsIgnoreCase(strState) || ProgramCentralConstants.STATE_PROJECT_REVIEW_COMPLETE.equalsIgnoreCase(strState) || ProgramCentralConstants.STATE_PROJECT_REVIEW_ARCHIEVE.equalsIgnoreCase(strState)){
          %>
           <script language="javascript" type="text/javaScript">
           alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.InvalidParent</framework:i18nScript>");
           </script>
          <%
          return;
      }
		StringList reviewTypelist = ProgramCentralUtil.getSubTypesList(context, ProgramCentralConstants.TYPE_GATE);
		reviewTypelist.addAll(ProgramCentralUtil.getSubTypesList(context, ProgramCentralConstants.TYPE_MILESTONE));
		if(ProgramCentralConstants.POLICY_PROJECT_REVIEW.equalsIgnoreCase(parentPolicy) && !(reviewTypelist.contains(strTasksTypeToAdd)) )
		{
			%>
	    	   <script language="javascript" type="text/javaScript">
	    	   alert("<framework:i18nScript localize="i18nId">emxProgramCentral.WBS.TaskCannotAdded</framework:i18nScript>");
	           </script>
	    	<%
	    	return;
  }

  }
  //End::2013:NZF:Quick WBS Functionality
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
  String duration        = (String) emxGetParameter(request, "duration");
  String newUnit        = (String) emxGetParameter(request, "unitCB");
  String newDurationKeyword = (String) emxGetParameter(request, "durationKeyword");
  String memberId        = (String) emxGetParameter(request, "memberId");
  String makeOwner       = (String) emxGetParameter(request, "makeOwner");
  String strcalendar  = (String) emxGetParameter(request, "hideCalendar");
  //Added:10-Nov-09:nzf:R209:PRG:WBS Task Constraint
  String strTaskConstraint = (String) emxGetParameter(request, "TaskConstraintType");
  String strTaskConstraintDate = (String) emxGetParameter(request, "TaskConstraintDate");

  //Added:18-Jan-10:nzf:R209:PRG:Bug:IR-033629
  //Added:2013:NZF:Quick WBS Functionality
  String strTasksToAdd = (String) emxGetParameter(request, "PMCWBSQuickTasksToAddBelow");

  int nTasksToAdd = 1;
  String currentframe = XSSUtil.encodeForJavaScript(context, (String)emxGetParameter(request, "portalCmdName"));
  String strPortalCommandName = (String)emxGetParameter(request, "portalCmdName");
  //Start WBS AddProcess with SB Add/Remove Feture Implementation
  StringList busSelects = new StringList(2);
  busSelects.addElement(DomainConstants.SELECT_ID);
  busSelects.addElement(DomainConstants.SELECT_NAME);
  StringList relSelects = new StringList(2);
  relSelects.addElement(DomainConstants.SELECT_RELATIONSHIP_ID);
  relSelects.addElement(DomainRelationship.SELECT_DIRECTION);
  String relType = DomainConstants.RELATIONSHIP_SUBTASK;
  String fromPage  = (String) emxGetParameter(request, "fromPage");
  boolean isFromRMB = "true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB"));
  if("QuickWBS".equalsIgnoreCase(strMode)){
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
      String selectedObjectID = (String) emxGetParameter(request, "emxTableRowId");
      slResult = FrameworkUtil.splitString(selectedObjectID, "|");
      selectedNodeId = (String)slResult.get(1);
      //parentTaskId = selectedNodeId;
        isFromRMB =  false;
      done = "Done";
  }
  
  StringList slNewTaskIds = new StringList(nTasksToAdd);
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

  DateFormat dateFmt = DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), Locale.US);
  strTaskConstraintDate = dateFmt.format(date);
  }
 
  MapList attrMapList    = (MapList) session.getAttribute("attributeMapCreate");
  session.removeAttribute("attributeMapCreate");
  DomainObject dojTestBus = DomainObject.newInstance(context,busId);
  String strTypeBus=(String)dojTestBus.getInfo(context,DomainConstants.SELECT_TYPE);

  //code for retrieving hierarchy of summary tasks starts
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
 String parentTaskType = task.getInfo(context, task.SELECT_TYPE);

 if (selectedPolicy == null || selectedPolicy.equals("") || selectedPolicy.equals("null")){
	  selectedPolicy = task.getDefaultPolicy(context);
  }
 
 String projectType = DomainConstants.TYPE_PROJECT_SPACE;
 String templateType = DomainConstants.TYPE_PROJECT_TEMPLATE;
 String conceptType = DomainConstants.TYPE_PROJECT_CONCEPT;
 
 String sAttributeProjectRole = PropertyUtil.getSchemaProperty( context, "attribute_ProjectRole" );
 String sProjectRole    = (String) emxGetParameter( request, sAttributeProjectRole );
 
 String memberName = ProgramCentralConstants.EMPTY_STRING;
 if ( txtOwner != null && !txtOwner.equals( "" ) ) {
     person.setId(txtOwner);
     memberName = person.getName(context);
 }
 
	String resultInputValue = MqlUtil.mqlCommand(context,"print bus $1 select $2 dump",busId,"attribute["+taskEstimatedDuration+"].inputunit");
  
  for(int k=0;k<nTasksToAdd;k++){
  //End::2013:NZF:Quick WBS Functionality
  
  //End:R209:PRG:Bug:IR-033629

  //END:nzf:R209:PRG:WBS Task Constraint
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
      newTask.create(context, taskType, taskName, selectedPolicy, project, selectedNodeId);
	
    } else if(parentTaskType.equals(templateType)) {
      template.setId(parentTaskId);
      newTask.create(context, taskType, taskName, selectedPolicy, template, selectedNodeId);
       } else if(parentTaskType.equals(conceptType)) {
      concept.setId(parentTaskId);
      newTask.create(context, taskType, taskName, selectedPolicy, concept, selectedNodeId);
     } else {
      newTask.create(context, taskType, taskName, selectedPolicy, task, selectedNodeId);
    }

    if (taskRequirement != null) {
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
      HashMap processMap = new HashMap();
      Iterator attrMapListItr = attrMapList.iterator();
      while(attrMapListItr.hasNext())
      {
        Map item = (Map) attrMapListItr.next();
        String attrName = (String) item.get("NAME");
        String attrType = (String) item.get("TYPE");
        String attrValue = (String) emxGetParameter(request, attrName);
        //websphere's calendar issue with spaces
        if(attrType.equals("timestamp")) {
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

    //Added for ECH
	boolean isECHInstalled = com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appVersionEnterpriseChange",false,null,null);
	//End Added for ECH

	//Change Discipline if Change Task
    if(isECHInstalled){
		if(newTask.isKindOf(context, PropertyUtil.getSchemaProperty(context,"type_ChangeTask"))){
			String taskId = newTask.getInfo(context, DomainConstants.SELECT_ID);

	    	if(taskId!=null && !taskId.equalsIgnoreCase("")){
	    		//add interface attribute for Change Discipline
	    		String strInterfaceName = PropertyUtil.getSchemaProperty(context,"interface_ChangeDiscipline");
	    		//Check if an the change discipline interface has been already connected
	    		String strMessage = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context,"print bus $1 select $2", taskId,"interface["+strInterfaceName+"]");

	    		//If no interface --> add one
	    		if(strMessage.equalsIgnoreCase("false")){

	    			String strAddInterfaceMessage = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context,"modify bus $1 add interface $2", taskId,strInterfaceName);
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
		
		String newTaskId = (String)newTask.getId();
		
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
   // configurating the duration
    if (duration != null && "".equals(duration.trim()))
    {
      duration = "0";
    }
    // start: Added for Task calender feature
    if(strcalendar != null && !"".equals(strcalendar.trim())){
    	newTask.addCalendar(context,strcalendar);
    }
	// End: Added for Task calender feature

    Integer newDuration = new Integer(Double.valueOf(duration).intValue());
	if(newUnit.equals("h"))
	{
        newUnit="h";
		DomainObject dojTask = new DomainObject((String)newTask.getObjectId(context));
		duration = duration+" "+newUnit;
		dojTask.setAttributeValue(context,taskEstimatedDuration,duration);
		int index = duration.indexOf(" ");
	    duration = duration.substring(0,index);

	}


	//fetch the previous inputunits of project and summary tasks


	StringList summaryTaskPrior = new StringList();
	
		Iterator itr = summaryTaskAL.iterator();
		String resultInputValueTask ="";
		while(itr.hasNext())
		{
				String value=(String) itr.next();

				resultInputValueTask = MqlUtil.mqlCommand(context,"print bus $1 select $2 dump", value, "attribute["+taskEstimatedDuration+"].inputunit");
				summaryTaskPrior.add(resultInputValueTask);
		}
	
	//fetch the previous inputunits of project and summary tasks ends
    if(null!=newDurationKeyword && !"NotSelected".equalsIgnoreCase(newDurationKeyword))
    {
    	newDurationKeyword = newDurationKeyword.substring(0,newDurationKeyword.indexOf("|"));
        newTask.setAttributeValue(context,task.ATTRIBUTE_ESTIMATED_DURATION_KEYWORD,newDurationKeyword);
    }
    //String message = newTask.updateDuration(context,newDuration);
     String message = newTask.updateDuration(context,duration+ " " + newUnit);
	//set the project ans summary tasks with the previous input units starts
	//set Project with previous unit value starts
	if(resultInputValue.equalsIgnoreCase("h") )
	{

            String resultUnitValue = MqlUtil.mqlCommand(context,"print bus $1 select $2 dump",busId,"attribute["+taskEstimatedDuration+"].unitvalue["+resultInputValue+"]");
		resultUnitValue=resultUnitValue+" "+resultInputValue;
		DomainObject dojProj = new DomainObject(busId);

		dojProj.setAttributeValue(context,taskEstimatedDuration,resultUnitValue);
	}
		//set Project with previous unit value ends
        //set Summarytasks with previous unit value starts

		Iterator itrTask = summaryTaskAL.iterator();
		int i=0;
		while(itrTask.hasNext()){
			String summaryId =(String)itrTask.next();
			String unitSummary = (String)summaryTaskPrior.get(i);

			String resultUnitSummaryValue = MqlUtil.mqlCommand(context,"print bus $1 select $2 dump",summaryId,"attribute["+taskEstimatedDuration+"].unitvalue["+unitSummary+"]");;
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

		String resultProjectUnit = MqlUtil.mqlCommand(context,"print bus $1 select $2 dump",busId,"attribute["+taskEstimatedDuration+"].inputunit");
		
		String resultUnitSummaryValue = MqlUtil.mqlCommand(context,"print bus $1 select $2 dump",parentTaskId,"attribute["+taskEstimatedDuration+"].unitvalue["+resultProjectUnit+"]");
		resultUnitSummaryValue =resultUnitSummaryValue + " "+resultProjectUnit;
		task.setAttributeValue(context,taskEstimatedDuration,resultUnitSummaryValue);

    }

    slNewTaskIds.add(newTask.getId(context));
    // commit the data
    ContextUtil.commitTransaction(context);
    //ADDED:1-Dec-09:nzf:R209:PRG:WBS Task Constraint
   // task.rollupAndSave(context);
    //END:NZF:R209:PRG:WBS Task Constraint
  } catch(Exception e) {
    ContextUtil.abortTransaction(context);
    e.printStackTrace();
    throw e;
  }
  }
%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="java.util.Enumeration"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><html>
  <body>
    <form name="wbsInsertProcess" method="post">
	      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
      <input type="hidden" name="taskName" value="<xss:encodeForHTMLAttribute><%=newTask.getName(context)%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="taskType" value="<xss:encodeForHTMLAttribute><%=taskType%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="busId" value="<xss:encodeForHTMLAttribute><%=busId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="taskId" value="<xss:encodeForHTMLAttribute><%=selectedNodeId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="memberId" value="<xss:encodeForHTMLAttribute><%=memberId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="makeOwner" value="<xss:encodeForHTMLAttribute><%=makeOwner%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="taskName" value="<%=taskName%>" />
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
	  <input type="hidden" name="contentPageIsDialog" value="true"/>
	  <input type="hidden" name="portalCmdName" value="<xss:encodeForHTMLAttribute><%=strPortalCommandName%></xss:encodeForHTMLAttribute>" />
    </form>
  </body>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
<%
StringList slemxTableRowId = FrameworkUtil.split(emxTableRowId, "|");
    String newTaskId = "";
String strSubOperation="AddAbove";
String xmlMessage=null;
xmlMessage = "<mxRoot>" +
    "<action><![CDATA[add]]></action>" ;
//Modified:2013:NZF:Quick WBS Functionality    
for(int i=0;i<slNewTaskIds.size();i++){
	newTaskId = (String)slNewTaskIds.get(i);
	DomainObject newObject = DomainObject.newInstance(context, newTaskId);
	String TestRelId =  newObject.getInfo(context,"to[" + DomainRelationship.RELATIONSHIP_SUBTASK + "].id");
	xmlMessage += "<data status=\"noMarkupRows\" fromRMB=\"" + "\" " + (("AddChild".equals(strSubOperation))? "":"pasteBelowOrAbove=\"true\"") + " >" +
	"<item oid=\"" + newTaskId + "\" relId=\"" + TestRelId + "\" pid=\"" + busId + "\" direction=\"from\"" ;

if ("AddAbove".equals(strSubOperation))
{
xmlMessage += " pasteAboveToRow=\"" + slemxTableRowId.get(3) + "\" />";
}
	xmlMessage +="</data>";
}
//String newTaskId = newTask.getId();
    xmlMessage += "</mxRoot>";
//End:2013:NZF:Quick WBS Functionality    
if(fromPage!=null && "StructureBrowser".equalsIgnoreCase(fromPage)){
%>
	var topFrame = findFrame(getTopWindow(), "<%=currentframe%>");
	if(null == topFrame){
		topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
		if(null == topFrame)
			topFrame = findFrame(getTopWindow(), "detailsDisplay");	
	}
	topFrame.toggleProgress('hidden');
	
	    topFrame.emxEditableTable.removeRowsSelected('<%=xmlMessage%>');
	    topFrame.emxEditableTable.refreshStructureWithOutSort(); 

     <%--XSSOK--%> 
  if(<%=done.equals("notDone")%>) {
          topFrame.emxEditableTable.addToSelected('<%=XSSUtil.encodeForJavaScript(context, xmlMessage)%>');
          topFrame.emxEditableTable.refreshStructureWithOutSort();
          form = document.wbsInsertProcess;
          form.action="emxProgramCentralWBSInsertDialog.jsp?emxTableRowId="+'<%=XSSUtil.encodeForURL(context,emxTableRowId)%>';
          form.submit();
        }
        else{
             topFrame.emxEditableTable.addToSelected('<%=XSSUtil.encodeForJavaScript(context, xmlMessage)%>');
             topFrame.emxEditableTable.refreshStructureWithOutSort();
             getTopWindow().closeSlideInDialog();
        }
<%  }
    else{
%>
    parent.window.getWindowOpener().reloadWBS();
    <%--XSSOK--%>
  if(<%=done.equals("notDone")%>) {
      form = document.wbsInsertProcess;
      form.action="emxProgramCentralWBSInsertDialog.jsp?emxTableRowId="+'<%=XSSUtil.encodeForURL(context,emxTableRowId)%>';
      form.submit();
    }
    else {
      parent.window.closeWindow();
      parent.window.getWindowOpener().parent.document.focus();
    }
<%
	}
%>
    // Stop hiding here -->//]]>
  </script>
</html>
