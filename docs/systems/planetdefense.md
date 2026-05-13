# Planet Defense System

## Purpose

An optional auto-defense system for the home planet. Purchased and upgraded through the shop. When active, it targets and fires at enemies within a radius around the planet.

## How It Works

The defense system tracks a `level` (0 = inactive, 1-3 = active) and an internal cooldown. Each frame, if the cooldown is ready, it scans all alive enemies within the defense radius, picks the nearest one, and creates a `Bullet` aimed at it. The bullet is inserted directly into the gameplay state's bullet list so it participates in the standard bullet cleanup and collision logic.

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

### `PlanetDefense:getMaxLevel()`
Returns `DEFENSE_MAX_LEVEL` (3).

### `PlanetDefense:update(dt, enemies, bullets, planetX, planetY)`
Scans `enemies` for targets and inserts new `Bullet` objects into `bullets`. Fires at most once every `DEFENSE_FIRE_RATE` seconds.

- `dt` — delta time
- `enemies` — list of enemy objects with `.alive`, `.x`, `.y`
- `bullets` — list to push new bullet instances into
- `planetX`, `planetY` — the home planet's world position

### `PlanetDefense:draw(planetX, planetY, camera)`
Draws a semi-transparent filled circle and a ring at the defense radius around the planet. Uses `DEFENSE_BULLET_COLOR` with alpha 0.15 (fill) and 0.4 (line).

## Levels and Radius

| Level | Cost  | Radius |
|-------|-------|--------|
| 0     | —     | None   |
| 1     | $10   | 150    |
| 2     | $15   | 200    |
| 3     | $15   | 250    |

## Integration with Bullet System

Defense bullets use `Bullet.new()` with a custom color (`DEFENSE_BULLET_COLOR`, purple) and custom speed (`DEFENSE_BULLET_SPEED`, 400). They are added to the same `bullets` list as player bullets, so they use the same cleanup (`keepAlive`) and collision logic in `Gameplay:update()`.

## Gotchas

- The defense only fires if `level > 0`. Setting `level` to 0 disables it entirely.
- The cooldown uses a subtractive accumulator pattern (not reset to 0), which is frame-rate independent.
- Only enemies with `alive == true` are considered targets.
