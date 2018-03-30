<%@page import="com.matrixone.apps.common.Route"%>
<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "../components/emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>


<%
	
	String selectId = emxGetParameter(request, "selectId");
	StringList splitList =  FrameworkUtil.split(selectId,"_");
	String routeId = (String)splitList.get(1);
	String attrValue = (String)splitList.get(2);
	attrValue = attrValue.substring(0,1);

	DomainObject routeObj =new DomainObject(routeId);
	StringList busList = new StringList("id");
	StringList relList = new StringList("id[connection]");
	MapList routeNodeList = routeObj.getRelatedObjects(context, DomainObject.RELATIONSHIP_ROUTE_NODE,
												"*",
												busList, relList, 
												false, true,
												(short)1, "",
												"");
												String deleteId="";
	for(int orderIndex = 0 ;orderIndex < routeNodeList.size();orderIndex++)
	{
		Map tempSeqMap = (Map)routeNodeList.get(orderIndex);
		String relId = (String)tempSeqMap.get("id[connection]");
		DomainRelationship relObj = new DomainRelationship(relId);
		String strSequence = relObj.getAttributeValue(context,"Route Sequence"); 
		if(attrValue.equals(strSequence))
		{
			deleteId = relId;
		}
	}
	try{
	DomainRelationship delRelObj = new DomainRelationship(deleteId);
	delRelObj.open(context);
	  ContextUtil.pushContext(context);	
	
	 delRelObj.remove(context);	 
	  ContextUtil.popContext(context);
	  delRelObj.close(context);
	}catch(Exception e){
		throw new Exception(e.getMessage());
	}
%>	
<script>
	
	parent.location.href=parent.location.href;
	top.close();
</script>