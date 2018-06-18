local class = require "lib/middleclass"
local InfoBar = class("InfoBar")

local MAX_PLAYERS = GLOBAL_SETTING.MAX_PLAYERS
local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency

local verticalGap = 39 --vertical gap between bars
local verticalMargin = 13 --vert margin from the top
local horizontalMargin = 28 --horizontal margin
local horizontalGap = 20 --horizontal gap between bars
local barWidth = 150
local barWidthWithLR = barWidth + 16
local barHeight = 16
local iconWidth = 40
local iconHeight = 17
local screenWidth = 640
local normColor = {244,210,14}
local losingColor = {228,102,21}
local lostColor = {199,32,26}
local gotColor = {34,172,11}
local barTopBottomSmoothColor = {100,50,50}

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

InfoBar.DELAY = 3 -- seconds to show a victim's infoBar
InfoBar.OVERRIDE = 2.5 -- seconds to show a victim's infoBar

function InfoBar:initialize(source)
    self.source = source
    self.name = source.name or "Unknown"
    self.note = source.note or "EXTRA TEXT"
    self.color = normColor
    self.timer = InfoBar.DELAY
    self.id = self.source.id
    self.source:initFaceIcon(self)
    self.hp = 1
    self.old_hp = 1
    self.maxHp = source.maxHp
    self.x, self.y = 0, 0
    if self.id <= MAX_PLAYERS then
        self.x, self.y = barsCoords[self.id].x, barsCoords[self.id].y
    end
    local _, _, w, _ = self.q:getViewport( )
    self.iconOffset_x = math.floor((38 - w)/2)
end

function InfoBar:setAttacker(attackerSource)
    local id = -1
    if attackerSource.isThrown then
        id = attackerSource.throwerId.id
    else
        id = attackerSource.id
    end
    self.timer = InfoBar.DELAY
    if id <= MAX_PLAYERS and self.id > MAX_PLAYERS then
        self.x, self.y = barsCoords[id].x, barsCoords[id].y + verticalGap
        return self
    end
    return nil
end

function InfoBar:setPicker(picker_source)
    local id = picker_source.id
    if id <= MAX_PLAYERS then
        self.x, self.y = barsCoords[id].x, barsCoords[id].y + verticalGap
    end
    self.timer = InfoBar.DELAY
    return self
end

function InfoBar:drawFaceIcon(l, t, transpBg)
    self.iconColor[4] = transpBg
    love.graphics.setColor( unpack( self.iconColor ) )
    if self.shader then
        love.graphics.setShader(self.shader)
    end
    self.source.drawFaceIcon(self, l + self.iconOffset_x + self.x - 2, t + self.y, transpBg)
    if self.shader then
        love.graphics.setShader()
    end
end

function InfoBar:drawDeadCross(l, t, transpBg)
    if self.hp <= 0 then
        colors:set("white", nil, 255 * math.sin(self.timer*20 + 17) * transpBg)
        love.graphics.draw (
            gfx.ui.deadIcon.sprite,
            gfx.ui.deadIcon.q,
            l + self.x + self.source.shake.x + 1, t + self.y - 2
        )
    end
end

function InfoBar:drawLifebar(l, t, transpBg)
    -- Normal lifebar
    lostColor[4] = transpBg
    love.graphics.setColor( unpack( lostColor ) )
    slantedRectangle2( l + self.x + 4, t + self.y + iconHeight + 6, calcBarWidth(self) , barHeight - 6 )

    if self.old_hp > 0 then
        if self.source.hp > self.hp then
            gotColor[4] = transpBg
            love.graphics.setColor( unpack( gotColor ) )
        else
            losingColor[4] = transpBg
            love.graphics.setColor( unpack( losingColor ) )
        end
        slantedRectangle2( l + self.x + 4, t + self.y + iconHeight + 6, calcBarWidth(self)  * self.old_hp / self.maxHp , barHeight - 6 )
    end
    if self.hp > 0 then
        self.color[4] = transpBg
        love.graphics.setColor( unpack( self.color ) )
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
    barTopBottomSmoothColor[4] = math.min(255,transpBg) - 127
    love.graphics.setColor( unpack( barTopBottomSmoothColor ) )
    love.graphics.rectangle('fill', l + self.x + 4, t + self.y + iconHeight + 6, calcBarWidth(self), 1)
    love.graphics.rectangle('fill', l + self.x + 0, t + self.y + iconHeight + barHeight - 1, calcBarWidth(self), 1)
end

function InfoBar:draw(l,t,w,h)
    if self.timer <= 0 and self.source.id > MAX_PLAYERS then
        return
    end
    self.source.drawBar(self, 0,0,w,h, iconWidth, normColor)
end

local function norm_n(curr, target, n)
    if curr > target then
        return  curr - (n or 1)
    elseif curr < target then
        if curr < target then
            return curr + (n or 1)
        end
    end
    return curr
end

function InfoBar:update(dt)
    self.hp = norm_n(self.hp, self.source.hp)
    if self.hp > self.source.hp then
        self.color[1] = norm_n(self.color[1],normColor[1],10)
        self.color[2] = norm_n(self.color[2],normColor[2],10)
        self.color[3] = norm_n(self.color[3],normColor[3],10)
    elseif self.hp < self.source.hp then
        self.old_hp = self.source.hp
        self.color[1] = norm_n(self.color[1],normColor[1],10)
        self.color[2] = norm_n(self.color[2],normColor[2],10)
        self.color[3] = norm_n(self.color[3],normColor[3],10)
    else
        self.color[1] = norm_n(self.color[1],normColor[1])
        self.color[2] = norm_n(self.color[2],normColor[2])
        self.color[3] = norm_n(self.color[3],normColor[3])
        self.old_hp = self.hp
    end
    self.timer = self.timer - dt
end

return InfoBar
