-- Sprite Viewer
spriteViewerState = {}

local time = 0
local screenWidth = 640
local screenHeight = 480
local menuItem_h = 40
local menuOffset_y = 200 - menuItem_h
local menuOffset_x = 0
local hintOffset_y = 80
local titleOffset_y = 24
local leftItemOffset  = 6
local topItemOffset  = 6
local itemWidthMargin = leftItemOffset * 2
local itemHeightMargin = topItemOffset * 2 - 2

local txtCurrentSprite --love.graphics.newText( gfx.font.kimberley, "SPRITE" )
local txtItems = {"ANIMATIONS", "FRAMES", "DISABLED", "PALETTES", "BACK"}

local player
local hero
local sprite
local specialOverlaySprite
local animations

local menu = fillMenu(txtItems)

local menuState, oldMenuState = 1, 1
local mouse_x, mouse_y, oldMouse_y = 0, 0, 0

function spriteViewerState:enter(_, _hero)
    hero = _hero
    sprite = getSpriteInstance(hero.spriteInstance)
    sprite.sizeScale = 2
    txtCurrentSprite = love.graphics.newText( gfx.font.kimberley, hero.name )
    animations = {}
    for key, val in pairs(sprite.def.animations) do
        animations[#animations + 1] = key
    end
    table.sort( animations )
    setSpriteAnimation(sprite,animations[1])
    specialOverlaySprite = getSpriteInstance(hero.spriteInstance .. "_sp")
    if specialOverlaySprite then
        specialOverlaySprite.sizeScale = 2
    end
    menu[1].n = 1
    mouse_x, mouse_y = 0,0
    --TEsound.stop("music")
    -- Prevent double press at start (e.g. auto confirmation)
    Controls[1].attack:update()
    Controls[1].jump:update()
    Controls[1].start:update()
    Controls[1].back:update()
    love.graphics.setLineWidth( 2 )
    self:wheelmoved(0, 0)   --pick 1st sprite to draw
    -- show hitBoxes
    stage = Stage:new()
    player = Rick:new("SPRED", hero.spriteInstance, screenWidth /2, menuOffset_y + menuItem_h / 2)
    player.id = 1   -- fixed id
    player:setOnStage(stage)
    player.doThrow = function() end -- block ability
    player.showEffect = function() end -- block visual effects
    cleanRegisteredPlayers()
end

local function clearPlayerHitBoxes()
    attackHitBoxes = {} -- DEBUG
end
local function getPlayerHitBoxes()
    local sc = sprite.def.animations[sprite.curAnim][menu[menuState].n]
    clearPlayerHitBoxes()
    if sc then
        if sc.funcCont and player then
            sc.funcCont(player, true) --isfuncCont = true
        end
        if sc.func then
            sc.func(player, false) --isfuncCont = false
        end
    end
end

local function displayHelp()
    local font = love.graphics.getFont()
    local x, y = leftItemOffset, menuOffset_y + menuItem_h
    love.graphics.setFont(gfx.font.arcade3)
    colors:set("gray")
    if menuState == 1 then
        love.graphics.print(
[[<- -> / Mouse wheel :
  Select animation

Attack/Enter :
  Replay animation]], x, y)
    elseif menuState == 2 then
        love.graphics.print(
[[<- -> / Mouse wheel :
  Select frame
L-Shift + <- -> Up Down :
  Frame Position (ox,oy)
L-Alt + <- -> :
  Rotate Character
L-Ctrl + <- -> Up Down :
  FlipH/V Character
Attack/Enter :
  Dump to Console


Use R-Alt, R-Ctrl, R-Shift for Overlay operations]], x, y)
    elseif menuState == 4 then
        love.graphics.print(
[[<- -> / Mouse wheel :
  Select palette]], x, y)
    end
    love.graphics.setFont(font)
end

--Only P1 can use menu / options
function spriteViewerState:playerInput(controls)
    local s, f
    local m = menu[menuState]
    if menuState == 2 then --static frame
        if love.keyboard.isDown('lctrl') or love.keyboard.isDown('lshift') or love.keyboard.isDown('lalt') then
            s = sprite.def.animations[sprite.curAnim]
        elseif specialOverlaySprite and spriteHasAnimation(specialOverlaySprite, sprite.curAnim) then
            s = specialOverlaySprite.def.animations[sprite.curAnim]
        end
        if s then
            f = s[m.n]    --current frame
            if love.keyboard.isDown('lctrl', 'rctrl') then
                --flip sprite frame horizontally & vertically
                if controls.horizontal:pressed() then
                    f.flipH = controls.horizontal:getValue()
                end
                if controls.vertical:pressed() then
                    f.flipV = controls.vertical:getValue()
                end
                return
            end
            if love.keyboard.isDown('lshift', 'rshift') then
                --change ox, oy offset of the sprite frame
                if controls.horizontal:pressed() then
                    f.ox = f.ox + controls.horizontal:getValue()
                end
                if controls.vertical:pressed() then
                    f.oy = f.oy + controls.vertical:getValue()
                end
                return
            end
            if love.keyboard.isDown('lalt', 'ralt') then
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

function spriteViewerState:update(dt)
    time = time + dt
    if menuState ~= oldMenuState then
        sfx.play("sfx","menuMove")
        oldMenuState = menuState
    end
    if sprite then
        updateSpriteInstance(sprite, dt)
    end
    self:playerInput(Controls[1])
end

function spriteViewerState:draw()
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
            local so = specialOverlaySprite and specialOverlaySprite.def.animations[sprite.curAnim] or nil
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
                m.hint = m.hint .. "\nox="..s[m.n].ox..",oy="..s[m.n].oy
            end
            if so and so[m.n].ox and so[m.n].oy then
                m.hint = m.hint .. ", Overlay ox="..so[m.n].ox..",oy="..so[m.n].oy.." "
            end
            if s[m.n].rotate then
                m.hint = m.hint .. "R:"..s[m.n].rotate.." RXY:"..(s[m.n].rx or 0)..","..(s[m.n].ry or 0).." "
            end
        elseif i == 4 then
            if m.n > #hero.shaders then
                m.n = #hero.shaders
            end
            if #hero.shaders < 1 then
                m.item = "NO PALETTES"
                m.hint = ""
            else
                if not hero.shaders[m.n] then
                    m.item = "PALETTE #"..m.n.." (ORIGINAL)"
                else
                    m.item = "PALETTE #"..m.n
                end
                m.hint = ""
            end
        end
        calcMenuItem(menu, i)
        if i == oldMenuState then
            colors:set("lightGray")
            love.graphics.print(m.hint, m.wx, m.wy)
            colors:set("black", nil, 80)
            love.graphics.rectangle("fill", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4,4,1)
            colors:set("menuOutline")
            love.graphics.rectangle("line", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4,4,1)
        end
        colors:set("white")
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= oldMouse_y and
            CheckPointCollision(mouse_x, mouse_y, m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin )
        then
            oldMouse_y = mouse_y
            menuState = i
        end
    end
    --header
    colors:set("white", nil, 120)
    love.graphics.draw(txtCurrentSprite, (screenWidth - txtCurrentSprite:getWidth()) / 2, titleOffset_y)

    --character sprite
    local xStep = 140 --(sc.ox or 20) * 4 + 8 or 100
    local x = screenWidth /2
    local y = menuOffset_y + menuItem_h / 2
    if sprite.curAnim == "icon" then --normalize icon's pos
        y = y - 40
        x = x - 40
    end
    colors:set("white")
    if hero.shaders[menu[4].n] then
        love.graphics.setShader(hero.shaders[menu[4].n])
    end
    if sprite then --for stage objects w/o shaders
        if menuState == 2 then
            --1 frame
            colors:set("red", nil, 150)
            love.graphics.rectangle("fill", 0, y, screenWidth, 2)
            colors:set("blue", nil, 150)
            love.graphics.rectangle("fill", x, 0, 2, menuOffset_y + menuItem_h)
            if menu[menuState].n > #sprite.def.animations[sprite.curAnim] then
                menu[menuState].n = 1
            end
            colors:set("white", nil, 150)
            for i = 1, #sprite.def.animations[sprite.curAnim] do
                if i ~= menu[menuState].n then
                    drawSpriteInstance(sprite, x - (menu[menuState].n - i) * xStep, y, i )
                    if specialOverlaySprite then
                        if spriteHasAnimation(specialOverlaySprite, sprite.curAnim) then
                            drawSpriteCustomInstance(specialOverlaySprite, x - (menu[menuState].n - i) * xStep, y, sprite.curAnim, i)
                        end
                    end
                end
            end
            if isDebug() then
                showDebugBoxes(sprite.sizeScale)
            end
            colors:set("white")
            drawSpriteInstance(sprite, x, y, menu[menuState].n)
            if isDebug() then
                drawDebugUnitHurtBox(sprite, x, y, menu[menuState].n, sprite.sizeScale)
            end
            if specialOverlaySprite then
                if spriteHasAnimation(specialOverlaySprite, sprite.curAnim) then
                    drawSpriteCustomInstance(specialOverlaySprite, x , y, sprite.curAnim, menu[menuState].n)
                end
            end
        else
            --animation
            drawSpriteInstance(sprite, x, y)
            if specialOverlaySprite then
                if spriteHasAnimation(specialOverlaySprite, sprite.curAnim) then
                    drawSpriteCustomInstance(specialOverlaySprite, x , y, sprite.curAnim, sprite.curFrame)
                end
            end
        end
    end
    showDebugIndicator()
    push:finish()
end

function spriteViewerState:confirm( x, y, button, istouch )
    if (button == 1 and menuState == #menu) or button == 2 then
        sfx.play("sfx","menuCancel")
        TEsound.stop("music")
        TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
        return Gamestate.pop()
    end
    if button == 1 then
        if menuState == 1 then
            setSpriteAnimation(sprite, animations[menu[menuState].n])
            sfx.play("sfx","menuSelect")
        elseif menuState == 2 then
            print(parseSpriteAnimation(sprite))
            sfx.play("sfx","menuSelect")
        elseif menuState == 4 then
            sfx.play("sfx","menuSelect")
        end
    end
end

function spriteViewerState:wheelmoved(x, y)
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
        setSpriteAnimation(sprite, animations[menu[menuState].n])

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
        getPlayerHitBoxes()
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

function spriteViewerState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    self:confirm( x, y, button, istouch )
end

function spriteViewerState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end
