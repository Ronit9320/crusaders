# Shop UI

## Purpose

An in-game shop overlay that lets the player spend money on upgrades. Currently has one item: Planet Defense.

## How It Works

The shop is a screen-space overlay. When the player is near the home planet, a pulsing "Press E to open shop" prompt appears. Pressing E toggles the shop open, which pauses gameplay (via `Gameplay:update()` returning early when `shop:isOpen()`). The shop displays the available item, current level, cost, and a buy button. Clicking the buy button purchases or upgrades the item.

## Public API

### `Shop.new()`
Creates a new shop instance (closed by default). Initializes the item definition from constants.

### `Shop:isOpen()`
Returns `true` if the shop overlay is currently open.

### `Shop:toggle()`
Opens the shop if closed, closes it if open.

### `Shop:close()`
Closes the shop.

### `Shop:drawPrompt()`
Draws the "Press E to open shop" text at the bottom center of the screen with a pulsing alpha animation.

### `Shop:draw(money, defenseLevel)`
Draws the full shop overlay (only if open). Displays the panel with current money, item name, level, description, and buy button. Button color changes based on affordability.

- `money` — player's current money
- `defenseLevel` — current defense level (0-3)

### `Shop:tryBuy(money, defenseLevel)`
Attempts to purchase/upgrade. Returns `(success, newMoney, newLevel)`.

- Returns `false, money, defenseLevel` if no buy button exists, insufficient funds, or already at max level.
- Deducts cost from `money` and increments `defenseLevel`.

## How Buying and Upgrading Works

- First purchase (level 0 → 1): costs `DEFENSE_COST_BASE` ($10)
- Subsequent upgrades (level 1 → 2, 2 → 3): costs `DEFENSE_COST_UPGRADE` ($15) each
- At max level (`DEFENSE_MAX_LEVEL`, 3), the button is replaced by a "MAXED" label

## How to Add New Items

The shop currently holds a single item in `self.item`. To add more items:

1. Convert `self.item` to a list: `self.items = { ... }`
2. Add navigation (e.g., tabs or scroll) for selecting which item to view
3. Update `draw()` to render the selected item's details
4. Update `tryBuy()` to accept an item index and check that item's level cap

Each item definition follows this structure:

```lua
{
    name = "Item Name",
    description = "What it does.",
    baseCost = 10,       -- first purchase cost
    upgradeCost = 15,    -- subsequent upgrade cost
    maxLevel = 3,
}
```

## Gotchas

- The shop stores a `buyButton` reference during `draw()` that is used by `tryBuy()` for hit detection and cost lookup. If `draw()` is not called before `tryBuy()`, `buyButton` will be `nil` and no purchase will succeed.
- The shop does not manage money or defense level — it only reads and modifies them via return values. The gameplay state is responsible for applying changes.
