#!/bin/bash

TMPDIR=`mktemp -d`
#UNITSDIR=`mkdir $TMPDIR/units`
UNITS="/media/histidine/228CBE3D8CBE0AF5/Games/Spring/games/zk.sdd"
mkdir $TMPDIR/extradefs
EXTRADEFS="$TMPDIR/extradefs"
mkdir $TMPDIR/markup
MARKUP="$TMPDIR/markup"

#cp -r "/media/histidine/228CBE3D8CBE0AF5/Games/Spring/games/zk.sdd/" "$UNITS"
cp "/media/histidine/228CBE3D8CBE0AF5/Games/Spring/games/zk.sdd/LuaRules/Configs/morph_defs.lua" "$EXTRADEFS/morph_defs.lua"
cp "/media/histidine/228CBE3D8CBE0AF5/Games/Spring/games/zk.sdd/gamedata/buildoptions.lua" "$EXTRADEFS/buildoptions.lua"

#for i in $UNITS/*.lua; do sed -r "s/.+(unitDef = \{)/\1/g" $i > $i.old; mv $i.old $i; done

lua5.3 "/media/histidine/My Book/Games/Spring/SpringRTS-Tools/unitguide/export_unit_templates.lua" $UNITS $MARKUP en
#recode ISO-8859-1..UTF-8 $MARKUP
rm -rf "/home/histidine/zkwiki/output"
mkdir -p "/home/histidine/zkwiki/output"
cp -r $MARKUP "/home/histidine/zkwiki/output"

rm -rf $TMPDIR

