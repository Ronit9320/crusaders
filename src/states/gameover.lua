local Constants = require("src.constants")

local GameOver = {}
GameOver.__index = GameOver

function GameOver:enter(params)
    self.wave = params.wave or 1
    return self
end

function GameOver:exit()
end

function GameOver:update(dt)
end

function GameOver:draw()
    local w = Constants.WINDOW_WIDTH
    local h = Constants.WINDOW_HEIGHT

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("GAME OVER", 0, h / 2 - 60, w, "center")
    love.graphics.printf("Wave reached: " .. self.wave, 0, h / 2 - 20, w, "center")
    love.graphics.printf("Press ENTER to restart", 0, h / 2 + 20, w, "center")
end

function GameOver:keypressed(key)
    if key == "return" or key == "r" then
        Game.stateManager:switchTo("gameplay")
    end
end

return GameOver
