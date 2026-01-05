#!/bin/sh
# Entrypoint script for nenga-print Docker image
# Use /work/Makefile if exists, otherwise /app/Makefile

umask 022

if [ -f /work/Makefile ]; then
    MAKEFILE=/work/Makefile
else
    MAKEFILE=/app/Makefile
fi

cd /work

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
