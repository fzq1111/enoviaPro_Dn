<%--  LSLifecycleRemoveRoute.jsp  --%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>


<!-- Java script functions -->

<%@include file="../emxUICommonHeaderEndInclude.inc"%>
<%@ page import = "com.matrixone.apps.common.Lifecycle" %>
<!-- Page display code here -->
<%@ page import = "org.apache.log4j.Logger"%>

<%
	Logger myLogger = Logger.getLogger(LSLifecycleRemoveRoute_jsp.class);
    try {
	    String jsTreeID = emxGetParameter(request,"jsTreeID");
	    String suiteKey = emxGetParameter(request,"suiteKey");
	    
	    // Get the id of the object in context
	    String strObjectId = emxGetParameter(request,"objectId");
	    DomainObject domObj = DomainObject.newInstance(context, strObjectId);
		
		StringList busList = new StringList(DomainObject.SELECT_ID);
		busList.addElement("attribute[Route Status]");
 		StringList relList = new StringList(DomainRelationship.SELECT_ID);
		MapList routeList = domObj.getRelatedObjects(context,"Object Route","Route", busList, relList, false,true, (short)1, null, null);
	    
        ContextUtil.startTransaction(context, true);
        for(int i = 0; i < routeList.size(); i ++)
		{
			Map routeMap = (Map)routeList.get(i);
			String strRelId = (String)routeMap.get(DomainRelationship.SELECT_ID);
			DomainRelationship.disconnect(context, strRelId);
		}
%>
		<script language="javascript">
			window.parent.parent.location.href = window.parent.parent.location.href;
		</script>
<%        
		ContextUtil.commitTransaction(context);

    } catch (Exception ex) {
        ContextUtil.abortTransaction(context);
        myLogger.error(ex.getMessage(), ex);
%>
		
        <script language="javascript">
        	//XSSOK
			alert("<%=FrameworkUtil.findAndReplace(ex.getMessage(),"\n", "\\\n")%>");
        </script>
<%
    } 
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>
