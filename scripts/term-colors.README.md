# term-colors

Print the terminal's color palette as blocks — a quick way to eyeball how a
theme renders the 16 ANSI colors in your current terminal.

It draws two rows of swatches: the 8 standard colors (`\e[30m`–`\e[37m`) and the
8 bright colors (`\e[90m`–`\e[97m`, via the 256-color codes 8–15).

## Usage

```sh
term-colors
```

No arguments. Run it after changing your terminal theme to confirm the colors
look right.

## Tuning

A few shell variables at the top of the script control the layout:

| Variable | Default | Effect |
|---|---|---|
| `block_range` | `(0 15)` | Which color indices to draw |
| `block_width` | `4` | Swatch width in spaces |
| `block_height` | `2` | Swatch height in rows |
| `col_offset` | `auto` | Left indent of the block row |

## Credit

The `get_cols` routine is adapted from
[Neofetch](https://github.com/dylanaraps/neofetch) (MIT-licensed; notice kept in
the script header).
