local Constants = require("src.constants")

local Bullet = {}
Bullet.__index = Bullet

--- Creates a new Bullet.
--- @param x number
--- @param y number
--- @param angle number Direction in radians.
--- @param color table|nil Optional color override.
--- @param speed number|nil Optional speed override.
function Bullet.new(x, y, angle, color, speed)
    local self = setmetatable({}, Bullet)
    self.x = x
    self.y = y
    self.radius = Constants.BULLET_RADIUS
    self.speed = speed or Constants.BULLET_SPEED
    self.vx = math.cos(angle) * self.speed
    self.vy = math.sin(angle) * self.speed
    self.alive = true
    self.color = color or Constants.BULLET_COLOR
    return self
end

--- Moves the bullet. Marks dead if outside world bounds.
--- @param dt number
function Bullet:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    if self.x < -50 or self.x > Constants.WORLD_WIDTH + 50
        or self.y < -50 or self.y > Constants.WORLD_HEIGHT + 50 then
        self.alive = false
    end
end

--- Draws the bullet in world space.
--- @param camera table
function Bullet:draw(camera)
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

return Bullet
