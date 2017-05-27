-- Copyright (c) .2017 SineDie
-- Visuals and SFX go here

local Character = Character

local sign = sign
local clamp = clamp

-- Start of Lifebar elements
function Character:initFaceIcon(target)
    target.sprite = imageBank[self.sprite.def.spriteSheet]
    target.q = self.sprite.def.animations["icon"][1].q  --quad
    target.qa = self.sprite.def.animations["icon"]  --quad array
    target.iconColor = self.color or { 255, 255, 255, 255 }
    target.shader = self.shader
end

function Character:drawFaceIcon(l, t)
    local s = self.qa
    local n = clamp(math.floor((#s-1) - (#s-1) * self.hp / self.maxHp)+1,
        1, #s)
    love.graphics.draw (
        self.sprite,
        self.qa[n].q, --Current frame of the current animation
        l + self.source.shake.x / 2, t
    )
end

local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency
function Character:drawTextInfo(l, t, transpBg, iconWidth, normColor)
    love.graphics.setColor(255, 255, 255, transpBg)
    printWithShadow(self.name, l + self.shake.x + iconWidth + 2, t + 9,
        transpBg)
    if self.lives >= 1 then
        love.graphics.setColor(255, 255, 255, transpBg)
        printWithShadow("x", l + self.shake.x + iconWidth + 91, t + 9,
            transpBg)
        love.graphics.setFont(gfx.font.arcade3x2)
        if self.lives > 10 then
            printWithShadow("9+", l + self.shake.x + iconWidth + 100, t + 1,
                transpBg)
        else
            printWithShadow(self.lives - 1, l + self.shake.x + iconWidth + 100, t + 1,
                transpBg)
        end
    end
end

function Character:drawBar(l,t,w,h, iconWidth, normColor)
    love.graphics.setFont(gfx.font.arcade3)
    local transpBg = 255 * calcBarTransparency(self.cooldown)
    self:drawLifebar(l, t, transpBg)
    self:drawFaceIcon(l + self.source.shake.x, t, transpBg)
    self:drawDeadCross(l, t, transpBg)
    self.source:drawTextInfo(l + self.x, t + self.y, transpBg, iconWidth, normColor)
end
-- End of Lifebar elements
