/****************************************************************
**  Tcl Extension for Windows
**  RCS Version $Revision: 1.30 $
**  RCS Last Change Date: $Date: 1999/03/08 04:56:22 $
**  Original Author: Michael I. Schwartz, mschwart@nyx.net
**  
**  {LICENSE}
**  
**  THIS SOFTWARE IS PROVIDED BY THE AUTHOR WITH PERMISSION TO USE, COPY, MODIFY, AND
**  DISTRIBUTE IT FOR ANY PURPOSE WITH THE FOLLOWING CONDITIONS:
**  1) IN SOURCE FORM, THIS HEADER MUST BE PRESERVED AND THESE CONDITIONS PROPOGATED
**  2) IN BINARY FORM, THE ORIGINAL AUTHOR MUST BE ACKNOWLEDGED IN DOCUMENTATION AND
**     CREDITS SCREEN (IF ANY)
**  3) FOR ANY COMMERCIAL SALE, THE AUTHOR MUST BE NOTIFIED OF THE USE OF THIS CODE
**     IN A PARTICULAR PRODUCT; THE ORIGINAL AUTHOR MAY CITE 
**     THE COMMERCIAL SELLER AS A BENEFICIARY OF THE CODE.
**  
**  
**  IN NO EVENT SHALL THE AUTHOR BE LIABLE TO ANY PARTY FOR DIRECT,
**  INDIRECT, SPECIAL, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING OUT OF
**  THE USE OF THIS SOFTWARE, ITS DOCUMENTATION,  OR ANY DERIVATIVES
**  THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF
**  SUCH DAMAGE.
**  
**  THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
**  INCLUDING, BUT NOT LIMITED TO,  THE IMPLIED WARRANTIES OF
**  MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. 
**  THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND
**  DISTRIBUTORS HAVE NO OBLIGATION  TO PROVIDE MAINTENANCE, SUPPORT,
**  UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
**
**  FUNCTIONS MARKED WITH MICROSOFT COPYRIGHT WERE LARGELY BASED ON THE
**  WINCAP32 EXAMPLE PROVIDED WITH MSVC++ 5.0.
**
**  {SYNOPSIS}
**  
**  This file contains commands to extend TK for Windows 3.11, Windows 95,
**  and Windows NT 4.0 features
**  
**  The commands are:
**  
**  gdi
**  
**  The details of each command's options follow:
**  
**  {GDI}
**  
**  The GDI command is a small, experimental extension for allowing direct 
**  access to a subset of Windows drawing routines. The subset selected has
**  the nature that it maps to postscript nicely in case of Unix 
**  implementation.
**  
**  Several models for preparing such an extension are available.
**  X windows provides a drawing model, Windows provides a drawing model,
**  and Tk canvases provide a drawing model.
**  
**  The original purpose of the extension was to test the printer extension.
**  
**  As these ideas have matured, it seems more useful to have a Tk model 
**  rather than a postscript model of printing. The first "real" revision of 
**  this package is likely to support many of the canvas techniques.
**  
**  The initial canvas emulation code has gone in. I am still looking to see 
**  if there is an easy way to grab a copy of, or modify, the existing 
**  canvas code so that many other special cases will be taken care of.
**  
**  GENERAL LIMITATION:
**  
**  While the extension has been provided for Tcl7.5 and Tcl7.6, the 
**  font command options will be unlikely to work correctly for these
**  versions, and no great effort is likely to go into doing so.
**  If anyone wishes to correct this and send the fix to the author, though,
**  I will be happy to incorporate it.
**  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
**  
**  gdi arc hdc x1 y1 x2 y2 -extent degrees -fill color -outline color 
**  	                -outlinestipple bitmap -start degrees -stipple bitmap 
**  		        -style [pieslice|chord|arc] -width linewid
**   DESCRIPTION:
**     Draws an arc just like on a canvas
**   LIMITATIONS:
**     -outlinestipple, and -stipple have no effect.
**  
**  gdi bitmap hdc x y -anchor [center|n|e|s|w] -background color 
**  		   -bitmap bitmap -foreground color
**    Not implemented yet
**  
**  gdi copybits hdc [-window w|-screen] [-client] [-source "a b c d"]
**                   [-destination "a b c d"] -scale number
**   DESCRIPTION:
**      Copies a window, client area of a window, or the entire screen to 
**      the destination hdc.
**   ARGUMENTS:
**      hdc    Handle to destination device context (e.g., printer)
**      window The window to copy. This can be in one of two forms
**             Numeric: This will be taken to represent an HWND
**             Tk window: This will be taken as a Tk path in the given interpreter.
**             If not provided, the current application main window is used.
**      screen This will copy the entire screen. This is not the default.
**             If -window and -screen are both used, an error results
**      client This will modify -window to include only the client area of the window.
**             It has no effect if -screen is specified.
**      source The list of up to four components represent:
**             a   x coordinate within the selected window to start copy at
**             b   y coordinate within the selected window to start copy at
**             c   x extent to copy (limited to width of window)
**             d   y extent to copy (limited to height of window)
**         If -source is used, at least a and b must be provided.
**         If -source is not present, the entire window is copied.
**         If c is not provided, copy stops at the right of the window
**         If d is not provided, copy stops at the bottom of the window
**      destination  The list of up to four components represent:
**             a   x coordinate within the destination HDC for upper left corner
**             b   y coordinate within the destination HDC for upper left corner
**             c   x extent for the copied image
**             d   y extent for the copied image
**         If -destination is provided, at least a and b must be provided.
**         If -destination is not provided, the image goes to the upper left of the
**         destination HDC.
**         If c is not provided, the image is not stretched (see -scale)
**         If d is not provided, the image is stretched vertically the same as horizonatally
**      scale  The argument to -scale is a floating point number representing the
**           scale factor to apply in converting the source to the destination.
**           That is, 2.0 means to double the size on the destination, and 0.5 means
**           shrink it to 50% of the number of pixels at the destination.
**    LIMITATIONS:
**     For some postscript printers this can be excruciatingly slow.
**     Some printers probably do not support BitBlt, and thus will
**     not support this function.
**     This function does not consider "banding" for the printer
**  
**  gdi characters hdc [-font fontspec] [-array arrayname]
**    DESCRIPTION:
**      Creates an array of character widths in device coordinates
**      for the currently selected or the specified font.
**      Saves the result in the array GdiCharWidths, indexed by the
**      character (including non-printable characters). If a different
**      global array is desired, use the -array specifier.
**    LIMITATIONS:
**      Assumes 256 characters per font.
**  
**  gdi image hdc x y -anchor [center|n|e|s|w] -image name
**    Not implemented yet
**  
**  gdi line hdc x1 y1 ... xn yn -arrow [first|last|both|none] -arrowshape {d1 d2 d3} 
**  		     	     -capstyle [butt|projecting|round] -fill color 
**  		     	     -joinstyle [bevel|miter|round] -smooth [true|false] 
**  		     	     -splinesteps number -stipple bitmap -width linewid
**   DESCRIPTION:
**     Draws a line just like on a canvas
**   LIMITATIONS:
**     Only -fill and -width are honored
**  
**  gdi map hdc [-logical x[y]] [-physical x[y]] [-offset {x y}] [-default] [-mode mode]
**    DESCRIPTION:
**      Changes the mapping mode for the device context 
**      Uses ISOTROPIC mode if only x is provided for physical and logical,
**      uses ANISOTROPIC mode if both are provided.
**      Also a linear offset is provided, and the ability to select an 
**      enumerated or numeric mode. The enumerated names are the same as the
**      Windows interface names (e.g., MM_HIENGLISH).
**      Return value is a set of pairs describing the current transformation.
**    LIMITATIONS:
**      Windows only allows translations and scaling. Rotation is not supported.
**  
**  gdi oval hdc x1 y1 x2 y2 -fill color -outline color -stipple bitmap -width linewid
**   DESCRIPTION:
**     Draws an oval just like on a canvas
**   LIMITATIONS:
**     -stipple is not implemented
**  
**  gdi polygon hdc x1 y1 ... xn yn -fill color -outline color -smooth [true|false] 
**  				-splinesteps number -stipple bitmap -width linewid
**   DESCRIPTION:
**     Draws a polygon just like on a canvas
**   LIMITATIONS:
**     -smooth, -splinesteps, and -stipple are not implemented
**  
**  gdi rectangle hdc x1 y1 x2 y2 -fill color -outline color 
**  		              -stipple bitmap -width linewid
**   DESCRIPTION:
**     Draws a rectangle just like on a canvas
**   LIMITATIONS:
**     -stipple is not implemented
**  
**  gdi text hdc x y -anchor [center|n|e|s|w] -fill color -font fontname 
**  		 -justify [left|right|center] -stipple bitmap -text string -width linelen
**   DESCRIPTION:
**     Draws text just like on a canvas
**   RETURNS:
**     Height of the output text block
**   LIMITATIONS:
**     Only the -anchor, -justify, -text, -fill, and -width flags are fully 
**     honored.
**     The -font flag is honored in a very limited way -- "fontname size style" triples.
**     The "normal" -width seems to be broken as yet.
**  
**  gdi version
**   DESCRIPTION:
**     Returns the current version number of the extension
**   LIMITATIONS:
**     None
**  
** Note: This is a work in progress. Please coordinate changes with
** the original author.
**
** Change for copymain from BitBlt to DIBBits provided by Roger Schneider (roger@prs.de)
** and Heiko Schock (heiko@prs.de).
**
** RCS Change summaries:
**  $Log: gdi.c $
 * Revision 1.30  1999/03/08  04:56:22  Michael_Schwartz
 * Updated ISOMETRIC mode to work properly
 *
 * Revision 1.29  1999/03/08  03:44:47  Michael_Schwartz
 * Align all mapping modes to proper scaling for pixels and points.
 * This should make the font mechanism work a lot like that of Tk
 * (without requiring Tk).
 *
 * Revision 1.28  1999/02/14  01:47:51  Michael_Schwartz
 * Moved test in copybits to after context is set.
 *
 * Revision 1.27  1998/12/15  03:56:41  Michael_Schwartz
 * Added missing semicolon
 *
 * Revision 1.26  1998/12/15  03:53:46  Michael_Schwartz
 * Add code to recover from a failure of the GetCharWidth32 function,
 * which has been reported by Andreas Sievers <Andreas.Sievers@t-mobil.de>
 * to occur under Windows 95
 *
 * Revision 1.25  1998/12/09  06:39:05  Michael_Schwartz
 * Added better reporting for changes in the mapping mode.
 *
 * Revision 1.24  1998/11/26  17:03:34  Michael_Schwartz
 * Removed deprecated functions
 * Modified description and comments in preparation for release
 *
 * Revision 1.23  1998/11/22  19:57:05  Michael_Schwartz
 * Consolidated comments, headers, and usage into the file
 *
 * Revision 1.22  1998/11/22  18:29:21  Michael_Schwartz
 * Moved in special handling for top-level windows (to get frame) and
 * added return value from copybits to reflect size at destination.
 *
 * Revision 1.21  1998/11/22  06:55:43  Michael_Schwartz
 * Changed assignments to remove all code warnings.
 *
 * Revision 1.20  1998/11/20  22:37:32  Michael_Schwartz
 * Added comments to improve readability.
 * Changed some local variables to float to support better scanning
 * of user input.
 *
 * Revision 1.19  1998/11/15  06:16:16  Michael_Schwartz
 * First attempt to incorporate work suggested by Arndt Roger Scheider
 * (roger@prs.de) and Heiko Schock (heiko@prs.de).
 * Added command "copybits" to go via DIBitmaps from the screen to the printer.
 * This should be more general a solution that the previous BitBlt.
 * Also, added long-awaited options to the command to copy a particular
 * window in the Tk heirarchy (instead of just the main application window),
 * to take just a part of a window, and to place the bits at a desired location
 * in the destination window.
 *
 * Revision 1.18  1998/09/29  03:26:05  Michael_Schwartz
 * *** empty log message ***
 *
 * Revision 1.17  1998/06/08  05:09:35  Michael_Schwartz
 * Added mapping mode command to allow transformations of the coordinate
 * space for printing.
 * Landscape and portrait mode are a characteristic of the printer driver,
 * and thus can't be set through this interface (at least under Windows).
 *
 * Revision 1.16  1998/04/27  02:51:48  Michael_Schwartz
 * Fixed a typo for a usage message
 *
 * Revision 1.15  1998/04/26  19:42:35  Michael_Schwartz
 * Added characters width function
 *
 * Revision 1.14  1998/02/08  06:17:30  Michael_Schwartz
 * Updated to handle system colors properly
 *
 * Revision 1.13  1998/02/08  05:58:07  Michael_Schwartz
 * Changed algorithm for # colors to handle "short" cases better.
 *
 * Revision 1.12  1998/02/08  05:10:00  Michael_Schwartz
 * Added brushes to the commands that take them.
 * These are limited brushes--just solid colors
 *
 * Revision 1.11  1998/02/08  04:43:46  Michael_Schwartz
 * Added color to text items
 *
 * Revision 1.10  1998/02/08  04:34:43  Michael_Schwartz
 * Added line color handling for all geometric shapes
 *
 * Revision 1.9  1998/02/08  03:59:17  Michael_Schwartz
 * Added initial color information
 *
 * Revision 1.8  1998/02/06  06:53:58  Michael_Schwartz
 * Added Pen to allow width setting (no color or style yet)
 *
 * Revision 1.7  1997/10/27  04:04:19  Michael_Schwartz
 * Updated documentation, added fallback for older versions of Tcl
 * However, earlier versions do not make it easy to get the HWND;
 * it will need to be emulated or copied from Tcl8
 *
 * Revision 1.6  1997/10/21  06:01:05  Michael_Schwartz
 * Updated to include new "canvas-like" functionality, but without yet
 * removing the old "postscript operator-like" functionality.
 * Implemented GdiArc command except for fills, stipples, and colors.
 * Did not yet reuse canvas code, which is heavy on the storage maintenance
 * and interaction (e.g., tags) functionality.
 *
 * Revision 1.5  1997/09/29  04:27:06  Michael_Schwartz
 * Removed test code
 *
 * Revision 1.4  1997/09/28  05:19:32  Michael_Schwartz
 * Recovered from disk failure, removed test code
 *
 * Revision 1.1  1997/09/28  03:59:25  Michael_Schwartz
 * Initial revision
 *
 * Revision 1.3  1997/09/25  07:14:45  Michael_Schwartz
 * Added source notes and some "todo" items
 *
 * Revision 1.2  1997/09/25  07:13:02  Michael_Schwartz
 * Added BitBlt commands for dumping a raster and ArcTo.
 *
 * Revision 1.1  1997/09/02  02:40:01  Michael_Schwartz
 * Initial revision
 *
****************************************************************/
#include <tcl.h>
#include <windows.h>
#include <stdlib.h>
#include <math.h>
#include <tk.h>


#if defined(__WIN32__) || defined (__WIN32S__) || defined (WIN32S)
  #   if defined(_MSC_VER)
  #     include <wtypes.h> /* Ensure to include WINAPI definition */
  #     define EXPORT(a,b) __declspec(dllexport) a b
  #     define DllEntryPoint DllMain
  #     define strcmpi(l,r) stricmp(l,r)
  #     define strncmpi(l,r,c) strnicmp(l,r,c)
  #   else
  #     if defined(__BORLANDC__)
  #         define EXPORT(a,b) a _export b
  #     else
  #         define EXPORT(a,b) a b
  #     endif
  #   endif
#else
  #   error "Extension is only for Windows"
#endif

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

#if TCL_MAJOR_VERSION == 7 && TCL_MINOR_VERSION <= 6
  /* Under version 8.0, there is a nice function called Tk_GetHWND
  ** to do the real work..
  */

  /*
  ** Copy a piece of tkWinInt.h
  ** This is easier to deal with than including tkWinInt.h,
  ** though it does mean one has to check when compiling
  ** against a new version!
  */
  typedef struct {
    int type;
    HWND handle;
    void *winPtr; /* Really a TkWindow */
  } TkWinWindow, TkWinDrawable;

  #define Tk_GetHWND(w) (((TkWinWindow *)w)->handle)
  #define TkWinGetWrapperWindow(w) (((TkWinWindow *)w)->winPtr->wmInfoPtr->wrapper)
#else
  EXTERN EXPORT(HWND,Tk_GetHWND) _ANSI_ARGS_((Window window));
  EXTERN EXPORT(HWND,TkWinGetWrapperWindow) _ANSI_ARGS_((Window tkwin));
#endif



EXTERN EXPORT(int,Gdi_Init) (Tcl_Interp *interp);
EXTERN EXPORT(int,Gdi_SafeInit) (Tcl_Interp *interp);

/* Main dispatcher for commands */
static int gdi      (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
/* Main dispatcher for subcommands */
static int Gdi      (ClientData unused, Tcl_Interp *interp, int argc, char **argv);

/* Real functions */
static int GdiArc      (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int GdiBitmap   (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int GdiCharWidths (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int GdiImage    (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int GdiLine     (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int GdiOval     (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int GdiPolygon  (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int GdiRectangle(ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int GdiText     (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int Version     (ClientData unused, Tcl_Interp *interp, int argc, char **argv);

static int GdiMap      (ClientData unused, Tcl_Interp *interp, int argc, char **argv);
static int GdiCopyBits (ClientData unused, Tcl_Interp *interp, int argc, char **argv);

/* Local copies of similar routines elsewhere in Tcl/Tk */
static int GdiParseColor (const char *name, unsigned long *color);
static int GdiGetColor   (const char *name, unsigned long *color);

/* Helper functions */
static int GdiMakeLogFont(Tcl_Interp *interp, const char *str, LOGFONT *lf, HDC hDC);
static int GdiMakePen(Tcl_Interp *interp, int width, int style, unsigned long color,
                      LOGPEN *lf, HDC hDC, HGDIOBJ *oldPen);
static int GdiFreePen(Tcl_Interp *interp, HDC hDC, HGDIOBJ oldPen);
static int GdiMakeBrush (Tcl_Interp *interp, unsigned int style, unsigned long color,
                         long hatch, LOGBRUSH *lb, HDC hDC, HGDIOBJ *oldBrush);
static int GdiFreeBrush (Tcl_Interp *interp, HDC hDC, HGDIOBJ oldBrush);
static int GdiGetHdcInfo( HDC hdc, 
                          LPPOINT worigin, LPSIZE wextent, 
                          LPPOINT vorigin, LPSIZE vextent);

/* Helper functions for printing the window client area */
enum PrintType { PTWindow=0, PTClient=1, PTScreen=2 };
static HANDLE CopyToDIB ( HWND wnd, enum PrintType type );
static HBITMAP CopyScreenToBitmap(LPRECT lpRect);
static HANDLE BitmapToDIB (HBITMAP hb, HPALETTE hp);
static HANDLE CopyScreenToDIB(LPRECT lpRect);
static int DIBNumColors(LPBITMAPINFOHEADER lpDIB);
static int PalEntriesOnDevice(HDC hDC);
static HPALETTE GetSystemPalette(void);
static void GetDisplaySize (LONG *width, LONG *height);

static char usage_message[] = "gdi [arc|characters|copybits|line|map|oval|"
                              "polygon|rectangle|text|version]\n"
                              "\thdc parameters can be generated by the printer extension";
static char msgbuf[1024];

/****************************************************************
** This is the top-level routine for the GDI command
** It strips off the first word of the command (gdi) and
** sends the result to the switch
****************************************************************/
static int gdi  (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  if ( argc > 1 && strcmp(*argv, "gdi") == 0 )
  {
    argc--;
    argv++;
    return Gdi(unused, interp, argc, argv);
  }

  Tcl_SetResult (interp, usage_message, TCL_STATIC);
  return TCL_ERROR;
}

/****************
** To make the "subcommands" follow a standard convention,
** add them to this array. The first element is the subcommand
** name, and the second a standard Tcl command handler.
****************/
struct gdi_command
{
  char *command_string;
  int (*command) (ClientData, Tcl_Interp *, int, char **);
} gdi_commands[] =
{
  { "arc",        GdiArc },
  { "bitmap",     GdiBitmap },
  { "characters", GdiCharWidths },
  { "image",      GdiImage },
  { "line",       GdiLine },
  { "map",        GdiMap },
  { "oval",       GdiOval },
  { "polygon",    GdiPolygon },
  { "rectangle",  GdiRectangle },
  { "text",       GdiText },
  { "copybits",   GdiCopyBits },
  { "version",    Version },
  
};

/****************************************************************
** This is the GDI subcommand dispatcher
****************************************************************/
static int Gdi      (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  int i;

  for (i=0; i<sizeof(gdi_commands) / sizeof(struct gdi_command); i++)
    if ( strcmp (*argv, gdi_commands[i].command_string) == 0 )
      return (*gdi_commands[i].command)(unused, interp, argc-1, argv+1);

  Tcl_SetResult (interp, usage_message, TCL_STATIC);
  return TCL_ERROR;
}

/****************************************************************
** Arc command
** Create a standard "DrawFunc" to make this more workable....
****************************************************************/
#ifdef _MSC_VER
typedef BOOL (WINAPI *DrawFunc) (HDC, int, int, int, int, int, int, int, int); /* Arc, Chord, Pie */
#else
typedef BOOL WINAPI (*DrawFunc) (HDC, int, int, int, int, int, int, int, int); /* Arc, Chord, Pie */
#endif

static int GdiArc      (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  int x1, y1, x2, y2;
  int xr0, yr0, xr1, yr1;
  HDC hDC;
  char *strend;    /* for strtol() */
  double extent = 0.0 , start = 0.0 ;
  DrawFunc drawfunc;
  int width = 0;
  HPEN hPen;
  LOGPEN lpen;
  COLORREF linecolor=0, fillcolor=BS_NULL;
  int dolinecolor=0, dofillcolor=0;
  HBRUSH hBrush;
  LOGBRUSH lbrush;
  
  static char usage_message[] = "gdi arc hdc x1 y1 x2 y2 "
                                "-extent degrees "
				"-fill color -outline color "
				"-outlinestipple bitmap "
		                "-start degrees -stipple bitmap "
				"-style [pieslice|chord|arc] -width linewid";

  drawfunc = Pie;
  
  /* Verrrrrry simple for now... */
  if (argc >= 5)
  {
    hDC = (HDC)strtoul(argv[0], &strend, 0);
    x1 = atoi(argv[1]);
    y1 = atoi(argv[2]);
    x2 = atoi(argv[3]);
    y2 = atoi(argv[4]);
    if ( x1 > x2 ) { int x3 = x1; x1 = x2; x2 = x3; }
    if ( y1 > y2 ) { int y3 = y1; y1 = y2; y2 = y3; }
    argc -= 5;
    argv += 5;
    while ( argc >= 2 )
    {
      if ( strcmp (argv[0], "-extent") == 0 )
        extent = atof(argv[1]);
      else if ( strcmp (argv[0], "-start") == 0 )
        start  = atof(argv[1]);
      else if ( strcmp (argv[0], "-style") == 0 )
      {
        if ( strcmp (argv[1], "pieslice") == 0 )
          drawfunc = Pie;
        else if ( strcmp(argv[1], "arc") == 0 )
          drawfunc = Arc;
        else if ( strcmp(argv[1], "chord") == 0 )
          drawfunc = Chord;
      }
      /* Handle all args, even if we don't use them yet */
      else if ( strcmp(argv[0], "-fill") == 0 )
      {
        if ( GdiGetColor(argv[1], &fillcolor) )
          dofillcolor=1;
      }
      else if ( strcmp(argv[0], "-outline") == 0 )
      {
        if ( GdiGetColor(argv[1], &linecolor) )
          dolinecolor=1;
      }
      else if (strcmp(argv[0], "-outlinestipple") == 0 )
      {
      }
      else if (strcmp(argv[0], "-stipple") == 0 )
      {
      }
      else if (strcmp(argv[0], "-width") == 0 )
      {
        width = atoi(argv[1]);
      }
      argc -= 2;
      argv += 2;
    }
    xr0 = xr1 = ( x1 + x2 ) / 2;
    yr0 = yr1 = ( y1 + y2 ) / 2;
    xr0 += (int)(100.0 * cos( (start * 2.0 * 3.14159265) / 360.0 ) );
    yr0 += (int)(100.0 * sin( (start * 2.0 * 3.14159265) / 360.0 ) );
    xr1 += (int)(100.0 * cos( ((start+extent) * 2.0 * 3.14159265) / 360.0 ) );
    yr1 += (int)(100.0 * sin( ((start+extent) * 2.0 * 3.14159265) / 360.0 ) );

    if ( dofillcolor )
      GdiMakeBrush(interp, 0, fillcolor, 0, &lbrush, hDC, (HGDIOBJ *)&hBrush);
    if ( width || dolinecolor )
      GdiMakePen(interp, width, 0, linecolor, &lpen, hDC, (HGDIOBJ *)&hPen);
    (*drawfunc)(hDC, x1, y1, x2, y2, xr0, yr0, xr1, yr1);
    if ( width || dolinecolor )
      GdiFreePen(interp, hDC, hPen);
    if ( dofillcolor )
      GdiFreeBrush(interp, hDC, hBrush);

    return TCL_OK;
  }

  Tcl_SetResult(interp, usage_message, TCL_STATIC);
  return TCL_ERROR;
}

/****************************************************************
** Bitmap command
** Unimplemented for now.
****************************************************************/
static int GdiBitmap   (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  static char usage_message[] = "gdi bitmap hdc x y "
                                "-anchor [center|n|e|s|w] -background color "
		                "-bitmap bitmap -foreground color\n"
                                "Not implemented yet. Sorry!";

  /* Skip this for now.... */
  /* Should be based on common code with the copybits command */
  
  Tcl_SetResult(interp, usage_message, TCL_STATIC);
  return TCL_ERROR;
}

/****************************************************************
** Image command
** Unimplemented for now.
****************************************************************/
static int GdiImage    (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  static char usage_message[] = "gdi image hdc x y -anchor [center|n|e|s|w] -image name\n"
                                "Not implemented yet. Sorry!";

  /* Skip this for now.... */
  /* Should be based on common code with the copybits command */
  
  Tcl_SetResult(interp, usage_message, TCL_STATIC);
  /* Normally, usage results in TCL_ERROR--but wait til' it's implemented */
  return TCL_OK;
}

/****************************************************************
** Line command
****************************************************************/
static int GdiLine     (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  static char usage_message[] = "gdi line hdc x1 y1 ... xn yn "
                                "-arrow [first|last|both|none] -arrowshape {d1 d2 d3} "
		     	        "-capstyle [butt|projecting|round] -fill color "
		     	        "-joinstyle [bevel|miter|round] -smooth [true|false] "
		     	        "-splinesteps number -stipple bitmap -width linewid";
  char *strend;
  POINT *polypoints;
  int npoly;
  int x, y;
  HDC hDC;
  LOGPEN lpen;
  HPEN hPen;
  int width = 0;
  COLORREF linecolor = 0;
  int dolinecolor = 0;
  
  /* Verrrrrry simple for now... */
  if (argc >= 5)
  {
    hDC = (HDC)strtoul(argv[0], &strend, 0);

    if ( (polypoints = (POINT *)Tcl_Alloc(argc * sizeof(POINT))) == 0 )
    {
      Tcl_SetResult(interp, "Out of memory in GdiLine", TCL_STATIC);
      return TCL_ERROR;
    }
    polypoints[0].x = atoi(argv[1]);
    polypoints[0].y = atoi(argv[2]);
    polypoints[1].x = atoi(argv[3]);
    polypoints[1].y = atoi(argv[4]);
    argc -= 5;
    argv += 5;
    npoly = 2;
    
    while ( argc >= 2 )
    {
      /* Check for a number  */
      x = strtoul(argv[0], &strend, 0);
      if ( strend > argv[0] )
      {
        /* One number... */
        y = strtoul (argv[1], &strend, 0);
        if ( strend > argv[1] )
        {
          /* TWO numbers! */
          polypoints[npoly].x = x;
          polypoints[npoly].y = y;
          npoly++;
          argc-=2;
          argv+=2;
        }
        else
        {
          /* Only one number... Assume a usage error */
          Tcl_Free((void *)polypoints);
          Tcl_SetResult(interp, usage_message, TCL_STATIC);
          return TCL_ERROR;
        }
      }
      else
      {
        if ( strcmp(*argv, "-arrow") == 0 )
        {
          argv+=2;
          argc-=2;
        }
        else if ( strcmp(*argv, "-arrowshape") == 0 )
        {
          argv+=2;
          argc-=2;
        }
        else if ( strcmp(*argv, "-capstyle") == 0 )
        {
          argv+=2;
          argc-=2;
        }
        else if ( strcmp(*argv, "-fill") == 0 )
        {
          if ( GdiGetColor(argv[1], &linecolor) )
            dolinecolor = 1;
          argv+=2;
          argc-=2;
        }
        else if ( strcmp(*argv, "-joinstyle") == 0 )
        {
          argv+=2;
          argc-=2;
        }
        else if ( strcmp(*argv, "-smooth") == 0 )
        {
          argv+=2;
          argc-=2;
        }
        else if ( strcmp(*argv, "-splinesteps") == 0 )
        {
          argv+=2;
          argc-=2;
        }
        else if ( strcmp(*argv, "-stipple") == 0 )
        {
          argv+=2;
          argc-=2;
        }
        else if ( strcmp(*argv, "-width") == 0 )
        {
          width = atoi(argv[1]);
          argv+=2;
          argc-=2;
        }
        /* Check for arguments
        ** Most of the arguments affect the "Pen"
        */
      }
    }

    if (width || dolinecolor)
      GdiMakePen(interp, width, 0, linecolor, &lpen, hDC, (HGDIOBJ *)&hPen);
    Polyline(hDC, polypoints, npoly);
    if (width || dolinecolor)
      GdiFreePen(interp, hDC, hPen);
    
    Tcl_Free((void *)polypoints);
    
    return TCL_OK;
  }

  Tcl_SetResult(interp, usage_message, TCL_STATIC);
  return TCL_ERROR;
}

/****************************************************************
** Oval command
****************************************************************/
static int GdiOval     (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  static char usage_message[] = "gdi oval hdc x1 y1 x2 y2 -fill color -outline color "
                                "-stipple bitmap -width linewid";
  int x1, y1, x2, y2;
  HDC hDC;
  char *strend;
  LOGPEN lpen;
  HPEN hPen;
  int width=0;
  COLORREF linecolor = 0, fillcolor = 0;
  int dolinecolor = 0, dofillcolor = 0;
  HBRUSH hBrush;
  LOGBRUSH lbrush;
  
  /* Verrrrrry simple for now... */
  if (argc >= 5)
  {
    hDC = (HDC)strtoul(argv[0], &strend, 0);
    x1 = atoi(argv[1]);
    y1 = atoi(argv[2]);
    x2 = atoi(argv[3]);
    y2 = atoi(argv[4]);
    if ( x1 > x2 ) { int x3 = x1; x1 = x2; x2 = x3; }
    if ( y1 > y2 ) { int y3 = y1; y1 = y2; y2 = y3; }
    argc -= 5;
    argv += 5;

    while ( argc > 0 )
    {
      /* Now handle any other arguments that occur */
      if ( strcmp(argv[0], "-fill") == 0 )
      {
        if ( GdiGetColor(argv[1], &fillcolor) )
          dofillcolor = 1;
        argv+=2;
        argc-=2;
      }
      else if ( strcmp(argv[0], "-outline") == 0 )
      {
        if ( GdiGetColor(argv[1], &linecolor) )
          dolinecolor = 1;
        argv+=2;
        argc-=2;
      }
      else if ( strcmp(argv[0], "-stipple") == 0 )
      {
        argv+=2;
        argc-=2;
      }
      else if ( strcmp(argv[0], "-width") == 0 )
      {
        width = atoi(argv[1]);
        argv+=2;
        argc-=2;
      }
    }

    if (dofillcolor)
      GdiMakeBrush(interp, 0, fillcolor, 0, &lbrush, hDC, (HGDIOBJ *)&hBrush);
    if (width || dolinecolor)
      GdiMakePen(interp, width, 0, linecolor, &lpen, hDC, (HGDIOBJ *)&hPen);
    Ellipse (hDC, x1, y1, x2, y2);
    if (width || dolinecolor)
      GdiFreePen(interp, hDC, hPen);
    if (dofillcolor)
      GdiFreeBrush(interp, hDC, hBrush);
      
    return TCL_OK;
  }

  Tcl_SetResult(interp, usage_message, TCL_STATIC);
  return TCL_ERROR;
}

/****************************************************************
** Polygon command
****************************************************************/
static int GdiPolygon  (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  static char usage_message[] = "gdi polygon hdc x1 y1 ... xn yn "
                                "-fill color -outline color -smooth [true|false] "
				"-splinesteps number -stipple bitmap -width linewid";

  char *strend;
  POINT *polypoints;
  int npoly;
  int x, y;
  HDC hDC;
  LOGPEN lpen;
  HPEN hPen;
  int width = 0;
  COLORREF linecolor=0, fillcolor=BS_NULL;
  int dolinecolor=0, dofillcolor=0;
  LOGBRUSH lbrush;
  HBRUSH hBrush;
  
  /* Verrrrrry simple for now... */
  if (argc >= 5)
  {
    hDC = (HDC)strtoul(argv[0], &strend, 0);

    if ( (polypoints = (POINT *)Tcl_Alloc(argc * sizeof(POINT))) == 0 )
    {
      Tcl_SetResult(interp, "Out of memory in GdiLine", TCL_STATIC);
      return TCL_ERROR;
    }
    polypoints[0].x = atoi(argv[1]);
    polypoints[0].y = atoi(argv[2]);
    polypoints[1].x = atoi(argv[3]);
    polypoints[1].y = atoi(argv[4]);
    argc -= 5;
    argv += 5;
    npoly = 2;
    
    while ( argc >= 2 )
    {
      /* Check for a number  */
      x = strtoul(argv[0], &strend, 0);
      if ( strend > argv[0] )
      {
        /* One number... */
        y = strtoul (argv[1], &strend, 0);
        if ( strend > argv[1] )
        {
          /* TWO numbers! */
          polypoints[npoly].x = x;
          polypoints[npoly].y = y;
          npoly++;
          argc-=2;
          argv+=2;
        }
        else
        {
          /* Only one number... Assume a usage error */
          Tcl_Free((void *)polypoints);
          Tcl_SetResult(interp, usage_message, TCL_STATIC);
          return TCL_ERROR;
        }
      }
      else
      {
        if ( strcmp(argv[0], "-fill") == 0 )
        {
          if ( GdiGetColor(argv[1], &fillcolor) )
            dofillcolor = 1;
        }
        else if ( strcmp(argv[0], "-outline") == 0 )
        {
          if ( GdiGetColor(argv[1], &linecolor) )
            dolinecolor = 0;
        }
        else if (strcmp(argv[0], "-stipple") == 0 )
        {
        }
        else if (strcmp(argv[0], "-width") == 0 )
        {
          width = atoi(argv[1]);
        }
        argc -= 2;
        argv += 2;
        /* Check for arguments
        ** Most of the arguments affect the "Pen" and "Brush"
        */
      }
    }

    if (dofillcolor)
      GdiMakeBrush(interp, 0, fillcolor, 0, &lbrush, hDC, (HGDIOBJ *)&hBrush);
    if (width || dolinecolor)
      GdiMakePen(interp, width, 0, linecolor, &lpen, hDC, (HGDIOBJ *)&hPen);
    Polygon(hDC, polypoints, npoly);
    if (width || dolinecolor)
      GdiFreePen(interp, hDC, hPen);
    if (dofillcolor)
      GdiFreeBrush(interp, hDC, hBrush);
    
    Tcl_Free((void *)polypoints);
    
    return TCL_OK;
  }

  Tcl_SetResult(interp, usage_message, TCL_STATIC);
  return TCL_ERROR;
}

/****************************************************************
** Rectangle command
****************************************************************/
static int GdiRectangle(ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  static char usage_message[] = "gdi rectangle hdc x1 y1 x2 y2 "
                                "-fill color -outline color "
				"-stipple bitmap -width linewid";

  int x1, y1, x2, y2;
  HDC hDC;
  char *strend;
  LOGPEN lpen;
  HPEN hPen;
  int width = 0;
  COLORREF linecolor=0, fillcolor=BS_NULL;
  int dolinecolor=0, dofillcolor=0;
  LOGBRUSH lbrush;
  HBRUSH hBrush;
  
  /* Verrrrrry simple for now... */
  if (argc >= 5)
  {
    hDC = (HDC)strtoul(argv[0], &strend, 0);
    x1 = atoi(argv[1]);
    y1 = atoi(argv[2]);
    x2 = atoi(argv[3]);
    y2 = atoi(argv[4]);
    if ( x1 > x2 ) { int x3 = x1; x1 = x2; x2 = x3; }
    if ( y1 > y2 ) { int y3 = y1; y1 = y2; y2 = y3; }
    argc -= 5;
    argv += 5;
    
    /* Now handle any other arguments that occur */
    while (argc > 1)
    {
      if ( strcmp(argv[0], "-fill") == 0 ) 
      {
        if (GdiGetColor(argv[1], &fillcolor) )
          dofillcolor = 1;
      }
      else if ( strcmp(argv[0], "-outline") == 0) 
      {
        if (GdiGetColor(argv[1], &linecolor) )
          dolinecolor = 1;
      }
      else if ( strcmp(argv[0], "-stipple") == 0) 
      { 
      }
      else if ( strcmp(argv[0], "-width") == 0) 
      {
        width = atoi(argv[1]);
      }
      argc -= 2;
      argv += 2;
    }

    /* Note: If any fill is specified, the function must create a brush and
    ** put the coordinates in a RECTANGLE structure, and call FillRect.
    ** FillRect requires a BRUSH / color.
    ** If not, the function Rectangle must be called
    */
    if (dofillcolor)
      GdiMakeBrush(interp, 0, fillcolor, 0, &lbrush, hDC, (HGDIOBJ *)&hBrush);
	else
	  GdiMakeBrush(interp, -1, BS_NULL, 0, &lbrush, hDC, (HGDIOBJ *)&hBrush);

    if ( width || dolinecolor )
      GdiMakePen(interp, width, 0, linecolor, &lpen, hDC, (HGDIOBJ *)&hPen);
    Rectangle (hDC, x1, y1, x2, y2);
    if ( width || dolinecolor )
      GdiFreePen(interp, hDC, hPen);

    GdiFreeBrush(interp, hDC, hBrush);

    return TCL_OK;
  }

  Tcl_SetResult(interp, usage_message, TCL_STATIC);
  return TCL_ERROR;
}

/****************************************************************
** characters command
** Need some way to get accurate data on character widths.
** This is completely inadequate for typesetting, but should work
** for simple text manipulation.
****************************************************************/
static int GdiCharWidths (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  static char usage_message[] = "gdi characters hdc [-font fontname] [-array ary]";
  /* Returns widths of characters from font in an associative array
  ** Font is currently selected font for HDC if not specified
  ** Array name is GdiCharWidths if not specified
  ** Widths should be in the same measures as all other values (1/1000 inch).
  */
  HDC hDC;
  LOGFONT lf;
  HFONT hfont, oldfont;
  int made_font = 0;
  char *strend;
  char *aryvarname = "GdiCharWidths";
  /* For now, assume 256 characters in the font... */
  int widths[256];
  int retval;
  
  if ( argc < 1 )
  {
    Tcl_SetResult(interp, usage_message, TCL_STATIC);
    return TCL_ERROR;
  }

  hDC = (HDC)strtoul(argv[0], &strend, 0);
  argc--;
  argv++;

  while ( argc > 0 )
  {
    if ( strcmp(argv[0], "-font")  == 0 )
    {
      argc--;
      argv++;
      if ( GdiMakeLogFont(interp, argv[0], &lf, hDC) )
        if ( (hfont = CreateFontIndirect(&lf)) != NULL )
        {
          made_font = 1;
          oldfont = SelectObject(hDC, hfont);
        }
      /* Else leave the font alone! */
    }
    else if ( strcmp(argv[0], "-array") == 0 )
    {
      argv++;
      argc--;
      if ( argc > 0 )
      {
        aryvarname=argv[0];
      }
    }
    argv++;
    argc--;
  }  

  /* Now, get the widths using the correct function for this windows version */
#ifdef WIN32
  /* Try the correct function. If it fails (as has been reported on some
  ** versions of Windows 95), try the "old" function
  */
  if ( (retval = GetCharWidth32(hDC, 0, 255, widths)) == FALSE )
  {
    retval = GetCharWidth (hDC, 0, 255, widths );
  }
#else
  retval = GetCharWidth  (hDC, 0, 255, widths);
#endif
  /* Retval should be 1 (TRUE) if the function succeeded. If the function fails,
  ** get the "extended" error code and return. Be sure to deallocate the font if
  ** necessary.
  */
  if (retval == FALSE)
  {
    DWORD val = GetLastError();
    char intstr[12+1];
    sprintf (intstr, "%ld", val );
    Tcl_AppendResult (interp, "gdi character failed with code ", intstr, 0);
    if ( made_font )
    {
      SelectObject(hDC, oldfont);
      DeleteObject(hfont);
    }
    return TCL_ERROR;
  }
  
  {
    int i;
    char numbuf[11+1];
    char ind[2];
    ind[1] = '\0';
    
    for (i = 0; i < 255; i++ )
    {
      /* May need to convert the widths here(?) */
      sprintf(numbuf, "%d", widths[i]);
      ind[0] = i;
      Tcl_SetVar2(interp, aryvarname, ind, numbuf, TCL_GLOBAL_ONLY); 
    }
  }
  /* Now, remove the font if we created it only for this function */
  if ( made_font )
  {
    SelectObject(hDC, oldfont);
    DeleteObject(hfont);
  }

  /* The return value should be the array name(?) */
  Tcl_SetResult(interp, aryvarname, TCL_VOLATILE);
  return TCL_OK;
}

/****************************************************************
** Text command
****************************************************************/
static int GdiText     (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  static char usage_message[] = "gdi text hdc x y -anchor [center|n|e|s|w] "
                                "-fill color -font fontname "
		                "-justify [left|right|center] "
				"-stipple bitmap -text string -width linelen";

  HDC hDC;
  int x, y;
  char *string = 0;
  RECT sizerect;
  UINT format_flags = DT_EXPANDTABS|DT_NOPREFIX; /* Like the canvas */
  Tk_Anchor anchor = 0;
  char *strend;
  LOGFONT lf;
  HFONT hfont, oldfont;
  int   made_font = 0;
  int retval;
  int dotextcolor=0;
  COLORREF textcolor = 0;
  int usewidth=0;

  //---- for unicode support
  Tcl_DString tmp;
  char *unicode;
  //----


  if ( argc >= 4 )
  {
    /* Parse the command */
    hDC = (HDC)strtoul(argv[0], &strend, 0);
    x = atoi(argv[1]);
    y = atoi(argv[2]);
    argc -= 3;
    argv += 3;

    sizerect.left = sizerect.right = x;
    sizerect.top = sizerect.bottom = y;
    
    while ( argc > 0 )
    {
      if ( strcmp(argv[0], "-anchor") == 0 )
      {
        argc--;
        argv++;
        if (argc > 0 )
          Tk_GetAnchor(interp, argv[0], &anchor);
      }
      else if ( strcmp(argv[0], "-justify") == 0 )
      {
        argc--;
        argv++;
        if (argc > 0 )
        {
          if ( strcmp(argv[0], "left") == 0 )
            format_flags |= DT_LEFT;
          else if ( strcmp(argv[0], "center") == 0 )
            format_flags |= DT_CENTER;
          else if ( strcmp(argv[0], "right") == 0 )
            format_flags |= DT_RIGHT;
        }
      }
      else if ( strcmp(argv[0], "-text") == 0 )
      {
        argc--;
        argv++;
        if (argc > 0 )
          string = argv[0];
      }
      else if ( strcmp(argv[0], "-font")  == 0 )
      {
        argc--;
        argv++;
        if ( GdiMakeLogFont(interp, argv[0], &lf, hDC) )
          if ( (hfont = CreateFontIndirect(&lf)) != NULL )
          {
            made_font = 1;
            oldfont = SelectObject(hDC, hfont);
          }
        /* Else leave the font alone! */
      }
      else if ( strcmp(argv[0], "-stipple") == 0 )
      {
        argc--;
        argv++;
        /* Not implemented yet */
      } 
      else if ( strcmp(argv[0], "-fill") == 0 )
      {
        argc--;
        argv++;
        /* Get text color */
        if ( GdiGetColor(argv[0], &textcolor) )
          dotextcolor = 1;
      }
      else if ( strcmp(argv[0], "-width") == 0 )
      {
        argc--;
        argv++;
        if ( argc > 0 )
          sizerect.right += atoi(argv[0]);
        /* If a width is specified, break at words. */
        format_flags |= DT_WORDBREAK;
        usewidth = 1;
      }

      argc--;
      argv++;
    }

    if (string == 0 )
    {
      Tcl_SetResult(interp, usage_message, TCL_STATIC);
      return TCL_ERROR;
    }

    //---- for Unicode support
#ifdef USE_UNICODE
	unicode = Tcl_UtfToExternalDString(Tcl_GetEncoding(interp, "unicode"), string, -1, &tmp);
#else
//	{
//	CHARSETINFO charsetInfo;
//	char codepage[4 + TCL_INTEGER_SPACE];
//	extern Tcl_Encoding TkWinGetKeyInputEncoding();
//	wsprintfA(codepage, "cp%d", GetACP());
//MessageBox(NULL, codepage, "Codepage", MB_OK|MB_ICONSTOP);
//	unicode = Tcl_UtfToExternalDString(Tcl_GetEncoding(NULL, codepage), string, -1, &tmp);
//	}
	unicode = Tcl_UtfToExternalDString(NULL, string, -1, &tmp);
#endif
	//----


    /* Set the format flags */
    if ( usewidth == 0 )
      format_flags |= DT_SINGLELINE;

    /* Calculate the rectangle */
#ifdef USE_UNICODE
    DrawTextW (hDC, unicode, -1, &sizerect, format_flags | DT_CALCRECT);
#else
    DrawTextA (hDC, unicode, -1, &sizerect, format_flags | DT_CALCRECT);
#endif

    /* Adjust the rectangle according to the anchor */
    x = y = 0;
    switch ( anchor )
    {
      case TK_ANCHOR_N:
        x = ( sizerect.right - sizerect.left  ) / 2;
        break;
      case TK_ANCHOR_S:
        x = ( sizerect.right - sizerect.left  ) / 2;
        y = ( sizerect.bottom - sizerect.top );
        break;
      case TK_ANCHOR_E:
        x = ( sizerect.right - sizerect.left  );
        y = ( sizerect.bottom - sizerect.top ) / 2;
        break;
      case TK_ANCHOR_W:
        y = ( sizerect.bottom - sizerect.top ) / 2;
        break;
      case TK_ANCHOR_NE:
        x = ( sizerect.right - sizerect.left  );
        break;
      case TK_ANCHOR_NW:
        break;
      case TK_ANCHOR_SE:
        x = ( sizerect.right - sizerect.left  );
        y = ( sizerect.bottom - sizerect.top );
        break;
      case TK_ANCHOR_SW:
        y = ( sizerect.bottom - sizerect.top );
        break;
      case TK_ANCHOR_CENTER:
        x = ( sizerect.right - sizerect.left  ) / 2;
        y = ( sizerect.bottom - sizerect.top ) / 2;
        break;
    }
    sizerect.right  -= x;
    sizerect.left   -= x;
    sizerect.top    -= y;
    sizerect.bottom -= y;

    /* Get the color right */
    if ( dotextcolor )
      textcolor = SetTextColor(hDC, textcolor);

    /* Print the text */
	{int bg = SetBkMode(hDC, TRANSPARENT);
#ifdef USE_UNICODE
    retval = DrawTextW (hDC, unicode, -1, &sizerect, format_flags);
#else
    retval = DrawTextA (hDC, unicode, -1, &sizerect, format_flags);
#endif
	if (bg) SetBkMode(hDC, bg);
	}

    /* Get the color set back */
    if ( dotextcolor )
      textcolor = SetTextColor(hDC, textcolor);

    if (made_font)
    {
      SelectObject(hDC, oldfont);
      DeleteObject(hfont);
    }


	//---- unicode support - cleanup
	Tcl_DStringFree(&tmp);

    /* In this case, the return value is the height of the text */
    sprintf(msgbuf, "%d usefont %d size %d font %d oldfont %d", retval, made_font,lf.lfHeight, hfont, oldfont);
    Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
    
    return TCL_OK;
  }
  
  Tcl_SetResult(interp, usage_message, TCL_STATIC);
  return TCL_ERROR;
}

/****************************************************************
** GdiGetHdcInfo
** Return salient characteristics of the CTM.
** The return value is 0 if any failure occurs--in which case
** none of the other values are meaningful.
** Otherwise the return value is the current mapping mode
** (this may be VERY windows-specific).
****************************************************************/
static int GdiGetHdcInfo( HDC hdc, 
                          LPPOINT worigin, LPSIZE wextent, 
                          LPPOINT vorigin, LPSIZE vextent)
{
  int mapmode;
  int retval;

  memset (worigin, 0, sizeof(POINT));    
  memset (vorigin, 0, sizeof(POINT));
  memset (wextent, 0, sizeof(SIZE));
  memset (vextent, 0, sizeof(SIZE));
  
  if ( (mapmode = GetMapMode(hdc)) == 0 )
  {
    /* Failed! */
    retval=0;
  }
  else
    retval = mapmode;

  if ( GetWindowExtEx(hdc, wextent) == FALSE )
  {
    /* Failed! */
    retval = 0;
  }
  if ( GetViewportExtEx (hdc, vextent) == FALSE )
  {
    /* Failed! */
    retval = 0;
  }
  if ( GetWindowOrgEx(hdc, worigin) == FALSE )
  {
    /* Failed! */
    retval = 0;
  }
  if ( GetViewportOrgEx(hdc, vorigin) == FALSE )
  {
    /* Failed! */
    retval = 0;
  }
  
  return retval;
}

/****************************************************************
** Converts Windows mapping mode names to values in the .h
****************************************************************/
static int GdiNameToMode(const char *name)
{
  static struct gdimodes {
    int mode;
    const char *name;
  } modes[] = {
    { MM_ANISOTROPIC, "MM_ANISOTROPIC" },
    { MM_HIENGLISH,   "MM_HIENGLISH" },
    { MM_HIMETRIC,    "MM_HIMETRIC" },
    { MM_ISOTROPIC,   "MM_ISOTROPIC" },
    { MM_LOENGLISH,   "MM_LOENGLISH" },
    { MM_LOMETRIC,    "MM_LOMETRIC" },
    { MM_TEXT,        "MM_TEXT" },
    { MM_TWIPS,       "MM_TWIPS" }
  };

  int i;
  for (i=0; i < sizeof(modes) / sizeof(struct gdimodes); i++)
  {
    if ( strcmp(modes[i].name, name) == 0 )
      return modes[i].mode;
  }
  return atoi(name);
}

/****************************************************************
** Mode to Name converts the mode number to a printable form
****************************************************************/
static const char *GdiModeToName(int mode)
{
  static struct gdi_modes {
    int mode;
    const char *name;
  } modes[] = {
    { MM_ANISOTROPIC, "Anisotropic" },
    { MM_HIENGLISH,   "1/1000 inch" },
    { MM_HIMETRIC,    "1/100 mm" },
    { MM_ISOTROPIC,   "Isotropic" },
    { MM_LOENGLISH,   "1/100 inch" },
    { MM_LOMETRIC,    "1/10 mm" },
    { MM_TEXT,        "1 to 1" },
    { MM_TWIPS,       "1/1440 inch" }
  };

  int i;
  for (i=0; i < sizeof(modes) / sizeof(struct gdi_modes); i++)
  {
    if ( modes[i].mode == mode )
      return modes[i].name;
  }
  return "Unknown";
}

/****************************************************************
** GdiMap -
** Set mapping mode between logical and physical device space
** Syntax for this is intended to be more-or-less independent of
** Windows/Mac/X--that is, equally difficult to use with each.
** Alternative:
** Possibly this could be a feature of the HDC extension itself?
****************************************************************/
static int GdiMap      (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  static char usage_message[] = "gdi map hdc "
                                "[-logical x[y]] [-physical x[y]] "
                                "[-offset {x y} ] [-default] [-mode mode]"
				;
  HDC hdc;
  char *strend;
  int mapmode;    /* Mapping mode */
  SIZE wextent;   /* Device extent */
  SIZE vextent;   /* Viewport extent */
  POINT worigin;  /* Device origin */
  POINT vorigin;  /* Viewport origin */
  int argno;

  /* Keep track of what parts of the function need to be executed */
  int need_usage   = 0;
  int use_logical  = 0;
  int use_physical = 0;
  int use_offset   = 0;
  int use_default  = 0;
  int use_mode     = 0;
  
  /* Required parameter: HDC for printer */
  if ( argc >= 1 )
  {
    hdc = (HDC)strtoul(argv[0], &strend, 0);
    if ( (mapmode = GdiGetHdcInfo(hdc, &worigin, &wextent, &vorigin, &vextent)) == 0 )
    {
      /* Failed! */
      Tcl_SetResult(interp, "Cannot get current HDC info", TCL_STATIC);
      return TCL_ERROR;
    }
    
    /* Parse remaining arguments */
    for (argno = 1; argno < argc; argno++)
    {
      if ( strcmp(argv[argno], "-default") == 0 )
      {
        vextent.cx = vextent.cy = wextent.cx = wextent.cy = 1;
        vorigin.x = vorigin.y = worigin.x = worigin.y = 0;
        mapmode = MM_TEXT;
        use_default = 1;
      }
      else if ( strcmp (argv[argno], "-mode" ) == 0 )
      {
        if ( argno + 1 >= argc )
          need_usage = 1;
        else
        {
          mapmode = GdiNameToMode(argv[argno+1]);
          use_mode = 1;
          argno++;
        }
      }
      else if ( strcmp (argv[argno], "-offset") == 0 )
      {
        if (argno + 1 >= argc)
          need_usage = 1;
        else
        {
          /* It would be nice if this parsed units as well... */
          if ( sscanf(argv[argno+1], "%ld%ld", &vorigin.x, &vorigin.y) == 2 )
            use_offset = 1;
          else
            need_usage = 1;
          argno ++;
        }
      }
      else if ( strcmp (argv[argno], "-logical") == 0 )
      {
        if ( argno+1 >= argc)
          need_usage = 1;
        else
        {
          int count;
          /* In "real-life", this should parse units as well. */
          if ( (count = sscanf(argv[argno+1], "%ld%ld", &wextent.cx, &wextent.cy)) != 2 )
          {
            if ( count == 1 )
            {
              mapmode = MM_ISOTROPIC;
              use_logical = 1;
              wextent.cy = wextent.cx;  /* Make them the same */
            }
            else
              need_usage = 1;
          }
          else
          {
            mapmode = MM_ANISOTROPIC;
            use_logical = 2;
          }
        }
      }
      else if ( strcmp (argv[argno], "-physical") == 0 )
      {
        if ( argno+1 >= argc)
          need_usage = 1;
        else
        {
          int count;
          /* In "real-life", this should parse units as well. */
          if ( (count = sscanf(argv[argno+1], "%ld%ld", &vextent.cx, &vextent.cy)) != 2 )
          {
            if ( count == 1 )
            {
              mapmode = MM_ISOTROPIC;
              use_physical = 1;
              vextent.cy = vextent.cx;  /* Make them the same */
            }
            else
              need_usage = 1;
          }
          else
          {
            mapmode = MM_ANISOTROPIC;
            use_physical = 2;
          }
        }
      }
    }

    /* Check for any impossible combinations */
    if ( use_logical != use_physical )
      need_usage = 1;
    if ( use_default && (use_logical || use_offset || use_mode ) )
      need_usage = 1;
    if ( use_mode && use_logical )
      need_usage = 1;
      
    if ( need_usage == 0 )
    {
      /* Call Windows CTM functions */
      if ( use_logical || use_default || use_mode )  /* Don't call for offset only */
      {
        SetMapMode(hdc, mapmode);
      }
      
      if ( use_offset || use_default )
      {
        POINT oldorg;
        SetViewportOrgEx (hdc, -vorigin.x, -vorigin.y, &oldorg);
        SetWindowOrgEx   (hdc, -worigin.x, -worigin.y, &oldorg);
      }

      if ( use_logical )  /* Same as use_physical */
      {
        SIZE oldsiz;
        SetWindowExtEx   (hdc, wextent.cx, wextent.cy, &oldsiz);
        SetViewportExtEx (hdc, vextent.cx, vextent.cy, &oldsiz);
      }

      /* Since we may not have set up every parameter, get them again for
      ** the report:
      */
      mapmode = GdiGetHdcInfo(hdc, &worigin, &wextent, &vorigin, &vextent);
      
      /* Output current CTM info */
      /* Note: This should really be in terms that can be used in a gdi map command! */
      sprintf(msgbuf, "Transform: \"(%ld, %ld) -> (%ld, %ld)\" "
                      "Origin: \"(%ld, %ld)\" "
                      "MappingMode: \"%s\"",
                      vextent.cx, vextent.cy, wextent.cx, wextent.cy,
		      vorigin.x, vorigin.y,
		      GdiModeToName(mapmode));
      Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
      return TCL_OK;
    }
  }

  Tcl_SetResult(interp, usage_message, TCL_STATIC);
  return TCL_ERROR;
}

/****************************************************************
** GdiCopyBits
****************************************************************/
static int GdiCopyBits (ClientData unused, Tcl_Interp *interp, int argc, char **argv)
{
  /* Goal: get the Tk_Window from the top-level
           convert it to an HWND
           get the HDC
           Do a bitblt to the given hdc
           Use an optional parameter to point to an arbitrary window instead of the main
           Use optional parameters to map to the width and height required for the dest.
  */
  static char usage_message[] = "gdi copybits hdc [-window w|-screen] [-client] "
                                "[-source \"a b c d\"] "
                                "[-destination \"a b c d\"] [-scale number]";
  
  Tk_Window mainWin;
  Tk_Window workwin;
  Window w;
  HDC src;
  HDC dst;
  HWND wnd = 0;

  HANDLE hDib;    /* handle for device-independent bitmap */
  LPBITMAPINFOHEADER lpDIBHdr;
  LPSTR lpBits;
  enum PrintType wintype = PTWindow;
  
  int hgt, wid;
  char *strend;
  long errcode;

  /* Variables to remember what we saw in the arguments */
  int do_window=0;
  int do_screen=0;
  int do_scale=0;
  /* Variables to remember the values in the arguments */
  char *window_spec;
  double scale=0.0;
  int src_x=0, src_y=0, src_w=0, src_h=0;
  int dst_x=0, dst_y=0, dst_w=0, dst_h=0;
  int is_toplevel = 0;
  
  /****************************************************************
  ** The following steps are peculiar to the top level window.
  ** There is likely a clever way to do the mapping of a
  ** widget pathname to the proper window, to support the idea of
  ** using a parameter for this purpose.
  ****************************************************************/
  if ( (workwin = mainWin = Tk_MainWindow(interp)) == 0 )
  {
    Tcl_SetResult(interp, "Can't find main Tk window", TCL_STATIC);
    return TCL_ERROR;
  }

  /*****************************************************************
  **   Parse the arguments.
  ****************************************************************/
  /* HDC is required */
  if ( argc < 1 )
  {
    Tcl_SetResult(interp, usage_message, TCL_STATIC);
    return TCL_ERROR;
  }
  /* Use strtoul() so octal or hex representations will be parsed */
  dst = (HDC)strtoul(argv[0], &strend, 0);

  /****************************************************************
  ** Next, check to see if 'dst' can support BitBlt.
  ** If not, raise an error
  ****************************************************************/
  if ( GetDeviceCaps (dst, RASTERCAPS) & RC_BITBLT == 0 )
  {
    sprintf(msgbuf, "Can't do bitmap operations on device context (0x%lx)", dst);
    Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
    return TCL_ERROR;      
  }

  /* Loop through the remaining arguments */
  {
    int k;
    for (k=1; k<argc; k++)
    {
      if ( strcmp(argv[k], "-window") == 0 )
      {
        if (argv[k+1] && argv[k+1][0] == '.')
        {
          do_window = 1;
          workwin = Tk_NameToWindow(interp, window_spec = argv[++k], mainWin);
          if ( workwin == NULL )
          {
            sprintf(msgbuf, "Can't find window %s in this application", window_spec);
            Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
            return TCL_ERROR;
          }
        }
        else
        {
          /* Use strtoul() so octal or hex representations will be parsed */
          wnd = (HWND)strtoul(argv[++k], &strend, 0);
          if ( strend == 0 || strend == argv[k] )
          {
            sprintf(msgbuf, "Can't understand window id %s", argv[k]);
            Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
            return TCL_ERROR;
          }
        }
      }
      else if ( strcmp(argv[k], "-screen") == 0 )
      {
        do_screen = 1;
        wintype = PTScreen;
      }
      else if ( strcmp(argv[k], "-client") == 0 )
      {
        wintype = PTClient;
      }
      else if ( strcmp(argv[k], "-source") == 0 )
      {
        float a, b, c, d;
        int count;
        count = sscanf(argv[++k], "%f%f%f%f", &a, &b, &c, &d);
        if ( count < 2 ) /* Can't make heads or tails of it... */
        {
          Tcl_SetResult(interp, usage_message, TCL_STATIC);
          return TCL_ERROR;
        }
        else
        {
          src_x = (int)a;
          src_y = (int)b;
          if ( count == 4 )
          {
            src_w = (int)c;
            src_h = (int)d;
          }
        }
      }
      else if ( strcmp(argv[k], "-destination") == 0 )
      {
        float a, b, c, d;
	int count;

        count = sscanf(argv[++k], "%f%f%f%f", &a, &b, &c, &d);
        if ( count < 2 ) /* Can't make heads or tails of it... */
        {
          Tcl_SetResult(interp, usage_message, TCL_STATIC);
          return TCL_ERROR;
        }
        else
        {
          dst_x = (int)a;
          dst_y = (int)b;
          if ( count == 3 )
          {
            dst_w = (int)c;
            dst_h = -1;
          }
          if ( count == 4 )
          {
            dst_w = (int)c;
            dst_h = (int)d;
          }
        }
      }
      else if ( strcmp(argv[k], "-scale") == 0 )
      {
        if ( argv[++k] )
        {
          scale = strtod(argv[k], &strend);
          if ( strend == 0 || strend == argv[k] )
          {
            sprintf(msgbuf, "Can't understand scale specification %s", argv[k]);
            Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
            return TCL_ERROR;
          }
        }
      }
    }
  }

  /****************************************************************
  ** Check to ensure no incompatible arguments were used
  ****************************************************************/
  if ( do_window && do_screen )
  {
    Tcl_SetResult(interp, usage_message, TCL_STATIC);
    return TCL_ERROR;
  }
  
  /*****************************************************************
  ** Get the MS Window we want to copy.
  *****************************************************************/
  /* Given the HDC, we can get the "Window" */
  if (wnd == 0 )
  {
    if ( Tk_IsTopLevel(workwin) )
      is_toplevel = 1;
      
    if ( (w =    Tk_WindowId(workwin)) == 0 )
    {
      Tcl_SetResult(interp, "Can't get id for Tk window", TCL_STATIC);
      return TCL_ERROR;
    }

    /* Given the "Window" we can get a Microsoft Windows HWND */

    if ( (wnd =  Tk_GetHWND(w)) == 0 )
    {
      Tcl_SetResult(interp, "Can't get Windows handle for Tk window", TCL_STATIC);
      return TCL_ERROR;
    }

    /* If it's a toplevel, give it special treatment: Get the top-level window instead.
    ** If the user only wanted the client, the -client flag will take care of it.
    ** This uses "windows" tricks rather than Tk since the obvious method of
    ** getting the wrapper window didn't seem to work.
    */
    if ( is_toplevel )
    {
      HWND tmpWnd = wnd;
      while ( (tmpWnd = GetParent( tmpWnd ) ) != 0 ) 
        wnd = tmpWnd;
    }
  }
  
  /* Given the HWND, we can get the window's device context */
  if ( (src =  GetWindowDC(wnd)) == 0 )
  {
    Tcl_SetResult(interp, "Can't get device context for Tk window", TCL_STATIC);
    return TCL_ERROR;
  }

  if ( do_screen )
  {
    LONG w, h;
    GetDisplaySize(&w, &h);
    wid = w;
    hgt = h;
  }
  else if ( is_toplevel )
  {
    RECT tl;
    GetWindowRect(wnd, &tl);
    wid = tl.right - tl.left;
    hgt = tl.bottom - tl.top;
  }
  else
  {
    if ( (hgt =  Tk_Height(workwin)) <= 0 )
    {
      Tcl_SetResult(interp, "Can't get height of Tk window", TCL_STATIC);
      return TCL_ERROR;
    }
    
    if ( (wid =  Tk_Width(workwin)) <= 0 )
    {
      Tcl_SetResult(interp, "Can't get width of Tk window", TCL_STATIC);
      return TCL_ERROR;
    }
  }

  if ( do_scale && dst_w == 0 )
  {
    /* Calculate destination width and height based on scale */
    dst_w = (int)(scale * src_w);
    dst_h = (int)(scale * src_h);
  }

  /*****************************************************************
  **  Ensure all the widths and heights are set up right
  ** A: No dimensions are negative
  ** B: No dimensions exceed the maximums
  ** C: The dimensions don't lead to a 0 width or height image.
  ****************************************************************/
  if ( src_x < 0 ) 
    src_x = 0;
  if ( src_y < 0 ) 
    src_y = 0;
  if ( dst_x < 0 ) 
    dst_x = 0;
  if ( dst_y < 0 ) 
    dst_y = 0;

  if ( src_w > wid || src_w <= 0 )
    src_w = wid;
    
  if ( src_h > hgt || src_h <= 0 ) 
    src_h = hgt;

  if ( dst_h == -1 ) 
    dst_h = (int) (((long)src_h * dst_w) / (src_w + 1)) + 1;

  if ( dst_h == 0 || dst_w == 0 )
  {
    dst_h = src_h;
    dst_w = src_w;
  }

  /*****************************************************************
  ** Based on notes from Heiko Schock and Arndt Roger Schneider,
  ** create this as a DIBitmap, to allow output to a greater range of
  ** devices. This approach will also allow selection of
  ** a) Whole screen
  ** b) Whole window
  ** c) Client window only
  ** for the "grab"
  *****************************************************************/
  hDib = CopyToDIB( wnd, wintype );

  /* GdiFlush(); */

  if (!hDib) {
    Tcl_SetResult(interp, "Can't create DIB", TCL_STATIC);
    return TCL_ERROR;
  }

  lpDIBHdr = (LPBITMAPINFOHEADER)GlobalLock(hDib);
  if (!lpDIBHdr) {
    Tcl_SetResult(interp, "Can't get DIB header", TCL_STATIC);
    return TCL_ERROR;
  }

  lpBits = (LPSTR)lpDIBHdr + lpDIBHdr->biSize + DIBNumColors(lpDIBHdr) * sizeof(RGBQUAD);

  /* stretch the DIBbitmap directly in the target device */

  if (StretchDIBits(dst, 
                     dst_x, dst_y, dst_w, dst_h,
                     src_x, src_y, src_w, src_h,
		     lpBits, (LPBITMAPINFO)lpDIBHdr, DIB_RGB_COLORS,
		     SRCCOPY) == GDI_ERROR)
  {
    GlobalUnlock(hDib);
    GlobalFree(hDib);
    ReleaseDC(wnd,src);
    errcode = GetLastError();
    sprintf(msgbuf, "StretchDIBits failed with code %ld", errcode);
    Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);
    return TCL_ERROR;
  }

  /* free allocated memory */
  GlobalUnlock(hDib);
  GlobalFree(hDib);
  ReleaseDC(NULL,src);

  ReleaseDC(wnd,src);

  /* The return value should relate to the size in the destination space.
  ** At least the height should be returned (for page layout purposes)
  */
  sprintf(msgbuf, "%d %d %d %d", dst_x, dst_y, dst_w, dst_h);
  Tcl_SetResult(interp, msgbuf, TCL_VOLATILE);

  return TCL_OK;
}

/****************************************************************
** Computes the number of colors required for a DIB palette
****************************************************************/
static int DIBNumColors(LPBITMAPINFOHEADER lpDIB)
{
    WORD wBitCount;  // DIB bit count
    DWORD dwClrUsed;

    // If this is a Windows-style DIB, the number of colors in the
    // color table can be less than the number of bits per pixel
    // allows for (i.e. lpbi->biClrUsed can be set to some value).
    // If this is the case, return the appropriate value.
    

    dwClrUsed = (lpDIB)->biClrUsed;
    if (dwClrUsed)
      return (WORD)dwClrUsed;

    // Calculate the number of colors in the color table based on
    // the number of bits per pixel for the DIB.
    
    wBitCount = (lpDIB)->biBitCount;

    // return number of colors based on bits per pixel

    switch (wBitCount)
    {
        case 1:
            return 2;

        case 4:
            return 16;

        case 8:
            return 256;

        default:
            return 0;
    }
}

/****************************************************************
** Helper functions
****************************************************************/
/****************************************************************
** WordToWeight converts keywords to font weights.
** This is used to help set the proper font for GDI rendering.
****************************************************************/
static int GdiWordToWeight(const char *str)
{
  int retval = FW_NORMAL;
  int i; 
  static struct font_weight
  {
    const char *name;
    int weight;
  } font_weights[] =
  {
    { "thin", FW_THIN },
    { "extralight", FW_EXTRALIGHT },
    { "ultralight", FW_EXTRALIGHT },
    { "light", FW_LIGHT },
    { "normal", FW_NORMAL },
    { "regular", FW_NORMAL },
    { "medium", FW_MEDIUM },
    { "semibold", FW_SEMIBOLD },
    { "demibold", FW_SEMIBOLD },
    { "bold", FW_BOLD },
    { "extrabold", FW_EXTRABOLD },
    { "ultrabold", FW_EXTRABOLD },
    { "heavy", FW_HEAVY },
    { "black", FW_HEAVY },
  };
  
  /* Function ALWAYS succeeds. Default is FW_NORMAL (400) */
  if ( str == 0 )
    return retval;
    
  for (i=0; i<sizeof(font_weights) / sizeof(struct font_weight); i++)
  {
    if ( strcmp(str, font_weights[i].name) == 0 )
    {
      retval = font_weights[i].weight;
      break;
    }
  }
  
  return retval;
}

/****************************************************************
** MakeLogFont takes the font description string and converts
** this into a logical font spec.
** This routine doesn't parse like Tcl (or anything else yet)
** but can do a "reasonable" job for many font descriptions.
** Doesn't support styles, just weights.
****************************************************************/
static int GdiMakeLogFont(Tcl_Interp *interp, const char *str, LOGFONT *lf, HDC hDC)
{
  char **list;
  int  count;

  /* Set up defaults for logical font */
  memset (lf,0, sizeof(*lf));
  lf->lfWeight  = FW_NORMAL;
  lf->lfCharSet = DEFAULT_CHARSET;
  lf->lfOutPrecision = OUT_DEFAULT_PRECIS;
  lf->lfClipPrecision = CLIP_DEFAULT_PRECIS;
  lf->lfQuality = DEFAULT_QUALITY;
  lf->lfPitchAndFamily = DEFAULT_PITCH | FF_DONTCARE;

  /* The cast to (char *) is silly, based on prototype of Tcl_SplitList */
  if ( Tcl_SplitList(interp, (char *)str, &count, &list) != TCL_OK )
    return 0;

  /* Now we have the font structure broken into name, size, weight */
  if ( count >= 1 )
    strncpy(lf->lfFaceName, list[0], sizeof(lf->lfFaceName) - 1);
  else
    return 0;

  if ( count >= 2 )
  {
    int siz;
    char *strend;
    siz = strtol(list[1], &strend, 0);
    
    /* Assumptions:
    ** 1) Like canvas, if a positive number is specified, it's in points
    ** 2) Like canvas, if a negative number is specified, it's in pixels
    */
    if ( strend > list[1]  ) /* If it looks like a number, it is a number... */
    {
      if ( siz > 0 )  /* Size is in points */
      {
        SIZE wextent, vextent;
        POINT worigin, vorigin;
        double factor;

        switch ( GdiGetHdcInfo(hDC, &worigin, &wextent, &vorigin, &vextent) )
        {
          case MM_ISOTROPIC:
            if ( vextent.cy < -1 || vextent.cy > 1 )
            {
              factor = (double)wextent.cy / vextent.cy;
              if ( factor < 0.0 )
                factor = - factor;
              lf->lfHeight = (int)(-siz * GetDeviceCaps(hDC, LOGPIXELSY) * factor / 72.0);
            }
            else if ( vextent.cx < -1 || vextent.cx > 1 )
            {
              factor = (double)wextent.cx / vextent.cx;
              if ( factor < 0.0 )
                factor = - factor;
              lf->lfHeight = (int)(-siz * GetDeviceCaps(hDC, LOGPIXELSY) * factor / 72.0);
            }
            else
              lf->lfHeight = -siz; /* This is bad news... */
            break;
          case MM_ANISOTROPIC:
            if ( vextent.cy != 0 )
            {
              factor = (double)wextent.cy / vextent.cy;
              if ( factor < 0.0 )
                factor = - factor;
              lf->lfHeight = (int)(-siz * GetDeviceCaps(hDC, LOGPIXELSY) * factor / 72.0);
            }
            else
              lf->lfHeight = -siz; /* This is bad news... */
            break;
          case MM_TEXT:
          default:
            /* If mapping mode is MM_TEXT, use the documented formula */
            lf->lfHeight = -MulDiv(siz, GetDeviceCaps(hDC, LOGPIXELSY), 72);
            break;
          case MM_HIENGLISH:
            lf->lfHeight = -MulDiv(siz, 1000, 72);
            break;
          case MM_LOENGLISH:
            lf->lfHeight = -MulDiv(siz, 100, 72);
            break;
          case MM_HIMETRIC:
            lf->lfHeight = -MulDiv(siz, 1000*2.54, 72);
            break;
          case MM_LOMETRIC:
            lf->lfHeight = -MulDiv(siz, 100*2.54, 72);
            break;
          case MM_TWIPS:
            lf->lfHeight = -MulDiv(siz, 1440, 72);
            break;
        }
      }
      else if ( siz == 0 ) /* Use default size of 12 points */
        lf->lfHeight = -MulDiv(12, GetDeviceCaps(hDC, LOGPIXELSY), 72);
      else                 /* Use pixel size */
      {
        lf->lfHeight = siz;  /* Leave this negative */
      }
    }
    else 
      lf->lfWeight = GdiWordToWeight(list[1]);
  }

  if ( count >= 3 ) {
	if (strcmp(list[2], "italic") == 0)
		lf->lfItalic = 1;
	else
	    lf->lfWeight = GdiWordToWeight(list[2]);
  }

  Tcl_Free((char *)list);
  return 1;
}

/****************************************************************
** This command creates a logical pen based on input
** parameters and selects it into the HDC
****************************************************************/
static int GdiMakePen(Tcl_Interp *interp, int width, int style, unsigned long color,
                      LOGPEN *lf, HDC hDC, HGDIOBJ *oldPen)
{
  HPEN hPen;
  
  lf->lopnWidth.x = width;
  lf->lopnWidth.y = 0;         /* Unused in LOGPEN */
  lf->lopnStyle = PS_SOLID;    /* For now...convert 'style' in the future */
  lf->lopnColor = color;       /* Assume we're getting a COLORREF */
  /* Now we have a logical pen. Create the "real" pen and put it in the hDC */
  hPen = CreatePenIndirect(lf);
  *oldPen = SelectObject(hDC, hPen);
  return 1;
}

/****************************************************************
** FreePen wraps the protocol to delete a created pen
****************************************************************/
static int GdiFreePen(Tcl_Interp *interp, HDC hDC, HGDIOBJ oldPen)
{
  HGDIOBJ gonePen;
  gonePen = SelectObject (hDC, oldPen);
  DeleteObject (gonePen);
  return 1;
}

/****************************************************************
** MakeBrush creates a logical brush based on input parameters,
** creates it, and selects it into the hdc.
****************************************************************/
static int GdiMakeBrush (Tcl_Interp *interp, unsigned int style, unsigned long color,
                         long hatch, LOGBRUSH *lb, HDC hDC, HGDIOBJ *oldBrush)
{
  HBRUSH hBrush;
  lb->lbStyle = (style == -1 ? BS_HOLLOW : BS_SOLID);
  lb->lbColor = color;    /* Assume this is a COLORREF */
  lb->lbHatch = hatch;    /* Ignored for now, given BS_SOLID in the Style */
  /* Now we have the logical brush. Create the "real" brush and put it in the hDC */
  hBrush = CreateBrushIndirect(lb);
  *oldBrush = SelectObject(hDC, hBrush);
  return 1;
}

/****************************************************************
** FreeBrush wraps the protocol to delete a created brush
****************************************************************/
static int GdiFreeBrush (Tcl_Interp *interp, HDC hDC, HGDIOBJ oldBrush)
{
  HGDIOBJ goneBrush;
  goneBrush = SelectObject (hDC, oldBrush);
  DeleteObject(goneBrush);
  return 1;
}

/****************************************************************
** Copied functions from elsewhere in Tcl.
** Functions have removed reliance on X and Tk libraries,
** as well as removing the need for TkWindows.
** GdiGetColor is a copy of a TkpGetColor from tkWinColor.c
** GdiParseColor is a copy of XParseColor from xcolors.c
****************************************************************/
typedef struct {
    char *name;
    int index;
} SystemColorEntry;


static SystemColorEntry sysColors[] = {
    "3dDarkShadow",		COLOR_3DDKSHADOW,
    "3dLight",			COLOR_3DLIGHT,
    "ActiveBorder",		COLOR_ACTIVEBORDER,
    "ActiveCaption",		COLOR_ACTIVECAPTION,
    "AppWorkspace",		COLOR_APPWORKSPACE,
    "Background",		COLOR_BACKGROUND,
    "ButtonFace",		COLOR_BTNFACE,
    "ButtonHighlight",		COLOR_BTNHIGHLIGHT,
    "ButtonShadow",		COLOR_BTNSHADOW,
    "ButtonText",		COLOR_BTNTEXT,
    "CaptionText",		COLOR_CAPTIONTEXT,
    "DisabledText",		COLOR_GRAYTEXT,
    "GrayText",			COLOR_GRAYTEXT,
    "Highlight",		COLOR_HIGHLIGHT,
    "HighlightText",		COLOR_HIGHLIGHTTEXT,
    "InactiveBorder",		COLOR_INACTIVEBORDER,
    "InactiveCaption",		COLOR_INACTIVECAPTION,
    "InactiveCaptionText",	COLOR_INACTIVECAPTIONTEXT,
    "InfoBackground",		COLOR_INFOBK,
    "InfoText",			COLOR_INFOTEXT,
    "Menu",			COLOR_MENU,
    "MenuText",			COLOR_MENUTEXT,
    "Scrollbar",		COLOR_SCROLLBAR,
    "Window",			COLOR_WINDOW,
    "WindowFrame",		COLOR_WINDOWFRAME,
    "WindowText",		COLOR_WINDOWTEXT,
};

static int numsyscolors = 0;

typedef struct {
    char *name;
    unsigned char red;
    unsigned char green;
    unsigned char blue;
} XColorEntry;

static XColorEntry xColors[] =  {
    {"alice blue", 240, 248, 255},
    {"AliceBlue", 240, 248, 255},
    {"antique white", 250, 235, 215},
    {"AntiqueWhite", 250, 235, 215},
    {"AntiqueWhite1", 255, 239, 219},
    {"AntiqueWhite2", 238, 223, 204},
    {"AntiqueWhite3", 205, 192, 176},
    {"AntiqueWhite4", 139, 131, 120},
    {"aquamarine", 127, 255, 212},
    {"aquamarine1", 127, 255, 212},
    {"aquamarine2", 118, 238, 198},
    {"aquamarine3", 102, 205, 170},
    {"aquamarine4", 69, 139, 116},
    {"azure", 240, 255, 255},
    {"azure1", 240, 255, 255},
    {"azure2", 224, 238, 238},
    {"azure3", 193, 205, 205},
    {"azure4", 131, 139, 139},
    {"beige", 245, 245, 220},
    {"bisque", 255, 228, 196},
    {"bisque1", 255, 228, 196},
    {"bisque2", 238, 213, 183},
    {"bisque3", 205, 183, 158},
    {"bisque4", 139, 125, 107},
    {"black", 0, 0, 0},
    {"blanched almond", 255, 235, 205},
    {"BlanchedAlmond", 255, 235, 205},
    {"blue", 0, 0, 255},
    {"blue violet", 138, 43, 226},
    {"blue1", 0, 0, 255},
    {"blue2", 0, 0, 238},
    {"blue3", 0, 0, 205},
    {"blue4", 0, 0, 139},
    {"BlueViolet", 138, 43, 226},
    {"brown", 165, 42, 42},
    {"brown1", 255, 64, 64},
    {"brown2", 238, 59, 59},
    {"brown3", 205, 51, 51},
    {"brown4", 139, 35, 35},
    {"burlywood", 222, 184, 135},
    {"burlywood1", 255, 211, 155},
    {"burlywood2", 238, 197, 145},
    {"burlywood3", 205, 170, 125},
    {"burlywood4", 139, 115, 85},
    {"cadet blue", 95, 158, 160},
    {"CadetBlue", 95, 158, 160},
    {"CadetBlue1", 152, 245, 255},
    {"CadetBlue2", 142, 229, 238},
    {"CadetBlue3", 122, 197, 205},
    {"CadetBlue4", 83, 134, 139},
    {"chartreuse", 127, 255, 0},
    {"chartreuse1", 127, 255, 0},
    {"chartreuse2", 118, 238, 0},
    {"chartreuse3", 102, 205, 0},
    {"chartreuse4", 69, 139, 0},
    {"chocolate", 210, 105, 30},
    {"chocolate1", 255, 127, 36},
    {"chocolate2", 238, 118, 33},
    {"chocolate3", 205, 102, 29},
    {"chocolate4", 139, 69, 19},
    {"coral", 255, 127, 80},
    {"coral1", 255, 114, 86},
    {"coral2", 238, 106, 80},
    {"coral3", 205, 91, 69},
    {"coral4", 139, 62, 47},
    {"cornflower blue", 100, 149, 237},
    {"CornflowerBlue", 100, 149, 237},
    {"cornsilk", 255, 248, 220},
    {"cornsilk1", 255, 248, 220},
    {"cornsilk2", 238, 232, 205},
    {"cornsilk3", 205, 200, 177},
    {"cornsilk4", 139, 136, 120},
    {"cyan", 0, 255, 255},
    {"cyan1", 0, 255, 255},
    {"cyan2", 0, 238, 238},
    {"cyan3", 0, 205, 205},
    {"cyan4", 0, 139, 139},
    {"dark goldenrod", 184, 134, 11},
    {"dark green", 0, 100, 0},
    {"dark khaki", 189, 183, 107},
    {"dark olive green", 85, 107, 47},
    {"dark orange", 255, 140, 0},
    {"dark orchid", 153, 50, 204},
    {"dark salmon", 233, 150, 122},
    {"dark sea green", 143, 188, 143},
    {"dark slate blue", 72, 61, 139},
    {"dark slate gray", 47, 79, 79},
    {"dark slate grey", 47, 79, 79},
    {"dark turquoise", 0, 206, 209},
    {"dark violet", 148, 0, 211},
    {"DarkGoldenrod", 184, 134, 11},
    {"DarkGoldenrod1", 255, 185, 15},
    {"DarkGoldenrod2", 238, 173, 14},
    {"DarkGoldenrod3", 205, 149, 12},
    {"DarkGoldenrod4", 139, 101, 8},
    {"DarkGreen", 0, 100, 0},
    {"DarkKhaki", 189, 183, 107},
    {"DarkOliveGreen", 85, 107, 47},
    {"DarkOliveGreen1", 202, 255, 112},
    {"DarkOliveGreen2", 188, 238, 104},
    {"DarkOliveGreen3", 162, 205, 90},
    {"DarkOliveGreen4", 110, 139, 61},
    {"DarkOrange", 255, 140, 0},
    {"DarkOrange1", 255, 127, 0},
    {"DarkOrange2", 238, 118, 0},
    {"DarkOrange3", 205, 102, 0},
    {"DarkOrange4", 139, 69, 0},
    {"DarkOrchid", 153, 50, 204},
    {"DarkOrchid1", 191, 62, 255},
    {"DarkOrchid2", 178, 58, 238},
    {"DarkOrchid3", 154, 50, 205},
    {"DarkOrchid4", 104, 34, 139},
    {"DarkSalmon", 233, 150, 122},
    {"DarkSeaGreen", 143, 188, 143},
    {"DarkSeaGreen1", 193, 255, 193},
    {"DarkSeaGreen2", 180, 238, 180},
    {"DarkSeaGreen3", 155, 205, 155},
    {"DarkSeaGreen4", 105, 139, 105},
    {"DarkSlateBlue", 72, 61, 139},
    {"DarkSlateGray", 47, 79, 79},
    {"DarkSlateGray1", 151, 255, 255},
    {"DarkSlateGray2", 141, 238, 238},
    {"DarkSlateGray3", 121, 205, 205},
    {"DarkSlateGray4", 82, 139, 139},
    {"DarkSlateGrey", 47, 79, 79},
    {"DarkTurquoise", 0, 206, 209},
    {"DarkViolet", 148, 0, 211},
    {"deep pink", 255, 20, 147},
    {"deep sky blue", 0, 191, 255},
    {"DeepPink", 255, 20, 147},
    {"DeepPink1", 255, 20, 147},
    {"DeepPink2", 238, 18, 137},
    {"DeepPink3", 205, 16, 118},
    {"DeepPink4", 139, 10, 80},
    {"DeepSkyBlue", 0, 191, 255},
    {"DeepSkyBlue1", 0, 191, 255},
    {"DeepSkyBlue2", 0, 178, 238},
    {"DeepSkyBlue3", 0, 154, 205},
    {"DeepSkyBlue4", 0, 104, 139},
    {"dim gray", 105, 105, 105},
    {"dim grey", 105, 105, 105},
    {"DimGray", 105, 105, 105},
    {"DimGrey", 105, 105, 105},
    {"dodger blue", 30, 144, 255},
    {"DodgerBlue", 30, 144, 255},
    {"DodgerBlue1", 30, 144, 255},
    {"DodgerBlue2", 28, 134, 238},
    {"DodgerBlue3", 24, 116, 205},
    {"DodgerBlue4", 16, 78, 139},
    {"firebrick", 178, 34, 34},
    {"firebrick1", 255, 48, 48},
    {"firebrick2", 238, 44, 44},
    {"firebrick3", 205, 38, 38},
    {"firebrick4", 139, 26, 26},
    {"floral white", 255, 250, 240},
    {"FloralWhite", 255, 250, 240},
    {"forest green", 34, 139, 34},
    {"ForestGreen", 34, 139, 34},
    {"gainsboro", 220, 220, 220},
    {"ghost white", 248, 248, 255},
    {"GhostWhite", 248, 248, 255},
    {"gold", 255, 215, 0},
    {"gold1", 255, 215, 0},
    {"gold2", 238, 201, 0},
    {"gold3", 205, 173, 0},
    {"gold4", 139, 117, 0},
    {"goldenrod", 218, 165, 32},
    {"goldenrod1", 255, 193, 37},
    {"goldenrod2", 238, 180, 34},
    {"goldenrod3", 205, 155, 29},
    {"goldenrod4", 139, 105, 20},
    {"gray", 190, 190, 190},
    {"gray0", 0, 0, 0},
    {"gray1", 3, 3, 3},
    {"gray10", 26, 26, 26},
    {"gray100", 255, 255, 255},
    {"gray11", 28, 28, 28},
    {"gray12", 31, 31, 31},
    {"gray13", 33, 33, 33},
    {"gray14", 36, 36, 36},
    {"gray15", 38, 38, 38},
    {"gray16", 41, 41, 41},
    {"gray17", 43, 43, 43},
    {"gray18", 46, 46, 46},
    {"gray19", 48, 48, 48},
    {"gray2", 5, 5, 5},
    {"gray20", 51, 51, 51},
    {"gray21", 54, 54, 54},
    {"gray22", 56, 56, 56},
    {"gray23", 59, 59, 59},
    {"gray24", 61, 61, 61},
    {"gray25", 64, 64, 64},
    {"gray26", 66, 66, 66},
    {"gray27", 69, 69, 69},
    {"gray28", 71, 71, 71},
    {"gray29", 74, 74, 74},
    {"gray3", 8, 8, 8},
    {"gray30", 77, 77, 77},
    {"gray31", 79, 79, 79},
    {"gray32", 82, 82, 82},
    {"gray33", 84, 84, 84},
    {"gray34", 87, 87, 87},
    {"gray35", 89, 89, 89},
    {"gray36", 92, 92, 92},
    {"gray37", 94, 94, 94},
    {"gray38", 97, 97, 97},
    {"gray39", 99, 99, 99},
    {"gray4", 10, 10, 10},
    {"gray40", 102, 102, 102},
    {"gray41", 105, 105, 105},
    {"gray42", 107, 107, 107},
    {"gray43", 110, 110, 110},
    {"gray44", 112, 112, 112},
    {"gray45", 115, 115, 115},
    {"gray46", 117, 117, 117},
    {"gray47", 120, 120, 120},
    {"gray48", 122, 122, 122},
    {"gray49", 125, 125, 125},
    {"gray5", 13, 13, 13},
    {"gray50", 127, 127, 127},
    {"gray51", 130, 130, 130},
    {"gray52", 133, 133, 133},
    {"gray53", 135, 135, 135},
    {"gray54", 138, 138, 138},
    {"gray55", 140, 140, 140},
    {"gray56", 143, 143, 143},
    {"gray57", 145, 145, 145},
    {"gray58", 148, 148, 148},
    {"gray59", 150, 150, 150},
    {"gray6", 15, 15, 15},
    {"gray60", 153, 153, 153},
    {"gray61", 156, 156, 156},
    {"gray62", 158, 158, 158},
    {"gray63", 161, 161, 161},
    {"gray64", 163, 163, 163},
    {"gray65", 166, 166, 166},
    {"gray66", 168, 168, 168},
    {"gray67", 171, 171, 171},
    {"gray68", 173, 173, 173},
    {"gray69", 176, 176, 176},
    {"gray7", 18, 18, 18},
    {"gray70", 179, 179, 179},
    {"gray71", 181, 181, 181},
    {"gray72", 184, 184, 184},
    {"gray73", 186, 186, 186},
    {"gray74", 189, 189, 189},
    {"gray75", 191, 191, 191},
    {"gray76", 194, 194, 194},
    {"gray77", 196, 196, 196},
    {"gray78", 199, 199, 199},
    {"gray79", 201, 201, 201},
    {"gray8", 20, 20, 20},
    {"gray80", 204, 204, 204},
    {"gray81", 207, 207, 207},
    {"gray82", 209, 209, 209},
    {"gray83", 212, 212, 212},
    {"gray84", 214, 214, 214},
    {"gray85", 217, 217, 217},
    {"gray86", 219, 219, 219},
    {"gray87", 222, 222, 222},
    {"gray88", 224, 224, 224},
    {"gray89", 227, 227, 227},
    {"gray9", 23, 23, 23},
    {"gray90", 229, 229, 229},
    {"gray91", 232, 232, 232},
    {"gray92", 235, 235, 235},
    {"gray93", 237, 237, 237},
    {"gray94", 240, 240, 240},
    {"gray95", 242, 242, 242},
    {"gray96", 245, 245, 245},
    {"gray97", 247, 247, 247},
    {"gray98", 250, 250, 250},
    {"gray99", 252, 252, 252},
    {"green", 0, 255, 0},
    {"green yellow", 173, 255, 47},
    {"green1", 0, 255, 0},
    {"green2", 0, 238, 0},
    {"green3", 0, 205, 0},
    {"green4", 0, 139, 0},
    {"GreenYellow", 173, 255, 47},
    {"grey", 190, 190, 190},
    {"grey0", 0, 0, 0},
    {"grey1", 3, 3, 3},
    {"grey10", 26, 26, 26},
    {"grey100", 255, 255, 255},
    {"grey11", 28, 28, 28},
    {"grey12", 31, 31, 31},
    {"grey13", 33, 33, 33},
    {"grey14", 36, 36, 36},
    {"grey15", 38, 38, 38},
    {"grey16", 41, 41, 41},
    {"grey17", 43, 43, 43},
    {"grey18", 46, 46, 46},
    {"grey19", 48, 48, 48},
    {"grey2", 5, 5, 5},
    {"grey20", 51, 51, 51},
    {"grey21", 54, 54, 54},
    {"grey22", 56, 56, 56},
    {"grey23", 59, 59, 59},
    {"grey24", 61, 61, 61},
    {"grey25", 64, 64, 64},
    {"grey26", 66, 66, 66},
    {"grey27", 69, 69, 69},
    {"grey28", 71, 71, 71},
    {"grey29", 74, 74, 74},
    {"grey3", 8, 8, 8},
    {"grey30", 77, 77, 77},
    {"grey31", 79, 79, 79},
    {"grey32", 82, 82, 82},
    {"grey33", 84, 84, 84},
    {"grey34", 87, 87, 87},
    {"grey35", 89, 89, 89},
    {"grey36", 92, 92, 92},
    {"grey37", 94, 94, 94},
    {"grey38", 97, 97, 97},
    {"grey39", 99, 99, 99},
    {"grey4", 10, 10, 10},
    {"grey40", 102, 102, 102},
    {"grey41", 105, 105, 105},
    {"grey42", 107, 107, 107},
    {"grey43", 110, 110, 110},
    {"grey44", 112, 112, 112},
    {"grey45", 115, 115, 115},
    {"grey46", 117, 117, 117},
    {"grey47", 120, 120, 120},
    {"grey48", 122, 122, 122},
    {"grey49", 125, 125, 125},
    {"grey5", 13, 13, 13},
    {"grey50", 127, 127, 127},
    {"grey51", 130, 130, 130},
    {"grey52", 133, 133, 133},
    {"grey53", 135, 135, 135},
    {"grey54", 138, 138, 138},
    {"grey55", 140, 140, 140},
    {"grey56", 143, 143, 143},
    {"grey57", 145, 145, 145},
    {"grey58", 148, 148, 148},
    {"grey59", 150, 150, 150},
    {"grey6", 15, 15, 15},
    {"grey60", 153, 153, 153},
    {"grey61", 156, 156, 156},
    {"grey62", 158, 158, 158},
    {"grey63", 161, 161, 161},
    {"grey64", 163, 163, 163},
    {"grey65", 166, 166, 166},
    {"grey66", 168, 168, 168},
    {"grey67", 171, 171, 171},
    {"grey68", 173, 173, 173},
    {"grey69", 176, 176, 176},
    {"grey7", 18, 18, 18},
    {"grey70", 179, 179, 179},
    {"grey71", 181, 181, 181},
    {"grey72", 184, 184, 184},
    {"grey73", 186, 186, 186},
    {"grey74", 189, 189, 189},
    {"grey75", 191, 191, 191},
    {"grey76", 194, 194, 194},
    {"grey77", 196, 196, 196},
    {"grey78", 199, 199, 199},
    {"grey79", 201, 201, 201},
    {"grey8", 20, 20, 20},
    {"grey80", 204, 204, 204},
    {"grey81", 207, 207, 207},
    {"grey82", 209, 209, 209},
    {"grey83", 212, 212, 212},
    {"grey84", 214, 214, 214},
    {"grey85", 217, 217, 217},
    {"grey86", 219, 219, 219},
    {"grey87", 222, 222, 222},
    {"grey88", 224, 224, 224},
    {"grey89", 227, 227, 227},
    {"grey9", 23, 23, 23},
    {"grey90", 229, 229, 229},
    {"grey91", 232, 232, 232},
    {"grey92", 235, 235, 235},
    {"grey93", 237, 237, 237},
    {"grey94", 240, 240, 240},
    {"grey95", 242, 242, 242},
    {"grey96", 245, 245, 245},
    {"grey97", 247, 247, 247},
    {"grey98", 250, 250, 250},
    {"grey99", 252, 252, 252},
    {"honeydew", 240, 255, 240},
    {"honeydew1", 240, 255, 240},
    {"honeydew2", 224, 238, 224},
    {"honeydew3", 193, 205, 193},
    {"honeydew4", 131, 139, 131},
    {"hot pink", 255, 105, 180},
    {"HotPink", 255, 105, 180},
    {"HotPink1", 255, 110, 180},
    {"HotPink2", 238, 106, 167},
    {"HotPink3", 205, 96, 144},
    {"HotPink4", 139, 58, 98},
    {"indian red", 205, 92, 92},
    {"IndianRed", 205, 92, 92},
    {"IndianRed1", 255, 106, 106},
    {"IndianRed2", 238, 99, 99},
    {"IndianRed3", 205, 85, 85},
    {"IndianRed4", 139, 58, 58},
    {"ivory", 255, 255, 240},
    {"ivory1", 255, 255, 240},
    {"ivory2", 238, 238, 224},
    {"ivory3", 205, 205, 193},
    {"ivory4", 139, 139, 131},
    {"khaki", 240, 230, 140},
    {"khaki1", 255, 246, 143},
    {"khaki2", 238, 230, 133},
    {"khaki3", 205, 198, 115},
    {"khaki4", 139, 134, 78},
    {"lavender", 230, 230, 250},
    {"lavender blush", 255, 240, 245},
    {"LavenderBlush", 255, 240, 245},
    {"LavenderBlush1", 255, 240, 245},
    {"LavenderBlush2", 238, 224, 229},
    {"LavenderBlush3", 205, 193, 197},
    {"LavenderBlush4", 139, 131, 134},
    {"lawn green", 124, 252, 0},
    {"LawnGreen", 124, 252, 0},
    {"lemon chiffon", 255, 250, 205},
    {"LemonChiffon", 255, 250, 205},
    {"LemonChiffon1", 255, 250, 205},
    {"LemonChiffon2", 238, 233, 191},
    {"LemonChiffon3", 205, 201, 165},
    {"LemonChiffon4", 139, 137, 112},
    {"light blue", 173, 216, 230},
    {"light coral", 240, 128, 128},
    {"light cyan", 224, 255, 255},
    {"light goldenrod", 238, 221, 130},
    {"light goldenrod yellow", 250, 250, 210},
    {"light gray", 211, 211, 211},
    {"light grey", 211, 211, 211},
    {"light pink", 255, 182, 193},
    {"light salmon", 255, 160, 122},
    {"light sea green", 32, 178, 170},
    {"light sky blue", 135, 206, 250},
    {"light slate blue", 132, 112, 255},
    {"light slate gray", 119, 136, 153},
    {"light slate grey", 119, 136, 153},
    {"light steel blue", 176, 196, 222},
    {"light yellow", 255, 255, 224},
    {"LightBlue", 173, 216, 230},
    {"LightBlue1", 191, 239, 255},
    {"LightBlue2", 178, 223, 238},
    {"LightBlue3", 154, 192, 205},
    {"LightBlue4", 104, 131, 139},
    {"LightCoral", 240, 128, 128},
    {"LightCyan", 224, 255, 255},
    {"LightCyan1", 224, 255, 255},
    {"LightCyan2", 209, 238, 238},
    {"LightCyan3", 180, 205, 205},
    {"LightCyan4", 122, 139, 139},
    {"LightGoldenrod", 238, 221, 130},
    {"LightGoldenrod1", 255, 236, 139},
    {"LightGoldenrod2", 238, 220, 130},
    {"LightGoldenrod3", 205, 190, 112},
    {"LightGoldenrod4", 139, 129, 76},
    {"LightGoldenrodYellow", 250, 250, 210},
    {"LightGray", 211, 211, 211},
    {"LightGrey", 211, 211, 211},
    {"LightPink", 255, 182, 193},
    {"LightPink1", 255, 174, 185},
    {"LightPink2", 238, 162, 173},
    {"LightPink3", 205, 140, 149},
    {"LightPink4", 139, 95, 101},
    {"LightSalmon", 255, 160, 122},
    {"LightSalmon1", 255, 160, 122},
    {"LightSalmon2", 238, 149, 114},
    {"LightSalmon3", 205, 129, 98},
    {"LightSalmon4", 139, 87, 66},
    {"LightSeaGreen", 32, 178, 170},
    {"LightSkyBlue", 135, 206, 250},
    {"LightSkyBlue1", 176, 226, 255},
    {"LightSkyBlue2", 164, 211, 238},
    {"LightSkyBlue3", 141, 182, 205},
    {"LightSkyBlue4", 96, 123, 139},
    {"LightSlateBlue", 132, 112, 255},
    {"LightSlateGray", 119, 136, 153},
    {"LightSlateGrey", 119, 136, 153},
    {"LightSteelBlue", 176, 196, 222},
    {"LightSteelBlue1", 202, 225, 255},
    {"LightSteelBlue2", 188, 210, 238},
    {"LightSteelBlue3", 162, 181, 205},
    {"LightSteelBlue4", 110, 123, 139},
    {"LightYellow", 255, 255, 224},
    {"LightYellow1", 255, 255, 224},
    {"LightYellow2", 238, 238, 209},
    {"LightYellow3", 205, 205, 180},
    {"LightYellow4", 139, 139, 122},
    {"lime green", 50, 205, 50},
    {"LimeGreen", 50, 205, 50},
    {"linen", 250, 240, 230},
    {"magenta", 255, 0, 255},
    {"magenta1", 255, 0, 255},
    {"magenta2", 238, 0, 238},
    {"magenta3", 205, 0, 205},
    {"magenta4", 139, 0, 139},
    {"maroon", 176, 48, 96},
    {"maroon1", 255, 52, 179},
    {"maroon2", 238, 48, 167},
    {"maroon3", 205, 41, 144},
    {"maroon4", 139, 28, 98},
    {"medium aquamarine", 102, 205, 170},
    {"medium blue", 0, 0, 205},
    {"medium orchid", 186, 85, 211},
    {"medium purple", 147, 112, 219},
    {"medium sea green", 60, 179, 113},
    {"medium slate blue", 123, 104, 238},
    {"medium spring green", 0, 250, 154},
    {"medium turquoise", 72, 209, 204},
    {"medium violet red", 199, 21, 133},
    {"MediumAquamarine", 102, 205, 170},
    {"MediumBlue", 0, 0, 205},
    {"MediumOrchid", 186, 85, 211},
    {"MediumOrchid1", 224, 102, 255},
    {"MediumOrchid2", 209, 95, 238},
    {"MediumOrchid3", 180, 82, 205},
    {"MediumOrchid4", 122, 55, 139},
    {"MediumPurple", 147, 112, 219},
    {"MediumPurple1", 171, 130, 255},
    {"MediumPurple2", 159, 121, 238},
    {"MediumPurple3", 137, 104, 205},
    {"MediumPurple4", 93, 71, 139},
    {"MediumSeaGreen", 60, 179, 113},
    {"MediumSlateBlue", 123, 104, 238},
    {"MediumSpringGreen", 0, 250, 154},
    {"MediumTurquoise", 72, 209, 204},
    {"MediumVioletRed", 199, 21, 133},
    {"midnight blue", 25, 25, 112},
    {"MidnightBlue", 25, 25, 112},
    {"mint cream", 245, 255, 250},
    {"MintCream", 245, 255, 250},
    {"misty rose", 255, 228, 225},
    {"MistyRose", 255, 228, 225},
    {"MistyRose1", 255, 228, 225},
    {"MistyRose2", 238, 213, 210},
    {"MistyRose3", 205, 183, 181},
    {"MistyRose4", 139, 125, 123},
    {"moccasin", 255, 228, 181},
    {"navajo white", 255, 222, 173},
    {"NavajoWhite", 255, 222, 173},
    {"NavajoWhite1", 255, 222, 173},
    {"NavajoWhite2", 238, 207, 161},
    {"NavajoWhite3", 205, 179, 139},
    {"NavajoWhite4", 139, 121, 94},
    {"navy", 0, 0, 128},
    {"navy blue", 0, 0, 128},
    {"NavyBlue", 0, 0, 128},
    {"old lace", 253, 245, 230},
    {"OldLace", 253, 245, 230},
    {"olive drab", 107, 142, 35},
    {"OliveDrab", 107, 142, 35},
    {"OliveDrab1", 192, 255, 62},
    {"OliveDrab2", 179, 238, 58},
    {"OliveDrab3", 154, 205, 50},
    {"OliveDrab4", 105, 139, 34},
    {"orange", 255, 165, 0},
    {"orange red", 255, 69, 0},
    {"orange1", 255, 165, 0},
    {"orange2", 238, 154, 0},
    {"orange3", 205, 133, 0},
    {"orange4", 139, 90, 0},
    {"OrangeRed", 255, 69, 0},
    {"OrangeRed1", 255, 69, 0},
    {"OrangeRed2", 238, 64, 0},
    {"OrangeRed3", 205, 55, 0},
    {"OrangeRed4", 139, 37, 0},
    {"orchid", 218, 112, 214},
    {"orchid1", 255, 131, 250},
    {"orchid2", 238, 122, 233},
    {"orchid3", 205, 105, 201},
    {"orchid4", 139, 71, 137},
    {"pale goldenrod", 238, 232, 170},
    {"pale green", 152, 251, 152},
    {"pale turquoise", 175, 238, 238},
    {"pale violet red", 219, 112, 147},
    {"PaleGoldenrod", 238, 232, 170},
    {"PaleGreen", 152, 251, 152},
    {"PaleGreen1", 154, 255, 154},
    {"PaleGreen2", 144, 238, 144},
    {"PaleGreen3", 124, 205, 124},
    {"PaleGreen4", 84, 139, 84},
    {"PaleTurquoise", 175, 238, 238},
    {"PaleTurquoise1", 187, 255, 255},
    {"PaleTurquoise2", 174, 238, 238},
    {"PaleTurquoise3", 150, 205, 205},
    {"PaleTurquoise4", 102, 139, 139},
    {"PaleVioletRed", 219, 112, 147},
    {"PaleVioletRed1", 255, 130, 171},
    {"PaleVioletRed2", 238, 121, 159},
    {"PaleVioletRed3", 205, 104, 137},
    {"PaleVioletRed4", 139, 71, 93},
    {"papaya whip", 255, 239, 213},
    {"PapayaWhip", 255, 239, 213},
    {"peach puff", 255, 218, 185},
    {"PeachPuff", 255, 218, 185},
    {"PeachPuff1", 255, 218, 185},
    {"PeachPuff2", 238, 203, 173},
    {"PeachPuff3", 205, 175, 149},
    {"PeachPuff4", 139, 119, 101},
    {"peru", 205, 133, 63},
    {"pink", 255, 192, 203},
    {"pink1", 255, 181, 197},
    {"pink2", 238, 169, 184},
    {"pink3", 205, 145, 158},
    {"pink4", 139, 99, 108},
    {"plum", 221, 160, 221},
    {"plum1", 255, 187, 255},
    {"plum2", 238, 174, 238},
    {"plum3", 205, 150, 205},
    {"plum4", 139, 102, 139},
    {"powder blue", 176, 224, 230},
    {"PowderBlue", 176, 224, 230},
    {"purple", 160, 32, 240},
    {"purple1", 155, 48, 255},
    {"purple2", 145, 44, 238},
    {"purple3", 125, 38, 205},
    {"purple4", 85, 26, 139},
    {"red", 255, 0, 0},
    {"red1", 255, 0, 0},
    {"red2", 238, 0, 0},
    {"red3", 205, 0, 0},
    {"red4", 139, 0, 0},
    {"rosy brown", 188, 143, 143},
    {"RosyBrown", 188, 143, 143},
    {"RosyBrown1", 255, 193, 193},
    {"RosyBrown2", 238, 180, 180},
    {"RosyBrown3", 205, 155, 155},
    {"RosyBrown4", 139, 105, 105},
    {"royal blue", 65, 105, 225},
    {"RoyalBlue", 65, 105, 225},
    {"RoyalBlue1", 72, 118, 255},
    {"RoyalBlue2", 67, 110, 238},
    {"RoyalBlue3", 58, 95, 205},
    {"RoyalBlue4", 39, 64, 139},
    {"saddle brown", 139, 69, 19},
    {"SaddleBrown", 139, 69, 19},
    {"salmon", 250, 128, 114},
    {"salmon1", 255, 140, 105},
    {"salmon2", 238, 130, 98},
    {"salmon3", 205, 112, 84},
    {"salmon4", 139, 76, 57},
    {"sandy brown", 244, 164, 96},
    {"SandyBrown", 244, 164, 96},
    {"sea green", 46, 139, 87},
    {"SeaGreen", 46, 139, 87},
    {"SeaGreen1", 84, 255, 159},
    {"SeaGreen2", 78, 238, 148},
    {"SeaGreen3", 67, 205, 128},
    {"SeaGreen4", 46, 139, 87},
    {"seashell", 255, 245, 238},
    {"seashell1", 255, 245, 238},
    {"seashell2", 238, 229, 222},
    {"seashell3", 205, 197, 191},
    {"seashell4", 139, 134, 130},
    {"sienna", 160, 82, 45},
    {"sienna1", 255, 130, 71},
    {"sienna2", 238, 121, 66},
    {"sienna3", 205, 104, 57},
    {"sienna4", 139, 71, 38},
    {"sky blue", 135, 206, 235},
    {"SkyBlue", 135, 206, 235},
    {"SkyBlue1", 135, 206, 255},
    {"SkyBlue2", 126, 192, 238},
    {"SkyBlue3", 108, 166, 205},
    {"SkyBlue4", 74, 112, 139},
    {"slate blue", 106, 90, 205},
    {"slate gray", 112, 128, 144},
    {"slate grey", 112, 128, 144},
    {"SlateBlue", 106, 90, 205},
    {"SlateBlue1", 131, 111, 255},
    {"SlateBlue2", 122, 103, 238},
    {"SlateBlue3", 105, 89, 205},
    {"SlateBlue4", 71, 60, 139},
    {"SlateGray", 112, 128, 144},
    {"SlateGray1", 198, 226, 255},
    {"SlateGray2", 185, 211, 238},
    {"SlateGray3", 159, 182, 205},
    {"SlateGray4", 108, 123, 139},
    {"SlateGrey", 112, 128, 144},
    {"snow", 255, 250, 250},
    {"snow1", 255, 250, 250},
    {"snow2", 238, 233, 233},
    {"snow3", 205, 201, 201},
    {"snow4", 139, 137, 137},
    {"spring green", 0, 255, 127},
    {"SpringGreen", 0, 255, 127},
    {"SpringGreen1", 0, 255, 127},
    {"SpringGreen2", 0, 238, 118},
    {"SpringGreen3", 0, 205, 102},
    {"SpringGreen4", 0, 139, 69},
    {"steel blue", 70, 130, 180},
    {"SteelBlue", 70, 130, 180},
    {"SteelBlue1", 99, 184, 255},
    {"SteelBlue2", 92, 172, 238},
    {"SteelBlue3", 79, 148, 205},
    {"SteelBlue4", 54, 100, 139},
    {"tan", 210, 180, 140},
    {"tan1", 255, 165, 79},
    {"tan2", 238, 154, 73},
    {"tan3", 205, 133, 63},
    {"tan4", 139, 90, 43},
    {"thistle", 216, 191, 216},
    {"thistle1", 255, 225, 255},
    {"thistle2", 238, 210, 238},
    {"thistle3", 205, 181, 205},
    {"thistle4", 139, 123, 139},
    {"tomato", 255, 99, 71},
    {"tomato1", 255, 99, 71},
    {"tomato2", 238, 92, 66},
    {"tomato3", 205, 79, 57},
    {"tomato4", 139, 54, 38},
    {"turquoise", 64, 224, 208},
    {"turquoise1", 0, 245, 255},
    {"turquoise2", 0, 229, 238},
    {"turquoise3", 0, 197, 205},
    {"turquoise4", 0, 134, 139},
    {"violet", 238, 130, 238},
    {"violet red", 208, 32, 144},
    {"VioletRed", 208, 32, 144},
    {"VioletRed1", 255, 62, 150},
    {"VioletRed2", 238, 58, 140},
    {"VioletRed3", 205, 50, 120},
    {"VioletRed4", 139, 34, 82},
    {"wheat", 245, 222, 179},
    {"wheat1", 255, 231, 186},
    {"wheat2", 238, 216, 174},
    {"wheat3", 205, 186, 150},
    {"wheat4", 139, 126, 102},
    {"white", 255, 255, 255},
    {"white smoke", 245, 245, 245},
    {"WhiteSmoke", 245, 245, 245},
    {"yellow", 255, 255, 0},
    {"yellow green", 154, 205, 50},
    {"yellow1", 255, 255, 0},
    {"yellow2", 238, 238, 0},
    {"yellow3", 205, 205, 0},
    {"yellow4", 139, 139, 0},
    {"YellowGreen", 154, 205, 50},
};

static int numxcolors=0;

/****************************************************************
** Convert color name to color specification
****************************************************************/
static int GdiGetColor(const char *name, unsigned long *color)
{
  if ( numsyscolors == 0 )
    numsyscolors = sizeof ( sysColors ) / sizeof (SystemColorEntry);
  if ( strncmpi(name, "system", 6) == 0 )
  {
    int i, l, u, r;
    l = 0;
    u = numsyscolors;
    while ( l <= u )
    {
      i = (l + u) / 2;
      if ( (r = strcmpi(name+6, sysColors[i].name)) == 0 )
        break;
      if ( r < 0 )
        u = i - 1;
      else
        l = i + 1;
    }
    if ( l > u )
      return 0;
    *color = GetSysColor(sysColors[i].index);
    return 1;
  }
  else
    return GdiParseColor(name, color);
}

/****************************************************************
** Convert color specification string (which could be an RGB string)
** to a color RGB triple
****************************************************************/
static int GdiParseColor (const char *name, unsigned long *color)
{
  if ( name[0] == '{' )
	  return 0;

  if ( name[0] == '#' )
  {
    char fmt[16];
    int i, red, green, blue;

    if ( (i = strlen(name+1))%3 != 0 || i > 12 || i < 3)
      return 0;
    i /= 3;
    sprintf(fmt, "%%%dx%%%dx%%%dx", i, i, i);
    if (sscanf(name+1, fmt, &red, &green, &blue) != 3) {
        return 0;
    }
    /* Now this is windows specific -- each component is at most 8 bits */
    switch ( i )
    {
      case 1:
        red <<= 4;
        green <<= 4;
        blue <<= 4;
        break;
      case 2:
        break;
      case 3:
        red >>= 4;
        green >>= 4;
        blue >>= 4;
        break;
      case 4:
        red >>= 8;
        green >>= 8;
        blue >>= 8;
        break;
    }
    *color = RGB(red, blue, green);
    return 1;
  }
  else
  {
    int i, u, r, l;
    if ( numxcolors == 0 )
      numxcolors = sizeof(xColors) / sizeof(XColorEntry);
    l = 0;
    u = numxcolors;
    
    while ( l <= u)
    {
      i = (l + u) / 2;
      if ( (r = strcmpi(name, xColors[i].name)) == 0 )
        break;
      if ( r < 0 )
        u = i-1;
      else
        l = i+1;
    }
    if ( l > u )
      return 0;
    *color = RGB(xColors[i].red, xColors[i].green, xColors[i].blue);
    return 1;
  }
}

/*****************************************************************
** Beginning of functions for screen-to-dib translations
** Several of these functions are based on those in the WINCAP32
** program provided as a sample by Microsoft on the VC++ 5.0
** disk. The copyright on these functions is retained, even for
** those with significant changes.
** I do not understand the meaning of this copyright in this
** context, since the example is present to provide insight into
** the rather baroque mechanism used to manipulate DIBs.
*****************************************************************/
/****************************************************************
** Written by Microsoft Product Support Services, Developer Support.
** Copyright (C) 1991-1996 Microsoft Corporation. All rights reserved.
****************************************************************/
static HANDLE CopyToDIB ( HWND hWnd, enum PrintType type )
{
   HANDLE     hDIB;
   HBITMAP  hBitmap;
   HPALETTE hPalette;
   
   /* check for a valid window handle */

    if (!hWnd)
        return NULL;

    switch (type)
    {
        case PTWindow: /* copy entire window */
        {
            RECT    rectWnd;

            /*  get the window rectangle */

            GetWindowRect(hWnd, &rectWnd);

            /* get the DIB of the window by calling
            ** CopyScreenToDIB and passing it the window rect
            */
            
            hDIB = CopyScreenToDIB(&rectWnd);
            break;
        }
      
        case PTClient: /* copy client area */
        {
            RECT    rectClient;
            POINT   pt1, pt2;

            /* get the client area dimensions */

            GetClientRect(hWnd, &rectClient);

            /* convert client coords to screen coords */

            pt1.x = rectClient.left;
            pt1.y = rectClient.top;
            pt2.x = rectClient.right;
            pt2.y = rectClient.bottom;
            ClientToScreen(hWnd, &pt1);
            ClientToScreen(hWnd, &pt2);
            rectClient.left = pt1.x;
            rectClient.top = pt1.y;
            rectClient.right = pt2.x;
            rectClient.bottom = pt2.y;

            /* get the DIB of the client area by calling
            ** CopyScreenToDIB and passing it the client rect
            */

            hDIB = CopyScreenToDIB(&rectClient);
            break;
        }

        case PTScreen: /* Entire screen */
        {
          RECT   Rect;
          
          /* get the device-dependent bitmap in lpRect by calling
          **  CopyScreenToBitmap and passing it the rectangle to grab
          */
          Rect.top = Rect.left = 0;
          GetDisplaySize(&Rect.right, &Rect.bottom);
          
          hBitmap = CopyScreenToBitmap(&Rect);

          /* check for a valid bitmap handle */

          if (!hBitmap)
            return NULL;

          /* get the current palette */

          hPalette = GetSystemPalette();

          /* convert the bitmap to a DIB */

          hDIB = BitmapToDIB(hBitmap, hPalette);

          /* clean up  */

          DeleteObject(hPalette);
          DeleteObject(hBitmap);

          /* return handle to the packed-DIB */
        }
        break;
      default:    /* invalid print area */
        return NULL;
    }

   /* return the handle to the DIB */
  return hDIB;
}

/****************************************************************
** GetDisplaySize does just that.
** There may be an easier way, but I just haven't found it.
****************************************************************/
static void GetDisplaySize (LONG *width, LONG *height)
{
  HDC hDC;

  hDC = CreateDC("DISPLAY", 0, 0, 0);
  *width = GetDeviceCaps (hDC, HORZRES);
  *height = GetDeviceCaps (hDC, VERTRES);
  DeleteDC(hDC);
}

/****************************************************************
** Written by Microsoft Product Support Services, Developer Support.
** Copyright (C) 1991-1996 Microsoft Corporation. All rights reserved.
****************************************************************/
static HBITMAP CopyScreenToBitmap(LPRECT lpRect)
{
    HDC         hScrDC, hMemDC;         /* screen DC and memory DC */
    HBITMAP     hBitmap, hOldBitmap;    /* handles to deice-dependent bitmaps */
    int         nX, nY, nX2, nY2;       /* coordinates of rectangle to grab */
    int         nWidth, nHeight;        /* DIB width and height  */
    int         xScrn, yScrn;           /* screen resolution */

    /* check for an empty rectangle */

    if (IsRectEmpty(lpRect))
      return NULL;

    /* create a DC for the screen and create
    ** a memory DC compatible to screen DC
    */
    
    hScrDC = CreateDC("DISPLAY", NULL, NULL, NULL);
    hMemDC = CreateCompatibleDC(hScrDC);

    /* get points of rectangle to grab */

    nX = lpRect->left;
    nY = lpRect->top;
    nX2 = lpRect->right;
    nY2 = lpRect->bottom;

    /* get screen resolution */

    xScrn = GetDeviceCaps(hScrDC, HORZRES);
    yScrn = GetDeviceCaps(hScrDC, VERTRES);

    /* make sure bitmap rectangle is visible */

    if (nX < 0)
        nX = 0;
    if (nY < 0)
        nY = 0;
    if (nX2 > xScrn)
        nX2 = xScrn;
    if (nY2 > yScrn)
        nY2 = yScrn;

    nWidth = nX2 - nX;
    nHeight = nY2 - nY;

    /* create a bitmap compatible with the screen DC */
    hBitmap = CreateCompatibleBitmap(hScrDC, nWidth, nHeight);

    /* select new bitmap into memory DC */
    hOldBitmap = SelectObject(hMemDC, hBitmap);

    /* bitblt screen DC to memory DC */
    BitBlt(hMemDC, 0, 0, nWidth, nHeight, hScrDC, nX, nY, SRCCOPY);

    /* select old bitmap back into memory DC and get handle to
    ** bitmap of the screen
    */
    
    hBitmap = SelectObject(hMemDC, hOldBitmap);

    /* clean up */

    DeleteDC(hScrDC);
    DeleteDC(hMemDC);

    /* return handle to the bitmap */

    return hBitmap;
}

/****************************************************************
** Written by Microsoft Product Support Services, Developer Support.
** Copyright (C) 1991-1996 Microsoft Corporation. All rights reserved.
****************************************************************/
static HANDLE BitmapToDIB(HBITMAP hBitmap, HPALETTE hPal)
{
    BITMAP              bm;         
    BITMAPINFOHEADER    bi;         
    LPBITMAPINFOHEADER  lpbi;       
    DWORD               dwLen;      
    HANDLE              hDIB;
    HANDLE              h;    
    HDC                 hDC;        
    WORD                biBits;     

    /* check if bitmap handle is valid */

    if (!hBitmap)
        return NULL;

    /* fill in BITMAP structure, return NULL if it didn't work */

    if (!GetObject(hBitmap, sizeof(bm), (LPSTR)&bm))
        return NULL;

    /* if no palette is specified, use default palette */

    if (hPal == NULL)
        hPal = GetStockObject(DEFAULT_PALETTE);

    /* calculate bits per pixel */

    biBits = bm.bmPlanes * bm.bmBitsPixel;

    /* make sure bits per pixel is valid */

    if (biBits <= 1)
        biBits = 1;
    else if (biBits <= 4)
        biBits = 4;
    else if (biBits <= 8)
        biBits = 8;
    else /* if greater than 8-bit, force to 24-bit */
        biBits = 24;

    /* initialize BITMAPINFOHEADER */

    bi.biSize = sizeof(BITMAPINFOHEADER);
    bi.biWidth = bm.bmWidth;
    bi.biHeight = bm.bmHeight;
    bi.biPlanes = 1;
    bi.biBitCount = biBits;
    bi.biCompression = BI_RGB;
    bi.biSizeImage = 0;
    bi.biXPelsPerMeter = 0;
    bi.biYPelsPerMeter = 0;
    bi.biClrUsed = 0;
    bi.biClrImportant = 0;

    /* calculate size of memory block required to store BITMAPINFO */

    dwLen = bi.biSize + DIBNumColors(&bi) * sizeof(RGBQUAD);

    /* get a DC */

    hDC = GetDC(NULL);

    /* select and realize our palette */

    hPal = SelectPalette(hDC, hPal, FALSE);
    RealizePalette(hDC);

    /* alloc memory block to store our bitmap */

    hDIB = GlobalAlloc(GHND, dwLen);

    /* if we couldn't get memory block */

    if (!hDIB)
    {
      /* clean up and return NULL */

      SelectPalette(hDC, hPal, TRUE);
      RealizePalette(hDC);
      ReleaseDC(NULL, hDC);
      return NULL;
    }

    /* lock memory and get pointer to it */

    lpbi = (LPBITMAPINFOHEADER)GlobalLock(hDIB);

    /* use our bitmap info. to fill BITMAPINFOHEADER */

    *lpbi = bi;

    /* call GetDIBits with a NULL lpBits param, so it will calculate the
    ** biSizeImage field for us
    */

    GetDIBits(hDC, hBitmap, 0, (UINT)bi.biHeight, NULL, (LPBITMAPINFO)lpbi,
        DIB_RGB_COLORS);

    /* get the info. returned by GetDIBits and unlock memory block */

    bi = *lpbi;
    GlobalUnlock(hDIB);

    /* if the driver did not fill in the biSizeImage field, make one up  */
    if (bi.biSizeImage == 0)
        bi.biSizeImage = (((((DWORD)bm.bmWidth * biBits) + 31) / 32) * 4) * bm.bmHeight;

    /* realloc the buffer big enough to hold all the bits */

    dwLen = bi.biSize + DIBNumColors(&bi) * sizeof(RGBQUAD) + bi.biSizeImage;

    if ((h = GlobalReAlloc(hDIB, dwLen, 0)) != 0)
        hDIB = h;
    else
    {
        /* clean up and return NULL */

        GlobalFree(hDIB);
        SelectPalette(hDC, hPal, TRUE);
        RealizePalette(hDC);
        ReleaseDC(NULL, hDC);
        return NULL;
    }

    /* lock memory block and get pointer to it */ 

    lpbi = (LPBITMAPINFOHEADER)GlobalLock(hDIB);

    /* call GetDIBits with a NON-NULL lpBits param, and actualy get the
    ** bits this time
    */

    if (GetDIBits(hDC, hBitmap, 0, (UINT)bi.biHeight, (LPSTR)lpbi +
            (WORD)lpbi->biSize + DIBNumColors(lpbi) * sizeof(RGBQUAD), (LPBITMAPINFO)lpbi,
            DIB_RGB_COLORS) == 0)
    {
        /* clean up and return NULL */

        GlobalUnlock(hDIB);
        SelectPalette(hDC, hPal, TRUE);
        RealizePalette(hDC);
        ReleaseDC(NULL, hDC);
        return NULL;
    }

    bi = *lpbi;

    /* clean up  */
    GlobalUnlock(hDIB);
    SelectPalette(hDC, hPal, TRUE);
    RealizePalette(hDC);
    ReleaseDC(NULL, hDC);

    /* return handle to the DIB */
    return hDIB;
}

/****************************************************************
** Written by Microsoft Product Support Services, Developer Support.
** Copyright (C) 1991-1996 Microsoft Corporation. All rights reserved.
****************************************************************/
static HANDLE CopyScreenToDIB(LPRECT lpRect)
{
    HBITMAP     hBitmap;        
    HPALETTE    hPalette;       
    HANDLE      hDIB;    

    /* get the device-dependent bitmap in lpRect by calling
    ** CopyScreenToBitmap and passing it the rectangle to grab
    */

    hBitmap = CopyScreenToBitmap(lpRect);

    /* check for a valid bitmap handle */

    if (!hBitmap)
      return NULL;

    /* get the current palette */

    hPalette = GetSystemPalette();

    /* convert the bitmap to a DIB */

    hDIB = BitmapToDIB(hBitmap, hPalette);

    /* clean up  */

    DeleteObject(hPalette);
    DeleteObject(hBitmap);

    /* return handle to the packed-DIB */
    return hDIB;
}

/****************************************************************
** Written by Microsoft Product Support Services, Developer Support.
** Copyright (C) 1991-1996 Microsoft Corporation. All rights reserved.
****************************************************************/
static HPALETTE GetSystemPalette(void)
{
    HDC hDC;                // handle to a DC
    static HPALETTE hPal = NULL;   // handle to a palette
    HANDLE hLogPal;         // handle to a logical palette
    LPLOGPALETTE lpLogPal;  // pointer to a logical palette
    int nColors;            // number of colors

    // Find out how many palette entries we want.

    hDC = GetDC(NULL);

    if (!hDC)
        return NULL;

    nColors = PalEntriesOnDevice(hDC);   // Number of palette entries

    // Allocate room for the palette and lock it.

    hLogPal = GlobalAlloc(GHND, sizeof(LOGPALETTE) + nColors *
            sizeof(PALETTEENTRY));

    // if we didn't get a logical palette, return NULL

    if (!hLogPal)
        return NULL;

    // get a pointer to the logical palette

    lpLogPal = (LPLOGPALETTE)GlobalLock(hLogPal);

    // set some important fields

    lpLogPal->palVersion = 0x300;
    lpLogPal->palNumEntries = nColors;

    // Copy the current system palette into our logical palette

    GetSystemPaletteEntries(hDC, 0, nColors,
            (LPPALETTEENTRY)(lpLogPal->palPalEntry));

    // Go ahead and create the palette.  Once it's created,
    // we no longer need the LOGPALETTE, so free it.    

    hPal = CreatePalette(lpLogPal);

    // clean up

    GlobalUnlock(hLogPal);
    GlobalFree(hLogPal);
    ReleaseDC(NULL, hDC);

    return hPal;
}

/****************************************************************
** Written by Microsoft Product Support Services, Developer Support.
** Copyright (C) 1991-1996 Microsoft Corporation. All rights reserved.
****************************************************************/
static int PalEntriesOnDevice(HDC hDC)
{
  return (1 << (GetDeviceCaps(hDC, BITSPIXEL) * GetDeviceCaps(hDC, PLANES)));
}


/****************************************************************
** This is the version information/command
** The static data should also be used by pkg_provide, etc.
****************************************************************/
/* Version information */
static char version_string[] = "0.9.5.1";

/* Version command */
static int Version(ClientData unused, Tcl_Interp *interp, int argc, char **argv)
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
EXPORT(int,Gdi_Init) (Tcl_Interp *interp)
{

#if TCL_MAJOR_VERSION <= 7
  Tcl_CreateCommand(interp, "gdi", gdi, 
                    0, 0);
#else
  /* Wanted to use namespaces, but "unknown" isn't smart enough yet */
  /* Since this package is so full of numbers, this would be a great place
  ** to introduce a TclCmdObj
  */
  Tcl_CreateCommand(interp, "gdi", gdi, 
                    0, 0);
#endif

  Tcl_PkgProvide (interp, "gdi", version_string);

  return TCL_OK;
}

/* The gdi function is considered safe. */
EXPORT (int,Gdi_SafeInit) (Tcl_Interp *interp)
{
  return Gdi_Init(interp);
}

#if 0
/* Exported symbols */
BOOL APIENTRY DllEntryPoint (HINSTANCE hInstance, DWORD seginfo, LPVOID lpCmdLine)
{
  /* Don't do anything, so just return true */
  return TRUE;
}
#endif