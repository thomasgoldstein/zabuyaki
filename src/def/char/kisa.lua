local spriteSheet = "res/img/char/kisa.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "kisa", -- The name of the sprite

    delay = 0.2, -- Default delay for all animations
    hurtBox = { width = 20, height = 50 }, -- Default hurtBox for all animations

    animations = {
        icon = {
            { q = q(2, 11, 37, 17) },
            delay = math.huge
        },
        intro = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        stand = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            { q = q(42,2,39,58), ox = 24, oy = 57 }, --stand 2
            { q = q(83,3,40,57), ox = 25, oy = 56, delay = 0.25 }, --stand 3
            { q = q(42,2,39,58), ox = 24, oy = 57 }, --stand 2
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            { q = q(125,3,39,57), ox = 23, oy = 56, delay = 0.25 },
            loop = true,
            delay = 0.16
        },
        walk = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            loop = true,
            delay = 0.167
        },
        run = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            loop = true,
            delay = 0.117
        },
        duck = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.06
        },
        sideStepUp = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        sideStepDown = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        jump = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        jumpAttackStraight = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        jumpAttackForward = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        jumpAttackRun = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        jumpAttackLight = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        dropDown = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        respawn = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            { q = q(2,2,38,58), ox = 23, oy = 57, delay = 0.5 }, --stand 1
            { q = q(2,2,38,58), ox = 23, oy = 57, delay = 0.1 }, --stand 1 (need 3 frames)
            delay = math.huge
        },
        pickUp = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.05
        },
        combo1 = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.01
        },
        combo2 = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.04
        },
        combo3 = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.06
        },
        combo4 = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.06
        },
        dashAttack = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.16
        },
        grab = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        grabSwap = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
        },
        grabFrontAttack1 = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.05
        },
        grabFrontAttackForward = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.1
        },
        grabFrontAttackDown = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.1
        },
        hurtHighWeak = {
            { q = q(2,2,38,60), ox = 22, oy = 58 }, --stand 1
            delay = 0.02
        },
        hurtHighMedium = {
            { q = q(2,2,38,60), ox = 22, oy = 58 }, --stand 1
            delay = 0.02
        },
        hurtHighStrong = {
            { q = q(2,2,38,60), ox = 22, oy = 58 }, --stand 1
            delay = 0.02
        },
        hurtLowWeak = {
            { q = q(2,2,38,60), ox = 24, oy = 58 }, --stand 1
            delay = 0.02
        },
        hurtLowMedium = {
            { q = q(2,2,38,60), ox = 24, oy = 58 }, --stand 1
            delay = 0.02
        },
        hurtLowStrong = {
            { q = q(2,2,38,60), ox = 24, oy = 58 }, --stand 1
            delay = 0.02
        },
        fall = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        fallBounce = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        fallenDead = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
        getUp = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.2
        },
        grabbedFront = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.02
        },
        grabbedBack = {
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = 0.02
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(2,2,38,58), ox = 23, oy = 57 }, --stand 1
            delay = math.huge
        },
    }
}
