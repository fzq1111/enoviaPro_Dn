<%-- emxProgramCentralWBSSummary.jsp

  Displays the tasks/phases for a given project.

  Copyright (c) 1992-2015 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = "$Id: emxProgramCentralWBSSummary.jsp.rca 1.83 Tue Oct 28 22:59:42 2008 przemek Experimental przemek $";
--%>

<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%
  com.matrixone.apps.program.Task task =
    (com.matrixone.apps.program.Task) DomainObject.newInstance(context,
    DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);
  com.matrixone.apps.program.ProjectSpace project =
    (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context,
    DomainConstants.TYPE_PROJECT_SPACE, DomainConstants.PROGRAM);
  com.matrixone.apps.common.Person person =
    (com.matrixone.apps.common.Person) DomainObject.newInstance(context,
    DomainConstants.TYPE_PERSON);

    boolean toExcel = false;
    String outputAsSpreadsheet = emxGetParameter(request, "outputAsSpreadsheet");
    if ("true".equals(outputAsSpreadsheet)){
    toExcel = true;
    }
%>
      <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%!

  static public int locateTask(MapList list, String taskId)
  {
    int index = -1;
    com.matrixone.apps.program.Task task = null;
    if (list != null && taskId != null)
    {
      Iterator itr = list.iterator();
      index = 0;
      while (itr.hasNext())
      {
        Map map = (Map) itr.next();
        String id = (String) map.get(task.SELECT_ID);
        if (taskId.equals(id))
        {
          break;
        }
        index++;
      }
    }
    return index;
  }
%>

<%
  ContextUtil.startTransaction(context, false);
  try
  {
    com.matrixone.apps.common.SubtaskRelationship subtask = null;
    String language = request.getHeader("Accept-Language");
    // Added for Critical Task Managment feature in Solution Library

    String SELECT_CRITICAL_TASK = null;
    String ATTRIBUTE_CRITICALTASK = PropertyUtil.getSchemaProperty(context,"attribute_CriticalTask");
    SELECT_CRITICAL_TASK = "attribute[" + ATTRIBUTE_CRITICALTASK + "]";
    String CRITICAL_TASK_FLAG="TRUE";

    // End of addition
    // Get business object id from URL
    String showSel    = emxGetParameter(request, "mx.page.filter");
    String objectId   = emxGetParameter(request, "objectId");
    String jsTreeID   = emxGetParameter(request, "jsTreeID");
    String topId      = emxGetParameter(request, "topId");
    String hideWBS    = emxGetParameter(request, "hideWBS");
    String expanded   = emxGetParameter(request, "expanded");
    String wbsNumber  = emxGetParameter(request, "wbsNumber");
    String timeStamp  = emxGetParameter(request, "timeStamp");
    String[] relationshipIds = emxGetParameterValues(request,"selectedIds");
    String mode       = emxGetParameter(request, "mode");
    String wizType = (String) emxGetParameter(request, "wizType");
    String busId = (String) emxGetParameter(request, "busId");
    String isBaselineView = emxGetParameter(request, "isBaselineView");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String initSource = emxGetParameter(request, "initSource");
    String portalMode     = emxGetParameter(request,"portalMode");

    //------------------------------------------------------------------------
    //Added For Back Button Utility Following Parameters required from request

    String businessGoalId 	= emxGetParameter(request,"businessGoalId");
    String fromProgram		= emxGetParameter(request,"fromProgram");
    String fromAction		= emxGetParameter(request,"fromAction");
    String businessUnitId 	= emxGetParameter(request,"BusinessUnitId");
    String fromBG			= emxGetParameter(request,"fromBG");
    String wbsForm			= emxGetParameter(request,"wbsForm");
    //------------------------------------------------------------------------

    String printerFriendly = emxGetParameter(request,"PrinterFriendly");
    boolean isPrinterFriendly = false;
    if ((printerFriendly != null) && (printerFriendly.equals("true"))) {
      isPrinterFriendly = true;
    }

    boolean isPortal = false;
    if(portalMode != null && "true".equalsIgnoreCase(portalMode)){
      isPortal = true;
    }

  boolean isTimeDisplay = eMatrixDateFormat.isTimeDisplay();
  int dtFormat = (new Integer(dateFormat)).intValue();
  if (dtFormat < 0 && dtFormat > 3 )
  {
  dtFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
  }
  double tzone = (new Double(timeZone)).doubleValue();

    if (isBaselineView == null) { isBaselineView = "false";}

    // make sure mode != null
    if(mode == null){
      mode = "";
    }
    // construct a stringlist for the relationshipIds
    StringList objIdList = new StringList();
    if(relationshipIds != null){
      for(int i = 0; i < relationshipIds.length; i++){
        objIdList.add(relationshipIds[i]);
      }
    }
    String jsTreeIDValue = null;
    String taskPolicy = task.getDefaultPolicy(context);
    String completeState = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Complete");
      String SELECT_DELETED_COMMENTS = "attribute[" + task.ATTRIBUTE_COMMENTS + "]";

      String SELECT_DELETED_DATE = "attribute[" + task.ATTRIBUTE_DATE_DELETED + "]";

    String createState = task.STATE_PROJECT_SPACE_CREATE;
    String projectType = task.TYPE_PROJECT_SPACE;
    String conceptType = task.TYPE_PROJECT_CONCEPT;

    // checks on variables
    if (jsTreeID!=null || !"null".equals(jsTreeID)){
       jsTreeIDValue = jsTreeID;
    }

    if(expanded==null || expanded.equals("null")) {
      expanded = "false";
    } else {
      // set expanded to be opposite
      expanded = expanded.equals("false") ? "true" : "false";
    }

    if(wbsNumber==null || wbsNumber.equals("null")) {
      wbsNumber = "0";
    }

    int recurseLevel = 1;
    if ("false".equals(hideWBS) == false)
    {
      hideWBS = "true";
    }
    else
    {
      recurseLevel = 0;
    }
    if(topId == null || topId.equals("null") || topId.equals("")) {
     topId = objectId;
    }
    if(showSel == null || showSel.equalsIgnoreCase("null") || showSel.equalsIgnoreCase("")) {
      showSel = "";
    } else if(showSel.equalsIgnoreCase("Deleted")) {
      showSel = "deleted";
    } else {
      showSel = "all";
    }

    task.setId(objectId);

    // Retrieve the tasks for the project or task parent
    StringList busSelects = new StringList(20);
    busSelects.add(task.SELECT_ID);
    busSelects.add(task.SELECT_NAME);
    busSelects.add(task.SELECT_OWNER);
    busSelects.add(task.SELECT_TYPE);
    busSelects.add(task.SELECT_DESCRIPTION);
    busSelects.add(task.SELECT_CURRENT);
    busSelects.add(task.SELECT_PERCENT_COMPLETE);
    busSelects.add(task.SELECT_TASK_ESTIMATED_DURATION);
    busSelects.add(task.SELECT_TASK_ESTIMATED_DURATION+".inputunit");
    busSelects.add(task.SELECT_TASK_ESTIMATED_START_DATE);
    busSelects.add(task.SELECT_TASK_ESTIMATED_FINISH_DATE);
    // Added for Critical Task Managment feature in Solution Library
    busSelects.add(SELECT_CRITICAL_TASK);
    // End of addition

    if(!isPortal){
      busSelects.add(task.SELECT_TASK_ACTUAL_DURATION);
    }
    busSelects.add(task.SELECT_TASK_ACTUAL_START_DATE);
    busSelects.add(task.SELECT_TASK_ACTUAL_FINISH_DATE);
    busSelects.add(task.SELECT_PREDECESSOR_IDS);
    busSelects.add(task.SELECT_PREDECESSOR_TYPES);
    if(!isPortal){
      busSelects.add(task.SELECT_TASK_REQUIREMENT);
    }
    busSelects.add(task.SELECT_HAS_SUBTASK);
    busSelects.add(task.SELECT_POLICY);
    busSelects.add(task.SELECT_BASELINE_CURRENT_END_DATE);
    busSelects.add(task.SELECT_PREDECESSOR_LAG_TIMES);
    //[Start Added::Aug 10, 2011:MS9:R212 : IR-016048V6R2012x]
    busSelects.add("from["+DomainConstants.RELATIONSHIP_DEPENDENCY+"].attribute[Lag Time].inputunit"); // DependencyRelationship.SELECT_LAG_TIME);
    //[Start Added::Aug 10, 2011:MS9:R212 : IR-016048V6R2012x]
       
    //add only if needed for the baseline
    if("true".equals(isBaselineView)){
      busSelects.add(task.SELECT_BASELINE_INITIAL_START_DATE);
      busSelects.add(task.SELECT_BASELINE_INITIAL_END_DATE);
      busSelects.add(task.SELECT_BASELINE_CURRENT_START_DATE);
    }

    StringList relSelects = new StringList(1);
    relSelects.add(subtask.SELECT_TASK_WBS);
    boolean retrieve = false;
    //Map wbsIndexMap = null;
    MapList wbsMasterList = null;
    String currLevel = "0";
    int index = 1;
    if(timeStamp==null || timeStamp.equals("") || timeStamp.equals("null"))
    {
      Date time = new Date();
      // create a new timestamp if one doesn't exist
      timeStamp = Long.toString(time.getTime());
      // get the parent information along with user access.
      busSelects.add("current.access[modify]");

      String selectParentWBS = "to[" + task.RELATIONSHIP_SUBTASK + "]." +
                                subtask.SELECT_TASK_WBS;
      busSelects.add(selectParentWBS);

      Map parentList = task.getInfo(context, busSelects);
      // no need to retrieve for each child; just parent
      busSelects.remove("current.access[modify]");

      busSelects.remove(selectParentWBS);
      String parentWBS = (String) parentList.get(selectParentWBS);
      if(parentWBS == null)
      {
        parentWBS = "";
      }
      parentList.remove(selectParentWBS);

      parentList.put(task.SELECT_LEVEL, "0");
      parentList.put(subtask.SELECT_TASK_WBS, parentWBS);
      parentList.put("EXPANDED", "true");
      wbsMasterList = new MapList(1);
      wbsMasterList.add(parentList);
      retrieve = true;
      // Save wbs list for subsequent pages
      session.setAttribute("wbsMasterList" + timeStamp, wbsMasterList);
    }
    else
    {
      // no need to re-store into session as we will update same pointer.
      wbsMasterList = (MapList) session.getAttribute("wbsMasterList" + timeStamp);
      // Get index of the current object
      index = locateTask(wbsMasterList, objectId);
      Map map = (Map) wbsMasterList.get(index);
      currLevel = (String) map.get(task.SELECT_LEVEL);
      map.put("EXPANDED", expanded);
      if (expanded.equals("true"))
      {
        index++;
        int size = wbsMasterList.size();
        //boolean retrieve = false;
        if (size == index)
        {
          retrieve = true;
        }
        else
        {
          Map nextMap = (Map) wbsMasterList.get(index);
          String nextLevel = (String) nextMap.get(task.SELECT_LEVEL);
          if (Integer.parseInt(currLevel) >= Integer.parseInt(nextLevel))
          {
            retrieve = true;
          }
        }
      }
    }
    if (retrieve)
    {
      String relFilter = "";
      if (recurseLevel == 1)
      {
        busSelects.remove(task.SELECT_HAS_SUBTASK);
      }
      // get all the children for the current task
      MapList wbsTasks = null;
      MapList wbsDeletedTasks = null;
      if (showSel.equals("deleted") || showSel.equals("all"))
      {
        StringList deletedRelSelects = new StringList();

        deletedRelSelects.add(SELECT_DELETED_COMMENTS);

        deletedRelSelects.add(SELECT_DELETED_DATE);

        wbsDeletedTasks = task.getDeletedTasks(context, busSelects, deletedRelSelects);

        relFilter = task.RELATIONSHIP_DELETED_SUBTASK;
      }
      if (index > 1 || showSel.equals("") || showSel.equals("all"))
      {
        relFilter += "," + task.RELATIONSHIP_SUBTASK;
        wbsTasks = task.getTasks(context, task, recurseLevel, busSelects, relSelects);
        if (wbsDeletedTasks != null  && "false".equals(expanded))
        {
          wbsTasks.addAll(wbsDeletedTasks);
        }
      }
      else
      {
        wbsTasks = wbsDeletedTasks;
      }
      StringList leafNodes = null;
      if (recurseLevel == 1)
      {
        //get Tasks that don't have structure
       //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
        String cmd = "expand bus $1 terse from rel $2 select $3 where $4 dump $5";
        String whereClause = "from[" + task.RELATIONSHIP_SUBTASK + "] == False";
        String output =  MqlUtil.mqlCommand(context, cmd, task.getObjectId(), relFilter,"bus",whereClause,"|"); 
        //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
        leafNodes = FrameworkUtil.split(output, "\n");
        ListIterator listItr = leafNodes.listIterator();
        while (listItr.hasNext())
        {
          String item = (String) listItr.next();
          StringList itemInfo = FrameworkUtil.split(item, "|");
          String id = (String) itemInfo.get(3);
          listItr.set(id);
        }
      }
      wbsMasterList.addAll(index, wbsTasks);
      String nextLevel = String.valueOf(Integer.parseInt(currLevel) + 1);
      Iterator itr = wbsTasks.iterator();
      while (itr.hasNext())
      {
        Map child = (Map) itr.next();
        if (leafNodes != null)
        {
          String childId = (String) child.get(task.SELECT_ID);
          if (leafNodes.indexOf(childId) == -1 && child.get(SELECT_DELETED_DATE)==null)
          {
            child.put(task.SELECT_HAS_SUBTASK, "TRUE");
          }
          else
          {
            child.put(task.SELECT_HAS_SUBTASK, "FALSE");
          }
        }
        if (recurseLevel == 0)
        {
          child.put("EXPANDED", "true");
        }
        else
        {
          child.put(task.SELECT_LEVEL, nextLevel);
          child.put("EXPANDED", "false");
        }
      }
    }
    Map topLevel = (Map) wbsMasterList.get(0);
    String modifyAccess = (String) topLevel.get("current.access[modify]");
    boolean allowEdit = "TRUE".equalsIgnoreCase(modifyAccess) ? true : false;
    // creating index map of each id for figuring out dependencies
    //Deletermine whether a specific level is expanded or not.
    Map expandLevel = new HashMap(1);
    expandLevel.put("0", "true");
    Map wbsIndexMap = new HashMap(wbsMasterList.size());
    Iterator itr = wbsMasterList.iterator();
    int counter = 0;
    while (itr.hasNext())
    {
      Map map = (Map) itr.next();
      String thisLevel = (String) map.get(task.SELECT_LEVEL);
      String show = "true";
      int level = Integer.parseInt(thisLevel);
      if (level <= 0)
      {
        expanded = "true";
      }
      else
      {
        int parentLevel = level - 1 ;
        String prevLevel = String.valueOf(parentLevel);
        expanded = (String) expandLevel.get(prevLevel);
        if ("true".equals(expanded))
        {
          expanded = (String) map.get("EXPANDED");
        }
        else
        {
          show = "false";
        }
      }
      map.put("show", show);
      expandLevel.put(thisLevel, expanded);
      if (show.equals("true"))
      {
        String id = (String) map.get(task.SELECT_ID);
        wbsIndexMap.put(id, String.valueOf(counter++));
        //wbsIndexMap.put(id, map.get(subtask.SELECT_TASK_WBS));
      }
    }
    // used to format dates
    Date tempDate = new Date();
    java.util.Calendar cal = new java.util.GregorianCalendar((1900+tempDate.getYear()), tempDate.getMonth(), tempDate.getDate());
    Date sysDate = cal.getTime();

    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
    String statusString = ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.ProjectStatus", request.getHeader("Accept-Language"));
    ContextUtil.commitTransaction(context);
    //get the members of the project
    project.setId(topId);
    busSelects.clear();
    busSelects.add(person.SELECT_NAME);
    busSelects.add(person.SELECT_FIRST_NAME);
    busSelects.add(person.SELECT_LAST_NAME);
    MapList membersList = project.getMembers(context, busSelects, null, null, null );

    // the following list of variables are used in the map iterator
    int row = 0;

  StringBuffer exportStringBuffer = new StringBuffer();
  String strDelimiter = ",";

  exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.PhaseTaskName", language) + strDelimiter);
  exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.WBS", language) + strDelimiter);
  exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.TaskType", language) + strDelimiter);
  exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.State", language) + strDelimiter);
  exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.PerComplete", language) + strDelimiter);

  if("false".equals(isBaselineView))
  {
    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.Estimated", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.Duration", language) + strDelimiter);
    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.Estimated", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.StartDate", language) + strDelimiter);
    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.Estimated", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.EndDate", language) + strDelimiter);

    if ("false".equals(isBaselineView) && isPortal==false) {
      exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
  			"emxProgramCentral.Common.Actual", language));
      exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
  			"emxProgramCentral.Common.Duration", language) + strDelimiter);
    }

    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.Actual", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.StartDate", language) + strDelimiter);
    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.Actual", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.EndDate", language) + strDelimiter);
    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.Owner", language) + strDelimiter);

    if ("false".equals(isBaselineView) && isPortal==false) {
      exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
  			"emxProgramCentral.Common.ID", language) + strDelimiter);
      exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
  			"emxProgramCentral.Common.Dependency", language) + strDelimiter);
      if (!mode.equalsIgnoreCase("Wizard")) {
        exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
    			"emxProgramCentral.Common.TaskReq", language));
      }
    }
    exportStringBuffer.append("\n");
  } else {
    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.Estimated", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.StartDate", language) + strDelimiter);
    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.Estimated", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.EndDate", language) + strDelimiter);
    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.Actual", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.StartDate", language) + strDelimiter);
    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.Actual", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.EndDate", language) + strDelimiter);

    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.BaselineInitial", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.StartDate", language) + strDelimiter);
    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.BaselineInitial", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.EndDate", language) + strDelimiter);
    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.BaselineCurrent", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.StartDate", language) + strDelimiter);
    exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.BaselineCurrent", language));
    exportStringBuffer.append(" " + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Common.EndDate", language) + '\n');
  }
  //Added for ECH to support Change Disciplines
  boolean isECHInstalled = com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appVersionEnterpriseChange",false,null,null);
  String messageThereAreNoProjectTasksForThisProject = "";
  if(isECHInstalled){
	  messageThereAreNoProjectTasksForThisProject = EnoviaResourceBundle.getProperty(context, "EnterpriseChange", 
				"emxEnterpriseChange.Common.ThereAreNoProjectTasksForThisProject", language);
	  HashMap paramMap = new HashMap();
      paramMap.put("objectId", busId);
      paramMap.put("wbsMasterList", wbsMasterList);
      //paramMap.put("wizType", wizType);
      String[] methodargs = JPO.packArgs(paramMap);
      wbsMasterList = (MapList)JPO.invoke(context, "emxEnterpriseChangeBase", new String[0], "filterWBSProjectListWithParentForChangeDisciplines", methodargs, MapList.class);
  }
  //End Added for ECH to support Change Disciplines

%>
      <%@include file = "../emxUICommonHeaderEndInclude.inc" %>


<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><framework:ifExpr expr="<%=toExcel == false%>">
      <form name="EditTasks" method="post">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	  
        <input type="hidden" name="p_button" value="" />
        <input type="hidden" name="wizType" value="<xss:encodeForHTMLAttribute><%=wizType%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="pageName" value="WizardWBS" />
        <input type="hidden" name="taskID" value="" />
        <input type="hidden" name="busID" value="" />
        <input type="hidden" name="level" value="" />
        <input type="hidden" name="requirement" value="" />
        <input type="hidden" name="state" value="" />
        <input type="hidden" name="selectedTaskParentState" value="" />
        <input type="hidden" name="topId" value="<xss:encodeForHTMLAttribute><%=topId%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="hideWBS" value="<xss:encodeForHTMLAttribute><%=hideWBS%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="sessionTimeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="isActive" value="false" />
        <input type="hidden" name="expanded" value="" />
        <input type="hidden" name="mode" value="<xss:encodeForHTMLAttribute><%=mode%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="busId" value="<%=busId%>" />
        <input type="hidden" name="isBaselineView" value="<xss:encodeForHTMLAttribute><%=isBaselineView%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />


        <table border="0" width="100%">
          <tr>
            <td><%-- Modified: Aug 10, 2011:MS9:R212 : IR-016048V6R2012x --%>
              <table border="0" width="100%" class="list"> 
                <%-- End: Aug 10, 2011:MS9:R212 : IR-016048V6R2012x --%>
               <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("wizard")%>'>

                <framework:ifExpr expr='<%= "false".equals(isBaselineView)%>'>
                    <th class="groupheader" colspan="1">&nbsp;</th>
                    <th class="groupheader" colspan="5">&nbsp;</th>
                    <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                    <th class="groupheader" valign="bottom" colspan="3">
                      <table border="0" cellpadding="0" cellspacing="0" width="100%">
                        <tr class="rule" height="1">
                          <td colspan="6" height="1"><img src="../common/images/utilSpacer.gif" height="1" width="1" border="0" /></td>
                        </tr>
                      </table>
                    </th>
                    <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                    <th class="groupheader" valign="bottom" colspan="3">
                      <table border="0" cellpadding="0" cellspacing="0" width="100%">
                        <tr class="rule" height="1">
                          <td colspan="6" height="1"><img src="../common/images/utilSpacer.gif" height="1" width="1" border="0" /></td>
                        </tr>
                      </table>
                    </th>
                    <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                    <th class="groupheader" colspan="5">&nbsp;</th>
                </framework:ifExpr>
                <framework:ifExpr expr='<%= "true".equals(isBaselineView)%>'>
                    <th class="groupheader" colspan="5">&nbsp;</th>
                    <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                    <th class="groupheader" valign="bottom" colspan="2">
                      <table border="0" cellpadding="0" cellspacing="0" width="100%">
                        <tr class="rule" height="1">
                          <td colspan="6" height="1"><img src="../common/images/utilSpacer.gif" height="1" width="1" border="0" /></td>
                        </tr>
                      </table>
                    </th>
                    <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                    <th class="groupheader" valign="bottom" colspan="2">
                      <table border="0" cellpadding="0" cellspacing="0" width="100%">
                        <tr class="rule" height="1">
                          <td colspan="6" height="1"><img src="../common/images/utilSpacer.gif" height="1" width="1" border="0" /></td>
                        </tr>
                      </table>
                    </th>
                    <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                    <th class="groupheader" valign="bottom" colspan="2">
                      <table border="0" cellpadding="0" cellspacing="0" width="100%">
                        <tr class="rule" height="1">
                          <td colspan="6" height="1"><img src="../common/images/utilSpacer.gif" height="1" width="1" border="0" /></td>
                        </tr>
                      </table>
                    </th>
                    <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                    <th class="groupheader" valign="bottom" colspan="2">
                      <table border="0" cellpadding="0" cellspacing="0" width="100%">
                        <tr class="rule" height="1">
                          <td colspan="6" height="1"><img src="../common/images/utilSpacer.gif" height="1" width="1" border="0" /></td>
                        </tr>
                      </table>
                    </th>
                </framework:ifExpr>

               <tr>
                <framework:ifExpr expr='<%= "false".equals(isBaselineView)%>'>
                    <th class="groupheader" colspan="1">&nbsp;</th>
                    <th class="groupheader" colspan="5">&nbsp;</th>

                  <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                  <th class="groupheader" colspan="3" style="text-align:center">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.Estimated</framework:i18n>
                  </th>
                  <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                  <th class="groupheader" colspan="3" style="text-align:center" class="groupheader">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.Actual</framework:i18n>
                  </th>
                  <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                  <th class="groupheader" colspan="5">&nbsp;</th>
                </framework:ifExpr>

                <framework:ifExpr expr='<%= "true".equals(isBaselineView)%>'>
                  <th class="groupheader" colspan="5">&nbsp;</th>
                  <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                  <th class="groupheader" colspan="2" style="text-align:center">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.Estimated</framework:i18n>
                  </th>
                  <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                  <th class="groupheader" colspan="2" style="text-align:center">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.Actual</framework:i18n>
                  </th>
                  <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                <th class="groupheader" colspan="2" style="text-align:center">
                  <framework:i18n localize="i18nId">emxProgramCentral.Common.BaselineInitial</framework:i18n>
                </th>
                <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                <th class="groupheader" colspan="2" style="text-align:center">
                  <framework:i18n localize="i18nId">emxProgramCentral.Common.BaselineCurrent</framework:i18n>
                </th>
                </framework:ifExpr>

               </tr>
              </framework:ifExpr>
                <tr>
                  <framework:ifExpr expr='<%=mode.equalsIgnoreCase("wizard")%>'>
                    <th width="5%" align="center">
                      &nbsp;
                    </th>
                  </framework:ifExpr>
                  <th width="10%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.PhaseTaskName</framework:i18n>
                  </th>
                  <th width="1%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.WBS</framework:i18n>
                  </th>
                  <th width="3%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.TaskType</framework:i18n>
                  </th>
                <framework:ifExpr expr='<%=mode.equalsIgnoreCase("Wizard")%>'>
                  <th width="30%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.Description</framework:i18n>
                  </th>
                </framework:ifExpr>
                <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("Wizard")%>'>
                    <th width="5%" nowrap="nowrap" style="text-align:center">
                    <%-- Commenting for PMC 10-6-SP2 Starts --%>
                     <%-- <img src="../common/images/iconStatus.gif" border="0" alt="<%=statusString%>" /> --%>
                    <%-- Commenting for PMC 10-6-SP2 Ends --%>

                    <%-- Modification for PMC 10-6-SP2 Starts --%>
                    <%-- Added 'title' keyword so that tooltip functionality works for FireFox Browser too --%>
                    <img src="../common/images/iconStatus.gif" border="0" alt="<%=statusString%>" title="<%=statusString%>" />
                    <%-- Modification for PMC 10-6-SP2 Ends --%>
                    </th>
                  <th width="3%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.State</framework:i18n>
                  </th>
                </framework:ifExpr>
                <framework:ifExpr expr='<%= "false".equals(isBaselineView)%>'>
                  <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("Wizard")%>'>
                    <th width="3%" nowrap="nowrap">
                      <framework:i18n localize="i18nId">emxProgramCentral.Common.PerComplete</framework:i18n>
                    </th>
                  </framework:ifExpr>
                  <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("Wizard")%>'>
                    <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                  </framework:ifExpr>
                  <th width="3%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.Duration</framework:i18n>
                  </th>
                </framework:ifExpr>
                <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("Wizard")%>'>
                  <framework:ifExpr expr='<%= "true".equals(isBaselineView)%>'>
                    <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                  </framework:ifExpr>
                  <th width="5%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.StartDate</framework:i18n>
                  </th>
                  <th width="5%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.EndDate</framework:i18n>
                  </th>
                  <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                  <framework:ifExpr expr='<%= "false".equals(isBaselineView)&& isPortal == false%>'>
                    <th width="3%" nowrap="nowrap">
                      <framework:i18n localize="i18nId">emxProgramCentral.Common.Duration</framework:i18n>
                    </th>
                  </framework:ifExpr>
                  <th width="5%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.StartDate</framework:i18n>
                  </th>
                  <th width="5%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.EndDate</framework:i18n>
                  </th>
                </framework:ifExpr>
                <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("Wizard")%>'>
                  <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                </framework:ifExpr>
                <framework:ifExpr expr='<%= "true".equals(isBaselineView)%>'>
                  <th width="5%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.StartDate</framework:i18n>
                  </th>
                  <th width="5%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.EndDate</framework:i18n>
                  </th>
                  <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                  <th width="5%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.StartDate</framework:i18n>
                  </th>
                  <th width="5%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.EndDate</framework:i18n>
                  </th>
                </framework:ifExpr>
                <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("Wizard")%>'>
                  <framework:ifExpr expr='<%= "false".equals(isBaselineView)%>'>
                    <th width="2%" nowrap="nowrap">
                      <framework:i18n localize="i18nId">emxProgramCentral.Common.Owner</framework:i18n>
                    </th>
                  </framework:ifExpr>
                </framework:ifExpr>
                <framework:ifExpr expr='<%= "false".equals(isBaselineView) && isPortal == false%>'>
                  <th width="1%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.ID</framework:i18n>
                  </th>
                  <th width="2%" nowrap="nowrap">
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.Dependency</framework:i18n>
                  </th>
                </framework:ifExpr>
                <framework:ifExpr expr='<%= "false".equals(isBaselineView)%>'>
                  <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("Wizard")%>'>
                    <framework:ifExpr expr='<%=isPortal==false%>'>
                      <th width="2%" nowrap="nowrap">
                        <framework:i18n localize="i18nId">emxProgramCentral.Common.TaskReq</framework:i18n>
                      </th>
                      <th width="2%" nowrap="nowrap" style="text-align:center">
                        &nbsp;
                          <%-- Commenting for PMC 10-6-SP2 Starts --%>
                          <%-- <img src="../common/images/iconActionEdit.gif" border="0" alt="<framework:i18n localize="i18nId">emxProgramCentral.Common.Edit</framework:i18n>" /> --%>
                          <%-- Commenting for PMC 10-6-SP2 Ends --%>

                          <%-- Modification for PMC 10-6-SP2 Starts --%>
                          <img src="../common/images/iconActionEdit.gif" border="0" alt="<framework:i18n localize="i18nId">emxProgramCentral.Common.Edit</framework:i18n>" title="<framework:i18n localize="i18nId">emxProgramCentral.Common.Edit</framework:i18n>" />
                          <%-- Modification for PMC 10-6-SP2 Ends --%>
                      </th>
                    </framework:ifExpr>
                  </framework:ifExpr>
                </framework:ifExpr>
              </tr>
            </framework:ifExpr>

              <framework:mapListItr mapList="<%=wbsMasterList%>">
<%
    // truncate the Name field to ensure it always displays evenly.
    // the icon image ALT will have the full name

    String taskName = XSSUtil.encodeURLForServer(context,(String) map.get(task.SELECT_NAME));
	/*
		add by zs 5/3/2017 
	*/
	String pageName           = emxGetParameter(request,"pageName");
    if(mode.equalsIgnoreCase("Wizard") && pageName.equals("WizardClone")){
    	taskName =(String) map.get(task.SELECT_NAME);
    }
   
    /*if (taskName.length() > 30) {
      taskName = taskName.substring(0,30);
    }*/
    String newURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + XSSUtil.encodeForURL(context, (String)map.get(task.SELECT_ID));
    newURL += "&mode=replace&jsTreeID=" + XSSUtil.encodeForURL(context, jsTreeID) + "&AppendParameters=true";
    newURL += "&wbsNumber=" + map.get(subtask.SELECT_TASK_WBS) + "&reloadAfterChange=true";
   
    if(showSel.equals("")){
       showSel="null";
    }
    String nextURL = "javascript:treeAction('"  +XSSUtil.encodeURLForServer(context,(String)map.get(task.SELECT_ID))+  "','"  +XSSUtil.encodeURLForServer(context,showSel)+  "','"  +jsTreeID+  "','"  +XSSUtil.encodeURLForServer(context,(String)map.get("EXPANDED"))+  "','" +timeStamp+ "','" +topId+ "')";
    // used for the edit icon
    String url = "emxProgramCentralWBSEditEstDateDialogFS.jsp?objectId=";
    url += XSSUtil.encodeURLForServer(context,(String)map.get(task.SELECT_ID));
    // determine dependencies
    String preString = "";
    Object listPreds = (Object) map.get(task.SELECT_PREDECESSOR_IDS);
    Object listTypes = (Object) map.get(task.SELECT_PREDECESSOR_TYPES);
    Object listLagTimes = (Object) map.get(task.SELECT_PREDECESSOR_LAG_TIMES);
    String lagTime = "";

    //[Start Modified::Aug 10, 2011:MS9:R212 : IR-016048V6R2012x]
    Object listLagTimesUnit = (Object) map.get("from["+DomainConstants.RELATIONSHIP_DEPENDENCY+"].attribute[Lag Time].inputunit");
    Map _unitsLabel = ProgramCentralUtil.getUnits(context,ProgramCentralConstants.ATTRIBUTE_LAG_TIME);
    
    if (listPreds == null) {
      preString = "";
    } else if (listPreds instanceof String){
      String preId = (String)wbsIndexMap.get((String) listPreds);
      if (preId == null) {
        preString = "*";
      } else {
        lagTime = (String) listLagTimes;
        String strLagTimesUnit = (String)listLagTimesUnit; 
        Unit unit = (Unit) _unitsLabel.get(strLagTimesUnit);
        if(lagTime.charAt(0) != '-' && !lagTime.equals("0"))
        {
        	if (unit != null)
            {
        		lagTime = unit.denormalize(lagTime) + " " + strLagTimesUnit;
            } 
          lagTime = "+" + lagTime;
        }
        else if(lagTime.equals("0")) {
        	if (unit != null)
            {
                lagTime = unit.denormalize(lagTime) + " " + strLagTimesUnit;
            } 
        }
        preString = preId + ":" + (String) listTypes + lagTime;
      }
    } else if (listPreds instanceof StringList) {
      StringList sl = (StringList) listPreds;
      StringList st = (StringList) listTypes;
      StringList slag = (StringList) listLagTimes;
      StringList slagUnit = (StringList) listLagTimesUnit;
      boolean foundExternal = false;
      for (int i =0; i<sl.size(); i++) {
        String preId = (String)wbsIndexMap.get((String) sl.elementAt(i));
        if (preId == null) {
          foundExternal = true;
        } else {
            lagTime = (String) slag.elementAt(i);
            String strLagTimesUnit = (String) slagUnit.elementAt(i);
            Unit unit = (Unit) _unitsLabel.get(strLagTimesUnit); 
            if(lagTime.charAt(0) != '-' && !lagTime.equals("0"))
            {
            	if (unit != null)
                {
                    lagTime = unit.denormalize(lagTime) + " " + strLagTimesUnit;
                }
              lagTime = "+" + lagTime;
            }
            else if(lagTime.equals("0")) {
            	if (unit != null)
                {
                    lagTime = unit.denormalize(lagTime) + " " + strLagTimesUnit;
                }
            }
            preString = preString + preId + ":" + (String) st.elementAt(i) + lagTime +", ";
        }
      }
      if (foundExternal) {
        preString = preString + "*";
      }
    }
    //[End Added::Aug 10, 2011:MS9:R212 : IR-016048V6R2012x]
    map.put ("PREDECESSORS", preString);
    boolean show = "true".equals((String) map.get("show")) ? true : false;
    expanded = (String) map.get("EXPANDED");
    String thisLevel = (String) map.get(task.SELECT_LEVEL);
    int level = Integer.parseInt(thisLevel);
    // determine if this is a task or something else
    String thisObjectType = (String) map.get(task.SELECT_TYPE);

    //determine which gif should be display for status
    String statusGif = "";
    Date estFinishDate = sdf.parse((String)map.get(task.SELECT_TASK_ESTIMATED_FINISH_DATE));
    Date baselineCurrentEndDate = null;
    String baselineCurrentEndDateString = (String)map.get(task.SELECT_BASELINE_CURRENT_END_DATE);
    if(!"".equals(baselineCurrentEndDateString)){
      baselineCurrentEndDate = sdf.parse((String)map.get(task.SELECT_BASELINE_CURRENT_END_DATE));
    }
    long daysRemaining;
    if(null == baselineCurrentEndDate){
      daysRemaining = (long) task.computeDuration(sysDate,estFinishDate);
    } else {
      daysRemaining = (long) task.computeDuration(sysDate,baselineCurrentEndDate);
    }
    //set the yellow red threshold from the properties file
    i18nNow i18nnow = new i18nNow();
    int yellowRedThreshold = Integer.parseInt(EnoviaResourceBundle.getProperty(context, "eServiceApplicationProgramCentral.SlipThresholdYellowRed"));
    if(null == baselineCurrentEndDate){
      if(map.get(task.SELECT_CURRENT).equals(completeState) ||
        ((String)map.get(task.SELECT_PERCENT_COMPLETE)).equals("100")) {
        statusGif = "<img src=\"../common/images/iconStatusGreen.gif\" border=\"0\" alt=\"";
        statusGif += ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.OnTime",request.getHeader("Accept-Language"))+"\">";
      } else if(mxType.isOfParentType(context,thisObjectType,projectType) && !map.get(task.SELECT_CURRENT).equals(project.STATE_PROJECT_SPACE_COMPLETE) && sysDate.after(estFinishDate)) {
        statusGif = "<img src=\"../common/images/iconStatusRed.gif\" border=\"0\" alt=\"";
        statusGif += ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Late",request.getHeader("Accept-Language"))+"\">";
      } else if(!mxType.isOfParentType(context,thisObjectType,projectType) && !map.get(task.SELECT_CURRENT).equals(completeState) && sysDate.after(estFinishDate)) {
        statusGif = "<img src=\"../common/images/iconStatusRed.gif\" border=\"0\" alt=\"";
        statusGif += ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Late",request.getHeader("Accept-Language"))+"\">";
      } else if(mxType.isOfParentType(context,thisObjectType,projectType) && !map.get(task.SELECT_CURRENT).equals(project.STATE_PROJECT_SPACE_COMPLETE) && (daysRemaining <= yellowRedThreshold)) {
        statusGif = "<img src=\"../common/images/iconStatusYellow.gif\" border=\"0\" alt=\"";
        statusGif += ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Legend.BehindSchedule",request.getHeader("Accept-Language"))+"\">";
      } else if(!mxType.isOfParentType(context,thisObjectType,projectType) && !map.get(task.SELECT_CURRENT).equals(completeState) && (daysRemaining <= yellowRedThreshold)) {
        statusGif = "<img src=\"../common/images/iconStatusYellow.gif\" border=\"0\" alt=\"";
        statusGif += ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Legend.BehindSchedule",request.getHeader("Accept-Language"))+"\">";
      } else {
        statusGif = "&nbsp;";
      }
    } else {
      if(map.get(task.SELECT_CURRENT).equals(completeState) ||
        ((String)map.get(task.SELECT_PERCENT_COMPLETE)).equals("100")) {
        statusGif = "<img src=\"../common/images/iconStatusGreen.gif\" border=\"0\" alt=\"";
        statusGif += ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.OnTime",request.getHeader("Accept-Language"))+"\">";
      } else if(mxType.isOfParentType(context,thisObjectType,projectType) && !map.get(task.SELECT_CURRENT).equals(project.STATE_PROJECT_SPACE_COMPLETE) && sysDate.after(baselineCurrentEndDate)) {
        statusGif = "<img src=\"../common/images/iconStatusRed.gif\" border=\"0\" alt=\"";
        statusGif += ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Late",request.getHeader("Accept-Language"))+"\">";
      } else if(!mxType.isOfParentType(context,thisObjectType,projectType) && !map.get(task.SELECT_CURRENT).equals(completeState) && sysDate.after(baselineCurrentEndDate)) {
        statusGif = "<img src=\"../common/images/iconStatusRed.gif\" border=\"0\" alt=\"";
        statusGif += ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Late",request.getHeader("Accept-Language"))+"\">";
      } else if(mxType.isOfParentType(context,thisObjectType,projectType) && !map.get(task.SELECT_CURRENT).equals(project.STATE_PROJECT_SPACE_COMPLETE) && (daysRemaining <= yellowRedThreshold)) {
        statusGif = "<img src=\"../common/images/iconStatusYellow.gif\" border=\"0\" alt=\"";
        statusGif += ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Legend.BehindSchedule",request.getHeader("Accept-Language"))+"\">";
      } else if(!mxType.isOfParentType(context,thisObjectType,projectType) && !map.get(task.SELECT_CURRENT).equals(completeState) && (daysRemaining <= yellowRedThreshold)) {
        statusGif = "<img src=\"../common/images/iconStatusYellow.gif\" border=\"0\" alt=\"";
        statusGif += ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.Legend.BehindSchedule",request.getHeader("Accept-Language"))+"\">";
      } else {
        statusGif = "&nbsp;";
      }
    } //ends BaselineCurrent if else

    boolean isActive = true;
    if(task.RELATIONSHIP_DELETED_SUBTASK.equals((String)map.get(task.KEY_RELATIONSHIP)))
    {
      isActive = false;
    }
    //get the Last and First name of the project owner
    String ownerName = PersonUtil.getFullName(context, (String)map.get(task.SELECT_OWNER));

    String checkboxValue = (String) map.get(subtask.SELECT_TASK_WBS)+"|"+(String) map.get(task.SELECT_ID);

    //Baseline Information
    String baselineInitialStartDateStr = (String) map.get(task.SELECT_BASELINE_INITIAL_START_DATE);
    String baselineInitialEndDateStr = (String) map.get(task.SELECT_BASELINE_INITIAL_END_DATE);
    String baselineCurrentStartDateStr = (String) map.get(task.SELECT_BASELINE_CURRENT_START_DATE);
    String baselineCurrentEndDateStr = (String) map.get(task.SELECT_BASELINE_CURRENT_END_DATE);
    String WBSNumber = (String) map.get(subtask.SELECT_TASK_WBS);
    if(null == baselineInitialStartDateStr) {baselineInitialStartDateStr = "";}
    if(null == baselineInitialEndDateStr) {baselineInitialEndDateStr = "";}
    if(null == baselineCurrentStartDateStr) {baselineCurrentStartDateStr = "";}
    if(null == baselineCurrentEndDateStr) {baselineCurrentEndDateStr = "";}
    if(null == WBSNumber){WBSNumber = "";}

  if(toExcel)
  {
    exportStringBuffer.append((String)map.get(task.SELECT_NAME) + strDelimiter);
    exportStringBuffer.append(WBSNumber + strDelimiter);
    exportStringBuffer.append(i18nNow.getTypeI18NString(thisObjectType, language) + strDelimiter);
    exportStringBuffer.append(i18nNow.getStateI18NString((String)map.get(task.SELECT_POLICY),(String)map.get(task.SELECT_CURRENT),language) + strDelimiter);
    exportStringBuffer.append((String)map.get(task.SELECT_PERCENT_COMPLETE) + strDelimiter);

    String tempdate = "";
    if("false".equals(isBaselineView))
    {
      exportStringBuffer.append((String)map.get(task.SELECT_TASK_ESTIMATED_DURATION) + strDelimiter);

      tempdate = eMatrixDateFormat.getFormattedDisplayDateTime((String)map.get(task.SELECT_TASK_ESTIMATED_START_DATE), isTimeDisplay, dtFormat, tzone, request.getLocale());
      tempdate = tempdate.replace(',', ' ');
      exportStringBuffer.append(tempdate + strDelimiter);

      tempdate = eMatrixDateFormat.getFormattedDisplayDateTime((String)map.get(task.SELECT_TASK_ESTIMATED_FINISH_DATE), isTimeDisplay, dtFormat, tzone, request.getLocale());
      tempdate = tempdate.replace(',', ' ');
      exportStringBuffer.append(tempdate + strDelimiter);

      if ("false".equals(isBaselineView) && isPortal==false) {
        exportStringBuffer.append((String)map.get(task.SELECT_TASK_ACTUAL_DURATION) + strDelimiter);
      }

      tempdate = eMatrixDateFormat.getFormattedDisplayDateTime((String)map.get(task.SELECT_TASK_ACTUAL_START_DATE), isTimeDisplay, dtFormat, tzone, request.getLocale());
      tempdate = tempdate.replace(',', ' ');
      exportStringBuffer.append(tempdate + strDelimiter);

      tempdate = eMatrixDateFormat.getFormattedDisplayDateTime((String)map.get(task.SELECT_TASK_ACTUAL_FINISH_DATE), isTimeDisplay, dtFormat, tzone, request.getLocale());
      tempdate = tempdate.replace(',', ' ');
      exportStringBuffer.append(tempdate + strDelimiter);

      String excelOwner = ownerName.replace(',' , ' ');
      exportStringBuffer.append(excelOwner + strDelimiter);

      if ("false".equals(isBaselineView) && isPortal==false) {
        exportStringBuffer.append(row + strDelimiter);
        exportStringBuffer.append((String)map.get("PREDECESSORS") + strDelimiter);

        if (!mode.equalsIgnoreCase("Wizard")) {
          String taskReq = (String)map.get(task.SELECT_TASK_REQUIREMENT);
          if(mxType.isOfParentType(context,thisObjectType,projectType) || thisObjectType.equals(conceptType))
          {
          }
          else
          {
            if(!"Mandatory".equals(taskReq))
            {
              exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
          			"emxProgramCentral.Common.Optional", language));
            }
            else
            {
              exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
          			"emxProgramCentral.Common.Mandatory", language));
            }
          }
        }
      }
      exportStringBuffer.append('\n');
      row++;
    } else
    {
      tempdate = eMatrixDateFormat.getFormattedDisplayDateTime((String)map.get(task.SELECT_TASK_ESTIMATED_START_DATE), isTimeDisplay, dtFormat, tzone, request.getLocale());
      tempdate = tempdate.replace(',', ' ');
      exportStringBuffer.append(tempdate + strDelimiter);

      tempdate = eMatrixDateFormat.getFormattedDisplayDateTime((String)map.get(task.SELECT_TASK_ESTIMATED_FINISH_DATE), isTimeDisplay, dtFormat, tzone, request.getLocale());
      tempdate = tempdate.replace(',', ' ');
      exportStringBuffer.append(tempdate + strDelimiter);

      tempdate = eMatrixDateFormat.getFormattedDisplayDateTime((String)map.get(task.SELECT_TASK_ACTUAL_START_DATE), isTimeDisplay, dtFormat, tzone, request.getLocale());
      tempdate = tempdate.replace(',', ' ');
      exportStringBuffer.append(tempdate + strDelimiter);

      tempdate = eMatrixDateFormat.getFormattedDisplayDateTime((String)map.get(task.SELECT_TASK_ACTUAL_FINISH_DATE), isTimeDisplay, dtFormat, tzone, request.getLocale());
      tempdate = tempdate.replace(',', ' ');
      exportStringBuffer.append(tempdate + strDelimiter);

      tempdate = eMatrixDateFormat.getFormattedDisplayDateTime(baselineInitialStartDateStr, isTimeDisplay, dtFormat, tzone, request.getLocale());
      tempdate = tempdate.replace(',', ' ');
      exportStringBuffer.append(tempdate + strDelimiter);


      tempdate = eMatrixDateFormat.getFormattedDisplayDateTime(baselineInitialEndDateStr, isTimeDisplay, dtFormat, tzone, request.getLocale());
      tempdate = tempdate.replace(',', ' ');
      exportStringBuffer.append(tempdate + strDelimiter);

      tempdate = eMatrixDateFormat.getFormattedDisplayDateTime(baselineCurrentStartDateStr, isTimeDisplay, dtFormat, tzone, request.getLocale());
      tempdate = tempdate.replace(',', ' ');
      exportStringBuffer.append(tempdate + strDelimiter);

      tempdate = eMatrixDateFormat.getFormattedDisplayDateTime(baselineCurrentEndDateStr, isTimeDisplay, dtFormat, tzone, request.getLocale());
      tempdate = tempdate.replace(',', ' ');
      exportStringBuffer.append(tempdate + '\n');
    }
  }
%>

<framework:ifExpr expr="<%=toExcel == false%>">
                <framework:ifExpr expr='<%= show %>'>
                  <tr class='<framework:swap id="1"/>'>

               <%--XSSOK --%>  
                    <framework:ifExpr expr='<%=(mode.equalsIgnoreCase("wizard"))%>'>
                      <framework:ifExpr expr='<%=(row>0)%>'>
                        <td width="5%" nowrap="nowrap" align="center">
                            <input type="checkbox" name="selectedIds" value="<%=XSSUtil.encodeForHTMLAttribute(context, checkboxValue)%>" <%if(objIdList.contains(checkboxValue)) out.print("CHECKED");%> />
                        </td>
                      </framework:ifExpr>

                      <framework:ifExpr expr='<%=(row==0)%>'>
                        <td width="5%" nowrap="nowrap" align="center">
                          &nbsp;
                        </td>
                      </framework:ifExpr>
                    </framework:ifExpr>

                    <td width="10%" nowrap="nowrap">
                      <framework:ifExpr expr="<%= level >= 1 %>">
                          <img src="../common/images/utilSpacer.gif" height="5" width="<%= (level-1)*10 %>" border="0" />
                  <%--XSSOK --%> 
                        <framework:ifExpr expr='<%="TRUE".equalsIgnoreCase((String)map.get(task.SELECT_HAS_SUBTASK))%>'>
                      <%--XSSOK --%> 
                          <framework:ifExpr expr='<%="true".equals(expanded)%>'>
                         <%--XSSOK --%> 
                              <a href="<%=nextURL%>">
                                <img src="../common/images/utilTreeMinus.gif" border="0" alt="" /></a>
                          </framework:ifExpr>
                        <%--XSSOK --%>
                          <framework:ifExpr expr='<%="false".equals(expanded)%>'>
                           <%--XSSOK --%> 
                              <a href="<%=nextURL%>">
                                <img src="../common/images/utilTreePlus.gif" border="0" alt="" /></a>
                          </framework:ifExpr>
                        </framework:ifExpr>
                       <%--XSSOK --%> 
                        <framework:ifExpr expr='<%="FALSE".equalsIgnoreCase((String)map.get(task.SELECT_HAS_SUBTASK)) && level!=0 %>'>
                            <img src="../common/images/utilTreeLineLast.gif" border="0" alt="" />
                        </framework:ifExpr>
                      </framework:ifExpr>
                      <!--- Added for Critical Task Managment feature in Solution Library -->
                   <%--XSSOK --%>  
                      <framework:ifExpr expr='<%=!mxType.isOfParentType(context,thisObjectType,projectType) && !thisObjectType.equals(conceptType) && "TRUE".equals(map.get(SELECT_CRITICAL_TASK)) && !map.get(task.SELECT_CURRENT).equals(completeState)%>'>
                       <%--XSSOK --%>  
                         <img src="../common/images/iconSmallTask.gif" border="0" /><a href="javascript:showDetailsPopup('<%=newURL%>')"><font color="red"><b><%=taskName%></b></a>&nbsp;
                      </framework:ifExpr>

                   <%--XSSOK --%>  
                      <framework:ifExpr expr='<%=!mxType.isOfParentType(context,thisObjectType,projectType) && !thisObjectType.equals(conceptType) && "FALSE".equals(map.get(SELECT_CRITICAL_TASK))%>'>
                     <%--XSSOK --%> 
                         <img src="../common/images/iconSmallTask.gif" border="0" /><a href="javascript:showDetailsPopup('<%=newURL%>')"><%=taskName%></a>&nbsp;
                      </framework:ifExpr>

                  <%--XSSOK --%> 
                      <framework:ifExpr expr='<%=!mxType.isOfParentType(context,thisObjectType,projectType) && !thisObjectType.equals(conceptType) && "TRUE".equals(map.get(SELECT_CRITICAL_TASK)) && map.get(task.SELECT_CURRENT).equals(completeState)%>'>
                     <%--XSSOK --%>  
                        <img src="../common/images/iconSmallTask.gif" border="0" /><a href="javascript:showDetailsPopup('<%=newURL%>')"><%=taskName%></a>&nbsp;
                      </framework:ifExpr>
                      <!--- End Of addition --->
                 <%--XSSOK --%> 
                      <framework:ifExpr expr='<%=thisObjectType.equals(conceptType)%>'>
                         <%-- Commenting for PMC 10-6-SP2 Starts --%>
                   <%--XSSOK --%>  
                         <%-- <img src="../common/images/iconSmallProjectConcept.gif" border="0" alt="<%= map.get(task.SELECT_NAME) %>" /> --%>
                         <%-- Commenting for PMC 10-6-SP2 Ends --%>

                         <%-- Modification for PMC 10-6-SP2 Starts --%>
                         <%-- Added 'title' keyword so that tooltip functionality works for FireFox Browser too --%>
                         <img src="../common/images/iconSmallProjectConcept.gif" border="0" alt="<%= XSSUtil.encodeForHTMLAttribute(context,(String)map.get(task.SELECT_NAME)) %>" title="<%= XSSUtil.encodeForHTMLAttribute(context,(String)map.get(task.SELECT_NAME)) %>" />
                         <%-- Modification for PMC 10-6-SP2 Ends --%>
             <%--XSSOK --%>
                         <a href="javascript:showDetailsPopup('<%=newURL%>')"><%=taskName%></a>&nbsp;                      </framework:ifExpr>
                   <%--XSSOK --%>  
                      <framework:ifExpr expr='<%=mxType.isOfParentType(context,thisObjectType,projectType)%>'>
                         <%-- Commenting for PMC 10-6-SP2 Starts --%>
                  <%--XSSOK --%> 
                         <%-- <img src="../common/images/iconSmallProject.gif" border="0" alt="<%= map.get(task.SELECT_NAME) %>" /> --%>
                         <%-- Commenting for PMC 10-6-SP2 Ends --%>

                         <%-- Modification for PMC 10-6-SP2 Starts --%>
                         <%-- Added 'title' keyword so that tooltip functionality works for FireFox Browser too --%>
                         <img src="../common/images/iconSmallProject.gif" border="0" alt="<%= XSSUtil.encodeForHTMLAttribute(context,(String)map.get(task.SELECT_NAME)) %>" title="<%=XSSUtil.encodeForHTMLAttribute(context,(String)map.get(task.SELECT_NAME)) %>" />
                         <%-- Modification for PMC 10-6-SP2 Ends --%>
                     <%--XSSOK --%>
                         <a href="javascript:showDetailsPopup('<%=newURL%>')"><%=taskName%></a>&nbsp;
                      </framework:ifExpr>
                    </td>
                    <td <%= isActive ? "" : "class=\"requiredNotice\"" %> width="1%" align="left"><%=XSSUtil.encodeForHTML(context,WBSNumber)%>&nbsp;</td>
                    <td <%= isActive ? "" : "class=\"requiredNotice\"" %> width="3%" nowrap="nowrap">
                      <%= i18nNow.getTypeI18NString(thisObjectType, language)%>
                      &nbsp;
                    </td>
          <%--XSSOK --%>  
                      <framework:ifExpr expr='<%=mode.equalsIgnoreCase("Wizard")%>'>
                        <td width="30%" nowrap="nowrap">
                          <%=XSSUtil.encodeForHTML(context,(String) map.get(task.SELECT_DESCRIPTION))%>
                        </td>
                      </framework:ifExpr>
                  <%--XSSOK --%>  
                    <framework:ifExpr expr="<%=isActive%>">
                    <%--XSSOK --%> 
                      <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("Wizard")%>'>
                          <td nowrap="nowrap" align="center"><%=XSSUtil.encodeForHTML(context,statusGif)%>&nbsp;</td>
                    <%--XSSOK --%> 
                      <framework:ifExpr expr="<%=map.get(task.SELECT_CURRENT).equals(completeState)%>">
                        <td width="3%" nowrap="nowrap">
                          <%= i18nNow.getStateI18NString((String)map.get(task.SELECT_POLICY),(String)map.get(task.SELECT_CURRENT),language)%>
                          &nbsp;
                        </td>
                      </framework:ifExpr>
    <%--XSSOK--%>
                  <framework:ifExpr expr="<%= ! map.get(task.SELECT_CURRENT).equals(completeState) %>">
                        <td width="3%" nowrap="nowrap">
                          &nbsp;
                          <%= i18nNow.getStateI18NString((String)map.get(task.SELECT_POLICY),(String)map.get(task.SELECT_CURRENT),language)%>
                          &nbsp;
                        </td>
                      </framework:ifExpr>
                      </framework:ifExpr>
                  <%--XSSOK --%> 
                      <framework:ifExpr expr='<%= "false".equals(isBaselineView)%>'>
                  <%--XSSOK --%>  
                        <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("Wizard")%>'>
                          <td align="center" width="3%"><%=XSSUtil.encodeForHTML(context,(String)map.get(task.SELECT_PERCENT_COMPLETE))%>&nbsp;</td>
                        </framework:ifExpr>
                    <%--XSSOK --%> 
                        <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("Wizard")%>'>
                          <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                        </framework:ifExpr>
                        <%
	                        //[End Added::Aug 10, 2011:MS9:R212 : IR-016048V6R2012x]
	                        _unitsLabel = ProgramCentralUtil.getUnits(context,DomainConstants.ATTRIBUTE_TASK_ESTIMATED_DURATION);
	                        
	                        String strTaskEstDuration = (String)map.get(task.SELECT_TASK_ESTIMATED_DURATION);
	                        String strTaskUnit = (String)map.get(task.SELECT_TASK_ESTIMATED_DURATION+".inputunit");                    
	                        String strEstDurwithUnit = "";
	                        
	                        Unit unit = (Unit) _unitsLabel.get(strTaskUnit);
	                        if (unit != null)
	                        {
	                            strEstDurwithUnit = unit.denormalize(strTaskEstDuration) + " " + strTaskUnit;
	                        }
	                        //[End Added::Aug 10, 2011:MS9:R212 : IR-016048V6R2012x]     
                        %>
                        <td width="3%" nowrap="nowrap"><%=strEstDurwithUnit%>&nbsp;</td>
                      </framework:ifExpr>
                <%--XSSOK --%>  
                      <framework:ifExpr expr='<%= "true".equals(isBaselineView)%>'>
                        <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                      </framework:ifExpr>
                   <%--XSSOK --%> 
                      <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("Wizard")%>'>
                      <td width="5%" nowrap="nowrap">
                        <framework:lzDate localize="i18nId" tz="<%=timeZone%>" format="<%=dateFormat%>" displaydate="true">
                     <%--XSSOK --%>  
                          <%=map.get(task.SELECT_TASK_ESTIMATED_START_DATE)%>
                        </framework:lzDate>&nbsp;
                      </td>
                      <td width="5%" nowrap="nowrap">
                        <framework:lzDate localize="i18nId" tz="<%=timeZone%>" format="<%=dateFormat%>" displaydate="true">
                   <%--XSSOK --%>   
                          <%=map.get(task.SELECT_TASK_ESTIMATED_FINISH_DATE)%>
                        </framework:lzDate>&nbsp;
                      </td>
                      <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                    <%--XSSOK --%> 
                      <framework:ifExpr expr='<%= "false".equals(isBaselineView) && isPortal==false%>'>
                        <td width="3%" nowrap="nowrap"><%=XSSUtil.encodeForHTML(context,(String)map.get(task.SELECT_TASK_ACTUAL_DURATION))%></td>
                      </framework:ifExpr>
                      <td width="5%" nowrap="nowrap">
                        <framework:lzDate localize="i18nId" tz="<%= timeZone %>" format="<%= dateFormat %>" displaydate="true">
                 <%--XSSOK --%>   
                          <%=map.get(task.SELECT_TASK_ACTUAL_START_DATE)%>
                        </framework:lzDate>&nbsp;
                      </td>
                      <td width="5%" nowrap="nowrap">
                        <framework:lzDate localize="i18nId" tz="<%=timeZone%>" format="<%=dateFormat%>" displaydate="true">
                      <%--XSSOK --%>  
                          <%=map.get(task.SELECT_TASK_ACTUAL_FINISH_DATE)%>
                        </framework:lzDate>&nbsp;
                      </td>
                    <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                 <%--XSSOK --%> 
                    <framework:ifExpr expr='<%= "true".equals(isBaselineView)%>'>
                      <td width="5%" nowrap="nowrap">
                        <framework:lzDate localize="i18nId" tz="<%= timeZone %>" format="<%= dateFormat %>" displaydate="true">
                          <%= XSSUtil.encodeForHTML(context,baselineInitialStartDateStr) %>
                        </framework:lzDate>&nbsp;
                      </td>
                      <td width="5%" nowrap="nowrap">
                        <framework:lzDate localize="i18nId" tz="<%=timeZone%>" format="<%=dateFormat%>" displaydate="true">
                          <%=XSSUtil.encodeForHTML(context, baselineInitialEndDateStr) %>
                        </framework:lzDate>&nbsp;
                      </td>
                      <td class="whiteseparator"><img src="../common/images/utilSpacer.gif" width="2" height="2" /></td>
                      <td width="5%" nowrap="nowrap">
                        <framework:lzDate localize="i18nId" tz="<%= timeZone %>" format="<%= dateFormat %>" displaydate="true">
                          <%= XSSUtil.encodeForHTML(context,baselineCurrentStartDateStr) %>
                        </framework:lzDate>&nbsp;
                      </td>
                      <td width="5%" nowrap="nowrap">
                        <framework:lzDate localize="i18nId" tz="<%=timeZone%>" format="<%=dateFormat%>" displaydate="true">
                          <%=XSSUtil.encodeForHTML(context, baselineCurrentEndDateStr) %>
                        </framework:lzDate>&nbsp;
                      </td>
                    </framework:ifExpr>
                     <%--XSSOK --%> 
                      <framework:ifExpr expr='<%= "false".equals(isBaselineView)%>'>
                        <td width="2%" align="left" nowrap="nowrap"><%=XSSUtil.encodeForHTML(context,ownerName)%>&nbsp;</td>
                      </framework:ifExpr>
                    </framework:ifExpr>
                     <%--XSSOK --%> 
                      <framework:ifExpr expr='<%= "false".equals(isBaselineView) && isPortal==false%>'>
                        <td width="1%" align="left" nowrap="nowrap">
                          <%= row++ %>
                        </td>
                        <td width="2%" align="left" nowrap="nowrap"><%=XSSUtil.encodeForHTML(context,(String)map.get("PREDECESSORS"))%>&nbsp;</td>
                      </framework:ifExpr>
                  <%--XSSOK --%>  
                    <framework:ifExpr expr='<%=!mode.equalsIgnoreCase("Wizard")%>'>
                     <%--XSSOK --%>  
                        <framework:ifExpr expr='<%= "false".equals(isBaselineView) && isPortal==false%>'>
                          <td align="left" width="5%" nowrap="nowrap">
                          <%--XSSOK --%>  
                            <framework:ifExpr expr='<%=(("Mandatory".equals((String)map.get(task.SELECT_TASK_REQUIREMENT)))) && !mxType.isOfParentType(context,thisObjectType,projectType) && !thisObjectType.equals(conceptType)%>'>
                              <framework:i18n localize="i18nId">emxProgramCentral.Common.Mandatory</framework:i18n>
                            </framework:ifExpr>&nbsp;
                         <%--XSSOK --%>  
                            <framework:ifExpr expr='<%=(!("Mandatory".equals((String)map.get(task.SELECT_TASK_REQUIREMENT)))) && !mxType.isOfParentType(context,thisObjectType,projectType) && !thisObjectType.equals(conceptType)%>'>
                              <framework:i18n localize="i18nId">emxProgramCentral.Common.Optional</framework:i18n>
                            </framework:ifExpr>&nbsp;
                          </td>
                        </framework:ifExpr>
              <%--XSSOK --%>    
                        <framework:ifExpr expr='<%= "false".equals(isBaselineView) && isPortal==false%>'>
                          <td width="2%" align="center" nowrap="nowrap">
                            &nbsp;
                            <framework:ifExpr expr="<%=allowEdit%>">
<%
                            if(!isPrinterFriendly) {
%>
                             <%--XSSOK --%>  
                                <a href="javascript:showDialog('<%=url%>');">
<%
                            }
%>
                                  <%-- Commenting for PMC 10-6-SP2 Starts --%>
                                  <%-- <img src="../common/images/iconActionEdit.gif" border="0" alt="<framework:i18n localize="i18nId">emxProgramCentral.Common.Edit</framework:i18n>" /> --%>
                                  <%-- Commenting for PMC 10-6-SP2 Ends --%>

                                  <%-- Modification for PMC 10-6-SP2 Starts --%>
                                  <%-- Added 'title' keyword so that tooltip functionality works for FireFox Browser too --%>
                                  <img src="../common/images/iconActionEdit.gif" border="0" alt="<framework:i18n localize="i18nId">emxProgramCentral.Common.Edit</framework:i18n>" title="<framework:i18n localize="i18nId">emxProgramCentral.Common.Edit</framework:i18n>" />
                                  <%-- Modification for PMC 10-6-SP2 Ends --%>
                                </a>
                            </framework:ifExpr>
                          </td>
                        </framework:ifExpr>
                      </framework:ifExpr>
                    </framework:ifExpr>

                    <framework:ifExpr expr="<%=!isActive%>">

                      <td>&nbsp;</td>

                      <td class="requiredNotice" align="center" nowrap="nowrap">

                        <framework:i18n localize="i18nId">emxProgramCentral.Common.Deleted</framework:i18n>

                      </td>

                      <td class="requiredNotice" align="center" nowrap="nowrap">

                        <framework:lzDate localize='i18nId' tz='<%= timeZone %>' format='<%= dateFormat %>' displaydate='true'>

                      <%--XSSOK --%>  
                          <%= map.get(SELECT_DELETED_DATE)%>

                        </framework:lzDate>

                        &nbsp;

                      </td>

                   <%-- XSSOK--%>
   <td colspan="10" class="requiredNotice"><%=map.get(SELECT_DELETED_COMMENTS)%>&nbsp;</td>

                    </framework:ifExpr>


                  </tr>
                 </framework:ifExpr>
               </framework:ifExpr>
             </framework:mapListItr>

<%
  if(toExcel)
  {
    if(wbsMasterList.size() == 1) {
      exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
  			"emxProgramCentral.Common.ThereAreNoProjectTasksForThisProject", language) + '\n');
      if(isECHInstalled){
	  	exportStringBuffer.append(messageThereAreNoProjectTasksForThisProject);
	  }
    }

    String fileNameStr = "projectSpace_" + (new Date()).getTime() + "_WBSSummary.csv";
    String fileEncodeType = UINavigatorUtil.getFileEncoding(context, request);
    String fileName = new String(fileNameStr.getBytes(),fileEncodeType);
    fileName = fileName.replace(' ','_');
    String saveAs = ServletUtil.encodeURL(fileName);
    String tempFileName = saveAs.replace('%','0');  // temp - hashed file name

    String url = "";
    try
    {
        OutputStreamWriter osw = new OutputStreamWriter( (java.io.OutputStream)Framework.createTemporaryFile(session, tempFileName),  fileEncodeType);
          BufferedWriter prgBw = new BufferedWriter( osw );
      prgBw.write(exportStringBuffer.toString());
      prgBw.flush();
      prgBw.close();
      url = Framework.getTemporaryFilePath(response, session, tempFileName, true);
    }
    catch(Exception nex)
    {

    }
    url = url.substring(0,url.lastIndexOf("/")+1) + tempFileName  +  "?saveasfile=" + saveAs;
%>
<link rel="stylesheet" href="../common/styles/emxUIDialog.css" type="text/css" />
<table border="0" width="710" cellpadding="0" cellspacing="0" class="formBG">
    <tr>
      <td>
        <table border="0" width="710" cellpadding="0" cellspacing="0" class="formBG">
            <table border="0" width="700">
                <tr>
                  <td nowrap class="label" width="33%">
                    <emxUtil:i18n localize="i18nId">emxProgramCentral.Export.DownloadFile</emxUtil:i18n>
                  </td>
                <%--XSSOK --%>  
<td width="10"> <a href="<%= url%>"><%= XSSUtil.encodeForHTML(context,fileName) %></a></td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
  <div id="confirmDownload">
    <p>
      <a href="javascript:getTopWindow().closeWindow()">&nbsp;&nbsp;<emxUtil:i18n
          localize="i18nId">emxProgramCentral.Common.Close</emxUtil:i18n>&nbsp;&nbsp;
      </a>
    </p>
  </div>
<%
  }
%>

<framework:ifExpr expr="<%=toExcel == false%>">
      <%--XSSOK --%>   
                <framework:ifExpr expr="<%=wbsMasterList.size() == 1%>">
                  <tr>
                    <td class="requiredNotice" align="center" valign="top" colspan="13">
                      <framework:i18n localize="i18nId">emxProgramCentral.Common.ThereAreNoProjectTasksForThisProject</framework:i18n>
                      <%if(isECHInstalled){%>
                      	<%=messageThereAreNoProjectTasksForThisProject%>
                      <%}%>
                    </td>
                  </tr>
                </framework:ifExpr>
              </table>
            </td>
          </tr>
        </table>
      </form>

      <form name="HiddenForm" method="post">
        <input type="hidden" name="jsTreeID" value="<%=XSSUtil.encodeForHTMLAttribute(context,jsTreeID)%>" />
        <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="initSource" value="<xss:encodeForHTMLAttribute><%=initSource%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="filterValue" value="<xss:encodeForHTMLAttribute><%=showSel%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="objectId" value="<%=XSSUtil.encodeForHTMLAttribute(context,topId)%>" />
        <input type="hidden" name="wbsNumber" value="<xss:encodeForHTMLAttribute><%=wbsNumber%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="isBaselineView" value="<%=XSSUtil.encodeForHTMLAttribute(context,isBaselineView)%>" />
        <input type="hidden" name="portalMode" value="<%=XSSUtil.encodeForHTMLAttribute(context,portalMode)%>" />
      </form>
    </body>
    	<!--MSDesktopIntegration-Start-->
    	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script><!--To use the find frame function in launchInMSProject() below-->
    	<!--MSDesktopIntegration-End-->

    <script language="javascript" type="text/javaScript">
       <%--XSSOK--%>
        if(<%= !("true".equals(printerFriendly))%>){
          turnOffProgress();
        }

      function refreshSummary(){
        f = document.HiddenForm;
        f.action = "emxProgramCentralWBSSummaryFS.jsp?objectId="+f.objectId.value;
        f.target = "_parent";
        startProgressBar(false);
        f.submit();
      }
      function checkAll (allbox, chkprefix) {
        form = allbox.form;
        max = form.elements.length;
        for (var i=0; i<max; i++) {
          fieldname = form.elements[i].name;
          if (fieldname.substring(0,chkprefix.length) == chkprefix) {
            if(form.elements[i].value != "|<%=XSSUtil.encodeForJavaScript(context, topId)%>"){
              form.elements[i].checked = allbox.checked;
            }
          }
        }
      }

      function submitBaselineView() {
        form = document.EditTasks;
        form.objectId.value = form.topId.value;
        form.action = "emxProgramCentralWBSSummaryFS.jsp?isBaselineView=true&objectId="+form.topId.value;
        form.target = "_parent";
        startProgressBar(false);
        form.submit();
      }

      function submitNormalView() {
        form = document.EditTasks;
        form.objectId.value = form.topId.value;
        form.action = "emxProgramCentralWBSSummaryFS.jsp?isBaselineView=false&objectId="+form.topId.value;
        form.target = "_parent";
        startProgressBar(false);
        form.submit();
      }

      function submitCreateReviseBaseline() {
        form = document.EditTasks;
        url = "emxProgramCentralWBSBaselineDialogFS.jsp?objectId="+form.topId.value;
        showDialog(url);
      }

      function submitBaselineLog() {
        form = document.EditTasks;
        url = "emxProgramCentralWBSBaselineLogFS.jsp?objectId="+form.topId.value;
        showDialog(url);
      }

      function submitHideAllWBS() {
        form = document.EditTasks;
        form.isActive.value = "true";
        form.hideWBS.value = "true";
        form.timeStamp.value = "";
        form.objectId.value = form.topId.value;
        form.action="emxProgramCentralWBSSummaryFS.jsp?objectId="+form.topId.value;
        form.target = "_parent";
        startProgressBar(false);
        form.submit();
      }

      function treeAction(objectId, showSel, jsTreeId,expanded,timeStamp,topId){
        form = document.EditTasks;
        form.objectId.value=objectId;
        form.jsTreeID.value=jsTreeId;
        form.expanded.value=expanded;
        form.timeStamp.value=timeStamp;
        form.topId.value=topId;
        var url = "emxProgramCentralWBSSummary.jsp?mx.page.filter="+showSel+"&isActive=true";
        url += "&objectId=" + objectId;
        url += "&jsTreeID=" + jsTreeId;
        url += "&expanded=" + expanded;
        url += "&timeStamp=" + timeStamp;
        url += "&topId=" + topId;
        url += "&isBaselineView=<%=XSSUtil.encodeForJavaScript(context,isBaselineView)%>"
        url += "&portalMode=<%=XSSUtil.encodeForJavaScript(context,portalMode)%>";
        url += "&suiteKey=<%=XSSUtil.encodeForJavaScript(context,suiteKey)%>";
        url += "&fromAction=<%=XSSUtil.encodeForJavaScript(context,fromAction)%>";
        form.action= url;
        startProgressBar(false);
        form.submit();
      }

      function reloadWBS(){
        f = document.HiddenForm;
        f.action = "emxProgramCentralWBSSummaryFS.jsp?objectId="+f.objectId.value;
        f.target = "_parent";
        startProgressBar(false);
        f.submit();
      }


      // returns true or false depending on whether a child of a selected parent has
      // been selected for copy

      // global boolean value to track if an item is checked
      var isChecked = false;

      function validateStructure() {
        isChecked = false;
        form = document.EditTasks;
        max = form.elements.length;
        for (var i=0; i<max; i++) {
          if (beginsWith("selectedIds", form.elements[i].name)){
            if(form.elements[i].checked == true){
              isChecked = true;
              // if the item is checked make sure none of its children are checked
              for(var j = 0; j<max; j++){
                if(form.elements[j].checked==true && i != j && beginsWith("selectedIds", form.elements[j].name)){
                  if(IsChildParent(form.elements[i].value.split("|")[0], form.elements[j].value)){
                    return false;
                  }
                }
              }
            }
          }
        }
        return true;
      }

	  function IsChildParent(startString, wholeString)
	  {
		var startId = startString+".";
		var tempString = wholeString.substr(0, startId.length);
	    if(tempString == startId){
	       return true;
	    }
	    return false;
	  }
      function submitShowAllWBS() {
        form = document.EditTasks;
        form.isActive.value = "true";
        form.hideWBS.value = "false";
        form.timeStamp.value = "";
        form.objectId.value = form.topId.value;
        form.action="emxProgramCentralWBSSummaryFS.jsp?objectId="+form.topId.value;
        form.target = "_parent";
        startProgressBar(false);
        form.submit();
      }

      // function introduced for Gantt Chart

      function submitGanttChart() {
        var appletHiddenFrame = null;

        if(getTopWindow().findFrame)
        {
          appletHiddenFrame = getTopWindow().findFrame(getTopWindow(), "appletFrame");
          if(!appletHiddenFrame)
          {
            appletHiddenFrame = getTopWindow().openerFindFrame(getTopWindow(), "appletFrame");
          }
        }
        if(!appletHiddenFrame && findFrame)
        {
          appletHiddenFrame = findFrame(getTopWindow(), "appletFrame");
        }
        if(!appletHiddenFrame)
        {
          appletHiddenFrame = openerFindFrame(getTopWindow(), "appletFrame");
        }

        appletHiddenFrame.document.location.href =  "emxProgramCentralGanttApplet.jsp?objectId="+document.EditTasks.topId.value;
      }


      function beginsWith(startString, wholeString){
        var tempString = wholeString.substr(0, startString.length);
        if(tempString == startString){
          return true;
        }
        return false;
      }

	function movePrevious(){
		document.EditTasks.action = "emxProgramCentralCommonFS.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context,busId)%>&fromWBS=true&suiteKey=<%=XSSUtil.encodeForJavaScript(context,suiteKey)%>&fromProgram=<%=XSSUtil.encodeForJavaScript(context,fromProgram)%>&businessGoalId=<%=XSSUtil.encodeForJavaScript(context,businessGoalId)%>&fromAction=<%=XSSUtil.encodeForJavaScript(context,fromAction)%>&fromBG=<%=XSSUtil.encodeForJavaScript(context,fromBG)%>&BusinessUnitId=<%=XSSUtil.encodeForJavaScript(context,businessUnitId)%>&portalMode=<%=XSSUtil.encodeForJavaScript(context,portalMode)%>&functionality=CreateCloneProjectSpaceStep2&topLinks=false&bottomLinks=false&p_button=Back&pageName=WizardWBS";
		document.EditTasks.target = "_parent";		
      document.EditTasks.submit();
    }

//Added:11-Feb-09:nr2:R207:PRG Bug :367099
	function closeWindow(){
		parent.window.closeWindow();
}
//End R207:PRG Bug :367099

      function validateForm(){
        if(validateStructure()){
          // submit to process page
          if(isChecked){
            document.EditTasks.p_button.value = "Next";
            document.EditTasks.action = "emxprojectCreateWizardDispatcher.jsp";
            startProgressBar(false);
            if (jsDblClick()){
              document.EditTasks.submit();
            }
          } else {
            alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Project.SelectTaskBeforeSubmitting</emxUtil:i18nScript>");
            return;
          }
        } else {
          alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.CanNotCopyParentAndChild</emxUtil:i18nScript>");
          return;
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
        if("<%=allowEdit%>" == "false") {
          alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Project.NoEditAccessOnSelectedProject</emxUtil:i18nScript>");
        } else {
			var IntegrationFrame = findFrame(getTopWindow(), "MSOfficeIntegration");

//Added to fix CLink# 324790 - START
			var sframe = top; // variable to store the frames
			//initially assigned the current top frame

			var bpopupFound=false;  // boolean variable to store whether this is a pop-up

			//traversing bottom-up
			while(sframe.getWindowOpener())
			{
				bpopupFound = true;
				//assigning the parent of the current frame to current frame
			    sframe = sframe.getWindowOpener().getTopWindow();
			}

			//if this window was a popup then
			if(bpopupFound == true)
			{
				// finding the frame 'MSOfficeIntegration'
				IntegrationFrame = findFrame(sframe, "MSOfficeIntegration");
			}
//Added to fix CLink# 324790- END

			if(IntegrationFrame)
			{
				var msg = IntegrationFrame.document.MxMSOIApplet.callCommandHandler("MSOffice", "getProjectForMSP", "<%=XSSUtil.encodeForJavaScript(context,topId)%>|" + edit);

				if(msg != "")
					alert(msg);

				return true;
			}
			else
				alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Project.IntegrationFrameNotFound</emxUtil:i18nScript>");
        }
    }
//MSDesktopIntegration-End

  //function added to pass the selected tasks for Deliverables Report.
  //begin of the function
  function submitDeliverableReport(){
    var projId = document.EditTasks.topId.value;
    /*Addition for Incident - 317710 by Matrix One India Starts*/
    startProgressBar(true);
    /*Addition for Incident - 317710 by Matrix One India Ends*/
    var reportURL="../common/emxTable.jsp?table=PMCProjectDeliverableReportSummary&suiteKey=ProgramCentral&header=emxProgramCentral.Common.DeliverableReport&chart=false&pagination=0&calculations=false&HelpMarker=emxhelpdeliverablesreport&program=emxProjectReport:getProjectWBSDeliverableList&objectId="+projId+"&showAll=true";
    showModalDialog(reportURL, 930,650, true);
  }
  //end of the function

    </script>
</framework:ifExpr>
<script language="javascript" type="text/javaScript">
    function editWBS(){
      showModalDialog("emxProgramCentralWBSModifyDialogFS.jsp?objectId="+document.EditTasks.topId.value, 930,650, true);
    }
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

<%
    ContextUtil.commitTransaction(context);
  } catch (Exception e) {
    ContextUtil.abortTransaction(context);
    throw e;
  }
%>
