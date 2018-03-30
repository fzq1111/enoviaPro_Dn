<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@page language="java" pageEncoding="UTF-8"%>
<% 
	String mode=emxGetParameter(request,"mode");
	StringList busList = new StringList("id");
    StringList relList = new StringList(DomainRelationship.SELECT_ID);
	if(mode.equals("Reoccurence"))
	{
		String msg="";
	    StringList list=new StringList();
		String[] emxTableRowId= emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue=emxTableRowId[i].split("\\|");
			String strObjectId=splitValue[1];	
			DomainObject strObj=new DomainObject(strObjectId);
			State StateObj=strObj.getCurrentState(context);
			if(StateObj.getName().equals("Closed"))
			{
				list.addElement(strObjectId);
			}else{
				msg="\u6240\u9009\u62E9\u7684\u95EE\u9898\u5FC5\u987B\u90FD\u5728\u5173\u95ED\u72B6\u6001!";
				break;
			}
		}
	    if(msg.equals("")){
			for(int j=0;j<list.size();j++){
				DomainObject issueObj=new DomainObject((String)list.get(j));
				issueObj.setState(context,"Assign");
			}
%>
            <script type="text/javascript">
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
}else if(mode.equals("DirectDistribution"))
	{
		String currentUser=context.getUser();
		String[] emxTableRowId=emxGetParameterValues(request, "emxTableRowId");
		StringList list=new StringList();
		String msg="";
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue=emxTableRowId[i].split("\\|");
			String strObjectId=splitValue[1];
			DomainObject strObj=new DomainObject(strObjectId);
			String sOwner=strObj.getInfo(context, "owner");	
			String name=strObj.getName(context);
			State StateObj=strObj.getCurrentState(context);
			StringList personIdList =strObj.getInfoList(context,"to[Assigned Issue].from.id");
			if(StateObj.getName().equals("Create"))
			{
				if(!currentUser.equals(sOwner)){
					msg="\u5F53\u524D\u7528\u6237\u4E0D\u662F\u95EE\u9898"+name+"\u7684\u6240\u6709\u8005\uFF0C\u65E0\u6CD5\u5206\u914D!";
					break;
				}
				if(personIdList.size()==0){
					msg="\u6240\u9009\u95EE\u9898\u7F3A\u5C11\u95EE\u9898\u5BF9\u7B56\u4EBA\uFF0C\u8BF7\u91CD\u65B0\u9009\u62E9!";
					break;
				}else{
					list.addElement(strObjectId);
				}
			}else{
				msg="\u6240\u9009\u62E9\u7684\u95EE\u9898\u5FC5\u987B\u90FD\u5728\u521B\u5EFA\u72B6\u6001!";
				break;
			}
		}	
		if(msg.equals("")){
			for(int j=0;j<list.size();j++){
				DomainObject issueObj=new DomainObject((String)list.get(j));
				issueObj.setState(context,"Assign");
			}
%>
            <script type="text/javascript">
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
	}else if(mode.equals("DirectResponse"))
	{
		String currentUser=context.getUser();
		StringList list=new StringList();
		String msg="";
		String[] emxTableRowId= emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue=emxTableRowId[i].split("\\|");
			String strObjectId=splitValue[1];
			DomainObject strObj=new DomainObject(strObjectId);
			String name=strObj.getName(context);
			State StateObj=strObj.getCurrentState(context);
		    if(StateObj.getName().equals("Assign")||StateObj.getName().equals("Active"))
		    {
			   boolean isAssigned=false;
			   StringList personNameList=strObj.getInfoList(context,"to[Assigned Issue].from.name");
			   for(int j=0;j<personNameList.size();j++){
				   String personName=(String)personNameList.get(j);
				   if(currentUser.equals(personName)){
					   isAssigned=true;
					   break;
				   }
			   }
			   if(!isAssigned){
				   msg="\u5F53\u524D\u7528\u6237\u4E0D\u662F\u95EE\u9898"+name+"\u7684\u5BF9\u7B56\u4EBA\uFF0C\u65E0\u6CD5\u56DE\u590D!";
				   break;
			   }
               list.add(strObjectId);
		    }else{
				msg="\u6240\u9009\u62E9\u7684\u95EE\u9898\u5FC5\u987B\u90FD\u5728\u5206\u914D\u6216\u6D3B\u52A8\u72B6\u6001!";
				break;
			}
		}	
		if(msg.equals("")){
			for(int j=0;j<list.size();j++){
				DomainObject issueObj=new DomainObject((String)list.get(j));
				issueObj.setState(context,"Review");
			}
%>
<script type="text/javascript">
  parent.location.href=parent.location.href;
</script>
<% 
		}else{
%>
			<script type="text/javascript">
              alert("<%=msg%>");
            </script>
<%		}
}else if(mode.equals("Approvedistribution"))
{
	String currentUser=context.getUser();
	String emxTableRowId[]=emxGetParameterValues(request,"emxTableRowId");
	StringList strProId = new StringList();
	String objectId=null;
	StringBuffer qStringBuff= new StringBuffer();
	String msg="";
	StringList busList1= new StringList("id");
	busList1.add("name");
    for(int i=0;i<emxTableRowId.length;i++)
	{
		String[] splitValue = emxTableRowId[i].split("\\|");
		String strObjId =splitValue[1];
		DomainObject strFromObj = new DomainObject(strObjId);
		MapList mapList1=strFromObj.getRelatedObjects(context,"Issue","Project Space",busList1,relList,true,false,(short)1,null,null);
		for(int j=0;j<mapList1.size();j++){
				Map projMap = (Map)mapList1.get(j);
			    objectId = (String)projMap.get("id");					
			}
		strProId.add(objectId);	
		String sOwner=strFromObj.getInfo(context, "owner");	
		String name=strFromObj.getName(context);
		State StateObj=strFromObj.getCurrentState(context);
		StringList personIdList =strFromObj.getInfoList(context,"to[Assigned Issue].from.id");
	    if(StateObj.getName().equals("Create"))
		{
			if(!currentUser.equals(sOwner)){
					msg="\u5F53\u524D\u7528\u6237\u4E0D\u662F\u95EE\u9898"+name+"\u7684\u6240\u6709\u8005\uFF0C\u65E0\u6CD5\u5206\u914D!";
					break;
			}
			if(personIdList.size()==0){
				msg="\u6240\u9009\u95EE\u9898\u7F3A\u5C11\u95EE\u9898\u5BF9\u7B56\u4EBA\uFF0C\u8BF7\u91CD\u65B0\u9009\u62E9!";
			    break;
			}else{
				qStringBuff.append(strObjId+"|");
			}
		}else{
				msg="\u6240\u9009\u62E9\u7684\u95EE\u9898\u5FC5\u987B\u90FD\u5728\u521B\u5EFA\u72B6\u6001!";
				break;
		}
		String fromName=strFromObj.getName(context);
		String where="attribute[SEM Approval Type]=='\u95EE\u9898\u5206\u914D\u5BA1\u6279'&&current!='Complete'";
	    MapList mapList=strFromObj.getRelatedObjects(context,"Affected Item","SEM Approve Order",busList1,relList,true,false,(short)1,where,null);
		if(mapList.size()>0){
			Map map=(Map)mapList.get(0);
			String toName=(String)map.get("name");
			msg=fromName+"\u95EE\u9898\u8FD8\u5728\u5BA1\u6279\u5355"+toName+"\u4E2D\u5BA1\u6279";
			break;
		}
	}
	if(strProId.size()>1){
		try{
			for(int k=0;k<strProId.size();k++){
			String strk1 = (String)strProId.get(k);
			String strk2 = (String)strProId.get(k+1);
				if(!strk1.equals(strk2)){
					msg = "\u8bf7\u9009\u62e9\u76f8\u540c\u9879\u76ee\u4e0b\u7684\u95ee\u9898\uff01";
					break;
				}else{
					objectId = (String)strProId.get(0);
				}				
			}
		}catch(Exception e){
			e.printStackTrace();
		}
		
	}
	String rows=qStringBuff.toString();
	if(msg.equals("")){
		String url="emxCreate.jsp?type=type_SEMApproveOrder&policy=policy_SEMApproveOrder&form=type_CreateSEMApproveOrder&nameField=autoName&createJPO=SEMACO:issueCreateNewSAO&relationship=relationship_SEMProjectChange&header=emxFramework.Common.CreateApproveOrder&LSvalidateCreate=true&submitAction=refreshCaller&typeflag=adb";
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
        <script type="text/javascript">
            alert("<%=msg%>");
			window.top.close();
        </script>
<% 		
	}	
}else if(mode.equals("StrategyApprove"))
{
	String currentUser=context.getUser();				
	String msg="";
	StringList busList1= new StringList("id");
	busList1.add("name");
	String emxTableRowId[]=emxGetParameterValues(request,"emxTableRowId");
	StringList strProId = new StringList();
	String objectId=null;			
	String strObjId = null;			
	StringBuffer qStringBuff= new StringBuffer();
    for(int i=0;i<emxTableRowId.length;i++)
	{
		String[] splitValue = emxTableRowId[i].split("\\|");
	    strObjId =splitValue[1];
		DomainObject strFromObj = new DomainObject(strObjId);
		MapList mapList1=strFromObj.getRelatedObjects(context,"Issue","Project Space",busList1,relList,true,false,(short)1,null,null);
		for(int j=0;j<mapList1.size();j++){
				Map projMap = (Map)mapList1.get(j);
			    objectId = (String)projMap.get("id");							
			}
		strProId.add(objectId);
		String name=strFromObj.getName(context);
		State StateObj=strFromObj.getCurrentState(context);
		String ResolutionRecommendation=strFromObj.getAttributeValue(context,"Resolution Recommendation");
		String ResolutionDate=strFromObj.getAttributeValue(context,"Resolution Date");
	    if(StateObj.getName().equals("Assign")||StateObj.getName().equals("Active"))
		{
			boolean isAssigned=false;
			StringList personNameList=strFromObj.getInfoList(context,"to[Assigned Issue].from.name");
			for(int j=0;j<personNameList.size();j++){
				String personName=(String)personNameList.get(j);
				if(currentUser.equals(personName)){
					   isAssigned=true;
					   break;
			    }
			}
			if(!isAssigned){
				msg="\u5F53\u524D\u7528\u6237\u4E0D\u662F\u95EE\u9898"+name+"\u7684\u5BF9\u7B56\u4EBA\uFF0C\u65E0\u6CD5\u56DE\u590D!";
				break;
			}
			if(ResolutionRecommendation==null||ResolutionRecommendation.equals("")){
				msg="\u95EE\u9898"+name+"\u7684\u5BF9\u7B56\u6539\u5584\u8BF4\u660E\u4E3A\u7A7A\uFF0C\u65E0\u6CD5\u56DE\u590D!";
				break;
			}
			if(ResolutionDate==null||ResolutionDate.equals("")){
				msg="\u95EE\u9898"+name+"\u7684\u5BF9\u7B56\u65E5\u671F\u4E3A\u7A7A\uFF0C\u65E0\u6CD5\u56DE\u590D!";
				break;
			}
			qStringBuff.append(strObjId+"|");
		}else{
				msg="\u6240\u9009\u62E9\u7684\u95EE\u9898\u5FC5\u987B\u90FD\u5728\u5206\u914D\u6216\u6D3B\u52A8\u72B6\u6001!";
				break;
		}
		String fromName=strFromObj.getName(context);
		String where="attribute[SEM Approval Type]=='\u95EE\u9898\u5BF9\u7B56\u5BA1\u6279'&&current!='Complete'";
	    MapList mapList=strFromObj.getRelatedObjects(context,"Affected Item","SEM Approve Order",busList1,relList,true,false,(short)1,where,null);
		if(mapList.size()>0){
			Map map=(Map)mapList.get(0);
			String toName=(String)map.get("name");
			msg=fromName+"\u95EE\u9898\u8FD8\u5728\u5BA1\u6279\u5355"+toName+"\u4E2D\u5BA1\u6279";
			break;
		}
	}
	if(strProId.size()>1){
		try{
			for(int k=0;k<strProId.size();k++){
			String strk1 = (String)strProId.get(k);
			String strk2 = (String)strProId.get(k+1);
				if(!strk1.equals(strk2)){
					msg = "\u8bf7\u9009\u62e9\u76f8\u540c\u9879\u76ee\u4e0b\u7684\u95ee\u9898\uff01";
					break;
				}else{
					objectId = (String)strProId.get(0);
				}				
			}
		}catch(Exception e){
			e.printStackTrace();
		}
		
	}
	if(msg.equals("")){
		
	String rows=qStringBuff.toString();
	String url="emxCreate.jsp?type=type_SEMApproveOrder&policy=policy_SEMApproveOrder&form=type_CreateSEMApproveOrder&nameField=autoName&createJPO=SEMACO:issueCreateNewSAO&relationship=relationship_SEMProjectChange&header=emxFramework.Common.CreateApproveOrder&LSvalidateCreate=true&submitAction=refreshCaller&typeflag=sa";
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
		 <script type="text/javascript">
            alert("<%=msg%>");
			window.top.close();
        </script>
<%
	}
}else if(mode.equals("AssignedIssue")){
		String IssueId=(String)emxGetParameter(request,"IssueId");
		String tableId=(String)emxGetParameter(request,"tableId");
		DomainObject IssueObj = new DomainObject(IssueId);
		MapList personList = IssueObj.getRelatedObjects(context,"Assigned Issue","Person",busList,relList,true,false,(short)1,"","");
		Iterator it = personList.iterator();
		while(it.hasNext())
		{
			Map personMap = (Map)it.next();
			String relId = (String)personMap.get("id[connection]");
			DomainRelationship.disconnect(context, relId);
		}
		String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue = emxTableRowId[i].split("\\|");
			String personId = splitValue[1];
			DomainObject personObj = new DomainObject(personId);			 
			ContextUtil.pushContext(context);	
			DomainRelationship del = personObj.connectTo(context,"Assigned Issue",IssueObj); 			
			ContextUtil.popContext(context);
		}
		%>
	<script>
		window.top.opener.emxEditableTable.refreshRowByRowId("<%=tableId%>");
		window.top.close();
	</script>
<%
	}else if("removePerson".equals(mode))
    {
		String IssueId=(String)emxGetParameter(request,"IssueId");
		DomainObject IssueObj = new DomainObject(IssueId);
		MapList personList = IssueObj.getRelatedObjects(context,"Assigned Issue","Person",busList,relList,true,false,(short)1,"","");
		Iterator it = personList.iterator();
		while(it.hasNext())
		{
			Map personMap = (Map)it.next();
			String relId = (String)personMap.get("id[connection]");
			DomainRelationship.disconnect(context, relId);
		}	
	}else if(mode.equals("createIssue")){
		String projectId=emxGetParameter(request,"objectId");
		DomainObject projectObj=new DomainObject(projectId);
        if(projectObj.getType(context).equals("Issue")){
	     MapList ProjectList=projectObj.getRelatedObjects(context,"Issue","Project Space", busList, relList,true,false,(short)1,"", null);
	     if(ProjectList.size()>0){
		   Map projectMap=(Map)ProjectList.get(0);
		   String Id=(String)projectMap.get("id");
		   projectId=Id;
	     }
		}		
%>
 	<script language="javascript" type="text/javaScript">
		var objform = top.opener.document.forms['emxCreateForm'];
		if(objform==undefined){
			objform = top.opener.document.forms['editDataForm'];
		}
		var IssueType=objform.SEMIssueType.value;
		var IssuePhase=objform.SEMIssuePhase.value;
		var strURL="SEMCarNumber.jsp?mode=CreateIssue&IssueType="+IssueType+"&IssuePhase="+IssuePhase+"&projectId=<%=projectId%>";
		window.top.location.href=strURL;
	</script>
<%
	}
%>



