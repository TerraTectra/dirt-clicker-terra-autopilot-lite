# Terra Autopilot Lite v0.4.0-alpha (Dirt Clicker)

**Experimental, loader-free community derivative of [Dirt Autopilot](https://github.com/eyyMinda/DirtAutopilot) by eyyMinda.** Not affiliated with the game developer or the upstream mod author.

## What it does

- Automatically starts the Sand Mines timer game and stops near 00:00 for the intended PERFECT window (0.05 seconds remaining).
- Submits solutions to relic minigames automatically (including words and cards) after a short delay.
- Equips new hats on eligible, unhatted pals in order of effectiveness, leaving an item queued when no suitable pal is available. Does not interrupt manual name typing.
- Picks up the coffee bean when active, without moving the mouse.

## Compact mod menu

A single 32x32 hamburger button appears at the bottom left, above the game version. The menu starts closed. Click the button to see eight independent Russian-language checkbox rows: Sand Mines timer, relic minigame answers, hat placement, coffee collection, relic reward acceptance, chest opening, whole-shop auto-purchases, and skill-tree auto-purchases.

Click any part of a row to toggle it. Close the menu using the hamburger again, the close icon, Escape or an outside click. An outside closing click is consumed instead of passed through to the playfield.

The four original automations, automatic relic reward acceptance and automatic chest opening default ON. Shop and skill-tree auto-purchases default OFF. All eight choices are saved independently per slot; 0.2 purchase preferences are preserved on upgrade.

Automatic relic acceptance now handles the whole inventory-to-reward flow: it opens an unlocked relic stack using the normal one-second hold action, waits for its minigame if any, and confirms the granted relic reward with the normal Continue action. Only one relic stack is processed at a time. Locked relics and regular inventory items are left untouched. Puzzle relics wait while the separate minigame solver is disabled. Disabling the relic option cancels an automatic opening still in progress without consuming its items. Existing manual relic actions are not canceled. Achievement reward popups remain manual.

Automatic chest opening uses the matching key and the normal game animations and rewards, one chest at a time. It supports both a newly acquired key and a key owned before the chest appears. It waits for menus, dialogs, hat selection, minigames and existing reward popups. Disabling the switch preserves manual opening and lets an already-started animation finish. With relic acceptance disabled, chest reward popups require manual confirmation.

A separate fix repairs negative world-input lock counts caused by a deferred release after a run reset. This invalid state can prevent manual chest clicks despite owning the key. The fix works with auto-chests disabled and preserves valid game input locks.

- **Shop:** unlocked by reaching the Underground world (`WORLD_CAVE`). Buys every available shop category, including tools, friends, hats and other entries, starting with the cheapest affordable next purchase.
- **Skills:** unlocked by reaching the Molten world (`WORLD_LAVA`). Buys affordable upgrades in the ordinary skill tree, starting with the cheapest next level.

Locked purchase rows show which world is required. Preferences use the mod's own `user://terra_autopilot_lite.cfg`. World unlocks use the game's persistent meta stats, so returning to an earlier world or prestiging does not remove an earned unlock.

Purchases use DIRT only, the game's normal purchase function, current discounts and level limits. At most one purchase per enabled category occurs every 0.35 seconds. Spending stops in settings/dialog overlays, during transitions and outside an active run; the ordinary skill-tree view allows automation to continue. The panel is hidden outside a run and during other overlay menus.

There is no installer or separate mod loader, and no modification of the game executable or PCK.

## Compatibility and limitations

**ALPHA — not publicly validated.** Tested with a local Dirt Clicker build displaying version 1.0.1 and a customized game PCK. Auto-purchases, world gates, slot preferences, mouse input and panel layout were checked in an isolated test profile. Manual chest clicks, automatic opening of all seven chest types, reward counts, serialization and input repair were also checked through a real prestige and a new run in a separate profile. The current official Steam build and all functions in an unmodified game have **not** been verified. No promise of cross-version compatibility or safe achievement behavior.

Scripts access internal, undocumented game objects and can break after game updates. Timed outcomes depend on framerate. Coffee and hat automation have been checked for startup script parsing but not yet observed end-to-end in a public game build. Use at your own risk and back up your saves.

## Install (Windows, manual)

1. Exit Dirt Clicker. Make a backup of your saved games.
2. Open the directory containing `Dirt Clicker.exe`.
3. **If `override.cfg` already exists, stop and merge the autoload entry manually. Never replace another mod's `override.cfg`.** If no such file exists, copy `override.cfg` from this package.
4. Copy all four `.gd` files (`terra_autopilot.gd`, `terra_hats.gd`, `terra_purchases.gd`, `terra_purchase_panel.gd`) beside `Dirt Clicker.exe`.
5. Start or restart the game. Use the corner menu to choose functions; enable purchase options after their world unlocks.

For an existing `override.cfg`, preserve all other autoloads and add under `[autoload]`:

```ini
TerraAutopilot="*res://terra_autopilot.gd"
```

Do not add two `[autoload]` sections; merge into the existing one. Avoid installing at the same time as the original Dirt Autopilot, as both can process the same events.

## Uninstall

Close the game. Remove the TerraAutopilot autoload line from `override.cfg`, then remove the four `.gd` files. Delete `override.cfg` only if it contains no other settings and was created exclusively for this mod. The mod stores its switches in a separate preferences file; it does not rewrite game save files or archives directly. Auto-purchases change normal gameplay progress and are saved by the game in the usual way.

## Credits and license

- Original automation and hat suitability/naming logic: [eyyMinda / Dirt Autopilot](https://github.com/eyyMinda/DirtAutopilot), GPL-3.0.
- Loader-free integration, reduced feature set and modifications: TerraTectra / Terra Autopilot Lite, 2026.
- License: GNU GPL v3.0; see `LICENSE`.
- All sources needed for this package are included. Game resources, executables and saves are not distributed.

See `NOTICE.md` and `CHANGELOG.md` for derivative attribution and modifications.
