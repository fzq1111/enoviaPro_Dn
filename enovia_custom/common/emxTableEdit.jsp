<%-- emxTableEdit.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableEdit.jsp.rca 1.40 Tue Oct 28 18:55:03 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<html>
<head>

<%@include file = "emxFormConstantsInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "emxFormUtil.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<script language="JavaScript" type="text/javascript" src="scripts/emxUITableUtil.js"></script>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%-- Added:For Enhanced Calendar Control:AEF:nr2:20-11-09 --%>
<%@page import="java.util.Iterator"%>
<%@page import="com.matrixone.json.JSONObject"%>
<%@page import="java.util.Map,java.util.HashMap,com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.Map,java.util.Set,java.util.Map,java.util.HashSet,com.matrixone.json.JSONObject"%>
<%-- End:For Enhanced Calendar Control:AEF:nr2:20-11-09 --%>

<%!

private StringList getSortedList(StringList sortList, String sortDirection,String sortType)
    {
        if(sortList==null) {

            return new StringList();
        }

        if(sortDirection == null || "".equals(sortDirection))
        {
            sortDirection = "ascending";
        }

        if(sortType == null || "".equals(sortType))
        {
            sortType = "string";
        }

        Map sortMap = null;
        Map sortedMap = null;
        StringList sortedList=new StringList(sortList.size());
        MapList sortMapList = new MapList(sortList.size());

        Iterator itr = sortList.iterator();
        while(itr.hasNext())
        {
            sortMap = new HashMap();
            sortMap.put("option",itr.next());
            sortMapList.add(sortMap);
        }

        sortMapList.sort("option",sortDirection,sortType);

        Iterator sortedListItr = sortMapList.iterator();
         while(sortedListItr.hasNext())
        {
             sortedMap =(HashMap)sortedListItr.next();
             sortedList.add(sortedMap.get("option"));
        }

    return sortedList;

    }
    %>



<%
//AddedFor Enhanced Calendar Control:AEF:nr2:20-11-09
Map requestMapforCal = new HashMap();
JSONObject retValObj = new JSONObject();
//Here we will get the form field and the parameters calander program and function
//and put them in requestMap


//End:For Enhanced Calendar Control:AEF:nr2:20-11-09

  StringBuffer mxLinkHTML = new StringBuffer(100);
  StringBuffer sfb = new StringBuffer();
    int paramind = 1;
    Enumeration enumParamNames = emxGetParameterNames(request);
    while(enumParamNames.hasMoreElements()) {
        String paramName = (String) enumParamNames.nextElement();
        String paramValue =emxGetParameter(request, paramName);

       if(paramValue != null && !"null".equals(paramValue) && !"".equals(paramValue) ) {
                if(paramind > 1)
                        sfb.append("&");
                sfb.append(paramName);
                sfb.append("=");
                sfb.append(paramValue);
                paramind++;
        }
    }
 String findMxLink = emxGetParameter(request, "findMxLink");
  boolean invokeEditDirectly = false;
  String timeStamp = emxGetParameter(request, "timeStamp");
  
  HashMap tableData = new HashMap();
  HashMap requestMap = new HashMap();
  
  if(timeStamp == null || "".equalsIgnoreCase(timeStamp))
  {
    invokeEditDirectly = true;
    timeStamp = tableBean.getTimeStamp();
    try {
      ContextUtil.startTransaction(context, true);
      sfb.append("&timeStamp=");
      sfb.append(timeStamp);
      sfb.append("&invokeEditDirectly=true");

      // Process the request object to obtain the table data and set it in Table bean
      tableBean.setTableData(context, pageContext,request, timeStamp, PersonUtil.getAssignments(context));

      // Sort the table data
      String sortColumnName = emxGetParameter(request, "sortColumnName");
      if (sortColumnName != null && sortColumnName.trim().length() > 0 && (!(sortColumnName.equals("null"))) )
      {
    	  tableData = tableBean.getTableData(timeStamp);
    	  requestMap = tableBean.getRequestMap(tableData);
    	  requestMap.put(UIComponent.UI_TYPE, UIComponent.FLAT_TABLE);
    	  requestMap.put(UIComponent.FLAT_TABLE_EDIT_MODE, UIComponent.TRUE);
          tableBean.sortObjects(context, timeStamp);
      }
    } catch (Exception ex) {
      ContextUtil.abortTransaction(context);
      if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());
    } finally {
      ContextUtil.commitTransaction(context);
    }
  }

  tableData = tableData.size() == 0 ? tableBean.getTableData(timeStamp) : tableData;  
  HashMap tableControlMap = tableBean.getControlMap(tableData);
  requestMap = requestMap.size() == 0 ? tableBean.getRequestMap(tableData) : requestMap;
  
  String objectId = (String)requestMap.get("objectId");
  String relId = (String)requestMap.get("relId");
  String suiteKey = (String)requestMap.get("suiteKey");
  String showApply = (String)requestMap.get("showApply");	

    String tableRowIdList[] = emxGetParameterValues(request, "emxTableRowId");
    MapList relBusObjList = tableBean.getFilteredObjectList(tableData);
    MapList relBusObjPageList = tableBean.getEditObjectList(context, timeStamp);

    if(relBusObjPageList == null) {
    relBusObjPageList = new MapList();
    if (relBusObjList != null && relBusObjList.size() > 0)
    {
      if (tableBean.isMultiPageMode(tableControlMap) && !invokeEditDirectly)
      {
        int currentIndex = tableBean.getCurrentIndex(tableControlMap);
        int lastPageIndex = tableBean.getPageEndIndex(tableControlMap);

        for (int i = currentIndex; i < lastPageIndex; i++)
        {
          if (i >= relBusObjList.size())
            break;
          relBusObjPageList.add(relBusObjList.get(i));
        }
      } else {
        relBusObjPageList = relBusObjList;
      }
      if(tableRowIdList == null || tableRowIdList.length <= 0) {
        tableBean.setEditObjectList(context, timeStamp, relBusObjPageList, null);
      } else {
        tableBean.setEditObjectList(context, timeStamp, relBusObjList, tableRowIdList);
      }
    }
  }

 //Added for pre-process hook-up
  String cancelProcessURL = (String)requestMap.get("cancelProcessURL");
  String cancelProcessJPO = (String)requestMap.get("cancelProcessJPO");

  String preProcessJPO = (String)requestMap.get("preProcessJPO");
  String preProcessURL = (String)requestMap.get("preProcessURL");

  if ((preProcessURL != null && !"".equals(preProcessURL)) || (preProcessJPO != null && !"".equals(preProcessJPO)))
  {
    request.setAttribute("context", context);
  %>
    <jsp:include page="emxTableEditPreProcess.jsp" flush="true">
    <jsp:param name = "timeStamp" value = "<%=XSSUtil.encodeForURL(context, timeStamp)%>" />
    </jsp:include>
  <%
  }

  String HelpMarker = emxGetParameter(request,"HelpMarker");
  if(HelpMarker == null)
  {
    HelpMarker = (String)requestMap.get("HelpMarker");
  }

    String inquiryList = (String)requestMap.get("inquiry");
  String inquiryLabel = (String)requestMap.get("inquiryLabel");
  String programList = (String)requestMap.get("program");
  String programLabel = (String)requestMap.get("programLabel");
  String selectedFilter = (String)requestMap.get("selectedFilter");

  String toolbar = (String)requestMap.get("editToolbar");
  if(toolbar == null || "".equals(toolbar))
  {
    toolbar = emxGetParameter(request, "editToolbar");
  }

    String suiteDir = "";
    String registeredSuite = suiteKey;

    if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
        registeredSuite = suiteKey.substring("eServiceSuite".length());

    if ( (registeredSuite != null) && (registeredSuite.trim().length() > 0 ) )
    {
         suiteDir = UINavigatorUtil.getRegisteredDirectory(context, registeredSuite);
    }

  String stringResFileId = UINavigatorUtil.getStringResourceFileId(context,registeredSuite);

  if(stringResFileId == null || stringResFileId.length()==0)
    stringResFileId="emxFrameworkStringResource";

    String strLanguage = Request.getLanguage(request);
	String helpApply = UINavigatorUtil.getI18nString("emxFramework.FormComponent.Apply", "emxFrameworkStringResource", strLanguage);
    String helpDone=UINavigatorUtil.getI18nString("emxFramework.FormComponent.Done", "emxFrameworkStringResource", strLanguage);
    String helpCancel=UINavigatorUtil.getI18nString("emxFramework.FormComponent.Cancel", "emxFrameworkStringResource", strLanguage);

    StringList filterStrList = new StringList();
    StringList filterLabelStrList = new StringList();

    // Get the list of enquiries and label
  if (inquiryList != null && inquiryList.trim().length() > 0 )
  {
      if (inquiryList.indexOf(",") > 0 )
          filterStrList = FrameworkUtil.split(inquiryList, ",");

      if (inquiryLabel != null && inquiryLabel.trim().length() > 0 )
      {
          if (inquiryLabel.indexOf(",") > 0 )
              filterLabelStrList = FrameworkUtil.split(inquiryLabel, ",");
      }
  } else if (programList != null && programList.trim().length() > 0 )
  {
      if (programList.indexOf(",") > 0 )
          filterStrList = FrameworkUtil.split(programList, ",");

      if (programLabel != null && programLabel.trim().length() > 0 )
      {
          if (programLabel.indexOf(",") > 0 )
              filterLabelStrList = FrameworkUtil.split(programLabel, ",");
      }
  }


    String showMassUpdate = (String)requestMap.get("massUpdate");
    if(showMassUpdate == null || "".equals(showMassUpdate.trim())) {
        showMassUpdate = emxGetParameter(request, "massUpdate");
    }

  if(showMassUpdate == null || "".equals(showMassUpdate.trim())) {
      try {
          showMassUpdate = EnoviaResourceBundle.getProperty(context, "emxFramework.ShowMassUpdate");
      } catch(Exception e) {
          showMassUpdate = "false";
      }
  }
  String allowKeyableDates = "false";
  try {
          allowKeyableDates = EnoviaResourceBundle.getProperty(context, "emxFramework.AllowKeyableDates");
  } catch(Exception e) {
      allowKeyableDates = "false";
  }


  StringList columnNames = new StringList();
  StringList columnNamesDisplay = new StringList();
  StringList columnElementHtML = new StringList();
  StringList columnElementType = new StringList();

  String header = tableBean.getPageHeader(tableControlMap);
  if (header == null || "".equals(header)) {
    header = emxGetParameter(request, "header");
    if ( (header != null) && (header.trim().length() > 0) ) {
      header = UINavigatorUtil.parseHeader(context, header, objectId, suiteKey, strLanguage);
    }
      else{
    	  header= "";
      }
    }
    String strtitle="";
    if((objectId == null) || (objectId.equalsIgnoreCase("null")) || (objectId.trim().length() == 0)){
    	if(tableRowIdList != null && tableRowIdList.length==1){
            strtitle=UIUtil.getWindowTitleName(context, null,tableRowIdList[0], UINavigatorUtil.getI18nString("emxFramework.WindowTitle.Edit", "emxFrameworkStringResource",context.getLocale().toString()));
       }
    	else{
    		 strtitle=UIUtil.getWindowTitleName(context, relId,objectId, UINavigatorUtil.getI18nString("emxFramework.WindowTitle.Edit", "emxFrameworkStringResource",context.getLocale().toString()));
    	}
    }
    else{
    	 strtitle=UIUtil.getWindowTitleName(context, relId,objectId, UINavigatorUtil.getI18nString("emxFramework.WindowTitle.Edit", "emxFrameworkStringResource",context.getLocale().toString()));
  }

  String subHeader = (String)requestMap.get("subHeader");
  if ( (subHeader != null) && (subHeader.trim().length() > 0) ) {
      subHeader = UINavigatorUtil.parseHeader(context, pageContext, subHeader, objectId, suiteKey, strLanguage);
  }

    if ( (HelpMarker == null) || (HelpMarker.equalsIgnoreCase("null")) || (HelpMarker.trim().length() == 0) )
        HelpMarker = "false";


  String helpString=UINavigatorUtil.getI18nString("emxFramework.FormComponent.Help", "emxFrameworkStringResource", strLanguage);
  String requiredMsg = UINavigatorUtil.getI18nString("emxFramework.TableEdit.ColumnsInRedAreRequired", "emxFrameworkStringResource", strLanguage);
  String strColumn = UINavigatorUtil.getI18nString("emxFramework.TableEdit.Column", "emxFrameworkStringResource", strLanguage);
  String strValue = UINavigatorUtil.getI18nString("emxFramework.TableEdit.Value", "emxFrameworkStringResource", strLanguage);
  String strApplytoall = UINavigatorUtil.getI18nString("emxFramework.TableEdit.Applytoall", "emxFrameworkStringResource", strLanguage);
  String strApplytoselected = UINavigatorUtil.getI18nString("emxFramework.TableEdit.Applytoselected", "emxFrameworkStringResource", strLanguage);
  String strSelectOne = UINavigatorUtil.getI18nString("emxFramework.Common.PleaseSelectitem", "emxFrameworkStringResource", strLanguage);
  String strSelectcolumn = UINavigatorUtil.getI18nString("emxFramework.TableEdit.PleaseSelectColumn", "emxFrameworkStringResource", strLanguage);
  String strAlertNewlyAddedorDeleted = UINavigatorUtil.getI18nString("emxFramework.TableEdit.AlertNewlyAddedorDeleted", "emxFrameworkStringResource", strLanguage);

String enableMxLink =  EnoviaResourceBundle.getProperty(context, "emxFramework.DynamicURLEnabled");
if (!"false".equals(findMxLink) && !"false".equals(enableMxLink)) {

  mxLinkHTML.append("<a href=\"javascript:showModalDialog('");
  mxLinkHTML.append("emxSearch.jsp?mxLink=true&toolbar=AEFGenericSearch");
  mxLinkHTML.append("', '");
  mxLinkHTML.append(XSSUtil.encodeForJavaScript(context, suiteDir));
  mxLinkHTML.append("', '");
  mxLinkHTML.append(XSSUtil.encodeForJavaScript(context, langStr));
  //mxLinkHTML.append("')\"><img src=\"images/iconActionMXLink.gif\" alt=\"");
  mxLinkHTML.append("\" border=\"0\" /></a>");
}

  StringBuffer helpHTML = new StringBuffer(100);
  helpHTML.append("<a href=\"javascript:openHelp('");
  helpHTML.append(XSSUtil.encodeForJavaScript(context, HelpMarker));
  helpHTML.append("', '");
  helpHTML.append(XSSUtil.encodeForJavaScript(context, suiteDir));
  helpHTML.append("', '");
  helpHTML.append(langStr);
  helpHTML.append("', '");
  helpHTML.append(XSSUtil.encodeForJavaScript(context, langOnlineStr));
  helpHTML.append("', '");
  helpHTML.append("', '");
  helpHTML.append(XSSUtil.encodeForJavaScript(context, suiteKey));
  helpHTML.append("')\"><img src=\"images/iconActionHelp.gif\" alt=\"");
  helpHTML.append(helpString);
  helpHTML.append("\" border=\"0\" /></a>");


  boolean showMUControl = false;
  boolean showMUToolbar = true;
  boolean showHelpIcon = true;

  if("false".equalsIgnoreCase(HelpMarker)) {
    showHelpIcon = false;
  }

  if(showMassUpdate != null && "true".equalsIgnoreCase(showMassUpdate))
  {
      UIForm formEditBean = new UIForm();
      MapList columns = tableBean.getColumns(tableData);

      for (int i = 0; i < columns.size(); i++)
      {
          HashMap columnMap = (HashMap)columns.get(i);

			 String columnType = formEditBean.getSetting(columnMap, "Column Type");

			if(columnType.equalsIgnoreCase("Image"))
			{
			formEditBean.modifySetting(columnMap, "Mass Update","false");
			}

          StringBuffer fieldHtml = new StringBuffer(500);
		  //Modified For Bug No 337827 Dated 9/19/2007 Begin.
          if (formEditBean.isFieldEditable(columnMap)&&formEditBean.isFieldMassUpdatable(columnMap)) {
		 //Modified For Bug No 337827 Dated 9/19/2007 Ends.
              boolean bUOMField = (tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap));
                  formEditBean.fillRangeValues(context, requestMap, objectId, relId, columnMap, strLanguage, 0);
              String columnName = tableBean.getName(columnMap);
              String columnNameDisplay = tableBean.getLabel(columnMap);
              String sRangeHelperURL = formEditBean.getRangeHelperURL(columnMap);
              if ((sRangeHelperURL != null && sRangeHelperURL.length() > 0) && !bUOMField)
              {
                  columnNames.add(columnName);
                  columnNamesDisplay.add(columnNameDisplay);
                  columnElementType.add("popup");
                  StringBuffer sRangeHelperURLBuffer = new StringBuffer(150);
                  sRangeHelperURLBuffer.append(UINavigatorUtil.parseHREF(context,sRangeHelperURL, formEditBean.getSetting(columnMap, "Registered Suite")));
                  if(sRangeHelperURLBuffer.toString().indexOf("?") > 0) {
                      sRangeHelperURLBuffer.append("&fieldNameDisplay=valueFieldDisplay");
                  } else {
                      sRangeHelperURLBuffer.append("?fieldNameDisplay=valueFieldDisplay");
                  }
                  sRangeHelperURLBuffer.append("&fieldNameActual=valueField");
                  sRangeHelperURLBuffer.append("&fieldNameOID=valueFieldOID");
                  sRangeHelperURLBuffer.append("&suiteKey=");
                  sRangeHelperURLBuffer.append(formEditBean.getFieldSuiteKey(columnMap));
                  sRangeHelperURLBuffer.append("&emxSuiteDirectory=");
                  sRangeHelperURLBuffer.append(formEditBean.getFieldSuiteDirectory(columnMap));

                  String fieldClearURL = "<a href='javascript:Clear()'>" + UINavigatorUtil.getI18nString("emxFramework.Common.Clear", "emxFrameworkStringResource", strLanguage) + "</a>";
                  String winWidth = formEditBean.getSetting(columnMap, "Window Width");
                  String winHeight = formEditBean.getSetting(columnMap, "Window Height");
                  String readOnly = "";
                  if (!formEditBean.isFieldManualEditable(columnMap)) {
                      readOnly = "READONLY ";
                  }

                  fieldHtml.append("<input type=\\\"text\\\" ");
                  fieldHtml.append(readOnly);
                  fieldHtml.append("name=\\\"valueFieldDisplay\\\" value=\\\"\\\" />");
                  fieldHtml.append("<input type=\\\"button\\\" value=\\\"...\\\" name=\\\"btn\\\"");
                  fieldHtml.append("onclick=\\\"showModalDialog('");
                  fieldHtml.append(sRangeHelperURLBuffer.toString());
                  fieldHtml.append("','");
                  fieldHtml.append(winWidth);
                  fieldHtml.append("','");
                  fieldHtml.append(winHeight);
                  fieldHtml.append("', true )\\\" />&nbsp;");
                  fieldHtml.append(fieldClearURL);
                  fieldHtml.append("<input type=\\\"hidden\\\" name=\\\"valueField\\\" value=\\\"\\\" />");
                  fieldHtml.append("<input type=\\\"hidden\\\" name=\\\"valueFieldOID\\\" value=\\\"\\\" />");
              } else if((formEditBean.isComboBoxField(columnMap) || formEditBean.isListBoxField(columnMap)) && !bUOMField)
              {
                  columnNames.add(columnName);
                  columnNamesDisplay.add(columnNameDisplay);
                  StringList fieldChoices = formEditBean.getFieldChoices(columnMap);
                  StringList fieldChoicesDisplay = formEditBean.getFieldDisplayChoices(columnMap);
                  HashMap fieldChoicesMap = new HashMap();

                  if (fieldChoices != null && fieldChoices.size() > 0) {
                      if (fieldChoicesDisplay == null || fieldChoicesDisplay.size() == 0) {
                        fieldChoicesDisplay = fieldChoices;
                      }

					  // added for bug - 343360
					  for (int itr = 0; itr < fieldChoices.size(); itr++) {
						  fieldChoicesMap.put((String)fieldChoices.get(itr), (String)fieldChoicesDisplay.get(itr));
					  }
                  }

				  String sSortRangeValues = formEditBean.getSetting(columnMap,"Sort Range Values");
                  if(!"disable".equalsIgnoreCase(sSortRangeValues)) {
                  String sortDirection=formEditBean.getSetting(columnMap,"Sort Direction");
                  String sortType=(String)columnMap.get("Attribute Sort Type");
                  fieldChoices = getSortedList(fieldChoices,sortDirection,sortType);
				  }

                  String fieldChoice = "";
                  String fieldChoiceDisplay = "";
                  fieldHtml.append(" <select ");
                  if(formEditBean.isListBoxField(columnMap)) {
                    fieldHtml.append("multiple size=\\\"2\\\" ");
                  }
                  fieldHtml.append("name=\\\"valueField\\\">");

                  if(fieldChoices != null) {
                      for (int j = 0; j < fieldChoices.size(); j++) {
                          fieldChoice = (String)fieldChoices.get(j);
                          // changed for bug - 343360
                          fieldChoiceDisplay = (String)fieldChoicesMap.get(fieldChoice);
                          fieldHtml.append("<option value=\\\"");
                          fieldHtml.append(fieldChoice);
                          fieldHtml.append("\\\">");
                          fieldHtml.append(fieldChoiceDisplay);
                          fieldHtml.append("</option>");
                      }
                  }

                  fieldHtml.append("</select>");
                  columnElementType.add("select");
              } else if(formEditBean.isDateField(columnMap) && !bUOMField) {
                  columnNames.add(columnName);
                  columnNamesDisplay.add(columnNameDisplay);
                  String fieldallowKeyableDates = (String)formEditBean.getSetting(columnMap, "Allow Manual Edit");
                  if((allowKeyableDates != null && "true".equalsIgnoreCase(allowKeyableDates)) || (fieldallowKeyableDates != null && "true".equalsIgnoreCase(fieldallowKeyableDates))) {
                      fieldHtml.append(" <span class=\\\"hint\\\">(");
                      fieldHtml.append(((java.text.SimpleDateFormat)java.text.DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), request.getLocale())).toLocalizedPattern());
                      fieldHtml.append(")</span>");
                      fieldHtml.append(" <input type=\\\"text\\\" size=\\\"14\\\" name=\\\"valueField\\\"");
                      columnElementType.add("manualdate");
                  } else {
                      fieldHtml.append(" <input type=\\\"text\\\" size=\\\"14\\\" name=\\\"valueField\\\"");
                      fieldHtml.append("onFocus=\\\"this.blur();\\\"");
                      columnElementType.add("date");
                  }
                  /* modified for 368828 */
                  
                //Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
                  if(null!=requestMap){
                      //Needed parameters
                          requestMapforCal.put("CalendarProgram",formEditBean.getSetting(columnMap,"Calendar Program"));
                          requestMapforCal.put("CalendarFunction",formEditBean.getSetting(columnMap,"Calendar Function"));
                          requestMapforCal.put("format",formEditBean.getSetting(columnMap,"format"));
                          System.out.println("Input Type" + formEditBean.getSetting(columnMap,"Input Type"));
                          String InputType = formEditBean.getSetting(columnMap,"Input Type");
                          
                          if(InputType != null && !"".equals(InputType))
                        	  requestMapforCal.put("InputType",InputType);
                          else
                        	  requestMapforCal.put("InputType","textbox");
                          
                          requestMapforCal.put("calBeanTimeStamp",timeStamp);
                          requestMapforCal.put("objectId",objectId);
                          requestMapforCal.put("relId",relId);
                          requestMapforCal.put("componentType","table");
                          requestMapforCal.put("mode","edit");
                          
                          if(requestMap.get("languageStr")!=null)
                        	  requestMapforCal.put("languageStr",requestMap.get("languageStr"));
                         //Added:25-01-10:nr2:IR-035216V6R2011
                          if(null != columnName)
                        	  requestMapforCal.put("columnName",columnName);
                         //End:25-01-10:nr2:IR-035216V6R2011
                  }

                  //Put all these parameters in JSON
                      Iterator it = requestMapforCal.keySet().iterator();
                      while(it.hasNext()){
                          String key = (String)it.next();
                          retValObj.put(key ,requestMapforCal.get(key));
                      }
                      String strRetVal = "";
                      strRetVal = retValObj.toString().replaceAll("\"","&quot;");
                      strRetVal = "\'" + strRetVal + "\'";
                  //End
              //End:For Enhanced Calendar Control:AEF:nr2:20-11-09

                    //fieldHtml.append("><a onClick=\\\"javascript:showCalendar2('massUpdateForm', 'valueField', ' ',null,null,null);return false;\\\" href=\\\"javascript:;\\\"><img src=\\\"../common/images/iconSmallCalendar.gif\\\" alt=\\\"Date Picker\\\" border=\\\"0\\\" /></a>");
                    //fieldHtml.append("><a onClick=\\\"javascript:showCalendar2('massUpdateForm', 'valueField', ' ',null,null,null,null,\\\" + strRetVal + \\\");return false;\\\" href=\\\"javascript:;\\\"><img src=\\\"../common/images/iconSmallCalendar.gif\\\" alt=\\\"Date Picker\\\" border=\\\"0\\\" /></a>");
                    fieldHtml.append("><a onClick=\\\"javascript:showCalendar2('massUpdateForm', 'valueField', ' ',null,null,null,null,");
                    fieldHtml.append(strRetVal + ")");
                    fieldHtml.append("\\\";return false;\\\" href=\\\"javascript:;\\\"><img src=\\\"../common/images/iconSmallCalendar.gif\\\" alt=\\\"Date Picker\\\" border=\\\"0\\\" /></a>");
              } else if(formEditBean.isTextAreaField(columnMap) || formEditBean.isTextBoxField(columnMap) || bUOMField) {
                  fieldHtml.append(" <input type=\\\"text\\\" name=\\\"valueField\\\" />");
                  StringList listDimUnits = (StringList)columnMap.get("DB UnitList");
                  String DBUnit = (String)columnMap.get("DB Unit");
                  if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                    String columnSelect = tableBean.getBusinessObjectSelect(columnMap);
                    if(columnSelect == null || "".equals(columnSelect)) {
                        columnSelect = tableBean.getRelationshipSelect(columnMap);
                    }
                    if(UOMUtil.isSimpleAttributeExpression(columnSelect)) {
                        String htmlCode = UIUtil.displayUOMComboField(context, columnName, listDimUnits, DBUnit, "comboValueField",true, Request.getLanguage(request));
                        fieldHtml.append(htmlCode);
                    }
                  }
                  columnNames.add(columnName);
                  columnNamesDisplay.add(columnNameDisplay);
                  columnElementType.add("textbox");

                  //validateBadChars
                  if ((formEditBean.getSetting(columnMap, "Validate Type") != null &&
                      formEditBean.getSetting(columnMap, "Validate Type").equalsIgnoreCase("Basic"))) {
                    fieldHtml.append("<input type=\\\"hidden\\\" name=\\\"badcharValidate\\\" value=\\\"true\\\" />");
                  }
                  //validateBadNameChars
                  if ((formEditBean.getSetting(columnMap, "Validate Type") != null &&
                      formEditBean.getSetting(columnMap, "Validate Type").equalsIgnoreCase("Name"))) {
                    fieldHtml.append("<input type=\\\"hidden\\\" name=\\\"badnamecharValidate\\\" value=\\\"true\\\" />");
                  }
                  //validateRestrictedBadChars
                  if ((formEditBean.getSetting(columnMap, "Validate Type") != null &&
                      formEditBean.getSetting(columnMap, "Validate Type").equalsIgnoreCase("Restricted"))) {
                    fieldHtml.append("<input type=\\\"hidden\\\" name=\\\"badrestrictedValidate\\\" value=\\\"true\\\" />");
                  }

                  //if the field is numeric
                  fieldHtml.append("<input type=\\\"hidden\\\" name=\\\"isNumericField\\\" value=\\\"");
                  if (formEditBean.isNumericField(columnMap)) {
                     fieldHtml.append("true");
                  } else {
                     fieldHtml.append("false");
                  }
                  fieldHtml.append("\\\" />");

                  //if the field is integer
                  fieldHtml.append("<input type=\\\"hidden\\\" name=\\\"isIntegerField\\\" value=\\\"");
                  if (formEditBean.isIntegerField(columnMap)) {
                     fieldHtml.append("true");
                  } else {
                     fieldHtml.append("false");
                  }
                  fieldHtml.append("\\\" />");
              } else if(!formEditBean.isCheckBoxField(columnMap) && !formEditBean.isRadioButtonField(columnMap)) {
                  fieldHtml.append("<input type=\\\"text\\\" name=\\\"valueField\\\">");
                  columnNames.add(columnName);
                  columnNamesDisplay.add(columnNameDisplay);
                  columnElementType.add("textbox");
              }

              //if the field is required
              fieldHtml.append("<input type=\\\"hidden\\\" name=\\\"isFieldRequired\\\" value=\\\"");
              if (formEditBean.isFieldRequired(columnMap)) {
                 fieldHtml.append("true");
              } else {
                 fieldHtml.append("false");
              }
              fieldHtml.append("\\\" />");

              //if the field has custom validation
              fieldHtml.append("<input type=\\\"hidden\\\" name=\\\"hasValidation\\\" value=\\\"");
              if (formEditBean.hasValidation(columnMap)) {
                 fieldHtml.append("true");
                 fieldHtml.append("\\\" />");

              } else {
                 fieldHtml.append("false");
                 fieldHtml.append("\\\" />");
              }
              columnElementHtML.add(fieldHtml.toString());
          }
      }
  }
  else 
  {//Range Values should be updated even if the mass edit is false
    UIForm formEditBean  = new UIForm();
    MapList columns      = tableBean.getColumns(tableData);

    for (int i = 0; i < columns.size(); i++)
    {
        HashMap columnMap = (HashMap)columns.get(i);
        formEditBean.fillRangeValues(context, requestMap, objectId, relId, columnMap, strLanguage, 0);
    }
  }
  
  if(showMassUpdate != null && "true".equalsIgnoreCase(showMassUpdate) && columnNames.size() > 0) {
    showMUControl = true;
  }

  if(!showHelpIcon && !showMUControl && !(!"false".equals(findMxLink) && !"false".equals(enableMxLink))) {
    showMUToolbar = false;
  }

  // Style to be used with one or two toolbar (Mass update toolbar and regular toolbar)
  /*String divPageBody = "divPageBody";
  if (showMUControl && showMUToolbar && toolbar != null && toolbar.length() > 0)
  {
    divPageBody = "divPageBody2";
  }*/
%>
<%
   String progressImage = "images/utilProgressBlue.gif";
   String languageStr = Request.getLanguage(request);
   String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
 %>
  <title><%=strtitle%></title>

  <script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
  <script language="javascript" src="scripts/emxNavigatorHelp.js"></script>
  <script language="JavaScript" src="scripts/emxUIPopups.js"></script>
  <script language="JavaScript" src="scripts/emxUICalendar.js"></script>
    <script language="javascript" src="scripts/emxUIFormUtil.js"></script>
  <script language="javascript" src="scripts/emxUITableEditUtil.js"></script>
    <script language="javascript" src="scripts/emxUITableEditHeaderUtil.js"></script>

  <script language="JavaScript" type="text/JavaScript">
	 addStyleSheet("emxUIDefault");
	 addStyleSheet("emxUIDialog");
	 addStyleSheet("emxUIToolbar");
	 addStyleSheet("emxUICalendar");
	 addStyleSheet("emxUIMenu");
  </script>
  <%@include file = "../emxStyleDefaultInclude.inc"%>
  <%@include file = "../emxStyleDialogInclude.inc"%>

  <script language="javascript">
  //var cancelProcess="true";
  var cancelProcessParamExists = "false";
<%
    if(cancelProcessURL != null || cancelProcessJPO != null) {
%>
        cancelProcessParamExists = "true";
<%
    }
%>
  function onSubmit(){
      document.forms[0].cancelProcess.value = "false";

      var bodyFrame = findFrame(parent, "formEditDisplay");
      if(bodyFrame)
      {
        bodyFrame.tableEditsaveChanges("false");
      }
      else
      {
        tableEditsaveChanges("false");
      }
      document.forms[0].cancelProcess.value = "true";
    }
	
	function onApply(){
	document.forms[0].cancelProcess.value = "false";
	 var bodyFrame = findFrame(parent, "formEditDisplay");
      if(bodyFrame)
      {
        bodyFrame.tableEditsaveChanges("true");
      }
      else
      {
        tableEditsaveChanges("true");
      }
      document.forms[0].cancelProcess.value = "true";
    }

    function recurseData(strDepth){
      var fieldName = document.forms[0].columnSelect[document.forms[0].columnSelect.selectedIndex].text;
      if(fieldName == '') {
          alert("<%=strSelectcolumn%>");
          return;
      }

            //custom validation field
            var formObj = document.forms[0];
            if(formObj.hasValidation && formObj.hasValidation.value == "true")
            {
                document.forms[0].isCustomValidateField.value = "true";
            }

            //validate field if needed
            if(validateColumn(fieldName))
            {
                document.forms[0].strdepth.value = strDepth;
                document.forms[0].target = "formEditHidden";
                document.forms[0].action = "emxTableEditHeaderHiddenProcess.jsp";
                document.forms[0].submit();
        }
        }

    function Clear() {
        var formElement= eval ("document.forms[0]['valueField']");
        if (formElement){
            formElement.value="";
        }

        formElement=eval ("document.forms[0]['valueFieldDisplay']");

        if (formElement){
            formElement.value="";
        }

        formElement=eval ("document.forms[0]['valueFieldOID']");

        if (formElement){
             formElement.value="";
        }
    }

    function swapFormfield(f){
        switch(f) {
<%
            for(int k = 0; k < columnNames.size(); k++) {
%>
            //XSSOK
            case "<%=columnNames.get(k)%>" :
                //XSSOK
                document.forms[0].fieldType.value = "<%=columnElementType.get(k)%>";
                var idiv = document.getElementById('inputDiv');
                //xssencoding is not required for columnElementHtML
                //XSSOK
                idiv.innerHTML = "<%=columnElementHtML.get(k)%>";
                break;
<%
            }
%>
        }
    }

    function windowClose()
    {
      var cancelProcess=document.forms[0].cancelProcess.value;
      if(document.forms[0].clearEditObjList)
      {
        var clearEOList = document.forms[0].clearEditObjList.value;
        if(clearEOList == 'true') {

          var objHiddenFrame = getTopWindow().openerFindFrame(getTopWindow(), "hiddenFrame");
          if(!objHiddenFrame) {
            objHiddenFrame = getTopWindow().openerFindFrame(getTopWindow(), "formViewHidden");
          }
          objHiddenFrame.document.location.href = 'emxTableEditCancelProcess.jsp?timeStamp=<%=XSSUtil.encodeForURL(context, timeStamp)%>&cancelProcess=' + cancelProcess;
        }
      }
      else
      {
          var objHiddenFrame = getTopWindow().openerFindFrame(getTopWindow(), "hiddenFrame");
          objHiddenFrame.document.location.href = 'emxTableEditCancelProcess.jsp?timeStamp=<%=XSSUtil.encodeForURL(context, timeStamp)%>&cancelProcess=' + cancelProcess;
      }
    }


    function loadpage()
    {
      var toppage = getTopWindow().document.location.href;
      //alert("toppage" + toppage);
      if(toppage.indexOf("emxTableEdit.jsp") < 0)
      {
        var editFrame = findFrame(parent,"formEditDisplay");
        editFrame.document.forms[0].isPopup.value = 'false';
        var cnlImg = document.getElementById('cancelImage');
        var cnlTxt = document.getElementById('cancelText');
        cnlTxt.innerHTML = "";
        cnlImg.innerHTML = "";
      }

      if(!isIE)
            {
                emxUICore.addEventHandler(window, "beforeunload", windowClose);
        }
        else
        {
            emxUICore.addEventHandler(window, "unload", windowClose);
        }

    }
    function toViewMultipleToolbars(showMassUpdate){
		if(showMassUpdate){
			var dpb1 = document.getElementById("divPageBody");			
			dpb1.style.top = dpb1.offsetTop + (28) + "px";
		}
	}

    function cleanupEditSession(timeStamp, invokeEditDirectly)
    {
        if (invokeEditDirectly == "true" && cancelProcessParamExists=="false") {
            cleanupSession(timeStamp);
        }
    }
    
    function setTitle(){
    	if(getTopWindow().document.location.href.indexOf("emxNavigatorDialog.jsp") >= 0){
    		getTopWindow().document.title = '<xss:encodeForHTML><%=header%></xss:encodeForHTML>';
    	}
    }
    emxUICore.addEventHandler(window, "load", loadpage);
  </script>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</head>

<body class="dialog" onload="setTitle('<%=strtitle%>');adjustBody();turnOffProgress();" onbeforeunload="cleanupEditSession('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>', '<%=invokeEditDirectly%>')">
<div id="pageHeadDiv" >
        <form name="massUpdateForm" method="post" onsubmit="return false">
        <input type="hidden" name="clearEditObjList" value="true" />
        <input type="hidden" name="cancelProcess" value="true" />
        <input type="hidden" name="fieldType" value="textbox" />
        <input type="hidden" name="strdepth" value="" />
                <input type="hidden" name="isCustomValidateField" value="" />
      <table>
       <tr>
      <td class="page-title">
        <h2><xss:encodeForHTML><%=header%></xss:encodeForHTML></h2>
<%
        if(subHeader != null && !"".equals(subHeader)){
%>
            <h3><xss:encodeForHTML><%=subHeader%></xss:encodeForHTML></h3>
<%
        }
%>
      </td>
    <td class="functions">
        <table>
            <tr>
                <!-- //XSSOK -->
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>            
<%
         String filterLabel = "";
         if (filterStrList != null && filterStrList.size() > 1)
         {
             if (selectedFilter == null || selectedFilter.length() == 0)
                 selectedFilter = (String)filterStrList.get(0);

             for (int i=0; i < filterStrList.size(); i++ )
             {
                 String filterItem = (String)filterStrList.get(i);
                 filterLabel = (String)filterLabelStrList.get(i);

                 if (filterItem.equalsIgnoreCase(selectedFilter) ) {
                     filterLabel = UINavigatorUtil.parseHeader(context, filterLabel, objectId, suiteKey, Request.getLanguage(request));
                     break;
                 }
             }
        }
        if (filterLabel != null && filterLabel.length() > 0 )
        {
%>
      <td align="right" class="filter"><xss:encodeForHTML><%=filterLabel%></xss:encodeForHTML></td>
<%
        }
%>
	              </tr>
	        </table>
        </td>      
        </tr>
        </table>
<%
        if(toolbar != null && !"".equals(toolbar))
        {
          String strHelpMarker = HelpMarker;
          if(showMUControl)
          {
            strHelpMarker = "false";
          } else if (!(!"false".equals(findMxLink) && !"false".equals(enableMxLink))) {
            showMUToolbar = false;
          }
%>
          <jsp:include page = "emxToolbar.jsp" flush="true">
            <jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/>
            <jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
            <jsp:param name="relId" value="<%=XSSUtil.encodeForURL(context, relId)%>"/>
            <jsp:param name="parentOID" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
            <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>
            <jsp:param name="suiteKey" value="<%=XSSUtil.encodeForURL(context, suiteKey)%>"/>
            <jsp:param name="PrinterFriendly" value="false"/>
            <jsp:param name="export" value="false"/>
            <jsp:param name="uiType" value="table"/>
            <jsp:param name="helpMarker" value="<%=XSSUtil.encodeForURL(context, strHelpMarker)%>"/>
          </jsp:include>
<%
        }
if(showMUToolbar) {
%>
                <div id="divToolbarContainer" class="toolbar-subcontainer"><div class="toolbar-frame" id="divToolbar2">
                        <div id="divEditListControls" class="toolbar">
              <table border="0" cellpadding="0" cellspacing="0">
              <tr>
<%
  if(showMUControl)
  {  %>
      <td class="toolbar-panel-label" nowrap><%=strColumn%></td>
      <td class="toolbar-panel-input" nowrap><select name="columnSelect" onChange="swapFormfield(this.options[this.selectedIndex].value)">
      <option value=""></option>
<%
                      for(int j = 0; j < columnNames.size(); j++) {
%>
                          <option value="<%=columnNames.get(j)%>"><xss:encodeForHTML><%=columnNamesDisplay.get(j)%></xss:encodeForHTML></option>
<%
                      }
%>
                    </select>
              </td>
              <td class="toolbar-panel-label" nowrap><%=strValue%></td>
              <td class="toolbar-panel-input" nowrap>
              <div id="inputDiv">
                <input type="text" name="textfield" value="" />
              </div>
              </td>
              <td class="toolbar-panel-input" nowrap>
              <input type="button" name="applyToSel" value="<%=strApplytoselected%>" onClick="javascript:recurseData('selected')"><input type="button" name="applyToAll" value="<%=strApplytoall%>" onClick="javascript:recurseData('all')" />
              </td>
			   <!-- //XSSOK -->
			   <td align="right"><%=mxLinkHTML.toString()%></td>
<%
  }

  if (!showMUControl && !"false".equals(findMxLink) && !"false".equals(enableMxLink)) { %>
    <td><div class="separator"></div></td>
	<td align="right"><%=mxLinkHTML.toString()%> </td>
<%
  }
  if(showHelpIcon) {
%>
              <td><div class="separator"></div></td>
              <td align="right"><%=helpHTML.toString()%></td>
<%
  }
%>
                </tr>
              </table>
                        </div>
                </div></div>
<%
}
String emxTableEditBodyURL = UINavigatorUtil.encodeURL("emxTableEditBody.jsp?"+sfb.toString());
%>
      </form>
        </div>
        <%if(toolbar != null && !"".equals(toolbar))
        {
        %>
            <div id="divPageBody" class="edit">
        <%}else{%>
            <div id="divPageBody">
        <%}%>
          <!-- //XSSOK -->
          <iframe name="formEditDisplay" src="<%=emxTableEditBodyURL%>" width="100%" height="100%"  frameborder="0" border="0"></iframe>
          <iframe class="hidden-frame" name="formEditHidden" HEIGHT="0" WIDTH="0"></iframe>
        </div>

        <div id="divPageFoot">
                <div id="divDialogButtons">
          <table>
          <tr>
          <td align="right" class="buttons">
          <table>
          <tr>
<%
	  if(showApply!=null)
	  {
%>
		   <td><a class="footericon" href="javascript:;" onClick="onApply();return false"><img src="images/buttonDialogApply.gif" border="0" alt="<%=helpApply%>" /></a></td>
                    <td><a href="javascript:;" onClick="onApply();return false" class="button"><button class="btn-default" type="button"><%=helpApply%></button></a></td>
<%
}
%>

                    <td><a class="footericon" href="javascript:;" onclick="onSubmit();return false"><img src="images/buttonDialogDone.gif" border="0" alt="<%=helpDone%>" /></a></td>
                    <td><a href="javascript:;" onclick="onSubmit();return false" class="button"><button class="btn-primary" type="button"><%=helpDone%></button></a></td>
		    <td><a class="footericon" href="javascript:getTopWindow().closeWindow()"><img src="images/buttonDialogCancel.gif" border="0" alt="<%=helpCancel%>" /></a></td>
            	    <td><a onClick="javascript:getTopWindow().closeWindow()" class="button"><button class="btn-default" type="button"><%=helpCancel%></button></a></td>
          </tr>
          </table>
          </td>
          </tr>
          </table>
                </div>
        </div>
</body>
</html>
