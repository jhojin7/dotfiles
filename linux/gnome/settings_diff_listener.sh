#!/bin/bash

gsettings list-recursively | grep "gnome" > xxxx.txt
prev=$(cat xxxx.txt)

while true; do
    gsettings list-recursively | grep "gnome" > xxxx.txt
    cur=$(cat xxxx.txt)
    if [[ "$prev" != "$cur" ]]; then
        echo ">>> CHANGED:"
        diff <(echo "$prev") <(echo "$cur")
    fi
    prev=$(cat xxxx.txt)
    sleep 0.2
done
