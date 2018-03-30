

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.program.Currency"%>
<%@page import="com.matrixone.apps.common.WorkCalendar"%>
<%@page import="com.matrixone.apps.program.fiscal.Helper"%>
<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.json.JSONObject"%>
<%@page import="java.util.Set"%>
<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.db.MQLCommand"%>
<%@page import="com.matrixone.apps.common.Company,matrix.util.StringList" %>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>

<%@page import="java.util.Enumeration"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.matrixone.apps.program.FTE"%>
<%@page import="com.matrixone.apps.program.ResourceRequest"%>
<%@page import="com.matrixone.apps.program.Question"%>
<%@page import="com.matrixone.apps.domain.DomainConstants" %>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script src="../programcentral/emxProgramCentralUIFormValidation.js" type="text/javascript"></script>

<%
	 String projectType = DomainConstants.TYPE_PROJECT_SPACE; 
	 String sLanguage = request.getHeader("Accept-Language");	 
	 String strMode = emxGetParameter(request, "mode");
	 strMode = XSSUtil.encodeURLForServer(context, strMode);
     String objId = emxGetParameter(request, "objectId");
     objId = XSSUtil.encodeURLForServer(context, objId);
     String contentURL = DomainObject.EMPTY_STRING;
     String RELATIONSHIP_SHADOW_GATE = PropertyUtil.getSchemaProperty("relationship_ShadowGate");
     String SELECT_SHADOW_GATE_ID = "from["+RELATIONSHIP_SHADOW_GATE+"].id";
     
 	 boolean isECHInstalled = com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appVersionEnterpriseChange",false,null,null);
 	 
     if("refreshStructure".equals(strMode)) {   	 
    		%>
    		<script language="javascript">    		  		   		
    	      var detailsDisplay = findFrame(getTopWindow().parent.window, "detailsDisplay");
    	       detailsDisplay.location.href = detailsDisplay.location.href; 
    	     </script> 
    		<%
	       
     } else if ("manageDependencies".equalsIgnoreCase(strMode)) {
		String selectedTaskId = emxGetParameter(request, "objectId");
		selectedTaskId = XSSUtil.encodeURLForServer(context, selectedTaskId);
		String strURL = "../common/emxIndentedTable.jsp?table=PMCTaskDependency&freezePane=Name&selection=multiple&header=emxProgramCentral.Common.DependencyHeading&program=emxTaskBase:getTaskDependencies&HelpMarker=emxhelpeditdepend&suiteKey=ProgramCentral&SuiteDirectory=programcentral&toolbar=PMCManageTaskDependenciesActionToolbar&StringResourceFileId=emxProgramCentralStringResource&emxSuiteDirectory=programcentral";
		if(ProgramCentralUtil.isNotNullString(objId))
			strURL = strURL + "&projectId=" + XSSUtil.encodeForURL(context, objId);
		strURL = strURL + "&objectId=" + XSSUtil.encodeForURL(context, selectedTaskId);
		strURL = strURL + "&customize=false";
		strURL = strURL + "&rowGrouping=false";
		strURL = strURL + "&Export=false";
		strURL = strURL + "&multiColumnSort=false";
		strURL = strURL + "&showPageURLIcon=false";
		strURL = strURL + "&displayView=details";
		strURL = strURL + "&showClipboard=false";
		strURL = strURL + "&objectCompare=false";
	    strURL = strURL + "&massUpdate=false";
		strURL = strURL + "&findMxLink=false";
		strURL = strURL + "&autoFilter=false";
  	    strURL = strURL + "&mode=refreshWBS";
  	    strURL = strURL + "&showRMB=false";

%>
   <script language="javascript">
 <%-- XSSOK--%>
    var strUrl = "<%=strURL%>";
     var manageDependencies = findFrame(getTopWindow(),"PMCWBSManageDependencies");
     manageDependencies.location.href = strUrl;
   </script> 
 <%
  	}

  	else if ("addInternalDependencies".equalsIgnoreCase(strMode))
  	{
  		String taskId = emxGetParameter(request, "objectId");
  		taskId = XSSUtil.encodeURLForServer(context, taskId); 
  		String projectId = emxGetParameter(request, "projectId");
  		projectId = XSSUtil.encodeURLForServer(context, projectId);
 
 		String strURL = "../common/emxIndentedTable.jsp?table=PMCAddTaskDependencyTable&freezePane=Name&selection=multiple&header=emxProgramCentral.Dependency.AssignWBSTaskDependency&expandProgram=emxTask:getWBSIndependentTaskList&toolbar=PMCAddTaskDependenciesActionToolbar&HelpMarker=emxhelpdependencyadddialog&suiteKey=ProgramCentral&SuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource&emxSuiteDirectory=programcentral&hideRootSelection=true";
  		strURL = strURL + "&objectId=" + XSSUtil.encodeForURL(context, projectId);
  		strURL = strURL + "&selectedTaskId=" + XSSUtil.encodeForURL(context, taskId);
  		strURL = strURL + "&customize=true";
  		strURL = strURL + "&rowGrouping=false";
  		strURL = strURL + "&Export=false";
  		strURL = strURL + "&multiColumnSort=false";
  		strURL = strURL + "&showPageURLIcon=false";
  		strURL = strURL + "&displayView=details";
  		strURL = strURL + "&showClipboard=false";
  		strURL = strURL + "&objectCompare=false";
  		strURL = strURL + "&massUpdate=false";
  		strURL = strURL + "&findMxLink=false";
  		strURL = strURL + "&PrinterFriendly=false";
  		strURL = strURL + "&autoFilter=false";
  	    strURL = strURL + "&expandLevelFilter=true";
  	   	strURL = strURL + "&sortColumnName=ID";
  	    strURL = strURL + "&uiType=structureBrowser";
  	    strURL = strURL + "&mode=refreshWBS";
  	    strURL = strURL + "&showRMB=false";
  	    session.setAttribute("rootObjectId",projectId);
  	  
  	
  %>
      <script language="javascript">
   <%-- XSSOK--%>
    var strUrl = "<%=strURL%>";
     var internalTaskDependencies = findFrame(getTopWindow(),"PMCAddInternalTaskDependencies");
     internalTaskDependencies.location.href = strUrl;
       </script> 
<%
  	}
	
  	else if ("addExternalDependencies".equalsIgnoreCase(strMode))	{
  		String selectedTaskId = emxGetParameter(request, "objectId");
  		String strProjectId = emxGetParameter(request, "projectId");
          		
  	String strURL = "../common/emxIndentedTable.jsp?table=PMCAddExternalTaskDependencyTable&freezePane=Title&selection=single&header=eServiceSuiteProgramCentral.ExternalCrossProjectDependencyStep1.heading&program=emxProjectSpace:getExternalProjects&HelpMarker=emxhelpprojectcopypage2&suiteKey=ProgramCentral&SuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource&emxSuiteDirectory=programcentral";
  		strURL = strURL + "&customize=false";
  		strURL = strURL + "&projectId=" + XSSUtil.encodeForURL(context,strProjectId);
  		strURL = strURL + "&rowGrouping=false";
  		strURL = strURL + "&Export=false";
  		strURL = strURL + "&multiColumnSort=false";
  		strURL = strURL + "&showPageURLIcon=false";
  		strURL = strURL + "&displayView=details";
  		strURL = strURL + "&showClipboard=false";
  		strURL = strURL + "&objectCompare=false";
  		strURL = strURL + "&massUpdate=false";
  		strURL = strURL + "&findMxLink=false";
  		strURL = strURL + "&PrinterFriendly=false";
  		strURL = strURL + "&autoFilter=false";
  	    strURL = strURL + "&triggerValidation=false";
   	    strURL = strURL + "&massPromoteDemote=false";
   	    strURL = strURL + "&externalDependency=true";
   	    strURL = strURL + "&submitLabel=emxProgramCentral.Button.Next";
  		strURL = strURL + "&submitURL=../programcentral/emxProgramCentralUtil.jsp";
  		strURL = strURL + "&mode=addExternalTasks";
  		strURL = strURL + "&selectedTaskId=" + XSSUtil.encodeForURL(context,selectedTaskId);
  		strURL = strURL + "&showRMB=false";
  %>
      <script language="javascript">
    <%-- XSSOK--%>
   var strUrl = "<%=strURL%>";
     var externalTaskDependencies = findFrame(getTopWindow(),"PMCAddExternalProjectTaskDependencies");
     externalTaskDependencies.location.href = strUrl;
          
       </script> 
<%
  	}
	
	else if ("addExternalTasks".equalsIgnoreCase(strMode)) 
  	{
  		String selectedTaskId = emxGetParameter(request, "selectedTaskId");
  		selectedTaskId = XSSUtil.encodeURLForServer(context, selectedTaskId);
  		String[] projectIds = emxGetParameterValues(request, "emxTableRowId"); 
  		String projectId = "";
  		
  		  if(projectIds!=null) {
  		  for(int i=0;i<projectIds.length;i++){
            StringList slTemp = FrameworkUtil.split(projectIds[i].substring( (projectIds[i].indexOf("|"))+1 ),"|");
          	projectId = (String)slTemp.get(0); 
  			}
  		}
  		  
  	     if( projectIds == null){
         	%>
          	<script language="javascript" type="text/javaScript">
         	alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Project.SelectProject</emxUtil:i18nScript>");
         	</script>
         	<%
         	return;
         }
  		  
  	
  		String strURL = "../common/emxIndentedTable.jsp?table=PMCAddTaskDependencyTable&freezePane=Name&selection=multiple&header=emxProgramCentral.Dependency.AssignWBSTaskDependency&toolbar=PMCAddTaskDependenciesActionToolbar&HelpMarker=emxhelpdependencyadddialog&suiteKey=ProgramCentral&expandProgram=emxTask:getWBSIndependentTaskList&SuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource&emxSuiteDirectory=programcentral&hideRootSelection=true";
  		strURL = strURL + "&objectId=" + XSSUtil.encodeForURL(context, projectId);
  		strURL = strURL + "&selectedTaskId=" + XSSUtil.encodeForURL(context, selectedTaskId);
  		strURL = strURL + "&customize=false";
  		strURL = strURL + "&rowGrouping=false";
  		strURL = strURL + "&Export=false";
  		strURL = strURL + "&multiColumnSort=false";
  		strURL = strURL + "&showPageURLIcon=false";
  		strURL = strURL + "&displayView=details";
  		strURL = strURL + "&showClipboard=false";
  		strURL = strURL + "&objectCompare=false";
  		strURL = strURL + "&massUpdate=false";
  		strURL = strURL + "&findMxLink=false";
  		strURL = strURL + "&PrinterFriendly=false";
  		strURL = strURL + "&autoFilter=false";
  	    strURL = strURL + "&expandLevelFilter=true";
   	   	strURL = strURL + "&sortColumnName=ID";
   	    strURL = strURL + "&uiType=structureBrowser";
   	    strURL = strURL + "&mode=refreshWBS";
   	   
  		
  %>
      <script language="javascript">
    <%-- XSSOK--%>
    var strUrl = "<%=strURL%>";  
      window.parent.location.href = strUrl;
       </script>  
<%
  	    
  	}
	else if("cloneAsDeliverableTemplate".equalsIgnoreCase(strMode))
	{
		String selectedDeliverableId = emxGetParameter(request, "objectId");
		DeliverableIntent.saveAsDeliverableTemplate(context, selectedDeliverableId);		
		%>	      
		<script language="javascript" type="text/javaScript">
		alert("Saved as Deliverable Template");
	    </script>
	    <%  
	}
	else if("deleteDeliverableTemplate".equalsIgnoreCase(strMode))
	{
		String[] deliverableTemplateIds = emxGetParameterValues(request,"emxTableRowId");
		String sObjId = "";
		String sTempRowId = "";
		String partialXML = "";
		String[] strObjectIDArr    = new String[deliverableTemplateIds.length];
		for(int i=0; i<deliverableTemplateIds.length; i++)
		{
			String sTempObj = deliverableTemplateIds[i];
			Map mParsedObject = ProgramCentralUtil.parseTableRowId(context,sTempObj);
			sObjId = (String)mParsedObject.get("objectId");
			strObjectIDArr[i] = sObjId;
			sTempRowId = (String)mParsedObject.get("rowId");
			partialXML += "<item id=\"" + XSSUtil.encodeForURL(context, sTempRowId) + "\" />";		
		}
		DomainObject.deleteObjects(context,strObjectIDArr) ;
		String xmlMessage = "<mxRoot>";
		String message = "";
		xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
		xmlMessage += partialXML;
		xmlMessage += "<message><![CDATA[" + message + "]]></message>";
		xmlMessage += "</mxRoot>";
		 %>
		 <script type="text/javascript" language="JavaScript">
	  <%-- XSSOK--%>
	 window.parent.removedeletedRows('<%= xmlMessage %>');
         window.parent.closeWindow();
         </script>
		 <% 	
	}
	else if("deleteDeliverable".equalsIgnoreCase(strMode))
	{
		String[] deliverableIds = emxGetParameterValues(request,"emxTableRowId");
		String strDeliverableId = "";
		String sTempRowId = ProgramCentralConstants.EMPTY_STRING;
		String partialXML = ProgramCentralConstants.EMPTY_STRING;
		String[] strObjectIDArr    = new String[deliverableIds.length];
		for(int i = 0; i < deliverableIds.length; i++)
		{
			String sTempObj = deliverableIds[i];
			Map mParsedObject = ProgramCentralUtil.parseTableRowId(context,sTempObj);
			strDeliverableId = (String)mParsedObject.get("objectId");
			DomainObject dmoObject = DomainObject.newInstance(context,strDeliverableId);
		    String strPrjObjId = dmoObject.getInfo(context, "from[Governing Project].to.id");
		    if(strPrjObjId != null)
		    {
		    	ProjectSpace project = new ProjectSpace(strPrjObjId);     
		     	((BusinessObject)project).remove(context);
		    }
			strObjectIDArr[i] = strDeliverableId;
			sTempRowId = (String)mParsedObject.get("rowId");
			partialXML += "<item id=\"" + XSSUtil.encodeForURL(context, sTempRowId) + "\" />";		
		}
		DomainObject.deleteObjects(context,strObjectIDArr) ;
		String xmlMessage = "<mxRoot>";
		String message = ProgramCentralConstants.EMPTY_STRING;
		xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
		xmlMessage += partialXML;
		xmlMessage += "<message><![CDATA[" + message + "]]></message>";
		xmlMessage += "</mxRoot>";
		 %>
		 <script type="text/javascript" language="JavaScript">
	  <%-- XSSOK--%>
	 window.parent.removedeletedRows('<%= xmlMessage %>');
         window.parent.closeWindow();
         </script>
		 <%
	}
	else if ("isPortalMode".equalsIgnoreCase(strMode)) 	{
	
		boolean isModifyOp = false;
		String selectedTaskid = DomainObject.EMPTY_STRING;
		sLanguage = request.getHeader("Accept-Language");
		projectType = DomainConstants.TYPE_PROJECT_SPACE;
		String projectTemplateType = DomainConstants.TYPE_PROJECT_TEMPLATE;
		String projectConceptType= DomainConstants.TYPE_PROJECT_CONCEPT;
		
		String selectedids[] = request.getParameterValues("emxTableRowId");
		StringList slIds = com.matrixone.apps.domain.util.FrameworkUtil.split(selectedids[0], "|");
	
		Map <String,String>selectedRowIdMap = ProgramCentralUtil.parseTableRowId(context,selectedids[0]);
		selectedTaskid = selectedRowIdMap.get("objectId");
		String strRowLevel = selectedRowIdMap.get("rowId");
		
		if(selectedTaskid == "" || selectedTaskid == null){
			selectedTaskid = (String) slIds.get(0);
			isModifyOp = true;
		}
			
		
		DomainObject selectedObj = new DomainObject(selectedTaskid);
		
		String selectedTaskStates = selectedObj.getCurrentState(context).getName();
		String taskPolicy = selectedObj.getDefaultPolicy(context,projectType);
	    String completeState     = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Complete");
	    String reviewState       = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Review");
	    String activeState       = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Active");
			
	    StringList slSelectable = new StringList();
	    slSelectable.add(ProgramCentralConstants.SELECT_KINDOF_PROJECT_SPACE);
	    slSelectable.add(ProgramCentralConstants.SELECT_KINDOF_PROJECT_TEMPLATE);
	    slSelectable.add(ProgramCentralConstants.SELECT_KINDOF_PROJECT_CONCEPT);
	    slSelectable.add(SELECT_SHADOW_GATE_ID);
	    
	    Map <String,String>objectInfoMap = selectedObj.getInfo(context,slSelectable);
	    String isProjectSpace = objectInfoMap.get(ProgramCentralConstants.SELECT_KINDOF_PROJECT_SPACE);
	    String isProjectTemplate = objectInfoMap.get(ProgramCentralConstants.SELECT_KINDOF_PROJECT_TEMPLATE);
	    String isProjectConcept = objectInfoMap.get(ProgramCentralConstants.SELECT_KINDOF_PROJECT_CONCEPT);
	    String strShadowGateId = objectInfoMap.get(SELECT_SHADOW_GATE_ID);

        if(strShadowGateId != null && !strShadowGateId.equals("")){
			 %>
			 <script language="javascript" type="text/javaScript">
			 alert("<framework:i18nScript localize="i18nId">emxProgramCentral.DeliverablePlanning.CannnotAddDependency</framework:i18nScript>");
			 </script>
			 <%
			 return;
        }

	 	if(strRowLevel.equals("0") && ("TRUE".equalsIgnoreCase(isProjectSpace) || "TRUE".equalsIgnoreCase(isProjectTemplate) || "TRUE".equalsIgnoreCase(isProjectConcept))){
				 %>
				 <script language="javascript" type="text/javaScript">
					 alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Alert.CannotPerform</framework:i18nScript>");
				 </script>
				 <%
				 return;
		}
		
		if(selectedTaskStates.equals(completeState) || selectedTaskStates.equals(reviewState) ){
			%>
                   <script language="javascript" type="text/javaScript">
                    var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState1</framework:i18nScript>" +
                     " <%=i18nNow.getStateI18NString(taskPolicy,activeState,sLanguage)%> " +
                     "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState2</framework:i18nScript>";
                    alert ( msg );
      	            </script>
     	             <%
     	         return;
                }

	     if(selectedObj.hasRelatedObjects(context,DomainConstants.RELATIONSHIP_DELETED_SUBTASK,false)){
	    	 %>
	           <script language="javascript" type="text/javaScript">
	           alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.TaskHasBeenMarkedForDeletion</framework:i18nScript>");
	           </script>
	           <%
	           return;
          }
		    
		String strURL = "../common/emxPortal.jsp?portal=PMCWBSTaskDependencyPortal&showPageHeader=false";
		
		if(ProgramCentralUtil.isNotNullString(objId) && !isModifyOp){
			DomainObject task = DomainObject.newInstance(context,selectedTaskid);
			if(strRowLevel.equals("0") && task.isKindOf(context,DomainObject.TYPE_TASK_MANAGEMENT)){
	  			String projectId = task.getInfo(context, ProgramCentralConstants.SELECT_TASK_PROJECT_ID);			
				strURL = strURL + "&projectId=" + XSSUtil.encodeForURL(context, projectId);
			}else{
				strURL = strURL + "&projectId=" + XSSUtil.encodeForURL(context, objId);
			}
		}else{
			DomainObject task = DomainObject.newInstance(context,selectedTaskid);
	  		String projectId = task.getInfo(context, ProgramCentralConstants.SELECT_TASK_PROJECT_ID);
	  		
	  		strURL = strURL + "&projectId=" + XSSUtil.encodeForURL(context, projectId);
	  		}
		
		strURL = strURL + "&objectId=" + XSSUtil.encodeForURL(context, selectedTaskid);
			
%>
  	  <script language="javascript">
    <%-- XSSOK--%>
	   var strUrl = "<%=strURL%>";  
  	   showModalDialog(strUrl,1000,1000);
  	   </script> 
 <%
  	}
	else if ("addPerson".equals(strMode)) {
		String parentOID = emxGetParameter( request, "parentOID");
		parentOID = XSSUtil.encodeURLForServer(context, parentOID);
		String url="../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=state_Active:USERROLE=External Project User,Project User&table=PMCCommonPersonSearchTable&mode=addMember&form=PMCCommonPersonSearchForm&selection=multiple&excludeOIDprogram=emxCommonPersonSearch:getMembersIdsToExclude&submitAction=refreshCaller&submitURL=../programcentral/emxProgramCentralCommonPersonSearchUtil.jsp?mode=addMember&&objectId="+XSSUtil.encodeForURL(context, objId)+"&parentOID="+XSSUtil.encodeForURL(context, parentOID);
	
 %>
       <script language="javascript">
      <%-- XSSOK--%>
   document.location.href ='<%=url%>';
  	   </script> 
<%
}else if (ProgramCentralConstants.INSERT_EXISTING_PROJECT_ABOVE.equalsIgnoreCase(strMode)) {

		String currentFrame = XSSUtil.encodeURLForServer(context, emxGetParameter(request, "portalCmdName"));
		String tableRowIdList[] = emxGetParameterValues(request,
				"emxTableRowId");
		String levelId = ProgramCentralConstants.EMPTY_STRING;
		if (tableRowIdList != null) {
			for (int i = 0; i < tableRowIdList.length; i++) {
				StringTokenizer strtk = new StringTokenizer(
						tableRowIdList[i], "|");
				int tokens = strtk.countTokens();
				if (tokens == 2) {
					for (int j = 0; j < tokens; j++) {
						levelId = strtk.nextToken();
						if (levelId.equals("0")) {
%>
<script language="javascript">		        	  
		        	  alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.CannotInsertOnRoot</framework:i18nScript>");
		        	  getTopWindow().window.closeWindow();
	 		                 </script>
<%
							return;
						}
					}
				}
			}
		}
		String requiredTaskId = emxGetParameter(request,
				"emxTableRowId");
		Map mpRow=null;
		if (null != requiredTaskId) {

			 mpRow = ProgramCentralUtil.parseTableRowId(context,
					requiredTaskId);
			requiredTaskId = (String) mpRow.get("objectId") + "|"
					+ (String) mpRow.get("parentOId");

		}
		String strSelectedTaskObjID=(String) mpRow.get("objectId");   
		String strSelectedParentObjID=(String) mpRow.get("parentOId");   
		
		DomainObject domtaskObj = new DomainObject(strSelectedTaskObjID);    		
		String parentIdSelect = "to[" + ProgramCentralConstants.RELATIONSHIP_SUBTASK + "].from.id";
		StringList taskSelects = new StringList(2);
		taskSelects.add(ProgramCentralConstants.SELECT_CURRENT);	
		if(ProgramCentralUtil.isNullString(strSelectedParentObjID)){
			taskSelects.add(parentIdSelect);	
		}
		Map taskInfo = domtaskObj.getInfo(context, taskSelects);
		String selectedTaskStates = (String) taskInfo.get(ProgramCentralConstants.SELECT_CURRENT); 
		if(ProgramCentralUtil.isNullString(strSelectedParentObjID)){
			strSelectedParentObjID = (String) taskInfo.get(parentIdSelect);
		}
		DomainObject domParentObj = new DomainObject(strSelectedParentObjID);    		
		String strParentState = domParentObj.getCurrentState(context).getName();
		String parentPolicy = domParentObj.getDefaultPolicy(context,projectType);
		boolean allowParentInsert = false;
		if (strParentState.equalsIgnoreCase(DomainObject.STATE_PROJECT_SPACE_COMPLETE) || strParentState.equalsIgnoreCase(DomainObject.STATE_PROJECT_SPACE_REVIEW))
        {
			if(selectedTaskStates.equalsIgnoreCase(ProgramCentralConstants.STATE_PROJECT_TASK_COMPLETE) || selectedTaskStates.equalsIgnoreCase(ProgramCentralConstants.STATE_PROJECT_TASK_REVIEW) ){
		
			%>
                 <script language="javascript" type="text/javaScript">   
                 var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState</framework:i18nScript>" ;                                                
                 alert ( msg );
                 window.closeWindow();
                 </script>
     	    <%
			}else{
				allowParentInsert=true;					
           		}
     	         return;
        }else{
        		allowParentInsert=true;				
        }
		if(allowParentInsert)
		{
		String strURL = "../common/emxFullSearch.jsp?field=TYPES=type_ProjectSpace,type_ProjectConcept&table=PMCProjectSummaryForProjects&selection=multiple&toolbar=&editLink=true&submitURL=../programcentral/emxprojectCreateWizardAction.jsp&fromProgram=null&fromWBS=false&fromAction=false&wizType=AddExistingSubtaskProject&addType=Sibling&copyExistingSearchShowSubTypes=true&pageName=fromAddExistingSubProject&p_button=Next&fromSubProjects=true&calledMethod=submitInsertProject&PMCWBSQuickTaskTypeToAddBelow=Task&portalMode=true&copyExistingProjectType=type_ProjectManagement&fromClone=null&wbsForm=false&insertExistingProjectAboveMode=insertExistingProjectAbove&excludeOIDprogram=emxTask:excludeProjectsfromAddExisting&suiteKey=ProgramCentral&HelpMarker=emxhelpinsertprojectsastasks";
		strURL = strURL + "&objectId=" + XSSUtil.encodeForURL(context, objId) + "&requiredTaskId="+ XSSUtil.encodeForURL(context, requiredTaskId) + "&parentProjectId=" + XSSUtil.encodeForURL(context, objId) + "&portalCmdName="+currentFrame;
%>
   <script language="javascript">
  <%-- XSSOK--%>
	var strUrl ="<%=strURL%>";    	  	 
  	 //window.parent.location.href = strUrl;
  	 showModalDialog(strUrl,1000,1000);
  	   </script> 
  
 <%
    	}
		
    }else if (ProgramCentralConstants.INSERT_EXISTING_PROJECT_BELOW.equalsIgnoreCase(strMode)) {
    	
    		String currentFrame = XSSUtil.encodeURLForServer(context, emxGetParameter(request, "portalCmdName"));
    		Map mpRow =null;
    		String selectedTaskid = DomainObject.EMPTY_STRING;
    		String requiredTaskId = emxGetParameter(request,
    				"emxTableRowId");
    		if (null != requiredTaskId) {

    			mpRow = ProgramCentralUtil.parseTableRowId(context,
    					requiredTaskId);
    			requiredTaskId = (String) mpRow.get("objectId") + "|" + (String) mpRow.get("parentOId");
    		}
    		String strSelectedObjID=(String) mpRow.get("objectId");   
    		
    		DomainObject selectedObj = new DomainObject(strSelectedObjID);    		
            StringList selectList = new StringList(2);
            selectList.add(DomainObject.SELECT_CURRENT);
            selectList.add(SELECT_SHADOW_GATE_ID);

            Map taskInfo = selectedObj.getInfo(context, selectList);
            String selectedTaskStates = (String)taskInfo.get(DomainObject.SELECT_CURRENT);
    		String sShadowGateId = (String)taskInfo.get(SELECT_SHADOW_GATE_ID);

    		if(sShadowGateId != null && !sShadowGateId.equals("")){
    			%>
    	    	   <script language="javascript" type="text/javaScript">
                   var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.DeliverablePlanning.CannnotAddSubProject</framework:i18nScript>" ;                                                
                   alert ( msg );
                   window.close();
    	           </script>
    	    	<%
    	    	  return;
    		}

    	    if(selectedTaskStates.equalsIgnoreCase(ProgramCentralConstants.STATE_PROJECT_TASK_COMPLETE) || selectedTaskStates.equalsIgnoreCase(ProgramCentralConstants.STATE_PROJECT_TASK_REVIEW) ){
    			%>
                     <script language="javascript" type="text/javaScript">   
                     var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState</framework:i18nScript>" ;                                                
                     alert ( msg );
                     window.closeWindow();
                     </script>
         	    <%
         	         return;
                    }else{
    		String strURL = "../common/emxFullSearch.jsp?field=TYPES=type_ProjectSpace,type_ProjectConcept&table=PMCProjectSummaryForProjects&selection=multiple&toolbar=&editLink=true&submitURL=../programcentral/emxprojectCreateWizardAction.jsp&fromProgram=null&fromWBS=false&fromAction=false&wizType=AddExistingSubtaskProject&addType=Child&copyExistingSearchShowSubTypes=true&pageName=fromAddExistingSubProject&p_button=Next&fromSubProjects=true&calledMethod=submitAddProject&PMCWBSQuickTaskTypeToAddBelow=Task&portalMode=true&copyExistingProjectType=type_ProjectManagement&fromClone=false&wbsForm=false&insertExistingProjectBelowMode=insertExistingProjectBelow&excludeOIDprogram=emxTask:excludeProjectsfromAddExisting&suiteKey=ProgramCentral&HelpMarker=emxhelpinsertprojectsastasks";
    		strURL = strURL + "&objectId=" + XSSUtil.encodeForURL(context, objId) + "&requiredTaskId=" + XSSUtil.encodeForURL(context, requiredTaskId) + "&parentProjectId=" + XSSUtil.encodeForURL(context, objId)+ "&portalCmdName="+currentFrame;
%> 
	 <script language="javascript">
  <%-- XSSOK--%>
	var strUrl ="<%=strURL%>";    	  	 
  	 //window.parent.location.href = strUrl;
  	 showModalDialog(strUrl,1000,1000);
  	   </script> 
<%
    	}

    	}

    	else if (ProgramCentralConstants.ADD_EXISTING_RELATED_PROJECTS.equalsIgnoreCase(strMode)) {
    		
    		String strURL = "../common/emxFullSearch.jsp?field=TYPES=type_ProjectSpace,type_ProjectConcept&table=PMCProjectSummaryForProjects&selection=multiple&toolbar=&editLink=true&submitURL=../programcentral/emxprojectCreateWizardAction.jsp&fromProgram=null&fromWBS=false&fromAction=false&wizType=AddExistingRelProject&addType=Child&copyExistingSearchShowSubTypes=true&pageName=fromAddExistingRelProject&p_button=Next&fromRelatedProjects=true&copyExistingProjectType=type_ProjectManagement&fromClone=false&wbsForm=false&addRelatedProjectMode=addRelatedProjectMode&excludeOIDprogram=emxProjectSpace:excludeRelatedProjectsforAddExisting";
    		strURL = strURL + "&objectId=" + XSSUtil.encodeForURL(context, objId) + "&parentOID=" + XSSUtil.encodeForURL(context, objId)+ "&parentProjectId="+XSSUtil.encodeForURL(context, objId);
%> 
	 <script language="javascript">
  <%-- XSSOK--%>
	  var strUrl ="<%=strURL%>";    	  	 
  	 window.parent.location.href = strUrl;
  	 
  	   </script> 

<%
 	}
    	else if("deletequestion".equals(strMode)) {
    		String[] questionIds = emxGetParameterValues(request,"emxTableRowId");
    		String sObjId = "";
    		String sTempRowId = "";
    		String partialXML = "";
    		String[] strObjectIDArr    = new String[questionIds.length];
    		for(int i=0; i<questionIds.length; i++)
    		{
    			String sTempObj = questionIds[i];
				Map mParsedObject = ProgramCentralUtil.parseTableRowId(context,sTempObj);
				sObjId = (String)mParsedObject.get("objectId");
				strObjectIDArr[i] = sObjId;
				sTempRowId = (String)mParsedObject.get("rowId");
				partialXML += "<item id=\"" + XSSUtil.encodeForURL(context, sTempRowId) + "\" />";		
    		}
    		DomainObject.deleteObjects(context,strObjectIDArr) ;
    		String xmlMessage = "<mxRoot>";
    		String message = "";
    		xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
    		xmlMessage += partialXML;
    		xmlMessage += "<message><![CDATA[" + message + "]]></message>";
    		xmlMessage += "</mxRoot>";
    		 %>
    		 <script type="text/javascript" language="JavaScript">
      <%-- XSSOK--%>
		 window.parent.removedeletedRows('<%= xmlMessage %>');
             window.parent.closeWindow();
             </script>
    		 <% 
    		
    	}
    	else if("deletequestionset".equals(strMode)) {
    		String[] questionsetIds = emxGetParameterValues(request,"emxTableRowId");
    		String sObjId = "";
    		String sTempRowId = "";
    		String partialXML = "";
    		String[] strObjectIDArr    = new String[questionsetIds.length];
    		for(int i=0; i<questionsetIds.length; i++)
    		{
    			String sTempObj = questionsetIds[i];
				Map mParsedObject = ProgramCentralUtil.parseTableRowId(context,sTempObj);
				sObjId = (String)mParsedObject.get("objectId");
				strObjectIDArr[i] = sObjId;
				sTempRowId = (String)mParsedObject.get("rowId");
				partialXML += "<item id=\"" + XSSUtil.encodeForURL(context, sTempRowId) + "\" />";		
    		}
    		DomainObject.deleteObjects(context,strObjectIDArr) ;
    		String xmlMessage = "<mxRoot>";
    		String message = "";
    		xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
    		xmlMessage += partialXML;
    		xmlMessage += "<message><![CDATA[" + message + "]]></message>";
    		xmlMessage += "</mxRoot>";
    		 %>
    		 <script type="text/javascript" language="JavaScript">
      <%-- XSSOK--%>
		 window.parent.removedeletedRows('<%= xmlMessage %>');
             window.parent.closeWindow();
             </script>
    		 <% 
    		
    	}
    	else if ("clearAll".equalsIgnoreCase(strMode)) 	{ 	
%>
    	<script language="javascript">
    	parent.document.location.href = parent.document.location.href;
        </script> 
<%   	  
    	}
    	else if("deletedelivers".equals(strMode)) {
    		String[] deliversIds = emxGetParameterValues(request,"emxTableRowId");
    		String sObjId = ProgramCentralConstants.EMPTY_STRING;
    		String sRelId = ProgramCentralConstants.EMPTY_STRING;
    		String sTempRowId = ProgramCentralConstants.EMPTY_STRING;
    		String partialXML = ProgramCentralConstants.EMPTY_STRING;
    		String[] strObjectIDArr  = new String[deliversIds.length];
    		String[] strRelIdArr     = new String[deliversIds.length];
    		for(int i=0; i<deliversIds.length; i++)
    		{
    			String sTempObj = deliversIds[i];
				Map mParsedObject = ProgramCentralUtil.parseTableRowId(context,sTempObj);
				sObjId = (String)mParsedObject.get("objectId");
				sRelId = (String)mParsedObject.get("relId");
				strObjectIDArr[i] = sObjId;
				strRelIdArr[i] = sRelId;
				sTempRowId = (String)mParsedObject.get("rowId");
				partialXML += "<item id=\"" + XSSUtil.encodeForURL(context, sTempRowId) + "\" />";		
    		}
    		DomainRelationship.disconnect(context,strRelIdArr);
            //DomainObject.deleteObjects(context,strObjectIDArr) ; 
    		String xmlMessage = "<mxRoot>";
    		String message = "";
    		xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
    		xmlMessage += partialXML;
    		xmlMessage += "<message><![CDATA[" + message + "]]></message>";
    		xmlMessage += "</mxRoot>";
    		 %>
    		 <script type="text/javascript" language="JavaScript">
    	  <%-- XSSOK--%>
	 window.parent.removedeletedRows('<%= xmlMessage %>');
             window.parent.closeWindow();
             </script>
    		 <%     		
    	}
    	else if("AddDelivers".equalsIgnoreCase(strMode)) {
        	String DeliversID = DomainObject.EMPTY_STRING;
        	String sObjIDToConnect = DomainObject.EMPTY_STRING;
        	String sDeliverIntentObjId = DomainObject.EMPTY_STRING;
        	String sTableRowId[] = emxGetParameterValues( request, "emxTableRowId" );
        	StringList slObjIDToConnect = new StringList();
			for(int i=0; i<sTableRowId.length; i++){
				String sTempObj = sTableRowId[i];
				Map mParsedObject = ProgramCentralUtil.parseTableRowId(context,sTempObj);
				slObjIDToConnect.add(mParsedObject.get("objectId").toString());
				sDeliverIntentObjId = (String)mParsedObject.get("parentOId");
			}
			try {
				DeliverableIntent.connectDelivers(context, sDeliverIntentObjId, slObjIDToConnect);
			}
			catch(Exception e) {
				e.printStackTrace();
			}			
			%>
			<script language="javascript" type="text/javaScript">				
				 getTopWindow().window.getWindowOpener().location.href=getTopWindow().window.getWindowOpener().location.href;
				 getTopWindow().window.closeWindow();										
			</script>
			<% 
		}
    	else if("SearchDelivers".equalsIgnoreCase(strMode)) {
    		String targetSearchPage = DomainConstants.EMPTY_STRING;
    		String objectId = emxGetParameter( request, "objectId");    		
    		targetSearchPage = "../common/emxFullSearch.jsp?table=PMCDeliverableSearchSummary&cancelLabel=emxProgramCentral.Common.Close&suiteKey=ProgramCentral&selection=multiple&excludeOIDprogram=emxDeliverable:getExcludeOIDForDelivers&objectId="+XSSUtil.encodeForURL(context,objectId)+"&submitURL=../programcentral/emxProgramCentralUtil.jsp?mode=AddDelivers";
			%>
			<script language="javascript" type="text/javaScript">				
		  <%-- XSSOK--%>
		var strUrl ="<%=targetSearchPage%>";
				document.location.href = strUrl;      	   		
			</script>
			<% 
		}
    	else if ("submitResourceRequest".equalsIgnoreCase(strMode)){
    		String sErrMsg  = "";
    		String selectedids[] = request.getParameterValues("emxTableRowId");
    		StringList requestIdList = new StringList();
    		boolean isInvalidRequest = false;
    		String strLanguage = context.getSession().getLanguage();
    		//Extarct all request ids from selected ids.
    		for(String selectedId : selectedids){
    			StringList selectedIdList = FrameworkUtil.split(selectedId, "|");
    			if(selectedIdList.size() >=4){
    				String requestId = (String) selectedIdList.get(1);
    				requestIdList.add(requestId);								
    			}			
    		}
    		if(!requestIdList.isEmpty()){
    	   		//Get all request ids in an array from stringlist
        		String[] requestIdArray = new String[requestIdList.size()];
        		requestIdList.toArray(requestIdArray);
        		
        		//Get Types of all the ids in one shot.
        		StringList slSelectable = new StringList();
				String SELECT_REL_ATTRIBUTE_FTE = "to["+ DomainConstants.RELATIONSHIP_RESOURCE_PLAN+ "].attribute["+ DomainConstants.ATTRIBUTE_FTE + "]";
				slSelectable.add(ProgramCentralConstants.SELECT_ID);
				slSelectable.add(ProgramCentralConstants.SELECT_TYPE);
        		slSelectable.add(ProgramCentralConstants.SELECT_CURRENT);
        		slSelectable.add(SELECT_REL_ATTRIBUTE_FTE);
        		
        		MapList infoMapList = DomainObject.getInfo(context, requestIdArray, slSelectable);
        		java.util.Iterator itrInfoMapList = infoMapList.iterator();
        		
        		//Check if selected is a Resource Request that too in Create state or Rejected states with valid FTE.
        		while(itrInfoMapList.hasNext()){
        			Map objectInfoMap = (Map)itrInfoMapList.next();
        			String resourceRequestId = (String)objectInfoMap.get(ProgramCentralConstants.SELECT_ID);
        			String type = (String)objectInfoMap.get(ProgramCentralConstants.SELECT_TYPE);
                	String state = (String)objectInfoMap.get(ProgramCentralConstants.SELECT_CURRENT);
        			String sFTE = (String)objectInfoMap.get(SELECT_REL_ATTRIBUTE_FTE);
					
        			//Check if selected object is Resource Request
        			if(!ProgramCentralConstants.TYPE_RESOURCE_REQUEST.equals(type)){
        				sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.SelectResourceRequest", strLanguage); 
        				isInvalidRequest = true;
        				break;		
        			}
        			//Check if selected Resource Request is in Create or Rejected state
        			else if(!ProgramCentralConstants.STATE_RESOURCE_REQUEST_CREATE.equals(state) && !ProgramCentralConstants.STATE_RESOURCE_REQUEST_REJECTED.equals(state)){
        				sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.DoNotSelectRequestedRequest", strLanguage);
        				isInvalidRequest = true;
        				break;
        			}
        			
        			//Check if selected Resource Request is in Create and it is connected to a valid resource pool
        			if(ProgramCentralConstants.STATE_RESOURCE_REQUEST_CREATE.equals(state)){
        				String[] arrRequestId = {resourceRequestId};
        				sErrMsg = ResourceRequest.triggerCheckResourcePoolMessage(context, arrRequestId);
        				if(ProgramCentralUtil.isNotNullString(sErrMsg)){
        					isInvalidRequest = true;
            				break;        				
            			}
        			}
        			//Check if Request FTE is not zero
        			FTE oFTE = FTE.getInstance(context);
					if (ProgramCentralUtil.isNotNullString(sFTE)){
						oFTE = FTE.getInstance(context, sFTE);
					}
					Map mapFTEValues = null;
					mapFTEValues = oFTE.getAllFTE();
					boolean isValidFTE = false;
					int count = 0;
					if (null != mapFTEValues && !"null".equals(mapFTEValues) && !"".equals(mapFTEValues)){
						for (Iterator iter = mapFTEValues.keySet().iterator(); iter.hasNext();){
							String strTimeFrame = (String) iter.next();
							Double dFTEValue = 0D;
							dFTEValue = (Double) mapFTEValues.get(strTimeFrame);
							if (dFTEValue <= 0){
								count++;
							}
						}
							if(mapFTEValues.size()==count){
								isInvalidRequest = true;
								sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.InvalidRequestForSubmission", strLanguage);
								break;
							}
						}
					}
    		}else{
    			sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.SelectResourceRequest", strLanguage);
    			isInvalidRequest = true;
    		} 
    		if(isInvalidRequest){
				%>
				<script language="javascript" type="text/javaScript">
				alert("<%= sErrMsg%>" );
				</script>
				<%
				return;
    		}else{
    			String strURL = "../common/emxForm.jsp?form=PMCResourceRequestSubmitForm&mode=edit&formHeader=emxProgramCentral.ResourcePlan.HeaderForSubmition&suiteKey=ProgramCentral&SuiteDirectory=programcentral&postProcessURL=../programcentral/emxProgramCentralResourceRequestUtil.jsp&submitAction=doNothing&submode=SubmitRequestComment&toolbar=null&HelpMarker=emxhelpresourcerequestsubmitcomment";
				strURL += "&objectId=" + requestIdList.get(0);
				String rowIds = "";
				for(int index=0; index<requestIdList.size(); index++){
					String nextId = (String) requestIdList.get(index);
					if(index == 0){
						rowIds += XSSUtil.encodeForURL(context, nextId);
					}else{
						rowIds += "," + XSSUtil.encodeForURL(context, nextId);	
					}
				}
				strURL += "&rowIds=" + XSSUtil.encodeForURL(context, rowIds);
				%>
				<script language="javascript" type="text/javaScript">
	  <%-- XSSOK--%>
		  	   var url = "<%=strURL%>";  
			  	 getTopWindow().showSlideInDialog(url,false);
				</script>
				<%
    		}
    	} else if("createSnapshot".equalsIgnoreCase(strMode))
     {
    		String objectId = (String) emxGetParameter(request, "objectId");
   	  if(ProgramCentralUtil.isNotNullString(objectId)){
   		  String sPlanId = com.matrixone.apps.program.ProjectSpace.getGoverningProjectPlanId(context,objectId);
   		     //DomainObject dmnProjectPlanId = DomainObject.newInstance(context,sPlanId);
   		     if(!ProgramCentralUtil.isNullString(sPlanId))
   		     {
   		    	 com.matrixone.apps.program.ProjectSpace projectSpace = new com.matrixone.apps.program.ProjectSpace(sPlanId);
   		    	 com.matrixone.apps.program.ProjectSnapshot snapshot = new com.matrixone.apps.program.ProjectSnapshot(projectSpace);
   		    	 String sSnapshotId =  "";
   		    	 Map mapObjInfo = new HashMap();
   		    	 final String SELECT_RELATIONSHIP_RELATED_PROJECTS = "to["+ProgramCentralConstants.RELATIONSHIP_RELATED_PROJECTS+"].id";
   		         final String SELECT_TYPE_RELATED_PROJECTS = "to["+ProgramCentralConstants.RELATIONSHIP_RELATED_PROJECTS+"].from.id";
   		         
   		    	 StringList slObjSelect = new StringList();
   		    	 slObjSelect.add(ProgramCentralConstants.SELECT_ID);
   		    	 slObjSelect.add(SELECT_RELATIONSHIP_RELATED_PROJECTS);
   		    	 slObjSelect.add(SELECT_TYPE_RELATED_PROJECTS);
   		    	 
   		    	 try{
   		    	com.matrixone.apps.program.ProjectSnapshot dmoSnapshotObj = snapshot.create(context);
   		    	mapObjInfo = dmoSnapshotObj.getInfo(context,slObjSelect);
   		    	 }catch(Exception e){
   		    		 throw new MatrixException(e);
   		    	 }
   		       		  
   		  /*  sSnapshotId =  (String)mapObjInfo.get(ProgramCentralConstants.SELECT_ID);
   		   String strRelId =  (String)mapObjInfo.get(SELECT_RELATIONSHIP_RELATED_PROJECTS);
   		   String strParentId =  (String)mapObjInfo.get(SELECT_TYPE_RELATED_PROJECTS);
   		   String pasteBelowToRow = "0,1"; 
   		    StringBuffer partialXML   =   new StringBuffer();
   		    partialXML.append("<item oid=\"" + sSnapshotId); 
               partialXML.append("\" relId=\"" + strRelId);
               partialXML.append("\" pid=\"" + strParentId); 
               partialXML.append("\" direction=\"\" pasteBelowToRow=\"" + pasteBelowToRow + "\" />");
               //boolean isFromRMB = "true".equalsIgnoreCase((String)requestMap.get("isFromRMB"));
               String fromRMB = "false";
               
                String xmlMessage = "<mxRoot>" +"<action><![CDATA[add]]></action>" + "<data status=\"committed\" fromRMB=\"" + fromRMB + "\"" + " >";
                xmlMessage += partialXML.toString();
                xmlMessage += "</data></mxRoot>";
               */
   %>  
    <script language="javascript" type="text/javaScript">
     var topFrame = findFrame(getTopWindow(), "PMCProjectSnapshots");
    	if(topFrame != null)
    	{
    		topFrame.location.href = topFrame.location.href;
    	}
    </script>
   <%
   	}
   	  }
     }else if("deleteSnapshot".equalsIgnoreCase(strMode)){
    	 String objectId = (String) emxGetParameter(request, "objectId");
   	  if(ProgramCentralUtil.isNotNullString(objectId)){
   		  ProjectSnapshot dmoSnapshot = (ProjectSnapshot)ProjectSnapshot.newInstance(context, ProgramCentralConstants.TYPE_PROJECT_SNAPSHOT,ProgramCentralConstants.PROGRAM);
   		  dmoSnapshot.setId(objectId);
   		  dmoSnapshot.delete(context);
   	   %>  
   	<script language="javascript" type="text/javaScript">
   		var topFrame = findFrame(getTopWindow(), "PMCProjectSnapshots");
   		if(topFrame != null)
   		{
    	 		topFrame.location.href = topFrame.location.href; 
    	 	}
   	</script>
   <%
   	}
     }else if("compareWBS".equalsIgnoreCase(strMode)){
 	    String strSelectedTaskRowId = request.getParameter("emxTableRowId");
	    
 		Map mapRowId = (Map)ProgramCentralUtil.parseTableRowId(context,strSelectedTaskRowId);
 		String sParentId = (String)mapRowId.get("parentOId");
 		String sChildId = (String)mapRowId.get("objectId");
 		
 		if(ProgramCentralUtil.isNotNullString(sParentId)){
 	contentURL = "../common/emxIndentedTable.jsp?table=PMCWhatIfCompareViewTable&showRMB=false&expandProgram=emxWhatIf:getExperimentWBSSubtasks&reportType=Complete_Summary_Report&IsStructureCompare=TRUE&expandLevel=0&connectionProgram=emxWhatIf:updateMasterProject&resequenceRelationship=relationship_Subtask&refreshTableContent=true&objectId=";
 	contentURL += sChildId +","+ XSSUtil.encodeForURL(context, sParentId);
 	contentURL += "&ParentobjectId="+XSSUtil.encodeForURL(context, sParentId)+"&objectId1="+XSSUtil.encodeForURL(context, sChildId)+"&objectId2="+XSSUtil.encodeForURL(context, sParentId);
 	contentURL += "&compareBy=Name,Dependency,ConstraintType,Constraint Date,PhaseEstimatedDuration,PhaseEstimatedStartDate,PhaseEstimatedEndDate,Description&objectCompare=false&showClipboard=false&customize=false&rowGrouping=false&inlineIcons=false&displayView=details&syncEntireRow=true&SortDirection=ascending&SortColumnName=dupId&matchBasedOn=TaskId&selection=multiple&editRootNode=false&emxSuiteDirectory=programcentral&suiteKey=ProgramCentral&hideRootSelection=true";
 		}else {
 	String strMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
 			"emxProgramCentral.ProjectSnapshot.WBSCompareWarningMessage", context.getSession().getLanguage());
 %>
 			<script language="javascript" type="text/javaScript">
 	       		var vMsg = "<%=strMsg%>";
 	       		alert(vMsg);
 	 		</script>
 			<%
 				return;
 					}
 			%>
    		<script language="javascript">
    	  <%-- XSSOK--%>
		var url = "<%=contentURL%>";
    			var topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");	
    			topFrame.location.href = url;
    		</script>
    		<%
    			}else if("launchWBS".equalsIgnoreCase(strMode)){
    			String objectId = (String) emxGetParameter(request, "objectid");
    			session.setAttribute("ObjectId",objectId);
    			contentURL = "../common/emxIndentedTable.jsp?table=PMCWhatIfWBSViewTable&jsTreeID=null&parentOID="+XSSUtil.encodeForURL(context, objectId)+"&objectId="+XSSUtil.encodeForURL(context, objectId)+"&emxSuiteDirectory=programcentral&showRMB=false&suiteKey=ProgramCentral&HelpMarker=emxhelpwbstasklist&findMxLink=false&freezePane=Name&showPageHeader=false&header=emxProgramCentral.Common.WorkBreakdownStructureSB&editLink=false&selection=multiple&sortColumnName=ID&postProcessJPO=emxTask:postProcessRefresh&StringResourceFileId=emxProgramCentralStringResource&editRelationship=relationship_Subtask&expandProgram=emxTask:getWBSSubtasks&expandLevel=1&massPromoteDemote=false&rowGrouping=false&objectCompare=false&showClipboard=false&showPageURLIcon=false&triggerValidation=false&displayView=details&multiColumnSort=false&showRMB=false";
    		%>
 	<script language="javascript" type="text/javaScript">
   <%-- XSSOK--%>
		var url = "<%=contentURL%>";
 		var topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");	
 		topFrame.location.href = url;
 	</script>
 	<%
    	} else if("addResourceManager".equalsIgnoreCase(strMode)) {
    		
    		String[] selectedRowArray = emxGetParameterValues(request, "emxTableRowId");
    		
    		if (selectedRowArray != null && selectedRowArray.length > 0) {
	    		Map paramMap = new HashMap(2);
    			String companyId=DomainConstants.EMPTY_STRING;
    			List<String> resourceManagerIdList = new ArrayList<String>();
    			
	    		for (int i=0;i<selectedRowArray.length;i++) {
	    			StringList idList = FrameworkUtil.split(selectedRowArray[i], "|");
	    			resourceManagerIdList.add((String)idList.get(0));
	    			companyId = (String)idList.get(1);
	    		}
	    		
    			paramMap.put("objectId",companyId);
    			paramMap.put("resourceManagerIdList", resourceManagerIdList);
    			JPO.invoke(context, "emxResourcePool", null, "addResourceManagerToCompany",JPO.packArgs(paramMap));
    		}
    %>
       <script language="javascript" type="text/javaScript">
       		getTopWindow().getWindowOpener().refreshSBTable(getTopWindow().getWindowOpener().configuredTableName);
       		getTopWindow().closeWindow(); 
 		</script>
    <%		
    	} else if("removeResourceManager".equalsIgnoreCase(strMode)) {
    		
    		String[] selectedRowArray = emxGetParameterValues(request, "emxTableRowId");
    		
    		if (selectedRowArray != null && selectedRowArray.length > 0) {
	    		Map paramMap = new HashMap(2);
    			String companyId=DomainConstants.EMPTY_STRING;
    			List<String> resourceManagerIdList = new ArrayList<String>();
    			
	    		for (int i=0;i<selectedRowArray.length;i++) {
	    			StringList idList = FrameworkUtil.split(selectedRowArray[i], "|");
	    			resourceManagerIdList.add((String)idList.get(0));
	    			companyId = (String)idList.get(1);
	    		}
	    		
    			paramMap.put("objectId",companyId);
    			paramMap.put("resourceManagerIdList", resourceManagerIdList);
    			JPO.invoke(context, "emxResourcePool", null, "removeResourceManagerFromCompany",JPO.packArgs(paramMap));
    		}
    %>
       <script language="javascript" type="text/javaScript">
       		var topFrame = findFrame(getTopWindow(),"detailsDisplay");	
       		if (topFrame != null) {
	 			topFrame.location.href = topFrame.location.href;                        
	        }else{
	        	parent.location.href = parent.location.href;
	        }
 		</script>
		<% }  else if("deleteRisk".equalsIgnoreCase(strMode)){
			 		   Risk risk = (Risk) DomainObject.newInstance(context,DomainConstants.TYPE_RISK,"PROGRAM");
	 		   String[] risks = emxGetParameterValues(request,"emxTableRowId");
	 		   risks = ProgramCentralUtil.parseTableRowId(context,risks);
	 		   
	 		   if(risks != null && risks.length > 0){
	 			   for(int i=0;i<risks.length;i++){
	 				  String riskObjectId = risks[i];	 				  
	 				  risk.setId(riskObjectId);
	 				  if(risk.getInfo(context, DomainConstants.SELECT_TYPE).equalsIgnoreCase(DomainConstants.TYPE_RISK)){
			 					StringList objectSelects = new StringList();
			 			    	objectSelects.add(ProgramCentralConstants.SELECT_ID);
			 			    	StringList relationshipSelects = new StringList();
			 			    	MapList rpnList = risk.getRelatedObjects(context,
			 							DomainConstants.RELATIONSHIP_RISK_RPN,
			 							ProgramCentralConstants.TYPE_RPN,
			 							objectSelects,
			 							relationshipSelects,
			 							false,
			 							true,
			 							(short) 0,
			 							DomainConstants.EMPTY_STRING,
			 							DomainConstants.EMPTY_STRING,
			 							0);
			 			    	String[] strObjectIDArr    = new String[2];
			 						  Map RPNMap =(Map) rpnList.get(0);
			 						  String RPNId = (String)RPNMap.get(DomainConstants.SELECT_ID);
			 						  strObjectIDArr[0] = riskObjectId;
			 						  strObjectIDArr[1] = RPNId;
			 						  DomainObject.deleteObjects(context,strObjectIDArr);  		 					 
	 				  }	 	
	 			   }
	 	    	}
	 	    		 %>
	 		 	<script language="javascript" type="text/javaScript">
	 		 		var topFrame = findFrame(getTopWindow(), "PMCProjectRisk");	
	 		 		if (topFrame != null) {
	 		 			topFrame.location.href = topFrame.location.href;                        
	 		        }else{
	 		        	parent.location.href = parent.location.href;
	 		        }	 		 		
	 		 	</script>
	 		  <%}else if("findAssessor".equalsIgnoreCase(strMode)){
		    String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
		    fieldNameDisplay = XSSUtil.encodeURLForServer(context, fieldNameDisplay);
		    String fieldNameActual = emxGetParameter(request, "fieldNameActual"); 
		    fieldNameActual = XSSUtil.encodeURLForServer(context, fieldNameActual);
		    String fieldNameOID = emxGetParameter(request, "fieldNameOID");
		    fieldNameOID = XSSUtil.encodeURLForServer(context, fieldNameOID);
		    
		    String assessmentId = emxGetParameter(request, "objectId"); 
		    Assessment assessment = new Assessment(assessmentId);
            StringList busSelects = new StringList();
            busSelects.add(ProgramCentralConstants.SELECT_ID);
		    Map projectMap = assessment.getRelatedObject(context, Assessment.RELATIONSHIP_PROJECT_ASSESSMENT, false, busSelects, null);
		    String projectId = (String) projectMap.get(ProgramCentralConstants.SELECT_ID);
			 String strURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=state_Active&table=PMCCommonPersonSearchTable&selection=multiple&includeOIDprogram=emxAssessment:getPeopleForAssessor&showInitialResults=true";
			 strURL +="&objectId=" + XSSUtil.encodeForURL(context, projectId);
			 strURL +="&submitURL=../common/AEFSearchUtil.jsp";
			 strURL +="&fieldNameDisplay="+fieldNameDisplay;
			 strURL +="&fieldNameActual="+fieldNameActual;
			 strURL +="&fieldNameOID="+XSSUtil.encodeForURL(context, fieldNameOID);
			%>
				<script language="javascript">
	  <%-- XSSOK--%>
				var url = "<%=strURL%>";
					document.location.href = url;
				</script>
			<%
    	   }else if("deleteProject".equalsIgnoreCase(strMode)){
    		   String[] projects = emxGetParameterValues(request,"emxTableRowId");
    		   for (int i=0;i<projects.length;i++){
    			      Map mpRow = ProgramCentralUtil.parseTableRowId(context,projects[i]);
    			      projects[i] = (String) mpRow.get("objectId");
    		   }
    		   if(projects.length >0){
    			   session.setAttribute("selectedProjectId", projects);
    		   }
    		   String url = "../programcentral/emxProgramCentralProjectDeleteProcess.jsp?invokedFrom=StructureBrowser";
    	    		 %>
    		 	<script language="javascript" type="text/javaScript">
	    		 	var topFrame = findFrame(getTopWindow(), "PMCProjectSpaceMyDesk");
	    		 	if(topFrame== null){
	    		 		topFrame = findFrame(getTopWindow(), "content");
	    		 		turnOnProgress();
<%--XSSOK--%>	    		 		document.location.href = "<%=url%>";
	    		 	}else{
	    			setTimeout(function() {
	    				topFrame.toggleProgress('visible');
<%--XSSOK--%>	    				document.location.href = "<%=url%>";
		    		    },100);
	    		 	}
	    			
    		 		
    		 	</script>
    		  <%
    	   }else if("deleteProjectTemplate".equalsIgnoreCase(strMode)){
    		   String[] projectTemplates = emxGetParameterValues(request,"emxTableRowId");
    		   for (int i=0;i<projectTemplates.length;i++){
    			      Map mpRow = ProgramCentralUtil.parseTableRowId(context,projectTemplates[i]);
    			      projectTemplates[i] = (String) mpRow.get("objectId");
    		   }
    		   if(projectTemplates.length >0){
    			   session.setAttribute("selectedProjectTemplateId", projectTemplates);
    		   }
    		   String url = "../programcentral/emxProgramCentralProjectTemplateDeleteProcess.jsp";
    	    		 %>
    		 	<script language="javascript" type="text/javaScript">
	    		 	var topFrame = findFrame(getTopWindow(), "PMCProjectTemplateMyDesk");
	    		 	if(topFrame== null){
	    		 		topFrame = findFrame(getTopWindow(), "content");
	    		 		turnOnProgress();
<%--XSSOK--%>	    		 		document.location.href = "<%=url%>";
	    		 	}else{
	    			setTimeout(function() {
	    				topFrame.toggleProgress('visible');
<%--XSSOK--%>	    				document.location.href = "<%=url%>";
		    		    },100);
	    		 	}
	    			
    		 		
    		 	</script>
    		  <%
    	   }else if("refreshQualityPage".equalsIgnoreCase(strMode)){
    	    		 %>
    		 	<script language="javascript" type="text/javaScript">
	    		 	var topFrame = findFrame(getTopWindow(), "PMCQuality");
	    		 	topFrame.location.href = topFrame.location.href;
    		 	</script>
    		  <%
    	   }else if("timesheetReminder".equalsIgnoreCase(strMode)){
    			Date date = new Date();
    			String strMemberId = emxGetParameter(request,"memberId");
    			String timesheetName = emxGetParameter(request,"timesheetName");
    			NotificationUtil.sendTimesheetSubmissionNotification(context, strMemberId, timesheetName);
    	   }else if("quickCreateQuestion".equalsIgnoreCase(strMode)){
        	
                // nx5 - TP6569
               // String projectTemplateId = emxGetParameter( request, "parentOID");
                String projectTemplateId = emxGetParameter( request, "objectId");
        	Map<String,String> parameterMap = new HashMap<String,String>();
        	parameterMap.put("projectTemplateId",projectTemplateId);

        	Question question = new Question();
        	Map<String,String> questionInfoMap = question.createAndConnectQuestion(context, projectTemplateId);
        	
        	String questionId = questionInfoMap.get("questionId");
        	String questionProjectRelId = questionInfoMap.get("questionProjectRelId");
        	
	       	String xmlMessage = "<mxRoot><action><![CDATA[add]]></action>";
	       		   	xmlMessage +="<data status=\"committed\" fromRMB=\"" + false + "\">";
	       		   	xmlMessage +="<item oid=\"" + questionId + "\" relId=\"" + questionProjectRelId + "\" pid=\"" + projectTemplateId + "\"/>"; 
	       			xmlMessage +="</data></mxRoot>";
 	    	%>
 		 	<script language="javascript" type="text/javaScript">
	 		 	var topFrame = findFrame(getTopWindow(),"detailsDisplay");
	            topFrame.emxEditableTable.addToSelected('<%=XSSUtil.encodeForJavaScript(context,xmlMessage)%>');
	            topFrame.refreshStructureWithOutSort();
 		 	</script>
 		  <%
     } else if("deleteQuestion".equalsIgnoreCase(strMode)){
    		   
    		   String[] selectedRowArray = emxGetParameterValues(request,"emxTableRowId");
    		   String[] questionIdArray  = new String[selectedRowArray.length];
    		   String partialXML = "";
    		   
    		   for(int i=0; i<selectedRowArray.length; i++) {
					String selectedRowString = selectedRowArray[i];
					Map parsedObjectMap = ProgramCentralUtil.parseTableRowId(context,selectedRowString);
					String objectId = (String)parsedObjectMap.get("objectId");
					String rowId = (String)parsedObjectMap.get("rowId");
					questionIdArray[i] = objectId;
					partialXML += "<item id=\"" + rowId + "\" />";		
				}
    		   
    		   if(questionIdArray != null && questionIdArray.length > 0){
    			   
	    		   boolean isOfQuestionType = 
	    				   ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_QUESTION,questionIdArray);
	    		   
	    		   if (isOfQuestionType) {
	    			   
	    			   DomainObject.deleteObjects(context,questionIdArray);
	    			   
	    			   String xmlMessage = "<mxRoot>";
	    			   String message = "";
	    			   xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
	    			   xmlMessage += partialXML;
	    			   xmlMessage += "<message><![CDATA[" + message + "]]></message>";
	    			   xmlMessage += "</mxRoot>";
	    				
	    			%>
   	    		 		<script language="javascript" type="text/javaScript">
		   	    		 	var topFrame = findFrame(getTopWindow(), "detailsDisplay");
		   		            topFrame.removedeletedRows('<%= XSSUtil.encodeForJavaScript(context,xmlMessage) %>');
		   		            topFrame.refreshStructureWithOutSort();
	 		 			</script>
   	    		  	<%
	    		   } else {
	    	    		String errorMessage = 
	    	    				ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Question.PleaseSelectQuestionToRemove",sLanguage);
	    	    		 %>
	    	    		 	<script language="javascript" type="text/javaScript">
	     		 				alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
    	 		 			</script>
	    	    		  <%
	    	    	}
    		   }
    		   
      } else if("assignTaskToQuestion".equalsIgnoreCase(strMode)){
    		   
	   		   	String[] questionIdArray = emxGetParameterValues(request,"emxTableRowId");
	   		 	String projectTemplateId = emxGetParameter( request, "parentOID");	   		 	
	   			String errorMessage = null;
	   			String listTaskToAssignURL = null;
	   			
	   			if (questionIdArray != null && questionIdArray.length != 0) {
	   			   if (questionIdArray.length == 1) {
	   					String questionId =  ProgramCentralUtil.parseTableRowId(context,questionIdArray)[0];
	   					boolean isOfQuestionType = 
	 	    				   ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_QUESTION,questionId);
	   					if (isOfQuestionType) {	
	   						projectTemplateId = XSSUtil.encodeURLForServer(context,projectTemplateId);
		   					questionId = XSSUtil.encodeURLForServer(context,questionId);
		   					
		   					listTaskToAssignURL = 
			   						"../common/emxIndentedTable.jsp?program=emxProjectTemplate:getTaskMapListToAssignQuestion"+
			   						"&table=PMCTaskListTable&selection=multiple&sortColumnName=Question Response"+
			   						"&suiteKey=ProgramCentral&SuiteDirectory=programcentral"+
			   						"&header=emxProgramCentral.Common.Tasks&helpMarker=emxhelpassigntotasks"+
			   						"&submitLabel=emxProgramCentral.Common.Assign"+
			   			  			"&submitURL=../programcentral/emxProgramCentralUtil.jsp"+
			   			  			"&mode=connectTaskToQuestion"+
			   						"&projectTemplateId="+projectTemplateId+"&questionId="+questionId;
		   					
	   					} else {
	   	   				 errorMessage = ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Question.PleaseSelectQuestionToAssignTasks",sLanguage);
	 	   			   }
	   			   } else {
	   				 errorMessage = ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Question.SelectOnlyOneQuestionToAssign",sLanguage);
	   			   }
	   		   	} else {
	 				errorMessage = ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Question.MustSelectQuestionToAssign",sLanguage);
	   		   	}
	   		   	
				if (ProgramCentralUtil.isNullString(errorMessage)) {
	   				%>
	     		 	<script language="javascript" type="text/javaScript">
	     		 	 	var listTaskToAssignURL = "<%=XSSUtil.encodeForJavaScript(context,listTaskToAssignURL)%>";
	     		 	 	getTopWindow().location.href = listTaskToAssignURL;
	     		 	</script>
	     			<%  
	   		   	} else {
	   		   		%>
     		 		<script language="javascript" type="text/javaScript">
	     		 		alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
	     		 		getTopWindow().closeWindow();
    	 		 	</script>
     				<% 
     				return;
	   		   	}
   	   	}  else if("removeQuestionTask".equalsIgnoreCase(strMode)){
 		   
   	   	   String[] selectedRowArray = emxGetParameterValues(request,"emxTableRowId");
		   String[] questionTaskIdArray  = new String[selectedRowArray.length];
		   String partialXML = "";
		   
		   for(int i=0; i<selectedRowArray.length; i++) {
				String selectedRowString = selectedRowArray[i];
				Map parsedObjectMap = ProgramCentralUtil.parseTableRowId(context,selectedRowString);
				String objectId = (String)parsedObjectMap.get("objectId");
				String rowId = (String)parsedObjectMap.get("rowId");
				questionTaskIdArray[i] = objectId;
				partialXML += "<item id=\"" + rowId + "\" />";		
			}
 		   
 		   	if(selectedRowArray != null && selectedRowArray.length > 0) {
 		   		 String errorMessage ="";
 		   		 boolean isOfTaskType = 
 				   			ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_TASK_MANAGEMENT,questionTaskIdArray);
 		   	     
 		   		 if (isOfTaskType) {
					Question question = new Question();
 		    		errorMessage = question.disconnectTaskList(context, selectedRowArray);
	 			 	
 		   	     } else {
	 		   		errorMessage = 
	 	   	    			ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.common.PleaseSelectTasksToRemove",sLanguage); 		   	    	 
 		   	     }

	  	    	 if (ProgramCentralUtil.isNullString(errorMessage)) {
	  	    		String xmlMessage = "<mxRoot>";
	    			   String message = "";
	    			   xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
	    			   xmlMessage += partialXML;
	    			   xmlMessage += "<message><![CDATA[" + message + "]]></message>";
	    			   xmlMessage += "</mxRoot>";
	  	    	 %>
  	    	 		<script language="javascript" type="text/javaScript">
		    	 		var topFrame = findFrame(getTopWindow(), "detailsDisplay");
			            topFrame.removedeletedRows('<%= XSSUtil.encodeForJavaScript(context,xmlMessage) %>');
			            topFrame.refreshStructureWithOutSort();
    		 		</script>
		 		<% } else {
		 		%>
		 			<script language="javascript" type="text/javaScript">
  	    	 			alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
		 			</script>
	  	    	<% 
 	     	} 
   	   	  }
   	   	} else if("connectTaskToQuestion".equalsIgnoreCase(strMode)){
 		   
   	   	 	String[] selectedRowArray = emxGetParameterValues(request,"emxTableRowId");
		
		   	if(selectedRowArray != null && selectedRowArray.length > 0){		   		
		   		String[] taskIdArray = ProgramCentralUtil.parseTableRowId(context,selectedRowArray);
		   		String[] questionResponseArray = new String[taskIdArray.length];
		   		 for(int i=0;i<taskIdArray.length;i++){
			    	 String selectedId = taskIdArray[i];
			    	 String questionResponse = request.getParameter(selectedId);			    	
			    	 questionResponseArray[i]=questionResponse;
			    }
		   		String questionId 	 = emxGetParameter(request,"questionId");		   		 
	 			Question question = new Question(questionId);
				question.connectTaskArray(context,taskIdArray,questionResponseArray);
	 			 
		 		%>	
		 		<script language="javascript" type="text/javaScript">
		 			getTopWindow().getWindowOpener().refreshSBTable(getTopWindow().getWindowOpener().configuredTableName);
	       			getTopWindow().close(); 
 		 		</script>
	  	    	<% 
	   	  }else{
	   		  String errorMessage = 
	   	    			ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Common.Noobjectsselected",sLanguage);
		 	 %>
		 	<script language="javascript" type="text/javaScript">
		 		alert('<%= errorMessage %>');     <%--XSSOK--%>  
	 	 	</script>
	 	 	<%
	   	  }
   	   	} else if("createResourcePlanTemplate".equalsIgnoreCase(strMode)){
   	   		
	   	   	String projectTemplateId = emxGetParameter( request, "parentOID");
	   	 	String resourcePlanTemplateName = new DomainObject().getUniqueName("RPT-");
	   	 	   	   		
			ResourcePlanTemplate resourcePlanTemplate = new ResourcePlanTemplate();
			resourcePlanTemplate.createResourcePlanTemplate(context,projectTemplateId,resourcePlanTemplateName,"-");
	    	
	    	%>
		 	<script language="javascript" type="text/javaScript">
 		 	var topFrame = findFrame(getTopWindow(), "PMCResourcePlanTemplateSummaryTable");	
	 		if (topFrame != null) {
	 			topFrame.location.href = topFrame.location.href;                        
	        }else{
	        	parent.location.href = parent.location.href;
	        }
		 	</script>
	<%		 	
   	   	}  else if("resourcePlanTemplateResourceRequestCreate".equalsIgnoreCase(strMode)){
	   		String projectTemplateId = emxGetParameter(request, "parentOID");
   	 		String resourcePlanTemplateId = emxGetParameter(request, "objectId");
   			String resourcePlanTemplateRelId = emxGetParameter(request, "relId");
   			
			ResourcePlanTemplate resourcePlanTemplate = new ResourcePlanTemplate();
			resourcePlanTemplate.createResourceRequestFromResourcePlanTemplate(context,
												resourcePlanTemplateId, projectTemplateId, resourcePlanTemplateRelId);
			
			%>
				<script language="javascript" type="text/javaScript">
	 		 	var topFrame = findFrame(getTopWindow(), "PMCResourcePlanTemplateRequestSummaryTable");	
		 		if (topFrame != null) {
		 			topFrame.location.href = topFrame.location.href;                        
		        }else{
		        	parent.location.href = parent.location.href;
		        }
			 	</script>
			<%
   	   	} else if("createQuestionsAndConnectToTemplateTask".equalsIgnoreCase(strMode)){
   	   	 
 		   	String[] selectedRowArray = emxGetParameterValues(request,"emxTableRowId");
 		   	String projectTemplateId = emxGetParameter(request, "parentOID");
 		   	projectTemplateId = XSSUtil.encodeURLForServer(context,projectTemplateId);
   		   		
   		   	if (selectedRowArray != null && selectedRowArray.length >= 1) {
   		   	
				String[] taskIdArray = ProgramCentralUtil.parseTableRowId(context,selectedRowArray);
				
				StringList busSelectList= new StringList();
				busSelectList.add("to[" + DomainObject.RELATIONSHIP_QUESTION + "]");
				busSelectList.add(ProgramCentralConstants.SELECT_KINDOF_TASKMANAGEMENT);
				
				List<Map<String,String>> taskInfoMapList = DomainObject.getInfo(context,taskIdArray,busSelectList);
				
				for(Map<String,String> taskInfoMap :  taskInfoMapList) {
					
					String isOfTaskMgmtType = taskInfoMap.get(ProgramCentralConstants.SELECT_KINDOF_TASKMANAGEMENT);
					if(!"true".equalsIgnoreCase(isOfTaskMgmtType)){
						String errorMessage = 
		 	   	    			ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.common.PleaseSelectTasksOnly",sLanguage);
						%>
						<script language="javascript" type="text/javaScript">
							alert('<%=errorMessage%>');  <%--XSSOK--%>
							getTopWindow().closeSlideInDialog();
						</script>
						<%
						return;
					}
					
					String connectedToQuestion = taskInfoMap.get("to[" + DomainObject.RELATIONSHIP_QUESTION + "]");
					if ("true".equalsIgnoreCase(connectedToQuestion)){
						String errorMessage = 
		 	   	    			ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Common.QuestionAlreadyAssigned",sLanguage);
						%>
						<script language="javascript" type="text/javaScript">
							alert('<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>');
							getTopWindow().closeSlideInDialog();
					 	</script>
						<%
						return;
					}
				}
				
				String taskIdString = taskIdArray[0];
				for(int i=1;i<taskIdArray.length;i++) {
					taskIdString +="_"+taskIdArray[i];
				}
				String createQuestionsAndConnectToTemplateTaskURL = 
					"../common/emxCreate.jsp?type=type_Question"+
					"&typeChooser=false&nameField=keyin&form=PMCCreateQuestionForm"+
					"&suiteKey=ProgramCentral&SuiteDirectory=programcentral"+
					"&header=emxProgramCentral.Common.CreateQuestion"+
					"&HelpMarker=emxhelpquestioncreatedialog&findMxLink=false"+
					"&submitAction=nothing&showPageURLIcon=false"+
					"&postProcessURL=../programcentral/emxProgramCentralUtil.jsp?mode=postRefresh"+
					"&postProcessJPO=emxQuestion:connectQuestionToTask"+
					"&showQuestionResponseDD=true"+
					"&projectTemplateId="+XSSUtil.encodeURLForServer(context,projectTemplateId)+"&taskIdString="+XSSUtil.encodeURLForServer(context,taskIdString);
		  			
					createQuestionsAndConnectToTemplateTaskURL = 
						XSSUtil.encodeURLForServer(context,createQuestionsAndConnectToTemplateTaskURL);
				%>
				<script language="javascript" type="text/javaScript">
				<%--XSSOK--%>	var createQuestionsAndConnectToTemplateTaskURL = "<%=createQuestionsAndConnectToTemplateTaskURL%>";
					getTopWindow().showSlideInDialog(createQuestionsAndConnectToTemplateTaskURL,true);
			 	</script>
				<%
   		   	}
   	   }  else if("listQuestionsToAssignTemplateTask".equalsIgnoreCase(strMode)){
     	   	 
   		   	String[] selectedRowArray = emxGetParameterValues(request,"emxTableRowId");
   		   	String projectTemplateId = emxGetParameter(request, "parentOID");
   		   	projectTemplateId = XSSUtil.encodeURLForServer(context,projectTemplateId);
     		   		
     		if (selectedRowArray != null && selectedRowArray.length >= 1) {
     		   	
				String[] taskIdArray = ProgramCentralUtil.parseTableRowId(context,selectedRowArray);
  				
  				StringList busSelectList= new StringList();
  				busSelectList.add("to[" + DomainObject.RELATIONSHIP_QUESTION + "]");
  				List<Map<String,String>> taskInfoMapList = DomainObject.getInfo(context,taskIdArray,busSelectList);
  				
  				for(Map<String,String> taskInfoMap :  taskInfoMapList) {
  					String connectedToQuestion = taskInfoMap.get("to[" + DomainObject.RELATIONSHIP_QUESTION + "]");
  					if ("true".equalsIgnoreCase(connectedToQuestion)){
  						String errorMessage = 
  		 	   	    			ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Common.QuestionAlreadyAssigned",sLanguage);
  						%>
  						<script language="javascript" type="text/javaScript">
  							alert('<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>');
  							getTopWindow().closeWindow(); 
  					 	</script>
  						<%
  						return;
  					}
  				}
  				
  				String taskIdString = taskIdArray[0];
  				for(int i=1;i<taskIdArray.length;i++) {
  					taskIdString +="_"+taskIdArray[i];
  				}
  				String listQuestionToAssignURL = 
  					"../common/emxIndentedTable.jsp?"+
  					"&program=emxProjectTemplate:getProjectTemplateQuestionList"+
  					"&table=PMCQuestionListTable&selection=single&sortColumnName=Name"+
  					"&suiteKey=ProgramCentral&SuiteDirectory=programcentral"+
  					"&header=emxFramework.Command.Question&helpMarker=emxhelptemplatewbsassignquestion"+
  					"&submitLabel=emxProgramCentral.Common.Assign"+
  		  			"&submitURL=../programcentral/emxProgramCentralUtil.jsp&mode=connectQuestiontoTask"+
  		  			"&projectTemplateId="+projectTemplateId+"&taskIdString="+taskIdString;
  		  			
  		  		listQuestionToAssignURL = XSSUtil.encodeURLForServer(context,listQuestionToAssignURL);
  					
  				%>
  				<script language="javascript" type="text/javaScript">
  					var listQuestionToAssignURL = "<%=listQuestionToAssignURL%>";
  					getTopWindow().location.href = listQuestionToAssignURL;
  			 	</script>
  				<%
     		}
     	 } else if("connectQuestiontoTask".equalsIgnoreCase(strMode)) {
 		   	String[] selectedRowArray = emxGetParameterValues(request,"emxTableRowId");

 		   	if (selectedRowArray != null && selectedRowArray.length == 1) {
	 		   	Map<String,String> infoMap = ProgramCentralUtil.parseTableRowId(context,selectedRowArray[0]);
	 		   	String questionId    = infoMap.get("objectId");
	 		   	String selectedIndex = infoMap.get("rowId").split(",")[1];
	 		   	int questionIndex    = Integer.parseInt(selectedIndex);
	 		   	
	 		   	String taskIdString  = emxGetParameter(request,"taskIdString");
		   		String[] taskIdArray = taskIdString.split("_");  
		    	String selectedQuestionResponse = emxGetParameter(request, questionId);
		    	String[] questionResponseArray = new String[taskIdArray.length];
		    	
		    	for(int i=0;i<taskIdArray.length;i++) {
					questionResponseArray[i]=selectedQuestionResponse;
				}
		    	
		    	Question question = new Question(questionId);
    			question.connectTaskArray(context,taskIdArray,questionResponseArray);
		 	%>	
		 	<script language="javascript" type="text/javaScript">
		 		getTopWindow().getWindowOpener().refreshSBTable(getTopWindow().getWindowOpener().configuredTableName);
   				getTopWindow().closeWindow();  
			</script>
	  	    <% 
 		   	 }else{
     			 String errorMessage = 
  		 	   	    			ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Common.Noobjectsselected",sLanguage);
     			 %>
     			 <script language="javascript" type="text/javaScript">
     				 alert('<%= errorMessage %>');   <%--XSSOK--%>
			 	 </script>
			 	 <%
 		   	}
   	 } else if("createQuestionForTemplateTask".equalsIgnoreCase(strMode)){
   		   
   		   	String taskIdString = emxGetParameter(request,"objectId");
     		   		
    		if (ProgramCentralUtil.isNotNullString(taskIdString)) {    			
    		   	String SELECT_PROJECT_ID = "to["+DomainObject.RELATIONSHIP_SUBTASK+"].from.id";

    		   	taskIdString = XSSUtil.encodeURLForServer(context,taskIdString);   		 		
    		   	DomainObject taskObject  = DomainObject.newInstance(context,taskIdString);
    		   	
   		 		String projectTemplateId = taskObject.getInfo(context,SELECT_PROJECT_ID);
   		 		projectTemplateId = XSSUtil.encodeURLForServer(context,projectTemplateId);
   		 		
 				String createQuestionForTemplateTaskURL = 
 					"../common/emxCreate.jsp?type=type_Question"+
 					"&typeChooser=false&nameField=keyin&form=PMCCreateQuestionForm"+
 					"&suiteKey=ProgramCentral&SuiteDirectory=programcentral"+
 					"&header=emxProgramCentral.Common.CreateQuestion"+
 					"&HelpMarker=emxhelpquestioncreatedialog&findMxLink=false"+
 					"&submitAction=refreshCaller&showPageURLIcon=false"+
 					"&postProcessJPO=emxQuestion:connectQuestionToTask"+
 					"&showQuestionResponseDD=true"+
 					"&projectTemplateId="+XSSUtil.encodeURLForServer(context,projectTemplateId)+"&taskIdString="+XSSUtil.encodeURLForServer(context,taskIdString);
 		  			
 					createQuestionForTemplateTaskURL = 
 						XSSUtil.encodeURLForServer(context,createQuestionForTemplateTaskURL);
 				%>
 				<script language="javascript" type="text/javaScript">
 					var createQuestionForTemplateTaskURL = "<%=createQuestionForTemplateTaskURL%>"; <%--XSSOK--%>
 					getTopWindow().showSlideInDialog(createQuestionForTemplateTaskURL, true);
 			 	</script>
 				<%
    		}
    		
     } else if("assignQuestionForTemplateTask".equalsIgnoreCase(strMode)){
       		   
      		String taskIdString = emxGetParameter(request,"objectId");
        		   		
       		if (ProgramCentralUtil.isNotNullString(taskIdString)) {
       			
       		   	String SELECT_PROJECT_TEMPLATE_ID = 
       		   			"to["+DomainObject.RELATIONSHIP_PROJECT_ACCESS_KEY+"].from.from["+DomainObject.RELATIONSHIP_PROJECT_ACCESS_LIST+"].to.id";
       		   	taskIdString = XSSUtil.encodeURLForServer(context,taskIdString);
      		 		
       		   	DomainObject taskObject  = DomainObject.newInstance(context,taskIdString);
       		   	
      		 	String projectTemplateId = taskObject.getInfo(context,SELECT_PROJECT_TEMPLATE_ID);
      		 	projectTemplateId = XSSUtil.encodeURLForServer(context,projectTemplateId);
      		 		
      		 	String listQuestionToAssignURL = 
      	  				"../common/emxIndentedTable.jsp?"+
      	  				"&program=emxProjectTemplate:getProjectTemplateQuestionList"+
      	  				"&table=PMCQuestionListTable&selection=single&sortColumnName=Name"+
      	  				"&suiteKey=ProgramCentral&SuiteDirectory=programcentral"+
      	  				"&header=emxFramework.Command.Question&helpMarker=emxhelptemplatewbsassignquestion"+
      	  				"&submitLabel=emxProgramCentral.Common.Assign"+
      	  		  		"&submitURL=../programcentral/emxProgramCentralUtil.jsp&mode=connectQuestiontoTask"+
      	  		  		"&projectTemplateId="+projectTemplateId+"&taskIdString="+taskIdString;
      	  		  			
      	  		listQuestionToAssignURL = XSSUtil.encodeURLForServer(context,listQuestionToAssignURL);
      	  					
      	  		%>
      	  		<script language="javascript" type="text/javaScript">
      	  			var listQuestionToAssignURL = "<%=listQuestionToAssignURL%>";
      	  			getTopWindow().location.href = listQuestionToAssignURL;
      	  		</script>
      	  		<%
       		}
      } else if("unAssignTaskQuestion".equalsIgnoreCase(strMode)){
    	  
    	  String taskId = emxGetParameter(request, "objectId");
    	  
    	  if (ProgramCentralUtil.isNotNullString(taskId)) {
    		  String SELECT_QUESTION_REL_ID = "to["+ DomainObject.RELATIONSHIP_QUESTION+"].id";
	    	  
	    	  DomainObject taskObject  = DomainObject.newInstance(context,taskId);
	    	  String questionConnectId = taskObject.getInfo(context,SELECT_QUESTION_REL_ID);
	    	  
	    	  DomainRelationship.disconnect(context,questionConnectId);
	    	  
	    	%>
    	  	<script language="javascript" type="text/javaScript">
	    	  	parent.document.location.href = parent.document.location.href;
    	  	</script>
    	  	<%
    	  }
  	  } else if ("wbsAssignmentView".equalsIgnoreCase(strMode) || "wbsAllocationView".equalsIgnoreCase(strMode) ) {
			
			String sMode = emxGetParameter(request,"subMode");
			String sRelationship = request.getParameter("relationship");	
			String sObjectId = request.getParameter("objectId");	
			String sRelId = request.getParameter("relId");	
			String sRowID = request.getParameter("rowId");	
			String sPersonOID = request.getParameter("personId");
			String sFrom = request.getParameter("from");
			String sPercent = request.getParameter("percent");
			DomainObject domObjTask = new DomainObject(sObjectId);
			
			try {
				DomainRelationship dRelationship = new DomainRelationship();
				if(sMode.equalsIgnoreCase("assign")) {
					domObjTask.addFromObject(context, new RelationshipType(sRelationship), sPersonOID);
				} else if (sMode.equalsIgnoreCase("unassign"))  {
						dRelationship = new DomainRelationship(sRelId);
						dRelationship.remove(context);
				} else if (sMode.equalsIgnoreCase("allocate"))  {
					if(sPercent.equals("0.0")) { //Remove both Assignment & Allocation
						dRelationship = new DomainRelationship(sRelId);
						dRelationship.remove(context);
					} else {
						if (ProgramCentralUtil.isNullString(sRelId)) { //Assigning & Allocating
							dRelationship = domObjTask.addFromObject(context, new RelationshipType(sRelationship), sPersonOID);	
						} else { //Re-allocating
							dRelationship = new DomainRelationship(sRelId);
						}
						try{
							ProgramCentralUtil.pushUserContext(context);
							dRelationship.setAttributeValue(context, ProgramCentralConstants.ATTRIBUTE_PERCENT_ALLOCATION, sPercent);
						}
						finally{
							ProgramCentralUtil.popUserContext(context);
						}
					}
				}
			} catch (Exception exception) {
				exception.printStackTrace();
			}
%>
		<script language="javascript" type="text/javaScript">	
			parent.emxEditableTable.refreshRowByRowId("<%=sRowID%>"); <%-- XSSOK --%>
		</script>
<%			
  	  }else if("getCurrentDate".equalsIgnoreCase(strMode)){
			ProjectSpace project = new ProjectSpace();
			JSONObject jsonObject = new JSONObject();
			Map programMap = new HashMap();
			Map requestMap = new HashMap();
				
			programMap.put("requestMap",requestMap);
			requestMap.put("timeZone", (String)session.getValue("timeZone"));
				
			String []args = JPO.packArgs(programMap);
			String currentProjectDate = project.getCurrentDate(context, args);
			jsonObject.put("ProjectDate",currentProjectDate);
			out.clear();
			out.write(jsonObject.toString());
			return;
			
		}else if("QuestionTxt".equalsIgnoreCase(strMode)){
			String subMode = emxGetParameter(request,"subMode");
			JSONObject jsonObject = new JSONObject();
			
			String noQuestionText = EnoviaResourceBundle.getProperty(context,ProgramCentralConstants.PROGRAMCENTRAL, 
					"emxProgramCentral.Common.Project.QuestionToResponed", context.getSession().getLanguage());
			
			String toRespondQuestionText = EnoviaResourceBundle.getProperty(context,ProgramCentralConstants.PROGRAMCENTRAL, 
					"emxProgramCentral.Common.Project.QuestionBeforeResponse", context.getSession().getLanguage());
			
			if(ProgramCentralUtil.isNotNullString(subMode) && "NoQuestion".equalsIgnoreCase(subMode)){
				jsonObject.put("questionsDisplay",noQuestionText);
			}else{
				jsonObject.put("questionsDisplay",toRespondQuestionText);
			}
			
			out.clear();
			out.write(jsonObject.toString());
			return;
		}else if("QuestionResponse".equalsIgnoreCase(strMode)){
		    String fieldNameDisplay = request.getParameter("fieldNameDisplay");
		    String fieldNameActual = request.getParameter("fieldNameActual");
		    String fieldNameOID = request.getParameter("fieldNameOID");
		    String templateObjectId = (String)session.getValue("selectedTemplateId");
	
		    Map questionTaskListMap = new HashMap();
		    String urlProgram = "emxProjectSpace:getActiveQuestionList";
		    String strQusURL =  Question.getQuestionResponceURL(questionTaskListMap,templateObjectId,urlProgram,fieldNameDisplay,fieldNameActual,fieldNameOID);
		    %>
				<script language="javascript">
					document.location.href ='<%=strQusURL%>';
				</script>
			<%
		}else if("updateQuestionValue".equalsIgnoreCase(strMode)){
		    String[] QR = emxGetParameterValues(request,"QR");
		    
		    String strFieldNameDisplay = (String)emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_DISPLAY);
			String strFieldNameActual = (String)emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_ACTUAL);
			
			strFieldNameDisplay = XSSUtil.encodeURLForServer(context, strFieldNameDisplay);
			strFieldNameActual = XSSUtil.encodeURLForServer(context, strFieldNameActual);
			
		    String questionResponseValue = DomainObject.EMPTY_STRING;
		    for(int i =0;i<QR.length;i++){
			    String questionResponse = QR[i];
			    StringList questionResponseValueList = FrameworkUtil.split(questionResponse, "|");
			    questionResponseValue += (String)questionResponseValueList.get(0)+"="+(String)questionResponseValueList.get(1)+"|";
		    }
		    
		    questionResponseValue = questionResponseValue.substring(0, questionResponseValue.length()-1);
		    CacheUtil.setCacheObject(context, "QuestionsResponse", questionResponseValue);
		    String textAfterResponse = EnoviaResourceBundle.getProperty(context,ProgramCentralConstants.PROGRAMCENTRAL, 
					"emxProgramCentral.Common.Project.QuestionAfterResponse", context.getSession().getLanguage());
		    %>
			<script language="javascript">
				var strfieldDisplay = "<%=strFieldNameDisplay%>";		<%-- XSSOK --%>	
		      	var strfieldNameActual = "<%=strFieldNameActual%>" ; 	<%-- XSSOK --%>

		      	var txtTypeDisplay = getTopWindow().getWindowOpener().document.forms[0].elements[strfieldDisplay];
		        var txtTypeActual = getTopWindow().getWindowOpener().document.forms[0].elements[strfieldNameActual];
			    
			    txtTypeDisplay.value = "<%=textAfterResponse%>"; <%-- XSSOK --%>
			    txtTypeActual.value = "<%=textAfterResponse%>";  <%-- XSSOK --%>
			    
			    getTopWindow().close();
			</script>
			<%
		    
		}else if("importProjectProcess".equalsIgnoreCase(strMode)){
			CacheUtil.removeCacheObject(context, "typeList");
			CacheUtil.removeCacheObject(context, "PersonInfo");
			
			Context contextDB = (matrix.db.Context)request.getAttribute("context");
			ProjectSpace project = new ProjectSpace(); 
			JSONObject jsonObject1 = new JSONObject();
			boolean invalidConfig = false;
			
			String fileName = emxGetParameter(request,"fileName");
			String fileNameExt[] = fileName.split("\\.");
			String fileExt = fileNameExt[1];
			
			String delimiter = ",";
			if(fileExt.equals("txt")){
				delimiter = "\t";
			}
			String projectDescription = EnoviaResourceBundle.getProperty(context, "ProgramCentral","emxProgramCentral.ProjectImport.ProjectDescription", context.getSession().getLanguage());
			projectDescription += fileName;
			Map <String,String>requestMap = new HashMap();
			requestMap.put("timeZone", (String)session.getValue("timeZone"));
			
			InputStream in = request.getInputStream();
			MapList importedObjectList = project.getImportedFileDetails(context, in, delimiter,requestMap);
			
			//check file
			Map errorMap = (Map)importedObjectList.get(0);
			String errorValue = DomainObject.EMPTY_STRING;
			Set keySet = errorMap.keySet();
			
			Iterator itr = keySet.iterator();
			while (itr.hasNext()){
				String key = (String) itr.next();
				if(key.equalsIgnoreCase("error")){
					invalidConfig = true;
					errorValue = (String)errorMap.get(key);
					break;
				}
			}
			
			if(!invalidConfig){
				session.setAttribute("importList", importedObjectList);
				
				FrameworkServlet framework = new FrameworkServlet();
				String fileContent = project.getFilePreviewViewContent(context,importedObjectList);
				framework.setGlobalCustomData(session,context,"fileContent",fileContent);
				
				boolean isFileCurrpted = false;
				
				for(int i=0;i<importedObjectList.size();i++){
					Map importedObjectMap = (Map)importedObjectList.get(i);
					if(!project.hasCorrectValue(context, importedObjectMap)){
						isFileCurrpted = true;
						break;
					}
				}
				
				for(int i=0;i<importedObjectList.size();i++){
					Map importedObjectMap = (Map)importedObjectList.get(i);
					
					if(!isFileCurrpted){
						String objectType = (String)importedObjectMap.get("type");
						String objectTypeDisplay = EnoviaResourceBundle.getAdminI18NString(context, "Type", objectType, context.getSession().getLanguage());
						if(objectType.equalsIgnoreCase(DomainObject.TYPE_PROJECT_SPACE)){
							String objectName = (String)importedObjectMap.get("name");
							String objectStartDate = (String)importedObjectMap.get("Task Estimated Start Date");
							
							try{
								double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
								objectStartDate = eMatrixDateFormat.getFormattedDisplayDate(objectStartDate, clientTZOffset,context.getLocale());
							}catch(Exception e){
								e.printStackTrace();
							}
						
							jsonObject1.put("Name",objectName.trim());
		   	        		jsonObject1.put("TypeActual",objectType.trim());
		   	        		jsonObject1.put("TypeActualDisplay",objectTypeDisplay);
		   	        		jsonObject1.put("ProjectDate",objectStartDate.trim());
		   	        		jsonObject1.put("description",projectDescription.trim());
		   	        		jsonObject1.put("title",EnoviaResourceBundle.getProperty(context, "ProgramCentral","emxProgramCentral.ImportFrom.FileHasNoErrors", context.getSession().getLanguage()));
		   	        		
		   	        		break;
						}
					}else{
						jsonObject1.put("error",EnoviaResourceBundle.getProperty(context, "ProgramCentral","emxProgramCentral.ImportFrom.FileHasSomeErrors", context.getSession().getLanguage()));
						break;
					}
				
				}
			}else{
				jsonObject1.put("error",errorValue);
			}
			out.clear();
			out.write(jsonObject1.toString());
			return;
			 
		}else if("searchProjectData".equalsIgnoreCase(strMode)){
			CacheUtil.removeCacheObject(context, "QuestionsResponse");
			ProjectSpace project = new ProjectSpace();
			JSONObject jsonObject = new JSONObject();
			Map <String,String>programMap = new HashMap();
			
			String selectedProjectId = emxGetParameter(request,"searchProjectId");
			session.setAttribute("selectedTemplateId", selectedProjectId);
			
			if(ProgramCentralUtil.isNotNullString(selectedProjectId)){

				Map projectInfoMap = project.getSelectedProjectInfo(context, selectedProjectId, (String)session.getValue("timeZone"));
				String kindOfProjectTemplate  = (String)projectInfoMap.get("KindOfProjectTemplate");		
				String questionInfo = (String)projectInfoMap.get("QuestionsInfo");
				projectInfoMap.remove("QuestionsInfo");
				boolean hasQuestion = ProgramCentralUtil.isNotNullString(questionInfo) ? true : false ;
				
				projectInfoMap.remove("KindOfProjectTemplate");
				projectInfoMap.remove("QuestionsInfo");
				
				Set keys = projectInfoMap.keySet();
				for (Iterator i = keys.iterator(); i.hasNext();){
					String key = (String) i.next();
				    String value = (String) projectInfoMap.get(key);
				    if(!DomainObject.TYPE_PROJECT_TEMPLATE.equalsIgnoreCase(value)){
				    	if(!("TypeActualDisplay".equalsIgnoreCase(key) || "TypeActual".equalsIgnoreCase(key))){
				    		jsonObject.put(key,value);	
						}
					}
				}
				
				if(Boolean.valueOf(kindOfProjectTemplate)){
					ResourcePlanTemplate resourcePlanTemplteObj = new ResourcePlanTemplate();
					MapList mlResourceRequest = resourcePlanTemplteObj.getResourceRequestMap(context,selectedProjectId);
				
					if(hasQuestion){
						jsonObject.put("Question","true");	
					}else{
						jsonObject.put("Question","false");	
					}
					
					if(mlResourceRequest.size()>0){
						jsonObject.put("RT","true");	
					}else{
						jsonObject.put("RT","false");
					}
				}
				out.clear();
				out.write(jsonObject.toString());
			}
			return;
			
		}else if("launchProject".equalsIgnoreCase(strMode)){
			Context contextDB = (matrix.db.Context)request.getAttribute("context");
			CacheUtil.removeCacheObject(context, "QuestionsResponse");
			String newlyProjectCreatedId = request.getParameter("newObjectId");
			
		    //Change Discipline if Change Project
			if(isECHInstalled){	
				Task project = new Task();
				project.setId(newlyProjectCreatedId);
				if(newlyProjectCreatedId!=null && !newlyProjectCreatedId.equalsIgnoreCase("")){
					if(project.isKindOf(contextDB, PropertyUtil.getSchemaProperty(context,"type_ChangeProject"))){
						
						Map requestMap = request.getParameterMap();
						Map paramMap = new HashMap(2);    				    		
		    			paramMap.put("newObjectId", newlyProjectCreatedId);    	
		    			paramMap.put("requestMap", requestMap);    	
		    			JPO.invoke(contextDB, "emxChangeTask", null, "setChangeDisciplineAttribute",JPO.packArgs(paramMap));			
					}
				}					
			}//End of Change Discipline if Change Project
			
			StringBuffer treeUrl = new StringBuffer("../common/emxTree.jsp?AppendParameters=true"+
	                  "&treeNodeKey=node.ProjectSpace&suiteKey=eServiceSuiteProgramCentral&objectId="+
	                  XSSUtil.encodeForURL(newlyProjectCreatedId) + "&DefaultCategory=PMCGateDashboardCommandPowerView" + 
	                  "&emxSuiteDirectory=programcentral&treeTypeKey=type.Project");
			%>
		    <script language="javascript" type="text/javaScript">
			   var parentContentDetailsFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
               parentContentDetailsFrame.document.location.href = "<%= treeUrl %>"; <%-- XSSOK --%>
               parent.window.closeWindow();
               
		    </script>
		    <%
	   }else if("launchImportProject".equalsIgnoreCase(strMode)){
			ProjectSpace project = new ProjectSpace();
		    FrameworkServlet framework = new FrameworkServlet();
			framework.removeFromGlobalCustomData(session, context, "fileContent");
			
		    Context contextDB = (matrix.db.Context)request.getAttribute("context");
			String newlyProjectCreatedId = request.getParameter("newObjectId");
			MapList importObjList = (MapList)session.getAttribute("importList");
			session.removeAttribute("importList");
			
			project.setId(newlyProjectCreatedId);
			
			project.completeImportProcess(contextDB, newlyProjectCreatedId, importObjList);
			
			//Change Discipline if Change Project
			if(isECHInstalled){	
				if(newlyProjectCreatedId!=null && !newlyProjectCreatedId.equalsIgnoreCase("")){
					if(project.isKindOf(contextDB, PropertyUtil.getSchemaProperty(context,"type_ChangeProject"))){
						
						Map requestMap = request.getParameterMap();
						Map paramMap = new HashMap(2);    				    		
		    			paramMap.put("newObjectId", newlyProjectCreatedId);    	
		    			paramMap.put("requestMap", requestMap);    	
		    			JPO.invoke(contextDB, "emxChangeTask", null, "setChangeDisciplineAttribute",JPO.packArgs(paramMap));			
					}
				}					
			}//End of Change Discipline if Change Project
			
			StringBuffer treeUrl = new StringBuffer("../common/emxTree.jsp?AppendParameters=true"+
	                  "&treeNodeKey=node.ProjectSpace&suiteKey=eServiceSuiteProgramCentral&objectId="+
	               	  XSSUtil.encodeForURL(newlyProjectCreatedId) + "&DefaultCategory=PMCGateDashboardCommandPowerView" + 
	                  "&emxSuiteDirectory=programcentral&treeTypeKey=type.Project");
			%>
		    <script language="javascript" type="text/javaScript">
			    var parentContentDetailsFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
               parentContentDetailsFrame.document.location.href = "<%= treeUrl %>";	<%-- XSSOK --%>
               parent.window.closeWindow();
               
		    </script>
		    <%
	   	} else if ("blankResourcePoolChart".equals(strMode)) {
				String strMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
						"emxProgramCentral.ResourcePlanning.Report.ClickOnChart", context.getSession().getLanguage());	
	%>			
				<div align='center'><%=strMessage%></div>
	<% 		
				return;
			} else if ("displayResourcePoolChart".equalsIgnoreCase(strMode)) {
				String strTimeStamp = emxGetParameter(request, "timeStamp");
				String url = "../programcentral/emxProgramCentralResourcePoolReportChart.jsp?timeStamp=" + XSSUtil.encodeForURL(context, strTimeStamp) ;
	%>
				<script language="javascript" type="text/javaScript">
					var url = "<%=url%>";	<%-- XSSOK --%>
					var topFrame = findFrame(getTopWindow(), "PMCResourcePoolReportChart");	
					topFrame.location.href = url;
				</script>
	<%
			}else if ("AddTaskBelow".equalsIgnoreCase(strMode)) 	{
			    String portalCommandName = emxGetParameter(request, "portalCmdName");
	    		String selectedNodeId = emxGetParameter(request, "emxTableRowId");
	    		String objectId = (String)(ProgramCentralUtil.parseTableRowId(context,selectedNodeId)).get("objectId");
	    		String parentId = (String)(ProgramCentralUtil.parseTableRowId(context,selectedNodeId)).get("parentOId");
	    		String rowId = (String)(ProgramCentralUtil.parseTableRowId(context,selectedNodeId)).get("rowId");
                        
                DomainObject object = DomainObject.newInstance(context, objectId);
                StringList selectList = new StringList(2);
                selectList.add(DomainObject.SELECT_CURRENT);
                selectList.add(SELECT_SHADOW_GATE_ID);
                selectList.add(DomainObject.SELECT_POLICY);

                Map taskInfo = object.getInfo(context, selectList);
                String selectedObjectState = (String)taskInfo.get(DomainObject.SELECT_CURRENT);
        		String sShadowGateId = (String)taskInfo.get(SELECT_SHADOW_GATE_ID);

        		if(sShadowGateId != null && !sShadowGateId.equals("")){
	    			%>
	    	    	   <script language="javascript" type="text/javaScript">
	    	    	   alert("<framework:i18nScript localize="i18nId">emxProgramCentral.DeliverablePlanning.CannnotAddSubTask</framework:i18nScript>");
	    	           </script>
	    	    	<%
	    	    	  return;
        		}
	    		
        		String policy = (String)taskInfo.get(DomainObject.SELECT_POLICY);
	    		String type = "type_Task";
	    		if(ProgramCentralConstants.POLICY_PROJECT_REVIEW.equalsIgnoreCase(policy))
	    		{
	    			type = "type_Gate";
	    		}
	    		
	    		objectId = XSSUtil.encodeURLForServer(context, objectId);
	    		parentId = XSSUtil.encodeURLForServer(context, parentId);
	    		
	    		StringList stateList = new StringList(3);
	    		stateList.addElement(ProgramCentralConstants.STATE_PROJECT_TASK_REVIEW);
	    		stateList.addElement(ProgramCentralConstants.STATE_PROJECT_REVIEW_COMPLETE);
	    		stateList.addElement(ProgramCentralConstants.STATE_PROJECT_REVIEW_ARCHIEVE);
	    			    		
	    		if(stateList.contains(selectedObjectState)){
	    			%>
	    	    	   <script language="javascript" type="text/javaScript">
	    	    	   alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState3</framework:i18nScript>");
	    	           </script>
	    	    	<%
	    	    	  return;
	    		}else{
		    		String strURL = "../common/emxCreate.jsp?typeChooser=false&nameField=both&type="+type+"&form=PMCProjectTaskCreateForm&mode=create&addTask=addTaskBelow&createJPO=emxTask:createNewTask&showApply=true&suiteKey=ProgramCentral&HelpMarker=emxhelpwbsadddialog&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral&submitAction=doNothing&postProcessURL=../programcentral/emxProgramCentralUtil.jsp?mode=addSubTaskBelow&objectId="+objectId+"&parentId="+parentId+"&rowId="+rowId+"&portalCmdName="+portalCommandName+"&PolicyName="+policy;
		    		%>
		        	<script language="javascript">
		        		var url = "<%=strURL%>"; <%-- XSSOK --%> 
		        		getTopWindow().showSlideInDialog(url,true);
		            </script> 
		    		<%   
	    		}		  
	        	
	    	} else if ("InsertTaskAbove".equalsIgnoreCase(strMode)) 	{
	    		String portalCommandName = emxGetParameter(request, "portalCmdName");
	    		String selectedNodeId = emxGetParameter(request, "emxTableRowId");
	    		String objectId = (String)(ProgramCentralUtil.parseTableRowId(context,selectedNodeId)).get("objectId");
	    		String parentId = (String)(ProgramCentralUtil.parseTableRowId(context,selectedNodeId)).get("parentOId");
	    		String rowId = (String)(ProgramCentralUtil.parseTableRowId(context,selectedNodeId)).get("rowId");
	    		
                DomainObject object = DomainObject.newInstance(context, parentId);
				StringList selectList = new StringList(2);
                selectList.add(DomainObject.SELECT_CURRENT);
                selectList.add(DomainObject.SELECT_POLICY);
                
                Map objectInfo = object.getInfo(context, selectList);
	    		String selectedObjectState = (String)objectInfo.get(DomainObject.SELECT_CURRENT);
	    		String policy = (String)objectInfo.get(DomainObject.SELECT_POLICY);
	    		String type = "type_Task";
	    		if(ProgramCentralConstants.POLICY_PROJECT_REVIEW.equalsIgnoreCase(policy))
	    		{
	    			type = "type_Gate";
	    		}

	    		StringList stateList = new StringList(3);
	    		stateList.addElement(ProgramCentralConstants.STATE_PROJECT_TASK_REVIEW);
	    		stateList.addElement(ProgramCentralConstants.STATE_PROJECT_REVIEW_COMPLETE);
	    		stateList.addElement(ProgramCentralConstants.STATE_PROJECT_REVIEW_ARCHIEVE);

	    		objectId = XSSUtil.encodeURLForServer(context, objectId);
	    		parentId = XSSUtil.encodeURLForServer(context, parentId);
	    		
	    		if(ProgramCentralUtil.isNotNullString(rowId) && "0".equals(rowId)){
	    			%>
	    	    	   <script language="javascript" type="text/javaScript">
	    	    	   alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.CannotInsertOnRoot</framework:i18nScript>");
	    	           </script>
	    	    	<%
	    	    	  return;
	    		}else if(stateList.contains(selectedObjectState)){
		    		%>
		        	<script language="javascript">
	    	    	   alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState3</framework:i18nScript>");
		            </script> 
		    		<%   
	    		}else{
	    			String strURL = "../common/emxCreate.jsp?type="+type+"&nameField=both&typeChooser=falsemode=create&addTask=addTaskAbove&createJPO=emxTask:createNewTask&form=PMCProjectTaskCreateForm&Header=CreateTask&showApply=true&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral&submitAction=doNothing&postProcessURL=../programcentral/emxProgramCentralUtil.jsp?mode=refreshInsertTaskAbove&HelpMarker=emxhelpwbsadddialog&objectId="+objectId+"&parentId="+parentId+"&rowId="+rowId+"&portalCmdName="+portalCommandName+"&PolicyName="+policy;
		    		
		    		%>
		        	<script language="javascript">
			        	var url = "<%=strURL%>";  <%-- XSSOK --%>
			        	getTopWindow().showSlideInDialog(url,true);
		            </script> 
		    		<%   	  
	    		}	
	        	
	    	}else if ("addTaskAssignee".equalsIgnoreCase(strMode)) 	{
	    	    String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
	    	    fieldNameDisplay = XSSUtil.encodeURLForServer(context, fieldNameDisplay);
	    	    String fieldNameActual = emxGetParameter(request,"fieldNameActual");
	    	    fieldNameActual = XSSUtil.encodeURLForServer(context, fieldNameActual);
	    	    String fieldNameOID = emxGetParameter(request,"fieldNameOID");
	    	    fieldNameOID = XSSUtil.encodeURLForServer(context, fieldNameOID);
	    	    String objectId = emxGetParameter(request,"objectId");
	    	    objectId = XSSUtil.encodeURLForServer(context, objectId);
	    	    
	    		 if(ProgramCentralUtil.isNullString(objectId)){
	    			 objectId = request.getParameter("parentOID");
	    		 }
	    		 String strURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=state_Active:USERROLE=Project User,VPLMViewer&table=PMCCommonPersonSearchTable&form=PMCCommonPersonSearchForm&includeOIDprogram=emxProgramCentralUtil:getIncludeOIDforProjectMemberPersonSearch&searchMode=GeneralPeopleTypeMode&selection=multiple&includeOIDprogram=emxTask:includeMembersToAddAsAssignee";
	    		 
	    		strURL +="&objectId="+objectId;
	    		strURL +="&submitURL=../common/AEFSearchUtil.jsp";
	    		strURL +="&fieldNameDisplay="+fieldNameDisplay;
	    		strURL +="&fieldNameActual="+fieldNameActual;
	    		strURL +="&fieldNameOID="+fieldNameOID;
	    		%>
	    			<script language="javascript">
	    				//var projectRole = top.window.opener.emxCreateForm.ProjectRoleId.value;
	    				var url = "<%=strURL%>";	<%-- XSSOK --%>
	    				//url = url + "&SelectedProjectRole="+projectRole;
	    				document.location.href = url;
	    			</script>
	    		<%
			}else if ("makeTaskOwner".equalsIgnoreCase(strMode)) 	{
	    	    String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
	    	    fieldNameDisplay = XSSUtil.encodeURLForServer(context, fieldNameDisplay);
	    	    String fieldNameActual = emxGetParameter(request,"fieldNameActual");
	    	    fieldNameActual = XSSUtil.encodeURLForServer(context, fieldNameActual);
	    	    String fieldNameOID = emxGetParameter(request,"fieldNameOID");
	    	    fieldNameOID = XSSUtil.encodeURLForServer(context, fieldNameOID);
	    	    String objectId = emxGetParameter(request,"objectId");
	    	    objectId = XSSUtil.encodeURLForServer(context, objectId);
	    	    
	    		 if(ProgramCentralUtil.isNullString(objectId)){
	    			 objectId = request.getParameter("parentOID");
	    		 }
	    		 
	    		 String strURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=state_Active:USERROLE=Project User,VPLMViewer&table=PMCCommonPersonSearchTable&form=PMCCommonPersonSearchForm&excludeOIDprogram=emxProgramCentralUtil:getexcludeOIDforPersonSearch&searchMode=GeneralPeopleTypeMode&selection=single&includeOIDprogram=emxTask:includeMembersToAddAsAssignee";
	    		strURL +="&objectId="+objectId;
	    		strURL +="&submitURL=../common/AEFSearchUtil.jsp";
	    		strURL +="&fieldNameDisplay="+fieldNameDisplay;
	    		strURL +="&fieldNameActual="+fieldNameActual;
	    		strURL +="&fieldNameOID="+fieldNameOID;
 		 	    		 
	    		%>
	    			<script language="javascript">
	    				var url = "<%=strURL%>";	<%-- XSSOK --%>
	    				document.location.href = url;
	    			</script>
	    		<%
			}else if ("addSubTaskBelow".equalsIgnoreCase(strMode)) 	{	    		
	    		Context contextDB = (matrix.db.Context)request.getAttribute("context");
	    		String portalCommandName = (String)emxGetParameter(request, "portalCmdName");
	    		String newTaskId = emxGetParameter(request, "newObjectId");
	    		newTaskId = XSSUtil.encodeURLForServer(context, newTaskId);
	    		String objectId = emxGetParameter(request, "objectId");
	    		objectId = XSSUtil.encodeURLForServer(context, objectId);
	    		
	    		DomainObject newObject = DomainObject.newInstance(contextDB, newTaskId);
	    		String relId =  newObject.getInfo(contextDB,"to[" + DomainRelationship.RELATIONSHIP_SUBTASK + "].id");
	    		relId = XSSUtil.encodeURLForServer(context, relId);
	    		
	    	    if(isECHInstalled){	    	    	
    		    	if(newTaskId!=null && !newTaskId.equalsIgnoreCase("")){    		    		
	    				if(newObject.isKindOf(contextDB, PropertyUtil.getSchemaProperty(context,"type_ChangeTask"))){	
	    					
	    					Map requestMap = request.getParameterMap();
							Map paramMap = new HashMap(2);    				    		
			    			paramMap.put("newObjectId", newTaskId);    	
			    			paramMap.put("requestMap", requestMap);  
			    			//Change Discipline if Change Task
			    			JPO.invoke(contextDB, "emxChangeTask", null, "setChangeDisciplineAttribute",JPO.packArgs(paramMap));		
			    			//Added for Applicability Context
			    			JPO.invoke(contextDB, "emxChangeTask", null, "setApplicabilityContext",JPO.packArgs(paramMap));		
	    		    	}
	    			}
	    	    }
	    		
	    		 boolean isFromRMB = "true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB"));
	    		  StringBuffer sBuff = new StringBuffer();
	    		    sBuff.append("<mxRoot>");
	    		    sBuff.append("<action><![CDATA[add]]></action>");

	    		    if (isFromRMB) {
	    		        sBuff.append("<data fromRMB=\"true\" status=\"committed\">");
    		    } else {
	    		    sBuff.append("<data status=\"committed\">");
	    		    }

	    		    sBuff.append("<item oid=\""+newTaskId+"\" relId=\""+relId+"\" pid=\""+objectId+"\"  direction=\""+"from"+"\" />");
	    		    sBuff.append("</data>");	    				
	    		    sBuff.append("</mxRoot>");
	    	  %>
	    	  <script language="javascript">
	    	  var frame = "<%=portalCommandName%>";
	    	  var topFrame = findFrame(getTopWindow(), frame);

	    	  if(null == topFrame){
	    	  	topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");	
	    	      if(null == topFrame)
	    	  		topFrame = findFrame(getTopWindow(), "detailsDisplay");	
	    	  }
	    	  
	    	  topFrame.emxEditableTable.addToSelected('<%=sBuff.toString()%>');
	    	  topFrame.emxEditableTable.refreshStructureWithOutSort();
	         </script>
	    	  <%  
	    	 
	    	}else if ("refreshInsertTaskAbove".equalsIgnoreCase(strMode)) 	{	    		
	    		Context contextDB = (matrix.db.Context)request.getAttribute("context");
		    	String portalCommandName = emxGetParameter(request, "portalCmdName");
	    		String newTaskId = emxGetParameter(request, "newObjectId");
	    		newTaskId = XSSUtil.encodeURLForServer(context, newTaskId);
	    		String objectId = emxGetParameter(request, "parentId");
	    		objectId = XSSUtil.encodeURLForServer(context, objectId);
	    		String rowId = emxGetParameter(request, "rowId");
	    		
	    		DomainObject newObject = DomainObject.newInstance(contextDB, newTaskId);
	    		String relId =  newObject.getInfo(contextDB,"to[" + DomainRelationship.RELATIONSHIP_SUBTASK + "].id");
	    		relId = XSSUtil.encodeURLForServer(context, relId);
	    		
	    	    if(isECHInstalled){
    		    	if(newTaskId!=null && !newTaskId.equalsIgnoreCase("")){    		    		
	    				if(newObject.isKindOf(contextDB, PropertyUtil.getSchemaProperty(context,"type_ChangeTask"))){	    					    				

	    					Map requestMap = request.getParameterMap();
							Map paramMap = new HashMap(2);    				    		
			    			paramMap.put("newObjectId", newTaskId);    	
			    			paramMap.put("requestMap", requestMap);  
			    			//Change Discipline if Change Task
			    			JPO.invoke(contextDB, "emxChangeTask", null, "setChangeDisciplineAttribute",JPO.packArgs(paramMap));		
			    			//Added for Applicability Context
			    			JPO.invoke(contextDB, "emxChangeTask", null, "setApplicabilityContext",JPO.packArgs(paramMap));		
			    			
	    		    	}
	    			}
	    	    }

	    		 boolean isFromRMB = "true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB"));
	    		  StringBuffer sBuff = new StringBuffer();
	    		    sBuff.append("<mxRoot>");
	    		    sBuff.append("<action><![CDATA[add]]></action>");

	    		    if (isFromRMB) {
	    		        sBuff.append("<data fromRMB=\"true\" status=\"committed\" pasteBelowOrAbove=\"true\">");
		    	}else {
	    		    sBuff.append("<data status=\"committed\" pasteBelowOrAbove=\"true\">");
	    		    }
	    		    sBuff.append("");
	    		    sBuff.append("<item oid=\""+newTaskId+"\" relId=\""+relId+"\" pid=\""+objectId+"\"  direction=\""+"from"+"\" pasteAboveToRow=\"" + rowId + "\"/>");
	    		    sBuff.append("</data>");
	    				
	    		    sBuff.append("</mxRoot>");
	    	  %>
	    	  <script language="javascript">
	    		var frame = "<%=portalCommandName%>";
	    	  	var topFrame = findFrame(getTopWindow(), frame);
	    	  if(null == topFrame){
	    	  	topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");	
				     if(null == topFrame){
	    	  		topFrame = findFrame(getTopWindow(), "detailsDisplay");	
	    	  }
			     }
		   	     
			     topFrame.emxEditableTable.addToSelected('<%=sBuff.toString()%>');
	    	  topFrame.emxEditableTable.refreshStructureWithOutSort();
	         </script>
	    	  <%  
	    	 
	    	} else if ("showCalendar".equalsIgnoreCase(strMode)) {
	    		
	    	    String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
	    	    fieldNameDisplay = XSSUtil.encodeURLForServer(context, fieldNameDisplay);
	    	    String fieldNameActual = emxGetParameter(request,"fieldNameActual");
	    	    fieldNameActual = XSSUtil.encodeURLForServer(context, fieldNameActual);
	    	    String fieldNameOID = emxGetParameter(request,"fieldNameOID");
	    	    fieldNameOID = XSSUtil.encodeURLForServer(context, fieldNameOID);
	    	    String objectId = emxGetParameter(request,"objectId");
	    	    objectId = XSSUtil.encodeURLForServer(context, objectId);
	    	    
	    		 if(ProgramCentralUtil.isNullString(objectId)){
	    			 objectId = request.getParameter("parentOID");
	    		 }
	    		 String strURL = "../common/emxFullSearch.jsp?field=TYPES=type_WorkCalendar&table=PMCTaskCalendarSearchTable&selection=single&excludeOIDprogram=emxProgramCentralUtil:getExcludeOIDForCalendar&hideHeader=true&submitURL=../programcentral/FullSearchUtil.jsp?mode=chooser&chooserType=CalendarChooser&fieldNameActual=Calendar&fieldNameDisplay=CalendarDisplay&HelpMarker=emxhelpfullsearch&sortColumnName=ProjectCalendar&sortDirection=descending";
	    		 strURL +="&objectId="+objectId;
	    		%>
	    			<script language="javascript">
	    				var url = "<%=strURL%>";	<%-- XSSOK --%>
	    				document.location.href = url;
	    			</script>
	    		<%
			}else if("setDefaultProjectCalendar".equalsIgnoreCase(strMode)){
				
			    String[] calendarIds = emxGetParameterValues(request,"emxTableRowId");
			    calendarIds = ProgramCentralUtil.parseTableRowId(context, calendarIds);
			    String defaultCalendarId = emxGetParameter(request,"DefaultCalendar");
			    
			    String strFieldNameDisplay = (String)emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_DISPLAY);
				String strFieldNameActual  = (String)emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_ACTUAL);
				
				strFieldNameDisplay = XSSUtil.encodeURLForServer(context, strFieldNameDisplay);
				strFieldNameActual = XSSUtil.encodeURLForServer(context, strFieldNameActual);
				StringList calendarSelectables = new StringList(ProgramCentralConstants.SELECT_NAME);
				calendarSelectables.add(ProgramCentralConstants.SELECT_ID);
				MapList calendarNameList = DomainObject.getInfo(context, calendarIds, calendarSelectables);
			    Iterator calendarNameListIterator = calendarNameList.iterator();
			    String displayValue = ProgramCentralConstants.EMPTY_STRING;
			    String actualValue = ProgramCentralConstants.EMPTY_STRING;
			    while(calendarNameListIterator.hasNext()){
			    	Map calendarMap = (Map)calendarNameListIterator.next();
			    	String calendarName = (String)calendarMap.get(ProgramCentralConstants.SELECT_NAME);
			    	String calendarId = (String)calendarMap.get(ProgramCentralConstants.SELECT_ID);
			    	
			    	if(ProgramCentralUtil.isNotNullString(displayValue)){
			    		displayValue = displayValue + " ,"+calendarName;
			    	} else {
			    		displayValue = calendarName;
			    	}
			    	
			    	if(calendarId.equals(defaultCalendarId)){
			    		calendarId = calendarId +"|DefaultCalendar";
			    	} 
			    	
			    	if(ProgramCentralUtil.isNotNullString(actualValue)){
			    		actualValue = actualValue + " ,"+calendarId;
			    	} else {
			    		actualValue = calendarId;
			    	}
			    	
			    }
			    %>
				<script language="javascript">
					var strfieldDisplay = "<%=strFieldNameDisplay%>";		<%-- XSSOK --%>	
			      	var strfieldNameActual = "<%=strFieldNameActual%>" ; 	<%-- XSSOK --%>

			      	var txtTypeDisplay = getTopWindow().getWindowOpener().document.forms[0].elements[strfieldDisplay];
			        var txtTypeActual = getTopWindow().getWindowOpener().document.forms[0].elements[strfieldNameActual];
				    
				    txtTypeDisplay.value = "<%=displayValue%>"; <%-- XSSOK --%>
				    txtTypeActual.value = "<%=actualValue%>";  <%-- XSSOK --%>
				    
				    getTopWindow().close();
				</script>
				<%
			} else if ("addCalendarToProject".equalsIgnoreCase(strMode)) 	{
	    	    String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
	    	    fieldNameDisplay = XSSUtil.encodeURLForServer(context, fieldNameDisplay);
	    	    String fieldNameActual = emxGetParameter(request,"fieldNameActual");
	    	    fieldNameActual = XSSUtil.encodeURLForServer(context, fieldNameActual);
	    	    String fieldNameOID = emxGetParameter(request,"fieldNameOID");
	    	    fieldNameOID = XSSUtil.encodeURLForServer(context, fieldNameOID);
	    	    String objectId = emxGetParameter(request,"objectId");
	    	    objectId = XSSUtil.encodeURLForServer(context, objectId);
	    	    
	    		 if(ProgramCentralUtil.isNullString(objectId)){
	    			 objectId = request.getParameter("parentOID");
	    		 }
	    		 String strURL = "../common/emxFullSearch.jsp?field=TYPES=type_WorkCalendar&table=PMCProjectCalendarSearchTable&selection=multiple&excludeOIDprogram=emxProjectSpace:getExcludeOIDForProjectCalendar&hideHeader=true&submitURL=../programcentral/emxProgramCentralUtil.jsp?mode=addCalendarToProjectProcess&chooserType=CalendarChooser&fieldNameActual=Calendar&fieldNameDisplay=CalendarDisplay&suiteKey=ProgramCentral&SuiteDirectory=programcentral&HelpMarker=emxhelpfullsearch";
	    		 strURL +="&objectId="+objectId;

	    		%>
	    			<script language="javascript">
	    				var url = "<%=strURL%>";	<%-- XSSOK --%>
	    				document.location.href = url;
	    			</script>
	    		<%
			} else if ("addCalendarToProjectProcess".equalsIgnoreCase(strMode)) {

				    String[] calendarIds = emxGetParameterValues(request,"emxTableRowId");
			        calendarIds = ProgramCentralUtil.parseTableRowId(context, calendarIds);
			        String defaultCalendarId = emxGetParameter(request,"DefaultCalendar");
				    String projectID = emxGetParameter(request,"objectId");
				    
				    DomainObject calendarObject    = DomainObject.newInstance(context);
				    DomainRelationship connnection = null;
				    ProjectSpace newProject =(ProjectSpace)DomainObject.newInstance(context,ProgramCentralConstants.TYPE_PROJECT_SPACE,DomainConstants.PROGRAM);
				    newProject.setId(projectID);
				    MapList calendarList = new MapList();
				    calendarList = newProject.getProjectCalendars(context);
				    for(Iterator iterator = calendarList.iterator(); iterator.hasNext();) {
			   			 Map calInfo            = (Map) iterator.next();
			   			 String relationshipName    = (String)calInfo.get(ProgramCentralConstants.KEY_RELATIONSHIP);
			   			 String connectionID = (String)calInfo.get(DomainRelationship.SELECT_ID);
			   			 if(ProgramCentralUtil.isNotNullString(defaultCalendarId) && ProgramCentralConstants.RELATIONSHIP_DEFAULT_CALENDAR.equalsIgnoreCase(relationshipName)){
			   				DomainRelationship.setType(context, connectionID, ProgramCentralConstants.RELATIONSHIP_CALENDAR);
			   			 }
			   		}
				    for(int i=0; i<calendarIds.length; i++){
						String strCalendarId = calendarIds[i];
					    calendarObject.setId(strCalendarId);
						
						if(ProgramCentralUtil.isNotNullString(defaultCalendarId) && defaultCalendarId.equalsIgnoreCase(strCalendarId)){
							
							connnection = DomainRelationship.connect(context, newProject, ProgramCentralConstants.RELATIONSHIP_DEFAULT_CALENDAR, calendarObject);
						}else {
							connnection = DomainRelationship.connect(context, newProject, ProgramCentralConstants.RELATIONSHIP_CALENDAR, calendarObject);
						}
					}
				    
				    //If default calendar is changed then we need to call the rollup 
				    if(ProgramCentralUtil.isNotNullString(defaultCalendarId) && ProgramCentralUtil.isNotNullString(projectID)){
				    	Task project = new Task(projectID);
				    	project.rollupAndSave(context);
				    }
				    %>
				 	<script language="javascript" type="text/javaScript">
				 	getTopWindow().getWindowOpener().refreshSBTable(getTopWindow().getWindowOpener().configuredTableName);
	       			getTopWindow().close(); 
				 	</script>
					<%
				   
			} else if ("removeCalendar".equalsIgnoreCase(strMode)) {
				
	     	    String calendarIdArray[] = emxGetParameterValues(request,"emxTableRowId");
	     	    calendarIdArray = FrameworkUtil.getSplitTableRowIds(calendarIdArray);
		  		String sSelectedTableRowIds = FrameworkUtil.join(calendarIdArray,",");
		  		String projectID = emxGetParameter(request,"objectId");
		  		
		  		calendarIdArray = ProgramCentralUtil.parseTableRowId(context, calendarIdArray);
			    StringList calendarIdsList = new StringList();
			    for(int i=0; i<calendarIdArray.length;i++){
			    	calendarIdsList.add(calendarIdArray[i]);
			    }
			    
			    boolean isDefault=false;
			    		  	 	
			    ProjectSpace project = (ProjectSpace) DomainObject.newInstance(context,DomainConstants.TYPE_PROJECT_SPACE,DomainConstants.PROGRAM);
		  	 	project.setId(projectID);
		  	 	String defaultCalendarId = project.getInfo(context, "from["+ProgramCentralConstants.RELATIONSHIP_DEFAULT_CALENDAR+"].to.id");
		  	 	
		  	 	if(ProgramCentralUtil.isNotNullString(defaultCalendarId) && calendarIdsList.contains(defaultCalendarId)){
		  	 		isDefault = true;
		  	 	}
		  	 	 	
		  	 	 	
				if(isDefault){
		  	 	 	 String strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=removeDefaultCalender&calIds="+sSelectedTableRowIds+"&projectID="+projectID;
	     	      	 %>
	 			  	<script language="javascript" type="text/javaScript">
	 			  	var result = confirm("<framework:i18nScript localize="i18nId">emxProgramCentral.Calendar.DefaultCalendarRemoveWarningMsg</framework:i18nScript>");
	     		  	if(result){
	     				  var URL = "<%=strURL%>";
	     			 	 document.location.href = URL;
	     	      	}
	     		 	</script><%	
	  	 	  	} else {
		  	 		project.removeCalendars(context, calendarIdsList);
			    %>
			 	<script language="javascript" type="text/javaScript">
			 	 var topFrame = findFrame(getTopWindow(), "detailsDisplay");
	    		 topFrame.location.href = topFrame.location.href; 		
			 	</script>
				  <%
	  	 	  	}
			  
			}else if("removeDefaultCalender".equalsIgnoreCase(strMode)) {
				
			     String calIds = emxGetParameter(request, "calIds");
			     String projectID = emxGetParameter(request, "projectID");
				 StringList calendarIdsList = FrameworkUtil.splitString(calIds,",");
				 ProjectSpace projectSpace = (ProjectSpace) DomainObject.newInstance(context,DomainConstants.TYPE_PROJECT_SPACE,DomainConstants.PROGRAM);
				 projectSpace.setId(projectID);
				 projectSpace.removeCalendars(context, calendarIdsList);
				 
				 //If default calendar is removed then we need to call the rollup 
				    if(ProgramCentralUtil.isNotNullString(projectID)){
				    	Task project = new Task(projectID);
				    	project.rollupAndSave(context);
				    }
				 
			    %>
			 	<script language="javascript" type="text/javaScript">
			 	 var topFrame = findFrame(getTopWindow(), "detailsDisplay");
	    		 topFrame.location.href = topFrame.location.href; 		
			 	</script>
				<%
			}else if ("defaultProjectCalendar".equalsIgnoreCase(strMode)) {
								   
				    String projectID = emxGetParameter(request,"parentId");
				    String newCalId = emxGetParameter(request,"objectId");
				    String rowId = emxGetParameter(request,"rowId");
				    String sRelId = emxGetParameter(request,"relId");
				    String subMode = emxGetParameter(request,"subMode");
				    DomainRelationship connnection = null;
				   
				    if("setAsDefaultProjectCalendar".equalsIgnoreCase(subMode)) {
				    MapList calendarList = new MapList();
				    ProjectSpace project = (ProjectSpace) DomainObject.newInstance(context,DomainConstants.TYPE_PROJECT_SPACE,DomainConstants.PROGRAM);
					project.setId(projectID);
				    calendarList = project.getProjectCalendars(context);
				    for(Iterator iterator = calendarList.iterator(); iterator.hasNext();) {
			   			 Map temp    = (Map) iterator.next();
			   			 String id   = (String)temp.get(DomainConstants.SELECT_ID);
			   			 String relationshipName    = (String)temp.get(ProgramCentralConstants.KEY_RELATIONSHIP);
			   			 String connectionID = (String)temp.get(DomainRelationship.SELECT_ID);
			   			 if(ProgramCentralConstants.RELATIONSHIP_DEFAULT_CALENDAR.equalsIgnoreCase(relationshipName)){
			   				DomainRelationship.setType(context, connectionID, ProgramCentralConstants.RELATIONSHIP_CALENDAR);
			   			 }
			   			 if(newCalId.equalsIgnoreCase(id)){
			   				DomainRelationship.setType(context, connectionID, ProgramCentralConstants.RELATIONSHIP_DEFAULT_CALENDAR);
			   			 }
			   		}
				  } else if("removeDefaultProjectCalendar".equalsIgnoreCase(subMode)){
					  
					  DomainRelationship.setType(context, sRelId, ProgramCentralConstants.RELATIONSHIP_CALENDAR);
				  }
				    
				    if(ProgramCentralUtil.isNotNullString(projectID)){
				    	Task project = new Task(projectID);
				    	project.rollupAndSave(context);
				    }
				 %>
				 <script language="javascript" type="text/javaScript">
				 	var topFrame = findFrame(getTopWindow(), "detailsDisplay");
		    		topFrame.location.href = topFrame.location.href; 
				    //contentFrameObj.refreshSBTable(contentFrameObj.configuredTableName);
		    	</script>
				<%
			     
		}else if ("ChangePolicy".equalsIgnoreCase(strMode)) {
				String selectedType = emxGetParameter(request,"SelectedType");
				JSONObject jsonObject = new JSONObject();
				
				StringList gateSubTypeList = ProgramCentralUtil.getSubTypesList(context, ProgramCentralConstants.TYPE_GATE);
			    StringList mileStoneSubTypeList = ProgramCentralUtil.getSubTypesList(context, ProgramCentralConstants.TYPE_MILESTONE);
			    
			    if(ProgramCentralUtil.isNotNullString(selectedType)){
			    	
			    	if(mileStoneSubTypeList.contains(selectedType) || gateSubTypeList.contains(selectedType)){
			    		jsonObject.put("Duration","0");
			    		jsonObject.put("Policy",ProgramCentralConstants.POLICY_PROJECT_REVIEW);
			    	}else{
			    		jsonObject.put("Duration","1");
			    	}
			    }
				
				out.clear();
				out.write(jsonObject.toString());
				return;
			}else if ("DnDWarningMsg".equalsIgnoreCase(strMode)) {
				JSONObject jsonObject = new JSONObject();
				String warnMsg = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.DragAndDrop.WarningMessage1", 
																							context.getSession().getLanguage());
				jsonObject.put("error",warnMsg);
				out.clear();
				out.write(jsonObject.toString());
				return;
			}else if ("DragAndDrop".equalsIgnoreCase(strMode)) {
				String targetObjectId 		= emxGetParameter(request,"targetObjectId");
				String targetObjectLevel 	= emxGetParameter(request,"targetObjectLevel");
				String targetObjectType 	= emxGetParameter(request,"targetObjectType");
				
				String draggedObjectId 		= emxGetParameter(request,"draggedObjectId");
				String draggedObjectLevel 	= emxGetParameter(request,"draggedObjectLevel");
				String draggedObjectType 	= emxGetParameter(request,"draggedObjectType");
				
				Map <String,String>programMap = new HashMap();
				programMap.put("targetObjectId",targetObjectId);
				programMap.put("targetObjectLevel",targetObjectLevel);
				programMap.put("targetObjectType",targetObjectType);
				programMap.put("draggedObjectId",draggedObjectId);
				programMap.put("draggedObjectLevel",draggedObjectLevel);
				programMap.put("draggedObjectType",draggedObjectType);
				
				String []args 				= JPO.packArgs(programMap);
				Map<String,String> validMap = ProgramCentralUtil.isValidDnDOperation(context, args);
				String action 				= validMap.get("Action");
				String errorMsg 			= validMap.get("Error");
				
				JSONObject jsonObject = new JSONObject();
				jsonObject.put("status",action);
	    		jsonObject.put("error",errorMsg);
	    		
				out.clear();
				out.write(jsonObject.toString());
				return;
				
		} else if ("updateSessionWithSummaryTasks".equalsIgnoreCase(strMode)) {
			StatusReport report = (StatusReport) session.getAttribute("store");
			MapList mlSummaryTasks = (MapList)report.getWBSSummaryTasks();
			session.putValue("objectList", mlSummaryTasks);
		    return;
		} else if ("getBadChars".equalsIgnoreCase(strMode)) {
		    String sInvalidChars = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.NameBadChars");
		    sInvalidChars = sInvalidChars.trim();
		    JSONObject jsonObject = new JSONObject();
			jsonObject.put("badChars", sInvalidChars);
			out.clear();
			out.write(jsonObject.toString());
			return;
		}else if("isRiskSelected".equalsIgnoreCase(strMode)){
			 String sErrMsg  = "";
			 String[] selectedids = request.getParameterValues("emxTableRowId");
			 String projectId = emxGetParameter( request, "parentOID");	   		 	
	   			String errorMessage = null;
	   			String riskCreationURL = null;
    		StringList requestIdList = new StringList();
    		boolean isInvalidRequest = false;
    		
    		if (selectedids != null && selectedids.length != 0) {
	   			   if (selectedids.length == 1) {
	   					String riskId =  ProgramCentralUtil.parseTableRowId(context,selectedids)[0];
	   					boolean isOfRiskType = 
	 	    				   ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_RISK,riskId);
	   					if (isOfRiskType) {	
	   						projectId = XSSUtil.encodeURLForServer(context,projectId);
		   					riskId = XSSUtil.encodeURLForServer(context,riskId);
		   					riskCreationURL = 
		   							"../common/emxForm.jsp?mode=edit&form=CreateNewRPN&portalMode=false&suiteKey=ProgramCentral&targetLocation=slidein&formHeader=emxProgramCentral.Risk.CreateRPN&PrinterFriendly=false&HelpMarker=emxhelprpncreatedialog&postProcessJPO=emxRPNBase:createNewRPN&findMxLink=false&submitAction=doNothing&postProcessURL=../common/SEMConnectExisting.jsp?mode=refresh"+
		   			   						"&objectId="+riskId;
		   					
	   					} else {
	   	   				 errorMessage = ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Common.PleaseSelectOneRisk",sLanguage);
	 	   			  %>
	 	   			  	<script language="javascript" type="text/javaScript">
         					alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.PleaseSelectOneRisk</emxUtil:i18nScript>");
         				</script>
	 	   			  <% 
	 	   			 return;
	 	   			 	}
	   			   } 
	   		   	} 
	   		   	
				if (ProgramCentralUtil.isNullString(errorMessage)) {
	   				%>
	     		 	<script language="javascript" type="text/javaScript">
	     		 	 	var riskCreationURL = "<%=XSSUtil.encodeForJavaScript(context,riskCreationURL)%>";
	     		 	 	getTopWindow().showSlideInDialog(riskCreationURL,true);
	     		 	</script>
	     			<%  
	   		   	}
		}else if("quickCreateRisk".equalsIgnoreCase(strMode)){
        	
	        	String projectId = emxGetParameter( request, "parentOID");
	        	String objectId = emxGetParameter( request, "objectId");
	        	
	        	if(!ProgramCentralUtil.isNullString(objectId)){
	        		if(ProgramCentralUtil.isNullString(projectId) || objectId != projectId){
	        			projectId = objectId;
	        		}
	        	}
	        	
	        	boolean isOfProjectType = ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_PROJECT_SPACE,projectId);
	        	Risk risk = new Risk();
	        	String name = new DomainObject().getUniqueName("R-");
	            risk.create(context, name,risk.POLICY_PROJECT_RISK);
	            String riskId = risk.getId(context);
				String timezone = (String)session.getValue("timeZone");
				String rValue = "1";

            	int eDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
       			java.text.DateFormat format = DateFormat.getDateTimeInstance(eDateFormat, eDateFormat, Locale.US);
            	Date  currentDate =  new Date();
            	String eDate=format.format(currentDate); 
    			double clientTZOffset = new Double(timeZone).doubleValue(); 

            	Map paramMap = new HashMap();
            	paramMap.put("objectId", riskId);
            	paramMap.put("languageStr", sLanguage);
            	
            	Map requestMap = new HashMap();
            	requestMap.put("mode", "quickCreateRisk");
            	requestMap.put("Probability",rValue);
            	requestMap.put("Impact",rValue);
            	requestMap.put("RPN", rValue);
            	requestMap.put("timeZone",timezone);
            	requestMap.put("EffectiveDate", eDate);
            	requestMap.put("timeZone",timezone);
            	requestMap.put("EstimatedEndDate", eDate);
            	requestMap.put("EstimatedStartDate", eDate);
            	requestMap.put("localeObj", Locale.US);
            	requestMap.put("parentOID", projectId);
            	
            	
            	Map ProgramMap = new HashMap();
            	ProgramMap.put("paramMap",paramMap);
            	ProgramMap.put("requestMap",requestMap);
            	Risk riskObject = new Risk();
            	
            	riskObject = risk.createRisk(context, ProgramMap);
            	String rpnRiskRelId = riskObject.getInfo(context,"to[Risk].id");
            	
    	       	String xmlMessage = "<mxRoot><action><![CDATA[add]]></action>";
    	       		   	xmlMessage +="<data status=\"committed\" fromRMB=\"" + false + "\">";
    	       		   	xmlMessage +="<item oid=\"" + riskId + "\" relId=\"" + rpnRiskRelId + "\" pid=\"" + projectId + "\"/>"; 
    	       			xmlMessage +="</data></mxRoot>";
     	    	%>
     		 	<script language="javascript" type="text/javaScript">
     		 	/*if(<%=isOfProjectType%> == true){
     		 	var topFrame = findFrame(getTopWindow(),"PMCProjectRisk");
     		 	}else{*/
     		 		var topFrame = findFrame(getTopWindow(),"detailsDisplay");
     		 	//}
    	            topFrame.emxEditableTable.addToSelected('<%=XSSUtil.encodeForJavaScript(context,xmlMessage)%>');
    	            topFrame.refreshStructureWithOutSort();
     		 	</script>
     		  <%

     } else if ("businessUnitSelectorForEditDetails".equalsIgnoreCase(strMode)) {
			String fieldNameDisplay = request.getParameter("fieldNameDisplay");
		    fieldNameDisplay = XSSUtil.encodeURLForServer(context, fieldNameDisplay);
		    String fieldNameActual = request.getParameter("fieldNameActual");
		    fieldNameActual = XSSUtil.encodeURLForServer(context, fieldNameActual);
		    String fieldNameOID = request.getParameter("fieldNameOID");
		    fieldNameOID = XSSUtil.encodeURLForServer(context, fieldNameOID);
		    String url="../common/emxFullSearch.jsp?field=TYPES=type_Company,type_BusinessUnit&table=PMCOrganizationSummary&hideHeader=true&selection=single&submitAction=refreshCaller&showInitialResults=true";
		    url +="&submitURL=../common/AEFSearchUtil.jsp";
		    url +="&fieldNameDisplay="+XSSUtil.encodeURLForServer(context,fieldNameDisplay);
		    url +="&fieldNameActual="+XSSUtil.encodeURLForServer(context,fieldNameActual);
		    url +="&fieldNameOID="+XSSUtil.encodeURLForServer(context,fieldNameOID);
		    %>
	          <script language="javascript">
		        <%-- XSSOK--%>
		      	document.location.href ='<%=url%>';
	    	  </script> 
		   <%
		} else if("createQuickFolder".equalsIgnoreCase(strMode)){
    		    boolean isRefresh 			= true;
    		    String xmlMessage 			= DomainObject.EMPTY_STRING;
    		    StringList newFolderIdList 	= new StringList();
    			String tableRowId 			= request.getParameter("emxTableRowId");
    			Map rowIdMap 				= ProgramCentralUtil.parseTableRowId(context, tableRowId);
    			String parentId 			= (String)rowIdMap.get("objectId");
    			String rowId 				= (String)rowIdMap.get("rowId");
    			String relationship 		= DomainConstants.RELATIONSHIP_PROJECT_VAULTS;

    			String folderAccessType 	= request.getParameter("PMCFolderInheritAccess");
    			String selectedFolderType 	= request.getParameter("PMCFolderTypeToAddBelow");
    			String folderToAdd 			= request.getParameter("PMCFolderToAddBelow");
    			int nfolderToAdd 			= 1;
    			
                        boolean isOfProjectTemplateType = ProgramCentralUtil.isOfGivenTypeObject(context, DomainConstants.TYPE_PROJECT_TEMPLATE,objId);

    			if(selectedFolderType.equalsIgnoreCase("Workspace Folder")){
    				selectedFolderType = DomainObject.TYPE_WORKSPACE_VAULT;
    			}
    			
    			try{
    				nfolderToAdd = Integer.parseInt(folderToAdd);
    			}catch(Exception e){
    				nfolderToAdd = 1;
    			}
    			
    			if(ProgramCentralUtil.isNullString(parentId)){
    				parentId = request.getParameter("parentOID");
    			}
    			
    			if(ProgramCentralUtil.isNotNullString(parentId)){
    				JSONObject folderInfo 		= new JSONObject();
    				DomainObject parentObject 	= DomainObject.newInstance(context, parentId);
    				
    				try{
    					PMCWorkspaceVault folder 	= new PMCWorkspaceVault();
    				
    					StringList selectable 		= new StringList(2);
    					selectable.addElement(ProgramCentralConstants.SELECT_IS_WORKSPACE_VAULT);
    					selectable.addElement(DomainObject.SELECT_TYPE);
	    				
    					Map parentObjectInfoMap = parentObject.getInfo(context, selectable);
    					String parentType 		= (String)parentObjectInfoMap.get(DomainObject.SELECT_TYPE);
    					String isWorkspaceVault = (String)parentObjectInfoMap.get(ProgramCentralConstants.SELECT_IS_WORKSPACE_VAULT);
    					
	    				folderInfo.put("parentId", parentId);
	    				folderInfo.put("parentType", parentType);
	    				folderInfo.put("folderType", selectedFolderType);
	    				folderInfo.put("folderToAdd", String.valueOf(nfolderToAdd));
	    				folderInfo.put("folderAccessType", folderAccessType);
	    				folderInfo.put("isWorkspaceVault", isWorkspaceVault);
	    				
	    				if("true".equalsIgnoreCase(isWorkspaceVault)){
	    					relationship = DomainConstants.RELATIONSHIP_SUB_VAULTS;
	    					
	    					if(selectedFolderType.equalsIgnoreCase(parentType)){
	    						 newFolderIdList = folder.create(context,folderInfo);
	    					}else{
	    						 String warnMsg = ProgramCentralUtil.getPMCI18nString(context, 
	    								"emxProgramCentral.QuickFolder.WarningMessage", context.getSession().getLanguage());
	    						 isRefresh = false;
	    						%>
	    		    			<script language="javascript">
	    		    				var alertMsg = "<%=warnMsg%>";
	    			    			alert(alertMsg);
	    		    			</script>
	    		    			<%
	    					}
	    				}else{
	    					 newFolderIdList = folder.create(context,folderInfo);
	    				}
	    				
	    				folderInfo.put("rowId", rowId);
	    				folderInfo.put("relationship", relationship);
	    				
                        //NX5 - #6868 Quick create toolbar on Template not setting Co-Owner access
                        // Template revision is not happening
                        if(isOfProjectTemplateType) {

                            for ( Object obj: newFolderIdList) {
                                String id = (String) obj;
                                DomainObject objFolder 	= DomainObject.newInstance(context, id);
                                HashMap programMap = new HashMap();
                                HashMap paramMap = new HashMap();
                                HashMap requestMap = new HashMap();

                                paramMap.put("objectId",  id);

                                // Transaztion - object is returning "auto_11111" name type
                             // requestMap.put("Name",       (String) objFolder.getInfo(context, DomainConstants.SELECT_NAME));

                                String sName = objFolder.getAttributeValue(context, DomainConstants.ATTRIBUTE_TITLE);
                                requestMap.put("Name",       sName);
                                requestMap.put("AccessType", folderAccessType);
                                requestMap.put("Policy",     selectedFolderType);

                                requestMap.put("parentOID", objId);         // The Project Template
                                requestMap.put("IgnoreNameChk", "true");    // Added for this invocation of JPO

                                // requestMap.put("IsClone", "false");
                                // requestMap.put("emxTableRowId", "true");
                                // requestMap.put("DefaultAccess", null);    // Can be null
                                // requestMap.put("Description", "");
                                // requestMap.put("oldObjectId", "true");  // Only if isClone

                                programMap.put("paramMap", paramMap);
                                programMap.put("requestMap", requestMap);

                                String[] progArgs;
                                progArgs = JPO.packArgs(programMap);
                                JPO.invoke(context, "emxProjectFolder", null, "postProcessActions", progArgs);
                            }
                        }
                        // NX5 - End
	    				
	    				xmlMessage = folder.refreshFolderStructure(context, parentObject, newFolderIdList, folderInfo);
	    				
    				}catch(Exception e){
    					isRefresh = false;
    					e.printStackTrace();
    				}
    			}
    			%>
    			<script language="javascript">
    				var isRefreshes = "<%=isRefresh%>";
    				if(isRefreshes=="true"){
		    			var topFrame = findFrame(getTopWindow(), "detailsDisplay"); 
        				topFrame.emxEditableTable.addToSelected('<%=xmlMessage%>');
        				topFrame.refreshStructureWithOutSort();
    				}
    			</script>
    			<%
    		} else if("chainTask".equalsIgnoreCase(strMode)){
			
				String strSelectedIds = (String) emxGetParameter(request, "selectedIds");
				StringList selectedIds = FrameworkUtil.split(strSelectedIds, ",");
			
				Task task = new Task();
				Map errorMassageMap = task.chainWBSTask(context, selectedIds);
				
				if(!errorMassageMap.isEmpty()){
					Object errorMessage = errorMassageMap.get("error");
				
	    		 %>
	    		 	<script language="javascript" type="text/javaScript">
 		 				alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage.toString())%>");
 		 			</script>
	    		  <%
	    		 return;
				}
%>
				<script language="javascript" type="text/javaScript">
					parent.emxEditableTable.refreshStructureWithOutSort();
					parent.rebuildView();
				</script>	
<%
	    } else if("deleteRelatedProject".equalsIgnoreCase(strMode)){
         			
         			String[] emxTableRowId = emxGetParameterValues(request, "emxTableRowId");
         			if ( emxTableRowId != null )
    			       {
    			    	   String projId="";
    			           String relId = "";
    			           String intermediate="";
    			           int numProjects = emxTableRowId.length;
    			           int index;
    			           DomainObject domObj;
    			           String projectIdList[] = new String[numProjects];
    			           String state = DomainConstants.EMPTY_STRING;
    			           boolean beyondCreate =false;
    			           String beyondcreateprojects = DomainConstants.EMPTY_STRING;
    			           StringList selectable =new StringList();
    			           selectable.add(DomainConstants.SELECT_CURRENT);
    			           selectable.add(DomainConstants.SELECT_NAME);
    			           boolean flag=false;
    			           for (int i=0; numProjects>i; i++) 
    			           {
    			             if(emxTableRowId[i].indexOf("|") != -1 )
    			             {
    			                  relId = emxTableRowId[i].substring(0,emxTableRowId[i].indexOf("|"));
    			                  if("".equalsIgnoreCase(relId))
    			                  {
    			                	  flag = true;
    			                      break;
    			                  }else if(!"".equalsIgnoreCase(relId))
    			                  {
    			                    index=emxTableRowId[i].indexOf("|");
    			                    intermediate=emxTableRowId[i].substring(index+1,emxTableRowId[i].lastIndexOf("|"));
    			                    projId=intermediate.substring(0,intermediate.indexOf("|"));
    			                    projectIdList[i]=projId;
    			                  }
    			             }
    			          }
    			           if(flag){
      	    	        	 %>
  	    	                   <script language="javascript" type="text/javaScript">
  	    	                    alert("<framework:i18nScript localize="i18nId">emxProgramCentral.RootProjectDelete</framework:i18nScript>");
  	    	                   </script> 
  	    	                <% 
  	    	             } else {   	    	         
     	         	          
    			           try{ 
    			        	    MapList infoList = DomainObject.getInfo(context, projectIdList, selectable);
    				  	 		for(int j=0; j<infoList.size(); j++){
    				  	 			Map info = (Map)infoList.get(j);
    				  	 			state = (String)info.get(DomainConstants.SELECT_CURRENT);
    				  	 			if(!state.equalsIgnoreCase("create")){
    				  	 				beyondcreateprojects +=  (String)info.get(DomainConstants.SELECT_NAME) +"\\n";
    				  	 				beyondCreate=true; 
    				  	 			}
    				  	 		}
    			        	    if(beyondCreate){
    			        		   %>
			                        <script language="javascript" type="text/javaScript">
			                        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.UnableToDeleteProjects</framework:i18nScript>\n\n<%=beyondcreateprojects%>");
			                        </script>
			                      <%
    			        	    }else{    				  	 		
			                    DomainObject.deleteObjects(context,projectIdList);
			                    %>
			                    <script language="javascript" type="text/javaScript">
			                    var topFrame = findFrame(getTopWindow(), "PMCRelatedProjects");
			    	    		topFrame.location.href = topFrame.location.href; 
			                     </script>
			                    <% 
    			        	   }
			               } catch(Exception e) {
			                    	%>
			                        <script language="javascript" type="text/javaScript">
			                        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.UnableToDeleteProjects</framework:i18nScript>");
			                        </script>
			                        <%
			               }
    	            }
   	        }
       } else  if("removeRelatedProject".equalsIgnoreCase(strMode)) {
    	    	String[] emxTableRowId = emxGetParameterValues(request, "emxTableRowId");
    	   	    final String RELATIONSHIP_RELATED_PROJECTS = PropertyUtil.getSchemaProperty (context, "relationship_RelatedProjects");
    	    	boolean flag=false;
    	    	      if ( emxTableRowId != null ) 
    	    	        {
    	    	          int numProjects = emxTableRowId.length;
    	    	          String strProjObjId = "";
    	    	           flag=false;
    	    	           String projectIdList[] = new String[numProjects];
    	    	           for (int i=0; numProjects>i; i++) 
    	    	           {
    	    	              if(emxTableRowId[i].indexOf("|") != -1 )
    	    	              {
    	    	              strProjObjId = emxTableRowId[i].substring(0,emxTableRowId[i].indexOf("|"));
    	    	                if(strProjObjId.equalsIgnoreCase(""))
    	    	                {
    	    	                  flag=true;
    	    	                  break;
    	    	                }
    	    	              } else {
    	    	              strProjObjId = emxTableRowId[i];
    	    	              }
    	    	              projectIdList[i] =strProjObjId;
    	    	         }
    	    	         if(flag){
    	    	        	 %>
	    	                   <script language="javascript" type="text/javaScript">
	    	                   alert("<framework:i18nScript localize="i18nId">emxProgramCentral.RootProjectRemove</framework:i18nScript>");
	    	                   </script> 
	    	                <% 
	    	             }else if(!flag){   	    	         
   	         	           DomainRelationship.disconnect(context, projectIdList);
   	         	           %>
   	         	           <script language="javascript" type="text/javaScript">
    	    			   var topFrame = findFrame(getTopWindow(), "PMCRelatedProjects");
						   topFrame.location.href = topFrame.location.href;
						  </script>
   	         	          <%
   	    	            }
    	    	    }
	} else  if("deleteCalender".equalsIgnoreCase(strMode)) {
		
			String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
			if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
				return;
			}
			 String calendarIdArray[] = emxGetParameterValues(request,"emxTableRowId");
			 boolean hasTaskConected = false;
			 String taskId = DomainConstants.EMPTY_STRING;
		  	 StringList selectableList = new StringList();
		  	 selectableList.add("to[Calendar].from.id");
		  	
		  	 if(calendarIdArray != null) {
		  		 
		  		calendarIdArray = FrameworkUtil.getSplitTableRowIds(calendarIdArray);
		  		String sSelectedTableRowIds = FrameworkUtil.join(calendarIdArray,",");
		  		
	  	 	  	MapList infoList = DomainObject.getInfo(context, calendarIdArray, selectableList);
	  	 	  	
	  	 		for(int j=0; j<infoList.size(); j++) {
	  	 			Map info = (Map)infoList.get(j);
	  	 			taskId = (String)info.get("to[Calendar].from.id");
	  	 			if(taskId != null) {
	  	 				hasTaskConected=true; 
	  	 				break;
	  	 		 	}
	  	 		}
	  	 	  	if(hasTaskConected){
		  	 	 	 String strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=deleteCalenderAction&calIds="+sSelectedTableRowIds;
	     	      	 %>
	 			  	<script language="javascript" type="text/javaScript">
	 			  	var result = confirm("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.UnableToDeleteCalendar</framework:i18nScript>");
	     		  	if(result){
	     				  var URL = "<%=strURL%>";
	     			 	 document.location.href = URL;
	     	      	}
	     		 	</script><%	
	  	 	  	} else {
		  	 	  	DomainObject.deleteObjects(context,calendarIdArray);
		  	 	 	%>
				  	 <script language="Javascript">
		 	  	  	 parent.location.href = parent.location.href;
		           	</script><%
	  	 	  	}
		 	}
   } else if("deleteCalenderAction".equalsIgnoreCase(strMode)) {
						
		     String calIds = emxGetParameter(request, "calIds");
			 StringList calenderIdList = FrameworkUtil.splitString(calIds,",");
			 int length = calenderIdList.size();
			 String[] resultStringList=new String[length];
			 for(int i=0; i<length; i++){
					 resultStringList[i]=(String)calenderIdList.get(i);
			 }
			 try {
				 ProgramCentralUtil.pushUserContext(context);
				 DomainObject.deleteObjects(context, resultStringList);
			 } finally {
				 ProgramCentralUtil.popUserContext(context);
			 }
	    %>
		    <script language="Javascript">
	 		parent.location.href = parent.location.href;
		    </script> 
<%
		} else if("contentReport".equalsIgnoreCase(strMode)){
			
		String selectedIds="";
	    String formURL = "";
	    
		String objectId    = emxGetParameter(request,"objectId");
		String[] tableRowIds = emxGetParameterValues(request,"emxTableRowId");
		String strLanguage= context.getSession().getLanguage();
		String[] strProjectVaultRowIds = emxGetParameterValues(request, "emxTableRowId");
		String[] ProjectVaultTokensArr = new String[4];
		String strProjectVaultId = null;
		StringList slProjectVaultIds = new StringList();
		DomainObject domainObject = new DomainObject();
		domainObject.setId(objectId);
		int size = strProjectVaultRowIds.length;
		String IS_KINDOF_WORKSPACE_VAULT = "type.kindof["+ DomainConstants.TYPE_WORKSPACE_VAULT + "]";
		  
		String[] vaultIds = new String[size];
		for (int i = 0; i < size; i++) {
			  ProjectVaultTokensArr = strProjectVaultRowIds[i].split("\\|");
			  strProjectVaultId = ProjectVaultTokensArr[1];
			vaultIds[i] = strProjectVaultId;
		}

		StringList objectSelects = new StringList();
		objectSelects.add(DomainConstants.SELECT_ID);
		objectSelects.add(IS_KINDOF_WORKSPACE_VAULT);
		MapList objectList = domainObject.getInfo(context, vaultIds,objectSelects);
		  String objectType = (String)domainObject.getInfo(context, DomainConstants.SELECT_TYPE);

		for (int i = 0; i < size; i++) {
			Map objectMap = (Map) objectList.get(i);
			if ("FALSE".equalsIgnoreCase(IS_KINDOF_WORKSPACE_VAULT)) {
				String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral","emxProgramCentral.Common.SelectFoldersOnly",strLanguage);
			              %>
						<script language="JavaScript" type="text/javascript">
							    alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
							    window.closeWindow();
						</script>
		<%return;
			     }
		String vaultId = (String)objectMap.get(DomainConstants.SELECT_ID);
		slProjectVaultIds.add(vaultId);
		  }

		 if(ProgramCentralConstants.TYPE_PROJECT_TEMPLATE.equalsIgnoreCase(objectType)){
		 formURL="../common/emxForm.jsp?form=PMCProjectTemplateFolderContentReportForm&suiteKey=ProgramCentral&formHeader=emxProgramCentral.Common.FolderContentReport&selectedIds="+slProjectVaultIds+"&objectId="+objectId+"&HelpMarker=emxhelpfoldercontentreport";
		 }
		 else{
			 formURL="../common/emxForm.jsp?form=PMCProjectFolderContentReportForm&suiteKey=ProgramCentral&formHeader=emxProgramCentral.Common.FolderContentReport&selectedIds="+slProjectVaultIds+"&objectId="+objectId+"&HelpMarker=emxhelpfoldercontentreport";
		 }
		 response.sendRedirect(formURL);
		 %>
		<script language="javascript" type="text/javaScript">
			document.hiddenForm.submit();
		</script>
<%
			}else if("deleteAssessment".equalsIgnoreCase(strMode)){
				 String[] selectedIds = emxGetParameterValues(request,"emxTableRowId");  
				  String[] strObjectIDArr    = new String[selectedIds.length];
				  String sObjId = "";
				  for(int i=0; i<selectedIds.length; i++)
					  {
						 String sTempObj = selectedIds[i];
						 Map mParsedObject = ProgramCentralUtil.parseTableRowId(context,sTempObj);
						 sObjId = (String)mParsedObject.get("objectId");
						 strObjectIDArr[i] = sObjId;	
					  } 
				  if ( strObjectIDArr != null )
				  {
				      try
				      {
				    	  DomainObject.deleteObjects(context,strObjectIDArr);
				      }  
				      catch(Exception e)
				      {
				        session.setAttribute("error.message", e.getMessage());
				      }
				  }
				  %>
			<script language="javascript" type="text/javaScript">
				var topFrame = findFrame(getTopWindow(), "PMCAssessment");
				topFrame.location.href = topFrame.location.href;
			</script>
<%
   } else if("translateErrorMsg".equalsIgnoreCase(strMode)){
		String key = request.getParameter("key");
		JSONObject jsonObject = new JSONObject();
		String errorMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
				key, context.getSession().getLanguage());
		jsonObject.put("Error",errorMsg);

		out.clear();
		out.write(jsonObject.toString());
		return;
  } else if("importProjectSchedule".equalsIgnoreCase(strMode)){
	 
	  	ProjectSpace project =(ProjectSpace) DomainObject.newInstance(context,DomainConstants.TYPE_PROJECT_SPACE, DomainConstants.PROGRAM);
		Context contextDB = (matrix.db.Context)request.getAttribute("context");
		FrameworkServlet framework = new FrameworkServlet();
		framework.removeFromGlobalCustomData(session, context, "fileContent");
			
		String objectId = emxGetParameter(request,"objectId");
		MapList importObjList = (MapList)session.getAttribute("importList");
		session.removeAttribute("importList");
			
		project.setId(objectId);
		project.completeImportProcess(contextDB, objectId, importObjList);
		
 } else if("getScheduleTasksPreview".equalsIgnoreCase(strMode)) {
	 
		String selectedProjectId = emxGetParameter(request,"searchProjectId");
	  	StringList sourceTaskIdList = FrameworkUtil.split(selectedProjectId,"|");
	  	String[] sourceTaskIdArray = new String[sourceTaskIdList.size()];
	  	sourceTaskIdList.toArray(sourceTaskIdArray);
  		
	  	CacheUtil.setCacheObject(context, "taskIdList", sourceTaskIdList);
	     	return;

} else if("copyRisk".equalsIgnoreCase(strMode)) {

	    String parentId = emxGetParameter(request,"objectId");
	    boolean isOfProjectType = ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_PROJECT_SPACE,parentId);	     
	    
	    String[] selectedRiskRowId = emxGetParameterValues(request,"emxTableRowId");
	    selectedRiskRowId = ProgramCentralUtil.parseTableRowId(context, selectedRiskRowId);
	    for(int i=0;i<selectedRiskRowId.length;i++){
	    	 String selectedRiskId = selectedRiskRowId[i];
	    	 String riskAttachment = request.getParameter(selectedRiskId);
	    	 boolean copyFile = Boolean.parseBoolean(riskAttachment);
	    	 Risk risk = new Risk(selectedRiskId);
	    	 risk.copyRisk(context, parentId, copyFile);
	    }
		%>
		 	<script language="javascript" type="text/javaScript">
		 	if(<%=isOfProjectType%> == true){
		 	var riskFrame = findFrame(getTopWindow().window.getWindowOpener().parent,"PMCProjectRisk");
		 	}else{
		 		var riskFrame = findFrame(getTopWindow().window.getWindowOpener().parent,"detailsDisplay");
		 	}
		 	riskFrame.location.href = riskFrame.location.href;				 
		 	parent.window.closeWindow();
		 	</script>
			  <%
	} else if("updateTaskPercentageComplete".equalsIgnoreCase(strMode)){
		String sOID = emxGetParameter(request, "objectId");
		String sValue = emxGetParameter(request, "newValue");

		String SUBTASK_IDS = "from[" + DomainConstants.RELATIONSHIP_SUBTASK + "].to.id";
		StringList busSelects = new StringList();
		busSelects.add(DomainConstants.SELECT_NAME);
		busSelects.add(SUBTASK_IDS);
		
		DomainObject task = DomainObject.newInstance(context, sOID);
		Map taskInfoMap = task.getInfo(context, busSelects);
		StringList subTasksList = (StringList)taskInfoMap.get(SUBTASK_IDS);
        boolean isSummaryTask = (subTasksList != null && subTasksList.size() != 0);
        
        if(!isSummaryTask){
		Map paramMap = new HashMap();
		paramMap.put("objectId", sOID);
		paramMap.put("New Value", sValue);
		
		Map programMap = new HashMap();
		programMap.put("paramMap", paramMap);
		
		JPO.invoke(context, "emxTask", null, "updateTaskPercentageComplete", JPO.packArgs(programMap), Map.class);	
		if("100.0".equals(sValue)){
		%>			
			<script language="javascript" type="text/javaScript">			       	
			 parent.location.href = parent.location.href;
			</script>
		<%}else{%>
			<script language="javascript" type="text/javaScript">			
        	 parent.emxEditableTable.refreshStructureWithOutSort();
			</script>
		<%}
        } else {
        	String errorMessage = "emxProgramCentral.WBS.PercentageCompletedCannotChangeForParent";
        	String key[] = {"TaskName"}; 
        	String value[] = {(String)taskInfoMap.get(DomainConstants.SELECT_NAME)};
        	errorMessage = ProgramCentralUtil.getMessage(context, errorMessage, key, value, null);
    %>
			<script language="javascript" type="text/javaScript">
				alert("<%= errorMessage %>");   									<%--XSSOK--%>
		 	</script>
	<%
        }
	} else if("postRefresh".equalsIgnoreCase(strMode)) {
		String portalCommandName = (String)emxGetParameter(request, "portalCmdName");
	%>
		<script language="javascript" type="text/javaScript">			
  	  var frame = "<%=portalCommandName%>";
	  var topFrame = findFrame(getTopWindow(), frame);
	      if(null == topFrame)
	  		topFrame = findFrame(getTopWindow(), "detailsDisplay");	
	  
	  topFrame.emxEditableTable.refreshStructureWithOutSort();
		</script>	
	<%
	}else if("taskIndentation".equalsIgnoreCase(strMode)){
		        
	     		Map requestMap 			= new HashMap();
	     		StringList slSelectedId = new StringList();
	
	     		String sMode 			= emxGetParameter(request,"SubMode");
	     		String portalCmd 		= (String)emxGetParameter(request,"portalCmdName");
	     		portalCmd 				= UIUtil.isNullOrEmpty(portalCmd)?DomainObject.EMPTY_STRING: portalCmd;
	     		String strProjectId 	= (String)emxGetParameter(request,"parentOID");
	     		String []strTableRowId 	= emxGetParameterValues(request,"emxTableRowId");
	     		MapList mlSelectedTaskInfoList = new MapList();
	     		 
	     		StringList rowIdList 	= new StringList();
	     		Map rowIdMap 			= new HashMap();
	     		
	     		if(strTableRowId == null){
	     			return;
	     		}
	
	     		for(int i=0;i<strTableRowId.length;i++){
					String sRowId 				= strTableRowId[i];
					Map mpRowDetails 			= (Map)ProgramCentralUtil.parseTableRowId(context,sRowId);
					String strSelectedTaskId 	= (String)mpRowDetails.get("objectId");
					String rowId 				= (String)mpRowDetails.get("rowId");
				
					Task task 			= new Task(strSelectedTaskId);
					String taskState = (String)task.getInfo(context, DomainConstants.SELECT_CURRENT);
				if(!(ProgramCentralConstants.STATE_PROJECT_TASK_REVIEW.equalsIgnoreCase(taskState) || ProgramCentralConstants.STATE_PROJECT_TASK_COMPLETE.equalsIgnoreCase(taskState))){
					slSelectedId.addElement(strSelectedTaskId);
					rowIdList.addElement(rowId);
					rowIdMap.put(strSelectedTaskId, rowId);
				}else {
			         	String errorMessage = 
	    	    				ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.cutTask.IndentationNotice",sLanguage);
	    	    		 %>
	    	    		 	<script language="javascript" type="text/javaScript">
	     		 				alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
    	 		 			</script>
	    	    		  <%
	    	    		 return;
			         }
					
			    }
	     		   
	     		requestMap.put("projectId",strProjectId);
	     		requestMap.put("selectedTaskIdList",slSelectedId);
	     		requestMap.put("rowIdMap",rowIdMap);
	     		requestMap.put("rowIdList",rowIdList);
	     		requestMap.put("PortalCmd",portalCmd);
	     		session.setAttribute("IndentaionInfoMap", requestMap);
	     		
	     		String strUrl = DomainObject.EMPTY_STRING;
	     		if(Task.LEFT_INDENTAION.equalsIgnoreCase(sMode)){
		     		 strUrl  = "../programcentral/emxProgramCentralUtil.jsp?mode=Left&portalCmd="+portalCmd+"&projectId="+strProjectId;
	     		}else if(Task.RIGHT_INDENTAION.equalsIgnoreCase(sMode)){
	     			strUrl  = "../programcentral/emxProgramCentralUtil.jsp?mode=Right&portalCmd="+portalCmd+"&projectId="+strProjectId;
	     		}
	     		%>
	     			<script language="javascript">
	     				var portalName = "<%=portalCmd%>";
	     				var topFrame = findFrame(getTopWindow(), portalName);

	     				if(topFrame == null){
	     					topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
	     					if(null == topFrame){
		     				    topFrame = findFrame(getTopWindow(), "detailsDisplay");
	     					}
	     					
	     					if(null == topFrame){
	     						topFrame = findFrame(getTopWindow(), "PMCWBS");
	     					}
	     				}
	     				
	     				//if(validateState("PMCWBS")){
	     					setTimeout(function() {
		     					topFrame.toggleProgress('visible');
		     				    document.location.href = "<%=strUrl%>";
		     			    },100);	
	     				//}
	     				
	     			</script>
	     		<%
	
    		}else if(Task.LEFT_INDENTAION.equalsIgnoreCase(strMode)){
		     		boolean isRefreshStructure = true;
			     	StringList parentRowIdList = new StringList();
			     	
			     	String projectId = (String)emxGetParameter(request,"projectId");
			     	Task task = new Task(projectId);
			     	Map requestMap 		= (Map)session.getAttribute("IndentaionInfoMap");
			     	String portalCmd 	= (String)requestMap.get("PortalCmd");
			     	requestMap.put("shift",Task.LEFT_INDENTAION);
			     	
			     	session.removeAttribute("IndentaionInfoMap");
			     	
			     	StringList rowIdList = (StringList)requestMap.get("rowIdList");
			     	StringList selectedIdList = (StringList)requestMap.get("selectedTaskIdList");
			     	
				    boolean  isIndendentaionDone = task.doIndentation(context,requestMap);
			     	if(!isIndendentaionDone){
					    isRefreshStructure = false;
			     	}else{
						parentRowIdList = task.getParentRowIds(context,Task.LEFT_INDENTAION,rowIdList);
			     	}
					     	
		     		%>
		     		<script language="javascript" type="text/javaScript">
			     		var isRefresh = "<%=isRefreshStructure%>";
			     		var portalName = "<%=portalCmd%>";
			 			var cBoxArray = new Array();
			 			var selectedRowIdArr = new Array();
			 			var topFrame = findFrame(getTopWindow(), portalName);
			 			
	     				if(topFrame == null){
	     					topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
	     					if(null == topFrame){
		     				    topFrame = findFrame(getTopWindow(), "detailsDisplay");
	     					}
	     				}
			 			
				    	<%
				 		String[] emxTableRowIdArray = new String[rowIdList.size()];	
				 		for (int i=0; i<rowIdList.size(); i++) {
						 	emxTableRowIdArray[i]= " | | |"+rowIdList.get(i);
						    %>
						    cBoxArray["<%=i%>"]="<%=emxTableRowIdArray[i]%>";
						    <%
					    }
				 		for(int i=0;i<selectedIdList.size();i++){
				 			%>
				 			selectedRowIdArr["<%=i%>"]="<%=(String)selectedIdList.get(i)%>";
						    <%
				 		}
						%>	
						if(isRefresh == "true"){
							topFrame.emxEditableTable.removeRowsSelected(cBoxArray);
							   		  	
				 			var rowIdArr = new Array();
				 		    <%
						 	for (int i=0; i<parentRowIdList.size(); i++) {
							 	String exmRowId= (String)parentRowIdList.get(i);
					 		    %>
					 		    var emxRow = "<%=exmRowId%>";
					 		    rowIdArr.push(emxRow);
					 		    <%
				 		    } 
				 			%>	
				 			
				     		setTimeout(function() {
								topFrame.toggleProgress('hidden');
					    		topFrame.emxEditableTable.refreshRowByRowId(rowIdArr);
					    		for(var rw=0;rw<rowIdArr.length;rw++){
					    			var nRow = emxUICore.selectSingleNode(topFrame.oXML, "/mxRoot/rows//r[@id = '" + rowIdArr[rw] + "']");
						            nRow.setAttribute("expand", false);
						            nRow.setAttribute("expandedLevels", 0);
					    		}

					    		topFrame.emxEditableTable.expand(rowIdArr, "1");
					    		var selectedObjRowId = new Array();
					    		for(var i=0;i<selectedRowIdArr.length;i++){
					    			var nRow = emxUICore.selectSingleNode(topFrame.oXML, "/mxRoot/rows//r[@o = '" + selectedRowIdArr[i] + "']");
					    			selectedObjRowId[i] = nRow.getAttribute("id");
					    		}

					    		topFrame.emxEditableTable.select(selectedObjRowId);
					    		topFrame.emxEditableTable.refreshStructureWithOutSort();
						    },100);
			 			}else{
			 				setTimeout(function() {
			 					topFrame.toggleProgress('hidden');
			 			    },100);
			 			}
		     		</script>
		     		<%
	     				
	     		}else if(Task.RIGHT_INDENTAION.equalsIgnoreCase(strMode)){
		     		boolean isRefreshStructure = true;
		     		StringList parentRowIdList = new StringList();
		     				
		     		String projectId 	= (String)emxGetParameter(request,"projectId");
			     	Task task 			= new Task(projectId);
		     		Map requestMap 		= (Map)session.getAttribute("IndentaionInfoMap");
		     		String portalCmd 	= (String)requestMap.get("PortalCmd");
		     		
		     		requestMap.put("shift",Task.RIGHT_INDENTAION);
			     	session.removeAttribute("IndentaionInfoMap");
			     	
			     	StringList rowIdList = (StringList)requestMap.get("rowIdList");
			     	StringList selectedIdList 	= (StringList)requestMap.get("selectedTaskIdList");
			     	
			     	boolean isIndendentaionDone = task.doIndentation(context, requestMap);
			     	if(!isIndendentaionDone){
				    	isRefreshStructure = false;
			     	}else{
						parentRowIdList = task.getParentRowIds(context,Task.RIGHT_INDENTAION,rowIdList);
			     	}
		     					
		     		%>
		     		<script language="javascript" type="text/javaScript">
			     		var isRefresh = "<%=isRefreshStructure%>";
			     		var portalName = "<%=portalCmd%>";
			     		var cBoxArray = new Array();
			     		var selectedRowIdArr = new Array();
			     		
			     		var topFrame = findFrame(getTopWindow(), portalName);
			     		
	     				if(topFrame == null){
	     					topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
	     					if(null == topFrame){
		     				    topFrame = findFrame(getTopWindow(), "detailsDisplay");
	     					}
	     				}
					    <%
					 	String[] emxTableRowIdArray = new String[rowIdList.size()];	
					 	for (int i=0; i<rowIdList.size(); i++) {
							emxTableRowIdArray[i]= " | | |"+rowIdList.get(i);
							%>
							cBoxArray["<%=i%>"]="<%=emxTableRowIdArray[i]%>";
							<%
						} 
					 	for(int i=0;i<selectedIdList.size();i++){
				 			%>
				 			selectedRowIdArr["<%=i%>"]="<%=(String)selectedIdList.get(i)%>";
						    <%
				 		}
						%>	
						if(isRefresh == "true"){
							topFrame.emxEditableTable.removeRowsSelected(cBoxArray);
				     		var rowIdArr = new Array();
				     		<%
				    		for (int i=0; i<parentRowIdList.size(); i++) {
					    		String exmRowId= (String)parentRowIdList.get(i);
					     		%>
					     		rowIdArr.push("<%=exmRowId%>");
					     		<%
				     		}
				     		%>	
				     		setTimeout(function() {
								topFrame.toggleProgress('hidden');
					    		topFrame.emxEditableTable.refreshRowByRowId(rowIdArr);
					    		
					    		for(var rw=0;rw<rowIdArr.length;rw++){
					    			var nRow = emxUICore.selectSingleNode(topFrame.oXML, "/mxRoot/rows//r[@id = '" + rowIdArr[rw] + "']");
						            nRow.setAttribute("expand", false);
						            nRow.setAttribute("expandedLevels", 0);
					    		}
					    		
					    		topFrame.emxEditableTable.expand(rowIdArr, "1");
					    		
					    		var selectedObjRowId = new Array();
					    		for(var i=0;i<selectedRowIdArr.length;i++){
					    			var nRow = emxUICore.selectSingleNode(topFrame.oXML, "/mxRoot/rows//r[@o = '" + selectedRowIdArr[i] + "']");
					    			selectedObjRowId[i] = nRow.getAttribute("id");
					    		}
					    		
					    		topFrame.emxEditableTable.select(selectedObjRowId);
					    		topFrame.emxEditableTable.refreshStructureWithOutSort();
						    },100);
			     		}else{
			     			setTimeout(function() {
			 					topFrame.toggleProgress('hidden');
			 			    },100);
			     		}
		     		</script>
		     		<%
	     		
     	   }else if("MoveTasks".equals(strMode)){
     		   
     		  Task task 				= new Task();
     		  Map requestMap 			= new HashMap();
    		  StringList slSelectedId 	= new StringList();
  		    
	  		  String sMode 				= emxGetParameter(request,"SubMode");
			  String projectId 			= (String)emxGetParameter(request,"parentOID");
			  String selectedTableRowId = (String)emxGetParameter(request,"emxTableRowId");
			  String portalCmd 			= (String)emxGetParameter(request,"portalCmdName");
			  
			  Map mpRowDetails 			= ProgramCentralUtil.parseTableRowId(context,selectedTableRowId);
			  mpRowDetails.put("Action", sMode);
			  mpRowDetails.put("ProjectId", projectId);
			  
			  String strSelectedTaskId 	= (String)mpRowDetails.get("objectId");
			  String rowID 				= (String)mpRowDetails.get("rowId");
			  if("0".equalsIgnoreCase(rowID)){
				  return;
			  }
				  
			  String toMoveUpOrDown 	= DomainObject.EMPTY_STRING;
			  String parentRowID		= DomainObject.EMPTY_STRING;
			  
			  int posi 					= rowID.lastIndexOf(",");
			  String val 				= rowID.substring(0,posi);
			  String val1 				= rowID.substring(posi+1,rowID.length());
			  
			  //Moveing tasks
			  task.moveTaskUpOrDown(context, mpRowDetails);
			  
			  if(Task.MOVE_UP.equalsIgnoreCase(sMode)){
			      int ilevel 		= Integer.parseInt(val1)-1;
			      toMoveUpOrDown 	= val+","+ilevel;
				  StringList parentRowIdList = task.getParentRowIds(context, Task.MOVE_UP, new StringList(rowID));
				  parentRowID = (String)parentRowIdList.get(0);
			  }else{
			      int ilevel 		= Integer.parseInt(val1)+1;
			      toMoveUpOrDown 	= val+","+ilevel;
				  StringList parentRowIdList = task.getParentRowIds(context, Task.MOVE_DOWN, new StringList(rowID));
				  parentRowID 		= (String)parentRowIdList.get(0);
			  }
			  
			  %>
			    <script language="javascript" type="text/javaScript">
				    var portalName 		= "<%=portalCmd%>";
				    var topFrame = findFrame(getTopWindow(), portalName);
     				if(topFrame == null){
     					topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
     					if(null == topFrame){
	     				    topFrame = findFrame(getTopWindow(), "detailsDisplay");
     					}
     				}

     				var selectdObjId 	= "<%=strSelectedTaskId%>";
				    var toMoveUpOrDownObjRowID = "<%=toMoveUpOrDown%>";
				    var pId 			= "<%=parentRowID%>";
				   
				    var nRow 			= emxUICore.selectSingleNode(topFrame.oXML, "/mxRoot/rows//r[@id = '" + pId + "']");
				    var selectedRow 	= emxUICore.selectSingleNode(topFrame.oXML, "/mxRoot/rows//r[@o = '" + selectdObjId + "']");
				    
				    nRow.setAttribute("display",'none'); 
				    nRow.setAttribute("expand", false);
		                    nRow.setAttribute("expandedLevels", 0);
				    
		            var selectedObjRowId = selectedRow.getAttribute("id");
		            var parentIdArr = new Array();
		            parentIdArr[0] = pId;
		            
		            topFrame.emxEditableTable.expand(parentIdArr, "1"); 
		            selectedRow = emxUICore.selectSingleNode(topFrame.oXML, "/mxRoot/rows//r[@o = '" + selectdObjId + "']");
				    topFrame.emxEditableTable.select([selectedRow.getAttribute("id")]);
		            topFrame.emxEditableTable.unselect([selectedObjRowId]);
				    
			    </script>
			    <%
			 
     	   }  	else if ("PMCWBS".equalsIgnoreCase(strMode)) {
         		String strURL = "../common/emxIndentedTable.jsp?tableMenu=PMCWBSTableMenu&expandProgramMenu=PMCWBSListMenu&toolbar=PMCWBSToolBar&freezePane=Name&selection=multiple&HelpMarker=emxhelpwbstasklist&header=emxProgramCentral.Common.WorkBreakdownStructureSB&sortColumnName=ID&findMxLink=false&postProcessJPO=emxTask:postProcessRefresh&editRelationship=relationship_Subtask&suiteKey=ProgramCentral&SuiteDirectory=programcentral&resequenceRelationship=relationship_Subtask&connectionProgram=emxTask:cutPasteTasksInWBS&hideLaunchButton=true&displayView=details&cellwrap=false&reSort=true";
         		String objectId = emxGetParameter(request, "objectId");
         		
         		Map paramMap = new HashMap(1);
   	    	paramMap.put("objectId",objectId);
                  
               String[] methodArgs = JPO.packArgs(paramMap);
                boolean hasModifyAccess  = (boolean) JPO.invoke(context,"emxTask", null, "hasModifyAccess", methodArgs, Boolean.class);
               
         		Enumeration requestParams = emxGetParameterNames(request);
      		  	StringBuilder url = new StringBuilder();
                 		
      		  	if(requestParams != null){
	        		  while(requestParams.hasMoreElements()){
		        		  String param = (String)requestParams.nextElement();  
		        		  String value = emxGetParameter(request,param);
		        		  url.append("&"+param);
		        		  url.append("="+value);
	        		  }
      		  		strURL = strURL + url.toString();
      		  	}
         		
         		if(hasModifyAccess){
         			strURL = strURL + "&editLink=true";
         		}
            %>
             <script language="javascript">
           		 var strUrl = "<%=strURL%>";
           		 document.location.href = strUrl;
             </script> 
           <%
         	  } else if ("PMCProjectTemplateWBS".equalsIgnoreCase(strMode) || "type_ProjectTemplate".equalsIgnoreCase(strMode) ) {
                 
           		String strURL = "../common/emxIndentedTable.jsp?expandProgram=emxTask:getWBSProjectTemplateSubtasks&toolbar=PMCWBSProjectTemplateToolBar&table=PMCWBSProjectTemplateViewTable&freezePane=Name&selection=multiple&HelpMarker=emxhelpprojecttemplatewbs&header=emxProgramCentral.Common.WorkBreakdownStructureSB&sortColumnName=ID&findMxLink=false&postProcessJPO=emxTask:postProcessRefresh&editRelationship=relationship_Subtask&resequenceRelationship=relationship_Subtask&suiteKey=ProgramCentral&SuiteDirectory=programcentral&connectionProgram=emxTask:cutPasteTasksInWBS&hideLaunchButton=true&displayView=details&cellwrap=false&showClipboard=false";
             		String objectId = emxGetParameter(request, "objectId");
             		
             		Map paramMap = new HashMap(1);
       	    	    paramMap.put("objectId",objectId);
                      
                   String[] methodArgs = JPO.packArgs(paramMap);
	                boolean hasModifyAccess  = (boolean) JPO.invoke(context,"emxTask", null, "hasModifyAccess", methodArgs, Boolean.class);
                   
	                Enumeration requestParams = emxGetParameterNames(request);
	      		  	StringBuilder url = new StringBuilder();
                     		
	      		  	if(requestParams != null){
		        		  while(requestParams.hasMoreElements()){
			        		  String param = (String)requestParams.nextElement();  
			        		  String value = emxGetParameter(request,param);
			        		  url.append("&"+param);
			        		  url.append("="+value);
		        		  }
		        		  strURL = strURL + url.toString();
	      		  	}
             		
             		if(hasModifyAccess){
             			strURL = strURL + "&editLink=true";
             		}
                %>
                 <script language="javascript">
               		 var strUrl = "<%=strURL%>";
               		 document.location.href = strUrl;
                 </script> 
               <%
             	  }else if ("PMCWBSEffortFilter".equalsIgnoreCase(strMode)) {
               		String strURL = "../common/emxIndentedTable.jsp?tableMenu=PMCWBSTableMenu&expandProgramMenu=PMCWBSListMenu&toolbar=PMCWBSToolBar&freezePane=Name&selection=multiple&suiteKey=ProgramCentral&SuiteDirectory=programcentral&HelpMarker=emxhelpwbstasklist&header=emxProgramCentral.Common.WorkBreakdownStructureSB&sortColumnName=ID&findMxLink=false&postProcessJPO=emxTask:postProcessRefresh&editRelationship=relationship_Subtask&resequenceRelationship=relationship_Subtask&connectionProgram=emxTask:cutPasteTasksInWBS";
               		String objectId = emxGetParameter(request, "objectId");
               		
               		Map paramMap = new HashMap(1);
         	    	    paramMap.put("objectId",objectId);
                        
                     String[] methodArgs = JPO.packArgs(paramMap);
                    boolean hasModifyAccess  = (boolean) JPO.invoke(context,"emxTask", null, "hasModifyAccess", methodArgs, Boolean.class);
                     
                    Enumeration requestParams = emxGetParameterNames(request);
	      		  	StringBuilder url = new StringBuilder();
                       		
	      		  	if(requestParams != null){
		        		  while(requestParams.hasMoreElements()){
			        		  String param = (String)requestParams.nextElement();  
			        		  String value = emxGetParameter(request,param);
			        		  url.append("&"+param);
			        		  url.append("="+value);
		        		  }
		        		  strURL = strURL + url.toString();
	      		  	}
               		
               		if(hasModifyAccess){
               			strURL = strURL + "&editLink=true";
               		}
                  %>
                   <script language="javascript">
                 		 var strUrl = "<%=strURL%>";
                 		 document.location.href = strUrl;
                   </script> 
                 <%
                }else if ("PMCWhatIfProjectExperimentsList".equalsIgnoreCase(strMode)) {
               		String strURL = "../common/emxIndentedTable.jsp?table=PMCWhatIfExperimentSummaryTable&toolbar=PMCWhatIfActions&postProcessJPO=emxProjectBaseline:postProcessRefresh&freezePane=Name&relationship=relationship_Experiment&direction=from&selection=multiple&HelpMarker=emxhelpexperiments&hideHeader=true&customize=false&rowGrouping=false&showPageURLIcon=false&hideLaunchButton=true&export=false&displayView=details&export=false&objectCompare=false&showClipboard=false&multiColumnSort=false&findMxLink=false&showRMB=false&massPromoteDemote=false&expandLevelFilter=false&triggerValidation=false&cellwrap=false&suiteKey=ProgramCentral&SuiteDirectory=programcentral";
               		String objectId = emxGetParameter(request, "objectId");
               		
               		Map paramMap = new HashMap(1);
         	    	    paramMap.put("objectId",objectId);
                        
                     String[] methodArgs = JPO.packArgs(paramMap);
                    boolean hasModifyAccess  = (boolean) JPO.invoke(context,"emxTask", null, "hasModifyAccess", methodArgs, Boolean.class);
                     
                    Enumeration requestParams = emxGetParameterNames(request);
	      		  	StringBuilder url = new StringBuilder();
                       		
	      		  	if(requestParams != null){
		        		  while(requestParams.hasMoreElements()){
			        		  String param = (String)requestParams.nextElement();  
			        		  String value = emxGetParameter(request,param);
			        		  url.append("&"+param);
			        		  url.append("="+value);
		        		  }
		        		  strURL = strURL + url.toString();
	      		  	}
               		
               		if(hasModifyAccess){
               			strURL = strURL + "&editLink=true";
               		}
                  %>
                   <script language="javascript">
                 		 var strUrl = "<%=strURL%>";
                 		 document.location.href = strUrl;
                   </script> 
                 <%
                }else if ("PMCProjectBaselineList".equalsIgnoreCase(strMode)) {
               		String strURL = "../common/emxIndentedTable.jsp?table=PMCProjectBaselineSummaryTable&toolbar=PMCProjectBaselineActions&expandProgram=emxProjectBaseline:getProjectBaselines&freezePane=Name&selection=multiple&hideHeader=true&customize=false&rowGrouping=false&showPageURLIcon=false&hideLaunchButton=true&export=false&displayView=details&export=false&objectCompare=false&showClipboard=false&multiColumnSort=false&findMxLink=false&showRMB=false&massPromoteDemote=false&expandLevelFilter=false&triggerValidation=false&cellwrap=false&suiteKey=ProgramCentral&SuiteDirectory=programcentral";
               		String objectId = emxGetParameter(request, "objectId");
               		
               		Map paramMap = new HashMap(1);
         	    	    paramMap.put("objectId",objectId);
                        
                     String[] methodArgs = JPO.packArgs(paramMap);
                    boolean hasModifyAccess  = (boolean) JPO.invoke(context,"emxTask", null, "hasModifyAccess", methodArgs, Boolean.class);
                     
                    Enumeration requestParams = emxGetParameterNames(request);
	      		  	StringBuilder url = new StringBuilder();
                       		
	      		  	if(requestParams != null){
		        		  while(requestParams.hasMoreElements()){
			        		  String param = (String)requestParams.nextElement();  
			        		  String value = emxGetParameter(request,param);
			        		  url.append("&"+param);
			        		  url.append("="+value);
		        		  }
		        		  strURL = strURL + url.toString();
	      		  	}
               		
               		if(hasModifyAccess){
               			strURL = strURL + "&editLink=true";
               		}
                  %>
                   <script language="javascript">
                 		 var strUrl = "<%=strURL%>";
                 		 document.location.href = strUrl;
                   </script> 
                 <%
                }else if("validateCost".equalsIgnoreCase(strMode)) {
		
					JSONObject jsonObject = new JSONObject();
					String costValue =  emxGetParameter(request,"costValue");	
					Currency currencyObj = new Currency();
					Boolean iscurrencyValid = currencyObj.validateFinancialInput(context, costValue);
					String responce =iscurrencyValid.toString();
					jsonObject.put("isValidCurrency",responce);
					out.clear();
					out.write(jsonObject.toString());
					return;
				} else if("AddProjectToSelectedDashboard".equalsIgnoreCase(strMode)) {             		 
                    String projectId = emxGetParameter(request,"emxParentIds");
                    StringList slIds = FrameworkUtil.split(projectId, "~");
                    String[] projects = new String[slIds.size()];
                    for(int i=0; i<slIds.size(); i++){
                    	String sId = (String)slIds.get(i);
                    	 StringList allIds = FrameworkUtil.split(sId, "|");
                    	 projects[i] = (String)allIds.get(0);
                    }
                
                    String dashboardName = emxGetParameter(request,"emxTableRowId");
                    if(ProgramCentralUtil.isNotNullString(dashboardName)){
                     try {
                 	   Map mpRow = ProgramCentralUtil.parseTableRowId(context,dashboardName);
                 	   dashboardName = (String) mpRow.get("objectId");       
                 	  // start a write transaction and lock business object
                       ContextUtil.startTransaction( context, true );
                       //to find the set for this dashboard name
                       SetList sl = matrix.db.Set.getSets( context , true);
                       Iterator setItr = sl.iterator();
                       while ( setItr.hasNext() ){
                         matrix.db.Set curSet = ( matrix.db.Set )setItr.next();
                         if ( curSet.getName().equals( dashboardName ) ){
                           //add the projects to this set
                           BusinessObjectList busList = curSet.getBusinessObjects( context );
                           for ( int i = 0; i < projects.length; i++ ){
                             String busId = projects[i];
                             BusinessObject bo = new BusinessObject(busId);
                             curSet.add(bo);
                           }
                       // commit the data
                           curSet.setBusinessObjects( context );
                           break; // don't need to continue looping
                     } // end if
                       } // end while
                         ContextUtil.commitTransaction( context );
                    }catch (Exception e){
                    	ContextUtil.abortTransaction( context );
                	    throw e;
                	  }
                    }else{
            			 String errorMessage = 	
   		 	   	    			ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Common.Noobjectsselected",sLanguage);
      			 %>
				<script language="javascript" type="text/javaScript">
		 		alert('<%= errorMessage %>');     <%--XSSOK--%>  
	 	 		</script>
				<%
	  					}
                %>
				<script language="javascript" type="text/javaScript">
					getTopWindow().getWindowOpener().refreshSBTable(
							getTopWindow().getWindowOpener().configuredTableName);
					getTopWindow().closeWindow();
				</script>
<%
				} else if("FindCompanyAdminList".equalsIgnoreCase(strMode)) {
					String objectId = emxGetParameter(request, "objectId");
					
					String URL = "../common/emxIndentedTable.jsp?program=emxProjectTemplate:getAllAdminFromCompany&table=PMCProjectTemplateCoOwnersTable&sortColumnName=ID&suiteKey=ProgramCentral&SuiteDirectory=programcentral&header=emxProgramCentral.PersonDialog.ProjectAdministrator&submitLabel=emxProgramCentral.Common.Assign";
					URL += "&submitURL=../programcentral/emxProgramCentralUtil.jsp&mode=AddTemplateCoOwners&objectId="+objectId+"&selection=multiple&customize=false&displayView=details&showClipboard=false&findMxLink=false&showRMB=false&showPageURLIcon=false&hideLaunchButton=true&objectCompare=false&autoFilter=false&rowGrouping=false&Export=false&PrinterFriendly=false&multiColumnSort=false&HelpMarker=false&cellwrap=false";
%>	
	     		 	<script language="javascript" type="text/javaScript">
	     		 	 	var url = "<%=XSSUtil.encodeForJavaScript(context,URL)%>";
	     		 	 	getTopWindow().location.href = url;
	     		 	</script>
<%  
				} else if("AddTemplateCoOwners".equalsIgnoreCase(strMode)) {
					String[] selectedCoOwnerList = emxGetParameterValues(request, "emxTableRowId");
					String templateId = emxGetParameter(request, "objectId");

					ProjectTemplate template = (ProjectTemplate) DomainObject.newInstance(context, templateId, DomainConstants.PROGRAM, DomainConstants.TYPE_PROJECT_TEMPLATE);
					template.addCoOwners(context, selectedCoOwnerList);
%>
				 	<script language="javascript" type="text/javaScript">
					 	getTopWindow().getWindowOpener().refreshSBTable(getTopWindow().getWindowOpener().configuredTableName);
		       			getTopWindow().close(); 
				 	</script>
<%
				} else if("RemoveTemplateCoOwner".equalsIgnoreCase(strMode)) {
					String[] selectedCoOwnerList = emxGetParameterValues(request, "emxTableRowId");

					//ProjectTemplate template = new ProjectTemplate();
					ProjectTemplate template = (ProjectTemplate)DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_TEMPLATE, DomainObject.PROGRAM);
					template.removeCoOwners(context, selectedCoOwnerList);
%>
				 	<script language="javascript" type="text/javaScript">
					 	 var topFrame = findFrame(getTopWindow(), "detailsDisplay");
			    		 topFrame.location.href = topFrame.location.href; 		
				 	</script>
<%
				 } else if("errorMessage".equalsIgnoreCase(strMode)){
					String key = (String) emxGetParameter(request, "key");
					String errmsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral",key, context.getSession().getLanguage());
					out.clear();
					out.write(errmsg.toString());
					return;
				} else if("TemplateQuestion".equalsIgnoreCase(strMode)) {
					String URL = "../common/emxIndentedTable.jsp?table=PMCQuestionSummaryTable&selection=multiple&sortColumnName=Name&header=emxFramework.Command.Question&toolbar=PMCQuestionToolbar&massPromoteDemote=true&expandProgram=emxQuestion:getQuestionORQuestionTaskList&helpMarker=emxhelpquestionsummary&postProcessJPO=emxQuestionBase:postProcessRefresh";
					String templateId = emxGetParameter(request, "objectId");
					URL += "&objectId="+templateId; 
					ProjectTemplate projectTemplate = (ProjectTemplate)DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_TEMPLATE, DomainObject.PROGRAM);
			 		boolean isOwnerOrCoOwner = projectTemplate.isOwnerOrCoOwner(context, templateId);
					if(isOwnerOrCoOwner){
						URL += "&editLink=true";
					}
%>
		             <script language="javascript">
		             	var topFrame = findFrame(getTopWindow(), "detailsDisplay");
		             	topFrame.location.href = "<%=URL%>";
		             </script> 
<%
				}
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "../components/emxComponentsDesignBottomInclude.inc"%>
