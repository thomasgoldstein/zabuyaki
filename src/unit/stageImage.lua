local class = require "lib/middleclass"
local stageImage = class("StageImage", Stopper)

local function nop() end

function stageImage:initialize(name, f)
    --f options {}: shapeType, shapeArgs, hp, score, shader, color,isMovable, sfxDead, func, face, horizontal, weight, sfxOnHit, sfxOnBreak
    if not f then
        f = { shapeType = "rectangle", shapeArgs = { 0, 0, 10, 10 } }
    end
    local x, y = f.shapeArgs[1] or 0, f.shapeArgs[2] or 0
    self.width, self.depth = f.shapeArgs[3] or 10, f.shapeArgs[4] or 10
    self.shift_x = 0
    x = x + self.width / 2
    y = y + self.depth / 2
    Unit.initialize(self, name, nil, x, y, f)
    self.name = name or "Unknown Image"
    self.type = "stageImage"
    self.vertical, self.horizontal, self.face = 1, f.horizontal or 1, f.face or 1 --movement and face directions
    self.isObstacle = false
    self.isHittable = false
    self.isDisabled = false
    self.isMovable = false
    self.lifeBar = nil
    self:setState(self.stand)
end

function stageImage:setOnStage(stage)
    stage.objects:add(self)
end

function stageImage:updateSprite(dt)
end

function stageImage:setSprite(anim)
end

function stageImage:drawSprite(l, t, w, h)
end

function stageImage:drawShadow(l, t, w, h)
end

function stageImage:drawReflection(l, t, w, h)
end

function stageImage:defaultDraw(l, t, w, h)
    if isDebug(SHOW_DEBUG_BOXES) and CheckCollision(l, t, w, h, self.x - self:getHurtBoxWidth() / 2, self.y - self:getHurtBoxDepth() / 2, self:getHurtBoxWidth(), self:getHurtBoxDepth()) then
        colors:set("lightBlue", nil, 50)
        love.graphics.rectangle("line", self.x - self:getHurtBoxWidth() / 2, self.y - self:getHurtBoxDepth() / 2, self:getHurtBoxWidth(), self:getHurtBoxDepth())
    end
end

function stageImage:updateAI(dt)
end

function stageImage:onHurt()
end

stageImage.stand = { name = "stand", start = nop, exit = nop, update = nop, draw = stageImage.defaultDraw}

return stageImage
