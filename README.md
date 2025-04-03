# Cursor Installer & Updater for Linux

This script automates the installation and configuration of Cursor AppImage on Linux systems. It performs the following actions:

1.  Creates an installation directory (`~/Applications/cursor` by default).
2.  Downloads the latest Cursor AppImage.
3.  Makes the AppImage executable.
4.  Creates a symbolic link for command-line access (`/usr/local/bin/cursor`).
5.  Downloads an icon for the application.
6.  Creates a `.desktop` file for application menu integration.
7.  Sets up and enables a systemd user service to automatically update Cursor at startup.

## Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/HugoPfeffer/cursor_update.git
    cd cursor_update
    ```
    *Alternatively, download the `install_cursor.sh` script directly.*

2.  **Make the script executable:**
    ```bash
    chmod +x install_cursor.sh
    ```

3.  **Run the installation script:**
    ```bash
    ./install_cursor.sh
    ```

The script will prompt for `sudo` access when creating the symbolic link in `/usr/local/bin`. It will also configure paths using your current username automatically.

## Usage

After installation, you can launch Cursor:
*   From your application menu.
*   By typing `cursor` in your terminal.

The application will automatically check for updates each time you log in, thanks to the systemd service. You can manually trigger an update by running the script located at `~/Applications/cursor/update-cursor.sh` (created by the main install script).