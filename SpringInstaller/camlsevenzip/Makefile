#########################################################################
# spring-installer: GUI tools for installing Spring mods/maps           #
# Copyright (C) 2009 Chris Clearwater                                   #
#                                                                       #
# This program is free software: you can redistribute it and#or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#########################################################################

LD_FLAGS = -Llibmlsevenzip
LIBS = -lml_sevenzip

all: libml_sevenzip.a sevenzip.cmxa

sevenzip.cmxa: sevenzip.cmx
	ocamlopt -cclib "$(LD_FLAGS) $(LIBS)" -a -o sevenzip.cmxa sevenzip.cmx

sevenzip.cmx: sevenzip.ml
	ocamlopt -o sevenzip.cmx -c sevenzip.ml

libsevenzip:
	$(MAKE) -C libsevenzip/Archive/7z -f makefile.gcc

libml_sevenzip.a: libsevenzip ml_sevenzip.o
	ar rc libml_sevenzip.a ml_sevenzip.o libsevenzip/Archive/7z/*.o
	ranlib libml_sevenzip.a

ml_sevenzip.o: ml_sevenzip.c
	ocamlopt -o ml_sevenzip.o ml_sevenzip.c

clean:
	$(MAKE) -C libsevenzip/Archive/7z -f makefile.gcc clean
	rm -rf *.cmx
	rm -rf *.cmi
	rm -rf *.o
	rm -rf *.a
	rm -rf *.cmxa

.PHONY: all clean libsevenzip
