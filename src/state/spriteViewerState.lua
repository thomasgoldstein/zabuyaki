spriteViewerState = {}

local time = 0
local menuState, oldMenuState = 1, 1
local menuParams = {
    center = true,
    screenWidth = 640,
    screenHeight = 480,
    menuItem_h = 40,
    menuOffset_y = 160, -- override
    menuOffset_x = 0,
    hintOffset_y = 80,
    titleOffset_y = 14,
    leftItemOffset = 6,
    topItemOffset = 6,
    itemWidthMargin = 12,
    itemHeightMargin = 10
}
local menuTitle
local txtItems = {"ANIMATIONS", "FRAMES", "PALETTES", "BACK"}
local menuItems = {animations = 1, frames = 2, palettes = 3, back = 4}
local menu = fillMenu(txtItems, nil, menuParams)

local character, unit, sprite, specialOverlaySprite, animations
local character2, unit2, sprite2, unit2InitialFacing
local saveUnitSpriteInstance

local function resetSpritesFacingAndAnim()  -- initial sprite and sprite2 facing, sprite2 animation
    character.face = 1
    character2.face = unit2InitialFacing
    sprite2.flipH = unit2InitialFacing
    if unit2InitialFacing == -1 then
        sprite2.curAnim = spriteHasAnimation(sprite2, "grabbedFront") and "grabbedFront" or "stand"
    else
        sprite2.curAnim = spriteHasAnimation(sprite2, "grabbedBack") and "grabbedBack" or "stand"
    end
end

function spriteViewerState:enter(_, _unit, _unit2, flipH)
    unit = _unit
    saveUnitSpriteInstance = unit.spriteInstance
    sprite = getSpriteInstance(unit.spriteInstance)
    sprite.sizeScale = 2
    menuTitle = love.graphics.newText( gfx.font.kimberley, unit.name )
    animations = {}
    for key, val in pairs(sprite.def.animations) do
        animations[#animations + 1] = key
    end
    table.sort( animations )
    setSpriteAnimation(sprite,animations[1])
    specialOverlaySprite = getSpriteInstance(unit.spriteInstance .. "_sp")
    if specialOverlaySprite then
        specialOverlaySprite.sizeScale = 2
    end
    menu[menuItems.animations].n = 1
    -- Prevent double press at start (e.g. auto confirmation)
    Controls[1].attack:update()
    Controls[1].jump:update()
    Controls[1].start:update()
    Controls[1].back:update()
    love.graphics.setLineWidth( 2 )
    -- to show hitBoxes:
    stage = Stage:new()
    character = Character:new("SPRITE", unit.spriteInstance, menuParams.screenWidth /2, menuParams.menuOffset_y + menuParams.menuItem_h / 2)
    character.id = 1   -- fixed id
    character:setOnStage(stage)
    character.doThrow = function() end -- block ability
    character.showEffect = function() end -- block visual effects
    -- the aux unit/character/sprite
    unit2InitialFacing = flipH
    unit2 = _unit2
    character2 = Character:new("SPRITE2", unit2.spriteInstance, menuParams.screenWidth /2 + 100, menuParams.menuOffset_y + menuParams.menuItem_h / 2)
    character2.id = 2   -- fixed id
    character2:setOnStage(stage)
    character2.doThrow = function() end -- block ability
    character2.showEffect = function() end -- block visual effects
    sprite2 = character2.sprite
    sprite2.sizeScale = 2
    -- grab context for glued sprites, for moveStatesApply
    local g = character.grabContext
    local gTarget = character2.grabContext
    gTarget.source = unit
    gTarget.target = nil
    character2.isGrabbed = true
    g.source = nil
    g.target = character2
    resetSpritesFacingAndAnim()
end

local function clearCharacterHitBoxes()
    attackHitBoxes = {} -- DEBUG
end
local function getCharacterHitBoxes()
    local sc = sprite.def.animations[sprite.curAnim][menu[menuState].n]
    clearCharacterHitBoxes()
    if sc then
        if sc.funcCont and character then
            pcall(sc.funcCont, character, true) --isfuncCont = true
        end
        if sc.func then
            pcall( sc.func, character, false) --isfuncCont = false
        end
    end
end

local function displayHelp()
    local font = love.graphics.getFont()
    local x, y = menuParams.leftItemOffset, menuParams.menuOffset_y + menuParams.menuItem_h
    love.graphics.setFont(gfx.font.arcade3)
    colors:set("gray")
    if menuState == menuItems.animations then
        love.graphics.print(
[[<- -> :
  Select animation

Attack/Enter :
  Replay animation

F5 :
  Reload sprite def and spritesheet image]], x, y)
    elseif menuState == menuItems.frames then
        love.graphics.print(
[[<- -> :
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
    elseif menuState == menuItems.palettes then
        love.graphics.print(
[[<- -> :
  Select palette]], x, y)
    end
    love.graphics.setFont(font)
end

function spriteViewerState:keypressed( key, scancode, isrepeat )
    if key == 'f5' then
        sfx.play("sfx","menuSelect")
        removeSpriteFromImageBank(saveUnitSpriteInstance)
        sprite = getSpriteInstance(saveUnitSpriteInstance)
        sprite.sizeScale = 2
        animations = {}
        for key, val in pairs(sprite.def.animations) do
            animations[#animations + 1] = key
        end
        table.sort( animations )
        menu[menuItems.animations].n = math.min(menu[menuItems.animations].n, #animations)
        setSpriteAnimation(sprite,animations[menu[menuItems.animations].n])
        removeSpriteFromImageBank(saveUnitSpriteInstance .. "_sp")
        specialOverlaySprite = getSpriteInstance(saveUnitSpriteInstance .. "_sp")
        if specialOverlaySprite then
            specialOverlaySprite.sizeScale = 2
        end
    elseif scancode >= 'a' and scancode <= 'z' then
        if menuState == menuItems.animations then
            local first, last = #animations, 1
            local n = menu[menuItems.animations].n
            for i = 1, #animations do
                local a = animations[i]
                if i < first and a:sub(1,1):lower() == scancode then
                    first = i
                end
                if i > last and a:sub(1,1):lower() == scancode then
                    last = i
                end
            end
            if first == #animations and last == 1 then return end
            n = n + 1
            if n < first or n > last then n = first end
            menu[menuItems.animations].n = n
            setSpriteAnimation(sprite, animations[n])
        end
    end
end

--Only P1 can use menu / options
function spriteViewerState:playerInput(controls)
    local s, f
    local m = menu[menuState]
    if menuState == menuItems.frames then --static frame
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
        return self:confirm( 1)
    end
    local h = controls.horizontal:getValue()
    if controls.horizontal:pressed(-1) or controls.horizontal:pressed(1) then
        self:select(h)
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
    if sprite2 then
        local s = sprite2.def.animations[sprite2.curAnim]
        local sc = s[sprite2.curFrame]
        if not sc then
            sprite2.curFrame = 1
        end
        updateSpriteInstance(sprite2, dt)
    end
    if menuState == menuItems.animations then
        if sprite then
            updateSpriteInstance(sprite, dt)
        end
    end
    self:playerInput(Controls[1])
end

function spriteViewerState:displayGrabbedUnit()
    return character:hasMoveOStates(sprite, sprite.curAnim, sprite.curFrame)
end

local function delayToFrames(n) return n <= 1/60 and 1 or math.ceil(n * 60) end
function spriteViewerState:draw()
    push:start()
    displayHelp()
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1,#menu do
        local m = menu[i]
        if i == menuItems.animations then
            m.item = animations[m.n].." #"..m.n
            local m2 = menu[menuItems.frames]
            if m2.n > #sprite.def.animations[sprite.curAnim] then
                m2.n = #sprite.def.animations[sprite.curAnim]
            end
            m2.item = "FRAME #"..m2.n.." of "..#sprite.def.animations[sprite.curAnim]
            m.hint = ""
        elseif i == menuItems.frames then
            local s = sprite.def.animations[sprite.curAnim]
            local so = specialOverlaySprite and specialOverlaySprite.def.animations[sprite.curAnim] or nil
            m.item = "FRAME #"..m.n.." of "..#sprite.def.animations[sprite.curAnim]
            m.hint = ""
            if s[m.n].delay then
                m.hint = m.hint .. "FR.DELAY "..s[m.n].delay.."s " .. delayToFrames(s[m.n].delay) .. "fr "
            elseif s.delay then
                m.hint = m.hint .. "DELAY "..s.delay.."s " .. delayToFrames(s.delay) .. "fr "
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
            local tAnimation, t = character:hasMoveStatesFrame(sprite, sprite.curAnim, menu[menuState].n)
            if t then
                m.hint = m.hint .. "\n"..t
            end
        elseif i == menuItems.palettes then
            if m.n > #unit.shaders then
                m.n = #unit.shaders
            end
            if #unit.shaders < 1 then
                m.item = "NO PALETTES"
                m.hint = ""
            else
                if not unit.shaders[m.n] then
                    m.item = "PALETTE #"..m.n.." (ORIGINAL)"
                else
                    if unit.shaders.aliases then
                        local aliases = {}
                        for v,k in pairs(unit.shaders.aliases) do
                            aliases[k] = v
                        end
                        if aliases[m.n] then
                            m.item = "PALETTE #"..m.n..' "'..aliases[m.n]..'"'
                        else
                            m.item = "PALETTE #"..m.n..' (NO ALIAS)'
                        end
                    else
                        m.item = "PALETTE #"..m.n
                    end
                end
                m.hint = ""
            end
        end
        drawMenuItem(menu, i, oldMenuState)
    end
    drawMenuTitle(menu, menuTitle, 120)
    --character sprite
    local xStep = 140 --(sc.ox or 20) * 4 + 8 or 100
    local x = menuParams.screenWidth /2
    local y = menuParams.menuOffset_y + menuParams.menuItem_h / 2
    if sprite.curAnim == "icon" then --normalize icon's pos
        y = y - 40
        x = x - 40
    end
    colors:set("white")
    if unit.shaders[menu[menuItems.palettes].n] then
        love.graphics.setShader(unit.shaders[menu[menuItems.palettes].n])
    end
    if sprite then --for stage objects w/o shaders
        if menuState == menuItems.frames then
            --1 frame
            colors:set("red", nil, 150)
            love.graphics.rectangle("fill", 0, y, menuParams.screenWidth, 2)
            colors:set("blue", nil, 150)
            love.graphics.rectangle("fill", x, 0, 2, menuParams.menuOffset_y + menuParams.menuItem_h)
            if menu[menuState].n > #sprite.def.animations[sprite.curAnim] then
                menu[menuState].n = 1
            end
            for i = 1, #sprite.def.animations[sprite.curAnim] do
                if i == 1 then -- reset facing for animation with 'moves' table
                    resetSpritesFacingAndAnim()
                end
                colors:set("blue", nil, 150)
                love.graphics.rectangle("fill", x, 0, 2, menuParams.menuOffset_y + menuParams.menuItem_h)
                colors:set("white", nil, 150)
                if i ~= menu[menuState].n then
                    drawSpriteInstance(sprite, x - (menu[menuState].n - i) * xStep, y, i )
                    if specialOverlaySprite then
                        if spriteHasAnimation(specialOverlaySprite, sprite.curAnim) then
                            drawSpriteCustomInstance(specialOverlaySprite, x - (menu[menuState].n - i) * xStep, y, sprite.curAnim, i)
                        end
                    end
                else
                    character.x = 0; character.y = 0; character.z = 0
                    character2.x = character:getGrabDistance()
                    character2.y = 0; character2.z = 0
                    character:moveStatesInit()
                    character:getMoveStates(sprite, sprite.curAnim, i) -- sync pos/anim of aux sprite
                    if self:displayGrabbedUnit() then
                        local tAnimation = character:hasMoveStatesFrame(sprite, sprite.curAnim, i)
                        if tAnimation then
                            colors:set("darkGray")
                            love.graphics.print("*" .. tAnimation, x + 2, y + 2)
                        end
                        colors:set("white", nil, 200)
                        drawSpriteInstance(sprite2, x + character2.x * sprite2.sizeScale, y - character2.z * sprite2.sizeScale, sprite2.curFrame )
                    end
                    colors:set("white")
                    drawSpriteInstance(sprite, x + character.x * sprite.sizeScale, y - character.z * sprite.sizeScale, i)
                    drawDebugUnitHurtBox(sprite, x + character.x * sprite.sizeScale, y - character.z * sprite.sizeScale, i, sprite.sizeScale)
                    if specialOverlaySprite then
                        if spriteHasAnimation(specialOverlaySprite, sprite.curAnim) then
                            drawSpriteCustomInstance(specialOverlaySprite, x + character.x * sprite.sizeScale, y - character.z * sprite.sizeScale, sprite.curAnim, i)
                        end
                    end
                    drawDebugHitBoxes(x, y, sprite.sizeScale)
                end
            end
        else
            --animation
            character.x = 0; character.y = 0; character.z = 0 -- reset sprite pos for start animation
            character2.x = character:getGrabDistance()
            character2.y = 0; character2.z = 0
            character:moveStatesInit()
            character:getMoveStates(sprite, sprite.curAnim, sprite.curFrame) -- sync pos/anim of aux sprite
            if self:displayGrabbedUnit() then
                colors:set("white", nil, 200)
                drawSpriteInstance(sprite2, x + character2.x * sprite2.sizeScale, y - character2.z * sprite2.sizeScale )
            end
            colors:set("white")
            drawSpriteInstance(sprite, x + character.x * sprite.sizeScale, y - character.z * sprite.sizeScale)
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

function spriteViewerState:confirm(button)
    if (button == 1 and menuState == #menu) or button == 2 then
        sfx.play("sfx","menuCancel")
        return Gamestate.pop()
    end
    if button == 1 then
        if menuState == menuItems.animations then
            setSpriteAnimation(sprite, animations[menu[menuState].n])
            resetSpritesFacingAndAnim()
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.frames then
            print(parseSpriteAnimation(sprite))
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.palettes then
            sfx.play("sfx","menuSelect")
        end
    end
end

function spriteViewerState:select(i)
    menu[menuState].n = menu[menuState].n + i
    if menuState == menuItems.animations then
        if menu[menuState].n < 1 then
            menu[menuState].n = #animations
        end
        if menu[menuState].n > #animations then
            menu[menuState].n = 1
        end
        setSpriteAnimation(sprite, animations[menu[menuState].n])
    elseif menuState == menuItems.frames then
        if menu[menuState].n < 1 then
            menu[menuState].n = #sprite.def.animations[sprite.curAnim]
        end
        if menu[menuState].n > #sprite.def.animations[sprite.curAnim] then
            menu[menuState].n = 1
        end
        if #sprite.def.animations[sprite.curAnim] <= 1 then
            return
        end
        getCharacterHitBoxes()
    elseif menuState == menuItems.palettes then
        if #unit.shaders < 1 then
            return
        end
        if menu[menuState].n < 1 then
            menu[menuState].n = #unit.shaders
        end
        if menu[menuState].n > #unit.shaders then
            menu[menuState].n = 1
        end
    end
    if menuState ~= #menu then
        sfx.play("sfx","menuMove")
    end
end
