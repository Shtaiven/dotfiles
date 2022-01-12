#!/usr/bin/env bash
#
# A script for showing terminal colors.
# get_cols adapted from Neofetch
#
# Neofetch: A command-line system information tool written in bash 3.2+.
# https://github.com/dylanaraps/neofetch
#
# The MIT License (MIT)
#
# Copyright (c) 2015-2021 Dylan Araps
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

block_range=(0 15)
block_width=4
block_height=2
col_offset="auto"

get_cols() {
    local blocks blocks2 cols

    # Convert the width to space chars.
    printf -v block_width "%${block_width}s"

    # Generate the string.
    for ((block_range[0]; block_range[0]<=block_range[1]; block_range[0]++)); do
        case ${block_range[0]} in
            [0-7])
                printf -v blocks  '%b\e[3%bm\e[4%bm%b' \
                    "$blocks" "${block_range[0]}" "${block_range[0]}" "$block_width"
            ;;

            *)
                printf -v blocks2 '%b\e[38;5;%bm\e[48;5;%bm%b' \
                    "$blocks2" "${block_range[0]}" "${block_range[0]}" "$block_width"
            ;;
        esac
    done

    # Convert height into spaces.
    printf -v block_spaces "%${block_height}s"

    # Convert the spaces into rows of blocks.
    [[ "$blocks"  ]] && cols+="${block_spaces// /${blocks}[mnl}"
    [[ "$blocks2" ]] && cols+="${block_spaces// /${blocks2}[mnl}"

    # Add newlines to the string.
    cols=${cols%%nl}
    cols=${cols//nl/
[${text_padding}C${zws}}

    # Add block height to info height.
    ((info_height+=block_range[1]>7?block_height+2:block_height+1))

    case $col_offset in
        "auto") printf '\n\e[%bC%b\n' "$text_padding" "${zws}${cols}" ;;
        *) printf '\n\e[%bC%b\n' "$col_offset" "${zws}${cols}" ;;
    esac

    unset -v blocks blocks2 cols
}

get_cols