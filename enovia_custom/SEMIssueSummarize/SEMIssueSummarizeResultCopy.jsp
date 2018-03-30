<%--  SEMIssueSummarizeResultCopy.jsp --%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@ page import="com.matrixone.apps.framework.ui.UIStructureCompare"%>
<%@ page import = "org.apache.log4j.Logger"%>
<html>
<head>
<script type="text/javascript"> 
copyToClipboard = function(txt) 
{
	if(window.clipboardData) 
	{
		window.clipboardData.clearData();
		window.clipboardData.setData("Text", txt);
	} else if(navigator.userAgent.indexOf("Opera") != -1) 
	{
		window.location = txt;
	} else if (window.netscape) 
	{
		try 
		{
			netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
		} catch (e) 
		{
			alert(e.name + ": " + e.message);
			return false;
		}
		
		var clip = Components.classes['@mozilla.org/widget/clipboard;1'].createInstance(Components.interfaces.nsIClipboard);
		if (!clip)
		{
			alert("Copy failed!");
			return;
		}
			
		var trans = Components.classes['@mozilla.org/widget/transferable;1'].createInstance(Components.interfaces.nsITransferable);
		if (!trans)
		{
			alert("Copy failed!");
			return;
		}
			
		trans.addDataFlavor('text/unicode');
		var str = new Object();
		var len = new Object();
		var str = Components.classes["@mozilla.org/supports-string;1"].createInstance(Components.interfaces.nsISupportsString);
		var copytext = txt;
		str.data = copytext;
		trans.setTransferData("text/unicode",str,copytext.length*2);
		var clipid = Components.interfaces.nsIClipboard;
		if (!clip)
		{
			alert("Copy failed!");
			return false;
		}
		
		clip.setData(trans,null,clipid.kGlobalClipboard);
	}
	alert("\u6570\u636E\u6210\u529F\u590D\u5236\u5230\u526A\u8D34\u677F");
}
</script>
</head>
<body>
<%
	MapList summarizeList = (MapList)session.getValue("summarizeList");
	Map orderMap = (Map)summarizeList.get(0);
	String strClipTxt = "";
	for(int i = 1; i < summarizeList.size(); i ++)
	{
		Map map = (Map)summarizeList.get(i);
		String strRowTxt = "";
		for(int m = 0; m < orderMap.keySet().size(); m ++)
		{
			String strAttrName = (String)orderMap.get("" + m);
			strRowTxt += (String)map.get(strAttrName) + "\t";
		}
		strRowTxt = strRowTxt.substring(0, strRowTxt.length() - 1);
		
		strClipTxt += strRowTxt + "\r\n";
	}
%>
<script type="text/javascript"> 
var testtxt = "<%=XSSUtil.encodeForJavaScript(context, strClipTxt)%>";
copyToClipboard(testtxt);

</script>

</body>
</html>
