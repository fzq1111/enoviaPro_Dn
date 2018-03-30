<%@page import="com.matrixone.apps.program.StatusReport"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.common.Person"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>

<%
	String sLanguage		= request.getHeader("Accept-Language");
	String sOID 			= com.matrixone.apps.domain.util.Request.getParameter(request, "objectId");	
	String treeLabel 		= com.matrixone.apps.domain.util.Request.getParameter(request, "treeLabel");
	String localeString 	= context.getLocale().toString();
	String languageString 	= context.getLocale().getLanguage();
	//is display company data
	StringList busList = new StringList("id");
	StringList relList = new StringList(DomainRelationship.SELECT_ID);
	boolean isCompanyLevel=false;
	DomainObject strObj = new DomainObject(sOID);
	String projectName=strObj.getName(context);
	Person person=Person.getPerson(context);
	if(person.hasRole(context,"Project Administrator")||person.hasRole(context,"SEM_Financial_Reviewer")){
		isCompanyLevel=true;
	}
	if(!isCompanyLevel){
       String buswhere="name=='"+projectName+"'";
  	   String relwhere="attribute[Project Role]=='SEM_StrategyProjectLeader'||attribute[Project Role]=='SEM_SecretariatPM'";    	
       MapList mapList=person.getRelatedObjects(context,"Member","Project Space", busList,relList,true,false,(short)1,buswhere,relwhere);
	   if(mapList.size()>0){
		  isCompanyLevel=true;
	   }
	}//
	String initargs[]	= {};
	HashMap params 		= new HashMap();
	params.put("objectId"		, sOID			);		
	params.put("languageStr"	, sLanguage		);
	params.put("companyLevel", isCompanyLevel);//add by ryan 2017-05-25
	//System.out.println("1---------" + new Date().getTime());
    String[] aDataReviewTasks=(String[])JPO.invoke(context, "emxTask", initargs, "getReviewTaskDashboardData", JPO.packArgs (params), String[].class);
    //System.out.println("2---------" + new Date().getTime());
    String[] aDataProjectTasks=(String[])JPO.invoke(context, "SEMProjectBoard", initargs, "getProjectTaskDashboardData", JPO.packArgs (params), String[].class); 
    //System.out.println("3---------" + new Date().getTime());
    String[] aDataKeyTasks=(String[])JPO.invoke(context, "SEMProjectBoard", initargs, "getKeyTaskDashboardData", JPO.packArgs (params), String[].class); 
    //System.out.println("4---------" + new Date().getTime());
    String[] aDataRisks=(String[])JPO.invoke(context, "SEMProjectBoard", initargs, "getRiskDashboardData", JPO.packArgs (params), String[].class); 
	//System.out.println("5---------" + new Date().getTime());
	String[] aDataOrders=(String[])JPO.invoke(context, "SEMProjectBoard", initargs, "getPrjChangeRequestDashboardData", JPO.packArgs (params), String[].class); 
	//System.out.println("6---------" + new Date().getTime());
	String[] aDataProjectIssues=(String[])JPO.invoke(context, "SEMProjectBoard", initargs, "getProjectIssueDashboardData", JPO.packArgs (params), String[].class); 
	//System.out.println("7---------" + new Date().getTime());
	String[] aDataTaskDeliverys=(String[])JPO.invoke(context, "SEMProjectBoard", initargs, "getTaskDeliveryDashboardData1", JPO.packArgs (params), String[].class); 
	//System.out.println("8---------" + new Date().getTime());
	String[] aDataPerfitAndLosts=(String[])JPO.invoke(context, "SEMProjectBoard", initargs, "getPerfitAndLostDashboardData", JPO.packArgs (params), String[].class); 
	//System.out.println("9---------" + new Date().getTime());
	String[] aDataBudgets=(String[])JPO.invoke(context, "SEMProjectBoard", initargs, "getBudgetDashboardData1", JPO.packArgs (params), String[].class); 
	//System.out.println("10---------" + new Date().getTime());
	MapList aDataGates=(MapList)JPO.invoke(context, "SEMProjectBoard", initargs, "getGates", JPO.packArgs (params), MapList.class); 
	//System.out.println("11---------" + new Date().getTime());
	String aDataProjectProgress=(String)JPO.invoke(context, "SEMProjectBoard", initargs, "getProjectProgress", JPO.packArgs (params),String.class); 
	//System.out.println("12---------" + new Date().getTime());
	String aDataProjectProgress1=(String)JPO.invoke(context, "SEMProjectBoard", initargs, "getProjectProgressHeader", JPO.packArgs (params),String.class); 
	//System.out.println("13---------" + new Date().getTime());
%>

<HTML>
    <HEAD>
    	<link rel="stylesheet" href="../programcentral/styles/ProgramCentralStatusReport.css" type="text/css">
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css">
        <link rel="stylesheet" type="text/css" href="../common/styles/emxDashboardCommon.css">		
		<link rel="stylesheet" type="text/css" href="../common/enoDashboardPanelRight.css">
		<script type="text/javascript" src="../common/scripts/emxDashboardCommon.js"></script>	
		<script type='text/javascript'>	
		
			$( "" ).ready(function() {
	            drawTiles();
	            fillTiles();
	            return false;
	        });

            var percent = "%";
            var tileId = "";
            var tileExpression = "";
            var tileHeader = "";
            var tileHeaderExpression = "";
			var tileCount = <%=aDataGates.size()%>;
			
			//Render Dashboard Tiles.
			var drawTiles = function () {
	        	$("#divInnerTileContainer").append('<table class="statusTile" id="statusTileTable">');

	        	$("#divInnerTileContainer").append('<tr>');
        	    $("#divInnerTileContainer").append('<td><br/></td>');
	        	$("#divInnerTileContainer").append('</tr>');

	        	$("#divInnerTileContainer").append('<tr>');
        	    $("#divInnerTileContainer").append('<td>');
		    
        	    for(var elemCount=0; elemCount<tileCount; elemCount++){
	        	    $("#divInnerTileContainer").append('<div class="statusTileHeader" id=\"tileHeader' + elemCount + '\"></div>');
	        	    if(elemCount<tileCount){
		        	    $("#divInnerTileContainer").append('<div class="spacer" id=\"tileHeaderSpacer' + elemCount + '\"></div>');
	        	    }
		        }
	        	$("#divInnerTileContainer").append('</td>');
	        	$("#divInnerTileContainer").append('</tr>');

	        	$("#divInnerTileContainer").append('<tr>');
        	    $("#divInnerTileContainer").append('<td>');
		        
        	    for(var elemCount=0; elemCount<tileCount; elemCount++){
	        	    $("#divInnerTileContainer").append('<div class="statusTile" id=\"tile' + elemCount + '\"></div>');
	        	    if(elemCount<tileCount){
		        	    $("#divInnerTileContainer").append('<div class="spacer" id=\"tileSpacer' + elemCount + '\"></div>');
	        	    }
		        }
	        	$("#divInnerTileContainer").append('</td>');
	        	$("#divInnerTileContainer").append('</tr>');
	        	
				$("#divInnerTileContainer").append('</table>');
			};

			//Populate Dashboard Tiles.
	        var fillTiles = function () {
				<%
					for(int index=0; index<aDataGates.size(); index++){
						Map map=(Map)aDataGates.get(index);
						String sTileHeader = (String) map.get("Header");
						String sTileUrl= (String) map.get("Url");
						String sTileBody = (String) map.get("Body");
						String sTileFooter = (String) map.get("Footer");
						String sTileColor = (String) map.get("Colorcode");
						String sTileDecisionURL = (String)map.get("DecisionURL");
%>
						var index = <%=index%>;
						tileId = "tile" + index;
						tileHeader = "tileHeader" + index;
						tileExpression =  "#" + tileId;
						tileHeaderExpression =  "#" + tileHeader;

						//Set Tile Header
						var url='<%=sTileUrl%>';	
						var head='<%=sTileHeader%>';
						if(url==''){
						$(tileHeaderExpression).text('<%=sTileHeader%>');
	    				}else{
							url='javascript:showModalDialog(\"../common/'+url+'\")';
							$(tileHeaderExpression).append('<u  onclick='+url+'>'+head+'</u>');
						}
	    				//Set Tile Body 
						var body = '<%=sTileBody%>';
						
						//Set Tile Footer 
	                    var footer = '<%=sTileFooter%>';
						$(tileExpression).append('<h1 class="statusTile" >' + body + '</h1>');						
						$(tileExpression).append('<span class="statusTile" >' + footer + '</span>');	                    
						
						//Set status color
						var statusColor = '<%=sTileColor%>';
                        $(tileExpression).css('border-Bottom', '16px solid ' + statusColor);
						
						//add by fzq
						var decisionUrl='<%=sTileDecisionURL%>';
						if(decisionUrl!=''){
							var oDiv = document.getElementById(tileId);
							decisionUrl='javascript:showModalDialog("'+decisionUrl+'");';
							oDiv.setAttribute("onclick",decisionUrl); 
						}
<%						
					}				
				%>	        	
	        };
			 //To toggle specific div row in Dashobard
			var toggleRow = function(rowNum) {
				if(rowNum == 1){
					toggleChartInfo(divHeaderProjectStatus, divChartProjectStatus, null, null);
					//toggleChartInfo(divHeaderTopLevelTasks, divChartTopLevelTasks, null, null);
				}
			};
</script>
    </HEAD>
	<body id="reportContainer" onload="initGanttChart()" style="overflow: auto;">
			<CENTER>
				<table id="itemTable" width="100%">
					<tr>
						<td width="1%"  style="line-height:5px">&nbsp;</td>
						<td width="31%" style="line-height:5px">&nbsp;</td>
						<td width="1%"  style="line-height:5px">&nbsp;</td>
						<td width="30%" style="line-height:5px">&nbsp;</td>
						<td width="1%"  style="line-height:5px">&nbsp;</td>
						<td width="31%" style="line-height:5px">&nbsp;</td>
						<td width="1%"  style="line-height:5px">&nbsp;</td>
					</tr>
					<tr><td colspan="7" style="line-height:10px">&nbsp;</td></tr>					
					<tr><td colspan="7" style="line-height:4px">&nbsp;</td></tr>							
				</table>		
			</CENTER>
			<div style="width:100%;min-width:1400px"> 
			<div id="left">
				            <div class="chart chartBorder outerTileContainer" id="divChartProjectStatus" style="height:180px;">
								<div class="innerTileContainer" id="divInnerTileContainer" style="height:100%">
								</div>									
							</div>
							<div class="header expanded" style="font-size: 17px;font-weight:bold;" id="divHeaderCounters8" onclick="toggleChartInfo(divHeaderCounters8, divChartCounters8, null,null);"><%=aDataProjectProgress1%></div>
								<div class="chart" style="height:150px;overflow: auto;"	id="divChartCounters8">
									<div id="textarea1">
									   <%=aDataProjectProgress%>
									</div>
								</div>
						    <div class="header expanded" style="font-size: 17px;font-weight:bold;" id="divHeaderCounters" onclick="toggleChartInfo(divHeaderCounters, divChartCounters, null,null);"><%=aDataProjectIssues[0]%></div>
					           <div class="chart" style="height:100px;"	id="divChartCounters">
						          <table style="width:100%;margin-bottom:5px;margin-top:5px;"><tr>
						       <%if(isCompanyLevel){%>
								    <%=aDataProjectIssues[1]%>
									<%=aDataProjectIssues[2]%>
									<%=aDataProjectIssues[3]%>
									<%=aDataProjectIssues[4]%>
									<%=aDataProjectIssues[5]%>
									<td></td>
							   <%}else{%>
							        <%=aDataProjectIssues[6]%>
									<%=aDataProjectIssues[7]%>
									<%=aDataProjectIssues[8]%>
									<%=aDataProjectIssues[9]%>
									<%=aDataProjectIssues[10]%>
									<td></td>
							   <%}%>   
							      </tr>
						        </table>
					        </div>
							<div class="header expanded" style="font-size: 17px;font-weight:bold;" id="divHeaderCounters5" onclick="toggleChartInfo(divHeaderCounters5, divChartCounters5, null,null);"><%=aDataBudgets[0]%></div>
					           <div class="chart" style="height:100px;"	id="divChartCounters5">
						          <table style="width:100%;margin-bottom:5px;margin-top:5px;"><tr>
								<%if(isCompanyLevel){%>
									<%=aDataBudgets[1]%>
									<%=aDataBudgets[2]%>
									<%=aDataBudgets[3]%>
									<%=aDataBudgets[4]%>
									<%=aDataBudgets[5]%>
									<td></td>
								<%}else{%>
								    <%=aDataBudgets[6]%>
									<%=aDataBudgets[7]%>
									<%=aDataBudgets[8]%>
									<%=aDataBudgets[9]%>
									<%=aDataBudgets[10]%>
									<td></td>
								<%}%> 
							      </tr>
						        </table>
					        </div>
						<%if(isCompanyLevel){%>
							<div class="header expanded" style="font-size: 17px;font-weight:bold;" id="divHeaderCounters7" onclick="toggleChartInfo(divHeaderCounters7, divChartCounters7, null,null);"><%=aDataPerfitAndLosts[0]%></div>
					           <div class="chart" style="height:100px;"	id="divChartCounters7">
						          <table style="width:100%;margin-bottom:5px"><tr>
								    <%=aDataPerfitAndLosts[1]%>
									<td></td>
							      </tr>
						        </table>
					        </div>
					    <%}%>
				</div>
				<div id="right">
				  <div class="header expanded" style="font-size: 17px;font-weight:bold;" id="divHeaderCounters1" onclick="toggleChartInfo(divHeaderCounters1, divChartCounters1, null,null);"><%=aDataProjectTasks[0]%></div>
				  <div class="chart" style="height:100px;"	id="divChartCounters1">
						          <table style="width:100%;margin-bottom:5px;margin-top:5px;"><tr>
								  <%if(isCompanyLevel){%>
								    <%=aDataProjectTasks[1]%>
									<%=aDataProjectTasks[2]%>
									<%=aDataProjectTasks[3]%>
									<%=aDataProjectTasks[4]%>
									<%=aDataProjectTasks[5]%>
									<td></td>
								  <%}else{%>
									<%=aDataProjectTasks[6]%>
									<%=aDataProjectTasks[7]%>
									<%=aDataProjectTasks[8]%>
									<%=aDataProjectTasks[9]%>
									<%=aDataProjectTasks[10]%> 
									<td></td>
								  <%}%>
							      </tr>
						        </table>
				  </div>
				  <div class="header expanded" style="font-size: 17px;font-weight:bold;" id="divHeaderCounters2" onclick="toggleChartInfo(divHeaderCounters2, divChartCounters2, null,null);"><%=aDataKeyTasks[0]%></div>
				  <div class="chart" style="height:100px;"	id="divChartCounters2">
						          <table style="width:100%;margin-bottom:5px;margin-top:5px;"><tr>
								    <%=aDataKeyTasks[1]%>
									<%=aDataKeyTasks[2]%>
									<%=aDataKeyTasks[3]%>
									<%=aDataKeyTasks[4]%>
									<%=aDataKeyTasks[5]%>
									<td></td>
							      </tr>
						        </table>
				  </div>
				  <div class="header expanded" style="font-size: 17px;font-weight:bold;" id="divHeaderCounters6" onclick="toggleChartInfo(divHeaderCounters6, divChartCounters6, null,null);"><%=aDataTaskDeliverys[0]%></div>
				  <div class="chart" style="height:100px;"	id="divChartCounters6">
						          <table style="width:100%;margin-bottom:5px;margin-top:5px;"><tr>
								   <%if(isCompanyLevel){%>
								      <%=aDataTaskDeliverys[1]%>
									  <%=aDataTaskDeliverys[2]%>
									  <%=aDataTaskDeliverys[3]%>
									  <%=aDataTaskDeliverys[4]%>
									  <td></td>
								   <%}else{%>
									  <%=aDataTaskDeliverys[5]%>
									  <%=aDataTaskDeliverys[6]%>
									  <%=aDataTaskDeliverys[7]%>
									  <%=aDataTaskDeliverys[8]%>
									  <td></td>
								   <%}%>
							      </tr>
						        </table>
				  </div>	
				  
				  <div class="header expanded" style="font-size: 17px;font-weight:bold;" id="divHeaderCounters3" onclick="toggleChartInfo(divHeaderCounters3, divChartCounters3, null,null);"><%=aDataRisks[0]%></div>
					           <div class="chart" style="height:100px;"	id="divChartCounters3">
						          <table style="width:100%;margin-bottom:5px;margin-top:5px;"><tr>
								    <%=aDataRisks[1]%>
								    <%=aDataRisks[2]%>
									<%=aDataRisks[3]%>
									<td></td>
							      </tr>
						        </table>
					       </div>
				 
				
						   <div class="header expanded" style="font-size: 17px;font-weight:bold;" id="divHeaderCounters4" onclick="toggleChartInfo(divHeaderCounters4, divChartCounters4, null,null);"><%=aDataOrders[0]%></div>
					           <div class="chart" style="height:100px;"	id="divChartCounters4">
						          <table style="width:100%;margin-bottom:5px;margin-top:5px;"><tr>
								    <%=aDataOrders[1]%>
									<td></td>
							      </tr>
						        </table>
					       </div>
					
				</div>
				</div>
    </body>
	<style type="text/css"> 
      span.counterText{
       font-size: 30px;
       font-weight: bold;
       line-height: 56px;
      }
	  #left{
		   margin-left:10px;
		   width:50%;
		   float:left;
		   min-width:800px
		
	  }
	  #right{
		  margin-left:20px;		 
		  width:35%;
		  float:left;
		  min-width:560px
	  }
	  #textarea1{
		text-align:left;
		padding:7px 7px 7px 20px;
		border-width:1px;
		border-color:Bisque;
		color:black;
		font-size: 15px;
	
	  }
	  div.statusTileHeader {
    border-radius: 5px;
    font-weight: bold;
    font-size: 110%;
    width: 12%;
    max-width: 100px;
    margin-top: 1px;
    display: inline-block;
      }
	  
	  h1.statusTile {
    font-weight: bold;
    font-size: 80%;
    font-align: center;
    vertical-align: middle;
    padding-top: 30%;
    }
	
	span.statusTile {
    font-size: 85%;
    }
	
	body, div, span, th, td, p, a, layer, label, ul, li {
    font-kerning: normal;
    text-rendering: optimizeLegibility;
    color: #5b5d5e;
    font-size: 15px;
    line-height: 25px;
    font-family: Arial, Helvetica, sans-serif;
    }
	  
    </style> 
</HTML>
