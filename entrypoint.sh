#!/bin/sh
# Entrypoint script for nenga-print Docker image
# Use /work/Makefile if exists, otherwise /app/Makefile

if [ -f /work/Makefile ]; then
    MAKEFILE=/work/Makefile
else
    MAKEFILE=/app/Makefile
fi

case "$1" in
    make)
        shift
        exec make -f "$MAKEFILE" "$@"
        ;;
    clean|demo)
        exec make -f "$MAKEFILE" "$1"
        ;;
    "")
        exec make -f "$MAKEFILE"
        ;;
    *)
        exec "$@"
        ;;
esac
