
#########################################################################*2013
#
# @progdoc      emxSpinnerAttribute.tcl vMV6R2013 (Build 11.10.2)
#
# @Description: Procedures for running in Attributes
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

# Procedure to reverse range order for input
   proc pRevOrderRange {} {
      global aCol lsRangePlan lsRangeValuePlan
      set lsRangePlanReverse [list ]
      set lsRangeValuePlanReverse [list ]
      for {set i [expr [llength $lsRangeValuePlan] -1]} {$i >= 0} {incr i -1} {
         lappend lsRangePlanReverse [lindex $lsRangePlan $i]
         lappend lsRangeValuePlanReverse [lindex $lsRangeValuePlan $i]
      }
      set lsRangePlan $lsRangePlanReverse
      set lsRangeValuePlan $lsRangeValuePlanReverse
   }

# Procedure to add and remove range values
   proc pAddDelAttrRange {sRange sRangeValue sAddMod} {
      global sAppendRange sVal1 sIncExc1 sVal2 sIncExc2
      if {[string first "program" $sRange] != "-1"} {
         regsub "program " $sRange "" sProgRange
         set sInput ""
         set iWith [string first "with input" $sProgRange]
         if {$iWith != "-1"} {
            set iProgEnd [expr $iWith -2]
            set sInput [string range $sProgRange $iWith end]
            regsub "with input " $sInput "" sInput
            set sInput [pRegSubEvalEscape $sInput]
            set sInput [string trim $sInput]
            set sProgRange [string range $sProgRange 0 $iProgEnd]
         }
         append sAppendRange " $sAddMod program \042$sProgRange\042"
         if {$sAddMod == "add"} {append sAppendRange " input \042$sInput\042"}
      } elseif {$sRangeValue == "between"} {
         set lsBetween [split $sRange " "]
         set sVal1 [lindex $lsBetween 0]
         set sIncExc1 [lindex $lsBetween 1]
         set sVal2 [lindex $lsBetween 2]
         set sIncExc2 [lindex $lsBetween 3]
         append sAppendRange " $sAddMod range $sRangeValue \042$sVal1\042 $sIncExc1 \042$sVal2\042 $sIncExc2"
      } else {
         set sRange [pRegSubEvalEscape $sRange]
# Bug fix 313705
         # regsub -all "\134\042" $sRange "\134\134\134\042" sRange
         append sAppendRange " $sAddMod range $sRangeValue \042$sRange\042"
      }
   }

# Procedure to analyze attributes
proc pAnalyzeAttribute {} {
   global aCol aDat bOverlay bAdd sRangeDelim lsRangeValue lsRangePlan lsRangeValuePlan lsRangeActual lsRangeValueActual sMxVersion
   set aCol(2) [string tolower $aCol(2)]
   if {[string first "date" $aCol(2)] >= 0} {set aCol(2) timestamp} 
   if {[string tolower $aCol(4)] == "'true" || [string tolower $aCol(4)] == "'false"} {regsub -all "\047" $aCol(4) "" aCol(4)}
   regsub -all "<SPACE>" $aCol(4) " " aCol(4)
   ######### START Added by SL Team for spinner V6R2012 validation ##########
   regsub -all "<NEWLINE>" $aCol(4) "\012" aCol(4)
   ############ END ########################################################
   set lsRangePlan [list ]
   set lsRangeValuePlan [list ]
   set sSplit $sRangeDelim
   if {[string first "uses prog" $aCol(5)] >= 0 || [string first "uses <<prog" $aCol(5)] >= 0} {
      regsub -all " \134| " $aCol(5) " ~ " aCol(5)
      set sSplit "~"
   }
   set lsRangePlanTemp [split $aCol(5) $sSplit]
   foreach sRangePlan $lsRangePlanTemp {
      set sRangePlan [string trim $sRangePlan]
      set bFoundValue FALSE
      set bNull FALSE
      set bLeftTag FALSE
      if {[string first "<<" $sRangePlan] == 0} {
         regsub "<<" $sRangePlan "" sRangePlan
         set sRangePlan [string trim $sRangePlan]
         set bLeftTag TRUE
      }
      regsub -all "  " $sRangePlan " " sRangePlan
      regsub -all "<SPACE>" $sRangePlan " " sRangePlan
      if {[regsub -all "<NULL>" $sRangePlan "" sRangePlan]} {set bNull TRUE}
      foreach sRangeValue $lsRangeValue {
         if {[string first $sRangeValue $sRangePlan] == 0} {
            regsub "$sRangeValue" $sRangePlan "" sRangePlan
            set sRangePlan [string trim $sRangePlan]
            lappend lsRangeValuePlan $sRangeValue
            set bFoundValue TRUE
            break
         }
      }
      if {$bFoundValue == "FALSE"} {lappend lsRangeValuePlan "="}
      if {$bLeftTag} {set sRangePlan "<<$sRangePlan"}
      lappend lsRangePlan $sRangePlan
   }
   set aCol(6) [pCompareAttr [string tolower $aCol(6)] notmultiline multiline true true]
   if {$sMxVersion > 2010.1} {
      set aCol(10) [pCompareAttr [string tolower $aCol(10)] !resetonclone resetonclone true true]
      set aCol(11) [pCompareAttr [string tolower $aCol(11)] !resetonrevision resetonrevision true true]
   }
   set lsRangeValueActual [list ]
   set lsRangeActual [list ]
   if {$bAdd != "TRUE"} {
      set aDat(2) [pPrintQuery "" type "" ""]
      set aDat(4) [pPrintQuery "" default "" ""]
      set bMultilineActual [pPrintQuery FALSE multiline "" ""]
      set aDat(6) [pCompareAttr $bMultilineActual notmultiline multiline true false]
	  if {$sMxVersion > 2010.1} {
         set aDat(9) [pPrintQuery "" maxlength "" ""]
         set bResetOnClone [pPrintQuery FALSE resetonclone "" ""]
         set aDat(10) [pCompareAttr $bResetOnClone !resetonclone resetonclone true false]
         set bResetOnRevision [pPrintQuery FALSE resetonrevision "" ""]
         set aDat(11) [pCompareAttr $bResetOnRevision !resetonrevision resetonrevision true false]
	  }
      set lsRangeActualTemp [split [mql print attr $aCol(0)] \n]
      foreach sRangeActual $lsRangeActualTemp {
         if {[string first "  range " $sRangeActual] == 0} {
            regsub "  range " $sRangeActual "" sRangeActual
            foreach sRangeValue $lsRangeValue {
               if {[string first $sRangeValue $sRangeActual] == 0} {
                  regsub "$sRangeValue" $sRangeActual "" sRangeActual
                  if {$sRangeActual == "  "} {
                     set sRangeActual " "
                  } else {
                     set sRangeActual [string trim $sRangeActual]
                  }
                  lappend lsRangeValueActual $sRangeValue
                  break
               }
            }
            lappend lsRangeActual $sRangeActual
         }
      }
      #modified if condition to check for 10.7 version to fix 363168 on 1/29/2009
      if {$sMxVersion >= 10.7} {set aDat(8) [pPrintQuery "" dimension "" ""]} 
   }
   if {$bOverlay} {
      if {$sMxVersion >= 2010.1} { 
         pOverlay [list 2 4 6 8 9 10 11]
      } elseif {$sMxVersion >= 10.8} { 
         pOverlay [list 2 4 6 8]
      } else {
         pOverlay [list 2 4 6]
      }
      if {$lsRangePlan == "\{\}" && $bNull} {
         set lsRangeValuePlan [list ]
         set lsRangePlan [list ]
      } elseif {$lsRangePlan == ""} {
         set lsRangePlan $lsRangeActual
         set lsRangeValuePlan $lsRangeValueActual
      } elseif {[lsort $lsRangePlan] == [lsort $lsRangeActual] && [lsort $lsRangeValuePlan] == [lsort $lsRangeValueActual]} {
      } else {
      	 set lsPlanTest [list ]
      	 set lsActualTest [list ]
         foreach sRangeValuePlan $lsRangeValuePlan sRangePlan $lsRangePlan {lappend lsPlanTest "$sRangeValuePlan\^$sRangePlan"}
         foreach sRangeValueActual $lsRangeValueActual sRangeActual $lsRangeActual {lappend lsActualTest "$sRangeValueActual\^$sRangeActual"}
            set lsPlanTest [lindex [pMergeList $lsPlanTest "" $lsActualTest "" ATTR] 0]
            set lsRangeValuePlan [list ]
            set lsRangePlan [list ]
         foreach sPlan $lsPlanTest {
            set lsPlan [split $sPlan ^]
            lappend lsRangeValuePlan [lindex $lsPlan 0]
            lappend lsRangePlan [lindex $lsPlan 1]
         }
      }
   }
}

# Procedure to process attributes
proc pProcessAttribute {} {
   global aCol aDat bAdd lsRangePlan lsRangeValuePlan lsRangeActual lsRangeValueActual sHidden sHiddenActual sAppendRange sVal1 sIncExc1 sVal2 sIncExc2 bRegister sModName bChangeAttrType bOut bDelAddAttr sMxVersion
   set iExit 0
   set bDelFlag FALSE
   set bWarnAttr FALSE
   if {$bAdd != "TRUE"} {
      if {$bDelAddAttr && [pPrintQuery "" "property\134\133SpinnerDelAddAttr\134\135.value" "" ""] != "TRUE"} {
         set bDelFlag TRUE
      } elseif {$bChangeAttrType && $aCol(2) != $aDat(2)} {
         set bDelFlag TRUE
      } elseif {$aCol(2) != $aDat(2)} {
         set bWarnAttr TRUE
      }
   }
   if {$bDelFlag} {
      pMqlCmd "delete attr \042$aCol(0)\042"
      set bAdd TRUE
      if {$aCol(1) != "" && $aCol(1) != "<NULL>"} {
      	 if {$sModName != $aCol(0)} {set aCol(0) $sModName}
         set bRegister TRUE
      } else {
      	 set bRegister FALSE
      }
   } elseif {$bWarnAttr} {
   	  set sWarningMsg "WARNING: Attribute '$aCol(0)' type '$aCol(2)' cannot be changed to '$aDat(2)' as program setting 'bChangeAttrType' is set to 'FALSE'"
      pWriteWarningMsg "\n$sWarningMsg"
   }   
   set sAppendRange ""
   if {$bAdd} {
      set aCol(4) [pRegSubEvalEscape $aCol(4)]
	  if {$sMxVersion > 2010.1} {
	     if {$aCol(9) > 0} {
            pMqlCmd "escape add attr \042$aCol(0)\042 type $aCol(2) default \042$aCol(4)\042 maxlength $aCol(9) $aCol(6) $aCol(10) $aCol(11) $sHidden"
		 } else {
            pMqlCmd "escape add attr \042$aCol(0)\042 type $aCol(2) default \042$aCol(4)\042 $aCol(6) $aCol(10) $aCol(11) $sHidden"
		 }
	  } else {
      pMqlCmd "escape add attr \042$aCol(0)\042 type $aCol(2) default \042$aCol(4)\042 $aCol(6) $sHidden"
	  }
      if {$lsRangePlan != ""} {
         pRevOrderRange
         foreach sRange $lsRangePlan sRangeValue $lsRangeValuePlan {pAddDelAttrRange $sRange $sRangeValue add}
         if {$sAppendRange != ""} {pMqlCmd "escape mod attribute \042$aCol(0)\042$sAppendRange"}
      }
      #modified if condition to check for 10.7 version to fix 363168 on 1/29/2009
      if {$sMxVersion >= 10.7 && $aCol(8) != ""} {pMqlCmd "mod attr \042$aCol(0)\042 add dimension \042$aCol(8)\042"}
      if {$bDelAddAttr} {pMqlCmd "add property SpinnerDelAddAttr on attribute \042$aCol(0)\042 value TRUE"}
   } else {
         set aCol(4) [pRegSubEvalEscape $aCol(4)]
      if {$sMxVersion > 2010.1} {
         if {$aCol(4) != $aDat(4) || $aCol(6) != $aDat(6) || $aCol(9) != $aDat(9) || $aCol(10) != $aDat(10) || $aCol(11) != $aDat(11) || $sHidden != $sHiddenActual} {
            pMqlCmd "escape mod attr \042$aCol(0)\042 default \042$aCol(4)\042 $aCol(6) maxlength $aCol(9) $aCol(10) $aCol(11) $sHidden"
         }
	  } else {
         if {$aCol(4) != $aDat(4) || $aCol(6) != $aDat(6) || $sHidden != $sHiddenActual} {
         pMqlCmd "escape mod attr \042$aCol(0)\042 default \042$aCol(4)\042 $aCol(6) $sHidden"
      }
	  }
      if {$lsRangePlan != $lsRangeActual || $lsRangeValuePlan != $lsRangeValueActual} {
         if {$lsRangeActual != ""} {foreach sRangeA $lsRangeActual sRangeValueA $lsRangeValueActual {pAddDelAttrRange $sRangeA $sRangeValueA remove}}
         if {$lsRangePlan != ""} {
            pRevOrderRange
            foreach sRange $lsRangePlan sRangeValue $lsRangeValuePlan {pAddDelAttrRange $sRange $sRangeValue add}
         }
         if {$sAppendRange != ""} {pMqlCmd "escape mod attribute \042$aCol(0)\042$sAppendRange"}
      }
      #modified if condition to check for 10.7 version to fix 363168 on 1/29/2009
      if {$sMxVersion >= 10.7 && $aCol(8) != $aDat(8)} {
         if {$aCol(8) == ""} {
            pMqlCmd "mod attr \042$aCol(0)\042 remove dimension \042$aDat(8)\042"
         } else {
            pMqlCmd "mod attr \042$aCol(0)\042 dimension \042$aCol(8)\042"
         }
      }
   }
   return $iExit
}

