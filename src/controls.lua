local doubleTapDelta = 0.25

love.joystick.loadGamepadMappings( "res/gamecontrollerdb.txt" )
Controls = {}   -- global controls list
local commonPlayersGamepadButtons = { attack = 'a', jump = 'b', start  = 'start', back = 'back'}
local playersKeys = {   -- for P1, P2, P3
    { left = 'left', right = 'right', up = 'up', down = 'down', attack = 'x', jump = 'c',
      start = 'return', back = 'escape', fullScreen = 'f11', screenshot = '/', screenshot2 = 'pause' },
    { left = 'a', right = 'd', up = 'w', down = 's', attack = 'i', jump = 'o',
      start = '?', back = '?', fullScreen = '?', screenshot = '?', screenshot2 = '?' },
    { left = 'f', right = 'h', up = 't', down = 'g', attack = 'r', jump = 'y',
      start = '?', back = '?', fullScreen = '?', screenshot = '?', screenshot2 = '?' },
}

local connected = {}
function love.joystickadded(joystick)
    connected[joystick] = joystick
    dp(joystick:getGUID().." added joystick "..joystick:getName().." with "..joystick:getButtonCount().." buttons")
    bindGameInput()
end

function love.joystickremoved( joystick )
    dp("removed joystick "..joystick:getName())
    connected[joystick] = nil
end

local function gamepadHat(num, hat, axis)
    local joystick = love.joystick.getJoysticks()[num]
    if not joystick then
        return function()
            return 0
        end
    end
    if axis == "horizontal" then
        return function()
            local joystick = love.joystick.getJoysticks()[num]
            if not joystick then
                return 0
            end
            local h = joystick:getHat(hat)
            if h == "l" or h == "lu" or h == "ld" then
                return -1
            elseif h == "r" or h == "ru" or h == "rd" then
                return 1
            end
            return 0
        end
    else
        return function()
            local joystick = love.joystick.getJoysticks()[num]
            if not joystick then
                return 0
            end
            local h = joystick:getHat(hat)
            if h == "u" or h == "ru" or h == "lu" then
                return -1
            elseif h == "d" or h == "rd" or h == "ld" then
                return 1
            end
            return 0
        end
    end
end

local maxAxisDelta = 0.15
local function gamepadDigitalAxis(num, axis)
    return function()
        local joystick = love.joystick.getJoysticks()[num]
        if not joystick then
            return 0
        end
        local a = joystick ~= nil and joystick:getGamepadAxis(axis) or 0
        if a < -maxAxisDelta then
            return -1
        elseif a > maxAxisDelta then
            return 1
        end
        return 0
    end
end

-- buttons = { attack = 'a', jump = 'b', start  = 'start', back = 'back'}
-- keys = { left = 'left', right = 'right', up = 'up', down = 'down', attack = 'x', jump = 'c', start  = 'return', back = 'escape', fullscreen = 'f11', screenshot = '/', screenshot2 = 'pause'}
--- Create controls for a player
--- @param gamepadNum number control number 1..3 (it coincides with the gamepad number)
--- @param buttons table list of gamepad buttons
--- @param keys table list of keyboard keys for a player
function createControl(gamepadNum, buttons, keys)
    return {
        horizontal = tactile.newControl()
                            :addAxis(gamepadDigitalAxis(gamepadNum, 'leftx'))
                            :addAxis(gamepadHat(gamepadNum, 1, "horizontal"))
                            :addButtonPair(tactile.keys(keys.left), tactile.keys(keys.right)),
        vertical = tactile.newControl()
                          :addAxis(gamepadDigitalAxis(gamepadNum, 'lefty'))
                          :addAxis(gamepadHat(gamepadNum, 1, "vertical"))
                          :addButtonPair(tactile.keys(keys.up), tactile.keys(keys.down)),
        attack = tactile.newControl()
                        :addButton(tactile.gamepadButtons(gamepadNum, buttons.attack))
                        :addButton(tactile.keys(keys.attack)),
        jump = tactile.newControl()
                      :addButton(tactile.gamepadButtons(gamepadNum, buttons.jump))
                      :addButton(tactile.keys(keys.jump)),
        strafe = tactile.newControl()
                        :addButton(function() return false end),
        start = tactile.newControl()
                       :addButton(tactile.keys(keys.start))
                       :addButton(tactile.gamepadButtons(gamepadNum, buttons.start)),
        back = tactile.newControl()
                      :addButton(tactile.keys(keys.back))
                      :addButton(tactile.gamepadButtons(gamepadNum, buttons.back)),
        fullScreen = tactile.newControl()
                            :addButton(tactile.keys(keys.fullScreen)),
        screenshot = tactile.newControl()
                            :addButton(tactile.keys(keys.screenshot))
                            :addButton(tactile.keys(keys.screenshot2))
    }
end

function bindGameInput()
    Controls = {}
    for i = 1, 3 do
        local p = getRegisteredPlayer(i)
        Controls[i] = createControl( i, commonPlayersGamepadButtons, playersKeys[i] )   -- Controls should be created for all possible players
        if p then
            p.b = Controls[i]
        end
    end
end

local function checkDoubleTapState(directionControl)
    local value = directionControl:getValue()
    local doubleTap = directionControl.doubleTap
    directionControl.isDoubleTap = false
    if directionControl:pressed() then
        if value == doubleTap.lastDirection and love.timer.getTime() - doubleTap.lastTapTime <= delayWithSlowMotion(doubleTapDelta) then
            directionControl.isDoubleTap = true
            doubleTap.lastDoubleTapDirection = value
            doubleTap.lastDoubleTapTime = love.timer.getTime()
        else
            doubleTap.lastDirection = value
        end
        doubleTap.lastTapTime = love.timer.getTime()
    end
end

-- adds volatile properties to controls:
-- self.b.horizontal.isDoubleTap - contains true on double tap
-- self.b.horizontal.doubleTap.lastDirection - contains last double tap direction
-- self.b.horizontal.doubleTap.lastAttackTapTime - contains last Attack tap time
-- self.b.horizontal.doubleTap.lastJumpTapTime - contains last Jump tap time
function updateDoubleTap(control)
    local h = control.horizontal
    local v = control.vertical
    local a = control.attack
    if not h.doubleTap then
        h.doubleTap = { lastDirection = 0, lastTapTime = 0, lastDoubleTapDirection = 0, lastDoubleTapTime = 0, lastAttackTapTime = 0, lastJumpTapTime = 0 }
        v.doubleTap = { lastDirection = 0, lastTapTime = 0, lastDoubleTapDirection = 0, lastDoubleTapTime = 0 }
        a.doubleTap = { lastDirection = 0, lastTapTime = 0, lastDoubleTapDirection = 0, lastDoubleTapTime = 0 }
    end
    checkDoubleTapState(h)
    checkDoubleTapState(v)
    checkDoubleTapState(a)
    if control.attack:pressed() then
        h.doubleTap.lastAttackTapTime = love.timer.getTime()
    end
    if control.jump:pressed() then
        h.doubleTap.lastJumpTapTime = love.timer.getTime()
    end
end

function isSpecialCommand(control)
    return (control.attack:pressed() and control.jump:isDown()) or (control.jump:pressed() and control.attack:isDown())
end

function bindEnemyInput()
    local Controls = { h = 0, v = 0, a = false, j = false, s = false }
    Controls.horizontal = tactile.newControl()
                                 :addAxis( function() return Controls.h end )
    Controls.vertical = tactile.newControl()
                               :addAxis( function() return Controls.v end )
    Controls.horizontal.doubleTap = { lastDirection = 0, lastTapTime = 0, lastDoubleTapDirection = 0, lastDoubleTapTime = 0, lastAttackTapTime = 0, lastJumpTapTime = 0 }
    Controls.vertical.doubleTap = { lastDirection = 0, lastTapTime = 0, lastDoubleTapDirection = 0, lastDoubleTapTime = 0 }
    Controls.attack = tactile.newControl()
                             :addButton( function() return Controls.a end )
    Controls.jump = tactile.newControl()
                           :addButton(function() return Controls.j end)
    Controls.strafe = tactile.newControl()
                           :addButton(function() return Controls.s end)
    Controls.setJump = function(st) Controls.j = st end
    Controls.setAttack = function(st) Controls.a = st end
    Controls.setStrafe = function(st) Controls.s = st end
    Controls.setHorizontal = function(st) Controls.h = st or 0 end
    Controls.setVertical = function(st) Controls.v = st or 0 end
    Controls.setHorizontalAndVertical = function(sth, stv) Controls.h = sth or 0; Controls.v = stv or 0 end
    Controls.doHorizontalDoubleTap = function(lastDirection)
        Controls.horizontal.isDoubleTap = true
        Controls.horizontal.doubleTap.lastDirection = lastDirection or 0
        Controls.horizontal.doubleTap.lastDoubleTapDirection = lastDirection or 0
        Controls.horizontal.doubleTap.lastDoubleTapTime = love.timer.getTime() - 0.05
    end
    Controls.doVerticalDoubleTap = function(lastDirection)
        Controls.vertical.isDoubleTap = true
        Controls.vertical.doubleTap.lastDirection = lastDirection or 0
        Controls.vertical.doubleTap.lastDoubleTapDirection = lastDirection or 0
        Controls.vertical.doubleTap.lastDoubleTapTime = love.timer.getTime() - 0.05
    end
    Controls.resetButtons = function() Controls.h= 0; Controls.v = 0; Controls.a = false; Controls.j = false; Controls.s = false end
    Controls.reset = function() Controls.h= 0; Controls.v = 0; Controls.a = false; Controls.j = false; Controls.s = false; Controls.horizontal.isDoubleTap = false; Controls.vertical.isDoubleTap = false end
    Controls.resetDoubleTap = function() Controls.horizontal.isDoubleTap = false; Controls.vertical.isDoubleTap = false end
    Controls.update = function(dt)
        Controls.horizontal:update(dt)
        Controls.vertical:update(dt)
        Controls.jump:update(dt)
        Controls.attack:update(dt)
        Controls.strafe:update(dt)
    end
    return Controls
end

local r = love.math.random
function bindRandomDebugInput()
    local _Controls = bindEnemyInput()
    _Controls.debugUpdate = function(dt)
        if r(100) < 3 then
            if r(100) < 50 then
                _Controls.setAttack(true)
            elseif r(100) < 50 then
                _Controls.setAttack(false)
            end
        end
        if r(100) < 2 then
            if r(100) < 50 then
                _Controls.setJump(true)
            elseif r(100) < 50 then
                _Controls.setJump(false)
            end
        end

        if r(100) < 5 then
            if r(100) < 20 then
                _Controls.setHorizontal(-1)
            else
                _Controls.setHorizontal(r(0, 1))
            end
            if r(100) < 10 then
                _Controls.doHorizontalDoubleTap()
            end
        end
        if r(100) < 2 then
            _Controls.setVertical(r(-1, 1))
            if r(100) < 10 then
                _Controls.doVerticalDoubleTap()
            end
        end

        if r(1000) <= 5 then
            _Controls.resetButtons()    -- all the buttons and h/v controls are not pressed
        end
        _Controls.horizontal:update(dt)
        _Controls.vertical:update(dt)
        _Controls.jump:update(dt)
        _Controls.attack:update(dt)
    end
    return _Controls
end
