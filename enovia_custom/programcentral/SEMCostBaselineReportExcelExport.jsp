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
	StringList CostBaselineList=new StringList();
	String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
	if(emxTableRowId.length==2){
		for(int i=0;i<emxTableRowId.length;i++)
	   {
		String[] splitValue = emxTableRowId[i].split("\\|");
		String selectedId = splitValue[1];
		CostBaselineList.add(selectedId);
	 }
	}else{
		msg="\u6240\u9009\u6295\u8D44\u57FA\u7EBF\u53EA\u80FD\u4E3A\u4E24\u4E2A\uFF01";
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
	paraMap.put("CostBaselineList",CostBaselineList);
	MapList dataList = new MapList();
	String JPOName="SEMCostBaselineReportExport";
	String methodName="getCostBaselineComparisonReport";
	String sfile="投资基线对比报表";
	dataList = JPO.invoke(context, JPOName, null, methodName, (String[]) JPO.packArgs(paraMap), MapList.class);
    if(dataList!=null&&dataList.size()>0){	
	try{
		String timeStac = new SimpleDateFormat("yyyyMMDDHHmmssms").format(new Date());
		String fileName=new String(sfile.getBytes("gb2312"), "iso8859-1")+"_"+timeStac+".xls";	
		HSSFWorkbook workbook = new HSSFWorkbook(); //create excel
		HashMap requestMap = new HashMap();
		
		requestMap.put("dataList", dataList);
 		requestMap.put("workbook", workbook);	
		methodName = "exportExcel";
		JPO.invoke(context, JPOName, null, methodName, (String[]) JPO.packArgs(requestMap));

		response.reset();
	 	response.setContentType("application/vnd.ms-excel;charset=UTF-8"); 
		response.setHeader("Content-Disposition","attachment; filename="+fileName);
		response.setCharacterEncoding("UTF-8");
		OutputStream outStream = response.getOutputStream();
		workbook.write(outStream);
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
