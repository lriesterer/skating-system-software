##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

proc skating::fastentry:init {w} {
variable gui

	bind $w <Alt-KeyPress> {# nothing}
	bind $w <Meta-KeyPress> {# nothing}
	bind $w <Control-KeyPress> {# nothing}

	bind $w <KeyPress> "skating::fastentry %K"
	set gui(v:after) ""
	fastentry:mode ""
}

proc skating::fastentry:mode {mode} {
variable gui

#TRACEF

	set gui(v:mode) $mode
	set gui(v:judge) -1
	set gui(v:byRank) $gui(pref:mode:compmgr)
	set gui(v:couple) ""
	set gui(v:judge:pending) ""
	set gui(v:ranking) 1
	# annule le timer d'inactivité
	if {$gui(v:after) != ""} {
		after cancel $gui(v:after)
	}
	set gui(v:after) ""
}

#-------------------------------------------------------------------------------------------------


proc skating::fastentry {k} {
global judgesLongMode
variable event
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder


#TRACEF "'$gui(v:mode)' '$gui(v:inEdit)'"		;# if [info exists gui(v:dance)] {puts $gui(v:dance)} else {puts "-"}

	# test du mode d'édition
	if {$gui(v:mode) == "" || $gui(v:inEdit) || $k == ""} {
		return
	}

	# filtre les touches
	set commit 0
	set letter 0
	switch -exact -regexp $k {
		0			-
		KP_Insert	{ set k 0 }
		1			-
		KP_End		{ set k 1 }
		2			-
		KP_Down		{ set k 2 }
		3			-
		KP_Next		{ set k 3 }
		4			-
		KP_Left		{ set k 4 }
		5			-
		KP_Begin	{ set k 5 }
		6			-
		KP_Right	{ set k 6 }
		7			-
		KP_Home		{ set k 7 }
		8			-
		KP_Up		{ set k 8 }
		9			-
		KP_Prior	{ set k 9 }

		space		-
		comma		-
		Return		-
		KP_Enter	-
		KP_Delete	{ set commit 1 }

		period		{ set k . }

		{[A-Z]}		-
		{[a-z]}		{ if {[string length $k] != 1} {
						  return 
					  } else {
						  set k [string toupper $k]
						  set letter 1
					  }
					}
	}

	#---------------------------------------------------
	# sélection des couples
	#---------------------------------------------------
	if {$gui(v:mode) == "init:couples"} {
		if {$letter} {
			set gui(v:couple) ""
		} elseif {$commit} {
			# si aucun numéro sélectionné ou numéro non attribué
			if {$gui(v:couple) == "" || [lsearch $event(couples) $gui(v:couple)] == -1} {
				bell
			} else {
				# OK, process
				manage:couples:toggle $gui(v:couple)
			}
			set gui(v:couple) ""
		} else {
			append gui(v:couple) $k
		}
		return
	}

	#---------------------------------------------------
	# sélection des juges
	#---------------------------------------------------
	if {$gui(v:mode) == "init:judges"} {
		if {!$commit} {
			append gui(v:judge:pending) $k
		}
#TRACE ">>>>>init:judges>>>>>>>>>>> fastentry / mode = $judgesLongMode / judge = $gui(v:judge:pending) / k = $k / commit = $commit"
		if {$letter || $commit} {
			if {!$judgesLongMode || ($judgesLongMode && $commit)} {
#TRACE "                 +++ committing judge = $gui(v:judge:pending) / $event(judges)"
				if {[lsearch $event(judges) $gui(v:judge:pending)] != -1} {
#TRACE "                 +++ manage:judges:toggleJudge $gui(v:folder) $gui(v:judge:pending) all"
					manage:judges:toggleJudge $gui(v:folder) $gui(v:judge:pending) all 1
				} else {
					bell
				}
				set gui(v:judge:pending) ""
			}
		} else {
			if {!$judgesLongMode} {
				set gui(v:judge:pending) ""
				bell
			}
		}
		return
	}

	#---------------------------------------------------
	# mode sans saisie
	#---------------------------------------------------
	if {$gui(v:mode) == "result"} {
		return
	}

	#---------------------------------------------------
	# saisie rapide de résultats
	#---------------------------------------------------
	# test si on édite une danse
	if {![info exists gui(v:dance)] || $gui(v:dance) == ""} {
		return
	}

	# annule le timer d'inactivité
	if {$gui(v:after) != ""} {
		after cancel $gui(v:after)
	}
	# déselection après 5 min = 5*60 = 300 seconds
	set gui(v:after) [after 300000 "skating::fastentry:deselectAll; set skating::gui(v:judge) -1"]

	# traitement de la saisie
	if {$letter || ($commit && $gui(v:judge:pending) != "")} {
		#---- LETTRE
		if {!$commit} {
			append gui(v:judge:pending) $k
		}
		# si on peut traiter l'input (pas de composition de nom de juges sur deux lettres)
		set long 0
		foreach j $folder(judges:$gui(v:round)) {
			if {[string length $j] > 1} {
				set long 1
				break
			}
		}
#TRACE ">>>>>>>>>>>>>>>> fastentry / mode = $long / judge = $gui(v:judge:pending) / k = $k / commit = $commit"
		# si on peut traiter l'input (pas de composition de nom de juges sur deux lettres)
		if {!$long || ($long && $commit)} {
			# déselection du l'ancien juge sélectionné
#TRACE "deselect (10)"
			fastentry:deselectAll
			# si lettre, sélection du juge avec vérification que le juge est valide pour le dossier
#TRACE "    committing judge $gui(v:judge:pending) / $folder(judges:$gui(v:round))"
			set judge [lsearch $folder(judges:$gui(v:round)) $gui(v:judge:pending)]
			if {$judge == -1} {
				set gui(v:judge) -1
				bell
			} else {
				# toggle mode d'entrée pour la finale
				if {$gui(v:judge) == $judge} {
					set gui(v:byRank) [expr !$gui(v:byRank)]
				} else {
					set gui(v:judge) $judge
					set gui(v:byRank) $gui(pref:mode:compmgr)
				}
				# reinitialise les données
				set gui(v:couple) ""
				set gui(v:ranking) 1
				fastentry:selectJudge
				fastentry:selectRanking
			}
			set gui(v:judge:pending) ""
		}
	} elseif {$gui(v:mode) == "finale" && !$gui(v:byRank)} {
		#---- CHIFFRE, finale
		# si activation de juge en attente, on active car on vient de saisir une note
#TRACE "j = $gui(v:judge)  //  '$gui(v:judge:pending)' // $k"
		if {$gui(v:judge) == -1 || $gui(v:judge:pending) != ""} {
#TRACE "deselect (11)"
			fastentry:deselectAll
			set judge [lsearch $folder(judges:$gui(v:round)) $gui(v:judge:pending)]
			if {$judge == -1} {
				set gui(v:judge) -1
				bell
				return
			} else {
				# toggle mode d'entrée pour la finale
				if {$gui(v:judge) == $judge} {
					set gui(v:byRank) [expr !$gui(v:byRank)]
				} else {
					set gui(v:judge) $judge
					set gui(v:byRank) $gui(pref:mode:compmgr)
				}
				# reinitialise les données
				set gui(v:ranking) 1
				fastentry:selectJudge
				fastentry:selectRanking
			}
			set gui(v:judge:pending) ""
		}
		# liste des couples
		set couples $folder(couples:finale)
		# si en finale comme nb couple maxi <= 9, selection directe par la touche
		if {$commit == 0} {
			set gui(v:couple) $k
			if {$gui(v:ranking)<=[llength $couples] && [fastentry:toggle]} {
				incr gui(v:ranking)
				fastentry:selectRanking
			}

			# @COMP_MGR@: avance automatique des juges
			if {$gui(pref:mode:compmgr) && $gui(v:ranking)>[llength $couples]} {
				# avance automatique juge suivant
				set judge $gui(v:judge)
				incr judge
#TRACE ">>> next"
				if {$judge >= [llength $folder(judges:finale)]} {
#TRACE "next dance armed"
					set gui(v:judge) -2
				} else {
#TRACE "new judge = $judge"
					set letters [lindex $folder(judges:finale) $judge]
					foreach l [split $letters {}] {
						after 250 "skating::fastentry $l"
					}
					after idle "skating::fastentry Return"
				}
			}
		}
		set gui(v:couple) ""

	} elseif {$gui(v:judge) == -2 && $commit} {
		#---- commit avec juge positionné à -2 dans round:toggle = danse suivante
		set next [lsearch $folder(dances) $gui(v:dance)]
		incr next
		set next [lindex $folder(dances) $next]
#TRACE "---- danse suivante = $next"
		if {$next == ""} {
			# sélection du résultat
			NoteBook::raise $gui(w:notebook) "result"
		} else {
			# sélection de la danse suivante
			NoteBook::raise $gui(w:notebook) [join $next "_"]
		}
		set gui(v:couple) ""

	} elseif {$gui(v:judge) >= 0 && $commit} {
		#---- CHIFFRE, round + commit
		# si séparateur, essaye de sélectionner
#TRACE "---- CHIFFRE, round + commit"
		if {[fastentry:toggle]} {
			if {$gui(v:mode) == "finale"} {
				incr gui(v:ranking)
				fastentry:selectRanking

				# @COMP_MGR@: avance automatique des juges
				if {$gui(pref:mode:compmgr) && $gui(v:ranking)>[llength $folder(couples:finale)]} {
					# avance automatique juge suivant
					set judge $gui(v:judge)
					incr judge
#TRACE ">>> next"
					if {$judge >= [llength $folder(judges:finale)]} {
#TRACE "next dance armed"
						set gui(v:judge) -2
					} else {
#TRACE "new judge = $judge"
						set letters [lindex $folder(judges:finale) $judge]
						foreach l [split $letters {}] {
							after 250 "skating::fastentry $l"
						}
						after idle "skating::fastentry Return"
					}
				}

			} else {
				round:highlight $gui(w:canvas:$gui(v:mode):$gui(v:dance)) \
						$gui(v:couple) $gui(v:judge)
			}
		}
		set gui(v:couple) ""
	} else {
		#---- CHIFFRE
		# si chiffre, ajoute à la selection (si pas de juge et chiffre ne faisant
		# pas partie d'un juge, erreur)
		if {$gui(v:judge) < 0 && $gui(v:judge:pending) == ""} {
			bell
		} elseif {$k != "."} {
			append gui(v:couple) $k
			if {$gui(v:judge:pending) != ""} {
				append gui(v:judge:pending) $k
			}

			# @COMP_MGR@: forcer la saisie sur 3 chiffres
			if {$gui(pref:mode:compmgr)} {
				if {[string length $gui(v:couple)] == 3} {
					set gui(v:couple) [string trimleft $gui(v:couple) "0"]
					# force un commit
					fastentry Return
				}
			}
		}
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::fastentry:selectJudge {} {
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder


	# si en mode navigation clavier, on ne veut pas d'inteférences
	if {$gui(v:mode) == "" || $gui(v:round) == "" || $gui(v:round) == "__result__"} {
		return
	}

	# différent si round ou finale
	set c $gui(w:canvas:$gui(v:mode):$gui(v:dance))
	if {$gui(v:mode) == "finale"} {
		$c itemconfigure "judge:[lindex $folder(judges:$gui(v:round)) $gui(v:judge)]" \
				-fill $gui(color:lightorange)
	} else {
		$c itemconfigure "judge:$gui(v:judge)" -fill $gui(color:orange)
		round:highlight $c -1 $gui(v:judge)
	}
}

proc skating::fastentry:selectRanking {} {
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder


	fastentry:adjustRanking
	# différent si round ou finale
	if {$gui(v:mode) == "finale"} {
		set c $gui(w:canvas:$gui(v:mode):$gui(v:dance))
		set judge [lindex $folder(judges:$gui(v:round)) $gui(v:judge)]
		if {$gui(v:byRank)} {
			$c itemconfigure "$judge:[expr $gui(v:ranking)-1]:f" -outline black -width 1
			$c itemconfigure "$judge:$gui(v:ranking):f" -outline $gui(color:orange) -width 2
			$c raise "$judge:$gui(v:ranking):f"
			$c raise "$judge:$gui(v:ranking):t"
		} else {
			$c itemconfigure "couple:$judge:all" -fill $gui(color:yellow)
			$c itemconfigure "couple:$judge:$gui(v:ranking)" -fill $gui(color:orange)
		}
	}
}

proc skating::fastentry:adjustRanking {} {
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder

	# si pas d'exclusion, ok. sinon skip les couples exclus
	if {$gui(v:mode) == "finale" && [info exists folder(exclusion:finale:$gui(v:dance))]} {
		# liste des couples
		set couples $folder(couples:finale)

		if {$gui(v:byRank)} {
			# sélection par place
			set max [expr [llength $couples]-[llength $folder(exclusion:finale:$gui(v:dance))]]
			if {$gui(v:ranking) > $max} {
#TRACE "deselect (1)"
				fastentry:deselectAll
				set gui(v:ranking) 100000
			}
		} else {
			# sélection par couples
			while {1} {
				set c [lindex $couples [expr {$gui(v:ranking)-1}]]
				if {[lsearch $folder(exclusion:finale:$gui(v:dance)) $c] == -1} {
					break
				}
				incr gui(v:ranking)
			}
		}
	}
}

proc skating::fastentry:deselectAll {} {
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder

#TRACES

	# différent si round ou finale
	if {[catch {set c $gui(w:canvas:$gui(v:mode):$gui(v:dance))}]} {
		# canvas déjà détruit ...
		return
	}
	catch {
		if {$gui(v:mode) == "finale"} {
			set judge [lindex $folder(judges:$gui(v:round)) $gui(v:judge)]
			$c itemconfigure "judge:$judge" -fill $gui(color:lightyellow)
			$c itemconfigure "couple:$judge:all" -fill $gui(color:yellow)
			$c itemconfigure "$judge:[expr $gui(v:ranking)-1]:f" -outline black -width 1
			$c itemconfigure "$judge:$gui(v:ranking):f" -outline black -width 1
		} else {
			$c itemconfigure "judge:$gui(v:judge)" -fill $gui(color:yellow)
		}
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::fastentry:toggle {} {
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder


	# si entrée vide, retour
	if {$gui(v:couple) == ""} {
		return 0
	}
	set dance $gui(v:dance)
	# liste des couples
	set couples $folder(couples:$gui(v:round))

#TRACE "couples=$couples"

	# vérifie si le couple est valide
	if {$gui(v:mode) == "finale"} {
		#---- FINALE
		if {$gui(v:byRank)} {
			# position entrée par couple
			if {[info exists folder(exclusion:finale:$dance)] &&
					[lsearch $folder(exclusion:finale:$dance) $gui(v:couple)] != -1} {
#TRACE "     ERROR - invalid couple - excluded"
				bell
				return 0
			}
			set index [lsearch $couples $gui(v:couple)]
#TRACE "by rank $gui(v:couple) / $index"
			if {$index == -1} {
TRACE "     ERROR - invalid couple '$gui(v:couple)'"
				bell
				return 0
			}
			return [notes:toggle $gui(v:folder) $gui(w:canvas:finale:$dance) \
								[lindex $folder(judges:$gui(v:round)) $gui(v:judge)] \
								[expr $index+1] \
								$gui(v:ranking) 1]
		} else {
			# position entrée par rang
			if {[info exists folder(exclusion:finale:$dance)]} {
				set max [expr [llength $couples]-[llength $folder(exclusion:finale:$dance)]]
			} else {
				set max [llength $couples]
			}
			if {$gui(v:couple) > $max} {
TRACE "     ERROR - invalid rank for '$gui(v:couple)'"
				bell
				return 0
			}
			return [notes:toggle $gui(v:folder) $gui(w:canvas:finale:$dance) \
								[lindex $folder(judges:$gui(v:round)) $gui(v:judge)] \
								$gui(v:ranking) $gui(v:couple) 1]
		}
	} else {
		#---- ROUND
		if {[lsearch $couples $gui(v:couple)] == -1} {
TRACE "     ERROR - invalid couple '$gui(v:couple)'"
			bell
			return 0
		}
		round:toggle $gui(v:folder) $gui(w:canvas:$gui(v:mode):$dance) \
					$dance $gui(v:mode) $gui(v:couple) $gui(v:judge) 1
	}

	# ok : prêt pour entrée suivante
	return 1
}
