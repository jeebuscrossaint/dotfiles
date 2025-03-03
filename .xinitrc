#!/bin/sh

xrdb -merge ~/.Xresources

xsetroot -cursor_name left_ptr &

i3


#echo "All window managers failed, starting xterm"
#exec xterm
