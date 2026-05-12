local Constants = require("src.constants")

local Planet = {}
Planet.__index = Planet

--- Creates a new Planet (home base) at world center.
function Planet.new()
    local self = setmetatable({}, Planet)
    self.x = Constants.WORLD_WIDTH / 2
    self.y = Constants.WORLD_HEIGHT / 2
    self.radius = Constants.PLANET_RADIUS
    self.hp = Constants.PLANET_HP
    self.maxHp = Constants.PLANET_HP
    return self
end

--- Reduces planet HP. Clamped to 0.
--- @param amount number
function Planet:takeDamage(amount)
    self.hp = math.max(0, self.hp - amount)
end

--- Returns true if the planet is destroyed.
--- @return boolean
function Planet:isDestroyed()
    return self.hp <= 0
end

--- Draws the planet in world space.
--- @param camera table
function Planet:draw(camera)
    love.graphics.setColor(Constants.PLANET_COLOR)
    love.graphics.circle("fill", self.x, self.y, self.radius)

    love.graphics.setColor(0.3, 0.7, 0.9, 0.3)
    love.graphics.circle("fill", self.x, self.y, self.radius + 10)
end

return Planet
