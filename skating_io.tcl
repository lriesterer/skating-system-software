##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#==============================================================================
#
#	Routine pour l'interface graphique
#
#==============================================================================


namespace eval skating {
	set plugins(IO) [list]
}


#------------------------------------------------------------------------------


proc skating::gui:new {{check 1}} {
global msg
variable gui
variable event

	# boite de confirmation
	if {$check && ![gui:check:save]} {
		return
	}
	# efface notebook
	foreach p [NoteBook::pages $gui(w:notebook)] {
		NoteBook::delete $gui(w:notebook) $p
	}
	# réinitialise les variables
	unset event
	# nouvelles valeurs par défaut
	set event(folders) {}
	set event(couples) {}
	set event(judges) {}
	set event(panels) {}
	set event(useCountry) 0
	# efface anciens dossiers
	folder:remove all
	# pas de nom de fichier
	set gui(v:filename) $msg(noName)
	set gui(v:modified) 0
	# retire affichage sélection
	set ::skating::displayFolder ""
	set ::skating::displayRound ""
	# réinitialise affichage
	set gui(v:lastselection) ""
	set gui(v:folder) ""
	set gui(v:round) ""
	gui:redisplay

	# ouvre le dialogue permettant une définition rapide
	if {$check} {
		gui:newQuick:dialog
	}
}

proc skating::gui:newQuick:dialog {} {
global msg
variable gui
variable event


	destroy .dialog
	toplevel .dialog
	wm title .dialog $msg(dlg:quickinput)

	# frame du dialogue
	set f [frame .dialog.top]
		# texte explicatif
		label $f.msg -text $msg(dlg:new:msg) -justify left
		# date
		set ff [frame $f.date]
		  label $ff.l -text $msg(date) -width 10 -anchor w
		  entry $ff.e -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
				-textvariable ::skating::event(general:date)
			bindEntry $ff.e {}
			bind $ff.e <Return> {tkTabToWindow [tk_focusNext %W]}
		  pack $ff.l -side left
		  pack $ff.e -side left -fill x -expand true
		# titre
		set ff [frame $f.title]
		  label $ff.l -text $msg(title) -width 10 -anchor w
		  entry $ff.e -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
				-textvariable ::skating::event(general:title)
			bindEntry $ff.e {}
			bind $ff.e <Return> {tkTabToWindow [tk_focusNext %W]}
		  pack $ff.l -side left
		  pack $ff.e -side left -fill x -expand true
		# spinboxes couples & juges
		SpinBox::create $f.cfrom -labelwidth 25 -label $msg(dlg:new:couples) \
				-range {1 1000 1} \
				-width 4 -entrybg gray95 -textvariable ::quickCouplesFrom \
				-selectbackground $gui(color:selection)
		  bind $f.cfrom.e <Return> {tkTabToWindow [tk_focusNext %W]}
		SpinBox::create $f.cto -label " $msg(dlg:new:couples2)  " -range {1 1000 1} \
				-width 4 -entrybg gray95 -textvariable ::quickCouplesTo \
				-selectbackground $gui(color:selection)
		  bind $f.cto.e <Return> {tkTabToWindow [tk_focusNext %W]}
		SpinBox::create $f.j -labelwidth 25 -label $msg(dlg:new:judges) \
				-range {1 26 1} \
				-width 4 -entrybg gray95 -textvariable ::quickJudges \
				-selectbackground $gui(color:selection)
  		  bind $f.j.e <Return> "skating::gui:newQuick:doit ; break"
		# init
		set date [clock format [clock seconds] -format $msg(dateFormat)]
		set map [list ]
		foreach m1 {January February March April May June July August September October November December} \
				m2 $msg(months) {
			lappend map $m1
			lappend map $m2
		}
		set ::skating::event(general:date) [string map $map $date]

		set ::quickCouplesFrom 1
		set ::quickCouplesTo 20
		set ::quickJudges 5
		focus $f.title.e
		# mise en page
		pack $f.msg -side top -fill both -anchor w
		pack [frame $f.sep1 -height 15] $f.date $f.title -side top -fill x -padx 25 -pady 2 -anchor w
		pack [frame $f.sep2 -height 5] -side top -padx 25 -pady 2 -anchor w
		pack $f.j -side bottom -padx 25 -pady 2 -anchor w
		pack [frame $f.sep3 -width 25] $f.cfrom -side left -pady 2 -anchor w
		pack $f.cto -side left -padx 5 -pady 2 -anchor w

	pack $f -side top -expand true -fill both -padx 10 -pady 10

	# frame des boutons
	variable plugins
	set but [frame .dialog.but -bd 1 -relief raised]
	  button $but.go -text $msg(dlg:quickinput) -bd 1 -width 13 \
			-command "skating::gui:newQuick:doit" -default active
	  button $but.no -text $msg(dlg:standard) -bd 1 -width 13 \
			-command "destroy .dialog; set skating::gui(v:inEdit) 0; if {[llength $::templates]} {skating::folder:template}"
	  if {[llength $plugins(IO)]} {
		  button $but.plug -text "Plugin ... " -bd 1 -width 13 \
				-command "skating::gui:newPlugin"
	  }
	  button $but.cancel -text $msg(dlg:cancel) -bd 1 -width 13 \
			-command "destroy .dialog; set skating::gui(v:inEdit) 0;"
	  if {[llength $plugins(IO)]} {
		  grid $but.go $but.no $but.plug $but.cancel -sticky ew -padx 10 -pady 5
	  } else {
		  grid $but.go $but.no $but.cancel -sticky ew -padx 10 -pady 5
	  }
	pack $but -fill x -anchor c -side bottom

	# ajuste position de la boite de dialogue
	centerDialog .top .dialog
}

proc skating::gui:newQuick:doit {} {
variable gui
variable event

	# on vérifie les arguments
	if {[scan $::quickCouplesFrom "%d" dummy1] != 1
			|| [scan $::quickCouplesTo "%d" dummy1] != 1
			|| [scan $::quickJudges "%d" dummy1] != 1} {
		bell
		return
	}
	# nom de fichier par défaut
	set gui(v:filename) "$event(general:title).ska"
	# crée les données
	event:couples:quickCreate 1
	event:judges:quickCreate 1
	destroy .dialog
	set gui(v:inEdit) 0
	# choix de compétitions dans la liste des pré-définies
	if {[llength $::templates]} {
		folder:template
	} else {
		# crée une première compétition
		after idle { skating::folder:new }
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::gui:newPlugin {} {
variable plugins

	if {[llength $plugins(IO)] == 2} {
		#--------------------------------
		# un seul et unique : on le prend
		#--------------------------------
		gui:doPlugin [lindex $plugins(IO) 1]

	} else {
		#------------------
		# dialogue de choix
		#------------------
		global msg
		destroy .dialog
		toplevel .dialog
		wm title .dialog $msg(dlg:plugin)

		# frame du dialogue
		set f [frame .dialog.top]
			# mise en page
			set i 0
			foreach {label command} $plugins(IO)] {
				button $f.$i -text $label -command "skating::gui:doPlugin $command" \
						-bd 1
				pack $f.$i -padx 30 -pady 10 -expand true -fill x
				incr i
			}
		pack $f -side top -expand true -fill both -padx 10 -pady 10

		# frame des boutons
		variable plugins
		set but [frame .dialog.but -bd 1 -relief raised]
		  button $but.cancel -text $msg(dlg:cancel) -bd 1 -width 13 \
				-command "destroy .dialog"
		  pack $but.cancel -padx 10 -pady 5
		pack $but -fill x -anchor c -side bottom

		# ajuste position de la boite de dialogue
		centerDialog .top .dialog
	}
}

proc skating::gui:doPlugin {plugin} {
variable plugins

	destroy .dialog
	# execute
	$plugin

	# mise à jour affichage
	skating::gui:redisplay
}


#-------------------------------------------------------------------------------------------------

proc skating::gui:splash:init {} {
global msg
variable gui

	set c $gui(w:notebook):cmd
	set y 30
	set hb [expr int(1.1*[font metrics "splash:big" -linespace])]
	set hn [expr int(1.1*[font metrics "splash:normal" -linespace])]

	# logo
	$c create image 10 $y -image imgLogo -anchor nw
	incr y [expr [image height imgLogo]+20]

	# numéro de version + URL du site
	$c create text 10 $y -font splash:big -text "Version $::version" -anchor nw
	incr y $hb
	$c create text 10 $y -font splash:normal -text "http://laurent.riesterer.free.fr/skating" -anchor nw
	incr y $hn
	incr y 50

	# infos
	$c create text 10 $y -font splash:big -text "$msg(license:registred)" -anchor nw
	incr y $hb
	incr y 10
	set name [license name]
	if {$name == 0} {
		set who $msg(license:demo)
		append who "\n\n$msg(license:id): [format %09d [license id]]"
		set lines 3
	} else {
		set who {}
		foreach s [split $name ,] {
			lappend who [string trim $s]
		}
		set lines [llength $who]
		set who [join $who \n]
		set limit [license expiry]
		set v [license maxversion]
		set version [format "%d.%d.%d" [expr $v/100] [expr ($v/10)%10] [expr $v%10]]
		if {$limit} {
			append who "\n\n($msg(license:expiry) [clock format $limit -format %d/%m/%Y], "
			append who "$msg(license:id): [format %09d [license id]])"
			incr lines 3
		} elseif {$v} {
			append who "\n\n($msg(license:maxallowed): $version)"
			incr lines 3
		} else {
			append who "\n\n($msg(license:id): [format %09d [license id]])"
			incr lines 3
		}
	}
	set id [$c create text 10 $y -font splash:normal -text $who -anchor nw]
	# calcul bbox
	set x [lindex [$c bbox $id] 2]
	incr x 50
	$c create image $x $y -image imgCustomLogo -anchor nw

	incr y [expr $lines*$hb]
}

#-------------------------------------------------------------------------------------------------

proc skating::gui:load {{file ""}} {
global msg
variable gui

	# si fichier non donné, boite de dialogue pour choix
	if {$file == ""} {
		# boite de confirmation
		if {![gui:check:save]} {
			return
		}
		# boite de dialogue pour le choix du fichier
	    set types [list [list $msg(fileSkating)	{.ska}] \
						[list $msg(fileAll) 	*] ]
		if {$gui(v:filename) == $msg(noName)} {
			set file [tk_getOpenFile -filetypes $types -parent $gui(w:tree)]
		} else {
			set file [tk_getOpenFile -filetypes $types -parent $gui(w:tree) \
									-initialdir [file dirname $gui(v:filename)]]
		}
		if {$file == ""} {
			return
		}
	}
	#-----------
	# chargement
	io:load $file
	# mémorise nom du fichier
	set gui(v:filename) $file
	set gui(pref:print:html:outputdir) [file dirname $file]/web
	set gui(v:modified) 0
	gui:setTitle
	# retire affichage sélection
	set ::skating::displayFolder ""
	set ::skating::displayRound ""
	# réinitialise affichage
	set gui(v:lastselection) ""
	set gui(v:folder) ""
	set gui(v:round) ""
	Tree::delete $gui(w:tree) [Tree::nodes $gui(w:tree) root]
	gui:redisplay
}

#-------------------------------------------------------------------------------------------------

proc skating::gui:check:save {} {
global msg
variable gui
variable event

	# demande confirmation
	if {$gui(v:modified)} {
		set doit [tk_messageBox -icon "question" -type okcancel -default ok \
							-title $msg(dlg:question) -message $msg(dlg:confirmDiscard)]
		if {$doit != "ok"} {
			return 0
		}
	}
	return 1
}

#-------------------------------------------------------------------------------------------------

proc skating::gui:redisplay {} {
variable gui
variable event

	# efface notebook
	foreach p [NoteBook::pages $gui(w:notebook)] {
		NoteBook::delete $gui(w:notebook) $p
	}
	# ajoute nouveau
	foreach f $event(folders) {
		folder:add $f [set ::skating::${f}(label)]
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::gui:save {mode} {
global msg
variable gui

#TRACEF

	# mode = 0 --> boite de dialogue pour le nom
	# mode = 1 --> Ctrl+S pour sauvegarde rapide
	# mode = 2 --> autosave
	if {$mode == 0 || ($mode == 1 && $gui(v:filename) == $msg(noName))} {
		# boite de dialogue pour le choix du fichier
	    set types [list [list $msg(fileSkating)	{.ska}] \
						[list $msg(fileAll) 	*] ]

		if {$gui(v:filename) == $msg(noName)} {
			set initialdir [pwd]
			if {[file writable $initialdir] == 0} {
				set old [pwd]
				cd ~
				set initialdir [pwd]
				cd $old
			}
			set file [tk_getSaveFile -filetypes $types -parent $gui(w:tree) \
								-initialdir $initialdir \
								-initialfile $gui(v:filename) -defaultextension .ska]
		} else {
			set file [tk_getSaveFile -filetypes $types -parent $gui(w:tree) \
								-initialdir [file dirname $gui(v:filename)] \
								-initialfile [file tail $gui(v:filename)] -defaultextension .ska]
		}
		if {$file == ""} {
			return
		}
		set gui(v:filename) $file
		set gui(pref:print:html:outputdir) [file dirname $file]/web
		gui:setTitle
	} else {
		# mode = 2 ---> autosave
		# flash save bouton pour feedback
		set bg [$gui(w:tb).save cget -background]
		$gui(w:tb).save configure -background aquamarine
		update
		after 1000 "$gui(w:tb).save configure -background $bg"
		if {$mode == 1} {
			set file $gui(v:filename)
		} else {
			set file [file rootname $gui(v:filename)].autosave.ska
		}
		if {![file writable [file dirname $file]]} {
			return
		}
	}

	# sauvegarde de l'ancien fichier (backup)
	if {$gui(pref:save:backup) && $mode != 2} {
		catch {
			file rename -force -- $file [file rootname $file].bak.ska
		}
	}
	# sauvegarde
	set isError 0
	if {[catch { io:save $file } ]} {
		if {[lindex $::errorCode 0] == "POSIX" && [lindex $::errorCode 1] == "ENOSPC"} {
			tk_messageBox -icon "error" -type ok -default ok \
					-title $msg(dlg:error) -message "$msg(dlg:errorWrite)"
		} else {
puts $::errorInfo
			bgerror "CRITICAL"
			set isError 1
			if {![catch { set backupFile [io:saveDirty $file] }]} {
				tk_messageBox -icon "error" -type ok -default ok \
						-title $msg(dlg:error) -message "[format $msg(dlg:errorWriteBackup) $backupFile]"
			}
		}
	}

	# auto-save
	if {$gui(pref:save:auto)} {
		after cancel $gui(v:autosave:timer)
		if {$isError == 0} {
			set gui(v:autosave:timer) [after [expr {60000*$gui(pref:save:auto)}] "skating::gui:save 2"]
		}
	}
	# modifications sauvées
	set gui(v:modified) 0
}

proc skating::gui:save:initAutosave {} {
variable gui

	after cancel $gui(v:autosave:timer)
	if {$gui(pref:save:auto)} {
		set gui(v:autosave:timer) [after [expr {60000*$gui(pref:save:auto)}] "skating::gui:save 2"]
	} else {
		set gui(v:autosave:timer) -1
	}
}


#=================================================================================================
#
#	Routines pour l'enregistrement et le chargement
#
#=================================================================================================

#	Historique des versions du format
#
#	   Ver. Date		Changement
#	   ---------------
#		2				Première définition de event/version
#		3	22/05/00	Ajout des commentaires pour chaque round de chaque compétition
#						Suppression de la gestion des categories
#						Ajout du support pour les panels de juges (un panel par compétition)
#	   (4)	01/10/00	Gestion des panels juges étendue (multi-panel par coméptition)
#						-- jamais utilisé -- erreur --
#		5	02/10/00	Nouvelle gestion des panels: un panel = un regroupement de juges, ajout
#						de noms pour les panels
#	   (6)	15/12/00	Support du mode dix danses  -- jamais releasé --
#		7	07/01/01	Restructuration du mode dix danses
#			18/03/01	Ajout de la sauvegarde du mode pour les heats (taille+type)
#		8	21/04/01	Modification heats : ajout type d'aléa (couples)
#		9	13/06/01	Sauvegarde/lecture forcés en mode UTF-8
#		10	22/06/01	Gestion des alias de couples:
#							couples:all = entiers,
#							couples:names = reel, pointeur sur le nom réel
#		11	07/10/01	Ajout support pour forcer règle de 50% de candidats de N vers N+1
#							round:use50%rule
#		12	12/11/01	Ajout support pour attributs utilisateurs.
#			30/11/01	Ajout judges:requested (optionnel)
#		13	21/01/02	Ajout support pour round de départ
#		14	05/05/02	Ajout mémorisation des panels dans les compétitions
#		15	07/09/02	Ajout d'un flag pour utilisation 'pays' au lieu de 'ecole/club'
#			21/09/02	Ajout d'attributs globaux sur un fichier
#			22/08/04	Support pour les heatid de OCM

set fileformatVersion 15

proc skating::io:load {filename} {
global msg
variable gui
variable event

	# ouvre le fichier
	if {[catch {set file [open $filename "r"]} errStr]} {
		tk_messageBox -icon "error" -type ok -default ok \
				-title $msg(dlg:error) -message "$msg(dlg:cantOpen) '$filename'.\n\n($errStr)"
		return
	}

	# force la lecture en utf-8
	gets $file
	set version [gets $file]
	if {[scan $version "    version %d" version] == 1} {
		if {$version >= 9} {
			fconfigure $file -encoding utf-8
		}
		# check si on ouvre un fichier d'une versoin plus récente
		if {$version > $::fileformatVersion} {
			tk_messageBox -icon "info" -type ok -default ok \
					-title $msg(dlg:information) -message "$msg(dlg:loadTooRecent)"
		}
	}
	seek $file 0 start

	# réinitialise les variables
	foreach f $event(folders) {
		unset ::skating::$f
	}
	unset ::skating::event

	# charge le fichier
	set whole [read $file]
	close $file
	# parse les nouvelles valeurs
	foreach {var value} $whole {
		foreach {item val} $value {
			set ::skating::${var}($item) $val
		}
	}

	#---- définition d'un numéro de version de format de fichier
	if {![info exists event(version)]} {
		set event(version) 1
	}

	#---- conversions pour compatibilité ascendante (GENERAL)
	#-- pour support panels de juges
	if {$event(version) < 3} {
		set event(panels) {}
	} elseif {$event(version) < 5} {
		set judges {}
		foreach panel $event(panels) {
			foreach judge [lsort $event(judges:$panel)] {
				set letter "A"
				for {set i 1} {$i < 700} {incr i} {
					if {[lsearch $judges $letter] == -1} {
						break
					}
					set letter [event:judges:nextLetter $letter]
				}
#puts "$panel:$judge = using letter $letter"
				set convert($panel:$judge) $letter
				lappend judges $letter
			}
		}
		# conversion des noms
		foreach panel $event(panels) {
			foreach judge $event(judges:$panel) {
				set event(name:$convert($panel:$judge)) $event(name:$panel:$judge)
				unset event(name:$panel:$judge)
			}
			unset event(judges:$panel)
		}
		# nouvelle init
		set event(panels) {}
		set event(judges) $judges
	} 

	if {$event(version) < 15} {
		set event(useCountry) 0
	}

	#---- conversions pour compatibilité ascendante (COMPETITIONS)
	foreach f $event(folders) {
	variable $f
	upvar 0 $f folder

		#-- ajoute le mode pour le dossier
		if {$event(version) < 6} {
			set folder(mode) normal			
		}	

		#-- gère l'option 'judges:requested'
		if {![info exists folder(judges:requested)]} {
			if {$folder(mode) == "ten"} {
				foreach dance $folder(dances) {
					variable $f.$dance
					upvar 0 $f.$dance Dfolder

					set Dfolder(judges:requested) [list ]
				}
			} else {
				set folder(judges:requested) [list ]
			}
		}

		#-- pour support repêchage
		if {$event(version) < 7} {
			if {![info exists folder(round:generation)]} {
				set folder(round:generation) "auto"
			}
			if {![info exists folder(round:explicitNames)]} {
				set folder(round:explicitNames) $gui(pref:explicitNames)
			}
		}
		#-- pour support couples aliasing
		if {$event(version) < 11} {
			if {$folder(mode) == "ten"} {
				foreach dance $folder(dances) {
					variable $f.$dance
					upvar 0 $f.$dance Dfolder

					set Dfolder(round:use50%rule) 0
				}
			} else {
				set folder(round:use50%rule) 0
			}
		}
		manage:rounds:generate $f io		;# pre-compute, sans mise-à-jour interface

		#-- pour support choix partiel de juges
		if {$event(version) < 7 && [info exists folder(levels)]} {
			foreach level $folder(levels) {
				if {[info exists folder(judges)]} {
					set folder(judges:$level) $folder(judges)
				} elseif {![info exists folder(judges:$level)]} {
					set folder(judges:$level) {}
				}
			}
			catch {unset folder(judges)}
		}
		#-- pour support mode de génération des couples dans les heats
		if {$event(version) < 8 && [info exists folder(levels)]} {
			foreach level $folder(levels) {
				if {[llength [array names folder heats:$level:*]]} {
					set folder(heats:$level:couples) random
				}
			}
		}

		#-- pour support couples aliasing
		if {$event(version) < 10} {
			if {[info exists folder(couples:all)]} {
				set folder(couples:names) $folder(couples:all)
			}
			if {$folder(mode) == "ten"} {
				foreach dance $folder(dances) {
					variable $f.$dance
					upvar 0 $f.$dance Dfolder
					if {[info exists Dfolder(couples:all)]} {
						set Dfolder(couples:names) $Dfolder(couples:all)
					}
				}
			}
		}

		#-- pour support unification notes/select
		if {$event(version) < 2} {
			set select [array names folder select:*]
			set notes [array names folder notes:*]
			foreach name $select {
				regexp "select:(.*)" $name dummy what
				if {[regexp "(.*):dances" $what dummy round]} {
					set folder(dances:$round) $folder($name)
				} else {
					set folder(notes:$what) $folder($name)
				}
				unset folder($name)
			}
			foreach name $notes {
				regexp "notes:(.*)" $name dummy what
				set folder(notes:finale:$what) $folder($name)
				unset folder($name)
			}
		}
		#-- pour support panels de juges
		if {$event(version) == 3} {
			foreach name [array names folder judges:*] {
				set tmp {}
				foreach judge $folder($name) {
					lappend tmp $convert($folder(panel):$judge)
				}
				set folder($name) $tmp
			}
			unset folder(panel)
			
		}

		#-- pour le support round de départ
		if {$event(version) < 13 && $folder(mode) == "normal"} {
			set folder(startIn:[lindex $folder(levels) 0]) $folder(couples:all)
			foreach r [lrange $folder(levels) 1 end] {
				set folder(startIn:$r) [list ]
			}
		}

		#-- pour le support mémorisation des panels
		if {$event(version) < 14} {
			set folder(panels) [list ]			
			if {$folder(mode) == "ten"} {
				foreach dance $folder(dances) {
					variable $f.$dance
					upvar 0 $f.$dance Dfolder
					set Dfolder(panels) [list ]			
				}
			}
		}	

#  puts "-------------------------------"
#  puts "$f = $folder(label)"
#  puts "-------------------------------"
#  parray folder
	}

	event:database:refreshWithFile
	# mode de sélection des juges pour fastentry
	event:judges:setMode

	# gestion des attributs (à partir v. 15)
	setAttributes
}

#-------------------------------------------------------------------------------------------------

proc skating::io:saveDirty {filename} {
global msg
variable event


TRACEF

	# trouve un nom de fichier
	set serial 1
	while {$serial < 100} {
		set real_filename [file rootname $filename].save$serial.ska
		if {![file exists $real_filename]} {
			break
		}
		incr serial
	}
	# ouvre le fichier
	if {[catch {set file [open $real_filename "w"]} errStr]} {
		if {![file writable [file dirname $real_filename]]} {
			tk_messageBox -icon "error" -type ok -default ok \
					-title $msg(dlg:cannotWrite) -message [format $msg(dlg:cannotWrite) $real_filename]
		} else {
			tk_messageBox -icon "error" -type ok -default ok \
					-title $msg(dlg:error) -message "$msg(dlg:cantSave) '$real_filename'.\n\n($errStr)"
		}
		return ""
	}

	# force la sauvegarde en utf-8
	fconfigure $file -encoding utf-8 -translation cr

	# partie commune dance event
	puts $file "event \{"
	  # version du format de fichier
	  puts $file "    version $::fileformatVersion\n"
	  # couples incrits
	  puts $file "    couples [list $event(couples)]"
	  # juges incrits
	  puts $file "    judges [list $event(judges)]"
	  # panels
	  puts $file "    panels [list $event(panels)]"
	  foreach panel $event(panels) {
		  puts $file "    panel:name:$panel [list $event(panel:name:$panel)]"
		  puts $file "    panel:judges:$panel [list $event(panel:judges:$panel)]"
	  }
	  # school vs country mode
	  puts $file "    useCountry [list $event(useCountry)]"
	  # folders  --  1 seulement pour version démo
	  set folders $event(folders)
	  if {[license check] == 0} {
		  set folders [lindex $folders 0]
		  tk_messageBox -icon "info" -type ok -default ok \
				  -title $msg(dlg:information) -message $msg(dlg:demoSave)
	  }
	  puts $file "    folders {$folders}"
	  puts $file ""
	  # nom et infos sur les couples et les écoles
	  foreach c [lsort -real $event(couples)] {
		  puts $file "    name:$c [list $event(name:$c)]"
		  puts $file "    school:$c [list $event(school:$c)]"
	  }
	  foreach j [lsort $event(judges)] {
		  puts $file "    name:$j [list $event(name:$j)]"
	  }
	  puts $file ""
	  # titre, commentaires, date, ... (dans general:*)
	  foreach n [lsort [array names event general:*]] {
		  puts $file "    $n [list $event($n)]"
	  }
	  syncAttributes
	  foreach n [lsort [array names event attributes:*]] {
		  puts $file "    $n [list $event($n)]"
	  }
	puts $file "\}\n\n"
	# sauve chaque dossier
	foreach folder $folders {
		io:saveDirty:folder $folder $file
	}
	# ferme le fichier
	close $file

	# retourne le nom de la sauvegarde
	return $real_filename
}

proc skating::io:saveDirty:folder {f file} {
variable $f
upvar 0 $f folder

	puts $file "[list $f] \{"
	foreach n [array names folder] {
		if {[string range $n 0 1] == "t:" || [string range $n 0 3] == "prt:"} {
			continue
		}
		puts $file "    [list $n] [list $folder($n)]"
	}
	puts $file "\}\n"

	# en dix-danses, appels récursive pour chaque danse
	if {$folder(mode) == "ten"} {
		foreach dance $folder(dances) {
			io:saveDirty:folder $f.$dance $file
		}
	}
}

#----------------------------------------------------------------------------------------------

proc skating::io:save {filename} {
global msg
variable event

	# ouvre le fichier
	if {[catch {set file [open $filename "w"]} errStr]} {
		if {![file writable [file dirname $filename]]} {
			tk_messageBox -icon "error" -type ok -default ok \
					-title $msg(dlg:cannotWrite) -message [format $msg(dlg:cannotWrite) $filename]
		} else {
			tk_messageBox -icon "error" -type ok -default ok \
					-title $msg(dlg:error) -message "$msg(dlg:cantSave) '$filename'.\n\n($errStr)"
		}
		return
	}

	# force la sauvegarde en utf-8
	fconfigure $file -encoding utf-8 -translation cr

	# partie commune dance event
	puts $file "event \{"
	  # version du format de fichier
	  puts $file "    version $::fileformatVersion\n"
	  # couples incrits
	  puts $file "    couples [list $event(couples)]"
	  # juges incrits
	  puts $file "    judges [list $event(judges)]"
	  # panels
	  puts $file "    panels [list $event(panels)]"
	  foreach panel $event(panels) {
		  puts $file "    panel:name:$panel [list $event(panel:name:$panel)]"
		  puts $file "    panel:judges:$panel [list $event(panel:judges:$panel)]"
	  }
	  # school vs country mode
	  puts $file "    useCountry [list $event(useCountry)]"
	  # folders  --  1 seulement pour version démo
	  set folders $event(folders)
	  if {[license check] == 0} {
		  set folders [lindex $folders 0]
		  tk_messageBox -icon "info" -type ok -default ok \
				  -title $msg(dlg:information) -message $msg(dlg:demoSave)
	  }
	  puts $file "    folders {$folders}"
	  puts $file ""
	  # nom et infos sur les couples et les écoles
	  foreach c [lsort -real $event(couples)] {
		  puts $file "    name:$c [list $event(name:$c)]"
		  puts $file "    school:$c [list $event(school:$c)]"
	  }
	  foreach j [lsort $event(judges)] {
		  puts $file "    name:$j [list $event(name:$j)]"
	  }
	  puts $file ""
	  # titre, commentaires, date, ... (dans general:*)
	  foreach n [lsort [array names event general:*]] {
		  puts $file "    $n [list $event($n)]"
	  }
	  syncAttributes
	  foreach n [lsort [array names event attributes:*]] {
		  puts $file "    $n [list $event($n)]"
	  }
	puts $file "\}\n\n"

	# sauve chaque dossier
	foreach folder $folders {
		io:save:folder $folder $file
	}
	# ferme le fichier
	close $file
}

proc skating::io:save:folder {f file} {
variable event
variable $f
upvar 0 $f folder

	#---- start
	puts $file "[list $f] \{"

	# label
	puts $file "    label [list $folder(label)]"
	# mode
	puts $file "    mode [list $folder(mode)]"
	# danses
	puts $file "    dances [list $folder(dances)]"
	# attributs associés à la danse
	foreach n [lsort [array names folder attributes:*]] {
		puts $file "    [list $n] [list $folder($n)]"
	}

	#---- mode dix danse = sauvegarde de chaque sous folder
	if {$folder(mode) == "ten"} {
		puts $file "\}\n"
		foreach dance $folder(dances) {
			io:save:folder $f.$dance $file
		}
		return

	} else {
		# rounds
		puts $file "    levels [list $folder(levels)]"
		puts $file "    round:generation [list $folder(round:generation)]"
		puts $file "    round:explicitNames [list $folder(round:explicitNames)]"
		puts $file "    round:use50%rule $folder(round:use50%rule)"
		foreach round $folder(levels) {
			if {[string first "." $round] != -1} {
				continue
			}
			puts $file "    round:$round:use [list $folder(round:$round:use)]"
			puts $file "    round:$round:split [list $folder(round:$round:split)]"
			foreach n [lsort [array names folder round:$round:nb*]] {
				puts $file "    [list $n] [list $folder($n)]"
			}
			foreach n [lsort [array names folder round:$round.2:nb*]] {
				puts $file "    [list $n] [list $folder($n)]"
			}
			puts $file "    round:$round:name [list $folder(round:$round:name)]"
			if {$folder(round:$round:split)} {
				puts $file "    round:$round.2:name [list $folder(round:$round.2:name)]"
			}
		}
		# danses pour chaque round
		foreach item [lsort -command skating::io:save:sort [array names folder dances:*]] {
			puts $file "    [list $item] [list $folder($item)]"
		}
		# commentaires
		foreach item [lsort -command skating::io:save:sort [array names folder comments:*]] {
			puts $file "    [list $item] [list [string trim $folder($item)]]"
		}
		# panels
		puts $file "    panels [list $folder(panels)]"
		# juges
		foreach item [lsort -command skating::io:save:sort [array names folder judges:*]] {
			puts $file "    [list $item] [list $folder($item)]"
		}
		# couples
		foreach item [lsort -command skating::io:save:sort [array names folder couples:*]] {
			puts $file "    [list $item] [list $folder($item)]"
		}
		# round de départ de chaque couple
		foreach item [lsort -command skating::io:save:sort [array names folder startIn:*]] {
			puts $file "    [list $item] [list $folder($item)]"
		}
		# exclusions
		foreach item [lsort -command skating::io:save:sort1 [array names folder exclusion:*]] {
			puts $file "    [list $item] [list $folder($item)]"
		}
		# heats (taille+type + couples)
		foreach item [lsort -command skating::io:save:sort1 [array names folder heats:*]] {
			puts $file "    [list $item] [list $folder($item)]"
		}

		# misc
		if {[info exists folder(splitpoints)]} {
			puts $file "    splitpoints [list $folder(splitpoints)]"
			puts $file "    subfolders [list $folder(subfolders)]"
		}

		# @OCM@
		if {[info exists folder(heatid)]} {
			puts $file "    heatid [list $folder(heatid)]"
		}


		# notes (rounds+finale)
			# HACK : clean-up of bad entries
			foreach item [array names folder notes:*] {
				if {[regexp {notes:.*:$} $item]} {
					unset folder($item)
				}
			}
		foreach item [lsort -command skating::io:save:sort2 [array names folder notes:*]] {
			if {[regexp {__1\d__} $item] == 0} {
				puts $file "    [list $item] [list $folder($item)]"
			}
		}
	}

	#---- end
	puts $file "\}\n"
}


array set skating::sorttable {
	names			0
	all				1
	requested		2

	finale			100
	prefinale.2		99
	prefinale		98

	semi.2			91
	semi			90
	quarter.2		81
	quarter			80
	eight.2			71
	eight			70
	16.2			61
	16				60
	32.2			51
	32				50
	64.2			41
	64				40
	128.2			31
	128				30

	qualif			10
}

proc skating::io:save:sort {a b} {
variable sorttable

	# xxxxxx:<round>(:<dance>)?
	regexp {[^:]*:([^:]*)(:([^:]*))?} $a {} aa {} da
	regexp {[^:]*:([^:]*)(:([^:]*))?} $b {} bb {} db
	if {$aa == $bb} {
		string compare $da $db
	} else {
		expr {$sorttable($aa) > $sorttable($bb)}
	}
}

proc skating::io:save:sort1 {a b} {
variable sorttable

	# exclusion:<round>:<dance>
  	scan $a {%[a-z]:%[a-z0-9.]:%s} dummy aa da
  	scan $b {%[a-z]:%[a-z0-9.]:%s} dummy bb db
	if {$aa == $bb} {
		string compare $da $db
	} else {
		expr $sorttable($aa) > $sorttable($bb)
	}
}

proc skating::io:save:sort2 {a b} {
variable sorttable

	# notes:<round>:<couple>:<dance>
	scan $a {%[a-z]:%[a-z0-9.]:%[0-9]:%s} dummy aa na da
	scan $b {%[a-z]:%[a-z0-9.]:%[0-9]:%s} dummy bb nb db
	if {$sorttable($aa) == $sorttable($bb)} {
		if {![info exists na]} {
			return 0
		}
		if {![info exists nb]} {
			return 1
		}
#  		if {$na == $nb} {
#  			return [string compare $da $db]
#  		} else {
#  			return [expr $na > $nb]
#  		}
		if {![info exists da] || ![info exists db]} {
			return 0
		}
		set result [string compare $da $db]
		if {$result == 0} {
			return [expr $na > $nb]
		} else {
			return $result
		}
	} else {
		return [expr $sorttable($aa) > $sorttable($bb)]
	}
}
