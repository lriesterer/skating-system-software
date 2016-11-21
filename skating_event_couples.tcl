##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion de la liste des couples
#
#=================================================================================================

proc skating::event:couples:init {w} {
global msg
variable gui
variable event


	# calcule le nombre de compétitions
	set buttons 0
	foreach f $event(folders) {
		set gui(t:init:couples:$buttons) $f
		incr buttons
		# un pour chaque danse en mode 10-danses
		variable $f
		upvar 0 $f folder
		if {$folder(mode) == "ten"} {
			foreach d $folder(dances) {
				set gui(t:init:couples:$buttons) $f.$d
				incr buttons
			}
		}
	}
	set gui(t:init:couples:total) $buttons

	# table principale
	set sw [ScrolledWindow::create $w.sw \
				-scrollbar both -auto both -relief sunken -borderwidth 1]
	set table [Table::create $w.t 3 1 0 .popCouples {^\d{0,4}\.?\d?$} \
						$buttons \
							skating::event:couples:buttons:display \
							skating::event:couples:buttons:handle \
							skating::event:couples:buttons:tip \
						skating::event:couples:getIndex \
						skating::event:couples:validateIndex \
						skating::event:couples:modify \
						skating::event:couples:completion \
						skating::event:couples:canDeleteIndex]
	set gui(w:init:couples) $table
	ScrolledWindow::setwidget $sw $table
	# fin paramétrage de la table
	if {$event(useCountry)} {
		set text $msg(country)
	} else {
		set text $msg(schoolClub)
	}
	$table set row 0,0 [list $msg(number) $msg(name) $text]
	if {$::tcl_platform(platform) == "windows"} {
		$table width -1 5 0 5 1 54 2 20
	} else {
		$table width -1 5 0 5 1 46
	}
	# popup menu pour la table
	if {![winfo exists .popCouples]} {
		set m [menu .popCouples -tearoff 0 -bd 1]
			regsub -all -- {\n} $msg(insert:before) { } label
			$m add command -label $label -command {Table::insert:before $tkPriv(tkCurrentTable)}
			regsub -all -- {\n} $msg(insert:after) { } label
			$m add command -label $label -command {Table::insert:after $tkPriv(tkCurrentTable)}
			$m add separator
			$m add command -label $msg(remove) -command {skating::event:couples:remove}
	}

	# help
	text $w.h -font tips -height 2 -relief flat -bg [$w cget -background] -tabs {125}
	set gui(w:init:couples:help) $w.h
	$w.h tag configure blue -foreground darkblue
	$w.h tag configure red -foreground red
	bindtags $w.h "$w.h all"
	eval $w.h insert 1.0 $msg(help:couples:edit)

	# boutons
	set but2 [frame $w.b2]
	  set gui(w:init:couples:buttons) $but2
	  button $but2.remove -text $msg(remove) -bd 1 -command "skating::event:couples:remove"
	  button $but2.removeall -text $msg(removeall) -bd 1 -command "skating::event:couples:removeall"
	  button $but2.insb -text $msg(insert:before) -bd 1 -command "Table::insert:before $table"
	  button $but2.insa -text $msg(insert:after) -bd 1 -command "Table::insert:after $table"

	  button $but2.sort0 -text $msg(numberSorting) -bd 1 -command "skating::event:couples:grouping:dialog"
	  button $but2.sort -text $msg(redisplay) -bd 1 -command "skating::event:couples:redisplay"
	  button $but2.toclip -text $msg(toclip) -bd 1 -command "skating::event:couples:toClipboard $table"
	  button $but2.fromclip -text $msg(fromclip) -bd 1 -command "skating::event:couples:fromClipboard"
	  button $but2.fromclip2 -text $msg(fromclip2) -bd 1 -command "skating::event:couples:clear&fromClipboard"
	  SpinBox::create $but2.from -labelwidth 10 -label $msg(from) -range {1 1000 1} \
				-width 4 -entrybg gray95 -textvariable ::quickCouplesFrom \
				-selectbackground $gui(color:selection) \
				-modifycmd {if {$::quickCouplesTo < $::quickCouplesFrom} {set ::quickCouplesTo $::quickCouplesFrom}}
		set ::quickCouplesFrom 1
	  SpinBox::create $but2.to -labelwidth 10 -label $msg(to) -range {1 1000 1} \
				-width 4 -entrybg gray95 -textvariable ::quickCouplesTo \
				-selectbackground $gui(color:selection) \
				-modifycmd {if {$::quickCouplesFrom < $::quickCouplesTo} {set ::quickCouplesFrom $::quickCouplesTo}}
		bind $but2.to.e <Return> "$but2.quick invoke"
		set ::quickCouplesTo 10
	  button $but2.quick -text $msg(create) -bd 1 -command "skating::event:couples:quickCreate"
	  checkbutton $but2.country -text $msg(useCountry) -variable skating::event(useCountry) \
				-command skating::event:couples:useCountry -bd 1
	  #----
	  pack $but2.remove $but2.removeall -fill x -pady 2
	  pack [frame $but2.sep1 -height 15]
	  pack $but2.insb $but2.insa -fill x -pady 2
	  pack [frame $but2.sep2 -height 15]
	  pack $but2.sort0 $but2.sort -fill x -pady 2
	  pack [frame $but2.sep3 -height 25]
	  pack $but2.toclip $but2.fromclip $but2.fromclip2 -fill x -pady 2
	  pack [frame $but2.sep4 -height 35]
	  pack $but2.from $but2.to $but2.quick -fill x -pady 2
	  pack [frame $but2.sep5 -height 10]
	  pack $but2.country -fill x

	# mise en page
	pack $w.b2 -side right -fill y
	pack $w.h -side bottom -fill x
	pack $sw -side left -expand true -fill both
	pack [frame $w.sep2 -width 10] -side left

	# inits
#	set gui(v:db:couples:modified) 0
	focus $gui(w:init:couples)
	after idle "skating::event:couples:display"
}

#-------------------------------------------------------------------------------------------------

proc skating::event:couples:useCountry {} {
variable gui
variable event
global msg

	if {$event(useCountry)} {
		$gui(w:init:couples) set 0,2 $msg(country)
	} else {
		$gui(w:init:couples) set 0,2 $msg(schoolClub)
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::event:couples:display {} {
variable gui
variable event
global msg

#TRACEF

	if {[info exists event(couples)] && [llength $event(couples)]} {
		# insert les couples
		$gui(w:init:couples) configure -rows [expr [llength $event(couples)]+1]
		set i 1
		foreach couple [lsort -real $event(couples)] {
			$gui(w:init:couples) set row $i,-1 [list $couple $couple $event(name:$couple) $event(school:$couple)]
			incr i
		}
		Table::select $gui(w:init:couples) "1,0"
	} else {
		# insert un premier couple par défaut
		set event(couples) {1}
		set event(name:1) ""
		set event(school:1) ""
		$gui(w:init:couples) configure -rows 2
		$gui(w:init:couples) set row 1,0 [list "1" "" ""]
		Table::setValue $gui(w:init:couples) 1,-1 "1"
		Table::activate $gui(w:init:couples) "1,0"
		set i 2
	}

	#---- les boutons de sélection rapide & pré-remplit la table
#set c [clock clicks -milliseconds]

	set last ""
	set number 0
	set table $gui(w:init:couples)
	set empty [string repeat "$msg(no) " [llength $event(couples)]]
	set emptyBut [string repeat "$msg(all) " [llength $event(couples)]]
	for {set i 0} {$i < $gui(t:init:couples:total)} {incr i} {
		set col [expr {3+$i}]
		$table width $col 5
		set f $gui(t:init:couples:$i)
		variable $f
		upvar 0 $f folder
		# affiche label pour la colonne
		if {[set index [string first "." $f]] != -1} {
			$table set 0,$col $number.[firstLetters [string range $f [expr {$index+1}] end]]
		} elseif {$f != $last} {
			incr number
			$table set 0,$col $number
			set last $f
		}
		# tag toute la colonne en première approximation
		if {$folder(mode) != "ten"} {
			$table set col 1,$col "$empty"
			$table tag col OFF $col
		} else {
			$table set col 1,$col "$emptyBut"
			$table tag col BUTTON $col
		}
	}
#set cc [clock clicks -milliseconds]; TRACE "[expr $cc-$c]"

	# contenu pour chaque couple - définit le type de bouton
	set couples [lsort -real $event(couples)]
	for {set i 0} {$i < $gui(t:init:couples:total)} {incr i} {
		set f $gui(t:init:couples:$i)
		# définit le type de bouton
		variable $f
		upvar 0 $f folder
		# itère pour chaque couple par compétition
		set row 1
		foreach couple $couples {
			if {$couple != [expr {int($couple)}] && ($folder(mode) == "ten" || [string first "." $f] != -1)} {
				# c'est un alias en mode 10-danses = interdit
				if {$folder(mode) == "ten"} {
					Table::buttons:setStyle $table $row $i BUTTON_DISABLED
				} else {
					Table::buttons:setStyle $table $row $i DISABLED
				}
			} else {
				# cherche si couple inscrit pour compétition
				if {$folder(mode) == "normal" && [lsearch $folder(couples:names) $couple] != -1} {
					Table::buttons:setStyle $table $row $i ON
				}
			}
			# couple suivant
			incr row
		}
	}
#set ccc [clock clicks -milliseconds]; TRACE "[expr $ccc-$cc]  //  [expr $ccc-$c]"
}

proc skating::event:couples:redisplay {} {
variable gui
variable event

	# essaie de valider la saisie en cours (si besoin)
	if {[Table::validate:entry $gui(w:init:couples)] == 0} {
		return
	}
	# réaffichage
	event:couples:display
}

#-------------------------------------------------------------------------------------------------

proc skating::event:couples:getIndex {nb1 nb2 {lastrow -1}} {
variable event

#TRACEF

	if {$nb1 != ""} {
		set nb1 [expr {int($nb1)}]
	}
	if {$nb2 != ""} {
		set nb2 [expr {int($nb2)}]
	} else {
		set nb2 -1
	}
	set lastrow [expr {int($lastrow)}]
	if {$nb2 > $nb1+1} {
		set nb [expr {$nb1+1}]
	} elseif {$lastrow != -1} {
		set nb [expr {$lastrow+1}]
	} else {
		set nb -1
	}

	if {[lsearch $event(couples) $nb] != -1 || $nb == -1} {
		if {$lastrow != -1} {
			bell
			bell
		}
		set max [lindex [lsort -real $event(couples)] end]
		set nb [expr {int($max+1)}]
	}
	set nb
}

proc skating::event:couples:validateIndex {nb} {
global msg
variable event

#TRACEF "[lsearch $event(couples) $nb] / $event(couples)"

	if {$nb != int($nb) && ([lsearch $event(couples) [expr {int($nb)}]] == -1)} {
		event:couples:error help:couples:alias
		set valid 0
	} else {
		if {$nb == int($nb)} {
			set nb [expr {int($nb)}]
		}
		set valid [expr {[lsearch $event(couples) $nb] == -1}]
		if {!$valid} {
			event:couples:error help:couples:error
		}
	}
	# return result
	set valid
}

proc skating::event:couples:canDeleteIndex {{nb -1}} {
variable event

	expr {[lsearch $event(couples) $nb] == -1}
}

proc skating::event:couples:modify {row column couple oldCouple data} {
variable gui
variable event

#TRACE "col=$column couple='$couple' old='$oldCouple' data='$data'"

	if {$oldCouple != 0 } {
		if {$column != 0} {
			return -code error "oldCouple set but column=$column"
		}
		# modification du numéro d'un couple
#TRACE "    changing couple '$oldCouple' to '$couple'"
		foreach c $event(couples) {
			if {$c != $oldCouple && int($c) == int($oldCouple)} {
				Table::setValue $gui(w:init:couples) $row,0 $oldCouple
				event:couples:error help:couples:alias2
				return
			}
		}

		# changement de numéro d'un couple


		# mise à jour header
		Table::setValue $gui(w:init:couples) $row,-1 $couple

	} else {
		if {$column == 0} {
			# création d'un nouveau couple
#TRACE "    creating couple '$couple'"
			if {$couple != int($couple)} {
				lappend event(couples) $couple
				set c [expr {int($couple)}]
#TRACE "    	using old data"
				set event(name:$couple) $event(name:$c)
				set event(school:$couple) $event(school:$c)
				Table::setValue $gui(w:init:couples) $row,1 $event(name:$c)
				Table::setValue $gui(w:init:couples) $row,2 $event(school:$c)
			} else {
				# traite x et x.0 de la même façon
				set couple [expr {int($couple)}]
				lappend event(couples) $couple
				Table::setValue $gui(w:init:couples) $row,0 $couple
				set event(name:$couple) ""
				set event(school:$couple) ""
			}

			# mise à jour header
			Table::setValue $gui(w:init:couples) $row,-1 $couple

		} elseif {$column == 1} {
			# modification du nom
#TRACE "    updating name:'$couple'"
			variable db
			set idx [lsearch -exact $db(couples) $event(name:$couple)]
			# remplace ou ajoute en début de liste
			set db(couples) [lreplace $db(couples) $idx $idx $data]
			set gui(v:db:modified) 1

			set event(name:$couple) $data

		} elseif {$column == 2} {
			# modification dun club/école
#TRACE "    updating school:'$couple'"
			variable db
			set idx [lsearch -exact $db(schools) $event(name:$couple)]
			# remplace ou ajoute en début de liste
			set db(schools) [lreplace $db(schools) $idx $idx $data]
			set gui(v:db:modified) 1

			set event(school:$couple) $data
		}
	}

	# modifications ...
	set gui(v:modified) 1
	return 1
}


proc skating::event:couples:swap {oldCouple couple} {
variable gui
variable event

#TRACEF

	set idx [lsearch $event(couples) $oldCouple]
	set event(couples) [lreplace $event(couples) $idx $idx $couple]
	# change données sur le couple
	set event(name:$couple) $event(name:$oldCouple)
	unset event(name:$oldCouple)
	set event(school:$couple) $event(school:$oldCouple)
	unset event(school:$oldCouple)
	# change numéro dans les compétitions
	foreach ff $event(folders) {
		variable $ff
		upvar 0 $ff folder
		if {$folder(mode) == "ten"} {
			set list [list ]
			foreach dance $folder(dances) {
				lappend list $ff.$dance
			}
		} else {
			set list $ff
		}
		foreach f $list {
			variable $f
			upvar 0 $f folder
			# mise-à-jour dans couples sélectionnés
			foreach name [array names folder couples:*] {
				if {$name == "couples:names"} {
					set idx [lsearch $folder($name) $oldCouple]
					if {$idx != -1} {
						set folder($name) [lsort -real [lreplace $folder($name) $idx $idx $couple]]
#TRACE "    -- $folder(label) -- couples: $name --> $folder($name)"
					}
				} else {
					set c [expr {int($couple)}]
					set idx [lsearch $folder($name) $oldCouple]
					if {$idx != -1} {
						set folder($name) [lsort -integer [lreplace $folder($name) $idx $idx $c]]
#TRACE "    -- $folder(label) -- couples: $name --> $folder($name)"
					}
				}
			}
			# mise-à-jour notes du couple
			foreach name [array names folder notes:*:$oldCouple:*] {
				regsub -- $oldCouple $name $couple name2
#TRACE "    -- $folder(label) -- notes: $name --> $name2"
				set folder($name2) $folder($name)
				unset folder($name)
			}
		}	
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::event:couples:remove {{couple 0}} {
global msg
variable gui
variable event

	# test si un couple est sélectionné
	if {$couple == 0} {
		set couple [Table::get:currentIndex $gui(w:init:couples)]
		if {$couple == ""} {
			bell
			return -1
		}
	}
	# test si le couple est utilisé
	set use {}
	foreach f $event(folders) {
		variable $f
		upvar 0 $f folder

		if {$folder(mode) == "ten"} {
			foreach dance $folder(dances) {
				variable $f.$dance
				upvar 0 $f.$dance Dfolder

				if {[lsearch $Dfolder(couples:names) $couple] != -1} {
					lappend use "$Dfolder(label) ($dance)"
				}
			}

		} else {
			if {[lsearch $folder(couples:names) $couple] != -1} {
				lappend use $folder(label)
			}
		}
	}
	# si on veut enlever une racine et des alias sont définis
	set stem [expr {int($couple)}]
	if {$stem == $couple && [llength [array names event "name:$stem.*"]]} {
		tk_messageBox -icon "warning" -type ok -default ok \
				-title $msg(dlg:information) -message "$msg(dlg:coupleUseAlias)"
		return -1
	}
	# si utilisé, demande confirmation avant suppression
	if {[llength $use]} {
		if {[llength $use] > 4} {
			set use [lreplace $use 4 end "..."]
		}
		set text ""
		foreach comp $use {
			append text "  - $comp\n"
		}
		tk_messageBox -icon "warning" -type ok -default ok \
				-title $msg(dlg:information) -message "$msg(dlg:coupleUsed)\n$text"
		return -1
	}

	# ok pour suppression
	foreach item {name school} {
		unset event($item:$couple)
	}
	set idx [lsearch $event(couples) $couple]
	set event(couples) [lreplace $event(couples) $idx $idx]
	# mise-à-jour affichage
	Table::deleteCurrent $gui(w:init:couples)

#TRACE "suppression '$couple' / $event(couples)"
	return 0
}

proc skating::event:couples:removeall {} {
variable event

	foreach couple $event(couples) {
		if {[event:couples:remove $couple] < 0} {
			return -1
		}
	}
	# réaffichage avec insertion d'un premier couple par défaut
	event:couples:display
	return 0
}

#-------------------------------------------------------------------------------------------------

proc skating::event:couples:toClipboard {table} {
variable gui
variable event
global msg

	# essaie de valider la saisie en cours (si besoin)
	if {[Table::validate:entry $gui(w:init:couples)] == 0} {
		event:couples:error help:couples:error
		return
	}

	# on possède la sélection
	clipboard clear -displayof $table
	foreach couple $event(couples) {
	    clipboard append -displayof $table "$couple\t$event(name:$couple)\t$event(school:$couple)\n"
	}
#TRACE "<to clipboard>"
}

proc skating::event:couples:fromClipboard {} {
variable gui
variable event

	# essaie de valider la saisie en cours (si besoin)
	if {[Table::validate:entry $gui(w:init:couples)] == 0} {
		event:couples:error help:couples:error
		return
	}

	# vérifie le format du presse-papier
	set usedNb {}
	if {[catch {set data [split [selection get -selection CLIPBOARD] "\n"]}]} {
		event:couples:error help:couples:paste1
		return
	}
#TRACE "<from clip>-------------------------------------------------------------------"
#TRACE "<from clip> selection = '$data'"
	# regarde si la liste est dans un état par défaut : on supprime le "faux" couple 1
	if {$event(couples) == "1" && $event(name:1) == "" && $event(school:1) == ""} {
		set event(couples) {}
		unset event(name:1)
		unset event(school:1)
	}
	# cherche les conflits
	foreach row $data {
		set nb [lindex $row 0]
		if {$nb == ""} {
			continue
		}
#TRACE "<from clip> checking $nb"
		if {[lsearch $usedNb $nb] != -1} {
			event:couples:error help:couples:paste2
			return
		}
		if {[lsearch $event(couples) $nb] != -1} {
#TRACE "<from clip> event(couples) = $event(couples)"
			event:couples:error help:couples:paste3
			return
		}
		lappend usedNb $nb
	}
#TRACE "<from clip> data OK"

	# réinitialise la liste
	foreach row $data {
		set row [split $row "\t"]
		set couple [lindex $row 0]
		if {$couple == ""} {
			continue
		}
		set name [lindex $row 1]
		set school [lindex $row 2]
#TRACE "<from clip> setting $couple / '$name' / '$school'"
		lappend event(couples) $couple
		set event(name:$couple) $name
		set event(school:$couple) $school
	}

	# données modifiées
	set gui(v:modified) 1
	# mise-à-jour affichage
	event:couples:display
}

proc skating::event:couples:clear&fromClipboard {} {
	if {[event:couples:removeall] < 0} {
		return
	}
	event:couples:fromClipboard
}

proc skating::event:couples:quickCreate {{force 0}} {
variable event
global msg

	# suppression des couples
	if {!$force} {
		for {set couple $::quickCouplesFrom} {$couple <= $::quickCouplesTo} {incr couple} {
			if {[lsearch $event(couples) $couple] != -1} {
				if {[event:couples:remove $couple] < 0} {
					return
				}
			}
		}
#		set event(couples) {}
#		catch { unset event(name:1) }
#		catch { unset event(school:1) }
	}
	# insertion des N couples
	for {set couple $::quickCouplesFrom} {$couple <= $::quickCouplesTo} {incr couple} {
		lappend event(couples) $couple
		set event(name:$couple) "$msg(Couple) $couple"
		set event(school:$couple) ""
	}

	# données modifiées
	set gui(v:modified) 1
	# mise-à-jour affichage
	if {!$force} {
		event:couples:display
	}
}

#----------------------------------------------------------------------------------------------

proc skating::event:couples:buttons:display {row couple} {
global msg
variable gui
variable event

#TRACEF

	set table $gui(w:init:couples)
	set alias [expr {$couple != [expr {int($couple)}]}]
	# affiche les boites
	for {set i 0} {$i < $gui(t:init:couples:total)} {incr i} {
		set f $gui(t:init:couples:$i)
		# définit le type de bouton
		variable $f
		upvar 0 $f folder
		if {$alias && ($folder(mode) == "ten" || [string first "." $f] != -1)} {
			# c'est un alias en mode 10-danses = interdit
			if {$folder(mode) == "ten"} {
				Table::buttons:setStyle $table $row $i BUTTON_DISABLED
			} else {
				Table::buttons:setStyle $table $row $i DISABLED
			}

		} else {
			# cherche si couple inscrit pour compétition
			if {$folder(mode) == "ten"} {
				Table::buttons:setStyle $table $row $i BUTTON
			} else {
				if {[lsearch $folder(couples:names) $couple] == -1} {
					Table::buttons:setStyle $table $row $i OFF
				} else {
					Table::buttons:setStyle $table $row $i ON
				}
			}
		}
	}
}

proc skating::event:couples:buttons:handle {action couple row button} {
variable gui
global msg

#TRACEF "[$gui(w:init:couples) get $row,[expr {3+$button}]]"

	if {$action != "space"} {
		return
	}
	# si button interdit, retour
	if {[$gui(w:init:couples) get $row,[expr {3+$button}]] == "---"} {
		bell
#TRACE "returning"
		return
	}

	# bloque certains rafraichissement graphiques
	set gui(v:inEvent) 1

	set f $gui(t:init:couples:$button)
	variable $f
	upvar 0 $f folder

	if {$folder(mode) == "ten"} {
#TRACE "ten mode"
		set table $gui(w:init:couples)
		set bb [expr {$button+1}]
		foreach dance $folder(dances) {
			variable $f.$dance
			upvar 0 $f.$dance Dfolder
			set gui(v:folder) $f.$dance
			set gui(v:dance) $dance

			if {[manage:couples:isSelected $couple]} {
				incr bb
				continue
			}

			if {[manage:couples:toggle $couple 0] < 0} {
				incr bb
				continue
			}
			# mise à jour affichage
			switch [Table::buttons:getStyle $table $row $bb] {
				ON		{ Table::buttons:setStyle $table $row $bb OFF }
				OFF		{ Table::buttons:setStyle $table $row $bb ON }
			}
			incr bb
		}
		set gui(v:folder) ""
		set gui(v:dance) ""

	} else {
#TRACE "toggle one dance for $f"
		# ajuste les données
		set gui(v:folder) $f
		if {[manage:couples:toggle $couple 0] < 0} {
			set gui(v:folder) ""
		} else {
			set gui(v:folder) ""
			# mise à jour affichage
			set table $gui(w:init:couples)
			switch [Table::buttons:getStyle $table $row $button] {
				ON		{ Table::buttons:setStyle $table $row $button OFF }
				OFF		{ Table::buttons:setStyle $table $row $button ON }
			}
		}
	}

	# débloque certains rafraichissement graphiques
	set gui(v:inEvent) 0
}

proc skating::event:couples:buttons:tip {button data} {
variable gui
variable event

	set f $gui(t:init:couples:$button)
	variable $f
	upvar 0 $f folder
	if {[string first "." $f] == -1} {
		set result $folder(label)
	} else {
		set result "$folder(label) ([lindex $folder(dances) 0])"
	}

	if {$gui(pref:tip:name)} {
		catch { append result "\n$event(name:$data)" }
	}

	catch {
		if {[set start [manage:couples:startRound:get $f $data 1]] != ""} {
			append result "\n\n$::msg(startIn) $folder(round:$start:name)"
		}
	}

	return $result
}

#----------------------------------------------------------------------------------------------

proc skating::event:couples:completion {list stem col} {
variable gui
variable db
global msg

#TRACEF

	if {!$gui(pref:completion:couples) || $col == 0} {
		# pas de complétion sur le numéro du couple
		return 0
	}
	$list delete 0 end
	set items {}
	if {$col == 1} {
		set what couples
	} else {
		set what schools
	}
	foreach item $db($what) {
		if {[string match -nocase "$stem*" $item]} {
			lappend items $item
		}
	}
	set last ""
	foreach item [lsort -dictionary $items] {
		if {$item == $last} {
			continue
		}
		$list insert end $item
		set last $item
	}

	return 1
}

#----------------------------------------------------------------------------------------------

proc skating::event:couples:error {ref} {
variable gui
global msg

	set text $gui(w:init:couples:help)
	$text delete 1.0 end
	$text insert 1.0 $msg($ref) red
	after 2000 "$text delete 1.0 end; $text insert 1.0 $msg(help:couples:edit)"
	bell
}



#==============================================================================================
#
#	Dialogue pour le tri alphabétique pour l'attribution des dossard
#
#==============================================================================================


proc skating::event:couples:grouping:dialog {} {
variable event
variable gui
global msg


	# boite de dialogue modale
	set w .dialog
	destroy $w
	toplevel $w -class Dialog
	wm title $w $msg(dlg:editgroups)
	wm iconname $w Dialog
	wm protocol $w WM_DELETE_WINDOW { }
	wm transient $w
	wm geometry $w 600x500

	#------------------
	# la liste des noms
	set data [list ]
	foreach couple $event(couples) {
		if {$couple != int($couple)} {
			destroy $w
			bell
			return
		}
		lappend data [list $event(name:$couple) $event(school:$couple) $couple]
		set mappingOld($event(name:$couple)) $couple
	}
	set data [lsort -dictionary -index 0 $data]
	foreach item $data {
		lappend names [lindex $item 0]
		lappend schools [lindex $item 1]
		lappend couples [lindex $item 2]
	}


	#------------------------------------------
	# la table utilisée comme zone de sélection
	set sw [ScrolledWindow::create $w.sw \
				-scrollbar both -auto both -relief sunken -borderwidth 1]
	if {[info exists ::groups]} {
		# efface données résiduelles
		unset ::groups
	}
	set table [table $w.t -bordercursor sb_h_double_arrow -variable ::groups \
			-highlightthickness 0 -cursor {} \
			-borderwidth 1 -bg gray95 \
			-resizeborders col \
			-width 6 -height 0 -maxheight 50 -maxwidth 50 \
			-titlerows 1 -titlecols 0 -roworigin 0 \
			-colstretchmode none -rowstretchmode none \
			-selectmode extended \
			-yscrollcommand {.sy set} -xscrollcommand {.sx set}]
	ScrolledWindow::setwidget $sw $table

	$table tag configure title -relief raised -bd 1 -bg [. cget -bg] -fg black -font {bold} \
							   -state normal -anchor c
	$table tag configure sel -bg $gui(color:selection) -fg $gui(color:selectionFG)
	$table tag configure ON -bg $gui(color:selection)
	$table tag configure OFF -bg gray95
	$table tag configure left -anchor w
	$table tag configure center -anchor c
	$table tag raise left

	# paramétrage de la table
	$table configure -cols 12 -rows [expr {[llength $event(couples)]+1}]
	$table set row 0,0 {10 100 200 300 400 500 600 700 800 900}
	$table configure -titlecols 2 -colorigin -2
	$table set col 1,-2 $names
	$table tag col left -2
	$table width -2 35
	$table set col 1,-1 $schools
	$table tag col left -1
	$table width -1 20
	set row 1
	foreach couple $couples {
		set col [expr {int($couple/100)}]
		$table tag cell ON $row,$col
		incr row
	}

	for {set i 0} {$i<=9} {incr i} {
		$table width $i 6
	}

	# bindings
	bindtags $table "$table Groups all"

	# boutons
	set f [frame $w.b -relief raised -bd 1]
	button $f.ok -bd 1 -default active -width 10 -text $msg(dlg:ok) -under 0 \
			-command "set tkPriv(button) ok"
	button $f.cancel -bd 1 -width 10 -text $msg(dlg:cancel) -under 0 \
			-command "set tkPriv(button) cancel"
	pack $f.ok $f.cancel -side left -expand true -padx 3m -pady 2m

	# aide
	text $w.h -font tips -height 2 -relief flat -bg [$w cget -background] -tabs {125}
	$w.h tag configure blue -foreground darkblue
	$w.h tag configure red -foreground red
	bindtags $w.h "$w.h all"
	eval $w.h insert 1.0 $msg(help:couples:groups)

	# mise en page
	pack $sw -side top -expand true -fill both
	pack $w.h -side top -fill x -pady 5
	pack $f -side top -fill x

	# OK pour boite modale
	centerDialog .top $w 600 500
	tkwait visibility $w
	set oldFocus [focus]
	set oldGrab [grab current $w]
	if {$oldGrab != ""} {
		set grabStatus [grab status $oldGrab]
	}
	grab $w
	global tkPriv
	tkwait variable tkPriv(button)
	catch {focus $oldFocus}
	if {$oldGrab != ""} {
		if {$grabStatus == "global"} {
			grab -global $oldGrab
		} else {
			grab $oldGrab
		}
	}

	# process le résultat
	set modified 0
	if {$tkPriv(button) == "ok"} {
		# reset les groupes
		foreach j {0 1 2 3 4 5 6 7 8 9} {
			set group($j) [list ]
		}
		# forme les nouveaux sous-groupes
		set row 1
		foreach dummy $event(couples) {
			foreach j {0 1 2 3 4 5 6 7 8 9} {
				if {[$table tag includes ON $row,$j]} {
					lappend group($j) $::groups($row,-2)
					break
				}
			}
			incr row
		}
		# tri par ordre alphabétique
		foreach j {0 1 2 3 4 5 6 7 8 9} {
			set group($j) [lsort -dictionary $group($j)]
#TRACE "group $j = $group($j)"
		}
		# calcule le nouveau mapping
		foreach j {0 1 2 3 4 5 6 7 8 9} {
			set nb [expr {$j*100+1 + ($j==0 ? 10 : 0)}]
			foreach name $group($j) {
				set mappingNew($name) $nb
				incr nb
			}
		}

		# effectue les changements
		foreach name $names {
			if {$mappingOld($name) != $mappingNew($name)} {
				# pour tous les couples qui ont changés de numéro,
				# on les place en 10000++ (pas de conflit)
				event:couples:swap $mappingOld($name) [expr {$mappingOld($name)+10000}]
			}
		}
		foreach name $names {
#puts "[format {%-50s%3d --> %3d} $name $mappingOld($name) $mappingNew($name)]"
			if {$mappingOld($name) != $mappingNew($name)} {
				# on replace les couples à leur "nouvelle" place
				event:couples:swap [expr {$mappingOld($name)+10000}] $mappingNew($name)
				set modified 1
			}
		}
	}

	# destruction de la fenêtre
	destroy $w

	# réaffichage des couples
	if {$modified} {
		event:couples:display
	}
}


set tkPriv(tkTableCurrent) 0,0

#---- Button-1 press & release
bind Groups <ButtonPress-1> {
	focus %W
	set col [%W border mark %x %y]
	if {$col != ""} {
		set tkPriv(tkTableMode) "resize"
	} else {
		set tkPriv(tkTableMode) "select"
	}
}
bind Groups <Shift-ButtonPress-1> {
	set col [%W border mark %x %y]
	if {$col != ""} {
		set tkPriv(tkTableMode) "resize-all"
		set tkPriv(tkTableCol) [lindex $col 1]
	} else {
		set tkPriv(tkTableMode) "select"
	}
}
bind Groups <B1-Motion> {
	if {$tkPriv(tkTableMode) == "resize"} {
		%W border dragto %x %y
	} elseif {$tkPriv(tkTableMode) == "resize-all"} {
		%W border dragto %x %y
		set w [%W width $tkPriv(tkTableCol)]
		foreach item [%W width] {
			foreach {col width} $item break;
			if {$col >= 0} {
				%W width $col $w
			}
		}

	}
}

bind Groups <ButtonRelease-1> {
	if {$tkPriv(tkTableMode) != "resize"} {
		set row [%W index @%x,%y row]
		set col [%W index @%x,%y col]
		if {$col >= 0 && $row > 0} {
			foreach i {0 1 2 3 4 5 6 7 8 9} {
				%W tag cell OFF $row,$i
			}
			%W tag cell ON $row,$col
		}
	}	
}


bind Groups <MouseWheel> { %W yview scroll [expr {- (%D / 120) * 4}] units }
if {[string equal "unix" $tcl_platform(platform)]} {
    bind Groups <4> { if {!$tk_strictMotif} { %W yview scroll -5 units } }
    bind Groups <5> { if {!$tk_strictMotif} { %W yview scroll 5 units } }
}
