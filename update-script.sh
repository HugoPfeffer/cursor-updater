#!/bin/bash

APPDIR=/opt
APPIMAGE_URL="https://downloader.cursor.sh/linux/appImage/x64"

if [ -f "$APPDIR/cursor.appimage" ]; then
    rm "$APPDIR/cursor.appimage"
fi

wget -O $APPDIR/cursor.appimage $APPIMAGE_URL
chmod +x $APPDIR/cursor.appimage