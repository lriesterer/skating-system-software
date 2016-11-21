##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion de la liste des juges
#
#=================================================================================================

proc skating::event:judges:init {w} {
variable gui

	set gui(w:tab:judges) $w
	set gui(v:tab:judges:pendingReinit) 0
	event:judges:reinit
	# give focus
	focus $gui(w:init:judges)
}

proc skating::event:judges:refresh {} {
variable gui

TRACEF "pending = $gui(v:tab:judges:pendingReinit)"

	if {$gui(v:tab:judges:pendingReinit)} {
		event:judges:reinit
		set gui(v:tab:judges:pendingReinit) 0
	}
}

proc skating::event:judges:reinit {} {
global msg
variable gui
variable event

	# récupère la widget pour l'onglet & détruit anciennes widget
	set w $gui(w:tab:judges)
	foreach child [winfo children $w] {
		destroy $child
	}

	# calcule le nombre de compétitions
	set buttons 0
	foreach f $event(folders) {
		set gui(t:init:judges:$buttons) $f
		incr buttons
		# un pour chaque danse en mode 10-danses
		if {!$gui(pref:judges:button:compact)} {
			variable $f
			upvar 0 $f folder
			if {$folder(mode) == "ten"} {
				foreach d $folder(dances) {
					set gui(t:init:judges:$buttons) $f.$d
					incr buttons
				}
			}
		}
	}
	set gui(t:init:judges:total) $buttons

	# table principale
	set sw [ScrolledWindow::create $w.sw \
				-scrollbar both -auto both -relief sunken -borderwidth 1]
	set table [Table::create $w.t 2 1 0 .popJudges {^([A-Z]?|[A-Z][A-Z0-9]?)$} \
					$buttons \
						skating::event:judges:buttons:display \
						skating::event:judges:buttons:handle \
						skating::event:judges:buttons:tip \
					skating::event:judges:getIndex \
					skating::event:judges:validateIndex \
					skating::event:judges:modify \
					skating::event:judges:completion \
					skating::event:judges:canDeleteIndex]
	set gui(w:init:judges) $table
	set Table::data($table:upperCaseInColumn0) 1
	ScrolledWindow::setwidget $sw $table
	# fin paramétrage de la table
	$table set row 0,0 [list $msg(letter) $msg(name)]
	if {$::tcl_platform(platform) == "windows"} {
		$table width -1 5 0 5 1 54
	} else {
		$table width -1 5 0 5 1 60
	}
	# popup menu pour la table
	if {![winfo exists .popJudges]} {
		set m [menu .popJudges -tearoff 0 -bd 1]
			regsub -all -- {\n} $msg(insert:before) { } label
			$m add command -label $label -command {Table::insert:before $tkPriv(tkCurrentTable)}
			regsub -all -- {\n} $msg(insert:after) { } label
			$m add command -label $label -command {Table::insert:after $tkPriv(tkCurrentTable)}
			$m add separator
			$m add command -label $msg(remove) -command {skating::event:couples:remove}
	}

	# help
	text $w.h -font tips -height 2 -relief flat -bg [$w cget -background] -tabs {125}
	set gui(w:init:judges:help) $w.h
	$w.h tag configure blue -foreground darkblue
	$w.h tag configure red -foreground red
	bindtags $w.h "$w.h all"
	eval $w.h insert 1.0 $msg(help:judges:edit)

	# boutons
	set but2 [frame $w.b2]
	  set gui(w:init:judges:buttons) $but2
	  button $but2.remove -text $msg(remove) -bd 1 -command "skating::event:judges:remove"
	  button $but2.removeall -text $msg(removeall) -bd 1 -command "skating::event:judges:removeall"
	  button $but2.insb -text $msg(insert:before) -bd 1 -command "Table::insert:before $table"
	  button $but2.insa -text $msg(insert:after) -bd 1 -command "Table::insert:after $table"
	  button $but2.sort -text $msg(redisplay2) -bd 1 -command "skating::event:judges:redisplay"
	  button $but2.toclip -text $msg(toclip) -bd 1 -command "skating::event:judges:toClipboard $table"
	  button $but2.fromclip -text $msg(fromclip) -bd 1 -command "skating::event:judges:fromClipboard"
	  button $but2.fromclip2 -text $msg(fromclip2) -bd 1 -command "skating::event:judges:clear&fromClipboard"
	  SpinBox::create $but2.spin -labelwidth 5 -label "Nb" -range {1 500 1} \
				-width 4 -entrybg gray95 -textvariable ::quickJudges \
				-selectbackground $gui(color:selection)
		set ::quickJudges 5
	  button $but2.quick -text $msg(create) -bd 1 -command "skating::event:judges:quickCreate"
	  #----
	  pack $but2.remove $but2.removeall -fill x -pady 2
	  pack [frame $but2.sep1 -height 20]
	  pack $but2.insb $but2.insa -fill x -pady 2
	  pack [frame $but2.sep2 -height 20]
	  pack $but2.sort -fill x
	  pack [frame $but2.sep3 -height 35]
	  pack $but2.toclip $but2.fromclip $but2.fromclip2 -fill x -pady 2
	  pack [frame $but2.sep4 -height 35]
	  pack $but2.spin $but2.quick -fill x -pady 2

	# mise en page
	pack $w.h -side bottom -fill x
	pack $sw -side left -expand true -fill both
	pack [frame $w.sep2 -width 10] -side left
	pack $w.b2 -side right -fill y

	# inits
	after idle "skating::event:judges:display"
}

#-------------------------------------------------------------------------------------------------

proc skating::event:judges:display {} {
global msg
variable gui
variable event

#TRACEF "'$event(judges)'"

	if {[info exists event(judges)] && [llength $event(judges)]} {
		# insert les juges
		$gui(w:init:judges) configure -rows [expr [llength $event(judges)]+1]
		set i 1
		foreach judge $event(judges) {
			$gui(w:init:judges) set row $i,-1 [list $judge $judge $event(name:$judge)]
			incr i
		}
		Table::select $gui(w:init:judges) "1,0"
	} else {
		# insert un premier couple par défaut
		set event(judges) {A}
		set event(name:A) ""
		$gui(w:init:judges) configure -rows 2
		$gui(w:init:judges) set row 1,0 [list "A" ""]
		Table::setValue $gui(w:init:judges) 1,-1 "A"
		Table::activate $gui(w:init:judges) "1,0"
	}

	# les boutons de sélection rapide
#set c [clock clicks -milliseconds]

	set last ""
	set number 0
	set table $gui(w:init:judges)
	set empty [string repeat "$msg(no) " [llength $event(judges)]]
	set emptyBut [string repeat "$msg(all) " [llength $event(judges)]]
	for {set i 0} {$i < $gui(t:init:judges:total)} {incr i} {
		set col [expr {2+$i}]
		$table width $col 5
		set f $gui(t:init:judges:$i)
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
		if {$folder(mode) != "ten" || $gui(pref:judges:button:compact)} {
			$table set col 1,$col "$empty"
			$table tag col OFF $col
		} else {
			$table set col 1,$col "$emptyBut"
			$table tag col BUTTON $col
		}
	}
#set cc [clock clicks -milliseconds]; TRACE "[expr $cc-$c]"

	# contenu pour chaque juge - affiche "oui/non"
	for {set i 0} {$i < $gui(t:init:judges:total)} {incr i} {
		set f $gui(t:init:judges:$i)
		# définit le type de bouton
		variable $f
		upvar 0 $f folder
		# itère pour chaque juge par compétition
		set row 1
		foreach judge $event(judges) {
			if {$folder(mode) != "ten" || $gui(pref:judges:button:compact)} {
				set state [manage:judges:isSelected $f $judge]
				if {$state != "OFF"} {
					Table::buttons:setStyle $table $row $i $state
				}
			}
			# juge suivant
			incr row
		}
	}
#set ccc [clock clicks -milliseconds]; TRACE "[expr $ccc-$cc]  //  [expr $ccc-$c]"
}

proc skating::event:judges:redisplay {} {
variable gui
variable event

	# essaie de valider la saisie en cours (si besoin)
	if {[Table::validate:entry $gui(w:init:judges)] == 0} {
		return
	}
	# réaffichage
	event:judges:display
}

#-------------------------------------------------------------------------------------------------

proc skating::event:judges:getIndex {letter1 letter2 {lastrow ""}} {
variable event

#TRACE

	if {[event:judges:sort $letter2 [event:judges:nextLetter $letter1]] == 1} {
		set letter [event:judges:nextLetter $letter1]
	} elseif {$lastrow != ""} {
		set letter [event:judges:nextLetter $lastrow]
	} else {
		set letter ""
	}

	if {[lsearch $event(judges) $letter] != -1 || $letter == ""} {
		if {$lastrow != ""} {
			bell
			bell
		}
		set letter [event:judges:nextLetter [lindex $event(judges) end]]
	}
	set letter
}

proc skating::event:judges:validateIndex {letter} {
global msg
variable event

#puts "validating '$letter' / [lsearch $event(judges) $letter] / $event(judges)"
	set valid [expr {[lsearch $event(judges) $letter] == -1}]
	if {!$valid} {
		event:judges:error help:judges:error
    }
	# return result
	set valid
}

proc skating::event:judges:canDeleteIndex {{letter "_"}} {
variable event

	expr {[lsearch $event(judges) $letter] == -1}
}

#-------------------------------------------------------------------------------------------------

proc skating::event:judges:modify {row column judge oldJudge data} {
global msg
variable event
variable gui

#TRACEF
	if {$oldJudge != 0} {
		if {$column != 0} {
			return -code error "oldJudge set but column=$column"
		}
		# modification du numéro d'un juge
#TRACE "changing judge '$oldJudge' to '$judge'"
		set idx [lsearch $event(judges) $oldJudge]
		set event(judges) [lreplace $event(judges) $idx $idx $judge]
		# change données sur le juge
		set event(name:$judge) $event(name:$oldJudge)
		unset event(name:$oldJudge)
		event:judges:setMode
		#------------------------------------
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
				# mise-à-jour dans juges sélectionnés
				foreach name [array names folder judges:*] {
					set idx [lsearch $folder($name) $oldJudge]
#TRACE "    -- searching $oldJudge in '$folder($name)'/$name = $idx"
					if {$idx != -1} {
						set folder($name) [lreplace $folder($name) $idx $idx $judge]
#TRACE "    -- $folder(label) -- judges: $name --> $folder($name)"
					}
				}
				# les notes du judge restent valides car l'index dans la liste est
				# conservé
			}
		}	
		# change numéro dans les panels
		foreach panel $event(panels) {
			set idx [lsearch $event(panel:judges:$panel) $oldJudge]
			if {$idx != -1} {
				set event(panel:judges:$panel) [lreplace \
							$event(panel:judges:$panel) $idx $idx $judge]
			}
		}

		# mise à jour header
		Table::setValue $gui(w:init:judges) $row,-1 $judge

	} else {
		if {$column == 0} {
			# création d'un nouveau judge
#puts "    creating judge '$judge'"
			lappend event(judges) $judge
			set event(name:$judge) ""
			event:judges:setMode

			# mise à jour header
			Table::setValue $gui(w:init:judges) $row,-1 $judge

			# les panels doivent être réaffichés
			set gui(v:tab:panels:pendingReinit) 1

		} elseif {$column == 1} {
			# modification du nom
#puts "    updating name:'$judge'"
			variable db
			set idx [lsearch -exact $db(judges) $event(name:$judge)]
			# remplace ou ajoute en début de liste
			set db(judges) [lreplace $db(judges) $idx $idx $data]
			set gui(v:db:modified) 1

			set event(name:$judge) $data

		}
	}

	# modifications ...
	set gui(v:modified) 1
	return 1
}

#-------------------------------------------------------------------------------------------------

proc skating::event:judges:isUsed {judge} {
variable event

	# test si le juge est utilisé
	set use {}
	foreach f $event(folders) {
		variable $f
		upvar 0 $f folder
		# vérifie si le juge est sélectionné pour un round
		foreach name [array names folder judges:*] {
			if {[lsearch $folder($name) $judge] != -1} {
				lappend use $folder(label)
				break
			}
		}
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
		return $text
	}

	return ""
}

proc skating::event:judges:remove {{judge ""}} {
global msg
variable gui
variable event

#puts "skating::event:judges:remove {$judge}"
	# test si un juge est sélectionné
	if {$judge == ""} {
		set judge [Table::get:currentIndex $gui(w:init:judges)]
		if {$judge == ""} {
			bell
			return -1
		}
	}
	# suppression d'un juge
	set usedIn [event:judges:isUsed $judge]
	if {$usedIn != ""} {
		tk_messageBox -icon "warning" -type ok -default ok \
				-title $msg(dlg:information) -message "$msg(dlg:judgeUsed)\n$usedIn"
		return -1
	}
	# suppression du juge
	catch { unset event(name:$judge) }
	set idx [lsearch $event(judges) $judge]
	set event(judges) [lreplace $event(judges) $idx $idx]
	# mise à jour des panels
	foreach panel $event(panels) {
		set idx [lsearch $event(panel:judges:$panel) $judge]
		if {$idx != -1} {
			set event(panel:judges:$panel) [lreplace $event(panel:judges:$panel) $idx $idx]
		}
	}

	# mise-à-jour affichage
	Table::deleteCurrent $gui(w:init:judges)

	return 0
}

proc skating::event:judges:removeall {} {
variable event

	foreach judge $event(judges) {
		if {[event:judges:remove $judge] < 0} {
			return -1
		}
	}
	# réaffichage avec insertion d'un premier juge par défaut
	event:judges:display
	return 0
}

#-------------------------------------------------------------------------------------------------

proc skating::event:judges:toClipboard {table} {
variable gui
variable event
global msg

	# essaie de valider la saisie en cours (si besoin)
	if {[Table::validate:entry $gui(w:init:judges)] == 0} {
		event:judges:error help:judges:error
		return
	}

	# on possède la sélection
	clipboard clear -displayof $table
	foreach judge $event(judges) {
	    clipboard append -displayof $table "$judge\t$event(name:$judge)\n"
	}
#TRACE "<to clipboard>"
}

proc skating::event:judges:fromClipboard {} {
variable gui
variable event

	# essaie de valider la saisie en cours (si besoin)
	if {[Table::validate:entry $gui(w:init:judges)] == 0} {
		event:judges:error help:judges:error
		return
	}

	# vérifie le format du presse-papier
	set usedLetter {}
	if {[catch {set data [split [selection get -selection CLIPBOARD] "\n"]}]} {
		event:judges:error help:judges:paste1
		return
	}
#TRACE "<from clip>-------------------------------------------------------------------"
#TRACE "<from clip> selection = '$data'"
	# regarde si la liste est dans un état par défaut : on supprime le "faux" juge A
	if {$event(judges) == "A" && $event(name:A) == ""} {
		set event(judges) {}
		unset event(name:A)
	}
	# cherche les conflits
	foreach row $data {
		set letter [string toupper [string trim [lindex $row 0]]]
		if {$letter == ""} {
			continue
		}
#TRACE "<from clip> checking $letter"
		if {[regexp {^[A-Z][A-Z0-9]?$} $letter] != 1} {
			event:judges:error help:judges:paste4
			return
		}
		if {[lsearch $usedLetter $letter] != -1} {
			event:judges:error help:judges:paste2
			return
		}
		if {[lsearch $event(judges) $letter] != -1} {
#TRACE "<from clip> event(judges) = $event(judges)"
			event:judges:error help:judges:paste3
			return
		}
		lappend usedLetter $letter
	}
#TRACE "<from clip> data OK"

	# réinitialise la liste
	foreach row $data {
		set row [split $row "\t"]
		set judge [string toupper [string trim [lindex $row 0]]]
		if {$judge == ""} {
			continue
		}
		set name [lindex $row 1]
#TRACE "<from clip> setting $judge / '$name'"
		lappend event(judges) $judge
		set event(name:$judge) $name
	}
	event:judges:setMode

	# données modifiées
	set gui(v:modified) 1
	# mise-à-jour affichage
	event:judges:display
}

proc skating::event:judges:clear&fromClipboard {} {
	if {[event:judges:removeall] < 0} {
		return
	}
	event:judges:fromClipboard
}

proc skating::event:judges:quickCreate {{force 0}} {
variable gui
variable event
global msg

	# suppression des judges
	if {!$force && [event:judges:removeall] < 0} {
		return
	}
	# insertion des N judges
	set letter "A"
	set event(judges) [list ]
	for {set judge 1} {$judge <= $::quickJudges} {incr judge} {
		lappend event(judges) $letter
		set event(name:$letter) "$msg(judge) $letter"
		set letter [event:judges:nextLetter $letter]
	}
	event:judges:setMode

	# données modifiées
	set gui(v:modified) 1
	# mise-à-jour affichage
	if {!$force} {
		event:judges:display
	}

	# les panels doivent être réaffichés
	set gui(v:tab:panels:pendingReinit) 1
}

#----------------------------------------------------------------------------------------------

proc skating::event:judges:buttons:display {row judge} {
global msg
variable gui
variable event

	set table $gui(w:init:judges)
	# affiche les boites
	for {set i 0} {$i < $gui(t:init:judges:total)} {incr i} {
		set f $gui(t:init:judges:$i)
		# cherche si couple inscrit pour compétition
		variable $f
		upvar 0 $f folder
		if {$folder(mode) == "ten"} {
TRACEF
			if {$gui(pref:judges:button:compact)} {
				Table::buttons:setStyle $table $row $i \
										[manage:judges:isSelected $f $judge]
			} else {
				Table::buttons:setStyle $table $row $i BUTTON
			}
		} else {
			Table::buttons:setStyle $table $row $i [manage:judges:isSelected $f $judge]
		}
	}
}

proc skating::event:judges:buttons:handle {action judge row button} {
variable gui
global msg

#TRACEF

	if {$action != "space"} {
		return
	}

	set f $gui(t:init:judges:$button)
	variable $f
	upvar 0 $f folder

	# bloque certains rafraichissement graphiques
	set gui(v:inEvent) 1

	# distingue le cas 10/normal
	if {$folder(mode) == "ten"} {
#TRACE "ten mode"
		set table $gui(w:init:judges)

		# avec les boutons compacts, trouve the mode
		set mode 1
		if {$gui(pref:judges:button:compact)} {
			if {[manage:judges:isSelected $f $judge] == "ON"} {
				set mode 0
			}
		}

		set bb [expr {$button+1}]
		foreach dance $folder(dances) {
			variable $f.$dance
			upvar 0 $f.$dance Dfolder
			set gui(v:folder) $f.$dance
			set gui(v:dance) $dance

			manage:judges:toggleJudge $f.$dance $judge ALL 0 $mode
			# mise à jour affichage
			if {!$gui(pref:judges:button:compact)} {
				Table::buttons:setStyle $table $row $bb ON
				incr bb
			}
		}
		# mise à jour affichage
		if {$gui(pref:judges:button:compact)} {
			if {$mode == 0} {
				Table::buttons:setStyle $table $row $button OFF
			} else {
				Table::buttons:setStyle $table $row $button ON
			}
		}

		set gui(v:dance) ""
		set gui(v:folder) ""

	} else {
#TRACE "toggle one dance for $f"
		# ajuste les données & mise à jour affichage
		set table $gui(w:init:judges)
		set gui(v:folder) $f
		switch [Table::buttons:getStyle $table $row $button] {
			ON	{	Table::buttons:setStyle $table $row $button OFF 
		  			manage:judges:toggleJudge $f $judge ALL 0 0 }
			OFF	{ 	Table::buttons:setStyle $table $row $button ON 
		  			manage:judges:toggleJudge $f $judge ALL 0 1	}
		}
		set gui(v:folder) ""
	}

	# débloque certains rafraichissement graphiques
	set gui(v:inEvent) 0
}

proc skating::event:judges:buttons:tip {button data} {
variable gui
variable event

	set f $gui(t:init:judges:$button)
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

	return $result
}

#----------------------------------------------------------------------------------------------

proc skating::event:judges:completion {list stem col} {
variable gui
variable db
global msg

#puts "skating::event:judges:completion $list '$stem' $col"
	if {!$gui(pref:completion:judges) || $col == 0} {
		# pas de complétion sur la lettre du juge
		return 0
	}
	$list delete 0 end
	set items {}
	foreach item $db(judges) {
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

proc skating::event:judges:error {ref} {
variable gui
global msg

	set text $gui(w:init:judges:help)
	$text delete 1.0 end
	$text insert 1.0 $msg($ref) red
	after 2000 "$text delete 1.0 end; $text insert 1.0 $msg(help:judges:edit)"
	bell
}

#==============================================================================================

proc skating::event:judges:setMode {} {
global judgesLongMode
variable event

	# tri des noms des juges
	set event(judges) [lsort -command skating::event:judges:sort $event(judges)]
#puts "skating::event:judges:setMode / '$event(judges)'"

	# teste si des juges ont des noms de plus de 1 lettre
	foreach judge $event(judges) {
		if {[string length $judge] > 1} {
			set judgesLongMode 1
			return
		}
	}
	set judgesLongMode 0
}

proc skating::event:judges:sort {a b} {
	# tri alphabétique mais juge sur une lettre d'abord
	if {[string length $a] == [string length $b]} {
		return [string compare $a $b]
	} elseif {[string length $a] == 1} {
		return -1
	} else {
		return 1
	}
}


set mapping {A B B C C D D E E F F G G H H I I J J K K L L M M N N O O P P Q Q R R S S T T U U V V W W X X Y Y Z Z _
			 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 _}
proc skating::event:judges:nextLetter {a} {
	set a1 [string map $::mapping [string index $a 0]]
	set a2 [string map $::mapping [string index $a 1]]
	if {$a2 == ""} {
		if {$a1 == "_"} {
			return AA
		} else {
			set a1
		}
	} else {
		if {[regexp {[0-9]} [string index $a 1]] == 1} {
			if {$a2 == "_"} {
				return ${a1}1
			} else {
				return [string index $a 0]$a2
			}
		} elseif {$a2 == "_"} {
			if {$a1 == "_"} {
				return ZZ
			} else {
				return ${a1}A
			}
		} else {
			return [string index $a 0]$a2
		}
	}
}
