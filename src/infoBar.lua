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
local screen_width = 640
local norm_color = {255,200,40}
local decr_color = {249,187,0} --{240,60,30}
local incr_color = {255,217,102} --{140,240,50}
local lost_color = {164,0,0}
local got_color = {0,164,0}
local transp_bg = 200
local transp_bar = 255
local transp_lost = 255
local transp_got = 255
local transp_name = 255

local bars_coords = {
    { x = h_m, y = v_m + 0 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 0 * v_g, face = -1 },
    { x = h_m, y = v_m + 1 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 1 * v_g, face = -1 },
    { x = h_m, y = v_m + 2 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 2 * v_g, face = -1 },
    { x = h_m, y = v_m + 3 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 3 * v_g, face = -1 },
    { x = h_m, y = v_m + 4 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 4 * v_g, face = -1 },
    { x = h_m, y = v_m + 5 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 5 * v_g, face = -1 },
}
function InfoBar:initialize(source, attacker_source)
    self.source = source
    self.icon = nil --icon? TODO
    self.name = source.name or "Unknown"
    self.extra_text = "EXTRA TEXT"
    self.hp = 1
    self.old_hp = 1
    self.color = {155,110,20}
    self.max_hp = 100
    self.id = self.source.id
    --print("src id", self.id)
    if attacker_source then
        --victim of the corresponded player
        self.x, self.y, self.face = bars_coords[attacker_source.id].x, bars_coords[attacker_source.id].y + v_g, bars_coords[attacker_source.id].face
    else
        --player
        self.x, self.y, self.face = bars_coords[self.id].x, bars_coords[self.id].y, bars_coords[self.id].face
    end
end

function InfoBar:setAttacker(attacker_source)
    self.x, self.y, self.face = bars_coords[attacker_source.id].x, bars_coords[attacker_source.id].y + v_g, bars_coords[attacker_source.id].face
    return self
end

function InfoBar:draw(l,t,w,h)
    if self.face == 1 then
        --left side
        love.graphics.setColor(0, 50, 50, transp_bg)
        love.graphics.rectangle("fill", l + self.x, t + self.y, bar_width, bar_height )
        if self.old_hp > 0 then
            if self.source.hp > self.hp then
                love.graphics.setColor(got_color[1], got_color[2], got_color[3], transp_got)
            else
                love.graphics.setColor(lost_color[1], lost_color[2], lost_color[3], transp_lost)
            end
            love.graphics.rectangle("fill", l + self.x + 2, t + self.y + 2, (bar_width - 2) * self.old_hp / self.max_hp, (bar_height - 4) )
        end
        if self.hp > 0 then
            love.graphics.setColor(self.color[1], self.color[2], self.color[3], transp_bar)
            love.graphics.rectangle("fill", l + self.x + 2, t + self.y + 2, (bar_width - 2) * self.hp / self.max_hp, (bar_height - 4) )
        end

        love.graphics.setColor(255, 255, 255, transp_name)
        love.graphics.print(self.name, l + self.x, t + self.y-13)
    else
        --right side
        love.graphics.setColor(0, 50, 50, transp_bg)
        love.graphics.rectangle("fill", l + self.x, t + self.y, bar_width, bar_height )
        if self.old_hp > 0 then
            if self.source.hp > self.hp then
                love.graphics.setColor(got_color[1], got_color[2], got_color[3], transp_got)
            else
                love.graphics.setColor(lost_color[1], lost_color[2], lost_color[3], transp_lost)
            end
            love.graphics.rectangle("fill", l + self.x + 2, t + self.y + 2, (bar_width -2) * self.old_hp / self.max_hp, (bar_height - 4) )
        end
        if self.hp > 0 then
            love.graphics.setColor(self.color[1], self.color[2], self.color[3], transp_bar)
            love.graphics.rectangle("fill", l + self.x + 2, t + self.y + 2, (bar_width -2) * self.hp / self.max_hp, (bar_height - 4) )
        end

        love.graphics.setColor(255, 255, 255, transp_name)
        love.graphics.print(self.name, l + self.x, t + self.y-13)
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
end

function InfoBar:drawShadow(l,t,w,h)
end

return InfoBar
