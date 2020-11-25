spriteSelectState = {}

local time = 0
local menuState, oldMenuState = 1, 1
local menuParams = {
    center = true,
    screenWidth = 640,
    screenHeight = 480,
    menuItem_h = 40,
    menuOffset_y = 180, -- override
    menuOffset_x = 0,
    hintOffset_y = 80,
    titleOffset_y = 14,
    leftItemOffset = 6,
    topItemOffset = 6,
    itemWidthMargin = 12,
    itemHeightMargin = 10
}
local menuTitle = love.graphics.newText( gfx.font.kimberley, "SELECT CHAR/OBJ" )
local txtItems = {"CHARACTER", "BACK"}
local menuItems = {characters = 1, back = 2}
local menu = fillMenu(txtItems, nil, menuParams)

local currentSprite, currentShader
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
        name = "HOOCH",
        shaders = shaders.hooch,
        spriteInstance = "src/def/char/hooch",
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

function spriteSelectState:enter()
    -- Prevent double press at start (e.g. auto confirmation)
    Controls[1].attack:update()
    Controls[1].jump:update()
    Controls[1].start:update()
    Controls[1].back:update()
    love.graphics.setLineWidth( 2 )
    self:showCurrentSprite()
end

--Only P1 can use menu / options
function spriteSelectState:playerInput(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menuCancel")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return self:confirm(1)
    end
    if controls.horizontal:pressed(-1)then
        self:select(-1)
    elseif controls.horizontal:pressed(1)then
        self:select(1)
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
    local x, y = menuParams.leftItemOffset, menuParams.menuOffset_y + menuParams.menuItem_h
    love.graphics.setFont(gfx.font.arcade3)
    colors:set("gray")
    if menuState == menuItems.characters then
        love.graphics.print(
            [[<- -> :
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
        drawMenuItem(menu, i, oldMenuState)
    end
    drawMenuTitle(menu, menuTitle)
    --sprite
    colors:set("white")
    if currentSprite then
        if currentShader then
            love.graphics.setShader(currentShader)
        end
        drawSpriteInstance(currentSprite, menuParams.screenWidth / 2, menuParams.menuOffset_y + menuParams.menuItem_h / 2)
        if currentShader then
            love.graphics.setShader()
        end
    end
    showDebugIndicator()
    push:finish()
end

function spriteSelectState:confirm(button)
    if (button == 1 and menuState == #menu) or button == 2 then
        sfx.play("sfx","menuCancel")
        return Gamestate.pop()
    end
    if button == 1 then
        if menuState == menuItems.characters then
            sfx.play("sfx","menuSelect")
            return Gamestate.push(spriteViewerState, heroes[menu[menuState].n])
        end
    end
end

function spriteSelectState:showCurrentSprite()
    if menuState == menuItems.characters then
        currentSprite = getSpriteInstance(heroes[menu[menuState].n].spriteInstance)
        setSpriteAnimation(currentSprite,"stand")
    end
end

function spriteSelectState:select(i)
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
