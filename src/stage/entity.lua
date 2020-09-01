--
-- Date: 23.06.2016
--
local class = require "lib/middleclass"
local Entity = class("Entity")

function Entity:initialize()
    self.entities = {}
end

function Entity:add(e)
    --TODO refactor addArr to 1 func
    if false and type(e) == "table" then
        for i=1,#e do
            e[i].isDisabled = false
            self.entities[#self.entities+1] = e[i]
        end
    else
        e.isDisabled = false
        self.entities[#self.entities+1] = e
    end
    return e
end

function Entity:addArray(e)
    if not e then
        return self.entities
    end
    for i=1,#e do
        e[i].isDisabled = false
        self.entities[#self.entities+1] = e[i]
    end
    return self.entities
end

local az, bz = 0, 0
function Entity:sortByZIndex()
    table.sort(self.entities, function(a,b)
        if not a then
            return false
        elseif not b then
            return true
        end
        az, bz = a:getZIndex(), b:getZIndex()
        if az == bz then
            return a.id > b.id
        end
        return az < bz end )
end

function Entity:remove(e)
    if not e then
        return false
    end
    e.y = GLOBAL_SETTING.OFFSCREEN
    return true
end

function Entity:getByName(name)
    for _,obj in ipairs(self.entities) do
        if obj.name == name then
            return obj
        end
    end
    return nil
end

function Entity:update(dt)
    for _,obj in ipairs(self.entities) do
        obj:updateAI(dt)
        obj:update(dt)
        if obj.lifeBar then
            obj.lifeBar:update(dt)
        end
    end
    for _,obj in ipairs(self.entities) do
        obj:onHurt()
    end
    --remove inactive effects
    local lastEntity = self.entities[#self.entities]
    if lastEntity.y >= GLOBAL_SETTING.OFFSCREEN then
        if not lastEntity.lifeBar or lastEntity.lifeBar.timer <= 0 then -- remove entity only when the lifeBar is faded out
            self.entities[#self.entities] = nil
        end
    end
end

function Entity:draw(l,t,w,h)
    for _,obj in ipairs(self.entities) do
        obj:draw(l,t,w,h)
    end
end

function Entity:drawShadows(l,t,w,h)
    for i,obj in ipairs(self.entities) do
        obj:drawShadow(l,t,w,h)
    end
end

function Entity:drawReflections(l,t,w,h)
    for i,obj in ipairs(self.entities) do
        if obj.shader then
            love.graphics.setShader(obj.shader)
        end
        obj:drawReflection(l,t,w,h)
        if obj.shader then
            love.graphics.setShader()
        end

    end
end

function Entity:dp()
    local t = "* "
    for i,obj in pairs(self.entities) do
        if not obj then
            t = t .. i .. ":<>, "
        else
            t = t .. i .. ":" .. obj.name .. " x:" .. obj.x .. ", "
        end
    end
    dp(t)
end

return Entity
