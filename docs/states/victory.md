# Victory State

## Purpose

Displayed when the player destroys all three enemy colonies. Shows a summary of the run and offers a restart.

## How It Works

The victory state is switched to from `Gameplay:update()` when all enemy planets have `alive == false`. It receives a params table with end-of-run statistics and displays them centered on screen. The game loops here until the player chooses to restart.

## Public API

### `Victory:enter(params)`
Stores stats from the completed run:
- `params.timeSurvived` — total elapsed seconds
- `params.scrapsCollected` — total scraps collected over the run
- `params.moneySpent` — total money spent on upgrades

### `Victory:update(dt)`
No-op. The victory screen is static.

### `Victory:draw()`
Renders the victory screen:
1. "VICTORY" header in white, centered, 60px above midpoint
2. Stats block with three lines:
   - `Time survived: X seconds`
   - `Scraps collected: X`
   - `Money spent: $X`
3. "Press ENTER to restart" prompt in white, 60px below midpoint

### `Victory:keypressed(key)`
Restarts the game on ENTER or R:
```lua
Game.stateManager:switchTo("gameplay")
```

## Displayed Stats

| Stat             | Source                             |
|------------------|------------------------------------|
| Time survived    | `love.timer.getTime() - startTime` |
| Scraps collected | `totalScrapsCollected`             |
| Money spent      | `moneySpent` (tracked on purchase) |

## Gotchas

- The victory state does not need to pass params back to gameplay — `switchTo("gameplay")` creates a fresh state.
- Stats are formatted with `string.format("%.0f seconds", ...)` — the time is shown as an integer.
- ENTER and R both trigger restart.
