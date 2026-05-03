#!/bin/bash
setterm blank 0
setterm powerdown 0
pulseaudio --start --exit-idle-time=-1 >/dev/null 2>&1 || true
/usr/bin/cinnamon-session > /dev/null 2>&1