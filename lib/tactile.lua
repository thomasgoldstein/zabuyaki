local tactile = {
  _VERSION     = 'Tactile v1.2',
  _DESCRIPTION = 'A simple and straightfoward input library for LÖVE.',
  _URL         = 'https://github.com/tesselode/tactile',
  _LICENSE     = [[
    The MIT License (MIT)

    Copyright (c) 2015 Andrew Minnich

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

local function removeByValue(t, value)
  for i = #t, 1, -1 do
    if t[i] == value then
      table.remove(t, i)
      break
    end
  end
end

--button class
local Button = {}
Button.__index = Button

function Button:update()
  self.downPrev = self.down
  self.down = false

  --check whether any detectors are down
  for i = 1, #self.detectors do
    if self.detectors[i]() then
      self.down = true
      break
    end
  end
end

function Button:addDetector(detector)
  table.insert(self.detectors, detector)
end

function Button:removeDetector(detector)
  removeByValue(self.detectors, detector)
end

function Button:isDown() return self.down end
function Button:pressed() return self.down and not self.downPrev end
function Button:released() return self.downPrev and not self.down end

--axis class
local Axis = {}
Axis.__index = Axis

function Axis:getValue(deadzone)
  deadzone = deadzone or self.deadzone
  self.value = 0

  --check whether any detectors have a value greater than the deadzone
  for i = 1, #self.detectors do
    local value = self.detectors[i]()
    if math.abs(value) > deadzone then
      self.value = value
    end
  end

  return self.value
end

function Axis:addDetector(detector)
  table.insert(self.detectors, detector)
end

function Axis:removeDetector(detector)
  removeByValue(self.detectors, detector)
end

--main module
tactile.__index = tactile

--button detectors
function tactile.key(key)
  assert(type(key) == 'string',
    'key should be a KeyConstant (string)')

  return function()
    return love.keyboard.isDown(key)
  end
end

function tactile.gamepadButton(button, gamepadNum)
  assert(type(button) == 'string',
    'button should be a GamepadButton (string)')
  assert(type(gamepadNum) == 'number',
    'gamepadNum should be a number')

  return function()
    local gamepad = love.joystick.getJoysticks()[gamepadNum]
    return gamepad and gamepad:isGamepadDown(button)
  end
end

function tactile.mouseButton(button)
  local major, minor, revision = love.getVersion()
  local t = "string"

  -- LOVE 0.10+ switched from strings (l, r, m) to numbers (1, 2, 3)
  if minor > 9 then
    t = "number"
  end
  assert(type(button) == t,
    'button should be a MouseButton ('..t..')')

  return function()
    return love.mouse.isDown(button)
  end
end

function tactile.thresholdButton(axisDetector, threshold)
  assert(axisDetector, 'No axisDetector supplied')
  assert(type(threshold) == 'number',
    'threshold should be a number')

  return function()
    local value = axisDetector()
    return value and math.abs(value) > math.abs(threshold) and (value < 0) == (threshold < 0)
  end
end

--axis detectors
function tactile.binaryAxis(negative, positive)
  assert(negative, 'No negative button detector supplied')
  assert(positive, 'No positive button detector supplied')

  return function()
    local negativeValue, positiveValue = negative(), positive()
    if negativeValue and not positiveValue then
      return -1
    elseif positiveValue and not negativeValue then
      return 1
    else
      return 0
    end
  end
end

function tactile.analogStick(axis, gamepadNum)
  assert(type(axis) == 'string',
    'axis should be a GamepadAxis (string)')
  assert(type(gamepadNum) == 'number',
    'gamepadNum should be a number')

  return function()
    local gamepad = love.joystick.getJoysticks()[gamepadNum]
    return gamepad and gamepad:getGamepadAxis(axis) or 0
  end
end

--button constructor
function tactile.newButton(...)
  local buttonInstance = {
    detectors = {...},
    down      = false,
    downPrev  = false
  }
  return setmetatable(buttonInstance, Button)
end

--axis constructor
function tactile.newAxis(...)
  local axisInstance = {
    detectors = {...},
    deadzone  = 0.5
  }
  return setmetatable(axisInstance, Axis)
end

return tactile
