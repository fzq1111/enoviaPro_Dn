<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@page language="java" pageEncoding="UTF-8"%>
<%
  StringList busList = new StringList("id");
  StringList relList = new StringList(DomainRelationship.SELECT_ID);
  String mode=(String)emxGetParameter(request,"mode");
  String strRelName = emxGetParameter(request,"relName");
  if("addExisting".equals(mode))
  {
	    strRelName=PropertyUtil.getSchemaProperty(context,strRelName);
		String errorMsg = "";
		try{
			String objectId=(String)emxGetParameter(request,"objectId");
			DomainObject strFromObj = new DomainObject(objectId);
			String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
			for(int i=0;i<emxTableRowId.length;i++)
			{
				String[] splitValue = emxTableRowId[i].split("\\|");
			    Map<String,String> mplist=new HashMap<String,String>();
				String strObjId = splitValue[1];
				DomainObject strObj = new DomainObject(strObjId);
				String strName = strObj.getName(context);
				MapList mapList = strObj.getRelatedObjects(context,strRelName, "*", busList, relList,true,false,(short)1, null, null);
				if(mapList.size()>0)
				{
					Iterator it = mapList.iterator();
					while(it.hasNext()){
						Map map = (Map)it.next();
						String id=(String)map.get("id");
						mplist.put(id,id);
					}
				}
				if(mplist.containsValue(objectId)){
					
				}else{
					ContextUtil.pushContext(context);
					DomainRelationship rel=strFromObj.connectTo(context,strRelName,strObj);				
					ContextUtil.popContext(context);
				}
			}
		}catch(Exception e){
			String msg = e.getMessage();
			throw new Exception(msg);
		}
%>
		<script>
		 window.top.opener.location.href = window.top.opener.location.href;
		 window.top.close();
		</script>
<%				
   }else if("SEMPRaddExisting".equals(mode)){
	    strRelName=PropertyUtil.getSchemaProperty(context,strRelName);
		String errorMsg = "";
		try{
			Map<String,String> mplist=new HashMap<String,String>();
		    ContextUtil.pushContext(context);
			String objectId=(String)emxGetParameter(request,"objectId");
			DomainObject strFromObj = new DomainObject(objectId);
		    MapList mapList = strFromObj.getRelatedObjects(context,strRelName,"Task Management", busList, relList,false,true,(short)1, null, null);
			if(mapList.size()>0)
			{
					Iterator it = mapList.iterator();
					while(it.hasNext()){
						Map map = (Map)it.next();
						String id=(String)map.get("id");
						mplist.put(id,id);
					}
			}
			String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
			for(int i=0;i<emxTableRowId.length;i++)
			{
				String[] splitValue = emxTableRowId[i].split("\\|");
				String strObjId = splitValue[1];
				DomainObject strObj = new DomainObject(strObjId);
				if(mplist.containsValue(strObjId)){
					
				}else{
					DomainRelationship rel=strFromObj.connectTo(context,strRelName,strObj);		
			    }
			    StringList affectedTaskIdList =strObj.getInfoList(context,"to[Dependency].from.id");
			    if(affectedTaskIdList.size()>0)
			    {
				  for(int j=0;j< affectedTaskIdList.size();j++)
				  {
					String affectedTaskId = (String)affectedTaskIdList.get(j);
			        DomainObject affectedTaskObj= new DomainObject(affectedTaskId );
					if(!mplist.containsValue(affectedTaskId)){
					   strFromObj.connectTo(context,strRelName,affectedTaskObj);	
				    }
			      }
		        }
			}				
			
		}catch(Exception e){
			String msg = e.getMessage();
			throw new Exception(msg);
		}finally{
			ContextUtil.popContext(context);
		}
%>
		<script>
		 window.top.opener.location.href = window.top.opener.location.href;
		 window.top.close();
		</script>
<%				
   }else if(mode.equals("removeRelationship")){
       String objectId = emxGetParameter(request,"objectId");
		DomainObject strFromObj = new DomainObject(objectId);
		String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue = emxTableRowId[i].split("\\|");
			String sRelationshipIds = splitValue[0];
			ContextUtil.pushContext(context);
			DomainRelationship.disconnect(context, sRelationshipIds);
			ContextUtil.popContext(context);
		}
%>
<!-- 刷新父页面 -->
<script type="text/javascript">
  parent.location.href=parent.location.href;
</script>
<%  }else if(mode.equals("Delete")){
	  String emxTableRowId[]=emxGetParameterValues(request,"emxTableRowId");
	  for(int i=0;i<emxTableRowId.length;i++){
		 String[] splitValue = emxTableRowId[i].split("\\|");
		 String strObjId=splitValue[1];
		 DomainObject strObj=new DomainObject(strObjId);
		 ContextUtil.pushContext(context);
		 strObj.delete(context);
		 ContextUtil.popContext(context);
	  } 
	 %>
	 <!-- 刷新父页面 -->
   <script type="text/javascript">
     parent.location.href=parent.location.href;
   </script>
<%	 
}else if(mode.equals("IRIaddExisting")){
    String preRowId=request.getParameter("preRows");
	String[] preRowIds=preRowId.split("\\|");
	String emxTableRowId[]=emxGetParameterValues(request,"emxTableRowId");
	String[] splitValue =emxTableRowId[0].split("\\|");
	String strObjId=splitValue[1];
	DomainObject strObj=new DomainObject(strObjId);
	if(!strObj.getType(context).equals("Cost Item")){
%>
	<script>
     alert("\u6240\u9009\u62E9\u7684\u5217\u5FC5\u987B\u662F\u6295\u8D44\u9879\uFF0C\u8BF7\u91CD\u65B0\u9009\u62E9!");
	 window.top.opener.location.href = window.top.opener.location.href;
	 window.top.close();
    </script>
<%		
	}else{
	    String planCost=strObj.getAttributeValue(context,"Planned Cost");
	    double doublePlanCost = Double.parseDouble(planCost);
	    MapList CQList=strObj.getRelatedObjects(context,"SEM CostRequest Budget","*",busList,relList,false,true,(short)1,"" ,"");
	    Iterator x = CQList.iterator();
	    double budgetCost1=0.0;
	    while(x.hasNext())
	    {
			Map map2 = (Map)x.next();
			String CQId = (String)map2.get("id");
			DomainObject CQObj = new DomainObject(CQId);
			String strContractCost = CQObj.getAttributeValue(context,"SEM Contract Amount");
			double doubleContractCost = Double.parseDouble(strContractCost);
			String strRequestCost = CQObj.getAttributeValue(context,"SEM Request Amount");
			double doubleRequestCost = Double.parseDouble(strRequestCost);
			if(doubleContractCost==0.0)
			{
				budgetCost1 +=doubleRequestCost;
			}else{
				budgetCost1 +=doubleContractCost;
			}
	    }
	    double tzyeValue=doublePlanCost - budgetCost1;
		double sqjeValue=0.0;
		for(int j=0;j<preRowIds.length;j++)
	    {
			  String[]  preSplitValue1=preRowIds[j].split(",");
			  String  preId1=preSplitValue1[1];
              DomainObject SEMCostRequestObj= new DomainObject(preId1);
              String strContractCost1 =SEMCostRequestObj.getAttributeValue(context,"SEM Contract Amount");
			  double doubleContractCost1 = Double.parseDouble(strContractCost1);
			  String strRequestCost1=SEMCostRequestObj.getAttributeValue(context,"SEM Request Amount");
			  double doubleRequestCost1= Double.parseDouble(strRequestCost1);
			  if(doubleContractCost1==0.0)
			  {
				sqjeValue+=doubleRequestCost1;
			  }else{
				sqjeValue+=doubleContractCost1;
			  }
	     }
		 if(sqjeValue>tzyeValue){
%>
	<script>
     alert("\u4F59\u989D\u4E0D\u8DB3!");
	 window.top.opener.location.href = window.top.opener.location.href;
	 window.top.close();
    </script>
<%				 	 
		 }else{
		
		
	      Vector vc=new Vector();
	      MapList mapList = strObj.getRelatedObjects(context,"SEM CostRequest Budget", "*",busList,relList,false,true,(short)1, null, null);
	      if(mapList.size()>0)
	      {
	          Iterator it = mapList.iterator();
	          while(it.hasNext()){
			    Map map = (Map)it.next();
			    String id=(String)map.get("id");
			    vc.add(id);
		     }
	      }
		  try{
	         ContextUtil.pushContext(context);
	         for(int i=0;i<preRowIds.length;i++)
	         {
			  String[]  preSplitValue=preRowIds[i].split(",");
			  String  relId=preSplitValue[0];
			  String  preId=preSplitValue[1];		
			  DomainRelationship.disconnect(context,relId);	
			  if(!vc.contains(preId)){
				DomainObject toObj=new DomainObject(preId);
				strObj.connectTo(context,"SEM CostRequest Budget",toObj);
			  }
	         }
		  }finally{
	         ContextUtil.popContext(context);
		  }		  
%>
		<script>
		 window.top.opener.location.href = window.top.opener.location.href;
		 window.top.close();
		</script>
<%
		 }
	}	
}else if(mode.equals("SEMIRIaddExisting")){
	String emxTableRowId[] = emxGetParameterValues(request,"emxTableRowId");
	String objectId=(String)emxGetParameter(request,"objectId");
	StringBuffer qStringBuff= new StringBuffer();
    for(int i=0;i<emxTableRowId.length;i++)
	{
		String[] splitValue = emxTableRowId[i].split("\\|");
		String relObjId=splitValue[0];
		String strObjId =splitValue[1];
		
		if(i==emxTableRowId.length-1){
			qStringBuff.append(relObjId+","+strObjId);
		}else{
			qStringBuff.append(relObjId+","+strObjId+"|");
		}
	}
	String rows=qStringBuff.toString();
	String url="emxFullSearch.jsp?field=TYPE=type_CostItem&showInitialResults=false&HelpMarker=emxhelpfullsearch&table=AEFGeneralSearchResults&selection=single&includeOIDprogram=SEMInvestmentManagement:getCurrentProjectSpace&objectId="+objectId+"&submitURL=SEMConnectExisting.jsp?mode=IRIaddExisting";
%>
<html>
 <body>
    <form method="post" id="myform" action="<%=url%>">
       <input type="hidden"  id="preRows"  name="preRows" value="<%=rows%>">
    </form>
 </body>
</html>
	<script type="text/javascript">
        document.getElementById('myform').submit();
    </script>
<%
}else if(mode.equals("InvestmentCreateBCR")){
	String emxTableRowId[]=emxGetParameterValues(request,"emxTableRowId");
	String objectId=request.getParameter("objectId");
	String errorMsg="";
	StringBuffer qStringBuff= new StringBuffer();
    for(int i=0;i<emxTableRowId.length;i++)
	{
		String[] splitValue = emxTableRowId[i].split("\\|");
		String relObjId=splitValue[0];
		String strObjId =splitValue[1];
		DomainObject strFromObj = new DomainObject(strObjId);
		String strName1 = strFromObj.getName(context);
		MapList mapList = strFromObj.getRelatedObjects(context,"SEM Affected Budget","SEM BudgetChange Request",busList,relList,true,false,(short)1,"","");
		if(mapList.size()>0){
			Iterator items=mapList.iterator();
			while(items.hasNext()){
				Map map=(Map) items.next();
				String strSBRId=(String)map.get("id");
				DomainObject semBRObj = new DomainObject(strSBRId);
				String strName2 = semBRObj.getName(context);
				String strCurrent = semBRObj.getInfo(context, DomainObject.SELECT_CURRENT);				
				if(!"Complete".equals(strCurrent) && !"Cancel".equals(strCurrent)){
					errorMsg= "\u6295\u8d44\u9879\u0020"+strName1+"\u0020\u5df2\u5173\u8054\u672a\u5b8c\u6210\u7684\u6295\u8d44\u8c03\u6574\u5355\u0020"+strName2+"\uff01";									
				}
			}
		}	
		if(!strFromObj.getType(context).equals("Cost Item")){
			errorMsg="\u6240\u9009\u5BF9\u8C61\u7684\u7C7B\u578B\u5FC5\u987B\u5168\u90E8\u4E3A\u6295\u8D44\u9879\uFF0C\u8BF7\u91CD\u65B0\u9009\u62E9\uFF01";
			break;
		}
		if(i==emxTableRowId.length-1){
			qStringBuff.append(strObjId);
		}else{
			qStringBuff.append(strObjId+"|");
		}
	}
	String rows=qStringBuff.toString();
	String url="emxCreate.jsp?type=type_SEMBudgetChangeRequest&policy=policy_SEMBudgetChangeRequest&form=type_CreateSEMBudgetChangeRequest&nameField=both&createJPO=SEMACO:investmentCreateNewBCR&relationship=relationship_SEMProjectChange&header=emxFramework.Common.CreateBudgetChangeRequest&submitAction=treeContent";
    if(errorMsg==""){
%>
<html>
 <body>
    <form method="post" id="myform" action="<%=url%>">
       <input type="hidden"  id="preRows"  name="preRows" value="<%=rows%>">
	   <input type="hidden"  id="objectId"  name="objectId"   value="<%=objectId%>">
    </form>
 </body>
</html>
	<script type="text/javascript">
        document.getElementById('myform').submit();
    </script>
<%			
}else{
%>
   		<script>
		    alert("<%=errorMsg%>");
		    window.top.opener.location.href = window.top.opener.location.href;
		    window.top.close();
		</script>
<%
    }	
}else if(mode.equals("CreateSEMPartTask")){
	String selectedNodeId = emxGetParameter(request, "emxTableRowId");
	String[] rows=selectedNodeId.split("\\|");
	DomainObject obj=new DomainObject(rows[1]);
	String type=obj.getType(context);	
    if(type.equals("Project Space")){
		MapList checklist = obj.getRelatedObjects(context, "SEM Project PartTask,SEM SubPart","SEM Part Task", busList, relList,false,true, (short)2, null, null);
		if(checklist.size() != 0)
		{
			%>
				   <script language="javascript" type="text/javaScript">
				   alert("\u8be5\u9879\u76ee\u4e0b\u5df2\u6709\u96f6\u4ef6\u4efb\u52a1\uff0c\u8bf7\u91cd\u65b0\u9009\u62e9!");
				   </script>
			 <%
				  return;
		}
		else
		{	
				//add parameter(LSvalidateExist) by zhangshuai 3/25/2017
		 String strURL = "emxCreate.jsp?type=type_SEMPartTask&policy=policy_SEMPartTask&form=type_CreateSEMPartTask&createJPO=SEMTask:createNewPartTask&header=emxFramework.Command.CreateSEMPartTask&submitAction=refreshCaller&LSvalidateExist=true&emxTableRowId="+selectedNodeId;
						%>
						<script language="javascript">
							var url = "<%=strURL%>"; <%-- XSSOK --%> 
							getTopWindow().showSlideInDialog(url,true);
						</script> 
						<%   

		 }
		 
	 }
	 
	 else if(type.equals("SEM Part Task")){
	
				//add parameter(LSvalidateExist) by zhangshuai 3/25/2017
		 String strURL = "emxCreate.jsp?type=type_SEMPartTask&policy=policy_SEMPartTask&form=type_CreateSEMPartTask&createJPO=SEMTask:createNewPartTask&header=emxFramework.Command.CreateSEMPartTask&submitAction=refreshCaller&LSvalidateExist=true&emxTableRowId="+selectedNodeId;
						%>
						<script language="javascript">
							var url = "<%=strURL%>"; <%-- XSSOK --%> 
							getTopWindow().showSlideInDialog(url,true);
						</script> 
						<%   

		 }
	 else
		 {
			 %>
				   <script language="javascript" type="text/javaScript">
				   alert("");
				   </script>
			 <%
				  return;
		 }

}else if(mode.equals("CreateIssue")){
	String objectId= emxGetParameter(request,"objectId");
	String flag= emxGetParameter(request,"flag");
	String strURL="";
	if(flag.equals("Market Survey Issue")){
		 strURL="emxCreate.jsp?form=type_CreateTestDriveIssue&type=type_Issue&nameField=autoName&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("SEG Model Issue")){
		 strURL="emxCreate.jsp?form=type_CreateSEGModelIssue&type=type_Issue&nameField=autoName&openerFrame=SEMModellingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("SEG Engineer Issue")){
		 strURL="emxCreate.jsp?form=type_CreateSEGModelIssue&type=type_Issue&nameField=autoName&openerFrame=SEGEngingeeringIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Structure Analyse Issue")){
		 strURL="emxCreate.jsp?form=type_CreateSEGModelIssue&type=type_Issue&nameField=autoName&openerFrame=ModellingReviewIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Try Stamping Issue")){
		 strURL="emxCreate.jsp?form=type_CreateTryStampingIssue&type=type_Issue&nameField=autoName&openerFrame=TestStampingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Try Welding Issue")){
		 strURL="emxCreate.jsp?form=type_CreateTryWeldingIssue&type=type_Issue&nameField=autoName&openerFrame=TestWeldingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Try Coating Issue")){
		 strURL="emxCreate.jsp?form=type_CreateTryCoatingIssue&type=type_Issue&nameField=autoName&openerFrame=TestPaintingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Try Assembly Issue")){
		 strURL="emxCreate.jsp?form=type_CreateTryAssemblyIssue&type=type_Issue&nameField=autoName&openerFrame=TestGeneralAssemblyIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Vehicle Check Issue")){
		 strURL="emxCreate.jsp?form=type_CreateVehicleCheckIssue&type=type_Issue&nameField=autoName&openerFrame=VehicleTestingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Assess Issue")){
		 strURL="emxCreate.jsp?form=type_CreateAssessIssue&type=type_Issue&nameField=autoName&openerFrame=EvaluatingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Vehicle Test Issue")){
		 strURL="emxCreate.jsp?form=type_CreateVehicleTestIssue&type=type_Issue&nameField=autoName&openerFrame=VehicleInspectIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Performance Test Issue")){
		 strURL="emxCreate.jsp?form=type_CreateVehicleTestIssue&type=type_Issue&nameField=autoName&openerFrame=PerformanceTestIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Test Drive Issue")){
		 strURL="emxCreate.jsp?form=type_CreateTestDriveIssue&type=type_Issue&nameField=autoName&openerFrame=TestDriveIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Case Issue")){
		 strURL="emxCreate.jsp?form=type_CreateTestDriveIssue&type=type_Issue&nameField=autoName&openerFrame=SpecialIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else{
		 strURL="emxCreate.jsp?form=type_CreateTestDriveIssue&type=type_Issue&nameField=autoName&openerFrame=InvestingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}
	
  %>  
 	<script language="javascript">
 		var url = "<%=strURL%>"; <%-- XSSOK --%> 
 		getTopWindow().showSlideInDialog(url,true);
     </script> 
<%
}else if(mode.equals("CreateIssue1")){
	String objectId= emxGetParameter(request,"objectId");
	DomainObject meetObj = new DomainObject(objectId);
	String meetType = meetObj.getType(context);
	if("SEM Contact Order".equals(meetType)){
		MapList resList = meetObj.getRelatedObjects(context, "SEM Meeting ContactOrder", "Meeting", busList, relList, true, false, (short)1, null, null);
		for(int i = 0; i < resList.size(); i ++)
		{
			Map resMap = (Map)resList.get(i);
		    objectId = (String)resMap.get("id");
		}
	}
	String flag= emxGetParameter(request,"flag");
	String strURL="";
	if(flag.equals("Case Issue")){
		 strURL="emxCreate.jsp?form=type_CreateSEMIssue&type=type_Issue&nameField=autoName&openerFrame=SpecialIssue&submitAction=refreshCaller&relationship=relationship_Issue&direction=To&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}
%>
   
 	<script language="javascript">
 		var url = "<%=strURL%>"; <%-- XSSOK --%> 
 		getTopWindow().showSlideInDialog(url,true);
     </script> 
<%
}else if(mode.equals("WBSSendEmail")){
    String emxTableRowId[] = emxGetParameterValues(request,"emxTableRowId");
	String path = request.getContextPath();  
	String baseURL=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/common/emxNavigator.jsp";  
	StringBuffer qStringBuff= new StringBuffer();
    for(int i=0;i<emxTableRowId.length;i++)
	{
		String[] splitValue = emxTableRowId[i].split("\\|");
		String strObjId =splitValue[1];
        qStringBuff.append(strObjId+",");
	}
	String rows=qStringBuff.toString();
	String url="emxCreate.jsp?form=type_CreateLSNotificationRequest&type=type_LSNotificationRequest&nameField=autoName&createJPO=LSNotificationRequest:createLSNotificationRequest&header=emxFramework.Common.CreateLSNotificationRequest&submitAction=refreshCaller";
%>
<html>
 <body>
    <form method="post" id="myform" action="<%=url%>">
       <input type="hidden"  id="preRows"  name="preRows" value="<%=rows%>">
	   <input type="hidden"  id="baseURL"  name="baseURL" value="<%=baseURL%>">
    </form>
 </body>
</html>
	<script type="text/javascript">
        document.getElementById('myform').submit();
    </script>	
<%	
}else if(mode.equals("SEMCancelMeeting")){
	String objectId=(String)emxGetParameter(request,"objectId");
	String path = request.getContextPath();  
	String baseURL=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/common/emxNavigator.jsp";  
	String url="emxCreate.jsp?form=SEMMeetingCancelLSNotificationRequest&type=type_LSNotificationRequest&nameField=autoName&createJPO=emxMeeting:createCancelLSNotificationRequest&header=emxFramework.Common.CreateLSNotificationRequest&submitAction=refreshCaller&objectId="+objectId;
%>
<html>
 <body>
    <form method="post" id="myform" action="<%=url%>">
	   <input type="hidden"  id="baseURL"  name="baseURL" value="<%=baseURL%>">
    </form>
 </body>
</html>
	<script type="text/javascript">
        document.getElementById('myform').submit();
    </script>	
<%	
}else if(mode.equals("DeleteSEMPaetTask")){
	 String emxTableRowId[]=emxGetParameterValues(request,"emxTableRowId");
	  boolean flag=false;
	  for(int j=0;j<emxTableRowId.length;j++){
		 String[] splitValue = emxTableRowId[j].split("\\|");
		 String strObjId=splitValue[1];
		 DomainObject strObj=new DomainObject(strObjId);
		 ContextUtil.pushContext(context);
		 if(strObj.getType(context).equals("Project Space")){
	            flag=true;
				break;
		 }
	  }
	  if(flag){
%>
<script type="text/javascript">
     alert("\u6240\u9009\u9879\u4E2D\u6709\u9879\u76EE\u7A7A\u95F4,\u8BF7\u91CD\u65B0\u9009\u62E9!");
     parent.location.href=parent.location.href;
</script>	  
<%		  
	  }
	  else{
	  for(int i=0;i<emxTableRowId.length;i++){
		 String[] splitValue = emxTableRowId[i].split("\\|");
		 String strObjId=splitValue[1];
		 DomainObject strObj=new DomainObject(strObjId);
		 ContextUtil.pushContext(context);
		 if(strObj.getType(context).equals("SEM Part Task")){
			 MapList mapList = strObj.getRelatedObjects(context,"SEM Related DrwTask", "SEM Task Item", busList, relList,false,true,(short)1, null, null);
			 if(mapList.size()>0)
			 {
					Iterator it = mapList.iterator();
					while(it.hasNext()){
						Map map = (Map)it.next();
						String id=(String)map.get("id");
						DomainObject stiObj=new DomainObject(id);
						stiObj.delete(context);
					}
			 }
		 }
		 strObj.delete(context);
		 ContextUtil.popContext(context);
	  } 
%>
   <script type="text/javascript">
     parent.location.href=parent.location.href;
   </script>
<%	
     } 
}else if(mode.equals("CreateIssue")){
	String objectId= emxGetParameter(request,"objectId");
	String flag= emxGetParameter(request,"flag");
	String strURL="";
	if(flag.equals("Market Survey Issue")){
		 strURL="emxCreate.jsp?form=type_CreateMarketSurveyIssue&type=type_Issue&nameField=autoName&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("SEG Model Issue")){
		 strURL="emxCreate.jsp?form=type_CreateSEGModelIssue&type=type_Issue&nameField=autoName&openerFrame=SEMModellingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("SEG Engineer Issue")){
		 strURL="emxCreate.jsp?form=type_CreateSEGEngineerIssue&type=type_Issue&nameField=autoName&openerFrame=SEGEngingeeringIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Structure Analyse Issue")){
		 strURL="emxCreate.jsp?form=type_CreateStructureAnalyseIssue&type=type_Issue&nameField=autoName&openerFrame=ModellingReviewIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Try Stamping Issue")){
		 strURL="emxCreate.jsp?form=type_CreateTryStampingIssue&type=type_Issue&nameField=autoName&openerFrame=TestStampingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Try Welding Issue")){
		 strURL="emxCreate.jsp?form=type_CreateTryWeldingIssue&type=type_Issue&nameField=autoName&openerFrame=TestWeldingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Try Coating Issue")){
		 strURL="emxCreate.jsp?form=type_CreateTryCoatingIssue&type=type_Issue&nameField=autoName&openerFrame=TestPaintingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Try Assembly Issue")){
		 strURL="emxCreate.jsp?form=type_CreateTryAssemblyIssue&type=type_Issue&nameField=autoName&openerFrame=TestGeneralAssemblyIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Vehicle Check Issue")){
		 strURL="emxCreate.jsp?form=type_CreateVehicleCheckIssue&type=type_Issue&nameField=autoName&openerFrame=VehicleTestingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Assess Issue")){
		 strURL="emxCreate.jsp?form=type_CreateAssessIssue&type=type_Issue&nameField=autoName&openerFrame=EvaluatingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Vehicle Test Issue")){
		 strURL="emxCreate.jsp?form=type_CreateVehicleTestIssue&type=type_Issue&nameField=autoName&openerFrame=VehicleInspectIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Performance Test Issue")){
		 strURL="emxCreate.jsp?form=type_CreatePerformanceTestIssue&type=type_Issue&nameField=autoName&openerFrame=PerformanceTestIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Test Drive Issue")){
		 strURL="emxCreate.jsp?form=type_CreateTestDriveIssue&type=type_Issue&nameField=autoName&openerFrame=TestDriveIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else if(flag.equals("Case Issue")){
		 strURL="emxCreate.jsp?form=type_CreateCaseIssue&type=type_Issue&nameField=autoName&openerFrame=SpecialIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}else{
		 strURL="emxCreate.jsp?form=type_CreateBudgetIssue&type=type_Issue&nameField=autoName&openerFrame=InvestingIssue&submitAction=refreshCaller&relationship=relationship_Issue&policy=policy_Issue&createJPO=SEMIssue:createNewIssue&typeflag="+flag+"&projectId="+objectId+"&objectId="+objectId;
	}
	
  %>  
 	<script language="javascript">
 		var url = "<%=strURL%>"; <%-- XSSOK --%> 
 		getTopWindow().showSlideInDialog(url,true);
     </script> 


<%
}else if(mode.equals("ImportIssue")){
	String objectId= emxGetParameter(request,"objectId");
	String flag= emxGetParameter(request,"flag");
	String strURL="";
	if(flag.equals("Market Survey Issue")){
		 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;	
	}else if(flag.equals("SEG Model Issue")){
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("SEG Engineer Issue")){
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Structure Analyse Issue")){
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Try Stamping Issue")){
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Try Welding Issue")){
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Try Coating Issue")){
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Try Assembly Issue")){
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Vehicle Check Issue")){
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Assess Issue")){
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Vehicle Test Issue")){
			strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Performance Test Issue")){
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Test Drive Issue")){
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Case Issue")){
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}else{
			 strURL="../programcentral/SEMImportIssue.jsp?typeflag="+flag+"&objectId="+objectId;
	}
	
  %>  
 	<script language="javascript">
 		var url = "<%=strURL%>"; <%-- XSSOK --%> 
 	    showModalDialog(url);
    </script> 
 <%
		}else if(mode.equals("ImportIssueStrategy")){
	String objectId= emxGetParameter(request,"objectId");
	String flag= emxGetParameter(request,"flag");
	String strURL="";
	if(flag.equals("Market Survey Issue")){
		 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;	
	}else if(flag.equals("SEG Model Issue")){
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("SEG Engineer Issue")){
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Structure Analyse Issue")){
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Try Stamping Issue")){
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Try Welding Issue")){
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Try Coating Issue")){
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Try Assembly Issue")){
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Vehicle Check Issue")){
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Assess Issue")){
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Vehicle Test Issue")){
			strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Performance Test Issue")){
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Test Drive Issue")){
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Case Issue")){
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}else{
			 strURL="../programcentral/SEMImportIssueStrategy.jsp?typeflag="+flag+"&objectId="+objectId;
	}
 %>
  	<script language="javascript">
 		var url = "<%=strURL%>"; <%-- XSSOK --%> 
 	    showModalDialog(url);
     </script> 
	 
	 <%
	}else if(mode.equals("SEMIssueBOM")){
	String objectId= emxGetParameter(request,"objectId");
	String flag= emxGetParameter(request,"flag");
	String strURL="";
	if(flag.equals("Market Survey Issue")){
		 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;	
	}else if(flag.equals("SEG Model Issue")){
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("SEG Engineer Issue")){
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Structure Analyse Issue")){
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Try Stamping Issue")){
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Try Welding Issue")){
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Try Coating Issue")){
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Try Assembly Issue")){
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Vehicle Check Issue")){
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Assess Issue")){
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Vehicle Test Issue")){
			strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Performance Test Issue")){
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Test Drive Issue")){
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else if(flag.equals("Case Issue")){
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}else{
			 strURL="../programcentral/SEMIssueBOM.jsp?typeflag="+flag+"&objectId="+objectId;
	}
	 %>
	   	<script language="javascript">
 		var url = "<%=strURL%>"; <%-- XSSOK --%> 
 	    showModalDialog(url);
     </script> 
	 <%
	}else if("addSEMCOAddAffectedItems".equals(mode)){
		String names="";
		String ids="";
		try{
			String objectId=(String)emxGetParameter(request,"objectId");
			DomainObject strFromObj = new DomainObject(objectId);
			String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
			for(int i=0;i<emxTableRowId.length;i++)
			{
				String[] splitValue = emxTableRowId[i].split("\\|");
				String strObjId = splitValue[1];
				ids+=strObjId+"|";
				DomainObject strObj=new DomainObject(strObjId);
				String strName = strObj.getName(context);			
				names+=strName+"|";	
			}
			if(names.length()>0){
				names=names.substring(0,names.length()-1);
				ids=ids.substring(0,ids.length()-1);
			}
		}catch(Exception e){
			e.printStackTrace();
		}
		%>
     <script language="javascript">
 		var objform = top.opener.document.forms['emxCreateForm'];
		objform.SEMAffectedItemTaskDisplay.value="<%=names%>";
		objform.SEMAffectedItemTask.value="<%=ids%>";
		getTopWindow().closeWindow();
     </script> 
	<%}else if("addSEMBCRAddAffectedItems".equals(mode)){
		    strRelName=PropertyUtil.getSchemaProperty(context,strRelName);
		    String Msg="";
			String objectId=(String)emxGetParameter(request,"objectId");
			DomainObject strFromObj = new DomainObject(objectId);
			StringList busList1= new StringList("id");
			busList1.add("name");
			StringList list=new StringList();
			String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
			for(int i=0;i<emxTableRowId.length;i++)
			{
				String[] splitValue = emxTableRowId[i].split("\\|");
				String strObjId = splitValue[1];
				DomainObject strObj = new DomainObject(strObjId);
				String strName = strObj.getName(context);
				MapList mapList = strObj.getRelatedObjects(context,strRelName,"SEM BudgetChange Request", busList1, relList,true,false,(short)1, null, null);
				if(mapList.size()>0)
				{
					list.add(strObjId);
				}else{
					list.add(strObjId);
				}
			}
			if(Msg.equals("")){
			 try{
				for(int j=0;j<list.size();j++){
				    DomainObject CostItemObj=new DomainObject((String)list.get(j));
					ContextUtil.pushContext(context);
					DomainRelationship rel=strFromObj.connectTo(context,strRelName,CostItemObj);				
					ContextUtil.popContext(context);
				}
					
			}catch(Exception e){
			  String msg = e.getMessage();
			  throw new Exception(msg);
		    }
%>
        <script>
		 window.top.opener.location.href = window.top.opener.location.href;
		 window.top.close();
		</script>
<%
		}else{
			Msg=Msg.substring(0,Msg.length()-1);
			Msg+="\u5DF2\u7ECF\u5173\u8054\u4E86\u6295\u8D44\u8C03\u6574\u5355\uFF0C\u8BF7\u4ECE\u65B0\u9009\u62E9!";			
%>
         <script>
			alert("<%=Msg%>");
			window.top.location.href = window.top.location.href;
		</script>
<%
		}	
	}else if(mode.equals("refresh")){
		%>
         <script>
			 var contentFrame=getFormContentFrame();
			 contentFrame.location.href=contentFrame.location.href;
		</script>		
<%		
	}
%>







