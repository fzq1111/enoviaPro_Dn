#########################################################################*2013
#
# @progdoc      emxSpinnerFormat.tcl vM2013 (Build 5.1.12)
#
# @Description: Procedures for running in Formats
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

# Procedure to analyze formats
proc pAnalyzeFormat {} {
   global aCol aDat bOverlay bAdd
   if {$bAdd != "TRUE"} {
      foreach sDat [list 3 4 7 8 9] sPQ2 [list version filesuffix view edit print] {set aDat($sDat) [pPrintQuery "" $sPQ2 "" ""]}
      set aDat(5) ""
      set aDat(6) ""
      set aDat(10) ""
      set lsPrint [split [pQuery "" "print format \042$aCol(0)\042"] \n]
      foreach sPrint $lsPrint {
         set sPrint [string trim $sPrint]
         if {[string first "type" $sPrint] == 0} {
            regsub "type" $sPrint "" aDat(6)
            set aDat(6) [string trim $aDat(6)]
            set aDat(5) $aDat(6)
         } elseif {[string first "mime" $sPrint] == 0} {
            regsub "mime" $sPrint "" aDat(10)
            set aDat(10) [string trim $aDat(10)]
         }
      }
   }
   if {$bOverlay} {pOverlay [list 3 4 5 6 7 8 9 10]}
}

# Procedure to process formats
proc pProcessFormat {} {
   global aCol aDat bAdd sSchemaType
   if {$bAdd} {
      pMqlCmd "add format \042$aCol(0)\042 version \042$aCol(3)\042 suffix \042$aCol(4)\042 creator \042$aCol(5)\042 type \042$aCol(6)\042 view \042$aCol(7)\042 edit \042$aCol(8)\042 print \042$aCol(9)\042 mime \042$aCol(10)\042"
   } elseif {$aCol(3) != $aDat(3) || $aCol(4) != $aDat(4) || $aCol(5) != $aDat(5) || $aCol(6) != $aDat(6) || $aCol(7) != $aDat(7) || $aCol(8) != $aDat(8) || $aCol(7) != $aDat(7) || $aCol(9) != $aDat(9) || $aCol(10) != $aDat(10)} {
      pMqlCmd "mod format \042$aCol(0)\042 version \042$aCol(3)\042 suffix \042$aCol(4)\042 creator \042$aCol(5)\042 type \042$aCol(6)\042 view \042$aCol(7)\042 edit \042$aCol(8)\042 print \042$aCol(9)\042 mime \042$aCol(10)\042"
   }
   return 0
}                                          
                                      

