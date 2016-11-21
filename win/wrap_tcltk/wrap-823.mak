#---------------------------------------------------------------------
#ROOT		= e:\laurent\perso\tcltk8.2.3
#DEVSTUDIO	= d:\devstudio
ROOT		= d:\work\tcltk8.2.3
DEVSTUDIO	= d:\progra~1\devstudio

TCLROOT		= $(ROOT)\tcl8.2.3
TCLDIR            = $(TCLROOT)
TKROOT		= $(ROOT)\tk8.2.3

TOOLS32		= $(DEVSTUDIO)\vc
TOOLS32_rc	= $(DEVSTUDIO)\sharedide
TOOLS16		= d:\msvc

INSTALLDIR	= d:\work\Tcl
#---------------------------------------------------------------------



# Set this to the appropriate value of /MACHINE: for your platform
MACHINE	= IX86

# Set NODEBUG to 0 to compile with symbols
NODEBUG = 1




######################################################################
# Do not modify below this line
######################################################################

NAMEPREFIX = tcl
STUBPREFIX = $(NAMEPREFIX)stub
DOTVERSION = 8.2
VERSION = 82

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

TCLSTUBLIBNAME	= $(STUBPREFIX)$(VERSION)$(DBGX).lib
TCLSTUBLIB	= $(OUTDIR)\$(TCLSTUBLIBNAME)

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
TCLDDEDLLNAME	= $(NAMEPREFIX)dde$(VERSION)$(DBGX).dll
TCLDDEDLL	= $(OUTDIR)\$(TCLDDEDLLNAME)
TCLTEST		= $(OUTDIR)\$(NAMEPREFIX)test.exe
DUMPEXTS	= $(TMPDIR)\dumpexts.exe
CAT16		= $(TMPDIR)\cat16.exe
CAT32		= $(TMPDIR)\cat32.exe
RMDIR		= .\rmd.bat
MKDIR		= .\mkd.bat
RM		= del

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
	$(TMPDIR)\tclThreadTest.obj \
	$(TMPDIR)\tclWinTest.obj \
	$(TMPDIR)\testMain.obj

TCLOBJS = \
	$(TMPDIR)\regcomp.obj \
	$(TMPDIR)\regexec.obj \
	$(TMPDIR)\regfree.obj \
	$(TMPDIR)\regerror.obj \
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
	$(TMPDIR)\tclCompCmds.obj \
	$(TMPDIR)\tclCompExpr.obj \
	$(TMPDIR)\tclCompile.obj \
	$(TMPDIR)\tclDate.obj \
	$(TMPDIR)\tclEncoding.obj \
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
	$(TMPDIR)\tclLiteral.obj \
	$(TMPDIR)\tclListObj.obj \
	$(TMPDIR)\tclLoad.obj \
	$(TMPDIR)\tclMain.obj \
	$(TMPDIR)\tclNamesp.obj \
	$(TMPDIR)\tclNotify.obj \
	$(TMPDIR)\tclObj.obj \
	$(TMPDIR)\tclPanic.obj \
	$(TMPDIR)\tclParse.obj \
	$(TMPDIR)\tclParseExpr.obj \
	$(TMPDIR)\tclPipe.obj \
	$(TMPDIR)\tclPkg.obj \
	$(TMPDIR)\tclPosixStr.obj \
	$(TMPDIR)\tclPreserve.obj \
	$(TMPDIR)\tclProc.obj \
	$(TMPDIR)\tclRegexp.obj \
	$(TMPDIR)\tclResolve.obj \
	$(TMPDIR)\tclResult.obj \
	$(TMPDIR)\tclScan.obj \
	$(TMPDIR)\tclStringObj.obj \
	$(TMPDIR)\tclStubInit.obj \
	$(TMPDIR)\tclStubLib.obj \
	$(TMPDIR)\tclThread.obj \
	$(TMPDIR)\tclTimer.obj \
	$(TMPDIR)\tclUtf.obj \
	$(TMPDIR)\tclUtil.obj \
	$(TMPDIR)\tclVar.obj \
	$(TMPDIR)\tclWin32Dll.obj \
	$(TMPDIR)\tclWinChan.obj \
	$(TMPDIR)\tclWinConsole.obj \
	$(TMPDIR)\tclWinSerial.obj \
	$(TMPDIR)\tclWinError.obj \
	$(TMPDIR)\tclWinFCmd.obj \
	$(TMPDIR)\tclWinFile.obj \
	$(TMPDIR)\tclWinInit.obj \
	$(TMPDIR)\tclWinLoad.obj \
	$(TMPDIR)\tclWinMtherr.obj \
	$(TMPDIR)\tclWinNotify.obj \
	$(TMPDIR)\tclWinPipe.obj \
	$(TMPDIR)\tclWinSock.obj \
	$(TMPDIR)\tclWinThrd.obj \
	$(TMPDIR)\tclWinTime.obj 

TCLSTUBOBJS = $(TMPDIR)\tclStubLib.obj \

cc32		= "$(TOOLS32)\bin\cl.exe"
link32		= "$(TOOLS32)\bin\link.exe"
rc32		= "$(TOOLS32_rc)\bin\rc.exe"
include32	= -I"$(TOOLS32)\include"
lib32		= "$(TOOLS32)\bin\lib.exe"

cc16		= "$(TOOLS16)\bin\cl.exe"
link16		= "$(TOOLS16)\bin\link.exe"
rc16		= "$(TOOLS16)\bin\rc.exe"
include16	= -I"$(TOOLS16)\include"

TCLWINDIR		= $(TCLROOT)\win
TCLGENERICDIR	= $(TCLROOT)\generic

TCL_INCLUDES	= -I$(TCLWINDIR) -I$(TCLGENERICDIR)
TCL_DEFINES	= -D__WIN32__ $(DEBUGDEFINES) $(THREADDEFINES)

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
lflags	 = $(lcommon) /MACHINE:$(MACHINE)
!ELSE
lflags	 = $(lcommon) /MACHINE:$(MACHINE)
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
winlibs	   = $(baselibs) gdi32.lib comdlg32.lib winspool.lib

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

cvars	   = -DWIN32 -D_WIN32
cvarsmt	   = $(cvars)
cvarsdll   = $(cvarsmt)

!IF "$(NODEBUG)" == "1"
cvarsdll   = $(cvars) -ML
!ELSE
cvarsdll   = $(cvars) -MLd
!ENDIF

######################################################################
# Project specific targets
######################################################################

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

$(TCLSTUBLIB): $(TCLSTUBOBJS)
	$(lib32) /out:$@ $(TCLSTUBOBJS)

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
	set LIB=$(TOOLS32)\lib
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

$(TCLDDEDLL): $(TMPDIR)\tclWinDde.obj $(TCLSTUBLIB)
	set LIB="$(TOOLS32)\lib"
	$(link32) $(ldebug) $(dlllflags) -out:$@ $(TMPDIR)\tclWinDde.obj \
		$(conlibsdll) $(TCLSTUBLIB)

$(TCLREGDLL): $(TMPDIR)\tclWinReg.obj $(TCLSTUBLIB)
	set LIB="$(TOOLS32)\lib"
	$(link32) $(ldebug) $(dlllflags) -out:$@ $(TMPDIR)\tclWinReg.obj \
		$(conlibsdll) $(TCLSTUBLIB)

$(CAT32): $(TCLWINDIR)\cat.c
	$(cc32) $(CON_CFLAGS) -Fo$(TMPDIR)\ $?
	set LIB="$(TOOLS32)\lib"
	$(link32) $(conlflags) -out:$@ -stack:16384 $(TMPDIR)\cat.obj $(conlibs)

$(CAT16): $(TCLWINDIR)\cat.c
	if exist $(cc16) $(cc16) $(DOS_CFLAGS) -Fo$(TMPDIR)\ $?
	set LIB=$(TOOLS16)\lib
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

#
# Regenerate the stubs files.
#

genstubs:
	tclsh$(VERSION) $(TCLROOT)\tools\genStubs.tcl $(TCLGENERICDIR) \
		$(TCLGENERICDIR)\tcl.decls $(TCLGENERICDIR)\tclInt.decls

#
# Special case object file targets
#

$(TMPDIR)\tclWinInit.obj: $(TCLWINDIR)\tclWinInit.c
	$(cc32) -DSTATIC_BUILD -DBUILD_tcl $(TCL_CFLAGS) $(EXTFLAGS) -Fo$(TMPDIR)\ $?

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

# The following objects should be built using the stub interfaces

$(TMPDIR)\tclWinReg.obj : $(TCLWINDIR)\tclWinReg.c
	$(cc32) $(TCL_CFLAGS) -DUSE_TCL_STUBS -Fo$@ $?

$(TMPDIR)\tclWinDde.obj : $(TCLWINDIR)\tclWinDde.c
	$(cc32) $(TCL_CFLAGS) -DUSE_TCL_STUBS -Fo$@ $?

# The following objects are part of the stub library and should not
# be built as DLL objects but none of the symbols should be exported

$(TMPDIR)\tclStubLib.obj : $(TCLGENERICDIR)\tclStubLib.c
	$(cc32) $(TCL_CFLAGS) -DSTATIC_BUILD -Fo$@ $?


# Dedependency rules

$(TCLGENERICDIR)\regcomp.c: \
	$(TCLGENERICDIR)\regguts.h \
	$(TCLGENERICDIR)\regc_lex.c \
	$(TCLGENERICDIR)\regc_color.c \
	$(TCLGENERICDIR)\regc_nfa.c \
	$(TCLGENERICDIR)\regc_cvec.c \
	$(TCLGENERICDIR)\regc_locale.c
$(TCLGENERICDIR)\regcustom.h: \
	$(TCLGENERICDIR)\tclInt.h \
	$(TCLGENERICDIR)\tclPort.h \
	$(TCLGENERICDIR)\regex.h
$(TCLGENERICDIR)\regexec.c: \
	$(TCLGENERICDIR)\rege_dfa.c \
	$(TCLGENERICDIR)\regguts.h
$(TCLGENERICDIR)\regerror.c: $(TCLGENERICDIR)\regguts.h
$(TCLGENERICDIR)\regfree.c: $(TCLGENERICDIR)\regguts.h
$(TCLGENERICDIR)\regfronts.c: $(TCLGENERICDIR)\regguts.h
$(TCLGENERICDIR)\regguts.h: $(TCLGENERICDIR)\regcustom.h

#
# Implicit rules
#

{$(TCLWINDIR)}.c{$(TMPDIR)}.obj:
    $(cc32) -DSTATIC_BUILD -DBUILD_tcl $(TCL_CFLAGS) -Fo$(TMPDIR)\ $<

{$(TCLGENERICDIR)}.c{$(TMPDIR)}.obj:
    $(cc32) -DSTATIC_BUILD -DBUILD_tcl $(TCL_CFLAGS) -Fo$(TMPDIR)\ $<

{$(TCLROOT)\compat}.c{$(TMPDIR)}.obj:
    $(cc32) -DSTATIC_BUILD -DBUILD_tcl $(TCL_CFLAGS) -Fo$(TMPDIR)\ $<

{$(TCLWINDIR)}.rc{$(TMPDIR)}.res:
	$(rc32) -fo $@ -r -i $(TCLGENERICDIR) -i $(TCLWINDIR) -D__WIN32__ \
		$(TCL_DEFINES) $<

clean:
	-@$(RM) $(OUTDIR)\*.exp 
	-@$(RM) $(OUTDIR)\*.lib 
	-@$(RM) $(OUTDIR)\*.dll 
	-@$(RM) $(OUTDIR)\*.exe
	-@$(RM) $(OUTDIR)\*.pdb
	-@$(RM) $(TMPDIR)\*.pch
	-@$(RM) $(TMPDIR)\*.obj
	-@$(RM) $(TMPDIR)\*.res
	-@$(RM) $(TMPDIR)\*.def
	-@$(RM) $(TMPDIR)\*.exe
	-@$(RMDIR) $(OUTDIR)
	-@$(RMDIR) $(TMPDIR)






######################################################################
# Do not modify below this line
######################################################################

TCLNAMEPREFIX = tcl
TKNAMEPREFIX = tk
WISHNAMEPREFIX = wish
VERSION = 82
DOTVERSION = 8.2

TCLSTUBPREFIX = $(TCLNAMEPREFIX)stub
TKSTUBPREFIX  = $(TKNAMEPREFIX)stub


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
TCLSTUBLIB	= $(TCLSTUBPREFIX)$(VERSION)$(DBGX).lib
TKDLLNAME	= $(TKNAMEPREFIX)$(VERSION)$(DBGX).dll
TKDLL 		= $(OUTDIR)\$(TKDLLNAME)
TKLIB 		= $(OUTDIR)\$(TKNAMEPREFIX)$(VERSION)$(DBGX).lib
TKSTUBLIBNAME	= $(TKSTUBPREFIX)$(VERSION)$(DBGX).lib
TKSTUBLIB	= $(OUTDIR)\$(TKSTUBLIBNAME)
TKPLUGINDLLNAME	= $(TKNAMEPREFIX)$(VERSION)p$(DBG).dll
TKPLUGINDLL 	= $(OUTDIR)\$(TKPLUGINDLLNAME)
TKPLUGINLIB 	= $(OUTDIR)\$(TKNAMEPREFIX)$(VERSION)p$(DBGX).lib

WISH 		= $(OUTDIR)\$(WISHNAMEPREFIX)$(VERSION)$(DBGX).exe
WISHC 		= $(OUTDIR)\$(WISHNAMEPREFIX)c$(VERSION)$(DBGX).exe
WISHP 		= $(OUTDIR)\$(WISHNAMEPREFIX)p$(VERSION)$(DBGX).exe
TKTEST 		= $(OUTDIR)\$(TKNAMEPREFIX)test.exe
DUMPEXTS 	= $(TMPDIR)\dumpexts.exe
CAT32           = $(TMPDIR)\cat32.exe

BIN_INSTALL_DIR = $(INSTALLDIR)\bin
INCLUDE_INSTALL_DIR = $(INSTALLDIR)\include
LIB_INSTALL_DIR = $(INSTALLDIR)\lib
SCRIPT_INSTALL_DIR = $(LIB_INSTALL_DIR)\tk$(DOTVERSION)

WISHOBJS = \
	$(TMPDIR)\winMain.obj

TKTESTOBJS = \
	$(TMPDIR)\tkTest.obj \
	$(TMPDIR)\tkSquare.obj \
	$(TMPDIR)\testMain.obj \
	$(TCLLIBDIR)\tclThreadTest.obj

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
	$(TMPDIR)\tkWinConfig.obj \
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
	$(TMPDIR)\tkWinTest.obj \
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
	$(TMPDIR)\tkObj.obj \
	$(TMPDIR)\tkOldConfig.obj \
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
	$(TMPDIR)\tkStubInit.obj \
	$(TMPDIR)\tkStubLib.obj \
	$(TMPDIR)\tkWindow.obj

TKSTUBOBJS = $(TMPDIR)\tkStubLib.obj \


cc32		= "$(TOOLS32)\bin\cl.exe"
link32		= "$(TOOLS32)\bin\link.exe"
lib32		= "$(TOOLS32)\bin\lib.exe"
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
TK_DEFINES	= -D__WIN32__ $(DEBUGDEFINES) $(THREADDEFINES)

TK_CFLAGS	= $(cdebug) $(cflags) $(cvarsdll) $(include32) \
			$(TK_INCLUDES) $(TK_DEFINES) -DUSE_TCL_STUBS

WISH_CFLAGS	= $(cdebug) $(cflags) $(cvarsdll) $(include32) \
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
conlibs    = $(libc) $(baselibs)
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

$(TKLIB): $(TKDLL) $(TKSTUBLIB)

$(TKSTUBLIB): $(TKSTUBOBJS)
        $(lib32) /out:$@ $(TKSTUBOBJS)

$(TKDLL): $(TKOBJS) $(TMPDIR)\tk.res $(TMPDIR)\tk.def
	set LIB=$(TOOLS32)\lib
       $(link32) $(ldebug) $(dlllflags) -def:$(TMPDIR)\tk.def \
		-out:$@ $(TMPDIR)\tk.res $(TCLLIBDIR)\$(TCLSTUBLIB) \
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
	$(link32) $(ldebug) $(guilflags) $(TMPDIR)\wish.res -out:$@ \
		$(guilibsdll) $(TCLLIBDIR)\$(TCLLIB) $(TKLIB) $(WISHOBJS) 

$(WISHC): $(WISHOBJS) $(TKLIB) $(TMPDIR)\wish.res
	set LIB=$(TOOLS32)\lib
	$(link32) $(ldebug) $(conlflags) $(TMPDIR)\wish.res -out:$@ \
		$(guilibsdll) $(TCLLIBDIR)\$(TCLLIB) $(TKLIB) $(WISHOBJS) 

$(WISHP): $(WISHOBJS) $(TKPLUGINLIB) $(TMPDIR)\wish.res
	set LIB=$(TOOLS32)\lib
	$(link32) $(ldebug) $(guilflags) $(TMPDIR)\wish.res -out:$@ \
		$(guilibsdll) $(TCLLIBDIR)\$(TCLPLUGINLIB) \
		$(TKPLUGINLIB) $(WISHOBJS) 

$(TKTEST): $(TKTESTOBJS) $(TKLIB) $(TMPDIR)\wish.res
	set LIB=$(TOOLS32)\lib
	$(link32) $(ldebug) $(guilflags) $(TMPDIR)\wish.res -out:$@ \
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

$(CAT32): $(TCLDIR)\win\cat.c
	$(cc32) $(CON_CFLAGS) -Fo$(TMPDIR)\ $?
	set LIB=$(TOOLS32)\lib
	$(link32) $(conlflags) -out:$@ -stack:16384 $(TMPDIR)\cat.obj $(conlibs)

#
# Regenerate the stubs files.
#

genstubs:
	tclsh$(VERSION) $(TCLDIR)\tools\genStubs.tcl $(TKGENERICDIR) \
		$(TKGENERICDIR)\tk.decls $(TKGENERICDIR)\tkInt.decls

#
# Special case object file targets
#

$(TMPDIR)\testMain.obj: $(TKROOT)\win\winMain.c
	$(cc32) $(WISH_CFLAGS) -DTK_TEST -Fo$@ $?

$(TMPDIR)\tkTest.obj: $(TKROOT)\generic\tkTest.c
	$(cc32) $(WISH_CFLAGS) -Fo$@ $?

$(TMPDIR)\tkSquare.obj: $(TKROOT)\generic\tkSquare.c
	$(cc32) $(WISH_CFLAGS) -Fo$@ $?

$(TMPDIR)\winMain.obj: $(TKROOT)\win\winMain.c
	$(cc32) $(WISH_CFLAGS) -Fo$@ $?

$(TMPDIR)\tkStubLib.obj : $(TKGENERICDIR)\tkStubLib.c
	$(cc32) $(TK_CFLAGS) -DSTATIC_BUILD -Fo$@ $?

#
# Implicit rules
#

{$(XLIBDIR)}.c{$(TMPDIR)}.obj:
	$(cc32) -DSTATIC_BUILD -DBUILD_tk $(TK_CFLAGS) -Fo$(TMPDIR)\ $<

{$(TKGENERICDIR)}.c{$(TMPDIR)}.obj:
	$(cc32) -DSTATIC_BUILD -DBUILD_tk $(TK_CFLAGS) -Fo$(TMPDIR)\ $<

{$(TKWINDIR)}.c{$(TMPDIR)}.obj:
	$(cc32) -DSTATIC_BUILD -DBUILD_tk $(TK_CFLAGS) -Fo$(TMPDIR)\ $<

{$(TKROOT)\unix}.c{$(TMPDIR)}.obj:
	$(cc32) -DSTATIC_BUILD -DBUILD_tk $(TK_CFLAGS) -Fo$(TMPDIR)\ $<

{$(RCDIR)}.rc{$(TMPDIR)}.res:
	$(rc32) -fo $@ -r -i "$(TKGENERICDIR)" -i "$(TOOLS32)\include" \
		-i "$(TCLDIR)\generic" $<

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


#---------------------------------------------------------------------
setup:
	@mkd $(TMPDIR)
	@mkd $(OUTDIR)

tcl:   setup $(TCLSHOBJS) $(TCLOBJS)
tk:    setup $(WISHOBJS) $(TKOBJS)

wrap.exe:	tcl tk
	set LIB=$(TOOLS32)\lib
	$(link32) $(ldebug) $(guilflags) -stack:2300000 \
		-out:$@ \
		libc$(DBGX).lib oldnames.lib kernel32.lib  advapi32.lib user32.lib gdi32.lib \
		comdlg32.lib winspool.lib \
		$(WISHOBJS) $(TCLOBJS) $(TKOBJS)

libs	:	libtcltk823.lib $(TMPDIR)\tk.res
	xcopy $(TMPDIR)\tk.res .

libtcltk823.lib:	tcl tk
	set LIB=$(TOOLS32)\lib
	$(link32) -lib $(lflags) \
		-out:$@ \
		$(TCLOBJS) $(TKOBJS)
#---------------------------------------------------------------------
