local image_w = 196 --This info can be accessed with a Love2D call
local image_h = 308 --after the image has been loaded

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local combo_attack = function(slf)
    slf:checkAndAttack(30,0, 22,12, 7, "high", "res/sfx/attack1.wav")
    slf.cool_down = 0.8
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
			{ q = q(40,3,36,61), ox = 18, oy = 60 }, --stand 2
			{ q = q(78,4,36,60), ox = 18, oy = 59 }, --stand 3
			{ q = q(40,3,36,61), ox = 18, oy = 60 }, --stand 2
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
        combo1 = {
            { q = q(2,130,62,61), ox = 18, oy = 60, func = combo_attack }, --punch
            delay = 0.2
        },
        fall = {
			{ q = q(2,263,67,43), ox = 33, oy = 42, delay = 0.8 }, --falling
            { q = q(71,264,65,42), ox = 32, oy = 29, delay = 3 }, --lying down
			{ q = q(138,257,56,49), ox = 25, oy = 48 }, --getting up
            delay = 0.2
        },
        getup = {
            { q = q(71,264,65,42), ox = 32, oy = 29, delay = 1 }, --lying down
			{ q = q(138,257,56,49), ox = 25, oy = 48 }, --getting up
            delay = 0.2
        },
        dead = {
			{ q = q(138,257,56,49), ox = 25, oy = 48, delay = 1 }, --getting up
            { q = q(71,264,65,42), ox = 32, oy = 29 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,193,39,62), ox = 21, oy = 61, delay = 0.03 }, --hh1
			{ q = q(43,193,44,62), ox = 26, oy = 61 }, --hh2
            { q = q(2,193,39,62), ox = 21, oy = 61, delay = 0.1 }, --hh1
            delay = 0.3
        },
        hurtLow = {
            { q = q(89,194,37,61), ox = 19, oy = 60 , delay = 0.03 }, --hl1
			{ q = q(128,196,42,59), ox = 20, oy = 58 }, --hl2
            { q = q(89,194,37,61), ox = 19, oy = 60 , delay = 0.1 }, --hl1
            delay = 0.3
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
            { q = q(43,193,44,62), ox = 26, oy = 61 }, --hh2
            delay = 0.1
        },

    } --offsets

} --return (end of file)
