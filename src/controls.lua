--
-- Date: 28.06.2016
--

--ff113133000000000000504944564944 Gembird

function love.joystickadded(joystick)
    p1joystick = joystick
    print (joystick:getGUID().." added joystick "..joystick:getName().." with "..joystick:getButtonCount().." buttons")
    if p1joystick then
        p2joystick = joystick
    elseif p2joystick then
        p3joystick = joystick
    end

    love.joystick.loadGamepadMappings( "res/gamecontrollerdb.txt" )
    local joysticks = love.joystick.getJoysticks()
    for i, joystick in ipairs(joysticks) do
        print("detected ",joystick:getName())
    end

--    love.joystick.setGamepadMapping( joystick:getGUID(), "a", "button", 1, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "b", "button", 2, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "x", "button", 3, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "y", "button", 4, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "back", "button", 5, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "guide", "button", 6, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "start", "button", 7, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "leftstick", "button", 8, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "rightstick", "button", 9, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "leftshoulder", "button", 10, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "rightshoulder", "button", 11, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "dpup", "button", 12, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "dpdown", "button", 13, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "dpleft", "button", 14, nil )
--    love.joystick.setGamepadMapping( joystick:getGUID(), "dpright", "button", 15, nil )

    --bind_game_input()
end

function love.joystickremoved( joystick )
    print ("removed joystick "..joystick:getName())
end

DUMMY_CONTROL = {}
DUMMY_CONTROL.horizontal = {
    getValue = function() return 0 end,
    isDown = function() return false end,
    pressed = function() return false end,
    released = function() return false end,
    update = function() return false end
}
DUMMY_CONTROL.vertical = {
    getValue = function() return 0 end,
    isDown = function() return false end,
    pressed = function() return false end,
    released = function() return false end,
    update = function() return false end
}
DUMMY_CONTROL.fire = {
    getValue = function() return 0 end,
    isDown = function() return false end,
    pressed = function() return false end,
    released = function() return false end,
    update = function() return false end
}
DUMMY_CONTROL.jump = {
    getValue = function() return 0 end,
    isDown = function() return false end,
    pressed = function() return false end,
    released = function() return false end,
    update = function() return false end
}

function bind_game_input()
    -- define Player 1 controls
    print ("binding keys")
    Control1 = {
        horizontal = tactile.newControl()
        :addAxis(tactile.gamepadAxis(1, 'leftx'))
        :addButtonPair(tactile.keys('left'), tactile.keys('right')),
        vertical = tactile.newControl()
        :addAxis(tactile.gamepadAxis(1, 'lefty'))
        :addButtonPair(tactile.keys('up'), tactile.keys('down')),
        fire = tactile.newControl()
        :addButton(tactile.gamepadButtons(1, 'a'))
        :addButton(tactile.keys('x')),
        jump = tactile.newControl()
        :addButton(tactile.gamepadButtons(1, 'b'))
        :addButton(tactile.keys('c')),
        --TODO test
        start = tactile.newControl()
        :addButton(tactile.keys('return'))
        :addButton(tactile.gamepadButtons(1, 'start')),
        back = tactile.newControl()
        :addButton(tactile.keys('escape'))
        :addButton(tactile.gamepadButtons(1, 'back')),
        fullScreen = tactile.newControl()
        :addButton(tactile.keys('f11'))
    }
    -- define Player 2 controls
    Control2 = {
        horizontal = tactile.newControl()
        :addAxis(tactile.gamepadAxis(2, 'leftx'))
        :addButtonPair(tactile.keys('a'), tactile.keys('d')),
        vertical = tactile.newControl()
        :addAxis(tactile.gamepadAxis(2, 'lefty'))
        :addButtonPair(tactile.keys('w'), tactile.keys('s')),
        fire = tactile.newControl()
        :addButton(tactile.gamepadButtons(2, 'a'))
        :addButton(tactile.keys 'i'),
        jump = tactile.newControl()
        :addButton(tactile.gamepadButtons(2, 'b'))
        :addButton(tactile.keys 'o'),
        start = tactile.newControl()
        :addButton(tactile.gamepadButtons(2, 'start')),
        back = tactile.newControl()
        :addButton(tactile.gamepadButtons(2, 'back'))
    }
    -- define Player 3 controls
    Control3 = {
        horizontal = tactile.newControl()
        :addAxis(tactile.gamepadAxis(3, 'leftx'))
        :addButtonPair(tactile.keys('f'), tactile.keys('h')),
        vertical = tactile.newControl()
        :addAxis(tactile.gamepadAxis(3, 'lefty'))
        :addButtonPair(tactile.keys('t'), tactile.keys('g')),
        fire = tactile.newControl()
        :addButton(tactile.gamepadButtons(3, 'a'))
        :addButton(tactile.keys 'r'),
        jump = tactile.newControl()
        :addButton(tactile.gamepadButtons(3, 'b'))
        :addButton(tactile.keys 'y'),
        start = tactile.newControl()
        :addButton(tactile.gamepadButtons(3, 'start')),
        back = tactile.newControl()
        :addButton(tactile.gamepadButtons(3, 'back'))
    }

    local double_press_delta = 0.15
    --add keyTrace into every player 1 button
    for index,value in pairs(Control1) do
        local b = Control1[index]
        if index == "horizontal" or index == "vertical" then
            --for derections
            b.ikn = KeyTrace:new(index, value, -1, double_press_delta)  --negative dir
            b.ikp = KeyTrace:new(index, value, 1, double_press_delta)   --positive dir
        else
            b.ik = KeyTrace:new(index, value, nil, double_press_delta)
        end
    end
    --add keyTrace into every player 2 button
    for index,value in pairs(Control2) do
        local b = Control2[index]
        if index == "horizontal" or index == "vertical" then
            --for derections
            b.ikn = KeyTrace:new(index, value, -1, double_press_delta)  --negative dir
            b.ikp = KeyTrace:new(index, value, 1, double_press_delta)   --positive dir
        else
            b.ik = KeyTrace:new(index, value, nil, double_press_delta)
        end
    end
    --add keyTrace into every player 3 button
    for index,value in pairs(Control3) do
        local b = Control3[index]
        if index == "horizontal" or index == "vertical" then
            --for derections
            b.ikn = KeyTrace:new(index, value, -1, double_press_delta)  --negative dir
            b.ikp = KeyTrace:new(index, value, 1, double_press_delta)   --positive dir
        else
            b.ik = KeyTrace:new(index, value, nil, double_press_delta)
        end
    end
end
