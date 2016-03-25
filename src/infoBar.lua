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

        love.graphics.setColor(255, 80, 80, 200)
        if self.hp > 0 then
            love.graphics.rectangle("fill", l + self.x + 1, t + self.y +1, (bar_width -2) * self.hp / self.max_hp, 6 )
        end

        love.graphics.setColor(255, 255, 255, 200)
        love.graphics.print(self.name, l + self.x, t + self.y-13)
    else
        --right side
        love.graphics.setColor(0, 50, 50, 200)
        love.graphics.rectangle("fill", l + self.x, t + self.y, bar_width, bar_height )

        love.graphics.setColor(255, 80, 80, 200)
        if self.hp > 0 then
            love.graphics.rectangle("fill", l + self.x + 1, t + self.y +1, (bar_width -2) * self.hp / self.max_hp, 6 )
        end

        love.graphics.setColor(255, 255, 255, 200)
        love.graphics.print(self.name, l + self.x, t + self.y-13)
    end
end

function InfoBar:update(dt)
    if dt % 2 then
        if self.hp > self.source.hp then
            self.hp = self.hp - 1
        elseif self.hp < self.source.hp then
            if self.hp < self.max_hp then
                self.hp = self.hp + 1
            end
        end
    end
end

function InfoBar:drawShadow(l,t,w,h)
end

return InfoBar
