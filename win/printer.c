/*
**
** Tcl Extension for Windows
** RCS Version $Revision: 1.17 $
** RCS Last Change Date: $Date: 1999/03/12 06:34:15 $
** Original Author: Michael I. Schwartz, mschwart@nyx.net
** Incorporates code and ideas from:
**  Mark Roseman: Dialogs, Mac code, breakout of open, job, and page commands
**  Andreas Sievers (Andreas.Sievers@t-mobil.de): Fixes for ISO paper calculations
** 
** {LICENSE}
** 
** THE AUTHORS HEREBY GRANT PERMISSION TO USE, COPY, MODIFY, DISTRIBUTE,
** AND LICENSE THIS SOFTWARE AND ITS DOCUMENTATION FOR ANY PURPOSE, PROVIDED
** THAT EXISTING COPYRIGHT NOTICES ARE RETAINED IN ALL COPIES AND THAT THIS
** NOTICE IS INCLUDED VERBATIM IN ANY DISTRIBUTIONS. 
**
** NO WRITTEN AGREEMENT, LICENSE, OR ROYALTY FEE IS REQUIRED FOR ANY OF THE
** AUTHORIZED USES.
** 
** MODIFICATIONS TO THIS SOFTWARE MAY BE COPYRIGHTED BY THEIR AUTHORS
** AND NEED NOT FOLLOW THE LICENSING TERMS DESCRIBED HERE, PROVIDED THAT
** THE NEW TERMS ARE CLEARLY INDICATED ON THE FIRST PAGE OF EACH FILE WHERE
** THEY APPLY.
** 
** IN NO EVENT SHALL THE AUTHOR BE LIABLE TO ANY PARTY FOR DIRECT,
** INDIRECT, SPECIAL, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING OUT OF
** THE USE OF THIS SOFTWARE, ITS DOCUMENTATION,  OR ANY DERIVATIVES
** THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF
** SUCH DAMAGE.
** 
** THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
** INCLUDING, BUT NOT LIMITED TO,  THE IMPLIED WARRANTIES OF
** MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. 
** THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND
** DISTRIBUTORS HAVE NO OBLIGATION  TO PROVIDE MAINTENANCE, SUPPORT,
** UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
** 
** {SYNOPSIS}
** 
** This file contains commands to extend TK for Windows 3.11, Windows 95,
** and Windows NT 4.0 features
** 
** The commands are:
** 
** printer
**  printer attr
**  printer close
**  printer dialog [select|page_setup] [-flags flagsnum]
**  printer job [start|end]
**  printer list [-match matchstring]
**  printer open
**  printer page [start|end]
**  printer send [-postscript|-nopostscript] 
**               [-hDC hdc] [-printer pname] [-file|-data] file_or_data ...
**  printer version
** 
** The details of each command's options follow:
** 
** {PRINTER}
**
**  
**  printer attr
**   DESCRIPTION:
**    Returns a set of attribute/value pairs
**   LIMITATIONS:
**    These are intended to have differences on each implementation
**    No functions for setting attributes are yet provided
**  
**  printer close
**   DESCRIPTION:
**    Returns nothing if successful
**    Printer is closed and DC is released, concluding any jobs pending
**   LIMITATIONS:
**    None known
**  
**  printer dialog [select|page_setup] [-flags flagnum]
**   DESCRIPTION:
**    Invokes a platform specific printer selection, printer setup,  or 
**    printer page setup dialog with any provided flags (platform specific)
**    The select dialog returns a platform specific long integer handle to 
**    the selected printer.
**    The page_setup dialog returns nothing at this time.
**    Values remain accessible through the attributes (or are intended to be)
**   LIMITATIONS:
**  
**  printer job [start|end]
**   DESCRIPTION:
**    printer job returns information about the pending job, if any.
**    printer job start initiates a new document spooled for printing
**    printer job end   lets the spooler process the job
**   LIMITATIONS:
**  
**  printer list [-match matchstring]
**   DESCRIPTION:
**     Returns a list of all locally-known printers
**     The matchstring uses the "string match" style syntax
**     The return value is in 3 parts, separated by commas, as required by the 
**       -printer option in printer send
**   LIMITATIONS:
**  
**  printer open
**   DESCRIPTION:
**    Returns long integer representing handle to selected printer
**    Opens default printer and stores DC in printer_values structure.
**   LIMITATIONS:
**    Doesn't process command options yet to pre-populate appropriate fields
**    (e.g., printer name)
**  
**  printer page [start|end]
**   DESCRIPTION:
**    Start or end a page
**   LIMITATIONS:
**  
** printer version
**  DESCRIPTION:
**    Returns the version of this package
** 
** printer send [-hdc hdc] [-postscript|-nopostscript] 
**                      [-printer pname] [-file|-data] file_or_data ...
**  DESCRIPTION:
**    Used to send a file to the printer in "raw" format
**  OPTIONS
**    -postscript
**       Input file is an ASCII text file for newline/special character handling.
**       This is the default
**    -nopostscript
**       Input file is a binary file (no special character handling).
**       This is NOT the default.
**    -hDC hdc
**       Use the given HDC as the printer DC.
**       This overrides the -printer switch.
**    -printer pname
**       Set the output printer to pname (in "windows" format)
**       If the printer selection dialog has been invoked, the printer
**       selected by the dialog is the default.
**       If not, and there is a previously used printer, use it.
**       If not, the current default printer is the default.
**    -file
**       The arguments following are filenames to send to the printer
**       This is the default.
**    -data
**       The arguments following are data to be sent to the printer.
**       In general, only one argument should follow this option.
** 
**  LIMITATIONS:
**    Despite the documentation on EPS, the MSWindows preamble does get sent to a 
**    Postscript printer, and thus a blank page is emitted at the end of each job.
**    The -nopostscript option opens the input file in binary mode.
**    No whitespace is output between arguments following the -data option. This means
**    normally you will want to send only one argument with -data.
** 
**
** RCS Change summaries:
**     $Log: printer.c $
** Revision 1.17  1999/03/12  06:34:15  Michael_Schwartz
** Removed all dependencies on WIN32S #define. Instead, use a runtime
** check. This way, only one version of the extension need exist.
** Also, fixed enumprinter to be useful under win95.
** Also, added network printers for win95 and winnt.
** Fixed a memory leak in printer list
**
** Revision 1.17  1998/12/21  04:56:02  Michael_Schwartz
** Added flag handling for the page setup dialog.
** Added event loop handling for "printer job start", which also has
** a possible popup dialog when "print to file" is selected.
** Checked all handles before GlobalFree. While this does not cause a
** problem under NT, it appears to cause problems under Win95 and
** presumably 98. The symptom for this is a crash of Wish on the second
** or subsequent print (depending on the exact order of operations).
**
** Revision 1.16  1998/12/17  07:54:57  Michael_Schwartz
** Added notifier loop calls to allow Tcl/Tk to repaint and do other idle
** tasks while the dialog is up.
**
** Revision 1.15  1998/12/09  06:31:30  Michael_Schwartz
** Added fixes for ISO standard paper size conversion per bug report
** by Andreas Sievers <Andreas.Sievers@t-mobil.de>.
** Changed call to get parent HWND in hopes of getting the proper window
** to cause refresh when a standard dialog is up (it didn't work). Still
** need to find the right wrapper window.
** Added handling for -name argument to printer job.
**
** Revision 1.14  1998/09/29  03:23:41  Michael_Schwartz
** *** empty log message ***
**
** Revision 1.13  1998/04/27  01:38:03  Michael_Schwartz
** Cleaned up the open routine and the send routine to handle
** coordination of the page setup dialog and the select dialog
**
**
** Revision 1.11  1997/11/27  15:30:44  Michael_Schwartz
** Add -hDC flag to printer send
** Add "job" logic so a job can be started when needed
**
** Revision 1.10  1997/10/27  03:28:01  Michael_Schwartz
** Moved allocation logic to the right place, added an option to the print
** dialogs, and made code acceptable for 4.1, 4.2, and 8.0 Tcl.
**
** Revision 1.9  1997/10/26  18:15:13  Michael_Schwartz
** Cleaned up global resources better
** Allowed flags in printer selection dialog
** Added more attributes to printer attr--it will need the match soon!
**
** Revision 1.8  97/09/28  13:12:01  ROOT_DOS
** Recovery from disk failure
** 
** Revision 1.7  1997/09/25  07:07:31  Michael_Schwartz
** *** empty log message ***
**
** Revision 1.6  1997/09/02  02:38:42  Michael_Schwartz
** Added in Macintosh code. NB***UNTESTED***
** Added all commands to the printer main dispatcher.
** Made printer send compatible with DCs built by other printer functions
**
** Revision 1.5  1997/09/01  20:09:17  Michael_Schwartz
** Removed code warnings by putting into a few casts.
**
** Revision 1.4  1997/09/01  18:55:48  Michael_Schwartz
** Code rearrangement to make room for MAC and Unix implementations.
** Revision 1.3  1997/09/01  18:53:46  Michael_Schwartz
** Added dialog options; returned HDC; changed code organization slightly
** Revision 1.2  1997/09/01  07:39:42  Michael_Schwartz
** Added several functions from Mark Roseman's mail.
** Removed a couple warnings for compile.
** Switched all status and reporting to Tcl_SetResult or Tcl_AppendResult, and
** not using interp->result directly anymore.
** Revision 1.1  1997/09/01  03:38:18  Michael_Schwartz
** Initial revision
*/

/****************************************************************
** This section contains windows-specific includes and structures
** global to the file.
** Windows-specific functions will be found in a section at the
** end of the file
****************************************************************/
#if defined(__WIN32__) || defined (__WIN32S__) || defined (WIN32)
  #include <windows.h>
  #include <commdlg.h>

  /* This value structure is intended for ClientData in all Print functions */
  static struct printer_values
  {
    HDC hDC;            /* Default printer context--override via args? */
    PRINTDLG pdlg;      /* Printer dialog and associated values */
    PAGESETUPDLG pgdlg; /* Printer setup dialog and associated values */
	DEVMODE *devPortrait;
	DEVMODE *devLandscape;
  } default_printer_values;

  static HDC GetPrinterDC (char *printer);
  static int SplitDevice(LPSTR device, LPSTR *dev, LPSTR *dvr, LPSTR *port);

  /*
   * VC++ has an alternate entry point called DllMain, so we need to rename
   * our entry point.
   */
  # ifndef STATIC_BUILD
  #   if defined(_MSC_VER)
  #     define EXPORT(a,b) __declspec(dllexport) a b
  #     define DllEntryPoint DllMain
  #   else
  #     if defined(__BORLANDC__)
  #         define EXPORT(a,b) a _export b
  #     else
  #         define EXPORT(a,b) a b
  #     endif
  #   endif
  # endif
#else
  #   define EXPORT(a,b) a b
#endif

#define EXPORT(a,b) a b


#include <tcl.h>
#include <string.h>
#include <stdlib.h>

/* New macros for tcl8.0.3 and later */
#if defined(TCL_STORAGE_CLASS)
#  undef TCL_STORAGE_CLASS
#endif
#define TCL_STORAGE_CLASS DLLEXPORT
#if ! defined(EXTERN)
#  define EXTERN
#endif

#if TCL_MAJOR_VERSION == 7 && TCL_MINOR_VERSION <= 5
/* In this case, must replace Tcl_Alloc(), Tcl_Realloc(), and Tcl_Free()
** with ckalloc(), ckrealloc(), and ckfree()
*/

#define Tcl_Alloc(x)  ckalloc(x)
#define Tcl_Free(x)   ckfree(x)
#define Tcl_Realloc(x,y)  ckrealloc(x,y)

#endif

/****************************************************************
** External function prototypes
****************************************************************/
EXTERN EXPORT(int,Printer_Init) (Tcl_Interp *interp);
EXTERN EXPORT(int,Printer_SafeInit) (Tcl_Interp *interp);

/****************************************************************
** Internal function prototypes
****************************************************************/
static int Print (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int PrintList (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int PrintCommand (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int PrintFile (HDC hdc, Tcl_Interp *interp, const char *filename, int postscript);
static int PrintData (HDC hdc, Tcl_Interp *interp, const char *data, int postscript);
static int PrintStart (HDC hdc, Tcl_Interp *interp, const char *docname);
static int PrintFinish (HDC hdc);
static int Version(Tcl_Interp *interp);
static long WinVersion(void);

/* New functions from Mark Roseman */
static int PrintOpen(ClientData data, Tcl_Interp *interp, int argc, char **argv);
static int PrintClose(ClientData data, Tcl_Interp *interp, int argc, char **argv);
static int PrintDialog(ClientData data, Tcl_Interp *interp, int argc, char **argv);
static int PrintJob(ClientData data, Tcl_Interp *interp, int argc, char **argv);
static int PrintPage(ClientData data, Tcl_Interp *interp, int argc, char **argv);
static int PrintAttr(ClientData data, Tcl_Interp *interp, int argc, char **argv);
static int JobInfo(int state, const char *name, const char **outname);
/* End new functions */

static int PrintPageSize(ClientData data, Tcl_Interp *interp, int argc, char **argv);


// DMORIENT_LANDSCAPE  or  DMORIENT_PORTRAIT
static LPDEVMODE PrintGetOrientedDevMode(HWND hWnd, char *pDevice, int orientation);


/****************************************************************
** Internal static data structures (ClientData)
****************************************************************/
static char msgbuf[255+1];
static char usage_message[] = "printer [close|dialog|job|list|open|send|version]";
static struct {
  char *tmpname;
} option_defaults =
{
  0
};


/****************************************************************
** Try the following syntax:
** printer version
** printer list [-match matchstring]
** printer send [-postscript|-nopostscript] 
**                      [-printer pname] [-file|-data] file_or_data ...
**   Defaults are postscript, default printer, files
****************************************************************/


/****************************************************************
** WinVersion returns an integer representing the current version
** of windows.
****************************************************************/
static long WinVersion(void)
{
    static OSVERSIONINFO osinfo;
    if ( osinfo.dwOSVersionInfoSize == 0 )
    {
      osinfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
      GetVersionEx(&osinfo); /* Should never fail--only failure is if size too small */
    }
    return osinfo.dwPlatformId;
}

/****************************************************************
** PrintCommand takes the print command, parses it, and calls
** PrintFile as appropriate.
** This routine is independent of OS.
****************************************************************/
static int Print (ClientData defaults, Tcl_Interp *interp, int argc, char **argv)
{

  if ( argc == 0 )
  {
    Tcl_SetResult(interp, usage_message, TCL_STATIC);
    return TCL_ERROR;
  }

  /* Get rid of the "printer" argument */

  if ( strcmp(argv[0], "list") == 0 )
    return PrintList(defaults, interp, argc-1, argv+1);
  else if ( strcmp(argv[0], "send") == 0 )
    return PrintCommand(defaults, interp, argc-1, argv+1);
  else if ( strcmp(argv[0], "open") == 0 )
    return PrintOpen(defaults, interp, argc-1, argv+1);
  else if ( strcmp(argv[0], "close") == 0 )
    return PrintClose(defaults, interp, argc-1, argv+1);
  else if ( strcmp(argv[0], "dialog") == 0)
    return PrintDialog(defaults, interp, argc-1, argv+1);
  else if ( strcmp(argv[0], "job") == 0)
    return PrintJob(defaults, interp, argc-1, argv+1);
  else if ( strcmp(argv[0], "page") == 0 )
    return PrintPage(defaults, interp, argc-1, argv+1);
  else if ( strcmp(argv[0], "attr") == 0 )
    return PrintAttr(defaults, interp, argc-1, argv+1);
  else if ( strcmp(argv[0], "version") == 0 )
    return Version(interp);
  
  Tcl_SetResult(interp, usage_message, TCL_STATIC);
  return TCL_ERROR;  
}


/****************************************************************
** printer
** This is the "unsafe" version which supports the full range
** of possibilities.
** Could benefit by an execution table rather than a switch.
****************************************************************/
static int printer (ClientData data, Tcl_Interp *interp, int argc, char **argv)
{
  if ( argc > 1 )
  {
    argv++;
    argc--;
    return Print(data, interp, argc, argv);
  }

  Tcl_SetResult(interp , usage_message, TCL_STATIC);
  return TCL_ERROR;
}

/****************************************************************
** This is the "safe" version of printer
****************************************************************/
static int printer_safe (ClientData data, Tcl_Interp *interp, int argc, char **argv)
{
  return printer(data, interp, argc, argv);
}

/****************************************************************
** This is the version information/command
** The static data should also be used by pkg_provide, etc.
****************************************************************/
/* Version information */
static char version_string[] = "0.7.2.1";

/* Version command */
static int Version(Tcl_Interp *interp)
{
  Tcl_SetResult(interp, version_string, TCL_STATIC);
  return TCL_OK;
}

/****************************************************************
** Initialization procedures
** These are the only public procedures in the file.
** These are OS independent
****************************************************************/
/* Initialization Procedures */
EXTERN EXPORT(int,Printer_Init) (Tcl_Interp *interp)
{
#if TCL_MAJOR_VERSION <= 7
  Tcl_CreateCommand(interp, "printer", printer, 
                    (ClientData)(&default_printer_values), 0);
#else
  /* Wanted to Use namespaces, but "unknown" isn't smart enough yet */
  Tcl_CreateCommand (interp, "printer", printer,
                    (ClientData)(&default_printer_values), 0);
#endif

  Tcl_PkgProvide (interp, "printer", version_string);

  return TCL_OK;
}

/* The printer function is considered safe. */
EXTERN EXPORT (int,Printer_SafeInit) (Tcl_Interp *interp)
{
  return Printer_Init(interp);
}


/* A macro for converting 10ths of millimeters to 1000ths of inches */
#define MM_TO_MINCH(x) ( (x) / 0.0254 )
#define TENTH_MM_TO_MINCH(x) ( (x) / 0.254 )


/****************************************************************
** Support for getting error messages out of windows error codes
****************************************************************/
static struct ErrorMap
{
  long errnum;
  char *msg;
} WinErrorMap[] =
{
  { 0,                            "\"Unexpected error code\"" },
  { ERROR_FILE_NOT_FOUND,         "\"Requested value or subkeys of nonexistent key\"" },
  { ERROR_ACCESS_DENIED,          "\"Cannot delete registry key in NT with subkeys\"" },
  { ERROR_BADDB,                  "\"Registry database is corrupt\"" },
  { ERROR_BADKEY,                 "\"Configuration registry key is invalid\"" },
  { ERROR_CANTOPEN,               "\"Can't open registry key\"" },
  { ERROR_CANTREAD,               "\"Can't read registry key\"" },
  { ERROR_CANTWRITE,              "\"Can't write registry key\"" },
  { ERROR_REGISTRY_RECOVERED,     "\"Successfully recovered a corrupt registry file\"" },
  { ERROR_REGISTRY_CORRUPT,       "\"Registry database is corrupt and unrecoverable\"" },
  { ERROR_REGISTRY_IO_FAILED,     "\"Registry I/O operattion failed\"" },
  { ERROR_NOT_REGISTRY_FILE,      "\"Registry attempted to load non-registry file\"" },
  { ERROR_KEY_DELETED,            "\"Operation cannot be completed on registry key marked for deletion\""},
  { ERROR_NO_LOG_SPACE,           "\"Could not allocate required space in Registry log\""},
  { ERROR_KEY_HAS_CHILDREN,       "\"Cannot create symbolic link in registry key with subkeys or values\"" },
  { ERROR_CHILD_MUST_BE_VOLATILE, "\"Cannot create stable subkey under volatile parent key\"" },
};

static int FormatWinError(long code, char *buffer, int maxsize)
{
  int i;
  char numbuf[13]; /* long enough for the biggest long number */
  int len;

  sprintf(numbuf, "%ld ", code);
  len = strlen(numbuf);
  if (maxsize <= len)
  {
    return -1;
  }
  strcpy(buffer, numbuf);
  buffer += len;
  maxsize -= len;
  
  for (i=1; i< sizeof(WinErrorMap) / sizeof(struct ErrorMap); i++)
  {
    if ( code == WinErrorMap[i].errnum )
    {
      strncpy(buffer, WinErrorMap[i].msg, maxsize);
      buffer[maxsize - 1] = '\0';
      return 0;
    }
  }
  strncpy (buffer, WinErrorMap[0].msg, maxsize);
  buffer[maxsize - 1] = '\0';
  return 1;
}

/****************************************************************
** Divide the default printing device into its component parts
****************************************************************/
static int SplitDevice(LPSTR device, LPSTR *dev, LPSTR *dvr, LPSTR *port)
{
  static char buffer[256];
  if (device == 0 )
  {
    switch ( WinVersion() )
    {
      case VER_PLATFORM_WIN32s:
        GetProfileString("windows", "device", "", (LPSTR)buffer, sizeof buffer);
        device = (LPSTR)buffer;
        break;
      case VER_PLATFORM_WIN32_WINDOWS:
      case VER_PLATFORM_WIN32_NT:
      default:
        device = (LPSTR)"WINSPOOL,Postscript,";
        break;
    }
  }
  
  *dev = strtok(device, ",");
  *dvr = strtok(NULL, ",");
  *port = strtok(NULL, ",");

  if (*dev)
    while ( **dev == ' ')
      (*dev)++;
  if (*dvr)
    while ( **dvr == ' ')
      (*dvr)++;
  if (*port)
    while ( **port == ' ')
      (*port)++;
      
  return 1;
}

/****************************************************************
** Build a compatible printer DC for the default printer. (WfW)
****************************************************************/
static HDC GetPrinterDC (char *printer)
{
  HDC hdcPrint;

  LPSTR lpPrintDevice = "";
  LPSTR lpPrintDriver = "";
  LPSTR lpPrintPort   = "";

  SplitDevice (printer, &lpPrintDevice, &lpPrintDriver, &lpPrintPort);
  switch ( WinVersion() )
  {
    case VER_PLATFORM_WIN32s:
      hdcPrint = CreateDC (lpPrintDriver,
                           lpPrintDevice,
		           lpPrintPort,
		           NULL);
      break;
    case VER_PLATFORM_WIN32_WINDOWS:
    case VER_PLATFORM_WIN32_NT:
    default:
      hdcPrint = CreateDC (lpPrintDriver, 
                           lpPrintDevice, 
		           NULL, 
		           NULL);
      break;
  }

  return hdcPrint;
}

/*****************************************************************/
/* End of support for file printing */
/*****************************************************************/

/****************************************************************
** PrintList will return the list of available printers in
** a format convenient for the print command.
****************************************************************/
static int PrintList (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  char *usgmsg = "printer list [-match matchstring]";
  char *match = 0;
  char *illegal = 0;

  /* The following 3 declarations are only needed for the Win32s case */
  static char devices_buffer[256];
  static char value[256];
  char *cp;

  int i;

  for (i=0; i<argc; i++)
  {
    if (strcmp(argv[i], "-match") == 0)
      match = argv[++i];
    else
      illegal = argv[i];
  }

  if (illegal)
  {
    Tcl_SetResult(interp, usgmsg, TCL_STATIC);
    return TCL_ERROR;
  }

  /* The result should be useful for specifying the devices and/or OpenPrinter and/or lp -d */
  /* Rather than make this compilation-dependent, do a runtime check */
  switch ( WinVersion() )
  {
    case VER_PLATFORM_WIN32s: /* Windows 3.1 */
      /* Getting the printer list isn't hard... the trick is which is right for WfW?
      ** [PrinterPorts] or [devices]?
      ** For now, use devices.
      */
      /* First, get the entries in the section */
      GetProfileString("devices", 0, "", (LPSTR)devices_buffer, sizeof devices_buffer);

      /* Next get the values for each entry; construct each as a list of 3 elements */
      for (cp = devices_buffer; *cp ; cp+=strlen(cp) + 1)
      {
        GetProfileString("devices", cp, "", (LPSTR)value, sizeof value);
        if (match == 0 || Tcl_StringMatch(cp, match) || Tcl_StringMatch(value, match) )
          Tcl_AppendResult(interp, "{", cp, "," , value,  "} ", 0);
      }
      break;
    case VER_PLATFORM_WIN32_WINDOWS:  /* Windows 95, 98 */
    default:
      /* Win32 implementation uses EnumPrinters */
      /* There is a hint in the documentation that this info is stored in the registry.
      ** if so, that interface would probably be even better!
      */
      {
        DWORD bufsiz = 0;
        DWORD needed = 0;
        DWORD num_printers = 0;
        PRINTER_INFO_5 *ary = 0;
        DWORD i;
  
        if ( EnumPrinters(PRINTER_ENUM_LOCAL, NULL, 
                          5, (LPBYTE)ary, 
                          bufsiz, &needed, 
                          &num_printers) == FALSE )
        {
          /* Expected failure--we didn't allocate space */
          DWORD err = GetLastError();
          /* If the error isn't insufficient space, we have a real problem. */
          if ( err != ERROR_INSUFFICIENT_BUFFER )
          {
            sprintf (msgbuf, "EnumPrinters: unexpected error code: %ld", err);
            Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
            return TCL_ERROR;
          }
        }

        if ( needed && (ary = (PRINTER_INFO_5 *)Tcl_Alloc(needed) ) != 0 )
          bufsiz = needed;

        if ( EnumPrinters(PRINTER_ENUM_LOCAL, NULL, 
                          5, (LPBYTE)ary, 
                          bufsiz, &needed, 
                          &num_printers) == FALSE )
        {
          /* Now we have a real failure! */
          sprintf(msgbuf, "printer list: Cannot enumerate printers: %ld", GetLastError());
          Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
          return TCL_ERROR;
        }

        /* Question for Win95: Do I need to provide the port number? */
        for (i=0; i<num_printers; i++)
          if (match == 0 || Tcl_StringMatch(ary[i].pPrinterName, match) ||
                            Tcl_StringMatch(ary[i].pPortName,    match) )
            Tcl_AppendElement(interp, ary[i].pPrinterName);
      }
      break;
    case VER_PLATFORM_WIN32_NT:       /* Windows NT */
      /* Win32 implementation uses EnumPrinters */
      /* There is a hint in the documentation that this info is stored in the registry.
      ** if so, that interface would probably be even better!
      ** Note: The PRINTER_INFO_4 is fine, but we need both local AND remote printers.
      */
      {
        DWORD bufsiz = 0;
        DWORD needed = 0;
        DWORD num_printers = 0;
        PRINTER_INFO_4 *ary = 0;
        DWORD i;
  
        if ( EnumPrinters(PRINTER_ENUM_LOCAL, NULL, 
                          4, (LPBYTE)ary, 
                          bufsiz, &needed, 
                          &num_printers) == FALSE )
        {
          /* Expected failure--we didn't allocate space */
          DWORD err = GetLastError();
          /* If the error isn't insufficient space, we have a real problem. */
          if ( err != ERROR_INSUFFICIENT_BUFFER )
          {
            sprintf (msgbuf, "EnumPrinters: unexpected error code: %ld", err);
            Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
            return TCL_ERROR;
          }
        }

        if ( needed && (ary = (PRINTER_INFO_4 *)Tcl_Alloc(needed) ) != 0 )
        {
          bufsiz = needed;
          if ( EnumPrinters(PRINTER_ENUM_LOCAL, NULL, 
                            4, (LPBYTE)ary, 
                            bufsiz, &needed, 
                            &num_printers) == FALSE )
          {
            /* Now we have a real failure! */
            sprintf(msgbuf, "printer list: Cannot enumerate local printers: %ld", GetLastError());
            Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
            Tcl_Free((char *)ary);
            return TCL_ERROR;
          }
    
          for (i=0; i<num_printers; i++)
            if (match == 0 || Tcl_StringMatch(ary[i].pPrinterName, match) )
              Tcl_AppendElement(interp, ary[i].pPrinterName);
        }
  
        if ( bufsiz )
          Tcl_Free((char *)ary);
        ary    = 0;

        /* Now, the same treatement for the Network Printers. */
        bufsiz = 0;
        needed = 0;
        num_printers = 0;
        if ( EnumPrinters(PRINTER_ENUM_NETWORK, NULL, 
                          4, (LPBYTE)ary, 
                          bufsiz, &needed, 
                          &num_printers) == FALSE )
        {
          /* Expected failure--we didn't allocate space */
          DWORD err = GetLastError();
          /* If the error isn't insufficient space, we have a real problem. */
          if ( err != ERROR_INSUFFICIENT_BUFFER )
          {
            sprintf (msgbuf, "EnumPrinters: unexpected error code: %ld", err);
            Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
            return TCL_ERROR;
          }
        }
        if ( needed && (ary = (PRINTER_INFO_4 *)Tcl_Alloc(needed) ) != 0 )
        {
          bufsiz = needed;

          if ( EnumPrinters(PRINTER_ENUM_NETWORK, NULL, 
                            4, (LPBYTE)ary, 
                            bufsiz, &needed, 
                            &num_printers) == FALSE )
          {
            /* Now we have a real failure! */
            sprintf(msgbuf, "printer list: Cannot enumerate remote printers: %ld", GetLastError());
            Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
            Tcl_Free((char *)ary);
            return TCL_ERROR;
          }
    
          for (i=0; i<num_printers; i++)
            if (match == 0 || Tcl_StringMatch(ary[i].pPrinterName, match) )
              Tcl_AppendElement(interp, ary[i].pPrinterName);
        }
        if (bufsiz)
          Tcl_Free((char *)ary);
        ary = 0;
      }
    break;
  }
  return TCL_OK;
}

#define PRINT_FROM_FILE 0
#define PRINT_FROM_DATA 1

/****************************************************************
** PrintCommand: Main routine for sending data or files to a printer
****************************************************************/
static int PrintCommand (ClientData defaults, Tcl_Interp *interp, int argc, char **argv)
{
  static char *usgmsg = "printer send [-postscript|-nopostscript] "
			"[-hDC hdc] "
                        "[-printer printer] "
			"[-file|-data] file_or_data ... ";
  int ps = 1; /* For now, default is postscript */
  LPCSTR filename;
  char *printer = 0;
  char *hdcString = 0;
  static char last_printer[CCHDEVICENAME];
  int debug = 0;
  int printtype = PRINT_FROM_FILE;
  struct printer_values * ppv = (struct printer_values *) defaults;
  HDC hdc = 0;
  int self_created = 0; /* Remember if we specially created the DC */
  
  while ( argc > 0 )
  {
    if (argv[0][0] == '-')
    {
      /* Check for -postscript / -nopostscript flag */
      if (strcmp(argv[0], "-postscript") == 0)
        ps = 1;
      else if (strcmp(argv[0], "-nopostscript") == 0)
        ps = 0;
      else if ( strcmp(argv[0], "-printer") == 0)
      {
        argc--;
        argv++;
        printer = argv[0];
      }
      else if ( strcmp(argv[0], "-hdc") == 0  || strcmp (argv[0], "-hDC") == 0 )
      {
        argc--;
        argv++;
        hdcString = argv[0];
      }
      else if ( strcmp(argv[0], "-file") == 0)
        printtype = PRINT_FROM_FILE;
      else if ( strcmp(argv[0], "-data") == 0)
        printtype = PRINT_FROM_DATA;
      else if ( strcmp(argv[0], "-debug") == 0)
        debug++;
    }
    else
      break;
    argc--;
    argv++;
  }

  if (argc <= 0)
  {
    Tcl_SetResult(interp,usgmsg, TCL_STATIC);
    return TCL_ERROR;
  }

  if ( hdcString )
  {
    char *strend;
    hdc = (HDC)strtoul (hdcString, &strend, 0);
  }

  if ( hdc == NULL  )
  {
    if ( printer )
    {
      hdc = GetPrinterDC(printer);
      self_created = 1;
    }
    else if ( ppv->pdlg.hDC )
      hdc = ppv->pdlg.hDC;
    else if ( last_printer[0] == '\0' || ppv->pdlg.hDC == 0 )
    {
      if ( PrintOpen (defaults, interp, argc, argv) == TCL_OK )
      {
        hdc = ppv->pdlg.hDC;
        self_created = 1;
      }
    }
    else 
    {
      hdc = GetPrinterDC(last_printer);
      self_created = 1;
    }

    if ( hdc == NULL ) /* STILL can't get a good printer DC */
    {
      Tcl_SetResult (interp, "Error: Can't get a valid printer context", TCL_STATIC);
      return TCL_ERROR;
    }
  }

  /* Now save off a bit of information for the next call... */
  if (printer)
    strncpy ( last_printer, printer, sizeof(last_printer) - 1);
  else if ( ppv->pdlg.hDevMode )
  {
    DEVMODE *dm;
    dm = (DEVMODE *)GlobalLock (ppv->pdlg.hDevMode);
    strncpy ( last_printer, dm->dmDeviceName, sizeof(last_printer) - 1 );
    GlobalUnlock (ppv->pdlg.hDevMode);
  }
  
  while (argc > 0)
  {
    if ( printtype == PRINT_FROM_FILE )
    {
      filename = argv[0];
      if ( JobInfo(-1, 0, 0) == 0 )
        PrintStart(hdc, interp, filename);
      PrintFile(hdc, interp, filename, ps); /* handles own error messages */
      if ( self_created )
        PrintFinish(hdc);
    }
    else
    {
      if ( JobInfo (-1, 0, 0) == 0 )
        PrintStart(hdc, interp, "Tcl Standard Input");
      PrintData(hdc, interp, argv[0], ps);
      if ( self_created )
        PrintFinish(hdc);
    }
    argc--;
    argv++;
  }

  /* After all the files are printed, if the job wasn't completed, do so now */
  if ( JobInfo(-1, 0, 0) == 1 )
    PrintFinish(hdc);
    
  if (self_created)
    DeleteDC(hdc);

  return TCL_OK;
}

/*****************************************************************
** Support for file printing
** #if 0/#endif sections may be useful, but I can't find 
******************************************************************/

static int PrintStart (HDC hdc, Tcl_Interp *interp, const char *docname)
{
  DOCINFO docinfo;
  BOOL bresult;
  short result;

  docinfo.cbSize = sizeof docinfo;
  docinfo.lpszDocName = docname;
  docinfo.lpszOutput  = 0;
#if 0
  bresult = 1; /* Suppress output */
  result = Escape (hdc, POSTSCRIPT_IGNORE, 0, (LPCSTR)&bresult, NULL);
  /* Result is non-zero if previous setting was to suppress, 0 if previously suppressed */
#endif

  bresult = 1; /* EPS printing download suppressed */
  result = Escape (hdc, EPSPRINTING, sizeof (BOOL), (LPCSTR)&bresult, NULL);
  if ( result == 0 )
  {
	 /* The EPSPRINTING escape isn't implemented! */
	 Tcl_AppendElement(interp, 
	                   "printer I: EPSPRINTING escape not implemented");
  }
  else if ( result < 0 )
  {
	 /* The EPSPRINTING escape failed! */
	 Tcl_AppendElement(interp, 
	                   "printer W: EPSPRINTING escape implemented but failed");
  }

  StartDoc(hdc, &docinfo);
  JobInfo (1, docname, 0);
  
#if 0
  EndPage(hdc);
  StartPage(hdc);
#endif
  return 1;
}

static int PrintFinish (HDC hdc)
{
#if 0
  EndPage(hdc);
#endif

  EndDoc(hdc);
  JobInfo (0, 0, 0);
  return 1;
}

static int PrintFile (HDC hdc, Tcl_Interp *interp, const char *filename, int postscript)
{
  Tcl_Channel channel;
  
  struct {
	 short len; /* Defined to be 16 bits.... */
	 char buffer[128+1];
  } indata;

  if ( (channel = Tcl_OpenFileChannel(interp, (char *)filename, "r", 0444)) == NULL)
  {
    return 0;
  }
  if (postscript == 0)
    Tcl_SetChannelOption(interp, channel, "-translation", "binary");
  else
  {
    /* Note: NT 4.0 seems to leave the default CTM quite tiny! */
    strcpy(indata.buffer, "\r\nsave\r\ninitmatrix\r\n");
    indata.len = strlen(indata.buffer);
    Escape(hdc, PASSTHROUGH, 0, (LPCSTR)&indata, NULL);
  }
  
  while ( (indata.len = Tcl_Read(channel, indata.buffer, sizeof(indata.buffer)-1)) > 0)
  {
    int retval;
    indata.buffer[indata.len] = '\0';
    retval = Escape(hdc, PASSTHROUGH, 0, (LPCSTR)&indata, NULL);
    if (retval <= 0)
    {
      Tcl_AppendElement(interp, "printer E: PASSTHROUGH Escape failed");
    }
    else if (retval != indata.len)
    {
      sprintf(msgbuf, "printer W: Short write (%d vs. %d)", retval, indata.len);
      Tcl_AppendElement(interp, msgbuf);
    }
  }
  Tcl_Close(interp,channel);
  
  if (postscript != 0)
  {
    strcpy(indata.buffer, "\r\nrestore\r\n");
    indata.len = strlen(indata.buffer);
    Escape(hdc, PASSTHROUGH, 0, (LPCSTR)&indata, NULL);
  }

  return 1;
}

static int PrintData (HDC hdc, Tcl_Interp *interp, const char *data, int postscript)
{
  const char *cp = data;
  long datalen;
  
  struct {
	 short len; /* Defined to be 16 bits.... */
	 char buffer[128+1];
  } indata;


  if (data == 0)
  {
    Tcl_AppendElement(interp, "Cannot send NULL data to printer!");
  }

  datalen = strlen(data);
  
  if (postscript)
  {
    /* Note: NT 4.0 seems to leave the default CTM quite tiny! */
    strcpy(indata.buffer, "\r\nsave\r\ninitmatrix\r\n");
    indata.len = strlen(indata.buffer);
    Escape(hdc, PASSTHROUGH, 0, (LPCSTR)&indata, NULL);
  }

  while (datalen > 0)
  {
    int retval;
    short len = sizeof(indata.buffer) - 1;
    if ( datalen < (long)len )
      len = (short)datalen;
    strncpy (indata.buffer, cp, len);
    indata.len = len;
    indata.buffer[indata.len] = '\0';
    cp += len;
    datalen -= len;
    
    retval = Escape(hdc, PASSTHROUGH, 0, (LPCSTR)&indata, NULL);
    if (retval <= 0)
    {
      Tcl_AppendElement(interp, "printer E: PASSTHROUGH Escape failed");
    }
    else if (retval != indata.len)
    {
      sprintf(msgbuf, "printer W: Short write (%d vs. %d)", retval, indata.len);
      Tcl_AppendElement(interp, msgbuf);
    }
  }
  
  if (postscript != 0)
  {
    strcpy(indata.buffer, "\r\nrestore\r\n");
    indata.len = strlen(indata.buffer);
    Escape(hdc, PASSTHROUGH, 0, (LPCSTR)&indata, NULL);
  }

  return 1;
}

static int PrintOpen(ClientData data, Tcl_Interp *interp, int argc, char **argv)
{
  struct printer_values *ppv = (struct printer_values *)data;

  HANDLE oldDevNames = 0;
  HANDLE oldDevMode = 0;
  
  /* Command line should specify everything needed. Don't bring up dialog */
  /* Use command line to populate structure (or call original GetPrinterDC) */
  if (ppv->pdlg.hDC == NULL) /* No HDC built yet */
  {
    HWND tophwnd;
    int retval;
    
    ppv->pdlg.lStructSize = sizeof( PRINTDLG );
    ppv->pdlg.Flags = PD_RETURNDEFAULT | PD_RETURNDC;
    oldDevNames = ppv->pdlg.hDevNames;
    oldDevMode  = ppv->pdlg.hDevMode;
    ppv->pdlg.hDevNames = 0;
    ppv->pdlg.hDevMode  = 0;
    /* The following is an attempt to get the right owners notified of
    ** repaint requests from the dialog. It doesn't quite work.
    ** It does make the dialog box modal to the toplevel it's working with, though.
    */
    if ( (ppv->pdlg.hwndOwner = GetActiveWindow()) != 0 )
      while ( (tophwnd = GetParent(ppv->pdlg.hwndOwner) ) != 0 )
        ppv->pdlg.hwndOwner = tophwnd;

    /*
    ** Since we are doing the "default" dialog, we must put NULL in the
    ** hDevNames and hDevMode members.
    ** We save the old members in case of cancellation
    */
    retval = PrintDlg ( &(ppv->pdlg) );
    if ( retval == 1 )
    {
      /* Free up the old device stuff */
      if (ppv->pgdlg.hDevNames == oldDevNames)
        ppv->pgdlg.hDevNames = ppv->pdlg.hDevNames;
      if (ppv->pgdlg.hDevMode == oldDevMode)
        ppv->pgdlg.hDevMode  = ppv->pdlg.hDevMode;
      if ( oldDevNames )
        GlobalFree(oldDevNames);
      if ( oldDevMode )
        GlobalFree(oldDevMode);
    }
    else
    {
      /* Failed or cancelled. What should we do? Replace the old members. */
      ppv->pdlg.hDevNames = oldDevNames;
      ppv->pdlg.hDevMode  = oldDevMode;
    }
  }

  /* The status does not need to be supplied. either hDC is OK or it's NULL */
  sprintf(msgbuf, "0x%lx", (unsigned long)(ppv->pdlg.hDC) );
  Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);

  return TCL_OK;
}

/****************************************************************
** PrintClose - Frees the printer DC and releases it.
****************************************************************/
static int PrintClose(ClientData data, Tcl_Interp *interp, int argc, char **argv)
{
  struct printer_values *ppv = (struct printer_values *)data;

  PrintFinish(ppv->pdlg.hDC);


  if (ppv->devPortrait != NULL) {
    free(ppv->devPortrait);
    ppv->devPortrait = NULL;
  }
  if (ppv->devLandscape != NULL) {
    free(ppv->devLandscape);
    ppv->devLandscape = NULL;
  }

  
  /* Free the printer DC */  
  DeleteDC(ppv->pdlg.hDC);
  ppv->pdlg.hDC = NULL;

	/* Also, free devmode and devnames so print open can be called again */
  if (ppv->pdlg.hDevMode != NULL)
  {
    if ( ppv->pgdlg.hDevMode == ppv->pdlg.hDevMode )
      ppv->pgdlg.hDevMode = 0;
    GlobalFree(ppv->pdlg.hDevMode);
    ppv->pdlg.hDevMode = NULL;
  }

  if (ppv->pdlg.hDevNames != NULL)
  {
    if ( ppv->pgdlg.hDevNames == ppv->pdlg.hDevNames )
      ppv->pgdlg.hDevNames = 0;
    GlobalFree(ppv->pdlg.hDevNames);
    ppv->pdlg.hDevNames = NULL;
  }

  if ( ppv->pgdlg.hDevMode )
  {
    GlobalFree(ppv->pgdlg.hDevMode);
    ppv->pgdlg.hDevMode = 0;
  }

  if ( ppv->pgdlg.hDevNames )
  {
    GlobalFree(ppv->pgdlg.hDevNames);
    ppv->pgdlg.hDevNames = 0;
  }
  
  return TCL_OK;
}

static int PrintDialog(ClientData data, Tcl_Interp *interp, int argc, char **argv)
{
  /* Which dialog is requested: one of select, page_setup */
  static char usage_message[] = "printer dialog [select|page_setup] [-flags flagsnum]";
  struct printer_values *ppv = (struct printer_values *)data;
  int flags;
  int oldMode;
  int print_retcode;
  static const int PRINT_ALLOWED_SET = PD_ALLPAGES|PD_SELECTION|PD_PAGENUMS|
                                 PD_NOSELECTION|PD_NOPAGENUMS|PD_COLLATE|
				 PD_PRINTTOFILE|PD_PRINTSETUP|PD_NOWARNING|
				 PD_RETURNDC|PD_RETURNDEFAULT|
				 PD_DISABLEPRINTTOFILE|PD_HIDEPRINTTOFILE|
				 PD_NONETWORKBUTTON;
  static const int PAGE_ALLOWED_SET =
                                 PSD_DEFAULTMINMARGINS|PSD_DISABLEMARGINS|
				 PSD_DISABLEORIENTATION|PSD_DISABLEPAGEPAINTING|
				 PSD_DISABLEPAPER|PSD_DISABLEPRINTER|
				 PSD_INHUNDREDTHSOFMILLIMETERS|PSD_INTHOUSANDTHSOFINCHES|
				 PSD_RETURNDEFAULT;

  if (argc < 1)
  {
    Tcl_SetResult(interp ,usage_message, TCL_STATIC);
    return TCL_ERROR;
  }

  if ( strcmp(argv[0], "select") == 0)
  {
    /*
    ** Looking at the return value of PrintDlg, we want to
    ** save the values in the PAGEDIALOG for the next time.
    ** The tricky part is that PrintDlg and PageSetupDlg
    ** have the ability to move their hDevMode and hDevNames memory. 
    ** This never seems to happen under NT, 
    ** seems not to happen under Windows 3.1,
    ** but can be demonstrated under Windows 95 (and presumably Windows 98).
    **
    ** As the handles are shared among the Print and Page dialogs, we must
    ** consistently establish and free the handles.
    ** Current thinking is to preserve them in the PageSetup structure ONLY,
    ** thus avoiding the problem here.
    */

    /* Save off the old DevMode and Devnames in case of cancellation */
    HANDLE  oldDevMode  = ppv->pdlg.hDevMode;
    HANDLE  oldDevNames = ppv->pdlg.hDevNames;
    HANDLE  oldHDC      = ppv->pdlg.hDC;
    HWND    tophwnd;

    ppv->pdlg.hDevMode  = NULL;
    ppv->pdlg.hDevNames = NULL;
    ppv->pdlg.hDC       = NULL;
    
    /* 
    ** This loop make the dialog box modal to the toplevel it's working with.
    ** It also avoids any reliance on Tk code (for Tcl users).
    */
    if ( (ppv->pdlg.hwndOwner = GetActiveWindow()) != 0 )
      while ( (tophwnd = GetParent(ppv->pdlg.hwndOwner) ) != 0 )
        ppv->pdlg.hwndOwner = tophwnd;

    /* Leaving the memory alone will preserve selections */
    /* memset (&(ppv->pdlg), 0, sizeof(PRINTDLG) ); */
    ppv->pdlg.lStructSize = sizeof(PRINTDLG);
    ppv->pdlg.Flags = PD_RETURNDC; 

    /*
    ** Now, handle any remaining command line arguments
    */
    if ( argc > 1 )
    {
      /* For now, just look for "flags" */
      if ( strcmp(argv[1], "-flags") == 0 )
      {
        char *endstr;
        if (argv[2])
          flags = strtol(argv[2], &endstr, 0); /* Take any valid base */
        if (endstr != argv[2]) /* if this was a valid numeric string */
        {
          /* Enable requested flags, but disable the flags we don't want to support */
          ppv->pdlg.Flags |= flags;
          ppv->pdlg.Flags &= PRINT_ALLOWED_SET;
        }
      }
    }

#if TCL_MAJOR_VERSION > 7
    /* In Tcl versions 8 and later, a service call to the notifier is provided */
    oldMode = Tcl_SetServiceMode(TCL_SERVICE_ALL);
#endif

    print_retcode = PrintDlg(&(ppv->pdlg));

#if TCL_MAJOR_VERSION > 7
    /* Return the service mode to its original state */
    Tcl_SetServiceMode(oldMode);
#endif

    if ( print_retcode == 1 ) /* Not cancelled */
    {
      /* If the hDevNames or hDevMode members are set, update the
      ** page setup dialog members to match
      ** That way, if we bring up the page setup dialog, we'll have
      ** the right printer selected.
      */
      if ( ppv->pdlg.hDevMode != NULL )
      {
        if ( ppv->pgdlg.hDevMode != NULL && 
	     ppv->pgdlg.hDevMode != oldDevMode )
          GlobalFree (ppv->pgdlg.hDevMode);
        ppv->pgdlg.hDevMode = ppv->pdlg.hDevMode;
      }

      if ( ppv->pdlg.hDevNames != NULL )
      {
        if ( ppv->pgdlg.hDevNames != NULL && 
	     ppv->pgdlg.hDevNames != oldDevNames )
          GlobalFree (ppv->pgdlg.hDevNames);
        ppv->pgdlg.hDevNames = ppv->pdlg.hDevNames;
      }

      /* Now, free the old stuff.
      ** The old DC should still be valid, so may be deleted.
      ** The oldDevMode and oldDevNames have been replaced into the
      ** page setup dialog, so are no longer needed.
      */
      if ( oldHDC )
        DeleteDC(oldHDC);
      if ( oldDevMode )
        GlobalFree(oldDevMode);
      if ( oldDevNames )
        GlobalFree(oldDevNames);
    }
    else /* Canceled */
    {
      ppv->pdlg.hDC       = oldHDC;
      ppv->pdlg.hDevNames = oldDevNames;
      ppv->pdlg.hDevMode  = oldDevMode;
    }


{DEVMODE *pDevMode = (DEVMODE *)GlobalLock (ppv->pdlg.hDevMode);

ppv->devPortrait = PrintGetOrientedDevMode(ppv->pdlg.hwndOwner, pDevMode->dmDeviceName, DMORIENT_PORTRAIT);
ppv->devLandscape = PrintGetOrientedDevMode(ppv->pdlg.hwndOwner, pDevMode->dmDeviceName, DMORIENT_LANDSCAPE);

//sprintf(msgbuf,"device = '%s'\n0x%08x\n0x%08x",pDevMode->dmDeviceName,ppv->devPortrait,ppv->devLandscape);
//MessageBox(NULL, msgbuf, "Information",MB_ICONSTOP | MB_OK | MB_TASKMODAL | MB_SETFOREGROUND);

GlobalUnlock (ppv->pdlg.hDevMode);}


    /* Results are available through printer attr; HDC now returned */
    /* This would be a good place for Tcl_SetObject, but for now, support
    ** older implementations by returning a Hex-encoded value.
    ** Note: Added a 2nd parameter to allow caller to note cancellation.
    */
    sprintf(msgbuf, "0x%lx %d", (unsigned long)(ppv->pdlg.hDC), print_retcode );
    Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
  }
  else if (strcmp(argv[0], "page_setup") == 0 )
  {
    /*
    ** Now, handle any remaining command line arguments
    */
    if ( argc > 1 )
    {
      /* For now, just look for "flags" */
      if ( strcmp(argv[1], "-flags") == 0 )
      {
        char *endstr;
        if (argv[2])
          flags = strtol(argv[2], &endstr, 0); /* Take any valid base */
        if (endstr != argv[2]) /* if this was a valid numeric string */
        {
          /* Enable requested flags, but disable the flags we don't want to support */
          ppv->pgdlg.Flags |= flags;
          ppv->pgdlg.Flags &= PAGE_ALLOWED_SET;
        }
      }
    }
    
    /* memset (&(ppv->pgdlg), 0, sizeof(PAGESETUPDLG)); */
    ppv->pgdlg.lStructSize = sizeof(PAGESETUPDLG);
#if TCL_MAJOR_VERSION > 7
    /* In Tcl versions 8 and later, a service call to the notifier is provided */
    oldMode = Tcl_SetServiceMode(TCL_SERVICE_ALL);
#endif

    print_retcode = PageSetupDlg(&(ppv->pgdlg));

#if TCL_MAJOR_VERSION > 7
    /* Return the service mode to its original state */
    Tcl_SetServiceMode(oldMode);
#endif

    sprintf(msgbuf, "%d", print_retcode );
    Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
  }
  else
  {
    Tcl_SetResult(interp ,usage_message, TCL_STATIC);
    return TCL_ERROR;
  }

  return TCL_OK;
}

static int JobInfo(int state, const char *name, const char **outname)
{
  static int inJob = 0;
  static char jobname[63+1];

  switch (state)
  {
    case 0:
      inJob = 0;
      jobname[0] = '\0';
      break;
    case 1:
      inJob = 1;
      if ( name )
        strncpy (jobname, name, sizeof(jobname) - 1 );
      break;
    default:
      break;
  }
  if ( outname )
    *outname = jobname;
  return inJob;
}

static int PrintJob(ClientData data, Tcl_Interp *interp, int argc, char **argv)
{
  DOCINFO di;
  struct printer_values * ppv = (struct printer_values *) data;

  static char usage_message[] = "printer job start [-name docname]\nprinter job end";

  /* Parameters for document name and output file (if any) should be supported */

  /* Should this command keep track of start/end state so two starts in a row
  ** automatically have an end inserted?
  */
  if ( argc == 0 )  /* printer job by itself */
  {
    const char *jobname;
    int status;
    
    status = JobInfo (-1, 0, &jobname);
    if ( status )
      Tcl_SetResult(interp, (char *)jobname, TCL_VOLATILE);
    return TCL_OK;
  }
  else if ( argc >= 1 )
  {
    if ( strcmp (*argv, "start") == 0 )
    {
      char *docname = "Tcl Printer Document";
      int oldMode;
      
      argc--;
      argv++;
      /* handle -name argument if present */
      if ( argc >= 1 && strcmp( *argv, "-name" ) == 0 )
      {
        argv++;
        if ( --argc > 0 )
        {
          docname = *argv;
        }
      }

      /* Ensure the hDC is valid before continuing */
      if ( ppv->pdlg.hDC == NULL )
      {
        Tcl_SetResult (interp, "Error starting print job: no printer context", TCL_STATIC);
        return TCL_ERROR;
      }
      
      /* Close off any other job if already in progress */
      if ( JobInfo(-1, 0, 0) )
      {
        EndDoc(ppv->pdlg.hDC);
        JobInfo(0, 0, 0);
      }

      memset ( &di, 0, sizeof(DOCINFO) );
      di.cbSize = sizeof(DOCINFO);
      di.lpszDocName = docname;

      /*****************************************************************
      ** If print to file is selected, this causes a popup dialog.
      ** Therefore, in Tcl 8 and above, enable event handling
      ******************************************************************/
#if TCL_MAJOR_VERSION > 7
      /* In Tcl versions 8 and later, a service call to the notifier is provided */
      oldMode = Tcl_SetServiceMode(TCL_SERVICE_ALL);
#endif
      StartDoc(ppv->pdlg.hDC, &di);
      JobInfo (1, docname, 0);
#if TCL_MAJOR_VERSION > 7
    /* Return the service mode to its original state */
    Tcl_SetServiceMode(oldMode);
#endif


      return TCL_OK;
    }
    else if ( strcmp (*argv, "end") == 0 )
    {
      EndDoc(ppv->pdlg.hDC);
      JobInfo (0, 0, 0);
      
      return TCL_OK;
    }
  }

  Tcl_SetResult(interp, usage_message, TCL_STATIC);
  return TCL_ERROR;
}

static int PrintPage(ClientData data, Tcl_Interp *interp, int argc, char **argv)
{
  struct printer_values * ppv = (struct printer_values *) data;
  static char usage_message[] = "printer page [start|end] [orientation]";

  /* Should this command keep track of start/end state so two starts in a row
  ** automatically have an end inserted?
  */
  if ( argc >= 1 )
  {
    if ( strcmp (*argv, "start") == 0 )
    {
		if (argc >= 2) {
		    if ( strcmp (argv[1], "-portrait") == 0 )	{
				ResetDC(ppv->pdlg.hDC, ppv->devPortrait);
			} else {
				ResetDC(ppv->pdlg.hDC, ppv->devLandscape);
			}
		}
	  StartPage(ppv->pdlg.hDC);
      return TCL_OK;
    }
	else if ( strcmp(*argv, "size") == 0 )
	  return PrintPageSize(data, interp, argc-1, argv+1);
    else if ( strcmp (*argv, "end") == 0 )
    {
      EndPage(ppv->pdlg.hDC);
      return TCL_OK;
    }
  }

  Tcl_SetResult(interp, usage_message, TCL_STATIC);
  return TCL_ERROR;
}

/****************************************************************
** This function gets physical page size in case the user hasn't
** performed any action to set it
****************************************************************/
static int PrintPageAttr (HDC hdc, int *hsize, int *vsize,
                                   int *hscale, int *vscale,
                                   int *hoffset, int *voffset)
{
  int status = 0;
  if ( hdc == 0 )
  {
    return -1; /* A value indicating failure */
  }
#ifdef WIN32
  *hsize = GetDeviceCaps(hdc, PHYSICALWIDTH);
  *vsize = GetDeviceCaps(hdc, PHYSICALHEIGHT);
  *hscale = GetDeviceCaps(hdc, SCALINGFACTORX);
  *vscale = GetDeviceCaps(hdc, SCALINGFACTORY);
  *hoffset = GetDeviceCaps (hdc, PHYSICALOFFSETX);
  *voffset = GetDeviceCaps (hdc, PHYSICALOFFSETY);
#else
  /* These functions are obsolete in WIN32 (but should still be supported) */
  POINT size, scale, offset;
  status  = Escape(hdc, GETPHYSPAGESIZE, 0, 0, &size);
  status |= Escape(hdc, GETPHYSPAGEOFFSET, 0, 0, &offset);
  status |= Escape(hdc, GETSCALINGFACTOR, 0, 0, &scale );
  *hsize = size.x;
  *vsize = size.y;
  *hscale = scale.x;
  *vscale = scale.y;
  *hoffset = offset.x;
  *voffset = offset.y;
#endif
  return status;
}

/****************************************************************
** Report printer attributes.
** In some cases, this function should probably get the information
** if not already available from user action
** -- For instance, page size
****************************************************************/
static int PrintAttr(ClientData data, Tcl_Interp *interp, int argc, char **argv)
{
  struct printer_values * ppv = (struct printer_values *) data;

  /* Get and set options? Depends on further arguments? Pattern matching? */
  /* Returns a collection of key/value pairs. Should it use a user-specified array name? */
  /* The attributes of interest are the ones buried in the dialog structures */

  /*
  ** This command should take an HDC as an optional parameter, otherwise using
  ** the one in the ppv structure?
  */
  
  if (ppv)
  {
    if (ppv->pdlg.hDC == NULL) /* No HDC built yet--just get attributes of default */
    {
      ppv->pdlg.lStructSize = sizeof( PRINTDLG );
      ppv->pdlg.Flags = PD_RETURNDEFAULT;
      if ( PrintDlg( &(ppv->pdlg) ) == 0 )
        ppv->pdlg.lStructSize = 0;
    }
    
    if (ppv->pdlg.lStructSize)
    {
      /* For now, just append them to a list--just so we can see the results */
      sprintf(msgbuf, "%s %d", "copies", ppv->pdlg.nCopies);
      Tcl_AppendElement(interp, msgbuf);
      sprintf(msgbuf, "\"%s\" %d", "first page", ppv->pdlg.nFromPage);
      Tcl_AppendElement(interp, msgbuf);
      sprintf(msgbuf, "\"%s\" %d", "last page", ppv->pdlg.nToPage);
      Tcl_AppendElement(interp, msgbuf);
      sprintf(msgbuf, "%s 0x%lx", "hDC", ppv->pdlg.hDC);
      Tcl_AppendElement(interp, msgbuf);
    }
    else
    {
      Tcl_AppendElement(interp, "copies ?");
      Tcl_AppendElement(interp, "\"first page\" ?");
      Tcl_AppendElement(interp, "\"last page\" ?");
      Tcl_AppendElement(interp, "hDC ?");
    }

    if ( ppv->pdlg.hDevMode != NULL)
    {
      DEVMODE *dm;
      dm = (DEVMODE *)GlobalLock (ppv->pdlg.hDevMode);
      sprintf(msgbuf, "%s \"%s\"", "device", dm->dmDeviceName);
      Tcl_AppendElement(interp, msgbuf);
      if ( dm->dmFields & DM_ORIENTATION )
      {
        sprintf(msgbuf, "\"%s\" %s", "page orientation", 
                        dm->dmOrientation==DMORIENT_PORTRAIT?"portrait":"landscape");
        Tcl_AppendElement(interp, msgbuf);
      }
      else
      {
        Tcl_AppendElement(interp, "device ?");
        Tcl_AppendElement(interp, "\"page orientation\" ?");
      }


      if ( dm->dmFields & DM_YRESOLUTION )
      {
        sprintf(msgbuf, "%s \"%d %d\"", "resolution", 
	                dm->dmYResolution, dm->dmPrintQuality);
        Tcl_AppendElement(interp, msgbuf);
      }
      else if ( (dm->dmFields & DM_PRINTQUALITY) && dm->dmPrintQuality > 0 )
      {
        sprintf(msgbuf, "%s \"%d %d\"", "resolution", 
	                dm->dmPrintQuality, dm->dmPrintQuality);
        Tcl_AppendElement(interp, msgbuf);
      }
      else
        Tcl_AppendElement(interp, "resolution \"? ?\"");


      if ( dm->dmFields & DM_LOGPIXELS )
      {
        sprintf(msgbuf, "\"%s\" %d", "pixels per inch", 
	                dm->dmLogPixels);
        Tcl_AppendElement(interp, msgbuf);
      }
      else
        Tcl_AppendElement(interp, "\"pixels per inch\" ?");


      GlobalUnlock (ppv->pdlg.hDevMode);
    }
    else
    {
      Tcl_AppendElement(interp, "device ?");
      Tcl_AppendElement(interp, "\"page orientation\" ?");
      Tcl_AppendElement(interp, "resolution \"? ?\"");
      Tcl_AppendElement(interp, "\"pixels per inch\" ?");
    }


    /* Try to initialize the structures using PageSetupDlg with the
    ** no dialog box option
    */
    if ( ppv->pgdlg.lStructSize == 0 && ppv->pdlg.hDevMode == NULL)
    {
      ppv->pgdlg.lStructSize = sizeof(PAGESETUPDLG);
      ppv->pgdlg.Flags |= PSD_RETURNDEFAULT;
      if ( PageSetupDlg(&(ppv->pgdlg)) == FALSE )
        ppv->pgdlg.lStructSize = 0;
      ppv->pgdlg.Flags ^= PSD_RETURNDEFAULT;
    }
    
    /* If the user has brought up the page setup dialog, use these values--
    ** if not, use the values in the DEVMODE structure
    ** if those aren't present, just return unknowns
    */
    if ( ppv->pgdlg.lStructSize )
    {
      sprintf(msgbuf, "\"%s\" \"%ld %ld\"", "page dimensions", 
                      ppv->pgdlg.ptPaperSize.x, ppv->pgdlg.ptPaperSize.y);
      Tcl_AppendElement (interp, msgbuf);
      sprintf(msgbuf, "\"%s\" \"%ld %ld %ld %ld\"", "page margins", 
                      ppv->pgdlg.rtMargin.left,
                      ppv->pgdlg.rtMargin.top,
                      ppv->pgdlg.rtMargin.right,
                      ppv->pgdlg.rtMargin.bottom);
      Tcl_AppendElement (interp, msgbuf);
      sprintf(msgbuf, "\"%s\" \"%ld %ld %ld %ld\"", "page minimum margins", 
                      ppv->pgdlg.rtMinMargin.left,
                      ppv->pgdlg.rtMinMargin.top,
                      ppv->pgdlg.rtMinMargin.right,
                      ppv->pgdlg.rtMinMargin.bottom);
      Tcl_AppendElement (interp, msgbuf);
    }
    else if ( ppv->pdlg.hDevMode != NULL)
    {
      DEVMODE *dm;
      dm = (DEVMODE *)GlobalLock (ppv->pdlg.hDevMode);

      /* Look for page size here... */
      if ( (dm->dmFields & DM_PAPERLENGTH) && (dm->dmFields & DM_PAPERWIDTH) )
      {
//MessageBox(NULL, "Using paper length", "Information",MB_ICONSTOP | MB_OK | MB_TASKMODAL | MB_SETFOREGROUND);
        sprintf (msgbuf, "\"%s\" \"%ld %ld\"", "page dimensions",
            (long)TENTH_MM_TO_MINCH(dm->dmPaperWidth), 
	    (long)TENTH_MM_TO_MINCH(dm->dmPaperLength));
		Tcl_AppendElement (interp, msgbuf);
      }
      else if ( dm->dmFields & DM_PAPERSIZE )
      {
        static const struct paper_size { int size; long wid; long len; } paper_sizes[] = {
          { DMPAPER_LETTER, 8500, 11000 },
          { DMPAPER_LEGAL, 8500, 14000 },
          { DMPAPER_A4, (long)MM_TO_MINCH(210), (long)MM_TO_MINCH(297) },
          { DMPAPER_CSHEET, 17000, 22000 },
          { DMPAPER_DSHEET, 22000, 34000 },
          { DMPAPER_ESHEET, 34000, 44000 },
          { DMPAPER_LETTERSMALL, 8500, 11000 },
          { DMPAPER_TABLOID, 11000, 17000 },
          { DMPAPER_LEDGER, 17000, 11000 },
          { DMPAPER_STATEMENT, 5500, 8500 },
          { DMPAPER_A3, (long)MM_TO_MINCH(297), (long)MM_TO_MINCH(420) },
          { DMPAPER_A4SMALL, (long)MM_TO_MINCH(210), (long)MM_TO_MINCH(297) },
          { DMPAPER_A5, (long)MM_TO_MINCH(148), (long)MM_TO_MINCH(210) },
          { DMPAPER_B4, (long)MM_TO_MINCH(250), (long)MM_TO_MINCH(354) },
          { DMPAPER_B5, (long)MM_TO_MINCH(182), (long)MM_TO_MINCH(257) },
          { DMPAPER_FOLIO, 8500, 13000 },
          { DMPAPER_QUARTO, (long)MM_TO_MINCH(215), (long)MM_TO_MINCH(275) },
          { DMPAPER_10X14, 10000, 14000 },
          { DMPAPER_11X17, 11000, 17000 },
          { DMPAPER_NOTE, 8500, 11000 },
          { DMPAPER_ENV_9, 3875, 8875 },
          { DMPAPER_ENV_10, 4125, 9500 },
          { DMPAPER_ENV_11, 4500, 10375 },
          { DMPAPER_ENV_12, 4750, 11000 },
          { DMPAPER_ENV_14, 5000, 11500 },
          { DMPAPER_ENV_DL, (long)MM_TO_MINCH(110), (long)MM_TO_MINCH(220) },
          { DMPAPER_ENV_C5, (long)MM_TO_MINCH(162), (long)MM_TO_MINCH(229) },
          { DMPAPER_ENV_C3, (long)MM_TO_MINCH(324), (long)MM_TO_MINCH(458) },
          { DMPAPER_ENV_C4, (long)MM_TO_MINCH(229), (long)MM_TO_MINCH(324) },
          { DMPAPER_ENV_C6, (long)MM_TO_MINCH(114), (long)MM_TO_MINCH(162) },
          { DMPAPER_ENV_C65, (long)MM_TO_MINCH(114), (long)MM_TO_MINCH(229) },
          { DMPAPER_ENV_B4, (long)MM_TO_MINCH(250), (long)MM_TO_MINCH(353) },
          { DMPAPER_ENV_B5, (long)MM_TO_MINCH(176), (long)MM_TO_MINCH(250) },
          { DMPAPER_ENV_B6, (long)MM_TO_MINCH(176), (long)MM_TO_MINCH(125) },
          { DMPAPER_ENV_ITALY, (long)MM_TO_MINCH(110), (long)MM_TO_MINCH(230) },
          { DMPAPER_ENV_MONARCH, 3825, 7500 },
          { DMPAPER_ENV_PERSONAL, 3625, 6500 },
          { DMPAPER_FANFOLD_US, 14825, 11000 },
          { DMPAPER_FANFOLD_STD_GERMAN, 8500, 12000 },
          { DMPAPER_FANFOLD_LGL_GERMAN, 8500, 13000 },
        };
        int i;

//MessageBox(NULL, "Using paper size", "Information",MB_ICONSTOP | MB_OK | MB_TASKMODAL | MB_SETFOREGROUND);
        for (i=0; i<sizeof(paper_sizes) / sizeof(struct paper_size); i++)
        {
          if (paper_sizes[i].size == dm->dmPaperSize )
          {
//sprintf(msgbuf, "%d", i);MessageBox(NULL, msgbuf, "Information",MB_ICONSTOP | MB_OK | MB_TASKMODAL | MB_SETFOREGROUND);
            sprintf(msgbuf, "\"%s\" \"%d %d\"", "page dimensions", paper_sizes[i].wid, paper_sizes[i].len);
            Tcl_AppendElement(interp, msgbuf);
            break;
          }
        }
        if ( i == ( sizeof(paper_sizes) / sizeof (struct paper_size) ) )
          Tcl_AppendElement (interp, "\"page dimensions\" \"? ?\"");
      }
      else
        Tcl_AppendElement (interp, "\"page dimensions\" \"? ?\"");
      
/*	  {
	    int hsize, vsize, hscale, vscale, hoffset, voffset;
		if (PrintPageAttr(ppv->pdlg.hDC, &hsize, &vsize, &hscale, &vscale, &hoffset, &voffset) != -1) {
			sprintf(msgbuf, "\"page dimensions\" \"%d %d\"", hsize, vsize);
			Tcl_AppendElement (interp, msgbuf);
			sprintf(msgbuf, "\"page offset\" \"%d %d\"", hoffset, voffset);
			Tcl_AppendElement (interp, msgbuf);
		} else {
			Tcl_AppendElement (interp, "\"page dimensions\" \"? ?\"");
			Tcl_AppendElement (interp, "\"page offset\" \"? ?\"");
		}
		sprintf(msgbuf, "\"page minimum margins\" \"%d %d %d %d\"", hoffset, voffset,
                                                          hsize - hoffset, vsize - voffset);
		Tcl_AppendElement (interp, msgbuf);
	  }
*/
/*
      Tcl_AppendElement (interp, "\"page margins\" \"1000 1000 1000 1000\"");
      Tcl_AppendElement (interp, "\"page minimum margins\" \"0 0 0 0\"");
*/
      
      GlobalUnlock (ppv->pdlg.hDevMode);
    }
    else
    {
      int hsize, vsize, hscale, vscale, hoffset, voffset;
      PrintPageAttr(ppv->pdlg.hDC, &hsize, &vsize, &hscale, &vscale, &hoffset, &voffset);
      sprintf(msgbuf, "\"page dimensions\" \"%d %d\"", hsize, vsize);
      Tcl_AppendElement (interp, msgbuf);
      sprintf(msgbuf, "\"page margins\" \"%d %d %d %d\"", hoffset, voffset,
                                                          hsize - hoffset, vsize - voffset);
      Tcl_AppendElement (interp, msgbuf);
      sprintf(msgbuf, "\"page minimum margins\" \"%d %d %d %d\"", hoffset, voffset,
                                                          hsize - hoffset, vsize - voffset);
      Tcl_AppendElement (interp, msgbuf);
    }
  }
  else
  {
    Tcl_SetResult (interp, "Error: Printer values not set", TCL_STATIC);
    return TCL_ERROR;
   }
  
  return TCL_OK;
}



LPDEVMODE PrintGetOrientedDevMode(HWND hWnd, char *pDevice, int orientation)
{
HANDLE      hPrinter;
LPDEVMODE   pDevMode;
DWORD       dwNeeded, dwRet;

   /* Start by opening the printer */ 
   if (!OpenPrinter(pDevice, &hPrinter, NULL))
       return NULL;

   /*
    * Step 1:
    * Allocate a buffer of the correct size.
    */ 
   dwNeeded = DocumentProperties(hWnd,
       hPrinter,       /* handle to our printer */ 
       pDevice,        /* Name of the printer */ 
       NULL,           /* Asking for size so */ 
       NULL,           /* these are not used. */ 
       0);             /* Zero returns buffer size. */ 
   pDevMode = (LPDEVMODE)malloc(dwNeeded);

   /*
    * Step 2:
    * Get the default DevMode for the printer and
    * modify it for our needs.
    */ 
   dwRet = DocumentProperties(hWnd,
       hPrinter,
       pDevice,
       pDevMode,       /* The address of the buffer to fill. */ 
       NULL,           /* Not using the input buffer. */ 
       DM_OUT_BUFFER); /* Have the output buffer filled. */ 
   if (dwRet != IDOK)
   {
       /* if failure, cleanup and return failure */ 
       free(pDevMode);
       ClosePrinter(hPrinter);
       return NULL;
   }

   /*
    * Make changes to the DevMode which are supported.
    */ 
   if (pDevMode->dmFields & DM_ORIENTATION)
   {
       /* if the printer supports paper orientation, set it*/ 
       pDevMode->dmOrientation = orientation;
   }

   /*
    * Step 3:
    * Merge the new settings with the old.
    * This gives the driver a chance to update any private
    * portions of the DevMode structure.
    */ 
    dwRet = DocumentProperties(hWnd,
       hPrinter,
       pDevice,
       pDevMode,       /* Reuse our buffer for output. */ 
       pDevMode,       /* Pass the driver our changes. */ 
       DM_IN_BUFFER |  /* Commands to Merge our changes and */ 
       DM_OUT_BUFFER); /* write the result. */ 

   /* Done with the printer */ 
   ClosePrinter(hPrinter);

   if (dwRet != IDOK)
   {
       /* if failure, cleanup and return failure */ 
       free(pDevMode);
       return NULL;
   }

   /* return the modified DevMode structure */ 
   return pDevMode;

} 










/****************************************************************
****************************************************************/
static int PrintPageSize(ClientData data, Tcl_Interp *interp, int argc, char **argv)
{
struct printer_values * ppv = (struct printer_values *) data;
int hsize, vsize, hoffset, voffset;
int w,h;


	if (argc < 2) {
		Tcl_SetResult(interp, "page size x y", TCL_STATIC);
		return TCL_ERROR;
	}

	if (ppv == NULL) {
		Tcl_SetResult(interp, "ppv is NULL", TCL_STATIC);
		return TCL_ERROR;
	}
	if (ppv->pdlg.hDC == NULL) {
		Tcl_SetResult(interp, "ppv->pdlg.hDC is NULL", TCL_STATIC);
		return TCL_ERROR;
	}


	hsize = GetDeviceCaps(ppv->pdlg.hDC, PHYSICALWIDTH);
	vsize = GetDeviceCaps(ppv->pdlg.hDC, PHYSICALHEIGHT);
	hoffset = GetDeviceCaps (ppv->pdlg.hDC, PHYSICALOFFSETX);
	voffset = GetDeviceCaps (ppv->pdlg.hDC, PHYSICALOFFSETY);

	w = atoi(argv[0]);
	h = atoi(argv[1]);

//sprintf(msgbuf,"page=%d,%d  device=%d,%d-%d,%d",w,h, hsize,vsize,hoffset,voffset);
//MessageBox(NULL, msgbuf, "Information",MB_ICONSTOP | MB_OK | MB_TASKMODAL | MB_SETFOREGROUND);


	SetMapMode(ppv->pdlg.hDC, MM_ANISOTROPIC);
	SetWindowExtEx(ppv->pdlg.hDC, w, h, NULL);
	SetViewportExtEx(ppv->pdlg.hDC, hsize, vsize, NULL);
	SetViewportOrgEx(ppv->pdlg.hDC, -hoffset, -voffset, NULL);


	Tcl_SetResult(interp, "page size set", TCL_STATIC);
	return TCL_OK;
}
