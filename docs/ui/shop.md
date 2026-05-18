# Shop UI

## Purpose

An in-game shop overlay that lets the player spend money on ship and defense upgrades. Supports 5 upgrade items with keyboard navigation.

## How It Works

The shop is a screen-space overlay. When the player is near the home planet, a pulsing "Press E to open shop" prompt appears. Pressing E toggles the shop open, which pauses gameplay (via `Gameplay:update()` returning early when `shop:isOpen()`). The shop displays the selected item's name, level, description, cost, and a buy button. Left/right arrow keys cycle between items. Clicking the buy button purchases or upgrades the selected item. The gameplay state applies the upgrade effect immediately.

## Public API

### `Shop.new()`
Creates a new shop instance (closed by default). Initializes 5 upgrade items and their max levels.

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
Draws the "Press E to open shop" text at the bottom center of the screen with a pulsing alpha animation.

### `Shop:draw(money)`
Draws the full shop overlay (only if open). Displays the panel with current money, item index, selected item name, level, description, and buy button. Button color changes based on affordability.

- `money` — player's current money

### `Shop:tryBuy(money)`
Attempts to purchase/upgrade the selected item. Returns `(success, newMoney, itemIndex, newLevel)`.

- Returns `false, money, nil, nil` if no buy button, insufficient funds, or already at max level.
- Deducts cost from `money` and increments the item's internal level.
- The gameplay state uses the returned `itemIndex` and `newLevel` to apply the upgrade.

## Upgrade Items

| # | Item                  | Max Level | Cost per Level | Effect |
|---|-----------------------|-----------|----------------|--------|
| 1 | Planet Defense        | 3         | $10 / $15 (upg)| Auto-targets enemies near home planet |
| 2 | Fuel Capacity         | 3         | $15            | +25 max fuel per level, refills on purchase |
| 3 | Integrity Reinforcement| 3        | $20            | +200 max hull integrity per level |
| 4 | Thrust Power          | 3         | $25            | +40 thrust per level |
| 5 | Weapons Upgrade       | 3         | $20            | L1: +1 damage, L2: -30% cooldown, L3: +20% speed |

## Navigation

- **Left arrow** — previous item
- **Right arrow** — next item
- **E** — toggle shop
- **ESC** — close shop
- **Mouse click** — buy button

## Upgrade Application

Each upgrade is applied immediately by `Gameplay:applyUpgrade(itemIndex, level)`:

1. **Planet Defense** — sets `self.defense.level`
2. **Fuel Capacity** — calls `player:upgradeFuel()`, which increases `maxFuel` and refills to the new maximum
3. **Integrity Reinforcement** — calls `player:upgradeIntegrity()`, which increases `maxIntegrity`
4. **Thrust Power** — calls `player:upgradeThrust()`, which increases both `thrust` and `singleThrust`
5. **Weapons Upgrade** — calls `player:upgradeWeapons(level)`, recalculating bulletDamage, bulletCooldown, and bulletSpeed from scratch

## Gotchas

- The shop stores a `buyButton` reference during `draw()` that is used by `tryBuy()` for hit detection and cost lookup. If `draw()` is not called before `tryBuy()`, `buyButton` will be `nil` and no purchase will succeed.
- Upgrade levels persist for the session. There is no save/load system.
- Weapon upgrades are recalculated from base values each time, so they compose correctly regardless of purchase order.
- The shop stores all levels internally in `self.levels`. The gameplay state reads them on purchase to apply effects.
