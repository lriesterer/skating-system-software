##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion de la sortie d'un événement en HTML
#
#=================================================================================================


source skating_print_html_template.tcl

array set skating::gui {
	pref:print:html:outputdir			"/tmp/html"

	pref:print:html:logo				""

	pref:print:html:repeatCouples		5
	pref:print:html:repeatHeader		40
	pref:print:html:repeatHeaderSummary	10
	pref:print:html:resultsLogo			"<img src=\"cup1_big.gif\" align=middle>&nbsp;&nbsp;&nbsp;"

	pref:print:html:dataFilename		"data.ska"
	pref:print:html:archiveFilename		"site.zip"

	pref:print:html:user:defined		0
	pref:print:html:user:title			""
	pref:print:html:user:links			{}

	pref:print:html:email				"joe@foo.com"

	pref:print:html:output:rounds		1
	pref:print:html:output:summaries	1
	pref:print:html:output:idsf			1
}
#  	pref:print:html:user:title			"User"
#  	pref:print:html:user:links			{link1 link1 link2 link2}

#-------------------------------------------------------------------------------------------------

proc skating::print:html {} {
variable html
variable event
variable gui
global msg

#TRACEF

	# génère la feuille de style & copie les images
	print:html:generatepage "skating.css" stylesheet
	foreach image $html(images) {
		foreach path [list . $::pathExecutable] {
			set file [file join $path $image]
#TRACE "trying $file"
			if {[file exists $file]} {
				break
			}
		}
#TRACE "copying $file to $gui(pref:print:html:outputdir)"
		catch { file copy -force $file $gui(pref:print:html:outputdir) }
	}
	if {$gui(pref:print:html:logo) != ""} {
		catch { file copy -force $gui(pref:print:html:logo) $gui(pref:print:html:outputdir) }
	}

	# page d'accueil
	print:html:index
	# données générales
	print:html:couples
	print:html:judges
	print:html:panels
	# les données informatiques sources
	io:save "$gui(pref:print:html:outputdir)/$gui(pref:print:html:dataFilename)"

	# user data
	if {$gui(pref:print:html:user:title) != ""} {
		foreach {text filename} $gui(pref:print:html:user:links) {
			set nav [print:html:navigation $filename.html]
			print:html:generatepageCompressed "$filename.html" body \
					%NAVIGATION% $nav \
					%BODY% "\n\n\n\n\n\n<!-- INSERT YOUR DATA HERE -->\n\n\n\n\n\n"
		}
	}

	# pages pour chaque compétition
	foreach f $event(folders) {
		variable $f
		upvar 0 $f folder

		if {[catch {print:html:folder:$folder(mode) $f}]} {
			tk_messageBox -icon "error" -type ok -default ok \
					-title $msg(dlg:error) -message [format $msg(dlg:cannotWeb) $folder(label)]
puts $::errorInfo
		}
		progressBarUpdate 1
	}
}

#----------------------------------------------------------------------------------------------

proc skating::print:html:generatepage {filename template args} {
variable gui
variable html

#puts "skating::print:html:generatepage {$filename $template '$args'}"
	set page [open "$gui(pref:print:html:outputdir)/$filename" "w"]
	fconfigure $page -encoding utf-8
	lappend args %LOGO%
	if {$gui(pref:print:html:logo) != ""} {
		lappend args "<img src=\"[file tail $gui(pref:print:html:logo)]\">"
	} else {
		lappend args ""
	}
	lappend args %EMAIL%
	lappend args $gui(pref:print:html:email)
	puts $page [string map $args $html($template)]
	close $page
	# montre progression
	progressBarIncrText
}

proc skating::print:html:generatepageCompressed {filename template args} {
variable gui
variable html

#puts "skating::print:html:generatepageCompressed {$filename $template '$args'}"
	set page [open "$gui(pref:print:html:outputdir)/$filename" "w"]
	fconfigure $page -encoding utf-8
	lappend args %LOGO%
	if {$gui(pref:print:html:logo) != ""} {
		lappend args "<img src=\"[file tail $gui(pref:print:html:logo)]\">"
	} else {
		lappend args ""
	}
	lappend args %EMAIL%
	lappend args $gui(pref:print:html:email)
	set content [string map $args $html($template)]
	regsub -all -- {[ \t]+} $content { } content
	regsub -all -line -- {^ } $content {} content
	regsub -all -- {\n<} $content {<} content
	puts $page $content
	close $page
	# montre progression
	progressBarIncrText
}

proc skating::print:html:append {var template value args} {
variable html
upvar $var content

#puts "skating::print:html:append {$var $template $value '$args'}"
	lappend args %BODY%
	lappend args $value
	append content [string map $args $html($template)]
}

proc skating::print:html:subst {template value args} {
variable html

#puts "skating::print:html:subst {$template $value '$args'}"
	lappend args %BODY%
	lappend args $value
	return [string map $args $html($template)]
}

proc skating::print:html:formatComment {comment} {
	regsub -all -- {\n\n} $comment {<p>} comment
	regsub -all -- {\n} $comment {<br>} comment
	regsub -all -- { } $comment {\&nbsp;} comment
	regsub -all -- {\t} $comment {\&nbsp;\&nbsp;\&nbsp;\&nbsp;} comment
	return $comment
}


#----------------------------------------------------------------------------------------------
#	Syntaxe de nommage
#----------------------------------------------------------------------------------------------
#
#	MAIN
#		acceuil+général		= index.html
#		couples				= couples.html
#		juges				= judges.html
#		panels				= panels.html
#
#	FOLDER NORMAL
#		données globales	= <folder>.html
#		résultat			= <folder>.res.html
#		résumé par couple	= <folder>.csum.html 
#		résumé par place	= <folder>.psum.html
#		round				= <folder>.<round>.html
#
#	FOLDER TEN
#		données globales	= <folder>.html
#		résultat			= <folder>.res.html
#		résumé par couple	= <folder>.csum.html 
#		résumé par place	= <folder>.psum.html
#		dance				= <folder>.<dance>.html
#
#----------------------------------------------------------------------------------------------

proc skating::print:html:navigation {selected} {
global msg
variable event
variable gui
variable html

	set nav ""

	#---- main
	print:html:append nav "nav:head" $msg(prt:general)
	foreach entry {index couples judges panels} {
		set text $msg(prt:$entry)
		if {$selected == "$entry.html"} {
			set text "<span class=selected>$text</span>"
		}
		print:html:append nav "nav:level1" \
				[print:html:subst "nav:anchor1" $text %HREF% $entry.html]
	}
	#---- les données informatiques (fichier '.ska')
	print:html:append nav "nav:level1" \
				[print:html:subst "nav:anchor1" $msg(prt:dataFor3S) \
				%HREF% $gui(pref:print:html:dataFilename)]
	#---- le site sous forme d'une archive zip
	print:html:append nav "nav:level1" \
				[print:html:subst "nav:anchor1" $msg(prt:siteArchive) \
				%HREF% $gui(pref:print:html:archiveFilename)]
	#---- user data
	if {$gui(pref:print:html:user:title) != ""} {
		append nav $html(nav:separator)
		print:html:append nav "nav:head" $gui(pref:print:html:user:title)
		foreach {text filename} $gui(pref:print:html:user:links) {
			if {$selected == "$filename.html"} {
				set text "<span class=selected>$text</span>"
			}
			print:html:append nav "nav:level1" \
					[print:html:subst "nav:anchor1" $text %HREF% $filename.html]
		}
	}

	#---- folders
	append nav $html(nav:separator)
	print:html:append nav "nav:head" $msg(prt:competitions)
	foreach f $event(folders) {
		variable $f
		upvar 0 $f folder

		set text $folder(label)
		if {$selected == "$f.html"} {
			set text "<span class=selected>$text</span>"
		}
		set content [print:html:subst "nav:anchor1" $text %HREF% $f.html]

		if {[string match "$f*" $selected]} {
			if {$folder(mode) == "ten"} {
				append content [print:html:navigation:dances $f $selected]
			} else {
				append content [print:html:navigation:rounds $f $selected]
			}
		}
		print:html:append nav "nav:level1" $content
	}

	# résultat = barre de navigation
	return $nav
}

proc skating::print:html:navigation:rounds {f selected} {
global msg
variable $f
upvar 0 $f folder
upvar nav nav

	# chaque round
	set content ""
	foreach round $folder(levels) {
		set text $folder(round:$round:name)
		if {$selected == "$f.$round.html"} {
			set text "<span class=selected>$text</span>"
		}
		print:html:append content "nav:anchor2" $text %HREF% $f.$round.html
	}
	# résultats
	set text $msg(prt:results)
	if {$selected == "$f.res.html" || $selected == "$f.psum.html" || $selected == "$f.csum.html"} {
		set text "<span class=selected>$text</span>"
	}
	print:html:append content "nav:anchor2" $text %HREF% $f.res.html
	
	return [print:html:subst "nav:level2" $content]
}

proc skating::print:html:navigation:dances {f selected} {
global msg
variable $f
upvar 0 $f folder
upvar nav nav

	# chaque danse
	set content ""
	foreach dance $folder(dances) {
		set text $dance
		if {$selected == "$f.$dance.html"} {
			set text "<span class=selected>$text</span>"
		}
		print:html:append content "nav:anchor2" $text %HREF% $f.$dance.html

		# pour chaque round
		if {[string match "$f.$dance*" $selected]} {
			variable $f.$dance
			upvar 0 $f.$dance Dfolder
			foreach round $Dfolder(levels) {
				set text $Dfolder(round:$round:name)
				if {$selected == "$f.$dance.$round.html"} {
					set text "<span class=selected>$text</span>"
				}
				print:html:append content "nav:anchor3" $text %HREF% $f.$dance.$round.html
			}
			set text $msg(prt:results)
			if {$selected == "$f.$dance.res.html" || $selected == "$f.$dance.psum.html" || $selected == "$f.$dance.csum.html"} {
				set text "<span class=selected>$text</span>"
			}
			print:html:append content "nav:anchor3" $text %HREF% $f.$dance.res.html
		}
	}
	# résultats
	set text $msg(prt:results)
	if {$selected == "$f.res.html" || $selected == "$f.psum.html" || $selected == "$f.csum.html"} {
		set text "<span class=selected>$text</span>"
	}
	print:html:append content "nav:anchor2" $text %HREF% $f.res.html
	
	return [print:html:subst "nav:level2" $content]
}


#=================================================================================================
#
#	Partie Principale - Données globales
#
#=================================================================================================

proc skating::print:html:main:title {} {
global msg
variable event

	set title $event(general:title)
	if {$title == ""} {
		set title $msg(noName)
	}
	if {![info exists event(general:date)]} {
		set event(general:date) ""
	}
	return [print:html:subst "main:title" $title %DATE% $event(general:date)]
}

#----------------------------------------------------------------------------------------------

proc skating::print:html:index {} {
global msg
variable event
variable gui

	set content [print:html:main:title]
	if {[info exists event(general:comment)] && $event(general:comment) != ""} {
		append content [print:html:subst "main:comment" [print:html:formatComment $event(general:comment)]]
	}

	# liste de compétitions, accès direct aux résultats
	set list ""
	set i 0
	foreach f $event(folders) {
		variable $f
		upvar 0 $f folder

		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		incr i
		print:html:append list "list:competition" "" \
				%COMPETITION% "<a href=\"$f.html\" class=show>$folder(label)</a>" \
				%RESULTS% [print:html:summary:nav $f ""] \
				%CLASS% $row
	}
	print:html:append results "list:competitions" $list \
				%COMPETITION% "$gui(pref:print:html:resultsLogo)$msg(prt:final)"

	# mise en page principale
	set nav [print:html:navigation index.html]
	print:html:append content "main:stats" "" \
				%COUPLES% "<a href=\"couples.html\">[llength $event(couples)] $msg(prt:couplesRegistered)</a>" \
				%JUDGES% "<a href=\"judges.html\">[llength $event(judges)] $msg(prt:judgesRegistered)</a>" \
				%RESULTS% $results
	print:html:generatepage "index.html" body %NAVIGATION% $nav %BODY% $content
}

#----------------------------------------------------------------------------------------------

proc skating::print:html:couples {} {
global msg
variable event

	set nav [print:html:navigation couples.html]
	set body [print:html:main:title]
	append body [print:html:list:couples]
	print:html:generatepage "couples.html" body %NAVIGATION% $nav %BODY% $body
}

proc skating::print:html:judges {} {
global msg
variable event
	
	set nav [print:html:navigation judges.html]
	set body [print:html:main:title]
	append body [print:html:list:judges $event(judges)]
	print:html:generatepage "judges.html" body %NAVIGATION% $nav %BODY% $body
}

proc skating::print:html:panels {} {
global msg
variable event

	# liste des panels de juges
	set content ""
	set i 0
	foreach panel $event(panels) {
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		incr i
		print:html:append content "list:panel" "" \
				%PANEL% $event(panel:name:$panel) \
				%JUDGES% $event(panel:judges:$panel) \
				%CLASS% $row
	}

	set nav [print:html:navigation panels.html]
	set body [print:html:main:title]
	print:html:append body "list:panels" $content \
				%PANEL% $msg(prt:panel) \
				%JUDGES% $msg(prt:judges)
	print:html:generatepage "panels.html" body %NAVIGATION% $nav %BODY% $body
}


#----------------------------------------------------------------------------------------------
#	Helpers - Liste de couples & juges
#----------------------------------------------------------------------------------------------

proc skating::print:html:list:judges {judges} {
global msg
variable event

	# liste des juges
	set content ""
	set i 0
	foreach judge $judges {
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		incr i
		print:html:append content "list:judge" "" \
				%JUDGE% $judge \
				%NAME% $event(name:$judge) \
				%CLASS% $row
	}

	return [print:html:subst "list:judges" $content %NAME% $msg(prt:judges)]
}

proc skating::print:html:list:couples {} {
global msg
variable event

	# liste des couples
	set content ""
	set i 0
	foreach couple [lsort -real $event(couples)] {
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		incr i
		print:html:append content "list:couple" "" \
				%COUPLE% $couple \
				%NAME% $event(name:$couple) \
				%SCHOOL% $event(school:$couple) \
				%CLASS% $row
	}

	# nom/école ou pays
	if {$event(useCountry)} {
		set text $msg(prt:country)
	} else {
		set text $msg(prt:school)
	}

	return [print:html:subst "list:couples" $content \
					%COUPLE% "&nbsp;" \
					%NAME% $msg(prt:couples) \
					%SCHOOL% $text]
}


#=================================================================================================
#
#	Partie Compétitions
#
#=================================================================================================

proc skating::print:html:folder:title {f} {
global msg
variable event
variable $f
upvar 0 $f folder

	set title $event(general:title)
	if {$title == ""} {
		set title $msg(noName)
	}
	return [print:html:subst "folder:title" $title %DATE% $event(general:date) \
							 %COMPETITION% $folder(label)]
}

#----------------------------------------------------------------------------------------------

proc skating::print:html:folder:normal {f} {
global msg
variable event
variable $f
upvar 0 $f folder

	# les résultats globaux
  	print:html:summary $f

	# génération des pages pour les rounds
	foreach round $folder(levels) {
		if {$round == "finale"} {
			print:html:finale $f
		} else {
			print:html:round $f $round
		}
	}

	#---- page des données globales
	# danses
	set content ""
	set i 0
	foreach dance $folder(dances) {
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		incr i
		print:html:append content "folder:list_dance" "" \
				%DANCE% $dance \
				%CLASS% $row
	}
	set list_dances [print:html:subst "folder:list_dances" $content \
									%DANCES% $msg(prt:dances)]

	# rounds
	set allJudges [list ]
	set content ""
	set i 0
	foreach round $folder(levels) {
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		incr i
		if {[string first ".2" $round] != -1} {
			set icon "icn_round_chance.gif"
		} elseif {[info exists folder(round:$round:split)] && $folder(round:$round:split)} {
			set icon "icn_round_main.gif"
		} else {
			set icon "icn_round.gif"
		}
		set allJudges [concat $allJudges $folder(judges:$round)]
		set nbCouples "?"
		if {[info exists folder(couples:$round)]} {
			set nbCouples [llength $folder(couples:$round)]
		}
		print:html:append content "folder:list_round" "" \
				%ICON% $icon \
				%ROUND% "<a href=\"$f.$round.html\" class=show>$folder(round:$round:name)</a>" \
				%NB_COUPLES% $nbCouples \
				%JUDGES% [lsort -command skating::event:judges:sort $folder(judges:$round)] \
				%CLASS% $row
	}
	set list_rounds [print:html:subst "folder:list_rounds" $content \
									%ROUND% $msg(prt:rounds) \
									%NB_COUPLES% $msg(prt:couples) \
									%JUDGES% $msg(prt:judges)]

	# juges
	set content ""
	set i 0
	foreach judge [lsort -unique -command skating::event:judges:sort $allJudges] {
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		incr i
		print:html:append content "list:judge" "" \
				%JUDGE% $judge \
				%NAME% $event(name:$judge) \
				%CLASS% $row
	}
	set list_judges [print:html:subst "list:judges" $content %NAME% $msg(prt:judges)]

	# couples
	set content ""
	set i 0
	foreach couple $folder(couples:all) {
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		incr i
		print:html:append content "list:couple" "" \
				%COUPLE% $couple \
				%NAME% [couple:name $f $couple] \
				%SCHOOL% [couple:school $f $couple] \
				%CLASS% $row
	}
	if {$event(useCountry)} {
		set text $msg(prt:country)
	} else {
		set text $msg(prt:school)
	}
	set list_couples [print:html:subst "list:couples" $content \
										%COUPLE% "&nbsp;" \
										%NAME% $msg(prt:couples) \
										%SCHOOL% $text]

	# mise en page principale
	set nav [print:html:navigation $f.html]
	set body [print:html:folder:title $f]
	print:html:append body "folder:summary:nav" [print:html:summary:nav $f ""]

  	print:html:append body "folder:general" "" \
			%LIST_DANCES% $list_dances \
			%LIST_ROUNDS% $list_rounds \
			%LIST_JUDGES% $list_judges \
			%LIST_COUPLES% $list_couples
	print:html:generatepage "$f.html" body %NAVIGATION% $nav %BODY% $body
}

#----------------------------------------------------------------------------------------------

proc skating::print:html:links {f round} {
global msg
variable event
variable gui
variable $f
upvar 0 $f folder

	set index [lsearch $folder(levels) $round]
	set previous [lindex $folder(levels) [expr {$index-1}]]
	set next [lindex $folder(levels) [expr {$index+1}]]
	set folder(round::name) ""
	# barre de navigation
	set links "<a href=\"$f.$previous.html\" class=summaryNav>"
	if {$previous != ""} {
		append links "<img src=\"prev.gif\" border=0>&nbsp;"
	}
	append links "$folder(round:$previous:name)</a>"
	if {$next != "" && $previous != ""} {
		append links "&nbsp;&nbsp&nbsp;|&nbsp;&nbsp;&nbsp;"
	}
	append links "<a href=\"$f.$next.html\" class=summaryNav>$folder(round:$next:name)"
	if {$next != ""} {
		append links "&nbsp;<img src=\"next.gif\" border=0>"
	}
	append links "</a>"

	return $links
}

#----------------------------------------------------------------------------------------------

proc skating::print:html:round {f round} {
global msg
variable event
variable gui
variable $f
upvar 0 $f folder

	# commentaires
	set comment ""
	if {[info exists folder(comments:$round)]} {
		set comment [print:html:formatComment $folder(comments:$round)]
	}

	# calcul des données
	set idx [lsearch -exact $folder(levels) $round]
	set next [lindex $folder(levels) [incr idx]]
	set force 0
	if {[info exists folder(couples:$next)]} {
		set force 1
	}
	if {[class:round $f $round $force] <= 0} {
		set nav [print:html:navigation $f.$round.html]
		print:html:generatepage "$f.$round.html" body %NAVIGATION% $nav %BODY% $msg(prt:notAvailable)
		return
	}
	set total [lsort -dictionary -index 0 $folder(result:$round)]
	set couples $folder(couples:$round)
	set judges [lsort -command skating::event:judges:sort $folder(judges:$round)]
	set next [rounds:next $f $round]
	if {([string first "." $round]==-1) && $folder(round:$round:split)} {
		set isSplit 1
	} else {
		set isSplit 0
	}
	# structure
	# | name | N° | Dance | ... | N° | ... | Result             |
	# |      |    |A B C D| ... |    | ... | Tot. | repris | N° |
	set nbCells [expr {2+([llength $folder(judges:$round)]+1)*[llength $folder(dances)] \
						+ 2*(int(ceil(1.0*[llength $folder(dances)]/$gui(pref:print:html:repeatCouples))))+ 7}]

	# génération du header
	set header "  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				  <tr class=header>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center rowspan=2>$msg(prt:couples)</td>"
	set d 0
	foreach dance $folder(dances) {
		if {($d % $gui(pref:print:html:repeatCouples)) == 0} {
			append header "<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
						   <td class=center rowspan=2>$msg(prt:couplesNb)</td>"
		}
		incr d
		append header "<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					   <td class=center colspan=[llength $folder(judges:$round)] width=\"1%\">$dance</td>"
	}
	append header "	<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center colspan=5 width=\"1%\">$msg(prt:result)</td>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
				  </tr>
				  <tr class=subheader>"
	foreach dance $folder(dances) {
		foreach judge $judges {
			append header "<td class=center2>$judge</td>"
		}
	}
	append header " <td class=center>$msg(prt:total)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$msg(prt:keepLabel)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$msg(prt:couple)</td>
				  </tr>
				  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"

	# les données
	set content $header
	set i 0
	foreach couple $couples {
		# répétition du header
		if {$i && ($i % $gui(pref:print:html:repeatHeader)) == 0} {
			append content $header
		}

		# regarde si pré-qualifié
		set preQualif [isPrequalified $f $couple $round]

		# les données
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		append content "<tr class=$row>
						<td class=border><img src=\"1x1.gif\" width=1></td>"
		# nom du couple (replace les espace par des espaces non-sécables pour mise en forme de la table)
		append content "<td class=left>[string map {{ } &nbsp;} [couple:name $f $couple]]</td>"
		# danses
		set d 0
		foreach dance $folder(dances) {
			# répétition du numéro des couples
			if {($d % $gui(pref:print:html:repeatCouples)) == 0} {
				append content "<td class=border><img src=\"1x1.gif\" width=1></td>
								<td class=centerHeader>$couple</td>"
			}
			incr d
			# les notes
			append content "<td class=border><img src=\"1x1.gif\" width=1></td>"
			set skip 0
			if {[lsearch $folder(dances:$round) $dance] == -1} {
				set skip 1
			}
			foreach judge $judges {
				set j [lsearch $folder(judges:$round) $judge]
				if {[lindex $folder(notes:$round:$couple:$dance) $j]} {
					if {$preQualif} {
						set text "+"
					} elseif {$gui(pref:print:useLetters)} {
						set text $judge
					} else {
						set text "X"
					}
				} elseif {$skip} {
					set text "-"
				} else {
					set text "."
				}
				append content "<td class=center2>$text</td>"
			}
		}
		# resultat & repris
		set sum [lindex [lindex $total $i] 1]
		if {$sum > 1000000} {
			set sum "P"
		}
		append content "<td class=border><img src=\"1x1.gif\" width=1></td>
						<td class=center>$sum</td>
						<td class=border><img src=\"1x1.gif\" width=1></td>"
		set text "&nbsp;"
		set color 0
		if {[info exists folder(couples:$next)]} {
			# si split, alors  on est en éliminatoire
			# si non split, que round soit simple ou .2, même logique
			if {$isSplit} {
				set ok [expr {([lsearch $folder(couples:$next) $couple] != -1) \
							 && ([lsearch $folder(couples:$round.2) $couple] == -1)}]
			} else {
				set ok [expr {[lsearch $folder(couples:$next) $couple] != -1}]
			}
			if {$preQualif} {
				set text "Pre"
				set color 1
			} elseif {$ok} {
				set text $msg(prt:yes)
				set color 1
			} elseif {$isSplit} {
				set text "R"
			}
		}
		append content "<td class=center>$text</td>
						<td class=border><img src=\"1x1.gif\" width=1></td>"
		if {$color} {
			if {$i % 2} {
				append content "<td class=centerHighlightOdd>$couple</td>"
			} else {
				append content "<td class=centerHighlight>$couple</td>"
			}
		} else {
			append content "<td class=center>$couple</td>"
		}
		append content "<td class=border><img src=\"1x1.gif\" width=1></td>"

		# suivant
		append content "</tr>"
		incr i
	}


	# mise en page principale
	set nav [print:html:navigation $f.$round.html]
	set body [print:html:folder:title $f]
	if {$comment != ""} {
		set comment [print:html:subst "folder:comment" $comment]
	}
	print:html:append body "folder:round" "" \
			%COMMENT% $comment \
			%RESULTS% " <table border=0 cellpadding=0 cellspacing=0>
						  $content
						  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
						</table>" \
			%LINKS% [print:html:links $f $round]
	print:html:generatepage "$f.$round.html" body %NAVIGATION% $nav %BODY% $body
}

#----------------------------------------------------------------------------------------------

proc skating::print:html:finale {f} {
global msg
variable event
variable gui
variable $f
upvar 0 $f folder


	# commentaires
	set comment ""
	if {[info exists folder(comments:finale)]} {
		set comment [print:html:formatComment $folder(comments:finale)]
	}

	# calcul des données
	if {![class:dances $f]} {
		set nav [print:html:navigation $f.finale.html]
		print:html:generatepage "$f.finale.html" body %NAVIGATION% $nav %BODY% $msg(prt:notAvailable)
		return
	}
	class:result $f
	set couples $folder(couples:finale)
	set judges [lsort -command skating::event:judges:sort $folder(judges:finale)]

	#--- résultats pour chaque danse
	#
	# | Dance                                       |
	# | name | N° | A B C D E | 1 2 3 4 5 6 | Place |
	set nbCells [expr {5 + [llength $judges] + 1 + [llength $couples] + 3}]
	set d 0
	foreach dance $folder(dances) {
		# header
		set r($dance) "<table border=0 cellpadding=0 cellspacing=0>
					  <tr class=header>
						<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
						<td class=center colspan=[expr {$nbCells-2}]>$dance</td>
						<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					  </tr>
					  <tr class=subheader>
						<td class=center>$msg(prt:couples)</td>
						<td class=border><img src=\"1x1.gif\" width=1></td>
						<td class=centerHeader>$msg(prt:couplesNb)</td>
						<td class=border><img src=\"1x1.gif\" width=1></td>"
		foreach judge $judges {
			append r($dance) "<td class=center>$judge</td>"
		}
		append r($dance) "<td class=border><img src=\"1x1.gif\" width=1></td>"
		set i 1
		foreach dummy $couples {
			append r($dance) "<td class=left>$i</td>"
			incr i
		}
		append r($dance) "<td class=border><img src=\"1x1.gif\" width=1></td>
						<td class=center>$msg(prt:placeAbbrev)</td>"

		# pour chaque couple
		set c 0
		foreach couple $couples {
			# les données
			set row "row"
			if {$c % 2} {
				set row "rowOdd"
			}
			append r($dance) "<tr class=$row>
							<td class=border><img src=\"1x1.gif\" width=1></td>"
			# nom du couple (replace les espace par des espaces non-sécables pour mise en forme de la table)
			append r($dance) "<td class=left>[string map {{ } &nbsp;} [couple:name $f $couple]]</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=centerHeader>$couple</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>"
			# vérifie si le couple est exclus
			if {[info exists folder(exclusion:finale:$dance)] &&
					[lsearch $folder(exclusion:finale:$dance) $couple] != -1} {
				set excluded 1
			} else {
				set excluded 0
			}
			#-- notes
			set i 0
			foreach judge $judges {
				set j [lsearch $folder(judges:finale) $judge]
				if {$excluded} {
					append r($dance) "<td class=center>-</td>"
				} else {
					append r($dance) "<td class=center>[lindex $folder(notes:finale:$couple:$dance) $j]</td>"
				}
				incr i
			}
			#-- data
			append r($dance) "<td class=border><img src=\"1x1.gif\" width=1></td>"
			set i 0
			foreach dummy $folder(couples:finale) {
				if {!$excluded} {
					set mark [lindex $folder(prt:$dance:mark+:$couple) $i]
					set total [lindex $folder(prt:$dance:marktotal:$couple) $i]
					set text "&nbsp;"
					if {$mark} {
						set text "$mark"
					}
					if {$total} {
						append text "<span class=exponent>$total</span>"
					}
				} else {
					set text "-"
				}
				append r($dance) "<td class=leftFixed>$text</td>"
				incr i
			}
			#-- place
			append r($dance) "<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=centerFixed>[lindex $folder(places:$couple) $d]</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>"
			# couple suivant
			append r($dance) "</tr>"
			incr c
		}

		# fin
		append r($dance) "<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" height=1></td></tr>
						</table>
						<br class=vskip>"
		# danse suivante
		incr d
	}
	foreach dance $folder(dances) {
		append results_dances $r($dance)
	}

	#---- le classement
	# header
	# | Classement                                                |
	# | Couple | N° | D1 | D2 | ... | Dn | Tot. | Place | Comment |
	set nbCells [expr {4 + 2*[llength $folder(dances)] + 7}]
	set results "<p>&nbsp;</p>
				 <table border=0 cellpadding=0 cellspacing=0>
				  <tr class=header>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center colspan=[expr {$nbCells-2}]>$gui(pref:print:html:resultsLogo)$msg(prt:final)</td>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
				  </tr>
				  <tr class=subheader>
					<td class=center>$msg(prt:couples)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=centerHeader>$msg(prt:couplesNb)</td>"
	foreach dance $folder(dances) {
		append results "<td class=border><img src=\"1x1.gif\" width=1></td>
						<td class=center>[firstLetters $dance]</td>"
	}
	append results "<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$msg(prt:tot)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$msg(prt:class)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$msg(prt:rules)</td>
				  </tr>"
	# données
	set rules(10) {}
	set rules(11) {}
	set rules(12) {}
	set rules(13) {}
	set rules(14) {}
	set rules(15) {}
	set rules(16) {}
	set rules(17) {}
	set c 0
	foreach couple $folder(couples:finale) {
		set row "row"
		if {$c % 2} {
			set row "rowOdd"
		}
		append results "<tr class=$row>
							<td class=border><img src=\"1x1.gif\" width=1></td>"
		# nom du couple (replace les espace par des espaces non-sécables pour mise en forme de la table)
		append results "<td class=left>[string map {{ } &nbsp;} [couple:name $f $couple]]</td>
						<td class=border><img src=\"1x1.gif\" width=1></td>
						<td class=centerHeader>$couple</td>"
		# par danse
		set j 0
		foreach dance $folder(dances) {
			append results "<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=center>[lindex $folder(places:$couple) $j]</td>"
			incr j
		}
		# total
		set tot [lindex $folder(totals) $c]
		if {[expr {int($tot)-$tot}] == 0} {
			set tot [expr {int($tot)}]
		}
		append results "<td class=border><img src=\"1x1.gif\" width=1></td>
						<td class=center>$tot</td>"
		# place
		set place [lindex $folder(result) $c]
		append results "<td class=border><img src=\"1x1.gif\" width=1></td>
						<td class=center>$place</td>"
		# rule
		set rule [lindex $folder(rules) $c]
		set text ""
		if {$rule >= 10} {
			lappend rules(10) $couple
			set text "   $msg(prt:rule) 10"
		}
		if {$rule >= 11} {
			lappend rules(11) $couple
			append text " & 11"
		}
		if {$rule >= 12} {
			lappend rules(12) $couple
			append text " & ..."
		}
		if {$rule >= 13} {
			lappend rules(13) $couple
		}
		if {$rule >= 14} {
			lappend rules(14) $couple
		}
		if {$rule >= 15} {
			lappend rules(15) $couple
		}
		if {$rule >= 16} {
			lappend rules(16) $couple
		}
		if {$rule >= 17} {
			lappend rules(17) $couple
		}
		if {$text == ""} {
			set text "&nbsp;"
		}
		append results "<td class=border><img src=\"1x1.gif\" width=1></td>
						<td class=left>$text</td>
						<td class=border><img src=\"1x1.gif\" width=1></td>
					  </tr>"
		# suivant
		incr c
	}
	append results "<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" height=1></td></tr>
				  </table>"

	#---- explications (Règles 10 & 11 & suivantes)
	set explanations "<table border=0 cellpadding=0 cellspacing=0>"
	set already11 0
	if {$gui(pref:print:explain) && [llength $rules(10)]} {
		skating::print:html:explanation_rules 10 11 1
	}
	# second niveau de 10 & 11
	if {$gui(pref:print:explain) && [llength $rules(12)]} {
		skating::print:html:explanation_rules 12 13 0
	}
	# troisième niveau de 10 & 11
	if {$gui(pref:print:explain) && [llength $rules(14)]} {
		skating::print:html:explanation_rules 14 15 0
	}
	# quatrième niveau de 10 & 11
	if {$gui(pref:print:explain) && [llength $rules(16)]} {
		skating::print:html:explanation_rules 16 17 0
	}
	append explanations "</table>"

	append results "<br class=vskip>$explanations"

	#---- mise en page principale
	set nav [print:html:navigation $f.finale.html]
	set body [print:html:folder:title $f]
	if {$comment != ""} {
		set comment [print:html:subst "folder:comment" $comment]
	}
	print:html:append body "folder:finale" "" \
			%COMMENT% $comment \
			%RESULTS_DANCES% $results_dances \
			%RESULTS_FINALE% $results \
			%LINKS% [print:html:links $f finale]
	print:html:generatepage "$f.finale.html" body %NAVIGATION% $nav %BODY% $body
}

proc skating::print:html:explanation_rules {rule10 rule11 needheader} {
variable event
variable gui
global msg

upvar y y c c f f folder folder rules rules already11 already11
upvar couples couples judges judges explanations explanations


	# calcul hauteur
	set need11 [llength $rules($rule11)]

	if {$needheader} {
		# | Couple | N° | Règle 10  | Règle 11  |
		# |             | 1 2 ... n | 1 2 ... n |
		append explanations "
				  <tr class=header>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center colspan=3>$msg(prt:rules)</td>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center colspan=[llength $couples]>$msg(prt:rule) 10</td>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>"
		if {$need11} {
			set majority [expr int([llength $folder(dances)]*[llength $judges])/2+1]
			append explanations "
					<td class=center colspan=[llength $couples]>$msg(prt:rule) 11 ($msg(prt:majority): $majority)</td>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>"
		}
		append explanations "
				  </tr>
				  <tr class=subheader>
					<td class=center>$msg(prt:couples)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=centerHeader>$msg(prt:couplesNb)</td>"
		set i 1
		foreach dummy $couples {
			append explanations "<td class=left>$i</td>"
			incr i
		}
		if {$need11} {
			set i 1
			foreach dummy $couples {
				append explanations "<td class=left>$i</td>"
				incr i
			}
		}
	}

	#---- données explicatives
	set c 0
	foreach couple $rules($rule10) {
		set row "row"
		if {$c % 2} {
			set row "rowOdd"
		}
		append explanations "<tr class=$row>
								<td class=border><img src=\"1x1.gif\" width=1></td>"
		# nom du couple (replace les espace par des espaces non-sécables pour mise en forme de la table)
		append explanations "<td class=left>[string map {{ } &nbsp;} [couple:name $f $couple]]</td>
							 <td class=border><img src=\"1x1.gif\" width=1></td>
							 <td class=centerHeader>$couple</td>"
		foreach rule {10 11} {
			append explanations "<td class=border><img src=\"1x1.gif\" width=1></td>"
			set i 0
			foreach dummy $folder(couples:finale) {
				# cas de la règle 11
				if {$rule == 11 && !$need11} {
					incr i
					continue
				}
				set mark [lindex $folder(prt:__[set rule$rule]__:mark+:$couple) $i]
				set total [lindex $folder(prt:__[set rule$rule]__:marktotal:$couple) $i]
				set text "&nbsp;"
				if {$mark != -1} {
					set text "$mark"
				}
				if {$total != -1} {
					if {[expr {int($total)}] == $total} {
						set total [expr {int($total)}]
					}
					append text "<span class=exponent>$total</span>"
				}
				append explanations "<td class=leftFixed2>$text</td>"
				# suivant
				incr i
			}
		}
		if {$need11} {
			append explanations "<td class=border><img src=\"1x1.gif\" width=1></td>"
		}
		append explanations "</tr>"
		# couple suivant
		incr c
	}

	set nbCells [expr {4+ (1+[llength $couples])*(1+$need11) + ($need11 ? 0 : 1)}]
	append explanations "<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"
}

#----------------------------------------------------------------------------------------------
#	Etat récapitulatif
#----------------------------------------------------------------------------------------------

proc skating::print:html:summary {f} {
global msg
variable $f
upvar 0 $f folder

	# effectue le classement
	if {[catch {set results [class:folder $f]}]} {
		set nav [print:html:navigation $f.res.html]
		print:html:generatepage "$f.res.html" body %NAVIGATION% $nav %BODY% $msg(prt:notAvailable)
		print:html:generatepage "$f.csum.html" body %NAVIGATION% $nav %BODY% $msg(prt:notAvailable)
		print:html:generatepage "$f.psum.html" body %NAVIGATION% $nav %BODY% $msg(prt:notAvailable)
		return
	}

	# trié par place
	print:html:summary:simple $f
	print:html:summary:extended $f place psum
	print:html:idsf:report $f
	# trié par couples
	print:html:summary:extended $f couple csum
	print:html:idsf:table $f
}

proc skating::print:html:summary:nav {f current {mode "normal"}} {
global msg

	if {$mode == "normal"} {
		set items {result:simple result:extended:place result:extended:couple
				   prt:idsf:report prt:idsf:table}
		set links {res psum csum ireport itable}
	} else {
		set items {result:simple result:extended:place result:extended:couple}
		set links {res psum csum}
	}

	foreach item $items link $links {
		if {$current == $item} {
			append nav "<span class=summaryNav>$msg(result:$item)</span>"
		} else {
			append nav "<a href=\"$f.$link.html\" class=summaryNav>$msg($item)</a>"
		}
		if {$item == "result:extended:couple"} {
			append nav "<br>"
		} elseif {$item == "prt:idsf:table"} {
		} else {
			append nav "&nbsp;&nbsp&nbsp;|&nbsp;&nbsp;&nbsp;"
		}
	}
	append nav "<br class=vskip>"
	return $nav
}

proc skating::print:html:summary:simple {f} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder
upvar results results

	# école ou pays
	if {$event(useCountry)} {
		set text $msg(prt:country)
	} else {
		set text $msg(prt:school)
	}

	# structure
	# | Place | N° | Couple | Round |
	set nbCells 11
	set header "<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				<tr class=header>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$msg(prt:place)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=centerHeader>$msg(prt:couplesNb)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$msg(prt:couples)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$text</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$msg(prt:rounds)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
				</tr>
				<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"
	# les données
	set content $header
	set i 0
	set last [lindex [lindex $results 0] 2]
	foreach item $results {
		# répétition du header
		if {$i && ($i % $gui(pref:print:html:repeatHeader)) == 0} {
			append content $header
		}
		# les données
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		set couple [lindex $item 0]
		set min [lindex $item 1]
		set round [lindex $item 2]
		set max [lindex $item 3]
		set place [lindex $item 4]
		# ligne de séparation entre les rounds
		if {$round != $last} {
			append content "<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"
		}
		# une ligne pour les données du couples
		if {$gui(pref:print:placeAverage)} {
			set text $place
		} elseif {$min != $max} {
			set text "$min-$max"
		} else {
			set text $min
		}
		append content "<tr class=$row>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=center>$text</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=centerHeader>$couple</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=left>[string map {{ } &nbsp;} [couple:name $f $couple]]</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=left>[couple:school $f $couple]</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=left>$folder(round:$round:name)</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
						</tr>"
		# suivant
		incr i
		set last $round
	}

	# mise en page principale
	set nav [print:html:navigation $f.res.html]
	set body [print:html:folder:title $f]
	print:html:append body "folder:summary:nav" [print:html:summary:nav $f simple]

	append body "<table border=0 cellpadding=0 cellspacing=0>
				  $content
				  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				</table>
				<br class=vskip>"
	print:html:generatepage "$f.res.html" body %NAVIGATION% $nav %BODY% $body
}

proc skating::print:html:summary:extended {f mode filename} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder
upvar results results


	# école ou pays
	if {$event(useCountry)} {
		set text $msg(prt:country)
	} else {
		set text $msg(prt:school)
	}

	# tri en fonction du mode
	if {$mode == "couple"} {
		set results [lsort -integer -index 0 $results]
	}

	# calcule la liste des juges
	set judges [list ]
	foreach round $folder(levels) {
		foreach j $folder(judges:$round) {
			if {[lsearch $judges $j] == -1} {
				lappend judges $j
			}
		}
	}
	set judges [lsort -command skating::event:judges:sort $judges]
	set nbJ [llength $judges]

	#---- header
	# structure
	# | Couple | N° | Rnd | Dance1   | ... | Dance n  | Total | Place |
	# |        |    |     | A B C Re | ... | A B C Re |       |       |
	set nbCells [expr {2+(1+$nbJ+1)*[llength $folder(dances)]
					    + 4*(int(ceil(1.0*[llength $folder(dances)]/$gui(pref:print:html:repeatCouples))))
						+ 5}]
	set header "  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				  <tr class=header>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center rowspan=2>$msg(prt:couples)<br>$text</td>"
	set d 0
	foreach dance $folder(dances) {
		if {($d % $gui(pref:print:html:repeatCouples)) == 0} {
			append header "<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
						   <td class=center rowspan=2>$msg(prt:couplesNb)</td>
						   <td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
						   <td class=center rowspan=2>$msg(prt:round)</td>"
		}
		incr d
		append header "<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					   <td class=center colspan=[expr {[llength $judges]+1}] width=\"1%\">$dance</td>"
	}
	append header "	<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center rowspan=2 width=\"1%\">$msg(prt:total)</td>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center rowspan=2 width=\"1%\">$msg(prt:place)</td>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
				  </tr>
				  <tr class=subheader>"
	foreach dance $folder(dances) {
		foreach judge $judges {
			append header "<td class=center2>$judge</td>"
		}
		append header "<td class=center2>$msg(prt:resultShort)</td>"
	}
	append header "</tr>
				   <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"
	set folder(dances:finale) $folder(dances)

	#---- les données pour chaque couple
	set content $header
	set i 0
	foreach item $results {
		set couple [lindex $item 0]
		set min [lindex $item 1]
		set round [lindex $item 2]
		set max [lindex $item 3]
		set place [lindex $item 4]
		# nombre de lignes à imprimer
		set nb [expr [lsearch $folder(levels) $round]+1]
		foreach r [lrange $folder(levels) 0 [lsearch $folder(levels) $round]] {
			if {[lsearch $folder(couples:$r) $couple] == -1} {
				incr nb -1
			}
		}
		if {$nb < 2} {
			set nb 2
		}
		# répétition du header
		if {$i && ($i % $gui(pref:print:html:repeatHeaderSummary)) == 0} {
			append content $header
		}
		# les données
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		append content "<tr class=$row>
						<td class=border rowspan=$nb><img src=\"1x1.gif\" width=1></td>"
		# nom du couple (replace les espace par des espaces non-sécables pour mise en forme de la table)
		append content "<td class=left rowspan=$nb><span class=coupleName>[string map {{ } &nbsp;} [couple:name $f $couple]]</span>
												   <br><span class=coupleSchool>[couple:school $f $couple]</span></td>"
		# pour chaque round
		set needFill 2
		set first 1
		foreach r [reverse [lrange $folder(levels) 0 [lsearch $folder(levels) $round]]] {
			# si le couple n'a pas dansé le round (repéchage)
			if {[lsearch $folder(couples:$r) $couple] == -1} {
				continue
			}
			# début de ligne
			if {!$first} {
				append content "<tr class=$row>"
			}
			# regarde si pré-qualifié
			set preQualif [isPrequalified $f $couple $r]
			# danses
			set total 0
			set d 0
			foreach dance $folder(dances) {
				# trouve l'index de cette danse pour le round
				# (des dances ont pu être skippées)
				set index [lsearch $folder(dances:$r) $dance]
				# répétition du numéro des couples
				if {($d % $gui(pref:print:html:repeatCouples)) == 0} {
					if {$first} {
						append content "<td class=border rowspan=$nb><img src=\"1x1.gif\" width=1></td>
										<td class=centerHeaderBig rowspan=$nb>$couple</td>"
					}
					append content "<td class=border><img src=\"1x1.gif\" width=1></td>
									<td class=centerSubheader>$msg(round:short:$r)</td>"
				}
				append content "<td class=border><img src=\"1x1.gif\" width=1></td>"
				if {$r == "finale"} {
					#---- finale
					foreach judge $judges {
						set j [lsearch $folder(judges:$r) $judge]
						if {$j == -1} {
							append content "<td class=center2>&nbsp;</td>"
						} else {
							set note [lindex $folder(notes:finale:$couple:$dance) $j]
							if {[expr {int($note)}] == $note} {
								set note [expr {int($note)}]
							}
							append content "<td class=center2>$note</td>"
						}
					}
					# la place dans la danse
					append content "<td class=centerPlace>[lindex $folder(places:$couple) $index]</td>"
					set total [expr {$total+[lindex $folder(places:$couple) $index]}]
				} else {
					#---- round
					set skip 0
					if {[lsearch $folder(dances:$r) $dance] == -1} {
						set skip 1
					}
					foreach judge $judges {
						set j [lsearch $folder(judges:$r) $judge]
						if {$j == -1} {
							append content "<td class=centerRound>&nbsp;</td>"
						} elseif {$preQualif} {
							append content "<td class=centerRound>+</td>"
						} elseif {$skip} {
							append content "<td class=centerRound>-</td>"
						} elseif {[lindex $folder(notes:$r:$couple:$dance) $j]} {
							if {$gui(pref:print:useLetters)} {
								append content "<td class=centerRound>$judge</td>"
							} else {
								append content "<td class=centerRound>X</td>"
							}
						} else {
							append content "<td class=centerRound>.</td>"
						}
					}
					# le sous-total
					foreach item $folder(result:$r) {
						if {[lindex $item 0] == $couple} {
							break
						}
					}
					set sum [lindex $item [expr 2+$index]]
					if {$preQualif} {
						append content "<td class=centerRound>+</td>"
					} elseif {$index == -1} {
						append content "<td class=centerRound>&nbsp;</td>"
					} else {
						append content "<td class=centerRound>$sum</td>"
					}
					if {$sum != "" && $index != -1} {
						set total [expr {$total+[lindex $item [expr 2+$index]]}]
					}
				}
				# danse suivante
				incr d
			}
			# total (des marks ou somme des places)
			if {$r == "finale"} {
				set style "center2"
			} else {
				set style "centerRound"
			}
			if {$preQualif} {
				set total "+"
			}
			append content "<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=$style>$total</td>"

			# place obtenue (ajouté uniquement première fois à cause du row span)
			if {$first} {
				if {$gui(pref:print:placeAverage)} {
					set text $place
				} elseif {$min != $max} {
					set text "$min-$max"
				} else {
					set text $min
				}
				append content "<td class=border rowspan=$nb><img src=\"1x1.gif\" width=1></td>
								<td class=centerBig rowspan=$nb>$text</td>
								<td class=border rowspan=$nb><img src=\"1x1.gif\" width=1></td>"
			}
			# round suivant
			append content "</tr>"
			set first 0
			incr needFill -1
		}
		# test si il faut créer une ligne vide
		if {$needFill > 0} {
			append content "<tr class=$row>"
			# danses
			set d 0
			foreach dance $folder(dances) {
				# répétition du numéro des couples
				if {($d % $gui(pref:print:html:repeatCouples)) == 0} {
					append content "<td class=border><img src=\"1x1.gif\" width=1></td>
									<td class=centerSubheader>&nbsp;</td>"
				}
				append content "<td class=border><img src=\"1x1.gif\" width=1></td>"
				foreach judge $judges {
					append content "<td class=center2>&nbsp;</td>"
				}
				append content "<td class=center2>&nbsp;</td>"
				incr d
			}
			append content "    <td class=border><img src=\"1x1.gif\" width=1></td>
								<td class=$style>&nbsp;</td>
							</tr>"
		}
		# couple suivant
		incr i
	}

	#---- mise en page principale
	set nav [print:html:navigation $f.res.html]
	set body [print:html:folder:title $f]
	print:html:append body "folder:summary:nav" [print:html:summary:nav $f extended:$mode]

	append body "<table border=0 cellpadding=0 cellspacing=0>
				  $content
				  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				</table>
				<br class=vskip>"
	print:html:generatepage "$f.$filename.html" body %NAVIGATION% $nav %BODY% $body
}

#----------------------------------------------------------------------------------------------

proc skating::print:html:attributesBlock {f header block} {
variable event
variable gui
variable $f
upvar 0 $f folder
global msg

#TRACEF

	# définition d'un cartouche
	#---- 1. calcul du nombre d'attributs
	set i 0
	set max 0
	foreach line [split $gui(pref:format:block:$block) \n] {
		if {$line == ""} {
			continue
		}
		if {$line == "-"} {
			incr i
			continue
		}
		regsub -all -- {\s+} $line { } line
		set nb [llength [split $line " "]]
		if {![info exists size($i)] || $nb > $size($i)} {
			set size($i) $nb
		}
		if {$nb > $max} {
			set max $nb
		}
	}
#TRACE "max = $max"

	#---- 2. formattage dans un tableau
	set data "<p><table border=0 cellspacing=0 cellpadding=10 width=\"100%\"><tr><td class=\"subtitle\">$header</td></tr></table>"
	append data "<p><table border=0 cellspacing=0 cellpadding=3>"
	set i 0
	foreach line [split $gui(pref:format:block:$block) \n] {
		if {$line == "" || $line == "-"} {
			# ligne vide = small skip
			append data "<tr><td colspan=[expr 3*$max]><hr></td></tr>"
			if {$line == "-"} {
				incr i
			}
			continue
		}
		regsub -all -- {\s+} $line { } line
		set j 0
		append data "<tr>"
		set span ""
		if {[llength [split $line " "]] == 1} {
			set span " colspan=$max"
		}
		foreach item [split $line " "] {
			# label
			append data "<td$span><b>[manage:attributes:getLabel $f $item]:</b></td>"
			# data
			append data "<td$span>[manage:attributes:parseFormat $f $item]</td><td style=\"padding-right: 50\">&nbsp;</td>"
			# groupe suivant
			incr j
		}
		# ligne suivante
		append data "</tr>"
	}
	append data "</table>"

	return $data
}

proc skating::print:html:idsf:report {f} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder
upvar results results


	#------
	# juges
	#------
	set content ""
	set i 0
	foreach judge [lsort -unique -command skating::event:judges:sort $folder(judges:finale)] {
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		incr i
		print:html:append content "list:judge" "" \
				%JUDGE% $judge \
				%NAME% $event(name:$judge) \
				%CLASS% $row
	}
	set list_judges [print:html:subst "list:judges" $content %NAME% $msg(prt:judges)]

	#----------------------------------------
	# les résultats pour la finale uniquement
	#----------------------------------------

	# | Place | Couple | Ecole/Pays |

	# école ou pays
	if {$event(useCountry)} {
		set text $msg(prt:country)
	} else {
		set text $msg(prt:school)
	}

	set nbCells 9
	set header "<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				<tr class=header>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$msg(prt:place)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$msg(prt:couples)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$text</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
				</tr>
				<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"
	# les données
	set content $header
	set i 0
	set last [lindex [lindex $results 0] 2]
	foreach item $results {
		# les données
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		set couple [lindex $item 0]
		set min [lindex $item 1]
		set round [lindex $item 2]
		set max [lindex $item 3]
		set place [lindex $item 4]
		# uniquement la finale
		if {$round != "finale"} {
			break
		}
		# une ligne pour les données du couples
		if {$gui(pref:print:placeAverage)} {
			set text $place
		} elseif {$min != $max} {
			set text "$min-$max"
		} else {
			set text $min
		}
		append content "<tr class=$row>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=center>$text</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=left>[string map {{ } &nbsp;} [couple:name $f $couple]]</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=left>[couple:school $f $couple]</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
						</tr>"
		# suivant
		incr i
		set last $round
	}
	set ranking "<table border=0 cellpadding=0 cellspacing=0>
				  $content
				  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				</table>"

	#-------------
	# statistiques
	#-------------
	set nbCells [expr 2+2*[llength $folder(levels)]+1]
	set stats "<table border=0 cellpadding=0 cellspacing=0>
				<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				<tr class=header>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center colspan=[expr $nbCells-2]>$msg(prt:statistics)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
				</tr>
				<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"
	set lineR "<tr class=row><td class=border><img src=\"1x1.gif\" width=1></td><td class=nav>&nbsp;</td>"
	set lineT "<tr class=row><td class=border><img src=\"1x1.gif\" width=1></td><td class=nav>$msg(prt:total)</td>"
	set lineS "<tr class=row><td class=border><img src=\"1x1.gif\" width=1></td><td class=nav>$msg(prt:set)</td>"
	foreach round $folder(levels) {
		# nom du round
		append lineR "<td class=border><img src=\"1x1.gif\" width=1></td><td class=nav>$folder(round:$round:name)</td>"
		# nb total
		append lineT "<td class=border><img src=\"1x1.gif\" width=1></td><td class=center>[llength $folder(couples:$round)]</td>"
		# nb "set" en cas de redance
		if {[string first "." $round] != -1} {
			scan $round {%[^.].2} mainRound
			set text $folder(round:$mainRound:nbSelected)
		} else {
			set text "-"
		}
		append lineS "<td class=border><img src=\"1x1.gif\" width=1></td><td class=center>$text</td>"
	}
	append stats "
				$lineR<td class=border><img src=\"1x1.gif\" width=1></td></tr>
			  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				$lineT<td class=border><img src=\"1x1.gif\" width=1></td></tr>
				$lineS<td class=border><img src=\"1x1.gif\" width=1></td></tr>
			  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
			</table>"


	#---- mise en page principale
	set nav [print:html:navigation $f.res.html]
	set body [print:html:folder:title $f]
	print:html:append body "folder:summary:nav" [print:html:summary:nav $f idsf:report]

	append body [print:html:attributesBlock $f $msg(prt:idsf:report) idsf_report]

	append body "<br class=vskip> $list_judges <br class=vskip> $ranking <br class=vskip> $stats <br class=vskip>"
	print:html:generatepage "$f.ireport.html" body %NAVIGATION% $nav %BODY% $body
}

proc skating::print:html:idsf:table {f} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder
upvar results results

	#------------------------------
	# table des résultats par juges
	#------------------------------

	#---- header
	# structure
	# | Juges  | Couple       |
	# | A name | N° N° N° ....|
	set nbCouples [llength $folder(couples:all)]
	set groupSize 25
	set nbGroups [expr {int( 1.0*($nbCouples-1)/$groupSize+1 )}]
	set nbCells [expr {3+2*($nbCouples+$nbGroups)+1}]
#TRACE "$nbCouples in $nbGroups groups (size $groupSize)"
	set header "  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				  <tr class=header>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center colspan=2 rowspan=2>$msg(prt:judges)</td>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center colspan=$groupSize width=\"1%\">$msg(prt:couples)</td>"
	set c 0
	set width 0
	foreach couple $folder(couples:all) {
		if {$c && ($c % $groupSize) == 0} {
			append header "<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
						   <td class=center rowspan=2>&nbsp;</td>
						   <td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
						   <td class=center colspan=$groupSize width=\"1%\">$msg(prt:couples)</td>"
		}
		incr c
		# taille du nom des couples
		if {[string length $couple] > $width} {
			set width [string length $couple]
		}
	}
	append header "<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td></tr>
				  <tr class=subheader>"
	set width [expr {5+$width*10}]
	foreach couple $folder(couples:all) {
		append header "<td class=center2 width=$width>$couple</td>"
	}
	append header "</tr>
				   <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"

	#---- pour chaque round
	set data ""
	foreach round $folder(levels) {
		#---- list des couples ayant une note pour le round courant
		set goodCouples [list ]
		scan $round {%[^.]} mainRound
		foreach couple $folder(couples:all) {
			if {[lsearch $folder(couples:$mainRound) $couple] == -1} {
				lappend goodCouples "-"
			} else {
				lappend goodCouples $couple
			}
		}

		#---- affiche mini header
		if {$round != [lindex $folder(levels) 0]} {
			append data "<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
						 <tr class=subHeader>
						 <td class=border><img src=\"1x1.gif\" width=1></td>
						 <td colspan=2 style=\"padding-left: 100; text-align: right;\">$msg(prt:set)</td>
						 <td class=border><img src=\"1x1.gif\" width=1></td>"
			# pour chaque couple
			set c 0
			foreach couple $goodCouples {
				# répétition des lettres de juges ?
				if {$c && ($c % $groupSize) == 0} {
					append data "<td class=border><img src=\"1x1.gif\" width=1></td>
								 <td class=centerSubheader>&nbsp;</td>
								 <td class=border><img src=\"1x1.gif\" width=1></td>"
				}
				incr c

				# donnée pour le couples
				append data "<td class=center>$couple</td>"
			}
			append data "<td class=border><img src=\"1x1.gif\" width=1></td>
						 </tr>
						 <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"
		}

		if {$round == "finale"} {
			#-------
			# finale
			#-------

			# somme des notes
			if {$folder(mode) == "ten"} {
				class:folder $f
			} else {
				class:result $f
			}

			append data "<tr class=row>
						 <td class=border><img src=\"1x1.gif\" width=1></td>
						 <td colspan=2 style=\"text-align: right;\">$msg(prt:sumInFinale)</td>
						 <td class=border><img src=\"1x1.gif\" width=1></td>"
			set c 0
			set i 0
			foreach couple $folder(couples:all) {
				# répétition des lettres de juges ?
				if {$c && ($c % $groupSize) == 0} {
					append data "<td class=border><img src=\"1x1.gif\" width=1></td>
								 <td class=centerSubheader>&nbsp;</td>
								 <td class=border><img src=\"1x1.gif\" width=1></td>"
				}
				incr c
				# donnée
				if {[lsearch $folder(couples:finale) $couple] != -1} {
					set text [lindex $folder(totals) $i]
					incr i
				} else {
					set text "-"
				}
				append data "<td class=center>$text</td>"
			}
			append data "<td class=border><img src=\"1x1.gif\" width=1></td>
						 </tr>
						 <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
						 <tr><td colspan=$nbCells><img src=\"1x1.gif\" height=5></td></tr>
						 <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"

			# couples
			append data "<tr class=subHeader>
						 <td class=border><img src=\"1x1.gif\" width=1></td>
						 <td colspan=2 style=\"text-align: right;\">$msg(prt:couples)</td>
						 <td class=border><img src=\"1x1.gif\" width=1></td>"
			# pour chaque couple
			set c 0
			foreach couple $folder(couples:all) {
				# répétition des lettres de juges ?
				if {$c && ($c % $groupSize) == 0} {
					append data "<td class=border><img src=\"1x1.gif\" width=1></td>
								 <td class=centerSubheader>&nbsp;</td>
								 <td class=border><img src=\"1x1.gif\" width=1></td>"
				}
				incr c
				# donnée pour le couples
				append data "<td class=center>$couple</td>"
			}
			append data "<td class=border><img src=\"1x1.gif\" width=1></td>
						 </tr>
						 <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"

			# place de XXX à YYY
			set from "<tr class=row>
					  <td class=border><img src=\"1x1.gif\" width=1></td>
					  <td colspan=2 style=\"text-align: right;\">$msg(prt:placeFrom)</td>
					  <td class=border><img src=\"1x1.gif\" width=1></td>"
			set to "<tr class=row>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td colspan=2 style=\"text-align: right;\">$msg(prt:placeTo)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>"
			set c 0
			foreach item $results {
				# répétition des lettres de juges ?
				if {$c && ($c % $groupSize) == 0} {
					append from "<td class=border><img src=\"1x1.gif\" width=1></td>
								 <td class=centerSubheader>&nbsp;</td>
								 <td class=border><img src=\"1x1.gif\" width=1></td>"
					append to   "<td class=border><img src=\"1x1.gif\" width=1></td>
								 <td class=centerSubheader>&nbsp;</td>
								 <td class=border><img src=\"1x1.gif\" width=1></td>"
				}
				incr c
				# données
				set min [lindex $item 1]
				set max [lindex $item 3]
				if {$max == $min} {
					set max "-"
				}
				append from "<td class=center>$min</td>"
				append to "<td class=center>$max</td>"
			}
			append data "$from <td class=border><img src=\"1x1.gif\" width=1></td>
						 </tr>
						 $to <td class=border><img src=\"1x1.gif\" width=1></td>
						 </tr>"

		} else {
			#------
			# round
			#------

			# mémorise le total
			foreach couple $folder(couples:all) {
				set total($couple) 0
			}

			#-- pour chaque juges
			set i 0
			set j 0
			foreach judge $folder(judges:$round) {
				# juge = une nouvelle ligne
				set row "row"
				if {$i % 2} {
					set row "rowOdd"
				}
				incr i
				append data "<tr class=$row>"
				# juge : lettre + nom
				append data "<td class=border><img src=\"1x1.gif\" width=1></td>
							 <td class=centerSubheader>$judge</td><td>$event(name:$judge)</td>
							 <td class=border><img src=\"1x1.gif\" width=1></td>"
				# pour chaque couple
				set c 0
				foreach couple $folder(couples:all) {
					# répétition des lettres de juges ?
					if {$c && ($c % $groupSize) == 0} {
						append data "<td class=border><img src=\"1x1.gif\" width=1></td>
									 <td class=centerSubheader>$judge</td>
									 <td class=border><img src=\"1x1.gif\" width=1></td>"
					}
					incr c
	
					# donnée pour le couples
					if {[isPrequalified $f $couple $round]} {
						set text "+"
						set total($couple) $text
					} elseif {[lsearch $folder(couples:$round) $couple] == -1} {
						if {[lsearch $folder(couples:$mainRound) $couple] == -1} {
							# couple éliminé à ce niveau
							set text "-"
						} else {
							# couple qualifié en round de repêchage
							set text "*"
						}
						set total($couple) $text
					} else {
						# somme des marks donné par un juge sur l'ensemble des dances
						set text 0
						foreach dance $folder(dances:$round) {
							incr text [lindex $folder(notes:$round:$couple:$dance) $j]
						}
						# mise à jour total
						incr total($couple) $text
					}
					append data "<td class=center>$text</td>"
				}
				append data "<td class=border><img src=\"1x1.gif\" width=1></td>
							 </tr>"
				incr j
			}
			#-- total
			set row "row"
			if {$i % 2} {
				set row "rowOdd"
			}
			append data "<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
						 <tr class=$row>
						 <td class=border><img src=\"1x1.gif\" width=1></td>
						 <td colspan=2 style=\"text-align: right;\">$folder(round:$round:name)</td>
						 <td class=border><img src=\"1x1.gif\" width=1></td>"
			# pour chaque couple
			set c 0
			foreach couple $folder(couples:all) {
				# répétition des lettres de juges ?
				if {$c && ($c % $groupSize) == 0} {
					append data "<td class=border><img src=\"1x1.gif\" width=1></td>
								 <td class=centerSubheader>&nbsp;</td>
								 <td class=border><img src=\"1x1.gif\" width=1></td>"
				}
				incr c

				# donnée pour le couples
				append data "<td class=center>$total($couple)</td>"
			}
			append data "<td class=border><img src=\"1x1.gif\" width=1></td>
						 </tr>"
		}
	}


	set table "<table border=0 cellpadding=3 cellspacing=0>
				$header
				$data
				<tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
			   </table>"
	

	#---- mise en page principale
	set nav [print:html:navigation $f.res.html]
	set body [print:html:folder:title $f]
	print:html:append body "folder:summary:nav" [print:html:summary:nav $f idsf:report]

	append body [print:html:attributesBlock $f $msg(prt:idsf:table) idsf_table]

	append body "<br class=vskip> $table <br class=vskip>"

	print:html:generatepage "$f.itable.html" body %NAVIGATION% $nav %BODY% $body
}



#----------------------------------------------------------------------------------------------
#	Partie 10-danses
#----------------------------------------------------------------------------------------------

proc skating::print:html:folder:ten {f} {
global msg
variable gui
variable $f
upvar 0 $f folder

	# les résultats globaux sur les 10-danses
  	print:html:summary:ten $f

	# pour chaque danse, génère une sortie normal
	foreach dance $folder(dances) {
		print:html:folder:normal $f.$dance
	}

	# pour la page globale, liste des danses avec accès aux résultats
	set list ""
	set i 0
	foreach dance $folder(dances) {
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		incr i
		print:html:append list "list:competition" "" \
				%COMPETITION% "<a href=\"$f.$dance.html\" class=show>$dance</a>" \
				%RESULTS% [print:html:summary:nav $f.$dance ""] \
				%CLASS% $row
	}
	print:html:append results "list:competitions" $list \
				%COMPETITION% "$gui(pref:print:html:resultsLogo)$msg(prt:final:dances)"


	# mise en page principale
	set nav [print:html:navigation $f.html]
	set body [print:html:folder:title $f]
	print:html:append body "folder:summary:nav" [print:html:summary:nav $f ""]

	append body $results

	print:html:generatepage "$f.html" body %NAVIGATION% $nav %BODY% $body
}

#----------------------------------------------------------------------------------------------

proc skating::print:html:summary:ten {f} {
global msg
variable $f
upvar 0 $f folder

	# on utilise toutes les danses
	if {![info exists folder(v:overall:dances)]} {
		set folder(v:overall:dances) $folder(dances)
	}
	set old $folder(v:overall:dances)
	set folder(v:overall:dances) $folder(dances)

	# effectue le classement
	if {[catch { set results [class:folder $f] }] || ![class:dances $f]} {
		set nav [print:html:navigation $f.res.html]
		print:html:generatepage "$f.res.html" body %NAVIGATION% $nav %BODY% $msg(prt:notAvailable)
		print:html:generatepage "$f.csum.html" body %NAVIGATION% $nav %BODY% $msg(prt:notAvailable)
		print:html:generatepage "$f.psum.html" body %NAVIGATION% $nav %BODY% $msg(prt:notAvailable)
		return
	}

	# trois vues
	print:html:summary:ten:simple $f
	print:html:summary:ten:extended $f place psum
	print:html:summary:ten:extended $f couple csum

	# restaure les données modifiées
	set folder(v:overall:dances) $old
}

proc skating::print:html:summary:ten:simple {f} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder
upvar results results

	# structure
	# | Place | Couple | N° | Dance1 | ... | DanceN | Total | Place |
	set nbCells [expr {6+ 2*[llength $folder(dances)] + 5}]

	# génération du header
	set header "  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				  <tr class=header>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$msg(prt:place:short)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center>$msg(prt:couples)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=centerHeader>$msg(prt:couplesNb)</td>"
	foreach dance $folder(dances) {
		append header "<td class=border><img src=\"1x1.gif\" width=1></td>
					   <td class=center2>[firstLetters $dance]</td>"
	}
	append header "	<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center width=\"1%\">$msg(prt:total)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
					<td class=center width=\"1%\">$msg(prt:place:short)</td>
					<td class=border><img src=\"1x1.gif\" width=1></td>
				  </tr>
				  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"

	# les données
	set content $header
	set i 0
	foreach item $results {
		# répétition du header
		if {$i && ($i % $gui(pref:print:html:repeatHeader)) == 0} {
			append content $header
		}
		# récupère une ligne à imprimer
		set couple [lindex $item 0]
		set place [lindex $item 1]
		set total [lindex $item 2]
		set places [lindex $item 3]
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}

		# place
		# une ligne pour les données du couples
		set text [couple:name $f $couple]
		if {[couple:school $f $couple] != ""} {
			append text " ([couple:school $f $couple])"
		}
		set text [string map {{ } &nbsp;} $text]
		append content "<tr class=$row>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=centerPlace>$place</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=left>$text</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=centerHeader>$couple</td>"
		foreach p $places {
			append content "<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=center2>$p</td>"
		}
		append content "	<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=centerTotal>$total</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
							<td class=centerPlace>$place</td>
							<td class=border><img src=\"1x1.gif\" width=1></td>
						</tr>"
		# suivant
		incr i
	}

	# mise en page principale
	set nav [print:html:navigation $f.res.html]
	set body [print:html:folder:title $f]
	print:html:append body "folder:summary:nav" [print:html:summary:nav $f simple]

	append body "<table border=0 cellpadding=0 cellspacing=0>
				  $content
				  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				</table>
				<br class=vskip>"
	print:html:generatepage "$f.res.html" body %NAVIGATION% $nav %BODY% $body
}

proc skating::print:html:summary:ten:extended {f mode filename} {
global msg
variable gui
variable event
variable $f
upvar 0 $f folder
upvar results results


	# école ou pays
	if {$event(useCountry)} {
		set text $msg(prt:country)
	} else {
		set text $msg(prt:school)
	}

	# tri en fonction du mode
	if {$mode == "couple"} {
		set results [lsort -integer -index 0 $results]
	}

	#---------------------------
	# calcule la liste des juges
	set allJudges [list ]
	set nbJudges 0
	foreach dance $folder(dances) {
		variable $f.$dance
		upvar 0 $f.$dance Dfolder

		set judges($dance) [list ]
		foreach round $Dfolder(levels) {
			foreach j $Dfolder(judges:$round) {
				lappend judges($dance) $j
				lappend allJudges $j
			}
		}
		set judges($dance) [lsort -unique -command skating::event:judges:sort $judges($dance)]
		set nbJ($dance) [llength $judges($dance)]
		incr nbJudges $nbJ($dance)
	}
	set allJudges [lsort -unique -command skating::event:judges:sort $allJudges]
	unset round

	#---- header
	# structure
	# | Couple | N° | Dance1               | ... | Dance n              | Total | Place |
	# |        |    | Rnd | A B C Re | Plc | ... | Rnd | A B C Re | Plc |       |       |
	set nbCells [expr {2+ (1+2+1+2)*[llength $folder(dances)]+$nbJudges
					    + 2*(int(ceil(1.0*[llength $folder(dances)]/$gui(pref:print:html:repeatCouples))))
						+ 5}]
	set header "  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				  <tr class=header>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center rowspan=2>$msg(prt:couples)<br>$text</td>"
	set d 0
	foreach dance $folder(dances) {
		if {($d % $gui(pref:print:html:repeatCouples)) == 0} {
			append header "<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
						   <td class=center rowspan=2>$msg(prt:couplesNb)</td>"
		}
		incr d
		append header "<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					   <td class=center colspan=[expr {[llength $judges($dance)]+5}] width=\"1%\">$dance</td>"
	}
	append header "	<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center rowspan=2 width=\"1%\">$msg(prt:total)</td>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
					<td class=center rowspan=2 width=\"1%\">$msg(prt:place)</td>
					<td class=border rowspan=2><img src=\"1x1.gif\" width=1></td>
				  </tr>
				  <tr class=subheader>"
	foreach dance $folder(dances) {
		append header "<td class=center2>$msg(prt:round)</td>
					   <td class=border><img src=\"1x1.gif\" width=1></td>"
		foreach judge $judges($dance) {
			append header "<td class=center2>$judge</td>"
		}
		append header "<td class=center2>$msg(prt:resultShort)</td>
					   <td class=border><img src=\"1x1.gif\" width=1></td>
					   <td class=center2>$msg(prt:place:short)</td>"
	}
	append header "</tr>
				   <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>"

	#---- les données pour chaque couple
	set content $header
	set i 0
	foreach item $results {
		set couple [lindex $item 0]
		set mainplace [lindex $item 1]
		set total [lindex $item 2]
		# nombre de lignes à imprimer
		set nb 2
		foreach d $folder(dances) {
			variable $f.$dance
			upvar 0 $f.$dance Dfolder

			foreach z $folder(v:results:$d) {
				if {[lindex $z 0] == $couple} {
					set place($d) [lindex $z 1]
					set round($d) [lindex $z 2]
					break
				}
			}
			set n [expr {[lsearch $Dfolder(levels) $round($d)]+1}]
			if {$n > $nb} {
				set nb $n
			}
		}
		# répétition du header
		if {$i && ($i % $gui(pref:print:html:repeatHeaderSummary)) == 0} {
			append content $header
		}
		#---- les données
		set row "row"
		if {$i % 2} {
			set row "rowOdd"
		}
		append content "<tr class=$row>
						<td class=border rowspan=$nb><img src=\"1x1.gif\" width=1></td>"
		# nom du couple (replace les espace par des espaces non-sécables pour mise en forme de la table)
		append content "<td class=left rowspan=$nb><span class=coupleName>[string map {{ } &nbsp;} [couple:name $f $couple]]</span>
												   <br><span class=coupleSchool>[couple:school $f $couple]</span></td>"
		# pour chaque ligne
		for {set line 0} {$line < $nb} {incr line} {
			# début de ligne
			if {$line != 0} {
				append content "<tr class=$row>"
			}
			# pour chaque danses
			set d 0
			foreach dance $folder(dances) {
				variable $f.$dance
				upvar 0 $f.$dance Dfolder
				# répétition du numéro des couples
				if {$line == 0 && ($d % $gui(pref:print:html:repeatCouples)) == 0} {
					append content "<td class=border rowspan=$nb><img src=\"1x1.gif\" width=1></td>
									<td class=centerHeaderBig rowspan=$nb>$couple</td>"
				}
				append content "<td class=border><img src=\"1x1.gif\" width=1></td>"

				# cherche le round en fonction de la ligne
				set r [lindex [lrange $Dfolder(levels) 0 [lsearch $Dfolder(levels) $round($dance)]] $line]
				if {$r == ""} {
					#-- rien à afficher
					append content "<td class=centerSubheader>&nbsp;</td>
									<td class=border><img src=\"1x1.gif\" width=1></td>
									<td class=center2 colspan=[expr {$nbJ($dance)+1}]>&nbsp;</td>"

				} elseif {$r == "finale"} {
					append content "<td class=centerSubheader>$msg(round:short:$r)</td>
									<td class=border><img src=\"1x1.gif\" width=1></td>"
					#-- finale
					foreach judge $judges($dance) {
						set j [lsearch $Dfolder(judges:$r) $judge]
						if {$j == -1} {
							append content "<td class=center2>&nbsp;</td>"
						} else {
							set note [lindex $Dfolder(notes:finale:$couple:$dance) $j]
							if {[expr {int($note)}] == $note} {
								set note [expr {int($note)}]
							}
							append content "<td class=center2>$note</td>"
						}
					}
					# la place dans la danse
					append content "<td class=centerPlace>$Dfolder(places:$couple)</td>"

				} else {
					append content "<td class=centerSubheader>$msg(round:short:$r)</td>
									<td class=border><img src=\"1x1.gif\" width=1></td>"
					#-- round
					foreach judge $judges($dance) {
						set j [lsearch $Dfolder(judges:$r) $judge]
						if {$j == -1} {
							append content "<td class=centerRound>&nbsp;</td>"
						} elseif {[lindex $Dfolder(notes:$r:$couple:$dance) $j]} {
							if {$gui(pref:print:useLetters)} {
								append content "<td class=centerRound>$judge</td>"
							} else {
								append content "<td class=centerRound>X</td>"
							}
						} else {
							append content "<td class=centerRound>.</td>"
						}
					}
					# le sous-total
					foreach item $Dfolder(result:$r) {
						if {[lindex $item 0] == $couple} {
							break
						}
					}
					append content "<td class=centerRound>[lindex $item 2]</td>"
				}
				# le résultat pour cette danse
				if {$line == 0} {
					append content "<td class=border rowspan=$nb><img src=\"1x1.gif\" width=1></td>
									<td class=center2 rowspan=$nb>$place($dance)</td>"
				}

				#-- danse suivante
				incr d
			}

			if {$line == 0} {
			# le total
				append content "<td class=border rowspan=$nb><img src=\"1x1.gif\" width=1></td>
								<td class=centerTotal rowspan=$nb>$total</td>"
			# la place obtenue (ajouté uniquement première fois à cause du row span)
				append content "<td class=border rowspan=$nb><img src=\"1x1.gif\" width=1></td>
								<td class=centerBig rowspan=$nb>$mainplace</td>
								<td class=border rowspan=$nb><img src=\"1x1.gif\" width=1></td>"
			}

			# ligne suivant
			append content "</tr>"
		}

		# couple suivant
		incr i
	}

	#---- mise en page principale
	set nav [print:html:navigation $f.res.html]
	set body [print:html:folder:title $f]
	print:html:append body "folder:summary:nav" [print:html:summary:nav $f extended:$mode]

	append body "<table border=0 cellpadding=0 cellspacing=0>
				  $content
				  <tr><td class=border colspan=$nbCells><img src=\"1x1.gif\" width=1></td></tr>
				</table>
				<br class=vskip>"
	print:html:generatepage "$f.$filename.html" body %NAVIGATION% $nav %BODY% $body
}


#=================================================================================================
#
#	Dialogue de personnalisation de la sortie Web
#
#=================================================================================================

proc skating::print:html:dialog {f} {
global msg
variable gui

upvar selectfont selectfont selectcolor selectcolor selectforeground selectforeground


	set width 32

	#-- général
	set general [TitleFrame::create $f.g -text $msg(web:parameters) -font $selectfont]
	set sub [TitleFrame::getframe $general]
		set ff [frame $sub.f -bd 0]
		# logo
		label $ff.c -width $width -text $msg(web:outputdir) -anchor w \
				-foreground $selectforeground -font $selectfont
		set gui(t:dir) $ff.c
		entry $ff.d -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
				-textvariable skating::gui(pref:print:html:outputdir)
		button $ff.p -text $msg(choose) -bd 1 -font normal \
				-command "set skating::gui(pref:print:html:outputdir) \
								\[tk_chooseDirectory -initialdir \[file dirname \$skating::gui(pref:print:html:outputdir)\]\]"
		# nom de fichier pour 'data.ska'
		label $ff.c2 -width $width -text $msg(web:filenameSKA) -anchor w \
				-foreground $selectforeground -font $selectfont
		entry $ff.d2 -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
				-textvariable skating::gui(pref:print:html:dataFilename)
		# nom de fichier pour 'site.zip'
		label $ff.c3 -width $width -text $msg(web:filenameZIP) -anchor w \
				-foreground $selectforeground -font $selectfont
		entry $ff.d3 -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
				-textvariable skating::gui(pref:print:html:archiveFilename)
		# mise en page
		grid $ff.c	$ff.d 	$ff.p -sticky ew -padx 5
		grid $ff.c2 $ff.d2 	x	  -sticky ew -padx 5 -pady 5
		grid $ff.c3 $ff.d3 	x	  -sticky ew -padx 5
		grid configure $ff.c -padx 0
		grid configure $ff.c2 -padx 0
		grid configure $ff.c3 -padx 0
		grid columnconfigure $ff {1} -weight 1
	# mise en page
	pack $sub.f -side top -anchor w -fill both


	#-- personnalisation
	set custom [TitleFrame::create $f.c -text $msg(web:customization) -font $selectfont]
	set sub [TitleFrame::getframe $custom]
		# liens
		set ff1 [frame $sub.1 -bd 0]
		label $ff1.c -width $width -text $msg(web:links) -anchor w \
				-foreground $selectforeground -font $selectfont
		radiobutton $ff1.y -bd 1 -text $msg(yes,) -font normal -selectcolor $selectcolor \
				-variable skating::gui(pref:print:html:user:defined) -value 1 \
				-command "$ff1.d configure -state normal"
		radiobutton $ff1.n -bd 1 -text $msg(no) -font normal -selectcolor $selectcolor \
				-variable skating::gui(pref:print:html:user:defined) -value 0 \
				-command "$ff1.d configure -state disabled"
		button $ff1.d -text $msg(define) -bd 1 -font normal
		grid $ff1.c $ff1.n $ff1.y $ff1.d -sticky w -padx 5
		grid configure $ff1.c -padx 0
		if {$gui(pref:print:html:user:defined) == 0} {
			$ff1.d configure -state disabled
		}
		# adresses e-mail du contact
		set ff2 [frame $sub.2 -bd 0]
		label $ff2.c -width $width -text $msg(web:email) -anchor w \
				-foreground $selectforeground -font $selectfont
		entry $ff2.d -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
				-textvariable skating::gui(pref:print:html:email)
		grid $ff2.c $ff2.d -sticky ew -padx 5
		grid configure $ff2.c -padx 0
		grid columnconfigure $ff2 {1} -weight 1
		# logo
		set ff3 [frame $sub.3 -bd 0]
		label $ff3.c -width $width -text $msg(web:logo) -anchor w \
				-foreground $selectforeground -font $selectfont
		entry $ff3.d -bd 1 -bg gray95 -selectbackground $gui(color:selection) \
				-textvariable skating::gui(pref:print:html:logo)
		button $ff3.p -text $msg(choose) -bd 1 -font normal \
				-command {if {[set file [tk_getOpenFile -filetypes \
											[list [list $msg(fileImages) {.png .gif .jpg .jpeg}] \
												  [list $msg(fileAll) 	*] ]]] != ""} {
							 set skating::gui(pref:print:html:logo) $file
						  } }
		grid $ff3.c $ff3.d $ff3.p -sticky ew -padx 5
		grid configure $ff3.c -padx 0
		grid columnconfigure $ff3 {1} -weight 1
		# compteurs de répétition des headers
		set ff5 [frame $sub.5 -bd 0]
		label $ff5.c -width $width -text $msg(web:headers) -anchor w \
					-foreground $selectforeground -font $selectfont
		foreach ww {1 2 3} name {repeatCouples repeatHeader repeatHeaderSummary} {
			frame $ff5.$ww
			SpinBox::create $ff5.$ww.s -label "$msg(web:$name) " -editable false \
						-range {0 99 1} -bd 1 -justify right -width 2 -entrybg gray95 \
						-labelfont normal -textvariable skating::gui(pref:print:html:$name)
			label $ff5.$ww.e -text " $msg(web:$name:2)" -font normal
			pack $ff5.$ww.s $ff5.$ww.e -side left
		}
		grid $ff5.c $ff5.1 -sticky w -padx 5
		grid x		$ff5.2 -sticky w -padx 5
		grid x		$ff5.3 -sticky w -padx 5
		grid configure $ff5.c -padx 0
		grid columnconfigure $ff5 {1} -weight 1
		# choix d'un modèle pré-défini
		set ff6 [frame $sub.6 -bd 0]
#  		label $ff6.c -width $width -text $msg(web:headers) -anchor w \
#  					-foreground $selectforeground -font $selectfont
#  		SpinBox::create $ff6.$ww.s -label "$msg(web:$name) " -editable false \
#  					-range {0 99 1} -bd 1 -justify right -width 2 -entrybg gray95 \
#  					-labelfont normal -textvariable skating::gui(pref:print:html:$name)
#  		label $ff6.$ww.e -text " $msg(web:$name:2)" -font normal
#  		grid $ff6.c $ff6.1 -sticky w -padx 5
#  		grid configure $ff6.c -padx 0
#  		grid columnconfigure $ff6 {1} -weight 1

		# choix des données à générer
		set ff7 [frame $sub.7 -bd 0]
		label $ff7.c -width $width -text $msg(web:output) -anchor w \
				-foreground $selectforeground -font $selectfont
		checkbutton $ff7.1 -bd 1 -text $msg(web:output:rounds) -font normal \
					-variable skating::gui(pref:print:html:output:rounds)
		checkbutton $ff7.2 -bd 1 -text $msg(web:output:summaries) -font normal \
					-variable skating::gui(pref:print:html:output:summaries)
		checkbutton $ff7.3 -bd 1 -text $msg(web:output:idsf) -font normal \
					-variable skating::gui(pref:print:html:output:idsf)
#  		grid $ff7.c $ff7.1 -sticky w -padx 5
#  		grid x		$ff7.2 -sticky w -padx 5
#  		grid x		$ff7.3 -sticky w -padx 5
		grid $ff7.c $ff7.3 -sticky w -padx 5
		grid configure $ff7.c -padx 0
		grid columnconfigure $ff7 {1} -weight 1

	# mise en page
	pack $sub.2 -side top -anchor w -fill both
	pack $sub.3 -side top -anchor w -pady 5 -fill both
	pack $sub.5 -side top -anchor w -fill both
#	pack $sub.7 -side top -anchor w -pady 10 -fill both
#	pack $sub.1 -side top -anchor w -pady 5
#	pack $sub.6 -side top -anchor w -fill both

	#-- mise en page
	pack $general -side top -fill x -padx 5 -fill both
	pack $custom -side top -fill x -padx 5 -pady 10 -fill both
}

#-------------------------------------------------------------------------------------------------
#	Vérification avant de lancer l'impression
#-------------------------------------------------------------------------------------------------

proc skating::print:html:doit {} {
global msg
variable event
variable gui

	# répertoire de sortie
	if {$gui(pref:print:html:outputdir) == ""
			|| [catch {file mkdir $gui(pref:print:html:outputdir)}]} {
		set old [$gui(t:dir) cget -background]
		$gui(t:dir) configure -background #ff7a7a
		after 2500 "$gui(t:dir) configure -background [list $old]"
		bell
		return
	}
	if {![file writable $gui(pref:print:html:outputdir)]} {
		tk_messageBox -icon "error" -type ok -default ok \
				-title $msg(dlg:cannotWrite) -message [format $msg(dlg:cannotWrite) $gui(pref:print:html:outputdir)]
		return
	}	

	# supprime la boite de dialogue
	destroy .dialog

	#---- go
	# dialogue de progrès
	progressBarInit $msg(web:generating) $msg(web:generating:msg) $msg(web:generating:page) [llength $event(folders)]
	# génération des pages
	print:html
	# fin boite de progression
	progressBarEnd


	#---- archive ZIP du site
	set oldpath [pwd]
	cd $gui(pref:print:html:outputdir)
	file delete -force -- $gui(pref:print:html:archiveFilename)
	set files [glob -type f *]
	zip open $gui(pref:print:html:archiveFilename)
	foreach file $files {
		zip add $file [file mtime $file]
	}
	zip close
	cd $oldpath


	#---- DONE ----  affiche le point de départ
	tk_messageBox -icon "info" -type ok -default ok -title $msg(dlg:information) \
			-message [format $msg(dlg:webDone) $gui(pref:print:html:outputdir)/index.html]
}
