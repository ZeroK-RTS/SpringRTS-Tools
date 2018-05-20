#!/bin/sh
EXEC=$0
TRUNK=$1
BRANCH=$2
MODDIR=$3

REVISION=`wget --quiet -O - http://files.caspring.org/snapshots/latest_$BRANCH`

if [ $? -ne 0 ]
then
    echo "Unable to query latest revision for '$BRANCH' release."
    exit 1
fi

BUILD="`dirname $EXEC`/build.sh"
VERSION="$BRANCH-$REVISION"
FILE="$MODDIR/ca-$VERSION.sdz"

if [ -f "$FILE" ]
then
    echo "$FILE already installed."
    exit 0
fi

$BUILD "$TRUNK" "$VERSION" "$MODDIR" "$REVISION"
