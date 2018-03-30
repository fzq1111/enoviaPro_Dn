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

#  Set up array for symbolic name mapping
#
   set lsPropertyName [mql get env PROPERTYNAME]
   set lsPropertyTo [mql get env PROPERTYTO]
   set sTypeReplace "table "

   foreach sPropertyName $lsPropertyName sPropertyTo $lsPropertyTo {
      set sSchemaTest [lindex [split $sPropertyName "_"] 0]
      if {$sSchemaTest == "table"} {
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

   set sPath "$sSpinnerPath/Business/SpinnerTableData\_ALL.xls"
   set lsTable [split [mql list table system] \n]
   set sFile "Name\tRegistry Name\tDescription\tColumn Names (in order-use \"|\" delim)\tHidden (boolean)\n"
   # START--- Added by Solution Library Team for Incidents SR00040360 and SR00039673
   set sPath2 "$sSpinnerPath/Business/SpinnerTableColumnData\_ALL.xls"
    # END-----      
   set sFile2 "Table Name\tColumn Name\tColumn Label\tCol Description\tExpression Type (bus or \"\" / rel)\tExpression\tHref\tSetting Names (use \"|\" delim)\tSetting Values (use \"|\" delim)\tUsers (use \"|\" delim)\tAlt\tRange\tUpdate\tSortType (alpha / numeric / other / none or \"\")\tHidden\n"
   set sMxVersion [mql get env MXVERSION]
   if {$sMxVersion == ""} {
      set sMxVersion "2012"
   }
   
  
  
   
   if {!$bTemplate} {
      foreach sTable $lsTable {
         set bPass TRUE
         set sModDate [mql print table $sTable system select modified dump]
         set sModDate [clock scan [clock format [clock scan $sModDate] -format "%m/%d/%Y"]]
         if {$sModDateMin != "" && $sModDate < $sModDateMin} {
            set bPass FALSE
         } elseif {$sModDateMax != "" && $sModDate > $sModDateMax} {
            set bPass FALSE
         }
         
         if {($bPass == "TRUE") && ($bSpinnerAgentFilter != "TRUE" || [mql print table $sTable system select property\[SpinnerAgent\] dump] != "")} {
            set sName [mql print table $sTable system select name dump]
			
            for {set i 0} {$i < [string length $sName]} {incr i} {
               if {[string range $sName $i $i] == " "} {
                  regsub " " $sName " " sName
				  
               } else {
                  break
               }
            }
            set sOrigName ""
            catch {set sOrigName $aSymbolic($sTable)} sMsg
            regsub -all " " $sTable "" sOrigNameTest
            if {$sOrigNameTest == $sOrigName} {
               set sOrigName $sTable
            }
            set sDescription [mql print table $sTable system select description dump]
            set sHidden [mql print table $sTable system select hidden dump]
            set slsColumn [mql print table $sTable system select column dump " | "]
            for {set i 0} {$i < [string length $slsColumn]} {incr i} {
               if {[string range $slsColumn $i $i] == " "} {
			    
                  regsub " " $slsColumn " " slsColumn
				  
               } else {
                  break
               }
            }
			
            regsub -all " \\\|  " $slsColumn " \| " slsColumn
			
            append sFile "$sName\t$sOrigName\t$sDescription\t$slsColumn\t$sHidden\n"
			
# Table Column
            set lsColumn [split [mql print table $sTable system select column dump |] |]
		    set colvalue " "
			set count 0;
            foreach sColumn $lsColumn {
			
			incr count
               set sName $sColumn
			  
			   for {set i 0} {$i < [string length $sName]} {incr i} {
				   
			      if {[string range $sName $i $i] == " "} {
				  
				 
                     regsub " " $sName "<SPACE>" sName
#					   set slsSettingName [mql print table $sTable system select column\[$sColumn\].setting dump " | "]
#					   set slsSettingValue [mql print table $sTable system select column\[$sColumn\].setting.value dump " | "]
					  
					 
                  } else {
                     break
                  } 
				  				  			
               }
			   
			   						  
			 #  regsub -all " \\\|  " $slsColumn " \| <SPACE>" slsColumn
			   
               set sLabel [mql print table $sTable system select column\[$sColumn\].label dump]
               set sDescription [mql print table $sTable system select column\[$sColumn\].description dump]
               set sExpressionType [mql print table $sTable system select column\[$sColumn\].expressiontype dump]
               set sExpression [mql print table $sTable system select column\[$sColumn\].expression dump]
               set sHref [mql print table $sTable system select column\[$sColumn\].href dump]
               set sAlt [mql print table $sTable system select column\[$sColumn\].alt dump]
               set sRange [mql print table $sTable system select column\[$sColumn\].range dump]
               set sUpdate [mql print table $sTable system select column\[$sColumn\].update dump]
			   
			   
			   
               set slsSettingName [mql print table $sTable system select column\[$sColumn\].setting dump " | "]
               set slsSettingValue [mql print table $sTable system select column\[$sColumn\].setting.value dump " | "]
			   
               if {$sMxVersion >= 9.6} {
                  set slsUser [mql print table $sTable system select column\[$sColumn\].user dump " | "]
                  set sAlt [mql print table $sTable system select column\[$sColumn\].alt dump]
                  set sRange [mql print table $sTable system select column\[$sColumn\].range dump]
                  set sUpdate [mql print table $sTable system select column\[$sColumn\].update dump]
                  set sSortType "none"
                  set lsPrint [split [mql print table $sTable system] \n]
                  set bTrip "FALSE"
                  foreach sPrint $lsPrint {
                     set sPrint [string trim $sPrint]
                     if {[string range $sPrint 0 3] == "name" && [string first $sColumn $sPrint] > 3} {
                        set bTrip TRUE
                     } elseif {$bTrip && [string range $sPrint 0 3] == "name"} {
                        break
                     } elseif {$bTrip} {
                        if {[string range $sPrint 0 7] == "sorttype"} {
                           regsub "sorttype" $sPrint "" sPrint
                           set sSortType [string trim $sPrint]
                           break
                        }
                     } 
                  }
                  set sHidden [mql print table $sTable system select column\[$sColumn\].hidden dump]
               } else {
                  set slsUser ""
                  set sAlt ""
                  set sRange ""
                  set sUpdate ""
                  set sSortType ""
                  set sHidden ""
               }
               set sTableName $sTable
               for {set i 0} {$i < [string length $sTableName]} {incr i} {
                  if {[string range $sTableName $i $i] == " "} {
                     regsub " " $sTableName " " sTableName
                  } else {
                     break
                  }
               }
			   
               append sFile2 "$sTableName\t$sName\t$sLabel\t$sDescription\t$sExpressionType\t$sExpression\t$sHref\t$slsSettingName\t$slsSettingValue\t$slsUser\t$sAlt\t$sRange\t$sUpdate\t$sSortType\t$sHidden\n"
			               }
         }
      }
   }
   set iFile [open $sPath w]
   puts $iFile $sFile
   close $iFile
   set iFile [open $sPath2 w]
   puts $iFile $sFile2
   close $iFile
   
}
