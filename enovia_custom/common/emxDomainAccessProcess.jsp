<%--  emxDomainAccessProcess.jsp   - The Collection Memeber delete object processing page
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    PropertyUtil.setGlobalRPEValue(context, DomainAccess.RPE_MEMBER_ADDED_REMOVED, "true");    
    String objectId = emxGetParameter(request, "objectId");
    String access = emxGetParameter(request, "access");
	String cmdEventToHandle = emxGetParameter(request, "cmdName");
	String jpoName = emxGetParameter(request,"jpoName");
	String methodName = emxGetParameter(request,"methodName");
    String[] ids = emxGetParameterValues(request, "emxTableRowId");
	Boolean flag = false;
    if(UIUtil.isNullOrEmpty(jpoName) && UIUtil.isNullOrEmpty(methodName)){
    	jpoName = "emxDomainAccess";
    	methodName = "deleteAccess";
    }
    
        
    //System.out.println("DEFAULT PROJECT = " +DomainAccess.getDefaultProject(context));
    if(cmdEventToHandle.equals("deleteAccess")) {						
	    Map paramMapForJPO = new HashMap();		
		paramMapForJPO.put("busObjId", objectId);			
		paramMapForJPO.put("emxTableRowIds" ,ids);		
		String[] args = JPO.packArgs(paramMapForJPO);
		JPO.invoke(context, jpoName, null, methodName, args);
    } else {       
	    String owner = "";
	    String ownerAccess = "";
	    String defaultAccess = "";
	    String OID = "";	    
		for(int i =0; i<ids.length;i++)
	    {
	    
	    	StringList idList = com.matrixone.apps.domain.util.StringUtil.split(ids[i], "|");
	    	if( idList.size() >= 1 )
	    	{
	      		//String busId = (idList.size() >2) ? (String)idList.get(1) : objectId;
				String	busId = objectId;
	      		if(!busId.equals(OID))
	      		{
	      			OID = busId;
	      			owner =  new DomainObject(busId).getInfo(context, DomainObject.SELECT_OWNER);
	      			StringList accessNames = DomainAccess.getLogicalNames(context, busId);
	      			defaultAccess = (String)accessNames.get(0);
	      			ownerAccess = (String)accessNames.get(accessNames.size()-1);      			
	      		}
	 			if (cmdEventToHandle.equals("addPerson"))
				{
					String personId = (String)idList.get(1);
					String personName = new DomainObject(personId).getInfo(context, DomainObject.SELECT_NAME);
					String personType = new DomainObject(personId).getInfo(context, DomainObject.SELECT_TYPE);
					
					if(personType.equals("Project Space")){
						flag = true;
					}else{
						if(!personType.equals("Person")){
							 personId = (String)idList.get(0);
							 personName = new DomainObject(personId).getInfo(context, DomainObject.SELECT_NAME);
							 personType = new DomainObject(personId).getInfo(context, DomainObject.SELECT_TYPE);
						}
						if(personName.equals(owner)){					
							DomainAccess.createObjectOwnership(context, busId, personId, ownerAccess, DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);	
						}else {					
							DomainAccess.createObjectOwnership(context, busId, personId, defaultAccess, DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);	
						}
					}
					
									
				} else if (cmdEventToHandle.equals("addProject"))
				{
					String projectId = (String)idList.get(0);
					String projectName = new DomainObject(projectId).getInfo(context, DomainObject.SELECT_NAME);
					//System.out.println("Inside DomainAccess Process" +projectName);
					DomainAccess.createObjectOwnership(context, busId, null, projectName, defaultAccess, DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);
				} else if (cmdEventToHandle.equals("addOrg"))
				{
					String orgId = (String)idList.get(0);
					String orgName = new DomainObject(orgId).getInfo(context, DomainObject.SELECT_NAME);
					//System.out.println("Inside DomainAccess Process" +orgName);
					DomainAccess.createObjectOwnership(context, busId, orgName, null, defaultAccess, DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);
				} else if (cmdEventToHandle.equals("addSecurityContext"))
				{
					String secContextId = (String)idList.get(0);
					String orgName = new DomainObject(secContextId).getInfo(context, DomainConstants.SELECT_RELATIONSHIP_SECURITY_CONTEXT_ORGANIZATION_TO_NAME);
					String projectName = new DomainObject(secContextId).getInfo(context, DomainConstants.SELECT_RELATIONSHIP_SECURITY_CONTEXT_PROJECT_TO_NAME);
					//System.out.println("Inside DomainAccess Process" +orgName);
					//System.out.println("Inside DomainAccess Process" +projectName);
					DomainAccess.createObjectOwnership(context, busId, orgName, projectName, defaultAccess, DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);
				}  
	      	}
	    }	
    }

%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>	
<%
if(flag){
	%>
	<script>
	  alert("\u8bf7\u9009\u62e9\u4eba\u5458\uff01");
	  getTopWindow().location.href = getTopWindow().location.href;
	</script>
	<%
}else{
	%>
	<script>
		var pageToRefresh = getTopWindow().getWindowOpener();
		var cmdEvent = "<%=XSSUtil.encodeForJavaScript(context,(String) cmdEventToHandle)%>";
		if (pageToRefresh) {
			if ("deleteAccess" == cmdEvent){
				getTopWindow().location.reload();
			}else{
				getTopWindow().getWindowOpener().location.reload();
				getTopWindow().closeWindow();			
				}
		}
		else
		{
			getTopWindow().refreshTablePage();
		}
	</script>
	<%
}
%>





