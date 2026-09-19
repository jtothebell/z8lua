#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
make -j4 a MYCFLAGS= MYLDFLAGS= MYLIBS=
test_binary=$(mktemp "${TMPDIR:-/tmp}/eris-test.XXXXXX")
trap 'rm -f "$test_binary"' EXIT
${CXX:-c++} -std=c++17 -I. tests/eris-runner.cpp liblua.a -lm -o "$test_binary"
"$test_binary" tests/eris-open-upvalues.lua
