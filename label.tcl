# ------------------------------------------------------------------------------
#  label.tcl
#  This file is part of Unifix BWidget Toolkit
#  $Id: label.tcl,v 1.7 1999/05/25 08:28:14 eric Exp $
# ------------------------------------------------------------------------------
#  Index of commands:
#     - Label::create
#     - Label::configure
#     - Label::cget
#     - Label::setfocus
#     - Label::_drag_cmd
#     - Label::_drop_cmd
#     - Label::_over_cmd
# ------------------------------------------------------------------------------

namespace eval Label {
    Widget::tkinclude Label label :cmd \
        remove {-foreground -text -textvariable -underline}

    Widget::declare Label {
        {-name               String     "" 0}
        {-text               String     "" 0}
        {-textvariable       String     "" 0}
        {-underline          Int        -1 0 {=-1}}
        {-focus              String     "" 0}
        {-foreground         TkResource "" 0 label}
        {-disabledforeground TkResource "" 0 button}
        {-state              Enum       normal 0  {normal disabled}}
        {-fg                 Synonym    -foreground}

    }
    DynamicHelp::include Label balloon

    Widget::syncoptions Label "" :cmd {-text {} -underline {}}

    proc ::Label { path args } { return [eval Label::create $path $args] }
    proc use {} {}

    bind BwLabel <FocusIn> {Label::setfocus %W}
    bind BwLabel <Destroy> {Widget::destroy %W; rename %W {}}
}


# ------------------------------------------------------------------------------
#  Command Label::create
# ------------------------------------------------------------------------------
proc Label::create { path args } {
    Widget::init Label $path $args

    if { [Widget::getoption $path -state] == "normal" } {
        set fg [Widget::getoption $path -foreground]
    } else {
        set fg [Widget::getoption $path -disabledforeground]
    }

    set var [Widget::getoption $path -textvariable]
    if {  $var == "" &&
          [Widget::getoption $path -image] == "" &&
          [Widget::getoption $path -bitmap] == ""} {
        set desc [BWidget::getname [Widget::getoption $path -name]]
        if { $desc != "" } {
            set text  [lindex $desc 0]
            set under [lindex $desc 1]
        } else {
            set text  [Widget::getoption $path -text]
            set under [Widget::getoption $path -underline]
        }
    } else {
        set under -1
        set text  ""
    }


    eval label $path [Widget::subcget $path :cmd] \
    	    [list -text $text -textvariable $var -underline $under -foreground $fg]

    set accel [string tolower [string index $text $under]]
    if { $accel != "" } {
        bind [winfo toplevel $path] <Alt-$accel> "Label::setfocus $path"
    }

    bindtags $path [list $path Label BwLabel [winfo toplevel $path] all]

    DynamicHelp::sethelp $path $path 1

    rename $path ::$path:cmd
    proc ::$path { cmd args } "return \[eval Label::\$cmd $path \$args\]"

    return $path
}


# ------------------------------------------------------------------------------
#  Command Label::configure
# ------------------------------------------------------------------------------
proc Label::configure { path args } {
    set oldunder [$path:cmd cget -underline]
    if { $oldunder != -1 } {
        set oldaccel [string tolower [string index [$path:cmd cget -text] $oldunder]]
    } else {
        set oldaccel ""
    }
    set res [Widget::configure $path $args]

    set cfg  [Widget::hasChanged $path -foreground fg]
    set cdfg [Widget::hasChanged $path -disabledforeground dfg]
    set cst  [Widget::hasChanged $path -state state]

    if { $cst || $cfg || $cdfg } {
        if { $state == "normal" } {
            $path:cmd configure -fg $fg
        } else {
            $path:cmd configure -fg $dfg
        }
    }

    set cv [Widget::hasChanged $path -textvariable var]
    set cb [Widget::hasChanged $path -image img]
    set ci [Widget::hasChanged $path -bitmap bmp]
    set cn [Widget::hasChanged $path -name name]
    set ct [Widget::hasChanged $path -text text]
    set cu [Widget::hasChanged $path -underline under]

    if { $cv || $cb || $ci || $cn || $ct || $cu } {
        if {  $var == "" && $img == "" && $bmp == "" } {
            set desc [BWidget::getname $name]
            if { $desc != "" } {
                set text  [lindex $desc 0]
                set under [lindex $desc 1]
            }
        } else {
            set under -1
            set text  ""
        }
        set top [winfo toplevel $path]
        if { $oldaccel != "" } {
            bind $top <Alt-$oldaccel> {}
        }
        set accel [string tolower [string index $text $under]]
        if { $accel != "" } {
            bind $top <Alt-$accel> "Label::setfocus $path"
        }
        $path:cmd configure -text $text -underline $under -textvariable $var
    }

    return $res
}


# ------------------------------------------------------------------------------
#  Command Label::cget
# ------------------------------------------------------------------------------
proc Label::cget { path option } {
    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command Label::setfocus
# ------------------------------------------------------------------------------
proc Label::setfocus { path } {
    if { ![string compare [Widget::getoption $path -state] "normal"] } {
        set w [Widget::getoption $path -focus]
        if { [winfo exists $w] && [Widget::focusOK $w] } {
            focus $w
        }
    }
}
