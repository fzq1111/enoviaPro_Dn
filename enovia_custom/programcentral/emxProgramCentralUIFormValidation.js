//=================================================================
// JavaScript emxUIFormValidation.js
//
// Copyright (c) 1992-2015 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================
// emxProgramCentralUIFormValidation.js
// This file is used to add any validation routines to be used by the UIForm component
//-----------------------------------------------------------------

// [Added::Jan 19, 2011:S4E:R211:TypeAhead::Start]
//This functions will be executed when user changes Resource Pool field,
//Preferred person and Business skill will become blank when Resource pool is changed
//Added to Change the fields of form according to selected Quality data types..
function ChangeQualityType() {

	var objectId= document.forms[0].objectId.value;
	var timeStamp= document.forms[0].timeStamp.value;
	var DataTypeElement = document.getElementById("DataTypeId").value;

	if("Continuous"==DataTypeElement)
	{
		var href="../common/emxCreate.jsp?type=type_Quality&relationship=relationship_Quality&form=PMCProjectQualityCreateForm&policy=policy_Quality&header=emxProgramCentral.Common.Quality&postProcessJPO=emxQuality:createQualityProcess&isContinuous=true&nameField=both&autoNameChecked=true&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral&submitAction=doNothing&postProcessURL=../programcentral/emxProgramCentralUtil.jsp?mode=refreshQualityPage&targetLocation=slidein&openerFrame=detailsDisplay&objectId="+objectId+"&timeStamp="+timeStamp+"";

		window.location.href=href;
	}
	else if("Discrete"==DataTypeElement) 
	{
		var href="../common/emxCreate.jsp?type=type_Quality&relationship=relationship_Quality&form=PMCProjectQualityCreateForm&policy=policy_Quality&header=emxProgramCentral.Common.Quality&postProcessJPO=emxQuality:createQualityProcess&isContinuous=false&nameField=both&autoNameChecked=true&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral&submitAction=doNothing&postProcessURL=../programcentral/emxProgramCentralUtil.jsp?mode=refreshQualityPage&targetLocation=slidein&openerFrame=detailsDisplay&objectId="+objectId+"&timeStamp="+timeStamp+"";

		window.location.href=href;

	}
}
//Added to validate field DPU of Quality form
function validateDPU()
{
	var DPU = document.forms[0].DPU;
	if(isNaN(DPU.value)){
		alert("DPU Value must be a Real Number.");
		return false;
	}
	else if(DPU.value <0)
	{
		alert("DPU Value must be a Positive Integer.");
		return false;
	}
	else if (DPU.value > 2147483647){
		alert("DPU Value must be smaller than 2^31 - 1");
		return false;
	}else{
		return true;
	}
}
//Added to validate field DPMO of Quality form
function validateDPMO()
{	
	var DPMO = document.forms[0].DPMO;

	if(isNaN(DPMO.value)){
		alert(" DPMO Value must be a Real Number.");
		return false;
	}
	else if (DPMO.value > 2147483647){		
		alert("DPMO Value must be smaller than 2^31 - 1");
		return false;
	}else{
		return true;
	}
}
//Added to validate field Sigma of Quality form
function validateSigma()
{	
	var Sigma = document.forms[0].Sigma;	
	if(isNaN(Sigma.value)){
		alert("Sigma Value must be a Real Number.");
		return false;
	}	
	else if (Sigma.value > 2147483647){
		alert("Sigma Value must be smaller than 2^31 - 1");
		return false;
	}else{
		return true;
	}	
}

//Added to validate fields Mean,StandardDeviation,UpperSpecificationLimit, LowerSpecificationLimit,of Quality form
function validateContinuousFields()
{
	var Mean = document.forms[0].Mean.value;
	var StandardDeviation = document.forms[0].StandardDeviation.value;
	var UpperSpecificationLimit = document.forms[0].UpperSpecificationLimit.value;
	var LowerSpecificationLimit = document.forms[0].LowerSpecificationLimit.value;
	var continuousFieldvalues = new Array(Mean,StandardDeviation,UpperSpecificationLimit,LowerSpecificationLimit);
	var continuousFieldNames = new Array("Mean","Standard Deviation","Upper Spec Limit","Lower Spec Limit");
	for(var i=0; i<continuousFieldvalues.length; i++) {
		var value = continuousFieldvalues[i];

		if(isNaN(value)){
			alert(continuousFieldNames[i]+" Value must be a Real Number.");
			return false;
		}
		else if (value > 2147483647){
			alert(continuousFieldNames[i]+" Value must be smaller than 2^31 - 1");
			return false;
		}
	}
	return true;
}

function clearPreferredPersons()
{
	document.forms[0].PreferredPersonDisplay.value="";
	document.forms[0].PreferredPersonOID.value="";
	document.forms[0].PreferredPerson.value="";
}
//[Added::Jan 19, 2011:S4E:R211:TypeAhead::End]


//added for Risk Configurable component V6R2008-1

function modifyRPNValueForRisk() { 
     var Impact = document.forms[0].Impact.value;
     var Probability = document.forms[0].Probability.value;
     document.forms[0].RPN.value = Impact * Probability;
    }


function getSearchData()
    {
     var objectId=document.getElementById('myParentId').value;
     var href= "../programcentral/emxProgramCentralAddProjectContentPreProcess.jsp?objectId="+objectId+"&back=true";

     for (var i = 0; i <document.forms[0].elements.length; i++ )
     {
        //Added one more condition to cut short length of url as it is constraint
        if(document.forms[0].elements[i].name !=null && document.forms[0].elements[i].name !="" && document.forms[0].elements[i].name!="emxTableRowIdActual" && document.forms[0].elements[i].name!="RequestValuesMap")
        {
            href=href+"&"+document.forms[0].elements[i].name+"="+document.forms[0].elements[i].value;
        }
     }
     //added for the bug 340320 
     if (isIE) {
         window.open('','_parent','');
      }
     //till here
    getTopWindow().location.href=href;

    }

// added for to nullify the "ProgramName" field.
function removeProgram() { 
    document.forms[0].ProgramId.value = null;
    document.forms[0].ProgramName.value = "";
    return true;
}

// added for to nullify the "BusinessUnitName" field.
function removeBusinessUnit() {
    document.forms[0].BusinessUnitId.value = null;
    document.forms[0].BusinessUnitName.value = "";
    return true;
}

//Added:23-March-09:yox:R207:PRG:Bug :368172
  /*function checkStartEndDateValidate() {
      
      var strEstimatedEndDate = document.forms[0].EstimatedEndDate.value;
      var fieldEstimatedEndDate = new Date(strEstimatedEndDate);

    
      var strEstimatedStartDate = document.forms[0].EstimatedStartDate.value;
      var fieldEstimatedStartDate = new Date(strEstimatedStartDate);

       
    
     if(fieldEstimatedStartDate.getTime() > fieldEstimatedEndDate.getTime())
     {
         alert("End date cannot be before the start date.");
    	 //Added:PRG:I16:R213:IR-131272V6R2013 Start
    	 //var errBegin = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Import.EndDateBeforeStartDate</emxUtil:i18nScript>";
    	 //alert(errBegin);
    	//End:PRG:I16:R213:IR-131272V6R2013 End
       return false;
      }
      return true;
    }*/
//End:R207:PRG :Bug :368172

// Added:24-Mar-109:nzf:R207:PRG:Bug:366902
function isBadNameChars() {
  var isBadNameChar=checkForNameBadCharsList(this);
       if( isBadNameChar.length > 0 )
       {
         alert(BAD_NAME_CHARS + isBadNameChar);
         return false;
       }
        return true;
}
// End:R207:PRG:Bug:366902

function selectAssociatedPlanOnDeliverableTemplate()
{
	emxFormReloadField('Plan');
}

function selectResourcePoolPeople()
{//Modified function :24-Mar-109:di1:R210:ARP feature
	var ResourcePoolId = document.forms[0].ResourcePoolOID.value;
	if( null == ResourcePoolId || "" == ResourcePoolId){
	  	if (ResourcePoolId.length == 0){
	  		alert("Please select Resource Pool");
                     //Added:PRG:I16:R213:IR-131272V6R2013 Start
	  		 //var errBegin = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.ResourcePool.SelectPerson</emxUtil:i18nScript>";
	    	 //alert(errBegin);	  		
                  //Added:PRG:I16:R213:IR-131272V6R2013 End	  	
	  		return;
	  	}	  	
	}

	if (ResourcePoolId == null || ResourcePoolId == "" || ResourcePoolId == "null"){
		alert("Please select Resource Pool");
                 //Added:PRG:I16:R213:IR-131272V6R2013 Start
		//var errBegin = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.ResourcePool.SelectPerson</emxUtil:i18nScript>";
   	    //alert(errBegin);
		//Added:PRG:I16:R213:IR-131272V6R2013 End
		return;
	}

	  	var href = "../common/emxFullSearch.jsp?field=TYPES=type_Person&table=AEFGeneralSearchResults&cancelLabel=emxProgramCentral.Common.Close&selection=multiple&objectId="+ResourcePoolId+"&excludeOIDprogram=emxResourceRequest:getExcludeOIDforResourcePoolPerson&submitURL=../programcentral/emxProgramCentralResourceRequestAutonomySearchSelect.jsp&fieldNameActual=PreferredPerson&fieldNameDisplay=PreferredPersonDisplay&fieldNameOID=PreferredPersonOID&suiteKey=ProgramCentral";
  		showChooser(href,700,500);   
	  	 
    }

//Added function :26-Oct-10:s2e:R210  IR: IR-070493V6R2012   	
function selectResourcePoolPreferredPerson()
{
	var ResourcePoolId = document.forms[0].ResourcePoolOID.value;
	if( null == ResourcePoolId || "" == ResourcePoolId){
	  	if (ResourcePoolId.length == 0){
	  		alert("Please select Resource Pool");
	  	//Added:PRG:I16:R213:IR-131272V6R2013 Start
	  		//var errBegin = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.ResourcePool.SelectPerson</emxUtil:i18nScript>";
	    	//alert(errBegin);
                //Added:PRG:I16:R213:IR-131272V6R2013 End
	  		return;
	  	}	  	
	}
	if (ResourcePoolId == null || ResourcePoolId == "" || ResourcePoolId == "null"){
		alert("Please select Resource Pool ");
                //Added:PRG:I16:R213:IR-131272V6R2013 Start		
		//var errBegin = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.ResourcePool.SelectPerson</emxUtil:i18nScript>";
   	    //alert(errBegin);
               //Added:PRG:I16:R213:IR-131272V6R2013 End
		return;
	}
	  	//var href = "../common/emxFullSearch.jsp?field=TYPES=type_Person&table=PMCCommonPersonSearchTable&cancelLabel=emxProgramCentral.Common.Close&selection=multiple&objectId="+ResourcePoolId+"&excludeOIDprogram=emxResourceRequest:getExcludeOIDforResourcePoolPerson&form=PMCCommonPersonSearchForm&submitURL=../programcentral/emxProgramCentralResourceRequestAutonomySearchSelect.jsp&fieldNameActual=PreferredPerson&fieldNameDisplay=PreferredPersonDisplay&fieldNameOID=PreferredPersonOID&suiteKey=ProgramCentral";
		var href = "../common/emxFullSearch.jsp?field=TYPES=type_Person:POLICY=policy_Person:RESOURCE_POOL_ID=" + ResourcePoolId + "&table=PMCCommonPersonSearchTable&cancelLabel=emxProgramCentral.Common.Close&selection=multiple&objectId="+ResourcePoolId+"&excludeOIDprogram=emxResourcePool:getExcludeOIDForAddResourcesSearch&form=PMCCommonPersonSearchForm&submitURL=../programcentral/emxProgramCentralResourceRequestAutonomySearchSelect.jsp&fieldNameActual=PreferredPerson&fieldNameDisplay=PreferredPersonDisplay&fieldNameOID=PreferredPersonOID&suiteKey=ProgramCentral";  	
	  	showChooser(href,700,500);   
}
//End :26-Oct-10:s2e:R210  IR: IR-070493V6R2012 

function selectResourcePoolSkill(businessSkill1,businessSkill2,businessSkill3,resourcePool)
{
  	var href = "../common/emxFullSearch.jsp?field=TYPES=type_BusinessSkill&table=PMCBusinessSkillSearchSummary&cancelLabel=emxProgramCentral.Common.Close&selection=single&submitURL=../programcentral/emxProgramCentralResourceRequestAutonomySearchSelect.jsp&fieldNameActual="+ businessSkill1 +"&fieldNameDisplay="+businessSkill2+"&fieldNameOID="+businessSkill3+"&suiteKey=ProgramCentral";
		showChooser(href,700,500);   
         // End:27-Apr-R212:MS9:PRG:IR-103943V6R2012x
	//End:04-Feb-R211:hp5:PRG:IR-046641V6R2012
}


   
//Added For IR-033739V6R2011
//Added:4-Oct-2010:vf2:R2012
//document.write("<script src='../common/scripts/emxUICore.js' type='text/javascript'></script>");
//End:4-Oct-2010:vf2:R2012
var CHANGE_PROJECT="Change Project";
function validationForAddProgram()
{
	var document= getTopWindow().document;
	//if(null!=frameobj.document.forms[0].ActualType && frameobj.document.forms[0].ProgramId.value =="" && frameobj.document.forms[0].ActualType.value == CHANGE_PROJECT){	
	if(null!=document.forms[0].ActualType && document.forms[0].ProgramId.value =="" && document.forms[0].ActualType.value == CHANGE_PROJECT){	
    	alert("Please enter a Program");
    	return false;
    }else{
    	return true;
    	}
}
//End For IR-033739V6R2011
//Added:28-May-2010:s4e:R210 PRG:ARP
function validateStandardCost() {
    var standardCostValue = document.forms[0].StandardCost.value;
    if (isNaN(standardCostValue))
     {
       alert("Please enter numeric value for Standard Cost");
        //Added:PRG:I16:R213:IR-131272V6R2013 Start    	
        //var errBegin = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.StandardCost.EnterNumericValue</emxUtil:i18nScript>";
   	    //alert(errBegin);
        //Added:PRG:I16:R213:IR-131272V6R2013 End
       return false;
     } 
     else if (parseInt(standardCostValue,10) < 0 )
     {
       alert("Please enter positive value for Standard Cost");
       //Added:PRG:I16:R213:IR-131272V6R2013 Start    	 
        //var errBegin = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.StandardCost.EnterPositiveValue</emxUtil:i18nScript>";
    	//alert(errBegin);
        //Added:PRG:I16:R213:IR-131272V6R2013 End
       return false;
     }
     else{
         return true;    
     }
    
}
//End:28-May-2010:s4e:R210 PRG:ARP
//Added:13-Aug-2010:rz1:R210 PRG for External IR-063823V6R2011x bug
function validateNumberofPerson() {
    var NumberofPersonvalue = document.forms[0].NumberOfPeople.value;
    //MODIFIED:PA4:25-Aug-2011:IR-123555V6R2012x
    if (isNaN(NumberofPersonvalue)|| (parseFloat(NumberofPersonvalue,10) < 0 ))
     {
    	var key = "emxProgramCentral.Validate.ValidatePeople";
    	var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=translateErrorMsg&key="+key;
    	var responseText = emxUICore.getData(strURL);
    	var responseJSONObject = emxUICore.parseJSON(responseText);
    	var errorMsg = responseJSONObject["Error"];
    	alert(errorMsg);
        return false;
     } 
     else{
         return true;    
     }}

//END:13-Aug-2010:rz1:R210 PRG External IR-063823V6R2011x


function validateResourceRequestName() {
   var RequestName = document.forms[0].Name.value;
   var badChars = checkForNameBadCharsList(document.getElementById("Name"));
   if(badChars.length > 0 )
   {
	   alert("The following characters are invalid:\n"+badChars+"\nPlease remove the invalid character from Name Field");
	   //Added:PRG:I16:R213:IR-131272V6R2013 Start
       //var errBegin = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.InvalidCharacters</emxUtil:i18nScript>";
	   //var errEnd = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.RemoveInvalidCharacter</emxUtil:i18nScript>";
	    //alert(errBegin+" "+badChars+" "+errEnd);
//Added:PRG:I16:R213:IR-131272V6R2013 End	   
       return false;
   }
       return true;
}

  // [ADDED::PRG:RG6:Feb 25, 2011:IR-094808V6R2012x :R211::Start]
 function validateWBSTaskName() {
	   var taskNameField = document.forms[0].Name;
	   var badChars = checkForNameBadCharsList(taskNameField);
   if(badChars.length > 0 )
   {
	   alert("The following characters are invalid:\n"+badChars+"\nPlease remove the invalid character from Name Field");
	   //Added:PRG:I16:R213:IR-131272V6R2013 Start
       //var errBegin = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.InvalidCharacters</emxUtil:i18nScript>";
	   //var errEnd = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.RemoveInvalidCharacter</emxUtil:i18nScript>";
	   //alert(errBegin+" "+badChars+" "+errEnd);
//Added:PRG:I16:R213:IR-131272V6R2013 End
       return false;
   }
       return true;
}
//[ADDED::PRG:RG6:Feb 25, 2011:IR-094808V6R2012x :R211::End]

 //ADDED for IR-030459V6R2013x
 function validateWBSTaskConstraintDate() {

	 var taskTypeElement = document.getElementById("Task Constraint Type").value;
	 //IR-196805V6R2014: Date value is coming as NaN in FF for non English language. Manual entry is not allowed so entered value will be always date string, 
	 //so NaN check is not required. Need to check constaint date value is set or not by comparing with "".		
	 //var taskDateElement = new Date(document.getElementById("TaskConstraintDate").value);	

	 //if(taskTypeElement!= "As Soon As Possible" && taskTypeElement != "As Late As Possible" && isNaN(taskDateElement.getTime()))
	 if(taskTypeElement!= "As Soon As Possible" && taskTypeElement != "As Late As Possible" && document.getElementById("TaskConstraintDate").value == "")
	 {
		 alert("Please select the Task Constraint Date");
		 return false;
	 }	
	 return true;
 }
 
//Added for the IR-221588V6R2014 to check both Badchars and characters length.  
 function checkFormFieldLength(fieldObj){
	  var charset = document.charset;
	  var chars = fieldObj.value;
	  var fieldLengthMax = 127;
	  var i;
	  var asciiCount = 0;
	  var unicodeCount = 0;
	  for (i = 0; i < chars.length; i++) {
	    var charValue = chars.charCodeAt(i);
	    if (charValue < 256) {
	      asciiCount++;
	    } else {
	      unicodeCount++;
	    }
	  }
	  
	  var byteCount = (unicodeCount * 3) + asciiCount;	  
	  if((charset != null || charset != undefined) && charset=='Shift_JIS'){
	    byteCount = (unicodeCount * 2) + asciiCount;
	  }
	  
	  if (byteCount > fieldLengthMax) {
	    return "Fail";
	  } else {
	    return "Pass";
	  }
	}

 function validateBadCharsNlength(){
	 var isBadNameChar=checkForNameBadCharsList(this);
	 if( isBadNameChar.length > 0 )
	 {
		 alert(BAD_NAME_CHARS + isBadNameChar);
		 return false;
	  } else {
		 var charLength = checkFormFieldLength(this);
		 if(charLength == "Fail"){			 
			 var timestamp = new Date().getTime();			 
			 var url="../programcentral/emxProgramCentralUIFormValidation.jsp?strmode=maxLengthError&timestamp="+timestamp;
			 var strMaxLength=emxUICore.getData(url);
			 alert(strMaxLength);
			 return false;
		 }else
	    return true;
	  }     
 }
function validateExpIssueDate(){
	 var isValidDate = true;
	 var  formName = document.emxCreateForm;
	 
	 if((formName.EstimatedStartDate.value != "" && formName.EstimatedStartDate.value != null)&&(formName.EstimatedFinishDate.value != "" && formName.EstimatedFinishDate.value!= null)){
		 if(formName.EstimatedStartDate_msvalue.value > formName.EstimatedFinishDate_msvalue.value){
			 alert("Invalid Date:\n Estimated Start Date should not be later than Estimated Finish Date.\n Please enter valid dates.");
			 isValidDate = false;
		 }else{
			 isValidDate = true;
		 }
	 }else{
		 isValidDate = false;
	 }
	 
	 if(isValidDate){
		 return true;
	 }else{
		 return false;
	 }
 }

//Synchronization 
function syncRows(dir){
	var cBoxArray = new Array();
    var checkboxes = getCheckedCheckboxes();
    
    for (var e in checkboxes){
    	var aId    = e.split("|");
		var rowid  = aId[3];
		var rowObject = getSelectedRowObjects([rowid])[0];
		var nRows = emxUICore.selectNodes(rowObject, ".//r");
		var matchresult = rowObject.getAttribute("matchresult");
		if(matchresult != 'common' && dir == matchresult){
			var chkLen = nRows.length;
		    for(var j = 0; j < chkLen; j++){
		       var id = nRows[j].getAttribute("id");
		       var oid = nRows[j].getAttribute("o");
		       var relid = nRows[j].getAttribute("r");
		       if (relid == null || relid == "null") {
		          relid = "";
		       }
		       var parentId = nRows[j].getAttribute("p");
		       if (parentId == null || parentId == "null") {
		          parentId = "";
		       }
		       var totalRowInfo = relid + "|" + oid + "|" + parentId + "|" + id;
		       FreezePaneregisterByRowId(id);
		       checkboxes[totalRowInfo] = totalRowInfo;
		    }
		}
    }    
    
    for (var e in checkboxes){
    	var aId    = e.split("|");
		var rowid  = aId[3];
        cBoxArray[cBoxArray.length] = rowid;
    }
    var invalidSyncArray = [];
    for (var e in checkboxes){

    	var aId    = e.split("|");
    	var rowid  = aId[3];
    	var rowObject = getSelectedRowObjects([rowid])[0];

    	var matchResult = rowObject.getAttribute("matchresult");
    	var taskName = "";
    	if("common" != parentMatchResult && "parent" != parentMatchResult){
    		var rowColumns = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@id = '" + rowid + "']/c");
    		var columnCount = rowColumns.length;
    		var columnHalf = columnCount/2;

    		taskName = trim(emxUICore.getText(rowColumns[0]));
    		if(taskName=="" || taskName==null){
    			taskName = trim(emxUICore.getText(rowColumns[columnHalf]));
    		}
    	}
    	
    	var parentMatchResult = rowObject.parentNode.getAttribute("matchresult");
    	var parentRowId = rowObject.parentNode.getAttribute("id");
    	var isSelected = false;

    	if(dir == matchResult){
    		//Do nothing
    	}else{
    		//#1 use case
    		for(var itr = 0; itr < cBoxArray.length; itr++) {
    			if(cBoxArray[itr]==parentRowId){
    				isSelected = true;
    			}
    		}

    		//#2
    		if(!isSelected && parentRowId != "0"){
    			if("common" != parentMatchResult && "parent" != parentMatchResult){
    				var parentRow = emxUICore.selectSingleNode(syncDataXML, "/mxRoot/object/object[@rowId = '" + parentRowId + "']");
    				if(parentRow != null){
    					var markup = parentRow.getAttribute("markup");
    					if("cut"==markup){
    						invalidSyncArray.push(taskName);
    					}
    				}else{
    					invalidSyncArray.push(taskName);
    				}
    			}
    		}
    	}
    }
    
    if(invalidSyncArray.length > 0){
    	var invalidTaskName = "";
    	for(var i=0;i<invalidSyncArray.length;i++){
    		if(i==0){
    			invalidTaskName = invalidSyncArray[i];
    		}else{
    			invalidTaskName += ", "+invalidSyncArray[i];
    		}
    	}
    	var strURL = "../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=errorMsg";
    	var responseText = emxUICore.getData(strURL);
    	var responseJSONObject = emxUICore.parseJSON(responseText);
    	var errorMsg = responseJSONObject["Error"];
    	alert(errorMsg+" "+invalidTaskName);
    }else{
    	if(dir=="left"){
			javascript:synchronize('left');
		}else if(dir=="right"){
			javascript:synchronize('right');
		}
    }
}

/***************New Project UI scripts**************/
function getFileDetails(mode){
	var errorMassage;
	var fileInput = document.getElementById('FileFullPath');
	var fileInputName = document.getElementById('FileFullPath').value;
	var file = fileInput.files[0];
	var url = "../programcentral/emxProgramCentralUtil.jsp?mode=importProjectProcess&fileName="+fileInputName;
	turnOnProgress();
	var responseText = getFilePostData(url,file);
	var responseJSONObject = emxUICore.parseJSON(responseText);
	var hasError = false;
	for (var key in responseJSONObject){
		
		if(key != "error" && "Schedule" !=mode){
			if(key == "title"){
				errorMassage = responseJSONObject[key];
			}else {
			document.getElementsByName(key)[0].value = responseJSONObject[key];
			}
		}else if(key == "error"){
			errorMassage = responseJSONObject[key];
			alert(errorMassage);
			hasError = true;
			break;
		}
		
	}
	turnOffProgress();
	enablePreviewButton();
	createImportedFileStatusField(hasError,mode,errorMassage);
	
}

function createImportedFileStatusField(hasError,mode,errorMassage){
	var image;
	var title;
	
	if(hasError){
		image = "images/iconStatusComplaintUrgent.png";
		title = errorMassage;
		disableImportFormFields();
	}else{
		image = "images/iconStatusComplete.gif";
		title = errorMassage;
		if("Schedule" !=mode){
		enableImportFormFields();
	}
	}
	var statusField = document.getElementById("status");
	if(statusField != null){
		statusField.src= image;
		statusField.title = title;
	}else{
		var img = "<img id=\"status\" src=\""+image+"\" title=\""+title+"\"/>";
		statusField = document.createElement('td');
		statusField.innerHTML= img;
		var previewNode = document.getElementById("previewFile");
		var nodeToAppend = previewNode.parentNode.parentNode;
		nodeToAppend.appendChild(statusField);
	}
	
} 
function disableAllFields(){
	document.getElementsByName("btnquestions")[0].disabled = true;
	document.getElementsByName("questionsDisplay")[0].value="No question for respond..";
}
function getFilePostData(strURL, strData, fnCallback, oClientData) {
	ElapsedTimer.enter(strURL + " " + strData + " " + fnCallback ? ("ASYNCH: ") : "synchronous");
	if (typeof strURL != "string") {
		ElapsedTimer.exit("FAIL");
		emxUICore.throwError("Required parameter strURL is null or not a string.");
	}
	var objHTTP = emxUICore.createHttpRequest();
	objHTTP.open("post", strURL, fnCallback != null);
	objHTTP.setRequestHeader("Content-Type", "multipart/form-data");
	addSecureTokenHeader(objHTTP);
	if (fnCallback) {
		if (typeof fnCallback != "function") {
			ElapsedTimer.exit("FAIL2");
			emxUICore.throwError("Optional parameter fnCallback is not null and not a function.");
		}
		objHTTP.onreadystatechange = function getXMLDataPost_readyStateChange() {
			if (objHTTP.readyState == 4) {
				//emxUICore.checkResponse(objHTTP);
				ElapsedTimer.info("getDataPost: Data callback: " + ElapsedTimer.fn(fnCallback));
				ElapsedTimer.enter("onreadystatechange: ->" + objHTTP.readyState + ' ' + objHTTP.responseText.length + " chars");
				fnCallback(objHTTP.responseText, oClientData, objHTTP);
				objHTTP.onreadystatechange = null;
				ElapsedTimer.exit("onreadystatechange");
			}
		};
		objHTTP.send(strData);
		ElapsedTimer.exit();
		return objHTTP;
	} else {
		objHTTP.send(strData);
		emxUICore.checkResponse(objHTTP);
		ElapsedTimer.exit(objHTTP.responseText.length + ' chars');
		try {
			return objHTTP.responseText;
		} finally {
			objHTTP = null;
		}
	}
}

function getPreview(){
	var href="../common/emxIndentedTable.jsp?table=PMCProjectImportFileViewTable&expandProgram=emxProjectSpace:getImportObjectList&suiteKey=ProgramCentral&SuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource&emxSuiteDirectory=programcentral&freezePane=Name&hideHeader=true&customize=false&rowGrouping=false&showPageURLIcon=false&hideLaunchButton=true&export=false&displayView=details&export=false&hideRootSelection=true&objectCompare=false&showClipboard=false&multiColumnSort=false&findMxLink=false&showRMB=false&massPromoteDemote=false&expandLevelFilter=false&cellwrap=false";
	showModalDialog(href);
}

function predictTemplateWBS(){
	var searchProjectTemplateId = document.getElementsByName("SeachProjectOID")[0].value;
	var href="../common/emxIndentedTable.jsp?table=PMCPredictTemplateWBSTable&sortColumnName=taskId&expandProgram=emxProjectSpace:getTemplateWBS&suiteKey=ProgramCentral&SuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource&emxSuiteDirectory=programcentral&freezePane=Name&hideHeader=true&customize=false&rowGrouping=false&showPageURLIcon=false&hideLaunchButton=true&export=false&displayView=details&export=false&hideRootSelection=true&objectCompare=false&showClipboard=false&multiColumnSort=false&findMxLink=false&showRMB=false&massPromoteDemote=false&expandLevelFilter=false&objectId="+searchProjectTemplateId;
	showModalDialog(href);
}
function previewTemplateTasksWBS(){
	var href="../common/emxIndentedTable.jsp?table=PMCPredictTemplateWBSTable&sortColumnName=taskId&program=emxProjectTemplate:getTemplateTasksWBS&expandProgram=emxProjectSpace:getTemplateWBS&suiteKey=ProgramCentral&SuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource&emxSuiteDirectory=programcentral&freezePane=Name&hideHeader=true&customize=false&rowGrouping=false&showPageURLIcon=false&hideLaunchButton=true&export=false&displayView=details&export=false&hideRootSelection=true&objectCompare=false&showClipboard=false&multiColumnSort=false&findMxLink=false&showRMB=false&massPromoteDemote=false&expandLevelFilter=false";
	showModalDialog(href);
}
function getExistingProjectInfo(){
	var searchProjectId = document.getElementsByName("SeachProjectOID")[0].value;

	if(searchProjectId != null && searchProjectId !="" && searchProjectId != "undefined"){
		var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=searchProjectData&searchProjectId="+searchProjectId;

		var responseText = emxUICore.getData(strURL);
		var responseJSONObject = emxUICore.parseJSON(responseText);

		for (var key in responseJSONObject) {
			if(document.getElementsByName(key)[0]!= null && document.getElementsByName(key)[0] != 'undefined'){
				if ( key == "description" && responseJSONObject[key] == null) {
					document.getElementsByName(key)[0].value = "";
				} else {
				document.getElementsByName(key)[0].value = responseJSONObject[key];
			}
		}
		}

	}else{
		setDefaultValue();
	}
}
function setFocusOnNameField(){
	document.getElementById("Name").focus();
}
function setFocusOnSearchField(){
	document.getElementsByName("SeachProjectDisplay")[0].focus();
}
function setDefaultValue(){
	document.getElementById("Name").value="";
	document.getElementById("descriptionId").value="";

	var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=getCurrentDate";
	var responseText = emxUICore.getData(strURL);
	var responseJSONObject = emxUICore.parseJSON(responseText);
	for (var key in responseJSONObject) {
		document.getElementsByName(key)[0].value = responseJSONObject[key];
	}
	//Program
	document.getElementsByName("ProgramDisplay")[0].value="";
	document.getElementsByName("Program")[0].value="";
	document.getElementsByName("ProgramOID")[0].value="";
	
	//BU
	document.getElementsByName("BusinessUnitDisplay")[0].value="";
	document.getElementsByName("BusinessUnit")[0].value="";
	document.getElementsByName("BusinessUnitOID")[0].value="";
	
	//BG
	var bg = document.getElementsByName("BusinessGoal")[0];
	if(bg != null && bg != 'undefined'){
		document.getElementsByName("BusinessGoalDisplay")[0].value="";
		document.getElementsByName("BusinessGoal")[0].value="";
		document.getElementsByName("BusinessGoalOID")[0].value="";	
	}
	
	//Question
	var question = document.getElementsByName("questions")[0];
	if(question != null && question != 'undefined'){
		disableQuestionField();
	}
	
	//Predict WBS
	var preview = document.getElementsByName("predictWBS")[0];
	if(preview != null && preview != 'undefined'){
		disableTemplatePredictWBS();
	}
	
	document.getElementsByName("SeachProjectDisplay")[0].focus();
}

function getSelectedProjectTemplateScheduleDetails(){
	var searchProjectTemplateId = document.getElementsByName("SeachProjectOID")[0].value;
	
	if(searchProjectTemplateId != null && searchProjectTemplateId !="" && searchProjectTemplateId != "undefined"){
		var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=searchProjectData&searchProjectId="+searchProjectTemplateId;
		
		var responseText = emxUICore.getData(strURL);
		var responseJSONObject = emxUICore.parseJSON(responseText);

		for (var key in responseJSONObject) {
			
			if(key=="Question" && responseJSONObject[key]=="true"){
				enableQuestionField();
			}else if(key=="Question" && responseJSONObject[key]=="false"){
				disableQuestionField();
			}
		}
		enableTemplatePredictWBS();
	}
}
function getSelectedProjectScheduleDetails(){
	
	var searchProjectTemplateId = document.getElementsByName("SeachProjectOID")[0].value;
	
	if(searchProjectTemplateId != null && searchProjectTemplateId !="" && searchProjectTemplateId != "undefined"){
		var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=getScheduleTasksPreview&searchProjectId="+searchProjectTemplateId;
		emxUICore.getData(strURL);
		enableTemplatePredictWBS();
	}	
}

function getSelectedProjectTemplateDetails(){
	var searchProjectTemplateId = document.getElementsByName("SeachProjectOID")[0].value;
	
	if(searchProjectTemplateId != null && searchProjectTemplateId !="" && searchProjectTemplateId != "undefined"){
		var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=searchProjectData&searchProjectId="+searchProjectTemplateId;
		
		var responseText = emxUICore.getData(strURL);
		var responseJSONObject = emxUICore.parseJSON(responseText);

		for (var key in responseJSONObject) {
			
			if(key=="Question" && responseJSONObject[key]=="true"){
				enableQuestionField();
			}else if(key=="Question" && responseJSONObject[key]=="false"){
				disableQuestionField();
			}else if(key=="RT" && responseJSONObject[key]=="true"){
				enableRTF();
				emxFormReloadField('ResourceTemplate');
			}else if(key=="RT" && responseJSONObject[key]=="false"){
				emxFormReloadField('ResourceTemplate');
				disableRT();
			}else if(key=="ProjectDate"){
				// While creating the Project from "Project Template" default date in ProjectDate field should not be changed after selecting the "Project Template".
			} else if(key == "ScheduleFrom"){
				emxFormReloadField('ScheduleFrom');
			} else if(key == "DefaultConstraintType") {
				emxFormReloadField('DefaultConstraintType');
			} else {
				var value = responseJSONObject[key];
				if(value != null && value !=""){
					document.getElementsByName(key)[0].value = value;
			}
		}
		}
		enableTemplatePredictWBS();
		
	}else{
		setDefaultValue();
	}
	
}

function disablePreviewButton(){
	document.getElementById("previewFile").disabled=true;
	disableImportFormFields();
}

function disableSchedulePreviewButton(){
	document.getElementById("previewFile").disabled=true;
}

function enablePreviewButton(){
	document.getElementById("previewFile").disabled=false;
}

function disableRT(){
	document.getElementById("ResourceTemplateId").disabled=true;
}

function disableRTF(){
	setFocusOnSearchField();
	document.getElementById("ResourceTemplateId").disabled=true;
	disableQuestionField();
}

function enableRTF(){
	document.getElementById("ResourceTemplateId").disabled=false;
}

function disableQuestionField(){
	var keyName = "questionsDisplay";
	var keyValue="";
	var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=QuestionTxt&subMode=NoQuestion";
	var responseTxt = emxUICore.getData(strURL);
	var responseJSONObj = emxUICore.parseJSON(responseTxt);
	
	keyValue = responseJSONObj[keyName];
	
	document.getElementsByName("btnquestions")[0].disabled = true;
	document.getElementsByName("questionsDisplay")[0].value=keyValue;
	disableTemplatePredictWBS();
}

function enableTemplatePredictWBS(){
	document.getElementById("predictWBS").disabled=false;
}

function disableTemplatePredictWBS(){
	document.getElementById("predictWBS").disabled=true;
}

function enableQuestionField(){
	var keyName = "questionsDisplay";
	var keyValue="";
	var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=QuestionTxt&subMode=ToRespond";
	var responseTxt = emxUICore.getData(strURL);
	var responseJSONObj = emxUICore.parseJSON(responseTxt);

	keyValue = responseJSONObj[keyName];
	
	document.getElementsByName("btnquestions")[0].disabled = false;
	document.getElementsByName("questionsDisplay")[0].value = "";//Value is set to empty for IR-436555-3DEXPERIENCER2016x
	
	enableTemplatePredictWBS();
}

function disableImportFormFields(){
	document.getElementById("Name").value="";
	document.getElementById("descriptionId").value="";
	
	document.getElementById("Name").disabled=true;
	document.getElementsByName("autoNameCheck")[0].disabled = true;
	document.getElementById("descriptionId").disabled=true;
	document.getElementsByName("TypeActualDisplay")[0].disabled=true;
	document.getElementsByName("btnTypeActual")[0].disabled = true;
} 
function enableImportFormFields(){
	document.getElementById("Name").disabled=false;
	document.getElementsByName("autoNameCheck")[0].disabled = false;
	document.getElementById("descriptionId").disabled=false;
	document.getElementsByName("TypeActualDisplay")[0].disabled=false;
	document.getElementsByName("btnTypeActual")[0].disabled = false;
}

//Task creation script
function reloadForm()
{
	emxFormReloadField('Policy');
}

function changeDurationAndPolicy()
{
	var selectedTaskType = document.getElementsByName("TypeActual")[0].value;
	var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=ChangePolicy&SelectedType="+selectedTaskType;
	var responseTxt = emxUICore.getData(strURL);
	var responseJSONObj = emxUICore.parseJSON(responseTxt);
	
	for (var key in responseJSONObj) {
		if(document.getElementsByName(key)[0]!= null && document.getElementsByName(key)[0] != 'undefined'){
			document.getElementsByName(key)[0].value = responseJSONObj[key];
		}
	}
	var policyElement = document.getElementById("PolicyId").value;
	var labels = document.getElementsByTagName("label");
	for (var i = 0; i < labels.length; i++) {
	         var elem = document.getElementsByTagName("label")[i].htmlFor;
	         if("Project Review"==policyElement && "NeedsReview"==elem){
	        	 document.getElementsByTagName("label")[i].style.visibility="hidden";
	        	 document.getElementById("NeedsReviewId").style.visibility = "hidden";
	         } else {
	        	 document.getElementsByTagName("label")[i].style.visibility="visible";
	        	 document.getElementById("NeedsReviewId").style.visibility = "visible";
	}
	}
}

function setDefaultConstraint() {
	 var defconstratinttype = "As Soon As Possible"; 
    if(null !=document.getElementById("Schedule FromId")){
    	var scheduledfrom = document.getElementById("Schedule FromId").value;
    }else if(null != document.emxCreateForm.ScheduleFrom){
    var scheduledfrom = document.emxCreateForm.ScheduleFrom.value;
    }
    var defconstratinttype = document.getElementById("DefaultConstraintTypeId");
    if("Project Start Date" == scheduledfrom){
    	defconstratinttype.value = "As Soon As Possible";    
    }else{
    	defconstratinttype.value = "As Late As Possible";
    }
}   

function validateWBSTaskConstraintDate1() {

	 var taskTypeElement = document.getElementById("Task Constraint TypeId").value;

	 if(taskTypeElement!= "As Soon As Possible" && taskTypeElement != "As Late As Possible" && document.getElementById("TaskConstraintDate").value == "")
	 {
		 alert("Please select the Task Constraint Date");
		 return false;
	 }	
	 return true;
}

function setTaskDuration()
{
	var taskDurationKeyword = document.getElementById("DurationKeywordsId");
	
	if(null!=taskDurationKeyword && null!=taskDurationKeyword.value)
   {
	var durationKeywordVal = taskDurationKeyword.value;
	if(durationKeywordVal!="")
	{
   	var temp = new Array();
   	temp = durationKeywordVal.split('|');
   	document.getElementById("Duration").value=temp[1];
   	document.getElementById("units_DurationId").value=temp[2];
	}
	else
	{
		document.getElementById("Duration").value="";
	}
}
}

function setDurationKeyword() {
	 var duration = document.getElementById("Duration");
	 //the seconCall logic is added because this method gets called twice.
	 var secondCall = duration.getAttribute("secondCall");
	 if(secondCall != "true" && (isNaN(duration.value) || duration.value < 0)){
		 alert("Value must be a Positive Real Number");
		 duration.value="";
		 duration.setAttribute("secondCall","true");
		 return false;
	 }else{
		 duration.removeAttribute("secondCall");
	 }
	 var taskDurationKeyword = document.getElementById("DurationKeywordsId");
	 if(null!=taskDurationKeyword) {
		 taskDurationKeyword.value = "";
	 }
	    
}

function addApplicabilityContextsSelector(){
	var selectTag = document.getElementsByName("ApplicabilityContexts");
	var applicabilityContextsHidden = document.getElementById("ApplicabilityContextsHidden");
	var sURL=	'../common/emxFullSearch.jsp?field=TYPES=type_Model&excludeOID='+applicabilityContextsHidden.value+'&table=PMCGeneralSearchResults&selection=multiple&hideHeader=true&submitURL=../enterprisechange/emxEnterpriseChangeUtil.jsp?mode=searchUtil&targetTag=select&selectName=ApplicabilityContexts';
	showChooser(sURL, 850, 630);
}

//For ECH fields
function removeApplicabilityContexts() {
	var selectTag = document.getElementsByName("ApplicabilityContexts");
	var selectedOptionsValue = "";
	for (var i=selectTag[0].options.length-1;i>=0;i--) {
		if (selectTag[0].options[i].selected) {
			if (selectedOptionsValue!="") {
				selectedOptionsValue += ",";
			}
			selectedOptionsValue += selectTag[0].options[i].value;
			selectTag[0].remove(i);
		}
	}
	
	var applicabilityContextsHidden = document.getElementById("ApplicabilityContextsHidden");
	var applicabilityContextsHiddenValues = applicabilityContextsHidden.value.split(",");
	var selectedOptionsValues = selectedOptionsValue.split(",");
	var applicabilityContextsHiddenNewValue = "";
	for (var j=0;j<applicabilityContextsHiddenValues.length;j++) {
		var applicabilityContextsHiddenValue = applicabilityContextsHiddenValues[j];
		var contains = "false";
		for (var k=0;k<selectedOptionsValues.length;k++) {
    		var selectedOptionValue = selectedOptionsValues[k];
    		if (applicabilityContextsHiddenValue == selectedOptionValue) {
    			contains = "true";
    		}
    	}
		if (contains == "false") {
			if (applicabilityContextsHiddenNewValue!="") {
				applicabilityContextsHiddenNewValue += ",";
    		}
			applicabilityContextsHiddenNewValue += applicabilityContextsHiddenValue;
		}
	}
	applicabilityContextsHidden.value = applicabilityContextsHiddenNewValue;
}

//Drag & drop
function isValidDnDOperation(inputs) {
	var error = "";
	var success = "";
	
	if(inputs != "" && inputs != 'undefined'){
		var isDragParent = false;
		var targetObjectId 		= inputs.targetObjectId;
		var targetObjectLevel	= inputs.targetObjectLevel;
		var targetObjectType 	= inputs.targetObjectType;

		var draggedObjectId		= inputs.draggedObjectId;
		var draggedObjectLevel	= inputs.draggedObjectLevel;
		var draggedObjectType	= inputs.draggedObjectType;

		if(draggedObjectLevel != ""){
			isDragParent = targetObjectLevel.indexOf(draggedObjectLevel)== 0?true:false;
		}

		if(isDragParent){
			var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=DnDWarningMsg";
			var responseTxt = emxUICore.getData(strURL);
			var responseJSONObj = emxUICore.parseJSON(responseTxt);
			error 	=  responseJSONObj["error"];
			success = "error"; 
		}else {
			var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=DragAndDrop&targetObjectId="+targetObjectId+"&targetObjectLevel="+targetObjectLevel+"&targetObjectType="+targetObjectType+"&draggedObjectId="+draggedObjectId+"&draggedObjectLevel="+draggedObjectLevel+"&draggedObjectType="+draggedObjectType;
			var responseTxt = emxUICore.getData(strURL);
			var responseJSONObj = emxUICore.parseJSON(responseTxt);
			success =  responseJSONObj["status"];
			error 	=  responseJSONObj["error"];
		}
		return {status: success, error:error};
	}else{
		return true;
	}
	
}

function ChangeEventFrequncy() {
	debugger;
	var objectId= document.forms[0].parentOID.value;
	var EventFreqElelment = document.getElementById("FrequencyId").value;
	if("Non-Recurrence"==EventFreqElelment)
	{		
		var href="../common/emxForm.jsp?form=PMCCalendarCreateEventForm&mode=edit&findMxLink=false&formHeader=emxProgramCentral.Common.CreateCalendar&isNonRecurrence=true&postProcessJPO=emxWorkCalendar:createCalendareEventProcess&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral&submitAction=doNothing&postProcessURL=../programcentral/emxProgramCentralUtil.jsp?mode=refreshCalendarEventPage&targetLocation=slidein&openerFrame=PMCListCalendarEvents&HelpMarker=emxhelpcalendareventcreate&objectId="+objectId+"&parentOID="+objectId+"";

		window.location.href=href;
	}
	else if("Weekly"==EventFreqElelment) 
	{
		var href="../common/emxForm.jsp?form=PMCCalendarCreateEventForm&mode=edit&findMxLink=false&formHeader=emxProgramCentral.Common.CreateCalendar&isNonRecurrence=false&postProcessJPO=emxWorkCalendar:createCalendareEventProcess&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral&submitAction=doNothing&postProcessURL=../programcentral/emxProgramCentralUtil.jsp?mode=refreshCalendarEventPage&targetLocation=slidein&openerFrame=PMCListCalendarEvents&HelpMarker=emxhelpcalendareventcreate&objectId="+objectId+"&parentOID="+objectId+"";

		window.location.href=href;
	}
}

function ChangeReviewTaskField() {
		var policyElement = document.getElementById("PolicyId").value;
	var labels = document.getElementsByTagName("label");
	for (var i = 0; i < labels.length; i++) {
	         var elem = document.getElementsByTagName("label")[i].htmlFor;
	         if("Project Review"==policyElement && "NeedsReview"==elem){
	        	 document.getElementsByTagName("label")[i].style.visibility="hidden";
	        	 document.getElementById("NeedsReviewId").style.visibility = "hidden";
	         } else {
	        	 document.getElementsByTagName("label")[i].style.visibility="visible";
				 //webfrom里面的NeedsReview隐藏了,会弹出验证方法未定义
	        	 //document.getElementById("NeedsReviewId").style.visibility = "visible";
	         }
	}
}

/**
 * Validate state of selected tasks.
 * @param frameXML -  structure browser object.
 * @returns {Boolean} - boolean value.
 */
function validateScheduleState(frameXML)
{
	var isValidOperation = true;
    var checkboxes = frameXML.getCheckedCheckboxes();
    
    for (var e in checkboxes){
    	var aId    = e.split("|");
		var rowid  = aId[3];
		
		var rowObject 			= frameXML.getSelectedRowObjects([rowid])[0];
		var taskStateValue 		= frameXML.document.getElementById(rowObject.getAttribute("o")).value;
		
		if(taskStateValue != null && typeof taskStateValue != "undefined" 
			&& taskStateValue =="Review" && taskStateValue =="Complete"){
			alert("You cannot perform indentation operation beyond active state!");
			isValidOperation = false;
			break;
		}
    }
    
	return isValidOperation;
}

function removeLocation() { 
    document.forms[0].LocationId.value = null;
    document.forms[0].LocationName.value = "";
}

function validateProjectName() { 
	var projectName=this.value;
	if(projectName == " "){
		
		var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=errorMessage&key=emxProgramCentral.Common.WrongProjectName";
		var responseTxt = emxUICore.getData(strURL);
		var responseJSONObj = emxUICore.toJSONString(responseTxt);
		var parsedValue 	=  responseJSONObj;
		var strErrorMessage = parsedValue;
		
		alert(strErrorMessage);
	}
	else{
		return true;
	}
}
