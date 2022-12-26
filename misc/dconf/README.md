# dconf settings for GNOME shell extensions

This folder contains settings for certain shell extensions. These have been obtained with the following command:

```zsh
dconf dump /org/gnome/shell/extensions/<extension-name>/ > <extension-name>.dconf
```

replacing `<extension_name>` with the appropriate name.

The settings can be restored with the following command:

```zsh
dconf load /org/gnome/shell/extensions/<extension-name>/ < <extension-name>.dconf
```

replacing `<extension_name>` with the appropriate name.
