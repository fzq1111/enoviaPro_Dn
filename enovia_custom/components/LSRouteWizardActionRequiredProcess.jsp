<%--  emxRouteWizardActionRequiredProcess.jsp   -
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteWizardActionRequiredProcess.jsp.rca 1.10 Tue Oct 28 23:01:06 2008 przemek Experimental przemek $
--%>


<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<html>
<head>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
</head>
<body>
</body>

<%
//System.out.println("-------------------------->this is RequiredProcess is page");
  String keyValue=emxGetParameter(request,"keyValue");
  String routeId  = emxGetParameter(request, "objectId");
  String portalMode  = (String)formBean.getElementValue("portalMode");
 // DomainObject routeObject = DomainObject.newInstance(context);
 // DomainObject personObject = DomainObject.newInstance(context);
  DomainRelationship routeNode = null;
  String sAttParallelNodeProcessionRule = PropertyUtil.getSchemaProperty(context, "attribute_ParallelNodeProcessionRule");
  String sourcePage  = (String)formBean.getElementValue("sourcePage");
  if ((sourcePage == null) || sourcePage.equals("null")){
      sourcePage = "";
   }
   String sRadioNames    = emxGetParameter(request, "radioNames");
   String sRouteNodeSecs = emxGetParameter(request, "routeNodeSecs" );

   StringTokenizer sTokNodeSecs = new StringTokenizer(sRouteNodeSecs, "|");
   StringTokenizer sTokRadioNames = new StringTokenizer(sRadioNames, "|");
 
   HashMap parallelNodeMap = new HashMap();
   HashMap radioSelectedMap	= new HashMap();
   while(sTokRadioNames.hasMoreElements()) 
   {
     String sTokRadioName = sTokRadioNames.nextToken().trim();
     String sRadioValue = emxGetParameter(request,sTokRadioName );
     radioSelectedMap.put(sTokRadioName,sRadioValue);
     
     String sNodeIds[] = emxGetParameterValues(request, sTokNodeSecs.nextToken().trim());

     for(int i=0; i <sNodeIds.length; i++){
        String sRouteNodeId = sNodeIds[i];
     	if ("EditAllTasks".equals(sourcePage)) 
	{
           routeNode = DomainRelationship.newInstance(context,sRouteNodeId);
           routeNode.setAttributeValue(context,sAttParallelNodeProcessionRule,sRadioValue);
     	}else{
           parallelNodeMap.put(sRouteNodeId , sRadioValue);
     	}
      }

  }//while
  formBean.setElementValue("radioSelectedMap", radioSelectedMap);
  formBean.setFormValues(session);
  if (!("EditAllTasks".equals(sourcePage))) {
     formBean.setElementValue("parallelNodeMap" , parallelNodeMap);
     formBean.setFormValues(session);

  }
if ("EditAllTasks".equals(sourcePage)) 
{
// Start: Create New Tasks at Current Level
// For edit functionality, the page will be directed to final process page before the dialog will be closed
    formBean.setElementValue("FROM_PAGE" , "EditAllTasks");
  //Added for the Bug No:350789 starts
  Map mapRouteDetails  = (Map)formBean.getElementValue("mapRouteDetails");
  Route boRoute = new Route(routeId);
  String sType = (String)mapRouteDetails.get("sType");
  java.util.Set setKeys = mapRouteDetails.keySet();

  if(setKeys.contains("sType")) {
	  setKeys.remove("sType");
  }

  Iterator itrKeys = setKeys.iterator();
  while(itrKeys.hasNext()) {
	  Relationship relGeneric = (Relationship)itrKeys.next();
	  AttributeList attrListGeneric = (AttributeList)mapRouteDetails.get(relGeneric);
	  String sRelId = relGeneric.toString();

	  if ( sType.equals(DomainConstants.TYPE_ROUTE) || sType.equals(DomainConstants.TYPE_ROUTE_TEMPLATE) ) {
		 relGeneric.open(context);
         relGeneric.setAttributes(context, attrListGeneric);
		 
         if ( sType.equals(DomainConstants.TYPE_ROUTE) ) {
           AttributeItr attrItr = new AttributeItr(attrListGeneric);
           AttributeList attrList1 = new AttributeList();
           attrItr.reset();
           while (attrItr.next()) {
             String sAttrName = attrItr.obj().getName();
             // Added check for attribute Scheduled Completion Date. If the value of the date is blank, then dont add, retain DB value. 
             if(sAttrName.equals(DomainConstants.ATTRIBUTE_SCHEDULED_COMPLETION_DATE)){
            	 String sAttrValue = attrItr.obj().getValue();
            	 if("".equals(sAttrValue))
            		 continue;
             }
             if (!sAttrName.equals(DomainConstants.ATTRIBUTE_ROUTE_SEQUENCE)) {
               attrList1.addElement(attrItr.obj());
             }
           }

           Pattern relPattern                = new Pattern(DomainConstants.RELATIONSHIP_ROUTE_TASK);
           Pattern typePattern               = new Pattern(DomainConstants.TYPE_INBOX_TASK);

           ExpansionWithSelect projectSelect     = null;
           RelationshipWithSelectItr relItrTask  = null;

           SelectList selectStmts    = new SelectList();
           selectStmts.addName();
           selectStmts.addDescription();
           SelectList selectRelStmts = new SelectList();
           projectSelect = boRoute.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(), selectStmts, selectRelStmts,true,false,(short)1);
           boRoute.close(context);
           relItrTask = new RelationshipWithSelectItr(projectSelect.getRelationships());
           BusinessObject boTask               = null;
           String sRouteNodeID  = "";

           while (relItrTask != null && relItrTask.next()) {
             boTask = relItrTask.obj().getFrom();
             boTask.open(context);
             sRouteNodeID = (String)JSPUtil.getAttribute(context,session,boTask,DomainConstants.ATTRIBUTE_ROUTE_NODE_ID);

             if ( sRelId.equals(sRouteNodeID) ) {
               boTask.setAttributes(context,attrList1);
               break;
             }
             boTask.close(context);
           }
         }
         relGeneric.close(context);
       }
  }
  //Added for the Bug No:350789 ends.
// Start: Create New Tasks at Current Level
} 
else 
{
   Map paramMap = (Map)formBean.getElementValue("strParams");
    if (paramMap != null){
      Iterator keyItr = paramMap.keySet().iterator();
      while (keyItr.hasNext()){
        String name = (String) keyItr.next();
        String value = (String) paramMap.get(name);
        request.setAttribute(name, value);
      }
    }
 
    formBean.removeElement("strParams");

}
%>

<script language="javascript">
submitWithCSRF("LSRouteWizardFinalProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&objectId=<%=XSSUtil.encodeForURL(context, routeId)%>", window);
  
</script>

</html>



