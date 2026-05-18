local Constants = require("src.constants")

local Enemy = {}
Enemy.__index = Enemy

--- Creates a new Enemy of the given type.
--- @param type string "basic" or "fast"
--- @param spawnX number|nil Optional spawn x. Random world edge if omitted.
--- @param spawnY number|nil Optional spawn y.
function Enemy.new(type, spawnX, spawnY)
    local self = setmetatable({}, Enemy)
    self.type = type
    self.alive = true

    if type == "basic" then
        self.radius = Constants.BASIC_ENEMY_RADIUS
        self.speed = Constants.BASIC_ENEMY_SPEED
        self.hp = Constants.BASIC_ENEMY_HP
        self.damage = Constants.BASIC_ENEMY_DAMAGE
        self.color = Constants.BASIC_ENEMY_COLOR
    else
        self.radius = Constants.FAST_ENEMY_RADIUS
        self.speed = Constants.FAST_ENEMY_SPEED
        self.hp = Constants.FAST_ENEMY_HP
        self.damage = Constants.FAST_ENEMY_DAMAGE
        self.color = Constants.FAST_ENEMY_COLOR
    end

    if spawnX and spawnY then
        self.x = spawnX
        self.y = spawnY
    else
        local edge = love.math.random(4)
        if edge == 1 then
            self.x = love.math.random(0, Constants.WORLD_WIDTH)
            self.y = -self.radius
        elseif edge == 2 then
            self.x = love.math.random(0, Constants.WORLD_WIDTH)
            self.y = Constants.WORLD_HEIGHT + self.radius
        elseif edge == 3 then
            self.x = -self.radius
            self.y = love.math.random(0, Constants.WORLD_HEIGHT)
        else
            self.x = Constants.WORLD_WIDTH + self.radius
            self.y = love.math.random(0, Constants.WORLD_HEIGHT)
        end
    end

    self.vx = 0
    self.vy = 0

    return self
end

--- Moves the enemy toward the home planet at world center.
--- @param dt number
function Enemy:update(dt)
    local planetX = Constants.WORLD_WIDTH / 2
    local planetY = Constants.WORLD_HEIGHT / 2
    local dx = planetX - self.x
    local dy = planetY - self.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > 0 then
        local nx = dx / dist
        local ny = dy / dist
        self.vx = self.vx + nx * self.speed * 3 * dt
        self.vy = self.vy + ny * self.speed * 3 * dt
    end

    local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
    if speed > self.speed then
        self.vx = (self.vx / speed) * self.speed
        self.vy = (self.vy / speed) * self.speed
    end

    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
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
    if self.type == "basic" then
        love.graphics.rectangle("fill", self.x - self.radius, self.y - self.radius, self.radius * 2, self.radius * 2)
    else
        local r = self.radius
        love.graphics.polygon("fill",
            self.x, self.y - r,
            self.x - r * 0.866, self.y + r * 0.5,
            self.x + r * 0.866, self.y + r * 0.5
        )
    end
end

return Enemy
