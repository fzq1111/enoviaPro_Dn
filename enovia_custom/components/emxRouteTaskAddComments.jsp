<%-- emxRouteTaskAddComments.jsp --

  Copyright (c) 1992-2015 Dassault Systemes.All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $ Exp $
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%

  String languageStr = request.getHeader("Accept-Language");
  String keyValue  = emxGetParameter(request, "keyValue");
   if(keyValue == null){
         keyValue = formBean.newFormKey(session);
 }

 formBean.processForm(session,request,"keyValue");
 String fromPage = (String)formBean.getElementValue("fromPage");
 String isFDAEnabled = emxGetParameter(request, "isFDAEnabled");
%>

<script language="javascript">
    function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }
  
 function submitForm() {	
	<%	
	String formPage = (String)formBean.getElementValue("fromPage");
	if( formPage.equals("Complete")){						
			if(isFDAEnabled != null && "true".equalsIgnoreCase(isFDAEnabled)){
			 %>
				document.RejectTask.target=getTopWindow().getWindowOpener().name;
			   // Begin of Modify by Infosys for bug no.297431, dated 12-May-2005
			   if (jsDblClick()) {
				document.RejectTask.submit();
			   }
			   // End of Modify by Infosys for bug no.297431, dated 12-May-2005
				getTopWindow().closeWindow();
			 <%
			  }
			  else
			  {
			  %>
				  // Begin of Modify by Infosys for bug no.297431, dated 12-May-2005
				  if (jsDblClick()) {
				document.RejectTask.submit();
			  }
				 // End of Modify by Infosys for bug no.297431, dated 12-May-2005
			 <% }
			 %>
			return; 
	<%
	}
	else{
		%>
		if ( trim(document.RejectTask.txtComments.value) == "" ) {
			alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RejectComments.Comments</emxUtil:i18nScript>");
			document.RejectTask.txtComments.value="";
			document.RejectTask.txtComments.focus();
			return;
		} else {
			<% if(isFDAEnabled != null && "true".equalsIgnoreCase(isFDAEnabled)){
			 %>
				document.RejectTask.target=getTopWindow().getWindowOpener().name;
			   // Begin of Modify by Infosys for bug no.297431, dated 12-May-2005
			   if (jsDblClick()) {
				document.RejectTask.submit();
			   }
			   // End of Modify by Infosys for bug no.297431, dated 12-May-2005
				getTopWindow().closeWindow();
			 <%
			  }
			  else
			  {
			  %>
				  // Begin of Modify by Infosys for bug no.297431, dated 12-May-2005
				  if (jsDblClick()) {
				document.RejectTask.submit();
			  }
				 // End of Modify by Infosys for bug no.297431, dated 12-May-2005
			 <% }
			 %>
			return; 
		}
	<%
	}
	%>
}
</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
        if( (fromPage !=null) && (!fromPage.equals("")) )
        {
                if(fromPage.equals("ApproveCommand"))
                        fromPage="Approve";
                else if(fromPage.equals("RejectCommand"))
                        fromPage="Reject";
        }else{
                fromPage="";
        }

%>

<%
	if( formPage.equals("Complete")){
		%>
		<form name="RejectTask" method="post" onSubmit="return false" action="emxUserTasksSummaryLinksProcess.jsp">
		<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
		<input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>"/>
		<input type="hidden" name="fromPage" value="<xss:encodeForHTMLAttribute><%=fromPage%></xss:encodeForHTMLAttribute>"/>
		<input type="hidden" name="returnBack" value="true"/>
		  <table border="0" cellpadding="5" cellspacing="2" width="100%">
			<tr>
			  <td class="label">
				<emxUtil:i18n localize="i18nId">emxComponents.Common.Comments</emxUtil:i18n>
			  </td>
			  <td class="inputField"><textarea name="txtComments" id="txtComments" rows="5" cols="35"></textarea></td>
			</tr>
		  </table>
		  &nbsp;
		</form>
		<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
	<%}
	else{
		%>
		<form name="RejectTask" method="post" onSubmit="return false" action="emxUserTasksSummaryLinksProcess.jsp">
		<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
		<input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>"/>
		<input type="hidden" name="fromPage" value="<xss:encodeForHTMLAttribute><%=fromPage%></xss:encodeForHTMLAttribute>"/>
		<input type="hidden" name="returnBack" value="true"/>
		  <table border="0" cellpadding="5" cellspacing="2" width="100%">
			<tr>
			  <td class="labelRequired">
				<emxUtil:i18n localize="i18nId">emxComponents.Common.Comments</emxUtil:i18n>
			  </td>
			  <td class="inputField"><textarea name="txtComments" id="txtComments" rows="5" cols="35"></textarea></td>
			</tr>
		  </table>
		  &nbsp;
		</form>
		<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
	<%}
%>



