##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion de la selection des couples pour une competition
#
#=================================================================================================

proc skating::manage:dances:init {folder w} {
global msg
variable gui
variable event

	# danses
	set but [frame $w.b]
	set gui(w:dances) $but
		# les danses
		set index 0
		foreach item $gui(pref:dances) {
			if {$item == "----"} {
				pack [frame $but.$index -height 8] -fill x
			} else {
				button $but.$index -text $item -bd 1 \
					-command "skating::manage:dances:adjust $folder add [list $item]"
				pack $but.$index -fill x
			}
			incr index
		}
		# autres danses
		set other [frame $but.other]
		button $other.l -text $msg(other) -bd 1 \
				-command "skating::manage:dances:adjust $folder addother"
		entry $other.e -textvariable __dance -bd 1 -bg gray95
		pack $other.l [frame $other.sep1 -width 5] $other.e -fill x -side left
	pack [frame $but.sep -height 16] $other -fill x
	# listbox pour les choix
	set sw [ScrolledWindow::create $w.sw \
					-scrollbar both -auto both -relief sunken -borderwidth 1]
	set gui(w:listDances) [listbox [ScrolledWindow::getframe $sw].sel -bd 0 -bg gray95 -width 25 \
									-selectbackground $gui(color:selection) -selectmode single]
	ScrolledWindow::setwidget $sw $gui(w:listDances)
	manage:dances:set $folder $gui(w:listDances)

	# boutons
	set but2 [frame $w.b2]
		button $but2.remove -text $msg(remove) -bd 1 \
				-command "skating::manage:dances:adjust $folder remove"
		button $but2.up -image imgUp -bd 1 \
				-command "skating::manage:dances:adjust $folder up"
		button $but2.down -image imgDown -bd 1 \
				-command "skating::manage:dances:adjust $folder down"
	pack $but2.remove -fill x
	pack [frame $but2.sep1 -height 8]
	pack $but2.up $but2.down -fill x

	# type de systèmes de notation utilisé
	set type [TitleFrame::create $w.n -text $msg(notation)]
	set f [TitleFrame::getframe $type]
	  	radiobutton $f.1 -text $msg(notation:normal) -bd 1 \
				-value normal -variable ::skating::${folder}(mode) \
				-command "skating::manage:dances:updateMode $folder"
	  	radiobutton $f.2 -text $msg(notation:ten) -bd 1 \
				-value ten -variable ::skating::${folder}(mode) \
				-command "skating::manage:dances:updateMode $folder"
	  	radiobutton $f.3 -text $msg(notation:qualif) -bd 1 \
				-value qualif -variable ::skating::${folder}(mode) \
				-command "skating::manage:dances:updateMode $folder"
	  	radiobutton $f.4 -text $msg(notation:tree) -bd 1 \
				-value tree -variable ::skating::${folder}(mode) \
				-command "skating::manage:dances:updateMode $folder"
		grid $f.1 $f.3 -sticky nw -padx 5 -pady 5
		grid $f.2 -    -sticky nw -padx 5 -pady 5
		grid columnconfigure $f {2} -weight 1

	# modèles de danses prédéfinis
	set template [TitleFrame::create $w.t -text $msg(templates)]
  	set gui(w:dances:templates) [TitleFrame::getframe $template]
		manage:dances:buildTemplates
	button $w.e -text $msg(edit) -bd 1 -command "skating::gui:options templates"

	# mise en page
	grid $but 	$type 		-		-sticky news -padx 5 -pady 5
	grid ^		$sw			$but2	-sticky news -padx 5 -pady 5
	grid ^		$template	^		-sticky news -padx 5 -pady 5
	grid ^		$w.e		x		-sticky ns -padx 5
	grid columnconfigure $w {0 2} -weight 0
	grid columnconfigure $w {1} -weight 1
	grid rowconfigure $w {1} -weight 1
	grid rowconfigure $w {0 2 3} -weight 0
}

proc skating::manage:dances:buildTemplates {} {
variable gui

	if {![info exists gui(w:dances:templates)] || ![winfo exists $gui(w:dances:templates)]} {
		return
	}

	foreach w [winfo children $gui(w:dances:templates)] {
		destroy $w
	}
	set w $gui(w:dances:templates)
	foreach t $gui(pref:templates) {
		button $w.$t -bd 1 -text $gui(pref:template:name:$t) -pady 0 \
				-command "skating::manage:dances:useTemplate $t"
		pack $w.$t -fill x -pady 0 -padx 5
		set text ""
		foreach dance $gui(pref:template:dances:$t) {
			append text " $dance \n"
		}
		DynamicHelp::register $w.$t balloon [string range $text 0 end-1]
	}
}

proc skating::manage:dances:useTemplate {t} {
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder

	# retire les danses
	foreach dummy $folder(dances) {
		# on retire toujours le premier élement de la listbox (0)
		$gui(w:listDances) selection clear 0 end
		$gui(w:listDances) selection set 0
		if {[manage:dances:adjust $gui(v:folder) remove 0] < 0} {
			return
		}
	}
	foreach name [array names folder dances:*] {
		unset folder($name)
	}
	# ajoute celles du modèle
	foreach dance $gui(pref:template:dances:$t) {
		manage:dances:adjust $gui(v:folder) add $dance
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:dances:adjust {f cmd {data ""}} {
variable $f
upvar 0 $f folder

	manage:dances:adjust:$folder(mode) $f $cmd $data
}

proc skating::manage:dances:adjust:qualif {f cmd data} {
	skating::manage:dances:adjust:normal $f $cmd $data
}

proc skating::manage:dances:adjust:normal {f cmd data} {
global msg
variable gui
variable $f
upvar 0 $f folder


#puts "skating::manage:dances:adjust:normal {$f $cmd {$data}}"
	# vérification - réinit des folders si on change la liste des danses alors que des notes
	# sont déjà entrées
	if {$cmd == "remove"} {
		if {$data != ""} {
			set dance $data
		} else {
			set dance [$gui(w:listDances) curselection]
		}
		if {$dance == ""} {
			return 0
		}
		set dance [$gui(w:listDances) get $dance]
		# si on retire une danse, il faut qu'elle ne soit pas employée dans les rounds
		set used 0
		foreach n [array names folder dances:*] {
			if {[lsearch -exact $folder($n) $dance] != -1} {
				set used 1
				break
			}
		}
		if {$used} {
			set doit [tk_messageBox -icon "question" -type yesno -default yes \
								-title $msg(dlg:question) -message $msg(dlg:dancesReinit)]
			if {$doit == "no"} {
				return -1
			}
			# retire la danse et réinitialise les rounds
			set erase 0
			foreach level {128.2 128 64.2 64 32.2 32 16.2 16 eight.2 eight quarter.2 quarter semi.2 semi finale} {
				if {$level != "finale"} {
					if {![info exists folder(dances:$level)]} {
						continue
					}
					# si la danse est utilisée
					if {[lsearch -exact $folder(dances:$level) $dance] != -1} {
						incr erase
					}
				} elseif {$erase} {
					incr erase
				}
				# effaçage des données
				if {$erase} {
					if {$erase == 1} {
						set pattern "notes:$level:*:$dance"
					} else {
						set pattern "notes:$level:*"
					}
					foreach n [array names folder $pattern] {
						unset folder($n)
					}
					if {$erase > 1 && [info exists folder(couples:$level)]} {
						unset folder(couples:$level)
					}
				}
			}
			# mise-à-jour affichage
			manage:rounds:adjustTreeColor $f

		} else {
			# cherche si impact sur la finale
			set used 0
			foreach n [array names folder "notes:finale:*:$dance"] {
				foreach note $folder($n) {
					if {$note} {
						set used 1
						break
					}
				}
			}
			# demande confirmation
			if {$used} {
				set doit [tk_messageBox -icon "question" -type yesno -default yes \
									-title $msg(dlg:question) -message $msg(dlg:dancesReinit2)]
				if {$doit == "no"} {
					return -1
				}
				# remove data
				foreach n [array names folder "notes:finale:*:$dance"] {
					unset folder($n)
				}
			}
		}
	}

	# traite la commande
	switch $cmd {
		add		  {	if {[lsearch $folder(dances) $data] != -1} {
						bell
						return -1
					}
					$gui(w:listDances) insert end $data
				  	lappend folder(dances) $data
					set idx [lsearch $gui(pref:dances) $data]
					if {$idx != -1} {
						$gui(w:dances).$idx configure -state disabled
					}
					# mise à jour pour impact sur rounds/résultat
					manage:rounds:adjustTreeColor $f
				  }

		addother  {	global __dance
					if {$__dance != ""} {
						if {[lsearch $folder(dances) $__dance] != -1} {
							bell
							return -1
						}
						$gui(w:listDances) insert end $__dance
					  	lappend folder(dances) $__dance
						set __dance ""
					} else {
						bell
					}
					# mise à jour pour impact sur rounds/résultat
					manage:rounds:adjustTreeColor $f
				  }

		remove    {	if {$data != ""} {
						set dance $data
					} else {
						set dance [$gui(w:listDances) curselection]
					}
					set dancename [$gui(w:listDances) get $dance]
					foreach n [array names folder dances*] {
						set idx [lsearch $folder($n) $dancename]
						set folder($n) [lreplace $folder($n) $idx $idx]
					}
					$gui(w:listDances) delete $dance
					set idx [lsearch $gui(pref:dances) $dancename]
					if {$idx != -1} {
						$gui(w:dances).$idx configure -state normal
					}
					# retire la sélection
					$gui(w:listDances) selection clear 0 end
					# mise à jour pour impact sur rounds/résultat
					manage:rounds:adjustTreeColor $f
				  }

		up		  {	set idx [$gui(w:listDances) curselection]
					if {[llength $idx] != 1} {
						bell
						return -1
					}
					if {$idx == 0} {
						return 0
					}
					$gui(w:listDances) selection clear $idx
					# retire élément
					set data [$gui(w:listDances) get $idx]
					set folder(dances) [lreplace $folder(dances) $idx $idx]
					$gui(w:listDances) delete $idx
					# repositionne élément
					incr idx -1
					$gui(w:listDances) insert $idx $data
					set folder(dances) [linsert $folder(dances) $idx $data]
					# ajuste sélection
					$gui(w:listDances) selection set $idx
				  }

		down	  {	set idx [$gui(w:listDances) curselection]
					if {[llength $idx] != 1} {
						bell
						return -1
					}
					if {$idx == [expr [$gui(w:listDances) size]-1]} {
						return 0
					}
					$gui(w:listDances) selection clear $idx
					# retire élément
					set data [$gui(w:listDances) get $idx]
					set folder(dances) [lreplace $folder(dances) $idx $idx]
					$gui(w:listDances) delete $idx
					# repositionne élément
					incr idx
					$gui(w:listDances) insert $idx $data
					set folder(dances) [linsert $folder(dances) $idx $data]
					# ajuste sélection
					$gui(w:listDances) selection set $idx
				  }
	}
	return 0
}

proc skating::manage:dances:adjust:ten {f cmd data} {
global msg
variable gui
variable $f
upvar 0 $f folder


#TRACEF

	# traite la commande
	switch $cmd {
		add		  {	if {[lsearch $folder(dances) $data] != -1} {
						bell
						return -1
					}
					$gui(w:listDances) insert end $data
				  	lappend folder(dances) $data
					set idx [lsearch $gui(pref:dances) $data]
					if {$idx != -1} {
						$gui(w:dances).$idx configure -state disabled
					}
					# créer un nouveau sous dossier
					folder:init:normal $f.$data $folder(label) [list $data]
				  }

		addother  {	global __dance
					if {$__dance != ""} {
						if {[lsearch $folder(dances) $__dance] != -1} {
							bell
							return -1
						}
						$gui(w:listDances) insert end $__dance
					  	lappend folder(dances) $__dance
					} else {
						bell
					}
					# créer un nouveau sous dossier
					folder:init:normal $f.$__dance $folder(label) [list $__dance]
					set __dance ""
				  }

		remove    {	if {$data != ""} {
						set dance $data
					} else {
						set dance [$gui(w:listDances) curselection]
					}
					if {$dance == ""} {
						bell
						return -1
					}
					set dancename [$gui(w:listDances) get $dance]
					# efface les données
					unset ::skating::$f.$dancename
					set folder(dances) [lreplace $folder(dances) $dance $dance]
					# efface dans la listbox
					$gui(w:listDances) delete $dance
					set idx [lsearch $gui(pref:dances) $dancename]
					if {$idx != -1} {
						$gui(w:dances).$idx configure -state normal
					}
					# retire la sélection
					$gui(w:listDances) selection clear 0 end
				  }

		up		  {	set idx [$gui(w:listDances) curselection]
					if {[llength $idx] != 1} {
						bell
						return -1
					}
					if {$idx == 0} {
						return 0
					}
					$gui(w:listDances) selection clear $idx
					# retire élément
					set data [$gui(w:listDances) get $idx]
					set folder(dances) [lreplace $folder(dances) $idx $idx]
					$gui(w:listDances) delete $idx
					# repositionne élément
					incr idx -1
					$gui(w:listDances) insert $idx $data
					set folder(dances) [linsert $folder(dances) $idx $data]
					# ajuste sélection
					$gui(w:listDances) selection set $idx
				  }

		down	  {	set idx [$gui(w:listDances) curselection]
					if {[llength $idx] != 1} {
						bell
						return -1
					}
					if {$idx == [expr [$gui(w:listDances) size]-1]} {
						return 0
					}
					$gui(w:listDances) selection clear $idx
					# retire élément
					set data [$gui(w:listDances) get $idx]
					set folder(dances) [lreplace $folder(dances) $idx $idx]
					$gui(w:listDances) delete $idx
					# repositionne élément
					incr idx
					$gui(w:listDances) insert $idx $data
					set folder(dances) [linsert $folder(dances) $idx $data]
					# ajuste sélection
					$gui(w:listDances) selection set $idx
				  }
	}

	# ajuste l'affichage
	manage:rounds:generate:ten $f auto

	return 0
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:dances:set {f lb} {
variable $f
upvar 0 $f folder
variable gui


	foreach d $folder(dances) {
		$lb insert end $d
		set idx [lsearch $gui(pref:dances) $d]
		if {$idx != -1} {
			$gui(w:dances).$idx configure -state disabled
		}
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:dances:updateMode {f} {
variable $f
upvar 0 $f folder
variable gui


#puts "skating::manage:dances:updateMode {$f} -> $folder(mode)"

	if {$folder(mode) == "ten"} {
		folder:init:ten $f $folder(label) $folder(dances)
		Tree::itemconfigure $gui(w:tree) $f -image imgCupTen
	} elseif {$folder(mode) == "qualif"} {
		folder:init:normal $f $folder(label) $folder(dances) $folder(mode)
		set folder(round:generation) "user"
		set folder(levels) "qualif"
		Tree::itemconfigure $gui(w:tree) $f -image imgCup
	} else {
		set folder(round:generation) "auto"
		folder:init:normal $f $folder(label) $folder(dances) $folder(mode)
		Tree::itemconfigure $gui(w:tree) $f -image imgCup
	}
	# mise à jour des onglets
	gui:select:folder:showTabs $f
	# calcule le nombre de rounds & ajuste Tree
	manage:rounds:generate $f auto
}
