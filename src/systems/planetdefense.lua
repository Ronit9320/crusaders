local Constants = require("src.constants")
local Bullet = require("src.entities.bullet")

local PlanetDefense = {}
PlanetDefense.__index = PlanetDefense

--- Creates a new PlanetDefense system.
function PlanetDefense.new()
    local self = setmetatable({}, PlanetDefense)
    self.level = 0
    self.cooldown = 0
    return self
end

--- Returns whether the defense system is active (purchased).
--- @return boolean
function PlanetDefense:isActive()
    return self.level > 0
end

--- Returns the defense radius based on current level.
--- @return number
function PlanetDefense:getRadius()
    if not self:isActive() then return 0 end
    return Constants.DEFENSE_RADIUS_BASE + (self.level - 1) * Constants.DEFENSE_RADIUS_PER_LEVEL
end

--- Returns the max level.
--- @return number
function PlanetDefense:getMaxLevel()
    return Constants.DEFENSE_MAX_LEVEL
end

--- Fires at the nearest enemy within radius if cooldown is ready.
--- @param dt number
--- @param enemies table
--- @param bullets table
--- @param planetX number
--- @param planetY number
function PlanetDefense:update(dt, enemies, bullets, planetX, planetY)
    if not self:isActive() then return end

    self.cooldown = math.max(0, self.cooldown - dt)
    if self.cooldown > 0 then return end

    local radius = self:getRadius()
    local nearest = nil
    local nearestDist = nil

    for _, enemy in ipairs(enemies) do
        if enemy.alive then
            local dx = enemy.x - planetX
            local dy = enemy.y - planetY
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= radius then
                if not nearest or dist < nearestDist then
                    nearest = enemy
                    nearestDist = dist
                end
            end
        end
    end

    if nearest then
        local angle = math.atan2(nearest.y - planetY, nearest.x - planetX)
        table.insert(bullets, Bullet.new(planetX, planetY, angle, Constants.DEFENSE_BULLET_COLOR, Constants.DEFENSE_BULLET_SPEED))
        self.cooldown = Constants.DEFENSE_FIRE_RATE
    end
end

--- Draws the defense radius circle around the planet.
--- @param planetX number
--- @param planetY number
--- @param camera table
function PlanetDefense:draw(planetX, planetY, camera)
    if not self:isActive() then return end

    local radius = self:getRadius()
    love.graphics.setColor(Constants.DEFENSE_BULLET_COLOR[1], Constants.DEFENSE_BULLET_COLOR[2], Constants.DEFENSE_BULLET_COLOR[3], 0.15)
    love.graphics.circle("fill", planetX, planetY, radius)
    love.graphics.setColor(Constants.DEFENSE_BULLET_COLOR[1], Constants.DEFENSE_BULLET_COLOR[2], Constants.DEFENSE_BULLET_COLOR[3], 0.4)
    love.graphics.circle("line", planetX, planetY, radius)
end

return PlanetDefense
