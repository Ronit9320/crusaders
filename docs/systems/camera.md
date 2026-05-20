# Camera System

## Purpose

Transforms world-space coordinates to screen-space so the viewport follows the player. The world is 8000x8000 but the window is 1280x720 — the camera bridges the two.

## How It Works

The camera stores its own `(x, y)` in world coordinates. On each frame, `follow()` lerps the camera toward the target (the player). `apply()` pushes the current transform and translates so that the camera position is centered on screen. All subsequent draw calls are in world space. `unapply()` pops the transform, returning to screen space.

## Public API

### `Camera.new()`
Creates a camera centered at `(WORLD_WIDTH/2, WORLD_HEIGHT/2)`.

### `Camera:follow(target, dt)`
Smoothly moves the camera toward `target` (must have `.x` and `.y`). Uses a hardcoded smoothing factor of 5.

- `target` — table with `x` and `y` fields
- `dt` — delta time in seconds

### `Camera:apply()`
Pushes the Love2D transform and translates so world objects draw relative to camera position. Must be called before any world-space draw calls.

### `Camera:unapply()`
Pops the transform. Must be called after all world-space draws and before screen-space UI draws.

## World Space vs Screen Space

- **World space**: The 8000x8000 game world. All entities store position in world space. Draw calls between `apply()`/`unapply()` are in world space.
- **Screen space**: The 1280x720 window. UI elements (HUD, shop) draw after `unapply()`.

Converting between them:
```lua
-- screen to world
worldX = screenX + camera.x - WINDOW_WIDTH / 2
worldY = screenY + camera.y - WINDOW_HEIGHT / 2
```

## Gotchas

- Camera uses `math.floor` on the translation — sub-pixel camera positions can cause slight jitter on entities. This is intentional to keep pixel alignment clean.
- The smoothing is framerate-dependent (lerp with hardcoded `smooth = 5` multiplied by `dt`).
- Do not call `love.graphics.setColor` between `apply()` and world draw calls unless you intend to tint everything.
