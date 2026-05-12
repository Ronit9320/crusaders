local Constants = require("src.constants")
local Player = require("src.entities.player")
local Bullet = require("src.entities.bullet")
local Enemy = require("src.entities.enemy")
local Resource = require("src.entities.resource")
local Planet = require("src.entities.planet")

local Gameplay = {}
Gameplay.__index = Gameplay

function Gameplay:enter()
    self.planet = Planet.new()
    self.player = Player.new()
    self.bullets = {}
    self.enemies = {}
    self.resources = {}

    self.wave = 1
    self.enemiesSpawned = 0
    self.spawnTimer = 0
    self.waveDelayTimer = 0
    self.waveActive = false
    self.betweenWaves = false
    self.resourceCount = 0

    self:startWave()
    return self
end

function Gameplay:exit()
end

function Gameplay:startWave()
    self.enemiesRemaining = Constants.WAVE_BASE_COUNT + (self.wave - 1) * Constants.WAVE_INCREMENT
    self.enemiesSpawned = 0
    self.spawnTimer = 0
    self.waveActive = true
    self.betweenWaves = false
end

function Gameplay:update(dt)
    if self.planet:isDestroyed() then
        Game.stateManager:switchTo("gameover", { wave = self.wave })
        return
    end

    self.player:update(dt)

    if love.mouse.isDown(1) and self.player:canShoot() then
        local angle = self.player:getShotAngle()
        table.insert(self.bullets, Bullet.new(self.player.x, self.player.y, angle))
        self.player:resetCooldown()
    end

    for _, bullet in ipairs(self.bullets) do
        bullet:update(dt)
    end

    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt)
    end

    for _, bullet in ipairs(self.bullets) do
        if bullet.alive then
            for _, enemy in ipairs(self.enemies) do
                if enemy.alive then
                    local dx = bullet.x - enemy.x
                    local dy = bullet.y - enemy.y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist < bullet.radius + enemy.radius then
                        enemy:takeDamage(1)
                        bullet.alive = false
                        if not enemy.alive then
                            table.insert(self.resources, Resource.new(enemy.x, enemy.y))
                        end
                        break
                    end
                end
            end
        end
    end

    for _, enemy in ipairs(self.enemies) do
        if enemy.alive then
            local dx = enemy.x - self.planet.x
            local dy = enemy.y - self.planet.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < enemy.radius + self.planet.radius then
                self.planet:takeDamage(enemy.damage)
                enemy.alive = false
            end
        end
    end

    for _, res in ipairs(self.resources) do
        if not res.collected then
            local dx = res.x - self.player.x
            local dy = res.y - self.player.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < res.radius + self.player.radius then
                res.collected = true
                self.resourceCount = self.resourceCount + 1
            end
        end
    end

    self:cleanup()

    if self.waveActive then
        if self.enemiesSpawned < self.enemiesRemaining then
            self.spawnTimer = self.spawnTimer + dt
            if self.spawnTimer >= Constants.SPAWN_INTERVAL then
                self.spawnTimer = 0
                self:spawnEnemy()
                self.enemiesSpawned = self.enemiesSpawned + 1
            end
        elseif #self.enemies == 0 then
            self.waveActive = false
            self.betweenWaves = true
            self.waveDelayTimer = 0
        end
    elseif self.betweenWaves then
        self.waveDelayTimer = self.waveDelayTimer + dt
        if self.waveDelayTimer >= Constants.WAVE_DELAY then
            self.wave = self.wave + 1
            self:startWave()
        end
    end
end

function Gameplay:spawnEnemy()
    local type = love.math.random() < 0.3 and "fast" or "basic"
    table.insert(self.enemies, Enemy.new(type))
end

function Gameplay:cleanup()
    local function keepAlive(t)
        local nextIndex = 1
        for _, item in ipairs(t) do
            if item.alive ~= false and (item.collected == nil or not item.collected) then
                t[nextIndex] = item
                nextIndex = nextIndex + 1
            end
        end
        for i = nextIndex, #t do
            t[i] = nil
        end
    end

    keepAlive(self.bullets)
    keepAlive(self.enemies)
    keepAlive(self.resources)
end

function Gameplay:draw()
    self.planet:draw()

    for _, res in ipairs(self.resources) do
        res:draw()
    end

    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end

    for _, bullet in ipairs(self.bullets) do
        bullet:draw()
    end

    self.player:draw()
    self:drawUI()
end

function Gameplay:drawUI()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Planet HP: " .. self.planet.hp .. "/" .. self.planet.maxHp, 10, 10)
    love.graphics.print("Resources: " .. self.resourceCount, 10, 30)
    love.graphics.print("Wave: " .. self.wave, 10, 50)

    if self.betweenWaves then
        local remaining = math.ceil(Constants.WAVE_DELAY - self.waveDelayTimer)
        love.graphics.print("Next wave in: " .. remaining, 10, 70)
    end
end

function Gameplay:keypressed(key)
end

return Gameplay
