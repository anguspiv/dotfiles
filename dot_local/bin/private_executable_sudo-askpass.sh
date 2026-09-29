#!/bin/bash
# sudo askpass helper — GUI password prompt for TTY-less sudo (SUDO_ASKPASS + sudo -A).
osascript -e 'display dialog "sudo password for '"$USER"':" default answer "" with hidden answer with title "sudo" with icon caution' -e 'text returned of result' 2>/dev/null
