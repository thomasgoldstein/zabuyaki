--
-- Date: 25.03.2016
--

local class = require "lib/middleclass"

local InfoBar = class("InfoBar")

local v_g = 24 --vertical gap between bars
local v_m = 16 --vert margin from the top
local h_m = 16 --horizontal margin
local bar_width = 116
local bar_height = 8
local screen_width = 320
local norm_color = {255,210,77}
local decr_color = {255,0,0}
local incr_color = {255,233,164}
local lose_color = {0,0,0}

local bars_coords = {
    { x = h_m, y = v_m + 0 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 0 * v_g, face = -1 },
    { x = h_m, y = v_m + 1 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 1 * v_g, face = -1 },
    { x = h_m, y = v_m + 2 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 2 * v_g, face = -1 },
    { x = h_m, y = v_m + 3 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 3 * v_g, face = -1 },
    { x = h_m, y = v_m + 4 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 4 * v_g, face = -1 },
    { x = h_m, y = v_m + 5 * v_g, face = 1 }, { x = screen_width - bar_width - h_m, y = v_m + 5 * v_g, face = -1 },
}
function InfoBar:initialize(source)
    self.source = source
    self.icon = nil --icon? TODO
    self.name = source.name or "Unknown"
    self.extra_text = "EXTRA TEXT"
    self.hp = 1
    self.color = {155,110,20}
    self.max_hp = 100
    self.id = self.source.id
    print("src id", self.id)
    self.x, self.y, self.face = bars_coords[self.id].x, bars_coords[self.id].y, bars_coords[self.id].face
end

function InfoBar:draw(l,t,w,h)
    if self.face == 1 then
        --left side
        love.graphics.setColor(0, 50, 50, 200)
        love.graphics.rectangle("fill", l + self.x, t + self.y, bar_width, bar_height )


        if self.hp > 0 then
            love.graphics.setColor(self.color[1], self.color[2], self.color[3], 200)
            love.graphics.rectangle("fill", l + self.x + 1, t + self.y +1, (bar_width -2) * self.hp / self.max_hp, 6 )
        end

        love.graphics.setColor(255, 255, 255, 200)
        love.graphics.print(self.name, l + self.x, t + self.y-13)
    else
        --right side
        love.graphics.setColor(0, 50, 50, 200)
        love.graphics.rectangle("fill", l + self.x, t + self.y, bar_width, bar_height )

        if self.hp > 0 then
            love.graphics.setColor(self.color[1], self.color[2], self.color[3], 200)
            love.graphics.rectangle("fill", l + self.x + 1, t + self.y +1, (bar_width -2) * self.hp / self.max_hp, 6 )
        end

        love.graphics.setColor(255, 255, 255, 200)
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
        self.color[1] = norm_n(self.color[1],incr_color[1],10)
        self.color[2] = norm_n(self.color[2],incr_color[2],10)
        self.color[3] = norm_n(self.color[3],incr_color[3],10)
    else
        self.color[1] = norm_n(self.color[1],norm_color[1])
        self.color[2] = norm_n(self.color[2],norm_color[2])
        self.color[3] = norm_n(self.color[3],norm_color[3])
    end
end

function InfoBar:drawShadow(l,t,w,h)
end

return InfoBar
