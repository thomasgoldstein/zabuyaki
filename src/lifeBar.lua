local class = require "lib/middleclass"
local LifeBar = class("LifeBar")

local MAX_PLAYERS = GLOBAL_SETTING.MAX_PLAYERS

local verticalGap = 39 --vertical gap between bars
local verticalMargin = 13 --vertical margin from the top
local horizontalMargin = 28 --horizontal margin
local horizontalGap = 20 --horizontal gap between bars
local barWidth = 150
local barWidthWithLR = barWidth + 16
local barHeight = 16
local iconWidth = 40
local iconHeight = 17
local screenWidth = 640

local barsCoords = {   --for players only 1..MAX_PLAYERS
    { x = horizontalMargin , y = verticalMargin + 0 * verticalGap },
    { x = horizontalMargin + barWidthWithLR + horizontalGap, y = verticalMargin + 0 * verticalGap },
    { x = horizontalMargin + barWidthWithLR * 2 + horizontalGap * 2, y = verticalMargin + 0 * verticalGap }
}

local function calcBarWidth(self)
    if self.maxHp < 100 and self.source.lives <= 1 then
        return math.floor((self.maxHp * barWidth) / 100)
    end
    return barWidth
end

local function slantedRectangle2(x, y, width, height)
    for i = 0, height-1, 2 do
        love.graphics.rectangle('fill', x-i/2, y+i, width , 2)
    end
end

LifeBar.DELAY = 3 -- seconds to show a victim's lifeBar
LifeBar.OVERRIDE = 2.5 -- seconds to show a victim's lifeBar

function LifeBar:initialize(source)
    self.source = source
    self.name = source.name
    self.pickUpNote = source.pickUpNote
    self.timer = LifeBar.DELAY
    self.id = self.source.id
    self.source:initFaceIcon(self)
    self.hp = 1
    self.oldHp = 1
    self.maxHp = source.maxHp
    self.x, self.y = 0, 0
    if self.id <= MAX_PLAYERS then
        self.x, self.y = barsCoords[self.id].x, barsCoords[self.id].y
    end
    local _, _, w, _ = self.q:getViewport( )
    self.iconOffset_x = math.floor((38 - w)/2)
end

function LifeBar:getAttackerId(attackerSource)
    if attackerSource.isThrown then
        return attackerSource.throwerId.id
    end
    return attackerSource.id
end

function LifeBar:setPositionUnderAttackersBar(attackerSource)
    local id = self:getAttackerId(attackerSource)
    self.x, self.y = barsCoords[id].x, barsCoords[id].y + verticalGap
end

function LifeBar:setAttacker(attackerSource)
    local id = self:getAttackerId(attackerSource)
    if id <= MAX_PLAYERS and self.id > MAX_PLAYERS then -- player attacks enemies
        self.timer = LifeBar.DELAY
        getRegisteredPlayer(id).lifeBarTimer = LifeBar.DELAY
        return self
    end
end

function LifeBar:setPicker(picker)
    self.timer = LifeBar.DELAY
    picker.lifeBarTimer = LifeBar.DELAY
    return self
end

function LifeBar:drawFaceIcon(l, t, transpBg)
    colors:set(self.iconColor, nil, transpBg)
    if self.shader then
        love.graphics.setShader(self.shader)
    end
    self.source.drawFaceIcon(self, l + self.iconOffset_x + self.x - 2, t + self.y, transpBg)
    if self.shader then
        love.graphics.setShader()
    end
end

function LifeBar:drawDeadCross(l, t, transpBg)
    if self.hp <= 0 then
        colors:set("white", nil, (transpBg > 200 and 255 or 1) * math.sin(self.timer*20 + 17) * transpBg)
        love.graphics.draw (
            gfx.ui.deadIcon.sprite,
            gfx.ui.deadIcon.q,
            l + self.x + self.source.shake.x + 1, t + self.y - 2
        )
    end
end

function LifeBar:drawLifebar(l, t, transpBg)
    -- Normal lifeBar
    colors:set("barLostColor", nil, transpBg)
    slantedRectangle2( l + self.x + 4, t + self.y + iconHeight + 6, calcBarWidth(self) , barHeight - 6 )
    if self.oldHp > 0 then
        if self.source.hp > self.hp then
            colors:set("barGotColor", nil, transpBg)
        else
            colors:set("barLosingColor", nil, transpBg)
        end
        slantedRectangle2( l + self.x + 4, t + self.y + iconHeight + 6, calcBarWidth(self)  * self.oldHp / self.maxHp , barHeight - 6 )
    end
    if self.hp > 0 then
        colors:set("barNormColor", nil, transpBg)
        slantedRectangle2( l + self.x + 4, t + self.y + iconHeight + 6, calcBarWidth(self) * self.hp / self.maxHp + 1, barHeight - 6 )
    end
    colors:set("white", nil, transpBg)
    love.graphics.draw (
        gfx.ui.middleSlant.sprite,
        gfx.ui.middleSlant.q,
        l + self.x - 4 + 12, t + self.y + iconHeight + 3, 0, (calcBarWidth(self) - 12) / 4, 1
    )
    love.graphics.draw (
        gfx.ui.leftSlant.sprite,
        gfx.ui.leftSlant.q,
        l + self.x - 4, t + self.y + iconHeight + 3
    )
    love.graphics.draw (
        gfx.ui.rightSlant.sprite,
        gfx.ui.rightSlant.q,
        l + self.x - 4 + calcBarWidth(self), t + self.y + iconHeight + 3
    )
    colors:set("barTopBottomSmoothColor", nil, math.min(255,transpBg) - 127)
    love.graphics.rectangle('fill', l + self.x + 4, t + self.y + iconHeight + 6, calcBarWidth(self), 1)
    love.graphics.rectangle('fill', l + self.x + 0, t + self.y + iconHeight + barHeight - 1, calcBarWidth(self), 1)
end

function LifeBar:draw(l,t,w,h, characterSource)
    if self.timer <= 0 and self.source.id > MAX_PLAYERS then
        return
    end
    self.source.drawBar(self, 0,0,w,h, characterSource)
end

local function normalizeHp(curr, target, step)
    if curr > target then
        return  curr - (step or 1)
    elseif curr < target then
        return curr + (step or 1)
    end
    return curr
end

function LifeBar:update(dt)
    self.hp = normalizeHp(self.hp, self.source.hp)  -- TODO add a step according to dt
    if self.hp == self.source.hp then
        self.oldHp = self.hp
    elseif self.hp < self.source.hp then
        self.oldHp = self.source.hp
    end
    self.timer = self.timer - dt
end

return LifeBar
