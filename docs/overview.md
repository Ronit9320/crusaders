# vibe_v0 Overview

A top-down space defense game built with Love2D. The player flies a ship around an 8000x8000 world, collects scrap from destroyed enemies, converts scrap to money at the home planet, and spends money on upgrades. Three enemy colonies with escalating difficulty must be destroyed to win.

## Project Structure

```
/
├── main.lua                      # Entry point, creates Game global, registers states
├── conf.lua                      # Love2D window configuration
├── assets/
│   ├── background/background.png # Tiled world background
│   └── planet/                   # Spritesheets for home and enemy planets
├── src/
│   ├── constants.lua             # All tunable values in one place
│   ├── entities/                 # Game object definitions (player, enemies, fuel, scrap)
│   ├── systems/                  # Engine systems (camera, state manager, defense, gravity)
│   ├── states/                   # Game states (gameplay, gameover, victory)
│   └── ui/                       # Interface overlays (shop, minimap)
└── docs/                         # This documentation
```

## How Systems Connect

```
main.lua
  └── Game.stateManager (statemanager.lua)
        ├── "gameplay" (gameplay.lua)
        │     ├── camera.lua          — world-to-screen transform
        │     ├── player.lua          — ship movement, shooting, fuel, integrity
        │     ├── planet.lua          — home base with HP
        │     ├── bullet.lua          — projectiles (player + defense)
        │     ├── enemy.lua           — fighter & bomber enemies
        │     ├── enemyplanet.lua     — destructible colonies, spawn + waves
        │     ├── scrap.lua           — money pickups
        │     ├── fuelpickup.lua      — fuel canisters
        │     ├── planetdefense.lua   — multi-target turret system with spread
        │     ├── minimap.lua         — world overview overlay
        │     └── shop.lua            — multi-item upgrade overlay
        ├── "gameover" (gameover.lua)
        │     └── restart prompt
        └── "victory" (victory.lua)
              └── stats + restart prompt

## Game Loop

### Update Order (`Gameplay:update(dt)`)

1. Early return if shop is open (game paused)
2. Check planet destruction → game over
3. Advance global elapsed time
4. Update player (rotation, thrust, fuel drain, integrity, speed cap)
5. Check if player integrity death triggered state switch
6. Update camera (smooth follow)
7. Update planet animation
8. Handle player shooting (left mouse, fires in ship's facing direction)
9. Update all bullets (movement + bounds check)
10. Update enemy planets (spawn timer, wave timer, wave launch)
11. Update all enemies (movement toward target)
12. Update enemy bullets
13. Apply gravity (affects player, bullets, enemies, scraps, fuel)
14. Update defense system (fires at all enemies in range)
15. Bullet-enemy collision (damage + scrap + fuel drops)
16. Bullet-colony collision (damage colonies)
17. Enemy-planet collision (planet damage)
18. Enemy bullet-player collision (integrity damage)
19. Player-scrap collection
20. Player-fuel collection
21. Scrap-to-money conversion (at planet)
22. Near-planet check (for shop prompt)
23. Cleanup dead/collected objects
24. Victory check (all colonies dead)

### Draw Order (`Gameplay:draw()`)

1. `camera:apply()` — enter world space
2. `drawBackground()` — tiled world background (visible tiles only)
3. Planet sprite + defense radius
4. Enemy planets (with HP bar or dead overlay)
5. Scrap pickups + fuel canisters
6. Enemies
7. Bullets (player + enemy)
8. Player ship
9. `camera:unapply()` — return to screen space
10. `drawUI()` — HUD (planet HP, scrap count, money, integrity %, fuel, speed)
11. Minimap overlay
12. Attack wave warnings (pulsing text)
13. Shop prompt ("Press E")
14. Shop overlay (if open)

## Controls

| Key        | Action                                                    |
|------------|-----------------------------------------------------------|
| W          | Both engines fire — full thrust forward                   |
| A          | Left engine fires — rotate left + partial thrust forward  |
| D          | Right engine fires — rotate right + partial thrust forward|
| E          | Open/close shop (when near planet)                        |
| ESC        | Close shop                                                |
| Left mouse | Shoot in ship's facing direction                          |

## Game Over Reasons

| Reason     | Trigger                                            |
|------------|----------------------------------------------------|
| `planet`   | Home planet HP reaches 0                           |
| `integrity`| Player ship integrity reaches 0 (excessive speed)  |
| victory    | All enemy colonies destroyed                       |

## Constants (`src/constants.lua`)

Every tunable value (speeds, sizes, colors, timers, costs) lives in a single table returned by `constants.lua`. No magic numbers anywhere in source files. Reference via `require("src.constants")`:

```lua
local Constants = require("src.constants")
-- Constants.PLAYER_THRUST, Constants.BULLET_COLOR, etc.
```

### Debug Mode

Set `DEBUG = true` in `constants.lua` to enable debug prints.

## How to Add a New State

1. Create `src/states/mystate.lua` following the standard module pattern
2. Implement the required callbacks: `enter()`, `exit()`, `update(dt)`, `draw()`, `keypressed(key)`, `mousepressed(x, y, button)`
3. Register it in `main.lua`:
```lua
local MyState = require("src.states.mystate")
Game.stateManager:register("mystate", MyState)
```
4. Switch to it with `Game.stateManager:switchTo("mystate", params)`

## How to Add a New Entity

1. Create `src/entities/myentity.lua` following the table/metatable pattern with `new()`, `update(dt)`, `draw(camera)` methods
2. Require it in `src/states/gameplay.lua` (or wherever it's used)
3. Create instances in `Gameplay:enter()` and store them (e.g., `self.myEntities = {}`)
4. Update them in `Gameplay:update(dt)` and draw them in `Gameplay:draw()`
5. Add cleanup logic in `Gameplay:cleanup()` if they have `alive`/`collected` flags

## How to Add a New Shop Item

1. Add any new constants to `src/constants.lua` (costs, levels, etc.)
2. Add the item definition to `Shop.new()` in `src/ui/shop.lua`:
```lua
{
    name = "My Upgrade",
    description = "What it does.",
    baseCost = 10,
    upgradeCost = 15,
    maxLevel = 3,
}
```
3. Create or extend the system it upgrades (e.g., a new system in `src/systems/`)
4. Wire the purchase in `Gameplay:mousepressed()` — call the shop's `tryBuy()` and apply the result to the relevant system

## Gotchas

- Avoid circular requires. If two systems need to talk, use the event system or pass data through `Game`.
- Load assets once at startup or state load. Never inside `update()` or `draw()`.
- No Love2D objects (images, sounds) as globals.
- All world-space draws must be between `camera:apply()` and `camera:unapply()`.
- All screen-space draws (UI) must be after `camera:unapply()`.
- The player ship has no brake thruster — to slow down, rotate and thrust opposite to your velocity.
- Fuel depletion disables engines but is not game over. The ship drifts until integrity fails.
