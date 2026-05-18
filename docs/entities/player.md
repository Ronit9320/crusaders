# Player Entity

## Purpose

The player's ship, controlled with a thruster-based Asteroids-style movement system. Fires bullets in the ship's facing direction on left-click. Tracks integrity (damaged by high speeds) and fuel (consumed by engines).

## How It Works

The ship has a persistent velocity vector (`vx`, `vy`) with no drag — it only changes when thrust is applied. Rotation speed scales inversely with current speed: full rotation rate at rest, minimum rate at max speed.

Thrust is always applied forward along the ship's facing direction. There is no lateral or reverse thrust. The ship coasts indefinitely once velocity is built up.

## Public API

### `Player.new()`
Creates a player at world center offset 80px upward. Starts with zero velocity, facing up (`-math.pi / 2`), full integrity (1000), full fuel (100), weapons at base stats.

### `Player:update(dt)`
Reads keyboard input (W, A, D). Rotates the ship if A/D are held, with speed-dependent rotation rate. Applies forward thrust if fuel > 0. Clamps speed to `PLAYER_MAX_SPEED` (1500). Moves position by velocity. Clamps position to world bounds (zeroes offending velocity component on wall hit). Drains fuel per active engine. Applies integrity loss based on speed thresholds. Triggers game over via `Game.stateManager:switchTo("gameover", { reason = "integrity" })` if integrity reaches 0.

### `Player:draw(camera)`
Draws the player as a green triangle pointing in `self.angle` direction.

### `Player:canShoot()`
Returns `true` if the shoot cooldown has expired.

### `Player:resetCooldown()`
Sets the shoot cooldown to `self.bulletCooldown` (default `BULLET_COOLDOWN` 0.2s, modified by weapons upgrade).

### `Player:upgradeFuel()`
Increases `maxFuel` by `UPGRADE_FUEL_AMOUNT` (25) and refills `fuel` to the new maximum.

### `Player:upgradeIntegrity()`
Increases `maxIntegrity` by `UPGRADE_INTEGRITY_AMOUNT` (200) and adds the same amount to current `integrity`, clamped to the new maximum.

### `Player:upgradeThrust()`
Increases both `thrust` and `singleThrust` by `UPGRADE_THRUST_AMOUNT` (40).

### `Player:upgradeWeapons(level)`
Recalculates weapon stats from base values:

| Level | Effect                        |
|-------|-------------------------------|
| 0     | Damage 1, cooldown 0.2s, speed 600 |
| 1     | Damage 2                      |
| 2     | Cooldown 0.14s (-30%)         |
| 3     | Speed 720 (+20%)              |

## Controls

| Key        | Action                                                    |
|------------|-----------------------------------------------------------|
| W          | Both engines fire — full thrust forward                   |
| A          | Left engine fires — rotate left + partial thrust forward  |
| D          | Right engine fires — rotate right + partial thrust forward|
| Left mouse | Shoot in ship's facing direction (`self.angle`)           |

## Engine and Fuel System

- Ship carries `SHIP_FUEL_MAX` (100) metric tonnes of fuel.
- Each engine consumes `ENGINE_FUEL_DRAIN` (0.2) tonnes per second while active.
- Engine count per action:
  - W: 2 engines (drains `ENGINE_FUEL_DRAIN * 2 * dt`)
  - A alone: 1 engine
  - D alone: 1 engine
  - A + D (no W): 2 engines
  - W + A or W + D: 2 engines
- When fuel hits 0, engines are dead — no thrust can be applied. The ship continues drifting.
- Fuel 0 is **not** game over. The ship simply drifts until integrity fails.

## Integrity System

- Starts at `SHIP_INTEGRITY_MAX` (1000).
- Integrity is lost every frame based on current speed:

  | Speed          | Loss per second |
  |----------------|-----------------|
  | ≤ 600          | 0               |
  | > 600          | 1               |
  | > 800          | 4               |
  | > 1000         | 30              |

- When integrity reaches 0, game over triggers with `{ reason = "integrity" }`.

## Rotation Speed Scaling

Rotation speed lerps linearly between `PLAYER_ROTATION_SPEED` (3.0 rad/s at speed 0) and `PLAYER_ROTATION_MIN_SPEED` (0.5 rad/s at `PLAYER_MAX_SPEED` and above).

## Speed Cap

Hard cap at `PLAYER_MAX_SPEED` (1500). Velocity magnitude is clamped every frame after thrust is applied.

## Starting Stats

| Stat            | Value |
|-----------------|-------|
| Position        | (4000, 3920) — world center, 80px up |
| Thrust          | 200   |
| SingleThrust    | 80    |
| Max Fuel        | 100   |
| Max Integrity   | 1000  |
| Bullet Damage   | 1     |
| Bullet Cooldown | 0.2s  |
| Bullet Speed    | 600   |

## Gotchas

- `update()` calls `Game.stateManager:switchTo("gameover")` directly when integrity is exhausted. The gameplay state guards against this by checking `current.name` after `player:update()`.
- The ship has no brake thruster. To slow down, rotate and thrust opposite to your current velocity direction.
- Shooting direction is independent of velocity — bullets always fire in `self.angle` direction, not the direction of travel.
- Speed cap of 1500 means the >1000 integrity damage tier is reachable, losing 30 integrity per second.
- W and A/D together produce full thrust, not single thrust.
