# Player Entity

## Purpose

The player's ship, controlled with a thruster-based Asteroids-style movement system. Fires bullets in the ship's facing direction on left-click.

## How It Works

The ship has a persistent velocity vector (`vx`, `vy`) with no drag — it only changes when thrust is applied. The ship also has an orientation (`self.angle`) that determines both the direction of thrust and the draw direction. Rotation speed scales inversely with current speed: full rotation rate at rest, minimum rate at max speed.

Thrust is always applied forward along the ship's facing direction (`math.cos(self.angle)`, `math.sin(self.angle)`). There is no lateral or reverse thrust. The ship coasts indefinitely once velocity is built up.

## Public API

### `Player.new()`
Creates a player at world center offset slightly upward. Starts with zero velocity, facing up (`-math.pi / 2`), full integrity, full fuel, cooldown at 0.

### `Player:update(dt)`
Reads keyboard input (W, A, D). Rotates the ship if A/D are held, with speed-dependent rotation rate. Applies forward thrust if fuel > 0. Clamps speed to `PLAYER_MAX_SPEED`. Moves position by velocity. Clamps to world bounds (zeroes the offending velocity component on wall hit). Drains fuel per active engine. Applies integrity loss based on speed thresholds. Triggers game over if integrity reaches 0.

### `Player:draw(camera)`
Draws the player as a green triangle pointing in `self.angle` direction. No mouse involvement.

### `Player:canShoot()`
Returns `true` if the shoot cooldown has expired.

### `Player:resetCooldown()`
Sets the shoot cooldown to `BULLET_COOLDOWN` (0.2s).

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
- Fuel is displayed as `X.XX t` in the HUD.

## Integrity System

- Starts at `SHIP_INTEGRITY_MAX` (1000).
- Integrity is lost based on current speed every frame:
  - Speed > 600: 1 per second
  - Speed > 800: 4 per second
  - Speed > 1000: 30 per second
  - Speed ≤ 600: no loss
- Displayed as a percentage in the HUD.
- When integrity reaches 0, game over triggers with `{ reason = "integrity" }`.

## Rotation Speed Scaling

Rotation speed is not fixed. It lerps linearly between `PLAYER_ROTATION_SPEED` (3.0 rad/s at speed 0) and `PLAYER_ROTATION_MIN_SPEED` (0.5 rad/s at `PLAYER_MAX_SPEED` and above).

## Speed Cap

Hard cap at `PLAYER_MAX_SPEED` (1500). Velocity magnitude is clamped every frame after thrust is applied.

## Gotchas

- `update()` calls `Game.stateManager:switchTo("gameover")` directly when integrity is exhausted. The calling state must guard against this if needed.
- The ship has no brake thruster. To slow down, rotate and thrust opposite to your current velocity direction.
- Shooting direction is independent of velocity — bullets always fire in `self.angle` direction, not the direction of travel.
- Speed cap of 1500 means the >1000 integrity damage tier is reachable.
