<%-- emxTasksSummaryLinksProcess.jsp -- for Opening the Window on clicking the Top links in Content Page.
  Copyright (c) 1992-2015 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxUserTasksSummaryLinksProcess.jsp.rca 1.2.2.1.7.5 Wed Oct 22 16:17:47 2008 przemek Experimental przemek $
--%>
<%@ page import = "com.matrixone.apps.domain.*,com.matrixone.apps.framework.ui.UINavigatorUtil, com.matrixone.apps.common.*,com.matrixone.apps.domain.util.*,com.matrixone.apps.common.UserTask" %>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%@include file = "emxRouteInclude.inc" %>
<%
	String sOutput = "";
	String errMsg = "";
	String objName = "";
	String sCompletedTasks = "";
	String curOutput = "";

	String isFDAEnabled = EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.EnableFDA");	
	
	formBean.processForm(session,request);
	
	String keyValue=emxGetParameter(request,"keyValue");
	if(keyValue == null)
	{
		keyValue = formBean.newFormKey(session);
	}	
	
	formBean.processForm(session, request, "keyValue");
	
	boolean blnAction=false;
	String jsTreeID   = emxGetParameter(request,"jsTreeID");
    String suiteKey   = emxGetParameter(request,"suiteKey");
	String isFDAEntered   = emxGetParameter(request,"isFDAEntered");
    String comments   = emxGetParameter(request,"txtComments");
	String sAction   = emxGetParameter(request,"fromPage");
	String sActionSuccessful = "";

    if( comments == null || comments.equals(""))
	{
        comments   = (String)formBean.getElementValue("txtComments");
	}

	String objectId[] = ComponentsUIUtil.getSplitTableRowIds(formBean.getElementValues("emxTableRowId"));
	String[] onlyObjectId = new String[objectId.length];
	for(int arrIndex = 0; arrIndex < objectId.length; arrIndex++)
	{		
		onlyObjectId[arrIndex]=(objectId[arrIndex].indexOf("|")!=-1)?(objectId[arrIndex].substring(objectId[arrIndex].lastIndexOf("|")+1)):objectId[arrIndex];
	}

	boolean isCommentsRequired = false;
	String returnFromPopup = emxGetParameter(request, "returnBack");
	if (returnFromPopup == null)
	{
		returnFromPopup = "false";
	}

	UserTask userTask = new UserTask();	

	if ("false".equalsIgnoreCase(returnFromPopup))
	{
		isCommentsRequired = userTask.isCommentsRequired(context, onlyObjectId, sAction);
		if (!isCommentsRequired) returnFromPopup = "true";
	}

	boolean isApproveAction = userTask.isListContainsApproveAction(context,  onlyObjectId, DomainObject.TYPE_INBOX_TASK + "~Approve");
		
	if ("true".equalsIgnoreCase(returnFromPopup))
	{
		if ( (isApproveAction && "true".equalsIgnoreCase(isFDAEnabled) && "true".equalsIgnoreCase(isFDAEntered)) || !isApproveAction || (isApproveAction && "false".equalsIgnoreCase(isFDAEnabled)) )
		{
			HashMap appMap = new HashMap();
			String sSubject = i18nNow.getI18nString("emxComponents.common.TaskDeletionNotice", "emxComponentsStringResource" ,sLanguage);
			String sMessage1 = i18nNow.getI18nString("emxComponents.common.TaskDeletionMessage3", "emxComponentsStringResource" ,sLanguage);
			String sMessage2 = i18nNow.getI18nString("emxComponents.common.TaskDeletionMessage2", "emxComponentsStringResource" ,sLanguage);
			String sRouteTaskUser = i18nNow.getI18nString("emxComponents.TaskSummary.TasksNotAccepted", "emxComponentsStringResource" ,sLanguage);
			String sCannotRejectReason = i18nNow.getI18nString("emxComponents.InboxTask.CannotRejectReason", "emxComponentsStringResource", sLanguage);
			String sRouteStopped = i18nNow.getI18nString("emxComponents.Task.RouteStopped", "emxComponentsStringResource", sLanguage);
			String sTasksCompleted = i18nNow.getI18nString("emxComponents.Task.TaskCompleted", "emxComponentsStringResource", sLanguage);

			
			appMap.put("eServiceComponents.treeMenu.Route", JSPUtil.getApplicationProperty(context,application,"eServiceComponents.treeMenu.Route"));
			appMap.put("eServiceComponents.treeMenu.InboxTask", JSPUtil.getApplicationProperty(context,application,"eServiceComponents.treeMenu.InboxTask"));		
			appMap.put("emxComponents.common.TaskDeletionNotice", sSubject);
			appMap.put("emxComponents.common.TaskDeletionMessage3", sMessage1);
			appMap.put("emxComponents.common.TaskDeletionMessage2", sMessage2);
			appMap.put("emxComponents.TaskSummary.TasksNotAccepted", sRouteTaskUser);
			appMap.put("emxComponents.Task.RouteStopped", sRouteStopped);
			appMap.put("emxComponents.Task.TaskCompleted", sTasksCompleted);
			appMap.put("emxComponents.InboxTask.CannotRejectReason", sCannotRejectReason);


			double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
			//sOutput = userTask.doProcess(context, onlyObjectId, appMap, comments, sAction, clientTZOffset);


			DomainObject genericObject = new DomainObject();
		
			String taskId = "";
			String objType = "";
	
			for (int index=0 ;index < onlyObjectId.length; index++)
			{
				 curOutput = "";
				try 
				{
					taskId = onlyObjectId[index];
					genericObject.setId(taskId);
					objType = genericObject.getInfo(context, DomainObject.SELECT_TYPE);
					objName = genericObject.getInfo(context, DomainObject.SELECT_NAME);
					
					if (DomainObject.TYPE_INBOX_TASK.equals(objType))
					{
                        InboxTask taskObject  = (InboxTask)DomainObject.newInstance(context, taskId);
						if(!taskObject.canCompleteTask(context)){
						throw new Exception(i18nNow.getI18nString("emxComponents.Common.CanNotPromoteTask" ,"emxComponentsStringResource", sLanguage));
					}
						curOutput = userTask.doInboxTaskAction(context, taskId, appMap, comments, sAction, clientTZOffset);
						if(!"".equals(curOutput)){
							sOutput += curOutput;
						}else{
							sCompletedTasks += objName + "\n";
						}
					}
					else if (DomainObject.TYPE_TASK.equals(objType))
					{
						curOutput = userTask.doWBSTaskAction(context, taskId, sAction);
						if(!"".equals(curOutput)){
							sOutput += curOutput;
						}else{
							sCompletedTasks += objName + "\n";
						}
					}
				}
				catch(Exception ex)
				{
					errMsg += objName + " : " + ex.getMessage() + "\\n";
				}
			}
		
			if (errMsg.length() > 0)
			{
				session.putValue("error.message", errMsg);
			}
		}
	}
%>
    <body>

<%
	if(isCommentsRequired && isApproveAction && ("true".equalsIgnoreCase(isFDAEnabled) && !"true".equalsIgnoreCase(isFDAEntered)))
    {
%>
		<script language="Javascript" >
        emxShowModalDialog('emxRouteTaskAddCommentsFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&fromPage=<%=XSSUtil.encodeForURL(context, sAction)%>&isFDAEnabled=<%=isFDAEnabled%>',575, 575); 
     </script>
<% 
	}
	 else if( (isCommentsRequired && !isApproveAction) || (isCommentsRequired && isApproveAction && "false".equalsIgnoreCase(isFDAEnabled)) )
    {
%>
		<script language="Javascript" >
        emxShowModalDialog('emxRouteTaskAddCommentsFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&fromPage=<%=XSSUtil.encodeForURL(context, sAction)%>',575, 575); 
     </script>
<% 
	}
	 else if ("true".equalsIgnoreCase(isFDAEnabled) && !"true".equalsIgnoreCase(isFDAEntered) && isApproveAction)
    {
    %>
     <script language="Javascript" >
       emxShowModalDialog('emxComponentsUserAuthenticationDialogFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&fromPage=<%=XSSUtil.encodeForURL(context, sAction)%>',400, 400);  
     </script>

    <% 
      }
	else
	{
		if (!"".equals(sOutput) || !"".equals(sCompletedTasks))
		{
		    String sCompleteComments = i18nNow.getI18nString("emxComponents.Task.CompleteComments", "emxComponentsStringResource" ,sLanguage);
			if ("Complete".equalsIgnoreCase(sAction))
			{		
				sOutput = !"".equals(sOutput) ? (sCompleteComments + ":\n"+ sOutput) : "";	
				sActionSuccessful = i18nNow.getI18nString("emxComponents.Task.TaskCompletionSuccessful", "emxComponentsStringResource" ,sLanguage);
			}
			else if ("Reject".equalsIgnoreCase(sAction))
			{
				sOutput = !"".equals(sOutput) ? (sCompleteComments + ":\n" + sOutput) : "";
				sActionSuccessful = i18nNow.getI18nString("emxComponents.Task.TaskRejectionSuccessful", "emxComponentsStringResource" ,sLanguage);
			}				
            sOutput = sCompletedTasks.length() > 0 ? (sActionSuccessful + ": " + "\n" + sCompletedTasks + "\n" + sOutput) : sOutput;			
		
%>	
		<Script>
			var temp = "<%=XSSUtil.encodeForJavaScript(context, sOutput)%>";
			alert(temp);
		</script>
<%
		}
%>
		<Script>
			//parent.window.location.href = parent.window.location.href;
			if (parent.window.getWindowOpener() != null)
			{
				//parent.window.getWindowOpener().parent.location.reload();
				parent.window.getWindowOpener().parent.location.href = parent.window.getWindowOpener().parent.location.href;
				//getTopWindow().closeWindow();
				top.window.close();
			}
			else
			{
				parent.window.location.href = parent.window.location.href;
				//parent.location.reload();
			}			
		</script>
<%   
	}
%>
    

</body>
