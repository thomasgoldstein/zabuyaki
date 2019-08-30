local class = require "lib/middleclass"
local Stopper = class("Stopper", Unit)

local function nop() end

function Stopper:initialize(name, f)
    --f options {}: shapeType, shapeArgs, hp, score, shader, color,isMovable, sfxDead, func, face, horizontal, weight, sfxOnHit, sfxOnBreak
    if not f then
        f = { shapeType = "rectangle", shapeArgs = { 0, 0, 20, 100 } }
    end
    local x, y = f.shapeArgs[1] or 0, f.shapeArgs[2] or 0
    local width, height = f.shapeArgs[3] or 20, f.shapeArgs[4] or 240
    Unit.initialize(self, name, nil, x, y, f)
    self.name = name or "Unknown Stopper"
    self.type = "stopper"
    self.vertical, self.horizontal, self.face = 1, f.horizontal or 1, f.face or 1 --movement and face directions
    self.isHittable = false
    self.isDisabled = false
    self.isMovable = false
    self.width = width
    self.height = height
    self.lifeBar = nil
    self:setState(self.stand)
end

function Stopper:moveTo(x, y)
    self.shape:moveTo(x, y)
    self.x, self.y = x, y
end

function Stopper:updateSprite(dt)
end

function Stopper:setSprite(anim)
end

function Stopper:drawSprite(l,t,w,h)
end

function Stopper:drawShadow(l,t,w,h)
end

function Stopper:drawReflection(l,t,w,h)
end

function Stopper:updateAI(dt)
end

function Stopper:onHurt()
end

Stopper.stand = {name = "stand", start = nop, exit = nop, update = nop, draw = nop}

function Stopper:getFace()
    return 1    -- stoppers and walls have no sprite face
end

function Stopper:getHurtBoxWidth()
    return self.width
end
function Stopper:getHurtBoxHeight()
    return math.huge
end
function Stopper:getHurtBoxX()
    return 0
end
function Stopper:getHurtBoxY()
    return 0
end
function Stopper:getHeight()
    return math.huge
end
function Stopper:getHurtBoxDepth()
    return self.height
end

return Stopper
