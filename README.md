# Terra Autopilot Lite (Dirt Clicker)

**Experimental, loader-free community derivative of [Dirt Autopilot](https://github.com/eyyMinda/DirtAutopilot) by eyyMinda.** Not affiliated with the game developer or the upstream mod author.

## What it does

- Automatically starts the Sand Mines timer game and stops near 00:00 for the intended PERFECT window (0.05 seconds remaining).
- Submits solutions to relic minigames automatically (including words and cards) after a short delay.
- Equips new hats on eligible, unhatted pals in order of effectiveness, leaving an item queued when no suitable pal is available. Does not interrupt manual name typing.
- Picks up the coffee bean when active, without moving the mouse.

No GUI, no installer, no mod loader, no modification of game executable or PCK. All features are currently enabled together.

## Compatibility and limitations

**ALPHA — not publicly validated.** Smoke-tested with a local Dirt Clicker build displaying version 1.0.1 and a customized game PCK. The current official Steam build and all functions in an unmodified game have **not** been verified. No promise of cross-version compatibility or safe achievement behavior.

Scripts access internal, undocumented game objects and can break after game updates. Timed outcomes depend on framerate. Coffee and hat automation have been checked for startup script parsing but not yet observed end-to-end in a public game build. Use at your own risk and back up your saves.

## Install (Windows, manual)

1. Exit Dirt Clicker. Make a backup of your saved games.
2. Open the directory containing `Dirt Clicker.exe`.
3. **If `override.cfg` already exists, stop and merge the autoload entry manually. Never replace another mod's `override.cfg`.** If no such file exists, copy `override.cfg` from this package.
4. Copy `terra_autopilot.gd` and `terra_hats.gd` beside `Dirt Clicker.exe`.
5. Start the game. The mod is active automatically for every save slot.

For an existing `override.cfg`, preserve all other autoloads and add under `[autoload]`:

```ini
TerraAutopilot="*res://terra_autopilot.gd"
```

Do not add two `[autoload]` sections; merge into the existing one. Avoid installing at the same time as the original Dirt Autopilot, as both can process the same events.

## Uninstall

Close the game. Remove the TerraAutopilot autoload line from `override.cfg`, then remove both `.gd` files. Delete `override.cfg` only if it contains no other settings and was created exclusively for this mod. The mod itself does not edit saves or game archives.

## Credits and license

- Original automation and hat suitability/naming logic: [eyyMinda / Dirt Autopilot](https://github.com/eyyMinda/DirtAutopilot), GPL-3.0.
- Loader-free integration, reduced feature set and modifications: TerraTectra / Terra Autopilot Lite, 2026.
- License: GNU GPL v3.0; see `LICENSE`.
- All sources needed for this package are included. Game resources, executables and saves are not distributed.

See `NOTICE.md` and `CHANGELOG.md` for derivative attribution and modifications.
