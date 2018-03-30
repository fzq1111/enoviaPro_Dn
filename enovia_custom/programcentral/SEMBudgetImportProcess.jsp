
<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page language="java" pageEncoding="UTF-8"%>



<head>

<script language="javascript">

function doneMethod()
{
     f = document.fileUpload;     
     //startProgressBar(true);
     f.submit();
     //parent.window.close();

}
</script>

</head>

<%
  String objectId = emxGetParameter(request,"objectId");

  String actionUrl = "SEMBudgetImportSubmit.jsp?objectId="+objectId;
%>
<html>
<body>
    <!-- content begins here -->
    <form name = "fileUpload" method = "post" action = "<%=actionUrl%>" target="_parent" enctype="multipart/form-data">
      
     
      <br/><br/>
      <table border="0" cellpadding="0" cellspacing="0" align="center">  <!-- class="formBG" -->
        <tr align="center">          
          <td><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.File</emxUtil:i18n> <input size="35" type="file" name="file"></td>
        </tr>
    </table>

    </form>
</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
</html>

