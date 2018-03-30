<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>

<%
/*
	Enumeration en = request.getParameterNames();
	while(en.hasMoreElements()) {
		String paraName = (String) en.nextElement();
		String [] values = (String []) request.getParameterValues(paraName);
		System.out.print(paraName + "=");
		for(int i = 0; i < values.length; i++) {
			System.out.print(values[i] + " ");
		}
		System.out.println();
	}
*/
    PropertyUtil.setGlobalRPEValue(context, DomainAccess.RPE_MEMBER_ADDED_REMOVED, "true");    
	String openerFrame 			= emxGetParameter(request,"openerFrame");
	String jpoName = emxGetParameter(request,"jpoName");
	if(UIUtil.isNullOrEmpty(jpoName)) {
		jpoName = "emxTeamcenterClient";
	}
	String methodName = emxGetParameter(request,"methodName");
	if(UIUtil.isNullOrEmpty(methodName)) {
		methodName = "doImportPartTask";
    }
	String objectId = emxGetParameter(request, "objectId");
    String[] ids = emxGetParameterValues(request, "emxTableRowId");
	
	Map paramMapForJPO = new HashMap();		
	paramMapForJPO.put("busObjId", objectId);			
	paramMapForJPO.put("emxTableRowIds" ,ids);		
	String[] args = JPO.packArgs(paramMapForJPO);
	try {
		JPO.invoke(context, jpoName, null, methodName, args);
%>
	<script>
		alert("\u64cd\u4f5c\u5b8c\u6210");
	</script>
<%
	} catch (Exception ex) {
		String message = ex.getMessage();
%>
	<script>
		var errorMsg = "<%=XSSUtil.encodeForJavaScript(context, message)%>";
		alert(errorMsg);
	</script>
<%}%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

<script>
	var pageToRefresh = getTopWindow().getWindowOpener();
	if (pageToRefresh) {
		window.top.opener.location.href = window.top.opener.location.href;
		window.top.close();
	}
	else {
		var openerFrame = "<xss:encodeForJavaScript><%=openerFrame%></xss:encodeForJavaScript>";
		//getTopWindow().refreshTablePage();
		var frameHandle = getTopWindow().findFrame(getTopWindow(), openerFrame);		
			frameHandle.location.href = frameHandle.location.href;		
		//frameHandle.refreshTablePage();
	}
</script>
