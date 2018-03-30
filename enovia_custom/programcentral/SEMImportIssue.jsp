<%--
   Create by ICE 
   
--%>
<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page language="java" pageEncoding="UTF-8"%>

<%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectId = emxGetParameter(request,"objectId");
  String flag=emxGetParameter(request,"typeflag");
  //System.out.println("flag====="+flag);

  // Add Parameters Below
  // Specify URL to come in middle of frameset
  String contentURL = "SEMIssueImportProcess.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+"&objectId="+objectId+"&typeflag="+flag;

  String PageHeading = "emxProgramCentral.Common.SEMImportIssue";
  String HelpMarker = "emxhelppartbommultilevelreport";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  
 // Role based access
 /*String roleList = "role_DesignEngineer,role_SeniorDesignEngineer,role_ManufacturingEngineer,role_SeniorManufacturingEngineer,role_ECRCoordinator,role_ECREvaluator,role_ECRChairman,role_ProductObsolescenceManager,role_PartFamilyCoordinator,role_SupplierEngineer,role_SupplierRepresentative";*/
 String roleList ="role_GlobalUser";

  fs.createCommonLink("emxProgramCentral.Command.Done",
                      "doneMethod()",
                       roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      4);

  fs.createCommonLink("emxProgramCentral.Common.Cancel",
                      "parent.window.close()",
                       roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      0);
  
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>
