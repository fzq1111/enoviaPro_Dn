<%--
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id$
--%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="java.util.ArrayList" %>
<%@page import="java.util.*"  %>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="matrix.db.*,matrix.util.StringList"  %>
<%@page import="matrix.util.MatrixException"%>
<%@page import="com.matrixone.apps.domain.*" %>
<%@page import="com.matrixone.apps.domain.util.*,com.matrixone.apps.domain.util.i18nNow" %>
<%@page import="com.matrixone.apps.common.Task" %>
<%@page import =  "com.matrixone.apps.program.ProjectSpace" %>
<%@page import =  "com.matrixone.apps.program.GateReport" %>
<%@page import =  "com.matrixone.apps.program.ProgramCentralConstants" %>
<%!
    static final String SELECT_ID = DomainConstants.SELECT_ID;
    static final String SELECT_NAME = DomainConstants.SELECT_NAME;
    static final String SELECT_TYPE = DomainConstants.SELECT_TYPE;
    static final String SELECT_POLICY = DomainConstants.SELECT_POLICY;
    static final String SELECT_CURRENT = DomainConstants.SELECT_CURRENT;
    static final String POLICY_PROJECT_TASK = DomainConstants.POLICY_PROJECT_TASK;
    static final String POLICY_PROJECT_SPACE = DomainConstants.POLICY_PROJECT_SPACE;

%>


<%!

    public static final String STATE_HOLD = ProgramCentralConstants.STATE_PROJECT_SPACE_HOLD_CANCEL_HOLD;
    public static final String STATE_CANCEL = ProgramCentralConstants.STATE_PROJECT_SPACE_HOLD_CANCEL_CANCEL;
    public static final String TYPE_GATE = ProgramCentralConstants.TYPE_GATE;
    public static final String TYPE_PHASE = ProgramCentralConstants.TYPE_PHASE;
    public static final String STATUS = "status";
    public static final String LAST_DECISION = "lastDecision";
    public static final String  ISARROWHERE= "isArrowHere";

    // Task status constants
    //
    public static final String GATE_HOLD = "hold";
    public static final String GATE_CANCELED = "canceled";
    public static final String GATE_CONDITIONAL = "conditional";
    public static final String GATE_APPROVED = "approved";
    public static final String TASK_COMPLETE = "completed";
    public static final String TASK_LATE = "late";
    public static final String TASK_DELAYED = "delayed";
    public static final String TASK_INACTIVE = "inactive";

    //This method returns the decisions connected with the gate (identified by id).
    //It extracts only the "Approve"/"ConditionallyApproved"/"Hold"/"Cancel"/"Reactivated" decisions whichever is with last revision
    //It should modify the existing mlGatePhase MapList and adds 2 parameter "gateColor" and "lastDecision"   "isArrowAbove"
    private void modifyFinalMapList(Context context,MapList finalMapList,MapList finalMilestoneMapList, int numberOfGates,int numberOfPhases) throws MatrixException{
        try{
            for(int i=0;i<finalMapList.size();i++){
                Map rowMap = (Map) finalMapList.get(i);
                String type = (String) rowMap.get(SELECT_TYPE);
                String id = (String) rowMap.get(SELECT_ID);

                String decisionName = "";
                Map tempMap = new HashMap();
                tempMap.putAll(rowMap);

                if(TYPE_GATE.equals(type)){
                    decisionName = getLastDecision(context,id);
                    tempMap.put(LAST_DECISION,decisionName);
                    tempMap.put(STATUS, getGateStatus(decisionName));
                    finalMapList.remove(rowMap);
                    finalMapList.add(i,tempMap);
                }
                else {
                    tempMap.put(STATUS, getTaskStatus(context, rowMap));
                    finalMapList.remove(rowMap);
                    finalMapList.add(i, tempMap);
                }
            }
            modifyFinalMapForArrow(context,finalMapList);
            // FINAL_GATE_PHASE_MAPLIST = finalMapList;
        }
        catch(Exception e){
            throw new MatrixException(e);
        }
        return;
    }

    private void modifyFinalMapForArrow(Context context,MapList FINAL_GATE_PHASE_MAPLIST) throws MatrixException
    {
        boolean ISARROWFOUND = false;

    /** state "Create" for the "Project Task" policy. */
    final String STATE_PROJECT_TASK_CREATE =
            PropertyUtil.getSchemaProperty(context,"policy",
                                           POLICY_PROJECT_TASK,
                                           "state_Create");

    /** state "Assign" for the "Project Task" policy. */
    final String STATE_PROJECT_TASK_ASSIGN =
            PropertyUtil.getSchemaProperty(context,"policy",
                                           POLICY_PROJECT_TASK,
                                           "state_Assign");

    /** state "Active" for the "Project Task" policy. */
    final String STATE_PROJECT_TASK_ACTIVE =
            PropertyUtil.getSchemaProperty(context,"policy",
                                           POLICY_PROJECT_TASK,
                                           "state_Active");

    /** state "Review" for the "Project Task" policy. */
    final String STATE_PROJECT_TASK_REVIEW =
            PropertyUtil.getSchemaProperty(context,"policy",
                                           POLICY_PROJECT_TASK,
                                           "state_Review");

        try
        {
            int index = 0;
            MapList phaseMapList = new MapList();
            int previousArrowPosition = -1;

            for(int i=0;i<FINAL_GATE_PHASE_MAPLIST.size();i++){
                Map tempMap = (Map) FINAL_GATE_PHASE_MAPLIST.get(i);

                String type = (String) tempMap.get(DomainConstants.SELECT_TYPE);

                if(type.equals(TYPE_GATE)){
                    //Check the Gate status based on project's state
                    String gateId = (String) tempMap.get(DomainConstants.SELECT_ID);
                    DomainObject gateObj = DomainObject.newInstance(context);
                    gateObj.setId(gateId);

                    String  projectId = Task.getParentProject(context,gateObj);
                    com.matrixone.apps.program.ProjectSpace project =
                    (com.matrixone.apps.program.ProjectSpace)
                                        DomainObject.newInstance(context,
                                                                 DomainConstants.TYPE_PROJECT_SPACE,
                                                                 DomainConstants.PROGRAM);

                    if(null != projectId && !"".equals(projectId)){
                        project.setId(projectId);
                    }

                    String prjState = project.getInfo(context, DomainConstants.SELECT_CURRENT);
                    String gateDecision = (String) tempMap.get(LAST_DECISION);

                    // Don't display arrow if the project is not active
                    //
                    if (STATE_PROJECT_TASK_CREATE.equals(prjState) || STATE_PROJECT_TASK_ASSIGN.equals(prjState)){
                        ISARROWFOUND = false;
                        break;
                    }
                    else if((STATE_HOLD.equals(prjState) ||
                        STATE_CANCEL.equals(prjState)) && !ISARROWFOUND){
                        //This is gate is the gate on which arrow should be there.
                        //All subsequest gates and phases should be gray.

                        //we will find a gate with decision either Hold or Cancel if it was done from gate portal view
                        if(null != gateDecision && !"".equals(gateDecision) &&
                                (STATE_HOLD.equals(gateDecision) || STATE_CANCEL.equals(gateDecision))){
                            makeDecisionBlank(FINAL_GATE_PHASE_MAPLIST,i+1);
                            tempMap.put(ISARROWHERE,"middle");
                            FINAL_GATE_PHASE_MAPLIST.remove(i);
                            FINAL_GATE_PHASE_MAPLIST.add(i,tempMap);
                            ISARROWFOUND = true;
                            break;
                        }
                    }
                    else{
                        //Search for first gate with Est. start date > current date.
                        String attrEstStartDate = "attribute[" + DomainConstants.ATTRIBUTE_TASK_ESTIMATED_START_DATE + "]";

                        String gateEstStartDtStr = (String) tempMap.get(attrEstStartDate);
                        Date gateEstStartDt = eMatrixDateFormat.getJavaDate(gateEstStartDtStr);

                        //Don't show arrow if this gate is already completed.
                        //
                        String gateState = (String) tempMap.get(SELECT_CURRENT);
                        Date currentDt = new Date();
                        if((gateEstStartDt.after(currentDt)|| areDatesEqual(gateEstStartDt,currentDt))
                                && !ISARROWFOUND && !ProgramCentralConstants.STATE_PROJECT_REVIEW_COMPLETE.equals(gateState)){
                            makeDecisionBlank(FINAL_GATE_PHASE_MAPLIST,i+1);
                            tempMap.put(ISARROWHERE,"middle");
                            FINAL_GATE_PHASE_MAPLIST.remove(i);
                            FINAL_GATE_PHASE_MAPLIST.add(i,tempMap);
                            ISARROWFOUND = true;
                            break;
                         }
                     }
                }
                else if(type.equals(TYPE_PHASE)){
                    String state = (String) tempMap.get(DomainConstants.SELECT_CURRENT);
                    if(STATE_PROJECT_TASK_ACTIVE.equals(state) || STATE_PROJECT_TASK_REVIEW.equals(state)){
                        double percentComplete = 0.0;
                        makeDecisionBlank(FINAL_GATE_PHASE_MAPLIST,i+1);

                        // See where we are in the phase, based on percent complete
                        //
                        percentComplete = Double.parseDouble((String)tempMap.get(com.matrixone.apps.program.Task.SELECT_PERCENT_COMPLETE));

                        if (percentComplete <= 33.0)
                        {
                            tempMap.put(ISARROWHERE,"beginning");
                        }
                        else if (percentComplete > 33.0 && percentComplete <= 66.0){
                            tempMap.put(ISARROWHERE,"middle");
                        }
                        else
                        {
                            tempMap.put(ISARROWHERE,"end");
                        }

                        FINAL_GATE_PHASE_MAPLIST.remove(i);
                        FINAL_GATE_PHASE_MAPLIST.add(i,tempMap);
                        ISARROWFOUND = true;
                        break;
                    }
                }
                else{ //Put phases here
                    phaseMapList.add(tempMap);
                }
            } //End For

            for(int i=FINAL_GATE_PHASE_MAPLIST.size()-1;i>=1;i--){
                Map tMap = (Map) FINAL_GATE_PHASE_MAPLIST.get(i);
                String isArrowAbove = (String) tMap.get(ISARROWHERE);

                if(null != isArrowAbove && !"".equals(isArrowAbove)){
                    removePreviousArrow(FINAL_GATE_PHASE_MAPLIST,i-1);
                    break;
                }
            }
        }//End try
        catch(Exception e){
            throw new MatrixException(e);
        }
        ISARROWFOUND = false;
        return;
    }

    private void removePreviousArrow(MapList FINAL_GATE_PHASE_MAPLIST,int previousArrowPosition)
    throws MatrixException{
        try{
            for(int i=previousArrowPosition;i>=0 && i<FINAL_GATE_PHASE_MAPLIST.size();i--){
                Map tMap = (Map) FINAL_GATE_PHASE_MAPLIST.get(i);
                tMap.put(ISARROWHERE,"");
            }
        }
        catch(Exception e){
            throw new MatrixException(e);
        }
    }

    private boolean areDatesEqual(Date firstDate,Date secondDate) throws MatrixException{
        boolean returnVal = false;
        try{
            SimpleDateFormat sfd = new SimpleDateFormat("yyyy.MM.dd");
            String firstDateStr =  sfd.format(firstDate);
            String secondDateStr =  sfd.format(secondDate);

            returnVal = firstDateStr.equals(secondDateStr);
        }
        catch(Exception e){
            throw new MatrixException(e);
        }
        return returnVal;
    }

    private String getGateStatus(String decisionName) throws MatrixException, Exception {
        String gateStatus = "";

        try{
            String APPROVE = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.Gate.Approve", "en");
            String CONDITIONALLYAPPROVE = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.Gate.ConditionallyApprove", "en");
            String HOLD = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.Gate.Hold", "en");
            String CANCEL = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.Gate.Cancel", "en");
            String REACTIVATE = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.Gate.Reactivate", "en");
            // Gate status is dependent on last decision made for that Gate
            //
            if((APPROVE).equals(decisionName) || (REACTIVATE).equals(decisionName)){
                gateStatus = GATE_APPROVED;
            }
            else if((CONDITIONALLYAPPROVE).equals(decisionName)){
                gateStatus = GATE_CONDITIONAL;
            }
            else if((HOLD).equals(decisionName)){
                gateStatus = GATE_HOLD;
            }
            else if ((CANCEL).equals(decisionName)){
                gateStatus = GATE_CANCELED;
            }
            else{
                gateStatus = ""; //Even if no Decision is connected to this gate.
            }
        }
        catch(Exception e){
            throw new MatrixException(e);
        }
        return gateStatus;
    }

    //This method returns the name of the last decison connected with the gate identified by gateId.
    //will return empty string if no decision connected to the gate is found.
    //Note: This is an performance overhead doing database fetch in JSP, will move the code in JPO.

    private String getLastDecision(Context context,String gateId) throws MatrixException{
        String decisionName = "";
        try{
            GateReport grBean = new GateReport();
            decisionName = grBean.getLastDecision(context,gateId);
        }
        catch(Exception e){
            throw new MatrixException(e);
        }
        return decisionName;
    }

    private void makeDecisionBlank(MapList FINAL_GATE_PHASE_MAPLIST,int index){
        for(int i=index;i<FINAL_GATE_PHASE_MAPLIST.size();i++){
            ((Map)FINAL_GATE_PHASE_MAPLIST.get(i)).put(LAST_DECISION,"");
        }
    }

    private String getDeliveryChecklistHTML(Context context, String id, String strLang) throws MatrixException, Exception {
        String deliveryChecklistHTML = "";
        try{
            //String deliverableHeader = i18nNow.getI18nString("emxProgramCentral.Common.Deliverable","emxProgramCentralStringResource",strLang);
            //deliverableHeader = deliverableHeader.replaceAll("'","&apos;");
        //  String meetingHeader = i18nNow.getI18nString("emxComponents.Heading.Meetings","emxComponentsStringResource",strLang);
          //meetingHeader = meetingHeader.replaceAll("'","&apos;");
            //String checkListHeader = i18nNow.getI18nString("emxProgramCentral.Common.Checklist.ChecklistSummary","emxProgramCentralStringResource",strLang);
            //checkListHeader = checkListHeader.replaceAll("'","&apos;");
            
            com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context,
            DomainConstants.TYPE_TASK, "PROGRAM");
            task.setId(id);

            String taskPolicy = task.getInfo(context, SELECT_POLICY);
            
            boolean returnValue = true;
            Map methodMap = new HashMap(1);
            methodMap.put("objectId",id);
            methodMap.put("languageStr",strLang);
            String[] methodArgs = JPO.packArgs(methodMap);
            Boolean returnVal  = (Boolean) JPO.invoke(context,
                                                 "emxChecklist", 
                                                 null,
                                                 "checkCreateObjectAccessFunctionProjectLead", 
                                                  methodArgs,
                                                  Boolean.class);
                String strReturnValue = returnVal.toString();

            String deliverableURL = "../common/emxTable.jsp?program=emxTask:getAllDeliverables&table=APPDocumentSummary&selection=multiple&sortColumnName=Name&sortDirection=ascending&toolbar=PMCContentSummaryToolBar&header=emxProgramCentral.Common.Deliverable&HelpMarker=emxhelpcontentsummary&suiteKey=ProgramCentral&parentRelName=relationship_TaskDeliverable&objectId=";
            // [MODIFIED::Jul 30, 2011:S4E:R212:IR-122369V6R2012x::Start]
            String checkListURL = "../common/emxIndentedTable.jsp?table=PMCChecklistSummaryTable&toolbar=PMCChecklistTopActionToolbar&mode=view&selection=multiple&sortColumnName=Name,Type&suiteKey=ProgramCentral&Export=true&relationship=relationship_Checklist,relationship_ChecklistItem&type=type_Checklist,type_ChecklistItem&direction=From&expandLevelFilter=true&editRootNode=false&header=emxProgramCentral.Common.Checklist.ChecklistSummary&objectId="+id;
            if(null != strReturnValue && strReturnValue.equalsIgnoreCase("true")){
                	checkListURL += "&editLink=true";
                }
            // [MODIFIED::Jul 30, 2011:S4E:R212:IR-122369V6R2012x::End]
             String meetingURL = "../common/emxIndentedTable.jsp?program=emxMeeting:getMeetings&table=APPMeetingSummary&mode=view&toolbar=APPMeetingsTopActionToolbar&selection=multiple&editLink=true&sortColumnName=Name&postProcessJPO=emxMeeting:postProcessRefresh&GlobalContext=false&direction=from&objectCompare=false&FilterFramePage=..common/emxCommonStateFilter.jsp&SuiteDirectory=components&header=emxComponents.Heading.Meetings&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&expandProgram=emxMeeting:getTableMeetingData&objectId=";
           //modify by wangyitao
		   // String decisionURL = "../common/emxPortal.jsp?portal=PMCDecisionPowerView&showPageHeader=false&objectId=";
			String decisionURL ="../common/emxIndentedTable.jsp?program=emxTask:getSEMRelatedTask&table=SEMRelatedTaskTable&selection=multiple&editLink=true&toolbar=SEMRelatedTaskToolbar&sortColumnName=Name&header=emxFramework.command.SEMRelatedTaskName&sortDirection=ascending&objectId=";
			//end
            StringBuffer deliveryChecklistBuff = new StringBuffer();

            deliveryChecklistBuff.append("<td>");
            deliveryChecklistBuff.append("<div class=\"objects\">");
            
            String strMeeting = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Dashboards.Meeting", strLang);
            //modify by wangyitao
			//String strDecision = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Dashboards.Decision", strLang);
            String strDecision = "\u5173\u8054\u4EFB\u52A1";
			//end
			String strDeliverables = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Dashboards.Deliverables", strLang);
            String strChecklist = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Dashboards.Checklist", strLang);

            // Meeting
            //
            deliveryChecklistBuff.append("<a href = 'javascript:showModalDialog(\"");
            deliveryChecklistBuff.append(meetingURL + id);
            deliveryChecklistBuff.append(" \" , \"875\" , \"600\")'>");
            deliveryChecklistBuff.append("<img src=\"../common/images/iconSmallMeeting.gif\" title=\""+strMeeting+"\"/></a>");
          

            // Decision
            //
            deliveryChecklistBuff.append("<a href = 'javascript:showModalDialog(\"");
            deliveryChecklistBuff.append(decisionURL + id);
            deliveryChecklistBuff.append(" \" , \"875\" , \"600\")'>");
            deliveryChecklistBuff.append("<img src=\"../common/images/iconSmallDecision.gif\" title=\""+strDecision+"\"/></a>");

            // Deliverable
            //
            deliveryChecklistBuff.append("<a href = 'javascript:showModalDialog(\"");
            deliveryChecklistBuff.append(deliverableURL + id);
            deliveryChecklistBuff.append(" \" , \"875\" , \"600\")'>");
            deliveryChecklistBuff.append("<img src=\"../common/images/iconSmallDeliverable.gif\" title=\""+strDeliverables+"\"/></a>");

            // Checklist
            //
            if(ProgramCentralConstants.POLICY_PROJECT_REVIEW.equalsIgnoreCase(taskPolicy)){
            deliveryChecklistBuff.append("<a href = 'javascript:showModalDialog(\"");
            deliveryChecklistBuff.append(checkListURL);
            deliveryChecklistBuff.append(" \" , \"875\" , \"600\")'>");
            deliveryChecklistBuff.append("<img src=\"../common/images/iconSmallFile.gif\" title=\""+strChecklist+"\"/></a>");
			}

            deliveryChecklistBuff.append("</div>");
            deliveryChecklistBuff.append("</td>");


            deliveryChecklistHTML = deliveryChecklistBuff.toString();
        }
        catch(Exception e){
            throw new MatrixException(e);
        }
        return deliveryChecklistHTML;
    }

    private String getMilestonesHTML(Context context, MapList mlMilestones, double clientTZOffset, Locale locale, String strLang) throws MatrixException
    {
        String milestonesHTML = "";

        try
        {
            StringBuffer milestonesBuff = new StringBuffer();
            milestonesBuff.append("<td>");

            if (mlMilestones.size() > 0)
            {
                String cssClass = "";
				String sMilestone = EnoviaResourceBundle.getAdminI18NString(context, "Type", ProgramCentralConstants.TYPE_MILESTONE, strLang);
                milestonesBuff.append("<div class=\"milestones\">");
                milestonesBuff.append("<p>");
                milestonesBuff.append(sMilestone);
                milestonesBuff.append("</p>");
                milestonesBuff.append("<ul>");

                for (int i=0; i < mlMilestones.size(); i++)
                {
                    Map milestoneMap = (Map)mlMilestones.get(i);
                    String name = (String) milestoneMap.get(DomainConstants.SELECT_NAME);
                    String id   = (String) milestoneMap.get(DomainConstants.SELECT_ID);
                    String currentState = (String) milestoneMap.get(SELECT_CURRENT);

                    String toolTipString = getToolTipInfo(milestoneMap, clientTZOffset, locale, strLang);

                    // CSS class based on status
                    //
                    cssClass = (String)milestoneMap.get(STATUS);

                    milestonesBuff.append("<li>");
                    milestonesBuff.append("<a class=\"" + cssClass + "\" href='javascript:showModalDialog(\"");
                    milestonesBuff.append("../common/emxTree.jsp?objectId=" + id);
                    milestonesBuff.append("\", \"850\", \"600\")'");
                    milestonesBuff.append(" id=\"milestone" + id + "\"");
                    milestonesBuff.append(" onmouseover=\"xstooltip_show('tooltip_123', " + "'milestone" + id + "', 289, 49,'" + toolTipString.replaceAll("'","&quot;") +"');\"");
                    milestonesBuff.append(" onmouseout=\"xstooltip_hide('tooltip_123');\">");
                    milestonesBuff.append(name);
                    milestonesBuff.append("</a>");
                    milestonesBuff.append("</li>");
                }

                milestonesBuff.append("</ul>");
                milestonesBuff.append("</div>");
            }

            milestonesBuff.append("</td>");
            milestonesHTML = milestonesBuff.toString();
        }
        catch(Exception e){
            throw new MatrixException(e);
        }
        return milestonesHTML;
    }

    // TODO!  Rename this properly
    //Will return milestones connested at level two for the phase whose id is being passed
    private MapList getMilestones(Context context,String id) throws MatrixException{
        MapList mlMilestones = new MapList();
        try{
            GateReport grBean = new GateReport();
            mlMilestones = grBean.getMilestones(context,id);
        }
        catch(Exception e){
            throw new MatrixException(e);
        }
        return mlMilestones;
    }

    private String getToolTipInfo(Map m, double clientTZOffset, Locale locale,String strLang) throws MatrixException, Exception {
        String toolTipString = "";
        try{
            String estStartDate = "attribute[" + DomainConstants.ATTRIBUTE_TASK_ESTIMATED_START_DATE + "]";
            String estFinishDate = "attribute[" + DomainConstants.ATTRIBUTE_TASK_ESTIMATED_FINISH_DATE + "]";
            String actStartDate = "attribute[" + DomainConstants.ATTRIBUTE_TASK_ACTUAL_START_DATE + "]";
            String actFinishDate = "attribute[" + DomainConstants.ATTRIBUTE_TASK_ACTUAL_FINISH_DATE + "]";
            // String parentName = "to[" + DomainConstants.RELATIONSHIP_SUBTASK + "].from.name";

            StringBuffer sbf = new StringBuffer();

            // String nameValue = (String) m.get(DomainConstants.SELECT_NAME);
            // String stateValue = (String)m.get(DomainConstants.SELECT_CURRENT);
            String typeValue = (String)m.get(DomainConstants.SELECT_TYPE);
            String estStDtValue = (String)m.get(estStartDate);
            estStDtValue = eMatrixDateFormat.getFormattedDisplayDate(estStDtValue, clientTZOffset, locale);
            String estFinDtValue = (String)m.get(estFinishDate);
            estFinDtValue = eMatrixDateFormat.getFormattedDisplayDate(estFinDtValue, clientTZOffset, locale);
            String actStDtValue = (String)m.get(actStartDate);
            actStDtValue = eMatrixDateFormat.getFormattedDisplayDate(actStDtValue, clientTZOffset, locale);
            String actFinDtValue = (String)m.get(actFinishDate);
            actFinDtValue = eMatrixDateFormat.getFormattedDisplayDate(actFinDtValue, clientTZOffset, locale);

            String statusValue = "";
            String statusLabel = "";
            if(ProgramCentralConstants.TYPE_GATE.equals(typeValue)){
                statusLabel = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.lastDecisionTakenOnGate", strLang);
                statusValue = (String) m.get(LAST_DECISION);
                if( ProgramCentralUtil.isNotNullString(statusValue)){                     
                statusValue =i18nNow.getStateI18NString(ProgramCentralConstants.POLICY_PROJECT_SPACE_HOLD_CANCEL,statusValue ,strLang);
                }
            }
            else{
                statusLabel = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.Status", strLang);
                statusValue = (String)m.get(STATUS);

                if (TASK_LATE.equals(statusValue)){
                    statusValue = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.Late", strLang);
                }
                else if (TASK_DELAYED.equals(statusValue)){
                    statusValue = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.Legend.BehindSchedule", strLang);
                }
                else if (TASK_COMPLETE.equals(statusValue)){
                    statusValue = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.OnTime", strLang);
                }
                else{
                    statusValue = ""; 
                }
            }
            // String parent = i18nNow.getI18nString("emxProgramCentral.Common.Parent","emxProgramCentralStringResource",strLang);
            //Added :28-Oct-10:s2e:R210  IR: 075143
            String strEstStartDate = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.EstimatedStartDate", strLang);
            String strEstFinDate = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.EstimatedFinishDate", strLang);
            String strActStartDate = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.ActualStartDate", strLang);
            String strActFinDate = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", "emxProgramCentral.Common.ActualFinishDate", strLang);
            //End :28-Oct-10:s2e:R210  IR: 075143
            // sbf.append(parent + ": " + (String)m.get(parentName) + "<br>");
            // String Name = i18nNow.getBasicI18NString("Name",strLang);
            // sbf.append(Name + ": " + nameValue + "<br>");
            // String State = i18nNow.getBasicI18NString("Current",strLang);
            // sbf.append(State + ": " + stateValue + "<br>");
            // String Type = i18nNow.getBasicI18NString("Type",strLang);
            // sbf.append(Type + ": " + typeValue + "<br>");

            String estStartDt = i18nNow.getAttributeI18NString(DomainConstants.ATTRIBUTE_TASK_ESTIMATED_START_DATE,strLang);
            //Modified :8-Oct-10:s2e:R210  IR: 075143
            //sbf.append(estStartDt + ": " + estStDtValue + "<br>");
            sbf.append(strEstStartDate + ": " + estStDtValue + "<br/>");
            String estFinishDt = i18nNow.getAttributeI18NString(DomainConstants.ATTRIBUTE_TASK_ESTIMATED_FINISH_DATE,strLang);
            //sbf.append(estFinishDt + ": " + estFinDtValue + "<br>");
            sbf.append(strEstFinDate + ": " + estFinDtValue + "<br/>");
            String ActStartDt = i18nNow.getAttributeI18NString(DomainConstants.ATTRIBUTE_TASK_ACTUAL_START_DATE,strLang);
            //sbf.append(ActStartDt + ": " + actStDtValue + "<br>");
            sbf.append(strActStartDate + ": " + actStDtValue + "<br/>");
            String ActFinishDt = i18nNow.getAttributeI18NString(DomainConstants.ATTRIBUTE_TASK_ACTUAL_FINISH_DATE ,strLang);
            //sbf.append(ActFinishDt + ": " + actFinDtValue);
            sbf.append(strActFinDate + ": " + actFinDtValue);
            //End :28-Oct-10:s2e:R210  IR: 075143

            if(!"".equals(statusValue)){
                sbf.append("<br/>" + statusLabel + ": " + statusValue);
            }

            toolTipString = sbf.toString();
        }
        catch(Exception e){
            throw new MatrixException(e);
        }
        return toolTipString;
    }

    private String getTaskStatus(Context context, Map objectMap) throws MatrixException
    {
        String status = "";

        com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context,
                DomainConstants.TYPE_TASK, "PROGRAM");


    /** state "Complete" for the "Project Task" policy. */
    final String STATE_PROJECT_TASK_COMPLETE =
            PropertyUtil.getSchemaProperty(context,"policy",
                                           POLICY_PROJECT_TASK,
                                           "state_Complete");

        try
        {
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(),
                    Locale.US);
            int yellowRedThreshold = Integer.parseInt(EnoviaResourceBundle.getProperty(context, "eServiceApplicationProgramCentral.SlipThresholdYellowRed"));
            Date tempDate = new Date();
            Date sysDate = new Date(tempDate.getYear(), tempDate.getMonth(),
                    tempDate.getDate());

            Date baselineCurrentEndDate = null;
            String baselineCurrentEndDateString = (String) objectMap.get(task.SELECT_BASELINE_CURRENT_END_DATE);

            Date estFinishDate = sdf.parse((String) objectMap.get(
                        task.SELECT_TASK_ESTIMATED_FINISH_DATE));
            if (null != baselineCurrentEndDateString && !"".equals(baselineCurrentEndDateString))
            {
                baselineCurrentEndDate = sdf.parse((String) objectMap.get(
                            task.SELECT_BASELINE_CURRENT_END_DATE));
            }
            long daysRemaining;
            if (null == baselineCurrentEndDate)
            {
                daysRemaining = (long) task.computeDuration(sysDate,estFinishDate);

                if (objectMap.get(task.SELECT_CURRENT).equals(STATE_PROJECT_TASK_COMPLETE) ||
                      ((String) objectMap.get(task.SELECT_PERCENT_COMPLETE)).equals(
                          "100"))
                {
                    status = TASK_COMPLETE;
                }
                else if (!objectMap.get(task.SELECT_CURRENT).equals(STATE_PROJECT_TASK_COMPLETE) &&
                      sysDate.after(estFinishDate))
                {
                    status = TASK_LATE;
                }
                else if (!objectMap.get(task.SELECT_CURRENT).equals(STATE_PROJECT_TASK_COMPLETE) &&
                      daysRemaining <= yellowRedThreshold)
                {
                    status = TASK_DELAYED;
                }
                else
                {
                    status = TASK_INACTIVE;
                }
            }
            else
            {
                daysRemaining = (long) task.computeDuration(sysDate,baselineCurrentEndDate);

                if (objectMap.get(task.SELECT_CURRENT).equals(STATE_PROJECT_TASK_COMPLETE) ||
                      ((String) objectMap.get(task.SELECT_PERCENT_COMPLETE)).equals(
                          "100"))
                {
                    status = TASK_COMPLETE;
                }
                else if (!objectMap.get(task.SELECT_CURRENT).equals(STATE_PROJECT_TASK_COMPLETE) &&
                      sysDate.after(baselineCurrentEndDate))
                {
                    status = TASK_LATE;
                }
                else if (!objectMap.get(task.SELECT_CURRENT).equals(STATE_PROJECT_TASK_COMPLETE) &&
                      (daysRemaining <= yellowRedThreshold))
                {
                    status = TASK_DELAYED;
                }
                else
                {
                    status = TASK_INACTIVE;
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
            throw new MatrixException(e);
        }
        finally {
            return status;
        }
    }
%>
