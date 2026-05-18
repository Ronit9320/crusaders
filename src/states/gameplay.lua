local Constants = require("src.constants")
local Camera = require("src.systems.camera")
local Player = require("src.entities.player")
local Bullet = require("src.entities.bullet")
local Enemy = require("src.entities.enemy")
local Scrap = require("src.entities.scrap")
local Planet = require("src.entities.planet")
local EnemyPlanet = require("src.entities.enemyplanet")
local PlanetDefense = require("src.systems.planetdefense")
local Shop = require("src.ui.shop")
local Gravity = require("src.systems.gravity")

local Gameplay = {}
Gameplay.__index = Gameplay

local TILE_SIZE = 200

function Gameplay:enter()
    self.camera = Camera.new()
    self.planet = Planet.new()
    self.player = Player.new()
    self.bullets = {}
    self.enemies = {}
    self.scraps = {}
    self.enemyPlanets = {}

    for _, pos in ipairs(Constants.ENEMY_PLANET_POSITIONS) do
        table.insert(self.enemyPlanets, EnemyPlanet.new(pos.x, pos.y, pos.sprite))
    end

    self.scrapCount = 0
    self.money = 0
    self.defense = PlanetDefense.new()
    self.shop = Shop.new()
    self.nearPlanet = false
    self.background = love.graphics.newImage("assets/background/background.png")

    return self
end

function Gameplay:exit()
end

function Gameplay:update(dt)
    if self.shop:isOpen() then
        return
    end

    if self.planet:isDestroyed() then
        Game.stateManager:switchTo("gameover", { reason = "planet" })
        return
    end

    self.player:update(dt)
    if Game.stateManager.current.name ~= "gameplay" then
        return
    end

    self.camera:follow(self.player, dt)
    self.planet:update(dt)

    if love.mouse.isDown(1) and self.player:canShoot() then
        local angle = self.player.angle
        table.insert(self.bullets, Bullet.new(self.player.x, self.player.y, angle))
        self.player:resetCooldown()
    end

    for _, bullet in ipairs(self.bullets) do
        bullet:update(dt)
    end

    for _, ep in ipairs(self.enemyPlanets) do
        ep:update(dt, self.enemies)
    end

    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt)
    end

    do
        local gravityPlanets = {
            { x = self.planet.x, y = self.planet.y, gravityRadius = Constants.HOME_PLANET_GRAVITY_RADIUS, gravityStrength = Constants.GRAVITY_STRENGTH },
        }
        for _, ep in ipairs(self.enemyPlanets) do
            table.insert(gravityPlanets, { x = ep.x, y = ep.y, gravityRadius = Constants.ENEMY_PLANET_GRAVITY_RADIUS, gravityStrength = Constants.GRAVITY_STRENGTH })
        end

        local objects = {}
        table.insert(objects, self.player)
        for _, bullet in ipairs(self.bullets) do
            if bullet.alive then table.insert(objects, bullet) end
        end
        for _, enemy in ipairs(self.enemies) do
            if enemy.alive then table.insert(objects, enemy) end
        end
        for _, scrap in ipairs(self.scraps) do
            if not scrap.collected then table.insert(objects, scrap) end
        end

        Gravity.apply(dt, gravityPlanets, objects)

        for _, scrap in ipairs(self.scraps) do
            if not scrap.collected then
                scrap.x = scrap.x + scrap.vx * dt
                scrap.y = scrap.y + scrap.vy * dt
            end
        end
    end

    self.defense:update(dt, self.enemies, self.bullets, self.planet.x, self.planet.y)

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
                            table.insert(self.scraps, Scrap.new(enemy.x, enemy.y))
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

    for _, scrap in ipairs(self.scraps) do
        if not scrap.collected then
            local dx = scrap.x - self.player.x
            local dy = scrap.y - self.player.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < scrap.radius + self.player.radius then
                scrap.collected = true
                self.scrapCount = self.scrapCount + 1
            end
        end
    end

    do
        local dx = self.player.x - self.planet.x
        local dy = self.player.y - self.planet.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist < self.player.radius + self.planet.radius and self.scrapCount > 0 then
            self.money = self.money + self.scrapCount * Constants.SCRAP_TO_MONEY_RATE
            self.scrapCount = 0
        end
    end

    do
        local dx = self.player.x - self.planet.x
        local dy = self.player.y - self.planet.y
        local dist = math.sqrt(dx * dx + dy * dy)
        self.nearPlanet = dist < self.player.radius + self.planet.radius + 20
    end

    self:cleanup()
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
    keepAlive(self.scraps)
end

function Gameplay:draw()
    self.camera:apply()

    self:drawBackground()

    self.planet:draw(self.camera)
    self.defense:draw(self.planet.x, self.planet.y, self.camera)

    for _, ep in ipairs(self.enemyPlanets) do
        ep:draw(self.camera)
    end

    for _, scrap in ipairs(self.scraps) do
        scrap:draw(self.camera)
    end

    for _, enemy in ipairs(self.enemies) do
        enemy:draw(self.camera)
    end

    for _, bullet in ipairs(self.bullets) do
        bullet:draw(self.camera)
    end

    self.player:draw(self.camera)

    self.camera:unapply()

    self:drawUI()

    if self.nearPlanet and not self.shop:isOpen() then
        self.shop:drawPrompt()
    end

    self.shop:draw(self.money, self.defense.level)
end

function Gameplay:drawBackground()
    love.graphics.setColor(1, 1, 1, 1)

    local camLeft = self.camera.x - Constants.WINDOW_WIDTH / 2
    local camTop = self.camera.y - Constants.WINDOW_HEIGHT / 2
    local camRight = self.camera.x + Constants.WINDOW_WIDTH / 2
    local camBottom = self.camera.y + Constants.WINDOW_HEIGHT / 2

    local startX = math.max(0, math.floor(camLeft / TILE_SIZE) * TILE_SIZE)
    local startY = math.max(0, math.floor(camTop / TILE_SIZE) * TILE_SIZE)
    local endX = math.min(Constants.WORLD_WIDTH, camRight + TILE_SIZE)
    local endY = math.min(Constants.WORLD_HEIGHT, camBottom + TILE_SIZE)

    for x = startX, endX - TILE_SIZE, TILE_SIZE do
        for y = startY, endY - TILE_SIZE, TILE_SIZE do
            love.graphics.draw(self.background, x, y)
        end
    end
end

function Gameplay:drawUI()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Planet HP: " .. self.planet.hp .. "/" .. self.planet.maxHp, 10, 10)
    love.graphics.print("Scraps: " .. self.scrapCount, 10, 30)
    love.graphics.print("Money: " .. self.money, 10, 50)
    love.graphics.print("Integrity: " .. math.floor(self.player.integrity / self.player.maxIntegrity * 100) .. "%", 10, 70)
    love.graphics.print("Fuel: " .. string.format("%.2f", self.player.fuel) .. " t", 10, 90)

    local speed = math.sqrt(self.player.vx * self.player.vx + self.player.vy * self.player.vy)
    love.graphics.print("Speed: " .. math.floor(speed), 10, 110)
end

function Gameplay:keypressed(key)
    if key == "e" then
        if self.shop:isOpen() then
            self.shop:close()
        elseif self.nearPlanet then
            self.shop:toggle()
        end
    end
    if key == "escape" then
        self.shop:close()
    end
end

function Gameplay:mousepressed(x, y, button)
    if not self.shop:isOpen() then return end
    if button ~= 1 then return end

    local success, newMoney, newLevel = self.shop:tryBuy(self.money, self.defense.level)
    if success then
        self.money = newMoney
        self.defense.level = newLevel
    end
end

return Gameplay
