local class = require "lib/middleclass"
local Wall = class("Wall", Stopper)

local function nop() end

function Wall:initialize(name, f)
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
    self.name = name or "Unknown Wall"
    self.type = "wall"
    self.vertical, self.horizontal, self.face = 1, f.horizontal or 1, f.face or 1 --movement and face directions
    self.isObstacle = true
    self.isHittable = false
    self.isDisabled = false
    self.isMovable = false
    self.lifeBar = nil
    self:setState(self.stand)
end

function Wall:setOnStage(stage)
    stage.objects:add(self)
end

function Wall:updateSprite(dt)
end

function Wall:setSprite(anim)
end

function Wall:drawSprite(l,t,w,h)
end

function Wall:drawShadow(l,t,w,h)
end

function Wall:drawReflection(l,t,w,h)
end

function Wall:defaultDraw(l,t,w,h)
    if isDebug(SHOW_DEBUG_BOXES) and CheckCollision(l, t, w, h, self.x - self:getHurtBoxWidth() / 2, self.y - self:getHurtBoxDepth() / 2, self:getHurtBoxWidth(), self:getHurtBoxDepth()) then
        colors:set("lightBlue", nil, 50)
        love.graphics.rectangle("line", self.x - self:getHurtBoxWidth() / 2, self.y - self:getHurtBoxDepth() / 2, self:getHurtBoxWidth(), self:getHurtBoxDepth())
    end
end

function Wall:updateAI(dt)
end

function Wall:onHurt()
end

Wall.stand = {name = "stand", start = nop, exit = nop, update = nop, draw = Wall.defaultDraw}

return Wall
