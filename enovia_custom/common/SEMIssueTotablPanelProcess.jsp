<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@page import="java.util.Set"%>
<%
    String mode = emxGetParameter(request, "mode");	
	StringList busList = new StringList("id");
	StringList relList = new StringList("id[connection]");
	if("getIssuesFromSearch".equals(mode))
	{
		String selectId = "";
		String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		for(int i = 0 ;i < emxTableRowId.length; i++)
		{
			String[] splitValue = emxTableRowId[i].split("\\|");
			String taskId = splitValue[1];
			selectId +=taskId+",";
		}	
		if(selectId.length()>0)
		{
			selectId = selectId.substring(0,selectId.length()-1);
		}
		
		PropertyUtil.setAdminProperty(context,"person",context.getUser(),"SEMIssue",selectId);

		
%>		
		<script >
			var parentWindowId = top.opener.document.getElementById("getSelectedIds");
			parentWindowId.value="<%=selectId%>";			
			//var inputView = top.opener.document.getElementById("Submit1");
			//inputView.value="<%="\u641C\u7D22\u95EE\u9898\u5DF2\u9009"%>"
			top.close();
		</script>
	
<%		
	}else if("createTableHasPanelValue".equals(mode))
	{
		
		String getSelectedIdValue = (String)PropertyUtil.getAdminProperty (context,"person",context.getUser(),"SEMIssue");
		String panelAttributeValue = emxGetParameter(request, "panelAttributeValue");	
		//String mateValue = emxGetParameter(request, "mateValue");
		MapList mapList =new MapList();
		if(panelAttributeValue!=null && panelAttributeValue.length()>0)
		{
			mapList = getSeletedAttributeValues(context,getSelectedIdValue,panelAttributeValue);
		}

		String totalColumnA=getColumnTotalValue(context,mapList,"A");
		String totalColumnB=getColumnTotalValue(context,mapList,"B");
		String totalColumnC=getColumnTotalValue(context,mapList,"C");
		String totalColumnD=getColumnTotalValue(context,mapList,"D");
		int iColumnA=Integer.parseInt(totalColumnA);
		int iColumnB=Integer.parseInt(totalColumnB);
		int iColumnC=Integer.parseInt(totalColumnC);
		int iColumnD=Integer.parseInt(totalColumnD);
		int iTotalColumn= iColumnA+ iColumnB+iColumnC+iColumnD;
		String sTotalColumn = Integer.toString(iTotalColumn);
		
		session.setAttribute("mapList",mapList);
		for(int j=0;j<mapList.size();j++)
		{
			
			Map map1 = (Map)mapList.get(j);
			Set set = map1.entrySet();         
			Iterator i = set.iterator(); 
			String rowName="";
			String rowA="0";
			String rowB="0";
			String rowC="0";
			String rowD="0";
			String totalRow="";
			while(i.hasNext())
			{      
				Map.Entry<String, String> entry1=(Map.Entry<String, String>)i.next();    
				String key = entry1.getKey() ;
				String key1=key.split("_")[0];
				rowName=key1;
				if(rowName.equals(key1))
				{
					String key2=key.split("_")[1];
					if(key2.equals("A"))
					{
						rowA = entry1.getValue();
					}else if(key2.equals("B")){
						rowB = entry1.getValue();
					}else if(key2.equals("C")){
						rowC = entry1.getValue();
					}else if(key2.equals("D")){
						rowD = entry1.getValue();
					}
				}
				
			}			
			int iRowA = Integer.parseInt(rowA);	
			int iRowB = Integer.parseInt(rowB);	
			int iRowC = Integer.parseInt(rowC);	
			int iRowD = Integer.parseInt(rowD);	
			int iTotal = iRowA+iRowB+iRowC+iRowD;
			totalRow=Integer.toString(iTotal);
%>		
	<!--创建table js-->	
	<script>
			
			var tableView = top.opener.document.getElementById("tableView");
			if(tableView==null)
			{
				tableView = parent.opener.document.getElementById("tableView");		
				if(tableView==null)
				{
					tableView = parent.document.getElementById("tableView");		
				}
				if(tableView==null)
				{
					top.window.close();
				}
			}
			tableView.rows[1].cells[1].innerText="<%=totalColumnA%>";
			tableView.rows[1].cells[2].innerText="<%=totalColumnB%>";
			tableView.rows[1].cells[3].innerText="<%=totalColumnC%>";
			tableView.rows[1].cells[4].innerText="<%=totalColumnD%>";
			tableView.rows[1].cells[5].innerText="<%=sTotalColumn%>";
			var row;  
			var cell;	
		
			row = document.createElement("tr"); 
			tableView.appendChild(row);
			row.align="center"; 	
			cell = document.createElement("td");
			cell.innerText = "<%=rowName%>"; 				
			row.appendChild(cell); 						
			cell = document.createElement("td");
			cell.innerText = "<%=rowA%>"; 				
			row.appendChild(cell); 
			cell = document.createElement("td");
			cell.innerText = "<%=rowB%>"; 				
			row.appendChild(cell); 
			cell = document.createElement("td");
			cell.innerText = "<%=rowC%>"; 				
			row.appendChild(cell); 	
			cell = document.createElement("td");
			cell.innerText = "<%=rowD%>"; 				
			row.appendChild(cell); 	
			cell = document.createElement("td");
			cell.innerText = "<%=totalRow%>"; 				
			row.appendChild(cell); 		
			top.window.close();
		</script>
<%		
		}
	
		
	}else if("createViewTable".equals(mode)){
		
		String getSelectedIdValue = (String)PropertyUtil.getAdminProperty (context,"person",context.getUser(),"SEMIssue");
		MapList mapList =new MapList();	
		mapList = getSeletedAttributeValues(context,getSelectedIdValue,"");
		String totalColumnA=getColumnTotalValue(context,mapList,"A");
		String totalColumnB=getColumnTotalValue(context,mapList,"B");
		String totalColumnC=getColumnTotalValue(context,mapList,"C");
		String totalColumnD=getColumnTotalValue(context,mapList,"D");
		int iColumnA=Integer.parseInt(totalColumnA);
		int iColumnB=Integer.parseInt(totalColumnB);
		int iColumnC=Integer.parseInt(totalColumnC);
		int iColumnD=Integer.parseInt(totalColumnD);
		int iTotalColumn= iColumnA+ iColumnB+iColumnC+iColumnD;
		String sTotalColumn = Integer.toString(iTotalColumn);			
%>
	<script>
			
		var tableView = top.opener.document.getElementById("tableView");
		if(tableView==null)
		{
			tableView = parent.opener.document.getElementById("tableView");	
			if(tableView==null)
			{
				top.window.close();
			}
		}
		tableView.rows[1].cells[1].innerText="<%=totalColumnA%>";
		tableView.rows[1].cells[2].innerText="<%=totalColumnB%>";
		tableView.rows[1].cells[3].innerText="<%=totalColumnC%>";
		tableView.rows[1].cells[4].innerText="<%=totalColumnD%>";
		tableView.rows[1].cells[5].innerText="<%=sTotalColumn%>";
		top.window.close();
		
		
		
		
	</script>
<%		
	}else if("createViewTableSplitDouHao".equals(mode)){
		
		String panelAttributeValue = emxGetParameter(request, "panelAttributeValue");	
		String getSelectedIdValue = (String)PropertyUtil.getAdminProperty (context,"person",context.getUser(),"SEMIssue");
		MapList mapList =new MapList();	
		mapList = getSeletedValues(context,getSelectedIdValue,panelAttributeValue);
		String totalColumnA=getColumnTotalValue(context,mapList,"A");
		String totalColumnB=getColumnTotalValue(context,mapList,"B");
		String totalColumnC=getColumnTotalValue(context,mapList,"C");
		String totalColumnD=getColumnTotalValue(context,mapList,"D");
		int iColumnA=Integer.parseInt(totalColumnA);
		int iColumnB=Integer.parseInt(totalColumnB);
		int iColumnC=Integer.parseInt(totalColumnC);
		int iColumnD=Integer.parseInt(totalColumnD);
		int iTotalColumn= iColumnA+ iColumnB+iColumnC+iColumnD;
		String sTotalColumn = Integer.toString(iTotalColumn);	
		for(int j=0;j<mapList.size();j++)
		{
			
			Map map1 = (Map)mapList.get(j);
			Set set = map1.entrySet();         
			Iterator i = set.iterator(); 
			String rowName="";
			String rowA="0";
			String rowB="0";
			String rowC="0";
			String rowD="0";
			String totalRow="";
			while(i.hasNext())
			{      
				Map.Entry<String, String> entry1=(Map.Entry<String, String>)i.next();    
				String key = entry1.getKey() ;
				String key1=key.split("_")[0];
				rowName=key1;
				if(rowName.equals(key1))
				{
					String key2=key.split("_")[1];
					if(key2.equals("A"))
					{
						rowA = entry1.getValue();
					}else if(key2.equals("B")){
						rowB = entry1.getValue();
					}else if(key2.equals("C")){
						rowC = entry1.getValue();
					}else if(key2.equals("D")){
						rowD = entry1.getValue();
					}
				}
				
			} 		
			int iRowA = Integer.parseInt(rowA);	
			int iRowB = Integer.parseInt(rowB);	
			int iRowC = Integer.parseInt(rowC);	
			int iRowD = Integer.parseInt(rowD);	
			int iTotal = iRowA+iRowB+iRowC+iRowD;
			totalRow=Integer.toString(iTotal);
		
%>		
	<!--创建table js-->	
	<script>
			var row;  
			var cell;	
			var tableView = top.opener.document.getElementById("tableView");
			if(tableView==null)
			{
				tableView = parent.opener.document.getElementById("tableView");		
				if(tableView==null)
				{
					tableView = parent.document.getElementById("tableView");		
				}
				if(tableView==null)
				{
					top.window.close();
				}
			}
			tableView.rows[1].cells[1].innerText="<%=totalColumnA%>";
			tableView.rows[1].cells[2].innerText="<%=totalColumnB%>";
			tableView.rows[1].cells[3].innerText="<%=totalColumnC%>";
			tableView.rows[1].cells[4].innerText="<%=totalColumnD%>";
			tableView.rows[1].cells[5].innerText="<%=sTotalColumn%>";
	
			row = document.createElement("tr");  
			tableView.appendChild(row);
			cell = document.createElement("td");
			row.align="center"; 
			cell.innerText = "<%=rowName%>#"; 				
			row.appendChild(cell); 						
			cell = document.createElement("td");
			cell.innerText = "<%=rowA%>"; 				
			row.appendChild(cell); 
			cell = document.createElement("td");
			cell.innerText = "<%=rowB%>"; 				
			row.appendChild(cell); 
			cell = document.createElement("td");
			cell.innerText = "<%=rowC%>"; 				
			row.appendChild(cell); 	
			cell = document.createElement("td");
			cell.innerText = "<%=rowD%>"; 				
			row.appendChild(cell); 	
			cell = document.createElement("td");
			cell.innerText = "<%=totalRow%>"; 				
			row.appendChild(cell); 	
			
			top.window.close();
		</script>
<%		
		}
	}else if("setPanelValue".equals(mode)){
		String panelAttributeValue = emxGetParameter(request, "panelAttributeValue");	
		if(panelAttributeValue!=null&&panelAttributeValue.length()>0)
		{
			PropertyUtil.setAdminProperty(context,"person",context.getUser(),"SEMIssuePanelValue",panelAttributeValue);
		}
%>

	<script>
		top.window.close();
	</script>
<%		
	}else if("clearValue".equals(mode)){	
		
		PropertyUtil.setAdminProperty(context,"person",context.getUser(),"SEMIssuePanelValue","");
		PropertyUtil.setAdminProperty(context,"person",context.getUser(),"SEMIssue","");		
%>

	<script>
		top.window.close();
	</script>
<%		
	}	
%>



<%!
	public MapList getSeletedAttributeValues(Context context,String objectIds,String selectedAttr)throws Exception
	{
		MapList mapList = new MapList();
		StringList hangList = new StringList();
		String[] splitSelectedIds = objectIds.split(",");

		for(int i=0;i<splitSelectedIds.length;i++)
		{
			String selectId = splitSelectedIds[i];
			DomainObject strSelectObj = new DomainObject(selectId);
			String attrValue ="";
			if(selectedAttr.equals("owner"))
			{
				attrValue = strSelectObj.getInfo(context,"owner");

			}else{
				attrValue = strSelectObj.getAttributeValue(context,selectedAttr);
			}			
			String semAttrValue = strSelectObj.getAttributeValue(context,"SEM Issue SolutionProgress");
			if(!hangList.contains(attrValue))
			{ 
				hangList.add(attrValue);
				Map map = new HashMap();
				if(semAttrValue.equals("A"))
				{
					map.put(attrValue+"_A","1");
					map.put(attrValue+"_B","0");
					map.put(attrValue+"_C","0");
					map.put(attrValue+"_D","0");
				}else if(semAttrValue.equals("B")){
					map.put(attrValue+"_A","0");
					map.put(attrValue+"_B","1");
					map.put(attrValue+"_C","0");
					map.put(attrValue+"_D","0");
				}else if(semAttrValue.equals("C")){
					map.put(attrValue+"_A","0");
					map.put(attrValue+"_B","0");
					map.put(attrValue+"_C","1");
					map.put(attrValue+"_D","0");
				}else if(semAttrValue.equals("D")){
					map.put(attrValue+"_A","0");
					map.put(attrValue+"_B","0");
					map.put(attrValue+"_C","0");
					map.put(attrValue+"_D","1");
				}
				mapList.add(map);
			}else{
				StringList addList = new StringList();
					
				for(int a=0;a<mapList.size();a++)
				{
					Map map = (Map)mapList.get(a);
					String sNum = (String)map.get(attrValue+"_"+semAttrValue);
					if(sNum!=null && sNum.length()>0)
					{
						int iNum = Integer.parseInt(sNum)+1;
						sNum = Integer.toString(iNum);
						map.put(attrValue+"_A",sNum);
					}						
				}				
			}			
		}
		return mapList;
	}
	
	public MapList getSeletedValues(Context context,String objectIds,String selectedAttr)throws Exception
	{
		MapList mapList = new MapList();
		StringList hangList = new StringList();
		String[] splitSelectedIds = objectIds.split(",");

		for(int i=0;i<splitSelectedIds.length;i++)
		{
			String selectId = splitSelectedIds[i];
			DomainObject strSelectObj = new DomainObject(selectId);
			String attrValue ="";
			
			attrValue = strSelectObj.getAttributeValue(context,selectedAttr);
						
			String semAttrValue = strSelectObj.getAttributeValue(context,"SEM Issue SolutionProgress");
			String[] splitAttrValue = attrValue.split(",");
			for(int j=0;j<splitAttrValue.length;j++)
			{
				String value = (String)splitAttrValue[j];
				if(!hangList.contains(value))
				{ 
					hangList.add(value);
					Map map = new HashMap();
					if(semAttrValue.equals("A"))
					{
						map.put(value+"_A","1");
						map.put(value+"_B","0");
						map.put(value+"_C","0");
						map.put(value+"_D","0");
					}else if(semAttrValue.equals("B")){
						map.put(value+"_A","0");
						map.put(value+"_B","1");
						map.put(value+"_C","0");
						map.put(value+"_D","0");
					}else if(semAttrValue.equals("C")){
						map.put(value+"_A","0");
						map.put(value+"_B","0");
						map.put(value+"_C","1");
						map.put(value+"_D","0");
					}else if(semAttrValue.equals("D")){
						map.put(value+"_A","0");
						map.put(value+"_B","0");
						map.put(value+"_C","0");
						map.put(value+"_D","1");
					}
					

					mapList.add(map);
				}else{
					StringList addList = new StringList();
					for(int a=0;a<mapList.size();a++)
					{
						Map map = (Map)mapList.get(a);
						String sNum = (String)map.get(value+"_"+semAttrValue);
						if(sNum!=null && sNum.length()>0)
						{
							int iNum = Integer.parseInt(sNum)+1;
							sNum = Integer.toString(iNum);
							map.put(value+"_"+semAttrValue,sNum);
						}						
					}
				}					
			}
					
		}
		return mapList;
	}
	
	
	
	public String getColumnTotalValue(Context context,MapList mapList,String totalName)throws Exception
	{
		String totalValue = "";
		int intTotal = 0;
		for(int i=0;i<mapList.size();i++)
		{
			Map map1 = (Map)mapList.get(i);
			Set set = map1.entrySet();         
			Iterator j = set.iterator();
			String rowName="";
			while(j.hasNext())
			{      
				Map.Entry<String, String> entry1=(Map.Entry<String, String>)j.next();    
				String key = entry1.getKey() ;
				String key1=key.split("_")[0];
				rowName=key1;
				String key2=key.split("_")[1];
				if(rowName.equals(key1) && key2.equals(totalName))
				{
					String rowA = entry1.getValue();
					int intRowA = Integer.parseInt(rowA);
					intTotal += intRowA;
				}
			}
		}
		totalValue = Integer.toString(intTotal);
		return totalValue;
	}
	

%>