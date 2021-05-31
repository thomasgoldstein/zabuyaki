local spriteSheet = "res/img/char/drvolker.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local function f(n)
    return (n / 60) - ((n / 60) % 0.001) -- converts frames -> seconds. Usage: delay = f(4)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "drvolker", -- The name of the sprite

    delay = f(12), -- Default delay for all animations
    hurtBox = { width = 20, height = 50 }, -- Default hurtBox for all animations

    animations = {
        icon = {
            { q = q(6, 14, 37, 17) },
            delay = math.huge
        },
        stand = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            loop = true,
            delay = f(10)
        },
        walk = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            loop = true,
            delay = f(10)
        },
        run = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            loop = true,
            delay = f(10)
        },
        squat = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(4)
        },
        land = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(4)
        },
        sideStepUp = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        sideStepDown = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        jump = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        jumpAttackStraight = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        jumpAttackForward = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        jumpAttackRun = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        jumpAttackLight = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        dropDown = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
        },
        respawn = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            { q = q(2,2,60,74), ox = 30, oy = 73, delay = f(36) }, --stand 1 (need 2 frames)
            delay = math.huge
        },
        pickUp = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(3)
        },
        combo1 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(1)
        },
        combo2 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(1)
        },
        combo3 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(1)
        },
        combo4 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(1)
        },
        dashAttack = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(10)
        },
        grab = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        grabSwap = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
        },
        grabFrontAttack1 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(3)
        },
        grabFrontAttackForward = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(6)
        },
        grabFrontAttackDown = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(6)
        },
        hurtHighWeak = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(1)
        },
        hurtHighMedium = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(1)
        },
        hurtHighStrong = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(1)
        },
        hurtLowWeak = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(1)
        },
        hurtLowMedium = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(1)
        },
        hurtLowStrong = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(1)
        },
        fall = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            loop = true,
            delay = f(8)
        },
        fallTwistStrong = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            loop = true,
            delay = f(7)
        },
        fallBounce = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        fallOnHead = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(5)
        },
        fallenDead = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        getUp = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = f(12)
        },
        grabbedFront = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1 (need 2 frames)
            delay = f(2)
        },
        grabbedBack = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1 (need 2 frames)
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        thrown12h = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        thrown10h = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        thrown8h = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
        thrown6h = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --stand 1
            delay = math.huge
        },
    }
}
