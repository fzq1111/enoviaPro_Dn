<%--  emxBlank.jsp   - Page for poping up a window from an actin link page

   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxAEFSubmitPopupAction.jsp.rca 1.8 Tue Oct 28 22:59:40 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>

<html>
<%
  String strURL = emxGetParameter(request,"url");
  String frameName = emxGetParameter(request,"frameName");
%>
<head><title><xss:encodeForHTML><%=sAppName%></xss:encodeForHTML></title>
<script language="JavaScript" src="scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/emxUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/emxUIConstants.js" type="text/javascript"></script>

<script language="javascript">
var strURL= "<%=XSSUtil.encodeForJavaScript(context, strURL)%>";
var frameName= "<%=XSSUtil.encodeForJavaScript(context, frameName)%>";
function submitSpecialForm(){
	
	var objListWindow = findFrame(getTopWindow().getWindowOpener(), "listDisplay");

	/* added for getting the proper frame using frame name*/
	if(!objListWindow){
			  objListWindow = findFrame(getTopWindow().getWindowOpener().parent, frameName);
			  var objListChildWindow = findFrame(objListWindow, "listDisplay");
			  if(!objListChildWindow){
				  objListChildWindow = findFrame(objListWindow, "formViewDisplay");
			  }	
			  if(!objListChildWindow){
				  objListChildWindow = findFrame(objListWindow, "formEditDisplay");
			  }  
			  objListWindow = objListChildWindow ? objListChildWindow : objListWindow;			  
		}
if(!objListWindow){
   objListWindow=findFrame(getWindowOpener().parent, "formViewDisplay");
   if(!objListWindow){
        objListWindow = getWindowOpener().parent.frames['formEditDisplay'];
   }
   
   //mod by zs 4/13/2017
   var contExit;
   if(!objListWindow){
	   contExit = getWindowOpener().location.href;
	   if(contExit.indexOf("frompage")>0){
		   objListWindow = getWindowOpener();
	   }else{
		   objListWindow = getWindowOpener().parent;
	   }
        
   }
   //end
}
   
   var objForm = objListWindow.document.forms['emxSubmitForm'] ? objListWindow.document.forms['emxSubmitForm'] : objListWindow.document.forms[0];

   if(objForm.timeStamp){
	   strURL += "&timeStamp=" + objForm.timeStamp.value;
   }
   
   //Added for Bug : 353307
   var rmbFormParent = objListWindow.document.body;
   if(strURL.indexOf("isFromRMB=true") > 0)  {
   	  objForm = emxUICore.clonedForm(objForm,rmbFormParent);
   }  
   
   objForm.target = window.name;
   objForm.action = strURL;
   objForm.method = "post";
  
    objListWindow.addSecureToken(objForm);
   objForm.submit();
	objListWindow.removeSecureToken(objForm);
   if(strURL.indexOf("isFromRMB=true") > 0) {
   	  rmbFormParent.removeChild(objForm);
   }
}

</script>
</head>

<body topmargin="0" marginheight="0" leftmargin="0" marginwidth="0" onload="submitSpecialForm()">
</body>
</html>

