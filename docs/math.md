# Math Reference

All mathematical operations used across the codebase, grouped by category.

---

## Vector Operations

### Magnitude / Length

Computes the length of a 2D vector (dx, dy):

```
length = sqrt(dx² + dy²)
```

**Used in:** `player.lua:48` (current speed for rotation scaling and integrity damage), `player.lua:67` (speed clamping), `player.lua:99` (integrity loss check), `enemy.lua` (movement targeting, fire range check), `enemyplanet.lua` (HP bar ratio), `bullet.lua` (no direct use — velocity is precomputed), `gravity.lua` (distance check), `planetdefense.lua` (range check), `gameplay.lua` (all collision checks: bullet–enemy, bullet–colony, enemy–planet, enemy bullet–player, player–scrap, player–fuel, player–planet)

### Normalization

Returns a unit vector (nx, ny) pointing from one entity to another:

```
nx = dx / length
ny = dy / length
```

Only computed when length > 0 to avoid division by zero.

**Used in:** `enemy.lua` (fighter movement toward/away/strafe from player, bomber movement toward world center), `gravity.lua` (pulling objects toward planet center)

### Direction Perpendicular (Strafe)

Rotates a 2D unit vector by 90° clockwise to produce a perpendicular direction:

```
tx = -ny
ty =  nx
```

This is equivalent to multiplying by the rotation matrix `[[0, 1], [-1, 0]]` applied to direction-from-target.

**Used in:** `enemy.lua:33` — fighters strafe perpendicular to the player when at medium range (`FIGHTER_TOO_CLOSE < dist ≤ FIGHTER_ENGAGE_RANGE`)

### Dot Product

**Not used anywhere in the codebase.**

---

## Trigonometry

### math.atan2(dy, dx)

Returns the angle in radians from the positive x-axis to the point (dx, dy). Range: [-π, π].

```
angle = atan2(dy, dx)
```

**Used in:**
- `enemy.lua:63` — fighter aims bullet toward player's current position
- `planetdefense.lua:62` — defense turret aims at each enemy in range; `baseAngle` is computed per enemy

### math.cos(angle) and math.sin(angle)

Decompose an angle into the x and y components of a unit vector:

```
direction_x = cos(angle)
direction_y = sin(angle)
```

**Used in:**
- `player.lua:62–63` — apply thrust in ship's facing direction: `vx += cos(angle) * thrust * dt`
- `bullet.lua:16–17` — set initial velocity from angle: `vx = cos(angle) * speed`, `vy = sin(angle) * speed`
- `player.lua:123–128` — draw ship triangle: compute the three polygon vertices from `self.angle` with offset angles of `+2.5` and `-2.5` radians for the wing tips
- `gameplay.lua:35–36` — fuel pickup spawn placement: `cos(angle) * dist`, `sin(angle) * dist` to scatter canisters around colony positions

### math.pi

Constant π (≈3.14159). Used to generate random angles in radians:

- `gameplay.lua:35` — `love.math.random() * math.pi * 2` for fuel pickup scatter direction
- `player.lua:14` — initial angle set to `-π / 2` (facing upward)

---

## Physics

### Momentum Model (No Drag)

Velocity accumulates via thrust (acceleration) but never decays. No friction, no drag.

```
vx = vx + cos(angle) * thrust * dt
vy = vy + sin(angle) * thrust * dt
```

Position integrates velocity each frame:

```
x = x + vx * dt
y = y + vy * dt
```

This produces Asteroids-style momentum: the ship drifts indefinitely unless velocity is explicitly cancelled by counter-thrust or clamped by world bounds.

**Used in:** `player.lua:62–63` (thrust), `player.lua:73–74` (position), `enemy.lua:30–38` (enemy thrust toward target), `bullet.lua:13–14` (velocity), `bullet.lua:20–21` (position)

### Gravity

Constant-magnitude acceleration toward nearby planets:

```
distance = sqrt(dx² + dy²)
if distance > 0 and distance ≤ gravityRadius:
  nx = dx / distance
  ny = dy / distance
  vx += nx * gravityStrength * dt
  vy += ny * gravityStrength * dt
```

Gravity is applied at full strength throughout the radius (no inverse-square falloff). Multiple planets stack linearly.

| Source       | Radius | Strength      |
|--------------|--------|---------------|
| Home Planet  | 300    | radius × 0.5  |
| Enemy Colony | 200    | radius × 0.5  |

Affected objects: player, bullets (player only), enemies, scraps, fuel pickups. Enemy bullets are not affected.

**Used in:** `gravity.lua` (core), `gameplay.lua:106–141` (gravity setup and application per frame)

### Speed Clamping

Velocity magnitude is capped by normalizing and scaling:

```
speed = sqrt(vx² + vy²)
if speed > maxSpeed:
  vx = (vx / speed) * maxSpeed
  vy = (vy / speed) * maxSpeed
```

Direction is preserved — only the magnitude is reduced.

| Entity  | maxSpeed | Constant             |
|---------|----------|----------------------|
| Player  | 1500     | `PLAYER_MAX_SPEED`   |
| Fighter | 150      | `FIGHTER_SPEED`      |
| Bomber  | 50       | `BOMBER_SPEED`       |

**Used in:** `player.lua:67–71` (player speed cap), `enemy.lua:47–51` (enemy speed cap)

### Integrity Damage Tiers

Integrity loss per second based on speed threshold, applied every frame as `loss * dt`:

| Speed     | Loss/s |
|-----------|--------|
| ≤ 600     | 0      |
| > 600     | 1      |
| > 800     | 4      |
| > 1000    | 30     |

Implementation uses a cascading `if-elseif` chain, checking highest threshold first.

**Used in:** `player.lua:99–111`

---

## Interpolation

### Camera Lerp (Smooth Follow)

Linear interpolation toward a target each frame:

```
cam.x = cam.x + (target.x - cam.x) * smooth * dt
cam.y = cam.y + (target.y - cam.y) * smooth * dt
```

Where `smooth = 5` (hardcoded). This is equivalent to exponential smoothing with factor `1 - e^(-smooth * dt)`. Higher smooth values = faster tracking.

**Used in:** `camera.lua:17–20`

### Rotation Speed Scaling

Rotation rate decreases as ship speed increases, using linear interpolation between two rates:

```
t = min(speed / PLAYER_MAX_SPEED, 1)
rotSpeed = PLAYER_ROTATION_SPEED * (1 - t) + PLAYER_ROTATION_MIN_SPEED * t
```

At speed 0: `rotSpeed = 3.0 rad/s`. At max speed (1500): `rotSpeed = 0.5 rad/s`. The lerp is linear with respect to speed ratio, clamped to [0, 1].

**Used in:** `player.lua:49–50`

---

## Collision Detection

### Circle–Circle Intersection

Two circles with centers (x₁, y₁), (x₂, y₂) and radii r₁, r₂ intersect when:

```
dx = x₂ - x₁
dy = y₂ - y₁
distance = sqrt(dx² + dy²)
collision = distance < r₁ + r₂
```

Strict inequality (not ≤) so tangential grazing doesn't count as a hit.

**Used in** `gameplay.lua` for every collision pair:

| Pair                          | Line(s) | Action                      |
|-------------------------------|---------|-----------------------------|
| Player bullet ↔ enemy         | 149–166 | Damage enemy, drop scrap    |
| Bullet ↔ colony               | 172–183 | Damage colony HP            |
| Enemy ↔ home planet           | 188–196 | Damage planet HP            |
| Enemy bullet ↔ player         | 200–208 | Damage player integrity     |
| Player ↔ scrap                | 212–221 | Collect scrap               |
| Player ↔ fuel pickup          | 225–233 | Collect fuel                |
| Player ↔ home planet          | 237–244 | Convert scrap to money      |
| Player ↔ home planet (near)   | 247–251 | Show shop prompt            |

### Planet–Gravity Radius Check

```
distance ≤ gravityRadius
```

Used to determine whether gravity applies. Unlike collision, this uses `≤` (inclusive).

**Used in:** `gravity.lua:12`

---

## Coordinate Systems

### World Space vs Screen Space

- **World space**: 8000 × 8000 units, origin at top-left. All entities store positions and velocities in world space.
- **Screen space**: 1280 × 720 pixels (the window). UI elements (HUD, minimap, shop) draw in screen space.

### Camera Translation

The camera transform bridges the two spaces. When `camera:apply()` is called, Love2D's transform is pushed and translated:

```
translate(-floor(cam.x - WINDOW_WIDTH / 2), -floor(cam.y - WINDOW_HEIGHT / 2))
```

Equivalently:

```
screenX = worldX - cam.x + WINDOW_WIDTH / 2
screenY = worldY - cam.y + WINDOW_HEIGHT / 2
```

And in reverse (screen → world):

```
worldX = screenX + cam.x - WINDOW_WIDTH / 2
worldY = screenY + cam.y - WINDOW_HEIGHT / 2
```

The `math.floor` on the translation keeps pixel alignment clean.

**Used in:** `camera.lua:25–30`

### Minimap Projection

World positions are projected onto the 200×200 minimap by linear scaling:

```
mapX = minimapLeft + worldX * (MINIMAP_SIZE / WORLD_WIDTH)
mapY = minimapTop  + worldY * (MINIMAP_SIZE / WORLD_HEIGHT)
```

Scale factor: `200 / 8000 = 0.025`.

**Used in:** `minimap.lua:33–58`

### Background Tile Culling

Only tiles visible within the camera viewport are drawn. Tile positions snap to a `TILE_SIZE` (200) grid:

```
startX = max(0, floor(camLeft / TILE_SIZE) * TILE_SIZE)
startY = max(0, floor(camTop  / TILE_SIZE) * TILE_SIZE)
endX   = min(WORLD_WIDTH,  camRight  + TILE_SIZE)
endY   = min(WORLD_HEIGHT, camBottom + TILE_SIZE)
```

**Used in:** `gameplay.lua:351–361`

---

## Other

### Spawn Interval Escalation

Spawn interval decreases in steps based on elapsed time:

```
escalations = floor(elapsedTime / ENEMY_SPAWN_ESCALATION_TIME)
interval = max(ENEMY_SPAWN_INTERVAL_MIN, ENEMY_SPAWN_INTERVAL_START - escalations * step)
```

Where `step = ENEMY_SPAWN_ESCALATION_STEP * difficulty`.

**Used in:** `enemyplanet.lua:64–68`

### Wave Size Growth

Base wave size grows over time, multiplied by difficulty, then rounded:

```
growthSteps = floor(globalElapsed / ESCALATION_GROWTH_TIME)
baseSize = min(ESCALATION_WAVE_MAX, ESCALATION_WAVE_SIZE + growthSteps * ESCALATION_WAVE_GROWTH)
finalSize = max(1, floor(baseSize * difficulty + 0.5))
```

The `+ 0.5` before `floor` implements rounding to the nearest integer.

**Used in:** `enemyplanet.lua:74–77`

### Fighter / Bomber Wave Split

Wave composition: 60% fighters, 40% bombers.

```
fighterCount = floor(waveSize * 0.6 + 0.5)
bomberCount = waveSize - fighterCount
```

`+ 0.5` rounding ensures fighters are rounded to nearest integer, bombers get the remainder.

**Used in:** `enemyplanet.lua:106–107`

### Warning Alpha Fade

In the 5 seconds before a wave, alpha fades linearly:

```
timeToWave = waveInterval - waveTimer    -- seconds until wave
if timeToWave > 4:   alpha = (5 - timeToWave) / 1    -- fade in
if timeToWave > 1:   alpha = 1                       -- hold full
if timeToWave ≤ 1:   alpha = timeToWave / 1          -- fade out
```

This creates a 1-second fade in, 3-second hold, 1-second fade out.

**Used in:** `enemyplanet.lua:120–129`

### Shop Prompt Pulse

Text alpha oscillates using a sine wave:

```
alpha = 0.6 + sin(time * 3) * 0.3
```

Range: [0.3, 0.9], frequency: 3 rad/s ≈ 0.48 Hz (one full pulse every ~2.1 seconds).

**Used in:** `shop.lua:87`

### Defense Radius per Level

Linear growth with level:

```
radius = DEFENSE_RADIUS_BASE + (level - 1) * DEFENSE_RADIUS_PER_LEVEL
```

Level 1: 150, Level 2: 200, Level 3: 250.

**Used in:** `planetdefense.lua:30–33`

### Enemy Planet HP Bar Gradient

The HP bar color transitions from green through yellow to red as HP decreases:

```
ratio = hp / maxHp
if ratio > 0.5:
  r = 1 - (ratio - 0.5) * 2    -- r goes 1→0
  g = 1                          -- g stays 1
else:
  r = 1                          -- r stays 1
  g = ratio * 2                  -- g goes 1→0
```

Blue channel is fixed at 0.1. At full HP: (0, 1, 0.1). At 50% HP: (1, 1, 0.1). At 0% HP: (1, 0, 0.1).

**Used in:** `enemyplanet.lua:171–178`

### Sprite Scaling

Planet sprites are scaled from their frame pixel dimensions to match the collision radius:

```
scale = radius * 2 / FRAME_WIDTH
```

Both home planet (`planet.lua:59`) and enemy planets (`enemyplanet.lua:151`) use the same formula.

**Used in:** `planet.lua:59`, `enemyplanet.lua:151`

### Cooldown Accumulator

Timers count down using a subtractive accumulator (resets to fire rate on firing):

```
cooldown = max(0, cooldown - dt)
if cooldown ≤ 0:
  -- fire
  cooldown = fireRate
```

Frame-rate independent — the accumulator naturally handles variable dt.

**Used in:** `player.lua:92` (shoot cooldown), `planetdefense.lua:56–60` (defense fire rate), `enemy.lua:60–64` (fighter fire timer, which uses an additive counter instead: `timer += dt; if timer ≥ rate then timer = 0`)
