# Enemy Planet Entity

## Purpose

Indestructible planets that periodically spawn enemies. They are fixed spawn points that the player must deal with by shooting down the enemies they produce.

## How It Works

Each enemy planet has a position, a sprite assignment, and a spawn timer. The timer counts up each frame. When it exceeds `ENEMY_PLANET_SPAWN_INTERVAL`, an enemy is created at the planet's position and added to the enemy list, and the timer resets. The planet also has a looping spritesheet animation.

Enemy planets are indestructible — they cannot be damaged or removed.

## Public API

### `EnemyPlanet.new(x, y, spriteIndex)`
Creates a new enemy planet at `(x, y)`. `spriteIndex` chooses which spritesheet to use (1 or 2).

### `EnemyPlanet:update(dt, enemies)`
Advances the animation frame and increments the spawn timer. Spawns an enemy when the timer reaches `ENEMY_PLANET_SPAWN_INTERVAL` (3 seconds, with initial random offset).

- `enemies` — the list to insert new enemy instances into

### `EnemyPlanet:draw(camera)`
Sets color to white and draws the current animation frame scaled to `ENEMY_PLANET_RADIUS * 2`, centered on the planet's position.

## Spawning

- Spawn interval: `ENEMY_PLANET_SPAWN_INTERVAL` (3.0s)
- Enemy type probability: 30% fast, 70% basic
- Initial spawn timer is randomized (0 to `ENEMY_PLANET_SPAWN_INTERVAL`) so planets don't all spawn on the same cadence
- Spawned enemies appear at the planet's exact position

## Spritesheets

Each enemy planet position in `ENEMY_PLANET_POSITIONS` specifies a `sprite` index (1 or 2) corresponding to the two spritesheets loaded at module initialization time:

- `assets/planet/enemy_planet1.png`
- `assets/planet/enemy_planet2.png`

Both spritesheets have the same frame structure and use `ENEMY_PLANET_FRAME_*` constants.

## Gotchas

- Enemy planets are indestructible — there is no health or damage logic.
- The `enemies` parameter passed to `update()` is mutated directly (new enemies are inserted). The caller (gameplay state) owns the list.
