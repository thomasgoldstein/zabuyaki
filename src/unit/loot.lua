local class = require "lib/middleclass"
local Loot = class("Loot", Unit)

local CheckCollision = CheckCollision

function Loot:initialize(name, gfx, x, y, f)
    --f options {}: shapeType, shapeArgs, hp, score, shader, color, sfxOnHit, sfxDead, func
    if not f then
        f = {}
    end
    Unit.initialize(self, name, nil, nil, x, y, f)
    self.draw = Loot.draw
    if gfx.sprite2 then
        self.sprite = imageBank[gfx.sprite2.def.spriteSheet]
        self.q = gfx.sprite2.def.animations.stand[1].q
    else
        self.sprite = gfx.sprite
        self.q = gfx.q
    end
    self.ox = gfx.ox
    self.oy = gfx.oy

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

function Loot:calcShadowSpriteAndTransparency()
    love.graphics.setColor(0, 0, 0, 255) --4th is the shadow transparency
    return self.sprite, self.sprite, self, -stage.shadowAngle, 0
end

function Loot:draw(l,t,w,h)
    if not self.isDisabled and CheckCollision(l, t, w, h, self.x-20, self.y-40, 40, 40) then
        love.graphics.setColor( unpack( self.color ) )
        love.graphics.draw (
            self.sprite, --The image
            self.q, --Current frame of the current animation
            self.x, self.y - self.z,
            0, --spr.rotation
            1, 1, --spr.sizeScale * spr.flipH, spr.sizeScale * spr.flipV,
            self.ox, self.oy
        )
    end
end

function Loot:onHurt()
end

function Loot:updateAI(dt)
    if self.isDisabled then
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.vel_z
        self.vel_z = self.vel_z - self.gravity * dt
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
