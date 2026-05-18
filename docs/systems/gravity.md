# Gravity System

## Purpose

Applies a constant gravitational pull from planets toward nearby objects, creating orbital mechanics around both the home planet and enemy colonies.

## How It Works

The gravity system is a pure function — it has no state of its own. It iterates over all objects and all planets, and for each object within a planet's gravity radius, it applies an acceleration toward the planet's center. The pull is directional (toward planet center) and constant (not distance-falloff).

## Public API

### `Gravity.apply(dt, planets, objects)`

Applies gravitational acceleration from every planet to every object within range.

- `dt` — delta time in seconds
- `planets` — list of tables, each containing:
  - `x`, `y` — planet world position
  - `gravityRadius` — maximum distance for gravity to apply
  - `gravityStrength` — acceleration magnitude (applied as `nx * strength * dt`)
- `objects` — list of tables, each containing:
  - `x`, `y` — current position
  - `vx`, `vy` — velocity (mutated in place)

The function modifies `vx`/`vy` on each object directly — no return value.

## Affected Objects

In `Gameplay:update()`, the following objects receive gravity each frame:

- Player ship
- Player bullets (only alive ones)
- Enemies (only alive ones)
- Scraps (only uncollected ones)
- Fuel pickups (only uncollected ones)

Enemy bullets and defense bullets are **not** affected by gravity.

## Gravity Sources

| Source       | Radius | Strength                                     |
|--------------|--------|----------------------------------------------|
| Home Planet  | 300    | `PLANET_RADIUS * GRAVITY_SCALE_FACTOR` = 30  |
| Enemy Colony | 200    | `ENEMY_PLANET_RADIUS * GRAVITY_SCALE_FACTOR` = 20 |

Both `GRAVITY_SCALE_FACTOR` (0.5) and per-planet radii are defined in `constants.lua`.

## Gotchas

- Dead planets (colonies with `alive == false`) still exert gravity — their `gravityStrength` is unchanged.
- Gravity has no distance falloff within the radius — it applies at full strength regardless of distance.
- Scraps and fuel pickups have their velocities updated by gravity but their positions are then integrated separately in the gameplay update loop.
- The gravity module returns a table with a single `apply` function — it is not an object with state.
