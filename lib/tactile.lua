local tactile = {
  _VERSION = 'Tactile v2.0.1',
  _DESCRIPTION = 'A happy and friendly input library for LÖVE.',
  _URL = 'https://github.com/tesselode/tactile',
  _LICENSE = [[
    Copyright (c) 2016 Andrew Minnich

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  ]]
}

local function sign(x)
  return x < 0 and -1 or x > 0 and 1 or 0
end

local function verify(identity, argnum, value, expected, expectedstring)
  if type(value) ~= expected then
    error(string.format("%s: argument %d should be a %s, got %s", identity,
      argnum, expectedstring or expected, type(value)))
  end
end

local Control = {}

function Control:addAxis(f)
  table.insert(self._detectors, f)
  return self
end

function Control:addButton(f)
  table.insert(self._detectors, function()
    return f() and 1 or 0
  end)
  return self
end

function Control:addButtonPair(negative, positive)
  table.insert(self._detectors, function()
    local n, p = negative(), positive()
    return n and p and 0
      or n and -1
      or p and 1
      or 0
  end)
  return self
end

function Control:_calculateValue()
  for i = #self._detectors, 1, -1 do
    local value = self._detectors[i]()
    if math.abs(value) > self.deadzone then
      return value
    end
  end
  return 0
end

function Control:getValue()
  return self._currentValue
end

function Control:isDown(dir)
  if dir then
    return sign(self._currentValue) == sign(dir)
  end
  return self._currentValue ~= 0
end

function Control:pressed(dir)
  if dir then
    dir = sign(dir)
    return sign(self._currentValue) == dir
      and sign(self._previousValue) ~= dir
  end
  return self._currentValue ~= 0
    and self._previousValue == 0
end

function Control:released(dir)
  if dir then
    dir = sign(dir)
    return sign(self._currentValue) ~= dir
      and sign(self._previousValue) == dir
  end
  return self._currentValue == 0
    and self._previousValue ~= 0
end

function Control:update()
  self._previousValue = self._currentValue
  self._currentValue = self:_calculateValue()
end

function tactile.newControl()
  local control = {
    deadzone = .5,
    _detectors = {},
    _currentValue = 0,
    _previousValue = 0,
  }

  setmetatable(control, {
    __index = Control,
    __call = function(t)
      return t:getValue()
    end
  })

  return control
end

function tactile.keys(...)
  local keys = {...}
  for i, key in ipairs(keys) do
    verify('tactile.keys()', i, key, 'string', 'KeyConstant (string)')
  end
  return function()
    return love.keyboard.isDown(unpack(keys))
  end
end

function tactile.gamepadButtons(num, ...)
  local buttons = {...}
  for i, button in ipairs(buttons) do
    verify('tactile.gamepadButtons()', i, button, 'string',
      'GamepadButton (string)')
  end
  return function()
    local joystick = love.joystick.getJoysticks()[num]
    return joystick ~= nil and joystick:isGamepadDown(unpack(buttons))
  end
end

function tactile.gamepadAxis(num, axis)
  verify('tactile.gamepadAxis()', 1, num, 'number')
  verify('tactile.gamepadAxis()', 2, axis, 'string', 'GamepadAxis (string)')
  return function()
    local joystick = love.joystick.getJoysticks()[num]
    return joystick ~= nil and joystick:getGamepadAxis(axis) or 0
  end
end

return tactile
