#include "tcl.h"
#include <time.h>
#include "zip.h"

extern int Zip_ObjCmd(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST[]);


int Zip_Init(Tcl_Interp *interp)
{
	Tcl_CreateObjCommand(interp, "zip", Zip_ObjCmd, 0, NULL);

	return TCL_OK;
}

int Zip_ObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
static char *cmdsPtr[] = {"open", "add", "close", 0};
enum {iOpen, iAdd, iClose} index;

static zipFile zf = NULL;
char *name;
int result;


	if (objc < 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "cmd ?arg ...?");
		return TCL_ERROR;
	}

	if (Tcl_GetIndexFromObj(interp, objv[1], cmdsPtr, "command", 0, (int *)&index) != TCL_OK) {
		return TCL_ERROR;
	}


	if ((index == iAdd || index == iClose) && zf == NULL) {
		Tcl_SetResult(interp, "no zip opened", TCL_STATIC);
		return TCL_ERROR;
	}

	switch (index) {
		case iOpen:	if (objc < 3) {
						Tcl_WrongNumArgs(interp, 2, objv, "filename");
						return TCL_ERROR;
					}
					if (zf != NULL) {
						Tcl_SetResult(interp, "already an archive opened",
									  TCL_STATIC);
						return TCL_ERROR;
					}
					name = Tcl_GetStringFromObj(objv[2], NULL);
					zf = zipOpen(name,0);
					if (zf == NULL) {
						Tcl_SetResult(interp, "cannot open zip",
									  TCL_STATIC);
						return TCL_ERROR;
					}
					break;

		case iAdd:	{
					FILE *in;
					int size_read;
					const char *filename;
					zip_fileinfo zi;
					char *buf;
					struct tm* filedate;
					time_t tm_t=0;

					if (objc < 4) {
						Tcl_WrongNumArgs(interp, 2, objv, "filename time");
						return TCL_ERROR;
					}
					filename = Tcl_GetStringFromObj(objv[2], NULL);
					// compute date & time
					Tcl_GetIntFromObj(interp, objv[3], (int *) &tm_t);
					zi.tmz_date.tm_sec = zi.tmz_date.tm_min = 0;
					zi.tmz_date.tm_hour = zi.tmz_date.tm_mday =  0;
					zi.tmz_date.tm_min = zi.tmz_date.tm_year = 0;
					zi.dosDate = 0;
					zi.internal_fa = 0;
					zi.external_fa = 0;
					filedate = localtime(&tm_t);
					zi.tmz_date.tm_sec  = filedate->tm_sec;
					zi.tmz_date.tm_min  = filedate->tm_min;
					zi.tmz_date.tm_hour = filedate->tm_hour;
					zi.tmz_date.tm_mday = filedate->tm_mday;
					zi.tmz_date.tm_mon  = filedate->tm_mon ;
					zi.tmz_date.tm_year = filedate->tm_year;

					// create local file in zip
					result = zipOpenNewFileInZip(zf,filename,&zi,
												 NULL,0,NULL,0,NULL,
												 Z_DEFLATED, 7);
					if (result != ZIP_OK) {
						Tcl_SetResult(interp, "cannot open in zip",
									  TCL_STATIC);
						return TCL_ERROR;
					}

					if ((in = fopen(filename,"rb")) == NULL) {
						Tcl_SetResult(interp, "cannot open file to add",
									  TCL_STATIC);
						return TCL_ERROR;
					}
#define BUF_SIZE (64*1024)
					// read source and add to zip
					buf = (char *) malloc(BUF_SIZE);
					do {
						result = ZIP_OK;
						size_read = fread(buf,1,BUF_SIZE,in);
						if (size_read < BUF_SIZE) {
							if (feof(in)==0) {
								Tcl_SetResult(interp, "error reading file",
											  TCL_STATIC);
								result = ZIP_ERRNO;
							}
						}

						if (size_read>0)
						{
							result = zipWriteInFileInZip(zf,buf,size_read);
							if (result < 0)
							{
								Tcl_SetResult(interp, "error writing in zip file",
											  TCL_STATIC);
							}
								
						}
					} while ((result == ZIP_OK) && (size_read>0));
					free(buf);
					close(in);
					// close local file
					result = zipCloseFileInZip(zf);
					if (result != ZIP_OK) {
						Tcl_SetResult(interp, "cannot open in zip",
									  TCL_STATIC);
						return TCL_ERROR;
					}

					}
					break;

		case iClose: result = zipClose(zf,NULL);
					zf = NULL;
					if (result != ZIP_OK) {
						Tcl_SetResult(interp, "cannot close zip",
									  TCL_STATIC);
						return TCL_ERROR;
					}
					break;
	}

	return TCL_OK;
}
