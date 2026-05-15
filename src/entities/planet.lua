local Constants = require("src.constants")

local Planet = {}
Planet.__index = Planet

local spritesheet = love.graphics.newImage("assets/planet/home_planetv2.png")
local quads = {}
for i = 0, Constants.PLANET_FRAME_COUNT - 1 do
    quads[i + 1] = love.graphics.newQuad(
        i * Constants.PLANET_FRAME_WIDTH, 0,
        Constants.PLANET_FRAME_WIDTH, Constants.PLANET_FRAME_HEIGHT,
        spritesheet:getDimensions()
    )
end

--- Creates a new Planet (home base) at world center.
function Planet.new()
    local self = setmetatable({}, Planet)
    self.x = Constants.WORLD_WIDTH / 2
    self.y = Constants.WORLD_HEIGHT / 2
    self.radius = Constants.PLANET_RADIUS
    self.hp = Constants.PLANET_HP
    self.maxHp = Constants.PLANET_HP
    self.frame = 1
    self.frameTimer = 0
    return self
end

--- Updates the animation frame.
--- @param dt number
function Planet:update(dt)
    self.frameTimer = self.frameTimer + dt
    if self.frameTimer >= Constants.PLANET_FRAME_DURATION then
        self.frameTimer = self.frameTimer - Constants.PLANET_FRAME_DURATION
        self.frame = self.frame + 1
        if self.frame > Constants.PLANET_FRAME_COUNT then
            self.frame = 1
        end
    end
end

--- Reduces planet HP. Clamped to 0.
--- @param amount number
function Planet:takeDamage(amount)
    self.hp = math.max(0, self.hp - amount)
end

--- Returns true if the planet is destroyed.
--- @return boolean
function Planet:isDestroyed()
    return self.hp <= 0
end

--- Draws the planet sprite in world space, scaled to match collision radius.
--- @param camera table
function Planet:draw(camera)
    love.graphics.setColor(1, 1, 1, 1)
    local scale = self.radius * 2 / Constants.PLANET_FRAME_WIDTH
    love.graphics.draw(spritesheet, quads[self.frame], self.x, self.y, 0, scale, scale, Constants.PLANET_FRAME_WIDTH / 2, Constants.PLANET_FRAME_HEIGHT / 2)
end

return Planet
