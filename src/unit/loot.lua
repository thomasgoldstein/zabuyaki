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
    self.sprite = gfx.sprite
    self.q = gfx.q
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

    self.infoBar = InfoBar:new(self)

    self.id = GLOBAL_UNIT_ID --to stop Y coord sprites flickering
    GLOBAL_UNIT_ID = GLOBAL_UNIT_ID + 1
end

function Loot:setOnStage(stage)
    stage.objects:add(self)
end

function Loot:addShape()
    Unit.addShape(self, "circle", { self.x, self.y, 7.5 })
end

function Loot:drawShadow(l,t,w,h)
    if not self.isDisabled and CheckCollision(l, t, w, h, self.x-16, self.y-10, 32, 20) then
        love.graphics.setColor(0, 0, 0, 255) --4th is the shadow transparency
        love.graphics.draw (
            self.sprite, --The image
            self.q, --Current frame of the current animation
            self.x, self.y + self.z/6,
            0, --spr.rotation
            1,
            -stage.shadowHeight,
            self.ox, self.oy,
            -stage.shadowAngle
        )
    end
end

function Loot:draw(l,t,w,h)
    if not self.isDisabled and CheckCollision(l, t, w, h, self.x-20, self.y-40, 40, 40) then
        love.graphics.setColor( unpack( self.color ) )
        love.graphics.draw (
            self.sprite, --The image
            self.q, --Current frame of the current animation
            self.x, self.y - self.z,
            0, --spr.rotation
            1, 1, --spr.size_scale * spr.flip_h, spr.size_scale * spr.flip_v,
            self.ox, self.oy
        )
    end
end

-- Start of Lifebar elements
function Loot:initFaceIcon(target)
    target.sprite = self.sprite
    target.q = self.q  --quad
    target.icon_color = { 255, 255, 255, 255 }
end

function Loot:drawFaceIcon(l, t)
    love.graphics.draw (
        self.sprite,
        self.q, --Current frame of the current animation
            l, t
        )
end

local calcBarTransparency = calcBarTransparency
local printWithShadow = printWithShadow
function Loot:drawBar(l,t,w,h, icon_width, norm_color)
    local transp_bg = 255 * calcBarTransparency(self.cool_down)
    self:drawFaceIcon(l, t, transp_bg)
    love.graphics.setFont(gfx.font.arcade3)
    love.graphics.setColor(255, 255, 255, transp_bg)
    printWithShadow(self.name, l + self.x + icon_width + 4 + 0, t + self.y + 9 - 0, transp_bg)
    norm_color[4] = transp_bg
    love.graphics.setColor( unpack( norm_color ) )
    printWithShadow(self.note, l + self.x + icon_width + 2 + (#self.name+1)*8 + 0, t + self.y + 9 - 0, transp_bg)
end
-- End of Lifebar elements

function Loot:onHurt()
end

function Loot:updateAI(dt)
    if self.isDisabled then
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt
        if self.z <= 0 then
            if self.velz < -100 and self.bounced < 1 then    --bounce up after fall (not )
                if self.velz < -300 then
                    self.velz = -300
                end
                self.z = 0.01
                self.velz = -self.velz/2
                --sfx.play("sfx" .. self.id, self.sfx.onBreak or "fall", 1 - self.bounced * 0.2, self.bounced_pitch - self.bounced * 0.2)
                self.bounced = self.bounced + 1
                --landing dust clouds
                local psystem = PA_DUST_FALLING:clone()
                psystem:setAreaSpread( "uniform", 4, 1 )
                psystem:setLinearAcceleration(-50, -10, 50, -20) -- Random movement in all directions.
                psystem:emit(3)
                stage.objects:add(Effect:new(psystem, self.x, self.y+3))
                return
            else
                --final fall (no bouncing)
                self.z = 0
                self.velz = 0
                return
            end
        end
    end
end

function Loot:get(taker)
    dp(taker.name .. " got "..self.name.." HP+ ".. self.hp .. ", $+ " .. self.score_bonus)
    if self.func then    --run custom function if there is
        self:func(taker)
    end
    sfx.play("sfx"..self.id, self.pickupSfx)
    taker:addHp(self.hp)
    taker:addScore(self.score_bonus)
    self.isDisabled = true
    stage.world:remove(self.shape)  --stage.world = global collision shapes pool
    self.shape = nil
    --self.y = GLOBAL_SETTING.OFFSCREEN --keep in the stage for proper save/load
end

return Loot
