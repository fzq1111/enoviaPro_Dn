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
   set sTypeReplace "form "

   foreach sPropertyName $lsPropertyName sPropertyTo $lsPropertyTo {
      set sSchemaTest [lindex [split $sPropertyName "_"] 0]
      if {$sSchemaTest == "form"} {
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

   set sPath "$sSpinnerPath/Business/SpinnerWebFormData$sAppend.xls"
   set lsWebForm [split [mql list form $sFilter] \n]
   set sFile "Name\tRegistry Name\tDescription\tField Names (in order-use \"|\" delim)\tHidden (boolean)\tTypes (use \"|\" delim)\n"
   set sPath2 "$sSpinnerPath/Business/SpinnerWebFormFieldData$sAppend.xls"
   set sFile2 "WebForm Name\tField Name\tField Label\tField Description\tExpression Type (bus or \"\" / rel)\tExpression\tHref\tSetting Names (use \"|\" delim)\tSetting Values (use \"|\" delim)\tUsers (use \"|\" delim)\tAlt\tRange\tUpdate\tField Order\tHidden\n"
   set sMxVersion [mql get env MXVERSION]
   if {$sMxVersion == ""} {
      set sMxVersion "2012"
   }
   
   if {!$bTemplate} {
      foreach sWebForm $lsWebForm {
         if {[mql print form $sWebForm select web dump] == "TRUE"} {
# Web Form
            set bPass TRUE
            set sModDate [mql print form $sWebForm select modified dump]
            set sModDate [clock scan [clock format [clock scan $sModDate] -format "%m/%d/%Y"]]
            if {$sModDateMin != "" && $sModDate < $sModDateMin} {
               set bPass FALSE
            } elseif {$sModDateMax != "" && $sModDate > $sModDateMax} {
               set bPass FALSE
            }
            
            if {($bPass == "TRUE") && ($bSpinnerAgentFilter != "TRUE" || [mql print form $sWebForm select property\[SpinnerAgent\] dump] != "")} {
               set sName [mql print form $sWebForm select name dump]
               for {set i 0} {$i < [string length $sName]} {incr i} {
                  if {[string range $sName $i $i] == " "} {
                     regsub " " $sName "<SPACE>" sName
                  } else {
                     break
                  }
               }
               set sOrigName ""
               catch {set sOrigName $aSymbolic($sWebForm)} sMsg
               regsub -all " " $sWebForm "" sOrigNameTest
               if {$sOrigNameTest == $sOrigName} {
                  set sOrigName $sWebForm
               }
               set sDescription [mql print form $sWebForm select description dump]
               set slsType [mql print form $sWebForm select type dump " | "]
               set sHidden [mql print form $sWebForm select hidden dump]
               set slsField [mql print form $sWebForm select field dump " | "]
               for {set i 0} {$i < [string length $slsField]} {incr i} {
                  if {[string range $slsField $i $i] == " "} {
                     regsub " " $slsField "<SPACE>" slsField
                  } else {
                     break
                  }
               }
               regsub -all " \\\|  " $slsField " \| <SPACE>" slsField
               append sFile "$sName\t$sOrigName\t$sDescription\t$slsField\t$sHidden\t$slsType\n"
# Web Form Field
               set lsField [split [mql print form $sWebForm] \n]
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
                     set bHidden FALSE
                     incr iCounter
                     set iSelect [string first "select" $sField]
                     if {$iSelect >= 0} {
                        set sExpression [string range $sField [expr $iSelect + 7] end]
                     }
                  } elseif {$bField} {
                     if {$sField == ""} {
		   
                    set value_index [lindex $lsSettingName 0]
	        ######### START Added by SL Team for spinner V6R2012 validation ##########
		    if {$value_index == "value user"} {
		    regsub "value user" $lsSettingName "" lsSettingName
            ######### END ##########  
		    }
            set slsSettingName [join $lsSettingName " | "]	
               ######### START Added by SL Team for spinner V6R2012 validation ##########
		    set value_index1 [lindex $lsSettingValue 0]
		    if {$value_index1 == ""} {
                    regsub "{" $lsSettingValue "\040" lsSettingValue
		            regsub "}" $lsSettingValue "\040" lsSettingValue
                    regsub "" $lsSettingValue "user" lsSettingValue
		    }
               ######### END ##########  
                        set slsSettingValue [join $lsSettingValue " | "]
                        set slsUser [join $lsUser " | "]
                        set sFormName $sWebForm
                        for {set i 0} {$i < [string length $sFormName]} {incr i} {
                           if {[string range $sFormName $i $i] == " "} {
                              regsub " " $sFormName "<SPACE>" sFormName
                           } else {
                              break
                           }
                        }
                        append sFile2 "$sFormName\t$sName\t$sLabel\t$sDescription\t$sExpressionType\t$sExpression\t$sHref\t$slsSettingName\t$slsSettingValue\t$slsUser\t$sAlt\t$sRange\t$sUpdate\t$iFieldOrder\t$bHidden\n"
                     } else {
                        regsub " " $sField "^" sFieldTemp
                        set lsFieldTemp [split $sFieldTemp ^]
                        set sChoice [lindex $lsFieldTemp 0]
                        set sValue [lindex $lsFieldTemp 1]
                        if {$sChoice == "name"} {
                           regsub "        " $sValue "" sValue
                           for {set i 0} {$i < [string length $sValue]} {incr i} {
                              if {[string range $sValue $i $i] == " "} {
                                 regsub " " $sValue "<SPACE>" sValue
                              } else {
                                 break
                              }
                           }
                        } else {
                           set sValue [string trim $sValue]
                        }
                        switch $sChoice {
                           expressiontype {
                              set sExpressionType $sValue
                           } name {
                              set sName $sValue
                              set bHidden [mql print form $sWebForm select field\[$sName\].hidden dump]
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
         }
      }
   }
   set iFile [open $sPath w]
   puts $iFile $sFile
   close $iFile
   puts "Web Form data loaded in file $sPath"
   set iFile [open $sPath2 w]
   puts $iFile $sFile2
   close $iFile
   puts "Web Form Field data loaded in file $sPath2"
}
