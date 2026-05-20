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
    self.integrity = Constants.SHIP_INTEGRITY_MAX
    self.maxIntegrity = Constants.SHIP_INTEGRITY_MAX
    self.fuel = Constants.SHIP_FUEL_MAX
    self.maxFuel = Constants.SHIP_FUEL_MAX
    self.thrust = Constants.PLAYER_THRUST
    self.singleThrust = Constants.PLAYER_SINGLE_THRUST
    self.bulletDamage = 1
    self.bulletCooldown = Constants.BULLET_COOLDOWN
    self.bulletSpeed = Constants.BULLET_SPEED
    return self
end

--- Updates player rotation, velocity, position, cooldown, integrity, and fuel.
--- Triggers game over if integrity reaches 0.
--- @param dt number Delta time in seconds.
function Player:update(dt)
    local hasFuel = self.fuel > 0
    local enginesActive = 0
    local thrustForward = 0
    local rotation = 0
    local speed

    if love.keyboard.isDown("a") then
        rotation = rotation - 1
        enginesActive = enginesActive + 1
    end
    if love.keyboard.isDown("d") then
        rotation = rotation + 1
        enginesActive = enginesActive + 1
    end
    if love.keyboard.isDown("w") then
        enginesActive = enginesActive + 2
    end
    speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
    local t = math.min(speed / Constants.PLAYER_MAX_SPEED, 1)
    local rotSpeed = Constants.PLAYER_ROTATION_SPEED * (1 - t) + Constants.PLAYER_ROTATION_MIN_SPEED * t

    self.angle = self.angle + rotation * rotSpeed * dt

    if hasFuel then
        if love.keyboard.isDown("w") then
            thrustForward = self.thrust
        elseif love.keyboard.isDown("a") or love.keyboard.isDown("d") then
            thrustForward = self.singleThrust
        end

        if thrustForward > 0 then
            self.vx = self.vx + math.cos(self.angle) * thrustForward * dt
            self.vy = self.vy + math.sin(self.angle) * thrustForward * dt
        end
    end

    speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
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

    if enginesActive > 0 then
        self.fuel = math.max(0, self.fuel - Constants.ENGINE_FUEL_DRAIN * enginesActive * dt)
    end

    do
        speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
        local loss = 0
        if speed > 1000 then
            loss = 30 * dt
        elseif speed > 800 then
            loss = 4 * dt
        elseif speed > 600 then
            loss = 1 * dt
        end
        if loss > 0 then
            self.integrity = math.max(0, self.integrity - loss)
        end
    end

    if self.integrity <= 0 then
        Game.stateManager:switchTo("gameover", { reason = "integrity" })
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
    self.cooldown = self.bulletCooldown
end

--- Increases max fuel capacity and refills.
function Player:upgradeFuel()
    self.maxFuel = self.maxFuel + Constants.UPGRADE_FUEL_AMOUNT
    self.fuel = self.maxFuel
end

--- Increases max hull integrity.
function Player:upgradeIntegrity()
    self.maxIntegrity = self.maxIntegrity + Constants.UPGRADE_INTEGRITY_AMOUNT
    self.integrity = math.min(self.maxIntegrity, self.integrity + Constants.UPGRADE_INTEGRITY_AMOUNT)
end

--- Increases engine thrust power.
function Player:upgradeThrust()
    self.thrust = self.thrust + Constants.UPGRADE_THRUST_AMOUNT
    self.singleThrust = self.singleThrust + Constants.UPGRADE_THRUST_AMOUNT
end

--- Recalculates weapon stats based on upgrade level.
--- @param level number 0-3
function Player:upgradeWeapons(level)
    self.bulletDamage = 1
    self.bulletCooldown = Constants.BULLET_COOLDOWN
    self.bulletSpeed = Constants.BULLET_SPEED
    if level >= 1 then self.bulletDamage = 2 end
    if level >= 2 then self.bulletCooldown = Constants.BULLET_COOLDOWN * 0.7 end
    if level >= 3 then self.bulletSpeed = Constants.BULLET_SPEED * 1.2 end
end

return Player
