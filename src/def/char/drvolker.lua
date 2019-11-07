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
        intro = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        stand = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            loop = true,
            delay = f(10)
        },
        walk = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            loop = true,
            delay = f(10)
        },
        run = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            loop = true,
            delay = f(10)
        },
        duck = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(4)
        },
        sideStepUp = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        sideStepDown = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        jump = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        jumpAttackStraight = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        jumpAttackForward = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        jumpAttackRun = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        jumpAttackLight = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        dropDown = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
        },
        respawn = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame (need 3 frames)
            delay = f(6)
        },
        pickUp = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(3)
        },
        combo1 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(1)
        },
        combo2 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(1)
        },
        combo3 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(1)
        },
        combo4 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(1)
        },
        dashAttack = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(10)
        },
        grab = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        grabSwap = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
        },
        grabFrontAttack1 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(3)
        },
        grabFrontAttackForward = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(6)
        },
        grabFrontAttackDown = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(6)
        },
        hurtHighWeak = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(1)
        },
        hurtHighMedium = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(1)
        },
        hurtHighStrong = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(1)
        },
        hurtLowWeak = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(1)
        },
        hurtLowMedium = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(1)
        },
        hurtLowStrong = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(1)
        },
        fall = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        fallBounce = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        fallenDead = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        getUp = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(12)
        },
        grabbedFront = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(2)
        },
        grabbedBack = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = f(2)
        },
        grabbedFrames = {
            --default order should be kept: hurt low 2, hurt high 2, fall 1 (rotated -90°), hurt low 2 (/), hurt low 2 (upsideDown), fallen, fall 3
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        thrown12h = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        thrown10h = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        thrown8h = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        thrown6h = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
    }
}
