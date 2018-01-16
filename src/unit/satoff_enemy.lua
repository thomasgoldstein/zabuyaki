local class = require "lib/middleclass"
local Satoff = class('Satoff', Enemy)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Satoff:initialize(name, sprite, input, x, y, f)
    self.lives = self.lives or 3
    self.hp = self.hp or 100
    self.scoreBonus = self.scoreBonus or 1500
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon"
    f.shapeArgs = f.shapeArgs or { 1, 0, 27, 0, 28, 3, 27, 6, 1, 6, 0, 3 }
    self.tx, self.ty = x, y
    Enemy.initialize(self, name, sprite, input, x, y, f)
    Satoff.initAttributes(self)
    self.whichPlayerAttack = "close" -- random far close weak healthy fast slow
    self:pickAttackTarget()
    self.subtype = "midboss"
    self.face = -1
    self:postInitialize()
end

function Satoff:initAttributes()
    self.moves = { -- list of allowed moves
        run = true, sideStep = true, pickup = true,
        jump = true, jumpAttackForward = true, jumpAttackLight = false, jumpAttackRun = true, jumpAttackStraight = true,
        grab = true, grabSwap = false, frontGrabAttack = true,
        frontGrabAttackUp = false, frontGrabAttackDown = true, frontGrabAttackBack = true, frontGrabAttackForward = false,
        dashAttack = false, offensiveSpecial = false, defensiveSpecial = false,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
    }
    self.height = self.height or 55
    self.velocityWalk_x = 86
    self.velocityWalk_y = 45
    self.velocityWalkHold_x = 80
    self.velocityWalkHold_y = 40
    self.velocityRun_x = 140
    self.velocityRun_y = 23
    self.velocitySideStep = 160
    self.frictionSideStep = 350
    self.hopDuringSideStep = false
    self.velocityDash = 190 --speed of the character
    --    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = self.velocityDash * 3
    --    self.velocityThrow_x = 220 --my throwing speed
    --    self.velocityThrow_z = 200 --my throwing speed
    --    self.velocityThrowHorizontal = 1.3 -- +30% for horizontal throws
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.throw = sfx.satoffAttack
    self.sfx.jumpAttack = sfx.satoffAttack
    self.sfx.step = "rickStep" --TODO refactor def files
    self.sfx.dead = sfx.satoffDeath
    self.AI = AIMoveCombo:new(self)
end

function Satoff:updateAI(dt)
    if self.isDisabled then
        return
    end
    Enemy.updateAI(self, dt)
    self.AI:update(dt)
end

function Satoff:walkStart()
    self.isHittable = true
    self:setSprite("walk")
    self.tx, self.ty = self.x, self.y
    if not self.target then
        self:setState(self.intro)
        return
    end
    local t = dist(self.target.x, self.target.y, self.x, self.y)
    --get to player(to fight)
    if self.x < self.target.x then
        self.move = tween.new(1 + t / self.walkSpeed, self, {
            tx = self.target.x - love.math.random(40, 60),
            ty = self.target.y + 1
        }, 'inOutQuad')
    else
        self.move = tween.new(1 + t / self.walkSpeed, self, {
            tx = self.target.x + love.math.random(40, 60),
            ty = self.target.y + 1
        }, 'inOutQuad')
    end
end
function Satoff:walkUpdate(dt)
    local complete
    if self.move then
        complete = self.move:update(dt)
    else
        complete = true
    end
    if complete then
        --        if love.math.random() < 0.5 then
        --            self:setState(self.walk)
        --        else
        self:setState(self.stand)
        --        end
        return
    end
    self.canJump = true
    self:calcMovement(dt, true, nil)
end
Satoff.walk = { name = "walk", start = Satoff.walkStart, exit = nop, update = Satoff.walkUpdate, draw = Enemy.defaultDraw }

function Satoff:runStart()
    self.isHittable = true
    self:setSprite("run")
    local t = dist(self.target.x, self.y, self.x, self.y)

    --get to player(to fight)
    if self.x < self.target.x then
        self.move = tween.new(0.3 + t / self.runSpeed, self, {
            tx = self.target.x - love.math.random(25, 35),
            ty = self.y + 1 + love.math.random(-1, 1) * love.math.random(6, 8)
        }, 'inQuad')
        self.face = 1
        self.horizontal = self.face
    else
        self.move = tween.new(0.3 + t / self.runSpeed, self, {
            tx = self.target.x + love.math.random(25, 35),
            ty = self.y + 1 + love.math.random(-1, 1) * love.math.random(6, 8)
        }, 'inQuad')
        self.face = -1
        self.horizontal = self.face
    end
end
function Satoff:runUpdate(dt)
    local complete
    if self.move then
        complete = self.move:update(dt)
    else
        complete = true
    end
    if complete then
        local t = dist(self.target.x, self.target.y, self.x, self.y)
        if t > 200 then
            self:setState(self.walk)
        else
            self:setState(self.combo)
        end
        return
    end
    self:calcMovement(dt, true, nil)
end
Satoff.run = {name = "run", start = Satoff.runStart, exit = nop, update = Satoff.runUpdate, draw = Satoff.defaultDraw}

return Satoff
