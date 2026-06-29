#!/bin/bash
set -e

git clone https://github.com/flutter/flutter.git \
  --branch 3.41.9 \
  --depth 1

export PATH="$PWD/flutter/bin:$PATH"

flutter --version

flutter config --enable-web

flutter pub get

flutter build web --release