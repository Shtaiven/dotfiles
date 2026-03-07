#!/usr/bin/env bash
# Back up dconf configuration for GNOME extensions

dconf dump "/org/gnome/shell/extensions/${1}/" >"org.gnome.shell.extensions.${1}.dconf"
