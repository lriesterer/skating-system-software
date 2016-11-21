##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Classement pour la finale d'une danse d'un dossier (notation)
#
#=================================================================================================

proc skating::gui:notes {top f dance} {
variable gui

	# création du canvas pour les grilles de notation
	set c [canvas $top.canvas -highlightthickness 0 -bg gray95 -height 1]
	set gui(w:canvas:finale:$dance) $c
	set gui(v:redraw:$dance) 0
	# bind pour retracer lors changement de configuration
	set ::__$c.pending 0
	bind $c <Configure> "if {!\[set __$c.pending\]} {
							skating::notes:draw [list $f] [list $dance]
							set __$c.pending 1
							after 500 {set __$c.pending 0}
						 }"
	# binding pour scrolling des canvas
	bind $c <Visibility> "focus $c"
	bind $c <Up> "$c yview scroll -1 units"
	bind $c <Down> "$c yview scroll +1 units"
	bind $c <Prior> "$c yview scroll -1 pages"
	bind $c <Next> "$c yview scroll +1 pages"
	bind $c <Left> "$c xview scroll -1 units"
	bind $c <Right> "$c xview scroll +1 units"
	bind $c <Home> "$c xview scroll -1 pages"
	bind $c <End> "$c xview scroll +1 pages"
	# retourne le path
	return $c
}

#-------------------------------------------------------------------------------------------------

proc skating::notes:refresh {f dance} {
variable gui

	if {$gui(v:redraw:$dance)} {
		notes:draw $f $dance
	}
}

proc skating::notes:draw {f dance} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder

#TRACEF

	# init
	set c $gui(w:canvas:finale:$dance)
	set gui(v:redraw:$dance) 0
	set couples $folder(couples:finale)
	set judges [lsort -command skating::event:judges:sort $folder(judges:finale)]

	# efface tout
	$c delete all
	# récupère la taille de la frame
	set startX 10
	set startY 10
	set spaceX 20
	set spaceY 15
	set wC 30
	set wN 20
	set width [winfo width $c]
	set nb [llength $couples]
	set xsize [expr $spaceX + $wC+$nb*$wN]
	# arrange les grilles dans la page
	set row 0
	set column 0
	set xpos [expr $spaceX+$xsize]
	foreach j $judges {
		# traite les panels
		notes:judge $f $c $j -row $row -column $column -editable true \
				-label $j -labelcolor $gui(color:lightyellow) -color $gui(color:yellow)
		# suivant
		incr xpos $xsize
		if {$xpos > $width} {
			set column 0
			set xpos [expr $spaceX+$xsize]
			incr row
		} else {
			incr column
		}
	}
	# initialise le tableau avec les données
	set gui(v:dance) $dance
	notes:setFromDance $f $c $dance

	# partie pour affichage du classement
	notes:places $f $c
	notes:result $f $c

	# établit la scrollregion
	set bbox [$c bbox all]
	set x [expr [lindex $bbox 2]+$spaceX]
	set y [expr [lindex $bbox 3]+$spaceY]
	if {$x < [winfo width $c]} { set x [winfo width $c] }
	if {$y < [winfo height $c]} { set y [winfo height $c] }
	$c configure -scrollregion [list 0 0 $x $y]

	# @COMP_MGR@: sélection du premier juge par défaut
	if {$gui(pref:mode:compmgr)} {
		if {$gui(v:judge) == -1} {
			set gui(v:judge) 0
		}
		fastentry:selectJudge
		fastentry:selectRanking
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::notes:places {f c} {
global msg
variable gui
variable $f
upvar 0 $f folder
upvar couples couples spaceX spaceX startX startX

	# init partie pour tracé du résultat
	set nb [llength $couples]
	set limits [$c bbox all]
	set y [expr [lindex $limits 3]-1 + 30]
	set xmin $startX
	set xmax [expr $xmin+$nb*40+100]

	# titre
	$c create rectangle $xmin $y $xmax [expr $y+20] \
			-fill $gui(color:lightyellow) -outline black
	$c create text [expr $xmin+($xmax-$xmin)/2] [expr $y+11] \
			-text "$msg(ranking) <$gui(v:dance)>" -font canvas:label
	# par couple
	$c create rectangle $xmin [expr $y+20] [expr $xmin+100] [expr $y+20+60] \
			-fill $gui(color:lightyellow) -outline black
	$c create text [expr $xmin+50] [expr $y+20+31] \
			-text $msg(byCouple) -font canvas:label
	set i 0
	foreach couple $couples {
		$c create rectangle [expr $xmin+100+40*$i] [expr $y+20] \
				[expr $xmin+100+40*($i+1)] [expr $y+20+30] \
				-fill $gui(color:yellow) -outline black -tags "ctip:$couple"
		$c create text [expr $xmin+100+40*$i+20] [expr $y+20+16] \
				-text $couple -font canvas:label -tags "ctip:$couple"
		$c create rectangle [expr $xmin+100+40*$i] [expr $y+20+30] \
				[expr $xmin+100+40*($i+1)] [expr $y+20+60] \
				-outline black
		$c create text [expr $xmin+100+40*$i+20] [expr $y+20+30+16] \
				-text "?" -font canvas:label -tag "_p:c:$couple"
		incr i
	}
	# par place
	$c create rectangle $xmin [expr $y+20+60] [expr $xmin+100] [expr $y+20+120] \
			-fill $gui(color:lightyellow) -outline black
	$c create text [expr $xmin+50] [expr $y+20+60+31] \
			-text $msg(byPlace) -font canvas:label
	set i 0
	foreach couple $couples {
		$c create rectangle [expr $xmin+100+40*$i] [expr $y+20+60] \
				[expr $xmin+100+40*($i+1)] [expr $y+20+90] \
				-fill $gui(color:yellow) -outline black
		$c create text [expr $xmin+100+40*$i+20] [expr $y+20+60+16] \
				-text [expr $i+1] -font canvas:label
		$c create rectangle [expr $xmin+100+40*$i] [expr $y+20+90] \
				[expr $xmin+100+40*($i+1)] [expr $y+20+120] \
				-outline black
		$c create text [expr $xmin+100+40*$i+20] [expr $y+20+90+16] \
				-text "?" -font canvas:label -tag "_p:r:$i"
		incr i
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::notes:judge {f c judge args} {
variable gui
variable $f
upvar 0 $f folder
variable event
upvar spaceX spaceX spaceY spaceY startX startX startY startY wC wC wN wN


	# init
	set couples $folder(couples:finale)

	# parse les options
	set label "label"
	set labelcolor $gui(color:lightyellow)
	set color $gui(color:yellow)
	set editable false
	set column 0
	set row 0
	foreach {option value} $args {
		switch -- $option {
			-label		{ set label $value }
			-labelcolor	{ set labelcolor $value }
			-color		{ set color $value }
			-editable	{ set editable $value }
			-row		{ set row $value }
			-column		{ set column $value }
		}
	}

	# calcule la taille du tableau
	set nb [llength $couples]

	set xmin [expr $startX + ($spaceX + $wC+$nb*$wN)*$column]
	set ymin [expr $startY + ($spaceY + 20+$nb*16)*$row]
	set xmax [expr $xmin + $wC+$nb*$wN]
	set ymax [expr $ymin + 20+$nb*16]

	# label avec nom du juge
	if {$gui(pref:names:finale)} {
		$c create rectangle $xmin $ymin $xmax [expr $ymin+20] -fill $labelcolor -outline black \
				-tags "judge:$judge jtip:$judge key:$judge"
		$c create rectangle [expr $xmin +$wC] $ymin $xmax [expr $ymin+20] -fill $labelcolor -outline black \
				-tags "judge:$judge key:$judge"
		$c create text [expr $xmin+$wC/2] [expr $ymin+11] -text $label -font canvas:label -tags "key:$judge"
		$c create text [expr $xmin+$wC+($xmax-$xmin-$wC)/2] [expr $ymin+11] -text $event(name:$judge) \
				-font canvas:label -tags "key:$judge"
	} else {
		$c create rectangle $xmin $ymin $xmax [expr $ymin+20] -fill $labelcolor -outline black \
				-tags "judge:$judge jtip:$judge key:$judge"
		$c create text [expr $xmin+($xmax-$xmin)/2] [expr $ymin+11] -text $label -font canvas:label \
				-tags "jtip:$judge key:$judge"
		DynamicHelp::register $c canvasballoon "jtip:$judge" $event(name:$judge)
	}
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

	# table pour l'attribution des places
	set i 1
#puts ">>>> $judge"
	foreach couple $couples {
		$c create rectangle $xmin [expr $ymin+20+16*($i-1)] \
				[expr $xmin+$wC] [expr $ymin+20+16*$i] -fill $color -outline black \
				-tags "couple:$judge:$i couple:$judge:all ctip:$couple"
		$c create text [expr $xmin+$wC/2] [expr $ymin+20+16*($i-1)+9] \
				-text $couple -font canvas:couple -tags "ctip:$couple"
		DynamicHelp::register $c canvasballoon "ctip:$couple" [couple:name $f $couple]

		set j 1
		foreach dummy $couples {
			# dans les tags : n(otes)/c(ouple) + r=rectangle, t=text, f=frame
			set id1 [$c create rectangle [expr $xmin+$wC+$wN*($j-1)] [expr $ymin+20+16*($i-1)] \
							[expr $xmin+$wC+$wN*$j] [expr $ymin+20+16*$i] -fill gray95 -outline black \
							-tags "$judge:$j:f $judge:$i:r $judge:$j:nr $judge:$i:$j:r $judge:r"]
			set id2 [$c create text [expr $xmin+$wC+$wN*($j-1)+$wN/2] [expr $ymin+20+16*($i-1)+9] \
							-text $j -font canvas:place \
							-tags "$judge:$i:ct $judge:$j:t $judge:$i:$j:t $judge:t"]

			if {$editable == "true"} {
				$c bind $id1 <1> "skating::notes:toggle [list $f] $c $judge $i $j"
				$c bind $id2 <1> "skating::notes:toggle [list $f] $c $judge $i $j"
			}

			incr j
		}
		incr i
	}
}

proc skating::notes:setFromDance {f c dance} {
variable $f
upvar 0 $f folder
variable gui


	# génère list vide
	set empty {}
	foreach judge $folder(judges:finale) {
		lappend empty 0
	}

	# affecte les notes
	foreach couple $folder(couples:finale) {
		# si l'info n'existe pas pour les couples, on la crée
		if {![info exists folder(notes:finale:$couple:$dance)]} {
			set folder(notes:finale:$couple:$dance) $empty
			continue
		}
	}
	notes:display $f $c $dance $folder(judges:finale)
}

proc skating::notes:display {f c dance judges} {
variable $f
upvar 0 $f folder
variable gui


#puts "skating::notes:display {$f $c '$dance' '$judges'}"

	# liste des couples
	set couples $folder(couples:finale)

	# calcule les conflits
	foreach judge $judges {
		set conflicts($judge) 0
#		set notGiven($judge) [expr {0x7FFFFFFF >> (31-[llength $couples])}]
		set notes($judge) 0
	}
	set i 1
	foreach couple $couples {
		set j 1
		foreach note $folder(notes:finale:$couple:$dance) judge $folder(judges:finale) {
			if {[lsearch $judges $judge] == -1} {
				continue
			}
			set mask [expr {1<<(int($note)-1)}]
			if {$notes($judge) & $mask} {
				set conflicts($judge) [expr {$conflicts($judge) | $mask}]
			}
#			set notGiven($judge) [expr {$notGiven($judge) & ~$mask}]
			set notes($judge) [expr {$notes($judge) | $mask}]
#puts "$i / $j : note=$note  /  notes($judge) = [format %04x $notes($judge)] conflicts($judge) = [format %04x $conflicts($judge)] notGiven($judge) = [format %04x $notGiven($judge)]"
			incr j
		}
		incr i
	}
	#---- affiche les notes & les conflits
	# on réinitialise tout
	foreach judge $judges {
		$c itemconfigure $judge:r -fill {}
		$c itemconfigure $judge:t -fill black
#  		set mask 1
#  		set i 1
#  		set notSet($judge) [list ]
#  		foreach dummy $couples {
#  			if {$notGiven($judge) & $mask} {
#  				lappend notSet($judge) $i
#  			}
#  			set mask [expr {$mask << 1}]
#  			incr i
#  		}
	}
	set i 1
	# pour chaque couple
	foreach couple $couples {
		set j 1
		# on affiche sa note pour chaque juge
		foreach note $folder(notes:finale:$couple:$dance) judge $folder(judges:finale) {
#puts "string first $judge '$judges' = [lsearch $judges $judge]"
			if {[lsearch $judges $judge] == -1} {
				continue
			}
			if {$note == 0} {
#puts "$i / $j -- note = 0"
  				$c itemconfigure $judge:$i:r -fill {}
			} else {
				set mask [expr {1<<(int($note)-1)}]
#puts "$i / $j -- note = $note mask = [format %04x $mask] notes($judge) = [format %04x $notes($judge)] conflicts($judge) = [format %04x $conflicts($judge)]"
				if {$conflicts($judge) & $mask} {
 					$c itemconfigure $judge:$note:t -fill black
 					$c itemconfigure $judge:$i:$note:r -fill $gui(color:placebad)
				} else {
 					$c itemconfigure $judge:$note:t -fill gray80
 					$c itemconfigure $judge:$i:$note:r -fill $gui(color:place)
 					$c itemconfigure $judge:$i:$note:t -fill black
				}
			}
			incr j
		}
		incr i
	}

	# affiche les exclusions
	set i 1
	if {[info exists folder(exclusion:finale:$dance)]} {
		set nb [expr [llength $couples]-([llength $folder(exclusion:finale:$dance)]-1)]
		foreach couple $couples {
			if {[lsearch $folder(exclusion:finale:$dance) $couple] != -1} {
				set j 1
				foreach note $folder(notes:finale:$couple:$dance) judge $folder(judges:finale) {
					if {[lsearch $judges $judge] == -1} {
						continue
					}
					$c itemconfigure $judge:$i:r -fill $gui(color:exclusion)
					$c itemconfigure $judge:$i:ct -fill $gui(color:exclusion:text)
					$c itemconfigure $judge:$nb:nr -fill $gui(color:exclusion)
					$c itemconfigure $judge:$nb:t -fill $gui(color:exclusion:text)
					incr j
				}
				incr nb
			}
			incr i
		}
	}
}

proc skating::notes:toggle {f c p i j {fromKeyboard 0}} {
variable $f
upvar 0 $f folder
variable gui


TRACE ">> $f $c $p $i $j"
	set dance $gui(v:dance)
	# liste des couples
	set couples $folder(couples:finale)

	# vérifie si on peut éditer le couple (non exclus)
	if {[info exists folder(exclusion:finale:$dance)]} {
		if {[lsearch $folder(exclusion:finale:$dance) [lindex $couples [expr $i-1]]] != -1} {
error "can't edit $p $i $j -- bad couple"
			return 0
		}
		set nb [expr [llength $couples]-([llength $folder(exclusion:finale:$dance)]-1)]
		if {$j >= $nb} {
error "can't edit $p $i $j -- bad place"
			return 0
		}
	}

	# endroit où effectuer le changement
	set judge [lsearch -exact $folder(judges:finale) $p]
	set name notes:finale:[lindex $couples [expr $i-1]]:$dance

	# regarde si double saisie de couple est autorisée
	if {0 && $fromKeyboard && $gui(pref:keyboard:toggleling) == 0 && [lindex $folder($name) $judge] != 0} {
TRACE "double input"
		bell
		return 0
	}

	# affecte la nouvelle note
#puts -nonewline "lreplace '$folder($name)'($name) $judge $judge $j"
	set folder($name) [lreplace $folder($name) $judge $judge $j]
#puts " = $folder($name)"

	# modification des données
	set gui(v:modified) 1

	# mise à jour du résultat
	notes:display $f $c $dance $p
	notes:result $f $c
	return 1
}

#-------------------------------------------------------------------------------------------------

proc skating::notes:result {f c} {
variable gui
variable $f
upvar 0 $f folder

	set dance $gui(v:dance)

	# liste des couples
	set couples $folder(couples:finale)

	if {[check:dance $f $gui(v:dance)]} {
		set classed 1
		# effectue le classement
 		class:dance $f $gui(v:dance)
	} else {
		set classed 0
		# valeurs indéfinies
		foreach couple $couples {
			set folder(t:place:$couple) "?"
		}
	}

	# affiche le résultat -- par couple
	set tmp {}
	foreach couple $couples {
		$c itemconfigure _p:c:$couple -text $folder(t:place:$couple)
		lappend tmp [list $couple $folder(t:place:$couple)]
	}
	if {$classed} {
		set tmp [lsort -real -index 1 $tmp]
	}
	# affiche le résultat -- par place
	set i 0
	foreach dummy $couples {
		if {$classed} {
			$c itemconfigure _p:r:$i -text [lindex [lindex $tmp $i] 0]
		} else {
			$c itemconfigure _p:r:$i -text "?"
		}
		incr i
	}

	# affiche les détails
	if {$classed && $gui(pref:explain:finale)} {
		# ok
		notes:result:explain $f $c
	} elseif {$gui(pref:explain:finale)} {
		# résultat incomplets ou mauvais 
		$c delete "ex"
	}

	# check résultat final
	if {$folder(mode) == "ten"} {
		ten:rounds:check $f $dance "result"
	} else {
		ranking:check $f
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::notes:result:explain {f c} {
global msg
variable gui
variable $f
upvar 0 $f folder
upvar couples couples dance dance

	# si les notes sont déjà dessinnées, on quitte
	if {[llength [$c find withtag "ex"]]} {
		return
	}

	# liste triée des juges
	set level $gui(v:round)
	set judges [lsort -command skating::event:judges:sort $folder(judges:$level)]

	# variables
	set startX 10
	set spaceX 20
	set spaceY 15
	set hBold 20
	set hNormal 20

	set wC 30
	set wJ 20
	set twJ [expr $wJ*[llength $judges]]
	set wP 40
	set twP [expr $wP*[llength $couples]+$wP/3]
	set wR 30
	set width [expr $wC+$twJ+$twP+$wR]

	# calcul x,y de départ
	set left $startX
	set y [expr [lindex [$c bbox all] 3]+2*$spaceY]

	# affichage des explications
	$c create rectangle $left $y [expr $wC+$left] [expr $y+$hNormal] \
			-fill $gui(color:lightyellow) -outline black -tags "ex"
	set j 0
	foreach judge $judges {
		$c create rectangle [expr $left+$wC+$wJ*$j] $y \
				[expr $left+$wC+$wJ*($j+1)] [expr $y+$hNormal] \
				-fill $gui(color:lightyellow) -outline black -tags "ex"
		$c create text [expr $left+$wC+$wJ*($j+0.5)] [expr $y+$hNormal/2+1] \
				-text $judge -font canvas:label -tags "ex"
		incr j
	}
	#----
	set j 0
	$c create rectangle [expr $left+$wC+$twJ] $y \
			[expr $left+$wC+$twJ+$twP] [expr $y+$hNormal] \
			-fill $gui(color:lightyellow) -outline black -tags "ex"
	foreach dummy $couples {
		$c create text [expr $left+$wC+$twJ+$wP*($j+0.5)] [expr $y+$hNormal/2+1] \
				-text [expr $j+1] -font canvas:label -tags "ex"
		incr j
	}
	#----
	$c create rectangle [expr $left+$wC+$twJ+$twP] $y [expr $left+$width] [expr $y+$hNormal] \
			-fill $gui(color:lightyellow) -outline black -tags "ex"
	$c create text [expr $left+$wC+$twJ+$twP+$wR/2] [expr $y+$hNormal/2+1] \
			-text $msg(prt:placeAbbrev) -font canvas:label -tags "ex"
	set y [expr $y+$hNormal]
	#==== résultats pour cette dance
	foreach couple $couples {
		$c create rectangle $left $y [expr $left+$wC] [expr $y+$hNormal] \
				-fill $gui(color:yellow) -outline black -tags "ex"
		$c create text [expr $left+$wC/2] [expr $y+$hNormal/2+1] \
				-text "$couple" -font canvas:label -tags "ex"
		# vérifie si le couple est exclus
		if {[info exists folder(exclusion:finale:$dance)] &&
				[lsearch $folder(exclusion:finale:$dance) $couple] != -1} {
			set excluded 1
		} else {
			set excluded 0
		}
		#---- notes
		set i 0
		foreach judge $judges {
			set j [lsearch $folder(judges:finale) $judge]
			$c create rectangle [expr $left+$wC+$wJ*$i] $y \
					[expr $left+$wC+$wJ*($i+1)] [expr $y+$hNormal] -outline black -tags "ex"
			if {$excluded} {
				set text "-"
			} else {
				set text [lindex $folder(notes:finale:$couple:$dance) $j]
			}
			$c create text [expr $left+$wC+$wJ*($i+0.5)] [expr $y+$hNormal/2+1] \
					-text $text -font canvas:place -tags "ex"
			incr i
		}
		#---- data
		$c create rectangle [expr $left+$wC+$twJ] $y \
				[expr $left+$wC+$twJ+$twP] [expr $y+$hNormal] -outline black -tags "ex"
		set i 0
		foreach dummy $couples {
			if {!$excluded} {
				finale:mark $c 1 \
						[lindex $folder(prt:$dance:mark+:$couple) $i] \
						[lindex $folder(prt:$dance:marktotal:$couple) $i] \
						[expr $left+$wC+$twJ+$wP*($i+0.5)] $y $hNormal
			} else {
				$c create text [expr $left+$wC+$twJ+$wP*($i+0.5)] [expr $y+$hNormal/2+1] \
						-text "-" -font canvas:place -tags "ex"
			}
			incr i
		}
		#---- place
		$c create rectangle [expr $left+$wC+$twJ+$twP] $y \
				[expr $left+$width] [expr $y+$hNormal] -outline black -tags "ex"
		$c create text [expr $left+$wC+$twJ+$twP+$wR/2] [expr $y+$hNormal/2+1] \
				-text $folder(t:place:$couple) -font canvas:place -tags "ex"
		#----
		set y [expr $y+$hNormal]
	}

	# ajuste le scrolling
	set bbox [$c bbox all]
	set x [expr [lindex $bbox 2]+$spaceX]
	set y [expr [lindex $bbox 3]+$spaceY]
	if {$x < [winfo width $c]} { set x [winfo width $c]}
	if {$y < [winfo height $c]} { set y [winfo height $c] }
	$c configure -scrollregion [list 0 0 $x $y]
}


#=================================================================================================
#
#	Gestion du résultat final (classement sur un dossier)
#
#=================================================================================================


proc skating::gui:ranking {top f round} {
variable $f
upvar 0 $f folder
variable gui


	# création du canvas pour les grilles de notation
	set c [canvas $top.canvas -highlightthickness 0 -bg gray95 -height 1]
	# binding pour scrolling des canvas
	bind $c <Visibility> "focus $c"
	bind $c <Up> "$c yview scroll -1 units"
	bind $c <Down> "$c yview scroll +1 units"
	bind $c <Prior> "$c yview scroll -1 pages"
	bind $c <Next> "$c yview scroll +1 pages"
	bind $c <Left> "$c xview scroll -1 units"
	bind $c <Right> "$c xview scroll +1 units"
	bind $c <Home> "$c xview scroll -1 pages"
	bind $c <End> "$c xview scroll +1 pages"

	# liste des couples
	set couples $folder(couples:finale)

	# table pour le classement final
	ranking:drawResult $c $f
	ranking:drawSummary $c $f

	# zone pour le scrolling
	set spaceX 20
	set spaceY 15
	set bbox [$c bbox all]
	set x [expr [lindex $bbox 2]+$spaceX]
	set y [expr [lindex $bbox 3]+$spaceY]
	if {$x < [winfo width $c]} { set x [winfo width $c]}
	if {$y < [winfo height $c]} { set y [winfo height $c] }
	$c configure -scrollregion [list 0 0 $x $y]
	# retourne le path
	set gui(w:ranking:$round) $c
	return $c
}

#-------------------------------------------------------------------------------------------------

proc skating::ranking:drawResult {c f} {
global msg
variable $f
upvar 0 $f folder
variable event
variable gui
upvar couples couples

	# position
	set nb [llength $folder(couples:finale)]
	set xmin 10
	set xmax [expr $xmin+$nb*40+100]
	set y 10

	# titre
	$c create rectangle $xmin $y $xmax [expr $y+20] \
			-fill $gui(color:lightyellow) -outline black
	$c create text [expr $xmin+($xmax-$xmin)/2] [expr $y+11] \
			-text $msg(rankingFinal) -font canvas:label
	# par couple
	$c create rectangle $xmin [expr $y+20] [expr $xmin+100] [expr $y+20+60] \
			-fill $gui(color:lightyellow) -outline black
	$c create text [expr $xmin+50] [expr $y+20+31] \
			-text $msg(byCouple) -font canvas:label
	set i 0
	foreach couple $couples {
		$c create rectangle [expr $xmin+100+40*$i] [expr $y+20] \
				[expr $xmin+100+40*($i+1)] [expr $y+20+30] \
				-fill $gui(color:yellow) -outline black -tags "ctip:$couple"
		$c create text [expr $xmin+100+40*$i+20] [expr $y+20+16] \
				-text $couple -font canvas:label -tags "ctip:$couple"
		DynamicHelp::register $c canvasballoon "ctip:$couple" [couple:name $f $couple]
		$c create rectangle [expr $xmin+100+40*$i] [expr $y+20+30] \
				[expr $xmin+100+40*($i+1)] [expr $y+20+60] \
				-outline black
		$c create text [expr $xmin+100+40*$i+20] [expr $y+20+30+16] \
				-text "?" -font canvas:label -tag "_r:c:$couple"
		incr i
	}
	# par place
	$c create rectangle $xmin [expr $y+20+60] [expr $xmin+100] [expr $y+20+120] \
			-fill $gui(color:lightyellow) -outline black
	$c create text [expr $xmin+50] [expr $y+20+60+31] \
			-text $msg(byPlace) -font canvas:label
	set i 0
	foreach couple $couples {
		$c create rectangle [expr $xmin+100+40*$i] [expr $y+20+60] \
				[expr $xmin+100+40*($i+1)] [expr $y+20+90] \
				-fill $gui(color:yellow) -outline black
		$c create text [expr $xmin+100+40*$i+20] [expr $y+20+60+16] \
				-text [expr $i+1] -font canvas:label
		$c create rectangle [expr $xmin+100+40*$i] [expr $y+20+90] \
				[expr $xmin+100+40*($i+1)] [expr $y+20+120] \
				-outline black
		$c create text [expr $xmin+100+40*$i+20] [expr $y+20+90+16] \
				-text "?" -font canvas:label -tag "_r:r:$i"
		incr i
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::ranking:drawSummary {c f} {
global msg
variable $f
upvar 0 $f folder
variable gui
upvar couples couples

	# calcule valeurs
	set wdance 40
	set wtot 60
	set wcomment 250
	# position
	set nb [llength $folder(dances)]
	set limits [$c bbox all]
	set xmin 10
	set xmax [expr $xmin + 30+$nb*$wdance+$wtot+$wcomment]
	set y [expr [lindex $limits 3]-1 + 30]

	# titre
	$c create rectangle $xmin $y $xmax [expr $y+20] \
			-fill $gui(color:lightyellow) -outline black
	$c create text [expr $xmin+($xmax-$xmin)/2] [expr $y+11] \
			-text $msg(summary) -font canvas:label

	# labels
	set y [expr $y+20]
	$c create rectangle $xmin $y [expr $xmin+30] [expr $y+20] -outline black -fill $gui(color:lightyellow)
	set j 0
	if {$folder(mode) == "ten"} {
		set dances $folder(v:overall:dances)
	} else {
		set dances $folder(dances)
	}
	foreach d $dances {
		$c create rectangle [expr $xmin+30+$wdance*$j] [expr $y] \
				[expr $xmin+30+$wdance*($j+1)] [expr $y+20] \
				-outline black -fill $gui(color:lightyellow) -tags "d$j"
		$c create text [expr $xmin+30+$wdance*$j+$wdance/2] [expr $y+11] \
				-text [firstLetters $d] -font canvas:label -tags "d$j"
		if {$folder(mode) == "ten"} {
			$c bind "d$j" <1> "skating::gui:select 0 $f.[join $d _]; \
							   set skating:dblclick 1; \
							   NoteBook::raise $skating::gui(w:notebook) result"
		} else {
			$c bind "d$j" <1> "skating::gui:select 0 $f.finale; \
							   set skating:dblclick 1; \
							   NoteBook::raise $skating::gui(w:notebook) [join $d _]"
		}
		incr j
	}
	# -- totaux
	$c create rectangle [expr $xmin+30+$wdance*$j] [expr $y] \
			[expr $xmin+30+$wdance*$j+$wtot] [expr $y+20] \
			-outline black -fill $gui(color:lightyellow)
	$c create text [expr $xmin+30+$wdance*$j+$wtot/2] [expr $y+11] \
			-text $msg(tot) -font canvas:label
	#-- commentaires
	$c create rectangle [expr $xmin+30+$wdance*$j+$wtot] [expr $y] \
			[expr $xmin+30+$wdance*$j+$wtot+$wcomment] [expr $y+20] \
			-outline black -fill $gui(color:lightyellow)
	$c create text [expr $xmin+30+$wdance*$j+$wtot+$wcomment/2] [expr $y+11] \
			-text $msg(remarks) -font canvas:label

	# classement par danse
	set y [expr $y+20]
	set color $gui(color:yellow)
	set i 0
	foreach couple $couples {
		$c create rectangle $xmin [expr $y+16*$i] \
				[expr $xmin+30] [expr $y+16*($i+1)] -fill $color -outline black \
				-tags "ctip:$couple"
		$c create text [expr $xmin+15] [expr $y+16*$i+9] \
				-text $couple -font canvas:couple -tags "ctip:$couple"

		set j 0
		foreach dummy $folder(dances) {
			$c create rectangle [expr $xmin+30+$wdance*$j] [expr $y+16*$i] \
					[expr $xmin+30+$wdance*($j+1)] [expr $y+16*($i+1)] -outline black
			$c create text [expr $xmin+30+$wdance*$j+$wdance/2] [expr $y+16*$i+9] \
					-text "?" -font canvas:place -tags "sum:$couple:$j"

			incr j
		}
		# -- totaux
		$c create rectangle [expr $xmin+30+$wdance*$j] [expr $y+16*$i] \
				[expr $xmin+30+$wdance*$j+$wtot] [expr $y+16*($i+1)] \
				-outline black -fill $gui(color:lightyellow)
		$c create text [expr $xmin+30+$wdance*$j+$wtot/2] [expr $y+16*$i+9] \
				-text "?" -font canvas:place -tags "sum:$couple:tot"
		# -- commentaires
		$c create rectangle [expr $xmin+30+$wdance*$j+$wtot] [expr $y+16*$i] \
				[expr $xmin+30+$wdance*$j+$wtot+$wcomment] [expr $y+16*($i+1)] \
				-outline black -fill $gui(color:lightyellow)
		$c create text [expr $xmin+30+$wdance*$j+$wtot+5] [expr $y+16*$i+9] \
				-text "?" -font canvas:place -tags "sum:$couple:com" -anchor w
		# suivant
		incr i
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::ranking:check {f} {
variable $f
upvar 0 $f folder
variable gui


	if {[class:dances $f]} {
		set state normal
		set result 1
		set bg #adf3b1
		set abg #b6ffba
	} else {
		set state disabled
		set result 0
		set bg #f3b4ad
		set abg #ffffff
	}

	global tcl_platform
	if {$tcl_platform(platform) == "windows"} {
		set abg $bg
	}

	if {$folder(mode) == "normal"} {
		# mode classique
		NoteBook::itemconfigure $gui(w:notebook) "result" -state $state \
				-background $bg -selectedbackground $bg -activebackground $abg
	}
	# montre éventuellement l'entrée pour les Resultats
	manage:rounds:adjustTreeColor $f

	# retourne le résultat
	set result
}

#-------------------------------------------------------------------------------------------------

proc check:duplicate {item list} {
	set nb 0
	foreach i $list {
		if {$i == $item} {
			incr nb
		}
	}
	return [expr $nb > 1]
}

proc skating::ranking:display {f round} {
global msg
variable $f
upvar 0 $f folder
variable gui


	set c $gui(w:ranking:$round)

	# effectue le classement
	if {$folder(mode) == "ten"} {
		class:folder $f
	} else {
		class:result $f
	}

	# liste des couples
	set couples $folder(couples:finale)

	# mise à jour du classement
	# -- par couple
	set tmp {}
	set i 0
	foreach couple $couples rank $folder(result) {
		if {[check:duplicate $rank $folder(result)]} {
			set color "red"
		} else {
			set color "black"
		}
		$c itemconfigure "_r:c:$couple" -text $rank -fill $color
		lappend tmp [list $couple $rank]
		incr i
	}
	# -- par place
	set tmp [lsort -real -index 1 $tmp]
	set i 0
	foreach dummy $couples {
		set rank [lindex [lindex $tmp $i] 1]
		if {[check:duplicate $rank $folder(result)]} {
			set color "red"
		} else {
			set color "black"
		}
		$c itemconfigure "_r:r:$i" -text [lindex [lindex $tmp $i] 0] -fill $color
		incr i
	}

	# mise à jour du résumé
	set i 0
	foreach dummy $folder(dances) {
		# classement par danse
		foreach couple $couples {
			$c itemconfigure "sum:$couple:$i" \
					-text [lindex $folder(places:$couple) $i]
		}
		incr i
	}

	set rules(10) {}
	set rules(11) {}
	set rules(12) {}
	set rules(13) {}
	set rules(14) {}
	set rules(15) {}
	set rules(16) {}
	set rules(17) {}
	set i 0
	foreach couple $couples {
		# total
		$c itemconfigure "sum:$couple:tot" \
				-text [format "%g" [lindex $folder(totals) $i]]
		# remarques
		set text ""
		# 1. exclusions
		set first 1
		set excluded ""
		foreach dance $folder(dances) {
			if {![info exists folder(exclusion:finale:$dance)]} {
				continue
			}
			if {[lsearch $folder(exclusion:finale:$dance) $couple] != -1} {
				if {$first} {
					set first 0
				} else {
					append excluded ", "
				}
				append excluded [firstLetters $dance]
			}
		}
		if {$excluded != ""} {
			append text "$msg(excludedFrom) $excluded. "
		}
		# 2. applications règles 10&11
		set rule [lindex $folder(rules) $i]
		if {$rule >= 10} {
			lappend rules(10) $couple
			append text "$msg(rule) 10"
		}
		if {$rule >= 11} {
			lappend rules(11) $couple
			append text " & 11"
		}
		if {$rule >= 12} {
			lappend rules(12) $couple
			append text " & 10"
		}
		if {$rule >= 13} {
			lappend rules(13) $couple
			append text " & 11"
		}
		if {$rule >= 14} {
			lappend rules(14) $couple
			append text " & 10"
		}
		if {$rule >= 15} {
			lappend rules(15) $couple
			append text " & 11"
		}
		if {$rule >= 16} {
			lappend rules(16) $couple
		}
		if {$rule >= 17} {
			lappend rules(17) $couple
		}
		$c itemconfigure "sum:$couple:com" -text $text
		# suivant
		incr i
	}

	# affiche les détails
	$c delete "ex"
	if {$gui(pref:explain:finale)} {
		# ok
		ranking:explain $f $c
	}
}

#----------------------------------------------------------------------------------------------

proc skating::ranking:explain {f c} {
global msg
variable gui
variable $f
upvar 0 $f folder
upvar rules rules couples couples


#puts "<skating::ranking:explain> $f"
	# variables
	set startX 10
	set spaceX 20
	set spaceY 15
	set hBold 20
	set hNormal 20

	# calcul x,y de départ
	set left $startX
	set y [expr [lindex [$c bbox all] 3]+$spaceY]

	#==== explications (Règles 10 & 11 & suivantes)
	set already11 0
	if {$gui(pref:print:explain) && [llength $rules(10)]} {
		ranking:explain_rules 10 11 1
	}
	# second niveau de 10 & 11
	if {$gui(pref:print:explain) && [llength $rules(12)]} {
		ranking:explain_rules 12 13 0
	}
	# troisième niveau de 10 & 11
	if {$gui(pref:print:explain) && [llength $rules(14)]} {
		ranking:explain_rules 14 15 0
	}
	# quatrième niveau de 10 & 11
	if {$gui(pref:print:explain) && [llength $rules(16)]} {
		ranking:explain_rules 16 17 0
	}

	# ajuste le scrolling
	set bbox [$c bbox all]
	set x [expr [lindex $bbox 2]+$spaceX]
	set y [expr [lindex $bbox 3]+$spaceY]
	if {$x < [winfo width $c]} { set x [winfo width $c]}
	if {$y < [winfo height $c]} { set y [winfo height $c] }
	$c configure -scrollregion [list 0 0 $x $y]
}

proc skating::ranking:explain_rules {rule10 rule11 needheader} {
variable event
variable gui
global msg

upvar couples couples
upvar left left y y c c f f folder folder rules rules already11 already11
upvar hBetweenExplain hBetweenExplain hNormal hNormal hBold hBold

	# calcul hauteur
	set need11 [llength $rules($rule11)]

	#---- taille
	set wC 30
	set wP 40
	set twP [expr $wP*[llength $couples]+$wP/3]
	if {$need11 || $already11} {
		set width [expr $wC+2*$twP]
		set already11 1
	} else {
		set width [expr $wC+$twP]
	}

	#---- header
	if {$needheader} {
		$c create rectangle $left $y [expr $left+$wC] [expr $y+$hBold] \
				-fill $gui(color:lightyellow) -outline black -tags "ex"
		$c create rectangle [expr $left+$wC] $y [expr $left+$wC+$twP] [expr $y+$hBold] \
				-fill $gui(color:lightyellow) -outline black -tags "ex"
		$c create text [expr $left+$wC+$twP/2] [expr $y+$hBold/2+1] \
				-text "$msg(prt:rule) 10" -font canvas:label -tags "ex"
		if {$need11} {
			$c create rectangle [expr $left+$wC+$twP] $y [expr $left+$width] [expr $y+$hBold] \
					-fill $gui(color:lightyellow) -outline black -tags "ex"
			$c create text [expr $left+$wC+$twP*3/2] [expr $y+$hBold/2+1] \
					-text "$msg(prt:rule) 11 ($msg(prt:majority): $folder(t:majority))" -font canvas:label -tags "ex"
		}
		set y [expr $y+$hBold]
		#----
		set j 0
		$c create rectangle [expr $left] $y \
				[expr $left+$wC] [expr $y+$hNormal] \
				-fill $gui(color:lightyellow) -outline black -tags "ex"
		$c create rectangle [expr $left+$wC] $y \
				[expr $left+$wC+$twP] [expr $y+$hNormal] \
				-fill $gui(color:lightyellow) -outline black -tags "ex"
		if {$need11} {
			$c create rectangle [expr $left+$wC+$twP] $y \
					[expr $left+$wC+2*$twP] [expr $y+$hNormal] \
					-fill $gui(color:lightyellow) -outline black -tags "ex"
		}
		foreach dummy $couples {
			$c create text [expr $left+$wC+$wP*($j+0.5)] [expr $y+$hNormal/2+1] \
					-text [expr $j+1] -font canvas:place -tags "ex"
			if {$need11} {
				$c create text [expr $left+$wC+$twP+$wP*($j+0.5)] [expr $y+$hNormal/2+1] \
						-text [expr $j+1] -font canvas:place -tags "ex"
			}
			incr j
		}
		set y [expr $y+$hNormal]
	} else {
		incr y 5
	}
	#---- données explicatives
	foreach couple $rules($rule10) {
		$c create rectangle $left $y [expr $left+$wC] [expr $y+$hNormal] \
				-fill $gui(color:yellow) -outline black -tags "ex"
		$c create text [expr $left+$wC/2] [expr $y+$hNormal/2+1] \
				-text "$couple" -font canvas:place -tags "ex"
		$c create rectangle [expr $left+$wC] $y \
				[expr $left+$wC+$twP] [expr $y+$hNormal] -outline black -tags "ex"
		if {$need11} {
			$c create rectangle [expr $left+$wC+$twP] $y \
					[expr $left+$wC+2*$twP] [expr $y+$hNormal] -outline black -tags "ex"
		}
		set i 0
		foreach dummy $couples {
			# règle 10
			finale:mark $c 0 \
					[lindex $folder(prt:__${rule10}__:mark+:$couple) $i] \
					[lindex $folder(prt:__${rule10}__:marktotal:$couple) $i] \
					[expr $left+$wC+$wP*($i+0.5)] $y $hNormal
			# règle 11
			if {!$need11 || [lsearch $rules($rule11) $couple] == -1} {
				incr i
				continue
			}
			finale:mark $c 0 \
					[lindex $folder(prt:__${rule11}__:mark+:$couple) $i] \
					[lindex $folder(prt:__${rule11}__:marktotal:$couple) $i] \
					[expr $left+$wC+$twP+$wP*($i+0.5)] $y $hNormal
			# suivant
			incr i
		}
		set y [expr $y+$hNormal]
	}
}


#=================================================================================================
#
#	Gestion des couples exclus dans les finales
#
#=================================================================================================

proc skating::finale:exclusion:display {f dance} {
variable $f
upvar 0 $f folder
variable gui


	set sub $gui(w:exclusion:$dance)
	# colorie les boutons
	if {![info exists folder(exclusion:finale:$dance)]} {
		return
	}
	foreach c $folder(exclusion:finale:$dance) {
		$sub.$c configure -bg $gui(color:exclusion:on:bg) -activebackground $gui(color:exclusion:on:abg) -relief sunken
	}
}

proc skating::finale:exclusion:toggle {f dance c} {
variable $f
upvar 0 $f folder
variable gui


	if {![info exists folder(exclusion:finale:$dance)]} {
		set folder(exclusion:finale:$dance) {}
	}
	# liste des couples
	set couples $folder(couples:finale)

	# ON ou OFF ?
	if {[set idx [lsearch $folder(exclusion:finale:$dance) $c]] == -1} {
		# ON
		lappend folder(exclusion:finale:$dance) $c
		$gui(w:exclusion:$dance).$c configure -bg $gui(color:exclusion:on:bg) -activebackground $gui(color:exclusion:on:abg) -relief sunken
		# change display of grids for notes
		finale:exclusion:activate $f $dance $c
	} else {
		# OFF
		set folder(exclusion:finale:$dance) [lreplace $folder(exclusion:finale:$dance) $idx $idx]
		$gui(w:exclusion:$dance).$c configure -bg $gui(color:exclusion:off:bg) -activebackground $gui(color:exclusion:off:abg) -relief raise
		# change display of grids for notes
		finale:exclusion:deactivate $f $dance $c
	}
}

proc skating::finale:exclusion:activate {f dance couple} {
variable $f
upvar 0 $f folder
variable gui
upvar couples couples

	# vérifie si aucun couple n'occupe la place
	set nb [expr [llength $couples]-([llength $folder(exclusion:finale:$dance)]-1)]
	foreach c $couples {
		set idx [lsearch $folder(notes:finale:$c:$dance) $nb]
		if {$idx != -1} {
#puts "removing notes $nb from $c/'notes:finale:$c:$dance'"
			set folder(notes:finale:$c:$dance) [lreplace $folder(notes:finale:$c:$dance) $idx $idx 0]
		}
	}
	# attribution de la note moyenne aux exclus
	finale:exclusion:setAverageNote $f $dance
	# mise-à-jour affichage
	notes:display $f $gui(w:canvas:finale:$dance) $dance $folder(judges:finale)
	notes:result $f $gui(w:canvas:finale:$dance)
}

proc skating::finale:exclusion:deactivate {f dance couple} {
variable $f
upvar 0 $f folder
variable gui
upvar couples couples

	# re-initialise la note à zéro
	set j 0
	foreach dummy $folder(judges:finale) {
		set folder(notes:finale:$couple:$dance) [lreplace $folder(notes:finale:$couple:$dance) $j $j 0]
		incr j
	}
	# attribution de la note moyenne aux exclus
	finale:exclusion:setAverageNote $f $dance
	# mise-à-jour affichage
	notes:display $f $gui(w:canvas:finale:$dance) $dance $folder(judges:finale)
	notes:result $f $gui(w:canvas:finale:$dance)
}


proc skating::finale:exclusion:setAverageNote {f dance} {
variable $f
upvar 0 $f folder
variable gui
upvar couples couples

	# attribue une place
	set note [expr [llength $couples]-([llength $folder(exclusion:finale:$dance)]-1)/2.0]
	foreach c $folder(exclusion:finale:$dance) {
		set j 0
		foreach dummy $folder(judges:finale) {
#puts "setting notes $note to $c/'notes:finale:$c:$dance'"
			set folder(notes:finale:$c:$dance) [lreplace $folder(notes:finale:$c:$dance) $j $j $note]
			incr j
		}
	}
}

#==============================================================================================

proc skating::finale:mark {c skipZeros mark total x y hNormal} {
	if {($skipZeros && $mark == 0) || $mark == -1} {
		return
	}
	incr y
	if {$total < 1} {
		$c create text $x [expr $y+$hNormal/2] -text $mark -font canvas:place -tags "ex"
	} else {
		set id [$c create text $x [expr $y+$hNormal/2] -text $mark -font canvas:place -tags "ex"]
		if {[expr int($total)] == $total} {
			set total [expr int($total)]
		}
		set x [expr [lindex [$c bbox $id] 2]+1]
		$c create text $x [expr $y+$hNormal/2] -text ($total) -font canvas:place -anchor w -tags "ex"
	}
}

