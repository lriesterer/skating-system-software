##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

namespace eval skating {
	variable majority 0
}


#==============================================================================================
#
#	Classement d'une dance
#
#==============================================================================================

#----------------------------------------------------------------------------------------------
#	Vérification cohérence des notes
#----------------------------------------------------------------------------------------------

proc skating::check:dance {f dance} {
variable $f
upvar 0 $f folder


	# liste des couples
	if {![info exists folder(couples:finale)] || [llength $folder(judges:finale)]==0} {
		return 0
	}
	set couples $folder(couples:finale)

	# vérifie les notes attribuées par chaque juge
	set i 0
	set mask [expr {(0x7FFFFFFF >> (30-[llength $couples])) & ~1}]
#puts "mask = [format %08x $mask]"
	foreach j $folder(judges:finale) {
		set ok $mask
		foreach c $couples {
			if {![info exists folder(notes:finale:$c:$dance)]} {
				return 0
			}
			if {[lindex $folder(notes:finale:$c:$dance) $i]} {
#puts -nonewline "   $j:$c -- [format %02x $ok] & [format %02x [expr (1 << ([lindex $folder(notes:finale:$c:$dance) $i]-1))]] = "
				set ok [expr {$ok & ~(1 << int([lindex $folder(notes:finale:$c:$dance) $i]))}]
#puts "[format %02x $ok]"
			}
		}
		# tient compte des couples exclus (avec note autoattribuée)
#puts "coucou ok = [format %08x $ok] / '$dance'"
		if {[info exists folder(exclusion:finale:$dance)]} {
			set nb [expr {[llength $couples]-([llength $folder(exclusion:finale:$dance)]-1)}]
			foreach c $folder(exclusion:finale:$dance) {
#puts "  mask = [format %08x [expr {(1 << $nb)}]]"
				set ok [expr {$ok & ~(1 << $nb)}]
#puts "  new ok = [format %08x $ok]"
				incr nb
			}
		}
		# si il reste des bits à un, des notes n'ont pas été attribuées (doublon ou non saisie)
		if {$ok != 0} {
			return 0
		}
		incr i
	}

	return 1
}

#----------------------------------------------------------------------------------------------
#	Calcule interne pour le marquage "place ou mieux" pour une dance
#----------------------------------------------------------------------------------------------

proc skating::class:dance:placeOrBetter {f couples dance mark} {
variable $f
upvar 0 $f folder


	set tmp {}
	foreach c $couples {
		if {$folder(t:place:$c)} {
			lappend tmp [list $c -1 -1]
			continue
		}
		set n 0
		set total 0
		foreach m $folder(notes:finale:$c:$dance) {
			if {$m <= $mark} {
				incr n
				set total [expr $total + $m]
			}
		}
		lappend tmp [list $c $n $total]
		# information pour impression
		set idx [expr int($mark)-1]
		set folder(prt:$dance:mark+:$c) [lreplace $folder(prt:$dance:mark+:$c) \
					$idx $idx $n]
	}

	set folder(t:$mark+) [lsort -decreasing -command skating::class:sort $tmp]
#puts ">>>> marking '$dance' @ $mark+ = $folder(t:$mark+)"
}

proc skating::class:sort {a b} {
	# format = couple / nb marque ou miex / total
	if {[lindex $a 1] > [lindex $b 1]} {
		return 1
	} elseif {[lindex $a 1] < [lindex $b 1]} {
		return -1
	} else {
		# égalité : classement en fonction du plus petit total
		if {[lindex $a 2] <= [lindex $b 2]} {
			return 1
		} else {
			return -1
		}
	}
}

#----------------------------------------------------------------------------------------------
#	Classement de toutes les dances définies dans un dossier
#----------------------------------------------------------------------------------------------

proc skating::class:dances {f} {
variable $f
upvar 0 $f folder


#puts "skating::class:dances {$f}"

	if {$folder(mode) == "ten"} {
		foreach d $folder(dances) {
			# vérifie cohérence des notes
			if {![check:dance $f.$d $d]} {
#puts "erreur in dance $d"
				return 0
			}
 			class:dance $f.$d $d
		}

	} else {
		if {![info exists folder(couples:finale)]} {
			return 0
		}
		# reset le classement
		foreach c $folder(couples:finale) {
			set folder(places:$c) {}
		}
		# classe les danses
		foreach d $folder(dances) {
			# vérifie cohérence des notes
			if {![check:dance $f $d]} {
#puts "erreur in dance $d"
				return 0
			}
			# effectue le classement
 			class:dance $f $d
			# enregistre le résultat
			foreach c $folder(couples:finale) {
				lappend folder(places:$c) $folder(t:place:$c)
			}	
		}
	}

	return 1
}

#----------------------------------------------------------------------------------------------

proc skating::class:dance {f dance} {
variable $f
upvar 0 $f folder
variable majority
variable position
variable positionMax
variable mark


	# calcul de la majorité absolue
	set majority [expr int([llength $folder(judges:finale)]/2)+1]

	# liste des couples
	set couples $folder(couples:finale)

	# tous les couples sont initialement non classés
	set empty {}
	foreach c $couples {
		set folder(t:place:$c) 0
		lappend empty 0
	}
	# information pour impression
	foreach c $couples {
		set folder(prt:$dance:mark+:$c) $empty
		set folder(prt:$dance:marktotal:$c) $empty
	}

	# places et marque initiales
	set positionMax [llength $couples]
	set position 1
	set mark 1

	# classement
	class:dance:part $f $couples $dance
}

#----------------------------------------------------------------------------------------------

proc skating::class:dance:part {f couples dance {rule 0}} {
variable $f
upvar 0 $f folder
variable majority
variable position
variable positionMax
variable mark


	# calcule le classement
	set max [expr $position+[llength $couples]]
#puts "------------ $couples / mark=$mark --- position=$position>>positionMax=$positionMax ---------------"

	while {$position < $max} {
		# marques reçues pour la place cherchée "et mieux"
		class:dance:placeOrBetter $f $couples $dance $mark

		set index 0
		while {1} {
			set first [lindex $folder(t:$mark+) $index]
			incr index
			set next [lindex $folder(t:$mark+) $index]
#puts "  cmp <$first>--<$next>  --  mark=$mark pos=$position"

			if {[lindex $first 1] >= $majority} {
				if {[lindex $next 1] < $majority} {
					# <<Règle 5>> une seule majorité absolue --> classer
					set folder(t:place:[lindex $first 0]) $position
#puts "    (1) class [lindex $first 0] - $position  --  $dance"
					incr mark
					incr position
					if {$rule != 0} {
#puts "    >>>> return rule (1)"
						return
					}
					break

				} else {
					# chercher la plus grande majorité
					# ou la plus grande marque <<Règle 8>>
					if {[lindex $next 1] < [lindex $first 1]} {
						# <<Règle 6>> une plus grande majorité --> classer
						set folder(t:place:[lindex $first 0]) $position
#puts "    (2) class [lindex $first 0] - $position  --  $dance"
						incr position
						if {$rule != 0} {
#puts "    >>>> return rule (2)"
							return
						}
						continue
					} else {
						# <<Règle 7>> totaliser les marques de la place "et mieux"
						if {[lindex $next 2] != [lindex $first 2]} {
							# << Règle 7(a)>>
							set folder(t:place:[lindex $first 0]) $position
#puts "    (3) class [lindex $first 0] - $position  --  $dance"
							incr position
							# info pour impression
							set idx [expr $mark-1]
							set folder(prt:$dance:marktotal:[lindex $first 0]) [lreplace \
										$folder(prt:$dance:marktotal:[lindex $first 0]) \
										$idx $idx [lindex $first 2]]
							set folder(prt:$dance:marktotal:[lindex $next 0]) [lreplace \
										$folder(prt:$dance:marktotal:[lindex $next 0]) \
										$idx $idx [lindex $next 2]]

							if {$rule != 0} {
#puts "    >>>> return rule (3)"
								return
							}
							continue
						} else {
							# sauvegarde mark
							set oldmark $mark
							# << Règle 7(b)>> départage les couples ex-aequo
							set exaequo {}
							set i [expr $index-1]
							set tmp [lindex $folder(t:$mark+) $i]
							while {[lindex $first 1] == [lindex $tmp 1]
										&& [lindex $first 2] == [lindex $tmp 2]} {
								lappend exaequo [lindex $tmp 0]
#puts "    (4) class [lindex $tmp 0] - $position:$mark / ([lindex $first 1],[lindex $first 2])  --  $dance"
								# info pour impression
								set idx [expr $mark-1]
								set folder(prt:$dance:marktotal:[lindex $tmp 0]) [lreplace \
											$folder(prt:$dance:marktotal:[lindex $tmp 0]) \
											$idx $idx [lindex $first 2]]
								# exaequo suivant
								incr i
								set tmp [lindex $folder(t:$mark+) $i]
							}
							# données pour impression
							if {$rule != 0} {
								while {[lindex $first 1] == [lindex $tmp 1]} {
									# info pour impression
									set idx [expr $mark-1]
									set folder(prt:$dance:marktotal:[lindex $tmp 0]) [lreplace \
												$folder(prt:$dance:marktotal:[lindex $tmp 0]) \
												$idx $idx [lindex $tmp 2]]
									# exaequo suivant
									incr i
									set tmp [lindex $folder(t:$mark+) $i]
								}
							}

							incr mark
							if {$mark > $positionMax} {
#puts "    rule 7b -- '$exaequo' ex-aequo for $position"
								set delta [expr double([llength $exaequo]-1)/2]
								if {[expr int($delta)] == $delta} {
									set delta [expr int($delta)]
								}
								foreach c $exaequo {
									set folder(t:place:$c) [expr $position+$delta]
								}
								incr position [llength $exaequo]
#puts "    rule 7b -- after position = $position / $max"
							} else {
#puts "    recursive call : class:dance:part '$exaequo' $dance"
								class:dance:part $f $exaequo $dance $rule
							}
							if {$rule != 0} {
#puts "    >>>> return rule (4)"
								return
							}
							# reprend classement un fois la place attribuée
							set mark $oldmark
#puts "    resuming class with mark=$mark"
							break
						}
					}
				}
			} else {
				# pas de décision possible à ce niveau. Continuer la recherche
				incr mark
				if {$mark > $positionMax} {
#puts "    end -- ex-aequo"; bell
				}
				break
			}
		}
	}

#puts "============ $couples / $mark ================"
}


#==============================================================================================
#
#	Classement de la finale sur un dossier (ensemble de dances)
#
#==============================================================================================

#----------------------------------------------------------------------------------------------
#	Calcule interne pour le marquage "place ou mieux" sur l'ensemble des danses
#----------------------------------------------------------------------------------------------

proc skating::class:result:placeOrBetter {f couples mark rule} {
variable $f
upvar 0 $f folder

#TRACEF "for marks 1-$mark"

	set tmp {}
	foreach c $couples {
		if {$folder(t:place:$c)} {
			lappend tmp [list $c -1 -1]
			continue
		}
		set n 0
		set total 0
		foreach m $folder(places:$c) {
			if {$m <= $mark} {
				incr n
				set total [expr $total + $m]
			}
		}
		lappend tmp [list $c $n $total]
		# information pour impression
		set idx [expr $mark-1]
		set folder(prt:__${rule}__:mark+:$c) [lreplace $folder(prt:__${rule}__:mark+:$c) $idx $idx $n]
	}

	set folder(t:$mark+) [lsort -decreasing -command skating::class:sort $tmp]
#TRACE ">>>> marking finale @ $mark+ = $folder(t:$mark+) / rule=$rule"
}

#----------------------------------------------------------------------------------------------

proc skating::class:result {f {callback ""}} {
variable $f
upvar 0 $f folder
variable position
variable positionMax


#TRACEF

	# classe les couples danse par danse
	class:dances $f
	# tous les couples sont initialement non classés
	set folder(rules) {}
	foreach c $folder(couples:finale) {
		set folder(t:place:$c) 0
		lappend folder(rules) 0
	}
	# calcule total sur toutes les dances
	set totals {}
	set folder(totals) {}
	foreach c $folder(couples:finale) {
		set tmp 0
		foreach p $folder(places:$c) {
			set tmp [expr $tmp+$p]
		}
		lappend totals [list $c $tmp]
		lappend folder(totals) $tmp
	}
	set totals [lsort -real -index 1 $totals]
#TRACE "---- totals = $totals"

	# places et marque initiales
	set positionMax [llength $folder(couples:finale)]
	set position 1
	set mark 1

	# classement
	while {$position <= $positionMax} {
		# trouve tous les couples avec le même total
		set tieCouples [lindex [lindex $totals [expr $position-1]] 0]
		set tieValue [lindex [lindex $totals [expr $position-1]] 1]
		set index $position
		set tmp [lindex $totals $index]
		while {[lindex $tmp 1] == $tieValue} {
			lappend tieCouples [lindex $tmp 0]
			incr index
			set tmp [lindex $totals $index]
		}

#TRACE "for position $position  --  $totals  --  $tieValue / $tieCouples"

		if {[llength $tieCouples] == 1} {
			# <<Règle 9>> si un couple seulement, on le classe
			set folder(t:place:$tieCouples) $position
			incr position
		} else {
			# appliquer la règle 10
			class:result:rule10 $f $tieCouples
		}

		# callback indiquant la progression
		if {$callback != ""} {
			uplevel #0 $callback $position $positionMax
		}
	}

	# construit le résultat
	set folder(result) {}
	foreach c $folder(couples:finale) {
		lappend folder(result) $folder(t:place:$c)
	}

#TRACE "rules = $folder(rules)"
}

#----------------------------------------------------------------------------------------------

proc skating::class:result:rule10 {f couples} {
variable $f
upvar 0 $f folder
variable position
variable positionMax


	# init
	set allcouples $couples
	set localmark $position
	set rule 10
	set empty {}
	for {set i 0} {$i < [llength $folder(couples:finale)]} {incr i} {
		lappend empty -1
	}

	# calcule le classement
	set max [expr $position+[llength $couples]]
#TRACEF "---- RULE 10 ---- position=$position >> max=$max --------"


	set tiedLevel 0
	set tiedCouples($tiedLevel) [list ]
	set tiedRule($tiedLevel) 10


	while {$position < $max} {

#TRACE ">>>> looping with tied($tiedLevel) = $tiedCouples($tiedLevel)  //   rule=$rule"
#parray folder t:place:*

		# mise-à-jour de la liste des couples non classés
		if {[llength $tiedCouples($tiedLevel)] > 0} {
			set newcouples [list ]
			foreach c $tiedCouples($tiedLevel) {
				if {$folder(t:place:$c) == 0} {
					lappend newcouples $c
				}
			}
			set couples $newcouples

#TRACE "for position $position ---- continuing tied $couples"
			if {[llength $couples] == 0} {
				incr tiedLevel -1
				set rule $tiedRule($tiedLevel)
#TRACE "incr -1 -- continue"
				continue

			} elseif {[llength $couples] == 1} {
				# ferme la résolution d'une conflit, reprend avec le reste
				# des couples non encore classés
				set folder(t:place:$couples) $position
				incr position
				incr rule 2
				set localmark $position
				# restaure état précedent
				incr tiedLevel -1
				set rule $tiedRule($tiedLevel)
#TRACE "one couple left from tie ---- classing and continuing with rule $rule"
				continue
			}

		} else {
			set newcouples [list ]
			foreach c $allcouples {
				if {$folder(t:place:$c) == 0} {
					lappend newcouples $c
				}
			}
			set couples $newcouples
#TRACE "for position $position ---- new couples $couples"
		}
		# construit les marquages
		foreach c $couples {
			if {![info exists folder(prt:__${rule}__:mark+:$c)]} {
				set folder(prt:__${rule}__:mark+:$c) $empty
				set folder(prt:__${rule}__:marktotal:$c) $empty
				set folder(prt:__[expr ${rule}+1]__:mark+:$c) $empty
				set folder(prt:__[expr ${rule}+1]__:marktotal:$c) $empty
			}
		}

		# si il reste un couple, on le classe
		if {[llength $couples] == 1} {
			set folder(t:place:$couples) $position
			incr position
			return
		}

		# marque application de la règle 10 (+2*n)
		foreach c $couples {
			set idx [lsearch $folder(couples:finale) $c]
			if {[lindex $folder(rules) $idx] < $rule} {
				set folder(rules) [lreplace $folder(rules) $idx $idx $rule]
			}
		}
		# marques reçues pour la place cherchée "et mieux"
		class:result:placeOrBetter $f $couples $localmark $rule
#parray folder prt:__*

		set index 0
		set first [lindex $folder(t:$localmark+) $index]
		incr index
		set second [lindex $folder(t:$localmark+) $index]
#TRACE "==> compare <$first>--<$second>  --  pos=$position"

		# <<Règle 10(b) rechercher le plus grand nombre de place "ou mieux"
		if {[lindex $second 1] != [lindex $first 1]} {
			# nombre de place "ou mieux" différent --> classer
			set folder(t:place:[lindex $first 0]) $position
#TRACE "    RULE 10(b-place) -->  [lindex $first 0] // position=$position"
			incr position
			incr localmark
			continue
		} else {
			# <<Règle 10(b) sinon, totaliser les marques de la place "ou mieux"
			if {[lindex $second 2] != [lindex $first 2]} {
				# totaux différents --> classer
				set folder(t:place:[lindex $first 0]) $position
#TRACE "    RULE 10(b-total) -->  [lindex $first 0]"
				# info pour impression
				set idx [expr $position-1]
				set folder(prt:__${rule}__:marktotal:[lindex $first 0]) [lreplace \
							$folder(prt:__${rule}__:marktotal:[lindex $first 0]) $idx $idx [lindex $first 2]]
				set folder(prt:__${rule}__:marktotal:[lindex $second 0]) [lreplace \
							$folder(prt:__${rule}__:marktotal:[lindex $second 0]) $idx $idx [lindex $second 2]]

				incr position
				incr localmark
				continue
			} else {
				# <<Règle 11>>
				# cherche les couples concernés
				set tied [list [lindex $first 0]]
				set i $index
				set tmp [lindex $folder(t:$localmark+) $i]
				while {[lindex $first 1] == [lindex $tmp 1]
							&& [lindex $first 2] == [lindex $tmp 2]} {
					lappend tied [lindex $tmp 0]
					incr i
					set tmp [lindex $folder(t:$localmark+) $i]
				}
				# mémorise l'état
				incr tiedLevel
				set tiedCouples($tiedLevel) $tied
				set tiedRule($tiedLevel) $rule
#TRACE "    RULE 11 --> tied = $tied    //  tiedLevel=$tiedLevel / saved rule=$rule"

				# pour impression
				while {[lindex $first 1] == [lindex $tmp 1]} {
					# info pour impression
					set idx [expr $localmark-1]
					set folder(prt:__${rule}__:marktotal:[lindex $tmp 0]) [lreplace \
								$folder(prt:__${rule}__:marktotal:[lindex $tmp 0]) $idx $idx [lindex $tmp 2]]
					# suivant
					incr i
					set tmp [lindex $folder(t:$localmark+) $i]
				}

				# marque application de la règle 11
				foreach c $tied {
					set idx [lsearch $folder(couples:finale) $c]
					set folder(rules) [lreplace $folder(rules) $idx $idx [expr $rule+1]]
					# info pour impression
					set idx [expr $localmark-1]
					set folder(prt:__${rule}__:marktotal:$c) [lreplace \
								$folder(prt:__${rule}__:marktotal:$c) $idx $idx [lindex $first 2]]
				}

				# construit une méta-danse par agrégation des notes
				foreach c $tied {
					set folder(notes:finale:$c:__[expr ${rule}+1]__) {}
					if {$folder(mode) == "ten"} {
						# cas 10-danses
						set i 0
						foreach d $folder(v:overall:dances) {
							variable $f.$d
							upvar 0 $f.$d folder2
							set tenPosition [lindex $folder(places:$c) $i]
							if {$tenPosition > [llength $folder2(couples:finale)]} {
								set n $tenPosition
								foreach j $folder2(judges:finale) {
									lappend folder(notes:finale:$c:__[expr ${rule}+1]__) $n
								}
							} else {
								foreach n $folder2(notes:finale:$c:$d) {
									lappend folder(notes:finale:$c:__[expr ${rule}+1]__) $n
								}
							}
							# danse suivante
							incr i
						}
					} else {
						# cas normal
						foreach d $folder(dances) {
							foreach n $folder(notes:finale:$c:$d) {
								lappend folder(notes:finale:$c:__[expr ${rule}+1]__) $n
							}
						}
					}
#TRACE "        $c --> $folder(notes:finale:$c:__[expr ${rule}+1]__)"
					set nb [llength $folder(notes:finale:$c:__[expr ${rule}+1]__)]
				}
				# ---- calcule sur la méta-danse
				# on commence le recherche de place "ou mieux" à partir de la position courante
				variable mark
				set mark $position
				# ajuste la majorité (nb danse * nb juges)/2+1
				variable majority
				set majority [expr int($nb/2)+1]
				set folder(t:majority) $majority
				# classe sur la méta-danse
#TRACE "    ----> skating::class:dance:part $f $tied __[expr $rule-1]__ $rule"
				skating::class:dance:part $f $tied __[expr $rule+1]__ [expr $rule+2]

#TRACE "    ====> number tied = [llength $tied] among [llength $couples]"
				if {[llength $couples] != 3 || ([llength $couples] == 3 && [llength $tied] == 3 )} {
					incr rule 2
					set localmark $position
				}
			}
		}
	}
}



#==============================================================================================
#
#	Classement d'une danse d'un round
#
#==============================================================================================

#----------------------------------------------------------------------------------------------
#	Vérification cohérence des notes
#----------------------------------------------------------------------------------------------

proc skating::check:round {f dance level} {
variable $f
upvar 0 $f folder

#TRACEF

	# vérifie si danse est prise ou non en compte
	if {[lsearch $folder(dances:$level) $dance] == -1} {
		return 1
	}
	# liste des couples
	set couples $folder(couples:$level)

	# vérifie si danse déjà définie
	set couple [lindex $couples 0]
	if {![info exists folder(notes:$level:$couple:$dance)]} {
		return 0
	}
	# vérifie si nb de sélectionnés correct
	set judge 0
	foreach dummy $folder(judges:$level) {
		set total 0
		foreach couple $couples {
			incr total [lindex $folder(notes:$level:$couple:$dance) $judge]
		}
		if {$total != $folder(round:$level:nb)} {
			return 0
		}
		incr judge
	}
	return 1
}

#----------------------------------------------------------------------------------------------
#	Sélection des couples pour le round suivant
#----------------------------------------------------------------------------------------------

proc skating::class:round {f level {force 0}} {
variable $f
upvar 0 $f folder
variable gui

#TRACEF

	if {![info exists folder(dances:$level)]} {
		return -1
	}

	# classe les danses
	if {$folder(mode) == "ten"} {
		error "call of 'class:round' in ten mode dance"
	}
	set dances $folder(dances:$level)

	# si on force le calcul, pas de vérifications
	if {$force == 0} {
		foreach d $dances {
			# vérifie cohérence des notes
			if {![check:round $f $d $level]} {
				catch { unset folder(result:$level) }
				return 0
			}
		}
	}

	# liste des couples
	set couples $folder(couples:$level)

	# liste vide si notes non définies
	set empty {}
	foreach judge $folder(judges:$level) {
		lappend empty 0
	}

	# calcule le total obtenu par chaque couple
	set tmp {}
	foreach couple $couples {
		set preQualif [isPrequalified $f $couple $level]

		set total 0
		# pour les couples pré-qualifiés, ajoute 10000, pour être sûr de les
		# voir devant tout le monde + affichage avec un "P"
		if {$preQualif} {
			incr total 1000000
		}

		# calcul total global des mark + par danse
		set items [list ]
		foreach dance $dances {
			set subtotal 0
			# pour les couples pré-qualifiés, ajoute 1, pour marquage
			# pour affichage avec un "P"
			if {$preQualif} {
				incr subtotal
			}
			# addition des marks obtenues
			if {![info exists folder(notes:$level:$couple:$dance)]} {
				set folder(notes:$level:$couple:$dance) $empty
			} else {
				foreach note $folder(notes:$level:$couple:$dance) {
					incr total $note
					incr subtotal $note
				}
			}
			lappend items $subtotal
		}

		lappend tmp [linsert $items 0 $couple $total]
	}
	# effectue le classement
	set folder(result:$level) [lsort -decreasing -integer -index 1 $tmp]

	return 1
}


#==============================================================================================
#
#	Classement global sur un dossier (place de tous les couples)
#
#==============================================================================================

proc skating::class:folder {f {callback ""}} {
variable $f
upvar 0 $f folder

#TRACE "starting timer ..."; set t [clock clicks -milliseconds]
#  	set r [class:folder:$folder(mode) $f $callback]
#TRACE "timing = [expr {([clock clicks -milliseconds]-$t)/1000.0}]"
#	set r

	return [class:folder:$folder(mode) $f $callback]
}

#----------------------------------------------------------------------------------------------

proc skating::class:folder:ten {f callback} {
variable $f
upvar 0 $f folder


#TRACEF

	# construit la liste si elle n'existe pas
	if {![info exists folder(v:overall:dances)]} {
		set folder(v:overall:dances) $folder(dances)
	}
	# récupère le classement par danse
	set allCouples [list ]
#TRACE "starting timer"; set t [clock clicks -milliseconds]
	foreach dance $folder(v:overall:dances) {
		set folder(v:results:$dance) [lsort -integer -index 0 [class:folder:normal $f.$dance ""]]
		# liste des couples sur l'ensemble des danses
		set couples($dance) [list ]
		foreach item $folder(v:results:$dance) {
			set couple [lindex $item 0]
			lappend couples($dance) $couple
#			if {[lsearch $allCouples $couple] == -1} {
				lappend allCouples $couple
#			}
		}
#TRACE "couples <$dance> = $couples($dance)"
	}
	set allCouples [lsort -integer -unique $allCouples]
#	set allCouples [lsort -integer $allCouples]
#TRACE ">>>> list of couples built = [expr {([set t1 [clock clicks -milliseconds]]-$t)/1000.0}]"

	# construit un résult global par aggrégation
#TRACE "allCouples = $allCouples / [llength $allCouples]"
	foreach dance $folder(v:overall:dances) {
		# pour couple manquant, on lui affecte une dernière place
		set list [list ]
		set place [expr {([llength $allCouples]+[llength $couples($dance)]+1)/2.0}]
		if {int($place) == $place} {
			set place [expr {int($place)}]
		}
		foreach couple $allCouples {
			if {[lsearch $couples($dance) $couple] == -1} {
				lappend folder(v:results:$dance) [list $couple $place "-"]
			}
		}
		set folder(v:results:$dance) [lsort -real -index 0 $folder(v:results:$dance)]
#TRACE "$dance = $folder(v:results:$dance) / $couples($dance)"
	}
#TRACE ">>>> missing couples done = [expr {([set t2 [clock clicks -milliseconds]]-$t1)/1000.0}]"
	set i 0
	foreach couple $allCouples {
		set folder(places:$couple) [list ]
#TRACE "places:$couple = $folder(places:$couple) / $folder(v:overall:dances)"
		foreach dance $folder(v:overall:dances) {
			lappend folder(places:$couple) [lindex [lindex $folder(v:results:$dance) $i] 1]
		}
		incr i
#TRACE "places:$couple = $folder(places:$couple)"
	}

	set folder(couples:names) $allCouples
	set folder(couples:all) $allCouples


	# nettoyage des vielles données
	foreach pattern {prt:* t:*} {
		foreach n [array names folder $pattern] {
			unset folder($n)
		}
	}
#TRACE ">>>> ready to class = [expr {([set t3 [clock clicks -milliseconds]]-$t2)/1000.0}]"

	# effectue le classement sur cette méta-danse
	set folder(couples:finale) $allCouples
	class:result $f $callback
#TRACE ">>>> class done = [expr {([set t4 [clock clicks -milliseconds]]-$t3)/1000.0}]"
#TRACE ">>>>>>>> allCouples = $allCouples / [llength $allCouples]"
#TRACE ">>>>>>>> result = $folder(result)"
	# reconstruit un résultat exploitable
	set results [list ]
	set i 0
	foreach couple $allCouples {
		lappend results [list $couple [lindex $folder(result) $i] [lindex $folder(totals) $i] $folder(places:$couple)]
		incr i
	}
#TRACE ">>>> before last lsort = [expr {([clock clicks -milliseconds]-$t4)/1000.0}]"

	# retourne le résultat
	return [lsort -real -index 1 $results]
}

#----------------------------------------------------------------------------------------------

proc skating::class:folder:normal {f callback} {
variable $f
upvar 0 $f folder

#puts "skating::class:folder:normal {$f}"
	# init
	set all {}
	set done {}
	set position [expr {[llength $folder(couples:finale)]+1}]

	# pour la finale
	class:result $f $callback
#puts "$folder(couples:finale) / $folder(result)"
	foreach couple $folder(couples:finale) rank $folder(result) {
		lappend done $couple
		lappend all [list $couple $rank finale $rank $rank]
	}

	# pour les autres niveaux
	foreach round [lrange [reverse $folder(levels)] 1 end] {
		class:round $f $round 1
#puts "---- $round = $folder(result:$round)"
		class:computePlaces $folder(result:$round)
	}

#puts "skating::class:folder:normal {$f} / $all"
	# tri selon la place
	return [lsort -real -index 1 $all]
}

#----------------------------------------------------------------------------------------------

proc skating::class:finale {f} {
variable $f
upvar 0 $f folder

#TRACEF

	# finale
	class:result $f
	foreach couple $folder(couples:finale) rank $folder(result) {
		lappend all [list $couple $rank finale]
	}
	# tri selon la place
	return [lsort -real -index 1 $all]
}

#----------------------------------------------------------------------------------------------

proc skating::class:computePlaces {results} {
upvar done done all all position position
upvar round round


	set lasttotal -1
	set min 0
	set max -1
	set tied [list ]
	foreach item $results {
		set couple [lindex $item 0]
		set total [lindex $item 1]
		# correction du total pour les couples pré-qualifiés
		if {$total > 1000000} {
			incr total -1000000
		}
		# calcul la place à affecter
		if {$total != $lasttotal} {
			set lasttotal $total
			# affecte la place moyenne
#puts "---- $min / $max"
			if {$max > 0} {
				set place [expr {$min + ($max-1-$min)/2.0}]
				if {$place == [expr {int($place)}]} {
					set place [expr {int($place)}]
				}
				foreach {c round} $tied {
					lappend all [list $c $min $round [expr {$max-1}] $place]
				}
#puts "     affecting place $place to '$tied'"
				set tied [list ]
			}
			set min $position
		}

		# traite le couple
#puts "    ???? $couple"
		if {[lsearch -exact $done $couple] == -1} {
			# si couple pas déjà traité
#puts "    ++++ $couple added"
			lappend tied $couple $round
			incr position
			set max $position
			# couple vu
			lappend done $couple
		}
	}


	# affecte la place moyenne
#puts "==== $min / $max"
	if {$max > 0} {
		set place [expr {$min + ($max-1-$min)/2.0}]
		if {$place == [expr {int($place)}]} {
			set place [expr {int($place)}]
		}
		foreach {couple round} $tied {
			lappend all [list $couple $min $round [expr {$max-1}] $place]
		}
		set tied [list ]
	}
}
