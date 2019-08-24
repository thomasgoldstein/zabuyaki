local spriteSheet = "res/img/char/zeena.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local jumpAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 21, y = 17, width = 25, height = 45, damage = 13, type = "knockDown", repel_x = slf.dashFallSpeed },
        cont
) end
local comboSlap = function(slf, cont)
    slf:checkAndAttack(
        { x = 25, y = 32, width = 26, damage = 5, sfx = "air" },
        cont
    )
end
local comboKick = function(slf, cont)
    slf:checkAndAttack(
        { x = 21, y = 10, width = 25, damage = 8, type = "knockDown", repel_x = slf.dashFallSpeed, sfx = (slf.sprite.elapsedTime <= 0) and "air" },
        cont
    )
    -- move Zeena forward
    if slf.sprite.elapsedTime <= 0 then
        slf:initSlide(slf.slideSpeed_x, slf.slideDiagonalSpeed_x, slf.slideDiagonalSpeed_y, slf.slideSpeed_x * 2.5)
    end
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "zeena", -- The name of the sprite

    delay = 0.2,	--default delay for all animations
    hurtBox = { x = -10, y = 40, width = 20, height = 40 },
    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon = {
            { q = q(45, 74, 33, 17) },
            delay = math.huge
        },
        intro = {
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = math.huge
        },
        stand = {
            { q = q(2,2,39,59), ox = 22, oy = 58 }, --stand 1
            { q = q(43,3,40,58), ox = 23, oy = 57, delay = 0.18 }, --stand 2
            { q = q(85,4,40,57), ox = 23, oy = 56 }, --stand 3
            { q = q(43,3,40,58), ox = 23, oy = 57, delay = 0.16 }, --stand 2
            loop = true,
            delay = 0.2
        },
        walk = {
            { q = q(2,63,39,58), ox = 22, oy = 58, delay = 0.16 }, --walk 1
            { q = q(43,64,40,58), ox = 23, oy = 57 }, --walk 2
            { q = q(85,63,40,59), ox = 23, oy = 58, delay = 0.16 }, --walk 3
            { q = q(43,3,40,58), ox = 23, oy = 57 }, --stand 2
            loop = true,
            delay = 0.2
        },
        duck = {
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 0.06
        },
        sideStepUp = {
            { q = q(2,297,38,61), ox = 22, oy = 60 }, --jump
        },
        sideStepDown = {
            { q = q(2,297,38,61), ox = 22, oy = 60 }, --jump
        },
        jump = {
            { q = q(2,297,38,61), ox = 22, oy = 60 }, --jump
            delay = math.huge
        },
        jumpAttackStraight = {
            { q = q(42,297,43,57), ox = 25, oy = 61, delay = 0.06 }, --jump attack 1
            { q = q(87,297,66,53), ox = 32, oy = 61, funcCont = jumpAttack }, --jump attack 2
            delay = math.huge
        },
        jumpAttackStraightEnd = {
            { q = q(42,297,43,57), ox = 25, oy = 61 }, --jump attack 1
            delay = math.huge
        },
        jumpAttackForward = {
            { q = q(42,297,43,57), ox = 25, oy = 61, delay = 0.06 }, --jump attack 1
            { q = q(87,297,66,53), ox = 32, oy = 61, funcCont = jumpAttack }, --jump attack 2
            delay = math.huge
        },
        jumpAttackForwardEnd = {
            { q = q(42,297,43,57), ox = 25, oy = 61 }, --jump attack 1
            delay = math.huge
        },
        dropDown = {
            { q = q(2,297,38,61), ox = 22, oy = 60 }, --jump
            delay = math.huge
        },
        respawn = {
            { q = q(2,297,38,61), ox = 22, oy = 60 }, --jump
            { q = q(81,193,40,51), ox = 22, oy = 50, delay = 0.6 }, --duck
            delay = math.huge
        },
        pickUp = {
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 0.28
        },
        combo1 = {
            { q = q(116,360,40,58), ox = 20, oy = 57 }, --slap 3
            { q = q(59,360,55,58), ox = 17, oy = 57, func = comboSlap }, --slap 2
            { q = q(2,360,55,58), ox = 35, oy = 57 }, --slap 1
            delay = 0.067
        },
        combo2 = {
            { q = q(2,360,55,58), ox = 35, oy = 57 }, --slap 1
            { q = q(59,360,55,58), ox = 17, oy = 57, func = comboSlap }, --slap 2
            { q = q(116,360,40,58), ox = 20, oy = 57 }, --slap 3
            delay = 0.067
        },
        combo3 = {
            { q = q(116,360,40,58), ox = 20, oy = 57 }, --slap 3
            { q = q(59,360,55,58), ox = 17, oy = 57, func = comboSlap }, --slap 2
            { q = q(2,360,55,58), ox = 35, oy = 57 }, --slap 1
            delay = 0.067
        },
        combo4 = {
            { q = q(42,297,43,57), ox = 25, oy = 56 }, --jump attack 1
            { q = q(87,297,66,53), ox = 32, oy = 52, funcCont = comboKick, delay = 0.167 }, --jump attack 2
            { q = q(42,297,43,57), ox = 25, oy = 56, delay = 0.117 }, --jump attack 1
            delay = 0.067
        },
        hurtHighWeak = {
            { q = q(2,124,43,60), ox = 25, oy = 59 }, --hurt high 1
            { q = q(47,125,48,59), ox = 29, oy = 58, delay = 0.2 }, --hurt high 2
            { q = q(2,124,43,60), ox = 25, oy = 59, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtHighMedium = {
            { q = q(2,124,43,60), ox = 25, oy = 59 }, --hurt high 1
            { q = q(47,125,48,59), ox = 29, oy = 58, delay = 0.33 }, --hurt high 2
            { q = q(2,124,43,60), ox = 25, oy = 59, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtHighStrong = {
            { q = q(2,124,43,60), ox = 25, oy = 59 }, --hurt high 1
            { q = q(47,125,48,59), ox = 29, oy = 58, delay = 0.47 }, --hurt high 2
            { q = q(2,124,43,60), ox = 25, oy = 59, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtLowWeak = {
            { q = q(2,186,36,58), ox = 21, oy = 57 }, --hurt low 1
            { q = q(40,188,39,56), ox = 21, oy = 55, delay = 0.2 }, --hurt low 2
            { q = q(2,186,36,58), ox = 21, oy = 57, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        hurtLowMedium = {
            { q = q(2,186,36,58), ox = 21, oy = 57 }, --hurt low 1
            { q = q(40,188,39,56), ox = 21, oy = 55, delay = 0.33 }, --hurt low 2
            { q = q(2,186,36,58), ox = 21, oy = 57, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        hurtLowStrong = {
            { q = q(2,186,36,58), ox = 21, oy = 57 }, --hurt low 1
            { q = q(40,188,39,56), ox = 21, oy = 55, delay = 0.47 }, --hurt low 2
            { q = q(2,186,36,58), ox = 21, oy = 57, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        fall = {
            { q = q(127,7,54,54), ox = 33, oy = 53, delay = 0.33 }, --fall 1
            { q = q(2,249,63,46), ox = 38, oy = 45, delay = 0.13 }, --fall 2
            { q = q(123,215,64,29), ox = 40, oy = 28 }, --fall 3
            delay = math.huge
        },
        fallBounce = {
            { q = q(67,266,66,29), ox = 41, oy = 27, delay = 0.06 }, --fallen
            { q = q(123,215,64,29), ox = 40, oy = 28 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(67,266,66,29), ox = 41, oy = 27 }, --fallen
            delay = math.huge
        },
        getUp = {
            { q = q(67,266,66,29), ox = 41, oy = 27, delay = 0.4 }, --fallen
            { q = q(135,249,53,46), ox = 30, oy = 45 }, --get up
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 0.22
        },
        grabbedFront = {
            { q = q(2,124,43,60), ox = 25, oy = 59 }, --hurt high 1
            { q = q(47,125,48,59), ox = 29, oy = 58 }, --hurt high 2
            delay = 0.02
        },
        grabbedBack = {
            { q = q(2,186,36,58), ox = 21, oy = 57 }, --hurt low 1
            { q = q(40,188,39,56), ox = 21, oy = 55 }, --hurt low 2
            delay = 0.02
        },
        grabbedFrames = {
            --default order should be kept: hurtLow2, hurtHigh2, \, /, upsideDown, fallen
            { q = q(40,188,39,56), ox = 21, oy = 55 }, --hurt low 2
            { q = q(47,125,48,59), ox = 29, oy = 58 }, --hurt high 2
            { q = q(127,7,54,54), ox = 33, oy = 53 }, --fall 1
            { q = q(127,7,54,54), ox = 33, oy = 53, rotate = -1.57, rx = 33, ry = -26 }, --fall 1 (rotated -90°)
            { q = q(40,188,39,56), ox = 21, oy = 55, flipV = -1 }, --hurt low 2
            { q = q(67,266,66,29), ox = 41, oy = 27 }, --fallen
            delay = math.huge
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(127,7,54,54), ox = 33, oy = 53, rotate = -1.57, rx = 16, ry = -26, delay = 0.4 }, --fall 1 (rotated -90°)
            { q = q(123,215,64,29), ox = 40, oy = 28 }, --fall 3
            delay = math.huge
        },
    }
}
