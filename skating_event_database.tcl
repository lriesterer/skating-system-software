##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion de la base données pour les noms juges & couples & écoles
#
#=================================================================================================

proc skating::event:database:start {} {
variable gui
variable db


	set db(judges) {}
	set db(couples) {}
	set db(schools) {}

	# charge le fichier
	if {![file exists $gui(pref:db)]} {
		return
	}
	if {[catch {set file [open $gui(pref:db) "r"]} errStr]} {
		after idle "skating::event:database:loadError [list $errStr]"
		return
	}
	fconfigure $file -encoding utf-8
	set whole [read $file]
	close $file
	# parse les nouvelles valeurs
	if {[catch {foreach {var value} $whole {
					foreach item $value {
						lappend db($var) $item
					}
				} } ]} {
		after idle "skating::event:database:loadError ???"
	}
}

proc skating::event:database:loadError {errStr} {
global msg

	tk_messageBox -icon "warning" -type ok -default ok \
			-title $msg(dlg:information) -message "$msg(dlg:loadDBFailed) ($errStr)"
}

#-------------------------------------------------------------------------------------------------

proc skating::event:database:save {} {
global msg
variable gui
variable db

#TRACEF "$gui(pref:db)"

	if {[catch {if {![file exists $gui(pref:db)] || 
					([file exists $gui(pref:db)] && [file writable $gui(pref:db)])} {
					# backup si pb
					catch {file rename -force -- $gui(pref:db) "$gui(pref:db).bak"}
					set out [open $gui(pref:db) "w"]
					fconfigure $out -encoding utf-8
					puts $out "judges {"
					set last ""
					foreach j [lsort -dictionary $db(judges)] {
						if {$j == "" || [string match -nocase "$msg(judge) *" $j] || $j == $last} {
							continue
						}
						puts $out "\t{$j}"
						set last $j
					}
					puts $out "}\n\ncouples {"
					set last ""
					foreach c [lsort -dictionary $db(couples)] {
						if {$c == "" || [string match -nocase "$msg(Couple) *" $c] || $c == $last} {
							continue
						}
						puts $out "\t{$c}"
						set last $c
					}
					puts $out "}\n\nschools {"
					set last ""
					foreach s [lsort -dictionary $db(schools)] {
						if {$s == "" || [string match -nocase "$msg(school) *" $s] || $s == $last} {
							continue
						}
						puts $out "\t{$s}"
						set last $s
					}
					puts $out "}"
#TRACE "DB saved"
					close $out
				}
			} errStr]} {
		# erreur
TRACE "ERROR = $errStr"
		tk_messageBox -icon "error" -type ok -default ok \
							-title $msg(dlg:error) -message $msg(dlg:saveDBFailed)
		catch {file rename -force -- "$gui(pref:db).bak" $gui(pref:db)}
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::event:database:refreshWithFile {} {
variable event

	foreach judge $event(judges) {
		event:database:updateJudges $judge
	}
	foreach couple $event(couples) {
		event:database:updateCouples $couple
	}
}

#-------------------------------------------------------------------------------------------------

proc skating::event:database:updateJudges {judge} {
variable event
variable gui
variable db

	set name $event(name:$judge)
	if {[lsearch -exact $db(judges) $name] == -1} {
		lappend db(judges) $name
	}
}

proc skating::event:database:updateCouples {couple} {
variable event
variable gui
variable db

	set name $event(name:$couple)
	if {[lsearch -exact $db(couples) $name] == -1} {
		lappend db(couples) $name
	}

	set name $event(school:$couple)
	if {[lsearch -exact $db(schools) $name] == -1} {
		lappend db(schools) $name
	}
}


#=================================================================================================


proc skating::event:database:export {} {
variable event
variable gui
variable db
global msg

	# export par copie dans le clipboard
	set lastj ""
	set lastc ""
	set lasts ""
	set jj [list ]
	set cc [list ]
	set ss [list ]
	foreach j [lsort -dictionary $db(judges)] \
			c [lsort -dictionary $db(couples)] \
			s [lsort -dictionary $db(schools)] {
		if { ! ([string match -nocase "$msg(judge) *" $j] || $j == $lastj)} {
			lappend jj $j
			}
		if { ! ([string match -nocase "$msg(Couple) *" $c] || $c == $lastc)} {
			lappend cc $c
		}
		if { ! ([string match -nocase "$msg(school) *" $s] || $s == $lasts)} {
			lappend ss $s
		}
		set lastj $j
		set lastc $c
		set lasts $s
	}
	# construit le clipboard
	clipboard clear -displayof $gui(w:db)
	clipboard append -displayof $gui(w:db) "$msg(Couple)\t$msg(school)\t$msg(judge)\n"
	clipboard append -displayof $gui(w:db) "------------------------------\t------------------------------\t------------------------------\n"
	foreach j $jj c $cc s $ss {
		clipboard append -displayof $gui(w:db) "$c\t$s\t$j\n"
	}
#TRACE "<to clipboard>"
}

proc skating::event:database:import {} {
variable event
variable gui
variable db
global msg

	if {[catch {set data [split [selection get -selection CLIPBOARD] "\n"]}]} {
		bell
		return
	}
#TRACE "<from clip>-------------------------------------------------------------------"
#TRACE "<from clip> selection = "; foreach line $data {puts "    $line"}

	# efface listes
	set db(judges) [list ]
	set db(couples) [list ]
	set db(schools) [list ]
	# utilise les nouvelles données
	foreach row [lrange $data 2 end] {
		foreach {c s j} [split $row "\t"] break
		if {$c != "" && [lsearch -exact $db(couples) $c] == -1} {
			lappend db(couples) $c
		}
		if {$s != "" && [lsearch -exact $db(schools) $s] == -1} {
			lappend db(schools) $s
		}
		if {$j != "" && [lsearch -exact $db(judges) $j] == -1} {
			lappend db(judges) $j
		}
	}
	# modification à sauver
	set gui(v:db:modified) 1
}

