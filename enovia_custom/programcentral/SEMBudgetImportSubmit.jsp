
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

  MapList maplist1 							= new MapList();
  boolean flag 								= false;
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
  //System.out.println("projectId---------"+projectId);
  DomainObject projectObj = new DomainObject(projectId);
  StringList busList = new StringList("id");
  busList.add("name");
  busList.add("id");
  busList.add("revision");
  StringList relList = new StringList(DomainRelationship.SELECT_ID);
  ContextUtil.startTransaction(context, true);
  String exceptionStr = "";
  
  
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
				String depId = "";	
				String gouId = "";
				DomainObject gouObj = new DomainObject();
				String FinancialItemsRId="";
				String costItemId = "";
				DomainRelationship CostToBudgetRel=new DomainRelationship();
				DomainObject depObj = new DomainObject();	
				DomainObject costItemObj =new DomainObject();
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
		    					if(hcellValue ==null || hcellValue==""){
		    						continue;
		    					} 		    				
							  }catch(Exception ex){
								   hcellValue="";
							  }finally{
								   hcellValue = hcellValue.trim();
							  }		
							  
												
							if(h==0 && hcellValue.length()>0)
							{	
								String strBudgetName = hcellValue;		
								String where = "name=='"+strBudgetName+"'";
								MapList deplist = projectObj.getRelatedObjects(context,"Project Financial Item","Budget", busList, relList,false,true, (short)1,where,"");															
								if(deplist.size()>0){
									for(int i=0;i<deplist.size();i++)
									{
										 Map depMap = (Map) deplist.get(i);
										 depId = (String) depMap.get("id");
										 depObj = new DomainObject(depId);
										 continue;			
									}
								}else{								
								 {
									 depObj.createObject(context,"Budget",strBudgetName , Calendar.getInstance().getTimeInMillis()+"", "Financial Items",vault);
									 depId = depObj.getInfo(context, "id");									
									 ContextUtil.pushContext(context);							 							
									 projectObj.connectTo(context,"Project Financial Item",depObj);
									 ContextUtil.popContext(context);									
								}	
								} 
							}
							if(h==1 && hcellValue.length()>0)
							{
								ContextUtil.pushContext(context);
								depObj.setAttributeValue(context,"SEM DepCode" ,hcellValue);								
								ContextUtil.popContext(context);								
							} 
							if(h==2 && hcellValue.length()>0)
							{
								String strBudgetGroup = hcellValue;	
								String where = "name=='"+strBudgetGroup+"'";
								MapList gouList = depObj.getRelatedObjects(context,"SEM Sub Budget","Budget", busList, relList,false,true, (short)1,where,"");	
								if(gouList.size()>0){
									for(int i=0;i<gouList.size();i++)
									{
										Map gouMap = (Map) gouList.get(i);
										gouId = (String) gouMap.get("id");

										gouObj = new DomainObject(gouId);
									}
								}else{System.out.println("strBudgetGroup == " + strBudgetGroup);
									gouObj.createObject(context,"Budget",strBudgetGroup, Calendar.getInstance().getTimeInMillis()+"", "Financial Items", vault);
									 gouId = gouObj.getInfo(context, "id");
									  ContextUtil.pushContext(context);
									   gouObj.connectFrom(context,"SEM Sub Budget",depObj);
								//gouToDepRel=gouObj.connectFrom(context,"SEM Sub Budget",depObj);
								ContextUtil.popContext(context);
								}								
							}
							if(h==3 && hcellValue.length()>0)
							{
								ContextUtil.pushContext(context);
								gouObj.setAttributeValue(context,"SEM DepCode",hcellValue);
								ContextUtil.popContext(context);

							}

														
							if(h==4 && hcellValue.length()>0)
							{
								String strCostItem = hcellValue;		
								String where = "name=='"+strCostItem+"'";
								MapList costItemList = gouObj.getRelatedObjects(context,"Financial Items","Cost Item", busList, relList,false,true, (short)1,where,"");	
															
								if(costItemList.size()>0){
									for(int i=0;i<costItemList.size();i++)
									{
										 Map costItemMap = (Map) costItemList.get(i);
										 costItemId = (String) costItemMap.get("id");
										 FinancialItemsRId= (String) costItemMap.get("id[connection]");
										 CostToBudgetRel=new DomainRelationship(FinancialItemsRId);
										 costItemObj = new DomainObject(costItemId);
									}
								}else{	
													
									 costItemObj.createObject(context,"Cost Item",strCostItem , Calendar.getInstance().getTimeInMillis()+"", "Financial Items", vault);
									 costItemId = costItemObj.getInfo(context, "id");

									 ContextUtil.pushContext(context);
							
									//costItemObj.connectFrom(context,"Financial Items",gouObj);	
									CostToBudgetRel=costItemObj.connectFrom(context,"Financial Items",gouObj);
									ContextUtil.popContext(context);								
								}									
							}	
							
							if(h==5 && hcellValue.length()>0)
							{
								ContextUtil.pushContext(context);
								
								CostToBudgetRel.setAttributeValue(context,"SEM Sequence",hcellValue);							
								ContextUtil.popContext(context);
							}							
							if(h==6 && hcellValue.length()>0)
							{					
									ContextUtil.pushContext(context);								
									costItemObj.setAttributeValue(context,"Planned Cost",hcellValue);
									ContextUtil.popContext(context);
							}
							
							if(h==7 && hcellValue.length()>0)
							{
								ContextUtil.pushContext(context);
								costItemObj.setAttributeValue(context,"SEM Cost Type",hcellValue);
								ContextUtil.popContext(context);
							}
					 	 }		
					}
				
					 
					
				}//end if .xlsx
				else if(excelContentType.equals(".xls")){
					 HSSFWorkbook hw = new HSSFWorkbook(item.getInputStream());
					 HSSFSheet hsheet = hw.getSheetAt(0);
					 int hrows = hsheet.getPhysicalNumberOfRows();
					 int hcells = hsheet.getRow(0).getPhysicalNumberOfCells();					 
					 HSSFRow hrow=null;
					 HSSFCell hcell=null;
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
		    					if(hcellValue ==null || hcellValue==""){
		    						continue;
		    					} 		    				
							  }catch(Exception ex){
								   hcellValue="";
							  }finally{
								   hcellValue = hcellValue.trim();
							  }		
							  
												
							if(h==0 && hcellValue.length()>0)
							{	
								String strBudgetName = hcellValue;		
								String where = "name=='"+strBudgetName+"'";
								MapList deplist = projectObj.getRelatedObjects(context,"Project Financial Item","Budget", busList, relList,false,true, (short)1,where,"");															
								if(deplist.size()>0){
									for(int i=0;i<deplist.size();i++)
									{
										 Map depMap = (Map) deplist.get(i);
										 depId = (String) depMap.get("id");
										 depObj = new DomainObject(depId);
										 continue;			
									}
								}else{
								
								 {
									 depObj.createObject(context,"Budget",strBudgetName , Calendar.getInstance().getTimeInMillis()+"", "Financial Items",vault);
									 depId = depObj.getInfo(context, "id");									
									 ContextUtil.pushContext(context);							 							
									 projectObj.connectTo(context,"Project Financial Item",depObj);
									 ContextUtil.popContext(context);									
								}	
								} 
							}
							if(h==1 && hcellValue.length()>0)
							{
								ContextUtil.pushContext(context);
								depObj.setAttributeValue(context,"SEM DepCode" ,hcellValue);								
								ContextUtil.popContext(context);								
							} 
							if(h==2 && hcellValue.length()>0)
							{
								String strBudgetGroup = hcellValue;	
								String where = "name=='"+strBudgetGroup+"'";
								MapList gouList = depObj.getRelatedObjects(context,"SEM Sub Budget","Budget", busList, relList,false,true, (short)1,where,"");	
								if(gouList.size()>0){
									for(int i=0;i<gouList.size();i++)
									{
										Map gouMap = (Map) gouList.get(i);
										gouId = (String) gouMap.get("id");
										//SEMSubBudgetRId= (String) gouMap.get("id[connection]");
										//gouToDepRel=new DomainRelationship(SEMSubBudgetRId);
										gouObj = new DomainObject(gouId);
									}
								}else{System.out.println("strBudgetGroup == " + strBudgetGroup);
									gouObj.createObject(context,"Budget",strBudgetGroup, Calendar.getInstance().getTimeInMillis()+"", "Financial Items", vault);
									gouId = gouObj.getInfo(context, "id");
									ContextUtil.pushContext(context);
								    gouObj.connectFrom(context,"SEM Sub Budget",depObj);
								    ContextUtil.popContext(context);
								}								
							}
							if(h==3 && hcellValue.length()>0)
							{
								ContextUtil.pushContext(context);
								gouObj.setAttributeValue(context,"SEM DepCode",hcellValue);
								ContextUtil.popContext(context);

							}

														
							if(h==4 && hcellValue.length()>0)
							{
								String strCostItem = hcellValue;		
								String where = "name=='"+strCostItem+"'";
								MapList costItemList = gouObj.getRelatedObjects(context,"Financial Items","Cost Item", busList, relList,false,true, (short)1,where,"");	
															
								if(costItemList.size()>0){
									for(int i=0;i<costItemList.size();i++)
									{
										 Map costItemMap = (Map) costItemList.get(i);
										 costItemId = (String) costItemMap.get("id");
										 FinancialItemsRId= (String) costItemMap.get("id[connection]");
										 CostToBudgetRel=new DomainRelationship(FinancialItemsRId);
										 costItemObj = new DomainObject(costItemId);
									}
								}else{	
													
									 costItemObj.createObject(context,"Cost Item",strCostItem , Calendar.getInstance().getTimeInMillis()+"", "Financial Items", vault);
									 costItemId = costItemObj.getInfo(context, "id");
									 ContextUtil.pushContext(context);							
									 //costItemObj.connectFrom(context,"Financial Items",gouObj);	
									 CostToBudgetRel=costItemObj.connectFrom(context,"Financial Items",gouObj);
									 ContextUtil.popContext(context);								
								}									
							}	
							
							if(h==5 && hcellValue.length()>0)
							{
								ContextUtil.pushContext(context);								
								CostToBudgetRel.setAttributeValue(context,"SEM Sequence",hcellValue);							
								ContextUtil.popContext(context);
							}							
							if(h==6 && hcellValue.length()>0)
							{					
									ContextUtil.pushContext(context);								
									costItemObj.setAttributeValue(context,"Planned Cost",hcellValue);
									ContextUtil.popContext(context);
							}
							
							if(h==7 && hcellValue.length()>0)
							{
								ContextUtil.pushContext(context);
								costItemObj.setAttributeValue(context,"SEM Cost Type",hcellValue);
								ContextUtil.popContext(context);
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
		 
		 throw new Exception(ex.getMessage());
		  
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
	SimpleDateFormat dateformat = new SimpleDateFormat("yyyy-mm-dd");
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
	SimpleDateFormat dateformat = new SimpleDateFormat("yyyy-mm-dd");
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