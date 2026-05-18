# FuelPickup Entity

## Purpose

Collectible fuel canisters that restore the player's fuel. Dropped by destroyed enemies and pre-placed near enemy planets at game start.

## How It Works

Fuel pickups are spawned at world positions and affected by gravity. When the player flies within collection range, the canister is consumed and `FUEL_PICKUP_AMOUNT` fuel is added to the player's tank (clamped to max capacity).

## Sources

| Source | Frequency |
|--------|-----------|
| Bomber death | Always drops 1 fuel pickup |
| Fighter death | 30% chance (`FIGHTER_FUEL_DROP_CHANCE`) |
| Enemy planet start | 3 canisters (`FUEL_CANISTER_COUNT`) placed randomly within 200px (`FUEL_CANISTER_SPREAD`) |

## Visual

- Outer rectangle: orange (`1.0, 0.7, 0.1`)
- Inner rectangle: light yellow (`1.0, 0.9, 0.4`) at half size
- Collection radius: 8px (`FUEL_PICKUP_RADIUS`)

## Public API

### `FuelPickup.new(x, y)`
Creates a new fuel pickup at the given world position. Initializes with zero velocity and `collected = false`.

### `FuelPickup:draw(camera)`
Draws the fuel canister as nested rectangles in world space.

## Gotchas

- Fuel pickups are affected by planet gravity (added to the gravity objects list in gameplay).
- The `collected` flag is used for cleanup — the entity persists until the next `keepAlive` pass.
- Fuel is clamped to `player.maxFuel` on collection, so upgrading fuel capacity doesn't create overflow.
