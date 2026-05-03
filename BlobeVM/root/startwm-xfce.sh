#!/bin/bash

setterm blank 0
setterm powerdown 0
pulseaudio --start --exit-idle-time=-1 >/dev/null 2>&1 || true
if [ -f "${HOME}"/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml ]; then
  sed -i \
    '/use_compositing/c <property name="use_compositing" type="bool" value="false"/>' \
    "${HOME}"/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
fi
/usr/bin/xfce4-session > /dev/null 2>&1