local Constants = require("src.constants")

local FuelPickup = {}
FuelPickup.__index = FuelPickup

--- Creates a new FuelPickup at the given position.
--- @param x number
--- @param y number
function FuelPickup.new(x, y)
    local self = setmetatable({}, FuelPickup)
    self.x = x
    self.y = y
    self.vx = 0
    self.vy = 0
    self.radius = Constants.FUEL_PICKUP_RADIUS
    self.collected = false
    return self
end

--- Draws the fuel canister in world space.
--- @param camera table
function FuelPickup:draw(camera)
    love.graphics.setColor(1.0, 0.7, 0.1)
    love.graphics.rectangle("fill", self.x - self.radius, self.y - self.radius, self.radius * 2, self.radius * 2)
    love.graphics.setColor(1.0, 0.9, 0.4)
    love.graphics.rectangle("fill", self.x - self.radius * 0.5, self.y - self.radius * 0.5, self.radius, self.radius)
end

return FuelPickup
