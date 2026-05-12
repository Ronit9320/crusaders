Game = {}

function love.load()
    Game.stateManager = require("src.systems.statemanager").new()

    local GameplayState = require("src.states.gameplay")
    local GameOverState = require("src.states.gameover")

    Game.stateManager:register("gameplay", GameplayState)
    Game.stateManager:register("gameover", GameOverState)

    Game.stateManager:switchTo("gameplay")
end

function love.update(dt)
    Game.stateManager:update(dt)
end

function love.draw()
    Game.stateManager:draw()
end

function love.keypressed(key)
    Game.stateManager:keypressed(key)
end

function love.mousepressed(x, y, button)
    Game.stateManager:mousepressed(x, y, button)
end
