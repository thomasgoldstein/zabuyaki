local doubleTapDelta = 0.25

local connected = {}
function love.joystickadded(joystick)
    connected[joystick] = joystick
    dp(joystick:getGUID().." added joystick "..joystick:getName().." with "..joystick:getButtonCount().." buttons")
    love.joystick.loadGamepadMappings( "res/gamecontrollerdb.txt" )
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

function bindGameInput()
    Controls = {}
    -- define Player 1 controls
    local gamepad1 = 1
    local gamepad2 = 2
    local gamepad3 = 3
    Controls[gamepad1] = {
        horizontal = tactile.newControl()
                            :addAxis(gamepadDigitalAxis(gamepad1, 'leftx'))
                            :addAxis(gamepadHat(gamepad1, 1, "horizontal"))
        --:addAxis(gamepadDigitalAxis(1, 'rightx'))
                            :addButtonPair(tactile.keys('left'), tactile.keys('right')),
        vertical = tactile.newControl()
                          :addAxis(gamepadDigitalAxis(gamepad1, 'lefty'))
                          :addAxis(gamepadHat(gamepad1, 1, "vertical"))
        --:addAxis(gamepadDigitalAxis(1, 'righty'))
                          :addButtonPair(tactile.keys('up'), tactile.keys('down')),
        attack = tactile.newControl()
                        :addButton(tactile.gamepadButtons(gamepad1, 'a'))
                        :addButton(tactile.keys('x')),
        jump = tactile.newControl()
                      :addButton(tactile.gamepadButtons(gamepad1, 'b'))
                      :addButton(tactile.keys('c')),
        strafe = tactile.newControl()
                :addButton(function() return false end),
        --TODO test
        start = tactile.newControl()
                       :addButton(tactile.keys('return'))
                       :addButton(tactile.gamepadButtons(gamepad1, 'start')),
        back = tactile.newControl()
                      :addButton(tactile.keys('escape'))
                      :addButton(tactile.gamepadButtons(gamepad1, 'back')),
        fullScreen = tactile.newControl()
                            :addButton(tactile.keys('f11')),
        screenshot = tactile.newControl()
                            :addButton(tactile.keys('pause'))
    }
    -- define Player 2 controls
    Controls[gamepad2] = {
        horizontal = tactile.newControl()
                            :addAxis(gamepadDigitalAxis(gamepad2, 'leftx'))
                            :addAxis(gamepadHat(gamepad2, 1, "horizontal"))
                            :addButtonPair(tactile.keys('a'), tactile.keys('d')),
        vertical = tactile.newControl()
                          :addAxis(gamepadDigitalAxis(gamepad2, 'lefty'))
                          :addAxis(gamepadHat(gamepad2, 1, "vertical"))
                          :addButtonPair(tactile.keys('w'), tactile.keys('s')),
        attack = tactile.newControl()
                        :addButton(tactile.gamepadButtons(gamepad2, 'a'))
                        :addButton(tactile.keys 'i'),
        jump = tactile.newControl()
                      :addButton(tactile.gamepadButtons(gamepad2, 'b'))
                      :addButton(tactile.keys 'o'),
        strafe = tactile.newControl()
                        :addButton(function() return false end),
        start = tactile.newControl()
                       :addButton(tactile.gamepadButtons(gamepad2, 'start')),
        back = tactile.newControl()
                      :addButton(tactile.gamepadButtons(gamepad2, 'back'))
    }
    -- define Player 3 controls
    Controls[gamepad3] = {
        horizontal = tactile.newControl()
                            :addAxis(gamepadDigitalAxis(gamepad3, 'leftx'))
                            :addAxis(gamepadHat(gamepad3, 1, "horizontal"))
                            :addButtonPair(tactile.keys('f'), tactile.keys('h')),
        vertical = tactile.newControl()
                          :addAxis(gamepadDigitalAxis(gamepad3, 'lefty'))
                          :addAxis(gamepadHat(gamepad3, 1, "vertical"))
                          :addButtonPair(tactile.keys('t'), tactile.keys('g')),
        attack = tactile.newControl()
                        :addButton(tactile.gamepadButtons(gamepad3, 'a'))
                        :addButton(tactile.keys 'r'),
        jump = tactile.newControl()
                      :addButton(tactile.gamepadButtons(gamepad3, 'b'))
                      :addButton(tactile.keys 'y'),
        strafe = tactile.newControl()
                        :addButton(function() return false end),
        start = tactile.newControl()
                       :addButton(tactile.gamepadButtons(gamepad3, 'start')),
        back = tactile.newControl()
                      :addButton(tactile.gamepadButtons(gamepad3, 'back'))
    }
    for i = 1, 3 do
        local p = getRegisteredPlayer(i)
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
    if not h.doubleTap then
        h.doubleTap = { lastDirection = 0, lastTapTime = 0, lastDoubleTapDirection = 0, lastDoubleTapTime = 0, lastAttackTapTime = 0, lastJumpTapTime = 0 }
        v.doubleTap = { lastDirection = 0, lastTapTime = 0, lastDoubleTapDirection = 0, lastDoubleTapTime = 0 }
    end
    checkDoubleTapState(h)
    checkDoubleTapState(v)
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
    Controls.doHorizontalDoubleTap = function() Controls.horizontal.isDoubleTap = true end
    Controls.doVerticalDoubleTap = function() Controls.vertical.isDoubleTap = true end
    Controls.resetButtons = function() Controls.h= 0; Controls.v = 0; Controls.a = false; Controls.j = false; Controls.s = false end
    Controls.reset = function() Controls.h= 0; Controls.v = 0; Controls.a = false; Controls.j = false; Controls.s = false end
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
