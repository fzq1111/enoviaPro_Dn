<html>
	<body>
<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@ page import = "com.matrixone.apps.common.Lifecycle,com.matrixone.apps.domain.*,matrix.db.*,com.matrixone.apps.common.*,com.matrixone.apps.domain.util.MapList" %>

<%
	String  sObjectId	= emxGetParameter(request, "objectId");
	String[] emxTableRowId    = emxGetParameterValues(request,"emxTableRowId");
	if (emxTableRowId==null || sObjectId==null){
	%>

			<script>
			alert("<emxUtil:i18nScript localize="i18nId">emxComponents.MassAssignRoutes.MustSelectOnlyOneStateToAssign</emxUtil:i18nScript>");
			window.close();
		</script>

	<%
		return;
	}

	if (emxTableRowId!=null && emxTableRowId.length>1){
	%>

			<script>
			alert("<emxUtil:i18nScript localize="i18nId">emxComponents.MassAssignRoutes.MustSelectOnlyOneStateToAssign</emxUtil:i18nScript>");
			window.close();
		</script>

	<%
		return;
	}

	String state = (com.matrixone.apps.domain.DomainObject.newInstance(context,sObjectId)).getInfo(context,com.matrixone.apps.domain.DomainObject.SELECT_CURRENT);
	
	
    	for (int j = 0; emxTableRowId!=null && j < emxTableRowId.length; j++) {
		matrix.util.StringList rowList = com.matrixone.apps.domain.util.FrameworkUtil.split(emxTableRowId[j],"^");
		state = (String)rowList.get(1);


			DomainObject affectedItem = new DomainObject(sObjectId);


			com.matrixone.apps.domain.util.MapList relatedReviewRoutesList = affectedItem.getRelatedObjects(context, "Object Route", "Route", null, null, true, true, (short)1, null, "attribute[Route Base State]==state_Review");

			//System.out.println("size()=" + relatedReviewRoutesList.size());
			
			if (relatedReviewRoutesList.size()>0)
			{
%>

		<script>
			alert("<emxUtil:i18nScript 
localize="i18nId">emxComponents.MassAssignRoutes.AlreadyAssignedRoutes</emxUtil:i18nScript>);
			window.close();
		</script>


<%
			}

	           	
	}
	
	session.setAttribute("contentObjectId",sObjectId);
%>
<form name=form1 action="../components/SEMRouteWizardCreateDialogFS.jsp">
	<input type=hidden name=ContentID value="<%=sObjectId%>">
	<input type=hidden name=baseState value="<%=state%>">
	
	<!--   begin     add by tangfan 2015.4.18-->
	<input type=hidden name=init1 value="true">
	<!--   end     add by tangfan 2015.4.18-->
</form>

</body>
<script type="text/javascript">
	
	document.form1.submit();
</script>

</html>
