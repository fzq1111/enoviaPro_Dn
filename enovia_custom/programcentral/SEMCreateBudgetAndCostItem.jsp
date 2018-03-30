<%-- emxProgramCentralWBSHiddenProcess.jsp

  Displays the tasks/phases for a given project.

  Copyright (c) 1992-2015 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = "$Id: emxProgramCentralWBSHiddenProcess.jsp.rca 1.1.1.4.3.2.2.2 Fri Dec 19 05:48:40 2008 ds-panem Experimental $";
--%>
<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>


<%
String projectId      = emxGetParameter(request, "objectId");
DomainObject obj=new DomainObject(projectId);
String typeName1=obj.getInfo(context,"type");
String[] emxTableRowId= emxGetParameterValues(request, "emxTableRowId");
String mode=emxGetParameter(request,"mode");
if(mode.equals("CreateBudget"))
{
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue=emxTableRowId[i].split("\\|");
			String objectId=splitValue[1];
			String tableId = splitValue[3];
			DomainObject strObj=new DomainObject(objectId);
			String typeName=strObj.getInfo(context,"type");
			String strURL = "../common/emxCreate.jsp?form=type_CreateSEMBudget&type=type_Budget&header=emxFramework.webform.SEMBudgetNew&nameField=keyin&createJPO=SEMBudget:createBudget&submitAction=refreshCaller&mode=CreateBudget&parentOID="+projectId+"&objectId="+objectId+"&tableId="+tableId;
			if("Cost Item".equals(typeName))
			{
				%>
					<script type="text/javascript">
					alert("\u63D0\u793A\u65E0\u6CD5\u5728\u6295\u8D44\u9879\u4E0B\u6DFB\u52A0\u6295\u8D44");
					top.window.close();
					</script>
				<%
			}else
			{
				%>
				  <script type="text/javascript">
				  var url = "<%=strURL%>";
					window.location.href = url;
					</script>
				<%
			}
		}
}
%>
