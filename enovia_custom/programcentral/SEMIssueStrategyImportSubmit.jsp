
<%@page import="java.util.regex.Pattern"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="java.util.*,
                java.util.List,
				java.util.Set,
                java.util.Iterator,
                java.io.FileInputStream,
                java.io.InputStream,
                java.util.regex.*,
                java.io.File,
                java.io.BufferedInputStream,
				java.text.SimpleDateFormat,
				com.matrixone.apps.domain.util.eMatrixDateFormat,
                javax.servlet.ServletOutputStream"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload,
                org.apache.commons.fileupload.FileItem,
                org.apache.poi.poifs.filesystem.POIFSFileSystem,
                org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFWorkbook,
                org.apache.poi.xssf.usermodel.XSSFSheet,
                org.apache.poi.xssf.usermodel.XSSFRow,
                org.apache.poi.xssf.usermodel.XSSFCell,
                org.apache.poi.xssf.usermodel.XSSFDataFormat,
                org.apache.poi.hssf.usermodel.HSSFWorkbook,
                org.apache.poi.hssf.usermodel.HSSFSheet,
                org.apache.poi.hssf.usermodel.HSSFRow,
                org.apache.poi.hssf.usermodel.HSSFDateUtil,
                org.apache.poi.hssf.usermodel.HSSFCell"%>


<%
	
  String language=(String)emxGetParameter(request,"languageStr");
 
  List<String> failList 					= new ArrayList<String>();
  List<String> notExistPartList 			= new ArrayList<String>();
  Map<String,Set> parentPartAndFnMap 		= new HashMap<String ,Set>();
  List<String> notPreAssemblyOrNoAccessList = new ArrayList<String>();
  com.matrixone.apps.common.Person person 	= com.matrixone.apps.common.Person.getPerson(context);
  String personName 						= person.getName();
  String strSysEnginner 					= PropertyUtil.getSchemaProperty(context, "role_AdministrationManager");
  String dialogMessage 						= null;
  String strLanguage 						= request.getHeader("Accept-Language");
  String projectId=emxGetParameter(request,"objectId");
  String flag=emxGetParameter(request,"typeflag");

  DomainObject projectObj = new DomainObject(projectId);
  String currentUser =context.getUser();
  String fullName=person.getDisplayName(context,currentUser);
  String[] names=fullName.split(" ");
  currentUser=names[1];
  
  
  StringList busList = new StringList("id");
  busList.add("name");
  busList.add("id");
  busList.add("revision");
  StringList relList = new StringList(DomainRelationship.SELECT_ID);
  ContextUtil.startTransaction(context, true);
  String exceptionStr = "";
  boolean flagbool=false;
  int[] pos=new int[20];
  int[] cj=new int[]{11,7,8,13,14,100,100,100,100,100,100};
  int[] sd=new int[]{5,3,7,8,100,13,100,100,100,100,100};
  int[] seg=new int[]{9,100,11,12,100,20,13,14,15,100,100};
  int[] cs=new int[]{20,100,7,18,21,25,17,26,100,8,28};
  int[] pj=new int[]{13,9,10,11,18,100,100,100,100,17,100};
  int[] cy=new int[]{18,11,12,13,14,100,100,19,24,25,21};
  int[] hz=new int[]{19,8,9,11,12,22,100,23,10,13,21};
  int[] tz=new int[]{11,9,10,14,15,100,100,13,100,16,24};
  int[] zz=new int[]{12,6,7,15,16,13,100,14,8,17,9};
  if(flag.equals("Vehicle Check Issue")){
	  pos=Arrays.copyOf(cj,cj.length);
  }else if(flag.equals("Market Survey Issue")||flag.equals("Test Drive Issue")||flag.equals("Case Issue")||flag.equals("Budget Issue")){
	  pos=Arrays.copyOf(sd,sd.length);
  }else if(flag.equals("SEG Model Issue")||flag.equals("SEG Engineer Issue")||flag.equals("Structure Analyse Issue")){
	  pos=Arrays.copyOf(seg,seg.length);
  }else if(flag.equals("Vehicle Test Issue")||flag.equals("Performance Test Issue")){
	  pos=Arrays.copyOf(cs,cs.length);
  }else if(flag.equals("Assess Issue")){
	  pos=Arrays.copyOf(pj,pj.length);
  }else if(flag.equals("Try Stamping Issue")){
	   pos=Arrays.copyOf(cy,cy.length);
  }else if(flag.equals("Try Welding Issue")){
		 pos=Arrays.copyOf(hz,hz.length);
  }else if(flag.equals("Try Coating Issue")){
		 pos=Arrays.copyOf(tz,tz.length);
  }else if(flag.equals("Try Assembly Issue")){
		 pos=Arrays.copyOf(zz,zz.length);
  }					
  if(ServletFileUpload.isMultipartContent(request))
  {
	  DiskFileItemFactory factory =  new DiskFileItemFactory();
	  factory.setSizeThreshold(1024*1000);    //  指定在内存中缓存数据大小,单位为byte
	  //factory.setRepository(new File("C:/tempload"));            
	  ServletFileUpload fileUpload=new ServletFileUpload(factory);            
	  fileUpload.setFileSizeMax(20*1024*1024);//设置最大文件大小
	  try{
		  @SuppressWarnings("unchecked")
		  List<FileItem> items=fileUpload.parseRequest(request);//获取所有表单
         
		  for(FileItem item:items)
		  {
			  if(!item.isFormField())
			  {
				String excelFileName = new String(item.getName().getBytes(), "utf-8"); //获取上传文件的名称      
				  //上传文件必须为excel类型,根据后缀判断(xls)                       
				String excelContentType = excelFileName.substring(excelFileName.lastIndexOf(".")); //获取上传文件的类型
			    String cellValue ="";
				String issueId = "";	
				DomainObject IssueObj =new DomainObject();

				if(excelContentType.equals(".xlsx"))
				{
				
					 XSSFWorkbook hw = new XSSFWorkbook(item.getInputStream());
					 XSSFSheet hsheet = hw.getSheetAt(0);
					 int hrows = hsheet.getPhysicalNumberOfRows();
					 int hcells = hsheet.getRow(0).getPhysicalNumberOfCells();
					 String vault = context.getVault().getName();
					 XSSFRow hrow=null;
					 XSSFCell hcell=null;	
					
					 for(int z=1;z<hrows;z++)
					 {  
						hrow = hsheet.getRow(z);			
					 	for(int h=0;h<=hcells;h++)
					 	{
							 hcell = hrow.getCell(h);
							 String hcellValue="";
							 try{		    					  
		    					hcellValue = getExcelCellValue(hcell);	    				
							  }catch(Exception ex){
								   hcellValue="";
							  }finally{
								   hcellValue = hcellValue.trim();
							  }	
							  
							 if(h==0&&hcellValue.length()==0)
							  { 
								 
								if(hcellValue.length()==0){
								%>
								  <script type="text/javascript">
									alert("\u95EE\u9898\u7F16\u53F7\u4E0D\u80FD\u4E3A\u7A7A!");
									top.window.close();
								  </script>
								<%	
								flagbool=true;
								break;
								 }else{
								  String strIssueName = hcellValue;		
								  String where = "name=='"+strIssueName+"'";
								  MapList issuelist = projectObj.getRelatedObjects(context,"Issue","Issue", busList, relList,false,true, (short)1,where,"");															
								  if(issuelist.size()==0)
								  {
									%>
									  <script type="text/javascript">
										alert("\u7F16\u53F7\u4E0D\u5B58\u5728  \u8BF7\u6838\u5BF9");
										top.window.close();
									  </script>
									<%
									flagbool=true;
									break;
								  }
							    }	
							  }	
							if(h==pos[0]&&hcellValue.length()>0)
							{
								if(!currentUser.equals(hcellValue))
								{	
							   %>
								  <script type="text/javascript">
									alert("\u5BFC\u5165\u95EE\u9898\u6E05\u5355\u4E2D\u5B58\u5728\u5BF9\u7B56\u4EBA\u4E0D\u662F\u5F53\u524D\u767B\u5F55\u4EBA!");
									top.window.close();
								  </script>
								 <%	
									flagbool=true;	
                                    break;									
								}						
							}
                            if(h==pos[3]&&hcellValue.length()==0){
								 %>
								  <script type="text/javascript">
									alert("\u5BF9\u7B56\u65E5\u671F\u4E0D\u80FD\u4E3A\u7A7A!");
									top.window.close();
								  </script>
								 <%	
									flagbool=true;	
                                    break;	
                            }								
						}
						if(flagbool==true){
							break;
						}
					 }
					 if(flagbool==true)
					 {
						flagbool=false;
						break;
					 }
				
					 for(int z=1;z<hrows;z++)
					 {  

						hrow = hsheet.getRow(z);			
					 	for(int h=0;h<=hcells;h++)
					 	{
							 hcell = hrow.getCell(h);
							 String hcellValue="";
							 try{		    					  
		    					hcellValue = getExcelCellValue(hcell);
	    				
							  }catch(Exception ex){
								   hcellValue="";
							  }finally{
								   hcellValue = hcellValue.trim();
							  }		
						
							if(h==0)
							{			
														
								if( hcellValue.length()!=0)
								{
								String strIssueName = hcellValue;		

								String where = "name=='"+strIssueName+"'";
								MapList issuelist = projectObj.getRelatedObjects(context,"Issue","Issue", busList, relList,false,true, (short)1,where,"");	
						
								if(issuelist.size()>0){
									for(int i=0;i<issuelist.size();i++)
									{
										 Map issuemap = (Map) issuelist.get(i);
										 issueId = (String) issuemap.get("id");
										
										 IssueObj = new DomainObject(issueId);	
									}
								}
								}
							}else if(h==pos[1]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue Reason",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[2]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"Resolution Recommendation",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[3]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"Resolution Date",changeDate(hcellValue));
								//ContextUtil.popContext(context);
							}else if(h==pos[4]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue Solution TestCarCode",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[5]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue Undertaker",hcellValue);
							}else if(h==pos[6]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"Estimated End Date",changeDate(hcellValue));
							}else if(h==pos[7]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Supplier",hcellValue);
							}else if(h==pos[8]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM SupplierResolution Recommendation",hcellValue);
							}else if(h==pos[9]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Phase To Resolution",hcellValue);
							}else if(h==pos[10]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue EO",hcellValue);
							}
					 } 
					 }	
		}//end if .xlsx
				else if(excelContentType.equals(".xls"))
				{	
					 HSSFWorkbook hw = new HSSFWorkbook(item.getInputStream());
					 HSSFSheet hsheet = hw.getSheetAt(0);
					 int hrows = hsheet.getPhysicalNumberOfRows();
					 int hcells = hsheet.getRow(0).getPhysicalNumberOfCells();
					 HSSFRow hrow=null;
					 HSSFCell hcell=null;
					 boolean flag1=false;
					 String vault = context.getVault().getName();
				
					 for(int z=1;z<hrows;z++)
					 {  
						hrow = hsheet.getRow(z);			
					 	for(int h=0;h<=hcells;h++)
					 	{
							 hcell = hrow.getCell(h);
							 String hcellValue="";
							 try{		    					  
		    					hcellValue = getExcelCellValue(hcell);	    				
							  }catch(Exception ex){
								   hcellValue="";
							  }finally{
								   hcellValue = hcellValue.trim();
							  }	
							  
							  if(h==0&&hcellValue.length()==0)
							  { 
								 
								if(hcellValue.length()==0){
								%>
								  <script type="text/javascript">
									alert("\u95EE\u9898\u7F16\u53F7\u4E0D\u80FD\u4E3A\u7A7A!");
									top.window.close();
								  </script>
								<%	
								flagbool=true;
								 break;	
								 }else{
								  String strIssueName = hcellValue;		
								  String where = "name=='"+strIssueName+"'";
								  MapList issuelist = projectObj.getRelatedObjects(context,"Issue","Issue", busList, relList,false,true, (short)1,where,"");															
								  if(issuelist.size()==0)
								  {
									%>
									  <script type="text/javascript">
										alert("\u7F16\u53F7\u4E0D\u5B58\u5728  \u8BF7\u6838\u5BF9");
										top.window.close();
									  </script>
									<%
									flagbool=true;
									 break;	
								  }
							    }	
							  }							  
							if(h==pos[0]&&hcellValue.length()>0)
							{
								if(!currentUser.equals(hcellValue))
								{
								  %>
								  <script type="text/javascript">
									alert("\u5BFC\u5165\u95EE\u9898\u6E05\u5355\u4E2D\u5B58\u5728\u5BF9\u7B56\u4EBA\u4E0D\u662F\u5F53\u524D\u767B\u5F55\u4EBA!");
									top.window.close();
								  </script>
								 <%	
									flagbool=true;
                                    break;										
								}						
							}
                            if(h==pos[3]&&hcellValue.length()==0){
								 %>
								  <script type="text/javascript">
									alert("\u5BF9\u7B56\u65E5\u671F\u4E0D\u80FD\u4E3A\u7A7A!");
									top.window.close();
								  </script>
								 <%	
									flagbool=true;	
                                    break;	
                            }									
						}
						if(flagbool==true)
						{
							break;
						}
					 }
					 	if(flagbool==true)
						{
							flagbool=false;
							break;
						}
				
					 for(int z=1;z<hrows;z++)
					 {  

						hrow = hsheet.getRow(z);			
					 	for(int h=0;h<=hcells;h++)
					 	{
							 hcell = hrow.getCell(h);
							 String hcellValue="";
							 try{		    					  
		    					hcellValue = getExcelCellValue(hcell);
	    				
							  }catch(Exception ex){
								   hcellValue="";
							  }finally{
								   hcellValue = hcellValue.trim();
							  }		
						
							if(h==0)
							{			
														
								if( hcellValue.length()!=0)
								{
								String strIssueName = hcellValue;		

								String where = "name=='"+strIssueName+"'";
								MapList issuelist = projectObj.getRelatedObjects(context,"Issue","Issue", busList, relList,false,true, (short)1,where,"");	
						
								if(issuelist.size()>0){
									for(int i=0;i<issuelist.size();i++)
									{
										 Map issuemap = (Map) issuelist.get(i);
										 issueId = (String) issuemap.get("id");
										
										 IssueObj = new DomainObject(issueId);	
									}
								}
								}			
							}else if(h==pos[1]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue Reason",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[2]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"Resolution Recommendation",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[3]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"Resolution Date",changeDate(hcellValue));
								//ContextUtil.popContext(context);
							}else if(h==pos[4]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue Solution TestCarCode",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[5]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue Undertaker",hcellValue);
							}else if(h==pos[6]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"Estimated End Date",changeDate(hcellValue));
							}else if(h==pos[7]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Supplier",hcellValue);
							}else if(h==pos[8]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM SupplierResolution Recommendation",hcellValue);
							}else if(h==pos[9]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Phase To Resolution",hcellValue);
							}else if(h==pos[10]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue EO",hcellValue);
							}									
					 } 
				
					 }					
				}		
	 		 }
		 }
		 ContextUtil.commitTransaction(context);
	  }catch(Exception ex){
		  ex.printStackTrace();
		  ContextUtil.abortTransaction(context);
		 
		 //throw new Exception(ex.getMessage());
		  
	  }
	  	  
  }



%>
  <script type="text/javascript">
  	opener.parent.location.href = opener.parent.location.href;
  	alert("\u5BFC\u5165\u5B8C\u6210\u3002");
	top.window.close();
		
</script> 

<%!

public String changeDate(String strDate)throws Exception
{
	try{
		if(strDate.length()>0)
		{
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");
			java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
			Date date2 = dateFormat.parse(strDate);		
			strDate = formatter.format(date2);		
			return strDate;
		}else{
			return "";
		}
	}catch(Exception e){
		throw new Exception(e.getMessage());
	}
	
}



public static String getExcelCellValue(XSSFCell xCell)throws Exception
{
	if(xCell == null)
	{
		return "";
	}
	int cellType = xCell.getCellType();
	SimpleDateFormat dateformat = new SimpleDateFormat("yyyy/MM/dd");
	String v_excelData = "";
	switch (cellType) {
		case 0 :
	        if ( org.apache.poi.hssf.usermodel.HSSFDateUtil.isCellDateFormatted(xCell) ){
	        	v_excelData = dateformat.format( xCell.getDateCellValue() );      
	        }else{         
				long longVal = Math.round(xCell.getNumericCellValue());  
				Double doubleVal = xCell.getNumericCellValue();
				if(Double.parseDouble(longVal + ".0") == doubleVal)  
					v_excelData = longVal+"";  
        	    else  
					v_excelData = doubleVal+"";  
	        }                  
	        break;
		case 1 :
			v_excelData = xCell.getStringCellValue().trim();
			break;
		case 2:
			v_excelData = xCell.getNumericCellValue() + "";
			break;
		case 3:
			v_excelData = ""; 
			break;
		case 4:
			v_excelData = xCell.getBooleanCellValue() + "";  
			break; 
		case 5:
			v_excelData = "";
			break;
	}
	return v_excelData.trim();
}

public static String getExcelCellValue(HSSFCell xCell)throws Exception
{
	if(xCell == null)
	{
		return "";
	}
	int cellType = xCell.getCellType();
	SimpleDateFormat dateformat = new SimpleDateFormat("yyyy/MM/dd");
	String v_excelData = "";
	switch (cellType) {
		case 0 :
	        if ( org.apache.poi.hssf.usermodel.HSSFDateUtil.isCellDateFormatted(xCell) ){
	        	v_excelData = dateformat.format( xCell.getDateCellValue() );      
	        }else{         
				long longVal = Math.round(xCell.getNumericCellValue());  
				Double doubleVal = xCell.getNumericCellValue();
				if(Double.parseDouble(longVal + ".0") == doubleVal)  
					v_excelData = longVal+"";  
        	    else  
					v_excelData = doubleVal+"";  
	        }                  
	        break;
		case 1 :
			v_excelData = xCell.getStringCellValue().trim();
			break;
		case 2:
			v_excelData = xCell.getNumericCellValue() + "";
			break;
		case 3:
			v_excelData = ""; 
			break;
		case 4:
			v_excelData = xCell.getBooleanCellValue() + "";  
			break; 
		case 5:
			v_excelData = "";
			break;
	}
	return v_excelData.trim();
}


%>