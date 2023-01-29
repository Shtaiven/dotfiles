#!/usr/bin/env bash
# Load dconf configuration for GNOME extensions

dconf load "/org/gnome/shell/extensions/${1}/" < "org.gnome.shell.extensions.${1}.dconf"

