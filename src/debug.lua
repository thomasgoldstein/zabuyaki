-- Load PRofiler
if GLOBAL_SETTING.PROFILER_ENABLED then
    Profiler  = require "lib/piefiller"
    ProfOn = false
    Prof = Profiler:new()
end

--Debug console output
function dp(...)
    if GLOBAL_SETTING.DEBUG then
        print(...)
    end
end

dboc = {}
dboc[0] = { x = 0, y = 0, z = 0, time = 0 }
function dpo(o, txt)
    if not GLOBAL_SETTING.DEBUG then
        return
    end
    local ox = 0
    local oy = 0
    local oz = 0
    local time = 0
    if dboc[o.name] then
        --        print(o.x, o.y, o.z, o.time)
        ox = dboc[o.name].x or 0
        oy = dboc[o.name].y or 0
        oz = dboc[o.name].z or 0
        time = dboc[o.name].time or love.timer.getTime()
    end
    print(o.name .. "(" .. o.type .. ") x:" .. o.x .. ",y:" .. o.y .. ",z:" .. o.z .. " ->" .. (txt or ""))
    print("DELTA x: " .. math.abs(o.x - ox) .. " y: " .. math.abs(o.y - oy) .. " z: " .. math.abs(o.z - oz) .. " t(ms):" .. (love.timer.getTime() - time))
    dboc[o.name] = { x = o.x, y = o.y, z = o.z, time = love.timer.getTime() }
end

local fonts = { gfx.font.arcade3, gfx.font.arcade3x2, gfx.font.arcade3x3 }
function show_debug_indicator(size, x, y)
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setFont(fonts[size or 1])
        love.graphics.print("DEBUG", x or 2, y or 2)
        love.graphics.print("FPS:"..tonumber(love.timer.getFPS()), x or 2, y or 11)
    end
end

function show_debug_controls()
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setFont(gfx.font.arcade3)
        --debug draw P1 / P2 pressed buttons
        local players = { player1, player2, player3 }
        for i = 1, #players do
            local p = players[i]
            local x = p.infoBar.x + 76
            local y = p.infoBar.y + 36
            love.graphics.setColor(0, 0, 0, 150)
            love.graphics.rectangle("fill", x - 2, y, 61, 9)
            love.graphics.setColor( unpack( GLOBAL_SETTING.PLAYERS_COLORS[p.id] ) )
            if p.b.attack:isDown() then
                love.graphics.print("F", x, y)
            end
            x = x + 10
            if p.b.jump:isDown() then
                love.graphics.print("J", x, y)
            end
            x = x + 10
            if p.b.horizontal:isDown(-1) then
                love.graphics.print("<", x, y)
            end
            x = x + 10
            if p.b.horizontal:isDown(1) then
                love.graphics.print(">", x, y)
            end
            x = x + 10
            if p.b.vertical:isDown(-1) then
                love.graphics.print("A", x, y)
            end
            x = x + 10
            if p.b.vertical:isDown(1) then
                love.graphics.print("V", x, y)
            end
            x = x + 10
        end
    end
end

function show_debug_boxes()
    if GLOBAL_SETTING.DEBUG then
        local a
        -- draw attack hitboxes
        for i = 1, #attackHitBoxes do
            a = attackHitBoxes[i]
            love.graphics.setColor(255, 255, 0, 150)
            love.graphics.rectangle("line", a.x, a.y - a.height - a.z + a.h / 2, a.w, a.height)

            love.graphics.setColor(0, 255, 0, 150)
            love.graphics.rectangle("line", a.x, a.y, a.w, a.h)
        end
        attackHitBoxes = {}
    end
end

function show_debug_grid()
    if GLOBAL_SETTING.SHOW_GRID then
        love.graphics.setColor(0, 0, 0, 55)
        for i = 1, 320 * 2, 2 do
            love.graphics.rectangle("fill", i, 0, 1, 240 * 2)
        end
        for i = 1, 240 * 2, 2 do
            love.graphics.rectangle("fill", 0, i, 320 * 2, 1)
        end
    end
end

function watch_debug_variables()
    if GLOBAL_SETTING.DEBUG then
    end
end

function check_debug_keys(key)
    if GLOBAL_SETTING.DEBUG then
        if key == '0' then
            stage.objects:dp()
        end
        if key == 'f8' and player1 then
            player1:setState(player1.dead)
        end
        if key == 'f9' and player2 then
            player2:setState(player2.dead)
        end
        if key == 'f10' and player3 then
            player3:setState(player3.dead)
        end
        if key == '1' then
            GLOBAL_SETTING.SHOW_GRID = not GLOBAL_SETTING.SHOW_GRID
        end
    end
end

function draw_debug_unit_cross(slf)
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setColor(127, 127, 127, 127)
        love.graphics.line( slf.x - 30, slf.y - slf.z, slf.x + 30, slf.y - slf.z )
        love.graphics.setColor(255, 255, 255, 127)
        love.graphics.line( slf.x, slf.y+2, slf.x, slf.y-66 )
    end
end

function draw_debug_unit_hitbox(a)
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setColor(255, 255, 255, 150)
--        stage.world:add(obj, obj.x-7, obj.y-3, 15, 7)
        love.graphics.rectangle("line", a.x - 7, a.y - a.height - a.z + 1, 14, a.height-1)
    end
end

function draw_debug_unit_info(a)
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setFont(gfx.font.debug)
        if a.hp <= 0 then
            love.graphics.setColor(0, 0, 0, 50)
            love.graphics.print( a.name, a.x - 16 , a.y - 7)
        else
            love.graphics.setColor(0, 0, 0, 120)
            love.graphics.print( "HP "..math.floor(a.hp), a.x - 16 , a.y + 14)
        end
        love.graphics.print( a.state, a.x - 14, a.y)
        love.graphics.print( ""..math.floor(a.x).." "..math.floor(a.y).." "..math.floor(a.z), a.x - 22, a.y + 7)
    end
end
