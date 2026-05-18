local Constants = require("src.constants")

local Hud = {}
Hud.__index = Hud

local PAD = Constants.HUD_PADDING
local BAR_W = Constants.HUD_BAR_WIDTH
local BAR_H = Constants.HUD_BAR_HEIGHT
local TEXT_H = 14
local GAP = 3
local ROW_SPACE = 5

local function drawPanel(x, y, w, h)
    love.graphics.setColor(0, 0, 0, Constants.HUD_PANEL_ALPHA)
    love.graphics.rectangle("fill", x, y, w, h, 6)
end

local function drawBar(x, y, label, value, ratio, color)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(label, x, y)
    love.graphics.printf(value, x, y, BAR_W, "right")

    local by = y + TEXT_H + GAP

    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", x, by, BAR_W, BAR_H)

    if ratio > 0 then
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", x + 1, by + 1, math.max(0, (BAR_W - 2) * ratio), BAR_H - 2)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, by, BAR_W, BAR_H)
end

function Hud.new()
    return setmetatable({}, Hud)
end

--- Draws all HUD elements in screen space.
--- @param player table Player entity with integrity, fuel, maxIntegrity, maxFuel, vx, vy.
--- @param planet table Home planet entity.
--- @param scrapCount number Current scrap count.
--- @param money number Current money.
--- @param warnings table List of {name=string, alpha=number} for active threats.
function Hud:draw(player, planet, scrapCount, money, warnings)
    self:drawShipStatus(player)
    self:drawResources(money, scrapCount)
    self:drawWarnings(warnings)
end

function Hud:drawShipStatus(player)
    local px = PAD
    local py = PAD

    local rowH = TEXT_H + GAP + BAR_H
    local contentH = rowH + ROW_SPACE + rowH + ROW_SPACE + TEXT_H
    local panelH = contentH + PAD * 2
    local panelW = BAR_W + PAD * 2

    drawPanel(px, py, panelW, panelH)

    local x = px + PAD
    local y = py + PAD

    local intRatio = player.integrity / player.maxIntegrity
    local intColor
    if intRatio > 0.6 then
        intColor = { 0.2, 0.8, 0.2 }
    elseif intRatio > 0.3 then
        intColor = { 0.8, 0.8, 0.2 }
    else
        intColor = { 0.8, 0.2, 0.2 }
    end
    drawBar(x, y, "INTEGRITY", math.floor(intRatio * 100) .. "%", intRatio, intColor)
    y = y + rowH + ROW_SPACE

    local fuelRatio = player.fuel / player.maxFuel
    local fuelText = string.format("%.2f / %.2f t", player.fuel, player.maxFuel)
    drawBar(x, y, "FUEL", fuelText, fuelRatio, { 0.2, 0.8, 0.8 })
    y = y + rowH + ROW_SPACE

    local speed = math.sqrt(player.vx * player.vx + player.vy * player.vy)
    local speedColor
    if speed > 1000 then
        speedColor = { 1, 0.2, 0.2 }
    elseif speed > 800 then
        speedColor = { 1, 0.6, 0.2 }
    elseif speed > 600 then
        speedColor = { 1, 1, 0.2 }
    else
        speedColor = { 1, 1, 1 }
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("SPEED", x, y)
    love.graphics.setColor(speedColor)
    love.graphics.printf(math.floor(speed) .. " u/s", x, y, BAR_W, "right")
end

function Hud:drawResources(money, scrapCount)
    local font = love.graphics.getFont()
    local cashStr = "$" .. money
    local scrapStr = tostring(scrapCount)

    local cashW = font:getWidth(cashStr)
    local scrapTotalW = font:getWidth(scrapStr) + 12 + 4
    local contentW = math.max(cashW, scrapTotalW)
    local panelW = contentW + PAD * 2 + 8
    local panelX = Constants.WINDOW_WIDTH - PAD - panelW
    local panelY = PAD

    local contentH = TEXT_H + ROW_SPACE + 1 + ROW_SPACE + TEXT_H
    local panelH = contentH + PAD * 2

    drawPanel(panelX, panelY, panelW, panelH)

    local x = panelX + PAD + 4
    local y = panelY + PAD

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(cashStr, x, y)
    y = y + TEXT_H + ROW_SPACE

    love.graphics.setColor(1, 1, 1, 0.25)
    love.graphics.rectangle("fill", x, y, panelW - PAD * 2 - 8, 1)
    y = y + 1 + ROW_SPACE

    love.graphics.setColor(Constants.SCRAP_COLOR)
    love.graphics.rectangle("fill", x, y + 2, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(" " .. scrapStr, x + 12, y)
end

function Hud:drawWarnings(warnings)
    if not warnings or #warnings == 0 then return end

    local y = Constants.WINDOW_HEIGHT / 2 - 80
    for _, w in ipairs(warnings) do
        love.graphics.setColor(1, 0.2, 0.2, w.alpha)
        love.graphics.printf("INCOMING ATTACK FROM " .. w.name, 0, y, Constants.WINDOW_WIDTH, "center")
        y = y + 20
    end
end

return Hud
