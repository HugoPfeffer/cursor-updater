1. Create a new folder for cursor

mkdir -p ~/Applications/cursor
2. Get the latest version of cursor in that folder

wget -O ~/Applications/cursor/cursor.AppImage "https://downloader.cursor.sh/linux/appImage/x64"
3. Make sure AppImage is executable (should already be but still)

chmod +x ~/Applications/cursor/cursor.AppImage
4. Make a symlink to be able to launch cursor from command line

sudo ln -s ~/Applications/cursor/cursor.AppImage /usr/local/bin/cursor
5. Download this image and put it in ~/Applications/cursor/
cursor_icon

6. Create a desktop entry to make it accessible in your menus

nano ~/.local/share/applications/cursor.desktop
7. Shift + Insert this code in the new file, then Ctrl + X, then Y, then Enter
Also, change your_username by your actual username.

[Desktop Entry]
Name=Cursor
Exec=/home/your_username/Applications/cursor/cursor.AppImage
Icon=/home/your_username/Applications/cursor/cursor-icon.png
Type=Application
Categories=Utility;Development;
8. Create an update script

nano ~/Applications/cursor/update-cursor.sh
9. Shift + Insert this code into the script, then Ctrl + X, then Y, then Enter

#!/bin/bash

APPDIR=~/Applications/cursor
APPIMAGE_URL="https://downloader.cursor.sh/linux/appImage/x64"

wget -O $APPDIR/cursor.AppImage $APPIMAGE_URL
chmod +x $APPDIR/cursor.AppImage
10. Make this script executable

chmod +x ~/Applications/cursor/update-cursor.sh
11. Create a service to update cursor at startup

nano ~/.config/systemd/user/update-cursor.service
12.Shift + Insert this code into the service, then Ctrl + X, then Y, then Enter
Also, change your_username by your actual username.

[Unit]
Description=Update Cursor

[Service]
ExecStart=/home/your_username/Applications/cursor/update-cursor.sh
Type=oneshot

[Install]
WantedBy=default.target
13. Enable and start the service

systemctl --user enable update-cursor.service
systemctl --user start update-cursor.service