local Constants = require("src.constants")

local Player = {}
Player.__index = Player

--- Creates a new Player ship.
function Player.new()
    local self = setmetatable({}, Player)
    self.x = Constants.WINDOW_WIDTH / 2
    self.y = Constants.WINDOW_HEIGHT / 2 - 100
    self.radius = Constants.PLAYER_RADIUS
    self.speed = Constants.PLAYER_SPEED
    self.cooldown = 0
    return self
end

--- Updates player position and cooldown.
--- @param dt number Delta time in seconds.
function Player:update(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then dy = -1 end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then dy = 1 end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then dx = -1 end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then dx = 1 end

    if dx ~= 0 or dy ~= 0 then
        local len = math.sqrt(dx * dx + dy * dy)
        dx = dx / len
        dy = dy / len
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end

    self.x = math.max(self.radius, math.min(Constants.WINDOW_WIDTH - self.radius, self.x))
    self.y = math.max(self.radius, math.min(Constants.WINDOW_HEIGHT - self.radius, self.y))

    self.cooldown = math.max(0, self.cooldown - dt)
end

--- Draws the player as a triangle pointing toward the mouse.
function Player:draw()
    local mx, my = love.mouse.getPosition()
    local angle = math.atan2(my - self.y, mx - self.x)
    local r = self.radius

    local x1 = self.x + r * 1.5 * math.cos(angle)
    local y1 = self.y + r * 1.5 * math.sin(angle)
    local x2 = self.x + r * 0.6 * math.cos(angle + 2.5)
    local y2 = self.y + r * 0.6 * math.sin(angle + 2.5)
    local x3 = self.x + r * 0.6 * math.cos(angle - 2.5)
    local y3 = self.y + r * 0.6 * math.sin(angle - 2.5)

    love.graphics.setColor(Constants.PLAYER_COLOR)
    love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
end

--- Returns the angle from the player to the mouse cursor.
--- @return number
function Player:getShotAngle()
    local mx, my = love.mouse.getPosition()
    return math.atan2(my - self.y, mx - self.x)
end

--- Returns whether the player can shoot (cooldown expired).
--- @return boolean
function Player:canShoot()
    return self.cooldown <= 0
end

--- Resets the shoot cooldown.
function Player:resetCooldown()
    self.cooldown = Constants.BULLET_COOLDOWN
end

return Player
