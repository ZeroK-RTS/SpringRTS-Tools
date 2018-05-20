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

ifndef PREFIX
PREFIX=/usr/local
endif

ifndef GAMESBIN
GAMESBIN=games
endif

ifndef APPDIR
APPDIR=share/applications
endif

ifndef ICONDIR
ICONDIR=share/icons/hicolor/128x128/apps
endif

all: spring-installer ca-installer

CAMLZIP = camlzip-1.04
CAMLZIP_FLAGS = -I $(CAMLZIP) zip.cmxa

CAMLSEVENZIP = camlsevenzip
CAMLSEVENZIP_FLAGS = -I $(CAMLSEVENZIP) sevenzip.cmxa

# Some setups link gtkInit and gtkThread automatically, strip them
LABLGTK2_FLAGS = $(shell ocamlfind query -predicates "native,archive,mt" -format "-I %d %a" lablgtk2 | grep -Ev "gtkInit|gtkThread") gtkInit.cmx

SI_SOURCES = hex.ml fileSystem.ml sdz.ml sd7.ml archive.ml datadir.ml springInstaller.ml
SI_PACKAGES = unix extlib
SI_FLAGS = $(LABLGTK2_FLAGS) $(CAMLSEVENZIP_FLAGS) $(CAMLZIP_FLAGS)

CI_SOURCES = hex.ml fileSystem.ml datadir.ml sdz.ml store.ml download.ml caInstaller.ml
CI_PACKAGES = unix threads netsys pcre equeue netstring extlib netclient
CI_FLAGS = $(LABLGTK2_FLAGS) gtkThread.cmx $(CAMLZIP_FLAGS)

camlsevenzip:
	$(MAKE) -C $(CAMLSEVENZIP)

camlzip:
	$(MAKE) -C $(CAMLZIP) allopt

spring-installer: camlsevenzip camlzip $(SI_SOURCES)
	ocamlfind ocamlopt -o spring-installer -linkpkg -package "$(SI_PACKAGES)" $(SI_FLAGS) $(SI_SOURCES)

ca-installer: camlzip $(CI_SOURCES)
	ocamlfind ocamlopt -o ca-installer -thread -linkpkg -package "$(CI_PACKAGES)" $(CI_FLAGS) $(CI_SOURCES)

install_spring-installer: spring-installer
	install -D -m 755 spring-installer $(DESTDIR)$(PREFIX)/$(GAMESBIN)/spring-installer
	install -D -m 644 data/spring-installer.desktop $(DESTDIR)$(PREFIX)/$(APPDIR)/spring-installer.desktop

install_ca-installer: ca-installer
	install -D -m 755 ca-installer $(DESTDIR)$(PREFIX)/$(GAMESBIN)/ca-installer
	install -D -m 644 data/ca-installer.desktop $(DESTDIR)$(PREFIX)/$(APPDIR)/ca-installer.desktop
	install -D -m 644 data/ca-installer.png $(DESTDIR)$(PREFIX)/$(ICONDIR)/ca-installer.png

clean:
	$(MAKE) -C $(CAMLSEVENZIP) clean
	$(MAKE) -C $(CAMLZIP) clean
	rm -f *.cmi  *.cmo  *.cmx  *.o spring-installer ca-installer

install: spring-installer ca-installer install_spring-installer install_ca-installer

.PHONY: all clean $(CAMLSEVENZIP) $(CAMLZIP) install install_spring-installer install_ca-installer
