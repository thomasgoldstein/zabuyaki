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

function Item:initialize(name, sprite, hp, score, func, x, y, color)
    self.sprite = sprite
    self.name = name or "Unknown Item"
    self.type = "item"
    self.hp = hp
    self.score = score
    self.func = func
    self.x, self.y, self.z = x, y, 0
    self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
    if color then
        self.color = { r = color[1], g = color[2], b = color[3], a = color[4] }
    else
        self.color = { r= 255, g = 255, b = 255, a = 255 }
    end
    self.isHidden = false
    self.isEnabled = true
    self.id = GLOBAL_PLAYER_ID --to stop Y coord sprites flickering
    GLOBAL_PLAYER_ID = GLOBAL_PLAYER_ID + 1
end

function Item:drawShadow(l,t,w,h)
    --TODO adjust sprite dimensions
    if not self.isHidden and CheckCollision(l, t, w, h, self.x-16, self.y-10, 32, 20) then
        love.graphics.setColor(0, 0, 0, 100)
        love.graphics.ellipse("fill", self.x, self.y + 1, 8 - self.z/8, 2)
    end
end

function Item:draw(l,t,w,h)
    --TODO adjust sprite dimensions.
    if not self.isHidden and CheckCollision(l, t, w, h, self.x-20, self.y-40, 40, 40) then
        love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
        love.graphics.ellipse("fill", self.x, self.y - self.z - 8, 8, 8)
        --DrawInstance(self.sprite, self.x, self.y - self.z)
    end
end

function Item:onHurt()
end

function Item:update(dt)
    if self.isHidden then
        return
    end
    --custom code here. e.g. for triggers / keys
end

function Item:get(taker)
    if DEBUG then
        print(taker.name .. " got "..self.name.." HP+ ".. self.hp .. ", $+ " .. self.score)
    end
    if self.func then    --run custom function if there is
        self:func(taker)
    end
    if self.hp > self.score then
        TEsound.play("res/sfx/pickup1.wav", nil, 1)
    else
        TEsound.play("res/sfx/pickup2.wav", nil, 1)
    end
    taker.hp = taker.hp + self.hp
    if taker.hp > taker.max_hp then
        taker.hp = taker.max_hp
    end
    taker.score = taker.score + self.score
    self.isHidden = true
    world:remove(self)  --world = global bump var
end

return Item
