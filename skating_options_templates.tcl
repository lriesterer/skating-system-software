##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion des modèles de danses pré-définis
#
#=================================================================================================

proc skating::options:templates {w} {
global msg
variable gui

	# la table utilisée comme zone de sélection
	set danses [TitleFrame::create $w.danses -text $msg(templates:danses)]
	set sub [TitleFrame::getframe $danses]

		set sw [ScrolledWindow::create $sub.sw \
					-scrollbar both -auto both -relief sunken -borderwidth 1]
		if {[info exists ::__templates]} {
			# efface données résiduelles
			unset ::__templates
		}
		set table [table $w.t -bordercursor sb_h_double_arrow -variable ::__templates \
				-highlightthickness 0 -cursor {} \
				-borderwidth 1 -bg gray95 \
				-resizeborders col \
				-width 6 -height 0 -maxheight 50 -maxwidth 50 \
				-titlerows 1 -titlecols 0 -roworigin 0 \
				-colstretchmode none -rowstretchmode none \
				-selectmode extended \
				-yscrollcommand {.sy set} -xscrollcommand {.sx set}]
		set gui(w:init:templates) $table
		ScrolledWindow::setwidget $sw $table
		# paramétrage de la table
		$table configure -titlecols 1 -colorigin -1 -rows 20
		$table set col 0,-1 {{} 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}
		$table width -1 3
		for {set i 0} {$i<25} {incr i} {
			$table width $i 15
		}

		$table tag configure active -relief raised -bd 1 -bg white -fg black -font {bold}
		$table tag configure title -relief raised -bd 1 -bg [. cget -bg] -fg black -font {bold} \
								   -state normal -anchor c
		$table tag configure sel -bg $gui(color:selection) -fg $gui(color:selectionFG)
		$table tag configure current -bg orange -anchor c
		$table tag cell current 0,0
		$table tag raise current
		$table tag configure left -anchor w
		$table tag configure center -anchor c
		$table tag configure noedit -state disable
		$table tag cell noedit 0,-1
		$table tag raise noedit
	
		# bindings
		bindtags $table "$table Template all"

		# help
		text $sub.h -font tips -height 2 -relief flat -bg [$w cget -background] -tabs {125}
		set gui(w:init:templates:help) $sub.h
		$sub.h tag configure blue -foreground darkblue
		$sub.h tag configure red -foreground red
		bindtags $sub.h "$sub.h all"
		eval $sub.h insert 1.0 $msg(help:templates:edit)

		# boutons
		set but2 [frame $sub.b2]
		  set gui(w:init:templates:buttons) $but2
		  button $but2.add -text $msg(add:template) -bd 1 -command "skating::options:templates:add"
		  button $but2.remove -text $msg(remove:template) -bd 1 -command "skating::options:templates:remove"
		  button $but2.left -image imgLeft -bd 1 -command "skating::options:templates:shift -1"
		  button $but2.right -image imgRight -bd 1 -command "skating::options:templates:shift +1"
		  button $but2.up -image imgUp -bd 1 -command "skating::options:templates:reorder -1"
		  button $but2.down -image imgDown -bd 1 -command "skating::options:templates:reorder +1"
		  pack $but2.add [frame $but2.sep1 -width 10] $but2.remove -side left -fill y
		  pack [frame $but2.sep2 -width 15] $but2.left [frame $but2.sep3 -width 5] $but2.right -side left -fill y
		  pack [frame $but2.sep4 -width 30] $but2.up [frame $but2.sep5 -width 5] $but2.down -side left -fill y

		pack $sw -side top -expand true -fill both
		pack $sub.h -side top -fill x
		pack [frame $sub.sep1 -height 5] $but2 -side top -fill x

	# fichier par défaut pour les modèles de compétitions
	set file [TitleFrame::create $w.file -text $msg(templates:file)]
	set sub [TitleFrame::getframe $file]
		set f [frame $sub.t]
			label $f.l -text $msg(db:filename)
			entry $f.e -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
					-textvariable skating::gui(pref:templates:file)
			button $f.b -text $msg(choose) -bd 1 \
					-command "skating::options:templates:setFile"
			pack $f.l $f.e $f.b -side left -anchor w -padx 5
			pack configure $f.e -expand true -fill x
		pack $sub.t -side top -anchor w -fill x


	# mise en page
	pack $danses -side top -fill both -expand true
	pack [frame $w.sep2 -height 15] $file -side top -fill x

	#==== init
	options:templates:display
	$table activate 0,-1
	$table selection anchor 1,0
	$table selection set 1,0
}

proc skating::options:templates:setFile {} {
global msg
variable gui

    set types [list [list $msg(fileSkating)	{.skt}] \
					[list $msg(fileAll) 	*] ]

	if {[file pathtype $gui(pref:templates:file)] == "relative"} {
		set filename "$::pathExecutable/data/$gui(pref:templates:file)"
	} else {
		set filename "$gui(pref:templates:file)"
	}

	set file [tk_getOpenFile -filetypes $types -parent .settings \
						-initialdir [file dirname $filename] \
						-initialfile [file tail $filename] ]
	if {$file == ""} {
		return
	}
	# OK
	set ::skating::gui(pref:templates:file) $file
	# charge nouvelles données
	folder:template:load $file
}

#-------------------------------------------------------------------------------------------------

proc skating::options:templates:display {} {
variable gui

#puts "skating::options:templates:display"
	set t $gui(w:init:templates)
	$t set col 0,-1 {{} 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19}

	# applique les données
	$t selection clear all
	$t configure -cols [expr [llength $gui(pref:templates)]+1]
	set col 0
	foreach template $gui(pref:templates) {
		$t tag col left $col
		$t tag row center 0
		$t set row 0,$col [list $gui(pref:template:name:$template)]
		$t set col 1,$col [list "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""]
		$t set col 1,$col $gui(pref:template:dances:$template)
		incr col
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::options:templates:add {} {
variable gui

	# cherche un numéro
	set new [expr [lindex [lsort $gui(pref:templates)] end]+1]
	lappend gui(pref:templates) $new
	# créé les variables
	set gui(pref:template:name:$new) ""
	set gui(pref:template:dances:$new) {}
	# réaffiche
	options:templates:display
	# positionne pour saisie du nom du template
	set t $gui(w:init:templates)
#puts "skating::options:templates:add >> tag cell {} $::tkPriv(tkTableCurrent)"
	$t tag cell {} $::tkPriv(tkTableCurrent)
	set ::tkPriv(tkTableCurrent) 0,[expr [llength $gui(pref:templates)]-1]
#puts "skating::options:templates:add >> tag cell current $::tkPriv(tkTableCurrent)"
	$t tag cell current $::tkPriv(tkTableCurrent)
	$t activate 0,[llength $gui(pref:templates)]
	$t see 0,[llength $gui(pref:templates)]
}

proc skating::options:templates:remove {} {
variable gui
global msg

	# cherche le template associé
	set t $gui(w:init:templates)
	set index [$t index $::tkPriv(tkTableCurrent) col]
	set template [lindex $gui(pref:templates) $index]
	# demande confirmation si le template contient des juges
	if {[llength $gui(pref:template:dances:$template)]} {
		set text "$msg(dlg:removeTemplate) '$gui(pref:template:name:$template)' ?"
		set doit [tk_messageBox -icon "question" -type yesno -default yes \
							-title $msg(dlg:question) -message $text]
		if {$doit != "yes"} {
			return
		}
	}
	# OK --> envèle le template
	set gui(pref:templates) [lreplace $gui(pref:templates) $index $index]
	# mise à jour affichage
	$t tag cell {} $::tkPriv(tkTableCurrent)
	$t activate "0,-1"
	set ::tkPriv(tkTableCurrent) "0,0"
	$t tag cell current "0,0"
	options:templates:display
}

#-------------------------------------------------------------------------------------------------

proc skating::options:templates:shift {dir} {
variable gui

	# cherche le template associé
	set t $gui(w:init:templates)
	set index [$t index $::tkPriv(tkTableCurrent) col]
	set max [expr [llength $gui(pref:templates)]-1]
	set template [lindex $gui(pref:templates) $index]
	# vérifie les index
	if {($dir == -1 && $index == 0) || ($dir == +1 && $index == $max)} {
		bell
		return
	}
	# "shift" le template
#puts "before templates = $gui(pref:templates) / $index ($max)"
	set gui(pref:templates) [lreplace $gui(pref:templates) $index $index]
	if {$dir == -1} {
		incr index -1
		set gui(pref:templates) [linsert $gui(pref:templates) $index $template]
	} else {
		incr index
		set gui(pref:templates) [linsert $gui(pref:templates) $index $template]
	}
#puts "after templates =  $gui(pref:templates)"
	# mise à jour affichage
	unset ::__templates
	options:templates:display
	$t tag cell {} $::tkPriv(tkTableCurrent)
	set ::tkPriv(tkTableCurrent) "0,$index"
	$t tag cell current $::tkPriv(tkTableCurrent)
	if {[$t index active col] != -1} {
		$t activate "0,$index"
	}
	$t see 0,$index
}

#-------------------------------------------------------------------------------------------------

proc skating::options:templates:reorder {dir} {
variable gui

	# cherche le template associé
	set t $gui(w:init:templates)
	set tindex [$t index $::tkPriv(tkTableCurrent) col]
	set template [lindex $gui(pref:templates) $tindex]
	# trouve la danse sélectionnée
#puts "<reorder> anchor = [$t index anchor]"
	set index [expr [$t index anchor row]-1]
	set max [expr [llength $gui(pref:template:dances:$template)]-1]
	# vérifie les index
	if {($dir == -1 && ($index == 0 || $index > $max)) || ($dir == +1 && $index >= $max)} {
		bell
		return
	}
	# "shift" le template
#puts "<reorder> before dances = $gui(pref:template:dances:$template) / $index ($max)"
	set old [lindex $gui(pref:template:dances:$template) $index]
	set gui(pref:template:dances:$template) [lreplace $gui(pref:template:dances:$template) $index $index]
	if {$dir == -1} {
		incr index -1
		set gui(pref:template:dances:$template) [linsert $gui(pref:template:dances:$template) $index $old]
	} else {
		incr index
		set gui(pref:template:dances:$template) [linsert $gui(pref:template:dances:$template) $index $old]
	}
#puts "<reorder> after templates =  $gui(pref:template:dances:$template)"
	# mise à jour affichage
	unset ::__templates
	options:templates:display
	$t tag cell {} $::tkPriv(tkTableCurrent)
	set ::tkPriv(tkTableCurrent) "0,$tindex"
	$t tag cell current $::tkPriv(tkTableCurrent)
	if {[$t index active col] != -1} {
		$t activate "0,$tindex"
	}
	$t see 0,$tindex
	# la sélection
	$t selection clear all
	incr index
#puts "<reorder> setting anchor to $index,$tindex"
	$t selection anchor $index,$tindex
	$t selection set $index,$tindex
}

#-------------------------------------------------------------------------------------------------

proc skating::options:templates:setData {activateNext} {
variable gui

	set w $gui(w:init:templates)
	set template [lindex $skating::gui(pref:templates) [$w index active col]]

	if {[$w index active row] == 0} {
		# mémorise le nom en cours d'édition
		set col [$w index active col]
		if {$col != -1 && [$w index active row] == 0} {
			set template [lindex $gui(pref:templates) $col]
			set gui(pref:template:name:$template) [$w curvalue]
			$w activate "0,-1"
		}

	} elseif {[$w index active col] >= 0} {
		set index [expr [$w index active row]-1]
#puts "---- $template / $skating::gui(pref:template:dances:$template) <<< $index"
		if {$::__templates(active) == "" && $index < [llength $skating::gui(pref:template:dances:$template)]} {
			set list [lreplace $skating::gui(pref:template:dances:$template) $index $index]
		} elseif {$index == [llength $skating::gui(pref:template:dances:$template)]} {
			lappend skating::gui(pref:template:dances:$template) $::__templates(active)
			set list $skating::gui(pref:template:dances:$template)
		} else {
			set list [lreplace $skating::gui(pref:template:dances:$template) $index $index $::__templates(active)]
		}
#puts "set skating::gui(pref:template:dances:$template) '$list'"
		set skating::gui(pref:template:dances:$template) $list
		if {$::__templates(active) == "" || $activateNext == 0} {
			$w activate "0,-1"
			skating::options:templates:display
		} else {
#puts "<Return> setting anchor to [expr [$w index active row]+1],[$w index active col]"
			$w selection anchor [expr [$w index active row]+1],[$w index active col]
			$w selection clear all
			$w selection set [expr [$w index active row]+1],[$w index active col]
#puts "[expr [$w index active row]+1] > 20"
			if {[expr [$w index active row]+1] < 20} {
				$w activate [expr [$w index active row]+1],[$w index active col]
				$w see active
			} else {
				$w activate "0,-1"
			}
		}
	}
}


set tkPriv(tkTableCurrent) 0,0

#---- Gestion du événements claviers
bind Template <Visibility> {
	focus %W
}
bind Template <KeyPress> {
    if {[string compare %A {}] != 0} {
		# auto-toggle édition
	    if {[%W index active] == "0,-1"} {
			%W selection clear all
			%W activate [%W index anchor]
			%W delete active 0 end
	    }
		# insère la saisie
		%W insert active insert %A
    }
}

bind Template <BackSpace> {
    set tkPriv(junk) [%W icursor]
    if {[string compare {} $tkPriv(junk)] && $tkPriv(junk)} {
		%W delete active [expr {$tkPriv(junk)-1}]
    }
}
bind Template <Delete> {
	if {[%W index active col] >= 0} {
		%W delete active insert
	} else {
		set template [lindex $skating::gui(pref:templates) [%W index anchor col]]
		set index [expr [%W index anchor row]-1]
		set list [lreplace $skating::gui(pref:template:dances:$template) $index $index]
#puts "list = $list"
		set skating::gui(pref:template:dances:$template) $list
		%W activate "0,-1"
		skating::options:templates:display
	}
}

bind Template <Return> {
	skating::options:templates:setData 1
}
bind Template <Escape> {
	%W reread
	%W activate "0,-1"
}

#---- Button-1 press & release
bind Template <ButtonPress-1> {
    set col [%W border mark %x %y]
	if {$col != "" && [lindex $col 1] >= 0} {
		set tkPriv(tkTableMode) "resize"
	} else {
		set tkPriv(tkTableMode) "select"
	}
}
bind Template <B1-Motion> {
	if {$tkPriv(tkTableMode) == "resize"} {
		%W border dragto %x %y
	}
}

bind Template <ButtonRelease-1> {
	if {$tkPriv(tkTableMode) != "resize"} {
		skating::options:templates:setData 0
		set template [lindex $skating::gui(pref:templates) [%W index @%x,%y col]]
		if {[%W index @%x,%y col] >= 0 && [%W index @%x,%y row] <= 1+[llength $skating::gui(pref:template:dances:$template)]} {
#puts "<ButtonRelease-1> setting anchor to [%W index @%x,%y]"
			%W selection anchor @%x,%y
			%W selection clear all
			%W selection set @%x,%y
			%W tag cell {} $tkPriv(tkTableCurrent)
			set tkPriv(tkTableCurrent) 0,[%W index @%x,%y col]
			%W tag cell current $tkPriv(tkTableCurrent)
		} else {
			bell
		}
	}
}

#---- Edition
bind Template <Double-ButtonRelease-1> { }
bind Template <Double-1> {
	set template [lindex $skating::gui(pref:templates) [%W index @%x,%y col]]
#puts "<Double-1> template = $template / [llength $skating::gui(pref:template:dances:$template)]"
	if {[%W index @%x,%y col] >= 0 && [%W index @%x,%y row] <= 1+[llength $skating::gui(pref:template:dances:$template)]} {
		%W tag cell {} $tkPriv(tkTableCurrent)
		set tkPriv(tkTableCurrent) 0,[%W index @%x,%y col]
		%W tag cell current $tkPriv(tkTableCurrent)
		%W activate @%x,%y
	}
}
bind Template <F2> {
	%W activate $tkPriv(tkTableCurrent)
}

#---- Scrollings
bind Template <Left>		{
	if {[%W index active] != "0,-1"} {
		set pos [%W icursor]
		incr pos -1
		%W icursor $pos
	} else {
		%W xview scroll -1 unit
	}
}
bind Template <Right>	{
	if {[%W index active] != "0,-1"} {
		set pos [%W icursor]
		incr pos +1
		%W icursor $pos
	} else {
		%W xview scroll +1 unit
	}
}
bind Template <Home>		{
	if {[%W index active] != "0,-1"} {
		%W icursor 0
	} else {
		%W xview scroll -1000 page
		%W yview scroll -1000 page
	}
}
bind Template <End>		{
	if {[%W index active] != "0,-1"} {
		%W icursor end
	} else {
		%W xview scroll +1000 page
		%W yview scroll +1000 page
	}
}
bind Template <Prior> { if {[%W index active] == "0,-1"} { %W yview scroll -1 page } }
bind Template <Next>  { if {[%W index active] == "0,-1"} { %W yview scroll +1 page } }
bind Template <Up>    { if {[%W index active] == "0,-1"} { %W yview scroll -1 unit } }
bind Template <Down>  { if {[%W index active] == "0,-1"} { %W yview scroll +1 unit } }

bind Template <MouseWheel> { %W yview scroll [expr {- (%D / 120) * 4}] units }
if {[string equal "unix" $tcl_platform(platform)]} {
    bind Template <4> { if {!$tk_strictMotif} { %W yview scroll -5 units } }
    bind Template <5> { if {!$tk_strictMotif} { %W yview scroll 5 units } }
}
