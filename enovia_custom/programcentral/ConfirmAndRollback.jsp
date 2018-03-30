<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page language="java" pageEncoding="UTF-8"%>
<% 

	String mode=emxGetParameter(request,"mode");
	if(mode.equals("complete"))
	{
		try{
			String[] emxTableRowId= emxGetParameterValues(request, "emxTableRowId");
			for(int i=0;i<emxTableRowId.length;i++)
			{
				String[] splitValue=emxTableRowId[i].split("\\|");				
				String strObjectId=splitValue[1];	
				//System.out.println("strObjectId=="+strObjectId);
				String currentUser=context.getUser();		
				DomainObject strObj=new DomainObject(strObjectId);
				String sOwner = strObj.getInfo(context, "owner");
				if(currentUser.equals(sOwner))
				{
					ContextUtil.pushContext(context);
					strObj.promote(context);
					ContextUtil.popContext(context);
				}else{
					StringList busList = new StringList("id");
					busList.add("name");
					StringList relList = new StringList(DomainRelationship.SELECT_ID);					
					MapList mapList=strObj.getRelatedObjects(context,"SEM Task Reviewer","Person", busList, relList, false, true, (short)1, "", "");
					StringList allList = new StringList();
					for(int j = 0; j < mapList.size(); j ++){
						Map map = (Map)mapList.get(j);
						String relId = (String)map.get("id[connection]");
						DomainRelationship  strRel1=new DomainRelationship (relId);
						String strName = (String)map.get("name");
						if(currentUser.equals(strName)){
							ContextUtil.pushContext(context);
							strRel1.setAttributeValue(context,"SEM Reviewed","YES");
							ContextUtil.popContext(context);
						}					
						String ss1=strRel1.getAttributeValue(context,"SEM Reviewed");
						allList.add(ss1);
					}
					if(!allList.contains("NO")){
						ContextUtil.pushContext(context);
						strObj.promote(context);
						ContextUtil.popContext(context);
					}
				}										
			}
		}catch(Exception e){
			e.printStackTrace();
		}
	%>
<script>
    alert("\u5B8C\u6210\u64CD\u4F5C\u6210\u529F!");
	parent.location.href=parent.location.href;
</script>
<%
	}else if(mode.equals("rollback"))
	{
		String[] emxTableRowId= emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue=emxTableRowId[i].split("\\|");
			String strObjectId=splitValue[1];
			DomainObject strObj=new DomainObject(strObjectId);
			//System.out.println("strObjectId=="+strObjectId);
		//	strObj.setAttributeValue(context,"Percent Complete","90");	
		//	int objState=strObj.setState(context,"Active");
			ContextUtil.pushContext(context);
			strObj.demote(context);
			ContextUtil.popContext(context);
		}	
%>
<script>
    alert("\u9000\u56DE\u6210\u529F!");
	parent.location.href=parent.location.href;
</script>
<%
	}else if(mode.equals("complete1")){
		try{
			String strObjectId=emxGetParameter(request,"objectId");
			String currentUser=context.getUser();		
			DomainObject strObj=new DomainObject(strObjectId);
			String sOwner = strObj.getInfo(context, "owner");			
			if(currentUser.equals(sOwner))
				{
					ContextUtil.pushContext(context);
					strObj.promote(context);
					ContextUtil.popContext(context);
				}else{
					StringList busList = new StringList("id");
					busList.add("name");
					StringList relList = new StringList(DomainRelationship.SELECT_ID);					
					MapList mapList=strObj.getRelatedObjects(context,"SEM Task Reviewer","Person", busList, relList, false, true, (short)1, "", "");
					StringList allList = new StringList();
					for(int j = 0; j < mapList.size(); j ++){
						Map map = (Map)mapList.get(j);
						String relId = (String)map.get("id[connection]");
						DomainRelationship  strRel1=new DomainRelationship (relId);
						String strName = (String)map.get("name");
						if(currentUser.equals(strName)){
							ContextUtil.pushContext(context);
							strRel1.setAttributeValue(context,"SEM Reviewed","YES");
							ContextUtil.popContext(context);
						}					
						String ss1=strRel1.getAttributeValue(context,"SEM Reviewed");
						allList.add(ss1);
					}
					if(!allList.contains("NO")){
						ContextUtil.pushContext(context);
						strObj.promote(context);
						ContextUtil.popContext(context);
					}
				}									
		}catch(Exception e){
			e.printStackTrace();
		}
	%>
<script>
    alert("\u5B8C\u6210\u64CD\u4F5C\u6210\u529F!");
	parent.location.href=parent.location.href;
</script>
	<%}else if(mode.equals("rollback1")){
		    String strObjectId=emxGetParameter(request,"objectId");
			DomainObject strObj=new DomainObject(strObjectId);
			ContextUtil.pushContext(context);
			strObj.demote(context);
			ContextUtil.popContext(context);
%>
<script>
    alert("\u9000\u56DE\u6210\u529F!");
	parent.location.href=parent.location.href;
</script>
<%
	}
%>

