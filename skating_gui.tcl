##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

namespace eval skating {
	variable event
	variable gui
	# init variables
	set event(v:folder) 1
	set event(folders) {}
	set gui(v:lastselection) ""
	set gui(v:folder) ""
	set gui(v:round) ""
	set gui(v:dance) ""
	set gui(v:inEdit) 0
	set gui(v:inEvent) 0
	set gui(v:db:modified) 0
	set gui(v:autosave:timer) -1

	# gestion des couleurs
	button .__b
	set gui(t:on:bg) [.__b cget -background]
	set gui(t:on:abg) [.__b cget -activebackground]
	set gui(t:off:bg) #ffc37b
	set gui(t:off:abg) #ffd29b
	global tcl_platform
	if {$tcl_platform(platform) == "windows"} {
		set gui(t:off:abg) $gui(t:off:bg)
	}
	destroy .__b
	# charge image
	image create photo imgNew -file images/new.gif
	image create photo imgLoad -file images/open.gif
	image create photo imgSave -file images/save.gif
	image create photo imgPrint -file images/print.gif
	image create photo imgPrintResult -file images/print_result.gif
	image create photo imgPrintList -file images/print_list.gif
	image create photo imgPrintSetup -file images/print_setup.gif
	image create photo imgOption -file images/option.gif

	image create photo imgOK -file images/but_ok.gif
	image create photo imgNOK -file images/but_cancel.gif

	image create photo imgNewFolder -file images/tb_newfolder.gif
	image create photo imgDeleteFolder -file images/tb_deletefolder.gif
	image create photo imgUp -file images/tb_up.gif
	image create photo imgDown -file images/tb_down.gif
	image create photo imgLeft -file images/tb_left.gif
	image create photo imgRight -file images/tb_right.gif

	image create photo imgCup -file images/icn_cup.gif
	image create photo imgCupTen -file images/icn_cupten.gif
	image create photo imgRound -file images/icn_round.gif
	image create photo imgRoundMain -file images/icn_round_main.gif
	image create photo imgRoundChance -file images/icn_round_chance.gif
	image create photo imgResult -file images/icn_result.gif

	image create photo imgLogo -file images/small_logo.gif

	image create photo imgPrintGlobal -file images/global.gif
	image create photo imgPrintSheets -file images/sheets.gif
	image create photo imgPrintCup -file images/cup1_big.gif
	image create photo imgPrintWeb -file images/world.gif
}

#-------------------------------------------------------------------------------------------------

proc skating::gui:exit {} {
variable gui
global msg

	# boite de confirmation si fichier modifié
	if {$gui(v:modified)} {
		set doit [tk_messageBox -icon "question" -type yesnocancel -default yes \
							-title $msg(dlg:question) -message $msg(dlg:modifiedSave)]
		if {$doit == "cancel"} {
			return
		}
		if {$doit == "yes"} {
			gui:save 0
		}
	} else {
		set doit [tk_messageBox -icon "question" -type okcancel -default ok \
							-title $msg(dlg:question) -message $msg(dlg:reallyQuit)]
		if {$doit == "cancel"} {
			return
		}
	}
	# boite de confirmation si database modifiée
#TRACE "checking database = $gui(v:db:modified)"
	if {$gui(v:db:modified)} {
#  		set doit [tk_messageBox -icon "question" -type yesno -default yes \
#  							-title $msg(dlg:question) -message $msg(dlg:modifiedDB)]
#  		if {$doit == "yes"} {
			event:database:save
#  		}
	}
	# fin du programme
	exit
}


proc skating::gui:setTitle {} {
variable gui

	set title "\[Skating System Software\]  [file tail $gui(v:filename)]"
	# @OCM@ détails about OCM link
	if {$gui(pref:mode:linkOCM) && $gui(v:linkOCM:logon)} {
		append title "  --  Scrutineer #$gui(pref:mode:linkOCM:id) on $gui(pref:mode:linkOCM:server)"
	}
	wm title $gui(w:top) $title
}

#-------------------------------------------------------------------------------------------------

proc skating::gui:main {w {redisplay 0}} {
variable gui
global msg

	if {$redisplay == 1} {
		set geometry [winfo geometry $w]
		destroy $w
	}

	toplevel $w
	set gui(w:top) $w
	wm title $w "\[Skating System Software\]"
	wm protocol $w WM_DELETE_WINDOW "skating::gui:exit"
	bind all <Control-q> "skating::gui:exit"

	# en haut, une toolbar
	set tb [frame $w.tb]
	button $tb.new -image imgNew -bd 1 -command "skating::gui:new"
	button $tb.load -image imgLoad -bd 1 -command "skating::gui:load"
	button $tb.save -image imgSave -bd 1 -command "skating::gui:save 0"
	button $tb.print -image imgPrint -bd 1 -command "set skating::gui(v:print:updateDisplay) 1 ; skating::gui:print"
	button $tb.options -image imgOption -bd 1 -command "skating::gui:options"
	pack [frame $tb.sep1 -width 5] $tb.new $tb.load $tb.save $tb.options -side left
	pack [frame $tb.sep2 -width 5] $tb.print -side left
	#----
	DynamicHelp::register $tb.new balloon $msg(tip:new)
	bind all <Control-n> "$tb.new invoke"
	DynamicHelp::register $tb.load balloon $msg(tip:open)
	bind all <Control-o> "$tb.load invoke"
	DynamicHelp::register $tb.save balloon $msg(tip:save)
	bind all <Control-s> "skating::gui:save 1"
	DynamicHelp::register $tb.options balloon $msg(tip:options)
	bind all <Control-t> "$tb.options invoke"
	DynamicHelp::register $tb.print balloon $msg(tip:print)
	bind all <Control-p> "$tb.print invoke"

	# label pour afficher sélection courante
	label $tb.folder -textvariable ::skating::displayFolder -font competition
	set gui(w:labelround) [label $tb.round -textvariable ::skating::displayRound -font competition \
							-fg $gui(color:competition) -width 15]
	pack $tb.folder -side left -expand true -fill x
	pack $tb.round -side right


	# une paned window
    set pw [PanedWindow::create $w.pw -side top]
	  # à gauche, les dossiers
	  set pane [PanedWindow::add $pw -weight 0]
	  # un bouton pour définir événement
	  button $pane.def -text $msg(eventManagement) -bd 1 -command "skating::gui:event"
	  pack $pane.def [frame $pane.sep0 -height 5] -fill x -side top
	  DynamicHelp::register $pane.def balloon $msg(tip:event)
	  bind all <Control-d> "$pane.def invoke"
	  # liste des dossiers
	  set sw [ScrolledWindow::create $pane.sw -relief sunken -borderwidth 1]
	  set tree [Tree::create [ScrolledWindow::getframe $sw].tree \
						-bg gray95 -relief flat -borderwidth 0 -width 17 -height 1 \
						-highlightthickness 0 -padx 20 -deltay 16 \
						-selectbackground $gui(color:selection) \
						-highlightbackground $gui(color:selection)]
	  Tree::configure $tree \
			-opencmd  "Tree::opentree $tree" \
			-closecmd "Tree::closetree $tree"
	  Tree::bindText $tree <ButtonPress-1> "skating::gui:select 1"
	  Tree::bindText $tree <Double-ButtonPress-1> "skating::gui:select 2"
	  Tree::bindText $tree <ButtonPress-3> "skating::gui:popup %X %Y"

	  ScrolledWindow::setwidget $sw $tree
      pack $sw -side top -expand yes -fill both
	  # toolbar pour gestion dossier
	  set tb2 [frame $pane.tb]
	  button $tb2.new -image imgNewFolder -bd 1 -command "skating::folder:new"
	  bind $tb2.new <ButtonRelease-3> "skating::folder:template"
	  bind all <Control-c> "$tb2.new invoke"
#	  button $tb2.new2 -image imgNewFolder -bd 1 -command "skating::folder:template"

	  button $tb2.delete -image imgDeleteFolder -bd 1 -command "skating::folder:delete"
	  bind all <Control-Delete> "$tb2.delete invoke"

	  button $tb2.up -image imgUp -bd 1 -command "skating::folder:up"
	  bind all <Control-Up> "$tb2.up invoke"

	  button $tb2.down -image imgDown -bd 1 -command "skating::folder:down"
	  bind all <Control-Down> "$tb2.down invoke"

	  pack $tb2.new $tb2.delete -side left
	  pack [frame $tb2.sep1 -width 5] $tb2.up $tb2.down -side left
	  pack [frame $pane.sep1 -height 5] $tb2 -fill x
	  #----
	  DynamicHelp::register $tb2.new balloon $msg(tip:comp:new)
	  DynamicHelp::register $tb2.delete balloon $msg(tip:comp:delete)
	  DynamicHelp::register $tb2.up balloon $msg(tip:comp:moveup)
	  DynamicHelp::register $tb2.down balloon $msg(tip:comp:movedown)

	  # à droite, une partie avec diverses info
	  set pane [PanedWindow::add $pw -weight 1]
	  set notebook [NoteBook::create $pane.nb]
      pack $notebook -side top -expand yes -fill both


	# mise en forme
	pack $tb -side top -pady 5 -fill x
	pack [frame $w.sep -height 2 -bd 2 -relief raise] -side top -fill x
	pack $pw -side top -padx 5 -pady 5 -expand true -fill both

	# mémorise les widgets utiles
	set gui(w:tb) $tb
	set gui(w:tree) $tree
	set gui(w:notebook) $notebook

	# binding pour le mode d'édition rapide
	fastentry:init $w

	# initialise splash screen
	gui:splash:init

	#---------------------
	if {$redisplay == 0} {
		# crée un dossier, sans checking pour sauvegarde
		gui:new 0
		# initialise les bases de données
		event:database:start
	} else {
		wm geometry $w $geometry
		gui:redisplay
		# reset les variables d'état car plus rien ne sera sélectionné
		set gui(v:lastselection) ""
		set gui(v:folder) ""
		set gui(v:round) ""
		set gui(v:dance) ""
		set gui(v:inEdit) 0
		set gui(v:inEvent) 0
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::gui:select {num node} {
global msg
variable gui
variable dblclick


TRACE "[Tree::itemcget $gui(w:tree) $node -data]"
	set dblclick 1
	if {$num < 2} {
		# trouve le type d'objet, un parmi:
		#		folder
		#		round <round>
		#		dance <dance>
		#		result
		set tmp [Tree::itemcget $gui(w:tree) $node -data]
		set type [lindex $tmp 0]
		set subtype [lindex $tmp 1]
		# gère le changement de nom "en-ligne"
		if {$num && $type == "folder" && [lsearch [Tree::selection $gui(w:tree) get] $node] != -1} {
			unset dblclick
			after 500 "skating::gui:tree:edit $node"
		} elseif {$num && $type == "round" && [lsearch [Tree::selection $gui(w:tree) get] $node] != -1} {
			unset dblclick
			after 500 "skating::manage:rounds:editName $node"
		}
		# format du node = folder
		# format du node = folder.<round>(.2)?
		# format du node = folder.__result__
		# format du node = folder.<dance>
		set selection $node
		set idx [string first "." $node]
		if {$idx != -1} {
			incr idx -1
			set round [string range $node [expr $idx+2] end]
			set node [string range $node 0 $idx]
		} else {
			set round ""
		}
		# routine spécifique en fonction du type
		if {$selection != $gui(v:lastselection)} {
			if {[skating::gui:select:$type $node $subtype]} {
			    Tree::selection $gui(w:tree) set $selection
				set ::skating::displayFolder [set skating::${node}(label)]
				if {$type == "dance"} {
					set ::skating::displayRound $subtype
				} elseif {$type == "round"} {
					set ::skating::displayRound [rounds:getName $node $round]
				} else {
					set ::skating::displayRound ""
				}
				set gui(v:lastselection) $selection
				if {[set skating::${node}(mode)] != "ten"} {
					# mémorise le round & mode d'édition rapide en fonction du type
					set gui(v:folder) $node
					set gui(v:round) $round
					fastentry:mode $round
				}
			}
		}
		# on n'est pas en mode sélection
		set skating::gui(v:inEdit) 0

	} else {
		# open/close le noeud si dossier
		if {[Tree::itemcget $gui(w:tree) $node -data] == "folder"} {
			if {[Tree::itemcget $gui(w:tree) $node -open]} {
				Tree::closetree $gui(w:tree) $node
			} else {
				Tree::opentree $gui(w:tree) $node
			}
		}
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::gui:tree:edit {node} {
variable gui
variable dblclick
variable $node
upvar 0 $node folder


#puts "skating::gui:tree:edit {$node}"
    if {[info exists dblclick]} {
		return
    }

	if {[lsearch [Tree::selection $gui(w:tree) get] $node] != -1 } {
		set gui(v:inEdit) 1
		set res [Tree::edit $gui(w:tree) $node $folder(label)]
		set gui(v:inEdit) 0
		if {$res != ""} {
			Tree::itemconfigure $gui(w:tree) $node -text $res
			set ::skating::displayFolder $res
			set ::skating::displayRound ""
			set folder(label) $res
			if {$folder(mode) == "ten"} {
				foreach dance $folder(dances) {
					set ::skating::$node.${dance}(label) $res
				}
			}
			# modifications ...
			set gui(v:modified) 1
		}
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::gui:popup {x y node} {
global msg
variable gui

#puts "skating::gui:popup {'$node'} / [Tree::itemcget $gui(w:tree) $node -data]"

	# sélectionne le noeud
	skating::gui:select 0 $node

	# trouve le type d'objet, un parmi:
	#		folder
	#		round <round>
	#		dance <dance>
	#		result
	set tmp [Tree::itemcget $gui(w:tree) $node -data]
	set type [lindex $tmp 0]

	# affiche un menu contextuel
	destroy .popup
	set m [menu .popup -tearoff 0 -bd 1]
	if {$type == "folder"} {
		$m add command -label $msg(rename) \
				-command "catch { unset skating::dblclick } ; skating::gui:tree:edit $node"
	} elseif {$type == "round"} {
		$m add command -label $msg(rename) \
				-command "catch { unset skating::dblclick } ; skating::manage:rounds:editName $node"
	} else {
		return
	}
	tk_popup $m $x $y
}


#=================================================================================================
#
#	Gestion des folder (= une compétition)
#
#=================================================================================================

proc skating::gui:select:folder {f dummy} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder


	# reset le notebook
	foreach p [NoteBook::pages $gui(w:notebook)] {
		NoteBook::delete $gui(w:notebook) $p
	}

	# onglet de synthèse + attributs définis par utilisateur
	set general [NoteBook::insert $gui(w:notebook) end "general" -text $msg(general) \
						-raisecmd "skating::manage:general:init [list $f]"]

	# onglet pour le choix des danses
	set dances [NoteBook::insert $gui(w:notebook) end "dances" -text $msg(dances) \
						-raisecmd "skating::fastentry:mode {}"]
	  manage:dances:init $f $dances

	# onglets conditionnels
	gui:select:folder:showTabs $f

	# montrer l'onglet définition
	if {[llength $folder(dances)]} {
		NoteBook::raise $gui(w:notebook) "general"
	} else {
		NoteBook::raise $gui(w:notebook) "dances"
	}
	update
	# sélection OK
	set gui(v:folder) $f
	set gui(v:round) ""
	set gui(v:dance) ""
	return 1
}

proc skating::gui:select:folder:showTabs {f} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder

	catch { NoteBook::delete $gui(w:notebook) "couples" }
	catch { NoteBook::delete $gui(w:notebook) "rounds" }
	catch { NoteBook::delete $gui(w:notebook) "judges" }

	if {$folder(mode) != "ten"} {
		# onglet pour le choix des couples
		set couples [NoteBook::insert $gui(w:notebook) end "couples" -text $msg(couples) \
							-raisecmd "skating::fastentry:mode init:couples"]
		  bind $couples <Visibility> "focus $couples"
		  #manage:couples:init $f $couples
		  	NoteBook::itemconfigure	$gui(w:notebook) "couples" \
					-createcmd "skating::manage:couples:init [list $f] $couples"

		if {$folder(mode) != "qualif"} {
			# onglet pour le choix des rounds
			set gui(t:roundsNeedInit) 1
			set rounds [NoteBook::insert $gui(w:notebook) end "rounds" -text $msg(roundManagement) \
								-raisecmd "skating::manage:rounds:refresh [list $f]"]
		}

		# onglet pour le choix des juges
		set judges [NoteBook::insert $gui(w:notebook) end "judges" -text $msg(judges) \
							-raisecmd "skating::manage:judges:init [list $f]"]
	}
}


#=================================================================================================
#
#	Gestion des rounds dans une comptétition
#
#=================================================================================================

proc skating::gui:select:round {f type} {
variable $f
upvar 0 $f folder
variable gui
global msg

TRACEFS "round='$gui(v:round)'"

	# vérifie si valide de sélectionner un round
	if {!([llength $folder(dances)] && [llength $folder(couples:names)] \
			&& [llength $folder(judges:$type)])} {
		tk_messageBox -icon "info" -type ok -default ok \
				-title $msg(dlg:information) -message $msg(dlg:notDefined)
		return 0
	}
	# vérifie si on peut accéder au type (les rounds supérieurs doivent être validés)
	if {![info exists folder(couples:$type)]} {
		if {$type == [lindex $folder(levels) 0]} {
			set folder(couples:$type) $folder(couples:all)
		} else {
			tk_messageBox -icon "info" -type ok -default ok \
					-title $msg(dlg:information) -message $msg(dlg:notSelected)
			return 0
		}
	}

	# reset le notebook
	foreach p [NoteBook::pages $gui(w:notebook)] {
		NoteBook::delete $gui(w:notebook) $p
	}
	#----------------------------------
	# onglets pour les danses du folder
	foreach d $folder(dances) {
		set check ""
		if {$type == "finale"} {
			set check "skating::notes:refresh [list $f] [list $d] ;"
		}

		set page [NoteBook::insert $gui(w:notebook) end [join $d "_"] \
					-text $d -raisecmd "skating::fastentry:deselectAll;
										skating::fastentry:mode $type;
										$check
										set ::skating::gui(v:dance) [list $d];
										set ::skating::gui(v:judge) 0;
										skating::fastentry:selectJudge;
										skating::round:deselectAll $type [list $d]"]

		set sw [ScrolledWindow::create $page.sw \
					-scrollbar both -auto both -relief sunken -borderwidth 1]
		if {$type == "finale"} {
			set canvas [gui:notes [ScrolledWindow::getframe $sw] $f $d]
		} else {
			if {[llength $folder(couples:$type)]*[llength $folder(judges:$type)]/17 > 15} {
				ScrolledWindow::configure $sw -auto horizontal
			}
			set canvas [gui:round [ScrolledWindow::getframe $sw] $f $d $type]
		}
		ScrolledWindow::setwidget $sw $canvas
		# mise en page
		pack $sw -side top -pady 5 -expand true -fill both
		# indication pour nombre à sélectionner

		# @OCM@: récupération des notes depuis OCM
		if {$gui(pref:mode:linkOCM) && $gui(pref:mode:linkOCM:wireless)} {
			set tf [TitleFrame::create $page.ocm -text $msg(getMarksFromOCM)]
			set sub [TitleFrame::getframe $tf]
			button $sub.ocm1 -width 15 -text "$d" -bd 1 -padx 0 -pady 1 \
					-command "OCM::getMarks $f $type [list $d] [list $d]"
			button $sub.ocm2 -width 15 -text "All " -bd 1 -padx 0 -pady 1 \
					-command "OCM::getMarks $f $type all [list $d]"
			pack $sub.ocm1 $sub.ocm2 -side left -padx 5
			pack $tf -side left
		}
		if {$type == "finale"} {
			#==== FINALE ====
			#---- choix de couples à exclure
			set tf [TitleFrame::create $page.exclude -text $msg(couplesToExclude)]
			set sub [TitleFrame::getframe $tf]
			set gui(w:exclusion:$d) $sub
			foreach c $folder(couples:finale) {
				button $sub.$c -width 5 -text "$c" -bd 1 -padx 0 -pady 1 \
						-command "skating::finale:exclusion:toggle [list $f] [list $d] $c"
				pack $sub.$c -side left -padx 5
			}
			pack $tf -side left -fill x -expand true
			# mise-à-jour
			finale:exclusion:display $f $d

		} else {
			#==== ROUND ====
			#---- à skipper, indication nb à reprendre, activation Heats
			# skip
			set tf [TitleFrame::create $page.skip -text $msg(keep)]
			set sub [TitleFrame::getframe $tf]
			checkbutton $sub.skip -text $msg(useInResult) -bd 1 \
					-command "skating::selection:skip $sub.skip [list $f] $type [list $d]" \
					-variable "__$d"
			selection:skip:init $sub.skip $f $type $d
			pack $sub.skip -side left -fill x
			pack $tf -side left -fill x
			# indication
			set tf [TitleFrame::create $page.nb -text $msg(hint)]
			set sub [TitleFrame::getframe $tf]
			set nb $folder(round:$type:nb)
			if {[string first "." $type] != -1} {
				label $sub.nb -anchor w \
						-text "$msg(rescue) $nb $msg(among) [llength $folder(couples:$type)] $msg(remaining)"
			} else {
				label $sub.nb -anchor w \
						-text "$msg(select) $nb $msg(among) [llength $folder(couples:$type)] $msg(competing)"
			}
			pack $sub.nb -side left -fill x
			pack [frame $page.sep -width 10] -side left
			pack $tf -side left -fill x -expand true
			# utilisation des Heats
			set tf [TitleFrame::create $page.h -text $msg(Heats)]
			set sub [TitleFrame::getframe $tf]
			set skating::gui(t:useHeats:$type:$d) 0
			checkbutton $sub.b -text $msg(active) -bd 1 -variable skating::gui(t:useHeats:$type:$d) \
					-command "skating::round:draw $canvas [list $f] [list $d] $type"
			pack $sub.b -side left -fill x
			pack [frame $page.sep2 -width 10] -side left
			pack $tf -side left -fill x
		}
	}

	#------------------------
	# onglet pour le résultat
	result:createTab $f $type full

	#-------------------------------------------------------
	# onglets pour la saisie par juge en finale non 10-danse
	if {$type == "finale" && $gui(pref:inputByJudgeInFinale) && [string first "." $f] == -1} {
		foreach judge [lsort -command skating::event:judges:sort $folder(judges:finale)] {
			set page [NoteBook::insert $gui(w:notebook) end __$judge \
						-text $judge -raisecmd "skating::finale:refresh [list $f] $judge;
												skating::fastentry:deselectAll;
												skating::fastentry:mode {}"]
			finale:init $page $f $judge
		}
	}

	#-----------------------------------------
	# sélectionne la première danse par défaut
	NoteBook::raise $gui(w:notebook) [join [lindex $folder(dances) 0] "_"]

	# sélection OK
	return 1
}

# get color for normal/disabled state
checkbutton .b
set colorNormal [.b cget -foreground]
set colorDisabled [.b cget -disabledforeground]


#=================================================================================================
#
#	Gestion des résultats pour une compétition
#
#=================================================================================================

proc skating::gui:select:result {f type} {
variable $f
upvar 0 $f folder

	gui:select:result:$folder(mode) $f $type
}

proc skating::gui:select:result:normal {f type} {
variable $f
upvar 0 $f folder
variable gui
global msg

#puts "skating::gui:select:result:normal {$f $type}"
	if {![info exists folder(couples:finale)] || ![class:dances $f]} {
		# pas de sélection possible car finale non classable
		return 0
	}

	# reset le notebook
	foreach p [NoteBook::pages $gui(w:notebook)] {
		NoteBook::delete $gui(w:notebook) $p
	}
	#---- ajoute la(es) page(s)
	# résultat global 
	set result [NoteBook::insert $gui(w:notebook) end "result" -text $msg(result)]
	results:init $f $result
	# pour chaque round
	foreach round [reverse $folder(levels)] {
		result:createTab $f $round "summary"
	}
	# montrer l'onglet résultat
	NoteBook::raise $gui(w:notebook) "result"

	# sélection OK
	return 1
}

proc skating::gui:select:result:ten {f type} {
variable $f
upvar 0 $f folder
variable gui
global msg

#puts "skating::gui:select:result:ten {$f $type}"
	if {![class:dances $f]} {
		# pas de sélection possible car finale non classable
		return 0
	}

	# reset le notebook
	foreach p [NoteBook::pages $gui(w:notebook)] {
		NoteBook::delete $gui(w:notebook) $p
	}
	#---- ajoute la(es) page(s)
	# résultat global
	set result [NoteBook::insert $gui(w:notebook) end "result" -text $msg(result)]
		NoteBook::raise $gui(w:notebook) "result"
		ten:overall:results $f $result

	# pour chaque dance
	set j 0
	foreach dance $folder(dances) {
		results:init $f.$dance [NoteBook::insert $gui(w:notebook) end $j -text $dance] $dance
		incr j
		# interactivité
		update
	}

	# sélection OK
	set gui(v:folder) $f
	set gui(v:round) "__result__"
	set gui(v:dance) ""
	return 1
}


#=================================================================================================
#
#	Gestion d'un danse pour le mode 10-danses (chaque danse est gérée de manière indépendante)
#
#=================================================================================================

proc skating::gui:select:dance {f dance} {
variable $f
upvar 0 $f folder
variable gui
global msg

#puts "skating::gui:select:dance {$f $dance}"
	# reset le notebook
	foreach p [NoteBook::pages $gui(w:notebook)] {
		NoteBook::delete $gui(w:notebook) $p
	}

	# initialisations
	set ::skating::gui(v:dance) $dance
	set ::skating::gui(v:folder) $f.$dance
	set ::skating::gui(v:round) ""

	# construit les onglets pour les rounds
	ten:init $f.$dance $gui(w:notebook) $dance

	# sélection OK
	return 1
}
