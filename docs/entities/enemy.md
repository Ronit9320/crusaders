# Enemy Entity

## Purpose

Hostile ships that spawn from enemy planets or world edges and move toward the home planet. They damage the planet on contact and can be shot by the player (or defense system).

## How It Works

Each enemy is created with a type that determines its stats. On `update()`, it moves along the direct vector toward the world center (home planet position). When it reaches the planet, it deals damage and is marked dead. Enemies can be killed by bullets (player or defense), which spawns scrap pickups at their position.

## Public API

### `Enemy.new(type, spawnX, spawnY)`
Creates a new enemy. If `spawnX` and `spawnY` are omitted, spawns at a random world edge.

- `type` — `"basic"` or `"fast"`
- `spawnX`, `spawnY` — optional explicit spawn position

### `Enemy:update(dt)`
Moves toward `(WORLD_WIDTH/2, WORLD_HEIGHT/2)` at the enemy's speed.

### `Enemy:takeDamage(amount)`
Reduces HP by `amount`. Sets `alive = false` if HP ≤ 0.

### `Enemy:draw(camera)`
Draws the enemy in world space. Basic enemies are red squares; fast enemies are orange triangles.

## Enemy Types

| Stat     | Basic | Fast  |
|----------|-------|-------|
| Radius   | 14    | 10    |
| Speed    | 80    | 160   |
| HP       | 2     | 1     |
| Damage   | 10    | 10    |
| Color    | Red   | Orange|
| Shape    | Square| Triangle |

Fast enemies move twice as fast but die in one hit.

## Spawn Logic

Enemies are created by two sources:
1. **Enemy planets** — spawn an enemy every `ENEMY_PLANET_SPAWN_INTERVAL` seconds (30% chance fast, 70% basic), at the planet's position.
2. **World edge spawn** — when `Enemy.new(type)` is called without coordinates, it chooses one of four world edges and places the enemy just outside the world boundary.

## Gotchas

- All enemies path toward `(WORLD_WIDTH/2, WORLD_HEIGHT/2)` — there is no target selection or player pursuit.
- The `alive` flag is the only way to check if an enemy is still active. Bullet collision and planet collision both mark `alive = false`.
- Enemies do not damage the player — only the planet.
