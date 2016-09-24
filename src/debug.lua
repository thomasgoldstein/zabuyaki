--Debug console output
function dp(...)
    if GLOBAL_SETTING.DEBUG then
        print(...)
    end
end

dboc = {}
dboc[0] = {x = 0, y = 0, z = 0, time = 0}
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
        time = dboc[o.name].time or love.timer.getTime( )
    end
    print(o.name .."(".. o.type .. ") x:".. o.x..",y:"..o.y..",z:"..o.z.." ->"..(txt or "") )
    print("DELTA x: ".. math.abs(o.x - ox) .. " y: ".. math.abs(o.y - oy) .. " z: ".. math.abs(o.z - oz) .." t(ms):" .. (love.timer.getTime() - time))
    dboc[o.name] = {x = o.x, y = o.y, z = o.z, time = love.timer.getTime() }
end

local fonts = {gfx.font.arcade3,gfx.font.arcade3x2,gfx.font.arcade3x3}
function show_debug_indicator(size, x, y)
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setColor(255, 255, 255, 255)
        size = size or 1
        love.graphics.setFont(fonts[size])
        love.graphics.print("DEBUG", x or 2, y or love.graphics.getHeight( ) - 9)
    end
end

function show_debug_controls()
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setFont(gfx.font.arcade3)
        --debug draw P1 / P2 pressed buttons
        local players = {player1, player2, player3}
        for i = 1, #players do
            local p = players[i]
            local c = GLOBAL_SETTING.PLAYERS_COLORS[p.id]
            local x = p.infoBar.x + 80
            local y = p.infoBar.y + 18
            love.graphics.setColor(0, 0, 0, 150)
            love.graphics.rectangle("fill", x-2, y, 61, 9 )
            love.graphics.setColor(c[1], c[2], c[3])

            if p.b.fire:isDown()  then
                love.graphics.print("F", x, y)
            end
            x = x + 10
            if p.b.jump:isDown()  then
                love.graphics.print("J", x, y)
            end
            x = x + 10
            if p.b.horizontal:isDown(-1)  then
                love.graphics.print("<", x, y)
            end
            x = x + 10
            if p.b.horizontal:isDown(1)  then
                love.graphics.print(">", x, y)
            end
            x = x + 10
            if p.b.vertical:isDown(-1)  then
                love.graphics.print("A", x, y)
            end
            x = x + 10
            if p.b.vertical:isDown(1)  then
                love.graphics.print("V", x, y)
            end
            x = x + 10
        end
    end
end