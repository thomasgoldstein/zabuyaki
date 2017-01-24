-- Sprite Editor
spriteEditorState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 200 - menu_item_h
local menu_x_offset = 0
local hint_y_offset = 80
local title_y_offset = 24
local left_item_offset  = 6
local top_item_offset  = 6
local item_width_margin = left_item_offset * 2
local item_height_margin = top_item_offset * 2 - 2

local txt_current_sprite = nil --love.graphics.newText( gfx.font.kimberley, "SPRITE" )
local txt_items = {"ANIMATIONS", "FRAMES", "SHADERS", "BACK"}

local hero = nil
local sprite = nil
local animations = nil

local weapon = nil
local sprite_weapon = nil
local animations_weapon = {}

local function fillMenu(txt_items, txt_hints)
    local m = {}
    local max_item_width, max_item_x = 8, 0
    if not txt_hints then
        txt_hints = {}
    end
    for i = 1, #txt_items do
        local w = gfx.font.arcade4:getWidth(txt_items[i])
        if w > max_item_width then
            max_item_x = menu_x_offset + screen_width / 2 - w / 2
            max_item_width = w
        end
    end
    for i = 1, #txt_items do
        local w = gfx.font.arcade4:getWidth(txt_items[i])
        m[#m + 1] = {
            item = txt_items[i],
            hint = txt_hints[i] or "",
            x = menu_x_offset + screen_width / 2 - w / 2,
            y = menu_y_offset + i * menu_item_h,
            rect_x = max_item_x,
            w = max_item_width,
            h = gfx.font.arcade4:getHeight(txt_items[i]),
            wx = (screen_width - gfx.font.arcade4:getWidth(txt_hints[i] or "")) / 2,
            wy = screen_height - hint_y_offset,
            n = 1
        }
    end
    return m
end

local function calcMenuItem(menu, i)
    assert(menu and menu[i], "menu item error")
    local m = menu[i]
    m.w = gfx.font.arcade4:getWidth(m.item)
    m.h = gfx.font.arcade4:getHeight(m.item)
    m.wy = screen_height - hint_y_offset
    m.x = menu_x_offset + screen_width / 2 - m.w / 2
    m.y = menu_y_offset + i * menu_item_h
    m.rect_x = menu_x_offset + screen_width / 2 - m.w / 2
    m.wx = (screen_width - gfx.font.arcade4:getWidth(m.hint)) / 2
end

local menu = fillMenu(txt_items, txt_hints)

local menu_state, old_menu_state = 1, 1
local mouse_x, mouse_y, old_mouse_y = 0, 0, 0

local sort_abc_func = function( a, b ) return a.bName < b.bName end

function spriteEditorState:enter(_, _hero, _weapon)
    hero = _hero
    sprite = GetSpriteInstance(hero.sprite_instance)
    sprite.size_scale = 2
    txt_current_sprite = love.graphics.newText( gfx.font.kimberley, hero.name )
    animations = {}
    for key, val in pairs(sprite.def.animations) do
        animations[#animations + 1] = key
    end
    table.sort( animations )
    SetSpriteAnimation(sprite,animations[1])

    weapon = _weapon
    if weapon then
        sprite_weapon = GetSpriteInstance(weapon.sprite_instance)
        sprite_weapon.size_scale = 2
        animations_weapon = {}
        for key, val in pairs(sprite_weapon.def.animations) do
            animations_weapon[#animations_weapon + 1] = key
        end
        table.sort( animations_weapon )
        SetSpriteAnimation(sprite_weapon,"stand")
    else
        sprite_weapon = nil
        animations_weapon = {}
    end
    menu[1].n = 1
    menu[3].n = 1
    mouse_x, mouse_y = 0,0

    --TEsound.stop("music")
    -- Prevent double press at start (e.g. auto confirmation)
    Control1.attack:update()
    Control1.jump:update()
    Control1.start:update()
    Control1.back:update()
    love.graphics.setLineWidth( 2 )
    self:wheelmoved(0, 0)   --pick 1st sprite to draw
end

--Only P1 can use menu / options
local function player_input(controls)
    if love.keyboard.isDown('lshift') then
        --change ox, oy offset of the sprite frame
        local s = sprite.def.animations[sprite.cur_anim]
        local m = menu[menu_state]
        if menu_state == 2 then
            if controls.horizontal:pressed() then
                s[m.n].ox = s[m.n].ox + controls.horizontal:getValue()
            end
            if controls.vertical:pressed() then
                s[m.n].oy = s[m.n].oy + controls.vertical:getValue()
            end
        end
        return
    end
    if love.keyboard.isDown('lalt') then
        --change rotation of the sprite frame
        local s = sprite.def.animations[sprite.cur_anim]
        local m = menu[menu_state]
        if menu_state == 2 then
            if not s[m.n].rotate then
                s[m.n].rotate = 0
            end
            if controls.horizontal:pressed() then
                s[m.n].rotate = s[m.n].rotate + controls.horizontal:getValue() / 10
            end
        end
        return
    end
    if love.keyboard.isDown('lctrl') and love.keyboard.isDown('c') then
        print(ParseSpriteAnimation(sprite))
    end
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menu_cancel")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return spriteEditorState:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1)then
        spriteEditorState:wheelmoved(0, -1)
    elseif controls.horizontal:pressed(1)then
        spriteEditorState:wheelmoved(0, 1)
    elseif controls.vertical:pressed(-1) then
        menu_state = menu_state - 1
    elseif controls.vertical:pressed(1) then
        menu_state = menu_state + 1
    end
    if menu_state < 1 then
        menu_state = #menu
    end
    if menu_state > #menu then
        menu_state = 1
    end
end

function spriteEditorState:update(dt)
    time = time + dt
    if menu_state ~= old_menu_state then
        sfx.play("sfx","menu_move")
        old_menu_state = menu_state
    end

    if sprite then
        UpdateSpriteInstance(sprite, dt)
    end
    if sprite_weapon then
        UpdateSpriteInstance(sprite_weapon, dt)
    end

    player_input(Control1)
end

function spriteEditorState:draw()
    push:apply("start")
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1,#menu do
        local m = menu[i]
        if i == 1 then
            m.item = animations[m.n].." #"..m.n
            --m.hint = "" --..heroes[m.n].sprite_instance
            local m2 = menu[2]
            if m2.n > #sprite.def.animations[sprite.cur_anim] then
                m2.n = #sprite.def.animations[sprite.cur_anim]
            end
            m2.item = "FRAME #"..m2.n.." of "..#sprite.def.animations[sprite.cur_anim]
        elseif i == 2 then
            local s = sprite.def.animations[sprite.cur_anim]
            m.item = "FRAME #"..m.n.." of "..#sprite.def.animations[sprite.cur_anim]
            m.hint = ""
            if s[m.n].delay then
                m.hint = m.hint .. "FR.DELAY "..s[m.n].delay.." "
            elseif s.delay then
                m.hint = m.hint .. "DELAY "..s.delay.." "
            end
            if s.loop then
                m.hint = m.hint .. "LOOP "
            end
            if s[m.n].ox and s[m.n].oy then
                m.hint = m.hint .. "\nOX,Y:"..s[m.n].ox..","..s[m.n].oy.." "
            end
            if s[m.n].flip_h then
                m.hint = m.hint .. "flip_h "
            end
            if s[m.n].flip_v then
                m.hint = m.hint .. "flip_v "
            end
            if s[m.n].rotate then
                m.hint = m.hint .. "R:"..s[m.n].rotate.." "
            end
            if s[m.n].func then
                m.hint = m.hint .. "FUNC "
            end
        elseif i == 3 then
            if #hero.shaders < 1 then
                m.item = "NO SHADERS"
            else
                if not hero.shaders[m.n] then
                    m.item = "ORIGINAL COLORS"
                else
                    m.item = "SHADER #"..m.n
                end
            end
        end
        calcMenuItem(menu, i)
        if i == old_menu_state then
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.print(m.hint, m.wx, m.wy)
            love.graphics.setColor(0, 0, 0, 80)
            love.graphics.rectangle("fill", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= old_mouse_y and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin )
        then
            old_mouse_y = mouse_y
            menu_state = i
        end
    end
    --header
    love.graphics.setColor(255, 255, 255, 120)
    love.graphics.draw(txt_current_sprite, (screen_width - txt_current_sprite:getWidth()) / 2, title_y_offset)

    --current weapon sprite
    if sprite_weapon then
        love.graphics.setColor(255, 255, 255, 255)
        DrawSpriteInstance(sprite_weapon, 0 + 60, screen_height - 4)
    end
    --character sprite
    local sc = sprite.def.animations[sprite.cur_anim][1]
    local x_step = 140 --(sc.ox or 20) * 4 + 8 or 100
    local x = screen_width /2
    local y = menu_y_offset + menu_item_h / 2
    if sprite.cur_anim == "icon" then --normalize icon's pos
        y = y - 40
        x = x - 40
    end
    love.graphics.setColor(255, 255, 255, 255)
    if hero.shaders[menu[3].n] then
        love.graphics.setShader(hero.shaders[menu[3].n])
    end
    if sprite then --for Obstacles w/o shaders
        if menu_state == 2 then
            --1 frame
            love.graphics.setColor(255, 0, 0, 150)
            love.graphics.rectangle("fill", 0, y, screen_width, 2)
            love.graphics.setColor(0, 0, 255, 150)
            love.graphics.rectangle("fill", x, 0, 2, menu_y_offset + menu_item_h)
            if menu[menu_state].n > #sprite.def.animations[sprite.cur_anim] then
                menu[menu_state].n = 1
            end
            love.graphics.setColor(255, 255, 255, 150)
            for i = 1, #sprite.def.animations[sprite.cur_anim] do
                DrawSpriteInstance(sprite, x - (menu[menu_state].n - i) * x_step, y, i )
            end
            love.graphics.setColor(255, 255, 255, 255)
            DrawSpriteInstance(sprite, x, y, menu[menu_state].n)
        else
            --animation
            DrawSpriteInstance(sprite, x, y)
        end
    end
    if hero.shaders[menu[3].n] then
            love.graphics.setShader()
    end
    show_debug_indicator()
    push:apply("end")
end

function spriteEditorState:confirm( x, y, button, istouch )
    if (button == 1 and menu_state == #menu) or button == 2 then
        sfx.play("sfx","menu_cancel")
        TEsound.stop("music")
        TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
        return Gamestate.pop()
    end
    if button == 1 then
        if menu_state == 1 then
            SetSpriteAnimation(sprite, animations[menu[menu_state].n])
            sfx.play("sfx","menu_select")
        elseif menu_state == 2 then
            sfx.play("sfx","menu_select")
        elseif menu_state == 3 then
            sfx.play("sfx","menu_select")
        end
    end
end

function spriteEditorState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    spriteEditorState:confirm( x, y, button, istouch )
end

function spriteEditorState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end

function spriteEditorState:wheelmoved(x, y)
    local i = 0
    if y > 0 then
        i = 1
    elseif y < 0 then
        i = -1
    end
    menu[menu_state].n = menu[menu_state].n + i
    if menu_state == 1 then
        if menu[menu_state].n < 1 then
            menu[menu_state].n = #animations
        end
        if menu[menu_state].n > #animations then
            menu[menu_state].n = 1
        end
        SetSpriteAnimation(sprite, animations[menu[menu_state].n])

    elseif menu_state == 2 then
        --frames
        if menu[menu_state].n < 1 then
            menu[menu_state].n = #sprite.def.animations[sprite.cur_anim]
        end
        if menu[menu_state].n > #sprite.def.animations[sprite.cur_anim] then
            menu[menu_state].n = 1
        end

    elseif menu_state == 3 then
        --shaders
        if menu[menu_state].n < 1 then
            menu[menu_state].n = #hero.shaders
        end
        if menu[menu_state].n > #hero.shaders then
            menu[menu_state].n = 1
        end
    end
    if menu_state ~= 3 then
        sfx.play("sfx","menu_move")
    end
end
