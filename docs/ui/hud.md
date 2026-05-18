# HUD — Heads-Up Display

## Overview

The HUD module (`src/ui/hud.lua`) draws all on-screen status overlays in screen space after the camera transform is popped. It replaces the old ad-hoc `Gameplay:drawUI()` method.

## Layout

### Top-Left Panel — Ship Status
Semi-transparent rounded panel containing:
- **Integrity bar** — green (>60%), yellow (>30%), red (≤30%) with percentage
- **Fuel bar** — cyan with `.2f` precision, shows `current / max t`
- **Speed indicator** — color-coded text (white ≤600, yellow >600, orange >800, red >1000), shown as `X u/s`

### Top-Right Panel — Resources
Semi-transparent rounded panel containing:
- **Cash** — `$X`
- **Divider** — thin faint line
- **Scraps** — blue square icon + count

### Bottom Center — Threat Warnings
Pulsing red text per active colony wave warning. Y-position matches the original location (`H/2 - 80`). Multiple warnings stack vertically.

## Public API

```lua
--- Draws all HUD elements in screen space.
--- @param player    table  Player entity (needs .integrity, .maxIntegrity, .fuel, .maxFuel, .vx, .vy)
--- @param planet    table  Home planet entity (reserved for future use)
--- @param scrapCount number Current scrap count held by player
--- @param money      number Current money
--- @param warnings   table  List of { name = string, alpha = number } for active threats
function Hud:draw(player, planet, scrapCount, money, warnings)
```

## Bar Rendering

All bars (`HUD_BAR_WIDTH` x `HUD_BAR_HEIGHT`):
1. Dark grey background rect
2. Colored fill rect (inset 1px so white border is visible)
3. Thin white `rectangle("line")` border
4. Label left-aligned above bar, value right-aligned

## Constants

| Constant | Default | Description |
|---|---|---|
| `HUD_PANEL_ALPHA` | 0.75 | Background opacity for panels |
| `HUD_PADDING` | 10 | Internal panel padding in px |
| `HUD_BAR_WIDTH` | 180 | Width of status bars |
| `HUD_BAR_HEIGHT` | 14 | Height of status bars |
