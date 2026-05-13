# State Manager

## Purpose

Handles switching between game states (e.g., gameplay, game over). States are self-contained modules with their own `update`, `draw`, and input callbacks.

## How It Works

States are registered by name. When switching, the current state's `exit()` is called (if it exists), then the new state's `enter()` is called. Love2D callbacks (`love.update`, `love.draw`, etc.) are forwarded to the active state via the state manager.

The global `Game.stateManager` is created in `main.lua` and is the only way to change states.

## Public API

### `StateManager.new()`
Creates a new state manager with no active state.

### `StateManager:register(name, state)`
Registers a state module by name so it can be switched to later.

- `name` — string key used to identify the state
- `state` — table that implements the required callbacks

### `StateManager:switchTo(name, params)`
Switches to a registered state. Calls `exit()` on the current state and `enter(params)` on the new one.

- `name` — string matching a registered state name
- `params` — optional table passed to the new state's `enter()`

### `StateManager:update(dt)`, `StateManager:draw()`, `StateManager:keypressed(key)`, `StateManager:mousepressed(x, y, button)`
Forwards the Love2D callback to the active state. Input callbacks are only forwarded if the state implements the corresponding method.

## State Interface

Every state should implement:

```lua
function State:enter(params) end  -- called on switchTo
function State:exit() end         -- called before leaving
function State:update(dt) end
function State:draw() end
function State:keypressed(key) end      -- optional
function State:mousepressed(x, y, button) end  -- optional
```

Only `update` and `draw` are required. The rest are optional and checked with a nil guard.

## How to Register and Switch

```lua
-- In main.lua or anywhere during load:
Game.stateManager:register("myState", MyState)

-- To activate:
Game.stateManager:switchTo("myState", { someData = 42 })
```

## Gotchas

- States are singletons — the same state table is reused each time you switch to it. If you need fresh state each time, create new instances in `enter()`.
- `switchTo` immediately calls `exit()` on the old state and `enter()` on the new one. This means it's safe to call from within `update()`.
