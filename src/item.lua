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

function Item:initialize(name, sprite, hp, score, func, x, y, color)
    self.sprite = sprite --GetInstance("res/man_template.lua")
    self.name = name or "Unknown Item"
    self.type = "item"
    self.hp = hp
    self.score = score
    self.x, self.y, self.z = x, y, 0
    self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
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
end

return Item
