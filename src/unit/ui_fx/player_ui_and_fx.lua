-- Visuals and SFX go here

local Player = Player

local iconWidth = 40

-- Start of LifeBar elements
local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency

function Player:drawScore(l, t)
    colors:set("playersColors", self.id, transpBg)
    printWithShadow(self.pid, l + self.shake.x + iconWidth + 2, t - 1,
        transpBg)
    colors:set("barNormColor", nil, transpBg)
    printWithShadow(string.format("%06d", self.score), l + self.shake.x + iconWidth + 34, t - 1,
        transpBg)
end

function Player:getBarTransparency()
    if self.lives == 1 and self.deathDelay < 1 then
        return  255 * calcBarTransparency(self.deathDelay)
    end
    return 255
end

function Player:drawBar(l,t,w,h)
    local playerSelectMode = self.source.playerSelectMode
    if self.source.lives > 0 then
        -- Default draw
        Character.drawBar(self, l,t,w,h)
    else
        local transpBg = self.source:getBarTransparency()
        love.graphics.setFont(gfx.font.arcade3)
        colors:set("white", nil, transpBg)
        if playerSelectMode == 0 then
            -- wait press to use credit
            printWithShadow("CONTINUE x"..tonumber(credits), l + self.x + 2, t + self.y + 9,
                transpBg)
            colors:set("white", nil, 200 + 55 * math.sin(self.timer*2 + 17))
            printWithShadow(self.source.pid .. " PRESS ATTACK (".. math.floor(self.source.displayDelay) ..")", l + self.x + 2, t + self.y + 9 + 11,
                transpBg)
        elseif playerSelectMode == 1 then
            -- wait 1 sec before player select
            printWithShadow("CONTINUE x"..tonumber(credits), l + self.x + 2, t + self.y + 9,
                transpBg)
        elseif playerSelectMode == 2 then
            -- Select Player
            printWithShadow(self.source.name, l + self.x + self.source.shake.x + iconWidth + 2, t + self.y + 9,
                transpBg)
            colors:set("playersColors", self.source.id, transpBg)
            printWithShadow(self.source.pid, l + self.x + self.source.shake.x + iconWidth + 2, t + self.y - 1,
                transpBg)
            if self.source.shader then
                love.graphics.setShader(self.source.shader)
            end
            self:drawFaceIcon(l + self.source.shake.x, t, transpBg)
            if self.source.shader then
                love.graphics.setShader()
            end
            colors:set("white", nil, 200 + 55 * math.sin(self.timer*3 + 17))
            printWithShadow("SELECT PLAYER (".. math.floor(self.source.displayDelay) ..")", l + self.x + 2, t + self.y + 19,
                transpBg)
        elseif playerSelectMode == 3 then
            -- Spawn selected player
        elseif playerSelectMode == 4 then
            -- Replace this player with the new character
        elseif playerSelectMode == 5 then
            -- Game Over (too late)
            colors:set("white", nil, 200 + 55 * math.sin(self.timer*0.5 + 17))
            printWithShadow(self.source.pid .. " GAME OVER", l + self.x + 2, t + self.y + 9,
                transpBg)
        end
    end
end
-- End of LifeBar elements
