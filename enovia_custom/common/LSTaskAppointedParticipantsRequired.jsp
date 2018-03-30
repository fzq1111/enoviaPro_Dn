<%@page import="com.matrixone.apps.common.Route"%>
<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "../components/emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%
try{
	DomainRelationship routeNode = null;
	//Route.removeRouteMembers(arg0, arg1, arg2)
	String sAttParallelNodeProcessionRule = PropertyUtil.getSchemaProperty(context, "attribute_ParallelNodeProcessionRule");
	String sourcePage  = emxGetParameter(request,"sourcePage");
	if ((sourcePage == null) || sourcePage.equals("null")){
	    sourcePage = "";
	}
	
	String strTaskNameValue = "";  
	String strRouteNodeValue = "";
	String sRouteNodeId = "";
	
	String radioActionKey = "";
	String strRadioActionValue = "";
//	String attrReviewTask = DomainObject.ATTRIBUTE_REVIEW_TASK;//need review 
//	String attrDueDateOffset = DomainObject.ATTRIBUTE_DUEDATE_OFFSET;//kai shi hou de tianshu 
//	String attrScheduledCompletionDate = DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE;//di yi lie shijian she zhi
//	String attrDateOffsetForm = DomainObject.ATTRIBUTE_DATE_OFFSET_FROM;//kai shi shijian 
	String attrTitle = DomainObject.ATTRIBUTE_TITLE;
	String attrAssigneeSetDueDate = DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE; //fen pai ren xuan shijian 
	String attrRouteSquence = DomainObject.ATTRIBUTE_ROUTE_SEQUENCE;//xu hao
	String attrRouteInstructions = DomainObject.ATTRIBUTE_ROUTE_INSTRUCTIONS;//zhi ling
	String attrRouteAction = DomainObject.ATTRIBUTE_ROUTE_ACTION;//caozuo
	String attrAllowDelegation = DomainObject.ATTRIBUTE_ALLOW_DELEGATION;//wei tuo
	
	String attrTaskTitleKey = "";
	String attrAssigneeSetDueDateKey = "";
	String attrRouteSquenceKey="";
	String attrRouteInstructionsKey="";
	String attrRouteActionKey="";
	String attrAllowDelegationKey="";
	
	String attrRouteActionValue = "";
	String attrRouteInstrucValue = "";
	
	String strRouteNodeIdValue = "";
	String strPersonIdValue = "";
	
	String strFinishCheckerkey = "";
	String strFinishCheckerValue = "";

	String strCH_AllowReAsignkey = "";
	String strCH_AllowReAsignValue = "";
	
	Attribute attrObj = null;
	AttributeList attrRouteNodeList = null;
	AttributeList attrTaskList = null;
	HashMap attrKeyValueMap = null;
	
	StringList creatPersonid = null;
	StringList addPersonMember = null;
	HashMap deleteMember = null;
	
	boolean modifyFalge = true;
	String routeId = "";
	String routeSequenceNumber = "";
	String routeNodeIds = "";
	String [] routeIdList = emxGetParameterValues(request, "routeId");
	for(int i  =0;i<routeIdList.length;i++)
	{
		routeId = routeIdList[i];
		
		StringList slMergeList = (StringList) session.getAttribute("Sequence_"+routeId.trim());
		session.removeAttribute("Sequence_"+routeId.trim());
		if(slMergeList != null && slMergeList.size() > 0)
		{
			for(int i2 = 0 ;i2 < slMergeList.size(); i2++)
			{
				
				String strMerge = (String) slMergeList.get(i2);
				String strSuffix = routeId+"_"+strMerge;
				String strModifyFalge = emxGetParameter(request,"modifyTask_"+strSuffix);
				
				//String FinishChecker = emxGetParameter(request,"FinishChecker_"+strSuffix);
				
				attrRouteNodeList = new AttributeList();
				strCH_AllowReAsignkey = "CH_AllowReAsign_"+strSuffix;
				 strCH_AllowReAsignValue = emxGetParameter(request, strCH_AllowReAsignkey);
				if(strCH_AllowReAsignValue == null){ 
					strCH_AllowReAsignValue="";
				}
				if(strCH_AllowReAsignValue.length()>0){
					attrObj = new Attribute(new AttributeType("LS Allow ReAssign"),strCH_AllowReAsignValue);
					attrRouteNodeList.add(attrObj); 
				
				}
				
				
				//attrRouteNodeList = new AttributeList();
				 strFinishCheckerkey = "FinishChecker_"+strSuffix;
				strFinishCheckerValue = emxGetParameter(request, strFinishCheckerkey);
				if(strFinishCheckerValue == null){ 
					strFinishCheckerValue="";
				}
				//attrObj = new Attribute(new AttributeType("TMT Route Task Finish Checker"),strFinishCheckerValue);
				//attrRouteNodeList.add(attrObj); 
				
				modifyFalge = Boolean.parseBoolean(strModifyFalge);
				if(!modifyFalge){
					continue;
				} 
				String strSequence = emxGetParameter(request,"sequence_"+strSuffix);
				attrObj = new Attribute(new AttributeType(attrRouteSquence),strSequence);
				attrRouteNodeList.add(attrObj);
				
				attrTaskTitleKey = "taskName_"+strSuffix;
				strTaskNameValue = emxGetParameter(request, attrTaskTitleKey);
				if(strTaskNameValue == null) strTaskNameValue="";
				attrObj = new Attribute(new AttributeType(attrTitle),strTaskNameValue);
				attrRouteNodeList.add(attrObj);
				
				attrRouteActionKey = "routeAction_"+strSuffix;
				attrRouteActionValue = emxGetParameter(request, attrRouteActionKey);
				if(attrRouteActionValue == null) attrRouteActionValue="";
				attrObj = new Attribute(new AttributeType(attrRouteAction),attrRouteActionValue);
				attrRouteNodeList.add(attrObj);
				
				attrRouteInstructionsKey = "routeInstructions_"+strSuffix;
				attrRouteInstrucValue = emxGetParameter(request, attrRouteInstructionsKey);
				if(attrRouteInstrucValue == null) attrRouteInstrucValue="";
				attrObj = new Attribute(new AttributeType(attrRouteInstructions),attrRouteInstrucValue);
				attrRouteNodeList.add(attrObj);
				
				routeNodeIds = emxGetParameter(request,"strRouteNodeIds_"+strSuffix);
				StringList strRouteNodeIds = FrameworkUtil.split(routeNodeIds, "|");
				
				String sAttParallValue = emxGetParameter(request, "radioAction_"+routeId + "_" +strSequence);
				attrObj = new Attribute(new AttributeType(sAttParallelNodeProcessionRule),sAttParallValue);
				attrRouteNodeList.add(attrObj);
				
				for(int i3 = 0;i3<strRouteNodeIds.size();i3++)
				{
					String strRouteNodeIdsValue = (String)strRouteNodeIds.get(i3);
					modifyTask(context, strRouteNodeIdsValue, attrRouteNodeList);
			    }
				
				attrObj = new Attribute(new AttributeType(attrAssigneeSetDueDate),"Yes");
				attrRouteNodeList.add(attrObj);
				
				
				attrObj = new Attribute(new AttributeType(attrAllowDelegation),"TRUE");
				attrRouteNodeList.add(attrObj);
				
				
				String [] personRoutNode = emxGetParameterValues(request, "personId_"+strSuffix);
				
				for(int i4= 0;i4<personRoutNode.length;i4++)
				{
					String routePersonId[] = personRoutNode[i4].split("~");
					if(routePersonId[0] == null || routePersonId[0].trim().equals("") || routePersonId[0].trim().equals("null")){
						CreateRouteNode(context, routePersonId[2], routeId, attrRouteNodeList);
					}
				}
				
				for(int i3 = 0;i3<strRouteNodeIds.size();i3++)
				{
					String strRouteNodeIdsValue = (String)strRouteNodeIds.get(i3);
					boolean falge = false;
					for(int i4= 0;i4<personRoutNode.length;i4++){
						String routePersonId[] = personRoutNode[i4].split("~");
						if(routePersonId[0].equals(strRouteNodeIdsValue)){
							falge = true;
						}
					}
					if(!falge){
						DeleteTask(context, strRouteNodeIdsValue, routeId, "");
					}
			   	}
			}
		}
	}
}catch(Exception e){
	e.printStackTrace();
}
%>
<Script type = "text/javascript">
top.opener.location.href = top.opener.location.href;
window.top.close();
</script>
<%!
	public static  void DeleteTask(Context context,String relationshipId,String routeId,String taskId)throws Exception{
    	//End: Resume Process Modifications
        try {
        	if(routeId != null && !routeId.equals("") && !routeId.equals("null")){
	            //Start: Resume Process Modifications
	        	final String SELECT_TASK_ASSIGNEE_ID = "from[" + DomainObject.RELATIONSHIP_PROJECT_TASK + "].to.id";
	        	final String SELECT_ATTRIBUTE_ROUTE_NODE_ID = "attribute[" + DomainObject.ATTRIBUTE_ROUTE_NODE_ID + "]";
	            // Find the tasks connected to route object but which are not connected to the person object (sideeffect of Resume Process)
	            Route objRoute = (Route)DomainObject.newInstance(context, DomainObject.TYPE_ROUTE);
	            objRoute.setId(routeId);
	            StringList slBusSelect = new StringList(DomainObject.SELECT_ID);
	            slBusSelect.add(SELECT_ATTRIBUTE_ROUTE_NODE_ID);
	            slBusSelect.add(SELECT_TASK_ASSIGNEE_ID);
	            StringList slRelSelect = new StringList();
	            MapList mlRouteTasks = objRoute.getRouteTasks(context, slBusSelect, slRelSelect, null, false);
	            // Filter the tasks for partially connected tasks
	            MapList mlPartialTasks = new MapList();
	            Map mapPartialTask = null;
	            for (Iterator itrRouteTasks = mlRouteTasks.iterator(); itrRouteTasks.hasNext();) {
	                mapPartialTask = (Map)itrRouteTasks.next();
	                if (mapPartialTask.get(SELECT_TASK_ASSIGNEE_ID) == null) {
	                    mlPartialTasks.add(mapPartialTask);
	                }
	            }
	            //mlRouteTasks = null;
	        //End: Resume Process Modifications
	            if(relationshipId!= null && !relationshipId.trim().equals("") && !relationshipId.equals("null")){	
		              Relationship relationship = new Relationship(relationshipId.trim());
		              // Modified on Oct 12 2007 to remove already deleted relation id's from the req parameter "newTaskIds"
		              // End of modification on Oct 12 2007 to remove already deleted relation id's from the req parameter "newTaskIds"
		              relationship.open(context);
		              ContextUtil.pushContext(context);
		              relationship.remove(context);
					  ContextUtil.popContext(context);
		              relationship.close(context);
		              if(taskId!= null && !taskId.trim().equals("") && !taskId.equals("null")){
				            BusinessObject boTask = new BusinessObject(taskId);
				             // Modified on Oct 12 2007 to remove already deleted task id's from the req parameter "newTaskIds" 
				            taskId = taskId.trim();
				             // End of modification on Oct 12 2007 to remove already deleted task id's from the req parameter "newTaskIds"
				            boTask.open(context);
				            boTask.remove(context);
				            boTask.close(context);
		              }
		              //
		              // Due to Resume Process implememtation, there can be tasks which are connected to route object but not connected to
		              // the person object, these tasks are reused in next reassignment. When the route node relationship will be removed,
		              // such tasks must also be deleted.
		              //
		              for (Iterator itrPartialTasks = mlPartialTasks.iterator(); itrPartialTasks.hasNext();) {
		                    mapPartialTask = (Map)itrPartialTasks.next();
		                    if (relationshipId.equals((String)mapPartialTask.get(SELECT_ATTRIBUTE_ROUTE_NODE_ID))) {
		                        DomainObject.deleteObjects(context, new String[]{(String)mapPartialTask.get(DomainObject.SELECT_ID)});
		                    }
		              }
		              //edit by heyanbo 2014-6-10
		              for (Iterator itrRouteTasks = mlRouteTasks.iterator(); itrRouteTasks.hasNext();) {
			                mapPartialTask = (Map)itrRouteTasks.next();
			                if (relationshipId.equals((String)mapPartialTask.get(SELECT_ATTRIBUTE_ROUTE_NODE_ID)) 
			                		&& mapPartialTask.get(SELECT_TASK_ASSIGNEE_ID) != null) {
		                        DomainObject.deleteObjects(context, new String[]{(String)mapPartialTask.get(DomainObject.SELECT_ID)});
		                    }
			           }
		            //edit by heyanbo 2014-6-10
	            }
	          //Uncommented the commented code on Oct 12th 2007 since need this logic for Route template -  delete task to work and for adjusting the order of Task seq no. in Routes after deleting other tasks.
	          if(routeId != null && !"".equals(routeId))
	          {
	            DomainObject domRoute = DomainObject.newInstance(context , routeId);
	            if(domRoute.getType(context).equals(DomainConstants.TYPE_ROUTE)){
	              Route routeObect =(Route)domRoute;
	              routeObect.adjustSequenceNumber(context);//Rearranges the Sequence Number of the Route Node Ids when the Sequence has been disturbed. 
	            }
	          }
	          //Uncommented the code on Oct 12th 2007 since need this logic for Route template -  delete task to work and for adjusting the order of Task seq no. in Routes after deleting other tasks.
        	}
        } catch (Exception ex ){
        	ex.printStackTrace();
        }
	}
	
	public String CreateRouteNode(Context context,String personId,String routeId,AttributeList attrList)throws Exception{
		//only Create Route Node
		//DomainObject routeObject     = DomainObject.newInstance(context);
		Route routeObject = new Route();
		DomainObject personObject     = DomainObject.newInstance(context);
		routeObject.setId(routeId);
		routeObject.open(context);
		personObject.setId(personId);
		personObject.open(context);
		
		MapList tskMapList = null;
	   StringList existedMemberList = new StringList();
	   String sRouteNode = PropertyUtil.getSchemaProperty(context, "relationship_RouteNode");
	   Pattern typePattern = new Pattern(DomainObject.TYPE_PERSON);
	    typePattern.addPattern(DomainObject.TYPE_ROUTE_TASK_USER);
	    Pattern relPattern = new Pattern(sRouteNode);
	    StringList selectTypeStmts = new StringList();
	    selectTypeStmts.add(DomainObject.SELECT_ID);
	    selectTypeStmts.add(DomainObject.SELECT_TYPE);
	    StringList selectRelStmts = new StringList();
	    selectRelStmts.add(DomainObject.SELECT_RELATIONSHIP_ID);
	    selectRelStmts.add("attribute["+DomainObject.ATTRIBUTE_ROUTE_SEQUENCE+"]");
	    selectRelStmts.add("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
	   tskMapList = routeObject.getRelatedObjects(context,
									               relPattern.getPattern(),  //String relPattern
									               typePattern.getPattern(), //String typePattern
									               selectTypeStmts,          //StringList objectSelects,
									               selectRelStmts,                     //StringList relationshipSelects,
									               false,                    //boolean getTo,
									               true,                     //boolean getFrom,
									               (short)1,                 //short recurseToLevel,
									               "",                       //String objectWhere,
									               "",                       //String relationshipWhere,
									               null,                     //Pattern includeType,
									               null,                     //Pattern includeRelationship,
									               null);                    //Map includeMap

		tskMapList.sort("attribute["+DomainObject.ATTRIBUTE_ROUTE_SEQUENCE+"]","ascending","integer");
		Iterator tskMapListItr = tskMapList.iterator();
		while(tskMapListItr.hasNext()){
			Map taskMap = (Map)tskMapListItr.next();
			if(DomainConstants.TYPE_ROUTE_TASK_USER.equals(taskMap.get(DomainConstants.SELECT_TYPE))){
				existedMemberList.add(PropertyUtil.getSchemaProperty(context,taskMap.get("attribute["+DomainConstants.ATTRIBUTE_ROUTE_TASK_USER+"]").toString()));
			}else{
				existedMemberList.add(taskMap.get(DomainConstants.SELECT_ID));
			}
		}
					
		DomainRelationship taskRouteNode = routeObject.connectTo(context,DomainObject.RELATIONSHIP_ROUTE_NODE, personObject);
		taskRouteNode.setAttributeValues(context, attrList);
	/* String basePurpose=(String) routeObject.getInfo(context,SELECT_ROUTE_BASE_PURPOSE);
         if(basePurpose.equals("Approval"))
       	 taskRouteNode.setAttributeValue(context,routeActionStr,"Approve"); */
		if(!existedMemberList.contains(personId)){
	       	addPesonToRoute(context,"Person",routeObject,null,routeObject.getTypeName(),new String[]{personId},routeId);
		}
		routeObject.close(context);
		personObject.close(context);
		return taskRouteNode.toString();
	}
	
	public static void modifyTask(Context context,String relRouteNodeId,AttributeList attrList)throws Exception{
		DomainRelationship routeNodeRel = new DomainRelationship(relRouteNodeId);
		routeNodeRel.setAttributeValues(context, attrList);
	}
%>
<%!
     public void addPesonToRoute(matrix.db.Context context,String memberType, Route routeObject, RouteTemplate routeTemplateObject, String objType, String[] memberID, String sRouteId) throws MatrixException
  {
   try
   {
	DomainObject personObject = null;
    if(DomainConstants.TYPE_PERSON.equals(memberType))
    {
        //<Fix 372839>
        java.util.Set granteeSet = new HashSet();
        //</Fix 372839>
	    for(int count =0; count < memberID.length; count++ ) {
	      	String typePersonId = memberID[count];
		      personObject = DomainObject.newInstance(context , typePersonId);
               //<Fix 372839>
               granteeSet.add(personObject.getName(context));
  		   //</Fix 372839>                   
	     }

    //<Fix 372839>
    if(objType.equals(DomainConstants.TYPE_ROUTE)) {
        routeObject.setId(sRouteId);
        routeObject.grantAccessOnContent(context, (String[])granteeSet.toArray(new String []{}));
    }
    //</Fix 372839>    
    }
  }catch(Exception e){}
}// End method
%>
