local class = require "lib/middleclass"
local InfoBar = class("InfoBar")

local printWithShadow = printWithShadow

local v_g = 39 --vertical gap between bars
local v_m = 13 --vert margin from the top
local h_m = 42 --horizontal margin
local bar_width = 150
local bar_width_with_lr = bar_width + 8
local bar_height = 16
local icon_width = 40
local icon_height = 17
local screen_width = 640
local norm_color = {244,210,14}
local losing_color = {228,102,21}
local lost_color = {199,32,26}
local got_color = {34,172,11}
local bar_top_bottom_smooth_color = {100,50,50}
local transp_bg = 255
local cool_down_transparency = 0
local MAX_PLAYERS = GLOBAL_SETTING.MAX_PLAYERS

local bars_coords = {   --for players only 1..MAX_PLAYERS
    { x = h_m + 4, y = v_m + 0 * v_g },
    { x = math.floor(screen_width / 2 - bar_width_with_lr / 2) + 2, y = v_m + 0 * v_g },
    { x = math.floor(screen_width - bar_width_with_lr - h_m + 0), y = v_m + 0 * v_g }
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
    self.source:initFaceIcon(self)
    self.hp = 1
    self.old_hp = 1
    self.max_hp = source.max_hp
    if source.type == "player" then
        self.score = -1
        self.displayed_score = ""
    end
    if self.id <= MAX_PLAYERS then
        self.x, self.y = bars_coords[self.id].x, bars_coords[self.id].y
    else
        self.x, self.y = 0, 0
    end
    local _, _, w, _ = self.q:getViewport( )
    self.icon_x_offset = math.floor((38 - w)/2)
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

function InfoBar:drawFaceIcon(l, t, transp_bg)
    self.icon_color[4] = transp_bg
    love.graphics.setColor( unpack( self.icon_color ) )
    if self.shader then
        love.graphics.setShader(self.shader)
    end
    self.source.drawFaceIcon(self, l + self.icon_x_offset + self.x - 2, t + self.y, transp_bg)
    if self.shader then
        love.graphics.setShader()
    end
end

function InfoBar:draw_dead_cross(l, t, transp_bg)
    if self.hp <= 0 then
        --    if not self.source:isAlive() then
        love.graphics.setColor(255,255,255, 255 * math.sin(self.cool_down*20 + 17) * cool_down_transparency)
        love.graphics.draw (
            gfx.ui.dead_icon.sprite,
            gfx.ui.dead_icon.q,
            l + self.x + self.source.shake.x + 1, t + self.y - 2
        )
    end
end

function InfoBar:draw_name_(l, t, transp_bg)
    love.graphics.setColor(255, 255, 255, transp_bg)
    printWithShadow(self.name, l + self.x + self.source.shake.x + icon_width + 2, t + self.y + 9,
        transp_bg)
    if self.source.type == "player" or self.source.lives > 1 then
        local c = GLOBAL_SETTING.PLAYERS_COLORS[self.source.id]
        if c then
            c[4] = transp_bg
            love.graphics.setColor(unpack( c ))
        end
        printWithShadow(self.source.pid, l + self.x + self.source.shake.x + icon_width + 2, t + self.y - 1,
            transp_bg)
        love.graphics.setColor(norm_color[1], norm_color[2], norm_color[3], transp_bg)
        printWithShadow(self.displayed_score, l + self.x + self.source.shake.x + icon_width + 34, t + self.y - 1,
            transp_bg)
        if self.source.lives >= 1 then
            love.graphics.setColor(255, 255, 255, transp_bg)
            printWithShadow("x", l + self.x + self.source.shake.x + icon_width + 91, t + self.y + 9,
                transp_bg)
            love.graphics.setFont(gfx.font.arcade3x2)
            if self.source.lives > 10 then
                printWithShadow("9+", l + self.x + self.source.shake.x + icon_width + 100, t + self.y + 1,
                    transp_bg)
            else
                printWithShadow(self.source.lives - 1, l + self.x + self.source.shake.x + icon_width + 100, t + self.y + 1,
                    transp_bg)
            end
        end
    end
end

function InfoBar:draw_lifebar(l, t, transp_bg)
    -- Normal lifebar
    lost_color[4] = transp_bg
    love.graphics.setColor( unpack( lost_color ) )
    slantedRectangle2( l + self.x + 4, t + self.y + icon_height + 6, calcBarWidth(self) , bar_height - 6 )

    if self.old_hp > 0 then
        if self.source.hp > self.hp then
            got_color[4] = transp_bg
            love.graphics.setColor( unpack( got_color ) )
        else
            losing_color[4] = transp_bg
            love.graphics.setColor( unpack( losing_color ) )
        end
        slantedRectangle2( l + self.x + 4, t + self.y + icon_height + 6, calcBarWidth(self)  * self.old_hp / self.max_hp , bar_height - 6 )
    end
    if self.hp > 0 then
        self.color[4] = transp_bg
        love.graphics.setColor( unpack( self.color ) )
        slantedRectangle2( l + self.x + 4, t + self.y + icon_height + 6, calcBarWidth(self) * self.hp / self.max_hp + 1, bar_height - 6 )
    end
    love.graphics.setColor(255,255,255, transp_bg)
    love.graphics.draw (
        gfx.ui.middle_slant.sprite,
        gfx.ui.middle_slant.q,
        l + self.x - 4 + 12, t + self.y + icon_height + 3, 0, (calcBarWidth(self) - 12) / 4, 1
    )
    love.graphics.draw (
        gfx.ui.left_slant.sprite,
        gfx.ui.left_slant.q,
        l + self.x - 4, t + self.y + icon_height + 3
    )
    love.graphics.draw (
        gfx.ui.right_slant.sprite,
        gfx.ui.right_slant.q,
        l + self.x - 4 + calcBarWidth(self), t + self.y + icon_height + 3
    )
    bar_top_bottom_smooth_color[4] = math.min(255,transp_bg) - 127
    love.graphics.setColor( unpack( bar_top_bottom_smooth_color ) )
    love.graphics.rectangle('fill', l + self.x + 4, t + self.y + icon_height + 6, calcBarWidth(self), 1)
    love.graphics.rectangle('fill', l + self.x + 0, t + self.y + icon_height + bar_height - 1, calcBarWidth(self), 1)
end

function InfoBar:draw_enemy_bar(l,t,w,h)
    local font = gfx.font.arcade3
    love.graphics.setFont(font)
    if self.source.id > GLOBAL_SETTING.MAX_PLAYERS then
        cool_down_transparency = calcTransparency(self.cool_down)
    else
        cool_down_transparency = calcTransparency(3)
    end
    transp_bg = 255 * cool_down_transparency
    local player_select_mode = self.source.player_select_mode
    if self.source.id <= GLOBAL_SETTING.MAX_PLAYERS
        and self.source.lives <= 0
    then
        love.graphics.setColor(255, 255, 255, transp_bg)
        if player_select_mode == 0 then
            -- wait press to use credit
            printWithShadow("CONTINUE x"..tonumber(credits), l + self.x + 2, t + self.y + 9,
                transp_bg)
            love.graphics.setColor(255,255,255, 200 + 55 * math.sin(self.cool_down*2 + 17))
            printWithShadow(self.source.pid .. " PRESS ATTACK (".. math.floor(self.source.cool_down) ..")", l + self.x + 2, t + self.y + 9 + 11,
                transp_bg)
        elseif player_select_mode == 1 then
            -- wait 1 sec before player select
            printWithShadow("CONTINUE x"..tonumber(credits), l + self.x + 2, t + self.y + 9,
                transp_bg)
        elseif player_select_mode == 2 then
            -- Select Player
            printWithShadow(self.source.name, l + self.x + self.source.shake.x + icon_width + 2, t + self.y + 9,
                transp_bg)
            local c = GLOBAL_SETTING.PLAYERS_COLORS[self.source.id]
            if c then
                c[4] = transp_bg
                love.graphics.setColor(unpack( c ))
            end
            printWithShadow(self.source.pid, l + self.x + self.source.shake.x + icon_width + 2, t + self.y - 1,
                transp_bg)
            --printWithShadow("<     " .. self.source.name .. "     >", l + self.x + 2 + math.floor(2 * math.sin(self.cool_down*4)), t + self.y + 9 + 11 )
            self:drawFaceIcon(l + self.source.shake.x, t, transp_bg)
            love.graphics.setColor(255,255,255, 200 + 55 * math.sin(self.cool_down*3 + 17))
            printWithShadow("SELECT PLAYER (".. math.floor(self.source.cool_down) ..")", l + self.x + 2, t + self.y + 19,
                transp_bg)
        elseif player_select_mode == 3 then
            -- Spawn selecterd player
            --printWithShadow(self.source.pid .. " GET READY!", l + self.x + 2, t + self.y + 9 )
        elseif player_select_mode == 4 then
            -- Game Over (too late)
            love.graphics.setColor(255,255,255, 200 + 55 * math.sin(self.cool_down*0.5 + 17))
            printWithShadow(self.source.pid .. " GAME OVER", l + self.x + 2, t + self.y + 9,
                transp_bg)
        end
    else
        -- Default draw
        if player_select_mode == 3 then
            -- Fade-in and drop down bar while player falls (respawns)
            transp_bg = 255 - self.source.z
            t = t - self.source.z / 2
        end
        self:draw_lifebar(l, t, transp_bg)
        self:drawFaceIcon(l + self.source.shake.x, t, transp_bg)
        self:draw_dead_cross(l, t, transp_bg)
        if self.score ~= self.source.score then
            self.score = self.source.score
            self.displayed_score = string.format("%06d", self.score)
        end
        self.source:drawTextInfo(l, t, transp_bg, self, icon_width, norm_color)
    end
end

function InfoBar:draw_loot_bar(l,t,w,h)
    local cool_down_transparency = calcTransparency(self.cool_down)
    transp_bg = 255 * cool_down_transparency
    self:drawFaceIcon(l, t, transp_bg)
    local font = gfx.font.arcade3
    love.graphics.setFont(font)
    love.graphics.setColor(255, 255, 255, transp_bg)
    printWithShadow(self.name, l + self.x + icon_width + 4 + 0, t + self.y + 9 - 0, transp_bg)
    norm_color[4] = transp_bg
    love.graphics.setColor( unpack( norm_color ) )
    printWithShadow(self.note, l + self.x + icon_width + 2 + (#self.name+1)*8 + 0, t + self.y + 9 - 0, transp_bg)
end

function InfoBar:draw(l,t,w,h)
    if self.cool_down <= 0 and self.source.id > GLOBAL_SETTING.MAX_PLAYERS then
        return
    end
    if self.source.type == "loot" then
        self:draw_loot_bar(l,t,w,h)
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

return InfoBar