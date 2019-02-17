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
    local Controls = { h = 0, v = 0, a = false, j = false }
    Controls.horizontal = tactile.newControl()
                                 :addAxis( function() return this.h end )
    Controls.vertical = tactile.newControl()
                               :addAxis( function() return this.h end )
    Controls.attack = tactile.newControl()
                             :addButton( function() return this.a end )
    Controls.jump = tactile.newControl()
                           :addButton(function() return this.j end)
    return Controls
end
