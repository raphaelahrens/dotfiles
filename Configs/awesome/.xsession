#!/bin/sh

#Language
LANG=en_GB.UTF-8;export LANG
LC_CTYPE=de_DE.UTF-8;export LC_CTYPE
LC_COLLATE=de_DE.UTF-8;export LC_COLLATE
LC_TIME=de_DE.UTF-8;export LC_TIME
LC_NUMERIC=de_DE.UTF-8;export LC_NUMERIC
LC_MONETARY=de_DE.UTF-8;export LC_MONETARY
LC_MESSAGES=en_GB.UTF-8;export LC_MESSAGES

#env
. ~/.enviroment

DEFAULT_SESSION="/usr/bin/ssh-agent /usr/local/bin/awesome"


case "$1" in
     xmonad) exec /usr/local/bin/xmonad ;;
     twm) exec /usr/local/bin/twm ;;
     *) exec $DEFAULT_SESSION ;;
esac
