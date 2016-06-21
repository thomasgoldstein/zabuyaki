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

local portrait_width = 140
local portrait_height = 140
local portrait_margin = 20

local txt_player_select = love.graphics.newText( gfx.font.arcade2x15, "PLAYER SELECT" )

--sprites and shaders
local rick_spr = GetInstance("res/rick.lua")
SetSpriteAnim(rick_spr,"stand")
rick_spr.size_scale = 2
local chai_spr = GetInstance("res/chai.lua")
SetSpriteAnim(chai_spr,"stand")
chai_spr.size_scale = 2

local sh_rick2 = love.graphics.newShader(sh_replace_3_colors)
sh_rick2:sendColor("colors", {181, 81, 23, 255},  {122, 54, 15, 255},  {56, 27, 28, 255})
sh_rick2:sendColor("newColors", {77,111,158, 255},  {49,73,130, 255},  {28,42,73, 255})   --Blue

local sh_rick3 = love.graphics.newShader(sh_replace_3_colors)
sh_rick3:sendColor("colors", {181, 81, 23, 255},  {122, 54, 15, 255},  {56, 27, 28, 255})
sh_rick3:sendColor("newColors", {111,77,158, 255},  {73,49,130, 255},  {42,28,73, 255}) --Purple

--{name, shader, text color P1}..
local heroes = {
    {
        {name = "KISA", shader = sh_rick2, color = {77,111,158, 255}},
        {name = "KYSA", shader = nil, color = {181, 81, 23, 255}},
        {name = "KEESA", shader = sh_rick3, color = {111,77,158, 255}},
        hero = Rick,
        sprite = rick_spr,
        sprite_instance = "res/rick.lua",
        x = screen_width / 2 - portrait_width - portrait_margin,
        y = 440,    --char sprite
        sy = 280,   --selected P1 P2 P3
        ny = 90,   --char name
        py = 120    --Portrait
    },
    {
        {name = "RICK", shader = nil, color = {181, 81, 23, 255}},
        {name = "RICH", shader = sh_rick3, color = {111,77,158, 255}},
        {name = "RICKY", shader = sh_rick2, color = {77,111,158, 255}},
        hero = Rick,
        sprite = rick_spr,
        sprite_instance = "res/rick.lua",
        x = screen_width / 2,
        y = 440,
        sy = 280,
        ny = 90,
        py = 120
    },
    {
        {name = "CHAI", shader = sh_rick3, color = {111,77,158, 255}},
        {name = "CHI", shader = sh_rick2, color = {77,111,158, 255}},
        {name = "CHE", shader = nil, color = {181, 81, 23, 255}},
        hero = Chai,
        sprite = chai_spr,
        sprite_instance = "res/chai.lua",
        x = screen_width / 2 + portrait_width + portrait_margin,
        y = 440,
        sy = 280,
        ny = 90,
        py = 120
    }
}
local players = {
    {name = "P1", pos = 1, visible = false, confirmed = false, sprite = nil},
    {name = "P2", pos = 2, visible = false, confirmed = false, sprite = nil},
    {name = "P3", pos = 3, visible = false, confirmed = false, sprite = nil}
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
    --mouse_x, mouse_y = 0,0
    players = {
        {name = "P1", pos = 1, visible = false, confirmed = false, sprite = nil},
        {name = "P2", pos = 2, visible = false, confirmed = false, sprite = nil},
        {name = "P3", pos = 3, visible = false, confirmed = false, sprite = nil}
    }
end

function heroSelectState:resume()
    heroSelectState:enter()
end

local function player_input(player, controls)
    if not player.visible then
        if controls.jump:pressed() or controls.fire:pressed()
            or controls.horizontal:pressed() or controls.vertical:pressed() then
            player.visible = true
            player.sprite = GetInstance(heroes[player.pos].sprite_instance)
            player.sprite.size_scale = 2
            SetSpriteAnim(player.sprite,"stand")
        end
        return
    end
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
                player.sprite = GetInstance(heroes[player.pos].sprite_instance)
                player.sprite.size_scale = 2
                SetSpriteAnim(player.sprite,"stand")
            end
        elseif controls.horizontal:pressed(1) then
            player.visible = true
            player.pos = player.pos + 1
            if player.pos > GLOBAL_SETTING.MAX_PLAYERS then
                player.pos = GLOBAL_SETTING.MAX_PLAYERS
            else
                sfx.play("menu_move")
                player.sprite = GetInstance(heroes[player.pos].sprite_instance)
                player.sprite.size_scale = 2
                SetSpriteAnim(player.sprite,"stand")
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
    for i = 1,3 do
        if players[i].sprite then
            UpdateInstance(players[i].sprite, dt)
        end
    end

    player_input(players[1], Control1)
    player_input(players[2], Control2)
    player_input(players[3], Control3)

end

function heroSelectState:draw()
    local sh = selected_heroes()
    for i = 1,3  do
        local curr_players_hero = heroes[players[i].pos]
        local curr_players_hero_set = heroes[players[i].pos][sh[i][2]]
        local curr_color_slot = sh[i][2]
        local h = heroes[i]

        local original_char = 1
        love.graphics.setColor(255, 255, 255, 255)
        --name
        love.graphics.setFont(gfx.font.arcade3x3)
        love.graphics.print(h[original_char].name, h.x - 24 * #h[original_char].name / 2, h.ny)
        --portrait
        love.graphics.rectangle("line", h.x - portrait_width/2, h.py, portrait_width, portrait_height )
        love.graphics.setColor(255, 255, 255, 127)
        love.graphics.setFont(gfx.font.arcade3)
        love.graphics.print("PORTRAIT", h.x - portrait_width/2 + 6, h.py + 4)
        --Players sprite
        if players[i].visible then
            --hero sprite 1 2 3
            love.graphics.setColor(255, 255, 255, 255)
            if curr_players_hero_set.shader then
                love.graphics.setShader(curr_players_hero_set.shader)
            end
            --DrawInstance(curr_players_hero.sprite, h.x, h.y)
            DrawInstance(players[i].sprite, h.x, h.y)
            if curr_players_hero_set.shader then
                love.graphics.setShader()
            end
        else
            love.graphics.setColor(255, 255, 255, 200 + math.sin(time * 4)*55)
            love.graphics.setFont(gfx.font.arcade3x2)
            love.graphics.print(players[i].name.."\nPUSH\nANY\nBUTTON", h.x - portrait_width/2 + 20, h.y - portrait_height + 48)
        end
        --P1 P2 P3 indicators
        love.graphics.setFont(gfx.font.arcade3x2)
        if players[i].visible then
            local c = curr_players_hero_set.color

            love.graphics.setColor(c[1], c[2], c[3], c[4])
            local nx = curr_players_hero.x - portrait_width / 2 + (curr_color_slot - 1) * portrait_width / GLOBAL_SETTING.MAX_PLAYERS
            local ny = curr_players_hero.sy
            love.graphics.print(players[i].name, nx, ny)

            if(players[i].confirmed) then
                love.graphics.rectangle("line", nx - 2, ny - 2, 32 + 4, 16 + 4 )
            end
        end

    end
    --header
    love.graphics.setColor(255, 255, 255, 200 + math.sin(time)*55)
    love.graphics.draw(txt_player_select, (screen_width - txt_player_select:getWidth()) / 2, 24)
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
