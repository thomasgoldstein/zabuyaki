--
-- Date: 23.06.2016
--
local class = require "lib/middleclass"
local Entity = class("Entity")

function Entity:initialize()
    self.entities = {}
--    dp("Entitiy new")
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
    return self.entities
end

function Entity:addArray(e)
    if not e then
        return self.entities
    end
    --    if type(e) == "table" then
    for i=1,#e do
        e[i].isDisabled = false
        self.entities[#self.entities+1] = e[i]
    end
    return self.entities
end

function Entity:sortByY()
    table.sort(self.entities, function(a,b)
        if not a then
            return false
        elseif not b then
            return true
        elseif a.y == b.y then
            return a.id > b.id
        end
        return a.y < b.y end )
end

function Entity:sortByY_()
    table.sort(self.entities, function(a,b)
        if not a then
            return false
        elseif not b then
            return true
        end
        local ay, by = a.y - a.id / 100, b.y - b.id / 100
        if b.isGrabbed then
            by = by - 1
        end
        if ay == by then
            return a.id > b.id
        end
        return ay < by end )
end

function Entity:remove(e)
    if not e then
        return flase
    end
    e.y = GLOBAL_SETTING.OFFSCREEN
    return true
end

function Entity:update(dt)
    for _,obj in ipairs(self.entities) do
        obj:update(dt)
        obj:updateAI(dt)
        if obj.infoBar then
            obj.infoBar:update(dt)
        end
    end
    for _,obj in ipairs(self.entities) do
        obj:onHurt()
    end
    --remove inactive effects
    if self.entities[#self.entities].y >= GLOBAL_SETTING.OFFSCREEN then
        self.entities[#self.entities] = nil
    end
end

function Entity:draw(l,t,w,h)
    for _,obj in ipairs(self.entities) do
        obj:draw(l,t,w,h)
        if GLOBAL_SETTING.DEBUG and obj.shape then
            love.graphics.setColor(0, 255, 255, 50)
            obj.shape:draw()
        end
    end
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setColor(255, 0, 255, 50)
        stage.testShape:draw()
    end
end

function Entity:drawShadows(l,t,w,h)
    for i,obj in ipairs(self.entities) do
        obj:drawShadow(l,t,w,h)
    end
end

function Entity:dp()
    local t = "* "
    for i,obj in pairs(self.entities) do
        if not obj then
            t = t .. i .. ":<>, "
        else
            t = t .. i .. ":" .. obj.name .. ", "
        end
    end
    dp(t)
end

return Entity