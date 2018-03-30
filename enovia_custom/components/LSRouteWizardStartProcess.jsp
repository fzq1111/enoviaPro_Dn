<%--  emxRouteWizardStartProcess.jsp  --  Starting the Route process

  Copyright (c) 1992-2015 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteWizardStartProcess.jsp.rca 1.15 Wed Oct 22 16:18:13 2008 przemek Experimental przemek $

 --%>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%@include file = "../components/emxComponentsTreeUtilInclude.inc" %>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%

    String keyValue               =emxGetParameter(request,"keyValue");
    formBean.processForm(session,request,"keyValue");
    Route route                   = (Route)DomainObject.newInstance(context , DomainConstants.TYPE_ROUTE);
    Document document             = (Document)DomainObject.newInstance(context , DomainConstants.TYPE_DOCUMENT);
    DomainObject RouteScope       = null;
    String routeId                = (String) formBean.getElementValue("routeId");
    String projectId              = (String) formBean.getElementValue("objectId");
    String sState                 = (String)((Hashtable)formBean.getElementValue("hashRouteWizFirst")).get("routeStart");
    String folderId               = (String) formBean.getElementValue("folderId");
    String workspaceId            = (String) formBean.getElementValue("workspaceId");
    String portalMode             = (String) formBean.getElementValue("portalMode");
    String treeUrl                = null;
    String sRoute                 = i18nNow.getI18nString("emxFramework.Command.Route", "emxComponentsStringResource", sLanguage);
    String typeWorkspace          = PropertyUtil.getSchemaProperty( context,"type_Project");
    String typeWorkspaceVault     = PropertyUtil.getSchemaProperty( context,"type_ProjectVault");
    String attrDueDateOffset      = PropertyUtil.getSchemaProperty( context,"attribute_DueDateOffset");
    String attrDueDateOffsetFrom  = PropertyUtil.getSchemaProperty( context,"attribute_DateOffsetFrom");
    String OFFSET_FROM_ROUTE_START_DATE  = "Route Start Date";
    String OFFSET_FROM_TASK_CREATE_DATE  = "Task Create Date";
    boolean bPublishWorkspace     = false;
    String url                    = "";
    if("null".equals(sState) || sState == null){
      sState = "";
    }
	
	
	    String promoted = (String)session.getAttribute("isPromoted");
		session.setAttribute("isPromoted","false");
		//System.out.println("SSSSSSSSSSSSSSSSSSSSSSSSS:"+promoted);
   if(sState.equals("start")&& !"true".equals(promoted)) {
       try
       {
          route.setId(routeId);

          route.open(context);
          String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteComponents.emxTreeAlternateMenuName.type_InboxTask");
          if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu ))
          {
            MailUtil.setTreeMenuName(context, treeMenu );
          }
          ContextUtil.startTransaction(context, true);
            String selDueDateOffset       = "attribute["+attrDueDateOffset+"]";
          String selDueDateOffsetFrom   = "attribute["+attrDueDateOffsetFrom+"]";
          String selRouteNodeRelId      = DomainObject.SELECT_RELATIONSHIP_ID;
          String selSequence            = "attribute["+DomainObject.ATTRIBUTE_ROUTE_SEQUENCE+"]";
          String sWhereExp              = "";
          String taskScheduledDateStr   = "";
          String rNodeId                = "";
          String duedateOffset          = "";
          StringList relSelects             = new StringList();
          relSelects.addElement(selDueDateOffset);
          relSelects.addElement(selDueDateOffsetFrom);
          relSelects.addElement(selRouteNodeRelId);
          relSelects.addElement(selSequence);

          // where clause filters to all route tasks with due offset from this Route Start

          sWhereExp = "";
          sWhereExp += "("+selDueDateOffset+ " !~~ \"\")";
          //sWhereExp += " && (" +selDueDateOffsetFrom + " ~~ \""+OFFSET_FROM_TASK_CREATE_DATE+"\")";
          //sWhereExp += " && ("+selDueDateOffset+ " !~~ \"\")";
          sWhereExp += " && (" +selDueDateOffsetFrom + " ~~ \""+OFFSET_FROM_ROUTE_START_DATE+"\")";
          sWhereExp += " || (" +selSequence + " == \"1\")";

          MapList routeFirstOrderOffsetList = Route.getFirstOrderOffsetTasks(context, route, relSelects, sWhereExp);
          // set Scheduled Due Date attribute for all delta offset ORDER 1 Route Nodes offset From Task create which is same as Route start
          Route.setDueDatesFromOffset(context, session, routeFirstOrderOffsetList);
          //Added for Bug 300225 -Start
		  DomainObject domainObject=DomainObject.newInstance(context,routeId);
		  Pattern typePattern = new Pattern(DomainObject.TYPE_PERSON);
          typePattern.addPattern(DomainObject.TYPE_ROUTE_TASK_USER);
 	      String selTaskName = "attribute["+DomainObject.ATTRIBUTE_TITLE+"]";
   	      StringList routeRelSelects = new StringList();
          routeRelSelects.addElement(selTaskName);
		  boolean routeTitleFlag=true;
          MapList routeNodeList = domainObject.getRelatedObjects(context,
                                                           DomainObject.RELATIONSHIP_ROUTE_NODE, //relationshipPattern
                                                           typePattern.getPattern(), //typePattern
                                                           null, //objectSelects
                                                           routeRelSelects, //relationshipSelects
                                                           false, //getTo
                                                           true, //getFrom
                                                           (short)1, //recurseToLevel
                                                           null, //objectWhere
                                                           null, //relationshipWhere
                                                           null,
                                                           null,
                                                           null);

		  Iterator routeNodeItr=routeNodeList.iterator();
		  while(routeNodeItr.hasNext()) {
			  Map routeNodeMap=(Map)routeNodeItr.next();
			  String routeNodeTitle=(String)routeNodeMap.get(selTaskName);
			  if(routeNodeTitle.equals("")){
				  routeTitleFlag=false;
				  break;
			  }
		   }
          if(routeTitleFlag==true){
			route.promote(context);
		  }else{
			%>
       <script language="Javascript" >
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteDetails.UnTitleTask</emxUtil:i18nScript>");
		</script>
    	<%
		  } 
	  //Bug 300225-End

       route.close(context);
          ContextUtil.commitTransaction(context);
          try
          {
             ContextUtil.pushContext(context);
             InboxTask.setTaskTitle(context, routeId);
             ContextUtil.popContext(context);
          }catch(Exception ex){
             session.putValue("error.message",ex.getMessage());
          }
          treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteComponents.emxTreeAlternateMenuName.type_Route");
          boolean validTreeMenu=false;
          if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
            validTreeMenu=true;
          }
          //THIS CODITION IS KEPT IF ROUTE IS CREATED UNDER COMMON
          if(projectId != null && !"null".equals(projectId) && !"".equals(projectId))
          {
             String sScopeObjId = route.getInfo(context,"to["+route.RELATIONSHIP_ROUTE_SCOPE+"].from.id");
             if(sScopeObjId != null && !"null".equals(sScopeObjId) && !"".equals(sScopeObjId))
             {
             RouteScope = DomainObject.newInstance(context , sScopeObjId);
             if(RouteScope.getType(context).equals(typeWorkspace))
             {
                bPublishWorkspace = true ;
             }
             //Workspace Vault
             if(typeWorkspaceVault.equals(RouteScope.getType(context)))
             {
                WorkspaceVault workspaceVault = (WorkspaceVault)DomainObject.newInstance(context , DomainConstants.TYPE_WORKSPACE_VAULT);

                workspaceVault.setId(sScopeObjId);
                if(validTreeMenu)
                {
                   MailUtil.setTreeMenuName(context, treeMenu );
                }
                String projectId1 = UserTask.getProjectId(context,sScopeObjId);
        if(projectId1 != null && !"".equals(projectId1))
        {
          bPublishWorkspace =true;
           projectId = projectId1;
        }
        else
        {
                  bPublishWorkspace = false;
                }
      }else{

            projectId = sScopeObjId;

      }

        if(bPublishWorkspace)
    {
    Workspace workspace           = (Workspace)DomainObject.newInstance(context , DomainConstants.TYPE_PROJECT);

      workspace.setId(projectId);
          if(validTreeMenu) {
            MailUtil.setTreeMenuName(context, treeMenu );
          }
        }
     }
   }//THIS CODITION IS KEPT IF ROUTE IS CREATED UNDER COMMON
      //getting the ids of the connected contents
      StringList listContentIds = route.getInfoList(context,"to["+route.RELATIONSHIP_OBJECT_ROUTE+"].from.id");
      if(listContentIds == null){
        listContentIds = new StringList();
      }
      Iterator contentItr = listContentIds.iterator();

      while(contentItr.hasNext()){
        String sDocId = (String)contentItr.next();

        document.setId(sDocId);
        if(validTreeMenu) {
          MailUtil.setTreeMenuName(context, treeMenu );
        }
      }
      if(validTreeMenu) {
        MailUtil.setTreeMenuName(context, treeMenu );
      }



        ContextUtil.commitTransaction(context);


    } catch (Exception ex ) {
      session.putValue("error.message",ex.getMessage());
      // Abort the transaction
      ContextUtil.abortTransaction(context);
    }
  } // if route selects start

formBean.removeElement("hashRouteWizFirst");
formBean.removeElement("taskMapList");
formBean.removeElement("parallelNodeMap");
formBean.removeElement("routeMemberMapList");
formBean.removeElement("routeRoleMapList");
formBean.removeElement("hashStateMap");
//Added for Bug 314737 - Begin
formBean.removeElement("radioSelectedMap");
formBean.removeElement("actionRequiredMap");
//Added for Bug 314737 - End
String treePage = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId="+ XSSUtil.encodeForURL(context, routeId);

if(projectId!=null && !"null".equals(projectId) && !"".equals(projectId))
{
 %>


<script>
 //loadTreeNode("<%=XSSUtil.encodeForJavaScript(context, routeId)%>","",null,"<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>",true);
 //getTopWindow().close();
</script>
<%
}
else
{
%>
	<script language="javascript">
	var frameContent = findFrame(getTopWindow().opener.getTopWindow(), "content");
	//XSSOK
	frameContent.document.location.href =  frameContent.document.location.href ;
	frameContent.focus();
	getTopWindow().close();
</script>
<%
}
%>




