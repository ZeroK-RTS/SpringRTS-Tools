#!/bin/bash

TMPDIR=`mktemp -d`
UNITS="$TMPDIR/units"
MORPHDEFSDIR=`mkdir $TMPDIR/morphdefs`
MORPHDEFS="$TMPDIR/morphdefs/morph_defs.lua"
MARKUP="$TMPDIR/markup"

svn export http://zero-k.googlecode.com/svn/trunk/mods/zk/units "$UNITS"
svn export http://zero-k.googlecode.com/svn/trunk/mods/zk/LuaRules/Configs/morph_defs.lua "$MORPHDEFS"

#for i in $UNITS/*.lua; do sed -r "s/.+(unitDef = \{)/\1/g" $i > $i.old; mv $i.old $i; done

lua ./make_unit_guide.lua $TMPDIR $MARKUP en
cp $MARKUP ./index.html
#recode ISO-8859-1..UTF-8 $MARKUP
#trac-admin /home/ca/trac wiki import UnitGuide $MARKUP
#cp $MARKUP /home/ca/bin/manual/output

lua ./make_unit_guide.lua $TMPDIR $MARKUP all
cp $MARKUP ./comparison.html
#recode ISO-8859-1..UTF-8 $MARKUP
#trac-admin /home/ca/trac wiki import UnitGuide_ALL $MARKUP
#cp $MARKUP /home/ca/bin/manual/output_all


rm -rf $TMPDIR

