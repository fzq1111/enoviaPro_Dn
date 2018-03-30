<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page language="java" pageEncoding="UTF-8"%>

<%@page import = "com.matrixone.apps.domain.DomainObject,
                  com.matrixone.apps.domain.DomainConstants,
                  com.matrixone.apps.domain.util.MapList,
                  com.matrixone.apps.domain.util.FrameworkProperties"%>

<%@page import="java.util.*,
                java.util.List,
                java.util.Iterator,
                java.io.FileInputStream,
                java.io.InputStream,
                java.io.File,
                java.io.BufferedInputStream,
                javax.servlet.ServletOutputStream,
                java.util.Date,
                java.text.SimpleDateFormat,
                java.net.*,
				org.apache.poi.hssf.usermodel.HSSFWorkbook"%>


<%	
    String msg="";
	StringList groupIdList=new StringList();
	String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
	if(emxTableRowId.length==1){
		msg="\u6240\u9009\u9879\u76EE\u4E0D\u80FD\u5C11\u4E8E\u4E24\u4E2A!";
	}else{
	 for(int i=0;i<emxTableRowId.length;i++)
	 {
		String[] splitValue = emxTableRowId[i].split("\\|");
		String selectedId = splitValue[1];
	    groupIdList.add(selectedId);
	 }
	}
	if(!msg.equals("")){
%>
    <script>
        alert("<%=msg%>");	
		parent.location.href=parent.location.href;
	</script>	
<%			
	}else{
	HashMap paraMap = new HashMap();
	paraMap.put("groupIdList", groupIdList);
	MapList dataList0= new MapList();
	MapList dataList1= new MapList();
	MapList dataList2= new MapList();
	MapList dataList3= new MapList();
	MapList dataList4= new MapList();
	MapList dataList5= new MapList();
	String JPOName="SEMProjectComparsionReportExport";
	String methodName0="getGateScheduleCompareReport";
	String methodName1="getPhaseScheduleCompareReport";
	String methodName2="getGateInvestmentCompareReport";
	String methodName3="getPhaseInvestmentCompareReport";
	String methodName4="getDepartmentInvestmentCompareReport";
	String methodName5="getGateJudgetCompareReport";
	String sfile="多项目对比报表";
	dataList0= JPO.invoke(context, JPOName, null, methodName0, (String[]) JPO.packArgs(paraMap), MapList.class);
	dataList1= JPO.invoke(context, JPOName, null, methodName1, (String[]) JPO.packArgs(paraMap), MapList.class);
	dataList2= JPO.invoke(context, JPOName, null, methodName2, (String[]) JPO.packArgs(paraMap), MapList.class);
	dataList3= JPO.invoke(context, JPOName, null, methodName3, (String[]) JPO.packArgs(paraMap), MapList.class);
	dataList4= JPO.invoke(context, JPOName, null, methodName4, (String[]) JPO.packArgs(paraMap), MapList.class);
	dataList5= JPO.invoke(context, JPOName, null, methodName5, (String[]) JPO.packArgs(paraMap), MapList.class);
    if(dataList0!=null&&dataList0.size()>0){	
	try{
		String timeStac = new SimpleDateFormat("yyyyMMDDHHmmssms").format(new Date());
		String fileName=new String(sfile.getBytes("gb2312"), "iso8859-1")+"_"+timeStac+".xls";	
		HSSFWorkbook workbook = new HSSFWorkbook(); //create excel
		HashMap requestMap = new HashMap();
		requestMap.put("dataList0", dataList0);
		requestMap.put("dataList1", dataList1);
		requestMap.put("dataList2", dataList2);
		requestMap.put("dataList3", dataList3);
		requestMap.put("dataList4", dataList4);
		requestMap.put("dataList5", dataList5);
 		requestMap.put("workbook", workbook);	
		String methodName="exportExcel";
		JPO.invoke(context, JPOName, null, methodName, (String[]) JPO.packArgs(requestMap));

		response.reset();
	 	response.setContentType("application/vnd.ms-excel;charset=UTF-8"); 
		response.setHeader("Content-Disposition","attachment; filename="+fileName);
		response.setCharacterEncoding("UTF-8");
		OutputStream outStream = response.getOutputStream();
		workbook.write(outStream);//
		outStream.flush();
		outStream.close();
		out.clear();
		out=pageContext.pushBody();   
	}catch(Exception e){
		e.printStackTrace();
	}
    }
  }
%>
