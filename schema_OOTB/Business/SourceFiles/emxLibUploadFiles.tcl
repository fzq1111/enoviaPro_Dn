tcl;
mql verb off
eval {
set sOS [string tolower $tcl_platform(os)];
#Win64 fix begin
set sArch [string tolower $tcl_platform(machine)];
set sMacName $sArch

if {$sArch == "intel"} {
   set sArch "intel_a"
} else {
   set sArch "win_b64"
}
#Win64 fix end
#mxclasspath msg begin
puts "\nINFO: ** Please make sure SpinnerBuild.jar is in your classpath if you have ENOVIA JAR files stored in a folder other than studio or server's javaserver folder. **"
#mxclasspath msg end

if {$sOS == "windows nt" } {
set insProg [mql insert program .///Business///SourceFiles///prog]
set pt [mql get env STDHOME]
#Win64 fix replaced hardcoded path append pt "///intel_a///docs///javaserver"
append pt "///$sArch///docs///javaserver"

 if { [catch {file copy -force ".///Business///SpinnerBuild.jar" $pt} fid] } {
   puts stderr "\nCould not copy file \n$fid,\nPlease enter a valid studio home path"
   exit 1
   return
 }

 set pt1 [mql get env SERHOME]
 #Win64 fix replaced hardcoded path append pt1 "///intel_a///docs///javaserver"
 append pt1 "///$sArch///docs///javaserver"
 if { [catch {file copy -force ".///Business///SpinnerBuild.jar" $pt1} fid] } {
   puts stderr "\nCould not copy file \n$fid,\nPlease enter a valid server home path"
   exit 1
   return
 }

 set sTest [mql execute prog emxKeyGenrateDetails -method getKeyDetails]
puts $sTest
if {$sTest != ""} {

   #exit 1
   #return
                  }

} elseif {$sOS == "linux"} {

# HE5 Fix For SUSE (09/13/2012)- START
 set linuxflavor [exec lsb_release -i]
 regexp {Distributor ID:\s*.*?(.*)} $linuxflavor matched flavor
# HE5 Fix For SUSE (09/13/2012)- END

set insProg [mql insert program .///Business///SourceFiles///prog]
set pt [mql get env STDHOME]

# HE5 Fix For SUSE (09/13/2012)- START

if {$flavor== "SUSE LINUX"} {
   set sMacName "linux_b64"
} else {
   set sMacName "linux_a64"
}

# append pt "///linux_a64///docs///javaserver"
  append pt "///$sMacName///docs///javaserver"

# HE5 Fix For SUSE (09/13/2012)- END

 if { [catch {file copy -force ".///Business///SpinnerBuild.jar" $pt} fid] } {
   puts stderr "\nCould not copy file \n$fid,\nPlease enter a valid studio home path"
   exit 1
   return
 }

  set pt1 [mql get env SERHOME]

# append pt1 "///linux_a64///docs///javaserver"
  append pt1 "///$sMacName///docs///javaserver"

 if { [catch {file copy -force ".///Business///SpinnerBuild.jar" $pt1} fid] } {
   puts stderr "\nCould not copy file \n$fid,\nPlease enter a valid server home path"
   exit 1
   return
 }

 set sTest [mql execute prog emxKeyGenrateDetails -method getKeyDetails]
puts $sTest
if {$sTest != ""} {

   exit 1
   return
                  }
} elseif {$sOS == "sunos"} {
set insProg [mql insert program .///Business///SourceFiles///prog]
set pt [mql get env STDHOME]
append pt "///solaris_a64///docs///javaserver"

 if { [catch {file copy -force ".///Business///SpinnerBuild.jar" $pt} fid] } {
   puts stderr "\nCould not copy file \n$fid,\nPlease enter a valid studio home path"
   exit 1
   return
 }
  set pt1 [mql get env SERHOME]
 append pt1 "///solaris_a64///docs///javaserver"
 if { [catch {file copy -force ".///Business///SpinnerBuild.jar" $pt1} fid] } {
   puts stderr "\nCould not copy file \n$fid,\nPlease enter a valid server home path"
   exit 1
   return
 }

 set sTest [mql execute prog emxKeyGenrateDetails -method getKeyDetails]
puts $sTest
if {$sTest != ""} {

   exit 1
   return
                  }
} elseif {$sOS == "aix"} {
set insProg [mql insert program .///Business///SourceFiles///prog]
set pt [mql get env STDHOME]
append pt "///aix_a64///docs///javaserver"

 if { [catch {file copy -force ".///Business///SpinnerBuild.jar" $pt} fid] } {
   puts stderr "\nCould not copy file \n$fid,\nPlease enter a valid studio home path"
   exit 1
   return
 }
 set pt1 [mql get env SERHOME]
 append pt1 "///aix_a64///docs///javaserver"
 if { [catch {file copy -force ".///Business///SpinnerBuild.jar" $pt1} fid] } {
   puts stderr "\nCould not copy file \n$fid,\nPlease enter a valid server home path"
   exit 1
   return
 }

 set sTest [mql execute prog emxKeyGenrateDetails -method getKeyDetails]
puts $sTest
if {$sTest != ""} {

   exit 1
   return
                  }

}

}


