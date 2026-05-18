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

--- Returns max HP for the given difficulty.
--- @param difficulty number
--- @return number
local function getMaxHp(difficulty)
    if difficulty >= 1.5 then return Constants.COLONY_HP_HARD end
    if difficulty >= 1.0 then return Constants.COLONY_HP_MEDIUM end
    return Constants.COLONY_HP_EASY
end

--- Creates a new destructible enemy planet at the given world position.
--- @param x number
--- @param y number
--- @param spriteIndex number 1 or 2
--- @param difficulty number Spawn rate escalation multiplier and HP scaling.
--- @param colonyName string Display name for warnings.
function EnemyPlanet.new(x, y, spriteIndex, difficulty, colonyName)
    local self = setmetatable({}, EnemyPlanet)
    self.x = x
    self.y = y
    self.radius = Constants.ENEMY_PLANET_RADIUS
    self.gravityStrength = self.radius * Constants.GRAVITY_SCALE_FACTOR
    self.difficulty = difficulty or 1.0
    self.name = colonyName or "COLONY"
    self.alive = true
    self.maxHp = getMaxHp(self.difficulty)
    self.hp = self.maxHp
    self.spawnTimer = love.math.random() * Constants.ENEMY_SPAWN_INTERVAL_START
    self.elapsedTime = 0
    self.waveTimer = love.math.random() * Constants.ESCALATION_WAVE_INTERVAL
    self.waveInterval = Constants.ESCALATION_WAVE_INTERVAL
    self.warningActive = false
    self.warningAlpha = 0
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

--- Returns the number of enemies in the next wave based on global elapsed time.
--- @param globalElapsed number
--- @return number
function EnemyPlanet:getWaveSize(globalElapsed)
    local growthSteps = math.floor(globalElapsed / Constants.ESCALATION_GROWTH_TIME)
    local baseSize = math.min(Constants.ESCALATION_WAVE_MAX, Constants.ESCALATION_WAVE_SIZE + growthSteps * Constants.ESCALATION_WAVE_GROWTH)
    return math.max(1, math.floor(baseSize * self.difficulty + 0.5))
end

--- Applies damage. Sets alive = false when HP reaches 0.
--- @param amount number
function EnemyPlanet:takeDamage(amount)
    if not self.alive then return end
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self.hp = 0
        self.alive = false
    end
end

--- Updates spawn timer, wave timer, and animation frame. Skips when dead.
--- @param dt number
--- @param enemies table List to insert spawned enemies into.
--- @param globalElapsed number Game-wide elapsed time for wave scaling.
function EnemyPlanet:update(dt, enemies, globalElapsed)
    self.elapsedTime = self.elapsedTime + dt
    self.frameTimer = self.frameTimer + dt
    if self.frameTimer >= Constants.ENEMY_PLANET_FRAME_DURATION then
        self.frameTimer = self.frameTimer - Constants.ENEMY_PLANET_FRAME_DURATION
        self.frame = self.frame + 1
        if self.frame > Constants.ENEMY_PLANET_FRAME_COUNT then
            self.frame = 1
        end
    end

    self.warningActive = false
    self.warningAlpha = 0

    if not self.alive then return end

    local spawnInterval = self:getSpawnInterval()
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer >= spawnInterval then
        self.spawnTimer = 0
        local enemyType = love.math.random() < 0.3 and "bomber" or "fighter"
        table.insert(enemies, Enemy.new(enemyType, self.x, self.y))
    end

    self.waveTimer = self.waveTimer + dt
    local timeToWave = self.waveInterval - self.waveTimer
    if timeToWave <= 5 and timeToWave > 0 then
        self.warningActive = true
        if timeToWave > 4 then
            self.warningAlpha = (5 - timeToWave) / 1
        elseif timeToWave > 1 then
            self.warningAlpha = 1
        else
            self.warningAlpha = timeToWave / 1
        end
    end

    if self.waveTimer >= self.waveInterval then
        self.waveTimer = 0
        self.warningActive = false
        self.warningAlpha = 0
        local waveSize = self:getWaveSize(globalElapsed)
        local fighterCount = math.floor(waveSize * 0.6 + 0.5)
        local bomberCount = waveSize - fighterCount
        for _ = 1, fighterCount do
            table.insert(enemies, Enemy.new("fighter", self.x, self.y))
        end
        for _ = 1, bomberCount do
            table.insert(enemies, Enemy.new("bomber", self.x, self.y))
        end
    end
end

--- Draws the enemy planet in world space. Dead planets get a dark overlay.
--- @param camera table
function EnemyPlanet:draw(camera)
    love.graphics.setColor(1, 1, 1, 1)
    local scale = self.radius * 2 / Constants.ENEMY_PLANET_FRAME_WIDTH
    love.graphics.draw(spritesheets[self.spriteIndex], quads[self.spriteIndex][self.frame],
        self.x, self.y, 0, scale, scale,
        Constants.ENEMY_PLANET_FRAME_WIDTH / 2, Constants.ENEMY_PLANET_FRAME_HEIGHT / 2)

    if not self.alive then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.circle("fill", self.x, self.y, self.radius)
        return
    end

    local barW = self.radius * 2.5
    local barH = 4
    local barX = self.x - barW / 2
    local barY = self.y - self.radius - 10

    love.graphics.setColor(0.3, 0.1, 0.1)
    love.graphics.rectangle("fill", barX, barY, barW, barH)

    local ratio = self.hp / self.maxHp
    local r, g
    if ratio > 0.5 then
        r = 1 - (ratio - 0.5) * 2
        g = 1
    else
        r = 1
        g = ratio * 2
    end
    love.graphics.setColor(r, g, 0.1)
    love.graphics.rectangle("fill", barX, barY, barW * ratio, barH)
end

return EnemyPlanet
