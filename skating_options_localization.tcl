##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#==============================================================================================
#
#	Gestion des paramétrages utilisateurs (préferences & options)
#
#==============================================================================================

proc skating::options:language {w} {
global msg
variable gui

	# si pas de choix déjà défini, propose anglais par défaut
	if {![info exists gui(pref:language)]} {
		set ::__lang $::currentLanguage
	} else {
		set ::__lang $gui(pref:language)
	}

	# choix + création d'une nouvelle langue
	set lang [TitleFrame::create $w.lang -text $msg(language:language)]
	set sub [TitleFrame::getframe $lang]
		set values [list ]
		foreach f [glob -nocomplain $::pathExecutable/data/*.lang] {
			lappend values [file rootname [file tail $f]]
		}
		set list [ComboBox::create $sub.l -bd 1 -height 0 -editable 0 -entrybg gray95 \
						-selectbackground $gui(color:selection) \
						-label "$msg(language:language) " \
						-values $values -textvariable __lang \
						-modifycmd "skating::options:language:change"]
		set gui(w:localize:combo) $sub.l		
		button $sub.n -bd 1 -text $msg(language:new) -command "skating::options:language:new"
		pack $list $sub.n -side left -anchor w -padx 5 -pady 5

	# chargement de la référence en anglais
	global msg_ref
	parseFile "$::pathExecutable/data/english.lang" msg_ref dlg:langFailed

	# choix + création d'une nouvelle langue
	set edit [TitleFrame::create $w.edit -text $msg(language:edit)]
	set sub [TitleFrame::getframe $edit]
		# list avec tous les noms symboliques
		set sw [ScrolledWindow::create $sub.list \
						-scrollbar both -auto both -relief sunken -borderwidth 1]
		set list [listbox [ScrolledWindow::getframe $sw].l -bd 0 -bg gray95 \
						-bg gray95 -selectbackground $::skating::gui(color:selection) -selectmode browse]
		set gui(w:localize) $sub
		set gui(w:localize:list) $list
		bind $list <<ListboxSelect>> "$sub.en delete 1.0 end; $sub.en insert end \$msg_ref(\[$list get anchor\]);
									  $sub.lg delete 1.0 end; $sub.lg insert end \$msg(\[$list get anchor\]);"
		bind $list <1> "focus $list"
		ScrolledWindow::setwidget $sw $list
		pack $sw -fill both
		foreach n [lsort -dictionary [array names msg *]] {
			$list insert end $n
		}
		# text en Anglais
		label $sub.enl -text "English" -anchor w
		text $sub.en -height 1 -width 1 -bd 1 -wrap char -bg $gui(t:on:bg)
		bindtags $sub.en "all"
		# texte de la traduction
		label $sub.lgl -textvariable ::__lang -anchor w
		text $sub.lg -height 1 -width 1 -bd 1 -wrap char \
				-bg gray95 -selectbackground $gui(color:selection)

 		bind $sub.lg <Alt-Up> "tkListboxUpDown $list -1"
 		bind $sub.lg <Alt-Down> "tkListboxUpDown $list +1"
		bind $sub.lg <KeyRelease-Left> { #nothing }
		bind $sub.lg <KeyRelease-Right> { #nothing }
		bind $sub.lg <KeyRelease-Up> { #nothing }
		bind $sub.lg <KeyRelease-Down> { #nothing }
		bind $sub.lg <KeyRelease-Prior> { #nothing }
		bind $sub.lg <KeyRelease-Next> { #nothing }
		bind $sub.lg <KeyRelease-Home> { #nothing }
		bind $sub.lg <KeyRelease-End> { #nothing }
		bind $sub.lg <KeyRelease> "set ::msg(\[$list get anchor\]) \[string trimright \[$sub.lg get 1.0 end\]\];
								   \$::skating::gui(w:localize:save) configure -bg salmon -activebackground pink;
								   set ::__modified 1"
		bindEntry $sub.lg "" 1

		# help
		text $sub.h -font tips -height 1 -relief flat -bg [$sub cget -background] -tabs {125}
		$sub.h tag configure blue -foreground darkblue
		$sub.h tag configure red -foreground red
		bindtags $sub.h "all"
		eval $sub.h insert 1.0 $msg(language:help)

		# bouton pour sauver les modifications
		frame $sub.b
		button $sub.b.s -bd 1 -text $msg(dlg:save) -command "skating::options:language:save"
		set gui(w:localize:save) $sub.b.s
		button $sub.b.a -bd 1 -text $msg(apply) -command "skating::options:language:apply"
		pack $sub.b.s -side left
		pack $sub.b.a -side left -padx 10

		# mise en page
		pack $sub.b -side bottom -anchor w -padx 5 -pady 5
		pack $sub.list -side left -anchor w -padx 5 -pady 5 -fill y
#  		label $sub.item -text "cureent:item" -anchor w -relief groove
#  		pack [frame $sub.sep0 -height 5] $sub.item \
#  			 [frame $sub.sep1 -height 10] $sub.enl $sub.en \
#  			 [frame $sub.sep2 -height 10] \
#  			 $sub.lgl $sub.lg [frame $sub.sep3 -height 5] -side top -anchor w -padx 5 -fill x
		pack [frame $sub.sep1 -height 5] $sub.enl $sub.en \
			 [frame $sub.sep2 -height 10] \
			 $sub.lgl $sub.lg $sub.h [frame $sub.sep3 -height 5] -side top -anchor w -padx 5 -fill x
		pack configure $sub.en $sub.lg -expand true -fill both

	# mise en page
	grid $lang -sticky news -padx 5 -pady 5
	grid $edit -sticky news -padx 5 -pady 5
	grid columnconfigure $w {0} -weight 1
	grid rowconfigure $w {1} -weight 1

	# sélection premier élément
	$list selection anchor 0
	$list selection set 0
	update
	event generate $list <<ListboxSelect>>
}

proc skating::options:language:change {} {
global msg
variable gui


#TRACE "$::__lang / before $gui(pref:language)"

	# essaie de parser le fichier
	global msg_new
	if {[parseFile "$::pathExecutable/data/$::__lang.lang" msg_new dlg:langFailed] == 0} {
		return
	}
	
	# enregistre le choix
	set gui(pref:language) $::__lang
	# mets à jour les chaines de texte
	foreach n [array names msg_new] {
		set msg($n) $msg_new($n)
	}

	# appliquer les changements
	options:language:apply
}


proc skating::options:language:apply {} {
global msg
variable gui

	set sub $gui(w:localize)
	set list $gui(w:localize:list)
	set selection [$list index anchor]

	# provoque le redessin de la fenêtre
	skating::gui:main .top 1
	tkwait visibility .top

	set geometry [winfo geometry .settings]
	destroy .settings
	skating::gui:options language
	wm geometry .settings $geometry

	# resélection qqch
	$gui(w:localize:list) selection anchor $selection
	$sub.lg delete 1.0 end; $sub.lg insert end $msg([$list get anchor])


	# restaure état bouton 'sauver'
	if {$::__modified} {
		$gui(w:localize:save) configure -bg salmon -activebackground pink
	} else {
		$gui(w:localize:save) configure -bg $gui(t:on:bg) -activebackground $gui(t:on:abg)
	}
}


proc skating::options:language:save {} {
global msg
variable gui

#TRACE "$::__lang"

	# enregistre le fichier
	set filename "$::pathExecutable/data/$::__lang.lang"
	if {![file writable [file dirname $filename]]} {
		tk_messageBox -icon "error" -type ok -default ok \
				-title $msg(dlg:cannotWrite) -message [format $msg(dlg:cannotWrite) $filename]
		return
	}

	set out [open $filename "w"]
	fconfigure $out -encoding utf-8
	foreach n [array name msg] {
		puts $out "$n [list $msg($n)]"
	}
	close $out

	# montre les changements
	set ::__modified 0
	options:language:apply
}

set ::__modified 0


proc skating::options:language:new {} {
global msg
variable gui

	# nom du fichier
	set done 0
	while {!$done} {
	    set types [list [list $msg(fileLanguage)	{.lang}]]
		set file [tk_getSaveFile -filetypes $types -parent $gui(w:tree) \
							-initialdir $::pathExecutable/data -defaultextension ".db"]
		if {$file == ""} {
			return
		}

		# vérifie que l'on reste dans le répertoire '.../data'
		set old [pwd]
		cd $::pathExecutable/data
		if {[file dirname $file] == [pwd]} {
			set done 1
		} else {
			bell
		}
		cd $old
	}

	# vérifie si on peut écrire
	if {![file writable [file dirname $file]]} {
		tk_messageBox -icon "error" -type ok -default ok \
				-title $msg(dlg:cannotWrite) -message [format $msg(dlg:cannotWrite) $filename]
		return
	}

	# crée le nouveau fichier
	set ::__lang [file rootname [file tail $file]]
	options:language:save

	# mise à jour combo
	set values [list ]
	foreach f [glob -nocomplain $::pathExecutable/data/*.lang] {
		lappend values [file rootname [file tail $f]]
	}
	$gui(w:localize:combo) configure -values $values
}
