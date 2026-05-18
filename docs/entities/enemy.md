# Enemy Entity

## Purpose

Hostile ships that spawn from enemy planets and move toward targets. Two types exist: fighters are agile and shoot at the player; bombers are slow, tough, and home in on the home planet.

## How It Works

Each enemy is created with a type that determines its stats and behaviour. On `update()`, the enemy applies thrust toward its target with velocity capping. Fighters have three movement zones around the player (engage, strafe, retreat) and fire bullets on a cooldown when within range. Bombers always thrust toward world center. When an enemy reaches the home planet, it deals damage and is marked dead. Enemies killed by bullets drop scrap pickups (and fuel canisters with certain odds).

## Public API

### `Enemy.new(type, x, y)`
Creates a new enemy at the given world position.

- `type` — `"fighter"` or `"bomber"`
- `x`, `y` — spawn position

### `Enemy:update(dt, playerX, playerY, enemyBullets)`
Moves toward target using simplified thrust with speed cap. Fighters target `playerX`/`playerY` and insert bullets into `enemyBullets` on cooldown.

### `Enemy:takeDamage(amount)`
Reduces HP by `amount`. Sets `alive = false` if HP ≤ 0.

### `Enemy:draw(camera)`
Draws the enemy in world space. Fighters are magenta triangles; bombers are orange filled circles.

## Enemy Types

| Stat                 | Fighter | Bomber |
|----------------------|---------|--------|
| Radius               | 10      | 20     |
| Speed cap            | 150     | 50     |
| HP                   | 3       | 8      |
| Planet Damage        | 5       | 25     |
| Scrap Drop           | 1       | 3      |
| Fire Rate            | 2.0s    | —      |
| Bullet Speed         | 350     | —      |
| Colour               | Magenta | Orange |
| Shape                | Triangle| Circle |

## Movement Behaviour

### Fighter
The fighter's target is always `(playerX, playerY)`. Its behaviour changes based on distance to the player:

| Range                          | Behaviour                                  |
|--------------------------------|--------------------------------------------|
| `dist > FIGHTER_ENGAGE_RANGE` (250) | Move directly toward the player       |
| `dist > FIGHTER_TOO_CLOSE` (120)    | Strafe perpendicular to the player    |
| `dist ≤ FIGHTER_TOO_CLOSE`          | Retreat away from the player          |

The fighter fires a bullet toward the player's position every `FIGHTER_FIRE_RATE` seconds when within `FIGHTER_ENGAGE_RANGE`.

### Bomber
Always thrusts toward `(WORLD_WIDTH / 2, WORLD_HEIGHT / 2)` — the home planet's location. Does not shoot. Exchanges speed for high HP and heavy planet damage.

## Drop Table

| Enemy   | Scraps    | Fuel Drop Chance     |
|---------|-----------|----------------------|
| Fighter | 1 (`FIGHTER_SCRAP_DROP`) | 30% (`FIGHTER_FUEL_DROP_CHANCE`) |
| Bomber  | 3 (`BOMBER_SCRAP_DROP`)  | Always drops 1      |

## Gotchas

- Fighters target the player's current position each frame — they lead naturally.
- Bombers always fly toward world center, not the planet entity directly (but the planet is at world center).
- Fighter bullets are stored in `gameplay.enemyBullets`, separate from player/defense bullets, and only collide with the player.
- The `alive` flag is the only way to check if an enemy is still active.
- Enemies do not collide with each other or with their own bullets.
- An enemy that reaches the home planet deals its `damage` value to `Planet:takeDamage()` and is immediately set to `alive = false`.
