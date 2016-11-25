--
-- Date: 04.04.2016
--

local class = require "lib/middleclass"

local Player = class('Player', Character)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[print "nop"]] end

function Player:initialize(name, sprite, input, x, y, f)
    Character.initialize(self, name, sprite, input, x, y, f)
    self.type = "player"
end

function Player:drawShadow(l,t,w,h)
    if not self.isDisabled and CheckCollision(l, t, w, h, self.x-45, self.y-10, 90, 20) then
        if self.cool_down_death < 2 then
            love.graphics.setColor(0, 0, 0, 255 * math.sin(self.cool_down_death)) --4th is the shadow transparency
        else
            love.graphics.setColor(0, 0, 0, 255) --4th is the shadow transparency
        end
        local spr = self.sprite
        local sc = spr.def.animations[spr.cur_anim][spr.cur_frame]
        local shadowAngle = -stage.shadowAngle * spr.flip_h
        love.graphics.draw (
            image_bank[spr.def.sprite_sheet], --The image
            sc.q, --Current frame of the current animation
            self.x + self.shake.x, self.y - 2 + self.z/6,
            0,
            spr.flip_h,
            -stage.shadowHeight,
            sc.ox, sc.oy,
            shadowAngle
        )
    end
end

return Player