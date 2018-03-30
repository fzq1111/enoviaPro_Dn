#########################################################################*2013
#
# @progdoc      emxSpinnerUser.tcl vM2013 (Build 6.10.12)
#
# @Description: Procedures for running in Roles, Groups and Associations
#
# @Parameters:  Returns 0 if successful, 1 if not
#
# @Usage:       Utilized by emxSpinnerAgent.tcl
#
# @progdoc      Copyright (c) ENOVIA Inc. 2005
#
#########################################################################
#
# @Modifications: FirstName LastName MM/DD/YYYY - Modification
#
#########################################################################

# Procedure to add or remove role/group parent or site
proc pAddDelParentSite {sSchemaType sSchemaName sParentSite sParentSiteName sGroupRoleSite iRange} {
   if {$sParentSiteName != ""} {
      pMqlCmd "mod $sSchemaType \042$sSchemaName\042 $sParentSite \042$sParentSiteName\042"
   } else {
      set lsSelect [split [pQuery "" "print $sSchemaType \042$sSchemaName\042"] \n]
      foreach sSelect $lsSelect {
         set sSelect [string trim $sSelect]
         if {[string range $sSelect 0 $iRange] == $sParentSite} {
            pMqlCmd "add $sGroupRoleSite DeleteThisElement"
            pMqlCmd "mod $sSchemaType \042$sSchemaName\042 $sParentSite DeleteThisElement"
            pMqlCmd "delete $sGroupRoleSite DeleteThisElement"
            break
         }
      }
   }
}

# Procedure to analyze roles and groups
proc pAnalyzeUser {} {
   global aCol aDat bOverlay bAdd lsParentRolePlan lsParentRoleActual slsParentRoleActual lsChildRolePlan lsChildRoleActual lsAssignmentPlan lsAssignmentActual sSchemaType bUseAssignmentField sParentChild
   set lsParentRolePlan [lsort [pTrimList $aCol(3)]]
   set aCol(3) [join $lsParentRolePlan ","]
   set lsChildRolePlan [pTrimList $aCol(4)]
   set lsChildRolePlan [pCheckNameChange $lsChildRolePlan $sSchemaType]
   set lsAssignmentPlan [pTrimList $aCol(5)]
   set slsParentRoleActual "" 
   set lsChildRoleActual [list ]
   set lsAssignmentActual [list ]
   if {$bAdd != "TRUE"} {
      set aDat(6) ""
      set lsSiteActualTemp [split [pQuery "" "print $sSchemaType \042$aCol(0)\042"] \n]
      foreach sSiteTemp $lsSiteActualTemp {
         set sSiteTemp [string trim $sSiteTemp]
         if {[string first "site" $sSiteTemp] == 0} {
            regsub "site " $sSiteTemp "" aDat(6)
            break
         }
      }
      set lsParentRoleActual [lsort [pPrintQuery "" parent | spl]]
      set slsParentRoleActual [join $lsParentRoleActual ","]
      set lsChildRoleActual [pPrintQuery "" child | spl]
      set lsAssignmentActual [list ]
      if {$bUseAssignmentField} {
         set lsAssignmentTemp [pPrintQuery "" assignment | spl]
         regsub -all "\134\050" $aCol(0) "\134\050" sTestName
         regsub -all "\134\051" $sTestName "\134\051" sTestName
         foreach sAssignment $lsAssignmentTemp {
            regsub "$sTestName\ " $sAssignment "" sAssignment
            lappend lsAssignmentActual [string trim $sAssignment]
         }
      }
   }
   if {$bOverlay} {
      set aCol(3) [pOverlayList $aCol(3) $slsParentRoleActual]
      set lsChildRolePlan [pOverlayList $lsChildRolePlan $lsChildRoleActual]
      set lsAssignmentPlan [pOverlayList $lsAssignmentPlan $lsAssignmentActual]
   }
}

# Procedure to process roles and groups
proc pProcessUser {} {
   global aCol aDat bAdd lsParentRolePlan lsParentRoleActual slsParentRoleActual lsChildRolePlan lsChildRoleActual lsAssignmentPlan lsAssignmentActual sHidden sHiddenActual bUseAssignmentField sParentChild sSchemaType
   if {$bAdd} {
      pMqlCmd "add $sSchemaType \042$aCol(0)\042 $sHidden"
      if {$aCol(3) != "" && $sParentChild == "parent"} {pMqlCmd "mod $sSchemaType \042$aCol(0)\042 parent \042$aCol(3)\042"}
      if {$aCol(6) != ""} {pMqlCmd "mod $sSchemaType \042$aCol(0)\042 site \042$aCol(6)\042"}
      if {$sParentChild != "parent"} {pPlanAdd $lsChildRolePlan $sSchemaType $aCol(0) "child" ""}
      if {$bUseAssignmentField} {pPlanAdd $lsAssignmentPlan $sSchemaType $aCol(0) "assign person" ""}
   } else {
      if {$sHidden != $sHiddenActual} {pMqlCmd "mod $sSchemaType \042$aCol(0)\042 $sHidden"}
      if {$aCol(3) != $slsParentRoleActual && $sParentChild == "parent"} {pAddDelParentSite $sSchemaType $aCol(0) parent $aCol(3) $sSchemaType 5}
      if {$aCol(6) != $aDat(6)} {pAddDelParentSite $sSchemaType $aCol(0) site $aCol(3) site 3}
      if {$bUseAssignmentField} {pPlanActualAddDel $lsAssignmentActual "" $lsAssignmentPlan $sSchemaType "" $aCol(0) "remove assign person" "assign person" ""}
      if {$sParentChild != "parent"} {pPlanActualAddDel $lsChildRoleActual "" $lsChildRolePlan $sSchemaType "" $aCol(0) "remove child" "child" ""}
   }
   return 0
}

# Procedure to analyze associations
proc pAnalyzeAssociation {} {
   global aCol aDat bAdd sDefinition sDefinitionTest sDefinitionActual sHiddenActual sDescriptionActual
   set lsDefinition [split $aCol(3) |]
   set sDefinition ""
   set sDefinitionTest ""
   foreach sDefinitionTemp $lsDefinition {
      set bAndOr FALSE
      set sDefinitionTemp [string trim $sDefinitionTemp]
      if {[string tolower $sDefinitionTemp] == "or"} {
         set sDefinitionTemp " || "
         set bAndOr TRUE
      } elseif {[string tolower $sDefinitionTemp] == "and"} {
         set sDefinitionTemp " && "
         set bAndOr TRUE
      }
      if {$bAndOr} {
         append sDefinition $sDefinitionTemp
         append sDefinitionTest $sDefinitionTemp
      } else {
         append sDefinition "\042$sDefinitionTemp\042"
         append sDefinitionTest $sDefinitionTemp
      }
   }
   regsub -all "\042" $sDefinitionTest "" sDefinitionTest
   regsub -all "\042" $sDefinition "\134\042" sDefinition
   if {$bAdd != "TRUE"} {
      set sDefinitionActual ""
      set sHiddenActual ""
      set lsPrint [split [pQuery "" "print association \042$aCol(0)\042"] \n]
      foreach sPrint $lsPrint {
         set sPrint [string trim $sPrint]
         if {[string first "description" $sPrint] == 0} {
            regsub "description" $sPrint "" sDescriptionActual
            set sDescriptionActual [string trim $sDescriptionActual]
         } elseif {[string first "definition" $sPrint] == 0} {
            regsub "definition" $sPrint "" sDefinitionActual
            regsub -all "\042" $sDefinitionActual "" sDefinitionActual
            set sDefinitionActual [string trim $sDefinitionActual]
         } elseif {$sPrint == "hidden"} {
            set sHiddenActual hidden
         } elseif {$sPrint == "nothidden"} {
            set sHiddenActual nothidden
         }
      }
   }
}                                       

# Procedure to process associations
proc pProcessAssociation {} {
   global aCol bAdd sDefinition sDefinitionTest sDefinitionActual sHidden sHiddenActual
   if {$bAdd} {
      pMqlCmd "add association \042$aCol(0)\042 definition '$sDefinition' $sHidden"
   } elseif {$sDefinitionTest != $sDefinitionActual || $sHidden != $sHiddenActual} {
      pMqlCmd "escape mod association \042$aCol(0)\042 definition '$sDefinition' $sHidden"
   }
   return 0
}

