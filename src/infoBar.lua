--
-- Date: 25.03.2016
--

local class = require "lib/middleclass"

local InfoBar = class("InfoBar")

local v_g = 39 --vertical gap between bars
local v_m = 13 --vert margin from the top
local h_m = 42 --horizontal margin
local bar_width = 150
local bar_width_with_lr = bar_width + 6
local bar_height = 16
local icon_width = 40
local icon_height = 17
local screen_width = 640
local norm_color = {230,200,30}
local losing_color = {210,100,30}
local lost_color = {180,35,30}
local got_color = {40,160,20}
local bar_yellow_color = {230,200,30}
local bar_top_bottom_smooth_color = {100,50,50}
local transp_bg = 255

local MAX_PLAYERS = GLOBAL_SETTING.MAX_PLAYERS

local bars_coords = {   --for players only 1..MAX_PLAYERS
    { x = h_m + 5, y = v_m + 0 * v_g },
    { x = math.floor(screen_width / 2 - bar_width_with_lr/2) + 4, y = v_m + 0 * v_g },
    { x = math.floor(screen_width - bar_width_with_lr - h_m + 3), y = v_m + 0 * v_g }
}

local function calcBarWidth(self)
    if self.max_hp < 100 and self.source.lives <= 1 then
        return math.floor((self.max_hp * bar_width) / 100)
    end
    return bar_width
end

local function calcTransparency(cd)
    if cd < 0 then
        return -cd * 4
    end
    return cd * 4
end

local function printWithShadow(text, x, y)
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(0, 0, 0, transp_bg)
    love.graphics.print(text, x + 1, y - 1)
    love.graphics.setColor(r, g, b, a)
    love.graphics.print(text, x, y)
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
    self.color = norm_color
    self.cool_down = 1
    self.id = self.source.id
    if source.type == "item" then
        self.icon_sprite = source.icon_sprite
        self.icon_q = source.icon_q  --quad
        self.icon_color = { r= 255, g = 255, b = 255, a = 255 }
        self.max_hp = 20
        self.hp = 1
        self.old_hp = 1
        self.x, self.y = 0, 0
    else --Player / enemy / object
        if source.type == "player" then
            self.score = -1
            self.displayed_score = ""
        end
        self.icon_sprite = source.sprite.def.sprite_sheet
        self.icon_q = source.sprite.def.animations["icon"][1].q  --quad
        self.icon_color = source.color
        self.max_hp = source.max_hp
        self.hp = 1
        self.old_hp = 1
        if self.id <= MAX_PLAYERS then
            self.x, self.y = bars_coords[self.id].x, bars_coords[self.id].y
        else
            self.x, self.y = 0, 0
        end
    end
end

function InfoBar:setAttacker(attacker_source)
    local id = -1
    if attacker_source.isThrown then
        id = attacker_source.thrower_id.id
    else
        id = attacker_source.id
    end
    self.cool_down = 3
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
    self.cool_down = 3
    return self
end

local cool_down_transparency = 0
function InfoBar:draw_enemy_bar(l,t,w,h)
    if self.source.id > GLOBAL_SETTING.MAX_PLAYERS then
        cool_down_transparency = calcTransparency(self.cool_down)
    else
        cool_down_transparency = calcTransparency(3)
    end
    transp_bg = 255 * cool_down_transparency
    love.graphics.setColor(lost_color[1], lost_color[2], lost_color[3], transp_bg)
    slantedRectangle2( l + self.x + 4, t + self.y + icon_height + 6, calcBarWidth(self) - 6 , bar_height - 6 )
    love.graphics.setColor(255, 255, 255, transp_bg)
    if self.source.shader then
        love.graphics.setShader(self.source.shader)
    end
    love.graphics.draw (
        image_bank[self.icon_sprite],
        self.icon_q, --Current frame of the current animation
        l + self.x + self.source.shake.x, t + self.y
    )
    if self.source.shader then
        love.graphics.setShader()
    end
    if self.old_hp > 0 then
        if self.source.hp > self.hp then
            love.graphics.setColor(got_color[1], got_color[2], got_color[3], transp_bg)
        else
            love.graphics.setColor(losing_color[1], losing_color[2], losing_color[3], transp_bg)
        end
        slantedRectangle2( l + self.x + 4, t + self.y + icon_height + 6, (calcBarWidth(self) - 6) * self.old_hp / self.max_hp , bar_height - 6 )
    end
    if self.hp > 0 then
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], transp_bg)
        slantedRectangle2( l + self.x + 4, t + self.y + icon_height + 6, (calcBarWidth(self) - 6) * self.hp / self.max_hp , bar_height - 6 )
    else
        love.graphics.setColor(255,255,255, 255 * math.sin(self.cool_down*20 + 17) * cool_down_transparency)
        love.graphics.draw (
            gfx.ui.dead_icon.sprite,
            gfx.ui.dead_icon.q,
            l + self.x + self.source.shake.x + 3, t + self.y - 2
        )
    end
    love.graphics.setColor(255,255,255, transp_bg)
    love.graphics.draw (
        gfx.ui.middle_slant.sprite,
        gfx.ui.middle_slant.q,
        l + self.x - 4 + 12, t + self.y + icon_height + 3, 0, calcBarWidth(self) / 4 - 4, 1
    )
    love.graphics.draw (
        gfx.ui.left_slant.sprite,
        gfx.ui.left_slant.q,
        l + self.x - 4, t + self.y + icon_height + 3
    )
    love.graphics.draw (
        gfx.ui.right_slant.sprite,
        gfx.ui.right_slant.q,
        l + self.x - 4 - 6 + calcBarWidth(self), t + self.y + icon_height + 3
    )
    if self.score ~= self.source.score then
        self.score = self.source.score
        self.displayed_score = string.format("%06d", self.score)
    end
    love.graphics.setColor(bar_top_bottom_smooth_color[1], bar_top_bottom_smooth_color[2], bar_top_bottom_smooth_color[3], math.min(255,transp_bg) - 127)
    love.graphics.rectangle('fill', l + self.x + 4, t + self.y + icon_height + 6, calcBarWidth(self) - 6, 1)
    love.graphics.rectangle('fill', l + self.x + 0, t + self.y + icon_height + bar_height - 1, calcBarWidth(self) - 6, 1)

    local font = gfx.font.arcade3
    love.graphics.setFont(font)
    love.graphics.setColor(255, 255, 255, transp_bg)
    printWithShadow(self.name, l + self.x + self.source.shake.x + icon_width + 4 + 0, t + self.y + 9 - 0)
    if self.source.type == "player" or self.source.lives > 1 then
        local c = GLOBAL_SETTING.PLAYERS_COLORS[self.source.id]
        if c then
            love.graphics.setColor(c[1],c[2],c[3], transp_bg)
        end
        printWithShadow(self.source.pid, l + self.x + self.source.shake.x + icon_width + 4 + 0, t + self.y - 1 - 0)
        love.graphics.setColor(bar_yellow_color[1], bar_yellow_color[2], bar_yellow_color[3], transp_bg)
        printWithShadow(self.displayed_score, l + self.x + self.source.shake.x + icon_width + 2 + 34 + 0, t + self.y - 1 - 0)
        love.graphics.setColor(255, 255, 255, transp_bg)
        printWithShadow("x", l + self.x + self.source.shake.x + icon_width + 2 + 85 + 0, t + self.y + 9 - 0)
        local font = gfx.font.arcade3x2
        love.graphics.setFont(font)
        printWithShadow(self.source.lives, l + self.x + self.source.shake.x + icon_width + 2 + 94 + 0, t + self.y + 1 - 0)
    end
end

function InfoBar:draw_item_bar(l,t,w,h)
    local cool_down_transparency = calcTransparency(self.cool_down)
    transp_bg = 255 * cool_down_transparency

    love.graphics.setColor(self.icon_color.r, self.icon_color.g, self.icon_color.b, transp_bg)
    love.graphics.draw (
        self.icon_sprite,
        self.icon_q, --Current frame of the current animation
        l + self.x + icon_height/4, t + self.y + 4
    )
    local font = gfx.font.arcade3
    love.graphics.setFont(font)
    love.graphics.setColor(255, 255, 255, transp_bg)
    printWithShadow(self.name, l + self.x + icon_width + 4 + 0, t + self.y + 9 - 0)
    love.graphics.setColor(bar_yellow_color[1], bar_yellow_color[2], bar_yellow_color[3], transp_bg)
    printWithShadow(self.note, l + self.x + icon_width + 2 + (#self.name+1)*8 + 0, t + self.y + 9 - 0)
end

function InfoBar:draw(l,t,w,h)
    if self.cool_down <= 0 and self.source.id > GLOBAL_SETTING.MAX_PLAYERS then
        return
    end
    if self.source.type == "item" then
        self:draw_item_bar(l,t,w,h)
    else
        self:draw_enemy_bar(l,t,w,h)
    end
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
        self.color[1] = norm_n(self.color[1],norm_color[1],10)
        self.color[2] = norm_n(self.color[2],norm_color[2],10)
        self.color[3] = norm_n(self.color[3],norm_color[3],10)
    elseif self.hp < self.source.hp then
        self.old_hp = self.source.hp
        self.color[1] = norm_n(self.color[1],norm_color[1],10)
        self.color[2] = norm_n(self.color[2],norm_color[2],10)
        self.color[3] = norm_n(self.color[3],norm_color[3],10)
    else
        self.color[1] = norm_n(self.color[1],norm_color[1])
        self.color[2] = norm_n(self.color[2],norm_color[2])
        self.color[3] = norm_n(self.color[3],norm_color[3])
        self.old_hp = self.hp
    end
    self.cool_down = self.cool_down - dt
end

function InfoBar:drawShadow(l,t,w,h)
end

return InfoBar