<%--  SEMIssueSummarize.jsp --%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ page import = "com.matrixone.apps.framework.ui.UIUtil" %>
<%@ page import = "org.apache.log4j.Logger"%>

<%
	Logger myLogger = Logger.getLogger(SEMIssueSummarize_jsp.class);
	try
	{
		String contentURL = "";
		String suiteKey = emxGetParameter(request,"suiteKey");
		String strHeader = emxGetParameter(request,"header");
		String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
		String strObjectId = "";
		String strRowInfo = tableRowIdList[0];
	    StringList strlRowInfo = FrameworkUtil.split(strRowInfo, "|");
	    if (strlRowInfo.size() == 3)
	    {
	    	strObjectId = (String) strlRowInfo.get(0);
	    }
	    else
	    {
	    	strObjectId = (String) strlRowInfo.get(1);
	    }
		String strSelectedObjIds = strObjectId;
		DomainObject dobj = DomainObject.newInstance(context, strObjectId);
		String strType = dobj.getType(context);
		
		for(int i = 1; i < tableRowIdList.length; i ++)
		{
		    strRowInfo = tableRowIdList[i];
		    strlRowInfo = FrameworkUtil.split(strRowInfo, "|");
			String strSelectedId = "";
		    if (strlRowInfo.size() == 3)
		    {
		    	strSelectedId = (String) strlRowInfo.get(0);
		    }
		    else
		    {
		    	strSelectedId = (String) strlRowInfo.get(1);
		    }
		    strSelectedObjIds += "," + strSelectedId;
		}
		
		session.putValue("SEMIssueSelectedId", strSelectedObjIds);
		contentURL = "../common/emxPortal.jsp?portal=SEMIssueSummarizePortal&header=" + XSSUtil.encodeForJavaScript(context, strHeader) + 
					"&AppSuiteKey="+XSSUtil.encodeForJavaScript(context, suiteKey) + "&suiteKey="+XSSUtil.encodeForJavaScript(context, suiteKey) + 
					"&selectedType=" + XSSUtil.encodeForJavaScript(context, strType);
	
%>

<!-- <form name="form1" method="post" action="<%=contentURL %>" target="popup">
	<input type="hidden" name="selectIds" value="<%=strSelectedObjIds%>">
</form> -->
    
<script type="text/javascript">
    //document.form1.submit();
     showAndGetNonModalDialog("<%=contentURL%>", "Max", "Max", "true");
</script>

<%
	}catch(Exception ex)
	{
		myLogger.error(ex.getMessage(), ex);
%>
	<script type="text/javascript">
	    alert("<%=ex.getMessage()%>");
	</script>
<%
	}
%>
