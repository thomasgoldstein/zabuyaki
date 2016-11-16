--
-- Date: 20.06.2016
--
playerSelectState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local title_y_offset = 24
local portrait_width = 140
local portrait_height = 140
local portrait_margin = 20

local p1_old_pos = 0
local p1_mouse_pos = 0
local txt_player_select = love.graphics.newText( gfx.font.kimberley, "PLAYER SELECT" )

local heroes = {
    {
        {name = "RICK", shader = nil},
        {name = "RICK", shader = shaders.rick[2]},
        {name = "RICK", shader = shaders.rick[3]},
        hero = Rick,
        sprite_instance = "src/def/char/rick.lua",
        sprite_portrait = GetSpriteInstance("src/def/misc/portraits.lua"),
        sprite_portrait_anim = "rick",
        default_anim = "stand",
        cancel_anim = "hurtHigh",
        confirm_anim = "walk",
        x = screen_width / 2 - portrait_width - portrait_margin,
        y = 440,    --char sprite
        sy = 272,   --selected P1 P2 P3
        ny = 90,   --char name
        py = 120    --Portrait
    },
    {
        {name = "KISA", shader = nil},
        {name = "KISA", shader = shaders.kisa[2]},
        {name = "KISA", shader = shaders.kisa[3]},
        hero = Kisa,
        sprite_instance = "src/def/char/kisa.lua",
        sprite_portrait = GetSpriteInstance("src/def/misc/portraits.lua"),
        sprite_portrait_anim = "kisa",
        default_anim = "stand",
        cancel_anim = "hurtLow",
        confirm_anim = "walk",
        x = screen_width / 2,
        y = 440,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "CHAI", shader = nil},
        {name = "CHAI", shader = shaders.chai[2]},
        {name = "CHAI", shader = shaders.chai[3]},
        hero = Chai,
        sprite_instance = "src/def/char/chai.lua",
        sprite_portrait = GetSpriteInstance("src/def/misc/portraits.lua"),
        sprite_portrait_anim = "chai",
        default_anim = "stand",
        cancel_anim = "hurtHigh",
        confirm_anim = "walk",
        x = screen_width / 2 + portrait_width + portrait_margin,
        y = 440,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "GOPPER", shader = shaders.gopper[2]},
        {name = "GOPPER", shader = shaders.gopper[3]},
        {name = "GOPPER", shader = nil},
        hero = PGopper,
        sprite_instance = "src/def/char/gopper.lua",
        sprite_portrait = GetSpriteInstance("src/def/misc/portraits.lua"),
        sprite_portrait_anim = "rick",  --NO OWN PORTRAIT
        default_anim = "stand",
        cancel_anim = "hurtHigh",
        confirm_anim = "walk",
        x = screen_width / 2,
        y = 440 + 80,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "NIKO", shader = shaders.niko[2]},
        {name = "NIKO", shader = shaders.niko[3]},
        {name = "NIKO", shader = nil},
        hero = PNiko,
        sprite_instance = "src/def/char/niko.lua",
        sprite_portrait = GetSpriteInstance("src/def/misc/portraits.lua"),
        sprite_portrait_anim = "rick",  --NO OWN PORTRAIT
        default_anim = "stand",
        cancel_anim = "hurtHigh",
        confirm_anim = "walk",
        x = screen_width / 2 - 80,
        y = 440 + 80,
        sy = 272,
        ny = 90,
        py = 120
    }
}
HEROES = heroes -- global var for in-game player select

local players = {
    {pos = 1, visible = false, confirmed = false, sprite = nil},
    {pos = 2, visible = false, confirmed = false, sprite = nil},
    {pos = 3, visible = false, confirmed = false, sprite = nil}
}

local function selected_heroes()
    --calc P's indicators X position in the slot
    --P1
    local s1 = {players[1].pos, 1}
    local s2 = {players[2].pos, 1}
    local s3 = {players[3].pos, 1}
    local xshift = {0, 0, 0 }
    --adjust P2
    if s2[1] == s1[1] and players[2].visible and players[1].visible then
        s2[2] = s1[2] + 1
    end
    --adjust P3
    if s3[1] == s2[1] and players[2].visible and players[3].visible then
        s3[2] = s2[2] + 1
    elseif s3[1] == s1[1] and players[3].visible and players[1].visible then
        s3[2] = s1[2] + 1
    end

    --x shift to center P indicator
    if players[1].visible then
        xshift[players[1].pos] = xshift[players[1].pos] + 1
    end
    if players[2].visible then
        xshift[players[2].pos] = xshift[players[2].pos] + 1
    end
    if players[3].visible then
        xshift[players[3].pos] = xshift[players[3].pos] + 1
    end
    --dp( players[1].pos, players[2].pos, players[3].pos, " pos -> ",xshift[players[1].pos], xshift[players[2].pos], xshift[players[3].pos], " - ", s1[2], s2[2], s3[2])
    return {s1, s2, s3}, xshift
end

local function all_confirmed()
    --visible players confirmed their choice
    local confirmed = false
    for i = 1,#players do
        if players[i].confirmed then
            confirmed = true
        else
            if players[i].visible then
                return false
            end
        end
    end
    return confirmed
end

local function all_unconfirmed()
    --All active players did not confirm their choice
    return not (players[1].confirmed or players[2].confirmed or players[3].confirmed)
end

local function all_invisible()
    --Active players are invisible "press any button"
    return not (players[1].visible or players[2].visible or players[3].visible)
end

local function drawPID(x, y_, i, confirmed)
    if not x then
        return
    end
    local y = y_ - math.cos(x+time*6)
    love.graphics.setColor( unpack( GLOBAL_SETTING.PLAYERS_COLORS[i] ) )
    love.graphics.rectangle( "fill", x - 30, y, 60, 34 )
    love.graphics.polygon( "fill", x, y - 6, x - 4 , y - 0, x + 4, y - 0 ) --arrow up
    love.graphics.setColor(0, 0, 0, 255)
    if confirmed then
        love.graphics.rectangle( "fill", x - 26, y + 4, 52, 26 )    --bold outline
    else
        love.graphics.rectangle( "fill", x - 28, y + 2, 56, 30 )
    end
    love.graphics.setFont(gfx.font.arcade3x2)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(GLOBAL_SETTING.PLAYERS_NAMES[i], x - 14, y + 8)
end

function playerSelectState:enter()
    players = {
        {pos = 1, visible = true, confirmed = false, sprite = nil},
        {pos = 2, visible = false, confirmed = false, sprite = nil},
        {pos = 3, visible = false, confirmed = false, sprite = nil}
    }
    p1_old_pos = 0
    p1_mouse_pos = 0
    for i = 1,#players do
      SetSpriteAnimation(heroes[i].sprite_portrait, heroes[i].sprite_portrait_anim)
      heroes[i].sprite_portrait.size_scale = 2
    end
    -- Prevent double press at start (e.g. auto confirmation)
    Control1.attack:update()
    Control2.attack:update()
    Control3.attack:update()
    love.graphics.setLineWidth( 2 )
    --start BGM
--    TEsound.stop("music")
--    TEsound.playLooping(bgm.intro, "music")
    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function playerSelectState:resume()
    playerSelectState:enter()
end

local function GameStart()
    --All characters confirmed, pass them into the stage
    sfx.play("sfx","menu_gamestart")
    local pl = {}
    local sh = selected_heroes()
    for i = 1,GLOBAL_SETTING.MAX_PLAYERS do
        if players[i].confirmed then
            local pos = players[i].pos
            if GLOBAL_SETTING.DEBUG then --DEBUG =use Gopper as P1
                if pos == 3 then
                    pos = 5 --Niko Player
                else
                    pos = 4 --Gopper Player
                end
                pl[i] = {
                    hero = heroes[pos].hero,
                    sprite_instance = heroes[pos].sprite_instance,
                    shader = heroes[pos][i].shader, --debug shader = slot N
                    name = heroes[pos][i].name, --debug name = slot N
                    color = heroes[pos][i].color --debug color = slot N
                }
            else
                pl[i] = {
                    hero = heroes[pos].hero,
                    sprite_instance = heroes[pos].sprite_instance,
                    shader = heroes[pos][sh[i][2]].shader,
                    name = heroes[pos][sh[i][2]].name,
                    color = heroes[pos][sh[i][2]].color
                }
            end
        end
    end
    return Gamestate.switch(arcadeState, pl)
end

local function player_input(player, controls, i)
    if not player.visible then
        if (controls.jump:pressed() or controls.back:pressed()) and i == 1 then
            --Only P1 can return to title
            sfx.play("sfx","menu_cancel")
            return Gamestate.switch(titleState, "dontStartMusic")
        end
        if controls.attack:pressed() or controls.start:pressed()then
            sfx.play("sfx","menu_select")
            player.visible = true
            player.sprite = GetSpriteInstance(heroes[player.pos].sprite_instance)
            player.sprite.size_scale = 2
            SetSpriteAnimation(player.sprite,heroes[player.pos].default_anim)
        end
        return
    end
    if not player.confirmed then
        if controls.jump:pressed() or controls.back:pressed() then
            if player.visible then
                sfx.play("sfx","menu_cancel")
                player.visible = false
            end
        elseif controls.attack:pressed() or controls.start:pressed() then
            player.visible = true
            player.confirmed = true
            SetSpriteAnimation(player.sprite,heroes[player.pos].confirm_anim)
            sfx.play("sfx","menu_select")
        elseif controls.horizontal:pressed(-1) then
            player.pos = player.pos - 1
            if player.pos < 1 then
                player.pos = GLOBAL_SETTING.MAX_PLAYERS
            end
            sfx.play("sfx","menu_move")
            player.sprite = GetSpriteInstance(heroes[player.pos].sprite_instance)
            player.sprite.size_scale = 2
            SetSpriteAnimation(player.sprite,"stand")
        elseif controls.horizontal:pressed(1) then
            player.pos = player.pos + 1
            if player.pos > GLOBAL_SETTING.MAX_PLAYERS then
                player.pos = 1
            end
            sfx.play("sfx","menu_move")
            player.sprite = GetSpriteInstance(heroes[player.pos].sprite_instance)
            player.sprite.size_scale = 2
            SetSpriteAnimation(player.sprite,"stand")
        end
    else
        if controls.jump:pressed() or controls.back:pressed() then
            player.confirmed = false
            SetSpriteAnimation(player.sprite,heroes[player.pos].cancel_anim)
            sfx.play("sfx","menu_cancel")
        elseif (controls.attack:pressed() or controls.start:pressed()) and all_confirmed() then
            GameStart()
            return
        end
    end
end

function playerSelectState:update(dt)
    time = time + dt
    local sh,shiftx = selected_heroes()
    for i = 1,#players do
        local cur_players_hero = heroes[players[i].pos]
        local cur_players_hero_set = heroes[players[i].pos][sh[i][2]]
        local cur_color_slot = sh[i][2]
        if players[i].sprite then
            UpdateSpriteInstance(players[i].sprite, dt)
            if players[i].sprite.isFinished
                    and (players[i].sprite.cur_anim == heroes[players[i].pos].cancel_anim
                    or players[i].sprite.cur_anim == heroes[players[i].pos].confirm_anim)
            then
                SetSpriteAnimation(players[i].sprite,heroes[players[i].pos].default_anim)
            end
            if players[i].visible then
                --smooth indicators movement
                local nx = cur_players_hero.x - (shiftx[players[i].pos] - 1) * 32 + (cur_color_slot - 1) * 64 -- * (i - 1)
                local ny = cur_players_hero.sy
                if not players[i].nx then
                    players[i].nx = nx
                    players[i].ny = ny
                else
                    if players[i].nx < nx then
                        players[i].nx = math.floor(players[i].nx + 0.5 + (nx - players[i].nx) / 5)
                    elseif players[i].nx > nx then
                        players[i].nx = math.floor(players[i].nx - 0.5 + (nx - players[i].nx) / 5)
                    end
                end
            end
        else
            if players[i].visible then
                players[i].sprite = GetSpriteInstance(heroes[players[i].pos].sprite_instance)
                players[i].sprite.size_scale = 2
                SetSpriteAnimation(players[i].sprite,heroes[players[i].pos].default_anim)
            end

        end
    end
    player_input(players[1], Control1, 1)
    player_input(players[2], Control2, 2)
    player_input(players[3], Control3, 3)
end

function playerSelectState:draw()
    push:apply("start")
    local sh = selected_heroes()
    for i = 1,#players do
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
        DrawSpriteInstance(heroes[i].sprite_portrait, h.x - portrait_width/2, h.py)
        love.graphics.rectangle("line", h.x - portrait_width/2, h.py, portrait_width, portrait_height, 4,4,1)
        --Players sprite
        if players[i].visible then
            --hero sprite
            love.graphics.setColor(255, 255, 255, 255)
            if cur_players_hero_set.shader then
                love.graphics.setShader(cur_players_hero_set.shader)
            end
            if players[i].sprite then
                DrawSpriteInstance(players[i].sprite, h.x, h.y)
            end
            if cur_players_hero_set.shader then
                love.graphics.setShader()
            end
            --P1 P2 P3 indicators
            drawPID(players[i].nx, players[i].ny, i, players[i].confirmed)
        else
            local c = GLOBAL_SETTING.PLAYERS_COLORS[i]
            c[4] = 230 + math.sin(time * 4)*25
            love.graphics.setColor( unpack( c ) )
            love.graphics.setFont(gfx.font.arcade3x2)
            love.graphics.print(GLOBAL_SETTING.PLAYERS_NAMES[i].."\nPRESS\nATTACK", h.x - portrait_width/2 + 20, h.y - portrait_height + 48)
        end
    end
    --header
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(txt_player_select, (screen_width - txt_player_select:getWidth()) / 2, title_y_offset)
    show_debug_indicator()
    push:apply("end")
end

function playerSelectState:confirm( x, y, button, istouch )
    -- P1 mouse control only
    if button == 1 then
        p1_mouse_pos = 2
        if x < heroes[2].x - portrait_width/2 - portrait_margin/2 then
            p1_mouse_pos = 1
        elseif x > heroes[2].x + portrait_width/2 + portrait_margin/2 then
            p1_mouse_pos = 3
        end
        if not players[1].visible then
            players[1].visible = true
            sfx.play("sfx","menu_select")
            SetSpriteAnimation(players[1].sprite,heroes[players[1].pos].default_anim)
        elseif not players[1].confirmed then
            if players[1].pos ~= p1_mouse_pos then
                p1_old_pos = players[1].pos
                players[1].pos = p1_mouse_pos
                players[1].sprite = GetSpriteInstance(heroes[players[1].pos].sprite_instance)
                players[1].sprite.size_scale = 2
            end
            players[1].confirmed = true
            sfx.play("sfx","menu_select")
            SetSpriteAnimation(players[1].sprite,heroes[players[1].pos].confirm_anim)
        elseif p1_mouse_pos == players[1].pos and all_confirmed() then
            GameStart()
            return
        end
    elseif button == 2 then
        sfx.play("sfx","menu_cancel")
        if players[1].visible and not players[1].confirmed then
            players[1].visible = false
        elseif players[1].confirmed then
            players[1].confirmed = false
            SetSpriteAnimation(players[1].sprite,heroes[players[1].pos].cancel_anim)
        else
            return Gamestate.switch(titleState, "dontStartMusic")
        end
    end
end

function playerSelectState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    playerSelectState:confirm( x, y, button, istouch )
end

function playerSelectState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    p1_mouse_pos = 2
    if x < heroes[2].x - portrait_width/2 - portrait_margin/2 then
        p1_mouse_pos = 1
    elseif x > heroes[2].x + portrait_width/2 + portrait_margin/2 then
        p1_mouse_pos = 3
    end
    if p1_mouse_pos ~= p1_old_pos and players[1].visible and not players[1].confirmed then
        p1_old_pos = p1_mouse_pos
        players[1].pos = p1_mouse_pos
        sfx.play("sfx","menu_move")
        players[1].sprite = GetSpriteInstance(heroes[players[1].pos].sprite_instance)
        players[1].sprite.size_scale = 2
        SetSpriteAnimation(players[1].sprite,heroes[players[1].pos].default_anim)
    end
end

function playerSelectState:keypressed(key, unicode)
end