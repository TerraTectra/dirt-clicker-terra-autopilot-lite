# Changelog

## 0.4.0-alpha — 2026-11-15

- Add an independent, default-on auto-chest switch to the compact menu; preserve existing slot preferences.
- Open chests through the stock interaction only with their matching key, one at a time, including keys owned before a chest appears.
- Wait for normal interaction locks, transitions, menus, dialogs and rewards; let in-progress openings finish when the switch is disabled.
- Reconcile idle chest unlock flags against actual key ownership.
- Repair negative world-input lock counts after a run reset, restoring manual clicks even when auto-chests are disabled; leave positive locks intact.
- Validate manual and automatic chest flows, all seven types and exact rewards through a real prestige/new run in an isolated local modified 1.0.1 profile.

## 0.3.1-alpha — 2026-11-14

- Extend the existing relic switch to activate relics directly from inventory, followed by reward confirmation.
- Use the normal one-second hold action and process one stack at a time; respect item locks and existing manual actions.
- Wait on puzzle relics while the separate minigame solver is disabled.
- Cancel a pending automatic opening immediately when its switch is disabled; also cancel a pending puzzle-relic opening if the solver is disabled.
- Guard an automatically consumed stack's UI against the game's deferred-deletion null access.
- Validate the full ordinary-relic and cards-minigame flows in an isolated local modified 1.0.1 profile, including consumption, rewards, cancellation and item filtering.

## 0.3.0-alpha — 2026-11-14

- Replace the permanently expanded purchase panel with a 32x32 hamburger button and an initially closed menu.
- Add independent per-slot switches for all seven functions, preserving existing purchase preferences.
- Add automatic confirmation of already-granted relic rewards through the normal Continue action; achievement rewards remain manual.
- Expand Underground-world auto-purchases to the whole shop, including tools, friends, hats and other available entries.
- Keep the Underground and Molten world gates for shop and skill-tree purchases.
- Support closing with the hamburger, close icon, outside click and Escape; consume the outside closing click.
- Validate menu input, settings, actual friend/hat purchases, gameplay function routing and real relic/achievement popup behavior in an isolated local modified 1.0.1 profile.

## 0.2.0-alpha — 2026-11-14

- Add optional tool auto-purchases after the Underground/CAVE world unlock.
- Add optional ordinary skill-tree auto-purchases after the Molten/LAVA world unlock.
- Add a compact bottom-left panel above the game version with clickable checkbox rows, descriptions and locked-world requirements.
- Save switches per slot in a separate mod preferences file; both default off.
- Respect ordinary DIRT prices, discounts, prerequisites, maximum levels and run transitions. Bound purchases to one per category every 0.35 seconds.
- Check the new behavior and rendered UI in an isolated profile of the local modified 1.0.1 build. Clean Steam compatibility remains unconfirmed.

## 0.1.0-alpha — 2026-11-14

- Initial experimental loader-free derivative of Dirt Autopilot.
- Automatic relic answers and Sand Mines PERFECT-window timing.
- Automatic assignment of hats to eligible, unhatted pals.
- Automatic coffee bean collection.
- Minimal Godot `override.cfg` deployment.
- No independent test on a clean current Steam installation; not yet production-ready.
