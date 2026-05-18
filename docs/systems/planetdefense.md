# Planet Defense System

## Purpose

An optional auto-defense system for the home planet. Purchased and upgraded through the shop. When active, it targets and fires at all enemies within a radius around the planet, with per-level fire rate and spread shot.

## How It Works

The defense system tracks a `level` (0 = inactive, 1–3 = active) and an internal cooldown. Each frame, if the cooldown is ready, it scans all alive enemies within the defense radius and fires at **every eligible enemy simultaneously** (not just the nearest one). Bullets are inserted directly into the gameplay state's bullet list so they participate in standard cleanup and collision logic.

## Public API

### `PlanetDefense.new()`
Creates a defense system at level 0 (inactive).

### `PlanetDefense:isActive()`
Returns `true` if level > 0.

### `PlanetDefense:getRadius()`
Returns the current defense radius:
- Level 1: `DEFENSE_RADIUS_BASE` (150)
- Level 2: `DEFENSE_RADIUS_BASE + DEFENSE_RADIUS_PER_LEVEL` (200)
- Level 3: `DEFENSE_RADIUS_BASE + DEFENSE_RADIUS_PER_LEVEL * 2` (250)

Returns 0 if inactive.

### `PlanetDefense:getFireRate()`
Returns the fire rate (cooldown in seconds) for the current level:
- Level 1: `DEFENSE_FIRE_RATE` (0.8s)
- Level 2: `DEFENSE_FIRE_RATE_L2` (0.5s)
- Level 3: `DEFENSE_FIRE_RATE_L3` (0.3s)

### `PlanetDefense:getMaxLevel()`
Returns `DEFENSE_MAX_LEVEL` (3).

### `PlanetDefense:update(dt, enemies, bullets, planetX, planetY)`
Scans all alive enemies within the defense radius. For each enemy in range, fires one bullet aimed directly at it. At level 3, fires three bullets in a spread pattern per enemy.

- `dt` — delta time
- `enemies` — list of enemy objects with `.alive`, `.x`, `.y`
- `bullets` — list to push new `Bullet` instances into
- `planetX`, `planetY` — the home planet's world position

### `PlanetDefense:draw(planetX, planetY, camera)`
Draws a semi-transparent filled circle and a ring at the defense radius around the planet. Uses `DEFENSE_BULLET_COLOR` (purple) with alpha 0.15 (fill) and 0.4 (line).

## Levels

| Level | Cost       | Radius | Fire Rate | Shots per Enemy |
|-------|------------|--------|-----------|-----------------|
| 0     | —          | None   | —         | —               |
| 1     | $10        | 150    | 0.8s      | 1 (direct)      |
| 2     | $15 (upg)  | 200    | 0.5s      | 1 (direct)      |
| 3     | $15 (upg)  | 250    | 0.3s      | 3 (spread)      |

At level 3, the spread fires three purple bullets per enemy: one aimed directly, and two offset by ±`DEFENSE_SPREAD_ANGLE` (0.175 rad / ~10°).

## Integration with Bullet System

Defense bullets use `Bullet.new()` with a custom color (`DEFENSE_BULLET_COLOR`, purple) and custom speed (`DEFENSE_BULLET_SPEED`, 550). They are added to the same `bullets` list as player bullets, so they use the same cleanup (`keepAlive`) and collision logic in `Gameplay:update()`.

## Gotchas

- The defense fires at **all** enemies in range simultaneously, not just the nearest one. This means high-level defense with many enemies in range can produce a lot of bullets per volley.
- The cooldown uses a subtractive accumulator pattern (not reset to 0), which is frame-rate independent.
- Only enemies with `alive == true` are considered targets.
- Defense bullets collide with enemies and colonies (same as player bullets).
