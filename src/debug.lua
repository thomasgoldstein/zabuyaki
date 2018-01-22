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
function dpoInit(o)
    if not GLOBAL_SETTING.DEBUG then
        return
    end
    if not GLOBAL_SETTING.DEBUG then
        return
    end
    dboc[o.name] = { x = o.x, y = o.y, z = o.z, time = love.timer.getTime() }
end
local r = round
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
--    print(o.name .. "(" .. o.type .. ") x:" .. o.x .. ",y:" .. o.y .. ",z:" .. o.z .. " ->" .. (txt or ""))
--    print("DELTA x: " .. r(math.abs(o.x - ox), 2) .. " y: " .. r(math.abs(o.y - oy), 2) .. " z: " .. math.abs(o.z - oz) .. " t(ms):" .. r(love.timer.getTime() - time, 3))
    print(o.name
            .." Dxyz: " .. r(math.abs(o.x - ox), 2) .. "," .. r(math.abs(o.y - oy), 2) .. "," .. math.abs(o.z - oz)
            .." xyz: " .. r(o.x, 2) .. "," .. r(o.y, 2) .. "," .. r(o.z, 2)
            .. " ".. o.type .. " t(ms): " .. r(love.timer.getTime() - time, 2) .." -> " .. (txt or ""))
    dboc[o.name] = { x = o.x, y = o.y, z = o.z, time = love.timer.getTime() }
end

local fonts = { gfx.font.arcade3, gfx.font.arcade3x2, gfx.font.arcade3x3 }
function showDebugIndicator(size, x, y)
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setFont(fonts[size or 1])
        love.graphics.print("DEBUG", x or 2, y or 2)
        love.graphics.print("FPS:"..tonumber(love.timer.getFPS()), x or 2, y or 2 + 9 * 1)
        if GLOBAL_SETTING.SLOW_MO > 0 then
            love.graphics.print("SLOW:"..(GLOBAL_SETTING.SLOW_MO + 1), x or 2, y or 2 + 9 * 2)
        end
    end
end

function showDebugControls()
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setFont(gfx.font.arcade3)
        -- draw players controls
        for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
            local p = getRegisteredPlayer(i)
            if p and p.infoBar then
                local x = p.infoBar.x + 76
                local y = p.infoBar.y + 36
                love.graphics.setColor(0, 0, 0, 150)
                love.graphics.rectangle("fill", x - 2, y, 61, 9)
                love.graphics.setColor( unpack( GLOBAL_SETTING.PLAYERS_COLORS[p.id] ) )
                if p.b.attack:isDown() then
                    love.graphics.print("A", x, y)
                end
                x = x + 10
                if p.b.jump:isDown() then
                    love.graphics.print("J", x, y)
                end
                local horizontalValue = p.b.horizontal:getValue()
                x = x + 10
                if horizontalValue == -1 then
                    love.graphics.print("<", x, y)
                end
                if p.b.horizontal.isDoubleTap and p.b.horizontal.doubleTap.lastDirection == -1 then
                    love.graphics.print("2", x, y + 10)
                end
                x = x + 10
                if horizontalValue == 1 then
                    love.graphics.print(">", x, y)
                end
                if p.b.horizontal.isDoubleTap and p.b.horizontal.doubleTap.lastDirection == 1 then
                    love.graphics.print("2", x, y + 10)
                end
                local verticalValue = p.b.vertical:getValue()
                x = x + 10
                if verticalValue == -1 then
                    love.graphics.print("^", x, y)
                end
                if p.b.vertical.isDoubleTap and p.b.vertical.doubleTap.lastDirection == -1 then
                    love.graphics.print("2", x, y + 10)
                end
                x = x + 10
                if verticalValue == 1 then
                    love.graphics.print("V", x, y)
                end
                if p.b.vertical.isDoubleTap and p.b.vertical.doubleTap.lastDirection == 1 then
                    love.graphics.print("2", x, y + 10)
                end
                x = p.infoBar.x + 76
                y = y - 12
                if p.charge >= p.chargedAt then
                    love.graphics.print("H", x, y)
                end
            end
        end
    end
end

function showDebugBoxes(scale)
    if not scale then
        scale = 1
    end
    if GLOBAL_SETTING.DEBUG then
        local a
        -- draw attack hitboxes
        for i = 1, #attackHitBoxes do
            a = attackHitBoxes[i]
            if a.d then
                if a.collided then
                    love.graphics.setColor(255, 0, 0, 150)
                else
                    love.graphics.setColor(255, 255, 0, 150)
                end
                -- yellow: width + height
                love.graphics.rectangle("line", a.x + a.sx * scale, a.y + ( -a.z - a.h / 2) * scale, a.w * scale, a.h * scale)
                love.graphics.setColor(0, 255, 0, 150)
                -- green: width + depth
                love.graphics.rectangle("line", a.x + a.sx * scale, a.y - (a.d / 2) * scale, a.w * scale, a.d * scale)
            else
                -- blue / green(not collided) cross
                if a.collided then
                    love.graphics.setColor(255, 0, 0, 150)
                else
                    love.graphics.setColor(0, 255, 0,150)
                end
                love.graphics.rectangle("line", a.x + a.sx * scale - (a.w / 2) * scale, a.y - a.z * scale, a.w * scale, a.h * scale)
                love.graphics.rectangle("line", a.x + a.sx * scale, a.y + ( -a.z - a.w / 2) * scale, a.h * scale, a.w * scale)
            end
        end
    end
end

function clearDebugBoxes()
    if GLOBAL_SETTING.DEBUG then
        attackHitBoxes = {}
    end
end

function watchDebugVariables()
    if GLOBAL_SETTING.DEBUG then
    end
end

local keysToKill = {f8 = 1, f9 = 2, f10 = 3}
function checkDebugKeys(key)
    if GLOBAL_SETTING.DEBUG then
        if key == '0' then
            stage.objects:dp()
        elseif key == 'kp+' or key == '=' then
            GLOBAL_SETTING.SLOW_MO = GLOBAL_SETTING.SLOW_MO - 1
            if GLOBAL_SETTING.SLOW_MO < 0 then
                GLOBAL_SETTING.SLOW_MO = 0
                sfx.play("sfx","menuCancel")
            else
                sfx.play("sfx","menuMove")
            end
        elseif key == 'kp-' or key == '-' then
            GLOBAL_SETTING.SLOW_MO = GLOBAL_SETTING.SLOW_MO + 1
            if GLOBAL_SETTING.SLOW_MO > GLOBAL_SETTING.MAX_SLOW_MO then
                GLOBAL_SETTING.SLOW_MO = GLOBAL_SETTING.MAX_SLOW_MO
                sfx.play("sfx","menuCancel")
            else
                sfx.play("sfx","menuMove")
            end
        elseif key == 'f12' then
            --saveAllCanvasesToPng()
            saveStageToPng()
        elseif keysToKill[key] then
            local id = keysToKill[key]
            if getRegisteredPlayer(id) then
                getRegisteredPlayer(id):setState(getRegisteredPlayer(id).dead)
            end
        end
    end
end

function drawDebugUnitCross(slf)
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setColor(127, 127, 127, 127)
        love.graphics.line( slf.x - 30, slf.y - slf.z, slf.x + 30, slf.y - slf.z )
        love.graphics.setColor(255, 255, 255, 127)
        love.graphics.line( slf.x, slf.y+2, slf.x, slf.y-66 )
    end
end

function drawDebugUnitHitbox(a)
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setColor(255, 255, 255, 150)
--        stage.world:add(obj, obj.x-7, obj.y-3, 15, 7)
        love.graphics.rectangle("line", a.x - a.width / 2, a.y - a.height - a.z + 1, a.width, a.height-1)
    end
end

function drawDebugUnitInfo(a)
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setFont(gfx.font.debug)
        if a.hp <= 0 then
            love.graphics.setColor(0, 0, 0, 50)
            love.graphics.print( a.name, a.x - 16 , a.y - 7)
        else
            love.graphics.setColor(0, 0, 0, 120)
            love.graphics.print( "HP "..math.floor(a.hp), a.x - 16 , a.y + 14)
        end
        if a.comboN and a.sprite.def.comboMax > 0 then
            love.graphics.print( "CN" .. a.comboN .. "/".. a.sprite.def.comboMax, a.x - 14, a.y + 21)
        end
        love.graphics.print( a.state, a.x - 14, a.y)
        love.graphics.print( ""..math.floor(a.x).." "..math.floor(a.y).." "..math.floor(a.z), a.x - 22, a.y + 7)

        love.graphics.setColor(220, 220, 0, 120)
        love.graphics.line( a.x, a.y + 6.5, a.x, a.y + 8.5)
        love.graphics.line( a.x, a.y + 7.5, a.x + 10 * a.horizontal, a.y + 7.5)
        love.graphics.setColor(220, 0, 220, 120)
        love.graphics.line( a.x, a.y + 8, a.x + 8 * a.face, a.y + 8)
    end
end
