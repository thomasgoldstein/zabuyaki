--
-- Date: 20.06.2016
--
heroSelectState = {}

local time = 0
local screen_width = 640
local screen_height = 480

local left_item_offset  = 6
local top_item_offset  = 6
local item_width_margin = left_item_offset * 2
local item_height_margin = top_item_offset * 2 - 2

local portrait_width = 120
local portrait_height = 200
local portrait_margin = 40

--sprites and shaders
local rick_spr = GetInstance("res/rick.lua")
SetSpriteAnim(rick_spr,"stand")
rick_spr.size_scale = 2

local sh_rick2 = love.graphics.newShader(sh_replace_3_colors)
sh_rick2:sendColor("colors", {181, 81, 23, 255},  {122, 54, 15, 255},  {56, 27, 28, 255})
sh_rick2:sendColor("newColors", {77,111,158, 255},  {49,73,130, 255},  {28,42,73, 255})   --Blue

local sh_rick3 = love.graphics.newShader(sh_replace_3_colors)
sh_rick3:sendColor("colors", {181, 81, 23, 255},  {122, 54, 15, 255},  {56, 27, 28, 255})
sh_rick3:sendColor("newColors", {111,77,158, 255},  {73,49,130, 255},  {42,28,73, 255}) --Purple

--{name, shader, text color P1}..
local heroes = {
    {
        {name = "RICK", shader = nil, color = {255, 255, 255, 255}}, --{181, 81, 23, 255}
        {name = "RICH", shader = sh_rick2, color = {77,111,158, 255}},
        {name = "RICKY", shader = sh_rick3, color = {111,77,158, 255}},
        hero = Rick,
        sprite = rick_spr,
        x = screen_width / 2 - portrait_width - portrait_margin,
        y = 400,
        sy = 420,
        ny = 240,
        py = 32
    },
    {
        {name = "CHAI", shader = sh_rick3, color = {111,77,158, 255}},
        {name = "CHI", shader = sh_rick2, color = {77,111,158, 255}},
        {name = "CHE", shader = nil, color = {255, 255, 255, 255} },
        hero = Rick,
        sprite = rick_spr,
        x = screen_width / 2,
        y = 400,
        sy = 420,
        ny = 240,
        py = 32
    },
    {
        {name = "KISA", shader = nil, color = {255, 255, 255, 255}},
        {name = "KYSA", shader = sh_rick3, color = {111,77,158, 255} },
        {name = "KEESA", shader = sh_rick2, color = {77,111,158, 255} },
        hero = Rick,
        sprite = rick_spr,
        x = screen_width / 2 + portrait_width + portrait_margin,
        y = 400,
        sy = 420,
        ny = 240,
        py = 32
    }
}
local players = {
    {name = "P1", pos = 1, visible = true, confirmed = false},
    {name = "P2", pos = 1, visible = false, confirmed = false},
    {name = "P3", pos = 1, visible = false, confirmed = false}
}

local function selected_heroes()
--P1 has the hero original color
    local s1 = {players[1].pos, 1 }
    local s2 = {players[2].pos, 1 }
    local s3 = {players[3].pos, 1 }
    --adjust P2
    if s2[1] == s1[1] then
        s2[2] = s1[2] + 1
    end
    --adjust P3
    if s3[1] == s2[1] then
        s3[2] = s2[2] + 1
    elseif s3[1] == s1[1] then
        s3[2] = s1[2] + 1
    end
    --print(s1[1],s1[2],s2[1],s2[2],s3[1],s3[2])
    return {s1, s2, s3}
end

local function all_confirmed()
    --Active players confirmed their choice
    return players[1].confirmed
            and
            ((players[2].visible and players[2].confirmed)
                    or not players[2].visible)
            and
            ((players[3].visible and players[3].confirmed)
                    or not players[3].visible)
end

local function all_unconfirmed()
    --Active players confirmed their choice
    return not (players[1].confirmed or players[2].confirmed or players[3].confirmed)
end

local menu_state, old_menu_state = 1, 1
local mouse_x, mouse_y = 0,0

local function CheckPointCollision(x,y, x1,y1,w1,h1)
    return x < x1+w1 and
            x >= x1 and
            y < y1+h1 and
            y >= y1
end

function heroSelectState:enter()
    TEsound.stop("music")
    mouse_x, mouse_y = 0,0

    players = {
        {name = "P1", pos = 1, visible = true, confirmed = false},
        {name = "P2", pos = 1, visible = false, confirmed = false},
        {name = "P3", pos = 1, visible = false, confirmed = false}
    }
end

function heroSelectState:resume()
    heroSelectState:enter()
end

local function player_input(player, controls)
    if not player.confirmed then
        if controls.jump:pressed() and all_unconfirmed() then
            sfx.play("menu_cancel")
            return Gamestate.switch(titleState)
        elseif controls.fire:pressed() then
            player.visible = true
            player.confirmed = true
            sfx.play("menu_select")
        elseif controls.horizontal:pressed(-1) then
            player.visible = true
            player.pos = player.pos - 1
            if player.pos < 1 then
                player.pos = 1
            else
                sfx.play("menu_move")
            end
        elseif controls.horizontal:pressed(1) then
            player.visible = true
            player.pos = player.pos + 1
            if player.pos > GLOBAL_SETTING.MAX_PLAYERS then
                player.pos = GLOBAL_SETTING.MAX_PLAYERS
            else
                sfx.play("menu_move")
            end
        end
    else
        if controls.jump:pressed() then
            player.confirmed = false
            sfx.play("menu_cancel")
        elseif controls.fire:pressed() and all_confirmed() then
            sfx.play("menu_gamestart")
            return Gamestate.switch(testState)
        end
    end
end

function heroSelectState:update(dt)
    time = time + dt
    UpdateInstance(rick_spr, dt)    --todo add for all 3 heroes

    player_input(players[1], Control1)
    player_input(players[2], Control2)
--    player_input(players[3], Control3) --not defined yet TODO

end

function heroSelectState:draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gfx.font.arcade3x2)

    local sh = selected_heroes()
    for i = 1,3  do
        local h = heroes[i]
        love.graphics.setColor(255, 255, 255, 255)
        --portrait
        love.graphics.rectangle("line", h.x - portrait_width/2, h.py, portrait_width, portrait_height )
        love.graphics.print("Face\npic", h.x - portrait_width/2 + 4, h.py + 4)
        --name
        love.graphics.print(h[1].name, h.x, h.ny)
        --hero sprite 1 2 3
        --P1 P2 P3
        for n = 3, 1, -1 do
            if sh[n][1] == i then
                local k = sh[n][2]
                local c = h[k].color
                love.graphics.setColor(255, 255, 255, 255)
                if h[k].shader then
                    love.graphics.setShader(h[k].shader)
                end
                DrawInstance(h.sprite, h.x + (k - 1) * 40 - 32, h.y - (k - 1) * 8)
                if h[k].shader then
                    love.graphics.setShader()
                end
                love.graphics.setColor(c[1], c[2], c[3], c[4])
                local nx = h.x + (k - 1) * 34 - 32
                local ny = h.sy - (k - 1) * 8
                love.graphics.print(players[n].name, nx, ny)

                if(players[n].confirmed) then
                    love.graphics.rectangle("line", nx - 2, ny - 2, 32 + 4, 16 + 4 )
                end
            end
        end
    end

end

function heroSelectState:mousepressed( x, y, button, istouch )
end

function heroSelectState:mousemoved( x, y, dx, dy)
    mouse_x, mouse_y = x, y
end

function heroSelectState:keypressed(key, unicode)
    if key == "escape" then
        sfx.play("menu_cancel")
        return Gamestate.switch(titleState)
    end
end
