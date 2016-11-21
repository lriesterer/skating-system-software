##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Classement pour la finale d'une danse d'un dossier (notation)
#
#	Vue par juge
#
#=================================================================================================

#-------------------------------------------------------------------------------------------------

proc skating::finale:init {page f judge} {
variable $f
upvar 0 $f folder
variable gui
variable event

	#---- nom de juge
	label $page.n -font canvas:medium -text $event(name:$judge)

	#---- ScrolledWindow avec zone de saisie
	set sw [ScrolledWindow::create $page.sw \
				-scrollbar both -auto both -relief sunken -borderwidth 1]
	# création du canvas pour les grilles de notation
	set c [canvas [ScrolledWindow::getframe $sw].canvas -highlightthickness 0 -bg gray95 -height 1]
	set gui(w:finale:$judge) $c
	ScrolledWindow::setwidget $sw $c

	# bind pour retracer lors changement de configuration
	bind $c <Configure> "skating::finale:draw [list $f] $judge"
	# binding du canvas
	bind $c <Visibility> "focus $c"
		# navigation dans les marks
		bind $c <Left> "skating::finale:keyboard [list $f] $c   -1   0"
		bind $c <Right> "skating::finale:keyboard [list $f] $c  +1   0"
		bind $c <Up> "skating::finale:keyboard [list $f] $c      0  -1"
		bind $c <Down> "skating::finale:keyboard [list $f] $c    0  +1"
		bind $c <Home> "skating::finale:keyboard [list $f] $c  -10  -10"
		bind $c <End> "skating::finale:keyboard [list $f] $c   +10  +10"
  		foreach k {1 2 3 4 5 6 7 8 9} kk {KP_End KP_Down KP_Next KP_Left KP_Begin
										  KP_Right KP_Home KP_Up KP_Prior } {
  			bind $c $k "skating::finale:keyboard:input [list $f] $c $judge $k"
			if {$::tcl_platform(platform) != "windows"} {
	  			bind $c <$kk> "skating::finale:keyboard:input [list $f] $c $judge $k"
			}
  		}
		bind $c <1> "skating::finale:click [list $f] $c %x %y"

		foreach judge $folder(judges:finale) {
			bind $c [string tolower $judge] "NoteBook::raise $gui(w:notebook) __$judge"
		}

	#---- zone d'aide (rappel des touches)
	set help [text $page.help -font tips -width 40 -height 3 \
						-relief flat -bg [$page cget -background] -tabs {200}]
		$help tag configure blue -foreground darkblue
		$help tag configure red -foreground red
		bindtags $help "all"
		eval $help insert 1.0 $::msg(help:finale)

	#==== mise en page
	pack $page.n -side top -anchor w
	pack $sw -side top -fill both -expand true
	pack $help -side top -fill x -expand false
}

#----------------------------------------------------------------------------------------------

proc skating::finale:refresh {f judge} {
variable $f
upvar 0 $f folder

#TRACEF

	finale:draw $f $judge
}

proc skating::finale:draw {f judge} {
variable $f
upvar 0 $f folder
variable gui
variable event

#TRACEF

	set c $gui(w:finale:$judge)
	# efface tout
	$c delete all

	# récupère la taille de la frame
	set startX 10
	set startY 10
	set h1 26
	set h2 20
	set wD 30
	set wC 50

	set y $startY
	set color $gui(color:lightyellow)


	set left $startX
	$c create rectangle $left $y [incr left $wC] [expr $y+$h1] -fill $gui(color:lightyellow) -outline black
	foreach dance $folder(dances) {

		$c create rectangle $left $y [expr {$left+$wD}] [expr {$y+$h1}] -tags "tip:d$left" \
				-fill $gui(color:lightyellow) -outline black
		$c create text [expr {$left+$wD/2}] [expr {$y+$h1/2+1}] -tags "tip:d$left" \
				-anchor c -text [firstLetters $dance] -font bold
		DynamicHelp::register $c canvasballoon "tip:d$left" $dance
		incr left $wD
	}
	incr y $h1

	foreach couple $folder(couples:finale) {
		set left $startX
		# nom du couple
		$c create rectangle $left $y [expr $left+$wC] [expr $y+$h2] -tags "tip:$couple" \
					-fill $gui(color:yellow) -outline black
		$c create text [expr {$left+$wC/2}] [expr {$y+$h2/2+1}] -tags "tip:$couple" \
					-anchor c -text $couple -font bold
		DynamicHelp::register $c canvasballoon "tip:$couple" [couple:name $f $couple]
		incr left $wC

		# boite pour les danses
		foreach dance $folder(dances) {
			$c create rectangle $left $y [expr {$left+$wD}] [expr {$y+$h2}] \
						-outline black -tag [list c:$couple:$dance c:$dance] -fill gray95
			$c create rectangle $left $y [expr {$left+$wD}] [expr {$y+$h2}] \
						-outline black -tag [list b:$couple:$dance] -fill {}
			$c create text [expr {$left+$wD/2}] [expr {$y+$h2/2+1}] \
						-anchor c -font normal -tag [list t:$couple:$dance]

			incr left $wD
		}

		# couple suivant
		incr y $h2
	}

	# initialise le tableau avec les données
	finale:setFromData $f $c $judge

	# curseur de saisie
  	set gui(v:activeX) [lindex $folder(dances) 0]
  	set gui(v:activeY) [lindex $folder(couples:finale) 0] 
	$gui(w:finale:$judge) itemconfigure "b:$gui(v:activeY):$gui(v:activeX)" \
				-fill $gui(color:selection)
	$gui(w:finale:$judge) itemconfigure "t:$gui(v:activeY):$gui(v:activeX)" \
				-fill $gui(color:selectionFG)

	# zone pour le scrolling
	set bbox [$c bbox all]
	set x [expr [lindex $bbox 2]+10]
	set y [expr [lindex $bbox 3]+10]
	if {$x < [winfo width $c]} { set x [winfo width $c] }
	if {$y < [winfo height $c]} { set y [winfo height $c] }
	$c configure -scrollregion [list 0 0 $x $y]
}

#----------------------------------------------------------------------------------------------

proc skating::finale:setFromData {f c judge} {
variable $f
upvar 0 $f folder
variable gui

#TRACEF

	set index [lsearch $folder(judges:finale) $judge]

	foreach couple $folder(couples:finale) {
		foreach dance $folder(dances) {
			set text 0
			if {[info exists folder(exclusion:finale:$dance)]
							&& [lsearch $folder(exclusion:finale:$dance) $couple] != -1} {
				set text "E"
			} elseif {[info exists folder(notes:finale:$couple:$dance)]} {
				set text [lindex $folder(notes:finale:$couple:$dance) $index]
			} else {
				set text 0
				set folder(notes:finale:$couple:$dance) [string repeat "0 " [llength $folder(judges:finale)]]
			}

			if {$text == 0} {
				set text "?"
			}
			$c itemconfigure "t:$couple:$dance" -text $text
		}
	}

	finale:showError $f $c $judge $folder(dances)
}

#----------------------------------------------------------------------------------------------

proc skating::finale:showError {f c judge dances} {
variable $f
upvar 0 $f folder
variable gui

#TRACEF

	set index [lsearch $folder(judges:finale) $judge]
	# construit liste des conflits
	foreach couple $folder(couples:finale) {
		foreach dance $dances {
			lappend data($dance:[lindex $folder(notes:finale:$couple:$dance) $index]) $couple
		}
	}
	# affichage
	foreach dance $dances {
		$c itemconfigure "c:$dance" -fill gray95

		for {set i 1} {$i <= [llength $folder(couples:finale)]} {incr i} {
			if {[info exists data($dance:$i)] && [llength $data($dance:$i)] > 1} {
				foreach couple $data($dance:$i) {
					$c itemconfigure "c:$couple:$dance" -fill $gui(color:placebad)
				}
			}
		}
	}
}

#----------------------------------------------------------------------------------------------

proc skating::finale:keyboard {f c dx dy {loop 0}} {
variable gui
variable $f
upvar 0 $f folder

	# on efface l'ancien
	$c itemconfigure "b:$gui(v:activeY):$gui(v:activeX)" -fill {}
	$c itemconfigure "t:$gui(v:activeY):$gui(v:activeX)" -fill black

	# on calcule le nouveau
	set maxY [expr [llength $folder(couples:finale)]-1]
	set maxX [expr [llength $folder(dances)]-1]

	# dY
	if {$dy == -10} {
		set index 0
	} elseif {$dy == +10} {
		set index end
	} else {
		set index [lsearch $folder(couples:finale) $gui(v:activeY)]
		incr index $dy
		if {$index < 0} { set index 0 }
		if {$index > $maxY} {
			if {$loop && $gui(v:activeX) != [lindex $folder(dances) end]} {
				set index 0
				incr dx
			} else {
				set index $maxY
			}
		}
	}
	set gui(v:activeY) [lindex $folder(couples:finale) $index]

	# dX
	if {$dx == -10} {
		set index 0
	} elseif {$dx == +10} {
		set index end
	} else {
		set index [lsearch $folder(dances) $gui(v:activeX)]
		incr index $dx
		if {$index < 0} { set index 0 }
		if {$index > $maxX} { set index $maxX }
	}
	set gui(v:activeX) [lindex $folder(dances) $index]

	# affiche sélection
	$c itemconfigure "b:$gui(v:activeY):$gui(v:activeX)" \
			-fill $gui(color:selection)
	$c itemconfigure "t:$gui(v:activeY):$gui(v:activeX)" \
			-fill $gui(color:selectionFG)

	# ajuste le scrolling pour voir l'élément actif
	set h [lindex [$c cget -scrollregion] 3]
	set y1 [lindex [$c coords "b:$gui(v:activeY):$gui(v:activeX)"] 1]
	set y2 [lindex [$c coords "b:$gui(v:activeY):$gui(v:activeX)"] 3]
	set fraction1 [expr {($y1-10.0)/$h}]
	set fraction2 [expr {($y2)/$h}]
	foreach {min max} [$c yview] break
	if {$fraction1 < $min} {
		$c yview moveto $fraction2
		$c yview scroll -1 page
	} elseif {$fraction2 > $max} {
		$c yview moveto $fraction1
	}
}

proc skating::finale:keyboard:input {f c judge place} {
variable gui
variable $f
upvar 0 $f folder

	# position courante
	set dance $gui(v:activeX)
	set couple $gui(v:activeY)

	# check
	set max [llength $folder(couples:finale)]
	if {[info exists folder(exclusion:finale:$dance)]} {
		if {[lsearch $folder(exclusion:finale:$dance) $couple] != -1} {
			bell
			return
		}
		incr max -[llength $folder(exclusion:finale:$dance)]
	}
	if {$place > $max} {
		bell
		return
	}

	# entrée de la note
#TRACE "$couple / $judge / $dance / $place"
	set index [lsearch $folder(judges:finale) $judge]
	set name notes:finale:$couple:$dance
#TRACE "index = $index  // $folder($name)"
	set folder($name) [lreplace $folder($name) $index $index $place]
#TRACE "             // $folder($name)"

	# mise à jour affichage
	$c itemconfigure "t:$couple:$dance" -text $place
	finale:showError $f $c $judge [list $dance]
	ranking:check $f

	# nécessite un redraw pour la danse modifiée
	set gui(v:redraw:$dance) 1

	# passage au couple suivant
	finale:keyboard $f $c 0 1 1
}


proc skating::finale:click {f c x y} {
variable gui
variable $f
upvar 0 $f folder


	set id [lindex [$c find overlapping $x $y $x $y] 0]
	set tag [$c itemcget $id -tags]
	if {[set idx [lsearch $tag current]] != -1 || [string first "c:" $tag 2] != -1} {
		set tag [lindex $tag 0]
	}

	# on efface l'ancien
	$c itemconfigure "b:$gui(v:activeY):$gui(v:activeX)" -fill {}
	$c itemconfigure "t:$gui(v:activeY):$gui(v:activeX)" -fill black

	# on affiche le nouveau
	regexp -- {.:([^:]*):(.*)} $tag {} gui(v:activeY) gui(v:activeX)
	$c itemconfigure "b:$gui(v:activeY):$gui(v:activeX)" -fill $gui(color:selection)
	$c itemconfigure "t:$gui(v:activeY):$gui(v:activeX)" -fill $gui(color:selectionFG)

}