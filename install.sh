#!/bin/bash

mkdir -p "$HOME/.local/share/liteconf/"
cp liteconf "$HOME/.local/bin/"
cp configure *.makefile "$HOME/.local/share/liteconf/"
