# Nudge Cell
**Nudge Cell** is a plugin for Roblox Studio that is used for quickly adjusting
the occupancy of terrain cells.

Activating the tool will display a box in front of the camera. This box wraps
around the current terrain cell, and displays its current occupancy value. When
the user clicks the yellow adjustment handle, a slider appears, which is used to
finely adjust the occupancy.

![](assets/demo/demo_small.gif)

Holding `Ctrl` while adjusting will snap to a smaller increment.

![](assets/demo/snap_small.gif)

See the [demo](assets/demo) directory for more demonstrations.

## Installation
Nudge Cell is available for installation from within Studio via the Toolbox:

1. Open the Toolbox.
2. Select the Plugins category.
3. Search for "Nudge Cell".
4. Select **Nudge Cell** by **Anaminus**.
4. Click the Install button.

It can also be installed from [the website][asset]. Installing free copies of
Nudge Cell should be avoided, as they will have been authored by untrusted
providers. Instead, it is recommended that you compile the plugin yourself [from
source](#user-content-building).

[asset]: https://www.roblox.com/library/6785866759

## Permissions
Nudge Cell requires **no** permissions to operate.

## Building
This plugin can be built manually with **[rbxmk][rbxmk] v0.7.2 or later**.

```bash
rbxmk run build.rbxmk.lua
```

This builds the plugin as the default `NudgeCell.rbxm`, which can be moved to
the user's configured plugin folder.

The plugin may instead be built directly to the plugins folder by including it
as a root directory (`$PLUGINS_FOLDER` is replaced by the folder path):

```bash
rbxmk run build.rbxmk.lua \
--include-root $PLUGINS_FOLDER \
$PLUGINS_FOLDER/NudgeCell.rbxm
```

Compatible file extensions are `rbxm`, which writes as the binary model format,
and `rbxmx`, which writes as the XML model format.

For asset development, the user's configured asset directory may be included as
a second argument:

```bash
rbxmk run build.rbxmk.lua \
--include-root $PLUGINS_FOLDER \
--include-root $ASSETS_FOLDER \
$PLUGINS_FOLDER/NudgeCell.rbxm \
$ASSETS_FOLDER
```

This will copy assets to the asset folder, and compile the plugin to point to
these assets instead of uploaded versions.

[rbxmk]: https://github.com/Anaminus/rbxmk

## License
The source code and assets for Nudge Cell, except for the [logo](assets/logo),
are licensed under [MIT](LICENSE).
