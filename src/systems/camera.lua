local Constants = require("src.constants")

local Camera = {}
Camera.__index = Camera

--- Creates a new Camera centered on the world.
function Camera.new()
    local self = setmetatable({}, Camera)
    self.x = Constants.WORLD_WIDTH / 2
    self.y = Constants.WORLD_HEIGHT / 2
    return self
end

--- Smoothly follows a target position.
--- @param target table Must have x and y fields.
--- @param dt number
function Camera:follow(target, dt)
    local smooth = 5
    self.x = self.x + (target.x - self.x) * smooth * dt
    self.y = self.y + (target.y - self.y) * smooth * dt
end

--- Pushes the current transform and translates to camera position.
function Camera:apply()
    love.graphics.push()
    love.graphics.translate(
        math.floor(-self.x + Constants.WINDOW_WIDTH / 2),
        math.floor(-self.y + Constants.WINDOW_HEIGHT / 2)
    )
end

--- Pops the camera transform.
function Camera:unapply()
    love.graphics.pop()
end

return Camera
