# vibe_v0 Overview

A top-down space defense game built with Love2D. The player flies a ship around an 8000x8000 world, collects scrap from destroyed enemies, converts scrap to money at the home planet, and spends money on upgrades. Three enemy colonies with escalating difficulty must be destroyed to win.

## Project Structure

```
/
├── main.lua                      # Entry point, creates Game global, registers states
├── conf.lua                      # Love2D window configuration (1280x720, resizable off)
├── assets/
│   ├── background/
│   │   └── background.png        # Tiled world background (200x200 tiles)
│   └── planet/
│       ├── home_planetv2.png     # Home planet spritesheet (50 frames)
│       ├── enemy_planet1.png     # Enemy colony spritesheet variant 1
│       └── enemy_planet2.png     # Enemy colony spritesheet variant 2
├── src/
│   ├── constants.lua             # All tunable values in one place
│   ├── entities/
│   │   ├── player.lua            # Ship movement, shooting, fuel, integrity, upgrades
│   │   ├── enemy.lua             # Fighter & bomber enemy ships
│   │   ├── enemyplanet.lua       # Destructible colonies with spawn + wave system
│   │   ├── bullet.lua            # Projectiles with configurable color/speed
│   │   ├── planet.lua            # Home base with animated sprite and HP
│   │   ├── scrap.lua             # Money pickups dropped by enemies
│   │   └── fuelpickup.lua        # Fuel canisters from enemies + pre-placed
│   ├── systems/
│   │   ├── camera.lua            # World-to-screen transform, smooth follow
│   │   ├── statemanager.lua      # State registration and switching
│   │   ├── gravity.lua           # Planetary gravity on objects
│   │   └── planetdefense.lua     # Auto-turret with per-level fire rate + spread
│   ├── states/
│   │   ├── gameplay.lua          # Main game loop — update, draw, collision, flow
│   │   ├── gameover.lua          # Game over screen with restart prompt
│   │   └── victory.lua           # Victory screen with stats summary
│   └── ui/
│       ├── hud.lua               # Ship status, resources, and warnings overlay
│       ├── minimap.lua           # World overview in bottom-right corner
│       └── shop.lua              # Multi-item upgrade shop overlay
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
        │     ├── bullet.lua          — projectiles (player + defense + enemy)
        │     ├── enemy.lua           — fighter & bomber enemies
        │     ├── enemyplanet.lua     — destructible colonies, spawn + waves
        │     ├── scrap.lua           — money pickups
        │     ├── fuelpickup.lua      — fuel canisters
        │     ├── gravity.lua         — planetary gravitational pull
        │     ├── planetdefense.lua   — multi-target turret with spread
        │     ├── hud.lua             — ship status + resources + warnings
        │     ├── minimap.lua         — world overview overlay
        │     └── shop.lua            — multi-item upgrade overlay
        ├── "gameover" (gameover.lua)
        │     └── restart prompt (ENTER/R)
        └── "victory" (victory.lua)
              └── stats + restart prompt (ENTER/R)
```

## Game Loop

### Update Order (`Gameplay:update(dt)`)

1. Early return if shop is open (game paused)
2. Check planet destruction → game over with `{ reason = "planet" }`
3. Advance global elapsed time
4. Update player (rotation, thrust, fuel drain, integrity loss from speed, wall clamp)
5. Check if player integrity reached 0 → game over with `{ reason = "integrity" }`
6. Update camera (smooth follow toward player)
7. Update planet animation
8. Handle player shooting (left mouse held, fires in ship's facing direction)
9. Update all player bullets (movement + world bounds check)
10. Update enemy planets (animation, spawn timer, wave timer, wave launch)
11. Update all enemies (movement toward target, fighter firing)
12. Update enemy bullets
13. Apply gravity (affects player, bullets, enemies, scraps, fuel)
14. Update defense system (fires at all enemies in range simultaneously)
15. Bullet–enemy collision (damage + scrap + fuel drops)
16. Bullet–colony collision (damage colonies)
17. Enemy–planet collision (planet damage)
18. Enemy bullet–player collision (integrity damage)
19. Player–scrap collection
20. Player–fuel collection
21. Scrap-to-money conversion (when player touches home planet)
22. Near-planet check (for shop prompt)
23. Cleanup dead/collected objects
24. Victory check (all colonies dead)

### Draw Order (`Gameplay:draw()`)

1. `camera:apply()` — enter world space
2. `drawBackground()` — tiled world background (only visible tiles)
3. Planet sprite
4. Defense system (radius circle drawn around planet)
5. Enemy planets (animated sprite, HP bar, or dead overlay)
6. Scrap pickups + fuel canisters
7. Enemies
8. Bullets (player + enemy)
9. Player ship
10. `camera:unapply()` — return to screen space
11. Minimap overlay (bottom-right corner)
12. `hud:draw()` — ship status panel (top-left), resources panel (top-right), threat warnings (bottom-center)
13. Shop prompt ("Press E" — when near planet and shop closed)
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

## Win/Loss Conditions

| Outcome   | Trigger                                            | Screen         |
|-----------|----------------------------------------------------|----------------|
| Loss      | Home planet HP reaches 0 (`reason = "planet"`)     | Game over      |
| Loss      | Player integrity reaches 0 (`reason = "integrity"`)| Game over      |
| Win       | All 3 enemy colonies destroyed                     | Victory + stats|

Victory stats displayed: time survived (seconds), total scraps collected, money spent.

Both game over and victory accept ENTER or R to restart.

## Constants (`src/constants.lua`)

Every tunable value (speeds, sizes, colors, timers, costs) lives in a single table returned by `constants.lua`. Reference via:

```lua
local Constants = require("src.constants")
-- Constants.PLAYER_THRUST, Constants.BULLET_COLOR, etc.
```

Key constant groups:
- **Window/World**: `WINDOW_WIDTH` (1280), `WINDOW_HEIGHT` (720), `WORLD_WIDTH` (8000), `WORLD_HEIGHT` (8000)
- **Player**: `PLAYER_RADIUS` (12), `PLAYER_THRUST` (200), `PLAYER_SINGLE_THRUST` (80), `PLAYER_MAX_SPEED` (1500), `SHIP_INTEGRITY_MAX` (1000), `SHIP_FUEL_MAX` (100), `ENGINE_FUEL_DRAIN` (0.2)
- **Bullets**: `BULLET_RADIUS` (4), `BULLET_SPEED` (600), `BULLET_COOLDOWN` (0.2)
- **Fighter enemies**: `FIGHTER_RADIUS` (10), `FIGHTER_SPEED` (150), `FIGHTER_HP` (3), `FIGHTER_FIRE_RATE` (2.0)
- **Bomber enemies**: `BOMBER_RADIUS` (20), `BOMBER_SPEED` (50), `BOMBER_HP` (8), `BOMBER_PLANET_DAMAGE` (25)
- **Enemy planets**: `ENEMY_SPAWN_INTERVAL_START` (8.0), `ENEMY_SPAWN_INTERVAL_MIN` (2.0), `ESCALATION_WAVE_INTERVAL` (45.0)
- **Defense**: `DEFENSE_RADIUS_BASE` (150), `DEFENSE_RADIUS_PER_LEVEL` (50), `DEFENSE_FIRE_RATE` (0.8), `DEFENSE_SPREAD_ANGLE` (0.175)
- **Upgrade costs**: `UPGRADE_FUEL_COST` (15), `UPGRADE_INTEGRITY_COST` (20), `UPGRADE_THRUST_COST` (25), `UPGRADE_WEAPONS_COST` (20)
- **Gravity**: `GRAVITY_SCALE_FACTOR` (0.5), `HOME_PLANET_GRAVITY_RADIUS` (300), `ENEMY_PLANET_GRAVITY_RADIUS` (200)
- **HUD**: `HUD_PANEL_ALPHA` (0.75), `HUD_PADDING` (10), `HUD_BAR_WIDTH` (180), `HUD_BAR_HEIGHT` (14)

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
2. Add the item definition to `Shop.new()` in `src/ui/shop.lua` with `name`, `description`, `maxLevel`, and `getCost(level)` function
3. Create or extend the system it upgrades (e.g., a new system in `src/systems/`)
4. Wire the purchase in `Gameplay:mousepressed()` — call the shop's `tryBuy()` and apply the result to the relevant system via `Gameplay:applyUpgrade()`

## Gotchas

- Avoid circular requires. If two systems need to talk, use the event system or pass data through `Game`.
- Load assets once at startup or state load. Never inside `update()` or `draw()`.
- No Love2D objects (images, sounds) as globals.
- All world-space draws must be between `camera:apply()` and `camera:unapply()`.
- All screen-space draws (UI) must be after `camera:unapply()`.
- The player ship has no brake thruster — to slow down, rotate and thrust opposite to your velocity.
- Fuel depletion disables engines but is not game over. The ship drifts until integrity fails.
- Dead colonies still exert gravity — their `gravityStrength` remains active.
- `Player:update()` calls `Game.stateManager:switchTo("gameover")` directly when integrity hits 0. The gameplay state guards against double-switch by checking `Game.stateManager.current.name` after the player update.
