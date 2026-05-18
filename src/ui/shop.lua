local Constants = require("src.constants")

local Shop = {}
Shop.__index = Shop

--- Creates a new Shop UI with multiple upgrade items.
function Shop.new()
    local self = setmetatable({}, Shop)
    self.open = false
    self.selectedIndex = 1
    self.levels = { 0, 0, 0, 0, 0 }

    self.items = {
        {
            name = "Planet Defense",
            description = "Auto-targets and fires at enemies\nnear the home planet.",
            maxLevel = Constants.DEFENSE_MAX_LEVEL,
            getCost = function(level)
                if level < 1 then return Constants.DEFENSE_COST_BASE end
                return Constants.DEFENSE_COST_UPGRADE
            end,
        },
        {
            name = "Fuel Capacity",
            description = "Increases max fuel by " .. Constants.UPGRADE_FUEL_AMOUNT .. " per level.\nRefills fuel on purchase.",
            maxLevel = 3,
            getCost = function() return Constants.UPGRADE_FUEL_COST end,
        },
        {
            name = "Integrity Reinforcement",
            description = "Increases hull integrity by " .. Constants.UPGRADE_INTEGRITY_AMOUNT .. " per level.",
            maxLevel = 3,
            getCost = function() return Constants.UPGRADE_INTEGRITY_COST end,
        },
        {
            name = "Thrust Power",
            description = "Increases engine thrust by " .. Constants.UPGRADE_THRUST_AMOUNT .. " per level.",
            maxLevel = 3,
            getCost = function() return Constants.UPGRADE_THRUST_COST end,
        },
        {
            name = "Weapons Upgrade",
            description = "L1: +1 damage. L2: -30% cooldown. L3: +20% speed.",
            maxLevel = 3,
            getCost = function() return Constants.UPGRADE_WEAPONS_COST end,
        },
    }

    self.buyButton = nil
    return self
end

--- Returns whether the shop overlay is open.
--- @return boolean
function Shop:isOpen()
    return self.open
end

--- Toggles the shop open/closed.
function Shop:toggle()
    self.open = not self.open
end

--- Closes the shop.
function Shop:close()
    self.open = false
end

--- Selects the previous item, wrapping around.
function Shop:navLeft()
    self.selectedIndex = self.selectedIndex - 1
    if self.selectedIndex < 1 then
        self.selectedIndex = #self.items
    end
end

--- Selects the next item, wrapping around.
function Shop:navRight()
    self.selectedIndex = self.selectedIndex + 1
    if self.selectedIndex > #self.items then
        self.selectedIndex = 1
    end
end

--- Draws the "Press E to open shop" prompt in screen space.
function Shop:drawPrompt()
    local alpha = 0.6 + math.sin(love.timer.getTime() * 3) * 0.3
    love.graphics.setColor(1, 1, 1, alpha)
    local text = "Press E to open shop"
    local w = Constants.WINDOW_WIDTH
    love.graphics.printf(text, 0, Constants.WINDOW_HEIGHT - 60, w, "center")
end

--- Draws the shop overlay.
--- @param money number
function Shop:draw(money)
    if not self.open then return end

    local w, h = Constants.WINDOW_WIDTH, Constants.WINDOW_HEIGHT

    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local panelW, panelH = 420, 340
    local px = (w - panelW) / 2
    local py = (h - panelH) / 2

    love.graphics.setColor(0.15, 0.15, 0.25, 0.95)
    love.graphics.rectangle("fill", px, py, panelW, panelH)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", px, py, panelW, panelH)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SHOP", px, py + 12, panelW, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Money: $" .. money, px + 20, py + 40, panelW - 40, "left")

    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.printf(self.selectedIndex .. " / " .. #self.items, px + 20, py + 40, panelW - 40, "right")

    local item = self.items[self.selectedIndex]
    local level = self.levels[self.selectedIndex]
    local itemY = py + 80

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("< " .. item.name .. " >", px + 20, itemY, panelW - 40, "center")

    love.graphics.setColor(0.8, 0.8, 0.9)
    love.graphics.printf("Level: " .. level .. " / " .. item.maxLevel, px + 20, itemY + 24, panelW - 40, "left")

    love.graphics.setColor(0.6, 0.6, 0.7)
    love.graphics.printf(item.description, px + 20, itemY + 48, panelW - 40, "left")

    local cost
    if level < item.maxLevel then
        cost = item.getCost(level)
    end

    self.buyButton = nil

    if cost then
        local canBuy = money >= cost
        local buyX = px + panelW - 120
        local buyY = py + panelH - 70
        local buyW, buyH = 100, 28

        if canBuy then
            love.graphics.setColor(0.2, 0.7, 0.2)
        else
            love.graphics.setColor(0.4, 0.2, 0.2)
        end
        love.graphics.rectangle("fill", buyX, buyY, buyW, buyH)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Buy ($" .. cost .. ")", buyX, buyY + 5, buyW, "center")

        self.buyButton = { x = buyX, y = buyY, w = buyW, h = buyH, cost = cost }
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.printf("MAXED", px + 20, py + panelH - 65, panelW - 40, "left")
    end

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("Press E or ESC to close  |  Arrow keys to navigate", px, py + panelH - 25, panelW, "center")
end

--- Attempts to purchase/upgrade the selected item.
--- @param money number
--- @return boolean success
--- @return number newMoney
--- @return number|nil itemIndex
--- @return number|nil newLevel
function Shop:tryBuy(money)
    if not self.buyButton then return false, money, nil, nil end
    if money < self.buyButton.cost then return false, money, nil, nil end

    local item = self.items[self.selectedIndex]
    local level = self.levels[self.selectedIndex]
    if level >= item.maxLevel then return false, money, nil, nil end

    money = money - self.buyButton.cost
    level = level + 1
    self.levels[self.selectedIndex] = level

    return true, money, self.selectedIndex, level
end

return Shop
