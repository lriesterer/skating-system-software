# ------------------------------------------------------------------------------
#  scrollw.tcl
#  This file is part of Unifix BWidget Toolkit
# ------------------------------------------------------------------------------
#  Index of commands:
#     - ScrolledWindow::create
#     - ScrolledWindow::getframe
#     - ScrolledWindow::setwidget
#     - ScrolledWindow::configure
#     - ScrolledWindow::cget
#     - ScrolledWindow::_set_hscroll
#     - ScrolledWindow::_set_vscroll
#     - ScrolledWindow::_realize
# ------------------------------------------------------------------------------

namespace eval ScrolledWindow {
    Widget::declare ScrolledWindow {
        {-background  TkResource ""   0 button}
        {-scrollbar   Enum       both 1 {none both vertical horizontal}}
        {-auto        Enum       both 0 {none both vertical horizontal}}
        {-relief      TkResource flat 0 frame}
        {-borderwidth TkResource 0    0 frame}
        {-bg          Synonym    -background}
        {-bd          Synonym    -borderwidth}
    }

    Widget::addmap ScrolledWindow "" .grid.frame {-relief {} -borderwidth {}}

    proc use {} {}

    variable _widget
}


# ------------------------------------------------------------------------------
#  Command ScrolledWindow::create
# ------------------------------------------------------------------------------
proc ScrolledWindow::create { path args } {
    variable _widget

    Widget::init ScrolledWindow $path $args

    set bg     [Widget::cget $path -background]
    set sw     [frame $path -relief flat -bd 0 -bg $bg -highlightthickness 0 -takefocus 0]
    set grid   [frame $path.grid -relief flat -bd 0 -bg $bg -highlightthickness 0 -takefocus 0]

    set sb    [lsearch {none horizontal vertical both} [Widget::cget $path -scrollbar]]
    set auto  [lsearch {none horizontal vertical both} [Widget::cget $path -auto]]
    set rspan [expr {1 + (!($sb & 1) || ($auto & 1))}]
    set cspan [expr {1 + (!($sb & 2) || ($auto & 2))}]

    set _widget($path,sb)    $sb
    set _widget($path,auto)  $auto
    set _widget($path,hpack) [expr {$rspan == 1}]
    set _widget($path,vpack) [expr {$cspan == 1}]

    # scrollbar horizontale ou les deux
    if { $sb & 1 } {
        scrollbar $grid.hscroll \
            -bd 1 -highlightthickness 0 -takefocus 0 \
            -orient  horiz	\
            -relief  sunken	\
            -bg      $bg
        $grid.hscroll set 0 1
        grid $grid.hscroll -column 0 -row 1 -sticky we -columnspan $cspan -pady 1
    }

    # scrollbar verticale ou les deux
    if { $sb & 2 } {
        scrollbar $grid.vscroll \
            -bd 1 -highlightthickness 0 -takefocus 0 \
            -orient  vert  	\
            -relief  sunken 	\
            -bg      $bg
        $grid.vscroll set 0 1
        grid $grid.vscroll -column 1 -row 0 -sticky ns -rowspan $rspan -padx 1
    }

    eval frame $grid.frame -bg $bg -highlightthickness 0 [Widget::subcget $path .grid.frame]
    grid $grid.frame -column 0 -row 0 -sticky nwse -columnspan $cspan -rowspan $rspan
    grid columnconfigure $grid 0 -weight 1
    grid rowconfigure    $grid 0 -weight 1
    pack $grid -fill both -expand yes

    bind $grid <Configure> "ScrolledWindow::_realize $path"
    bind $grid <Destroy>   "ScrolledWindow::_destroy $path"

    return $path
}


# ------------------------------------------------------------------------------
#  Command ScrolledWindow::getframe
# ------------------------------------------------------------------------------
proc ScrolledWindow::getframe { path } {
    variable _widget

    if { [info exists _widget($path,sb)] } {
        return $path.grid.frame
    }
}


# ------------------------------------------------------------------------------
#  Command ScrolledWindow::setwidget
# ------------------------------------------------------------------------------
proc ScrolledWindow::setwidget { path widget {withHeader 0}} {
    variable _widget

    if { ![info exists _widget($path,sb)] } {
        return
    }
 	foreach c [winfo children $path.grid.frame] {
		if {$withHeader} {
	 		grid forget $c
		} else {
			pack forget $c
		}
 	}
	if {$withHeader} {
	    grid $widget -sticky news -column 1 -row 1
		grid columnconfigure $path.grid.frame {0} -weight 0
		grid columnconfigure $path.grid.frame {1} -weight 1
		grid rowconfigure $path.grid.frame {0} -weight 0
		grid rowconfigure $path.grid.frame {1} -weight 1
	} else {
	    pack $widget -in $path.grid.frame -fill both -expand yes
	}

    set sb     $_widget($path,sb)
    set grid   $path.grid
    set option {}
    # scrollbar horizontale ou les deux
    if { $sb & 1 } {
        $grid.hscroll configure -command "$widget xview"
        lappend option  "-xscrollcommand" "ScrolledWindow::_set_hscroll $path"
    }

    # scrollbar verticale ou les deux
    if { $sb & 2 } {
        $grid.vscroll configure -command "$widget yview"
        lappend option  "-yscrollcommand" "ScrolledWindow::_set_vscroll $path"
    }
    if { [llength $option] } {
        eval $widget configure $option
    }
}


# ------------------------------------------------------------------------------
#  Command ScrolledWindow::configure
# ------------------------------------------------------------------------------
proc ScrolledWindow::configure { path args } {
    variable _widget

    set res [Widget::configure $path $args]
    if { [Widget::hasChanged $path -background bg] } {
        $path configure -background $bg
        $path.grid.frame configure -background $bg
        catch {$path.grid.hscroll configure -background $bg}
        catch {$path.grid.vscroll configure -background $bg}
    }
    if { [Widget::hasChanged $path -auto auto] } {
        set _widget($path,auto) [lsearch {none horizontal vertical both} $auto]
	    set auto  $_widget($path,auto)
	    set sb    $_widget($path,sb)
	    set rspan [expr {1 + (!($sb & 1) || ($auto & 1))}]
	    set cspan [expr {1 + (!($sb & 2) || ($auto & 2))}]
        if { $sb & 1 } {
            grid configure $path.grid.vscroll -rowspan 1
	        grid $path.grid.hscroll -column 0 -row 1 -sticky we -columnspan $cspan -pady 1
            eval _set_hscroll $path [$path.grid.hscroll get]
        }
        if { $sb & 2 } {
            grid configure $path.grid.frame -columnspan 1
	        grid $path.grid.vscroll -column 1 -row 0 -sticky ns -rowspan $rspan -padx 1
            eval _set_vscroll $path [$path.grid.vscroll get]
        }
    }
    return $res
}


# ------------------------------------------------------------------------------
#  Command ScrolledWindow::cget
# ------------------------------------------------------------------------------
proc ScrolledWindow::cget { path option } {
    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command ScrolledWindow::_destroy
# ------------------------------------------------------------------------------
proc ScrolledWindow::_destroy { path } {
    variable _widget

    unset _widget($path,sb)
    unset _widget($path,auto)
    unset _widget($path,hpack)
    unset _widget($path,vpack)
    Widget::destroy $path
}


# ------------------------------------------------------------------------------
#  Command ScrolledWindow::_set_hscroll
# ------------------------------------------------------------------------------
proc ScrolledWindow::_set_hscroll { path vmin vmax } {
    variable _widget

    if { $_widget($path,auto) & 1 } {
        if { $_widget($path,hpack) && $vmin == 0 && $vmax == 1 } {
            grid configure $path.grid.frame -rowspan 2
            if { $_widget($path,sb) & 2 } {
                grid configure $path.grid.vscroll -rowspan 2
            }
            set _widget($path,hpack) 0
        } elseif { !$_widget($path,hpack) && ($vmin != 0 || $vmax != 1) } {
            grid configure $path.grid.frame -rowspan 1
            if { $_widget($path,sb) & 2 } {
                grid configure $path.grid.vscroll -rowspan 1
            }
            set _widget($path,hpack) 1
        }
    }
    $path.grid.hscroll set $vmin $vmax
}


# ------------------------------------------------------------------------------
#  Command ScrolledWindow::_set_vscroll
# ------------------------------------------------------------------------------
proc ScrolledWindow::_set_vscroll { path vmin vmax } {
    variable _widget

    if { $_widget($path,auto) & 2 } {
        if { $_widget($path,vpack) && $vmin == 0 && $vmax == 1 } {
            grid configure $path.grid.frame -columnspan 2
            if { $_widget($path,sb) & 1 } {
                grid configure $path.grid.hscroll -columnspan 2
            }
            set _widget($path,vpack) 0
        } elseif { !$_widget($path,vpack) && ($vmin != 0 || $vmax != 1) } {
            grid configure $path.grid.frame -columnspan 1
            if { $_widget($path,sb) & 1 } {
                grid configure $path.grid.hscroll -columnspan 1
            }
            set _widget($path,vpack) 1
        }
    }
    $path.grid.vscroll set $vmin $vmax
}


# ------------------------------------------------------------------------------
#  Command ScrolledWindow::_realize
# ------------------------------------------------------------------------------
proc ScrolledWindow::_realize { path } {
    place $path.grid -anchor nw -x 0 -y 0 -relwidth 1.0 -relheight 1.0
    bind  $path.grid <Configure> {}
}



#==============================================================================================

proc ScrolledWindow::header {path head side} {
	# if windows is managed, then there is nothing to do
	if {[winfo manager $head] != ""} {
#puts "ScrolledWindow::header ---- $head aldready managed"
		return
	}
	# en fonction du coté
#puts "ScrolledWindow::header ---- gridding '$side' $head"
	switch $side {
		top		{	grid $head -sticky ew -column 1 -row 0
					# synchronize the content & header
					set oldcmd [$path.grid.hscroll cget -command]
					$path.grid.hscroll configure -command "::sync_$head"
					proc ::sync_$head {args} "eval $head xview \$args; eval $oldcmd \$args"
					# binding pour MouseWheel
					foreach w [grid slaves $path.grid.frame -row 0] {
						bind $w <MouseWheel> "break"
						if {[string equal "unix" $::tcl_platform(platform)]} {
						    bind $w <4> "break"
						    bind $w <5> "break"
						}
					}
					sync_$head moveto 0
				}
		left	{ 	grid $head -sticky sn -column 0 -row 1
					# synchronize the content & header
					set oldcmd [$path.grid.vscroll cget -command]
					$path.grid.vscroll configure -command "::sync_$head"
					proc ::sync_$head {args} "eval $head yview \$args; eval $oldcmd \$args"
					# binding pour MouseWheel
#puts "---- scrolling mouse for '[grid slaves $path.grid.frame -row 1]'"
					set left [grid slaves $path.grid.frame -column 0 -row 1]
					foreach w [grid slaves $path.grid.frame -row 1] {
						bind $w <MouseWheel> "::sync_$left scroll \[expr {- (%D / 120) * 4}\] units ; break"
						if {[string equal "unix" $::tcl_platform(platform)]} {
						    bind $w <4> "::sync_$left scroll -5 units ; break"
						    bind $w <5> "::sync_$left scroll 5 units ; break"
						}
					}
					sync_$head moveto 0
				}
		topleft	{	grid $head -sticky news -column 0 -row 0
					# binding pour MouseWheel
					foreach w [grid slaves $path.grid.frame -row 0] {
						bind $w <MouseWheel> "break"
						if {[string equal "unix" $::tcl_platform(platform)]} {
						    bind $w <4> "break"
						    bind $w <5> "break"
						}
					}
				}
	}
#	pack $head -side top -before $master -fill x
}

proc ScrolledWindow::unheader {head} {
	grid forget $head
}
