
tcl;

eval {
   if {[info host] == "mostermant61p" } {
      source "c:/Program Files/TclPro1.3/win32-ix86/bin/prodebug.tcl"
   	  set cmd "debugger_eval"
   	  set xxx [debugger_init]
   } else {
   	  set cmd "eval"
   }
}
$cmd {
 
#************************************************************************
# Procedure:   pfile_write
#
# Description: Procedure to write a variable to file.
#
# Parameters:  The filename to write to,
#              The data variable.
#
# Returns:     Nothing
#************************************************************************

proc pfile_write { filename data } {
  return  [catch {
    set fileid [open $filename "w+"]
    puts $fileid $data
    close $fileid
  }]
}
#End pfile_write

#************************************************************************
# Procedure:   pFormatSpinner
#
# Description: Procedure to format data for spinner file.
#
# Parameters:  The data to format.
#
# Returns:     Nothing
#************************************************************************

    proc pFormatSpinner { lData sHead sType } {
    
        global lAccessModes
        global sPositive
        global sNegative
        global bTemplate
     
        set sDelimit "\t"
        set sFormat ""
    
        if { [ llength $lData ] == 0 && !$bTemplate } {
            append sFormat "No Data"
            return $sFormat
        }
    
        append sFormat "State"
        append sFormat "${sDelimit}User"
    
        # construct the access headers
        foreach sMode $lAccessModes {
            append sFormat "$sDelimit$sMode"
        }
        append sFormat "${sDelimit}Filter"
        append sFormat "\n"
    
        foreach line $lData {
            if { $line == "" } {
                continue
            }
            set sPolicyDetails [ lindex $line 0 ]
            set sPolicyData [ lindex $line 1 ]
            set sFilter [ lindex $sPolicyData 1 ]
            set sLeft [ split [ lindex $line 0 ] , ]
            set sOwner [ lindex $sLeft 2 ]
            set sLeft [ split [ lindex $sLeft 0 ] | ]
            set sPolicy [ lindex $sLeft 0 ]
            set sState [ lindex $sLeft 2 ]
            set sRights [ lindex $sPolicyData 0 ]
    
            append sFormat "$sState"
            append sFormat "$sDelimit$sOwner"
    
            if { $sRights == "all" } {
                set sNegativeValue $sPositive
            } else {
                set sNegativeValue $sNegative
            }
            foreach sMode $lAccessModes {
                set sMode [string tolower $sMode]
                if { [ lsearch $sRights $sMode ] == -1 } {
                    append sFormat "$sDelimit$sNegativeValue"
                } else {
                    append sFormat "$sDelimit$sPositive"
                }
            }
            append sFormat "$sDelimit$sFilter"
            append sFormat "\n"
    
        }
        return $sFormat
    }
#End pFormatSpinner

# Main
   set sFilter [mql get env 1]
   set bTemplate [mql get env 2]
   set bSpinnerAgentFilter [mql get env 3]
   set sGreaterThanEqualDate [mql get env 4]
   set sLessThanEqualDate [mql get env 5]

   if {$sGreaterThanEqualDate != ""} {
      set sModDateMin [clock scan $sGreaterThanEqualDate]
   } else {
      set sModDateMin ""
   }
   if {$sLessThanEqualDate != ""} {
      set sModDateMax [clock scan $sLessThanEqualDate]
   } else {
      set sModDateMax ""
   }
   
   set sMxVersion [mql version]
   if {[string first "V6" $sMxVersion] >= 0} {
      set rAppend ""
	  if {[string range $sMxVersion 7 7] == "x"} {set rAppend ".1"}
      set sMxVersion [string range $sMxVersion 3 6]
	  if {$rAppend != ""} {append sMxVersion $rAppend}
   } else {
      set sMxVersion [join [lrange [split $sMxVersion .] 0 1] .]
   }
# Major/Minor Check - ION - 10/1/2011
   if {[catch {
      set sTestMm [mql validate upgrade revisions]
      if {$sTestMm == "" || [string tolower $sTestMm] == "validation of upgrade complete"} {
         set bMm TRUE
	  } else {
	     set bMm FALSE
	  }
   } sMsg] != 0} {
      set bMm FALSE
   }
   
    set sSpinnerPath [mql get env SPINNERPATH]
    if {$sSpinnerPath == ""} {
       set sOS [string tolower $tcl_platform(os)];
       set sSuffix [clock format [clock seconds] -format "%Y%m%d"]
       
       if { [string tolower [string range $sOS 0 5]] == "window" } {
          set sSpinnerPath "c:/temp/SpinnerAgent$sSuffix";
       } else {
          set sSpinnerPath "/tmp/SpinnerAgent$sSuffix";
       }
       file mkdir "$sSpinnerPath/Business/Policy"
    }
 
# Major/Minor Mod - ION - 10/1/2012
    if {$bMm} {
       set lAccessModes [ list Read Modify Delete Checkout Checkin Schedule Lock \
           Unlock Execute Freeze Thaw Create Revise MajorRevise Promote Demote Grant \
           Enable Disable Override ChangeName ChangeType ChangeOwner ChangePolicy Revoke \
           ChangeVault FromConnect ToConnect FromDisconnect ToDisconnect \
           ViewForm Modifyform Show ]
    } else {
    set lAccessModes [ list Read Modify Delete Checkout Checkin Schedule Lock \
        Unlock Execute Freeze Thaw Create Revise Promote Demote Grant Enable \
        Disable Override ChangeName ChangeType ChangeOwner ChangePolicy Revoke \
        ChangeVault FromConnect ToConnect FromDisconnect ToDisconnect \
        ViewForm Modifyform Show ]
    }    
    set sPositive Y
    set sNegative "-"

    set lPolicy [split [mql list policy $sFilter] \n]

    foreach sPol $lPolicy {
       set bPass TRUE
       if {$sMxVersion > 8.9} {
          set sModDate [mql print policy $sPol select modified dump]
          set sModDate [clock scan [clock format [clock scan $sModDate] -format "%m/%d/%Y"]]
          if {$sModDateMin != "" && $sModDate < $sModDateMin} {
             set bPass FALSE
          } elseif {$sModDateMax != "" && $sModDate > $sModDateMax} {
             set bPass FALSE
          }
       }
        
       if {($bPass == "TRUE") && ($bSpinnerAgentFilter != "TRUE" || [mql print policy $sPol select property\[SpinnerAgent\] dump] != "")} {
          set sStates [ split [ mql print policy $sPol select state dump | ] | ]
          set bAllstate FALSE
          if {$sMxVersion >= 10.8} {set bAllstate [ mql print policy $sPol select allstate dump ]}
          if {$bAllstate && $sStates != [list ]} {lappend sStates "allstate"}
          set sStOrder 0
          if {!$bTemplate} {
             foreach sSt $sStates {
                 if {$sSt == "allstate"} {
                     set sOwner [ split [ string trim [ mql print policy $sPol select allstate.owneraccess dump | ] ] , ]
                     set data($sPol|$sStOrder|$sSt,0,Owner) [ list $sOwner "" ]
                     set sPublic [ split [ string trim [ mql print policy $sPol select allstate.publicaccess dump | ] ] , ]
                     set data($sPol|$sStOrder|$sSt,0,Public) [ list $sPublic "" ]
                     set sUsers [ split [ mql print policy $sPol select allstate.access ] \n ]
                 } else {
                     set sOwner [ split [ string trim [ mql print policy $sPol select state\[$sSt\].owneraccess dump | ] ] , ]
                     set data($sPol|$sStOrder|$sSt,0,Owner) [ list $sOwner "" ]
                     set sPublic [ split [ string trim [ mql print policy $sPol select state\[$sSt\].publicaccess dump | ] ] , ]
                     set data($sPol|$sStOrder|$sSt,0,Public) [ list $sPublic "" ]
                     set sUsers [ split [ mql print policy $sPol select state\[$sSt\].access ] \n ]
                 }
                 foreach i $sUsers {
                     set i [ string trim $i ]
                     if {[string first "policy" $i] == 0} {continue}
                     if { $i != "" } {
                         set sLine [ split $i "=" ]
                         set sUs [string range [ lindex $sLine 0 ] [ string first "." $sLine ] end ]
                         set sRights [ split [ string trim [ lindex $sLine 1 ] ] , ]
                         if { $sRights == "all" } {
#                              set sRights $lAccessModes
                         } elseif { $sRights == "none" } {
                             set sRights ""
                         }
                         if {[string first "access\[" $sUs] > -1} {
                             regsub "access\134\[" $sUs "|" sUs
                             set sUs [lindex [split $sUs |] 1]
                             regsub "\134\]" $sUs "" sOwner
                             #Start fix for incident 386952 by sn7
                             set sOwner [string trim $sOwner]
                             #End fix for incident 386952 by sn7
                             if {$sSt == "allstate"} {
                                 set sExpression [ mql print policy "$sPol" select allstate.filter\[$sOwner\] dump ]
                             } else {
                                 set sExpression [ mql print policy "$sPol" select state\[$sSt\].filter\[$sOwner\] dump ]
                             }
                             set data($sPol|$sStOrder|$sSt,1,$sOwner) [ list $sRights $sExpression ]
                         }
                     }
                 }
                 incr sStOrder
             }
          }
       } 
    }
 
    set sSpin ""
    foreach sP $lPolicy {
        set pu [ lsort -dictionary [ array name data "$sP|*|*,*,*" ] ]
        foreach i $pu {
            lappend sSpin [ list $i $data($i) ]
        }
        set sPolicySpin [ pFormatSpinner $sSpin $sP Policy ]
        pfile_write "$sSpinnerPath/Business/Policy/$sP.xls" $sPolicySpin
        set sSpin ""
    }
    puts "Policy State Access data loaded in directory: $sSpinnerPath/Business/Policy"
}
