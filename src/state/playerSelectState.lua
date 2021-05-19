playerSelectState = {}

local time = 0
local screenWidth = 640
local screenHeight = 480
local titleOffset_y = 14
local portraitWidth = 140
local portraitHeight = 140
local portraitMargin = 0
local portraitOffset_x = 110
local availableHeroes = 4
local playerSelectText = love.graphics.newText( gfx.font.kimberley, "PLAYER SELECT" )

local heroes = {
    {
        {name = "RICK", palette = 1},
        {name = "RICK", palette = 2},
        {name = "RICK", palette = 3},
        hero = Rick,
        spriteInstance = "src/def/char/rick",
        sprite_portrait = getSpriteInstance("src/def/misc/portraits"),
        sprite_portraitAnim = "rick",
        defaultAnim = "stand",
        cancelAnim = "hurtHighWeak",
        confirmAnim = "walk",
        x = portraitOffset_x,
        y = 440,    --char sprite
        sy = 272,   --selected P1 P2 P3
        ny = 90,   --char name
        py = 120    --Portrait
    },
    {
        {name = "KISA", palette = 1},
        {name = "KISA", palette = 2},
        {name = "KISA", palette = 3},
        hero = Kisa,
        spriteInstance = "src/def/char/kisa",
        sprite_portrait = getSpriteInstance("src/def/misc/portraits"),
        sprite_portraitAnim = "kisa",
        defaultAnim = "stand",
        cancelAnim = "hurtLowWeak",
        confirmAnim = "walk",
        x = portraitOffset_x + (portraitMargin + portraitWidth) * 1,
        y = 440,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "CHAI", palette = 1},
        {name = "CHAI", palette = 2},
        {name = "CHAI", palette = 3},
        hero = Chai,
        spriteInstance = "src/def/char/chai",
        sprite_portrait = getSpriteInstance("src/def/misc/portraits"),
        sprite_portraitAnim = "chai",
        defaultAnim = "stand",
        cancelAnim = "hurtHighWeak",
        confirmAnim = "walk",
        x = portraitOffset_x + (portraitMargin + portraitWidth) * 2,
        y = 440,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "YAR", palette = 1},
        {name = "YAR", palette = 2},
        {name = "YAR", palette = 3},
        hero = Yar,
        spriteInstance = "src/def/char/yar",
        sprite_portrait = getSpriteInstance("src/def/misc/portraits"),
        sprite_portraitAnim = "yar",
        defaultAnim = "stand",
        cancelAnim = "hurtHighWeak",
        confirmAnim = "walk",
        x = portraitOffset_x + (portraitMargin + portraitWidth) * 3,
        y = 440,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "GOPPER", palette = 1},
        {name = "GOPPER", palette = 2},
        {name = "GOPPER", palette = 3},
        {name = "GOPPER", palette = 4},
        hero = PGopper,
        spriteInstance = "src/def/char/gopper",
        sprite_portrait = getSpriteInstance("src/def/misc/portraits"),
        sprite_portraitAnim = "rick", --NO OWN PORTRAIT
        defaultAnim = "stand",
        cancelAnim = "hurtHighWeak",
        confirmAnim = "walk",
        x = screenWidth / 2,
        y = 440 + 80,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "NIKO", palette = 1},
        {name = "NIKO", palette = 1},
        {name = "NIKO", palette = 1},
        hero = PNiko,
        spriteInstance = "src/def/char/niko",
        sprite_portrait = getSpriteInstance("src/def/misc/portraits"),
        sprite_portraitAnim = "rick", --NO OWN PORTRAIT
        defaultAnim = "stand",
        cancelAnim = "hurtHighWeak",
        confirmAnim = "walk",
        x = screenWidth / 2 - 80,
        y = 440 + 80,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "SVETA", palette = 1},
        {name = "SVETA", palette = 1},
        {name = "SVETA", palette = 1},
        hero = PSveta,
        spriteInstance = "src/def/char/sveta",
        sprite_portrait = getSpriteInstance("src/def/misc/portraits"),
        sprite_portraitAnim = "rick", --NO OWN PORTRAIT
        defaultAnim = "stand",
        cancelAnim = "hurtHighWeak",
        confirmAnim = "walk",
        x = screenWidth / 2 - 80,
        y = 440 + 80,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "ZEENA", palette = 1},
        {name = "ZEENA", palette = 1},
        {name = "ZEENA", palette = 1},
        hero = PZeena,
        spriteInstance = "src/def/char/zeena",
        sprite_portrait = getSpriteInstance("src/def/misc/portraits"),
        sprite_portraitAnim = "rick", --NO OWN PORTRAIT
        defaultAnim = "stand",
        cancelAnim = "hurtHighWeak",
        confirmAnim = "walk",
        x = screenWidth / 2 - 80,
        y = 440 + 80,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "HOOCH", palette = 1},
        {name = "HOOCH", palette = 1},
        {name = "HOOCH", palette = 1},
        hero = PHooch,
        spriteInstance = "src/def/char/hooch",
        sprite_portrait = getSpriteInstance("src/def/misc/portraits"),
        sprite_portraitAnim = "rick", --NO OWN PORTRAIT
        defaultAnim = "stand",
        cancelAnim = "hurtHighWeak",
        confirmAnim = "walk",
        x = screenWidth / 2 - 80,
        y = 440 + 80,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "BEATNIK", palette = 1},
        {name = "BEATNIK", palette = 1},
        {name = "BEATNIK", palette = 1},
        hero = PBeatnik,
        spriteInstance = "src/def/char/beatnik",
        sprite_portrait = getSpriteInstance("src/def/misc/portraits"),
        sprite_portraitAnim = "rick", --NO OWN PORTRAIT
        defaultAnim = "stand",
        cancelAnim = "hurtHighWeak",
        confirmAnim = "walk",
        x = screenWidth / 2 - 80,
        y = 440 + 80,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "SATOFF", palette = 1},
        {name = "SATOFF", palette = 2},
        {name = "SATOFF", palette = 3},
        hero = PSatoff,
        spriteInstance = "src/def/char/satoff",
        sprite_portrait = getSpriteInstance("src/def/misc/portraits"),
        sprite_portraitAnim = "rick", --NO OWN PORTRAIT
        defaultAnim = "stand",
        cancelAnim = "hurtHighWeak",
        confirmAnim = "walk",
        x = screenWidth / 2 - 80,
        y = 440 + 80,
        sy = 272,
        ny = 90,
        py = 120
    },
    {
        {name = "DR.VOLKER", palette = 1},
        {name = "DR.VOLKER", palette = 1},
        {name = "DR.VOLKER", palette = 1},
        hero = PDrVolker,
        spriteInstance = "src/def/char/drvolker",
        sprite_portrait = getSpriteInstance("src/def/misc/portraits"),
        sprite_portraitAnim = "rick", --NO OWN PORTRAIT
        defaultAnim = "stand",
        cancelAnim = "hurtHighWeak",
        confirmAnim = "walk",
        x = screenWidth / 2 - 80,
        y = 440 + 80,
        sy = 272,
        ny = 90,
        py = 120
    }
}
HEROES = heroes -- global var for in-game player select

local players = {}
function playerSelectState:initDefaultPlayersSelectionOrder()
    players = { -- pos contains character number from HEROES table
        {pos = 1, visible = true, confirmed = false, sprite = nil},
        {pos = 2, visible = false, confirmed = false, sprite = nil},
        {pos = 3, visible = false, confirmed = false, sprite = nil}
    }
end

local playersPosition_x = {
    screenWidth / 2 - portraitWidth - portraitMargin,
    screenWidth / 2,
    screenWidth / 2 + portraitWidth + portraitMargin
}

local function selected_heroes()
    --calc P's indicators X position in the slot
    --P1
    local s1 = {players[1].pos, 1}
    local s2 = {players[2].pos, 1}
    local s3 = {players[3].pos, 1}
    local xshift = {0, 0, 0, 0}
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
    return {s1, s2, s3}, xshift
end

local function allConfirmed()
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

local function drawPID(x, y_, i, confirmed)
    if not x then
        return
    end
    local y = y_ - math.cos(x+time*6)
    colors:set("playersColors", i)
    love.graphics.rectangle( "fill", x - 30, y, 60, 34 )
    love.graphics.polygon( "fill", x, y - 6, x - 4 , y - 0, x + 4, y - 0 ) --arrow up
    colors:set("black")
    if confirmed then
        love.graphics.rectangle( "fill", x - 26, y + 4, 52, 26 )    --bold outline
    else
        love.graphics.rectangle( "fill", x - 28, y + 2, 56, 30 )
    end
    love.graphics.setFont(gfx.font.arcade3x2)
    colors:set("white")
    love.graphics.print(GLOBAL_SETTING.PLAYERS_NAMES[i], x - 14, y + 8)
end

function playerSelectState:enter()
    self:initDefaultPlayersSelectionOrder()
    for i = 1, availableHeroes do
        setSpriteAnimation(heroes[i].sprite_portrait, heroes[i].sprite_portraitAnim)
        heroes[i].sprite_portrait.sizeScale = 2
    end
    self.enablePlayerSelectOnStart = false
    -- Prevent double press at start (e.g. auto confirmation)
    for i = 1,GLOBAL_SETTING.MAX_PLAYERS do
        local p = getRegisteredPlayer(i)
        if p then
            p.b.attack:update(1) -- clear the Attack pressed event
            p.b.attack:update(1)
        end
    end
    love.graphics.setLineWidth( 2 )
    bgm.setVolume() --default volume
end

function playerSelectState:resume()
    self:enter()
end

function playerSelectState:GameStart()
    --All characters confirmed, pass them into the stage
    sfx.play("sfx","menuGameStart")
    local pl = {}
    local sh = selected_heroes()
    cleanRegisteredPlayers()
    for i = 1,GLOBAL_SETTING.MAX_PLAYERS do
        if players[i].confirmed then
            local pos = players[i].pos
            pl[i] = {
                hero = heroes[pos].hero,
                spriteInstance = heroes[pos].spriteInstance,
                palette = heroes[pos][sh[i][2]].palette,
                name = heroes[pos][sh[i][2]].name,
                color = heroes[pos][sh[i][2]].color
            }
        end
    end
    return Gamestate.switch(arcadeState, pl)
end

function playerSelectState:playerInput(player, controls, i)
    if not player.visible then
        if (controls.jump:pressed() or controls.back:pressed()) and i == 1 then
            --Only P1 can return to title
            sfx.play("sfx","menuCancel")
            return Gamestate.pop()
        end
        if controls.attack:pressed() or controls.start:pressed()then
            sfx.play("sfx","menuSelect")
            player.visible = true
            player.sprite = getSpriteInstance(heroes[player.pos].spriteInstance)
            player.sprite.sizeScale = 2
            setSpriteAnimation(player.sprite,heroes[player.pos].defaultAnim)
        end
        return
    end
    if not player.confirmed then
        if controls.jump:pressed() or controls.back:pressed() then
            if player.visible then
                sfx.play("sfx","menuCancel")
                player.visible = false
            end
        elseif controls.attack:pressed() or controls.start:pressed() then
            player.visible = true
            player.confirmed = true
            setSpriteAnimation(player.sprite,heroes[player.pos].confirmAnim)
            sfx.play("sfx","menuSelect")
        elseif controls.horizontal:pressed(-1) then
            player.pos = player.pos - 1
            if player.pos < 1 then
                player.pos = availableHeroes --GLOBAL_SETTING.MAX_PLAYERS
            end
            sfx.play("sfx","menuMove")
            player.sprite = getSpriteInstance(heroes[player.pos].spriteInstance)
            player.sprite.sizeScale = 2
            setSpriteAnimation(player.sprite,"stand")
        elseif controls.horizontal:pressed(1) then
            player.pos = player.pos + 1
            if player.pos > availableHeroes then --GLOBAL_SETTING.MAX_PLAYERS
                player.pos = 1
            end
            sfx.play("sfx","menuMove")
            player.sprite = getSpriteInstance(heroes[player.pos].spriteInstance)
            player.sprite.sizeScale = 2
            setSpriteAnimation(player.sprite,"stand")
        end
    else
        if controls.jump:pressed() or controls.back:pressed() then
            player.confirmed = false
            setSpriteAnimation(player.sprite,heroes[player.pos].cancelAnim)
            sfx.play("sfx","menuCancel")
        elseif (controls.attack:pressed() or controls.start:pressed()) and allConfirmed() then
            self:GameStart()
            return
        end
    end
end

function playerSelectState:update(dt)
    time = time + dt
    local sh,shiftx = selected_heroes()
    for i = 1,#players do
        local curPlayerHero = heroes[players[i].pos]
        local curColorSlot = sh[i][2]
        if players[i].sprite then
            updateSpriteInstance(players[i].sprite, dt)
            if players[i].sprite.isFinished
                    and (players[i].sprite.curAnim == heroes[players[i].pos].cancelAnim
                    or players[i].sprite.curAnim == heroes[players[i].pos].confirmAnim)
            then
                setSpriteAnimation(players[i].sprite,heroes[players[i].pos].defaultAnim)
            end
            if players[i].visible then
                --smooth indicators movement
                local nx = curPlayerHero.x - (shiftx[players[i].pos] - 1) * 32 + (curColorSlot - 1) * 64 -- * (i - 1)
                local ny = curPlayerHero.sy
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
                players[i].sprite = getSpriteInstance(heroes[players[i].pos].spriteInstance)
                players[i].sprite.sizeScale = 2
                setSpriteAnimation(players[i].sprite,heroes[players[i].pos].defaultAnim)
            end

        end
    end
    self:playerInput(players[1], Controls[1], 1)
    self:playerInput(players[2], Controls[2], 2)
    self:playerInput(players[3], Controls[3], 3)
end

function playerSelectState:draw()
    push:start()
    local sh = selected_heroes()
    local originalChar = 1
    for i = 1,#players do
        local curPlayerHeroSet = heroes[players[i].pos][sh[i][2]]
        local h = heroes[i]
        --Players sprite
        if players[i].visible then
            --hero sprite
            colors:set("white")
            if players[i].sprite then
                local currentShader = getShader(curPlayerHeroSet.name:lower(), curPlayerHeroSet.palette)
                if currentShader then love.graphics.setShader(currentShader) end
                drawSpriteInstance(players[i].sprite, playersPosition_x[i], h.y)
                if currentShader then love.graphics.setShader() end
            end
            --P1 P2 P3 indicators
            drawPID(players[i].nx, players[i].ny, i, players[i].confirmed)
        else
            colors:set("playersColors", i, 230 + math.sin(time * 4)*25)
            love.graphics.setFont(gfx.font.arcade3x2)
            love.graphics.print(GLOBAL_SETTING.PLAYERS_NAMES[i].."\nPRESS\nATTACK", playersPosition_x[i] - portraitWidth/2 + 20, h.y - portraitHeight + 48)
        end
    end
    colors:set("white")
    for i = 1, availableHeroes do
        local h = heroes[i]
        love.graphics.setFont(gfx.font.arcade3x3)
        love.graphics.print(h[originalChar].name, h.x - 24 * #h[originalChar].name / 2, h.ny)
        drawSpriteInstance(heroes[i].sprite_portrait, h.x - portraitWidth/2, h.py)
        love.graphics.rectangle("line", h.x - portraitWidth/2, h.py, portraitWidth, portraitHeight, 4,4,1)
    end
    --header
    colors:set("white")
    love.graphics.draw(playerSelectText, (screenWidth - playerSelectText:getWidth()) / 2, titleOffset_y)
    showDebugIndicator()
    push:finish()
end

function playerSelectState:confirmAllPlayers()
    --visible players confirmed their choice
    for i = 1,#players do
        players[i].confirmed = true
        players[i].visible = true
    end
end
