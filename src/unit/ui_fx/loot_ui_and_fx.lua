-- Copyright (c) .2017 SineDie
-- Visuals and SFX go here

local Loot = Loot

-- Start of Lifebar elements
function Loot:initFaceIcon(target)
    target.sprite = imageBank[self.sprite.def.spriteSheet]
    target.q = self.sprite.def.animations["icon"][1].q  --quad
    target.iconColor = { 255, 255, 255, 255 }
end

function Loot:drawFaceIcon(l, t)
    local s = self.qa
    love.graphics.draw (
        self.sprite,
        self.q, --Current frame of the current animation
        l, t
    )
end

local calcBarTransparency = calcBarTransparency
local printWithShadow = printWithShadow
function Loot:drawBar(l,t,w,h, iconWidth, normColor)
    local transpBg = 255 * calcBarTransparency(self.delay)
    self:drawFaceIcon(l, t, transpBg)
    love.graphics.setFont(gfx.font.arcade3)
    love.graphics.setColor(255, 255, 255, transpBg)
    printWithShadow(self.name, l + self.x + iconWidth + 4 + 0, t + self.y + 9 - 0, transpBg)
    normColor[4] = transpBg
    love.graphics.setColor( unpack( normColor ) )
    printWithShadow(self.note, l + self.x + iconWidth + 2 + (#self.name+1)*8 + 0, t + self.y + 9 - 0, transpBg)
end
-- End of Lifebar elements
