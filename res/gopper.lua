local image_w = 80 --This info can be accessed with a Love2D call
local image_h = 193 --after the image has been loaded

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local step_sfx = function(self) TEsound.play("res/sfx/step.wav", nil, 0.5)
self.particles:setLinearAcceleration(-self.face * 60, 1, -self.face * 100, -15)
self.particles:emit(10)
end
local step_sfx2 = function(self) TEsound.play("res/sfx/step.wav", nil, 1)
self.particles:setLinearAcceleration(-self.face * 80, 1, -self.face * 120, -20)
self.particles:emit(20)
end
local jump_still_attack = function(self) self:checkAndAttack(28,0, 20,12, 13, "fall") end
local grabKO_attack = function(self) self:checkAndAttackGrabbed(20,0, 20,12, 11, "grabKO") end
local grabLow_attack = function(self) self:checkAndAttackGrabbed(10,0, 20,12, 8, "low") end
local combo_attack = function(slf)
    slf:checkAndAttack(30,0, 22,12, 7, "high", "res/sfx/attack1.wav")
    slf.cool_down_combo = 0.4
end
local dash_attack = function(slf) slf.permAttack = slf:checkAndAttack(20,0, 55,12, 20, "fall") end
local jump_forward_attack = function(slf) slf.permAttack = function(slf) slf:checkAndAttack(32,0, 25,12, 15, "fall") end end
local jump_weak_attack = function(slf)
    slf.permAttack = function(slf)
        if slf.z > 30 then
            slf:checkAndAttack(15,0, 22,12, 8, "high")
        elseif slf.z > 10 then
            slf:checkAndAttack(15,0, 22,12, 8, "low")
        end
    end
end

return {
    serialization_version = 0.42, -- The version of this serialization process

    sprite_sheet = "res/gopper.png", -- The path to the spritesheet
    --TODO read width/height of the sheet automatically.
    sprite_name = "gopper", -- The name of the sprite

    delay = 0.20,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon  = {
            { q = q(21, 21, 16, 16) }
        },
        stand = {
            -- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = fun
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            loop = true,
            delay = 0.167
        },
        walk = {
			{ q = q(2,66,36,62), ox = 18, oy = 61 }, --walk 1
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
			{ q = q(40,67,38,61), ox = 18, oy = 60 }, --walk 2
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            loop = true,
            delay = 0.167
        },
        run = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            loop = true,
            delay = 0.1
        },
        jump = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 5
        },
        duck = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 0.15
        },
        pickup = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 0.05
        },
        dash = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 0.16
        },
        combo = {
            { q = q(2,130,62,61), ox = 18, oy = 60, func = combo_attack }, --punch
            delay = 0.1
        },
        fall = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 0.2
        },
        getup = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 0.2
        },
        dead = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 65
        },
        hurtHigh = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 0.1
        },
        hurtLow = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 0.1
        },
        jumpAttackForward = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 5
        },
        jumpAttackWeak = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 5
        },
        jumpAttackStill = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 5
        },
        sideStepUp = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
        },
        sideStepDown = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
        },
        grab = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
        },
        grabHit = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 0.05
        },
        grabHitLast = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 0.05
        },
        grabHitEnd = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 0.1
        },
        grabThrow = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
        },
        grabSwap = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
        },
        grabbed = {
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            delay = 0.1
        },

    } --offsets

} --return (end of file)
