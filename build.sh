#!/bin/sh
REPO=$1
VERSION=$2
DEST=$3
REVISION=$4

TMPDIR=`mktemp -d`
BUILDDIR=$TMPDIR/build

if [ -n "$REVISION" ]
then
    svn export -r "$REVISION" "$REPO" "$BUILDDIR"    
else
    svn export "$REPO" "$BUILDDIR"    
fi

for i in "$BUILDDIR/mods/"*
do
    BASENAME=`basename "$i"`
    FILENAME="$BASENAME-$VERSION.sdz"

    echo "Archiving: $BASENAME"
    sed -i "s/\$VERSION/$VERSION/g" "$i/modinfo.lua"
    cd "$i" && zip -r "$BUILDDIR/$FILENAME" .
    mv -f "$BUILDDIR/$FILENAME" "$DEST"
done

rm -rf "$TMPDIR"
