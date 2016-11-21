OUTDIR=.\Release
INTDIR=.\Release


VERSION=8.4.1
BASEDIR=..\tcltk$(VERSION)
TCLDIR=$(BASEDIR)\tcl$(VERSION)
TKDIR=$(BASEDIR)\tk$(VERSION)

PACKER=.\upx --compress-resources=0


#-------------------------------------------------------

ALL : EN FR

ONE: ".\3s_en.exe"

EN : ".\3s_en.exe" ".\3s_u_en.exe"

FR : ".\3s_fr.exe" ".\3s_u_fr.exe"

TEST:	".\live\3s_test.exe"

PACK: 
	$(PACKER) .\3s_en.exe
	$(PACKER) .\3s_fr.exe
	$(PACKER) .\3s_u_en.exe
	$(PACKER) .\3s_u_fr.exe
	"c:\program files\inno setup 2\iscc" 3s_fr.iss
	"c:\program files\inno setup 2\iscc" 3s_u_fr.iss
	"c:\program files\inno setup 2\iscc" 3s_en.iss
	"c:\program files\inno setup 2\iscc" 3s_u_en.iss
	copy .\Output\*.* G:


CHECK:	".\3s_u_en.exe"
CHECK2:
	$(PACKER) .\3s_u_en.exe
 	copy .\3s_u_en.exe G:
	copy .\Tktable.dll G:


#-------------------------------------------------------


!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF


CPP=cl.exe
MTL=midl.exe
RSC=rc.exe



#################################################################################


"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"


CPP_PROJ=/nologo /MT /W3 /GX /O2 /I "$(TCLDIR)\generic" /I "$(TKDIR)\generic" /I "$(TKDIR)\win" /I "$(TKDIR)\xlib" \
/D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "NDEBUG" /D "STATIC_BUILD" /Fp"$(INTDIR)\skating.pch" \
/YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
CPP_OBJS=.\Release/
CPP_SBRS=.
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /win32 
RSC_PROJ=/l 0x40c /fo"$(INTDIR)\skating.res" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\skating.bsc" 
BSC32_SBRS= \
	


LINK32=link.exe
LINK32_FLAGS=kernel32.lib advapi32.lib user32.lib shell32.lib gdi32.lib comdlg32.lib winspool.lib imm32.lib comctl32.lib \
$(BASEDIR)\tcl84s.lib $(BASEDIR)\tk84s.lib /nologo /subsystem:windows /incremental:no \
/pdb:"$(OUTDIR)\skating.pdb" /machine:I386
LINK32_OBJS= \
	"$(INTDIR)\Adler32.obj" \
	"$(INTDIR)\Compress.obj" \
	"$(INTDIR)\Crc32.obj" \
	"$(INTDIR)\Deflate.obj" \
	"$(INTDIR)\Gzio.obj" \
	"$(INTDIR)\Infblock.obj" \
	"$(INTDIR)\Infcodes.obj" \
	"$(INTDIR)\Inffast.obj" \
	"$(INTDIR)\Inflate.obj" \
	"$(INTDIR)\Inftrees.obj" \
	"$(INTDIR)\Infutil.obj" \
	"$(INTDIR)\printer.obj" \
	"$(INTDIR)\skating.res" \
	"$(INTDIR)\Trees.obj" \
	"$(INTDIR)\Uncompr.obj" \
	"$(INTDIR)\Zutil.obj" \
	"$(INTDIR)\Zip.obj" \
	"$(INTDIR)\My_zip.obj" \


.c{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

######################################################################################


SOURCE=.\3s_script_full_en.c
"$(INTDIR)\3s_script_full_en.obj" : $(SOURCE) "$(INTDIR)"

SOURCE=.\3s_script_full_fr.c
"$(INTDIR)\3s_script_full_fr.obj" : $(SOURCE) "$(INTDIR)"


".\3s_en.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS) "$(INTDIR)\winMain.obj" "$(INTDIR)\gdi.obj" "$(INTDIR)\3s_script_full_en.obj"
    $(LINK32) @<<
  $(LINK32_FLAGS) /out:".\3s_en.exe" $(LINK32_OBJS) "$(INTDIR)\winMain.obj" "$(INTDIR)\gdi.obj" "$(INTDIR)\3s_script_full_en.obj"
<<

".\3s_fr.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS) "$(INTDIR)\winMain.obj" "$(INTDIR)\gdi.obj" "$(INTDIR)\3s_script_full_fr.obj"
    $(LINK32) @<<
  $(LINK32_FLAGS) /out:".\3s_fr.exe" $(LINK32_OBJS) "$(INTDIR)\winMain.obj" "$(INTDIR)\gdi.obj" "$(INTDIR)\3s_script_full_fr.obj"
<<


".\3s_u_en.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS) "$(INTDIR)\winMain.obj" "$(INTDIR)\gdi_unicode.obj" "$(INTDIR)\3s_script_full_en.obj"
    $(LINK32) @<<
  $(LINK32_FLAGS) /out:".\3s_u_en.exe" $(LINK32_OBJS) "$(INTDIR)\winMain.obj" "$(INTDIR)\gdi_unicode.obj" "$(INTDIR)\3s_script_full_en.obj"
<<

".\3s_u_fr.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS) "$(INTDIR)\winMain.obj" "$(INTDIR)\gdi_unicode.obj" "$(INTDIR)\3s_script_full_fr.obj"
    $(LINK32) @<<
  $(LINK32_FLAGS) /out:".\3s_u_fr.exe" $(LINK32_OBJS) "$(INTDIR)\winMain.obj" "$(INTDIR)\gdi_unicode.obj" "$(INTDIR)\3s_script_full_fr.obj"
<<


".\live\3s_test.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS) "$(INTDIR)\winMain_test.obj" "$(INTDIR)\gdi_unicode.obj" 
    $(LINK32) @<<
  $(LINK32_FLAGS) /out:".\live\3s_test.exe" $(LINK32_OBJS) "$(INTDIR)\winMain_test.obj" "$(INTDIR)\gdi_unicode.obj"
<<


######################################################################################


SOURCE=.\Adler32.c
DEP_CPP_ADLER=\
	".\zconf.h"\
	".\zlib.h"
"$(INTDIR)\Adler32.obj" : $(SOURCE) $(DEP_CPP_ADLER) "$(INTDIR)"


SOURCE=.\Crc32.c
DEP_CPP_CRC32=\
	".\zconf.h"\
	".\zlib.h"
"$(INTDIR)\Crc32.obj" : $(SOURCE) $(DEP_CPP_CRC32) "$(INTDIR)"


SOURCE=.\Deflate.c
DEP_CPP_DEFLA=\
	".\deflate.h"\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\Deflate.obj" : $(SOURCE) $(DEP_CPP_DEFLA) "$(INTDIR)"


SOURCE=.\gdi.c
DEP_CPP_GDI_C=\
	"$(TCLDIR)\generic\tcl.h"\
	"$(TKDIR)\generic\tk.h"\
	"$(TKDIR)\xlib\x11\x.h"\
	"$(TKDIR)\xlib\x11\xfuncproto.h"\
	"$(TKDIR)\xlib\x11\xlib.h"
"$(INTDIR)\gdi.obj" : $(SOURCE) $(DEP_CPP_GDI_C) "$(INTDIR)"
"$(INTDIR)\gdi_unicode.obj" : $(SOURCE) $(DEP_CPP_GDI_C) "$(INTDIR)"
	$(CPP) /nologo /MT /W3 /GX /O1 /I "$(TCLDIR)\generic" /I "$(TKDIR)\generic" /I\
	"$(TKDIR)\win" /I "$(TKDIR)\xlib" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" \
	/D "STATIC_BUILD" /D "__WIN32__" /D "USE_UNICODE" \
	/Fp"$(INTDIR)\skating.pch" /YX /Fd"$(INTDIR)\\" \
	/Fo"$(INTDIR)\gdi_unicode.obj" /c $(SOURCE)


SOURCE=.\Gzio.c
DEP_CPP_GZIO_=\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\Gzio.obj" : $(SOURCE) $(DEP_CPP_GZIO_) "$(INTDIR)"


SOURCE=.\Infblock.c
DEP_CPP_INFBL=\
	".\infblock.h"\
	".\infcodes.h"\
	".\inftrees.h"\
	".\infutil.h"\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\Infblock.obj" : $(SOURCE) $(DEP_CPP_INFBL) "$(INTDIR)"


SOURCE=.\Infcodes.c
DEP_CPP_INFCO=\
	".\infblock.h"\
	".\infcodes.h"\
	".\inffast.h"\
	".\inftrees.h"\
	".\infutil.h"\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\Infcodes.obj" : $(SOURCE) $(DEP_CPP_INFCO) "$(INTDIR)"


SOURCE=.\Inffast.c
DEP_CPP_INFFA=\
	".\infblock.h"\
	".\infcodes.h"\
	".\inffast.h"\
	".\inftrees.h"\
	".\infutil.h"\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\Inffast.obj" : $(SOURCE) $(DEP_CPP_INFFA) "$(INTDIR)"


SOURCE=.\Inflate.c
DEP_CPP_INFLA=\
	".\infblock.h"\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\Inflate.obj" : $(SOURCE) $(DEP_CPP_INFLA) "$(INTDIR)"


SOURCE=.\Inftrees.c
DEP_CPP_INFTR=\
	".\inftrees.h"\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\Inftrees.obj" : $(SOURCE) $(DEP_CPP_INFTR) "$(INTDIR)"


SOURCE=.\Infutil.c
DEP_CPP_INFUT=\
	".\infblock.h"\
	".\infcodes.h"\
	".\inftrees.h"\
	".\infutil.h"\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\Infutil.obj" : $(SOURCE) $(DEP_CPP_INFUT) "$(INTDIR)"





SOURCE=.\Compress.c
DEP_CPP_INFUT=\
	".\infblock.h"\
	".\infcodes.h"\
	".\inftrees.h"\
	".\infutil.h"\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\Compress.obj" : $(SOURCE) $(DEP_CPP_INFUT) "$(INTDIR)"

SOURCE=.\zip.c
DEP_CPP_INFUT=\
	".\infblock.h"\
	".\infcodes.h"\
	".\inftrees.h"\
	".\infutil.h"\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\zip.obj" : $(SOURCE) $(DEP_CPP_INFUT) "$(INTDIR)"

SOURCE=.\my_zip.c
DEP_CPP_INFUT=\
	".\infblock.h"\
	".\infcodes.h"\
	".\inftrees.h"\
	".\infutil.h"\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\my_zip.obj" : $(SOURCE) $(DEP_CPP_INFUT) "$(INTDIR)"




SOURCE=.\printer.c
DEP_CPP_PRINT=\
	"$(TCLDIR)\generic\tcl.h"
"$(INTDIR)\printer.obj" : $(SOURCE) $(DEP_CPP_PRINT) "$(INTDIR)"


SOURCE=skating.rc
DEP_RSC_STAND=\
	"$(TKDIR)\win\rc\buttons.bmp"\
	"$(TKDIR)\win\rc\cursor00.cur"\
	"$(TKDIR)\win\rc\cursor02.cur"\
	"$(TKDIR)\win\rc\cursor04.cur"\
	"$(TKDIR)\win\rc\cursor06.cur"\
	"$(TKDIR)\win\rc\cursor08.cur"\
	"$(TKDIR)\win\rc\cursor0a.cur"\
	"$(TKDIR)\win\rc\cursor0c.cur"\
	"$(TKDIR)\win\rc\cursor0e.cur"\
	"$(TKDIR)\win\rc\cursor10.cur"\
	"$(TKDIR)\win\rc\cursor12.cur"\
	"$(TKDIR)\win\rc\cursor14.cur"\
	"$(TKDIR)\win\rc\cursor16.cur"\
	"$(TKDIR)\win\rc\cursor18.cur"\
	"$(TKDIR)\win\rc\cursor1a.cur"\
	"$(TKDIR)\win\rc\cursor1c.cur"\
	"$(TKDIR)\win\rc\cursor1e.cur"\
	"$(TKDIR)\win\rc\cursor20.cur"\
	"$(TKDIR)\win\rc\cursor22.cur"\
	"$(TKDIR)\win\rc\cursor24.cur"\
	"$(TKDIR)\win\rc\cursor26.cur"\
	"$(TKDIR)\win\rc\cursor28.cur"\
	"$(TKDIR)\win\rc\cursor2a.cur"\
	"$(TKDIR)\win\rc\cursor2c.cur"\
	"$(TKDIR)\win\rc\cursor2e.cur"\
	"$(TKDIR)\win\rc\cursor30.cur"\
	"$(TKDIR)\win\rc\cursor32.cur"\
	"$(TKDIR)\win\rc\cursor34.cur"\
	"$(TKDIR)\win\rc\cursor36.cur"\
	"$(TKDIR)\win\rc\cursor38.cur"\
	"$(TKDIR)\win\rc\cursor3a.cur"\
	"$(TKDIR)\win\rc\cursor3c.cur"\
	"$(TKDIR)\win\rc\cursor3e.cur"\
	"$(TKDIR)\win\rc\cursor42.cur"\
	"$(TKDIR)\win\rc\cursor44.cur"\
	"$(TKDIR)\win\rc\cursor46.cur"\
	"$(TKDIR)\win\rc\cursor48.cur"\
	"$(TKDIR)\win\rc\cursor4a.cur"\
	"$(TKDIR)\win\rc\cursor4c.cur"\
	"$(TKDIR)\win\rc\cursor4e.cur"\
	"$(TKDIR)\win\rc\cursor50.cur"\
	"$(TKDIR)\win\rc\cursor52.cur"\
	"$(TKDIR)\win\rc\cursor54.cur"\
	"$(TKDIR)\win\rc\cursor56.cur"\
	"$(TKDIR)\win\rc\cursor58.cur"\
	"$(TKDIR)\win\rc\cursor5a.cur"\
	"$(TKDIR)\win\rc\cursor5c.cur"\
	"$(TKDIR)\win\rc\cursor5e.cur"\
	"$(TKDIR)\win\rc\cursor60.cur"\
	"$(TKDIR)\win\rc\cursor62.cur"\
	"$(TKDIR)\win\rc\cursor64.cur"\
	"$(TKDIR)\win\rc\cursor66.cur"\
	"$(TKDIR)\win\rc\cursor68.cur"\
	"$(TKDIR)\win\rc\cursor6a.cur"\
	"$(TKDIR)\win\rc\cursor6c.cur"\
	"$(TKDIR)\win\rc\cursor6e.cur"\
	"$(TKDIR)\win\rc\cursor70.cur"\
	"$(TKDIR)\win\rc\cursor72.cur"\
	"$(TKDIR)\win\rc\cursor74.cur"\
	"$(TKDIR)\win\rc\cursor76.cur"\
	"$(TKDIR)\win\rc\cursor78.cur"\
	"$(TKDIR)\win\rc\cursor7a.cur"\
	"$(TKDIR)\win\rc\cursor7c.cur"\
	"$(TKDIR)\win\rc\cursor7e.cur"\
	"$(TKDIR)\win\rc\cursor80.cur"\
	"$(TKDIR)\win\rc\cursor82.cur"\
	"$(TKDIR)\win\rc\cursor84.cur"\
	"$(TKDIR)\win\rc\cursor86.cur"\
	"$(TKDIR)\win\rc\cursor88.cur"\
	"$(TKDIR)\win\rc\cursor8a.cur"\
	"$(TKDIR)\win\rc\cursor8c.cur"\
	"$(TKDIR)\win\rc\cursor8e.cur"\
	"$(TKDIR)\win\rc\cursor90.cur"\
	"$(TKDIR)\win\rc\cursor92.cur"\
	"$(TKDIR)\win\rc\cursor94.cur"\
	"$(TKDIR)\win\rc\cursor96.cur"\
	"$(TKDIR)\win\rc\cursor98.cur"\
	"icon.ico"\
	"icon2.ico"
"$(INTDIR)\skating.res" : $(SOURCE) $(DEP_RSC_STAND) "$(INTDIR)"
	$(RSC) /l 0x40c /fo"$(INTDIR)\skating.res" /i "$(TKDIR)\win\rc" /i "$(TKDIR)\generic" /i "$(TCLDIR)\generic" $(SOURCE)


SOURCE=.\Trees.c
DEP_CPP_TREES=\
	".\deflate.h"\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\Trees.obj" : $(SOURCE) $(DEP_CPP_TREES) "$(INTDIR)"


SOURCE=.\Uncompr.c
DEP_CPP_UNCOM=\
	".\zconf.h"\
	".\zlib.h"
"$(INTDIR)\Uncompr.obj" : $(SOURCE) $(DEP_CPP_UNCOM) "$(INTDIR)"


SOURCE=.\winMain.c
DEP_CPP_WINMA=\
	"$(TCLDIR)\generic\tcl.h"\
	"$(TKDIR)\generic\tk.h"\
	"$(TKDIR)\xlib\x11\x.h"\
	"$(TKDIR)\xlib\x11\xfuncproto.h"\
	"$(TKDIR)\xlib\x11\xlib.h"
"$(INTDIR)\winMain.obj" : $(SOURCE) $(DEP_CPP_WINMA) "$(INTDIR)"


SOURCE=.\winMain.c
DEP_CPP_WINMA=\
	"$(TCLDIR)\generic\tcl.h"\
	"$(TKDIR)\generic\tk.h"\
	"$(TKDIR)\xlib\x11\x.h"\
	"$(TKDIR)\xlib\x11\xfuncproto.h"\
	"$(TKDIR)\xlib\x11\xlib.h"
"$(INTDIR)\winMain_test.obj" : $(SOURCE) $(DEP_CPP_WINMA) "$(INTDIR)"
	$(CPP) /nologo /MT /W3 /GX /O1 /I "$(TCLDIR)\generic" /I "$(TKDIR)\generic" /I\
	"$(TKDIR)\win" /I "$(TKDIR)\xlib" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" \
	/D "STATIC_BUILD" /D "__WIN32__" /D "TEST" \
	/Fp"$(INTDIR)\skating.pch" /YX /Fd"$(INTDIR)\\" \
	/Fo"$(INTDIR)\winMain_test.obj" /c $(SOURCE)


SOURCE=.\Zutil.c
DEP_CPP_ZUTIL=\
	".\zconf.h"\
	".\zlib.h"\
	".\zutil.h"
"$(INTDIR)\Zutil.obj" : $(SOURCE) $(DEP_CPP_ZUTIL) "$(INTDIR)"
