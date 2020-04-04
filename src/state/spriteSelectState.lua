-- Select Sprite for Sprite Viewer
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

local currentSprite
local currentShader
local heroes = {
    {
        name = "RICK",
        shaders = shaders.rick,
        spriteInstance = "src/def/char/rick",
    },
    {
        name = "KISA",
        shaders = shaders.kisa,
        spriteInstance = "src/def/char/kisa",
    },
    {
        name = "CHAI",
        shaders = shaders.chai,
        spriteInstance = "src/def/char/chai",
    },
    {
        name = "YAR",
        shaders = shaders.yar,
        spriteInstance = "src/def/char/yar",
    },
    {
        name = "GOPPER",
        shaders = shaders.gopper,
        spriteInstance = "src/def/char/gopper",
    },
    {
        name = "NIKO",
        shaders = shaders.niko,
        spriteInstance = "src/def/char/niko",
    },
    {
        name = "SVETA",
        shaders = shaders.sveta,
        spriteInstance = "src/def/char/sveta",
    },
    {
        name = "ZEENA",
        shaders = shaders.zeena,
        spriteInstance = "src/def/char/zeena",
    },
    {
        name = "BEATNIK",
        shaders = shaders.beatnik,
        spriteInstance = "src/def/char/beatnik",
    },
    {
        name = "SATOFF",
        shaders = shaders.satoff,
        spriteInstance = "src/def/char/satoff",
    },
    {
        name = "DR.VOLKER",
        shaders = shaders.drVolker,
        spriteInstance = "src/def/char/drvolker",
    },
    {
        name = "TRASHCAN",
        shaders = shaders.trashcan,
        spriteInstance = "src/def/stage/object/trashcan",
    },
    {
        name = "SIGN",
        shaders = { },
        spriteInstance = "src/def/stage/object/sign",
    },
}

local optionsLogoText = love.graphics.newText( gfx.font.kimberley, "SELECT CHAR/OBJ" )
local txtItems = {"CHARACTER", "BACK"}
local menuItems = {characters = 1, back = 2}

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
    self:showCurrentSprite()
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

    if currentSprite then
        updateSpriteInstance(currentSprite, dt)
    end

    self:playerInput(Controls[1])
end

local function displayHelp()
    local font = love.graphics.getFont()
    local x, y = leftItemOffset, menuOffset_y + menuItem_h
    love.graphics.setFont(gfx.font.arcade3)
    colors:set("gray")
    if menuState == menuItems.characters then
        love.graphics.print(
            [[<- -> / Mouse wheel :
  Select character]], x, y)
    end
    love.graphics.setFont(font)
end

function spriteSelectState:draw()
    push:start()
    displayHelp()
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1,#menu do
        local m = menu[i]
        if i == menuItems.characters then
            if #heroes[m.n].shaders > 0 then
                m.item = heroes[m.n].name.." - "..#heroes[m.n].shaders.." palettes"
            else
                m.item = heroes[m.n].name.." - no palettes"
            end
            m.hint = ""..heroes[m.n].spriteInstance
            currentShader = heroes[m.n].shaders[1]
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
    if currentSprite then
        if currentShader then
            love.graphics.setShader(currentShader)
        end
        drawSpriteInstance(currentSprite, screenWidth / 2, menuOffset_y + menuItem_h / 2)
        if currentShader then
            love.graphics.setShader()
        end
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
        if menuState == menuItems.characters then
            sfx.play("sfx","menuSelect")
            return Gamestate.push(spriteViewerState, heroes[menu[menuState].n])
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
    if menuState == menuItems.characters then
        currentSprite = getSpriteInstance(heroes[menu[menuState].n].spriteInstance)
        setSpriteAnimation(currentSprite,"stand")
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
    if menuState == menuItems.characters then
        if menu[menuState].n < 1 then
            menu[menuState].n = #heroes
        end
        if menu[menuState].n > #heroes then
            menu[menuState].n = 1
        end
        self:showCurrentSprite()
    end
    if menuState ~= #menu then
        sfx.play("sfx","menuMove")
    end
end
