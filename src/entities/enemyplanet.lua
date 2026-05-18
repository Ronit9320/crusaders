local Constants = require("src.constants")
local Enemy = require("src.entities.enemy")

local spritesheets = {
    love.graphics.newImage("assets/planet/enemy_planet1.png"),
    love.graphics.newImage("assets/planet/enemy_planet2.png"),
}

local quads = {}
for si = 1, 2 do
    quads[si] = {}
    for i = 0, Constants.ENEMY_PLANET_FRAME_COUNT - 1 do
        quads[si][i + 1] = love.graphics.newQuad(
            i * Constants.ENEMY_PLANET_FRAME_WIDTH, 0,
            Constants.ENEMY_PLANET_FRAME_WIDTH, Constants.ENEMY_PLANET_FRAME_HEIGHT,
            spritesheets[si]:getDimensions()
        )
    end
end

local EnemyPlanet = {}
EnemyPlanet.__index = EnemyPlanet

--- Creates a new indestructible enemy planet at the given world position.
--- @param x number
--- @param y number
--- @param spriteIndex number 1 or 2
--- @param difficulty number Spawn rate escalation multiplier.
function EnemyPlanet.new(x, y, spriteIndex, difficulty)
    local self = setmetatable({}, EnemyPlanet)
    self.x = x
    self.y = y
    self.radius = Constants.ENEMY_PLANET_RADIUS
    self.gravityStrength = self.radius * Constants.GRAVITY_SCALE_FACTOR
    self.difficulty = difficulty or 1.0
    self.spawnTimer = love.math.random() * Constants.ENEMY_SPAWN_INTERVAL_START
    self.elapsedTime = 0
    self.spriteIndex = spriteIndex or 1
    self.frame = 1
    self.frameTimer = 0
    return self
end

--- Returns the current spawn interval based on elapsed time and difficulty.
--- @return number
function EnemyPlanet:getSpawnInterval()
    local escalations = math.floor(self.elapsedTime / Constants.ENEMY_SPAWN_ESCALATION_TIME)
    local step = Constants.ENEMY_SPAWN_ESCALATION_STEP * self.difficulty
    return math.max(Constants.ENEMY_SPAWN_INTERVAL_MIN, Constants.ENEMY_SPAWN_INTERVAL_START - escalations * step)
end

--- Updates the spawn timer and animation frame.
--- @param dt number
--- @param enemies table List to insert spawned enemies into.
function EnemyPlanet:update(dt, enemies)
    self.elapsedTime = self.elapsedTime + dt
    self.frameTimer = self.frameTimer + dt
    if self.frameTimer >= Constants.ENEMY_PLANET_FRAME_DURATION then
        self.frameTimer = self.frameTimer - Constants.ENEMY_PLANET_FRAME_DURATION
        self.frame = self.frame + 1
        if self.frame > Constants.ENEMY_PLANET_FRAME_COUNT then
            self.frame = 1
        end
    end

    local spawnInterval = self:getSpawnInterval()
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer >= spawnInterval then
        self.spawnTimer = 0
        local enemyType = love.math.random() < 0.3 and "bomber" or "fighter"
        table.insert(enemies, Enemy.new(enemyType, self.x, self.y))
    end
end

--- Draws the enemy planet in world space.
--- @param camera table
function EnemyPlanet:draw(camera)
    love.graphics.setColor(1, 1, 1, 1)
    local scale = self.radius * 2 / Constants.ENEMY_PLANET_FRAME_WIDTH
    love.graphics.draw(spritesheets[self.spriteIndex], quads[self.spriteIndex][self.frame],
        self.x, self.y, 0, scale, scale,
        Constants.ENEMY_PLANET_FRAME_WIDTH / 2, Constants.ENEMY_PLANET_FRAME_HEIGHT / 2)
end

return EnemyPlanet
