##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer


#=================================================================================================
#
#	Génération d'un onglet de résultats pour un round d'une compétition
#
#=================================================================================================

proc skating::result:createTab {f round mode} {
variable $f
upvar 0 $f folder
variable event
variable gui
global msg

TRACEF

	# différenciation mode Round/Finale
	#---- partie haute = canvas avec les résultats
	if {$mode == "full"} {
		set name "result"
		set text $msg(result)
	} else {
		set name "result_[string map {. _} $round]"
		set text $folder(round:$round:name)
	}
	if {$round == "finale"} {
		set result [NoteBook::insert $gui(w:notebook) end $name \
							-text $text \
							-raisecmd "skating::fastentry:deselectAll; \
									   set skating::gui(v:judge) -1; \
									   set ::skating::gui(v:dance) {}; \
									   skating::ranking:display [list $f] $round"]
	} else {
		set result [NoteBook::insert $gui(w:notebook) end $name \
							-text $text \
							-raisecmd "skating::fastentry:deselectAll; \
									   set skating::gui(v:judge) -1; \
									   set ::skating::gui(v:dance) {}; \
									   skating::selection:display [list $f] $round"]
	}
	if {$mode == "full"} {
		NoteBook::itemconfigure $gui(w:notebook) $name -background #f3b4ad
	}
	set sw [ScrolledWindow::create $result.sw -scrollbar both -auto both -relief sunken -borderwidth 1]
	if {$round == "finale"} {
		set canvas [gui:ranking [ScrolledWindow::getframe $sw] $f $round]
	} else {
		set canvas [gui:selection [ScrolledWindow::getframe $sw] $f $round $mode]
	}
	ScrolledWindow::setwidget $sw $canvas
	# mise en page
	pack $sw -side top -pady 5 -expand true -fill both

	# création de la partie basse de l'écran
	result:bottomPanel:$folder(mode) $f $round $mode $result
}

proc skating::result:bottomPanel:normal {f round mode w {dance {}}} {
variable $f
upvar 0 $f folder
variable event
variable gui
global msg

#puts "skating::result:bottomPanel {$f $round $mode $w}"

	#---- pour les deux, zone de texte pour commentaire libre
	set tf [TitleFrame::create $w.comment -text $msg(comment)]
	set sub [TitleFrame::getframe $tf]
    text $sub.text -width 1 -height 4 -wrap word -yscrollcommand "$sub.y set" -borderwidth 1 \
			-bg gray95 -relief sunken -selectbackground $gui(color:selection)
	scrollbar $sub.y -orient vertical -command "$sub.text yview" -bd 1
	pack $sub.text -side left -fill both -expand true
	pack $sub.y -side left -fill y
	pack $tf [frame $w.sep1 -height 20] -side bottom -fill x
	# binding pour focus & synchro variable associée
	if {$folder(mode) == "ten"} {
		bindEntry $sub.text "[list skating::${f}.${dance}(comments:$round)]"
		variable $f.$dance
		upvar 0 $f.$dance Dfolder
		if {[info exists Dfolder(comments:$round)]} {
			$sub.text insert end $Dfolder(comments:$round)
		}
	} else {
		bindEntry $sub.text "[list skating::${f}(comments:$round)]"
		if {[info exists folder(comments:$round)]} {
			$sub.text insert end $folder(comments:$round)
		}
	}

	#---- partie basse de l'écran pour l'onglet de résultat = sélection des couples
	#     à garder pour le round suivant
	if {$mode == "full" && $round != "finale"} {
		#---- en mode dix-danses, bouton pour le choix des heats
		if {[string first "." $f] != -1} {
			set tf [TitleFrame::create $w.h -text $msg(Heats)]
			set sub [TitleFrame::getframe $tf]
			set skating::gui(t:useHeats:$round:$dance) 0
			checkbutton $sub.b -text $msg(active) -bd 1 -variable skating::gui(t:useHeats:$round:$dance) \
					-command "skating::round:draw $gui(w:canvas:$round:$dance) [list $f] [list $dance] $round;
							  skating::selection:drawResult $gui(w:canvas:$round:$dance) [list $f] $round 0 full"
			pack $sub.b -side left -fill x -anchor s
			pack $tf -side right -fill y
			pack [frame $w.sep2 -width 10] -side right
		}
		#---- pour les rounds, nombre de couple à reprendre, et bouton de validation
		set tf [TitleFrame::create $w.nb -text $msg(selectionCouples)]
		set sub [frame [TitleFrame::getframe $tf].top]
		# liste des couples
		set selected round:$round:nbSelected
		set couples $folder(couples:$round)

		if {![info exists folder($selected)]} {
			set folder($selected) $folder(round:$round:nb)
		}
		# calcul min/max
		set nb $folder(round:$round:nb)
		set min [expr {$nb-12}]
		regexp {[^.]*} $round mainRound
		set next [rounds:next $f $mainRound]
		set isSplit [expr {[string first "." $round] != -1}]
		if {$isSplit} {
			set minNext [expr $folder(round:$next:nb)+$folder(round:$next.2:nb) - $folder(round:$round:nb)]
		} else {
			set minNext [expr $folder(round:$next:nb)+$folder(round:$next.2:nb) - $folder(round:$round.2:nb)]
		}
		if {$min < $minNext && $min >= $nb } { set min $minNext	}
		if {$min < 0} { set min 0 }
		set max [expr $nb+12]
		if {$max > [llength $couples]} {
			set max [llength $couples]
		}
#TRACE "isSplit $isSplit"
		if {!$isSplit && $min < [set pre [nbPrequalified $f $round]]} {
			set min $pre
		}
		# force dans bornes 2--9 pour finale
		if {$min < 2 && $next == "finale"} { set min 2 }
		if {$max > 9 && $next == "finale"} { set max 9 }
		if {$min > $max} { set min $max }
#TRACE "---- min = $min / max = $max  --  $nb"
		label $sub.nb -text "$msg(keepCouples) : $folder(round:$round:nb)" \
				-anchor w -font normal
		scale $sub.scale -from $min -to $max -bd 1 -orient horizontal -font normal \
				-variable ::skating::gui(v:nbToNextRound:$round) \
				-command "skating::selection:show $round [llength $couples]"
		set scale $sub.scale
		set skating::gui(v:nbToNextRound:$round) $nb
		button $sub.valid -bd 1 -text $msg(validation) \
				-command "skating::selection:validate [list $f] $round"
		button $sub.force -bd 1 -text $msg(force) \
				-command "skating::selection:okForResult [list $f] $round 1"
		button $sub.print -bd 1 -image imgPrint -state disabled \
				-command "skating::result:quickPrint [list $f] $round heat"
		button $sub.print2 -bd 1 -image imgPrintResult -state disabled \
				-command "skating::result:quickPrint [list $f] $round heatSheet"
		button $sub.print3 -bd 1 -image imgPrintList -state disabled \
				-command "skating::result:quickPrint [list $f] $round list"
		# @OCM@: button de refresh
		if {$gui(pref:mode:linkOCM)} {
			button $sub.ocm -bd 1 -text "Promote\nin OCM" -state disabled \
					-pady 2 -width 10 -command "OCM::promote:round [list $f] [rounds:next $f $round]"
		}

		DynamicHelp::register $sub.print balloon $msg(tip:print:result1)
		DynamicHelp::register $sub.print2 balloon $msg(tip:print:result2)
		DynamicHelp::register $sub.print3 balloon $msg(tip:print:result3)
		set gui(w:validate:$round) $sub
		pack $sub.nb [frame $sub.sep1 -width 15] $sub.scale \
				[frame $sub.sep2 -width 10] $sub.valid \
				[frame $sub.sep3 -width 5] $sub.force \
				[frame $sub.sep4 -width 20] $sub.print \
				[frame $sub.sep5 -width 5] $sub.print2 \
				[frame $sub.sep6 -width 5] $sub.print3 \
				-side left -fill x -anchor s
		# @OCM@: button de refresh
		if {$gui(pref:mode:linkOCM)} {
			pack [frame $sub.sep7 -width 5] $sub.ocm -side left -fill x -anchor s
		}
		pack $sub.nb -padx 5

		#---- pour les rounds (sauf 1/2 finale + éliminatoires), assurer au moins 50%
		set next [lindex $folder(levels) [expr {1+[lsearch $folder(levels) $round]}]]
#TRACE "règle des 50% / next=$next / string match=[string match *finale $next]"
		set gui(w:prefinale:button) list
		set gui(w:prefinale:sub) [TitleFrame::getframe $tf].bottom
		set gui(w:prefinale:scale) $scale

		if {[string match "*finale" $next] == 0 && [string first "." $next] == -1} {
			# round classique, réglage du nombre à reprendre
			set sub [frame [TitleFrame::getframe $tf].bottom]
			SpinBox::create $sub.sel -label "$msg(nextRound) ($folder(round:$next:name)) : $msg(select2) " \
					-editable false -range [list 1 $max 1] \
					-bd 1 -justify right -width 2 -entrybg gray95 \
					-labelfont normal \
					-textvariable ::skating::gui(v:nbSelectNextRound:$next) \
					-modifycmd "skating::selection:check [list $f] $round"
					# -textvariable skating::${f}(round:$next:nb)
			label $sub.sel2 -font normal -text " $msg(among) "
			set ::__total 0
			label $sub.sel3 -font normal -textvariable __total
#  			set gui(t:select:$round) skating::${f}(round:$next:nb)
			set gui(t:select:$round) $next
			pack $sub.sel -side left -fill x -anchor s -padx 5 -pady 5
			pack $sub.sel2 $sub.sel3 -side left -fill x -pady 5 
			pack [TitleFrame::getframe $tf].top [TitleFrame::getframe $tf].bottom -fill x
		} elseif {[string match "*finale" $next] && $gui(pref:mode:linkOCM) == 0} {
			# gestion des pre-finales
#TRACE "gestion (pre)finale / next=$next"
			set sub [frame [TitleFrame::getframe $tf].bottom]
			if {$next == "finale" && [lsearch $folder(levels) prefinale] == -1} {
				button $sub.b -bd 1 -pady 0 -text $msg(createPreFinale) \
						-command "skating::result:prefinale:create [list $f]"
				set gui(w:prefinale:button) $sub.b
				pack $sub.b -side left -fill x -anchor s -padx 5 -pady 5
			} elseif {$next == "prefinale"} {
				result:prefinale $f $sub $scale
			}
#  			set gui(t:select:$round) skating::${f}(round:$next:nb)
			set gui(t:select:$round) $next
			pack [TitleFrame::getframe $tf].top [TitleFrame::getframe $tf].bottom -fill x
		} else {
			set gui(t:select:$round) ""
			pack [TitleFrame::getframe $tf].top -fill x
		}
		#---- mise en page
		pack $tf -fill x
	}

	if {$mode == "full" && $round == "finale"} {
		# @OCM@: button de refresh
		if {$gui(pref:mode:linkOCM)} {
			button $w.ocm -bd 1 -text "Promote in OCM" \
					-pady 2 -width 20 -command "OCM::promote:finale [list $f]"
			pack $w.ocm -side left -fill x -anchor s -padx 5 -pady 2
		}
	}
}

proc skating::result:bottomPanel:ten {f round mode w {dance {}}} {
	skating::result:bottomPanel:normal $f $round $mode $w $dance
}

proc skating::result:bottomPanel:qualif {f round mode w {dance {}}} {
variable $f
upvar 0 $f folder
variable event
variable gui
global msg

TRACEF

	#---- pour les deux, zone de texte pour commentaire libre
	set tf [TitleFrame::create $w.comment -text $msg(comment)]
	set sub [TitleFrame::getframe $tf]
    text $sub.text -width 1 -height 4 -wrap word -yscrollcommand "$sub.y set" -borderwidth 1 \
			-bg gray95 -relief sunken -selectbackground $gui(color:selection)
	scrollbar $sub.y -orient vertical -command "$sub.text yview" -bd 1
	pack $sub.text -side left -fill both -expand true
	pack $sub.y -side left -fill y
	pack $tf [frame $w.sep1 -height 20] -side bottom -fill x
	# binding pour focus & synchro variable associée
	bindEntry $sub.text "[list skating::${f}(comments:$round)]"
	if {[info exists folder(comments:$round)]} {
		$sub.text insert end $folder(comments:$round)
	}

	#---- partie basse de l'écran pour l'onglet de résultat = sélection des couples
	set tf [TitleFrame::create $w.nb -text $msg(selectionCouples)]
	set sub [frame [TitleFrame::getframe $tf].top]
	SpinBox::create $sub.nb -label "$msg(splitCouples1) " \
			-editable false -range [list 1 10 1] \
			-bd 1 -justify right -width 2 -entrybg gray95 \
			-labelfont normal \
			-textvariable ::skating::gui(v:nbSplits) \
			-modifycmd "skating::selection:split:compute [list $f]"
	label $sub.split2 -text " $msg(splitCouples2)" \
			-anchor w -font normal
	button $sub.valid -bd 1 -text $msg(validation) \
			-command "skating::selection:split:validate [list $f]"
	button $sub.force -bd 1 -text $msg(force) \
			-command "skating::selection:okForResult [list $f] $round 1"
	button $sub.print -bd 1 -image imgPrint -state disabled \
			-command "skating::result:quickPrint [list $f] $round heat"
	button $sub.print2 -bd 1 -image imgPrintResult -state disabled \
			-command "skating::result:quickPrint [list $f] $round heatSheet"
	button $sub.print3 -bd 1 -image imgPrintList -state disabled \
			-command "skating::result:quickPrint [list $f] $round list"

	set gui(w:prefinale:button) list
	set ::skating::gui(v:nbToNextRound:qualif) 1
	set ::skating::gui(v:nbSplits) [llength $folder(splitpoints)]

	DynamicHelp::register $sub.print balloon $msg(tip:print:result1)
	DynamicHelp::register $sub.print2 balloon $msg(tip:print:result2)
	DynamicHelp::register $sub.print3 balloon $msg(tip:print:result3)
	set gui(w:validate:$round) $sub
	pack $sub.nb $sub.split2 \
            [frame $sub.sep2 -width 5] $sub.valid \
			[frame $sub.sep3 -width 5] $sub.force \
            [frame $sub.sep4 -width 20] $sub.print \
			[frame $sub.sep5 -width 5] $sub.print2 \
			[frame $sub.sep6 -width 5] $sub.print3 \
			-side left -fill x -anchor s

	set sub [frame [TitleFrame::getframe $tf].bottom]
	entry $sub.limits -textvariable skating::${f}(splitpoints)
	button $sub.adjust -bd 1 -text $msg(splitAdjust) \
			-command "skating::selection:split:show [list $f]"
	pack $sub.limits $sub.adjust -side left -fill x -pady 3 -padx 5

	#---- mise en page
	pack [TitleFrame::getframe $tf].top -fill x
	pack [TitleFrame::getframe $tf].bottom -fill x
	pack $tf -fill x
}

proc skating::result:quickPrint {f round mode} {
variable $f
upvar 0 $f folder
variable gui

TRACEF

	#---- sauve contexte
	set oldRound $gui(v:round)
	set oldSize $gui(pref:print:heats:size)
	set oldType $gui(pref:print:heats:type)
	set oldMode $gui(pref:print:heats:mode)
	set oldList $gui(pref:print:heats:lists)
	set oldSheets $gui(pref:print:heats:withSheets)
	set oldJudges $gui(pref:print:enrollment:judges)
	set oldDances $gui(pref:print:enrollment:dances)
	set oldSelect $gui(pref:print:enrollment:select)


	#---- print la liste des heats pour le round suivant
	#     (pour directeur technique sans feuilles pour les juges)
	set next [lindex $folder(levels) [expr {1+[lsearch $folder(levels) $round]}]]
	set gui(v:round) $next
	set ten 0
	set subten 0
	if {$gui(v:folder) != "" && [string first "." $gui(v:folder)] != -1} {
		set subten 1
	} elseif {$gui(v:folder) != "" && $folder(mode) == "ten"} {
		set ten 1
	}
	set gui(v:ten) $ten
	set gui(v:subten) $subten
	# défaut pour heats
	if {[info exists folder(heats:$gui(v:round):size)]} {
		set skating::gui(pref:print:heats:size) $folder(heats:$gui(v:round):size)
	}
	if {[info exists folder(heats:$gui(v:round):type)]} {
		set skating::gui(pref:print:heats:type) $folder(heats:$gui(v:round):type)
	}
	if {[info exists folder(heats:$gui(v:round):grouping)]} {
		set skating::gui(pref:print:heats:grouping) $folder(heats:$gui(v:round):couples)
	}
	# affichage des listes pour les juges + danses
	if {$subten} {
		set skating::gui(pref:print:heats:lists) 1
	} else {
		set skating::gui(pref:print:heats:lists) 3
	}
	set gui(t:label) "$folder(label)"
	if {$mode == "heatSheet"} {
		set gui(pref:print:heats:withSheets) 1
	} else {
		set gui(pref:print:heats:withSheets) 0
	}

	#---- impression sans fenêtre : création du contexte
	set gui(v:print:updateDisplay) 0
	destroy .preview
	frame .preview
	set gui(w:preview:root) .preview
	print:ps:setup
	progressBarInit "" "" "" 1
	# impression proprement dite
	if {![info exists folder(dances:$next)]} {
		set folder(dances:$next) $folder(dances)
	}

	#==== fonction du mode (heat / heat+sheet / liste)
	if {$mode == "heat" || $mode == "heatSheet"} {
		#---- Heats
		set gui(pref:print:what) $gui(pref:print:sheetsMode)
		scan $gui(pref:print:sheetsMode) "sheets:round:%s" type
		print:$gui(pref:print:format):marksSheets $f $next $type
		set gui(v:print:from) 1
		set gui(v:print:to) [llength $gui(v:print:pages)]
#		print:toFile
		print:toPrinter

	} else {
		#---- Liste
		set ::enrollment(use:$f) 1
		set ::enrollment(round:$f) $folder(round:$next:name)
		set gui(pref:print:enrollment:judges) 1
		set gui(pref:print:enrollment:select) 1
		set gui(pref:print:enrollment:dances) 1
		set gui(pref:print:what) "event:enrollment:competitions"
		print:$gui(pref:print:format):enrollment:competitions [list $f]
		set gui(v:print:from) 1
		set gui(v:print:to) [llength $gui(v:print:pages)]
#		print:toFile
		print:toPrinter
	}

	#---- restaure contexte (.preview est détruite par print:to(File|Printer) )
	set gui(v:round) $oldRound
	set gui(pref:print:heats:size) $oldSize
	set gui(pref:print:heats:type) $oldType
	set gui(pref:print:heats:mode) $oldMode
	set gui(pref:print:heats:lists) $oldList
	set gui(pref:print:heats:withSheets) $oldSheets
	set gui(pref:print:enrollment:judges) $oldJudges
	set gui(pref:print:enrollment:dances) $oldDances
	set gui(pref:print:enrollment:select) $oldSelect
}

#-------------------------------------------------------------------------------------------------

proc skating::result:prefinale:remove {f {round ""}} {
variable $f
upvar 0 $f folder
global msg
variable gui

#TRACEF

	if {[lsearch $folder(levels) prefinale] == -1 || [string match "*finale" $round]} {
#TRACE "nothing to do"
		return
	}

	set folder(levels) [lreplace $folder(levels) end-1 end-1]
#TRACE "new levels = $folder(levels)"

	set folder(round:prefinale:use) 0
	unset folder(judges:prefinale)

	# mise à jour affichage (tree)
#TRACE "mise à jour tree / $f"
	if {[string first "." $f] != -1} {
		# dix-danses = notebook
		NoteBook::delete $gui(w:notebook) prefinale
	} else {
		# normal = tree sur la gauche
		Tree::delete $gui(w:tree) $f.prefinale
	}
	manage:rounds:adjustTreeColor $f

	#---- mise à jour locale, si semi ----
	if {$round == "semi"} {
#TRACE "mise à jour bottom panel"
		# recupère les paramètres
		set sub $gui(w:prefinale:sub)
		set scale $gui(w:prefinale:scale)
		# bouton pour création de pre-finale
		button $sub.b -bd 1 -pady 0 -text $msg(createPreFinale) \
				-command "skating::result:prefinale:create [list $f]" \
				-state disabled
		set gui(w:prefinale:button) $sub.b
		# détruit le spinbox, pack le bouton
#TRACE "mise à jour spin+bouton"
		destroy $sub.sel $sub.sel2 $sub.sel3
		pack $sub.b -side left -fill x -anchor s -padx 5 -pady 5
	}
}

proc skating::result:prefinale:create {f} {
variable $f
upvar 0 $f folder
global msg
variable gui

	# vérifie si impact sur la suite et demande confirmation
	if {[selection:check $f semi] == 0} {
		return
	}

	# recupère les paramètres
	set sub $gui(w:prefinale:sub)
	set scale $gui(w:prefinale:scale)

	# crée la pre-finale
	set folder(levels) [linsert $folder(levels) end-1 prefinale]

	set folder(round:prefinale:use) 1
	set folder(round:prefinale:split) 0
	set folder(round:prefinale:nb) $folder(round:semi:nb)
	set folder(round:prefinale.2:nb) 0
	set folder(round:prefinale:name) $msg(round:prefinale)

	set folder(judges:prefinale) $folder(judges:semi)

	# faux bouton pour normal/disabled
	set gui(w:prefinale:button) list

	# mise à jour affichage (tree)
#TRACE "mise à jour tree"
	if {[string first "." $f] != -1} {
		# dix-danses = notebook
		set index [NoteBook::index $gui(w:notebook) finale]
		NoteBook::insert $gui(w:notebook) $index prefinale \
				-text $folder(round:prefinale:name) \
				-state disabled \
				-raisecmd  "skating::ten:init:round [list $f] [list $gui(v:dance)] prefinale; \
							skating::fastentry:deselectAll; \
							skating::fastentry:mode prefinale; \
							set skating::gui(v:round) prefinale; \
							set skating::gui(v:judge) -1"
	} else {
		# normal = tree sur la gauche
		set index [Tree::index $gui(w:tree) $f.finale]
		Tree::insert $gui(w:tree) $index $f $f.prefinale -data "round prefinale" \
				-text $folder(round:prefinale:name) -image imgRound
	}
	manage:rounds:adjustTreeColor $f

	# mise à jour affichage (local, selection des couples à garder pour la finale)
#TRACE "mise à jour locale"
	result:prefinale $f $sub $scale
}

proc skating::result:prefinale {f sub scale} {
variable $f
upvar 0 $f folder
variable gui
global msg


#TRACEFS

	# détruit le bouton de création
	destroy $sub.b

	# nb de couples maximum autorisé
	set nbCouples [llength $folder(couples:semi)]
	set max $nbCouples
	if {$max > 9} {
		set max 9
	}

	# zone de selection des couples à reprendre pour la finale dans la pre-finale
	SpinBox::create $sub.sel -label "$msg(nextRound) ($folder(round:prefinale:name)) : $msg(select2) " \
			-editable false -range [list 1 $max 1] \
			-bd 1 -justify right -width 2 -entrybg gray95 \
			-labelfont normal \
			-textvariable skating::${f}(round:prefinale:nb) \
			-modifycmd "skating::selection:check [list $f] semi"

	label $sub.sel2 -font normal -text " $msg(among) "
	set ::__total 0
	label $sub.sel3 -font normal -textvariable __total
#	set gui(t:select:semi) skating::${f}(round:prefinale:nb)
	set gui(t:select:semi) prefinale
	pack $sub.sel -side left -fill x -anchor s -padx 5 -pady 5
	pack $sub.sel2 $sub.sel3 -side left -fill x -pady 5 

	# ajuste le scale pour permettre une selection plus "large"
#TRACE "configure scale max to $nbCouples"
	$scale configure -to $nbCouples
	# affiche selection & update '__total' (via appel à selection:show)
	selection:display $f semi
}


#=================================================================================================
#
#	Affichage des résultats globaux sur une compétition (ou une dance en mode 10 danses)
#
#=================================================================================================

proc skating::results:init {f w {dance ""}} {
global msg
variable gui
variable event


#puts "skating::results:init {'$f' $w '$dance'}"

	set sw [ScrolledWindow::create $w.sw \
				-scrollbar both -auto both -relief sunken -borderwidth 1]
	set c [canvas [ScrolledWindow::getframe $sw].c -highlightthickness 0 -bg gray95 -height 1]
	ScrolledWindow::setwidget $sw $c 1
	set tophead [canvas [ScrolledWindow::getframe $sw].t -highlightthickness 0 -bg gray95 -height 1]
	set lefthead [canvas [ScrolledWindow::getframe $sw].l -highlightthickness 0 -bg gray95 -width 1]
	set toplefthead [canvas [ScrolledWindow::getframe $sw].tl -highlightthickness 0 -bg gray95 -width 1 -height 1]
	set gui(w:results:$dance) $sw
	set gui(w:results:topheader:$dance) $tophead
	set gui(w:results:leftheader:$dance) $lefthead
	set gui(w:results:topleftheader:$dance) $toplefthead

	# choix du mode (liste globale ou détails par couples)
	set ff [frame $w.b -relief groove -bd 2]
		# ancien mode sauvegardé
		if {[info exists gui(v:result:$dance)]} {
			set what $gui(v:result:$dance)
		} else {
			set what "simple"
		}
		# radio boutons pour le mode
		radiobutton $ff.1 -text $msg(result:simple) -bd 1 -value simple \
				-variable ::skating::gui(v:result:$dance) -command "skating::results:draw [list $f] $c [list $dance]"
		radiobutton $ff.2 -text $msg(result:extended:place) -bd 1 -value extended_place \
				-variable ::skating::gui(v:result:$dance) -command "skating::results:draw [list $f] $c [list $dance]"
		radiobutton $ff.3 -text $msg(result:extended:couple) -bd 1 -value extended_couple \
				-variable ::skating::gui(v:result:$dance) -command "skating::results:draw [list $f] $c [list $dance]"
		pack $ff.1 $ff.2 $ff.3 -side left -padx 5 -pady 5
		# init le mode
#puts "---- set ::skating::gui(v:result:$dance) '$what' / [info exists gui(v:result:$dance)]"
		set ::skating::gui(v:result:$dance) $what
	# mise en page
	pack $sw -side top -pady 5 -expand true -fill both
	pack $ff -side top -pady 5 -fill x
	# binding pour scrolling des canvas
	bind $c <Configure> {
		set limits [%W bbox all]
		set x [expr {[lindex $limits 2]+10}]
		set y [expr {[lindex $limits 3]+10}]
		if {$x < %w} { set x %w }
		if {$y < %h} { set y %h }
		%W configure -scrollregion [list 0 0 $x $y]
		[winfo parent %W].t configure -scrollregion [list 0 0 $x 0]
		[winfo parent %W].l configure -scrollregion [list 0 0 0 $y]
	}
	bind $c <Visibility> "focus $c"

	# mise à jour affichage
	skating::results:draw $f $c $dance
}

#----------------------------------------------------------------------------------------------

proc skating::results:check {f} {
variable $f
upvar 0 $f folder
variable gui


#puts "skating::results:check {$f}"
	if {[llength [array names folder couples:finale*]] && [class:dances $f]} {
		set state normal
		set bg #adf3b1
		set abg #b6ffba
	} elseif {$folder(mode) == "qualif" && []} {
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

	NoteBook::itemconfigure $gui(w:notebook) "results" -state $state \
			-background $bg -selectedbackground $bg -activebackground $abg
}

#----------------------------------------------------------------------------------------------

proc skating::results:draw {f c dance} {
variable $f
upvar 0 $f folder
variable gui

	# effectue le classement
	set result [class:folder $f]

	# affichage adapté à chaque mode
	$c delete all
	results:draw:$gui(v:result:$dance) $f $c $dance
}

proc skating::results:draw:simple {f c dance} {
variable $f
upvar 0 $f folder
variable event
variable gui
global msg
upvar result result


#puts "skating::results:draw:simple {$f $c}"
	# variables - init
	set nb [llength $result]
	set xmin 10
	set y 10
	set spaceX 10
	set hBold 20
	set hNormal 20
	set wC 50
	set wP 50
	set wN 395
	set wB 50
	set left $xmin

	# mise à jour header
	catch { ScrolledWindow::unheader $gui(w:results:topleftheader:$dance) }
	catch { ScrolledWindow::unheader $gui(w:results:leftheader:$dance) }
	ScrolledWindow::header $gui(w:results:$dance) $gui(w:results:topheader:$dance) top

	# affichage
	#---- header
	set ch  $gui(w:results:topheader:$dance)
	$ch delete all
	$ch configure -height [expr $y+$hNormal+1]
	$ch create rectangle $left $y [expr $left+$wC] [expr $y+$hNormal] \
			-fill $gui(color:yellow) -outline black
	$ch create text [expr $left+$wC/2] [expr $y+$hNormal/2+1] -text $msg(place) -font canvas:label

	$ch create rectangle [expr $left+$wC] $y [expr $left+$wC+$wP] [expr $y+$hNormal] \
			-fill $gui(color:yellow) -outline black
	$ch create text [expr $left+$wC+$wP/2] [expr $y+$hNormal/2+1] -text $msg(Couple) -font canvas:label

	$ch create rectangle [expr $left+$wC+$wP] $y [expr $left+$wC+$wP+$wN] [expr $y+$hNormal] \
			-fill $gui(color:yellow) -outline black
	$ch create text [expr $left+$wC+$wP+$spaceX] [expr $y+$hNormal/2+1] -text $msg(name) \
			-anchor w -font canvas:label

	$ch create rectangle [expr $left+$wC+$wP+$wN] $y [expr $left+$wC+$wP+$wN+$wB] [expr $y+$hNormal] \
			-fill $gui(color:yellow) -outline black
	$ch create text [expr $left+$wC+$wP+$wN+$wB/2] [expr $y+$hNormal/2+1] -text $msg(best) \
			-font canvas:label
	#---- data
	set y -1
	foreach item $result {
		set couple [lindex $item 0]
		set min [lindex $item 1]
		set round [lindex $item 2]
		set max [lindex $item 3]
		set place [lindex $item 4]
		#---- un couple
		if {$gui(pref:print:placeAverage)} {
			set text $place
		} elseif {$min != $max} {
			set text "$min-$max"
		} else {
			set text $min
		}
		$c create rectangle $left $y [expr $left+$wC] [expr $y+$hNormal] \
				-fill $gui(color:lightyellow) -outline black
		$c create text [expr $left+$wC/2] [expr $y+$hNormal/2+1] -text $text -font canvas:label

		$c create rectangle [expr $left+$wC] $y [expr $left+$wC+$wP] [expr $y+$hNormal] \
				-outline black
		$c create text [expr $left+$wC+$wP/2] [expr $y+$hNormal/2+1] -text $couple -font canvas:place

		$c create rectangle [expr $left+$wC+$wP] $y [expr $left+$wC+$wP+$wN] [expr $y+$hNormal] \
				-outline black
		$c create text [expr $left+$wC+$wP+$spaceX] [expr $y+$hNormal/2+1] -text [couple:name $f $couple] \
				-anchor w -font canvas:place

		$c create rectangle [expr $left+$wC+$wP+$wN] $y [expr $left+$wC+$wP+$wN+$wB] [expr $y+$hNormal] \
				-outline black
		if {!$folder(round:explicitNames)} {
			set index [expr [llength $folder(levels)]-[lsearch $folder(levels) $round]-1]
#puts "<skating::rounds:getName> index = $index / $round / '$folder(levels)'"
			set round [lindex {finale semi quarter eight 16 32 64 128 256 512 1024} $index]
		}
		$c create text [expr $left+$wC+$wP+$wN+$wB/2] [expr $y+$hNormal/2+1] \
				-text $msg(round:short:$round) -font canvas:place

		# suivant
		incr y $hNormal
	}

	# bindings
	bind $c <Up> "$c yview scroll -1 units"
	bind $c <Down> "$c yview scroll +1 units"
	bind $c <Prior> "$c yview scroll -1 pages"
	bind $c <Next> "$c yview scroll +1 pages"
	bind $c <Left> "$c xview scroll -1 units"
	bind $c <Right> "$c xview scroll +1 units"
	bind $c <Home> "$c xview scroll -1 pages"
	bind $c <End> "$c xview scroll +1 pages"
}

proc skating::results:draw:extended_place {f c dance} {
variable $f
upvar 0 $f folder
variable event
variable gui
global msg
upvar result result


#TRACEF

	# variables - init
	set nb [llength $folder(couples:all)]
	set spaceX 10
	set spaceY 10
	set hBold 20
	set hSmall 16
	set hNormal 20
	set hMedium 25
	set wC 50
	set wR 30
	set wP 70
	set wN 200
	set wL 30
	set wB 50

	# liste des danses en fonction du mode
#  	if {$folder(mode) == "ten"} {
#  		set dances [list $dance]
#  	} else {
		set dances $folder(dances)
		set folder(dances:finale) $folder(dances)
#	}

	# calcule la taille des marks pour chaque danse
	results:computeJudgesSizes $dances 14 20

	#=====================
	# place pour le header
#puts "---- drawing header"
	set ctl $gui(w:results:topleftheader:$dance)
	$ctl delete all
	ScrolledWindow::header $gui(w:results:$dance) $ctl topleft
	$ctl configure -height [expr $spaceY+$hMedium+$hNormal+1]
	set id_topleft [$ctl create line [expr $spaceX+$wC+$wN+$wL] $spaceY \
				[expr $spaceX+$wC+$wN+$wL] [expr $spaceY+$hMedium+$hNormal+1] -tags move]
	$ctl create line $spaceX [expr $spaceY+$hMedium+$hNormal] \
			[expr $spaceX+$wC+2*$wN+$wL+1] [expr $spaceY+$hMedium+$hNormal]

	set ct $gui(w:results:topheader:$dance)
	ScrolledWindow::header $gui(w:results:$dance) $ct top
	$ct configure -height [expr $spaceY+$hMedium+$hNormal+1]
	$ct delete all
		# calcule la liste des juges
		set judges [list ]
		foreach round $folder(levels) {
			foreach j $folder(judges:$round) {
				if {[lsearch $judges $j] == -1} {
					lappend judges $j
				}
			}
		}
		set judges [lsort -command skating::event:judges:sort $judges]
#puts "---- judges = $judges"
		set nbJ [llength $judges]
		# pour chaque danse
		set x -1
		foreach d $dances {
			set y $spaceY
			$ct create rectangle $x $y [expr $x + $wJ($d)+$wR] [expr $y+$hMedium] \
					-fill $gui(color:yellow)
			$ct create text [expr $x + ($wJ($d)+$wR)/2] [expr $y+$hMedium/2+1] \
					-text [firstLetters $d] -font canvas:medium
			# les juges
			set xx $x
			incr y $hMedium
			foreach j $judges {
				$ct create rectangle $xx $y [expr $xx+$wJ($d:$j)] [expr $y+$hNormal] \
						-fill $gui(color:lightyellow)
				$ct create text [expr $xx + $wJ($d:$j)/2] [expr $y+$hNormal/2+1] \
						-text $j -font canvas:label
				incr xx $wJ($d:$j)
			}
			$ct create rectangle $xx $y [expr $xx+$wR] [expr $y+$hNormal] \
					-fill $gui(color:lightyellow)
			$ct create text [expr $xx + $wR/2] [expr $y+$hNormal/2+1] \
					-text "Re" -font canvas:label
			# suivante
			incr x [expr {$wJ($d)+$wR}]
		}
		# le classement global
		set y $spaceY
		$ct create rectangle $x $y [expr $x+$wP] [expr $y+$hMedium+$hNormal] \
				-fill $gui(color:yellow)
		$ct create text [expr $x+$wP/2] [expr $y+($hMedium+$hNormal)/2+1] \
				-text "Place" -font canvas:medium
		incr x $wP

	#=================================================
	# header pour nom des couples sur la partie gauche
	set cl $gui(w:results:leftheader:$dance)
	$cl delete all
	ScrolledWindow::header $gui(w:results:$dance) $cl left
	$cl configure -width [expr $spaceX+$wC+$wN+$wL+1]
	$gui(w:results:topleftheader:$dance) configure -width [expr $spaceX+$wC+$wN+$wL+1]
	# partie principale
	set y -1
	foreach item $result {
		set couple [lindex $item 0]
		set min [lindex $item 1]
		set round [lindex $item 2]
		set max [lindex $item 3]
		set place [lindex $item 4]
		set x $spaceX
		# taille du cadre suivant nb de rounds
		set nb [expr [lsearch $folder(levels) $round]+1]
		set rounds [reverse [lrange $folder(levels) 0 [lsearch $folder(levels) $round]]]
		foreach r $rounds {
			if {[lsearch $folder(couples:$r) $couple] == -1} {
				incr nb -1
			}
		}
		if {$nb < 2} {
			set nb 2
		}
#puts "---- $couple / $round, $nb"
		#---- numéro du couple
		$cl create rectangle $x $y [expr $x+$wC] [expr $y+$nb*$hSmall] \
					-fill $gui(color:lightyellow)
		$cl create text [expr $x+$wC/2] [expr $y+($nb*$hSmall)/2+1] \
					-text $couple -font canvas:big
		incr x $wC
		#---- nom et école
		$cl create rectangle $x $y [expr $x+2*$wN] [expr $y+$nb*$hSmall]
		$cl create text [expr $x+5] [expr $y+$hSmall/2+1] -anchor w \
					-text [couple:name $f $couple] -font canvas:label
		$cl create text [expr $x+5] [expr $y+$hSmall*3/2+1] -anchor w \
					-text [couple:school $f $couple] -font canvas:place
		incr x $wN
		#---- rounds
		$cl create rectangle $x $y [expr $x+2*$wN] [expr $y+$nb*$hSmall] \
				-tags move -fill [$c cget -bg]
		set yy [expr $y+$hSmall/2+1]
		set xx [expr $x+$wL/2]
		foreach round $rounds {
			if {[lsearch $folder(couples:$round) $couple] == -1} {
				continue
			}
			$cl create text $xx $yy -tags move \
						-text $msg(round:short:$round) -font canvas:place
			incr yy $hSmall
		}
		#---- les résultats
		set x -1
		foreach d $dances {
			# dessine un rectangle de séparation
			$c create rectangle $x $y [expr $x+$wJ($d)+$wR] [expr $y+($nb*$hSmall)]
			set yy $y
			# pour chaque round
			foreach round $rounds {
				set preQualif [isPrequalified $f $couple $round]
				# si le couple n'a pas dansé le round (repéchage)
				if {[lsearch $folder(couples:$round) $couple] == -1} {
#TRACE "    redance -- continue // $i"
					continue
				}
				# trouve l'index de cette danse pour le round
				# (des dances ont pu être skippées)
				set i [lsearch $folder(dances:$round) $d]
				# -------------
				set data [list ]
				if {$round != "finale" && [lsearch $folder(dances:$round) $d] == -1} {
#TRACE "$couple / $d / $round // skipped dance"
					# danse non prise en compte
					foreach judge $judges {
						if {[lsearch $folder(judges:$round) $judge] == -1} {
							lappend data ""
						} elseif {$preQualif} {
							lappend data "+"
						} else {
							lappend data "-"
						}
					}
					if {$preQualif} {
						set dataRes "+"
					} else {
						set dataRes ""
					}
					set font canvas:place

				} elseif {$round == "finale"} {
#TRACE "$couple / $d / $round // finale"
					# une FINALE
					foreach judge $judges {
						set j [lsearch $folder(judges:$round) $judge]
						if {$j == -1} {
							lappend data ""
						} else {
							set note [lindex $folder(notes:finale:$couple:$d) $j]
							if {[expr {int($note)}] == $note} {
								set note [expr {int($note)}]
							}
							lappend data $note
						}
					}
					# la place dans la danse
					set dataRes [lindex $folder(places:$couple) $i]
					set font canvas:label

				} else {
#TRACE "$couple / $d / $round // round"
					# un ROUND classique
					foreach judge $judges {
						set j [lsearch $folder(judges:$round) $judge]
						if {$j == -1} {
							lappend data ""
						} elseif {[lindex $folder(notes:$round:$couple:$d) $j]} {
							if {$preQualif} {
								lappend data "+"
							} elseif {$gui(pref:print:useLetters)} {
								lappend data $judge
							} else {
								lappend data "X"
							}
						} else {
							lappend data "."
						}
					}
					# le sous-total
#  					if {$folder(mode) == "ten"} {
#  						set result result:$round:$d
#  					} else {
						set result result:$round
#  					}
					foreach item $folder($result) {
						if {[lindex $item 0] == $couple} {
							break
						}
					}
					if {$preQualif} {
						set dataRes "+"
					} else {
#TRACE "    dataRes / $item // $i"
						set dataRes [lindex $item [expr 2+$i]]
					}
					set font canvas:place
				}
				# affichage
				results:draw:extended_place:draw $font

				# round suivant
				incr yy $hSmall
			}

			# danse suivante
			incr x [expr {$wJ($d)+$wR}]
		}
		#---- la place globale
		if {$gui(pref:print:placeAverage)} {
			set text $place
		} elseif {$min != $max} {
			set text "$min-$max"
		} else {
			set text $min
		}
		$c create rectangle $x $y [expr $x+$wP] [expr $y+$nb*$hSmall]
		$c create text [expr $x+$wP/2] [expr $y+($nb*$hSmall)/2+1] \
					-text $text -font canvas:big

		# suivant
		incr y [expr $nb*$hSmall]
	}

	#=================
	# line pour resize
	set id_left [$cl create line [expr $spaceX+$wC+$wN+$wL] 0 [expr $spaceX+$wC+$wN+$wL] $y -tags move]
	results:resize:init [expr $spaceX+$wC+$wL-1] [expr $spaceX+$wC+2*$wN] \
			$gui(w:results:topleftheader:$dance) $id_topleft $spaceY [expr $spaceY+$hMedium+$hNormal+1] \
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
}

proc skating::results:draw:extended_place:draw {font} {
upvar data data dataRes dataRes judges judges
upvar c c x x yy yy hSmall hSmall wJ wJ wR wR d d

	set xx $x
	foreach text $data j $judges {
#		$c create rectangle $xx $yy [expr $xx+$wJ($d:$j)] [expr $yy+$hSmall]
		if {$text != ""} {
			$c create text [expr $xx + $wJ($d:$j)/2] [expr $yy+$hSmall/2+1] \
					-text $text -font canvas:place
		}
		incr xx $wJ($d:$j)
	}
#	$c create rectangle $xx $yy [expr $xx+$wR] [expr $yy+$hSmall]
	if {$dataRes != ""} {
		$c create text [expr $xx + $wR/2] [expr $yy+$hSmall/2+1] \
				-text $dataRes -font $font
	}
}


proc skating::results:draw:extended_couple {f c dance} {
upvar result result

#puts "skating::results:draw:extended_couple {$f $c}"
	set result [lsort -integer -index 0 $result]
	results:draw:extended_place $f $c $dance
}


#----------------------------------------------------------------------------------------------

proc skating::results:resize:init {xmin xmax c1 id1 y11 y12 c2 id2 y21 y22} {
	$c1 bind $id1 <Enter> "$c1 configure -cursor sb_h_double_arrow"
	$c1 bind $id1 <Leave> "$c1 configure -cursor {}"

	$c2 bind $id2 <Enter> "$c2 configure -cursor sb_h_double_arrow"
	$c2 bind $id2 <Leave> "$c2 configure -cursor {}"


	foreach c [list $c1 $c2] id [list $id1 $id2] {
		$c bind $id <ButtonPress-1> "set __x \[$c1 cget -width\]; incr __x -1"
		$c bind $id <B1-Motion> "
			if {%x > $xmin && %x < $xmax} {
				$c1 configure -width \[expr {%x+1}\]
				$c2 configure -width \[expr {%x+1}\]
				set dx \[expr {%x - \$__x}\]
				$c1 move move \$dx 0
				$c2 move move \$dx 0
				set __x %x
			}
		"
	}
}

#==============================================================================================

proc skating::results:computeJudgesSizes {dances wJ1 wJ2 {var folder}} {
upvar $var folder wJ wJ

	# calcule la taille des marks pour chaque danse
	foreach d $dances {
		# init à taille mini
		foreach round $folder(levels) {
			foreach judge $folder(judges:$round) {
				set wJ($d:$judge) $wJ1
			}
		}
		# liste de couples en finale
		set couples $folder(couples:finale)
		set ok 0
		foreach couple $couples {
			foreach note $folder(notes:finale:$couple:$d) judge $folder(judges:finale) {
				if {[expr {int($note)}] != $note} {
					set wJ($d:$judge) $wJ2
				}
			}
		}
		foreach round $folder(levels) {
			foreach judge $folder(judges:$round) {
				if {[string length $judge] > 1} {
					set wJ($d:$judge) $wJ2
				}
			}
		}
		# calcul taille total pour la danse
		set wJ($d) 0
		foreach item [array names wJ $d:*] {
			incr wJ($d) $wJ($item)
		}
	}
}
