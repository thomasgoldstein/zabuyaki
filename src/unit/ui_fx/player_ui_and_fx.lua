-- Visuals and SFX go here

local Player = Player

local iconWidth = 40

local function calcPIDTransparency(cd)
    if cd > 1 then
        return math.sin(cd * 10) * 55 + 200
    end
    if cd < 0.33 then
        return cd * 255
    end
    return 255
end

function Player:drawPID(x_, y_, l, w)
    if self.hp > 0 and self.showPIDDelay < 1 and (x_ < l or x_ >= l + w ) then
        self.showPIDDelay = self.showPIDDelay + math.pi
    end
    if self.showPIDDelay <= 0 then return end
    local x = clamp(x_, l + 20, l + w - 20)
    local y = y_ - math.cos(self.showPIDDelay * 6) - 30 - self:getHurtBoxHeight()
    local PIDTransparency = calcPIDTransparency(self.showPIDDelay)
    colors:set("playersColors", self.id, PIDTransparency)
    love.graphics.rectangle("fill", x - 15, y, 30, 17)
    if x == x_ then
        love.graphics.polygon("fill", x, y + 20, x - 2, y + 17, x + 2, y + 17) -- V
    elseif x < x_ then
        love.graphics.polygon("fill", x + 15, y + 6, x + 18, y + 9, x + 15, y + 12) -- >
    else
        love.graphics.polygon("fill", x - 15, y + 6, x - 18, y + 9, x - 15, y + 12) -- <
    end
    colors:set("black", nil, PIDTransparency)
    love.graphics.rectangle("fill", x - 13, y + 2, 30 - 4, 13)
    love.graphics.setFont(gfx.font.arcade3)
    colors:set("white", nil, PIDTransparency)
    love.graphics.print(self.pid, x - 7, y + 4)
end
-- Start of LifeBar elements
local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency

function Player:drawScore(l, t, transpBg)
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
