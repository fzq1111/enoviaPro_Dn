<%--  emxComponentsCheckinProcess.jsp -
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentCheckinProcess.jsp.rca 1.22 Wed Oct 22 16:18:50 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "emxComponentsSetCompanyKeyInRPE.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.UIUtil"%>

<jsp:useBean id="requestBean" scope="page" class="com.matrixone.apps.domain.util.Request"/>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
  Map requestMap = (Map) session.getAttribute("emxCommonDocumentCheckinData");
  //Commented this for the bug 335525
  //session.removeAttribute("emxCommonDocumentCheckinData");
  //End of comments for the bug 335525
  String objectAction = (String)requestMap.get("objectAction");
  String objectId       = "";
  String appProcessPage = (String)requestMap.get("appProcessPage");
  String appDir         = (String)requestMap.get("appDir");
  String jpoName = (String)requestMap.get("JPOName");
  String methodName = (String)requestMap.get("methodName");
  String deleteFromTree = (String)requestMap.get("deleteFromTree");
  String refreshTable = (String)requestMap.get("refreshTable");
  String deleteFilePostCheckin = (String)requestMap.get("deleteFileOnCheckin");
  
  String checkinDirValue = Download.processDefaultCheckoutDirectory(context);
  if(UIUtil.isNotNullAndNotEmpty(checkinDirValue)){
	  deleteFilePostCheckin = "true";
  }
  
  boolean errorMSG=false;
  boolean refreshTableContent = "true".equalsIgnoreCase((String)requestMap.get("refreshTableContent"));
  Map objectMap = new HashMap();
  StringList strFileList = (StringList)requestMap.get("fileList");
  if (strFileList == null)
  {
      strFileList = new StringList(5);
  }
  %>
  <script type="text/javascript">
  function findFrame(objWindow, strName)
  {
  if (strName == "_top") {
  return getTopWindow();
  } else if (strName == "_self") {
  return self;
  } else if (strName == "_parent") {
  return parent;
  } else {
  var objFrame = null;
  for (var i = 0; i < objWindow.frames.length && !objFrame; i++)
  {
  if (objWindow.frames[i].name == strName) {
    objFrame = objWindow.frames[i];
  }
  }
  if (!objFrame) {
  for (var i=0; i < objWindow.frames.length && !objFrame; i++) {
    objFrame = findFrame(objWindow.frames[i], strName);
  }
  }
  return objFrame;
  }
  }
  function compareframe(frm1, frm2){
  for (var i = 0; i < frm1.frames.length; i++){
  	if (frm1.location.href.indexOf(frm2) != -1) {
  		return true;
  	}  	
  }
  return false;
  }
  </script>
  <%
  String fcsEnabled = (String) requestMap.get("fcsEnabled");
  StringList deleteFromTreeList = (StringList)requestMap.get("deleteFromTreeList");
  boolean updateDeleteFromTreeList = false;
  if (deleteFromTreeList == null || deleteFromTreeList.size() == 0)
  {
      deleteFromTreeList = new StringList(5);
      if ( deleteFromTree != null && !"".equals(deleteFromTree) && !"null".equals(deleteFromTree) )
      {
          deleteFromTreeList.addElement(deleteFromTree);
          updateDeleteFromTreeList = true;
      }
  }
  String oid = "";
  try
  {
      boolean multiPart = false;
      if (request.getContentType() != null &&
        request.getContentType().indexOf("multipart/form-data") == 0)
      {
        multiPart = true;
      }

      //Map requestMap = new HashMap();
      Enumeration enumParam;
        if (multiPart)
        {
          com.matrixone.servlet.FileUploadMultipartRequest multi = requestBean.uploadFile(context,request,true,true);
          //requestBean.uploadFile(context,request);
          enumParam = multi.getParameterNames();
          objectId = multi.getParameter("objectId");
          //jpoName = multi.getParameter("JPOName");
          //appProcessPage = multi.getParameter("appProcessPage");
          //appDir = multi.getParameter("appDir");
          requestMap.put("fcsEnabled", "false");

          while (enumParam.hasMoreElements())
          {
            String name = (String) enumParam.nextElement();
            String value = (String) multi.getParameter(name);
            if ( name.indexOf("fileName") == 0 && (value != null && !"".equals(value) && !"null".equals(value) ) )
            {
              strFileList.addElement(value);
            }
            if ( updateDeleteFromTreeList && name.indexOf("oid") == 0 )
            {
                if ( value != null && !"".equals(value) && !"null".equals(value) )
                {
                    deleteFromTreeList.addElement(value);
                }
            }
            requestMap.put(name, value);
          }
        }
        else
        {
          enumParam = request.getParameterNames();
          objectId = (String)requestMap.get("objectId");
          //jpoName = request.getParameter("JPOName");
          //appProcessPage = request.getParameter("appProcessPage");
          //appDir   = request.getParameter("appDir");
          requestMap.put("fcsEnabled", "true");
          while (enumParam.hasMoreElements())
          {
              String name = (String) enumParam.nextElement();
              requestMap.put(name, request.getParameter(name));
              if (updateDeleteFromTreeList && name.indexOf("oid") == 0 )
              {
                oid = request.getParameter(name);
                if ( oid != null && !"".equals(oid) && !"null".equals(oid) )
                {
                    deleteFromTreeList.addElement(oid);
                }
              }
          }
        }
        if ( fcsEnabled != null && !"".equals(fcsEnabled) && !"null".equals(fcsEnabled) )
        {
            requestMap.put("fcsEnabled", fcsEnabled);
        }
        request.setAttribute("requestMap", requestMap);
        String[] args = JPO.packArgs(requestMap);

        if ( "".equals(objectId) || "null".equals(objectId) )
        {
          objectId = null;
        }
        if (jpoName == null || "".equals(jpoName) || "null".equals(jpoName) )
        {
          jpoName = "emxCommonDocument";
        }
        if (methodName == null || "".equals(methodName) || "null".equals(methodName) )
        {
          methodName = "commonDocumentCheckin";
        }

        objectMap = (Map)JPO.invoke(context, jpoName, null, methodName, args, Map.class);
        request.setAttribute("objectMap", objectMap);
        request.setAttribute("requestMap", requestMap);
        errorMSG = UIUtil.isNullOrEmpty((String)objectMap.get("errorMessage")) ? true : false;
        if(!errorMSG)
        {
        	String errorMsg = (String)objectMap.get("errorMessage");
        	if(errorMsg.contains("ORA-12899") || errorMsg.contains("ORA-01461")){
	    		String oraErrorMessage = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Create.NameColumn", new Locale(request.getHeader("Accept-Language")));            		
	    		session.setAttribute("error.message", oraErrorMessage);	    	
        	}else{
          session.setAttribute("error.message", objectMap.get("errorMessage"));
        	}
          
        }
  } catch (Exception ex) {

      try
      {
        if ( objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER)
                  || objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ZIP_TAR_GZ)) {

          // Logic to delete the object when an exception comes.
          String []objectIds = new String[1];
          objectIds[0] = objectId;
          DomainObject.deleteObjects(context,objectIds);
        }
      } catch(Exception dex)
      {
        String deleteErrMessage = dex.getMessage();
        dex.printStackTrace();
        session.putValue("error.message", deleteErrMessage);
      }
      String errMessage = ex.getMessage();
      ex.printStackTrace();
	  if(errMessage.contains("ORA-12899") || errMessage.contains("ORA-01461")){
    	  errMessage = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Create.NameColumn", new Locale(request.getHeader("Accept-Language")));
      }
      session.putValue("error.message", errMessage);
  }
  finally
  {
      Document.workspaceCleanUp(context,strFileList);
      int interval = session.getMaxInactiveInterval();
      int maxInterval = Integer.parseInt((String)EnoviaResourceBundle.getProperty(context,"emxFramework.ServerTimeOutInSec"));
      if( interval == maxInterval )
      {
        interval = ((Integer)session.getAttribute("InactiveInterval")).intValue();
        session.setMaxInactiveInterval(interval);
      }
  }
  String newURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + XSSUtil.encodeForURL(context, objectId);
  newURL +="&emxSuiteDirectory="+XSSUtil.encodeForURL(context, appDirectory);
  if ( appProcessPage != null && !"".equals(appProcessPage) && !"null".equals(appProcessPage) )
  {
      // Added so that when the checkin applet is used, the
      // processing JSP gets the parent ID if it exists.
      String parentId = (String)requestMap.get("parentId");
      // IR-116358V6R2012x when XSS is turned on
	  requestMap.put("fromPage", "multi");
	  requestMap.put("refreshTableContent",(String)requestMap.get("refreshTableContent"));
	  //IR-116358V6R2012x end
      appProcessPage = "../" + appDir + "/" + appProcessPage;
                context.shutdown();
      
      if(errorMSG && (deleteFilePostCheckin == "true" || "true".equalsIgnoreCase(deleteFilePostCheckin))){
    	  appProcessPage = appProcessPage+"?"+"objectId="+XSSUtil.encodeForURL(context, objectId)+"&parentId="+XSSUtil.encodeForURL(context,parentId)+"&refreshTableContent="+refreshTableContent+"&fromPage=multi";
      	%>

<script language="Javascript">
var myframe=getTopWindow().getWindowOpener().getTopWindow();
var myappletFrame=getTopWindow().getWindowOpener().getTopWindow().document.getElementById("appletFrame");
if(compareframe(myframe,"emxNavigator.jsp")){
myappletFrame=getTopWindow().getWindowOpener().getTopWindow().document.getElementById("appletFrame");
}else if(compareframe(getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow(), "emxNavigator.jsp")){
myframe = getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow();
myappletFrame = getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow().document.getElementById("appletFrame");
}

appletHiddenFrame = findFrame(myframe,"appletFrame");
myappletFrame.style.height = "1px";
myappletFrame.style.width = "1px";
myappletFrame.style.visibility = "visible";

appletHiddenFrame.document.location.href =  "emxAppletDeleteProcess.jsp";
//XSSOK
document.location.href = "<%=appProcessPage%>";
</script>
      	<%	
      	      }
      	      else{
%><!-- //XSSOK -->
  <jsp:forward page="<%=appProcessPage%>" >
  <jsp:param name ="objectId" value  ="<%=objectId%>" />   
      <jsp:param name ="parentId" value ="<%=parentId%>" />
      <jsp:param name ="refreshTableContent" value ="<%=refreshTableContent%>" />
      <jsp:param name ="fromPage" value  ="multi" />
      </jsp:forward>
                	<%     }
                		
  }
  else
  {
      // The function javascript findFrame is added to the page since IE not recognizing js include
      // with document.write which is needed in Applet version of file upload
%>
    <script language="Javascript">
    var tree          = getTopWindow().getWindowOpener().getTopWindow().objStructureTree;
    var refreshTableContent = ("true" == "<%=refreshTableContent%>");
    var frameContent1 = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
<%
    if (objectAction.indexOf("create") != -1)
    {
%>
      if(getTopWindow().getWindowOpener().getTopWindow().modalDialog)
      {
          getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
      }
<%
    }
	if(errorMSG && (deleteFilePostCheckin == "true" || "true".equalsIgnoreCase(deleteFilePostCheckin))){
%>
var myframe=getTopWindow().getWindowOpener().getTopWindow();
var myappletFrame=getTopWindow().getWindowOpener().getTopWindow().document.getElementById("appletFrame");
if(compareframe(myframe,"emxNavigator.jsp")){
	myappletFrame=getTopWindow().getWindowOpener().getTopWindow().document.getElementById("appletFrame");
}else if(compareframe(getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow(), "emxNavigator.jsp")){
	myframe = getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow();
myappletFrame = getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow().document.getElementById("appletFrame");
	  }

appletHiddenFrame = findFrame(myframe,"appletFrame");
myappletFrame.style.height = "1px";
myappletFrame.style.width = "1px";
myappletFrame.style.visibility = "visible";
    appletHiddenFrame.document.location.href =  "emxAppletDeleteProcess.jsp";	  
	  
<%	}%>
      var frameContent;
      if(getTopWindow().getWindowOpener()) {
        frameContent = getTopWindow().getWindowOpener();
      } else {
        frameContent = findFrame(getTopWindow(),"detailsDisplay");
      }
      var checking = true;
<%
      if ( deleteFromTreeList.size() == 0)
      {
%>
        if ( frameContent != null )
        {
<%
        if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER)){
%>
         if(tree){
           var SelectedNodeParent =tree.getSelectedNode().parent.parent;
           if((SelectedNodeParent != null )&&(SelectedNodeParent != 'undefined'))
           {
             tempNodeID = SelectedNodeParent.nodeID;
           tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, objectId)%>",false);
           frameContent1.addStructureNode("<%=XSSUtil.encodeForJavaScript(context, objectId)%>","",tempNodeID,"<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>");
    }
           else{
        	   //XSSOK
             frameContent1.document.location.href="<%=newURL%>";
         checking = false;
           }
    }
<%     }
      if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ON_DEMAND)){ 
      String fromPage = "";
      String calledPage = "";
      if(requestMap.get("fromPage") != null) 
          {
            fromPage = (String)requestMap.get("fromPage");
          }
      if(requestMap.get("calledPage") != null ){
        calledPage= (String)requestMap.get("calledPage");
      }
          if ("Navigate".equalsIgnoreCase(fromPage) || "Navigate".equalsIgnoreCase(calledPage)){
%>
         checking = false;
        getTopWindow().getWindowOpener().getTopWindow().document.location.href =  "../components/emxCommonDocumentVCNavigateProcess.jsp";
<% 
     }
   }
%>  
    if(checking){
		    var loadHREF = true;
		    if(refreshTableContent) {
            	var tableContentFrame;
            	if(getTopWindow().getWindowOpener()) {
            		tableContentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"listDisplay");
           	    } else {
           	    	tableContentFrame = findFrame(getTopWindow(),"listDisplay");
           	    }
           	    if(tableContentFrame) {
	           	    tableContentFrame.refreshTableContent();
	           	    loadHREF = false;
           	    } 
		    } 
			if(getTopWindow().opener && getTopWindow().opener.getTopWindow().RefreshHeader){
				getTopWindow().opener.getTopWindow().RefreshHeader();
			}else if(getTopWindow().RefreshHeader){
				getTopWindow().RefreshHeader();
			}
		    if(loadHREF) {
			    frameContent.document.location.href = frameContent.document.location.href;
		    }
         }
        } else {
<%
        if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER)){
%>
         if(tree){
         var SelectedNodeParent =tree.getSelectedNode().parent.parent;
          if((SelectedNodeParent != null )&&(SelectedNodeParent != 'undefined'))
         {
           tempNodeID = SelectedNodeParent.nodeID;
           selObjId   = SelectedNodeParent.objectID
         tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, objectId)%>",false);
         frameContent1.addStructureNode("<%=XSSUtil.encodeForJavaScript(context, objectId)%>","",tempNodeID,"<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>");
     }
         else{
           checking= false;
           //XSSOK
           frameContent1.document.location.href="<%=newURL%>";
         }
        }
<%     }

      if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ON_DEMAND)){ 
         String fromPage = "";
         String calledPage = "";

          if(requestMap.get("fromPage") != null) 
          {
            fromPage = (String)requestMap.get("fromPage");
          }
          if(requestMap.get("calledPage") != null ){
            calledPage= (String)requestMap.get("calledPage");
          }
          if ("Navigate".equalsIgnoreCase(fromPage) || "Navigate".equalsIgnoreCase(calledPage)){
%>
         checking = false;
        getTopWindow().getWindowOpener().getTopWindow().document.location.href =  "../components/emxCommonDocumentVCNavigateProcess.jsp";
<% 
     }
   }
%>  

          if(checking){
		    var loadHREF = true;
		    if(refreshTableContent) {
            	var tableContentFrame;
            	if(getTopWindow().getWindowOpener()) {
            		tableContentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"listDisplay");
           	    } else {
           	    	tableContentFrame = findFrame(getTopWindow(),"listDisplay");
           	    }
           	    if(tableContentFrame) {
	           	    tableContentFrame.refreshTableContent();
	           	    loadHREF = false;
           	    } 
		    } 
		    if(loadHREF) {
			    getTopWindow().getWindowOpener().getTopWindow().document.location.href = getTopWindow().getWindowOpener().getTopWindow().document.location.href;
		    }
      }
        }
<%
      } else {
%>
        var contTree = getTopWindow().getWindowOpener().getTopWindow().objStructureTree;
		frameContent = openerFindFrame(getTopWindow(),"detailsDisplay");
		frameContent = frameContent == null ? openerFindFrame(getTopWindow(), "listDisplay"): frameContent;
		frameContent = frameContent == null ? frameContent = getTopWindow().getWindowOpener() : frameContent;	
        
        if(contTree == null || contTree.currentRoot == null) {
        	var loadHREF = true;
		    if(refreshTableContent) {
            	var tableContentFrame;
            	if(getTopWindow().getWindowOpener()) {
            		tableContentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"listDisplay");
           	    } else {
           	    	tableContentFrame = findFrame(getTopWindow(),"listDisplay");
           	    }
           	    if(tableContentFrame) {
	           	    tableContentFrame.refreshTableContent();
	           	    loadHREF = false;
           	    } 
		    } 
		    if(loadHREF) {
	           if ( frameContent != null )
    	       {
			        frameContent.document.location.href = frameContent.document.location.href;    
	            } else {
	                getTopWindow().getWindowOpener().getTopWindow().document.location.href = getTopWindow().getWindowOpener().getTopWindow().document.location.href;
	            }
		    }           
        } else {
<%
          Iterator deleteIdItr = deleteFromTreeList.iterator();
          while( deleteIdItr.hasNext() )
          {
              deleteFromTree = (String) deleteIdItr.next();
              if(deleteFromTree != null && !"".equals(deleteFromTree) && !"null".equals(deleteFromTree) )
              {
%>
                  contTree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, deleteFromTree)%>", false);
<%
              }
          }
%>
            
        	var loadHREF = true;
		    if(refreshTableContent) {
            	var tableContentFrame;
            	if(getTopWindow().getWindowOpener()) {
            		tableContentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"listDisplay");
           	    } else {
           	    	tableContentFrame = findFrame(getTopWindow(),"listDisplay");
           	    }
           	    if(tableContentFrame) {
	           	    tableContentFrame.refreshTableContent();
	           	    loadHREF = false;
           	    } 
		    } 
		    if(loadHREF) {
	           if ( frameContent != null )
    	       {
			        frameContent.document.location.href = frameContent.document.location.href;    
	            } else {
	                getTopWindow().getWindowOpener().getTopWindow().document.location.href = getTopWindow().getWindowOpener().getTopWindow().document.location.href;
	            }
		    }
            contTree.refresh();
        }
<%
      }
	  Object obj = objectMap.get("objectId");
	  String newDocId = null;
	  if(obj instanceof StringList)
	  {
		   StringList slNewObjId = (StringList)obj;
		   if(slNewObjId.size() > 0)
		   {
			   newDocId = (String)slNewObjId.get(0);
		   }
	  }
	  else if(obj instanceof String)
	  {
		   newDocId = (String) obj;
	  }
	  newURL = "../common/emxNavigator.jsp?isPopup=true&mode=tree&objectId=" + newDocId;
%>
	 alert("\u8bf7\u8d70\u6d41\u7a0b\u53d1\u5e03\u6b64\u6587\u6863\u0020\u6216\u0020\u76f4\u63a5\u53d1\u5e03\u6b64\u6587\u6863");						
	 getTopWindow().open('<%= newURL%>','','width=990,height=690');	
     getTopWindow().closeWindow();
    </script>
<%
  }
%>
