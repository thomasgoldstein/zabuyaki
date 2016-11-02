--
-- Date: 02.11.2016
--
local class = require "lib/middleclass"

local Obstacle = class("Obstacle", Character)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end
local function nop() --[[print "nop"]] end

function Obstacle:initialize(name, sprite, hp, score, func, x, y, shader, color)
    Character.initialize(self, name, sprite, nil, x, y, shader, color)
    self.name = name or "Unknown Obstacle"
    self.type = "obstacle"
    self.hp = hp
    self.max_hp = self.hp
    self.lives = 0
    self.score = score
    self.func = func
    --self.x, self.y, self.z = x, y, 0
    self.height = 40
    self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
    self.color = color or { 255, 255, 255, 255 }
    self.shader = shader
    self.isHittable = false
    self.isDisabled = false

    self.infoBar = InfoBar:new(self)

    self.id = GLOBAL_UNIT_ID --to stop Y coord sprites flickering
    GLOBAL_UNIT_ID = GLOBAL_UNIT_ID + 1

    self:setState(self.stand)
end

function Obstacle:update(dt)
    if self.isDisabled then
        return
    end
    --custom code here. e.g. for triggers / keys
end

function Obstacle:updateAI(dt)
    --    Unit.updateAI(self, dt)
    --     print("updateAI "..self.type.." "..self.name)
end

function Obstacle:stand_start()
    --	print (self.name.." - stand start")
    self.isHittable = true
    SetSpriteAnimation(self.sprite,"stand")
end
function Obstacle:stand_update(dt)
    --	print (self.name," - stand update",dt)
    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Obstacle.stand = {name = "stand", start = Obstacle.stand_start, exit = nop, update = Obstacle.stand_update, draw = Unit.default_draw}

return Obstacle
