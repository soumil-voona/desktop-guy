#!/bin/bash
setterm blank 0
setterm powerdown 0
export XDG_CURRENT_DESKTOP=GNOME
export XDG_SESSION_TYPE=x11
pulseaudio --start --exit-idle-time=-1 >/dev/null 2>&1 || true
sudo service dbus start
/usr/bin/gnome-shell --x11 -r > /dev/null 2>&1