# Enemy Entity

## Purpose

Hostile ships that spawn from enemy planets and move toward targets. Fighters chase the player and shoot back; bombers home in on the home planet to deal heavy damage.

## How It Works

Each enemy is created with a type that determines its stats and behaviour. On `update()`, it applies thrust toward its target (player for fighters, world center for bombers) with velocity capping. Fighters fire bullets at the player on a cooldown. When an enemy reaches the home planet (or the planet reaches it), it deals damage and is marked dead. Enemies killed by bullets drop scrap pickups.

## Public API

### `Enemy.new(type, x, y)`
Creates a new enemy at the given world position.

- `type` — `"fighter"` or `"bomber"`
- `x`, `y` — spawn position

### `Enemy:update(dt, playerX, playerY, enemyBullets)`
Moves toward target using simplified thrust. Fighters target `playerX`/`playerY` and insert bullets into `enemyBullets` on cooldown.

### `Enemy:takeDamage(amount)`
Reduces HP by `amount`. Sets `alive = false` if HP ≤ 0.

### `Enemy:draw(camera)`
Draws the enemy in world space. Fighters are magenta triangles; bombers are orange circles.

## Enemy Types

| Stat                 | Fighter | Bomber |
|----------------------|---------|--------|
| Radius               | 10      | 20     |
| Speed                | 150     | 50     |
| HP                   | 3       | 8      |
| Planet Damage        | 5       | 25     |
| Scrap Drop           | 1       | 3      |
| Fire Rate            | 2.0s    | —      |
| Bullet Speed         | 350     | —      |
| Colour               | Magenta | Orange |
| Shape                | Triangle| Circle |

Fighters are fast, aggressive, and shoot at the player. Bombers are slow, tough, and ignore the player to hit the planet hard.

## Spawn Logic

Enemies are created by **enemy planets** — each planet spawns an enemy every `ENEMY_PLANET_SPAWN_INTERVAL` seconds (30% chance bomber, 70% fighter) at the planet's position.

## Gotchas

- Fighters target the player's current position each frame — they lead naturally.
- Bombers always fly toward `(WORLD_WIDTH/2, WORLD_HEIGHT/2)`.
- Fighter bullets are stored in `gameplay.enemyBullets`, separate from player bullets, and only collide with the player.
- The `alive` flag is the only way to check if an enemy is still active.
- Enemies do not collide with each other or with their own bullets.
