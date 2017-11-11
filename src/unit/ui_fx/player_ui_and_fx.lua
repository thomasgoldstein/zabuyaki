-- Copyright (c) .2017 SineDie
-- Visuals and SFX go here

local Player = Player

-- Start of Lifebar elements
local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency
function Player:drawTextInfo(l, t, transpBg, iconWidth, normColor)
    love.graphics.setColor(255, 255, 255, transpBg)
    printWithShadow(self.name, l + self.shake.x + iconWidth + 2, t + 9,
        transpBg)
    local c = GLOBAL_SETTING.PLAYERS_COLORS[self.id]
    if c then
        c[4] = transpBg
        love.graphics.setColor(unpack( c ))
    end
    printWithShadow(self.pid, l + self.shake.x + iconWidth + 2, t - 1,
        transpBg)
    love.graphics.setColor(normColor[1], normColor[2], normColor[3], transpBg)
    printWithShadow(string.format("%06d", self.score), l + self.shake.x + iconWidth + 34, t - 1,
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

function Player:drawBar(l,t,w,h, iconWidth, normColor)
    love.graphics.setFont(gfx.font.arcade3)
    local transpBg = 255 * calcBarTransparency(3)
    local playerSelectMode = self.source.playerSelectMode
    if self.source.lives > 0 then
        -- Default draw
        if self.source.state == "respawn" then
            -- Fade-in and drop down bar while player falls (respawns)
            transpBg = 255 - self.source.z
            t = t - self.source.z / 2
        end
        self:drawLifebar(l, t, transpBg)
        self:drawFaceIcon(l + self.source.shake.x, t, transpBg)
        self:drawDeadCross(l, t, transpBg)
        self.source:drawTextInfo(l + self.x, t + self.y, transpBg, iconWidth, normColor)
    else
        love.graphics.setColor(255, 255, 255, transpBg)
        if playerSelectMode == 0 then
            -- wait press to use credit
            printWithShadow("CONTINUE x"..tonumber(credits), l + self.x + 2, t + self.y + 9,
                transpBg)
            love.graphics.setColor(255,255,255, 200 + 55 * math.sin(self.cooldown*2 + 17))
            printWithShadow(self.source.pid .. " PRESS ATTACK (".. math.floor(self.source.displayCooldown) ..")", l + self.x + 2, t + self.y + 9 + 11,
                transpBg)
        elseif playerSelectMode == 1 then
            -- wait 1 sec before player select
            printWithShadow("CONTINUE x"..tonumber(credits), l + self.x + 2, t + self.y + 9,
                transpBg)
        elseif playerSelectMode == 2 then
            -- Select Player
            printWithShadow(self.source.name, l + self.x + self.source.shake.x + iconWidth + 2, t + self.y + 9,
                transpBg)
            local c = GLOBAL_SETTING.PLAYERS_COLORS[self.source.id]
            if c then
                c[4] = transpBg
                love.graphics.setColor(unpack( c ))
            end
            printWithShadow(self.source.pid, l + self.x + self.source.shake.x + iconWidth + 2, t + self.y - 1,
                transpBg)
            --printWithShadow("<     " .. self.source.name .. "     >", l + self.x + 2 + math.floor(2 * math.sin(self.cooldown*4)), t + self.y + 9 + 11 )
            self:drawFaceIcon(l + self.source.shake.x, t, transpBg)
            love.graphics.setColor(255,255,255, 200 + 55 * math.sin(self.cooldown*3 + 17))
            printWithShadow("SELECT PLAYER (".. math.floor(self.source.displayCooldown) ..")", l + self.x + 2, t + self.y + 19,
                transpBg)
        elseif playerSelectMode == 3 then
            -- Spawn selecterd player
        elseif playerSelectMode == 4 then
            -- Replace this player with the new character
        elseif playerSelectMode == 5 then
            -- Game Over (too late)
            love.graphics.setColor(255,255,255, 200 + 55 * math.sin(self.cooldown*0.5 + 17))
            printWithShadow(self.source.pid .. " GAME OVER", l + self.x + 2, t + self.y + 9,
                transpBg)
        end
    end
end
-- End of Lifebar elements
