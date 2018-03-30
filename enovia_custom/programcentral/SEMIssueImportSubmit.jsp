
<%@page import="java.util.regex.Pattern"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.common.Person"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
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
  String issueType="";
  StringList orang=mxAttr.getChoices(context,"SEM Issue Type1");
  StringList fyorang=i18nNow.getAttrRangeI18NStringList("SEM Issue Type1",orang,strLanguage);
  for (int i = 0; i <orang.size(); i++)
  {
        if(orang.get(i).equals(flag)){
	        issueType=(String)fyorang.get(i);
        }
  }
  DomainObject projectObj = new DomainObject(projectId);
  
  Person currentPerson=Person.getPerson(context);
  String currentUser =currentPerson.getAttributeValue(context,"Last Name");
   
  
  StringList busList = new StringList("id");
  busList.add("name");
  busList.add("id");
  busList.add("revision");
  busList.add("attribute[Last Name]");
  StringList relList = new StringList(DomainRelationship.SELECT_ID);
  String exceptionStr = "";
  boolean flagbool=false;
  int[] pos=new int[40];
  
  int[] cj=new int[]{1,2,3,4,5,6,9,10,11,15,16,17,18,19,20,21,100,22,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100};
  int[] sd=new int[]{1,20,100,100,100,2,10,4,5,100,11,100,100,100,100,100,6,9,13,14,15,16,19,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100};
  int[] seg=new int[]{1,28,100,100,100,7,2,8,9,16,17,100,100,100,100,100,10,13,18,24,25,26,5,4,6,19,22,23,100,100,100,100,100,100,100,100,100,100,100};
  int[] cs=new int[]{1,15,100,29,14,5,23,32,20,22,24,9,100,2,100,100,19,17,100,100,31,4,16,100,100,100,100,100,3,10,11,12,13,30,100,100,100,100,100};
  int[] pj=new int[]{1,6,25,21,19,8,15,12,13,100,100,4,23,2,22,24,100,16,100,100,20,100,100,100,100,100,100,100,100,5,100,100,100,3,7,100,100,100,100};
  int[] cy=new int[]{1,8,29,32,6,3,15,17,18,26,16,31,30,2,28,100,100,9,37,10,22,23,7,100,100,100,33,100,100,100,100,100,100,100,100,4,5,34,100};
  int[] hz=new int[]{1,24,100,100,100,7,14,20,19,16,17,4,100,2,100,100,100,15,100,100,100,100,100,100,5,100,100,100,100,100,100,100,100,100,100,3,100,100,100};
  int[] tz=new int[]{1,3,100,25,6,8,17,32,11,18,100,4,21,2,22,100,12,19,20,26,28,7,31,100,5,100,100,100,100,100,100,100,100,100,100,100,100,100,23};
  int[] zz=new int[]{1,3,21,28,24,5,18,39,12,19,20,31,32,2,25,29,11,10,33,22,23,36,35,100,30,100,100,27,100,100,100,100,100,100,100,4,100,100,100};
  int hfqx=0;
  if(flag.equals("Vehicle Check Issue")){
	  pos=Arrays.copyOf(cj,cj.length);
	   hfqx=22;
  }else if(flag.equals("Market Survey Issue")||flag.equals("Test Drive Issue")||flag.equals("Case Issue")||flag.equals("Budget Issue")){
	  pos=Arrays.copyOf(sd,sd.length);
	   hfqx=9;
  }else if(flag.equals("SEG Model Issue")||flag.equals("SEG Engineer Issue")||flag.equals("Structure Analyse Issue")){
	  pos=Arrays.copyOf(seg,seg.length);
	   hfqx=13;
  }else if(flag.equals("Vehicle Test Issue")||flag.equals("Performance Test Issue")){
	  pos=Arrays.copyOf(cs,cs.length);
	  hfqx=17;
  }else if(flag.equals("Assess Issue")){
	   pos=Arrays.copyOf(pj,pj.length);
	   hfqx=16;
  }else if(flag.equals("Try Stamping Issue")){
	   pos=Arrays.copyOf(cy,cy.length);
	    hfqx=9;
  }else if(flag.equals("Try Welding Issue")){
		 pos=Arrays.copyOf(hz,hz.length);
		  hfqx=15;
  }else if(flag.equals("Try Coating Issue")){
		 pos=Arrays.copyOf(tz,tz.length);
		 hfqx=19;
  }else if(flag.equals("Try Assembly Issue")){
		 pos=Arrays.copyOf(zz,zz.length);
		 hfqx=10;
  }			
  
  ContextUtil.startTransaction(context, true);
  if(ServletFileUpload.isMultipartContent(request))
  {
	  	  try{
			  
	  DiskFileItemFactory factory =  new DiskFileItemFactory();
	  factory.setSizeThreshold(1024*1000);    //  指定在内存中缓存数据大小,单位为byte
	  //factory.setRepository(new File("C:/tempload"));            
	  ServletFileUpload fileUpload=new ServletFileUpload(factory);            
	  fileUpload.setFileSizeMax(20*1024*1024);//设置最大文件大小

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
				System.out.println("testsub123---"+excelContentType);
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
							  
							  if(h==0&&hcellValue.length()>0)
							  {
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
							 	
						 if(h==pos[8]&& hcellValue.length()>0)
						 {
							StringList LastNameList=new StringList();
							MapList personlist=projectObj.getRelatedObjects(context,"Member","Person", busList, relList,false,true, (short)1,"","");	
							for(int k=0;k<personlist.size();k++)
							{
								Map personmap=(Map)personlist.get(k);
								String personId=(String)personmap.get("id");
								DomainObject personObj=new DomainObject(personId);	
								String lastName=personObj.getAttributeValue(context,"Last Name");
								LastNameList.add(lastName);
							
							} 
							if(!LastNameList.contains(hcellValue))
							{
									%>
									 <script type="text/javascript">
										alert("\u5BF9\u7B56\u4EBA\u4E0D\u5B58\u5728");
										top.window.close();
										</script>
									<%
									flagbool=true;	
									break;
							}
						 }	
						 if(h==hfqx&&hcellValue.length()==0){
								 %>
								  <script type="text/javascript">
									alert("\u56DE\u590D\u671F\u9650\u4E0D\u80FD\u4E3A\u7A7A!");
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
					
					 for(int z=1;z<hrows;z++)
					 {  
				        hrow = hsheet.getRow(z);
						hcell = hrow.getCell(pos[7]);
						String owner=getExcelCellValue(hcell);
						if((!owner.equals(""))&&(!owner.equals(currentUser))){
							continue;
						}
				        if(flagbool==true)
						{
							flagbool=false;
							break;
						}
							
						String[] colValue=new String[hcells];				
					 	for(int h=0;h<hcells;h++)
					 	{
							 hcell = hrow.getCell(h);
							 colValue[h]=getExcelCellValue(hcell);
						}
					
								if(	colValue[0].length()!=0)
								{
								String strIssueName = colValue[0];		
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
								 
								else
								{
									String pre="";
										String SITCode="";
									try{
									    ////ContextUtil.pushContext(context);
									String SEMCarCode=projectObj.getAttributeValue(context,"SEM Car Code");
									
									if(SEMCarCode.length()>=5)
									{
										pre=SEMCarCode.substring(0,5)+"-";
										
									}
									//String issueType=colValue[pos[2]];
						
									String whereSITCode="attribute[LS Index Key1]=='SEM Issue Type'&&attribute[LS Attribute1]=='"+issueType+"'";									
									MapList mapList=new MapList();
									
							    		
									 mapList=DomainObject.findObjects(context,"LS Property Key","*",whereSITCode,busList);
								
									    if(mapList.size()>0)
										{
											Map map =(Map) mapList.get(0);
											String id = (String)map.get("id");
											DomainObject rtObj=new DomainObject(id);
											SITCode=rtObj.getAttributeValue(context,"LS Attribute2");
									
										}
									}finally
									{
										   //ContextUtil.popContext(context);
									}	
									
									String strName = "";
									String strType = "Issue";
									String strPolicy="Issue";
									String  realName="";
									if(strName == null || strName =="" )
									{
										strName= FrameworkUtil.autoName(context,"type_Issue",null,"type_Issue",null,null,true,true);
										realName=pre+SITCode+"-"+strName;		
									}
									try{
									    //ContextUtil.pushContext(context);
									DomainObject dom=new DomainObject();
									dom.createObject(context, strType,realName , "-", strPolicy, "eService Production");
									String ojectId =dom.getInfo(context, "id");
									IssueObj = new DomainObject(ojectId);
									IssueObj.connectFrom(context,"Issue",projectObj);
									}	finally
									{
										   //ContextUtil.popContext(context);
									}	
								}
								//System.out.println("222222222222222222");
					    for(int h=1;h<=hcells;h++)
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
                            if(colValue[0].length()==0){
							  IssueObj.setAttributeValue(context,"SEM Issue Type",issueType);	
							}							  
                            if(h==pos[0]&& hcellValue.length()>0)
							{
								String currentState=IssueObj.getCurrentState(context).getName();
								currentState=i18nNow.getStateI18NString("Issue",currentState,strLanguage);
								if(!currentState.equals(hcellValue)){
								  Policy mxPolicy = new Policy("Issue");
                                  Iterator stateItr = mxPolicy.getStateRequirements(context).iterator();
                                  while (stateItr.hasNext()) {
                                  StateRequirement stateReq = (StateRequirement) stateItr.next();
                                  String stateName = stateReq.getName();
                                  String zwState=i18nNow.getStateI18NString("Issue",stateName,strLanguage);
								  if(zwState.equals(hcellValue)){
									  //MqlUtil.mqlCommand(context, "trigger off");
									  IssueObj.setState(context,stateName);
									  //MqlUtil.mqlCommand(context, "trigger on");
									  break;
								  }
							     }
								}
							}else if(h==pos[1]){
                                if(hcellValue.length()>0){  
                                   IssueObj.setAttributeValue(context,"SEM Issue HappenDate",changeDate(hcellValue));								
                                }else{
                                   java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
        	                       java.util.Date  currentDate = new java.util.Date();
    		                       String newValue=formatter.format(currentDate);
								   IssueObj.setAttributeValue(context,"SEM Issue HappenDate",newValue);	
                                 }
							}else if(h==pos[2]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue Class",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[3]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Production Related Issue",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[4]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue Major",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[5]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								System.out.println("hcellValueDes====="+hcellValue);
								IssueObj.setDescription(context, hcellValue);							
								//ContextUtil.popContext(context);								
							}else if(h==pos[6]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue SolutionProgress",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[8]&& hcellValue.length()>0){
								String pId="",relId="";
								ContextUtil.pushContext(context); 
								String where="attribute[Last Name]=='"+hcellValue+"'";
								MapList personlist=projectObj.getRelatedObjects(context,"Member","Person", busList, relList,false,true, (short)1,where,"");
								MapList mapList=IssueObj.getRelatedObjects(context,"Assigned Issue","Person", busList, relList,true,false, (short)1, null, null);
   				                Iterator items1=mapList.iterator();
   			                    while(items1.hasNext()){
   				                   Map map=(Map)items1.next();
								   pId=(String)map.get("id");
   				                   relId=(String)map.get("id[connection]");
   	                            }
								if(personlist.size()>0){
									Map personmap=(Map)personlist.get(0);
									String personId=(String)personmap.get("id");
									if(!personId.equals(pId)){
										if(!relId.equals("")){
										   DomainRelationship.disconnect(context,relId);
										}
										DomainObject personObj=new DomainObject(personId);
										IssueObj.connectFrom(context,"Assigned Issue",personObj);
									}
								}		
								ContextUtil.popContext(context);
							}else if(h==pos[9]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue SolutionResult",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[10]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"ResolutionStatement",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[11]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue TestCarCode",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[12]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM IssueCar Number",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[13]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue Phase",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[14]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue Repeat",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[15]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue PartType",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[16]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM IssueSolution Dealer Department",hcellValue);
							}else if(h==pos[17]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"Estimated End Date",changeDate(hcellValue));
							}else if(h==pos[18]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Remark",hcellValue);
							}else if(h==pos[19]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"Priority",hcellValue);
							}else if(h==pos[20]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM IssueImportance ID",hcellValue);
							}else if(h==pos[21]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue Type",hcellValue);
							}else if(h==pos[22]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue Submiter",hcellValue);
							}else if(h==pos[23]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM ModelData Phase Version",hcellValue);
							}else if(h==pos[24]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue Section",hcellValue);
							}else if(h==pos[25]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM DataRecieved Date",changeDate(hcellValue));
							}else if(h==pos[26]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM UPG Part",hcellValue);
							}else if(h==pos[27]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Part",hcellValue);
							}else if(h==pos[28]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Test Item",hcellValue);
							}else if(h==pos[29]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Body Code",hcellValue);
							}else if(h==pos[30]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Test Engine",hcellValue);
							}else if(h==pos[31]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Test Gearbox",hcellValue);
							}else if(h==pos[32]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Test Mileage",hcellValue);
							}else if(h==pos[33]&& hcellValue.length()>0){
								 StringList orang1=mxAttr.getChoices(context,"SEM IssueCar Property");
                                 StringList rang1=i18nNow.getAttrRangeI18NStringList("SEM IssueCar Property", orang1,strLanguage);
								 for(int k=0;k<rang1.size();k++){
									 String value=(String)rang1.get(k);
									 String newValue=(String)orang1.get(k);
									 if(value.equals(hcellValue)){
										 IssueObj.setAttributeValue(context,"SEM IssueCar Property",newValue);
										 break;
									 }
								 }
							}else if(h==pos[34]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM IssuePoints Deduction",hcellValue);
							}else if(h==pos[35]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue Line",hcellValue);
							}else if(h==pos[36]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Equipment Type",hcellValue);
							}else if(h==pos[37]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue Undertaker",hcellValue);
							}else if(h==pos[38]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM TestIssue Number",hcellValue);
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
		    					if(hcellValue ==null){
		    						continue;
		    					} 		    				
							  }catch(Exception ex){
								   hcellValue="";
							  }finally{
								   hcellValue = hcellValue.trim();
							  }	
							  
							  if(h==0&&hcellValue.length()>0)
							  {
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
						 if(h==pos[8]&& hcellValue.length()>0)
						 {
							StringList LastNameList=new StringList();
							MapList personlist=projectObj.getRelatedObjects(context,"Member","Person", busList, relList,false,true, (short)1,"","");	
							for(int k=0;k<personlist.size();k++)
							{
								Map personmap=(Map)personlist.get(k);
								String personId=(String)personmap.get("id");
								DomainObject personObj=new DomainObject(personId);	
								String lastName=personObj.getAttributeValue(context,"Last Name");
								LastNameList.add(lastName);
							
							} 
								if(!LastNameList.contains(hcellValue))
								{
									%>
									 <script type="text/javascript">
										alert("\u5BF9\u7B56\u4EBA\u4E0D\u5B58\u5728");
										top.window.close();
										</script>
									<%
									flagbool=true;
                                    break;										
								}	
						 }
                         if(h==hfqx&&hcellValue.length()==0){
								 %>
								  <script type="text/javascript">
									alert("\u56DE\u590D\u671F\u9650\u4E0D\u80FD\u4E3A\u7A7A!");
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
					  System.out.println("sub99999");
					 for(int z=1;z<hrows;z++)
					 {  
				        hrow = hsheet.getRow(z);
						hcell = hrow.getCell(pos[7]);
						String owner=getExcelCellValue(hcell);
						if((!owner.equals(""))&&(!owner.equals(currentUser))){
							continue;
						}
				        if(flagbool==true)
						{
							flagbool=false;
							break;
						}
							
						String[] colValue=new String[hcells];				
					 	for(int h=0;h<hcells;h++)
					 	{
							 hcell = hrow.getCell(h);
							 colValue[h]=getExcelCellValue(hcell);
						}
					
								if(	colValue[0].length()!=0)
								{
								String strIssueName = colValue[0];		
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
								 
								else
								{
									String pre="";
										String SITCode="";
									try{
									    ////ContextUtil.pushContext(context);
									String SEMCarCode=projectObj.getAttributeValue(context,"SEM Car Code");
									
									if(SEMCarCode.length()>=5)
									{
										pre=SEMCarCode.substring(0,5)+"-";
										
									}
									//String issueType=colValue[pos[2]];
						
									String whereSITCode="attribute[LS Index Key1]=='SEM Issue Type'&&attribute[LS Attribute1]=='"+issueType+"'";									
									MapList mapList=new MapList();
									
							    		
									 mapList=DomainObject.findObjects(context,"LS Property Key","*",whereSITCode,busList);
								
									    if(mapList.size()>0)
										{
											Map map =(Map) mapList.get(0);
											String id = (String)map.get("id");
											DomainObject rtObj=new DomainObject(id);
											SITCode=rtObj.getAttributeValue(context,"LS Attribute2");
									
										}
									}finally
									{
										   //ContextUtil.popContext(context);
									}	
									
									String strName = "";
									String strType = "Issue";
									String strPolicy="Issue";
									String  realName="";
									if(strName == null || strName =="" )
									{
										strName= FrameworkUtil.autoName(context,"type_Issue",null,"type_Issue",null,null,true,true);
										realName=pre+SITCode+"-"+strName;		
									}
									try{
									    //ContextUtil.pushContext(context);
									DomainObject dom=new DomainObject();
									dom.createObject(context, strType,realName , "-", strPolicy, "eService Production");
									String ojectId =dom.getInfo(context, "id");
									IssueObj = new DomainObject(ojectId);
									IssueObj.connectFrom(context,"Issue",projectObj);
									}	finally
									{
										   //ContextUtil.popContext(context);
									}	
								}
								//System.out.println("222222222222222222");
					    for(int h=1;h<=hcells;h++)
					 	{
							 String hcellValue="";
							 try{		    					  
		    					hcellValue = colValue[h];
		    					if(hcellValue==null){
		    						continue;
		    					} 		    				
							  }catch(Exception ex){
								   hcellValue="";
							  }finally{
								   hcellValue = hcellValue.trim();
							  }	
                            if(colValue[0].length()==0){
							  IssueObj.setAttributeValue(context,"SEM Issue Type",issueType);	
							}							  
                            if(h==pos[0]&& hcellValue.length()>0)
							{
								String currentState=IssueObj.getCurrentState(context).getName();
								currentState=i18nNow.getStateI18NString("Issue",currentState,strLanguage);
								if(!currentState.equals(hcellValue)){
								  Policy mxPolicy = new Policy("Issue");
                                  Iterator stateItr = mxPolicy.getStateRequirements(context).iterator();
                                  while (stateItr.hasNext()) {
                                  StateRequirement stateReq = (StateRequirement) stateItr.next();
                                  String stateName = stateReq.getName();
                                  String zwState=i18nNow.getStateI18NString("Issue",stateName,strLanguage);
								  if(zwState.equals(hcellValue)){
									  //MqlUtil.mqlCommand(context, "trigger off");
									  IssueObj.setState(context,stateName);
									  //MqlUtil.mqlCommand(context, "trigger on");
									  break;
								  }
							     }
								}
							}else if(h==pos[1]){
								if(hcellValue.length()>0){  
                                   IssueObj.setAttributeValue(context,"SEM Issue HappenDate",changeDate(hcellValue));								
                                }else{
                                   java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
        	                       java.util.Date  currentDate = new java.util.Date();
    		                       String newValue=formatter.format(currentDate);
								   IssueObj.setAttributeValue(context,"SEM Issue HappenDate",newValue);	
                                 }
							}else if(h==pos[2]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue Class",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[3]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Production Related Issue",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[4]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue Major",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[5]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setDescription(context, hcellValue);							
								//ContextUtil.popContext(context);								
							}else if(h==pos[6]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue SolutionProgress",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[8]&& hcellValue.length()>0){
								String pId="",relId="";
								ContextUtil.pushContext(context); 
								String where="attribute[Last Name]=='"+hcellValue+"'";
								MapList personlist=projectObj.getRelatedObjects(context,"Member","Person", busList, relList,false,true, (short)1,where,"");
								MapList mapList=IssueObj.getRelatedObjects(context,"Assigned Issue","Person", busList, relList,true,false, (short)1, null, null);
   				                Iterator items1=mapList.iterator();
   			                    while(items1.hasNext()){
   				                   Map map=(Map)items1.next();
								   pId=(String)map.get("id");
   				                   relId=(String)map.get("id[connection]");
   	                            }
								if(personlist.size()>0){
									Map personmap=(Map)personlist.get(0);
									String personId=(String)personmap.get("id");
									if(!personId.equals(pId)){
										if(!relId.equals("")){
										   DomainRelationship.disconnect(context,relId);
										}
										DomainObject personObj=new DomainObject(personId);
										IssueObj.connectFrom(context,"Assigned Issue",personObj);
									}
								}		
								ContextUtil.popContext(context);
							}else if(h==pos[9]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue SolutionResult",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[10]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"ResolutionStatement",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[11]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue TestCarCode",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[12]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM IssueCar Number",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[13]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue Phase",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[14]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue Repeat",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[15]&& hcellValue.length()>0){
								//ContextUtil.pushContext(context);
								IssueObj.setAttributeValue(context,"SEM Issue PartType",hcellValue);
								//ContextUtil.popContext(context);
							}else if(h==pos[16]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM IssueSolution Dealer Department",hcellValue);
							}else if(h==pos[17]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"Estimated End Date",changeDate(hcellValue));
							}else if(h==pos[18]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Remark",hcellValue);
							}else if(h==pos[19]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"Priority",hcellValue);
							}else if(h==pos[20]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM IssueImportance ID",hcellValue);
							}else if(h==pos[21]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue Type",hcellValue);
							}else if(h==pos[22]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue Submiter",hcellValue);
							}else if(h==pos[23]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM ModelData Phase Version",hcellValue);
							}else if(h==pos[24]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue Section",hcellValue);
							}else if(h==pos[25]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM DataRecieved Date",changeDate(hcellValue));
							}else if(h==pos[26]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM UPG Part",hcellValue);
							}else if(h==pos[27]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Part",hcellValue);
							}else if(h==pos[28]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Test Item",hcellValue);
							}else if(h==pos[29]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Body Code",hcellValue);
							}else if(h==pos[30]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Test Engine",hcellValue);
							}else if(h==pos[31]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Test Gearbox",hcellValue);
							}else if(h==pos[32]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Test Mileage",hcellValue);
							}else if(h==pos[33]&& hcellValue.length()>0){
								 StringList orang1=mxAttr.getChoices(context,"SEM IssueCar Property");
                                 StringList rang1=i18nNow.getAttrRangeI18NStringList("SEM IssueCar Property", orang1,strLanguage);
								 for(int k=0;k<rang1.size();k++){
									 String value=(String)rang1.get(k);
									 String newValue=(String)orang1.get(k);
									 if(value.equals(hcellValue)){
										 IssueObj.setAttributeValue(context,"SEM IssueCar Property",newValue);
										 break;
									 }
								 }
							}else if(h==pos[34]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM IssuePoints Deduction",hcellValue);
							}else if(h==pos[35]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue Line",hcellValue);
							}else if(h==pos[36]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Equipment Type",hcellValue);
							}else if(h==pos[37]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM Issue Undertaker",hcellValue);
							}else if(h==pos[38]&& hcellValue.length()>0){
								IssueObj.setAttributeValue(context,"SEM TestIssue Number",hcellValue);
							}											
					   } 
				
					 }		
		 }
			  }
	      }
		ContextUtil.commitTransaction(context);
		 %>
		 <script type="text/javascript">

  		opener.parent.location.href = opener.parent.location.href;


  	alert("\u5BFC\u5165\u5B8C\u6210\u3002");
	
	top.window.close();

</script>
<%
	  }catch(Exception ex){
		  ex.printStackTrace();
		  ContextUtil.abortTransaction(context);
		  String strErrorMsg = ex.getMessage();
		  
		  
		  
		  
		  %>
			<script type="text/javascript">

  		
  	alert("<%=strErrorMsg%>");
	
	top.window.close();
	
		  <%
		 
		// throw new Exception(ex.getMessage());
		  
	  }
	  	  
  }

%>
   

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