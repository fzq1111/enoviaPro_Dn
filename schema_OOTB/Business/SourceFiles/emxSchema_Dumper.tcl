################################################################################
#
#  Version 10.8.0 (Build 8th Jan 09)
#  Modified by M.Osterman to add 10.8 features 
#  Spinner dumper routines
################################################################################



################################################################################
# Add_Value_Element_To_Array
#   Add value element to array
#
#   Parameters :
#       array_name
#       element
#       value
#   Return : none
#
proc Add_Value_Element_To_Array { array_tab element value } {
    upvar $array_tab $array_tab
    set array_name $array_tab

    if { [array exists $array_name] != 1 } {
        set ${array_name}($element) [list $value]
    } else {
        if { [lsearch -exact [array names $array_name] $element] != -1 } {
            lappend ${array_name}($element) $value
        } else {
            set ${array_name}($element) [list $value]
        }
    }
    return
}


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
#End Replace_Space


################################################################################
# pGenTrig
#   Processes Trigger data that contains { and } one char at a time.
#   Note: Make sure { and } match, even in comments!!!!
#
#   Parameters :
#       string
#   Return :
#       string
#

proc pGenTrig { sData } {

    set temp_data ""
    set sData [ string trim $sData ]
    set nLen [ string length $sData ]
    
    for {set x 8} {$x<$nLen} {incr x} {
    
        set i [string index $sData $x]
        
        if { $i == ":" } {
            append temp_data $sTag " "
            set sTag ""
        } elseif { $i == "(" } {
            set bInside TRUE
            append temp_data $sTag " "
            set sTag ""
        } elseif { $i == ")" } {
            set bInside FALSE
            append temp_data $sTag
            set sTag ""
        } elseif { $i == "," && $bInside =="FALSE" } {
            append temp_data "<BR>"
            set sTag ""
        } else {
            append sTag $i
        }
    }
    return $temp_data
}
# End pGenTrig


################################################################################
# pCheckHidden
#   Test to see if hidden should be enforced.
#
#   Parameters :
#       
#   Return :
#       list
#
proc pCheckHidden { lContent sType } {

    upvar aAdmin aAdmin
    
    set lOk [ list ]
    set lAllowed $aAdmin($sType)
    
    foreach sName $lContent {
        if { [lsearch $lAllowed $sName] != "-1" } {
        #add to list
            lappend lOk $sName
        }
    }
    return $lOk
}
#End pCheckHidden


################################################################################
# Generate_type
#   Generate HTML page for types
#
#   Parameters : none
#   Return : none
#
proc Generate_type {} {
    upvar  Attribute_Types Attribute_Types
    upvar aAdmin aAdmin
    global Out_Directory Out_Directory
    global Image_Directory Image_Directory
    global sDumpProperties
    global bDumpSchema
    global bSuppressHidden

    set lProp [list ]

    # Get definition instances
    set Object "type"
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {
        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        # Get type icon
        set Icon_Filename "[Replace_Space $instance].gif"
        catch { mql icon type "$instance" file "$Icon_Filename" dir $Image_Directory }
        if { [file exists $Image_Directory/$Icon_Filename] == 0 } {
            set Icon_Filename matrix_type.gif
        }

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><IMG ALIGN=ABSBOTTOM SRC=Images/$Icon_Filename BORDER=0 HSPACE=15><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5 VALIGN=BOTTOM><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        foreach item $Content {

            # Case 'inherited method'
            if { [string match "*inherited method*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 2 3]]
                set item_content [split [lrange $item 4 end] ,]
                set temp_item ""
                foreach program $item_content {
                    append temp_item "<A HREF=\"program.html#[Replace_Space $program]\">$program</A> "
                }
                set item_content $temp_item

            # Case 'inherited attribute'
            } elseif { [string match "*inherited attribute*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 2 3]]
                set item_content [split [lrange $item 4 end] ,]
                set temp_item ""
                if {$bSuppressHidden} {set item_content [ pCheckHidden $item_content attribute ]}
                foreach attribute $item_content {
                    append temp_item "<A HREF=\"attribute.html#[Replace_Space $attribute]\">$attribute</A>  "

                    # Update Attribute_Types array
                    Add_Value_Element_To_Array Attribute_Types $attribute $instance
                }
                set item_content $temp_item

            # Case 'inherited form'
            } elseif { [string match "*inherited form*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 2 3]]
                set item_content [split [lrange $item 4 end] ,]
                set temp_item ""
                foreach form $item_content {
                    append temp_item "<A HREF=\"form.html#[Replace_Space $form]\">$form</A>  "
                }
                set item_content $temp_item

            # Case 'inherited trigger'
            } elseif { [string match "*inherited trigger*" $item] == 1 } {
                set sTrigger $item
                set item [split $item]
                set item_name [join [lrange $item 2 3]]
                set item_content [split [lrange $item 4 end] ,]
                if { [ string match "*\{*\}*" $sTrigger ] == 0 } {
                    set item_content [Generate_TriggerLinks $item_content $Object $instance]
                } else {
                    set item_content [pGenTrig $sTrigger]
                }

            } else {
                set sTrigger $item
                set item [split $item]
                set item_name [lindex $item 2]

                # Case 'attribute'
                if { $item_name == "attribute" } {
                    set item_content [split [lrange $item 3 end] ,]
                    set temp_item ""
                    if {$bSuppressHidden} {set item_content [pCheckHidden $item_content attribute]}
                    foreach attribute $item_content {
                        append temp_item "<A HREF=\"attribute.html#[Replace_Space $attribute]\">$attribute</A>  "

                        # Update Attribute_Types arrays
                        Add_Value_Element_To_Array Attribute_Types $attribute $instance
                    }
                    set item_content $temp_item

                # Case 'method'
                } elseif { $item_name == "method" } {
                    set item_content [split [lrange $item 3 end] ,]
                    set temp_item ""
                    if {$bSuppressHidden} {set item_content [pCheckHidden $item_content program]}
                    foreach program $item_content {
                        append temp_item "<A HREF=\"program.html#[Replace_Space $program]\">$program</A>  "
                    }
                    set item_content $temp_item

                # Case 'form'
                } elseif { $item_name == "form" } {
                    set item_content [split [lrange $item 3 end] ,]
                    set temp_item ""
                    foreach form $item_content {
                        append temp_item "<A HREF=\"form.html#[Replace_Space $form]\">$form</A>  "
                    }
                    set item_content $temp_item

                # Case 'policy'
                } elseif { $item_name == "policy" } {
                    set item_content [split [lrange $item 3 end] ,]
                    set temp_item ""
                    foreach policy $item_content {
                        append temp_item "<A HREF=\"policy.html#[Replace_Space $policy]\">$policy</A>  "
                    }
                    set item_content $temp_item

                # Case 'trigger'
                } elseif { $item_name == "trigger" } {
                    set item_content [split [lrange $item 3 end] ,]
                    if { [ string match "*\{*\}*" $sTrigger ] == 0 } {
                        set item_content [Generate_TriggerLinks $item_content $Object $instance]
                    } else {
                        set item_content [pGenTrig $sTrigger]
                    }

                # Case 'derivative'
                } elseif { $item_name == "derivative" } {
                    set item_content [split [mql print type $instance select derivative dump |] |]
                    set temp_item ""
                    foreach type $item_content {
                        append temp_item "<A HREF=\"type.html#[Replace_Space $type]\">$type</A>  "
                    }
                    set item_content $temp_item

                # Case 'derived'
                } elseif { $item_name == "derived" } {
                    set item_content [join [lrange $item 3 end]]
                    set item_content "<A HREF=\"type.html#[Replace_Space $item_content]\">$item_content</A>"

                # Case 'property'
                # Extract property name and property value
                } elseif { $item_name == "property" } {
                    set property [lrange $item 3 end]
                    set value_index [lsearch -exact $property "value"]
                    if { $value_index != -1 } {
                        set item_name [join [lrange $property 0 [expr $value_index -1]]]
                        set item_content [join [lrange $property [expr $value_index +1] end]]
                    } else {
                        set item_content [join [lrange $item 3 end]]
                    }
                    lappend lProp "$item_name \t $item_content"

                # Default case
                } else {
                    set item_content [join [lrange $item 3 end]]
                }
            }

            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }

        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]

        set From_Rel [split [mql print type $instance select fromrel dump |] |]
        set temp ""
        foreach relation $From_Rel {
            append temp "<A HREF=\"relationship.html#[Replace_Space $relation]\">$relation</A>  "
        }
        set From_Rel $temp
        append Page_Content "<TR>
                          <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><B><FONT SIZE=-1>from relation</B></FONT></TD>
                         <TD ALIGN=LEFT><FONT SIZE=-1>$From_Rel</FONT></TD>
                        </TR>"
        set To_Rel [split [mql print type $instance select torel dump |] |]
        set temp ""
        foreach relation $To_Rel {
            append temp "<A HREF=\"relationship.html#[Replace_Space $relation]\">$relation</A>  "
        }
        set To_Rel $temp
        append Page_Content "<TR>
              <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><B><FONT SIZE=-1>to relation</B></FONT></TD>
              <TD ALIGN=LEFT><FONT SIZE=-1>$To_Rel</FONT></TD>
              </TR>"

        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "


        if { $bDumpSchema } { 
           if {$Object != "index"} {
              pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content
           } else {
              pfile_write [ file join $Out_Directory index_.html ] $Page_Content
           }
        }
              
}

################################################################################
# Generate_attribute
#   Generate HTML page for attributes
#
#   Parameters : none
#   Return : none
#
proc Generate_attribute {} {
    upvar Attribute_Types Attribute_Types
    upvar Attribute_Relationships Attribute_Relationships
    upvar aAdmin aAdmin
    
    global Out_Directory

    global sDumpProperties
    global bDumpSchema

    # Get definition instances
    set Object "attribute"
    set Instances $aAdmin($Object)
    
    set lProp [ list ]

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {

        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        foreach item $Content {
            set sTrigger $item
            set item [split $item]
            set item_name [lindex $item 2]

            # Case 'property'
            # Extract property name and property value
            if { $item_name == "property" } {
                set property [lrange $item 3 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 3 end]]
                }

            lappend lProp "$item_name \t $item_content"

            # Case 'trigger'
            } elseif { $item_name == "trigger" } {
                set item_content [split [lrange $item 3 end] ,]
                if { [ string match "*\{*\}*" $sTrigger ] == 0 } {
                    set item_content [Generate_TriggerLinks $item_content $Object $instance]
                } else {
                    set item_content [pGenTrig $sTrigger]
                }

            # Default case
            } else {
                set item_content [join [lrange $item 3 end]]
            }
            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]

        # Types using current attribute
        set Parent_Types ""
        if { [lsearch -exact [array names Attribute_Types] $instance] != -1 } {
            foreach type $Attribute_Types($instance) {
                append Parent_Types "<A HREF=\"type.html#[Replace_Space $type]\">$type</A>  "
            }
            append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><B><FONT SIZE=-1>Used in type(s)</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1>$Parent_Types</FONT></TD>
                    </TR>"
        }

        # Relationships using current attribute
        set Parent_Relationship ""
        if { [lsearch -exact [array names Attribute_Relationships] $instance] != -1 } {
            foreach relation $Attribute_Relationships($instance) {
                append Parent_Relationship "<A HREF=\"relationship.html#[Replace_Space $relation]\">$relation</A>  "
            }
            append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><B><FONT SIZE=-1>Used in relationship(s)</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1>$Parent_Relationship</FONT></TD>
                    </TR>"
        }

        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

        if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
}



################################################################################
# Generate_relationship
#   Generate HTML page for relationship
#
#   Parameters : none
#   Return : none
#
proc Generate_relationship {} {
    upvar Attribute_Types Attribute_Types
    upvar Attribute_Relationships Attribute_Relationships
    upvar aAdmin aAdmin

    global Out_Directory
    global sDumpProperties
    global bDumpSchema
    global bSuppressHidden

    set lProp [list ]

    # Get definition instances
    set Object "relationship"
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {

        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        foreach item $Content {
            set sTrigger $item
            set item [split $item]
            set item_name [lindex $item 2]
            set skip_line FALSE

            # Case 'trigger'
            if { $item_name == "trigger" } {
                set item_content [split [lrange $item 3 end] ,]
                if { [ string match "*\{*\}*" $sTrigger ] == 0 } {
                    set item_content [Generate_TriggerLinks $item_content $Object $instance]
                } else {
                    set item_content [pGenTrig $sTrigger]
                }

            # Case 'attribute'
            } elseif { $item_name == "attribute" } {
                set item_content [split [lrange $item 3 end] ,]
                set temp_item ""
                if {$bSuppressHidden} {set item_content [pCheckHidden $item_content attribute]}
                foreach attribute $item_content {
                    append temp_item "<A HREF=\"attribute.html#[Replace_Space $attribute]\">$attribute</A>"

                    # Update Attribute_Relationships array
                    Add_Value_Element_To_Array Attribute_Relationships $attribute $instance
                }
                set item_content $temp_item

            # Case 'from' and 'to'
            } elseif { ($item_name == "from") || ($item_name == "to") } {
                set item_content [split [mql print relationship $instance select ${item_name}type dump |] |]
                set temp_item ""
                foreach type $item_content {
                    append temp_item "<A HREF=\"type.html#[Replace_Space $type]\">$type</A> "
                }
                set item_content $temp_item

            # Case 'type'
            } elseif { [string match "*type*" [join [lrange $item 3 end]]] == 1 } {
                set skip_line TRUE

            # Case 'property'
            # Extract property name and property value
            } elseif { $item_name == "property" } {
                set property [lrange $item 3 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 3 end]]
                }
                lappend lProp "$item_name \t $item_content"
                    
            # Default case
            } else {
                set item_content [join [lrange $item 3 end]]
            }

            # Skip 'type' line
            if { $skip_line == "FALSE" } {
                append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                    </TR>"
            }
            if { [ llength $lProp ] > 0 } {
                set lProp [ join $lProp \n ]
            }
            set lProp [list ]
        }

        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

        if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
}

################################################################################
# Generate_policy
#   Generate HTML page for policy
#
#   Parameters : none
#   Return : none
#
proc Generate_policy {} {
    upvar Format_Policies Format_Policies
    upvar Store_Policy Store_Policy
    upvar aAdmin aAdmin

    global bExtendedPolicy
    global Out_Directory
    global sDumpProperties
    global bDumpSchema
    global bSVG
    
    set lProp [list ]

    # Get definition instances
    set Object "policy"
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {

        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        set sNoSpace [Replace_Space $instance]

        append Page_Content "
            <A NAME=\"$sNoSpace\"
            <h1><B>$Object $instance</B></h1>
            </A>"


        if {$bSVG} {
            append Page_Content "
                <center>
                <object type=\"image/svg-xml\" width=\"700\" height=\"200\" data=\"Images/${sNoSpace}.svg\">
                Should not happen
                </object>
                </center>
            "
        #Get the lifecycle state names.
        set lPolicyStateName [split [mql print policy "$instance" select state dump |] |]
        set sText ""
        set x 10
        set y 10
        foreach sStateName $lPolicyStateName {

            append sText "<use x=\"$x\" y=\"$y\" xlink:href=\"#rect\"/>
                <text x=\"[expr $x + 5]\" y=\"[expr $y + 15]\"
                font-size=\"10\"
                font-family=\"Arial\"
                fill=\"black\"
                text-anchor=\"start\"
                dominant-baseline=\"mathematical\">$sStateName</text>"
                incr x 150
        }

        # Create lifecycle
            set sDataSVG "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>
<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 20000303 Stylable//EN\"
\"http://www.w3.org/TR/2000/03/WD-SVG-20000303/DTD/svg-20000303-stylable.dtd\">
<svg xml:space=\"preserve\" width=\"5.0in\" height=\"2.5in\">
<defs>
    <rect id=\"rect\" width=\"90\" height=\"30\" fill=\"none\" stroke=\"blue\" stroke-width=\"2\"
/>
</defs>
$sText
</svg>
            "
            pfile_write [file join $Out_Directory Images ${sNoSpace}.svg] $sDataSVG
        }

        append Page_Content "
            <TABLE BORDER=0>
        "


#        append Page_Content "
#            <A NAME=\"[Replace_Space $instance]\">
#            <TABLE BORDER=0>
#            <TR>
#            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
#            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
#            </TR>
#            </A>
#        "

        if { $bExtendedPolicy == "1" } {
            append Page_Content "
                <TR>
                <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>State Access Info</B></FONT></TD>
                <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=-1><A HREF=\"Policy/[Replace_Space $instance].html\">$instance</A></FONT></TD>
                </TR>"
        }

        set sCurrentState ""
        foreach item $Content {

            set sTrigger $item
            set item [split $item]
            set item_name [lindex $item 2]
            set sub_item_name [lindex $item 4]

            # Case 'type'
            if { $item_name == "type" } {
                set item_content [split [lrange $item 3 end] ,]
                set temp_item ""
                foreach type $item_content {
                    append temp_item "<A HREF=\"type.html#[Replace_Space $type]\">$type</A>  "
                }
                set item_content $temp_item

            # Case 'store'
            } elseif { $item_name == "store" } {
                set item_content [split [lrange $item 3 end] ,]
                Add_Value_Element_To_Array Store_Policy $item_content $instance
                set temp_item ""
                foreach store $item_content {
                    append temp_item "<A HREF=\"store.html#[Replace_Space $store]\">$store</A>  "
                }
                set item_content $temp_item

            # Case 'format'
            } elseif { $item_name == "format" } {
                set item_content [split [lrange $item 3 end] ,]
                set temp_item ""
                foreach format $item_content {
                    append temp_item "<A HREF=\"format.html#[Replace_Space $format]\">$format</A>  "

                    # Update Format_Policies
                    Add_Value_Element_To_Array Format_Policies $format $instance
                }
                set item_content $temp_item

            # Case 'defaultformat'
            } elseif { $item_name == "defaultformat" } {
                set item_content [join [lrange $item 3 end]]
                set item_content "<A HREF=\"format.html#[Replace_Space $item_content]\">$item_content</A>"

            # Case 'trigger'
            } elseif { $sub_item_name == "trigger" } {
                set item_content [split [lrange $item 5 end] ,]
                if { [ string match "*\{*\}*" $sTrigger ] == 0 } {
                    set item_content [Generate_TriggerLinks $item_content $Object $instance]
                } else {
                    set item_content [pGenTrig $sTrigger]
                }

            # Case 'property'
            # Extract property name and property value
            } elseif { $item_name == "property" } {
                set property [lrange $item 3 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 3 end]]
                }
                lappend lProp "$item_name \t $item_content"
                    
            } elseif { $item_name == "state" } {
#                set sCurrentState $item_content
                set item_content [join [lrange $item 3 end]]
            # Default case
            } else {
                set item_content [join [lrange $item 3 end]]
            }
            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

        if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
}



################################################################################
# Generate_program
#   Generate HTML page for program
#
#   Parameters : none
#   Return : none
#
proc Generate_program {} {
    upvar Out_Directory Out_Directory
    upvar aAdmin aAdmin
    global bExtendedProgram
    global sDumpProperties
    global bDumpSchema

    set lProp [list ]
    # Get definition instances
    set Object "program"
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {
        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        set Selectables {description hidden ismqlprogram doesneedcontext code iswizardprogram doesuseinterface execute isamethod isafunction type downloadable property}

        foreach item_name $Selectables {

            # Case 'code'
            if { $item_name == "code" && $bExtendedProgram == "1" } {
                if {[catch {set item_content [mql print program $instance select $item_name dump]} sMsg] != 0} {continue}
                regsub -all -- \" $item_content \\\" item_content

                # Create a file containing the code
                regsub -all -- "/" $instance "_" program_filename
                regsub -all -- " " $program_filename "_" program_filename
                regsub -all -- ":" $program_filename "_" program_filename
                regsub -all -- "\134\174" $program_filename "_" program_filename
                regsub -all -- ">" $program_filename "_" program_filename
                regsub -all -- "<" $program_filename "_" program_filename
                set program_filename Programs/${program_filename}.txt
                set program_file [open $Out_Directory/$program_filename w+]
                puts $program_file $item_content
                close $program_file

                append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1><A HREF=\"${program_filename}\">See code</A></FONT></TD>
                    </TR>"

#            } elseif { $item_name == "code" && $bExtendedProgram == "0" } {
#                append Page_Content "<TR>
#                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
#                      <TD ALIGN=LEFT><FONT SIZE=-1>Code</FONT></TD>
#                    </TR>"
            # Case 'type'
            } elseif { $item_name == "type" } {
                set item_content [split [mql print program $instance select $item_name dump |] |]
                set temp_item ""
                foreach type $item_content {
                    append temp_item "<A HREF=\"type.html#[Replace_Space $type]\">$type</A>  "
                }
                set item_content $temp_item
                append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                    </TR>"


            # Case 'property'
            # Extract property name and property value
            } elseif { $item_name == "property" } {
                set propertydata [split [mql print program $instance select property dump |] | ]
foreach property $propertydata {
#                set property [lrange $item 3 end ]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join $property]
                }
                lappend lProp "$item_name \t $item_content"
                append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                    </TR>"
}


            # Default case
            } else {
                set item_content [mql print program $instance select $item_name dump]
                append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                    </TR>"
            }
            
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
            
        }

        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

    if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
}

################################################################################
# Generate_group
#   Generate HTML page for groups
#
#   Parameters : none
#   Return : none
#
proc Generate_group {} {

    global bExtendedPolicy
    global Out_Directory
    global sDumpProperties
    global bDumpSchema
    upvar aAdmin aAdmin
    set lProp [list ]

    # Get definition instances
    set Object "group"
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {

        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        if { $bExtendedPolicy == "1" } {
            append Page_Content "
                <TR>
                <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>Group Access Info</B></FONT></TD>
                <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=-1><A HREF=\"Policy/[Replace_Space $instance].html\">$instance</A></FONT></TD>
                </TR>"
        }

        set Person_List FALSE
        foreach item $Content {
            set item [split $item]
            set item_name [lindex $item 2]

            # Case 'child' or 'parent'
            if { ($item_name == "child") || ($item_name == "parent") } {
                set item_content [join [lrange $item 3 end]]
                set item_content "<FONT SIZE=-1><A HREF=\"group.html#[Replace_Space $item_content]\">$item_content</FONT></A>"

            # Case 'assign' or 'people'
            # Do it one time
            } elseif { ($item_name == "assign") || ($item_name == "people") } {
                if { $Person_List == "FALSE" } {
                    set persons [split [mql print group $instance select person dump |] |]
                    set item_content ""
                    foreach person $persons {
                        append item_content "<FONT SIZE=-1><A HREF=\"person.html#[Replace_Space $person]\">$person</FONT></A> "
                    }
                    set Person_List TRUE
                } else {
                    continue
                }

            # Case 'property'
            # Extract property name and property value
            } elseif { $item_name == "property" } {
                set property [lrange $item 3 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 3 end]]
                }
                lappend lProp "$item_name \t $item_content"
                
            # Default case
            } else {
                set item_content [join [lrange $item 3 end]]
            }
            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

        if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
}

################################################################################
# Generate_role
#   Generate HTML page for role
#
#   Parameters : none
#   Return : none
#
proc Generate_role {} {

    upvar aAdmin aAdmin
    global bExtendedPolicy
    global Out_Directory
    global sDumpProperties
    global bDumpSchema
    
    set lProp [list ]

    # Get definition instances
    set Object "role"
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "


    # Body of HTML page
    foreach instance $Instances {

        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        if { $bExtendedPolicy == "1" } {
            append Page_Content "
                <TR>
                <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>Role Access Info</B></FONT></TD>
                <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=-1><A HREF=\"Policy/[Replace_Space $instance].html\">$instance</A></FONT></TD>
                </TR>"
        }

        set Person_List FALSE
        foreach item $Content {
            set item [split $item]
            set item_name [lindex $item 2]

            # Case 'child' or 'parent'
            if { ($item_name == "child") || ($item_name == "parent") } {
                set item_content [join [lrange $item 3 end]]
                set item_content "<FONT SIZE=-1><A HREF=\"role.html#[Replace_Space $item_content]\">$item_content</FONT></A>"

            # Case 'assign' or 'people'
            # Do it one time
            } elseif { ($item_name == "assign") || ($item_name == "people") } {
                if { $Person_List == "FALSE" } {
                    set persons [split [mql print role $instance select person dump |] |]
                    set item_content ""
                    foreach person $persons {
                        append item_content "<FONT SIZE=-1><A HREF=\"person.html#[Replace_Space $person]\">$person</FONT></A> "
                    }
                    set Person_List TRUE
                } else {
                    continue
                }

            # Case 'property'
            # Extract property name and property value
            } elseif { $item_name == "property" } {
                set property [lrange $item 3 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 3 end]]
                }
                lappend lProp "$item_name \t $item_content"
                
            # Default case
            } else {
                set item_content [join [lrange $item 3 end]]
            }
            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

        if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
}

################################################################################
# Generate_person
#   Generate HTML page for person
#
#   Parameters : none
#   Return : none
#
proc Generate_person {} {

    upvar aAdmin aAdmin
    upvar aDirs aDirs
    
    global bExtendedPolicy
    global lExtendedPersonData

    global Out_Directory
    global sDumpProperties
    global bDumpSchema

    set sDelimit "\t"
    set lPerson [list ]
    set lProp [list ]
    set lPersonData [ list name fullname comment address phone fax email vault \
        site type assign_role assign_group ]
    lappend lPerson [join $lPersonData $sDelimit]

    # Get definition instances
    set Object "person"
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {
        set aData(name) $instance
        
        if {[catch {set Content [mql print $Object $instance]} sMsg] != 0} {continue}

        regsub -all -- {\{} $Content { LEFTBRACE } Content
        regsub -all -- {\}} $Content { RIGHTBRACE } Content

        set Content [lrange [split $Content \n] 1 end]
        set lAssign_Role [list ]
        set lAssign_Group [list ]

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        if { $bExtendedPolicy == "1"  && [lsearch $lExtendedPersonData $instance] != "-1" } {
            append Page_Content "
                <TR>
                <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>Person Access Info</B></FONT></TD>
                <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=-1><A HREF=\"Policy/[Replace_Space $instance].html\">$instance</A></FONT></TD>
                </TR>"
        }

        foreach item $Content {
            set item [string trimleft $item]
            set lItem [split $item]
            set item_name [lindex $lItem 0]
#            set item_content [lrange $item 1 end]
#            Change to allow for special char strings
            set nFirstWS [string first " " $item]
            set item_content [string range $item [expr $nFirstWS + 1] end]
            set item_content_html $item_content
            set aData($item_name) $item_content
            # Case assign
            if { $item_name == "assign" } {
                set user [lrange $item 2 end]
                set group_role [lindex $lItem 1]
                set item_content_html  "<A HREF=\"${group_role}.html#[Replace_Space $user]\">$user</A>"
                if {$group_role == "group"} {
                    lappend lAssign_Group $user
                } elseif {$group_role == "role"} {
                    lappend lAssign_Role $user
                }
            # Case lattice
            } elseif { $item_name == "lattice" } {
                set vault [lrange $item 1 end]
                set aData(vault) $vault
                set item_content_html  "<A HREF=\"vault.html#[Replace_Space $vault]\">$vault</A>"
            # Case 'property'
            # Extract property name and property value
            } elseif { $item_name == "property" } {
                set property [lrange $item 1 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                    set item_content_html $item_content
                } else {
                    set item_content [join [lrange $lItem 1 end]]
                    set item_content_html $item_content
                }
                lappend lProp "$item_name \t $item_content"
            }
            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content_html</FONT></TD>
                </TR>"
        }
        append Page_Content "\n</TABLE><BR><BR>"
        if {[llength $lAssign_Role] == 0} {
            set aData(assign_role) ""
        } else {
            set lAssign_Role [lsort -dictionary $lAssign_Role]
            set sAssign_Role [join $lAssign_Role |]
            regsub -all -- {\|} $sAssign_Role { | } sAssign_Role
            set aData(assign_role) $sAssign_Role
        }
        if {[llength $lAssign_Group] == 0} {
            set aData(assign_group) ""
        } else {
            set lAssign_Group [lsort -dictionary $lAssign_Group]
            set sAssign_Group [join $lAssign_Group |]
            regsub -all -- {\|} $sAssign_Group { | } sAssign_Group
            set aData(assign_group) $sAssign_Group
        }

        set lDataEach [list ]
        foreach sPersonData $lPersonData {
            if { [ info exists aData($sPersonData) ] == 1 } {
                lappend lDataEach $aData($sPersonData)
            } else {
                lappend lDataEach ""
            }
        }
        lappend lPerson [join $lDataEach $sDelimit]
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

    if {$bDumpSchema} {pfile_write [file join $Out_Directory ${Object}.html] \
        $Page_Content}
    return 0
}
# End Generate_person


################################################################################
# Generate_wizard
#   Generate HTML page for wizard
#
#   Parameters : none
#   Return : none
#
proc Generate_wizard {} {

    upvar Out_Directory Out_Directory
    upvar aAdmin aAdmin
    upvar aDirs aDirs
    global bExtendedProgram
    global sDumpProperties
    global bDumpSchema

    set lProp [list ]

    # Get definition instances
    set Object "wizard"
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {
        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        set Selectables {description hidden ismqlprogram doesneedcontext code iswizardprogram doesuseinterface execute isamethod isafunction type downloadable property}

        # Remove execute donwloadable type selectables for ENOVIA version prior to 8

        foreach item_name $Selectables {

            # Case 'code'
            if { $item_name == "code" && $bExtendedProgram == "1" } {
                if {[catch {set item_content [mql print program $instance select $item_name dump]} sMsg] != 0} {continue}
                regsub -all -- \" $item_content \\\" item_content

                # Create a file containing the code
                regsub -all -- "/" $instance "_" program_filename
                regsub -all -- " " $program_filename "_" program_filename
                set program_filename Programs/${program_filename}.txt
                set program_file [open $Out_Directory/$program_filename w+]
                puts $program_file $item_content
                close $program_file

                append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1><A HREF=\"${program_filename}\">See code</A></FONT></TD>
                    </TR>"

            # Case 'type'
            } elseif { $item_name == "type" } {
                set item_content [split [mql print program $instance select $item_name dump |] |]
                set temp_item ""
                foreach type $item_content {
                    append temp_item "<A HREF=\"type.html#[Replace_Space $type]\">$type</A>  "
                }
                set item_content $temp_item
                append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                    </TR>"

            # Case 'property'
            # Extract property name and property value
            } elseif { $item_name == "property" } {
                set property [split [mql print program $instance select property dump]]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join $property]
                }
                lappend lProp "$item_name \t $item_content"
                
                append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                    </TR>"

            # Default case
            } else {
                set item_content [mql print program $instance select $item_name dump]
                append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                    </TR>"
            }
        }

        # Frame infos
        # Get all lines printed after the 'frame' info
        set Content [lrange [split [mql print $Object $instance] \n] 1 end]
        set Frame_Infos FALSE
        foreach item $Content {
            set item [split $item]
            set item_name [lindex $item 2]
            set sub_item_name_1 [lindex $item 4]
            set sub_item_name_2 [lindex $item 6]
            set sub_item_name ""

            if { $item_name == "frame" } {
                set Frame_Infos TRUE
            }

            if { $Frame_Infos == "TRUE" } {

                # Program used by wizard
                if { ($sub_item_name_1 == "epilogue") || ($sub_item_name_1 == "prologue") } {
                    set program_event $sub_item_name_1
                    set program_name [lindex $item 6]
                    set program_parameters [join [lrange $item 10 end]]
                    set item_content "<FONT SIZE=-1>$program_event </FONT><FONT SIZE=-1><A HREF=\"program.html#[Replace_Space $program_name]\">$program_name </FONT></A> <FONT SIZE=-1>$program_parameters</FONT></TD></TR>"

                } elseif { ($sub_item_name_2 == "load") || ($sub_item_name_2 == "validate") } {
                    set program_event $sub_item_name_2
                    set program_name [lindex $item 8]
                    set program_parameters [join [lrange $item 12 end]]
                    set item_content "<FONT SIZE=-1>$program_event </FONT><FONT SIZE=-1><A HREF=\"program.html#[Replace_Space $program_name]\">$program_name </FONT></A> <FONT SIZE=-1>$program_parameters</FONT></TD></TR>"

                # Other frame infos
                } else {
                    set item_content [join [lrange $item 3 end]]
                }
                append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                    </TR>"
            }
            
            if { [ llength $lProp ] > 0 } {
                set lProp [ join $lProp \n ]
            }
            set lProp [list ]
        }
        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

    if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
    return 0
}

################################################################################
# Generate_format
#   Generate HTML page for format
#
#   Parameters :
#   Return : none
#
proc Generate_format {} {
    upvar Format_Policies Format_Policies
    upvar aAdmin aAdmin
    
    global Out_Directory
    global sDumpProperties
    global bDumpSchema
    
    set lProp [list ]

    # Get definition instances
    set Object "format"
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {
        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        foreach item $Content {
            set item [split $item]
            set item_name [lindex $item 2]

            # Case 'view' 'edit' 'print'
            if { ($item_name == "view") || ($item_name == "edit") || ($item_name == "print") } {
                set item_content [join [lrange $item 3 end]]
                set item_content "<A HREF=\"program.html#[Replace_Space $item_content]\">$item_content</A> "

            # Case 'property'
            # Extract property name and property value
            } elseif { $item_name == "property" } {
                set property [lrange $item 3 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 3 end]]
                }
                lappend lProp "$item_name \t $item_content"
                
            # Default case
            } else {
                set item_content [join [lrange $item 3 end]]
            }
                append Page_Content "<TR>
                      <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                      <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                    </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        # Used by policies
        set item_content ""
        if { [lsearch -exact [array names Format_Policies] $instance] != -1 } {
            foreach policy $Format_Policies($instance) {
                append item_content "<A HREF=policy.html#[Replace_Space $policy]\">$policy</A> "
            }
        } else {
            set item_content ""
        }
        append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>Used by policies</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"

        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

        if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
}

################################################################################
# Generate_association
#   Generate HTML page for association
#
#   Parameters : none
#   Return : none
#
proc Generate_association {} {

    upvar aAdmin aAdmin

    global Out_Directory
    global sDumpProperties
    global bDumpSchema
    global bExtendedPolicy
    
    set lProp [list ]

    # Get definition instances
    set Object "association"
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {

        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        if { $bExtendedPolicy == "1" } {
            append Page_Content "
                <TR>
                <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>Association Access Info</B></FONT></TD>
                <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=-1><A HREF=\"Policy/[Replace_Space $instance].html\">$instance</A></FONT></TD>
                </TR>"
        }

        set Person_List FALSE
        foreach item $Content {
            set item [split $item]
            set item_name [lindex $item 2]

            if { $Person_List != "TRUE" } {

                # Case List of persons :
                # line content is just : 'List of persons who belongs to association'
                if { $item_name == "List" } {
                    set Person_List TRUE
                    set item_name "List of persons"
                    set item_content ""

                # Case 'property'
                # Extract property name and property value
                } elseif { $item_name == "property" } {
                    set property [lrange $item 3 end]
                    set value_index [lsearch -exact $property "value"]
                    if { $value_index != -1 } {
                        set item_name [join [lrange $property 0 [expr $value_index -1]]]
                        set item_content [join [lrange $property [expr $value_index +1] end]]
                    } else {
                        set item_content [join [lrange $item 3 end]]
                    }
                    lappend lProp "$item_name \t $item_content"
                    
                # Default case
                } else {
                    set item_content [join [lrange $item 3 end]]
                }

            # Line content is just a name of person
            } else {
                set item_content $item_name
                set item_name ""
            }

            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

        if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
}

################################################################################
# Generate_process
#   Generate HTML page for process
#
#   Parameters :
#   Return : none
#
proc Generate_process {} {

    upvar aAdmin aAdmin
    upvar aDirs aDirs
    global Out_Directory
    global sDumpProperties
    global bDumpSchema
    
    set lProp [list ]

    # Get definition instances
    set Object "process"
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {
        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        foreach item $Content {
            set item [split [string trimleft $item]]
            set item_name [lindex $item 0]

            # Case 'property'
            # Extract property name and property value
            if { $item_name == "property" } {
                set property [lrange $item 3 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 3 end]]
                }
                lappend lProp "$item_name \t $item_content"
                
            # Default case
            } else {
                set item_content [join [lrange $item 1 end]]
            }

            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

    if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
    return 0
}

################################################################################
# Generate_form
#   Generate HTML page for forms
#
#   Parameters : none
#   Return : none
#
proc Generate_form {} {

    upvar aAdmin aAdmin
    upvar aDirs aDirs
    global Out_Directory
    global sDumpProperties
    global bDumpSchema

    set lProp [list ]

    # Get definition instances
    set Object "form"
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {
    
        if {[mql print $Object $instance select web dump] == "TRUE"} {
            continue
        }
    
        set Content [lrange [split [mql print $Object $instance] \n] 1 end]

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        foreach item $Content {
            set item [split $item]
            set item_name [lindex $item 2]

            if { $item_name == "type" } {
                set item_content [string trimleft [join [lrange $item 3 end]]]
                set item_content "<A HREF=\"type.html#[Replace_Space ${item_content}]\">${item_content}</A>"

            # Case 'property'
            # Extract property name and property value
            } elseif { $item_name == "property" } {
                set property [lrange $item 3 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 3 end]]
                }
                lappend lProp "$item_name \t $item_content"
                
            # Default case
            } else {
                set item_content [join [lrange $item 3 end]]
            }
            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        
        #export to file, change any spec char.
        set sInstanceFileName [pRemSpecChar $instance]
        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

    if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
    return 0
}


################################################################################
# Generate_vault
#   Generate HTML page for vault
#   
#   Parameters :
#       category
#   Return : none
#
proc Generate_vault {  } {

    global sDumpSchemaDirSystem
    global Out_Directory
    global sDumpProperties
    global bDumpSchema

    upvar aAdmin aAdmin
    
    set sDelimit "\t"

    set lProp [list ]

    # Get definition instances
    set Object vault
    set Instances $aAdmin($Object)

    set lVaultLocal [list name "Registry Name" description indexspace tablespace]
    set lDumpLocal [ list [ join $lVaultLocal $sDelimit ] ]
    set lVaultRemote [list name "Registry Name" description server]
    set lDumpRemote [ list [ join $lVaultRemote $sDelimit ] ]
    set lVaultForeign [list name "Registry Name" description interface file]
    set lDumpForeign [ list [ join $lVaultForeign $sDelimit ] ]

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page   
    foreach instance $Instances {
        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}
        
        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        set aVault(name) $instance
        set sOriginalName [mql print $Object $instance select property\[original name\].value dump]
        array set aVault "\"Registry Name\" \"$sOriginalName\""
        set aVault(server) ""
        set aVault(interface) ""
        set aVault(map) ""

        foreach item $Content {
            set item [ string trim $item ]
            # Case 'data tablespace'
            if { [string match "*data tablespace*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 1]]
                set item_content [join [lrange $item 2 end] ]
                set aVault(tablespace) $item_content
            # Case 'index tablespace'
            } elseif { [string match "*index tablespace*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 1]]
                set item_content [join [lrange $item 2 end] ]
                set aVault(indexspace) $item_content
           # Case 'total number of business objects'
            } elseif { [string match "*total number of business objects*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 4]]
                set item_content [join [lrange $item 5 end] ]
            } else {
            set item [split $item]
            set item_name [lindex $item 0]
            # Property case
            # Extract property name and property value
            if { $item_name == "property" } {
                set property [lrange $item 1 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 1 end]]
                }
                lappend lProp "$item_name \t $item_content"
            } elseif { $item_name == "description" } {
                set item_content [join [lrange $item 1 end]]
                set aVault(description) $item_content
            } elseif {$item_name == "map"} {
                set item_content [mql print vault $aVault(name) select map dump]
                set aVault(file) [file join . System $aVault(name).map]
                pfile_write [file join $sDumpSchemaDirSystem $aVault(name).map] $item_content
            } elseif {$item_name == "interface"} {
                set item_content [join [lrange $item 1 end]]
                set aVault(interface) $item_content
            } elseif {$item_name == "server"} {
                set item_content [join [lrange $item 1 end]]
                set aVault(server) $item_content
            # Default case
            } else {
                set item_content [join [lrange $item 1 end]]
            }
        }
            append Page_Content "<TR>
                <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"

        if {$aVault(server) != ""} {
            set sVaultType Remote
        } elseif {$aVault(map) != "" || $aVault(interface) != ""} {
            set sVaultType Foreign
        } else {
            set sVaultType Local
        }

        set sRefVault lVault${sVaultType}
        set lRefVault [set $sRefVault]
#        set lDump${sVaultType} [ list [ join $lRefVault $sDelimit ] ]
        set sInstanceData [ list ]
        foreach sDumpData $lRefVault {
            if { [ info exists aVault($sDumpData) ] == 1 } {
                lappend sInstanceData \"$aVault($sDumpData)\"
            }
            lappend sInstanceData $sDelimit
        }
        set sInstanceData [ join $sInstanceData "" ]
        lappend lDump${sVaultType} $sInstanceData
        unset aVault
    }
    append Page_Content "
        </BODY>
        </HTML>
    "

    if {[llength $lDumpLocal] > 1} {
        set lDumpLocal [ join $lDumpLocal \n ]
    }
    
    if {[llength $lDumpRemote] > 1} {
        set lDumpRemote [ join $lDumpRemote \n ]
    }
    
    if {[llength $lDumpForeign] > 1} {
        set lDumpForeign [ join $lDumpForeign \n ]
    }
    
    if {$bDumpSchema} {pfile_write [file join $Out_Directory ${Object}.html] $Page_Content }

    return 0
}


################################################################################
# Generate_store
#   Generate HTML page for store
#   
#   Parameters :
#       category
#   Return : none
#
proc Generate_store {  } {

    upvar Location_Store Location_Store
    upvar Store_Policy Store_Policy
    upvar aAdmin aAdmin

    global sDumpSchemaDirSystem
    global sDumpProperties
    global Out_Directory
    global bDumpSchema
    
    global bStatus
    
    set lProp [list ]

    set sDelimit "\t"
    set sSeperator " | "
    set sStoreType ""
    set bProcessLocations FALSE
    
    # Get definition instances
    set Object store
    set Instances $aAdmin($Object)

    set lStoreCaptured [ list name "Registry Name" description type filename permission \
        protocol port host path user password location ]
    
    set lDumpCaptured [ list [ join $lStoreCaptured $sDelimit ] ]

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page   
    foreach instance $Instances {
        if {$bStatus} {puts -nonewline "."}
        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        if { [ info exists Store_Policy($instance) ] == 1 } {
            set sLinks ""
            set lStores $Store_Policy($instance)
            foreach sStore $lStores {
                append sLinks " " "<A HREF=\"policy.html#[Replace_Space $sStore]\">$sStore</A>"
            }
            append Page_Content "<TR>
                <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><B><FONT SIZE=-1>Used in Policy</B></FONT></TD>
                <TD ALIGN=LEFT><FONT SIZE=-1>$sLinks</FONT></TD>
                </TR>"
        }
        set aStore(name) $instance
        set sOriginalName [mql print $Object $instance select property\[original name\].value dump]
        array set aStore "\"Registry Name\" \"$sOriginalName\""
        foreach item $Content {
            set item [ string trim $item ]
            if { $bProcessLocations == "TRUE" } {
                if { [ mql list location $item ] == "" } {
                    set bProcessLocations FALSE
                } else {
                    Add_Value_Element_To_Array Location_Store $item $instance
                    set aStore(locations) [ lappend aStore(locations) [Replace_Space $item] ]
                    append item_content " " "<A HREF=\"location.html#[Replace_Space ${item}] \
                        \">${item}</A>"
                    continue
                }
            # Case 'data tablespace'
            } elseif { [string match "*data tablespace*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 1]]
                set item_content [join [lrange $item 2 end] ]

            # Case 'index tablespace'
            } elseif { [string match "*index tablespace*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 1]]
                set item_content [join [lrange $item 2 end] ]

           # Case 'total number of business objects'
            } elseif { [string match "*total number of business objects*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 4]]
                set item_content [join [lrange $item 5 end] ]

            } else {
            set item [split $item]
            set item_name [lindex $item 0]
            
            # Property case
            # Extract property name and property value
            if { $item_name == "property" } {
                set property [lrange $item 1 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 1 end]]
                }
                lappend lProp "$item_name \t $item_content"
            } elseif { $item_name == "type" } {
                set item_content [join [lrange $item 1 end]]
                set aStore(type) $item_content
                set sStoreType $item_content
            } elseif { $item_name == "description" } {
                set item_content [join [lrange $item 1 end]]
                set aStore(description) $item_content
            } elseif { $item_name == "filename" } {
                set item_content [join [lrange $item 1 end]]
                set aStore(filename) $item_content
            } elseif { $item_name == "permission" } {
                set item_content [join [lrange $item 1 end]]
                set aStore(permission) $item_content
            } elseif { $item_name == "path" } {
                set item_content [join [lrange $item 1 end]]
                set aStore(path) $item_content
            } elseif { $item_name == "protocol" } {
                set item_content [join [lrange $item 1 end]]
                set aStore(protocol) $item_content
            } elseif { $item_name == "host" } {
                set item_content [join [lrange $item 1 end]]
                set aStore(host) $item_content
            } elseif { $item_name == "user" } {
                set item_content [join [lrange $item 1 end]]
                set aStore(user) $item_content
            } elseif { $item_name == "password" } {
                set item_content [join [lrange $item 1 end]]
                set aStore(password) $item_content
            } elseif { $item_name == "locations:" } {
                set aStore(locations) [ list ]
                set bProcessLocations TRUE
                set item_content ""
                continue
            # Default case
            } else {
                set item_content [join [lrange $item 1 end]]
            }
           }
            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"

        set sInstanceData [ list ]
        #process each store type
        if { $sStoreType == "captured" } {
            foreach sDumpData $lStoreCaptured {
                if { [ info exists aStore($sDumpData) ] == 1 } {
                    if { $sDumpData == "locations" } {
                        set aStore(locations) [ join $aStore(locations) $sSeperator ]
                    }
                    lappend sInstanceData \"$aStore($sDumpData)\"
                }
                lappend sInstanceData $sDelimit
            }
            set sInstanceData [ join $sInstanceData "" ]
            lappend lDumpCaptured $sInstanceData
        } else {
            puts "Store type $sStoreType, not yet supported"
        }
        unset aStore
    }
    append Page_Content "
        </BODY>
        </HTML>
    "

    set lDumpCaptured [ join $lDumpCaptured \n ]
    if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
    return 0
}


################################################################################
# Generate_location
#   Generate HTML page for location
#   
#   Parameters :
#       category
#   Return : none
#
proc Generate_location {  } {

    upvar Location_Store Location_Store
    upvar Location_Site Location_Site
    upvar aAdmin aAdmin
    
    global sDumpSchemaDirSystem
    global sDumpProperties
    global Out_Directory
    global bDumpSchema

    set lProp [list ]

    set sDelimit "\t"

    # Get definition instances
    set Object location
    set Instances $aAdmin($Object)

    set lLocation [ list name {Registry Name} description permission \
        protocol port host path user password ]
    
    set lDump [ list [ join $lLocation $sDelimit ] ]

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page   
    foreach instance $Instances {

        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\"></A>
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>"


        if { [ info exists Location_Store($instance) ] == 1 } {
            set sLinks ""
            set lStores $Location_Store($instance)
            foreach sStore $lStores {
                append sLinks " " "<A HREF=\"store.html#[Replace_Space $sStore]\">$sStore</A>"
            }

            append Page_Content "<TR>
                <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><B><FONT SIZE=-1>Used in store</B></FONT></TD>
                <TD ALIGN=LEFT><FONT SIZE=-1>$sLinks</FONT></TD>
                </TR>"
        }

        if { [ info exists Location_Site($instance) ] == 1 } {
            set sLinks ""
            set lStores $Location_Site($instance)
            foreach sStore $lStores {
                append sLinks " " "<A HREF=\"site.html#[Replace_Space $sStore]\">$sStore</A>"
            }

            append Page_Content "<TR>
                <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><B><FONT SIZE=-1>Used in site</B></FONT></TD>
                <TD ALIGN=LEFT><FONT SIZE=-1>$sLinks</FONT></TD>
                </TR>"
        }

        set aLocation(name) $instance
        set sOriginalName [mql print $Object $instance select property\[original name\].value dump]
        array set aLocation "\"Registry Name\" \"$sOriginalName\""


        foreach item $Content {

            set item [ string trim $item ]

            # Case 'data tablespace'
            if { [string match "*data tablespace*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 1]]
                set item_content [join [lrange $item 2 end] ]

            # Case 'index tablespace'
            } elseif { [string match "*index tablespace*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 1]]
                set item_content [join [lrange $item 2 end] ]

           # Case 'total number of business objects'
            } elseif { [string match "*total number of business objects*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 4]]
                set item_content [join [lrange $item 5 end] ]

            } else {

            set item [split $item]
            set item_name [lindex $item 0]
            
            # Property case
            # Extract property name and property value
            if { $item_name == "property" } {
                set property [lrange $item 1 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 1 end]]
                }
                lappend lProp "$item_name \t $item_content"
            } elseif { $item_name == "description" } {
                set item_content [join [lrange $item 1 end]]
                set aLocation(description) $item_content
            } elseif { $item_name == "permission" } {
                set item_content [join [lrange $item 1 end]]
                set aLocation(permission) $item_content
            } elseif { $item_name == "path" } {
                set item_content [join [lrange $item 1 end]]
                set aLocation(path) $item_content
            } elseif { $item_name == "protocol" } {
                set item_content [join [lrange $item 1 end]]
                set aLocation(protocol) $item_content
            } elseif { $item_name == "host" } {
                set item_content [join [lrange $item 1 end]]
                set aLocation(host) $item_content
            } elseif { $item_name == "user" } {
                set item_content [join [lrange $item 1 end]]
                set aLocation(user) $item_content
            } elseif { $item_name == "password" } {
                set item_content [join [lrange $item 1 end]]
                set aLocation(password) $item_content
            # Default case
            } else {
                set item_content [join [lrange $item 1 end]]
            }
           }
            
            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"

        set sInstanceData [ list ]

        foreach sDumpData $lLocation {
            if { [ info exists aLocation($sDumpData) ] == 1 } {
                lappend sInstanceData \"$aLocation($sDumpData)\"
            }
            lappend sInstanceData $sDelimit
        }
        set sInstanceData [ join $sInstanceData "" ]
        lappend lDump $sInstanceData

        unset aLocation
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

    set lDump [ join $lDump \n ]
    if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
    return 0
}


################################################################################
# Generate_site
#   Generate HTML page for site
#   
#   Parameters :
#       category
#   Return : none
#
proc Generate_site {  } {
    global sDumpSchemaDirSystem
    global sDumpProperties
    global Out_Directory
    global bDumpSchema
    set lProp [list ]
    upvar Location_Site Location_Site
    upvar aAdmin aAdmin
    set sDelimit "\t"
    set sSeperator " | "

    # Get definition instances
    set Object site
    set Instances $aAdmin($Object)
    set lSite [ list name {Registry Name} description {member location} ]
    set lDump [ list [ join $lSite $sDelimit ] ]

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "
    # Body of HTML page   
    foreach instance $Instances {
        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}
        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"
        set aData(name) $instance
        set sOriginalName [mql print $Object $instance select property\[original name\].value dump]
        array set aData "\"Registry Name\" \"$sOriginalName\""
        foreach item $Content {
            set item [ string trim $item ]
            # Case 'member location'
            if { [string match "*member location*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 1]]
                set item_content [join [lrange $item 2 end] ]
                if { [ info exists aData(location) ] == 0 } {
                    set aData(location) $item_content
                } else {
                    set aData(location) [ append aData(location) $sSeperator $item_content ]
                }
                Add_Value_Element_To_Array Location_Site $item_content $instance
                set item_content "<A HREF=\"location.html#[Replace_Space ${item_content}] \
                    \">${item_content}</A>"
            } else {
                set item [split $item]
                set item_name [lindex $item 0]
                # Property case
                # Extract property name and property value
                if { $item_name == "property" } {
                    set property [lrange $item 1 end]
                    set value_index [lsearch -exact $property "value"]
                    if { $value_index != -1 } {
                        set item_name [join [lrange $property 0 [expr $value_index -1]]]
                        set item_content [join [lrange $property [expr $value_index +1] end]]
                    } else {
                        set item_content [join [lrange $item 1 end]]
                    }
                    lappend lProp "$item_name \t $item_content"
                } elseif { $item_name == "description" } {
                    set item_content [join [lrange $item 1 end]]
                    set aData(description) $item_content
                # Default case
                } else {
                    set item_content [join [lrange $item 1 end]]
                }
            }
            append Page_Content "<TR>
                <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"

        set sInstanceData [ list ]
        foreach sDumpData $lSite {
            if { [ info exists aData($sDumpData) ] == 1 } {
                lappend sInstanceData \"$aData($sDumpData)\"
            }
            lappend sInstanceData $sDelimit
        }
        set sInstanceData [ join $sInstanceData "" ]
        lappend lDump $sInstanceData

        unset aData
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

    set lDump [ join $lDump \n ]
    if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
    return 0
}



################################################################################
# Generate_server
#   Generate HTML page for server
#   
#   Parameters :
#       category
#   Return : none
#
proc Generate_server {  } {

    global sDumpSchemaDirSystem
    global sDumpProperties
    global Out_Directory
    global bDumpSchema
    upvar aAdmin aAdmin
    set lProp [list ]
    set sDelimit "\t"

    # Get definition instances
    set Object server
    set Instances $aAdmin($Object)
    set lServer [ list name {Registry Name} description user pass connect timezone ]
    set lDump [ list [ join $lServer $sDelimit ] ]
    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "
    # Body of HTML page   
    foreach instance $Instances {
        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}
        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"
        set aData(name) $instance
        set sOriginalName [mql print $Object $instance select property\[original name\].value dump]
        array set aData "\"Registry Name\" \"$sOriginalName\""

        foreach item $Content {
            set item [ string trim $item ]
            # Case 'member location'
            if { [string match "*member location*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 1]]
                set item_content [join [lrange $item 2 end] ]
                set item_content "<A HREF=\"location.html#[Replace_Space ${item_content}] \
                    \">${item_content}</A>"
            } else {
                set item [split $item]
                set item_name [lindex $item 0]
                # Property case
                # Extract property name and property value
                if { $item_name == "property" } {
                    set property [lrange $item 1 end]
                    set value_index [lsearch -exact $property "value"]
                    if { $value_index != -1 } {
                        set item_name [join [lrange $property 0 [expr $value_index -1]]]
                        set item_content [join [lrange $property [expr $value_index +1] end]]
                    } else {
                        set item_content [join [lrange $item 1 end]]
                    }
                    lappend lProp "$item_name \t $item_content"
                } elseif { $item_name == "description" } {
                    set item_content [join [lrange $item 1 end]]
                    set aData(description) $item_content
                } elseif { $item_name == "user" } {
                    set item_content [join [lrange $item 1 end]]
                    set aData(user) $item_content
                } elseif { $item_name == "pass" } {
                    set item_content [join [lrange $item 1 end]]
                    set aData(pass) $item_content
                } elseif { $item_name == "connect" } {
                    set item_content [join [lrange $item 1 end]]
                    set aData(connect) $item_content
                } elseif { $item_name == "timezone" } {
                    set item_content [join [lrange $item 1 end]]
                    set aData(timezone) $item_content
                # Default case
                } else {
                    set item_content [join [lrange $item 1 end]]
                }
            }
            append Page_Content "<TR>
                <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"

        set sInstanceData [ list ]

        foreach sDumpData $lServer {
            if { [ info exists aData($sDumpData) ] == 1 } {
                lappend sInstanceData \"$aData($sDumpData)\"
            }
            lappend sInstanceData $sDelimit
        }
        set sInstanceData [ join $sInstanceData "" ]
        lappend lDump $sInstanceData

        unset aData
        append Page_Content "
            </BODY>
            </HTML>
        "
    }
    set lDump [ join $lDump \n ]
    if {$bDumpSchema} {pfile_write [file join $Out_Directory ${Object}.html] $Page_Content}
    return 0
}


################################################################################
# Generate_Table
#   Generate HTML page for simple category of business definitions
#
#   Parameters :
#       category
#   Return : none
#
proc Generate_table { } {
    global Out_Directory
    global sDumpProperties
    global bDumpSchema
    upvar aAdmin aAdmin

    set lProp [list ]

    # Get definition instances
    set Object table
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {

        if {[catch {set Content [lrange [split [mql print $Object $instance system] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        foreach item $Content {
            set item [split [string trim $item]]
            set item_name [lindex $item 0]

            # Property case
            # Extract property name and property value
            if { $item_name == "property" } {
                set property [lrange $item 1 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 1 end]]
                }
                lappend lProp "$item_name \t $item_content"

            # Default case
            } else {
                set item_content [join [lrange $item 1 end]]
            }

            regsub -all -- "<" $item_content {\&#60;} item_content
            regsub -all -- ">" $item_content {\&#62;} item_content
            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

        if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
}


################################################################################
# Generate_command
#   Generate HTML
#   Generate MQL
#   Parameters :
#       category
#   Return : none
#
proc Generate_command {  } {

    global sDumpSchemaDirSystem
    global Out_Directory
    global sDumpProperties
    global bDumpSchema
    global bDumpMQL

    upvar aAdmin aAdmin
    
    set sDelimit "\t"

    set lProp [list ]

    # Get definition instances
    set Object command
    set Instances $aAdmin($Object)

    set lLabels [ list description label href alt setting user ]
    
    set lDump [ list [ join $lLabels $sDelimit ] ]
    set lMql [ list ]

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page   
    foreach instance $Instances {
        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        set aData(name) $instance

        foreach item $Content {

            set item [ string trim $item ]

            # Case 'data tablespace'
            if { [string match "*data tablespace*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 1]]
                set item_content [join [lrange $item 2 end] ]
                set aData(tablespace) $item_content

            } else {

            set item [split $item]
            set item_name [lindex $item 0]
            
            # Property case
            # Extract property name and property value
            if { $item_name == "property" } {
                set property [lrange $item 1 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 1 end]]
                }
                lappend lProp "$item_name \t $item_content"
                
            } elseif { $item_name == "description" } {
                set item_content [join [lrange $item 1 end]]
                set aData(description) $item_content
            } elseif { $item_name == "label" } {
                set item_content [join [lrange $item 1 end]]
                set aData(label) $item_content
            } elseif { $item_name == "href" } {
                set item_content [join [lrange $item 1 end]]
                set aData(href) $item_content
            } elseif { $item_name == "alt" } {
                set item_content [join [lrange $item 1 end]]
                set aData(alt) $item_content
            } elseif { $item_name == "setting" } {
                set nValue [ lsearch $item value ]
                set sFirstValue [ lrange $item 1 [expr $nValue - 1] ]
                set sSeconValue [ lrange $item [expr $nValue + 1] end ]
                if {[info exists aData(setting)] == 0} {
                    set aData(setting) [list "$sFirstValue $sSeconValue"]
                } else {
                    set aDate(setting) [lappend aData(setting) [list $sFirstValue $sSeconValue] ]
                }
            } elseif { $item_name == "user" } {
                set item_content [join [lrange $item 1 end]]
                if {[info exists aData(user)] == 0} {
                    set aData(user) [list $item_content]
                } else {
                    set aData(user) [lappend aData(user) $item_content]
                }
            # Default case
            } else {
                set item_content [join [lrange $item 1 end]]
            }
           }
            
            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"

        set sCode "\n\n"
        append sCode "puts stdout \"Add $Object ...\""
        append sCode "\n\nset bRegister 1\n\n"
        append sCode "set sMql \"mql add $Object \\\"$instance\\\"\"\n"
        append sCode "pProcessMqlCmd \$bRegister \$sMql\n\n"
        append sCode "puts stdout \"Mod $Object ...\"\n\n"
        append sCode "set bRegister 0\n\n"
        append sCode "set sMql \"mql mod $Object \\\"$instance\\\" \\\n"
        foreach sDumpData $lLabels {
            if { [ info exists aData($sDumpData) ] == 1 } {
                switch $sDumpData {
                    user {
                        foreach sUser $aData($sDumpData) {
                            append sCode "    add user " \\\"$sUser\\\" " \\\n"
                        }
                    }
                    setting {
                        foreach sSet $aData($sDumpData) {
                            append sCode "    add setting " \\\"[lindex $sSet 0]\\\" " " "\\\"[lindex $sSet 1]\\\" \\\n"
                        }
                    }
                    default {append sCode "    " $sDumpData " " \\\"$aData($sDumpData)\\\" " \\\n"}
                }
            }
        }
        append sCode "  \"\n\n"
        append sCode "pProcessMqlCmd \$bRegister \$sMql\n\n"
        lappend lMql $sCode
        unset aData
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

    set lDump [ join $lDump \n ]
    set lMql [join $lMql \n]
    if {$bDumpMQL} {pfile_write [file join $sDumpSchemaDirSystem ${Object}.tcl] $lMql}
    if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
    return 0
}



################################################################################
# Generate_channel
#   Generate HTML
#   Generate MQL
#   Parameters :
#       category
#   Return : none
#
proc Generate_channel {  } {

    global sDumpSchemaDirSystem
    global Out_Directory
    global sDumpProperties
    global bDumpSchema
    global bDumpMQL

    upvar aAdmin aAdmin
    
    set sDelimit "\t"

    set lProp [list ]

    # Get definition instances
    set Object channel
    set Instances $aAdmin($Object)

    set lLabels [ list description label href alt setting command ]
    
    set lDump [ list [ join $lLabels $sDelimit ] ]
    set lMql [ list ]

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page   
    foreach instance $Instances {
        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        set aData(name) $instance

        foreach item $Content {

            set item [ string trim $item ]

            # Case 'data tablespace'
            if { [string match "*data tablespace*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 1]]
                set item_content [join [lrange $item 2 end] ]
                set aData(tablespace) $item_content

            } else {

            set item [split $item]
            set item_name [lindex $item 0]
            
            # Property case
            # Extract property name and property value
            if { $item_name == "property" } {
                set property [lrange $item 1 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 1 end]]
                }
                lappend lProp "$item_name \t $item_content"
                
            } elseif { $item_name == "description" } {
                set item_content [join [lrange $item 1 end]]
                set aData(description) $item_content
            } elseif { $item_name == "label" } {
                set item_content [join [lrange $item 1 end]]
                set aData(label) $item_content
            } elseif { $item_name == "href" } {
                set item_content [join [lrange $item 1 end]]
                set aData(href) $item_content
            } elseif { $item_name == "alt" } {
                set item_content [join [lrange $item 1 end]]
                set aData(alt) $item_content
            } elseif { $item_name == "setting" } {
                set nValue [ lsearch $item value ]
                set sFirstValue [ lrange $item 1 [expr $nValue - 1] ]
                set sSeconValue [ lrange $item [expr $nValue + 1] end ]
                if {[info exists aData(setting)] == 0} {
                    set aData(setting) [list "$sFirstValue $sSeconValue"]
                } else {
                    set aDate(setting) [lappend aData(setting) [list $sFirstValue $sSeconValue] ]
                }
            } elseif { $item_name == "command" } {
                set item_content [join [lrange $item 1 end]]
                if {[info exists aData(command)] == 0} {
                    set aData(command) [list $item_content]
                } else {
                    set aData(command) [lappend aData(command) $item_content]
                }
            # Default case
            } else {
                set item_content [join [lrange $item 1 end]]
            }
           }
            
            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"

        set sCode "\n\n"
        append sCode "puts stdout \"Add $Object ...\""
        append sCode "\n\nset bRegister 1\n\n"
        append sCode "set sMql \"mql add $Object \\\"$instance\\\"\"\n"
        append sCode "pProcessMqlCmd \$bRegister \$sMql\n\n"
        append sCode "puts stdout \"Mod $Object ...\"\n\n"
        append sCode "set bRegister 0\n\n"
        append sCode "set sMql \"mql mod $Object \\\"$instance\\\" \\\n"
        foreach sDumpData $lLabels {
            if { [ info exists aData($sDumpData) ] == 1 } {
                switch $sDumpData {
                    command {
                        foreach sCommand $aData($sDumpData) {
                            append sCode "    add command " \\\"$sCommand\\\" " \\\n"
                        }
                    }
                    setting {
                        foreach sSet $aData($sDumpData) {
                            append sCode "    add setting " \\\"[lindex $sSet 0]\\\" " " "\\\"[lindex $sSet 1]\\\" \\\n"
                        }
                    }
                    default {append sCode "    " $sDumpData " " \\\"$aData($sDumpData)\\\" " \\\n"}
                }
            }
        }
        append sCode "  \"\n\n"
        append sCode "pProcessMqlCmd \$bRegister \$sMql\n\n"
        lappend lMql $sCode
        unset aData
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

    set lDump [ join $lDump \n ]
    set lMql [join $lMql \n]
    if {$bDumpMQL} {pfile_write [file join $sDumpSchemaDirSystem ${Object}.tcl] $lMql}
    if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
    return 0
}



################################################################################
# Generate_portal
#   Generate HTML
#   Generate MQL
#   Parameters :
#       category
#   Return : none
#
proc Generate_portal {  } {

    global sDumpSchemaDirSystem
    global Out_Directory
    global sDumpProperties
    global bDumpSchema
    global bDumpMQL

    upvar aAdmin aAdmin
    
    set sDelimit "\t"

    set lProp [list ]

    # Get definition instances
    set Object portal
    set Instances $aAdmin($Object)

    set lLabels [ list description label href alt setting channel ]
    
    set lDump [ list [ join $lLabels $sDelimit ] ]
    set lMql [ list ]

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page   
    foreach instance $Instances {
        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        set aData(name) $instance

        foreach item $Content {

            set item [ string trim $item ]

            # Case 'data tablespace'
            if { [string match "*data tablespace*" $item] == 1 } {
                set item [split $item]
                set item_name [join [lrange $item 0 1]]
                set item_content [join [lrange $item 2 end] ]
                set aData(tablespace) $item_content

            } else {

            set item [split $item]
            set item_name [lindex $item 0]
            
            # Property case
            # Extract property name and property value
            if { $item_name == "property" } {
                set property [lrange $item 1 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 1 end]]
                }
                lappend lProp "$item_name \t $item_content"
                
            } elseif { $item_name == "description" } {
                set item_content [join [lrange $item 1 end]]
                set aData(description) $item_content
            } elseif { $item_name == "label" } {
                set item_content [join [lrange $item 1 end]]
                set aData(label) $item_content
            } elseif { $item_name == "href" } {
                set item_content [join [lrange $item 1 end]]
                set aData(href) $item_content
            } elseif { $item_name == "alt" } {
                set item_content [join [lrange $item 1 end]]
                set aData(alt) $item_content
            } elseif { $item_name == "setting" } {
                set nValue [ lsearch $item value ]
                set sFirstValue [ lrange $item 1 [expr $nValue - 1] ]
                set sSeconValue [ lrange $item [expr $nValue + 1] end ]
                if {[info exists aData(setting)] == 0} {
                    set aData(setting) [list "$sFirstValue $sSeconValue"]
                } else {
                    set aDate(setting) [lappend aData(setting) [list $sFirstValue $sSeconValue] ]
                }
            } elseif { $item_name == "channel" } {
                set item_content [join [lrange $item 1 end]]
                if {[info exists aData(channel)] == 0} {
                    set aData(channel) [list $item_content]
                } else {
                    set aData(channel) [lappend aData(channel) $item_content]
                }
            # Default case
            } else {
                set item_content [join [lrange $item 1 end]]
            }
           }
            
            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        append Page_Content "\n</TABLE><BR><BR>"

        set sCode "\n\n"
        append sCode "puts stdout \"Add $Object ...\""
        append sCode "\n\nset bRegister 1\n\n"
        append sCode "set sMql \"mql add $Object \\\"$instance\\\"\"\n"
        append sCode "pProcessMqlCmd \$bRegister \$sMql\n\n"
        append sCode "puts stdout \"Mod $Object ...\"\n\n"
        append sCode "set bRegister 0\n\n"
        append sCode "set sMql \"mql mod $Object \\\"$instance\\\" \\\n"
        foreach sDumpData $lLabels {
            if { [ info exists aData($sDumpData) ] == 1 } {
                switch $sDumpData {
                    user {
                        foreach sUser $aData($sDumpData) {
                            append sCode "    add channel " \\\"$sChannel\\\" " \\\n"
                        }
                    }
                    setting {
                        foreach sSet $aData($sDumpData) {
                            append sCode "    add setting " \\\"[lindex $sSet 0]\\\" " " "\\\"[lindex $sSet 1]\\\" \\\n"
                        }
                    }
                    default {append sCode "    " $sDumpData " " \\\"$aData($sDumpData)\\\" " \\\n"}
                }
            }
        }
        append sCode "  \"\n\n"
        append sCode "pProcessMqlCmd \$bRegister \$sMql\n\n"
        lappend lMql $sCode
        unset aData
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

    set lDump [ join $lDump \n ]
    set lMql [join $lMql \n]
    if {$bDumpMQL} {pfile_write [file join $sDumpSchemaDirSystem ${Object}.tcl] $lMql}
    if { $bDumpSchema } { pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content }
    return 0
}



################################################################################
# Generate_Simple
#   Generate HTML page for simple category of business definitions
#
#   Parameters :
#       category
#   Return : none
#
proc Generate_Simple { category } {

    global Out_Directory
    global sDumpProperties
    global bDumpSchema
    upvar aAdmin aAdmin
    upvar aDirs aDirs

    set lProp [list ]

    # Get definition instances
    set Object $category
    set Instances $aAdmin($Object)

    # Head of HTML page
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$Object</TITLE>
        </HEAD>
        <BODY>
    "

    # Body of HTML page
    foreach instance $Instances {

        if {[catch {set Content [lrange [split [mql print $Object $instance] \n] 1 end]} sMsg] != 0} {continue}

        append Page_Content "
            <A NAME=\"[Replace_Space $instance]\">
            <TABLE BORDER=0>
            <TR>
            <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>$Object</FONT></TD>
            <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>$instance</FONT></TD>
            </TR>
            </A>"

        foreach item $Content {
            set item [split $item]
            set item_name [lindex $item 2]

            # Property case
            # Extract property name and property value
            if { $item_name == "property" } {
                set property [lrange $item 3 end]
                set value_index [lsearch -exact $property "value"]
                if { $value_index != -1 } {
                    set item_name [join [lrange $property 0 [expr $value_index -1]]]
                    set item_content [join [lrange $property [expr $value_index +1] end]]
                } else {
                    set item_content [join [lrange $item 3 end]]
                }
                lappend lProp "$item_name \t $item_content"

            # Default case
            } else {
                set item_content [join [lrange $item 3 end]]
            }

            append Page_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$item_name</B></FONT></TD>
                  <TD ALIGN=LEFT><FONT SIZE=-1>$item_content</FONT></TD>
                </TR>"
        }
        if { [ llength $lProp ] > 0 } {
            set lProp [ join $lProp \n ]
        }
        set lProp [list ]
        if { $Object == "command" || $Object == "menu" || $Object == "channel" || $Object == "portal" || $Object == "page" || $Object == "interface" || $Object == "expression" || $Object == "index" || $Object == "dimension"} {
            # Do nothing
        } else {
        }
        append Page_Content "\n</TABLE><BR><BR>"
    }

    append Page_Content "
        </BODY>
        </HTML>
    "

    if { $bDumpSchema } { 
        if {$Object != "index"} {
             pfile_write [ file join $Out_Directory ${Object}.html ] $Page_Content
        } else {
             pfile_write [ file join $Out_Directory index_.html ] $Page_Content
        }
    }
         
    return 0
}



################################################################################
# Generate_Summary_Menu
#   Generate HTML page for a menu page (left frame)
#
#   Parameters :
#       category
#   Return : none
#
proc Generate_Summary_Menu { category } {
    upvar Category_Order Category_Order
    upvar Out_Directory Out_Directory
    upvar Statistic Statistic
    upvar aAdmin aAdmin
    global bDumpSchema
    global glsTriggerManagerObjects


    set Summary_Menu_Page "
        <HTML>
        <HEAD>
        <TITLE>$category</TITLE>
        </HEAD>
        <BODY>
        <A HREF=general.html TARGET=Category><IMG SRC=Images/ematrix_logo.gif BORDER=0 WIDTH=145 HEIGHT=32></A><BR><BR><BR>
    "

    foreach category_menu $Category_Order {

        # List administrative objects for category asked
        if { $category_menu == $category } {
            append Summary_Menu_Page "<A HREF=summary.html TARGET=\"Summary\"><IMG SRC=Images/moins.gif BORDER=0 WIDTH=9 HEIGHT=9> $category_menu</A><BR>"
            if {$category == "Trigger Manager Objects"} {
                set Objects [lsort -dictionary $glsTriggerManagerObjects]
                append Summary_Menu_Page "<TABLE BORDER=0 CELLSPACING=0>"
                foreach object $Objects {
                    append Summary_Menu_Page "
                            <TR><TD WIDTH=25>&nbsp;</TD>
                            <TD ALIGN=LEFT NOWRAP><A HREF=\"[Replace_Space $category].html#[Replace_Space $object]\" TARGET=\"Category\">$object</A><BR></TD>
                            </TR>
                    "
            }
            append Summary_Menu_Page "</TABLE>"

            } else {
                set Objects $aAdmin($category)
                append Summary_Menu_Page "<TABLE BORDER=0 CELLSPACING=0>"
                foreach object $Objects {
                    set sSubstitute [Replace_Space $category]
                    if {$sSubstitute == "index"} {set sSubstitute "index_"}
                    append Summary_Menu_Page "
                            <TR><TD WIDTH=25>&nbsp;</TD>
                            <TD ALIGN=LEFT NOWRAP><A HREF=\"$sSubstitute.html#[Replace_Space $object]\" TARGET=\"Category\">$object</A><BR></TD>
                            </TR>
                    "
                }
                append Summary_Menu_Page "</TABLE>"

            }
            # Update Statistic
            #puts "Add_Value_Element_To_Array Statistic $category [llength $Objects]"
            Add_Value_Element_To_Array Statistic $category [llength $Objects]

        # Display a link for other category
        } else {
            if {$category_menu == "index"} {
                append Summary_Menu_Page "<A HREF=\"index__menu.html\" TARGET=\"Summary\"><IMG SRC=Images/plus.gif BORDER=0 WIDTH=9 HEIGHT=9> $category_menu</A><BR>"
            } else {
                append Summary_Menu_Page "<A HREF=\"${category_menu}_menu.html\" TARGET=\"Summary\"><IMG SRC=Images/plus.gif BORDER=0 WIDTH=9 HEIGHT=9> $category_menu</A><BR>"
            }
        }
    }

    #puts "[array get Statistic]"
    if { $bDumpSchema } { pfile_write [ file join $Out_Directory [Replace_Space $category]_menu.html ] $Summary_Menu_Page }
    return 0
}


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
# Procedure:   pfile_read
#
# Description: Procedure to read a file.
#
# Parameters:  The filename to read from.
#
# Returns:     The file data
#************************************************************************

proc pfile_read { filename } {

  set data ""
  if { [file readable $filename] } {
    set fd [open $filename "r"]
    set data [read $fd]
    close $fd
  }
  return $data
}
#End file_read



proc pRemSpecChar {filename} {

    # Note, still need to add double quote, less than and greater than.
    #List elements are, {\\\" %22} {< %3C} {> %3E}
    set lChar [list {\\\\ %5C} {/ %2F} {: %3A} {\\\* %2A} {\\\? %3F} {\\\| %7C}]

    foreach i $lChar {

        set sLabel [lindex $i 0]
        set sValue [lindex $i 1]

        regsub -all -- "$sLabel" $filename "$sValue" filename

    }

    return $filename

}
#End pRemSpecChar



proc pFormat { lData sHead sType } {

    global lAccessModes
    global sPositive
    global sNegative


    set sFormat ""
    append sFormat "<html>\n"
    append sFormat {
        <STYLE type=text/css>
        TD.odd {
            BACKGROUND-COLOR: #DDDBCC
        }
        TD.even {
            BACKGROUND-COLOR: #FFFFFF
        }
        </STYLE>
    }
    append sFormat "<head>"
    append sFormat "<title>HTML document</title>"
    append sFormat "</head>\n"
    append sFormat "<body>"
    append sFormat "<h1><center>$sType - $sHead</center></h1>\n\n"

    set sFontC {#0000ff}

    if { [ llength $lData ] == 0 } {
        append sFormat "<h2><center>No Data</center></h2>\n"
        return $sFormat
    }

    append sFormat "<div style=\"width:80%\">\n"
    append sFormat "<table rows=\"1\" border=\"1\" cols=\"35\" align=\"Center\" border=\"1\" callpadding=\"1\" cellspacing=\"1\" width=\"100%\" ID=\"tblHeader\">\n"
    # construct the table header row
    append sFormat "<tr>\n"
    if { $sType == "Policy" } {
        append sFormat "<td CLASS=even VALIGN=BOTTOM ALIGN=LEFT><B>State</B></td>\n"
        append sFormat "<td CLASS=even VALIGN=BOTTOM ALIGN=LEFT><B>User</B></td>\n"
    } else {
        append sFormat "<td CLASS=even VALIGN=BOTTOM ALIGN=LEFT><B>Policy</B></td>\n"
        append sFormat "<td CLASS=even VALIGN=BOTTOM ALIGN=LEFT><B>State</B></td>\n"
    }
    # construct the access headers
    set lModes $lAccessModes
    lappend lModes Filter
    
    if {$sType == "Policy"} {
        foreach sMode $lModes {
            append sFormat "<td CLASS=even VALIGN=BOTTOM ALIGN=CENTER><IMG SRC=\"../Images/[string tolower $sMode].gif\" ALT=\"$sMode\"></TD>\n"
        }
    } else {
        foreach sMode $lModes {
            append sFormat "<td CLASS=even VALIGN=BOTTOM ALIGN=CENTER><IMG SRC=\"../../Images/[string tolower $sMode].gif\" ALT=\"$sMode\"></TD>\n"
        }
    }
    append sFormat "</tr>\n"
    append sFormat "</table>\n"

    append sFormat "<div style=\"height:400;overflow:auto;\">\n"
    append sFormat "<table cols=\"35\" border=\"1\" width=\"100%\" id=\"tblData\">\n"
    append sFormat "<tr height=\"0\">\n"

    for {set x 0} {$x < 35} {incr x} {
        append sFormat "<td></td>\n"
    }
    append sFormat "</tr>\n"

    set sData $lData
    set sLastPolicy ""
    set sLastState ""
    set sMajorRowClass "even"
    set sMinorRowClass "even"
    set sBlankRowClass "Spacer"
    set nAccessColumns [expr [llength $lAccessModes] + 3]
    set sSeparator "<TD COLSPAN=$nAccessColumns COLOR=\"#000000\" BGCOLOR=\"#000000\"><img src=\"../Images/utilspace.gif\" width=1 height=1></TD>\n"
    set sPositiveImage "Y"
    set sNegativeImage "&nbsp"

    set sTempData "@[join $sData @]"
    foreach line $sData {
        if { $line == "" } {
            continue
        }
        set sPolicyData [ lindex $line 1 ]
        set sLeft [ split [ lindex $line 0 ] , ]
        set sOwner [ lindex $sLeft 2 ]
        set sLeft [ split [ lindex $sLeft 0 ] | ]
        set sPolicy [ lindex $sLeft 0 ]
        set sState [ lindex $sLeft 2 ]
        set sRights [ lindex $sPolicyData 0 ]
        set sFilter [ lindex $sPolicyData 1 ]
        if { $sFilter == "" } {
            set sFilter "-"
        }
        append sFormat "<tr>"
        regsub -all {\(} $sPolicy {\\(} sTempPolicy
        regsub -all {\)} $sTempPolicy {\\)} sTempPolicy
        if { $sType == "Policy" } {
            # figure out how many rows there are with the same state
            # Make the state Name spans the correct number of rows
            if {$sState != $sLastState} {
                set sMatch "@\[\{\]?$sTempPolicy\\|\[0-9\]+\\|$sState\\," ;#check for \}
                set nNumUsersPerState [regsub -all $sMatch $sTempData {} sGarbage]
                append sFormat "$sSeparator</tr><tr>"
                append sFormat "<td CLASS=\"$sMajorRowClass\" rowspan=$nNumUsersPerState>$sState</td>"
                if {$sMajorRowClass == "odd"} {
                    set sMajorRowClass "even"
                } else {
                    set sMajorRowClass "odd"
                }
            }
            append sFormat "<td CLASS=\"$sMinorRowClass\"><A HREF=\"user/[Replace_Space $sOwner].html\">$sOwner</A></td>"
        } else {
            if {$sPolicy != $sLastPolicy} {
                set sMatch "@\[\{\]?$sTempPolicy\\|\[0-9\]+\\|\[^\\|\\,\]+\\,\[0-9\]+\\,$sOwner" ;#check for \}
                set nNumStatesPerPolicy [regsub -all $sMatch $sTempData {????} sGarbage]
                append sFormat "$sSeparator</tr><tr>\n"
                append sFormat "<td CLASS=\"$sMajorRowClass\" rowspan=$nNumStatesPerPolicy><A HREF=\"../[Replace_Space $sPolicy].html\">$sPolicy</A></td>"
                if {$sMajorRowClass == "odd"} {
                    set sMajorRowClass "even"
                } else {
                    set sMajorRowClass "odd"
                }
            }
            append sFormat "<td CLASS=\"$sMinorRowClass\">$sState</td>"
        }

        if { $sRights == "all" } {
            set sNegativeValue $sPositiveImage
        } else {
            set sNegativeValue $sNegativeImage
        }
        foreach sMode $lAccessModes {
            set sMode [string tolower $sMode]
            if { [ lsearch $sRights $sMode ] == -1 } {
                append sFormat "<td CLASS=\"$sMinorRowClass\">$sNegativeValue</td>"
            } else {
                append sFormat "<td CLASS=\"$sMinorRowClass\">$sPositiveImage</td>"
            }
        }
        append sFormat "<td CLASS=\"$sMinorRowClass\"> $sFilter</td>"
        append sFormat "</tr>\n\n"
        if {$sMinorRowClass == "odd"} {
            set sMinorRowClass "even"
        } else {
            set sMinorRowClass "odd"
        }
        set sLastState $sState
        set sLastPolicy $sPolicy
    }

    append sFormat "</td>\n"
    append sFormat "        </table>\n"
    append sFormat "</div>\n"
    append sFormat "</td> </tr> </table>\n"
    append sFormat "</div>\n"

    append sFormat "<script language=\"javascript\">

    doSyncTables();
    function doSyncTables(){
    var i;
    var nDtlCol = document.getElementById('tblData').rows\[0\].cells.length;
    var hdrColLength=\"\";
    var dltColLength=\"\";
    var dltColLength2=\"\";
    var colWidth = 0;

    for (i=0; i < nDtlCol; i++) {
        dltColLength2 = document.getElementById('tblHeader').cells\[i\].offsetWidth;
        dltColLength = document.getElementById('tblData').cells\[i\].offsetWidth;
        dltColLength2=parseInt(dltColLength2);
        dltColLength=parseInt(dltColLength);
     if (dltColLength<dltColLength2){
         dltColLength = dltColLength2;
     }
     if (dltColLength > 0){
         document.getElementById('tblData').cells\[i\].width = dltColLength;
         document.getElementById('tblHeader').cells\[i\].width = dltColLength;
     }     
     }     
     window.tblHeader.width  = window.tblData.offsetWidth;
     }
     </script>\n"

    append sFormat "    </body>\n"
    append sFormat "</html>\n"

    return $sFormat
}

proc Generate_ExtendedPolicy { } {

    global bDumpSchema
    global bStatus
    global bExtendedPolicy
    global lExtendedPersonData
    global Out_Directory
    global lAccessModes
    global nMxVer
    upvar aAdmin aAdmin

    set lAccessModes [ list Read Modify Delete Checkout Checkin Schedule Lock \
        Unlock Execute Freeze Thaw Create Revise Promote Demote Grant Enable \
        Disable Override ChangeName ChangeType ChangeOwner ChangePolicy Revoke \
        ChangeVault FromConnect ToConnect FromDisconnect ToDisconnect \
        ViewForm Modifyform Show ]

#    set lAccessModes [ list read modify delete checkout checkin lock unlock \
#        changeowner promote demote schedule override enable disable create \
#        revise changevault changename changepolicy changetype fromconnect \
#        toconnect fromdisconnect todisconnect freeze thaw execute modifyform \
#        viewform grant show]
        
    set lSpecialUsers [ list Public Owner ]
        
    global sPositive
    global sNegative

    set sPositive Y
    set sNegative "-"

    set lPolicy $aAdmin(policy)
    set lRule $aAdmin(rule)
    set lPerson $aAdmin(person)
    set lRole $aAdmin(role)
    set lGroup $aAdmin(group)
    set lAssociation $aAdmin(association)

    if {$bStatus} {puts "Start Process Extended Policy ..."}

    foreach sPol $lPolicy {
        set sStates [ split [ mql print policy $sPol select state dump | ] | ]
        set bAllstate FALSE
        if {$nMxVer >= 10.8} {set bAllstate [ mql print policy $sPol select allstate dump ]}
        if {$sStates != [list ] && $bAllstate} {lappend sStates "allstate"}
        set sStOrder 0
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
                    #MODIFICATION by FIT -start
                    set sLine [ split $i "=" ]
		    #Modified to fix incident 365960 on 7th Jan 09 - Start
		    set sUs [string range [ string trim [lindex $sLine 0 ]] [ string first "." $sLine ] end ]
		    #Modified to fix incident 365960 on 7th Jan 09 - End
	    
                    #set sLine [ lindex [ split $i "." ] 1 ]
                    #set sLine [ split $sLine "=" ]
                    #MODIFICATION by FIT -end
                    set sRights [ split [ string trim [ lindex $sLine 1 ] ] , ]
                    if { $sRights == "all" } {
#                        set sRights $lAccessModes
                    } elseif { $sRights == "none" } {
                        set sRights ""
                    }
                    #MODIFICATION by FIT -start
                    #set sUs [string trim [ lindex $sLine 0 ] ]
                    #MODIFICATION by FIT -end
                    
                    if {[string first "access\[" $sUs] > -1} {
                        regsub "access\134\[" $sUs "|" sUs
                        set sUs [lindex [split $sUs |] 1]
                        regsub "\134\]" $sUs "" sOwner
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
 
    set sSpin ""
    set bb ""
    if {$bStatus} {puts "Start Process Extended Policy by Policy Name ..."}
    foreach sP $lPolicy {
        set pu [ lsort -dictionary [ array name data "$sP|*|*,*,*" ] ]
        foreach i $pu {
            lappend sSpin [ list $i $data($i) ]
        }
        if { $bDumpSchema && $bExtendedPolicy } {
            set bb [ pFormat $sSpin $sP Policy ]
            set sFile [ Replace_Space $sP ]
            pfile_write $Out_Directory/Policy/$sFile.html $bb
        }
        set bb ""
        set sSpin ""
        set sPolicySpin ""
    }
     
    if {$bStatus} {puts "Start Process Extended Rule ..."}

    foreach sRul $lRule {
        set sOwner [ split [ string trim [ mql print rule $sRul select owneraccess dump | ] ] , ]
        set data($sRul|0|$sRul,0,Owner) [ list $sOwner "" ]
        set sPublic [ split [ string trim [ mql print rule $sRul select publicaccess dump | ] ] , ]
        set data($sRul|0|$sRul,0,Public) [ list $sPublic "" ]
        set sUsers [ split [ mql print rule $sRul select access ] \n ]
        foreach i $sUsers {
            set i [ string trim $i ]
            if {[string first "rule" $i] == 0} {continue}
            if { $i != "" } {
                set sLine [ split $i "=" ]
                set sRights [ split [ string trim [ lindex $sLine 1 ] ] , ]
                if { $sRights == "all" } {
#                    set sRights $lAccessModes
                } elseif { $sRights == "none" } {
                    set sRights ""
                }
                set sUs [string trim [ lindex $sLine 0 ] ]
                if {[string first "access\[" $sUs] > -1} {
                    regsub "access\134\[" $sUs "|" sUs
                    set sUs [lindex [split $sUs |] 1]
                    regsub "\134\]" $sUs "" sOwner
                    set sExpression [ mql print rule "$sRul" select filter\[$sOwner\] dump ]
                    set data($sRul|0|$sRul,1,$sOwner) [ list $sRights $sExpression ]
                }
            }
        }
    }
 
    set sSpin ""
    set bb ""
    if {$bStatus} {puts "Start Process Extended Rule by Rule Name ..."}
    foreach sR $lRule {
        set ru [ lsort -dictionary [ array name data "$sR|*|*,*,*" ] ]
        foreach i $ru {
            lappend sSpin [ list $i $data($i) ]
        }
        if { $bDumpSchema && $bExtendedPolicy } {
            set bb [ pFormat $sSpin $sR Rule ]
            set sFile [ Replace_Space $sR ]
            pfile_write $Out_Directory/Rule/$sFile.html $bb
        }
        set bb ""
        set sSpin ""
        set sRuleSpin ""
    }
     
    set sSpin ""
    set bb ""
    if { $bDumpSchema && $bExtendedPolicy} {
        if {$bStatus} {puts "Start Process Extended Policy Schema for Person ..."}
        foreach sP $lPerson {
            set pu [ lsort -dictionary [ array name data "*,*,$sP" ] ]
            if {$pu == ""} {continue}
            lappend lExtendedPersonData $sP
            foreach i $pu {
                lappend sSpin [ list $i $data($i) ]
            }
            set bb [ pFormat $sSpin $sP Person ]
            set sFile [ Replace_Space $sP ]
            pfile_write $Out_Directory/Policy/user/$sFile.html $bb
            set bb ""
            set sSpin ""
        }
    }


    set sSpin ""
    set bb ""
    if { $bDumpSchema && $bExtendedPolicy} {
        if {$bStatus} {puts "Start Process Extended Policy Schema for Role ..."}
        foreach sP $lRole {
            set pu [ lsort -dictionary [ array name data "*,*,$sP" ] ]
            foreach i $pu {
                lappend sSpin [ list $i $data($i) ]
            }
            set bb [ pFormat $sSpin $sP Role ]
            set sFile [ Replace_Space $sP ]        
            pfile_write $Out_Directory/Policy/user/$sFile.html $bb
            set bb ""
            set sSpin ""
        }
    }


    set sSpin ""
    set bb ""
    if { $bDumpSchema && $bExtendedPolicy} {
        if {$bStatus} {puts "Start Process Extended Policy Schema for Group ..."}
        foreach sP $lGroup {
            set pu [ lsort -dictionary [ array name data "*,*,$sP" ] ]
            foreach i $pu {
                lappend sSpin [ list $i $data($i) ]
            }
            set bb [ pFormat $sSpin $sP Group ]
            set sFile [ Replace_Space $sP ]        
            pfile_write $Out_Directory/Policy/user/$sFile.html $bb
            set bb ""
            set sSpin ""
        }
    }

    set sSpin ""
    set bb ""
    if { $bDumpSchema && $bExtendedPolicy} {
        if {$bStatus} {puts "Start Process Extended Policy Schema for Association ..."}
        foreach sP $lAssociation {
            set pu [ lsort -dictionary [ array name data "*,*,$sP" ] ]
            foreach i $pu {
                lappend sSpin [ list $i $data($i) ]
            }
            set bb [ pFormat $sSpin $sP Association ]
            set sFile [ Replace_Space $sP ]        
            pfile_write $Out_Directory/Policy/user/$sFile.html $bb
            set bb ""
            set sSpin ""
        }
    }


    set sSpin ""
    set bb ""
    if { $bDumpSchema && $bExtendedPolicy} {
        if {$bStatus} {puts "Start Process Extended Policy Schema for SpecialUsers ..."}
        foreach sP $lSpecialUsers {
            set pu [ lsort -dictionary [ array name data "*,*,$sP" ] ]
            foreach i $pu {
                lappend sSpin [ list $i $data($i) ]
            }
            set bb [ pFormat $sSpin $sP Special ]
            set sFile [ Replace_Space $sP ]        
            pfile_write $Out_Directory/Policy/user/$sFile.html $bb
            set bb ""
            set sSpin ""
        }
    }
}



################################################################################
# Generate_TriggerLinks
#
#   Parameters : TriggerData string
#   Return     : HTML formatted string containing Trigger information and hyperlinks
#
proc Generate_TriggerLinks {lsTriggerData sAdminType sAdminName {sState ""}} {
    upvar aTriggerXRef aTriggerXRef

    global glsPrograms
    global glsTriggerManagerObjects

    set sTempHTML "<TABLE BORDER=0>"
    foreach trigger $lsTriggerData {
        set trigger [split $trigger :]
        set trigger_event [lindex $trigger 0]
        set program_parameters [lindex $trigger 1]
        set bracket_index [string first ( $program_parameters]
        set program_name [string range $program_parameters 0 [expr $bracket_index -1]]
        set parameters [string range $program_parameters [expr $bracket_index +1] [expr [string length $program_parameters] -2]]

        # Add the trigger type,policy, state to the global list of "Where-used" triggers
        set lTriggerRef ""
        catch { set lTriggerRef $aTriggerXRef($program_name) }
        set sRefData "$sAdminType|$sAdminName|$sState|$trigger_event"
        if {[lsearch -exact $lTriggerRef $sRefData] == -1} {
            lappend lTriggerRef $sRefData
        }
        set aTriggerXRef($program_name) $lTriggerRef


        append sTempHTML "<TR><TD><FONT SIZE=-1>$trigger_event</FONT></TD><TD>"
        append sTempHTML "<FONT SIZE=-1><A HREF=\"program.html#[Replace_Space $program_name]\">$program_name</FONT></A> "
        # Assume the parameters are in tcl list format
        # for each list element, see if it is corresponds to an
        # eServiceTrigger object or an actual program
        set sParamData ""
        foreach sParam $parameters {
            set bIsProgram [lsearch -exact $glsPrograms $sParam]
            set bIsTriggerObject [lsearch -exact $glsTriggerManagerObjects $sParam]
            if {$bIsProgram != -1  || $bIsTriggerObject != -1 } \
            {
                set lTriggerRef ""
                catch { set lTriggerRef $aTriggerXRef($sParam) }
                set sRefData "$sAdminType|$sAdminName|$sState|$trigger_event"
                if {[lsearch -exact $lTriggerRef $sRefData] == -1} {
                    lappend lTriggerRef $sRefData
                }
                set aTriggerXRef($sParam) $lTriggerRef

                # create the hyperlinks to the parameters
                if {$bIsProgram != -1} {
                    set sProgramLink "<A HREF=\"program.html#[Replace_Space $sParam]\"><FONT SIZE=-1>$sParam</FONT></A>"
                } elseif {$bIsTriggerObject != -1} {
                    set sProgramLink "<A HREF=\"Trigger_Manager_Objects.html#[Replace_Space $sParam]\"><FONT SIZE=-1>$sParam</FONT></A>"
                } else {
                    set sProgramLink "<FONT SIZE=-1>$sParam</FONT>"
                }
                append sParamData " $sProgramLink"
            }
        }
        if {$sParamData == ""} {
            set sParamData "&nbsp;"
        }

        append sTempHTML "$sParamData</TD></TR>\n"
#        append sTempHTML "<TR><TD><FONT SIZE=-1>$trigger_event</FONT></TD>  <TD><FONT SIZE=-1><A HREF=\"program.html#[Replace_Space $program_name]\">$program_name</FONT></A> <FONT SIZE=-1>$parameters</FONT></TD></TR>"
    }
    append sTempHTML "</TABLE>"

    return $sTempHTML

}


################################################################################
# Generate_TriggerObjects
#
#   Parameters : none
#   Return     : none
#
proc Generate_TriggerObjects { } {
  global Out_Directory Out_Directory
  global bDumpSchema
  set sType "eService Trigger Program Parameters"

  if { [ catch { mql print type $sType } sErr ] == 0 } {


#  set lHeads [ list "type 1" name revision current desc ]
#    set lAtt [list "eService Program Name" "eService Sequence Number" \
#        "eService Program Argument 1" "eService Program Argument Desc 1" \
#        "eService Program Argument 2" "eService Program Argument Desc 2" \
#        "eService Program Argument 3" "eService Program Argument Desc 3" \
#        "eService Program Argument 4" "eService Program Argument Desc 4" \
#        "eService Program Argument 5" "eService Program Argument Desc 5" \
#        "eService Program Argument 6" "eService Program Argument Desc 6" \
#        "eService Program Argument 7" "eService Program Argument Desc 7" \
#        "eService Program Argument 8" "eService Program Argument Desc 8" \
#        "eService Program Argument 9" "eService Program Argument Desc 9" \
#        "eService Program Argument 10" "eService Program Argument Desc 10" \
#        "eService Program Argument 11" "eService Program Argument Desc 11" \
#        "eService Program Argument 12" "eService Program Argument Desc 12" \
#        "eService Program Argument 13" "eService Program Argument Desc 13" \
#        "eService Program Argument 14" "eService Program Argument Desc 14" \
#        "eService Program Argument 15" "eService Program Argument Desc 15" \
#    ]
    set lHeads [list "eService Program Name" "eService Sequence Number" ]
    set lAtt [ lsort -dictionary -index end [ split [ mql print type $sType select attribute dump | ] | ] ]

    set sCmd "mql temp query bus \"$sType\" * * select current description"
    foreach sAttr $lHeads {
        append sCmd " attribute\\\[$sAttr\\\].value"
    }
    foreach sAttr $lAtt {
        if {[lsearch -exact $lHeads $sAttr] == -1} {
            lappend lHeads $sAttr
            append sCmd " attribute\\\[$sAttr\\\].value"
        }
    }
#    set sRecSep [format "%c" 127]
#    append sCmd " dump | recordsep $sRecSep"
    append sCmd " dump |"

    # Append the basic info to the list of information returned
#    set lHeads [ linsert $lAtt 0 Type Name Revision State Description ]
    if { [ catch { eval $sCmd } sMsg ] == 0 } {
        set Object [ split $sMsg \n ]
    } else {
      puts "an error occurred\nthe message is:\n$sMsg"
    }

    set Object [lsort -dictionary $Object]
    set Page_Content [pFormatTriggerObj_html $sType $lHeads $Object]
    if {$bDumpSchema} { pfile_write [file join $Out_Directory Trigger_Manager_Objects.html] $Page_Content }
#puts "sType = $sType"
#puts "lHeads = $lHeads"
#puts "Object = $Object"
    }
}

################################################################################
# pFormatTriggerObj_html
#
#   Parameters : none
#   Return     : none
#
proc pFormatTriggerObj_html { sType lAtt data } {
    global glsTriggerManagerObjects
    set Page_Content "
        <HTML>
        <HEAD>
        <TITLE>$sType</TITLE>
        </HEAD>
        <BODY>
        <CENTER>
        <FONT SIZE=+2><B>$sType</B></FONT>
        </CENTER>"

    regsub -all "\n" $data {<BR>} data
    set sLastTriggerObjName ""

    append Page_Content "<TABLE BORDER=0>\n"

    foreach linedata $data {
        set lineinfo [ split $linedata | ]
        set nCount 0
        set lsBasicInfo [lrange $lineinfo 0 4]
        set lineinfo [lrange $lineinfo 5 end]
        set sObjType  [lindex $lsBasicInfo 0]
        set sObjName  [lindex $lsBasicInfo 1]
        set sObjRev   [lindex $lsBasicInfo 2]
        set sObjState [lindex $lsBasicInfo 3]
        set sObjDesc  [lindex $lsBasicInfo 4]
        if {$sObjName != $sLastTriggerObjName} {
            lappend glsTriggerManagerObjects $sObjName
            append Page_Content "\n<TR><TD COLSPAN=2 ALIGN=LEFT BGCOLOR=#F5F5F5 VALIGN=BOTTOM>"
            append Page_Content "<A NAME=\"[Replace_Space $sObjName]\">"
            append Page_Content "<FONT SIZE=+1>$sObjName</FONT>"
            append Page_Content "</A>"
            append Page_Content "</TD></TR>\n"
        }
        append Page_Content "<TR><TD ALIGN=RIGHT BGCOLOR=#DCDCDC VALIGN=BOTTOM><FONT SIZE=+1>"
        append Page_Content "Id"
        append Page_Content "</FONT></TD>\n"
        append Page_Content "<TD ALIGN=LEFT BGCOLOR=#F5F5F5 VALIGN=BOTTOM><FONT SIZE=+1>"
        append Page_Content "$sObjRev"
        append Page_Content "</FONT></TD></TR>\n"
        if {$sObjState == "Active"} {
            set sColor "#009900"
        } else {
            set sColor "#FF0000"
        }
        append Page_Content "
        <TR>
        <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><FONT SIZE=+1>State</FONT></TD>
        <TD ALIGN=LEFT BGCOLOR=#FFFFFF VALIGN=BOTTOM><FONT COLOR=$sColor SIZE=+1>$sObjState</FONT></TD>
        </TR>
        <TR>
        <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><FONT SIZE=+1>Description</FONT></TD>
        <TD ALIGN=LEFT BGCOLOR=#FFFFFF VALIGN=BOTTOM>$sObjDesc</TD>
        </TR>"
        foreach sAttrName $lAtt sAttrValue $lineinfo {
            incr nCount
            if {$sAttrName == "eService Program Name"} {
                append Page_Content "<TR>
                    <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><B><FONT SIZE=-1>$sAttrName</B></FONT></TD>
                    <TD ALIGN=LEFT><FONT SIZE=-1><A HREF=\"program.html#[Replace_Space $sAttrValue]\">$sAttrValue</FONT></A></TD>
                    </TR>\n"
            } else {
                if {$sAttrValue != ""} {
                    append Page_Content "<TR>
                        <TD ALIGN=RIGHT BGCOLOR=#DCDCDC WIDTH=150><B><FONT SIZE=-1>$sAttrName</B></FONT></TD>
                        <TD ALIGN=LEFT><FONT SIZE=-1>$sAttrValue</FONT></TD>
                        </TR>\n"
                }
            }
        }
        # End foreach
        append Page_Content "<TR><TD COLSPAN=2>&nbsp;</TD></TR>"
        set sLastTriggerObjName $sObjName
    }
    append Page_Content "</TABLE>\n<BR>"

    append Page_Content "
        </BODY>
        </HTML>"

    return $Page_Content

}


################################################################################
# pRemoveElement
#
#   Parameters : list to clear
#   Return     : list with element removed
#
proc pRemoveElement { llist } {

    set bDone 0
    set sRemove "adm*"

    while { $bDone == 0 } {

        set nIndex [ lsearch $llist $sRemove ]
        if { $nIndex == -1 } {
            set bDone 1
        } else {
            set llist [ lreplace $llist $nIndex $nIndex ]
        }
    }

    return $llist
}


proc pProcessFile { lAdmin sFileName sDelimit } {

    global bStatus
    upvar aAdminTemp aAdminTemp

    set sFileData [ split [ pfile_read $sFileName ] \n ]
    set sFileLine1 [split [lindex $sFileData 0] $sDelimit ]
    set sFileMarker [ lindex $sFileLine1 0 ]
    set sInVersion [ lindex $sFileLine1 1 ]
    set sFileType [ lindex $sFileLine1 3 ]
    set nLineStart [ lindex $sFileLine1 5 ]
    if {$bStatus} {puts "Input File,\nVersion: $sInVersion\nData Type to process: $sFileType\nLine Start: $nLineStart"}

    switch $sFileType {
    filter {
        set sData [lrange $sFileData [ expr $nLineStart - 1] end]
        foreach sDataLine $sData {
            set sVal [ lindex [ split $sDataLine ] 2]
            if {$sVal == ""} {continue}
#            set aAdminTemp($sVal) [split [eval $sDataLine] \n]

            set lLH [split [eval $sDataLine] \n]
            if { [ info exists aAdminTemp($sVal) ] == 0 } {
                set aAdminTemp($sVal) $lLH
            } else {
                set lRH $aAdminTemp($sVal)
                set aAdminTemp($sVal) [lindex [pCompareLists $lLH $lRH] 3]
            }
        }
    }
    data {
        set sHeaderRaw [ split [ lindex $sFileData [ expr $nLineStart - 1] ] "\t" ]
        set sHeader [ list ]
        foreach i $sHeaderRaw {
            lappend sHeader [ string trim $i ]
        }
        set sData [ lrange $sFileData $nLineStart end ]
        foreach sDataLine $sData {
            set sDataLine [ split $sDataLine $sDelimit ]
            foreach i $sHeader j $sDataLine {
                if { $j != "" } {
                    # Make sure the file header is in the admin list
                    if { [ lsearch $lAdmin ${i}* ] == -1 } {
                        if { $bStatus } { puts "Header error $i is not a recognized admin type, check developer file ..." }
                    }
                    # Check to see if name really exists
                    if {$i == "table" } {
                        set sRes [mql list $i $j system]
                    } else {
                        set sRes [mql list $i $j]
                    }
                    if {$sRes != ""} {
                        set aAdminTemp($i) [ lappend aAdminTemp($i) $j ]
                    } else {
                        if {$bStatus} {puts "Admin type $i, name $j, does not exist ..."}
                    }
                }
            }
        }
    }
    default {puts "unknown switch type, check input file"}
    } ;# End Switch
}
# End pIncludeFile



proc pMergeArray { sMode lAdminName } {

    upvar aAdmin aAdmin
    upvar aAdminTemp aAdminTemp

    foreach sType $lAdminName {
    
        if {[info exists aAdminTemp($sType)] == 0} {
            continue
        }

        set l1 $aAdmin($sType)
        set l2 $aAdminTemp($sType)

        switch $sMode {
        or {
            set lReturn [ pCompareLists $l1 $l2 ]
            set aAdmin($sType) [lindex $lReturn 3]
        }
        xor {
            set lReturn [ pCompareLists $l1 $l2 ]
            set aAdmin($sType) [lindex $lReturn 0] 
        }
        default {puts "unknown switch type from proc pMergeArray"}
        }
    }
}
# End pMergeArray



proc pCompareLists { lList1 lList2 } {

    set lCommon {}
    set lUnique1 {}
    set lOr $lList1
    foreach i1 $lList1 {
        set nFound [ lsearch $lList2 $i1 ]
        if { $nFound == -1 } {
            lappend lUnique1 $i1
        } else {
            lappend lCommon $i1
            set lList2 [ lreplace $lList2 $nFound $nFound ]
        }
    }
    foreach i2 $lList2 {
        set nFound [ lsearch $lOr $i2 ]
        if {$nFound == -1} {
            lappend lOr $i2
        }
    }
    set lResults [ list $lUnique1 $lCommon $lList2 $lOr ]
    return $lResults
}
# End pCompareLists


proc pCheckExists {sType sName} {

    set sCmd "mql list $sType $sName"
    if {[catch {eval $sCmd} sMsg] == 0} {
        set sExists $sMsg
    } else {
        puts "An error occurred with $sCmd, Error is: $sMsg"
        return "2|$sMsg"
    }
    set sExists $sMsg
    if {$sExists != ""} {
        return "0|"
    } else {
        return "1|"
    }
}
# End pCheckExists



################################################################################
# Generate
#
#   Parameters : none
#   Return     : none
#                This is the main processing routine.
#
proc Generate {} {
    upvar Attribute_Types Attribute_Types
    upvar Attribute_Relationships Attribute_Relationships
    upvar Format_Policies Format_Policies
    upvar Statistic Statistic
    upvar Out_Directory Out_Directory
    upvar Image_Directory Image_Directory
    upvar aTriggerXRef aTriggerXRef
    upvar Location_Store Location_Store
    upvar Location_Site Location_Site
    upvar Store_Policy Store_Policy
    upvar aAdmin aAdmin

    global bStatus

    upvar aInclude aInclude
    upvar aExclude aExclude

    global bExtendedPolicy
    global lExtendedPersonData
    
    # A new array to hold all dirs, need to migrate them in!
    
    upvar aDirs aDirs

    global sDumpSchemaDir
    global sDumpSchemaDirSystem
    global sDumpSchemaDirBusiness
    global sDumpSchemaDirBusinessSource
    global sDumpSchemaDirBusinessPage
    global sDumpSchemaDirSystem
    global sDumpSchemaDirSystemMap
    global sDumpSchemaDirObjects
    global sDumpProperties


    global bDumpSchema
    global bDumpMQL
    global glsPrograms
    global glsTriggerManagerObjects
    set glsPrograms ""
    set glsTriggerManagerObjects ""

    global bStatus
    global nMxVer
    global sHeaderTitle
    
    global glsServer
    global bSuppressAdmReporting
    global bSuppressHidden

    set lExtendedPersonData [ list ]

    set sMqlVersion [mql version]

    if {[string first "V6" $sMqlVersion] >= 0} {
        # Modified below code while fixing 357785 on 12th Aug 08
        set nMxVer "10.9"
        # Modified above code while fixing 357785 on 12th Aug 08
    } else {
        set nMxVer [ join [lrange [split $sMqlVersion "."] 0 1] "."]
	  }
    array set aAdminTemp {}

# Check version, if < 9.5 stop.
    if { $nMxVer < 9.5 } {
        puts "version not supported"
        return
    }


    file mkdir $Out_Directory
    
    set sSchemaPolicy [ file join $Out_Directory Policy ]
    file mkdir $sSchemaPolicy
    set sSchemaPolicyUser [ file join $sSchemaPolicy user ]
    file mkdir $sSchemaPolicyUser
    set sSchemaRule [ file join $Out_Directory Rule ]
    file mkdir $sSchemaRule
    set Image_Directory [ file join $Out_Directory Images ]
    file mkdir $Image_Directory
    set sSchemaProgram [ file join $Out_Directory Programs ]
    file mkdir $sSchemaProgram
    
    if {$bDumpSchema} {
        if {$bStatus} {puts "Start Create Images ..."}
        Create_Images
    }

    # Generate main page
    set Main_Page {
        <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 
            Frameset//EN""http://www.w3.org/TR/html4/loose.dtd">
        <HTML>
        <HEAD>
        <TITLE>Business Model Documentation</TITLE>
        </HEAD>
        <FRAMESET COLS="24%,*">
          <FRAME NAME="Summary" SRC="summary.html">
          <FRAME NAME="Category" SRC="general.html">
        <NOFRAMES>
        <BODY>
        Not available
        </BODY>
        </NOFRAMES>
        </FRAMESET>
        </HTML>
    }
    if {$bDumpSchema} { pfile_write [file join $Out_Directory index.html] $Main_Page }

    # Generate summary page
    set Summary_Page "
        <HTML>
        <HEAD>
        <TITLE>Business Model Documentation</TITLE>
        </HEAD>
        <BODY>
        <A HREF=general.html TARGET=Category><IMG SRC=Images/ematrix_logo.gif BORDER=0 WIDTH=145 HEIGHT=32></A><BR><BR><BR>
    "

    # This is the MASTER list of all admin types to process ANYWHERE.
    # Refer to readme for more details.  Version dependant.
    
    set lAdmin [ list {association complex} {attribute complex} \
        {format complex} {group complex} \
        {person complex} {policy complex} \
        {process complex} {relationship complex} {report simple} \
        {role complex} {rule simple} \
        {type complex} ]

    if {$nMxVer >= 10.7} {
        lappend lAdmin {dimension simple}
    }

    # Initialize the aAdmin array elements and make empty.
    set lAdminName [ list ]
    foreach i $lAdmin {
        set sTypeName [lindex $i 0]
        lappend lAdminName $sTypeName
        set aAdmin($sTypeName) {}
    }

    if { $aInclude(bMode) } {
        if { $bStatus } { puts "Build Data set from include file/s ..." }
        set lFile [ glob -nocomplain [ file join $aInclude(sDir) $aInclude(sMask) ] ]
        foreach sFile $lFile {
            unset aAdminTemp
            array set aAdminTemp {}
            pProcessFile $lAdmin $sFile $aInclude(sDelimit)
            pMergeArray or $lAdminName
        }
    } else {
        if { $bStatus } { puts "Build Data set from database ..." }
        foreach lAdminType $lAdmin {
            set sAdminType [ lindex $lAdminType 0 ]
            if { $sAdminType == "table" } {
                set lValues [lsort -dictionary [split [mql list $sAdminType system] \n]]
            } else {
                set lValues [lsort -dictionary [split [mql list $sAdminType] \n]]
            }
            set aAdmin($sAdminType) $lValues
        }
    }


    if { $aExclude(bMode) } {
        if { $bStatus } { puts "Remove Data defined in exclude file/s ..." }
        set lFile [ glob -nocomplain [ file join $aExclude(sDir) $aExclude(sMask) ] ]
        foreach sFile $lFile {
            unset aAdminTemp
            array set aAdminTemp {}
            pProcessFile $lAdmin $sFile $aExclude(sDelimit)
            pMergeArray xor $lAdminName
        }
    }


    foreach i $lAdminName {
        puts "Process admin type $i ..."
        set aAdmin($i) [ lsort -dictionary $aAdmin($i) ]

        if {$bSuppressAdmReporting} {
            puts "Supress adm admin data ..."
            set aAdmin($i) [pRemoveElement $aAdmin($i)]
        }
    
        if {$bSuppressHidden} {
            puts "Supress Hidden admin data ..."
            foreach sValue $aAdmin($i) {
                set bHidden "FALSE"
                if {$i != "table"} {
                    set bHidden [mql print "$i" $sValue select hidden dump]
                } else {
                    set bHidden [mql print "$i" $sValue system select hidden dump]
                }
                if {$bHidden == "TRUE"} {
                    set nIndex [ lsearch $aAdmin($i) $sValue ]
                    set aAdmin($i) [ lreplace $aAdmin($i) $nIndex $nIndex ]
                }
            }
        }
    } ;# End foreach

    set Category_Order [ list ]
    foreach cat $lAdmin {
        lappend Category_Order [ lindex $cat 0 ]
    }
    # Temp only until the BO are fixed.
    lappend Category_Order "Trigger Manager Objects"
    set Category_Order [ lsort -dictionary $Category_Order ]


    # build a global list of programs for use by the trigger processing routine
    set glsPrograms [split [mql list program *] \n]
#    set glsPrograms $aAdmin(program)
    
    # glsTriggerManagerObjects is set when the trigger manager objects
    Generate_TriggerObjects
#    puts [array get Statistic]

    # Generate Extended data before creating users, will allow for null data.
    Generate_ExtendedPolicy


    foreach category $Category_Order {
        if { $bStatus } { puts "Build Menu $category ..." }
        Generate_Summary_Menu $category
        append Summary_Page "<A HREF=\"[Replace_Space $category]_menu.html\" TARGET=\"Summary\"><IMG SRC=Images/plus.gif BORDER=0 WIDTH=9 HEIGHT=9> $category</A><BR>"
    }

    # Generate the business system data.
    foreach lAdminType $lAdmin {
        set sAdminType [ lindex $lAdminType 0 ]
        set sGenerate [ lindex $lAdminType 1 ]
        if { [llength $aAdmin($sAdminType)] == 0 } {
            if { $bStatus } { puts "No Data for $sAdminType ..." }
        } else {
            if { $bStatus } { puts "Start Processing $sAdminType ..." }
            if { $sGenerate == "complex" } {
                set sRet [Generate_$sAdminType]
            } else {
                set sRet [Generate_Simple $sAdminType]
            }
        }
    }

    # Generate general page
    set General_Content "
        <HTML>
        <HEAD>
        <TITLE>Business Model Documentation</TITLE>
        </HEAD>
        <BODY>"

    append General_Content "
        <DIV ALIGN=center><BR>
        <FONT SIZE=+1><B>$sHeaderTitle</FONT></B><BR><BR>
        <FONT SIZE=-1>Date-Time Generated<BR>(YYYY MM DD - HH MM SS)<BR>[clock format [clock seconds] -format "%Y %m %d% - %H %M %S"]</FONT><BR><BR>
        <TABLE BORDER=0 CELLSPACING=3>
        <TR>
        <TD ALIGN=RIGHT BGCOLOR=#F5F5F5 WIDTH=150><FONT SIZE=+1>Administration type</FONT></TD>
        <TD ALIGN=LEFT BGCOLOR=#F5F5F5><FONT SIZE=+1>Quantity</FONT></TD>
        </TR>"

    foreach type [lsort -dictionary [array names Statistic]] {
        if { $type != "" } {
            append General_Content "<TR>
                  <TD ALIGN=RIGHT BGCOLOR=#DCDCDC><B><FONT SIZE=-1>$type</B></FONT></TD>
                  <TD ALIGN=CENTER><FONT SIZE=-1>$Statistic($type)</FONT></TD>
                </TR>"
        }
    }

    append General_Content "
        </TABLE>
        <BR>
        <FONT SIZE=-1>Use menu on the left frame to navigate through administrative objects.
        <BR><BR><BR>Schema Dumper, Version 2011 Build 2010.08.20<BR><BR>
        [mql version]<BR>
        © Copyright 2010 by ENOVIA Inc.<BR>
        All rights reserved.<BR><BR>
        <A HREF=http://www.matrixone.com><IMG SRC=Images/matrixone_logo.gif BORDER=0><BR>
        <A HREF=http://www.matrixone.com>www.matrixone.com</a>
        </FONT>
        </DIV>
        <BR><BR>
        </BODY>
        </HTML>"

    if {$bDumpSchema} { pfile_write [file join $Out_Directory general.html] $General_Content }


    # Summary page
    append Summary_Page "
        </BODY>
        </HTML>
    "
    if {$bDumpSchema} { pfile_write [file join $Out_Directory summary.html] $Summary_Page }
    
    return 0
}


################################################################################
# Create_Image_File
#   Create_Image_File
#
#   Parameters :
#       path
#       binary_data
#   Return     : none
#
proc Create_Image_File { path binary_data } {

    set Image_File [open $path w+]
    fconfigure $Image_File -translation binary
    foreach data $binary_data {
        if { $data == "00" } {
          set data_f \000
        } elseif { $data == "0A" } {
          set data_f \012
        } else {
          scan $data %x data_i
          set data_f [format %c $data_i]
        }

    puts -nonewline $Image_File $data_f
    }
    close $Image_File

    return
}

################################################################################
# Create_Images
#   Create Images
#
#   Parameters : none
#   Return     : none
#
proc Create_Images {} {
    upvar Image_Directory Image_Directory

    set ematrix_logo {ematrix_logo.gif {47 49 46 38 39 61 91 00 20 00 D5 00 00 C5 00 40 C9 10 4C CC 20 58 D0 30 64 D4 40 70 D7 50 7C DB 60 88 DE 70 94 E2 7F 9F E6 8F AB E9 9F B7 ED AF C3 F0 BF CF F4 CF DB F8 DF E7 FB EF F3 FF FF FF EF EF EF DF DF DF CF CF CF BF BF BF AF AF AF 9F 9F 9F 8F 8F 8F 7F 7F 7F 70 70 70 60 60 60 50 50 50 40 40 40 30 30 30 20 20 20 10 10 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 2C 00 00 00 00 91 00 20 00 00 06 FF 40 88 70 48 2C 1A 8F C8 A4 72 C9 6C 3A 9F D0 A8 74 4A AD 5A AF D8 AC 76 CB ED 7A BF E0 B0 78 4C 2E 9B 97 18 90 7A CD 06 5D 8C 9A B6 9C 72 6E CA 41 98 7A 33 7D 5F 6F 8C 1F 7D 6B 74 57 1C 72 1C 54 77 79 7A 68 82 6B 45 13 8E 6A 84 56 86 6D 88 53 8A 8C 8D 92 15 44 7C 8E 94 55 96 6C 98 52 9A 9B 49 A0 82 1A 44 1D 92 20 A2 54 A4 6B A6 51 14 B8 B9 14 12 65 0D 09 08 05 04 07 08 0A 0D 47 AB 7D 1E 43 12 B0 B1 46 14 17 18 D2 D3 18 15 BC 43 B9 AF 6D 1D B9 12 13 BA B8 D7 16 D4 10 E0 E1 E6 E1 43 DF E6 11 4E 0A 02 00 F1 F2 F2 02 08 0F 9F CD 13 42 16 CD 94 12 1A 81 1C 79 B0 20 A4 19 1E 5A 6A 30 50 F0 D0 06 82 A2 0C 77 3A 08 89 24 C7 43 BB 25 0D 06 CC DB 38 4F 80 31 21 C8 FA BC 81 B0 A1 9F 90 0A 01 9B B5 32 88 01 21 88 92 72 1C CA C9 E3 12 4F 04 6D 6C 3E E8 C3 18 80 A3 CF FF 78 01 3E 86 04 C1 90 8D 44 08 29 D5 14 6D 43 27 42 D2 7C 2C 6B DE 91 D9 26 4F 84 A5 6C 60 B6 21 C8 44 E3 C6 00 06 10 1C 80 B7 91 00 C8 3B 10 DB 44 A8 20 27 2D 53 08 17 E4 7C B8 80 6B E8 05 0E 78 9F 82 F8 80 97 83 05 A9 31 51 4D D0 8B B6 89 02 8E 03 EE 09 79 E0 75 1E 03 08 43 29 3C B5 E0 56 CD 86 C8 10 FE F6 C5 CB 55 88 CB 45 10 5C DA 02 0C 02 2F 43 AA 6C 40 F3 93 64 4B 49 63 79 08 18 C8 96 8D 80 A3 01 C8 77 28 C4 C9 8A 15 C4 B8 DC 4A 24 50 A8 BC 06 B4 68 22 35 E7 12 E1 85 4A 08 F1 36 16 9D FC 9C 4E 0F F7 1C B6 39 E5 44 C0 AC EE 82 06 0E 84 53 0F 39 3E FE CE C8 22 CD 3D F7 D1 F9 84 BA 7B EB 6F C3 AB 41 C4 BD 42 6F 49 C6 0F 21 97 8B 24 7D B9 3E AD 2D E1 1E 75 F0 B1 41 C7 6E 22 15 38 08 04 CF B5 A1 57 7E 97 EC 17 E1 11 E9 39 25 48 67 4C F8 94 C0 6C 1C 76 F8 FF 18 66 D8 F5 C1 4B 64 CC DC 71 19 05 11 7C 56 DE 84 EA B1 88 DE 4C AE 48 B2 13 13 05 70 54 80 13 DC 85 77 54 64 76 C5 58 D5 8A 39 51 42 9E 11 CD 21 28 C8 07 D7 2C C1 80 4F 05 38 00 C1 03 0A F4 B4 11 02 0A 4E 22 84 91 6C 8C C4 A3 79 43 C4 05 63 8B 7D B4 A4 1F 85 5F AE 06 4B 07 17 2D 71 C0 80 1B 25 56 A5 33 10 84 D8 C6 35 91 99 B9 0D 07 F7 25 04 A4 22 43 BE F8 23 45 DB 34 D8 4A 13 06 B0 19 8F 9B 6F 52 A2 D7 51 89 5A 68 D0 1A 83 66 E6 88 98 2E 12 A1 88 A3 6D E8 53 13 68 4B 2C 40 D6 74 01 D8 33 04 77 10 60 E9 C6 A8 C0 0D 76 24 4E 6B 28 33 84 A9 C5 F5 69 E9 4C AC 16 27 84 04 84 61 D8 A9 01 AF 01 20 40 01 0A 28 36 84 66 9B 71 30 23 05 C5 72 90 24 B1 9B ED B4 5D AD 1D 64 20 41 05 C9 72 20 8A 6E E0 A9 D1 01 67 19 24 9B 01 12 D5 6E 50 6D A4 71 86 9B CA B9 E8 A6 AB 0F EE BA EC B6 EB EE BB F0 C6 2B EF BC 57 04 01 00 3B}}
    set plus {plus.gif {47 49 46 38 39 61 09 00 09 00 F7 00 00 00 00 00 84 84 84 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF 2C 00 00 00 00 09 00 09 00 00 08 26 00 03 08 1C 48 50 80 C1 83 02 04 1E 04 70 50 A1 41 86 06 15 02 98 38 31 61 80 85 0D 2F 3E CC 88 30 23 41 82 01 01 00 3B}}
    set moins {moins.gif {47 49 46 38 39 61 09 00 09 00 F7 00 00 00 00 00 84 84 84 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF 2C 00 00 00 00 09 00 09 00 00 08 22 00 03 08 1C 48 50 80 C1 83 02 04 22 3C A8 70 61 C2 00 02 00 48 94 F8 D0 61 45 87 0D 17 12 DC 18 20 20 00 3B}}
    set matrix_type {matrix_type.gif {47 49 46 38 39 61 10 00 10 00 F7 00 00 00 00 00 7B 7B 7B BD BD BD FF FF 00 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF 2C 00 00 00 00 10 00 10 00 00 08 67 00 09 08 1C 48 B0 A0 40 00 08 0D 1A 04 30 80 C0 00 84 10 21 12 04 E0 B0 62 C3 8B 14 07 32 B4 C8 31 E3 41 8B 01 42 8A 14 49 71 63 C3 00 0D 2B 3A 14 50 12 A4 42 96 04 4C 12 08 A0 32 E5 C3 98 2A 69 0E 0C 40 11 66 44 00 3A 1B 32 04 00 B3 20 4A 8D 0E 13 12 D4 79 50 A8 C7 9D 02 06 B0 94 A8 30 26 D5 AA 58 09 06 04 00 3B}}
    set matrixone_logo {matrixone_logo.gif {47 49 46 38 39 61 9E 00 3A 00 E6 00 00 FE F8 F9 FD F3 F5 FE F9 FA F8 DA E1 F9 DF E5 FB E9 ED FC EF F2 CC 00 33 CC 01 34 CC 02 35 CD 05 37 CD 06 38 CD 07 39 CE 08 39 CE 09 3A CE 0C 3D CF 10 40 D0 12 41 D0 15 44 D0 16 45 D1 17 45 D1 18 46 D2 1C 49 D2 1D 4A D2 20 4D D3 25 51 D4 26 51 D4 29 54 D6 30 59 D7 39 61 D8 3A 61 D9 40 66 DA 48 6D DB 4B 6F DC 50 73 DD 56 78 DE 58 79 DF 5E 7E DF 60 80 E0 65 84 E1 69 87 E1 6A 88 E2 6C 89 E2 70 8D E3 72 8E E5 7B 95 E5 7C 96 E5 7F 99 E6 83 9C E6 84 9D E8 8D A4 E9 8F A5 E9 93 A9 EA 95 AA EA 96 AB EB 9A AE EC 9F B2 EC A1 B4 ED A7 B9 EE A9 BA EF AF BF F0 B4 C3 F1 B7 C5 F2 BF CC F4 C6 D1 F7 D6 DE FB EA EE FE FA FB F3 C5 D1 F5 CF D9 F7 D9 E1 F9 E2 E8 F9 E3 E9 FA E7 EC FA E8 ED FB ED F1 FD F6 F8 FD F7 F9 FE FC FD FF FD FD FF FE FE FF FF FF EF EF EF DF DF DF CF CF CF BF BF BF AF AF AF 9F 9F 9F 8F 8F 8F 7F 7F 7F 70 70 70 60 60 60 50 50 50 40 40 40 30 30 30 20 20 20 10 10 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 2C 00 00 00 00 9E 00 3A 00 00 07 FF 80 51 82 83 84 85 86 87 88 89 8A 8B 8C 8D 8E 8F 90 91 92 93 94 95 96 97 98 99 9A 9B 9C 9D 9E 9F A0 A1 A2 A3 A4 A5 82 06 3C 2F 1F 18 07 AD AE AF 07 18 1F 26 2F 3C 45 A6 B8 B9 91 3C 22 B0 BE BF B0 1F 2B 38 04 BA C6 C7 51 3F AC C0 CC CD B1 26 38 06 C8 D3 A1 2B CD 10 1F 2F 33 3F 3F B7 A7 DC 3F 33 2F 26 1F 10 BE 1C 33 C5 D4 EB 98 D6 BF 18 2B DE 91 06 3F 2F 22 CB AD E8 EA EC FC 8F 3F EF 38 36 11 C0 61 02 9F 88 80 FD 12 2A EA 05 6B 45 28 02 33 38 B4 82 B0 62 9F C2 8B 51 7C CD 28 65 00 C7 87 56 26 7E 60 54 58 04 96 08 5D 10 59 7D 10 39 92 DD BF 57 16 73 FD 30 71 60 65 CB 75 AF 4C AC 23 F0 02 1B CB 9B C6 24 B6 E2 C1 AF A3 AC 98 40 49 CD 70 25 2D 21 0E 0C 26 9A 26 25 65 C0 DC 81 91 38 D0 4D 2D F5 A2 D5 4D 55 3F B7 7E 32 C0 0A 69 42 03 2F 56 48 15 DB E9 DF 46 A0 04 FF 56 84 D5 94 A5 AE DD BA 57 0A 61 B9 7B 57 D7 0A 0E 96 3A 8A F8 18 2B 9B 3C 4D E1 D6 62 0A C3 B8 71 63 29 83 A6 38 9E 2C E9 4A 97 CB 97 A9 44 FA 40 74 52 4F 66 1F CC 06 E6 34 D9 71 5E 41 58 4A 37 96 94 65 72 95 79 22 14 33 32 20 F4 5A E7 91 AA 19 6F 19 C4 25 77 18 D6 AE 25 F1 8C 54 DB 19 84 C3 0A 7D 83 19 E4 FB 37 21 29 55 A2 4B 87 4C A8 B5 E3 D7 89 A8 44 D7 4C A8 88 EC 44 5D 61 61 78 61 EF 5C 22 70 73 09 A1 4F 7F A9 B9 66 2B CD 07 5D F9 92 DB 8B 95 28 5D 9A E7 77 3C C5 4B E3 CB 93 C1 E7 18 18 53 E0 37 19 16 56 B9 A2 D3 20 38 F8 92 CA 2B 1F CC 90 60 2C B7 45 61 80 09 13 1E 00 81 09 A2 49 D2 5C 16 51 68 11 5F 14 5B 34 C7 98 15 FB E5 96 22 63 FE FD B7 E2 6F D6 FD 97 9A 63 5C BC E4 0A 04 8A D1 94 53 78 CE 74 56 44 86 AF 40 C0 9E 87 8E B5 C8 62 14 F4 31 06 46 FF 69 51 54 31 D9 17 5A F4 E6 18 80 BE BD 38 19 95 AB 45 21 65 7D 52 2C 05 A1 21 3C 04 C3 63 33 1F 58 98 61 39 41 76 F8 C8 95 5B 86 21 A0 6E 4C 5A 86 19 17 83 94 E8 98 20 31 32 86 5D 9E 8D 81 D1 C5 17 58 32 26 88 14 49 96 06 86 66 63 1E F0 82 21 36 B6 92 0D 2C 14 E9 F8 4A 14 92 1E C0 81 34 17 E6 D4 DD 24 57 5E 51 A4 63 6F 66 39 08 74 55 64 61 E7 9D 51 F0 B9 67 69 A7 09 F2 E2 20 54 2C 59 DA 7D 51 24 EA 50 21 8D D6 94 A8 37 0C B9 12 C5 84 B4 90 57 29 06 DD 21 04 C9 95 52 E4 B6 1C 93 51 4C B1 45 A1 B9 E1 19 5C AA 93 ED 46 C8 AB 83 CC E8 98 16 0C C2 02 58 21 5E BA F2 E8 A4 82 24 9A 91 33 BE 12 82 83 B1 8E 5C 69 60 69 74 C6 69 62 96 AA 4A 0B 6A 21 D8 0A 62 64 63 5F 50 47 80 2F 73 E1 D3 0A 79 B0 0C 62 2E BA AE CC F5 02 BB 8C B8 AB AD 69 51 30 29 6B 63 5B 5C 31 05 FF 9F F6 36 46 6B BD D7 52 26 88 88 AA 75 31 08 61 37 B2 44 40 AF AE F0 54 70 B9 05 C3 F2 C2 7A E8 C9 F6 01 C3 8A B8 2B 59 69 90 95 46 C5 64 5E 0C 02 AD 73 7C 7E 51 D7 A9 7A E2 EB B1 A7 BE 71 9B CC 2F 10 14 E7 8A 43 E6 B2 3C 29 CA 97 0A 92 0A 79 0B 1F 42 C0 71 ED 4E A9 EF 64 74 46 4C 59 69 5D 64 F1 B3 73 48 93 3D ED 20 AF C6 3A E0 BE 61 9C D6 20 C2 55 47 5D 6B C1 3F 06 B9 0A 2C 6F 19 D2 93 9A CC 79 1D C5 C3 71 0B C2 64 9B 23 4E 31 F1 94 6B BB 3A 19 A1 01 BA ED 18 77 38 00 69 52 53 76 47 5D 79 33 B7 1E 52 D5 B7 8B B8 
DB EC E3 86 53 26 05 D1 8C 7D 81 FA 69 55 9C FD 22 76 6C 5F 39 99 D2 84 83 E1 2F 86 BF D8 64 F0 CA 77 93 1B 05 01 95 8A 3B E4 20 34 2D 5A 0A 74 75 59 C1 9D 22 53 48 57 C5 F2 9F CC 15 0E D6 3C 00 0E C9 0F 38 68 F3 C3 77 60 B6 62 3D 5B 94 A0 45 73 BE 3F 25 D5 04 7E 28 3F CC 3C 52 CA E7 87 F2 02 07 E3 4F 63 63 E7 ED 7B 02 3C 06 F1 1B 33 77 2C F5 8B 92 3E 04 2F E0 1E 2E 48 76 95 FE F9 EF 23 21 41 C6 BF 7C 67 40 F4 7D 04 03 E9 D0 05 01 0B D8 C0 51 FC 80 21 07 11 20 27 12 05 81 0A 9A 22 2E 56 11 41 04 C7 12 BC 03 2C C8 83 A6 F0 88 2B E0 C1 03 0D 46 E2 29 BF F8 1E 0A 39 01 91 E2 40 65 1B 2E 44 44 11 56 20 B0 57 F4 6D 86 28 89 88 2F B0 41 0B 1C 80 83 10 04 E0 86 38 D0 C4 8C 1F 02 F1 18 1D 29 08 C2 A6 98 8F E1 3D D1 18 03 F9 0B 15 81 21 02 2B 5E 71 1D 45 48 C5 60 7A 78 8E 6C 54 E8 8B 68 4C A3 1A D7 C8 C6 36 CE 30 10 00 3B}}
    set image_changename {changename.gif {47 49 46 38 39 61 10 00 50 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 50 00 40 08 c0 00 ff 09 1c 48 b0 a0 c1 83 08 ff 01 58 c8 30 21 c1 86 07 21 0a 04 e0 50 a1 c4 8a 13 1d 32 bc 68 90 22 46 8f 0f 35 2e cc a8 11 e3 c4 8d 20 0b a6 b4 58 71 a4 c2 92 2f 3d ae 3c b9 d1 24 47 93 38 73 b6 44 29 b2 66 42 94 33 43 0e 0c 3a 34 e6 4f 9d 27 5b 76 2c 49 d1 25 42 88 37 69 02 8d c8 f3 68 d1 a3 4d 77 fa 54 09 d4 a9 ca a5 4f ab 22 1d 4b 95 e4 d3 98 44 87 46 b5 1a 76 2b 55 b7 60 6d 8a fd d8 73 6d 46 b8 64 bb a6 55 bb d7 2e df b9 64 f9 9a 7d eb 77 2f d7 91 78 5f 1a 55 dc 11 a4 d7 87 80 bf e2 9c 3a b9 ee e3 af 89 cf fe 8c 6c b1 6b c4 cf 65 af 82 16 da 18 72 dd c0 64 03 02 00 3b}}
    set image_changeowner {changeowner.gif {47 49 46 38 39 61 10 00 57 00 f7 00 00 05 05 05 fb fb fb 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 00 00 00 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 57 00 40 08 cc 00 ff 09 1c 48 b0 a0 41 00 04 11 1a 1c 08 a0 a1 c3 85 0c 05 3e 84 48 71 a1 c3 89 14 15 56 64 78 51 a3 c5 8e 1f 3b 36 84 38 92 63 45 8f 1b 11 aa 44 59 50 e4 46 89 2c 23 b6 3c 59 32 a6 4c 95 12 43 62 7c 69 b3 64 ce 97 40 83 72 bc 98 52 a1 cd a1 47 7f 02 4d da d2 27 4d a6 ff 5c 92 3c 28 b4 28 d1 8c 0f af 1e d4 e8 34 61 55 af 19 a3 ee dc aa 15 ec 4c 8b 54 b1 76 fd ca b6 6d 54 b3 3a d7 ba 9d 98 54 ea d2 a7 63 9b 96 4d ab 34 a4 d0 bd 5b 97 82 0c 1b 14 70 42 8f 72 df 9e 0d 6c 52 2d 54 b1 7d a9 ae b4 ca 94 6e 62 a3 8a 63 8a cc cb 37 6e dd c1 53 65 92 04 8d 16 a7 e0 cf 86 45 3b 26 3d b7 33 dc c8 87 53 bb ad 18 10 00 3b}}
    set image_changepolicy {changepolicy.gif {47 49 46 38 39 61 10 00 52 00 f7 00 00 05 05 05 fb fb fb 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 00 00 00 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 52 00 40 08 c3 00 ff 09 1c 48 b0 a0 41 00 08 0b 02 20 98 10 a1 c3 85 06 19 3a 8c 28 f0 21 44 8a 03 17 6a bc 18 d1 e2 c3 8e 0c 31 fe f3 48 91 63 45 91 28 15 26 4c c9 d1 64 45 8f 2b 4b 5a 2c 79 50 e4 c4 91 31 55 7e c4 a8 71 a4 4c 98 3c 67 a6 1c 2a 31 27 d1 9f 2e 15 86 ac c9 94 66 c6 a3 41 49 da 84 98 b4 68 d5 a7 3e a9 b2 9c ba 13 a9 d1 9f 36 a1 0e 75 79 55 2c d4 b2 32 51 0a ad 9a b4 ed c5 b2 52 c7 76 dc d8 75 eb 41 98 68 8f c6 05 89 35 2a dc af 4d b5 ce dd 6b b6 e8 49 bf 80 fb b2 9c 58 17 6b 4f 9f 73 33 b2 15 ea 74 2c 65 bb 5e e1 e2 4c cc 37 f3 60 c2 87 95 46 56 2c 7a e9 5d 89 5c f3 16 a6 18 10 00 3b}}
    set image_changetype {changetype.gif {47 49 46 38 39 61 10 00 4d 00 f7 00 00 05 05 05 fb fb fb 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 00 00 00 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 4d 00 40 08 bb 00 ff 09 1c 48 b0 a0 41 00 08 13 1a 24 08 60 61 43 86 0f 17 4a 9c 78 50 61 c2 88 0c 29 16 6c 78 d1 a1 c7 89 1d 35 8a 84 18 52 63 49 92 17 31 56 3c e9 30 22 c2 91 2a 37 a6 94 18 33 e6 c8 9b 20 5f fe b3 89 13 e5 cc 95 30 75 0e 54 59 93 66 cf 9d 3a 79 0a 54 7a 70 e9 4e a7 2b 15 e6 64 29 93 2a c8 96 29 85 ca cc 48 13 a3 d6 a3 60 c3 22 85 6a 94 23 53 a4 5f b1 8a f4 4a d6 a7 d5 b3 2d 4d 86 e4 69 93 28 ce ac 69 db ea 1d 0a 77 eb d3 ab 66 e5 e6 25 b9 74 f0 43 8e 7b d1 66 5d 4b 71 f1 54 a9 46 87 36 fe 59 f6 ef da c1 85 ad 4a 16 ec 58 ec 5e ba 4d bb 6a f6 3c 31 20 00 3b}}
    set image_changevault {changevault.gif {47 49 46 38 39 61 10 00 52 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 52 00 40 08 bc 00 ff 09 1c 48 b0 20 41 00 08 13 22 34 78 50 21 00 86 03 1d 3e 84 d8 70 22 c4 87 18 2d 32 94 98 70 e3 41 8a ff 24 5e 34 a8 11 a4 c9 93 02 39 2e a4 28 d2 23 ca 90 2f 23 ae ec b8 d1 21 48 8c 30 6b 72 64 69 33 a6 4f 93 25 5d 16 0c 3a 32 26 d1 88 21 69 92 4c 7a 54 a6 52 a0 13 9b a6 7c ea 12 67 ce 9b 37 7b 5e d4 9a 55 aa d4 9f 29 97 82 1d 4b d6 a7 c6 a3 2a 8d ea 6c 89 d2 2b 57 92 6f 87 1a 8d fb d1 ea 49 aa 32 c7 ae f4 48 77 6a 59 a8 51 bb e2 fd f8 52 21 53 a2 81 03 d7 cc bb 76 af d0 bb 7d 1f c3 35 cc f2 b0 5a 9e 94 87 a6 15 2b 77 31 d2 a2 84 e1 36 14 fc f7 67 40 00 3b}}
    set image_checkin {checkin.gif {47 49 46 38 39 61 10 00 36 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 36 00 40 08 87 00 ff 09 1c 48 b0 a0 c1 7f 00 12 2a 3c 38 10 00 41 87 0c 23 32 74 48 11 62 41 85 18 13 46 cc 68 51 a2 c7 86 0f 3f 6a ec 78 10 a3 47 8e 13 0d 92 fc c8 b2 25 c8 8d 19 4b 56 34 b9 b1 e1 4a 84 1c 35 d6 7c 09 53 e0 cd 87 0b 25 fe 74 a9 b2 28 d1 a3 48 93 da a4 99 b2 25 4a a7 32 71 32 2d 19 52 28 ce 89 39 6f 6a 15 6a 71 a8 d4 a0 4a 81 42 f4 fa 94 25 d9 98 2a b3 52 35 9a b6 ea 5a b7 17 3b ea c4 3a 37 6c cb 80 00 3b}}
    set image_checkmark {checkmark.gif {47 49 46 38 39 61 09 00 09 00 91 00 00 00 00 00 ff ff ff ff ff ff 00 00 00 21 f9 04 01 00 00 02 00 2c 00 00 00 00 09 00 09 00 00 02 11 94 8f a9 07 a0 ed 44 93 d0 c0 6b 6f a4 15 75 53 00 00 3b}}
    set image_checkout {checkout.gif {47 49 46 38 39 61 10 00 40 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 40 00 40 08 95 00 ff 09 1c 48 b0 a0 c1 83 08 0d 02 48 28 70 e1 40 87 05 01 48 9c 38 91 e1 3f 89 0d 19 42 d4 a8 d0 a2 c7 87 1f 43 12 84 88 31 e1 c6 8d 07 29 8a 5c c9 b2 65 4a 8a 15 4d c2 d4 38 53 a6 4a 9a 25 2d 62 44 e9 f2 61 4c 93 17 2f f2 1c 59 33 22 cc 9f 11 3b 22 3c da b3 a9 d3 a7 49 41 be 64 1a 72 a8 cf 9b 4b 8b a6 5c 89 75 e9 48 9c 48 95 66 e4 98 d3 e8 d1 a1 68 69 4a cd da d5 69 4c ab 0d b5 ea 04 5b f6 2a d5 a8 78 8d 7e f5 9a 97 a8 5f 9b 70 a1 16 0c 08 00 3b}}
    set image_create {create.gif {47 49 46 38 39 61 10 00 2c 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 2c 00 40 08 71 00 ff 09 1c 48 b0 a0 41 00 ff 10 02 40 68 70 e0 c2 87 0c 1b 26 9c b8 50 a2 c5 8b 18 33 1e 84 f8 50 63 47 8b 11 27 36 0c 29 90 a4 46 90 0c 4d 16 84 88 51 a5 44 85 22 2f 56 8c f9 f2 23 4a 96 23 0f de b4 79 b2 a7 cf 9f 32 67 ba 2c c9 51 26 41 97 1c 79 b6 0c 8a f3 65 42 a5 40 1d 0a 65 0a f5 68 cf a4 46 1d d6 b4 ea 74 e5 56 a9 54 a3 8a 0d 08 00 3b}}
    set image_delete {delete.gif {47 49 46 38 39 61 10 00 31 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 31 00 40 08 78 00 ff 09 1c 48 b0 a0 c1 83 08 05 02 20 b8 30 21 80 87 10 13 fe 8b 38 11 61 43 86 12 33 6a 74 f8 50 e1 46 89 10 43 76 fc c8 51 e4 45 92 28 53 1e 34 69 d1 e4 49 83 14 5f 82 54 d9 32 64 49 8a 2b 61 d2 dc c9 b3 a7 4f 85 0d 65 62 5c 38 f2 e6 4d 9b 0e 51 8e 14 3a 90 e8 44 a6 4d 71 16 74 59 14 a3 4e 90 41 67 12 85 0a b4 ea 4a a9 30 4f 42 95 c9 94 aa c5 ab 2a 03 02 00 3b}}
    set image_demote {demote.gif {47 49 46 38 39 61 10 00 32 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 32 00 40 08 7e 00 ff 09 1c 48 b0 a0 c1 7f 00 12 02 38 48 70 e1 40 87 0c 11 46 34 98 50 20 c4 82 15 1f 4e dc 78 30 e3 45 8a 1c 43 52 54 98 31 22 49 93 24 15 8a e4 b8 b0 e5 c7 87 29 4b 32 3c 39 31 66 cd 94 37 69 ce 6c 58 53 a2 cc 91 3f 31 82 ec 38 74 a5 51 94 0e 5f 36 c4 69 92 67 c7 98 4a 8f 5a 64 ba 53 63 ce a8 55 67 52 7d aa 93 a8 48 9b 52 b9 5a bc 1a 34 2c 58 af 4e 8b 5a 05 ba 35 ac c8 80 00 3b}}
    set image_disable {disable.gif {47 49 46 38 39 61 10 00 31 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 31 00 40 08 82 00 ff 09 1c 48 b0 a0 c1 7f 00 12 2a 3c 38 50 61 42 86 0d 11 4a 84 68 10 00 43 8b 05 31 52 dc c8 91 a0 c3 8f 07 35 76 14 f8 f0 e1 48 8a 1f 17 9e 44 69 52 e4 46 97 2b 49 a6 34 79 11 24 47 95 17 11 5a 84 a9 53 a7 43 88 29 81 56 8c 49 b4 68 46 8c 3c 23 ee 4c da 10 e7 d1 99 21 a3 b2 64 1a b1 ea d3 a0 23 a9 62 cd f9 d3 68 c6 9e 54 c1 f2 2c 69 33 a7 d5 90 4e 2b 8a 64 0a 33 e9 4c b7 43 8b 06 04 00 3b}}
    set image_enable {enable.gif {47 49 46 38 39 61 10 00 31 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 31 00 40 08 77 00 ff 09 1c 48 b0 a0 c1 83 07 01 28 5c b8 30 21 c2 87 ff 18 2a 44 08 20 e2 c4 88 10 33 6a 7c 28 b1 22 47 86 19 2b 8a 0c 29 91 a2 41 8f 1b 53 6e 6c 88 31 25 4a 95 05 3b b2 a4 58 52 e3 4c 87 30 6d ca cc c9 b3 a7 cf 9c 17 5f 9e c4 78 f1 63 d1 98 32 85 0a 54 da d2 a8 4d 82 4c 93 32 35 69 f4 e6 50 90 2e 21 76 d4 5a 93 ea 52 9a 50 a7 7a 44 29 76 e7 cf 94 01 01 00 3b}}
    set image_execute {execute.gif {47 49 46 38 39 61 10 00 30 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 30 00 40 08 7c 00 ff 09 1c 48 b0 a0 41 00 08 13 1a 24 98 50 e1 42 81 0d 11 3e 84 c8 f0 21 80 7f 0e 2f 4e dc c8 30 a2 c4 89 1a 39 42 fc 18 72 21 c9 92 15 0b a2 14 09 92 e4 c6 92 2b 41 be 8c 38 73 60 4c 96 07 69 72 74 88 b3 a5 c7 9e 40 83 ee d4 78 93 e2 c5 8f 3e 8b 7a 44 6a b2 e7 4f 96 45 47 36 14 6a 31 65 52 91 2e 65 1e 8d 8a 91 a7 56 a6 26 c1 36 b5 69 11 e6 4d a2 64 c3 3e a5 0a 34 20 00 3b}}
    set image_freeze {freeze.gif {47 49 46 38 39 61 10 00 2e 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 2e 00 40 08 77 00 ff 09 1c 48 b0 a0 c1 7f 00 00 08 54 78 70 61 c2 87 0d 07 3e 64 18 91 22 c2 86 13 27 46 dc 88 11 22 c7 84 0b 37 2a 1c 69 91 a3 c9 93 28 53 16 1c 89 b0 e4 4a 89 2e 09 82 0c 59 f1 e2 cc 8a 0c 63 ca f4 88 53 e3 41 92 3a 25 1a 0c aa b2 a8 51 94 1e 89 66 24 aa 32 a9 48 87 4c 53 3a ed c9 f3 e8 ce 9c 22 33 3e 45 aa b5 a6 d0 9f 51 69 52 d4 b9 f4 a6 55 94 01 01 00 3b}}
    set image_fromconnect {fromconnect.gif {47 49 46 38 39 61 10 00 52 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 52 00 40 08 b3 00 ff 09 1c 48 b0 a0 c1 83 08 05 02 f8 b7 10 c0 c2 84 0e 23 3e 44 38 91 61 c2 8b 18 33 56 c4 58 71 63 c6 8f 1a 09 7a 2c 28 91 a3 c4 91 03 4f a2 54 28 92 a2 c1 95 0c 4f 82 0c 99 92 a2 4a 98 20 6f c2 ec 68 92 e5 c5 92 3f 67 92 fc 29 93 a8 43 93 40 5f 2a b5 99 f4 e3 ce a2 4c 23 1a 95 3a 15 29 55 a5 57 5d 0e 15 ca f5 e5 cd a0 39 27 3e 6d da 55 e4 51 8b 10 a1 d2 8c 7a 96 ed ce 96 69 c9 6e 75 aa b6 6c ca ba 73 d1 c6 5d d9 56 ef 52 b8 5e cd 56 b5 7b 50 25 c7 b0 72 cd 26 ae c9 78 ef e1 c6 85 f1 02 d6 28 19 32 ca be 60 c5 ba c5 4c f8 62 40 00 3b}}
    set image_fromdisconnect {fromdisconnect.gif {47 49 46 38 39 61 10 00 63 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 63 00 40 08 d7 00 ff 09 1c 48 b0 a0 c1 7f 00 0e 2a 04 c0 50 60 42 85 08 19 4a 84 18 51 e2 43 88 16 29 22 8c b8 11 e3 44 8c 06 2f 1e 14 a9 51 24 49 8d 28 53 aa 1c 68 b1 a1 ca 93 04 5b c2 64 d9 92 a2 cc 91 09 6f 8e 0c 69 b3 e6 4a 9b 31 17 ca 9c f9 73 28 51 8e 0e 7f f6 cc e8 91 e9 c2 a0 20 95 a6 34 d9 93 a5 54 8f 48 9f 5a c5 09 15 a7 ce a9 4b 3f 0a 75 ea 55 ec d8 a3 15 cd 06 55 cb b3 20 da ab 70 b5 26 2d 4b 36 6e c7 b9 4d df ba 3c 9a 33 eb d9 92 3e e5 a2 fc 3a 38 ac cb b3 87 77 6e cd 5b b2 2b dd b7 2f 1d 97 05 ec 77 67 43 c8 78 63 e6 0c 6c 97 b0 db b6 a0 17 bb 1d 6a 57 73 dd d0 86 f9 72 0e 8d f6 f4 67 d1 21 57 bf 9e 2a db f1 cc c4 40 ef de 26 5d 1a 65 40 00 3b}}
    set image_grant {grant.gif {47 49 46 38 39 61 10 00 2e 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 2e 00 40 08 6b 00 ff 09 1c 48 b0 a0 c1 83 08 0d 02 48 f8 0f 80 c3 87 0c 1f 42 3c e8 90 60 45 86 18 2d 6a 4c 28 f1 22 c6 89 0a 07 4a cc 48 b2 a4 c9 93 02 3b 82 a4 d8 31 e2 46 84 0b 63 7e 7c 89 92 66 ca 88 2b 6b ea dc c9 b3 67 4a 95 0b 39 9a 54 e9 b2 24 51 a3 38 47 0a 55 0a 73 68 4b a1 22 61 56 cc f9 32 68 d0 90 05 af 2a 7c ea 93 64 40 00 3b}}
    set image_lock {lock.gif {47 49 46 38 39 61 10 00 22 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 22 00 40 08 5c 00 ff 09 1c 48 b0 a0 c1 81 00 00 fc 53 78 10 61 42 86 0d 0b 26 8c 48 b1 a2 c5 8b 08 09 42 94 f8 b0 23 46 8b 10 27 1a ec 48 92 e2 c6 8d 07 3d 9a 2c 89 11 65 46 89 1f 63 56 3c 39 73 a1 4b 81 24 55 c2 1c b9 f2 65 c3 9c 32 23 02 15 aa 71 e6 c3 98 37 17 f2 4c 99 33 69 50 8a 01 01 00 3b}}
    set image_modify {modify.gif {47 49 46 38 39 61 11 00 30 00 f7 00 00 05 05 05 fb fb fb 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 00 00 00 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 11 00 30 00 40 08 83 00 ff 09 1c 48 b0 a0 41 81 00 12 16 04 b0 90 61 c2 87 0c 0f 0e 84 a8 50 e2 c4 87 16 09 52 cc f8 0f 23 47 8a 1e 39 4e fc b8 51 22 c8 8a 07 23 6a 14 c9 d2 20 c4 94 0e 5b 22 5c 99 51 65 47 93 27 6d ca b4 68 53 27 cd 9f 3c 7d ba 44 79 73 a7 d1 8f 47 3b 0a 6d e8 71 69 d1 85 50 9f 4a 65 5a b2 e5 52 85 20 93 0e 3d 69 72 a6 57 92 44 83 86 4d 09 14 e6 4b ad 54 cf e2 2c 2b b6 66 48 b1 55 d1 ca 0c 08 00 3b}}
    set image_modifyform {modifyform.gif {47 49 46 38 39 61 10 00 4d 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 4d 00 40 08 b6 00 ff 09 1c 48 b0 a0 c1 7f 00 12 2a 3c 38 50 e1 42 86 02 1d 42 8c 38 91 22 42 82 00 2a 6a c4 f8 f0 a0 43 89 1e 3f 26 9c 28 92 24 46 92 1f 19 66 bc 68 51 25 c8 95 15 61 9e 64 49 d3 25 c8 98 23 37 ea dc 29 13 e5 4d 8f 33 77 42 94 d9 b3 61 51 9b 29 35 e6 1c 0a 94 63 49 83 23 9f 16 14 d9 11 69 cc a0 42 a1 12 1d 5a 35 ab d7 ab 5c 7f 6a 15 3b 95 67 52 95 66 c9 62 3d ea 94 6d 43 ac 63 bb 7e cd 28 77 2a 55 b4 65 c3 0a 55 1b 71 69 4b 84 74 37 52 75 5b f3 68 d4 b3 4d ff 82 b5 7b 37 6c dd b9 88 a1 c2 8d cb 34 6f 5c be 46 75 46 36 ba 35 f1 db af 01 01 00 3b}}
    set image_override {override.gif {47 49 46 38 39 61 10 00 39 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 39 00 40 08 8e 00 ff 09 1c 48 b0 a0 c1 7f 00 12 2a 3c 48 50 21 00 86 03 1d 26 84 28 70 22 42 8a 0d 1f 1e d4 d8 10 a3 c7 8f 11 25 2e 84 c8 f1 22 49 89 18 1d 82 f4 28 72 25 4b 8b 25 5d 46 ac 38 73 e3 c3 96 24 3b e6 04 59 32 66 c1 9b 08 7d ea fc a8 92 22 ce 8d 06 85 ca 5c 2a 13 a6 d1 8b 16 4f 46 25 6a 53 a4 d2 8a 28 79 da 0c 5a 94 e1 d5 a4 59 bd 0e 45 5a d3 6b 58 a6 19 35 7e 3d 8a 36 e4 54 b3 5d c9 12 1d 69 36 a3 d8 9f 75 43 1a a5 cb 34 20 00 3b}}
    set image_promote {promote.gif {47 49 46 38 39 61 10 00 36 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 36 00 40 08 84 00 ff 09 1c 48 b0 a0 41 00 08 13 1a 24 98 50 e1 42 81 0d 11 3e 9c 38 11 00 c3 87 11 1d 52 dc f8 2f a3 44 8a 0d 37 5a e4 08 f1 22 c9 93 28 51 3a 1c 89 d1 64 ca 96 03 59 72 94 79 30 22 48 9b 15 71 e6 fc b8 53 63 41 9d 30 5d be 1c fa 73 24 cd 9f 1d 3b 1e 2d ca b3 66 46 90 29 43 42 8d 79 53 2a 51 a6 3e 17 2e d5 0a d4 69 56 a4 54 ab 6e 0d 5b b2 67 d3 83 2a bb 82 2d cb 75 2c 59 a3 18 3d 5e 7d 19 10 00 3b}}
    set image_read {read.gif {47 49 46 38 39 61 10 00 22 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 22 00 40 08 63 00 ff 09 1c 48 b0 a0 c1 7f 00 12 2a 3c c8 b0 21 42 00 03 13 3a 9c e8 10 62 43 85 0b 2f 62 b4 68 70 63 46 8a 1a 3d 72 a4 38 b2 e3 43 89 21 05 96 04 69 52 e5 4a 82 2b 5f b2 9c 19 51 e4 4b 8b 1c 65 c2 fc c8 d0 63 45 84 40 41 f2 3c 88 52 27 50 88 28 43 1a 6d d9 71 e1 d0 88 50 83 36 f5 49 b3 aa c0 80 00 3b}}
    set image_revise {revise.gif {47 49 46 38 39 61 10 00 2b 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 2b 00 40 08 75 00 ff 09 1c 48 b0 a0 41 81 00 12 02 38 f8 2f 61 43 85 0e 19 36 94 48 71 62 c5 8b 03 23 2e 94 b8 d0 e1 46 86 10 2f 76 7c 08 32 23 42 8c 18 47 46 04 d9 f1 63 4a 94 22 21 ba 3c a8 b1 62 48 96 1e 57 16 94 a9 10 a6 cf 9f 14 7b 5a c4 29 14 a8 c1 96 43 59 92 3c da f2 66 49 93 1c 8d ea 64 3a d5 28 41 a1 33 77 ca b4 aa 35 63 d6 93 08 bf 7a e5 f9 f4 aa d5 80 00 3b}}
    set image_revoke {revoke.gif {47 49 46 38 39 61 10 00 32 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 32 00 40 08 80 00 ff 09 1c 48 b0 a0 c1 7f 00 10 22 4c 68 10 80 c3 87 0f 0f 12 84 28 b1 62 45 87 03 31 5a dc c8 51 22 c3 85 16 21 6a e4 38 f2 a0 c8 8f 05 4f 96 ec 18 92 21 4a 93 11 49 26 7c c9 d2 e4 c4 90 35 29 6e 8c 49 b3 66 c6 8c 3d 7f a6 f4 49 b4 28 4c 97 2d 75 7a bc 89 73 25 50 95 36 1b ee 8c 79 91 a9 47 91 46 8f 06 9d 88 b5 6a 4e a4 55 67 6e 15 a8 b4 63 50 8a 54 87 92 5d ab b5 6c 56 8e 01 01 00 3b}}
    set image_schedule {schedule.gif {47 49 46 38 39 61 10 00 39 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 39 00 40 08 8c 00 ff 09 1c 48 b0 a0 c1 7f 00 12 0a 04 70 b0 21 c3 86 06 1f 3a 54 88 f0 60 c2 8b 18 21 6a dc c8 b1 a3 43 8d 18 29 4e cc e8 51 a2 45 89 26 09 92 ac e8 b1 25 c7 90 29 17 c2 14 79 72 a5 c5 97 33 63 ba 54 19 12 64 cf 88 37 21 c2 fc 88 d0 e6 ce a3 48 77 52 d4 39 90 a1 53 a6 4d 2f 8e 1c 0a b4 ea 54 9a 20 37 52 4d 5a 74 66 50 94 38 b1 9e 5c 98 f5 a9 56 a9 3e 8d 16 84 1a d5 2b 57 95 70 d3 42 5d 2a b6 a9 4c b2 23 bb 26 0d 08 00 3b}}
    set image_show {show.gif {47 49 46 38 39 61 10 00 26 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 26 00 40 08 65 00 ff 09 1c 48 b0 a0 c1 7f 00 12 1e 34 98 b0 21 80 85 02 1f 42 1c e8 90 e2 44 89 13 29 2a cc 18 b1 21 c7 8f 20 43 16 94 e8 91 e3 46 91 10 31 22 bc e8 50 a5 c6 96 27 47 76 2c 89 b2 a6 cd 99 21 2b b2 fc 08 f3 a2 48 9d 29 09 ba 1c d9 32 27 4b a0 42 61 c6 b4 c8 70 e1 46 9a 4d 11 92 4c a9 10 ea 4d 8e 01 01 00 3b}}
    set image_thaw {thaw.gif {47 49 46 38 39 61 10 00 26 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 26 00 40 08 61 00 ff 09 1c 48 b0 a0 c1 7f 00 12 1e 34 98 b0 21 80 83 0e 23 2e 7c 58 90 e2 c4 85 10 15 62 bc 08 71 a3 c7 8f 20 07 52 6c 08 52 63 48 8b 1d 1d 6e 8c 88 52 64 c7 8c 2c 27 b6 0c 49 f3 a4 c9 8f 2a 57 ce 84 49 12 e3 4e 99 39 2f 3e fc c9 f0 66 d1 a0 2f 75 b2 fc 69 d4 27 43 a0 12 93 d6 9c 7a 30 20 00 3b}}
    set image_toconnect {toconnect.gif {47 49 46 38 39 61 10 00 49 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 49 00 40 08 9f 00 ff 09 1c 48 b0 a0 c1 83 08 05 02 20 b8 30 e1 3f 00 10 1b 3a 64 38 31 a2 44 83 17 15 56 8c 98 30 e3 c3 89 20 43 32 b4 c8 d1 21 44 8d 1d 45 3e 24 69 92 25 42 92 1e 0b c2 7c a9 b2 a6 cd 8f 03 63 de 54 58 32 e5 c2 93 1d 5d be 14 7a 70 66 ca 9c 26 29 ee 54 ca 74 29 d2 a7 18 75 46 35 ea b4 aa d5 ab 20 61 02 a5 29 72 ab d4 95 16 b1 82 45 39 34 6c d7 96 66 cb f6 2c da 74 ea 5a 8c 2a a9 5a 95 0b 17 aa da a0 6d f3 ea dc ba 12 ed d7 9b 74 65 e6 95 f9 76 b0 da b4 82 13 47 15 1b 10 00 3b}}
    set image_todisconnect {todisconnect.gif {47 49 46 38 39 61 10 00 53 00 f7 00 00 00 00 00 00 00 55 00 00 aa 00 00 ff 00 24 00 00 24 55 00 24 aa 00 24 ff 00 49 00 00 49 55 00 49 aa 00 49 ff 00 6d 00 00 6d 55 00 6d aa 00 6d ff 00 92 00 00 92 55 00 92 aa 00 92 ff 00 b6 00 00 b6 55 00 b6 aa 00 b6 ff 00 db 00 00 db 55 00 db aa 00 db ff 00 ff 00 00 ff 55 00 ff aa 00 ff ff 24 00 00 24 00 55 24 00 aa 24 00 ff 24 24 00 24 24 55 24 24 aa 24 24 ff 24 49 00 24 49 55 24 49 aa 24 49 ff 24 6d 00 24 6d 55 24 6d aa 24 6d ff 24 92 00 24 92 55 24 92 aa 24 92 ff 24 b6 00 24 b6 55 24 b6 aa 24 b6 ff 24 db 00 24 db 55 24 db aa 24 db ff 24 ff 00 24 ff 55 24 ff aa 24 ff ff 49 00 00 49 00 55 49 00 aa 49 00 ff 49 24 00 49 24 55 49 24 aa 49 24 ff 49 49 00 49 49 55 49 49 aa 49 49 ff 49 6d 00 49 6d 55 49 6d aa 49 6d ff 49 92 00 49 92 55 49 92 aa 49 92 ff 49 b6 00 49 b6 55 49 b6 aa 49 b6 ff 49 db 00 49 db 55 49 db aa 49 db ff 49 ff 00 49 ff 55 49 ff aa 49 ff ff 6d 00 00 6d 00 55 6d 00 aa 6d 00 ff 6d 24 00 6d 24 55 6d 24 aa 6d 24 ff 6d 49 00 6d 49 55 6d 49 aa 6d 49 ff 6d 6d 00 6d 6d 55 6d 6d aa 6d 6d ff 6d 92 00 6d 92 55 6d 92 aa 6d 92 ff 6d b6 00 6d b6 55 6d b6 aa 6d b6 ff 6d db 00 6d db 55 6d db aa 6d db ff 6d ff 00 6d ff 55 6d ff aa 6d ff ff 92 00 00 92 00 55 92 00 aa 92 00 ff 92 24 00 92 24 55 92 24 aa 92 24 ff 92 49 00 92 49 55 92 49 aa 92 49 ff 92 6d 00 92 6d 55 92 6d aa 92 6d ff 92 92 00 92 92 55 92 92 aa 92 92 ff 92 b6 00 92 b6 55 92 b6 aa 92 b6 ff 92 db 00 92 db 55 92 db aa 92 db ff 92 ff 00 92 ff 55 92 ff aa 92 ff ff b6 00 00 b6 00 55 b6 00 aa b6 00 ff b6 24 00 b6 24 55 b6 24 aa b6 24 ff b6 49 00 b6 49 55 b6 49 aa b6 49 ff b6 6d 00 b6 6d 55 b6 6d aa b6 6d ff b6 92 00 b6 92 55 b6 92 aa b6 92 ff b6 b6 00 b6 b6 55 b6 b6 aa b6 b6 ff b6 db 00 b6 db 55 b6 db aa b6 db ff b6 ff 00 b6 ff 55 b6 ff aa b6 ff ff db 00 00 db 00 55 db 00 aa db 00 ff db 24 00 db 24 55 db 24 aa db 24 ff db 49 00 db 49 55 db 49 aa db 49 ff db 6d 00 db 6d 55 db 6d aa db 6d ff db 92 00 db 92 55 db 92 aa db 92 ff db b6 00 db b6 55 db b6 aa db b6 ff db db 00 db db 55 db db aa db db ff db ff 00 db ff 55 db ff aa db ff ff ff 00 00 ff 00 55 ff 00 aa ff 00 ff ff 24 00 ff 24 55 ff 24 aa ff 24 ff ff 49 00 ff 49 55 ff 49 aa ff 49 ff ff 6d 00 ff 6d 55 ff 6d aa ff 6d ff ff 92 00 ff 92 55 ff 92 aa ff 92 ff ff b6 00 ff b6 55 ff b6 aa ff b6 ff ff db 00 ff db 55 ff db aa ff db ff ff ff 00 ff ff 55 ff ff aa ff ff ff 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 53 00 40 08 bd 00 ff 09 1c 48 b0 a0 c1 7f 00 0e 2a 04 c0 50 60 42 85 08 19 4a 84 18 51 e2 43 88 16 29 22 8c b8 11 e3 44 8c 06 2f 16 6c a8 b1 a4 49 8d 16 49 9a 14 19 32 25 c5 94 2c 47 ba 6c 59 f1 63 c8 9b 20 07 c6 74 08 73 e7 49 9d 3d 5f 5e f4 f9 13 68 46 8f 47 17 12 24 da b1 e8 ca a5 42 75 3a 8d aa f2 a0 48 9f 55 89 f6 64 5a 13 e5 4c 9c 50 ad 4e 1d 4b 56 a9 54 ab 41 cb 86 75 e8 b5 ea c2 87 4c 13 ca e5 9a f4 6d 5d b0 25 61 fe 8c fb 15 ed dd 91 6b ed d2 0d dc f2 2f d9 ab 6d e9 ce 45 c9 91 2b 61 9e 35 dd 1e ee 0b b8 32 5e b6 7e 29 97 d5 9b 13 33 52 ad 7b d3 5e 6e 2a 53 2d c1 80 00 3b}}
    set image_unlock {unlock.gif {47 49 46 38 39 61 10 00 2f 00 f7 00 00 05 05 05 fb fb fb 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 00 00 00 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 2f 00 40 08 75 00 ff 09 1c 48 b0 a0 c1 81 00 00 fc 53 78 10 61 42 86 0d 0d 42 3c f8 f0 61 c3 89 02 31 46 dc c8 91 22 41 8d 11 41 2e ac 98 b0 a3 c9 93 1f 1d 52 24 69 31 64 ca 8d 15 39 b2 5c c9 52 64 46 92 30 5f 9a 14 59 13 a5 cf 9f 32 75 5e 1c 79 b1 26 c8 a3 30 21 da 1c 19 13 28 cd 96 43 11 ca 84 5a d0 28 52 89 49 9b 46 dd 89 d3 e3 49 8d 4b ab 16 9d e9 d5 a9 c1 80 00 3b}}
    set image_utilspace {utilspace.gif {47 49 46 38 39 61 03 00 03 00 f7 00 00 00 00 00 33 00 00 66 00 00 99 00 00 cc 00 00 ff 00 00 00 33 00 33 33 00 66 33 00 99 33 00 cc 33 00 ff 33 00 00 66 00 33 66 00 66 66 00 99 66 00 cc 66 00 ff 66 00 00 99 00 33 99 00 66 99 00 99 99 00 cc 99 00 ff 99 00 00 cc 00 33 cc 00 66 cc 00 99 cc 00 cc cc 00 ff cc 00 00 ff 00 33 ff 00 66 ff 00 99 ff 00 cc ff 00 ff ff 00 00 00 33 33 00 33 66 00 33 99 00 33 cc 00 33 ff 00 33 00 33 33 33 33 33 66 33 33 99 33 33 cc 33 33 ff 33 33 00 66 33 33 66 33 66 66 33 99 66 33 cc 66 33 ff 66 33 00 99 33 33 99 33 66 99 33 99 99 33 cc 99 33 ff 99 33 00 cc 33 33 cc 33 66 cc 33 99 cc 33 cc cc 33 ff cc 33 00 ff 33 33 ff 33 66 ff 33 99 ff 33 cc ff 33 ff ff 33 00 00 66 33 00 66 66 00 66 99 00 66 cc 00 66 ff 00 66 00 33 66 33 33 66 66 33 66 99 33 66 cc 33 66 ff 33 66 00 66 66 33 66 66 66 66 66 99 66 66 cc 66 66 ff 66 66 00 99 66 33 99 66 66 99 66 99 99 66 cc 99 66 ff 99 66 00 cc 66 33 cc 66 66 cc 66 99 cc 66 cc cc 66 ff cc 66 00 ff 66 33 ff 66 66 ff 66 99 ff 66 cc ff 66 ff ff 66 00 00 99 33 00 99 66 00 99 99 00 99 cc 00 99 ff 00 99 00 33 99 33 33 99 66 33 99 99 33 99 cc 33 99 ff 33 99 00 66 99 33 66 99 66 66 99 99 66 99 cc 66 99 ff 66 99 00 99 99 33 99 99 66 99 99 99 99 99 cc 99 99 ff 99 99 00 cc 99 33 cc 99 66 cc 99 99 cc 99 cc cc 99 ff cc 99 00 ff 99 33 ff 99 66 ff 99 99 ff 99 cc ff 99 ff ff 99 00 00 cc 33 00 cc 66 00 cc 99 00 cc cc 00 cc ff 00 cc 00 33 cc 33 33 cc 66 33 cc 99 33 cc cc 33 cc ff 33 cc 00 66 cc 33 66 cc 66 66 cc 99 66 cc cc 66 cc ff 66 cc 00 99 cc 33 99 cc 66 99 cc 99 99 cc cc 99 cc ff 99 cc 00 cc cc 33 cc cc 66 cc cc 99 cc cc cc cc cc ff cc cc 00 ff cc 33 ff cc 66 ff cc 99 ff cc cc ff cc ff ff cc 00 00 ff 33 00 ff 66 00 ff 99 00 ff cc 00 ff ff 00 ff 00 33 ff 33 33 ff 66 33 ff 99 33 ff cc 33 ff ff 33 ff 00 66 ff 33 66 ff 66 66 ff 99 66 ff cc 66 ff ff 66 ff 00 99 ff 33 99 ff 66 99 ff 99 99 ff cc 99 ff ff 99 ff 00 cc ff 33 cc ff 66 cc ff 99 cc ff cc cc ff ff cc ff 00 ff ff 33 ff ff 66 ff ff 99 ff ff cc ff ff ff ff ff 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 21 f9 04 01 00 00 d7 00 2c 00 00 00 00 03 00 03 00 40 08 07 00 af 09 1c 38 30 20 00 3b}}
    set image_viewform {viewform.gif {47 49 46 38 39 61 10 00 42 00 f7 00 00 05 05 05 fb fb fb 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 00 00 00 21 f9 04 01 00 00 ff 00 2c 00 00 00 00 10 00 42 00 40 08 9b 00 ff 09 1c 48 b0 a0 41 81 00 0e 1e 4c 38 90 a1 42 87 ff 20 12 04 40 b1 22 45 85 05 2f 62 8c 68 51 62 43 8e 1e 37 8a 1c 69 b0 63 48 92 13 4f 3e 44 a8 11 e5 c2 84 26 1f 5a 74 89 32 26 46 9b 2b 3f de ec b8 11 a7 cc 96 25 11 ea cc 49 b2 62 51 a0 3b 19 aa 0c ba 90 66 ca 93 4b 9d 4a bd d9 93 67 52 a3 54 6b 5a 25 3a d2 27 53 a1 55 91 7e 8d 18 16 eb d4 8f 66 7f 6e cd 38 b6 a4 d8 ab 22 df ba 9d 99 55 2b d8 95 30 a3 d2 75 0b 32 ed 58 a8 51 65 52 5d 9b 31 f0 d9 8d 01 01 00 3b}}
    set image_filter {filter.gif {47 49 46 38 39 61 12 00 27 00 f7 00 00 00 00 00 80 00 00 00 80 00 80 80 00 00 00 80 80 00 80 00 80 80 c0 c0 c0 c0 dc c0 a6 ca f0 00 00 00 ff ff ff 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ff fb f0 a0 a0 a4 80 80 80 ff 00 00 00 ff 00 ff ff 00 00 00 ff ff 00 ff 00 ff ff ff ff ff 21 f9 4 00 00 00 00 00 2c 00 00 00 00 12 00 27 00 87 00 00 00 80 00 00 00 80 00 80 80 00 00 00 80 80 00 80 00 80 80 c0 c0 c0 c0 dc c0 a6 ca f0 00 00 00 ff ff ff 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ff fb f0 a0 a0 a4 80 80 80 ff 00 00 00 ff 00 ff ff 00 00 00 ff ff 00 ff 00 ff ff ff ff ff 8 6b 00 17 8 1c 48 b0 a0 c1 83 8 13 2a 44 8 00 c0 c2 82 e 1f 12 8c 28 90 62 c2 86 18 2d 32 cc a8 f1 a0 c5 8e 12 1f 36 5c 00 d2 20 c6 8a 22 49 a2 5c c8 b1 24 c4 93 29 7 ba 24 d9 72 66 45 8e 31 43 9a bc 58 d3 65 4f 9f 1e 75 ae f4 e8 b0 25 4f 9a 19 73 aa 14 aa 70 a4 4e 9b 3b 91 e6 a4 e8 b3 27 cf 9a 17 83 32 dd ca b5 6b 40 00 3b 00}}

    set images [list $ematrix_logo $plus $moins $matrix_type $matrixone_logo]
    set lTempImageNames [info vars "image_*"]
    foreach sVarName $lTempImageNames {
        lappend images [subst $[subst $sVarName]]
    }

    foreach image $images {
        Create_Image_File $Image_Directory/[lindex $image 0] [lindex $image 1]
    }

}


