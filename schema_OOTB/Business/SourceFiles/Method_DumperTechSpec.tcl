#########################################################################
#
# @progdoc      Method_DumperTechSpec.tcl
#
# @Description: Used to extract a complete Technical Specification or 
#               Technical Specification template structure into spinner files.
#
# @Parameters:  None
#
# @Usage:       Run this program as a method in thick client on a 'Technical Specification'.
#
# @progdoc      Copyright (c) ENOVIA Inc., June 26, 2002
#
#########################################################################
#
# @Modifications: Matt Osterman 11/08/2004 - v 0.2 (Build 4.11.8)
#
#########################################################################
tcl;

eval {
   if {[info host] == "MOSTERMAN2K" } {
      source "c:/Program Files/TclPro1.3/win32-ix86/bin/prodebug.tcl"
      set cmd "debugger_eval"
      set xxx [debugger_init]
   } else {
      set cmd "eval"
   }
}
$cmd {

   proc pWriteToFile { sOutStr } {
      global sWriteToFile
      append sWriteToFile "\n$sOutStr"
   }
      
################################################################################
#                   Business Objects
################################################################################

   proc pGet_BOAdmin { sList } {
   
      global sDumpSchemaDirObjects sDumpSchemaDirForms oID sPSType sPSName sPSRev sWriteToFile bIsTemplate fname
      set fname "bo_$sPSType-$sPSName-$sPSRev"
      set p_filename "$sDumpSchemaDirObjects/$fname\.xls"
      
      foreach sList1 $sList {
         set sValue1 "$sList1"
         puts "Start backup of Business Object $sList1 ..."
         set lsTNRBO ""
         set lsBusObj ""

#
# WRITE HEADER INFO INTO OUTPUT FILE.
#
         set sOutstr ""
         switch $sList1 {
            "Technical Specification" {
               set sOutstr [split [mql print bus "$sPSType" "$sPSName" "$sPSRev" select name revision policy current vault owner description attribute.value dump ^] ^]
               set sOutstr [join [concat [list "$sPSType" "$sPSName" "$sPSRev"] $sOutstr] \t]
               set sTest [join [lrange [split "$sOutstr" "\t"] 0 2] |]
               if {[lsearch $lsTNRBO "$sTest"] < 0} {
                  set sAttr1  [ mql print type "$sPSType" select attribute dump "\t" ]
                  set sWriteToFile "Type\tName\tRev\t\t\tPolicy\tState\tVault\tOwner\tdescription\t$sAttr1\t<HEADER>"
                  pWriteToFile "$sOutstr"
                  set lsFile [split [mql print bus "$sPSType" "$sPSName" "$sPSRev" select format.file.name dump |] |]
                  set lsFormat [split [mql print bus "$sPSType" "$sPSName" "$sPSRev" select format.file.format dump |] |]
                  foreach sFile $lsFile sFormat $lsFormat {
                     mql checkout bus "$sPSType" "$sPSName" "$sPSRev" server file $sFile "$sDumpSchemaDirObjects/Files"
                     file rename -force "$sDumpSchemaDirObjects/Files/$sFile" "$sDumpSchemaDirObjects/Files/$sPSType~~$sPSName~~$sPSRev~~$sFormat~~$sFile"
                  }
               }
               set lsTechSpec [split [mql expand bus "$sPSType" "$sPSName" "$sPSRev" rel BOS from recurse to all select bus name revision policy current vault owner description attribute.value dump ^] \n]
               set lsTechSpec [lsort $lsTechSpec]
               set sCurrentType ""
               foreach slsTechSpec $lsTechSpec {
                  set sTest [join [lrange [split $slsTechSpec ^] 3 5] |]
                  if {[lsearch $lsTNRBO $sTest] < 0} {
                     set sTSType [lindex [split $slsTechSpec ^] 3]
                     set sTSName [lindex [split $slsTechSpec ^] 4]
                     set sTSRev [lindex [split $slsTechSpec ^] 5]
                     set sOutstr [join [lrange [split "$slsTechSpec" ^] 3 end] "\t"]
                     lappend lsTNRBO "$sTest"
                     if {$sTSType != $sCurrentType} {
                        set sAttr1  [ mql print type "$sTSType" select attribute dump "\t" ]
                        pWriteToFile "Type\tName\tRev\t\t\tPolicy\tState\tVault\tOwner\tdescription\t$sAttr1\t<HEADER>"
                        set sCurrentType $sTSType
                     }
                     pWriteToFile "$sOutstr"
                     set lsFile [split [mql print bus "$sTSType" "$sTSName" "$sTSRev" select format.file.name dump |] |]
                     set lsFormat [split [mql print bus "$sTSType" "$sTSName" "$sTSRev" select format.file.format dump |] |]
                     foreach sFile $lsFile sFormat $lsFormat {
                        mql checkout bus "$sTSType" "$sTSName" "$sTSRev" server file $sFile "$sDumpSchemaDirObjects/Files"
                        file rename -force "$sDumpSchemaDirObjects/Files/$sFile" "$sDumpSchemaDirObjects/Files/$sTSType~~$sTSName~~$sTSRev~~$sFormat~~$sFile"
                     }
                  }
               }
               if {$bIsTemplate} {
                  set lsWebFormName ""
                  foreach sAttr3 [list "Specification View Form Name" "Properties Form Name" "Properties Template Form Name"] {
                     set sWebFormName [mql print bus "$sPSType" "$sPSName" "$sPSRev" select attribute\[$sAttr3\] dump]
                     if {$sWebFormName != ""} {lappend lsWebFormName $sWebFormName}
                  }
                  if {$lsWebFormName != ""} {
                     pDumpWebForm $lsWebFormName
                     pDumpWebFormField $lsWebFormName
                  }
               }

            } Characteristic {
               set lsTechSpec1 [list "|||$sPSType|$sPSName|$sPSRev|[mql print bus "$sPSType" "$sPSName" "$sPSRev" select id dump]"]
               set lsTechSpec2 [split [mql expand bus "$sPSType" "$sPSName" "$sPSRev" rel BOS from recurse to all select bus id dump |] \n]
               set lsTechSpec [concat $lsTechSpec1 $lsTechSpec2]
               set lsChar [split [mql print type Characteristic select derivative dump |] |]
               foreach sChar $lsChar {
                  set sOutstr ""
                  foreach sTechSpec $lsTechSpec {
                     set oCharID [lindex [split $sTechSpec |] 6]
                     set sOutstrTemp [mql expand bus $oCharID rel Characteristic from select bus name revision policy current vault owner description attribute.value where "type == '$sChar'" dump ^]
                     if {$sOutstrTemp != ""} {
                        set lsOutstrTemp [split "$sOutstrTemp" \n]
                        foreach slsOutstrTemp $lsOutstrTemp {
                           set sTest [join [lrange [split "$slsOutstrTemp" ^] 3 5] |]
                           if {[lsearch $lsTNRBO $sTest] < 0} { 
                              lappend sOutstr [join [lrange [split "$slsOutstrTemp" ^] 3 end] "\t"]
                              lappend lsTNRBO $sTest
                           }
                        }
                     }
                  }
                  if {$sOutstr != ""} {
                     set sAttr1  [mql print type $sChar select attribute dump "\t"]
                     pWriteToFile "Type\tName\tRev\tChange Name\tChange Rev\tPolicy\tState\tVault\tOwner\tdescription\t$sAttr1\t<HEADER>"
                     pWriteToFile "[join "$sOutstr" "\n"]"
                  }
               }
                  
            } "Specification Section" {
               set sOutstr ""
               set lsOutstrTemp [split [mql expand bus $oID rel "Specification Section" from select bus name revision policy current vault owner description attribute.value dump ^] \n]
               if {$lsOutstrTemp != ""} {
                  foreach sOutstrTemp $lsOutstrTemp {
                     set sTest [join [lrange [split "$sOutstrTemp" ^] 3 5] |]
                     if {[lsearch $lsTNRBO $sTest] < 0} { 
                        if {[lindex [split $sTest |] 1] != "Global Header Section"} {
                           lappend sOutstr [join [lrange [split "$sOutstrTemp" ^] 3 end] "\t"]
                        }
                        lappend lsTNRBO $sTest
                     }
                  }
               }
               if {$sOutstr != ""} {
                  set sAttr1  [mql print type "Specification Section" select attribute dump \t]
                  pWriteToFile "Type\tName\tRev\tChange Name\tChange Rev\tPolicy\tState\tVault\tOwner\tdescription\t$sAttr1\t<HEADER>"
                  pWriteToFile "[join "$sOutstr" \n]"
               }
                  
            } Part {
               set lsTechSpec [split [mql expand bus "$sPSType" "$sPSName" "$sPSRev" rel BOS from recurse to all select bus id dump |] \n]
               set lsTechSpec [linsert $lsTechSpec 0 "|||$sPSType|$sPSName|$sPSRev|[mql print bus "$sPSType" "$sPSName" "$sPSRev" select id dump]"]
               set sOutstr ""
               foreach sTechSpec $lsTechSpec {
                  set oTSID [lindex [split $sTechSpec |] 6]
                  set sOutstrTemp [mql expand bus $oTSID rel "Part Specification" to select bus name revision policy current vault owner description attribute.value dump ^]
                  if {$sOutstrTemp != ""} {
                     set sTest [join [lrange [split "$sOutstrTemp" ^] 3 5] |]
                     if {[lsearch $lsTNRBO $sTest] < 0} { 
                        lappend sOutstr [join [lrange [split "$sOutstrTemp" ^] 3 end] "\t"]
                        lappend lsTNRBO $sTest
                     }
                  }
               }
               if {$sOutstr != ""} {
                  set sAttr1  [mql print type Part select attribute dump \t]
                  pWriteToFile "Type\tName\tRev\tChange Name\tChange Rev\tPolicy\tState\tVault\tOwner\tdescription\t$sAttr1\t<HEADER>"
                  pWriteToFile "[join "$sOutstr" \n]"
               }
                  
            } "Project Space" {
               set lsPS [split [lindex [split [mql expand bus $oID rel "Project Space To Design" to select bus id dump |] \n] 0] |]
               set sPSpaceType [lindex $lsPS 3]
               set sPSpaceName [lindex $lsPS 4]
               set sPSpaceRev [lindex $lsPS 5]
               mql set env TECHSPEC TRUE
               mql exec prog Method_DumperProjectSpace.tcl "$sPSpaceType" "$sPSpaceName" "$sPSpaceRev"

            } "Document" {
               set lsDoc [split [mql expand bus $oID rel "Reference Document" from select bus id dump |] \n]
               set lsDocument ""
               foreach slsDoc $lsDoc {
                  set lslsDoc [split $slsDoc |]
                  set sDocType [lindex $lslsDoc 3]
                  set sDocName [lindex $lslsDoc 4]
                  set sDocRev [lindex $lslsDoc 5]
                  set oDocID [lindex $lslsDoc 6]
                  lappend lsDocument "$sDocType|$sDocName|$sDocRev|$oDocID"
               }
#               mql exec prog Method_DumperDocument.tcl $lsDocument
            }
         }
      }
      set p_file [open "$p_filename" w]
      puts $p_file $sWriteToFile
      close $p_file
   }
   
#############################################################################
#  Relationships
#############################################################################

   proc pGet_BOAdminRel {lsRel} {
   
      global sDumpSchemaDirRelationships oID sPSType sPSName sPSRev
      
      set fname "rel_$sPSType-$sPSName-$sPSRev"
      set p_filename "$sDumpSchemaDirRelationships/$fname\.xls"
      set lsTNRBR ""
      set lsBusRel ""
      set p_file [open "$p_filename" w]
      set lsTechSpec1 [list "|||$sPSType|$sPSName|$sPSRev|[mql print bus "$sPSType" "$sPSName" "$sPSRev" select id dump]"]
      set lsTechSpec2 [split [mql expand bus "$sPSType" "$sPSName" "$sPSRev" rel BOS from recurse to all select bus id dump |] \n]
      set lsTechSpec [concat $lsTechSpec1 $lsTechSpec2]
      set lsQuery ""
      set lsChar ""
      set lsCharDerivative [split [mql print type Characteristic select derivative dump |] |]
      
      foreach slsTechSpec $lsTechSpec {
         set lslsTechSpec [split $slsTechSpec |]
         set sTSType [lindex $lslsTechSpec 3]
         set sTSName [lindex $lslsTechSpec 4]
         set sTSRev [lindex $lslsTechSpec 5]
         set oTSID [lindex $lslsTechSpec 6]
         lappend lsQuery "$sTSType|$sTSName|$sTSRev|$oTSID"
      }
      
      foreach sRel $lsRel {
         puts "Start backup of Business Object Relation $sRel ..."
         set sDirection to
         set sDir from
         if {$sRel == "Characteristic" || $sRel == "BOS" || $sRel == "Specification Section"} {
            set sDirection from
            set sDir to
         }
         set sAttr1  [ mql print relationship "$sRel" select attribute dump \t ]
         if { "$sAttr1" == "" } {
            set sHeader "FromType\tFromName\tFromRev\tToType\tToName\tToRev\tDirection\tRelationship\t<HEADER>"
         } else {
            set sHeader "FromType\tFromName\tFromRev\tToType\tToName\tToRev\tDirection\tRelationship\t$sAttr1\t<HEADER>"
         }        	
         
         set lBos ""
         foreach slsQuery $lsQuery { 
            set lslsQuery [split $slsQuery |] 
            set sFromType [lindex $lslsQuery 0]
            set sFromName [lindex $lslsQuery 1]
            set sFromRev [lindex $lslsQuery 2]
            set oFromID [lindex $lslsQuery 3]
            
            if { "$sAttr1" == "" } {
               set sExpand  [ split [ mql expand bus "$sFromType" "$sFromName" "$sFromRev" relationship "$sRel" $sDirection dump |  ] \n ]
               foreach sExpand1 $sExpand { 
                  set lsLine2       [split "$sExpand1" "|" ] 
                  set sToType       [ string trim [ lindex "$lsLine2" 3 ] ]
                  set sToName       [ string trim [ lindex "$lsLine2" 4 ] ]
                  set sToRev        [ string trim [ lindex "$lsLine2" 5 ] ]
                  set sTNRBR "$sFromType|$sFromName|$sFromRev|$sToType|$sToName|$sToRev|$sDir|$sRel"
                  if {[lsearch $lsTNRBR $sTNRBR] < 0} {
                     lappend lBos "$sFromType\t$sFromName\t$sFromRev\t$sToType\t$sToName\t$sToRev\t$sDir\t$sRel"
                     lappend lsTNRBR $sTNRBR
                     if {$sRel == "Characteristic"} {
                        set lsExpand2 [split [mql expand bus "$sToType" "$sToName" "$sToRev" from dump |] \n]
                        foreach slsExpand2 $lsExpand2 {
                           set sToCharType [lindex [split $slsExpand2 |] 3]
                           if {[lsearch $lsCharDerivative $sToCharType] >= 0} {  
                              set sToCharName [lindex [split $slsExpand2 |] 4]
                              set sToCharRev [lindex [split $slsExpand2 |] 5]
                              set sCharRel [lindex [split $slsExpand2 |] 1]
                              set slsChar "$sCharRel|$sToType|$sToName|$sToRev|$sToCharType|$sToCharName|$sToCharRev"
                              if {[lsearch $lsChar $slsChar] <= 0} {
                                 lappend lsChar $slsChar
                              }
                           }
                        }
                     }
                  }
               }
            } else {
               set sExpand  [ split [ mql expand bus "$sFromType" "$sFromName" "$sFromRev" relationship "$sRel" $sDirection select relationship attribute.value dump | ] \n ]
               foreach sExpand1 $sExpand { 
                  set lsLine2       [split "$sExpand1" "|" ] 
                  set sToType       [ string trim [ lindex "$lsLine2" 3 ] ]
                  set sToName       [ string trim [ lindex "$lsLine2" 4 ] ]
                  set sToRev        [ string trim [ lindex "$lsLine2" 5 ] ]
                  set A1            [ lrange  "$lsLine2" 6 end ]
                  set A3            ""
                  				
                  foreach A2 $A1 {
                     append A3 "\t$A2"
                  }
                  					
                  set sTNRBR "$sFromType|$sFromName|$sFromRev|$sToType|$sToName|$sToRev|$sDir|$sRel"
                  if {[lsearch $lsTNRBR $sTNRBR] < 0} {
                     lappend lBos "$sFromType\t$sFromName\t$sFromRev\t$sToType\t$sToName\t$sToRev\t$sDir\t$sRel$A3"
                     lappend lsTNRBR $sTNRBR
                     if {$sRel == "Characteristic"} {
                        set lsExpand2 [split [mql expand bus "$sToType" "$sToName" "$sToRev" from dump |] \n]
                        foreach slsExpand2 $lsExpand2 {
                           set sToCharType [lindex [split $slsExpand2 |] 3]
                           if {[lsearch $lsCharDerivative $sToCharType] >= 0} {  
                              set sToCharName [lindex [split $slsExpand2 |] 4]
                              set sToCharRev [lindex [split $slsExpand2 |] 5]
                              set sCharRel [lindex [split $slsExpand2 |] 1]
                              set slsChar "$sCharRel|$sToType|$sToName|$sToRev|$sToCharType|$sToCharName|$sToCharRev"
                              if {[lsearch $lsChar $slsChar] <= 0} {
                                 lappend lsChar $slsExpand2
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         if {$lBos != ""} {
            puts $p_file "$sHeader"
            puts $p_file "[join $lBos \n]"
         }
      }
      
      set lsChar [lsort $lsChar]
      set sRelPrev ""
      set sAttr ""
      foreach slsChar $lsChar {
         set lslsChar [split $slsChar |]
         set sRel [lindex $lslsChar 0]
         set sFromType [lindex $lslsChar 1]
         set sFromName [lindex $lslsChar 2]
         set sFromRev [lindex $lslsChar 3]
         set sToType [lindex $lslsChar 4]
         set sToName [lindex $lslsChar 5]
         set sToRev [lindex $lslsChar 6]
         if {$sRel != $sRelPrev} {
            set sAttr  [ mql print relationship "$sRel" select attribute dump \t ]
            if { "$sAttr" == "" } {
               puts $p_file "FromType\tFromName\tFromRev\tToType\tToName\tToRev\tDirection\tRelationship\t<HEADER>"
            } else {
               puts $p_file "FromType\tFromName\tFromRev\tToType\tToName\tToRev\tDirection\tRelationship\t$sAttr\t<HEADER>"
            }
            set sRelPrev $sRel
         }
         if { "$sAttr" == "" } {
            puts $p_file "$sFromType\t$sFromName\t$sFromRev\t$sToType\t$sToName\t$sToRev\tto\t$sRel"
         } else {
            set sAttrValue [mql print connection bus "$sFromType" "$sFromName" "$sFromRev" to "$sToType" "$sToName" "$sToRev" rel "$sRel" select attribute.value dump \t]
            puts $p_file "$sFromType\t$sFromName\t$sFromRev\t$sToType\t$sToName\t$sToRev\tto\t$sRel\t$sAttrValue"
         }
      }

      close $p_file
   }

#############################################################################
#  WebForms
#############################################################################

   proc pDumpWebForm {lsWebFormName} {
      global sDumpSchemaDirForms fname
      regsub "bo_" $fname "" f_filename
      set sPath "$sDumpSchemaDirForms/SpinnerWebFormData_$f_filename.xls"
      set lsPropertyName ""
      catch {set lsPropertyName [split [mql print program eServiceSchemaVariableMapping.tcl select property.name dump |] |]} sMsg
      set sTypeReplace "form "
   
      foreach sPropertyName $lsPropertyName {
         set sSchemaTest [lindex [split $sPropertyName "_"] 0]
         if {$sSchemaTest == "form"} {
            set sPropertyTo [mql print program eServiceSchemaVariableMapping.tcl select property\[$sPropertyName\].to dump]
            regsub $sTypeReplace $sPropertyTo "" sPropertyTo
            regsub "_" $sPropertyName "|" sSymbolicName
            set sSymbolicName [lindex [split $sSymbolicName |] 1]
            array set aSymbolic [list $sPropertyTo $sSymbolicName]
         }
      }
   
      set sFile "Name\tRegistry Name\tDescription\tField Names (in order-use \"|\" delim)\tHidden (boolean)\tTypes (use \"|\" delim)\n"
      foreach sWebFormName $lsWebFormName {
         set sOrigName ""
         catch {set sOrigName $aSymbolic($sWebFormName)} sMsg
         regsub -all " " $sWebFormName "" sOrigNameTest
         if {$sOrigNameTest == $sOrigName} {
            set sOrigName $sWebFormName
         }
         set sDescription [mql print form $sWebFormName select description dump]
         set slsType [mql print form $sWebFormName select type dump " | "]
         set sHidden [mql print form $sWebFormName select hidden dump]
         set slsField [mql print form $sWebFormName select field dump " | "]
         append sFile "$sWebFormName\t$sOrigName\t$sDescription\t$slsField\t$sHidden\t$slsType\n"
      }
      set iFile [open $sPath w]
      puts $iFile $sFile
      close $iFile
   }
   
#############################################################################
#  WebFormFields
#############################################################################

   proc pDumpWebFormField {lsWebFormName} {
      global sDumpSchemaDirForms fname
      regsub "bo_" $fname "" f_filename
      set sPath "$sDumpSchemaDirForms/SpinnerWebFormFieldData_$f_filename.xls"
      set sFile "WebForm Name\tField Name\tField Label\tField Description\tExpression Type (bus or \"\" / rel)\tExpression\tHref\tSetting Names (use \"|\" delim)\tSetting Values (use \"|\" delim)\tUsers (use \"|\" delim)\tAlt\tRange\tUpdate\tField Order\n"
      foreach sForm $lsWebFormName {
         set lsField [split [mql print form $sForm] \n]
         set bField FALSE
         set iCounter 1
         foreach sField $lsField {
            set sField [string trim $sField]
            if {[string range $sField 0 5] == "field#"} {
               set bField TRUE
               set sName ""
               set sLabel ""
               set sDescription ""
               set sExpressionType ""
               set sExpression ""
               set sHref ""
               set sAlt ""
               set sRange ""
               set sUpdate ""
               set lsSettingName ""
               set lsSettingValue ""
               set lsUser ""
               set iFieldOrder $iCounter
               incr iCounter
               set iSelect [string first "select" $sField]
               if {$iSelect >= 0} {
                  set sExpression [string range $sField [expr $iSelect + 7] end]
               }
            } elseif {$bField} {
               if {$sField == ""} {
                  set slsSettingName [join $lsSettingName " | "]
                  set slsSettingValue [join $lsSettingValue " | "]
                  set slsUser [join $lsUser " | "]
                  append sFile "$sForm\t$sName\t$sLabel\t$sDescription\t$sExpressionType\t$sExpression\t$sHref\t$slsSettingName\t$slsSettingValue\t$slsUser\t$sAlt\t$sRange\t$sUpdate\t$iFieldOrder\n"
               } else {
                  regsub " " $sField "^" sFieldTemp
                  set lsFieldTemp [split $sFieldTemp ^]
                  set sChoice [lindex $lsFieldTemp 0]
                  set sValue [string trim [lindex $lsFieldTemp 1]]
                  switch $sChoice {
                     expressiontype {
                        set sExpressionType $sValue
                     } name {
                        set sName $sValue
                     } label {
                        set sLabel $sValue
                     } href {
                        set sHref $sValue
                     } alt {
                        set sAlt $sValue
                     } range {
                        set sRange $sValue
                     } update {
                        set sUpdate $sValue
                     } description {
                        set sDescription $sValue
                     } user {
                        lappend lsUser $sValue
                     } setting {
                        regsub " value " $sValue "^" sValue
                        set lsValue [split $sValue ^]
                        lappend lsSettingName [lindex $lsValue 0]
                        lappend lsSettingValue [lindex $lsValue 1]
                     }
                  }
               }
            }
         }
      }
      set iFile [open $sPath w]
      puts $iFile $sFile
      close $iFile
   }

   # end of procedures

   set oID [mql get env OBJECTID]
   set sPSType [mql get env TYPE]
   set sPSName [mql get env NAME]
   set sPSRev [mql get env REVISION]
   set sSpinnerPath [mql get env SPINNERPATHBO]
   set bIsTemplate [mql print bus $oID select attribute\[Is Template\] dump]
   
   if {$sSpinnerPath == ""} {
   set sOS [string tolower $tcl_platform(os)];
   set sSuffix [clock format [clock seconds] -format "%Y%m%d"]
   
   if { [string tolower [string range $sOS 0 5]] == "window" } {
   set sSpinnerPath "c:/temp/SpinnerAgent$sSuffix";
   } else {
   set sSpinnerPath "/tmp/SpinnerAgent$sSuffix";
   }
   file mkdir $sSpinnerPath
   }
   set sDumpSchemaDirForms [ file join $sSpinnerPath Business ]
   file mkdir $sDumpSchemaDirForms
   set sDumpSchemaDirObjects [ file join $sSpinnerPath Objects ]
   file mkdir $sDumpSchemaDirObjects
   file mkdir "$sDumpSchemaDirObjects/Files"
   set sDumpSchemaDirRelationships [ file join $sSpinnerPath Relationships ]
   file mkdir $sDumpSchemaDirRelationships
   
   if {$bIsTemplate} {
      set thelist [ list "Technical Specification" "Specification Section" "Characteristic" ]
      pGet_BOAdmin $thelist
   
      set thelist [ list "Business Unit Owns" "Region Owns" "Specification Section" "Specification Template" "Assigned To Specification Office" ]
      pGet_BOAdminRel $thelist
   } else {
      set thelist [list "Technical Specification" "Characteristic" "Part" "Project Space" "Document"]
      pGet_BOAdmin $thelist

      set thelist [list "BOS" "Business Unit Owns" "Region Owns" "CoOwned" "Originating Specification Template" "Assigned To Specification Office" "Characteristic" "Part Specification" "Project Space To Design" "Recommended Suppliers" "Reference Document"]
      pGet_BOAdminRel $thelist
   }
   
   mql notice "Files loaded in directory: $sSpinnerPath"   
}

