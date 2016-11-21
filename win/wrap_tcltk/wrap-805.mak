#
# Project directories
#
# ROOT    = top of source tree
#
# TOOLS32 = location of VC++ 32-bit development tools. Note that the
#	    VC++ 2.0 header files are broken, so you need to use the
#	    ones that come with the developer network CD's, or later
#	    versions of VC++.
#
# TOOLS16 = location of VC++ 1.5 16-bit tools, needed to build thunking
#	    library.  This information is optional; if the 16-bit compiler
#	    is not available, then the 16-bit code will not be built.
#	    Tcl will still run without the 16-bit code, but...
#		A. Under Windows 3.X you will any calls to the exec command
#	           will return an error.
#		B. A 16-bit program to test the behavior of the exec
#		   command under NT and 95 will not be built.
# INSTALLDIR = where the install- targets should copy the binaries and
#	    support files
#

ROOT		= e:\laurent\perso\static_tk
DEVSTUDIO	= d:\devstudio

TCLROOT		= $(ROOT)\tcl8.0.5
TKROOT		= $(ROOT)\tk8.0.5

TOOLS32		= $(DEVSTUDIO)\vc
TOOLS32_rc	= $(DEVSTUDIO)\sharedide
TOOLS16		= d:\msvc

INSTALLDIR	= d:\work\Tcl


# Set this to the appropriate value of /MACHINE: for your platform
MACHINE	= IX86

# Set NODEBUG to 0 to compile with symbols
NODEBUG = 1


######################################################################
# Do not modify below this line
######################################################################

NAMEPREFIX = tcl
DOTVERSION = 8.0
VERSION = 80

BINROOT		= .
!IF "$(NODEBUG)" == "1"
TMPDIRNAME	= Release
DBGX		=
!ELSE
TMPDIRNAME	= Debug
DBGX		= d
!ENDIF
TMPDIR		= $(BINROOT)\$(TMPDIRNAME)
OUTDIRNAME	= $(TMPDIRNAME)
OUTDIR		= $(TMPDIR)

TCLLIB		= $(OUTDIR)\$(NAMEPREFIX)$(VERSION)$(DBGX).lib
TCLDLLNAME	= $(NAMEPREFIX)$(VERSION)$(DBGX).dll
TCLDLL		= $(OUTDIR)\$(TCLDLLNAME)
TCLPLUGINLIB	= $(OUTDIR)\$(NAMEPREFIX)$(VERSION)p$(DBGX).lib
TCLPLUGINDLLNAME= $(NAMEPREFIX)$(VERSION)p$(DBGX).dll
TCLPLUGINDLL	= $(OUTDIR)\$(TCLPLUGINDLLNAME)
TCL16DLL	= $(OUTDIR)\$(NAMEPREFIX)16$(VERSION)$(DBGX).dll
TCLSH		= $(OUTDIR)\$(NAMEPREFIX)sh$(VERSION)$(DBGX).exe
TCLSHP		= $(OUTDIR)\$(NAMEPREFIX)shp$(VERSION)$(DBGX).exe
TCLPIPEDLLNAME	= $(NAMEPREFIX)pip$(VERSION)$(DBGX).dll
TCLPIPEDLL	= $(OUTDIR)\$(TCLPIPEDLLNAME)
TCLREGDLLNAME	= $(NAMEPREFIX)reg$(VERSION)$(DBGX).dll
TCLREGDLL	= $(OUTDIR)\$(TCLREGDLLNAME)
TCLTEST		= $(OUTDIR)\$(NAMEPREFIX)test.exe
DUMPEXTS	= $(TMPDIR)\dumpexts.exe
CAT16		= $(TMPDIR)\cat16.exe
CAT32		= $(TMPDIR)\cat32.exe

LIB_INSTALL_DIR	= $(INSTALLDIR)\lib
BIN_INSTALL_DIR	= $(INSTALLDIR)\bin
SCRIPT_INSTALL_DIR	= $(INSTALLDIR)\lib\tcl$(DOTVERSION)
INCLUDE_INSTALL_DIR	= $(INSTALLDIR)\include

TCLSHOBJS = \
	$(TMPDIR)\tclAppInit.obj

TCLTESTOBJS = \
	$(TMPDIR)\tclTest.obj \
	$(TMPDIR)\tclTestObj.obj \
	$(TMPDIR)\tclTestProcBodyObj.obj \
	$(TMPDIR)\tclWinTest.obj \
	$(TMPDIR)\testMain.obj

TCLOBJS = \
	$(TMPDIR)\panic.obj \
	$(TMPDIR)\regexp.obj \
	$(TMPDIR)\strftime.obj \
	$(TMPDIR)\tclAlloc.obj \
	$(TMPDIR)\tclAsync.obj \
	$(TMPDIR)\tclBasic.obj \
	$(TMPDIR)\tclBinary.obj \
	$(TMPDIR)\tclCkalloc.obj \
	$(TMPDIR)\tclClock.obj \
	$(TMPDIR)\tclCmdAH.obj \
	$(TMPDIR)\tclCmdIL.obj \
	$(TMPDIR)\tclCmdMZ.obj \
	$(TMPDIR)\tclCompExpr.obj \
	$(TMPDIR)\tclCompile.obj \
	$(TMPDIR)\tclDate.obj \
	$(TMPDIR)\tclEnv.obj \
	$(TMPDIR)\tclEvent.obj \
	$(TMPDIR)\tclExecute.obj \
	$(TMPDIR)\tclFCmd.obj \
	$(TMPDIR)\tclFileName.obj \
	$(TMPDIR)\tclGet.obj \
	$(TMPDIR)\tclHash.obj \
	$(TMPDIR)\tclHistory.obj \
	$(TMPDIR)\tclIndexObj.obj \
	$(TMPDIR)\tclInterp.obj \
	$(TMPDIR)\tclIO.obj \
	$(TMPDIR)\tclIOCmd.obj \
	$(TMPDIR)\tclIOSock.obj \
	$(TMPDIR)\tclIOUtil.obj \
	$(TMPDIR)\tclLink.obj \
	$(TMPDIR)\tclListObj.obj \
	$(TMPDIR)\tclLoad.obj \
	$(TMPDIR)\tclMain.obj \
	$(TMPDIR)\tclNamesp.obj \
	$(TMPDIR)\tclNotify.obj \
	$(TMPDIR)\tclObj.obj \
	$(TMPDIR)\tclParse.obj \
	$(TMPDIR)\tclPipe.obj \
	$(TMPDIR)\tclPkg.obj \
	$(TMPDIR)\tclPosixStr.obj \
	$(TMPDIR)\tclPreserve.obj \
	$(TMPDIR)\tclResolve.obj \
	$(TMPDIR)\tclProc.obj \
	$(TMPDIR)\tclStringObj.obj \
	$(TMPDIR)\tclTimer.obj \
	$(TMPDIR)\tclUtil.obj \
	$(TMPDIR)\tclVar.obj \
	$(TMPDIR)\tclWin32Dll.obj \
	$(TMPDIR)\tclWinChan.obj \
	$(TMPDIR)\tclWinError.obj \
	$(TMPDIR)\tclWinFCmd.obj \
	$(TMPDIR)\tclWinFile.obj \
	$(TMPDIR)\tclWinInit.obj \
	$(TMPDIR)\tclWinLoad.obj \
	$(TMPDIR)\tclWinMtherr.obj \
	$(TMPDIR)\tclWinNotify.obj \
	$(TMPDIR)\tclWinPipe.obj \
	$(TMPDIR)\tclWinSock.obj \
	$(TMPDIR)\tclWinTime.obj

cc32		= "$(TOOLS32)\bin\cl.exe"
link32		= "$(TOOLS32)\bin\link.exe"
rc32		= "$(TOOLS32_rc)\bin\rc.exe"
include32	= -I"$(TOOLS32)\include"

cc16		= "$(TOOLS16)\bin\cl.exe"
link16		= "$(TOOLS16)\bin\link.exe"
rc16		= "$(TOOLS16)\bin\rc.exe"
include16	= -I"$(TOOLS16)\include"

TCLWINDIR      = $(TCLROOT)\win
TCLGENERICDIR	= $(TCLROOT)\generic

TCL_INCLUDES	= -I$(TCLWINDIR) -I$(TCLGENERICDIR)
TCL_DEFINES	= -D__WIN32__ $(DEBUGDEFINES)

TCL_CFLAGS	= $(cdebug) $(cflags) $(cvarsdll) $(include32) \
			$(TCL_INCLUDES) $(TCL_DEFINES)
CON_CFLAGS	= $(cdebug) $(cflags) $(cvars) $(include32) -DCONSOLE
DOS_CFLAGS	= $(cdebug) $(cflags) $(include16) -AL
DLL16_CFLAGS	= $(cdebug) $(cflags) $(include16) -ALw

######################################################################
# Link flags
######################################################################

!IF "$(NODEBUG)" == "1"
ldebug = /RELEASE
!ELSE
ldebug = -debug:full -debugtype:cv
!ENDIF

# declarations common to all linker options
lcommon = /NODEFAULTLIB /RELEASE /NOLOGO

# declarations for use on Intel i386, i486, and Pentium systems
!IF "$(MACHINE)" == "IX86"
DLLENTRY = @12
lflags   = $(lcommon) /MACHINE:$(MACHINE)
!ELSE
lflags   = $(lcommon) /MACHINE:$(MACHINE)
!ENDIF

conlflags = $(lflags) -subsystem:console -entry:mainCRTStartup
guilflags = $(lflags) -subsystem:windows -entry:WinMainCRTStartup
dlllflags = $(lflags) -entry:_DllMainCRTStartup$(DLLENTRY) -dll

!IF "$(MACHINE)" == "PPC"
libc = libc$(DBGX).lib
libcdll = crtdll$(DBGX).lib
!ELSE
libc = libc$(DBGX).lib oldnames.lib
libcdll = msvcrt$(DBGX).lib oldnames.lib
!ENDIF

baselibs   = kernel32.lib $(optlibs) advapi32.lib user32.lib
winlibs    = $(baselibs) gdi32.lib comdlg32.lib winspool.lib

guilibs	   = $(libc) $(winlibs)
conlibs	   = $(libc) $(baselibs)
guilibsdll = $(libcdll) $(winlibs)
conlibsdll = $(libcdll) $(baselibs)

######################################################################
# Compile flags
######################################################################

!IF "$(NODEBUG)" == "1"
# This cranks the optimization level to maximize speed
cdebug = -O2 -Gs -GD
!ELSE
cdebug = -Z7 -Od -WX
!ENDIF

# declarations common to all compiler options
ccommon = -c -W3 -nologo -YX -Fp$(TMPDIR)\ -Dtry=__try -Dexcept=__except

!IF "$(MACHINE)" == "IX86"
cflags = $(ccommon) -D_X86_=1
!ELSE
!IF "$(MACHINE)" == "MIPS"
cflags = $(ccommon) -D_MIPS_=1
!ELSE
!IF "$(MACHINE)" == "PPC"
cflags = $(ccommon) -D_PPC_=1
!ELSE
!IF "$(MACHINE)" == "ALPHA"
cflags = $(ccommon) -D_ALPHA_=1
!ENDIF
!ENDIF
!ENDIF
!ENDIF

cvars      = -DWIN32 -D_WIN32
cvarsmt    = $(cvars)
cvarsdll   = $(cvarsmt)

!IF "$(NODEBUG)" == "1"
cvarsdll   = $(cvars) -ML
!ELSE
cvarsdll   = $(cvars) -MLd
!ENDIF

######################################################################
# Project specific targets
######################################################################

#release:    setup $(TCLSH) dlls
#dlls:	    setup $(TCL16DLL) $(TCLPIPEDLL) $(TCLREGDLL)
#all:	    setup $(TCLSH) dlls $(CAT16) $(CAT32)
#tcltest:    setup $(TCLTEST) dlls $(CAT16) $(CAT32)
#plugin:	    setup $(TCLPLUGINDLL) $(TCLSHP)
#install:    install-binaries install-libraries
#test:	    setup $(TCLTEST) dlls $(CAT16) $(CAT32)
#	copy $(TCLWINDIR)\pkgIndex.tcl $(OUTDIR)
#	set TCL_LIBRARY=$(TCLROOT)/library
#	$(TCLTEST) << "$(TCLREGDLL)"
#		load [lindex $$argv 0] registry
#		cd ../tests
#		source all
#<<

setup:
	@mkd $(TMPDIR)
	@mkd $(OUTDIR)



$(DUMPEXTS): $(TCLWINDIR)\winDumpExts.c
	$(cc32) $(CON_CFLAGS) -Fo$(TMPDIR)\ $?
	set LIB="$(TOOLS32)\lib"
	$(link32) $(ldebug) $(conlflags) $(guilibs) -out:$@ \
		$(TMPDIR)\winDumpExts.obj

$(TCLLIB): $(TCLDLL)

$(TCLDLL): $(TCLOBJS) $(TMPDIR)\tcl.def $(TMPDIR)\tcl.res
	set LIB="$(TOOLS32)\lib"
	$(link32) $(ldebug) $(dlllflags) -def:$(TMPDIR)\tcl.def \
		-out:$@ $(TMPDIR)\tcl.res $(guilibsdll) @<<
$(TCLOBJS)
<<

$(TCLPLUGINLIB): $(TCLPLUGINDLL)

$(TCLPLUGINDLL): $(TCLOBJS) $(TMPDIR)\plugin.def $(TMPDIR)\tcl.res
	set LIB="$(TOOLS32)\lib"
	$(link32) $(ldebug) $(dlllflags) -def:$(TMPDIR)\plugin.def \
		-out:$@ $(TMPDIR)\tcl.res $(guilibsdll) @<<
$(TCLOBJS)
<<

$(TCLSH): $(TCLSHOBJS) $(TCLLIB) $(TMPDIR)\tclsh.res
	set LIB="$(TOOLS32)\lib"
	$(link32) $(ldebug) $(conlflags) $(TMPDIR)\tclsh.res -stack:2300000 \
		-out:$@ $(conlibsdll) $(TCLLIB) $(TCLSHOBJS)

$(TCLSHP): $(TCLSHOBJS) $(TCLPLUGINLIB) $(TMPDIR)\tclsh.res
	set LIB="$(TOOLS32)\lib"
	$(link32) $(ldebug) $(conlflags) $(TMPDIR)\tclsh.res -stack:2300000 \
		-out:$@ $(conlibsdll) $(TCLPLUGINLIB) $(TCLSHOBJS)

$(TCLTEST): $(TCLTESTOBJS) $(TCLLIB) $(TMPDIR)\tclsh.res
	set LIB="$(TOOLS32)\lib"
	$(link32) $(ldebug) $(conlflags) $(TMPDIR)\tclsh.res -stack:2300000 \
		 -out:$@ $(conlibsdll) $(TCLLIB) $(TCLTESTOBJS)

$(TCL16DLL):  $(TCLWINDIR)\tcl16.rc $(TCLWINDIR)\tclWin16.c
	if exist $(cc16) $(cc16) @<<
$(DLL16_CFLAGS) -Fo$(TMPDIR)\ $(TCLWINDIR)\tclWin16.c
<<
	@copy << $(TMPDIR)\tclWin16.def > nul
LIBRARY $(@B);dll
EXETYPE WINDOWS
CODE PRELOAD MOVEABLE DISCARDABLE
DATA PRELOAD MOVEABLE SINGLE
HEAPSIZE 1024
EXPORTS
	WEP @1 RESIDENTNAME
	UTPROC @2
<<
	if exist $(cc16) $(link16) /NOLOGO /ONERROR:NOEXE /NOE @<<
$(TMPDIR)\tclWin16.obj
$@
nul
$(TOOLS16)\lib\ ldllcew oldnames libw toolhelp
$(TMPDIR)\tclWin16.def
<<
	if exist $(cc16) $(rc16) -i $(TCLGENERICDIR) $(TCL_DEFINES) $(TCLWINDIR)\tcl16.rc $@

$(TCLPIPEDLL): $(TCLWINDIR)\stub16.c
	$(cc32) $(CON_CFLAGS) -Fo$(TMPDIR)\ $(TCLWINDIR)\stub16.c
	set LIB="$(TOOLS32)\lib"
	$(link32) $(ldebug) $(conlflags) -out:$@ $(TMPDIR)\stub16.obj $(guilibs)

$(TCLREGDLL): $(TMPDIR)\tclWinReg.obj
	set LIB="$(TOOLS32)\lib"
	$(link32) $(ldebug) $(dlllflags) -out:$@ $(TMPDIR)\tclWinReg.obj \
		$(conlibsdll) $(TCLLIB)

$(CAT32): $(TCLWINDIR)\cat.c
	$(cc32) $(CON_CFLAGS) -Fo$(TMPDIR)\ $?
	set LIB="$(TOOLS32)\lib"
	$(link32) $(conlflags) -out:$@ -stack:16384 $(TMPDIR)\cat.obj $(conlibs)

$(CAT16): $(TCLWINDIR)\cat.c
	if exist $(cc16) $(cc16) $(DOS_CFLAGS) -Fo$(TMPDIR)\ $?
	set LIB="$(TOOLS16)\lib"
	if exist $(cc16) $(link16) /NOLOGO /ONERROR:NOEXE /NOI /STACK:16384 \
		$(TMPDIR)\cat.obj,$@,nul,llibce.lib,nul

$(TMPDIR)\tcl.def: $(DUMPEXTS) $(TCLOBJS)
	$(DUMPEXTS) -o $@ $(TCLDLLNAME) @<<
$(TCLOBJS)
<<

$(TMPDIR)\plugin.def: $(DUMPEXTS) $(TCLOBJS)
	$(DUMPEXTS) -o $@ $(TCLPLUGINDLLNAME) @<<
$(TCLOBJS)
<<

tcl-install-binaries: $(TCLSH)
	@mkd $(BIN_INSTALL_DIR)
	@mkd $(LIB_INSTALL_DIR)
	@echo installing $(TCLDLLNAME)
	@copy $(TCLDLL) $(BIN_INSTALL_DIR)
	@copy $(TCLLIB) $(LIB_INSTALL_DIR)
	@echo installing $(TCLSH)
	@copy $(TCLSH) $(BIN_INSTALL_DIR)
	@echo installing $(TCLPIPEDLLNAME)
	@copy $(TCLPIPEDLL) $(BIN_INSTALL_DIR)
	@echo installing $(TCLREGDLLNAME)
	@copy $(TCLREGDLL) $(LIB_INSTALL_DIR)

tcl-install-libraries:
	-@mkd $(LIB_INSTALL_DIR)
	-@mkd $(INCLUDE_INSTALL_DIR)
	-@mkd $(SCRIPT_INSTALL_DIR)
	-@mkd $(SCRIPT_INSTALL_DIR)\http1.0
	@copy << "$(SCRIPT_INSTALL_DIR)\pkgIndex.tcl"
package ifneeded registry 1.0 "load [list [file join $$dir .. $(TCLREGDLLNAME)]] registry"
<<
	-@copy $(TCLROOT)\library\http1.0\http.tcl $(SCRIPT_INSTALL_DIR)\http1.0
	-@copy $(TCLROOT)\library\http1.0\pkgIndex.tcl $(SCRIPT_INSTALL_DIR)\http1.0
	-@mkd $(SCRIPT_INSTALL_DIR)\http2.0
	-@copy $(TCLROOT)\library\http2.0\http.tcl $(SCRIPT_INSTALL_DIR)\http2.0
	-@copy $(TCLROOT)\library\http2.0\pkgIndex.tcl $(SCRIPT_INSTALL_DIR)\http2.0
	-@mkd $(SCRIPT_INSTALL_DIR)\opt0.1
	-@copy $(TCLROOT)\library\opt0.1\optparse.tcl $(SCRIPT_INSTALL_DIR)\opt0.1
	-@copy $(TCLROOT)\library\opt0.1\pkgIndex.tcl $(SCRIPT_INSTALL_DIR)\opt0.1
	-@copy $(TCLGENERICDIR)\tcl.h $(INCLUDE_INSTALL_DIR)
	-@copy $(TCLROOT)\library\history.tcl $(SCRIPT_INSTALL_DIR)
	-@copy $(TCLROOT)\library\init.tcl $(SCRIPT_INSTALL_DIR)
	-@copy $(TCLROOT)\library\ldAout.tcl $(SCRIPT_INSTALL_DIR)
	-@copy $(TCLROOT)\library\parray.tcl $(SCRIPT_INSTALL_DIR)
	-@copy $(TCLROOT)\library\safe.tcl $(SCRIPT_INSTALL_DIR)
	-@copy $(TCLROOT)\library\tclIndex $(SCRIPT_INSTALL_DIR)
	-@copy $(TCLROOT)\library\word.tcl $(SCRIPT_INSTALL_DIR)

#
# Special case object file targets
#

$(TMPDIR)\tclWinInit.obj: $(TCLWINDIR)\tclWinInit.c
	$(cc32) -DSTATIC_BUILD $(TCL_CFLAGS) $(EXTFLAGS) \
		-Fo$(TMPDIR)\ $?

$(TMPDIR)\testMain.obj: $(TCLWINDIR)\tclAppInit.c
	$(cc32) $(TCL_CFLAGS) -DTCL_TEST -Fo$(TMPDIR)\testMain.obj $?

$(TMPDIR)\tclTest.obj: $(TCLGENERICDIR)\tclTest.c
	$(cc32) $(TCL_CFLAGS) -Fo$@ $?

$(TMPDIR)\tclTestObj.obj: $(TCLGENERICDIR)\tclTestObj.c
	$(cc32) $(TCL_CFLAGS) -Fo$@ $?

$(TMPDIR)\tclWinTest.obj: $(TCLWINDIR)\tclWinTest.c
	$(cc32) $(TCL_CFLAGS) -Fo$@ $?

$(TMPDIR)\tclAppInit.obj : $(TCLWINDIR)\tclAppInit.c
	$(cc32) $(TCL_CFLAGS) -Fo$@ $?

#
# Implicit rules
#

{$(TCLWINDIR)}.c{$(TMPDIR)}.obj:
    $(cc32) -DSTATIC_BUILD $(TCL_CFLAGS) -Fo$(TMPDIR)\ $<

{$(TCLGENERICDIR)}.c{$(TMPDIR)}.obj:
    $(cc32) -DSTATIC_BUILD $(TCL_CFLAGS) -Fo$(TMPDIR)\ $<

{$(TCLROOT)\compat}.c{$(TMPDIR)}.obj:
    $(cc32) -DSTATIC_BUILD $(TCL_CFLAGS) -Fo$(TMPDIR)\ $<

{$(TCLWINDIR)}.rc{$(TMPDIR)}.res:
	$(rc32) -fo $@ -r -i $(TCLGENERICDIR) -i $(TCLWINDIR) -D__WIN32__ \
		$(TCL_DEFINES) $<

clean:
        -@del $(OUTDIR)\*.exp
	-@del $(OUTDIR)\*.lib
	-@del $(OUTDIR)\*.dll
	-@del $(OUTDIR)\*.exe
	-@del $(OUTDIR)\*.pdb
	-@del $(TMPDIR)\*.pch
        -@del $(TMPDIR)\*.obj
        -@del $(TMPDIR)\*.res
        -@del $(TMPDIR)\*.def
        -@del $(TMPDIR)\*.exe
	-@rmd $(OUTDIR)
	-@rmd $(TMPDIR)







#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################









######################################################################
# Do not modify below this line
######################################################################

TCLDIR = $(TCLROOT)

TCLNAMEPREFIX = tcl
TKNAMEPREFIX = tk
WISHNAMEPREFIX = wish
VERSION = 80
DOTVERSION = 8.0

BINROOT		= .
!IF "$(NODEBUG)" == "1"
TMPDIRNAME	= Release
DBGX		=
!ELSE
TMPDIRNAME	= Debug
DBGX		= d
!ENDIF
TMPDIR		= $(BINROOT)\$(TMPDIRNAME)
OUTDIRNAME	= $(TMPDIRNAME)
OUTDIR		= $(TMPDIR)

TCLLIB 		= $(TCLNAMEPREFIX)$(VERSION)$(DBGX).lib
TCLPLUGINLIB 	= $(TCLNAMEPREFIX)$(VERSION)p.lib
TKDLLNAME	= $(TKNAMEPREFIX)$(VERSION)$(DBGX).dll
TKDLL 		= $(OUTDIR)\$(TKDLLNAME)
TKLIB 		= $(OUTDIR)\$(TKNAMEPREFIX)$(VERSION)$(DBGX).lib
TKPLUGINDLLNAME	= $(TKNAMEPREFIX)$(VERSION)p$(DBG).dll
TKPLUGINDLL 	= $(OUTDIR)\$(TKPLUGINDLLNAME)
TKPLUGINLIB 	= $(OUTDIR)\$(TKNAMEPREFIX)$(VERSION)p$(DBGX).lib

WISH 		= $(OUTDIR)\$(WISHNAMEPREFIX)$(VERSION)$(DBGX).exe
WISHP 		= $(OUTDIR)\$(WISHNAMEPREFIX)p$(VERSION)$(DBGX).exe
TKTEST 		= $(OUTDIR)\$(TKNAMEPREFIX)test.exe
DUMPEXTS 	= $(TMPDIR)\dumpexts.exe

BIN_INSTALL_DIR = $(INSTALLDIR)\bin
INCLUDE_INSTALL_DIR = $(INSTALLDIR)\include
LIB_INSTALL_DIR = $(INSTALLDIR)\lib
SCRIPT_INSTALL_DIR = $(LIB_INSTALL_DIR)\tk$(DOTVERSION)

WISHOBJS = \
	$(TMPDIR)\winMain.obj

TKTESTOBJS = \
	$(TMPDIR)\tkTest.obj \
	$(TMPDIR)\tkSquare.obj \
	$(TMPDIR)\testMain.obj

XLIBOBJS = \
	$(TMPDIR)\xcolors.obj \
	$(TMPDIR)\xdraw.obj \
	$(TMPDIR)\xgc.obj \
	$(TMPDIR)\ximage.obj \
	$(TMPDIR)\xutil.obj

TKOBJS = \
	$(TMPDIR)\tkConsole.obj \
	$(TMPDIR)\tkUnixMenubu.obj \
	$(TMPDIR)\tkUnixScale.obj \
	$(XLIBOBJS) \
	$(TMPDIR)\tkWin3d.obj \
	$(TMPDIR)\tkWin32Dll.obj \
	$(TMPDIR)\tkWinButton.obj \
	$(TMPDIR)\tkWinClipboard.obj \
	$(TMPDIR)\tkWinColor.obj \
	$(TMPDIR)\tkWinCursor.obj \
	$(TMPDIR)\tkWinDialog.obj \
	$(TMPDIR)\tkWinDraw.obj \
	$(TMPDIR)\tkWinEmbed.obj \
	$(TMPDIR)\tkWinFont.obj \
	$(TMPDIR)\tkWinImage.obj \
	$(TMPDIR)\tkWinInit.obj \
	$(TMPDIR)\tkWinKey.obj \
	$(TMPDIR)\tkWinMenu.obj \
	$(TMPDIR)\tkWinPixmap.obj \
	$(TMPDIR)\tkWinPointer.obj \
	$(TMPDIR)\tkWinRegion.obj \
	$(TMPDIR)\tkWinScrlbr.obj \
	$(TMPDIR)\tkWinSend.obj \
	$(TMPDIR)\tkWinWindow.obj \
	$(TMPDIR)\tkWinWm.obj \
	$(TMPDIR)\tkWinX.obj \
	$(TMPDIR)\stubs.obj \
	$(TMPDIR)\tk3d.obj \
	$(TMPDIR)\tkArgv.obj \
	$(TMPDIR)\tkAtom.obj \
	$(TMPDIR)\tkBind.obj \
	$(TMPDIR)\tkBitmap.obj \
	$(TMPDIR)\tkButton.obj \
	$(TMPDIR)\tkCanvArc.obj \
	$(TMPDIR)\tkCanvBmap.obj \
	$(TMPDIR)\tkCanvImg.obj \
	$(TMPDIR)\tkCanvLine.obj \
	$(TMPDIR)\tkCanvPoly.obj \
	$(TMPDIR)\tkCanvPs.obj \
	$(TMPDIR)\tkCanvText.obj \
	$(TMPDIR)\tkCanvUtil.obj \
	$(TMPDIR)\tkCanvWind.obj \
	$(TMPDIR)\tkCanvas.obj \
	$(TMPDIR)\tkClipboard.obj \
	$(TMPDIR)\tkCmds.obj \
	$(TMPDIR)\tkColor.obj \
	$(TMPDIR)\tkConfig.obj \
	$(TMPDIR)\tkCursor.obj \
	$(TMPDIR)\tkEntry.obj \
	$(TMPDIR)\tkError.obj \
	$(TMPDIR)\tkEvent.obj \
	$(TMPDIR)\tkFileFilter.obj \
	$(TMPDIR)\tkFocus.obj \
	$(TMPDIR)\tkFont.obj \
	$(TMPDIR)\tkFrame.obj \
	$(TMPDIR)\tkGC.obj \
	$(TMPDIR)\tkGeometry.obj \
	$(TMPDIR)\tkGet.obj \
	$(TMPDIR)\tkGrab.obj \
	$(TMPDIR)\tkGrid.obj \
	$(TMPDIR)\tkImage.obj \
	$(TMPDIR)\tkImgBmap.obj \
	$(TMPDIR)\tkImgGIF.obj \
	$(TMPDIR)\tkImgPPM.obj \
	$(TMPDIR)\tkImgPhoto.obj \
	$(TMPDIR)\tkImgUtil.obj \
	$(TMPDIR)\tkListbox.obj \
	$(TMPDIR)\tkMacWinMenu.obj \
	$(TMPDIR)\tkMain.obj \
	$(TMPDIR)\tkMenu.obj \
	$(TMPDIR)\tkMenubutton.obj \
	$(TMPDIR)\tkMenuDraw.obj \
	$(TMPDIR)\tkMessage.obj \
	$(TMPDIR)\tkOption.obj \
	$(TMPDIR)\tkPack.obj \
	$(TMPDIR)\tkPlace.obj \
	$(TMPDIR)\tkPointer.obj \
	$(TMPDIR)\tkRectOval.obj \
	$(TMPDIR)\tkScale.obj \
	$(TMPDIR)\tkScrollbar.obj \
	$(TMPDIR)\tkSelect.obj \
	$(TMPDIR)\tkText.obj \
	$(TMPDIR)\tkTextBTree.obj \
	$(TMPDIR)\tkTextDisp.obj \
	$(TMPDIR)\tkTextImage.obj \
	$(TMPDIR)\tkTextIndex.obj \
	$(TMPDIR)\tkTextMark.obj \
	$(TMPDIR)\tkTextTag.obj \
	$(TMPDIR)\tkTextWind.obj \
	$(TMPDIR)\tkTrig.obj \
	$(TMPDIR)\tkUtil.obj \
	$(TMPDIR)\tkVisual.obj \
	$(TMPDIR)\tkWindow.obj

cc32		= "$(TOOLS32)\bin\cl.exe"
link32		= "$(TOOLS32)\bin\link.exe"
rc32		= "$(TOOLS32_rc)\bin\rc.exe"
include32	= -I"$(TOOLS32)\include"

TKWINDIR          = $(TKROOT)\win
TKGENERICDIR	= $(TKROOT)\generic
XLIBDIR		= $(TKROOT)\xlib
BITMAPDIR	= $(TKROOT)\bitmaps
TCLLIBDIR       = $(TCLDIR)\win\$(OUTDIRNAME)
RCDIR		= $(TKWINDIR)\rc

TK_INCLUDES	= -I$(TKWINDIR) -I$(TKGENERICDIR) -I$(BITMAPDIR) -I$(XLIBDIR) \
			-I$(TCLDIR)\generic
TK_DEFINES	= $(DEBUGDEFINES)

TK_CFLAGS	= $(cdebug) $(cflags) $(cvarsdll) $(include32) \
			$(TK_INCLUDES) $(TK_DEFINES) 

######################################################################
# Link flags
######################################################################

!IF "$(NODEBUG)" == "1"
ldebug = /RELEASE
!ELSE
ldebug = -debug:full -debugtype:cv
!ENDIF

# declarations common to all linker options
lcommon = /NODEFAULTLIB /RELEASE /NOLOGO

# declarations for use on Intel i386, i486, and Pentium systems
!IF "$(MACHINE)" == "IX86"
DLLENTRY = @12
lflags   = $(lcommon) /MACHINE:$(MACHINE)
!ELSE
lflags   = $(lcommon) /MACHINE:$(MACHINE)
!ENDIF

conlflags = $(lflags) -subsystem:console -entry:mainCRTStartup
guilflags = $(lflags) -subsystem:windows -entry:WinMainCRTStartup
dlllflags = $(lflags) -entry:_DllMainCRTStartup$(DLLENTRY) -dll

!IF "$(MACHINE)" == "PPC"
libc = libc$(DBGX).lib
libcdll = crtdll$(DBGX).lib
!ELSE
libc = libc$(DBGX).lib oldnames.lib
libcdll = msvcrt$(DBGX).lib oldnames.lib
!ENDIF

baselibs   = kernel32.lib $(optlibs) advapi32.lib
winlibs    = $(baselibs) user32.lib gdi32.lib comdlg32.lib winspool.lib
guilibs	   = $(libc) $(winlibs)

guilibsdll = $(libcdll) $(winlibs)

######################################################################
# Compile flags
######################################################################

!IF "$(NODEBUG)" == "1"
!IF "$(MACHINE)" == "ALPHA"
# MSVC on Alpha doesn't understand -Ot
cdebug = -O2i -Gs -GD
!ELSE
# NOTE: Due to a bug in MSVC, we cannot use -O2 here or Tk starts to misbehave.
cdebug = -Oti -Gs -GD
!ENDIF
!ELSE
cdebug = -Z7 -Od -WX
!ENDIF

# declarations common to all compiler options
ccommon = -c -W3 -nologo -Fp$(TMPDIR)\ -YX

!IF "$(MACHINE)" == "IX86"
cflags = $(ccommon) -D_X86_=1
!ELSE
!IF "$(MACHINE)" == "MIPS"
cflags = $(ccommon) -D_MIPS_=1
!ELSE
!IF "$(MACHINE)" == "PPC"
cflags = $(ccommon) -D_PPC_=1
!ELSE
!IF "$(MACHINE)" == "ALPHA"
cflags = $(ccommon) -D_ALPHA_=1
!ENDIF
!ENDIF
!ENDIF
!ENDIF

cvars      = -DWIN32 -D_WIN32
cvarsmt    = $(cvars)
cvarsdll   = $(cvarsmt)

!IF "$(NODEBUG)" == "1"
cvarsdll   = $(cvars) -ML
!ELSE
cvarsdll   = $(cvars) -MLd
!ENDIF

CON_CFLAGS	= $(cdebug) $(cflags) $(cvars) $(include32) -DCONSOLE

######################################################################
# Project specific targets
######################################################################


tcl:   setup $(TCLSHOBJS) $(TCLOBJS)
tk:    setup $(WISHOBJS) $(TKOBJS)


wrap.exe:	tcl tk
	set LIB=$(TOOLS32)\lib
	$(link32) $(ldebug) $(guilflags) -stack:2300000 \
		-out:$@ \
		libc$(DBGX).lib oldnames.lib kernel32.lib  advapi32.lib user32.lib gdi32.lib \
		comdlg32.lib winspool.lib \
		$(WISHOBJS) $(TCLOBJS) $(TKOBJS)

libs:	libtcltk805.lib $(TMPDIR)\tk.res
	xcopy $(TMPDIR)\tk.res .


libtcltk805.lib:	tcl tk
	set LIB=$(TOOLS32)\lib
	$(link32) -lib $(lflags) \
		-out:$@ \
		$(TCLOBJS) $(TKOBJS)





#all:    setup $(WISH)
#test:	setup $(TKTEST)
#install: install-binaries install-libraries
#plugin:	setup $(TKPLUGINDLL) $(WISHP)
#tktest: setup $(TKTEST)


tk-install-binaries:
	@mkd "$(BIN_INSTALL_DIR)"
	copy $(TKDLL) "$(BIN_INSTALL_DIR)"
	copy $(WISH) "$(BIN_INSTALL_DIR)"
	@mkd "$(LIB_INSTALL_DIR)"
	copy $(TKLIB) "$(LIB_INSTALL_DIR)"

tk-install-libraries:
	@mkd "$(INCLUDE_INSTALL_DIR)"
	@mkd "$(INCLUDE_INSTALL_DIR)\X11"
	copy "$(TKROOT)\generic\tk.h" "$(INCLUDE_INSTALL_DIR)"
	xcopy "$(TKROOT)\xlib\X11\*.h" "$(INCLUDE_INSTALL_DIR)\X11"
	@mkd "$(SCRIPT_INSTALL_DIR)"
	@mkd "$(SCRIPT_INSTALL_DIR)\images"
	@mkd "$(SCRIPT_INSTALL_DIR)\demos"
	@mkd "$(SCRIPT_INSTALL_DIR)\demos\images"
	xcopy "$(TKROOT)\library" "$(SCRIPT_INSTALL_DIR)"
	xcopy "$(TKROOT)\library\images" "$(SCRIPT_INSTALL_DIR)\images"
	xcopy "$(TKROOT)\library\demos" "$(SCRIPT_INSTALL_DIR)\demos"
	xcopy "$(TKROOT)\library\demos\images" "$(SCRIPT_INSTALL_DIR)\demos\images"

$(TKLIB): $(TKDLL)

$(TKDLL): $(TKOBJS) $(TMPDIR)\tk.res $(TMPDIR)\tk.def
	set LIB=$(TOOLS32)\lib
       $(link32) $(ldebug) $(dlllflags) -def:$(TMPDIR)\tk.def \
		-out:$@ $(TMPDIR)\tk.res $(TCLLIBDIR)\$(TCLLIB) \
		$(guilibsdll) @<<
			$(TKOBJS)
<<

$(TKPLUGINLIB): $(TKPLUGINDLL)

$(TKPLUGINDLL): $(TKOBJS) $(TMPDIR)\tk.res $(TMPDIR)\plugin.def
	set LIB=$(TOOLS32)\lib
        $(link32) $(ldebug) $(dlllflags) -def:$(TMPDIR)\plugin.def \
		-out:$@ $(TMPDIR)\tk.res $(TCLLIBDIR)\$(TCLPLUGINLIB) \
		$(guilibsdll) @<<
			$(TKOBJS)
<<

$(WISH): $(WISHOBJS) $(TKLIB) $(TMPDIR)\wish.res
	set LIB=$(TOOLS32)\lib
	$(link32) $(ldebug) $(guilflags) $(TMPDIR)\wish.res -stack:2300000 \
		-out:$@ \
		$(guilibsdll) $(TCLLIBDIR)\$(TCLLIB) $(TKLIB) $(WISHOBJS) 

$(WISHP): $(WISHOBJS) $(TKPLUGINLIB) $(TMPDIR)\wish.res
	set LIB=$(TOOLS32)\lib
	$(link32) $(ldebug) $(guilflags) $(TMPDIR)\wish.res -stack:2300000 \
		-out:$@ \
		$(guilibsdll) $(TCLLIBDIR)\$(TCLPLUGINLIB) \
		$(TKPLUGINLIB) $(WISHOBJS) 

$(TKTEST): $(TKTESTOBJS) $(TKLIB) $(TMPDIR)\wish.res
	set LIB=$(TOOLS32)\lib
	$(link32) $(ldebug) $(guilflags) $(TMPDIR)\wish.res -stack:2300000 \
		-out:$@ \
		$(guilibsdll) $(TCLLIBDIR)\$(TCLLIB) $(TKLIB) $(TKTESTOBJS)

$(TMPDIR)\tk.def: $(DUMPEXTS) $(TKOBJS)
	$(DUMPEXTS) -o $@ $(TKDLLNAME) @<<
		$(TKOBJS)
<<

$(TMPDIR)\plugin.def: $(DUMPEXTS) $(TKOBJS)
	$(DUMPEXTS) -o $@ $(TKPLUGINDLLNAME) @<<
		$(TKOBJS)
<<

$(DUMPEXTS): $(TCLDIR)\win\winDumpExts.c
	$(cc32) $(CON_CFLAGS) -Fo$(TMPDIR)\ $?
	set LIB=$(TOOLS32)\lib
	$(link32) $(ldebug) $(conlflags) $(guilibs) -out:$@ \
		$(TMPDIR)\winDumpExts.obj 

#
# Special case object file targets
#

$(TMPDIR)\testMain.obj: $(TKROOT)\win\winMain.c
	$(cc32) $(TK_CFLAGS) -DTK_TEST -Fo$@ $?

$(TMPDIR)\tkTest.obj: $(TKROOT)\generic\tkTest.c
	$(cc32) $(TK_CFLAGS) -Fo$@ $?

$(TMPDIR)\tkSquare.obj: $(TKROOT)\generic\tkSquare.c
	$(cc32) $(TK_CFLAGS) -Fo$@ $?

$(TMPDIR)\winMain.obj: $(TKROOT)\win\winMain.c
	$(cc32) -DSTATIC_BUILD $(TK_CFLAGS) -Fo$@ $?

#
# Implicit rules
#

{$(XLIBDIR)}.c{$(TMPDIR)}.obj:
	$(cc32) -DSTATIC_BUILD $(TK_CFLAGS) -Fo$(TMPDIR)\ $<

{$(TKGENERICDIR)}.c{$(TMPDIR)}.obj:
	$(cc32) -DSTATIC_BUILD $(TK_CFLAGS) -Fo$(TMPDIR)\ $<

{$(TKWINDIR)}.c{$(TMPDIR)}.obj:
	$(cc32) -DSTATIC_BUILD $(TK_CFLAGS) -Fo$(TMPDIR)\ $<

{$(TKROOT)\unix}.c{$(TMPDIR)}.obj:
	$(cc32) -DSTATIC_BUILD $(TK_CFLAGS) -Fo$(TMPDIR)\ $<

{$(RCDIR)}.rc{$(TMPDIR)}.res:
	$(rc32) -fo $@ -r -i $(TKGENERICDIR) $<

tkclean:
        -@del $(OUTDIR)\*.exp 
	-@del $(OUTDIR)\*.lib 
	-@del $(OUTDIR)\*.dll 
	-@del $(OUTDIR)\*.exe
	-@del $(OUTDIR)\*.pdb
	-@del $(TMPDIR)\*.pch
        -@del $(TMPDIR)\*.obj
        -@del $(TMPDIR)\*.res
        -@del $(TMPDIR)\*.def
        -@del $(TMPDIR)\*.exe
	-@rmd $(OUTDIR)
	-@rmd $(TMPDIR)

# dependencies

$(TMPDIR)\tk.res: \
    $(RCDIR)\buttons.bmp \
    $(RCDIR)\cursor*.cur \
    $(RCDIR)\tk.ico

$(TKGENERICDIR)/default.h: $(TKWINDIR)/tkWinDefault.h
$(TKGENERICDIR)/tkButton.c: $(TKGENERICDIR)/default.h
$(TKGENERICDIR)/tkCanvas.c: $(TKGENERICDIR)/default.h
$(TKGENERICDIR)/tkEntry.c: $(TKGENERICDIR)/default.h
$(TKGENERICDIR)/tkFrame.c: $(TKGENERICDIR)/default.h
$(TKGENERICDIR)/tkListbox.c: $(TKGENERICDIR)/default.h
$(TKGENERICDIR)/tkMenu.c: $(TKGENERICDIR)/default.h
$(TKGENERICDIR)/tkMenubutton.c: $(TKGENERICDIR)/default.h
$(TKGENERICDIR)/tkMessage.c: $(TKGENERICDIR)/default.h
$(TKGENERICDIR)/tkScale.c: $(TKGENERICDIR)/default.h
$(TKGENERICDIR)/tkScrollbar.c: $(TKGENERICDIR)/default.h
$(TKGENERICDIR)/tkText.c: $(TKGENERICDIR)/default.h
$(TKGENERICDIR)/tkTextIndex.c: $(TKGENERICDIR)/default.h
$(TKGENERICDIR)/tkTextTag.c: $(TKGENERICDIR)/default.h

$(TKGENERICDIR)/tkText.c: $(TKGENERICDIR)/tkText.h
$(TKGENERICDIR)/tkTextBTree.c: $(TKGENERICDIR)/tkText.h
$(TKGENERICDIR)/tkTextDisp.c: $(TKGENERICDIR)/tkText.h
$(TKGENERICDIR)/tkTextDisp.c: $(TKGENERICDIR)/tkText.h
$(TKGENERICDIR)/tkTextImage.c: $(TKGENERICDIR)/tkText.h
$(TKGENERICDIR)/tkTextIndex.c: $(TKGENERICDIR)/tkText.h
$(TKGENERICDIR)/tkTextMark.c: $(TKGENERICDIR)/tkText.h
$(TKGENERICDIR)/tkTextTag.c: $(TKGENERICDIR)/tkText.h
$(TKGENERICDIR)/tkTextWind.c: $(TKGENERICDIR)/tkText.h

$(TKGENERICDIR)/tkMacWinMenu.c: $(TKGENERICDIR)/tkMenu.h
$(TKGENERICDIR)/tkMenu.c: $(TKGENERICDIR)/tkMenu.h
$(TKGENERICDIR)/tkMenuDraw.c: $(TKGENERICDIR)/tkMenu.h
$(TKWINDIR)/tkWinMenu.c: $(TKGENERICDIR)/tkMenu.h









