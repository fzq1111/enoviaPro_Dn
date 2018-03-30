<%--  emxRouteWizardActionRequiredDialog.jsp   -   Display Summary Of People
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteWizardActionRequiredDialog.jsp.rca 1.18 Wed Oct 22 16:18:19 2008 przemek Experimental przemek $

--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%

	//integer to count the no of tasks added for IR 77904
	int taskSize = 0;
  String keyValue=emxGetParameter(request,"keyValue");

  Map paramMap = (Map) formBean.getElementValue("strParams");

  if (paramMap != null){
  Iterator keyItr = paramMap.keySet().iterator();

  while (keyItr.hasNext())
  {
    String name = (String) keyItr.next();
    String value = (String) paramMap.get(name);
    request.setAttribute(name, value);
  }

}


  String sAttParallelNodeProcessionRule = PropertyUtil.getSchemaProperty(context, "attribute_ParallelNodeProcessionRule");
  Route routeObj = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);

  String sRadioValue = "";

  String languageStr    = request.getHeader("Accept-Language");
  //String sourcePage     = emxGetParameter(request,"sourcePage");
  String sourcePage = (String)formBean.getElementValue("sourcePage");

  if ((sourcePage == null) || sourcePage.equals("null")){
    sourcePage = "";
  }



  String routeOrder = (String)formBean.getElementValue("routeOrder");
  String routeInstructions = (String)formBean.getElementValue("routeInstructions");
  String routeTime = (String)formBean.getElementValue("routeTime");
  String personName = (String)formBean.getElementValue("personName");
  String routeId = (String)formBean.getElementValue("routeId");
  String projectId = (String)formBean.getElementValue("objectId");
  String routeNodes = (String)formBean.getElementValue("routeNode");
  String templateId = (String)formBean.getElementValue("templateId");
  String templateName = (String)formBean.getElementValue("templateName");
  String assigneeType = (String)formBean.getElementValue("assigneeType");
  String portalMode = (String)formBean.getElementValue("portalMode");
  String routeAction = (String)formBean.getElementValue("routeAction");
//Added for Bug 314737 - Begin
//Added for Bug 309518 - Begin
  HashMap actionRequiredMap=null;
    Object actionRequiredMapObj=formBean.getElementValue("actionRequiredMap");
    if(actionRequiredMapObj==null || actionRequiredMapObj.equals("null") || actionRequiredMapObj.equals(""))
    {
        actionRequiredMap=null;
    }
    else
    {
        actionRequiredMap=(HashMap)actionRequiredMapObj;
    }
    //Added for Bug 309518 - End

    String title = (String)formBean.getElementValue("title");

    String relRouteNode      = PropertyUtil.getSchemaProperty(context, "relationship_RouteNode");


    String folderId = (String)formBean.getElementValue("folderId");
    String workspaceId = (String)formBean.getElementValue("workspaceId");


    String sRoute            = i18nNow.getI18nString("emxComponents.Common.Route", "emxComponentsStringResource", sLanguage);
    String strRouteActionAttr= PropertyUtil.getSchemaProperty(context, "attribute_RouteAction" );

    StringTokenizer sTokOrder      = null;
    StringTokenizer sTokName       = null;
    StringTokenizer sTokAction     = null;
    StringTokenizer sTokRouteNodes = null;

    String rowClass          = "even";
    String newTaskIds="";


     // MapList taskDetails    = (MapList)session.getAttribute("taskMapList");
      MapList taskDetails    = (MapList)formBean.getElementValue("taskMapList");


      if (sourcePage.equals("EditAllTasks")) {

        sTokOrder       = new StringTokenizer(routeOrder,"~");
        sTokName        = new StringTokenizer(title,"~");

        sTokAction      = new StringTokenizer(routeAction,"~");
        sTokRouteNodes  = new StringTokenizer(routeNodes,"~");
        newTaskIds=emxGetParameter(request,"newTaskIds");
        if (newTaskIds == null)
            newTaskIds="";

      }

      String sSameRow = "";
      boolean bRadioDisplay = false;



  String assignURL   = "emxRouteWizardAssignTaskFS.jsp?selectedAction=";
  if ((routeAction == null) || routeAction.equals("null"))
    assignURL += "false";
  else
    assignURL += "true";

  assignURL += "&portalMode=" + XSSUtil.encodeForURL(context, portalMode) + "&keyValue=" + XSSUtil.encodeForURL(context, keyValue);


if (!"EditAllTasks".equals(sourcePage)) {
  StringTokenizer sTokAssigneeType = new StringTokenizer(assigneeType,"~");
}



%>


 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

<script language="JavaScript">
  //added for the bug no 341551 Rev 1
  var submitAction = false;
  function closeWindow() {
  //added for the bug no 341551 Rev 1
  submitAction = true;
  <%
      if (sourcePage.equals("EditAllTasks")) {
  %>
    	submitWithCSRF("emxRouteCancelNewTaskProcess.jsp?newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>", window);
  <%
      } else {
  %>
        submitWithCSRF("emxRouteWizardCancelProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>", window);
  <%
      }
  %>

  }

  function goBack() {
    //added for the bug no 341551 Rev 1
     submitAction =true;
<%
    if (sourcePage.equals("EditAllTasks")) {
%>
      document.actionRequired.action="emxRouteEditAllTasksDialogFS.jsp?sortName=true&newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>";
<%
    } else {
%>//XSSOK
      document.actionRequired.action="<%=assignURL%>";
<%
    }
%>
    document.actionRequired.submit();
    return;
  }


  function submitForm() {
    //added for the bug no 341551 Rev 1
    submitAction = true
    startProgressBar(true);
    document.actionRequired.submit();
    return;
  }
      //added for the bug no  341551 Rev 1 -Begin
function setUnloadMethod()
{
  var bodyElement = document.getElementById("taskdelete");
    if (isIE && bodyElement)
    {
        bodyElement.onunload = function () { windowClose(); };
		
    }
    else
    {
        bodyElement.setAttribute("onbeforeunload",  "return windowClose()");
    }
	
}

function windowClose()
{
    if (submitAction != true )
    {
     window.location.href="emxRouteCancelNewTaskProcess.jsp?newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>";
    }
}
</script>
<body id="taskdelete" name="taskdelete" onload="setUnloadMethod()">
<!--    added for the bug no  341551 Rev 1  - Ends-->
<!---->

<form method="post" name="actionRequired" action="LSRouteWizardActionRequiredProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>" target="_parent" onSubmit="javascript:submitForm(); return false">
<input type="hidden" name="sourcePage" value="<xss:encodeForHTMLAttribute><%=sourcePage%></xss:encodeForHTMLAttribute>" />

<input type="hidden" name="routeId" value="<%=routeId%>" />
<input type="hidden" name="objectId" value="<%=projectId%>" />

<input type="hidden" name="routeInstructions" value="<xss:encodeForHTMLAttribute><%=routeInstructions%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeTime" value="<xss:encodeForHTMLAttribute><%=routeTime%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeOrder%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="personName" value="<xss:encodeForHTMLAttribute><%=personName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeAction" value="<xss:encodeForHTMLAttribute><%=routeAction%></xss:encodeForHTMLAttribute>" />



<input type="hidden" name="templateId" value="<%=templateId%>" />

<input type="hidden" name="templateName" value="<xss:encodeForHTMLAttribute><%=templateName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeNodes" value="<xss:encodeForHTMLAttribute><%=routeNodes%></xss:encodeForHTMLAttribute>" />

<input type="hidden" name="assigneeType" value="<xss:encodeForHTMLAttribute><%=assigneeType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>" />

  <table class="list" id="UITable">
    <tr>
      <th><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Order</emxUtil:i18n>&nbsp;</th>
       <th><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n>&nbsp;</th>
       <th><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Action</emxUtil:i18n></th>
      <th><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.ActionRequired</emxUtil:i18n></th>
    </tr>



<%

  String strArray[]  = null;
  TreeMap sortMap  = new TreeMap();
  Vector sortVector = null;


  String routeScheduledCompletionDateStr      = PropertyUtil.getSchemaProperty(context, "attribute_ScheduledCompletionDate");
  String routeSequenceStr                     = PropertyUtil.getSchemaProperty(context, "attribute_RouteSequence");
  String routeAllowDelegation                 = PropertyUtil.getSchemaProperty(context, "attribute_AllowDelegation");
  String routeActionStr                       = PropertyUtil.getSchemaProperty(context, "attribute_RouteAction");
  String routeInstructionsStr                 = PropertyUtil.getSchemaProperty(context, "attribute_RouteInstructions");
  String taskNameStr                          = PropertyUtil.getSchemaProperty(context, "attribute_Title");


   if (sourcePage.equals("EditAllTasks")){

	taskSize = sTokOrder.countTokens();

        while(sTokOrder.hasMoreTokens()) {
                       strArray = new String[4];
                       strArray[0] =  sTokOrder.nextToken("~");

/* commented for bug 308866
/* commented for Bug 311950
                       String Title = (String) sTokName.nextToken("~");
                       if(Title.equals("none"))
                       {
                           strArray[1]  = "";
                       }
                       else{
                           strArray[1]  =Title;
                       }

 till here     */

//modified for 311950
           String sName = sTokName.nextToken("~");
          //strArray[1] =  sName.startsWith("role")?Framework.getPropertyValue(session,sName)+"(Role)":sName;
          if(sName.startsWith("role"))
          {
            strArray[1]=Framework.getPropertyValue(session,sName)+"(Role)";
          }
          else if(sName.startsWith("group"))
          {
            strArray[1]=PropertyUtil.getSchemaProperty(context,sName)+"(Group)";
          }
          else
          {
            strArray[1]=sName;
          }
//till here
                       strArray[2] =  sTokAction.nextToken("~");
                       strArray[3] =  sTokRouteNodes.nextToken("~");

                       if (sortMap.containsKey(strArray[0])) {
                         sortVector = (Vector)sortMap.get(strArray[0]);
                         sortVector.addElement(strArray);
                       }
                       else
                       {
                         sortVector = new Vector();
                         sortVector.addElement(strArray);
                         sortMap.put(strArray[0], sortVector);
                       }

            }

    }else if(taskDetails !=null && taskDetails.size() > 0){

			taskSize = taskDetails.size();
            Iterator taskListItr = taskDetails.iterator();

            while(taskListItr.hasNext()) {
              Map taskMap = (Map)taskListItr.next();
               strArray = new String[4];
               strArray[0] =  (String)taskMap.get(routeSequenceStr);
               strArray[1] =  (String)taskMap.get(taskNameStr);
               strArray[2] =  (String)taskMap.get(routeActionStr);
               strArray[3] =  (String)taskMap.get(relRouteNode);


               if (sortMap.containsKey(strArray[0])) {
                 sortVector = (Vector)sortMap.get(strArray[0]);
                 sortVector.addElement(strArray);
               }
               else
               {
                 sortVector = new Vector();
                 sortVector.addElement(strArray);
                 sortMap.put(strArray[0], sortVector);
               }
            }

    }

    String sRadioButtonNames = "";
    String sRouteNodeNames = "";

    String sRouteNodeIds = "";
    String sRouteNodeSecs = "";

    String sHiddenParams = "";
//Added for Bug No : 314737 Begin
//Added for Bug No : 314737  End
    String strCheckedAny = "";
    String strCheckedAll = "";

  for(int orderCount=1;orderCount<=taskSize; orderCount++) {


    rowClass = rowClass.equals("even") ? "odd" : "even";
    Integer inter = new Integer(orderCount);
    String sOrder = inter.toString();
    if(sortMap.containsKey(sOrder)) {
      Vector vect = (Vector) sortMap.get(sOrder);
      int iSize = vect.size();
      for(int iDisplay=0;iDisplay < vect.size(); iDisplay++) {
        String sTest[] = (String[])vect.elementAt(iDisplay);
//Added For Bug No : 314737 Begin
//Added For Bug No : 314737 End
        strCheckedAny = "";
        strCheckedAll = "";

 %>


    <tr class='<framework:swap id ="1" />'>
      <td><%=XSSUtil.encodeForHTML(context, sTest[0])%>&nbsp;</td>
      <td><%=XSSUtil.encodeForHTML(context,sTest[1])%>&nbsp;</td>
      <td><%=XSSUtil.encodeForHTML(context, i18nNow.getRangeI18NString(strRouteActionAttr, sTest[2],languageStr))%></td>
      <td>

      <%
              if(iSize > 1 ) {
                iSize=0;

      %>
               <table border="0">
                 <tr>


                <%  if(sourcePage.equals("EditAllTasks")){

                    DomainRelationship routeNode =null;
                    try{
                        routeNode = DomainRelationship.newInstance(context,sTest[3]);
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

                   %><!-- //XSSOK -->
                  <td><input type="radio" value="Any" name="radioAction<%=XSSUtil.encodeForHTML(context, sTest[0])%>" <%=strCheckedAny%> /></td>
                   <td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Any</emxUtil:i18n></td>
                   <!-- //XSSOK --><td><input type="radio"  value="All" name="radioAction<%=XSSUtil.encodeForHTML(context, sTest[0])%>" <%=strCheckedAll%> /> </td>
                   <td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.All</emxUtil:i18n></td>

                 <%
                 }
               }else{
                   //Added for Bug 309518 - Begin
                   String checkedRouteAction="";
                        if (actionRequiredMap!=null) {
                            if ((String)actionRequiredMap.get(sTest[0])!=null){
                                checkedRouteAction=(String)actionRequiredMap.get(sTest[0]);
                            }
                        }
                   //Added for Bug 309518 - End
               %>
               <!-- Modified for bug 309518 - Begin -->
                <!-- //XSSOK -->
                <td><input type="radio" value="Any" name="radioAction<%=XSSUtil.encodeForHTML(context, sTest[0])%>" <%=checkedRouteAction.equals("Any")?"checked":""%>/></td>
                    <!-- //XSSOK -->
                    <td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Any</emxUtil:i18n></td>
                    <!-- //XSSOK -->
                    <td><input type="radio" <%=checkedRouteAction.equals("Any")?"":"checked"%>  value="All" name="radioAction<%=XSSUtil.encodeForHTML(context, sTest[0])%>" /></td>
                    <td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.All</emxUtil:i18n></td>
               <!-- Modified for bug 309518 - End -->
            <%}%>



            </tr>
               </table>
      <%

                // Store the radio button names.
                if(sRadioButtonNames.equals("")) {
                  sRadioButtonNames = "radioAction"+sTest[0];
                  sRouteNodeSecs += "RouteNodeAction"+sTest[0];
                } else {
                  sRadioButtonNames += "|" + "radioAction"+sTest[0];
                  sRouteNodeSecs += "|" + "RouteNodeAction"+sTest[0];
                }

              }
              sHiddenParams += "<input type=\"hidden\" name='RouteNodeAction"+sTest[0]+"' value='"+sTest[3] +"' />";
      %>
             </td>
          </tr>
      <%
            }
          }
        }
      %>
        </table>
        <input type="hidden" name="radioNames" value="<xss:encodeForHTMLAttribute><%=sRadioButtonNames%></xss:encodeForHTMLAttribute>"/>
        <input type="hidden" name="routeNodeSecs" value="<xss:encodeForHTMLAttribute><%=sRouteNodeSecs%></xss:encodeForHTMLAttribute>"/>
        <!-- //XSSOK--><%=sHiddenParams%>

      </form>	  

      <%@include file = "../emxUICommonEndOfPageInclude.inc" %>
	  

