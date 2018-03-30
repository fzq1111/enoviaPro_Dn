<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@page language="java" pageEncoding="UTF-8"%>
<%@ page import = "org.apache.log4j.Logger"%>

<%
	Logger myLogger = Logger.getLogger(SEMBudget_jsp.class);
	StringList busList = new StringList("id");
    StringList relList = new StringList(DomainRelationship.SELECT_ID);
    String mode=(String)emxGetParameter(request,"mode");

	if("CreateCostItem".equals(mode)){
		
		String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		String portalCommandName = (String)emxGetParameter(request, "portalCmdName");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue = emxTableRowId[i].split("\\|");
			String selectedId = splitValue[1];
			String tableRowId = splitValue[3];	
			String[] splitRowId = tableRowId.split(",");
			if(splitRowId.length==3)
			{
				String url="../common/emxCreate.jsp?form=type_CreateSEMCostItem&type=type_CostItem&header=emxFramework.webform.SEMCostItemCreateNew&nameField=keyin&submitAction=doNothing&createJPO=SEMBudget:createCostItem&mode=CreateBudget&selectedId="+selectedId+"&postProcessURL=../common/SEMBudget.jsp?mode=refreshCreateCostItem";

%>
	<script>
		showModalDialog("<%=url%>",'600','600')
	</script>
<%				
			}else{
				String error = "\u9009\u62E9\u5217\u4E0D\u5141\u8BB8\u521B\u5EFA\u6295\u8D44\u9879\u3002";
%>
	<script>
		alert("<%=error%>");
	</script>
<%				
			}
		}
		
	}else if("refreshCreateCostItem".equals(mode)){
	
%>
	<script>	
		parent.opener.parent.window.location.href = parent.opener.parent.window.location.href;
		window.top.close();

	</script>	
<%		
	}else if("deleteBudget".equals(mode)){
		String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		 boolean flag=false;
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue = emxTableRowId[i].split("\\|");
			String selectId = splitValue[1];	
			DomainObject strObj = new DomainObject(selectId);
			String strType = strObj.getType(context);
			if(strType.equals("SEM Cost Request"))
			{
				continue;
			}
			if(strType.equals("Project Space"))
			{			
%>
			<script type="text/javascript">
				 alert("\u6240\u9009\u9879\u4E2D\u6709\u9879\u76EE\u7A7A\u95F4,\u8BF7\u91CD\u65B0\u9009\u62E9!");
				 parent.location.href=parent.location.href;
			</script>	  
<%		  
				break;
			}
			boolean hasSubBudget = strObj.hasRelatedObjects(context,"SEM Sub Budget", true); 
			boolean hasItems = strObj.hasRelatedObjects(context,"Financial Items", true);
			if(hasSubBudget)
			{
				MapList mapList = strObj.getRelatedObjects(context,"SEM Sub Budget","*",busList,relList,false,true,(short)1,"" ,"");
				Iterator it = mapList.iterator();
				while(it.hasNext())
				{
					Map map = (Map)it.next();
					String objId = (String)map.get("id");
					DomainObject obj = new DomainObject(objId);
					MapList list = obj.getRelatedObjects(context,"Financial Items","*",busList,relList,false,true,(short)1,"" ,"");
					Iterator j = list.iterator();
					while(j.hasNext())
					{
						Map map1 = (Map)j.next();
						String id = (String)map1.get("id");
						DomainObject itemObj = new DomainObject(id);
						itemObj.delete(context,true);
					}
					obj.delete(context,true);
				}
			}else if(hasItems){
				MapList list = strObj.getRelatedObjects(context,"Financial Items","*",busList,relList,false,true,(short)1,"" ,"");
					Iterator j = list.iterator();
					while(j.hasNext())
					{
						Map map1 = (Map)j.next();
						String id = (String)map1.get("id");
						DomainObject itemObj = new DomainObject(id);
						itemObj.delete(context,true);
					}
			}
			
			strObj.delete(context,true);
		}
%>
	<script>
		parent.location.href = parent.location.href;
	</script>
<%		
	}else if("RemoveCostRequest".equals(mode)){
		try{
			String objectId = emxGetParameter(request,"objectId");
			DomainObject assetObj = new DomainObject(objectId);
			String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
			String specCostItem = getSpecCostItem(context);
			if(specCostItem.length()>0)
			{
				DomainObject strSpecObj = new DomainObject(specCostItem);
				for(int i=0;i<emxTableRowId.length;i++)
				{
					String[] splitValue = emxTableRowId[i].split("\\|");			
					String sRelationshipIds = splitValue[0];
					String toId = splitValue[1];
					DomainObject toObj = new DomainObject(toId);
					ContextUtil.pushContext(context);
					DomainRelationship.disconnect(context, sRelationshipIds);
					strSpecObj.connectTo(context,"SEM CostRequest Budget",toObj); 
					ContextUtil.popContext(context);				
				}
			}
			
		}catch(Exception e){
			myLogger.error(e.getMessage(), e);
			throw new Exception(e.getMessage());
		}
%>
	<script>
		parent.location.href = parent.location.href;
	</script>
<%		
	}else if("SEMBudgetOpen".equals(mode)){
		try{
			String objectId = emxGetParameter(request,"objectId");
			DomainObject projectObj = new DomainObject(objectId);
			ContextUtil.pushContext(context);
			projectObj.setAttributeValue(context,"SEM Budget Open Status","YES");
			ContextUtil.popContext(context);
		}catch(Exception e){
			myLogger.error(e.getMessage(), e);
			throw new Exception(e.getMessage());
		}
%>
<script>
	parent.location.href = parent.location.href;
	</script>
<%		
	}else if("SEMBudgetClose".equals(mode)){
		try{
			String objectId = emxGetParameter(request,"objectId");
			DomainObject projectObj = new DomainObject(objectId);
			projectObj.setAttributeValue(context,"SEM Budget Open Status","NO");
		}catch(Exception e){
			myLogger.error(e.getMessage(), e);
			throw new Exception(e.getMessage());
		}
%>
<script>
	parent.location.href = parent.location.href;
	
	</script>
<%			
	}else if("SEMBudgetFrozen".equals(mode)){
		try{
			String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
			for(int i=0;i<emxTableRowId.length;i++)
			{
				String[] splitValue = emxTableRowId[i].split("\\|");
				String selectId = splitValue[1];	
				DomainObject strObj = new DomainObject(selectId);
				String strType = strObj.getType(context);				
				
				if(strType.equals("Budget"))
				{
					boolean hasSubBudget = strObj.hasRelatedObjects(context,"SEM Sub Budget", true); 
					boolean hasItems = strObj.hasRelatedObjects(context,"Financial Items", true);
					if(hasSubBudget)
					{
						MapList mapList = strObj.getRelatedObjects(context,"SEM Sub Budget","*",busList,relList,false,true,(short)1,"" ,"");
						Iterator it = mapList.iterator();
						while(it.hasNext())
						{
							Map map = (Map)it.next();
							String objId = (String)map.get("id");
							DomainObject obj = new DomainObject(objId);
							MapList list = obj.getRelatedObjects(context,"Financial Items","*",busList,relList,false,true,(short)1,"" ,"");
							Iterator j = list.iterator();
							while(j.hasNext())
							{
								Map map1 = (Map)j.next();
								String id = (String)map1.get("id");
								DomainObject itemObj = new DomainObject(id);
								String current = itemObj.getInfo(context,"current");
							//	System.out.println("current==="+current);
								if(current!="Frozen")
								{
									//String planCost = itemObj.getAttributeValue(context,"Planned Cost");
									//itemObj.setAttributeValue(context,"SEM Frozen Cost",planCost);
									itemObj.gotoState(context,"Frozen");
								}
							}
							//obj.gotoState(context,"Frozen");
						}
					}else if(hasItems){
							MapList list = strObj.getRelatedObjects(context,"Financial Items","*",busList,relList,false,true,(short)1,"" ,"");
							Iterator j = list.iterator();
							while(j.hasNext())
							{
								Map map1 = (Map)j.next();
								String id = (String)map1.get("id");
								DomainObject itemObj = new DomainObject(id);
								String current = itemObj.getInfo(context,"current");
							//	System.out.println("current==1111="+current);
								if(current!="Frozen")
								{
									//String planCost = itemObj.getAttributeValue(context,"Planned Cost");
									//itemObj.setAttributeValue(context,"SEM Frozen Cost",planCost);
									itemObj.gotoState(context,"Frozen");
								}
							}
					}
				}else if(strType.equals("Cost Item")){
					String current = strObj.getInfo(context,"current");
					if(current!="Frozen")
						{
							//String planCost = strObj.getAttributeValue(context,"Planned Cost");
							//strObj.setAttributeValue(context,"SEM Frozen Cost",planCost);
							strObj.gotoState(context,"Frozen");
						}					
				}else{
					
				}
				
				//strObj.gotoState(context,"Frozen");
			}
		}catch(Exception e){
			myLogger.error(e.getMessage(), e);
			throw new Exception(e.getMessage());
		}
%>
<script>
	parent.location.href = parent.location.href;
	
	</script>
<%			
	}
	//add by ryan 2017-02-11
	else if("createCostBaseline".equals(mode))
	{
		try
		{
			String objectId = emxGetParameter(request,"objectId");
			String strDesc = "\u7528\u6237" + context.getUser() + "\u521B\u5EFA\u4E8E" + 
					new SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US).format(new Date());
			HashMap jpoArgsMap = new HashMap();
			jpoArgsMap.put("objectId", objectId);
			jpoArgsMap.put("description", strDesc);
			JPO.invoke(context, 
					  "SEMBudget", 
					  null, 
					  "createCostBaseline", 
					  JPO.packArgs(jpoArgsMap), 
					  Void.class);
			String strMessage = "\u6295\u8D44\u57FA\u7EBF\u5DF2\u4FDD\u5B58";
%>
			<script language="Javascript">
				alert("<%=strMessage%>");
			</script>
<%
		}catch(Exception ex)
		{
			myLogger.error(ex.getMessage(), ex);
			String strErr = "\u6295\u8D44\u57FA\u7EBF\u4FDD\u5B58\u51FA\u9519:" + ex.getMessage();
%>
			<script language="Javascript">
				alert("<%=strErr%>");
			</script>
<%
		}
	}
	else if("viewCostBaseline".equals(mode))
	{
		try
		{
			/*
			Enumeration enumParam = request.getParameterNames();
	          while (enumParam.hasMoreElements())
	          {
	              String name = (String) enumParam.nextElement();
	              System.out.println(name + "=" + request.getParameter(name));
	          }
	          //*/
			String strCostBaselineId = emxGetParameter(request,"objectId");
			String strProjId = emxGetParameter(request,"parentOID");
			String strUrl = "../common/emxIndentedTable.jsp?expandProgram=SEMBudget:expandContentsFromBaselineXML&" + 
							"table=SEMviewCostBaseline&autoFilter=false&customize=false&objectId=" + strProjId +"&costBaselineId=" + strCostBaselineId;
%>
			<script language="Javascript">
				document.location.href = "<%=strUrl%>";
			</script>
<%
		}catch(Exception ex)
		{
			myLogger.error(ex.getMessage(), ex);
			String strErr = ex.getMessage();
%>
			<script language="Javascript">
				alert("<%=strErr%>");
			</script>
<%
		}
	}
%>



<%!
	public String getSpecCostItem(Context context)throws Exception
	{
		StringList  busList = new StringList("id");	
		String costId="";
		MapList costItemList = DomainObject.findObjects(context,"Cost Item","99999999","*",null,null,null,null,true,busList,(short)0);
		if(costItemList!=null && costItemList.size()>0)
		{
			Iterator costItemIt = costItemList.iterator();
			while(costItemIt.hasNext())
			{
				Map costMap = (Map)costItemIt.next();
				costId = (String)costMap.get("id");
			}
		}
		return 	costId;
	}
%>