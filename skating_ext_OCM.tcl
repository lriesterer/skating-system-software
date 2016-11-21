##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer


#==============================================================================
#
#	Interface pour le logiciel OCM
#
#==============================================================================

namespace eval OCM {
	variable OCMprotocol
	array set OCMprotocol {
		login			100
		checkout		101
		checkin			102
		scratch			103
		list_session	104
		list_heat		105
		list_entry		106
		list_judge		107
		list_dance		108
		list_marks		109
		promote_couple	110
		clear_couples	117
	}

	variable config
	array set config {
		host			192.168.0.2
		port			11310
		id				1
	}

	variable data
	array set data {
		id2round:-7			128
		id2round:-6			64
		id2round:-5			32
		id2round:-4			16
		id2round:-3			eight
		id2round:-2			quarter
		id2round:-1			semi
		id2round:0			finale

		round2id:finale		0
		round2id:semi		-1
		round2id:quarter	-2
		round2id:eight		-3
		round2id:16			-4
		round2id:32			-5
		round2id:64			-6
		round2id:128		-7

		id2nb:0				0
		id2nb:-1			6
		id2nb:-2			12
		id2nb:-3			24
		id2nb:-4			48
		id2nb:-5			96
		id2nb:-6			192
		id2nb:-7			384
	}
}

proc OCM::request {type {arg1 0} {arg2 0} {arg3 0}} {
	variable OCMprotocol
	variable config

	set sock [socket $config(host) [expr $config(port)+$config(id)]]
	fconfigure $sock -translation binary -encoding binary

	set data [binary format "iiii" $OCMprotocol($type) $arg1 $arg2 $arg3]
	puts -nonewline $sock $data
	flush $sock

	# get answer
	set data [read $sock 8]
	binary scan $data "ii" nb -
	set records [list]
	for {set i 0} {$i < $nb} {incr i} {
		set data [read $sock 8]
		if {$data eq ""} {
			continue
		}
		binary scan $data "ii" value size
		set data [read $sock $size]
		if {$data eq "\x00"} {
			set data ""
		}
		lappend records $value $data
	}

	close $sock

	return $records
}

#------------------------------------------------------------------------------

proc OCM::login {} {
global msg

TRACEF
	# sauve les paramètres de connexion
	variable config
	set config(host) $::skating::gui(pref:mode:linkOCM:server)
	set config(id)   $::skating::gui(pref:mode:linkOCM:id)

	# tentative de login
	if {[catch { request login $skating::gui(pref:mode:linkOCM:id) }]} {
		tk_messageBox -icon warning -type ok -default ok -title OCM \
				-message "$msg(dlg:OCM:errLogin)\n(#$config(id) on $config(host))"
		set ::skating::gui(v:linkOCM:logon) 0
	} else {
		set ::skating::gui(v:linkOCM:logon) 1
	}

	# info de connexion dans la barre de titre
	::skating::gui:setTitle
}


#------------------------------------------------------------------------------

proc OCM::reload {whatHeats} {
global msg

TRACEF

	# réinitialise les variables
	foreach f $skating::event(folders) {
		unset ::skating::$f
	}
	unset ::skating::event

	#------------------------
	# récupère données de OCM
	#------------------------

	set heats [request list_heat $whatHeats]

set heats [lrange $heats 0 1]

	set i 1
	progressBarInit "Reloading" "Reloading data from OCM (heats = $whatHeats)." "Competitions" [expr [llength $heats]/2]
	foreach {heat name} $heats {
		lappend ::skating::event(folders) folder$i
		variable ::skating::folder$i
		upvar 0 ::skating::folder$i folder

		set folder(heatid) 	$heat
		set folder(mode) 	normal
		skating::folder:init:normal folder$i "$name"

		# get data from OCM
		set dances [request list_dance $folder(heatid) 1]
		set judges [request list_judge $folder(heatid) 1]
		set couples [request list_entry $folder(heatid) 1]
		set marks [request list_marks $folder(heatid) 1]

		set rounds [lindex $dances 0]
		foreach {id name} [lrange $dances 2 end] {
			lappend folder(dances) $name
		}
		foreach {id name} $couples {
			if {[lsearch ::skating::event(couples) $id] == -1} {
				lappend ::skating::event(couples) $id
				set ::skating::event(name:$id) $name
				set ::skating::event(school:$id) ""
			}
		}

		foreach {id name} $judges {
			if {[lsearch ::skating::event(judges) $id] == -1} {
				lappend ::skating::event(judges) $id
				set ::skating::event(name:$id) $name
			}
		}

		# suivant
		progressBarUpdate 1
		progressBarIncrText
		incr i
parray folder
	}
	progressBarEnd

	set ::skating::event(version) 15
	set ::skating::event(useCountry) 0


parray ::skating::event
exit

	#-----------------------------------
	# fini setup après lecture des infos
	#-----------------------------------

	event:database:refreshWithFile
	# mode de sélection des juges pour fastentry
	event:judges:setMode

	# gestion des attributs (à partir v. 15)
	setAttributes

	# mémorise nom du fichier
	if {$whatHeats == 0} {
		set whatHeats ALL
	}
	set gui(v:filename) "OCM_${whatHeats}_[clock format [clock seconds] -format %Y%m%d_%H%M%S].ska"
	set gui(pref:print:html:outputdir) [file dirname $file]/web
	set gui(v:modified) 0
	wm title $gui(w:top) "3S - Skating System Software    \[[file tail $file]\]"
	# retire affichage sélection
	set ::skating::displayFolder ""
	set ::skating::displayRound ""
	# réinitialise affichage
	set gui(v:lastselection) ""
	set gui(v:folder) ""
	set gui(v:round) ""
	Tree::delete $gui(w:tree) [Tree::nodes $gui(w:tree) root]
	gui:redisplay
}


#------------------------------------------------------------------------------

proc OCM::refresh {f round} {
global msg
variable ::skating::$f
upvar 0 ::skating::$f folder

TRACEF

	# check si on a le heatid
	if {![info exists folder(heatid)]} {
		tk_messageBox -icon warning -type ok -default ok -title OCM \
				-message "$msg(dlg:OCM:noHeatId)"
		return
	}

	# seulement pour le mode normal
	if { ! ([string first "." $f] == -1 && $folder(mode) == "normal") } {
		bell
		return
	}

# 	# trouve le round pour lequel on n'a pas de données
# 	foreach currentRound $folder(levels) {
# 		if {![info exists folder(couples:$currentRound)]} {
# 			break
# 		}
# 	}
	set currentRound $round
TRACE "round = $currentRound"
TRACE "ID $folder(heatid)"

	set sum 0
	foreach n [array names folder notes:finale:*] {
		set sum [expr $sum+[join $folder($n) +]]
	}
	if {$sum > 0} {
TRACE "---- notes/mark exists"
		set doit [tk_messageBox -icon "question" -type okcancel -default ok \
							-title "This will erase all data for current round" \
							-message $msg(dlg:resetRounds)]
		if {$doit != "ok"} {
			return 0
		}
	}

	variable data
	set currentId $data(round2id:$currentRound)

	# récupère les données
	set dances [request list_dance $folder(heatid) $currentId]
	set startId [lindex $dances 0]
TRACE "dances  = $currentId <-> $startId // $dances"

	if {$currentId <= $startId} {
		# si on est <= au startId, reconstruit tout
		foreach pattern { dances 
						  levels
						  judges:*
						  couples:*
						  notes:*
						  round:* } {
			foreach n [array names folder $pattern] {
				unset folder($n)
			}
		}

		# danses
		foreach {- name} [lrange $dances 2 end] {
			lappend folder(dances) $name
		}

		# rounds
		set i $startId
		while {$i <= 0} {
			set round $data(id2round:$i)
			lappend folder(levels) $round
			set folder(round:$round:use)   1
			set folder(round:$round:split) 0
			set folder(round:$round:nb)    $data(id2nb:$i)
			set folder(round:$round.2:nb)  0
			incr i
		}
		set folder(round:use50%rule) 	0
		set folder(round:generation) 	user
		set folder(round:explicitNames) 0

		# judges
		foreach round $folder(levels) {
			set judges [request list_judge $folder(heatid) $data(round2id:$round)]
			set list [string map {{ } {} , { }} [lindex $judges 1]]
			set folder(judges:$round) $list

			lappend folder(judges:requested) $list
		}
		set folder(judges:requested) [lsort -unique [join $folder(judges:requested)]]
		
		# couples
		set couples [request list_entry $folder(heatid) $startId]
TRACE "couples($startId) = [llength $couples] / $couples"
		set folder(couples:all) [list]
		set folder(couples:names) [list]
		foreach {id name} $couples {
			# trouve le nom et le crée si besoin
			set maxid $id
			set found 0
			foreach item [array names ::skating::event name:$id*] {
				set nameid [lindex [split $item :] 1]
				if {$::skating::event($item) == $name} {
					set found 1
					break
				}
				if {$nameid > $maxid} {
					set maxid $nameid
				}
			}
#TRACE "$name // $found // $nameid // $maxid"
			if {$found == 0} {
				set nameid [expr {$maxid+0.1}]
TRACE "--- creating $nameid"
				lappend ::skating::event(couples) $nameid
				set ::skating::event(name:$nameid) $name
				set ::skating::event(school:$nameid) ""
			}

			# info sur le couple
			lappend folder(couples:all) $id
			lappend folder(couples:names) $nameid
		}


		#set marks [request list_marks $folder(heatid) 1]
		#TRACE "marks   = $marks"


		# mise à jour
		::skating::manage:rounds:explicitNames $f
		::skating::manage:rounds:generate $f force
		::skating::gui:select:folder $f ""

##parray folder

	} else {
		# sinon, on refraichi le round courant

TRACE "refreshing $currentId"

		# les juges
		set judges [request list_judge $folder(heatid) $currentId]
TRACE "judges($currentId) = [llength $judges] / $judges"
		set list [string map {{ } {} , { }} [lindex $judges 1]]
		set folder(judges:$currentRound) $list

		# les couples
		set couples [request list_entry $folder(heatid) $currentId]
TRACE "couples($currentId) = [llength $couples] / $couples"
		set folder(couples:$currentRound) [list]
		foreach {id name} $couples {
			lappend folder(couples:$currentRound) $id
		}

		::skating::gui:select:folder $f ""
	}
	

}

#------------------------------------------------------------------------------

proc OCM::promote:round {f round} {
TRACEF
global msg
variable ::skating::$f
upvar 0 ::skating::$f folder

	# check si on a le heatid
	if {![info exists folder(heatid)]} {
		tk_messageBox -icon warning -type ok -default ok -title OCM \
				-message "$msg(dlg:OCM:noHeatId)"
		return
	}

	# conversion round --> ID
	variable data
	set nextId $data(round2id:$round)

	# nettoyage avant promotion
	request clear_couples $folder(heatid) $nextId

	# list des couples promus
	foreach couple $folder(couples:$round) {
		request promote_couple $folder(heatid) $couple $nextId
	}

	tk_messageBox -icon info -type ok -default ok -title OCM \
			-message "Couples $folder(couples:$round)\nsuccessfully promoted to '$folder(round:$round:name)'"
}

#------------------------------------------------------------------------------

proc OCM::promote:finale {f} {
TRACEF
global msg
variable ::skating::$f
upvar 0 ::skating::$f folder

	# check si on a le heatid
	if {![info exists folder(heatid)]} {
		tk_messageBox -icon warning -type ok -default ok -title OCM \
				-message "$msg(dlg:OCM:noHeatId)"
		return
	}

	# list des couples promus
	foreach couple $folder(couples:finale) {
		request promote_couple $folder(heatid) $couple [expr {int($folder(t:place:$couple))}]
	}

	tk_messageBox -icon info -type ok -default ok -title OCM \
			-message "Couples $folder(couples:finale)\n places successfully saved."
}

#------------------------------------------------------------------------------

proc OCM::getMarks {f round d dd} {
global msg
variable ::skating::$f
upvar 0 ::skating::$f folder

TRACEF

	# check si on a le heatid
	if {![info exists folder(heatid)]} {
		tk_messageBox -icon warning -type ok -default ok -title OCM \
				-message "$msg(dlg:OCM:noHeatId)"
		return
	}

	# get round
	variable data
	set roundId $data(round2id:$round)


	set judges [lsort [request list_judge $folder(heatid) $roundId]]
	set list [string map {{ } {} , { }} [lindex $judges 1]]
TRACE "$folder(heatid) = $judges // $list // $folder(judges:$round)   // roundId = $roundId"
	if {$list != [lsort $folder(judges:$round)]} {
		tk_messageBox -icon warning -type ok -default ok -title OCM \
				-message "Error synchro between judges in OCM and 3S."		
		set judges 
		#return
	}

	# liste des dances à traiter
	if {$d eq "all"} {
		set dances $folder(dances)
	} else {
		set dances [list $d]
	}

	# toutes les listes vides doivent exister
	set empty {}
	foreach judge $folder(judges:$round) {
		lappend empty 0
	}
	foreach couple $folder(couples:$round) {
		foreach dance $dances {
			if {![info exists folder(notes:$round:$couple:$dance)]} {
				set folder(notes:$round:$couple:$dance) $empty
				continue
			}
		}
	}

	# préparation des index
	set i 0
	foreach judge $folder(judges:$round) {
		set index [string first $judge "ABCDEFGHIJKLMNOPQRSTUVWXYZ"]
		lappend judgesIndices $index $i
TRACE "list judges: $judge --> $index : $i"
		incr i
	}

	# récupération des danses
	set dancesOCM [request list_dance $folder(heatid) $roundId]
TRACE "OCM = $dancesOCM"
	set index 0
	foreach {id name} [lrange $dancesOCM 2 end] {
		set dance2index($name) $index
		incr index
	}

	set sizeJudges [llength $judges]
	set sizeDances $index
TRACE "sizeJudges = $sizeJudges / sizeDances = $sizeDances"

	# récupération des notes
	set content [request list_marks $folder(heatid) $roundId]
#	set content [request list_marks $folder(heatid) 1]
TRACE "--> $content"
	foreach {couple notes} $content {
		set notes [split $notes {}]
#TRACE "$couple / $notes"
		foreach dance $dances {
			set danceIndex $dance2index($dance)
#TRACE "dances = $dances / index = $danceIndex"
			foreach {ocmIndex skaIndex} $judgesIndices {
				set note [lindex $notes [expr $danceIndex+$sizeDances*$ocmIndex]]
				if {$note eq ""} {
					continue
				}
				set name notes:$round:$couple:$dance
#TRACE "$name : $skaIndex = $note  //  $danceIndex+$sizeDances*$ocmIndex"
				set folder($name) [lreplace $folder($name) $skaIndex $skaIndex $note]
			}
		}
	}

	# mise-à-jour affichage
	if {$round eq "finale"} {
		skating::notes:draw $f $dd
	} else {
		skating::round:draw $skating::gui(w:canvas:$round:$dd) $f $dd $round
	}
}

#------------------------------------------------------------------------------

proc OCM::init {} {
TRACEF

	set ::skating::gui(v:linkOCM:logon) 0
	if {$skating::gui(pref:mode:linkOCM) == 0} {
		return
	}

TRACE "using OCM"

	# login as OCM scrutineer
	if {$skating::gui(pref:mode:linkOCM:autologin)} {
		OCM::login
	}
}
