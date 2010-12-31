#!/bin/bash

TMPDIR=`mktemp -d`
UNITS="$TMPDIR/units"
MORPHDEFS="$UNITS/morph_defs.lua"
MARKUP="$TMPDIR/markup"

svn export file:///home/ca/svn/trunk/mods/ca/units "$UNITS"
svn export file:///home/ca/svn/trunk/mods/ca/LuaRules/Configs/morph_defs.lua "$MORPHDEFS"
#for i in $UNITS/*.lua; do sed -r "s/.+(unitDef = \{)/\1/g" $i > $i.old; mv $i.old $i; done

lua /home/ca/bin/manual/make_unit_guide.lua $UNITS $MARKUP en
#recode ISO-8859-1..UTF-8 $MARKUP
trac-admin /home/ca/trac wiki import UnitGuide $MARKUP
cp $MARKUP /home/ca/bin/manual/output


lua /home/ca/bin/manual/make_unit_guide.lua $UNITS $MARKUP fr
#recode ISO-8859-1..UTF-8 $MARKUP
#recode -f ..ISO-8859-1 $MARKUP
trac-admin /home/ca/trac wiki import UnitGuide_FR $MARKUP
cp $MARKUP /home/ca/bin/manual/output_fr

lua /home/ca/bin/manual/make_unit_guide.lua $UNITS $MARKUP pt
#recode ISO-8859-1..UTF-8 $MARKUP
trac-admin /home/ca/trac wiki import UnitGuide_PT $MARKUP
cp $MARKUP /home/ca/bin/manual/output_pt

lua /home/ca/bin/manual/make_unit_guide.lua $UNITS $MARKUP pl
#recode ISO-8859-1..UTF-8 $MARKUP
trac-admin /home/ca/trac wiki import UnitGuide_PL $MARKUP
cp $MARKUP /home/ca/bin/manual/output_pl

lua /home/ca/bin/manual/make_unit_guide.lua $UNITS $MARKUP fi
#recode ISO-8859-1..UTF-8 $MARKUP
trac-admin /home/ca/trac wiki import UnitGuide_FI $MARKUP
cp $MARKUP /home/ca/bin/manual/output_fi

lua /home/ca/bin/manual/make_unit_guide.lua $UNITS $MARKUP my
#recode ISO-8859-1..UTF-8 $MARKUP
trac-admin /home/ca/trac wiki import UnitGuide_MY $MARKUP
cp $MARKUP /home/ca/bin/manual/output_my

lua /home/ca/bin/manual/make_unit_guide.lua $UNITS $MARKUP bp
#recode ISO-8859-1..UTF-8 $MARKUP
trac-admin /home/ca/trac wiki import UnitGuide_BP $MARKUP
cp $MARKUP /home/ca/bin/manual/output_bp

lua /home/ca/bin/manual/make_unit_guide.lua $UNITS $MARKUP es
#recode ISO-8859-1..UTF-8 $MARKUP
trac-admin /home/ca/trac wiki import UnitGuide_ES $MARKUP
cp $MARKUP /home/ca/bin/manual/output_es

lua /home/ca/bin/manual/make_unit_guide.lua $UNITS $MARKUP it
#recode ISO-8859-1..UTF-8 $MARKUP
trac-admin /home/ca/trac wiki import UnitGuide_IT $MARKUP
cp $MARKUP /home/ca/bin/manual/output_it


lua /home/ca/bin/manual/make_unit_guide.lua $UNITS $MARKUP all
#recode ISO-8859-1..UTF-8 $MARKUP
trac-admin /home/ca/trac wiki import UnitGuide_ALL $MARKUP
cp $MARKUP /home/ca/bin/manual/output_all


rm -rf $TMPDIR

