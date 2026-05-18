--- Applies constant gravitational pull from each planet toward affected objects.
--- @param dt number
--- @param planets table List of tables with x, y, gravityRadius, gravityStrength
--- @param objects table List of tables with x, y, vx, vy
local function apply(dt, planets, objects)
    for _, obj in ipairs(objects) do
        for _, planet in ipairs(planets) do
            local dx = planet.x - obj.x
            local dy = planet.y - obj.y
            local dist = math.sqrt(dx * dx + dy * dy)

            if dist > 0 and dist <= planet.gravityRadius then
                local nx = dx / dist
                local ny = dy / dist
                obj.vx = obj.vx + nx * planet.gravityStrength * dt
                obj.vy = obj.vy + ny * planet.gravityStrength * dt
            end
        end
    end
end

return { apply = apply }
