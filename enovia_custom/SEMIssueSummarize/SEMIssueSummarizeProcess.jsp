<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%@page import = "java.util.HashMap"%>

<%@page import = "com.matrixone.apps.domain.DomainObject,
                  com.matrixone.apps.domain.DomainConstants,
                  matrix.db.*"%>
<%@ page import = "org.apache.log4j.Logger"%>

<%
	Logger myLogger = Logger.getLogger(SEMIssueSummarizeProcess_jsp.class); 
	try
	{
		String strSelectedIds = (String)session.getValue("SEMIssueSelectedId");
		String strPanelAttribute = (String)emxGetParameter(request,"PanelAttribute");
		
		MapList summarizeList = new MapList();
		Map orderMap = new HashMap();
		orderMap.put("0", "\u5C5E\u6027");
		orderMap.put("1", "A");
		orderMap.put("2", "B");
		orderMap.put("3", "C");
		orderMap.put("4", "D");
		orderMap.put("5", "TTL");
		summarizeList.add(0, orderMap);
		
		Map paramMap = new HashMap();
		paramMap.put("selectedObjIds", strSelectedIds);
		paramMap.put("selectedAttr", strPanelAttribute);
		String[] jpoArgs = JPO.packArgs(paramMap);
		MapList resultList = (MapList)JPO.invoke(context, "SEMIssueSummarize", null, "getSeletedAttributeValues", jpoArgs, MapList.class);
		summarizeList.addAll(resultList);
		session.putValue("summarizeList", summarizeList);
		
		String strUrl = "../common/emxTable.jsp?jpoAppServerParamList=session:summarizeList" + 
		        "&editLink=false&expandLevelFilter=false&customize=false&toolbar=SEMIssueSummarizeResultToolbar" + 
	  			"&program=SEMIssueSummarize:getAllItems&table=SEMIssueSummarizeResultTable" + 
		        "&suiteKey=Framework&SuiteDirectory=Framework&selection=none" + 
	  			"&hideLaunchButton=true&portalMode=true&StringResourceFileId=emxFrameworkStringResource" + 
	  			"&objectId=";

%>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript" type="text/javascript">
		
		var resultTargetFrame = getTopWindow().parent.findFrame(getTopWindow(),"<xss:encodeForJavaScript>SEMIssueSummarizeResults</xss:encodeForJavaScript>");
		resultTargetFrame.location.href = "<%=strUrl%>";  
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