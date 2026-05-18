# Enemy Planet Entity

## Purpose

Destructible colonies that periodically spawn enemies and launch attack waves against the home planet. Each colony has a difficulty rating that determines its HP, spawn escalation rate, and wave size multiplier. Destroying all three colonies triggers victory.

## How It Works

Each enemy planet has a position, sprite assignment, max HP based on difficulty, a spawn timer for individual enemy production, and a wave timer for coordinated attack waves. The planet can be destroyed by shooting it (player or defense bullets), which stops all spawning, applies a dark overlay, and turns it grey on the minimap.

## Public API

### `EnemyPlanet.new(x, y, spriteIndex, difficulty, colonyName)`
Creates a new enemy planet at `(x, y)`.

- `x`, `y` — world position
- `spriteIndex` — 1 or 2, selects which spritesheet to use
- `difficulty` — determines max HP, spawn rate escalation step multiplier, and wave size multiplier
- `colonyName` — display name for attack warnings ("COLONY ALPHA", etc.)

Initializes with randomized spawn timer and wave timer so colonies don't all fire on the same cadence.

### `EnemyPlanet:update(dt, enemies, globalElapsed)`
Advances animation, tracks elapsed time for spawn/wave escalation, and manages two production modes:
1. **Continuous spawning** — individual enemies every `getSpawnInterval()` seconds
2. **Attack waves** — coordinated groups every `ESCALATION_WAVE_INTERVAL` (45s), with a 5-second visual warning

Skips all spawning when `alive == false`.

### `EnemyPlanet:takeDamage(amount)`
Reduces HP by `amount`. No-op if already dead. Sets `alive = false` when HP ≤ 0.

### `EnemyPlanet:getSpawnInterval()`
Returns the current individual spawn interval. Every `ENEMY_SPAWN_ESCALATION_TIME` (30s), the interval decreases by `ENEMY_SPAWN_ESCALATION_STEP × difficulty`, clamped to `ENEMY_SPAWN_INTERVAL_MIN` (2.0s).

### `EnemyPlanet:getWaveSize(globalElapsed)`
Returns the number of enemies in the next attack wave. Base size starts at `ESCALATION_WAVE_SIZE` (3) and grows by `ESCALATION_WAVE_GROWTH` (1) every `ESCALATION_GROWTH_TIME` (60s), clamped to `ESCALATION_WAVE_MAX` (12). Multiplied by difficulty and rounded (minimum 1).

### `EnemyPlanet:draw(camera)`
Draws the animated planet sprite. Dead planets get a semi-transparent black overlay. Alive planets show a coloured HP bar above them (green → yellow → red gradient).

## Colony Positions

Three colonies are defined in `ENEMY_PLANET_POSITIONS`:

| Index | Position   | Sprite | Difficulty | Name           | HP   |
|-------|------------|--------|------------|----------------|------|
| 1     | (1500, 1500) | 1      | 0.5        | COLONY ALPHA   | 200  |
| 2     | (6500, 1500) | 2      | 1.0        | COLONY BETA    | 400  |
| 3     | (4000, 7000) | 1      | 1.5        | COLONY GAMMA   | 700  |

HP is determined by difficulty: <1.0 → `COLONY_HP_EASY` (200), 1.0 → `COLONY_HP_MEDIUM` (400), ≥1.5 → `COLONY_HP_HARD` (700).

## Spawning

### Continuous Spawn
- Initial interval: `ENEMY_SPAWN_INTERVAL_START` (8.0s)
- Minimum interval: `ENEMY_SPAWN_INTERVAL_MIN` (2.0s)
- Escalation step: `ENEMY_SPAWN_ESCALATION_STEP` (0.5) × difficulty every `ENEMY_SPAWN_ESCALATION_TIME` (30s)
- Enemy type: 30% bomber, 70% fighter
- Initial spawn timer randomized per colony

### Attack Waves
Every `ESCALATION_WAVE_INTERVAL` (45s), each alive colony launches a coordinated wave:

- **Warning**: 5 seconds before the wave, red pulsing text appears: "INCOMING ATTACK FROM COLONY XXX"
  - Warning alpha fades in over 1s, holds full for 3s, fades out over 1s
- **Wave size**: base size × difficulty (rounded, min 1)
- **Composition**: 60% fighters, 40% bombers
- **Timer**: each colony tracks its own independent wave timer, randomized on game start

### Wave Size Over Time

| Time | Base Size | Alpha (0.5×) | Beta (1.0×) | Gamma (1.5×) |
|------|-----------|--------------|-------------|--------------|
| 0s   | 3         | 2            | 3           | 5            |
| 60s  | 4         | 2            | 4           | 6            |
| 120s | 5         | 3            | 5           | 8            |
| 180s | 6         | 3            | 6           | 9            |
| 240s | 7         | 4            | 7           | 11           |
| 300s | 8         | 4            | 8           | 12 (max)     |

## Destruction

- Player and defense bullets deal `BULLET_DAMAGE_TO_COLONY` (5) damage per hit
- When HP ≤ 0, `alive` is set to `false`, spawning stops
- Dead planets display a dark overlay in world space and grey on the minimap
- Dead planets still exert gravity
- Destroying all 3 colonies triggers the victory state

## HP Bar

Rendered above the planet when alive:
- Background: dark red rectangle (`0.3, 0.1, 0.1`)
- Foreground: green → yellow → red gradient (`r` goes 1→0→1, `g` stays 1→0)
- Width: 2.5× planet radius, height: 4px

## Spritesheets

Two spritesheet variants loaded at module init:
- `assets/planet/enemy_planet1.png` (sprite index 1)
- `assets/planet/enemy_planet2.png` (sprite index 2)

Each has `ENEMY_PLANET_FRAME_COUNT` (50) frames, with `ENEMY_PLANET_FRAME_DURATION` (0.05s) per frame.

## Gotchas

- Dead planets still exert gravity (their `gravityStrength` remains unchanged).
- The `enemies` parameter passed to `update()` is mutated directly — enemies and waves insert into the same list.
- Wave warning alpha is managed entirely by the enemy planet and passed to the HUD via a collected warnings list.
- Stat tracking (time, scraps, money) lives in the gameplay state and is passed to the victory screen.
