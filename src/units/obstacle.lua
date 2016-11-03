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
local function clamp(val, min, max)
    if min - val > 0 then
        return min
    end
    if max - val < 0 then
        return max
    end
    return val
end

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
    self.sfx.dead = "menu_cancel"

    self.infoBar = InfoBar:new(self)

    self:setState(self.stand)
end

--function Obstacle:update(dt)
--    if self.isDisabled then
--        return
--    end
--    --custom code here. e.g. for triggers / keys
--end
function Obstacle:updateSprite(dt)
    local spr = self.sprite
    local s = spr.def.animations[spr.cur_anim]
    --    print(spr.cur_frame, #s)
    UpdateSpriteInstance(self.sprite, dt, self)
end

function Obstacle:setSprite(anim)
    if anim ~= "stand" then
        return
    end
    SetSpriteAnimation(self.sprite, anim)
end

function Obstacle:drawSprite(x, y)
    local spr = self.sprite
    local s = spr.def.animations[spr.cur_anim]
    local n = clamp(math.floor(#s - #s * self.hp / self.max_hp),
        1, #s)
    --print(n, spr.cur_frame, #s)
    DrawSpriteInstance(self.sprite, x, y, n)
end

function Obstacle:updateAI(dt)
    if self.isDisabled then
        return
    end
    --print("updateAI "..self.type.." "..self.name)
    self:updateSprite(dt)
end

function Obstacle:onHurt()
    local h = self.hurt
    if not h then
        return
    end
    --TODO add such sfx in Unit class
    if math.random() < 0.5 then
        sfx.play("sfx"..self.id,"metal1")
    else
        sfx.play("sfx"..self.id,"metal2")
    end
    Character.onHurt(self)
end

function Obstacle:stand_start()
    --	print (self.name.." - stand start")
    self.isHittable = true
    self:setSprite("stand")
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

function Obstacle:getup_start()
    self.isHittable = false
--    print (self.name.." - getup start")
    dpo(self, self.state)
    if self.z <= 0 then
        self.z = 0
    end
    self.isThrown = false
    if self.hp <= 0 then
        self:setState(self.dead)
        return
    end
    self.cool_down = 0.2
end
function Obstacle:getup_update(dt)
    --dp(self.name .. " - getup update", dt)
    self.cool_down = self.cool_down - dt
    if self.cool_down <= 0 then
        self:setState(self.stand)
        return
    end
    self:checkCollisionAndMove(dt)
end
Obstacle.getup = {name = "getup", start = Obstacle.getup_start, exit = nop, update = Obstacle.getup_update, draw = Unit.default_draw}


return Obstacle
