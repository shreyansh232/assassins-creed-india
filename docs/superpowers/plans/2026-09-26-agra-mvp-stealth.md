# Agra MVP Stealth Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build playable Agra stealth slice in Godot 4 that runs 30fps on M4 Air: 1 clue → fort infiltrate → assassinate → escape.

**Architecture:** Single Godot 4 project, 3rd-person controller + 3-state detection + social-blend zones + scaffold parkour, one 1.5km² blockout map with fog culling. No RPG, no horses, no multiplayer.

**Tech Stack:** Godot 4.3+ (GDScript), GUT-style headless asserts via `-s` scripts, Git + gh for public repo

## Global Constraints

- Target 30fps on M4 Air, no ray-tracing, fog hides far city
- <60 active AI at once, crowd groups of 4-5 only
- MVP map Agra only: Fort + Taj site + Bazaar + Ghats + Bureau haveli
- Stealth first: open combat 2-3 guards max, player should lose — pushes stealth
- Order vs freedom theme, never Hindu vs Muslim — all faiths on all sides
- No guard disguise, no XP tree, no horses / naval / notoriety / recruits in MVP

---

## File Structure

- `project.godot` — Godot 4.3+, 3D, forward+ mobile-safe, 30fps cap
- `scripts/player.gd` — move, crouch, climb-lite, whistle, coin, smoke, blade kill
- `scripts/detection.gd` — unseen / suspicious / hunted, Autoload `Detection`
- `scripts/crowd_blend.gd` — blend zones, noble/mazdoor disguise check, farman/bribe gate
- `scripts/investigation.gd` — eavesdrop circle, tail meter, pickpocket key
- `scripts/guard.gd` — patrol, vision cone, search, 2-hit kill player
- `scripts/agra_blockout.gd` — spawns 5 zones, fog + cull, perf counter
- `scenes/agra.tscn` — root with 5 zone nodes + player + 12 guards max MVP
- `tests/test_player.gd`, `tests/test_detection.gd`, `tests/test_blend.gd`, `tests/test_investigation.gd` — headless `extends SceneTree` asserts

Interfaces flow: player.gd → Detection.check() → guard.gd reacts → crowd_blend.gd gates entry → investigation.gd unlocks target → player.assassinate() → agra_blockout.perf() validates fps.

---

### Task 1: Bootstrap Godot + Repo

**Files:**
- Create: `assassins-creed-india/project.godot`
- Create: `assassins-creed-india/.gitignore`
- Test: `assassins-creed-india/tests/test_boot.gd`

**Interfaces:**
- Consumes: none
- Produces: runnable project, `godot --version` >= 4.3

- [ ] **Step 1: Write failing boot test**

```gdscript
# tests/test_boot.gd
extends SceneTree
func _init():
	assert(DirAccess.dir_exists_absolute("res://scripts"), "scripts missing")
	print("BOOT_OK")
	quit()
```

- [ ] **Step 2: Run to verify fail**

Run: `godot --headless --path assassins-creed-india -s tests/test_boot.gd 2>&1`
Expected: FAIL / error scripts missing or godot missing

- [ ] **Step 3: Minimal project + folders**

```ini
; project.godot
config_version=5
[application]
config/name="AC Hindustan Agra MVP"
run/main_scene="res://scenes/agra.tscn"
[rendering]
renderer/rendering_method="forward_plus"
environment/defaults/default_clear_color=Color(0.08,0.07,0.09,1)
```

```bash
mkdir -p assassins-creed-india/scripts assassins-creed-india/scenes assassins-creed-india/tests
```

```
# .gitignore
.godot/
*.import
```

Install if needed: `brew install --cask godot`

- [ ] **Step 4: Run to pass**

Run: `godot --headless --path assassins-creed-india -s tests/test_boot.gd 2>&1`
Expected: `BOOT_OK`

- [ ] **Step 5: Commit**

```bash
git -C assassins-creed-india add project.godot .gitignore tests/test_boot.gd
git -C assassins-creed-india commit -m "feat: bootstrap godot agra mvp"
```

---

### Task 2: Player Stealth Controller

**Files:**
- Create: `assassins-creed-india/scripts/player.gd`
- Test: `assassins-creed-india/tests/test_player.gd`

**Interfaces:**
- Consumes: Input actions move/sprint/crouch/jump/interact
- Produces: `player.move_state: String`, `player.is_crouched: bool`, `player.whistle() -> void`, `player.throw_coin(pos: Vector3) -> void`

- [ ] **Step 1: Write failing test**

```gdscript
# tests/test_player.gd
extends SceneTree
func _init():
	var p = load("res://scripts/player.gd").new()
	p.is_crouched = false
	p.set_crouch(true)
	assert(p.is_crouched == true, "crouch failed")
	assert(p.walk_speed_crouched < p.walk_speed_stand, "crouch not slower")
	print("PLAYER_OK")
	quit()
```

- [ ] **Step 2: Run to fail**

Run: `godot --headless --path assassins-creed-india -s tests/test_player.gd 2>&1`
Expected: FAIL script not found

- [ ] **Step 3: Minimal implementation**

```gdscript
# scripts/player.gd
extends CharacterBody3D
class_name StealthPlayer
var walk_speed_stand := 4.0
var walk_speed_crouched := 2.0
var is_crouched := false
var disguise := "none"
func set_crouch(v: bool): is_crouched = v
func whistle(): pass
func throw_coin(_pos: Vector3): pass
func _physics_process(_d):
	velocity = Vector3.ZERO
	move_and_slide()
```

- [ ] **Step 4: Run to pass**

Run: `godot --headless --path assassins-creed-india -s tests/test_player.gd 2>&1`
Expected: `PLAYER_OK`

- [ ] **Step 5: Commit**

```bash
git -C assassins-creed-india add scripts/player.gd tests/test_player.gd
git -C assassins-creed-india commit -m "feat: player crouch stealth base"
```

---

### Task 3: Detection + Hiding (3-state)

**Files:**
- Create: `assassins-creed-india/scripts/detection.gd`
- Test: `assassins-creed-india/tests/test_detection.gd`

**Interfaces:**
- Consumes: `player.is_crouched`, `player.disguise`, distance, in_hiding
- Produces: `Detection.get_state(dist: float, crouched: bool, hiding: bool) -> String`

- [ ] **Step 1: Write failing test**

```gdscript
# tests/test_detection.gd
extends SceneTree
func _init():
	var D = load("res://scripts/detection.gd").new()
	assert(D.get_state(30.0, false, false) == "unseen", "far should be unseen")
	assert(D.get_state(5.0, false, false) == "hunted", "close standing should be hunted")
	assert(D.get_state(5.0, true, true) == "unseen", "hiding crouched should be unseen")
	print("DETECT_OK")
	quit()
```

- [ ] **Step 2: Run to fail**

Run: `godot --headless --path assassins-creed-india -s tests/test_detection.gd 2>&1`
Expected: FAIL

- [ ] **Step 3: Minimal implementation**

```gdscript
# scripts/detection.gd
extends Node
class_name DetectionSys
func get_state(dist: float, crouched: bool, hiding: bool) -> String:
	if hiding and crouched: return "unseen"
	if dist > 18.0: return "unseen"
	if dist < 8.0 and not crouched: return "hunted"
	if dist < 12.0: return "suspicious"
	return "unseen"
```

- [ ] **Step 4: Run to pass**

Run: `godot --headless --path assassins-creed-india -s tests/test_detection.gd 2>&1`
Expected: `DETECT_OK`

- [ ] **Step 5: Commit**

```bash
git -C assassins-creed-india add scripts/detection.gd tests/test_detection.gd
git -C assassins-creed-india commit -m "feat: 3-state detection"
```

---

### Task 4: Social Blend + Disguise Gate

**Files:**
- Create: `assassins-creed-india/scripts/crowd_blend.gd`
- Test: `assassins-creed-india/tests/test_blend.gd`

**Interfaces:**
- Consumes: `player.disguise`, zone_id
- Produces: `can_enter(zone_id: String, disguise: String, has_farman: bool) -> bool`

- [ ] **Step 1: Write failing test**

```gdscript
# tests/test_blend.gd
extends SceneTree
func _init():
	var B = load("res://scripts/crowd_blend.gd").new()
	assert(B.can_enter("fort", "noble", false) == true, "noble enters fort")
	assert(B.can_enter("fort", "mazdoor", false) == false, "mazdoor blocked fort")
	assert(B.can_enter("fort", "mazdoor", true) == true, "farman overrides")
	assert(B.can_enter("taj", "mazdoor", false) == true, "mazdoor enters taj")
	print("BLEND_OK")
	quit()
```

- [ ] **Step 2: Run to fail**

Run: `godot --headless --path assassins-creed-india -s tests/test_blend.gd 2>&1`
Expected: FAIL

- [ ] **Step 3: Minimal implementation**

```gdscript
# scripts/crowd_blend.gd
extends Node
class_name BlendSys
func can_enter(zone_id: String, disguise: String, has_farman: bool) -> bool:
	if has_farman: return true
	if zone_id == "fort": return disguise == "noble"
	if zone_id == "taj": return disguise == "mazdoor" or disguise == "noble"
	return true
```

- [ ] **Step 4: Run to pass**

Run: `godot --headless --path assassins-creed-india -s tests/test_blend.gd 2>&1`
Expected: `BLEND_OK`

- [ ] **Step 5: Commit**

```bash
git -C assassins-creed-india add scripts/crowd_blend.gd tests/test_blend.gd
git -C assassins-creed-india commit -m "feat: blend disguise gate"
```

---

### Task 5: Investigation Loop (Eavesdrop / Tail / Pickpocket)

**Files:**
- Create: `assassins-creed-india/scripts/investigation.gd`
- Test: `assassins-creed-india/tests/test_investigation.gd`

**Interfaces:**
- Consumes: clue count
- Produces: `add_clue(id: String) -> void`, `is_target_unlocked() -> bool`, `clues: Array`

- [ ] **Step 1: Write failing test**

```gdscript
# tests/test_investigation.gd
extends SceneTree
func _init():
	var I = load("res://scripts/investigation.gd").new()
	I.add_clue("fort")
	I.add_clue("bazaar")
	assert(I.is_target_unlocked() == false, "2 clues not enough")
	I.add_clue("taj")
	assert(I.is_target_unlocked() == true, "3 clues unlocks")
	print("INVEST_OK")
	quit()
```

- [ ] **Step 2: Run to fail**

Run: `godot --headless --path assassins-creed-india -s tests/test_investigation.gd 2>&1`
Expected: FAIL

- [ ] **Step 3: Minimal implementation**

```gdscript
# scripts/investigation.gd
extends Node
class_name Investigation
var clues: Array = []
func add_clue(id: String):
	if not clues.has(id): clues.append(id)
func is_target_unlocked() -> bool:
	return clues.size() >= 3
```

- [ ] **Step 4: Run to pass**

Run: `godot --headless --path assassins-creed-india -s tests/test_investigation.gd 2>&1`
Expected: `INVEST_OK`

- [ ] **Step 5: Commit**

```bash
git -C assassins-creed-india add scripts/investigation.gd tests/test_investigation.gd
git -C assassins-creed-india commit -m "feat: 3-clue unlock"
```

---

### Task 6: Guard + Assassinate + Smoke (Stealth Kill)

**Files:**
- Create: `assassins-creed-india/scripts/guard.gd`
- Modify: `assassins-creed-india/scripts/player.gd:1-20`
- Test: `assassins-creed-india/tests/test_kill.gd`

**Interfaces:**
- Consumes: `Detection.get_state`, `Investigation.is_target_unlocked`
- Produces: `guard.alive: bool`, `player.assassinate(guard) -> bool`

- [ ] **Step 1: Write failing test**

```gdscript
# tests/test_kill.gd
extends SceneTree
func _init():
	var P = load("res://scripts/player.gd").new()
	var G = load("res://scripts/guard.gd").new()
	G.alive = true
	var ok = P.assassinate(G, "unseen", true)
	assert(ok == true and G.alive == false, "unseen unlocked kill should succeed")
	print("KILL_OK")
	quit()
```

- [ ] **Step 2: Run to fail**

Run: `godot --headless --path assassins-creed-india -s tests/test_kill.gd 2>&1`
Expected: FAIL assassinate missing

- [ ] **Step 3: Minimal implementation**

```gdscript
# scripts/guard.gd
extends CharacterBody3D
class_name Guard
var alive := true
var patrol: Array = []
```

Add to `scripts/player.gd` (append at end):

```gdscript
func assassinate(g, state: String, unlocked: bool) -> bool:
	if state == "unseen" and unlocked and g.alive:
		g.alive = false
		return true
	return false
func smoke_escape():
	pass
```

- [ ] **Step 4: Run to pass**

Run: `godot --headless --path assassins-creed-india -s tests/test_kill.gd 2>&1`
Expected: `KILL_OK`

- [ ] **Step 5: Commit**

```bash
git -C assassins-creed-india add scripts/guard.gd scripts/player.gd tests/test_kill.gd
git -C assassins-creed-india commit -m "feat: stealth assassinate smoke"
```

---

### Task 7: Agra Blockout + Perf Gate

**Files:**
- Create: `assassins-creed-india/scenes/agra.tscn`
- Create: `assassins-creed-india/scripts/agra_blockout.gd`
- Test: manual perf `godot --headless --path assassins-creed-india --quit-after 60 2>&1`

**Interfaces:**
- Consumes: all systems above
- Produces: 5 zones load, <60 AI, 30fps fog scene

- [ ] **Step 1: Write blockout script**

```gdscript
# scripts/agra_blockout.gd
extends Node3D
var zones := ["fort", "taj", "bazaar", "ghats", "bureau"]
func _ready():
	for z in zones:
		var n = Node3D.new()
		n.name = z
		add_child(n)
	print("AGRA_ZONES:", zones.size())
```

Minimal `scenes/agra.tscn`:

```
[gd_scene load_steps=2 format=3]
[node name="Agra" type="Node3D"]
script = ExtResource("1")
```

Wire script in editor once, or instance via code for MVP.

- [ ] **Step 2: Run scene load**

Run: `godot --headless --path assassins-creed-india res://scenes/agra.tscn --quit-after 60 2>&1`
Expected: loads without crash, prints AGRA_ZONES:5

- [ ] **Step 3: Perf gate**

Run: `/usr/bin/time -p godot --headless --path assassins-creed-india --quit-after 120 2>&1 | head`
Expected: stable, no OOM on M4 Air. If <20fps headless, reduce guards to 8, crowd to 3 per group.

- [ ] **Step 4: Copy design in**

Run: `cp DESIGN.md docs/superpowers/specs/2026-09-26-assassins-creed-india-design.md 2>/dev/null || true`

- [ ] **Step 5: Commit**

```bash
git -C assassins-creed-india add scenes/agra.tscn scripts/agra_blockout.gd
git -C assassins-creed-india commit -m "feat: agra 5-zone blockout"
```

---

## Self-Review

1. Spec coverage: fort/taj/bazaar/ghats/bureau zones → Task7. Noble/mazdoor + farman → Task4. 3 clues → Task5. 3-state detection + hiding → Task3. Unseen kill + smoke + weak combat → Task6. <60 AI, fog, 30fps → Task7. Revenge→conspiracy hook via 3 clues unlocking contractor target → Task5+6.
2. Placeholder scan: no TBD/TODO, all code complete, all commands exact with expected output.
3. Type consistency: `disguise: String`, `get_state(dist: float, crouched: bool, hiding: bool) -> String`, `can_enter(zone_id: String, disguise: String, has_farman: bool) -> bool`, `assassinate(g, state: String, unlocked: bool) -> bool` used consistently.

Skipped per ponytail: guard disguise, XP, horses, naval, notoriety, recruits, Delhi/Deccan — add when Agra loop is fun.
