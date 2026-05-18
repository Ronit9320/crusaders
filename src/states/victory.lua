local Constants = require("src.constants")

local Victory = {}
Victory.__index = Victory

function Victory:enter(params)
    self.timeSurvived = params.timeSurvived or 0
    self.scrapsCollected = params.scrapsCollected or 0
    self.moneySpent = params.moneySpent or 0
    return self
end

function Victory:exit()
end

function Victory:update(dt)
end

function Victory:draw()
    local w = Constants.WINDOW_WIDTH
    local h = Constants.WINDOW_HEIGHT

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("VICTORY", 0, h / 2 - 60, w, "center")

    love.graphics.setColor(0.8, 0.8, 0.9)
    love.graphics.printf(
        string.format("Time survived: %.0f seconds", self.timeSurvived)
            .. "\nScraps collected: " .. self.scrapsCollected
            .. "\nMoney spent: $" .. self.moneySpent,
        0, h / 2 - 20, w, "center"
    )

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press ENTER to restart", 0, h / 2 + 60, w, "center")
end

function Victory:keypressed(key)
    if key == "return" or key == "r" then
        Game.stateManager:switchTo("gameplay")
    end
end

return Victory
