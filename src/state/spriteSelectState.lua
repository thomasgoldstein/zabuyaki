-- Select Sprite for Sprite Editor
spriteSelectState = {}

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

local sprite
local heroes = {
    {
        name = "RICK",
        shaders = {nil, shaders.rick[1], shaders.rick[2]},
        spriteInstance = "src/def/char/rick.lua",
    },
    {
        name = "KISA",
        shaders = {nil, shaders.kisa[1], shaders.kisa[2]},
        spriteInstance = "src/def/char/kisa.lua",
    },
    {
        name = "CHAI",
        shaders = {nil, shaders.chai[1], shaders.chai[2]},
        spriteInstance = "src/def/char/chai.lua",
    },
    {
        name = "CHAI_SP",
        shaders = {nil, nil, nil},
        spriteInstance = "src/def/char/chai_sp.lua",
    },
    {
        name = "YAR",
        shaders = {nil, nil, nil},
        spriteInstance = "src/def/char/yar.lua",
    },
    {
        name = "GOPPER",
        shaders = shaders.gopper,
        spriteInstance = "src/def/char/gopper.lua",
    },
    {
        name = "NIKO",
        shaders = shaders.niko,
        spriteInstance = "src/def/char/niko.lua",
    },
    {
        name = "SVETA",
        shaders = shaders.sveta,
        spriteInstance = "src/def/char/sveta.lua",
    },
    {
        name = "ZEENA",
        shaders = shaders.zeena,
        spriteInstance = "src/def/char/zeena.lua",
    },
    {
        name = "BEATNICK",
        shaders = shaders.beatnick,
        spriteInstance = "src/def/char/beatnick.lua",
    },
    {
        name = "SATOFF",
        shaders = shaders.satoff,
        spriteInstance = "src/def/char/satoff.lua",
    },
    {
        name = "TRASHCAN",
        shaders = shaders.trashcan,
        spriteInstance = "src/def/stage/object/trashcan.lua",
    },
    {
        name = "SIGN",
        shaders = { },
        spriteInstance = "src/def/stage/object/sign.lua",
    },
}

local weapons = {
    {
        name = "BAT",
        shaders = { },
        spriteInstance = "src/def/misc/bat.lua",
    },
    {
        name = "BAT2", -- testing > 1 weapons
        shaders = { },
        spriteInstance = "src/def/misc/bat.lua",
    }
}

local optionsLogoText = love.graphics.newText( gfx.font.kimberley, "SELECT CHAR/OBJ" )
local txtItems = {"FRAME POSITIONING", "WEAPON POSITIONING", "BACK"}

local menu = fillMenu(txtItems)

local menuState, oldMenuState = 1, 1
local mouse_x, mouse_y, oldMouse_y = 0, 0, 0

function spriteSelectState:enter()
    mouse_x, mouse_y = 0,0
    --TEsound.stop("music")
    -- Prevent double press at start (e.g. auto confirmation)
    Controls[1].attack:update()
    Controls[1].jump:update()
    Controls[1].start:update()
    Controls[1].back:update()
    love.graphics.setLineWidth( 2 )
    self:wheelmoved(0, 0)   --pick 1st sprite to draw
end

--Only P1 can use menu / options
function spriteSelectState:playerInput(controls)
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

function spriteSelectState:update(dt)
    time = time + dt
    if menuState ~= oldMenuState then
        sfx.play("sfx","menuMove")
        oldMenuState = menuState
        self:showCurrentSprite()
    end

    if sprite then
        updateSpriteInstance(sprite, dt)
    end

    self:playerInput(Controls[1])
end

function spriteSelectState:draw()
    push:start()
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1,#menu do
        local m = menu[i]
        if i == 1 then
            if #heroes[m.n].shaders > 0 then
                m.item = heroes[m.n].name.." - "..#heroes[m.n].shaders.." shaders"
            else
                m.item = heroes[m.n].name.." - no shaders"
            end
            m.hint = ""..heroes[m.n].spriteInstance
        elseif i == 2 then
            if m.n > #weapons then  --TODO plug while dont have any wep
                m.n = #weapons
            end
            if m.n == 0 then
                m.item = "N/A"
                m.hint = "NO WEAPONS"
            else
                m.item = "WEAPON #"..m.n.." "..weapons[m.n].name
                m.hint = "..."
            end
        end
        calcMenuItem(menu, i)
        if i == oldMenuState then
            colors:set("white")
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
    colors:set("white")
    love.graphics.draw(optionsLogoText, (screenWidth - optionsLogoText:getWidth()) / 2, titleOffset_y)

    --sprite
    colors:set("white")
--    if curPlayerHeroSet.shader then
--        love.graphics.setShader(curPlayerHeroSet.shader)
--    end
    if sprite then
        drawSpriteInstance(sprite, screenWidth / 2, menuOffset_y + menuItem_h / 2)
    end
--    if curPlayerHeroSet.shader then
--        love.graphics.setShader()
--    end
    showDebugIndicator()
    push:finish()
end

function spriteSelectState:confirm( x, y, button, istouch )
    if (button == 1 and menuState == #menu) or button == 2 then
        sfx.play("sfx","menuCancel")
        TEsound.stop("music")
        TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
        return Gamestate.pop()
    end
    if button == 1 then
        if menuState == 1 then
            sfx.play("sfx","menuSelect")
            return Gamestate.push(spriteEditorState, heroes[menu[menuState].n], weapons[menu[2].n])
        elseif menuState == 2 then
            if weapons[menu[menuState].n] then
                sfx.play("sfx","menuSelect")
                return Gamestate.push(spriteEditorState, weapons[menu[menuState].n])
            else
                sfx.play("sfx","menuCancel")
            end
        end
    end
end

function spriteSelectState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    self:confirm( x, y, button, istouch )
end

function spriteSelectState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end

function spriteSelectState:showCurrentSprite()
    if menuState == 1 then
        sprite = getSpriteInstance(heroes[menu[menuState].n].spriteInstance)
        --sprite.sizeScale = 2
        setSpriteAnimation(sprite,"stand")

    elseif menuState == 2 then
        if weapons[menu[menuState].n] then
            sprite = getSpriteInstance(weapons[menu[menuState].n].spriteInstance)
            --sprite.sizeScale = 2
            setSpriteAnimation(sprite,"stand")
        else
            sprite = nil
        end
    end
end

function spriteSelectState:wheelmoved(x, y)
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
            menu[menuState].n = #heroes
        end
        if menu[menuState].n > #heroes then
            menu[menuState].n = 1
        end
        self:showCurrentSprite()

    elseif menuState == 2 then
        if menu[menuState].n < 0 then
            menu[menuState].n = #weapons
        end
        if menu[menuState].n > #weapons then
            menu[menuState].n = 0
        end
        self:showCurrentSprite()
    end
    if menuState ~= #menu then
        sfx.play("sfx","menuMove")
    end
end
