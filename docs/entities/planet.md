# Planet Entity

## Purpose

The home planet at the center of the world. The player must defend it from enemies. When its HP reaches 0, the game ends.

## How It Works

The planet is a static entity at `(WORLD_WIDTH/2, WORLD_HEIGHT/2)` with HP that decreases when enemies collide with it. It is rendered using an animated spritesheet loaded at module level.

## Public API

### `Planet.new()`
Creates the planet at world center with full HP, starting on frame 1 of the animation.

### `Planet:update(dt)`
Advances the animation frame based on `PLANET_FRAME_DURATION`. Loops back to frame 1 after the last frame.

### `Planet:takeDamage(amount)`
Reduces HP by `amount`, clamped to a minimum of 0.

### `Planet:isDestroyed()`
Returns `true` if HP ≤ 0.

### `Planet:draw(camera)`
Sets color to white (to avoid tinting the sprite) and draws the current animation frame scaled to `PLANET_RADIUS * 2`, centered on the planet's position.

## Spritesheet Animation

- Spritesheet: `assets/planet/home_planet.png`
- `PLANET_FRAME_COUNT` frames arranged horizontally in a single strip
- Each frame is `PLANET_FRAME_WIDTH` x `PLANET_FRAME_HEIGHT` pixels
- Quads are generated at module load time
- Animation speed controlled by `PLANET_FRAME_DURATION` (seconds per frame)
- Uses subtractive accumulator for frame-rate independence

## HP and Destruction

- Starts at `PLANET_HP` (100).
- Damaged by enemies that reach the planet (fighters deal 5 damage, bombers deal 25 damage).
- When destroyed (`hp ≤ 0`), `Gameplay:update()` switches to game over with `{ reason = "planet" }`.
- There is no repair mechanic.

## Gotchas

- The spritesheet image and quads are module-level (shared across all instances). Since there is only one planet, this is fine.
- The planet's collision radius (`PLANET_RADIUS`) is separate from the sprite size — changing the radius affects collision but the sprite scales to match.
