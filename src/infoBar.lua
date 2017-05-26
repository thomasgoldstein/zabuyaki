local class = require "lib/middleclass"
local InfoBar = class("InfoBar")

local MAX_PLAYERS = GLOBAL_SETTING.MAX_PLAYERS
local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency

local v_g = 39 --vertical gap between bars
local v_m = 13 --vert margin from the top
local h_m = 28 --horizontal margin
local h_g = 20 --horizontal gap between bars
local barWidth = 150
local barWidth_with_lr = barWidth + 16
local barHeight = 16
local iconWidth = 40
local iconHeight = 17
local screenWidth = 640
local normColor = {244,210,14}
local losingColor = {228,102,21}
local lostColor = {199,32,26}
local gotColor = {34,172,11}
local bar_top_bottom_smoothColor = {100,50,50}

local bars_coords = {   --for players only 1..MAX_PLAYERS
    { x = h_m , y = v_m + 0 * v_g },
    { x = h_m + barWidth_with_lr + h_g, y = v_m + 0 * v_g },
    { x = h_m + barWidth_with_lr * 2 + h_g * 2, y = v_m + 0 * v_g }
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

function InfoBar:initialize(source)
    self.source = source
    self.name = source.name or "Unknown"
    self.note = source.note or "EXTRA TEXT"
    self.color = normColor
    self.cooldown = 1
    self.id = self.source.id
    self.source:initFaceIcon(self)
    self.hp = 1
    self.old_hp = 1
    self.maxHp = source.maxHp
    self.x, self.y = 0, 0
    if self.id <= MAX_PLAYERS then
        self.x, self.y = bars_coords[self.id].x, bars_coords[self.id].y
    end
    local _, _, w, _ = self.q:getViewport( )
    self.icon_xOffset = math.floor((38 - w)/2)
end

function InfoBar:setAttacker(attacker_source)
    local id = -1
    if attacker_source.isThrown then
        id = attacker_source.throwerId.id
    else
        id = attacker_source.id
    end
    self.cooldown = 3
    if id <= MAX_PLAYERS and self.id > MAX_PLAYERS then
        self.x, self.y = bars_coords[id].x, bars_coords[id].y + v_g
        return self
    end
    return nil
end

function InfoBar:setPicker(picker_source)
    local id = picker_source.id
    if id <= MAX_PLAYERS then
        self.x, self.y = bars_coords[id].x, bars_coords[id].y + v_g
    end
    self.cooldown = 3
    return self
end

function InfoBar:drawFaceIcon(l, t, transp_bg)
    self.iconColor[4] = transp_bg
    love.graphics.setColor( unpack( self.iconColor ) )
    if self.shader then
        love.graphics.setShader(self.shader)
    end
    self.source.drawFaceIcon(self, l + self.icon_xOffset + self.x - 2, t + self.y, transp_bg)
    if self.shader then
        love.graphics.setShader()
    end
end

function InfoBar:drawDeadCross(l, t, transp_bg)
    if self.hp <= 0 then
        love.graphics.setColor(255,255,255, 255 * math.sin(self.cooldown*20 + 17) * transp_bg)
        love.graphics.draw (
            gfx.ui.dead_icon.sprite,
            gfx.ui.dead_icon.q,
            l + self.x + self.source.shake.x + 1, t + self.y - 2
        )
    end
end

function InfoBar:drawLifebar(l, t, transp_bg)
    -- Normal lifebar
    lostColor[4] = transp_bg
    love.graphics.setColor( unpack( lostColor ) )
    slantedRectangle2( l + self.x + 4, t + self.y + iconHeight + 6, calcBarWidth(self) , barHeight - 6 )

    if self.old_hp > 0 then
        if self.source.hp > self.hp then
            gotColor[4] = transp_bg
            love.graphics.setColor( unpack( gotColor ) )
        else
            losingColor[4] = transp_bg
            love.graphics.setColor( unpack( losingColor ) )
        end
        slantedRectangle2( l + self.x + 4, t + self.y + iconHeight + 6, calcBarWidth(self)  * self.old_hp / self.maxHp , barHeight - 6 )
    end
    if self.hp > 0 then
        self.color[4] = transp_bg
        love.graphics.setColor( unpack( self.color ) )
        slantedRectangle2( l + self.x + 4, t + self.y + iconHeight + 6, calcBarWidth(self) * self.hp / self.maxHp + 1, barHeight - 6 )
    end
    love.graphics.setColor(255,255,255, transp_bg)
    love.graphics.draw (
        gfx.ui.middle_slant.sprite,
        gfx.ui.middle_slant.q,
        l + self.x - 4 + 12, t + self.y + iconHeight + 3, 0, (calcBarWidth(self) - 12) / 4, 1
    )
    love.graphics.draw (
        gfx.ui.left_slant.sprite,
        gfx.ui.left_slant.q,
        l + self.x - 4, t + self.y + iconHeight + 3
    )
    love.graphics.draw (
        gfx.ui.right_slant.sprite,
        gfx.ui.right_slant.q,
        l + self.x - 4 + calcBarWidth(self), t + self.y + iconHeight + 3
    )
    bar_top_bottom_smoothColor[4] = math.min(255,transp_bg) - 127
    love.graphics.setColor( unpack( bar_top_bottom_smoothColor ) )
    love.graphics.rectangle('fill', l + self.x + 4, t + self.y + iconHeight + 6, calcBarWidth(self), 1)
    love.graphics.rectangle('fill', l + self.x + 0, t + self.y + iconHeight + barHeight - 1, calcBarWidth(self), 1)
end

function InfoBar:draw(l,t,w,h)
    if self.cooldown <= 0 and self.source.id > MAX_PLAYERS then
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
    self.cooldown = self.cooldown - dt
end

return InfoBar