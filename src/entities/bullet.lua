local Constants = require("src.constants")

local Bullet = {}
Bullet.__index = Bullet

--- Creates a new Bullet.
--- @param x number
--- @param y number
--- @param angle number Direction in radians.
function Bullet.new(x, y, angle)
    local self = setmetatable({}, Bullet)
    self.x = x
    self.y = y
    self.radius = Constants.BULLET_RADIUS
    self.speed = Constants.BULLET_SPEED
    self.vx = math.cos(angle) * self.speed
    self.vy = math.sin(angle) * self.speed
    self.alive = true
    return self
end

--- Moves the bullet. Marks dead if off-screen.
--- @param dt number
function Bullet:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    if self.x < -50 or self.x > Constants.WINDOW_WIDTH + 50
        or self.y < -50 or self.y > Constants.WINDOW_HEIGHT + 50 then
        self.alive = false
    end
end

function Bullet:draw()
    love.graphics.setColor(Constants.BULLET_COLOR)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

return Bullet
