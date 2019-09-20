local class = require "lib/middleclass"
local Platform = class("Platform", Stopper)

local function nop() end

function Platform:initialize(name, f)
    --f options {}: shapeType, shapeArgs, hp, score, shader, color,isMovable, sfxDead, func, face, horizontal, weight, sfxOnHit, sfxOnBreak
    if not f then
        f = { shapeType = "rectangle", shapeArgs = { 0, 0, 10, 10 } }
    end
    local x, y = f.shapeArgs[1] or 0, f.shapeArgs[2] or 0
    self.width, self.depth = f.shapeArgs[3] or 10, f.shapeArgs[4] or 10
    x = x + self.width / 2
    y = y + self.depth / 2
    Unit.initialize(self, name, nil, x, y, f)
    self.name = name or "Unknown Platform"
    self.type = "platform"
    self.vertical, self.horizontal, self.face = 1, f.horizontal or 1, f.face or 1 --movement and face directions
    self.isObstacle = true
    self.isHittable = false
    self.isDisabled = false
    self.isMovable = false
    self.lifeBar = nil
    self:setState(self.stand)
end

function Platform:setOnStage(stage)
    stage.objects:add(self)
end

function Platform:updateSprite(dt)
end

function Platform:setSprite(anim)
end

function Platform:drawSprite(l,t,w,h)
end

function Platform:drawShadow(l,t,w,h)
end

function Platform:drawReflection(l,t,w,h)
end

function Platform:updateAI(dt)
end

function Platform:onHurt()
end

Platform.stand = {name = "stand", start = nop, exit = nop, update = nop, draw = nop}

return Platform
