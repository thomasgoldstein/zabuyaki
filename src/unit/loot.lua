local class = require "lib/middleclass"
local Loot = class("Loot", Unit)

local CheckCollision = CheckCollision

function Loot:initialize(name, sprite, x, y, f)
    --f options {}: shapeType, shapeArgs, hp, score, shader, color, sfxOnHit, sfxDead, func
    if not f then
        f = {}
    end
    Unit.initialize(self, name, sprite, nil, x, y, f)
    self.draw = Unit.defaultDraw
    self.chargedAt, self.charge = 0, -1  -- for Unit.defaultDraw
    self:setSprite("stand")

    self.note = f.note or "???"
    self.pickupSfx = f.pickupSfx
    self.type = "loot"
    self.x, self.y, self.z = x, y, 20
    self.height = 17
    self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
    self.isHittable = false
    self.isDisabled = false
    self.bounced = 0

    self.id = GLOBAL_UNIT_ID --to stop Y coord sprites flickering
    GLOBAL_UNIT_ID = GLOBAL_UNIT_ID + 1
end

function Loot:setOnStage(stage)
    stage.objects:add(self)
    self.infoBar = InfoBar:new(self)
end

function Loot:addShape()
    Unit.addShape(self, "circle", { self.x, self.y, 7.5 })
end

function Loot:onHurt()
end

function Loot:updateAI(dt)
    if self.isDisabled then
        return
    end
    if self.z > 0 then
        self:calcFreeFall(dt, 1)
        if self.z <= 0 then
            if self.vel_z < -100 and self.bounced < 1 then    --bounce up after fall (not )
                if self.vel_z < -300 then
                    self.vel_z = -300
                end
                self.z = 0.01
                self.vel_z = -self.vel_z/2
--                sfx.play("sfx" .. self.id, self.sfx.onBreak or "fall", 1 - self.bounced * 0.2, self.bouncedPitch - self.bounced * 0.2)
                self.bounced = self.bounced + 1
                Character.showEffect(self, "fallLanding")
                return
            else
                --final fall (no bouncing)
                self.z = 0
                self.vel_z = 0
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
    sfx.play("sfx"..self.id, self.pickupSfx)
    taker:addHp(self.hp)
    taker:addScore(self.scoreBonus)
    self.isDisabled = true
    stage.world:remove(self.shape)  --stage.world = global collision shapes pool
    self.shape = nil
    --self.y = GLOBAL_SETTING.OFFSCREEN --keep in the stage for proper save/load
end

return Loot
