local spriteSheet = "res/img/char/sveta.png"
local image_w,image_h = LoadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end
local combo_slap = function(slf, cont)
    slf:checkAndAttack(
        { left = 25, width = 26, height = 12, damage = 5, type = "high", velocity = slf.velx, sfx = "air" },
        cont
    )
    slf.cooldownCombo = 0.4
end
local combo_kick = function(slf, cont)
    slf:checkAndAttack(
        { left = 25, width = 26, height = 12, damage = 10, type = "fall", velocity = slf.velocityDashFall },
        cont
) end
local dashAttack = function(slf, cont)
    slf:checkAndAttack(
        { left = 21, width = 25, height = 12, damage = 14, type = "fall", velocity = slf.velocityDashFall },
        cont
) end

return {
    serialization_version = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    sprite_name = "sveta", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon  = {
            { q = q(11, 17, 31, 17) }
        },
        intro = {
            { q = q(147,209,48,56), ox = 30, oy = 55 }, --duck
            delay = 5
        },
        stand = {
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
            { q = q(48,3,46,63), ox = 29, oy = 62, delay = 0.18 }, --stand 2
            { q = q(96,4,47,62), ox = 30, oy = 61 }, --stand 3
            { q = q(48,3,46,63), ox = 29, oy = 62, delay = 0.16 }, --stand 2
            loop = true,
            delay = 0.2
        },
        walk = {
            { q = q(2,68,44,63), ox = 27, oy = 63, delay = 0.16 }, --walk 1
            { q = q(48,69,46,63), ox = 29, oy = 62 }, --walk 2
            { q = q(96,68,47,64), ox = 30, oy = 63, delay = 0.16 }, --walk 3
            { q = q(48,3,46,63), ox = 29, oy = 62 }, --stand 2
            loop = true,
            delay = 0.2
        },
        run = {
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
            loop = true,
            delay = 0.08
        },
        respawn = {
            { q = q(2,323,38,67), ox = 23, oy = 66, delay = 5 }, --jump
            { q = q(147,209,48,56), ox = 30, oy = 55 }, --duck
            delay = 0.6
        },
        duck = {
            { q = q(147,209,48,56), ox = 30, oy = 55 }, --duck
            delay = 0.06
        },
        pickup = {
            { q = q(147,209,48,56), ox = 30, oy = 55 }, --duck
            delay = 0.28
        },
        dashAttack = {
            { q = q(42,323,52,63), ox = 34, oy = 62 }, --dash attack 1
            { q = q(96,323,71,60), ox = 37, oy = 59, funcCont = dashAttack, delay = 0.5 }, --dash attack 2
            { q = q(42,323,52,63), ox = 34, oy = 62 }, --dash attack 1
            delay = 0.06
        },
        combo1 = {
            { q = q(2,392,55,64), ox = 35, oy = 63 }, --slap 1
            { q = q(59,392,72,64), ox = 34, oy = 63, func = combo_slap }, --slap 2
            { q = q(133,392,51,64), ox = 31, oy = 63 }, --slap 3
            delay = 0.067
        },
        combo2 = {
            { q = q(133,392,51,64), ox = 31, oy = 63 }, --slap 3
            { q = q(59,392,72,64), ox = 34, oy = 63, func = combo_slap }, --slap 2
            { q = q(2,392,55,64), ox = 35, oy = 63 }, --slap 1
            delay = 0.067
        },
        combo3 = {
            { q = q(2,392,55,64), ox = 35, oy = 63 }, --slap 1
            { q = q(59,392,72,64), ox = 34, oy = 63, func = combo_slap }, --slap 2
            { q = q(133,392,51,64), ox = 31, oy = 63 }, --slap 3
            delay = 0.067
        },
        combo4 = {
            { q = q(2,458,51,61), ox = 32, oy = 60 }, --high kick 1
            { q = q(55,459,76,60), ox = 38, oy = 59, func = combo_kick, delay = 0.217 }, --high kick 2
            { q = q(2,458,51,61), ox = 32, oy = 60 }, --high kick 1
            delay = 0.117
        },
        holdAttack = {
            { q = q(2,458,51,61), ox = 32, oy = 60 }, --high kick 1
            { q = q(55,459,76,60), ox = 38, oy = 59, func = combo_kick, delay = 0.217 }, --high kick 2
            { q = q(2,458,51,61), ox = 32, oy = 60 }, --high kick 1
            delay = 0.117
        },
        fall = {
            { q = q(2,267,75,54), ox = 49, oy = 53 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,267,75,54), ox = 49, oy = 53, rotate = -1.57, rx = 29, ry = -30 }, --falling
            delay = 5
        },
        getup = {
            { q = q(79,288,96,33), ox = 70, oy = 29, delay = 0.2 }, --lying down
            { q = q(177,273,63,45), ox = 40, oy = 44 }, --getting up
            { q = q(147,209,48,56), ox = 30, oy = 55 }, --duck
            delay = 0.3
        },
        fallen = {
            { q = q(79,288,96,33), ox = 70, oy = 29 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,134,48,62), ox = 30, oy = 61 }, --hurt high 1
            { q = q(52,138,58,58), ox = 39, oy = 57, delay = 0.2 }, --hurt high 2
            { q = q(112,134,50,62), ox = 32, oy = 61, delay = 0.05 }, --hurt high 3
            delay = 0.02
        },
        hurtLow = {
            { q = q(2,200,44,65), ox = 29, oy = 64, delay = 0.03 }, --hurt low 1
            { q = q(48,198,46,67), ox = 28, oy = 66 }, --hurt low 2
            { q = q(96,199,49,66), ox = 34, oy = 65, delay = 0.1 }, --hurt low 3
            delay = 0.3
        },
        sideStepUp = {
            { q = q(2,323,38,67), ox = 23, oy = 66 }, --jump
        },
        sideStepDown = {
            { q = q(2,323,38,67), ox = 23, oy = 66 }, --jump
        },
        grabbedFront = {
            { q = q(2,134,48,62), ox = 30, oy = 61 }, --hurt high 1
            { q = q(52,138,58,58), ox = 39, oy = 57 }, --hurt high 2
            delay = 0.1
        },
        grabbedBack = {
            { q = q(2,200,44,65), ox = 29, oy = 64 }, --hurt low 1
            { q = q(48,198,46,67), ox = 28, oy = 66 }, --hurt low 2
            delay = 0.1
        },
    }
}