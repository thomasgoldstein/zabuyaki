local image_w = 194 --This info can be accessed with a Love2D call
local image_h = 263 --after the image has been loaded

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local combo_attack = function(slf)
    slf:checkAndAttack(28,0, 26,12, 7, "high", slf.velx, "air")
    slf.cool_down = 0.8
end

return {
    serialization_version = 0.42, -- The version of this serialization process

    sprite_sheet = "res/img/char/niko.png", -- The path to the spritesheet
    --TODO read width/height of the sheet automatically.
    sprite_name = "niko", -- The name of the sprite

    delay = 0.20,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon  = {
            { q = q(68, 88, 32, 24) }
        },
        intro = {
            { q = q(66,73,38,58), ox = 19, oy = 57 }, --idle
            delay = 5
        },
        stand = {
            -- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = fun
            { q = q(2,2,36,64), ox = 18, oy = 63 }, --stand 1
			{ q = q(40,3,36,63), ox = 18, oy = 62 }, --stand 2
			{ q = q(78,4,36,62), ox = 18, oy = 61 }, --stand 3
			{ q = q(40,3,36,63), ox = 18, oy = 62 }, --stand 2
            loop = true,
            delay = 0.167
        },
        walk = {
			{ q = q(116,2,36,64), ox = 18, oy = 63 }, --walk 1
            { q = q(2,2,36,64), ox = 18, oy = 63 }, --stand 1
			{ q = q(154,3,38,63), ox = 18, oy = 62 }, --walk 2
            { q = q(2,2,36,64), ox = 18, oy = 63 }, --stand 1
            loop = true,
            delay = 0.167
        },
        run = {
            { q = q(116,2,36,64), ox = 18, oy = 63 }, --walk 1
            { q = q(2,2,36,64), ox = 18, oy = 63 }, --stand 1
            { q = q(154,3,38,63), ox = 18, oy = 62 }, --walk 2
            { q = q(2,2,36,64), ox = 18, oy = 63 }, --stand 1
            loop = true,
            delay = 0.1
        },
        jump = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 5
        },
        duck = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.15
        },
        pickup = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.05
        },
        dash = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.16
        },
        combo1 = {
            { q = q(2,68,62,63), ox = 18, oy = 62, func = combo_attack }, --punch
            delay = 0.2
        },
        fall = {
			{ q = q(2,199,51,62), ox = 25, oy = 61 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
			{ q = q(2,199,51,62), ox = 25, oy = 61, rotate = -1.57, rx = 30, ry = -25}, --falling
            delay = 5
        },
        getup = {
            { q = q(55,219,75,42), ox = 42, oy = 31, delay = 0.2 }, --lying down
			{ q = q(132,209,58,52), ox = 35, oy = 48 }, --getting up
			{ q = q(66,73,38,58), ox = 19, oy = 57 }, --idle
            delay = 0.3
        },
        fallen = {
            { q = q(55,219,75,42), ox = 42, oy = 31 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,133,41,64), ox = 23, oy = 63, delay = 0.03 }, --hh1
			{ q = q(45,133,46,64), ox = 28, oy = 63 }, --hh2
            { q = q(2,133,41,64), ox = 23, oy = 63, delay = 0.1 }, --hh1
            delay = 0.3
        },
        hurtLow = {
            { q = q(93,134,40,63), ox = 19, oy = 62, delay = 0.03 }, --hl1
			{ q = q(135,136,44,61), ox = 20, oy = 60 }, --hl2
            { q = q(93,134,40,63), ox = 19, oy = 62, delay = 0.1 }, --hl1
            delay = 0.3
        },
        jumpAttackForward = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 5
        },
        jumpAttackLight = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 5
        },
        jumpAttackStraight = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 5
        },
        sideStepUp = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
        },
        sideStepDown = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
        },
        grab = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
        },
        grabHit = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.05
        },
        grabHitLast = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.05
        },
        grabHitEnd = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.1
        },
        grabThrow = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
        },
        grabSwap = {
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
        },
        grabbed = {
            { q = q(2,133,41,64), ox = 23, oy = 63 }, --hh1
			{ q = q(45,133,46,64), ox = 28, oy = 63 }, --hh2
            delay = 0.1
        },

    } --offsets

} --return (end of file)
