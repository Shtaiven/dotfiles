# VS Code — Gruvbox Material Hard (static)

Frozen copies of sainnhe's gruvbox-material hard dark and hard light with my
terminal palette merged in, packaged as a local theme so they show up in VS
Code's theme picker with nothing installed from the marketplace. Each side also
gets two flattened variants.

| Theme | Surfaces | Seams |
| --- | --- | --- |
| Gruvbox Material Hard Dark | layered `#202020` / `#131414` / `#070808` | sainnhe's, mixed |
| Gruvbox Material Hard Dark Flat | all `#101010` | all `#2a2827` |
| Gruvbox Material Hard Dark Borderless | all `#101010` | splits only |
| Gruvbox Material Hard Light | layered `#f9f5d7` / `#f3eac7` / `#f2e5bc` | sainnhe's, mixed |
| Gruvbox Material Hard Light Flat | all `#fbf1c7` | all `#e0cfa9` |
| Gruvbox Material Hard Light Borderless | all `#fbf1c7` | splits only |

## Using it

`dots install vscode`, then reload VS Code and pick one from the theme list
(`Ctrl+K Ctrl+T`). To have the OS light/dark switch pick between two of them,
set `window.autoDetectColorScheme` and point
`workbench.preferredDarkColorTheme` / `preferredLightColorTheme` at the labels.

VS Code scans `~/.vscode/extensions` for folders with a `package.json` and reads
their `contributes.themes` — no `extensions.json` entry, no `.vsix`, no install
command. Verified on 1.135 with the files symlinked in by stow (`code
--list-extensions` reports `local.gruvbox-material-static`).

There is nothing to maintain: no marketplace version to track, no rebuild step,
and no generator to re-run. The theme files are the artifact.

Once one is selected, these entries in the synced `settings.json` are dead and
can go: `gruvboxMaterial.*` (darkContrast, darkWorkbench, italicComments) and
the `terminal.ansi*` block in `workbench.colorCustomizations`. Repoint
`workbench.preferredDarkColorTheme` / `preferredLightColorTheme`, which still
name the extension's themes. Keep the `separators.*` entries — those are colour
ids from `alefragnani.separators`, not standard theme keys, so the themes don't
carry them.

## How the base colours were derived

Rendered from sainnhe's own generator, not hand-transcribed.
`sainnhe.gruvbox-material` 6.5.2 (2022-12-13, the last release) ships its
palette and its workbench/syntax/semantic builders as plain JS with no `vscode`
imports, so they run standalone. The config matches what I had set for the
extension, with contrast forced to `hard` on both sides:

```
darkContrast:  "hard"            lightContrast:  "hard"
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
   original's value. 458 colours per base theme. The light side showed the
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

   Note my terminals set `ansiBrightBlack` to `#5a524c`, the same as black; the
   theme uses `#928374` (grey1) so bright black stays legible, matching
   `misc/theme.txt`.

   My terminals are dark-only, so there is nothing to merge into the light
   theme — a dark ansi palette on a `#f9f5d7` background would be unreadable,
   and sainnhe's light block stands as-is. The one override that does
   generalise is the selection tone: my dark choice (`#45403d`) lands on
   hard-dark `bg6` (`#46403d`), so light takes hard-light `bg6` (`#e0cfa9`) —
   the same tone its own `editor.selectionBackground` uses.

The interface-colour reference for non-editor theming lives in `misc/theme.txt`.

## The Flat and Borderless variants

**Flat** pulls all 14 chrome surface keys to one colour — editor, tab bar and
tabs, sidebar, activity bar, panel and its section headers, status bar, title
bar. Dark uses ghostty's `#101010` (`stow/ghostty`), light uses `#fbf1c7`. All
13 chrome seams plus `terminal.border` then take a single divider tone, since
with one flat surface everywhere the borders are the only thing left giving the
layout structure. Five of those seams were unset upstream and had to be added:
`sideBar.border`, `sideBarSectionHeader.border`, `editorGroupHeader.border`,
`activityBarTop.border` and `commandCenter.border` — without them there is no
line at all between sidebar and editor, or under the tab bar.

**Borderless** keeps the flat surfaces but makes every chrome seam
`#00000000`, except the two that separate split panes: `editorGroup.border`
(editor splits) and `terminal.border` (terminal splits).

Three things worth knowing about how they're built:

- **The divider tone is contrast-matched, not index-matched.** Dark's divider
  is `#2a2827`, hard-dark `bg2`, sitting at a 1.297 contrast ratio against
  `#101010`. Taking the same palette index on the light side gives hard-light
  `bg2` — which *is* `#fbf1c7`, the light surface, for a ratio of 1.000 and no
  visible line. So light matches the relationship instead: `bg6` `#e0cfa9` at
  1.354. For reference on `#fbf1c7`: `bg4` `#f2e5bc` = 1.108 (sainnhe's own
  light border tone, but too faint against a flattened surface), `bg5`
  `#ebdbb2` = 1.209, `bg7` `#d5c4a1` = 1.512.

- **Active-state indicators are kept, in both variants.** `tab.activeBorder`,
  `activityBar.activeBorder` and `panelTitle.activeBorder` are not seams. Flat
  makes `tab.activeBackground` and `tab.inactiveBackground` identical, so
  `tab.activeBorder` becomes the only cue for which file is open — dropping it
  in the name of "no borders" would leave the tab bar unreadable.

- **Build them with an explicit key allowlist, never a find-and-replace on the
  value.** `button.foreground`, `badge.foreground`,
  `activityBarBadge.foreground`, `extensionButton.prominentForeground` and
  `extensionBadge.remoteForeground` all hold `#202020` in the dark theme, so
  replacing that value globally silently wrecks five foregrounds. Replacing the
  old *divider* value globally is just as bad: on the light side it swept up
  `diffEditor.diagonalFill`, `editorHoverWidget.border` and
  `notificationCenterHeader.background`, which are legitimately `bg6` upstream.

`terminal.background` is left unset in every theme so the integrated terminal
inherits `panel.background` and tracks it. `terminal.border` does need setting
explicitly in the variants: it defaults to `panel.border`, so it would vanish
along with it in Borderless.

## What is not a theme colour

The drop shadows on the sidebar and panel edges cannot be reached from a theme
file. VS Code 1.135 draws them from hardcoded `--vscode-shadow-md` /
`--vscode-shadow-depth-x` CSS variables, and the rules are gated on
`.monaco-workbench.vs` — the light-theme class — which is why they show up on
light themes and not dark ones. `scrollbar.shadow` and `widget.shadow` are
unrelated: the first is the shadow indicating scrolled content, the second is
pop-up lift. Both keep sainnhe's values here.

The switch is a setting, not a colour:

```jsonc
"workbench.shadows": false      // adds a `no-shadows` class that zeroes them
```

## Editing it

Edit the files under `themes/` in the repo — the installed paths are symlinks to
them — then reload the window. `label` in `package.json` is the name shown in
the picker; `icon.png` is sainnhe's own, carried over from 6.5.2, and shows in
the Extensions view rather than the picker.
