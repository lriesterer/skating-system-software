# -*- wml -*-
set data {


images {
	html/1x1.gif
	html/dot.gif
	html/dot2.gif
	html/icn_round.gif
	html/icn_round_chance.gif
	html/icn_round_main.gif
	html/cup1_big.gif
	html/prev.gif
	html/next.gif
}

#----------------------------------------------------------------------------------------------
#	CSS Stylesheet
#----------------------------------------------------------------------------------------------

stylesheet {
	body				{font-family: verdana,arial,helvetica,sans-serif; font-size: 14px;
						 color: #000000; background-color: #b5b5b5; }

	span.copy			{font-size: 10px; }

	a					{color: #000000; text-decoration: none; }
	a:hover				{color: #ff0000; }
	span.selected		{color: #0000cc; font-weight: bold; }
	a.nav1				{font-size: 14px; color: #000000; text-decoration: none; }
	a.nav2				{font-size: 12px; color: #000000; text-decoration: none; }
	a.nav3				{font-size: 10px; color: #000000; text-decoration: none; }

	a.show				{color: #0000FF; text-decoration: underline; }

	tr.header			{font-weight: bold; background-color: #777777; color: #ffffff; padding: 3 5 3 5; }
	tr.subheader		{background-color: #999999; color: #ffffff; padding: 3 5 3 5; }
	tr.row				{padding: 1 5 1 5; }
	tr.rowOdd			{background-color: #e0e0e0; padding: 1 5 1 5; }

	td.nav				{background-color: #e0e0e0; }
	td.navHead			{background-color: #777777; color: #ffffff; 
						 font-size: 18px; font-weight: normal; text-align: center; }
	td.main				{background-color: #ffffff; }
	td.border			{background-color: #000000; padding: 0 0 0 0; }
	td.left				{text-align: left; }
	td.center			{text-align: center; }
	td.center2			{text-align: center; padding: 1 2 1 2; }
	td.centerHeader		{text-align: center; background-color: #777777; color: #ffffff; }
	td.centerSubheader	{text-align: center; background-color: #999999; color: #ffffff; }
	td.centerHighlight	{text-align: center; background-color: #a0ffd2; }
	td.centerHighlightOdd {text-align: center; background-color: #5effb6; }

	td.leftFixed		{text-align: left; width: 22px; }
	td.leftFixed2		{text-align: left; width: 32px; }
	td.centerFixed		{text-align: center;  width: 30px; }

	td.centerBig		{text-align: center; font-size: 24px; }
	td.centerHeaderBig	{text-align: center; font-size: 24px; background-color: #777777; color: #ffffff; }
	td.centerRound		{text-align: center; font-size: 12px; padding: 1 2 1 2; }
	td.centerPlace		{text-align: center; font-weight: bold; }
	td.centerTotal		{text-align: center; font-weight: bold; }

	span.title			{font-size: 24px; font-weight: bold; }
	span.date			{font-size: 16px; }
	span.competition	{font-size: 20px; }
	span.exponent		{font-size: 10px; position: relative; left: 1px; top:-5px; }

	td.subtitle			{font-size: 20px; font-weight: bold; background-color: #777777; color: #ffffff; }

	span.summaryNav		{font-weight: bold; }
	a.summaryNav		{color: #0000FF; text-decoration: underline; }

	span.coupleName		{}
	span.coupleSchool	{font-size: 12px; }
}

#----------------------------------------------------------------------------------------------
#	HTML template (main)
#----------------------------------------------------------------------------------------------

body {
	<html>
	<head>
	<meta name="resource-type" content="document">
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta name="author" content="Skating System Software">
	<meta name="creator" content="Skating System Software (c) Laurent Riesterer">
	<meta name="keywords" content="dancesport, danse sportive, skating system, scrutineer, scrutineering, 3S">
	<link rel="stylesheet" type="text/css" href="skating.css">
	</head>
	<body>
	<table border=0 cellPadding=4 cellSpacing=0 width="100%">
	<tr valign=top>
	  <td class=nav width=160>
		<table border=0 cellpadding=2 cellspacing=0 width="100%">
		  <tr><td colspan=3>%LOGO%</td></tr>
		  %NAVIGATION%
		</table>
	  </td>
	  <td class=main width=1><img alt=0 border=0 height=1 src="1x1.gif" width=1></td>
	  <td class=main>
		  %BODY%
	  </td>
	  <td class=main width=1><img alt=0 border=0 height=1 src="1x1.gif" width=1></td>
	</tr>
	</table>
	<a href="http://laurent.riesterer.free.fr/skating/"><span class=copy>&#169; Skating System Software</span></a>
	<br>
	<a href="mailto:%EMAIL%"><span class=copy>Contact the Webmaster</span></a>
	</body></html>
}


#----------------------------------------------------------------------------------------------
#	HTML template (navigation bar)
#----------------------------------------------------------------------------------------------

#---- Head ----
nav:head {
	<tr><td class=navHead colspan=3>%BODY%</td></tr>
}
nav:separator {
	<tr><td colspan=2><br></td></tr>
}
#---- Level 1 ----
nav:level1 {
	<tr>
	  <td valign=top width="1%"><img alt="" border=0 height=12 src="dot.gif" width=10><br></td>
	  <td width="99%">%BODY%</td>
	</tr>
}
nav:anchor1 {
	<a class="nav1" href="%HREF%">%BODY%</a>
}
#---- Level 2 ----
nav:level2 {
	<table border=0 cellspacing=0 cellpadding=0>
	  %BODY%
	</table>
}
nav:anchor2 {
	<tr>
	  <td><img src="dot2.gif"></td>
	  <td colspan=2><a class="nav2" href="%HREF%">%BODY%</a></td>
	</tr>
}
nav:anchor3 {
	<tr>
	  <td><img src="1x1.gif"></td>
	  <td><img src="1x1.gif" width=10><img src="dot2.gif"></td>
	  <td><a class="nav3" href="%HREF%">%BODY%</a></td>
	</tr>
}

#----------------------------------------------------------------------------------------------
#	Event data
#----------------------------------------------------------------------------------------------

main:title {
	<span class=title>%BODY%</span>
	<br><span class=date>%DATE%</span>
    <hr noShade size=4>
	<br class=vskip>
}
main:comment {
	<span class=comment>%BODY%</span>
    <hr noShade size=1>
}
main:stats {
	<span class=comment>%COUPLES%</span>
	<br><span class=comment>%JUDGES%</span>
    <hr noShade size=1>
	<br class=vskip>
	%RESULTS%
}
#-------- Competitions
list:competitions {
	<table border=0 cellpadding=0 cellspacing=0>
	  <tr class=header>
		<td class=border><img src="1x1.gif" width=1></td>
		<td class=center colspan=3>%COMPETITION%</td>
		<td class=border><img src="1x1.gif" width=1></td>
	  </tr>
	  %BODY%
	  <tr><td class=border colspan=5><img src="1x1.gif" height=1></td></tr>
	</table>
	<br class=vskip>
}
list:competition {
  <tr class=%CLASS%>
	<td class=border><img src="1x1.gif" width=1></td>
	<td class=center>%COMPETITION%</td>
	<td class=border><img src="1x1.gif" width=1></td>
	<td class=left>%RESULTS%</td>
	<td class=border><img src="1x1.gif" width=1></td>
  </tr>
}
#-------- Couples
list:couples {
	<table border=0 cellpadding=0 cellspacing=0>
	  <tr class=header>
		<td class=border><img src="1x1.gif" width=1></td>
		<td class=center>%COUPLE%</td>
		<td class=border><img src="1x1.gif" width=1></td>
		<td class=center>%NAME%</td>
		<td class=border><img src="1x1.gif" width=1></td>
		<td class=center>%SCHOOL%</td>
		<td class=border><img src="1x1.gif" width=1></td>
	  </tr>
	  %BODY%
	  <tr><td class=border colspan=7><img src="1x1.gif" height=1></td></tr>
	</table>
	<br class=vskip>
}
list:couple {
  <tr class=%CLASS%>
	<td class=border><img src="1x1.gif" width=1></td>
	<td class=center>%COUPLE%</td>
	<td class=border><img src="1x1.gif" width=1></td>
	<td class=left>%NAME%</td>
	<td class=border><img src="1x1.gif" width=1></td>
	<td class=left>%SCHOOL%</td>
	<td class=border><img src="1x1.gif" width=1></td>
  </tr>
}
#-------- Judges
list:judges {
	<table border=0 cellpadding=0 cellspacing=0>
	  <tr class=header>
		<td class=border><img src="1x1.gif" width=1></td>
		<td class=center colspan=3>%NAME%</td>
		<td class=border><img src="1x1.gif" width=1></td>
	  </tr>
	  %BODY%
	  <tr><td class=border colspan=5><img src="1x1.gif" height=1></td></tr>
	</table>
	<br class=vskip>
}
list:judge {
  <tr class=%CLASS%>
	<td class=border><img src="1x1.gif" width=1></td>
	<td class=center>%JUDGE%</td>
	<td class=border><img src="1x1.gif" width=1></td>
	<td class=left>%NAME%</td>
	<td class=border><img src="1x1.gif" width=1></td>
  </tr>
}
#-------- Panels
list:panels {
	<table border=0 cellpadding=0 cellspacing=0>
	  <tr class=header>
		<td class=border><img src="1x1.gif" width=1></td>
		<td class=center>%PANEL%</td>
		<td class=border><img src="1x1.gif" width=1></td>
		<td class=center>%JUDGES%</td>
		<td class=border><img src="1x1.gif" width=1></td>
	  </tr>
	  %BODY%
	  <tr><td class=border colspan=5><img src="1x1.gif" height=1></td></tr>
	</table>
	<br class=vskip>
}
list:panel {
  <tr class=%CLASS%>
	<td class=border><img src="1x1.gif" width=1></td>
	<td class=center>%PANEL%</td>
	<td class=border><img src="1x1.gif" width=1></td>
	<td class=left>%JUDGES%</td>
	<td class=border><img src="1x1.gif" width=1></td>
  </tr>
}

#----------------------------------------------------------------------------------------------
#	Folder data
#----------------------------------------------------------------------------------------------

folder:title {
	<span class=title>%BODY%</span>
	<br><span class=date>%DATE%</span>
    <hr noShade size=1>
	<span class=competition>%COMPETITION%</span>
    <hr noShade size=4>
	<br class=vskip>
}
#-------- General data about competition
folder:general {
	<table border=0 cellpadding=0 cellspacing=0>
	  <tr>
		<td colspan=3>%LIST_DANCES%</td>
	  </tr>
	  <tr><td colspan=3><br class=vskip></td></tr>
	  <tr>
		<td valign=top>%LIST_ROUNDS%</td>
		<td><img src="1x1.gif" width=20></td>
		<td valign=top>%LIST_JUDGES%</td>
	  </tr>
	  <tr><td colspan=3><br class=vskip></td></tr>
	  <tr>
		<td colspan=3>%LIST_COUPLES%</td>
	  </tr>
	</table>
}
#---- Dances
folder:list_dances {
	<table border=0 cellpadding=0 cellspacing=0>
	  <tr class=header>
		<td class=border><img src="1x1.gif" width=1></td>
		<td class=center>%DANCES%</td>
		<td class=border><img src="1x1.gif" width=1></td>
	  </tr>
	  %BODY%
	  <tr><td class=border colspan=3><img src="1x1.gif" height=1></td></tr>
	</table>
	<br class=vskip>
}
folder:list_dance {
  <tr class=%CLASS%>
	<td class=border><img src="1x1.gif" width=1></td>
	<td class=center>%DANCE%</td>
	<td class=border><img src="1x1.gif" width=1></td>
  </tr>
}
#---- Rounds
folder:list_rounds {
	<table border=0 cellpadding=0 cellspacing=0>
	  <tr class=header>
		<td class=border><img src="1x1.gif" width=1></td>
		<td class=center colspan=2>%ROUND%</td>
		<td class=border><img src="1x1.gif" width=1></td>
		<td class=center>%NB_COUPLES%</td>
		<td class=border><img src="1x1.gif" width=1></td>
		<td class=center>%JUDGES%</td>
		<td class=border><img src="1x1.gif" width=1></td>
	  </tr>
	  %BODY%
	  <tr><td class=border colspan=8><img src="1x1.gif" height=1></td></tr>
	</table>
	<br class=vskip>
}
folder:list_round {
  <tr class=%CLASS%>
	<td class=border><img src="1x1.gif" width=1></td>
	<td valign=middle><img src="%ICON%"></td><td class=left>%ROUND%</td>
	<td class=border><img src="1x1.gif" width=1></td>
	<td class=center>%NB_COUPLES%</td>
	<td class=border><img src="1x1.gif" width=1></td>
	<td class=left>%JUDGES%</td>
	<td class=border><img src="1x1.gif" width=1></td>
  </tr>
}
#---- one round
folder:comment {
	%BODY%
	<br class=vskip>
	<p></p>
}
folder:round {
	%COMMENT%
	%RESULTS%
	<br class=vskip>
	%LINKS%
	<p></p>
}
folder:finale {
	%COMMENT%
	%RESULTS_DANCES%
	%RESULTS_FINALE%
	<br class=vskip>
	%LINKS%
	<p></p>
}
folder:summary:nav {
	%BODY%
	<br class=vskip>
}




}
regsub -all -line -- {^#.*$} $data {} data
foreach {var value} $data {	set skating::html($var) $value }
