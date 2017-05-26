-- Sprite Editor
spriteEditorState = {}

local time = 0
local screenWidth = 640
local screenHeight = 480
local menuItem_h = 40
local menu_yOffset = 200 - menuItem_h
local menu_xOffset = 0
local hint_yOffset = 80
local title_yOffset = 24
local leftItemOffset  = 6
local topItemOffset  = 6
local itemWidthMargin = leftItemOffset * 2
local itemHeightMargin = topItemOffset * 2 - 2

local txtCurrentSprite = nil --love.graphics.newText( gfx.font.kimberley, "SPRITE" )
local txtItems = {"ANIMATIONS", "FRAMES", "WEAPON ANIMATIONS", "SHADERS", "BACK"}

local hero = nil
local sprite = nil
local animations = nil

local weapon = nil
local sprite_weapon = nil
local animations_weapon = {}

local menu = fillMenu(txtItems, txt_hints)

local menuState, oldMenuState = 1, 1
local mouse_x, mouse_y, old_mouse_y = 0, 0, 0

local sort_abc_func = function( a, b ) return a.bName < b.bName end

function spriteEditorState:enter(_, _hero, _weapon)
    hero = _hero
    sprite = GetSpriteInstance(hero.spriteInstance)
    sprite.sizeScale = 2
    txtCurrentSprite = love.graphics.newText( gfx.font.kimberley, hero.name )
    animations = {}
    for key, val in pairs(sprite.def.animations) do
        animations[#animations + 1] = key
    end
    table.sort( animations )
    SetSpriteAnimation(sprite,animations[1])

    weapon = _weapon
    if weapon then
        sprite_weapon = GetSpriteInstance(weapon.spriteInstance)
        sprite_weapon.sizeScale = 2
        animations_weapon = {}
        for key, val in pairs(sprite_weapon.def.animations) do
            animations_weapon[#animations_weapon + 1] = key
        end
        table.sort( animations_weapon )
        SetSpriteAnimation(sprite_weapon,"angle0")
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

local function displayHelp()
    local font = love.graphics.getFont()
    local x, y = leftItemOffset, menu_yOffset + menuItem_h
    love.graphics.setFont(gfx.font.arcade3)
    love.graphics.setColor(100, 100, 100, 255)
    if not weapon then
        if menuState == 1 then
            love.graphics.print(
[[<- -> / Mouse wheel :
    Select weapon
    animation

Attack/Enter :
    Replay animation]], x, y)
        elseif menuState == 2 then
            love.graphics.print(
[[<- -> / Mouse wheel :
    Select frame

L-Shift + Arrows :
    Weapon Position

L-Alt + <- -> :
    Rotate Weapon

Attack/Enter :
    Dump to Console]], x, y)
        elseif menuState == 4 then
            love.graphics.print(
[[<- -> / Mouse wheel :
    Select shader]], x, y)
        end
    else
        if menuState == 1 then
            love.graphics.print(
[[<- -> / Mouse wheel :
    Select character
    animation

Attack/Enter :
    Replay animation]], x, y)
        elseif menuState == 2 then
            love.graphics.print(
[[<- -> / Mouse wheel :
    Select frame
L-Shift + Arrows :
    Char Position
L-Alt + <- -> :
    Rotate Character
L-Ctrl + Arrows :
    Flip Character
R-Shift + Arrows :
    Weapon Position
R-Alt + <- -> :
    Rotate Weapon
R-Ctrl + Arrows :
    Flip Weapon
0 : Show/hide center
    of weapon sprite
Attack/Enter :
    Dump to Console]], x, y)
        elseif menuState == 3 then
            love.graphics.print(
[[Attack/Enter :
     Set this weapon
     animation to
     the current
     character's frame

<- -> / Mouse wheel :
    Select weapon
    animation]], x, y)
        elseif menuState == 4 then
            love.graphics.print(
[[<- -> / Mouse wheel :
    Select shader]], x, y)
        end
    end
    love.graphics.setFont(font)
end

--Only P1 can use menu / options
function spriteEditorState:player_input(controls)
    local s = sprite.def.animations[sprite.curAnim]
    local m = menu[menuState]
    local f = s[m.n]    --current frame
    if menuState == 2 then --static frame
        if love.keyboard.isDown('lctrl') then
            --flip sprite frame horizontally & vertically
            if controls.horizontal:pressed() then
                f.flipH = controls.horizontal:getValue()
            end
            if controls.vertical:pressed() then
                f.flipV = controls.vertical:getValue()
            end
            return
        end
        if love.keyboard.isDown('rctrl') then
            --flip weapon frame horizontally & vertically
            if controls.horizontal:pressed() then
                f.wFlip_h = controls.horizontal:getValue()
            end
            if controls.vertical:pressed() then
                f.wFlip_v = controls.vertical:getValue()
            end
            return
        end
        if love.keyboard.isDown('lshift') then
            --change ox, oy offset of the sprite frame
            if controls.horizontal:pressed() then
                f.ox = f.ox + controls.horizontal:getValue()
            end
            if controls.vertical:pressed() then
                f.oy = f.oy + controls.vertical:getValue()
            end
            return
        end
        if love.keyboard.isDown('rshift') then
            --change ox, oy offset of the weapon
            if not sprite_weapon then
                return
            end
            if not f.wx then
                f.wx = 0
                f.wy = -20
                f.wAnimation = animations_weapon[menu[3].n]
                f.wRotation = 0
            end
            if controls.horizontal:pressed() then
                f.wx = f.wx + controls.horizontal:getValue()
            end
            if controls.vertical:pressed() then
                f.wy = f.wy + controls.vertical:getValue()
            end
            return
        end
        if love.keyboard.isDown('lalt') then
            --change rotation of the sprite frame
            if not f.rotate then
                f.rotate = 0
            end
            if controls.horizontal:pressed() then
                f.rotate = f.rotate + controls.horizontal:getValue() * math.pi / 20
                if ( f.rotate ~= 0 and f.rotate > -0.1 and f.rotate < 0.1 )
                    or f.rotate >= math.pi * 2 or f.rotate <= -math.pi * 2
                then
                    f.rotate = 0
                end
            end
            return
        end
        if love.keyboard.isDown('ralt') then
            --change rotation of the weapon
            if not sprite_weapon or not f.wx then
                return
            end
            if not f.wRotate then
                f.wRotate = 0
            end
            if controls.horizontal:pressed() then
                f.wRotate = f.wRotate + controls.horizontal:getValue() * math.pi / 20
                if ( f.wRotate ~= 0 and f.wRotate > -0.1 and f.wRotate < 0.1 )
                    or f.wRotate >= math.pi * 2 or f.wRotate <= -math.pi * 2
                then
                    f.wRotate = 0
                end
            end
            return
        end
    end

    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menuCancel")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return self:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1)then
        self:wheelmoved(0, -1)
    elseif controls.horizontal:pressed(1)then
        self:wheelmoved(0, 1)
    elseif controls.vertical:pressed(-1) then
        menuState = menuState - 1
    elseif controls.vertical:pressed(1) then
        menuState = menuState + 1
    end
    if menuState < 1 then
        menuState = #menu
    end
    if menuState > #menu then
        menuState = 1
    end
end

function spriteEditorState:update(dt)
    time = time + dt
    if menuState ~= oldMenuState then
        sfx.play("sfx","menuMove")
        oldMenuState = menuState
    end
    if sprite then
        UpdateSpriteInstance(sprite, dt)
    end
    if sprite_weapon then
--        UpdateSpriteInstance(sprite_weapon, dt)
    end
    self:player_input(Control1)
end

local function DrawSpriteWeapon(sprite, x, y, i)
    if sprite_weapon then
        local s = sprite.def.animations[sprite.curAnim][i or sprite.curFrame or 1]
        local wx, wy, wAnimation
        if s.wx and s.wy then
            wx = s.wx * sprite_weapon.sizeScale or 0
            wy = s.wy * sprite_weapon.sizeScale or 0
            wAnimation = s.wAnimation or "angle0"
            if sprite_weapon.curAnim ~= wAnimation then
                SetSpriteAnimation(sprite_weapon, wAnimation)
            end
            sprite_weapon.rotation = s.wRotate or 0
            sprite_weapon.flipH = s.wFlip_h or 1
            sprite_weapon.flipV = s.wFlip_v or 1
            DrawSpriteInstance(sprite_weapon, x + wx, y + wy)
            if GLOBAL_SETTING.DEBUG then
                --center of the weapon animation
                love.graphics.rectangle("fill", x + wx - 2, y + wy, 6, 2)
                love.graphics.rectangle("fill", x + wx, y + wy - 2, 2, 6)
            end
        end
    end
end

function spriteEditorState:draw()
    push:start()
    displayHelp()
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1,#menu do
        local m = menu[i]
        if i == 1 then
            m.item = animations[m.n].." #"..m.n
            local m2 = menu[2]
            if m2.n > #sprite.def.animations[sprite.curAnim] then
                m2.n = #sprite.def.animations[sprite.curAnim]
            end
            m2.item = "FRAME #"..m2.n.." of "..#sprite.def.animations[sprite.curAnim]
            m.hint = ""
        elseif i == 2 then
            local s = sprite.def.animations[sprite.curAnim]
            m.item = "FRAME #"..m.n.." of "..#sprite.def.animations[sprite.curAnim]
            m.hint = ""
            if s[m.n].delay then
                m.hint = m.hint .. "FR.DELAY "..s[m.n].delay.." "
            elseif s.delay then
                m.hint = m.hint .. "DELAY "..s.delay.." "
            end
            if s.loop then
                m.hint = m.hint .. "LOOP "
            end
            if s[m.n].func then
                m.hint = m.hint .. "FUNC "
            end
            if s[m.n].flipH then
                m.hint = m.hint .. "flipH "
            end
            if s[m.n].flipV then
                m.hint = m.hint .. "flipV "
            end
            if s[m.n].ox and s[m.n].oy then
                m.hint = m.hint .. "\nOXY:"..s[m.n].ox..","..s[m.n].oy.." "
            end
            if s[m.n].rotate then
                m.hint = m.hint .. "R:"..s[m.n].rotate.." RXY:"..(s[m.n].rx or 0)..","..(s[m.n].ry or 0).." "
            end
            if s[m.n].wx then
                m.hint = m.hint .. "\nWXY:"..s[m.n].wx..","..s[m.n].wy.." WR:"..(s[m.n].wRotate or 0).." "..(s[m.n].wAnimation or "?")
            end
        elseif i == 3 then
            if not animations_weapon or #animations_weapon < 1 then
                m.item = "N/A"
                m.hint = ""
            else
                m.item = animations_weapon[m.n].." #"..m.n.." of "..#animations_weapon
                m.hint = ""
                local s = sprite.def.animations[sprite.curAnim]
                if sprite_weapon.curAnim ~= animations_weapon[menu[menuState].n] then
                    SetSpriteAnimation(sprite_weapon, animations_weapon[menu[menuState].n])
                end
            end
        elseif i == 4 then
            if m.n > #hero.shaders then
                m.n = #hero.shaders
            end
            if #hero.shaders < 1 then
                m.item = "NO SHADERS"
                m.hint = ""
            else
                if not hero.shaders[m.n] then
                    m.item = "SHADER #"..m.n.." (ORIGINAL)"
                else
                    m.item = "SHADER #"..m.n
                end
                m.hint = ""
            end
        end
        calcMenuItem(menu, i)
        if i == oldMenuState then
            love.graphics.setColor(200, 200, 200, 255)
            love.graphics.print(m.hint, m.wx, m.wy)
            love.graphics.setColor(0, 0, 0, 80)
            love.graphics.rectangle("fill", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4,4,1)
            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4,4,1)
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= old_mouse_y and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin )
        then
            old_mouse_y = mouse_y
            menuState = i
        end
    end
    --header
    love.graphics.setColor(255, 255, 255, 120)
    love.graphics.draw(txtCurrentSprite, (screenWidth - txtCurrentSprite:getWidth()) / 2, title_yOffset)

    --character sprite
    local sc = sprite.def.animations[sprite.curAnim][1]
    local xStep = 140 --(sc.ox or 20) * 4 + 8 or 100
    local x = screenWidth /2
    local y = menu_yOffset + menuItem_h / 2
    if sprite.curAnim == "icon" then --normalize icon's pos
        y = y - 40
        x = x - 40
    end
    love.graphics.setColor(255, 255, 255, 255)
    if hero.shaders[menu[4].n] then
        love.graphics.setShader(hero.shaders[menu[4].n])
    end
    if sprite then --for Obstacles w/o shaders
        if menuState == 2 then
            --1 frame
            love.graphics.setColor(255, 0, 0, 150)
            love.graphics.rectangle("fill", 0, y, screenWidth, 2)
            love.graphics.setColor(0, 0, 255, 150)
            love.graphics.rectangle("fill", x, 0, 2, menu_yOffset + menuItem_h)
            if menu[menuState].n > #sprite.def.animations[sprite.curAnim] then
                menu[menuState].n = 1
            end
            love.graphics.setColor(255, 255, 255, 150)
            for i = 1, #sprite.def.animations[sprite.curAnim] do
                DrawSpriteInstance(sprite, x - (menu[menuState].n - i) * xStep, y, i )
                DrawSpriteWeapon(sprite, x - (menu[menuState].n - i) * xStep, y, i )
            end
            love.graphics.setColor(255, 255, 255, 255)
            DrawSpriteInstance(sprite, x, y, menu[menuState].n)
            DrawSpriteWeapon(sprite, x, y, menu[menuState].n)
        elseif menuState == 3 then
            if sprite_weapon then
                love.graphics.setColor(255, 255, 255, 255)
                sprite_weapon.rotation = 0
                sprite_weapon.flipV = 1
                sprite_weapon.flipH = 1
                DrawSpriteInstance(sprite_weapon, x, y, 1)
            end
        else
            --animation
            DrawSpriteInstance(sprite, x, y)
            DrawSpriteWeapon(sprite, x, y)
        end
    end
    if hero.shaders[menu[3].n] then
            love.graphics.setShader()
    end
    showDebug_indicator()
    push:finish()
end

function spriteEditorState:confirm( x, y, button, istouch )
    if (button == 1 and menuState == #menu) or button == 2 then
        sfx.play("sfx","menuCancel")
        TEsound.stop("music")
        TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
        return Gamestate.pop()
    end
    if button == 1 then
        if menuState == 1 then
            SetSpriteAnimation(sprite, animations[menu[menuState].n])
            sfx.play("sfx","menuSelect")
        elseif menuState == 2 then
            print(ParseSpriteAnimation(sprite))
            sfx.play("sfx","menuSelect")
        elseif menuState == 3 then
            --set current characters frame weapon anim
            if sprite_weapon then
                local s = sprite.def.animations[sprite.curAnim]
                local f = s[menu[2].n]    --current char-sprite frame
                f.wAnimation = animations_weapon[menu[menuState].n]
                sfx.play("sfx","menuSelect")
            else
                sfx.play("sfx","menuCancel")
            end
        elseif menuState == 4 then
            sfx.play("sfx","menuSelect")
        end
    end
end

function spriteEditorState:wheelmoved(x, y)
    local i = 0
    if y > 0 then
        i = 1
    elseif y < 0 then
        i = -1
    else
        return
    end
    menu[menuState].n = menu[menuState].n + i
    if menuState == 1 then
        if menu[menuState].n < 1 then
            menu[menuState].n = #animations
        end
        if menu[menuState].n > #animations then
            menu[menuState].n = 1
        end
        SetSpriteAnimation(sprite, animations[menu[menuState].n])

    elseif menuState == 2 then
        --frames
        if menu[menuState].n < 1 then
            menu[menuState].n = #sprite.def.animations[sprite.curAnim]
        end
        if menu[menuState].n > #sprite.def.animations[sprite.curAnim] then
            menu[menuState].n = 1
        end
        if #sprite.def.animations[sprite.curAnim] <= 1 then
            return
        end

    elseif menuState == 3 then
        --weapon frames
        if not sprite_weapon then
            return
        end
        if menu[menuState].n < 1 then
            menu[menuState].n = #animations_weapon
        end
        if menu[menuState].n > #animations_weapon then
            menu[menuState].n = 1
        end
        SetSpriteAnimation(sprite_weapon, animations_weapon[menu[menuState].n])

    elseif menuState == 4 then
        --shaders
        if #hero.shaders < 1 then
            return
        end
        if menu[menuState].n < 0 then
            menu[menuState].n = #hero.shaders
        end
        if menu[menuState].n > #hero.shaders then
            menu[menuState].n = 0
        end
    end
    if menuState ~= #menu then
        sfx.play("sfx","menuMove")
    end
end

function spriteEditorState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    self:confirm( x, y, button, istouch )
end

function spriteEditorState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end