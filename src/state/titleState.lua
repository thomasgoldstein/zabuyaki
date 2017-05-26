titleState = {}

local time_to_title_fade = 1.25 --title fadein
local fadeToMenuTime = 0.5 --menu fadein & menu+title fadeout before intro
local moveToMenuTime = 0.25 --can move/select menu
local timeToIntro = 10 --idle to show intro
local titleSfx = "whooshHeavy"

local time = 0
local transparency = 0
local title_transparency = 0
local intro_movie = nil
local mode = nil

local screenWidth = 640
local screenHeight = 480
local zabuyaki_title
local menuItem_h = 40
local menu_yOffset = 200 - menuItem_h
local menu_xOffset = 0
local hint_yOffset = 80
local title_yOffset = 0
local leftItemOffset  = 6
local topItemOffset  = 6
local itemWidthMargin = leftItemOffset * 2
local itemHeightMargin = topItemOffset * 2 - 2

local txt_gfx_site = love.graphics.newText( gfx.font.arcade3, "WWW.ZABUYAKI.COM" )
local txtItems = {"START", "OPTIONS", "QUIT"}

local menu = fillMenu(txtItems, txt_hints)

local menuState, oldMenuState = 1, 1
local mouse_x, mouse_y, old_mouse_y = 0, 0, 0

function titleState:enter(_, param)
    mouse_x, mouse_y = 0,0
    time = 0
    transparency = 0
    title_transparency = 0
    mode = "fadein"
    if param ~= "dontStartMusic" then
        TEsound.stop("music")
        TEsound.playLooping(bgm.title, "music")
    end
    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
    sfx.play("sfx",titleSfx)

    -- Prevent double press at start (e.g. auto confirmation)
    Control1.attack:update()
    Control1.jump:update()
    zabuyaki_title = love.graphics.newImage( "res/img/misc/title.png" )
    love.graphics.setLineWidth( 2 )
end

function titleState:resume()
    mouse_x, mouse_y = 0,0
    time = 0
    transparency = 1
    title_transparency = 1
    mode = "menu"
    mouse_x, mouse_y = 0,0
    love.graphics.setLineWidth( 2 )
end

local function resetTime()
    if mode == "menufadein" then
        if time > fadeToMenuTime then
            time = fadeToMenuTime
        end
    else
        time = 0
    end
end

--Only P1 can use menu / options
function titleState:player_input(controls)
    if mode == "menufadein" and time < moveToMenuTime then
        return
    end
    if controls.back:pressed() then
        --Exit by "Back" button or "Esc" key
        sfx.play("sfx","menuCancel")
        return love.event.quit()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return self:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1) or controls.vertical:pressed(-1) then
        menuState = menuState - 1
    elseif controls.horizontal:pressed(1) or controls.vertical:pressed(1) then
        menuState = menuState + 1
    end
    if menuState < 1 then
        menuState = #menu
    end
    if menuState > #menu then
        menuState = 1
    end
end

function titleState:update(dt)
    time = time + dt
    if mode == "fadein" then
        title_transparency = clamp(time * (1 / time_to_title_fade), 0 , 1)
        transparency = 0
        if time > time_to_title_fade  then
            mode = "menufadein"
            time = 0
            return
        end
    elseif mode == "fadeout" then
        transparency = clamp((fadeToMenuTime - time) * (1 / fadeToMenuTime), 0 , 1)
        title_transparency = transparency
        if time > fadeToMenuTime then
            mode = "movie"
            time = 0
            return
        end
    elseif mode == "movie" then
        if intro_movie:update(dt) then
            self:enter()
            TEsound.stop("music")
            TEsound.playLooping(bgm.title, "music")
        end
        return
    else
        --mode == "menu"
        if mode == "menufadein" then
            title_transparency = 1
            transparency = clamp(time * (1 / fadeToMenuTime), 0, 1)
            if time > fadeToMenuTime then
                mode = "menu"
            end
        elseif mode == "menu" then
            title_transparency = 1
            transparency = 1
        end
        if time > timeToIntro then
            intro_movie = Movie:new(movie_intro)
            mode = "fadeout"
            time = 0
            return
        end
        if menuState ~= oldMenuState then
            sfx.play("sfx","menuMove")
            oldMenuState = menuState
            resetTime()
        end
        self:player_input(Control1)
    end
end

function titleState:draw()
    if mode == "movie" then
        love.graphics.setCanvas(canvas[1])
        intro_movie:draw(0,0,320,240)
        love.graphics.setCanvas()
	    push:start()
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(canvas[1], 0,0, nil, 2)
	    push:finish()
        return
    end
    love.graphics.setCanvas()
    push:start()
    --header
    love.graphics.setColor(255, 255, 255, 255 * title_transparency)
    love.graphics.draw(zabuyaki_title, 0, title_yOffset, 0, 2, 2)
    love.graphics.setColor(100, 100, 100, 255 * transparency)
    love.graphics.draw(txt_gfx_site, (screenWidth - txt_gfx_site:getWidth())/2, screenHeight - 20)
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1,#menu do
        local m = menu[i]
        if i == oldMenuState then
            love.graphics.setColor(255, 255, 255, 255 * transparency)
            love.graphics.print(m.hint, m.wx, m.wy)
            love.graphics.setColor(0, 0, 0, 80 * transparency)
            love.graphics.rectangle("fill", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4,4,1)
            love.graphics.setColor(255,200,40, 255 * transparency)
            love.graphics.rectangle("line", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4,4,1)
        end
        love.graphics.setColor(255, 255, 255, 255 * transparency)
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= old_mouse_y and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin )
        then
            old_mouse_y = mouse_y
            menuState = i
        end
    end
    showDebug_indicator()
    push:finish()
end

function titleState:confirm( x, y, button, istouch )
    if mode == "menufadein" and time < moveToMenuTime then
        return
    end
    if button == 1 then
        mouse_x, mouse_y = x, y
        if menuState == 1 then
            sfx.play("sfx","menuSelect")
            time = 0
            if GLOBAL_SETTING.DEBUG then
                playerSelectState.enablePlayerSelectOnStart = true
                playerSelectState:confirm_all_players()
                playerSelectState:GameStart()
                return
            else
                return Gamestate.push(playerSelectState)
            end

        elseif menuState == 2 then
            sfx.play("sfx","menuSelect")
            time = 0
            return Gamestate.push(optionsState)
        elseif menuState == #menu then
            sfx.play("sfx","menuCancel")
            return love.event.quit()
        end
    end
end

function titleState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    if mode == "movie" then
        return
    end
    if mode == "menu" or mode == "menufadein" then
        self:confirm( x, y, button, istouch )
        return
    end
end

function titleState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    if mode == "movie" then
        return
    end
    mouse_x, mouse_y = x, y
end

function titleState:keypressed(key, unicode)
end