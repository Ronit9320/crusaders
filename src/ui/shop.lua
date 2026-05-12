local Constants = require("src.constants")

local Shop = {}
Shop.__index = Shop

--- Creates a new Shop UI.
function Shop.new()
    local self = setmetatable({}, Shop)
    self.open = false
    self.item = {
        name = "Planet Defense",
        description = "Auto-targets and fires at enemies\nnear the home planet.",
        baseCost = Constants.DEFENSE_COST_BASE,
        upgradeCost = Constants.DEFENSE_COST_UPGRADE,
        maxLevel = Constants.DEFENSE_MAX_LEVEL,
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
--- @param defenseLevel number
function Shop:draw(money, defenseLevel)
    if not self.open then return end

    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, Constants.WINDOW_WIDTH, Constants.WINDOW_HEIGHT)

    local panelW, panelH = 420, 280
    local panelX = (Constants.WINDOW_WIDTH - panelW) / 2
    local panelY = (Constants.WINDOW_HEIGHT - panelH) / 2

    love.graphics.setColor(0.15, 0.15, 0.25, 0.95)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SHOP", panelX, panelY + 12, panelW, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Money: $" .. money, panelX + 20, panelY + 40, panelW - 40, "left")

    local item = self.item
    local itemY = panelY + 75
    love.graphics.printf(item.name, panelX + 20, itemY, panelW - 40, "left")

    local levelText = "Level: " .. defenseLevel .. " / " .. item.maxLevel
    love.graphics.setColor(0.8, 0.8, 0.9)
    love.graphics.printf(levelText, panelX + 20, itemY + 22, panelW - 40, "left")

    love.graphics.setColor(0.6, 0.6, 0.7)
    love.graphics.printf(item.description, panelX + 20, itemY + 44, panelW - 40, "left")

    local cost
    if defenseLevel == 0 then
        cost = item.baseCost
    elseif defenseLevel < item.maxLevel then
        cost = item.upgradeCost
    else
        cost = nil
    end

    self.buyButton = nil

    if cost then
        local canBuy = money >= cost
        local buyX = panelX + panelW - 120
        local buyY = panelY + panelH - 60
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
        love.graphics.printf("MAXED", panelX + 20, panelY + panelH - 55, panelW - 40, "left")
    end

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("Press E or ESC to close", panelX, panelY + panelH - 25, panelW, "center")
end

--- Attempts to purchase/upgrade the current item.
--- @param money number
--- @param defenseLevel number
--- @return boolean success
--- @return number newMoney
--- @return number newLevel
function Shop:tryBuy(money, defenseLevel)
    if not self.buyButton then return false, money, defenseLevel end
    if money < self.buyButton.cost then return false, money, defenseLevel end
    if defenseLevel >= self.item.maxLevel then return false, money, defenseLevel end

    money = money - self.buyButton.cost
    defenseLevel = defenseLevel + 1
    return true, money, defenseLevel
end

return Shop
