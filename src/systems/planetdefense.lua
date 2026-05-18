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

--- Returns the fire rate for the current level.
--- @return number
function PlanetDefense:getFireRate()
    if self.level >= 3 then return Constants.DEFENSE_FIRE_RATE_L3 end
    if self.level >= 2 then return Constants.DEFENSE_FIRE_RATE_L2 end
    return Constants.DEFENSE_FIRE_RATE
end

--- Returns the max level.
--- @return number
function PlanetDefense:getMaxLevel()
    return Constants.DEFENSE_MAX_LEVEL
end

--- Fires at every enemy in range simultaneously.
--- @param dt number
--- @param enemies table
--- @param bullets table
--- @param planetX number
--- @param planetY number
function PlanetDefense:update(dt, enemies, bullets, planetX, planetY)
    if not self:isActive() then return end

    self.cooldown = math.max(0, self.cooldown - dt)
    if self.cooldown > 0 then return end

    self.cooldown = self:getFireRate()
    local radius = self:getRadius()

    for _, enemy in ipairs(enemies) do
        if enemy.alive then
            local dx = enemy.x - planetX
            local dy = enemy.y - planetY
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= radius then
                local baseAngle = math.atan2(dy, dx)
                if self.level >= 3 then
                    table.insert(bullets, Bullet.new(planetX, planetY, baseAngle - Constants.DEFENSE_SPREAD_ANGLE, Constants.DEFENSE_BULLET_COLOR, Constants.DEFENSE_BULLET_SPEED))
                    table.insert(bullets, Bullet.new(planetX, planetY, baseAngle, Constants.DEFENSE_BULLET_COLOR, Constants.DEFENSE_BULLET_SPEED))
                    table.insert(bullets, Bullet.new(planetX, planetY, baseAngle + Constants.DEFENSE_SPREAD_ANGLE, Constants.DEFENSE_BULLET_COLOR, Constants.DEFENSE_BULLET_SPEED))
                else
                    table.insert(bullets, Bullet.new(planetX, planetY, baseAngle, Constants.DEFENSE_BULLET_COLOR, Constants.DEFENSE_BULLET_SPEED))
                end
            end
        end
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
