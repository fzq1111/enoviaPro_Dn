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
    //System.out.println("111111111111111111111111111111");
	String objectId=request.getParameter("objectId");
	String mode = emxGetParameter(request, "mode");
	String typeflag=emxGetParameter(request,"flag");
	//System.out.println("typeflag---"+typeflag);
	String languageStr=emxGetParameter(request, "languageStr");
	String[] emxTableRowId= emxGetParameterValues(request, "emxTableRowId");
	HashMap paraMap = new HashMap();
	paraMap.put("objectId",objectId);
	paraMap.put("mode",mode);
	paraMap.put("languageStr",languageStr);
	paraMap.put("emxTableRowId",emxTableRowId);
	MapList dataList = new MapList();
	String JPOName="SEMExportIssue";
	String methodName="searchSEMIssue";
	String sfile="问题清单";

	dataList = JPO.invoke(context, JPOName, null, methodName, (String[]) JPO.packArgs(paraMap), MapList.class);
	String currentUser=context.getUser();
	boolean flag=false;
	
	String strAlertMessage="";
    if(dataList!=null&&dataList.size()>0){	
	try{
		String timeStac = new SimpleDateFormat("yyyyMMDDHHmmssms").format(new Date());
		String fileName=new String(sfile.getBytes("gb2312"), "iso8859-1")+"_"+timeStac+".xls";	
		HSSFWorkbook workbook = new HSSFWorkbook();
		HashMap requestMap = new HashMap();
		requestMap.put("dataList", dataList);
 		requestMap.put("workbook", workbook);
        if(typeflag.equals("Vehicle Check Issue")){
			methodName = "exportExcel";
        }else if(typeflag.equals("Market Survey Issue")||typeflag.equals("Test Drive Issue")||typeflag.equals("Case Issue")||typeflag.equals("Budget Issue")){
			methodName = "exportExcel1";
        }else if(typeflag.equals("SEG Model Issue")||typeflag.equals("SEG Engineer Issue")||typeflag.equals("Structure Analyse Issue")){
			methodName = "exportExcel2";
		}else if(typeflag.equals("Vehicle Test Issue")||typeflag.equals("Performance Test Issue")){
			methodName = "exportExcel11";
		}else if(typeflag.equals("Assess Issue")){
			methodName = "exportExcel10";
		}else if(typeflag.equals("Try Stamping Issue")){
			methodName = "exportExcel5";
		}else if(typeflag.equals("Try Welding Issue")){
			methodName = "exportExcel6";
		}else if(typeflag.equals("Try Coating Issue")){
			methodName = "exportExcel7";
		}else if(typeflag.equals("Try Assembly Issue")){
			methodName = "exportExcel8";
		}												
		
		if(mode.equals("SEMExportUpdateIssue"))
		{
			for(int i=0;i<dataList.size();i++)
			{
			
				Map datamap=(Map)dataList.get(i);
				String issueOwner=(String)datamap.get("ownerName");	
				if(!issueOwner.equals(currentUser))
				{
					strAlertMessage += "\u5F53\u524D\u95EE\u9898" + datamap.get("name")+"\u7684\u6240\u6709\u8005\u4E0D\u662F\u5F53\u524D\u767B\u5F55\u4EBA;";
					flag=true;
				}
			}
		}else if(mode.equals("SEMExportStategyIssue"))
		{
			for(int i=0;i<dataList.size();i++)
			{
				Map datamap=(Map)dataList.get(i);
				String IssueSolutionDealer=(String)datamap.get("strPerson");
				if(!IssueSolutionDealer.equals(currentUser))
				{
					strAlertMessage += "\u5F53\u524D\u95EE\u9898" + datamap.get("name")+"\u7684\u5BF9\u7B56\u4EBA\u4E0D\u662F\u5F53\u524D\u767B\u5F55\u4EBA;";
					flag=true;
				}
			}
		}
		if(flag==false)
		{
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
		}
		else
		{
					%>
					<script type="text/javascript">	
					alert("<%=strAlertMessage%>");	
					</script>
					<%
		}
  
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
