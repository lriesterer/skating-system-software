##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion du cas particulier des 10 danses
#
#=================================================================================================

proc skating::ten:init {f notebook dance} {
variable gui
variable $f
upvar 0 $f folder
global msg


	#-----------------------------------------------------------
	# création des items de gestion des couples, rounds et juges
	set bg #bfd3ff
	set abg #bfe1ff
	if {$::tcl_platform(platform) == "windows"} {
		set abg $bg
	}
	set couples [NoteBook::insert $gui(w:notebook) end "couples" -text $msg(couples) \
						-background $bg -selectedbackground $bg -activebackground $abg \
						-raisecmd "skating::fastentry:mode init:couples; \
								   set skating::gui(v:round) {}; \
								   set skating::gui(v:judge) -1"]
	  bind $couples <Visibility> "focus $couples"
	  manage:couples:init $f $couples

	# onglet pour le choix des rounds
	set gui(t:roundsNeedInit) 1
	set rounds [NoteBook::insert $gui(w:notebook) end "rounds" -text "Gestion des rounds" \
						-background $bg -selectedbackground $bg -activebackground $abg \
						-raisecmd "skating::manage:rounds:refresh [list $f]; \
								   set skating::gui(v:round) \"\"; \
								   set skating::gui(v:judge) -1"]

	# onglet pour le choix des juges
	set judges [NoteBook::insert $gui(w:notebook) end "judges" -text $msg(judges) \
						-background $bg -selectedbackground $bg -activebackground $abg \
						-raisecmd "skating::manage:judges:init [list $f]; \
								   set skating::gui(v:round) {}; \
								   set skating::gui(v:judge) -1"]

	#------------------
	# pour chaque round
	foreach round $folder(levels) {
		# on prend en compte la danse dans tous les rounds
		if {![info exists folder(dances:$round)]} {
			set folder(dances:$round) $folder(dances)
		} elseif {[lsearch $folder(dances:$round) $dance] == -1} {
			lappend folder(dances:$round) $dance
		}
		# on crée la page
		set page [NoteBook::insert $notebook end [string map {. _} $round] \
						-text $folder(round:$round:name) \
						-raisecmd  "skating::ten:init:round [list $f] [list $dance] $round; \
									skating::fastentry:deselectAll; \
									skating::fastentry:mode $round; \
									set skating::gui(v:round) $round; \
									set skating::gui(v:judge) -1"]
#		NoteBook::itemconfigure $notebook [string map {. _} $round] \
#				-createcmd "skating::ten:init:round [list $f] [list $dance] $round"
	}

	# pour le résultat
	NoteBook::insert $notebook end "result" -text $msg(result) \
				-background #f3b4ad -state disabled
	NoteBook::itemconfigure $notebook "result" \
				-createcmd "skating::ten:init:result [list $f] [list $dance]" \
				-raisecmd  "skating::fastentry:mode {}; \
							set skating::gui(v:round) {}; \
							set skating::gui(v:judge) -1"

	# mise à jour affichage
	ten:rounds:check $f $dance

	# trouve la page à afficher = celle où il y a des choses à saisir
	set last [lindex $folder(levels) 0]
	set done 0
	foreach round $folder(levels) {
		if {![llength [array names folder couples:$round]] && [llength $folder(judges:$last)]} {
			NoteBook::raise $notebook [string map {. _} $last]
			set done 1
			break
		}
		set last $round
	}
#puts "--- done = $done / last = $last"
	if {!$done && [info exists folder(couples:finale)] && [check:dance $f $dance]} {
		NoteBook::raise $notebook "result"
	} elseif {[llength $folder(couples:all)] == 0} {
		NoteBook::raise $notebook "couples"
	} elseif {[llength $folder(judges:[lindex $folder(levels) 0])] == 0} {
		NoteBook::raise $notebook "judges"
	} elseif {$last != ""} {
		NoteBook::raise $notebook [string map {. _} $last]
	} else {
		NoteBook::raise $notebook "couples"
	}
}

#----------------------------------------------------------------------------------------------

proc skating::ten:init:round {f dance round} {
variable $f
upvar 0 $f folder
global msg
variable gui

#TRACEF

	set w [NoteBook::getframe $gui(w:notebook) [string map {. _} $round]]
	# efface anciennes fenêtres
	foreach child [winfo children $w] {
		destroy $child
	}
	# widgets
	set sw [ScrolledWindow::create $w.sw \
				-scrollbar both -auto both -relief sunken -borderwidth 1]
	if {$round == "finale"} {
		#---- FINALE
		set canvas [gui:notes [ScrolledWindow::getframe $sw] $f $dance]
		bind $canvas <1> "focus %W"
		#---- pour la finale, choix de couples à exclure
		set tf [TitleFrame::create $w.exclude -text $msg(couplesToExclude)]
		set sub [TitleFrame::getframe $tf]
		set gui(w:exclusion:$dance) $sub
		foreach c $folder(couples:finale) {
			button $sub.$c -width 5 -text "$c" -bd 1 -padx 0 -pady 1 \
					-command "skating::finale:exclusion:toggle [list $f] [list $dance] $c"
			pack $sub.$c -side left -padx 5
		}
		# mise-à-jour
		finale:exclusion:display $f $dance
		# mise en page
		pack $sw -side top -pady 5 -expand true -fill both
		pack $tf -side top -fill x
	} else {
		#---- ROUND
		# la zone de sélection
		if {[llength $folder(couples:$round)]*[llength $folder(judges:$round)]/17 > 15} {
			ScrolledWindow::configure $sw -auto horizontal
		}
		set canvas [gui:round [ScrolledWindow::getframe $sw] $f $dance $round]
		# la zone de résultat
		bind $canvas <Configure> "+skating::selection:drawResult $canvas [list $f] $round 0 full"
		bind $canvas <1> "focus %W"
		set gui(w:ranking:$round) $canvas
		# mise en page
		pack $sw -side top -pady 5 -expand true -fill both
	}
	ScrolledWindow::setwidget $sw $canvas
	# partie basse pour la sélection
	result:bottomPanel:ten $f $round "full" $w $dance
}

#----------------------------------------------------------------------------------------------

proc skating::ten:init:result {f dance} {
variable $f
upvar 0 $f folder
global msg
variable gui
variable event

#puts "skating::ten:init:result {'$f' '$dance'}"
	set w [NoteBook::getframe $gui(w:notebook) "result"]
	# efface anciennes fenêtres
	foreach child [winfo children $w] {
		destroy $child
	}
	# widgets
	results:init $f $w $dance
}

#----------------------------------------------------------------------------------------------

proc skating::ten:rounds:check {f dance {rounds {}}} {
variable $f
upvar 0 $f folder
variable gui
global msg

#TRACEF "[NoteBook::pages $gui(w:notebook)]"

	# en mode event, pas de rafraichissement à faire
	if {$gui(v:inEvent)} {
		return
	}

	if {[llength $rounds] == 0} {
		set tabs [lrange [NoteBook::pages $gui(w:notebook)] 3 end]
		set rounds [string map {_ .} $tabs]
	} else {
		set tabs [string map {. _} $rounds]
	}
#TRACE "rounds=$rounds"
	set ok 1
	foreach round $rounds tab $tabs {
		if {$round == "result"} {
			#---- RESULT ----
			if {[info exists folder(couples:finale)] && [check:dance $f $dance]} {
				set state normal
				set bg #adf3b1
				set abg #b6ffba
			} else {
				set state disabled
				set bg #f3b4ad
				set abg #ffffff
			}

			global tcl_platform
			if {$tcl_platform(platform) == "windows"} {
				set abg $bg
			}

			NoteBook::itemconfigure $gui(w:notebook) "result" -state $state \
					-background $bg -selectedbackground $bg -activebackground $abg
			# faut-il activer le résultat global ?
			manage:rounds:adjustTreeColor $f
		} else {
			#---- ROUND & FINALE ----
			set state normal
			# vérifie si on peut accéder au round (les rounds supérieurs doivent être validés)
			# pour la danse donnée
			if {![info exists folder(judges:$round)]} {
#TRACE "create empty list for $round"
				set folder(judges:$round) {}
			}
#TRACE "judges=$folder(judges:$round)"
			if {[llength $folder(judges:$round)] == 0} {
				set state disabled
				set ok 0
			} elseif {![info exists folder(couples:$round)]} {
				if {$round == [lindex $folder(levels) 0]} {
					set folder(couples:$round) $folder(couples:all)
				} else {
#TRACE "disabling $round == [lindex $folder(levels) 0] / $folder(levels)"
					set state disabled
					set ok 0
				}
			}
			if {!$ok} {
				set state disabled
			}
#puts "---- $round = $state"
#parray folder couples:*
			# repositionne la danse
			set folder(dances:$round) $folder(dances)
			# configure l'onglet
			NoteBook::itemconfigure $gui(w:notebook) $tab -state $state
		}
	}
}

#==============================================================================================
#
#		Gestion des résultats sur 10-danses
#
#==============================================================================================

proc skating::ten:overall:results {f w} {
variable $f
upvar 0 $f folder
global msg
variable gui


#puts "skating::ten:overall:results {$f $w}"
	#---- partie inférieure = sélection des danses
	set tf [TitleFrame::create $w.exclude -text $msg(dancesSelection)]
	set sub [TitleFrame::getframe $tf]
	# construit la liste
	if {![info exists folder(v:overall:dances)]} {
		set folder(v:overall:dances) $folder(dances)
	}
	# affiche les boutons
	set i 0
	set j 0
	foreach dance $folder(dances) {
		checkbutton $sub.$i$j -text $dance -bd 1 \
				-command "skating::ten:overall:toggleDance $f [list $dance]" \
				-variable skating::${f}(v:overall:$dance)
		grid $sub.$i$j -column $i -row $j -sticky nws -padx 5
		# postionne la valeur
		if {[lsearch $folder(v:overall:dances) $dance] != -1} {
			set skating::${f}(v:overall:$dance) 1
		}
		# suivant
		incr i
		if {($i % 5) == 0} {
			set i 0
			incr j
		}
	}
	pack $sub -anchor w -fill none
	pack $tf -side bottom -fill x

	#---- partie supérieure = affichage des résultats
	# zone d'affichage des résultats
	set sw [ScrolledWindow::create $w.sw \
				-scrollbar both -auto both -relief sunken -borderwidth 1]
	set c [canvas [ScrolledWindow::getframe $sw].c -highlightthickness 0 -bg gray95 -height 1]
	set gui(w:overall) $c
	ScrolledWindow::setwidget $sw $c 1
	set tophead [canvas [ScrolledWindow::getframe $sw].t -highlightthickness 0 -bg gray95 -height 1]
	set lefthead [canvas [ScrolledWindow::getframe $sw].l -highlightthickness 0 -bg gray95 -width 1]
	set toplefthead [canvas [ScrolledWindow::getframe $sw].tl -highlightthickness 0 -bg gray95 -width 1 -height 1]
	ScrolledWindow::header $sw $tophead top
	ScrolledWindow::header $sw $toplefthead topleft
	ScrolledWindow::header $sw $lefthead left

	# choix du mode (liste globale ou détails par couples)
	set ff [frame $w.b -relief groove -bd 2]
		# ancien mode sauvegardé
		if {[info exists gui(v:result)]} {
			set what $gui(v:result)
		} else {
			set what "place"
		}
		# radio boutons pour le mode
		radiobutton $ff.2 -text $msg(result:extended:place) -bd 1 -value place \
				-variable ::skating::gui(v:result) -command "skating::ten:overall:draw [list $f] $c 0 0"
		radiobutton $ff.3 -text $msg(result:extended:couple) -bd 1 -value couple \
				-variable ::skating::gui(v:result) -command "skating::ten:overall:draw [list $f] $c 0 0"
		pack $ff.2 $ff.3 -side left -padx 5 -pady 5
		# init le mode
		set ::skating::gui(v:result) $what
	# mise en page
	pack $sw -side top -pady 5 -expand true -fill both
	pack $ff -side top -pady 5 -fill x
	pack [frame $w.sep0 -height 5] -side top -pady 5 -fill x
	# binding pour scrolling des canvas
	bind $c <Configure> {
		set limits [%W bbox all]
		if {[llength $limits]} {
			set x [expr {[lindex $limits 2]+10}]
			set y [expr {[lindex $limits 3]+10}]
			if {$x < %w} { set x %w }
			if {$y < %h} { set y %h }
			%W configure -scrollregion [list 0 0 $x $y]
			[winfo parent %W].t configure -scrollregion [list 0 0 $x 0]
			[winfo parent %W].l configure -scrollregion [list 0 0 0 $y]
		}
	}
	bind $c <Visibility> "focus $c"

	# mise à jour affichage
	skating::ten:overall:draw $f $c
}

#----------------------------------------------------------------------------------------------

proc skating::ten:overall:draw {f c {resize 1} {recompute 1}} {
variable $f
upvar 0 $f folder
variable gui
variable event
global msg


#puts "skating::ten:overall:draw {$f $c $resize $recompute}"

	# init
	set ct [winfo parent $c].t
	set ctl [winfo parent $c].tl
	set cl [winfo parent $c].l
	# efface tout
	$ct delete all
	$ctl delete all
	$cl delete all
	$c delete all

	#----------------------
	# calcule les résultats
#puts ">>>> $recompute || ![info exists folder(v:results)]"
	if {$recompute || ![info exists folder(v:results)]} {
		# construit la liste si elle n'existe pas
		if {![info exists folder(v:overall:dances)]} {
			set folder(v:overall:dances) $folder(dances)
		}
		set size 1
		foreach dance $folder(v:overall:dances) {
			variable $f.$dance
			upvar 0 $f.$dance dance_folder
			if {[llength $dance_folder(couples:all)] >= 20} {
				set size 100
				break
			}
		}
		progressBarInit $msg(result:computing) $msg(result:computing:msg) "" $size
		set results [class:folder $f "progressBarUpdate"]
		set folder(v:results) $results
	} else {
		set results $folder(v:results)
	}
#puts "results = $results"
	if {$gui(v:result) == "couple"} {
		set results [lsort -integer -index 0 $results]
	}

	#-----------------
	# init des tailles
	set nb [llength $results]
	set xmin 10
	set y 10
	set spaceX 10
	set spaceY 10
	set hBold 20
	set hNormal 20
	set wC 30
	set wN 400
	set wD 35
	set wT 40
	set wP 40

	#--------------------
	# headers
	# top left (couple + nom)
	set x $xmin
	if {$resize} {
		$ctl configure -height [expr $y+$hBold+1]
	}
	$ctl create rectangle $x $y [expr $x+$wC] [expr $y+$hBold] \
			-fill $gui(color:yellow) -outline black
	incr x $wC
	$ctl create rectangle $x $y [expr $x+$wN] [expr $y+$hBold] \
			-fill $gui(color:yellow) -outline black
	if {$event(useCountry)} {
		set text $msg(country)
	} else {
		set text $msg(schoolClub)
	}
	$ctl create text [expr $x+3] [expr $y+$hBold/2+1] -anchor w \
			-text "$msg(name) ($text)" -font canvas:label
	# top (danses)
	set x -1
	if {$resize} {
		$ct configure -height [expr $y+$hBold+1]
	}
	foreach dance $folder(v:overall:dances) {
		$ct create rectangle $x $y [expr $x+$wD] [expr $y+$hBold] \
				-fill $gui(color:yellow) -outline black -tags "d$x"
		$ct create text [expr $x+$wD/2] [expr $y+$hBold/2+1] \
				-text [firstLetters $dance] -font canvas:label -tags "d$x"
		# hyper-lien vers les résultats de cette dance
		set i [lsearch $folder(dances) $dance]
		$ct bind "d$x" <1> "catch {
								set \"::skating::gui(v:result:$dance)\" extended_\$::skating::gui(v:result); \
								skating::results:draw [list $f.$dance] \
										\[ScrolledWindow::getframe \$::skating::gui(w:results:$dance)\].c [list $dance]; \
								NoteBook::raise $gui(w:notebook) $i}"
		incr x $wD
	}
	$ct create rectangle $x $y [expr $x+$wT] [expr $y+$hNormal] \
			-fill $gui(color:yellow) -outline black
	$ct create text [expr $x+$wT/2] [expr $y+$hNormal/2+1] \
			-text $msg(total) -font canvas:label
	incr x $wT
	$ct create rectangle $x $y [expr $x+$wP] [expr $y+$hNormal] \
			-fill $gui(color:yellow) -outline black
	$ct create text [expr $x+$wP/2] [expr $y+$hNormal/2+1] \
			-text $msg(place) -font canvas:label

	#--------
	# données
	if {$resize} {
		$cl configure -width [expr $spaceX+$wC+$wN/4+1]
	}
	set y -1
	foreach item $results {
		set couple [lindex $item 0]
		set place [lindex $item 1]
		set total [lindex $item 2]
		set places [lindex $item 3]
		#---- left
		set x $xmin
		# couple
		$cl create rectangle $x $y [expr $x+$wC] [expr $y+$hNormal] \
				-fill $gui(color:lightyellow) -outline black
		$cl create text [expr $x+$wC/2] [expr $y+$hNormal/2+1] -text $couple -font canvas:label
		incr x $wC
		# nom/école
		$cl create rectangle $x $y [expr $x+$wN] [expr $y+$hNormal] -outline black
		set text [couple:name $f $couple]
		if {[couple:school $f $couple] != ""} {
			append text " ([couple:school $f $couple])"
		}
		$cl create text [expr $x+3] [expr $y+$hNormal/2+1] -anchor w \
				-text $text -font canvas:place
		#---- main
		set x -1
		# places
		foreach p $places {
			$c create rectangle $x $y [expr $x+$wD] [expr $y+$hNormal] \
					-outline black
			$c create text [expr $x+$wD/2] [expr $y+$hNormal/2+1] \
					-text $p -font canvas:place
			incr x $wD
		}
		# total
		$c create rectangle $x $y [expr $x+$wT] [expr $y+$hNormal] \
				-fill $gui(color:lightyellow) -outline black
		$c create text [expr $x+$wT/2] [expr $y+$hNormal/2+1] \
				-text [expr {$total*1.0}] -font canvas:place
		incr x $wT
		# place finale
		$c create rectangle $x $y [expr $x+$wP] [expr $y+$hNormal] \
				-fill $gui(color:lightyellow) -outline black
		$c create text [expr $x+$wP/2] [expr $y+$hNormal/2+1] \
				-text $place -font canvas:label

		# couple suivant
		incr y $hNormal
	}

	# tables pour explications réglès 10 & 11 éventuelles
	if {$gui(pref:explain:ten)} {
		ten:overall:rules
	}

#  set folder(v:overall:dances) [lrange $folder(v:overall:dances) 1 end]
#  class:folder $f
#  set sw [ScrolledWindow::create $w.sw \
#                          -scrollbar both -auto both -relief sunken -borderwidth 1]
#  set canvas [gui:ranking [ScrolledWindow::getframe $sw] $f finale]
#  ranking:display $f "finale"
#  ScrolledWindow::setwidget $sw $canvas
#  pack $sw -side top -fill both -expand true

	#=================
	# line pour resize
	if {$resize} {
		set limitX [expr $spaceX+$wC+$wN/4]
	} else {
		set limitX [expr {[$cl cget -width]-1}]
	}
	set id_topleft [$ctl create line $limitX $spaceY $limitX [expr $spaceY+$hBold+1]]
	set id_left [$cl create line $limitX 0 $limitX $y]
	ten:overall:resize:init [expr $spaceX+$wC-1] [expr $spaceX+$wC+$wN] \
			$ctl $id_topleft $spaceY [expr $spaceY+$hBold+1] \
			$cl $id_left 0 $y

	# bindings
	bind $c <Up> "::sync_$cl scroll -1 units"
	bind $c <Down> "::sync_$cl scroll +1 units"
	bind $c <Prior> "::sync_$cl scroll -1 pages"
	bind $c <Next> "::sync_$cl scroll +1 pages"
	bind $c <Left> "::sync_$ct scroll -1 units"
	bind $c <Right> "::sync_$ct scroll +1 units"
	bind $c <Home> "::sync_$ct scroll -1 pages"
	bind $c <End> "::sync_$ct scroll +1 pages"

	# efface la boite de progression
	progressBarEnd
	update
}

proc skating::ten:overall:rules {} {
upvar folder folder
upvar c c y y spaceY spaceY hNormal hNormal hBold hBold

	set rules(10) {}
	set rules(11) {}
	set rules(12) {}
	set rules(13) {}
	set rules(14) {}
	set rules(15) {}
	set rules(16) {}
	set rules(17) {}
	set i 0
	set couples $folder(couples:finale)
	foreach couple $couples {
		# applications règles 10&11
		set rule [lindex $folder(rules) $i]
		if {$rule >= 10} {
			lappend rules(10) $couple
		}
		if {$rule >= 11} {
			lappend rules(11) $couple
		}
		if {$rule >= 12} {
			lappend rules(12) $couple
		}
		if {$rule >= 13} {
			lappend rules(13) $couple
		}
		if {$rule >= 14} {
			lappend rules(14) $couple
		}
		if {$rule >= 15} {
			lappend rules(15) $couple
		}
		if {$rule >= 16} {
			lappend rules(16) $couple
		}
		if {$rule >= 17} {
			lappend rules(17) $couple
		}
		# couple suivant
		incr i
	}

	# affiche les détails
	set left -1
	#==== explications (Règles 10 & 11 & suivantes)
	set already11 0
	if {[llength $rules(10)]} {
		ten:overall:explain_rules 10 11 1
	}
	# second niveau de 10 & 11
	if {[llength $rules(12)]} {
		ten:overall:explain_rules 12 13 0
	}
	# troisième niveau de 10 & 11
	if {[llength $rules(14)]} {
		ten:overall:explain_rules 14 15 0
	}
	# quatrième niveau de 10 & 11
	if {[llength $rules(16)]} {
		ten:overall:explain_rules 16 17 0
	}
}

proc skating::ten:overall:explain_rules {rule10 rule11 needheader} {
variable event
variable gui
global msg

upvar couples couples
upvar left left y y c c folder folder rules rules already11 already11
upvar hNormal hNormal hBold hBold spaceY spaceY

	# calcul hauteur
	set need11 [llength $rules($rule11)]

	#---- taille
	set wC 30
	set wP 45
	if {[llength $couples] > 25} {
		incr wP 15
	}
	set twP [expr $wP*[llength $couples]+$wP/3]
	if {$need11 || $already11} {
		set width [expr $wC+2*$twP]
		set already11 1
	} else {
		set width [expr $wC+$twP]
	}

	#---- header
	if {$needheader} {
		set y [expr $y+$spaceY]
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

#----------------------------------------------------------------------------------------------

proc skating::ten:overall:resize:init {xmin xmax c1 id1 y11 y12 c2 id2 y21 y22} {
	$c1 bind $id1 <Enter> "$c1 configure -cursor sb_h_double_arrow"
	$c1 bind $id1 <Leave> "$c1 configure -cursor {}"

	$c2 bind $id2 <Enter> "$c2 configure -cursor sb_h_double_arrow"
	$c2 bind $id2 <Leave> "$c2 configure -cursor {}"


	foreach c [list $c1 $c2] id [list $id1 $id2] {
		$c bind $id <B1-Motion> "
			if {%x > $xmin && %x < $xmax} {
				$c1 configure -width \[expr {%x+1}\]
				$c2 configure -width \[expr {%x+1}\]
				$c1 coords $id1 [list %x $y11 %x $y12]
				$c2 coords $id2 [list %x $y21 %x $y22]
			}
		"
	}
}

#----------------------------------------------------------------------------------------------

proc skating::ten:overall:toggleDance {f dance} {
variable $f
upvar 0 $f folder
variable gui


	# traite le basculement
	if {$folder(v:overall:$dance)} {
		#---- ON
		if {[lsearch $folder(v:overall:dances) $dance] == -1} {
			lappend folder(v:overall:dances) $dance
		}
	} else {
		#---- OFF
		if {[llength $folder(v:overall:dances)] == 1} {
			set folder(v:overall:$dance) 1
		} else {
			set idx [lsearch $folder(v:overall:dances) $dance]
			set folder(v:overall:dances) [lreplace $folder(v:overall:dances) $idx $idx]
		}
	}
#puts "skating::ten:overall:toggleDance {$f $dance} / after = $folder(v:overall:dances)"

	# mise à jour affichage
	ten:overall:draw $f $gui(w:overall) 0
	event generate $gui(w:overall) <Configure> -width [winfo width $gui(w:overall)] \
			-height [winfo height $gui(w:overall)]
}
