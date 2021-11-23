#!/bin/bash

TMPDIR=`mktemp -d`
# set this as your local copy of ZK repo
UNITS="D:/Games/Spring/games/zk.sdd"
mkdir $TMPDIR/extradefs
EXTRADEFS="$TMPDIR/extradefs"
mkdir $TMPDIR/markup
MARKUP="$TMPDIR/markup"
# Set where you want the output to go
OUTPUT="G:/zkwiki/output"

# likewise, point these to your local repo's copies of the files
cp "D:/Games/Spring/games/zk.sdd/LuaRules/Configs/morph_defs.lua" "$EXTRADEFS/morph_defs.lua"
cp "D:/Games/Spring/games/zk.sdd/gamedata/buildoptions.lua" "$EXTRADEFS/buildoptions.lua"

# Point this to a copy of the lua binary
/g/Programming/lua/lua53.exe "./export_unit_templates.lua" "$UNITS" $MARKUP en
#recode ISO-8859-1..UTF-8 $MARKUP
rm -rf "$OUTPUT/markup"
mkdir -p "$OUTPUT/markup"
cp -r $MARKUP "$OUTPUT"

rm -rf $TMPDIR
