##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion de la méthode de génération des rounds
#
#=================================================================================================

proc skating::manage:rounds:init {folderName w} {
variable $folderName
upvar 0 $folderName folder
global msg
variable gui
variable event

	# résumé
	label $w.summary -font competition
	pack $w.summary -side top -padx 5 -pady 10 -anchor w

	# radio bouton pour gestion automatique
	radiobutton $w.auto -text $msg(automatic) \
			-variable skating::${folderName}(round:generation) -value auto -bd 1 \
			-command "skating::manage:rounds:mode [list $folderName] 1"

	# radio bouton pour gestion manuelle
	radiobutton $w.user -text $msg(manual) \
			-variable skating::${folderName}(round:generation) -value user -bd 1 \
			-command "skating::manage:rounds:mode [list $folderName] 1"
	  # séparateur pour remplissage à gauche
	  frame $w.sep -width 25
	  # title frame pour les réglages
	  set sub [frame $w.f -bd 2 -relief groove]
		#---- pour chaque round
		foreach round {128 64 32 16 eight quarter semi finale} {
			set f [frame $sub.$round]
			set gui(w:round:$round) $f
			set ok 1
			if {$round == "finale"} {
				#---- FINALE ----
				checkbutton $f.use -bd 1 -text $msg(round:finale) -width 10 -font bold -anchor w \
					-variable skating::${folderName}(round:finale:use) -state disabled
				# nombre de couples en finale
				set ff [frame $f.main]
				label $ff.tot -text "0 couples." -font event:data
				pack $ff.tot -side left -anchor w

				pack $f.use -side left -anchor nw
				pack $f.main -side top -fill x -expand true

			} else {
				#---- ROUND ----
				checkbutton $f.use -bd 1 -text $msg(Round) -width 10 -font bold -anchor w \
						-variable skating::${folderName}(round:$round:use) \
						-command "skating::manage:rounds:toggle [list $folderName] $round"
				# sélection
				set ff [frame $f.main]
				  # nb couples à sélectionner
				  SpinBox::create $ff.nb -label "$msg(select2) " -editable false -range {1 2 1} \
						-bd 1 -justify right -width 3 -entrybg gray95 -labelfont normal \
						-textvariable skating::${folderName}(round:$round:nb) \
						-modifycmd "skating::manage:rounds:modify [list $folderName] $round;
									skating::manage:rounds:check50% [list $folderName]"
				  label $ff.tot -text " couples." -font event:data
				  # repêchage
				  checkbutton $ff.split -bd 1 -text $msg(secondChance) -font normal \
						-variable skating::${folderName}(round:$round:split) \
						-command "skating::manage:rounds:split [list $folderName] $round 1 1"
				  # mise en page
				  pack $ff.nb $ff.tot -side left -anchor w
				  pack $ff.split -side right

				set ff [frame $f.chance]
				  # nb couples à sélectionner
				  SpinBox::create $ff.nb -label "$msg(secondChance), $msg(select2) " -editable false -range {1 2 1} \
						-bd 1 -justify right -width 3 -entrybg gray95 -labelfont normal \
						-textvariable skating::${folderName}(round:$round.2:nb) \
						-modifycmd "skating::manage:rounds:modify [list $folderName] $round
									skating::manage:rounds:check50% [list $folderName]"
				  label $ff.tot -text " [string tolower $msg(couples)]." -font event:data
				  # mise en page
				  pack $ff.nb $ff.tot -side left -anchor w

				# mise en page
				pack $f.use -side left -anchor nw
				frame $f.sep -height 5
				pack $f.main -side top -fill x -expand true
			}
			if {$ok} {
				pack $sub.$round -side top -fill x -pady 5 -padx 5
			}
		}
		#---- bouton de choix dy système de nommage
		frame $sub.names -bd 2 -relief groove
			checkbutton $sub.names.c -bd 1 -text $msg(naming) -font normal -state disabled \
					-variable skating::${folderName}(round:explicitNames) \
					-command "skating::manage:rounds:explicitNames [list $folderName]"
			checkbutton $sub.names.r -bd 1 -text $msg(50%rule) -font normal \
					-variable skating::${folderName}(round:use50%rule) \
					-command "skating::manage:rounds:check50% [list $folderName]"
			pack $sub.names.c -padx 5 -pady 2 -side left
			pack $sub.names.r -padx 5 -pady 2 -side right
			set gui(w:round:names) $sub.names.c
		pack $sub.names -side bottom -fill x -pady 5 -padx 5
		#---- rappel des quotas officiels
		text $sub.h -font tips -height 10 -relief flat -bg [$w cget -background] -tabs {20 90 115}
		#$sub.h tag configure blue -foreground darkblue
		#$sub.h tag configure red -foreground red
		bindtags $sub.h "$sub.h all"
		$sub.h insert 1.0 $msg(help:rounds)
		pack $sub.h -side bottom -fill x -pady 5 -padx 5

	# mise en page
	pack $w.auto -side top -pady 5 -anchor w
	pack $w.user -side top -pady 5 -anchor w

	pack $w.sep -side left -pady 5
	pack $w.f -side left -expand true -fill both -pady 5

	# initialisation
	set skating::${folderName}(round:finale:use) 1
}

proc skating::manage:rounds:refresh {f} {
variable $f
upvar 0 $f folder
global msg
variable gui


	set w [NoteBook::getframe $gui(w:notebook) "rounds"]

	# si panel n'existepas, le créer
	if {$gui(t:roundsNeedInit)} {
		waitDialog:open $msg(dlg:pleaseWait)
		# init de l'interface (long)
		skating::manage:rounds:init $f $w
		set gui(t:roundsNeedInit) 0
	}

	# si mode qualification, pas de gestion des round
TRACEFS
	if {$folder(mode) == "qualif"} {
		$w.summary configure -text "Qualification mode."
		$w.auto configure -state disabled
		$w.user configure -state disabled
		waitDialog:close
		return
	}
	$w.auto configure -state normal
	$w.user configure -state normal

	# gestion des grisés pour les spin-boxes
	skating::manage:rounds:mode $f 0

	# nb de couple au total
	set total [llength $folder(couples:all)]
	$w.summary configure -text "$total [string tolower $msg(couples)] $msg(competing)."

	# vérification de la cohérence
	foreach round {128 64 32 16 eight quarter semi} {
		while {$folder(round:$round:nb)+$folder(round:$round.2:nb) > $total} {
			if {$folder(round:$round.2:nb) > 0} {
				incr folder(round:$round.2:nb) -1
			} else {
				incr folder(round:$round:nb) -1
			}
		}
	}	

	foreach round {128 64 32 16 eight quarter semi} {
		# mise-à-jour interface
		manage:rounds:modify $f $round
	}	

	waitDialog:close
}


#-------------------------------------------------------------------------------------------------

proc skating::manage:rounds:mode {f ask} {
variable $f
upvar 0 $f folder
variable gui
global msg colorNormal colorDisabled


#TRACEF "$folder(round:generation)"

	if {$folder(round:generation) == "auto"} {
		# si action de changement de l'utilisateur
		if {$ask} {
			# confirmation car effacement des données
			set doit [tk_messageBox -icon "question" -type yesno -default yes \
								-title $msg(dlg:question) -message $msg(dlg:roundModeReinit)]
			if {$doit == "no"} {
				set folder(round:generation) "user"
				return
			}
			reinitNotes $f
		}
		# génération des données
		manage:rounds:generate $f force
		# mise à jour interface		
		foreach round {128 64 32 16 eight quarter semi finale} {
			set w $gui(w:round:$round)
			if {$round == "finale"} {
				$w.use configure -disabledforeground $colorDisabled
				$w.main.tot configure -foreground $colorDisabled
			} else {
				$w.use configure -state disabled
				SpinBox::configure $w.main.nb -state disabled
				$w.main.tot configure -foreground $colorDisabled
				set skating::${f}(round:$round:split) 0
				manage:rounds:split $f $round
				$w.main.split configure -state disabled
				# mise-à-jour interface
				manage:rounds:modify $f $round
			}
		}
		$gui(w:round:names) configure -state disabled
	} else {
		# génération des données
		manage:rounds:generate $f force
		# mise à jour interface		
		foreach round {128 64 32 16 eight quarter semi finale} {
			set w $gui(w:round:$round)
			if {$round == "finale"} {
				$w.use configure -disabledforeground $colorNormal
				$w.main.tot configure -foreground $colorNormal
			} else {
				$w.use configure -state normal
				if {$folder(round:$round:use)} {
					SpinBox::configure $w.main.nb -state normal
					$w.main.tot configure -foreground $colorNormal
					$w.main.split configure -state normal
				} else {
					SpinBox::configure $w.main.nb -state disabled
					$w.main.tot configure -foreground $colorDisabled
					$w.main.split configure -state disabled
				}
				manage:rounds:split $f $round
			}
		}
		$gui(w:round:names) configure -state normal
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:rounds:toggle {f round} {
variable $f
upvar 0 $f folder
variable gui
global msg colorNormal colorDisabled

#TRACEF

	set w $gui(w:round:$round)
	set next [rounds:next $f $round 1]

	# action = retire la pre-finale
	result:prefinale:remove $f

	# si le suivant n'est pas activé ou précédent activé, interdit
	if {$folder(round:$next:use) == 0 ||
			($round != "128" && $folder(round:[rounds:previous $f $round]:use) == 1) ||
			($round == "semi" && [llength $folder(couples:all)]>9)} {
		set $folder(round:$round:use) 0
		$w.use toggle
		return
	}

	# OK pour changer l'état
	if {$folder(round:$round:use)} {
		#---- active
		# variables
		set min [expr $folder(round:$next:nb)+$folder(round:$next.2:nb)]
		set max [manage:rounds:total $f $round]
		set folder(round:$round:nb) [expr {$min + ($max-$min)/2}]
		if {$folder(round:$round:nb) < ($max+1)/2} {
			set folder(round:$round:nb) [expr {($max+1)/2}]
		}
		# interface
		SpinBox::configure $w.main.nb -state normal
		$w.main.tot configure -foreground $colorNormal
		$w.main.split configure -state normal
		manage:rounds:split $f $round 1

		# mise à jour variables
		#   levels
		set folder(levels) [linsert $folder(levels) 0 $round]
		#   couples & juges
		foreach n [array names folder couples:*] {
			if {$n != "couples:all" && $n != "couples:names"} {
				unset folder($n)
			}
		}
		set folder(couples:$round) $folder(couples:all)
		# propagation juges N+1 --> N
#TRACE "adjust judges"
		manage:rounds:propagateJudges $f $round

		# mise à jour Tree / NoteBook
		if {[string first "." $f] == -1} {
			Tree::insert $gui(w:tree) 0 $f $f.$round -data "round $round" \
					-text [rounds:getName $f $round] -image imgRound
		} else {
			NoteBook::insert $gui(w:notebook) 3 [string map {. _} $round] \
					-text $folder(round:$round:name) \
					-raisecmd  "skating::ten:init:round [list $f] [list $gui(v:dance)] $round; \
								skating::fastentry:deselectAll; \
								skating::fastentry:mode $round; \
								set skating::gui(v:round) $round; \
								set skating::gui(v:judge) -1"
			ten:rounds:check $f $gui(v:dance)
		}

	} else {
		#---- désactive
		# variables
		set folder(round:$round:nb) 0
		set folder(round:$round:nbSelected) 0
		set folder(round:$round.2:nb) 0
		set folder(round:$round.2:nbSelected) 0
		set split $folder(round:$round:split)
		set folder(round:$round:split) 0
		# interface
		SpinBox::configure $w.main.nb -state disabled
		$w.main.tot configure -foreground $colorDisabled
		$w.main.split configure -state disabled
		manage:rounds:split $f $round 1
		# mise-à-jour Tree / NoteBook
		if {[string first "." $f] == -1} {
			if {$split} {
				Tree::delete $gui(w:tree) $f.$round
				Tree::delete $gui(w:tree) $f.$round.2
			} else {
				Tree::delete $gui(w:tree) $f.$round
			}
		} else {
			if {$split} {
				NoteBook::delete $gui(w:notebook) [string map {. _} $round]
				catch { NoteBook::delete $gui(w:notebook) [string map {. _} $round.2] }
			} else {
				NoteBook::delete $gui(w:notebook) [string map {. _} $round]
			}
			ten:rounds:check $f $gui(v:dance)
		}
		# mise à jour variables
		#   levels
		set folder(levels) [lreplace $folder(levels) 0 0]
		#   exclusion
		foreach name [array names folder exclusion:$round:*] {
			unset folder($name)
		}
		#   juges & couples
		catch {unset folder(judges:$round)}
		catch {unset folder(couples:$round)}
		set folder(couples:[lindex $folder(levels) 0]) $folder(couples:all)
		#   notes
		foreach pattern {couples:* notes:* result:*} {
			foreach name [array names folder $pattern] {
				if {$name != "couples:all" && $name != "couples:names"} {
					unset folder($name)
				}
			}
		}
	}
	# assurer la règle du "50% au moins des candidats de N à N+1"
	manage:rounds:check50% $f
	# mise-à-jour suivant
	if {$folder(round:$round:use)} {
		manage:rounds:modify $f $round
	} else {
		$w.main.tot configure -text " [string tolower $msg(couples)]."
		manage:rounds:modify $f $next
	}

	# ajuste Tree
	manage:rounds:adjustTreeColor $f
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:rounds:split {f round {force 0} {fromUser 0}} {
variable $f
upvar 0 $f folder
variable gui
global msg


#TRACEF

	# demande confirmation
	if {$fromUser && ![selection:check $f $round]} {
		return
	}

	set w $gui(w:round:$round)

	if {$folder(round:$round:split)} {
		#-------- Activer --------
		SpinBox::configure $w.main.nb -label "$msg(firstChance), $msg(select2) "
		pack $w.sep $w.chance -side top -fill x -expand true
		# mise à jour variables
		#   levels
		set idx [lsearch -exact $folder(levels) $round]
		incr idx
		if {[lindex $folder(levels) $idx] != "$round.2"} {
			set folder(levels) [linsert $folder(levels) $idx $round.2]
		}
		#   juges
		if {![info exists folder(judges:$round.2)]} {
			set folder(judges:$round.2) $folder(judges:$round)
		}
		#   noms
		if {$folder(round:explicitNames)} {
			set name1 "[string toupper $msg(firstChance) 0 0] $msg(round:$round)"
			set name2 "[string toupper $msg(secondChance) 0 0] $msg(round:$round)"
		} else {
			set name1 [rounds:getName $f $round]
			set name2 [rounds:getName $f $round.2]
		}
		if {$force || ![info exists folder(round:$round:name)]} {
			set folder(round:$round:name) $name1
		}
		if {$force || ![info exists folder(round:$round.2:name)]} {
			set folder(round:$round.2:name) $name2
		}
		# mise à jour Tree / NoteBook
		if {[string first "." $f] == -1} {
			if {[Tree::exists $gui(w:tree) $f.$round]} {
				set index [Tree::index $gui(w:tree) $f.$round]
				Tree::delete $gui(w:tree) $f.$round
				Tree::delete $gui(w:tree) $f.$round.2
				Tree::insert $gui(w:tree) $index $f $f.$round.2 -data "round $round.2" \
						-text $folder(round:$round.2:name) -image imgRoundChance
				Tree::insert $gui(w:tree) $index $f $f.$round -data "round $round" \
						-text $folder(round:$round:name) -image imgRoundMain
				manage:rounds:adjustTreeColor $f
			}
		} else {
TRACEF
			set index [NoteBook::index $gui(w:notebook) $round]
			if {$index != -1} {
				if {$force || !$folder(round:explicitNames)} {
					manage:rounds:explicitNames $f
				}
				NoteBook::delete $gui(w:notebook) [string map {. _} $round]
				catch { NoteBook::delete $gui(w:notebook) [string map {. _} $round.2] }
				NoteBook::insert $gui(w:notebook) 3 [string map {. _} $round.2] \
						-text $folder(round:$round.2:name) \
						-raisecmd  "skating::ten:init:round [list $f] [list $gui(v:dance)] $round.2; \
									skating::fastentry:deselectAll; \
									skating::fastentry:mode $round.2; \
									set skating::gui(v:round) $round.2; \
									set skating::gui(v:judge) -1"
				NoteBook::insert $gui(w:notebook) $index [string map {. _} $round] \
						-text $folder(round:$round:name) \
						-raisecmd  "skating::ten:init:round [list $f] [list $gui(v:dance)] $round; \
									skating::fastentry:deselectAll; \
									skating::fastentry:mode $round; \
									set skating::gui(v:round) $round; \
									set skating::gui(v:judge) -1"
				ten:rounds:check $f $gui(v:dance)
			}
		}

	} else {
		#-------- Désactiver --------
		SpinBox::configure $w.main.nb -label "$msg(select2) "
		pack forget $w.sep $w.chance
		# vérification cohérence
		if {$folder(round:$round.2:nb) != 0} {
			# bon car 'nb+xxx2.nb <= max' par construction
			incr folder(round:$round:nb) $folder(round:$round.2:nb)
			set folder(round:$round.2:nb) 0
			set folder(round:$round.2:nbSelected) 0
			manage:rounds:modify $f $round
		} 
		# mise à jour variables
		catch {
			#   levels
			set idx [lsearch -exact $folder(levels) $round.2]
			set folder(levels) [lreplace $folder(levels) $idx $idx]
			#   noms
#  			set folder(round:$round:name) [rounds:getName $f $round]
#  			if {[info exists folder(round:$round.2:name)]} {
#  				unset folder(round:$round.2:name)
#  			}
			#   juges & couples
			catch {
				unset folder(judges:$round.2)
				unset folder(couples:$round.2)
			}
			#   notes
			foreach name [array names folder notes:$round.2:*] {
				unset folder($name)
			}
		}
		# mise à jour Tree
		if {[string first "." $f] == -1} {
			if {[Tree::exists $gui(w:tree) $f.$round]} {
				set index [Tree::index $gui(w:tree) $f.$round]
				Tree::delete $gui(w:tree) $f.$round
				Tree::delete $gui(w:tree) $f.$round.2
				Tree::insert $gui(w:tree) $index $f $f.$round -data "round $round" \
						-text $folder(round:$round:name) -image imgRound
				manage:rounds:adjustTreeColor $f
			}
		} else {
			set index [NoteBook::index $gui(w:notebook) $round]
			if {$index != -1} {
				if {$force || !$folder(round:explicitNames)} {
					manage:rounds:explicitNames $f
				}
				catch { NoteBook::delete $gui(w:notebook) [string map {. _} $round.2] }
				NoteBook::delete $gui(w:notebook) [string map {. _} $round]
				NoteBook::insert $gui(w:notebook) $index [string map {. _} $round] \
						-text $folder(round:$round:name) \
						-raisecmd  "skating::ten:init:round [list $f] [list $gui(v:dance)] $round; \
									skating::fastentry:deselectAll; \
									skating::fastentry:mode $round; \
									set skating::gui(v:round) $round; \
									set skating::gui(v:judge) -1"
				ten:rounds:check $f $gui(v:dance)
			}
		}
	}

	if {$force || !$folder(round:explicitNames)} {
		manage:rounds:explicitNames $f
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:rounds:modify {f round} {
variable $f
upvar 0 $f folder
variable gui
global msg

#TRACEFS

	set w $gui(w:round:$round)
	# rien à faire pour la finale, juste afficher pour prefinale
	if {$round == "finale"} {
		return
	}

	# initialisation
	set next [rounds:next $f $round 1]
	set previous [rounds:previous $f $round]

	#-------- round courant --------
	# configuration des valeurs mini/maxi
	set min [expr $folder(round:$next:nb)+$folder(round:$next.2:nb) - $folder(round:$round.2:nb)]
	if {$min < 1} {
		set min 1
	}
	set max [expr [manage:rounds:total $f $round] - $folder(round:$round.2:nb)]
	if {$round == "semi"} {
		set min 2
		set max [expr $max > 9 ? 9 : $max]
	}
	SpinBox::configure $w.main.nb -range [list $min $max 1]
	# mise-à-jour label + bornes pour repêchage
	set total [expr [manage:rounds:total $f $round]-$folder(round:$round:nb)]
	$w.chance.tot configure -text [format " $msg(couples:among) %d." $total]
	set min [expr $folder(round:$next:nb)+$folder(round:$next.2:nb) - $folder(round:$round:nb)]
	if {$min < 0} {
		set min 0
	}
	set max $total
	SpinBox::configure $w.chance.nb -range [list $min $max 1]
	# mise-à-jour label total couples pour le round (partie "couples sur XX.")
	if {$folder(round:$round:use)} {
		$w.main.tot configure -text [format " $msg(couples:among) %d." [manage:rounds:total $f $round]]
	} else {
		$w.main.tot configure -text " [string tolower $msg(couples)]."
	}

	#-------- round suivant --------
	if {$folder(round:$next:use)} {
		set wn $gui(w:round:$next)
		# configuration des valeurs mini/maxi
		if {$next != "finale"} {
			set range [SpinBox::cget $wn.main.nb -range]
			SpinBox::configure $wn.main.nb -range [lreplace $range 1 1 \
					[expr $folder(round:$round:nb)+$folder(round:$round.2:nb)]]
		}
		# mise-à-jour label pour total & repêchage du round suivant
		if {$next != "finale"} {
			set total [expr $folder(round:$round:nb)+$folder(round:$round.2:nb)]
			$wn.main.tot configure -text [format " $msg(couples:among) %d." $total]
			set total [expr $total-$folder(round:$next:nb)]
			$wn.chance.tot configure -text [format " $msg(couples:among) %d." $total]
		} else {
			$wn.main.tot configure -text [format "%d [string tolower $msg(couples)]." \
											 [expr {$folder(round:$round:nb)+$folder(round:$round.2:nb)}]]
		}
	}

	#-------- round précédent --------
	if {$folder(round:$previous:use)} {
		set wp $gui(w:round:$previous)
		# configuration des valeurs mini/maxi
		set range [SpinBox::cget $wp.main.nb -range]
		SpinBox::configure $wp.main.nb -range [lreplace $range 0 0 \
				[expr $folder(round:$round:nb)+$folder(round:$round.2:nb)]]
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:rounds:total {f round} {
variable $f
upvar 0 $f folder
variable gui
global msg


	set all {128 64 32 16 eight quarter semi finale}
	# cherche round précedent
	set index [lsearch -exact $all $round]
	# si déjà au top
	if {$index == 0} {
		return [llength $folder(couples:all)]
	}
	set previous [lindex $all [expr $index-1]]

	# si précédent non utilisés, alors renvoie nb total
	if {$folder(round:$previous:use) == 0} {
		return [llength $folder(couples:all)]
	}
	# calcul le total
	return [expr $folder(round:$previous:nb)+$folder(round:$previous.2:nb)]
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:rounds:check50% {f} {
variable $f
upvar 0 $f folder
variable gui
global msg

#TRACEF

	# l'utilisateur peut désactiver la règle
	if {!$folder(round:use50%rule)} {
		return
	}

	# assurer la règle du "50% au moins des candidats de N à N+1"
	set nb [llength $folder(couples:all)]
	set level [lindex $folder(levels) 0]
#TRACE "----- $nb / $level"
	while {$level != "finale"} {
#TRACE "level = $level / nb = $nb"
		# widget pour mise à jour du texte
		set next [rounds:next $f $level 1]
		set w $gui(w:round:$level)
		set wn $gui(w:round:$next)

		# deux cas en fonction du repêchage
		if {$folder(round:$level:split) == 0} {
			#---- NORMAL ----
#TRACE "    norml     $folder(round:$level:nb) < [expr ($nb+1)/2]"
			if {$folder(round:$level:nb) < ($nb+1)/2} {
				set folder(round:$level:nb) [expr {($nb+1)/2}]
				if {$next == "finale"} {
					# 9 maximum en finale ...
					if {$folder(round:$level:nb) > 9} {
						set folder(round:$level:nb) 9
					}
					$wn.main.tot configure -text [format "%d  [string tolower $msg(couples)]." $folder(round:$level:nb)]
				} else {
					$wn.main.tot configure -text [format " $msg(couples:among) %d." $folder(round:$level:nb)]
				}
			}
			set nb $folder(round:$level:nb)
		} else {
			#---- AVEC REPECHAGE ----
			regexp {[^.]*} $level main
#TRACE "    split    $folder(round:$main:nb)+$folder(round:$main.2:nb)=[expr {$folder(round:$main:nb)+$folder(round:$main.2:nb)}] < [expr ($nb+1)/2]"
			while {$folder(round:$main:nb)+$folder(round:$main.2:nb) < ($nb+1)/2} {
				incr folder(round:$main:nb)
				if {$next != "finale"} {
					$wn.main.tot configure -text [format " $msg(couples:among) %d." \
													 [expr {$folder(round:$main:nb)+$folder(round:$main.2:nb)}]]
				} else {
					$wn.main.tot configure -text [format "%d [string tolower $msg(couples)]." \
													 [expr {$folder(round:$main:nb)+$folder(round:$main.2:nb)}]]
				}
			}

			# 9 maximum en finale ...
			if {$next == "finale"} {
				while {$folder(round:$main:nb)+$folder(round:$main.2:nb) > 9} {
					if {$folder(round:$main.2:nb) == 0} {
						set folder(round:$main:nb) 9
						break
					} else {
						incr folder(round:$main.2:nb) -1
					}
				}
				$w.chance.tot configure -text [format " $msg(couples:among) %d." \
						[expr [manage:rounds:total $f $level]-$folder(round:$level:nb)]]
				$wn.main.tot configure -text [format "%d [string tolower $msg(couples)]." \
												 [expr {$folder(round:$main:nb)+$folder(round:$main.2:nb)}]]
			}

			set nb [expr {$folder(round:$main:nb)+$folder(round:$main.2:nb)}]
		}
		# suivant (ne tient pas compte des splits)
		set level $next
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:rounds:propagateJudges {f round} {
variable $f
upvar 0 $f folder

	# vérification des juges, propagation juges N+1 vers N
	# ou créer liste vide si besoin
#TRACE "propagate ![info exists folder(judges:$round)]"
	if {![info exists folder(judges:$round)]} {
		set next [rounds:next $f $round 1]
		if {[info exists folder(judges:$next)]} {
			set folder(judges:$round) $folder(judges:$next)
		} else {
			set folder(judges:$round) {}
		}
	}

	# gestion des juges requis par l'utilisateur
#TRACE "appending requested = $folder(judges:requested)"
	if {[llength [array names folder notes:$round:*]] == 0} {
		foreach j $folder(judges:requested) {
			if {[lsearch $folder(judges:$round) $j] == -1} {
				lappend folder(judges:$round) $j
			}
		}
	}
#TRACE "judges:$round = $folder(judges:$round)"
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:rounds:explicitNames {f} {
variable $f
upvar 0 $f folder
variable gui
global msg


	foreach round $folder(levels) {
		if {[string first "." $round] != -1} {
			continue
		}
		# construit le nom
		if {$folder(round:$round:split) && $folder(round:explicitNames)} {
			set name1 "[string toupper $msg(firstChance) 0 0] $msg(round:$round)"
			set name2 "[string toupper $msg(secondChance) 0 0] $msg(round:$round)"
		} else {
			set name1 [rounds:getName $f $round]
			set name2 [rounds:getName $f $round.2]
		}
		# affecte le nom & mets à jour affichage
		set folder(round:$round:name) $name1
		set folder(round:$round.2:name) $name2
		if {$folder(mode) == "normal"} {
			catch { Tree::itemconfigure $gui(w:tree) $f.$round -text $name1 }
			catch { Tree::itemconfigure $gui(w:tree) $f.$round.2 -text $name2 }
		}
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:rounds:editName {node} {
variable gui
variable dblclick

    if {[info exists dblclick]} {
		return
    }

	if {[lsearch [Tree::selection $gui(w:tree) get] $node] != -1 } {
		# format du node = folder.round(.2)?
		set selection $node
		set idx [string first "." $node]
		if {$idx != -1} {
			incr idx -1
			set round [string range $node [expr $idx+2] end]
			set node [string range $node 0 $idx]
		} else {
			# bizzare ...
			return
		}

		variable $node
		upvar 0 $node folder
		# édition proprement dite
		set gui(v:inEdit) 1
		set res [Tree::edit $gui(w:tree) $selection $folder(round:$round:name)]
		set gui(v:inEdit) 0
		if {$res != ""} {
			Tree::itemconfigure $gui(w:tree) $selection -text $res
			set folder(round:$round:name) $res
			# modifications ...
			set gui(v:modified) 1
		}
	}
}


#=================================================================================================
#
#	Fonctions d'aide
#
#=================================================================================================

# mode = io			pas de mise à jour graphique
#      = auto		création des entrées dynamique (mode auto)
#      = force		force création des entrées
proc skating::manage:rounds:generate {f mode} {
variable $f
upvar 0 $f folder

	manage:rounds:generate:$folder(mode) $f $mode
}

proc skating::manage:rounds:generate:qualif {f mode} {
variable $f
upvar 0 $f folder
variable gui
variable event
global msg

	# efface anciennes entrées
	if {$mode == "auto" || $mode == "create" || $mode == "force"} {
		Tree::delete $gui(w:tree) [Tree::nodes $gui(w:tree) $f]
	}

	# init variables
	set folder(levels) {qualif}
	set folder(round:qualif:name) [rounds:getName $f qualif]
	set folder(round:qualif:split) 0
	set folder(round:qualif:use) 1
	set folder(round:qualif:nb) [expr [llength $folder(couples:all)]/2]
	set folder(round:qualif.2:nb) 0
	if {![info exists folder(splitpoints)]} {
		set folder(splitpoints) {}
	}
	if {![info exists folder(subfolders)]} {
		set folder(subfolders) {}
	}

	manage:rounds:generate:addEntry $f $mode "qualif" "" "tree"
	manage:rounds:propagateJudges $f qualif
}

proc skating::manage:rounds:generate:normal {f mode} {
variable $f
upvar 0 $f folder
variable gui
variable event
global msg

#TRACEF "generation = $folder(round:generation)"

	# si danse d'une compétition 10 danses, pas de mise à jour GUI
	set updateGUI "tree"
	set dance ""
	if {[string first "." $f] != -1} {
#TRACE "ten-mode / $gui(v:folder) / $gui(v:dance)"
		set updateGUI "notebook"
		if {[info exists gui(v:dance)] && $gui(v:dance) != ""} {
			set dance $gui(v:dance)
		} else {
			set updateGUI ""
#			regexp -- {\w+.(.*)} $f dummy dance
#TRACE "   setting dance to '$dance'"
		}
		if {[llength [NoteBook::pages $gui(w:notebook)]] < 3} {
			set updateGUI ""
		}
	}

	if {$folder(round:generation) == "auto"} {
		#---- mode AUTO ----
		# efface anciennes entrées
		if {$mode == "auto" || $mode == "create" || $mode == "force"} {
			if {$updateGUI == "tree"} {
				Tree::delete $gui(w:tree) [Tree::nodes $gui(w:tree) $f]
			} elseif {$updateGUI == "notebook"} {
				NoteBook::delete $gui(w:notebook) [lrange [NoteBook::pages $gui(w:notebook)] 3 end-1]
			}
		}

		# init variables
		set isPrefinale 0
		if {[info exists folder(levels)] && [lsearch $folder(levels) prefinale] != -1} {
			set isPrefinale 1
		}
		set folder(levels) {}
		set nb [llength $folder(couples:all)]
		#----------------------------------------------------------------
		# les rounds
		foreach limit {384 192 96 48 24 12 7 0} round {128 64 32 16 eight quarter semi finale} select {384 192 96 48 24 12 6 0} {
			# nom du round
			if {![info exists folder(round:$round:name)]} {
				set folder(round:$round:name) [rounds:getName $f $round]
			}
			set folder(round:$round:split) 0

			if {$nb > $limit} {
				lappend folder(levels) $round
				set folder(round:$round:use) 1
				if {![info exists folder(round:$round:nbSelected)] || $folder(round:$round:nbSelected)==0} {
					set folder(round:$round:nb) $select
					set folder(round:$round.2:nb) 0
				}
				# ajout d'une entrée dans l'arbre
#TRACE "add entry {$f $mode $round $dance}"
				manage:rounds:generate:addEntry $f $mode $round $dance $updateGUI
				# propagation juges N+1 --> N
				manage:rounds:propagateJudges $f $round

			} else {
				set folder(round:$round:use) 0
				set folder(round:$round:nb) 0
				set folder(round:$round.2:nb) 0
			}
		}

		# cas particulier de la Prefinale
#TRACE "check prefinale / $isPrefinale"
		if {$isPrefinale} {
			set folder(levels) [linsert $folder(levels) end-1 prefinale]
#TRACE "add entry prefinale"
			manage:rounds:generate:addEntry $f $mode prefinale $dance $updateGUI finale
		}

		# ajuste Tree
		if {$mode != "create" && $updateGUI == "notebook"} {
			ten:rounds:check $f $dance
		}

	} else {
		#---- mode USER ----
		if {$mode == "create" || $mode == "force"} {
			# efface anciennes entrées
			if {$updateGUI == "tree"} {
				Tree::delete $gui(w:tree) [Tree::nodes $gui(w:tree) $f]
			} elseif {$updateGUI == "notebook"} {
#TRACE "---- deleted"
				NoteBook::delete $gui(w:notebook) [lrange [NoteBook::pages $gui(w:notebook)] 3 end-1]
			}
			# construit nouvelles valeurs
			foreach round $folder(levels) {
				if {[string first "." $round] != -1} {
					continue
				}
#TRACE "---- update 3"
				if {$updateGUI == "tree"} {
					Tree::insert $gui(w:tree) end $f $f.$round -data "round $round" \
							-text $folder(round:$round:name) -image imgRound
				} elseif {$updateGUI == "notebook"} {
#TRACE "---- creating(1) $round"
					NoteBook::insert $gui(w:notebook) end-1 [string map {. _} $round] \
							-text $folder(round:$round:name) \
							-raisecmd  "skating::ten:init:round [list $f] [list $dance] $round; \
										skating::fastentry:deselectAll; \
										skating::fastentry:mode $round; \
										set skating::gui(v:round) $round; \
										set skating::gui(v:judge) -1"
				}
				# mise à jour Tree si splité
				if {$folder(round:$round:split)} {
					if {$updateGUI == "tree"} {
						if {[Tree::exists $gui(w:tree) $f.$round]} {
							set index [Tree::index $gui(w:tree) $f.$round]
							Tree::delete $gui(w:tree) $f.$round
							Tree::insert $gui(w:tree) $index $f $f.$round.2 -data "round $round.2" \
									-text $folder(round:$round.2:name) -image imgRoundChance
							Tree::insert $gui(w:tree) $index $f $f.$round -data "round $round" \
								-text $folder(round:$round:name) -image imgRoundMain
						}
					} elseif {$updateGUI == "notebook"} {
#TRACE "---- creating(2) $round"
						NoteBook::delete $gui(w:notebook) [string map {. _} $round]
						NoteBook::insert $gui(w:notebook) end-1 [string map {. _} $round] \
								-text $folder(round:$round:name) \
								-raisecmd  "skating::ten:init:round [list $f] [list $dance] $round; \
											skating::fastentry:deselectAll; \
											skating::fastentry:mode $round; \
											set skating::gui(v:round) $round; \
											set skating::gui(v:judge) -1"
						NoteBook::insert $gui(w:notebook) end-1 [string map {. _} $round.2] \
								-text $folder(round:$round.2:name) \
								-raisecmd  "skating::ten:init:round [list $f] [list $dance] $round.2; \
											skating::fastentry:deselectAll; \
											skating::fastentry:mode $round.2; \
											set skating::gui(v:round) $round.2; \
											set skating::gui(v:judge) -1"
					}
				}
			}
			# vérification des juges, créer liste vide si besoin
			if {![info exists folder(judges:$round)]} {
				set next [rounds:next $f $round]
				if {[info exists folder(judges:$next)]} {
					set folder(judges:$round) $folder(judges:$next)
				} else {
					set folder(judges:$round) {}
				}
			}
			# ajuste Tree
			if {$mode != "create" && $updateGUI == "notebook"} {
				ten:rounds:check $f $dance
			}


		} elseif {$mode == "io"} {
			#---- mode IO ----
			# crée les variables qui pourraient manquer
			foreach round {128 64 32 16 eight quarter semi prefinale finale} {
				# génère les variables manquantes
				if {![info exists folder(round:$round:use)]} {
					set folder(round:$round:use) 0
					set folder(round:$round:nb) 0
					set folder(round:$round.2:nb) 0
					set folder(round:$round:split) 0					
				}
				# génère nom des rounds
				if {![info exists folder(round:$round:name)]} {
					# round simple
					if {$folder(round:explicitNames) && $folder(round:$round:split)} {
						set folder(round:$round:name) "[string toupper $msg(firstChance) 0 0] $msg(round:$round)"
					} else {
						set folder(round:$round:name) [rounds:getName $f $round]
					}
				}
				if {![info exists folder(round:$round.2:name)]} {
					# repêchage éventuel
					if {$folder(round:explicitNames) && $folder(round:$round:split)} {
						set folder(round:$round.2:name) "[string toupper $msg(secondChance) 0 0] $msg(round:$round)"
					} else {
						set folder(round:$round.2:name) [rounds:getName $f $round.2]
					}
				}
			}

		}

	}

	# ajoute entrée pour résultat
	if {$mode != "io"} {
		global colorDisabled
		if {$updateGUI == "tree" && ![Tree::exists $gui(w:tree) $f.__result__]} {
			Tree::insert $gui(w:tree) end $f $f.__result__ -data "result" \
					-text "$msg(result)" -image imgResult
		}
		# ajuste Tree
		manage:rounds:adjustTreeColor $f
	}
}

proc skating::manage:rounds:generate:addEntry {f mode round dance updateGUI {where end}} {
variable $f
upvar 0 $f folder
variable gui
global msg

#TRACEF

	# rien à faire en mode io
	if {$mode == "io"} {
		return
	}

	# position où inserer l'entrée
	if {$updateGUI == "tree"} {
		if {$where != "end"} {
			set where [Tree::index $gui(w:tree) $f.finale]
		}
	} elseif {$updateGUI == "notebook"} {
		if {$where != "end"} {
			set where end-2
		} else {
			set where end-1
		}
	}

	if {$mode == "auto" || $mode == "create" || $mode == "force"} {
		# do it
		if {$updateGUI == "tree"} {
			Tree::insert $gui(w:tree) $where $f $f.$round -data "round $round" \
					-text $folder(round:$round:name) -image imgRound
		} elseif {$updateGUI == "notebook" && $gui(v:inEvent) == 0} {
			NoteBook::insert $gui(w:notebook) $where [string map {. _} $round] \
					-text $folder(round:$round:name) \
					-raisecmd  "skating::ten:init:round [list $f] [list $dance] $round; \
								skating::fastentry:deselectAll; \
								skating::fastentry:mode $round; \
								set skating::gui(v:round) $round; \
								set skating::gui(v:judge) -1"
		}
	} elseif {$mode == "redisplay"} {
		if {$folder(round:explicitNames)} {
			set name1 "[string toupper $msg(firstChance) 0 0] $msg(round:$round)"
			set name2 "[string toupper $msg(secondChance) 0 0] $msg(round:$round)"
		} else {
			set name1 [rounds:getName $f $round]
			set name2 [rounds:getName $f $round.2]
		}
		# do it
		if {$updateGUI == "tree"} {
			Tree::insert $gui(w:tree) $where $f $f.$round -data "round $round" \
					-text [rounds:getName $f $round] -image imgRound
		} elseif {$updateGUI == "notebook" && $gui(v:inEvent) == 0} {
			NoteBook::insert $gui(w:notebook) $where [string map {. _} $round] \
					-text $folder(round:$round:name) \
					-raisecmd  "skating::ten:init:round [list $f] [list $dance] $round; \
								skating::fastentry:deselectAll; \
								skating::fastentry:mode $round; \
								set skating::gui(v:round) $round; \
								set skating::gui(v:judge) -1"
		}
	}
}

proc skating::manage:rounds:generate:ten {f mode} {
variable $f
upvar 0 $f folder
variable gui
global msg


#TRACEF "[info level -2]"
	# applique la génération pour chaque danse
	foreach dance $folder(dances) {
		manage:rounds:generate:normal $f.$dance $mode
	}

	if {$mode != "io"} {
		# efface anciennes entrées
		Tree::delete $gui(w:tree) [Tree::nodes $gui(w:tree) $f]
		# ajoute nouvelles entrées
		foreach dance $folder(dances) {
			Tree::insert $gui(w:tree) end $f $f.[join $dance "_"] -data "dance [list $dance]" \
					-text "$dance" -image imgRound
		}
		Tree::insert $gui(w:tree) end $f $f.__result__ -data "result" \
				-text "$msg(result)" -image imgResult

		# ajuste Tree
		manage:rounds:adjustTreeColor $f
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:rounds:adjustTreeColor {f} {
variable $f
upvar 0 $f folder
variable gui
global colorNormal colorDisabled


	if {[string first "." $f] == -1 && $folder(mode) == "normal"} {
		#---- système Classique
		foreach round $folder(levels) {
			if {[info exists folder(couples:$round)]} {
				set color $colorNormal
			} else {
				set color $colorDisabled
			}
			catch { Tree::itemconfigure $gui(w:tree) $f.$round -fill $color }
		}
		# premier toujours accessible
		catch { Tree::itemconfigure $gui(w:tree) $f.[lindex $folder(levels) 0] -fill $colorNormal }

	} else {
		#---- système 10-danses
		if {[string first "." $f] != -1} {
			set ff [lindex [split $f "."] 0]
		} else {
			set ff $f
		}
		variable $ff
		upvar 0 $ff topfolder
		foreach dance $topfolder(dances) {
			if {[check:dance $ff.$dance $dance]} {
				set color $gui(color:finishedDance)
			} else {
				set color $gui(color:activeDance)
			}
#TRACE "Tree::itemconfigure $ff.[join $dance "_"] -fill $color"
			catch { Tree::itemconfigure $gui(w:tree) $ff.[join $dance "_"] -fill $color }
		}
	}

	# item résultat à autoriser si classement global possible
	if {[string first "." $f] != -1} {
		set f [lindex [split $f "."] 0]
		if {[class:dances $f]} {
			set color $colorNormal
		} else {
			set color $colorDisabled
		}
	} elseif {$folder(mode) == "normal" && [info exists folder(couples:finale)] && [class:dances $f]} {
		set color $colorNormal
	} elseif {$folder(mode) == "ten" && [class:dances $f]} {
		set color $colorNormal
	} else {
		set color $colorDisabled
	}
	catch {Tree::itemconfigure $gui(w:tree) $f.__result__ -fill $color}
	catch {
		if {$color == $colorNormal} {
			set color $gui(color:finishedCompetition)
		} else {
			set color $gui(color:activeCompetition)
		}
		catch {Tree::itemconfigure $gui(w:tree) $f -fill $color}
	}
}


#-------------------------------------------------------------------------------------------------
#	Helpers routines (récupération du nom des rounds, suivant, précedent)
#-------------------------------------------------------------------------------------------------

proc skating::rounds:getName {f round} {
global msg
variable $f
upvar 0 $f folder

	if {!$folder(round:explicitNames)} {
		set index [expr [llength $folder(levels)]-[lsearch $folder(levels) $round]-1]
#puts "<skating::rounds:getName> index = $index / $round / '$folder(levels)'"
		set round [lindex {finale semi quarter eight 16 32 64 128 256 512 1024} $index]
	}
#puts "<skating::rounds:getName> new round = $round"

	set msg(round:$round)
}

proc skating::rounds:getShortName {f round} {
global msg
variable $f
upvar 0 $f folder

	if {!$folder(round:explicitNames)} {
		set index [expr [llength $folder(levels)]-[lsearch $folder(levels) $round]-1]
#puts "<skating::rounds:getShortName> index = $index / $round / '$folder(levels)'"
		set round [lindex {finale semi quarter eight 16 32 64 128 256 512 1024} $index]
	}
#puts "<skating::rounds:getShortName> new round = $round"

	set msg(round:short:$round)
}

#-------------------------------------------------------------------------------------------------

proc skating::rounds:next {f round {skipPrefinale 0}} {
variable $f
upvar 0 $f folder

	if {[set idx [string first "." $round]] != -1} {
		incr idx -1
		set round [string range $round 0 $idx]
	}

	if {[lsearch $folder(levels) prefinale] == -1 || $skipPrefinale} {
		set all {128 64 32 16 eight quarter semi finale}
	} else {
		set all {128 64 32 16 eight quarter semi prefinale finale}
	}
	set index [lsearch -exact $all $round]

	if {$index == [expr [llength $all]-1]} {
		return "finale"
	} else {
		return [lindex $all [expr $index+1]]
	}
}

proc skating::rounds:previous {f round} {
variable $f
upvar 0 $f folder


	if {[set idx [string first "." $round]] != -1} {
		incr idx -1
		set round [string range $round 0 $idx]
	}

	if {[lsearch $folder(levels) prefinale] == -1} {
		set all {128 64 32 16 eight quarter semi finale}
	} else {
		set all {128 64 32 16 eight quarter semi prefinale finale}
	}
	set index [lsearch -exact $all $round]

	if {$index == 0} {
		return "128"
	} else {
		return [lindex $all [expr $index-1]]
	}
}
