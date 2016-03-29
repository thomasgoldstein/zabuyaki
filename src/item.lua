--
-- Date: 29.03.2016
--
local class = require "lib/middleclass"

local Item = class("Item")

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[print "nop"]] end

GLOBAL_Item_ID = 1

function Item:initialize(name, sprite, hp, money, func, x, y, color)
    self.sprite = sprite --GetInstance("res/man_template.lua")
    self.name = name or "Unknown Item"
    self.type = "item"
    self.hp = hp
    self.money = money
    self.x, self.y, self.z = x, y, 0
    self.vertical, self.horizontal, self.face = 1, 1, 1; --movement and face directions
    --self.velx, self.vely, self.velz, self.gravity = 0, 0, 0, 0
    --self.gravity = 650
--    self.friction = 1650 -- velocity penalty for stand (when u slide on ground)
--    self.sideStepFriction = 600 -- velocity penalty for sideStepUp Down (when u slide on ground)
--    self.state = "item"
--    self.prev_state = "" -- text name
--    self.last_state = "" -- text name

    if color then
        self.color = { r = color[1], g = color[2], b = color[3], a = color[4] }
    else
        self.color = { r= 255, g = 255, b = 255, a = 255 }
    end

    self.isHidden = false
    self.isEnabled = true

    self.start = nop
    self.exit = nop

    self.id = GLOBAL_PLAYER_ID --to stop Y coord sprites flickering
    GLOBAL_PLAYER_ID = GLOBAL_PLAYER_ID + 1

    --self:setState(Item.stand)
end

function Item:_onGet(picker)
    -- hurt = {picker, hp, money, func}
    if DEBUG then
        print(picker.name .. " got "..self.name.." HP+ ".. self.hp .. ", $+ " .. self.money)
    end
    picker.hp = picker.hp + self.hp
    picker.money = picker.money + self.money
    self.isHidden = true
    self.type = ""
end

function Item:drawShadow(l,t,w,h)
    --TODO adjust sprite dimensions
    if not self.isHidden and CheckCollision(l, t, w, h, self.x-16, self.y-10, 32, 20) then
        love.graphics.setColor(0, 0, 0, 200)
        love.graphics.ellipse("fill", self.x, self.y, 9 - self.z/8, 3 - self.z/16)
    end
end

function Item:draw(l,t,w,h)
    --TODO adjust sprite dimensions.
    if not self.isHidden and CheckCollision(l, t, w, h, self.x-35, self.y-70, 70, 70) then
        love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
        love.graphics.ellipse("fill", self.x, self.y - self.z - 9, 9, 9)
        --DrawInstance(self.sprite, self.x, self.y - self.z)
    end
end

function Item:update(dt)
    if self.isHidden then
        return
    end
    local items, len = world:queryRect(self.x - 16/2, self.y - 8/2, 16, 8,
            function(item)
--                print("-"..item.type.."-")
                if item.type == "player" then
                    return true
                end
            end)
    --print(self.name, len)
    for i = 1, #items do
        items[i]:onGetItem(self)
    end
end

return Item
