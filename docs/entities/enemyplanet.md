# Enemy Planet Entity

## Purpose

Destructible planets that periodically spawn enemies. Each colony has a difficulty rating that determines its HP and spawn escalation rate. Destroying all three colonies triggers victory.

## How It Works

Each enemy planet has a position, a sprite assignment, HP, a spawn timer, and a difficulty multiplier. The timer counts up each frame. When it exceeds the current spawn interval (which escalates over time), an enemy is created at the planet's position. The planet can be destroyed by shooting it, which stops spawning and turns the planet dark on the map.

## Public API

### `EnemyPlanet.new(x, y, spriteIndex, difficulty, colonyName)`
Creates a new enemy planet at `(x, y)`. `spriteIndex` chooses which spritesheet to use (1 or 2). `difficulty` determines max HP, spawn rate escalation, and wave size multiplier. `colonyName` is the display name for attack warnings.

### `EnemyPlanet:update(dt, enemies, globalElapsed)`
Advances the animation frame, tracks elapsed time for spawn escalation, increments the spawn timer, and advances the wave timer. Skips spawning when `alive == false`. Wave size grows based on `globalElapsed` time.

### `EnemyPlanet:takeDamage(amount)`
Reduces HP by `amount`. Sets `alive = false` when HP ≤ 0.

### `EnemyPlanet:getSpawnInterval()`
Returns the current spawn interval based on elapsed time and difficulty. Every `ENEMY_SPAWN_ESCALATION_TIME` seconds, the interval decreases by `ENEMY_SPAWN_ESCALATION_STEP × difficulty`, clamped to `ENEMY_SPAWN_INTERVAL_MIN`.

### `EnemyPlanet:getWaveSize(globalElapsed)`
Returns the number of enemies in the next attack wave. Base size grows over `globalElapsed` time, multiplied by difficulty, rounded to nearest integer (minimum 1).

### `EnemyPlanet:draw(camera)`
Draws the planet with its current animation frame. Dead planets are drawn with a semi-transparent black overlay. Alive planets show a coloured HP bar above them (green → yellow → red as HP decreases).

## Colony Stats

| Colony          | Name           | Difficulty | HP   | Escalation Step | Wave Multiplier |
|-----------------|----------------|------------|------|-----------------|-----------------|
| Easy (Alpha)    | COLONY ALPHA   | 0.5        | 200  | 0.25/s          | 0.5×            |
| Medium (Beta)   | COLONY BETA    | 1.0        | 400  | 0.50/s          | 1.0×            |
| Hard (Gamma)    | COLONY GAMMA   | 1.5        | 700  | 0.75/s          | 1.5×            |

## Spawning

- Initial spawn interval: `ENEMY_SPAWN_INTERVAL_START` (8.0s) for all colonies
- Interval minimum: `ENEMY_SPAWN_INTERVAL_MIN` (2.0s)
- Escalation check every `ENEMY_SPAWN_ESCALATION_TIME` (30.0s)
- Enemy type probability: 30% bomber, 70% fighter
- Initial spawn timer is randomized so planets don't all spawn on the same cadence

## Destruction

- Player and defense bullets deal `BULLET_DAMAGE_TO_COLONY` (5) damage per hit
- When `hp` reaches 0, `alive` is set to `false` and spawning stops
- Dead planets still appear on the minimap as grey dots
- Destroying all colonies triggers the victory state

## Attack Waves

Every `ESCALATION_WAVE_INTERVAL` (45s), each alive colony sends an attack wave toward the home planet.

- **Wave size**: starts at `ESCALATION_WAVE_SIZE` (3) and grows by `ESCALATION_WAVE_GROWTH` (1) every `ESCALATION_GROWTH_TIME` (60s), clamped to `ESCALATION_WAVE_MAX` (12)
- **Difficulty multiplier**: wave size = base × difficulty (rounded, min 1)
- **Composition**: 60% fighters, 40% bombers
- **Timer**: each colony tracks its own independent wave timer, randomized on spawn
- **Warning**: red pulsing "INCOMING ATTACK FROM COLONY XXX" text appears in screen space 5 seconds before each wave, fading in/out over the warning period

### Wave Size by Difficulty Over Time

| Time | Base Size | Alpha (0.5×) | Beta (1.0×) | Gamma (1.5×) |
|------|-----------|--------------|-------------|--------------|
| 0s   | 3         | 2            | 3           | 5            |
| 60s  | 4         | 2            | 4           | 6            |
| 120s | 5         | 3            | 5           | 8            |
| 180s | 6         | 3            | 6           | 9            |
| 240s | 7         | 4            | 7           | 11           |
| 300s | 8         | 4            | 8           | 12 (max)     |

## Victory Condition

When all enemy planets have `alive == false`, the gameplay state switches to "victory", which displays:
- Time survived
- Total scraps collected
- Money spent on upgrades

## HP Bar

Rendered above the planet when alive:
- Background: dark red rectangle
- Foreground: green → yellow → red based on remaining HP ratio
- Width: 2.5× planet radius, height: 4px

## Spritesheets

Each enemy planet position in `ENEMY_PLANET_POSITIONS` specifies a `sprite` index (1 or 2) corresponding to two spritesheets loaded at module init:
- `assets/planet/enemy_planet1.png`
- `assets/planet/enemy_planet2.png`

## Gotchas

- Dead planets still exert gravity (their `gravityStrength` remains).
- The `enemies` parameter passed to `update()` is mutated directly.
- Stat tracking (time, scraps, money) lives in the gameplay state and is passed to the victory screen.
