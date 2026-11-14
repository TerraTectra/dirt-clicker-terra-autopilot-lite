# Third-party notices and changes

This package is a derivative of **Dirt Autopilot** by **eyyMinda**, source:
https://github.com/eyyMinda/DirtAutopilot

The upstream project is distributed under the GNU General Public License, version 3. Its LICENSE text is included unchanged as `LICENSE`.

Files derived/adapted:
- `terra_autopilot.gd`: timer automation, relic answer submission, hat placement and coffee pickup routines adapted from upstream `features/automations.gd`. Integration and scheduling were changed for a standalone Godot autoload.
- `terra_hats.gd`: copied from upstream `features/hats.gd`, preserving the original hat suitability and naming logic.
- `override.cfg`: new minimalist Godot autoload configuration.

Changes by TerraTectra / assistant collaboration, November 14, 2026:
- Remove dependency on full Godot Mod Loader/DirtLoader (use `override.cfg` autoload).
- Trim out unrelated automation, UI, settings and tools.
- Enable Sand Mines, relic minigame, hat and coffee actions by default.
- Keep all actions in one autoload; add a separate hat helper script.
- Add bilingual installation and rollback guidance.

No game binaries, copyrighted art assets or user save data are redistributed.

This is not an official eyyMinda release and should not be described as independently invented software. Redistribute under GPL-3.0 with attribution and source.
