#!/bin/sh

xrdb -merge ~/.Xresources

xsetroot -cursor_name left_ptr &

echo "Starting .xinitrc" >> ~/xinit_log.txt

log_and_exec() {
	echo "Attempting to start $1" >> ~/xinit_log.txt
	$1 >> ~/xinit_log.txt 2>&1
	echo "$1 exited with status $?" >> ~/xinit_log.txt
}

log_and_exec berry


echo "All window managers failed, starting xterm"
exec xterm
