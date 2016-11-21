# ------------------------------------------------------------------------------
#  labelframe.tcl
#  This file is part of Unifix BWidget Toolkit
# ------------------------------------------------------------------------------
#  Index of commands:
#     - LabelFrame::create
#     - LabelFrame::getframe
#     - LabelFrame::configure
#     - LabelFrame::cget
# ------------------------------------------------------------------------------

namespace eval LabelFrame {
    Label::use

    Widget::bwinclude LabelFrame Label .l \
        remove     {
            -highlightthickness -highlightcolor -highlightbackground
            -takefocus -relief -borderwidth
            -bitmap -image -cursor -textvariable} \
        initialize {-anchor w}

    Widget::declare LabelFrame {
        {-relief      TkResource flat 0 frame}
        {-borderwidth TkResource 0    0 frame}
        {-side        Enum       left 1 {left right top bottom}}
        {-bd          Synonym    -borderwidth}
    }

    Widget::addmap LabelFrame "" :cmd {-background {}}
    Widget::addmap LabelFrame "" .f   {-background {} -relief {} -borderwidth {}}

    Widget::syncoptions LabelFrame Label .l {-text {} -underline {}}

    bind BwLabelFrame <FocusIn> {Label::setfocus %W.l}
    bind BwLabelFrame <Destroy> {Widget::destroy %W; rename %W {}}

    proc ::LabelFrame { path args } { return [eval LabelFrame::create $path $args] }
    proc use {} {}
}


# ------------------------------------------------------------------------------
#  Command LabelFrame::create
# ------------------------------------------------------------------------------
proc LabelFrame::create { path args } {
    Widget::init LabelFrame $path $args

    set path  [frame $path -background [Widget::getoption $path -background] \
                   -relief flat -bd 0 -takefocus 0 -highlightthickness 0]

    set label [eval Label::create $path.l [Widget::subcget $path .l] \
   	               -takefocus 0 -highlightthickness 0 -relief flat -borderwidth 0]
    set frame [eval frame $path.f [Widget::subcget $path .f] \
                   -highlightthickness 0 -takefocus 0]

    switch  [Widget::getoption $path -side] {
        left   {set packopt "-side left"}
        right  {set packopt "-side right"}
        top    {set packopt "-side top -fill x"}
        bottom {set packopt "-side bottom -fill x"}
    }

	if {[Widget::getoption $path -width] >= 0} {
	    eval pack $label $packopt
	}
    pack $frame -fill both -expand yes

    bindtags $path [list $path BwLabelFrame [winfo toplevel $path] all]

    rename $path ::$path:cmd
    proc ::$path { cmd args } "return \[eval LabelFrame::\$cmd $path \$args\]"

    return $path
}


# ------------------------------------------------------------------------------
#  Command LabelFrame::getframe
# ------------------------------------------------------------------------------
proc LabelFrame::getframe { path } {
    return $path.f
}


# ------------------------------------------------------------------------------
#  Command LabelFrame::configure
# ------------------------------------------------------------------------------
proc LabelFrame::configure { path args } {
    return [Widget::configure $path $args]
}


# ------------------------------------------------------------------------------
#  Command LabelFrame::cget
# ------------------------------------------------------------------------------
proc LabelFrame::cget { path option } {
    return [Widget::cget $path $option]
}