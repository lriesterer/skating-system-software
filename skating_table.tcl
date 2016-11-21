namespace eval Table {
	variable data
	set data(t:oldCell) ""
	set data(t:timer) ""
}

#==============================================================================================

proc Table::create {path nbCols expand resize popup pattern
					nbButtons cbButtonDisplay cbButtonHandle cbButtonTip
					cbGetIndex cbValidateIndex cbModify cbCompletion cbCanDelete} {
variable data

	# enregistrement des paramètres & callbacks
	set data($path:upperCaseInColumn0) 0
	set data($path:useIndex) 1
	set data($path:allowEmpty) 0
	set data($path:returnToCol) 1
	set data($path:cols) [expr {$nbCols+$nbButtons}]
	set data($path:colsButton) $nbCols
	set data($path:expand) $expand
	set data($path:resize) $resize
	set data($path:popup) $popup
	if {$cbGetIndex == ""} {
		set cbGetIndex list
	}
	set data($path:getIndex) $cbGetIndex
	if {$cbValidateIndex == ""} {
		set cbValidateIndex list
	}
	set data($path:validateIndex) $cbValidateIndex
	set data($path:modify) $cbModify
	set data($path:completion) $cbCompletion
	set data($path:candelete) $cbCanDelete
	set data($path:buttonDisplay) $cbButtonDisplay
	set data($path:buttonHandle) $cbButtonHandle
	set data($path:buttonTip) $cbButtonTip
	# création de la widget
	if {[info exists ::table$path]} {
		# efface ancienne données
		unset ::table$path
	}
	table $path -rows 2 -cols [expr {1+$nbCols+$nbButtons}] \
			-bordercursor sb_h_double_arrow -variable ::table$path \
			-highlightthickness 0 \
			-borderwidth 1 -bg gray95 \
			-resizeborders col \
			-width 6 -height 0 -maxheight 50 -maxwidth 50 \
			-titlerows 1 -roworigin 0 -titlecols 1 -colorigin -1 \
			-colstretchmode none -rowstretchmode none \
			-selectmode extended
	if {$pattern != ""} {
		$path configure -validate 1 -validatecommand "Table::validate:input $path %c %r %S {$pattern}"
	}
	# configuration des stylse (left, center, active, title, sel)
	$path tag configure left -anchor w
	$path tag configure center -anchor c
	$path tag configure active -relief solid -bd 1 -bg white -anchor w
	$path tag configure title -relief raised -bd 1 -bg [. cget -bg] -fg black -font {bold}
	$path tag configure sel -bg $::skating::gui(color:selection) -fg $::skating::gui(color:selectionFG)
	$path tag configure OFF -relief raised
	$path tag configure PARTIAL -bg lightyellow -relief sunken
	$path tag configure ON -bg aquamarine -relief sunken
	$path tag configure BUTTON -bg [. cget -bg] -relief raised
	$path tag configure DISABLED -fg $::colorDisabled -relief raised
	$path tag configure BUTTON_DISABLED -bg [. cget -bg] -fg $::colorDisabled -relief raised

	# applique les styles
	$path tag col left 1 2
	$path tag row center 0
	# initialisation finale
	$path activate "0,0"
	$path selection set "1,0"
	$path selection anchor "1,0"
	if {$cbCompletion != ""} {
		completion:init $path
	}
	# bindings
	bindtags $path "$path MyTable all"
	# retourne chemin de la widget
	set path
}

#----------------------------------------------------------------------------------------------

proc Table::select {w cell} {
	$w activate 0,0
	$w selection clear all
	$w selection set $cell
	$w selection anchor $cell
}

proc Table::activate {w cell} {
	$w selection clear all
	$w activate $cell
	completion:start $w $cell
}

proc Table::get:currentIndex {w} {
	set row [$w index active row]
	if {$row == 0} {
		set row [$w index anchor row]
	}
	upvar #0 ::table$w table
	set table($row,0)
}

proc Table::setValue {w index value} {
	upvar #0 ::table$w table
	set table($index) $value
}

proc Table::deleteCurrent {w} {
	set row [$w index active row]
	set col [$w index active col]
	if {$row == 0} {
		set row [$w index anchor row]
		set col [$w index anchor col]
	}
	$w delete rows $row 1
	select $w $row,$col
}

proc Table::get:currentRow {w} {
	set row [$w index active row]
	if {$row == 0} {
		return [$w index anchor row]
	}
	set row
}

proc Table::get:currentCol {w} {
	set col [$w index active col]
	if {$col == 0} {
		return [$w index anchor col]
	}
	set col
}

proc Table::buttons:setStyle {w row button style} {
variable data
global msg

upvar 0 ::table$w content

	set col [expr {$button+$data($w:colsButton)}]
	switch -exact -- $style {
		ON 	{
				set content($row,$col) $msg(yes)
				$w tag cell ON $row,$col
			}
		PARTIAL {
				set content($row,$col) $msg(yes)
				$w tag cell PARTIAL $row,$col
			}
		OFF {
				set content($row,$col) $msg(no)
				$w tag cell OFF $row,$col
			}
		BUTTON {
				set content($row,$col) $msg(all)
				$w tag cell BUTTON $row,$col
			}

		DISABLED {
				set content($row,$col) "---"
				$w tag cell DISABLED $row,$col
			}
		BUTTON_DISABLED {
				set content($row,$col) "---"
				$w tag cell BUTTON_DISABLED $row,$col
			}
	}
}

proc Table::buttons:getStyle {w row button} {
variable data
global msg

	set col [expr {$button+$data($w:colsButton)}]
	set text [$w get $row,$col]
	if {$text == $msg(yes)} {
		return ON
	} elseif {$text == $msg(no)} {
		return OFF
	} elseif {$text == $msg(all)} {
		return BUTTON
	}
}

proc Table::insert:before {w} {
variable data

	set row [get:currentRow $w]
	$w insert rows $row -1
	set nb2 [$w get [expr $row+1],0]
	if {$row > 1} {
		set nb1 [$w get [expr $row-1],0]
	} else {
		set nb1 0
	}
	set nb [uplevel #0 $data($w:getIndex) [list $nb1] [list $nb2]]
	$w activate $row,0
	$w delete active 0 end
	$w insert active insert $nb
	completion:start $w $row,0
	# création des buttons
	uplevel #0 $data($w:buttonDisplay) $row $nb
}

proc Table::insert:after {w} {
variable data

	set row [get:currentRow $w]
	$w insert rows $row +1
	incr row
	set nb1 [$w get [expr $row-1],0]
	set nb2 [$w get [expr $row+1],0]
	set nb [uplevel #0 $data($w:getIndex) [list $nb1] [list $nb2]]
	$w activate $row,0
	$w delete active 0 end
	$w insert active insert $nb
	completion:start $w $row,0
	# création des buttons
	uplevel #0 $data($w:buttonDisplay) $row $nb
}

#----------------------------------------------------------------------------------------------

proc Table::validate:input {w col row candidate pattern} {
variable data

#puts "Table::validate:input {$w $col $row $candidate $pattern} / $data($w:useIndex) / [regexp -- $pattern $candidate]==0"
	if {$data($w:useIndex) && $col == 0 && [regexp -- $pattern $candidate]==0} {
#puts "BAD '$candidate' against '$pattern'"
		bell
		return 0
	} else {
		return 1
	}
}

#----------------------------------------------------------------------------------------------

proc Table::validate:entry {w} {
variable data
upvar #0 ::table$w table

	# si pas en mode édition, retour
	if {[$w index active] == "0,0"} {
		return 1
	}
	# row,col cellule active
	set cell [$w index active]
	set col [$w index active col]
	set row [$w index active row]

#puts "table(active)='$table(active)'  /  active=[$w index active]"
#catch {puts "table([$w index active])='$table([$w index active])'"}
	# si pas de modifications, retour
	if {[info exists table($cell)] && $table(active) == $table($cell)} {
		return 1
	}

	# si édition "index" (numéro, lettre), procédure callback de validation
#puts "validation = [uplevel #0 $data($w:validateIndex) [list $table(active)]]"
#parray table

	set oldindex 0
	if {$data($w:useIndex) && $col == 0} {
		if {(!$data($w:allowEmpty) && [$w curvalue] == "") || ($data($w:validateIndex) != "list"
				&& ![uplevel #0 $data($w:validateIndex) [list $table(active)]])} {
			bell
			return 0
		}
		if {[info exists table($cell)]} {
			set oldindex $table($cell)
		}
		set table($cell) $table(active)
	}
	set oldvalue ""
	if {[info exists table($cell)]} {
		set oldvalue $table($cell)
	}
	# enregistre les modifications
	set index 0
	if {[info exists table($row,0)]} {
		set index $table($row,0)
	}
	if {[uplevel #0 $data($w:modify) $row $col [list $index] [list $oldindex] [list $table(active)]] == 0} {
		set table($cell) $oldvalue
		return 0
	}
	return 1
}

proc Table::moveCell {w y x activate} {
variable data
global tkPriv


	set isActive 0
	set wasActive 1
	set r [$w index active row]
	if {$r == 0} {
		set wasActive 0
		set r [$w index anchor row]
		set c [$w index anchor col]
		if {[$w index anchor] == "1,0" && ($x < 0 || $y < 0)} {
#puts "returning=$r,$c"
			return
		}
	} else {
	    set c [$w index active col]
	}
#puts "r=$r + $y / c=$c + $x"
    incr r $y
	incr c $x
	set oldc $c
	set max [$w cget -rows]
#puts "r=$r ($r >= $max) / c=$c  / y=$y"
	if {$data($w:expand) && $r >= $max 
				&& ($y > 0 || ([$w index anchor] == [$w index end] && $x>0))
				&& ($c < $data($w:colsButton))} {
		set r [expr $max-1]
		set c $data($w:cols)
		set activate 1
		set wasActive 1
	}
	if {$c == $data($w:cols)} {
		set c 0
		incr r
		if {!$data($w:expand)} {
			if {$r>=$max} {
				set c $oldc
			}
			set activate 0
		} elseif {$activate && $r == [$w cget -rows]} {
			$w insert rows end 1
			set nb [uplevel #0 $data($w:getIndex) 0 0 [$w get [expr $r-1],0]]
			set isActive 1
			$w activate $r,$c
			$w delete active 0 end
			$w insert active insert $nb
			# création des buttons
			uplevel #0 $data($w:buttonDisplay) $r $nb
		}
	} elseif {$c >= $data($w:colsButton)} {
#puts "set activate to 0 because of buttons"
		set activate 0
	    $w activate "0,0"
	} elseif {$c == -1} {
		set c [expr $data($w:cols)-1]
		incr r -1
	}

#puts "newcell=$r,$c / $max"
	if {$r < 1} {
		set r 1
	} elseif {!$data($w:expand) && $r == $max} {
		# on a atteint le fond de la table
#puts "adjusting at bottom"
		incr r -1
		set activate 0
	    $w activate "0,0"
	}

	$w selection clear all
#puts "$r,$c / !$isActive && $activate && $wasActive"
	if {!$isActive && $activate && $wasActive} {
	    $w activate $r,$c
		completion:start $w $r,$c
	} elseif {!$isActive} {
#puts "setting selection to $r,$c"
		$w selection set $r,$c
		$w selection anchor $r,$c
		completion:stop $w
	} else {
		completion:stop $w
	}
    $w see $r,$c

	# catch car appuie sur <End> déplace en 100000,10000 : pas une "vraie" cellule
	catch { showButtonTip $w -1 -1 $r $c }
}

proc Table::showButtonTip {w x y r c} {
variable data

	if {$x != -1} {
		set r [$w index @$x,$y row]
		set c [$w index @$x,$y col]
	}

	if {$c >= $data($w:colsButton)} {
		if {![string equal $data(t:oldCell) "$r,$c"]} {
			set ::DynamicHelp::_registered(__manual__) \
					[uplevel #0 $data($w:buttonTip) [expr {$c-$data($w:colsButton)}] [$w get $r,0]]
			foreach {bbx bby bbw bbh} [$w bbox $r,$c] break
			set bbx [expr {[winfo rootx $w]+$bbx-13}]
			set bby [expr {[winfo rooty $w]+$bby+$bbh-10}]
			::DynamicHelp::_show_help __manual__ $bbx $bby
			set data(t:oldCell) $r,$c
			if {$data(t:timer) != ""} {
				after cancel $data(t:timer)
			}
			set data(t:timer) [after 5000 "destroy  $::DynamicHelp::_top"]
		}
	} else {
		destroy  $::DynamicHelp::_top
		set data(t:oldCell) ""
	}
}

#----------------------------------------------------------------------------------------------

proc Table::completion:init {w} {
	# toplevel windows pour la listbox offrant la completion (cachée par défaut)
	set top .c[winfo name [winfo parent $w]]
	destroy $top
	toplevel $top
	wm transient $top
	wm overrideredirect $top 1
	wm withdraw $top
	# la listbox dans une scrollwindow
	set sw [ScrolledWindow::create $top.sw \
					-scrollbar both -auto both -relief sunken -borderwidth 1]
	set list [listbox [ScrolledWindow::getframe $sw].l -bd 1 -bg gray95 -height 8 \
					-font [$w cget -font] -bg [$w cget -bg] \
					-selectbackground $::skating::gui(color:selection) -selectmode browse]
	ScrolledWindow::setwidget $sw $list
	pack $sw -fill both
	# bindings de la liste
	bindtags $list [list Listbox $list $top all]
	bind $list <1> {
		upvar #0 ::table$Table::listbox(%W) table
		%W selection clear 0 end
		%W selection set [%W nearest %y]
		%W selection anchor [%W nearest %y]
		set table(active) [%W get [%W nearest %y]]
		focus %W
	}
	bind $list <Double-1> {
		upvar #0 ::table$Table::listbox(%W) table
		set table(active) [%W get [%W nearest %y]]
		focus $Table::listbox(%W)
		event generate $Table::listbox(%W) <Return>
	}
	bind $list <Return> {
		upvar #0 ::table$Table::listbox(%W) table
		set table(active) [%W get active]
		focus $Table::listbox(%W)
		event generate $Table::listbox(%W) <Return>
	}
	bind $list <Escape> { focus $Table::listbox(%W); event generate $Table::listbox(%W) <Escape> }

	bind $list <Up> {
		if {[%W index active] == 0} {
			%W selection clear 0 0
			focus $Table::listbox(%W)
			break
		}
	}
	bind $list <<ListboxSelect>> {
		upvar #0 ::table$Table::listbox(%W) table
		set table(active) [%W get active]
	}

	variable listbox
	set listbox($list) $w
}

proc Table::completion:start {w cell} {
variable data

	if {$data($w:completion) != ""} {
		set top .c[winfo name [winfo parent $w]]
		set list [ScrolledWindow::getframe $top.sw].l
	  	set bbox [$w bbox $cell]
	  	foreach {x y ww hh} $bbox break
#puts "wm geometry $top ${ww}x[winfo reqheight $list]+[expr [winfo rootx $w]+$x]+[expr [winfo rooty $w]+$y+$hh]"
		wm withdraw $top
		catch { wm geometry $top ${ww}x[winfo reqheight $list]+[expr [winfo rootx $w]+$x]+[expr [winfo rooty $w]+$y+$hh] }
	}
}

proc Table::completion:fill {w cell} {
variable data

#puts "Table::completion:fill $w $cell"
	if {$data($w:completion) != ""} {
		set top .c[winfo name [winfo parent $w]]

		upvar #0 ::table$w table
		if {[info exists table($cell)]} {
			set stem $table($cell)
		} else {
			set stem ""
		}
		set result [uplevel #0 $data($w:completion) \
						[ScrolledWindow::getframe .c[winfo name [winfo parent $w]].sw].l \
						[list $stem] [$w index $cell col]]
		if {$result} {
		  	wm deiconify $top
		  	raise $top
		} else {
			wm withdraw $top
		}
	}
}

proc Table::completion:stop {w} {
variable data

	if {$data($w:completion) != ""} {
		wm withdraw .c[winfo name [winfo parent $w]]
	}
}

proc Table::completion:select {w} {
variable data

	if {$data($w:completion) != ""} {
		set list [ScrolledWindow::getframe .c[winfo name [winfo parent $w]].sw].l
		focus $list
		$list selection clear 0 end
		$list selection set 0
		$list selection anchor 0
	}
}

bind MyTable <Unmap> "Table::completion:stop %W"
bind MyTable <Leave> "destroy $::DynamicHelp::_top; set Table::data(t:oldCell) {}"
bind MyTable <Enter> "set Table::data(t:oldCell) {}"

#==============================================================================================

bind MyTable <3> {
	if {[winfo exists %W] && $Table::data(%W:popup) != "" && [Table::validate:entry %W]} {
		%W activate 0,0
		%W selection clear all
		set cell [%W index @%x,%y]
		%W selection set $cell
		%W selection anchor $cell
		set tkPriv(tkCurrentTable) %W
		tk_popup $Table::data(%W:popup) %X %Y
	}
}

#----------------------------------------------------------------------------------------------

#  bind MyTable <Leave> {
#  	catch {%W activate active}
#  }

bind MyTable <Visibility> { focus %W }
bind MyTable <Enter> { focus %W }

#----------------------------------------------------------------------------------------------

set mytable_clipboard ""
bind MyTable <Control-c> {
    if {[%W index active] == "0,0"} {
		set mytable_clipboard [%W get anchor]
	} else {
		set mytable_clipboard [%W get active]
	}
#puts "clip set to '$mytable_clipboard'"
	break
}
bind MyTable <Control-v> {
	if {$mytable_clipboard == ""} {
		break
	}
    if {[%W index active] == "0,0"} {
		set where anchor
	} else {
		set where active
	}

	set validation [%W cget -validatecommand]
	set cmd [string map [list %%c [%W index $where col] %%r [%W index $where row] \
							  %%S [list $mytable_clipboard]] $validation]
	if {[eval $cmd]} {
		%W set $where $mytable_clipboard
	}
	break
}

bind MyTable <Control-KeyPress> { break }
bind MyTable <Alt-KeyPress> { break }


bind MyTable <KeyPress> {
	if {[%W index anchor col] >= $Table::data(%W:colsButton)} {
		uplevel #0 $Table::data(%W:buttonHandle) %K \
				[set ::table%W([%W index anchor row],0)] [%W index anchor row] \
				[expr {[%W index anchor col]-$Table::data(%W:colsButton)}]
	} elseif {[string compare %A {}] != 0} {
		# auto-toggle édition
	    if {[%W index active] == "0,0"} {
			%W selection clear all
			%W activate [%W index anchor]
			%W delete active 0 end
			Table::completion:start %W [%W index anchor]
	    }
		# ok pour ajouter la lettre
		if {$Table::data(%W:upperCaseInColumn0) && [%W index active col]==0} {
			%W insert active insert [string toupper %A]
		} else {
			%W insert active insert %A
		}
		Table::completion:fill %W active
    }
}

bind MyTable <BackSpace> {
    set tkPriv(junk) [%W icursor]
    if {[string compare {} $tkPriv(junk)] && $tkPriv(junk)} {
		%W delete active [expr {$tkPriv(junk)-1}]
		Table::completion:fill %W active
    }
}
bind MyTable <Delete> {
	%W delete active insert
	Table::completion:fill %W active
}

bind MyTable <Return> {
	if {[Table::validate:entry %W]} {
		if {$Table::data(%W:returnToCol)} {
			if {[%W index active col] != $Table::data(%W:colsButton)-1} {
				Table::moveCell %W 0 +1 1
			} else {
				Table::moveCell %W +1 [expr -$Table::data(%W:colsButton)+1] 1
			}
		} else {
			Table::moveCell %W +1 0 1
		}
	}
}
bind MyTable <Escape> {
	%W reread
	if {[%W index active row]+1 == [%W cget -rows] && [%W index active col]==0
			&& [uplevel #0 $Table::data(%W:candelete) [%W get active]]} {
		if {$Table::data(%W:expand) && [%W index active row] > 1} {
			%W delete row end 1
		}
		%W selection anchor [%W index active row],[%W index active col]
		%W activate 0,0
		%W selection clear all
		%W selection set anchor
	} elseif {[Table::validate:entry %W] && [set old [%W index active]] != "0,0"} {
		%W activate 0,0
		%W selection clear all
		%W selection set $old
		%W selection anchor $old
	}
	Table::completion:stop %W
}


bind MyTable <ButtonPress-1> {
    set col [%W border mark %x %y]
#puts "col='$col'"
	if {$col != "" && [lindex $col 1] > $Table::data(%W:resize)} {
		set tkPriv(tkTableMode) "resize"
	} else {
		set tkPriv(tkTableMode) "select"
	}
}
bind MyTable <B1-Motion> {
	if {$tkPriv(tkTableMode) == "resize"} {
		%W border dragto %x %y
	}
}


bind MyTable <Motion> {
	Table::showButtonTip %W %x %y 0 0
}


bind MyTable <ButtonRelease-1> {
	if {$tkPriv(tkTableMode) != "resize"} {
	    if {[winfo exists %W] && [Table::validate:entry %W]} {
			%W activate 0,0
			%W selection clear all
			%W selection set @%x,%y
			%W selection anchor @%x,%y
			Table::completion:stop %W
	    }
	}
}

bind MyTable <Double-ButtonRelease-1> { }
bind MyTable <Double-1> {
    if {[winfo exists %W] && [Table::validate:entry %W]
			&& [%W index @%x,%y row] > 0} {
		if {[%W index @%x,%y col] >= $Table::data(%W:colsButton) 
					&& [%W index anchor col] >= $Table::data(%W:colsButton)} {
			uplevel #0 $Table::data(%W:buttonHandle) space \
				[set ::table%W([%W index anchor row],0)] [%W index anchor row] \
				[expr {[%W index anchor col]-$Table::data(%W:colsButton)}]
		} else {
			%W selection clear all
			%W activate @%x,%y
			if {[%W index @%x,%y row] < $Table::data(%W:colsButton)} {
				Table::completion:start %W [%W index @%x,%y]
			}
		}
    }
}
bind MyTable <F2> {
    if {[winfo exists %W] && [%W index active] == "0,0"} {
		%W selection clear all
		%W activate [%W index anchor]
		Table::completion:start %W [%W index anchor]
    }
}


bind MyTable <Tab> {
	if {[winfo exists %W] && [Table::validate:entry %W]} {
		if {$Table::data(%W:returnToCol)} {
			Table::moveCell %W 0 +1 1
		} else {
			Table::moveCell %W +1 0 1
		}
	}
	break
}
bind MyTable <Shift-Tab> {
	if {[winfo exists %W] && [Table::validate:entry %W]} {
		Table::moveCell %W 0 -1 1
	}
	break
}
catch {
	bind MyTable <ISO_Left_Tab> {
		if {[winfo exists %W] && [Table::validate:entry %W]} {
			Table::moveCell %W 0 -1 1
		}
		break
	}
}
bind MyTable <Up>		{
	if {$Table::data(%W:expand) && [%W index active row]+1 == [%W cget -rows] && [%W index active col]==0} {
		%W delete rows end 1
		%W selection anchor [%W index active row],[%W index active col]
		%W activate 0,0
		%W selection clear all
		%W selection set anchor
		Table::completion:stop %W
	} elseif {[%W index active] == "0,0"} {
		Table::moveCell %W -1 0 0
	}
}
bind MyTable <Down>		{
	if {[%W index active] == "0,0"} {
		Table::moveCell %W 1 0 0
	} else {
		Table::completion:select %W
	}
}
bind MyTable <Left>		{
	if {[%W index active] != "0,0"} {
		set pos [%W icursor]
		incr pos -1
		%W icursor $pos
	} else {
		Table::moveCell %W 0 -1 0
	}
}
bind MyTable <Right>	{
	if {[%W index active] != "0,0"} {
		set pos [%W icursor]
		incr pos +1
		%W icursor $pos
	} else {
		Table::moveCell %W 0 1 0
	}
}
bind MyTable <Home>		{
	if {[%W index active] != "0,0"} {
		%W icursor 0
	} else {
		Table::moveCell %W -1000000 -1000000 0
	}
}
bind MyTable <End>		{
	if {[%W index active] != "0,0"} {
		%W icursor end
	} else {
		Table::moveCell %W 1000000 1000000 0
	}
}
bind MyTable <Prior>	{
	if {$Table::data(%W:expand) && [%W index active row]+1 == [%W cget -rows] && [%W index active col]==0} {
		%W delete row end 1
		%W selection anchor [%W index active row],[%W index active col]
		%W activate 0,0
		%W selection clear all
		%W selection set anchor
		Table::completion:stop %W
	} elseif {[%W index active] == "0,0"} {
		set nb [expr -([%W index bottomright row]-[%W index topleft row])]
		Table::moveCell %W $nb 0 0
	}
}
bind MyTable <Next>		{
	if {[%W index active] == "0,0"} {
		set nb [expr [%W index bottomright row]-[%W index topleft row]]
		Table::moveCell %W $nb 0 0
	}
}



bind MyTable <MouseWheel> {
    %W yview scroll [expr {- (%D / 120) * 4}] units
}

if {[string equal "unix" $tcl_platform(platform)]} {
    bind MyTable <4> {
        if {!$tk_strictMotif} {
            %W yview scroll -5 units
        }
    }
    bind MyTable <5> {
        if {!$tk_strictMotif} {
            %W yview scroll 5 units
        }
    }
}
