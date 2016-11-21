/* 
 * winMain.c --
 *
 *	Main entry point for wish and other Tk-based applications.
 *
 * Copyright (c) 1995-1997 Sun Microsystems, Inc.
 * Copyright (c) 1998-1999 by Scriptics Corporation.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * RCS: @(#) $Id: winMain.c,v 1.7.6.1 1999/11/03 00:43:09 hobbs Exp $
 */

#include <tk.h>
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#undef WIN32_LEAN_AND_MEAN
#include <malloc.h>
#include <locale.h>

#include "tkInt.h"



//#define CHECK(arg) MessageBox(NULL, "Checkpoint " # arg, "3S", MB_OK|MB_ICONSTOP);
#define CHECK(arg)





int LoadPlugin_Cmd(ClientData clientData, Tcl_Interp *interp, 
				   int objc, Tcl_Obj *CONST objv[])
{
	FILE* in;
	int uncompSize, compSize, res;
	unsigned char *comp, *uncomp;


	if (objc < 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "filename");
		return TCL_ERROR;
	}

	in = fopen(Tcl_GetStringFromObj(objv[1], NULL), "rb");
	if (in == NULL) {
		Tcl_SetResult(interp, "can not open plugin", TCL_STATIC);
		return TCL_ERROR;
	}

	// read data
	fread(&compSize, 4, 1, in);
	fread(&uncompSize, 4, 1, in);
	comp = (char *) ckalloc(compSize+10);
	fread(comp, 1, compSize, in);
	fclose(in);
	// uncompress	
	uncomp = (char *) ckalloc(uncompSize+10);
	res = uncompress(uncomp, &uncompSize, comp, compSize);
	if (res != 0) {
		Tcl_SetResult(interp, "can not load plugin", TCL_STATIC);
		return TCL_ERROR;
	}
	// eval the script
	if (Tcl_Eval(interp, (char *) uncomp) != TCL_OK) {
		fprintf(stderr, "can not run the plugin\n", TCL_STATIC);
		return TCL_ERROR;
	}
	// clean-up
	ckfree(comp);
	ckfree(uncomp);

	return TCL_OK;
}



//=============================================================================

/*
 * The following declarations refer to internal Tk routines.  These
 * interfaces are available for use, but are not supported.
 */


/*
 * Forward declarations for procedures defined later in this file:
 */

static void		setargv _ANSI_ARGS_((int *argcPtr, char ***argvPtr));
static void		WishPanic _ANSI_ARGS_(TCL_VARARGS(char *,format));


/*
 *----------------------------------------------------------------------
 *
 * WinMain --
 *
 *	Main entry point from Windows.
 *
 * Results:
 *	Returns false if initialization fails, otherwise it never
 *	returns. 
 *
 * Side effects:
 *	Just about anything, since from here we call arbitrary Tcl code.
 *
 *----------------------------------------------------------------------
 */

int APIENTRY
WinMain(hInstance, hPrevInstance, lpszCmdLine, nCmdShow)
    HINSTANCE hInstance;
    HINSTANCE hPrevInstance;
    LPSTR lpszCmdLine;
    int nCmdShow;
{
    char **argv;
    int argc;

    Tcl_SetPanicProc(WishPanic);

    /*
     * Set up the default locale to be standard "C" locale so parsing
     * is performed correctly.
     */

    setlocale(LC_ALL, "C");
    setargv(&argc, &argv);

    /*
     * Increase the application queue size from default value of 8.
     * At the default value, cross application SendMessage of WM_KILLFOCUS
     * will fail because the handler will not be able to do a PostMessage!
     * This is only needed for Windows 3.x, since NT dynamically expands
     * the queue.
     */

    SetMessageQueue(64);

    /*
     * Create the console channels and install them as the standard
     * channels.  All I/O will be discarded until Tk_CreateConsoleWindow is
     * called to attach the console to a text widget.
     */


//-------------- LR ---------------------
	{
		int i;
		char buffer[MAX_PATH];
	    GetModuleFileName(NULL, buffer, sizeof(buffer));
		argv[0] = buffer;
		i = strlen(buffer)-1;
		while (i > 0 && buffer[i] != '\\')
			i--;
		buffer[i] = 0;
		Tcl_SetDefaultEncodingDir(buffer);
	}
CHECK(1)
	TclWinInit(hInstance);
    TkWinXInit(hInstance);
CHECK(2)
//-------------- LR ---------------------


    Tk_Main(argc, argv, Tcl_AppInit);
    return 1;
}


/*
 *----------------------------------------------------------------------
 *
 * Tcl_AppInit --
 *
 *	This procedure performs application-specific initialization.
 *	Most applications, especially those that incorporate additional
 *	packages, will have their own version of this procedure.
 *
 * Results:
 *	Returns a standard Tcl completion code, and leaves an error
 *	message in the interp's result if an error occurs.
 *
 * Side effects:
 *	Depends on the startup script.
 *
 *----------------------------------------------------------------------
 */


static int
EmptyCmd(clientData, interp, argc, argv)
    ClientData clientData;		/* Not used. */
    Tcl_Interp *interp;			/* Current interpreter. */
    int argc;				/* Number of arguments. */
    char **argv;			/* Argument strings. */
{
	Tcl_SetObjResult(interp, Tcl_NewIntObj(0));
	return TCL_OK;
}

EXTERN int Tk_Init(Tcl_Interp *interp);

EXTERN int Gdi_Init(Tcl_Interp *interp);
EXTERN int Gdi_SafeInit(Tcl_Interp *interp);
EXTERN int Printer_Init(Tcl_Interp *interp);
EXTERN int Printer_SafeInit(Tcl_Interp *interp);


int
Tcl_AppInit(interp)
    Tcl_Interp *interp;		/* Interpreter for application. */
{

//----------------------------------------
	Tcl_CreateCommand(interp, "console", EmptyCmd, (ClientData) NULL,
	    (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "consoleinterp", EmptyCmd, 
		(ClientData) NULL, (Tcl_CmdDeleteProc *) NULL);

	Tcl_CreateCommand(interp, "send", EmptyCmd, (ClientData) NULL,
	    (Tcl_CmdDeleteProc *) NULL);

#ifdef TEST
	if (Tcl_Init(interp) == TCL_ERROR) {
		if (Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY)) {
		    MessageBox(NULL, Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY),
						"Tcl Init Error", MB_OK|MB_ICONSTOP);
		} else {
		    MessageBox(NULL, interp->result, "Tcl Init Error",
						MB_OK|MB_ICONSTOP );
		}
		return TCL_ERROR;
    }
    if (Tk_Init(interp) == TCL_ERROR) {

		if (Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY)) {
		    MessageBox(NULL, Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY),
						"Tk Init Error", MB_OK|MB_ICONSTOP);
		} else {
		    MessageBox(NULL, interp->result, "Tk Init Error", MB_OK|MB_ICONSTOP);
		}
		return TCL_ERROR;
    }
#else
	Tcl_SetVar(interp, "tcl_library", ".", TCL_GLOBAL_ONLY);
	Tcl_SetVar(interp, "tk_library", "", TCL_GLOBAL_ONLY);

    Tk_Init(interp); // will return errors
#endif
    Tcl_StaticPackage(interp, "Tk", Tk_Init, (Tcl_PackageInitProc *) NULL);


	if (Zip_Init(interp) == TCL_ERROR) {
		return TCL_ERROR;
	}
CHECK(3)

    if (Gdi_Init(interp) == TCL_ERROR) {
		if (Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY)) {
		    MessageBox(NULL, Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY),
						"Tcl Eval Error", MB_OK|MB_ICONSTOP);
		} else {
		    MessageBox(NULL, interp->result, "Tcl Eval Error", MB_OK|MB_ICONSTOP);
		}
		exit(1);
    }
    Tcl_StaticPackage(interp, "Gdi", Gdi_Init, Gdi_SafeInit);
	if (Printer_Init(interp) == TCL_ERROR) {
		if (Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY)) {
		    MessageBox(NULL, Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY),
						"Tcl Eval Error", MB_OK|MB_ICONSTOP);
		} else {
		    MessageBox(NULL, interp->result, "Tcl Eval Error", MB_OK|MB_ICONSTOP);
		}
		exit(1);
    }
    Tcl_StaticPackage(interp, "Printer", Printer_Init, Printer_SafeInit);

	// LR extension via plugin
	Tcl_CreateObjCommand(interp, "load_plugin", LoadPlugin_Cmd,
						 (ClientData) NULL, (Tcl_CmdDeleteProc *) NULL);
#ifdef TEST
	if (Tk_CreateConsoleWindow(interp) == TCL_ERROR) {
		if (Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY)) {
		    MessageBox(NULL, Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY),
						"Console Init Error", MB_OK|MB_ICONSTOP);
		} else {
		    MessageBox(NULL, interp->result, "Console Init Error", MB_OK|MB_ICONSTOP);
		}
		return TCL_ERROR;
	}
#else
	// include the script (source of tcl + pixmap = self-contained)
	{
	extern unsigned int scriptSize;
	extern unsigned int scriptCompressedSize;
	extern unsigned char script[];
	unsigned char *tmp = malloc(scriptSize+10);
	unsigned int uncompressed = scriptSize+5;
	if (uncompress(tmp, &uncompressed, script, scriptCompressedSize) != 0) {
		MessageBox(NULL, "Error in decompression.",
						"Tcl Decompression", MB_OK|MB_ICONSTOP);
		exit(1);
	}
	if (uncompressed != scriptSize) {
		MessageBox(NULL, "Bad decompressed size !",
						"Tcl Decompression", MB_OK|MB_ICONSTOP);
		exit(1);
	}
CHECK(4)
	// eval the library of scripts
	if (Tcl_Eval(interp, (char *) tmp) != TCL_OK) {
		if (Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY)) {
		    MessageBox(NULL, Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY),
						"Tcl Eval Error", MB_OK|MB_ICONSTOP);
		} else {
		    MessageBox(NULL, interp->result, "Tcl Eval Error", MB_OK|MB_ICONSTOP);
		}
		exit(1);
	}
	// check for auto-load of file (extension association)
	tmp =  "catch { if {$argc} { \
						skating::gui:load [lindex $argv 0] \
					} else { \
						if {$skating::gui(pref:showNewDlgAtStartup)} { \
							update ; after 100 ; skating::gui:newQuick:dialog \
						} \
					} \
			}";
	Tcl_Eval(interp, (char *) tmp);
CHECK(99)
	// clean-up
	free(tmp);
	}
#endif
//----------------------------------------

    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * WishPanic --
 *
 *	Display a message and exit.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Exits the program.
 *
 *----------------------------------------------------------------------
 */

void
WishPanic TCL_VARARGS_DEF(char *,arg1)
{
    va_list argList;
    char buf[1024];
    char *format;
    
    format = TCL_VARARGS_START(char *,arg1,argList);
    vsprintf(buf, format, argList);

    MessageBeep(MB_ICONEXCLAMATION);
    MessageBox(NULL, buf, "Fatal Error in Wish",
	    MB_ICONSTOP | MB_OK | MB_TASKMODAL | MB_SETFOREGROUND);
#ifdef _MSC_VER
    DebugBreak();
#endif
    ExitProcess(1);
}

/*
 *-------------------------------------------------------------------------
 *
 * setargv --
 *
 *	Parse the Windows command line string into argc/argv.  Done here
 *	because we don't trust the builtin argument parser in crt0.  
 *	Windows applications are responsible for breaking their command
 *	line into arguments.
 *
 *	2N backslashes + quote -> N backslashes + begin quoted string
 *	2N + 1 backslashes + quote -> literal
 *	N backslashes + non-quote -> literal
 *	quote + quote in a quoted string -> single quote
 *	quote + quote not in quoted string -> empty string
 *	quote -> begin quoted string
 *
 * Results:
 *	Fills argcPtr with the number of arguments and argvPtr with the
 *	array of arguments.
 *
 * Side effects:
 *	Memory allocated.
 *
 *--------------------------------------------------------------------------
 */

static void
setargv(argcPtr, argvPtr)
    int *argcPtr;		/* Filled with number of argument strings. */
    char ***argvPtr;		/* Filled with argument strings (malloc'd). */
{
    char *cmdLine, *p, *arg, *argSpace;
    char **argv;
    int argc, size, inquote, copy, slashes;
    
    cmdLine = GetCommandLine();	/* INTL: BUG */

    /*
     * Precompute an overly pessimistic guess at the number of arguments
     * in the command line by counting non-space spans.
     */

    size = 1+2;
    for (p = cmdLine; *p != '\0'; p++) {
	if ((*p == ' ') || (*p == '\t')) {	/* INTL: ISO space. */
	    size++;
	    while ((*p == ' ') || (*p == '\t')) { /* INTL: ISO space. */
		p++;
	    }
	    if (*p == '\0') {
		break;
	    }
	}
    }
    argSpace = (char *) Tcl_Alloc(
	    (unsigned) (size * sizeof(char *) + strlen(cmdLine) + 1));
    argv = (char **) argSpace;
    argSpace += size * sizeof(char *);
    size--;

    p = cmdLine;
    for (argc = 0; argc < size; argc++) {
//---- LR 10/06/2001 : for extension association, insert a -- to get the filename in $argv
#ifndef TEST
	if (argc == 1) {
	    argv[argc] = "--";
	    continue;
	}
#endif
//---- LR 10/06/2001
	argv[argc] = arg = argSpace;
	while ((*p == ' ') || (*p == '\t')) {	/* INTL: ISO space. */
	    p++;
	}
	if (*p == '\0') {
	    break;
	}

	inquote = 0;
	slashes = 0;
	while (1) {
	    copy = 1;
	    while (*p == '\\') {
		slashes++;
		p++;
	    }
	    if (*p == '"') {
		if ((slashes & 1) == 0) {
		    copy = 0;
		    if ((inquote) && (p[1] == '"')) {
			p++;
			copy = 1;
		    } else {
			inquote = !inquote;
		    }
                }
                slashes >>= 1;
            }

            while (slashes) {
		*arg = '\\';
		arg++;
		slashes--;
	    }

	    if ((*p == '\0')
		    || (!inquote && ((*p == ' ') || (*p == '\t')))) { /* INTL: ISO space. */
		break;
	    }
	    if (copy != 0) {
		*arg = *p;
		arg++;
	    }
	    p++;
        }
	*arg = '\0';
	argSpace = arg + 1;
    }
    argv[argc] = NULL;

    *argcPtr = argc;
    *argvPtr = argv;
}

/*
 *----------------------------------------------------------------------
 *
 * main --
 *
 *	Main entry point from the console.
 *
 * Results:
 *	None: Tk_Main never returns here, so this procedure never
 *      returns either.
 *
 * Side effects:
 *	Whatever the applications does.
 *
 *----------------------------------------------------------------------
 */

int main(int argc, char **argv)
{
    Tcl_SetPanicProc(WishPanic);

    /*
     * Set up the default locale to be standard "C" locale so parsing
     * is performed correctly.
     */

    setlocale(LC_ALL, "C");
    /*
     * Increase the application queue size from default value of 8.
     * At the default value, cross application SendMessage of WM_KILLFOCUS
     * will fail because the handler will not be able to do a PostMessage!
     * This is only needed for Windows 3.x, since NT dynamically expands
     * the queue.
     */

    SetMessageQueue(64);

    /*
     * Create the console channels and install them as the standard
     * channels.  All I/O will be discarded until Tk_CreateConsoleWindow is
     * called to attach the console to a text widget.
     */

    Tk_Main(argc, argv, Tcl_AppInit);
    return 0;
}

