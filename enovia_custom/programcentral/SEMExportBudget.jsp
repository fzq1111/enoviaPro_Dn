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
	String objectId=request.getParameter("objectId");
	//System.out.println("objectId="+objectId);

	HashMap paraMap = new HashMap();
	paraMap.put("objectId",objectId);
	MapList dataList = new MapList();
	String JPOName="SEMExport";
	String methodName="searchSEMBudget";
	String sfile="投资清单";
//System.out.println("111111111111111");
	dataList = JPO.invoke(context, JPOName, null, methodName, (String[]) JPO.packArgs(paraMap), MapList.class);
	
if(dataList!=null&&dataList.size()>0){	
	try{
		String timeStac = new SimpleDateFormat("yyyyMMDDHHmmssms").format(new Date());
		String fileName=new String(sfile.getBytes("gb2312"), "iso8859-1")+"_"+timeStac+".xls";	
		HSSFWorkbook workbook = new HSSFWorkbook();
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
}else{
%>
<script>
	alert("\u6CA1\u6709\u53EF\u5BFC\u51FA\u7684\u6570\u636E\uFF01");	
	window.close();
</script>
<%
}	
%>
