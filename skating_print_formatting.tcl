##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer

#=================================================================================================
#
#	Gestion des impressions
#
#=================================================================================================

#---- HEADER -----

array set skating::gui {
	pref:format:text:header1_l		""
	pref:format:font:header1_l		print:title
	pref:format:text:header1_c		"%title"
	pref:format:font:header1_c		print:title
	pref:format:text:header1_r		""
	pref:format:font:header1_r		print:title

	pref:format:text:header2_l		""
	pref:format:font:header2_l		print:subtitle
	pref:format:text:header2_c		"%label"
	pref:format:font:header2_c		print:subtitle
	pref:format:text:header2_r		""
	pref:format:font:header2_r		print:subtitle

	pref:format:text:header3_l		""
	pref:format:font:header3_l		print:date
	pref:format:text:header3_c		"%date"
	pref:format:font:header3_c		print:date
	pref:format:text:header3_r		""
	pref:format:font:header3_r		print:date

	pref:format:text:header4_l		""
	pref:format:font:header4_l		print:normal
	pref:format:text:header4_c		""
	pref:format:font:header4_c		print:normal
	pref:format:text:header4_r		""
	pref:format:font:header4_r		print:normal

	pref:format:text:general1_l		""
	pref:format:font:general1_l		print:bold
	pref:format:text:general1_c		""
	pref:format:font:general1_c		print:bold
	pref:format:text:general1_r		""
	pref:format:font:general1_r		print:bold

	pref:format:text:general2_l		""
	pref:format:font:general2_l		print:normal
	pref:format:text:general2_c		""
	pref:format:font:general2_c		print:normal
	pref:format:text:general2_r		""
	pref:format:font:general2_r		print:normal
}


#---- MARK SHEETS ----- Portrait ----
array set skating::gui {
	pref:format:text:mark_p_h1_l	"%label"
	pref:format:font:mark_p_h1_l	font:folder
	pref:format:text:mark_p_h1_c	""
	pref:format:font:mark_p_h1_c	font:folder
	pref:format:text:mark_p_h1_r	""
	pref:format:font:mark_p_h1_r	font:folder

	pref:format:text:mark_p_h2_l	"%dance[%round]"
	pref:format:font:mark_p_h2_l	font:folder
	pref:format:text:mark_p_h2_c	""
	pref:format:font:mark_p_h2_c	font:folder
	pref:format:text:mark_p_h2_r	""
	pref:format:font:mark_p_h2_r	font:folder

	pref:format:text:mark_p_f_l		"%title"
	pref:format:font:mark_p_f_l		font:title
	pref:format:text:mark_p_f_c		""
	pref:format:font:mark_p_f_c		font:title
	pref:format:text:mark_p_f_r		"%date"
	pref:format:font:mark_p_f_r		font:date
}

#---- MARK SHEETS ----- Landscape ----
array set skating::gui {
	pref:format:text:mark_l_f1		"%title"
	pref:format:font:mark_l_f1		font:title

	pref:format:text:mark_l_f2		"%date"
	pref:format:font:mark_l_f2		font:date

	pref:format:text:mark_l_h1_l	"%dance[%round]"
	pref:format:font:mark_l_h1_l	font:folder
	pref:format:text:mark_l_h1_c	""
	pref:format:font:mark_l_h1_c	font:folder
	pref:format:text:mark_l_h1_r	"%label"
	pref:format:font:mark_l_h1_r	font:folder

	pref:format:text:mark_l_h2_l	""
	pref:format:font:mark_l_h2_l	font:folder
	pref:format:text:mark_l_h2_c	""
	pref:format:font:mark_l_h2_c	font:folder
	pref:format:text:mark_l_h2_r	""
	pref:format:font:mark_l_h2_r	font:folder
}


#---- IDSF OUTPUTS ----- Report ----
array set skating::gui {
	pref:format:block:idsf_report	"%date	%level\n%place	%type\n-\n%member\n%label\n%organizer\n\n%chairman"
	pref:format:block:idsf_table	"%date	%level\n%place	%type\n-\n%label\n-\n%nbcouples"

	pref:format:text:blockheader1_l		""
	pref:format:font:blockheader1_l		print:title
	pref:format:text:blockheader1_c		"%header"
	pref:format:font:blockheader1_c		print:title
	pref:format:text:blockheader1_r		""
	pref:format:font:blockheader1_r		print:title

	pref:format:text:blockheader2_l		""
	pref:format:font:blockheader2_l		print:subtitle
	pref:format:text:blockheader2_c		"%title"
	pref:format:font:blockheader2_c		print:subtitle
	pref:format:text:blockheader2_r		""
	pref:format:font:blockheader2_r		print:subtitle

	pref:format:text:blockheader3_l		""
	pref:format:font:blockheader3_l		print:subtitle
	pref:format:text:blockheader3_c		""
	pref:format:font:blockheader3_c		print:subtitle
	pref:format:text:blockheader3_r		""
	pref:format:font:blockheader3_r		print:subtitle
}


#=================================================================================================

# Sauvegarde dans un tableau pour restauration des valeurs par défaut

foreach n [array names skating::gui pref:format:*] {
	set formatDefault($n) $skating::gui($n)
}

proc skating::print:format:restoreDefaults {} {
global formatDefault
variable gui

	foreach n [array names formatDefault] {
		set gui($n) $formatDefault($n)
	}
}
