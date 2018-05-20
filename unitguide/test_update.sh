#!/bin/bash

TMPDIR=`mktemp -d`
UNITS="$TMPDIR/units"
UNITPICS="./unitpics"
EXTRADEFSDIR=`mkdir $TMPDIR/extradefs`
EXTRADEFS="$TMPDIR/extradefs"
MARKUP="$TMPDIR/markup"
WEAPONS="$TMPDIR/weapons"
NONLATIN="$TMPDIR/nonlatin"

REPO="https://github.com/ZeroK-RTS/Zero-K.git"

# http://stackoverflow.com/questions/600079/is-there-any-way-to-clone-a-git-repositorys-sub-directory-only

rm -rf "$UNITPICS"

git init "$TMPDIR"
pushd "$TMPDIR"
#git remote add -f origin "$REPO"
git remote add origin "$REPO"
git config core.sparsecheckout true
echo "units/" >> .git/info/sparse-checkout
echo "LuaRules/Configs/morph_defs.lua" >> .git/info/sparse-checkout
echo "gamedata/buildoptions.lua" >> .git/info/sparse-checkout
echo "weapons/" >> .git/info/sparse-checkout
echo "LuaUI/Configs/nonlatin/" >> .git/info/sparse-checkout
echo "unitpics/" >> .git/info/sparse-checkout

git pull --depth=1 origin master

cp LuaRules/Configs/morph_defs.lua extradefs/
cp gamedata/buildoptions.lua extradefs/
popd

cp -r "$TMPDIR/unitpics" "$UNITPICS"



#svn export "$REPO/units" "$UNITS"
#svn export "$REPO/LuaRules/Configs/morph_defs.lua" "$EXTRADEFS/morph_defs.lua"
#svn export "$REPO/gamedata/buildoptions.lua" "$EXTRADEFS/buildoptions.lua"
#svn export "$REPO/weapons" "$WEAPONS/"
#svn export "$REPO/LuaUI/Configs/nonlatin" "$NONLATIN/"
#svn export "$REPO/unitpics" "$UNITPICS"


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


lua ./make_unit_guide.lua $TMPDIR $MARKUP featured
cp $MARKUP ./featured.txt

rm -rf $TMPDIR

