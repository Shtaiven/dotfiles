#!/usr/bin/env bash
# Install webi if not installed already, then install listed packages
if ! command -v webi &> /dev/null
then
    echo "webi not found. Installing webi..."
    source $(dirname "$0")/webi.sh
fi

cat $(dirname "$0")/webi-packages.txt | xargs webi

