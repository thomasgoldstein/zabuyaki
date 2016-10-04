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
--    if not e then
--        return self.entities
--    end
    if false and type(e) == "table" then
        for i=1,#e do
            self.entities[#self.entities+1] = e[i]
        end
    else
        self.entities[#self.entities+1] = e
    end
    return self.entities
end

function Entity:addOne(e)
    if not e then
        return self.entities
    end
    self.entities[#self.entities+1] = e
    return self.entities
end

function Entity:addArray(a)
    if not a then
        return self.entities
    end
    --    if type(e) == "table" then
    for i=1,#a do
        self.entities[#self.entities+1] = a[i]
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

function Entity:addToWorld()
    for i,obj in pairs(self.entities) do
        --global var 'word'
        world:add(obj, obj.x-7, obj.y-3, 15, 7)
    end
end

--function Entity:remove(e)
--    if not e then
--        return self.entities
--    end
--    self.entities[#self.entities+1] = e
--    return self.entities
--end

function Entity:update(dt)
    for _,obj in ipairs(self.entities) do
        obj:update(dt)
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
    for i,obj in ipairs(self.entities) do
        obj:drawShadow(l,t,w,h)
    end
    for _,obj in ipairs(self.entities) do
        obj:draw(l,t,w,h)
    end
end

function Entity:revive()
    for i, player in ipairs(self.entities) do
        if player.type == "player" or player.type == "enemy" then
            player:revive()
        end
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