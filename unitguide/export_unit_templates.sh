#!/bin/bash

TMPDIR=`mktemp -d`
# set this as your local copy of ZK repo
UNITS="/media/histidine/NTFS Main/Games/Spring/games/zk.sdd"
mkdir $TMPDIR/extradefs
EXTRADEFS="$TMPDIR/extradefs"
mkdir $TMPDIR/markup
MARKUP="$TMPDIR/markup"
# Set where you want the output to go
OUTPUT="/media/histidine/My Book/zkwiki/output"

# likewise, point these to your local repo's copies of the files
cp "/media/histidine/NTFS Main/Games/Spring/games/zk.sdd/LuaRules/Configs/morph_defs.lua" "$EXTRADEFS/morph_defs.lua"
cp "/media/histidine/NTFS Main/Games/Spring/games/zk.sdd/gamedata/buildoptions.lua" "$EXTRADEFS/buildoptions.lua"

lua5.3 "./export_unit_templates.lua" "$UNITS" $MARKUP en
#recode ISO-8859-1..UTF-8 $MARKUP
rm -rf "$OUTPUT/markup"
mkdir -p "$OUTPUT/markup"
cp -r $MARKUP "$OUTPUT"

rm -rf $TMPDIR
