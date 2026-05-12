local Constants = require("src.constants")

local Player = {}
Player.__index = Player

--- Creates a new Player ship.
function Player.new()
    local self = setmetatable({}, Player)
    self.x = Constants.WORLD_WIDTH / 2
    self.y = Constants.WORLD_HEIGHT / 2 - 80
    self.radius = Constants.PLAYER_RADIUS
    self.speed = Constants.PLAYER_SPEED
    self.cooldown = 0
    self.fuel = Constants.PLAYER_FUEL_MAX
    self.maxFuel = Constants.PLAYER_FUEL_MAX
    return self
end

--- Updates player position, cooldown, and fuel.
--- Triggers game over if fuel reaches 0.
--- @param dt number Delta time in seconds.
function Player:update(dt)
    local dx, dy = 0, 0
    local moving = false
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then dy = -1; moving = true end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then dy = 1; moving = true end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then dx = -1; moving = true end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then dx = 1; moving = true end

    if moving then
        local len = math.sqrt(dx * dx + dy * dy)
        dx = dx / len
        dy = dy / len
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
        self.fuel = math.max(0, self.fuel - Constants.PLAYER_FUEL_DRAIN * dt)
    end

    self.x = math.max(self.radius, math.min(Constants.WORLD_WIDTH - self.radius, self.x))
    self.y = math.max(self.radius, math.min(Constants.WORLD_HEIGHT - self.radius, self.y))

    self.cooldown = math.max(0, self.cooldown - dt)

    if self.fuel <= 0 then
        Game.stateManager:switchTo("gameover", { reason = "fuel" })
    end
end

--- Draws the player as a triangle pointing toward the mouse cursor in world space.
--- @param camera table Camera for mouse-to-world coordinate conversion.
function Player:draw(camera)
    local mx, my = love.mouse.getPosition()
    local wmx = mx + camera.x - Constants.WINDOW_WIDTH / 2
    local wmy = my + camera.y - Constants.WINDOW_HEIGHT / 2
    local angle = math.atan2(wmy - self.y, wmx - self.x)
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

--- Returns the angle from the player to the mouse cursor in world space.
--- @param camera table
--- @return number
function Player:getShotAngle(camera)
    local mx, my = love.mouse.getPosition()
    local wmx = mx + camera.x - Constants.WINDOW_WIDTH / 2
    local wmy = my + camera.y - Constants.WINDOW_HEIGHT / 2
    return math.atan2(wmy - self.y, wmx - self.x)
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
