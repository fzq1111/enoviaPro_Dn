<%--  SEMIssueSummarizeInit.jsp --%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@ page import="com.matrixone.apps.framework.ui.UIStructureCompare"%>
<%@ page import = "org.apache.log4j.Logger"%>
<html>


<jsp:useBean id="SCTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/>

<body>
<%
	String strLanguage = request.getHeader("Accept-Language");
	String strEmptyReportMsg = UINavigatorUtil.getI18nString(
		"SEM.emxFramework.Common.EmptyReportResults",
		"emxFrameworkStringResource", strLanguage);
%>
<script type="text/javascript"> addStyleSheet("emxUIDialog"); </script>
<div class="divPageBody" align = "center"><%=strEmptyReportMsg%></div>

</body>
</html>
