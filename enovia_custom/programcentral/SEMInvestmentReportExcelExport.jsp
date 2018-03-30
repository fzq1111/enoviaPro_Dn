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

    String mode=(String)emxGetParameter(request,"mode");
	if(mode.equals("DDR")){
	String objectId=request.getParameter("objectId");
    String msg="";
	StringList groupIdList=new StringList();
	String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
	for(int i=0;i<emxTableRowId.length;i++)
	{
		String[] splitValue = emxTableRowId[i].split("\\|");
		String selectedId = splitValue[1];
		String tableRowId = splitValue[3];	
		String[] splitRowId = tableRowId.split(",");
		System.out.println("length--"+splitRowId.length);
		if(splitRowId.length==3)
		{
			groupIdList.add(selectedId);
		}else{
			msg="\u6240\u9009\u9879\u5FC5\u987B\u5168\u90E8\u4E3A\u7EC4\uFF01";
			break;
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
	paraMap.put("objectId",objectId);
	paraMap.put("groupIdList", groupIdList);
	MapList dataList = new MapList();
	String JPOName="SEMInvestmentReportExport";
	String methodName="getDepartmentDetailsReport";
	String sfile="组级投资明细表";
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
}else if(mode.equals("DSR")){
	String objectId=request.getParameter("objectId");
    String msg="";
	StringList departmentIdList=new StringList();
	String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
	for(int i=0;i<emxTableRowId.length;i++)
	{
		String[] splitValue = emxTableRowId[i].split("\\|");
		String selectedId = splitValue[1];
		String tableRowId = splitValue[3];	
		String[] splitRowId = tableRowId.split(",");
		if(splitRowId.length==2)
		{
			departmentIdList.add(selectedId);
		}else{
			msg="\u6240\u9009\u9879\u5FC5\u987B\u5168\u90E8\u4E3A\u90E8\u95E8\uFF01";
			break;
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
	paraMap.put("objectId",objectId);
	paraMap.put("departmentIdList",departmentIdList);
	MapList dataList = new MapList();
	String JPOName="SEMInvestmentReportExport";
	String methodName="getDepartmentSummaryReport";
	String sfile="部门投资汇总表";
	dataList = JPO.invoke(context, JPOName, null, methodName, (String[]) JPO.packArgs(paraMap), MapList.class);
    if(dataList!=null&&dataList.size()>0){	
	try{
		String timeStac = new SimpleDateFormat("yyyyMMDDHHmmssms").format(new Date());
		String fileName=new String(sfile.getBytes("gb2312"), "iso8859-1")+"_"+timeStac+".xls";	
		HSSFWorkbook workbook = new HSSFWorkbook(); //create excel
		HashMap requestMap = new HashMap();
		
		requestMap.put("dataList", dataList);
 		requestMap.put("workbook", workbook);	
		methodName = "exportExcelDSR";
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
}else if(mode.equals("CSR")){
	String objectId=request.getParameter("objectId");
	HashMap paraMap = new HashMap();
	paraMap.put("objectId",objectId);
	MapList dataList = new MapList();
	String JPOName="SEMInvestmentReportExport";
	String methodName="getCompanySummaryReport";
	String sfile="公司级投资汇总表";
	dataList = JPO.invoke(context, JPOName, null, methodName, (String[]) JPO.packArgs(paraMap), MapList.class);
    if(dataList!=null&&dataList.size()>0){	
	try{
		String timeStac = new SimpleDateFormat("yyyyMMDDHHmmssms").format(new Date());
		String fileName=new String(sfile.getBytes("gb2312"), "iso8859-1")+"_"+timeStac+".xls";	
		HSSFWorkbook workbook = new HSSFWorkbook(); //create excel
		HashMap requestMap = new HashMap();
		
		requestMap.put("dataList", dataList);
 		requestMap.put("workbook", workbook);	
		methodName = "exportExcelCSR";
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
  }else if(mode.equals("ICR")){
	String msg="";
	StringList projectIdList=new StringList();
	String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
	if(emxTableRowId.length==2){
		for(int i=0;i<emxTableRowId.length;i++)
	   {
		String[] splitValue = emxTableRowId[i].split("\\|");
		String selectedId = splitValue[1];
		projectIdList.add(selectedId);
	 }
	}else{
		msg="\u6240\u9009\u9879\u76EE\u53EA\u80FD\u4E3A\u4E24\u4E2A\uFF01";
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
	paraMap.put("projectIdList",projectIdList);
	MapList dataList = new MapList();
	String JPOName="SEMInvestmentReportExport";
	String methodName="getInvestmentComparisonReport";
	String sfile="投资对比报表";
	dataList = JPO.invoke(context, JPOName, null, methodName, (String[]) JPO.packArgs(paraMap), MapList.class);
    if(dataList!=null&&dataList.size()>0){	
	try{
		String timeStac = new SimpleDateFormat("yyyyMMDDHHmmssms").format(new Date());
		String fileName=new String(sfile.getBytes("gb2312"), "iso8859-1")+"_"+timeStac+".xls";	
		HSSFWorkbook workbook = new HSSFWorkbook(); //create excel
		HashMap requestMap = new HashMap();
		
		requestMap.put("dataList", dataList);
 		requestMap.put("workbook", workbook);	
		methodName = "exportExcelICR";
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
}
%>
