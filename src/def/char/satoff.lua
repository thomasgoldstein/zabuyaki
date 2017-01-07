local sprite_sheet = "res/img/char/satoff.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)
local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

return {
    serialization_version = 0.42, -- version
    sprite_sheet = sprite_sheet, -- path to spritesheet
    sprite_name = "satoff", -- sprite name
    delay = 0.50,	--default delay for all animations
    animations = {
        icon  = {
            { q = q(20, 17, 38, 17) } -- default 38x17
        },
        intro = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            loop = true,
            delay = 1
        },
        stand = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 1
        },
        walk = {
            { q = q(2,74,74,68), ox = 34, oy = 67 },
            { q = q(78,74,73,68), ox = 34, oy = 67 },
            { q = q(153,75,71,67), ox = 34, oy = 66 },
            { q = q(226,74,73,68), ox = 34, oy = 67 },
            loop = true,
            delay = 0.167
        },
        run = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            loop = true,
            delay = 0.117
        },
        jump = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 5
        },
        respawn = {
            { q = q(2,4,68,68), ox = 34, oy = 67 },--stand 1
            delay = 0.1
        },
        duck = {
            { q = q(227,214,69,64), ox = 35, oy = 63 }, --duck
            delay = 0.15
        },
        pickup = {
            { q = q(227,214,69,64), ox = 35, oy = 63 }, --duck
            delay = 0.28
        },
        dash = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 0.16
        },
        combo1 = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 0.01
        },
        combo2 = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 0.04
        },
        combo3 = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 0.06
        },
        combo4 = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 0.06
        },
        fall = {
            { q = q(2,221,71,57), ox = 34, oy = 56 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,221,71,57), ox = 34, oy = 56, rotate = -1.57, rx = 29, ry = -30 }, --falling
            delay = 5
        },
        getup = {
            { q = q(75,241,79,37), ox = 47, oy = 34, delay = 0.2 }, --lying down
            { q = q(156,216,69,62), ox = 34, oy = 59 }, --getting up
            { q = q(227,214,69,64), ox = 35, oy = 63 }, --duck
            delay = 0.3
        },
        fallen = {
            { q = q(75,241,79,37), ox = 47, oy = 34 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,144,68,68), ox = 35, oy = 67, delay = 0.03 }, --hh1
            { q = q(72,144,69,68), ox = 37, oy = 67 }, --hh2
            { q = q(2,144,68,68), ox = 35, oy = 67, delay = 0.1 }, --hh1
            delay = 0.3
        },
        hurtLow = {
            { q = q(143,145,69,67), ox = 34, oy = 66, delay = 0.03 }, --hl1
            { q = q(214,148,72,64), ox = 34, oy = 63 }, --hl2
            { q = q(143,145,69,67), ox = 34, oy = 66, delay = 0.1 }, --hl1
            delay = 0.3
        },
        jumpAttackForward = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 5
        },
        jumpAttackLight = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 5
        },
        jumpAttackStraight = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 5
        },
        jumpAttackRun = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 5
        },
        sideStepUp = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
        },
        sideStepDown = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
        },
        grab = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
        },
        grabHit = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 0.05
        },
        grabHitLast = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 0.05
        },
        grabHitEnd = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 0.1
        },
        grabThrow = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 0.1
        },
        grabSwap = {
            { q = q(2,4,68,68), ox = 34, oy = 67 }, --stand 1
        },
        grabbed = {
            { q = q(72,4,68,68), ox = 35, oy = 67 }, --grabbed1
            { q = q(142,4,69,68), ox = 37, oy = 67 }, --grabbed2
            delay = 0.1
        },
    }
}
