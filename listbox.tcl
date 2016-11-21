# ------------------------------------------------------------------------------
#  listbox.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: listbox.tcl,v 1.10 1999/05/25 08:28:15 eric Exp $
# ------------------------------------------------------------------------------
#  Index of commands:
#     - ListBox::create
#     - ListBox::configure
#     - ListBox::cget
#     - ListBox::insert
#     - ListBox::itemconfigure
#     - ListBox::itemcget
#     - ListBox::bindText
#     - ListBox::bindImage
#     - ListBox::delete
#     - ListBox::move
#     - ListBox::reorder
#     - ListBox::selection
#     - ListBox::exists
#     - ListBox::index
#     - ListBox::items
#     - ListBox::see
#     - ListBox::edit
#     - ListBox::xview
#     - ListBox::yview
#     - ListBox::_update_edit_size
#     - ListBox::_destroy
#     - ListBox::_see
#     - ListBox::_update_scrollregion
#     - ListBox::_draw_item
#     - ListBox::_redraw_items
#     - ListBox::_redraw_selection
#     - ListBox::_redraw_listbox
#     - ListBox::_redraw_idle
#     - ListBox::_resize
#     - ListBox::_init_drag_cmd
#     - ListBox::_drop_cmd
#     - ListBox::_over_cmd
#     - ListBox::_auto_scroll
#     - ListBox::_scroll
# ------------------------------------------------------------------------------


namespace eval ListBox {
    namespace eval Item {
        Widget::declare ListBox::Item {
            {-indent     Int        0       0 {=0}}
            {-before     String     ""      0}
            {-text       String     ""      0}
            {-font       TkResource ""      0 listbox}
            {-image      TkResource ""      0 label}
            {-window     String     ""      0}
            {-fill       TkResource black   0 {listbox -foreground}}
            {-data       String     ""      0}
        }
    }

    Widget::tkinclude ListBox canvas :cmd \
        remove     {-insertwidth -insertbackground -insertborderwidth -insertofftime \
                        -insertontime -selectborderwidth -closeenough -confine -scrollregion \
                        -xscrollincrement -yscrollincrement -width -height} \
        initialize {-relief sunken -borderwidth 2 -takefocus 1 \
                        -highlightthickness 1 -width 200}

    Widget::declare ListBox {
        {-deltax           Int 10 0 {=0 ""}}
        {-deltay           Int 15 0 {=0 ""}}
        {-padx             Int 20 0 {=0 ""}}
        {-background       TkResource "" 0 listbox}
        {-selectbackground TkResource "" 0 listbox}
        {-selectforeground TkResource "" 0 listbox}
        {-width            TkResource "" 0 listbox}
        {-height           TkResource "" 0 listbox}
        {-redraw           Boolean 1  0}
        {-multicolumn      Boolean 0  0}
        {-bg               Synonym -background}

        {-beforecolor      TkResource "" 0 {listbox -foreground}}
        {-beforewidth      Int 0 0 {=0 ""}}
        {-beforefont       TkResource "" 0 {listbox -font}}
    }

    Widget::addmap ListBox "" :cmd {-deltay -yscrollincrement}

    proc ::ListBox { path args } { return [eval ListBox::create $path $args] }
    proc use {} {}

    variable _edit
}


# ------------------------------------------------------------------------------
#  Command ListBox::create
# ------------------------------------------------------------------------------
proc ListBox::create { path args } {
    Widget::init ListBox $path $args

    variable $path
    upvar 0  $path data

    # widget informations
    set data(nrows) -1

    # items informations
    set data(items)    {}
    set data(selitems) {}

    # update informations
    set data(upd,level)   0
    set data(upd,afterid) ""
    set data(upd,level)   0
    set data(upd,delete)  {}

    eval canvas $path [Widget::subcget $path :cmd] \
        -width  [expr {[Widget::getoption $path -width]*8}] \
        -height [expr {[Widget::getoption $path -height]*[Widget::getoption $path -deltay]}] \
        -xscrollincrement 8

    bind $path <Configure> "ListBox::_resize  $path"
    bind $path <Destroy>   "ListBox::_destroy $path"

    rename $path ::$path:cmd
    proc ::$path { cmd args } "return \[eval ListBox::\$cmd $path \$args\]"

    return $path
}


# ------------------------------------------------------------------------------
#  Command ListBox::configure
# ------------------------------------------------------------------------------
proc ListBox::configure { path args } {
    set res [Widget::configure $path $args]

    set ch1 [expr {[Widget::hasChanged $path -deltay dy]  |
                   [Widget::hasChanged $path -padx val]   |
                   [Widget::hasChanged $path -multicolumn val]}]

    set ch2 [expr {[Widget::hasChanged $path -selectbackground val] |
                   [Widget::hasChanged $path -selectforeground val]}]

    set redraw 0
    if { [Widget::hasChanged $path -height h] } {
        $path:cmd configure -height [expr {$h*$dy}]
        set redraw 1
    }
    if { [Widget::hasChanged $path -width w] } {
        $path:cmd configure -width [expr {$w*8}]
        set redraw 1
    }
    if { [Widget::hasChanged $path -beforewidth val] } {
        _redraw_idle $path 2
    }

    if { !$redraw } {
        if { $ch1 } {
            _redraw_idle $path 2
        } elseif { $ch2 } {
            _redraw_idle $path 1
        }
    }

    if { [Widget::hasChanged $path -redraw bool] && $bool } {
        variable $path
        upvar 0  $path data
        set lvl $data(upd,level)
        set data(upd,level) 0
        _redraw_idle $path $lvl
    }

    return $res
}


# ------------------------------------------------------------------------------
#  Command ListBox::cget
# ------------------------------------------------------------------------------
proc ListBox::cget { path option } {
    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command ListBox::insert
# ------------------------------------------------------------------------------
proc ListBox::insert { path index item args } {
    variable $path
    upvar 0  $path data

    if { [lsearch $data(items) $item] != -1 } {
        return -code error "item \"$item\" already exists"
    }

    Widget::init ListBox::Item $path.$item $args

    if { ![string compare $index "end"] } {
        lappend data(items) $item
    } else {
        set data(items) [linsert $data(items) $index $item]
    }
    set data(upd,create,$item) $item

    _redraw_idle $path 2
    return $item
}


# ------------------------------------------------------------------------------
#  Command ListBox::itemconfigure
# ------------------------------------------------------------------------------
proc ListBox::itemconfigure { path item args } {
    variable $path
    upvar 0  $path data

    if { [lsearch $data(items) $item] == -1 } {
        return -code error "item \"$item\" does not exist"
    }

    set oldind [Widget::getoption $path.$item -indent]

    set res   [Widget::configure $path.$item $args]
    set chind [Widget::hasChanged $path.$item -indent indent]
    set chw   [Widget::hasChanged $path.$item -window win]
    set chi   [Widget::hasChanged $path.$item -image  img]
    set chb   [Widget::hasChanged $path.$item -before bfr]
    set cht   [Widget::hasChanged $path.$item -text txt]
    set chf   [Widget::hasChanged $path.$item -font fnt]
    set chfg  [Widget::hasChanged $path.$item -fill fg]
    set idn   [$path:cmd find withtag n:$item]

    if { $idn == "" } {
        # item is not drawn yet
        _redraw_idle $path 2
        return $res
    }

    set oldb   [$path:cmd bbox $idn]
    set coords [$path:cmd coords $idn]
    set padx   [Widget::getoption $path -padx]
    set x0     [expr {[lindex $coords 0]-$padx-$oldind+$indent}]
    set y0     [lindex $coords 1]
    if { $chw || $chi } {
        # -window or -image modified
        set idi  [$path:cmd find withtag i:$item]
        set type [lindex [$path:cmd gettags $idi] 0]
        if { [string length $win] } {
            if { ![string compare $type "win"] } {
                $path:cmd itemconfigure $idi -window $win
            } else {
                $path:cmd delete $idi
                $path:cmd create window $x0 $y0 -window $win -anchor w -tags "win i:$item"
            }
        } elseif { [string length $img] } {
            if { ![string compare $type "img"] } {
                $path:cmd itemconfigure $idi -image $img
            } else {
                $path:cmd delete $idi
                $path:cmd create image $x0 $y0 -image $img -anchor w -tags "img i:$item"
            }
        } else {
            $path:cmd delete $idi
        }
    }

    if { $cht || $chf || $chfg } {
        # -text or -font modified, or -fill modified
        $path:cmd itemconfigure $idn -text $txt -font $fnt -fill $fg
        _redraw_idle $path 1
    }
    if { $chb } {
        # -before
        $path:cmd itemconfigure [$path:cmd find withtag b:$item] -text $bfr \
				-font [Widget::getoption $path -beforefont] -fill [Widget::getoption $path -beforecolor]
        _redraw_idle $path 1
    }

    if { $chind } {
        # -indent modified
        $path:cmd coords $idn [expr {$x0+$padx}] $y0
        $path:cmd coords i:$item $x0 $y0
        _redraw_idle $path 1
    }

    if { [Widget::getoption $path -multicolumn] && ($cht || $chf || $chind) } {
        set bbox [$path:cmd bbox $idn]
        if { [lindex $bbox 2] > [lindex $oldb 2] } {
            _redraw_idle $path 2
        }
    }

    return $res
}


# ------------------------------------------------------------------------------
#  Command ListBox::itemcget
# ------------------------------------------------------------------------------
proc ListBox::itemcget { path item option } {
    return [Widget::cget $path.$item $option]
}


# ------------------------------------------------------------------------------
#  Command ListBox::bindText
# ------------------------------------------------------------------------------
proc ListBox::bindText { path event script } {
    if { $script != "" } {
        $path:cmd bind "item" $event \
            "$script \[string range \[lindex \[$path:cmd gettags current\] 1\] 2 end\]"
    } else {
        $path:cmd bind "item" $event {}
    }
}

# ------------------------------------------------------------------------------
#  Command ListBox::bindBefore
# ------------------------------------------------------------------------------
proc ListBox::bindBefore { path event script } {
    if { $script != "" } {
        $path:cmd bind "before" $event \
            "$script \[string range \[lindex \[$path:cmd gettags current\] 1\] 2 end\]"
    } else {
        $path:cmd bind "item" $event {}
    }
}


# ------------------------------------------------------------------------------
#  Command ListBox::bindImage
# ------------------------------------------------------------------------------
proc ListBox::bindImage { path event script } {
    if { $script != "" } {
        $path:cmd bind "img" $event \
            "$script \[string range \[lindex \[$path:cmd gettags current\] 1\] 2 end\]"
    } else {
        $path:cmd bind "img" $event {}
    }
}


# ------------------------------------------------------------------------------
#  Command ListBox::delete
# ------------------------------------------------------------------------------
proc ListBox::delete { path args } {
    variable $path
    upvar 0  $path data

    foreach litems $args {
        foreach item $litems {
            set idx [lsearch $data(items) $item]
            if { $idx != -1 } {
                set data(items) [lreplace $data(items) $idx $idx]
                Widget::destroy $path.$item
                if { [info exists data(upd,create,$item)] } {
                    unset data(upd,create,$item)
                } else {
                    lappend data(upd,delete) $item
                }
            }
        }
    }

    set sel $data(selitems)
    set data(selitems) {}
    eval selection $path set $sel
    _redraw_idle $path 2
}


# ------------------------------------------------------------------------------
#  Command ListBox::move
# ------------------------------------------------------------------------------
proc ListBox::move { path item index } {
    variable $path
    upvar 0  $path data

    if { [set idx [lsearch $data(items) $item]] == -1 } {
        return -code error "item \"$item\" does not exist"
    }

    set data(items) [lreplace $data(items) $idx $idx]
    if { ![string compare $index "end"] } {
        lappend data($path,item) $item
    } else {
        set data(items) [linsert $data(items) $index $item]
    }

    _redraw_idle $path 2
}


# ------------------------------------------------------------------------------
#  Command ListBox::reorder
# ------------------------------------------------------------------------------
proc ListBox::reorder { path neworder } {
    variable $path
    upvar 0  $path data

    set data(items) [BWidget::lreorder $data(items) $neworder]
    _redraw_idle $path 2
}


# ------------------------------------------------------------------------------
#  Command ListBox::selection
# ------------------------------------------------------------------------------
proc ListBox::selection { path cmd args } {
    variable $path
    upvar 0  $path data

    switch -- $cmd {
        set {
            set data(selitems) {}
			foreach group $args {
	            foreach item $group {
	                if { [lsearch $data(selitems) $item] == -1 } {
	                    if { [lsearch $data(items) $item] != -1 } {
	                        lappend data(selitems) $item
	                    }
	                }
	            }
			}
        }
        add {
            foreach item $args {
                if { [lsearch $data(selitems) $item] == -1 } {
                    if { [lsearch $data(items) $item] != -1 } {
                        lappend data(selitems) $item
                    }
                }
            }
        }
        remove {
            foreach item $args {
                if { [set idx [lsearch $data(selitems) $item]] != -1 } {
                    set data(selitems) [lreplace $data(selitems) $idx $idx]
                }
            }
        }
        clear {
            set data(selitems) {}
        }
        get {
            return $data(selitems)
        }
        default {
            return
        }
    }
    _redraw_idle $path 1
}


# ------------------------------------------------------------------------------
#  Command ListBox::exists
# ------------------------------------------------------------------------------
proc ListBox::exists { path item } {
    variable $path
    upvar 0  $path data

    return [expr {[lsearch $data(items) $item] != -1}]
}


# ------------------------------------------------------------------------------
#  Command ListBox::index
# ------------------------------------------------------------------------------
proc ListBox::index { path item } {
    variable $path
    upvar 0  $path data

    return [lsearch $data(items) $item]
}


proc ListBox::item { path first {last ""} } {
    variable $path
    upvar 0  $path data

    if { ![string length $last] } {
        return [lindex $data(items) $first]
    } else {
        return [lrange $data(items) $first $last]
    }
}


# ------------------------------------------------------------------------------
#  Command ListBox::items
# ------------------------------------------------------------------------------
proc ListBox::items { path } {
    variable $path
    upvar 0  $path data

    return $data(items)
}


# ------------------------------------------------------------------------------
#  Command ListBox::see
# ------------------------------------------------------------------------------
proc ListBox::see { path item {side left}} {
    set idn [$path:cmd find withtag n:$item]
    if { $idn != "" } {
        ListBox::_see $path $idn $side $item
    }
}


# ------------------------------------------------------------------------------
#  Command ListBox::edit
# ------------------------------------------------------------------------------
proc ListBox::edit { path item text {verifycmd ""} {clickres 0} {select 1}} {
    variable _edit

    set idn [$path:cmd find withtag n:$item]
    if { $idn != "" } {
        ListBox::_see $path $idn right
        ListBox::_see $path $idn left

        set oldfg  [$path:cmd itemcget $idn -fill]
        set sbg    [Widget::getoption $path -selectbackground]
        set coords [$path:cmd coords $idn]
        set x      [lindex $coords 0]
        set y      [lindex $coords 1]
        set bd     [expr {[$path:cmd cget -borderwidth]+[$path:cmd cget -highlightthickness]}]
        set w      [expr {[winfo width $path] - 2*$bd}]
        set wmax   [expr {[$path:cmd canvasx $w]-$x}]

	$path:cmd itemconfigure $idn    -fill [Widget::getoption $path -background]
        $path:cmd itemconfigure s:$item -fill {} -outline {}

        set _edit(text) $text
        set _edit(wait) 0

        set frame  [frame $path.edit \
                        -relief flat -borderwidth 0 -highlightthickness 0 \
                        -background [Widget::getoption $path -background]]
        set ent    [entry $frame.edit \
                        -width              0     \
                        -relief             solid \
                        -borderwidth        1     \
                        -highlightthickness 0     \
                        -foreground         [Widget::getoption $path.$item -fill] \
                        -background         [Widget::getoption $path -background] \
                        -selectforeground   [Widget::getoption $path -selectforeground] \
                        -selectbackground   $sbg  \
                        -font               [Widget::getoption $path.$item -font] \
                        -textvariable       ListBox::_edit(text)]
        pack $ent -ipadx 8 -anchor w

        set idw [$path:cmd create window $x $y -window $frame -anchor w]
        trace variable ListBox::_edit(text) w "ListBox::_update_edit_size $path $ent $idw $wmax"
        tkwait visibility $ent
        grab  $frame
        BWidget::focus set $ent
        _update_edit_size $path $ent $idw $wmax
        update
        if { $select } {
            $ent selection from 0
            $ent selection to   end
            $ent icursor end
            $ent xview end
        }

        bind $ent <Escape> {set ListBox::_edit(wait) 0}
        bind $ent <Return> {set ListBox::_edit(wait) 1}
	if { $clickres == 0 || $clickres == 1 } {
	    bind $frame <Button>  "set ListBox::_edit(wait) $clickres"
	}

        set ok 0
        while { !$ok } {
            tkwait variable ListBox::_edit(wait)
            if { !$_edit(wait) || $verifycmd == "" ||
                 [uplevel \#0 $verifycmd [list $_edit(text)]] } {
                set ok 1
            }
        }
        trace vdelete ListBox::_edit(text) w "ListBox::_update_edit_size $path $ent $idw $wmax"
        grab release $frame
        BWidget::focus release $ent
        destroy $frame
        $path:cmd delete $idw
        $path:cmd itemconfigure $idn    -fill $oldfg
        $path:cmd itemconfigure s:$item -fill $sbg -outline $sbg

        if { $_edit(wait) } {
            return $_edit(text)
        }
    }
    return ""
}


# ------------------------------------------------------------------------------
#  Command ListBox::xview
# ------------------------------------------------------------------------------
proc ListBox::xview { path args } {
    return [eval $path:cmd xview $args]
}


# ------------------------------------------------------------------------------
#  Command ListBox::yview
# ------------------------------------------------------------------------------
proc ListBox::yview { path args } {
    return [eval $path:cmd yview $args]
}

# ------------------------------------------------------------------------------
#  Command ListBox::measure
# ------------------------------------------------------------------------------
proc ListBox::measure { path args } {
	set font [Widget::getoption $path -beforefont]
	set max 0
	foreach t [lindex $args 0] {
    	set id [$path:cmd create text 0 -1000 -text $t -font $font -anchor w]
		set x [lindex [$path:cmd bbox $id] 2]
		if {$x > $max} {
			set max $x
		}
		$path:cmd delete $id
	}

#TRACE "max = $max"

	return $max
}


# ------------------------------------------------------------------------------
#  Command ListBox::_update_edit_size
# ------------------------------------------------------------------------------
proc ListBox::_update_edit_size { path entry idw wmax args } {
    set entw [winfo reqwidth $entry]
    if { $entw >= $wmax } {
        $path:cmd itemconfigure $idw -width $wmax
    } else {
        $path:cmd itemconfigure $idw -width 0
    }
}


# ------------------------------------------------------------------------------
#  Command ListBox::_destroy
# ------------------------------------------------------------------------------
proc ListBox::_destroy { path } {
    variable $path
    upvar 0  $path data

    if { $data(upd,afterid) != "" } {
        after cancel $data(upd,afterid)
    }

    foreach item $data(items) {
        Widget::destroy $path.$item
    }

    Widget::destroy $path
    unset data
    rename $path {}
}


# ------------------------------------------------------------------------------
#  Command ListBox::_see
# ------------------------------------------------------------------------------
proc ListBox::_see { path idn side {item ""}} {
	if {$item != ""} {
	    set bbox [$path:cmd bbox i:$item n:$item b:$item]
	} else {
	    set bbox [$path:cmd bbox $idn]
	}
    set scrl [$path:cmd cget -scrollregion]

    set ymax [lindex $scrl 3]
    set dy   [$path:cmd cget -yscrollincrement]
    set yv   [$path:cmd yview]
    set yv0  [expr {round([lindex $yv 0]*$ymax/$dy)}]
    set yv1  [expr {round([lindex $yv 1]*$ymax/$dy)}]
    set y    [expr {int([lindex [$path:cmd coords $idn] 1]/$dy)}]
    if { $y < $yv0 } {
        $path:cmd yview scroll [expr {$y-$yv0}] units
    } elseif { $y >= $yv1 } {
        $path:cmd yview scroll [expr {$y-$yv1+1}] units
    }

    set xmax [lindex $scrl 2]
    set dx   [$path:cmd cget -xscrollincrement]
    set xv   [$path:cmd xview]
    if { ![string compare $side "right"] } {
        set xv1 [expr {round([lindex $xv 1]*$xmax/$dx)}]
        set x1  [expr {int([lindex $bbox 2]/$dx)}]
        if { $x1 >= $xv1 } {
            $path:cmd xview scroll [expr {$x1-$xv1+1}] units
        }
    } else {
        set xv0 [expr {round([lindex $xv 0]*$xmax/$dx)}]
        set x0  [expr {int([lindex $bbox 0]/$dx)}]
        if { $x0 < $xv0 } {
            $path:cmd xview scroll [expr {$x0-$xv0}] units
        }
    }
}


# ------------------------------------------------------------------------------
#  Command ListBox::_update_scrollregion
# ------------------------------------------------------------------------------
proc ListBox::_update_scrollregion { path } {
    set bd   [expr {2*([$path:cmd cget -borderwidth]+[$path:cmd cget -highlightthickness])}]
    set w    [expr {[winfo width  $path] - $bd}]
    set h    [expr {[winfo height $path] - $bd}]
    set xinc [$path:cmd cget -xscrollincrement]
    set yinc [$path:cmd cget -yscrollincrement]
    set bbox [$path:cmd bbox all]
    if { [llength $bbox] } {
        set xs [lindex $bbox 2]
        set ys [lindex $bbox 3]

        if { $w < $xs } {
            set w [expr {int($xs)}]
            if { [set r [expr {$w % $xinc}]] } {
                set w [expr {$w+$xinc-$r}]
            }
        }
        if { $h < $ys } {
            set h [expr {int($ys)}]
            if { [set r [expr {$h % $yinc}]] } {
                set h [expr {$h+$yinc-$r}]
            }
        }
    }

    $path:cmd configure -scrollregion [list 0 0 $w $h]
}


# ------------------------------------------------------------------------------
#  Command ListBox::_draw_item
# ------------------------------------------------------------------------------
proc ListBox::_draw_item { path item x00 x0 x1 y } {

    set indent [Widget::getoption $path.$item -indent]
    $path:cmd create text [expr {$x1+$indent}] $y \
        -text   [Widget::getoption $path.$item -text] \
        -fill   [Widget::getoption $path.$item -fill] \
        -font   [Widget::getoption $path.$item -font] \
        -anchor w \
        -tags   "item n:$item"
    if { [set win [Widget::getoption $path.$item -window]] != "" } {
        $path:cmd create window [expr {$x0+$indent}] $y \
            -window $win -anchor w -tags "win i:$item"
    } elseif { [set img [Widget::getoption $path.$item -image]] != "" } {
        $path:cmd create image [expr {$x0+$indent}] $y \
            -image $img -anchor w -tags "img i:$item"
    }

    $path:cmd create text [expr {$x00+$indent}] $y \
        -text   [Widget::getoption $path.$item -before] \
        -fill   [Widget::getoption $path -beforecolor] \
        -font   [Widget::getoption $path -beforefont] \
        -anchor w \
        -tags   "before b:$item"
}


# ------------------------------------------------------------------------------
#  Command ListBox::_redraw_items
# ------------------------------------------------------------------------------
proc ListBox::_redraw_items { path } {
    variable $path
    upvar 0  $path data

    $path:cmd configure -cursor watch
    set dx   [Widget::getoption $path -deltax]
    set dy   [Widget::getoption $path -deltay]
    set padx [Widget::getoption $path -padx]
    set y0   [expr {$dy/2}]
    set x00  4
    set x0   4
    set x1   [expr {$x0+$padx}]
    set nitem 0
    set drawn {}
    set data(xlist) {}
    if { [Widget::getoption $path -multicolumn] } {
        set nrows $data(nrows)
    } else {
        set nrows [llength $data(items)]
    }
    if {[set bw [Widget::getoption $path -beforewidth]] > 0} {
        incr x0 $bw
        incr x1 $bw
	}

    foreach item $data(upd,delete) {
        $path:cmd delete b:$item i:$item n:$item s:$item
    }

    foreach item $data(items) {
        if { [info exists data(upd,create,$item)] } {
            _draw_item $path $item $x00 $x0 $x1 $y0
            unset data(upd,create,$item)
        } else {
            set indent [Widget::getoption $path.$item -indent]
            $path:cmd coords n:$item [expr {$x1+$indent}] $y0
            $path:cmd coords i:$item [expr {$x0+$indent}] $y0
            $path:cmd coords b:$item [expr {$x00+$indent}] $y0
        }
        incr y0 $dy
        incr nitem
        lappend drawn n:$item
        if { $nitem == $nrows } {
            set y0    [expr {$dy/2}]
            set bbox  [eval $path:cmd bbox $drawn]
            set drawn {}
            set x0    [expr {[lindex $bbox 2]+$dx}]
            set x1    [expr {$x0+$padx}]
            set nitem 0
            lappend data(xlist) [lindex $bbox 2]
        }
    }
    if { $nitem && $nitem < $nrows } {
        set bbox  [eval $path:cmd bbox $drawn]
        lappend data(xlist) [lindex $bbox 2]
    }
    set data(upd,delete) {}
    $path:cmd configure -cursor [Widget::getoption $path -cursor]
}


# ------------------------------------------------------------------------------
#  Command ListBox::_redraw_selection
# ------------------------------------------------------------------------------
proc ListBox::_redraw_selection { path } {
    variable $path
    upvar 0  $path data

    set selbg [Widget::getoption $path -selectbackground]
    set selfg [Widget::getoption $path -selectforeground]
    foreach id [$path:cmd find withtag sel] {
        set item [string range [lindex [$path:cmd gettags $id] 1] 2 end]
        $path:cmd itemconfigure "n:$item" -fill [Widget::getoption $path.$item -fill]
    }
    $path:cmd delete sel
    foreach item $data(selitems) {
        set bbox [$path:cmd bbox "n:$item"]
        if { [llength $bbox] } {
            set id [eval $path:cmd create rectangle $bbox -fill $selbg -outline $selbg -tags [list "sel s:$item"]]
            $path:cmd itemconfigure "n:$item" -fill $selfg
            $path:cmd lower $id
        }
    }
}


# ------------------------------------------------------------------------------
#  Command ListBox::_redraw_listbox
# ------------------------------------------------------------------------------
proc ListBox::_redraw_listbox { path } {
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path -redraw] } {
        if { $data(upd,level) == 2 } {
            _redraw_items $path
        }
        _redraw_selection $path
        _update_scrollregion $path
        set data(upd,level)   0
        set data(upd,afterid) ""
    }
}


# ------------------------------------------------------------------------------
#  Command ListBox::_redraw_idle
# ------------------------------------------------------------------------------
proc ListBox::_redraw_idle { path level } {
    variable $path
    upvar 0  $path data

    if { $data(nrows) != -1 } {
        # widget is realized
        if { [Widget::getoption $path -redraw] && $data(upd,afterid) == "" } {
            set data(upd,afterid) [after idle ListBox::_redraw_listbox $path]
        }
    }
    if { $level > $data(upd,level) } {
        set data(upd,level) $level
    }
    return ""
}


# ------------------------------------------------------------------------------
#  Command ListBox::_resize
# ------------------------------------------------------------------------------
proc ListBox::_resize { path } {
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path -multicolumn] } {
        set bd    [expr {[$path:cmd cget -borderwidth]+[$path:cmd cget -highlightthickness]}]
        set h     [expr {[winfo height $path] - 2*$bd}]
        set nrows [expr {$h/[$path:cmd cget -yscrollincrement]}]
        if { $nrows == 0 } {
            set nrows 1
        }
        if { $nrows != $data(nrows) } {
            set data(nrows) $nrows
            _redraw_idle $path 2
        } else {
            _update_scrollregion $path
        }
    } elseif { $data(nrows) == -1 } {
        # first Configure event
        set data(nrows) 0
        ListBox::_redraw_listbox $path
    } else {
        _update_scrollregion $path
    }
}

proc ListBox::nbRows { path } {
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path -multicolumn] } {
		set nrows $data(nrows)

	} else {
        set bd    [expr {[$path:cmd cget -borderwidth]+[$path:cmd cget -highlightthickness]}]
        set h     [expr {[winfo height $path] - 2*$bd}]
        set nrows [expr {$h/[$path:cmd cget -yscrollincrement]}]
        if { $nrows == 0 } {
            set nrows 1
        }
	}
	return $nrows
}