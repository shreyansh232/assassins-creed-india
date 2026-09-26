# Session handoff — AC Hindustan Agra MVP (Issue #1 art pass)

Date: 2026-09-27. Branch state: everything UNCOMMITTED (base `62a0f2d`).

## Where things stand
- Issue #1 art pass partially done: bazaar (Kenney stalls/cart/lanterns) and fort
  (tinted curtain walls, gate towers + marble domes) are asset-wired and Playwright-verified.
- Mouse look shipped: click captures mouse, Esc releases, SpringArm3D camera, WASD is facing-relative.
- User verdict: still unrealistic. Last ask before handoff: **"give the player a body"**
  (current player/guard/crowd figures are capsule + turban-sphere + sash-box procedural builds).
- Next session: start with the player body, then keep closing the realism gap.

## Changed / new files (all uncommitted)
- M `scenes/agra.tscn` — SpringArm3D camera rig under Player.
- M `scripts/player.gd` — mouse look, facing-relative movement.
- M `scripts/agra_blockout.gd` (360 lines, hard limit 400) — `_prop`/`_tint` asset helpers,
  `_fort_assets`, asset-wired `_stall`, hidden-CSG-collision pattern.
- M `tests/test_scene_wiring.gd` — new camera path.
- NEW `assets/kenney/` (272KB, CC0, see `ATTRIBUTION.md`) — only models actually referenced.
- NEW `tests/test_art_pass.gd`, `scripts/capture_shots.gd`, `e2e/` (report + `agra.e2e.mjs`).

## Verify (must all pass before claiming done)
- `godot --headless --path . -s tests/test_art_pass.gd` → `ART_OK` (+ the other 8 tests)
- `godot --path . --resolution 1280x720 -s scripts/capture_shots.gd` (needs display, regenerates `e2e/shots/`)
- `node agra.e2e.mjs` in `e2e/` → `E2E_OK` (runs Godot suite + Brave/Playwright pixel + interaction checks)

## Gotchas learned the hard way
- Failing `assert` in headless `-s` scripts HANGS (debugger break) — always run with a sleep/kill guard.
- Kenney 2.0 kits need their external `Textures/colormap.png` next to the .glb or models import white;
  palettes differ per kit → keep each kit in its own subfolder. Run `--import` after adding models.
- `visible=false` on CSG keeps its collision — used for hidden collision boxes. Don't break this.
- Fog density 0.012 is the tuned value (0.02 washed out mid-range); far-city ring sits at 55–70m on 160m ground.
- `stairs-stone.glb` was tried for ghats and reverted (read as rubble) — CSG steps stay. Deleted from repo.

## Suggested next slices (in order)
1. Player body (user's explicit ask): replace capsule trio in `_dress` — best free option not yet found
   (Quaternius Animated Men/Women is itch-only download friction; Poly Pizza needs login).-alt: richer
   procedural body (legs, arms, angarkha tunic, sash, turban with jewel) + keep `Body`/`Turban` node names
   (tests + capture depend on them).
2. Houses + ground: box houses and flat earth are the next-biggest slop after characters.
3. Crowd variety (heads/poses/colors), then Taj scaffold dressing.
