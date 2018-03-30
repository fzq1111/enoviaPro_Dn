<%-- emxCustomizeTableProcess.jsp
   ¨ Dassault Systemes, 1993 ? 2007. All rights reserved.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
   static const char RCSID[] = $Id: emxCustomizeTableProcess.jsp.rca 1.10.3.3 Tue Oct 28 22:59:38 2008 przemek Experimental przemek $
--%>

<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxNavigatorTimerTop.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />
 
<html>
<head>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUITableUtil.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>

<script type="text/javascript">
                addStyleSheet("emxUIDefault");
                addStyleSheet("emxUIDialog");
                addStyleSheet("emxUIToolbar");
                addStyleSheet("emxUIMenu");
</script>
<%
	String strTimeStamp = emxGetParameter(request,"timeStamp");
	String strUIType = emxGetParameter(request,"uiType");
	String strColumnsText = emxGetParameter(request,"columnsText");
	String strColumnsValue = emxGetParameter(request,"columnsValue");
	String strNewTableName = emxGetParameter(request,"txtCustomTextBox");	        
	String strFirstSortColumn = emxGetParameter(request,"hdnFirstColumn");	        
	String strSecondSortColumn = emxGetParameter(request,"hdnSecondColumn");	        
	String strThirdSortColumn = emxGetParameter(request,"hdnThirdColumn");	       
	String strFirstSortDirection= emxGetParameter(request,"hdnFirstColumnDirection");	        
	String strSecondSortDirection = emxGetParameter(request,"hdnSecondColumnDirection");	        
	String strThirdSortDirection = emxGetParameter(request,"hdnThirdColumnDirection");	     
	String strTable = emxGetParameter(request,"table");
	
	
	String strMode = emxGetParameter(request,"mode");
	String strSysTable = strTable;
	String strCustomSortColumn = "";
	String strCustomSortDirection = "";
	
	if( strFirstSortColumn!=null &&!"None".equalsIgnoreCase(strFirstSortColumn) && !"".equals(strFirstSortColumn))
	{
	    strFirstSortColumn = strFirstSortColumn.substring(strFirstSortColumn.indexOf("@")+1,strFirstSortColumn.length());
	    strCustomSortColumn = strFirstSortColumn;
	    strCustomSortDirection = strFirstSortDirection;
	}
	if(strSecondSortColumn!=null && !"None".equalsIgnoreCase(strSecondSortColumn) && !"".equals(strSecondSortColumn))
	{
	    strSecondSortColumn = strSecondSortColumn.substring(strSecondSortColumn.indexOf("@")+1,strSecondSortColumn.length());
	    strCustomSortColumn += "," + strSecondSortColumn;
	    strCustomSortDirection += "," + strSecondSortDirection;
	}
	if(strThirdSortColumn!=null && !"None".equalsIgnoreCase(strThirdSortColumn) && !"".equals(strThirdSortColumn))
	{
	    strThirdSortColumn = strThirdSortColumn.substring(strThirdSortColumn.indexOf("@")+1,strThirdSortColumn.length());
	    strCustomSortColumn += "," + strThirdSortColumn;
	    strCustomSortDirection += "," + strThirdSortDirection;
	}
	        
	java.util.List propertyList = new StringList();
	propertyList.add(0,strCustomSortColumn);
	propertyList.add(1,strCustomSortDirection);
		
	if("table".equalsIgnoreCase(strUIType))
	{
	    HashMap requestMap = (HashMap)tableBean.getRequestMap(strTimeStamp);
	    Boolean userTable = (Boolean)requestMap.get("userTable");
	    if(userTable!=null)
	    {
	    	boolean isUserTable  = userTable.booleanValue();
	    	strSysTable = tableBean.getSystemTableName(context,strTable,isUserTable);
	    }
	    else
	    {
	        strSysTable = tableBean.getSystemTableName(context,strTable);
	    }
		
	}
	if("structureBrowser".equalsIgnoreCase(strUIType))
	{
	    HashMap requestMap = (HashMap)indentedTableBean.getRequestMap(strTimeStamp);
	    Boolean userTable = (Boolean)requestMap.get("userTable");
	    if(userTable!=null)
	    {
	    	boolean isUserTable  = userTable.booleanValue();
	    	strSysTable = tableBean.getSystemTableName(context,strTable,isUserTable);
	    }
	    else
	    {
	        strSysTable = tableBean.getSystemTableName(context,strTable);
	    }
		
	}
	
	StringList listMap = new StringList();
	HashMap hmpHidden = new HashMap();
	HashMap hmpBasic = new HashMap();
	HashMap hmpExpression = new HashMap();
	HashMap hmpAttribute = new HashMap();
	HashMap hmpSystem = new HashMap();
	HashMap hmpSeparator = new HashMap();
	HashMap hmpDynamicColumns = new HashMap();
	StringBuilder strBuffFreezePane = new StringBuilder(64);	
	StringList strlColumnText = FrameworkUtil.split(strColumnsText,",");
	StringList strlColumnValue = FrameworkUtil.split(strColumnsValue,",");
	// Modified for bug no 345209
	int j=0;
	// End
	for(int i=0;i<strlColumnValue.size();i++)
	{
	    j++;
	    String strValue =(String) strlColumnValue.get(i);
	    StringList strlValues = FrameworkUtil.split(strValue,"|");
	    strValue = (String)strlValues.get(0);
	    String strExpression = (String)strlValues.get(1);
	    String label = (String)strlValues.get(2);
	    String strSortWidth = (String)strlValues.get(3);
	    StringList strList = FrameworkUtil.split(strSortWidth,"~");
		strSortWidth = (String) strList.get(0);
		String strWidth = (String) strList.get(1);
		if(strWidth.equals("0.0"))
		    strWidth = "0";
		if( strWidth!=null && !"".equalsIgnoreCase(strWidth))
		{
		    double width = 0;
		    if("structureBrowser".equalsIgnoreCase(strUIType))
		    {
		    	width = Double.parseDouble(strWidth) * 8;
		    }
		    else
		    {
		        width = Double.parseDouble(strWidth);
		        
		    }
		    strWidth = String.valueOf(width);
		    strWidth = strWidth.substring(0,strWidth.indexOf("."));
		}
		String strText =(String) strlColumnText.get(i);
		//int j = i+1;
	    strText += "|" + j +"|"+ strExpression+"|"+strWidth+"|"+label;
	    // Added for bug no 345209
	    if(strExpression.equals("paneSeparator"))
	        j--;
	    // End
	    long myLong = System.currentTimeMillis();
    	String strRandom = String.valueOf(myLong);
    	if(strValue.indexOf("@")<0)
    	{
    	    if(strValue.startsWith("Separator"))
    	    {
	    	    try
	    	    {
    	        	strValue = strValue+strRandom+i;
	    	    }
	    	    catch(Exception e)
	    	    {
	    	        
	    	    }   
	    	    hmpSeparator.put(strValue,strText);
    	    }
    	    
    	}
    	else
    	{
    	    if(strValue.startsWith("system@"))
    	    {
    	        hmpSystem.put(strValue,strText);
    	    }
    	    if(strValue.startsWith("hidden@"))
    	    {
    	        hmpHidden.put(strValue,strText);
    	    }
    	    if(strValue.startsWith("basic@"))
    	    {
    	        hmpBasic.put(strValue,strText);
    	    }
    	    if(strValue.startsWith("expression@"))
    	    {
    	        hmpExpression.put(strValue,strText);
    	    }
    	    if(strValue.startsWith("businessobject@") || strValue.startsWith("relationship@"))
    	    {
    	        hmpAttribute.put(strValue,strText);
    	    }
			if(strValue.startsWith("dynamic@")){
    	    	hmpDynamicColumns.put(strValue,strText);
    	    }
    	    if(strValue.startsWith("paneSeparator"))
    	    {
    	        for(int l=0;l<i;l++)
    	        {
    	            if(l!=0 && l!=i)
    	            {
    	                // Modified for bug no 343857
    	                strBuffFreezePane.append(",");
    	                // till here
    	            }
    	            String strTemp =(String) strlColumnValue.get(l);
    	    	    strlValues = FrameworkUtil.split(strTemp,"|");
    	    	    String strValueNew = (String)strlValues.get(0);
    	    	    try
    	    	    {
    	    	        strValueNew = strValueNew.substring(strValueNew.indexOf("@")+1,strValueNew.length());
    	    	        
    	    	    }
    	    	    catch(Exception e)
    	    	    {
    	    	        // No need to throw the exception.
    	    	    }
    	    	    
    	    	    strBuffFreezePane.append(strValueNew);
    	        }
    	    }
    	   
    	}
	}
	listMap.add(hmpHidden);
	listMap.add(hmpBasic);
	listMap.add(hmpExpression);
	listMap.add(hmpAttribute);
	listMap.add(hmpSystem);
	listMap.add(hmpSeparator);
	listMap.add(hmpDynamicColumns);
	propertyList.add(2,strBuffFreezePane);
	
	if((strUIType !=null) && ("structureBrowser".equalsIgnoreCase(strUIType)))
	{
	    strNewTableName = indentedTableBean.createCustomTable(context,strTimeStamp,strNewTableName,listMap,propertyList,strMode);
	    //add by ryan 2017-03-09
	    try
	    {
		    if(strNewTableName.indexOf("PMCWBSViewTable") > 0)
		    {
		    	String strMqlCmd = "print table \"" + strNewTableName + "\" user \"" + context.getUser() + "\" select column.isderived column.number dump";
		    	String strResult = MqlUtil.mqlCommand(context, strMqlCmd);
		    	String[] results = strResult.split(",");
		    	int nLength = results.length / 2;
		    	for(int i = 0; i < nLength; i ++)
		    	{
		    		if(results[i].equalsIgnoreCase("FALSE"))
		    		{
		    			strMqlCmd = "mod table \"" + strNewTableName + "\" user \"" + context.getUser() + "\" column modify " + results[i + nLength] + 
		    					" setting \"Edit Access Function\" isTaskEditable setting \"Edit Access Program\" emxTask";
		    			MqlUtil.mqlCommand(context, strMqlCmd);
		    		}
		    	}
		    }
	    }catch(Exception ex)
	    {
	    	ex.printStackTrace();
	    	throw ex;
	    }
	    //add end
	    
%>
		<script language="JavaScript">
			parent.getWindowOpener().refreshSBTable('<xss:encodeForJavaScript><%=strNewTableName%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strCustomSortColumn%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strCustomSortDirection%></xss:encodeForJavaScript>','true','<xss:encodeForJavaScript><%=strTimeStamp%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strUIType%></xss:encodeForJavaScript>');
			parent.window.closeWindow();
		</script>
<%
	}
	if((strUIType !=null) && ("table".equalsIgnoreCase(strUIType)))
	{
	    strNewTableName = tableBean.createCustomTable(context,strTimeStamp,strNewTableName,listMap,propertyList,strMode);
	    
%>
		<script language="JavaScript">
			parent.getWindowOpener().refreshTable('<xss:encodeForJavaScript><%=strNewTableName%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strCustomSortColumn%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strCustomSortDirection%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strTimeStamp%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strUIType%></xss:encodeForJavaScript>');
			parent.window.closeWindow();
		</script>
<%
	}
%>
