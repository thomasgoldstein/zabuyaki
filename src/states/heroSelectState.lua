--
-- Date: 20.06.2016
--
heroSelectState = {}

local function CheckPointCollision(x,y, x1,y1,w1,h1)
    return x < x1+w1 and
            x >= x1 and
            y < y1+h1 and
            y >= y1
end

local time = 0
local screen_width = 640
local screen_height = 480

local portrait_width = 140
local portrait_height = 140
local portrait_margin = 20

local txt_player_select = love.graphics.newText( gfx.font.arcade2x15, "PLAYER SELECT" )

--{name, shader, text color P1}..
local heroes = {
    {
        {name = "KISA", shader = nil},
        {name = "KYSA", shader = shaders.kisa[2]},
        {name = "KEESA", shader = shaders.kisa[3]},
        hero = Kisa,
        sprite_instance = "src/def/char/kisa.lua",
        sprite_portrait = GetInstance("src/def/misc/portraits.lua"),
        sprite_portrait_anim = "kisa",
        default_anim = "stand",
        cancel_anim = "hurtLow",
        confirm_anim = "walk",
        x = screen_width / 2 - portrait_width - portrait_margin,
        y = 440,    --char sprite
        sy = 276,   --selected P1 P2 P3
        ny = 90,   --char name
        py = 120    --Portrait
    },
    {
        {name = "RICK", shader = nil},
        {name = "RICH", shader = shaders.rick[2]},
        {name = "RICKY", shader = shaders.rick[3]},
        hero = Rick,
        sprite_instance = "src/def/char/rick.lua",
        sprite_portrait = GetInstance("src/def/misc/portraits.lua"),
        sprite_portrait_anim = "rick",
        default_anim = "stand",
        cancel_anim = "hurtHigh",
        confirm_anim = "walk",
        x = screen_width / 2,
        y = 440,
        sy = 276,
        ny = 90,
        py = 120
    },
    {
        {name = "CHAI", shader = nil},
        {name = "CHI", shader = shaders.chai[2]},
        {name = "CHE", shader = shaders.chai[3]},
        hero = Chai,
        sprite_instance = "src/def/char/chai.lua",
        sprite_portrait = GetInstance("src/def/misc/portraits.lua"),
        sprite_portrait_anim = "chai",
        default_anim = "stand",
        cancel_anim = "hurtHigh",
        confirm_anim = "walk",
        x = screen_width / 2 + portrait_width + portrait_margin,
        y = 440,
        sy = 276,
        ny = 90,
        py = 120
    }
}
local players = {
    {pos = 1, visible = false, confirmed = false, sprite = nil},
    {pos = 2, visible = false, confirmed = false, sprite = nil},
    {pos = 3, visible = false, confirmed = false, sprite = nil}
}
local old_pos = 0
local mouse_pos = 0

local function selected_heroes()
--P1 has the hero original color
    local s1 = {players[1].pos, 1 }
    local s2 = {players[2].pos, 1 }
    local s3 = {players[3].pos, 1 }
    --adjust P2
    if s2[1] == s1[1]  then
        s2[2] = s1[2] + 1
    end
    --adjust P3
    if s3[1] == s2[1] and players[2].visible then
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

local function all_invisible()
    --Active players confirmed their choice
    return not (players[1].visible or players[2].visible or players[3].visible)
end

local function CheckPointCollision(x,y, x1,y1,w1,h1)
    return x < x1+w1 and
            x >= x1 and
            y < y1+h1 and
            y >= y1
end

local function calcTransparency(cd)
--    if cd > 1 then
--        return math.sin(cd*10) * 55 + 200
--    end
--    if cd < 0.33 then
--        return cd * 255
--    end
    return 255
end
local show_pid_cool_down = 1
local function drawPID(x, y_, i, confirmed)
    if not x then
        return
    end
    local y = y_ - math.cos(x+time*6)
    local c = GLOBAL_SETTING.PLAYERS_COLORS[i]
    love.graphics.setColor(c[1],c[2],c[3], calcTransparency(show_pid_cool_down))
    love.graphics.rectangle( "fill", x - 30, y, 60, 34 )
--    love.graphics.polygon( "fill", x, y + 40, x - 4 , y + 34, x + 4, y + 34 ) --arrow down
    love.graphics.polygon( "fill", x, y - 6, x - 4 , y - 0, x + 4, y - 0 ) --arrow up
    love.graphics.setColor(0, 0, 0, calcTransparency(show_pid_cool_down))
    if confirmed then
        love.graphics.rectangle( "fill", x - 26, y + 4, 52, 26 )    --bold outline
    else
        love.graphics.rectangle( "fill", x - 28, y + 2, 56, 30 )
    end
    love.graphics.setFont(gfx.font.arcade3x2)
    love.graphics.setColor(255, 255, 255, calcTransparency(show_pid_cool_down))
    love.graphics.print(GLOBAL_SETTING.PLAYERS_NAMES[i], x - 14, y + 8)
end

function heroSelectState:enter()
    players = {
        {pos = 1, visible = true, confirmed = false, sprite = nil},
        {pos = 2, visible = false, confirmed = false, sprite = nil},
        {pos = 3, visible = false, confirmed = false, sprite = nil}
    }
    old_pos = 0
    mouse_pos = 0

    for i = 1,3 do
      SetSpriteAnim(heroes[i].sprite_portrait, heroes[i].sprite_portrait_anim)
      heroes[i].sprite_portrait.size_scale = 2
    end

    -- Prevent double press at start (e.g. auto confirmation)
    Control1.fire:update()
    Control2.fire:update()
    Control3.fire:update()

    --start BGM
    TEsound.stop("music")
    TEsound.playLooping("res/bgm/rockdrive.xm", "music")

    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function heroSelectState:resume()
    heroSelectState:enter()
end

local function player_input(player, controls, i)
    if not player.visible then
        if controls.jump:pressed() and i == 1 then
            --P1 can return to title
            sfx.play("menu_cancel")
            return Gamestate.switch(titleState)
        end
        if controls.jump:pressed() or controls.fire:pressed()
            or controls.horizontal:pressed() or controls.vertical:pressed() then
            player.visible = true
            player.sprite = GetInstance(heroes[player.pos].sprite_instance)
            player.sprite.size_scale = 2
            SetSpriteAnim(player.sprite,heroes[player.pos].default_anim)
        end
        return
    end
    if not player.confirmed then
        if controls.jump:pressed() and all_unconfirmed() then
            if player.visible then
                player.visible = false
--            elseif all_unconfirmed() then
--                sfx.play("menu_cancel")
--                return Gamestate.switch(titleState)
            end
        elseif controls.fire:pressed() then
            player.visible = true
            player.confirmed = true
            SetSpriteAnim(player.sprite,heroes[player.pos].confirm_anim)
            sfx.play("menu_select")
        elseif controls.horizontal:pressed(-1) then
            player.visible = true
            player.pos = player.pos - 1
            if player.pos < 1 then
                player.pos = GLOBAL_SETTING.MAX_PLAYERS
            end
            sfx.play("menu_move")
            player.sprite = GetInstance(heroes[player.pos].sprite_instance)
            player.sprite.size_scale = 2
            SetSpriteAnim(player.sprite,"stand")
        elseif controls.horizontal:pressed(1) then
            player.visible = true
            player.pos = player.pos + 1
            if player.pos > GLOBAL_SETTING.MAX_PLAYERS then
                player.pos = 1
            end
            sfx.play("menu_move")
            player.sprite = GetInstance(heroes[player.pos].sprite_instance)
            player.sprite.size_scale = 2
            SetSpriteAnim(player.sprite,"stand")
        end
    else
        if controls.jump:pressed() then
            player.confirmed = false
            SetSpriteAnim(player.sprite,heroes[player.pos].cancel_anim)
            sfx.play("menu_cancel")
        elseif controls.fire:pressed() and all_confirmed() then
            sfx.play("menu_gamestart")
            local pl = {}
            local sh = selected_heroes()
            for i = 1,GLOBAL_SETTING.MAX_PLAYERS do
                if players[i].confirmed then
                    local pos = players[i].pos
                    pl[#pl + 1] = {
                        hero = heroes[pos].hero,
                        sprite_instance = heroes[pos].sprite_instance,
                        shader = heroes[pos][sh[i][2]].shader,
                        name = heroes[pos][sh[i][2]].name,
                        color = heroes[pos][sh[i][2]].color
                    }
                end
            end
            return Gamestate.switch(arcadeState, pl)
        end
    end
end

function heroSelectState:update(dt)
    time = time + dt
    local sh = selected_heroes()
    for i = 1,3 do
        local cur_players_hero = heroes[players[i].pos]
        local cur_players_hero_set = heroes[players[i].pos][sh[i][2]]
        local cur_color_slot = sh[i][2]
        if players[i].sprite then
            UpdateInstance(players[i].sprite, dt)
            if players[i].sprite.isFinished
                    and (players[i].sprite.cur_anim == heroes[players[i].pos].cancel_anim
                    or players[i].sprite.cur_anim == heroes[players[i].pos].confirm_anim)
            then
                SetSpriteAnim(players[i].sprite,heroes[players[i].pos].default_anim)
            end
            if players[i].visible then
                --smooth indicators movement
                local nx = cur_players_hero.x - portrait_width / 2 +4 + (cur_color_slot - 1) * 64
                local ny = cur_players_hero.sy
                --love.graphics.print(players[i].name, nx, ny)
                if not players[i].nx then
                    players[i].nx = nx
                    players[i].ny = ny
                else
                    if players[i].nx < nx then
                        players[i].nx = math.floor(players[i].nx + 0.5 + (nx - players[i].nx) / 2)
                    elseif players[i].nx > nx then
                        players[i].nx = math.floor(players[i].nx - 0.5 + (nx - players[i].nx) / 2)
                    end
                end
            end
        else
            if players[i].visible then
                players[i].sprite = GetInstance(heroes[players[i].pos].sprite_instance)
                players[i].sprite.size_scale = 2
                SetSpriteAnim(players[i].sprite,heroes[players[i].pos].default_anim)
            end

        end
    end
    player_input(players[1], Control1, 1)
    player_input(players[2], Control2, 2)
    player_input(players[3], Control3, 3)
end

function heroSelectState:draw()
    local sh = selected_heroes()
    for i = 1,3  do
        local cur_players_hero = heroes[players[i].pos]
        local cur_players_hero_set = heroes[players[i].pos][sh[i][2]]
        local cur_color_slot = sh[i][2]
        local h = heroes[i]

        local original_char = 1
        love.graphics.setColor(255, 255, 255, 255)
        --name
        love.graphics.setFont(gfx.font.arcade3x3)
        love.graphics.print(h[original_char].name, h.x - 24 * #h[original_char].name / 2, h.ny)
        --portrait
        DrawInstance(heroes[i].sprite_portrait, h.x - portrait_width/2, h.py)
        love.graphics.rectangle("line", h.x - portrait_width/2, h.py, portrait_width, portrait_height )
        --love.graphics.setColor(255, 255, 255, 127)
        --love.graphics.setFont(gfx.font.arcade3)
        --love.graphics.print("PORTRAIT", h.x - portrait_width/2 + 6, h.py + 4)
        --Players sprite
        if players[i].visible then
            --hero sprite 1 2 3
--            if players[i].sprite then
--                local c = GLOBAL_SETTING.PLAYERS_COLORS[i]
--                love.graphics.setColor(c[1],c[2],c[3], 255)
--                DrawInstance(players[i].sprite, h.x - 8, h.y - 0)
--            end
            love.graphics.setColor(255, 255, 255, 255)
            if cur_players_hero_set.shader then
                love.graphics.setShader(cur_players_hero_set.shader)
            end
            if players[i].sprite then
                DrawInstance(players[i].sprite, h.x, h.y)
            end
            if cur_players_hero_set.shader then
                love.graphics.setShader()
            end
            --P1 P2 P3 indicators
            drawPID(players[i].nx, players[i].ny, i, players[i].confirmed)
        else
            local c = GLOBAL_SETTING.PLAYERS_COLORS[i]
            love.graphics.setColor(c[1], c[2], c[3], 230 + math.sin(time * 4)*25)
            love.graphics.setFont(gfx.font.arcade3x2)
            love.graphics.print(GLOBAL_SETTING.PLAYERS_NAMES[i].."\nPUSH\nANY\nBUTTON", h.x - portrait_width/2 + 20, h.y - portrait_height + 48)
        end
    end
    --header
    love.graphics.setColor(255, 255, 255, 200 + math.sin(time)*55)
    love.graphics.draw(txt_player_select, (screen_width - txt_player_select:getWidth()) / 2, 24)
end

function heroSelectState:keypressed(key, unicode)
    if key == "escape" then
        sfx.play("menu_cancel")
        return Gamestate.switch(titleState)
    end
end

function heroSelectState:mousepressed( x, y, button, istouch )
    if button == 1 then

        mouse_pos = 2
        if x < heroes[2].x - portrait_width/2 - portrait_margin/2 then
            mouse_pos = 1
        elseif x > heroes[2].x + portrait_width/2 + portrait_margin/2 then
            mouse_pos = 3
        end

        if not players[1].visible then
            players[1].visible = true
            sfx.play("menu_select")
            SetSpriteAnim(players[1].sprite,heroes[players[1].pos].default_anim)
        elseif not players[1].confirmed then
            players[1].pos = mouse_pos
            players[1].confirmed = true
            sfx.play("menu_select")
            SetSpriteAnim(players[1].sprite,heroes[players[1].pos].confirm_anim)
        elseif mouse_pos == players[1].pos and all_confirmed() then
            sfx.play("menu_gamestart")
            local pl = {}
            local sh = selected_heroes()
            for i = 1,GLOBAL_SETTING.MAX_PLAYERS do
                if players[i].confirmed then
                    local pos = players[i].pos
                    pl[#pl + 1] = {
                        hero = heroes[pos].hero,
                        sprite_instance = heroes[pos].sprite_instance,
                        shader = heroes[pos][sh[i][2]].shader,
                        name = heroes[pos][sh[i][2]].name,
                        color = heroes[pos][sh[i][2]].color
                    }
                end
            end
            return Gamestate.switch(arcadeState, pl)
        end

    elseif button == 2 then
        if players[1].visible and not players[1].confirmed then
            players[1].visible = false
            sfx.play("menu_cancel")
        elseif players[1].confirmed then
            players[1].confirmed = false
            sfx.play("menu_cancel")
            SetSpriteAnim(players[1].sprite,heroes[players[1].pos].cancel_anim)
        else    --if all_invisible() then
            sfx.play("menu_cancel")
            return Gamestate.switch(titleState)
        end
    end
end

function heroSelectState:mousemoved( x, y, dx, dy)
    mouse_pos = 2
    if x < heroes[2].x - portrait_width/2 - portrait_margin/2 then
        mouse_pos = 1
    elseif x > heroes[2].x + portrait_width/2 + portrait_margin/2 then
        mouse_pos = 3
    end
    if mouse_pos ~= old_pos and not players[1].confirmed then
        old_pos = mouse_pos
        players[1].pos = mouse_pos
        sfx.play("menu_move")
        players[1].sprite = GetInstance(heroes[players[1].pos].sprite_instance)
        players[1].sprite.size_scale = 2
        SetSpriteAnim(players[1].sprite,heroes[players[1].pos].default_anim)
    end
end