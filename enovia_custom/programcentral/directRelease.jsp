<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page language="java" pageEncoding="UTF-8"%>
<% 
	String mode=emxGetParameter(request,"mode");
	if(mode.equals("directRelease"))
	{
			String objectId = emxGetParameter(request, "objectId");
			DomainObject strObj=new DomainObject(objectId);	
			StringList busList = new StringList("id");
			StringList relList = new StringList(DomainRelationship.SELECT_ID);
			MapList maplist1=strObj.getRelatedObjects(context,"Object Route","Route", busList, relList, false, true, (short)1, "", "");
			ContextUtil.pushContext(context);	
			MqlUtil.mqlCommand(context, "trigger off;", true);
			try{
				for(int i=0;i<maplist1.size();i++)
				{
					Map map1=(Map)maplist1.get(i);

					String relId = (String) map1.get(DomainRelationship.SELECT_ID);

					if(relId.length()>0)
					{
						DomainRelationship.disconnect(context,relId);
					}else
					{
						continue;
					}
				}
				//ContextUtil.pushContext(context);
				strObj.gotoState(context,"Released");
				//ContextUtil.popContext(context);
			}finally{
				MqlUtil.mqlCommand(context, "trigger on;", true);
				ContextUtil.popContext(context);
			}
			
	%>
    <script type="text/javascript">
	   alert("\u53D1\u5E03\u6210\u529F!");
       var  detailsDisplay=window.parent.frames["content"];
	   if(detailsDisplay==undefined){
			 parent.location.href=parent.location.href;
	   }else{
			 detailsDisplay.location.href =detailsDisplay.location.href; 
	   }
     </script>

<%
	}else if(mode.equals("directRelease1")){
		String msg="";
		String currentUser=context.getUser();
		StringList list=new StringList();
	    StringList busList = new StringList("id");
	    StringList relList = new StringList(DomainRelationship.SELECT_ID);
		String emxTableRowId[]=emxGetParameterValues(request,"emxTableRowId");
        for(int i=0;i<emxTableRowId.length;i++)
	    {
		   String[] splitValue = emxTableRowId[i].split("\\|");
	 	   String strObjId =splitValue[1];
		   DomainObject strObj=new DomainObject(strObjId);
		   String sOwner = strObj.getInfo(context, "owner");
		   String name=strObj.getName(context);
		   String state=strObj.getCurrentState(context).getName();
		   if(state.equals("RELEASED")){
			   msg="\u6587\u6863"+name+"\u5DF2\u7ECF\u5904\u4E8E\u53D1\u5E03\u72B6\u6001\uFF0C\u8BF7\u91CD\u65B0\u9009\u62E9!";
			   break;
		   }
		   if(currentUser.equals(sOwner)){
			   list.add(strObjId);  
		   }else{
			   msg="\u5F53\u524D\u7528\u6237\u4E0D\u662F\u6587\u6863"+name+"\u7684\u6240\u6709\u8005\uFF0C\u8BF7\u91CD\u65B0\u9009\u62E9!";
			   break;
		   }
	    }
		if(msg.equals("")){
		 try{
			//ContextUtil.pushContext(context);	
			for(int j=0;j<list.size();j++){
				String objectId=(String)list.get(j);
				DomainObject strObj=new DomainObject(objectId);	
			    MapList maplist1=strObj.getRelatedObjects(context,"Object Route","Route", busList, relList, false, true, (short)1, "", "");
			    MqlUtil.mqlCommand(context, "trigger off;", true);
				for(int i=0;i<maplist1.size();i++)
				{
					Map map1=(Map)maplist1.get(i);

					String relId = (String) map1.get(DomainRelationship.SELECT_ID);

					if(relId.length()>0)
					{
						DomainRelationship.disconnect(context,relId);
					}else
					{
						continue;
					}
				}
				
				strObj.gotoState(context,"Released");
			}}finally{
				MqlUtil.mqlCommand(context, "trigger on;", true);
				//ContextUtil.popContext(context);
			}
	
%>
<script type="text/javascript">
       alert("\u53D1\u5E03\u6210\u529F!");
       parent.location.href=parent.location.href;
</script>
<%
		}else{
%>
          <script type="text/javascript">
			alert("<%=msg%>");
          </script>
<%
		}
}
%>