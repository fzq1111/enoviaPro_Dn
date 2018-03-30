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

		String objectId=emxGetParameter(request,"objectId");
		String flag=emxGetParameter(request,"typeflag");
		StringList busList = new StringList(DomainConstants.SELECT_ID);
		StringList relList = new StringList("id[connection]");		   
		String language = request.getHeader("Accept-Language");
		StringList orang=mxAttr.getChoices(context,"SEM Issue Type1");
	    StringList fyorang=i18nNow.getAttrRangeI18NStringList("SEM Issue Type1", orang,language);
	    String issueType="";
	    for (int i = 0; i <orang.size(); i++)
	    {
			if(orang.get(i).equals(flag)){
				 issueType=(String)fyorang.get(i);
				 break;
			}
	    }
	    //System.out.println("issueType===="+issueType);
	    String where="attribute[SEM Issue Type]=='"+issueType+"'";
		DomainObject projectObj = new DomainObject(objectId);
		MapList Issuelist = projectObj.getRelatedObjects(context,
				"Issue", "Issue", busList, relList,false,true,
				(short)1,where, null);

		HashMap paraMap = new HashMap();
		paraMap.put("Issuelist",Issuelist);
		paraMap.put("objectId",objectId);
		paraMap.put("issueType",issueType);
		String JPOName="SEMIssueBOM";
		String methodName0="searchIssueProgress";
		String methodName1="searchDepIssue";
		String methodName2="searchClassifiedIssue";
		String methodName3="searchMajorIssue";
		String sfile="\u95EE\u9898\u62A5\u8868";
		MapList dataList0 = JPO.invoke(context, JPOName, null, methodName0, (String[]) JPO.packArgs(paraMap), MapList.class);
		MapList  dataList1 = JPO.invoke(context, JPOName, null, methodName1, (String[]) JPO.packArgs(paraMap), MapList.class);
		 MapList dataList2 = JPO.invoke(context, JPOName, null, methodName2, (String[]) JPO.packArgs(paraMap), MapList.class);
		MapList dataList3 = JPO.invoke(context, JPOName, null, methodName3, (String[]) JPO.packArgs(paraMap), MapList.class);
	if(dataList0!=null&&dataList0.size()>0){	
	try{
		String timeStac = new SimpleDateFormat("yyyyMMDDHHmmssms").format(new Date());
		String fileName=new String(sfile.getBytes("gb2312"), "iso8859-1")+"_"+timeStac+".xls";	
		HSSFWorkbook workbook = new HSSFWorkbook(); //create excel
		HashMap requestMap = new HashMap();
		requestMap.put("dataList0", dataList0);
		requestMap.put("dataList1", dataList1);
		//System.out.println("Test123343");
		requestMap.put("dataList2", dataList2);
		requestMap.put("dataList3", dataList3);
 		requestMap.put("workbook", workbook);	
		String methodName = "exportExcel";
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
%>
