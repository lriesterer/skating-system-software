##	The Skating System Software    --    Copyright (c) 1999 Laurent Riesterer


#==============================================================================
#
#	Interface pour format de l'USBDA
#
#==============================================================================


proc skating::plugin:print:fids2 {} {
global msg
variable gui


TRACEF "$gui(v:folder) / $gui(v:round)"

}


#------------------------------------------------------------------------------


namespace eval skating {
	regsub -all -- {\.} $::version "" vv
	if {$vv < 534} {
		tk_messageBox -icon warning -type ok -default ok -title Plugin \
				-message "Need to upgrade 3S to use the FIDS printing plugin"
	} else {
		lappend plugins(print) "Printing FIDS results" \
							   results fids \
							   skating::plugin:print:fids2
	}
}
