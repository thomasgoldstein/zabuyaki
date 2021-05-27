-- Visuals and SFX go here

local StageObject = StageObject

local sign = sign
local round = math.floor

local particles
function StageObject:showEffect(effect, obj)
    if effect == "breakMetal" then
        self:playSfx(self.sfx.onBreak)
        particles = PA_OBSTACLE_BREAK_SMALL:clone()
        particles:setPosition( 0, -obj.z )
        if self.particleColor then
            particles:setColors( love.math.colorFromBytes(unpack(self.particleColor)) )
        end
        particles:setLinearAcceleration(sign(-self.face) * 100 , -500, sign(-self.face) * 400, 500) -- Random movement in all directions.
        particles:emit(4)
        particles:setLinearAcceleration(sign(self.face) * 100 , -500, sign(self.face) * 400, 500) -- Random movement in all directions.
        particles:emit(2)
        stage.objects:add(Effect:new(particles, round(self.x), round(self.y + 1), self.z))
        particles = PA_OBSTACLE_BREAK_BIG:clone()
        particles:setPosition( 0, -obj.z )
        if self.particleColor then
            particles:setColors( love.math.colorFromBytes(unpack(self.particleColor)) )
        end
        --particles:setEmissionArea( "uniform", 2, 8 )
        particles:setLinearDamping( 0.1, 2 )
        particles:setLinearAcceleration(sign(-self.face) * 100 , -500, sign(-self.face) * 400, 500) -- Random movement in all directions.
        particles:emit(2)
        particles:setLinearAcceleration(sign(self.face) * 100 , -500, sign(self.face) * 400, 500) -- Random movement in all directions.
        particles:emit(1)
        stage.objects:add(Effect:new(particles, round(self.x), round(self.y + 1), self.z))
    else
        Character.showEffect(self, effect, obj)
    end
end

function StageObject:calcShadowSpriteAndTransparency()
    local transparency = self.deathDelay < 1 and 255 * math.sin(self.deathDelay) or 255
    colors:set("black", nil, transparency)
    local spr = self.sprite
    local image = imageBank[spr.def.spriteSheet]
    local sc = spr.def.animations[spr.curAnim][spr.curFrame]
    local shadowAngle = -stage.shadowAngle * spr.flipH
    return image, spr, sc, shadowAngle, -2
end

function StageObject:calcReflectionSpriteAndTransparency()
    local transparency = self.deathDelay < 1 and 255 * math.sin(self.deathDelay) or 255
    colors:set("white", nil, transparency)
    local spr = self.sprite
    local image = imageBank[spr.def.spriteSheet]
    local sc = spr.def.animations[spr.curAnim][spr.curFrame]
    local shadowAngle = 0 -- -stage.shadowAngle * spr.flipH
    return image, spr, sc, shadowAngle, -2
end

-- borrow Lifebar methods from Character class
StageObject.initFaceIcon = Character.initFaceIcon
StageObject.drawFaceIcon = Character.drawFaceIcon
StageObject.drawTextInfo = Character.drawTextInfo
StageObject.getBarTransparency = Character.getBarTransparency
StageObject.drawLivesLeftNumber = Character.drawLivesLeftNumber
StageObject.drawScore = Character.drawScore
StageObject.drawBar = Character.drawBar
