local Constants = require("src.constants")

local Player = {}
Player.__index = Player

--- Creates a new Player ship.
function Player.new()
    local self = setmetatable({}, Player)
    self.x = Constants.WORLD_WIDTH / 2
    self.y = Constants.WORLD_HEIGHT / 2 - 80
    self.radius = Constants.PLAYER_RADIUS
    self.vx = 0
    self.vy = 0
    self.angle = -math.pi / 2
    self.cooldown = 0
    self.fuel = Constants.PLAYER_FUEL_MAX
    self.maxFuel = Constants.PLAYER_FUEL_MAX
    return self
end

--- Updates player rotation, velocity, position, cooldown, and fuel.
--- Triggers game over if fuel reaches 0.
--- @param dt number Delta time in seconds.
function Player:update(dt)
    local thrusting = false
    local thrustForward = 0
    local rotation = 0

    if love.keyboard.isDown("a") then
        rotation = rotation - Constants.PLAYER_ROTATION_SPEED
        thrusting = true
    end
    if love.keyboard.isDown("d") then
        rotation = rotation + Constants.PLAYER_ROTATION_SPEED
        thrusting = true
    end

    if love.keyboard.isDown("w") then
        thrustForward = Constants.PLAYER_THRUST
        thrusting = true
    elseif love.keyboard.isDown("a") or love.keyboard.isDown("d") then
        thrustForward = Constants.PLAYER_SINGLE_THRUST
    end

    self.angle = self.angle + rotation * dt

    if thrustForward > 0 then
        self.vx = self.vx + math.cos(self.angle) * thrustForward * dt
        self.vy = self.vy + math.sin(self.angle) * thrustForward * dt
    end

    if love.keyboard.isDown("space") then
        local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
        if speed > 0 then
            self.vx = self.vx - (self.vx / speed) * Constants.PLAYER_BRAKE_THRUST * dt
            self.vy = self.vy - (self.vy / speed) * Constants.PLAYER_BRAKE_THRUST * dt
        end
        thrusting = true
    end

    local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
    if speed > Constants.PLAYER_MAX_SPEED then
        self.vx = (self.vx / speed) * Constants.PLAYER_MAX_SPEED
        self.vy = (self.vy / speed) * Constants.PLAYER_MAX_SPEED
    end

    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    if self.x < self.radius then
        self.x = self.radius
        self.vx = 0
    elseif self.x > Constants.WORLD_WIDTH - self.radius then
        self.x = Constants.WORLD_WIDTH - self.radius
        self.vx = 0
    end

    if self.y < self.radius then
        self.y = self.radius
        self.vy = 0
    elseif self.y > Constants.WORLD_HEIGHT - self.radius then
        self.y = Constants.WORLD_HEIGHT - self.radius
        self.vy = 0
    end

    self.cooldown = math.max(0, self.cooldown - dt)

    if thrusting then
        self.fuel = math.max(0, self.fuel - Constants.PLAYER_FUEL_DRAIN * dt)
    end

    if self.fuel <= 0 then
        Game.stateManager:switchTo("gameover", { reason = "fuel" })
    end
end

--- Draws the player as a triangle pointing in the ship's facing direction.
--- @param camera table
function Player:draw(camera)
    local r = self.radius
    local angle = self.angle
    local x1 = self.x + r * 1.5 * math.cos(angle)
    local y1 = self.y + r * 1.5 * math.sin(angle)
    local x2 = self.x + r * 0.6 * math.cos(angle + 2.5)
    local y2 = self.y + r * 0.6 * math.sin(angle + 2.5)
    local x3 = self.x + r * 0.6 * math.cos(angle - 2.5)
    local y3 = self.y + r * 0.6 * math.sin(angle - 2.5)

    love.graphics.setColor(Constants.PLAYER_COLOR)
    love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
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
