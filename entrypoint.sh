#!/bin/sh
# Entrypoint script for nenga-print Docker image
# Transparently handles make commands to use /app/Makefile

case "$1" in
    make)
        shift
        exec make -f /app/Makefile "$@"
        ;;
    clean)
        exec make -f /app/Makefile clean
        ;;
    demo)
        exec make -f /app/Makefile demo
        ;;
    "")
        exec make -f /app/Makefile
        ;;
    *)
        exec "$@"
        ;;
esac
