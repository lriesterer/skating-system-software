ZLIB_SRC        =       \
        adler32.c    compress.c   crc32.c      \
        gzio.c       uncompr.c    deflate.c    \
        trees.c      zutil.c      inflate.c    \
        infblock.c   inftrees.c   infcodes.c   \
        infutil.c    inffast.c

ZLIB_OBJ        =       \
        adler32.o    compress.o   crc32.o      \
        gzio.o       uncompr.o    deflate.o    \
        trees.o      zutil.o      inflate.o    \
        infblock.o   inftrees.o   infcodes.o   \
        infutil.o    inffast.o


CFLAGS = -O2 -fpic


all::	$(ZLIB_OBJ) my_compress.o
	gcc -o compress $(ZLIB_OBJ) my_compress.o
