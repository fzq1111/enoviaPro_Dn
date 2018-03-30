<%--  emxRouteWizardAssignTaskDialog.jsp  -  Create Dialog for Assign task
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program

   static const char RCSID[] = $Id: emxRouteWizardAssignTaskDialog.jsp.rca 1.33 Tue Oct 28 19:01:09 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "emxComponentsJavaScript.js"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@ page import="com.matrixone.apps.framework.ui.UIUtil,java.util.*" %>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%@ page import = "com.matrixone.apps.domain.util.MqlUtil,java.util.Set,com.matrixone.apps.common.Person"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<%
String keyValue=emxGetParameter(request,"keyValue");
String languageStr     = request.getHeader("Accept-Language");
String advanceDateOption = EnoviaResourceBundle.getProperty(context,"emxComponents.common.AdvancedDateOption");
SimpleDateFormat dispDateFrmt = (SimpleDateFormat)DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), request.getLocale());
   String projectId  =  (String) formBean.getElementValue("objectId");
   String routeId       =  (String) formBean.getElementValue("routeId");
   String templateId    =  (String) formBean.getElementValue("templateId");
   String templateName  =  (String) formBean.getElementValue("templateName");
   String scopeId       =  (String) formBean.getElementValue("scopeId");
   String selectedAction   =  (String) formBean.getElementValue("selectedAction");
   String sortName    =  (String) formBean.getElementValue("sortName");
   String supplierOrgId    =  (String) formBean.getElementValue("supplierOrgId");
   String chkRouteAction   =  (String) formBean.getElementValue("chkRouteAction");
   String portalMode    =  (String) formBean.getElementValue("portalMode");
   String fromPageStr  =  (String) formBean.getElementValue("fromPage");
   String toAccessPage =  (String) formBean.getElementValue("toAccessPage");
   
   String slctdd    =  (String) formBean.getElementValue("slctdd");
   String slctmm    =  (String) formBean.getElementValue("slctmm");
   String slctyy    =  (String) formBean.getElementValue("slctyy");
     
	 
 //begin ---------------------------------------add by tangfan 2015.4.21
  	 String sContentId  =  (String) formBean.getElementValue("contentId");
   String sContentIds[] = sContentId.split("~");
 //end ---------------------------------------add by tangfan 2015.4.21 
   
   
   String strRole = i18nNow.getI18nString("emxComponents.Common.Role", "emxComponentsStringResource",
                                  request.getHeader("Accept-Language"));
   String strGroup = i18nNow.getI18nString("emxComponents.Common.Group", "emxComponentsStringResource",
                                   request.getHeader("Accept-Language"));

     int xx                                      = 0;
     int Count                                   = 0;

     int AllowDelegationCount           = 0;
     int NeedsReviewCount                        = 0;

     
     Date tempdate                               = new Date();

     MapList maplst  = (MapList)formBean.getElementValue("taskMapList");
     MapList routeMemberMapList  = (MapList)formBean.getElementValue("routeMemberMapList");
     Hashtable routeDetails  = (Hashtable)formBean.getElementValue("hashRouteWizFirst");

     StringBuffer personList = new StringBuffer(100);
     StringBuffer rolesList = new StringBuffer(100);
     StringBuffer groupsList = new StringBuffer(100);
     Iterator mapItr1 = maplst.iterator();
	 while(mapItr1.hasNext()) {
		    Map  map            = (Map)mapItr1.next();
		    String tempId   = (String)map.get("PersonId");
		    if(tempId.equals("Role")) {
		        rolesList.append(map.get("PersonName")).append("|");
		    }else if(tempId.equals("Group")){
		        groupsList.append(map.get("PersonName")).append("|");
		    } else {
		        personList.append(tempId).append("|");
		    }
	  }
	 
	  if(personList.length() > 0) {
	      personList.deleteCharAt(personList.length() -1);
	  }
	  if(rolesList.length() > 0) {
	      rolesList.deleteCharAt(rolesList.length() -1);
	  }
	  if(groupsList.length() > 0) {
	      groupsList.deleteCharAt(groupsList.length() -1);
	  }	 
	 
	  StringBuffer selectAssigneeURL = new StringBuffer();
	  selectAssigneeURL.append("../common/emxIndentedTable.jsp?");
	  selectAssigneeURL.append("table=APPUserSummary").append('&');
	  selectAssigneeURL.append("selection=single").append('&');
	  selectAssigneeURL.append("program=emxRoute:getRouteAssigneesToSelect").append('&');
	  selectAssigneeURL.append("personList=").append(personList).append('&');
	  selectAssigneeURL.append("roleList=").append(rolesList).append('&');
	  selectAssigneeURL.append("groupList=").append(groupsList).append('&');
	  selectAssigneeURL.append("submitURL=").append("../components/emxRouteWizardTaskAssignSelectProcess.jsp?keyValue=").append(keyValue).append('&');
	  selectAssigneeURL.append("suiteKey=Components").append('&');
	  selectAssigneeURL.append("header=emxComponents.Common.AssignTasks").append('&');
	  selectAssigneeURL.append("submitLabel=emxFramework.Common.Done").append('&');
	  selectAssigneeURL.append("cancelLabel=emxFramework.Common.Cancel").append('&');
	  selectAssigneeURL.append("objectBased=false").append('&');
	  selectAssigneeURL.append("displayView=details").append('&');
	  selectAssigneeURL.append("customize=false").append('&');
	  selectAssigneeURL.append("objectCompare=false").append('&');
	  selectAssigneeURL.append("multiColumnSort=false").append('&');
	  selectAssigneeURL.append("HelpMarker=emxhelpcreateroutewizard3").append('&');
	  selectAssigneeURL.append("showClipboard=false").append('&');	 
     
   String routeBasePurpose="";

     String parentObjectId = null;
     if (routeDetails != null){
       parentObjectId = (String)routeDetails.get("objectId");
       routeBasePurpose   =  (String) formBean.getElementValue("routeBasePurpose");
     }


     String parentTaskDueDate = getParentTaskDueDate(context,parentObjectId);
     if(toAccessPage == null || "null".equals(toAccessPage)){
      toAccessPage = "";
     }

     if(fromPageStr == null || "null".equals(fromPageStr)){
     fromPageStr = "";
     }


    if (selectedAction == null || selectedAction.equals("null") || selectedAction.equals(""))
    selectedAction = "false";


     com.matrixone.apps.common.Person PersonObject = (com.matrixone.apps.common.Person) DomainObject.newInstance(context, DomainConstants.TYPE_PERSON);
     String sRoute                               = i18nNow.getI18nString("emxComponents.Common.Route", "emxComponentsStringResource", sLanguage);
     String temp_hhrs_mmin                       = JSPUtil.getApplicationProperty(context,application,"emxComponents.RouteScheduledCompletionTime");

//TO GET THE NAME OF THE ROUTE OWNER


    //BusinessObject routeOwner = new BusinessObject(DomainObject.TYPE_PERSON,context.getUser().trim(),"-",context.getVault().getName());
    Person routeOwner = Person.getPerson(context);
    //routeOwner.open(context);
    String routeOwnerName          = routeOwner.getObjectId()+"~"+routeOwner.getName().trim();
    //routeOwner.close(context);


      Hashtable hashRouteWizFirst = (Hashtable)formBean.getElementValue("hashRouteWizFirst");

     templateId          = (String)hashRouteWizFirst.get("templateId");
     templateName        = "";

     String sTaskEditSetting  = "";
     if(templateId != null && !"".equals(templateId) && !templateId.equals("null")){
      DomainObject routeTempObj = DomainObject.newInstance(context ,templateId);
      sTaskEditSetting = getTaskSetting(context,templateId);
      templateName    = routeTempObj.getName(context);
     }

     if(sTaskEditSetting == null){
        sTaskEditSetting = "";
     }


     if(maplst == null) {
        maplst = new MapList();
     }

     if(routeMemberMapList == null) {
        routeMemberMapList = new MapList();
     }
      maplst.sort(PersonObject.ATTRIBUTE_ROUTE_SEQUENCE, "ascending", "Integer");/*modified "String" to "Integer" as 10th task is displayed as 2nd(create Routes with Route template having tasks with names t1,t2,t3,....t10  using route wizard int the Define Route Tasks screen)  and if the task with order 1 is deleted then 10th task takes the order 1 Bug# 329211*/

	  //begin --------------------------------------------add by tangfan 2015.4.21
	  
	  StringList objectSelects = new StringList();
objectSelects.addElement(DomainObject.SELECT_NAME);
objectSelects.addElement(DomainObject.SELECT_ID);

objectSelects.addElement("attribute[First Name]");
objectSelects.addElement("attribute[Last Name]");

MapList mlProduct = DomainObject.findObjects(context, "Person",// typePattern
    "*",// namePattern
    "-",// revPattern
    "*",// ownerPattern
    "*",// vaultPattern
    "current==Active",// whereExpression
    false,// expandType
    objectSelects);

   Map personMap = new HashMap();
for (Iterator iter = mlProduct.iterator(); iter.hasNext();) {
    Map productMap = (Map) iter.next();
    String sPersonName2 = (String) productMap.get(DomainObject.SELECT_NAME);
    String sPersonID = (String) productMap.get(DomainObject.SELECT_ID);
    String firstName = (String) productMap.get("attribute[First Name]");
    String lastName = (String) productMap.get("attribute[Last Name]");


    personMap.put(sPersonName2,sPersonID);
    personMap.put(sPersonName2 + "FullName", lastName + firstName);

}

   //end ----------------------------------------------------add by tangfan 2015.4.21


 %>
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

<script language="Javascript">

  var thisday = null;
  var thismonth = null;
  var thisyear = null;
  var CurrentDate = "";



<%
  if(slctdd!=null && !"null".equals(slctdd) && !"".equals(slctdd)){
%>
    emxUIPopupCalendar.prevDate = new Date('<%=XSSUtil.encodeForJavaScript(context, slctyy)%>','<%=XSSUtil.encodeForJavaScript(context, slctmm)%>','<%=XSSUtil.encodeForJavaScript(context, slctdd)%>');

<%

  }
%>


 // function to be called on click of Add Task Link
  function addTask() {
	
    setDateValue();
  	var checkedFlag=getCompatibility();
	 if (checkedFlag == '') {
      alert("\u8BF7\u9009\u62E9\u6D41\u7A0B\u4EFB\u52A1\u3002");
      return;
    } else {
    document.routeActionsForm.action="LSRouteWizardAssignTaskProcess.jsp?linkFlag=AddTask&projectId=<%=XSSUtil.encodeForURL(context, projectId)%>&slctdd="+thisday+"&slctmm="+thismonth+"&slctyy="+thisyear;
   if (jsDblClick()) {
    document.routeActionsForm.submit();
   }
    return;
	}
  }
  
    function getCompatibility() {
        var compatibility = "";
       var  input = document.getElementsByTagName("input");
        var value1="";
        for (var i = 0; i < input.length; i++) {
            if (input[i].type == "checkbox") {
                if (input[i].checked) {
                    value1 = input[i].value;
                    compatibility += value1 + ",";
                }
            }
        }
        compatibility = compatibility.substring(0,compatibility.lastIndexOf(","));
        return  compatibility;
    }


 // function to remove the task.
  function removeSelected() {
    var checkedFlag = checkedCheckBoxValues();
    if (checkedFlag == '') {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.SelectTask</emxUtil:i18nScript>");
      return;
    } else {
      if (confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.MsgConfirm</emxUtil:i18nScript>") != 0)  {
        setDateValue();
        document.routeActionsForm.action="emxRouteWizardAssignTaskProcess.jsp?linkFlag=RemoveSelected&projectId=<%=XSSUtil.encodeForURL(context, projectId)%>&slctdd="+thisday+"&slctmm="+thismonth+"&slctyy="+thisyear;
	  if (jsDblClick()) {
        document.routeActionsForm.submit();
	  }
        return;
      }
    }
  }


    function sortTaskList() {
  <%
      if ( maplst.size() == 0 ) {
  %>
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.TaskMessage</emxUtil:i18nScript>");
        return;
  <%
      } else {
  %>
        setDateValue();
        document.routeActionsForm.action="emxRouteWizardAssignTaskProcess.jsp?linkFlag=sortList&projectId=<%=XSSUtil.encodeForURL(context, projectId)%>&slctdd="+thisday+"&slctmm="+thismonth+"&slctyy="+thisyear;
       if (jsDblClick()) {
        document.routeActionsForm.submit();
	   }
        return;
  <%
      }
  %>
  }


//function to open the RouteTaskAssignSelected dialog window.
  function AssignSelected(){
    var checkedValue = checkedCheckBoxValues();
    if (checkedValue == '') {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignSelected.SelectTask</emxUtil:i18nScript>");
      return;
      } else {
      	setDateValue();
        var selectAssigneeURL = "<%=selectAssigneeURL%>routeNodeId=" + escape(checkedValue);
        emxShowModalDialog(selectAssigneeURL, 575, 575);
      }
  }


//function to close the window.
  function closeWindow() {

    submitWithCSRF("emxRouteWizardCancelProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>", window);
  }

  // function to be called on click of previous button
  function goBack() {

    // submit with values to process page of step 4; then from there redirect to step 3
    document.routeActionsForm.action="LSRouteWizardAssignTaskProcess.jsp?toAccessPage=yes&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>";
    document.routeActionsForm.submit();
    return;

  }


//function to return the checked check box value. modified for UI adoptions 
  function checkedCheckBoxValues(){
    var checkedVal='';
    for (var i=0; i < document.routeActionsForm.elements.length; i++) {
      if (document.routeActionsForm.elements[i].name == "routeNodeId" && document.routeActionsForm.elements[i+5].checked)  {
        checkedVal = checkedVal+document.routeActionsForm.elements[i].value+'~'+document.routeActionsForm.elements[i+1].value+'~';
      }
    }
    return checkedVal;

  }

  // function to select all the check boxes
  function doCheck() {

    var objForm = document.routeActionsForm;
    var chkList = objForm.chkList;
    for (var i=0; i < objForm.elements.length; i++)
    if (objForm.elements[i].name.indexOf('chkItem1') > -1 && objForm.elements[i].disabled == false){ // Modified for IR Mx376309V6R2011
      objForm.elements[i].checked = chkList.checked;
    }

  }

 // function to make all the check box disable
  function updateCheck() {
    //var objForm = document.routeActionsForm;
    //var chkList = objForm.chkItem1;
    //chkList.checked = false;
  }


  // removes leading, trailing whitespaces
  function trimStr (textStr) {

      while (textStr.charAt(textStr.length-1)==' ')
        textStr = textStr.substring(0,textStr.length-1);
      while (textStr.charAt(0)==' ')
        textStr = textStr.substring(1,textStr.length);
      return textStr;
  }



   // to allow only integers as delta offsets
  function CheckValidity(toCheckStr){

    var allowedChars = "0123456789";
    for (i = 0; i < toCheckStr.length; i++){
      checkChar = allowedChars.indexOf(toCheckStr.charAt(i))
      if (checkChar < 0){
         return true;
      }
     }
    return false;
   }


  //Array sort numerically
  function sortNum(arrayName,length) {

    for (var i=0; i<(length-1); i++) {
      for (var b=i+1; b<length; b++) {
        if (arrayName[b] < arrayName[i]) {
          var temp = arrayName[i];
          arrayName[i] = arrayName[b];
          arrayName[b] = temp;
        }
      }
    }

  }


 function isDeltaRadio(num){

       var count = 0;
       for ( var k = 0; k < document.routeActionsForm.length; k++ ) {
       if (( document.routeActionsForm.elements[k].type  == "select-one" )&& (document.routeActionsForm.elements[k].name == "routeTime")){
         count++;
       }
       }

       <%
        if(advanceDateOption.equals("true")){
        %>
       if (count == 1) {
        if((document.routeActionsForm.duedateOption0[0].checked && document.routeActionsForm.duedateOption0[0].value =="calendar") || (document.routeActionsForm.duedateOption0[2].checked && document.routeActionsForm.duedateOption0[2].value =="assignee")) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.NotDeltaOption</emxUtil:i18nScript>");
        document.routeActionsForm.duedateOffset.value = "";
        document.routeActionsForm.duedateOption0[2].focus();
        return;
        }
      }else {
        if((eval("document.routeActionsForm.duedateOption"+num+"[0].checked") && eval("document.routeActionsForm.duedateOption"+num+"[0].value") =="calendar" ) || (eval("document.routeActionsForm.duedateOption"+num+"[2].checked") && eval("document.routeActionsForm.duedateOption"+num+"[2].value") =="assignee")) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.NotDeltaOption</emxUtil:i18nScript>");
        document.routeActionsForm.duedateOffset[num].value = "";
        eval("document.routeActionsForm.duedateOption"+num+"[2].focus();");
        return;
        }
      }
         <%
      }
     %>

  }



//functions for dates



   // javascript function shows calendar popup only if calendar radio is chosen. Else alert user.
 function showCal(formName,dateField, id, num){


    var count = 0;
      for ( var k = 0; k < document.routeActionsForm.length; k++ ) {
        if (( document.routeActionsForm.elements[k].type  == "select-one" )&& (document.routeActionsForm.elements[k].name == "routeTime")){
            count++;
        }
      }
     // if count is 1, routeTime will not be an array
    if (count == 1) {
       <%
    if(advanceDateOption.equals("true")){
     %>

      if((document.routeActionsForm.duedateOption0[2].checked && document.routeActionsForm.duedateOption0[2].value =="assignee") || (document.routeActionsForm.duedateOption0[1].checked && document.routeActionsForm.duedateOption0[1].value =="delta")){
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.NotCalendarOption</emxUtil:i18nScript>");
        document.routeActionsForm.duedateOption0[2].focus();
        return;
      }else{
          document.routeActionsForm.routeTime.focus();
                showCalendar(formName,dateField,CurrentDate,true);
      }
    <%
        }else{

        %>

            document.routeActionsForm.routeTime.focus();
            showCalendar(formName,dateField,CurrentDate,true);

     <% } %>

     }else{
    <%
      if(advanceDateOption.equals("true")){
      %>
        if((eval("document.routeActionsForm.duedateOption"+num+"[2].checked") && eval("document.routeActionsForm.duedateOption"+num+"[2].value") =="assignee") || (eval("document.routeActionsForm.duedateOption"+num+"[1].checked") && eval("document.routeActionsForm.duedateOption"+num+"[1].value") =="delta") ){
           alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.NotCalendarOption</emxUtil:i18nScript>");
           eval("document.routeActionsForm.duedateOption"+num+"[2].focus();");
           return;
        }else{
           eval("document.routeActionsForm.routeTime[" + num + "].focus();");
           showCalendar(formName,dateField,CurrentDate,true);
        }
        <%
          } else {
        %>


            eval("document.routeActionsForm.routeTime[" + num + "].focus();");
            showCalendar(formName,dateField,CurrentDate,true);

        <% } %>
     }

    return;
 }


 // javascript function to clear date value at particular field

   // javascript function to clear date value at particular field
    function cleardate(num) {

            var num1= num - 1;

            var defaultTime = '<%=temp_hhrs_mmin.substring(0, (temp_hhrs_mmin.indexOf(':')+3))+":00 "+(temp_hhrs_mmin.indexOf("AM")>0?"AM":"PM")%>';
            var count = 0;
            for ( var k = 0; k < document.routeActionsForm.length; k++ ) {
              if (( document.routeActionsForm.elements[k].type  == "select-one" )&& (document.routeActionsForm.elements[k].name == "routeTime")){
                  count++;
              }
             }
            // if count is 1, routeTime will not be an array
            if (count == 1) {

               if(trimStr(document.routeActionsForm.routeScheduledCompletionDate0.value) !="") {

                   document.routeActionsForm.routeScheduledCompletionDate0.value="";
                   document.routeActionsForm.routeScheduledCompletionDate0_msvalue.value="";
               }

                for ( var z = 0; z < document.routeActionsForm.routeTime.options.length; z++ ) {

                 if(document.routeActionsForm.routeTime.options[z].value==defaultTime) {
                    document.routeActionsForm.routeTime.options[z].selected=true;

                    break;
                  }
             }

           }else{

        <%
          if(advanceDateOption.equals("true")){
          %>
           if(trimStr(eval("document.routeActionsForm.routeScheduledCompletionDate"+num+".value")) !="") {

             eval("document.routeActionsForm.routeScheduledCompletionDate"+num+".value=\"\";");
             eval("document.routeActionsForm.routeScheduledCompletionDate"+num+"_msvalue.value=\"\";");

           }
                var sCombo = eval("document.routeActionsForm.routeTime[" + num + "];");

           for ( var z = 0; z < sCombo.options.length; z++ ) {

             if(sCombo.options[z].value==defaultTime) {
              sCombo.options[z].selected=true;
              break;
            }
             }

             <%
          }else{
           %>

                 if(trimStr(eval("document.routeActionsForm.routeScheduledCompletionDate"+num1+".value")) !="") {
                      eval("document.routeActionsForm.routeScheduledCompletionDate"+num1+".value=\"\";");
                 }
                 var sCombo = eval("document.routeActionsForm.routeTime[" + num1 + "];");

                for ( var z = 0; z < sCombo.options.length; z++ ) {
                    if(sCombo.options[z].value==defaultTime) {
                           sCombo.options[z].selected=true;
                           break;
                     }
                }
           <%
          }
           %>
            }

         return;
     }





      // if assignee due-date / delta selected, clear default date..
       function toggleDefaultDate(num) {

         var count = 0;
         for ( var k = 0; k < document.routeActionsForm.length; k++ ) {
            if (( document.routeActionsForm.elements[k].type  == "select-one" )&& (document.routeActionsForm.elements[k].name == "routeTime")){
                 count++;
             }
         }

     <%
      if(advanceDateOption.equals("true")){
       %>

       if (count == 1) {
        if((document.routeActionsForm.duedateOption0[2].checked && document.routeActionsForm.duedateOption0[2].value =="assignee") || (document.routeActionsForm.duedateOption0[1].checked && document.routeActionsForm.duedateOption0[1].value =="delta")) {
         cleardate(num);
        }
        if((document.routeActionsForm.duedateOption0[0].checked && document.routeActionsForm.duedateOption0[0].value =="calendar") || (document.routeActionsForm.duedateOption0[2].checked && document.routeActionsForm.duedateOption0[2].value =="assignee")) {
              document.routeActionsForm.duedateOffset.value = "";
        }
        return;
       }else{
        if((eval("document.routeActionsForm.duedateOption"+num+"[2].checked") && eval("document.routeActionsForm.duedateOption"+num+"[2].value") =="assignee") || (eval("document.routeActionsForm.duedateOption"+num+"[1].checked") && eval("document.routeActionsForm.duedateOption"+num+"[1].value") =="delta") ) {
         cleardate(num);
        }
        if((eval("document.routeActionsForm.duedateOption"+num+"[0].checked") && eval("document.routeActionsForm.duedateOption"+num+"[0].value") =="calendar") || (eval("document.routeActionsForm.duedateOption"+num+"[2].checked") && eval("document.routeActionsForm.duedateOption"+num+"[2].value") =="assignee")) {
			if(typeof(document.routeActionsForm.duedateOffset[num])=="undefined")  {
              document.routeActionsForm.duedateOffset.value = "";
          }
          else  {
          document.routeActionsForm.duedateOffset[num].value = "";
        }
        }
        return;
       }

     <%
        }
       %>

         return;

       }




  var showCalendarAlert = true; // to prevent secnd alert due to focus made again on radio option


  //removing focus from date field.Not letting user to update the field.
  function redirectFocus(num) {

    var count = 0;
    for ( var k = 0; k < document.routeActionsForm.length; k++ ) {
      if (( document.routeActionsForm.elements[k].type  == "select-one" )&& (document.routeActionsForm.elements[k].name == "routeTime")){
        count++;
      }
    }
    if (count == 1) {// if count is 1, routeTime will not be an array
      // check if calendar date radio is checked. Else alert calendar option not selected
      <%
    if(advanceDateOption.equals("true")){
    %>

      if((document.routeActionsForm.duedateOption0[2].checked  && document.routeActionsForm.duedateOption0[2].value == "assignee") || (document.routeActionsForm.duedateOption0[1].checked  && document.routeActionsForm.duedateOption0[1].value == "delta")){
        if(showCalendarAlert){
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.NotCalendarOption</emxUtil:i18nScript>");
         showCalendarAlert = false;
        }else{
         showCalendarAlert = true;
        }
       document.routeActionsForm.duedateOption0[2].focus();
       return;
     }else{

        document.routeActionsForm.routeTime.focus();
          showCalendar('routeActionsForm','routeScheduledCompletionDate0',CurrentDate,true);
     }
    <%
      }else{
      %>


        document.routeActionsForm.routeTime.focus();
        showCalendar('routeActionsForm','routeScheduledCompletionDate0',CurrentDate,true);

      <% } %>
    } else{

    <%
    if(advanceDateOption.equals("true")){
    %>

      if((eval("document.routeActionsForm.duedateOption"+num+"[2].checked") && eval("document.routeActionsForm.duedateOption"+num+"[2].value") =="assignee") || (eval("document.routeActionsForm.duedateOption"+num+"[1].checked") && eval("document.routeActionsForm.duedateOption"+num+"[1].value") =="delta")){
        if(showCalendarAlert){
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.NotCalendarOption</emxUtil:i18nScript>");
         showCalendarAlert = false;
        }else{
         showCalendarAlert = true;
        }
        eval("document.routeActionsForm.duedateOption"+num+"[2].focus();");
        return;
      }else{

        showCalendarAlert = true;
        eval("document.routeActionsForm.routeTime[" + num + "].focus();");
          eval("showCalendar('routeActionsForm','routeScheduledCompletionDate"+ num +"',CurrentDate,true);");
      }

    <% }else{ %>

         showCalendarAlert = true;
         eval("document.routeActionsForm.routeTime[" + num + "].focus();");
         eval("showCalendar('routeActionsForm','routeScheduledCompletionDate"+ num +"',CurrentDate,true);");
     <%
     }
     %>
     }
     return;
  }
    //-----------------------------------------------------------------------------------
    // Function to Compare if date and order are in sequence
    //-----------------------------------------------------------------------------------

  // checks whether the dates are later than today. Also checks the ordering of the dates.
  function largestdate(order1,dt1,order2,dt2) {

      // if date variables below have empty or undefined values,they are assignee due-dates and ignored..
    if(dt1 == "undefined" || dt1== "" || dt1 == null || dt2 == "undefined" || dt2== "" || dt2== null ){
      return true;
    }
    var date1 = new Date(dt1);
    var date2 = new Date(dt2);

    //  addressing  Y2K.
    if (date1.getFullYear()< 1950) {
      // add 100 years.
      date1.setFullYear(date1.getFullYear() + 100);
    }
    if (date2.getFullYear()< 1950) {
      // add 100 years.
      date2.setFullYear(date2.getFullYear() + 100);
    }

   // comparing the order and the dates
    if (((((order1 >  order2) && (Date.parse(date1.toGMTString()) >= Date.parse(date2.toGMTString())))) || (((order1 <  order2) && (Date.parse(date1.toGMTString()) <= Date.parse(date2.toGMTString())))) || (order1 ==  order2))){
      return true;
    } else {
      return false;
    }
  }



  //-----------------------------------------------------------------------------------
  // Function to populate array with date and order values.
  //-----------------------------------------------------------------------------------

      // function to populate array with date and order values.
    function dateOrderCompare() {

      // step  1 : Moving dates in the order to array, declaring an array to store the order number and date
      var arrcol    = 0;
      var goodDtCnt = 0; // to hold count of non-empty and valid dates
      var slctArray = document.routeActionsForm.elements["routeOrder"];


      // loop to find out valid date elements
      for (ct = 0; ct < slctArray.length; ct++) {
        //if(trimStr(eval("document.routeActionsForm.routeScheduledCompletionDate"+ct+".value")) != ""){
        if(eval("document.routeActionsForm.routeScheduledCompletionDate"+ct+".value") != ""){
           goodDtCnt++;
        }
      }

      var dateOrder = new Array(goodDtCnt);

      arrcol        = 0;
      for (ct = 0; ct < slctArray.length; ct++){ // storing the order value
       //if(trimStr(eval("document.routeActionsForm.routeScheduledCompletionDate"+ct+".value")) != ""){
       if(eval("document.routeActionsForm.routeScheduledCompletionDate"+ct+".value") != ""){
         if(slctArray[ct].type == "select-one")
           {
              dateOrder[arrcol] = parseInt(slctArray[ct].options[slctArray[ct].selectedIndex].value);
              arrcol+=2;
           }
          else
          {
            dateOrder[arrcol] = parseInt(slctArray[ct].value);
            arrcol+=2;
          }

       }
      }

      arrcol       = 1;
      DtArray      = document.routeActionsForm.elements["routeTime"];
      var arrcount = 0;
      for (var i=0; i<document.routeActionsForm.elements.length;i++)
      {
        if ((document.routeActionsForm.elements[i].name.substring(0,28)  == "routeScheduledCompletionDate") &&
            (document.routeActionsForm.elements[i].value != "") &&
            (document.routeActionsForm.elements[i].name.indexOf("_msvalue") > 0))
        {
	  var check= document.routeActionsForm.elements[i].name.substring(28,29);
          arrcount++;
         if(eval("document.routeActionsForm.duedateOption"+check+"[0].checked"))
         {
          var milli = Number(document.routeActionsForm.elements[i].value);
          var DtTm =  new Date(milli);
          var k = arrcount - 1;
          if (DtTm.getFullYear()< 1950){
            // add 100 years.
            DtTm.setFullYear(DtTm.getFullYear() + 100);
          }
          var AmPmVar = new String(DtArray[k].options[DtArray[k].selectedIndex].value.substring(DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(" ") +1 ,DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(" ") + 3));
          if (AmPmVar == "PM"){
            DtTm.setHours(parseInt(DtArray[k].options[DtArray[k].selectedIndex].value.substring(0,DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(":")))+12);
          } else if (AmPmVar == "AM"){
            var check = parseInt(DtArray[k].options[DtArray[k].selectedIndex].value.substring(0,DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(":")));
            if(check == 12){
                
                DtTm.setHours("00");
            }
            else{
                
                DtTm.setHours(check);
            } 
			//DtTm.setHours(parseInt(DtArray[k].options[DtArray[k].selectedIndex].value.substring(0,DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(":"))));
          }
          DtTm.setMinutes(parseInt(DtArray[k].options[DtArray[k].selectedIndex].value.substring(DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(":")+1,DtArray[k].options[DtArray[k].selectedIndex].value.length)));
          dateOrder[arrcol]=DtTm;
          arrcol+=2;
	 }
        }
      }

      // step 2 :Passing it thru function largestdate to check validity
      if (document.routeActionsForm.routeOrder.length < 2){ //only a single date field
        return true;
      } else {
        for (var k =0 ; k < dateOrder.length; k+=2){
          for (var q = k + 2; q < dateOrder.length; q+=2){
            var rslt = largestdate(dateOrder[k],dateOrder[k+1],dateOrder[q],dateOrder[q+1]);
            if (!rslt){
              alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.DateOrder</emxUtil:i18nScript>");
              eval("document.routeActionsForm.routeTime[1].focus();");
              k = arrcol;
              q = arrcol;
              return false;
            }
          }
        }
      }
     return true;
  }

    //-----------------------------------------------------------------------------------
    // Function to Sort array
    //-----------------------------------------------------------------------------------

    //Array sort numerically
    function sortNum(arrayName,length){

       for (var i=0; i<(length-1); i++){
         for (var b=i+1; b<length; b++){
           if (arrayName[b] < arrayName[i]){
             var temp = arrayName[i];
             arrayName[i] = arrayName[b];
             arrayName[b] = temp;
           } //end-if
         } //end for-loop
       } //end for-loop

    }

  //function to set date.
  function setDateValue(){

   var sSelectedDate = emxUIPopupCalendar.prevDate;
   if(sSelectedDate != null) {
      thismonth = sSelectedDate.getMonth();
      thisyear  = sSelectedDate.getFullYear();
      thisday   = sSelectedDate.getDate();
    }

  }



 //function to submit the page.
  function submitForm() {

<%
    // function to check minimum of one task is connected to route object
    if ( maplst.size() == 0 ) {
%>
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.TaskMessage</emxUtil:i18nScript>");
      return;
<%
    }
%>
    var count = 0;
    for (var k=0; k < document.routeActionsForm.length; k++ ) {
      if ((document.routeActionsForm.elements[k].name == "routeOrder")) {
        count++;
      }

    }
    // step 4 : Check Instructions.
    if (count == 1){ //only one instruction field
      var namebadCharDescrption = checkForBadChars(document.routeActionsForm.routeInstructions);
      if (trim(document.routeActionsForm.routeInstructions.value).length == 0){
        alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
        document.routeActionsForm.routeInstructions.focus();
        return;
      }else if (namebadCharDescrption.length != 0){
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
        document.routeActionsForm.routeInstructions.focus();
        return;
      }
    } else {
      // more than one instruction field
      for (var k=0; k < count; k++) {
         var namebadCharDescrption = checkForBadChars(document.routeActionsForm.routeInstructions[k]);
        if(trim(document.routeActionsForm.routeInstructions[k].value).length == 0) {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
          document.routeActionsForm.routeInstructions[k].focus();
          return;
        }else if (namebadCharDescrption.length != 0){
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
          document.routeActionsForm.routeInstructions[k].focus();
          return;
        }
      }
    }
    // date Validation for giving message to user if any selected date is past date,taking current date into a variable
    var toDayDate = new Date();
   // toDayDate.setDate(toDayDate.getDate());

    var pastDate = "false";
    var position = 0;
    var parentTaskDate = "false";


    // checking whether the date selected is earlier than cuurent date.
    // also added check to prevent Route Owner asking self-review

var taskCount=-1 ; // Declared for the fix of bug #295599

    for (var i=0; i<document.routeActionsForm.length;i++) {

       if(document.routeActionsForm.elements[i].type=="select-one" && document.routeActionsForm.elements[i].name == "personId"){
         var rtOwnerStr    = '<%=XSSUtil.encodeForJavaScript(context, routeOwnerName)%>';
         var assigneeStr   = document.routeActionsForm.elements[i].options[document.routeActionsForm.elements[i].selectedIndex].value;
         // 3rd form element from task assignee select box is hidden form element having NeedReview flag value
         var needReviewStr = document.routeActionsForm.elements[i+3].value;
         if(rtOwnerStr == assigneeStr && needReviewStr=="Yes"){
           alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskEdit.CanNotHaveTaskReview</emxUtil:i18nScript>");
           document.routeActionsForm.elements[i].focus();
           return;
         }
       }

      if ((document.routeActionsForm.elements[i].type  == "text" ) && (document.routeActionsForm.elements[i].name == "taskName")){
        
        //Added for the Task Title Feature on 20th june 2007
        if(document.routeActionsForm.elements[i].value.length == 0){
              alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.EnterTitleField</emxUtil:i18nScript>");
              document.routeActionsForm.elements[i].focus();
              return;
        }//End of the Task Title Feature
        var namebadCharName       = checkForUnifiedNameBadChars(document.routeActionsForm.elements[i], true);
        var nameAllBadCharName = getAllNameBadChars(document.routeActionsForm.elements[i]);
        var name = document.routeActionsForm.elements[i].name;
        if (namebadCharName.length != 0){
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInvalidInput</emxUtil:i18nScript>"+nameAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript> "+name+" <emxUtil:i18nScript localize="i18nId">emxComponents.Alert.Field</emxUtil:i18nScript>"); 
              document.routeActionsForm.elements[i].focus();
              return;
        }

        if (!(isAlphanumeric(trim(document.routeActionsForm.elements[i].value), true))){
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidName</emxUtil:i18nScript>");
          document.routeActionsForm.elements[i].focus();
          return;
        }
      }
 /// bug No 295599 
     if ((document.routeActionsForm.elements[i].name.substring(0,28)  == "routeScheduledCompletionDate") && (document.routeActionsForm.elements[i].name.indexOf("_msvalue") > 0)){
			var rouSchComDate = document.routeActionsForm.elements[i].value;
      taskCount++ ;
		 }
  //till here

      if ((document.routeActionsForm.elements[i].name.substring(0,28)  == "routeScheduledCompletionDate") && (document.routeActionsForm.elements[i].name.indexOf("_msvalue") < 0)){
        var check= document.routeActionsForm.elements[i].name.substring(28,29);
        var dueDateRadio = true;
        if(document.getElementsByName("duedateOption0").length > 1){
        dueDateRadio = eval("document.routeActionsForm.duedateOption"+check+"[0].checked")
        }
        if(dueDateRadio){
          var dateStr = document.routeActionsForm.elements[i].value;
          var time    = document.routeActionsForm.elements[i+1].options[document.routeActionsForm.elements[i+1].selectedIndex].value;
          var hour=time.substring(0,time.indexOf(":"));
          var minute=time.substring((time.lastIndexOf(":"))-2,time.lastIndexOf(":"));
          var ampm=trim(time.substring(time.indexOf(" ")),time.indexOf(" ")+2);

          dateStr=new Date(dateStr);
          if(ampm=="AM"){
          dateStr.setHours(parseInt(hour));
          }else if(ampm=="PM"){
            if(parseInt(hour) == 12){
              hour="0";
            }
          dateStr.setHours(parseInt(hour)+12);
          }
          dateStr.setMinutes(parseInt(minute));


      if (dateStr != "" && dateStr != null) {
<%
      if(parentTaskDueDate !=null && !("".equals(parentTaskDueDate))){
%>
        var parentTaskDuedate =new Date('<%=XSSUtil.encodeForJavaScript(context, parentTaskDueDate)%>');


/// bug No : 295599
        //var schDate = new Date(dateStr);
        var schDate = new Date();
	      schDate.setTime(rouSchComDate);
//till here

        if (schDate.getFullYear()< 1950) {
           // add 100 years.
           schDate.setFullYear(schDate.getFullYear() + 100);
        }
        if ( (Date.parse(schDate.toGMTString()) >= Date.parse(parentTaskDuedate.toGMTString())) ){
           parentTaskDate = "true";
           position =i;
           break;
        }
<%
      }
%>

/// bug No : 295599
        // var date1 = new Date(dateStr);
        var date1 = new Date();
	      date1.setTime(rouSchComDate);
//till here

          //  addressing  Y2K.
          if (date1.getFullYear()< 1950) {
            // add 100 years.
            date1.setFullYear(date1.getFullYear() + 100);
          }


//# bug No : 295599
    var hrs,mns,str1 ;

if ( count==1 ) {
    str1=document.routeActionsForm.routeTime.value;
} else {
    str1=document.routeActionsForm.routeTime[taskCount].value;
}
    hrs=parseInt(str1.substring(0,str1.indexOf(':')));
    mns=parseInt(str1.substring(str1.indexOf(':')+1,str1.indexOf(' ')));
	if (str1.substring(str1.indexOf(' ')+1) == 'PM') {
		if(hrs == 12)
		{
			hrs = 0;
		}
     		hrs=hrs+12 ;
   	}
    date1.setHours(hrs);
    date1.setMinutes(mns);
//# bug No : 295599 end
		if ( (Date.parse(date1.toGMTString()) <= Date.parse(toDayDate.toGMTString())) ){
            pastDate = "true";
            position = i;
            break;
          }
        }
       }
      }
    }
    if(parentTaskDate=='true'){
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskDetails.IncorrectSubordinateDate</emxUtil:i18nScript>");
      document.routeActionsForm.elements[position].value = "";
      document.routeActionsForm.elements[position].focus();
      return;
    }

    if ( pastDate == "true" ) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterdPastDate</emxUtil:i18nScript>");
      document.routeActionsForm.elements[position].value = "";
      document.routeActionsForm.elements[position].focus();
      return;
    }

    // step 1 : Check if tasks in order
    if (count == 1) {     //only one order field
     var selectedValue="";
     try{
         selectedValue =  document.routeActionsForm.routeOrder.options[document.routeActionsForm.routeOrder.selectedIndex].value
          }catch(e){selectedValue = document.routeActionsForm.routeOrder.value;}
      if (selectedValue != 1 ) {
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderBig</emxUtil:i18nScript>" +" "+ document.routeActionsForm.routeOrder.options[document.routeActionsForm.routeOrder.selectedIndex].value + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderCont</emxUtil:i18nScript>");
         return;
      }

    } else {
      selArray = document.routeActionsForm.elements["routeOrder"];
      storeArray = new Array(count);
      var missingValue;
      for (ct = 0; ct < count; ct++){
       if(selArray[ct].type == "select-one")
        {
          // get array of values
          storeArray[ct] = parseInt(selArray[ct].options[selArray[ct].selectedIndex].value);
        }
        else
        {
          storeArray[ct] = parseInt(selArray[ct].value);
        }
      }
      sortNum(storeArray,storeArray.length);

      for (sorted = 0; sorted < (storeArray.length - 1) ; sorted++){
        // make sure the first number in the sorted array is 1
        if (sorted == 0) {
          if (storeArray[sorted] != 1) {
            missingValue = 1;
            errorValue = storeArray[sorted];
            break;
          }
        }
        if ((storeArray[sorted] != storeArray[sorted + 1]) && ((storeArray[sorted] + 1) != storeArray[sorted + 1])){
          missingValue = (storeArray[sorted] + 1);
          errorValue = storeArray[sorted + 1];
          break;
        }
      }

      // check if a value is missing
      if (missingValue > -1) {
        tempValue ="<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Enterorder</emxUtil:i18nScript>";
        tempValue += missingValue + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderSmall</emxUtil:i18nScript> ";
        tempValue += errorValue + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Encounter</emxUtil:i18nScript> ";
        tempValue += missingValue + "  <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Missing</emxUtil:i18nScript>";
	alert(tempValue);

        // set focus to errorValue
        for (ct = 0; ct < count; ct++){
        // compare to last value before above loop broke
        if(selArray[ct].type == "select-one")
         {
          if ( parseInt(selArray[ct].options[selArray[ct].selectedIndex].value) == errorValue){
            selArray[ct].focus();
            break;
           }
         }
        }
        return;
      }
    }

    // step 2 :  Checking for Empty Dates - Bypassed for(Assignee-set duedate feature)
    //           Check for valid delta offset range, if option selected.
<%

   if(advanceDateOption.equals("true")){
%>
    if (count == 1) {
      if(document.routeActionsForm.duedateOption0[1].checked && document.routeActionsForm.duedateOption0[1].value =="delta"){
          var duedateOffsetJS = trim(document.routeActionsForm.duedateOffset.value);
          var isInvalidRange = CheckValidity(duedateOffsetJS);

          if( duedateOffsetJS.length == 0 || duedateOffsetJS <1 || duedateOffsetJS > 365 || isInvalidRange){
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.EnterOffset </emxUtil:i18nScript>");
            document.routeActionsForm.duedateOffset.value = "";
            document.routeActionsForm.duedateOffset.focus();
            return;
          }
       }
    } else {
      for (var k=0; k < count; k++){
        if((eval("document.routeActionsForm.duedateOption"+k+"[1].checked") && eval("document.routeActionsForm.duedateOption"+k+"[1].value") =="delta")){
           var duedateOffsetJS = trim(document.routeActionsForm.duedateOffset[k].value);
           var isInvalidRange = CheckValidity(duedateOffsetJS);
           if( duedateOffsetJS.length == 0 || duedateOffsetJS <1 || duedateOffsetJS > 365 || isInvalidRange){
             alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.EnterOffset</emxUtil:i18nScript>");
             document.routeActionsForm.duedateOffset[k].value="";
             document.routeActionsForm.duedateOffset[k].focus();
             return;
            }
         }
      }
    }


    // step 3 : Check if dates are in order
    if (count > 1){
      var orderdate = dateOrderCompare();
      if (!orderdate){
        return;
      }
    }
  <%
  }
  %>




    // step 5 :  Submit form.
    startProgressBar(true);
   if (jsDblClick()) {
    document.routeActionsForm.submit();
   }
  }




</script>


<%
try{
%>
    <%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
  }catch(Exception e) {

    String error = ComponentsUtil.i18nStringNow("emxComponents.AssignTaskDialog.ErrorMessage",languageStr);
%>
    <table width="90%" border="0"  cellspacing="0" cellpadding="3"  class="formBG" align="center" >
      <tr >
        <td class="errorHeader"><%=XSSUtil.encodeForHTML(context, error)%></td>
      </tr>
    </table>
<%
  }
%>


<body class="editable">
<form method="post" name="routeActionsForm" action="LSRouteWizardAssignTaskProcess.jsp" target="_parent" onSubmit="javascript:submitForm(); return false" >

<input type="hidden" name="routeId"         value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="objectId"        value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="templateId"      value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="scopeId"      value="<xss:encodeForHTMLAttribute><%=scopeId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="templateName" value="<xss:encodeForHTMLAttribute><%=templateName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="chkRouteAction" value="<xss:encodeForHTMLAttribute><%=chkRouteAction%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="sortName" value="<xss:encodeForHTMLAttribute><%= sortName %></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="slctdd" value="<xss:encodeForHTMLAttribute><%=slctdd%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="slctmm" value="<xss:encodeForHTMLAttribute><%=slctmm%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="slctyy" value="<xss:encodeForHTMLAttribute><%=slctyy%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="projectId"    value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>" />
<table class="list" id="taskList">
	<tbody>
		<tr>
			<th width="5%" style="text-align:center">
				<input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" />
			</th>
			<th nowrap width="20%" class="required">
				<emxUtil:i18n localize="i18nId">emxComponents.AssignTasksDialog.TitleActionOrder</emxUtil:i18n>
			</th>
			<th nowrap width="35%" class="required">
				<emxUtil:i18n localize="i18nId">emxComponents.AssignTasksDialog.AssigneeInstructions</emxUtil:i18n>
			</th>
			<th nowrap width="42%" class="required">
				<emxUtil:i18n localize="i18nId">emxComponents.AssignTasksDialog.DueDateTimeEDT</emxUtil:i18n>
			</th>
		</tr>
<!-- Begin Task -->
		<framework:ifExpr expr="<%=maplst.isEmpty()%>">
			<tr>
				<td align="center" colspan="13" class="error">
					<emxUtil:i18n localize="i18nId">emxComponents.RouteTaskSummary.NoTasktoEdit</emxUtil:i18n>
				</td>
	   		</tr>
		</framework:ifExpr>
		<framework:ifExpr expr="<%=!maplst.isEmpty()%>">
<%
			
			AttributeType attrRouteAction = new AttributeType(DomainConstants.ATTRIBUTE_ROUTE_ACTION);
						
			attrRouteAction.open(context);
			
			//Remove the Info Only and Investigate ranges which we no longer support-Bug 347955
		    StringList routeActionList = attrRouteAction.getChoices(context);
		    routeActionList.remove ("Information Only");
		    routeActionList.remove ("Investigate");
		    // Added for bug 359347
		    Collections.sort ((java.util.List)routeActionList); // To maintain order Approve, Comment, Notify Only
		    attrRouteAction.close(context);
		    if("Approval".equals(routeBasePurpose)) {
		    	routeActionList = new StringList(1);
	            routeActionList.add("Approve");
		    } else if("Review".equals(routeBasePurpose)) {
        		routeActionList = new StringList(1);
		        routeActionList.add("Comment");
		    }			    
		   Iterator mapItr = maplst.iterator();
			while(mapItr.hasNext()) {
			    Map  map            = (Map)mapItr.next();
				 String templateRouteNodeId	      = (String)map.get(DomainRelationship.SELECT_RELATIONSHIP_ID);
			    String sPersonId    = (String)map.get("PersonId");
			    String userName     = (String)map.get(DomainConstants.SELECT_NAME);
    			String sPersonName  = (String)map.get("PersonName");
				String routeSequenceValueStr                 = (String)map.get(PersonObject.ATTRIBUTE_ROUTE_SEQUENCE);
			    String routeAllowDelegationStr               = (String)map.get(PersonObject.ATTRIBUTE_ALLOW_DELEGATION);
			    String strAssigneeDueDateOpt                 = (String)map.get(DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE);
			    String routeActionValueStr                   = (String)map.get(PersonObject.ATTRIBUTE_ROUTE_ACTION);
			    String routeInstructionsValueStr             = (String)map.get(PersonObject.ATTRIBUTE_ROUTE_INSTRUCTIONS);
			    String taskNameValueStr                      = (String)map.get(PersonObject.ATTRIBUTE_TITLE);
			    String routeScheduledCompletionDateValueStr  = (String)map.get(PersonObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE);
    			String strNeedsReview                        = (String)map.get(DomainObject.ATTRIBUTE_REVIEW_TASK);
			    String strDueDateOffset                      = (String)map.get(DomainObject.ATTRIBUTE_DUEDATE_OFFSET);
			    String strDueDateOffsetFrom                  = (String)map.get(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM);
				//begin --------------------------------------------add by  tangfan 2015.4.21
				String sCondition ="";
				String sChecker ="";
				String sBranch ="";
				

					  sCondition = DomainRelationship.getAttributeValue(context,templateRouteNodeId,"HS Condition");
					   sChecker = DomainRelationship.getAttributeValue(context,templateRouteNodeId,"TMT Route Task Finish Checker");
					 sBranch = DomainRelationship.getAttributeValue(context,templateRouteNodeId,"Route Branch");

					

					boolean bCondition = true;
					if(sCondition != null && !sCondition.equals(""))
					{
						bCondition = false ;
						for(int i = 0 ; i < sContentIds.length ; i++)
						{
						String sMql = "print bus " + sContentIds[i] + " select evaluate[" + sCondition + "] dump" ;
					
						//String sTempMqlReturn = MqlUtil.mqlCommand(context,sMql);
						String sTempMqlReturn="";
						bCondition = bCondition || "true".equalsIgnoreCase(sTempMqlReturn) ;
						if(bCondition)
							break;
						}
					}
				if(bCondition == false) 
					continue ;

			//end ---------------------------------------------------add by tangfan 2015.4.21
				
				
			    String sTemplateTask                    = (String)map.get("templateFlag");
			    int routeNodeIds                            = 0;
			    try{
			       routeNodeIds                     = Integer.parseInt((String)map.get(PersonObject.RELATIONSHIP_ROUTE_NODE));
				}catch(Exception sTask){}
   				
				routeAllowDelegationStr = (routeAllowDelegationStr == null) ? "" : routeAllowDelegationStr;
				strNeedsReview = (strNeedsReview == null) ? "" : strNeedsReview;
				
			    boolean bAssigneeDueDate = "Yes".equalsIgnoreCase(strAssigneeDueDateOpt);
			    boolean bDueDateEmpty    = UIUtil.isNullOrEmpty(routeScheduledCompletionDateValueStr);
			    boolean bDeltaDueDate    = !UIUtil.isNullOrEmpty(strDueDateOffset)&& bDueDateEmpty;
			    boolean bShowSystemDate  = ("AccessMembersProcess".equals(fromPageStr) && !"yes".equalsIgnoreCase(toAccessPage) && !bAssigneeDueDate && !bDeltaDueDate);
			    boolean bOwnerNotSetDate = (bDueDateEmpty && !bAssigneeDueDate && !bDeltaDueDate && !bShowSystemDate);
			    double clientTZOffset     = (new Double((String)session.getValue("timeZone"))).doubleValue();
			    
			    int hhrs = 9;
			    int mmin = 0;
			    
			    String slctdate  = "";
			    String AM_PM = "";
			    long routeScheduledCompletionDateValueMilli = 0;
			    if (!bDueDateEmpty){
				    tempdate                = eMatrixDateFormat.getJavaDate(routeScheduledCompletionDateValueStr);
				    slctdate                = eMatrixDateFormat.getFormattedDisplayDate(routeScheduledCompletionDateValueStr,clientTZOffset,request.getLocale());
				    routeScheduledCompletionDateValueMilli = tempdate.getTime();
				    Hashtable hashDateTime = eMatrixDateFormat.getFormattedDisplayInputDateTime(routeScheduledCompletionDateValueStr,clientTZOffset);
				    hhrs = (new Integer((String)hashDateTime.get("hours"))).intValue();
				    mmin = (new Integer((String)hashDateTime.get("minutes"))).intValue();
				    AM_PM = (hhrs >= 12) ? "PM" : "AM";
				   	temp_hhrs_mmin = hhrs +":"+(mmin<10?"0"+mmin:mmin) +" "+ AM_PM; 
			  }
			    
 		      boolean isTemplateTask = "Yes".equals(sTemplateTask);
			  boolean canEditTAsk = isTemplateTask && !"Modify/Delete Task List".equals(sTaskEditSetting);
		      boolean canModDelTemplateTask = "Modify/Delete Task List".equals(sTaskEditSetting);
		      boolean canModTask = "Modify Task List".equals(sTaskEditSetting);
		      boolean showAdvanceDateOption = "true".equals(advanceDateOption);
		      String defaultTime = temp_hhrs_mmin.substring(0, (temp_hhrs_mmin.indexOf(':')+3))+":00 "+(temp_hhrs_mmin.indexOf("AM")>0?"AM":"PM"); 
		      String checkNeedsReview = strNeedsReview.equals("Yes") ? "checked" : "";
		      String checkAllowDelegation = routeAllowDelegationStr.equals("TRUE") ? "checked" : "";
		      String checkchkItem = canEditTAsk ? "disabled" : "";
		          
%>
			<tr class='<framework:swap id="1"/>'>
			  	<input type="hidden" name="routeNodeId" value="<xss:encodeForHTMLAttribute><%=routeNodeIds%></xss:encodeForHTMLAttribute>"/>
			  	<input type="hidden" name="oldAssignee" value="<%=XSSUtil.encodeForHTMLAttribute(context, sPersonId)%>~<%=XSSUtil.encodeForHTMLAttribute(context, sPersonName)%>"/>
			  	<input type="hidden" name="templateTask" value="<xss:encodeForHTMLAttribute><%=sTemplateTask%></xss:encodeForHTMLAttribute>"/>
			  	<input type="hidden" name="AllowDelegation" value="<xss:encodeForHTMLAttribute><%=routeAllowDelegationStr%></xss:encodeForHTMLAttribute>"/>
			  	<input type="hidden" name="NeedsReview" value="<xss:encodeForHTMLAttribute><%=strNeedsReview%></xss:encodeForHTMLAttribute>"/>
				<input type="hidden" name="sChecker" value="<xss:encodeForHTMLAttribute><%=sChecker%></xss:encodeForHTMLAttribute>"/>
				<input type="hidden" name="sBranch" value="<xss:encodeForHTMLAttribute><%=sBranch%></xss:encodeForHTMLAttribute>"/>
						
				<td style="text-align: center;vertical-align:top;">
					<table>
						<tr>
							<td>
								<input type = "checkbox" name = "chkItem1" id = "chkItem1" <%=checkchkItem%> value = "<%=Count++%>"  onClick="updateCheck()" />
							</td>
						</tr>
					</table>
				</td>
				<!-- Name, Action & Number Column -->
				<td style="vertical-align:top">
					<table>
					 	<tr><!-- Title Field -->
						 	<td>
						 		<table>
						 			<tr>
						 				<td>
										 	<framework:ifExpr expr="<%=isTemplateTask && canModDelTemplateTask%>">
										 		<input type="text" name="taskName" size="20"  value="<xss:encodeForHTMLAttribute><%=taskNameValueStr%></xss:encodeForHTMLAttribute>" />
									 		</framework:ifExpr>
										 	<framework:ifExpr expr="<%=isTemplateTask && !canModDelTemplateTask%>">
												<%=XSSUtil.encodeForHTML(context, taskNameValueStr)%>(t)
												<input type="hidden" name="taskName" value="<xss:encodeForHTMLAttribute><%=taskNameValueStr%></xss:encodeForHTMLAttribute>" />
										 	</framework:ifExpr>
									 		<framework:ifExpr expr="<%=!isTemplateTask%>">
									 			<input type="text" name="taskName" size="20"  value="<xss:encodeForHTMLAttribute><%=taskNameValueStr%></xss:encodeForHTMLAttribute>" />
									 		</framework:ifExpr>
						 				</td>
						 			</tr>
					 			</table>
							 </td>
						</tr>
						<tr> <!-- Action -->
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

												<select name="routeAction" >
												
	<%
	                                  if(sTaskEditSetting.equals("None")){
	
													StringItr  routeActionItr  = new StringItr (routeActionList);
													while(routeActionItr.next()) {
													    String rangeValue = routeActionItr.obj();
														if(rangeValue.equals(routeActionValueStr)){
													    String i18nRouteAction=i18nNow.getRangeI18NString(PersonObject.ATTRIBUTE_ROUTE_ACTION, rangeValue, sLanguage);
													    String selected = (routeActionValueStr != null) && routeActionValueStr.equals(rangeValue) ? "selected" : "";
	%>
														<option value="<%=XSSUtil.encodeForHTMLAttribute(context, rangeValue)%>" <%=selected %>> <%=XSSUtil.encodeForHTML(context, i18nRouteAction)%> </option>
	<% 										    
														}
	
													}
	}else{
												StringItr  routeActionItr  = new StringItr (routeActionList);
													while(routeActionItr.next()) {
													    String rangeValue = routeActionItr.obj();
													    String i18nRouteAction=i18nNow.getRangeI18NString(PersonObject.ATTRIBUTE_ROUTE_ACTION, rangeValue, sLanguage);
													    String selected = (routeActionValueStr != null) && routeActionValueStr.equals(rangeValue) ? "selected" : "";
	%>
														<option value="<%=XSSUtil.encodeForHTMLAttribute(context, rangeValue)%>" <%=selected %>> <%=XSSUtil.encodeForHTML(context, i18nRouteAction)%> </option>
	<% 										    
													}
		
		
	}
													
	%>									
												</select>	


											
											</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
						<tr> <!-- Order Field -->
							<td>
								<table>
									<tbody>
										<tr>
							 				<td style="font-weight: bold;padding-top:10px;padding-bottom: 2px;">
											 	<emxUtil:i18n localize = "i18nId">emxComponents.common.Order</emxUtil:i18n>&nbsp;
											</td>
										</tr>
										<tr>
											<td>
												<framework:ifExpr expr="<%=!isTemplateTask || (canModDelTemplateTask || canModTask)%>">
													<select name = "routeOrder" >
<%
											              for (int loop = 1; loop <= 20; loop++) {
											                Integer integerType     = new Integer(loop);
											                String loopString       = integerType.toString();
											                String selected = loopString.equals(routeSequenceValueStr) ? "selected" : "";
%>									           
																 <option value="<%=loop%>" <%=selected%>><%=loop%></option>
<%
											              }
%>
													</select>
												</framework:ifExpr>
												<framework:ifExpr expr="<%=isTemplateTask && !(canModDelTemplateTask || canModTask)%>">
													<%=XSSUtil.encodeForHTML(context, routeSequenceValueStr)%>
													<input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeSequenceValueStr%></xss:encodeForHTMLAttribute>" />
													</framework:ifExpr>
											</td>											
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
					</table>
				</td>
				<td style="vertical-align:top;"> <!-- Assignee & Instructions -->
					<table>
		            	<tr> <!-- Assignee -->
		            		<td>
		            			<table>
		            				<tr>
		            					<td>
										
						     <%
							 
						
								 		 String hsOrgId ="";
							hsOrgId = DomainRelationship.getAttributeValue(context,templateRouteNodeId,"HS Org Id");
				
	if (hsOrgId!=null && !"".equals(hsOrgId) && !"All".equals(hsOrgId) && !"OOTB".equals(hsOrgId)) {

		matrix.util.StringList sList = com.matrixone.apps.domain.util.FrameworkUtil.split(hsOrgId,"|");	
		String type = (String)sList.get(0);
		String name = (String)sList.get(1);
		String revision = (String)sList.get(2);

		hsOrgId = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context,"print bus '" + type + "' '" + name + "' '" + revision + "' select id dump");
      		out.println((DomainObject.newInstance(context,hsOrgId)).getInfo(context,DomainObject.SELECT_NAME));
	}

						


	matrix.util.StringList roleList = new matrix.util.StringList();
      %>
				
										
										
               <select name="personId" >
                 <option value="none~none"><emxUtil:i18n localize="i18nId">emxComponents.RouteTemplateTaskAssignees.None</emxUtil:i18n></option>
				 

                 <%
                      Iterator personMapItr = routeMemberMapList.iterator();
                      StringList checkRoleList = new StringList();
				
                      while(personMapItr.hasNext()) {
                      Map tempMap = (Map)personMapItr.next();
                      String strPersonId = (String)tempMap.get(PersonObject.SELECT_ID);
                      String strUserName = (String)tempMap.get("name");
                      String strPersonName = (String)tempMap.get("LastFirstName");
                      if(strPersonId == null || "".equals(strPersonId))
                       {
                         strPersonId = "Role";
                       }

                       if(strPersonId.equals("Role"))
                       {
                     
                       strPersonName = i18nNow.getAdminI18NString("Role",strPersonName,sLanguage) + "(" + strRole + ")";
                       }

                       if(strPersonId.equals("Group"))
                       {
                        // modified for the bug no 339357
                         strPersonName = i18nNow.getAdminI18NString("Group",strPersonName,sLanguage) + "(" + strGroup + ")";
			 }
                      if(strPersonId.equals("Role") && 
                          strUserName.equals(sPersonName))			  
			 { 
			 roleList.add("Role~" + sPersonName);


			 if (hsOrgId!=null && "OOTB".equals(hsOrgId)){

			 		%>
					<option value="<%=strPersonId%>~<%=sPersonName%>" selected> <%=i18nNow.getAdminI18NString("Role",strPersonName,sLanguage)%></option>
					<%
				
			 } else if ("All".equals(hsOrgId) ){


				String rolePersons = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context,"print role \"" + sPersonName + "\" select person dump |");
				StringList personList1 = com.matrixone.apps.domain.util.FrameworkUtil.split(rolePersons, "|");
				personList1.sort();

				for(int k=0;k<personList1.size();k++) {
				
					String personUserName = (String)personList1.get(k);
					String personId = (String)personMap.get(personUserName); 
					if (personId==null)
						continue;

					String personFullName =  (String)personMap.get(personUserName + "FullName"); 

					%>
					<option value="<%=personId%>~<%=personUserName%>" <% if (personList1.size()==1) out.println("selected");%>> <%=personUserName %>(<%=personFullName%>) <%=i18nNow.getAdminI18NString("Role",strPersonName,sLanguage)%></option>
					<%

				}
				break;
			 	
			 }

			 }
                      else if((strPersonId.equals("Group") && 
                          strUserName.equals(sPersonName)) || 
                         (userName != null && userName.equals(strUserName)))
                      {
					   
		      roleList.add(strPersonId + "~" + sPersonName);

              %>
                          <option value="<%=strPersonId%>~<%=strUserName%>"Selected> <%=strPersonName%> </option>
              <%	
                      }
                      else
                      { 
              %>
                         
              <%	
                      }
                    }
              %>
      </select>	            


	  
		            					</td>
		            				</tr>
		            			</table>
		            		</td>
		            	</tr>
		            	<tr> <!-- Instructions -->
		            		<td style="padding-top:3px;">
		            			<table>
		            				<tr>
					            		<td>
					            			<textarea style="min-height:50px;width:250px;" rows="6" name="routeInstructions"><xss:encodeForHTML><%=routeInstructionsValueStr%></xss:encodeForHTML></textarea>
					            		</td>
		            				</tr>
		            			</table>
		            		</td>
		            	</tr>
		            </table>
				</td>
				<td style="vertical-align:top;padding-top:10px;"> <!-- Due Date & Time (EDT)  -->
					<table>
						<tr> <!-- Date and Time selection -->
							<td>
								<table>
									<tr>
										<td>
											<framework:ifExpr expr="<%=showAdvanceDateOption%>">
								                <input type="hidden" name="routeScheduledCompletionDate<%=xx%>_msvalue" value="<xss:encodeForHTMLAttribute><%=((!bAssigneeDueDate && !bOwnerNotSetDate && !bDeltaDueDate) || bShowSystemDate)?routeScheduledCompletionDateValueMilli:(long)0%></xss:encodeForHTMLAttribute>" />
								                <input type = "radio" onclick="javascript:toggleDefaultDate('<%=xx%>')" id = "duedateOption<%=xx%>" name = "duedateOption<%=xx%>" value = "calendar" <%= (!bAssigneeDueDate && !bDeltaDueDate)?"checked":""%> />&nbsp;
								                <input onfocus="redirectFocus('<%=xx%>')" type="text" size="12" name="routeScheduledCompletionDate<%=xx%>" value="<xss:encodeForHTMLAttribute><%=((!bAssigneeDueDate && !bOwnerNotSetDate && !bDeltaDueDate) || bShowSystemDate)?slctdate:""%></xss:encodeForHTMLAttribute>" />
								                <a href="javascript:showCal('routeActionsForm','routeScheduledCompletionDate<%=xx%>','Task','<%=xx%>')" ><img src="../common/images/iconSmallCalendar.gif" border="0" valign="absmiddle" name="img5" /></a>
											</framework:ifExpr>
											<framework:ifExpr expr="<%=!showAdvanceDateOption%>">
								                <input type="hidden" name="routeScheduledCompletionDate<%=xx%>_msvalue" value="<%=((!bAssigneeDueDate && !bOwnerNotSetDate && !bDeltaDueDate) || bShowSystemDate)?routeScheduledCompletionDateValueMilli:(long)0%>" />
								                <input type = "radio" onclick="javascript:toggleDefaultDate('<%=xx%>')" id = "duedateOption<%=xx%>" name = "duedateOption<%=xx%>" value = "calendar" <%="checked"%> />&nbsp;
								                <input onFocus="redirectFocus('<%=xx%>')" readonly type="text"  size="11" name="routeScheduledCompletionDate<%=xx%>" value="<%=((!bAssigneeDueDate && !bOwnerNotSetDate && !bDeltaDueDate) || bShowSystemDate)?slctdate:""%>" />
								                <a href="javascript:showCalendar('routeActionsForm','routeScheduledCompletionDate<%=xx++%>','<%=slctdate%>')" ><img src="../common/images/iconSmallCalendar.gif" border="0" valign="absmiddle" name="img5" /></a>
											</framework:ifExpr>
											<select name="routeTime" >
			<%
			int hour = 5;
			boolean is24= false;
			String amPm = "AM";
			// 24 Hours format for _de and _ja more can be added
			if(sLanguage.startsWith("de") || sLanguage.startsWith("ja"))
			{
				is24 = true;
				//amPm="";
			}
			if(!is24 && hhrs>12){
				defaultTime = defaultTime.replace(defaultTime.substring(0,2),(hhrs-12)+"");
			}
			boolean minFlag = true;
			boolean amFlag = true;
			// 48 loops one for 00 mins and one for 30 mins. 24 hours * 2  times
			
												for (int i=0;i<48;i++) {	
													String ttime = "";
													String timeValue = "";
		
													// After 12 PM , clock turns to 1 , for 24Hour format it becomes 13, below.													
													if(hour>12 && !is24)
													{
														hour =1 ;
													}
													if(minFlag) // Alternating between 00 min and 30 min. Initially flag=true once we display 00 then flag=false, display 30 mins , alternate
													{
														if(is24){
															ttime = hour + ":00 ";
															}else{
														ttime = hour + ":00 " + amPm;
															}
														
														timeValue = hour  + ":00" + ":00 " + amPm;
														minFlag = false;
													}else
													{
														if(is24){
															ttime = hour + ":30 "; 
															}else{
														ttime = hour + ":30 " + amPm; 
															}														
														timeValue = hour  + ":30" + ":00 " + amPm;
														hour++;
														minFlag = true;
														if(hour==12)// Once we reach 12, change amPm from AM to PM
										            	{
										            		amPm = "PM";
										            	}
													}
								                 
									               
								                 String Slct = timeValue.equals(defaultTime) ? "selected" : "";
								                 if(!is24 && hhrs == 0 && (hour == 12 || hour == 13 )){
								                	String timeValue1 = timeValue.replace("12:","0:") ;				                 
								                	 Slct = timeValue1.equals(defaultTime) ? "selected" : "";
								                 }
		%>
								                <Option value="<%=timeValue%>" <%=Slct%>> <%=ttime%> </Option>
		 <%
												if(hour>12 && is24 && amFlag){//If 24 hour format, change to 13 after 12PM not to 1PM 
													hour=13;
													amFlag = false;
								                  }
								            	if(hour>23 && is24){ //If 24 hour , after 23:30 change to 00 hours (12AM)
													hour=00;
												}
								            	
								            	if(timeValue.equalsIgnoreCase("11:30:00 PM") || timeValue.equalsIgnoreCase("23:30:00 PM"))
								            	{
								            		amPm = "AM";
								            	}
								            	
											}
		%>
										</select>
										&nbsp;
										<a href="javascript:cleardate('<%=xx%>')"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
												
									</td>
								</tr>
								</table>
							</td>
						</tr>
						<framework:ifExpr expr="<%=showAdvanceDateOption%>">
							<tr>
								<td>
									<table>
										<tr>
											<td style="font-weight: bold;padding-top:10px;padding-bottom:2px;">
												<emxUtil:i18n localize = "i18nId">emxComponents.common.Advanced</emxUtil:i18n>&nbsp;
											</td>
										</tr>
										<tr>
											<td >
												&nbsp;
											</td>
										</tr>
										<tr>
											<td>
												<input type = "radio" onclick="javascript:toggleDefaultDate('<%=xx%>')" id = "duedateOption<%=xx%>" name = "duedateOption<%=xx%>" value ="delta" <%=bDeltaDueDate?"checked":""%> />
												&nbsp;
												<input type="text" onfocus="isDeltaRadio('<%=xx%>')" name="duedateOffset" size="3" value="<xss:encodeForHTMLAttribute><%=bDeltaDueDate?strDueDateOffset:""%></xss:encodeForHTMLAttribute>" />
												&nbsp;<emxUtil:i18n localize = "i18nId">emxComponents.common.DaysFrom</emxUtil:i18n>&nbsp;
												<select name="duedateOffsetFrom"  onFocus="isDeltaRadio('<%=xx%>')">
			<%
													StringItr  offsetItr    = new StringItr (FrameworkUtil.getRanges(context, DomainObject.ATTRIBUTE_DATE_OFFSET_FROM));
													while(offsetItr.next()) {
														String rangeValue        = offsetItr.obj();
													    String i18nOffsetFrom    = i18nNow.getRangeI18NString(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM, rangeValue, sLanguage);
														String selected  = (strDueDateOffsetFrom != null && strDueDateOffsetFrom.equals(rangeValue)) ? "selected": "";										    
			%>									
														<option value="<%=XSSUtil.encodeForHTMLAttribute(context, rangeValue)%>" <%=selected%>> <%=XSSUtil.encodeForHTML(context, i18nOffsetFrom)%> </option>
			<%
													}
			%>											
												</select>
											</td>
										</tr>									
									</table>
								</td>
							</tr>						
						</framework:ifExpr>
						<tr>
							<td>
    							&nbsp;
    						</td>
    					</tr>
						<tr>
							<td>
								<input type = "radio" onclick="javascript:toggleDefaultDate('<%=xx%>')" id = "duedateOption<%=xx%>" name = "duedateOption<%=xx++%>" value = "assignee" <%=bAssigneeDueDate ? "checked" : "" %> />
								&nbsp;<emxUtil:i18n localize = "i18nId">emxComponents.AssignTasksDialog.AssigneeDueDate</emxUtil:i18n>
							</td>
						</tr>
						<tr>
    						<td>
    							&nbsp;
    						</td>
    					</tr>
						<tr>
							<td>
								<input type="checkbox" name="AllowDelegationchkItem" id="AllowDelegationchkItem" <%=checkAllowDelegation%> value="<%=AllowDelegationCount++%>" />
								<emxUtil:i18n localize = "i18nId">emxComponents.AssignTasksDialog.AllowDelegation</emxUtil:i18n>
								&nbsp;

								<input type="checkbox" name="NeedsReviewchkItem" id="NeedsReviewchkItem" <%=checkNeedsReview%> value="<%=NeedsReviewCount++%>" />
								  <input type="hidden" name="templateRouteNodeId" value="<%=templateRouteNodeId%>">
  		                         <input type="hidden" name="baseState" value="<%=emxGetParameter(request,"baseState")%>">
								<emxUtil:i18n localize = "i18nId">emxComponents.AssignTasksDialog.RequiresOwnerReview</emxUtil:i18n>
							</td>
						</tr>
					</table>
				</td>				
			</tr>
<%

	//}//else

 }//while

%>		
		</framework:ifExpr>		
</tbody>
</table>

</form>
</body>
<%!
// Method to return Parent Task Due Date will return null if no parent task
public static String getParentTaskDueDate(Context context,String objectId){
  String parentTaskDueDate=null;
  try{
    if(objectId!=null){
      DomainObject doObject=DomainObject.newInstance(context,objectId);
      if(DomainObject.TYPE_INBOX_TASK.equals(doObject.getType(context))){
        parentTaskDueDate=doObject.getInfo(context,"attribute["+DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE+"]");
      }
    }
  }catch(Exception ex){
  }
  return parentTaskDueDate;
}

%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

