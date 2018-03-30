<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@page language="java" pageEncoding="UTF-8"%>


<%
	StringList busList = new StringList("id");
    StringList relList = new StringList(DomainRelationship.SELECT_ID);
    String mode=(String)emxGetParameter(request,"mode");

	if("SelectWorkSpaceVault".equals(mode))
	{
		String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		String portalCommandName = (String)emxGetParameter(request, "portalCmdName");
		String strSelectType = "";
		String strSelectName = "";
		for(int i=0;i<emxTableRowId.length;i++)
		{
			String[] splitValue = emxTableRowId[i].split("\\|");
			String selectedId = splitValue[1];
			DomainObject strSelectObj = new DomainObject(selectedId);
			strSelectType = strSelectObj.getType(context);
			if("Project Space".equals(strSelectType))
			{
%>
			<script>
				alert("\u4E0D\u5141\u8BB8\u9009\u62E9\u9879\u76EE\uFF0C\u8BF7\u91CD\u65B0\u9009\u62E9\u6587\u4EF6\u5939\u3002");
			</script>
<%				
			}else{
				strSelectType = strSelectObj.getType(context);
				strSelectName = strSelectObj.getName(context);
%>
			<script>

				var forderName = window.top.opener.document.getElementById("forlderName");
				var forderId = window.top.opener.document.getElementById("forderId");
				forderName.value ="<%=strSelectName%>" ;
				forderId.value ="<%=selectedId%>" ;
				window.top.close();
			</script>	
<%								
			}
			
			
		}
		
		
	}else if("reloadSubType".equals(mode)){
				
		String unitValue = (String)emxGetParameter(request,"unitValue");
		ContextUtil.pushContext(context);
		String strWhere="attribute[LS Index Key1]=='SEM File Compiled Department' && current=='Active' && attribute[LS Attribute1]=='"+unitValue+"'";
		MapList LSPropertyKeyList = DomainObject.findObjects(context,"LS Property Key","*","*",null,null,strWhere,null,true,busList,(short)0);
		String returnValue="";
		Iterator it = LSPropertyKeyList.iterator();
		StringList duplicateList = new StringList();
		while(it.hasNext())
		{
			Map keyMap = (Map)it.next();
			String keyId = (String)keyMap.get("id");
			DomainObject strKeyObj = new DomainObject(keyId);
			String subType = strKeyObj.getAttributeValue(context,"LS Attribute2");	
			String secret = strKeyObj.getAttributeValue(context,"LS Attribute3");
			String policy="";
			if("\u79D8\u5BC6".equals(secret))
			{
				policy = "SEM Secret Document;\u79D8\u5BC6\u6587\u6863";
			}else if("\u673A\u5BC6".equals(secret)){
				policy = "SEM Confidential Document;\u673A\u5BC6\u6587\u6863";
			}else if("\u7EDD\u5BC6".equals(secret)){
				policy = "SEM TopSecret Document;\u7EDD\u5BC6\u6587\u6863";
			}else if("\u666E\u901A".equals(secret)){
				policy = "SEM Document;\u53D7\u63A7\u6587\u6863";
			}
			
			if(!duplicateList.contains(secret))
			{
				duplicateList.add(secret);
				returnValue+=subType+"_"+secret+"_"+policy+",";
			}else{
				returnValue+=subType+"_HID_"+policy+",";
			}
			
		}
		ContextUtil.popContext(context);
		returnValue = returnValue.substring(0,returnValue.length()-1);
		out.print(returnValue);
	}else if("reloadPolicy".equals(mode)){
		
		String secret = (String)emxGetParameter(request,"secret");
		String policy ="";
		if("\u79D8\u5BC6".equals(secret))
		{
			policy = "SEM Secret Document;\u79D8\u5BC6\u6587\u6863";
		}else if("\u673A\u5BC6".equals(secret)){
			policy = "SEM Confidential Document;\u673A\u5BC6\u6587\u6863";
		}else if("\u7EDD\u5BC6".equals(secret)){
			policy = "SEM TopSecret Document;\u7EDD\u5BC6\u6587\u6863";
		}else if("\u666E\u901A".equals(secret)){
			policy = "SEM Document;\u53D7\u63A7\u6587\u6863";
		}
		
		out.print(policy);
	}else if("reloadSubSecret".equals(mode)){
		
		String subType = (String)emxGetParameter(request,"subType");
		ContextUtil.pushContext(context);
		String strWhere="attribute[LS Index Key1]=='SEM File Compiled Department' && current=='Active' && attribute[LS Attribute2]=='"+subType+"'";
		MapList LSPropertyKeyList = DomainObject.findObjects(context,"LS Property Key","*","*",null,null,strWhere,null,true,busList,(short)0);
		String returnValue="";
		Iterator it = LSPropertyKeyList.iterator();
		while(it.hasNext())
		{
			Map keyMap = (Map)it.next();
			String keyId = (String)keyMap.get("id");
			DomainObject strKeyObj = new DomainObject(keyId);
			//String subType = strKeyObj.getAttributeValue(context,"LS Attribute2");	
			String secret = strKeyObj.getAttributeValue(context,"LS Attribute3");
			String policy="";
			if("\u79D8\u5BC6".equals(secret))
			{
				policy = "SEM Secret Document;\u79D8\u5BC6\u6587\u6863";
			}else if("\u673A\u5BC6".equals(secret)){
				policy = "SEM Confidential Document;\u673A\u5BC6\u6587\u6863";
			}else if("\u7EDD\u5BC6".equals(secret)){
				policy = "SEM TopSecret Document;\u7EDD\u5BC6\u6587\u6863";
			}else if("\u666E\u901A".equals(secret)){
				policy = "SEM Document;\u53D7\u63A7\u6587\u6863";
			}
			returnValue+=secret+"_"+policy+",";
		}
		returnValue = returnValue.substring(0,returnValue.length()-1);
		ContextUtil.popContext(context);
		out.print(returnValue);
	}
%>	