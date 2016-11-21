##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion des rounds dans une comptétition
#
#=================================================================================================

proc skating::folder:new {{label ""} {dances {}}} {
global msg
variable gui
variable event


#TRACEF "inEdit=$gui(v:inEdit)"

	# si en train d'éditer un titre
	if {$gui(v:inEdit) == 1} {
		return
	}

#  	# vérifie si des couples et des juges sont définis
#  	if {!([llength $event(couples)] && [llength $event(judges)])
#  			|| ($event(couples)=="1" && $event(name:1)=="" && $event(judges)=="A" && $event(name:A)=="") } {
#  		tk_messageBox -icon "info" -type ok -default ok \
#  				-title $msg(dlg:information) -message $msg(dlg:defineCandJ)
#  		return
#  	}

	# modifications ...
	set gui(v:modified) 1

	# cherche numéro de dossier
	set f [folder:getFreeID]
	# initialise le dossier
	set l $label
	if {$l == ""} { 
		set l $msg(newCompetition)
	}
	skating::folder:init:normal $f $l $dances
	# ajoute & affiche le dossier créé
	variable $f
	upvar 0 $f folder
	lappend event(folders) $f
	folder:add $f $folder(label)
	if {$label == ""} {
		update
		Tree::see $gui(w:tree) $f
		gui:select 1 $f

#TRACE "<<<<<< added >>>>>"
		variable dblclick
		catch { unset dblclick }
		after idle "skating::gui:tree:edit $f"
	}

	return $f
}

proc skating::folder:init:normal {f label {dances {}} {mode "normal"}} {
variable $f
upvar 0 $f folder
variable gui

TRACEF

	# efface anciennes données
	if {[info exists folder(dances)]} {
		foreach dance $folder(dances) {
			variable $f.$dance
			catch { unset $f.$dance }
		}
	}
	# données minimales
	set folder(label) $label
	set folder(mode) $mode
	set folder(couples:names) {}
	set folder(couples:all) {}
	set folder(dances) $dances
	set folder(judges:requested) {}
	set folder(judges:finale) {}
	set folder(round:generation) "auto"
	set folder(round:explicitNames) $gui(pref:explicitNames)
	set folder(round:use50%rule) 1
	set folder(levels) {}
	set folder(panels) {}
}

proc skating::folder:init:ten {f label {dances {}}} {
variable $f
upvar 0 $f folder

	# efface anciennes données
	foreach n [array names $f] {
		if {$n == "label" || $n == "dances" || $n == "mode" || [string match "attributes:*" $n]} {
			continue
		}
		unset folder($n)
	}
	# données minimales
	set folder(mode) "ten"
	set folder(label) $label
	set folder(dances) $dances
	foreach dance $folder(dances) {
		folder:init:normal $f.$dance $folder(label) [list $dance]
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::folder:add {f label {where end}} {
variable $f
upvar 0 $f folder
variable gui

#TRACEF

	# ajoute l'entrée
	if {$folder(mode) == "ten"} {
		set image imgCupTen
	} else {
		set image imgCup
	}
	Tree::insert $gui(w:tree) $where root $f -data "folder" \
			-text $label -image $image -open 1
	# pour les gros fichiers donne une meilleur impressino de réactivité
	if {$folder(mode) == "ten"} {
		update
	}
	# calcule le nombre de rounds
	manage:rounds:generate $f create

}

#-------------------------------------------------------------------------------------------------

proc skating::folder:delete {{interactive 1}} {
global msg
variable gui
variable event

#TRACEF

	# vérifie si qqch sélectionné
	if {$gui(v:folder) == ""} {
		bell
		return
	}
	# demande confirmation
	if {$interactive} {
		variable $gui(v:folder)
		upvar 0 $gui(v:folder) folder

		set judges 0
		foreach level $folder(levels) {
			if {[llength $folder(judges:$level)]} {
				set judges 1
				break
			}
		}
		if {[llength $folder(couples:names)] || [llength $folder(dances)] || $judges} {
			set doit [tk_messageBox -icon "question" -type yesno -default yes \
								-title $msg(dlg:question) -message $msg(dlg:confirmDelete)]
			if {$doit == "no"} {
				return
			}
		}
	}
	# modifications ...
	set gui(v:modified) 1
	# synchro variable event
	set idx [lsearch $event(folders) $gui(v:folder)]
	if {$idx == 0} {
		set before [lindex $event(folders) 1]
	} else {
		set before [lindex $event(folders) [expr $idx-1]]
	}
	set event(folders) [lreplace $event(folders) $idx $idx]
	# mise à jour affichage
	folder:remove $gui(v:folder)
	if {$interactive && $before != ""} {
		gui:select 1 $before
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::folder:remove {index} {
variable gui

	# teste si index donné ou tout
	if {$index == "all"} {
		set index [Tree::nodes $gui(w:tree) root]
	}
	# retire les entrées
	foreach i $index {
		unset ::skating::${i}
		Tree::delete $gui(w:tree) $i
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::folder:getFreeID {} {
variable gui

	set max 0
	foreach n [Tree::nodes $gui(w:tree) root] {
		scan $n "folder%d" tmp
		if {$tmp > $max} {
			set max $tmp
		}
	}
	return "folder[incr max]"
}

#=================================================================================================

proc skating::folder:up {} {
variable gui
variable event

	# modifications ...
	set gui(v:modified) 1
	# do it
	if {$gui(v:folder) == ""} {
		return
	}

	set idx [Tree::index $gui(w:tree) $gui(v:folder)]
	if {$idx == 0} {
		return
	}
	Tree::reorder $gui(w:tree) $gui(v:folder) [expr $idx-1]
	set event(folders) [Tree::nodes $gui(w:tree) root]
}

#-------------------------------------------------------------------------------------------------

proc skating::folder:down {} {
variable gui
variable event

	# modifications ...
	set gui(v:modified) 1
	# do it
	if {$gui(v:folder) == ""} {
		return
	}

	set idx [Tree::index $gui(w:tree) $gui(v:folder)]
	if {$idx == [expr [llength [Tree::nodes $gui(w:tree) root]]-1]} {
		return
	}
	Tree::reorder $gui(w:tree) $gui(v:folder) [expr $idx+1]
	set event(folders) [Tree::nodes $gui(w:tree) root]
}


#=================================================================================================
#
#		Gestion d'une liste de compétition pré-définies pour création rapide
#
#=================================================================================================

proc skating::folder:template {} {
global msg

#TRACEF

	set w [toplevel .dd]
	wm title $w $msg(competitions)

	# frame du dialogue
	set top [frame $w.top]

	set choice [frame $top.choice -bd 0]

	# zone pour la liste des modèles
	set sw [ScrolledWindow::create $choice.sw -scrollbar both -auto both -relief sunken -borderwidth 1]
	set c [canvas [ScrolledWindow::getframe $sw].sel -bd 0 -bg gray95 \
					-width 550 -height 40 \
					-highlightthickness 0]
	set ::canvasTemplates $c
	bind $c <Up> "skating::folder:template:move $c -1"
	bind $c <Down> "skating::folder:template:move $c +1"
	bind $c <Prior> "skating::folder:template:move $c -15"
	bind $c <Next> "skating::folder:template:move $c +15"
	bind $c <Home> "skating::folder:template:move $c -1000"
	bind $c <End> "skating::folder:template:move $c +1000"
	bind $c <space> "skating::folder:template:toggle $c \$position"
	ScrolledWindow::setwidget $sw $c

	folder:template:buildList $c

	# zone pour le choix du fichier de définition des modèles
	set f [frame $choice.f]
		label $f.l -text $msg(templates)
		entry $f.e -bd 1 -bg [$f cget -bg] \
				-textvariable ::fileTemplates
		bindtags $f.e "$f.e all"
		button $f.b -text $msg(load) -bd 1 \
				-command "skating::folder:template:choose"
		button $f.m -text $msg(edit) -bd 1 \
				-command "skating::folder:template:edit"
		pack $f.l $f.e [frame $f.0 -width 10] $f.b $f.m -side left -anchor w
		pack configure $f.e -padx 5
		pack configure $f.e -expand true -fill x

	# affiche nombre de compétitions sélectionnées
	label $choice.nb -textvariable ::nbSelected

	# mise en page
	pack $f -side top -fill x -pady 10
	pack $sw -fill both -expand true
	pack $choice.nb -pady 5 -anchor w

  	pack $choice -fill both -expand true -padx 10 -pady 10

	pack $top -fill both -expand true -side top

	# frame des boutons
	set but [frame $w.but -bd 1 -relief raised]
	  button $but.ok -text $msg(dlg:ok) -underline 0 -bd 1 -width 7 \
			-command "skating::folder:template:doit" -default active
	  button $but.can -text $msg(dlg:cancel) -underline 0 -bd 1 -width 7 \
			-command "destroy $w"
	  grid $but.ok $but.can -sticky ew -padx 10 -pady 5
	pack $but -fill x -anchor c -side bottom

	# key bindings
	bind $w <Alt-o> "skating::folder:template:doit"
	bind $w <Return> "skating::folder:template:doit"
	bind $w <Alt-a> "after idle {destroy $w}"
	bind $w <Alt-c> "after idle {destroy $w}"
	bind $w <Escape> "after idle {destroy $w}"

	# raise la page de choix
	wm geometry $w 600x500
	focus $c

	# ajuste position de la boite de dialogue
	centerDialog .top $w 600 500
}


proc skating::folder:template:buildList {c} {
variable gui
variable event


#TRACEF

	# détruit ancien contenu
	$c delete all

	# remplit le canvas (plusieurs passes pour ajuster la position des colonnes)

	# 1ère passe = nom/label
	set y 2
	set h 16
	set i 0
	set names [list ]
	foreach type $::templates {
		$c create rectangle 0 [expr $y-1] 10000 [expr $y+$h-1] -outline {} -fill {} -tags "b:$i s:$i"
		$c create text 4 $y -anchor nw -text [lindex $type 0] -tags "name s:$i t:$i"
		lappend names [lindex $type 0]
		# bindings pour sélection
		$c bind "s:$i" <1> "skating::folder:template:toggle $c $i"
		# entrée suivante
		incr i
		incr y $h
	}
	# 2ème passe = danses
	set y 2
	set i 0
	set x [expr [lindex [$c bbox name] 2]+50]
	foreach type $::templates {
		$c create text $x $y -anchor nw -text [join [lindex $type 1] ", "] -tags "text s:$i t:$i"
		if {[lindex $type 3] == "ten"} {
			$c create text [expr $x-25] $y -anchor nw -text (10) -fill blue
		}
		incr i
		incr y $h
	}
	# 3ème passe = attributs
	set y 2
	set i 0
	set x [expr [lindex [$c bbox text] 2]+50]
	foreach type $::templates {
		set text [list ]
		foreach {t v} [lindex $type 2] {
			lappend text "$t=$v"
		}
		$c create text $x $y -anchor nw -text [join $text " / "] -tags "attr s:$i t:$i"
		incr i
		incr y $h
	}

	# zone de scrolling
	set bbox [$c bbox attr]
	if {[llength $bbox] != 4} {
		set bbox [list 0 0 1000 $y]
	} else {
		set bbox [lreplace $bbox 0 1 0 0]
		set bbox [lreplace $bbox 2 2 [expr [lindex $bbox 2]+2]]
		set bbox [lreplace $bbox 3 3 [expr [lindex $bbox 3]+2]]
	}
	$c configure -scrollregion $bbox
	if {$::tcl_platform(platform) == "windows"} {
		$c create rectangle 0 [expr 2-1] 10000 [expr 2+$h-1] -outline black -fill {} -dash . -tags "cursor"
	} else {
		$c create rectangle 0 [expr 2-1] 10000 [expr 2+$h-1] -outline black -fill {} -tags "cursor"
	}
	$c xview moveto 0
	$c yview moveto 0

	# init
	set ::position 0
	set ::selected [list ]
	set ::selectedBefore [list ]
	catch { unset ::selectedBeforeFolder }
	foreach f $event(folders) {
		variable $f
		upvar 0 $f folder

		set i 0
		foreach name $names {
			if {[string first $name $folder(label)] != -1} {
				lappend ::selected $i
				lappend ::selectedBefore $i
				set ::selectedBeforeFolder($i) $f
				$c itemconfigure b:$i -fill $gui(color:selection)
				$c itemconfigure t:$i -fill $gui(color:selectionFG)
				break
			}
			incr i
		}
	}
	folder:template:setTotal
	set ::selectedBefore [lsort -integer $::selectedBefore]
}


proc skating::folder:template:setTotal {} {
variable event
global msg

	set len [llength $::selected]
	if {$len == 0} {
		set pattern 0
	} elseif {$len == 1} {
		set pattern 1
	} else {
		set pattern 2
	}
	set ::nbSelected [format $msg(compSelected$pattern) $len [llength $event(folders)]]
}


proc skating::folder:template:toggle {c i} {
variable gui
variable event
global msg

#TRACEF

	if {[set index [lsearch $::selected $i]] == -1} {
		# ON
		lappend ::selected $i
		$c itemconfigure b:$i -fill $gui(color:selection)
		$c itemconfigure t:$i -fill $gui(color:selectionFG)
	} else {
		# OFF
		set ::selected [lreplace $::selected $index $index]
		$c itemconfigure b:$i -fill {}
		if {[lsearch $::selectedBefore $i] != -1} {
			$c itemconfigure t:$i -fill red
		} else {
			$c itemconfigure t:$i -fill black
		}
	}

	$c coords cursor [$c bbox b:$i]
	folder:template:setTotal
}

proc skating::folder:template:move {c amount} {
variable gui
variable event
global msg

#TRACEF

	set i [expr {$::position + $amount}]
	if {$i < 0} { set i 0}
	if {$i >= [llength $::templates]} { set i [expr [llength $::templates]-1] }
	set ::position $i
	# bouge le curseur et scroll pour le voir
	$c coords cursor [$c bbox b:$i]

	set h [lindex [$c cget -scrollregion] 3]
	set y1 [lindex [$c coords "b:$i"] 1]
	set y2 [lindex [$c coords "b:$i"] 3]
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

#----------------------------------------------------------------------------------------------

proc skating::folder:template:doit {} {
variable gui
variable event
global msg

#TRACEF

	# vérifie si on détruit des compétitions : demande confirmation
	set confirm 0
	set foldersToRemove [list ]
	foreach i $::selectedBefore {
		if {[lsearch $::selected $i] == -1} {
			set confirm 1
			lappend foldersToRemove $i
		}
	}
	if {$confirm} {
		set doit [tk_messageBox -icon "question" -type yesno -default yes \
							-title $msg(dlg:question) -message $msg(dlg:confirmDelete2)]
		if {$doit == "no"} {
			return
		}
	}

#TRACE "remove = $foldersToRemove"
	foreach i $foldersToRemove {
		set gui(v:folder) $::selectedBeforeFolder($i)
		folder:delete 0
	}

#TRACE "selected = [lsort -integer $::selected]"
	# création des nouvelles compétitions
	foreach i [lsort -integer $::selected] {
		if {[lsearch $::selectedBefore $i] == -1} {
			# modifications ...
			set gui(v:modified) 1

			# cherche numéro de dossier
			set f [folder:getFreeID]
			# calcul position d'instersion
			set position "end"
#TRACE "searching position for $i"
			foreach ff $::selectedBefore {
#TRACE "testing  $i <= $ff"
				if {$i <= $ff} {
					set position [lsearch $event(folders) $::selectedBeforeFolder($ff)]
#TRACE "    position = $position"
					break
				}
			}
			
			# initialise le dossier
			variable $f
			upvar 0 $f folder
			set event(folders) [linsert $event(folders) $position $f]
			foreach {label dances attributes mode} \
					[lindex $::templates $i] break

#TRACE "creating folder '$f' / '$label' / $mode  //  $attributes  //  $dances"

			foreach {name value} $attributes {
				set folder(attributes:$name) $value
			}
			# création du dossier
			folder:init:$mode $f $label $dances
			folder:add $f $label $position
		}
	}

	# réinitialise affichage
	set gui(v:lastselection) ""
	set gui(v:folder) ""
	set gui(v:round) ""
	Tree::delete $gui(w:tree) [Tree::nodes $gui(w:tree) root]
	gui:redisplay

	# fin du dialogue
	destroy .dd
}

#----------------------------------------------------------------------------------------------

proc skating::folder:template:choose {} {
global msg

	# boite de dialogue pour le choix du fichier
    set types [list [list $msg(fileSkatingSkt)	{.skt}] \
					[list $msg(fileAll) 		*] ]

	set file [tk_getOpenFile -filetypes $types -parent .dd \
						-initialdir [file dirname $::fileTemplates] \
						-initialfile [file tail $::fileTemplates] ]
	if {$file == ""} {
		return
	}

	folder:template:load $file
	folder:template:buildList $::canvasTemplates
}

proc skating::folder:template:load {filename} {
global msg

#TRACEF

	# chargement des données
	if {[file exists $filename]} {
		if {[catch {set file [open $filename]
					fconfigure $file -encoding utf-8
					set ::templates [list ]
					while {![eof $file]} {
						set line [gets $file]
						if {[string length $line]} {
							lappend ::templates $line
						}
					}
					close $file
				} errmsg]} {
			tk_messageBox -icon "error" -type ok -default ok -title $msg(dlg:error) \
					-message "$msg(dlg:templatesFailed) ($filename)"
		}
	}

	# par défaut une liste de modèle vide
	if {![info exists ::templates]} {
		set ::templates [list ]
	}

	# mémorise le fichier courant
	set ::fileTemplates $filename
}

#----------------------------------------------------------------------------------------------

proc skating::folder:template:edit {} {
variable gui
global msg

#TRACEF

	set w [toplevel .e]
	wm title $w $msg(competitions)

	# zone de texte pour édition
	set sw [ScrolledWindow::create $w.sw -scrollbar both -auto both -relief sunken -borderwidth 1]
	set t [text [ScrolledWindow::getframe $sw].t -bd 1 -bg gray95 \
				-wrap none -selectbackground $gui(color:selection)]
	ScrolledWindow::setwidget $sw $t
	pack $sw -side top -fill both -expand true -padx 5 -pady 5

		# remplit le texte
		if {[catch {set file [open $::fileTemplates]
					fconfigure $file -encoding utf-8
					$t insert end [read $file]
					close $file
				} errmsg]} {
			destroy $w
#TRACE $::errorInfo
			tk_messageBox -icon "error" -type ok -default ok -title $msg(dlg:error) \
					-message "$msg(dlg:templatesFailed) ($::fileTemplates)"
		}
		$t mark set insert 1.0

	# rechercher / remplacer
	set f [frame $w.sr]
		label $f.sl -text $msg(search)
		entry $f.s -textvariable ::search -bd 1 -bg gray95
		button $f.sb -text $msg(search) -bd 1 -command "
			$t tag remove sel 0.0 end
			set pos \[$t search -regexp -- \$::search \"insert+1c\"\]
			if {\$pos == \"\"} { bell ; return }
			$t mark set insert \$pos
			$t tag add sel \$pos \[$t index \"\$pos+\[string length \$::search\]c\"\]
			$t see insert
		"

		label $f.rl -text $msg(replace)
		entry $f.r -textvariable ::replace -bd 1 -bg gray95
		button $f.rb -text $msg(replace) -bd 1 -command "
			$t tag remove sel 0.0 end
			set pos \[$t search -regexp -- \$::search \"insert+1c\"\]
			if {\$pos == \"\"} { bell ; return }
			$t delete \$pos \[$t index \"\$pos+\[string length \$::search\]c\"\]
			$t insert \$pos \$::replace
			$t mark set insert \$pos
			$t tag add sel \$pos \[$t index \"\$pos+\[string length \$::replace\]c\"\]
			$t see insert
		"

		grid $f.sl $f.s $f.sb -sticky ew -padx 5 -pady 2
		grid $f.rl $f.r $f.rb -sticky ew -padx 5 -pady 2
		grid columnconfigure $f {1} -weight 1

	pack $f -side top -fill both -expand true -padx 5 -pady 5

	# frame des boutons
	set but [frame $w.but -bd 1 -relief raised]
	  button $but.s -text $msg(dlg:save) -underline 0 -bd 1 -width 14 \
			-command "skating::folder:template:save $t 0; destroy $w" -default active
	  button $but.sas -text $msg(dlg:saveAs) -underline 0 -bd 1 -width 14 \
			-command "skating::folder:template:save $t 1; destroy $w"
	  button $but.can -text $msg(dlg:cancel) -underline 0 -bd 1 -width 14 \
			-command "destroy $w"
	  grid $but.s $but.sas $but.can -sticky ew -padx 10 -pady 5
	pack $but -fill x -anchor c -side bottom

	# key bindings
	bind $w <Alt-s> "skating::folder:template:doit"
	bind $w <Return> "skating::folder:template:doit"
	bind $w <Alt-a> "after idle {destroy $w}"
	bind $w <Alt-c> "after idle {destroy $w}"
	bind $w <Escape> "after idle {destroy $w}"

	# raise la page de choix
	wm geometry $w 600x500
	focus $t

	# ajuste position de la boite de dialogue
	centerDialog .top $w 600 500
}

proc skating::folder:template:save {t saveAs} {
global msg

#TRACEF

	# demande nom de fichier si besoin
	if {$saveAs} {
	    set types [list [list $msg(fileSkatingSkt)	{.skt}] \
						[list $msg(fileAll) 		*] ]

		set filename [tk_getSaveFile -filetypes $types -parent .e \
							-initialdir [file dirname $::fileTemplates] \
							-initialfile [file tail $::fileTemplates] ]
		if {$filename == ""} {
			return
		}
	} else {
		set filename $::fileTemplates
		# backup le fichier original
		catch {file rename -force -- $::fileTemplates "$::fileTemplates.bak"}
	}

	# vérifie si on peut sauver le fichier
	if {[catch {set file [open $filename "w"]} errStr]} {
		if {![file writable [file dirname $filename]]} {
			tk_messageBox -icon "error" -type ok -default ok \
					-title $msg(dlg:cannotWrite) -message [format $msg(dlg:cannotWrite) $filename]
		} else {
			tk_messageBox -icon "error" -type ok -default ok \
					-title $msg(dlg:error) -message "$msg(dlg:cantSave) '$filename'.\n\n($errStr)"
		}
		return
	}

	# sauvegarde les données
	fconfigure $file -encoding utf-8
	puts $file [string trim [$t get 1.0 end]]
	close $file

	# mise à jour affichage
	folder:template:load $filename
	folder:template:buildList $::canvasTemplates
}

