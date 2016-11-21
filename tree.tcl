# ------------------------------------------------------------------------------
#  tree.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: tree.tcl,v 1.11 1999/05/25 08:28:22 eric Exp $
# ------------------------------------------------------------------------------
#  Index of commands:
#     - Tree::create
#     - Tree::configure
#     - Tree::cget
#     - Tree::insert
#     - Tree::itemconfigure
#     - Tree::itemcget
#     - Tree::bindText
#     - Tree::bindImage
#     - Tree::delete
#     - Tree::move
#     - Tree::reorder
#     - Tree::selection
#     - Tree::exists
#     - Tree::parent
#     - Tree::index
#     - Tree::nodes
#     - Tree::see
#     - Tree::opentree
#     - Tree::closetree
#     - Tree::edit
#     - Tree::xview
#     - Tree::yview
#     - Tree::_update_edit_size
#     - Tree::_destroy
#     - Tree::_see
#     - Tree::_recexpand
#     - Tree::_subdelete
#     - Tree::_update_scrollregion
#     - Tree::_cross_event
#     - Tree::_draw_node
#     - Tree::_draw_subnodes
#     - Tree::_update_nodes
#     - Tree::_draw_tree
#     - Tree::_redraw_tree
#     - Tree::_redraw_selection
#     - Tree::_redraw_idle
#     - Tree::_drag_cmd
#     - Tree::_drop_cmd
#     - Tree::_over_cmd
#     - Tree::_auto_scroll
#     - Tree::_scroll
# ------------------------------------------------------------------------------

namespace eval Tree {
    namespace eval Node {
        Widget::declare Tree::Node {
            {-text       String     ""      0}
            {-font       TkResource ""      0 listbox}
            {-image      TkResource ""      0 label}
            {-window     String     ""      0}
            {-fill       TkResource black   0 {listbox -foreground}}
            {-data       String     ""      0}
            {-open       Boolean    0       0}
            {-drawcross  Enum       auto    0 {auto allways never}}
        }
    }

    Widget::tkinclude Tree canvas :cmd \
        remove     {-insertwidth -insertbackground -insertborderwidth -insertofftime \
                        -insertontime -selectborderwidth -closeenough -confine -scrollregion \
                        -xscrollincrement -yscrollincrement -width -height} \
        initialize {-relief sunken -borderwidth 2 -takefocus 1 \
                        -highlightthickness 1 -width 200}

    Widget::declare Tree {
        {-deltax           Int 10 0 {=0 ""}}
        {-deltay           Int 15 0 {=0 ""}}
        {-padx             Int 20 0 {=0 ""}}
        {-background       TkResource "" 0 listbox}
        {-selectbackground TkResource "" 0 listbox}
        {-selectforeground TkResource "" 0 listbox}
        {-width            TkResource "" 0 listbox}
        {-height           TkResource "" 0 listbox}
        {-showlines        Boolean 1  0}
        {-linesfill        TkResource black  0 {frame -background}}
        {-linestipple      TkResource ""     0 {label -bitmap}}
        {-redraw           Boolean 1  0}
        {-opencmd          String  "" 0}
        {-closecmd         String  "" 0}
        {-bg               Synonym -background}
    }

    Widget::addmap Tree "" :cmd {-deltay -yscrollincrement}

    proc ::Tree { path args } { return [eval Tree::create $path $args] }
    proc use {} {}


	image create photo imgMinus -file images/minus.gif
	image create photo imgPlus -file images/plus.gif

    variable _edit
}


# ------------------------------------------------------------------------------
#  Command Tree::create
# ------------------------------------------------------------------------------
proc Tree::create { path args } {
    variable $path
    upvar 0  $path data

    Widget::init Tree $path $args

    set data(root)         {{}}
    set data(selnodes)     {}
    set data(upd,level)    0
    set data(upd,nodes)    {}
    set data(upd,afterid)  ""

    set path [eval canvas $path [Widget::subcget $path :cmd] \
                  -width  [expr {[Widget::getoption $path -width]*8}] \
                  -height [expr {[Widget::getoption $path -height]*[Widget::getoption $path -deltay]}] \
                  -xscrollincrement 8]

    $path bind cross <ButtonPress-1> {Tree::_cross_event %W}
    bind $path <Configure> "Tree::_update_scrollregion $path"
    bind $path <Destroy>   "Tree::_destroy $path"

    rename $path ::$path:cmd
    proc ::$path { cmd args } "return \[eval Tree::\$cmd $path \$args\]"

    return $path
}


# ------------------------------------------------------------------------------
#  Command Tree::configure
# ------------------------------------------------------------------------------
proc Tree::configure { path args } {
    variable $path
    upvar 0  $path data

    set res [Widget::configure $path $args]

    set ch1 [expr {[Widget::hasChanged $path -deltax val] |
                   [Widget::hasChanged $path -deltay dy]  |
                   [Widget::hasChanged $path -padx val]   |
                   [Widget::hasChanged $path -showlines val]}]

    set ch2 [expr {[Widget::hasChanged $path -selectbackground val] |
                   [Widget::hasChanged $path -selectforeground val]}]

    if { [Widget::hasChanged $path -linesfill   fill] |
         [Widget::hasChanged $path -linestipple stipple] } {
        $path:cmd itemconfigure line  -fill $fill -stipple $stipple
        $path:cmd itemconfigure cross -foreground $fill
    }

    if { $ch1 } {
        _redraw_idle $path 3
    } elseif { $ch2 } {
        _redraw_idle $path 1
    }

    if { [Widget::hasChanged $path -height h] } {
        $path:cmd configure -height [expr {$h*$dy}]
    }
    if { [Widget::hasChanged $path -width w] } {
        $path:cmd configure -width [expr {$w*8}]
    }

    if { [Widget::hasChanged $path -redraw bool] && $bool } {
        set upd $data(upd,level)
        set data(upd,level) 0
        _redraw_idle $path $upd
    }

    return $res
}


# ------------------------------------------------------------------------------
#  Command Tree::cget
# ------------------------------------------------------------------------------
proc Tree::cget { path option } {
    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command Tree::insert
# ------------------------------------------------------------------------------
proc Tree::insert { path index parent node args } {
    variable $path
    upvar 0  $path data

    if { [info exists data($node)] } {
        return -code error "node \"$node\" already exists"
    }
    if { ![info exists data($parent)] } {
        return -code error "node \"$parent\" does not exist"
    }

    Widget::init Tree::Node $path.$node $args
    if { ![string compare $index "end"] } {
        lappend data($parent) $node
    } else {
        incr index
        set data($parent) [linsert $data($parent) $index $node]
    }
    set data($node) [list $parent]

    if { ![string compare $parent "root"] } {
        _redraw_idle $path 3
    } elseif { [visible $path $parent] } {
        # parent is visible...
        if { [Widget::getoption $path.$parent -open] } {
            # ...and opened -> redraw whole
            _redraw_idle $path 3
        } else {
            # ...and closed -> redraw cross
            lappend data(upd,nodes) $parent 8
            _redraw_idle $path 2
        }
    }
    return $node
}


# ------------------------------------------------------------------------------
#  Command Tree::itemconfigure
# ------------------------------------------------------------------------------
proc Tree::itemconfigure { path node args } {
    variable $path
    upvar 0  $path data

    if { ![string compare $node "root"] || ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }

    set result [Widget::configure $path.$node $args]
    if { [visible $path $node] } {
        set lopt   {}
        set flag   0
        foreach opt {-window -image -drawcross -font -text -fill} {
            set flag [expr {$flag << 1}]
            if { [Widget::hasChanged $path.$node $opt val] } {
                set flag [expr {$flag | 1}]
            }
        }

        if { [Widget::hasChanged $path.$node -open val] } {
            _redraw_idle $path 3
        } elseif { $data(upd,level) < 3 && $flag } {
            if { [set idx [lsearch $data(upd,nodes) $node]] == -1 } {
                lappend data(upd,nodes) $node $flag
            } else {
                incr idx
                set flag [expr {[lindex $data(upd,nodes) $idx] | $flag}]
                set data(upd,nodes) [lreplace $data(upd,nodes) $idx $idx $flag]
            }
            _redraw_idle $path 2
        }
    }
    return $result
}


# ------------------------------------------------------------------------------
#  Command Tree::itemcget
# ------------------------------------------------------------------------------
proc Tree::itemcget { path node option } {
    variable $path
    upvar 0  $path data

    if { ![string compare $node "root"] || ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }

    return [Widget::cget $path.$node $option]
}


# ------------------------------------------------------------------------------
#  Command Tree::bindText
# ------------------------------------------------------------------------------
proc Tree::bindText { path event script } {
    if { $script != "" } {
        $path:cmd bind "node" $event \
            "$script \[string range \[lindex \[$path:cmd gettags current\] 1\] 2 end\]"
    } else {
        $path:cmd bind "node" $event {}
    }
}


# ------------------------------------------------------------------------------
#  Command Tree::bindImage
# ------------------------------------------------------------------------------
proc Tree::bindImage { path event script } {
    if { $script != "" } {
        $path:cmd bind "img" $event \
            "$script \[string range \[lindex \[$path:cmd gettags current\] 1\] 2 end\]"
    } else {
        $path:cmd bind "img" $event {}
    }
}


# ------------------------------------------------------------------------------
#  Command Tree::delete
# ------------------------------------------------------------------------------
proc Tree::delete { path args } {
    variable $path
    upvar 0  $path data

    foreach lnodes $args {
        foreach node $lnodes {
            if { [string compare $node "root"] && [info exists data($node)] } {
                set parent [lindex $data($node) 0]
                set idx    [lsearch $data($parent) $node]
                set data($parent) [lreplace $data($parent) $idx $idx]
                _subdelete $path $node
            }
        }
    }

    set sel $data(selnodes)
    set data(selnodes) {}
    eval selection $path set $sel
    _redraw_idle $path 3
}


# ------------------------------------------------------------------------------
#  Command Tree::move
# ------------------------------------------------------------------------------
proc Tree::move { path parent node index } {
    variable $path
    upvar 0  $path data

    if { ![string compare $node "root"] || ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }
    if { ![info exists data($parent)] } {
        return -code error "node \"$parent\" does not exist"
    }
    set p $parent
    while { [string compare $p "root"] } {
        if { ![string compare $p $node] } {
            return -code error "node \"$parent\" is a descendant of \"$node\""
        }
        set p [parent $path $p]
    }

    set oldp        [lindex $data($node) 0]
    set idx         [lsearch $data($oldp) $node]
    set data($oldp) [lreplace $data($oldp) $idx $idx]
    set data($node) [concat [list $parent] [lrange $data($node) 1 end]]
    if { ![string compare $index "end"] } {
        lappend data($parent) $node
    } else {
        incr index
        set data($parent) [linsert $data($parent) $index $node]
    }
    if { ([visible $path $oldp]   && [Widget::getoption $path.$oldp   -open]) ||
         ([visible $path $parent] && [Widget::getoption $path.$parent -open]) } {
        _redraw_idle $path 3
    }
}


# ------------------------------------------------------------------------------
#  Command Tree::reorder
# ------------------------------------------------------------------------------
proc Tree::reorder { path node index } {
variable $path
upvar 0  $path data

    if { $node == "root" || ![info exists data($node)] } {
		return -code error "node \"$node\" does not exist"
    }

	set parent [lindex $data($node) 0]
#puts "BEFORE data($parent) = $data($parent)"

	set position [lsearch $data($parent) $node]
    if { $index == "end" } {
		set data($parent) [lreplace $data($oldp) $position $position]
		lappend data($parent) $node
    } else {
		incr index
		if {$index > $position} {
			incr index
		} else {
			incr position
		}
#puts "$node / $index = inserting at $index / old at $position"
		set data($parent) [linsert $data($parent) $index $node]
		set data($parent) [lreplace $data($parent) $position $position]
    }
#puts "AFTER data($parent) = $data($parent)"
    _redraw_idle $path 3
}
#  proc Tree::reorder { path node neworder } {
#      variable $path
#      upvar 0  $path data

#      if { ![info exists data($node)] } {
#          return -code error "node \"$node\" does not exist"
#      }
#      set children [lrange $data($node) 1 end]
#  puts "children = $children"
#      if { [llength $children] } {
#          set children [BWidget::lreorder $children $neworder]
#          set data($node) [linsert $children 0 [lindex $data($node) 0]]
#          if { [visible $path $node] && [Widget::getoption $path.$node -open] } {
#              _redraw_idle $path 3
#          }
#      }
#  }


# ------------------------------------------------------------------------------
#  Command Tree::selection
# ------------------------------------------------------------------------------
proc Tree::selection { path cmd args } {
    variable $path
    upvar 0  $path data

    switch -- $cmd {
        set {
            set data(selnodes) {}
            foreach node $args {
                if { [info exists data($node)] } {
                    if { [lsearch $data(selnodes) $node] == -1 } {
                        lappend data(selnodes) $node
                    }
                }
            }
        }
        add {
            foreach node $args {
                if { [info exists data($node)] } {
                    if { [lsearch $data(selnodes) $node] == -1 } {
                        lappend data(selnodes) $node
                    }
                }
            }
        }
        remove {
            foreach node $args {
                if { [set idx [lsearch $data(selnodes) $node]] != -1 } {
                    set data(selnodes) [lreplace $data(selnodes) $idx $idx]
                }
            }
        }
        clear {
            set data(selnodes) {}
        }
        get {
            return $data(selnodes)
        }
        default {
            return
        }
    }
    _redraw_idle $path 1
}


# ------------------------------------------------------------------------------
#  Command Tree::exists
# ------------------------------------------------------------------------------
proc Tree::exists { path node } {
    variable $path
    upvar 0  $path data

    return [info exists data($node)]
}


# ------------------------------------------------------------------------------
#  Command Tree::visible
# ------------------------------------------------------------------------------
proc Tree::visible { path node } {
    set idn [$path:cmd find withtag n:$node]
    return [llength $idn]
}


# ------------------------------------------------------------------------------
#  Command Tree::parent
# ------------------------------------------------------------------------------
proc Tree::parent { path node } {
    variable $path
    upvar 0  $path data

    if { ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }
    return [lindex $data($node) 0]
}


# ------------------------------------------------------------------------------
#  Command Tree::index
# ------------------------------------------------------------------------------
proc Tree::index { path node } {
    variable $path
    upvar 0  $path data

    if { ![string compare $node "root"] || ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }
    set parent [lindex $data($node) 0]
    return [expr {[lsearch $data($parent) $node] - 1}]
}


# ------------------------------------------------------------------------------
#  Command Tree::nodes
# ------------------------------------------------------------------------------
proc Tree::nodes { path node } {
    variable $path
    upvar 0  $path data

    if { ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }
    return [lrange $data($node) 1 end]
}


# ------------------------------------------------------------------------------
#  Command Tree::see
# ------------------------------------------------------------------------------
proc Tree::see { path node } {
    set idn [$path:cmd find withtag n:$node]
    if { $idn != "" } {
        Tree::_see $path $idn left
    }
}


# ------------------------------------------------------------------------------
#  Command Tree::opentree
# ------------------------------------------------------------------------------
proc Tree::opentree { path node } {
    variable $path
    upvar 0  $path data

    if { ![string compare $node "root"] || ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }

    _recexpand $path $node 1 [Widget::getoption $path -opencmd]
    _redraw_idle $path 3
}


# ------------------------------------------------------------------------------
#  Command Tree::closetree
# ------------------------------------------------------------------------------
proc Tree::closetree { path node } {
    variable $path
    upvar 0  $path data

    if { ![string compare $node "root"] || ![info exists data($node)] } {
        return -code error "node \"$node\" does not exist"
    }

    _recexpand $path $node 0 [Widget::getoption $path -closecmd]
    _redraw_idle $path 3
}


# ------------------------------------------------------------------------------
#  Command Tree::edit
# ------------------------------------------------------------------------------
proc Tree::edit { path node text {verifycmd ""} {clickres 0} {select 1}} {
    variable _edit

    set idn [$path:cmd find withtag n:$node]
    if { $idn != "" } {
        Tree::_see $path $idn right
        Tree::_see $path $idn left

        set oldfg  [$path:cmd itemcget $idn -fill]
        set sbg    [Widget::getoption $path -selectbackground]
        set coords [$path:cmd coords $idn]
        set x      [lindex $coords 0]
        set y      [lindex $coords 1]
        set bd     [expr {[$path:cmd cget -borderwidth]+[$path:cmd cget -highlightthickness]}]
        set w      [expr {[winfo width $path] - 2*$bd}]
        set wmax   [expr {[$path:cmd canvasx $w]-$x}]

        set _edit(text) $text
        set _edit(wait) 0

        $path:cmd itemconfigure $idn    -fill [Widget::getoption $path -background]
        $path:cmd itemconfigure s:$node -fill {} -outline {}

        set frame  [frame $path.edit \
                        -relief flat -borderwidth 0 -highlightthickness 0 \
                        -background [Widget::getoption $path -background]]
        set ent    [entry $frame.edit \
                        -width              0     \
                        -relief             solid \
                        -borderwidth        1     \
                        -highlightthickness 0     \
                        -foreground         [Widget::getoption $path.$node -fill] \
                        -background         [Widget::getoption $path -background] \
                        -selectforeground   [Widget::getoption $path -selectforeground] \
                        -selectbackground   $sbg  \
                        -font               [Widget::getoption $path.$node -font] \
                        -textvariable       Tree::_edit(text)]
        pack $ent -ipadx 8 -anchor w

        set idw [$path:cmd create window $x $y -window $frame -anchor w]
        trace variable Tree::_edit(text) w "Tree::_update_edit_size $path $ent $idw $wmax"
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

        bind $ent <Escape> {set Tree::_edit(wait) 0}
        bind $ent <Return> {set Tree::_edit(wait) 1}
        if { $clickres == 0 || $clickres == 1 } {
            bind $frame <Button>  "set Tree::_edit(wait) $clickres"
        }

        set ok 0
        while { !$ok } {
            tkwait variable Tree::_edit(wait)
            if { !$_edit(wait) || $verifycmd == "" ||
                 [uplevel \#0 $verifycmd [list $_edit(text)]] } {
                set ok 1
            }
        }

        trace vdelete Tree::_edit(text) w "Tree::_update_edit_size $path $ent $idw $wmax"
        grab release $frame
        BWidget::focus release $ent
        destroy $frame
        $path:cmd delete $idw
        $path:cmd itemconfigure $idn    -fill $oldfg
        $path:cmd itemconfigure s:$node -fill $sbg -outline $sbg

        if { $_edit(wait) } {
            return $_edit(text)
        }
    }
    return ""
}


# ------------------------------------------------------------------------------
#  Command Tree::xview
# ------------------------------------------------------------------------------
proc Tree::xview { path args } {
    return [eval $path:cmd xview $args]
}


# ------------------------------------------------------------------------------
#  Command Tree::yview
# ------------------------------------------------------------------------------
proc Tree::yview { path args } {
    return [eval $path:cmd yview $args]
}


# ------------------------------------------------------------------------------
#  Command Tree::_update_edit_size
# ------------------------------------------------------------------------------
proc Tree::_update_edit_size { path entry idw wmax args } {
    set entw [winfo reqwidth $entry]
    if { $entw+8 >= $wmax } {
        $path:cmd itemconfigure $idw -width $wmax
    } else {
        $path:cmd itemconfigure $idw -width 0
    }
}


# ------------------------------------------------------------------------------
#  Command Tree::_destroy
# ------------------------------------------------------------------------------
proc Tree::_destroy { path } {
    variable $path
    upvar 0  $path data

    if { $data(upd,afterid) != "" } {
        after cancel $data(upd,afterid)
    }

    foreach node [lrange $data(root) 1 end] {
        _subdelete $path $node
    }
    Widget::destroy $path
    unset data
    rename $path {}
}


# ------------------------------------------------------------------------------
#  Command Tree::_see
# ------------------------------------------------------------------------------
proc Tree::_see { path idn side } {
    set bbox [$path:cmd bbox $idn]
    set scrl [$path:cmd cget -scrollregion]

    set ymax [lindex $scrl 3]
    set dy   [$path:cmd cget -yscrollincrement]
    set yv   [$path yview]
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
    set xv   [$path xview]
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
#  Command Tree::_recexpand
# ------------------------------------------------------------------------------
proc Tree::_recexpand { path node expand cmd } {
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path.$node -open] != $expand } {
        Widget::setoption $path.$node -open $expand
        if { $cmd != "" } {
            uplevel \#0 $cmd $node
        }
    }

    foreach subnode [lrange $data($node) 1 end] {
        _recexpand $path $subnode $expand $cmd
    }
}


# ------------------------------------------------------------------------------
#  Command Tree::_subdelete
# ------------------------------------------------------------------------------
proc Tree::_subdelete { path node } {
    variable $path
    upvar 0  $path data

    foreach subnode [lrange $data($node) 1 end] {
        _subdelete $path $subnode
    }
    unset data($node)
    if { [set win [Widget::getoption $path.$node -window]] != "" } {
        destroy $win
    }
    Widget::destroy $path.$node
}


# ------------------------------------------------------------------------------
#  Command Tree::_update_scrollregion
# ------------------------------------------------------------------------------
proc Tree::_update_scrollregion { path } {
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
#  Command Tree::_cross_event
# ------------------------------------------------------------------------------
proc Tree::_cross_event { path } {
    variable $path
    upvar 0  $path data

    set node [string range [lindex [$path:cmd gettags current] 1] 2 end]
    if { [Widget::getoption $path.$node -open] } {
        if { [set cmd [Widget::getoption $path -closecmd]] != "" } {
            uplevel \#0 $cmd $node
        }
        Widget::setoption $path.$node -open 0
    } else {
        if { [set cmd [Widget::getoption $path -opencmd]] != "" } {
            uplevel \#0 $cmd $node
        }
        Widget::setoption $path.$node -open 1
    }
    _redraw_idle $path 3
}


# ------------------------------------------------------------------------------
#  Command Tree::_draw_node
# ------------------------------------------------------------------------------
proc Tree::_draw_node { path node x0 y0 deltax deltay padx showlines } {
    global   env
    variable $path
    upvar 0  $path data

    set x1 [expr {$x0+$deltax+5}]
    set y1 $y0
    if { $showlines } {
        $path:cmd create line $x0 $y0 $x1 $y0 \
            -fill    [Widget::getoption $path -linesfill]   \
            -stipple [Widget::getoption $path -linestipple] \
            -tags    line
    }
    $path:cmd create text [expr {$x1+$padx}] $y0 \
        -text   [Widget::getoption $path.$node -text] \
        -fill   [Widget::getoption $path.$node -fill] \
        -font   [Widget::getoption $path.$node -font] \
        -anchor w \
        -tags   "node n:$node"
    set len [expr {[llength $data($node)] > 1}]
    set dc  [Widget::getoption $path.$node -drawcross]
    set exp [Widget::getoption $path.$node -open]

    if { $len && $exp } {
        set y1 [_draw_subnodes $path [lrange $data($node) 1 end] \
                    [expr {$x0+$deltax}] $y0 $deltax $deltay $padx $showlines]
    }

    if { [string compare $dc "never"] && ($len || ![string compare $dc "allways"]) } {
        if { $exp } {
            set bmp imgMinus
        } else {
            set bmp imgPlus
        }
        $path:cmd create image $x0 $y0 \
            -image      $bmp \
            -tags       "cross c:$node" -anchor c
    }

    if { [set win [Widget::getoption $path.$node -window]] != "" } {
        $path:cmd create window $x1 $y0 -window $win -anchor w -tags "win i:$node"
    } elseif { [set img [Widget::getoption $path.$node -image]] != "" } {
        $path:cmd create image $x1 $y0 -image $img -anchor w -tags "img i:$node"
    }
    return $y1
}


# ------------------------------------------------------------------------------
#  Command Tree::_draw_subnodes
# ------------------------------------------------------------------------------
proc Tree::_draw_subnodes { path nodes x0 y0 deltax deltay padx showlines } {
    set y1 $y0
    foreach node $nodes {
        set yp $y1
        set y1 [_draw_node $path $node $x0 [expr {$y1+$deltay}] $deltax $deltay $padx $showlines]
    }
    if { $showlines && [llength $nodes] } {
        set id [$path:cmd create line $x0 $y0 $x0 [expr {$yp+$deltay}] \
                    -fill    [Widget::getoption $path -linesfill]   \
                    -stipple [Widget::getoption $path -linestipple] \
                    -tags    line]

        $path:cmd lower $id
    }
    return $y1
}


# ------------------------------------------------------------------------------
#  Command Tree::_update_nodes
# ------------------------------------------------------------------------------
proc Tree::_update_nodes { path } {
    global   env
    variable $path
    upvar 0  $path data

    set deltax [Widget::getoption $path -deltax]
    set padx   [Widget::getoption $path -padx]
    foreach {node flag} $data(upd,nodes) {
        set idn [$path:cmd find withtag "n:$node"]
        if { $idn == "" } {
            continue
        }
        set c  [$path:cmd coords $idn]
        set x0 [expr {[lindex $c 0]-$deltax}]
        set y0 [lindex $c 1]
        if { $flag & 48 } {
            # -window or -image modified
            set win  [Widget::getoption $path.$node -window]
            set img  [Widget::getoption $path.$node -image]
            set idi  [$path:cmd find withtag i:$node]
            set type [lindex [$path:cmd gettags $idi] 0]
            if { [string length $win] } {
                if { ![string compare $type "win"] } {
                    $path:cmd itemconfigure $idi -window $win
                } else {
                    $path:cmd delete $idi
                    $path:cmd create window $x0 $y0 -window $win -anchor w -tags "win i:$node"
                }
            } elseif { [string length $img] } {
                if { ![string compare $type "img"] } {
                    $path:cmd itemconfigure $idi -image $img
                } else {
                    $path:cmd delete $idi
                    $path:cmd create image $x0 $y0 -image $img -anchor w -tags "img i:$node"
                }
            } else {
                $path:cmd delete $idi
            }
        }

        if { $flag & 8 } {
            # -drawcross modified
            set len [expr {[llength $data($node)] > 1}]
            set dc  [Widget::getoption $path.$node -drawcross]
            set exp [Widget::getoption $path.$node -open]
            set idc [$path:cmd find withtag c:$node]

            if { [string compare $dc "never"] && ($len || ![string compare $dc "allways"]) } {
                if { $exp } {
                    set bmp imgMinus
                } else {
                    set bmp imgPlus
                }
                if { $idc == "" } {
                    $path:cmd create image $x0 $y0 \
                        -image      $bmp \
                        -tags       "cross c:$node" -anchor c
                } else {
                    $path:cmd itemconfigure $idc -image $bmp
                }
            } else {
                $path:cmd delete $idc
            }
        }

        if { $flag & 7 } {
            # -font, -text or -fill modified
            $path:cmd itemconfigure $idn \
                -text [Widget::getoption $path.$node -text] \
                -fill [Widget::getoption $path.$node -fill] \
                -font [Widget::getoption $path.$node -font]
        }
    }
}


# ------------------------------------------------------------------------------
#  Command Tree::_draw_tree
# ------------------------------------------------------------------------------
proc Tree::_draw_tree { path } {
    variable $path
    upvar 0  $path data

    $path:cmd delete all
    $path:cmd configure -cursor watch
    _draw_subnodes $path [lrange $data(root) 1 end] 8 \
        [expr {-[Widget::getoption $path -deltay]/2}] \
        [Widget::getoption $path -deltax] \
        [Widget::getoption $path -deltay] \
        [Widget::getoption $path -padx]   \
        [Widget::getoption $path -showlines]
    $path:cmd configure -cursor [Widget::getoption $path -cursor]
}


# ------------------------------------------------------------------------------
#  Command Tree::_redraw_tree
# ------------------------------------------------------------------------------
proc Tree::_redraw_tree { path } {
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path -redraw] } {
        if { $data(upd,level) == 2 } {
            _update_nodes $path
        } elseif { $data(upd,level) == 3 } {
            _draw_tree $path
        }
        _redraw_selection $path
        _update_scrollregion $path
        set data(upd,nodes)   {}
        set data(upd,level)   0
        set data(upd,afterid) ""
    }
}


# ------------------------------------------------------------------------------
#  Command Tree::_redraw_selection
# ------------------------------------------------------------------------------
proc Tree::_redraw_selection { path } {
    variable $path
    upvar 0  $path data

    set selbg [Widget::getoption $path -selectbackground]
    set selfg [Widget::getoption $path -selectforeground]
    foreach id [$path:cmd find withtag sel] {
        set node [string range [lindex [$path:cmd gettags $id] 1] 2 end]
        $path:cmd itemconfigure "n:$node" -fill [Widget::getoption $path.$node -fill]
    }
    $path:cmd delete sel
    foreach node $data(selnodes) {
        set bbox [$path:cmd bbox "n:$node"]
        if { [llength $bbox] } {
            set id [eval $path:cmd create rectangle $bbox -fill $selbg -outline $selbg -tags [list "sel s:$node"]]
            $path:cmd itemconfigure "n:$node" -fill $selfg
            $path:cmd lower $id
        }
    }
}


# ------------------------------------------------------------------------------
#  Command Tree::_redraw_idle
# ------------------------------------------------------------------------------
proc Tree::_redraw_idle { path level } {
    variable $path
    upvar 0  $path data

    if { [Widget::getoption $path -redraw] && $data(upd,afterid) == "" } {
        set data(upd,afterid) [after idle Tree::_redraw_tree $path]
    }
    if { $level > $data(upd,level) } {
        set data(upd,level) $level
    }
    return ""
}
