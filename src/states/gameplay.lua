local Constants = require("src.constants")
local Camera = require("src.systems.camera")
local Player = require("src.entities.player")
local Bullet = require("src.entities.bullet")
local Enemy = require("src.entities.enemy")
local Scrap = require("src.entities.scrap")
local FuelPickup = require("src.entities.fuelpickup")
local Planet = require("src.entities.planet")
local EnemyPlanet = require("src.entities.enemyplanet")
local PlanetDefense = require("src.systems.planetdefense")
local Shop = require("src.ui.shop")
local Minimap = require("src.ui.minimap")
local Hud = require("src.ui.hud")
local Gravity = require("src.systems.gravity")

local Gameplay = {}
Gameplay.__index = Gameplay

local TILE_SIZE = 200

function Gameplay:enter()
    self.camera = Camera.new()
    self.planet = Planet.new()
    self.player = Player.new()
    self.bullets = {}
    self.enemyBullets = {}
    self.enemies = {}
    self.scraps = {}
    self.fuelPickups = {}
    self.enemyPlanets = {}

    local colonyNames = { "COLONY ALPHA", "COLONY BETA", "COLONY GAMMA" }
    for i, pos in ipairs(Constants.ENEMY_PLANET_POSITIONS) do
        table.insert(self.enemyPlanets, EnemyPlanet.new(pos.x, pos.y, pos.sprite, pos.difficulty, colonyNames[i]))
        for _ = 1, Constants.FUEL_CANISTER_COUNT do
            local angle = love.math.random() * math.pi * 2
            local dist = love.math.random() * Constants.FUEL_CANISTER_SPREAD
            table.insert(self.fuelPickups, FuelPickup.new(
                pos.x + math.cos(angle) * dist,
                pos.y + math.sin(angle) * dist
            ))
        end
    end

    self.minimap = Minimap.new()
    self.hud = Hud.new()

    self.startTime = love.timer.getTime()
    self.elapsedTime = 0
    self.scrapCount = 0
    self.totalScrapsCollected = 0
    self.money = 1000
    self.moneySpent = 0
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

    self.elapsedTime = self.elapsedTime + dt
    self.player:update(dt)
    if Game.stateManager.current.name ~= "gameplay" then
        return
    end

    self.camera:follow(self.player, dt)
    self.planet:update(dt)

    if love.mouse.isDown(1) and self.player:canShoot() then
        local angle = self.player.angle
        table.insert(self.bullets, Bullet.new(self.player.x, self.player.y, angle, nil, self.player.bulletSpeed))
        self.player:resetCooldown()
    end

    for _, bullet in ipairs(self.bullets) do
        bullet:update(dt)
    end

    for _, ep in ipairs(self.enemyPlanets) do
        ep:update(dt, self.enemies, self.elapsedTime)
    end

    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt, self.player.x, self.player.y, self.enemyBullets)
    end

    for _, bullet in ipairs(self.enemyBullets) do
        bullet:update(dt)
    end

    do
        local gravityPlanets = {
            { x = self.planet.x, y = self.planet.y, gravityRadius = Constants.HOME_PLANET_GRAVITY_RADIUS, gravityStrength = self.planet.gravityStrength },
        }
        for _, ep in ipairs(self.enemyPlanets) do
            table.insert(gravityPlanets, { x = ep.x, y = ep.y, gravityRadius = Constants.ENEMY_PLANET_GRAVITY_RADIUS, gravityStrength = ep.gravityStrength })
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
        for _, fuel in ipairs(self.fuelPickups) do
            if not fuel.collected then table.insert(objects, fuel) end
        end

        Gravity.apply(dt, gravityPlanets, objects)

        for _, scrap in ipairs(self.scraps) do
            if not scrap.collected then
                scrap.x = scrap.x + scrap.vx * dt
                scrap.y = scrap.y + scrap.vy * dt
            end
        end
        for _, fuel in ipairs(self.fuelPickups) do
            if not fuel.collected then
                fuel.x = fuel.x + fuel.vx * dt
                fuel.y = fuel.y + fuel.vy * dt
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
                        enemy:takeDamage(self.player.bulletDamage)
                        bullet.alive = false
                        if not enemy.alive then
                            for _ = 1, enemy.scrapDrop do
                                table.insert(self.scraps, Scrap.new(enemy.x, enemy.y))
                            end
                            if enemy.type == "bomber" then
                                table.insert(self.fuelPickups, FuelPickup.new(enemy.x, enemy.y))
                            elseif enemy.type == "fighter" and love.math.random() < Constants.FIGHTER_FUEL_DROP_CHANCE then
                                table.insert(self.fuelPickups, FuelPickup.new(enemy.x, enemy.y))
                            end
                        end
                        break
                    end
                end
            end
        end
        if bullet.alive then
            for _, ep in ipairs(self.enemyPlanets) do
                if ep.alive then
                    local dx = bullet.x - ep.x
                    local dy = bullet.y - ep.y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist < bullet.radius + ep.radius then
                        ep:takeDamage(Constants.BULLET_DAMAGE_TO_COLONY)
                        bullet.alive = false
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

    for _, bullet in ipairs(self.enemyBullets) do
        if bullet.alive then
            local dx = bullet.x - self.player.x
            local dy = bullet.y - self.player.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < bullet.radius + self.player.radius then
                self.player.integrity = math.max(0, self.player.integrity - Constants.FIGHTER_BULLET_INTEGRITY_DAMAGE)
                bullet.alive = false
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
                self.totalScrapsCollected = self.totalScrapsCollected + 1
            end
        end
    end

    for _, fuel in ipairs(self.fuelPickups) do
        if not fuel.collected then
            local dx = fuel.x - self.player.x
            local dy = fuel.y - self.player.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < fuel.radius + self.player.radius then
                fuel.collected = true
                self.player.fuel = math.min(self.player.maxFuel, self.player.fuel + Constants.FUEL_PICKUP_AMOUNT)
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

    local allDead = true
    for _, ep in ipairs(self.enemyPlanets) do
        if ep.alive then allDead = false; break end
    end
    if allDead then
        Game.stateManager:switchTo("victory", {
            timeSurvived = love.timer.getTime() - self.startTime,
            scrapsCollected = self.totalScrapsCollected,
            moneySpent = self.moneySpent,
        })
    end
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
    keepAlive(self.enemyBullets)
    keepAlive(self.enemies)
    keepAlive(self.scraps)
    keepAlive(self.fuelPickups)
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

    for _, fuel in ipairs(self.fuelPickups) do
        if not fuel.collected then
            fuel:draw(self.camera)
        end
    end

    for _, enemy in ipairs(self.enemies) do
        enemy:draw(self.camera)
    end

    for _, bullet in ipairs(self.bullets) do
        bullet:draw(self.camera)
    end

    for _, bullet in ipairs(self.enemyBullets) do
        bullet:draw(self.camera)
    end

    self.player:draw(self.camera)

    self.camera:unapply()

    self.minimap:draw(self.player, self.planet, self.enemyPlanets, self.enemies)

    local warnings = {}
    for _, ep in ipairs(self.enemyPlanets) do
        if ep.warningActive then
            table.insert(warnings, { name = ep.name, alpha = ep.warningAlpha })
        end
    end
    self.hud:draw(self.player, self.planet, self.scrapCount, self.money, warnings)

    if self.nearPlanet and not self.shop:isOpen() then
        self.shop:drawPrompt()
    end

    self.shop:draw(self.money)
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

    if self.shop:isOpen() then
        if key == "left" then
            self.shop:navLeft()
        elseif key == "right" then
            self.shop:navRight()
        end
    end
end

function Gameplay:mousepressed(x, y, button)
    if not self.shop:isOpen() then return end
    if button ~= 1 then return end

    local success, newMoney, itemIndex, newLevel = self.shop:tryBuy(self.money)
    if success then
        self.moneySpent = self.moneySpent + (self.money - newMoney)
        self.money = newMoney
        self:applyUpgrade(itemIndex, newLevel)
    end
end

function Gameplay:applyUpgrade(itemIndex, level)
    if itemIndex == 1 then
        self.defense.level = level
    elseif itemIndex == 2 then
        self.player:upgradeFuel()
    elseif itemIndex == 3 then
        self.player:upgradeIntegrity()
    elseif itemIndex == 4 then
        self.player:upgradeThrust()
    elseif itemIndex == 5 then
        self.player:upgradeWeapons(level)
    end
end

return Gameplay
