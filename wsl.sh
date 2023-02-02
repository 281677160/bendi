#!/bin/bash

sudo tee -a /etc/wsl.conf << EOF > /dev/null
[interop]
appendWindowsPath = false
EOF
exit
