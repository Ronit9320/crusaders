local Constants = require("src.constants")

local Resource = {}
Resource.__index = Resource

--- Creates a new Resource pickup at the given position.
--- @param x number
--- @param y number
function Resource.new(x, y)
    local self = setmetatable({}, Resource)
    self.x = x
    self.y = y
    self.radius = Constants.RESOURCE_RADIUS
    self.collected = false
    return self
end

function Resource:draw()
    love.graphics.setColor(Constants.RESOURCE_COLOR)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(0.6, 0.6, 1.0)
    love.graphics.circle("fill", self.x, self.y, self.radius * 0.5)
end

return Resource
