--
-- Date: 25.03.2016
--

local class = require "lib/middleclass"

local InfoBar = class("InfoBar")

local v_g = 40 --vertical gap between bars
local v_m = 24 --vert margin from the top
local h_m = 48 --horizontal margin
local bar_width = 120
local bar_height = 16
local icon_width = 32
local icon_height = 24
local screen_width = 640
local norm_color = {230,200,30}
local decr_color = norm_color --{249,187,0}
local incr_color = norm_color --{255,217,102}
local lost_color = {210,100,30}
local missing_color = {180,35,30}
local got_color = {40,160,20}
local transp_bg = 200
local transp_bar = 255
local transp_icon = 255
local transp_lost = 255
local transp_missing = 255
local transp_got = 255
local transp_name = 255

local MAX_PLAYERS = GLOBAL_SETTING.MAX_PLAYERS

local max_bar_width = bar_width + icon_width + icon_height/2 + bar_height/2

local bars_coords = {   --for players only 1..MAX_PLAYERS
    { x = h_m, y = v_m + 0 * v_g, face = 1 },
    { x = screen_width - max_bar_width - h_m/3, y = v_m + 0 * v_g, face = 11 },
    { x = screen_width / 2 - max_bar_width/2 + icon_width/2, y = v_m + 0 * v_g, face = 1 }
}

local function calcBarWidth(self)
    if self.max_hp < 100 then
        return (self.max_hp * bar_width) / 100
    end
    return bar_width
end

local function calcTransparency(cd)
--    if cd < 0.25 then
--        return cd * 4
--    end
--    return 1
    if cd < 0 then
        return -cd * 4
    end
    return cd * 4
end

local function drawSBar(x, y, width, height, shift_x)
    love.graphics.polygon('fill', x, y, x + width , y,
            x + width - shift_x, y + height, x - shift_x, y + height)
end

function InfoBar:initialize(source)
    self.source = source
    self.name = source.name or "Unknown"
    self.note = source.note or "EXTRA TEXT"
    self.color = {155,110,20}
    self.cool_down = 1
    self.id = self.source.id
    if source.type == "item" then
        self.icon_sprite = source.icon_sprite
        self.icon_q = source.icon_q  --quad
        self.icon_color = { r= 255, g = 255, b = 255, a = 255 }
        self.max_hp = 20
        self.hp = 1
        self.old_hp = 1
        self.x, self.y, self.face = 0, 0, 1
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
            self.x, self.y, self.face = bars_coords[self.id].x, bars_coords[self.id].y, bars_coords[self.id].face
        else
            self.x, self.y, self.face = 0, 0, 1
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
        self.x, self.y, self.face = bars_coords[id].x, bars_coords[id].y + v_g, bars_coords[id].face
        return self
    end
    return nil
end

function InfoBar:setPicker(picker_source)
    local id = picker_source.id
    if id <= MAX_PLAYERS then
        self.x, self.y, self.face = bars_coords[id].x, bars_coords[id].y + v_g, bars_coords[id].face
    end
    self.cool_down = 3
    return self
end
function InfoBar:draw_enemy_bar(l,t,w,h)
    local cool_down_transparency = 1
    if self.source.id > GLOBAL_SETTING.MAX_PLAYERS then
        cool_down_transparency = calcTransparency(self.cool_down)
    end
    local transp_bg = transp_bg * cool_down_transparency
    local transp_bar = transp_bar * cool_down_transparency
    local transp_icon = transp_icon  * cool_down_transparency
    local transp_lost = transp_lost * cool_down_transparency
    local transp_missing = transp_missing * cool_down_transparency
    local transp_got = transp_got * cool_down_transparency
    local transp_name = transp_name * cool_down_transparency
    love.graphics.setColor(0, 50, 50, transp_bg)
    drawSBar(l + self.x, t + self.y, icon_width + 2, icon_height + 2, (icon_height + 2)/2)
    drawSBar(l + self.x + icon_width + 2, t + self.y, calcBarWidth(self), bar_height, bar_height/2)
    love.graphics.setColor(missing_color[1], missing_color[2], missing_color[3], transp_missing)
    drawSBar(l + self.x + icon_width + 4, t + self.y + 2, calcBarWidth(self) - 6, bar_height - 4, (bar_height - 4)/2)

    love.graphics.setColor(255, 255, 255, transp_icon)
    if self.source.shader then
        love.graphics.setShader(self.source.shader)
    end
    love.graphics.draw (
        image_bank[self.icon_sprite],
        self.icon_q, --Current frame of the current animation
        l + self.x + self.source.shake.x + 6 - icon_width/2, t + self.y + 1
    )
    if self.source.shader then
        love.graphics.setShader()
    end

    if self.old_hp > 0 then
        if self.source.hp > self.hp then
            love.graphics.setColor(got_color[1], got_color[2], got_color[3], transp_got)
        else
            love.graphics.setColor(lost_color[1], lost_color[2], lost_color[3], transp_lost)
        end
        drawSBar(l + self.x + icon_width + 4, t + self.y + 2, (calcBarWidth(self) - 6) * self.old_hp / self.max_hp, bar_height - 4, (bar_height - 4)/2 )
    end
    if self.hp > 0 then
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], transp_bar)
        drawSBar(l + self.x + icon_width + 4, t + self.y + 2, (calcBarWidth(self) - 6) * self.hp / self.max_hp, bar_height - 4, (bar_height - 4)/2 )
    else
        love.graphics.setColor(255,255,255, 255 * math.sin(self.cool_down*10) * cool_down_transparency)
        love.graphics.draw (
            gfx.ui.dead_icon.sprite,
            gfx.ui.dead_icon.q,
            l + self.x + self.source.shake.x + 6 - icon_width/2, t + self.y + 1
        )
        --love.graphics.rectangle("line", l + self.x + self.source.shake.x + 6 - icon_width/2, t + self.y + 1, 32, 24)
    end

    love.graphics.setColor(255, 255, 255, transp_name)
    love.graphics.print(self.name, l + self.x + self.source.shake.x + icon_width - bar_height + 12, t + self.y + bar_height)
    if self.source.type == "player" then
        love.graphics.print(self.source.pid, l + self.x, t + self.y - 9)
        if self.score ~= self.source.score then
            self.score = self.source.score
            self.displayed_score = string.format("%06d", self.score)
        end
        love.graphics.print(self.displayed_score, l + self.x + icon_width, t + self.y - 9)
    end
end

function InfoBar:draw_item_bar(l,t,w,h)
    local cool_down_transparency = calcTransparency(self.cool_down)
    local transp_icon = transp_icon  * cool_down_transparency
    local transp_name = transp_name * cool_down_transparency

    love.graphics.setColor(0, 50, 50, transp_bg)
    local font = gfx.font.arcade3
    love.graphics.setFont(font)
    local bar_width = math.max(font:getWidth(self.name), font:getWidth(self.note))
    drawSBar(l + self.x, t + self.y, icon_width*2 + bar_width - 4, icon_height + 2, (icon_height + 2)/2)

    love.graphics.setColor(self.icon_color.r, self.icon_color.g, self.icon_color.b, transp_icon)
    love.graphics.draw (
        self.icon_sprite,
        self.icon_q, --Current frame of the current animation
        l + self.x + icon_height/4, t + self.y + 4
    )
    love.graphics.setColor(255, 255, 255, transp_name)
    love.graphics.print(self.name, l + self.x + icon_width + 8, t + self.y + 4)
    love.graphics.print(self.note, l + self.x + icon_width + 8, t + self.y + 14)
end

function InfoBar:draw(l,t,w,h)
    if self.cool_down <= 0 and self.source.id > GLOBAL_SETTING.MAX_PLAYERS then
        return
    end
    love.graphics.setFont(gfx.font.arcade3)
    if self.face == 1 then
        --left side
        if self.source.type == "item" then
            self:draw_item_bar(l,t,w,h)
        else
            self:draw_enemy_bar(l,t,w,h)
        end
    else
        --right side
        if self.source.type == "item" then
            self:draw_item_bar(l,t,w,h)
        else
            self:draw_enemy_bar(l,t,w,h)
        end
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
        self.color[1] = norm_n(self.color[1],decr_color[1],10)
        self.color[2] = norm_n(self.color[2],decr_color[2],10)
        self.color[3] = norm_n(self.color[3],decr_color[3],10)
    elseif self.hp < self.source.hp then
        self.old_hp = self.source.hp
        self.color[1] = norm_n(self.color[1],incr_color[1],10)
        self.color[2] = norm_n(self.color[2],incr_color[2],10)
        self.color[3] = norm_n(self.color[3],incr_color[3],10)
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