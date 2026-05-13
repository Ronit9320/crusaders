# Scrap Entity

## Purpose

Pickups dropped by destroyed enemies. Collected by the player and converted to money at the home planet.

## How It Works

When an enemy dies, a scrap pickup spawns at its position. The player can fly over scrap to collect it (tracked in a `scrapCount` on the gameplay state). When the player returns to the home planet (overlapping), all accumulated scrap is converted to money at a fixed exchange rate.

## Public API

### `Scrap.new(x, y)`
Creates a scrap pickup at `(x, y)`. Starts uncollected.

### `Scrap:draw(camera)`
Draws a blue circle with a smaller lighter-blue center circle.

## Collection Flow

1. Enemy dies → `Scrap.new(enemy.x, enemy.y)` added to `scraps` list
2. Player overlaps scrap (`dist < player.radius + scrap.radius`) → `scrap.collected = true`, `scrapCount++`
3. Player overlaps planet with `scrapCount > 0` → `money += scrapCount * SCRAP_TO_MONEY_RATE`, `scrapCount = 0`

## Conversion to Money

- Rate: `SCRAP_TO_MONEY_RATE` (1 money per scrap)
- Conversion only happens when the player touches the home planet
- All accumulated scrap is converted at once
- Money is displayed in the HUD and can be spent in the shop

## Gotchas

- Scrap collection is proximity-based (not click-to-collect).
- Collected scrap is flagged (`collected = true`) but remains in the list until cleaned up by `keepAlive` in the gameplay state.
- If you don't return to the planet, scrap accumulates indefinitely in the count.
