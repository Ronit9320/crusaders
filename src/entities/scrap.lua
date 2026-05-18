local Constants = require("src.constants")

local Scrap = {}
Scrap.__index = Scrap

--- Creates a new Scrap pickup at the given position.
--- @param x number
--- @param y number
function Scrap.new(x, y)
    local self = setmetatable({}, Scrap)
    self.x = x
    self.y = y
    self.vx = 0
    self.vy = 0
    self.radius = Constants.SCRAP_RADIUS
    self.collected = false
    return self
end

--- Draws the scrap in world space.
--- @param camera table
function Scrap:draw(camera)
    love.graphics.setColor(Constants.SCRAP_COLOR)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(0.6, 0.6, 1.0)
    love.graphics.circle("fill", self.x, self.y, self.radius * 0.5)
end

return Scrap
