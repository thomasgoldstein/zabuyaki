--
-- Date: 13.06.2016
--

function love.joystickadded(joystick)
    p1joystick = joystick
    print ("added joystick "..joystick:getName())
    if p1joystick then
        p2joystick = joystick
    elseif p2joystick then
        p3joystick = joystick
    end
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
    --print ("binding keys")
    Control1 = {
        horizontal = tactile.newControl()
        :addAxis(tactile.gamepadAxis(1, 'leftx'))
        :addButtonPair(tactile.keys('left'), tactile.keys('right')),
        vertical = tactile.newControl()
        :addAxis(tactile.gamepadAxis(1, 'lefty'))
        :addButtonPair(tactile.keys('up'), tactile.keys('down')),
        fire = tactile.newControl()
        :addAxis(tactile.gamepadAxis(1, 'triggerleft'))
        :addButton(tactile.gamepadButtons(1, 'a'))
        :addButton(tactile.keys 'x'),
        jump = tactile.newControl()
        :addAxis(tactile.gamepadAxis(1, 'triggerright'))
        :addButton(tactile.gamepadButtons(1, 'b'))
        :addButton(tactile.keys 'c')
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
        :addAxis(tactile.gamepadAxis(2, 'triggerleft'))
        :addButton(tactile.gamepadButtons(2, 'a'))
        :addButton(tactile.keys 'i'),
        jump = tactile.newControl()
        :addAxis(tactile.gamepadAxis(2, 'triggerright'))
        :addButton(tactile.gamepadButtons(2, 'b'))
        :addButton(tactile.keys 'o')
    }
    -- define Player 3 controls
    Control3 = {
        horizontal = tactile.newControl()
        :addButtonPair(tactile.keys('f'), tactile.keys('h')),
        vertical = tactile.newControl()
        :addButtonPair(tactile.keys('t'), tactile.keys('g')),
        fire = tactile.newControl()
        :addButton(tactile.keys 'r'),
        jump = tactile.newControl()
        :addButton(tactile.keys 'y')
    }

    --add keyTrace into every player 1 button
    for index,value in pairs(Control1) do
        local b = Control1[index]
        if index == "horizontal" or index == "vertical" then
            --for derections
            b.ikn = KeyTrace:new(index, value, -1)  --negative dir
            b.ikp = KeyTrace:new(index, value, 1)   --positive dir
        else
            b.ik = KeyTrace:new(index, value)
        end
    end
    --add keyTrace into every player 2 button
    for index,value in pairs(Control2) do
        local b = Control2[index]
        if index == "horizontal" or index == "vertical" then
            --for derections
            b.ikn = KeyTrace:new(index, value, -1)  --negative dir
            b.ikp = KeyTrace:new(index, value, 1)   --positive dir
        else
            b.ik = KeyTrace:new(index, value)
        end
    end
    --add keyTrace into every player 3 button
    for index,value in pairs(Control3) do
        local b = Control3[index]
        if index == "horizontal" or index == "vertical" then
            --for derections
            b.ikn = KeyTrace:new(index, value, -1)  --negative dir
            b.ikp = KeyTrace:new(index, value, 1)   --positive dir
        else
            b.ik = KeyTrace:new(index, value)
        end
    end
end
