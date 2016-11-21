##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion des panels de juges
#
#=================================================================================================


proc skating::event:panels:init {w} {
variable gui

	set gui(w:tab:panels) $w
	set gui(v:tab:panels:pendingReinit) 0
	event:panels:reinit
}

proc skating::event:panels:refresh {} {
variable gui

TRACEF "pending = $gui(v:tab:panels:pendingReinit)"

	if {$gui(v:tab:panels:pendingReinit)} {
		event:panels:reinit
		set gui(v:tab:panels:pendingReinit) 0
	}
}

proc skating::event:panels:reinit {} {
global msg
variable gui
variable event


	# récupère la widget pour l'onglet & détruit anciennes widget
	set w $gui(w:tab:panels)
	foreach child [winfo children $w] {
		destroy $child
	}

	# récupère ancienne largueur de colonnes
	set widths [list ]
	if {[info exists gui(w:init:panels)] && [winfo exists $gui(w:init:panels)]} {
		set widths [$gui(w:init:panels) width]
	}

	# une paned window
    set pw [PanedWindow::create $w.pw -side right]
		# en haut, définitions des panels
		set top [PanedWindow::add $pw -weight 1]
		# en bas, affectation des panels aux compétitions
		set bottom [PanedWindow::add $pw -weight 1]
		# layout
		pack $pw -side top -padx 5 -pady 5 -expand true -fill both

	#------------------------------------------
	# la table utilisée comme zone de sélection
	set sw [ScrolledWindow::create $top.sw \
				-scrollbar both -auto both -relief sunken -borderwidth 1]
	if {[info exists ::panels]} {
		# efface données résiduelles
		unset ::panels
	}
	set table [table $w.t -bordercursor sb_h_double_arrow -variable ::panels \
			-highlightthickness 0 -cursor {} \
			-borderwidth 1 -bg gray95 \
			-resizeborders col \
			-width 6 -height 0 -maxheight 50 -maxwidth 50 \
			-titlerows 1 -titlecols 0 -roworigin 0 \
			-colstretchmode none -rowstretchmode none \
			-selectmode extended \
			-yscrollcommand {.sy set} -xscrollcommand {.sx set}]
	set gui(w:init:panels) $table
	$table tag configure ON -bg $::skating::gui(color:selection) -fg $::skating::gui(color:selectionFG)
	$table tag configure OFF -bg gray95 -fg black
	ScrolledWindow::setwidget $sw $table
	# paramétrage de la table
	$table configure -titlecols 1 -colorigin -1 -rows [expr {[llength $event(judges)]+1}]
	$table set col 1,-1 $event(judges)
	$table width -1 3
	for {set i 0} {$i<25} {incr i} {
		$table width $i 20
	}
	foreach item $widths {
		foreach {col width} $item break;
		if {$col >= 0} {
			$table width $col $width
		}
	}

	$table tag configure active -relief raised -bd 1 -bg white -fg black -font {bold}
	$table tag configure title -relief raised -bd 1 -bg [. cget -bg] -fg black -font {bold} \
							   -state normal -anchor c
	$table tag configure sel -bg $gui(color:selection) -fg $gui(color:selectionFG)
	$table tag configure current -bg orange -anchor c
	$table tag cell current $::tkPriv(tkTableCurrent)
	$table tag raise current
	$table tag configure left -anchor w
	$table tag configure center -anchor c
	$table tag configure noedit -state disable
	$table tag cell noedit 0,-1
	$table tag raise noedit

	# bindings
	bindtags $table "$table Panel all"

	# help
	text $w.h -font tips -height 2 -relief flat -bg [$w cget -background] -tabs {125}
	set gui(w:init:panels:help) $w.h
	$w.h tag configure blue -foreground darkblue
	$w.h tag configure red -foreground red
	bindtags $w.h "$w.h all"
	eval $w.h insert 1.0 $msg(help:panels:edit)

	# boutons
	set but2 [frame $w.b2]
	  set gui(w:init:panels:buttons) $but2
	  button $but2.add -text $msg(add:panel) -bd 1 -command "skating::event:panels:add"
	  button $but2.remove -text $msg(remove:panel) -bd 1 -command "skating::event:panels:remove"
	  button $but2.left -image imgLeft -bd 1 -command "skating::event:panels:shift -1"
	  button $but2.right -image imgRight -bd 1 -command "skating::event:panels:shift +1"
	  pack $but2.add [frame $but2.sep1 -width 10] $but2.remove -side left -fill y
	  pack [frame $but2.sep2 -width 30] $but2.left [frame $but2.sep3 -width 5] $but2.right -side left -fill y

	# mise en page
	pack $sw -side top -expand true -fill both
	pack $w.h -side top -fill x
	pack $but2 -side top -fill x

	#----------------------------------------------------------
	# la table utilisée pour affectation panels --> compétition
	# calcule le nombre de compétitions
	set buttons 0
	foreach f $event(folders) {
		set gui(t:init:panels2:$buttons) $f
		incr buttons
		# un pour chaque danse en mode 10-danses
		variable $f
		upvar 0 $f folder
		if {$folder(mode) == "ten"} {
			foreach d $folder(dances) {
				set gui(t:init:panels2:$buttons) $f.$d
				incr buttons
			}
		}
	}
	set gui(t:init:panels2:total) $buttons
	# table principale
	set sw [ScrolledWindow::create $bottom.sw \
				-scrollbar both -auto both -relief sunken -borderwidth 1]
	set table [Table::create $sw.t2 0 0 0 "" {} \
					$buttons \
						skating::event:panels2:buttons:display \
						skating::event:panels2:buttons:handle \
						skating::event:panels2:buttons:tip \
					skating::event:panels2:getIndex \
					skating::event:panels2:validateIndex \
					skating::event:panels2:modify \
					skating::event:panels2:completion \
					skating::event:panels2:canDeleteIndex]
	set gui(w:init:panels2) $table
	ScrolledWindow::setwidget $sw $table
	# fin paramétrage de la table
	$table set row 0,-1 [list [string totitle $msg(panel)]]
	$table width -1 30
	# mise en page
	pack $sw -side top -expand true -fill both

	#---------
	#==== init
	event:panels:display
	$gui(w:init:panels) activate 0,-1
	event:panels2:display
}

#-------------------------------------------------------------------------------------------------

proc skating::event:panels:display {} {
variable event
variable gui

	set t $gui(w:init:panels)

	# construit liste des noms de juges
	set names [list ]
	foreach judge $event(judges) {
		lappend names $event(name:$judge)
	}
	# applique les données
	$t selection clear all
	$t configure -cols [expr [llength $event(panels)]+1]
	set col 0
	foreach panel $event(panels) {
		$t tag col left $col
		$t tag row center 0
		$t set row 0,$col [list $event(panel:name:$panel)]
		$t set col 1,$col $names
		set row 1
		foreach judge $event(judges) {
			if {[lsearch $event(panel:judges:$panel) $judge] == -1} {
				$t tag cell OFF $row,$col
			} else {
				$t tag cell ON $row,$col
			}
			incr row
		}
		incr col
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::event:panels:add {} {
variable event
variable gui

	event:panels:setName

	# cherche un numéro
	set new [expr [lindex [lsort -integer $event(panels)] end]+1]
	lappend event(panels) $new
	# créé les variables
	set event(panel:name:$new) ""
	set event(panel:judges:$new) {}
	# réaffiche
	event:panels:display
	# positionne pour saisie du nom du panel
	set t $gui(w:init:panels)
#puts "skating::event:panels:add >> tag cell {} $::tkPriv(tkTableCurrent)"
	$t tag cell {} $::tkPriv(tkTableCurrent)
	set ::tkPriv(tkTableCurrent) 0,[expr [llength $event(panels)]-1]
#puts "skating::event:panels:add >> tag cell current $::tkPriv(tkTableCurrent)"
	$t tag cell current $::tkPriv(tkTableCurrent)
	$t tag raise current
	$t activate 0,[llength $event(panels)]
	$t see 0,[llength $event(panels)]

	# mise à jour 2ème table
	event:panels2:display
}

proc skating::event:panels:remove {} {
variable event
variable gui
global msg

	# cherche le panel associé
	set t $gui(w:init:panels)
	set index [$t index $::tkPriv(tkTableCurrent) col]
	set panel [lindex $event(panels) $index]
	# demande confirmation si le panel contient des juges
	if {[llength $event(panel:judges:$panel)]} {
		set text "$msg(dlg:removePanel) '$event(panel:name:$panel)' ?"
		set doit [tk_messageBox -icon "question" -type yesno -default yes \
							-title $msg(dlg:question) -message $text]
		if {$doit != "yes"} {
			return
		}
	}
	# OK --> envèle le panel
	set event(panels) [lreplace $event(panels) $index $index]
	# mise à jour affichage
	$t tag cell {} $::tkPriv(tkTableCurrent)
	$t activate "0,-1"
	set ::tkPriv(tkTableCurrent) "0,0"
	$t tag cell current "0,0"
	$t tag raise current
	event:panels:display

	# mise à jour 2ème table
	event:panels2:display
}

#-------------------------------------------------------------------------------------------------

proc skating::event:panels:shift {dir} {
variable event
variable gui

	# cherche le panel associé
	set t $gui(w:init:panels)
	set index [$t index $::tkPriv(tkTableCurrent) col]
	set max [expr [llength $event(panels)]-1]
	set panel [lindex $event(panels) $index]
	# vérifie les index
	if {($dir == -1 && $index == 0) || ($dir == +1 && $index == $max)} {
		bell
		return
	}
	# "shift" le panel
#puts "before panels = $event(panels) / $index ($max)"
	set event(panels) [lreplace $event(panels) $index $index]
	if {$dir == -1} {
		incr index -1
		set event(panels) [linsert $event(panels) $index $panel]
	} else {
		incr index
		set event(panels) [linsert $event(panels) $index $panel]
	}
#puts "after panels =  $event(panels)"
	# mise à jour affichage
	event:panels:display
	$t tag cell {} $::tkPriv(tkTableCurrent)
	set ::tkPriv(tkTableCurrent) "0,$index"
	$t tag cell current $::tkPriv(tkTableCurrent)
	$t tag raise current
	if {[$t index active col] != -1} {
		$t activate "0,$index"
	}
	$t see 0,$index
}

#-------------------------------------------------------------------------------------------------

proc skating::event:panels:using {f panel locked} {
variable $f
upvar 0 $f folder

	set levels [lindex $folder(panels) $panel]
#TRACEF "$folder(panels) / $levels"
	if {$locked == 0} {
		return [llength $levels]
	}

	# cherche si des notes existent pour le dossier
	if {$levels == "all"} {
		set levels $folder(levels)
	}

	set notes 0
	foreach level $levels {
		foreach item [array names folder notes:$level:*] {
			foreach n $folder($item) {
				incr notes $n
			}
		}
		if {$notes > 0} {
			break
		}
	}
#TRACEF "levels = $levels / notes = $notes"
	return $notes
}

proc skating::event:panels:isUsed {panel locked} {
variable gui
variable event

#TRACEF

	# cherche les dossiers utilisant le panel
	set uses [list ]
	foreach f $event(folders) {
		# un pour chaque danse en mode 10-danses
		variable $f
		upvar 0 $f folder
		if {$folder(mode) == "ten"} {
			foreach d $folder(dances) {
				if {[event:panels:using $f.$d $panel $locked]} {
					lappend uses $f.$d
				}
			}
		} else {
			if {[event:panels:using $f $panel $locked]} {
				lappend uses $f
			}
		}
	}
	set uses [lsort -unique $uses]

	return $uses
}

#-------------------------------------------------------------------------------------------------

proc skating::event:panels:propagateChange {panel} {
variable gui
variable event

	foreach f [event:panels:isUsed $panel 0] {
		variable $f
		upvar 0 $f folder
	
		# récupère les levels	
		set levels [lindex $folder(panels) $panel]
		if {$levels == "all"} {
			set levels $folder(levels)
		}
#TRACE "propagating on $f / $levels"
		# pour chaque level, mise à jour de la liste de juges
		foreach level $levels {
			set folder(judges:$level) $event(panel:judges:$panel)
		}
		# ajuste les judges:requested
		if {[lindex $folder(panels) $panel] == "all"} {
			set folder(judges:requested) $event(panel:judges:$panel)
		} else {
			# un peu brutal, mais sûr ...
			set folder(judges:requested) [list ]
		}
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::event:panels:setName {} {
variable gui
variable event

	# mémorise le nom en cours d'édition
	set col [$gui(w:init:panels) index active col]
	if {$col != -1} {
		set panel [lindex $event(panels) $col]
		set event(panel:name:$panel) [$gui(w:init:panels) curvalue]
		$gui(w:init:panels) activate "0,-1"
	}

	# mise à jour 2ème table
	event:panels2:display
}

set tkPriv(tkTableCurrent) 0,0

#---- Gestion du événements claviers
bind Panel <Visibility> {
	focus %W
}
bind Panel <KeyPress> {
	if {[string compare %A {}]} {
		%W insert active insert %A
	}
}

bind Panel <BackSpace> {
	set tkPriv(junk) [%W icursor]
	if {[string compare {} $tkPriv(junk)] && $tkPriv(junk)} {
		%W delete active [expr {$tkPriv(junk)-1}]
	}
}
bind Panel <Delete> {%W delete active insert}

bind Panel <Return> {
	skating::event:panels:setName
}
bind Panel <KP_Enter> {
	skating::event:panels:setName
}
bind Panel <Escape> {
	%W reread
	%W activate "0,-1"
}

#---- Button-1 press & release
bind Panel <ButtonPress-1> {
	focus %W
	set col [%W border mark %x %y]
	if {$col != "" && [lindex $col 1] >= 0} {
		set tkPriv(tkTableMode) "resize"
	} else {
		set tkPriv(tkTableMode) "select"
	}
}
bind Panel <Shift-ButtonPress-1> {
	set col [%W border mark %x %y]
	if {$col != "" && [lindex $col 1] >= 0} {
		set tkPriv(tkTableMode) "resize-all"
		set tkPriv(tkTableCol) [lindex $col 1]
	} else {
		set tkPriv(tkTableMode) "select"
	}
}
bind Panel <B1-Motion> {
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

bind Panel <ButtonRelease-1> {
	if {$tkPriv(tkTableMode) != "resize"} {
		skating::event:panels:setName
		set row [%W index @%x,%y row]
		set col [%W index @%x,%y col]
		if {$col >= 0 && $row > 0} {
			# cherche la lettre juge et regarde si il existe
			set judge [lindex $skating::event(judges) [expr {$row-1}]]
#puts "toggle $row/$col = $judge"
#  			if {[lsearch $skating::event(judges) $judge] == -1} {
#  				bell
#  				break
#  			}
			# ajout/supprime le juge du panel
			set panel [lindex $skating::event(panels) $col]

			if {[llength [skating::event:panels:isUsed $panel 1]]} {
				tk_messageBox -icon "info" -type ok -default ok \
							-title $msg(dlg:question) \
							-message $::msg(dlg:panelLocked)
			} elseif {[set index [lsearch $skating::event(panel:judges:$panel) $judge]] != -1} {
				set skating::event(panel:judges:$panel) [lreplace $skating::event(panel:judges:$panel) \
																$index $index]
				skating::event:panels:propagateChange $panel
				%W tag cell OFF @%x,%y
				skating::event:panels2:display
			} else {
				lappend skating::event(panel:judges:$panel) $judge
				skating::event:panels:propagateChange $panel
				%W tag cell ON @%x,%y
				skating::event:panels2:display
			}
#puts "toggle $panel/$judge = '$skating::event(panel:judges:$panel)'"
			%W selection anchor @%x,%y
			%W tag cell {} $tkPriv(tkTableCurrent)
			set tkPriv(tkTableCurrent) 0,[%W index @%x,%y col]
			%W tag cell current $tkPriv(tkTableCurrent)
			%W tag raise current

		} elseif {$col >= 0 && $row == 0} {
			# sélection du panel (highlight colonne)
			%W tag cell {} $tkPriv(tkTableCurrent)
			set tkPriv(tkTableCurrent) 0,[%W index @%x,%y col]
			%W tag cell current $tkPriv(tkTableCurrent)
			%W tag raise current
		}
	}
}

#---- Edition
bind Panel <Double-ButtonRelease-1> { }
bind Panel <Double-1> {
	if {[%W index @%x,%y row] == 0 && [%W index @%x,%y col] >= 0 } {
		%W tag cell {} $tkPriv(tkTableCurrent)
		set tkPriv(tkTableCurrent) [%W index @%x,%y]
		%W tag cell current $tkPriv(tkTableCurrent)
		%W tag raise current
		%W activate @%x,%y
	}
}
bind Panel <F2> {
	%W activate $tkPriv(tkTableCurrent)
}

#---- Scrollings
bind Panel <Left>		{
	if {[%W index active] != "0,-1"} {
		set pos [%W icursor]
		incr pos -1
		%W icursor $pos
	} else {
		%W xview scroll -1 unit
	}
}
bind Panel <Right>	{
	if {[%W index active] != "0,-1"} {
		set pos [%W icursor]
		incr pos +1
		%W icursor $pos
	} else {
		%W xview scroll +1 unit
	}
}
bind Panel <Home>		{
	if {[%W index active] != "0,-1"} {
		%W icursor 0
	} else {
		%W xview scroll -1000 page
		%W yview scroll -1000 page
	}
}
bind Panel <End>		{
	if {[%W index active] != "0,-1"} {
		%W icursor end
	} else {
		%W xview scroll +1000 page
		%W yview scroll +1000 page
	}
}
bind Panel <Prior> { if {[%W index active] == "0,-1"} { %W yview scroll -1 page } }
bind Panel <Next>  { if {[%W index active] == "0,-1"} { %W yview scroll +1 page } }
bind Panel <Up>    { if {[%W index active] == "0,-1"} { %W yview scroll -1 unit } }
bind Panel <Down>  { if {[%W index active] == "0,-1"} { %W yview scroll +1 unit } }

bind Panel <MouseWheel> { %W yview scroll [expr {- (%D / 120) * 4}] units }
if {[string equal "unix" $tcl_platform(platform)]} {
    bind Panel <4> { if {!$tk_strictMotif} { %W yview scroll -5 units } }
    bind Panel <5> { if {!$tk_strictMotif} { %W yview scroll 5 units } }
}



#==============================================================================================
#
#		Table pour la gestion des affectations de panels aux compétitions
#
#==============================================================================================


proc skating::event:panels2:display {} {
global msg
variable gui
variable event

	set table $gui(w:init:panels2)

	# redimensionne la table
	$table configure -rows [expr [llength $event(panels)]+1]
	$table tag col center 1 2
	$table tag row center 0
	set i 1
	foreach panel $event(panels) {
		$table set row $i,-1 [list $event(panel:name:$panel)]
		$table tag cell left $i,-1
		incr i
	}

	# les boutons de sélection rapide
	set last ""
	set number 0
	for {set i 0} {$i < $gui(t:init:panels2:total)} {incr i} {
		set col $i
		$table width $col 5
		set f $gui(t:init:panels2:$i)
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
	}
	# contenu pour chaque panel - affiche "oui/non"
	set row 1
	foreach panel $event(panels) {
		event:panels2:buttons:display $row $panel
		incr row
	}

	$table selection clear all
}

#-------------------------------------------------------------------------------------------------

proc skating::event:panels2:buttons:display {row panel} {
global msg
variable gui
variable event

TRACEF

	set table $gui(w:init:panels2)
	# affiche les boites
	for {set i 0} {$i < $gui(t:init:panels2:total)} {incr i} {
		set f $gui(t:init:panels2:$i)
		# cherche si panel utilisé
		variable $f
		upvar 0 $f folder
		if {$folder(mode) == "ten"} {
			Table::buttons:setStyle $table $row $i BUTTON
		} else {
			set levels [lindex $folder(panels) $panel]
			if {$levels == ""} {
				set state OFF
			} elseif {$levels == "all"} {
				set state ON
			} else {
				set state PARTIAL
			}
			Table::buttons:setStyle $table $row $i $state
		}
	}
}

proc skating::event:panels2:buttons:handle {action dummy row button} {
variable event
variable gui
global msg

#TRACEF

	if {$action != "space"} {
		return
	}

	set table $gui(w:init:panels2)
	set f $gui(t:init:panels2:$button)
	variable $f
	upvar 0 $f folder

	# retrouve le panel
	set panel [lindex $event(panels) [expr $row-1]]
#TRACE "panel = $panel / $row / $event(panels)"

	# bloque certains rafraichissement graphiques
	set gui(v:inEvent) 1

	# distingue le cas 10/normal
	if {$folder(mode) == "ten"} {
#TRACE "ten mode"
		set bb [expr {$button+1}]
		foreach dance $folder(dances) {
			variable $f.$dance
			upvar 0 $f.$dance Dfolder
			set gui(v:folder) $f.$dance
			set gui(v:dance) $dance

			manage:judges:selectPanel $f.$dance $panel all 0
			incr bb
		}
		set gui(v:dance) ""
		set gui(v:folder) ""

	} else {
#TRACE "toggle one dance for $f"
		# ajuste les données & mise à jour affichage
		set gui(v:folder) $f
		manage:judges:selectPanel $f $panel all 0
		set gui(v:folder) ""
	}

	# re-affiche tout car les exclusions mutuelles peuvent avoir des
	# effets de bords ...
	event:panels2:display

	# débloque certains rafraichissement graphiques
	set gui(v:inEvent) 0

	# les juges peuvent avoir été changés dans les compétitions
	set gui(v:tab:judges:pendingReinit) 1
}

proc skating::event:panels2:buttons:tip {button data} {
variable gui
variable event

	set f $gui(t:init:panels2:$button)
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

