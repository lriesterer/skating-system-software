/* example.c -- usage example of the zlib compression library
 * Copyright (C) 1995-1996 Jean-loup Gailly.
 * For conditions of distribution and use, see copyright notice in zlib.h 
 */

/* $Id: example.c,v 1.16 1996/05/23 17:11:28 me Exp $ */

#include <stdio.h>
#include "zlib.h"

#ifdef STDC
#  include <string.h>
#  include <stdlib.h>
#else
   extern void exit  OF((int));
#endif

#define CHECK_ERR(err, msg) { \
    if (err != Z_OK) { \
        fprintf(stderr, "%s error: %d\n", msg, err); \
        exit(1); \
    } \
}


/* ===========================================================================
 * Test compress() and uncompress()
 */
void main(int argc, char **argv)
{
FILE *in, *out;
unsigned char *bufIn, *bufOut;
uLong inLen, outLen;
int err, i;


	if (argc != 3) {
		fprintf(stderr, "Usage : %s <in> <out>", argv[0]);
		exit(1);
	}


    bufIn = malloc(400000);
    if ((in = fopen(argv[1], "r")) == NULL) {
		fprintf(stderr, "can't open input %s\n", argv[1]);
		exit(1);
	}
	inLen = fread(bufIn, 1, 400000, in);
	fclose(in);
fprintf(stderr, "read = %d\n", inLen);

    bufOut = malloc(200000);
	outLen = 200000;

    err = compress(bufOut, &outLen, (const Bytef*)bufIn, inLen);
    CHECK_ERR(err, "compress");
fprintf(stderr, "compressed = %d\n", outLen);


    if ((out = fopen(argv[2], "w")) == NULL) {
		fprintf(stderr, "can't open output %s\n", argv[2]);
		exit(1);
	}

	fprintf(out, "unsigned int scriptSize = %d;\n", inLen);
	fprintf(out, "unsigned int scriptCompressedSize = %d;\n", outLen);
	fprintf(out, "unsigned char script[] = {\n");
	for(i=0; i<outLen; i++) {
		if ((i%16) == 0) {
			fprintf(out, "\n");
		}
		fprintf(out, "0x%02X, ", bufOut[i]);
	}
	fprintf(out, "\n};\n");
	fclose(out);
}


