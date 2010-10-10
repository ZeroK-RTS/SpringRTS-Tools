all: lua_standards

lua_standards: lua_standards.ml
	 ocamlopt unix.cmxa -I +extlib extLib.cmxa -o lua_standards lua_standards.ml

clean:
	rm -rf .cmx *.cmi lua_standards

.PHONY: all
