##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Bilan pour une compétition + gestion d'attributs définis par l'utilisateur
#
#=================================================================================================

proc skating::manage:general:init {ff} {
global msg
variable gui
variable event
variable $ff
upvar 0 $ff folder

	set w [NoteBook::getframe $gui(w:notebook) "general"]
	# se détruit pour mise à jour (appel lors d'un raise pour prise en compte changement
	# dans le nombre de couples, de juges et les rounds)
	# HACK : destroy & create Notebook::frame car pb de geometry manager avec grid ...
	destroy $w
	frame $w -relief flat -background [Widget::getoption $gui(w:notebook) -background] -borderwidth 10

	#---- résumé

	# les danses
	set dances [TitleFrame::create $w.d -text $msg(dances)]
	set f [TitleFrame::getframe $dances]
	set sw [ScrolledWindow::create $f.sw -scrollbar both -auto both -relief sunken -borderwidth 0]
	set l [listbox [ScrolledWindow::getframe $sw].sel -bd 0 -bg [$f cget -bg] \
					-width 25 -height 5 -font normal]
	foreach d $folder(dances) {
		$l insert end $d
	}
	ScrolledWindow::setwidget $sw $l
	pack $sw  -fill both -expand true

	# les boites pour infos : Couples/Juges/Rounds
	set couples [TitleFrame::create $w.c -text $msg(couples)]
	set judges [TitleFrame::create $w.j -text $msg(judges)]
	set rounds [TitleFrame::create $w.r -text $msg(rounds)]

	if {$folder(mode) == "ten"} {
		# un click sur une danse affiche les infos sur cette danse
		$l configure -selectbackground $::skating::gui(color:selection) -selectmode browse
		bind $l <<ListboxSelect>> "skating::manage:general:init:showFolder $ff.\[$l get \[$l cursel\]\] $couples $judges $rounds"
		$l selection set 0
		manage:general:init:showFolder $ff.[lindex $folder(dances) 0] $couples $judges $rounds

	} elseif {$folder(mode) == "normal" || $folder(mode) == "qualif"} {
		# pas de binding sur la liste des danses
		bindtags $l "$l all"
		# rempli avec info sur folder
		manage:general:init:showFolder $ff $couples $judges $rounds
	}

	# les attributs
	set attr [TitleFrame::create $w.a -text $msg(attributes)]
	set f [TitleFrame::getframe $attr]
	set sw [ScrolledWindow::create $f.sw -scrollbar both -auto both -relief sunken -borderwidth 0]
	after idle "skating::manage:attributes:init $ff $sw"
	pack $sw -fill both -expand true -side left

	# mise en page
	grid $dances	$couples	-sticky news -padx 5 -pady 5
	grid $judges	$rounds		-sticky news -padx 5 -pady 5
	grid $attr		-			-sticky news -padx 5 -pady 5

	# @OCM@: button de refresh
	if {$gui(pref:mode:linkOCM)} {
		set heatid "not defined"
		catch { set heatid [set ::skating::${ff}(heatid)] }
		label $w.ocm -text "Heat ID: $heatid"

		grid $w.ocm [frame $w.ocm2] -sticky nws -padx 5 -pady 5

		set col 1
		foreach round $folder(levels) {
			button $w.ocm2.b$col -bd 1 -text "Refresh ($msg(round:short:$round))" -width 15 \
							  -command "OCM::refresh [list $ff] [list $round]"
			if {$col > 1 && ![info exists folder(couples:$round)]} {
				$w.ocm2.b$col configure -state disabled
			}
			pack $w.ocm2.b$col -padx 2 -pady 5 -side left
			incr col
		}

	}

	grid columnconfigure $w {0} -weight 1
	grid columnconfigure $w {1} -weight 3
	grid rowconfigure $w {0} -weight 3
	grid rowconfigure $w {1} -weight 1
	grid rowconfigure $w {2} -weight 6

	# init sélection clavier : pas de clavier
	fastentry:mode {}
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:general:init:showFolder {f couples judges rounds} {
variable $f
upvar 0 $f folder
variable event
global msg

#TRACEF

	# les couples
	TitleFrame::configure $couples -text "[llength $folder(couples:all)] $msg(couples)"
	set f [TitleFrame::getframe $couples]
	destroy $f.sw
	set sw [ScrolledWindow::create $f.sw -scrollbar vertical -auto both -relief sunken -borderwidth 0]
	set l [listbox [ScrolledWindow::getframe $sw].sel -bd 0 -bg [$f cget -bg] \
					-width 25 -height 5 -font normal]
	bindtags $l "$l all"
	foreach couple $folder(couples:names) {
		$l insert end "[expr {int($couple)}] - [couple:name "" $couple]"
	}
	ScrolledWindow::setwidget $sw $l
	pack $sw -fill both -expand true

	# les rounds + juges
	set f [TitleFrame::getframe $rounds]
	destroy $f.sw
	set sw [ScrolledWindow::create $f.sw -scrollbar vertical -auto both -relief sunken -borderwidth 0]
	set l [table [ScrolledWindow::getframe $sw].sel \
				-rows [llength $folder(levels)] -cols 2 -cursor {} \
				-variable ::summary \
				-highlightthickness 0 \
				-borderwidth 0 -relief solid -bg gray95 \
				-titlerows 0 -roworigin 0 -titlecols 0 -colorigin 0 \
				-colstretchmode none -rowstretchmode none \
				-bg [$f cget -bg] -font normal]
	bindtags $l "$l all"
	$l tag configure left -anchor w
	$l width 0 30 1 40
	set i 0
	set judgesList [list ]
	$l set row 0,0 [list "" ""]
	foreach round $folder(levels) {
		$l set row $i,0 [list $folder(round:$round:name) \
							  [lsort -command skating::event:judges:sort $folder(judges:$round)]]
		set judgesList [concat $judgesList $folder(judges:$round)]
		$l tag row left $i
		incr i
	}
	ScrolledWindow::setwidget $sw $l
	pack $sw -fill both -expand true

	# les juges
	set f [TitleFrame::getframe $judges]
	destroy $f.sw
	set sw [ScrolledWindow::create $f.sw -scrollbar both -auto both -relief sunken -borderwidth 0]
	set l [listbox [ScrolledWindow::getframe $sw].sel -bd 0 -bg [$f cget -bg] \
					-width 25 -height 6 -font normal]
	bindtags $l "$l all"
	foreach j $folder(judges:requested) {
		lappend judgesList $j
	}
	foreach j [lsort -unique -command skating::event:judges:sort $judgesList] {
		$l insert end "$j - $event(name:$j)"
	}
	ScrolledWindow::setwidget $sw $l
	pack $sw -fill both -expand true
}

#-------------------------------------------------------------------------------------------------

proc skating::manage:attributes:init {f sw} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder

#puts "skating::manage:attributes:init {$f $sw}"
	set w [ScrolledWindow::getframe $sw]
	set c [canvas $w.t -highlightthickness 0 -bg [. cget -bg] -height 1]

	# type
	set pos 0
	ComboBox::create $c.type -bd 1 -height 0 \
			-editable 0 -entrybg gray95 \
			-selectbackground $gui(color:selection) \
			-label $msg(attributes:type) -labelfont normal -labelwidth 20 \
			-values $gui(pref:attributes:type) -width 24 \
			-textvariable skating::${f}(attributes:type)
	$c create window 0 $pos -anchor nw -window $c.type
	trace variable skating::gui(pref:attributes:type) w \
			"ComboBox::configure $c.type -values \$skating::gui(pref:attributes:type); list "

	# classe d'age
	set pos 25
	ComboBox::create $c.amin -bd 1 -height 0 \
			-editable 0 -entrybg gray95 \
			-selectbackground $gui(color:selection) \
			-label $msg(attributes:age) -labelfont normal -labelwidth 20 \
			-values $gui(pref:attributes:agemin) -width 3 \
			-modifycmd "skating::manage:attributes:age:modify [list $f] $c" \
			-textvariable skating::${f}(attributes:age:min)
	trace variable skating::gui(pref:attributes:agemin) w \
			"ComboBox::configure $c.amin -values \$skating::gui(pref:attributes:agemin); list "
	ComboBox::create $c.amax -bd 1 -height 0 \
			-editable 0 -entrybg gray95 \
			-selectbackground $gui(color:selection) \
			-labelwidth -1 \
			-values $gui(pref:attributes:agemax) -width 3 \
			-textvariable skating::${f}(attributes:age:max)
	trace variable skating::gui(pref:attributes:agemax) w \
			"ComboBox::configure $c.amax -values \$skating::gui(pref:attributes:agemax); list "
	ComboBox::create $c.aext -bd 1 -height 0 \
			-editable 0 -entrybg gray95 \
			-selectbackground $gui(color:selection) \
			-labelwidth -1 \
			-values $gui(pref:attributes:ageext) -width 10 \
			-textvariable skating::${f}(attributes:age:ext)
	trace variable skating::gui(pref:attributes:ageext) w \
			"ComboBox::configure $c.aext -values \$skating::gui(pref:attributes:ageext); list "

	set id [$c create window 0 $pos -anchor nw -window $c.amin]
	update
	foreach {x y xx yy} [$c bbox $id] break
	$c create line [expr {$xx+3}] [expr {$y+($yy-$y)/2}] [expr {$xx+10}] [expr {$y+($yy-$y)/2}] -width 2
	set id [$c create window [expr {$xx+13}] $pos -anchor nw -window $c.amax]
	update
	foreach {x y xx yy} [$c bbox $id] break
	set id [$c create window [expr {$xx+9}] $pos -anchor nw -window $c.aext]

	# niveau
	set pos 50
	ComboBox::create $c.lev -bd 1 -height 0 \
			-editable 0 -entrybg gray95 \
			-selectbackground $gui(color:selection) \
			-label $msg(attributes:level) -labelfont normal -labelwidth 20 \
			-width 24 -values $gui(pref:attributes:level) \
			-textvariable skating::${f}(attributes:level)
	$c create window 0 $pos -anchor nw -window $c.lev
	trace variable skating::gui(pref:attributes:level) w \
			"ComboBox::configure $c.lev -values \$skating::gui(pref:attributes:level); list "

	# bouton de réglage de l'impression
	set pos 100
	button $c.o -bd 1 -image imgOption -command "skating::gui:options attributes"
	$c create window 0 $pos -anchor w -window $c.o
	button $c.p -bd 1 -image imgPrintSetup -command "skating::gui:options print2"
	$c create window 50 $pos -anchor w -window $c.p
	# bouton de génération du nom de la compétition
	button $c.n -bd 1 -text $msg(generateFolderName) -command "skating::manage:general:nameFolder [list $f]"
	$c create window 140 $pos -anchor w -window $c.n


	# ajuste la région de scrolling
#	$c create rectangle 0 0 370 [expr {$pos+20}]
	$c configure -scrollregion [list 0 0 370 [expr {$pos+20}]]
	# fin init ScrolledWindow
	ScrolledWindow::setwidget $sw $c
}

#----------------------------------------------------------------------------------------------

proc skating::manage:general:nameFolder {f} {
variable event
variable gui
variable $f
upvar 0 $f folder

#puts "skating::manage:general:nameFolder {$f}"

	# construit le label
	set label [manage:attributes:parseFormat $f $gui(pref:folderNaming)]

	# affecte le résultat
	set folder(label) $label
	if {$folder(mode) == "ten"} {
		foreach dance $folder(dances) {
			set ::skating::$f.${dance}(label) $label
		}
	}
	# mise à jour affichage
	Tree::itemconfigure $gui(w:tree) $f -text $label
	set ::skating::displayFolder $label
}

#----------------------------------------------------------------------------------------------

proc skating::manage:attributes:parseFormat {f format {round ""} {dance ""}} {
variable event

	# on utilise le dossier "racine" pour les dix-danses
	if {[set i [string first "." $f]] != -1} {
		set fr [string range $f 0 [expr {$i-1}]]
	} else {
		set fr $f
	}

variable $f
upvar 0 $f folder
variable $fr
upvar 0 $fr folderRoot

upvar header header

#TRACEF

	# numéro d'index de la compétition
	set index [expr {[lsearch $event(folders) $f]+1}]
	# nombre de couples
	if {[info exists folder(couples:all)]} {
		set nbcouples [llength $folder(couples:all)]
	} else {
		set nbcouples 0
	}
	# définition des méta-expressions
	set list [list ]
		# attributs compétition
		lappend list	%agemin		folderRoot(attributes:age:min)
		lappend list	%agemax		folderRoot(attributes:age:max)
		lappend list	%ageextra	folderRoot(attributes:age:ext)
		lappend list	%type		folderRoot(attributes:type)
		lappend list	%level		folderRoot(attributes:level)
		# attributs globaux
		foreach a $::attributesList {
			lappend list %[string range $a  1 end] event(attributes:$a)
		}
		# données globales
		lappend list	%nbcouples	nbcouples
		lappend list	%header		header
		lappend list	%label		folder(label)
		lappend list	%round		folder(round:$round:name)
		lappend list	%dance		dance
		lappend list	%index		index
		lappend list	%title		event(general:title)
		lappend list	%date		event(general:date)
	# construit la liste des valeurs à substituer
	set substitute [list ]
	foreach {name var} $list {
		if {![info exists $var]} {
			set value ""
		} else {
			set value [set $var]
		}
		lappend substitute $name $value
	}
	# on formatte
#puts "string map -nocase '$substitute' '$format'"
	string map -nocase $substitute $format
}

proc skating::manage:attributes:getLabel {f format {round ""} {dance ""}} {
global msg
variable event

	# on utilise le dossier "racine" pour les dix-danses
	if {[set i [string first "." $f]] != -1} {
		set fr [string range $f 0 [expr {$i-1}]]
	} else {
		set fr $f
	}

variable $f
upvar 0 $f folder
variable $fr
upvar 0 $fr folderRoot

#TRACEF

	# numéro d'index de la compétition
	set index [expr {[lsearch $event(folders) $f]+1}]
	# définition des méta-expressions
	set list [list ]
		# attributs compétition
		lappend list	%agemin		attributes:agemin
		lappend list	%agemax		attributes:agemax
		lappend list	%ageextra	attributes:ageext
		lappend list	%type		attributes:type
		lappend list	%level		attributes:level
		# attributs globaux
		foreach a $::attributesList {
			lappend list %[string range $a  1 end] attributes:$a
		}
		# données globales
		lappend list	%nbcouples	prt:nbcouples
		lappend list	%label		label
		lappend list	%round		prt:round
		lappend list	%dance		prt:dance
		lappend list	%index		round:
		lappend list	%title		title
		lappend list	%date		date
	# construit la liste des valeurs à substituer
	set substitute [list ]
	foreach {name var} $list {
		set value $msg($var)
		lappend substitute $name $value
	}
	# on formatte
#puts "string map -nocase '$substitute' '$format'"
	string map -nocase $substitute $format
}

#----------------------------------------------------------------------------------------------

proc skating::manage:attributes:age:modify {f c} {
variable gui
variable $f
upvar 0 $f folder

	set index [lsearch $gui(pref:attributes:agemin) $folder(attributes:age:min)]
	set folder(attributes:age:max) [lindex $gui(pref:attributes:agemax) $index]
}
