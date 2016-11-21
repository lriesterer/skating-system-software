##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#==============================================================================================
#
#	Gestion des paramétrages utilisateurs (préferences & options)
#
#==============================================================================================

proc skating::gui:options {{raise general}} {
global msg

	# dialogue pour réglage des préférences
	if {[winfo exists .settings]} {
		raise .settings
		return
	}
	set w [toplevel .settings]
	wm title $w $msg(setting)

	# un notebook pour les différentes catégories
	if {$::tcl_platform(platform) == "windows"} {
		set h 455
	} else {
		set h 400
	}
	set notebook [NoteBook::create $w.nb -width 700 -height $h]
	foreach tab {general colors rounds print print2 attributes dances templates database language} {
		set t [NoteBook::insert $notebook end $tab -text $msg(options:$tab)]
		NoteBook::itemconfigure $notebook $tab -createcmd "skating::options:$tab $t"
	}
	pack $notebook -expand true -fill both

	# fin init
	set ::__rebuildAttributes 0

	# frame des boutons
	set but [frame $w.but -bd 1 -relief raised]
	  button $but.ok -text $msg(dlg:ok) -underline 0 -bd 1 -width 7 \
			-command "skating::options:finalize; destroy $w" -default active
	  button $but.def -text $msg(dlg:saveAsDefault) -bd 1 \
			-command "skating::options:save"
	  button $but.save -text $msg(save) -bd 1 \
			-command "skating::options:save 1"
	  button $but.load -text $msg(load) -bd 1 \
			-command "skating::options:load"
	  grid $but.ok [frame $but.sep -width 20] $but.def $but.save $but.load -sticky ew -padx 5 -pady 5
	pack $but -fill x -anchor c -side bottom

	# bindings
	bind $w <Alt-o> "skating::options:finalize; destroy $w"
	bind $w <Return> "skating::options:finalize; destroy $w"
	bind $w <Escape> "skating::options:finalize; destroy $w"

	# ajuste position de la boite de dialogue
	centerDialog .top $w
	# affiche un tab particulier si spécifié
	NoteBook::raise $notebook $raise
}

proc skating::options:finalize {} {
variable gui

	$gui(w:labelround) configure -fg $gui(color:competition)
	# reconstruit la liste des templates
	manage:dances:buildTemplates
	# gestion de la sauvegarde automatique
	gui:save:initAutosave
	# reconstruit les liste d'attributs (si nécessaire)
	if {$::__rebuildAttributes} {
		options:attributes:rebuild
	}
	# valide les données en cours d'édition dans les tables (si besoin)
	catch {
		options:templates:setData 0
	}
}

#----------------------------------------------------------------------------------------------
#	Pour impression = préférences  +  papier/fontes
#----------------------------------------------------------------------------------------------

proc skating::options:print {w} {
global msg
variable gui

	# details
	set details [frame $w.details]
		#---- general
		set d1 [TitleFrame::create $details.1 -text $msg(detailLevel1)]
		set sub [TitleFrame::getframe $d1]
		checkbutton $sub.color -bd 1 -text $msg(detail:color) \
					-variable skating::gui(pref:print:color)
		checkbutton $sub.com -bd 1 -text $msg(detail:comment) \
					-variable skating::gui(pref:print:comment)
		checkbutton $sub.listc -bd 1 -text $msg(detail:listCouples) \
					-variable skating::gui(pref:print:listCouples)
		checkbutton $sub.listj -bd 1 -text $msg(detail:listJudges) \
					-variable skating::gui(pref:print:listJudges)
		checkbutton $sub.sign -bd 1 -text $msg(detail:sign) \
					-variable skating::gui(pref:print:sign)
		checkbutton $sub.letters -bd 1 -text $msg(detail:useLetters) \
					-variable skating::gui(pref:print:useLetters)
		checkbutton $sub.average -bd 1 -text $msg(detail:useAverage) \
					-variable skating::gui(pref:print:placeAverage)
#		scale $sub.skip -variable skating::gui(pref:print:skipY) -from 20 -to 50 -orient horizontal
		pack $sub.color $sub.com $sub.listc $sub.listj \
			 $sub.sign $sub.letters $sub.average -side top -anchor w -padx 5
		#----
		set d2 [TitleFrame::create $details.2 -text $msg(detailLevel2)]
		set sub [TitleFrame::getframe $d2]
		checkbutton $sub.nj -bd 1 -text $msg(detail:judges) \
					-variable skating::gui(pref:print:names:judges)
		checkbutton $sub.order -bd 1 -text $msg(detail:order) \
					-variable skating::gui(pref:print:order:rounds)
		checkbutton $sub.njr -bd 1 -text $msg(detail:judgesResult) \
					-variable skating::gui(pref:print:names:judgesResult)
		checkbutton $sub.ncr -bd 1 -text $msg(detail:couplesResult) \
					-variable skating::gui(pref:print:names:couplesResult)
		checkbutton $sub.font -bd 1 -text $msg(detail:useSmallFont) \
					-variable skating::gui(pref:print:useSmallFont)
		checkbutton $sub.rule -bd 1 -text $msg(detail:explain) \
					-variable skating::gui(pref:print:explain)
		# place + nb to print
		checkbutton $sub.place -bd 1 -text $msg(detail:place) \
					-variable skating::gui(pref:print:place)
		SpinBox::create $sub.spin -label "$msg(detail:place:nb) " \
					-editable false -range {1 9 1} -width 1 -entrybg gray95 \
					-textvariable skating::gui(pref:print:place:nb) \
                    -selectbackground $gui(color:selection) -labelfont event:data
		pack $sub.nj $sub.order $sub.njr $sub.ncr $sub.font $sub.rule -side top -anchor w -padx 5
		pack $sub.place -side top -anchor w -padx 5
		pack [frame $sub.sep -width 50] $sub.spin -side left -anchor w -padx 5
	pack $d1 -fill both
	pack $d2 -fill both -side bottom

	# mode par défault pour les feuilles de marks
	set mode [TitleFrame::create $w.mode -text $msg(marksSheetsMode)]
	set sub [TitleFrame::getframe $mode]
		# nombre par page
		label $sub.l -text $msg(markSheetsLayout)
		radiobutton $sub.1 -bd 1 -text "1 / $msg(portrait)" -value sheets:round:portrait1 \
				-variable skating::gui(pref:print:sheetsMode) -font normal
		radiobutton $sub.2 -bd 1 -text "1 / $msg(landscape)" -value sheets:round:landscape1 \
				-variable skating::gui(pref:print:sheetsMode) -font normal
		radiobutton $sub.3 -bd 1 -text "2 / $msg(portrait)" -value sheets:round:portrait2 \
				-variable skating::gui(pref:print:sheetsMode) -font normal
		radiobutton $sub.4 -bd 1 -text "2 / $msg(landscape)" -value sheets:round:landscape2 \
				-variable skating::gui(pref:print:sheetsMode) -font normal
		radiobutton $sub.5 -bd 1 -text "4 / $msg(portrait)" -value sheets:round:portrait4 \
				-variable skating::gui(pref:print:sheetsMode) -font normal
		radiobutton $sub.6 -bd 1 -text "4 / $msg(landscape)" -value sheets:round:landscape4 \
				-variable skating::gui(pref:print:sheetsMode) -font normal
		
		# input grid
		checkbutton $sub.10 -bd 1 -text $msg(separateInputGrid) -onvalue 1 -offvalue 0 \
				-variable skating::gui(pref:print:inputGrid)
		# compact marksheet pour la finale (toutes les danses sur une feuille)
		checkbutton $sub.11 -bd 1 -text $msg(heatsCompact?2) -onvalue 1 -offvalue 0 \
				-variable skating::gui(pref:print:sheets:compact)
		# groupage des couples + taille par défaut des heats
		label $sub.20 -text $msg(heatsCouplesGrouping)
		frame $sub.21
		radiobutton $sub.21.1 -bd 1 -text $msg(heatsNumber) -font normal -value number \
				-variable skating::gui(pref:print:heats:grouping)
		radiobutton $sub.21.2 -bd 1 -text $msg(heatsAlphabetic) -font normal -value alphabetic \
				-variable skating::gui(pref:print:heats:grouping)
		radiobutton $sub.21.3 -bd 1 -text $msg(heatsRandom) -font normal -value random \
				-variable skating::gui(pref:print:heats:grouping)
		pack $sub.21.1 $sub.21.2 $sub.21.3 -side left
		SpinBox::create $sub.22 -label "$msg(heatsSizeDefault) " -editable false \
				-range {4 48 1} -bd 1 -justify right -width 2 -entrybg gray95 \
				-labelfont bold -textvariable skating::gui(pref:print:heats:size)
	  	# spare boxes pour les entrées de retardataires
		label $sub.30 -text $msg(spareBoxes)
		set sub31 [frame $sub.31 -bd 0]
			SpinBox::create $sub31.nb -label "$msg(spareBoxes1) " -editable false \
						-range {0 99 1} -bd 1 -justify right -width 2 -entrybg gray95 \
						-labelfont normal -textvariable skating::gui(pref:print:sheets:spareBoxes)
			label $sub31.l -text " $msg(spareBoxes2)" -font normal
			grid $sub31.nb $sub31.l -sticky w
		# place pour signature des feuilles par les juges
		checkbutton $sub.40 -bd 1 -text $msg(signSheets) -onvalue 1 -offvalue 0 \
				-variable skating::gui(pref:print:sheets:sign)
		# permet de ne pas imprimer la liste des heats, juste les feuilles de selection
		checkbutton $sub.45 -bd 1 -text $msg(heatsPrint?) -onvalue 1 -offvalue 0 \
				-variable skating::gui(pref:print:heats:print)
		# commencer chaque juge sur une nouvelle feuille
		checkbutton $sub.50 -bd 1 -text $msg(newSheetOnJudge) -onvalue 1 -offvalue 0 \
				-variable skating::gui(pref:print:sheets:newOnJudge)

	grid $sub.l $sub.1 $sub.2 -sticky nw -padx 5
	grid x		$sub.3 $sub.4 -sticky nw -padx 5
	grid x		$sub.5 $sub.6 -sticky nw -padx 5
	variable plugins
	foreach {label category item cmd} $plugins(print) {
		if {$category != "markSheets"} {
			continue
		}
		radiobutton $sub.$item -bd 1 -text $label -anchor w \
			-font normal \
			-variable skating::gui(pref:print:sheetsMode) -value $item
		grid x		$sub.$item - -sticky nw -padx 5
	}
	grid [frame $sub.sep9] - - -sticky nw -pady 5
	grid $sub.22 -	   -	  -sticky nw -padx 5
	grid [frame $sub.sep0] - - -sticky nw -pady 5
	grid $sub.20 - 	   -	  -sticky nw -padx 5
	grid $sub.21 -	   -	  -sticky nw -padx 5
	grid [frame $sub.sep1] - - -sticky nw -pady 5
	grid $sub.30 x		x	  -sticky nw -padx 5
	grid $sub.31 -	  	-	  -sticky nw -padx 5
	grid [frame $sub.sep2] - - -sticky nw -pady 5
	grid $sub.10 - 	   -	  -sticky nw -padx 5
	grid $sub.11 - 	   -	  -sticky nw -padx 5
	grid $sub.40 - 	   -	  -sticky nw -padx 5
	grid $sub.45 - 	   -	  -sticky nw -padx 5
	grid $sub.50 - 	   -	  -sticky nw -padx 5
	grid columnconfigure $sub {0} -weight 1
	grid columnconfigure $sub {1 2} -weight 100
	grid rowconfigure $sub {20} -weight 1

	# mise en page
	grid $details $mode -sticky news -padx 5 -pady 5
	grid rowconfigure $w {0 1} -weight 1
	grid columnconfigure $w {0 1} -weight 1
}

proc skating::options:print2 {w} {
global msg
variable gui

	# taille du papier
	set paper [TitleFrame::create $w.paper -text $msg(paper)]
	set sub [TitleFrame::getframe $paper]
	radiobutton $sub.a4 -bd 1 -text "A4" -value a4 \
			-variable skating::gui(pref:print:paper) -width 10 -anchor w
	radiobutton $sub.letter -bd 1 -text "Letter" -value letter \
			-variable skating::gui(pref:print:paper)
	radiobutton $sub.legal -bd 1 -text "Legal" -value legal \
			-variable skating::gui(pref:print:paper)
	pack $sub.a4 $sub.letter $sub.legal -side top -anchor w -padx 5

	# marges
	set margin [TitleFrame::create $w.margins -text $msg(margins)]
	set sub [TitleFrame::getframe $margin]
	foreach dir {left right top bottom} i { 1 2 3 4} {
		SpinBox::create $sub.$i -label "$msg(margin:$dir) " -labelwidth 10 \
					-range {0 99 1} -width 3 -entrybg gray95 \
					-textvariable skating::gui(pref:print:margin:$dir) \
                    -selectbackground $gui(color:selection) -justify right
	}
	message $sub.5 -text $msg(margin:text) -font normal -padx 0 -width 275 -anchor w
	pack $sub.1 $sub.2 $sub.3 $sub.4 -side top -anchor w -padx 5
	pack $sub.5 -side top -anchor w -fill x -pady 5

	# fontes
	set layout [TitleFrame::create $w.layout -text $msg(layout)]
	set sub [TitleFrame::getframe $layout]
		pack [options:font $sub print:title] -anchor w -fill x -pady 1
		pack [options:font $sub print:subtitle] -anchor w -fill x -pady 1
		pack [options:font $sub print:date] -anchor w -fill x -pady 1
		pack [options:font $sub print:comment] -anchor w -fill x -pady 1
		pack [options:font $sub print:normal] -anchor w -fill x -pady 1
		pack [options:font $sub print:bold] -anchor w -fill x -pady 1
		pack [options:font $sub print:subscript] -anchor w -fill x -pady 1
		pack [options:font $sub print:small] -anchor w -fill x -pady 1
		pack [options:font $sub print:smallbold] -anchor w -fill x -pady 1

	# user-defined formatting
	set format [TitleFrame::create $w.format -text $msg(formatting)]
	set sub [TitleFrame::getframe $format]
		set left [frame $sub.l -bd 1 -relief raised]
		set frame [frame $sub.f]
		# par défaut dans la frame un bouton pour restaurer les valeurs par défaut
		button $frame.0 -text $msg(formatRestore) -bd 1 \
				-command skating::print:format:restoreDefaults
		pack $frame.0 -anchor c -expand true

		# insère les données dans la liste
		set list [list ]
		lappend list "$msg(format:header) 1"
		lappend list "$msg(format:header) 2"
		lappend list "$msg(format:header) 3"
		lappend list "$msg(format:header) 4"
		lappend list "$msg(format:general) 1"
		lappend list "$msg(format:general) 2"
		lappend list "$msg(format:marksheet:portrait:header) 1"
		lappend list "$msg(format:marksheet:portrait:header) 2"
		lappend list "$msg(format:marksheet:portrait:footer)"
		lappend list "$msg(format:marksheet:landscape:data) 1"
		lappend list "$msg(format:marksheet:landscape:data) 2"
		lappend list "$msg(format:marksheet:landscape:header) 1"
		lappend list "$msg(format:marksheet:landscape:header) 2"
		lappend list "--------------------------------------"
		lappend list "$msg(format:block:idsf:report)"

		set ::__combo ""
		ComboBox::create $left.list -bd 1 -height 0 \
				-editable 0 -entrybg gray95 -font small \
				-selectbackground $gui(color:selection) \
				-labelwidth -1 \
				-width 30 -values $list \
				-textvariable ::__combo \
				-modifycmd "skating::options:print2:format $left.list $frame"
		text $left.help -font tips -width 40 -height 4 -relief flat -bg [$left cget -background] -tabs {60}
		$left.help tag configure blue -foreground darkblue
		$left.help tag configure red -foreground red
		bindtags $left.help "all"
		$left.help insert 1.0 "%title\t%dance\t" normal "%type\t%agemin\n" blue
		$left.help insert 2.0 "%date\t%round\t"	 normal "%level\t%agemax\n" blue
		$left.help insert 3.0 "%label\t\t"		 normal "\t%ageextra\n" blue
		$left.help insert 4.0 "%index\t\t"		 normal "\t" blue

		pack $left.list [frame $left.sep -height 2] -side top -fill x
		pack $left.help -side top -fill x
		# mise en page
		pack $left -fill both -side left -anchor w
		pack $frame -fill both -expand true -side left -anchor w

	# mise en page
	grid $paper	 $layout -sticky news -padx 5 -pady 5
	grid $margin ^       -sticky news -padx 5 -pady 5
	grid $format -       -sticky nwes -padx 5 -pady 5
	grid columnconfigure $w {0 1} -weight 1
	grid rowconfigure $w {2} -weight 1
}

proc skating::options:print2:format {list frame} {
global msg
variable gui

	# quelles données traiter
	set simple 1
	switch [ComboBox::getvalue $list] {
		0	{ set zones {header1_l header1_c header1_r} 
			  set fonts {print:title print:subtitle} }
		1	{ set zones {header2_l header2_c header2_r}
			  set fonts {print:title print:subtitle} }
		2	{ set zones {header3_l header3_c header3_r}
			  set fonts {print:subtitle print:date print:normal} }
		3	{ set zones {header4_l header4_c header4_r} 
			  set fonts {print:normal print:bold print:small} }

		4	{ set zones {general1_l general1_c general1_r}
			  set fonts {print:normal print:bold print:small} }
		5	{ set zones {general2_l general2_c general2_r}
			  set fonts {print:normal print:bold print:small} }

		6	{ set zones {mark_p_h1_l mark_p_h1_c mark_p_h1_r}
			  set fonts {font:folder font:title font:date} }
		7	{ set zones {mark_p_h2_l mark_p_h2_c mark_p_h2_r}
			  set fonts {font:folder font:title font:date} }
		8	{ set zones {mark_p_f_l mark_p_f_c mark_p_f_r}
			  set fonts {font:folder font:title font:date} }

		9	{ set zones {mark_l_f1}
			  set fonts {font:folder font:title font:date} }
		10	{ set zones {mark_l_f2}
			  set fonts {font:folder font:title font:date} }
		11	{ set zones {mark_l_h1_l mark_l_h1_c mark_l_h1_r}
			  set fonts {font:folder font:title font:date} }
		12	{ set zones {mark_l_h2_l mark_l_h2_c mark_l_h2_r}
			  set fonts {font:folder font:title font:date} }

		13 {
			destroy $frame.0
			destroy $frame.1
			destroy $frame.2
			destroy $frame.3
			return
		}

		14 { set simple 0
			 set var idsf_report }
	}
	# efface ancienne frame
	destroy $frame.0
	destroy $frame.1
	destroy $frame.2
	destroy $frame.3
	# génère les zones de saisie
	if {$simple} {
		#------------------------
		# ligne par ligne (L/C/R)
		#------------------------
		set i 1
		foreach zone $zones {
			set f [frame $frame.$i]
			# zone de définition
			entry $f.e -textvariable skating::gui(pref:format:text:$zone) \
					-bd 1 -bg gray95 -selectbackground $gui(color:selection)
			pack $f.e -side top -fill x
			# radio bouton pour taille font
			set j 0
			foreach font $fonts {
				radiobutton $f.r$j -text $msg($font) -bd 1 -font normal \
						-value $font -variable skating::gui(pref:format:font:$zone)
				pack $f.r$j -side top -anchor nw
				incr j
			}
			# mise en page
			pack $f -side left -fill both -expand true -padx 5
			incr i
		}

		# focus sur la première zone de saisie
		focus $frame.1.e


	} else {
		#-------------------------------
		# texte définissant un cartouche
		#-------------------------------

		set t [text $frame.0 -bd 1 -bg gray95 -selectbackground $gui(color:selection)]
		$t insert end $gui(pref:format:block:$var)
		bindEntry $t "::skating::gui(pref:format:block:$var)"
		# mise en page
		pack $t -side left -fill both -expand true -padx 5
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::options:attributes {w} {
global msg
variable gui

	# gestion des listes de valeurs pour les attributs
	set c1 [TitleFrame::create $w.1 -text $msg(options:attributes)]
	set sub [TitleFrame::getframe $c1]
		# zone de saisie texte pour les attributs
		set i 0
		foreach attrib $gui(pref:attributes) {
			set f [frame $sub.$i -bd 1 -relief raised]
			label $f.l -text $msg(attributes:$attrib)
			set sw [ScrolledWindow::create $f.sw \
							-scrollbar both -auto both -relief sunken -borderwidth 1]
			set list [text [ScrolledWindow::getframe $sw].t \
							-width 10 -height 1 -font normal -bg gray95 -bd 0 \
							-selectbackground $gui(color:selection)]
			foreach value $gui(pref:attributes:$attrib) {
				$list insert end "$value\n"
			}
			ScrolledWindow::setwidget $sw $list
			bind $list <Key> "set ::__rebuildAttributes 1"
			bindtags $list "$list Text stop all"
			bind stop <Key> "break"
			set gui(t:w:$attrib) $list
			# mise en page
			pack $f.l -side top -fill x
			pack $f.sw -side top -fill both -expand true
			pack $f -side left -expand true -fill both -padx 5 -pady 5
			incr i
		}

	# format pour la génération automatique du nom de compétition
	set c6 [TitleFrame::create $w.6 -text $msg(folderNaming)]
	set sub [TitleFrame::getframe $c6]
		# zone de saisie
		entry $sub.e -textvariable skating::gui(pref:folderNaming) \
				-bd 1 -bg gray95 -selectbackground $gui(color:selection)
		pack $sub.e [frame $sub.sep -height 5] -anchor nw -fill x
		# mémo des valeurs utilisable
		text $sub.h -font tips -width 40 -height 4 -relief flat -bg [$sub cget -background] -tabs {60}
		$sub.h tag configure blue -foreground darkblue
		$sub.h tag configure red -foreground red
		bindtags $sub.h "all"
		$sub.h insert 1.0 "%title\t%dance\t" normal "%type\t%agemin\n" blue
		$sub.h insert 2.0 "%date\t%round\t"	 normal "%level\t%agemax\n" blue
		$sub.h insert 3.0 "%label\t\t"		 normal "\t%ageextra\n" blue
		$sub.h insert 4.0 "%index\t\t"		 normal "\t" blue
		pack $sub.h -anchor w

	pack $c1 -side top -anchor w -pady 5 -fill both -expand true
	pack $c6 -side top -anchor w -pady 5 -fill x
}

proc skating::options:attributes:rebuild {} {
global msg
variable gui

	foreach attrib $gui(pref:attributes) {
		set gui(pref:attributes:$attrib) [list ]
		foreach item [split [$gui(t:w:$attrib) get 1.0 end] \n] {
			if {$item != ""} {
				lappend gui(pref:attributes:$attrib) $item
			}
		}
		# dernier élément vide pour autoriser sélection nulle
		lappend gui(pref:attributes:$attrib) ""
#puts "$attrib = $gui(pref:attributes:$attrib)"
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::options:general {w} {
global msg
variable gui

	# Noms explicites par défaut
  	set c0 [TitleFrame::create $w.0 -text $msg(setting)]
  	set sub [TitleFrame::getframe $c0]
		checkbutton $sub.d -bd 1 -text $msg(showNewAtSartup) \
					-variable skating::gui(pref:showNewDlgAtStartup)
		checkbutton $sub.n -bd 1 -text $msg(explicitNames) \
					-variable skating::gui(pref:explicitNames)
		checkbutton $sub.rule -bd 1 -text $msg(explain:ten) \
					-variable skating::gui(pref:explain:ten)
		checkbutton $sub.name -bd 1 -text $msg(tip:name) \
					-variable skating::gui(pref:tip:name)
		checkbutton $sub.compact1 -bd 1 -text $msg(judges:button:compact) \
					-variable skating::gui(pref:judges:button:compact)
		pack $sub.d $sub.n $sub.rule $sub.name \
			 $sub.compact1 -side top -anchor w -padx 5
	# Sauvegarde
	set c5 [TitleFrame::create $w.5 -text $msg(saving)]
	set sub [TitleFrame::getframe $c5]
		checkbutton $sub.b -bd 1 -text $msg(saving:backup) \
					-variable skating::gui(pref:save:backup)
		SpinBox::create $sub.spin -label "$msg(saving:autosave) " \
					-editable false -range {0 60 1} -width 3 -entrybg gray95 \
					-justify right -textvariable skating::gui(pref:save:auto) \
                    -selectbackground $gui(color:selection)
		label $sub.l -text $msg(saving:autosave2)
		pack $sub.b -side top -anchor w -padx 5
		pack $sub.spin -side left -anchor w -padx 5
		pack $sub.l -side left -anchor w

	# Compatibilité CompMgr
	set c6 [TitleFrame::create $w.6 -text $msg(specialmodes)]
	set sub [TitleFrame::getframe $c6]
		checkbutton $sub.1 -bd 1 -text $msg(mode:compmgr) \
					-variable skating::gui(pref:mode:compmgr)
		checkbutton $sub.2 -bd 1 -text $msg(mode:linkOCM) \
					-variable skating::gui(pref:mode:linkOCM)
		set f [frame $sub.3]
			set ww [list]
			foreach i {10 11 12 13 20 21} \
					what {mode:linkOCM:DBserver mode:linkOCM:DBuser mode:linkOCM:DBpassword mode:linkOCM:DBdatabase
						  mode:linkOCM:server mode:linkOCM:id} {
				label $f.l$i -text $msg($what)
				entry $f.e$i -textvariable skating::gui(pref:$what) -bd 1

				lappend ww $f.l$i $f.e$i
			}
			checkbutton $f.4 -bd 1 -text $msg(mode:linkOCM:wireless) \
						-variable skating::gui(pref:mode:linkOCM:wireless)
			lappend ww $f.4
			button $f.5 -bd 1 -text $msg(mode:linkOCM:login) -width 15 \
						-command "puts login"
			button $f.6 -bd 1 -text $msg(mode:linkOCM:DBlogin) -width 15 \
						-command "puts loginDB"

			checkbutton $f.7 -bd 1 -text $msg(mode:linkOCM:autologin) \
						-variable skating::gui(pref:mode:linkOCM:autologin)
						
			$sub.2 configure -command "if {\$skating::gui(pref:mode:linkOCM)} { set mode normal } else { set mode disabled}
							   		  foreach w [list $ww] { \$w configure -state \$mode; } "
			
			set s [frame $f.ss -width 20]

			grid $f.l20 $f.e20 x  $f.l10 $f.e10 -stick nes -padx 2 -pady 2
			grid $f.l21 $f.e21 x  $f.l11 $f.e11 -stick nes -padx 2 -pady 2
			grid $f.4   -      x  $f.l12 $f.e12 -stick nes -padx 2 -pady 2
			grid x      x      x  $f.l13 $f.e13 -stick nes -padx 2 -pady 2
			grid $f.5   -	   $s $f.6   -      -stick nes -padx 2 -pady 2
			grid $f.7   -	   -  -      -      -stick nws -padx 2 -pady 2
		# force une mise à jour
		uplevel #0 [$sub.2 cget -command]

		pack $sub.1 $sub.2 -side top -anchor w -padx 5
		pack $f -side top -anchor w -padx 50


	pack $c0 $c5 $c6 -side top -anchor w -pady 5
}

#----------------------------------------------------------------------------------------------

proc skating::options:colors {w} {
global msg

	# Couleur dans l'abrte principal
	set c5 [TitleFrame::create $w.5 -text $msg(colors:competition)]
	set sub [TitleFrame::getframe $c5]
		pack [options:color $sub color:activeCompetition] -anchor w
		pack [options:color $sub color:finishedCompetition] -anchor w
		pack [options:color $sub color:activeDance] -anchor w
		pack [options:color $sub color:finishedDance] -anchor w
	# Juges
	set c3 [TitleFrame::create $w.3 -text $msg(colors:judges)]
	set sub [TitleFrame::getframe $c3]
		pack [options:color $sub color:selected] -anchor w
		pack [options:color $sub color:notselected] -anchor w
		pack [options:color $sub color:colselected] -anchor w
	# Impressions
	set c4 [TitleFrame::create $w.4 -text $msg(colors:printing)]
	set sub [TitleFrame::getframe $c4]
		pack [options:color $sub color:print:dark] -anchor w
		pack [options:color $sub color:print:light] -anchor w

	# Général
	set c1 [TitleFrame::create $w.1 -text $msg(colors:general)]
	set sub [TitleFrame::getframe $c1]
		pack [options:color $sub color:competition] -anchor w
		pack [options:color $sub color:flash] -anchor w
		pack [frame $sub.sep -height 5] -anchor w
		pack [options:color $sub color:lightyellow] -anchor w
		pack [options:color $sub color:lightyellow2] -anchor w
		pack [options:color $sub color:yellow] -anchor w
		pack [options:color $sub color:lightorange] -anchor w
		pack [options:color $sub color:orange] -anchor w


	pack $c1 [frame $w.sep0 -width 10] -side left -anchor nw -pady 5
	pack $c5 $c3 $c4 -side top -anchor w -pady 5
}

#----------------------------------------------------------------------------------------------

proc skating::options:rounds {w} {
global msg


	# Affichage du nom des juges
  	set c0 [TitleFrame::create $w.0 -text $msg(setting)]
  	set sub [TitleFrame::getframe $c0]
		checkbutton $sub.nr -bd 1 -text $msg(names:rounds) \
					-variable skating::gui(pref:names:rounds)
		checkbutton $sub.nf -bd 1 -text $msg(names:finale) \
					-variable skating::gui(pref:names:finale)
		checkbutton $sub.ef -bd 1 -text $msg(explain:finale) \
					-variable skating::gui(pref:explain:finale)
		checkbutton $sub.kb -bd 1 -text $msg(keyboard:toggleling) \
					-variable skating::gui(pref:keyboard:toggleling)
		pack $sub.nr $sub.nf $sub.ef $sub.kb -side top -anchor w -padx 5
		

	# Finale
	set c1 [TitleFrame::create $w.1 -text $msg(colors:finale)]
	set sub [TitleFrame::getframe $c1]
		pack [options:color $sub color:place] -anchor w
		pack [options:color $sub color:placebad] -anchor w
		pack [options:color $sub color:exclusion] -anchor w
		pack [options:color $sub color:exclusion:text] -anchor w
	# Rounds
	set c2 [TitleFrame::create $w.2 -text $msg(colors:rounds)]
	set sub [TitleFrame::getframe $c2]
		pack [options:color $sub color:choosengood] -anchor w
		pack [options:color $sub color:choosenprequalif] -anchor w
		pack [options:color $sub color:choosenbad] -anchor w

	pack $c0 $c2 $c1 -side top -anchor w -pady 5
}

#----------------------------------------------------------------------------------------------

proc skating::options:dances {w} {
global msg
variable gui

	# listbox pour la liste des dances
	set sw [ScrolledWindow::create $w.sw \
					-scrollbar both -auto both -relief sunken -borderwidth 1]
	set list [listbox [ScrolledWindow::getframe $sw].list -bd 1 -bg gray95 -width 25 -exportselection false \
					-selectbackground $gui(color:selection) -selectmode single]
	ScrolledWindow::setwidget $sw $list
	foreach item $gui(pref:dances) {
		$list insert end $item
	}
	# help
	text $w.h -font tips -height 3 -relief flat -bg [$w cget -background] -tabs {125} \
			-takefocus 0
	$w.h tag configure blue -foreground darkblue
	$w.h tag configure red -foreground red
	bindtags $w.h "$w.h all"
	eval $w.h insert 1.0 $msg(dances:help)

	# boutons
	set but2 [frame $w.b2]
		button $but2.new -text $msg(dances:new) -bd 1 \
				-command "skating::options:dances:change $list new"
		button $but2.edit -text $msg(dances:edit) -bd 1 \
				-command "skating::options:dances:change $list edit"
		button $but2.remove -text $msg(remove) -bd 1 \
				-command "skating::options:dances:adjust $list remove"
		button $but2.insert -text $msg(dances:separator) -bd 1 \
				-command "skating::options:dances:addSeparator $list"
		button $but2.up -image imgUp -bd 1 \
				-command "skating::options:dances:adjust $list up"
		button $but2.down -image imgDown -bd 1 \
				-command "skating::options:dances:adjust $list down"
	pack $but2.new $but2.edit $but2.remove $but2.insert -fill x -pady 2
	pack [frame $but2.sep1 -height 15]
	pack $but2.up $but2.down -fill x -pady 2

	# mise en page
	pack $but2 [frame $w.sep1 -width 10] -side right -padx 5 -anchor n
	pack $sw -side top -fill both -expand true
	pack $w.h -side top

	# bindings
	bind $list <Insert> "skating::options:dances:change $list new"
	bind $list <Double-1> "skating::options:dances:change $list edit"
	bind $list <Return> "skating::options:dances:change $list edit"
	bind $list <Delete> "skating::options:dances:adjust $list remove"
	bind $list <Up> "skating::options:dances:scroll $list -1; break"
	bind $list <Down> "skating::options:dances:scroll $list +1; break"
	bind $list <Shift-Up> "skating::options:dances:adjust $list up ; break"
	bind $list <Shift-Down> "skating::options:dances:adjust $list down ; break"

	# init
	focus $list
	$list activate 0
	$list selection set active
}

proc skating::options:dances:scroll {list amount} {
	$list activate [expr {[$list index active] + $amount}]
	$list see active
	$list selection clear 0 end
	$list selection set active
}

proc skating::options:dances:adjust {list cmd} {
global msg
variable gui

TRACE "skating::options:dances:adjust $list $cmd"

	# récupère index & retire élément de la liste
	set idx [$list curselection]
	if {[llength $idx] != 1
			|| ($cmd == "up" && $idx == 0)
			|| ($cmd == "down" && $idx == [expr [$list size]-1])} {
		bell
		return
	}
	set dancename [$list get $idx]
	$list delete $idx
	set gui(pref:dances) [lreplace $gui(pref:dances) $idx $idx]
	if {[info exists gui(pref:dances:short)]} {
		set letters [lindex $gui(pref:dances:short) $idx]
	}

	# traite la commande
	switch $cmd {
		remove    {	}

		up		  {	incr idx -1
					$list insert $idx $dancename
					set gui(pref:dances) [linsert $gui(pref:dances) $idx $dancename]
					if {[info exists gui(pref:dances:short)]} {
						set gui(pref:dances:short) [linsert $gui(pref:dances:short) $idx $letters]
					}
				  }

		down	  {	incr idx
					$list insert $idx $dancename
					set gui(pref:dances) [linsert $gui(pref:dances) $idx $dancename]
					if {[info exists gui(pref:dances:short)]} {
						set gui(pref:dances:short) [linsert $gui(pref:dances:short) $idx $letters]
					}
				  }
	}

	# ajuste sélection
	if {$idx == [expr [$list size]]} {
		incr idx -1
	}
	$list activate $idx
	$list see active
	$list selection set active
TRACE "AFTER = '$gui(pref:dances)'"
}

proc skating::options:dances:change {list cmd} {
global msg
variable gui

	set idx [$list curselection]
	set dancename [$list get $idx]
	if {[info exists gui(pref:dances:short)]} {
		set dancenameshort [lindex $gui(pref:dances:short) $idx]
	}
TRACE "$list $cmd / '$dancename' $idx '$dancenameshort'"
	if {$cmd == "edit" && $dancename == "----"} {
		return
	}

	# construit la boite de dialogue
	set w .dialog
	destroy $w
	toplevel $w -class Dialog
	wm title $w $msg(dlg:editdance)
	wm iconname $w Dialog
	wm protocol $w WM_DELETE_WINDOW { }
	wm transient $w
	wm geometry $w +[expr [winfo pointerx .settings]-15]+[expr [winfo pointery .settings]-32]
	wm resizable $w 0 0
		# zone d'édition (nom)
		set f [frame $w.e -relief raised -bd 1]
		label $f.l -text $msg(dlg:editdanceLabel)
		entry $f.e -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
				-textvariable __dancename
		if {$cmd == "new"} {
			set ::__dancename ""
		} else {
			set ::__dancename $dancename
		}
		# zone d'édition (abbréviation)
		label $f.l2 -text $msg(dlg:editdanceShortLabel)
		entry $f.e2 -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
				-textvariable __dancenameshort
		if {$cmd == "new"} {
			set ::__dancenameshort ""
		} else {
			set ::__dancenameshort $dancenameshort
		}
		pack [frame $f.sep1 -height 10] $f.l $f.e [frame $f.sep0 -height 5] \
			 $f.l2 $f.e2 [frame $f.sep2 -height 15] -fill x -padx 3m
		# boutons
		set f [frame $w.b -relief raised -bd 1]
		button $f.ok -bd 1 -default active -width 6 -text $msg(dlg:ok) -under 0 \
				-command "set tkPriv(button) ok"
		button $f.cancel -bd 1 -width 6 -text $msg(dlg:cancel) -under 0 \
				-command "set tkPriv(button) cancel"
		pack $f.ok $f.cancel -side left -expand true -padx 3m -pady 2m
	# mise en page
	pack $w.e -side top -fill both
	pack $w.b -side top -fill x

	# bindings
	bind $w <Return> "set tkPriv(button) ok"
	bind $w <Alt-o> "set tkPriv(button) ok"
	bind $w <Alt-c> "set tkPriv(button) cancel"
	bind $w <Alt-a> "set tkPriv(button) cancel"
	bind $w <Escape> "set tkPriv(button) cancel"

	# OK pour boite modale
	tkwait visibility $w
	set oldFocus [focus]
	set oldGrab [grab current $w]
	if {$oldGrab != ""} {
		set grabStatus [grab status $oldGrab]
	}
	grab $w
	focus $w.e.e
	global tkPriv
	tkwait variable tkPriv(button)
	catch {focus $oldFocus}
	destroy $w
	if {$oldGrab != ""} {
		if {$grabStatus == "global"} {
			grab -global $oldGrab
		} else {
			grab $oldGrab
		}
	}

	# process le résultat
	if {$tkPriv(button) == "ok"} {
		if {$cmd == "new"} {
			lappend gui(pref:dances) $::__dancename
			if {[info exists gui(pref:dances:short)]} {
				lappend gui(pref:dances:short) [string toupper $::__dancenameshort]
			}
			$list insert end $::__dancename
			set idx end
		} else {
			set gui(pref:dances) [lreplace $gui(pref:dances) $idx $idx $::__dancename]
			if {[info exists gui(pref:dances:short)]} {
				set gui(pref:dances:short) [lreplace $gui(pref:dances:short) $idx $idx \
												[string toupper $::__dancenameshort]]
			}
			$list delete $idx
			$list insert $idx $::__dancename
		}
		$list activate $idx
		$list see active
		$list selection clear 0 end
		$list selection set active
	}
#puts "AFTER = '$gui(pref:dances)'"
}

proc skating::options:dances:addSeparator {list} {
variable gui

	# ajoute à la fin de la liste
	lappend gui(pref:dances) "----"
	if {[info exists gui(pref:dances:short)]} {
		lappend gui(pref:dances:short) "----"
	}
	# mise à jour affichage
	$list insert end "----"
	$list activate end
	$list see active
	$list selection clear 0 end
	$list selection set active
}

#----------------------------------------------------------------------------------------------

proc skating::options:database {w} {
global msg
variable gui

	# activation
	set activate [TitleFrame::create $w.activate -text $msg(db:activate)]
	set sub [TitleFrame::getframe $activate]
		checkbutton $sub.c -bd 1 -text $msg(db:activate:couples) \
					-variable skating::gui(pref:completion:couples)
		checkbutton $sub.j -bd 1 -text $msg(db:activate:judges) \
					-variable skating::gui(pref:completion:judges)
		pack $sub.c $sub.j -side top -anchor w -padx 5
	# fichier
	set file [TitleFrame::create $w.file -text $msg(db:file)]
	set sub [TitleFrame::getframe $file]
		set f [frame $sub.t]
			label $f.l -text $msg(db:filename)
			entry $f.e -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
					-textvariable skating::gui(pref:db)
			button $f.b -text $msg(choose) -bd 1 \
					-command "skating::options:database:setFile"
			pack $f.l $f.e $f.b -side left -anchor w -padx 5
			pack configure $f.e -expand true -fill x
		set f [frame $sub.b]
			set gui(w:db) $f
			button $f.1 -text $msg(db:export) -bd 1 \
					-command "skating::event:database:export"
			button $f.2 -text $msg(db:import) -bd 1 \
					-command "skating::event:database:import"
			pack $f.1 $f.2 -side left -anchor w -padx 5
		pack $sub.t [frame $sub.sep -height 5] $sub.b -side top -anchor w -fill x
	# help
	text $w.h -font tips -height 6 -relief flat -bg [$w cget -background] -wrap word
	$w.h tag configure blue -foreground blue
	bindtags $w.h "$w.h all"
	eval $w.h insert 1.0 $msg(db:help)

	# mise en page
	pack $activate [frame $w.sep1 -height 10] $file [frame $w.sep2 -height 10] $w.h -fill both
}

proc skating::options:database:setFile {} {
global msg
variable gui

    set types [list [list $msg(fileDatabase)	{.db}] \
					[list $msg(fileAll) 	*] ]
	set file [tk_getSaveFile -filetypes $types -parent $gui(w:tree) \
						-initialfile $gui(pref:db) -defaultextension ".db"]
	if {$file == ""} {
		return
	}
	# OK
	set ::skating::gui(pref:db) $file
	event:database:start
	event:database:refreshWithFile
}

#==============================================================================================

proc skating::options:save {{askFile 0}} {
variable gui
global msg

#TRACEF

	set file "$::pathExecutable/3s.pref"

	while {$askFile || [catch { set out [open $file "w"] }]} {

	    set types [list [list $msg(fileSkatingPref) 	{.pref}] \
						[list $msg(fileAll) 			*] ]
		set file [tk_getSaveFile -filetypes $types -parent .settings \
								 -initialfile "3s.pref" -defaultextension ".pref"]
		if {$file == ""} {
			return
		}
		set askFile 0
	}

	if {[catch {
			fconfigure $out -encoding utf-8
			# les couleurs
			foreach var [lsort [array names gui color:*]] {
				puts $out "$var [list $gui($var)]"
			}
			# les préférences
			foreach var [lsort [array names gui pref:*]] {
				puts $out "$var [list $gui($var)]"
			}
			close $out

		} errmsg]} {

		tk_messageBox -icon "error" -type ok -default ok \
				-title $msg(dlg:error) -message "$msg(dlg:saveDefaultsFailed)\n\n($errmsg)"
	}
}

proc skating::options:load {} {
global msg
variable gui

    set types [list [list $msg(fileSkatingPref) 	{.pref}] \
					[list $msg(fileAll) 			*] ]
	set file [tk_getOpenFile -filetypes $types -parent .settings \
							 -initialfile "3s.pref" -defaultextension ".pref"]
	if {$file == ""} {
		return
	}
	# charge les préférences
	parseFile $file skating::gui dlg:prefFailed
	# détruit et reconstruit le dialogue
	destroy .settings
	gui:options

	# simule sélection de rien pour forcer le redessin pour prise en compte
	# des nouvelles préférences

	# enlève sélection pour le tree des dossiers
	Tree::selection $gui(w:tree) clear
	set gui(v:lastselection) ""
	set gui(v:folder) ""
	set gui(v:dance) ""
	set gui(v:round) ""
	set ::skating::displayFolder ""
	set ::skating::displayRound ""
	fastentry:mode ""
	# reset le notebook
	foreach p [NoteBook::pages $gui(w:notebook)] {
		NoteBook::delete $gui(w:notebook) $p
	}
}


#----------------------------------------------------------------------------------------------
#	Helpers
#----------------------------------------------------------------------------------------------

proc skating::options:color {w var} {

	set f [frame $w.$var]
	# label
	label $f.l -text $::msg($var) -width 40 -anchor w
	# option menu pour couleurs
	set color [SelectColor $f.c -type menubutton -variable skating::gui($var) -width 50]
	# mise en page
	pack $f.l -side left -anchor w
	pack $color -side right
	set f
}

#----------------------------------------------------------------------------------------------

proc skating::options:font {w var} {

	set f [frame $w.$var]
	# label
	label $f.l -text $::msg($var) -width 15 -anchor w
	# label affichant la fonte
	label $f.f -text "ABC abc 123" -font $var -bg gray95 -relief raised -bd 1
	bind $f.f <1> "skating::options:font:dialog $var"

	# mise en page
	pack $f.l -side left -anchor w
	pack $f.f -side left -fill x -expand true
	set f
}

proc skating::options:font:dialog {font} {

	set newfont [tk_chooseFont -initialfont $skating::gui(pref:font:$font)]
	if {$newfont == ""} {
		return
	}
	# enregistre la préférence
	set skating::gui(pref:font:$font) $newfont
	# extrait les valeurs
	set family [lindex $newfont 0]
	set size [lindex $newfont 1]
	set weight [lindex $newfont 2]
	# reconfigure la fonte
	if {$weight == ""} {
		font configure $font -family $family -size $size
	} else {
		font configure $font -family $family -size $size -weight $weight
	}
}
