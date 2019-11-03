-- Visuals and SFX go here

local Loot = Loot

local iconWidth = 40

-- Start of LifeBar elements
function Loot:initFaceIcon(target)
    target.sprite = imageBank[self.sprite.def.spriteSheet]
    target.q = self.sprite.def.animations["icon"][1].q  --quad
    target.iconColor = "white"
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
function Loot:drawBar(l,t,w,h)
    local transpBg = 255 * calcBarTransparency(self.timer)
    self:drawFaceIcon(l, t, transpBg)
    love.graphics.setFont(gfx.font.arcade3)
    colors:set("white", nil, transpBg)
    printWithShadow(self.name, l + self.x + iconWidth + 4 + 0, t + self.y + 9 - 0, transpBg)
    colors:set("barNormColor", nil, transpBg)
    printWithShadow(self.pickUpNote, l + self.x + iconWidth + 2 + (#self.name+1)*8 + 0, t + self.y + 9 - 0, transpBg)
end
-- End of LifeBar elements
