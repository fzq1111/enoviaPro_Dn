<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.domain.util.*"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "matrix.db.JPO"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>


<% 	//System.out.println("emxDashboardUser.jsp : ---------- STAR ----------");

	String sLanguage				= request.getHeader("Accept-Language");
	String sOID 					= request.getParameter("objectId");
	String sCollapse				= request.getParameter("collapse");
	String sRandomize				= request.getParameter("randomize"); // possible values (multiple are possible) : TasksByDate, Changes, 
	String sLabelHidePanel 			= EnoviaResourceBundle.getProperty(context, "Framework", "emxFramework.String.HidePanel", sLanguage);	
	String sLabelRestore 			= EnoviaResourceBundle.getProperty(context, "Framework", "emxFramework.String.RestoreDefaultView", sLanguage);
	String sLabelAssignedItems 		= EnoviaResourceBundle.getProperty(context, "Framework", "emxFramework.String.AssignedItems", sLanguage);
	String sLabelDate				= EnoviaResourceBundle.getProperty(context, "Framework", "emxFramework.History.Date", sLanguage);
	String sLabelPercentComplete	= EnoviaResourceBundle.getProperty(context, "Framework", "emxFramework.Attribute.Percent_Complete", sLanguage);
	String sLabelPast				= EnoviaResourceBundle.getProperty(context, "Framework", "emxFramework.String.Past", sLanguage);
	String sLabelNow				= EnoviaResourceBundle.getProperty(context, "Framework", "emxFramework.String.Now", sLanguage);
	String sLabelSoon				= EnoviaResourceBundle.getProperty(context, "Framework", "emxFramework.String.Soon", sLanguage);
	
	if(null == sOID) 		{ sOID = ""; } else if("null".equals(sOID)) 		{ sOID = ""; }
	if(null == sCollapse) 	{ sCollapse = "0"; }	
	if(null == sRandomize) 	{ sRandomize = "TasksByDate,Changes"; }	
	
	com.matrixone.apps.common.Person pUser = com.matrixone.apps.common.Person.getPerson( context );
	String sHasTasksAssigned 		= pUser.getInfo(context, "from["+ DomainConstants.RELATIONSHIP_ASSIGNED_TASKS +"]");
	String sHasIssuesAssigned 		= pUser.getInfo(context, "from["+ PropertyUtil.getSchemaProperty(context,DomainSymbolicConstants.SYMBOLIC_relationship_AssignedIssue)+ "]");	
	
	String sHasChangesAssigned 		= pUser.getInfo(context, "from["+DomainConstants.RELATIONSHIP_ASSIGNED_EC+"]");
	String sHasInboxTaskAssigned	= pUser.getInfo(context, "to["+ DomainConstants.RELATIONSHIP_PROJECT_TASK+"]");
	
	String initargs[]	= {};
	HashMap params 		= new HashMap();

	params.put("objectId"		, sOID			);		
	params.put("languageStr"	, sLanguage		);
	params.put("randomize"		, sRandomize	);
	
	boolean isPRJUser= false;
	try{
		FrameworkLicenseUtil.checkLicenseReserved(context, new String[] {"ENO_PRF_TP","ENO_PGE_TP"});
		isPRJUser = true;
		}catch(Exception e)	{
			isPRJUser = false;
		}
	
	String[] aDataDocuments	= (String[])JPO.invoke(context, "emxDashboardDocuments", initargs, "getUserDashboardData", JPO.packArgs (params), String[].class); 			
	String[] aDataIssues	= (String[])JPO.invoke(context, "emxDashboardIssues"	  , initargs, "getUserDashboardData", JPO.packArgs (params), String[].class); 			
	String[] aDataChanges	= (String[])JPO.invoke(context, "emxDashboardChanges"  , initargs, "getUserDashboardData", JPO.packArgs (params), String[].class); 			
	String[] aDataWorkflow	= (String[])JPO.invoke(context, "emxDashboardRoutes" , initargs, "getUserDashboardData", JPO.packArgs (params), String[].class); 
	String[] aDataProjects = new String[50];
	if(isPRJUser){
		try {
		aDataProjects	= (String[])JPO.invoke(context, "emxProgramUI"	  , initargs, "getUserDashboardData", JPO.packArgs (params), String[].class);
		} catch(Exception ex){
			isPRJUser = false;
		}
	}
	String[] aDataReviewTasks=(String[])JPO.invoke(context, "emxTask"	  , initargs, "getReviewTaskDashboardData", JPO.packArgs (params), String[].class); 	
	String[] aDataPlanTasks=(String[])JPO.invoke(context, "emxTask"	  , initargs, "getPlanTaskDashboardData", JPO.packArgs (params), String[].class); 	
    String[] aDataPlanConfirmeds=(String[])JPO.invoke(context, "emxTask"	  , initargs, "getPlanComfirmedDashboardData", JPO.packArgs (params), String[].class); 	
    String[] aDataPreallocatedTasks=(String[])JPO.invoke(context, "emxInboxTask"	  , initargs, "getPreallocatedDashboardData", JPO.packArgs (params), String[].class); 	
    String[] aDataMeetings=(String[])JPO.invoke(context, "emxMeeting"	  , initargs, "getMeetingDashboardData", JPO.packArgs (params), String[].class); 
	String[] aDataProposedIssues=(String[])JPO.invoke(context, "emxTask"	  , initargs, "getProposedIssueDashboardData", JPO.packArgs (params), String[].class); 
	String[] aDataCountermeasureIssues=(String[])JPO.invoke(context, "emxTask"	  , initargs, "getCountermeasureIssueDashboardData", JPO.packArgs (params), String[].class); 
	String[] aDataJudgedIssues=(String[])JPO.invoke(context, "emxTask"	  , initargs, "getJudgedIssueDashboardData", JPO.packArgs (params), String[].class); 
	String[] aDataProjectTasks=(String[])JPO.invoke(context, "emxTask"	  , initargs, "getProjectTaskDashboardData", JPO.packArgs (params), String[].class); 
	Calendar cNow 	= Calendar.getInstance();	
	int iYear 		= cNow.get(Calendar.YEAR);
	int iMonth 		= cNow.get(Calendar.MONTH);
	int iDay 		= cNow.get(Calendar.DAY_OF_MONTH);
	String sNow 	= iYear + "," + iMonth + "," + iDay;
	
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
	
		<link rel="stylesheet" type="text/css" href="styles/emxDashboardCommon.css">		
		<link rel="stylesheet" type="text/css" href="styles/enoDashboardPanelRight.css">
<%
	if(UINavigatorUtil.isMobile(context)){
%>
		<link rel="stylesheet" type="text/css" href="mobile/styles/emxUIMobile.css">
<%		
	}
%>		
		<script type="text/javascript" src="scripts/emxDashboardDefaults.js"></script>
		<script type="text/javascript" src="scripts/emxDashboardCommon.js"></script>
		<script type="text/javascript" src="scripts/emxDashboardPanelRight.js"></script>
		<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.2/js/highcharts.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.2/js/highcharts-more.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.2/js/modules/funnel.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.2/js/modules/exporting.js"></script>
		
	
		<script type="text/javascript">		
			function initPage() {
				var divLeft 		= document.getElementById("left");
				var widthLeft 		= $(window).width() - 571;
				$("#frameDashboard").width(widthLeft + "px");
				//divLeft.innerHTML	= "<iframe id='frameDashboard' style='width:" + widthLeft + "px;border:none;' src='../common/emxPortal.jsp?portal=AEFPowerView&showPageHeader=true&header=emxFramework.String.MyHome&suiteKey=Framework'></iframe> ";
				//XSSOK
				var collapse = "<%=sCollapse%>";
				if(collapse.indexOf("1") != -1) { toggleChartInfo(divHeaderCounters, divChartCounters, null, divInfoCounters); }
				if(collapse.indexOf("2") != -1) { toggleChartInfo(divHeaderDocuments, divChartDocuments, chartDocuments, divInfoDocuments); }
<%	if(sHasTasksAssigned.equalsIgnoreCase("TRUE")) { %>						
				if(collapse.indexOf("3") != -1) { toggleChartInfo(divHeaderProjects, divChartProjects, chartProjects, divInfoProjects); }
				if(collapse.indexOf("4") != -1) { toggleChart(divHeaderStatus, divChartStatus, chartStatus); }
				if(collapse.indexOf("5") != -1) { toggleChartInfo(divHeaderTasks, divChartTasks, chartTasks, divInfoTasks); }
<% 	} %>				
<%	if(sHasIssuesAssigned.equalsIgnoreCase("TRUE")) { %>						
				if(collapse.indexOf("6") != -1) { toggleChart(divHeaderIssues, divChartIssues, chartIssues); }
<% 	} %>
<%	if(sHasChangesAssigned.equalsIgnoreCase("TRUE")) { %>
				if(collapse.indexOf("7") != -1) { toggleChart(divHeaderChanges, divChartChanges, chartChanges); }
<% 	} %>
<%	if(sHasInboxTaskAssigned.equalsIgnoreCase("TRUE")) { %>
				if(collapse.indexOf("8") != -1) { toggleChartInfo(divHeaderRouteTasks, divChartRouteTasks, chartRouteTasks, divInfoRouteTasks); }
<% 	} %>
			}
		</script>		
		
		
		
		<script type="text/javascript">			
			
			var chartDocuments;
			var chartProjects;
			var chartStatus;			
			var chartTasks;			
			var chartIssues;			
			var chartChanges;			
			var chartRouteTasks;			
			
			$(document).ready(function() {
				
				Highcharts.setOptions({
			        lang: {

			                months: ['<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("January", request.getHeader("Accept-Language")))%>',
									  '<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("February", request.getHeader("Accept-Language")))%>',
									  '<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("March", request.getHeader("Accept-Language")))%>',
									  '<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("April", request.getHeader("Accept-Language")))%>',
									  '<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("May", request.getHeader("Accept-Language")))%>',
									  '<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("June", request.getHeader("Accept-Language")))%>',
									  '<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("July", request.getHeader("Accept-Language")))%>',
									  '<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("August", request.getHeader("Accept-Language")))%>',
									  '<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("September", request.getHeader("Accept-Language")))%>',
									  '<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("October", request.getHeader("Accept-Language")))%>',
									  '<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("November", request.getHeader("Accept-Language")))%>',
									  '<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("December", request.getHeader("Accept-Language")))%>'],
									  
			                weekdays: ['<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Sunday", request.getHeader("Accept-Language")))%>',
			   						'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Monday", request.getHeader("Accept-Language")))%>',
									'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Tuesday", request.getHeader("Accept-Language")))%>',
									'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Wednesday", request.getHeader("Accept-Language")))%>',
									'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Thursday", request.getHeader("Accept-Language")))%>',
									'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Friday", request.getHeader("Accept-Language")))%>',
									'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Saturday", request.getHeader("Accept-Language")))%>'],
									
			                shortMonths: ['<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Jan", request.getHeader("Accept-Language")))%>',
					   						'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Feb", request.getHeader("Accept-Language")))%>',
											'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Mar", request.getHeader("Accept-Language")))%>',
											'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Apr", request.getHeader("Accept-Language")))%>',
											'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("May", request.getHeader("Accept-Language")))%>',
											'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Jun", request.getHeader("Accept-Language")))%>',
											'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Jul", request.getHeader("Accept-Language")))%>',
											'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Aug", request.getHeader("Accept-Language")))%>',
											'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Sep", request.getHeader("Accept-Language")))%>',
											'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Oct", request.getHeader("Accept-Language")))%>',
											'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Nov", request.getHeader("Accept-Language")))%>',
											'<%= XSSUtil.encodeForJavaScript(context, com.matrixone.apps.domain.util.i18nNow.getCalendarI18NString("Dec", request.getHeader("Accept-Language")))%>'],
			               
			        }
			});
				chartDocuments = new Highcharts.Chart({
					title		: { text	: null	},
					credits		: { enabled	: false	},
					exporting	: { enabled : false },
					legend		: { enabled	: false	},
					chart: {
						marginTop	: 25,
						marginRight	: 20,
						renderTo	: 'divChartDocuments',
						type		: 'area',
						zoomType	: 'x'
					},
					xAxis: {
						type: 'datetime',
						dateTimeLabelFormats: { // don't display the dummy year
							month: '%e. %b',
							year: '%b'
						}
					},
					yAxis: {
						title: { text: null	},
						alternateGridColor	: '#F1F1F1',
						endOnTick			: false
					},
					tooltip: {
						shared		: true,						
						crosshairs	: true
					},
					plotOptions: {
						area: {
							stacking	: 'normal',
							lineWidth	: 1,
							cursor		: 'pointer',
							point: {
								events: {
									click: function() { openURLInDetails("../common/emxIndentedTable.jsp?program=emxDashboardDocuments:getDocuments&mode=By Date&header=<%=sLabelDate%> : " + Highcharts.dateFormat('%e. %b %Y', new Date(this.x)) + "&date=" + this.x + "&table=APPDashboardUserDocuments&freezePane=Name,RouteStatus,Title,Actions,NewWindow&selection=multiple");	}
								}
							}
						}
					},
					series: [<%=aDataDocuments[5]%>,<%=aDataDocuments[6]%>]
				});
				
<%	if(isPRJUser && sHasTasksAssigned.equalsIgnoreCase("TRUE")) { %>					
				chartProjects = new Highcharts.Chart({
					title		: { text: null	},
					credits		: { enabled: false	},
					exporting	: { enabled : false },
					legend		: { enabled: false	},
					tooltip		: { enabled: false	},					
					chart: {
						renderTo			: 'divChartProjects',
						marginRight			: 20,
						marginBottom		: 25,
						type				: 'bar',
						zoomType			: 'xy'
					},					
					xAxis: {
						categories: [<%=aDataProjects[5]%>],
						labels : { style: { fontSize: '10px'} },						
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
						alternateGridColor	: '#f1f1f1',
						title: {
							text: null
						}						
					},
					plotOptions: {
						bar: {
							cursor: 'pointer',
							point: {
								events: {
									click: function() { openURLInDetails("../common/emxIndentedTable.jsp?hideExtendedHeader=true&header=emxFramework.String.PendingTasks&suiteKey=Framework&table=PMCAssignedWBSTaskSummary&program=emxProgramUI:getMyOpenTasksOfProject&freezePane=Status,WBSTaskName,Delivarable,NewWindow&objectId=" + this.id); }						
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
						name : "<%=aDataProjects[0]%>",
						data : [<%=aDataProjects[6]%>]
					}]				
				});								

				chartStatus = new Highcharts.Chart({
					chart: {
						type		: 'pie',
						renderTo	: 'divChartStatus',
						marginRight	: 20,
						zoomType	: 'y'
					},
					title		: { text		: null  },
					credits 	: { enabled 	: false },
					exporting	: { enabled 	: false },
					legend		: { enabled 	: false },
					plotOptions: {
						pie: {
							dataLabels: { 
								enabled : true ,
								format	: '<b>{point.name}</b>: {point.percentage:.1f} %', 
								distance: 5
							},
							point : {
								events:{ click : function() { openURLInDetails("../common/emxIndentedTable.jsp?suiteKey=ProgramCentral&header=<%=sLabelPercentComplete%> : " + this.value + "%25&program=emxProgramUI:getMyOpenTasksByPercentComplete&percent=" + this.value + "&table=PMCAssignedWBSTaskSummary&editLink=true&selection=multiple&freezePane=Status,WBSTaskName,Delivarable,NewWindow"); }}
							}	
						}
					},				
					tooltip: {
						formatter: function() {
							return '<b>'+ this.point.name +'</b>: '+ this.y;
						}
					},					
					series: [{
						name: "<%=aDataProjects[8]%>",
						data: [
							{ color:'#CEDFEA', y:<%=aDataProjects[9]%>,  value:'0-25'	, name:'25%'	},
							{ color:'#88B1CC', y:<%=aDataProjects[10]%>, value:'25-50'	, name:'25-50%'	},
							{ color:'#508CB4', y:<%=aDataProjects[11]%>, value:'50-75'	, name:'50-75%'	},
							{ color:'#2A4B62', y:<%=aDataProjects[12]%>, value:'75-99'	, name:'75-99%'	},
							{ color:'#ff7f00', y:<%=aDataProjects[13]%>, value:'100'	, name:'100%'	}
						]
					}]
				});		

				chartTasks = new Highcharts.Chart({
					title		: { text: null	},
					credits		: { enabled: false	},
					exporting	: { enabled : false },
					legend		: { enabled: false	},
					chart: {
						marginTop	: 25,
						marginRight	: 20,
						renderTo	: 'divChartTasks',
						type		: 'spline',
						zoomType	: 'xy'
					},
					xAxis: {
						type : 'datetime'
					},
					yAxis: {
						alternateGridColor	: '#F1F1F1',
						endOnTick 			: false,
						min					: 0,
						title				: { text: null	}
					},
					tooltip: {
						shared		: true,						
						crosshairs	: true
					},
					plotOptions: {
						spline: {
							stacking: 'normal',
							cursor: 'pointer',
							point: {
								events:{ click : function() { 
									openURLInDetails("../common/emxIndentedTable.jsp?suiteKey=ProgramCentral&header=<%=sLabelDate%> : " + Highcharts.dateFormat('%e. %b %Y', new Date(this.x)) + "&date=" + this.x + "&program=emxProgramUI:getMyOpenTasksOfDate&table=PMCAssignedWBSTaskSummary&editLink=true&selection=multiple&freezePane=Status,WBSTaskName,Delivarable,NewWindow"); }									
								}
							}
						}
					},					
					series: [ <%=aDataProjects[19]%>,<%=aDataProjects[20]%>,<%=aDataProjects[21]%> ]
				});
<%	} %>				
				
<%if(sHasIssuesAssigned.equalsIgnoreCase("TRUE")) {%>
				
				chartIssues = new Highcharts.Chart({
					title		: { text: null	},
					credits		: { enabled: false	},
					exporting	: { enabled : false },
					legend		: { enabled: false	},
					chart: {
						inverted	: true,
						marginTop	: 25,
						marginRight	: 35,
						renderTo	: 'divChartIssues',
						type		: 'columnrange',
						zoomType	: 'xy'
					},
					xAxis: {
						categories: [<%=aDataIssues[1]%>]
					},	    
					yAxis: {
						alternateGridColor	: '#F1F1F1',
						opposite : true,
						plotLines			: [{
							color: '#cc0000',
							width: 2,
							value: Date.UTC(<%=sNow%>)
						}],
						title	: { text: null },
						type	: 'datetime'
					},
					plotOptions: {
						columnrange: {
							dataLabels : { enabled: false },
							point: {
								events:{ click : function() { openURLInDetails("../common/emxForm.jsp?hideExtendedHeader=true&form=type_Issue&objectId=" + this.id + "&toolbar=IssuePropertiesToolBar&editLink=true&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=components&emxSuiteDirectory=components"); }}			
							}							
						},
						series: {
							groupPadding: 0.07
						}							
					},
					tooltip: {
						formatter: function() {
							return "<span style='font-weight:bold;color:" + this.point.color + "'>" + this.x + "</span><br/>" + this.point.desc + "<br/>" + Highcharts.dateFormat('%e. %b %Y', new Date(this.point.low)) + " - " + Highcharts.dateFormat('%e. %b %Y', new Date(this.point.high)) + "<br/>(" + this.point.owner + ")";
						},
						useHTML : true
					},	
					series: [{
						name: "<%=aDataIssues[0]%>",
						data: [<%=aDataIssues[2]%>]
					}]
				});				
<% } %>
				
<%	if(sHasChangesAssigned.equalsIgnoreCase("TRUE")) { %>
				chartChanges = new Highcharts.Chart({
					title		: { text: null	},
					credits		: { enabled: false	},
					exporting	: { enabled : false },
					legend		: { enabled: true	},		
					chart: {
						marginTop	: 20,
						marginRight	: 25,
						renderTo	: 'divChartChanges',
						type		: 'column',
						zoomType	: 'xy'
					},

					xAxis: {
						categories: [<%=aDataChanges[1]%>]
					},
					yAxis: {
						alternateGridColor	: '#F1F1F1',
						endOnTick	: false,
						min: 0,
						title		: { text: null	},
						stackLabels: {
							enabled: true,
							style: {
								fontWeight: 'bold',
								color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
							}
						}
					},
		
					tooltip: {
						shared		: true,						
						crosshairs	: true
					},
					plotOptions: {
						column: {
							stacking: 'normal',
							dataLabels: {
								enabled: true,
								color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
							},
							point: {
								events:{ click : function() { openURLInDetails("../common/emxIndentedTable.jsp?filterStatus=" + this.x + "&table=APPDashboardEC&program=emxDashboardChanges:getChangesAssignedPending&mode=By Status&editLink=true&suiteKey=Framework&header=emxFramework.String.AssignedChangesPendingInState" + this.x); }}
							}
						}
					},
					series: [<%=aDataChanges[2]%>]
				
				});	
<% } %>

<%	if(sHasInboxTaskAssigned.equalsIgnoreCase("TRUE")) { %>
				chartRouteTasks = new Highcharts.Chart({
					title		: { text	: null	},
					credits		: { enabled	: false	},
					exporting	: { enabled : false },
					legend		: { enabled	: true	},			
					chart: {
						marginTop	: 25,
						marginRight	: 35,
						marginBottom: 15,
						renderTo	: 'divChartRouteTasks',
						type		: 'scatter',
						zoomType	: 'x'
					},				
					xAxis: {
						alternateGridColor	: '#f1f1f1',
						endOnTick			: true,
						opposite			: true,
						plotLines			: [{
							color: '#cc0000',
							width: 2,
							value: Date.UTC(<%=sNow%>)
						}],
						showLastLabel		: true,
						startOnTick			: true,
						title				: { text: null },
						type				:		'datetime'
					},
					yAxis: {
						title:		 { text: null },
						startOnTick : false,
						endOnTick 	: false,
						categories 	: ['',<%=aDataWorkflow[4]%>],               
						min			: 0.5,
						max			: <%=aDataWorkflow[8]%>.5,
						labels: {
							formatter: function () {
								var text = this.value,
								formatted = text.length > 18 ? text.substring(0, 18) + '...' : text;
								return '<div class="js-ellipse" style="width:115px;z-index:-100; overflow:hidden" title="' + text + '">' + formatted + '</div>';
							},
							style	: { width: '165px' },
							useHTML	: false
						},
						tickmarkPlacement : 'on'
					},
					plotOptions: {
						scatter: {
							marker: {
								radius: 6,
								lineWidth: 2,
								symbol: 'diamond',
								states: {
									hover: {
										enabled: true,
										lineColor: colorGrayBright
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
								useHTML		: true,
								headerFormat: 	'<small style="color: {series.color}">{point.key}</small><br/>',
								pointFormat :	"<b><%=aDataWorkflow[12]%></b> 		: {point.route}<br/>" +
												"<b><%=aDataWorkflow[13]%></b> 		: {point.title}<br/>" +
												"<b><%=aDataWorkflow[14]%></b> 		: {point.action}<br/>" +
												"<b><%=aDataWorkflow[15]%></b>  	: {point.date}<br/>"
							},
							point : {
								events:{ click : function() {openURLInDetails("../common/emxForm.jsp?hideExtendedHeader=true&form=type_Route&mode=view&toolbar=APPRoutePropertiesToolBar&formHeader=emxComponents.Heading.Properties&HelpMarker=emxhelprouteproperties&Export=false&showPageURLIcon=false&suiteKey=Components&objectId=" + this.id); }}
							}							
						}
					},
					series: [ 
						{name	: "<%=sLabelPast%>"		, color	: colorRed	 	 ,	data	: [<%=aDataWorkflow[5]%>]},
						{name	: "<%=sLabelNow%>"		, color	: colorYellow	 ,	data	: [<%=aDataWorkflow[6]%>]}, 
						{name	: "<%=sLabelSoon%>"	, color	: colorGreen	 ,	data	: [<%=aDataWorkflow[7]%>]} 
					]
				});					
<% } %>
				
			});
				
		</script>	
	
	</head>
	<body>
	
		<div id="left">
			<iframe id='frameDashboard' style='border:none;' src='../common/emxPortal.jsp?portal=AEFPowerView&showPageHeader=true&header=emxFramework.String.MyHome&suiteKey=Framework'></iframe>
		</div>
		<div id="details"></div>		
		<div id="middle" onclick="showPanel();"><img  class="unhide" src="../common/images/utilPanelToggleArrow.png" /></div>
		
		<%Boolean isCPFUser =(Boolean)session.getAttribute("isCPFUser");
		if(isCPFUser){
		%>				
		<div id="right">
		

		
			<table width="100%">	
				<tr><td>
					<div class="title link" onclick="hidePanel();"><img  class="hide" src="../common/images/utilPanelToggleArrow.png" /> <%=sLabelHidePanel%></div>
					<div class="title link italic" style="float:right;" onclick="restoreLeft();"><%=sLabelRestore%></div>
				</td></tr>			
				<tr><td>
					<div class="header expanded" id="divHeaderCounters" onclick="toggleChartInfo(divHeaderCounters, divChartCounters, null, divInfoCounters);"><%=sLabelAssignedItems%></div>
					<div class="chart" style="height:160px;"	id="divChartCounters">
						<table style="width:100%;margin-bottom:5px;"><tr>
							<!--<%=aDataDocuments[7]%> -->
							<%=aDataPlanTasks[0]%>
						    <%=aDataPreallocatedTasks[0]%>
							<%=aDataPlanConfirmeds[0]%>		
						<% if(isPRJUser){ %>							
							<!--<%=aDataProjects[22]%> -->
							<%=aDataProjectTasks[0]%>
						<%} %>	
						    <%=aDataReviewTasks[0]%>  										
						</tr>
						<tr>
						   <%=aDataWorkflow[10]%>					   
                           <%=aDataMeetings[0]%>
                           <%=aDataProposedIssues[0]%>	
                           <%=aDataCountermeasureIssues[0]%>	
                           <%=aDataJudgedIssues[0]%>						   
						   <!--<%=aDataIssues[4]%>  -->	
						   <!--<%=aDataChanges[3]%>	-->
						</tr>
						</table>
					</div>
					<div class="info"	id="divInfoCounters">				
						<table width="100%" >
							<tr>
							<%=aDataDocuments[8]%>
							<%=aDataPreallocatedTasks[1]%>
						<% if(isPRJUser){ %>
							<%=aDataProjects[23]%>
						<%} %>	
							<%=aDataIssues[5]%>
							<%=aDataChanges[4]%>
							<%=aDataWorkflow[11]%>
							</tr>
						</table>
					</div>					
				</td></tr>	
				<tr><td>
					<div class="header expanded" id="divHeaderDocuments" onclick="toggleChartInfo(divHeaderDocuments, divChartDocuments, chartDocuments, divInfoDocuments);"><%=aDataDocuments[0]%></div>
					<div class="chart"	id="divChartDocuments"  style="height:160px"></div>						
					<div class="info"	id="divInfoDocuments">				
						<table width="100%" >
							<tr>
								<td width="5px">&nbsp;</td>
								<td width="25%" align="left"  ><%=aDataDocuments[1]%></td>
								<td width="25%" align="center"><%=aDataDocuments[2]%></td>
								<td width="25%" align="center"><%=aDataDocuments[3]%></td>
								<td width="25%" align="right" ><%=aDataDocuments[4]%></td>
								<td width="5px">&nbsp;</td>
							</tr>
						</table>
					</div>
				</td></tr>	
<%	if(isPRJUser &&  sHasTasksAssigned.equalsIgnoreCase("TRUE")) { %>					
				<tr><td>
					<div class="header expanded" id="divHeaderProjects" onclick="toggleChartInfo(divHeaderProjects, divChartProjects, chartProjects, divInfoProjects);"><%=aDataProjects[0]%></div>
					<div class="chart"	id="divChartProjects"  style="height:<%=aDataProjects[7]%>px"></div>						
					<div class="info"	id="divInfoProjects">				
						<table width="100%" >
							<tr>
								<td width="5px">&nbsp;</td>
								<td width="25%" align="left"  ><%=aDataProjects[1]%></td>
								<td width="25%" align="center"><%=aDataProjects[2]%></td>
								<td width="25%" align="center"><%=aDataProjects[3]%></td>
								<td width="25%" align="right" ><%=aDataProjects[4]%></td>
								<td width="5px">&nbsp;</td>
							</tr>
						</table>
					</div>
				</td></tr>
				<tr><td>
					<div class="header expanded"	id="divHeaderStatus" onclick="toggleChartFilter(divHeaderStatus, divChartStatus, chartStatus, divFilterStatus);"><%=aDataProjects[8]%></div>			
					<div class="filter" id="divFilterStatus" onclick="removeFilter(divHeaderStatus, divChartStatus, divFilterStatus); filterStatus=''; updateTable();"></div>
					<div class="chart chartBorder"	id="divChartStatus"  style="height:190px;cursor:pointer;"></div>			
				</td></tr>	
				<tr><td>
					<div class="header expanded" id="divHeaderTasks" onclick="toggleChartInfo(divHeaderTasks, divChartTasks, chartTasks, divInfoTasks);"><%=aDataProjects[14]%></div>
					<div class="chart"	id="divChartTasks"  style="height:190px"></div>						
					<div class="info"	id="divInfoTasks">				
						<table width="100%" >
							<tr>
								<td width="5px">&nbsp;</td>
								<td width="20%" align="left"  ><%=aDataProjects[15]%>:</td>
								<td width="25%" align="center"><%=aDataProjects[16]%></td>
								<td width="25%" align="center"><%=aDataProjects[17]%></td>
								<td width="30%" align="right" ><%=aDataProjects[18]%></td>
								<td width="5px">&nbsp;</td>
							</tr>
						</table>
					</div>
				</td></tr>	
<% 	} %>			
<%if(sHasIssuesAssigned.equalsIgnoreCase("TRUE")) {%>				
				<tr><td>
					<div class="header expanded" id="divHeaderIssues" onclick="toggleChart(divHeaderIssues, divChartIssues, chartIssues);"><%=aDataIssues[0]%></div>
					<div class="chart chartBorder"	id="divChartIssues"  style="height:<%=aDataIssues[3]%>px"></div>						
				</td></tr>
<% 	} %>			
<%	if(sHasChangesAssigned.equalsIgnoreCase("TRUE")) { %>	
				<tr><td>
					<div class="header expanded" id="divHeaderChanges" onclick="toggleChart(divHeaderChanges, divChartChanges, chartChanges);"><%=aDataChanges[0]%></div>
					<div class="chart chartBorder"	id="divChartChanges"  style="height:240px"></div>						
				</td></tr>					
<% 	} %>	
<%	if(sHasInboxTaskAssigned.equalsIgnoreCase("TRUE")) { %>		
				<tr><td>
					<div class="header expanded" id="divHeaderRouteTasks" onclick="toggleChartInfo(divHeaderRouteTasks, divChartRouteTasks, chartRouteTasks, divInfoRouteTasks);"><%=aDataWorkflow[0]%></div>
					<div class="chart"	id="divChartRouteTasks"  style="height:<%=aDataWorkflow[9]%>px"></div>
					<div class="info"	id="divInfoRouteTasks">				
						<table width="100%" >
							<tr>
								<td width="5px">&nbsp;</td>
								<td width="33%" align="left"  ><%=aDataWorkflow[3]%></td>
								<td width="33%" align="center"><%=aDataWorkflow[2]%></td>
								<td width="33%" align="right" ><%=aDataWorkflow[1]%></td>
								<td width="5px">&nbsp;</td>
							</tr>
						</table>
					</div>					
				</td></tr>					
<% 	} %>	
			</table>				
			<br/>

		</div>		
		<%} %>
		
	</body>
</head>
