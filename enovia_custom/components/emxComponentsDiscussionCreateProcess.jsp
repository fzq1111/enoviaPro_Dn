<%--  emxComponentsDiscussionCreateProcess.jsp   -  creates a Discussion
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsDiscussionCreateProcess.jsp.rca 1.11 Wed Oct 22 16:18:02 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc" %>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<%
  // read the MemberId and ProjectId passed in
  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  String strSubject   = emxGetParameter(request, "Subject");
  String strMessage   = emxGetParameter(request, "Message");
  String objectId     = emxGetParameter(request, "objectId");
  String openerFrame     = emxGetParameter(request, "openerFrame");
  //System.out.println("openerFrame=="+openerFrame);
  String isReply = emxGetParameter(request, "formHeader");
  
  strSubject = FrameworkUtil.findAndReplace(UINavigatorUtil.htmlEncode(strSubject), "\n", "<br />");
  strMessage = FrameworkUtil.findAndReplace(UINavigatorUtil.htmlEncode(strMessage), "\n", "<br />");
  // added for Private and Public Messages
  String visibility = emxGetParameter(request, "DiscType");
  String strType      = "";
  String treeUrl      = null;
  try{
    ContextUtil.startTransaction(context, true);
    Message message           = (Message) DomainObject.newInstance(context,DomainConstants.TYPE_MESSAGE);
    Route route = (Route)DomainObject.newInstance(context,Route.TYPE_ROUTE);
    DomainObject domainObject = DomainObject.newInstance(context,objectId);
    strType = (String)domainObject.getInfo(context,domainObject.SELECT_TYPE);
	//System.out.println("strType=="+strType);
	boolean boolTree = false;
	String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteComponents.emxTreeAlternateMenuName.type_Message","emxComponentsProperties");
	if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
    	 boolTree = true;
  	}
  if(boolTree == true) {
    MailUtil.setTreeMenuName(context, treeMenu );
  }
//Depending on the Private and Public message visibility, corresponding create() method from the Message class should be called
	String strPrivate = "Private";
	String strPublic  = "Public";
if(!UIUtil.isNullOrEmpty(isReply) && isReply.contains("Reply")){
	if(visibility != null){
	    //Code to convert visibility from "Private Message"/"Public Message"
	    if(visibility.contains(strPrivate)){
	        //Private message
	    	message.create(context, strSubject, strMessage,strPrivate,domainObject);
	    }
	    else{
	        //Public message
	        message.create(context, strSubject, strMessage,strPublic,domainObject);
	    }
	}
	else{
	    //Public message without visibility parameter
	    message.create(context, strSubject, strMessage,domainObject);
	}
  	//String strURL = "emxTeamDiscussionSummary.jsp?objectId="+objectId + "&jsTreeID=" + jsTreeID + "&suiteKey=" + suiteKey;
  	treeUrl = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + message.getId() +"&emxSuiteDirectory="+appDirectory+"&mode=insert";//&jsTreeID=" + jsTreeID;//message.getId()
}
 	

       ContextUtil.commitTransaction(context);
  }catch(Exception ex)
  {
    ContextUtil.abortTransaction(context);
    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage("emxActionBar:" + ex.toString().trim());
  }
%>

<script language="javascript">
<%
if(strType.equals("Resource Request")){
    %>
    parent.window.getWindowOpener().location.href = parent.window.getWindowOpener().location.href;
    window.closeWindow();
    <%
} else if(!strType.equals("Message")) {
%>
var contentFrame = openerFindFrame(getTopWindow(),"content");
var detailsDisplay  = openerFindFrame(getTopWindow(), "detailsDisplay");

if (detailsDisplay && detailsDisplay.location.href.indexOf('emxPortal.jsp')== -1) {
	detailsDisplay.location.href = detailsDisplay.location.href;
	} else{
		var openerFrame = openerFindFrame(getTopWindow(),"<%=XSSUtil.encodeForJavaScript(context, openerFrame)%>");
		if(openerFrame){
			openerFrame.location.href = openerFrame.location.href;
		}else{
			contentFrame.getTopWindow().refreshTablePage();
		}
}
//window.closeWindow();
getTopWindow().closeSlideInDialog();
<%
  } else {
%>
    var detailsDisplay = openerFindFrame(getTopWindow(), "detailsDisplay");
    if(detailsDisplay) {
	    if(eval(detailsDisplay.document.getElementById("APPDiscussionView"))) {
	        view = detailsDisplay.document.getElementById("APPDiscussionView").value;      
	    } else {
	        view = detailsDisplay.header.document.getElementById("APPDiscussionView").value;
	    }

	    if(eval(detailsDisplay.document.getElementById("APPDiscussionSort"))) {
	        sort =  detailsDisplay.document.getElementById("APPDiscussionSort").value;
	    } else {
	        sort = detailsDisplay.header.document.getElementById("APPDiscussionSort").value;
	    }
	 
	    if(eval(detailsDisplay.document.getElementById("APPDiscussionShow"))) {
	      	show = detailsDisplay.document.getElementById("APPDiscussionShow").value;
    }else{
	      	show = detailsDisplay.header.document.getElementById("APPDiscussionShow").value;
    }
	
	    if(eval(detailsDisplay.document.getElementById("txtTempDiscussion"))) {
	       	tempVar = detailsDisplay.document.getElementById("txtTempDiscussion").value; 
	    } else {
	       	tempVar = detailsDisplay.header.document.getElementById("txtTempDiscussion").value;
    }
 
	 if(eval(findFrame(getTopWindow(), "discussionTreeDisplay"))) {   
	     	findFrame(getTopWindow(), "discussionTreeDisplay").location.href = tempVar + "&discussionView=" + view + "&discussionSort=" + sort + "&discussionShow=" + show;
    } else  {
	        findFrame(getTopWindow().getWindowOpener(), "discussionTreeDisplay").location.href = tempVar + "&discussionView=" + view + "&discussionSort=" + sort + "&discussionShow=" + show;  
    }
    }
   window.closeWindow();
<%
  }
%>
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc" %>


