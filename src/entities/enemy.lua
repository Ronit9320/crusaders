local Constants = require("src.constants")
local Bullet = require("src.entities.bullet")

local Enemy = {}
Enemy.__index = Enemy

--- Creates a new Enemy of the given type.
--- @param type string "fighter" or "bomber"
--- @param x number Spawn x.
--- @param y number Spawn y.
function Enemy.new(type, x, y)
    local self = setmetatable({}, Enemy)
    self.type = type
    self.alive = true
    self.x = x
    self.y = y
    self.vx = 0
    self.vy = 0

    if type == "fighter" then
        self.radius = Constants.FIGHTER_RADIUS
        self.speed = Constants.FIGHTER_SPEED
        self.hp = Constants.FIGHTER_HP
        self.damage = Constants.FIGHTER_PLANET_DAMAGE
        self.color = Constants.FIGHTER_COLOR
        self.scrapDrop = Constants.FIGHTER_SCRAP_DROP
        self.fireTimer = 0
        self.fireRate = Constants.FIGHTER_FIRE_RATE
    else
        self.radius = Constants.BOMBER_RADIUS
        self.speed = Constants.BOMBER_SPEED
        self.hp = Constants.BOMBER_HP
        self.damage = Constants.BOMBER_PLANET_DAMAGE
        self.color = Constants.BOMBER_COLOR
        self.scrapDrop = Constants.BOMBER_SCRAP_DROP
    end

    return self
end

--- Moves toward target and fires at the player.
--- @param dt number
--- @param playerX number
--- @param playerY number
--- @param enemyBullets table|nil List to insert fighter bullets into.
function Enemy:update(dt, playerX, playerY, enemyBullets)
    if self.type == "fighter" then
        local dx = playerX - self.x
        local dy = playerY - self.y
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist > 0 then
            local nx = dx / dist
            local ny = dy / dist

            if dist > Constants.FIGHTER_ENGAGE_RANGE then
                self.vx = self.vx + nx * self.speed * 3 * dt
                self.vy = self.vy + ny * self.speed * 3 * dt
            elseif dist > Constants.FIGHTER_TOO_CLOSE then
                local tx = -ny
                local ty = nx
                self.vx = self.vx + tx * self.speed * 3 * dt
                self.vy = self.vy + ty * self.speed * 3 * dt
            else
                self.vx = self.vx - nx * self.speed * 3 * dt
                self.vy = self.vy - ny * self.speed * 3 * dt
            end
        end
    else
        local targetX = Constants.WORLD_WIDTH / 2
        local targetY = Constants.WORLD_HEIGHT / 2
        local dx = targetX - self.x
        local dy = targetY - self.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > 0 then
            local nx = dx / dist
            local ny = dy / dist
            self.vx = self.vx + nx * self.speed * 3 * dt
            self.vy = self.vy + ny * self.speed * 3 * dt
        end
    end

    local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
    if speed > self.speed then
        self.vx = (self.vx / speed) * self.speed
        self.vy = (self.vy / speed) * self.speed
    end

    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    if self.type == "fighter" and enemyBullets then
        local dx = playerX - self.x
        local dy = playerY - self.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist <= Constants.FIGHTER_ENGAGE_RANGE then
            self.fireTimer = self.fireTimer + dt
            if self.fireTimer >= self.fireRate then
                self.fireTimer = 0
                local angle = math.atan2(playerY - self.y, playerX - self.x)
                table.insert(enemyBullets, Bullet.new(self.x, self.y, angle, Constants.FIGHTER_BULLET_COLOR, Constants.FIGHTER_BULLET_SPEED))
            end
        end
    end
end

--- Applies damage. Marks dead if HP reaches 0.
--- @param amount number
function Enemy:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self.alive = false
    end
end

--- Draws the enemy in world space.
--- @param camera table
function Enemy:draw(camera)
    love.graphics.setColor(self.color)
    if self.type == "fighter" then
        local r = self.radius
        love.graphics.polygon("fill",
            self.x, self.y - r,
            self.x - r * 0.866, self.y + r * 0.5,
            self.x + r * 0.866, self.y + r * 0.5
        )
    else
        love.graphics.circle("fill", self.x, self.y, self.radius)
    end
end

return Enemy
