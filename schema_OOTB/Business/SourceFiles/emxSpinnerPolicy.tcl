
#########################################################################*2012
#
# @progdoc      emxSpinnerPolicy.tcl vM2012 (Build 11.10.1)
#
# @Description: Procedures for running in Policies
#
# @Parameters:  Returns 0 if successful, 1 if not
#
# @Usage:       Utilized by emxSpinnerAgent.tcl
#
# @progdoc      Copyright (c) ENOVIA Inc. 2005
#
#########################################################################
#
# @Modifications: See SchemaAgent_ReadMe.htm
#
#########################################################################

# Procedure to analyze policies
proc pAnalyzePolicy {} {
   global aCol aDat aSymbolicRef bOverlay bAdd lsTypePlan lsTypeActual lsTypeRetain slsTypeRetain lsFormatPlan lsFormatActual lsStatePlan lsStateActual lsStateRef lsSymbolicPlan lsSymbolicActual lsSymbolicRef lsSchemaType bRetainBusObject bScan sMxVersion bMm
   regsub -all "continue" $aCol(3) "..." aCol(3)
# Major/Minor Mod - ION - 10/1/2012
   if {$bMm} {
      if {$aCol(3) != "" && $aCol(13) == ""} {
	     set aCol(13) $aCol(3)
	  } else {
	     regsub -all "continue" $aCol(13) "..." aCol(13)
      }
      regsub -all "continue" $aCol(14) "..." aCol(14)
   }  
   set lsTypePlan [pTrimList $aCol(6)]
   if {[lsearch $lsSchemaType type] >= 0} {set lsTypePlan [pCheckNameChange $lsTypePlan type]}
   set lsFormatPlan [pTrimList $aCol(7)]
   if {[lsearch $lsSchemaType format] >= 0} {set lsFormatPlan [pCheckNameChange $lsFormatPlan format]}
   if {$aCol(8) != ""} {set aCol(8) [pCheckNameChange $aCol(8) format]}
   set aCol(9) [pCompareAttr $aCol(9) notenforce enforce true true]
   set lsStatePlan [pTrimList $aCol(10)]
   set lsStateOrig [pTrimList $aCol(11)]
   set lsSymbolicPlan ""
   foreach sStateOrig $lsStateOrig {
      regsub -all " " $sStateOrig "" sStateOrig
      if {$sStateOrig == ""} {
         lappend lsSymbolicPlan ""
      } else {
         set sSymbolicPlan "state_$sStateOrig"
         lappend lsSymbolicPlan $sSymbolicPlan
      }
   }
   foreach sValue [list lsTypeActual lsFormatActual lsStateActual lsSymbolicActual lsStateRef lsSymbolicRef lsTypeRetain] {
      set "$sValue" [list ]
   }
   if {$bAdd != "TRUE"} {
# Major/Minor Mod - ION - 10/1/2012
      if {$bMm} {
         foreach iDat [list 4 8 13 14 15] sProperty [list store defaultformat minorsequence majorsequence delimiter] {set aDat($iDat) [pPrintQuery "" $sProperty "" ""]}
	  } else {
      foreach iDat [list 3 4 8] sProperty [list revision store defaultformat] {set aDat($iDat) [pPrintQuery "" $sProperty "" ""]}
	  }
      set bEnforceActual [pPrintQuery "" islockingenforced "" ""]
      set aDat(9) [pCompareAttr $bEnforceActual notenforce enforce true false]
      set lsTypeActual [pPrintQuery "" type | spl]
      set lsFormatActual [pPrintQuery "" format | spl]
      set lsStateActual [pPrintQuery "" state | spl]
      set lsStateRef [pPrintQuery "" property.value | spl]
      set lsSymbolicRef [pPrintQuery "" property.name | spl]
      foreach sStateRef $lsStateRef sSymbolicRef $lsSymbolicRef {
         if {[string range $sSymbolicRef 0 5] == "state_"} {
      	     set aSymbolicRef($sSymbolicRef) $sStateRef
      	     set aRevSymbolicRef($sStateRef) $sSymbolicRef
      	  }
      }
      foreach sStateActual $lsStateActual {
      	  set iState [lsearch $lsStateRef $sStateActual]
      	  if {$iState >= 0 && [string range [lindex $lsSymbolicRef $iState] 0 5] == "state_"} {
      	     lappend lsSymbolicActual [lindex $lsSymbolicRef $iState]
      	  } else {
      	     lappend lsSymbolicActual ""
      	  }
      }
      if {$sMxVersion >= 10.8} {set aDat(12) [pPrintQuery "FALSE" allstate "" ""]}
   }
   if {$bOverlay} {
      if {$sMxVersion >= 10.8} {
# Major/Minor Mod - ION - 10/1/2012
	     if {$bMm} {
            pOverlay [list 4 8 9 12 13 14 15]
		 } else {
         pOverlay [list 3 4 8 9 12]
		 }
      } else {
         pOverlay [list 3 4 8 9]
      }
      set lsTypePlan [pOverlayList $lsTypePlan $lsTypeActual]
      set lsFormatPlan [pOverlayList $lsFormatPlan $lsFormatActual]
      if {$lsStatePlan == "<NULL>"} {
         set lsStatePlan [list ]
         set lsSymbolicPlan [list ]
      } elseif {$bAdd != "TRUE" && $lsStatePlan == ""} {
         set lsStatePlan $lsStateActual
         set lsSymbolicPlan $lsSymbolicActual
      } else {
               set lsTemp [pMergeList $lsStatePlan $lsSymbolicPlan $lsStateActual $lsSymbolicActual STATE]
               set lsStatePlan [lindex $lsTemp 0]
               set lsSymbolicPlan [lindex $lsTemp 1]
      }
   }
   if {$bAdd != "TRUE" && $bRetainBusObject && $bScan != "TRUE"} {
      foreach sTypeActual $lsTypeActual {if {[lsearch $lsTypePlan $sTypeActual] > -1} {lappend lsTypeRetain $sTypeActual}}
      set slsTypeRetain [join $lsTypeRetain ,]
   }
}                                       

# Procedure to process policies
proc pProcessPolicy {} {
   global aCol aDat aSymbolicRef bAdd lsTypePlan lsTypeActual lsTypeRetain slsTypeRetain lsFormatPlan lsFormatActual lsStatePlan lsStateActual lsStateRef lsSymbolicPlan lsSymbolicActual lsSymbolicRef sHidden sHiddenActual lsSchemaType sSpinDir aSchemaTitle bRetainBusObject iBusObjCommit bScan slsVault sLogFileDir bOut sMxVersion bMm resultappend
   if {$bAdd} {
# Major/Minor Mod - ION - 10/1/2012
      if {$bMm} {
         set aCol(13) [pRegSubEvalEscape $aCol(13)]
         set aCol(14) [pRegSubEvalEscape $aCol(14)]
		 if {$aCol(13) != "" && $aCol(14) != ""} {
            pMqlCmd "escape add policy \042$aCol(0)\042 minorsequence '$aCol(13)' majorsequence '$aCol(14)' delimiter $aCol(15) $sHidden $aCol(9)"
		 } elseif {$aCol(14) == ""} {
            pMqlCmd "escape add policy \042$aCol(0)\042 minorsequence '$aCol(13)' $sHidden $aCol(9)"
		 } else {
            pMqlCmd "escape add policy \042$aCol(0)\042 majorsequence '$aCol(14)' $sHidden $aCol(9)"
		 }
      } else {
      set aCol(3) [pRegSubEvalEscape $aCol(3)]
      pMqlCmd "escape add policy \042$aCol(0)\042 sequence '$aCol(3)' $sHidden $aCol(9)"
	  }
      pPlanAdd $lsTypePlan policy $aCol(0) "add type" ""
      pPlanAdd $lsFormatPlan policy $aCol(0) "add format" ""
      pPlanAdd $lsStatePlan policy $aCol(0) "add state" ""
      if {$aCol(8) != ""} {pMqlCmd "mod policy \042$aCol(0)\042 defaultformat \042$aCol(8)\042"}
      if {$aCol(4) != ""} {pMqlCmd "mod policy \042$aCol(0)\042 store \042$aCol(4)\042"}
      if {$sMxVersion >= 10.8 && $aCol(12) == "TRUE"} {pMqlCmd "mod policy \042$aCol(0)\042 add allstate"}
      foreach sSymbolicPlan $lsSymbolicPlan sState $lsStatePlan {if {$sSymbolicPlan != ""} {pMqlCmd "add property \042$sSymbolicPlan\042 on policy \042$aCol(0)\042 value \042$sState\042"}}
   } else {
# Major/Minor Mod - ION - 10/1/2012
      if {$bMm} {
	     if {$aCol(13) != $aDat(13) || $aCol(14) != $aDat(14) || $sHidden != $sHiddenActual || $aCol(9) != $aDat(9)} {
            if {$aCol(13) != ""} {set aCol(13) [pRegSubEvalEscape $aCol(13)]}
            if {$aCol(14) != ""} {set aCol(14) [pRegSubEvalEscape $aCol(14)]}
            pMqlCmd "escape mod policy \042$aCol(0)\042 minorsequence '$aCol(13)' majorsequence '$aCol(14)' $sHidden $aCol(9)"
	     }
      } else {		 
      if {$aCol(3) != $aDat(3) || $sHidden != $sHiddenActual || $aCol(9) != $aDat(9)} {
         set aCol(3) [pRegSubEvalEscape $aCol(3)]
         pMqlCmd "escape mod policy \042$aCol(0)\042 sequence '$aCol(3)' $sHidden $aCol(9)"
      }
	  }
      if {$aCol(4) == "" && $aDat(4) != ""} {
         set resultappend "ERROR: Policy '$aCol(0)' store '$aDat(4)' may not be changed back to <null> once set!"
         return 1
      } elseif {$aCol(4) != $aDat(4)} {
         pMqlCmd "mod policy \042$aCol(0)\042 store \042$aCol(4)\042"
      }
      pPlanActualAddDel $lsTypeActual "" $lsTypePlan policy "" $aCol(0) "remove type" "add type" ""
      pPlanActualAddDel $lsFormatActual "" $lsFormatPlan policy "" $aCol(0) "remove format" "add format" ""
      if {$aCol(8) == "" && $aDat(8) != ""} {
         set resultappend "ERROR: Policy '$aCol(0)' default format '$aDat(8)' may not be set to <null> once set!"
         return 1
      } elseif {$aCol(8) != $aDat(8)} {
         pMqlCmd "mod policy \042$aCol(0)\042 defaultformat \042$aCol(8)\042"
      }
      if {$sMxVersion >= 10.8 && $aCol(12) != "" && $aCol(12) != $aDat(12)} {
         if {$aCol(12) == "TRUE"} {
            pMqlCmd "mod policy \042$aCol(0)\042 add allstate"
         } else {
            pMqlCmd "mod policy \042$aCol(0)\042 remove allstate"
         }
      }
      set bChange FALSE
      set bRename FALSE

      if {$lsStatePlan == $lsStateActual && $lsSymbolicPlan != $lsSymbolicActual} {
# Rename state symbolic names only - ION 10/26/09
         foreach sSymbolicActual $lsSymbolicActual {
# JD le 29/11/12 : correction du test --> Ajout : $sSymbolicActual != ""
            if {[mql print policy "$aCol(0)" select property\[$sSymbolicActual\] dump] != "" && $sSymbolicActual != ""} {
            pMqlCmd "delete property \042$sSymbolicActual\042 on policy \042$aCol(0)\042"
         }
         }
         foreach sState $lsStatePlan sSymbolicPlan $lsSymbolicPlan {
            pMqlCmd "add property \042$sSymbolicPlan\042 on policy \042$aCol(0)\042 value \042$sState\042"
         }            
      } else {
# Rename states
         foreach sStatePlan $lsStatePlan sSymbolicPlan $lsSymbolicPlan {
            if {[catch {
               if {$sStatePlan != $aSymbolicRef($sSymbolicPlan)} {
                  set sTemp ""
                  if {[lsearch $lsStateActual $sStatePlan] >= 0} {
                     set sTemp "TEMP_"
                     set bRename TRUE
                  }
                  pMqlCmd "mod policy \042$aCol(0)\042 state \042$aSymbolicRef($sSymbolicPlan)\042 name \042$sTemp$sStatePlan\042"
               }
            } sMsg]== 0 } {
               set bChange TRUE
            }
         }
         if {$bRename} {
            set lsStateActual [pPrintQuery "" state | spl]
            foreach sStateA $lsStateActual {
            	if {[string first "TEMP_" $sStateA] == 0} {
            	   regsub "TEMP_" $sStateA "" sRename
                  pMqlCmd "mod policy \042$aCol(0)\042 state \042$sStateA\042 name \042$sRename\042"
               }
            }
         }                                         	   
         if {$bChange} {set lsStateActual [pPrintQuery "" state | spl]}
# Remove states not in plan sequence and retain bus objects with states reordered
         set lsStateReorder ""
         set bQuery TRUE
         set iCtrA 0
         for {set iCtrP 0} {$iCtrP < [llength $lsStatePlan]} {incr iCtrP} {
            set sStateP [lindex $lsStatePlan $iCtrP]
            set sStateA [lindex $lsStateActual $iCtrA]
            if {$sStateA != ""} {
               if {$sStateP != $sStateA} {
                  if {[lsearch $lsStatePlan $sStateA] < 0} {
                     pMqlCmd "mod policy \042$aCol(0)\042 remove state \042$sStateA\042"
                     incr iCtrP -1
                  } elseif {[lsearch $lsStateActual $sStateP] >= 0} {
                     if {$bRetainBusObject && $bScan != "TRUE"} {
                        set aBusObject($sStateP) ""
                        if {$bQuery} {
                           puts -nonewline "\nRetain bus object current state option activated: querying database..."
                           mql temp query bus "$slsTypeRetain" * * vault "$slsVault" select id current policy dump | output "$sLogFileDir/BusObjectQuery.txt"
                           set bQuery FALSE
                        }
                        set iBOQuery [open "$sLogFileDir/BusObjectQuery.txt" r]
                        set slsBusObject [gets $iBOQuery]
                        set iBOCounter 0
                        while {$slsBusObject != ""} {
                           incr iBOCounter
                           set lslsBusObject [split $slsBusObject |]
                           if {[lindex $lslsBusObject 4] == $sStateP && [lindex $lslsBusObject 5] == $aCol(0)} {lappend aBusObject($sStateP) [lindex $lslsBusObject 3]}
                           set slsBusObject [gets $iBOQuery]
                        }
                        close $iBOQuery
                        if {$aBusObject($sStateP) != ""} {lappend lsStateReorder $sStateP}
                     }
                     pMqlCmd "mod policy \042$aCol(0)\042 remove state \042$sStateP\042"
                     pMqlCmd "mod policy \042$aCol(0)\042 add state \042$sStateP\042 before \042$sStateA\042"
                     incr iCtrA
                  } else {
                     pMqlCmd "mod policy \042$aCol(0)\042 add state \042$sStateP\042 before \042$sStateA\042"
                     incr iCtrA
                  }
                  set lsStateActual [pPrintQuery "" state | spl]
               } else {
                  incr iCtrA
               }
            } else {
               pMqlCmd "mod policy \042$aCol(0)\042 add state \042$sStateP\042"               
            }
         }
         for {} {$iCtrA < [llength $lsStateActual]} {incr iCtrA} {pMqlCmd "mod policy \042$aCol(0)\042 remove state \042[lindex $lsStateActual $iCtrA]\042"}
         
         if {$bQuery == "FALSE"} {
         	 puts "$iBOCounter bus object(s) found"
            file delete -force "$sLogFileDir/BusObjectQuery.txt"
         }
# Reset Bus Object states if reordered - ION 10/26/09 (removed promote logic - added change state logic)
         foreach sStateReorder $lsStateReorder {
            mql trigger off
            set iCommit 0
            set bReset FALSE
            foreach oID $aBusObject($sStateReorder) {
               if {!$bReset} {
                  if {[pQuery "" "print bus $oID select current dump"] != "$sStateReorder"} {
                     puts "Resetting [llength $aBusObject($sStateReorder)] bus object(s) back to state '$sStateReorder'"
                     pAppend "# Promote [llength $aBusObject($sStateReorder)] business objects back to state: $sStateReorder" FALSE
                     set bReset TRUE
                  } else {
                     break
                  }
               }
               if {[catch {
               	  mql mod bus $oID current $sStateReorder
               } sMsg] != 0} {
                  pWriteWarningMsg "\nWARNING: Bus Object [pQuery "$oID" "print bus $oID select type name revision dump \042 \042"] reset state error:\n$sMsg"
                  break
               } else {
                  incr iCommit
                  if {$iCommit > $iBusObjCommit} {
                     mql commit transaction
                     mql start transaction update
                     pAppend "# Committed $iCommit business object state resets" FALSE
                     set iCommit 0
                  }
               }
            }
            mql trigger on
         }
# For state resequence, run state, signature, trigger and policyaccess files
         set lsSchemaElement ""
         foreach sElement [list state signature policyaccess trigger] {
            if {[lsearch $lsSchemaType $sElement] < 0} {
               if {[file exists "$sSpinDir/Business/*$aSchemaTitle($sElement)Data*.*"] == 1 || ($sElement == "policyaccess" && [file exists "$sSpinDir/Business/Policy"] == 1)} {
                  set bProcess TRUE
                  lappend lsSchemaElement $sElement
               }
            }
         }
# Sync state properties - ION 10/26/09 (changed logic as states were not properly fixed)
         foreach sSymbolicActual $lsSymbolicActual {
# JD le 29/11/12 : correction du test --> Ajout : $sSymbolicActual != ""
            if {[mql print policy "$aCol(0)" select property\[$sSymbolicActual\] dump] != "" && $sSymbolicActual != ""} {
               mql delete property "$sSymbolicActual" on policy "$aCol(0)"
            } 
         }
         foreach sState $lsStatePlan sSymbolicPlan $lsSymbolicPlan {
            if {[mql print policy "$aCol(0)" select property\[$sSymbolicPlan\] dump] != ""} {
               mql mod property "$sSymbolicPlan" on policy "$aCol(0)" value "$sState"
            } else {
               mql add property "$sSymbolicPlan" on policy "$aCol(0)" value "$sState"
            }
         }            
      }
   }
   return 0
}

# Procedure to analyze policy states
proc pAnalyzeState {} {
   global aCol aDat bOverlay bAdd lsAccessPlan lsAccessActual lsNotifyPlan lsNotifyActual lsSignaturePlan lsSignatureActual bUseAccessField bMm
# Major/Minor Mod - ION - 10/1/2012
   if {$bMm} {
      foreach iCol [list 3 5 14] {set aCol($iCol) [pCompareAttr $aCol($iCol) false true true true]}
      foreach iCol [list 4 12 13] {set aCol($iCol) [pCompareAttr $aCol($iCol) true false false true]}
   } else {
   foreach iCol [list 2 3 5] {set aCol($iCol) [pCompareAttr $aCol($iCol) false true true true]}
   set aCol(4) [pCompareAttr $aCol(4) true false false true]
   }
   set lsAccessPlan  [pTrimList $aCol(6)]
   set lsNotifyPlan [pTrimList $aCol(7)]
   set lsSignaturePlan [pTrimList $aCol(11)]
# Major/Minor Mod - ION - 10/1/2012
   if {$bMm} {
      foreach iDat [list 3 4 5 12 13 14] sProperty [list versionable autopromote checkouthistory minorrevisionable majorrevisionable published] {set aDat($iDat) [pPrintQuery "" "state\134\133$aCol(1)\134\135.$sProperty" "" str]}
   } else {
   foreach iDat [list 2 3 4 5] sProperty [list revisionable versionable autopromote checkouthistory] {set aDat($iDat) [pPrintQuery "" "state\134\133$aCol(1)\134\135.$sProperty" "" str]}
   }
   set aDat(8) [pPrintQuery "" "state\134\133$aCol(1)\134\135.notify" "" ""]
   set aDat(10) [pPrintQuery "" "state\134\133$aCol(1)\134\135.route" "" ""]
   set lsSignatureActual [pPrintQuery "" "state\134\133$aCol(1)\134\135.signature" | spl]
   set lsAccessActual [list ]
   set lsNotifyActual [list ]
   set aDat(9) ""
   if {$bUseAccessField} {set lsAccessActual [pQueryAccess policy $aCol(0) "state\134\133$aCol(1)\134\135.access"]}
   set lsPrint [split [pQuery "" "print policy \042$aCol(0)\042"] \n]
   set bTrip "FALSE"
   foreach sPrint $lsPrint {
      set sPrint [string trim $sPrint]
      if {$sPrint == "state $aCol(1)"} {
         set bTrip TRUE
      } elseif {$bTrip && [string range $sPrint 0 4] == "state"} {
         break
      } elseif {$bTrip} {
         if {[string range $sPrint 0 5] == "notify"} {
            regsub "notify " $sPrint "" sPrint
            regsub -all "'" $sPrint "" sPrint
            if {$aDat(8) != ""} {regsub " $aDat(8)" $sPrint "" sPrint}
            set sPrint [string trim $sPrint]
            set lsNotifyActual [split $sPrint ","]
         } elseif {[string range $sPrint 0 4] == "route"} {
            regsub "route " $sPrint "" sPrint
            regsub -all "'" $sPrint "" sPrint
            if {$aDat(10) != ""} {regsub " $aDat(10)" $sPrint "" sPrint}
            set aDat(9) [string trim $sPrint]
         }
      }
   }
   pSetAction "Modify policy $aCol(0) state $aCol(1)"
   if {$bOverlay} {
# Major/Minor Mod - ION - 10/1/2012
      if {$bMm} {
         pOverlay [list 3 4 5 8 9 10 12 13 14]
	  } else {
      pOverlay [list 2 3 4 5 8 9 10]
	  }
      set lsAccessPlan [pOverlayList $lsAccessPlan $lsAccessActual]
      set lsNotifyPlan [pOverlayList $lsNotifyPlan $lsNotifyActual]
      set lsSignaturePlan [pOverlayList $lsSignaturePlan $lsSignatureActual]
   }
}                                       
     ######## Added By SL Team for Policy issue (Policy having branches is screwed up with User Agent being populated etc in Signature approver fields)####### 
proc pAnalyzeDataSignature {} {
global lsFileExtSkip aCol lsMasterSignatureList
set varSigDataFilePath "[pwd]/Business/*PolicyStateSignature*.*"
 set sDelimitSiganture "\t"
 set lsDataFileSignature [glob -nocomplain $varSigDataFilePath]
                  set slsDataFileSignature ""
				  set lsMasterSignatureList ""
                  foreach sDataFileSignature $lsDataFileSignature {
                     if {[lsearch $lsFileExtSkip [file ext $sDataFileSignature]] < 0} {
                      set iFile [open $sDataFileSignature r]
                      append slsDataFileSignature "[read $iFile]"
                      close $iFile
                     } 
					  }
					  set linesSignature [split $slsDataFileSignature \n]
					  foreach signature $linesSignature {
					  set sDataLineSignature [ split $signature $sDelimitSiganture ]
	                  set sDataLineSignatureList [list $sDataLineSignature]
					
					  foreach signatureList $sDataLineSignatureList {
					  set sDataLinesSignatureAtZe  [ lindex "$signatureList" 0] 
					  set sDataLinesSignatureAtOne  [lindex "$signatureList" 1] 
					  set sDataLinesSignatureName [lindex "$signatureList" 2] 
					  set sDataLinesApproveSignature  [lindex "$signatureList" 3] 
			########  Added by SL team for issue IR-140370 START  #############
			if {[regexp -all {\|} $sDataLinesApproveSignature match]} {
			set lsSignature [pTrimList $sDataLinesApproveSignature]
            foreach sItSignature $lsSignature {
            lappend lsMasterSignatureList [list $sDataLinesSignatureAtZe $sDataLinesSignatureAtOne $sItSignature $sDataLinesSignatureName]
			} 
					} else {
					  lappend lsMasterSignatureList [list $sDataLinesSignatureAtZe $sDataLinesSignatureAtOne $sDataLinesApproveSignature $sDataLinesSignatureName]
							}
            ############### END #################
					}
						}		
return $lsMasterSignatureList
}
######## END #######

# Procedure to process policy states
proc pProcessState {lsMasterSignatureList} {		
######## Added By SL Team for Policy issue (Policy having branches is screwed up with User Agent being populated etc in Signature approver fields)#######				  
 global aCol sfinaldata sDataLinesSignatureName aDat lsAccessPlan lsAccessActual lsNotifyPlan lsNotifyActual lsSignaturePlan lsSignatureActual bUseAccessField sIcon bScan bMm sDataLinesSignatureName
 set sfinaldata ""
 set sDataLinesSignatureName "" 
 set sDelimitSiganture "\t"
 set sModMasterlist ""
 set sfinaldata1 ""
 set lsEmptySigList ""
 set lsNonEmptySigList ""

set sDataLinesSigna [split "$lsMasterSignatureList" \n]	
	 
					  foreach signatureList $lsMasterSignatureList {
					  set sDataLinesSignatureAtZe [lindex $signatureList 0]
					  set sDataLinesSignatureAtOne  [lindex $signatureList 1]	
                      if { $aCol(0) == $sDataLinesSignatureAtZe && $aCol(1) == $sDataLinesSignatureAtOne}  { 
					  set sDataLinesSignatureName [lindex "$signatureList" 3]	
					  set sfinaldata1 ""					  
					  set sfinaldata [lindex "$signatureList" 2]
					  if { $sfinaldata == ""} { 
					  ## START - added BY SL Team For Double Signature Issue ##
					  lappend lsEmptySigList $sDataLinesSignatureName
					  ## END ##

						pPlanActualAddDel $lsSignatureActual "" $lsEmptySigList policy "\042$aCol(0)\042 state" $aCol(1) "remove signature" "add signature" " approve \042User Agent\042"
					   
} 
					 }								 
					 set idx [lsearch $lsMasterSignatureList $signatureList]
					 set $lsMasterSignatureList [lreplace $lsMasterSignatureList $idx $idx]
				 }	
######## END #######
if { $sfinaldata != ""} {					      
	                     ## START - Added By SL Team For Double Signature Issue##
					     lappend lsNonEmptySigList $sDataLinesSignatureName
						 ## END ##
						  pPlanActualAddDel $lsSignatureActual "" $lsNonEmptySigList policy "\042$aCol(0)\042 state" $aCol(1) "remove signature" "add signature" " approve \042$sfinaldata\042"
					   } else {
						 # KYB Start Fixed Signature issue for Product policy on 09/21/2012
						 pPlanActualAddDel $lsSignatureActual "" $lsSignaturePlan policy "\042$aCol(0)\042 state" $aCol(1) "remove signature" "add signature" " approve \042User Agent\042"
						 # KYB End Fixed Signature issue for Product policy on 09/21/2012
					   }

   # Major/Minor Mod - ION - 10/1/2012
   if {$bMm} {
      if {$aCol(3) != $aDat(3) || $aCol(4) != $aDat(4) || $aCol(5) != $aDat(5) || $aCol(8) != $aDat(8) || $aCol(10) != $aDat(10) || $aCol(12) != $aDat(12) || $aCol(13) != $aDat(13) || $aCol(14) != $aDat(14)} {
	     pMqlCmd "mod policy \042$aCol(0)\042 state \042$aCol(1)\042 version $aCol(3) promote $aCol(4) checkouthistory $aCol(5) notify message \042$aCol(8)\042 route message \042$aCol(10)\042 minorrevision $aCol(12) majorrevision $aCol(13) published $aCol(14)"
	  }
   } else {      
      if {$aCol(2) != $aDat(2) || $aCol(3) != $aDat(3) || $aCol(4) != $aDat(4) || $aCol(5) != $aDat(5) || $aCol(8) != $aDat(8) || $aCol(10) != $aDat(10)} {
	     pMqlCmd "mod policy \042$aCol(0)\042 state \042$aCol(1)\042 revision $aCol(2) version $aCol(3) promote $aCol(4) checkouthistory $aCol(5) notify message \042$aCol(8)\042 route message \042$aCol(10)\042"
      }
   }
   if {$bUseAccessField} {pPlanActualAddDel $lsAccessActual "" $lsAccessPlan policy "\042$aCol(0)\042 state" $aCol(1) "remove user" "add user" ""}
   pPlanActualAddDel $lsNotifyActual "" $lsNotifyPlan policy "\042$aCol(0)\042 state" $aCol(1) "remove notify" "add notify" ""
   if {$aDat(9) != "" && $aDat(9) != $aCol(9)} {pMqlCmd "mod policy \042$aCol(0)\042 state \042$aCol(1)\042 remove route"}
   if {$aCol(9) != "" && $aCol(9) != $aDat(9)} {pMqlCmd "mod policy \042$aCol(0)\042 state \042$aCol(1)\042 add route \042$aCol(9)\042"}
   if {$sIcon != "" && $bScan != "TRUE"} {mql mod policy $aCol(0) state $aCol(1) icon "$sSpinDir/Pix/$sIcon"}
   ######## Added By SL Team for Policy issue (Policy having branches is screwed up with User Agent being populated etc in Signature approver fields)#######
   return 	$lsMasterSignatureList	
   ######## END #######
}

# Procedure to analyze policy state signatures
proc pAnalyzeSignature {} {
   global aCol aDat bOverlay bAdd lsApprovePlan lsApproveActual lsRejectPlan lsRejectActual lsIgnorePlan lsIgnoreActual
   set lsApprovePlan [pTrimList $aCol(3)]
   set lsRejectPlan [pTrimList $aCol(4)]
   set lsIgnorePlan [pTrimList $aCol(5)]
   set lsApproveActual [pPrintQuery "" "state\134\133$aCol(1)\134\135.signature\134\133$aCol(2)\134\135.approve" | spl]
   set lsRejectActual [pPrintQuery "" "state\134\133$aCol(1)\134\135.signature\134\133$aCol(2)\134\135.reject" | spl]
   set lsIgnoreActual [pPrintQuery "" "state\134\133$aCol(1)\134\135.signature\134\133$aCol(2)\134\135.ignore" | spl]
   set sCatchStringOne "state $aCol(1)"
   set aDat(6) ""
   set aDat(7) ""
   set sCatchStringTwo ""
   set bPass false
   set bTrip1 false
   set bTrip2 false
   set lsPrint [split [pQuery "" "print policy \042$aCol(0)\042"] \n]
   foreach sPrint $lsPrint {
      set sPrint [string trim $sPrint]
      if {$sCatchStringTwo == ""} {
         if {[string first $sCatchStringOne $sPrint] == 0} {set sCatchStringTwo "state"}
      } elseif {[string first $sCatchStringTwo $sPrint] == 0} {
         break
      }
      if {$sCatchStringTwo != ""} {
         if {[string first "signature $aCol(2)" $sPrint] == 0} {
            set bPass true
         } elseif {$bPass} {
            if {[string first "branch" $sPrint] == 0} {
               set bTrip1 "true"
               regsub "branch " $sPrint "" aDat(6)
               set aDat(6) [string trim $aDat(6)]
            }
            if {[string first "filter" $sPrint] == 0} {
               set bTrip2 "true"
               regsub "filter " $sPrint "" aDat(7)
               set aDat(7) [string trim $aDat(7)]
            }
            if {$bTrip1 && $bTrip2} {break}
         }
      }
   }
   pSetAction "Modify policy $aCol(0) state $aCol(1) signature $aCol(2)"
   if {$bOverlay} {
      pOverlay [list 6 7]
      set lsApprovePlan [pOverlayList $lsApprovePlan $lsApproveActual]
      set lsRejectPlan [pOverlayList $lsRejectPlan $lsRejectActual]
      set lsIgnorePlan [pOverlayList $lsIgnorePlan $lsIgnoreActual]
   }
}

# Procedure to process policy state signatures
proc pProcessSignature {} {
   global aCol aDat lsApprovePlan lsApproveActual lsRejectPlan lsRejectActual lsIgnorePlan lsIgnoreActual
   if {$aCol(7) != $aDat(7)} {
      set aCol(7) [pRegSubEvalEscape $aCol(7)]
      pMqlCmd "mod policy \042$aCol(0)\042 state \042$aCol(1)\042 signature \042$aCol(2)\042 filter \042$aCol(7)\042"
   }
   pPlanActualAddDel $lsApproveActual "" $lsApprovePlan policy "\042$aCol(0)\042 state \042$aCol(1)\042 signature" $aCol(2) "remove approve" "add approve" ""
   pPlanActualAddDel $lsRejectActual "" $lsRejectPlan policy "\042$aCol(0)\042 state \042$aCol(1)\042 signature" $aCol(2) "remove reject" "add reject" ""
   pPlanActualAddDel $lsIgnoreActual "" $lsIgnorePlan policy "\042$aCol(0)\042 state \042$aCol(1)\042 signature" $aCol(2) "remove ignore" "add ignore" ""
   if {$aCol(6) != $aDat(6)} {
      if {$aCol(6) == "" && $aDat(6) != ""} {
         pMqlCmd "mod policy \042$aCol(0)\042 state \042$aCol(1)\042 signature \042$aCol(2)\042 remove branch"
      } else {
         pMqlCmd "mod policy \042$aCol(0)\042 state \042$aCol(1)\042 signature \042$aCol(2)\042 add branch \042$aCol(6)\042"
      }
   }
   return 0
}

