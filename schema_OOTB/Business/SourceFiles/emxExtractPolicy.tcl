


tcl;

eval {
   if {[info host] == "sn732plp" } {
      source "c:/Program Files/TclPro1.3/win32-ix86/bin/prodebug.tcl"
   	  set cmd "debugger_eval"
   	  set xxx [debugger_init]
   } else {
   	  set cmd "eval"
   }
}
$cmd {

   set sMxVersion [mql get env MXVERSION]
   if {$sMxVersion == ""} {
      set sMxVersion "2012"
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

#  Set up array for symbolic name mapping
#
   set lsPropertyName [split [mql print program eServiceSchemaVariableMapping.tcl select property.name dump |] |]
   set lsPropertyTo [split [mql print program eServiceSchemaVariableMapping.tcl select property.to dump |] |]
   set sTypeReplace "policy "

   foreach sPropertyName $lsPropertyName sPropertyTo $lsPropertyTo {
      set sSchemaTest [lindex [split $sPropertyName "_"] 0]
      if {$sSchemaTest == "policy"} {
         regsub $sTypeReplace $sPropertyTo "" sPropertyTo
         regsub "_" $sPropertyName "|" sSymbolicName
         set sSymbolicName [lindex [split $sSymbolicName |] 1]
         array set aSymbolic [list $sPropertyTo $sSymbolicName]
      }
   }

   set sFilter [mql get env 1]
   set bTemplate [mql get env 2]
   set bSpinnerAgentFilter [mql get env 3]
   set sGreaterThanEqualDate [mql get env 4]
   set sLessThanEqualDate [mql get env 5]

   set sAppend ""
   if {$sFilter != ""} {
      regsub -all "\134\052" $sFilter "ALL" sAppend
      regsub -all "\134\174" $sAppend "-" sAppend
      regsub -all "/" $sAppend "-" sAppend
      regsub -all ":" $sAppend "-" sAppend
      regsub -all "<" $sAppend "-" sAppend
      regsub -all ">" $sAppend "-" sAppend
      regsub -all " " $sAppend "" sAppend
      set sAppend "_$sAppend"
   }
   
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
   
   set sSpinnerPath [mql get env SPINNERPATH]
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

   set sPath "$sSpinnerPath/Business/SpinnerPolicyData$sAppend.xls"
   set lsPolicy [split [mql list policy $sFilter] \n]
   set sFile "Name\tRegistry Name\tDescription\tRev Sequence (use 'continue' for '...')\tStore\tHidden (boolean)\tTypes (use \"|\" delim)\tFormats (use \"|\" delim)\tDefault Format\tLocking (boolean)\tState Names (in order-use \"|\" delim)\tState Registry Names (in order-use \"|\" delim)\tAllstate (boolean)\tIcon File\n"
   set sPath2 "$sSpinnerPath/Business/SpinnerPolicyStateData$sAppend.xls"
   set sFile2 "Policy Name\tState Name\tRevision (boolean)\tVersion (boolean)\tPromote (boolean)\tCheckout History (boolean)\tUsers for Access (use \"|\" delim)\tNotify Users (use \"|\" delim)\tNotify Message\tRoute User\tRoute Message\tSignatures (use \"|\" delim)\tIcon File\n"
    ######## Added By SL Team for Policy issue (Policy xls sheet name change)####### 
   set sPath3 "$sSpinnerPath/Business/SpinnerPolicyStateSignatureData$sAppend.xls"
    ######## END ####### 
   set sFile3 "Policy Name\tState Name\tSignature Name\tUsers for Approve (use \"|\" delim)\tUsers for Reject (use \"|\" delim)\tUsers for Ignore (use \"|\" delim)\tBranch State\tFilter\n"
# Major/Minor Mod - ION - 10/1/2012
   if {$bMm} {
         set sFile "Name\tRegistry Name\tDescription\t(Not Used)\tStore\tHidden (boolean)\tTypes (use \"|\" delim)\tFormats (use \"|\" delim)\tDefault Format\tLocking (boolean)\tState Names (in order-use \"|\" delim)\tState Registry Names (in order-use \"|\" delim)\tAllstate (boolean)\tMinor Rev Seq (use 'continue' for '...')\tMajor Rev Seq (use 'continue' for '...')\tDelimiter\tIcon File\n"
         set sFile2 "Policy Name\tState Name\t(Not Used)\tVersion (boolean)\tPromote (boolean)\tCheckout History (boolean)\tUsers for Access (use \"|\" delim)\tNotify Users (use \"|\" delim)\tNotify Message\tRoute User\tRoute Message\tSignatures (use \"|\" delim)\tMinor Revision (boolean)\tMajor Revision (boolean)\tPublished (boolean)\tIcon File\n"
   }
   
   if {!$bTemplate} {
      foreach sPolicy $lsPolicy {
         set bPass TRUE
         if {$sMxVersion > 8.9} {
            set sModDate [mql print policy $sPolicy select modified dump]
            set sModDate [clock scan [clock format [clock scan $sModDate] -format "%m/%d/%Y"]]
            if {$sModDateMin != "" && $sModDate < $sModDateMin} {
               set bPass FALSE
            } elseif {$sModDateMax != "" && $sModDate > $sModDateMax} {
               set bPass FALSE
            }
         }
         
         if {($bPass == "TRUE") && ($bSpinnerAgentFilter != "TRUE" || [mql print policy $sPolicy select property\[SpinnerAgent\] dump] != "")} {
            set sName [mql print policy $sPolicy select name dump]
            set sOrigName ""
            catch {set sOrigName $aSymbolic($sPolicy)} sMsg
            regsub -all " " $sPolicy "" sOrigNameTest
            if {$sOrigNameTest == $sOrigName} {
               set sOrigName $sPolicy
            }
            set sRevSequence ""
			set sMajorRevSeq ""
			set sMinorRevSeq ""
			set sDelimiter ""
# Major/Minor Mod - ION - 10/1/2012
			if {$bMm} {
			   set sMinorRevSeq [mql print policy $sPolicy select minorsequence dump]
               regsub -all "\\\056\\\056\\\056" $sMinorRevSeq "continue" sMinorRevSeq
			   set sMajorRevSeq [mql print policy $sPolicy select majorsequence dump]
               regsub -all "\\\056\\\056\\\056" $sMajorRevSeq "continue" sMajorRevSeq
			   set sDelimiter [mql print policy $sPolicy select delimiter dump]
			} else {   
            set sRevSequence [mql print policy $sPolicy select revision dump]
            #Start fix for continue issue seen in policy revision sequences 
            regsub -all "\\\056\\\056\\\056" $sRevSequence "continue" sRevSequence
            #End fix for continue issue seen in policy revision sequences 
			}
            set bHidden [mql print policy $sPolicy select hidden dump]
            set bLocking [mql print policy $sPolicy select islockingenforced dump]
            
            set slsType [mql print policy $sPolicy select type dump " | "]
            set slsFormat [mql print policy $sPolicy select format dump " | "]
            set slsState [mql print policy $sPolicy select state dump " | "]
            
            set lsState [split [mql print policy $sPolicy select state dump |] |]
            foreach sState $lsState {
            	  array set aStateOrig [list $sState ""]
            } 
            set lsStateProp [split [mql print policy $sPolicy select property dump |] |]
            foreach sStateProp $lsStateProp {
               if {[string first "state_" $sStateProp] == 0} {
                  regsub "state_" $sStateProp "" sStateProp
                  regsub "value " $sStateProp "" sStateProp
                  regsub " " $sStateProp "|" sStateProp
                  set lsStateName [split $sStateProp |]
                  set sStateOrig [lindex $lsStateName 0]
                  set sStateName [lindex $lsStateName 1]
                  array set aStateOrig [list $sStateName $sStateOrig]
               }
            }
      
            set lsState [split $slsState |]
            set slsStateOrig ""
            set bFirstFlag TRUE
            foreach sState $lsState {
               set sState [string trim $sState]
               set sStateOrig ""
               catch {set sStateOrig $aStateOrig($sState)} sMsg
               regsub -all " " $sState "" sStateTest
               if {$sStateTest == $sStateOrig} {
                  set sStateOrig $sState
               }
               if {$bFirstFlag == "TRUE"} {
                  set slsStateOrig $sStateOrig
                  set bFirstFlag FALSE
               } else {
                  append slsStateOrig " | $sStateOrig"
               }
            }
      
            set sStore [mql print policy $sPolicy select store dump]
            set sDefaultFormat [mql print policy $sPolicy select defaultformat dump]
            set sDescription [mql print policy $sPolicy select description dump]
            set bAllstate ""
            if {$sMxVersion >= 10.8} {set bAllstate [mql print policy $sPolicy select allstate dump]}
            append sFile "$sName\t$sOrigName\t$sDescription\t$sRevSequence\t$sStore\t$bHidden\t$slsType\t$slsFormat\t$sDefaultFormat\t$bLocking\t$slsState\t$slsStateOrig\t$bAllstate\t$sMinorRevSeq\t$sMajorRevSeq\t$sDelimiter\n"
# Policy State
            set lsState [split [mql print policy $sPolicy select state dump |] |]
            foreach sState $lsState {
# Major/Minor Mod - ION - 10/1/2012
			   if {$bMm} {
                  set sMinorRev [string tolower [mql print policy $sPolicy select state\[$sState\].minorrevisionable dump]]
                  set sMajorRev [string tolower [mql print policy $sPolicy select state\[$sState\].majorrevisionable dump]]
                  set sPublish [string tolower [mql print policy $sPolicy select state\[$sState\].published dump]]
				  set sRevision ""
			   } else {
               set sRevision [string tolower [mql print policy $sPolicy select state\[$sState\].revisionable dump]]
				  set sMinorRev ""
				  set sMajorRev ""
				  set sPublish ""
			   }
               set sVersion [string tolower [mql print policy $sPolicy select state\[$sState\].versionable dump]]
               set sPromote [string tolower [mql print policy $sPolicy select state\[$sState\].autopromote dump]]
               set sCheckout [string tolower [mql print policy $sPolicy select state\[$sState\].checkouthistory dump]]
               set sNotifyMsg [mql print policy $sPolicy select state\[$sState\].notify dump]
               set sRouteMsg [mql print policy $sPolicy select state\[$sState\].route dump]
               set slsSignature [mql print policy $sPolicy select state\[$sState\].signature dump " | "]
               
               set lsAccess ""
               set slsAccess ""
               set lsAccessTemp [split [mql print policy $sPolicy select state\[$sState\].access] \n]
               foreach sAccessTemp $lsAccessTemp {
                  set sAccessTemp [string trim $sAccessTemp]
                  if {[string first "\].access\[" $sAccessTemp] > -1} {
                     set iFirst [expr [string first "access\[" $sAccessTemp] + 7]
                     set iSecond [expr [string first "\] =" $sAccessTemp] -1]
                     lappend lsAccess [string range $sAccessTemp $iFirst $iSecond]
                  }
               }
               set slsAccess [join $lsAccess " | "]
            
               set slsNotify ""
               set lsNotifyTemp [split [mql print policy $sPolicy] \n]
               set bTrip "FALSE"
               foreach sNotifyTemp $lsNotifyTemp {
                  set sNotifyTemp [string trim $sNotifyTemp]
                  if {$sNotifyTemp == "state $sState"} {
                     set bTrip TRUE
                  } elseif {$bTrip == "TRUE" && [string range $sNotifyTemp 0 4] == "state"} {
                     break
                  } elseif {$bTrip == "TRUE"} {
                     if {[string range $sNotifyTemp 0 5] == "notify"} {
                        regsub "notify " $sNotifyTemp "" sNotifyTemp
                        regsub -all "'" $sNotifyTemp "" sNotifyTemp
                        if {$sNotifyMsg != "" } {regsub " $sNotifyMsg" $sNotifyTemp "" sNotifyTemp}
                        set sNotifyTemp [string trim $sNotifyTemp]
                        regsub -all "," $sNotifyTemp " | " slsNotify
                        break
                     }
                  } 
               }
               
               set sRoute ""
               set lsRouteTemp [split [mql print policy $sPolicy] \n]
               set bTrip "FALSE"
               foreach sRouteTemp $lsRouteTemp {
                  set sRouteTemp [string trim $sRouteTemp]
                  if {$sRouteTemp == "state $sState"} {
                     set bTrip TRUE
                  } elseif {$bTrip == "TRUE" && [string range $sRouteTemp 0 4] == "state"} {
                     break
                  } elseif {$bTrip == "TRUE"} {
                     if {[string range $sRouteTemp 0 4] == "route"} {
                        regsub "route " $sRouteTemp "" sRouteTemp
                        regsub -all "'" $sRouteTemp "" sRouteTemp
                        if {$sRouteMsg != ""} {regsub " $sRouteMsg" $sRouteTemp "" sRouteTemp}
                        set sRoute [string trim $sRouteTemp]
                        break
                     }
                  }
               }
               append sFile2 "$sPolicy\t$sState\t$sRevision\t$sVersion\t$sPromote\t$sCheckout\t$slsAccess\t$slsNotify\t$sNotifyMsg\t$sRoute\t$sRouteMsg\t$slsSignature\t$sMinorRev\t$sMajorRev\t$sPublish\n"
# Policy State Signature
               set lsSignature [split [mql print policy $sPolicy select state\[$sState\].signature dump |] |]
               foreach sSignature $lsSignature {
                  set slsApprove [mql print policy $sPolicy select state\[$sState\].signature\[$sSignature\].approve dump " | "]
                  set slsReject [mql print policy $sPolicy select state\[$sState\].signature\[$sSignature\].reject dump " | "]
                  set slsIgnore [mql print policy $sPolicy select state\[$sState\].signature\[$sSignature\].ignore dump " | "]
      
                  set sBranch ""
                  set sFilter ""
                  set sCatchStringOne "state $sState"
                  set sCatchStringTwo ""
                  set bPass false
                  set bTrip1 false
                  set bTrip2 false
                  
                  set lsPrint [split [mql print policy $sPolicy] \n]
      
                  foreach sPrint $lsPrint {
                     set sPrint [string trim $sPrint]
                  
                     if {$sCatchStringTwo == ""} {
                        if {[string first $sCatchStringOne $sPrint] == 0} {
                           set sCatchStringTwo "state"
                        }
                     } elseif {[string first $sCatchStringTwo $sPrint] == 0} {
                        break
                     }
                     
                     if {$sCatchStringTwo != ""} {
                  
                        if {[string first "signature $sSignature" $sPrint] == 0} {
                           set bPass true
                        } elseif {$bPass == "true"} {
                  
                           if {[string first "branch" $sPrint] == 0} {
				 #Added if condition to check if Branch value is empty to fix incident SR00062107  by Solutions Library team  - start
				 if {$sBranch == ""} {
				 #Added if condition to check if Branch value is empty to fix incident SR00062107  by Solutions Library team  - end
                              set bTrip1 "true"
                              regsub "branch " $sPrint "" sBranch
                              set sBranch [string trim $sBranch]
                           }
			     #closing brace for 358272 fix
                           }
                           
                           if {[string first "filter" $sPrint] == 0} {
                              set bTrip2 "true"
                              regsub "filter " $sPrint "" sFilter
                              set sFilter [string trim $sFilter]
                           }
                           
                           if {$bTrip1 == "true" && $bTrip2 == "true"} {
                              break
                           }
                        }
                     }
                  }
                  append sFile3 "$sPolicy\t$sState\t$sSignature\t$slsApprove\t$slsReject\t$slsIgnore\t$sBranch\t$sFilter\n"
               }
            }
         }
      }
   }
   set iFile [open $sPath w]
   puts $iFile $sFile
   close $iFile
   puts "Policy data loaded in file $sPath"
   set iFile [open $sPath2 w]
   puts $iFile $sFile2
   close $iFile
   puts "Policy State data loaded in file $sPath2"
   set iFile [open $sPath3 w]
   puts $iFile $sFile3
   close $iFile
   puts "Policy State Signature data loaded in file $sPath3"
}
