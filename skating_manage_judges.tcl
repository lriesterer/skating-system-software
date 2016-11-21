##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion de la selection des juges pour une competition
#
#=================================================================================================

proc skating::manage:judges:init {f} {
variable $f
upvar 0 $f folder
global msg
variable gui
variable event


	set w [NoteBook::getframe $gui(w:notebook) "judges"]

	# se détruit pour mise à jour (appel lors d'un raise pour prise en compte changement
	# dans le nombre de couples et les rounds)
	foreach win [winfo children $w] {
		destroy $win
	}

	# titre de la fenêtre
	set h [expr [font metrics "canvas:label" -linespace]+6]
	set title [canvas $w.t -height $h -bg [$w cget -bg] -highlightthickness 0]
	set gui(w:titleJudges) $title
	pack [frame $w.sep1 -height 5] $title -side top -anchor w

	# liste des juges
	set sw [ScrolledWindow::create $w.sw \
					-scrollbar both -auto both -relief sunken -borderwidth 1]
	set list [canvas [ScrolledWindow::getframe $sw].c -bg gray95 -highlightthickness 0 \
					-yscrollincrement 16 -height 1]
	set gui(w:listJudges) $list
	ScrolledWindow::setwidget $sw $list
	pack $sw -side top -expand true -fill both
		# binding pour scrolling des canvas
		bind $list <Configure> "skating::manage:judges:adjustScrolling %w %h"
		bind $list <Visibility> "focus $list"
		bind $list <Up> "$list yview scroll -1 units"
		bind $list <Down> "$list yview scroll +1 units"
		bind $list <Prior> "$list yview scroll -1 pages"
		bind $list <Next> "$list yview scroll +1 pages"
		bind $list <Left> "$list xview scroll -1 units; $title xview scroll -1 units"
		bind $list <Right> "$list xview scroll +1 units; $title xview scroll +1 units"
		bind $list <Home> "$list xview scroll -1 pages; $title xview scroll -1 pages"
		bind $list <End> "$list xview scroll +1 pages; $title xview scroll +1 pages"

	# paramètres graphiques
	set start 300
	set width 30

	# construit le titre
#	set id [$title create text 5 [expr $h/2] -anchor w -text $msg(name) -font canvas:label]
	set i 0
	foreach level $folder(levels) {
		$title create rectangle [expr $start+$i*$width] 0 \
				[expr $start+($i+1)*$width] $h  -tags "hr:$level h:$level" \
				-fill $gui(color:colselected) -outline black
		$title create text [expr $start+($i+0.5)*$width] [expr $h/2] -font canvas:label \
				-text [rounds:getShortName $f $level] -tags "h:$level"
		$title bind "h:$level" <1> "skating::manage:judges:level $title $list $level"
		incr i
		set gui(t:active:level:$level) 1
	}
	# boutons Deselectionner tous/Aucun/Tous
	button $title.deselect -text $msg(deselectAll) -bd 1 -padx 0 -pady 0 \
			-command "skating::manage:judges:deselectAll [list $f]"
#	$title create window [expr {[lindex [$title bbox $id] 2]+5}] 0 -anchor nw -window $title.deselect
	$title create window 2 0 -anchor nw -window $title.deselect
	button $title.none -text $msg(none) -bd 1 -padx 0 -pady 0 \
			-command "skating::manage:judges:multilevel [list $f] $title $list none"
	$title create window $start 0 -anchor ne -window $title.none
	button $title.all -text $msg(all) -bd 1 -padx 0 -pady 0 \
			-command "skating::manage:judges:multilevel [list $f] $title $list all"
	$title create window [expr $start+$i*$width+1] 0 -anchor nw -window $title.all


	#---- en bas, quick entry par les panels
	if {[llength $event(panels)]} {
		set panel [TitleFrame::create $w.p -text $msg(selectByPanel)]
		set path0 [TitleFrame::getframe $panel]

		set path1 [ScrolledWindow::create $path0.sw -scrollbar vertical -auto both -borderwidth 0]
		set path2 [ScrolledWindow::getframe $path1]
		set path3 [canvas $path2.c -bd 0]
		set path [frame $path2.f -bd 0]
		set gui(w:t:pathToPanelsButtons) $path
		$path3 create window 0 0 -anchor nw -window $path
		ScrolledWindow::setwidget $path1 $path3
		pack $path0.sw -fill both

		set i 0
		set j 1
		foreach panel $event(panels) {
			# nom du panel
			label $path.$i -text "$event(panel:name:$panel)"
			grid configure $path.$i -row $i -column 0 -padx 1 -pady 1 -sticky wns
			# boutons pour selection rapide
			set j 1
			foreach level "all $folder(levels)" {
				set b [button $path.$i-$j -relief raised -text [rounds:getShortName $f $level] \
							-bd 1 -width 7 -padx 1 -pady 1 \
							-command "skating::manage:judges:selectPanel [list $f] $panel $level 1"]
				# montre les juges composants le panel
				bind $b <Enter> "foreach judge [list $event(panel:judges:$panel)] {$list raise flash:\$judge:$level}"
				bind $b <Leave> "$list lower flash"
				grid configure $b -row $i -column $j -padx [expr {$j==1 ? 15 : 1}] -pady 1
				incr j
			}
			# couleur de la ligne de boutons
			manage:judges:panel:buttonLineColor $f $panel
			# panel suivant
			incr i
		}
		grid columnconfigure $path {0} -weight 1
		grid columnconfigure $path [list $j] -weight 10
		pack [frame $w.sep -height 5] $w.p -side top -fill both

		# pour le scrolling si panels trop nombreux (on accorde jusqu'à la moitié de l'écran)
		update idletasks
		set wanted [winfo reqheight $path]
		set total [winfo reqheight $w]
		if {$wanted < $total/2} {
			$path3 configure -height $wanted
		} else {
			$path3 configure -height [expr {$total/2}]
		}
		$path3 configure -scrollregion [list 0 0 1 $wanted]
	}

	#==== init
	# affiche les juges sélectionnés
	manage:judges:display $f

	# init sélection clavier
	fastentry:mode init:judges
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:judges:display {f} {
variable gui
variable event
variable $f
upvar 0 $f folder
upvar start start width width

#TRACEF

	set c $gui(w:listJudges)
	# efface le canvas
	$c delete all
	# paramètres
	set left 5
	set h [expr int(1.2*[font metrics "canvas:couple" -linespace])]
   	# affiche les juges
	set y 0
	set i 0
	foreach judge $event(judges) {
		manage:judges:displayOneJudge $c $f $judge $i
		incr i
	}
	# cache les "flash"
	$c lower flash
}

proc skating::manage:judges:displayOneJudge {c f judge index} {
variable $f
upvar 0 $f folder
variable event
variable gui
upvar left left h h y y start start width width

#TRACEF

	# nom du juge
	set text "$judge"
	if {$event(name:$judge) != ""} {
		append text " ($event(name:$judge))"
	}
	set id [$c create text $left [expr $y+1] -anchor nw -fill $gui(color:notselected) \
			-text $text -tags "j:$judge" -font canvas:label]
	$c bind $id <1> "skating::manage:judges:toggleJudge [list $f] $judge ALL 1"

	# cases pour la sélection
	set i 0
	set x [expr $start-1]
	set y2 [expr $y + $h]
	set gui(t:active:judge:$judge) {}
	foreach level $folder(levels) {
		$c create rectangle $x $y [expr $x+$width] $y2 \
				-fill $gui(color:colselected) -outline black -tags "rr:$level"
		# cherche si juge utilisé dans level
		if {[lsearch -exact $folder(judges:$level) $judge] == -1} {
			set color $gui(color:colselected)
			set tag "r:$level"
		} else {
			set color $gui(color:choosengood)
			set tag ""
			$c itemconfigure "j:$judge" -fill $gui(color:selected)
			lappend gui(t:active:judge:$judge) $level
		}
		# boite pour le click de sélection
		$c create rectangle [expr $x+4] [expr $y+4] [expr $x+$width-4] [expr $y2-4] \
				-fill $color -outline $color \
				-tags "$tag b:$judge:$level"
		$c bind b:$judge:$level <1> \
				"skating::manage:judges:toggleJudge [list $f] $judge $level 1"
		# boite pour le flashing
		$c create rectangle [expr $x+2] [expr $y+2] [expr $x+$width-2] [expr $y2-2] \
				-width 3 -outline $gui(color:flash) -tags "flash flash:$judge:all flash:$judge:$level"
		# suivant
		incr x $width
		incr i
	}

	# affiche comme sélectionné si requis
	if {[lsearch $folder(judges:requested) $judge] != -1} {
		$c itemconfigure "j:$judge" -fill $gui(color:selected)
	}

	incr y $h
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:judges:adjustScrolling {w h} {
variable gui

	set c $gui(w:listJudges)
	# ajuste scrollregion
	set x [lindex [$c bbox all] 2]
	set y [lindex [$c bbox all] 3]
	if {$x < $w} {
		set x $w
	} else {
		# ajoute taille du bouton dans le titre
		incr x 40
	}
	if {$y < $h} {
		set y $h
	}
	$c configure -scrollregion [list 0 0 $x $y]
	$gui(w:titleJudges) configure -width $w -scrollregion [list 0 0 $x 0]
}

#-------------------------------------------------------------------------------------------------
#	updateMode flags = 0x01 ---> mise à jour GUI
#	                   0x02 ---> effacement des choix de panels

proc skating::manage:judges:toggleJudge {f judge level updateMode {newstate -1} {check 1}} {
variable $f
upvar 0 $f folder
variable gui

TRACEF "newstate = $newstate"

	# récupère le canvas
	if {$updateMode & 1} {
		set c $gui(w:listJudges)
	} else {
		foreach l $folder(levels) {
			set gui(t:active:level:$l) 1
		}
		set gui(t:active:judge:$judge) {}
	}

	#---- on traite le toggle : toute la ligne ou juste une case
	set askedLevel $level
	if {[string tolower $level] == "all"} {
		#-------------------------
		# toute la ligne à changer
		set activate 0
		foreach level $folder(levels) {
			if {$askedLevel == "all" || $gui(t:active:level:$level)} {
				if {[lsearch $gui(t:active:judge:$judge) $level] == -1} {
					# si un manque, on active tout
					set activate 1
					break
				}
			}
		}
		# si aucun round, on le rajoute dans la liste des requis
		if {[llength $folder(levels)] == 0} {
			if {[lsearch $folder(judges:requested) $judge] == -1} {
				set activate 1
			} else {
				set activate 0
			}
		}
		# utilise le choix de l'utilisateur si demandé
		if {$newstate != -1} {
			set activate $newstate
		}
TRACE "activate = $activate"
		# do it
		foreach level $folder(levels) {
			if {$askedLevel == "all" || $gui(t:active:level:$level)} {
				# demande confirmation si modification
				if {$check && ([skating::manage:judges:check $f $level] == 0)} {
					return
				}
				manage:judges:toggleJudge $f $judge $level \
										  $updateMode $activate 0
			}
		}
		# un juge coché ON via Event/Judges doit être mémorisé pour
		# un ajustement ultérieur automatique

		# HACK : suppression de ( || [llength $folder(levels)] == 0)
		#		 après activate. Utilité ????
		set forceChangeColor 0
		if {[set index [lsearch $folder(judges:requested) $judge]] == -1
					&& ($activate == 1)} {
			lappend folder(judges:requested) $judge
TRACE "folder(judges:requested) / activate / $folder(judges:requested)"
		} elseif {1 || [llength $folder(levels)] != 0} {
			set folder(judges:requested) [lreplace $folder(judges:requested) $index $index]
TRACE "folder(judges:requested) / desactivate / $folder(judges:requested) / $index"
			set forceChangeColor 1
		}
		# autorise la sélection d'un juge (mode requis) même si pas de rounds
		if {($updateMode & 1) && ([llength $folder(levels)] == 0 || $forceChangeColor)} {
			if {[lsearch $folder(judges:requested) $judge] != -1} {
				set color $gui(color:selected)
			} else {
				set color $gui(color:notselected)
			}
TRACE "color = $color"
			$c itemconfigure "j:$judge" -fill $color
		}
	} else {
		# -----------------------
		# choix direct d'une case

		# demande confirmation si modification
		if {$check && ([skating::manage:judges:check $f $level] == 0)} {
			return
		}

		set index [lsearch $folder(judges:$level) $judge]
		set state [expr {$index==-1 ? 0 : 1}]
		if {$state == $newstate} {
			return
		}
		if {$state == 1} {
#TRACE "$judge $level $newstate :: ON --> OFF"
			# ON --> OFF
			set folder(judges:$level) [lreplace $folder(judges:$level) $index $index]
			set i [lsearch $gui(t:active:judge:$judge) $level]
			set gui(t:active:judge:$judge) [lreplace $gui(t:active:judge:$judge) $i $i]

			if {$updateMode & 1} {
				if {$gui(t:active:level:$level)} {
					set color $gui(color:colselected)
				} else {
					set color [$c cget -bg]
				}
				$c itemconfigure "b:$judge:$level" -fill $color -outline $color
				$c addtag "r:$level" withtag "b:$judge:$level"
			}

		} else {
#TRACE "$judge $level $newstate :: OFF --> ON"
			# OFF --> ON
			lappend folder(judges:$level) $judge
			lappend gui(t:active:judge:$judge) $level

			if {$updateMode & 1} {
				$c itemconfigure "b:$judge:$level" -fill $gui(color:choosengood) \
						-outline $gui(color:choosengood)
				$c dtag "b:$judge:$level" "r:$level"
			}
		}

		# couleur du texte du nom du juge
		if {$updateMode & 1} {
			if {[llength $gui(t:active:judge:$judge)] || [lsearch $folder(judges:requested) $judge] != -1} {
				set color $gui(color:selected)
			} else {
				set color $gui(color:notselected)
			}
			$c itemconfigure "j:$judge" -fill $color
		}

		# choix direct annule la mémorisation de préselection
		set index [lsearch $folder(judges:requested) $judge]
		if {$index != -1 && [llength $folder(levels)] != 0} {
			set folder(judges:requested) [lreplace $folder(judges:requested) $index $index]
		}
	}

#parray folder judges:*
	# mise à jour des onglets si 10-danses
	if {($updateMode & 1) && $check && [string first "." $f] != -1} {
		ten:rounds:check $f $gui(v:dance)
	}

	# effacement de choix de panels
	if {($updateMode & 2) == 0 && ($updateMode & 1)} {
		variable event
		set folder(panels) [list ]
		foreach panel $event(panels) {
			manage:judges:panel:buttonLineColor $f $panel
		}
	}
}


#-------------------------------------------------------------------------------------------------

proc skating::manage:judges:multilevel {f title list mode} {
variable gui
variable $f
upvar 0 $f folder


	if {$mode == "none"} {
		# tous OFF
		foreach level $folder(levels) {
			if {$gui(t:active:level:$level)} {
				manage:judges:level $title $list $level
			}
		}
	} else {
		# tous ON
		foreach level $folder(levels) {
			if {!$gui(t:active:level:$level)} {
				manage:judges:level $title $list $level
			}
		}
	}
}

proc skating::manage:judges:level {title list level} {
variable gui


	if {$gui(t:active:level:$level)} {
		# désactivation
		set new 0
		$title itemconfigure "hr:$level" -fill [$title cget -bg]
		$list itemconfigure "rr:$level" -fill [$list cget -bg]
		$list itemconfigure "r:$level" -fill [$list cget -bg] -outline [$list cget -bg]
	} else {
		# activation
		set new 1
		$title itemconfigure "hr:$level" -fill $gui(color:colselected)
		$list itemconfigure "rr:$level" -fill $gui(color:colselected)
		$list itemconfigure "r:$level" -fill $gui(color:colselected) \
				-outline $gui(color:colselected)
	}
	# enregistre nouvel état
	set gui(t:active:level:$level) $new
}

proc skating::manage:judges:deselectAll {f} {
variable $f
upvar 0 $f folder
variable event

	# déselectionne les juges
	foreach judge $event(judges) {
		manage:judges:toggleJudge $f $judge all 1 0
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:judges:isSelected {f judge} {
variable $f
upvar 0 $f folder

#TRACEF
	# liste des compétitions à tester
	if {$folder(mode) == "ten"} {
		foreach dance $folder(dances) {
			lappend listFolders $f.$dance
		}
	} else {
		set listFolders [list $f]
	}

	# cherche état : ON/PARTIAL/OFF
	set state ""
	foreach ff $listFolders {
		variable $ff
		upvar 0 $ff folder

		set nb 0
		foreach l $folder(levels) {
			foreach j $folder(judges:$l) {
				if {$j == $judge} {
					incr nb
					break
				}
			}
		}

		if {$nb == 0} {
			if {[lsearch $folder(judges:requested) $judge] == -1} {
				# 			-> OFF
				# OFF & OFF -> OFF
				# OFF & ON  -> PARTIAL
				if {$state == ""} {
					set state OFF
				} elseif {$state != "OFF"} {
					return PARTIAL
				}
			} else {
				# 			-> ON
				# ON  & ON  -> ON
				# ON  & OFF -> PARTIAL
				if {$state == ""} {
					set state ON
				} elseif {$state != "ON"} {
					return PARTIAL
				}
			}
		} elseif {$nb == [llength $folder(levels)]} {
			# 			-> ON
			# ON  & ON  -> ON
			# ON  & OFF -> PARTIAL
			if {$state == ""} {
				set state ON
			} elseif {$state != "ON"} {
				return PARTIAL
			}
		} else {
			return PARTIAL
		}
	}

	return $state
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:judges:check {f level} {
variable $f
upvar 0 $f folder
variable gui
global msg


#TRACEF

	# check si notes déjà attribuées
	if {$level == "all"} {
		set exists [llength [array names folder notes:*]]
		set levels $folder(levels)
	} else {
		set notes 0
		foreach item [array names folder notes:$level:*] {
			foreach n $folder($item) {
				incr notes $n
			}
		}
		set exists [expr $notes > 0]
		set levels $level
	}

	if {$exists} {
		set doit [tk_messageBox -icon "question" -type yesno -default yes \
							-title $msg(dlg:question) -message $msg(dlg:judgesReinit)]
		if {$doit == "no"} {
			return 0
		}
	}

	# modifications ...
	set gui(v:modified) 1
	# efface les données
	foreach level $levels {
		set notFirst 0
		set idx [lsearch $folder(levels) $level]
		foreach level [lrange $folder(levels) $idx end] {
			# les notes/sélection
			foreach n [array names folder notes:$level:*] {
TRACEF "unsetting $n"
				unset folder($n)
			}
			# résultats
			foreach n [array names folder result:$level] {
				unset folder($n)
			}
			catch { unset folder(result) }
			# les couples sélectionnés (sauf pour le round en cours)
			if {$notFirst && [info exists folder(couples:$level)]} {
				unset folder(couples:$level)
			}
			set notFirst 1
		}
	}
	# ajuste Tree
	manage:rounds:adjustTreeColor $f

	return 1
}

#=================================================================================================
#
#	Gestion des panels
#
#=================================================================================================

proc skating::manage:judges:selectPanel {f panel level updateGUI} {
variable event
variable gui
variable $f
upvar 0 $f folder

	# vérification et demande de confirmation si influence sur les notes
	if {![manage:judges:check $f $level]} {
		return
	}
	# désélectionne tous les juges ...
	foreach judge $event(judges) {
		manage:judges:toggleJudge $f $judge $level \
				[expr 2 | $updateGUI] 0 0
	}
	# ... puis sélectionne
	foreach judge $event(panel:judges:$panel) {
		manage:judges:toggleJudge $f $judge $level \
				[expr 2 | $updateGUI] 1 0
	}

	# on mémorise le choix du panel
	while {[llength $folder(panels)] <= [llength $event(panels)]} {
		lappend folder(panels) ""
	}
	if {$level == "all"} {
		set folder(panels) [lreplace $folder(panels) $panel $panel "all"]
		set folder(judges:requested) $event(panel:judges:$panel)
	} else {
		set levels [lindex $folder(panels) $panel]
		if {$levels == "all"} {
			set levels ""
		}
TRACE "old levels = $levels"
		if {[lsearch $levels $level] == -1} {
			lappend levels $level
			set folder(panels) [lreplace $folder(panels) $panel $panel $levels]
		}
TRACE "after $folder(panels)"
	}
	# couleur du bouton = mise à jour de toute la ligne
	foreach p $event(panels) {
		# si conflit, gère mutuelle exclusion
		if {$p != $panel} {
			set old [lindex $folder(panels) $p]
			if {$level == "all"} {
TRACE "level all"
				# nouveau == ALL --> reset all
				set new ""
			} elseif {$old == "all"} {
				# ancien == ALL --> on garde tout sauf le round
TRACE "ancien all"
				set new [list ]
				foreach l $folder(levels) {
					if {$l != $level} {
						lappend new $l
					}
				}
			} elseif {[set index [lsearch $old $level]] != -1} {
				# ancien contient nouveau --> on retire
TRACE "conflit"
				set new [lreplace $old $index $index]
			} else {
TRACE "else"
				# nouveau et ancien disjoint, OK
				set new $old
			}
			set folder(panels) [lreplace $folder(panels) $p $p $new]
		}
		# colorise
		if {$updateGUI} {
			manage:judges:panel:buttonLineColor $f $p
		}
	}

	# mise à jour des onglets si 10-danses
	if {[string first "." $f] != -1 && [info exists gui(v:dance)]} {
		ten:rounds:check $f $gui(v:dance)
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:judges:panel:buttonLineColor {f panel} {
variable $f
upvar 0 $f folder
variable gui
variable event

#TRACEF "panels = $folder(panels)"

	set path $gui(w:t:pathToPanelsButtons)
	# couleurs (vert si actif, gris normal sinon)
	set i [lsearch $event(panels) $panel]
	set j 1
	foreach level "all $folder(levels)" {
		set levels [lindex $folder(panels) $panel]
		if {$levels == "all" || [lsearch $levels $level] != -1} {
#TRACE "coloring $level with $gui(color:exclusion:on:bg)/$gui(color:exclusion:on:abg)"
			$path.$i-$j configure -background $gui(color:exclusion:on:bg) \
						-activebackground $gui(color:exclusion:on:abg) \
						-relief sunken
		} else {
			$path.$i-$j configure -background $::bg -activebackground $::abg \
						-relief raised
		}
		# bouton suivant
		incr j
	}
}