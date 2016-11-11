--
-- Date: 09.11.2016
--
local class = require "lib/middleclass"

local function nop() --[[print "nop"]] end

local Wall = class("Wall", Unit)

function Wall:initialize(name, shapeType, shargs, f)
    --f options {}: hp, score, shader, color,isMovable, sfxDead, func, face, horizontal, weight, sfxOnHit, sfxOnBreak
    if not f then
        f = {}
    end
    local x,y = shargs[1], shargs[2]
    Unit.initialize(self, name, nil, nil, x, y, f)
    self.name = name or "Unknown Wall"
    self.type = "wall"
    self.lives = 0
    self.height = 40
    self.vertical, self.horizontal, self.face = 1, f.horizontal or 1, f.face or 1 --movement and face directions
    self.isHittable = false
    self.isDisabled = false
    self.isMovable = f.isMovable --on death sfx

    self.infoBar = nil

    self:addShape(shapeType or "rectangle", shargs)

    self:setState(self.stand)
end

function Wall:addShape(shapeType, shargs)
    if not self.shape then
        if shapeType == "rectangle" then
            self.shape = stage.world:rectangle(unpack(shargs))
        elseif shapeType == "circle" then
            self.shape = stage.world:circle(unpack(shargs))
        elseif shapeType == "polygon" then
            self.shape = stage.world:polygon(unpack(shargs))
        elseif shapeType == "point" then
            self.shape = stage.world:point(unpack(shargs))
        else
            error(self.name.."("..self.id.."): Unknown shape type -"..shapeType)
        end
        if shargs.rotate then
            self.shape:rotate(shargs.rotate)
        end
        self.shape.obj = self
    else
        print(self.name.."("..self.id..") has predefined shape")
    end
end

function Wall:updateSprite(dt)
end

function Wall:setSprite(anim)
end

function Wall:drawSprite(l,t,w,h)
end

function Wall:drawShadow(l,t,w,h)
end

function Wall:updateAI(dt)
--    print(self.name, self.shape:center())
end

function Wall:onHurt()
end

Wall.stand = {name = "stand", start = nop, exit = nop, update = nop, draw = nop}

return Wall