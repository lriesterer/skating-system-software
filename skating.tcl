##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
set version "5.3.7rc1"
#=================================================================================================

source widget.tcl
source utils.tcl
source dynhelp.tcl
source arrow.tcl
source notebook.tcl
source listbox.tcl
source scrollw.tcl
source panedw.tcl
source tree.tcl
source titleframe.tcl
source entry.tcl
source label.tcl
source labelframe.tcl
source spinbox.tcl
source combobox.tcl
source color.tcl
source font_selection.tcl

# patch
proc NoteBook::yview {args} {}

# masque la fenêtre principale
wm withdraw .

# protection contre retro-conception (catch car fonction inexistante sous Windows ...)
catch {rename send {}}

# load the Tktable extension
set pathExecutable [file dirname [info nameofexecutable]]

if {$tcl_platform(platform) == "windows"} {
	catch {load "$::pathExecutable/Tktable.dll"}
} else {
	catch {load "$::pathExecutable/Tktable.so"}
}

#-------------------------------------------------------------------------------------------------
# fixe l'échelle pour indépendence par rapport à la résolution (75 ou 100dpi) lors de l'impression
tk scaling 1.0414104141042

# pour la gestion des caractères accentués
if {$tcl_platform(platform) != "windows"} {
	tk useinputmethod 1
}


#-------------------------------------------------------------------------------------------------
source skating_table.tcl
source skating_utils.tcl

source skating_gui.tcl
source skating_event_general.tcl
source skating_event_attributes.tcl
source skating_event_couples.tcl
source skating_event_judges.tcl
source skating_event_panels.tcl
source skating_event_database.tcl
source skating_folder.tcl
source skating_manage_general.tcl
source skating_manage_dances.tcl
source skating_manage_couples.tcl
source skating_manage_judges.tcl
source skating_manage_rounds.tcl
source skating_class_core.tcl
source skating_class_round.tcl
source skating_class_finale.tcl
source skating_class_finale_2.tcl
source skating_ten_dances.tcl
source skating_results.tcl
source skating_io.tcl
source skating_fastentry.tcl
source skating_print.tcl
source skating_print_html.tcl
source skating_print_ps.tcl
source skating_print_windows.tcl
source skating_print_formatting.tcl
source skating_options.tcl
source skating_options_templates.tcl
source skating_options_localization.tcl

source skating_ext_OCM.tcl

source skating__french.tcl
#source skating__english.tcl


#==== Gestion des licences
set max 0
if {$tcl_platform(platform) == "windows"} {
	if {![info exists env(TMP)]} {
		set env(TMP) "c:/windows/tmp"
	}
	if {![info exists env(TEMP)]} {
		set env(TEMP) "c:/winnt/tmp"
	}
	foreach file [glob -nocomplain -- [string map {\\ /} $env(TMP)]/* [string map {\\ /} $env(TEMP)]/* . ..] {
		catch {
			set new [file mtime $file]
			if {$new > $max} {
				set max $new
			}
		}
	}
} else {
	foreach file [glob -nocomplain -- /tmp /tmp/* /var/log/* . ..] {
		catch {
			set new [file mtime $file]
			if {$new > $max} {
				set max $new
			}
		}
	}
}
set licenseFilename "$::pathExecutable/3s.license"
if {[file exists $licenseFilename]} {
	set license ""
	set file [open $licenseFilename]
	# 5 lignes de license
	append license [gets $file]
	append license [gets $file]
	append license [gets $file]
	append license [gets $file]
	append license [gets $file]
	set line [gets $file]
	if {![string match "----------------*" $line]} {
		# license v2
		append license $line
		for {set i 0} {$i < 15} {incr i} {
			append license [gets $file]
		}
		# 1 ligne de commentaires restant
		gets $file
	}
	# 3 lignes de commentaires restant
	gets $file
	gets $file
	gets $file
	# logo personnalisé
	set logo [string trim [read $file 1000000]]
	close $file

	scan $::version "%d.%d.%d" major minor level
	license version [expr $major*100+$minor*10+$level]

	if {[license set $license [clock seconds] $max] == 0} {
		tk_messageBox -icon warning -type ok -default ok -title License \
				-message $msg(dlg:demoMode)
	}
}
if {[catch {image create photo imgCustomLogo -data $logo}]} {
	# image 1x1 vide
	image create photo imgCustomLogo -data "R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOy=="
}


#==== Gestion des Préférences

proc parseFile {filename var message {useUTF8 1}} {
global $var
upvar 0 $var data

#TRACEF

	if {[file exists $filename]} {
		if {[catch {set file [open $filename]
					if {$useUTF8} {
						fconfigure $file -encoding utf-8
					}
					set content ""
					while {![eof $file]} {
						set line [gets $file]
						if {![string match "#*" $line]} {
							append content "$line "
						}
					}
					close $file
					foreach {var value} $content {
						set data($var) $value
					}
					} errmsg]} {
			tk_messageBox -icon "error" -type ok -default ok \
					-title $::msg(dlg:error) -message $::msg($message)
			return 0
		}	
	}

	return 1
}


# préférences
array set skating::gui {
	pref:showNewDlgAtStartup	1

	pref:names:rounds			0
	pref:names:finale			0
	pref:explain:finale			1
	pref:explicitNames			1
	pref:explain:ten			1
	pref:keyboard:toggleling	0

	pref:completion:couples		1
	pref:completion:judges		1
	pref:tip:name				1

	pref:save:auto				5
	pref:save:backup			1

	pref:mode:compmgr			0
	pref:mode:linkOCM			0
	pref:mode:linkOCM:DBserver	"server"
	pref:mode:linkOCM:DBuser	"user"
	pref:mode:linkOCM:DBpassword "pwd"
	pref:mode:linkOCM:DBdatabase "database"
	pref:mode:linkOCM:server	"localhost"
	pref:mode:linkOCM:id		1
	pref:mode:linkOCM:wireless	0
	pref:mode:linkOCM:autologin	1
	
	pref:attributes				{type agemin agemax ageext level}
	pref:attributes:type		"STD LAT {OPEN STD} {OPEN LAT} {}"
	pref:attributes:agemin		" 6 12 19 35 46 56 {}"
	pref:attributes:agemax		"11 15 34 45 55  + {}"
	pref:attributes:ageext		"OVER UNIF {}"
	pref:attributes:level		"1° 2° 3° D C B A2 A1 A {}"
	pref:folderNaming			"%index - %type / %agemin-%agemax %ageextra / %level"

	pref:inputByJudgeInFinale	1

	pref:judges:button:compact	1

	pref:templates:file			"IDSF.skt"

	color:place					darkseagreen2
	color:placebad				salmon
	color:choosengood			steelblue
	color:choosenprequalif		steelblue2
	color:choosenbad			salmon
	color:selected				black
	color:notselected			gray70
	color:colselected			#DDDDFF
	color:flash					orange
	color:competition			blue
	color:activeDance			red3
	color:finishedDance			black
	color:activeCompetition 	red
	color:finishedCompetition 	black
	color:exclusion				Lightblue2
	color:exclusion:text		SteelBlue4
	color:exclusion:on:bg		Lightblue2
	color:exclusion:on:abg		Lightblue1
	color:yellow				yellow
	color:lightyellow			lightyellow
	color:lightyellow2			#ffe1e0
	color:orange				orange
	color:lightorange			#ffd68b

	color:print:dark			gray80
	color:print:light			gray90
}
set skating::gui(color:exclusion:off:bg) $bg
set skating::gui(color:exclusion:off:abg) $abg

if {$tcl_platform(platform) == "windows"} {
	set skating::gui(color:selection) darkblue
	set skating::gui(color:selectionFG) white
	set skating::gui(color:exclusion:on:abg) $skating::gui(color:exclusion:on:bg)
	set skating::gui(color:exclusion:off:abg) $skating::gui(color:exclusion:off:bg)
} else {
	set skating::gui(color:selection) lightblue
	set skating::gui(color:selectionFG) black
}

# préférence de fontes
if {$tcl_platform(platform) == "windows"} {
	array set skating::gui {
		pref:font:canvas:big		{{MS Sans Serif} -24}
		pref:font:canvas:medium		{{MS Sans Serif} -14}
		pref:font:canvas:label		{{MS Sans Serif} -10 bold}
		pref:font:canvas:small		{{MS Sans Serif} -8 bold}
		pref:font:canvas:couple		{{MS Sans Serif} -10}
		pref:font:canvas:place		{{MS Sans Serif} -10}
		pref:font:competition		{{MS Sans Serif} -18 bold}
		pref:font:event:data		{{MS Sans Serif} -8}
		pref:font:event:data:bold	{{MS Sans Serif} -8 bold}
		pref:font:normal			{{MS Sans Serif} -8}
		pref:font:bold				{{MS Sans Serif} -8 bold}
		pref:font:small				{{MS Sans Serif} -8}
		pref:font:tips				{{MS Sans Serif} -8}
		pref:font:splash:big		{{MS Sans Serif} -12 bold}
		pref:font:splash:normal		{{MS Sans Serif} -10}

		pref:font:print:title		{Arial -22 bold}
		pref:font:print:subtitle	{Arial -16 bold}
		pref:font:print:date		{Arial -14}
		pref:font:print:comment		{Arial -14}
		pref:font:print:big			{Arial -22}
		pref:font:print:large		{Arial -18}
		pref:font:print:medium		{Arial -14 bold}
		pref:font:print:normal		{Arial -11}
		pref:font:print:bold		{Arial -11 bold}
		pref:font:print:subscript	{Arial -8}
		pref:font:print:small		{Arial -8}
		pref:font:print:smallbold	{Arial -8 bold}
	}
} else {
	array set skating::gui {
		pref:font:canvas:big		{Helvetica -24}
		pref:font:canvas:medium		{Helvetica -14 bold}
		pref:font:canvas:label		{Helvetica -12 bold}
		pref:font:canvas:small		{Helvetica -8 bold}
		pref:font:canvas:couple		{Helvetica -12}
		pref:font:canvas:place		{Helvetica -12}
		pref:font:competition		{Helvetica -18 bold}
		pref:font:event:data		{Helvetica -12}
		pref:font:event:data:bold	{Helvetica -12 bold}
		pref:font:normal			{Helvetica -12}
		pref:font:bold				{Helvetica -12 bold}
		pref:font:small				{Helvetica -10}
		pref:font:tips				{Helvetica -10}
		pref:font:splash:big		{Helvetica -16 bold}
		pref:font:splash:normal		{Helvetica -14}

		pref:font:print:title		{Helvetica 24 bold}
		pref:font:print:subtitle	{Helvetica 16 bold}
		pref:font:print:date		{Helvetica 14}
		pref:font:print:comment		{Helvetica 14}
		pref:font:print:big			{Helvetica 24}
		pref:font:print:large		{Helvetica 18}
		pref:font:print:medium		{Helvetica 14 bold}
		pref:font:print:normal		{Helvetica 12}
		pref:font:print:bold		{Helvetica 12 bold}
		pref:font:print:subscript	{Helvetica 8}
		pref:font:print:small		{Helvetica 8}
		pref:font:print:smallbold	{Helvetica 8 bold}
	}
}

# gestion des bases de données
set ::skating::gui(pref:db) "$::pathExecutable/3s.db"

#==== Préférences utilisateur
parseFile "$::pathExecutable/3s.pref" skating::gui dlg:prefFailed

#==== Préférences de langues
parseFile "$::pathExecutable/3s.lang" msg dlg:langFailed 0
if {[info exists skating::gui(pref:language)]} {
	parseFile "$::pathExecutable/data/$skating::gui(pref:language).lang" msg dlg:langFailed
}


#==== Charge les plugins
foreach file [glob -nocomplain -types {f l} $::pathExecutable/data/*.3sp] {
	if {[catch { load_plugin $file } errMsg]} {
		tk_messageBox -icon "error" -type ok -default ok \
				-title $msg(dlg:error) -message "ERROR while loading plugin '[file tail $file]'\n\n$errMsg"
puts "ERROR = $errMsg"
	}
}


#==== Gestion des templates de compétitions
if {[file pathtype $skating::gui(pref:templates:file)] == "relative"} {
	set filename "$::pathExecutable/data/$skating::gui(pref:templates:file)"
} else {
	set filename "$skating::gui(pref:templates:file)"
}
skating::folder:template:load $filename


#==== création des fonts
foreach font [array names skating::gui pref:font:*] {
	scan $font "pref:font:%s" name
	set family [lindex $skating::gui($font) 0]
	set size [lindex $skating::gui($font) 1]
	set weight [lindex $skating::gui($font) 2]
	if {$weight == ""} {
		font create $name -family $family -size $size
	} else {
		font create $name -family $family -size $size -weight $weight
	}
}

DynamicHelp::configure -font tips -delay 500


#==== Gestion des erreurs

proc bgerror err {
global msg errorCode errorInfo

	tk_messageBox -icon "error" -type ok -default ok \
			-title $msg(dlg:error) -message $msg(dlg:bugReport)

	set reportFilename "$::pathExecutable/3s.bugreport"
	catch {
		set file [open $reportFilename "w"]
		fconfigure $file -encoding utf-8
		puts $file "3S version $::version\n-----------------------"
		puts $file $errorCode
		puts $file $errorInfo
		close $file
	}
}


#==== Démarre le programme

skating::gui:main .top
if {$tcl_platform(platform) == "windows"} {
	if {[winfo screenwidth .] == 640} {
		wm geometry .top 632x472+0+0
	} elseif {[winfo screenwidth .] == 800} {
		wm geometry .top 792x592+0+0
	} else {
		wm geometry .top 800x620+0+0
	}
} else {
	wm geometry .top 800x600+0+0
}

# activation de l'auto-save
skating::gui:save:initAutosave

# init des extensions
OCM::init

# ajuste le titre
::skating::gui:setTitle
