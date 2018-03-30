<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.domain.util.*"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "matrix.db.JPO"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file="../programcentral/emxProgramGlobals2.inc" %>

<% 	// System.out.println("emxProgramCentralDashboardProjects.jsp :  ---------- START ----------");

	String sLanguage		= request.getHeader("Accept-Language");
	String sOID 			= request.getParameter("objectId");
	String sPortalMode		= request.getParameter("portalMode");		
	String sCollapse		= request.getParameter("collapse");	
	String sParamOID		= "";
	String sParamPortalMode	= "";
	String sParamToolbar	= "";
	String sParamProgram	= "&program=emxProgramUI:getProjectsOfProgram";

	if(null == sOID || "null".equals(sOID)) {
		sOID 			= "";
		sParamToolbar	= "&toolbar=PMCProjectSummaryToolBar";
		sParamProgram 	= "&program=emxProjectSpace:getActiveProjects";
	} else {
		sOID = XSSUtil.encodeURLForServer(context,sOID);
		sParamOID 			= "&objectId=" + sOID;
	}		
	if(null != sPortalMode) {
		if(sPortalMode.equalsIgnoreCase("TRUE")) {
			sParamPortalMode = "&amp;portalMode=true";
		}
	}	
	
	
	if(null == sCollapse) {sCollapse = "3"; }
	
	String initargs[]	= {};
	HashMap params 		= new HashMap();

	params.put("objectId"		, sOID		);		
	params.put("languageStr"	, sLanguage	);		
	
	String[] aData	= (String[])JPO.invoke(context, "emxProgramUI", initargs, "getProjectsDashboardData", JPO.packArgs (params), String[].class); 			
	
	String sLabelHidePanel 	= i18nNow.getI18nString("emxProgramCentral.String.HidePanel"			, "emxProgramCentralStringResource" 		, sLanguage);
	String sLabelRed 		= i18nNow.getI18nString("emxFramework.Range.Assessment_Status.Red"		, "emxFrameworkStringResource" 	, sLanguage);
	String sLabelGreen 		= i18nNow.getI18nString("emxFramework.Range.Assessment_Status.Green"	, "emxFrameworkStringResource" 	, sLanguage);
	String sLabelYellow 	= i18nNow.getI18nString("emxFramework.Range.Assessment_Status.Yellow"	, "emxFrameworkStringResource" 	, sLanguage);
	String sLabelNone		= i18nNow.getI18nString("emxFramework.Default.Task_Edit_Setting"		, "emxFrameworkStringResource"	, sLanguage);
	
%>

<html>

	<head>
	
<% 	if(!"".equals(sOID)) { %>
		<script type="text/javascript">
			var footerurl = 'foot URL';
			addStyleSheet("emxUIToolbar");
			addStyleSheet("emxUIMenu");
			addStyleSheet("emxUIDOMLayout");
		</script>
		<script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>	
<% 	} %>	
	
		<link rel="stylesheet" type="text/css" href="../common/styles/emxDashboardCommon.css">			
		<link rel="stylesheet" type="text/css" href="../common/styles/enoDashboardPanelRight.css">			
		<script type="text/javascript" src="../common/scripts/emxDashboardDefaults.js"></script>
		<script type="text/javascript" src="../common/scripts/emxDashboardCommon.js"></script>
		<script type="text/javascript" src="../common/scripts/emxDashboardPanelRight.js"></script>
		<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.10/js/highcharts.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.10/js/highcharts-more.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.10/js/modules/funnel.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.10/js/modules/exporting.js"></script>		
	
		<script type="text/javascript">		
			function initPage() {
				var divLeft 		= document.getElementById("left");
				var widthLeft 		= $(window).width() - 571;
				<%-- XSSOK --%>
				divLeft.innerHTML	= "<iframe id='frameDashboard' style='width:" + widthLeft + "px;border:none;' src='../common/emxIndentedTable.jsp?freezePane=Name,ProjectStatus,Folders,ProjectStatusDashboard,NewWindow<%=sParamOID%><%=sParamPortalMode%><%=sParamProgram%>&table=PMCProjectSpaceMyDesk&selection=multiple&header=emxProgramCentral.ProgramTop.Projects&sortColumnName=Est Finish&sortDirection=ascending&Export=false&HelpMarker=emxhelpprojectsummary&freezePane=Image,Name,ProjectDashboard,NewWindow&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral'></iframe> ";		
				var collapse = "<%=XSSUtil.encodeURLForServer(context, sCollapse)%>";
				if(collapse.indexOf("1") != -1) { toggleChartInfo(divHeaderTasks, divChartTasks, chartTasks, divInfoTasks); }
				if(collapse.indexOf("2") != -1) { toggleChartInfo(divHeaderDeliverables, divChartDeliverables, chartDeliverables, divInfoDeliverables); }
				if(collapse.indexOf("3") != -1) { toggleChartInfo(divHeaderIssues, divChartIssues, chartIssues, divInfoIssues); }
				if(collapse.indexOf("4") != -1) { toggleChart(divHeaderAssessments, divChartAssessments, chartAssessments); }
				if(collapse.indexOf("5") != -1) { toggleChart(divHeaderEfforts, divChartEfforts, chartEfforts); }
				
				
				
			}
		</script>	
		
	</head>
	
	
		<script type="text/javascript">

			var chartTasks;
			var chartDeliverables;
			var chartIssues;
			var chartAssessments;
			var chartEfforts;
			var colorAlternate = "#f5f5f5";
			
			$(document).ready(function() {
				chartTasks = new Highcharts.Chart({
					title		: { text: null	},
					credits		: { enabled: false	},
					exporting	: { enabled : false },
					legend		: { enabled: false	},
					tooltip		: { enabled: false	},					
					chart: {
						renderTo			: 'divChartTasks',
						marginRight			: 20,
						marginBottom		: 25,
						type				: 'bar',
						zoomType			: 'xy'
					},					
					xAxis: {
						categories: [<%=aData[16]%>],
						title: {
							text: null
						},
						labels: {
							formatter: function () {
								var text = this.value,
								formatted = text.length > 18 ? text.substring(0, 18) + '...' : text;
								return '<div class="js-ellipse" style="width:115px; overflow:hidden" title="' + text + '">' + formatted + '</div>';
							},
							style	: { width: '145px' },
							useHTML	: false
						}
					},			
					yAxis: {
						alternateGridColor	: colorAlternate,
						title: {
							text: null
						}						
					},
					plotOptions: {
						bar: {
							cursor: 'pointer',
							point: {
								events: {
									click: function() { openURLInDetails("../common/emxIndentedTable.jsp?hideExtendedHeader=true&suiteKey=ProgramCentral&header=emxProgramCentral.String.Name_PendingTasks&table=PMCAssignedWBSTaskSummary&program=emxProgramUI:getPendingTasksOfProject&hideWeeklyEfforts=true&freezePane=Status,WBSTaskName,Delivarable,NewWindow&objectId=" + this.id); }						
								}
							},
							dataLabels: {
								enabled: true,
								color: '#5f747d',
								connectorColor: '#5f747d',
								distance: 15,
								style: { fontSize:'7pt' }
							}
						},
						series: {
							groupPadding: 0.07
						}							
					},
				    series: [{
						name : 'tasks',
						data : [<%=aData[17]%>]
					}]				
				});

				chartDeliverables = new Highcharts.Chart({
					title		: { text: null	},
					credits		: { enabled: false	},
					exporting	: { enabled : false },
					legend		: { enabled: false	},
					tooltip		: { enabled: false	},					
					chart: {
						renderTo			: 'divChartDeliverables',
						marginRight			: 20,
						marginBottom		: 25,						
						type				: 'bar',
						zoomType			: 'xy'
					},					
					xAxis: {
						categories: [<%=aData[26]%>],
						title: {
							text: null
						},
						labels: {
							formatter: function () {
								var text = this.value,
								formatted = text.length > 18 ? text.substring(0, 18) + '...' : text;
								return '<div class="js-ellipse" style="width:115px; overflow:hidden" title="' + text + '">' + formatted + '</div>';
							},
							style	: { width: '145px' },
							useHTML	: false
						}						
					},						
					yAxis: {
						alternateGridColor	: colorAlternate,
						title: {
							text: null
						}						
					},					
					plotOptions: {
						bar: {
							cursor: 'pointer',
							point: {
								events: {
									click: function() { openURLInDetails("../common/emxIndentedTable.jsp?hideExtendedHeader=true&suiteKey=ProgramCentral&header=emxProgramCentral.String.Name_PendingDeliverables&table=PMCPendingDeliverableSummary&freezePane=Name&sortColumnName=EstEndDate&sortDirection=ascending&program=emxProgramUI:getDeliverablesOfProjectByTask&mode=All&objectId=" + this.id); }
								}                                                                                                                                                                                        
							},							
							dataLabels: {
								enabled: true,
								color: '#5f747d',
								connectorColor: '#5f747d',
								distance: 15,
								style: { fontSize:'7pt' }
							}
						},
						series: {
							groupPadding: 0.07
						}							
					},
				    series: [{
						name : 'deliverables',
						data : [<%=aData[27]%>]
					}]				
				});
							
				chartIssues = new Highcharts.Chart({
					title		: { text: null	},
					credits		: { enabled: false	},
					exporting	: { enabled : false },
					legend		: { enabled: false	},
					tooltip		: { enabled: false	},
					chart: {
						renderTo: 'divChartIssues',
						marginRight			: 20,
						marginBottom		: 25,						
						type				: 'bar',
						zoomType			: 'xy'
					},
					xAxis: {
						categories: [<%=aData[36]%>],
						title: {
							text: null
						},
						labels: {
							formatter: function () {
								var text = this.value,
								formatted = text.length > 18 ? text.substring(0, 18) + '...' : text;
								return '<div class="js-ellipse" style="width:115px; overflow:hidden" title="' + text + '">' + formatted + '</div>';
							},
							style	: { width: '145px' },
							useHTML	: false
						}						
					},	
					yAxis: {
						alternateGridColor	: colorAlternate,
						title				: { text: null }						
					},					
					plotOptions: {
						bar: {
							cursor: 'pointer',
							point: {
								events: {
									click: function() { openURLInDetails("../common/emxIndentedTable.jsp?suiteKey=ProgramCentral&header=emxProgramCentral.String.Name_PendingIssues&table=IssueList&freezePane=Name,Files,NewWindow&sortColumnName=EstimatedFinishDate&sortDirection=ascending&program=emxProgramUI:getPendingIssuesOfProject&mode=All&objectId=" + this.id); }
								}
							},							
							dataLabels: {
								enabled: true,
								color: '#5f747d',
								connectorColor: '#5f747d',
								distance: 15,
								style: { fontSize:'7pt' }
							}
						},
						series: {
							groupPadding: 0.07
						}						
					},
				    series: [{
						name : 'issues',
						data : [<%=aData[37]%>]
					}]			
				});
				
							
				chartAssessments = new Highcharts.Chart({
					title		: { text: null	},
					credits		: { enabled: false	},
					exporting	: { enabled : false },
					legend		: { enabled: false	},
					chart: {
						marginTop: 25,
						renderTo: 'divChartAssessments',					
						type				: 'scatter'
					},
					xAxis: {					
						plotBands: [{ 
							color	: '#f1f1f1',
							from	: -0.5,
							to		: 0.5
						}],
						title:		 { text: null },
						startOnTick	: true,
						endOnTick	: true,
						categories 	: [<%=aData[39]%>],
						opposite 	: true,
						tickColor	: 'transparent',
						lineColor	: '#fff',
						lineWidth	: 3
					},
					yAxis: {
						title:		 { text: null },
						startOnTick : false,
						endOnTick 	: false,
						categories 	: [<%=aData[40]%>],               
						labels: {
							formatter: function () {
								var text = this.value,
								formatted = text.length > 18 ? text.substring(0, 18) + '...' : text;
								return '<div class="js-ellipse" style="width:115px;z-index:-100; overflow:hidden" title="' + text + '">' + formatted + '</div>';
							},
							style	: { width: '145px' },
							useHTML	: false
						}	
					},
					plotOptions: {
						scatter: {
							point: {
								events: {
									click: function() { openURLInDetails("../common/emxIndentedTable.jsp?program=emxAssessment:getAssessment&table=PMCAssessmentSummary&suiteKey=ProgramCentral&selection=multiple&sortColumnName=Date&sortDirection=descending&header=emxProgramCentral.Common.AssessmentsPageHeading&HelpMarker=emxhelpassessmentsummary&Export=false&freezePane=Name&objectId=" + this.id); }
					
								}
							},
							marker: {
								radius: 8,
									states: {
										hover: {
											enabled: true,
											lineColor: colorGray
										}
									}
							},
							states: {
								hover: {
									marker: {
										enabled: false
									}
								}
							},
							tooltip: {
								pointFormat: '{point.name}'
							}
						}
					},
					tooltip: { backgroundColor : '#ffffff'},
					series: [
						{ name	: "<%=sLabelRed%>"		, color	: colorRed		 ,	data	: [<%=aData[42]%>] },
						{ name	: "<%=sLabelYellow%>"	, color	: colorYellow	 ,	data	: [<%=aData[43]%>] },
						{ name	: "<%=sLabelGreen%>"	, color	: colorGreen	 ,	data	: [<%=aData[44]%>] },
						{ name	: "<%=sLabelNone%>"		, color	: colorGrayBright ,	data	: [<%=aData[45]%>] }
					]
				});
    
    
				chartEfforts = new Highcharts.Chart({
					title		: { text: null	},
					credits		: { enabled: false	},
					exporting	: { enabled : false },
					legend		: { enabled: true	},
					chart: {
						marginTop			: 15,
						marginRight			: 25,
						renderTo			: 'divChartEfforts',					
						type				: 'bar'
					},
					xAxis: {
						categories: [<%=aData[1]%>],
						labels: {
							formatter: function () {
								var text = this.value,
								formatted = text.length > 18 ? text.substring(0, 18) + '...' : text;
								return '<div class="js-ellipse" style="width:115px;z-index:-100; overflow:hidden" title="' + text + '">' + formatted + '</div>';
							},
							style	: { width: '145px' },
							useHTML	: false
						},
						alternateGridColor	: colorAlternate,
					},
					yAxis: {
						min: 0,
						title				: { text: null	},
						endOnTick : false
					},
					tooltip: {
						shared		: true,						
						crosshairs	: true
					},						
					plotOptions: {
						bar: {
							dataLabels: {
								enabled: false
							},
							point: {
								events: {
									click: function() { openURLInDetails("../common/emxIndentedTable.jsp?hideExtendedHeader=true&suiteKey=ProgramCentral&table=PMCProjectTaskEffort&selection=multiple&expandProgramMenu=PMCWBSListMenu&freezePane=Name,ProgressBar,GNVTaskAllocationTotal&editLink=true&header=emxProgramCentral.Effort.EffortTitle&sortColumnName=ID&findMxLink=false&preProcessJPO=emxTask:preProcessCheckForEdit&postProcessJPO=emxTask:postProcessRefresh&editRelationship=relationship_Subtask&resequenceRelationship=relationship_Subtask&connectionProgram=emxTask:cutPasteTasksInWBS&parentOID=" + this.id + "&objectId=" + this.id); }
								}
							},
						},
						series: {
							groupPadding	: 0.1
						}
					},
					series: [
						<%=aData[3]%>,<%=aData[4]%>,<%=aData[2]%>
					]
				});
				
			});			

			
		</script>	

	<body>
		
		<div id="left"></div>			
		<div id="details"></div>			
		<div id="middle" onclick="showPanel();">
			<img  class="unhide" src="../common/images/utilPanelToggleArrow.png" />
		</div>		
		
		<div id="right">
			<table width="100%">	
				<tr><td>
					<div class="title link hidden" onmouseover="this.style.color='#04A3CF';" onmouseout="this.style.color='transparent';" onclick="hidePanel();"><img  class="hide" src="../common/images/utilPanelToggleArrow.png" /> <%=sLabelHidePanel%></div>
					<div class="title link italic" style="float:right;" onclick="restoreLeft();"><%=aData[0]%></div>
				</td></tr>		
				<tr><td>
					<div class="header" id="divHeaderTasks" onclick="toggleChartInfo(divHeaderTasks, divChartTasks, chartTasks, divInfoTasks);"><%=aData[10]%></div>
					<div class="chart"	id="divChartTasks"  style="height:<%=aData[11]%>px"></div>						
					<div class="info"	id="divInfoTasks">				
						<table width="100%" >
							<tr>
								<td width="5px">&nbsp;</td>
								<td width="25%" align="left"><%=aData[12]%></td>
								<td width="25%" align="center"><%=aData[13]%></td>
								<td width="25%" align="center"><%=aData[14]%></td>
								<td width="25%" align="right"><%=aData[15]%></td>
								<td width="5px">&nbsp;</td>
							</tr>
						</table>
					</div>				
				</td></tr>	

				<tr><td>
					<div class="header" id="divHeaderDeliverables" onclick="toggleChartInfo(divHeaderDeliverables, divChartDeliverables, chartDeliverables, divInfoDeliverables);"><%=aData[20]%></div>
					<div class="chart"	id="divChartDeliverables"  style="height:<%=aData[21]%>px"></div>					
					<div class="info"	id="divInfoDeliverables">	
						<table width="100%" >
							<tr>
								<td width="5px">&nbsp;</td>
								<td width="25%" align="left"><%=aData[22]%></td>
								<td width="25%" align="center"><%=aData[23]%></td>
								<td width="25%" align="center"><%=aData[24]%></td>
								<td width="25%" align="right"><%=aData[25]%></td>
								<td width="5px">&nbsp;</td>
							</tr>
						</table>
					</div>				
				</td></tr>		

				<tr><td>
					<div class="header"	id="divHeaderIssues" onclick="toggleChartInfo(divHeaderIssues, divChartIssues, chartIssues, divInfoIssues);"><%=aData[30]%></div>			
					<div class="chart"	id="divChartIssues"  style="height:<%=aData[31]%>px"></div>				
					<div class="info"	id="divInfoIssues">	
						<table width="100%" >
							<tr>
								<td width="5px">&nbsp;</td>
								<td width="25%" align="left"><%=aData[32]%></td>
								<td width="25%" align="center"><%=aData[33]%></td>
								<td width="25%" align="center"><%=aData[34]%></td>
								<td width="25%" align="right"><%=aData[35]%></td>
								<td width="5px">&nbsp;</td>
							</tr>
						</table>
					</div>				
				</td></tr>	
			
				
			</table>
			<br/>
		</div>	
	
	</body>
</html>
