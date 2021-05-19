local class = require "lib/middleclass"
local stageImage = class("StageImage", Stopper)

local function nop() end

function stageImage:initialize(name, image)
    assert(image, "need a table of arguments")
    self.image = image
    self.width = image.w or 10
    self.height = image.h or 10
    self.depth = 1
    Unit.initialize(self, name, nil, image.x + image.w / 2, image.y + image.h, image)
    self.width = image.w or 10 -- because Unit.initialize changes real width
    self.name = name or "Unknown Image"
    self.type = "stageImage"
    self.isObstacle = false
    self.isHittable = false
    self.isDisabled = false
    self.isMovable = false
    self.lifeBar = nil
end

function stageImage:setOnStage(stage)
    stage.objects:add(self)
end

function stageImage:getHeight()
    return self.height
end

function stageImage:updateSprite(dt)
    if dt <= 0 then return end -- skip animation update on the class init
    CompoundPicture.updateOne(self.image, self.image, dt)
end

function stageImage:setSprite(anim)
end

function stageImage:drawSprite(l, t, w, h)
    CompoundPicture.drawOne(self.image, self.image, l, t, w, h, false)
end

function stageImage:drawShadow(l, t, w, h)
end

function stageImage:drawReflection(l, t, w, h)
end

function stageImage:defaultDraw(l, t, w, h)
    if isDebug(SHOW_DEBUG_BOXES) and CheckCollision(l, t, w, h, self.x - self.width / 2, self.y - self.height, self.width, self.height) then
        colors:set("lightBlue", nil, 25)
        love.graphics.rectangle("line", self.x - self.width / 2, self.y - self.height, self.width, self.height)
    end
    colors:set("white")
    self:drawSprite(l, t, w, h)
end

function stageImage:updateAI(dt)
    self:updateSprite(dt)
end

function stageImage:onHurt()
end

stageImage.stand = { name = "stand", start = nop, exit = nop, update = nop, draw = stageImage.defaultDraw}

return stageImage
