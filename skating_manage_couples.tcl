##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion de la selection des couples pour une competition
#
#=================================================================================================

proc skating::manage:couples:init {folder w} {
global msg
variable gui
variable event


	set gui(v:folder) $folder

	# liste pour des couples
	set sw [ScrolledWindow::create $w.sw \
					-scrollbar both -auto horizontal -relief sunken -borderwidth 1]
	set list [ListBox::create [ScrolledWindow::getframe $sw].lb \
						-bg gray95 -relief flat -borderwidth 0 \
						-width 20 -height 1 -deltay 20 -padx 20 \
						-highlightthickness 0 -multicolumn false \
						-beforewidth 0 -beforecolor blue]
	set gui(w:listCouples) $list
	ScrolledWindow::setwidget $sw $list
		# binding pour scrolling des canvas
		bind $list <Visibility> "focus $list"
		bind $list <Enter> "focus $list"

	# nombre de couples sélectionnés
	global __nbCouples
	set __nbCouples ""
	set tf [TitleFrame::create $w.nb -text $msg(selection)]
	set sub [TitleFrame::getframe $tf]
	label $sub.nb -width 22 -textvariable __nbCouples -anchor w
	pack $sub.nb -side left

	# saisie rapide / copie à partir de (10-danses)
	if {[string first "." $folder] != -1} {
		set tf [TitleFrame::create $w.q -text $msg(copyFrom)]
		set sub [TitleFrame::getframe $tf]
		menubutton $sub.b -menu $sub.b.m -width 22 -relief raised -bd 1 \
				-indicator on -text $msg(sameAs) -anchor w -font normal
		set m [menu $sub.b.m -bd 1 -tearoff 0]
			foreach {f d} [split $folder "."] break
			variable $f
			upvar 0 $f topfolder
			foreach dance $topfolder(dances) {
				if {$dance != $d} {
					$m add command -label $dance \
						-command "skating::manage:couples:sameAs [list $f.$dance]"
				}
			}
		pack $sub.b -side left
	} else {
		set tf [TitleFrame::create $w.q -text $msg(input)]
		set sub [TitleFrame::getframe $tf]
		button $sub.a -width 5 -text $msg(all) -bd 1 -command "skating::manage:couples:quick all"
		button $sub.n -width 5 -text $msg(none) -bd 1 -command "skating::manage:couples:quick none"
		pack $sub.a $sub.n -side left
	}

	# critère de tri pour l'affichage
	global __sortCouples
	set tf [TitleFrame::create $w.sort -text $msg(sortby)]
	set sub [TitleFrame::getframe $tf]
	if {$event(useCountry)} {
		set text $msg(sortby:country)
	} else {
		set text $msg(sortby:school)
	}
	foreach b {nb name school} \
			text [list $msg(sortby:number) $msg(sortby:name) $text] {
		radiobutton $sub.$b -text $text \
				-variable __sortCouples -value $b -bd 1 \
				-command "skating::manage:couples:set"
		pack $sub.$b -side left
	}

	# mise en page
	pack $sw -side top -pady 5 -expand true -fill both
	pack $w.nb -side left -expand true -fill both -padx 5
	pack $w.q $w.sort -side left -fill both -padx 5

	set nb [llength [set ::skating::${folder}(couples:names)]]
	set total [llength $event(couples)]
	if {$total > 100} {
		# force une mise à jour
		waitDialog:open $msg(dlg:pleaseWait)
		# initialise les couples sélectionnés / affiche les couples
		$sub.nb invoke
		manage:couples:nbCouples $nb
		waitDialog:close
	} else {
		$sub.nb invoke;
		manage:couples:nbCouples $nb
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:couples:set {} {
variable gui
set f $gui(v:folder)
variable $f
upvar 0 $f folder
upvar 0 ::skating::${f}(couples:names) selected
variable event
global msg

TRACEF

	set list $gui(w:listCouples)

	# memorise ancien scrolling
	set oldScroll [$list yview]
#TRACEF "oldScroll = $oldScroll"

	# cherche si on doit réserve un affichage pour les rounds
	set max [list ]
	foreach round [lrange $folder(levels) 1 end] {
		if {[info exists folder(startIn:$round)] &&
					[llength $folder(startIn:$round)]} {
			lappend max "<$msg(round:short:$round)>"
		}
	}
	ListBox::configure $list -beforewidth [ListBox::measure $list $max]

	# efface les éléments
	ListBox::delete $list [ListBox::items $list]
	# trie les couples à afficher
	set all [lsort -command skating::manage:couples:sort $event(couples)]

	# initialise le tableau
	set in10dances [expr {[string first "." $f] != -1}]
#TRACE "in10dances = $in10dances / $f"
	set nav [list ]
	foreach v $all {
		# en cas 10-danses, n'affiche pas les alias
		if {$in10dances && $v != [expr {int($v)}]} {
#TRACE "    skipping $v"
			continue
		}
		lappend nav $v
		# collecte les informations
		if {$event(name:$v) != "" && $event(school:$v) != ""} {
			set text "$v - $event(name:$v), $event(school:$v)"
		} elseif {$event(name:$v) != ""} {
			set text "$v - $event(name:$v)"
		} else {
			set text "$v"
		}

		set start $msg(round:short:[manage:couples:startRound:get $f $v 1])

		# crée le couple dans la listbox
		if {[lsearch $selected $v] == -1} {
			ListBox::insert $list end $v -text $text -image imgNOK \
					-fill $gui(color:notselected)
		} else {
			ListBox::insert $list end $v -text $text -image imgOK -before $start
		}
	}
	# callback pour maintenir la sélection
	ListBox::bindText $list <ButtonPress-1> \
			"skating::manage:couples:toggle"
	ListBox::bindImage $list <ButtonPress-1> \
			"skating::manage:couples:toggle"
	# callback pour choix round de départ
	ListBox::bindText $list <ButtonPress-3> \
			"skating::manage:couples:startRound:choose %X %Y"
	ListBox::bindImage $list <ButtonPress-3> \
			"skating::manage:couples:startRound:choose %X %Y"


	# pour la navigation à l'aide du clavier
	ListBox::configure $list -selectbackground $gui(color:selection)
	set gui(t:nav:all) $nav
	set gui(t:nav:selected) [list ]
	set gui(t:nav:current) -1
	set gui(t:nav:anchor) 0
	# up / down
	bind $list <Up> "skating::manage:couples:keyboard $list 0 -1 0; break"
	bind $list <Down> "skating::manage:couples:keyboard $list 0 +1 0; break"
	bind $list <Shift-Up> "skating::manage:couples:keyboard $list 0 -1 1; break"
	bind $list <Shift-Down> "skating::manage:couples:keyboard $list 0 +1 1; break"
	bind $list <Prior> "skating::manage:couples:keyboard $list 0 -10 0; break"
	bind $list <Next> "skating::manage:couples:keyboard $list 0 +10 0; break"
	bind $list <Shift-Prior> "skating::manage:couples:keyboard $list 0 -10 1; break"
	bind $list <Shift-Next> "skating::manage:couples:keyboard $list 0 +10 1; break"
	# home / end
	bind $list <Home> "skating::manage:couples:keyboard $list 0 -100000 0; break"
	bind $list <End> "skating::manage:couples:keyboard $list 0 +100000 0; break"
	bind $list <Shift-Home> "skating::manage:couples:keyboard $list 0 -100000 1; break"
	bind $list <Shift-End> "skating::manage:couples:keyboard $list 0 +100000 1; break"
#  	# left / right
#  	bind $list <Left> "skating::manage:couples:keyboard $list -1 0 0; break"
#  	bind $list <Right> "skating::manage:couples:keyboard $list +1 0 0; break"
#  	bind $list <Shift-Left> "skating::manage:couples:keyboard $list -1 0 1; break"
#  	bind $list <Shift-Right> "skating::manage:couples:keyboard $list +1 0 1; break"
#  	# home / end
#  	bind $list <Home> "skating::manage:couples:keyboard $list -100000 0 0; break"
#  	bind $list <End> "skating::manage:couples:keyboard $list +100000 0 0; break"
#  	bind $list <Shift-Home> "skating::manage:couples:keyboard $list -100000 0 1; break"
#  	bind $list <Shift-End> "skating::manage:couples:keyboard $list +100000 0 1; break"

	# select & escape
	foreach k {<space> <Return> <comma> <period> <KP_Enter>} {
		bind $list $k "skating::manage:couples:keyboard:toggle $list"
	}
	if {$::tcl_platform(platform) != "windows"} {
		bind $list <KP_Delete> "skating::manage:couples:keyboard:toggle $list"
	}
	bind $list <Escape> "skating::fastentry:mode init:couples; \
						 ListBox::selection $list clear; \
						 set skating::gui(t:nav:selected) [list ]; \
						 set skating::gui(t:nav:current) -1; \
						 set skating::gui(t:nav:anchor) 0"

	# restaure le scrolling
	$list yview moveto [lindex $oldScroll 0]
}

proc skating::manage:couples:keyboard {list dx dy extend} {
variable gui

	# inhibe fastentry
	fastentry:mode ""

	set old $gui(t:nav:current)
	set side ""
	if {$dy == 0} {
		if {$gui(t:nav:current) == -1} {
			set dy 1
		} else {
			set dy [expr {$dx * [ListBox::nbRows $list]}]
		}
	}
	if {$dy == 10} {
		set dy [ListBox::nbRows $list]
	} elseif {$dy == -10} {
		set dy [expr {-1*[ListBox::nbRows $list]}]
	}

	# vers le bas
	if {$dy > 0 && ($gui(t:nav:current) < [llength $gui(t:nav:all)]-1)} {
		set side right
		incr gui(t:nav:current) $dy
		if {$gui(t:nav:current) > [llength $gui(t:nav:all)]-1} {
			set gui(t:nav:current) [expr {[llength $gui(t:nav:all)]-1}]
		}
#TRACE ">>>> UP / $old -> $gui(t:nav:current) / [expr {$gui(t:nav:current)-$old}]"
		# sélection ?
		if {!$extend || $gui(t:nav:current) == $gui(t:nav:anchor)} {
			set gui(t:nav:selected) [lindex $gui(t:nav:all) $gui(t:nav:current)]
			set gui(t:nav:anchor) $gui(t:nav:current)
		} elseif {$gui(t:nav:current) < $gui(t:nav:anchor)} {
			set gui(t:nav:selected) [lrange $gui(t:nav:selected) 0 end-[expr {$gui(t:nav:current)-$old}]]
		} else {
			incr old
			while {$old <= $gui(t:nav:current)} {
				lappend gui(t:nav:selected) [lindex $gui(t:nav:all) $old]
				incr old
			}
		}
	}

	# vers le haut
	if {$dy < 0 && ($gui(t:nav:current) > 0)} {
		set side left
		incr gui(t:nav:current) $dy
		if {$gui(t:nav:current) < 0} {
			set gui(t:nav:current) 0
		}
#TRACE ">>>> DOWN / $gui(t:nav:current) -> $old / [expr {$old-$gui(t:nav:current)}]"
		# sélection ?
		if {!$extend || $gui(t:nav:current) == $gui(t:nav:anchor)} {
			set gui(t:nav:selected) [lindex $gui(t:nav:all) $gui(t:nav:current)]
			set gui(t:nav:anchor) $gui(t:nav:current)
		} elseif {$gui(t:nav:current) < $gui(t:nav:anchor)} {
			incr old -1
			while {$old >= $gui(t:nav:current)} {
				lappend gui(t:nav:selected) [lindex $gui(t:nav:all) $old]
				incr old -1
			}
		} else {
			set gui(t:nav:selected) [lrange $gui(t:nav:selected) 0 end-[expr {$old-$gui(t:nav:current)}]]
		}
	}

#TRACE "skating::manage:couples:keyboard {list $dx $dy $extend} / after / $gui(t:nav:selected)"
	if {$side != ""} {
		ListBox::selection $list set $gui(t:nav:selected)
#  		ListBox::see $list [lindex $gui(t:nav:selected) end] $side
		ListBox::see $list [lindex $gui(t:nav:selected) end] left
	}
}

proc skating::manage:couples:keyboard:toggle {list} {
variable gui
set f $gui(v:folder)
variable $f
upvar 0 $f folder
upvar 0 ::skating::${f}(couples:names) selected
variable event


	# si pas de sélection, on laisse passer la touche pour fastentry
	if {$gui(t:nav:current) == -1} {
		return
	}

#TRACE "skating::manage:couples:keyboard:toggle / $gui(t:nav:selected)"
	# vérifie si l'on peut modifier
	if {[manage:couples:checkCouples $gui(t:nav:selected)] == 0} {
		return
	}
	#---- pour chaque couple
	foreach couple $gui(t:nav:selected) {
		# toggle de la sélection & mise à jour de la variable associée
		set list $gui(w:listCouples)
		set index [lsearch $selected $couple]
		if {$index == -1} {
			# autorise seulement un couple lors des aliasing
			set stem [expr {int($couple)}]
			if {[lsearch $folder(couples:all) $stem] != -1} {
				bell
				continue
			}
			ListBox::itemconfigure $list $couple -image imgOK -fill $gui(color:selected)
			lappend selected $couple
			set selected [lsort -real $selected]
			set folder(couples:all) [names2number $selected]
		} else {
			ListBox::itemconfigure $list $couple -image imgNOK -fill $gui(color:notselected)
			set selected [lreplace $selected $index $index]
			set folder(couples:all) [names2number $selected]
		}
	}

	# nombre de couples sélectionnés
	skating::manage:couples:nbCouples [llength $selected]
}

#----------------------------------------------------------------------------------------------

proc skating::manage:couples:sort {a b} {
global __sortCouples
variable event

	# comparaison chaine pour tri par nom ou école/club
	if {$__sortCouples != "nb"} {
		set test [string compare \
						[string tolower $event($__sortCouples:$a)] \
						[string tolower $event($__sortCouples:$b)] ]
		if {$test != 0} {
			return $test
		}
	}
	# tri par numéro ou égalité dans la comparaison de chaines
	if {$a > $b} {
		return 1
	} elseif {$a < $b} {
		return -1
	} else {
		return 0
	}
}

proc skating::manage:couples:isSelected {node} {
variable gui
set f $gui(v:folder)
variable $f
upvar 0 $f folder
upvar 0 ::skating::${f}(couples:names) selected

#TRACE "manage:couples:isSelected {$node} = [expr {[lsearch $selected $node] != -1}] / in $selected = [lsearch $selected $node] / $f"
	return [expr {[lsearch $selected $node] != -1}]
}

proc skating::manage:couples:toggle {node {updateGUI 1}} {
variable gui
set f $gui(v:folder)
variable $f
upvar 0 $f folder
upvar 0 ::skating::${f}(couples:names) selected
variable event


#TRACEF "$gui(v:folder)"

	# vérifie si l'on peut modifier
	if {[manage:couples:checkCouples $node] == 0} {
		return -1
	}
	# toggle de la sélection & mise à jour de la variable associée
	if {$updateGUI} {
		set list $gui(w:listCouples)
	}
	set index [lsearch $selected $node]
	if {$index == -1} {
		# OFF --> ON
		# autorise seulement un couple lors des aliasing
		set stem [expr {int($node)}]
		if {[lsearch $folder(couples:all) $stem] != -1} {
#TRACE "conflict $node / $stem // $selected"
			bell
			return -1
		}
		# ajoute le couple
		if {$updateGUI} {
			ListBox::itemconfigure $list $node -image imgOK -fill $gui(color:selected)
		}
		lappend selected $node
		set selected [lsort -real $selected]
		set folder(couples:all) [names2number $selected]

	} else {
		# ON --> OFF
		if {$updateGUI} {
			ListBox::itemconfigure $list $node -image imgNOK -fill $gui(color:notselected)
		}
		set selected [lreplace $selected $index $index]
		set folder(couples:all) [names2number $selected]
	}
	# nombre de couples sélectionnés
	skating::manage:couples:nbCouples [llength $selected]

	# gestion des entrées diférées (préqualifications)
	if {$index == -1} {
		# OFF --> ON
		set ::popRound [lindex $folder(levels) 0]
		manage:couples:startRound:set $f $node
	} else {
		# ON --> OFF
		manage:couples:startRound:remove $f $node
	}

	# ok
	return 0
}

proc skating::manage:couples:quick {mode} {
variable gui
variable event
set f $gui(v:folder)
variable $f
upvar 0 $f folder
upvar 0 ::skating::${f}(couples:names) selected


	set list $gui(w:listCouples)
	if {$mode == "all"} {
		# tous ON
		set done [list ]
		foreach couple $event(couples) {
			if {$couple != int($couple)} {
				continue
			}
			ListBox::itemconfigure $list $couple -image imgOK -fill $gui(color:selected)
			lappend done $couple
		}
		set selected [lsort -real $done]
		set folder(couples:all) [names2number $selected]
	} else {
		# tous OFF
		set in10dances [expr {[string first "." $f] != -1}]

		foreach couple $event(couples) {
			if {$in10dances && $couple != int($couple)} {
				continue
			}
			ListBox::itemconfigure $list $couple -image imgNOK -fill $gui(color:notselected) \
								   -before ""
		}
		set selected {}
		set folder(couples:all) {}
		foreach name [array names folder sartIn:*] {
			unset folder($name)
		}
		ListBox::configure $list -beforewidth 0
	}
	# nombre de couples sélectionnés
	skating::manage:couples:nbCouples [llength $selected]
}

proc skating::manage:couples:sameAs {source_f} {
variable gui
variable event
set f $gui(v:folder)
variable $f
upvar 0 $f folder
upvar 0 ::skating::${f}(couples:names) selected


	# vérifie si l'on peut modifier
	if {[manage:couples:checkCouples $selected] == 0} {
		return
	}

	# récupère les données
	variable $source_f
	upvar 0 $source_f source_folder
	set couples $source_folder(couples:names)
	set selected [lsort -real $couples]
	set folder(couples:all) [names2number $selected]

	# nombre de couples sélectionnés + génération des rounds
	skating::manage:couples:nbCouples [llength $selected]

	# on copie également les pré-qualifications
	foreach n [array names source_folder startIn:*] {
TRACE "copying $n"
		set folder($n) $source_folder($n)
	}

	# mise à jour affichage
	manage:couples:set
return

	# efface tout
	set list $gui(w:listCouples)
	foreach couple $event(couples) {
		if {$couple != int($couple)} {
			continue
		}
		ListBox::itemconfigure $list $couple -image imgNOK -fill $gui(color:notselected)
	}


	# mise à jour affichage
	foreach couple $couples {
		ListBox::itemconfigure $list $couple -image imgOK -fill $gui(color:selected)
	}
	set selected [lsort -real $couples]
	set folder(couples:all) [names2number $selected]
	# nombre de couples sélectionnés
	skating::manage:couples:nbCouples [llength $selected]
	# rétablit le focus (pour navigation clavier)
	after idle "focus $list"
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:couples:nbCouples {nb} {
global __nbCouples
global msg
variable gui

	# affiche nombre de couples sélectionnés
	if {$nb == 0} {
		set __nbCouples $msg(couples:none)
	} elseif {$nb == 1} {
		set __nbCouples "$nb $msg(couples:one)"
	} else {
		set __nbCouples "$nb $msg(couples:twoAndMore)"
	}
	# generation automatique des rounds (si besoin)
	manage:rounds:generate $gui(v:folder) auto
}

proc skating::manage:couples:checkCouples {couples} {
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder
global msg


#TRACEF

	# check si notes déjà attribuées
	#     (on autorise la suppression à la volée du couple si et
	#      seulement si il n'a pas reçu de marks)
	set reinit 0
	foreach couple $couples {
#TRACE "  check/$couple/notes = [array names folder notes:*:$couple:*]"
		set couple [expr {int($couple)}]
		foreach notes [array names folder notes:*:$couple:*] {
#TRACE "    $couple / $folder($notes)"
			foreach note $folder($notes) {
				if {$note != 0} {
					set reinit 1
				}
			}
			if {$reinit} {
				break
			}
		}
		if {$reinit} {
			break
		}
	}
	if {$reinit} {
		set doit [tk_messageBox -icon "question" -type yesno -default yes \
							-title $msg(dlg:question) -message $msg(dlg:couplesReinit)]
		if {$doit == "no"} {
			return 0
		}
		reinitNotes $gui(v:folder)

	} else {
		# suppression/ajout à la volée
		foreach coupleReal $couples {
			set couple [expr {int($coupleReal)}]
			if {[lsearch $folder(couples:all) $couple] == -1} {
				#---- ADD
#TRACE "  ---- add '$couple'"
				if {[llength [array names folder notes:*]] == 0} {
					# cas normal = rien à faire
#TRACE "       no ACTION"
					return 1
				}
				set folder(round:generation) user

				set level [lindex $folder(levels) 0]
				# génère liste vide
				set empty {}
				foreach judge $folder(judges:$level) {
					lappend empty 0
				}
				# ajoute des notes
				if {[info exists folder(dances:$level)]} {
					foreach dance $folder(dances:$level) {
						set folder(notes:$level:$couple:$dance) $empty
					}
				}
				# ajoute le couple dans la liste
				lappend folder(couples:$level) $couple
				set folder(couples:$level) [lsort -integer $folder(couples:$level)]

			} elseif {$couple == $coupleReal} {
#TRACE "  ---- delete '$couple'"
				#---- DELETE
				foreach notes [array names folder notes:*:$couple:*] {
					unset folder($notes)
				}
				foreach n [array names folder couples:*] {
					if {$n != "couples:names" && $n != "couples:all"} {
						set index [lsearch $folder($n) $couple]
						# replace avec -1 sans effet
						set folder($n) [lreplace $folder($n) $index $index]
					}
				}
			}
		}
#TRACE "names = $folder(couples:names) / all = $folder(couples:all)"
	}

	return 1
}

proc skating::reinitNotes {f} {
variable $f
upvar 0 $f folder

	# modifications ...
	set gui(v:modified) 1
	# efface les couples pour les rounds
	foreach n [array names folder notes:*] {
		unset folder($n)
	}
	foreach n [array names folder couples:*] {
		if {$n != "couples:names" && $n != "couples:all"} {
			unset folder($n)
		}
	}
	foreach n [array names folder result*] {
		unset folder($n)
	}
#  	foreach n [array names folder comments*] {
#  		unset folder($n)
#  	}

	# suppression de la prefinale si nécessaire
	result:prefinale:remove $f

	# pour les dix danses, les danses sont fixes
	foreach n [array names folder dances:*] {
		unset folder($n)
	}
}


#=================================================================================================
#
#	Gestion des alias de noms pour les couples
#
#=================================================================================================

proc skating::couple:name {f couple} {
variable event
variable $f
upvar 0 $f folder

#parray $f couples:*
#puts -nonewline stderr "skating::couple:name {'$f' $couple}  --->"
	if {$f != ""} {
		set couple [lindex $folder(couples:names) [lsearch $folder(couples:all) $couple]]
	}
#puts stderr "$couple"
	return $event(name:$couple)
}

proc skating::couple:school {f couple} {
variable event
variable $f
upvar 0 $f folder

#puts -nonewline "skating::couple:school {'$f' $couple}  --->"
	if {$f != ""} {
		set couple [lindex $folder(couples:names) [lsearch $folder(couples:all) $couple]]
	}
#puts "$couple"
	return $event(school:$couple)
}

proc skating::names2number {couples} {
	set result [list ]
	foreach c $couples {
		lappend result [expr {int($c)}]
	}
	set result
}


#=================================================================================================
#
#	Gestion des entrées différées pour certains couples
#
#=================================================================================================

proc skating::manage:couples:startRound:choose {x y node} {
variable gui
set f $gui(v:folder)
variable $f
upvar 0 $f folder
variable event
global msg

#TRACEF

	# si couple non sélectionné, rien
	if {[lsearch $folder(couples:names) $node] == -1} {
		return
	}

	# construit le menu de la liste des rounds
	destroy .popRound
	set m [menu .popRound -tearoff 0 -bd 1]
	$m add command -label "$msg(startingRound) $node" -state disabled
	$m add separator
	foreach round $folder(levels) {
		if {[string first "." $round] != -1} {
			# on ne peut commencer que dans un vrai round, pas un repêchage
			continue
		}
		$m add radiobutton -label $folder(round:$round:name) \
				-variable ::popRound \
				-value $round \
				-command "skating::manage:couples:startRound:set [list $f] $node"
	}

	# positionne la variable à la bonne valeur par défault
	set ::popRound [manage:couples:startRound:get $f $node 0]

	# affiche le popup
	tk_popup $m $x $y
}

set ::popRound ""

#-------------------------------------------------------------------------------------------------

proc skating::manage:couples:startRound:get {f couple removeFirst} {
variable $f
upvar 0 $f folder

	# nom du couple sans alias
	set couple [expr {int($couple)}]

	# par défaut, tous les rounds
	set start [lindex $folder(levels) 0]
	set first $start

	# cherche le couple
	foreach round $folder(levels) {
		if {[info exists folder(startIn:$round)] &&
					[lsearch $folder(startIn:$round) $couple] != -1} {
			set start $round
			break
		}
	}

	# retourne chaine vide si départ normal 1er round (si activé)
	if {$removeFirst && $start == $first} {
		set start ""
	}

	# OK
	return $start
}

proc skating::manage:couples:startRound:set {f couple} {
variable $f
upvar 0 $f folder
variable gui
global msg


	# si même choix, rien à faire
	if {$::popRound == [manage:couples:startRound:get $f $couple 0]} {
		return
	}

	# modifier le round de départ peut influer sur les notes déjà entrées
	set reinit 0
	foreach c $folder(couples:all) {
#TRACE "  check/$c/notes = [array names folder notes:*:$c:*]"
		set c [expr {int($c)}]
		foreach notes [array names folder notes:*:$c:*] {
#TRACE "    $c / $folder($notes)"
			foreach note $folder($notes) {
				if {$note != 0} {
					set reinit 1
				}
			}
			if {$reinit} {
				break
			}
		}
		if {$reinit} {
			break
		}
	}
#TRACE "reninit = $reinit"
	if {$reinit} {
		set doit [tk_messageBox -icon "question" -type yesno -default yes \
							-title $msg(dlg:question) -message $msg(dlg:couplesReinit)]
		if {$doit == "no"} {
			return 0
		}
		reinitNotes $f
		# generation automatique des rounds (si besoin) + mise à jour affichage
		manage:rounds:generate $f auto
	}

	# nom du couple sans alias
	set couple [expr {int($couple)}]

	# on retire des anciennes listes
	foreach round $folder(levels) {
		if {[info exists folder(startIn:$round)] &&
					[set index [lsearch $folder(startIn:$round) $couple]] != -1} {
			set folder(startIn:$round) [lreplace $folder(startIn:$round) $index $index]
			break
		}
	}

	# on ajoute le couple
	lappend folder(startIn:$::popRound) $couple

	# mise à jour affichage
	set start $msg(round:short:$::popRound)
	if {$::popRound == [lindex $folder(levels) 0]} {
		set start ""
	}
	ListBox::itemconfigure $gui(w:listCouples) $couple -before $start

	# cherche si on doit réserve un affichage pour les rounds
	set max [list ]
	foreach round [lrange $folder(levels) 1 end] {
		if {[info exists folder(startIn:$round)] &&
					[llength $folder(startIn:$round)]} {
			lappend max "<$msg(round:short:$round)>"
		}
	}
	ListBox::configure $gui(w:listCouples) -beforewidth [ListBox::measure $gui(w:listCouples) $max]
}

proc skating::manage:couples:startRound:remove {f couple} {
variable $f
upvar 0 $f folder
variable gui

	# nom du couple sans alias
	set couple [expr {int($couple)}]

	# on retire des anciennes listes
	foreach round $folder(levels) {
		if {[info exists folder(startIn:$round)] &&
					[set index [lsearch $folder(startIn:$round) $couple]] != -1} {
			set folder(startIn:$round) [lreplace $folder(startIn:$round) $index $index]
			break
		}
	}

	# mise à jour affichage
	catch {
		ListBox::itemconfigure $gui(w:listCouples) $couple -before ""
	}
}

proc skating::isPrequalified {f couple round} {
variable $f
upvar 0 $f folder

#TRACEF

	# retourne 1 si le couple est préqualifié dans <round>
	set idx [lsearch $folder(levels) $round]
	foreach round [lrange $folder(levels) [expr {$idx+1}] end] {
		if {[info exists folder(startIn:$round)] &&
				[lsearch $folder(startIn:$round) $couple] != -1} {
			return 1
		}
	}

	return 0
}

proc skating::couplesPrequalified {f round} {
variable $f
upvar 0 $f folder

#TRACEF

	if {[string first "." $round] != -1} {
		# pas de pré-qualifé pour les repêchages
		return [list ]
	}

	# construit la liste des couples préqualifiés dans <round>
	set couples [list ]
	set idx [lsearch $folder(levels) $round]
	foreach round [lrange $folder(levels) [expr {$idx+1}] end] {
		if {[info exists folder(startIn:$round)]} {
			foreach c $folder(startIn:$round) {
				if {[lsearch $$folder(couples:all) $c] != -1} {
					lappend couples $c
				}
			}
		}
	}

#TRACEF "couples = [lsort -unique $couples]"

	return [lsort -unique $couples]
}

proc skating::nbPrequalified {f round} {
variable $f
upvar 0 $f folder

#TRACEF

	if {[string first "." $round] != -1} {
		# pas de pré-qualifé pour les repêchages
		return 0
	}

	# calcul le nombre de couples préqualifiés dans <round>
	return [llength [couplesPrequalified $f $round]]
}


#=================================================================================================
#
#	Gestion des heats
#
#=================================================================================================

proc skating::computeHeats {f round size mode grouping} {
variable $f
upvar 0 $f folder

#TRACEF

	#-- retourne la liste ordonée des couples en fonction du mode de calcul
	#-- des heats. (Utilisé dans skating_class_round.tcl
	#							 skating_print_ps.tcl)

	# construit la liste des couples
	set couples $folder(couples:$round)
	set prequalified [couplesPrequalified $f $round]
	foreach couple $prequalified {
		if {[set index [lsearch $couples $couple]] != -1} {
			set couples [lreplace $couples $index $index]
		}
	}
#TRACE "couples = $couples"
#TRACE "prequal = $prequalified"

	# calcule une 'seed' reproductible pour 'rand'
	set seed 0
	foreach couple $couples {
		incr seed $couple
	}
	# fonction de groupage des couples des couples
	if {$grouping == "number"} {
		set couples [lsort -integer $couples]
	} elseif {$grouping == "alphabetic"} {
		set couples [lsort -integer -command "alphabetic" $couples]
	} elseif {$grouping == "random"} {
		expr {srand($seed)}
		set couples [lsort -integer -command "shuffle" $couples]
	}

	# on sous-trie chaque heat
	foreach {nb1 size1 nb2 size2} [computeHeats:size [llength $couples] $size $mode] break
	set heat 1
	set total [expr {$nb1+$nb2}]
	set index 0
	set list [list ]
	while {$total} {
		# extrait les couples
		if {$heat <= $nb1} {
			set newIndex [expr {$index+$size1}]
		} else {
			set newIndex [expr {$index+$size2}]
		}
		set couplesInHeat [lrange $couples $index [expr {$newIndex-1}]]
		set index $newIndex
		# on trie
		set list [concat $list [lsort -integer $couplesInHeat]]
		# heat suivante
		incr heat
		incr total -1
	}
	# ajoute la liste des pré-qualifiés

#TRACE "   [expr $heat-1] heats  >>>  $list  +  $prequalified"
	return [concat $list $prequalified]
}

proc skating::computeHeats:size {nb size mode} {

#TRACEF
#TRACE "  $nb / $size / $mode"

	if {$nb <= $size} {
#TRACE "    --> [list 1 $nb 0 0]"
		return [list 1 $nb 0 0]
	}

	set heats [expr {$nb/$size}]
	set rest  [expr {$nb - $heats*$size}]
#TRACE "___ $heats,$rest ___ "

	if {$mode == "exact"} {
		# mode 'exact' : on ne gère pas les restes
		set list [list $heats $size 1 $rest]
	} elseif {$mode == "add"} {
		# mode 'add' : on absorbe le reste sur les autres heats
		if {$heats >= $rest} {
			set list [list $rest [expr {$size+1}] [expr {$heats-$rest}] $size]
		} else {
			set list [list $heats $size 1 $rest]
		}
	} else {
		# mode 'sub' : on garde le même nb de heat, mais on répartit la charge
		if {$rest == 0} {
			return [list $heats $size 0 0]
		}
		set size2 [expr {$nb/($heats+1)}]
		if {$size2 == 0} {
			set size2 1
		}
		set heats2 [expr {$nb/$size2}]
		set rest2 [expr {$nb-$size2*$heats2}]
#TRACE "... $size2 / $heats2,$rest2 ..."
		if {$rest2} {
			set list [list $rest2 [expr {$size2+1}] \
						   [expr {$heats2-$rest2}] $size2]
		} else {
			set list [list $heats2 $size2 0 0]
		}
	}
#TRACE "    --> $list"
	return $list
}


proc skating::inHeat {nb size mode index} {

	#-- retourne dans quelle heat se trouve le couple 'index'

	# paramètres
	foreach {nb1 size1 nb2 size2} [computeHeats:size $nb $size $mode] break

	if {$index <= $nb1*$size1} {
		expr {$index/$size1}
	} else {
		expr {$nb1+($index-$nb1*$size1)/$size2}
	}
}




#
# Routines pour le tri des couples en fonction du mode (hasard, alphabetic, par école)
#

proc shuffle {args} {
	if {rand() > 0.5} {
		return -1
	} else {
		return 1
	}
}

proc alphabetic {a b} {
	string compare -nocase $skating::event(name:$a) $skating::event(name:$b)
}

proc groupBySchool {a b} {
	string compare -nocase $skating::event(school:$a) $skating::event(school:$b)
}
