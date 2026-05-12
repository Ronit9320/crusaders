local Constants = require("src.constants")

local Enemy = {}
Enemy.__index = Enemy

--- Creates a new Enemy of the given type.
--- @param type string "basic" or "fast"
function Enemy.new(type)
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

    local edge = love.math.random(4)
    if edge == 1 then
        self.x = love.math.random(0, Constants.WINDOW_WIDTH)
        self.y = -self.radius
    elseif edge == 2 then
        self.x = love.math.random(0, Constants.WINDOW_WIDTH)
        self.y = Constants.WINDOW_HEIGHT + self.radius
    elseif edge == 3 then
        self.x = -self.radius
        self.y = love.math.random(0, Constants.WINDOW_HEIGHT)
    else
        self.x = Constants.WINDOW_WIDTH + self.radius
        self.y = love.math.random(0, Constants.WINDOW_HEIGHT)
    end

    return self
end

--- Moves the enemy toward the planet center.
--- @param dt number
function Enemy:update(dt)
    local planetX = Constants.WINDOW_WIDTH / 2
    local planetY = Constants.WINDOW_HEIGHT / 2
    local dx = planetX - self.x
    local dy = planetY - self.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > 0 then
        self.x = self.x + (dx / dist) * self.speed * dt
        self.y = self.y + (dy / dist) * self.speed * dt
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

function Enemy:draw()
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
