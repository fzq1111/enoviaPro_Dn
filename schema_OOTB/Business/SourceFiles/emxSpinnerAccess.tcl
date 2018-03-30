

#####################################################################*2013
#
# @progdoc      emxSpinnerAccess.tcl vMV6R2013 (Build 11.10.1)
#
# @Description: This is schema spinner that adds or modifies schema
#               policy and/or rule access.  Invoked from program
#               'emxSpinnerAgent.tcl' but may be run separately.
#
# @Parameters:  None
#
# @Usage:       Run this program for an MQL command window w/data files in directories:
#               . (current dir)         emxSpinnerAgent.tcl, emxSpinnerAccess.tcl programs
#               ./Business/Policy       Policy access data files from Bus Doc Generator program
#               ./Business/Rule         Rule access data files from Bus Doc Generator program        
#
# @progdoc      Copyright (c) ENOVIA Inc., June 26, 2002
#
# @Originator:  Greg Inglis
#
#########################################################################
#
# @Modifications: Venkatesh Harikrishan 04/03/2006 - Fix for Incident 317721
#
#########################################################################
tcl;

eval {
   if {[info host] == "mostermant43" } {
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
    set fileid [open $filename "a+"]
    puts $fileid $data
    close $fileid
  }]
}
#End pfile_write


#************************************************************************
# Procedure:   pfile_read
#
# Description: Procedure to read a file.
#
# Parameters:  The filename to read from.
#
# Returns:     The file data
#************************************************************************

proc pfile_read { filename } {
  global sPolicyRule aPolicyRule
  set data ""
  # IR Fix 317721
  set sSpinnerDir [mql get env SPINNERPATH]
  set sFile "$sSpinnerDir/Business/$aPolicyRule($sPolicyRule)/$filename"
  #set sFile "./Business/$aPolicyRule($sPolicyRule)/$filename"

  if { [file readable $sFile] } {
    set fd [open $sFile r]
    set data [read $fd]
    close $fd
  } else { # IR Fix 317721
  	puts "File Not Found"
  }
  return $data
}
#End file_read


################################################################################
# Replace_Space
#   Replace space characters by underscore
#   
#   Parameters :
#       string
#   Return :
#       string 
#
proc Replace_Space { string } {
    regsub -all -- " " $string "_" string
    return $string
}


proc pProcessMqlCmd { sAction sType sName sMql } {

    global sMsg_Log iAccessError bScan sLogFileError bSpinnerAgent
    append sMsg_Log "# ACTION: $sAction $sType $sName\n"

    if {$bScan} {
        append sMsg_Log "$sMql\n"
        puts -nonewline ":"
        set sMsg ""
    } else {
    	mql start transaction update
        if { [ catch { eval $sMql } sMsg ] != 0 } {
            set sErrMsg "$sAction $sType $sName NOT successful.\nCommand: $sMql\nError Reason is $sMsg\n"
            append sMsg_Log $sErrMsg
            mql abort transaction
            puts -nonewline "!"
            if {$bSpinnerAgent} {
               set iLogFileErr [open $sLogFileError a+]
               puts $iLogFileErr $sErrMsg
               close $iLogFileErr
            }
            incr iAccessError
        } else {
            append sMsg_Log "# $sAction $sType $sName Successful."
            puts -nonewline ":"
            mql commit transaction
        }
    }
    return $sMsg
}
#End pProcessMqlCmd


# Procedure to pass tcl-type variables in tcl eval commands
   proc pRegSubEscape {sEscape} {
      regsub -all "\134$" $sEscape "\134\134\$" sEscape
      regsub -all "\134{" $sEscape "\134\134\173" sEscape
      regsub -all "\134}" $sEscape "\134\134\175" sEscape
      regsub -all "\134\133" $sEscape "\134\134\133" sEscape
      regsub -all "\134\135" $sEscape "\134\134\135" sEscape
      if {[string range $sEscape 0 0] == "\042" && [string range $sEscape end end] == "\042" && [string length $sEscape] > 2} {
         set iLast [expr [string length $sEscape] -2]
   	 set sEscape [string range $sEscape 1 $iLast]
      }
      regsub -all "\042\042" $sEscape "\042" sEscape
      regsub -all "\042" $sEscape "\134\042" sEscape
      return $sEscape
   }
#End pRegSubEscape


proc pCompareLists { lList1 lList2 } {

    set lCommon {}
    set lUnique1 {}
    foreach i1 $lList1 {
        set nFound [ lsearch $lList2 $i1 ]
        if { $nFound == -1 } {
            lappend lUnique1 $i1
        } else {
            lappend lCommon $i1
            set lList2 [ lreplace $lList2 $nFound $nFound ]
        }
    }
    set lResults [ list $lUnique1 $lCommon $lList2 ]
    return $lResults
}


proc pPolicyData { sPol } {
    global sPolicyRule bAllState bMm

# Major/Minor Mod - ION - 10/1/2012
    if {$bMm} {
       set lAccessModes [ list read modify delete checkout checkin schedule lock \
           unlock execute freeze thaw create revise majorrevise promote demote grant \
           enable disable override changename changetype changeowner changepolicy revoke \
           changevault fromconnect toconnect fromdisconnect todisconnect \
           viewform modifyform show ]
	} else {
    set lAccessModes [ list read modify delete checkout checkin schedule lock \
        unlock execute freeze thaw create revise promote demote grant enable \
        disable override changename changetype changeowner changepolicy revoke \
        changevault fromconnect toconnect fromdisconnect todisconnect \
        viewform modifyform show ]
    }
    set lData {}
    set sStates [list 999999]
    if {$sPolicyRule == "policy"} {
        set sStates [ split [ mql print policy $sPol select state dump | ] | ]
        if {$bAllState && $sStates != [list ]} {lappend sStates "allstate"}
    }
    foreach sSt $sStates {
        set sStateCmdOwner "owneraccess"
        set sStateCmdPublic "publicaccess"
        set sStateCmdAccess "access"
        set sStateCmdFilter "filter"
        if {$sPolicyRule == "policy"} {
            if {$sSt == "allstate"} {
                set sStateCmdOwner "allstate.owneraccess"
                set sStateCmdPublic "allstate.publicaccess"
                set sStateCmdAccess "allstate.access"
                set sStateCmdFilter "allstate.filter"
            } else {           
                set sStateCmdOwner "state\134\[\$sSt\134\].owneraccess"
                set sStateCmdPublic "state\134\[\$sSt\134\].publicaccess"
                set sStateCmdAccess "state\134\[\$sSt\134\].access"
                set sStateCmdFilter "state\134\[\$sSt\134\].filter"
            }
        }
        set sOwner Owner
        eval "set sAccess \[mql print $sPolicyRule \"$sPol\" select $sStateCmdOwner dump \]"
        set sRights [ split [ string trim $sAccess ] , ]
        if { $sRights == "all" } {
            set sRights $lAccessModes
        } elseif { $sRights == "none" } {
            set sRights ""
        }
        lappend lData [ list $sSt $sOwner $sRights "" ]
        set sOwner Public
        eval "set sAccess \[mql print $sPolicyRule \"$sPol\" select $sStateCmdPublic dump \]"
        set sRights [ split [ string trim $sAccess ] , ]
        if { $sRights == "all" } {
            set sRights $lAccessModes
        } elseif { $sRights == "none" } {
            set sRights ""
        }
        lappend lData [ list $sSt $sOwner $sRights "" ]
        
        eval "set sUser \[ mql print $sPolicyRule \"$sPol\" select $sStateCmdAccess \]"
        set sUsers [ split $sUser \n ]
        foreach i $sUsers {
            set i [ string trim $i ]
            if {[string first $sPolicyRule $i] == 0} {continue}
            if { $i != "" } {
                #MRA MOD BEGIN
                if {[string first "." $i] >= 0} {
                    #set i [ lindex [ split $i "." ] 1 ]
                }
                set sLine [ split $i "=" ]
                set sUs [string trim [string range [ lindex $sLine 0 ] [ string first "." $sLine ] end ] ]
                #set sLine [ split $i "=" ]
                #MRA MOD END
                set sRights [ split [ string trim [ lindex $sLine 1 ] ] , ]
                if { $sRights == "all" } {
                    #MRA MOD BEGIN
                    #set sRights $lAccessModes
		#KYB fixed policy issue for Shadow Agent,System Conversion Manager,System Transition Manager having access all
		    set sRights $lAccessModes
                    #MRA MOD END
                } elseif { $sRights == "none" } {
                    set sRights ""
                }
                #MRA MOD BEGIN
                #set sUs [string trim [ lindex $sLine 0 ] ]
                #MRA MOD END
                if {[string first "access\[" $sUs] > -1} {
                    regsub "access\134\[" $sUs "|" sUs
                    set sUs [lindex [split $sUs |] 1]
                    regsub "\134\]" $sUs "" sOwner
                    eval "set sFilter \[ mql print $sPolicyRule \"$sPol\" select $sStateCmdFilter\134\[$sOwner\134\] dump \]"
                    lappend lData [ list $sSt $sOwner $sRights $sFilter ]
                }
            }
        }
    }
    return $lData
}
#End pPolicyData

#main

    set sMxVersion [mql version]
    if {[string first "V6" $sMxVersion] >= 0} {
       set rAppend ""
	   if {[string range $sMxVersion 7 7] == "x"} {set rAppend ".1"}
       set sMxVersion [string range $sMxVersion 3 6]
	   if {$rAppend != ""} {append sMxVersion $rAppend}
    } else {
       set sMxVersion [join [lrange [split $sMxVersion .] 0 1] .]
    }

# Major/Minor Check
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

    set bScan [mql get env SPINNERSCANMODE]; #scan mode
    if {$bScan != "TRUE"} {set bScan FALSE}
    set bShowModOnly [mql get env SHOWMODONLY]
    set lFilesXLS [mql get env FILELIST]

    array set aPolicyRule [list policy Policy rule Rule]
    set sSuffix [clock format [clock seconds] -format ".%m%d%y"]
    if {$bScan} {set sSuffix ".SCAN"}
    set sDelimit "\t"

    set sPolicyRuleAccess [mql get env ACCESSTYPE]
    if { $sPolicyRuleAccess == ""} {
       set lsPolicyRule [list policy rule]
    } else {
       regsub "access" $sPolicyRuleAccess "" sPolicyRule
       set lsPolicyRule [list $sPolicyRule]
    }
    foreach sPolicyRule $lsPolicyRule {
        set iAccessError 0
        set sMsg_Log ""
        eval "set slPolicy \[mql list \"$sPolicyRule\" * \]"
        set lPolicies [split $slPolicy \n]
       
        if {[mql get env SPINNERLOGFILE] != ""} {; # SpinnerAgent Hook
           set bSpinnerAgent TRUE
           set sOutFile "[mql get env SPINNERLOGFILE]"
           set sLogFileError [mql get env SPINNERERRORLOG]
        } else {
           set bSpinnerAgent FALSE    
           set sOutFile "./logs/$aPolicyRule($sPolicyRule)Access$sSuffix.log"
           file delete $sOutFile
        }
        
        set lFiles ""
        if {$lFilesXLS == ""} {set lFilesXLS [ glob -nocomplain "./Business/$aPolicyRule($sPolicyRule)/*.xls" ]}
        foreach filename $lFilesXLS {
            set name [file rootname [file tail $filename ]]
            lappend lFiles $name
        }
        
        set lNames [ pCompareLists $lFiles $lPolicies ]
    
        set sExtra [ lindex $lNames 0 ]
        set sCommon [ lindex $lNames 1 ]
        
        foreach sName $sCommon {
            set bAllState FALSE
            if {$sMxVersion >= 10.8} {
                catch {set bAllState [mql print policy $sName select allstate dump]} sMsg
            }
            pfile_write $sOutFile $sMsg_Log
            set sMsg_Log ""
            set sPolicyFile {}
            set sPolicyDB [ pPolicyData $sName ]
	    # IR Fix 317721
            set lFileData [ split [ pfile_read "$sName.xls" ] \n ]
            set nCount 0
            foreach sLine $lFileData {
                set sLineData [ split $sLine $sDelimit ]
                set nL [ llength $sLineData ]
                if { $sLineData == "" } {
                    continue
                }
                if { $nCount == 0 } {
                    set sHeader [ string tolower $sLineData ]
                } else {
                    # process the data line!!
                    if {$sPolicyRule == "rule"} {
                         set sState 999999
                    } else {
                         set sState [ lindex $sLineData 0 ]
                    }
                    set sOwner [ lindex $sLineData 1 ]

                    set nPos 0
                    set sRights {}
                    set sFilter {}
                    foreach  i $sHeader j $sLineData {
                        if { $nPos > 1 } {
                            set bHasAccess [ string tolower $j ]
                            if {$i == "filter"} {
                                set sFilter $j
                            } elseif { $bHasAccess == "y" } {
                                lappend sRights $i
                            }
                        }
                        incr nPos
                    }
                    lappend sPolicyFile [ list $sState $sOwner $sRights $sFilter ]
                }
                incr nCount
            }
            set lRes [ pCompareLists $sPolicyFile $sPolicyDB ]
            set lLeft [ lindex $lRes 0 ]
            set lComm [ lindex $lRes 1 ]
            set lRight [ lindex $lRes 2 ]
    
            append sMsg_Log "\n# \[[clock format [clock seconds] -format %H:%M:%S]\] $aPolicyRule($sPolicyRule)Access '$sName':"
            puts -nonewline "\n$sPolicyRule $sName"
            
            foreach sCommon $lComm {
                set sSt [ lindex $sCommon 0 ]
                if {$sSt == "999999"} {
                   set sInsert ""
                } else {
                   set sInsert " state $sSt"
                }
                set sUser [ lindex $sCommon 1 ]
                if {$bShowModOnly == "FALSE"} {append sMsg_Log "# No Change Required for$sInsert $sUser\n"}
                puts -nonewline "."
            }
            
            foreach sLeft $lLeft {
                set sSt [ lindex $sLeft 0 ]
                if {$sSt == "999999"} {
                    set sInsert ""
                    set sCmdInsert ""
                } else {
                    if {$sSt == "allstate"} {
                        if {$bAllState} {
                            set sInsert " allstate"
                            set sCmdInsert "allstate"
                        } else {
                            continue
                        }
                    } else {
                        set sInsert " state $sSt"
                        set sCmdInsert "state \134\"$sSt\134\""
                    }
                }
                set sOwn [string trim [ lindex $sLeft 1 ]]
                set sAcc [ lindex $sLeft 2 ]
                set sFilter [ lindex $sLeft 3 ]
# JD le 18/01/12 : correction bug lorsque plusieurs roles commencent par le même nom : VPLMLeader et VPLMLeaderChangeSheet
#                set nIndex [ lsearch -glob $lRight [list $sSt $sOwn*] ]
                set nIndex [ lsearch -glob $lRight [list $sSt $sOwn [list *] ] ]
                
                set sDB [ lindex $lRight $nIndex ]
                set sDBSt [ lindex $sDB 0 ]
                set sDBOwn [ lindex $sDB 1 ]
                set sDBAcc [ lindex $sDB 2 ]
                set sDBFilter [ lindex $sDB 3 ]
                
                set lReqAcc [ pCompareLists $sAcc $sDBAcc ]
                
                set lAdd [ join [ lindex $lReqAcc 0 ] , ]
                set lDel [ join [ lindex $lReqAcc 2 ] , ]
                
                if {$sDBFilter != ""} {set sDBFilter [pRegSubEscape $sDBFilter]}
                if {$sFilter != ""} {set sFilter [pRegSubEscape $sFilter]}
                
                if {[ llength $lAdd ] != 0 || $sFilter != $sDBFilter} {
                  
                    if {$lAdd == ""} {set lAdd none}
                    append sMsg_Log "mod $aPolicyRule($sPolicyRule) $sName$sInsert add user \"$sOwn\" $lAdd filter \"$sFilter\"\n"
                    
                    if { $sOwn == "Public" || $sOwn == "Owner" } {
                        set sCmd "mql mod $sPolicyRule \"$sName\" $sCmdInsert add \"$sOwn\" \"$lAdd\""
                    } else {
                        set sCmd "mql mod $sPolicyRule \"$sName\" $sCmdInsert add user \"$sOwn\" \"$lAdd\" filter \"$sFilter\""
                    }
                    pProcessMqlCmd Mod $aPolicyRule($sPolicyRule) $sName $sCmd
                } else {
                    puts -nonewline "."
                }
    
                if { [ llength $lDel ] != 0 } {
                    append sMsg_Log "mod $aPolicyRule($sPolicyRule) $sName$sInsert remove $sOwn $lDel\n"                    

                    if { $sOwn == "Public" || $sOwn == "Owner" } {
                        set sCmd "mql mod $sPolicyRule \"$sName\" $sCmdInsert remove \"$sOwn\" \"$lDel\""
                    } else {
                        set sCmd "mql mod $sPolicyRule \"$sName\" $sCmdInsert remove user \"$sOwn\" \"$lDel\""
                    }
                    pProcessMqlCmd Mod $aPolicyRule($sPolicyRule) $sName $sCmd
                }
                
                if { $nIndex != -1 } {
                    set lRight [ lreplace $lRight $nIndex $nIndex ]
                }
            }
            set lLeft {}
            
            foreach sRight $lRight {
                set sSt [ lindex $sRight 0 ]
                if {$sSt == "999999"} {
                    set sInsert ""
                    set sCmdInsert ""
                } else {
                    if {$sSt == "allstate"} {
                        if {$bAllState} {
                            set sInsert " allstate"
                            set sCmdInsert "allstate"
                        } else {
                            continue
                        }
                    } else {
                        set sInsert " state $sSt"
                        set sCmdInsert "state \134\"$sSt\134\""
                    }
                }
                set sOwn [ lindex $sRight 1 ]
                append sMsg_Log "# Remove all access for $aPolicyRule($sPolicyRule) $sName$sInsert person $sOwn\n"
                
                if { $sOwn == "Public" || $sOwn == "Owner" } {
                    set sCmd "mql mod $sPolicyRule \"$sName\" $sCmdInsert remove \"$sOwn\" all"
                } else {
                    set sCmd "mql mod $sPolicyRule \"$sName\" $sCmdInsert remove user \"$sOwn\" all"
                }
                pProcessMqlCmd Mod $aPolicyRule($sPolicyRule) $sName $sCmd
            }
            set lRight {}
        }
        
        pfile_write $sOutFile $sMsg_Log
        if {$bSpinnerAgent} {pfile_write $sOutFile ""}
        puts ""
        mql set env ACCESSERROR $iAccessError
    }
}

