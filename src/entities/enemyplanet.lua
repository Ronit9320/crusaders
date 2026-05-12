local Constants = require("src.constants")
local Enemy = require("src.entities.enemy")

local EnemyPlanet = {}
EnemyPlanet.__index = EnemyPlanet

--- Creates a new indestructible enemy planet at the given world position.
--- @param x number
--- @param y number
function EnemyPlanet.new(x, y)
    local self = setmetatable({}, EnemyPlanet)
    self.x = x
    self.y = y
    self.radius = Constants.ENEMY_PLANET_RADIUS
    self.spawnTimer = love.math.random() * Constants.ENEMY_PLANET_SPAWN_INTERVAL
    return self
end

--- Updates the spawn timer and spawns an enemy when ready.
--- @param dt number
--- @param enemies table List to insert spawned enemies into.
function EnemyPlanet:update(dt, enemies)
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer >= Constants.ENEMY_PLANET_SPAWN_INTERVAL then
        self.spawnTimer = 0
        local type = love.math.random() < 0.3 and "fast" or "basic"
        table.insert(enemies, Enemy.new(type, self.x, self.y))
    end
end

--- Draws the enemy planet in world space.
--- @param camera table
function EnemyPlanet:draw(camera)
    love.graphics.setColor(Constants.ENEMY_PLANET_COLOR)
    love.graphics.circle("fill", self.x, self.y, self.radius)

    love.graphics.setColor(0.7, 0.2, 0.2, 0.3)
    love.graphics.circle("fill", self.x, self.y, self.radius + 8)
end

return EnemyPlanet
