##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer



#--------------------
# liste des attributs
#--------------------
set ::attributesList {_place _organizer _member _masterCeremony 
					  _chairman _music _scrutineer _support}

#--------------------------------------------------------------------------

proc skating::getAttribute {name} {
global msg
variable gui
variable event

}

#--------------------------------------------------------------------------

proc skating::setAttributes {} {
global msg
variable gui
variable event

#TRACEF

	# cherche les attributs dans 'event'
	foreach a [array names event attributes:*] {
		# récupération du nom
		scan $a "attributes:%s" name
		# cherche son index
		set index [lsearch $::attributesList $name]
		if {$index != -1} {
			set ::attributes($index,0) $event($a)
		}
	}
}

#--------------------------------------------------------------------------

proc skating::syncAttributes {} {
global msg
variable gui
variable event

#TRACEF

	# efface vieilles données
	foreach a [array names event attributes:*] {
		unset event($a)
	}
	# stocke les nouveaux
	set i 0
	foreach a $::attributesList {
		if {[info exist ::attributes($i,0)]} {
			set event(attributes:$a) $::attributes($i,0)
		}
		incr i
	}
}

#--------------------------------------------------------------------------

proc skating::event:general:attributes {w font} {
global msg
variable gui
variable event

	# une table
	set t [table $w.t -bd 0 -bg gray95 \
				-font $font -highlightthickness 1 \
				-bordercursor {} \
				-titlecols 1 -colorigin -1 \
				-colstretchmode last -borderwidth 1 \
				-height [llength $::attributesList] \
				-rows [llength $::attributesList] \
				-cols 2 -variable ::attributes]

	# configuration des stylse (left, center, active, title, sel)
	$t tag configure left -anchor w
	$t tag configure center -anchor c
	$t tag configure active -relief solid -bd 1 -bg white -anchor w
	$t tag configure title -relief raised -bd 1 -bg [. cget -bg] -fg black -font {bold}
	$t tag configure sel -bg {} -fg {}

	# initialise la première colonnes avec le nom des attributs
	$t tag col left -1 0
	set i 0
	set width 0
	foreach attribute $::attributesList {
		$t set $i,-1 $msg(attributes:$attribute)
		if {[string length $msg(attributes:$attribute)] > $width} {
			set width [string length $msg(attributes:$attribute)]
		}
		incr i
	}
	$t width -1 $width

	# qqs bindings
	bind $t <Tab> {::tk::table::MoveCell %W +1 0; break}
	bind $t <Shift-Tab> {::tk::table::MoveCell %W -1 0; break}
	catch {	bind $t <ISO_Left_Tab> {::tk::table::MoveCell %W -1 0; break} }
	bind $t <Return> {::tk::table::MoveCell %W 1 0; break}

	bind $t <FocusOut> {%W activate -1,-1}

	return $t
}