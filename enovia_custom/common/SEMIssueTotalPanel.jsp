<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<title><%="\u95EE\u9898\u8FDB\u5EA6\u9762\u677F"%></title>  <!--问题进度面板-->
<style type="text/css">
<!--
.STYLE1 {font-size: 24px}
-->
</style>
</head>

<body>
<table width="800" height="48" border="1">
  <tr>
    <td height="42"><div align="center" class="STYLE1"><%="\u95EE\u9898\u8FDB\u5EA6\u9762\u677F"%></div></td> <!--问题进度面板-->
  </tr>
</table>
<table width="800" height="36" border="1">
  <tr>
    <td width="137"><form id="form1" name="form1" method="post" action="">
<%
	String strUrl = "../common/emxFullSearch.jsp?field=TYPES=type_Issue&showInitialResults=false&HelpMarker=emxhelpfullsearch&table=AEFGeneralSearchResults&selection=multiple"+
	"&submitURL=../common/SEMIssueTotablPanelProcess.jsp?mode=getIssuesFromSearch";
	
	
	

%>
<script type="text/javascript">
	
	function submitForm()
	{		
		var panelAttributeValue = document.getElementById("panelAttribute").value;	
		var url="../common/SEMIssueTotablPanelProcess.jsp?mode=createTableHasPanelValue&panelAttributeValue="+panelAttributeValue;
		if(panelAttributeValue!=null && panelAttributeValue!="")
		{
			url="../common/SEMIssueTotablPanelProcess.jsp?mode=createTableHasPanelValue&panelAttributeValue="+panelAttributeValue;			
			if(panelAttributeValue=="SEM Issue TestCarCode")
			{
				url="../common/SEMIssueTotablPanelProcess.jsp?mode=createViewTableSplitDouHao&panelAttributeValue="+panelAttributeValue;;
			}
		}else{
			url="../common/SEMIssueTotablPanelProcess.jsp?mode=createViewTable";			
		}							
		
		window.open(url,"","width=1px,height=1px"); 
		
	}
	

	function setPanelValue()
	{
		var panelAttributeValue = document.getElementById("panelAttribute").value;	
		var url="../common/SEMIssueTotablPanelProcess.jsp?mode=setPanelValue&panelAttributeValue="+panelAttributeValue;
		window.open(url,"","width=1px,height=1px"); 
	}

	function clearValue()
	{
		
		var url="../common/SEMIssueTotablPanelProcess.jsp?mode=clearValue";
		window.open(url,"","width=1px,height=1px"); 
	}

	function searchIssue()
	{
		
		var url="<%=strUrl%>";
		window.open(url,"","width=1px,height=1px"); 
	}	
</script>

			 
		 


	<label>
        <input type="submit" name="Submit1" id="Submit1" style='font-size:14px' onClick="javascript:searchIssue()" value=<%="\u641C\u7D22\u95EE\u9898"%> /><!--搜索问题-->
		<input type="hidden" id="getSelectedIds" name="getSelectedIds"></input>
    </label>
    </form>
    </td>
	

    <td width="205">
	  <form id="form2" name="form2" method="post" action="">
      <label>
        <select name="select" id="panelAttribute"  onchange="javascript:setPanelValue()">

		 <option value="" selected="selected"><%="\u9762\u677F\u5C5E\u6027"%></option>  <!--面板属性-->	
          <option value="SEM Issue Type"><%="\u95EE\u9898\u5206\u7C7B"%></option>							    <!--问题分类-->
          <option value="owner"><%="\u6240\u6709\u8005"%></option>											<!--所有者-->
          <option value="Department"><%="\u6240\u6709\u8005\u7EC4"%></option>									<!--所有者组-->
          <option value="Originator"><%="\u521B\u5EFA\u4EBA"%></option>									<!--创建人-->
          <option value="Originated"><%="\u521B\u5EFA\u65F6\u95F4"%></option><!--创建时间-->
          <option value="SEM Issue Submiter"><%="\u6307\u6458\u4EBA"%></option><!--指摘人-->
          <option value="SEM Issue HappenDate"><%="\u6307\u6458\u65E5\u671F"%></option><!--指摘日期-->
          <option value="Actual End Date"><%="\u5173\u95ED\u65E5\u671F"%></option><!--关闭日期-->
          <option value="SEM Remark"><%="\u5907\u6CE8"%></option><!--备注-->
		  
          <option value="Estimated End Date"><%="\u5BF9\u7B56\u671F\u9650"%></option><!--对策期限-->
          <option value="SEM Phase To Resolution"><%="\u6539\u5584\u5BF9\u5E94\u9636\u6BB5"%></option><!--改善对应阶段-->
          <option value="SEM Issue EO"><%="EO\u7F16\u53F7"%></option><!--EO编号-->
          <option value="SEM Issue SolutionResult"><%="\u5BF9\u7B56\u5224\u5B9A\u7ED3\u679C"%></option><!--对策判定结果-->
          <option value="Assigned Issue"><%="\u5BF9\u7B56\u4EBA"%></option><!--对策人-->
          <option value="Department"><%="\u5BF9\u7B56\u4EBA\u7EC4"%></option><!--对策人组-->
          <option value="SEM Issue Undertaker"><%="\u627F\u529E"%></option><!--承办-->
          <option value="SEM Supplier"><%="\u5382\u5546"%></option><!--厂商-->
          <option value="Priority"><%="\u7D27\u6025\u5EA6"%></option><!--紧急度-->
          <option value="SEM IssueImportance ID"><%="\u91CD\u8981\u6807\u8BC6"%></option><!--重要标识-->
          <option value="SEM Issue Phase"><%="\u8BD5\u88C5\u9636\u6BB5"%></option><!--试装阶段-->
          <option value="SEM Issue Repeat"><%="\u91CD\u590D\u53D1\u751F"%></option><!--重复发生-->
          <option value="SEM Issue Major"><%="\u533A\u5206"%></option><!--区分-->
          <option value="SEM Issue Class"><%="\u7C7B\u522B"%></option><!--类别-->
          <option value="SEM Issue Line"><%="\u7EBF\u522B"%></option><!--线别-->
          <option value="SEM Issue PartType"><%="\u96F6\u4EF6\u7CFB\u7EDF"%></option><!--零件系统-->
          <option value="SEM Issue Section"><%="\u53D1\u751F\u90E8\u4F4D"%></option><!--发生部位-->
          <option value="SEM Issue TestCarCode"><%="\u53D1\u751F\u8F66\u53F7"%></option><!--发生车号-->
          <option value="SEM IssueCar Number"><%="\u53D1\u751F\u53F0\u6570"%></option><!--发生台数-->
          <option value="SEM IssuePoints Deduction"><%="\u6263\u5206"%></option><!--扣分-->
          <option value="SEM Production Related Issue"><%="\u91CF\u4EA7\u76F8\u5173"%></option><!--量产相关-->
          <option value="SEM IssueCar Property"><%="\u8F66\u8F86\u6027\u8D28"%></option><!--车辆性质-->
          <option value="SEM Equipment Type"><%="\u8BBE\u5907\u7C7B\u522B"%></option><!--设备类别-->
          <option value="SEM Test Engine"><%="\u53D1\u52A8\u673A"%></option><!--发动机-->
          <option value="SEM Test Gearbox"><%="\u53D8\u901F\u7BB1"%></option><!--变速箱-->
          <option value="SEM Test Mileage"><%="\u91CC\u7A0B\u6216\u5FAA\u73AF"%></option><!--里程或循环-->
          <option value="SEM Test Item"><%="\u8BD5\u9A8C\u9879\u76EE"%></option><!--试验项目-->
          <option value="SEM Production Date"><%="\u4EA7\u54C1\u9636\u6BB5"%></option><!--产品阶段-->
          <option value="SEM UPG Part">UPG</option><!--UPG-->
          <option value="SEM Part Number"><%="\u4EF6\u53F7"%></option><!--件号-->
        </select>
        </label>
        </form>
    </td>
    <td width="162"><form id="form3" name="form3" method="post" action="">
     <!-- <label>
        <select name="select2" id="mate">
			<option value="" selected="selected"><%="\u6C47\u603B\u65B9\u5F0F"%></option><!--汇总方式-->
		<!--	<option value="All"><%="\u5168\u5339\u914D"%></option><!--全匹配-->
		<!--	<option value="DouHao"><%="\u9017\u53F7\u5206\u89E3"%></option><!--逗号分解-->
     <!--   </select>
        </label>-->
    </form>
    </td>
    <td width="258"><form id="form4" name="form4" method="post" action="">
      <label>
        <input type="submit" name="Submit2" style='font-size:14px' onClick="javascript:submitForm()" value=<%="\u6C47\u603B"%> /><!--汇总-->
		&nbsp;
		<input type="submit" name="Submit2" style='font-size:14px' onClick="javascript:clearValue()" value=<%="\u6E05\u7A7A\u7F13\u5B58"%> /><!--清空缓存-->

        </label>
    </form>
    </td>
  </tr>
</table>
<p>&nbsp;</p>
<table width="800" height="51" border="1" id="tableView" align="center">
  <tr align="center">
	<td width="151"><%="\u5C5E\u6027"%></td><!--属性-->
    <td width="151">A</td>
    <td width="151">B</td>
    <td width="151">C</td>
    <td width="151">D</td>
    <td width="160">TTL</td>
  </tr>
  <tr align="center">
    <td>TTL</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
</table>
</body>
</html>
<%
	String getSelectedIdValue = (String)PropertyUtil.getAdminProperty (context,"person",context.getUser(),"SEMIssuePanelValue");
	if(getSelectedIdValue!=null && getSelectedIdValue.length()>0)
	{
%>
		<script>
			var valuex =document.getElementById("panelAttribute");
			var objItemValue="<%=getSelectedIdValue%>";
			for (var i = 0; i < valuex.options.length; i++) 
			{ 
				if(valuex.options[i].value == objItemValue)
				{
					
					valuex.options[i].selected = true;  	
				}
			}	
		</script>		
<%
		 }
%>