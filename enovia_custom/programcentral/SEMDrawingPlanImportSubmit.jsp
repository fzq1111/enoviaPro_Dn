
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
  System.out.println(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date()));
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

  DomainObject projectObj = new DomainObject(projectId);
  StringList busList = new StringList("id");
  busList.add("name");
  busList.add("id");
  busList.add("revision");
  StringList relList = new StringList(DomainRelationship.SELECT_ID);
  ContextUtil.startTransaction(context, true);
  String exceptionStr = "";
  String strCurrLoginUser = context.getUser();//add by ryan 2017-10-30
  
  
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
				
				String currentId="";
				int nParentLevel = 0;
				String currParentId= projectId;
				String prevId = "";
				Stack stack = new Stack();
				DomainObject currParentObj=new DomainObject();
				DomainObject SEMTaskItemSJObj = new DomainObject();	
				DomainObject SEMTaskItemCSObj =new DomainObject();
				DomainObject SEMTaskItemDPObj =new DomainObject();
				DomainObject SEMTaskItemYSObj =new DomainObject();
				DomainObject SEMTaskItemBPObj =new DomainObject();
				DomainObject SEMTaskItemZLObj =new DomainObject();
				DomainObject SEMTaskItemCRObj =new DomainObject();
				DomainObject SEMTaskItemDFObj =new DomainObject();
				DomainObject currentObj=new DomainObject();
				if(excelContentType.equals(".xlsx"))
				{
					System.out.println("begin"+new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date()));
					 XSSFWorkbook hw = new XSSFWorkbook(item.getInputStream());
					 XSSFSheet hsheet = hw.getSheetAt(0);
					 int hrows = hsheet.getPhysicalNumberOfRows();
					 int hcells = hsheet.getRow(0).getPhysicalNumberOfCells();
					 
					  String vault = context.getVault().getName();
					 XSSFRow hrow=null;
					 XSSFCell hcell=null;

					 for(int z=4;z<hrows;z++)
					 {  
						//System.out.println(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date()));
						//	System.out.println("z==================="+z);
						hrow = hsheet.getRow(z);
						String[] colValue=new String[hcells];
						for(int m=0;m<hcells;m++)
						{	
							hcell = hrow.getCell(m);
							colValue[m]=getExcelCellValue(hcell);
						}
						
						String currentName = colValue[1];	
						if(currentName.trim().equals(""))
						{
							continue;
						}
						
						String strLevel=colValue[0];
						int nLevel=0;
						String strCurRel="SEM SubPart";
						if(strLevel.equals(""))
						{
							nLevel=1;
							strCurRel="SEM Project PartTask";
						}else if(strLevel.equals("0"))
						{
							nLevel=2;
						}else if(strLevel.equals("1"))
						{
							nLevel=3;
						}else
						{
							continue;
						}
						if(nLevel - nParentLevel > 1)
						{
							nParentLevel = nLevel - 1;
							stack.push(currParentId);
							currParentId = prevId;
						}
						else if(nLevel - nParentLevel == 1)
						{
							
						}
						else
						{
							for(int m = nLevel - nParentLevel; m < 1; m ++)
							{
								currParentId = (String)stack.pop();
							}
							nParentLevel = nLevel - 1;
						}
						currParentObj=new DomainObject(currParentId);					
						String where = "name=='"+currentName+"'";
						MapList TempList=DomainObject.findObjects(context, "SEM Part Task", currentName, "-", "*", vault, null, true, busList);
						
						if(TempList!=null&&TempList.size()>0)
						{
							for(int k=0;k<TempList.size();k++)
							{
								HashMap TempMap=(HashMap)TempList.get(k);
								String TempId=(String)TempMap.get("id");
								currentId = TempId;
								currentObj = new DomainObject(currentId);
								String wherePart="id=='"+TempId+"'";
								MapList partTaskList = currParentObj.getRelatedObjects(context,strCurRel,"SEM Part Task", busList, relList,false,true, (short)1,wherePart,"");	
								if(partTaskList!=null&&partTaskList.size()>0)
								{
									for(int j=0;j<partTaskList.size();j++)
									{
										 Map partTaskMap = (Map) partTaskList.get(j);
									}
								}else
								{								 						 							
									 currParentObj.connectTo(context,strCurRel,currentObj);
								}
							}
						}else
						{
							currentObj.createObject(context,"SEM Part Task",currentName , "-", "SEM Part Task",vault);
							currentId = currentObj.getInfo(context,"id");
							currParentObj.connectTo(context,strCurRel,currentObj);
						}
						prevId = currentId;	
						
						//add by ryan 2017-10-30
						String strObjOwner = currentObj.getInfo(context, "owner");
						if(!strObjOwner.equals(strCurrLoginUser))
						{
							continue;
						}
						//add end
						      
					//	System.out.println(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date()));
					//	System.out.println("prevId================"+prevId);	
						
						String wherecs = "name == '\u5382\u5546\u5B9A\u70B9'";
						MapList SEMTaskItemCS = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wherecs,"");							
						for(int j=0;j<SEMTaskItemCS.size();j++)
						{ 
							Map SEMTaskItemCSmap =(Map)SEMTaskItemCS.get(j);
							String SEMTaskItemCSId = (String) SEMTaskItemCSmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemCSObj=new DomainObject(SEMTaskItemCSId);
						}
						String wheresj = "name == '\u8BBE\u8BA1\u6784\u60F3\u4E66'";
						MapList SEMTaskItemSJ = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wheresj,"");
						for(int j=0;j<SEMTaskItemSJ.size();j++)
						{ 
							Map SEMTaskItemSJmap =(Map)SEMTaskItemSJ.get(j);
							String SEMTaskItemSJId = (String) SEMTaskItemSJmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemSJObj=new DomainObject(SEMTaskItemSJId);
						}
						String wheredf = "name == '3D-F'";
						MapList SEMTaskItemDF = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wheredf,"");
						for(int j=0;j<SEMTaskItemDF.size();j++)
						{ 
							Map SEMTaskItemDFmap =(Map)SEMTaskItemDF.get(j);
							String SEMTaskItemDFId = (String) SEMTaskItemDFmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemDFObj=new DomainObject(SEMTaskItemDFId);
						}
				
						String wheredp = "name == '3D-P'";
						MapList SEMTaskItemDP = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wheredp,"");
						for(int j=0;j<SEMTaskItemDP.size();j++)
						{ 
							Map SEMTaskItemDPmap =(Map)SEMTaskItemDP.get(j);
							String SEMTaskItemDPId = (String) SEMTaskItemDPmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemDPObj=new DomainObject(SEMTaskItemDPId);
						}
						String whereys = "name == '\u8BBE\u8BA1\u4ED5\u6837\u56FE'";
						MapList SEMTaskItemYS = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,whereys,"");
						for(int j=0;j<SEMTaskItemYS.size();j++)
						{ 
							Map SEMTaskItemYSmap =(Map)SEMTaskItemYS.get(j);
							String SEMTaskItemYSId = (String) SEMTaskItemYSmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemYSObj=new DomainObject(SEMTaskItemYSId);
						}
						String wherebp= "name == '\u90E8\u54C1\u56FE'";
						MapList SEMTaskItemBP = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wherebp,"");
						for(int j=0;j<SEMTaskItemBP.size();j++)
						{ 
							Map SEMTaskItemBPmap =(Map)SEMTaskItemBP.get(j);
							String SEMTaskItemBPId = (String) SEMTaskItemBPmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemBPObj=new DomainObject(SEMTaskItemBPId);
						}
					   String wherecr= "name == '\u627F\u8BA4\u56FE'";
						MapList SEMTaskItemCR= currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wherecr,"");
						for(int j=0;j<SEMTaskItemCR.size();j++)
						{ 
							Map SEMTaskItemCRmap =(Map)SEMTaskItemCR.get(j);
							String SEMTaskItemCRId = (String) SEMTaskItemCRmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemCRObj=new DomainObject(SEMTaskItemCRId);
						}
						String wherezl= "name == '\u7EC4\u7ACB\u56FE'";
						MapList SEMTaskItemZL = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wherezl,"");
						for(int j=0;j<SEMTaskItemZL.size();j++)
						{ 
							Map SEMTaskItemZLmap =(Map)SEMTaskItemZL.get(j);
							String SEMTaskItemZLId = (String) SEMTaskItemZLmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemZLObj=new DomainObject(SEMTaskItemZLId);
						}
						HashMap currentObjMap=new HashMap();
						HashMap SEMTaskItemCSObjMap=new HashMap();
						HashMap SEMTaskItemSJObjMap=new HashMap();
						HashMap SEMTaskItemDFObjMap=new HashMap();
						HashMap SEMTaskItemDPObjMap=new HashMap();
						HashMap SEMTaskItemYSObjMap=new HashMap();
						HashMap SEMTaskItemBPObjMap=new HashMap();
						HashMap SEMTaskItemCRObjMap=new HashMap();
						HashMap SEMTaskItemZLObjMap=new HashMap();
						
					 	for(int h=2;h<=hcells;h++)
					 	{
					
							 String hcellValue="";
							 try{		    					  
		    					hcellValue = colValue[h];
		    					if(hcellValue ==null || hcellValue==""){
		    						continue;
		    					} 		    				
							  }catch(Exception ex){
								   hcellValue="";
							  }finally{
								   hcellValue = hcellValue.trim();
							  }				
				
						switch(h)
						{
							case 2:
							{
								//ContextUtil.pushContext(context);
								currentObjMap.put("SEM Part Revision" ,hcellValue);						
								//ContextUtil.popContext(context);		
								break;
							} 
					
							case 3:
							{
								//ContextUtil.pushContext(context);				
								currentObj.setDescription(context,hcellValue);							
								//ContextUtil.popContext(context);	
								break;									
							} 
				
							case 4:
							{
								//ContextUtil.pushContext(context);
								currentObjMap.put("SEM Is NewPart" ,hcellValue);									
								//ContextUtil.popContext(context);		
								break;										
							} 
		
							
							case 5:
							{
								//ContextUtil.pushContext(context);
								currentObjMap.put("SEM Need AdvPcue" ,hcellValue);										
								//ContextUtil.popContext(context);	
								break;										
							} 						
	
							case 6:
							{
								//ContextUtil.pushContext(context);
								hcellValue = changeDate(hcellValue);
								SEMTaskItemCSObjMap.put("Task Estimated Finish Date" ,hcellValue);				
								//ContextUtil.popContext(context);	
								break;		
							}
							case 7:
							{
								//ContextUtil.pushContext(context);
								hcellValue = changeDate(hcellValue);		
								SEMTaskItemCSObjMap.put("Task Actual Finish Date",hcellValue);													
								//ContextUtil.popContext(context);
								break;		
							}
							
							case 8:
							{
								//ContextUtil.pushContext(context);				
								SEMTaskItemCSObjMap.put("SEM Remark",hcellValue);							
								//ContextUtil.popContext(context);
								break;		
							}

														
							case 9:
							{
									//ContextUtil.pushContext(context);									
									SEMTaskItemSJObjMap.put("SEM Need DevConcept",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
																																				
							}																
							case 10:
							{					
									//ContextUtil.pushContext(context);											
									SEMTaskItemSJObjMap.put("SEM DevConcept NO",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
							}
							
							case 11:
							{
									//ContextUtil.pushContext(context);	
									hcellValue = changeDate(hcellValue);				
									SEMTaskItemSJObjMap.put("Task Estimated Finish Date",hcellValue);																		
									//ContextUtil.popContext(context);
									break;		
							}
							case 12:
							{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);	
									SEMTaskItemSJObjMap.put("Task Actual Finish Date",hcellValue);																				
									//ContextUtil.popContext(context);
									break;		
							}

								case 13:
								{
									//ContextUtil.pushContext(context);	
									hcellValue = changeDate(hcellValue);		
									SEMTaskItemDFObjMap.put("Task Estimated Finish Date",hcellValue);																			
									//ContextUtil.popContext(context);
									break;		
								}
								case 14:
								{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);
									SEMTaskItemDFObjMap.put("Task Actual Finish Date",hcellValue);						
									//ContextUtil.popContext(context);
									break;		
								}
								
								case 15:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemDFObjMap.put("SEM Issue EO",hcellValue);																	
									//ContextUtil.popContext(context);
									break;		
								}

								case 16:
								{
									//ContextUtil.pushContext(context);			
									hcellValue = changeDate(hcellValue);	
									SEMTaskItemDPObjMap.put("SEM Issue EO",hcellValue);																		
									//ContextUtil.popContext(context);
									break;		
								}
								case 17:
								{
									//ContextUtil.pushContext(context);
									hcellValue = changeDate(hcellValue);
									SEMTaskItemDPObjMap.put("Task Actual Finish Date",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
								}
								case 18:
								{
									//ContextUtil.pushContext(context);		
									SEMTaskItemDPObjMap.put("SEM Issue EO",hcellValue);																	
									//ContextUtil.popContext(context);
									break;		
								}

								case 19:
								{
									//ContextUtil.pushContext(context);		
									SEMTaskItemYSObjMap.put("SEM Drawing NO",hcellValue);																			
									//ContextUtil.popContext(context);
									break;		
								}
								case 20:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemYSObjMap.put("SEM Drawing Revision",hcellValue);											
									//ContextUtil.popContext(context);
									break;		
								}
								case 21:
								{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);
									SEMTaskItemYSObjMap.put("Task Estimated Finish Date",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
								}
								case 22:
								{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);
									SEMTaskItemYSObjMap.put("Task Actual Finish Date",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
								}
								case 23:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemYSObjMap.put("SEM Issue EO",hcellValue);																				
									//ContextUtil.popContext(context);
									break;		
								}

								case 24:
								{
									//ContextUtil.pushContext(context);		
									SEMTaskItemBPObjMap.put("SEM Drawing NO",hcellValue);																			
									//ContextUtil.popContext(context);
									break;		
								}
								case 25:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemBPObjMap.put("SEM Drawing Revision",hcellValue);								
									//ContextUtil.popContext(context);
									break;		
								}
								case 26:
								{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);
									SEMTaskItemBPObjMap.put("Task Estimated Finish Date",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
								}
								case 27:
								{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);
									SEMTaskItemBPObjMap.put("Task Actual Finish Date",hcellValue);						
									//ContextUtil.popContext(context);
									break;		
								}
								case 28:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemBPObjMap.put("SEM Issue EO",hcellValue);															
									//ContextUtil.popContext(context);
									break;		
								}

								case 29:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemZLObjMap.put("SEM Drawing NO",hcellValue);																		
									//ContextUtil.popContext(context);
									break;		
								}
								case 30:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemZLObjMap.put("SEM Drawing Revision",hcellValue);									
									//ContextUtil.popContext(context);
									break;		
								}
								case 31:
								{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);
									SEMTaskItemZLObjMap.put("Task Estimated Finish Date",hcellValue);											
									//ContextUtil.popContext(context);
									break;		
								}
								case 32:
								{
									//ContextUtil.pushContext(context);	
									hcellValue = changeDate(hcellValue);
									SEMTaskItemZLObjMap.put("Task Actual Finish Date",hcellValue);									
									//ContextUtil.popContext(context);
									break;		
								}
								case 33:
								{
									//ContextUtil.pushContext(context);
									SEMTaskItemZLObjMap.put("SEM Issue EO",hcellValue);																	
									//ContextUtil.popContext(context);
									break;		
								}

								case 34:
								{
									//ContextUtil.pushContext(context);			
									hcellValue = changeDate(hcellValue);
									SEMTaskItemCRObjMap.put("Task Estimated Finish Date",hcellValue);											
									//ContextUtil.popContext(context);
									break;		
								}
								case 35:
								{
									//ContextUtil.pushContext(context);	
									hcellValue = changeDate(hcellValue);
									SEMTaskItemCRObjMap.put("Task Actual Finish Date",hcellValue);								
									//ContextUtil.popContext(context);
									break;		
								}
								case 36:
								{
									//ContextUtil.pushContext(context);
									SEMTaskItemCRObjMap.put("SEM Issue EO",hcellValue);																			
									//ContextUtil.popContext(context);
									break;		
								}
								case 37:
								{
									//ContextUtil.pushContext(context);											
									currentObjMap.put("SEM Supplier",hcellValue);
									//ContextUtil.popContext(context);
									break;		
								}
								case 38:
								{
									//ContextUtil.pushContext(context);											
									currentObjMap.put("SEM Dep",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
								}
								case 39:
								{
									//ContextUtil.pushContext(context);													
									currentObjMap.put("SEM Institute Owner",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
								}
								case 40:
								{
									//ContextUtil.pushContext(context);										
									currentObjMap.put("SEM Dev Owner",hcellValue);											
									//ContextUtil.popContext(context);
									break;		
								}
								case 41:
								{
									//ContextUtil.pushContext(context);											
									currentObjMap.put("SEM Remark",hcellValue);									
									//ContextUtil.popContext(context);
									break;		
								}							
					 	 }							 
					}	
					currentObj.setAttributeValues(context,currentObjMap);
					SEMTaskItemCSObj.setAttributeValues(context,SEMTaskItemCSObjMap);
					SEMTaskItemSJObj.setAttributeValues(context,SEMTaskItemSJObjMap);
					SEMTaskItemDFObj.setAttributeValues(context,SEMTaskItemDFObjMap);
					SEMTaskItemDPObj.setAttributeValues(context,SEMTaskItemDPObjMap);
					SEMTaskItemYSObj.setAttributeValues(context,SEMTaskItemYSObjMap);
					SEMTaskItemBPObj.setAttributeValues(context,SEMTaskItemBPObjMap);
					SEMTaskItemCRObj.setAttributeValues(context,SEMTaskItemCRObjMap);
					SEMTaskItemZLObj.setAttributeValues(context,SEMTaskItemZLObjMap);

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
					 
					 for(int z=4;z<hrows;z++)
					 {  
						//System.out.println(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date()));
						//	System.out.println("z==================="+z);
						hrow = hsheet.getRow(z);
						String[] colValue=new String[hcells];
						for(int m=0;m<hcells;m++)
						{	
							hcell = hrow.getCell(m);
							colValue[m]=getExcelCellValue(hcell);
						}
						
						String currentName = colValue[1];	
						if(currentName.trim().equals(""))
						{
							continue;
						}
						
						String strLevel=colValue[0];
						int nLevel=0;
						String strCurRel="SEM SubPart";
						if(strLevel.equals(""))
						{
							nLevel=1;
							strCurRel="SEM Project PartTask";
						}else if(strLevel.equals("0"))
						{
							nLevel=2;
						}else if(strLevel.equals("1"))
						{
							nLevel=3;
						}else
						{
							continue;
						}
						if(nLevel - nParentLevel > 1)
						{
							nParentLevel = nLevel - 1;
							stack.push(currParentId);
							currParentId = prevId;
						}
						else if(nLevel - nParentLevel == 1)
						{
							
						}
						else
						{
							for(int m = nLevel - nParentLevel; m < 1; m ++)
							{
								currParentId = (String)stack.pop();
							}
							nParentLevel = nLevel - 1;
						}
						currParentObj=new DomainObject(currParentId);					
						String where = "name=='"+currentName+"'";
						MapList TempList=DomainObject.findObjects(context, "SEM Part Task", currentName, "-", "*", vault, null, true, busList);
						
						if(TempList!=null&&TempList.size()>0)
						{
							for(int k=0;k<TempList.size();k++)
							{
								HashMap TempMap=(HashMap)TempList.get(k);
								String TempId=(String)TempMap.get("id");
								currentId = TempId;
								currentObj = new DomainObject(currentId);
								String wherePart="id=='"+TempId+"'";
								MapList partTaskList = currParentObj.getRelatedObjects(context,strCurRel,"SEM Part Task", busList, relList,false,true, (short)1,wherePart,"");	
								if(partTaskList!=null&&partTaskList.size()>0)
								{
									for(int j=0;j<partTaskList.size();j++)
									{
										 Map partTaskMap = (Map) partTaskList.get(j);
									}
								}else
								{								 						 							
									 currParentObj.connectTo(context,strCurRel,currentObj);
								}
							}
						}else
						{
							currentObj.createObject(context,"SEM Part Task",currentName , "-", "SEM Part Task",vault);
							currentId = currentObj.getInfo(context,"id");
							currParentObj.connectTo(context,strCurRel,currentObj);
						}
						prevId = currentId;	

						//add by ryan 2017-10-30
						String strObjOwner = currentObj.getInfo(context, "owner");
						if(!strObjOwner.equals(strCurrLoginUser))
						{
							continue;
						}
						//add end
						      
					//	System.out.println(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date()));
					//	System.out.println("prevId================"+prevId);	
						
						String wherecs = "name == '\u5382\u5546\u5B9A\u70B9'";
						MapList SEMTaskItemCS = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wherecs,"");							
						for(int j=0;j<SEMTaskItemCS.size();j++)
						{ 
							Map SEMTaskItemCSmap =(Map)SEMTaskItemCS.get(j);
							String SEMTaskItemCSId = (String) SEMTaskItemCSmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemCSObj=new DomainObject(SEMTaskItemCSId);
						}
						String wheresj = "name == '\u8BBE\u8BA1\u6784\u60F3\u4E66'";
						MapList SEMTaskItemSJ = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wheresj,"");
						for(int j=0;j<SEMTaskItemSJ.size();j++)
						{ 
							Map SEMTaskItemSJmap =(Map)SEMTaskItemSJ.get(j);
							String SEMTaskItemSJId = (String) SEMTaskItemSJmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemSJObj=new DomainObject(SEMTaskItemSJId);
						}
						String wheredf = "name == '3D-F'";
						MapList SEMTaskItemDF = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wheredf,"");
						for(int j=0;j<SEMTaskItemDF.size();j++)
						{ 
							Map SEMTaskItemDFmap =(Map)SEMTaskItemDF.get(j);
							String SEMTaskItemDFId = (String) SEMTaskItemDFmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemDFObj=new DomainObject(SEMTaskItemDFId);
						}
				
						String wheredp = "name == '3D-P'";
						MapList SEMTaskItemDP = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wheredp,"");
						for(int j=0;j<SEMTaskItemDP.size();j++)
						{ 
							Map SEMTaskItemDPmap =(Map)SEMTaskItemDP.get(j);
							String SEMTaskItemDPId = (String) SEMTaskItemDPmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemDPObj=new DomainObject(SEMTaskItemDPId);
						}
						String whereys = "name == '\u8BBE\u8BA1\u4ED5\u6837\u56FE'";
						MapList SEMTaskItemYS = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,whereys,"");
						for(int j=0;j<SEMTaskItemYS.size();j++)
						{ 
							Map SEMTaskItemYSmap =(Map)SEMTaskItemYS.get(j);
							String SEMTaskItemYSId = (String) SEMTaskItemYSmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemYSObj=new DomainObject(SEMTaskItemYSId);
						}
						String wherebp= "name == '\u90E8\u54C1\u56FE'";
						MapList SEMTaskItemBP = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wherebp,"");
						for(int j=0;j<SEMTaskItemBP.size();j++)
						{ 
							Map SEMTaskItemBPmap =(Map)SEMTaskItemBP.get(j);
							String SEMTaskItemBPId = (String) SEMTaskItemBPmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemBPObj=new DomainObject(SEMTaskItemBPId);
						}
					   String wherecr= "name == '\u627F\u8BA4\u56FE'";
						MapList SEMTaskItemCR= currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wherecr,"");
						for(int j=0;j<SEMTaskItemCR.size();j++)
						{ 
							Map SEMTaskItemCRmap =(Map)SEMTaskItemCR.get(j);
							String SEMTaskItemCRId = (String) SEMTaskItemCRmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemCRObj=new DomainObject(SEMTaskItemCRId);
						}
						String wherezl= "name == '\u7EC4\u7ACB\u56FE'";
						MapList SEMTaskItemZL = currentObj.getRelatedObjects(context,"SEM Related DrwTask","SEM Task Item", busList, relList,false,true, (short)1,wherezl,"");
						for(int j=0;j<SEMTaskItemZL.size();j++)
						{ 
							Map SEMTaskItemZLmap =(Map)SEMTaskItemZL.get(j);
							String SEMTaskItemZLId = (String) SEMTaskItemZLmap.get(DomainConstants.SELECT_ID);
							SEMTaskItemZLObj=new DomainObject(SEMTaskItemZLId);
						}
						HashMap currentObjMap=new HashMap();
						HashMap SEMTaskItemCSObjMap=new HashMap();
						HashMap SEMTaskItemSJObjMap=new HashMap();
						HashMap SEMTaskItemDFObjMap=new HashMap();
						HashMap SEMTaskItemDPObjMap=new HashMap();
						HashMap SEMTaskItemYSObjMap=new HashMap();
						HashMap SEMTaskItemBPObjMap=new HashMap();
						HashMap SEMTaskItemCRObjMap=new HashMap();
						HashMap SEMTaskItemZLObjMap=new HashMap();
						
					 	for(int h=2;h<=hcells;h++)
					 	{
					
							 String hcellValue="";
							 try{		    					  
		    					hcellValue = colValue[h];
		    					if(hcellValue ==null || hcellValue==""){
		    						continue;
		    					} 		    				
							  }catch(Exception ex){
								   hcellValue="";
							  }finally{
								   hcellValue = hcellValue.trim();
							  }				
				
						switch(h)
						{
							case 2:
							{
								//ContextUtil.pushContext(context);
								currentObjMap.put("SEM Part Revision" ,hcellValue);						
								//ContextUtil.popContext(context);		
								break;
							} 
					
							case 3:
							{
								//ContextUtil.pushContext(context);			
								currentObj.setDescription(context,hcellValue);							
								//ContextUtil.popContext(context);	
								break;									
							} 
				
							case 4:
							{
								//ContextUtil.pushContext(context);
								currentObjMap.put("SEM Is NewPart" ,hcellValue);										
								//ContextUtil.popContext(context);		
								break;										
							} 
		
							
							case 5:
							{
								//ContextUtil.pushContext(context);
								currentObjMap.put("SEM Need AdvPcue" ,hcellValue);									
								//ContextUtil.popContext(context);	
								break;										
							} 						
	
							case 6:
							{
								//ContextUtil.pushContext(context);
								hcellValue = changeDate(hcellValue);
								SEMTaskItemCSObjMap.put("Task Estimated Finish Date" ,hcellValue);				
								//ContextUtil.popContext(context);	
								break;		
							}
							case 7:
							{
								//ContextUtil.pushContext(context);
								hcellValue = changeDate(hcellValue);		
								SEMTaskItemCSObjMap.put("Task Actual Finish Date",hcellValue);												
								//ContextUtil.popContext(context);
								break;		
							}
							
							case 8:
							{
								//ContextUtil.pushContext(context);				
								SEMTaskItemCSObjMap.put("SEM Remark",hcellValue);								
								//ContextUtil.popContext(context);
								break;		
							}

														
							case 9:
							{
									//ContextUtil.pushContext(context);											
									SEMTaskItemSJObjMap.put("SEM Need DevConcept",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
																																				
							}																
							case 10:
							{					
									//ContextUtil.pushContext(context);											
									SEMTaskItemSJObjMap.put("SEM DevConcept NO",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
							}
							
							case 11:
							{
									//ContextUtil.pushContext(context);	
									hcellValue = changeDate(hcellValue);				
									SEMTaskItemSJObjMap.put("Task Estimated Finish Date",hcellValue);																		
									//ContextUtil.popContext(context);
									break;		
							}
							case 12:
							{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);	
									SEMTaskItemSJObjMap.put("Task Actual Finish Date",hcellValue);																				
									//ContextUtil.popContext(context);
									break;		
							}

								case 13:
								{
									//ContextUtil.pushContext(context);	
									hcellValue = changeDate(hcellValue);		
									SEMTaskItemDFObjMap.put("Task Estimated Finish Date",hcellValue);																			
									//ContextUtil.popContext(context);
									break;		
								}
								case 14:
								{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);
									SEMTaskItemDFObjMap.put("Task Actual Finish Date",hcellValue);							
									//ContextUtil.popContext(context);
									break;		
								}
								
								case 15:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemDFObjMap.put("SEM Issue EO",hcellValue);																	
									//ContextUtil.popContext(context);
									break;		
								}

								case 16:
								{
									//ContextUtil.pushContext(context);			
									hcellValue = changeDate(hcellValue);	
									SEMTaskItemDPObjMap.put("SEM Issue EO",hcellValue);																		
									//ContextUtil.popContext(context);
									break;		
								}
								case 17:
								{
									//ContextUtil.pushContext(context);
									hcellValue = changeDate(hcellValue);
									SEMTaskItemDPObjMap.put("Task Actual Finish Date",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
								}
								case 18:
								{
									//ContextUtil.pushContext(context);		
									SEMTaskItemDPObjMap.put("SEM Issue EO",hcellValue);																	
									//ContextUtil.popContext(context);
									break;		
								}

								case 19:
								{
									//ContextUtil.pushContext(context);		
									SEMTaskItemYSObjMap.put("SEM Drawing NO",hcellValue);																			
									//ContextUtil.popContext(context);
									break;		
								}
								case 20:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemYSObjMap.put("SEM Drawing Revision",hcellValue);											
									//ContextUtil.popContext(context);
									break;		
								}
								case 21:
								{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);
									SEMTaskItemYSObjMap.put("Task Estimated Finish Date",hcellValue);											
									//ContextUtil.popContext(context);
									break;		
								}
								case 22:
								{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);
									SEMTaskItemYSObjMap.put("Task Actual Finish Date",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
								}
								case 23:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemYSObjMap.put("SEM Issue EO",hcellValue);																				
									//ContextUtil.popContext(context);
									break;		
								}

								case 24:
								{
									//ContextUtil.pushContext(context);		
									SEMTaskItemBPObjMap.put("SEM Drawing NO",hcellValue);																			
									//ContextUtil.popContext(context);
									break;		
								}
								case 25:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemBPObjMap.put("SEM Drawing Revision",hcellValue);								
									//ContextUtil.popContext(context);
									break;		
								}
								case 26:
								{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);
									SEMTaskItemBPObjMap.put("Task Estimated Finish Date",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
								}
								case 27:
								{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);
									SEMTaskItemBPObjMap.put("Task Actual Finish Date",hcellValue);						
									//ContextUtil.popContext(context);
									break;		
								}
								case 28:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemBPObjMap.put("SEM Issue EO",hcellValue);															
									//ContextUtil.popContext(context);
									break;		
								}

								case 29:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemZLObjMap.put("SEM Drawing NO",hcellValue);																			
									//ContextUtil.popContext(context);
									break;		
								}
								case 30:
								{
									//ContextUtil.pushContext(context);	
									SEMTaskItemZLObjMap.put("SEM Drawing Revision",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
								}
								case 31:
								{
									//ContextUtil.pushContext(context);		
									hcellValue = changeDate(hcellValue);
									SEMTaskItemZLObjMap.put("Task Estimated Finish Date",hcellValue);												
									//ContextUtil.popContext(context);
									break;		
								}
								case 32:
								{
									//ContextUtil.pushContext(context);	
									hcellValue = changeDate(hcellValue);
									SEMTaskItemZLObjMap.put("Task Actual Finish Date",hcellValue);									
									//ContextUtil.popContext(context);
									break;		
								}
								case 33:
								{
									//ContextUtil.pushContext(context);
									SEMTaskItemZLObjMap.put("SEM Issue EO",hcellValue);																		
									//ContextUtil.popContext(context);
									break;		
								}

								case 34:
								{
									//ContextUtil.pushContext(context);			
									hcellValue = changeDate(hcellValue);
									SEMTaskItemCRObjMap.put("Task Estimated Finish Date",hcellValue);											
									//ContextUtil.popContext(context);
									break;		
								}
								case 35:
								{
									//ContextUtil.pushContext(context);	
									hcellValue = changeDate(hcellValue);
									SEMTaskItemCRObjMap.put("Task Actual Finish Date",hcellValue);								
									//ContextUtil.popContext(context);
									break;		
								}
								case 36:
								{
									//ContextUtil.pushContext(context);
									SEMTaskItemCRObjMap.put("SEM Issue EO",hcellValue);																		
									//ContextUtil.popContext(context);
									break;		
								}
								case 37:
								{
									//ContextUtil.pushContext(context);												
									currentObjMap.put("SEM Supplier",hcellValue);
									//ContextUtil.popContext(context);
									break;		
								}
								case 38:
								{
									//ContextUtil.pushContext(context);												
									currentObjMap.put("SEM Dep",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
								}
								case 39:
								{
									//ContextUtil.pushContext(context);													
									currentObjMap.put("SEM Institute Owner",hcellValue);										
									//ContextUtil.popContext(context);
									break;		
								}
								case 40:
								{
									//ContextUtil.pushContext(context);											
									currentObjMap.put("SEM Dev Owner",hcellValue);											
									//ContextUtil.popContext(context);
									break;		
								}
								case 41:
								{
									//ContextUtil.pushContext(context);								
									currentObjMap.put("SEM Remark",hcellValue);									
									//ContextUtil.popContext(context);
									break;		
								}		
					 	 }	
					}	
					currentObj.setAttributeValues(context,currentObjMap);
					SEMTaskItemCSObj.setAttributeValues(context,SEMTaskItemCSObjMap);
					SEMTaskItemSJObj.setAttributeValues(context,SEMTaskItemSJObjMap);
					SEMTaskItemDFObj.setAttributeValues(context,SEMTaskItemDFObjMap);
					SEMTaskItemDPObj.setAttributeValues(context,SEMTaskItemDPObjMap);
					SEMTaskItemYSObj.setAttributeValues(context,SEMTaskItemYSObjMap);
					SEMTaskItemBPObj.setAttributeValues(context,SEMTaskItemBPObjMap);
					SEMTaskItemCRObj.setAttributeValues(context,SEMTaskItemCRObjMap);
					SEMTaskItemZLObj.setAttributeValues(context,SEMTaskItemZLObjMap);
					}				
				}
	 		 }
		 }
		 System.out.println(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date()));
		 ContextUtil.commitTransaction(context);
		 System.out.println("end="+new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date()));
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
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
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
	SimpleDateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd");
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
	SimpleDateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd");
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