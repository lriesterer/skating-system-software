##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer


bind Canvas <MouseWheel> {
    %W yview scroll [expr {- (%D / 120) * 4}] units
}

if {[string equal "unix" $tcl_platform(platform)]} {
    bind Canvas <4> {
        if {!$tk_strictMotif} {
            %W yview scroll -5 units
        }
    }
    bind Canvas <5> {
        if {!$tk_strictMotif} {
            %W yview scroll 5 units
        }
    }
}

#-------------------------------------------------------------------------------------------------

proc reverse {list} {
	set r {}
	foreach entry $list {
		set r "$entry $r"
	}
	return $r
}

#  proc unique {list} {
#  	set idx 0
#  	set unique {}
#  	while {$idx < [llength $list]} {
#  		set ref [lindex $list $idx]
#  		lappend unique $ref
#  		incr idx
#  		while {[lindex $list $idx] == $ref} {
#  			incr idx
#  		}
#  	}
#  	set unique
#  }

#-------------------------------------------------------------------------------------------------

proc centerDialog {top dialog {dw -1} {dh -1}} {
	wm withdraw $dialog
	if {$top == "."} {
		set tw [winfo screenwidth .]
		set th [winfo screenheight .]
	} else {
		set tw [winfo width $top]
		set th [winfo height $top]
	}
	update idletasks
	if {$dw == -1} {
		set dw [winfo reqwidth $dialog]
	}
	if {$dh == -1} {
		set dh [winfo reqheight $dialog]
	}
	set x [expr [winfo vrootx $top]+($tw-$dw)/2]
	if {$x < 0} {
		set x 0
	}
	set y [expr [winfo vrooty $top]+($th-$dh)/2]
	if {$y < 0} {
		set y 0
	}

	global tcl_platform
	if {$tcl_platform(platform) == "windows"} {
		wm geometry $dialog +$x+$y
#		wm resizable $dialog 0 0
		update
		wm deiconify $dialog
		after idle "raise $dialog"
	} else {
		wm geometry $dialog +$x+$y
		wm deiconify $dialog
	}
}

#-------------------------------------------------------------------------------------------------

proc progressBarInit {title msg text size} {
global progressBarOk progressBarX progressBarDX progressBarID


	set progressBarOk [expr {$size > 3 || [string length $text]}]
	if {$progressBarOk} {
		destroy .dialog
		toplevel .dialog
		wm title .dialog $title
		label .dialog.l -text $msg -anchor w
		canvas .dialog.c -width 300 -height 24 -bd 2 -relief groove
		pack .dialog.l -padx 5 -pady 5 -anchor w
		pack .dialog.c -padx 5 -pady 5
		# texte pour les pages
		if {$text != ""} {
			set f [frame .dialog.p -bd 0]
			pack $f -padx 5 -pady 5 -anchor w
			pack [label $f.t -text "$text "] -side left
			pack [label $f.tt -textvariable ::progressBarText] -side left
			pack [label $f.dot -text "."] -side left
		}
		# variables
		set ::progressBarText 0
		set progressBarID [.dialog.c create rectangle 0 0 0 26 -fill blue -outline blue]
		set progressBarDX [expr {300/$size}]
		set progressBarX 0
		# affichage
		centerDialog .top .dialog
		update
	}
}

proc progressBarAdd {amount} {
	catch {
		set nb [expr {$::progressBarX/$::progressBarDX}]
		set size [expr {300/$::progressBarDX}]
		incr size $amount
		set ::progressBarDX [expr {300/$size}]
		set ::progressBarX [expr {$nb*$::progressBarDX}]
		.dialog.c coords $::progressBarID 0 0 $::progressBarX 26
		update
	}
}

proc progressBarUpdate {amount {total 0}} {
	if {$::progressBarOk} {
		if {$total == 0} {
			incr ::progressBarX $::progressBarDX
		} else {
			set ::progressBarX [expr {300.0*$amount/$total}]
		}
		.dialog.c coords $::progressBarID 0 0 $::progressBarX 26
		update
	}
}

proc progressBarIncrText {} {
	if {$::progressBarOk} {
		incr ::progressBarText
		update
	}
}

proc progressBarEnd {} {
	destroy .dialog
}
#-------------------------------------------------------------------------------------------------

proc waitDialog:open {text} {
global msg

	destroy .dialog
	toplevel .dialog
	wm title .dialog $msg(dlg:information)
	label .dialog.l -anchor w -width 25 -text $text
	pack .dialog.l -padx 10 -pady 10
	centerDialog .top .dialog
	tkwait visibility .dialog.l
	update
}

proc waitDialog:close {} {
	destroy .dialog
}

proc waitDialog:raise {} {
	raise .dialog
}

#-------------------------------------------------------------------------------------------------

proc repeatStr {str count} {
	set result ""
	for {set i 0} {$i < $count} {incr i} {
		append result $str
	}
	return $result
}

proc firstLetters {words} {
variable ::skating::gui

	if {[info exists gui(pref:dances:short)]} {
		set idx [lsearch $gui(pref:dances) $words]
		if {$idx != -1} {
			set result [lindex $gui(pref:dances:short) $idx]
			if {$result != ""} {
				return $result
			}
		}
	}

	set label ""
	foreach word $words {
		append label [string toupper [string range $word 0 0]]
	}
	return $label
}

#-------------------------------------------------------------------------------------------------

# bind a text or entry to skip Control- or Alt-key and synchronize with variables
proc bindEntry {path {var {}} {novar 0}} {

	bindtags $path [lrange [bindtags $path] 0 end-1]
#TRACE "bindtags $path = [bindtags $path]"

	bind $path <FocusIn> "set skating::gui(v:inEdit) 2"
	bind $path <FocusOut> "set skating::gui(v:inEdit) 0"
	bind $path <Alt-KeyPress> {# nothing}
	bind $path <Meta-KeyPress> {# nothing}
	bind $path <Control-KeyPress> {# nothing}

	foreach key {Control_L Control_R Shift_L Shift_R Alt_L Alt_R Mode_switch Caps_Lock Print Pause} {
		bind $path <Key-$key> {# nothing}
	}

	if {$novar} {
		return
	}

	if {$var == {}} {
		bind $path <Key> "set ::skating::gui(v:modified) 1;"
 	} else {
		bind $path <KeyRelease> "set ::skating::gui(v:modified) 1; \
								 set $var \[string trim \[$path get 1.0 end\]\]"
	}
}


#------------------------------------------------------------------------------------------------
# Get default color for buttons
button .__b
set bg [.__b cget -background]
set abg [.__b cget -activebackground]
if {$tcl_platform(platform) == "windows"} {
	set abg $bg
}
destroy .__b





#=================================================================================================
# Rewrites tkMessageBox to have nicer images

image create photo tkMessageBox_error -file images/dlg_error.gif
image create photo tkMessageBox_info -file images/dlg_info.gif
image create photo tkMessageBox_question -file images/dlg_question.gif
image create photo tkMessageBox_warning -file images/dlg_warning.gif


proc tkMessageBox {args} {
global msg
global tkPriv tcl_platform

set w tkPrivMsgBox
upvar #0 $w data

	#
	# The default value of the title is space (" ") not the empty string
	# because for some window managers, a 
	#				wm title .foo ""
	# causes the window title to be "foo" instead of the empty string.
	#
	set specs {
		{-default "" "" ""}
		{-icon "" "" "info"}
		{-message "" "" ""}
		{-parent "" "" .}
		{-title "" "" " "}
		{-type "" "" "ok"}
	}

	tclParseConfigSpec $w $specs "" $args

	if {[lsearch {info warning error question} $data(-icon)] == -1} {
		error "invalid icon \"$data(-icon)\", must be error, info, question or warning"
	}

	if {![winfo exists $data(-parent)]} {
		error "bad window path name \"$data(-parent)\""
	}

	case $data(-type) {
		abortretryignore {
			set buttons [list \
				[list abort  -width 6 -text $msg(dlg:abort) -under 0] \
				[list retry  -width 6 -text $msg(dlg:retry) -under 0] \
				[list ignore -width 6 -text $msg(dlg:ignore) -under 0] \
			]
		}
		ok {
			set buttons [list \
				[list ok -width 6 -text $msg(dlg:ok) -under 0] \
			]
			if {$data(-default) == ""} {
				set data(-default) "ok"
			}
		}
		okcancel {
			set buttons [list \
				[list ok	 -width 6 -text $msg(dlg:ok) -under 0] \
				[list cancel -width 6 -text $msg(dlg:cancel) -under 0] \
			]
		}
		retrycancel {
			set buttons [list \
				[list retry  -width 6 -text $msg(dlg:retry) -under 0] \
				[list cancel -width 6 -text $msg(dlg:cancel) -under 0] \
			]
		}
		yesno {
			set buttons [list \
				[list yes	-width 6 -text $msg(dlg:yes) -under 0] \
				[list no	-width 6 -text $msg(dlg:no) -under 0] \
			]
		}
		yesnocancel {
			set buttons [list \
				[list yes	-width 6 -text $msg(dlg:yes) -under 0] \
				[list no	 -width 6 -text $msg(dlg:no) -under 0] \
				[list cancel -width 6 -text $msg(dlg:cancel) -under 0] \
			]
		}
		default {
			error "invalid message box type \"$data(-type)\", must be abortretryignore, ok, okcancel, retrycancel, yesno or yesnocancel"
		}
	}

	if {[string compare $data(-default) ""]} {
		set valid 0
		foreach btn $buttons {
			if {![string compare [lindex $btn 0] $data(-default)]} {
				set valid 1
				break
			}
		}
		if {!$valid} {
			error "invalid default button \"$data(-default)\""
		}
	}

	# 2. Set the dialog to be a child window of $parent
	#
	#
	if {[string compare $data(-parent) .]} {
		set w $data(-parent).__tk__messagebox
	} else {
		set w .__tk__messagebox
	}

	# 3. Create the top-level window and divide it into top
	# and bottom parts.

	catch {destroy $w}
	toplevel $w -class Dialog
	wm title $w $data(-title)
	wm iconname $w Dialog
	wm protocol $w WM_DELETE_WINDOW { }
	wm transient $w $data(-parent)
	if {$tcl_platform(platform) == "macintosh"} {
		unsupported1 style $w dBoxProc
	}

	frame $w.bot
	pack $w.bot -side bottom -fill both
	frame $w.top
	pack $w.top -side top -fill both -expand 1
	if {$tcl_platform(platform) != "macintosh"} {
		$w.bot configure -relief raised -bd 1
		$w.top configure -relief raised -bd 1
	}

	# 4. Fill the top part with bitmap and message (use the option
	# database for -wraplength so that it can be overridden by
	# the caller).

	option add *Dialog.msg.wrapLength 3i widgetDefault
	label $w.msg -justify left -text $data(-message)
	catch {$w.msg configure -font \
				-Adobe-Times-Medium-R-Normal--*-180-*-*-*-*-*-*
	}
	pack $w.msg -in $w.top -side right -expand 1 -fill both -padx 3m -pady 3m
	if {$data(-icon) != ""} {
		label $w.bitmap -image tkMessageBox_$data(-icon)
		pack $w.bitmap -in $w.top -side left -padx 3m -pady 3m
	}

	# 5. Create a row of buttons at the bottom of the dialog.

	set i 0
	foreach but $buttons {
		set name [lindex $but 0]
		set opts [lrange $but 1 end]
		if {![string compare $opts {}]} {
			# Capitalize the first letter of $name
			set capName \
				[string toupper \
					[string index $name 0]][string range $name 1 end]
			set opts [list -text $capName]
		}

		eval button $w.$name $opts -command [list "set tkPriv(button) $name"]

		if ![string compare $name $data(-default)] {
			$w.$name configure -default active
		}
		pack $w.$name -in $w.bot -side left -expand 1 \
			-padx 3m -pady 2m

		# create the binding for the key accelerator, based on the underline
		#
		set underIdx [$w.$name cget -under]
		if {$underIdx >= 0} {
			set key [string index [$w.$name cget -text] $underIdx]
			bind $w <Alt-[string tolower $key]>  "$w.$name invoke"
			bind $w <Alt-[string toupper $key]>  "$w.$name invoke"
		}
		incr i
	}

	# 6. Create a binding for <Return> on the dialog if there is a
	# default button.

	if {[string compare $data(-default) ""]} {
		bind $w <Return> "tkButtonInvoke $w.$data(-default)"
	}

	# 7. Withdraw the window, then update all the geometry information
	# so we know how big it wants to be, then center the window in the
	# display and de-iconify it.

	wm withdraw $w
	update idletasks
	set x [expr [winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
			- [winfo vrootx [winfo parent $w]]]
	set y [expr [winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
			- [winfo vrooty [winfo parent $w]]]
	wm geom $w +$x+$y
	wm deiconify $w

	# 8. Set a grab and claim the focus too.

	set oldFocus [focus]
	set oldGrab [grab current $w]
	if {$oldGrab != ""} {
		set grabStatus [grab status $oldGrab]
	}
	grab $w
	if {[string compare $data(-default) ""]} {
		focus $w.$data(-default)
	} else {
		focus $w
	}

	# 9. Wait for the user to respond, then restore the focus and
	# return the index of the selected button.  Restore the focus
	# before deleting the window, since otherwise the window manager
	# may take the focus away so we can't redirect it.  Finally,
	# restore any grab that was in effect.

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
	return $tkPriv(button)
}


#==============================================================================================

proc timing {script {msg "time"}} {
	set t [clock clicks -milliseconds]
	uplevel 1 $script
	puts "[info level -1] >>>> $msg = [expr {([clock clicks -milliseconds]-$t)/1000.0}]"
}
