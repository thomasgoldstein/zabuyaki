local sprite_sheet = "res/img/char/zeena.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end
local combo_slap = function(slf, cont)
    slf:checkAndAttack(
        { left = 25, width = 26, height = 12, damage = 5, type = "high", velocity = slf.velx, sfx = "air" },
        cont
    )
    slf.cool_down_combo = 0.4
end
local combo_kick = function(slf, cont)
    slf:checkAndAttack(
        { left = 21, width = 25, height = 12, damage = 8, type = "fall", velocity = slf.velocity_dash_fall },
        cont
    )
    -- move forward Zeena
    if slf.b.vertical:getValue() ~= 0 then
        slf.vertical = slf.b.vertical:getValue()
        slf.vely = slf.velocity_jab_y -- vertical velocity
        slf.velx = slf.velocity_jab_y -- reduced horizontal velocity
    else
        slf.velx = slf.velocity_jab -- horizontal velocity
    end
    slf.cool_down_combo = 0.4
end
local jump_attack = function(slf, cont)
    slf:checkAndAttack(
        { left = 21, width = 25, height = 12, damage = 13, type = "fall", velocity = slf.velocity_dash_fall },
        cont
) end

return {
    serialization_version = 0.42, -- The version of this serialization process

    sprite_sheet = sprite_sheet, -- The path to the spritesheet
    sprite_name = "zeena", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon  = {
            { q = q(6, 12, 31, 17) }
        },
        intro = {
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 5
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
        run = {
            { q = q(2,2,39,59), ox = 22, oy = 58 }, --stand 1
            { q = q(2,2,39,59), ox = 22, oy = 58 }, --stand 1
            { q = q(2,2,39,59), ox = 22, oy = 58 }, --stand 1
            loop = true,
            delay = 0.08
        },
        jump = {
            { q = q(2,297,38,61), ox = 22, oy = 60 }, --jump
            delay = 5
        },
        respawn = {
            { q = q(2,297,38,61), ox = 22, oy = 60, delay = 5 }, --jump
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 0.6
        },
        duck = {
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 0.06
        },
        pickup = {
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 0.28
        },
        dashAttack = {
            { q = q(2,2,39,59), ox = 22, oy = 58 }, --stand 1
            delay = 0.3
        },
        combo1 = {
            { q = q(115,360,40,58), ox = 20, oy = 57 }, --slap 3
            { q = q(59,360,55,58), ox = 17, oy = 57, func = combo_slap }, --slap 2
            { q = q(2,360,55,58), ox = 35, oy = 57 }, --slap 1
            delay = 0.067
        },
        combo2 = {
            { q = q(2,360,55,58), ox = 35, oy = 57 }, --slap 1
            { q = q(59,360,55,58), ox = 17, oy = 57, func = combo_slap }, --slap 2
            { q = q(115,360,40,58), ox = 20, oy = 57 }, --slap 3
            delay = 0.067
        },
        combo3 = {
            { q = q(115,360,40,58), ox = 20, oy = 57 }, --slap 3
            { q = q(59,360,55,58), ox = 17, oy = 57, func = combo_slap }, --slap 2
            { q = q(2,360,55,58), ox = 35, oy = 57 }, --slap 1
            delay = 0.067
        },
        combo4 = {
            { q = q(42,297,38,56), ox = 20, oy = 55 }, --jump attack 1
            { q = q(82,297,56,52), ox = 22, oy = 51, funcCont = combo_kick, delay = 0.167 }, --jump attack 2
            { q = q(42,297,38,56), ox = 20, oy = 55, delay = 0.117 }, --jump attack 1
            delay = 0.067
        },
        fall = {
            { q = q(2,246,65,49), ox = 39, oy = 48 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,246,65,49), ox = 39, oy = 48, rotate = -1.57, rx = 29, ry = -30 }, --falling
            delay = 5
        },
        getup = {
            { q = q(69,267,67,28), ox = 41, oy = 27, delay = 0.2 }, --lying down
            { q = q(138,249,53,46), ox = 30, oy = 45 }, --getting up
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 0.3
        },
        fallen = {
            { q = q(69,267,67,28), ox = 41, oy = 27 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,124,43,60), ox = 25, oy = 59, delay = 0.03 }, --hurt high 1
            { q = q(47,125,48,59), ox = 29, oy = 58 }, --hurt high 2
            { q = q(2,124,43,60), ox = 25, oy = 59, delay = 0.1 }, --hurt high 1
            delay = 0.3
        },
        hurtLow = {
            { q = q(2,186,36,58), ox = 21, oy = 57, delay = 0.03 }, --hurt low 1
            { q = q(40,188,39,56), ox = 21, oy = 55 }, --hurt low 2
            { q = q(2,186,36,58), ox = 21, oy = 57, delay = 0.1 }, --hurt low 1
            delay = 0.3
        },
        jumpAttackForward = {
            { q = q(42,297,38,56), ox = 20, oy = 60 }, --jump attack 1
            { q = q(82,297,56,52), ox = 22, oy = 60, funcCont = jump_attack, delay = 5 }, --jump attack 2
            delay = 0.06
        },
		jumpAttackForwardEnd = {
            { q = q(42,297,38,56), ox = 20, oy = 60 }, --jump attack 1
			delay = 5
		},
		jumpAttackLightEnd = {
            { q = q(42,297,38,56), ox = 20, oy = 60 }, --jump attack 1
			delay = 5
		},
        jumpAttackStraight = {
            { q = q(42,297,38,56), ox = 20, oy = 60 }, --jump attack 1
            { q = q(82,297,56,52), ox = 22, oy = 60, funcCont = jump_attack, delay = 5 }, --jump attack 2
            delay = 0.06
        },
		jumpAttackStraightEnd = {
            { q = q(42,297,38,56), ox = 20, oy = 60 }, --jump attack 1
			delay = 5
		},
        sideStepUp = {
            { q = q(2,297,38,61), ox = 22, oy = 60 }, --jump
        },
        sideStepDown = {
            { q = q(2,297,38,61), ox = 22, oy = 60 }, --jump
        },
        grabbed = {
            { q = q(2,124,43,60), ox = 25, oy = 59 }, --hurt high 1
            { q = q(47,125,48,59), ox = 29, oy = 58 }, --hurt high 2
            delay = 0.1
        },

    } --offsets

} --return (end of file)