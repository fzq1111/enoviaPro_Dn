<%--  emxCommonAutonomySearchSubmit.jsp - This page is used in SubmitURL to emxFullSearch.jsp by a javascript class emxCommonAutonomySearch

   Copyright (c) 2008-2011 Dassault Systemes, 1993 - 2007. All rights reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxCommonAutonomySearchSubmit.jsp.rca 1.1.1.3.3.2 Wed Oct 22 16:17:43 2008 przemek Experimental przemek $
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<!-- Include Java script functions -->

<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>

<script language="javascript">
	var arrSelectedObjects = new Array;
	var objSelection = null;
<%
    try {
        // Get request parameters. Selected objects and onsubmit function	
		String[] strEmxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
		String strOnSubmitCallback = emxGetParameter(request, "onSubmit");
		String selectId = emxGetParameter(request, "selectId");
		// If there are not objects selected
		if (strEmxTableRowIds == null || strEmxTableRowIds.length == 0) {
		    throw new Exception(getI18NString("emxComponentsStringResource", "emxComponents.Common.PleaseMakeASelection", lStr));
		}
		
		// If onSubmit parameter is not passed
		if (strOnSubmitCallback == null || "".equals(strOnSubmitCallback.trim())) {
		    throw new Exception("No onSubmit callback function provided.");                
		}
		String strTableRowId = null;
		StringList slTokens = null;
		String strParentObjectId = null;
		String strObjectId = null;
		String strType = null;
		String strName = null;
		String strRevision = null;
		String strRelId = null;
		String strObjLevel = null;
		String firstName = null;
		String lastName = null;
		StringList slBusSelect = new StringList();
		slBusSelect.add(DomainObject.SELECT_TYPE);
		slBusSelect.add(DomainObject.SELECT_NAME);
		slBusSelect.add("attribute["+DomainObject.ATTRIBUTE_LAST_NAME+"]");
		slBusSelect.add("attribute["+DomainObject.ATTRIBUTE_FIRST_NAME+"]");
		
		DomainObject dmoObject = null;
		Map mapObjInfo = null;
		
		for (int i = 0; i < strEmxTableRowIds.length; i++) {
		    strTableRowId = strEmxTableRowIds[i];
		    
		    if (strTableRowId == null || strTableRowId.length() == 0) {
		        continue;
		    }
		    
		    //emxTableRowId=|57868.32728.25576.7105||1,2
			//emxTableRowId=|57868.32728.35552.39987||1,1
		    slTokens = split(strTableRowId, "|");
		    
		    strParentObjectId = (String)slTokens.get(0);
			strObjectId = (String)slTokens.get(1);
			strRelId = (String)slTokens.get(2);
			strObjLevel = (String)slTokens.get(3);
			
			dmoObject = new DomainObject(strObjectId);
			mapObjInfo = dmoObject.getInfo(context, slBusSelect);
			
			strType = (String)mapObjInfo.get(DomainObject.SELECT_TYPE);
			strName = (String)mapObjInfo.get(DomainObject.SELECT_NAME);
			firstName = (String)mapObjInfo.get("attribute["+DomainObject.ATTRIBUTE_FIRST_NAME+"]");		
			lastName = (String)mapObjInfo.get("attribute["+DomainObject.ATTRIBUTE_LAST_NAME+"]");		
%>
			// Create a selection object and add to selection list
			objSelection = new emxCommonSerchPerson("<%=strParentObjectId%>",
																"<%=strObjectId%>",
																"<%=strType%>",
																"<%=strName%>",
																"<%=strRelId%>",
																"<%=firstName%>",
																"<%=lastName%>");
			arrSelectedObjects[arrSelectedObjects.length] = objSelection;
<%		    
		}
%>
		// Call the onSubmit function 
		if (<%=strOnSubmitCallback%>) {
			var strSelectId = "<%=selectId%>";
			<%=strOnSubmitCallback%>(arrSelectedObjects,strSelectId);
			top.close();
		}
		else {
			alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.Common.AutonomySearch</emxUtil:i18nScript> <%=strOnSubmitCallback%>");
		}	
<%		
    } catch (Exception ex) {
        String strExpMsg = ex.getMessage();
         if (strExpMsg != null && strExpMsg.length() != 0) {
            emxNavErrorObject.addMessage(strExpMsg);
         }
         else {
             emxNavErrorObject.addMessage(ex.toString());
         }
    } finally {
        // Add cleanup statements if required like object close, cleanup session, etc.
    }
%>
function emxCommonSerchPerson(strParentObjectId, strObjectId, strType, strName, strRelId,strFirstName,strLastName) {
    // The id of the parent object
    this.parentObjectId = strParentObjectId;
    // The id of the object itself
    this.objectId = strObjectId;
    // The object type
    this.type = strType;
    // The object name
    this.name = strName;
    // The relationship id
    this.relId = strRelId;
    // The level numbres in indented table row
    this.firstName = strFirstName;
    this.lastName = strLastName;
    this.debug = function() {
    	alert("emxCommonAutonomySearchSelection object: \nParnetObject=" + this.parentObjectId + "\nObjectId=" + this.objectId + "\nType=" + this.type + "\nName=" + this.name +  "\nRel Id=" + this.relId + "\nFist Name=" + this.firstName+ "\nLast Name=" + this.lastName);
    }//End : function debug
}//End : function emxCommonAutonomySearchSelection
</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<!-- Include Page display code here -->

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>

<%!

	/**
	 * Method to split the string at given delimiter. 
	 * Not using FrameworkUtil.split because of following issue.
	 * If value "|A||C" is to be splitted at "|", then FrameworkUtil.split returns 3 tokens instead of 4. "A", "", "C".
	 *
	 * @param strValue - The value to be splitted
	 * @param strDelimiter - The delimiter
	 * @return StringList object containing the values tokenized at delimiter.
	 * @throws Exception if operation fails
	 */
	private static StringList split(String strValue, String strDelimiter) throws Exception {
	    if (strValue == null) {
	        throw new Exception("Null strValue");
	    }
	    
	    if (strDelimiter == null) {
	        throw new Exception("Null strDelimiter");
	    }
	    
	    StringList slTokens = new StringList();
	    String strTempValue = strValue;
	    int nLengthOfDelimiter = strDelimiter.length();
	    int nIndex = 0;
	    boolean isFinished = false;
	    
	    while (!isFinished) {
		    nIndex = strTempValue.indexOf(strDelimiter);
		    if (nIndex == -1) {
		        slTokens.add(strTempValue);
		        isFinished = true;
		    }
		    else {
		        slTokens.add(strTempValue.substring(0, nIndex));
		        strTempValue = strTempValue.substring(nIndex+nLengthOfDelimiter);
		    }
	    }
	    
	    return slTokens;
	}

%>
