# VS Code — Gruvbox Material Hard (static)

Frozen copies of sainnhe's gruvbox-material hard dark and hard light with my
terminal palette merged in, packaged as a local theme so they show up in VS
Code's theme picker with nothing installed from the marketplace.

## Using it

`dots install vscode`, then reload VS Code and pick **Gruvbox Material Hard
Dark** or **Gruvbox Material Hard Light** from the theme list
(`Ctrl+K Ctrl+T`). To have the OS light/dark switch pick between them, set
`window.autoDetectColorScheme` and point `workbench.preferredDarkColorTheme` /
`preferredLightColorTheme` at the two labels.

VS Code scans `~/.vscode/extensions` for folders with a `package.json` and reads
their `contributes.themes` — no `extensions.json` entry, no `.vsix`, no install
command. Verified on 1.135 with the files symlinked in by stow (`code
--list-extensions` reports `local.gruvbox-material-static`).

There is nothing to maintain: no marketplace version to track, no rebuild step,
and no generator to re-run. The theme file is the artifact.

Once it's selected, these entries in the synced `settings.json` are dead and can
go: `gruvboxMaterial.*` (darkContrast, darkWorkbench, italicComments) and the
`terminal.ansi*` block in `workbench.colorCustomizations`. Repoint
`workbench.preferredDarkColorTheme` / `preferredLightColorTheme`, which still
name the extension's themes. Keep the `separators.*` entries — those are colour
ids from `alefragnani.separators`, not standard theme keys, so the themes don't
carry them.

## How the colours were derived

Rendered from sainnhe's own generator, not hand-transcribed.
`sainnhe.gruvbox-material` 6.5.2 (2022-12-13, the last release) ships its
palette and its workbench/syntax/semantic builders as plain JS with no `vscode`
imports, so they run standalone. The config matches what I had set for the
extension, with contrast forced to `hard` on both sides:

```
darkContrast:  "hard"    lightContrast:  "hard"
darkWorkbench: "high-contrast"   lightWorkbench: "high-contrast"
darkPalette:   "material"        lightPalette:   "material"
darkCursor:    "white"           lightCursor:    "black"
darkSelection: "grey"            lightSelection: "grey"
italicComments: false            italicKeywords: false
colorfulSyntax: false            highContrast:   false
diagnosticTextBackgroundOpacity: "0%"
```

Each side yields 449 workbench colours, 276 TextMate rules and 26 semantic
rules. Two deliberate deviations from a plain 6.5.2 render:

1. **Eight newer workbench keys** taken from the `snrico-moonlight`
   community fork (v8.0.0) — `editorIndentGuide.activeBackground1`–`6`,
   `editor.inlineValuesBackground`, `editor.inlineValuesForeground`. VS Code
   added these after 6.5.2 froze, so sainnhe's build has no opinion on them.
   The fork is otherwise a strict superset: identical palettes, identical 276
   TextMate rules, and the one key they disagreed on
   (`editorIndentGuide.activeBackground`, `#a8998450` → `#a8998430`) kept the
   original's value. 458 colours total per theme. The light side showed the
   identical relationship: same eight additions, same one alpha
   (`#7c6f6450` → `#7c6f6430`), no token-colour drift.

2. **Terminal palette from my terminals** (`stow/ghostty`, `stow/wezterm`),
   overriding sainnhe's terminal block in the **dark** theme. Only three keys
   actually differed — the rest was already the same gruvbox-material palette:

   | Key | sainnhe | mine |
   | --- | --- | --- |
   | `terminal.ansiBlack` | `#2a2827` | `#5a524c` |
   | `terminal.ansiBrightWhite` | `#ddc7a1` | `#d4be98` |
   | `terminal.selectionBackground` | *(unset)* | `#45403d` |

   `terminal.background` is deliberately left unset so the integrated terminal
   blends with the panel instead of becoming a `#101010` box. Note my terminals
   set `ansiBrightBlack` to `#5a524c`, the same as black; the theme uses
   `#928374` (grey1) so bright black stays legible, matching `misc/theme.txt`.

   My terminals are dark-only, so there is nothing to merge into the light
   theme — a dark ansi palette on a `#f9f5d7` background would be unreadable,
   and sainnhe's light block stands as-is. The one override that does
   generalise is the selection tone: my dark choice (`#45403d`) lands on
   hard-dark `bg6` (`#46403d`), so light takes hard-light `bg6` (`#e0cfa9`) —
   the same tone its own `editor.selectionBackground` uses.

The interface-colour reference for non-editor theming lives in `misc/theme.txt`.

## Editing it

Edit the files under `themes/` in the repo — the installed paths are symlinks to
them — then reload the window. `label` in `package.json` is the name shown in
the picker; `icon.png` is sainnhe's own, carried over from 6.5.2, and shows in
the Extensions view rather than the picker.
