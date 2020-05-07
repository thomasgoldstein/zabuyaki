local class = require "lib/middleclass"
local Loot = class("Loot", Unit)

function Loot:initialize(name, sprite, x, y, f)
    --f options {}: hp, score, shader, color, sfxOnHit, sfxDead, func
    if not f then
        f = {}
    end
    Unit.initialize(self, name, sprite, x, y, f)
    self.draw = Unit.defaultDraw
    self.chargedAt, self.chargeTimer = 0, -1  -- for Unit.defaultDraw
    self:setSprite("stand")
    self.pickUpNote = f.pickUpNote or "???"
    self.pickUpSfx = f.pickUpSfx
    self.type = "loot"
    self.x, self.y, self.z = x, y, 20
    self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
    self.isHittable = false
    self.isDisabled = false
    self.isMovable = false
    self.bounced = 0
    self.id = GLOBAL_UNIT_ID --to stop Y coord sprites flickering
    GLOBAL_UNIT_ID = GLOBAL_UNIT_ID + 1
end

function Loot:setOnStage(stage)
    stage.objects:add(self)
    self.lifeBar = LifeBar:new(self)
end

function Loot:addShape()
end

function Loot:onHurt()
end

function Loot:updateAI(dt)
    if self.isDisabled then
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt, 1)
        if not self:canFall() then
            if self.speed_z < -100 and self.bounced < 1 then    --bounce up after fall (not )
                if self.speed_z < -300 then
                    self.speed_z = -300
                end
                self.z = self:getRelativeZ()
                self.speed_z = -self.speed_z/2
                self.bounced = self.bounced + 1
                Character.showEffect(self, "fallLanding")
                return
            else
                --final fall (no bouncing)
                self.z = self:getRelativeZ()
                self.speed_z = 0
                return
            end
        end
    end
    self:updateSprite(dt)
end

function Loot:get(taker)
    dp(taker.name .. " got "..self.name.." HP+ ".. self.hp .. ", $+ " .. self.scoreBonus)
    if self.func then    --run custom function if there is
        self:func(taker)
    end
    self:playSfx(self.pickUpSfx)
    taker:addHp(self.hp)
    taker:addScore(self.scoreBonus)
    self.isDisabled = true
    self.y = GLOBAL_SETTING.OFFSCREEN --keep in the stage for proper save/load
end

local funcDropApple = function(slf)
    local loot = Loot:new("Apple", gfx.loot.apple,
        math.floor(slf.x), math.floor(slf.y) + 1,
        { hp = 25, score = 0, pickUpNote = "+25 HP", pickUpSfx = "pickUpApple"} --, func = testDeathFunc
    )
    loot:setOnStage(stage)
end
local funcDropChicken = function(slf)
    local loot = Loot:new("Chicken", gfx.loot.chicken,
        math.floor(slf.x), math.floor(slf.y) + 1,
        { hp = 50, score = 0, pickUpNote = "+50 HP", pickUpSfx = "pickUpChicken"}
    )
    loot:setOnStage(stage)
end
local funcDropBeef = function(slf)
    local loot = Loot:new("Beef", gfx.loot.beef,
        math.floor(slf.x), math.floor(slf.y) + 1,
        { hp = 100, score = 0, pickUpNote = "+100 HP", pickUpSfx = "pickUpBeef"}
    )
    loot:setOnStage(stage)
end
local funcDropBat = function(slf)
    local loot = Loot:new("Bat", gfx.loot.bat,
        math.floor(slf.x), math.floor(slf.y) + 1,
        { hp = 0, score = 0, pickUpNote = "Weapon", pickUpSfx = "grab"}
    )
    loot:setOnStage(stage)
end
local dropItemFuncList = {
    apple = funcDropApple, chicken = funcDropChicken, beef = funcDropBeef,
    bat = funcDropBat }
function Loot.getDropFuncByName(itemName)
    return dropItemFuncList[itemName]
end

return Loot
