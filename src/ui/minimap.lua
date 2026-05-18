local Constants = require("src.constants")

local Minimap = {}
Minimap.__index = Minimap

local MINIMAP_SIZE = 200
local MARGIN = 10

--- Creates a new Minimap overlay.
function Minimap.new()
    return setmetatable({}, Minimap)
end

--- Draws the minimap in screen space (bottom-right corner).
--- @param player table
--- @param homePlanet table
--- @param enemyPlanets table
--- @param enemies table
function Minimap:draw(player, homePlanet, enemyPlanets, enemies)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local mx = screenW - MINIMAP_SIZE - MARGIN
    local my = screenH - MINIMAP_SIZE - MARGIN

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", mx, my, MINIMAP_SIZE, MINIMAP_SIZE)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", mx, my, MINIMAP_SIZE, MINIMAP_SIZE)

    love.graphics.print("MAP", mx + 4, my + 2)

    local scale = MINIMAP_SIZE / Constants.WORLD_WIDTH

    local hx = mx + homePlanet.x * scale
    local hy = my + homePlanet.y * scale
    love.graphics.setColor(0.2, 0.4, 1.0)
    love.graphics.circle("fill", hx, hy, 4)

    for _, ep in ipairs(enemyPlanets) do
        local ex = mx + ep.x * scale
        local ey = my + ep.y * scale
        if ep.alive then
            love.graphics.setColor(1.0, 0.2, 0.2)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
        end
        love.graphics.circle("fill", ex, ey, 5)
    end

    local px = mx + player.x * scale
    local py = my + player.y * scale
    love.graphics.setColor(0.2, 1.0, 0.2)
    love.graphics.circle("fill", px, py, 3)

    love.graphics.setColor(1.0, 0.3, 0.3)
    for _, enemy in ipairs(enemies) do
        if enemy.alive then
            local ex = mx + enemy.x * scale
            local ey = my + enemy.y * scale
            love.graphics.circle("fill", ex, ey, 2)
        end
    end
end

return Minimap
