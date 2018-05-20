APR_CFLAGS = `pkg-config --cflags apr-1`
APR_LIBS = `pkg-config --libs apr-1`
SVN_CFLAGS = -Isubversion-1
SVN_LIBS = -lsvn_subr-1 -lsvn_client-1 -lsvn_wc-1
LUA_CFLAGS =
LUA_LIBS = -llua5.1

BUILD_CA_ML_SOURCES = svn.ml hex.ml gz.ml md5.ml crc32.ml temp.ml paths.ml modlist.ml \
                      deps.ml serialize.ml lua.ml tdf.ml store.ml versions.ml last.ml \
                      sdz.ml main.ml

ADD_ARCHIVE_ML_SOURCES = hex.ml gz.ml md5.ml crc32.ml temp.ml paths.ml \
                      deps.ml serialize.ml lua.ml tdf.ml store.ml versions.ml \
                      addArchive.ml

ZIP_POOL_ML_SOURCES = hex.ml gz.ml md5.ml crc32.ml temp.ml paths.ml deps.ml \
                      serialize.ml lua.ml tdf.ml store.ml versions.ml sdz.ml zipPool.ml

STREAMER_ML_SOURCES = hex.ml gz.ml md5.ml crc32.ml temp.ml paths.ml \
                      deps.ml bitArray.ml serialize.ml lua.ml tdf.ml store.ml versions.ml \
                      streamer.ml

all: build-ca add-archive zip-pool streamer

build-ca: ml_svn.o ml_md5.o ml_crc32.o ml_lua.o 7zCrc.o $(BUILD_CA_ML_SOURCES)
	ocamlfind ocamlopt -o build-ca \
		-cclib "$(APR_LIBS) $(SVN_LIBS) $(LUA_LIBS)" \
		-linkpkg -package "extlib,zip,xml-light,pcre" \
		ml_svn.o ml_md5.o 7zCrc.o ml_crc32.o ml_lua.o $(BUILD_CA_ML_SOURCES)

add-archive:ml_md5.o ml_crc32.o ml_lua.o 7zCrc.o $(ADD_ARCHIVE_ML_SOURCES)
	ocamlfind ocamlopt -o add-archive \
		-cclib "$(APR_LIBS) $(SVN_LIBS) $(LUA_LIBS)" \
		-linkpkg -package "extlib,zip,pcre" \
		ml_md5.o 7zCrc.o ml_crc32.o ml_lua.o $(ADD_ARCHIVE_ML_SOURCES)

zip-pool: ml_md5.o ml_crc32.o 7zCrc.o $(ZIP_POOL_ML_SOURCES)
	ocamlfind ocamlopt -o zip-pool \
		-cclib "$(APR_LIBS) $(SVN_LIBS) $(LUA_LIBS)" \
		-linkpkg -package "extlib,zip,pcre" \
		ml_md5.o 7zCrc.o ml_crc32.o ml_lua.o $(ZIP_POOL_ML_SOURCES)

streamer: ml_md5.o ml_crc32.o 7zCrc.o $(STREAMER_ML_SOURCES)
	ocamlfind ocamlopt -o streamer \
		-cclib "$(APR_LIBS) $(SVN_LIBS) $(LUA_LIBS)" \
		-linkpkg -package "extlib,zip,pcre" \
		ml_md5.o 7zCrc.o ml_crc32.o ml_lua.o $(STREAMER_ML_SOURCES)

ml_svn.o: ml_svn.c
	ocamlopt -ccopt "-Wall -O2 $(APR_CFLAGS)" -o ml_svn.o -c ml_svn.c

ml_md5.o: ml_md5.c
	ocamlopt -ccopt "-Wall -O2 $(APR_CFLAGS)" -o ml_md5.o -c ml_md5.c

7zCrc.o: 7zCrc.c
	gcc -Wall -O2 -o 7zCrc.o -c 7zCrc.c

ml_crc32.o: ml_crc32.c
	ocamlopt -ccopt "-Wall -O2" -o ml_crc32.o -c ml_crc32.c

ml_lua.o: ml_lua.c
	ocamlopt -ccopt "-Wall -O2" -o ml_lua.o -c ml_lua.c

clean:
	rm -rf *.cmx
	rm -rf *.cmi
	rm -rf *.o
	rm -rf *.a
	rm -rf *.cmxa
	rm -f build-ca zip-pool add-archive streamer

.PHONY: all clean
