<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@page language="java" pageEncoding="UTF-8"%>
<%
  String mode=emxGetParameter(request,"mode");
  if(mode.equals("CreateSEMTestCarNumbers")){
   StringBuffer content=new StringBuffer();
   String url = "SEMCarNumber.jsp?mode=selected";
   content.append("<html>");
   content.append("<body>");
   content.append("<div class='content'>");
   content.append("<form action='"+url+"' method='post' name='Form'>");
   content.append("<table>");
   for(int i=1;i<=200;i++){
         content.append("<td><input class='checkbox' type='checkbox' id='"+i);
		 content.append("' name='checkbox'  value='");
		 content.append(i+"'/>");
		 content.append("<label  class='checkbox'>"+i+"</label>");
		 content.append("</td>");
		 if(i%10==0){
			content.append("</tr>"); 
		 }
   }
   content.append("</table>");
    content.append("<div  class='divDialogButtons'>");
   content.append("<div class='select'><label>\u5168\u9009</label>&nbsp;&nbsp;<input type='checkbox' name='ifAll' id='ifAll' onClick='checkAll()'></div>");
   content.append("<div class='kg'>");
   content.append("<input class='btn' type='button' name='but' onclick='submit()' value='\u63D0\u4EA4' />&nbsp;&nbsp;&nbsp;&nbsp;");
   content.append("<input class='btn' type='button' name='cancel' onclick='closePopupWindow(getTopWindow())' value='\u53D6\u6D88'/>");
   content.append("</div>");
   content.append("</div>");
   content.append("</form> ");
   content.append("</div>");
   content.append("<style type=\"text/css\">");
   //content.append(".checkbox{width:60px;height:60px;}");
   content.append(".content{margin:20px;}");
   //content.append(".divDialogButtons{float:right;margin:20px;}");
   content.append(".divDialogButtons{width:230px;position:fixed;bottom: 30px;right: 25px;font-size: 0;line-height: 0;z-index: 100;}");
   content.append(".select{float:left}");
   content.append(".kg{float:right;margin-right:10px;}");
   content.append(".btn{width:60px;height:30px;}");
   content.append("tr{height:20px;}");
   content.append("</style>");
   content.append("<script language=\"javascript\"  type=\"text/javascript\">");
   content.append("var objform = top.opener.document.forms['emxCreateForm'];");	
   content.append("if(objform==undefined){");	
   content.append("objform = top.opener.document.forms['editDataForm'];");		
   content.append("}");
   content.append("var str=objform.SEMTestCarsScopeDisplay.value;");
   content.append("if(str!==''){");
   content.append("var strs=new Array();strs=str.split(\",\");");
   content.append("for(i=0;i<strs.length ;i++)");
   content.append("{");
   content.append("if(document.getElementById(strs[i])!=undefined&&document.getElementById(strs[i])!=''){");
         content.append("document.getElementById(strs[i]).checked=true;");
   content.append("}");
   content.append("}");
   content.append("}");
   
   content.append("function checkAll(){");
   content.append("for (var i = 0; i < document.getElementsByName(\"checkbox\").length; i++){");
   content.append("document.getElementsByName(\"checkbox\")[i].checked = document.getElementById(\"ifAll\").checked;");
   content.append("}");
   content.append("}");
   content.append("</script>");
   
   content.append("</body>");
   out.println(content.toString());   
}else if(mode.equals("selected")){	
	String fieldNameActual = emxGetParameter(request, "fieldNameActual");
    String uiType = emxGetParameter(request, "uiType");
    String typeAhead = emxGetParameter(request, "typeAhead");
    String frameName = emxGetParameter(request, "frameName");
    String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
    String[] chk = request.getParameterValues("checkbox");
	String displayValue = "";
    for(int i=0;i<chk.length;i++){
		displayValue +=chk[i]+",";
	}
	displayValue = displayValue.substring(0,displayValue.length()-1);
%>	
	<script language="javascript" type="text/javaScript">
		var objform = top.opener.document.forms['emxCreateForm'];
		if(objform==undefined){
			objform = top.opener.document.forms['editDataForm'];
		}
		objform.SEMTestCarsScopeDisplay.value="<%=displayValue%>";
		objform.SEMTestCarsScope.value="<%=displayValue%>";
		getTopWindow().closeWindow();
	</script>
<%
}else if(mode.equals("CreateIssue")){
  String projectId=emxGetParameter(request,"projectId");
   String IssueType=emxGetParameter(request,"IssueType");
   String IssuePhase=emxGetParameter(request,"IssuePhase");
  // System.out.println("projectId---"+projectId);
   StringList busList = new StringList("id");
   StringList relList = new StringList(DomainRelationship.SELECT_ID);
   DomainObject projectObj=new DomainObject(projectId);
   String result="";
   String where="attribute[SEM Issue Type]=='"+IssueType+"'&&attribute[SEM Issue Phase]=='"+IssuePhase+"'";  
   MapList mapList= projectObj.getRelatedObjects(context,"SEM Prject TestCars","SEM TestCar Numbers", busList, relList,false,true,(short)1,where, null);
   if(mapList.size()>0){
	   Map map=(Map)mapList.get(0);
	   String id=(String)map.get("id");
	   result=new DomainObject(id).getAttributeValue(context,"SEM TestCars Scope");
   }
   String where1="attribute[SEM Issue Type]=='\u901A\u7528'&&attribute[SEM Issue Phase]=='"+IssuePhase+"'";  
   if(result.equals("")){
	   MapList mapList1=projectObj.getRelatedObjects(context,"SEM Prject TestCars", "SEM TestCar Numbers", busList, relList,false,true,(short)1,where1,null);
	   if(mapList1.size()>0){
	   Map map1=(Map)mapList1.get(0);
	   String id1=(String)map1.get("id");
	   result=new DomainObject(id1).getAttributeValue(context,"SEM TestCars Scope");
       }
   }
   String where2="attribute[SEM Issue Type]=='\u901A\u7528'&&attribute[SEM Issue Phase]=='\u901A\u7528'";
   if(result.equals("")){
	   MapList mapList2=projectObj.getRelatedObjects(context,"SEM Prject TestCars","SEM TestCar Numbers", busList, relList,false,true,(short)1,where2, null);
	   if(mapList2.size()>0){
	   Map map2=(Map)mapList2.get(0);
	   String id2=(String)map2.get("id");
	   result=new DomainObject(id2).getAttributeValue(context,"SEM TestCars Scope");
       }
   }
   StringBuffer content=new StringBuffer();
   String url = "SEMCarNumber.jsp?mode=selectedIssue";
   content.append("<html>");
   content.append("<body>");
   content.append("<div class='content'>");
   content.append("<form action='"+url+"' method='post' name='Form'>");
   content.append("<table>");
   String[] rows=result.split(",");
   for(int j=0;j<rows.length;j++){
         content.append("<td><input class='checkbox' type='checkbox' id='"+rows[j]);
		 content.append("' name='checkbox'  value='");
		 content.append(rows[j]+"'/>");
		 content.append("<label  class='checkbox'>"+rows[j]+"</label>");
		 content.append("</td>");
		 if(j!=0&&j%6==0){
			content.append("</tr>"); 
		 }
    }
   content.append("</table>");
   content.append("<div  class='divDialogButtons'>");
   content.append("<div class='select'><label>\u5168\u9009</label>&nbsp;&nbsp;<input type='checkbox' name='ifAll' id='ifAll' onClick='checkAll()'></div>");
   content.append("<div class='kg'>");
   content.append("<input class='btn' type='button' name='but' onclick='submit()' value='\u63D0\u4EA4' />&nbsp;&nbsp;&nbsp;&nbsp;");
   content.append("<input class='btn' type='button' name='cancel' onclick='closePopupWindow(getTopWindow())' value='\u53D6\u6D88'/>");
   content.append("</div>");
   content.append("</div>");
   content.append("</form> ");
   content.append("</div>");
   content.append("<style type=\"text/css\">");
   //content.append(".checkbox{width:60px;height:60px;}");
   content.append(".content{margin:20px;}");
   //content.append(".divDialogButtons{float:right;margin:20px;}");
   content.append(".divDialogButtons{width:230px;position:fixed;bottom: 30px;right: 25px;font-size: 0;line-height: 0;z-index: 100;}");
   content.append(".select{float:left}");
   content.append(".kg{float:right;margin-right:10px;}");
   content.append(".btn{width:60px;height:30px;}");
   content.append("tr{height:20px;}");
   content.append("</style>");
   content.append("<script language=\"javascript\"  type=\"text/javascript\">");
   content.append("var objform = top.opener.document.forms['emxCreateForm'];");
   content.append("if(objform==undefined){");	
   content.append("objform = top.opener.document.forms['editDataForm'];");		
   content.append("}");
   content.append("var str=objform.SEMIssueTestCarCodeDisplay.value;");
   content.append("if(str!==''){");
   content.append("var strs=new Array();strs=str.split(\",\");");
   content.append("for(i=0;i<strs.length ;i++)");
   content.append("{");
   content.append("if(document.getElementById(strs[i])!=undefined&&document.getElementById(strs[i])!=''){");
         content.append("document.getElementById(strs[i]).checked=true;");
   content.append("}");
   content.append("}");
   content.append("}");
   
   content.append("function checkAll(){");
   content.append("for (var i = 0; i < document.getElementsByName(\"checkbox\").length; i++){");
   content.append("document.getElementsByName(\"checkbox\")[i].checked = document.getElementById(\"ifAll\").checked;");
   content.append("}");
   content.append("}");
   content.append("</script>");
   
   content.append("</body>");
   out.println(content.toString());  	
}else if(mode.equals("selectedIssue")){	
	String fieldNameActual = emxGetParameter(request, "fieldNameActual");
    String uiType = emxGetParameter(request, "uiType");
    String typeAhead = emxGetParameter(request, "typeAhead");
    String frameName = emxGetParameter(request, "frameName");
    String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
    String[] chk = request.getParameterValues("checkbox");
	String displayValue = "";
    for(int i=0;i<chk.length;i++){
		displayValue +=chk[i]+",";
	}
	displayValue = displayValue.substring(0,displayValue.length()-1);
%>	
	<script language="javascript" type="text/javaScript">
		var objform = top.opener.document.forms['emxCreateForm'];
		if(objform==undefined){
			objform = top.opener.document.forms['editDataForm'];
		}
		objform.SEMIssueTestCarCodeDisplay.value="<%=displayValue%>";
		objform.SEMIssueTestCarCode.value="<%=displayValue%>";
		getTopWindow().closeWindow();
	</script>
<%
}
%>