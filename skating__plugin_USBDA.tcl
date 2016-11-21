##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer


#==============================================================================
#
#	Interface pour format de l'USBDA
#
#==============================================================================


proc skating::plugin:usbda {} {
global msg
variable gui

	# boite de dialogue pour le choix du fichier
    set types [list [list $msg(fileText)	{.txt}] \
					[list $msg(fileAll) 	*] ]
	if {$gui(v:filename) == $msg(noName)} {
		set file [tk_getOpenFile -filetypes $types -parent $gui(w:tree)]
	} else {
		set file [tk_getOpenFile -filetypes $types -parent $gui(w:tree) \
								-initialdir [file dirname $gui(v:filename)]]
	}
	if {$file == ""} {
		return
	}

	# lit le fichier
	set in [open $file]
	set content [read $in]
	close $in
TRACE "$file read"

	# récupère les données
	set mode ""
	foreach line [split $content \n] {
		# passe les commentaires et les lignes vides
		if {$line == "" || [string range $line 0 1] == "#"} {
			continue
		}
		# regarde si on commence une nouvelle section
		if {[llength [split $line ,]] == 1} {
			set mode $line
			continue
		}

		# en fonction du mode
		switch $mode {
			events {
				foreach {id number level style} [split $line ,] break
				lappend listEvents $id
				set dataEvents($id:number) $number
				set dataEvents($id:level) $level
				set dataEvents($id:style) $style
			}

			dances {
				foreach {id name} [split $line ,] break
				set dataDances($id) $name
			}

			couples {
				foreach {id number name school} [split $line ,] break
				lappend listCouples $id
				set dataCouples($id:number) $number
				set dataCouples($id:name) $name
				set dataCouples($id:school) $school
			}

			judges {
				foreach {id letter name} [split $line ,] break
				lappend listJudges $id
				set dataJudges($id:letter) $letter
				set dataJudges($id:name) $name
			}

			mapping {
				foreach {eventID danceID} [split $line ,] break
				lappend dataMapping($eventID) $danceID
			}

			registration {
				set tmp [split $line ,]
				set dataRegistration([lindex $tmp 0]) [lrange $tmp 1 end]
			}
		}
	}


TRACE $listEvents
parray dataEvents
parray dataDances
parray dataCouples
parray dataMapping
parray dataRegistration


	# les variables
	variable event
	variable gui

	# initialise les couples
	foreach id $listCouples {
		lappend event(couples) $dataCouples($id:number)
		set event(name:$dataCouples($id:number)) $dataCouples($id:name)
		set event(school:$dataCouples($id:number)) $dataCouples($id:school)
	}

	# initialise les juges
	foreach id $listJudges {
		lappend event(judges) $dataJudges($id:letter)
		set event(name:$dataJudges($id:letter)) $dataJudges($id:name)
	}

	# initialise les dossiers
	set i 1
	foreach eventID $listEvents {
		set dances [list]
		foreach danceID $dataMapping($eventID) {
			lappend dances $dataDances($danceID)
		}
		set label "$dataEvents($eventID:number)"
		append label " - $dataEvents($eventID:level) $dataEvents($eventID:style)"
		# création de la compétition
	  	set f "folder$i"
	  	folder:init:normal $f $label $dances
		lappend event(folders) $f
		incr i

		# inscrit les couples dans la compétition
		variable $f
		upvar 0 $f folder
		# set the couples computing
		foreach coupleID $dataRegistration($eventID) {
TRACE "appending $dataCouples($coupleID:number) to $f"
			lappend folder(couples:all) [expr int($dataCouples($coupleID:number))]
			lappend folder(couples:names) $dataCouples($coupleID:number)
		}

		set folder(couples:all) [lsort -integer $folder(couples:all)]
		set folder(couples:names) [lsort -real $folder(couples:names)]

parray folder

	}

	# sort en position neutre
	set gui(v:folder) ""
}


#------------------------------------------------------------------------------


namespace eval skating {
	regsub -all -- {\.} $::version "" vv
	if {$vv < 534} {
		tk_messageBox -icon warning -type ok -default ok -title Plugin \
				-message "Need to 3S to use the USBDA plugin"
	} else {
		lappend plugins(IO) "From USBDA file" skating::plugin:usbda
	}
}
