<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page language="java" pageEncoding="UTF-8"%>
<% 
		StringList busList = new StringList("id");
	StringList relList = new StringList(DomainRelationship.SELECT_ID);
	 String strRelName = emxGetParameter(request,"relName");
	String mode=emxGetParameter(request,"mode");
	if(mode.equals("delete"))
	{
		String[] emxTableRowId=emxGetParameterValues(request,"emxTableRowId");
		//System.out.println("emxTableRowId====="+emxTableRowId[0]);
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue=emxTableRowId[i].split("\\|");
			String strObjectId=splitValue[1];
			DomainObject strObj=new DomainObject(strObjectId);
			ContextUtil.pushContext(context);
			strObj.delete(context);
			ContextUtil.popContext(context);
		}
	%>
<script>
	parent.location.href=parent.location.href;
</script>
<%
	}else if(mode.equals("remove"))
	{
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
<script>
		parent.location.href =parent.location.href ;
</script>
  
	<%	}else if("addExisting".equals(mode))
  {
	    strRelName=PropertyUtil.getSchemaProperty(context,strRelName);
		String errorMsg = "";
		try{
			String objectId=(String)emxGetParameter(request,"objectId");
			DomainObject strToObj = new DomainObject(objectId);
			String meetType = strToObj.getType(context);
			if("SEM Contact Order".equals(meetType)){				
				MapList resList = strToObj.getRelatedObjects(context, "SEM Meeting ContactOrder", "Meeting", busList, relList, true, false, (short)1, null, null);
				for(int i = 0; i < resList.size(); i ++)
				{
					Map resMap = (Map)resList.get(i);
					objectId = (String)resMap.get("id");
					strToObj = new DomainObject(objectId);
				}
			}
			String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
			for(int i=0;i<emxTableRowId.length;i++)
			{
				String[] splitValue = emxTableRowId[i].split("\\|");
			    Map<String,String> mplist=new HashMap<String,String>();
				String strObjId = splitValue[1];
				DomainObject strObj = new DomainObject(strObjId);
				String strName = strObj.getName(context);
				MapList mapList = strObj.getRelatedObjects(context,strRelName, "*", busList, relList,false,true,(short)1, null, null);
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
					DomainRelationship rel=strToObj.connectFrom(context,strRelName,strObj);				
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
		
	
	}
%>

