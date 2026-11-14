# Third-party notices and changes

This package is a derivative of **Dirt Autopilot** by **eyyMinda**, source:
https://github.com/eyyMinda/DirtAutopilot

The upstream project is distributed under the GNU General Public License, version 3. Its LICENSE text is included unchanged as `LICENSE`.

Files derived/adapted:
- `terra_autopilot.gd`: timer automation, relic answer submission, hat placement, coffee pickup and chest-opening routines adapted from upstream `features/automations.gd`. Integration and scheduling were changed for a standalone Godot autoload.
- `terra_hats.gd`: copied from upstream `features/hats.gd`, preserving the original hat suitability and naming logic.
- `override.cfg`: new minimalist Godot autoload configuration.
- `terra_purchases.gd` and `terra_purchase_panel.gd`: new optional auto-purchase logic and native checkbox panel by TerraTectra, 2026, distributed as part of this GPL-3.0 derivative.

Changes by TerraTectra / assistant collaboration, November 14, 2026:
- Remove dependency on full Godot Mod Loader/DirtLoader (use `override.cfg` autoload).
- Trim out unrelated automation, UI, settings and tools.
- Enable Sand Mines, relic minigame, hat and coffee actions by default.
- Keep all actions in one autoload; add a separate hat helper script.
- Add bilingual installation and rollback guidance.
- Version 0.2: add opt-in tool and skill-tree auto-purchases, gated by the Underground/CAVE and Molten/LAVA worlds; add a bottom-left native panel and per-slot preferences in a separate file.
- Version 0.3: replace the permanent panel with a compact hamburger menu, expose independent controls for every function, expand auto-purchases to the whole shop and add relic reward acceptance. The reward acceptance uses the game's own close/continue action, following the same approach as the upstream popup automation.
- Version 0.3.1: adapt the upstream inventory relic-opening approach and deferred item-UI deletion guard; integrate opening and reward confirmation under the existing relic switch, with cancellation of pending automatic actions.

- Version 0.4 (November 15, 2026): adapt the upstream chest opener for independent per-slot control and serial stock interactions; add key-state reconciliation and a narrowly scoped repair for invalid negative world-input lock counts.

No game binaries, copyrighted art assets or user save data are redistributed.

This is not an official eyyMinda release and should not be described as independently invented software. Redistribute under GPL-3.0 with attribution and source.
