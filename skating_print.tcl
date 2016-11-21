##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion des impressions
#
#=================================================================================================

namespace eval skating {
	set plugins(print) [list]
}

array set skating::gui {
	pref:print:format				ps
	pref:print:paper				a4
	pref:print:margin:left			30
	pref:print:margin:right			30
	pref:print:margin:top			30
	pref:print:margin:bottom		39

	pref:print:mode					"summary:place"

	pref:print:orientation			-portrait
	pref:print:judgesInSummary		1

	pref:print:enrollment			alphabetic
	pref:print:enrollment:bySchool	1
	pref:print:enrollment:pageBreak	1
	pref:print:enrollment:results	1
	pref:print:enrollment:judges	1
	pref:print:enrollment:dances	1
	pref:print:enrollment:select	1
	pref:print:enrollment:pageBreak2	1

	pref:print:inputGrid			1
	pref:print:heats:print			1
	pref:print:heats:mode			auto
	pref:print:heats:type			sub
 	pref:print:heats:size			12
 	pref:print:heats:grouping		number
	pref:print:heats:withSheets		1
	pref:print:heats:lists			3
	pref:print:sheets:spareBoxes	0
	pref:print:sheets:newOnJudge	1
	pref:print:sheets:sign			1
	pref:print:sheets:compact		0

	pref:print:color				1
	pref:print:comment				0
	pref:print:listCouples			1
	pref:print:listJudges			1
	pref:print:order:rounds			0
	pref:print:useLetters			1

	pref:print:names:judges			1
	pref:print:names:couples		0

	pref:print:names:judgesResult	1
	pref:print:names:couplesResult	1
	pref:print:explain				1
	pref:print:place				1
	pref:print:place:nb				9
	pref:print:sign					0
	pref:print:placeAverage			0

	pref:print:useSmallFont			0

	pref:print:smaller:skipY		10
	pref:print:small:skipY			20
	pref:print:medium:skipY			30
	pref:print:big:skipY			40

	pref:print:panelsPerRow			2
	pref:print:sheetsMode			sheets:round:portrait2

	v:print:copies					1
}


# demande utilisateur dans 'what' = liste avec tab to raise + item to select
#
#	====================+=================================	
#	Notebook Tab		|	Item
#	====================+=================================
#	global				|	event:couples_judges
#						|	event:judges
#						|	event:panels
#						|	event:enrollment:competitions
#						|	event:enrollment:couples
#						|	event:enrollment:judges
#						|	event:competitions
#	--------------------+---------------------------------
#	markSheets			|	sheets:round:portrait1
#						|	sheets:round:portrait2
#						|	sheets:round:portrait4
#						|	sheets:round:landscape1
#						|	sheets:round:landscape2
#						|	sheets:round:landscape4
#	--------------------+---------------------------------
#	results				|	result
#						|	folder
#						|	round
#						|	summary:place
#						|	summary:couple
#						|	summary:idsf:report
#						|	summary:idsf:table
#						|	all
#						|	all:summary:place
#						|	all:summary:couple
#						|	all:summary:idsf:report
#						|	all:summary:idsf:table
#	--------------------+---------------------------------	
#	web					|	web
#	--------------------+---------------------------------	

proc skating::gui:print {{userChoice {}}} {
global tcl_platform
global msg
variable event
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder


TRACE "folder = $gui(v:folder) / round = $gui(v:round) / dance = $gui(v:dance)"
	# test si qqch à imprimer
	if {[llength $event(folders)] == 0} {
		bell
		return
	}

	# dialogue pour demander préférences
	destroy .dialog
	toplevel .dialog
	wm title .dialog $msg(print)
	wm withdraw .dialog
	set skating::gui(pref:print:what) ""
	set dialogWidth 610
	set dialogHeight 250

	# test si 10-danses
	set ten 0
	set subten 0
	if {$gui(v:folder) != "" && [string first "." $gui(v:folder)] != -1} {
		set subten 1
	} elseif {$gui(v:folder) != "" && $folder(mode) == "ten"} {
		set ten 1
	}
	set gui(v:ten) $ten
	set gui(v:subten) $subten

	# génère un nom (tronque si trop grand)
	if {[info exists folder(label)]} {
		set label $folder(label)
	} else {
		set label ""
	}
	if {[string length $label] > 50} {
		set label "[string range $label 0 50]..."
	}


	# graphiques dépendant de la plteforme
	label .__l
	set selectfont [.__l cget -font]
	destroy .__l
	if {$::tcl_platform(platform) == "windows"} {
		set selectcolor {}
		set selectforeground darkblue
		set selectfont "$selectfont bold"
	} else {
		set selectcolor steelblue
		set selectforeground black
	}

	# frame du dialogue
	set top [frame .dialog.top]
	set nb [NoteBook::create $top.nb]

	  #===============================
	  # impression de données globales
	  set f [NoteBook::insert $nb end "global" -text " $msg(eventSheets)" \
							-image imgPrintGlobal -background gray72]
	  set setLandscape 0
	  set glob [TitleFrame::create $f.g -text $msg(dlg:print) -font $selectfont]
	  set sub [TitleFrame::getframe $glob]

	  #-- liste des competitions
	  set ff [frame $sub.list -bd 0]
		  radiobutton $ff.l -bd 1 -text $msg(competitionsList) \
					-variable skating::gui(pref:print:what) -value event:competitions \
					-command "set skating::gui(pref:print:orientation) -portrait"
		  pack $ff.l -anchor w

	  #-- couples, juges, enrollment juges
	  set ff [frame $sub.j -bd 0]
		  # les couples & juges
		  radiobutton $ff.event -bd 1 -text $msg(couplesAndJudges) \
					-variable skating::gui(pref:print:what) -value event:couples_judges \
					-command "set skating::gui(pref:print:orientation) -portrait"
		  if {[NoteBook::raised $gui(w:notebook)] == "couples"} {
			  set skating::gui(pref:print:what) event:couples_judges
			  NoteBook::raise $nb "global"
		  }
		  # les juges
		  radiobutton $ff.jo -bd 1 -text $msg(judgesOnly) \
					-variable skating::gui(pref:print:what) -value event:judges \
					-command "set skating::gui(pref:print:orientation) -portrait"
		  if {[NoteBook::raised $gui(w:notebook)] == "judges"} {
			  set skating::gui(pref:print:what) event:judges
			  NoteBook::raise $nb "global"
		  }
		  # la participation des juges aux compétitions
		  radiobutton $ff.jp -bd 1 -text $msg(judgesEnrollment) \
					-variable skating::gui(pref:print:what) -value event:enrollment:judges \
					-command "set skating::gui(pref:print:orientation) -portrait"
	  pack $ff.event [frame $ff.sep -width 25] $ff.jo [frame $ff.sep2 -width 25] $ff.jp -side left


	  #-- les panels
	  set ff [frame $sub.p -bd 0]
		  radiobutton $ff.b -bd 1 -text $msg(listPanels) \
				-variable skating::gui(pref:print:what) -value event:panels \
				-command "set skating::gui(pref:print:orientation) -portrait"
		  SpinBox::create $ff.nb -label "$msg(listPanels:perRow) " -editable false \
				-range {2 6 1} -bd 1 -justify right -width 1 -entrybg gray95 \
				-labelfont normal -textvariable skating::gui(pref:print:panelsPerRow)
		  pack $ff.b -anchor w
		  pack [frame $ff.sep -width 50] $ff.nb -anchor e -side left
	  if {[NoteBook::raised $gui(w:notebook)] == "panels"} {
		  set skating::gui(pref:print:what) event:panels
		  NoteBook::raise $nb "global"
	  }

	  #-- tableau de synthèse couples/compétitions
	  set ff [frame $sub.entries -bd 0]
		  radiobutton $ff.b -bd 1 -text $msg(checkEnrollment) \
					-variable skating::gui(pref:print:what) -value event:enrollment:couples \
					-command "set skating::gui(pref:print:orientation) -portrait"
		  radiobutton $ff.n -bd 1 -text $msg(checkEnrollment:number) -font normal \
					-variable skating::gui(pref:print:enrollment) -value number \
					-command "set skating::gui(pref:print:what) event:enrollment:couples"
		  radiobutton $ff.a -bd 1 -text $msg(checkEnrollment:alphabetic) -font normal \
					-variable skating::gui(pref:print:enrollment) -value alphabetic \
					-command "set skating::gui(pref:print:what) event:enrollment:couples"
		  frame $ff.g
		  if {$event(useCountry)} {
			  set text1 $msg(checkEnrollment:groupByCountry)
			  set text2 $msg(checkEnrollment:pageBreak2)
		  } else {
			  set text1 $msg(checkEnrollment:groupBySchool)
			  set text2 $msg(checkEnrollment:pageBreak)
		  }
		  checkbutton $ff.g.b -bd 1 -text $text1 -font normal \
					-variable skating::gui(pref:print:enrollment:bySchool) \
					-onvalue 1 -offvalue 0 \
					-command "set skating::gui(pref:print:what) event:enrollment:couples ; \
							  if {\$skating::gui(pref:print:enrollment:bySchool)} { $ff.p.b configure -state normal
							  } else { $ff.p.b configure -state disabled }"
		  frame $ff.p
		  checkbutton $ff.p.b -bd 1 -text $text2 -font normal \
					-variable skating::gui(pref:print:enrollment:pageBreak) \
					-onvalue 1 -offvalue 0 \
					-command "set skating::gui(pref:print:what) event:enrollment:couples"
		  frame $ff.r
		  checkbutton $ff.r.b -bd 1 -text $msg(checkEnrollment:withResults) -font normal \
					-variable skating::gui(pref:print:enrollment:results) \
					-onvalue 1 -offvalue 0 \
					-command "set skating::gui(pref:print:what) event:enrollment:couples"
		  if {$skating::gui(pref:print:enrollment:bySchool)} {
			  $ff.p.b configure -state normal
		  } else {
			  $ff.p.b configure -state disabled
		  }
		  pack $ff.r -anchor w -side bottom
			pack [frame $ff.r.sep -width 50] $ff.r.b -anchor e -side left
		  pack $ff.p -anchor w -side bottom
			pack [frame $ff.p.sep -width 50] $ff.p.b -anchor e -side left
		  pack $ff.g -anchor w -side bottom
			pack [frame $ff.g.sep -width 50] $ff.g.b -anchor e -side left
		  pack $ff.b -anchor w
		  pack [frame $ff.sep -width 50] $ff.a $ff.n -anchor e -side left
		  pack $ff.n -padx 10

	  if {$gui(v:folder) == "" && [NoteBook::raised $gui(w:notebook)] == "general"} {
		  set skating::gui(pref:print:what) event:competitions
		  NoteBook::raise $nb "global"
	  } elseif {$gui(v:folder) == "" && [NoteBook::raised $gui(w:notebook)] == "couples"} {
		  set skating::gui(pref:print:what) event:enrollment:couples
		  NoteBook::raise $nb "global"
	  } elseif {$gui(v:folder) == "" && [NoteBook::raised $gui(w:notebook)] == "judges"} {
		  set skating::gui(pref:print:what) event:enrollment:judges
		  NoteBook::raise $nb "global"
	  } elseif {$gui(v:folder) == "" && [NoteBook::raised $gui(w:notebook)] == "panels"} {
		  set skating::gui(pref:print:what) event:panels
		  NoteBook::raise $nb "global"
	  }

	  #-- tableau de synthèse couples/compétitions
	  set ff [frame $sub.compet -bd 0]
		  radiobutton $ff.l -bd 1 -text $msg(competitionsEnrollment) \
					-variable skating::gui(pref:print:what) -value event:enrollment:competitions \
					-command "set skating::gui(pref:print:orientation) -portrait"
		  pack $ff.l -side left

	  pack $sub.list -pady 10 -side top -anchor w -padx 5
	  pack $sub.j $sub.p $sub.entries $sub.compet -side top -anchor w -padx 5
	  pack $sub.p $sub.compet -pady 10
	  pack $glob -side top -anchor w -padx 5 -fill both

	  #--------
	  # options
	  set options [TitleFrame::create $f.options -text $msg(print:options) -font $selectfont]
	  set sub [TitleFrame::getframe $options]
	  #---- orientation du papier
	  if {([info exists folder(dances)] && [llength $folder(dances)] > 4)
				|| $setLandscape} {
		  set gui(pref:print:orientation) "-landscape"
	  } else {
		  set gui(pref:print:orientation) "-portrait"
	  }
	  set ff [frame $sub.orient -bd 0]
	  label $ff.t -text $msg(orientation) -foreground $selectforeground -font $selectfont
	  radiobutton $ff.p -bd 1 -text $msg(portrait) -font normal -selectcolor $selectcolor \
				-variable skating::gui(pref:print:orientation) -value -portrait
	  radiobutton $ff.l -bd 1 -text $msg(landscape) -font normal -selectcolor $selectcolor \
				-variable skating::gui(pref:print:orientation) -value -landscape
	  grid $ff.t - -	-sticky w
	  grid [frame $ff.sep1 -width 50] $ff.p $ff.l -sticky w -padx 5
	  #---- mise en page options
	  pack $sub.orient -side top -anchor w -padx 5
	  pack $options -side top -anchor w -padx 5 -pady 10 -fill both
	  # ajuste la taille de la boite de dialogue
	  update idletasks
	  if {[winfo reqwidth $f] > $dialogWidth} { set dialogWidth [winfo reqwidth $f] }
	  if {[winfo reqheight $f] > $dialogHeight} { set dialogHeight [winfo reqheight $f] }


	  #=================================================
	  # impression de feuilles de marques pour les juges
	  set f [NoteBook::insert $nb end "markSheets" -text " $msg(marksSheets)" \
							-image imgPrintSheets -background gray72]
	  set sheets [TitleFrame::create $f.s -text $msg(dlg:print) -font $selectfont]
	  set sub [TitleFrame::getframe $sheets]
	  if {$gui(v:folder) == "" || $gui(v:round) == "" || $gui(v:round) == "__result__"} {
		  label $sub.l -text "$msg(forRound)" -state disabled
		  pack $sub.l -side top -anchor w -padx 5
		  pack $sheets -side top -anchor w -padx 5 -fill both
	  } else {
		  if {!($gui(v:round) != "finale" && [selection:okForResult $gui(v:folder) $gui(v:round)])
					&& !($gui(v:round) == "finale" && [ranking:check $gui(v:folder)])} {
			  set skating::gui(pref:print:what) $gui(pref:print:sheetsMode)
			  NoteBook::raise $nb "markSheets"
		  }
		  # sélectionne quelque chose lors de la sélection du tab
		  NoteBook::itemconfigure $nb "markSheets" \
				-raisecmd "set skating::gui(pref:print:what) $gui(pref:print:sheetsMode)"
		  # les contrôles
		  label $sub.l -text "'$folder(label)', $msg(forRound) '$folder(round:$gui(v:round):name)'  "
		  radiobutton $sub.r1 -bd 1 -text "1/$msg(portrait)" -anchor w \
				-variable skating::gui(pref:print:what) -value sheets:round:portrait1
		  radiobutton $sub.r2 -bd 1 -text "1/$msg(landscape)" -anchor w \
				-variable skating::gui(pref:print:what) -value sheets:round:landscape1
		  radiobutton $sub.r3 -bd 1 -text "2/$msg(portrait)" -anchor w \
				-variable skating::gui(pref:print:what) -value sheets:round:portrait2
		  radiobutton $sub.r4 -bd 1 -text "2/$msg(landscape)" -anchor w \
				-variable skating::gui(pref:print:what) -value sheets:round:landscape2
		  radiobutton $sub.r5 -bd 1 -text "4/$msg(portrait)" -anchor w \
				-variable skating::gui(pref:print:what) -value sheets:round:portrait4
		  radiobutton $sub.r6 -bd 1 -text "4/$msg(landscape)" -anchor w \
				-variable skating::gui(pref:print:what) -value sheets:round:landscape4
		  grid $sub.l	$sub.r1	$sub.r2	-sticky nw -padx 5
		  grid x		$sub.r3	$sub.r4	-sticky nw -padx 5
		  grid x		$sub.r5	$sub.r6	-sticky nw -padx 5
		  variable plugins
		  foreach {label category item cmd} $plugins(print) {
			  if {$category != "markSheets"} {
				  continue
			  }
			  radiobutton $sub.$item -bd 1 -text $label -anchor w \
				-variable skating::gui(pref:print:what) -value $item
			  grid x $sub.$item - -sticky nw -padx 5
		  }
		  grid columnconfigure $sub {2} -weight 1
		  #---- options & génération automatique des 'heats'
		  set options [TitleFrame::create $f.o -text $msg(print:options) -font $selectfont]
		  set sub [TitleFrame::getframe $options]
		  set width 32
		  # si type défini lors de la sauvegarde, on l'utilise comme défaut
		  if {[info exists folder(heats:$gui(v:round):size)]} {
			  set skating::gui(pref:print:heats:size) $folder(heats:$gui(v:round):size)
		  }
		  if {[info exists folder(heats:$gui(v:round):type)]} {
			  set skating::gui(pref:print:heats:type) $folder(heats:$gui(v:round):type)
		  }
		  if {[info exists folder(heats:$gui(v:round):grouping)]} {
			  set skating::gui(pref:print:heats:grouping) $folder(heats:$gui(v:round):couples)
		  }
		  # les contrôles graphiques
			  # oui/non pour les heats
			  set ff1 [frame $sub.heat -bd 0]
			  label $ff1.t -width $width -text $msg(heatsGeneration) -anchor w \
						-foreground $selectforeground -font $selectfont
			  radiobutton $ff1.y -bd 1 -text $msg(yes,) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:heats:mode) -value auto \
						-command "$ff1.nb configure -state normal; $ff1.y2 configure -state normal; $ff1.y3 configure -state normal"
#  				  radiobutton $ff1.y1 -bd 1 -width 25 -font normal -selectcolor $selectcolor -anchor w \
# 	 					-variable skating::gui(pref:print:heats:type) -value "exact"
				  radiobutton $ff1.y2 -bd 1 -width 25 -font normal -selectcolor $selectcolor -anchor w \
						-variable skating::gui(pref:print:heats:type) -value "add"
				  radiobutton $ff1.y3 -bd 1 -width 25 -font normal -selectcolor $selectcolor -anchor w \
						-variable skating::gui(pref:print:heats:type) -value "sub"
				  set nbCouples 1
				  set nbPrequalified 0
				  catch {
					  set nbPrequalified [nbPrequalified $gui(v:folder) $gui(v:round)]
					  set nbCouples [expr [llength $folder(couples:$gui(v:round))]-$nbPrequalified]
				  }
				  print:adjustHeats $ff1 $nbCouples
			  if {$nbPrequalified} {
				  set text "($nbCouples $msg(prt:couples2), $nbPrequalified $msg(prt:prequalified2))"
			  } else {
				  set text "($nbCouples $msg(prt:couples2))"
			  }
			  label $ff1.c -width $width -text $text -anchor w \
						-foreground $selectforeground -font normal
			  radiobutton $ff1.n -bd 1 -text $msg(no) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:heats:mode) -value none \
						-command "$ff1.nb configure -state disabled; $ff1.y2 configure -state disabled; $ff1.y3 configure -state disabled"
			  SpinBox::create $ff1.nb -label "$msg(heatsSize) " -editable false \
					-range {4 48 1} -bd 1 -justify right -width 2 -entrybg gray95 \
					-labelfont normal -textvariable skating::gui(pref:print:heats:size) \
					-modifycmd "skating::print:adjustHeats $ff1 $nbCouples"
			  label $ff1.in -text " $msg(heatsIn) " -font normal
			  grid $ff1.t $ff1.y 	$ff1.nb	$ff1.in $ff1.y3 -sticky w
			  grid $ff1.c x			x	   	x	  	$ff1.y2 -sticky w
			  grid x	  $ff1.n	x	   	x		x		-sticky w
			  if {$skating::gui(pref:print:heats:mode) == "none"} {
				  $ff1.nb configure -state disabled
				  $ff1.y2 configure -state disabled
				  $ff1.y3 configure -state disabled
			  }
			  # mode de groupage des couples
			  set ff2 [frame $sub.heat2 -bd 0]
			  label $ff2.c -width $width -text $msg(heatsCouplesGrouping) -anchor w \
						-foreground $selectforeground -font $selectfont
			  radiobutton $ff2.cn -bd 1 -text $msg(heatsNumber) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:heats:grouping) -value number
			  radiobutton $ff2.ca -bd 1 -text $msg(heatsAlphabetic) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:heats:grouping) -value alphabetic
			  radiobutton $ff2.cr -bd 1 -text $msg(heatsRandom) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:heats:grouping) -value random
#  			  grid $ff2.c $ff2.cn -sticky w
#  			  grid x	  $ff2.ca -sticky w
#  			  grid x	  $ff2.cr -sticky w
			  grid $ff2.c $ff2.cn $ff2.ca $ff2.cr -sticky w
			  grid configure $ff2.c -padx 0
			  # imprimer les feuilles de sélection
			  set ff3 [frame $sub.heat3 -bd 0]
			  label $ff3.c -width $width -text $msg(heatsMarkingSheets) -anchor w \
						-foreground $selectforeground -font $selectfont
			  radiobutton $ff3.y -bd 1 -text $msg(heatsSheets) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:heats:withSheets) -value 1
			  radiobutton $ff3.n -bd 1 -text $msg(heatsNoSheets) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:heats:withSheets) -value 0
			  grid $ff3.c $ff3.y $ff3.n -sticky w
			  grid configure $ff3.c -padx 0
			  # imprimer la liste des juges
			  set ff4 [frame $sub.heat4 -bd 0]
			  label $ff4.c -width $width -text $msg(heatsPrintLists) -anchor w \
						-foreground $selectforeground -font $selectfont
			  radiobutton $ff4.n -bd 1 -text $msg(heatsListNone) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:heats:lists) -value 0
			  radiobutton $ff4.j -bd 1 -text $msg(heatsListJudges) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:heats:lists) -value 1
			  radiobutton $ff4.d -bd 1 -text $msg(heatsListDances) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:heats:lists) -value 2
			  radiobutton $ff4.b -bd 1 -text $msg(heatsListBoth) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:heats:lists) -value 3
			  grid $ff4.c $ff4.n $ff4.j $ff4.d $ff4.b -sticky w
			  grid configure $ff4.c -padx 0
			  if {$subten} {
				  set skating::gui(pref:print:heats:lists) 1
			  } else {
				  set skating::gui(pref:print:heats:lists) 3
			  }
			  # compacte les danses en finale en une seule feuille
			  set ff6 [frame $sub.heat6 -bd 0]
			  label $ff6.c -width $width -text $msg(newSheetOnJudge?) -anchor w \
						-foreground $selectforeground -font $selectfont
			  radiobutton $ff6.y -bd 1 -text $msg(newSheetOnJudgeY) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:sheets:newOnJudge) -value 1
			  radiobutton $ff6.n -bd 1 -text $msg(newSheetOnJudgeN) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:sheets:newOnJudge) -value 0
			  grid $ff6.c $ff6.y $ff6.n -sticky w
			  grid configure $ff6.c -padx 0
			  # compacte les danses en finale en une seule feuille
			  set ff5 [frame $sub.heat5 -bd 0]
			  label $ff5.c -width $width -text $msg(heatsCompact?) -anchor w \
						-foreground $selectforeground -font $selectfont
			  radiobutton $ff5.y -bd 1 -text $msg(heatsCompact) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:sheets:compact) -value 1
			  radiobutton $ff5.n -bd 1 -text $msg(heatsNoCompact) -font normal -selectcolor $selectcolor \
						-variable skating::gui(pref:print:sheets:compact) -value 0
			  grid $ff5.c $ff5.y $ff5.n -sticky w
			  grid configure $ff5.c -padx 0

		  # affichage des options utilisables
		  if {$gui(v:round) != "finale"} {
  			  grid $sub.heat -sticky w -padx 5
  			  grid [frame $sub.sep0] -pady 4
  			  grid $sub.heat2 -sticky w -padx 5
  			  grid [frame $sub.sep1] -pady 10
		  }
		  grid $sub.heat3 -sticky w -padx 5
		  grid $sub.heat4 -sticky w -padx 5
		  grid $sub.heat6 -sticky w -padx 5
#  		  if {$gui(v:round) == "finale" && !$subten} {
			  grid $sub.heat5 -sticky w -padx 5
#  		  }
		  grid columnconfigure $sub {0} -weight 1

		  pack $sheets -side top -anchor nw -padx 5 -fill both
		  pack $options -side top -anchor nw -padx 5 -pady 10 -fill both
	  }
	  # ajuste la taille de la boite de dialogue
	  update idletasks
	  if {[winfo reqwidth $f] > $dialogWidth} { set dialogWidth [winfo reqwidth $f] }
	  if {[winfo reqheight $f] > $dialogHeight} { set dialogHeight [winfo reqheight $f] }


	  #========================
	  # impression de résultats
	  set f [NoteBook::insert $nb end "results" -text " $msg(resultsSheets)" \
							-image imgPrintCup -background gray72]
	  set ok 0
	  if {$gui(v:folder) != "" && [class:dances $gui(v:folder)]} {
		  set ok 1
	  }
	  #-- les résultats
	  set what [TitleFrame::create $f.what -text $msg(print:rounds) -font $selectfont]
	  set sub [TitleFrame::getframe $what]
	  if {$gui(v:folder) == ""} {
		  radiobutton $sub.result -bd 1 -text $msg(resultCompetition) \
					-variable skating::gui(pref:print:what) -value result -state disabled
	  } else {
		  set state normal
		  if {$subten} {
			  set text "$msg(resultFor) '$label' ($gui(v:dance))"
		  } else {
			  set text "$msg(resultFor) '$label'"
		  }
		  if {$ten} {
			  set setLandscape 1
		  }
		  if {!$ok} {
			  set state disabled
		  }
		  radiobutton $sub.result -bd 1 -text $text -state $state \
					-variable skating::gui(pref:print:what) -value result
	  }
	  #-- l'ensemble de la compétition
	  if {$gui(v:folder) == ""} {
		  radiobutton $sub.folder -bd 1 -text $msg(wholeCompetition) \
					-variable skating::gui(pref:print:what) -value folder -state disabled
	  } else {
		  if {$subten} {
			  set text "'$label' ($gui(v:dance))"
		  } else {
			  set text "'$label'"
		  }
		  if {$skating::gui(pref:print:what) == ""} {
			  set skating::gui(pref:print:what) folder
			  NoteBook::raise $nb "results"
			  NoteBook::itemconfigure $nb "results"	-raisecmd "set skating::gui(pref:print:what) folder"
		  }
		  set ff [frame $sub.folder -bd 0]
			  radiobutton $ff.b -bd 1 -text $text \
						-variable skating::gui(pref:print:what) -value folder \
						-command "set skating::gui(pref:print:mode) place"
		  grid $ff.b - -sticky w
		  if {$ten} {
#  			  radiobutton $ff.11 -bd 1 -text $msg(summary:place) -font normal \
#  						-variable skating::gui(pref:print:mode) -value summary:place
#  			  radiobutton $ff.12 -bd 1 -text $msg(summary:couple) -font normal \
#  						-variable skating::gui(pref:print:mode) -value summary:couple
			  radiobutton $ff.21 -bd 1 -text $msg(dance:place) -font normal \
						-variable skating::gui(pref:print:mode) -value place \
						-command "set skating::gui(pref:print:what) folder"
			  radiobutton $ff.22 -bd 1 -text $msg(dance:couple) -font normal \
						-variable skating::gui(pref:print:mode) -value couple \
						-command "set skating::gui(pref:print:what) folder"
			  radiobutton $ff.f -bd 1 -text $msg(full) -font normal \
						-variable skating::gui(pref:print:mode) -value full \
						-command "set skating::gui(pref:print:what) folder"

#  			  grid [frame $ff.sep1 -width 50] $ff.11 $ff.12 -sticky w -padx 5
			  grid [frame $ff.sep2 -width 50] $ff.21 $ff.22 -sticky w -padx 5
			  grid [frame $ff.sep3 -width 50] $ff.f  -		-sticky w -padx 5

			  set setLandscape 1
		  }
	  }
	  #-- le round courant
	  if {$gui(v:round) == "" || $gui(v:round) == "__result__"} {
		  radiobutton $sub.round -bd 1 -text $msg(round) \
					-variable skating::gui(pref:print:what) -value round -state disabled
	  } else {
		  if {$subten} {
			  set text "$folder(round:$gui(v:round):name) $msg(of) '$label' ($gui(v:dance))"
		  } else {
			  set text "$folder(round:$gui(v:round):name) $msg(of) '$label'"
		  }
		  if {$gui(pref:print:what) == "" || $gui(pref:print:what) == "folder"} {
			  set skating::gui(pref:print:what) round
			  NoteBook::raise $nb "results"
			  NoteBook::itemconfigure $nb "results" -raisecmd "set skating::gui(pref:print:what) round"
		  }
		  radiobutton $sub.round -bd 1 -text $text \
					-variable skating::gui(pref:print:what) -value round
	  }
	  pack $sub.result $sub.folder $sub.round -side top -anchor w -padx 5
	  variable plugins
	  foreach {label category item cmd} $plugins(print) {
		  if {$category != "results"} {
			  continue
		  }
		  radiobutton $sub.$item -bd 1 -text $label -anchor w \
			-variable skating::gui(pref:print:what) -value $item
		  pack $sub.$item -side top -anchor w -padx 5
	  }

	  #-- un bilan récapitulatif + rapport IDSF
	  set what2 [TitleFrame::create $f.what2 -text $msg(print:summaries) -font $selectfont]
	  set sub [TitleFrame::getframe $what2]
	  set state disabled
	  if {$gui(v:folder) != "" && ( ($folder(mode) == "normal" && $ok)
									|| $ten )} {
		  if {$gui(v:round) == "__result__"} {
			  set skating::gui(pref:print:what) summary:place
			  NoteBook::raise $nb "results"
			  NoteBook::itemconfigure $nb "results" -raisecmd "set skating::gui(pref:print:what) summary:place"
			  if {([info exists folder(dances)] && [llength $folder(dances)] > 4) || $ten} {
				  set setLandscape 1
			  }
		  }
		  set state normal
	  }
#  	  if {$gui(v:folder) != "" && $folder(mode) == "ten" && $ok} {
#  		  if {$gui(v:round) == "__result__"} {
#  			  set skating::gui(pref:print:what) summary:place
#  		  }
#  		  set state normal
#  	  }
	  if {$subten} {
		  set text1 "$msg(folderSummary:place) ($gui(v:dance))"
		  set text2 "$msg(folderSummary:couple) ($gui(v:dance))"
	  } else {
		  set text1 "$msg(folderSummary:place)"
		  set text2 "$msg(folderSummary:couple)"
	  }
	  radiobutton $sub.sum -bd 1 -anchor w -text $text1 -state $state \
				-variable skating::gui(pref:print:what) -value summary:place
	  radiobutton $sub.sum2 -bd 1 -anchor w -text $text2 -state $state \
				-variable skating::gui(pref:print:what) -value summary:couple
	  radiobutton $sub.sum3 -bd 1 -anchor w -text $msg(idsf:report) -state $state \
				-variable skating::gui(pref:print:what) -value summary:idsf:report \
				-command "set skating::gui(pref:print:orientation) -portrait"
	  radiobutton $sub.sum4 -bd 1 -anchor w -text $msg(idsf:table) -state $state \
				-variable skating::gui(pref:print:what) -value summary:idsf:table

	  pack $sub.sum $sub.sum2 -side top -anchor w -padx 5
	  if {!$ten} {
		  pack $sub.sum3 $sub.sum4 -side top -anchor w -padx 5
	  }

	  #---- résultats pour l'ensemble des compétitions
	  set what3 [TitleFrame::create $f.what3 -text $msg(print:all) -font $selectfont]
	  set sub [TitleFrame::getframe $what3]

	  radiobutton $sub.all -bd 1 -text $msg(all:rounds) \
				-variable skating::gui(pref:print:what) -value all
	  radiobutton $sub.sumall -bd 1 -text $msg(summary:place) \
				-variable skating::gui(pref:print:what) -value all:summary:place
	  radiobutton $sub.sumall2 -bd 1 -text $msg(summary:couple) \
				-variable skating::gui(pref:print:what) -value all:summary:couple
	  radiobutton $sub.sumall3 -bd 1 -anchor w -text $msg(idsf:report) \
				-variable skating::gui(pref:print:what) -value all:summary:idsf:report \
				-command "set skating::gui(pref:print:orientation) -portrait"
	  radiobutton $sub.sumall4 -bd 1 -anchor w -text $msg(idsf:table) \
				-variable skating::gui(pref:print:what) -value all:summary:idsf:table
	  pack $sub.all $sub.sumall $sub.sumall2 $sub.sumall3 $sub.sumall4 -side top -anchor w -padx 5


	  #--------
	  # options
	  set options [TitleFrame::create $f.options -text $msg(print:options) -font $selectfont]
	  set sub [TitleFrame::getframe $options]
	  #---- orientation du papier
	  if {([info exists folder(dances)] && [llength $folder(dances)] > 4)
				|| $setLandscape} {
		  set gui(pref:print:orientation) "-landscape"
	  } else {
		  set gui(pref:print:orientation) "-portrait"
	  }
	  set ff [frame $sub.orient -bd 0]
	  label $ff.t -text $msg(orientation) -foreground $selectforeground -font $selectfont
	  radiobutton $ff.p -bd 1 -text $msg(portrait) -font normal -selectcolor $selectcolor \
				-variable skating::gui(pref:print:orientation) -value -portrait
	  radiobutton $ff.l -bd 1 -text $msg(landscape) -font normal -selectcolor $selectcolor \
				-variable skating::gui(pref:print:orientation) -value -landscape
	  grid $ff.t - -	-sticky w
	  grid [frame $ff.sep1 -width 50] $ff.p $ff.l -sticky w -padx 5
	  #---- impression des juges dans les résumés
	  if {([info exists folder(couples:all)] && [llength $folder(couples:all)] > 40
			&& $gui(pref:print:orientation) == "-landscape")
				|| ([info exists folder(judges:finale)] && [llength $folder(judges:finale)] > 6)} {
		  set gui(pref:print:judgesInSummary) 0
	  } else {
		  set gui(pref:print:judgesInSummary) 1
	  }
	  set ff [frame $sub.jsum -bd 0]
	  label $ff.t -text $msg(judgesInSummary) -foreground $selectforeground -font $selectfont
	  radiobutton $ff.p -bd 1 -text $msg(judgesInSummary:0) -font normal -selectcolor $selectcolor \
				-variable skating::gui(pref:print:judgesInSummary) -value 0
	  radiobutton $ff.l -bd 1 -text $msg(judgesInSummary:1) -font normal -selectcolor $selectcolor \
				-variable skating::gui(pref:print:judgesInSummary) -value 1
	  grid $ff.t - -	-sticky w
	  grid [frame $ff.sep1 -width 50] $ff.p $ff.l -sticky w -padx 5
	  #---- mise en page options
	  pack $sub.orient $sub.jsum -side top -anchor w -padx 5

	  #---------------------------
	  # mise en page des contrôles
	  pack [frame $f.sep4] -side bottom -anchor w -padx 5 -expand true -fill both
	  pack $options [frame $f.sep3 -height 10] -side bottom -anchor w -padx 5 -fill both
	  pack $what3 [frame $f.sep2 -height 10] -side bottom -anchor w -padx 5 -fill both
	  pack $what -side left -anchor nw -padx 5 -fill both
	  pack $what2 -side left -anchor nw -padx 5 -expand true -fill both
	  # ajuste la taille de la boite de dialogue
	  update idletasks
	  if {[winfo reqwidth $f] > $dialogWidth} { set dialogWidth [winfo reqwidth $f] }
	  if {[winfo reqheight $f] > $dialogHeight} { set dialogHeight [winfo reqheight $f] }

	  #=========================
	  # génération d'un site Web
	  set f [NoteBook::insert $nb end "web" -text " $msg(webOutput)" \
							-image imgPrintWeb -background gray72 \
							-raisecmd "set skating::gui(pref:print:what) web"]
	  print:html:dialog $f
	  # ajuste la taille de la boite de dialogue
	  update idletasks
	  if {[winfo reqwidth $f] > $dialogWidth} { set dialogWidth [winfo reqwidth $f] }
	  if {[winfo reqheight $f] > $dialogHeight} { set dialogHeight [winfo reqheight $f] }


	  #=============
	  # mise en page
	  pack $nb -side top -padx 5 -pady 5 -fill both -anchor n

	pack $top -side top -expand true -fill both -padx 5 -pady 5

	# frame des boutons
	set but [frame .dialog.but -bd 1 -relief raised]
	  button $but.ok -text $msg(dlg:ok) -underline 0 -bd 1 -width 7 \
			-command "skating::print:doit" -default active
	  button $but.can -text $msg(dlg:cancel) -underline 0 -bd 1 -width 7 \
			-command "destroy .dialog"
	  button $but.def -text $msg(dlg:options) -bd 1 \
			-command "skating::gui:options print"
	  button $but.layout -text $msg(dlg:layout) -bd 1 \
			-command "skating::gui:options print2"
	  grid $but.ok $but.can [frame $but.sep -width 10] $but.def $but.layout -sticky ew -padx 10 -pady 5
	pack $but -fill x -anchor c -side bottom

	# proposer quelque chose  par défault / utiliser demande utilisateur
	if {[llength $userChoice]} {
		NoteBook::raise $nb [lindex $userChoice 0]
		set skating::gui(pref:print:what) [lindex $userChoice 1]
	} elseif {$skating::gui(pref:print:what) == ""} {
		NoteBook::raise $nb "global"
		set skating::gui(pref:print:what) event:competitions
	}

	# key bindings
	bind .dialog <Alt-o> "skating::print:doit"
	bind .dialog <Return> "skating::print:doit"
	bind .dialog <Alt-a> "after idle {destroy .dialog}"
	bind .dialog <Alt-c> "after idle {destroy .dialog}"
	bind .dialog <Escape> "after idle {destroy .dialog}"

	# ajuste position de la boite de dialogue
	NoteBook::configure $nb -width $dialogWidth -height $dialogHeight
	centerDialog .top .dialog
}

proc skating::print:adjustHeats {buttons nb} {
variable gui

	foreach mode {add sub} path {y2 y3} {
		foreach {nb1 size1 nb2 size2} [computeHeats:size $nb $gui(pref:print:heats:size) $mode] break
		set total [expr {$nb1+$nb2}]
		if {$nb2 == 0 || $size2 == 0} {
			$buttons.$path configure -text "$total heats ($nb1 de $size1)"
		} elseif {$nb1 == 0 || $size1 == 0} {
			$buttons.$path configure -text "$total heats ($nb2 de $size2)"
		} else {
			$buttons.$path configure -text "$total heats ($nb1 de $size1, $nb2 de $size2)"
		}
	}
}


#-------------------------------------------------------------------------------------------------

proc skating::print:doit {} {
global msg
variable event
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder

#TRACE "what=$gui(pref:print:what)"
	# some sync
	syncAttributes

	# check si option Web
	if {$gui(pref:print:what) == "web"} {
		print:html:doit
		return
	} elseif {$gui(pref:print:what) == "event:enrollment:competitions"
			  && ![print:enrollment:competitions:dialog]} {
		return
	}
	#-----------------------------

	destroy .dialog
	# force une mise-à-jour
	update

	# dialogue de progrès
	progressBarInit $msg(printing) $msg(printing:msg) $msg(printing:page) [llength $event(folders)]

	# fenêtre pour aperçu avant impression
	destroy .preview
	toplevel .preview
	wm title .preview $msg(preview)
	wm withdraw .preview
	set sw [ScrolledWindow::create .preview.pages \
					-scrollbar both -auto both -relief sunken -borderwidth 1]
	  set gui(w:preview) $sw
	  set gui(w:preview:root) [ScrolledWindow::getframe $sw]

	# quelques dimensions pour les impressions en PostScript + initialisations
	if {$gui(pref:print:format) == "ps"} {
		print:ps:setup
	}

	# sauve contexte
	set olddark		$gui(color:print:dark)
	set oldlight 	$gui(color:print:light)
	set oldfolder 	$gui(v:folder)
	set oldcomment 	$gui(pref:print:comment)
	set oldjudges 	$gui(pref:print:names:judges)
	set oldcouples 	$gui(pref:print:names:couples)
	set oldmode 	$gui(pref:print:mode)
	set oldvten		$gui(v:ten)
	set oldvsubten	$gui(v:subten)
	if {!$gui(pref:print:color)} {
		set gui(color:print:dark) {}
		set gui(color:print:light) {}
	}

	if {$gui(pref:print:what) == "all"} {
		#---- toutes les compétitions

		# sauvegarde du contexte & positionnement des flags
		if {$gui(pref:print:listCouples) || $gui(pref:print:listJudges)} {
			set gui(v:folder) ""
			set gui(pref:print:comment) 1
			set gui(pref:print:names:judges) $gui(pref:print:listJudges) 
			set gui(pref:print:names:couples) $gui(pref:print:listCouples)
			set gui(v:ten) 0
			set gui(v:subten) 0
			set print [print:event 0]
		}
		set gui(pref:print:comment) $oldcomment
		set gui(pref:print:names:judges) $oldjudges
		set gui(pref:print:names:couples) $oldcouples
		set gui(pref:print:mode) full
		foreach f $event(folders) {
			variable $f
			upvar 0 $f currentFolder
			set gui(v:ten) 0
			if {$currentFolder(mode) == "ten"} {
				set gui(v:ten) 1
			}
			set gui(v:subten) 0
			set gui(v:folder) $f
			append print [print:folder]
			progressBarUpdate 1
		}
		if {[catch {set label $event(general:title)}]} {
			set label $msg(noName)
		}
		set gui(pref:print:mode) $oldmode
		set gui(v:ten) $oldvten
		set gui(v:subten) $oldvsubten

	} elseif {[string match "all:summary:*" $gui(pref:print:what)]} {
		#---- un bilan (place, couple ou IDSF) pour l'ensemble des compétitions
		scan $gui(pref:print:what) "all:summary:%s" type
		# sauvegarde du contexte & positionnement des flags
		if {($gui(pref:print:listCouples) || $gui(pref:print:listJudges))
			&& ![string match "all:summary:idsf:*" $gui(pref:print:what)]} {
			set gui(v:folder) ""
			set gui(pref:print:comment) 1
			set gui(pref:print:names:judges) $gui(pref:print:listJudges) 
			set gui(pref:print:names:couples) $gui(pref:print:listCouples)
			set gui(v:ten) 0
			set gui(v:subten) 0
			set print [print:event 0]
		}
		set gui(pref:print:comment) $oldcomment
		set gui(pref:print:names:judges) $oldjudges
		set gui(pref:print:names:couples) $oldcouples
		set gui(pref:print:mode) place
		foreach f $event(folders) {
			variable $f
			upvar 0 $f currentFolder
			set gui(v:ten) 0
			set gui(v:subten) 0
			set gui(v:folder) $f
			if {([info exists currentFolder(couples:all)] && [llength $currentFolder(couples:all)] > 40
						&& $gui(pref:print:orientation) == "-landscape")
						|| ([info exists currentFolder(judges:finale)] && [llength $currentFolder(judges:finale)] > 6)} {
				set gui(pref:print:judgesInSummary) 0
			} else {
				set gui(pref:print:judgesInSummary) 1
			}
			if {$currentFolder(mode) == "ten"} {
				set gui(v:ten) 1
				set gui(pref:print:mode) "summary:$type"
				append print [print:folder]
			} else {
				if {([info exists currentFolder(dances)] && [llength $currentFolder(dances)] > 4)
					&& ![string equal "all:summary:idsf:report" $gui(pref:print:what)]} {
					set gui(pref:print:orientation) "-landscape"
				} else {
					set gui(pref:print:orientation) "-portrait"
				}
				append print [print:summary $type]
			}
			progressBarUpdate 1
		}
		if {[catch {set label $event(general:title)}]} {
			set label $msg(noName)
		}
		set gui(pref:print:mode) $oldmode
		set gui(v:ten) $oldvten
		set gui(v:subten) $oldvsubten


	} elseif {$gui(pref:print:what) == "folder"} {
		#---- un dossier
		set print [print:folder]
		set label "$folder(label)"

	} elseif {$gui(pref:print:what) == "round"} {
		#---- un round
		set print [print:round $gui(v:round)]
		set label "$folder(label)"

	} elseif {[string match "summary:*" $gui(pref:print:what)]} {
		#---- un bilan (place ou couple)
		if {$gui(v:ten)} {
			set gui(pref:print:mode) $gui(pref:print:what)
			set print [print:folder]
		} else {
			scan $gui(pref:print:what) "summary:%s" type
			set print [print:summary $type]
		}
		set label "$folder(label)"

	} elseif {$gui(pref:print:what) == "result"} {
		#---- résultat sur une compétition
		set print [print:event 1]
		set label "$folder(label)"

	} elseif {$gui(pref:print:what) == "event:enrollment:competitions"} {
		#---- tableau de synthèse couples & juges par compétition
		set print [print:enrollment:competitions]
		if {[catch {set label $event(general:title)}]} {
			set label $msg(noName)
		}

	} elseif {$gui(pref:print:what) == "event:enrollment:couples"} {
		#---- tableau de vérification des participations
		set print [print:enrollment:couples]
		if {[catch {set label $event(general:title)}]} {
			set label $msg(noName)
		}

	} elseif {$gui(pref:print:what) == "event:enrollment:judges"} {
		#---- une table juges/compétitions
		set gui(v:folder) ""
		set gui(pref:print:names:judges) 1
		set gui(pref:print:names:couples) 0
		set print [print:event 0 $msg(prt:enrollment:judges)]
		set print [print:enrollment:judges]
		if {[catch {set label $event(general:title)}]} {
			set label $msg(noName)
		}

	} elseif {$gui(pref:print:what) == "event:panels"} {
		#---- les panels de juges
		set print [print:panels]
		if {[catch {set label $event(general:title)}]} {
			set label $msg(noName)
		}

	} elseif {$gui(pref:print:what) == "event:competitions"} {
		#---- les panels de juges
		set print [print:competitions]
		if {[catch {set label $event(general:title)}]} {
			set label $msg(noName)
		}

	} elseif {[scan $gui(pref:print:what) "event:%s" type] == 1} {
		#---- une liste des couples et/ou juges
		set gui(v:folder) ""
		set gui(pref:print:comment) 1
		set gui(pref:print:names:judges) 1
		if {$type == "couples_judges"} {
			set gui(pref:print:names:couples) 1
		} else {
			set gui(pref:print:names:couples) 0
		}
		set print [print:event 0]
		if {[catch {set label $event(general:title)}]} {
			set label $msg(noName)
		}

	} elseif {[scan $gui(pref:print:what) "sheets:round:%s" type] == 1} {
		#---- des feuilles de marquage pré-imprimées
		set print [print:marksSheets $type]
		set label "$folder(label)"

	} else {
		#---- check dans les plugins
		variable plugins
		set command ""
		foreach {label category item cmd} $plugins(print) {
			if {$gui(pref:print:what) == $item} {
				set command $cmd
				break
			}
		}
		if {$command == ""} {
			return
		}
		# execute le plugin
		set print [$command]
	}
	set gui(t:label) $label
	# restauration du contexte
	set gui(color:print:dark) $olddark
	set gui(color:print:light) $oldlight
	set gui(pref:print:comment) $oldcomment
	set gui(pref:print:names:judges) $oldjudges
	set gui(pref:print:names:couples) $oldcouples
	set gui(v:folder) $oldfolder

	print:preview:$gui(pref:print:format) $print
	# fin boite de progression
	progressBarEnd
	# ajuste position de la boite de dialogue
	update
	centerDialog .top .preview $gui(t:w) $gui(t:h)
	wm deiconify .preview
}

proc skating::print:getFile {format} {
global msg
variable gui


	set types [list $format	[list $msg(fileAll) *]]
	regsub -all {\\|/|\*|\?} $gui(t:label) { } label
	set filename [tk_getSaveFile -filetypes $types -parent $gui(w:tree) \
						-initialfile $label -defaultextension [lindex $format 1]]
	if {$filename == ""} {
		return ""
	}
	if {[catch {set file [open $filename "w"]} errStr]} {
		tk_messageBox -icon "error" -type ok -default ok \
				-title $msg(dlg:error) -message "$msg(dlg:cantSave) '$filename'.\n\n($errStr)"
		return ""
	}
	return $file
}

#=================================================================================================

proc skating::print:toPrinter {} {
global tcl_platform
global msg
variable gui


# set tcl_platform(platform) "windows"
# variable deltaY
# set deltaY 1

	# envoi vers l'imprimante
#  	if {$gui(pref:print:format) == "text"} {
#  		# version démo : non disponible
#  		if {[license check] == 0} {
#  			tk_messageBox -icon info -type ok -default ok -title "License" \
#  					-message $msg(dlg:demoNotAvailable)
#  			return
#  		}
#  		#---- texte ----
#  		if {$tcl_platform(platform) == "windows"} {
#  			# sélection d'une imprimante
#  			set hdc [printer dialog select]
#  			if {[lindex $hdc 1] == 0} {
#  				# User has canceled printing
#  				return
#  			}
#  			set hdc [lindex $hdc 0]
#  			# impression
#  			printer send -hDC $hdc -nopostscript -data [$gui(w:t:text) get 1.0 end]
#  		} else {
#  			catch {
#  				set printer [open "|lpr -#$gui(v:print:copies)" w]
#  				puts $printer [$gui(w:t:text) get 1.0 end]
#  				close $printer
#  			}
#  		}

#  	} else {
		#---- Postscript ----
		if {$tcl_platform(platform) == "windows"} {
			print:windows:print
		} else {
			variable paperSize
			set paper [string tolower $gui(pref:print:paper)]
			set cw [lindex $paperSize($paper) 0]
			set ch [lindex $paperSize($paper) 1]
			set pw [lindex $paperSize($paper) 2]
			set ph [lindex $paperSize($paper) 3]
			set x [lindex $paperSize($paper) 4]
			set y [lindex $paperSize($paper) 5]
			catch {
				set printer [open "|lpr -#$gui(v:print:copies)" w]
				# version démo : 1 page seulement
				if {[license check] == 0} {
					tk_messageBox -icon info -type ok -default ok -title License \
							-message $msg(dlg:demoPrint)
					set pages [lindex $gui(v:print:pages) [expr {$gui(v:print:from)-1}]]
					set orients [lindex $gui(v:print:pages:orientation) [expr {$gui(v:print:from)-1}]]
					puts $printer  "gsave
									/Helvetica-Bold findfont 110 scalefont setfont
									.85 .85 .85 setrgbcolor
									90 210 moveto 65 rotate (Unregistred) show -65 rotate
									300 30 moveto 65 rotate (Unregistred) show
									grestore"
				} else {
					set pages [lrange $gui(v:print:pages) [expr {$gui(v:print:from)-1}] \
														  [expr {$gui(v:print:to)-1}]]
					set orients [lrange $gui(v:print:pages:orientation) [expr {$gui(v:print:from)-1}] \
																		[expr {$gui(v:print:to)-1}]]
				}
				# dialogue d'avancement
				progressBarInit $msg(printing) $msg(printing:msg) $msg(printing:page) [llength $pages]
				# imprime dans le fichier
				foreach page $pages orient $orients {
					# imprime la page
					if {$orient == "-portrait"} {
						puts $printer [$page postscript -x 0 -y 0 -width $cw -height $ch \
											-pagewidth $pw -pageheight $ph -pagex $x -pagey $y]
					} else {
						puts $printer [$page postscript -x 0 -y 0 -width $ch -height $cw \
											-pagewidth $ph -pageheight $pw -pagex $x -pagey $y \
											-rotate true]
					}
					# progress bar
					progressBarUpdate 1
					progressBarIncrText
				}
				close $printer
			}
			progressBarEnd
		}
		
#  	}	

	# si feuille de pre-marques
	if {[scan $gui(pref:print:what) "sheets:round:%s" type] == 1 && $gui(v:round) != "finale"} {
		variable $gui(v:folder)
		upvar 0 $gui(v:folder) folder
		# enregistre dans fichier
		set gui(v:modified) 1
		set folder(heats:$gui(v:round):size) $gui(pref:print:heats:size)
		set folder(heats:$gui(v:round):type) $gui(pref:print:heats:type)
		# mise à jour affichage
		if {$gui(v:print:updateDisplay)} {
			foreach dance $folder(dances) {
				set skating::gui(t:useHeats:$dance) 1
				round:draw $gui(w:canvas:$gui(v:round):$dance) $gui(v:folder) $dance $gui(v:round)
			}
		}
	}

	# fin
	destroy .preview
}

#-------------------------------------------------------------------------------------------------

proc skating::print:toFile {} {
global msg
variable gui


	# sauve dans un fichier
#  	if {$gui(pref:print:format) == "text"} {
#  		# version démo : non disponible
#  		if {[license check] == 0} {
#  			tk_messageBox -icon info -type ok -default ok -title License \
#  					-message $msg(dlg:demoNotAvailable)
#  			return
#  		}
#  		# format texte
#  		set file [print:getFile [list $msg(fileText) {.txt}]]
#  		if {$file != ""} {
#  			puts $file $print
#  			close $file
#  		}
#  	} elseif {$gui(pref:print:format) == "ps"} {

	# format Postscript
	# retourne handle vers fichier ouvert ou "" si annulation
	set file [print:getFile [list $msg(filePostscript) {.ps}]]
	if {[catch {
		if {$file != ""} {
			variable paperSize
			set paper [string tolower $gui(pref:print:paper)]
			set cw [lindex $paperSize($paper) 0]
			set ch [lindex $paperSize($paper) 1]
			set pw [lindex $paperSize($paper) 2]
			set ph [lindex $paperSize($paper) 3]
			set x [lindex $paperSize($paper) 4]
			set y [lindex $paperSize($paper) 5]
			# version démo : 1 page seulement
			if {0 && [license check] == 0} {
				tk_messageBox -icon info -type ok -default ok -title License \
						-message $msg(dlg:demoPrint)
				set pages [lindex $gui(v:print:pages) [expr {$gui(v:print:from)-1}]]
				set orients [lindex $gui(v:print:pages:orientation) [expr {$gui(v:print:from)-1}]]
				puts $file "gsave
							/Helvetica-Bold findfont 110 scalefont setfont
							.85 .85 .85 setrgbcolor
							90 210 moveto 65 rotate (Unregistred) show -65 rotate
							300 30 moveto 65 rotate (Unregistred) show
							grestore"
			} else {
				set pages [lrange $gui(v:print:pages) [expr {$gui(v:print:from)-1}] \
													  [expr {$gui(v:print:to)-1}]]
				set orients [lrange $gui(v:print:pages:orientation) [expr {$gui(v:print:from)-1}] \
																	[expr {$gui(v:print:to)-1}]]
			}
			# dialogue d'avancement
			progressBarInit $msg(printing) $msg(printing:msg) $msg(printing:page) [llength $pages]
			# imprime dans le fichier
			foreach page $pages orient $orients {
				# imprime la page
				if {$orient == "-portrait"} {
					puts $file [$page postscript -x 0 -y 0 -width $cw -height $ch \
										-pagewidth $pw -pageheight $ph -pagex $x -pagey $y]
				} else {
					puts $file [$page postscript -x 0 -y 0 -width $ch -height $cw \
										-pagewidth $ph -pageheight $pw -pagex $x -pagey $y \
										-rotate true]
				}
				# progress bar
				progressBarUpdate 1
				progressBarIncrText
			}
			progressBarEnd
			close $file
		}

		}]} {
			# erreur pendant la sauvegarde
			tk_messageBox -icon "error" -type ok -default ok \
					-title $msg(dlg:error) -message "$msg(dlg:errorWrite)"
puts $::errorInfo
		}


#  	}

	destroy .preview

	# si feuille de pre-marques
	if {[scan $gui(pref:print:what) "sheets:round:%s" type] == 1 && $gui(v:round) != "finale"} {
		variable $gui(v:folder)
		upvar 0 $gui(v:folder) folder
		# enregistre dans fichier
		set gui(v:modified) 1
		set folder(heats:$gui(v:round):size) $gui(pref:print:heats:size)
		set folder(heats:$gui(v:round):type) $gui(pref:print:heats:type)
		# mise à jour affichage
		if {$gui(v:print:updateDisplay)} {
			foreach dance $folder(dances) {
				set skating::gui(t:useHeats:$dance) 1
				round:draw $gui(w:canvas:$gui(v:round):$dance) $gui(v:folder) $dance $gui(v:round)
			}
		}
	}
}

#=================================================================================================

#  proc skating::print:preview:text {print} {
#  global msg
#  variable gui

#  	# frame du dialogue
#  	set f .preview.pages
#  	  set sw $gui(w:preview)
#  	  set text [text [ScrolledWindow::getframe $sw].text -font fixed \
#  						-bg gray95 -relief flat -borderwidth 0 \
#  						-width 87 -height 1 -highlightthickness 0 \
#  						-cursor {} -insertofftime 1000000 -insertontime 0]
#  	  bindtags $text "$text .preview all"
#  	  bind $text <Up> "$text yview scroll -1 units"
#  	  bind $text <Down> "$text yview scroll +1 units"
#  	  bind $text <Prior> "$text yview scroll -1 pages"
#  	  bind $text <Next> "$text yview scroll +1 pages"
#  	  focus $text
#  	  $text insert end $print
#  	  ScrolledWindow::setwidget $sw $text
#  	  pack $sw -side top -expand true -fill both
#  	pack $f -side top -expand true -fill both
#  	set gui(w:t:text) $text
#  	# frame des boutons
#  	set but [frame .preview.but -bd 1 -relief raised]
#  	  set print [button $but.print -text $msg(dlg:print) -underline 0 -bd 1 -width 7 \
#  					-command "skating::print:toPrinter" -default active]
#  	  set save [button $but.save -text $msg(dlg:save) -underline 0 -bd 1 -width 7 \
#  					-command "skating::print:toFile"]
#  	  set cancel [button $but.cancel -text $msg(dlg:cancel) -underline 0 -bd 1 -width 7 \
#  					-command "destroy .preview"]
#  	  grid $print $save $cancel -sticky ew -padx 10 -pady 5
#  	pack $but -fill x -anchor c -side bottom
#  	# key bindings
#  	bind .preview <Alt-o> "after idle {destroy .preview}"
#  	bind .preview <Return> "after idle {destroy .preview}"
#  	# essaye de dimensionner la fenêtre
#  	set width [winfo reqwidth $text]
#  	set height [expr [winfo screenheight .]-40]
#  	wm geometry .preview ${width}x$height
#  	set gui(t:w) $width
#  	set gui(t:h) $height
#  }

#-------------------------------------------------------------------------------------------------

proc skating::print:preview:ps {dummy} {
global msg
variable gui

	# frame du dialogue
	set nbpages [llength $gui(v:print:pages)]
	if {$nbpages} {
		set gui(v:print:index) 0
		set page [lindex $gui(v:print:pages) 0]
		ScrolledWindow::setwidget $gui(w:preview) $page
		focus $page
	}
	pack $gui(w:preview) -expand true -fill both

	# frame pour le choix des pages à imprimer
	set range [frame .preview.range -bd 1 -relief flat]
		# range + tout/page courante
		SpinBox::create $range.from -label "$msg(dlg:print:from) " \
				-range [list 1 $nbpages 1] -width 3 -entrybg gray95 \
				-textvariable skating::gui(v:print:from) -labelfont normal \
				-selectbackground $gui(color:selection) -justify right
		SpinBox::create $range.to -label " $msg(dlg:print:to) " \
				-range [list 1 $nbpages 1] -width 3 -entrybg gray95 \
				-textvariable skating::gui(v:print:to) -labelfont normal \
				-selectbackground $gui(color:selection) -justify right
		set skating::gui(v:print:from) 1
		set skating::gui(v:print:to) $nbpages
		button $range.all -width 10 -bd 1 -text $msg(dlg:print:all) -font normal \
				-command "set skating::gui(v:print:from) 1 ; set skating::gui(v:print:to) $nbpages"
		button $range.current -width 10 -bd 1 -text $msg(dlg:print:page) -font normal \
				-command "set skating::gui(v:print:from) \[expr {\$skating::gui(v:print:index)+1}\]; \
						  set skating::gui(v:print:to) \$skating::gui(v:print:from)"
		# bouton pour nombre de copies
		SpinBox::create $range.copies -label "$msg(copies) " -editable true \
			-range {1 500 1} -bd 1 -justify right -width 3 -entrybg gray95 \
			-labelfont normal -textvariable skating::gui(v:print:copies)

	pack $range.copies -side left
	pack [frame $range.sep0] -fill x -side left -expand true
	pack $range.from $range.to [frame $range.sep1 -width 20] $range.all $range.current -side left

	# frame des boutons
	set but [frame .preview.but -bd 1 -relief raised]
	  set print [button $but.print -text $msg(dlg:print) -underline 0 -bd 1 -width 7 \
					-command "skating::print:toPrinter" -default active]
	  set save [button $but.save -text $msg(dlg:save) -underline 0 -bd 1 -width 7 \
					-command "skating::print:toFile"]
	  set cancel [button $but.cancel -text $msg(dlg:cancel) -underline 0 -bd 1 -width 7 \
					-command "destroy .preview"]
	  #----
	  set prev [button $but.prev -text "<<" -underline 0 -bd 1 -width 3 \
					-command "skating::print:preview:ps:changePage -1" -state disabled]
	  set nb [llength $gui(v:print:pages)]
	  if {$nb > 1} {
		  set state normal
	  } else {
		  set state disabled
	  } 
	  set ::__pages "1/$nb"
	  set next [button $but.next -text ">>" -underline 0 -bd 1 -width 3 \
					-command "skating::print:preview:ps:changePage +1" -state $state]
	  set gui(w:pages) $but
	  set nb [label $but.nb -textvariable ::__pages]
	  pack [frame $but.sep0] -expand true -fill x -side left
	  pack $print $save $cancel [frame $but.sep -width 25] -side left -padx 10 -pady 5
	  pack $prev $nb $next -side left -padx 2 -pady 5
	  pack [frame $but.sep1] -expand true -fill x -side left
	pack $but -fill x -anchor c -side bottom
	pack $range -fill x -anchor w -side bottom -pady 5 -padx 10
	# key bindings
	bind .preview <Return> "skating::print:toPrinter"
	bind .preview <Alt-i> "skating::print:toPrinter"
	bind .preview <Alt-p> "skating::print:toPrinter"
	bind .preview <i> "skating::print:toPrinter"
	bind .preview <p> "skating::print:toPrinter"
	bind .preview <Alt-s> "skating::print:toFile"
	bind .preview <s> "skating::print:toFile"
	bind .preview <Control-s> "break"
	bind .preview <Alt-a> "after idle {destroy .preview}"
	bind .preview <Alt-c> "after idle {destroy .preview}"
	bind .preview <a> "after idle {destroy .preview}"
	bind .preview <c> "after idle {destroy .preview}"
	bind .preview <Escape> "after idle {destroy .preview}"
	bind .preview <less> "skating::print:preview:ps:changePage -1"
	bind .preview <greater> "skating::print:preview:ps:changePage +1"
	  # changement de page automatique
	  global __prior __next
	  set __prior 0
	  set __next 0
	  bind .preview <Up> "if {\$__prior == 2} { skating::print:preview:ps:changePage -1; }"
	  bind .preview <Down> "if {\$__next == 2} { skating::print:preview:ps:changePage +1; }"
	  bind .preview <Prior> "if {\$__prior == 2} { skating::print:preview:ps:changePage -1; }"
	  bind .preview <Next> "if {\$__next == 2} { skating::print:preview:ps:changePage +1; }"

	# essaye de dimensionner la fenêtre
	set width [expr $gui(t:w)+24]
	if {$width > [winfo screenwidth .]} {
		set width [expr [winfo screenwidth .]-40]
	}
	set height [expr [winfo screenheight .]-40]
	wm geometry .preview ${width}x$height
	set gui(t:w) $width
	set gui(t:h) $height

	# optimise le déplacement avec Prior/next
	update
	if {[lindex [$page cget -scrollregion] 3] <= [winfo height $gui(w:preview)]} {
		set __next 1	;# toute la page affichée, donc changement lors prochain Next
		set __prior 1	;# toute la page affichée, donc changement lors prochain Prior
	}
}

proc skating::print:preview:ps:changePage {dir} {
global msg
variable gui

	# vérifie numéro page (car appel direct par binding)
	set newpage [expr $gui(v:print:index) + $dir]
	if {$newpage < 0 || $newpage >= [llength $gui(v:print:pages)]} {
		return
	}
	set gui(v:print:index) $newpage
	# état des boutons
	if {$gui(v:print:index) == 0} {
		$gui(w:pages).prev configure -state disabled
	} else {
		$gui(w:pages).prev configure -state normal
	}
	set nbpages [llength $gui(v:print:pages)]
	if {$gui(v:print:index) == $nbpages-1} {
		$gui(w:pages).next configure -state disabled
	} else {
		$gui(w:pages).next configure -state normal
	}
	# mise à jour du label
    set ::__pages "[expr {$gui(v:print:index)+1}]/$nbpages"
	# affiche la page
	set page [lindex $gui(v:print:pages) $gui(v:print:index)]
	ScrolledWindow::setwidget $gui(w:preview) $page
	focus $page
	# ajuste scrolling de la page
	global __prior __next
	if {$dir > 0 || ($dir < 0 && $__prior != 2)} {
		$page yview moveto 0
	} else {
		$page yview moveto 1
	}

	if {[lindex [$page cget -scrollregion] 3] <= [winfo height $gui(w:preview)]} {
		set __next 1	;# toute la page affichée, donc changement lors prochain Next
		set __prior 1	;# toute la page affichée, donc changement lors prochain Prior
	} else {
		set __next 0	;# doit scroller pour afficher fin de la page
		set __prior 0	;# doit scroller pour afficher début de la page
	}
}


#=================================================================================================
#
#	Impression -- dispatch vers des routines en fonctions du format
#
#=================================================================================================

proc skating::print:folder {} {
global msg
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder


#puts "skating::print:folder / $gui(v:folder) -- $folder(mode)"
	set print ""
	catch { set print [print:event 1] }
#puts $::errorInfo

	if {$folder(mode) == "ten"} {
		#---- mode ten = danses

		# dialogue de progrès
		progressBarAdd [llength $folder(v:overall:dances)]
		if {$gui(pref:print:mode) == "full"} {
			set old_folder $gui(v:folder)
			set gui(v:ten) 0
			set gui(v:subten) 1
			foreach dance $folder(v:overall:dances) {
				set gui(v:folder) $old_folder.$dance
				print:folder
				progressBarUpdate 1
			}
			set gui(v:folder) $old_folder
		} elseif {[scan $gui(pref:print:mode) "summary:%s" type] == 1} {
			if {[string match "idsf:*" $type]} {
				set old_folder $gui(v:folder)
				set old_dance $gui(v:dance)
				set gui(v:ten) 0
				set gui(v:subten) 1
				foreach dance $folder(v:overall:dances) {
					set gui(v:folder) $old_folder.$dance
					set gui(v:dance) $dance
					print:summary $type
					progressBarUpdate 1
				}
				set gui(v:folder) $old_folder
				set gui(v:dance) $old_dance
			} else {
				print:$gui(pref:print:format):summary:ten $gui(v:folder) $type
			}
		} else {
			set old_folder $gui(v:folder)
			set old_dance $gui(v:dance)
			set gui(v:ten) 0
			set gui(v:subten) 1
			foreach dance $folder(v:overall:dances) {
				set gui(v:folder) $old_folder.$dance
				set gui(v:dance) $dance
				print:summary $gui(pref:print:mode)
				progressBarUpdate 1
			}
			set gui(v:folder) $old_folder
			set gui(v:dance) $old_dance
		}

	} else {
		#---- mode normal = rounds
		foreach round $folder(levels) {
			if {[info exists folder(couples:$round)]} {
				print:round $round
			}
		}
	}
	return $print
}

proc skating::print:round {round} {
variable gui

	if {$round == ""} {
		return ""
	}

	if {$round != "finale"} {
		return [skating::print:$gui(pref:print:format):round $gui(v:folder) $round]
	} else {
		return [skating::print:$gui(pref:print:format):finale $gui(v:folder)]
	}
}

proc skating::print:event {withResult {subtitle {}}} {
variable gui

	if {$withResult && $gui(v:ten)} {
		return [skating::print:$gui(pref:print:format):result:ten]
	} else {
		return [skating::print:$gui(pref:print:format):event $withResult $subtitle]
	}
}

proc skating::print:summary {mode} {
variable gui
global msg

#TRACEF "$gui(v:folder) / $gui(pref:print:orientation)"
	set header ""
	if {$gui(v:subten)} {
		set header "$msg(prt:summaryFor) '$gui(v:dance)'"
	}

	if {[string match "idsf:*" $mode]} {
		#---- bilan au format IDSF avec statistics
		return [skating::print:$gui(pref:print:format):$mode $gui(v:folder) $mode $header]
	} else {
		#---- bilan ordonné par couple ou place
		return [skating::print:$gui(pref:print:format):summary $gui(v:folder) $mode $header]
	}
}

proc skating::print:panels {} {
variable gui

	return [skating::print:$gui(pref:print:format):panels $gui(v:folder)]
}

proc skating::print:competitions {} {
variable gui

	return [skating::print:$gui(pref:print:format):competitions $gui(v:folder)]
}

proc skating::print:marksSheets {type} {
variable gui

	return [skating::print:$gui(pref:print:format):marksSheets $gui(v:folder) $gui(v:round) $type]
}

proc skating::print:enrollment:competitions {} {
variable gui

	return [skating::print:$gui(pref:print:format):enrollment:competitions]
}

proc skating::print:enrollment:couples {} {
variable gui

	return [skating::print:$gui(pref:print:format):enrollment:couples $gui(v:folder) $gui(pref:print:enrollment)]
}

proc skating::print:enrollment:judges {} {
variable gui

	return [skating::print:$gui(pref:print:format):enrollment:judges]
}


#=================================================================================================
#
#	Impression -- dialogue pour le choix 'enrollment:competitions'
#
#=================================================================================================

proc skating::print:enrollment:competitions:dialog {} {
global tkPriv
global msg
variable gui


	# construit la dialog
	destroy .dialog
	set w [toplevel .dialog]
	wm title $w $msg(print)
	wm iconname $w Dialog
	wm withdraw $w

	# partie haute du dialogue
	set top [frame $w.top -bd 0]
		# scrolled window pour la liste des compétitions
		set sw [ScrolledWindow::create $top.liste \
						-scrollbar both -auto both -relief sunken -borderwidth 1]
		set t [text [ScrolledWindow::getframe $sw].t \
						-bg gray95 -relief flat -borderwidth 0 \
						-width 1 -height 1 -highlightthickness 0 \
						-cursor {} -insertofftime 1000000 -insertontime 0]
		ScrolledWindow::setwidget $sw $t
		pack $sw -expand true -fill both -side top
		# remplit la zone de texte
		print:enrollment:competitions:fill $t

		# boutons d'accès rapide aux rounds
		set f [frame $top.quick -bd 1 -relief sunken]
		pack [label $f.l -text "$msg(rounds)   "] -side left -padx 5
		foreach i {1 2 3 4 5 6 7 8 9 10 11} {
			button $f.$i -text "$i" -width 3 -bd 1 \
					-command "skating::print:enrollment:competitions:round $t [expr $i-1]"
			pack $f.$i -side left -padx 2
		}
		pack $f -side top -pady 5 -ipadx 5 -ipady 5 -fill x

		# quelques options
		pack [frame $top.sep -height 10] -side top
		foreach o {o1 o2 o3} name {judges dances select pageBreak2} {
			checkbutton $top.$o -text $msg(competitionsEnrollment:$name) -bd 1 \
								-variable ::skating::gui(pref:print:enrollment:$name)
			pack $top.$o -anchor w -side top
		}


	pack $top -side top -expand true -fill both -padx 5 -pady 5

	# frame des boutons
	set but [frame $w.but -bd 1 -relief raised]
	  button $but.ok -text $msg(dlg:ok) -underline 0 -bd 1 -width 7 \
			-command "set tkPriv(button) ok" -default active
	  button $but.can -text $msg(dlg:cancel) -underline 0 -bd 1 -width 7 \
			-command "set tkPriv(button) cancel"
	  grid $but.ok $but.can -sticky ew -padx 10 -pady 5
	pack $but -fill x -anchor c -side bottom

	# affichage
	wm geometry $w 640x480
	centerDialog .top $w 640 480

	#-------------
	# dialog modal
	set oldFocus [focus]
	set oldGrab [grab current $w]
	if {$oldGrab != ""} {
		set grabStatus [grab status $oldGrab]
	}
	grab $w
	focus $w.but.ok
	# key bindings
	bind $w <Alt-o> "set tkPriv(button) ok"
	bind $w <Return> "set tkPriv(button) ok"
	bind $w <Alt-a> "set tkPriv(button) cancel"
	bind $w <Alt-c> "set tkPriv(button) cancel"
	bind $w <Escape> "set tkPriv(button) cancel"

	# attente choix utilisateur
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
	# retourne résultat (0 pour Cancel, !0 pour Ok)
#TRACE "result = [string equal $tkPriv(button) ok]"
	return [string equal $tkPriv(button) "ok"]
}


proc skating::print:enrollment:competitions:fill {t} {
global msg
variable gui
variable event

	# configuration du text
	$t configure -tabs {50}
#	bindtags $t "$t all"

	# choix du round pour chaque compétition
	set i 1
	set max 0
	foreach f $event(folders) {
		variable $f
		upvar 0 $f folder

		if {$folder(mode) == "ten"} {
			foreach dance $folder(dances) {
				variable $f.$dance
				upvar 0 $f.$dance Dfolder
				
				print:enrollment:competitions:folder $t $f $f.$dance
			}
		} else {
			print:enrollment:competitions:folder $t $f $f
		}
	}

	incr max 50
	$t configure -tabs $max
	$t delete "end-2c" end
}


proc skating::print:enrollment:competitions:folder {t base f} {
global msg
variable gui

variable $f
upvar 0 $f folder

upvar i i max max


#TRACEF

	# par défaut active tout,
	# sauf si un folder est sélectionné = activé seulement
	if {$gui(v:folder) == "" || $gui(v:folder) == $base} {
		set ::enrollment(use:$f) 1
	} else {
		set ::enrollment(use:$f) 0
	}

	# checkbutton avec nom de la compétition
	if {[string first "." $f] != -1} {
		checkbutton $t.$i -text "$folder(label) / [lindex $folder(dances) 0]" \
					-bg gray95 -bd 1 -highlightthickness 0 \
					-variable ::enrollment(use:$f)
	} else {
		checkbutton $t.$i -text $folder(label) -bg gray95 -bd 1 \
					-highlightthickness 0 \
					-variable ::enrollment(use:$f)
	}
	$t window create $i.end -align center -padx 10 -pady 5 -window $t.$i
	set x [winfo reqwidth $t.$i]
	if {$x > $max} {
		set max $x
	}
	$t insert $i.end "\t"

	# menu pour choix du round
	set values [list ]
	if {($folder(mode) == "normal" && [info exists folder(couples:finale)] && [class:dances $f])} {
		lappend values $msg(result)
	}
	foreach round [reverse $folder(levels)] {
		if {[info exists folder(couples:$round)]} {
			lappend values $folder(round:$round:name)
		}
	}
	if {[llength $values] == 0} {
		# rien de sélectionnable -- disable entrée
		set ::enrollment(use:$f) 0
		$t.$i configure -state disabled
	} else {
		# une combo box pour le choix du round à afficher
		set ::enrollment(round:$f) [lindex $values 0]
		ComboBox::create $t.m_$i -bd 1 -height 0 \
				-editable 0 -entrybg gray95 \
				-selectbackground $gui(color:selection) \
				-labelwidth 0 \
				-values $values -width 30 \
				-textvariable ::enrollment(round:$f)
		$t window create $i.end -align center -padx 10 -pady 2 -window $t.m_$i
	}
	$t insert $i.end "\n"
	# compétition suivante
	incr i
}


proc skating::print:enrollment:competitions:round {t depth} {
variable event

	set i 1
	foreach f $event(folders) {
		if {![winfo exists $t.m_$i]} {
			incr i
			continue
		}

		variable $f
		upvar 0 $f folder

		if {$folder(mode) == "ten"} {
			foreach dance $folder(dances) {
				variable $f.$dance
				upvar 0 $f.$dance Dfolder
				
				# liste des rounds
				set list [ComboBox::cget $t.m_$i -values]
				# calcule valeur en fonction de la demande
				set what [lindex $list end-$depth]
				if {$what == ""} {
					set what [lindex $list 0]
				}
				# positionne la variable
				set ::enrollment(round:$f.$dance) $what

				# suivant
				incr i
			}

		} else {
			# liste des rounds
			set list [ComboBox::cget $t.m_$i -values]
			# calcule valeur en fonction de la demande
			set what [lindex $list end-$depth]
			if {$what == ""} {
				set what [lindex $list 0]
			}
			# positionne la variable
			set ::enrollment(round:$f) $what

			# suivant
			incr i
		}
	}
}
