--
-- Date: 25.03.2016
--

local class = require "lib/middleclass"

local InfoBar = class("InfoBar")

local v_g = 44 --vertical gap between bars
local v_m = 32 --vert margin from the top
local h_m = 32 --horizontal margin
local bar_width = 240
local bar_height = 16
local icon_width = 16
local icon_height = 16
local screen_width = 640
local norm_color = {255,200,40}
local decr_color = {249,187,0} --{240,60,30}
local incr_color = {255,217,102} --{140,240,50}
local lost_color = {164,0,0}
local got_color = {0,164,0}
local transp_bg = 200
local transp_bar = 255
local transp_icon = 255
local transp_lost = 255
local transp_got = 255
local transp_name = 255

local MAX_PLAYERS = 2

local bars_coords = {
    { x = h_m, y = v_m + 0 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 0 * v_g, face = -1 },
    { x = h_m, y = v_m + 1 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 1 * v_g, face = -1 },
    { x = h_m, y = v_m + 2 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 2 * v_g, face = -1 },
    { x = h_m, y = v_m + 3 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 3 * v_g, face = -1 },
    { x = h_m, y = v_m + 4 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 4 * v_g, face = -1 },
    { x = h_m, y = v_m + 5 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 5 * v_g, face = -1 },
}

local function calcBarWidth(self)
    if self.max_hp < 100 then
        return self.max_hp * 2.4
    end
    return bar_width
end

local function calcTransparency(cd)
    if cd < 1 then
        return cd
    end
    return 1
end

function InfoBar:initialize(source)
    self.source = source
    self.name = source.name or "Unknown"
    self.note = source.note or "EXTRA TEXT"
    self.color = {155,110,20}
    self.cool_down = 0
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
        self.icon_sprite = source.sprite.def.sprite_sheet
        self.icon_q = source.sprite.def.animations["icon"][1].q  --quad
        self.icon_color = source.color
        self.max_hp = source.max_hp
        self.hp = 1
        self.old_hp = 1
        self.x, self.y, self.face = bars_coords[self.id].x, bars_coords[self.id].y, bars_coords[self.id].face
    end
end

function InfoBar:setAttacker(attacker_source)
    local id = -1
    if attacker_source.isThrown then
        id = attacker_source.thrower_id.id
    else
        id = attacker_source.id
    end
    if id <= MAX_PLAYERS and self.id > MAX_PLAYERS then
        self.x, self.y, self.face = bars_coords[id].x, bars_coords[id].y + v_g, bars_coords[id].face
    end
    return self
end

function InfoBar:setPicker(picker_source)
    id = picker_source.id
    if id <= MAX_PLAYERS then
        self.x, self.y, self.face = bars_coords[id].x, bars_coords[id].y + v_g, bars_coords[id].face
    end
    self.cool_down = 3
    return self
end
function InfoBar:draw_enemy_bar(l,t,w,h)
    local cool_down_transparency = calcTransparency(self.cool_down)
    local transp_bg = transp_bg * cool_down_transparency
    local transp_bar = transp_bar * cool_down_transparency
    local transp_icon = transp_icon  * cool_down_transparency
    local transp_lost = transp_lost * cool_down_transparency
    local transp_got = transp_got * cool_down_transparency
    local transp_name = transp_name * cool_down_transparency
    love.graphics.setColor(0, 50, 50, transp_bg)
    love.graphics.rectangle("fill", l + self.x, t + self.y - icon_height - 1, icon_width + 2, icon_height + 2 )
    love.graphics.rectangle("fill", l + self.x, t + self.y , calcBarWidth(self), bar_height )
    if self.old_hp > 0 then
        if self.source.hp > self.hp then
            love.graphics.setColor(got_color[1], got_color[2], got_color[3], transp_got)
        else
            love.graphics.setColor(lost_color[1], lost_color[2], lost_color[3], transp_lost)
        end
        love.graphics.rectangle("fill", l + self.x + 2, t + self.y + 2, (calcBarWidth(self) - 2) * self.old_hp / self.max_hp, (bar_height - 4) )
    end
    if self.hp > 0 then
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], transp_bar)
        love.graphics.rectangle("fill", l + self.x + 2, t + self.y + 2, (calcBarWidth(self) - 2) * self.hp / self.max_hp, (bar_height - 4) )
    end

    love.graphics.setColor(self.icon_color.r, self.icon_color.g, self.icon_color.b, transp_icon)
    love.graphics.draw (
        image_bank[self.icon_sprite],
        self.icon_q, --Current frame of the current animation
        l + self.x + 1, t + self.y - icon_height
    )
    love.graphics.setColor(255, 255, 255, transp_name)
    love.graphics.print(self.name, l + self.x + icon_width + 4, t + self.y-13)
end

function InfoBar:draw_item_bar(l,t,w,h)
    local cool_down_transparency = calcTransparency(self.cool_down)
    local transp_icon = transp_icon  * cool_down_transparency
    local transp_name = transp_name * cool_down_transparency

    love.graphics.setColor(0, 50, 50, transp_bg)
    love.graphics.rectangle("fill", l + self.x, t + self.y - icon_height - 1, icon_width + 2, icon_height + 2 )

    love.graphics.setColor(self.icon_color.r, self.icon_color.g, self.icon_color.b, transp_icon)
    love.graphics.draw (
        self.icon_sprite,
        self.icon_q, --Current frame of the current animation
        l + self.x + 1, t + self.y - icon_height
    )
    love.graphics.setColor(255, 255, 255, transp_name)
    love.graphics.print(self.name.." "..self.note, l + self.x + icon_width + 4, t + self.y-13)
end

function InfoBar:draw(l,t,w,h)
--    if self.id > MAX_PLAYERS and self.cool_down <= 0 then
--        return
--    end
    if self.cool_down <= 0 then
        return
    end
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

    if self.source.type == "item" then
        if self.cool_down > 0 then
            self.cool_down = self.cool_down - dt
        end
    else
        if self.hp > 0 then
            self.cool_down = 3
        else
            if self.cool_down > 0 then
                self.cool_down = self.cool_down - dt
            end
        end
    end
end

function InfoBar:drawShadow(l,t,w,h)
end

return InfoBar
