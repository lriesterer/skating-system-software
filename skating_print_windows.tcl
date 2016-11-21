##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Impression directe sous Windows
#
#=================================================================================================


proc skating::print:windows:print {} {
global msg
variable gui
variable paperSize


	# sélection d'une imprimante
	set hdc [printer dialog select]
	if {[lindex $hdc 1] == 0} {
		# User has canceled printing
		return
	}
	set hdc [lindex $hdc 0]

	# vérification du handle
	if {[string match "?" $hdc] || [string match 0x0 $hdc]} {
		catch {printer close}
		tk_messageBox -icon "error" -type ok -default ok \
				-title $msg(dlg:error) -message "$msg(dlg:openPrinter)"
		return
	}

	# début d'impression : tâche dans le spooler
	printer job start -name "Skating System Software"

	# GDI mapping
	variable deltaY
	set deltaY 1
	set width 0
	set offset {}
##set xxx ""
    foreach attrpair [printer attr] {
##lappend xxx $attrpair
		set key [lindex $attrpair 0]
		set val [lindex $attrpair 1]
		switch -exact $key {
		  "device"			{ set val [string tolower $val]
							  if {[string match "*laser*" $val]} {
								  set deltaY 2
							  } }
		}
    }
##tk_messageBox -type ok -default ok -title DEBUG -message [join $xxx \n]


	# taille du papier
	set paper [string tolower $gui(pref:print:paper)]
	set w(-portrait)  [lindex $paperSize($paper) 0]
	set h(-portrait)  [lindex $paperSize($paper) 1]
	set w(-landscape) [lindex $paperSize($paper) 1]
	set h(-landscape) [lindex $paperSize($paper) 0]

	#----------------------------
	# gestion de copies multiples
	for {set i 0} {$i < $gui(v:print:copies)} {incr i} {
		# version démo : 1 page seulement
		if {[license check] == 0} {
			tk_messageBox -icon info -type ok -default ok -title License \
					-message $msg(dlg:demoPrint)
			# impression de la première page
			set page [lindex $gui(v:print:pages) [expr {$gui(v:print:from)-1}]]
			set orient [lindex $gui(v:print:pages:orientation) [expr {$gui(v:print:from)-1}]]
			printer page start $orient
			printer page size $w($orient) $h($orient)
	        gdi text $hdc 50  50 -anchor nw -fill #DDDDDD -font {Arial 72 bold} -text "Unregistred"
	        gdi text $hdc 50 300 -anchor nw -fill #DDDDDD -font {Arial 72 bold} -text "Unregistred"
	        gdi text $hdc 50 550 -anchor nw -fill #DDDDDD -font {Arial 72 bold} -text "Unregistred"
	        gdi text $hdc 50 800 -anchor nw -fill #DDDDDD -font {Arial 72 bold} -text "Unregistred"
			print:windows:canvas $hdc $page
			printer page end

		} else {
			# dialogue d'avancement
			progressBarInit $msg(printing) $msg(printing:msg) "" [llength $gui(v:print:pages)]
			# impression des différentes pages
			foreach page [lrange $gui(v:print:pages) [expr {$gui(v:print:from)-1}] [expr {$gui(v:print:to)-1}]] \
					orient [lrange $gui(v:print:pages:orientation) [expr {$gui(v:print:from)-1}] [expr {$gui(v:print:to)-1}]] {
				printer page start $orient
				printer page size $w($orient) $h($orient)
				print:windows:canvas $hdc $page
				printer page end
				# progress bar
				progressBarUpdate 1
			}
			progressBarEnd
		}
	}

	# fin de l'impression
	printer job end
	printer close
}

#-------------------------------------------------------------------------------------------------

proc skating::print:windows:canvas {hdc c} {
	# impression des items
	foreach id [$c find all] {
		set type [$c type $id]

		if {$type == "line"} {
			#---- line ----
			set color [$c itemcget $id -fill]
			set coords [$c coords $id]
			set width [$c itemcget $id -width]
			eval "gdi line $hdc $coords -fill [list $color] -width $width"

		} elseif {$type == "rectangle"} {
			#---- rectangle ----
			set fcolor [$c itemcget $id -fill]
			#if {$fcolor == ""} {set color black}
			set ocolor [$c itemcget $id -outline]
			#if {$ocolor == ""} {set ocolor black}
			set coords  [$c coords $id]
			if {[lindex $coords 3] == $skating::gui(v:print:height)} {
				continue
			}
			set width [$c itemcget $id -width]
			eval "gdi rectangle $hdc $coords -width $width \
							-fill [list $fcolor] -outline [list $ocolor]"

		} elseif {$type == "text"} {
			#---- text ----
			set color [$c itemcget $id -fill]
			set text [$c itemcget $id -text]
			if {$text == ""} {
				continue
			}

			set font [$c itemcget $id -font]
			if {[llength $font] > 1} {
				set weight [lindex $font 2]
				if {$weight == ""} {
					set weight "normal"
				}
			} else {
				set weight [font configure $font -weight]
				set font [list [font configure $font -family] [font configure $font -size] \
							   [font configure $font -weight]]
			}

			set coords [$c coords $id]
			if {$weight == "normal"} {
				variable deltaY
				set coords [list [lindex $coords 0] [expr [lindex $coords 1]-$deltaY]]
			} else {
				set coords [list [lindex $coords 0] [expr [lindex $coords 1]-1]]
			}
			set anchor [$c itemcget $id -anchor]

			set width [$c itemcget $id -width]
			if {$width} {
				eval "gdi text $hdc $coords -text [list $text] -font [list $font] -anchor $anchor -width $width"
			} else {
				eval "gdi text $hdc $coords -text [list $text] -font [list $font] -anchor $anchor"
			}

		} else {
			# skipping item
		}
	}
}
