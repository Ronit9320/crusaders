# Player Entity

## Purpose

The player's ship, controlled with WASD/arrow keys. Faces toward the mouse cursor and fires bullets on left-click.

## How It Works

The player stores position, velocity direction (computed from held keys), fuel, and a shoot cooldown. Each frame, `update()` processes input, moves the ship, drains fuel, decrements the cooldown, and clamps position to world bounds. If fuel hits 0, it triggers game over.

## Public API

### `Player.new()`
Creates a player at world center offset slightly upward. Fully fueled, cooldown at 0.

### `Player:update(dt)`
Reads keyboard input (WASD/arrows), computes movement vector, applies speed and fuel drain. Clamps position to world bounds. Triggers game over if fuel reaches 0.

### `Player:draw(camera)`
Draws the player as a green triangle pointing toward the mouse cursor in world space. Converts screen-space mouse to world-space using camera position.

### `Player:getShotAngle(camera)`
Returns the angle (in radians) from the player's position to the mouse cursor in world space.

### `Player:canShoot()`
Returns `true` if the shoot cooldown has expired.

### `Player:resetCooldown()`
Sets the shoot cooldown to `BULLET_COOLDOWN` (0.2s).

## Fuel System

- Starts at `PLAYER_FUEL_MAX` (100).
- Drains at `PLAYER_FUEL_DRAIN` (5/s) only while moving.
- Fuel UI displays as a colored bar (green > 30%, yellow > 15%, red ≤ 15%).
- When fuel reaches 0, the state switches to "gameover" with `{ reason = "fuel" }`.
- Fuel is not replenishable (no pickup exists).

## Controls

| Key           | Action    |
|---------------|-----------|
| W / Up        | Move up   |
| S / Down      | Move down |
| A / Left      | Move left |
| D / Right     | Move right|
| Left mouse    | Shoot     |

## Gotchas

- `update()` calls `Game.stateManager:switchTo("gameover")` directly when fuel is exhausted. The calling state must guard against this (gameplay.lua checks `Game.stateManager.current.name` after player update).
- The player triangle orientation is always toward the mouse cursor — this affects firing direction.
