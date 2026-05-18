# Minimap System

## Purpose

Provides a small radar-like overlay in the bottom-right corner of the screen showing the entire 8000x8000 world and all key entities.

## How It Works

The minimap renders after the camera has been unapplied, drawing a 200x200 pixel box in screen space. All world positions are scaled down by `MINIMAP_SIZE / WORLD_WIDTH` to fit. The HUD draws after so it renders on top.

## Displayed Elements

| Element       | Colour          | Size | Description                |
|---------------|-----------------|------|----------------------------|
| Home Planet   | Blue            | 4px  | Fixed at world center      |
| Enemy Colony  | Red (alive)     | 5px  | One per active colony      |
| Dead Colony   | Grey            | 5px  | One per destroyed colony   |
| Player        | Green           | 3px  | Current player position    |
| Enemies       | Light red       | 2px  | Every alive enemy ship     |

## Rendering

- Semi-transparent dark background (`0, 0, 0, 0.6`)
- White 1px border
- "MAP" label in top-left corner of the minimap
- All dots are filled circles drawn with `love.graphics.circle`
- Dead colonies use `(0.4, 0.4, 0.4)` — a muted grey distinct from the red of alive colonies

## Public API

### `Minimap.new()`
Creates a new minimap instance.

### `Minimap:draw(player, homePlanet, enemyPlanets, enemies)`
Renders the minimap. Accepts the player, home planet, enemy planets list, and enemies list.

## Gotchas

- Does not clip dots that fall outside the minimap bounds — they'll just be off the edge.
- World scale is calculated each frame as `200 / 8000` = 0.025.
- The minimap does not rotate or pan — it shows the whole world as a fixed top-down view.
- Dead colonies are still drawn on the minimap (as grey dots).
