--
-- Date: 09.11.2016
--
local class = require "lib/middleclass"

local function nop() --[[print "nop"]] end

local Wall = class("Wall", Unit)

function Wall:initialize(name, sprite, x, y, f)
    --f options {}: hp, score, shader, color,isMovable, sfxDead, func, face, horizontal, weight, sfxOnHit, sfxOnBreak
    if not f then
        f = {}
    end
    Unit.initialize(self, name, sprite, nil, x, y)
    self.name = name or "Unknown Wall"
    self.type = "wall"
    self.hp = f.hp or 50
    self.max_hp = self.hp
    self.lives = 0
    self.score = f.score or 10
    self.func = f.func
    self.height = 40
    self.vertical, self.horizontal, self.face = 1, f.horizontal or 1, f.face or 1 --movement and face directions
    self.isHittable = false
    self.isDisabled = false
    self.faceFix = nil   --keep the same facing after 1st hit
    self.sfx.dead = f.sfxDead --on death sfx
    self.sfx.onHit = f.sfxOnHit
    self.sfx.onBreak = f.sfxOnBreak
    self.isMovable = f.isMovable --on death sfx
    self.colorParticle = f.colorParticle
    self.weight = f.weight or 1.5
    self.gravity = self.gravity * self.weight

    self.old_frame = 1 --Old sprite frame N to start particles on change

    self.infoBar = nil

    self:setState(self.stand)
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