DEBUGGING_ON = 1 -- debugging enabled
SHOW_DEBUG_FPS_CONTROLS = 2 -- unit's pressed controls
SHOW_DEBUG_UNIT_HITBOX = 3 -- attack hitboxes
SHOW_DEBUG_BOXES = 4 -- debug boxes (hurtboxes, enemy AI cross, danger zone, etc)
SHOW_DEBUG_UNIT_INFO = 5 -- unit's info: name, pos, state
SHOW_DEBUG_ENEMY_AI_INFO = 6 -- enemy's AI info
SHOW_DEBUG_WAVES = 7 -- left edge of the current wave with red and the next with blue
SHOW_DEBUG_WALKABLE_AREA = 8 -- dynamic walkable area

local r = math.floor

function getDebugRawValue() return GLOBAL_SETTING.DEBUG or 0 end
function setDebugRawValue(n) GLOBAL_SETTING.DEBUG = n end

function setDebugOption( debugOption )
    setDebugRawValue( setBit(getDebugRawValue(), bit(debugOption) ) )
end

function unsetDebugOption( debugOption )
    setDebugRawValue( clearBit(getDebugRawValue(), bit(debugOption) ) )
end

function isDebug(debugOption)
    if not isDebuggingAvailable then
        return false
    end
    if not debugOption then
        return hasBit( getDebugRawValue(), bit(DEBUGGING_ON))
    end
    return hasBit( getDebugRawValue(), bit(DEBUGGING_ON)) and hasBit( getDebugRawValue(), bit(debugOption))
end

function isDebugOption(debugOption)
    return hasBit( getDebugRawValue(), bit(debugOption))
end

function invertDebugOption(debugOption)
    if hasBit( getDebugRawValue(), bit(debugOption)) then
        unsetDebugOption(debugOption)
    else
        setDebugOption(debugOption)
    end
end

function log2file( name, data, newFile)
    if newFile then
        love.filesystem.write( name, data )
    else
        local success, errormsg = love.filesystem.append( name, data )
        if not success then
            love.filesystem.write( name, data )
        end
    end
end

-- Debug console output
function dp(str1, str2)
    if isDebug() then
        local t = debug.getinfo (3, "flnSu")
        print(t.name, str1, str2 or "", t.short_src, t.currentline)
    end
end

-- Print delta x and delta time
local __x = 0
local __anim = 0
local __time = 0
function dpdi(self, text) -- reset delta
    __x = self.x
    __anim = self.sprite.curAnim
    __time = self.time
    print(self.sprite.curAnim, "DPD "..(text or ""))
end

function dpd(self, text) -- print current delta on animation change
    if __anim ~= self.sprite.curAnim then
        __anim = self.sprite.curAnim
        print(string.format("%02.2f",math.abs(self.x - __x)),  string.format("%02.2f",math.abs(self.time - __time)), self.sprite.curAnim, "DPD "..(text or ""))
    end
end

local dboc = {}
dboc[0] = { x = 0, y = 0, z = 0, time = 0 }
function dpoInit(o)
    if not isDebug() then
        return
    end
    dboc[o.name] = { x = o.x, y = o.y, z = o.z, time = love.timer.getTime() }
end
local r = round
function dpo(o, txt)
    if not isDebug() then
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
    local p = ""
    if o.platform then
        p = " Platform: '"..o.platform.name.."'"..r(o.platform.z)
    end
    print(o.name
            .." Dxyz: " .. r(math.abs(o.x - ox), 2) .. ", " .. r(math.abs(o.y - oy), 2) .. ", " .. r(math.abs(o.z - oz))
            .." xyz: " .. r(o.x, 2) .. ", " .. r(o.y, 2) .. ", " .. r(o.z, 2)
            .. " ".. o.type .. " t(ms): " .. r(love.timer.getTime() - time, 2) .." -> " .. (txt or "") .. p)
    dboc[o.name] = { x = o.x, y = o.y, z = o.z, time = love.timer.getTime() }
end

local debugFrame = 1000
function incrementDebugFrame()
    debugFrame = debugFrame + 1
end
function getDebugFrame()
    return debugFrame
end
local fonts = { gfx.font.arcade3, gfx.font.arcade3x2, gfx.font.arcade3x3 }
function showDebugIndicator(size, _x, _y)
    local x, y = _x or 2, _y or (480 - 9 * 4)
    if isDebug(SHOW_DEBUG_FPS_CONTROLS) then
        colors:set("white")
        love.graphics.setFont(fonts[size or 1])
        love.graphics.print("DEBUG:"..getDebugRawValue(), x, y)
        love.graphics.print("FPS:"..tonumber(love.timer.getFPS()), x, y + 9 * 1)
        if GLOBAL_SETTING.SLOW_MO > 0 then
            love.graphics.print("SLOW:"..(GLOBAL_SETTING.SLOW_MO + 1), x, y + 9 * 2)
        end
        if GLOBAL_SETTING.FRAME_SKIP > 0 then
            love.graphics.print("FRAME SKIP:"..(GLOBAL_SETTING.FRAME_SKIP + 1), x + 60, y + 9 * 2)
        end
        love.graphics.print("Frame:"..getDebugFrame(), x, y + 9 * 3)
    end
end

function showDebugWave(l,t,w,h)
    if isDebug(SHOW_DEBUG_WAVES) then
        local s = stage.wave
        if s then
            love.graphics.setFont(gfx.font.arcade3)
            local b,b2 = s.waves[s.n], s.waves[s.n + 1]
            if b then
                colors:set("red", nil, 150)
                love.graphics.rectangle("fill", b.leftStopper_x, t, 1, h)
                love.graphics.rectangle("fill", b.rightStopper_x, t, 1, h)
                love.graphics.print(b.name, b.leftStopper_x + 4, t + h - 12)
                if b2 then
                    colors:set("blue", nil, 150)
                    love.graphics.rectangle("fill", b2.leftStopper_x, t, 1, h)
                    love.graphics.rectangle("fill", b2.rightStopper_x, t, 1, h)
                    love.graphics.print(b2.name, b2.leftStopper_x + 4, t + h - 12)
                end
            end
        end
    end
end

function drawDebugControls(p, x, y)
    if p:isInstanceOf(StageObject) then
        return -- don't draw buttons for stageObjects
    end
    colors:set("black", nil, 150)
    love.graphics.rectangle("fill", x - 2, y, 61, 9)
    if p.id > GLOBAL_SETTING.MAX_PLAYERS then
        colors:set("white")
    else
        colors:set("playersColors", p.id)
    end
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
    if p.id <= GLOBAL_SETTING.MAX_PLAYERS then
        x = p.lifeBar.x + 76
        y = y - 12
        if p.chargeTimer >= p.chargedAt then
            love.graphics.print("H", x, y)
        elseif p.delayedChargeAttack then
            love.graphics.print("D", x, y)
        end
        if p.chargeTimer > 0 then
            love.graphics.print(tostring( r(p.chargeTimer, 3)), x + 10, y)
        end
    else -- virtual buttons for enemy
        x = x + 10
        if p.b.strafe:isDown() then
            love.graphics.print("S", x, y)
        end
    end
end

function showDebugControls()
    if isDebug(SHOW_DEBUG_FPS_CONTROLS) then
        love.graphics.setFont(gfx.font.arcade3)
        -- draw players controls
        for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
            local p = getRegisteredPlayer(i)
            if p and p.lifeBar then
                drawDebugControls(p, p.lifeBar.x + 76, p.lifeBar.y + 36)
            end
        end
    end
end

function drawWalkableArea()
    if isDebug(SHOW_DEBUG_WALKABLE_AREA) then
        local _x, y, w, h = mainCamera:getVisible()
        colors:set("menuOutline", nil, 50)
        for x = _x, _x + w, 8 do
            Stage:drawDebugWalkableArea( x, 1 )
        end
    end
end

function drawDebugHitBoxes(_x, _y, scale)
    if not scale then
        scale = 1
    end
    local x, y = _x or 0, _y or 0
    if isDebug(SHOW_DEBUG_UNIT_HITBOX) then
        local a
        -- draw attack hitboxes
        for i = 1, #attackHitBoxes do
            a = attackHitBoxes[i]
            if a.d then
                if a.collided then
                    colors:set("red", nil, 150)
                else
                    colors:set("yellow", nil, 150)
                end
                -- yellow: width + height
                love.graphics.rectangle("line", x + a.x + a.sx * scale, y + a.y + ( -a.z - a.h / 2) * scale, a.w * scale, a.h * scale)
                colors:set("green", nil, 150)
                -- green: width + depth
                love.graphics.rectangle("line", x + a.x + a.sx * scale, y + a.y - (a.d / 2) * scale, a.w * scale, a.d * scale)
            else
                -- red / green(not collided) cross
                if a.collided then
                    colors:set("red", nil, 150)
                else
                    colors:set("green", nil, 150)
                end
                love.graphics.rectangle("line", x + a.x + (a.sx - a.w / 2) * scale, y + a.y - a.z * scale, a.w * scale, a.h * scale)
                love.graphics.rectangle("line", x + a.x + a.sx * scale, y + a.y + ( -a.z - a.w / 2) * scale, a.h * scale, a.w * scale)
            end
        end
    end
end

function clearDebugBoxes()
    if isDebug() then
        attackHitBoxes = {}
    end
end

function drawDebugUnitHurtBoxUnder(sprite, x, y, frame, scale)
    if isDebug(SHOW_DEBUG_BOXES) then
        local scale = scale or 1
        local hurtBox =  getSpriteHurtBox(sprite, frame)
        if hurtBox then
            if not sprite.isPlatform then
                colors:set("green", nil, 150)
                love.graphics.rectangle("line", x + (sprite.flipH * hurtBox.x - hurtBox.width / 2) * scale, y - hurtBox.depth / 2 * scale, hurtBox.width * scale, hurtBox.depth * scale)
            end
        else
            colors:set("blue", nil, 150)
            love.graphics.rectangle("line", x - 5, y - 5, 10, 10 )
        end
    end
end
function drawDebugUnitDangerBoxUnder(unit, _x, _y, scale)
    if isDebug(SHOW_DEBUG_BOXES) and unit.id <= GLOBAL_SETTING.MAX_PLAYERS and unit:isDangerous() then
        local scale = scale or 1
        local x, y, width, depth = unit:getDangerBox(50, 8)
        colors:set("red", nil, 150)
        love.graphics.rectangle("line", x * scale, y * scale, width * scale, depth * scale)
    end
end
function drawDebugUnitHurtBox(sprite, x, y, frame, scale)
    if isDebug(SHOW_DEBUG_BOXES) then
        local scale = scale or 1
        local hurtBox =  getSpriteHurtBox(sprite, frame)
        if hurtBox then
            if sprite.isPlatform then
                colors:set("red", nil, 150)
                love.graphics.rectangle("line", x + (sprite.flipH * hurtBox.x - hurtBox.width / 2) * scale, y - hurtBox.height - hurtBox.depth / 2 * scale, hurtBox.width * scale, hurtBox.depth * scale)
            end
            colors:set("lightGray", nil, 150)
            love.graphics.rectangle("line", x + (sprite.flipH * hurtBox.x - hurtBox.width / 2) * scale, y - (hurtBox.y + hurtBox.height / 2) * scale, hurtBox.width * scale, hurtBox.height * scale)
        end
    end
end

function drawDebugUnitConditions(a, conditions)
    local z = 80
    love.graphics.setFont(gfx.font.debug)
    if a.AI.currentSchedule then
        local scheduleNameAndTaskN = a.AI.currentSchedule.name .. " " .. a.AI.currentSchedule.currentTask .. "/" .. #a.AI.currentSchedule.tasks
        colors:set("black")
        love.graphics.print( scheduleNameAndTaskN, r(a.x - 40 - 1), r(a.y - a.z - z))
        love.graphics.print( scheduleNameAndTaskN, r(a.x - 40 + 1), r(a.y - a.z - z))
        colors:set("red")
        love.graphics.print( scheduleNameAndTaskN, r(a.x - 40), r(a.y - a.z - z))
    end
    colors:set("yellow")
    local t = ""
    for k, _ in pairs(conditions) do
        if #t > 16 then
            z = z + 6
            love.graphics.print( t, r(a.x - 40), r(a.y - a.z - z))
            t = ""
        elseif #k > 12 then
            z = z + 6
            love.graphics.print( k, r(a.x - 40), r(a.y - a.z - z))
        else
            t = k .. " | " .. t
        end
    end
    if #t > 0 then
        z = z + 6
        love.graphics.print( t, r(a.x - 40), r(a.y - a.z - z))
    end
end

function drawDebugUnitInfo(a)
    if isDebug(SHOW_DEBUG_UNIT_INFO) then
        love.graphics.setFont(gfx.font.debug)
        if a.hp <= 0 then
            colors:set("black", nil, 50)
            love.graphics.print( a.name, r(a.x - 16), r(a.y - 7 - a.z))
        else
            colors:set("black", nil, 120)
            if a.id > GLOBAL_SETTING.MAX_PLAYERS then
                drawDebugControls(a, a.x - 32, a.y - a:getHurtBoxHeight() - 20 - a.z)
            end
        end
        if a.debugText then
            love.graphics.print( a.state .. " " .. a.debugText, r(a.x - 14), r(a.y - a.z))
        else
            love.graphics.print( a.state, r(a.x - 14), r(a.y - a.z))
        end
        colors:set(a.isHittable and "black" or "red", nil, 120)
        love.graphics.print( ""..r(a.x).." "..r(a.y).." "..r(a.z), r(a.x - 22), r(a.y + 7 - a.z))
        local yShift1 = 0
        colors:set("yellow", nil, 120)
        love.graphics.line( a.x, a.y + yShift1, a.x + 10 * a.horizontal, a.y + yShift1 - a.z)
        local yShift2 = 0
        colors:set("purple", nil, 120)
        love.graphics.line( a.x, a.y + yShift2, a.x + 8 * a.face, a.y + yShift2 - a.z)
        if a.movementMode then
            love.graphics.print( ""..a.movementMode.." "..( a.movementModeTimer > 0 and a.movementModeTimer or "OK" ), r(a.x - 22), r(a.y + 14 - a.z))
        end
        if a.platform and not a.platform.isDisabled and ( getDebugFrame() + a.id ) % 5 == 1 then
            colors:set("black", nil, 255)
            love.graphics.line( a.x, a.y - a.z, a.platform.x, a.platform.y - a.platform.z)
        end
    end
    if isDebug(SHOW_DEBUG_ENEMY_AI_INFO) then
        if a.hp > 0 and a.AI then
            drawDebugUnitConditions(a, a.AI.conditions)
            if a.target then
                colors:set("white", nil, 55)
                love.graphics.line( a.x, a.y - a.z, a.target.x, a.target.y - a.target.z)
            end
        end
    end
end

local savePlayersPosAndFaceDebug = {}
local keysToKill = {f8 = 1, f9 = 2, f10 = 3, f7 = 0, f12 = -1}
function checkDebugKeys(key)
    if isDebug() then
        if key == 'kp+' or key == '=' then
            if love.keyboard.isScancodeDown( "lctrl", "rctrl" ) then
                GLOBAL_SETTING.FRAME_SKIP = GLOBAL_SETTING.FRAME_SKIP + 1
                if GLOBAL_SETTING.FRAME_SKIP > GLOBAL_SETTING.MAX_FRAME_SKIP then
                    GLOBAL_SETTING.FRAME_SKIP = GLOBAL_SETTING.MAX_FRAME_SKIP
                    sfx.play("sfx","menuCancel")
                else
                    sfx.play("sfx","menuMove")
                end
            else
                GLOBAL_SETTING.SLOW_MO = GLOBAL_SETTING.SLOW_MO - 1
                if GLOBAL_SETTING.SLOW_MO < 0 then
                    GLOBAL_SETTING.SLOW_MO = 0
                    sfx.play("sfx","menuCancel")
                else
                    sfx.play("sfx","menuMove")
                end
            end
        elseif key == 'kp-' or key == '-' then
            if love.keyboard.isScancodeDown( "lctrl", "rctrl" ) then
                GLOBAL_SETTING.FRAME_SKIP = GLOBAL_SETTING.FRAME_SKIP - 1
                if GLOBAL_SETTING.FRAME_SKIP < 0 then
                    GLOBAL_SETTING.FRAME_SKIP = 0
                    sfx.play("sfx","menuCancel")
                else
                    sfx.play("sfx","menuMove")
                end
            else
                GLOBAL_SETTING.SLOW_MO = GLOBAL_SETTING.SLOW_MO + 1
                if GLOBAL_SETTING.SLOW_MO > GLOBAL_SETTING.MAX_SLOW_MO then
                    GLOBAL_SETTING.SLOW_MO = GLOBAL_SETTING.MAX_SLOW_MO
                    sfx.play("sfx","menuCancel")
                else
                    sfx.play("sfx","menuMove")
                end
            end
        elseif key == 'm' then
            for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
                local p = getRegisteredPlayer(i)
                if p then
                    if love.keyboard.isScancodeDown( "lctrl", "rctrl" ) then
                        p:setMovementMode("fast")
                    else
                        p:setMovementMode("slow")
                    end
                end
            end
            sfx.play("sfx","menuCancel")
        elseif key == '5' then
            if love.keyboard.isScancodeDown( "lctrl", "rctrl" ) then
                for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
                    local p = getRegisteredPlayer(i)
                    local s = savePlayersPosAndFaceDebug[i]
                    if s and p and p:isAlive() and not p:isInUseCreditMode() then
                        p.x, p.y, p.z, p.face, p.vertical, p.horizontal = s.x, s.y, s.z, s.face, s.vertical, s.horizontal
                    end
                end
                sfx.play("sfx","menuCancel")
            else
                local s = {}
                for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
                    local p = getRegisteredPlayer(i)
                    if p and p:isAlive() and not p:isInUseCreditMode() then
                        s[i] = { x = p.x, y = p.y, z = p.z, face = p.face, vertical = p.vertical, horizontal = p.horizontal }
                    end
                end
                savePlayersPosAndFaceDebug = s
                sfx.play("sfx","menuMove")
            end
        elseif keysToKill[key] then
            local id = keysToKill[key]
            if id == keysToKill.f12 then
                if love.keyboard.isScancodeDown( "lctrl", "rctrl" ) then
                    stage.wave:killCurrentWave()
                end
            elseif id == keysToKill.f7 then
                if love.keyboard.isScancodeDown( "lctrl", "rctrl" ) then
                    -- Ctrl + F7 Player select
                    playerSelectState.enablePlayerSelectOnStart = true
                    credits = math.max(credits, 3)
                    doInstantPlayersSelect()
                end
            else
                local p = getRegisteredPlayer(id)
                if p then
                    if love.keyboard.isScancodeDown( "lctrl", "rctrl" ) then
                        -- Ctrl + F8 F9 F0 Toggle random controls P1 P2 P3
                        if p.b == Controls[id] then
                            p.b = bindRandomDebugInput()
                        else
                            p.b = Controls[id]
                        end
                    else
                        -- F8 F9 F0 Instant kill P1 P2 P3
                        p:setState(getRegisteredPlayer(id).dead)
                    end
                end
            end
        end
    end
end
