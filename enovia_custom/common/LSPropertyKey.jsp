<%@include file = "emxNavigatorInclude.inc"%>
<%@page language="java" pageEncoding="UTF-8"%>

<%
StringList busList = new StringList("id");
StringList relList = new StringList(DomainRelationship.SELECT_ID);
        String mode = emxGetParameter(request, "mode");
        if(mode.equals("delete"))
        {	
        	String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
        	//System.out.println("emxTableRowId====="+emxTableRowId[0]);
        	for(int i=0;i<emxTableRowId.length;i++)
        	{
        	   String[]	splitValue = emxTableRowId[i].split("\\|");  
        	   String strObjId = splitValue[1];                       
        	   DomainObject strObj =new DomainObject(strObjId);
        	   ContextUtil.pushContext(context);
        	   strObj.delete(context);
        	   ContextUtil.popContext(context);
        	}
%>
     <script>
     parent.location.href =parent.location.href;
     </script>
<%      		
        }
        else if(mode.equals("remove"))
        {
        



        String objectId = emxGetParameter(request,"objectId");
		DomainObject strFromObj = new DomainObject(objectId);
		String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue = emxTableRowId[i].split("\\\\|");
			
			String sRelationshipIds = splitValue[0];
			ContextUtil.pushContext(context);
			DomainRelationship.disconnect(context, sRelationshipIds);
			ContextUtil.popContext(context);

		}
%>		
	<script>
		parent.location.href =parent.location.href ;

	</script>
	
<%   } 

        
        
       

     else if("addExisting".equals(mode))
	{
	
		String errorMsg = "";
		try{
			String objectId = emxGetParameter(request,"objectId");
			DomainObject strFromObj = new DomainObject(objectId);
			String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
			for(int i=0;i<emxTableRowId.length;i++)
			{
				String[] splitValue = emxTableRowId[i].split("\\\\|");
			
				String strObjId = splitValue[1];
				DomainObject strObj = new DomainObject(strObjId);
				String strName = strObj.getName(context);
				MapList mapList = strObj.getRelatedObjects(context, "LS Sub Course", "*", busList, relList, true, false, (short)1, null, null);
				if(mapList.size()>0)
				{
					Iterator it = mapList.iterator();
					while(it.hasNext()){
						Map map = (Map)it.next();
						String id = (String)map.get("id");
						DomainObject parentObj = new DomainObject(id);
						String parentName = parentObj.getName(context);
						errorMsg +=" \u57F9\u8BAD\u8BFE\u7A0B:"+strName+"\u5DF2\u5173\u8054\u5230:"+parentName+",\u8BF7\u91CD\u65B0\u9009\u62E9.\\n";
					}
					continue;
					
				}else{
					ContextUtil.pushContext(context);
					DomainRelationship rel = strFromObj.connectTo(context,"LS Sub Course",strObj);		
					ContextUtil.popContext(context);
				}

			}
		}catch(Exception e){
			String msg = e.getMessage();
			throw new Exception(msg);
		}
		if(errorMsg==""){
%>
<!--  先刷新   然后关闭页面-->
		<script>
		 window.top.opener.location.href = window.top.opener.location.href;
		 window.top.close();
		</script>
<%			
		
		}else{
%>
		<script>
			alert("<%=errorMsg%>");
		</script>
<%			
		}
	
	}
%>


