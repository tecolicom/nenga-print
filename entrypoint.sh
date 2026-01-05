#!/bin/sh
# Entrypoint script for nenga-print Docker image
# Use local Makefile if exists, otherwise /app/Makefile

umask 022

if [ -f Makefile ]; then
    MAKEFILE=Makefile
else
    MAKEFILE=/app/Makefile
fi

case "$1" in
    make)
        shift
        exec make -f "$MAKEFILE" "$@"
        ;;
    clean|demo|init)
        exec make -f "$MAKEFILE" "$1"
        ;;
    "")
        exec make -f "$MAKEFILE"
        ;;
    *)
        exec "$@"
        ;;
esac
