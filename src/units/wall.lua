--
-- Date: 09.11.2016
--
local class = require "lib/middleclass"

local function nop() --[[print "nop"]] end

local Wall = class("Wall", Unit)

function Wall:initialize(name, x, y, w, h, f)
    --f options {}: hp, score, shader, color,isMovable, sfxDead, func, face, horizontal, weight, sfxOnHit, sfxOnBreak
    if not f then
        f = {}
    end
    Unit.initialize(self, name, nil, nil, x, y)
    self.name = name or "Unknown Wall"
    self.type = "wall"
    self.hp = f.hp or 1
    self.max_hp = self.hp
    self.lives = 0
    self.score = f.score or 0
    self.func = f.func
    self.height = 40
    self.vertical, self.horizontal, self.face = 1, f.horizontal or 1, f.face or 1 --movement and face directions
    self.isHittable = false
    self.isDisabled = false
    self.isMovable = f.isMovable --on death sfx

    self.infoBar = nil

    self:addShape(x, y, w, h)

    self:setState(self.stand)
end

function Wall:addShape(x, y, w, h)
    if not self.shape then
        self.shape = stage.world:rectangle(x, y, w or 10, h or 10)
        self.shape.obj = self
    else
        print(self.name.."("..self.id..") has predefined shape")
    end
end

function Wall:updateSprite(dt)
end

function Wall:setSprite(anim)
end

function Wall:drawSprite(l,t,w,h)
end

function Wall:drawShadow(l,t,w,h)
end

function Wall:updateAI(dt)
--    print(self.name, self.shape:center())
end

function Wall:onHurt()
end

Wall.stand = {name = "stand", start = nop, exit = nop, update = nop, draw = nop}

return Wall