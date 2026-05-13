# Bullet Entity

## Purpose

Projectiles fired by the player and the planet defense system. Travel in a straight line and collide with enemies.

## How It Works

A bullet stores position, velocity (computed from angle and speed), and a color. Each frame it moves along its velocity vector. If it goes outside the world bounds (with a 50px buffer), it is marked dead. The gameplay state handles collision with enemies.

## Public API

### `Bullet.new(x, y, angle, color, speed)`
Creates a bullet at `(x, y)` traveling in the direction `angle` (radians).

- `x`, `y` — spawn position
- `angle` — direction in radians
- `color` — optional color override (table of 3-4 values), defaults to `BULLET_COLOR` (yellow)
- `speed` — optional speed override, defaults to `BULLET_SPEED` (600)

### `Bullet:update(dt)`
Moves the bullet along its velocity. Sets `alive = false` if outside world bounds (plus 50px margin).

### `Bullet:draw(camera)`
Draws the bullet as a filled circle at its world position using its current color.

## Color and Speed Overrides

The optional `color` and `speed` parameters allow different sources to create visually distinct bullets:

| Source  | Color | Speed |
|---------|-------|-------|
| Player  | Yellow (default) | 600 |
| Defense | Purple (`DEFENSE_BULLET_COLOR`) | 400 |

Both bullet types coexist in the same list and use identical collision logic.

## Gotchas

- All bullets, regardless of source, collide with all enemies. There is no friendly-fire distinction because only enemies receive bullet damage.
- Bullets do not collide with the player or the planet.
- The world bounds check uses a 50px margin to avoid popping bullets at the edge of the visible area.
