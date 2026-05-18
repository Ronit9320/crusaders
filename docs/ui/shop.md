# Shop UI

## Purpose

An in-game shop overlay that lets the player spend money on ship and defense upgrades. Supports 5 upgrade items with keyboard navigation and mouse click to buy.

## How It Works

The shop is a screen-space overlay. When the player is near the home planet, a pulsing "Press E to open shop" prompt appears. Pressing E toggles the shop open, which pauses gameplay (via `Gameplay:update()` returning early when `shop:isOpen()`). The shop displays the selected item's name, level, description, cost, and a buy button. Left/right arrow keys cycle between items. Clicking the buy button purchases or upgrades the selected item. The gameplay state applies the upgrade effect immediately via `Gameplay:applyUpgrade()`.

## Public API

### `Shop.new()`
Creates a new shop instance (closed by default). Initializes 5 upgrade items with their levels starting at 0.

### `Shop:isOpen()`
Returns `true` if the shop overlay is currently open.

### `Shop:toggle()`
Opens the shop if closed, closes it if open.

### `Shop:close()`
Closes the shop.

### `Shop:navLeft()`
Selects the previous item in the list (wraps around).

### `Shop:navRight()`
Selects the next item in the list (wraps around).

### `Shop:drawPrompt()`
Draws the "Press E to open shop" text at the bottom center of the screen with a pulsing alpha animation (`0.6 + 0.3 * sin(time * 3)`).

### `Shop:draw(money)`
Draws the full shop overlay (only if open). Shows a centred 420×340 panel with:
- "SHOP" header
- Current money and item index (e.g. "1 / 5")
- Selected item name (between `<` and `>` arrows)
- Level and max level
- Item description
- Buy button (green if affordable, dark red if not)
- "MAXED" label if item is at max level
- Navigation instructions footer

The `buyButton` hitbox is stored as `self.buyButton` for `tryBuy()`.

### `Shop:tryBuy(money)`
Attempts to purchase/upgrade the selected item.

**Returns**: `(success, newMoney, itemIndex, newLevel)`

- Returns `false, money, nil, nil` if no buy button exists (draw wasn't called), insufficient funds, or item already at max level.
- On success: deducts cost from `money`, increments the item's internal level, and returns the purchase details.
- The gameplay state uses the returned `itemIndex` and `newLevel` to apply the upgrade.

## Upgrade Items

| # | Item                  | Max Level | Cost Structure                      | Effect |
|---|-----------------------|-----------|-------------------------------------|--------|
| 1 | Planet Defense        | 3         | $10 (base) / $15 (upgrade)          | Auto-targets and fires at enemies near home planet. L1: 150 radius, 0.8s rate. L2: 200 radius, 0.5s rate. L3: 250 radius, 0.3s rate, triple spread shot. |
| 2 | Fuel Capacity         | 3         | $15 per level                       | +25 max fuel per level, refills tank on purchase |
| 3 | Integrity Reinforcement| 3        | $20 per level                       | +200 max hull integrity per level, heals same amount |
| 4 | Thrust Power          | 3         | $25 per level                       | +40 thrust and singleThrust per level |
| 5 | Weapons Upgrade       | 3         | $20 per level                       | L1: damage 1→2. L2: cooldown 0.2s→0.14s. L3: speed 600→720 |

## Navigation

| Input        | Action                  |
|--------------|-------------------------|
| Left arrow   | Previous item (wrap)    |
| Right arrow  | Next item (wrap)        |
| E            | Toggle shop open/close  |
| ESC          | Close shop              |
| Mouse click  | Buy button              |

## Upgrade Application

Each upgrade is applied immediately by `Gameplay:applyUpgrade(itemIndex, level)`:

1. **Planet Defense** — sets `self.defense.level = level` (system handles the rest internally)
2. **Fuel Capacity** — calls `player:upgradeFuel()`, which increases `maxFuel` and refills to the new maximum
3. **Integrity Reinforcement** — calls `player:upgradeIntegrity()`, which increases `maxIntegrity` and heals current integrity
4. **Thrust Power** — calls `player:upgradeThrust()`, which increases both `thrust` and `singleThrust`
5. **Weapons Upgrade** — calls `player:upgradeWeapons(level)`, recalculating `bulletDamage`, `bulletCooldown`, and `bulletSpeed` from base values

## Gotchas

- The shop stores a `buyButton` reference during `draw()` used by `tryBuy()` for hit detection and cost lookup. If `draw()` is not called before `tryBuy()`, `buyButton` is `nil` and no purchase will succeed.
- Upgrade levels persist for the session. There is no save/load system.
- Weapon upgrades are recalculated from base values each time, so they compose correctly regardless of purchase order.
- The shop stores all levels internally in `self.levels`. The gameplay state reads them on purchase to apply effects.
- The defense system's `level` is stored separately from the shop's internal level — `applyUpgrade` synchronizes them.
