##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Classement pour la finale d'une danse d'un dossier (notation)
#
#=================================================================================================

proc skating::gui:round {top f dance level} {
variable gui

#TRACEF

	# création du canvas pour les grilles de notation
	set c [canvas $top.canvas -highlightthickness 0 -bg gray95 -height 1]
	set gui(w:canvas:$level:$dance) $c
	# bind pour retracer lors changement de configuration
	bind $c <Configure> "skating::round:draw $c [list $f] [list $dance] $level"
	# binding du canvas
	bind $c <Visibility> "focus $c"
		# navigation dans les marks
		bind $c <Left> "skating::round:keyboard [list $f] $c   -1   0 $level"
		bind $c <Right> "skating::round:keyboard [list $f] $c  +1   0 $level"
		bind $c <Home> "skating::round:keyboard [list $f] $c  -10   0 $level"
		bind $c <End> "skating::round:keyboard [list $f] $c   +10   0 $level"
		bind $c <Up> "skating::round:keyboard [list $f] $c      0  -1 $level"
		bind $c <Down> "skating::round:keyboard [list $f] $c    0  +1 $level"
		bind $c <Prior> "skating::round:keyboard [list $f] $c   0 -10 $level"
		bind $c <Next> "skating::round:keyboard [list $f] $c    0 +10 $level"
		bind $c <Escape> "skating::round:unkeyboard [list $f] $c $level"
		foreach k {<space> <Return> <comma> <period> <KP_Enter>} {
			bind $c $k "skating::round:keyboard:toggle [list $f] $c $level"
		}
		if {$::tcl_platform(platform) != "windows"} {
			bind $c  <KP_Delete> "skating::round:keyboard:toggle [list $f] $c $level"
		}
		# pour le scrolling
		bind $c <Shift-Up> "$c yview scroll -1 units"
		bind $c <Shift-Down> "$c yview scroll +1 units"
		bind $c <Shift-Prior> "$c yview scroll -1 pages"
		bind $c <Shift-Next> "$c yview scroll +1 pages"
	# init
	set gui(t:$c:couple) -1
	set gui(t:$c:judge) -1
	set gui(t:$c:timer) -1
	set gui(v:activeX) -1
	set gui(v:activeY) -1
	# retourne le path
	return $c
}

#-------------------------------------------------------------------------------------------------

proc skating::round:draw {c f dance level} {
variable $f
upvar 0 $f folder
variable gui
variable event


#TRACEF

	# génère liste de notes à 1
	set empty {}
	foreach judge $folder(judges:$level) {
		lappend empty 1
	}

	# efface tout
	$c delete all
	# si non prise en compte, ne fait rien
	if {[lsearch $folder(dances:$level) $dance] == -1} {
#TRACE "---- not using dance"
		selection:okForResult $f $level
		return
	}
	# liste des couples & juges
	if {$gui(t:useHeats:$level:$dance)} {
		foreach item {size type grouping} {
			if {[info exists folder(heats:$level:$item)]} {
				set $item $folder(heats:$level:$item)
			} else {
				set $item $gui(pref:print:heats:$item)
			}
		}
		set couples [computeHeats $f $level $size $type $grouping]
		set nbPrequalified [nbPrequalified $f $level]
		set nbCouples [expr {[llength $couples] -$nbPrequalified}]
		set heat [inHeat $nbCouples $size $type 0]
	} else {
		set couples $folder(couples:$level)
	}
	set judges [lsort -command skating::event:judges:sort $folder(judges:$level)]
	set folder(judges:$level) $judges

	# mémorise qqs paramètres
	set gui(t:$c:nbJudges) [llength $judges]

	# récupère la taille de la frame
	set startX 10
	set startY 10
	set spaceY 15
	set wJ 30
	set wJ1 $wJ
	if {$gui(pref:names:rounds)} {
		foreach judge $judges {
			$c create text 0 0 -text $event(name:$judge) -font canvas:label -tags "text"
		}
		set bbox [$c bbox text]
		set wJ2 [expr [lindex $bbox 2]-[lindex $bbox 0] + 10]
		incr wJ $wJ2
		$c delete all
	}
	set wN 30
	# calcule la taille des blocs
	set width [winfo width $c]
	if {$width < 10} {
		return
	}
	set nb [llength $couples]
	set nbPerRow [expr {($width - $wJ - 2*$startX)/$wN}]
	set gui(v:nbPerRow) $nbPerRow
#puts "---- couples = '$couples' / $nb / $nbPerRow <- {($width - $wJ - 2*$startX)/$wN}"

	# arrange les couples
	set row 0
	set drawn 0
	set y $startY
	set cIndex 0
	set extra 0
	set color $gui(color:lightyellow)
	while {$drawn < $nb} {
		set oldy $y
		# nom des juges
		$c create rectangle $startX $y [expr $startX+$wJ] [expr $y+20] -fill $gui(color:yellow) -outline black
		incr y 20
		set i 0
		foreach judge $judges {
			$c create rectangle $startX $y [expr $startX+$wJ] [expr $y+20] \
					-fill $gui(color:yellow) -outline black -tags "judge:$i jtip:$i key:$judge"
			# affiche juge + nom (si option activée)
			$c create text [expr $startX+$wJ1/2] [expr $y+11] -text $judge -font canvas:label \
					-tags "jtip:$i key:$judge"
			if {$gui(pref:names:rounds)} {
				$c create line [expr $startX+$wJ1] $y [expr $startX+$wJ1] [expr $y+20]
				$c create text [expr $startX+$wJ1+$wJ2/2] [expr $y+11] -text $event(name:$judge) \
						-font canvas:label -tags "key:$judge"
			} else {
				DynamicHelp::register $c canvasballoon "jtip:$i" $event(name:$judge)
			}
			# bindings pour sélection par click
			if {[string length $judge] > 1} {
				$c bind "key:$judge" <1> "set skating::gui(v:judge:pending) \"\";
										  skating::fastentry [string index $judge 0];
										  skating::fastentry [string index $judge 1]
										  skating::fastentry Return"
			} else {
				$c bind "key:$judge" <1> "set skating::gui(v:judge:pending) \"\";
										  skating::fastentry $judge;
										  skating::fastentry Return"
			}
			# double-click = toggle des cases
			$c bind "key:$judge" <Double-1> "skating::round:toggleMulti:judge [list $f] $c [list $dance] $level $i"
			# juge suivant
			incr y 20
			incr i
		}
		# les couples
		set x [expr $startX+$wJ]
		foreach couple [lrange $couples $drawn [expr $drawn+$nbPerRow-1]] {
			# vérifie le style
			if {$gui(t:useHeats:$level:$dance)
						&& $cIndex <= $nbCouples
						&& [inHeat $nbCouples $size $type $cIndex] != $heat} {
				set heat [inHeat $nbCouples $size $type $cIndex]
				set extra [expr {!$extra}]
				if {$extra} {
					set color $gui(color:lightyellow2)
				} else {
					set color $gui(color:lightyellow)
				}
			}
			# affichage du numéro de couple (double-click = toggle des cases)
			set y $oldy
			$c create rectangle $x $y [expr $x+$wN] [expr $y+20] \
					-fill $color -outline black -tags "ctip:$couple couple:$couple"
			$c create text [expr $x+$wN/2] [expr $y+11] -text $couple -font canvas:label \
					-tags "ctip:$couple"
			DynamicHelp::register $c canvasballoon "ctip:$couple" [couple:name $f $couple]
			incr y 20
			set i 0
			foreach judge $judges {
				if {[isPrequalified $f $couple $level]} {
					#---- préqualifié
#TRACE "prequalified"
					$c create rectangle $x $y [expr {$x+$wN}] [expr {$y+20}] \
							-fill gray95 -outline black -tags "t:$couple:$i"
					$c create rectangle [expr {$x+5}] [expr {$y+5}] [expr {$x+$wN-5}] [expr {$y+15}] \
							-fill $gui(color:choosenprequalif) -outline $gui(color:choosenprequalif)
					# pour la navigation
					$c create rectangle [expr {$x+2}] [expr {$y+2}] [expr {$x+$wN-2}] [expr {$y+18}] \
							-outline gray95 -tags "k:$cIndex:$i k:all"
					# mémorise des notes "parfaites"
					set folder(notes:$level:$couple:$dance) $empty

				} else {
					#---- normal
					$c bind "ctip:$couple" <Double-1> "skating::round:toggleMulti:couple [list $f] $c [list $dance] $level $couple"
					# pour l'affichage
					$c create rectangle $x $y [expr {$x+$wN}] [expr {$y+20}] \
							-fill gray95 -outline black -tags "t:$couple:$i"
					$c create rectangle [expr {$x+5}] [expr {$y+5}] [expr {$x+$wN-5}] [expr {$y+15}] \
							-fill gray95 -outline gray95 -tags "t:$couple:$i $couple:$i $i:off"
					$c bind t:$couple:$i <1> \
							"skating::round:toggle [list $f] $c [list $dance] $level $couple $i"
					# pour la navigation
					$c create rectangle [expr {$x+2}] [expr {$y+2}] [expr {$x+$wN-2}] [expr {$y+18}] \
							-outline gray95 -tags "k:$cIndex:$i k:all"
				}
				# juge suivant
				incr y 20
				incr i
			}
			# couple suivant
			incr x $wN
			incr cIndex
		}
		# ensemble suivant
		incr drawn $nbPerRow
		incr y $spaceY
	}
	# initialise le tableau avec les données
	set gui(v:dance) $dance
	round:setFromDance $f $c $dance $level

	# mise à jour du résultat
	selection:okForResult $f $level

	# affichage du couple courant (mode navigation)
	if {$gui(v:activeX) != -1} {
		skating::round:keyboard $f $c 0 0 $level
	}
	# sélection du premier juge par défaut
	if {$gui(v:judge) == -1} {
		set gui(v:judge) 0
	}
	fastentry:selectJudge

	# zone pour le scrolling
	set bbox [$c bbox all]
	set x [expr [lindex $bbox 2]+10]
	set y [expr [lindex $bbox 3]+10]
	if {$x < [winfo width $c]} { set x [winfo width $c]}
	if {$y < [winfo height $c]} { set y [winfo height $c] }
	$c configure -scrollregion [list 0 0 $x $y]
}

#-------------------------------------------------------------------------------------------------

proc skating::round:toggle {f c dance level couple judge {fromKeyboard 0}} {
variable $f
upvar 0 $f folder
variable gui


#TRACEF


	# interdit la modification d'un couple pré-qualifié
	if {[isPrequalified $f $couple $level]} {
		bell
		return
	}

	# regarde si déjà sélectionné et option interdit la bascule
	set couples $folder(couples:$level)
	set old [lindex $folder(notes:$level:$couple:$dance) $judge]
	if {$fromKeyboard && $old == 1 && $gui(pref:keyboard:toggleling) == 0} {
		bell
		return
	}

	# test si impact sur la suite
	if {[selection:check $f $level] == 0} {
		focus $c
		return
	}
	focus $c

	# liste des couples
	set couples $folder(couples:$level)

	# bascule la sélection
	set old [lindex $folder(notes:$level:$couple:$dance) $judge]
	if {$old} {
		set new 0
		$c itemconfigure $couple:$judge -fill gray95 -outline gray95 \
				-tags "t:$couple:$judge $couple:$judge $judge:off"
	} else {
		set new 1
		$c itemconfigure $couple:$judge -fill $gui(color:choosengood) \
				-outline $gui(color:choosengood) -tags "t:$couple:$judge $couple:$judge $judge:on"
	}
	# mise à jour de la variable
	set folder(notes:$level:$couple:$dance) \
			[lreplace $folder(notes:$level:$couple:$dance) $judge $judge $new]
	# vérifie si le nombre n'est pas trop important
	set total 0
	foreach i $couples {
		incr total [lindex $folder(notes:$level:$i:$dance) $judge]
	}
	if {$total != $folder(round:$level:nb)} {
		$c itemconfigure $judge:on -fill $gui(color:choosenbad) \
				-outline $gui(color:choosenbad)
	} else {
		$c itemconfigure $judge:on -fill $gui(color:choosengood) \
				-outline $gui(color:choosengood)
	}
	# mise à jour du résultat
	selection:okForResult $f $level
	# mise à jour de l'affichage
	round:highlight $c $couple $judge


	#---- sélection du juge/danse suivant ----
	if {$total == $folder(round:$level:nb)} {
		if {$gui(v:judge)+1 < [llength $folder(judges:$level)]} {
			incr gui(v:judge)
			fastentry:deselectAll
			fastentry:selectJudge
		} else {
			# signal pour 'fastentry' sur prochain 'commit'
			set gui(v:judge) -2
		}
	}
}

proc skating::round:toggleMulti:judge {f c dance level judge} {
variable $f
upvar 0 $f folder
variable gui

	# test si impact sur la suite
	if {[selection:check $f $level] == 0} {
		focus $c
		return
	}
	focus $c

	# pour toutes les couples d'un juge
	foreach couple $folder(couples:$level) {
		# bascule la sélection
		set old [lindex $folder(notes:$level:$couple:$dance) $judge]
		if {$old} {
			set new 0
			$c itemconfigure $couple:$judge -fill gray95 -outline gray95 \
					-tags "t:$couple:$judge $couple:$judge $judge:off"
		} else {
			set new 1
			$c itemconfigure $couple:$judge -fill $gui(color:choosengood) \
					-outline $gui(color:choosengood) -tags "t:$couple:$judge $couple:$judge $judge:on"
		}
		# mise à jour de la variable
		set folder(notes:$level:$couple:$dance) \
				[lreplace $folder(notes:$level:$couple:$dance) $judge $judge $new]
	}
	# vérifie si le nombre n'est pas trop important
	set total 0
	foreach i $folder(couples:$level) {
		incr total [lindex $folder(notes:$level:$i:$dance) $judge]
	}
	if {$total != $folder(round:$level:nb)} {
		$c itemconfigure $judge:on -fill $gui(color:choosenbad) \
				-outline $gui(color:choosenbad)
	} else {
		$c itemconfigure $judge:on -fill $gui(color:choosengood) \
				-outline $gui(color:choosengood)
	}
	# mise à jour du résultat
	selection:okForResult $f $level
	# mise à jour de l'affichage
	round:highlight $c $couple $judge
}

proc skating::round:toggleMulti:couple {f c dance level couple} {
variable $f
upvar 0 $f folder
variable gui

	# test si impact sur la suite
	if {[selection:check $f $level] == 0} {
		focus $c
		return
	}
	focus $c

	# toggle pour tous les juges d'un couple
	set judge 0
	foreach dummy [lsort -command skating::event:judges:sort $folder(judges:$level)] {
		# bascule la sélection
		set old [lindex $folder(notes:$level:$couple:$dance) $judge]
		if {$old} {
			set new 0
			$c itemconfigure $couple:$judge -fill gray95 -outline gray95 \
					-tags "t:$couple:$judge $couple:$judge $judge:off"
		} else {
			set new 1
			$c itemconfigure $couple:$judge -fill $gui(color:choosengood) \
					-outline $gui(color:choosengood) -tags "t:$couple:$judge $couple:$judge $judge:on"
		}
		# mise à jour de la variable
		set folder(notes:$level:$couple:$dance) \
				[lreplace $folder(notes:$level:$couple:$dance) $judge $judge $new]
		# juge suivant
		incr judge
	}
	# vérifie si le nombre n'est pas trop important
	set couples $folder(couples:$level)
	set judge 0
	foreach dummy [lsort -command skating::event:judges:sort $folder(judges:$level)] {
		set total 0
		foreach i $couples {
			incr total [lindex $folder(notes:$level:$i:$dance) $judge]
		}
		if {$total != $folder(round:$level:nb)} {
			$c itemconfigure $judge:on -fill $gui(color:choosenbad) \
					-outline $gui(color:choosenbad)
		} else {
			$c itemconfigure $judge:on -fill $gui(color:choosengood) \
					-outline $gui(color:choosengood)
		}
		# juge suivant
		incr judge
	}
	# mise à jour du résultat
	selection:okForResult $f $level
	# mise à jour de l'affichage
	round:highlight $c $couple $judge
}

#-------------------------------------------------------------------------------------------------

proc skating::round:setFromDance {f c dance level} {
variable $f
upvar 0 $f folder
variable gui

#TRACEF

	# génère liste de notes à 0
	set empty {}
	foreach judge $folder(judges:$level) {
		lappend empty 0
	}

	# liste des couples & juges
	set couples $folder(couples:$level)
	set judges [lsort -command skating::event:judges:sort $folder(judges:$level)]

	# affecte les notes
	foreach couple $couples {
		if {![info exists folder(notes:$level:$couple:$dance)]} {
			set folder(notes:$level:$couple:$dance) $empty
			continue
		}
		set judge 0
		foreach note $folder(notes:$level:$couple:$dance) {
			if {$note} {
				$c itemconfigure $couple:$judge -tags "t:$couple:$judge $couple:$judge $judge:on" \
						-fill $gui(color:choosengood) -outline $gui(color:choosengood)
			}
			incr judge
		}
	}
	# vérifie si le nombre n'est pas trop important
	set judge 0
	foreach dummy $judges {
		set total 0
		foreach i $couples {
			incr total [lindex $folder(notes:$level:$i:$dance) $judge]
		}
#TRACE "$couple / $total != $folder(round:$level:nb)"
		if {$total != $folder(round:$level:nb)} {
			$c itemconfigure $judge:on -fill $gui(color:choosenbad) \
					-outline $gui(color:choosenbad)
		} else {
			$c itemconfigure $judge:on -fill $gui(color:choosengood) \
					-outline $gui(color:choosengood)
		}
		incr judge
	}
}



#=================================================================================================
#
#	Gestion du résultat d'un round (sélection pour le round suivant)
#
#=================================================================================================


proc skating::gui:selection {top f level mode} {
variable $f
upvar 0 $f folder
variable gui


	# création du canvas pour les grilles de notation
	set c [canvas $top.canvas -highlightthickness 0 -bg gray95 -height 1]
	# table pour le classement final
	bind $c <Configure> "skating::selection:drawResult $c [list $f] $level 1 $mode"
	# binding pour scrolling des canvas
	bind $c <Visibility> "focus $c"
	bind $c <Up> "$c yview scroll -1 units"
	bind $c <Down> "$c yview scroll +1 units"
	bind $c <Prior> "$c yview scroll -1 pages"
	bind $c <Next> "$c yview scroll +1 pages"
	# retourne le path
	set gui(w:ranking:$level) $c
	return $c
}

#-------------------------------------------------------------------------------------------------

proc skating::selection:drawResult {c f level delete mode} {
global msg
variable $f
upvar 0 $f folder
variable gui
variable event

#TRACEF

	# efface tout
	if {$delete} {
		$c delete all
		set y 0
	} else {
		set y [lindex [$c bbox all] 3]
		if {$y == ""} {
			set y 0
		} else {
			incr y 50
		}
	}

	# liste des couples
	set couples $folder(couples:$level)

	# récupère la taille de la frame
	set width [winfo width $c]
	if {$width < 120} {
		return
	}
	set nb [llength $couples]
	set nbPerRow [expr ($width - 20 - 100)/30]

	# arrange les couples
	set i 0
	set row 0
	set drawn 0
	while {$drawn < $nb} {
		set oldy [incr y 10]
		# nom des juges
		$c create rectangle 10 $y 70 [expr $y+20] -fill $gui(color:yellow) \
				-outline black -tags "rank"
		incr y 20
		if {[llength $folder(dances)] > 1} {
			foreach d $folder(dances:$level) {
				$c create rectangle 10 $y 70 [expr $y+20] \
						-fill $gui(color:yellow) -outline black -tags "rank d$y"
				$c create text 40 [expr $y+11] -text [firstLetters $d] \
						-font canvas:label -tags "rank d$y"
				if {$folder(mode) == "ten"} {
					$c bind "d$y" <1> "skating::gui:select 0 $f.[join $d _]; \
									   set skating:dblclick 1; \
									   NoteBook::raise $skating::gui(w:notebook) [string map {. _} $level]"
				} else {
					$c bind "d$y" <1> "skating::gui:select 0 $f.$level; \
									   set skating:dblclick 1; \
									   NoteBook::raise $skating::gui(w:notebook) [join $d _]"
				}
				incr y 20
			}
		}
		$c create rectangle 10 $y 70 [expr $y+20] -fill $gui(color:yellow) \
				-outline black -tags "rank"
		$c create text 40 [expr $y+11] -text $msg(total) -font canvas:label \
				-tags "rank"
		# les couples
		set x 70
		foreach couple [lrange $couples $drawn [expr $drawn+$nbPerRow-1]] {
			# label pour couple
			set y $oldy
			$c create rectangle $x $y [expr $x+30] [expr $y+20] -outline black -tags "show:$i rank"
			$c create text [expr $x+15] [expr $y+11] -font canvas:label -tags "rank:couple:$i rank"
			incr y 20
			# sous-total par danse
			if {[llength $folder(dances)] > 1} {
				set j 0
				foreach d $folder(dances:$level) {
					$c create rectangle $x $y [expr $x+30] [expr $y+20] \
							-outline black -tags "show:$i rank"
					$c create text [expr $x+15] [expr $y+11] \
							-font canvas:place -tags "subtotal:$j:$i rank"
					incr y 20
					incr j
				}
			}
			# nb pour total
			$c create rectangle $x $y [expr $x+30] [expr $y+20] -outline black -tags "show:$i rank"
			$c create text [expr $x+15] [expr $y+11] -font canvas:label -tags "total:$i rank"
			incr x 30
			# suivant
			incr i
		}
		incr y 20
		incr drawn $nbPerRow
	}

	# mise à jour affichage
	if {$mode == "full"} {
		selection:show $level $nb $gui(v:nbToNextRound:$level)
	}
	selection:display $f $level

	# définition des tips
	foreach couple $couples {
		DynamicHelp::register $c canvasballoon "ctip:$couple" [couple:name $f $couple]
	}

	# zone pour le scrolling
	set bbox [$c bbox all]
	set x [expr [lindex $bbox 2]+10]
	set y [expr [lindex $bbox 3]+10]
	if {$x < [winfo width $c]} { set x [winfo width $c]}
	if {$y < [winfo height $c]} { set y [winfo height $c] }
	$c configure -scrollregion [list 0 0 $x $y]
}

#-------------------------------------------------------------------------------------------------

proc skating::selection:skip:init {button f level dance} {
variable $f
upvar 0 $f folder
variable gui

	# ajuste la liste des danses validées
	if {![info exists folder(dances:$level)]} {
		set folder(dances:$level) $folder(dances)
	}
	# ajuste bouton
	if {[lsearch $folder(dances:$level) $dance] == -1} {
		$button deselect
		selection:skip:color $dance off
	} else {
		$button select
		selection:skip:color $dance on
	}
}

proc skating::selection:skip {button f level dance} {
variable $f
upvar 0 $f folder
variable gui


#puts "skating::selection:skip {$button $f $level $dance}"
	set gui(v:modified) 1

	# toggle bouton
	set idx [lsearch $folder(dances:$level) $dance]
	if {$idx == -1 && [selection:check $f $level]} {
		$button select
		lappend folder(dances:$level) $dance
		round:draw $gui(w:canvas:$level:$dance) $f $dance $level
		selection:skip:color $dance on
	} else {
		$button deselect
		set folder(dances:$level) [lreplace $folder(dances:$level) $idx $idx]
		$gui(w:canvas:$level:$dance) delete all
		selection:skip:color $dance off
	}
	# mise à jour du résultat
	selection:okForResult $f $level
	# redessine le contenu de résultat pour prendre en compte nouvelle liste des danses actives
	update
	eval [bind $gui(w:ranking:$level) <Configure>]
}

proc skating::selection:skip:color {dance mode} {
variable gui

	NoteBook::itemconfigure $gui(w:notebook) [join $dance "_"] \
			-background $gui(t:$mode:bg) -selectedbackground $gui(t:$mode:bg) \
			-activebackground $gui(t:$mode:abg)
}

#-------------------------------------------------------------------------------------------------

proc skating::selection:okForResult {f level {force 0}} {
variable $f
upvar 0 $f folder
variable gui


#TRACEFS

	# round suivant
	set idx [lsearch -exact $folder(levels) $level]
	incr idx
	set next [lindex $folder(levels) $idx]
	if {[info exists folder(couples:$next)]} {
		set force 1
		$gui(w:validate:$level).print configure -state normal
		$gui(w:validate:$level).print2 configure -state normal
		$gui(w:validate:$level).print3 configure -state normal
		# @OCM@: button de refresh
		if {$gui(pref:mode:linkOCM)} {
			$gui(w:validate:$level).ocm configure -state normal
		}

	} else {
		$gui(w:validate:$level).print configure -state disabled
		$gui(w:validate:$level).print2 configure -state disabled
		$gui(w:validate:$level).print3 configure -state disabled
		# @OCM@: button de refresh
		if {$gui(pref:mode:linkOCM)} {
			$gui(w:validate:$level).ocm configure -state disabled
		}
	}

	set try [class:round $f $level $force]
	if {$try == 1} {
		set result 1
		set bg #adf3b1
		set abg #b6ffba
	} elseif {$try == -1} {
		return 0
	} else {
		set result 0
		set bg #f3b4ad
		set abg #ffffff
		# efface le nombre de sélectionnés pour le round suivant
		foreach name [array names folder round:$level:nbSelected*] {
#puts "---- removing $f - $name"
			unset folder($name)
		}
	}
	if {$::tcl_platform(platform) == "windows"} {
		set abg $bg
	}

	# autorise/interdit l'accès au bouton de validation
#TRACE "result=$result"
	if {$result == 1} {
		selection:display $f $level
		$gui(w:validate:$level).valid configure -state normal
		$gui(w:prefinale:button) configure -state normal
	} else {
		$gui(w:validate:$level).valid configure -state disabled
		$gui(w:prefinale:button) configure -state disabled \
				-bg $gui(t:on:bg) -activebackground $gui(t:on:abg)
		result:prefinale:remove $f $level
	}

  	if {[string first "." $f] == -1} {
		# normal = un onglet pour le résultat sur l'ensemble des danses
		# change la couleur
		NoteBook::itemconfigure $gui(w:notebook) "result" \
				-background $bg -selectedbackground $bg -activebackground $abg
	}

	return $result
}

#-------------------------------------------------------------------------------------------------

proc skating::selection:display {f level} {
variable $f
upvar 0 $f folder
variable gui

#TRACEF

	# nom des resultats
	set selected "round:$level:nbSelected"
	set result result:$level

	# teste si le résultat est disponible
	if {![info exists folder($result)] || ![info exists gui(w:ranking:$level)]} {
		return
	}
	# affiche le total pour les couples
	set nbJudges [llength $folder(judges:$level)]
	set i 0
	foreach data $folder($result) {
		$gui(w:ranking:$level) itemconfigure rank:couple:$i -text [lindex $data 0] \
				-tags "rank:couple:$i ctip:[lindex $data 0]"
		$gui(w:ranking:$level) itemconfigure show:$i -tags "show:$i ctip:[lindex $data 0]"
		set total [lindex $data 1]
		if {$total > 1000000} {
			$gui(w:ranking:$level) itemconfigure total:$i -text "P"
		} else {
			$gui(w:ranking:$level) itemconfigure total:$i -text $total
		}
		set j 0
		foreach dance [lrange $data 2 end] {
			if {$dance > $nbJudges} {
				$gui(w:ranking:$level) itemconfigure subtotal:$j:$i -text "P"
			} else {
				$gui(w:ranking:$level) itemconfigure subtotal:$j:$i -text $dance
			}
			incr j
		}
		incr i
	}

	# nombre de couples sélectionnés
	if {![info exists folder($selected)]} {
		set nb $folder(round:$level:nb)
		set search 1
	} else {
		set nb $folder($selected)
		set search 0
	}

	# cherche si des couples ont le même nombre de points pour proposer
	# une validation intelligente
	set gui(v:nbToNextRound:$level) $nb
	set couples $folder(couples:$level)
	set total [lindex [lindex $folder($result) [expr $gui(v:nbToNextRound:$level)-1]] 1]
	if {$search && $total} {
		while {[lindex [lindex $folder($result) $gui(v:nbToNextRound:$level)] 1] == $total} {
			set old $gui(v:nbToNextRound:$level)
			incr gui(v:nbToNextRound:$level)
			if {$gui(v:nbToNextRound:$level) == $old || $gui(v:nbToNextRound:$level) > [llength $couples]} {
				# si on atteint la borne (à cause du 'scale', la variable est contrôlée : le 'incr'
				# n'a pas toujours d'effet) OU si on est au bout de la liste
				break
			}
		}
	}
#TRACE "après extension / gui(v:nbToNextRound:$level) = $gui(v:nbToNextRound:$level)"

	# mise à jour affichage
	if {[llength [array names folder result:$level*]]} {
		if {$gui(v:round) == "__result__"} {
			selection:show2 $level [llength $couples] $nb
		} else {
			selection:show $level [llength $couples] $gui(v:nbToNextRound:$level)
		}
	}
	if {$folder(mode) == "qualif"} {
		selection:split:show $f
	}
}

proc skating::selection:undisplay {f level} {
variable $f
upvar 0 $f folder
variable gui

#TRACEF "$gui(w:ranking:$level) / [info level -1]"

	# re-init affichage
	set i 0
	while {$i < [llength $folder(couples:$level)]} {
		$gui(w:ranking:$level) itemconfigure rank:couple:$i -text {}
		$gui(w:ranking:$level) itemconfigure total:$i -text {}
		incr i
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::selection:show {level max nb} {
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder

	if {![info exists gui(v:nbToNextRound:$gui(v:round))]} {
		return
	}

#TRACEF "$gui(v:nbToNextRound:$gui(v:round))"
#TRACES

	# montre l'étendue de couples sélectionnés
	for {set i 0} {$i < $nb} {incr i} {
		$gui(w:ranking:$level) itemconfigure show:$i -fill darkseagreen2
	}
	for {set i $nb} {$i < $max} {incr i} {
		$gui(w:ranking:$level) itemconfigure show:$i -fill salmon
	}

	# assure au moins 50% de repris d'un round sur le suivant
	set next $gui(t:select:$gui(v:round))
	if {$next != ""} {
		if {[string first "." $gui(v:round)] != -1} {
			regexp {[^.]*} $gui(v:round) mainRound
			set ::__total [expr {$folder(round:$mainRound:nbSelected)+$nb}]
		} else {
			set ::__total $nb
		}
		# mise à jour variable 'round:$level:nb'
		set fifty [expr {($::__total+1)/2}]
		if {[info exists gui(v:nbSelectNextRound:$next)]
				&& ($gui(v:nbSelectNextRound:$next) < $fifty || $folder(round:$next:nb) <= $fifty)} {
			set gui(v:nbSelectNextRound:$next) $fifty
		}

		# regarde si on doit suggérer une prefinale
#TRACE "round=$level / $gui(v:nbToNextRound:$level) >= 8"
		if {$level == "semi" && $gui(v:nbToNextRound:$level) >= 8} {
			$gui(w:prefinale:button) configure -bg $gui(t:off:bg) -activebackground $gui(t:off:abg)
		} else {
			$gui(w:prefinale:button) configure -bg $gui(t:on:bg) -activebackground $gui(t:on:abg)
		}
	}
}

proc skating::selection:show2 {level max nb} {
variable gui

	# montre l'étendue de couples sélectionnés (mode Résultat / résumé)
	for {set i 0} {$i < $nb} {incr i} {
		$gui(w:ranking:$level) itemconfigure show:$i -fill darkseagreen2
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::selection:validate {f level} {
global msg
variable $f
upvar 0 $f folder
variable gui


TRACEF "$gui(v:nbToNextRound:$level)"

	# vérifie si OK -- POSITIONNE LA VARIABLE 'next'
	if {[selection:check $f $level] == 0} {
		return
	}

	# liste des couples
	set current_couples $folder(couples:$level)
	set result "result:$level"
	set selected "round:$level:nbSelected"

	# stocke nombre sélectionnés par utilisateur
	set folder($selected) $gui(v:nbToNextRound:$level)

	# sélectionne les couples pour le round suivant
	set couples {}
	if {[string first "." $next] != -1} {
		# liste des couples à repêcher
		set total [llength $current_couples]
		for {set i $folder($selected)} {$i < $total} {incr i} {
			lappend couples [lindex [lindex $folder($result) $i] 0]
		}

	} else {
		# ajout de la selection des éliminatoires + repêchage
		regexp {[^.]*} $level round
		set result result:$round
		set result2 result:$round.2
		set selected round:$round:nbSelected
		set selected2 round:$round.2:nbSelected
		# les qualifiés directement
		if {![info exists folder($result)]} {
			class:round $f $round 1
		}
#puts "---- result = '$folder($result)'"
		for {set i 0} {$i < $folder($selected)} {incr i} {
			lappend couples [lindex [lindex $folder($result) $i] 0]
		}
		# les repéchés si nécessaire
		if {$folder(round:$round:split)} {
			for {set i 0} {$i < $folder($selected2)} {incr i} {
				lappend couples [lindex [lindex $folder($result2) $i] 0]
			}
		}
	}
	# enregistre couples pour round suivant
#puts "---- setting 'couples:$next:...' = '[lsort -dictionary $couples]'"
	set folder(couples:$next) [lsort -dictionary $couples]

	# mémorise le nb à sélectionner pour le round suivant
	set tmp $gui(t:select:$gui(v:round))
	if {$tmp != "" && [info exists gui(v:nbSelectNextRound:$tmp)]} {
		set folder(round:$next:nb) $gui(v:nbSelectNextRound:$tmp)
	}

	# efface les datas du round suivant
	foreach pattern [list exclusion:$next:* notes:$next:* dances:$next] {
		foreach name [array names folder $pattern] {
			unset folder($name)
		}
	}


	if {[string first "." $f] != -1} {
		#---- 10 danses
		# ajuste les onglets
		ten:rounds:check $f $gui(v:dance)
#  		# re-init affichage pour round suivant
#  		ten:init:round $f $gui(v:dance) $next
#  #puts "NoteBook::raise $gui(w:notebook) [string map {. _} $next]"
#  		NoteBook::raise $gui(w:notebook) [string map {. _} $next]
	} else {
		#---- normal
		# ajuste Tree
		manage:rounds:adjustTreeColor $f
#  		# re-init affichage pour round suivant
#  		gui:select 1 $f.$next
	}

	# donne accès aux boutons impression rapide
	$gui(w:validate:$level).print configure -state normal
	$gui(w:validate:$level).print2 configure -state normal
	$gui(w:validate:$level).print3 configure -state normal

	# @OCM@: button de refresh
	if {$gui(pref:mode:linkOCM)} {
		# donne accès à la liaison OCM
		$gui(w:validate:$level).ocm configure -state normal
	}
}

#-------------------------------------------------------------------------------------------------
# retourne 1 si OK, 0 si NOK
# utilise upvar 'next' pour stocker round suivant

proc skating::selection:check {f level} {
global msg
variable $f
upvar 0 $f folder
variable gui
upvar next next

TRACEF "[info level -1]"

	# round suivant
	set idx [lsearch -exact $folder(levels) $level]
	incr idx
	set next [lindex $folder(levels) $idx]

	# demande confirmation si les couples existent déjà
	if {[info exists folder(couples:$next)]} {
		set doit [tk_messageBox -icon "question" -type okcancel -default ok \
							-title $msg(dlg:question) -message $msg(dlg:resetRounds)]
		if {$doit != "ok"} {
			return 0
		}
	}

	# OK pour continuer
	set gui(v:modified) 1

	# reinitialise la suite
	set tmp $next
	while {$tmp != ""} {
TRACE "next = $tmp"
		catch {
TRACE "    unset folder(couples:$tmp)"
			unset folder(couples:$tmp)
			set pattern "notes:$tmp:*"
			foreach n [array names folder $pattern] {
				unset folder($n)
TRACE "    unset folder($n)"
			}
		} errmsg
		incr idx
		set tmp [lindex $folder(levels) $idx]
	}

	# ajuste Tree
	if {[string first "." $f] != -1} {
		ten:rounds:check $f $gui(v:dance)
	}
	manage:rounds:adjustTreeColor $f

	# retire accès aux boutons impression rapide
	catch { $gui(w:validate:$level).print configure -state disabled }
	catch { $gui(w:validate:$level).print2 configure -state disabled }
	catch { $gui(w:validate:$level).print3 configure -state disabled }
	# @OCM@: button de refresh
	if {$gui(pref:mode:linkOCM)} {
		catch { $gui(w:validate:$level).ocm configure -state disabled }
	}


	return 1
}

#-------------------------------------------------------------------------------------------------

proc skating::selection:split:compute {f} {
variable gui
variable $f
upvar 0 $f folder

	set limits [list]
	set nb [llength $folder(couples:all)]
	for {set i 1} {$i <= $::skating::gui(v:nbSplits)} {incr i} {
		lappend limits [expr $i*$nb/$::skating::gui(v:nbSplits)]
    }
	set ::skating::${f}(splitpoints) $limits
	skating::selection:split:show $f
}

proc skating::selection:split:show {f} {
variable gui
variable $f
upvar 0 $f folder

	set c 0
	set colors "darkseagreen2 lightblue"

	set i 0
	foreach limit $folder(splitpoints) {
		set color [lindex $colors $c]
		set c [expr ($c+1)%2]
		while {$i < $limit} {
			$gui(w:ranking:qualif) itemconfigure show:$i -fill $color
			incr i
		}
	}
}

proc skating::selection:split:validate {f} {
variable $f
upvar 0 $f folder

	set count 1
	set i 0
	foreach limit $folder(splitpoints) subf $folder(subfolders) {
		# sous-dossier existe ou doit être créé ?
		if {$subf == ""} {
			set subf [folder:new "$folder(label) - $count" $folder(dances)]
			lappend folder(subfolders) $subf
		}

		variable $subf
		upvar 0 $subf subfolder
		skating::folder:init:normal $subf "$folder(label) - $count" $folder(dances)
		set subfolder(judges:requested) $folder(judges:requested)

		while {$i < $limit} {
			lappend couples($subf) [lsearch $folder(couples:all) [lindex $folder(result:qualif) $i 0]]
			incr i
		}
		incr count
	}

	foreach subf [array names couples] {
		set indexes [lsort -integer $couples($subf)]
		variable $subf
		upvar 0 $subf subfolder
		foreach i $indexes {
			lappend subfolder(couples:names) [lindex $folder(couples:names) $i]
			lappend subfolder(couples:all) [lindex $folder(couples:qualif) $i]
		}

		manage:rounds:generate $subf create
		foreach level $folder(levels) {
			set subfolder(judges:$level) $folder(judges:requested)
		}
	}

	update
}

#----------------------------------------------------------------------------------------------

proc skating::round:highlight {c couple judge} {
variable gui

	# si l'utilisateur a changé de sélection, le canvas peut avoir été détruit
	# et on est rappelé par un timeout
	if {![winfo exists $c]} {
		return
	}

	# efface ancien
	$c itemconfigure "couple:$gui(t:$c:couple)" -fill $gui(color:lightyellow)
	$c itemconfigure "judge:$gui(t:$c:judge)" -fill $gui(color:yellow)
	# highlight nouveau
	$c itemconfigure "couple:$couple" -fill $gui(color:lightorange)
	$c itemconfigure "judge:$judge" -fill $gui(color:orange)
	set gui(t:$c:couple) $couple
	set gui(t:$c:judge) $judge


	# émule un 'canvas see ...'
	set ysee [lindex [$c bbox couple:$gui(t:$c:couple)] 1]
	set ymax [lindex [$c cget -scrollregion] 3]
  	foreach {min max} [$c yview] break
	if {$ysee != "" && $ymax != "" && $ymax != 0} {
		set fraction1 [expr {1.0*($ysee-10)/$ymax}]
		set fraction2 [expr {1.0*($ysee+$gui(t:$c:nbJudges)*20)/$ymax}]
		if {$fraction1 < $min || $fraction1 > $max} {
			$c yview moveto $fraction1
		}
		if {$fraction2 > $max} {
			$c yview moveto $fraction1
		}
	}

	# timer pour effacement
	after cancel $gui(t:$c:timer)
	set gui(t:$c:timer) [after 15000 "skating::round:highlight $c -1 -1"]
}

#----------------------------------------------------------------------------------------------

proc skating::round:coupleFromCoordinate {level x} {
variable gui
upvar f f folder folder

#TRACEF
	# construit liste des couples
	if {$gui(t:useHeats:$level:$gui(v:dance))} {
		foreach item {size type grouping} {
			if {[info exists folder(heats:$level:$item)]} {
				set $item $folder(heats:$level:$item)
			} else {
				set $item $gui(pref:print:heats:$item)
			}
		}
		set couples [computeHeats $f $level $size $type $grouping]
	} else {
		set couples $folder(couples:$level)
	}

	return [lindex $couples $x]
}

proc skating::round:keyboard {f c dx dy level} {
variable gui
variable $f
upvar 0 $f folder


#TRACEF

	# première touche : on affiche
	if {$gui(v:activeX) == -1} {
		# on interdit le processing par fastentry
		fastentry:deselectAll
		set gui(v:judge) -1
		fastentry:mode ""
		# on passe en mode clavier
		set gui(v:activeX) 0
		set gui(v:activeY) 0
		$c itemconfigure "k:$gui(v:activeX):$gui(v:activeY)" -outline red
		round:highlight $c [round:coupleFromCoordinate $level $gui(v:activeX)] $gui(v:activeY)
		return
	}

	# on efface l'ancien
	$c itemconfigure "k:$gui(v:activeX):$gui(v:activeY)" -outline [$c cget -bg]
	# on calcule le nouveau
	set maxX [llength $folder(couples:$level)]
	set maxY [llength $folder(judges:$level)]
	# dX
	if {$dx == -10} {
		set gui(v:activeX) 0
	} elseif {$dx == +10} {
		set gui(v:activeX) [expr {$maxX-1}]
	} elseif {$gui(v:activeX) + $dx < $maxX && $gui(v:activeX) + $dx >= 0} {
		incr gui(v:activeX) $dx
	}
	
	if {$gui(v:activeY) + $dy >= $maxY} {
		if {$gui(v:activeX) + $gui(v:nbPerRow) < $maxX} {
			incr gui(v:activeX) $gui(v:nbPerRow)
			set gui(v:activeY) 0
		}
	} elseif {$gui(v:activeY) + $dy < 0} {
		if {$gui(v:activeX) - $gui(v:nbPerRow) >= 0} {
			incr gui(v:activeX) -$gui(v:nbPerRow)
			set gui(v:activeY) [expr {$maxY-1}]
		}
	} else {
		incr gui(v:activeY) $dy
	}
	$c itemconfigure "k:$gui(v:activeX):$gui(v:activeY)" -outline red
	round:highlight $c [round:coupleFromCoordinate $level $gui(v:activeX)] $gui(v:activeY)
}

proc skating::round:keyboard:toggle {f c level} {
variable gui
variable $f
upvar 0 $f folder

	if {$gui(v:activeX) != -1 && ![isPrequalified $f [round:coupleFromCoordinate $level $gui(v:activeX)] $level]} {
		# toggle le couple
		round:toggle $f $c $gui(v:dance) $level \
				[round:coupleFromCoordinate $level $gui(v:activeX)] $gui(v:activeY)
	}
}

proc skating::round:unkeyboard {f c level} {
variable gui
variable $f
upvar 0 $f folder

	# on efface l'ancien
	$c itemconfigure "k:$gui(v:activeX):$gui(v:activeY)" -outline [$c cget -bg]
	set couple [round:coupleFromCoordinate $level $gui(v:activeX)]
	$c itemconfigure "couple:$couple" -fill $gui(color:lightyellow)
	$c itemconfigure "judge:$gui(v:activeY)" -fill $gui(color:yellow)
	# on autorise le processing par fastentry
	fastentry:mode $level
	# on désactive le mode clavier
	set gui(v:activeX) -1
	set gui(v:activeY) -1
}

proc skating::round:deselectAll {level dance} {
variable gui

	set gui(v:activeX) -1
	if {[info exists gui(w:canvas:$level:$dance)]} {
		set c $gui(w:canvas:$level:$dance)
		$c itemconfigure "k:all" -outline [$c cget -bg]
	}
}
