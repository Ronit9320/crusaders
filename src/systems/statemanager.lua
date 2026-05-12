local StateManager = {}
StateManager.__index = StateManager

--- Creates a new StateManager.
function StateManager.new()
    local self = setmetatable({}, StateManager)
    self.states = {}
    self.current = nil
    return self
end

--- Registers a state by name.
--- @param name string
--- @param state table Must implement update, draw, and optionally enter/exit/keypressed/mousepressed.
function StateManager:register(name, state)
    self.states[name] = state
end

--- Switches to a registered state, calling exit on the old and enter on the new.
--- @param name string
--- @param params table|nil
function StateManager:switchTo(name, params)
    if self.current and self.current.state.exit then
        self.current.state:exit()
    end
    self.current = { name = name, state = self.states[name] }
    if self.current.state.enter then
        self.current.state:enter(params)
    end
end

function StateManager:update(dt)
    if self.current then
        self.current.state:update(dt)
    end
end

function StateManager:draw()
    if self.current then
        self.current.state:draw()
    end
end

function StateManager:keypressed(key)
    if self.current and self.current.state.keypressed then
        self.current.state:keypressed(key)
    end
end

function StateManager:mousepressed(x, y, button)
    if self.current and self.current.state.mousepressed then
        self.current.state:mousepressed(x, y, button)
    end
end

return StateManager
