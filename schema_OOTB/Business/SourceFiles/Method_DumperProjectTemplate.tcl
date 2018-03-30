#########################################################################
#
# @progdoc      Method_DumperProjectSpace.tcl
#
# @Description: Used to extract a complete Tech Spec structure into spinner files.
#
# @Parameters:  None
#
# @Usage:       Run this program as a method in thick client on a 'Technical Specification'.
#
# @progdoc      Copyright (c) ENOVIA Inc., June 26, 2002
#
#########################################################################
#
# @Modifications: Matt Osterman 06/25/2004 - v 0.1 (Build 4.6.27)
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

################################################################################
#                   Business Objects
################################################################################

   proc pGet_BOAdmin { sList } {
   
      global sDumpSchemaDirObjects oID sPSType sPSName sPSRev
      
      foreach sList1 $sList {
         set sValue1 "$sList1"
         set sValue2 [join $sValue1 _]
         set fname "bo_$sPSType-$sPSName-$sPSRev"
         puts "Start backup of Business Object $sList1 ..."
         set p_filename "$sDumpSchemaDirObjects/$fname\.xls"
         set lsTNRBO ""
         set lsBusObj ""

         if {$sValue1 == "Project Template"} {
            set p_file [open $p_filename w]
         } else {
            set p_file [open $p_filename a+]
         }
         		
#
# WRITE HEADER INFO INTO OUTPUT FILE.
#
         set sOutstr ""
         switch $sList1 {
            "Project Template" {
               set sOutstr [mql temp query bus $sPSType $sPSName $sPSRev select name revision policy current vault owner description attribute.value dump \t]
               set sAttr1  [ mql print type "$sPSType" select attribute dump \t ]
               puts $p_file "Type\tName\tRev\tChange Name\tChange Rev\tPolicy\tState\tVault\tOwner\tdescription\t$sAttr1\t<HEADER>"
               puts $p_file $sOutstr
               set lsFile [split [mql print bus "$sPSType" "$sPSName" "$sPSRev" select format.file.name dump |] |]
               set lsFormat [split [mql print bus "$sPSType" "$sPSName" "$sPSRev" select format.file.format dump |] |]
               foreach sFile $lsFile sFormat $lsFormat {
                  mql checkout bus "$sPSType" "$sPSName" "$sPSRev" server file $sFile "$sDumpSchemaDirObjects/Files"
                  file rename -force "$sDumpSchemaDirObjects/Files/$sFile" "$sDumpSchemaDirObjects/Files/$sPSType~~$sPSName~~$sPSRev~~$sFormat~~$sFile"
               }
            } Task {
               set lsTechSpec [split [mql expand bus $sPSType $sPSName $sPSRev rel Subtask from recurse to all select bus name revision policy current vault owner description attribute.value dump ^] \n]
               set sOutstr ""
               foreach slsTechSpec $lsTechSpec {
                  set sTest [join [lrange [split $slsTechSpec ^] 3 5] |]
                  if {[lsearch $lsTNRBO $sTest] < 0} {
                     set sTSType [lindex [split $slsTechSpec ^] 3]
                     set sTSName [lindex [split $slsTechSpec ^] 4]
                     set sTSRev [lindex [split $slsTechSpec ^] 5]
                     lappend sOutstr [join [lrange [split $slsTechSpec ^] 3 end] "\t"]
                     lappend lsTNRBO $sTest
                     set lsFile [split [mql print bus "$sTSType" "$sTSName" "$sTSRev" select format.file.name dump |] |]
                     set lsFormat [split [mql print bus "$sTSType" "$sTSName" "$sTSRev" select format.file.format dump |] |]
                     foreach sFile $lsFile sFormat $lsFormat {
                        mql checkout bus "$sTSType" "$sTSName" "$sTSRev" server file $sFile "$sDumpSchemaDirObjects/Files"
                        file rename -force "$sDumpSchemaDirObjects/Files/$sFile" "$sDumpSchemaDirObjects/Files/$sTSType~~$sTSName~~$sTSRev~~$sFormat~~$sFile"
                     }
                  }
               }
               if {$sOutstr != ""} {
                  set sAttr1  [ mql print type Task select attribute dump \t ]
                  puts $p_file "Type\tName\tRev\t\t\tPolicy\tState\tVault\tOwner\tdescription\t$sAttr1\t<HEADER>"
                  puts $p_file [join $sOutstr \n]
               }
            } "Project Access List" {
               set slsPAL [mql expand bus $sPSType $sPSName $sPSRev rel "Project Access List" to select bus name revision policy current vault owner description attribute.value dump ^]
               set sOutstr [join [lrange [split $slsPAL ^] 3 end] "\t"]
               if {$sOutstr != ""} {
                  set sAttr1  [mql print type "Project Access List" select attribute dump \t]
                  puts $p_file "Type\tName\tRev\tChange Name\tChange Rev\tPolicy\tState\tVault\tOwner\tdescription\t$sAttr1\t<HEADER>"
                  puts $p_file $sOutstr
               }
            }
         }
         close $p_file
      }
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
      set p_file [open $p_filename w]
      		
      set lsTechSpec [split [mql expand bus $sPSType $sPSName $sPSRev rel Subtask from recurse to all select bus id dump |] \n]
      set oPS [mql print bus "$sPSType" "$sPSName" "$sPSRev" select id dump] 
      set lsTechSpec [linsert $lsTechSpec 0 "|||$sPSType|$sPSName|$sPSRev|$oPS"]
      set lsQuery ""
      foreach slsTechSpec $lsTechSpec {
         set lslsTechSpec [split $slsTechSpec |]
         set sTSType [lindex $lslsTechSpec 3]
         set sTSName [lindex $lslsTechSpec 4]
         set sTSRev [lindex $lslsTechSpec 5]
         set oID [lindex $lslsTechSpec 6]
         lappend lsQuery "$sTSType|$sTSName|$sTSRev|$oID"
      }
     
      foreach sRel $lsRel {
         puts "Start backup of Business Object Relation $sRel ..."
         set sDirection to
         set sDir from
         if {$sRel == "Subtask"} {
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
            set oID [lindex $lslsQuery 3]
            
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
                  }
               }
            }
         }
         if {$lBos != ""} {
            puts $p_file $sHeader
            puts $p_file [join $lBos \n]
         }
      }
      close $p_file
   }
   # end of procedures

   set sPSType [mql get env 1]
   set sPSName [mql get env 2]
   set sPSRev [mql get env 3]
   set bTechSpec [mql get env TECHSPEC]
   if {[mql print bus $sPSType $sPSName $sPSRev select exists dump] != "TRUE"} {
      set oID [mql get env OBJECTID]
      set sPSType [mql get env TYPE]
      set sPSName [mql get env NAME]
      set sPSRev [mql get env REVISION]
   } else {
      set oID [mql print bus $sPSType $sPSName $sPSRev select id dump]
   }
   set sSpinnerPath [mql get env SPINNERPATHBO]
   
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
   
   set sDumpSchemaDirObjects [ file join $sSpinnerPath Objects ]
   file mkdir $sDumpSchemaDirObjects
   file mkdir "$sDumpSchemaDirObjects/Files"
   set sDumpSchemaDirRelationships [ file join $sSpinnerPath Relationships ]
   file mkdir $sDumpSchemaDirRelationships
   
   set thelist [ list "Project Template" "Task" "Project Access List" ]
   pGet_BOAdmin $thelist

   set thelist [ list "Project Access List" "Project Access Key" "Subtask" "Company Project Templates" "Dependency" ]
   pGet_BOAdminRel $thelist
   
   if {$bTechSpec != "TRUE"} {mql notice "Files loaded in directory: $sSpinnerPath"}
}

