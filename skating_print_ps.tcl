##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion des impressions en mode Postscript
#
#=================================================================================================

#---- 75 dpi
#  array set skating::paperSize {
#  	a4			{621 878		21c 29.7c	10.5c 14.85c}
#  	letter		{637 825		8.5i 11i	4.25i 6.5i}
#  	legal		{637 1050		8.5i 14i	4.25i 7i}
#  }
#---- 100 dpi
#  array set skating::paperSize {
#  	a4			{827 1170		21c 29.7c	10.5c 14.85c}
#  	letter		{850 1100		8.5i 11i	4.25i 6.5i}
#  	legal		{850 1400		8.5i 14i	4.25i 7i}
#  }
#---- moyenne entre 75 et 100dpi
array set skating::paperSize {
	a4			{724 1024		21c 29.7c	10.5c 14.85c}
	letter		{744 962		8.5i 11i	4.25i 6.5i}
	legal		{744 1225		8.5i 14i	4.25i 7i}
}

array set skating::gui {
	prt:spacing:table	1.0
	prt:spacing:normal	1.1
	prt:spacing:bold	1.25
	prt:spacing:big		1.4
}

proc skating::print:ps:setup {} {
variable gui

	# initialise pages + numérotation des pages
	set gui(v:print:pages) {}
	set gui(v:print:pages:orientation) {}
	set gui(v:page) 1
}

proc skating::print:ps:set:margins {orientation} {
variable gui
variable paperSize

	set paper [string tolower $gui(pref:print:paper)]
	if {$orientation == "-portrait"} {
		set gui(t:w) [lindex $paperSize($paper) 0]
		set gui(t:h) [lindex $paperSize($paper) 1]
		set gui(t:m:l) $gui(pref:print:margin:left)
		set gui(t:m:r) $gui(pref:print:margin:right)
		set gui(t:m:t) $gui(pref:print:margin:top)
		set gui(t:m:b) $gui(pref:print:margin:bottom)
	} elseif {$orientation == "-landscape"} {
		set gui(t:w) [lindex $paperSize($paper) 1]
		set gui(t:h) [lindex $paperSize($paper) 0]
		set gui(t:m:t) $gui(pref:print:margin:left)
		set gui(t:m:b) $gui(pref:print:margin:right)
		set gui(t:m:l) $gui(pref:print:margin:top)
		set gui(t:m:r) $gui(pref:print:margin:bottom)
	} else {
		error "unknow paper orientation"
	}

	# largeur & hauteur
	set gui(v:print:width) $gui(t:w)
	set gui(v:print:height) [expr {$gui(t:h)-1}]

	# positions courantes
	set gui(t:l) $gui(t:m:l)
	set gui(t:r) [expr {$gui(t:w)-$gui(t:m:r)}]
	set gui(t:t) $gui(t:m:t)
	set gui(t:b) [expr {$gui(t:h)-$gui(t:m:b)}]
}

#-------------------------------------------------------------------------------------------------

proc skating::print:ps:header {f c style boxed} {
variable event
variable gui
variable $f
upvar 0 $f folder
global msg

upvar subtitle header

#TRACEF

	if {$boxed} {
		set padX 5
	} else {
		set padX 0
	}


	global tcl_platform
	if {$tcl_platform(platform) == "windows"} {
		set spaceBefore 5
		set spaceAfter 10
	} else {
		set spaceBefore 10
		set spaceAfter 5
	}

	# 1ere ligne
	set text_l [manage:attributes:parseFormat $f $gui(pref:format:text:${style}1_l)]
	set text_c [manage:attributes:parseFormat $f $gui(pref:format:text:${style}1_c)]
	set text_r [manage:attributes:parseFormat $f $gui(pref:format:text:${style}1_r)]
	set y [expr $gui(t:t)+$spaceBefore]
	if {$text_l != "" || $text_c != "" || $text_r != ""} {
		$c create text [expr {$gui(t:l)+$padX}] $y -text $text_l \
				-font $gui(pref:format:font:${style}1_l) -tags title -anchor nw
		$c create text [expr {$gui(t:w)/2}] $y -text $text_c \
				-font $gui(pref:format:font:${style}1_c) -tags title -anchor n
		$c create text [expr {$gui(t:r)-$padX}] $y -text $text_r \
				-font $gui(pref:format:font:${style}1_r) -tags title -anchor ne
		set y [expr [lindex [$c bbox title] 3]+$spaceAfter]
	}
	# 2eme, 3eme et 4eme lignes
	foreach line {2 3 4} {
		if {![info exists gui(pref:format:text:${style}${line}_l)]} {
			continue
		}
		set text_l [manage:attributes:parseFormat $f $gui(pref:format:text:${style}${line}_l)]
		set text_c [manage:attributes:parseFormat $f $gui(pref:format:text:${style}${line}_c)]
		set text_r [manage:attributes:parseFormat $f $gui(pref:format:text:${style}${line}_r)]
		if {$text_l != "" || $text_c != "" || $text_r != ""} {
			$c create text [expr {$gui(t:l)+$padX}] $y -text $text_l \
					-font $gui(pref:format:font:${style}${line}_l) -tags title -anchor nw
			$c create text [expr {$gui(t:w)/2}] $y -text $text_c \
					-font $gui(pref:format:font:${style}${line}_c) -tags title -anchor n
			$c create text [expr {$gui(t:r)-$padX}] $y -text $text_r \
					-font $gui(pref:format:font:${style}${line}_r) -tags title -anchor ne
			set y [expr [lindex [$c bbox title] 3]+5]
		}
	}
	# cadre
	if {$boxed} {
		set id [$c create rectangle $gui(t:l) $gui(t:t) $gui(t:r) $y -width 1.5]
		$c raise $id back
		set y [expr {$y+15}]
	}

	# 1ere et 2eme lignes génériques
	if {[info exists gui(pref:format:text:general${line}_l)]} {
		foreach line {1 2} {
			set text_l [manage:attributes:parseFormat $f $gui(pref:format:text:general${line}_l)]
			set text_c [manage:attributes:parseFormat $f $gui(pref:format:text:general${line}_c)]
			set text_r [manage:attributes:parseFormat $f $gui(pref:format:text:general${line}_r)]
			if {$text_l != "" || $text_c != "" || $text_r != ""} {
				$c create text [expr {$gui(t:l)+$padX}] $y -text $text_l \
						-font $gui(pref:format:font:general${line}_l) -tags gen$line -anchor nw
				$c create text [expr {$gui(t:w)/2}] $y -text $text_c \
						-font $gui(pref:format:font:general${line}_c) -tags gen$line -anchor n
				$c create text [expr {$gui(t:r)-$padX}] $y -text $text_r \
						-font $gui(pref:format:font:general${line}_r) -tags gen$line -anchor ne
				set y [expr [lindex [$c bbox gen$line] 3]+3]
			}
		}
	}

	return [expr {$y+5}]
}

proc skating::print:ps:footer {f c p} {
global msg
variable gui

	# binding pour scrolling
	bind $c <Left>  "$c xview scroll -1 units"
	bind $c <Right> "$c xview scroll +1 units"
	bind $c <Up>    "$c yview scroll -1 units; \
					 if {\[lindex \[$c yview\] 0\] == 0} {incr __prior}; \
					 if {\[lindex \[$c yview\] 1\] != 1} {set __next 0}"
	bind $c <Down>  "if {\[lindex \[$c yview\] 0\] > 0}  {$c yview scroll -1 pages}; \
					 if {\[lindex \[$c yview\] 0\] != 0} {set __prior 0}; \
					 if {\[lindex \[$c yview\] 1\] == 1} {incr __next}"
	bind $c <Prior> "if {\[lindex \[$c yview\] 0\] > 0}  {$c yview scroll -1 pages}; \
					 if {\[lindex \[$c yview\] 0\] == 0} {incr __prior}; \
					 if {\[lindex \[$c yview\] 1\] != 1} {set __next 0}"
	bind $c <Next>  "$c yview scroll +1 pages;  \
					 if {\[lindex \[$c yview\] 0\] != 0} {set __prior 0}; \
					 if {\[lindex \[$c yview\] 1\] == 1} {incr __next}"

	# numéro de page
	if {$p > 0} {
		$c create text $gui(t:l) $gui(t:b) -text "$msg(prt:produced) Skating System Software" \
				-font print:subscript -tags footer -anchor sw
		$c create text [expr {$gui(t:r)}] $gui(t:b) -text "$msg(prt:page) $p" \
				-font print:subscript -tags footer -anchor se
	}
	return [expr [lindex [$c bbox footer] 1]-5]
}

proc skating::print:ps:newpage {f orientation header {subtitle {}} {subtitle2 {}}} {
variable gui

	# initialise les marges en Portrait
	print:ps:set:margins $orientation
	# la zone pour l'impression
	set c [canvas $gui(w:preview:root).p$gui(v:page) -width 1 \
					-height 1 -bg white -highlightthickness 0 \
					-scrollregion [list 0 0 $gui(t:w) $gui(t:h)]]
	$c create rectangle 0 0 [expr $gui(t:w)-1] [expr $gui(t:h)-1] -tag back
	if {$header == "-header"} {
		set gui(t:y) [print:ps:header $f $c header 1]
	} elseif {$header == "-blockheader"} {
		set gui(t:y) [print:ps:header $f $c blockheader 1]
	} else {
		set gui(t:y) $gui(t:t)
	}
	# sous titre(s) éventuel(s)
	if {$header != "-blockheader"} {
		if {$subtitle != ""} {
			$c create text $gui(t:l) [expr $gui(t:y)+10] -text $subtitle \
						-font print:subtitle -anchor w
			incr gui(t:y) [font metrics "print:subtitle" -linespace]
		}
		if {$subtitle2 != ""} {
			$c create text $gui(t:l) [expr $gui(t:y)+10] -text $subtitle2 \
						-font print:normal -anchor w
			incr gui(t:y) [font metrics "print:normal" -linespace]
		}
		if {$subtitle != "" || $subtitle2 != ""} {
			incr gui(t:y) 20
		}
	}
	# y maxi pour la page
	if {$header == "-header" || $header == "-blockheader"} {
		set page $gui(v:page)
	} else {
		set page 0
	}
	set gui(t:max) [print:ps:footer $f $c $page]
	# ajoute la page
	incr gui(v:page)
	lappend gui(v:print:pages) $c
	lappend gui(v:print:pages:orientation) $orientation
	# nouvelle page créée
	progressBarIncrText
	# retourne le canvas
	return $c
}

#-------------------------------------------------------------------------------------------------

proc skating::print:ps:attributesBlock {f c block} {
variable event
variable gui
variable $f
upvar 0 $f folder
global msg

upvar y y
upvar subtitle header

#TRACEF

	global tcl_platform
	if {$tcl_platform(platform) == "windows"} {
		set spaceBefore 5
		set spaceAfter 10
	} else {
		set spaceBefore 10
		set spaceAfter 5
	}

	# définition d'un cartouche
	#---- 1. calcul la largeur de chaque label
	set i 0
	foreach line [split $gui(pref:format:block:$block) \n] {
		if {$line == ""} {
			continue
		}
		if {$line == "-"} {
			incr i
			continue
		}
		regsub -all -- {\s+} $line { } line
		set j 0
		foreach item [split $line " "] {
			set item [manage:attributes:getLabel $f $item]
			set width [print:ps:textWidth $c "$item: " print:bold]
			if {![info exists size($i,$j)] || $width > $size($i,$j)} {
				set size($i,$j) $width
			}
			incr j
		}
		set j 0
		foreach item [split $line " "] {
			set item [manage:attributes:parseFormat $f $item]
			set width [print:ps:textWidth $c "$item: " print:normal]
			if {![info exists size2($i,$j)] || $width > $size2($i,$j)} {
				set size2($i,$j) $width
			}
			incr j
		}
	}

	#---- 2. impression
	set hNormal [expr int($gui(prt:spacing:table)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]

	# ligne de séparation
	$c create line $gui(t:l) [expr $y+3] $gui(t:r) [expr $y+3]
	set y [expr {$y+7}]

	set i 0
	foreach line [split $gui(pref:format:block:$block) \n] {
		if {$line == "" || $line == "-"} {
			# ligne vide = small skip
			$c create line $gui(t:l) [expr $y+3] $gui(t:r) [expr $y+3]
			set y [expr {$y+7}]
			if {$line == "-"} {
				incr i
			}
			continue
		}
		regsub -all -- {\s+} $line { } line
		set j 0
		set x $gui(t:l)
		foreach item [split $line " "] {
			# label
			set text [manage:attributes:getLabel $f $item]
			$c create text $x [expr $y+$hBold/2+1] -anchor w -text "$text:" -font print:bold
			# data
			set text [manage:attributes:parseFormat $f $item]
			$c create text [expr {$x+$size($i,$j)+10}] [expr $y+$hBold/2+1] -anchor w -text $text -font print:normal
			# groupe suivant
			set x [expr {$x+$size($i,$j)+10+$size2($i,$j)+50}]
			incr j
		}
		# ligne suivante
		set y [expr {$y+$hBold}]
	}

	# last skip
	$c create line $gui(t:l) [expr $y+3] $gui(t:r) [expr $y+3]
	set y [expr {$y+10}]
}


#=================================================================================================
#
#	Impression des notes d'une finale
#
#=================================================================================================

proc skating::print:ps:finale {f} {
variable event
variable $f
upvar 0 $f folder
variable gui
global msg


	if {![class:dances $f]} {
		return ""
	}
	class:result $f

	set orientation "-portrait"

	# première page ...
	set text ""
	if {$gui(v:subten)} {
		set text "[lindex $folder(dances) 0] - $folder(round:finale:name)"
	}
	set c [print:ps:newpage $f $orientation -header $text]
	set y $gui(t:y)

	# commentaires
	if {[info exists folder(comments:finale)] && $folder(comments:finale)!=""} {
		$c create text $gui(t:l) $y -width [expr $gui(t:r)-$gui(t:l)] -anchor nw \
					-text [string trim $folder(comments:finale)] \
					-tags "comment" -font print:normal
		set y [expr [lindex [$c bbox comment] 3]+$gui(pref:print:smaller:skipY)]
	}

	# quelques constantes
	set maxWidth [expr $gui(t:r)-$gui(t:l)]

	#---------------------------
	# imprime les couples &juges
	if {$gui(pref:print:useSmallFont)} {
		set font print:small
		set fontBold print:smallbold
	} else {
	set font print:normal
		set fontBold print:bold
	}
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics $font -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics $fontBold -linespace])]
	set shift 0
	set startY $y
	set maxY $y

	set judges [lsort -command skating::event:judges:sort $folder(judges:finale)]
	if {$gui(pref:print:names:judgesResult)} {
		# liste de juges locale ou globale
		set y $startY
		if {$gui(pref:print:names:couplesResult)} {
			print:ps:judges $orientation $judges $font $fontBold \
						[expr $maxWidth*2/3.0] [expr $maxWidth/3.0] right
		} else {
			print:ps:judges $orientation $judges $font $fontBold \
						0 $maxWidth center
		}
		set y [expr $y+10]
		set maxY $y
		set shift 1
	}
	# imprime les couples
	if {$gui(pref:print:names:couplesResult)} {
		# liste des couples, classée par résultat
		foreach couple $folder(couples:finale) rank $folder(result) {
			lappend tmp [list $couple $rank]
		}
		set tmp [lsort -real -index 1 $tmp]
		set couples {}
		foreach data $tmp {
			lappend couples [lindex $data 0]
		}
		# impression
		set y $startY
		if {$gui(pref:print:names:judgesResult)} {
			print:ps:couples $f $couples $font $fontBold 0 [expr $maxWidth*2/3.0] left \
					[expr $gui(pref:print:place) ? $gui(pref:print:place:nb) : 0]
		} else {
			print:ps:couples $f $couples $font $fontBold 0 $maxWidth center
		}
		set y [expr $y+10]
		set shift 1
	}
	if {$maxY > $y} {
		set y $maxY
	}
	if {$shift} {
		set y [expr $y+10]
	}

	#--------------------
	# calcule la taille d'un bloc
	set wBetweenBlocks 20
	set hBetweenBlocks 20
	set hBeforeResult 10
	set hBetweenExplain 15
	set hNormal [expr int($gui(prt:spacing:table)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]
	set height [expr $hBold + $hNormal + [llength $folder(couples:finale)]*$hNormal]

	set wC 29
	set twJ 0
	foreach judge $judges {
		if {[string length $judge] > 1} {
			set wJ($judge) [expr {$twJ+12}]
			set wJ($judge:l) $twJ
			incr twJ 24
			set wJ($judge:r) $twJ
		} else {
			set wJ($judge) [expr {$twJ+6}]
			set wJ($judge:l) $twJ
			incr twJ 12
			set wJ($judge:r) $twJ
		}
	}
	set wP 20
	set twP [expr $wP*[llength $folder(couples:finale)]+$wP/3]
	set wR 24
	set width [expr $wC+$twJ+$twP+$wR]

	#==== tracé
	set nbBlocks [expr int(double($maxWidth)/($width+$wBetweenBlocks))]
	if {[llength $folder(dances)] == 1} {
		set nbBlocks 1
	}
	set initLeft [expr $gui(t:l)+($maxWidth-$nbBlocks*$width-($nbBlocks-1)*$wBetweenBlocks)/2.0]
	set left $initLeft
	set d 0
	foreach dance $folder(dances) {
		set oldy $y
		# vérifie si cela tient dans la page
		if {$y+$height > $gui(t:max)} {
			set c [print:ps:newpage $f $orientation -header]
			set y $gui(t:y)
			set oldy $y
		}
		#==== header
		$c create rectangle $left $y [expr $left+$width] [expr $y+$hBold] \
				-fill $gui(color:print:dark) -outline black
		$c create text [expr $left+$width/2] [expr $y+$hBold/2+1] -text $dance -font print:bold
		set y [expr $y+$hBold]
		#----
		$c create rectangle $left $y [expr $wC+$left] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
		foreach judge $judges {
			$c create rectangle [expr $left+$wC+$wJ($judge:l)] $y \
					[expr $left+$wC+$wJ($judge:r)] [expr $y+$hNormal] \
					-fill $gui(color:print:light) -outline black
			$c create text [expr $left+$wC+$wJ($judge)] [expr $y+$hNormal/2+1] \
					-text $judge -font print:normal
		}
		#----
		set j 0
		$c create rectangle [expr $left+$wC+$twJ] $y \
				[expr $left+$wC+$twJ+$twP] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
		foreach dummy $folder(couples:finale) {
			$c create text [expr $left+$wC+$twJ+$wP*($j+0.5)] [expr $y+$hNormal/2+1] \
					-text [expr $j+1] -font print:normal
			incr j
		}
		#----
		$c create rectangle [expr $left+$wC+$twJ+$twP] $y [expr $left+$width] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr $left+$wC+$twJ+$twP+$wR/2] [expr $y+$hNormal/2+1] \
				-text $msg(prt:placeAbbrev) -font print:normal
		set y [expr $y+$hNormal]
		#==== résultats pour cette dance
		foreach couple $folder(couples:finale) {
			$c create rectangle $left $y [expr $left+$wC] [expr $y+$hNormal] \
					-fill $gui(color:print:light) -outline black
			$c create text [expr $left+$wC/2] [expr $y+$hNormal/2+1] \
					-text "$couple" -font print:normal
			# vérifie si le couple est exclus
			if {[info exists folder(exclusion:finale:$dance)] &&
					[lsearch $folder(exclusion:finale:$dance) $couple] != -1} {
				set excluded 1
			} else {
				set excluded 0
			}
			#---- notes
			foreach judge $judges {
				set j [lsearch $folder(judges:finale) $judge]
				$c create rectangle [expr $left+$wC+$wJ($judge:l)] $y \
						[expr $left+$wC+$wJ($judge:r)] [expr $y+$hNormal] -outline black
				if {$excluded} {
					set text "-"
				} else {
					set text [lindex $folder(notes:finale:$couple:$dance) $j]
				}
				$c create text [expr $left+$wC+$wJ($judge)] [expr $y+$hNormal/2+1] \
						-text $text -font print:normal
			}
			#---- data
			$c create rectangle [expr $left+$wC+$twJ] $y \
					[expr $left+$wC+$twJ+$twP] [expr $y+$hNormal] -outline black
			set i 0
			foreach dummy $folder(couples:finale) {
				if {! $excluded} {
					print:ps:mark $c 1 \
							[lindex $folder(prt:$dance:mark+:$couple) $i] \
							[lindex $folder(prt:$dance:marktotal:$couple) $i] \
							[expr $left+$wC+$twJ+$wP*($i+0.5)] $y $hNormal
				} else {
					$c create text [expr $left+$wC+$twJ+$wP*($i+0.5)] [expr $y+$hNormal/2+1] \
							-text "-" -font print:normal
				}
				incr i
			}
			#---- place
			$c create rectangle [expr $left+$wC+$twJ+$twP] $y \
					[expr $left+$width] [expr $y+$hNormal] -outline black
			$c create text [expr $left+$wC+$twJ+$twP+$wR/2] [expr $y+$hNormal/2+1] \
					-text [lindex $folder(places:$couple) $d] -font print:bold
			#----
			set y [expr $y+$hNormal]
		}

		# danse suivante, à droite si possible
		set left [expr $left+$width+$wBetweenBlocks]
		if {$left+$width < $gui(t:r)} {
			set y $oldy
		} else {
			set left $initLeft
			set y [expr $y+$hBetweenBlocks]
		}
		incr d
	}

	#==== classement
	if {$left != $initLeft} {
		set y [expr $y+$height+$hBetweenBlocks]
	}
	set y [expr $y+$hBeforeResult]
	#---- taille
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics "print:normal" -linespace])]
	set height [expr $hBold + $hNormal + [llength $folder(couples:finale)]*$hNormal]
	set wC 30
	set wD 30
	set twD [expr $wD*[llength $folder(dances)]]
	set wT 50
	set wR 50
	set wE 164
#	set blockWidth $width
	set width [expr $wC+$twD+$wT+$wR+$wE]
#	if {$width > $blockWidth} {
	set left [expr $gui(t:l)+($maxWidth-$width)/2]
#	}
	# vérifie si cela tient dans la page
	if {$y+$height > $gui(t:max)} {
		set c [print:ps:newpage $f $orientation -header]
		set y $gui(t:y)
	}
	#---- header
	$c create rectangle $left $y [expr $left+$width] [expr $y+$hBold] \
			-fill $gui(color:print:dark) -outline black
	$c create text [expr $left+$width/2] [expr $y+$hBold/2+1] -text $msg(prt:final) \
			-font print:bold
	set y [expr $y+$hBold]
	#----
	$c create rectangle $left $y [expr $left+$wC] [expr $y+$hNormal] \
			-fill $gui(color:print:light) -outline black
	set j 0
	foreach dance $folder(dances) {
		$c create rectangle [expr $left+$wC+$wD*$j] $y \
				[expr $left+$wC+$wD*($j+1)] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr $left+$wC+$wD*($j+0.5)] [expr $y+$hNormal/2+1] \
				-text [firstLetters $dance] -font print:normal
		incr j
	}
	#----
	$c create rectangle [expr $left+$wC+$twD] $y \
			[expr $left+$wC+$twD+$wT] [expr $y+$hNormal] \
			-fill $gui(color:print:light) -outline black
	$c create text [expr $left+$wC+$twD+$wT/2] [expr $y+$hNormal/2+1] \
			-text $msg(prt:tot) -font print:normal
	#----
	$c create rectangle [expr $left+$wC+$twD+$wT] $y \
			[expr $left+$wC+$twD+$wT+$wR] [expr $y+$hNormal] \
			-fill $gui(color:print:light) -outline black
	$c create text [expr $left+$wC+$twD+$wT+$wR/2] [expr $y+$hNormal/2+1] \
			-text $msg(prt:class) -font print:normal
	#----
	$c create rectangle [expr $left+$wC+$twD+$wT+$wR] $y \
			[expr $left+$width] [expr $y+$hNormal] \
			-fill $gui(color:print:light) -outline black
	$c create text [expr $left+$wC+$twD+$wT+$wR+$wE/2] [expr $y+$hNormal/2+1] \
			-text $msg(prt:rules) -font print:normal
	set y [expr $y+$hNormal]
	#---- données
	set rules(10) {}
	set rules(11) {}
	set rules(12) {}
	set rules(13) {}
	set rules(14) {}
	set rules(15) {}
	set rules(16) {}
	set rules(17) {}
	set i 0
	foreach couple $folder(couples:finale) {
		$c create rectangle $left $y [expr $left+$wC] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr $left+$wC/2] [expr $y+$hNormal/2+1] \
				-text "$couple" -font print:normal
		# par danse
		set j 0
		foreach dance $folder(dances) {
			$c create rectangle [expr $left+$wC+$wD*$j] $y \
					[expr $left+$wC+$wD*($j+1)] [expr $y+$hNormal] -outline black
			$c create text [expr $left+$wC+$wD*($j+0.5)] [expr $y+$hNormal/2+1] \
					-text [lindex $folder(places:$couple) $j] -font print:normal
			incr j
		}
		# total
		set tot [lindex $folder(totals) $i]
		if {[expr int($tot)-$tot] == 0} {
			set tot [expr int($tot)]
		}
		$c create rectangle [expr $left+$wC+$twD] $y \
				[expr $left+$wC+$twD+$wT] [expr $y+$hNormal] -outline black
		$c create text [expr $left+$wC+$twD+$wT/2] [expr $y+$hNormal/2+1] \
				-text $tot -font print:normal
		# place
		set place [lindex $folder(result) $i]
		$c create rectangle [expr $left+$wC+$twD+$wT] $y \
				[expr $left+$wC+$twD+$wT+$wR] [expr $y+$hNormal] -outline black
		$c create text [expr $left+$wC+$twD+$wT+$wR/2] [expr $y+$hNormal/2+1] \
				-text $place -font print:bold
		# rule
		set rule [lindex $folder(rules) $i]
		set text ""
		if {$rule >= 10} {
			lappend rules(10) $couple
			set text "   $msg(prt:rule) 10"
		}
		if {$rule >= 11} {
			lappend rules(11) $couple
			append text " & 11"
		}
		if {$rule >= 12} {
			lappend rules(12) $couple
			append text " & 10"
		}
		if {$rule >= 13} {
			lappend rules(13) $couple
			append text " & ..."
		}
		if {$rule >= 14} {
			lappend rules(14) $couple
		}
		if {$rule >= 15} {
			lappend rules(15) $couple
		}
		if {$rule >= 16} {
			lappend rules(16) $couple
		}
		if {$rule >= 17} {
			lappend rules(17) $couple
		}
		$c create rectangle [expr $left+$wC+$twD+$wT+$wR] $y \
				[expr $left+$width] [expr $y+$hNormal] -outline black
		$c create text [expr $left+$wC+$twD+$wT+$wR-2] [expr $y+$hNormal/2+1] \
				-text $text -font print:normal -anchor w
		# suivant
		incr i
		set y [expr $y+$hNormal]
	}

	#==== explications (Règles 10 & 11 & suivantes)
	set already11 0
	if {$gui(pref:print:explain) && [llength $rules(10)]} {
		skating::print:ps:explanation_rules 10 11 1
	}
	# second niveau de 10 & 11
	if {$gui(pref:print:explain) && [llength $rules(12)]} {
		skating::print:ps:explanation_rules 12 13 0
	}
	# troisième niveau de 10 & 11
	if {$gui(pref:print:explain) && [llength $rules(14)]} {
		skating::print:ps:explanation_rules 14 15 0
	}
	# quatrième niveau de 10 & 11
	if {$gui(pref:print:explain) && [llength $rules(16)]} {
		skating::print:ps:explanation_rules 16 17 0
	}

	# signatures
	print:ps:signatures
}

proc skating::print:ps:explanation_rules {rule10 rule11 needheader} {
variable event
variable gui
global msg

upvar y y c c f f folder folder rules rules already11 already11
upvar hBetweenExplain hBetweenExplain hNormal hNormal hBold hBold
upvar judges judges orientation orientation

	# calcul hauteur
	set need11 [llength $rules($rule11)]
	set y [expr $y+$hBetweenExplain]
	if {$needheader} {
		set height [expr $hBold + $hNormal + [llength $rules($rule10)]*$hNormal]
	} else {
		set height [expr [llength $rules($rule10)]*$hNormal + 5]
	}
	# vérifie si cela tient dans la page
	if {$y+$height > $gui(t:max)} {
		set c [print:ps:newpage $f $orientation -header]
		set y $gui(t:y)
		set needheader 1
	}
	#---- taille
	set wC 30
	set wP 30
	set twP [expr $wP*[llength $folder(couples:finale)]+$wP/3]
	if {$need11 || $already11} {
		set width [expr $wC+2*$twP]
		set already11 1
	} else {
		set width [expr $wC+$twP]
	}
	# calcul alignement gauche
	set maxWidth [expr $gui(t:r)-$gui(t:l)]
	set left [expr $gui(t:l)+($maxWidth-$width)/2.0]

	#---- header
	if {$needheader} {
		$c create rectangle $left $y [expr $left+$wC] [expr $y+$hBold] \
				-fill $gui(color:print:dark) -outline black
		$c create rectangle [expr $left+$wC] $y [expr $left+$wC+$twP] [expr $y+$hBold] \
				-fill $gui(color:print:dark) -outline black
		$c create text [expr $left+$wC+$twP/2] [expr $y+$hBold/2+1] \
				-text "$msg(prt:rule) 10" -font print:bold
		if {$need11} {
			$c create rectangle [expr $left+$wC+$twP] $y [expr $left+$width] [expr $y+$hBold] \
					-fill $gui(color:print:dark) -outline black
			set majority [expr int([llength $folder(dances)]*[llength $judges])/2+1]
			$c create text [expr $left+$wC+$twP*3/2] [expr $y+$hBold/2+1] \
					-text "$msg(prt:rule) 11 ($msg(prt:majority): $majority)" -font print:bold
		}
		set y [expr $y+$hBold]
		#----
		set j 0
		$c create rectangle [expr $left] $y \
				[expr $left+$wC] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
		$c create rectangle [expr $left+$wC] $y \
				[expr $left+$wC+$twP] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
		if {$need11} {
			$c create rectangle [expr $left+$wC+$twP] $y \
					[expr $left+$wC+2*$twP] [expr $y+$hNormal] \
					-fill $gui(color:print:light) -outline black
		}
		foreach dummy $folder(couples:finale) {
			$c create text [expr $left+$wC+$wP*($j+0.5)] [expr $y+$hNormal/2+1] \
					-text [expr $j+1] -font print:normal
			if {$need11} {
				$c create text [expr $left+$wC+$twP+$wP*($j+0.5)] [expr $y+$hNormal/2+1] \
						-text [expr $j+1] -font print:normal
			}
			incr j
		}
		set y [expr $y+$hNormal]
	} else {
		incr y 5
	}
	#---- données explicatives
	foreach couple $rules($rule10) {
		$c create rectangle $left $y [expr $left+$wC] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr $left+$wC/2] [expr $y+$hNormal/2+1] \
				-text "$couple" -font print:normal
		$c create rectangle [expr $left+$wC] $y \
				[expr $left+$wC+$twP] [expr $y+$hNormal] -outline black
		if {$need11} {
			$c create rectangle [expr $left+$wC+$twP] $y \
					[expr $left+$wC+2*$twP] [expr $y+$hNormal] -outline black
		}
		set i 0
		foreach dummy $folder(couples:finale) {
			# règle 10
			print:ps:mark $c 0 \
					[lindex $folder(prt:__${rule10}__:mark+:$couple) $i] \
					[lindex $folder(prt:__${rule10}__:marktotal:$couple) $i] \
					[expr $left+$wC+$wP*($i+0.5)] $y $hNormal
			# règle 11
			if {!$need11 || [lsearch $rules($rule11) $couple] == -1} {
				incr i
				continue
			}
			print:ps:mark $c 0 \
					[lindex $folder(prt:__${rule11}__:mark+:$couple) $i] \
					[lindex $folder(prt:__${rule11}__:marktotal:$couple) $i] \
					[expr $left+$wC+$twP+$wP*($i+0.5)] $y $hNormal
			# suivant
			incr i
		}
		set y [expr $y+$hNormal]
	}

	set y [expr $y-$hNormal]
}

#----------------------------------------------------------------------------------------------

proc skating::print:ps:signatures {} {
variable gui
global msg
upvar c c y y hNormal hNormal hBold hBold

	# init
	set hBefore 10 
	set maxWidth [expr $gui(t:r)-$gui(t:l)]

	#==== signatures : Scrutineer & Chairman
	if {$gui(pref:print:sign)} {
		set boxWidth 200
		set boxHeight 100

		set y [expr $y+$hNormal+$hBefore]
		# cherche à caser la boite de signature, quite à la faire plus petite
		while {$boxHeight > 60} {
			set height [expr $hBold + $boxHeight + 5]
			if {$y+$height < $gui(t:max)} {
				break
			}
			incr boxHeight -10
		}
		# vérifie si cela tient sur la page
		if {$y+$height > $gui(t:max)} {
			set c [print:ps:newpage $f $orientation -header]
			set y $gui(t:y)
		} else {
			set y [expr $gui(t:max)-5-$height]
		}
		# tracé
		set width [expr $boxWidth * 2]
		set left [expr $gui(t:l)+($maxWidth-$width)/2]
		#---- labels
		$c create rectangle $left $y [expr $left+$width/2] [expr $y+$hBold] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr $left+$width/4] [expr $y+$hBold/2+1] -text $msg(prt:scrutineer) -font print:bold
		$c create rectangle [expr $left+$width/2] $y [expr $left+$width] [expr $y+$hBold] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr $left+$width*3/4] [expr $y+$hBold/2+1] -text $msg(prt:chairman) -font print:bold
		set y [expr $y+$hBold]
		#---- boite pour la signature
		$c create rectangle $left $y [expr $left+$width/2] [expr $y+$boxHeight] -outline black
		$c create rectangle [expr $left+$width/2] $y [expr $left+$width] [expr $y+$boxHeight] -outline black
	}
}


#=================================================================================================
#
#	Impression d'un round
#
#=================================================================================================

proc skating::print:ps:round {f level} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder


	# ajout une pseudo danse pour le total
	if {![class:round $f $level 2]} {
		set totalOk 0
		set total [repeatStr "? " [llength $folder(couples:$level)]]
		set couples $folder(couples:$level)
	} else {
		set totalOk 1
		if {$gui(pref:print:order:rounds) == 0} {
			set total [lsort -dictionary -index 0 $folder(result:$level)]
			set couples $folder(couples:$level)
		} else {
			set total [lsort -decreasing -integer -index 1 $folder(result:$level)]
			set couples {}
			foreach data $total {
				lappend couples [lindex $data 0]
			}
		}
	}
#TRACE "total = $total / couples = $couples"
	# calcule round suivant
	set next [rounds:next $f $level]

	# première page ...
	set header $folder(round:$level:name)
	set subtitle ""
	if {$totalOk} {
		if {[info exists folder(round:$level:nbSelected)]} {
			set nbPrequalified [nbPrequalified $f $level]
			if {$nbPrequalified > 0} {
				set format $msg(prt:selectedPrequalif)
			} else {
				set format $msg(prt:selected)
			}
			set subtitle [format $format \
								  $folder(round:$level:nbSelected) \
								  [expr {$folder(round:$level:nb)-$nbPrequalified}] \
								  $nbPrequalified \
								  $folder(round:$next:name)]
		}
	}
	if {$gui(v:subten)} {
		set header "[lindex $folder(dances) 0] - $header"
	}
	set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header $subtitle]
	set y $gui(t:y)

	# commentaires
	if {[info exists folder(comments:$level)] && $folder(comments:$level)!=""} {
		$c create text $gui(t:l) $y -width [expr $gui(t:r)-$gui(t:l)] -anchor nw \
					-text [string trim $folder(comments:$level)] \
					-tags "comment" -font print:normal
		set y [expr [lindex [$c bbox comment] 3]+$gui(pref:print:small:skipY)]
	}

	# les juges
	set judges [lsort -command skating::event:judges:sort $folder(judges:$level)]

	#--------------------
	# calcule les tailles
	set wC 30
	set wD 0
	foreach judge $judges {
		if {[string length $judge] > 1} {
			set wJ($judge) [expr {$wD+12}]
			set wJ($judge:l) $wD
			incr wD 24
			set wJ($judge:r) $wD
		} else {
			set wJ($judge) [expr {$wD+6}]
			set wJ($judge:l) $wD
			incr wD 12
			set wJ($judge:r) $wD
		}
	}
	set wT 40
	set wK 35
	if {$level == "qualif"} {
		set wK 0
	}
	set twR [expr {$wT+$wK+$wC}]
	set maxWidth [expr $gui(t:r)-$gui(t:l)]
	set n [llength $folder(dances)]
	if {$n > 5 && $gui(pref:print:orientation) == "-portrait"} {
		set n 5
	}
	if {$n > 10 && $gui(pref:print:orientation) == "-landscape"} {
		set n 10
	}
	set wN [expr {$maxWidth - ($twR + $wD*$n + $wC)}]
	while {$wN < 100} {
		incr n -1
		set wN [expr {$maxWidth - ($twR + $wD*$n + $wC)}]
	}
	if {$wN > 350} {
		set wN 350
	}
#puts "wN = $wN / $maxWidth - ($twR+$wD*$n+$wC)"

	set hNormal [expr int($gui(prt:spacing:table)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]


	#------------------
	# imprime les juges (si besoin)
	if {$gui(pref:print:names:judges)} {
		if {$gui(pref:print:useSmallFont)} {
			set font print:small
			set fontBold print:smallbold
		} else {
			set font print:normal
			set fontBold print:bold
		}
		print:ps:judges $gui(pref:print:orientation) $judges $font $fontBold \
					0 [expr {$maxWidth/2}] left
		set y [expr {$y+$gui(pref:print:medium:skipY)}]
	}

	# init
	if {([string first "." $level]==-1) && $folder(round:$level:split)} {
		set isSplit 1
	} else {
		set isSplit 0
	}

	# imprime les données
	set nbDances [llength $folder(dances)]
	set nbDone 0
	set needPageBreak 0
	set donePageBreak 0
	while {$nbDone < $nbDances} {
		# nouvelle page si nécessaire
		if {$needPageBreak} {
			set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
			set y $gui(t:y)
			set donePageBreak 1
		}
		# calcule les danses à afficher
		set width [expr {$wC+$wN}]
		set dances {}
		set oldDone $nbDone
		for {} {$nbDone < $nbDances} {incr nbDone} {
			if {$width + $wD <= $maxWidth} {
				lappend dances [lindex $folder(dances) $nbDone]
				incr width $wD
			} else {
				# test si on peut améliorer l'impression en groupant les dances par deux
#puts "          ???? [llength $dances] > [expr $nbDances/2]"
				if {[llength $dances] > $nbDances/2} {
					set dances [lrange $folder(dances) $oldDone [expr {$oldDone+$nbDances/2-1}]]
					set nbDone [expr {$oldDone+$nbDances/2}]
					set width $wC
					foreach d $dances {
						incr width $wD
					}
#					if {$nbDone == $nbDances} {
						set wN [expr {$maxWidth - $width-$twR}]
#					} else {
#						set wN [expr {$maxWidth - $width}]
#					}
				}
#puts "          ====> $dances"
				break
			}
		}
		set result 0
		if {$nbDone == $nbDances} {
			# vérifie plus de place pour le total, enlève derniére danse
			# pour afficher avec le résultat
			if {$width + $twR > $maxWidth} {
				set dances [lrange $dances 0 [expr [llength $dances]-2]]
				incr nbDone -1
			} else {
				set result 1
			}
		}

		#---- imprime tous les couples pour les danses (et/ou total)
		# header
		set y [expr $y+[print:ps:round:header]]
		set i 0
		foreach couple $couples {
			# page suivante si nécessaire
			if {$y+$hNormal > $gui(t:max)} {
				set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
				set y $gui(t:y)
				set y [expr $y+[print:ps:round:header]]
				set donePageBreak 1
			}
			# regarde si pré-qualifié
			set preQualif [isPrequalified $f $couple $level]

			#--------
			# couple
			$c create rectangle $gui(t:l) $y [expr $gui(t:l)+$wC] [expr $y+$hNormal] \
					-fill $gui(color:print:light) -outline black
			$c create text [expr $gui(t:l)+$wC/2] [expr $y+$hNormal/2+1] \
					-text $couple -font print:normal
			set left [expr {$gui(t:l)+$wC}]
			# nom
			$c create rectangle $left $y [expr $left+$wN] [expr $y+$hNormal]
			print:ps:textInBox $c [couple:name $f $couple] \
					$left [expr $left+$wN] [expr $y+$hNormal/2+1] print:normal
			incr left $wN
			# danses
			foreach dance $dances {
				$c create rectangle $left $y [expr $left+$wD] [expr $y+$hNormal]
				# juges
				if {[info exists folder(notes:$level:$couple:$dance)]} {
					set skip 0
					if {[lsearch $folder(dances:$level) $dance] == -1} {
						set skip 1
					}
#puts "ps:round >>>> $dance / $judges"
					foreach judge $judges {
						set j [lsearch $folder(judges:$level) $judge]
						if {[lindex $folder(notes:$level:$couple:$dance) $j]} {
							if {$preQualif} {
								set text "+"
							} elseif {$gui(pref:print:useLetters)} {
								set text $judge
							} else {
								set text "X"
							}
						} elseif {$skip} {
							set text "-"
						} else {
							set text "."
						}
						$c create text [expr $left+$wJ($judge)] [expr $y+$hNormal/2+1] \
								-text $text -font print:normal
					}
				}
				# suivante
				set left [expr {$left+$wD}]
			}
			# resultat & repris
			if {$result} {
				$c create rectangle $left $y [expr {$left+$wT}] [expr {$y+$hNormal}]
				if {$preQualif} {
					$c create text [expr {$left+$wT/2}] [expr {$y+$hNormal/2+1}] \
									-text "+" -font print:normal
				} else {
					$c create text [expr {$left+$wT/2}] [expr {$y+$hNormal/2+1}] \
									-text [lindex [lindex $total $i] 1] -font print:normal
				}
				$c create rectangle [expr {$left+$wT}] $y [expr {$left+$twR}] [expr {$y+$hNormal}]
				set color {}
				if {$isSplit && [info exists folder(couples:$level.2)] && $wK>0} {
					# si split, alors  on est en éliminatoire
					set ok [expr {[lsearch $folder(couples:$level.2) $couple] == -1}]
					if {$preQualif} {
						$c create text [expr {$left+$wT+$wK/2}] [expr {$y+$hNormal/2+1}] \
										-text "Pre" -font print:normal
						set color $gui(color:print:light)
					} elseif {$ok} {
						$c create text [expr {$left+$wT+$wK/2}] [expr {$y+$hNormal/2+1}] \
										-text $msg(prt:yes) -font print:normal
						set color $gui(color:print:light)
					} else {
						$c create text [expr {$left+$wT+$wK/2}] [expr {$y+$hNormal/2+1}] \
										-text "R" -font print:normal
					}
				} elseif {[info exists folder(couples:$next)] && $wK>0} {
					# pas de split : les couples pour le round suivant doivent exister
					set ok [expr {[lsearch $folder(couples:$next) $couple] != -1}]
					if {$ok} {
						$c create text [expr {$left+$wT+$wK/2}] [expr {$y+$hNormal/2+1}] \
										-text $msg(prt:yes) -font print:normal
						set color $gui(color:print:light)
					}
				}
				# rappel numéro du couple
				$c create rectangle [expr {$left+$wT+$wK}] $y [expr {$left+$wT+$wK+$wC}] [expr {$y+$hNormal}] \
						-fill $color -outline black
				$c create text [expr {$left+$wT+$wK+$wC/2}] [expr {$y+$hNormal/2+1}] \
						-text $couple -font print:normal
			}
			# suivant
			set y [expr {$y+$hNormal}]
			incr i
		}

		# si il y a beaucoup de couples, générer des pages séparées
		# sinon essayer de tout faire tenir sur une page
		incr y $gui(pref:print:medium:skipY)
		if {$y+$hBold+(1+[llength $couples])*$hNormal > $gui(t:max) || $donePageBreak} {
			set needPageBreak 1
		}
	}

	# signatures
	print:ps:signatures
}

proc skating::print:ps:round:header {} {
global msg
variable gui
upvar c c f f level level dances dances result result
upvar wC wC wN wN wJ wJ wD wD twR twR wT wT wK wK
upvar y y hNormal hNormal hBold hBold
variable $f
upvar 0 $f folder


	# couple
	$c create rectangle $gui(t:l) $y [expr {$gui(t:l)+$wC}] [expr {$y+$hBold}] \
			-fill $gui(color:print:dark) -outline black
	$c create rectangle $gui(t:l) [expr {$y+$hBold}] \
			[expr {$gui(t:l)+$wC}] [expr {$y+$hBold+$hNormal}] \
			-fill $gui(color:print:light) -outline black
	set left [expr {$gui(t:l)+$wC}]
	# name
	$c create rectangle $left $y [expr {$left+$wN}] [expr {$y+$hBold}] \
			-fill $gui(color:print:dark) -outline black
	$c create rectangle $left [expr {$y+$hBold}] [expr {$left+$wN}] [expr {$y+$hBold+$hNormal}] \
			-fill $gui(color:print:light) -outline black
	$c create text [expr {$left+$wN/2}] [expr {$y+$hBold/2+1}] -text $msg(name) -font print:bold
	# danses
	incr left $wN
	foreach dance $dances {
		# nom
		$c create rectangle $left $y [expr {$left+$wD}] [expr {$y+$hBold}] \
				-fill $gui(color:print:dark) -outline black
		$c create text [expr {$left+$wD/2}] [expr {$y+$hBold/2+1}] -font print:bold \
				-text [firstLetters $dance]
		# juges
		foreach judge [lsort -command skating::event:judges:sort $folder(judges:$level)] {
			$c create rectangle [expr {$left+$wJ($judge:l)}] [expr {$y+$hBold}] \
					[expr {$left+$wJ($judge:r)}] [expr {$y+$hBold+$hNormal}] \
					-fill $gui(color:print:light) -outline black
			$c create text [expr {$left+$wJ($judge)}] [expr {$y+$hBold+$hNormal/2+1}] \
					-text $judge -font print:normal
		}
		# suivante
		set left [expr {$left+$wD}]
	}
	# resultat & repris
	if {$result} {
		#---- résultat
		$c create rectangle $left $y [expr {$left+$twR}] [expr {$y+$hBold}] \
				-fill $gui(color:print:dark) -outline black
		$c create text [expr {$left+$twR/2}] [expr {$y+$hBold/2+1}] \
				-text $msg(prt:result) -font print:bold
		#---- total
		$c create rectangle $left [expr {$y+$hBold}] \
				[expr {$left+$wT}] [expr {$y+$hBold+$hNormal}] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr {$left+$wT/2}] [expr {$y+$hBold+$hNormal/2+1}] \
				-text $msg(prt:total) -font print:normal
		#---- repris ?
		if {$wK > 0} {
			$c create rectangle [expr {$left+$wT}] [expr {$y+$hBold}] \
					[expr {$left+$twR}] [expr {$y+$hBold+$hNormal}] \
					-fill $gui(color:print:light) -outline black
			$c create text [expr {$left+$wT+$wK/2}] [expr {$y+$hBold+$hNormal/2+1}] \
					-text $msg(prt:keepLabel) -font print:normal
		}
		#---- rappel numéro du couple
		$c create rectangle [expr {$left+$wT+$wK}] [expr {$y+$hBold}] \
				[expr {$left+$twR}] [expr {$y+$hBold+$hNormal}] \
				-fill $gui(color:print:light) -outline black
	}

	return [expr {$hBold+$hNormal}]
}



#=================================================================================================
#
#	Impression les données relatives à un événement
#	Si withResult est défini, affiche un résumé des résultats
#
#=================================================================================================

proc skating::print:ps:event {withResult {subtitle {}}} {
global msg
variable event
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder


	set f $gui(v:folder)

	# première page ...
	set header ""
	if {$withResult && $gui(v:subten)} {
		set header "[lindex $folder(dances) 0]"
	} else {
		set header $subtitle
	}
	set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
	set y $gui(t:y)

	# calcule les tailles
	set maxWidth [expr $gui(t:r)-$gui(t:l)]
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics "print:normal" \
					-linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]

	# commentaires
	if {$gui(pref:print:comment) && [info exists event(general:comment)]
			&& $event(general:comment) != ""} {
		$c create text $gui(t:l) $y -width [expr $gui(t:r)-$gui(t:l)] -anchor nw \
					-text $event(general:comment) -tags "comment" -font print:normal
		set y [expr [lindex [$c bbox comment] 3]+$gui(pref:print:big:skipY)]
	} elseif {!$gui(v:subten)} {
		set y [expr $y+$gui(pref:print:medium:skipY)]
	}

	#--------------------------------
	# imprime le résumé des résultats
	if {$withResult && $folder(mode) != "qualif"} {
		set results [class:folder $gui(v:folder)]
		#---- classement
		set hNormal [expr int($gui(prt:spacing:big)*[font metrics "print:normal" \
							-linespace])]
		set hBold [expr int($gui(prt:spacing:big)*[font metrics "print:bold" \
							-linespace])]
		if {[info exists results]} {
			# titre
			set wP 40
			set wC 40
			set wS 140
			set wB 75
			set wN [expr {0.9*($maxWidth-$wP-$wC-$wS-$wB)}]
			set left [expr $gui(t:l) + ($maxWidth-$wP-$wC-$wN-$wS-$wB)/2]
			set right [expr $gui(t:r) - ($maxWidth-$wP-$wC-$wN-$wS-$wB)/2]
			$c create rectangle $left $y $right [expr $y+$hBold] \
					-fill $gui(color:print:dark) -outline black
			$c create text [expr ($left+$right)/2] [expr $y+$hBold/2+1] \
					-text $msg(prt:final) -font print:bold
			set y [expr $y+$hBold]
			# les couples & les places & leurs noms
			set i 1
			foreach data $results {
				# page suivante si nécessaire
				if {$y+$hNormal > $gui(t:max)} {
					set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
					set y $gui(t:y)
				}
				# données
				set couple [lindex $data 0]
				set min [lindex $data 1]
				set round [lindex $data 2]
				set max [lindex $data 3]
				set place [lindex $data 4]
				if {$i > [llength $folder(couples:finale)]} {
					set font print:normal
					set hNormal [expr int($gui(prt:spacing:normal)*[font metrics "print:normal" -linespace])]
				} else {
					set font print:bold
					set hNormal [expr int($gui(prt:spacing:big)*[font metrics "print:normal" -linespace])]
				}
				# place
				if {$gui(pref:print:placeAverage)} {
					set text $place
				} elseif {$min != $max} {
					set text "$min-$max"
				} else {
					set text $min
				}
				$c create rectangle $left $y [expr $left+$wP] [expr $y+$hNormal] \
						-fill $gui(color:print:light) -outline black
				$c create text [expr $left+$wP/2] [expr $y+$hNormal/2+1] \
						-text $text -font $font
				# couple
				$c create rectangle [expr $left+$wP] $y [expr $left+$wP+$wC] \
						[expr $y+$hNormal] -outline black
				$c create text [expr $left+$wP+$wC/2] [expr $y+$hNormal/2+1] \
						-text $couple -font $font
				# nom
				$c create rectangle [expr $left+$wP+$wC] $y [expr $left+$wP+$wC+$wN] [expr $y+$hNormal] \
						-outline black
				print:ps:textInBox $c [couple:name $f $couple] \
						[expr $left+$wP+$wC] [expr $left+$wP+$wC+$wN] [expr $y+$hNormal/2+1] print:normal
				# école/club
				$c create rectangle [expr $left+$wP+$wC+$wN] $y [expr $left+$wP+$wC+$wN+$wS] [expr $y+$hNormal] \
						-outline black
				print:ps:textInBox $c [couple:school $f $couple] \
						[expr $left+$wP+$wC+$wN] [expr $left+$wP+$wC+$wN+$wS] [expr $y+$hNormal/2+1] print:normal
				# meilleur round
				$c create rectangle [expr $left+$wP+$wC+$wN+$wS] $y $right [expr $y+$hNormal] \
						-outline black
				print:ps:textInBox $c $folder(round:$round:name) \
						[expr $left+$wP+$wC+$wN+$wS] $right [expr $y+$hNormal/2+1] print:normal
				# suivant
				set y [expr $y+$hNormal]
				if {$i == [llength $folder(couples:finale)]} {
					incr y 5
				}
				incr i
			}
		} else {
			# par défaut (par de classement valide, affiche la liste des couples)
			print:ps:couples $f $folder(couples:all) print:normal print:bold 0 $maxWidth center
		}
  		set y [expr $y+$gui(pref:print:small:skipY)]
	}

	#--------------------
	# imprime les juges
	if {$gui(pref:print:names:judges)} {
		set y [expr $y+$gui(pref:print:small:skipY)]
		# page suivante si nécessaire
		if {$y+$hNormal > $gui(t:max)} {
			set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
			set y $gui(t:y)
		}
		# liste de juges locale ou globale
		if {$f != ""} {
			set judges {-}
		} else {
			set judges {}
			set y [expr $y-$gui(pref:print:small:skipY)]
		}
		print:ps:judges $gui(pref:print:orientation) $judges print:normal print:bold \
					0 $maxWidth center
	}

	#--------------------
	# imprime les couples
	if {$gui(pref:print:names:couples)} {
		set y [expr $y+$gui(pref:print:small:skipY)]
		# liste des couples
		if {[info exists folder(couples:all)]} {
			set couples [lsort $folder(couples:all)]
		} else {
			set couples [lsort -real $event(couples)]
		}
		print:ps:couples $f $couples print:normal print:bold 0 $maxWidth center
	}

	global lastY lastC
	set lastY $y
	set lastC $c
}


#=================================================================================================
#
#	Impression d'une liste de juges
#
#=================================================================================================

proc skating::print:ps:judges {orientation judges_set fontNormal fontBold startLeft maxWidth justify {scale 0.975} {split 0}} {
global msg
variable event
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder

# variable liées pour impression
upvar c c y y hNormal hNormal hBold hBold f f nextc nextc

#puts "skating::print:ps:judges {$orientation '$judges_set' $fontNormal $fontBold $startLeft $maxWidth $justify $scale}"

	#--------------------
	# base de maxWidth en A4 = 560
	set wJ [expr $maxWidth*0.075]
	if {$wJ > 50} { set wJ 50 }
	if {$wJ < 30} {	set wJ 30 }
	set wN [expr $scale*$maxWidth-$wJ]
	set wR 28
	set tw [expr $wJ+$wN]
	if {$justify == "center"} {
		set left [expr $gui(t:l)+$startLeft+($maxWidth-$tw)/2]
	} elseif {$justify == "left"} {
		set left [expr $gui(t:l)+$startLeft]
	} else {
		set left [expr $gui(t:l)+$startLeft+$maxWidth-$tw]
	}

	# page "event" - on doit construire la liste des juges utilisés & afficher quel round est jugé
	set extended 0
	if {$judges_set == "-" || $judges_set == "1" || $judges_set == "2"} {
		if {$judges_set != "-"} {
			set split $judges_set
		}
		set judges_set {}
		set extended 1
		foreach level $folder(levels) {
			foreach j $folder(judges:$level) {
				lappend judges_set $j
			}
		}
	}

	set headerDone 0

	# affiche les juges
	if {$judges_set == ""} {
		set judges $event(judges)
	} else {
		set judges [lsort -unique -command skating::event:judges:sort $judges_set]
	}
	if {$split} {
		set start [expr {([llength $judges]+1)*($split-1)/2}]
		set end   [expr {([llength $judges]+1)*$split/2 -1}]
		set judges  [lrange $judges $start $end]
	}

	set index 1
#puts "judges = $judges"
	foreach judge $judges {
		# test si tient dans la page, sinon nouvelle page
		if {       ( !$headerDone && ($y+$hBold+$hNormal > $gui(t:max)) )
				|| (  $headerDone && ($y+$hNormal > $gui(t:max)) ) } {
			if {$split == 2 && $nextc != ""} {
				set c $nextc
			} else {
				set c [print:ps:newpage $gui(v:folder) $orientation -header]
			}
			set y $gui(t:y)
			set headerDone 0
		}
		# header
		if {!$headerDone} {
			$c create rectangle $left $y [expr $left+$tw] [expr $y+$hBold] \
					-fill $gui(color:print:dark) -outline black
			if {$extended} {
				# construit la liste des rounds (du plus grand vers la finale = inversion de la liste)
				set levels [reverse $folder(levels)]
				# do it
				set i 0
				foreach level $levels {
					$c create rectangle [expr $left+$tw-$wR*$i] $y \
							[expr $left+$tw-$wR*($i+1)] [expr $y+$hBold] \
							-fill $gui(color:print:dark) -outline black
					$c create text [expr $left+$tw-$wR*($i+0.5)] [expr $y+$hBold/2+1] \
							-text [rounds:getShortName $f $level] -font $fontBold
					incr i
				}
				set right [expr $left+$tw-$wR*[llength $folder(levels)]]
				$c create text [expr $left+($tw-$wR*[llength $folder(levels)])/2] [expr $y+$hBold/2+1] \
						-text $msg(prt:judges) -font $fontBold
			} else {
				$c create text [expr $left+$tw/2] [expr $y+$hBold/2+1] \
						-text $msg(prt:judges) -font $fontBold
				set right [expr $left+$tw]
			}
			set y [expr $y+$hBold]
			set headerDone 1
		}
		# juge
		$c create rectangle [expr $left] $y [expr $left+$wJ] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr $left+$wJ/2] [expr $y+$hNormal/2+1] \
				-text $judge -font $fontNormal
		# nom
		$c create rectangle [expr $left+$wJ] $y [expr $left+$tw] [expr $y+$hNormal] \
				-outline black
		print:ps:textInBox $c $event(name:[join $judge ":"]) \
				[expr $left+$wJ] $right [expr $y+$hNormal/2+1] $fontNormal
		# si étendu
		if {$extended} {
			set i 0
			foreach level $levels {
				$c create rectangle [expr $left+$tw-$wR*$i] $y \
						[expr $left+$tw-$wR*($i+1)] [expr $y+$hNormal] -outline black
				if {[lsearch $folder(judges:$level) $judge] != -1} {
					$c create text [expr $left+$tw-$wR*($i+0.5)] [expr $y+$hBold/2+1] \
							-text "X" -font $fontNormal
				}
				incr i
			}
		}
		# suivant
		set y [expr $y+$hNormal]
		incr index
	}
}

#=================================================================================================
#
#	Impression d'une liste de couples
#
#=================================================================================================

proc skating::print:ps:couples {f couples fontNormal fontBold startLeft maxWidth justify {withPlaces 0}} {
global msg
variable gui

# variable liées pour impression
upvar c c y y hNormal hNormal hBold hBold

	#--------------------
	# base de maxWidth en A4
	if {$withPlaces} {
		set wC [expr $maxWidth*0.07]
		set wN [expr $maxWidth*0.60]
		set wS [expr $maxWidth*0.28]
		set wP [expr $maxWidth*0.05]
		set tw [expr $wC+$wN+$wS+$wP]
	} else {
		set wC [expr $maxWidth*0.07]
		set wN [expr $maxWidth*0.55]
		set wS [expr $maxWidth*0.38]
		if {$wC > 4*$hNormal} {
			set rest [expr {$wC-4*$hNormal}]
			set wC [expr {4*$hNormal}]
			set wN [expr {$wN+$rest}]
		}
		set tw [expr $wC+$wN+$wS]
	}
	if {$justify == "center"} {
		set left [expr $gui(t:l)+$startLeft+($maxWidth-$tw)/2]
	} elseif {$justify == "left"} {
		set left [expr $gui(t:l)+$startLeft]
	} else {
		set left [expr $gui(t:l)+$startLeft+$maxWidth-$tw]
	}
	# header
	$c create rectangle $left $y [expr $left+$tw] [expr $y+$hBold] \
			-fill $gui(color:print:dark) -outline black
	$c create text [expr $left+$tw/2] [expr $y+$hBold/2+1] \
			-text $msg(prt:couples) -font $fontBold
	set y [expr $y+$hBold]

	# affichage
	set place 1
	set oldleft $left
	foreach couple $couples {
		set left $oldleft
		# page suivante si nécessaire
		if {$y+$hNormal > $gui(t:max)} {
			set c [print:ps:newpage $f $gui(pref:print:orientation) -header]
			set y $gui(t:y)

			$c create rectangle $left $y [expr $left+$tw] [expr $y+$hBold] \
					-fill $gui(color:print:dark) -outline black
			$c create text [expr $left+$tw/2] [expr $y+$hBold/2+1] \
					-text $msg(prt:couples) -font $fontBold
			set y [expr $y+$hBold]
		}
		# place
		if {$withPlaces} {
			$c create rectangle $left $y [expr {$left+$wP}] [expr {$y+$hNormal}] \
					-outline black
			if {$place <= $withPlaces} {
				$c create text [expr {$left+$wP/2}] [expr {$y+$hNormal/2+1}] \
						-text $place -font $fontBold
			}
			set left [expr {$left+$wP}]
		}
		# couple
		$c create rectangle $left $y [expr $left+$wC] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr $left+$wC/2] [expr $y+$hNormal/2+1] \
				-text $couple -font $fontNormal
		# nom
		$c create rectangle [expr $left+$wC] $y [expr $left+$wC+$wN] [expr $y+$hNormal] \
				-outline black
		print:ps:textInBox $c [couple:name $f $couple] \
				[expr $left+$wC] [expr $left+$wC+$wN] [expr $y+$hNormal/2+1] $fontNormal
		# école
		$c create rectangle [expr $left+$wC+$wN] $y [expr $left+$wC+$wN+$wS] [expr $y+$hNormal] \
				-outline black
		print:ps:textInBox $c [couple:school $f $couple] \
				[expr $left+$wC+$wN] [expr $left+$wC+$wN+$wS] [expr $y+$hNormal/2+1] $fontNormal
		# suivant
		set y [expr $y+$hNormal]
		incr place
	}
}

#=================================================================================================
#
#	Impression d'une liste de danses
#
#=================================================================================================

proc skating::print:ps:dances {f level fontNormal fontBold startLeft maxWidth justify {scale 0.975} {split 0}} {
global msg
variable event
variable gui
variable $f
upvar 0 $f folder

# variable liées pour impression
upvar c c y y hNormal hNormal hBold hBold nextc nextc

#TRACEF

	set family [font configure print:normal -family]
	set size [font configure print:normal -size]
	set fontItalic [list $family $size italic]

	#--------------------
	# base de maxWidth en A4 = 560
	set tw [expr {$maxWidth*$scale}]
	if {$justify == "center"} {
		set left [expr $gui(t:l)+$startLeft+($maxWidth-$tw)/2]
	} elseif {$justify == "left"} {
		set left [expr $gui(t:l)+$startLeft]
	} else {
		set left [expr $gui(t:l)+$startLeft+$maxWidth-$tw]
	}

	# liste des danses
	set dances $folder(dances)
	if {$split} {
		set start [expr {([llength $dances]+1)*($split-1)/2}]
		set end   [expr {([llength $dances]+1)*$split/2 -1}]
		set dances  [lrange $dances $start $end]
	}

	# header
	set headerDone 0

	# affichage
	foreach dance $dances {
		# test si tient dans la page, sinon nouvelle page
		if {       ( !$headerDone && ($y+$hBold+$hNormal > $gui(t:max)) )
				|| (  $headerDone && ($y+$hNormal > $gui(t:max)) ) } {
			if {$nextc != ""} {
				set c $nextc
			} else {
				set c [print:ps:newpage $f $gui(pref:print:orientation) -header]
			}
			set y $gui(t:y)
		}
		# header
		if {!$headerDone} {
			$c create rectangle $left $y [expr $left+$tw] [expr $y+$hBold] \
					-fill $gui(color:print:dark) -outline black
			$c create text [expr $left+$tw/2] [expr $y+$hBold/2+1] \
					-text $msg(prt:dances) -font $fontBold
			set y [expr $y+$hBold]
			set headerDone 1
		}
		# danse
		set font $fontNormal
		if {$level != "finale" && [lsearch $folder(dances:$level) $dance] == -1} {
			append dance " ($msg(prt:skipped))"
			set font $fontItalic
		}
		$c create rectangle $left $y [expr $left+$tw] [expr $y+$hNormal] \
				-outline black
		print:ps:textInBox $c $dance $left [expr $left+$tw] [expr $y+$hNormal/2+1] $font
		# suivant
		set y [expr $y+$hNormal]
	}
}


#=================================================================================================
#
#	Impression d'un état récapitulatif
#
#=================================================================================================

proc skating::print:ps:summary {f order {header ""}} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder

#TRACEF

	# première page ...
	if {$header == ""} {
		set header $msg(prt:summary)
	}
	set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
	set y $gui(t:y)

	#-----------------
	# liste des danses
	set allDances $folder(dances)
	set folder(dances:finale) $folder(dances)
	# effectue le classement, récupère les données
	if {![info exists folder(couples:finale)]} {
		return
	}
	set results [class:folder $f]
#TRACE "results = $results"
	if {$order == "couple"} {
		set results [lsort -integer -index 0 $results]
	}

	#---------------------------
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

	#------------------
	# taille des fontes
	set hSmall [expr int([font metrics "print:normal" -linespace])]
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]
	set hBig [expr int($gui(prt:spacing:bold)*[font metrics "print:big" -linespace])]
	# taille initiales
	set wC [expr {int(1.55*$hBig)}]
	results:computeJudgesSizes $folder(dances) 12 24
	set wL 30
	set wR 22
	set twJ 0
	foreach d $folder(dances) {
		incr twJ [expr {$wJ($d)+$wR}]
	}
	set wT 35
	set wP [expr {int(1.1*$wC)}]
	if {[llength $results] > 10} {
		set wP [expr {int(1.6*$wC)}]
	}
	if {[llength $results] > 100} {
		set wP [expr {int(2.1*$wC)}]
	}
	set width [expr $wC+$wL+$twJ+$wP]
	set maxWidth [expr {$gui(t:r)-$gui(t:l)}]
	set wN [expr {$maxWidth - $width - $wT}]
#puts ">>>> required wN = $wN / $width, expr $wC+$wL+$twJ+$wP"
	if {$wN < 50} {
		set wN 50
	}
	set startX $gui(t:l)

	#---------------------------------------------------
	# imprime liste des juges sur page séparée si besoin
	if {$gui(pref:print:judgesInSummary) == 0} {
		if {$gui(pref:print:orientation) == "-landscape"} {
			set size [expr {$maxWidth/2}]
		} else {
			set size $maxWidth
		}
		print:ps:judges $gui(pref:print:orientation) "-" print:normal print:bold 0 $size left 1.0
		set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
		set y $gui(t:y)
	}

	#--------------------
	# imprime les données
	set nbDances [llength $allDances]
	set nbDone 0
	set needPageBreak 0
	set donePageBreak 0
	set count 0
	while {$nbDone < $nbDances} {
		# nouvelle page si nécessaire
		if {$needPageBreak} {
			set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
			set y $gui(t:y)
			set donePageBreak 1
		}
		# calcule les danses à afficher
		set width [expr $wC+$wN+$wL + $wP]
		set dances {}
#puts ">>>> compute dances '$allDances', $ii / $nbDone of $nbDances / $width , expr $wC+$wN+$wL + $wP / $maxWidth"
		set oldDone $nbDone
		for {} {$nbDone < $nbDances} {incr nbDone} {
			set dance [lindex $folder(dances) $nbDone]
			if {$nbDone == $nbDances-1} {
#puts "     adding wT = $wT / $width"
				incr width $wT
			}
#puts "     dance = $dance / $width + ($wJ($dance)+$wR) <[expr $width + ($wJ($dance)+$wR)]> <= $maxWidth"
			if {$width + ($wJ($dance)+$wR) <= $maxWidth} {
				lappend dances $dance
				incr width [expr {$wJ($dance)+$wR}]
			} else {
#puts "splitting ---> $dance / $width + ($wJ($dance)+$wR) [expr $width + ($wJ($dance)+$wR)] <= $maxWidth"
				# test si on peut améliorer l'impression en groupant les dances par deux
#puts "          ???? [llength $dances] > [expr $nbDances/2]"
				if {[llength $dances] > ($nbDances+1)/2} {
#puts "          OK for split"
					set dances [lrange $folder(dances) $oldDone [expr {$oldDone+$nbDances/2-1}]]
					set nbDone [expr {$oldDone+$nbDances/2}]
					set width [expr $wC+$wL + $wP]
					if {$nbDone == $nbDances-1} {
						incr width $wT
					}
					foreach d $dances {
						incr width [expr {$wJ($dance)+$wR}]
					}
					set wN [expr {$maxWidth - $width}]
				}
#puts "          ====> $dances"
				break
			}
		}

		#---- imprime le détail des résultats
		# header
#puts ">>>> $f / '$dances'"
		set y [expr $y+[print:ps:summary:header $y]]
#puts ">>>> $dances / $results"
		foreach item $results {
			set couple [lindex $item 0]
			set min [lindex $item 1]
			set round [lindex $item 2]
			set max [lindex $item 3]
			set place [lindex $item 4]
			# les rounds dans l'ordre à imprimer
			set rounds [reverse [lrange $folder(levels) 0 [lsearch $folder(levels) $round]]]
			# nombre de lignes à imprimer
			set nb [expr [lsearch $folder(levels) $round]+1]
			foreach r $rounds {
				if {[lsearch $folder(couples:$r) $couple] == -1} {
					incr nb -1
				}
			}
			if {$nb < 2} {
				set nb 2
			}
			set h [expr {$nb*$hSmall}]
			# page suivante si nécessaire
			if {$y+$h > $gui(t:max)} {
				set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
				set y $gui(t:y)
				set y [expr $y+[print:ps:summary:header $y]]
				set donePageBreak 1
			}
			#--------
			# couple
			$c create rectangle $gui(t:l) $y [expr $gui(t:l)+$wC] [expr $y+$h] \
					-fill $gui(color:print:light) -outline black
			$c create text [expr $gui(t:l)+$wC/2] [expr $y+$h/2+1] \
					-text $couple -font print:big
			set left [expr $gui(t:l)+$wC]
			# nom
			$c create rectangle $left $y [expr $left+$wN] [expr $y+$h]
			print:ps:textInBox $c [couple:name $f $couple] \
					$left [expr $left+$wN] [expr $y+$hSmall/2+1] print:bold
			print:ps:textInBox $c [couple:school $f $couple] \
					$left [expr $left+$wN] [expr $y+$hSmall*3/2+1] print:normal
			incr left $wN
			# rounds
			$c create rectangle $left $y [expr $left+$wL] [expr $y+$h]
			set yy [expr $y+$hSmall/2+1]
			foreach r $rounds {
				if {[lsearch $folder(couples:$r) $couple] == -1} {
					continue
				}
				$c create text [expr $left+$wL/2] $yy \
							-text $msg(round:short:$r) -font print:normal
				incr yy $hSmall
			}
			incr left $wL
			# danses
			foreach r $rounds {
				set total($r) 0
			}
			set x $left
			set count2 $count
			foreach d $dances {
				# cadre
				$c create rectangle $x $y [expr $x+$wJ($d)+$wR] [expr $y+($nb*$hSmall)]
				set yy $y
				# pour chaque round
				foreach r $rounds {
#TRACE "==== $couple / $d / $r"
					set preQualif [isPrequalified $f $couple $r]
					# si le couple n'a pas dansé le round (repéchage)
					if {[lsearch $folder(couples:$r) $couple] == -1} {
						continue
					}
					# trouve l'index de cette danse pour le round
					# (des dances ont pu être skippées)
					set i [lsearch $folder(dances:$r) $d]
					#---------------
					set data [list ]
					if {$r != "finale" && [lsearch $folder(dances:$r) $d] == -1} {
						# danse non prise en compte
						foreach judge $judges {
							if {[lsearch $folder(judges:$r) $judge] == -1} {
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
						set font print:normal

					} elseif {$r == "finale"} {
						# une FINALE
						foreach judge $judges {
							set j [lsearch $folder(judges:$r) $judge]
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
						set font print:bold

#TRACE "    (finale) $total($r)+$dataRes  //  $item"
						set total($r) [expr {$total($r)+$dataRes}]

					} else {
						# un ROUND classique
						foreach judge $judges {
							set j [lsearch $folder(judges:$r) $judge]
							if {$j == -1} {
								lappend data ""
							} elseif {[lindex $folder(notes:$r:$couple:$d) $j]} {
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
						foreach item $folder(result:$r) {
							if {[lindex $item 0] == $couple} {
								break
							}
						}
						set font print:normal

						if {$preQualif} {
							set dataRes "+"
							set total($r) "+"
						} else {
							set dataRes [lindex $item [expr 2+$i]]
#TRACE "    (round) $total($r)+$dataRes  //  $couple / $r / $item"
							set total($r) [expr {$total($r)+$dataRes}]
						}
					}
					# impression
					print:ps:summary:oneCouple $font

					# le total (des mark ou somme des places)
					if {$count2 == $nbDances-1} {
						set xx [expr {$x + $wJ($d)+$wR}]
						$c create text [expr $xx+$wT/2] [expr $yy+$hSmall/2+1] \
									-text $total($r) -font print:normal
					}

					# round suivant
					incr yy $hSmall
				}

				# danse suivante
				incr x [expr {$wJ($d)+$wR}]
				incr count2
			}

			#---- la place globale
			if {$count2 == $nbDances} {
				$c create rectangle $x $y [expr $x+$wT] [expr $y+$h]
				incr x $wT
			}
			$c create rectangle $x $y [expr $x+$wP] [expr $y+$h]
			if {$gui(pref:print:placeAverage)} {
				set text $place
			} elseif {$min != $max} {
				set text "$min-$max"
			} else {
				set text $min
			}
			$c create text [expr $x+$wP/2] [expr $y+$h/2+1] \
						-text $text -font print:big

			# couple suivant
			set y [expr $y+$h]
		}

		# si il y a beaucoup de couples, générer des pages séparées
		# sinon essayer de tout faire tenir sur une page
		incr y $gui(pref:print:medium:skipY)
		if {$y > $gui(t:max)/2 || $donePageBreak} {
			set needPageBreak 1
		}

		# ensemble de danses suivantes
		incr count [llength $dances]
	}
}

proc skating::print:ps:summary:header {y} {
global msg
variable gui
variable event
upvar c c f f
upvar wC wC wN wN wL wL wJ wJ wR wR judges judges wP wP wT wT
upvar hNormal hNormal hBold hBold
upvar startX startX dances dances maxWidth maxWidth
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder


	set oldY $y

	#-- affiche un tableau avec la liste des juges
	if {$gui(pref:print:judgesInSummary)} {
		set scale [expr {0.7+0.05*[llength $folder(levels)]}]
		if {$scale > 0.95} {
			set scale 0.95
		}
		set oldy $y
		print:ps:judges $gui(pref:print:orientation) "1" print:normal print:bold \
					0 [expr {$maxWidth/2}] left $scale
		set y1 $y
		set y $oldy
		print:ps:judges $gui(pref:print:orientation) "2" print:normal print:bold \
					[expr {$maxWidth/2}] [expr {$maxWidth/2}] right $scale
		if {$y1 > $y} {
			set y $y1
		}
		incr y $gui(pref:print:medium:skipY)
	}

	#-- header proprement dit
	set x $startX
	# couple
	$c create rectangle $x $y [expr $x+$wC] [expr $y+$hBold+$hNormal] \
			-fill $gui(color:print:dark)
	incr x $wC
	# nom/école ou pays
	if {$event(useCountry)} {
		set text $msg(prt:country)
	} else {
		set text $msg(prt:school)
	}
	$c create rectangle $x $y [expr $x+$wN] [expr $y+$hBold+$hNormal] \
			-fill $gui(color:print:dark)
	$c create text [expr $x+3] [expr $y+$hBold/2+1] -anchor w \
			-text $msg(prt:name) -font print:bold
	$c create text [expr $x+3] [expr $y+$hBold+$hNormal/2+1] -anchor w \
			-text $text -font print:normal
	incr x $wN
	# round
	$c create rectangle $x $y [expr $x+$wL] [expr $y+$hBold+$hNormal] \
			-fill $gui(color:print:dark)
	$c create text [expr $x+$wL/2] [expr $y+($hBold+$hNormal)/2+1] \
			-text $msg(prt:round) -font print:bold
	incr x $wL
	# pour chaque danse
#puts "---- '$dances'"
	foreach d $dances {
#puts "$d"
		$c create rectangle $x $y [expr $x + $wJ($d)+$wR] [expr $y+$hBold] \
				-fill $gui(color:print:dark)
		$c create text [expr $x + ($wJ($d)+$wR)/2] [expr $y+$hBold/2+1] \
				-text [firstLetters $d] -font print:bold
		# les juges
		set xx $x
		set yy [expr $y+$hBold]
		foreach j $judges {
			$c create rectangle $xx $yy [expr $xx+$wJ($d:$j)] [expr $yy+$hNormal] \
					-fill $gui(color:print:light)
			$c create text [expr $xx + $wJ($d:$j)/2] [expr $yy+$hNormal/2+1] \
					-text $j -font print:normal
			incr xx $wJ($d:$j)
		}
		$c create rectangle $xx $yy [expr $xx+$wR] [expr $yy+$hNormal] \
				-fill $gui(color:print:light)
		$c create text [expr $xx + $wR/2] [expr $yy+$hNormal/2+1] \
				-text $msg(prt:resultShort) -font print:normal
		# danse suivante
		incr x [expr {$wJ($d)+$wR}]
	}

	# le total des marks ou somme des places
	if {$d == [lindex $folder(dances) end]} {
		$c create rectangle $x $y [expr $x+$wT] [expr $y+$hBold+$hNormal] \
				-fill $gui(color:print:dark)
		$c create text [expr $x+$wT/2] [expr $y+($hBold+$hNormal)/2+1] \
				-text $msg(prt:total) -font print:bold
		incr x $wT
	}

	# le classement global
	$c create rectangle $x $y [expr $x+$wP] [expr $y+$hBold+$hNormal] \
			-fill $gui(color:print:dark)
	$c create text [expr $x+$wP/2] [expr $y+($hBold+$hNormal)/2+1] \
			-text $msg(prt:place) -font print:bold

	# retourne la hauteur totale du header généré
	return [expr ($y-$oldY)+$hBold+$hNormal]
}

proc skating::print:ps:summary:oneCouple {font} {
upvar data data dataRes dataRes judges judges
upvar c c x x yy yy hSmall hSmall wJ wJ wR wR d d

	set xx $x
	foreach text $data j $judges {
#		$c create rectangle $xx $yy [expr $xx+$wJ($d:$j)] [expr $yy+$hSmall]
		if {$text != ""} {
			$c create text [expr $xx + $wJ($d:$j)/2] [expr $yy+$hSmall/2+1] \
					-text $text -font print:normal
		}
		incr xx $wJ($d:$j)
	}
#	$c create rectangle $xx $yy [expr $xx+$wR] [expr $yy+$hSmall]
	if {$dataRes != ""} {
		$c create text [expr $xx + $wR/2] [expr $yy+$hSmall/2+1] \
				-text $dataRes -font $font
	}
}



#=================================================================================================
#
#	Impression d'un rapport au format IDSF (juges, couples en finale avec résultat, statistiques)
#
#=================================================================================================

proc skating::print:ps:idsf:report {f order {header ""}} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder

#TRACEF

	# première page ...
	if {$gui(v:subten)} {
		set header "$msg(prt:idsf:report) '$gui(v:dance)'"
	} else {
		set header $msg(prt:idsf:report)
	}
	set c [print:ps:newpage $f $gui(pref:print:orientation) -blockheader $header]
	set y $gui(t:y)

	# calcule les tailles
	set maxWidth [expr $gui(t:r)-$gui(t:l)]
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]

	# commentaires
#  	if {$gui(pref:print:comment) && [info exists event(general:comment)]
#  			&& $event(general:comment) != ""} {
#  		$c create text $gui(t:l) $y -width [expr $gui(t:r)-$gui(t:l)] -anchor nw \
#  					-text $event(general:comment) -tags "comment" -font print:normal
#  		set y [expr [lindex [$c bbox comment] 3]+$gui(pref:print:big:skipY)]
#  	} elseif {!$gui(v:subten)} {
#  		set y [expr $y+$gui(pref:print:medium:skipY)]
#  	}

	# cartouche
	print:ps:attributesBlock $f $c idsf_report

	#--------------------
	# imprime les juges
	set y [expr $y+$gui(pref:print:small:skipY)]
	# page suivante si nécessaire
	if {$y+$hNormal > $gui(t:max)} {
		set c [print:ps:newpage $f $gui(pref:print:orientation) -blockheader $header]
		set y $gui(t:y)
	}
	# liste de juges locale ou globale
	set judges $folder(judges:finale)
	print:ps:judges $gui(pref:print:orientation) $judges print:normal print:bold \
				[expr {0.05*$maxWidth}] [expr {0.9*$maxWidth}] center 1.0

	#--------------------------------
	# imprime le résumé des résultats
	set y [expr $y+$gui(pref:print:small:skipY)]
	set results [class:finale $f]
	#---- classement
	set hNormal [expr int($gui(prt:spacing:big)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:big)*[font metrics "print:bold" -linespace])]
	# titre
	set wP 40
#	set wC 40
	set wC 0
	set wS 140
	set wN [expr {(0.9*$maxWidth-$wP-$wC-$wS)}]
	set left [expr $gui(t:l) + ($maxWidth-$wP-$wC-$wN-$wS)/2]
	set right [expr $gui(t:r) - ($maxWidth-$wP-$wC-$wN-$wS)/2]
	$c create rectangle $left $y $right [expr $y+$hBold] \
			-fill $gui(color:print:dark) -outline black
	$c create text [expr ($left+$right)/2] [expr $y+$hBold/2+1] \
			-text $msg(prt:resultsFinale) -font print:bold
	set y [expr $y+$hBold]
	# les couples & les places & leurs noms
	foreach data $results {
		set couple [lindex $data 0]
		set place [lindex $data 1]
		# page suivante si nécessaire
		if {$y+$hNormal > $gui(t:max)} {
			set c [print:ps:newpage $f $gui(pref:print:orientation) -blockheader $header]
			set y $gui(t:y)
		}
		# données
		set font print:bold
		set hNormal [expr int($gui(prt:spacing:big)*[font metrics "print:normal" -linespace])]
		# place
		$c create rectangle $left $y [expr $left+$wP] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr $left+$wP/2] [expr $y+$hNormal/2+1] \
				-text $place -font $font
		# couple
#  		$c create rectangle [expr $left+$wP] $y [expr $left+$wP+$wC] \
#  				[expr $y+$hNormal] -outline black
#  		$c create text [expr $left+$wP+$wC/2] [expr $y+$hNormal/2+1] \
#  				-text $couple -font $font
		# nom
		$c create rectangle [expr $left+$wP+$wC] $y [expr $left+$wP+$wC+$wN] [expr $y+$hNormal] \
				-outline black
		print:ps:textInBox $c [couple:name $f $couple] \
				[expr $left+$wP+$wC] [expr $left+$wP+$wC+$wN] [expr $y+$hNormal/2+1] print:normal
		# école/club
		$c create rectangle [expr $left+$wP+$wC+$wN] $y [expr $left+$wP+$wC+$wN+$wS] [expr $y+$hNormal] \
				-outline black
		print:ps:textInBox $c [couple:school $f $couple] \
				[expr $left+$wP+$wC+$wN] [expr $left+$wP+$wC+$wN+$wS] [expr $y+$hNormal/2+1] print:normal
		# suivant
		set y [expr $y+$hNormal]
		incr place
	}

	#-----------------------------------------------
	# imprime le nombre de couples pour chaque round
	set y [expr $y+$gui(pref:print:small:skipY)]
	set wT 80
	set wS 80
	set wD [expr {(0.9*$maxWidth-$wT-$wS)}]
	set left [expr $gui(t:l) + ($maxWidth-$wD-$wT-$wS)/2]
	set right [expr $gui(t:r) - ($maxWidth-$wD-$wT-$wS)/2]
	# header
	if {$y+$hBold+2*$hNormal > $gui(t:max)} {
		set c [print:ps:newpage $f $gui(pref:print:orientation) -blockheader $header]
		set y $gui(t:y)
	}
	$c create rectangle $left $y $right [expr $y+$hBold] \
			-fill $gui(color:print:dark) -outline black
	$c create text [expr ($left+$right)/2] [expr $y+$hBold/2+1] \
			-text $msg(prt:statistics) -font print:bold
	set y [expr $y+$hBold]
	# sub-header
	$c create rectangle $left $y [expr $left+$wD] [expr $y+$hNormal] \
			-fill $gui(color:print:light) -outline black
	$c create text [expr $left+$wD/2] [expr $y+$hNormal/2+1] \
			-text $msg(prt:rounds) -font print:normal
	$c create rectangle [expr $left+$wD] $y [expr $left+$wD+$wT] [expr $y+$hNormal] \
			-fill $gui(color:print:light) -outline black
	$c create text [expr $left+$wD+$wT/2] [expr $y+$hNormal/2+1] \
			-text $msg(prt:total) -font print:normal
	$c create rectangle [expr $left+$wD+$wT] $y [expr $right] [expr $y+$hNormal] \
			-fill $gui(color:print:light) -outline black
	$c create text [expr $left+$wD+$wT+$wS/2] [expr $y+$hNormal/2+1] \
			-text $msg(prt:set) -font print:normal
	set y [expr $y+$hNormal]

#	set nbrounds [llength $folder(levels)]
	foreach round $folder(levels) {
		# page suivante si nécessaire
		if {$y+$hNormal > $gui(t:max)} {
			set c [print:ps:newpage $f $gui(pref:print:orientation) -blockheader $header]
			set y $gui(t:y)
		}
		# nom du round
		$c create rectangle $left $y [expr $left+$wD] [expr $y+$hNormal] \
				-outline black
		print:ps:textInBox $c $folder(round:$round:name) \
					$left [expr $left+$wD] [expr $y+$hNormal/2+1] print:normal
		# nb total
		$c create rectangle [expr $left+$wD] $y [expr $left+$wD+$wT] [expr $y+$hNormal] \
				-outline black
		$c create text [expr $left+$wD+$wT/2] [expr $y+$hNormal/2+1] \
				-text [llength $folder(couples:$round)] -font $font
		# nb "set" en cas de redance
		if {[string first "." $round] != -1} {
			scan $round {%[^.].2} mainRound
			set text $folder(round:$mainRound:nbSelected)
		} else {
			set text "-"
		}
		$c create rectangle [expr $left+$wD+$wT] $y [expr $right] [expr $y+$hNormal] \
				-outline black
		$c create text [expr $left+$wD+$wT+$wS/2] [expr $y+$hNormal/2+1] \
				-text $text -font $font
		# suivant
		set y [expr $y+$hNormal]
	}
}


#=================================================================================================
#
#	Impression d'un tableau de résultats au format IDSF
#	(pour chaque couple, pour chaque round, nb de mark attribués par les juges)
#
#=================================================================================================

proc skating::print:ps:idsf:table {f order {header ""}} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder

#TRACEF

	# première page ...
	if {$gui(v:subten)} {
		set header "$msg(prt:idsf:table) '$gui(v:dance)'"
	} else {
		set header $msg(prt:idsf:table)
	}
	set c [print:ps:newpage $f $gui(pref:print:orientation) -blockheader $header]
	set y $gui(t:y)
	set needNewPage 0

	#-------------------------------
	# résultats (classés par couple)
	set allResults [lsort -integer -index 0 [class:folder $f]]

	#------------------
	# liste des couples
	set allCouples $folder(couples:all)

	#------------------
	# taille des fontes
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]
	# taille initiales
	set wJ 30
	set wJN 150
	set wC [expr {int(1.25*$hNormal)}]
	if {[llength $allCouples] > 10} {
		set wC [expr {int(1.6*$wC)}]
	}
	if {[llength $allCouples] > 100} {
		set wC [expr {int(2.1*$wC)}]
	}
	set maxWidth [expr {$gui(t:r)-$gui(t:l)}]
	set nbPerPage [expr {int(($maxWidth-$wJ-$wJN)/$wC)}]
	# réajuste la taille du nom
	set wJN [expr {int($maxWidth-$wJ-$nbPerPage*$wC)}]
	if {$wJN < 50} {
		set wJN 50
	}
	set startX $gui(t:l)
#TRACE "wJ = $wJ, wJN = $wJN, wC = $wC  /  $nbPerPage"


	#-------------------------------------
	# boucle pour chaque groupe de couples
	set maxCouple 0
	while {$maxCouple*$nbPerPage < [llength $allCouples]} {
		# couples pour cette page
		set couples [lrange $allCouples [expr {$maxCouple*$nbPerPage}] \
										[expr {($maxCouple+1)*$nbPerPage-1}]]
		set results [lrange $allResults [expr {$maxCouple*$nbPerPage}] \
										[expr {($maxCouple+1)*$nbPerPage-1}]]
		incr maxCouple

		# nouvelle page + header
		if {$needNewPage} {
			set c [print:ps:newpage $f $gui(pref:print:orientation) -blockheader $header]
			set y $gui(t:y)
		}
		# cartouche
		print:ps:attributesBlock $f $c idsf_table
		set y [expr {$y+10}]

		set y [expr {$y+[print:ps:idsf:table:header __full__ couples]}]

		# pour chaque round
		foreach round $folder(levels) {
			#---- list des couples ayant une note pour le round courant
			set goodCouples [list ]
			scan $round {%[^.]} mainRound
			foreach couple $couples {
				if {[lsearch $folder(couples:$mainRound) $couple] == -1} {
					lappend goodCouples "-"
				} else {
					lappend goodCouples $couple
				}
			}

			#---- affiche mini header
			if {$round != [lindex $folder(levels) 0]} {
				if {$y+$hBold > $gui(t:max)} {
					set c [print:ps:newpage $gui(v:folder) $gui(pref:print:orientation) -blockheader $header]
					set y $gui(t:y)
				}
				set y [expr {$y+[print:ps:idsf:table:header $msg(prt:set) goodCouples]}]
			}

			#---- cas special de la finale
			if {$round == "finale"} {
				# somme des notes
				if {$folder(mode) == "ten"} {
					class:folder $f
				} else {
					class:result $f
				}
				if {$y+$hNormal > $gui(t:max)} {
					set c [print:ps:newpage $gui(v:folder) $gui(pref:print:orientation) -blockheader $header]
					set y $gui(t:y)
				}
				$c create rectangle $startX $y [expr {$startX+$wJ+$wJN}] [expr {$y+$hNormal}] \
						-outline black
			  	print:ps:textInBox $c $msg(prt:sumInFinale) \
						$startX [expr {$startX+$wJ+$wJN}] [expr {$y+$hNormal/2+1}] print:normal right
				set i 0
				set x [expr {$startX+$wJ+$wJN}]
				foreach couple $couples {
					if {[lsearch $folder(couples:finale) $couple] != -1} {
						set text [lindex $folder(totals) $i]
						incr i
					} else {
						set text "-"
					}
					$c create rectangle $x $y [expr {$x+$wC}] [expr {$y+$hNormal}] \
							-outline black
				  	$c create text [expr {$x+$wC/2}] [expr {$y+$hNormal/2+1}] \
				  			-text $text -font print:normal
					# couple suivant
					set x [expr {$x+$wC}]
				}
				set y [expr {$y+$hNormal}]
				# couples
				set y [expr {$y+5}]
				if {$y+$hBold > $gui(t:max)} {
					set c [print:ps:newpage $gui(v:folder) $gui(pref:print:orientation) -blockheader $header]
					set y $gui(t:y)
				}
				set y [expr {$y+[print:ps:idsf:table:header $msg(prt:couples) couples]}]
				# place de XXX à YYY
				if {$y+2*$hNormal > $gui(t:max)} {
					set c [print:ps:newpage $gui(v:folder) $gui(pref:print:orientation) -blockheader $header]
					set y $gui(t:y)
				}
				$c create rectangle $startX $y [expr {$startX+$wJ+$wJN}] [expr {$y+$hNormal}] \
						-outline black
			  	print:ps:textInBox $c $msg(prt:placeFrom) \
						$startX [expr {$startX+$wJ+$wJN}] [expr {$y+$hNormal/2+1}] print:normal right
				$c create rectangle $startX [expr {$y+$hNormal}] [expr {$startX+$wJ+$wJN}] [expr {$y+2*$hNormal}] \
						-outline black
			  	print:ps:textInBox $c $msg(prt:placeTo) \
						$startX [expr {$startX+$wJ+$wJN}] [expr {$y+3*$hNormal/2+1}] print:normal right
				set x [expr {$startX+$wJ+$wJN}]
				foreach item $results {
					set min [lindex $item 1]
					set max [lindex $item 3]
					if {$max == $min} {
						set max "-"
					}
					$c create rectangle $x $y [expr {$x+$wC}] [expr {$y+$hNormal}] \
							-outline black
				  	$c create text [expr {$x+$wC/2}] [expr {$y+$hNormal/2+1}] \
				  			-text $min -font print:normal
					$c create rectangle $x [expr {$y+$hNormal}] [expr {$x+$wC}] [expr {$y+2*$hNormal}] \
							-outline black
				  	$c create text [expr {$x+$wC/2}] [expr {$y+3*$hNormal/2+1}] \
				  			-text $max -font print:normal
					# couple suivant
					set x [expr {$x+$wC}]
				}
				continue
			}

			# mémorise le total
			foreach couple $couples {
				set total($couple) 0
			}

			#---- round non "finale" : pour chaque juge
			set j 0
			foreach judge $folder(judges:$round) {
				set left $startX
				# lettre et nom du juge
				$c create rectangle $left $y [expr $left+$wJ] [expr $y+$hNormal] \
						-fill $gui(color:print:light) -outline black
			  	$c create text [expr $left+$wJ/2] [expr $y+$hNormal/2+1] \
			  			-text $judge -font print:bold
				incr left $wJ
				$c create rectangle $left $y [expr $left+$wJN] [expr $y+$hNormal] \
						-outline black
			  	print:ps:textInBox $c $event(name:$judge) \
						$left [expr {$left+$wJN}] [expr {$y+$hNormal/2+1}] print:normal

				# pour chaque couple
				set x [expr {$left+$wJN}]
				foreach couple $couples {
					if {[isPrequalified $f $couple $round]} {
						set text "+"
						set total($couple) $text
					} elseif {[lsearch $folder(couples:$round) $couple] == -1} {
						if {[lsearch $folder(couples:$mainRound) $couple] == -1} {
							# couple éliminé à ce niveau
							set text "-"
						} else {
							# couple qualifié en round de repêchage
							set text "*"
						}
						set total($couple) $text
					} else {
						# somme des marks donné par un juge sur l'ensemble des dances
						set text 0
						foreach dance $folder(dances:$round) {
							incr text [lindex $folder(notes:$round:$couple:$dance) $j]
						}
						# mise à jour total
						incr total($couple) $text
					}
					# affichage
					$c create rectangle $x $y [expr {$x+$wC}] [expr {$y+$hNormal}] \
							-outline black
				  	$c create text [expr {$x+$wC/2}] [expr {$y+$hNormal/2+1}] \
				  			-text $text -font print:normal
					# couple suivant
					set x [expr {$x+$wC}]
				}

				# juge suivant
				incr j
				set y [expr {$y+$hNormal}]
				if {$y+$hNormal > $gui(t:max)} {
					set c [print:ps:newpage $gui(v:folder) $gui(pref:print:orientation) -blockheader $header]
					set y $gui(t:y)
					set y [expr {$y+[print:ps:idsf:table:header __full__ goodCouples]}]
				}
			}

			#---- affiche le résultat pour ce round
			if {$y+$hBold > $gui(t:max)} {
				set c [print:ps:newpage $gui(v:folder) $gui(pref:print:orientation) -blockheader $header]
				set y $gui(t:y)
				set y [expr {$y+[print:ps:idsf:table:header __full__ goodCouples]}]
			}
			set left $startX
			# nom du round
			$c create rectangle $left $y [expr $left+$wJ+$wJN] [expr $y+$hBold] \
					-outline black
		  	print:ps:textInBox $c $folder(round:$round:name) \
					$left [expr {$left+$wJ+$wJN}] [expr {$y+$hBold/2+1}] print:bold right
			# pour chaque couple
			set x [expr {$left+$wJ+$wJN}]
			foreach couple $couples {
				$c create rectangle $x $y [expr {$x+$wC}] [expr {$y+$hBold}] \
						-outline black
			  	$c create text [expr {$x+$wC/2}] [expr {$y+$hBold/2+1}] \
			  			-text $total($couple) -font print:bold
				# couple suivant
				set x [expr {$x+$wC}]
			}

			# fin de la ligne
			set y [expr {$y+$hNormal}]
		}

		# nouvelle page pour un nouveau lot de couples
		set needNewPage 1
	}
}

proc skating::print:ps:idsf:table:header {type couplesVar} {
global msg
variable gui
variable event

upvar c c y y hBold hBold startX startX
upvar $couplesVar couples wJ wJ wJN wJN wC wC f f
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder


	set left $startX
	# lettre et nom du juge
	if {$type == "__full__"} {
		$c create rectangle $left $y [expr $left+$wJ+$wJN] [expr $y+2*$hBold] \
				-fill $gui(color:print:dark) -outline black
	  	print:ps:textInBox $c $msg(prt:judges) \
				$left [expr {$left+$wJ+$wJN}] [expr {$y+$hBold+1}] print:bold center
	} else {
		$c create rectangle $left $y [expr $left+$wJ+$wJN] [expr $y+$hBold] \
				-fill $gui(color:print:light) -outline black
	  	print:ps:textInBox $c $type \
				$left [expr {$left+$wJ+$wJN}] [expr {$y+$hBold/2+1}] print:bold right
	}
	incr left $wJ
	incr left $wJN

	#couples
	if {$type == "__full__"} {
		set right [expr {$left + $wC*[llength $couples]}]
		$c create rectangle $left $y $right [expr $y+$hBold] \
				-fill $gui(color:print:dark) -outline black
	  	$c create text [expr {$left+($right-$left)/2}] [expr {$y+$hBold/2+1}] \
	  			-text $msg(prt:couples) -font print:bold
		set y [expr {$y+$hBold}]
	}
	# pour chaque couple
	set x $left
	foreach couple $couples {
		$c create rectangle $x $y [expr {$x+$wC}] [expr {$y+$hBold}] \
				-fill $gui(color:print:light) -outline black
	  	$c create text [expr {$x+$wC/2}] [expr {$y+$hBold/2+1}] \
	  			-text $couple -font print:bold
		# suivant
		set x [expr {$x+$wC}]
	}

	# retourne la hauteur totale du header généré
	if {$type == "__full__"} {
		return [expr {2*$hBold}]
	} else {
		return $hBold
	}
}



#=================================================================================================
#
#	Impression des résultats globaux sur une compétition 10-danses
#
#=================================================================================================

proc skating::print:ps:result:ten {} {
global msg
variable event
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder

	set f $gui(v:folder)

	# première page ...
	set c [print:ps:newpage $gui(v:folder) -landscape -header]
	set y $gui(t:y)
	set needheader 1

	# calcule les résultats
	if {[catch { set folder(v:results) [class:folder $gui(v:folder)] }] || ![class:dances $gui(v:folder)]} {
		return
	}

	#------------------
	# taille des fontes
	set hNormal [expr int(1.1*$gui(prt:spacing:normal)*[font metrics "print:normal" -linespace])]
	set hBold [expr int(1.1*$gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]
	# taille initiales
	set wC 40
	set wD 40
	set twD [expr {$wD*[llength $folder(v:overall:dances)]}]
	set wT 50
	set wP 40
	set maxWidth [expr {$gui(t:r)-$gui(t:l)}]
	set wN [expr {$maxWidth-($wP+$wC+$twD+$wT+$wP)}]

	#--------------------
	# imprime les données
	foreach item $folder(v:results) {
		if {$needheader} {
			set needheader 0
			set y [expr {$y+[print:ps:result:ten:header]}]
		}
		# récupère une ligne à imprimer
		set couple [lindex $item 0]
		set place [lindex $item 1]
		set total [lindex $item 2]
		set places [lindex $item 3]
		#---- go
		set left $gui(t:l)
		# place
		$c create rectangle $left $y [expr $left+$wP] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
	  	$c create text [expr $left+$wP/2] [expr $y+$hNormal/2+1] \
	  			-text $place -font print:bold
		set left [expr {$gui(t:l)+$wP}]
		# couple
		$c create rectangle $left $y [expr $left+$wC] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
	  	$c create text [expr $left+$wC/2] [expr $y+$hNormal/2+1] \
	  			-text $couple -font print:bold
		set left [expr {$left+$wC}]
		# name
		$c create rectangle $left $y [expr $left+$wN] [expr $y+$hNormal] -outline black
		set text [couple:name $f $couple]
		if {[couple:school $f $couple] != ""} {
			append text " ([couple:school $f $couple])"
		}
		print:ps:textInBox $c $text $left [expr $left+$wN] \
				[expr $y+$hNormal/2+1] print:normal
		incr left $wN
		# danses
		foreach p $places {
			$c create rectangle $left $y [expr $left+$wD] [expr $y+$hNormal] -outline black
			$c create text [expr $left+$wD/2] [expr $y+$hNormal/2+1] -font print:normal \
					-text $p
			# suivante
			set left [expr $left+$wD]
		}
		# total
		$c create rectangle $left $y [expr $left+$wT] [expr $y+$hNormal] -outline black
		$c create text [expr $left+$wT/2] [expr $y+$hNormal/2+1] \
				-text $total -font print:bold
		set left [expr {$left+$wT}]
		# place (2)
		$c create rectangle $left $y [expr $left+$wP] [expr $y+$hNormal] \
				-fill $gui(color:print:light) -outline black
	  	$c create text [expr $left+$wP/2] [expr $y+$hNormal/2+1] \
	  			-text $place -font print:bold

		#---- suivant
		set y [expr {$y+$hNormal}]
		if {$y+$hNormal > $gui(t:max)} {
			set c [print:ps:newpage $gui(v:folder) -landscape -header]
			set y $gui(t:y)
			set needheader 1
		}
	}		
}

proc skating::print:ps:result:ten:header {} {
global msg
variable gui
upvar c c wC wC wN wN wD wD wT wT wP wP
upvar y y hNormal hNormal hBold hBold
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder

	set left $gui(t:l)
	# place
	$c create rectangle $left $y [expr $left+$wP] [expr $y+$hBold] \
			-fill $gui(color:print:dark) -outline black
  	$c create text [expr $left+$wP/2] [expr $y+$hBold/2+1] \
  			-text $msg(prt:place) -font print:bold
	set left [expr {$gui(t:l)+$wP}]
	# couple
	$c create rectangle $left $y [expr $left+$wC] [expr $y+$hBold] \
			-fill $gui(color:print:dark) -outline black
  	$c create text [expr $left+$wC/2] [expr $y+$hBold/2+1] \
  			-text $msg(prt:couple) -font print:bold
	set left [expr {$left+$wC}]
	# name
	$c create rectangle $left $y [expr $left+$wN] [expr $y+$hBold] \
			-fill $gui(color:print:dark) -outline black
	$c create text [expr $left+$wN/2] [expr $y+$hBold/2+1] -text $msg(name) -font print:bold
	incr left $wN
	# danses
	foreach dance $folder(v:overall:dances) {
		$c create rectangle $left $y [expr $left+$wD] [expr $y+$hBold] \
				-fill $gui(color:print:dark) -outline black
		$c create text [expr $left+$wD/2] [expr $y+$hBold/2+1] -font print:bold \
				-text [firstLetters $dance]
		# suivante
		set left [expr $left+$wD]
	}
	# total
	$c create rectangle $left $y [expr $left+$wT] [expr $y+$hBold] \
			-fill $gui(color:print:dark) -outline black
	$c create text [expr $left+$wT/2] [expr $y+$hBold/2+1] \
			-text $msg(prt:tot) -font print:bold
	set left [expr {$left+$wT}]
	# place (2)
	$c create rectangle $left $y [expr $left+$wP] [expr $y+$hBold] \
			-fill $gui(color:print:dark) -outline black
  	$c create text [expr $left+$wP/2] [expr $y+$hBold/2+1] \
  			-text $msg(prt:place) -font print:bold

	# retourne hauteur consommée
	set hBold
}



#=================================================================================================
#
#	Impression d'un état récapitulatif pour une compétition 10-danses
#
#=================================================================================================

proc skating::print:ps:summary:ten {f order} {
global msg
variable event
variable gui
variable $gui(v:folder)
upvar 0 $gui(v:folder) folder


	if {![info exists folder(v:results)] || ![class:dances $f]} {
		return
	}

	#===========
	# ATTENTION : doit être appelée APRES un classement global (utilisation de folder(v:results*))
	#===========
	#	print:ps:folder
	#		\__	print:event
	#				\__ print:ps:result:ten
	#						\__ class:folder + class:dances  --> folder(v:results*)
	#		\__ ps:summary:ten

	progressBarAdd [llength $folder(v:overall:dances)]

	# première page ...
	set header ""
	set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
	set y $gui(t:y)

	#-----------------
	# liste des danses
	set allDances $folder(v:overall:dances)
	set results $folder(v:results)
	if {$order == "couple"} {
		set results [lsort -integer -index 0 $results]
	}

	#---------------------------
	# calcule la liste des juges
	set allJudges [list ]
	foreach dance $allDances {
		variable $gui(v:folder).$dance
		upvar 0 $gui(v:folder).$dance Dfolder

		set judges($dance) [list ]
		foreach round $Dfolder(levels) {
			foreach j $Dfolder(judges:$round) {
				lappend judges($dance) $j
				lappend allJudges $j
			}
		}
		set judges($dance) [lsort -unique -command skating::event:judges:sort $judges($dance)]
	}
	set allJudges [lsort -unique -command skating::event:judges:sort $allJudges]

	#------------------
	# taille des fontes
	set hSmall [expr int([font metrics "print:normal" -linespace])]
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]
	set hBig [expr int($gui(prt:spacing:bold)*[font metrics "print:big" -linespace])]
	# taille initiales
	set wC [expr {int(1.55*$hBig)}]
	foreach dance $allDances {
		variable $gui(v:folder).$dance
		upvar 0 $gui(v:folder).$dance Dfolder
		results:computeJudgesSizes [list $dance] 12 24 Dfolder
	}
	set wL 30
	set wR 30
	set wPD 30
	set twJ 0
	foreach d $allDances {
		incr twJ [expr {$wL+$wJ($d)+$wR+$wPD}]
	}
	set wP [expr {int(1.1*$wC)}]
	if {[llength $results] > 10} {
		set wP [expr {int(1.6*$wC)}]
	}
	if {[llength $results] > 100} {
		set wP [expr {int(2.1*$wC)}]
	}
	set width [expr $wC+$twJ+$wP]
	set maxWidth [expr {$gui(t:r)-$gui(t:l)}]
	set wN [expr {$maxWidth - $width}]
#puts ">>>> required wN = $wN / $width, expr $wC+$twJ+$wP"
	if {$wN < 200} {
		set wN 200
	}
	set startX $gui(t:l)

	#---------------------------------------------------
	# imprime liste des juges sur page séparée si besoin
	if {$gui(pref:print:judgesInSummary) == 0} {
		print:ps:judges $gui(pref:print:orientation) $allJudges print:normal print:bold \
					0 [expr {$maxWidth/2}] left 1.0
		set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
		set y $gui(t:y)
	}

	#--------------------
	# imprime les données
	set nbDances [llength $allDances]
	set nbDone 0
	set needPageBreak 0
	set donePageBreak 0
	unset round
	while {$nbDone < $nbDances} {
		# nouvelle page si nécessaire
		if {$needPageBreak} {
			set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
			set y $gui(t:y)
			set donePageBreak 1
		}
		# calcule les danses à afficher
		set width [expr {$wC+$wN + $wP}]
		set dances {}
#puts ">>>> compute dances '$allDances', $ii / $nbDone of $nbDances / $width , expr $wC+$wN + $wP / $maxWidth"
		set oldDone $nbDone
		for {} {$nbDone < $nbDances} {incr nbDone} {
			set dance [lindex $folder(dances) $nbDone]
#puts "     dance = $dance / $width + ($wJ($dance)+$wR+$wPD) <[expr $width + ($wJ($dance)+$wR+$wPD)]> <= $maxWidth"
			if {$width + ($wL+$wJ($dance)+$wR+$wPD) <= $maxWidth} {
				set needCorrection 1
				lappend dances $dance
				incr width [expr {$wL+$wJ($dance)+$wR+$wPD}]
			} else {
				set needCorrection 0
#puts "splitting ---> $dance / $width + ($wJ($dance)+$wR+$wPD) [expr $width + ($wJ($dance)+$wR+$wPD)] <= $maxWidth"
				# test si on peut améliorer l'impression en groupant les dances par deux
#puts "          ???? [llength $dances] > [expr ($nbDances+1)/2]"
				if {[llength $dances] > ($nbDances+1)/2} {
					set dances [lrange $folder(dances) $oldDone [expr {$oldDone+($nbDances+1)/2-1}]]
					set nbDone [expr {$oldDone+($nbDances+1)/2}]
					set width [expr {$wC + $wP}]
#puts "          rearranging dances = '$dances'"
					foreach d $dances {
						incr width [expr {$wL+$wJ($dance)+$wR+$wPD}]
					}
#puts "set wN = {$maxWidth - $width} = [expr {$maxWidth - $width}]"
					set wN [expr {$maxWidth - $width}]
				} else {
#puts "set wN = {$wN + $maxWidth - $width} = [expr {$wN + $maxWidth - $width}]"
					set wN [expr {$wN + $maxWidth - $width}]
				}
#puts "          ====> $dances"
				break
			}
		}
		# corrige la taille des nom pour remplir la page
		if {$needCorrection} {
			set wN [expr {$wN + $maxWidth - $width}]
		}

#  		set result 0
#  		if {$nbDone == $nbDances} {
#  			# vérifie plus de place pour le total, enlève derniére danse
#  			# pour afficher avec le résultat
#  			if {$width + $wP > $maxWidth} {
#  				set dances [lrange $dances 0 end-1]
#  				incr nbDone -1
#  			} else {
#  				set result 1
#  			}
#  		}

		#---- imprime le détail des résultats
		# header
		set y [expr $y+[print:ps:summary:ten:header $y]]
#puts ">>>> $dances / $results"

		foreach item $results {
			set couple [lindex $item 0]
#puts "--------------- couple $couple"
			set mainplace [lindex $item 1]

			# nombre de lignes à imprimer
			set nb 2
			foreach d $allDances {
				variable $gui(v:folder).$d
				upvar 0 $gui(v:folder).$d Dfolder

				foreach i $folder(v:results:$d) {
					if {[lindex $i 0] == $couple} {
						set place($d) [lindex $i 1]
						set round($d) [lindex $i 2]
						break
					}
				}
				set n [expr {[lsearch $Dfolder(levels) $round($d)]+1}]
#puts "<$couple/$d> $round($d) {$Dfolder(levels)} in $gui(v:folder).$dance /  $n  /  nb=$nb"
				if {$n > $nb} {
					set nb $n
				}
			}
			set h [expr {$nb*$hSmall}]
#puts "    nb = $nb"
			# page suivante si nécessaire
			if {$y+$h > $gui(t:max)} {
				set c [print:ps:newpage $f $gui(pref:print:orientation) -header $header]
				set y $gui(t:y)
				set y [expr $y+[print:ps:summary:ten:header $y]]
				set donePageBreak 1
			}
			#--------
			# couple
			$c create rectangle $gui(t:l) $y [expr $gui(t:l)+$wC] [expr $y+$h] \
					-fill $gui(color:print:light) -outline black
			$c create text [expr $gui(t:l)+$wC/2] [expr $y+$h/2+1] \
					-text $couple -font print:big
			set left [expr $gui(t:l)+$wC]
			# nom
			$c create rectangle $left $y [expr $left+$wN] [expr $y+$h]
			print:ps:textInBox $c [couple:name $f $couple] \
					$left [expr $left+$wN] [expr $y+$hSmall/2+1] print:bold
			print:ps:textInBox $c [couple:school $f $couple] \
					$left [expr $left+$wN] [expr $y+$hSmall*3/2+1] print:normal
			incr left $wN
			# danses
			set x $left
			foreach d $dances {
				variable $gui(v:folder).$d
				upvar 0 $gui(v:folder).$d Dfolder
				#----
				$c create rectangle $x $y [expr $x+$wL+$wJ($d)+$wR+$wPD] [expr $y+($nb*$hSmall)]
				# rounds
				$c create rectangle $x $y [expr $x+$wL] [expr $y+$h]
				set yy [expr $y+$hSmall/2+1]
				set rounds [reverse [lrange $Dfolder(levels) 0 [lsearch $Dfolder(levels) $round($d)]]]
				foreach r $rounds {
					$c create text [expr $x+$wL/2] $yy \
								-text $msg(round:short:$r) -font print:normal
					incr yy $hSmall
				}
				incr x $wL
				set yy $y
				# pour chaque round
#puts "couple = $couple / dance = $d / $round($d), $rounds"
				foreach r $rounds {
					# trouve l'index de cette danse pour le round
					# (des dances ont pu être skippées)
					set i [lsearch $Dfolder(dances:$r) $d]
					#---------------
					set data [list ]
					if {$r != "finale" && [lsearch $Dfolder(dances:$r) $d] == -1} {
						# danse non prise en compte
						foreach judge $judges($d) {
							if {[lsearch $Dfolder(judges:$r) $judge] == -1} {
								lappend data ""
							} else {
								lappend data "-"
							}
						}
						set dataRes ""
						set font print:normal

					} elseif {$r == "finale"} {
						# une FINALE
						foreach judge $judges($d) {
							set j [lsearch $Dfolder(judges:$r) $judge]
							if {$j == -1} {
								lappend data ""
							} else {
								set note [lindex $Dfolder(notes:finale:$couple:$d) $j]
								if {[expr {int($note)}] == $note} {
									set note [expr {int($note)}]
								}
								lappend data $note
							}
						}
						# la place dans la danse
						set dataRes [lindex $Dfolder(places:$couple) 0]
						set font print:bold

					} else {
						# un ROUND classique
						foreach judge $judges($d) {
							set j [lsearch $Dfolder(judges:$r) $judge]
							if {$j == -1} {
								lappend data ""
							} elseif {[lindex $Dfolder(notes:$r:$couple:$d) $j]} {
								if {$gui(pref:print:useLetters)} {
									lappend data $judge
								} else {
									lappend data "X"
								}
							} else {
								lappend data "."
							}
						}
						# le sous-total
						foreach item $Dfolder(result:$r) {
							if {[lindex $item 0] == $couple} {
								break
							}
						}
						set dataRes [lindex $item 2]
						set font print:normal
					}
					# impression
					print:ps:summary:ten:oneCouple $font

					# round suivant
					incr yy $hSmall
				}

				# place dans la danse
				incr x [expr {$wJ($d)+$wR}]
				$c create rectangle $x $y [expr $x+$wPD] [expr $y+$h] \
						-fill $gui(color:print:light)
				$c create text [expr $x+$wPD/2] [expr $y+$h/2+1] \
						-text $place($d) -font print:normal

				# danse suivante
				incr x $wPD
			}
		
			#---- la place globale
#			if {$result} {
				$c create rectangle $x $y [expr $x+$wP] [expr $y+$h] \
						-fill $gui(color:print:light)
				$c create text [expr $x+$wP/2] [expr $y+$h/2+1] \
						-text $mainplace -font print:big
#			}

			# couple suivant
			set y [expr $y+$h]
		}

		# si il y a beaucoup de couples, générer des pages séparées
		# sinon essayer de tout faire tenir sur une page
		incr y $gui(pref:print:medium:skipY)
		if {$y > $gui(t:max)/2 || $donePageBreak} {
			set needPageBreak 1
		}

		# ensemble de danses suivantes
	}
}

proc skating::print:ps:summary:ten:header {y} {
global msg
variable gui
variable event
upvar c c f f
upvar wC wC wN wN wL wL wJ wJ wR wR wPD wPD allJudges allJudges judges judges wP wP
upvar hNormal hNormal hBold hBold
upvar startX startX dances dances maxWidth maxWidth


	set oldY $y

	#-- affiche un tableau avec la liste des juges
	if {$gui(pref:print:judgesInSummary)} {
		set scale 0.80
		set oldy $y
		set size [expr {([llength $allJudges]+1)/2}]
#puts "allJudges = $allJudges / $size / [lrange $allJudges 0 [expr {$size-1}]] / [lrange $allJudges $size end]"
		print:ps:judges $gui(pref:print:orientation) [lrange $allJudges 0 [expr {$size-1}]] print:normal print:bold \
					0 [expr {$maxWidth/2}] left $scale
		set y1 $y
		set y $oldy
		print:ps:judges $gui(pref:print:orientation) [lrange $allJudges $size end] print:normal print:bold \
					[expr {$maxWidth/2}] [expr {$maxWidth/2}] right $scale
		if {$y1 > $y} {
			set y $y1
		}
		incr y $gui(pref:print:medium:skipY)
	}

	#-- header proprement dit
	set x $startX
	# couple
	$c create rectangle $x $y [expr $x+$wC] [expr $y+$hBold+$hNormal] \
			-fill $gui(color:print:dark)
	incr x $wC
	# nom/école ou pays
	if {$event(useCountry)} {
		set text $msg(prt:country)
	} else {
		set text $msg(prt:school)
	}
	$c create rectangle $x $y [expr $x+$wN] [expr $y+$hBold+$hNormal] \
			-fill $gui(color:print:dark)
	$c create text [expr $x+3] [expr $y+$hBold/2+1] -anchor w \
			-text $msg(prt:name) -font print:bold
	$c create text [expr $x+3] [expr $y+$hBold+$hNormal/2+1] -anchor w \
			-text $text -font print:normal
	incr x $wN
	# pour chaque danse
	foreach d $dances {
		$c create rectangle $x $y [expr $x + $wL+$wJ($d)+$wR+$wPD] [expr $y+$hBold] \
				-fill $gui(color:print:dark)
		$c create text [expr $x + ($wL+$wJ($d)+$wR+$wPD)/2] [expr $y+$hBold/2+1] \
				-text [firstLetters $d] -font print:bold
		set yy [expr $y+$hBold]
		# round
		$c create rectangle $x $yy [expr $x+$wL] [expr $yy+$hNormal] \
				-fill $gui(color:print:light)
		$c create text [expr $x+$wL/2] [expr $yy+($hNormal)/2+1] \
				-text $msg(prt:round) -font print:normal
		incr x $wL
		# les juges
		set xx $x
		foreach j $judges($d) {
			$c create rectangle $xx $yy [expr $xx+$wJ($d:$j)] [expr $yy+$hNormal] \
					-fill $gui(color:print:light)
			$c create text [expr $xx + $wJ($d:$j)/2] [expr $yy+$hNormal/2+1] \
					-text $j -font print:normal
			incr xx $wJ($d:$j)
		}
		$c create rectangle $xx $yy [expr $xx+$wR] [expr $yy+$hNormal] \
				-fill $gui(color:print:light)
		$c create text [expr $xx + $wR/2] [expr $yy+$hNormal/2+1] \
				-text "Re" -font print:normal
		incr xx $wPD
		# place dans la	 danse
		$c create rectangle $xx $yy [expr $xx+$wPD] [expr $yy+$hNormal] \
				-fill $gui(color:print:light)
		$c create text [expr $xx + $wPD/2] [expr $yy+$hNormal/2+1] \
				-text $msg(prt:place:short) -font print:normal
		# danse suivante
		incr x [expr {$wJ($d)+$wR+$wPD}]
	}
	# le classement global
	$c create rectangle $x $y [expr $x+$wP] [expr $y+$hBold+$hNormal] \
			-fill $gui(color:print:dark)
	$c create text [expr $x+$wP/2] [expr $y+($hBold+$hNormal)/2+1] \
			-text $msg(prt:place) -font print:bold

	# retourne la hauteur totale du header généré
	return [expr ($y-$oldY)+$hBold+$hNormal]
}

proc skating::print:ps:summary:ten:oneCouple {font} {
upvar data data dataRes dataRes judges judges
upvar c c x x yy yy hSmall hSmall wJ wJ wR wR d d

#puts "skating::print:ps:summary:ten:oneCouple / $x / $data / $dataRes"
	set xx $x
	foreach text $data j $judges($d) {
#		$c create rectangle $xx $yy [expr $xx+$wJ($d:$j)] [expr $yy+$hSmall]
		if {$text != ""} {
			$c create text [expr $xx + $wJ($d:$j)/2] [expr $yy+$hSmall/2+1] \
					-text $text -font print:normal
		}
		incr xx $wJ($d:$j)
	}
#	$c create rectangle $xx $yy [expr $xx+$wR] [expr $yy+$hSmall]
	if {$dataRes != ""} {
		$c create text [expr $xx + $wR/2] [expr $yy+$hSmall/2+1] \
				-text $dataRes -font $font
	}
}



#=================================================================================================
#
#	Impression des listes de panels de juges
#
#=================================================================================================

proc skating::print:ps:panels {f} {
global msg
variable gui
variable event

	
	# première page ...
	set c [print:ps:newpage $f $gui(pref:print:orientation) -header $msg(prt:panels)]
	set y $gui(t:y)

	#------------------
	# taille des fontes
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]
	# taille initiales
	set wJ 30
	set nb $gui(pref:print:panelsPerRow)
	set space 40
	set maxWidth [expr {$gui(t:r)-$gui(t:l)}]
	set wN [expr {($maxWidth-($nb-1)*$space)/$nb-$wJ}]

	#--------------------
	# imprime les données
	set done 0
	while {$done < [llength $event(panels)]} {
		set panels [lrange $event(panels) $done [expr {$done+$nb-1}]]
		incr done $nb
		# vérifie si les panels tiennent dans la page
		set height -1
		foreach p $panels {
			set h [expr {$hBold + $hNormal*[llength $event(panel:judges:$p)]}]
			if {$h >$height} {
				set height $h
			}
		}
		if {$y+$height > $gui(t:max)} {
			set c [print:ps:newpage $f $gui(pref:print:orientation) -header]
			set y $gui(t:y)
		}
		# imprime chaque panel
		set x $gui(t:l)
		foreach p $panels {
			if {$p != ""} {
				print:ps:panels:onePanel $c $p $x $y
			}
			incr x [expr {$wJ+$wN+$space}]
		}
		# ensemble de panels suivant
		set y [expr {$y+$height+$space}]
	}
}

proc skating::print:ps:panels:onePanel {c panel x y} {
variable gui
variable event
upvar wJ wJ wN wN hBold hBold hNormal hNormal

	# nom du panel
	$c create rectangle $x $y [expr {$x+$wJ+$wN}] [expr {$y+$hBold}] \
			-fill $gui(color:print:dark) -outline black
	$c create text [expr {$x+($wJ+$wN)/2}] [expr {$y+$hBold/2+1}] \
			-text $event(panel:name:$panel) -font print:bold
	set y [expr $y+$hBold]
	# les juges
	foreach judge $event(panel:judges:$panel) {
		# lettre
		$c create rectangle $x $y [expr {$x+$wJ}] [expr {$y+$hNormal}] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr {$x+$wJ/2}] [expr {$y+$hNormal/2+1}] \
				-text $judge -font print:normal
		# nom
		$c create rectangle [expr {$x+$wJ}] $y [expr {$x+$wJ+$wN}] [expr {$y+$hNormal}] \
				-outline black
		print:ps:textInBox $c $event(name:$judge) \
				[expr {$x+$wJ}] [expr {$x+$wJ+$wN}] [expr {$y+$hNormal/2+1}] print:normal
		# juge suivant
		set y [expr {$y+$hNormal}]
	}
}



#=================================================================================================
#
#	Impression des listes de panels de juges
#
#=================================================================================================

proc skating::print:ps:competitions {f} {
global msg
variable gui
variable event

	
	# première page ...
	set c [print:ps:newpage $f $gui(pref:print:orientation) -header \
							$msg(prt:competitions:list)]
	set y $gui(t:y)

	#------------------
	# taille des fontes
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]
	# taille initiales
	set wJ 60
	set wC 60
	set wR 130
	set maxWidth [expr {$gui(t:r)-$gui(t:l)}]
	set wN [expr {$maxWidth-$wC-$wJ-$wR}]

	# header
	set y [expr {$y+[print:ps:competitions:header]}]

	#--------------------
	# imprime les données
	foreach f $event(folders) {
		variable $f
		upvar 0 $f folder
		# liste des compétitions (pour les 10-danses)
		set listOfFolder [list $f]
		if {$folder(mode) == "ten"} {
			foreach dance $folder(dances) {
				lappend listOfFolder $f.$dance
			}
		}
		# vérifie si les panels tiennent dans la page
		set height -1
		if {$y+$hBold*[llength $listOfFolder] > $gui(t:max)} {
			set c [print:ps:newpage $f $gui(pref:print:orientation) -header]
			set y $gui(t:y)
			set y [expr {$y+[print:ps:competitions:header]}]
		}
		# imprime chaque competition
		set x $gui(t:l)
		foreach f $listOfFolder {
			variable $f
			upvar 0 $f folder

			# regarder si 10-danses
			set dance [lindex [split $f "."] 1]
			# label
			if {$dance != ""} {
				set label "    $folder(label)  ($dance)"
				set font print:normal
			} else {
				set label $folder(label)
				if {$folder(mode) != "ten"} {
					set font print:normal
				} else {
					set font print:normal
				}
			}

			if {[string length $label] > 80} {
		  		set label "[string range $label 0 80]..."
			}

			if {$folder(mode) != "ten"} {
				set nbC [llength $folder(couples:names)]
				set nbJ [llength $folder(judges:finale)]
				set rounds [list ]
				foreach round $folder(levels) {
					lappend rounds $msg(round:short:$round)
				}
				set rounds [join $rounds ", "]
			} else {
				set nbC ""
				set nbJ ""
				set rounds ""
			}

			set left $gui(t:l)
			# competition
			$c create rectangle $left $y [expr {$left+$wN}] [expr {$y+$hBold}] -outline black
			print:ps:fullTextInBox $c $label $left [expr {$left+$wN}] [expr {$y+$hBold/2+1}] $font
			set left [expr {$left+$wN}]

			# couples
			$c create rectangle $left $y [expr {$left+$wC}] [expr {$y+$hBold}] -outline black
			print:ps:textInBox $c $nbC $left [expr {$left+$wC}] [expr {$y+$hBold/2+1}] $font center
			set left [expr {$left+$wC}]

			# judges
			$c create rectangle $left $y [expr {$left+$wJ}] [expr {$y+$hBold}] -outline black
			print:ps:textInBox $c $nbJ $left [expr {$left+$wJ}] [expr {$y+$hBold/2+1}] $font center
			set left [expr {$left+$wJ}]

			# rounds
			$c create rectangle $left $y [expr {$left+$wR}] [expr {$y+$hBold}] -outline black
			print:ps:textInBox $c $rounds $left [expr {$left+$wR}] [expr {$y+$hBold/2+1}] $font
			set left [expr {$left+$wR}]

  			# suivant
  			incr y $hBold
		}
	}
}

proc skating::print:ps:competitions:header {} {
global msg
variable gui
upvar c c wN wN wC wC wJ wJ wR wR
upvar y y hNormal hNormal hBold hBold


	set left $gui(t:l)
	# competition
	$c create rectangle $left $y [expr {$left+$wN}] [expr {$y+$hBold}] \
			-fill $gui(color:print:dark) -outline black
	print:ps:textInBox $c $msg(prt:competitions) \
				$left [expr {$left+$wN}] [expr {$y+$hBold/2+1}] print:bold center
	set left [expr {$left+$wN}]

	# couples
	$c create rectangle $left $y [expr {$left+$wC}] [expr {$y+$hBold}] \
			-fill $gui(color:print:dark) -outline black
	print:ps:textInBox $c $msg(prt:couples) \
				$left [expr {$left+$wC}] [expr {$y+$hBold/2+1}] print:bold center
	set left [expr {$left+$wC}]

	# judges
	$c create rectangle $left $y [expr {$left+$wJ}] [expr {$y+$hBold}] \
			-fill $gui(color:print:dark) -outline black
	print:ps:textInBox $c $msg(prt:judges) \
				$left [expr {$left+$wJ}] [expr {$y+$hBold/2+1}] print:bold center
	set left [expr {$left+$wJ}]

	# rounds
	$c create rectangle $left $y [expr {$left+$wR}] [expr {$y+$hBold}] \
			-fill $gui(color:print:dark) -outline black
	print:ps:textInBox $c $msg(prt:rounds) \
				$left [expr {$left+$wR}] [expr {$y+$hBold/2+1}] print:bold center
	set left [expr {$left+$wR}]

	return $hBold
}



#=================================================================================================
#
#	Impression d'un tableau de synthèse des participations pour vérifications
#
#=================================================================================================

proc skating::print:ps:enrollment:couples {f mode} {
global msg
variable gui
variable event

	# première page ...
	set c [print:ps:newpage $f $gui(pref:print:orientation) -header $msg(prt:enrollment:couples)]
	set y $gui(t:y)
	set empty 1

	#------------------
	# taille des fontes
	set hSmall [expr int([font metrics "print:normal" -linespace])]
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]
	set hBig [expr int($gui(prt:spacing:bold)*[font metrics "print:big" -linespace])]
	# taille initiales
	set max 0
	foreach couple $event(couples) {
		set len [string length $couple]
		if {$len > $max} {
			set max $len
		}
	}
	set wC [expr {int((1+0.25*$max)*$hBig)}]
	set maxWidth [expr {$gui(t:r)-$gui(t:l)}]
	set wN [expr {($maxWidth-$wC)/2}]
	if {$gui(pref:print:enrollment:results)} {
		# max ==> +2 pour les cas "xxx.5"
		set wP [expr {int((1+0.35*($max+2))*$hNormal)}]
		set wF [expr {$maxWidth-$wC-$wN-$wP}]
	} else {
		set wF [expr {$maxWidth-$wC-$wN}]
	}

	#------------------
	# liste des couples
	set couples [lsort -real $event(couples)]
	if {$mode == "alphabetic"} {
		set couples [lsort -command "alphabetic" $couples]
	}

	if {$gui(pref:print:enrollment:bySchool)} {
		set couples [lsort -command "groupBySchool" $couples]
		set lastSchool "_____________________"
	}

	#---------------------------------------------------------
	# contruit les données de résultat pour chaque compétition
	if {$gui(pref:print:enrollment:results)} {
		print:ps:enrollment:buildResults
	}

	#--------------------
	# imprime les données
	set y [expr $y+[print:ps:enrollment:couples:header $y]]
	foreach couple $couples {
		# construit liste des compétition du couple
		set competitions [list ]
		set folders [list ]
		foreach f $event(folders) {
			variable $f
			upvar 0 $f folder

			if {$folder(mode) == "ten"} {
				set missing [list ]
				foreach dance $folder(dances) {
					variable $f.$dance
					upvar 0 $f.$dance Dfolder
					if {[lsearch $Dfolder(couples:all) $couple] == -1} {
						lappend missing $dance
					}
				}
				if {[llength $missing] != [llength $folder(dances)]} {
					set text $folder(label)
					if {[llength $missing]} {
						append text " ($msg(except)"
						foreach dance $missing {
							append text " [firstLetters $dance],"
						}
						set text "[string range $text 0 end-1])"
					}
					lappend competitions $text
					lappend folders $f
				}
			} else {
				if {[lsearch $folder(couples:names) $couple] != -1} {
					lappend competitions $folder(label)
					lappend folders $f
				}
			}
		}
		# affiche la liste
		set nb [llength $competitions]
		if {$nb < 2} {
			set nb 2
		}
		set h [expr {$nb*$hSmall}]
		# page suivante si nécessaire
		if {$gui(pref:print:enrollment:bySchool) &&
				[couple:school "" $couple] != $lastSchool} {
			# 1. en cas de nouveau groupe si groupage par école/club activé
			if {($gui(pref:print:enrollment:pageBreak) && !$empty)
						|| $y+2*$hBig+3*$hBold > $gui(t:max)} {
				# si rien n'a été affiché sur la page, on garde -- sinon nouvelle page si besoin
				set c [print:ps:newpage $f $gui(pref:print:orientation) -header $msg(prt:enrollment:couples)]
			}
			if {$gui(pref:print:enrollment:pageBreak) || $empty || $y+2*$hBig+3*$hBold > $gui(t:max)} {
				set y $gui(t:y)
			} else {
				set y [expr {$y+$hBig}]
			}
			# imprime le nom du groupe
			set x $gui(t:l)
			$c create rectangle $x $y [expr $x+$maxWidth] [expr $y+$hBig] \
					-fill $gui(color:print:light)
			$c create text [expr $x+$maxWidth/2] [expr $y+$hBig/2+1] \
					-text [couple:school "" $couple] -font print:big
			set y [expr $y+$hBig]
			set lastSchool [couple:school "" $couple]
			# imprime le header
			set y [expr $y+[print:ps:enrollment:couples:header $y]]
			set donePageBreak 1

		} elseif {$y+$h > $gui(t:max)} {
			# 2. en cas de manque de place
			set c [print:ps:newpage $f $gui(pref:print:orientation) -header $msg(prt:enrollment:couples)]
			set y $gui(t:y)
			set y [expr $y+[print:ps:enrollment:couples:header $y]]
			set donePageBreak 1
		}
		set empty 0

		#--------
		# couple
		$c create rectangle $gui(t:l) $y [expr $gui(t:l)+$wC] [expr $y+$h] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr $gui(t:l)+$wC/2] [expr $y+$h/2+1] \
				-text $couple -font print:big
		set left [expr $gui(t:l)+$wC]
		# nom
		$c create rectangle $left $y [expr $left+$wN] [expr $y+$h]
		print:ps:textInBox $c [couple:name "" $couple] \
				$left [expr $left+$wN] [expr $y+$hSmall/2+1] print:bold
		print:ps:textInBox $c [couple:school "" $couple] \
				$left [expr $left+$wN] [expr $y+$hSmall*3/2+1] print:normal
		incr left $wN
		# compétitions
		$c create rectangle $left $y [expr $left+$wF] [expr $y+$h]
		if {$gui(pref:print:enrollment:results)} {
			$c create rectangle [expr {$left+$wF}] $y [expr {$left+$wF+$wP}] [expr $y+$h]
		}
		set yy [expr $y+$hSmall/2+1]
		foreach competition $competitions f $folders {
			print:ps:textInBox $c $competition \
					$left [expr {$left+$wF}] $yy print:normal
			if {$gui(pref:print:enrollment:results)} {
				$c create text [expr {$left+$wF+$wP/2}] $yy \
						-text $resultsData($f:$couple) -font print:normal
			}
			incr yy $hSmall
		}

		# couple suivant
		incr y $h
	}
}

proc skating::print:ps:enrollment:couples:header {y} {
global msg
variable gui
variable event
upvar c c
upvar wC wC wN wN wF wF wP wP
upvar hNormal hNormal hBold hBold

	#-- header
	set x $gui(t:l)
	# couple
	$c create rectangle $x $y [expr $x+$wC] [expr $y+$hBold] \
			-fill $gui(color:print:dark)
	incr x $wC
	# nom/école ou pays
	if {$event(useCountry)} {
		set text $msg(prt:country)
	} else {
		set text $msg(prt:school)
	}
	$c create rectangle $x $y [expr $x+$wN] [expr $y+$hBold] \
			-fill $gui(color:print:dark)
	$c create text [expr $x+$wN/2] [expr $y+$hBold/2+1] \
			-text "$msg(prt:name) & $text" -font print:bold
	incr x $wN
	# liste des compétitions
	$c create rectangle $x $y [expr $x+$wF] [expr $y+$hBold] \
			-fill $gui(color:print:dark)
	$c create text [expr $x+$wF/2] [expr $y+($hBold)/2+1] \
			-text $msg(prt:competitions) -font print:bold
	if {$gui(pref:print:enrollment:results)} {
		$c create rectangle [expr {$x+$wF}] $y [expr {$x+$wF+$wP}] [expr $y+$hBold] \
				-fill $gui(color:print:dark)
		$c create text [expr {$x+$wF+$wP/2}] [expr $y+($hBold)/2+1] \
				-text $msg(prt:place:short) -font print:bold
	}

	# retourne la hauteur totale du header généré
	return $hBold
}

proc skating::print:ps:enrollment:buildResults {} {
global msg
variable gui
variable event
upvar resultsData  resultsData

	foreach f $event(folders) {
		variable $f
		upvar 0 $f folder

		if {($folder(mode) == "normal" && ![info exists folder(couples:finale)]) || ![class:dances $f]} {
			if {$folder(mode) == "normal"} {
				set couples $folder(couples:names)
			} else {
				set couples [list ]
				foreach dance $folder(dances) {
					variable $f.$dance
					upvar 0 $f.$dance Dfolder

					foreach couple $Dfolder(couples:names) {
						lappend couples $couple
					}
				}
				set couples [lsort -unique $couples]
			}
			# pas de couples en finale ou toutes les notes non présentes -> résultats impossibles
			foreach couple $couples {
				set resultsData($f:$couple) "?"
			}
		} else {
			# résultats possibles
			set results [class:folder $f]
			foreach item $results {
				# nom "réel" du couple
				set couple [lindex $folder(couples:names) [lsearch $folder(couples:all) [lindex $item 0]]]
				set place [lindex $item 1]
				set resultsData($f:$couple) "$place"
				#if {$folder(mode) == "normal"} {
				#	set round [lindex $item 2]
				#	set resultsData($f:$couple) "$place ($msg(round:short:$round))"
				#}
			}
		}
	}
}


#=================================================================================================
#
#	Impression d'une table juges / compétitions
#
#=================================================================================================

proc skating::print:ps:enrollment:judges {} {
global msg
variable event
variable gui

	#------------------
	# taille des fontes
	set hSmall [expr int([font metrics "print:normal" -linespace])]
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]
	set hBig [expr int($gui(prt:spacing:bold)*[font metrics "print:big" -linespace])]

	set family [font configure print:normal -family]
	set size [font configure print:normal -size]
	set fontItalic [list $family $size italic]

	# taille initiales
	set wC 0
	foreach f $event(folders) {
		variable $f
		upvar 0 $f folder

		set w [font measure "print:normal" $folder(label)]
		if {$w > $wC} {
			set wC $w
		}
	}
	set wC [expr {$wC * 1.1}]
	set maxWidth [expr {$gui(t:r)-$gui(t:l)}]
	if {$wC > $maxWidth/3} {
		set wC [expr {$maxWidth/3}]
	}
	set wJTot [expr {$maxWidth-$wC}]
	set wJ 20
	# calcul nombre de juges par page
	set jPerPage [expr {int(floor($wJTot/$wJ))}]
	set jToPrint [llength $event(judges)]
	if {$jToPrint > $jPerPage} {
		set wC [expr {$maxWidth-$jPerPage*$wJ}]
	}

	# on imprime les pages
	set jPrinted 0
	while {$jPrinted < $jToPrint} {
		# pour toutes les compétitions pour les juges courants
		set judges [lrange $event(judges) $jPrinted [expr {$jPrinted+$jPerPage-1}]]
		# une nouvelle page pour ce groupe de juges
TRACE "$jPerPage != $jToPrint"
		if {$jPerPage < $jToPrint} {
TRACE "new page ..."
			set c [print:ps:newpage "" $gui(pref:print:orientation) -header $msg(prt:enrollment:judges)]
			set y $gui(t:y)
		} else {
			global lastY lastC
			set y [expr $lastY + 50]
			set c $lastC
		}
		set needHeader 1

		foreach f $event(folders) {
			variable $f
			upvar 0 $f folder

			# vérifie si tient dans la page + header si besoin
			if {$y+$hBold > $gui(t:max)} {
				set c [print:ps:newpage "" $gui(pref:print:orientation) -header $msg(prt:enrollment:judges)]
				set y $gui(t:y)
				set needHeader 1
			}
			if {$needHeader} {
				set y [expr $y+[print:ps:enrollment:judges:header $y]]
				set needHeader 0
			}

			# imprime nom de la compétition
			set x $gui(t:l)
			# nom compétition
			$c create rectangle $x $y [expr $x+$wC] [expr $y+$hBold] \
					-fill $gui(color:print:light)
			print:ps:textInBox $c $folder(label) \
					$x [expr $x+$wC] [expr $y+$hBold/2+1] print:normal
			set x [expr {$x+$wC}]
			# boite pour les juges
			foreach j $judges {
				$c create rectangle $x $y [expr $x+$wJ] [expr $y+$hBold]

				# cherche si juge utilisé (totalement ou partiellement=italique)
				set ok "OFF"
				if {$folder(mode) == "ten"} {
					set nb 0
					foreach dance $folder(dances) {
						set state [manage:judges:isSelected $f.$dance $j]
						if {$state == "PARTIAL" || ($nb > 1 && $state == "OFF")} {
							set ok "PARTIAL"
							break
						} elseif {$state == "ON"} {
							incr nb
						}
					}
					if {$nb == [llength $folder(dances)]} {
						set ok "ON"
					} elseif {$nb > 1} {
						set ok "PARTIAL"
					}
				} else {
					set ok [manage:judges:isSelected $f $j]
				}
				# affichage en fonction résultat recherche
				if {$ok == "ON"} {
					$c create text [expr $x+$wJ/2] [expr $y+$hBold/2+1] \
							-text $j -font print:normal
				} elseif {$ok == "PARTIAL"} {
					$c create text [expr $x+$wJ/2] [expr $y+$hBold/2+1] \
							-text $j -font $fontItalic
				}
				set x [expr {$x+$wJ}]
			}

			# compétitions suivante
			set y [expr $y+$hBold]
		}

		# on avance aux juges suivants
		incr jPrinted $jPerPage
	}
}

proc skating::print:ps:enrollment:judges:header {y} {
global msg
variable gui
upvar c c
upvar wC wC wJ wJ judges judges
upvar hNormal hNormal hBold hBold

	#-- header
	set x $gui(t:l)
	# nom compétition
	$c create rectangle $x $y [expr $x+$wC] [expr $y+$hBold] \
			-fill $gui(color:print:dark)
	set x [expr {$x+$wC}]
	# boite pour les juges
	foreach j $judges {
		$c create rectangle $x $y [expr $x+$wJ] [expr $y+$hBold] \
				-fill $gui(color:print:dark)
		$c create text [expr $x+$wJ/2] [expr $y+$hBold/2+1] \
				-text $j -font print:bold
		set x [expr {$x+$wJ}]
	}

	# retourne la hauteur totale du header généré
	return $hBold
}


#=================================================================================================
#
#	Impression d'une synthèse des couples & juges pour chaque compétition
#
#=================================================================================================

proc skating::print:ps:enrollment:competitions {{folders ""}} {
global msg
variable gui
variable event

	# première page ...
	set orientation $gui(pref:print:orientation)
	set c [print:ps:newpage "" $orientation -header]
	set y $gui(t:y)
	set empty 1

	#------------------
	# taille des fontes
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics "print:normal" -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics "print:bold" -linespace])]
	set hSubtitle [expr int($gui(prt:spacing:bold)*[font metrics "print:subtitle" -linespace])]
	set maxWidth [expr $gui(t:r)-$gui(t:l)]

	#------------------------
	# pour chaque compétition
	if {$folders == ""} {
		set folders $event(folders)
	}
	foreach f $folders {
		variable $f
		upvar 0 $f folder

		if {$folder(mode) == "ten"} {
			foreach dance $folder(dances) {
				if {$::enrollment(use:$f.$dance)} {
					print:ps:enrollment:competition $f.$dance
				}
			}

		} elseif {$::enrollment(use:$f)} {
			print:ps:enrollment:competition $f
		}
	}
}

proc skating::print:ps:enrollment:competition {f} {
global msg
variable gui
variable $f
upvar 0 $f folder

upvar c c y y empty empty orientation orientation
upvar hNormal hNormal hBold hBold hSubtitle hSubtitle maxWidth maxWidth


	# si rien n'a été affiché sur la page, on garde -- sinon nouvelle page si besoin
	if {($gui(pref:print:enrollment:pageBreak2) && !$empty)
			|| $y+5+$hSubtitle+$hBold+10+$hBold+3*$hNormal > $gui(t:max)} {
		set c [print:ps:newpage "" $orientation -header]
		set y $gui(t:y)
	}

	#---- nom de la compétition
	set y [expr {$y+5}]
	$c create text $gui(t:l) $y -text $folder(label) \
			-font print:subtitle -anchor w
	set y [expr {$y+$hSubtitle}]

	# la page n'est plus vide
	set empty 0

	# calcul le type de round + calcul éventuel des places
	if {$::enrollment(round:$f) == $msg(result)} {
		set round result
		class:result $f
		# liste des couples, classée par résultat
		set tmp [list ]
		foreach couple $folder(couples:finale) rank $folder(result) {
			lappend tmp [list $couple $rank]
		}
		set tmp [lsort -real -index 1 $tmp]
		set couples [list ]
		foreach data $tmp {
			lappend couples [lindex $data 0]
		}
	} else {
		foreach round $folder(levels) {
			if {$::enrollment(round:$f) == $folder(round:$round:name)} {
				break
			}
		}
		set couples [computeHeats $f $round 1000000 add number]
	}
	set what $round
	if {$round == "result"} {
		set round finale
	}
	# sépare les couples et les préqualifiés
	set nbPrequalified [nbPrequalified $f $round]
	set nbCouples [expr {[llength $couples] - $nbPrequalified}]
	set prequalified [lrange $couples $nbCouples end]
	set couples [lrange $couples 0 [expr $nbCouples-1]]

	#---- le round
	if {$y+$hBold > $gui(t:max)} {
		set c [print:ps:newpage "" $orientation -header]
		set y $gui(t:y)
	}
	$c create text $gui(t:l) [expr {$y+$hBold/2+1}] -anchor w \
			-text $::enrollment(round:$f) -font print:bold
	if {[string first "." $f] != -1} {
		$c create text $gui(t:r) [expr {$y+$hBold/2+1}] -anchor e \
				-text [lindex $folder(dances) 0] -font print:bold
	}
	set y [expr {$y+$hBold+10}]
						

	#---- les couples
	print:ps:couples $f $couples print:normal print:bold 0 $maxWidth left \
					 [expr [string equal $what "result"] ? 9 : 0]
	set y [expr {$y+10}]

	#---- nombre à sélectionner
	if {$gui(pref:print:enrollment:select) && $what != "result"} {
		set text "[print:ps:textNbToSelect]."
		if {$y+5+$hBold > $gui(t:max)} {
			set c [print:ps:newpage "" $orientation -header]
			set y $gui(t:y)
		}
		set y [expr {$y+5}]
		$c create text $gui(t:l) [expr {$y+$hNormal/2+1}] -anchor w \
				-text $text -font print:normal
		set y [expr {$y+$hNormal+15}]
	} else {
		set y [expr {$y+15}]
	}

	#---- les couples pré-qualifiés
	if {$nbPrequalified > 0} {
		$c create text $gui(t:l) [expr {$y+$hNormal/2+1}] -anchor w \
				-text $msg(prt:prequalified) -font print:normal
		set y [expr {$y+$hNormal+5}]
		print:ps:couples $f $prequalified print:normal print:bold \
						 0 $maxWidth left
		set y [expr {$y+10}]
	}

	#---- les juges
	if {$gui(pref:print:enrollment:judges)} {
		set oldc $c
		set oldy $y
		if {[llength $folder(judges:$round)] > 5
					&& !($gui(pref:print:enrollment:dances) && [string first "." $f] == -1)} {
			print:ps:judges $orientation $folder(judges:$round) print:normal print:bold \
						0 [expr {$maxWidth/2}] left 0.95 1
			if {$c != $oldc} {
				set nextc $c
			} else {
				set nextc ""
			}
			set y1 $y
			set y $oldy
			set c $oldc
			print:ps:judges $orientation $folder(judges:$round) print:normal print:bold \
						[expr {$maxWidth/2}] [expr {$maxWidth/2}] right 0.95 2
			if {$c == $oldc && $nextc != ""} {
				set c $nextc
				set y $y1
			} elseif {$y1 > $y} {
				set y $y1
			}
		} else {
			print:ps:judges $orientation $folder(judges:$round) print:normal print:bold \
						0 [expr {$maxWidth/2}] left 1.0
			if {$c != $oldc} {
				set nextc $c
			} else {
				set nextc ""
			}
			set y1 $y
		}
		set y [expr {$y+10}]
	}

	#---- les danses
	if {$gui(pref:print:enrollment:dances) && [string first "." $f] == -1} {
		if {[llength $folder(dances)] > 5 && !$gui(pref:print:enrollment:judges)} {
			set oldc $c
			set oldy $y
			print:ps:dances $f $round print:normal print:bold \
						0 [expr {$maxWidth/2}] left 0.95 1
			if {$c != $oldc} {
				set nextc $c
			} else {
				set nextc ""
			}
			set y1 $y
			set y $oldy
			set c $oldc
			print:ps:dances $f $round print:normal print:bold \
						[expr {$maxWidth/2}] [expr {$maxWidth/2}] right 0.95 2
			if {$c == $oldc && $nextc != ""} {
				set c $nextc
				set y $y1
			} elseif {$y1 > $y} {
				set y $y1
			}
		} elseif {$gui(pref:print:enrollment:judges)} {
			set y $oldy
			set c $oldc
			# 'nextc' défini lors impression des juges ci-dessus
			print:ps:dances $f $round print:normal print:bold \
						[expr {$maxWidth/2}] [expr {$maxWidth/2}] right 0.95

			if {$c == $oldc && $nextc != ""} {
				set c $nextc
				set y $y1
			} elseif {$y1 > $y} {
				set y $y1
			}
		} else {
			print:ps:dances $f $round print:normal print:bold \
						0 [expr {$maxWidth/2}] left 1.0
		}
		set y [expr {$y+10}]
	}

	# compétition suivante
	set y [expr {$y+20}]
}



#=================================================================================================
#
#	Impression de feuilles pré-imprimées pour les juges
#
#=================================================================================================

proc skating::print:ps:marksSheets {f round type {dances ""}} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder

#TRACEF

	#------------------
	# initialisation de la taille du papier
	switch $type {
		#==== portrait / 1
		portrait1 {
			set orientation -portrait
			# marge papier
			print:ps:set:margins -portrait
			# tailles
			set data(y)				$gui(t:m:t)
			set data(width)			1.5
			set data(font:judge)	print:big
			set data(hJudge)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:big" -linespace])}]
			set data(font:folder)	print:medium
			set data(hFolder)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:medium" -linespace])}]
			set data(font:title)	print:normal
			set data(hTitle)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:normal" -linespace])}]
			set data(font:date)		print:small
			set data(hSkip)			20
			set data(hBigSkip)		50
			# pour calcul de la taille d'un bloc
			set data(w)				[expr {$gui(t:w)-$gui(t:m:l)-$gui(t:m:r)}]
			set data(h)				[expr {$gui(t:h)-$gui(t:m:t)-$gui(t:m:b) - ($data(hJudge)+4*$data(hFolder)+$data(hSkip))}]
			set data(hSign)			[expr {$data(hFolder)+$data(hTitle)}]
		}
		#==== portrait / 2
		portrait2 {
			set orientation -portrait
			# marge papier
			print:ps:set:margins -landscape
			# tailles
			set data(y)				$gui(t:m:t)
			set data(width)			1.5
			set data(font:judge)	print:big
			set data(hJudge)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:big" -linespace])}]
			set data(font:folder)	print:medium
			set data(hFolder)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:medium" -linespace])}]
			set data(font:title)	print:normal
			set data(hTitle)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:normal" -linespace])}]
			set data(font:date)		print:small
			set data(hSkip)			20
			set data(hBigSkip)		50
			# pour calcul de la taille d'un bloc
			set data(w)				[expr {$gui(t:w)/2-$gui(t:m:l)-$gui(t:m:r)}]
			set data(h)				[expr {$gui(t:h)-$gui(t:m:t)-$gui(t:m:b) - ($data(hJudge)+4*$data(hFolder)+$data(hSkip))}]
			set data(hSign)			[expr {$data(hFolder)+$data(hTitle)}]
		}
		#==== portrait / 4
		portrait4 {
			set orientation -portrait
			# marge papier
			print:ps:set:margins -portrait
			# tailles
			set data(y)				$gui(t:m:t)
			set data(width)			1.5
			set data(font:judge)	print:large
			set data(hJudge)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:large" -linespace])}]
			set data(font:folder)	print:normal
			set data(hFolder)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:normal" -linespace])}]
			set data(font:title)	print:small
			set data(hTitle)		[expr {int($gui(prt:spacing:big)*[font metrics "print:small" -linespace])}]
			set data(font:date)		print:small
			set data(hSkip)			10
			set data(hBigSkip)		25
			# pour calcul de la taille d'un bloc
			set data(w)				[expr {$gui(t:w)/2-$gui(t:m:l)-$gui(t:m:r)}]
			set data(h)				[expr {$gui(t:h)/2-$gui(t:m:t)-$gui(t:m:b) - ($data(hJudge)+4*$data(hFolder)+$data(hSkip))}]
			set data(hSign)			[expr {$data(hFolder)+$data(hTitle)}]
		}

		#==== landscape / 1
		landscape1 {
			set orientation -landscape
			# marge papier
			print:ps:set:margins -landscape
			# tailles
			set data(y)				$gui(t:m:t)
			set data(width)			1.5
			set data(font:judge)	print:big
			set data(hJudge)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:big" -linespace])}]
			set data(font:folder)	print:medium
			set data(hFolder)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:medium" -linespace])}]
			set data(font:title)	print:normal
			set data(hTitle)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:normal" -linespace])}]
			set data(font:date)		print:small
			set data(hSkip)			10
			set data(hBigSkip)		50
			# pour calcul de la taille d'un bloc
			set data(w)				[expr {$gui(t:w)-$gui(t:m:l)-$gui(t:m:r)}]
			set data(h)				[expr {$gui(t:h)-$gui(t:m:t)-$gui(t:m:b) - ($data(hJudge)+2*$data(hFolder))}]
			set data(hSign)			[expr {$data(hFolder)+$data(hTitle)}]
		}
		#==== landscape / 2
		landscape2 {
			set orientation -landscape
			# marge papier
			print:ps:set:margins -portrait
			# tailles
			set data(y)				$gui(t:m:t)
			set data(width)			1.5
			set data(font:judge)	print:big
			set data(hJudge)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:big" -linespace])}]
			set data(font:folder)	print:medium
			set data(hFolder)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:medium" -linespace])}]
			set data(font:title)	print:normal
			set data(hTitle)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:normal" -linespace])}]
			set data(font:date)		print:small
			set data(hSkip)			10
			set data(hBigSkip)		50
			# pour calcul de la taille d'un bloc
			set data(w)				[expr {$gui(t:w)-$gui(t:m:l)-$gui(t:m:r)}]
			set data(h)				[expr {$gui(t:h)/2-$gui(t:m:t)-$gui(t:m:b) - ($data(hJudge)+2*$data(hFolder))}]
			set data(hSign)			[expr {$data(hFolder)+$data(hTitle)}]
		}
		#==== landscape / 4
		landscape4 {
			set orientation -landscape
			# marge papier
			print:ps:set:margins -landscape
			# tailles
			set data(y)				$gui(t:m:t)
			set data(width)			1.5
			set data(font:judge)	print:large
			set data(hJudge)		[expr {int($gui(prt:spacing:bold)*[font metrics "print:large" -linespace])}]
			set data(font:folder)	print:normal
			set data(hFolder)		[expr {int($gui(prt:spacing:big)*[font metrics "print:normal" -linespace])}]
			set data(font:title)	print:small
			set data(hTitle)		[expr {int($gui(prt:spacing:big)*[font metrics "print:small" -linespace])}]
			set data(font:date)		print:small
			set data(hSkip)			5
			set data(hBigSkip)		25
			# pour calcul de la taille d'un bloc
			set data(w)				[expr {$gui(t:w)/2-$gui(t:m:l)-$gui(t:m:r)}]
			set data(h)				[expr {$gui(t:h)/2-$gui(t:m:t)-$gui(t:m:b) - ($data(hJudge)+2*$data(hFolder))}]
			set data(hSign)			[expr {$data(hFolder)+$data(hTitle)}]
		}
	}

	#---------------------------------------------------------------------------------
	# calcul de la liste des couples (alétoire: germe = somme des couples sélectionné)
	if {$gui(pref:print:heats:mode) == "auto"} {
		set couples [computeHeats $f $round $gui(pref:print:heats:size) \
								  $gui(pref:print:heats:type) $gui(pref:print:heats:grouping)]
		if {$gui(pref:print:heats:print)} {
			print:ps:marksSheets:listHeats 1
		}
	} else {
		set couples [computeHeats $f $round 1000000 add number]
		if {$gui(pref:print:heats:print)} {
			print:ps:marksSheets:listHeats 0
		}
	}
	# si on ne veut pas les feuilles, on retourne
	if {$gui(pref:print:heats:withSheets) == 0} {
		return
	}

	#-----------------------------------
	# list des dances à traiter
	if {$dances == ""} {
		if {$round == "finale"} {
			if {$gui(pref:print:sheets:compact)} {
				set dances [list $folder(dances)]
			} else {
				set dances $folder(dances)
			}
		} else {
			if {$gui(pref:print:sheets:compact)} {
				set dances [list $folder(dances:$round)]
			} else {
				set dances $folder(dances:$round)
			}
		}
	}
	#-----------------------------------
	# taille de la fonte pour les boites
	if {$round == [lindex $folder(levels) 0]} {
		set data(nb) [expr {[llength $couples] + $gui(pref:print:sheets:spareBoxes)}]
	} else {
		set data(nb) [llength $couples]
	}
	if {$gui(pref:print:sheets:sign)} {
		# une signature est estimée à 3 lignes normales
		set data(h) [expr {$data(h) - 3*$data(hTitle)}]
	}
	set family [font configure print:normal -family]

	# défault à 10 pt
	set data(font) [list $family 6]
	set data(fontItalic) [list $family 6 italic]
	set data(size) 0
	# chercher taille de fonte optimale
	for {set font 6} {$font < 40} {incr font} {
		foreach {nbPerRow size} [print:ps:marksSheets:boxesSize $data(nb) [list $family $font] \
											$data(w) $data(h) \
											$gui(pref:print:inputGrid) $folder(round:$round:nb)] break
		if {$size == 0} {
			break
		}
#TRACE "nb per rows = $nbPerRow"
		set data(font) [list $family $font]
		set data(fontItalic) [list $family $font italic]
		set data(size) $size
	}
#TRACE "font to use = $data(font) / size = $data(size) / $data(w) x $data(h)"

	#-----------------------------
	# impression pour chaque danse
	set i 0
	foreach judge $folder(judges:$round) {
		foreach dance $dances {
			# choix de la page et la la position
			switch $type {
				#==== portrait / 1
				portrait1 {
					set c [print:ps:newpage $f -portrait -noheader]
					set data(left)		$gui(t:m:l)
					set data(right)		[expr {$gui(t:w)-$gui(t:m:r)}]
					set data(y)			$gui(t:m:t)
					set data(bottom)	[expr {$gui(t:h)-$gui(t:m:b)}]
					# impression
					print:ps:marksSheets:portrait:panel
				}
				#==== portrait / 2
				#    0    |    1
				portrait2 {
					if {($i % 2) == 1} {
						set data(left)		[expr {$gui(t:w)/2+$gui(t:m:l)}]
						set data(right)		[expr {$gui(t:w)-$gui(t:m:r)}]
					} else {
						set c [print:ps:newpage $f -landscape -noheader]
						$c create line [expr {$gui(t:w)/2}] 0 [expr {$gui(t:w)/2}] $gui(t:h)
						set data(left)		$gui(t:m:l)
						set data(right)		[expr {$gui(t:w)/2-$gui(t:m:r)}]
					}
					set data(y)				$gui(t:m:t)
					set data(bottom)		[expr {$gui(t:h)-$gui(t:m:b)}]
					# impression
					print:ps:marksSheets:portrait:panel
				}
				#==== portrait / 4
				portrait4 {
					#  0  |  1
					#-----+-----
					#  2  |  3
					if {($i % 4) == 1} {
						set data(left)		[expr {$gui(t:w)/2+$gui(t:m:l)}]
						set data(right)		[expr {$gui(t:w)-$gui(t:m:r)}]
						set data(y)			$gui(t:m:t)
						set data(bottom)	[expr {$gui(t:h)/2-$gui(t:m:b)}]
					} elseif {($i % 4) == 2} {
						set data(left)		$gui(t:m:l)
						set data(right)		[expr {$gui(t:w)/2-$gui(t:m:r)}]
						set data(y)			[expr {$gui(t:h)/2+$gui(t:m:t)}]
						set data(bottom)	[expr {$gui(t:h)-$gui(t:m:b)}]
					} elseif {($i % 4) == 3} {
						set data(left)		[expr {$gui(t:w)/2+$gui(t:m:l)}]
						set data(right)		[expr {$gui(t:w)-$gui(t:m:r)}]
						set data(y)			[expr {$gui(t:h)/2+$gui(t:m:t)}]
						set data(bottom)	[expr {$gui(t:h)-$gui(t:m:b)}]
					} else {
						set c [print:ps:newpage $f -portrait -noheader]
						$c create line [expr {$gui(t:w)/2}] 0 [expr {$gui(t:w)/2}] $gui(t:h)
						$c create line 0 [expr {$gui(t:h)/2}] $gui(t:w) [expr {$gui(t:h)/2}]
						set data(left)		$gui(t:m:l)
						set data(right)		[expr {$gui(t:w)/2-$gui(t:m:r)}]
						set data(y)			$gui(t:m:t)
						set data(bottom)	[expr {$gui(t:h)/2-$gui(t:m:b)}]
					}
					# impression
					print:ps:marksSheets:portrait:panel
				}

				#==== landscape / 1
				landscape1 {
					set c [print:ps:newpage $f -landscape -noheader]
					set data(left)		$gui(t:m:l)
					set data(right)		[expr {$gui(t:w)-$gui(t:m:r)}]
					set data(y)			$gui(t:m:t)
					set data(bottom)	[expr {$gui(t:h)-$gui(t:m:b)}]
					# impression
					print:ps:marksSheets:portrait:panel
				}
				#==== landscape / 2
				landscape2 {
					#  0  
					#-----
					#  1  
					if {($i % 2) == 1} {
						set data(y)			[expr {$gui(t:h)/2+$gui(t:m:t)}]
						set data(bottom)	[expr {$gui(t:h)-$gui(t:m:b)}]
					} else {
						set c [print:ps:newpage $f -portrait -noheader]
						$c create line 0 [expr {$gui(t:h)/2}] $gui(t:w) [expr {$gui(t:h)/2}]
						set data(y)			$gui(t:m:t)
						set data(bottom)	[expr {$gui(t:h)/2-$gui(t:m:b)}]
					}
					set data(left)			$gui(t:m:l)
					set data(right)			[expr {$gui(t:w)-$gui(t:m:r)}]
					# impression
					print:ps:marksSheets:landscape:panel
				}
				#==== landscape / 4
				landscape4 {
					#    0    |    1
					#---------+---------
					#    2    |    3
					if {($i % 4) == 1} {
						set data(left)		[expr {$gui(t:w)/2+$gui(t:m:l)}]
						set data(right)		[expr {$gui(t:w)-$gui(t:m:r)}]
						set data(y)			$gui(t:m:t)
						set data(bottom)	[expr {$gui(t:h)/2-$gui(t:m:b)}]
					} elseif {($i % 4) == 2} {
						set data(left)		$gui(t:m:l)
						set data(right)		[expr {$gui(t:w)/2-$gui(t:m:r)}]
						set data(y)			[expr {$gui(t:h)/2+$gui(t:m:t)}]
						set data(bottom)	[expr {$gui(t:h)-$gui(t:m:b)}]
					} elseif {($i % 4) == 3} {
						set data(left)		[expr {$gui(t:w)/2+$gui(t:m:l)}]
						set data(right)		[expr {$gui(t:w)-$gui(t:m:r)}]
						set data(y)			[expr {$gui(t:h)/2+$gui(t:m:t)}]
						set data(bottom)	[expr {$gui(t:h)-$gui(t:m:b)}]
					} else {
						set c [print:ps:newpage $f -landscape -noheader]
						$c create line [expr {$gui(t:w)/2}] 0 [expr {$gui(t:w)/2}] $gui(t:h)
						$c create line 0 [expr {$gui(t:h)/2}] $gui(t:w) [expr {$gui(t:h)/2}]
						set data(left)		$gui(t:m:l)
						set data(right)		[expr {$gui(t:w)/2-$gui(t:m:r)}]
						set data(y)			$gui(t:m:t)
						set data(bottom)	[expr {$gui(t:h)/2-$gui(t:m:b)}]
					}
					# impression
					print:ps:marksSheets:landscape:panel
				}
			}
			# danses suivante -- page suivante
			incr i
		}
		# juge suivant -- nouvelle feuille
		if {$gui(pref:print:sheets:newOnJudge)} {
			switch $type {
				landscape2	-
				portrait2	{ while {($i % 2) != 0} { incr i } }
				landscape4	-
				portrait4	{ while {($i % 4) != 0} { incr i } }
			}
		}
	}
}

#----------------------------------------------------------------------------------------------

proc skating::print:ps:marksSheets:listHeats {computed} {
upvar f f folder folder couples couples orientation orientation round round
variable gui
global msg


#TRACEF " -- $couples (in $round)"

	# pour la demi-finale et la finale, affiche le nom complet
	if {$round == "semi" || $round == "prefinale" || $round == "finale"} {
		print:ps:marksSheets:listHeatsWithFullNames $computed
		return
	}

	# calcul nombre de couples en piste + nombre pré-qualifiés
	set nbPrequalified [nbPrequalified $f $round]
	set nbCouples [expr {[llength $couples] - $nbPrequalified}]
	set isSplit [expr {[string first "." $round] != -1}]

	# première page
	if {$gui(v:subten)} {
		set header "$msg(prt:heats) '$folder(round:$gui(v:round):name)' ($gui(v:dance))"
	} else {
		set header "$msg(prt:heats) '$folder(round:$gui(v:round):name)'"
	}
	set subtitle [print:ps:textNbToSelect]
	set c [print:ps:newpage $f $orientation -header $header $subtitle]
	set y $gui(t:y)
	set x $gui(t:l)

	# gestion des couples
	set nbPrequalified [nbPrequalified $f $round]
	set nb [expr {[llength $couples]-$nbPrequalified}]
	set start [expr {$nb-$nbPrequalified}]
	if {$computed} {
		# calcule les tailles des heats
		foreach {nb1 size1 nb2 size2} [computeHeats:size $nb $gui(pref:print:heats:size) $gui(pref:print:heats:type)] break
		set heat 1
		set total [expr {$nb1+$nb2}]
	} else {
		set total 1
	}
	# créé les deux liste : normal + pré-qualifiés
#TRACE "couples avant = $couples  //  $start"
	set prequalified [lrange $couples $nb end]
	set couples [lrange $couples 0 [expr $nb-1]]

	# nombre de couples en fonction orientation de la page
	if {$orientation == "-portrait"} {
		set max 12
	} else {
		set max 18
	}

	# paramètres graphiques
	set hMedium [expr {int($gui(prt:spacing:bold)*[font metrics "print:medium" -linespace])}]
	set wH 100
	set wC [expr {(($gui(t:r)-$gui(t:l))-$wH) / $max}]

	#---- affichage des couples / des heats
	if {$computed} {
		#-- pour chaque heat
		set index 0
		while {$total} {
			# extrait les couples
			if {$heat <= $nb1} {
				set newIndex [expr {$index+$size1}]
			} else {
				set newIndex [expr {$index+$size2}]
			}
			set couplesInHeat [lrange $couples $index [expr {$newIndex-1}]]
			set index $newIndex
			# paramètre
			set h [expr {$wC*(1+([llength $couplesInHeat]-1)/$max)}]
#TRACE "  <$heat> $couplesInHeat  /  [expr {(1+([llength $couplesInHeat]-1)/$max)}] lines"
			# teste si tient dans la page
			if {$y+$h > $gui(t:max)} {
				set c [print:ps:newpage $f $orientation -header $header]
				set y $gui(t:y)
			}
			# affiche
			$c create rectangle $x $y [expr {$x+$wH}] [expr {$y+$h}] \
					-fill $gui(color:print:light) -outline black
			$c create text [expr {$x+$wH/2}] [expr {$y+$h/3+1}] \
					-text "$msg(prt:Heat) $heat" -font print:medium
			$c create text [expr {$x+$wH/2}] [expr {$y+$h*3/4+1}] \
					-text "[llength $couplesInHeat] $msg(prt:couples2)" -font print:normal
			set xx [expr {$x+$wH}]
			set yy $y
			set i 0
			foreach couple $couplesInHeat {
				$c create rectangle $xx $yy [expr {$xx+$wC}] [expr {$yy+$wC}] \
						-outline black
				$c create text [expr {$xx+$wC/2}] [expr {$yy+$wC/2+1}] \
						-text $couple -font print:big
				# couple suivant
				incr xx $wC
				incr i
				if {($i % $max) == 0} {
					incr yy $wC
					set xx [expr {$x+$wH}]
				}
			}
			# heat suivante
			set y [expr {$y + $h + 10}]
			incr heat
			incr total -1
		}
	} else {
		#-- simple liste des couples
		set nbLeft $nb
		set nbPerPage [expr {(($gui(t:max)-$y)/$wC)*$max}]
		set page 0
		while {$nbLeft > 0} {
			# nombre de couples à afficher sur cette page
			set nbTodo $nbPerPage
			if {$nbTodo > $nbLeft} {
				set nbTodo $nbLeft
			}
			incr nbLeft -$nbTodo
			# calcul la hauteur
			set h [expr {$wC*(1+($nbTodo-1)/$max)}]
			$c create rectangle $x $y [expr {$x+$wH}] [expr {$y+$h}] \
					-fill $gui(color:print:light) -outline black
			$c create text [expr {$x+$wH/2}] [expr {$y+$h/3+1}] \
					-text "$msg(prt:couples)" -font print:medium
			$c create text [expr {$x+$wH/2}] [expr {$y+$h*3/4+1}] \
					-text "$nb $msg(prt:couples2)" -font print:normal
			set xx [expr {$x+$wH}]
			set yy $y
			set i 0
			foreach couple [lrange $couples [expr $page*$nbPerPage] \
											[expr ($page+1)*$nbPerPage-1]] {
				$c create rectangle $xx $yy [expr {$xx+$wC}] [expr {$yy+$wC}] \
						-outline black
				$c create text [expr {$xx+$wC/2}] [expr {$yy+$wC/2+1}] \
						-text $couple -font print:big
				# couple suivant
				incr xx $wC
				incr i
				if {($i % $max) == 0} {
					incr yy $wC
					set xx [expr {$x+$wH}]
				}
			}

			# on se décale
			set y [expr {$y + $h + 10}]
			if {$y+$wC > $gui(t:max)} {
				set c [print:ps:newpage $f $orientation -header $header]
				set y $gui(t:y)
				incr page
			}
		}
	}
	#-- liste des couples préqualified
	if {$nbPrequalified > 0 && !$isSplit} {
		# teste si tient dans la page
		set y [expr {$y + 40}]
		if {$y+$h > $gui(t:max)} {
			set c [print:ps:newpage $f $orientation -header $header]
			set y $gui(t:y)
		}

		# on liste tous les couples
		set h [expr {$wC*(1+($nbPrequalified-1)/$max)}]
		$c create rectangle $x $y [expr {$x+$wH}] [expr {$y+$h}] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr {$x+$wH/2}] [expr {$y+$h/3+1}] \
				-text "$msg(prt:prequalified)" -font print:medium
		$c create text [expr {$x+$wH/2}] [expr {$y+$h*3/4+1}] \
				-text "$nbPrequalified $msg(prt:couples2)" -font print:normal
		set xx [expr {$x+$wH}]
		set yy $y
		set i 0
		foreach couple $prequalified {
			$c create rectangle $xx $yy [expr {$xx+$wC}] [expr {$yy+$wC}] \
					-outline black
			$c create text [expr {$xx+$wC/2}] [expr {$yy+$wC/2+1}] \
					-text $couple -font print:big
			# couple suivant
			incr xx $wC
			incr i
			if {($i % $max) == 0} {
				incr yy $wC
				set xx [expr {$x+$wH}]
			}
		}
	}


	#---- liste des juges et des danses (si demandées)
	if {$gui(pref:print:heats:lists) == 0} {
		return
	}
	# taille de la liste
	set folder(dances:finale) $folder(dances)
	set maxWidth [expr {$gui(t:r)-$gui(t:l)}]
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics print:normal -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics print:bold -linespace])]
	set h1j [expr {$hBold + $hNormal*[llength $folder(judges:$round)] + $gui(pref:print:medium:skipY)+10}]
	set h2j [expr {$hBold + $hNormal*([llength $folder(judges:$round)]+1)/2 + $gui(pref:print:medium:skipY)+10}]
	set h1d [expr {$hBold + $hNormal*[llength $folder(dances:$round)] + $gui(pref:print:medium:skipY)+10}]
	set h2d [expr {$hBold + $hNormal*([llength $folder(dances:$round)]+1)/2 + $gui(pref:print:medium:skipY)+10}]
	set withJudges [expr {$gui(pref:print:heats:lists) & 1}]
	set withDances [expr {$gui(pref:print:heats:lists) & 2}]
	if {$withJudges && $withDances} {
		set h1 [expr {$h1j > $h1d ? $h1j : $h1d}]
		set h2 $h1
#TRACE "with both  h1 = $h1 / $h1j / $h1d"
	} elseif {$withJudges} {
		set h1 $h1j
		set h2 $h2j
	} else {
		set h1 $h1d
		set h2 $h2d
	}
	 # recherche tient dans la page
	set cols 1
	if {$y+$h1 > $gui(t:max)} {
#TRACE "not fitting in one page"
		if {$y + $h2 > $gui(t:max)} {
			# si ne passe pas en double colonne, nouvelle page
#TRACE "    = new page"
			set c [print:ps:newpage $f $orientation -header $header]
			set y $gui(t:y)
		} elseif {$gui(pref:print:heats:lists) != 3} {
			# si pas juges+danses, on passe en double colonne
#TRACE "    = 2 cols"
			set cols 2
		}
	} else {
		# tient dans la page
		# on essaie de faire joli
		if {( (($gui(pref:print:heats:lists) & 1) && [llength $folder(judges:$round)] >= 10)
			  || (($gui(pref:print:heats:lists) & 2) && [llength $folder(dances)] >= 10))
					&& $gui(pref:print:heats:lists) != 3} {
			set y [expr {$gui(t:max)-$h2}]
			set cols 2
		} else {
			set y [expr {$gui(t:max)-$h1}]
		}
		set y [expr {$y + $gui(pref:print:medium:skipY)}]
	}
	# affichage
	set oldy $y
	if {$withJudges} {
		if {$cols == 1} {
			print:ps:judges $orientation $folder(judges:$round) print:normal print:bold \
						0 [expr {$maxWidth/2}] left 0.95
		} else {
			print:ps:judges $orientation $folder(judges:$round) print:normal print:bold \
						0 [expr {$maxWidth/2}] left 0.95 1
			set y1 $y
			set y $oldy
			print:ps:judges $orientation $folder(judges:$round) print:normal print:bold \
						[expr {$maxWidth/2}] [expr {$maxWidth/2}] right 0.95 2
		}
	}
	set y $oldy
	if {$withDances} {
		if {$cols == 1} {
			if {$withJudges} {
				print:ps:dances $f $round print:normal print:bold \
							[expr {$maxWidth/2}] [expr {$maxWidth/2}] right 0.95
			} else {
				print:ps:dances $f $round print:normal print:bold \
							0 [expr {$maxWidth/2}] left 0.95
			}
		} else {
			print:ps:dances $f $round print:normal print:bold \
						0 [expr {$maxWidth/2}] left 0.95 1
			set y1 $y
			set y $oldy
			print:ps:dances $f $round print:normal print:bold \
						[expr {$maxWidth/2}] [expr {$maxWidth/2}] right 0.95 2
		}
	}
}

proc skating::print:ps:marksSheets:listHeatsWithFullNames {computed} {
upvar f f folder folder couples couples orientation orientation round round
variable gui
global msg

	# Semi-finale -- Prefinale -- Finale (devrait tenir sur une page)
TRACEF " -- $couples (in $round)"

	# calcul nombre de couples en piste + nombre pré-qualifiés
	set nbPrequalified [nbPrequalified $f $round]
	set nbCouples [expr {[llength $couples] - $nbPrequalified}]
	set isSplit [expr {[string first "." $round] != -1}]

	# première page
	if {$gui(v:subten)} {
		set header "$msg(prt:heats) '$folder(round:$gui(v:round):name)' ($gui(v:dance))"
	} else {
		set header "$msg(prt:heats) '$folder(round:$gui(v:round):name)'"
	}
	set subtitle [print:ps:textNbToSelect]
	set c [print:ps:newpage $f $orientation -header $header $subtitle]
	set y $gui(t:y)
	set x $gui(t:l)

	# gestion des couples
	set nbPrequalified [nbPrequalified $f $round]
	set nb [expr {[llength $couples]-$nbPrequalified}]
	set start [expr {$nb-$nbPrequalified}]
	if {$computed} {
		# calcule les tailles des heats
		foreach {nb1 size1 nb2 size2} [computeHeats:size $nb $gui(pref:print:heats:size) $gui(pref:print:heats:type)] break
		set heat 1
		set total [expr {$nb1+$nb2}]
	} else {
		set total 1
	}

	# créé les deux liste : normal + pré-qualifiés
#TRACE "couples avant = $couples  //  $start"
	set prequalified [lrange $couples $nb end]
	set couples [lrange $couples 0 [expr $nb-1]]

	# nombre de couples en fonction orientation de la page
	if {$orientation == "-portrait"} {
		set max 12
	} else {
		set max 18
	}

	# paramètres graphiques
	set hMedium [expr {int($gui(prt:spacing:bold)*[font metrics "print:medium" -linespace])}]
	set wH 100
	set wC [expr {(($gui(t:r)-$gui(t:l))-$wH) / $max}]

	#---- affichage des couples / des heats
	if {$computed} {
		#-- pour chaque heat
		set index 0
		while {$total} {
			# extrait les couples
			if {$heat <= $nb1} {
				set newIndex [expr {$index+$size1}]
			} else {
				set newIndex [expr {$index+$size2}]
			}
			set couplesInHeat [lrange $couples $index [expr {$newIndex-1}]]
			set index $newIndex
			# paramètre
			set h [expr {$wC*[llength $couplesInHeat]}]
#TRACE "  <$heat> $couplesInHeat  /  [llength $couplesInHeat] lines"
			# teste si tient dans la page
			if {$y+$h > $gui(t:max)} {
				set c [print:ps:newpage $f $orientation -header $header]
				set y $gui(t:y)
			}
			# affiche
			$c create rectangle $x $y [expr {$x+$wH}] [expr {$y+$h}] \
					-fill $gui(color:print:light) -outline black
			$c create text [expr {$x+$wH/2}] [expr {$y+$h/3+1}] \
					-text "$msg(prt:Heat) $heat" -font print:medium
			$c create text [expr {$x+$wH/2}] [expr {$y+$h*3/4+1}] \
					-text "[llength $couplesInHeat] $msg(prt:couples2)" -font print:normal
			set xx [expr {$x+$wH}]
			set yy $y
			foreach couple $couplesInHeat {
				$c create rectangle $xx $yy [expr {$xx+$wC}] [expr {$yy+$wC}] \
						-outline black
				$c create text [expr {$xx+$wC/2}] [expr {$yy+$wC/2+1}] \
						-text $couple -font print:big
				# nom & club
				$c create rectangle [expr {$xx+$wC}] $yy [expr {$gui(t:r)}] [expr {$yy+$wC}] \
						-outline black
				print:ps:textInBox $c [couple:name $f $couple] \
						[expr {$xx+$wC}] $gui(t:r) [expr $yy+$wC/3+1] print:medium
				print:ps:textInBox $c [couple:school $f $couple] \
						[expr {$xx+$wC}] $gui(t:r) [expr $yy+$wC*2/3+1] print:normal
				# couple suivant (un par ligne)
				incr xx $wC
				incr yy $wC
				set xx [expr {$x+$wH}]
			}
			# heat suivante
			set y [expr {$y + $h + 10}]
			incr heat
			incr total -1
		}
	} else {
		#-- simple liste des couples
		set nbLeft $nb
		set nbPerPage [expr {($gui(t:max)-$y)/$wC}]
		set page 0
		while {$nbLeft > 0} {
			# nombre de couples à afficher sur cette page
			set nbTodo $nbPerPage
			if {$nbTodo > $nbLeft} {
				set nbTodo $nbLeft
			}
			incr nbLeft -$nbTodo
			# calcul la hauteur
			set h [expr {$wC*$nbTodo}]
			$c create rectangle $x $y [expr {$x+$wH}] [expr {$y+$h}] \
					-fill $gui(color:print:light) -outline black
			$c create text [expr {$x+$wH/2}] [expr {$y+$h/3+1}] \
					-text "$msg(prt:couples)" -font print:medium
			$c create text [expr {$x+$wH/2}] [expr {$y+$h*3/4+1}] \
					-text "$nb $msg(prt:couples2)" -font print:normal
			set xx [expr {$x+$wH}]
			set yy $y
			foreach couple [lrange $couples [expr $page*$nbPerPage] \
											[expr ($page+1)*$nbPerPage-1]] {
				$c create rectangle $xx $yy [expr {$xx+$wC}] [expr {$yy+$wC}] \
						-outline black
				$c create text [expr {$xx+$wC/2}] [expr {$yy+$wC/2+1}] \
						-text $couple -font print:big
				# nom & club
				$c create rectangle [expr {$xx+$wC}] $yy [expr {$gui(t:r)}] [expr {$yy+$wC}] \
						-outline black
				print:ps:textInBox $c [couple:name $f $couple] \
						[expr {$xx+$wC}] $gui(t:r) [expr $yy+$wC/3+1] print:medium
				print:ps:textInBox $c [couple:school $f $couple] \
						[expr {$xx+$wC}] $gui(t:r) [expr $yy+$wC*2/3+1] print:normal
				# couple suivant (un par ligne)
				incr xx $wC
				incr yy $wC
				set xx [expr {$x+$wH}]
			}

			# on se décale
			set y [expr {$y + $h + 10}]
			if {$y+$wC > $gui(t:max)} {
				set c [print:ps:newpage $f $orientation -header $header]
				set y $gui(t:y)
				incr page
			}
		}
	}
	#-- liste des couples préqualified
	if {$nbPrequalified > 0 && !$isSplit} {
		# teste si tient dans la page
		set y [expr {$y + 40}]
		if {$y+$h > $gui(t:max)} {
			set c [print:ps:newpage $f $orientation -header $header]
			set y $gui(t:y)
		}

		# on liste tous les couples
		set h [expr {$wC*$nbPrequalified}]
		$c create rectangle $x $y [expr {$x+$wH}] [expr {$y+$h}] \
				-fill $gui(color:print:light) -outline black
		$c create text [expr {$x+$wH/2}] [expr {$y+$h/3+1}] \
				-text "$msg(prt:prequalified)" -font print:medium
		$c create text [expr {$x+$wH/2}] [expr {$y+$h*3/4+1}] \
				-text "$nbPrequalified $msg(prt:couples2)" -font print:normal
		set xx [expr {$x+$wH}]
		set yy $y
		foreach couple $prequalified {
			$c create rectangle $xx $yy [expr {$xx+$wC}] [expr {$yy+$wC}] \
					-outline black
			$c create text [expr {$xx+$wC/2}] [expr {$yy+$wC/2+1}] \
					-text $couple -font print:big
			# nom & club
			$c create rectangle [expr {$xx+$wC}] $yy [expr {$gui(t:r)}] [expr {$yy+$wC}] \
					-outline black
			print:ps:textInBox $c [couple:name $f $couple] \
					[expr {$xx+$wC}] $gui(t:r) [expr $yy+$wC/3+1] print:medium
			print:ps:textInBox $c [couple:school $f $couple] \
					[expr {$xx+$wC}] $gui(t:r) [expr $yy+$wC*2/3+1] print:normal
			# couple suivant (un par ligne)
			incr xx $wC
			incr yy $wC
			set xx [expr {$x+$wH}]
		}
	}


	#---- liste des juges et des danses (si demandées)
	if {$gui(pref:print:heats:lists) == 0} {
		return
	}
	# taille de la liste
	set folder(dances:finale) $folder(dances)
	set maxWidth [expr {$gui(t:r)-$gui(t:l)}]
	set hNormal [expr int($gui(prt:spacing:normal)*[font metrics print:normal -linespace])]
	set hBold [expr int($gui(prt:spacing:bold)*[font metrics print:bold -linespace])]
	set h1j [expr {$hBold + $hNormal*[llength $folder(judges:$round)] + $gui(pref:print:medium:skipY)+10}]
	set h2j [expr {$hBold + $hNormal*([llength $folder(judges:$round)]+1)/2 + $gui(pref:print:medium:skipY)+10}]
	set h1d [expr {$hBold + $hNormal*[llength $folder(dances:$round)] + $gui(pref:print:medium:skipY)+10}]
	set h2d [expr {$hBold + $hNormal*([llength $folder(dances:$round)]+1)/2 + $gui(pref:print:medium:skipY)+10}]
	set withJudges [expr {$gui(pref:print:heats:lists) & 1}]
	set withDances [expr {$gui(pref:print:heats:lists) & 2}]
	if {$withJudges && $withDances} {
		set h1 [expr {$h1j > $h1d ? $h1j : $h1d}]
		set h2 $h1
#TRACE "with both  h1 = $h1 / $h1j / $h1d"
	} elseif {$withJudges} {
		set h1 $h1j
		set h2 $h2j
	} else {
		set h1 $h1d
		set h2 $h2d
	}
	 # recherche tient dans la page
	set cols 1
	if {$y+$h1 > $gui(t:max)} {
#TRACE "not fitting in one page"
		if {$y + $h2 > $gui(t:max)} {
			# si ne passe pas en double colonne, nouvelle page
#TRACE "    = new page"
			set c [print:ps:newpage $f $orientation -header $header]
			set y $gui(t:y)
		} elseif {$gui(pref:print:heats:lists) != 3} {
			# si pas juges+danses, on passe en double colonne
#TRACE "    = 2 cols"
			set cols 2
		}
	} else {
		# tient dans la page
		# on essaie de faire joli
		if {( (($gui(pref:print:heats:lists) & 1) && [llength $folder(judges:$round)] >= 10)
			  || (($gui(pref:print:heats:lists) & 2) && [llength $folder(dances)] >= 10))
					&& $gui(pref:print:heats:lists) != 3} {
			set y [expr {$gui(t:max)-$h2}]
			set cols 2
		} else {
			set y [expr {$gui(t:max)-$h1}]
		}
		set y [expr {$y + $gui(pref:print:medium:skipY)}]
	}
	# affichage
	set oldy $y
	if {$withJudges} {
		if {$cols == 1} {
			print:ps:judges $orientation $folder(judges:$round) print:normal print:bold \
						0 [expr {$maxWidth/2}] left 0.95
		} else {
			print:ps:judges $orientation $folder(judges:$round) print:normal print:bold \
						0 [expr {$maxWidth/2}] left 0.95 1
			set y1 $y
			set y $oldy
			print:ps:judges $orientation $folder(judges:$round) print:normal print:bold \
						[expr {$maxWidth/2}] [expr {$maxWidth/2}] right 0.95 2
		}
	}
	set y $oldy
	if {$withDances} {
		if {$cols == 1} {
			if {$withJudges} {
				print:ps:dances $f $round print:normal print:bold \
							[expr {$maxWidth/2}] [expr {$maxWidth/2}] right 0.95
			} else {
				print:ps:dances $f $round print:normal print:bold \
							0 [expr {$maxWidth/2}] left 0.95
			}
		} else {
			print:ps:dances $f $round print:normal print:bold \
						0 [expr {$maxWidth/2}] left 0.95 1
			set y1 $y
			set y $oldy
			print:ps:dances $f $round print:normal print:bold \
						[expr {$maxWidth/2}] [expr {$maxWidth/2}] right 0.95 2
		}
	}
}

proc skating::print:ps:textNbToSelect {} {
global msg
upvar f f round round folder folder couples couples

	# calcul nombre de couples en piste + nombre pré-qualifiés
	set nbPrequalified [nbPrequalified $f $round]
	set nbCouples [expr {[llength $couples] - $nbPrequalified}]
	set isSplit [expr {[string first "." $round] != -1}]

	#---- finale
	if {$round == "finale"} {
		return "$nbCouples $msg(prt:couples2)"
	}

	#---- round
	if {$isSplit} {
		set text "$msg(rescue)"
	} else {
		set text "$msg(select)"
	}
	set nb [expr {$folder(round:$round:nb)-$nbPrequalified}]
	set text "$text $nb $msg(among) $nbCouples $msg(competing)"
	if {$nbPrequalified && !$isSplit} {
		append text " "
		if {$folder(round:$round:split)} {
			set format $msg(prt:explainPrequalifSplit)
		} else {
			set format $msg(prt:explainPrequalif)
		}
		append text [format $format \
								$nbPrequalified \
								$folder(round:$round:nb) \
								$folder(round:$round.2:nb) \
								[expr {$folder(round:$round:nb)+$folder(round:$round.2:nb)}] \
								[llength $couples] \
								$folder(round:[rounds:next $f $round]:name)]
	}

	return $text
}

#----------------------------------------------------------------------------------------------

proc skating::print:ps:marksSheets:landscape:panel {} {
global msg
variable gui
variable event
upvar folder folder f f data data c c couples couples judge judge round round
upvar dance dance dances dances


	set y $data(y)
	set w [expr {$data(right)-$data(left)}]
	set nbCouples [llength $couples]
	if {$gui(pref:print:sheets:compact)} {
		set what ""
	} else {
		set what "$dance  "
	}

	#---- header
	# nom du juge
	$c create rectangle $data(left) $y [expr {$data(left)+$w*2/3}] [expr {$y+$data(hJudge)}] \
			-fill $gui(color:print:dark) -width $data(width)
	$c create rectangle $data(left) $y [expr {$data(left)+1.3*$data(hJudge)}] [expr {$y+$data(hJudge)}] \
			-fill $gui(color:print:dark) -width $data(width)
	$c create text [expr {$data(left)+0.65*$data(hJudge)}] [expr {$y+$data(hJudge)/2+1}] \
			-text $judge -font $data(font:judge)
	print:ps:textInBox $c $event(name:$judge) \
			[expr {$data(left)+$data(hJudge)*1.4}] [expr {$data(left)+$w*2/3}] \
			[expr $y+$data(hJudge)/2+1] $data(font:judge)
	# infos sur la compétition
	$c create rectangle [expr {$data(left)+$w*2/3}] $y $data(right) [expr {$y+$data(hJudge)}] -width $data(width)
	set text_1 [manage:attributes:parseFormat $f $gui(pref:format:text:mark_l_f1) $round $what]
	set text_2 [manage:attributes:parseFormat $f $gui(pref:format:text:mark_l_f2) $round $what]
	set h [expr {$data(hJudge)/2}]
	print:ps:textInBox $c $text_1 [expr {$data(left)+$w*2/3}] $data(right) [expr $y+$h/2+1] \
			$data($gui(pref:format:font:mark_l_f1))
	print:ps:textInBox $c $text_2 [expr {$data(left)+$w*2/3}] $data(right) [expr $y+$h*3/2+1] \
			$data($gui(pref:format:font:mark_l_f2))
	# saut de ligne
	set y [expr {$y + $data(hJudge)+2}]

	#---- nom de la compétition / round
	foreach line {h1 h2} {
		set text_l [manage:attributes:parseFormat $f $gui(pref:format:text:mark_l_${line}_l) $round $what]
		set text_c [manage:attributes:parseFormat $f $gui(pref:format:text:mark_l_${line}_c) $round $what]
		set text_r [manage:attributes:parseFormat $f $gui(pref:format:text:mark_l_${line}_r) $round $what]
		if {$text_l != "" || $text_c != "" || $text_r != ""} {
			print:ps:textInBox $c $text_l $data(left) $data(right) [expr {$y+$data(hFolder)/2+1}] \
					$data($gui(pref:format:font:mark_l_${line}_l)) left
			print:ps:textInBox $c $text_c $data(left) $data(right) [expr {$y+$data(hFolder)/2+1}] \
					$data($gui(pref:format:font:mark_l_${line}_c)) center
			print:ps:textInBox $c $text_r $data(left) $data(right) [expr {$y+$data(hFolder)/2+1}] \
					$data($gui(pref:format:font:mark_l_${line}_r)) right
			# saut de ligne
			set y [expr {$y + $data(hFolder)}]
		}
	}
	set y [expr {$y + $data(hSkip)}]

	#==== la zone de saisie
	if {$round == "finale"} {
		#---- liste pour les places (FINALE)
		skating::print:ps:marksSheets:both:finale
	} else {
		#---- les boîtes pour les judges (ROUND)
		skating::print:ps:marksSheets:both:rounds
	}
}

proc skating::print:ps:marksSheets:portrait:panel {} {
global msg
variable gui
variable event
upvar f f folder folder data data c c couples couples judge judge round round
upvar dance dance dances dances


	set y $data(y)
	set w [expr {$data(right)-$data(left)}]
	set nbCouples [llength $couples]
	if {$gui(pref:print:sheets:compact)} {
		set what ""
	} else {
		set what "$dance  "
	}

	#---- header
	# nom du juge
	$c create rectangle $data(left) $y $data(right) [expr {$y+$data(hJudge)}] \
			-fill $gui(color:print:dark) -width $data(width)
	$c create rectangle $data(left) $y \
			[expr {$data(left)+1.3*$data(hJudge)}] [expr {$y+$data(hJudge)}] \
			-fill $gui(color:print:dark) -width $data(width)
	$c create text [expr {$data(left)+0.65*$data(hJudge)}] [expr {$y+$data(hJudge)/2+1}] \
			-text $judge -font $data(font:judge)
	print:ps:textInBox $c $event(name:$judge) \
			[expr {$data(left)+$data(hJudge)*1.4}] $data(right) \
			[expr {$y+$data(hJudge)/2+1}] $data(font:judge)
	# infos sur la compétition (en bas de page)
	$c create rectangle $data(left) [expr {$data(bottom)-$data(hTitle)}] \
			$data(right) $data(bottom) -width $data(width)
	set text_l [manage:attributes:parseFormat $f $gui(pref:format:text:mark_p_f_l) $round $what]
	set text_c [manage:attributes:parseFormat $f $gui(pref:format:text:mark_p_f_c) $round $what]
	set text_r [manage:attributes:parseFormat $f $gui(pref:format:text:mark_p_f_r) $round $what]
	print:ps:textInBox $c $text_l $data(left) [expr {$data(left)+$w*3/4}] \
			[expr {$data(bottom)-$data(hTitle)/2}] $data($gui(pref:format:font:mark_p_f_l)) left
	print:ps:textInBox $c $text_c $data(left) $data(right) \
			[expr {$data(bottom)-$data(hTitle)/2}] $data($gui(pref:format:font:mark_p_f_c)) center
	print:ps:textInBox $c $text_r [expr {$data(left)+$w*3/4}] $data(right) \
			[expr {$data(bottom)-$data(hTitle)/2}] $data($gui(pref:format:font:mark_p_f_r)) right
	# saut de ligne
	set y [expr {$y + $data(hJudge)}]

	#---- nom de la compétition / round
	foreach line {h1 h2} {
		set text_l [manage:attributes:parseFormat $f $gui(pref:format:text:mark_p_${line}_l) $round $what]
		set text_c [manage:attributes:parseFormat $f $gui(pref:format:text:mark_p_${line}_c) $round $what]
		set text_r [manage:attributes:parseFormat $f $gui(pref:format:text:mark_p_${line}_r) $round $what]
		if {$text_l != "" || $text_c != "" || $text_r != ""} {
			$c create rectangle $data(left) $y $data(right) [expr {$y+$data(hFolder)}]
			print:ps:textInBox $c $text_l $data(left) $data(right) [expr {$y+$data(hFolder)/2+1}] \
					$data($gui(pref:format:font:mark_p_${line}_l)) left
			print:ps:textInBox $c $text_c $data(left) $data(right) [expr {$y+$data(hFolder)/2+1}] \
					$data($gui(pref:format:font:mark_p_${line}_c)) center
			print:ps:textInBox $c $text_r $data(left) $data(right) [expr {$y+$data(hFolder)/2+1}] \
					$data($gui(pref:format:font:mark_p_${line}_r)) right
			# saut de ligne
			set y [expr {$y + $data(hFolder)}]
		}
	}
	set y [expr {$y + $data(hSkip)}]

	#==== la zone de saisie
	if {$round == "finale"} {
		#---- liste pour les places (FINALE)
		skating::print:ps:marksSheets:both:finale
	} else {
		#---- les boîtes pour les judges (ROUND)
		if {$gui(pref:print:sheets:compact)} {
			skating::print:ps:marksSheets:both:roundsCompact
		} else {
			skating::print:ps:marksSheets:both:rounds
		}
	}
}

proc skating::print:ps:marksSheets:both:rounds {} {
global msg
variable gui
variable event
upvar f f folder folder data data c c couples couples dance dance judge judge round round
upvar nbCouples nbCouples y y w w

	# initialisation paramètres
	set x $data(left)
	set index 0
	set extra 0
	set heat [inHeat $nbCouples $gui(pref:print:heats:size) $gui(pref:print:heats:type) 0]
	# ajout de cases pour les retardataires
	set spareboxes [list ]
	for {set i 0} {$i < $gui(pref:print:sheets:spareBoxes)} {incr i} {
		lappend spareboxes ""
	}
	# pour chaque couple
	foreach couple [concat $couples $spareboxes] {
		# vérifie le style
		if {$gui(pref:print:heats:mode) == "auto"
				&& [inHeat $nbCouples $gui(pref:print:heats:size) $gui(pref:print:heats:type) $index] != $heat} {
			set heat [inHeat $nbCouples $gui(pref:print:heats:size) $gui(pref:print:heats:type) $index]
			set extra [expr {!$extra}]
		}
		# la boite
		set id [$c create rectangle $x $y [expr {$x+$data(size)}] [expr {$y+$data(size)}]]
		if {$couple == ""} {
			# nothing
		} elseif {$extra} {
			$c itemconfigure $id -fill $gui(color:print:light)
			$c create text [expr {$x+$data(size)/2}] [expr {$y+$data(size)/2+1}] \
					-text $couple -font $data(fontItalic)
		} else {
			$c create text [expr {$x+$data(size)/2}] [expr {$y+$data(size)/2+1}] \
					-text $couple -font $data(font)
		}
		# suivant
		incr index
		set x [expr {$x+$data(size)}]
		if {$x >= ($data(left)+$data(w)*0.99)} {
			set x $data(left)
			set y [expr {$y+$data(size)}]
		}
	}
	# zone/grille de saisie (optionnelle)
	if {$gui(pref:print:inputGrid)} {
		if {$x != $data(left)} {
			set y [expr {$y+$data(size)}]
		}
		set x $data(left)
		set y [expr {$y+$gui(pref:print:small:skipY)}]
		set ySelect [expr {$y+$data(hFolder)/2}]
		set y [expr {$y+$data(hFolder)*3/2}]
		for {set i 0} {$i < $folder(round:$round:nb)} {incr i} {
			# la boite
			$c create rectangle $x $y [expr {$x+$data(size)}] [expr {$y+$data(size)}]
			set x [expr {$x+$data(size)}]
			if {$x >= ($data(left)+$data(w)*0.99)} {
				set x $data(left)
				set y [expr {$y+$data(size)}]
			}
		}
	} else {
		if {$x != $data(left)} {
			set y [expr {$y+$data(size)}]
		}
		set ySelect [expr {$y+$data(hFolder)}]
	}
	# imprimer nombre à sélectionner
	set nb [expr {$folder(round:$round:nb)-[nbPrequalified $f $round]}]
	if {[string first "." $round] != -1} {
		set text "$msg(rescue) $nb $msg(among) $nbCouples $msg(remaining)"
	} else {
		set text "$msg(select) $nb $msg(among) $nbCouples $msg(competing)"
	}
	print:ps:textInBox $c $text $data(left) $data(right) $ySelect $data(font:folder) center

	# zone pour la signature
	if {$gui(pref:print:sheets:sign)} {
		set y [expr {$data(bottom)-$data(hSign)}]
		set x1 [expr {$data(left)+($data(right)-$data(left))/2}]
		set x2 $data(right)
		$c create line $x1 $y $x2 $y
		$c create text $x1 $y -text $msg(prt:sign) -font print:small -anchor nw
	}
}

proc skating::print:ps:marksSheets:both:roundsCompact {} {
global msg
variable gui
variable event
upvar folder folder data data c c couples couples dance dances judge judge round round
upvar nbCouples nbCouples y y w w

	# initialisation paramètres
	set x $data(left)
	# ajout de cases pour les retardataires
	set spareboxes [list ]
	for {set i 0} {$i < $gui(pref:print:sheets:spareBoxes)} {incr i} {
		lappend spareboxes ""
	}
	# pour chaque danse
	foreach dance $dances {
		# affiche la dance
		set x $data(left)
		$c create text $x [expr {$y+$data(hFolder)/2+1}] \
				-text $dance -font $data(font:folder) -anchor w
		set y [expr {$y+$data(hFolder)*1.2}]

		# pour chaque couple
		set index 0
		set extra 0
		set heat [inHeat $nbCouples $gui(pref:print:heats:size) $gui(pref:print:heats:type) 0]
		foreach couple [concat $couples $spareboxes] {
			# vérifie le style
			if {$gui(pref:print:heats:mode) == "auto"
					&& [inHeat $nbCouples $gui(pref:print:heats:size) $gui(pref:print:heats:type) $index] != $heat} {
				set heat [inHeat $nbCouples $gui(pref:print:heats:size) $gui(pref:print:heats:type) $index]
				set extra [expr {!$extra}]
			}
			# la boite
			set id [$c create rectangle $x $y [expr {$x+$data(size)}] [expr {$y+$data(size)}]]
			if {$couple == ""} {
				# spare box -- nothing to do
			} elseif {$extra} {
				$c itemconfigure $id -fill $gui(color:print:light)
				$c create text [expr {$x+$data(size)/2}] [expr {$y+$data(size)/2+1}] \
						-text $couple -font $data(fontItalic)
			} else {
				$c create text [expr {$x+$data(size)/2}] [expr {$y+$data(size)/2+1}] \
						-text $couple -font $data(font)
			}
			# suivant
			incr index
			set x [expr {$x+$data(size)}]
			if {$x >= ($data(left)+$data(w)*0.99)} {
				set x $data(left)
				set y [expr {$y+$data(size)}]
			}
		}
		# zone/grille de saisie (optionnelle)
		if {$gui(pref:print:inputGrid)} {
			if {$x != $data(left)} {
				set y [expr {$y+$data(size)}]
			}
			set x $data(left)
			set y [expr {$y+$data(size)/5}]
			for {set i 0} {$i < $folder(round:$round:nb)} {incr i} {
				# la boite
				$c create rectangle $x $y [expr {$x+$data(size)}] [expr {$y+$data(size)}]
				set x [expr {$x+$data(size)}]
				if {$x >= ($data(left)+$data(w)*0.99)} {
					set x $data(left)
					set y [expr {$y+$data(size)}]
				}
			}
		}

		# re-sync y sur une nouvelle ligne
		if {$x != $data(left)} {
			set y [expr {$y+$data(size)}]
		}
		# danse suivante
		set y [expr {$y+$data(hFolder)*0.8}]
	}

	# imprimer nombre à sélectionner
	if {[string first "." $round] != -1} {
		set text "$msg(rescue) $folder(round:$round:nb) $msg(among) $nbCouples $msg(remaining)"
	} else {
		set text "$msg(select) $folder(round:$round:nb) $msg(among) $nbCouples $msg(competing)"
	}
	set ySelect [expr {$y+$data(hFolder)}]
	print:ps:textInBox $c $text $data(left) $data(right) $ySelect $data(font:folder) center

	# zone pour la signature
	if {$gui(pref:print:sheets:sign)} {
		set y [expr {$data(bottom)-$data(hSign)}]
		set x1 [expr {$data(left)+($data(right)-$data(left))/2}]
		set x2 $data(right)
		$c create line $x1 $y $x2 $y
		$c create text $x1 $y -text $msg(prt:sign) -font print:small -anchor nw
	}
}

proc skating::print:ps:marksSheets:both:finale {} {
global msg
variable gui
variable event
upvar folder folder data data c c couples couples dance dance judge judge round round
upvar nbCouples nbCouples y y

	# initialisation des paramètres
	set yy $y
	set maxy [expr {$data(bottom)-$data(hTitle)}]
	if {$y+$data(nb)*$data(size) > $maxy} {
		set x [expr {$data(left)+($data(right)-$data(left)-4*$data(size)-$data(hBigSkip))/2}]
		set split 1
	} else {
		if {$gui(pref:print:sheets:compact)} {
			set x [expr {$data(left)+($data(right)-$data(left)-(1+[llength $dance])*$data(size))/2}]
		} else {
			set x [expr {$data(left)+($data(right)-$data(left)-2*$data(size))/2}]
		}
		set split 0
	}

		set i 1

	# zone avec le nom des danses -- si compact
	if {$gui(pref:print:sheets:compact)} {
		set xx [expr {$x+$data(size)}]
		foreach d $dance {
			$c create rectangle $xx $y [expr {$xx+$data(size)}] [expr {$y+$data(size)}]
			$c create text [expr {$xx+$data(size)/2}] [expr {$y+$data(size)/2+1}] \
					-text [firstLetters $d] -font $data(font)
			set xx [expr {$xx+$data(size)}]
		}
		# on se décale d'une ligne vers le bas
		set y [expr {$y+$data(size)}]
	}

	# pour chaque couple -- zone de saisie
	set i 1
	foreach couple $couples {
		# le numéro du couple
		$c create rectangle $x $y [expr {$x+$data(size)}] [expr {$y+$data(size)}]
		$c create text [expr {$x+$data(size)/2}] [expr {$y+$data(size)/2+1}] \
				-text $couple -font $data(font)
		# une(des) case(s) vide(s) pour la place
		if {$gui(pref:print:sheets:compact)} {
			# toutes les danses sur une page
			set xx [expr {$x+$data(size)}]
			foreach d $dance {
				$c create rectangle $xx $y [expr {$xx+$data(size)}] [expr {$y+$data(size)}]
				set xx [expr {$xx+$data(size)}]
			}
		} else {
			# toutes les danses sur une page 
			$c create rectangle [expr {$x+$data(size)}] $y \
					[expr {$x+2*$data(size)}] [expr {$y+$data(size)}]
		}
		# suivant
		incr i
		set y [expr {$y+$data(size)}]
		if {$split && $i > ($data(nb)+1)/2} {
			set x [expr {$x+2*$data(size)+$data(hBigSkip)}]
			set y $yy
			set split 0
		}
	}

	# zone pour la signature
	if {$gui(pref:print:sheets:sign)} {
		set y [expr {$data(bottom)-$data(hSign)}]
		set x1 [expr {$data(left)+($data(right)-$data(left))/2}]
		set x2 $data(right)
		$c create line $x1 $y $x2 $y
		$c create text $x1 $y -text $msg(prt:sign) -font print:small -anchor nw
	}
}

#----------------------------------------------------------------------------------------------

proc skating::print:ps:marksSheets:boxesSize {nb font w h inputGrid nbToRecall} {
variable gui
upvar y y round round data data dances dances

#puts "skating::print:ps:marksSheets:boxesSize {$nb $font $w $h $inputGrid $nbToRecall}"

	# calcule la taille disponible
	set c [canvas .c]
	set id [$c create text 0 0 -anchor w -text 999 -font $font]
	foreach {x1 - x2 -} [$c bbox $id] break
	$c delete $id
	set size [expr {int(1.1*($x2-$x1))}]
	# détruit canvas temporaire
	destroy $c

	#==== pour la finale, cas particulier
	if {$round == "finale"} {
		if {$gui(pref:print:sheets:compact)} {
			#---- toutes les danses sur une page
			# colonnes = 1 N° + n danses
			# lignes = 1 nom danse + n (2 à 9) couples
			set nbPerRow [expr {int($w/$size)}]
			set size [expr {1.0*$w/$nbPerRow}]
			set nbRows [expr {int(1.0*$h/$size)}]
			if {$nbPerRow < (1+[llength [lindex $dances 0]]) || $nbRows < (1+$nb)} {
				set size 0
			}
			return [list $nbPerRow $size]

		} else {
			#---- chaque danse possède sa propre page
			if {4*$size+$data(hBigSkip) > $w} {
				set size 0
			}
			if {($nb+1)/2*$size > $h} {
				set size 0
			}
			return [list 4 $size]
		}
	}

	#==== pour les autres rounds
	# retourne le nombre de boîte pour la fonte donnée
	if {$gui(pref:print:sheets:compact)} {
		#---- toutes les danses sur une page

		# une ligne + 1/2 haut + 1/2 bas pour afficher le nom de la danse
		set hDance [expr {2*$data(hFolder)}]
		set nbDances [llength [lindex $dances 0]]

		set nbPerRow [expr {int($w/$size)}]
		set size [expr {1.0*$w/$nbPerRow}]
		if {$inputGrid} {
			set hAvailable [expr {$h-$data(hFolder)*3/2 \
									-($size/5+$hDance)*$nbDances}]
		} else {
			set hAvailable [expr {$h-$data(hFolder)*3/2 \
									-$hDance*$nbDances}]
		}
		set nbRows [expr {int(1.0*$hAvailable/$size)}]
		# pour les couples
		set nbRowsCouples [expr {ceil(1.0*$nb/$nbPerRow)}]
		# pour les repris
		if {$inputGrid} {
			set nbRowsRecall [expr {ceil(1.0*$nbToRecall/$nbPerRow)}]
		} else {
			set nbRowsRecall 0
		}
#TRACE "nbRows = $nbRows  //  $nbRowsCouples / $nbRowsRecall  //  $nbDances  //  size=$size"
		# test si ok
		if {($nbRowsCouples + $nbRowsRecall)*$nbDances > $nbRows} {
			# NOK
			set size 0
		}

	} else {
		#---- chaque danse possède sa propre page

#puts "nb=$nb / y=$y / $w $h / size=$size / [expr {1.0*$w/$size}] col * [expr {1.0*$h/$size}] row = [expr {int($w/$size) * int($h/$size)}]"
#	set nbBoxes [expr {int(1.0*$w/$size-0.5) * int(1.0*$h/$size-0.5)}]

		# ajuste à la taille de la ligne
		if {$inputGrid} {
			set nbPerRow [expr {int($w/$size)}]
			set size [expr {1.0*$w/$nbPerRow}]
			set nbRows [expr {int(1.0*($h-$gui(pref:print:small:skipY)-$data(hFolder)*3/2)/$size)}]
			# pour les couples
			set nbRowsCouples [expr {ceil(1.0*$nb/$nbPerRow)}]
			set nbRowsRecall  [expr {ceil(1.0*$nbToRecall/$nbPerRow)}]
			# pour les repris
			# test si ok
			if {$nbRowsCouples + $nbRowsRecall > $nbRows} {
				# NOK
				set size 0
			}
		} else {
			set nbPerRow [expr {int($w/$size)}]
			set size [expr {1.0*$w/$nbPerRow}]
			set nbRows [expr {int(1.0*$h/$size)}]
			if {$nbPerRow * $nbRows < $nb} {
				# NOK
				set size 0
			}
		}
	}

	return [list $nbPerRow $size]
}




#=================================================================================================
#
#	Helpers
#
#=================================================================================================

proc skating::print:ps:fullTextInBox {c text x1 x2 y font {anchor left}} {
	append text " "
	set id [$c create text 0 0 -text ""]
	set ok 0
	while {!$ok} {
		$c delete $id
		set text [string range $text 0 end-1]
		if {$anchor == "left"} {
			set id [$c create text [expr {$x1+5}] $y -anchor w -text $text -font $font]
			set ok [expr {[lindex [$c bbox $id] 2] <= $x2}]
		} elseif {$anchor == "center"} {
			set id [$c create text [expr {$x1+($x2-$x1)/2}] $y -anchor c -text $text -font $font]
			set ok 1
		} else {
			set id [$c create text [expr {$x2-5}] $y -anchor e -text $text -font $font]
			set ok [expr {[lindex [$c bbox $id] 0] >= $x1}]
		}
	}
}

proc skating::print:ps:textInBox {c text x1 x2 y font {anchor left}} {
	set text "[string trim $text] "
	set id [$c create text 0 0 -text ""]
	set ok 0
	while {!$ok} {
		$c delete $id
		set text [string range $text 0 end-1]
		if {$anchor == "left"} {
			set id [$c create text [expr {$x1+5}] $y -anchor w -text $text -font $font]
			set ok [expr {[lindex [$c bbox $id] 2] <= $x2}]
		} elseif {$anchor == "center"} {
			set id [$c create text [expr {$x1+($x2-$x1)/2}] $y -anchor c -text $text -font $font]
			set ok 1
		} else {
			set id [$c create text [expr {$x2-5}] $y -anchor e -text $text -font $font]
			set ok [expr {[lindex [$c bbox $id] 0] >= $x1}]
		}
	}
}

proc skating::print:ps:mark {c skipZeros mark total x y hNormal} {
	if {($skipZeros && $mark == 0) || $mark == -1} {
		return
	}
	incr y
	if {$total < 1} {
		$c create text $x [expr $y+$hNormal/2] -text $mark -font print:normal
	} else {
		set id [$c create text $x [expr $y+$hNormal/2] -text $mark -font print:normal]
		if {[expr int($total)] == $total} {
			set total [expr int($total)]
		}
		set x [expr [lindex [$c bbox $id] 2]-1]
		incr y
		$c create text $x $y -text $total -font print:subscript -anchor nw
	}
}

proc skating::print:ps:textWidth {c text font} {
	set id [$c create text 0 0 -anchor w -text $text -font $font]
	set width [lindex [$c bbox $id] 2]
	$c delete $id
	return $width	
}
