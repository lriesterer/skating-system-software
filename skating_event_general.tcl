##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

proc skating::gui:event {} {
global msg
variable event
variable gui


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

	# onglet pour les définitions générales
	set general [NoteBook::insert $gui(w:notebook) end "general" -text $msg(event) \
						-raisecmd "skating::event:general:refresh"]
	  event:general:init $general

	# onglet pour la définition des couples
	set couples [NoteBook::insert $gui(w:notebook) end "couples" -text $msg(couples)]
		NoteBook::itemconfigure $gui(w:notebook) "couples" \
						-createcmd "skating::event:couples:init $couples"

	# onglet pour le choix des juges
	set judges [NoteBook::insert $gui(w:notebook) end "judges" -text $msg(judges)]
		NoteBook::itemconfigure $gui(w:notebook) "judges" \
						-createcmd "skating::event:judges:init $judges" \
						-raisecmd "skating::event:judges:refresh"

	# onglet pour la gestion des panels de juges
	set panels [NoteBook::insert $gui(w:notebook) end "panels" -text $msg(Panels)]
		NoteBook::itemconfigure $gui(w:notebook) "panels" \
						-createcmd "skating::event:panels:init $panels" \
						-raisecmd "skating::event:panels:refresh"

	# onglet pour gestion de la base données
#  	set database [NoteBook::insert $gui(w:notebook) end "database" -text $msg(database) \
#  						-raisecmd "skating::event:database:refresh"]
#  	  event:database:init $database

	# montrer l'onglet couples
	NoteBook::raise $gui(w:notebook) "general"
}

#-------------------------------------------------------------------------------------------------

proc skating::event:general:init {w} {
global msg
variable gui
variable event

	# date
	set f [frame $w.date]
	  label $f.l -text $msg(date) -width 15 -anchor w
	  entry $f.e -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
			-textvariable ::skating::event(general:date)
		bindEntry $f.e {}
	  pack $f.l -side left
	  pack $f.e -side left -fill x -expand true
	pack $f -side top -fill x
	# titre
	set f [frame $w.title]
	  label $f.l -text $msg(title) -width 15 -anchor w
	  entry $f.e -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
			-textvariable ::skating::event(general:title)
		bindEntry $f.e {}
	  pack $f.l -side left
	  pack $f.e -side left -fill x -expand true
	pack $f -side top -fill x -pady 10
	# commentaires
	set f [frame $w.comment]
	  label $f.l -text $msg(comment) -width 15 -anchor w
	  set sw [ScrolledWindow::create $f.sw \
					-scrollbar both -auto both -relief sunken -borderwidth 1]
	  set gui(w:init:comment) [text [ScrolledWindow::getframe $sw].e -bd 0 -bg gray95 -height 1 \
				-selectbackground $gui(color:selection) -font [$w.title.e cget -font] -wrap word]
		bindEntry $gui(w:init:comment) "::skating::event(general:comment)"
	  ScrolledWindow::setwidget $sw $gui(w:init:comment)
	  pack $f.l -side left
	  pack $f.sw -side left -fill both -expand true
	pack $f -side top -fill both -expand true -pady 10

	# autres attributs
	set f [frame $w.attributes]
	  label $f.l -text $msg(attributes) -width 15 -anchor w
	  set sw [ScrolledWindow::create $f.sw \
					-scrollbar both -auto both -relief sunken -borderwidth 1]
	  set gui(w:init:attributes) [event:general:attributes [ScrolledWindow::getframe $sw] [$w.title.e cget -font]]
	  ScrolledWindow::setwidget $sw $gui(w:init:attributes)
	  pack $f.l -side left
	  pack $f.sw -side left -fill both -expand true
	pack $f -side top -fill both



	#----------------------------------
	pack [frame $w.sep -bd 2 -relief raised -height 2] -side top -fill x -pady 8

	# infos sur nb competition / couples / juges
	set font [$w.title.e cget -font]
	set f [frame $w.nbcouples]
	  label $f.l -text $msg(couples) -width 15 -anchor w
	  label $f.d -textvariable ::skating::gui(v:event:couples) -anchor w -font $font
	  pack $f.l -side left
	  pack $f.d -side left -fill x -expand true

	  # @OCM@: bouton pour tout recharger
	  if {0 && $gui(pref:mode:linkOCM)} {
		  SpinBox::create $f.ocm2 -labelwidth 15 -label "Heat (0=ALL)" -range {0 100 1} \
					-width 4 -entrybg gray95 -textvariable __OCM_heat__ \
					-selectbackground $gui(color:selection)
		  button $f.ocm -bd 1 -width 15 -text "Reload from OCM" -command "OCM::reload \$__OCM_heat__"
		  pack $f.ocm2 -side right -padx 3
		  pack $f.ocm -side right
	  }

	pack $f -side top -anchor w -fill x

	set f [frame $w.nbjudges]
	  label $f.l -text $msg(judges) -width 15 -anchor w
	  label $f.d -textvariable ::skating::gui(v:event:judges) -anchor w -font $font
	  pack $f.l -side left
	  pack $f.d -side left -fill x -expand true
	pack $f -side top -anchor w -pady 5 -fill x
	
	set f [frame $w.nbcompetitions]
	  label $f.l -text $msg(competitions) -width 15 -anchor w
	  label $f.d -textvariable ::skating::gui(v:event:competitions) -anchor w -font $font
	  pack $f.l -side left
	  pack $f.d -side left -fill x -expand true
	pack $f -side top -anchor w -fill x

	set f [frame $w.detail]
	  label $f.l -text "" -width 15 -anchor w
	  set header [canvas $f.h -bg [$w cget -bg] \
						-borderwidth 0 -height [font metrics "event:data:bold" -linespace] \
						-highlightthickness 0 -cursor {}]
		$header create text 2 0 -font event:data:bold -anchor nw -text $msg(label)
		$header create text 320 0 -font event:data:bold -anchor n -text $msg(couples)
		$header create text 385 0 -font event:data:bold -anchor n -text $msg(judges)
		$header create text 450 0 -font event:data:bold -anchor n -text $msg(rounds)
	  bindtags $header "all"
	  set sw [ScrolledWindow::create $f.d \
					-scrollbar both -auto both -relief sunken -borderwidth 1]
	  set h [expr int(1.1*[font metrics "event:data" -linespace])]
	  set gui(w:event:competitions) [canvas [ScrolledWindow::getframe $sw].c \
											-yscrollincrement $h -height 1 -bg gray95 \
											-relief flat -borderwidth 0 -highlightthickness 0]
	  ScrolledWindow::setwidget $sw $gui(w:event:competitions)
	  pack $f.l -side left
	  pack $f.h -side top -fill x
	  pack $f.d -side top -fill both -expand true
	pack $f -side top -anchor w -fill both -expand true

	# initialise le champ de commentaire
	$gui(w:init:comment) delete 0.0 end
	if {[info exists event(general:comment)]} {
		$gui(w:init:comment) insert end $event(general:comment)
	}
	#event:general:refresh called automatically
}

proc skating::event:general:refresh {} {
global msg
variable event
variable gui

	# couples
	set skating::gui(v:event:couples) [llength $event(couples)]
	# juges
	set skating::gui(v:event:judges) [llength $event(judges)]
	# competitions
	set skating::gui(v:event:competitions) [llength $event(folders)]
	set c $gui(w:event:competitions)
	set h [expr int(1.1*[font metrics "event:data" -linespace])]
	$c delete all
	set y 0
	foreach f $event(folders) {
		variable $f
		upvar 0 $f folder

		
		set listOfFolder [list $f]
		if {$folder(mode) == "ten"} {
			foreach dance $folder(dances) {
				lappend listOfFolder $f.$dance
			}
		}

		foreach f $listOfFolder {
			variable $f
			upvar 0 $f folder

			# fond pour click
			set bg [$c cget -background]
			$c create rectangle 0 [expr $y-1] 2000 [expr $y+$h-1] -tag "$f" -fill $bg -outline $bg
			# regarder si 10-danses
			set dance [lindex [split $f "."] 1]
			# label
			if {$dance != ""} {
				set label "    $folder(label) - $dance"
				set font normal
			} else {
				set label $folder(label)
				if {$folder(mode) != "ten"} {
					set font normal
				} else {
					set font bold
				}
			}

			if {[string length $label] > 50} {
		  		set label "[string range $label 0 50]..."
			}
			set tag [string map {" " "_"} $f]
			$c create text 2 $y -anchor nw -text $label -font $font -tag "$tag"

			if {$folder(mode) != "ten"} {
				# nb couples
				$c create text 330 $y -anchor ne -text [llength $folder(couples:names)] -tag "$tag"
				$c create text 348 $y -anchor n -text "/" -tag "$tag"
				# nb juges
				$c create text 390 $y -anchor ne -text [llength $folder(judges:finale)] -tag "$tag"
				$c create text 420 $y -anchor n -text "/" -tag "$tag"
				# nb rounds
				$c create text 445 $y -anchor ne -text [llength $folder(levels)] -tag "$tag"
			}
			# binding : click = selection de la compétition
			$c bind $tag <1> "skating::gui:select 1 $tag"
			# suivant
			incr y $h
		}
	}
	$c configure -scrollregion [list 0 0 458 $y]
}
