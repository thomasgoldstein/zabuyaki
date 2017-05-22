local sprite_sheet = "res/img/char/satoff.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local combo_uppercut1 = function(slf, cont) slf:checkAndAttack(
	{ left = 14, width = 30, height = 12, damage = 12, type = "low", velocity = slf.velocity_dash_fall, sfx = "whoosh_heavy" },
	cont
) end

local combo_uppercut2 = function(slf, cont) slf:checkAndAttack(
	{ left = 20, width = 30, height = 12, damage = 16, type = "fall", velocity = slf.velocity_dash_fall },
	cont
) end

local jump_attack = function(slf, cont)
    slf:checkAndAttack(
        { left = 4, width = 48, height = 12, damage = 28, type = "fall", velocity = slf.velx },
        cont
    )
end

local grab_attack = function(slf, cont)
	slf:checkAndAttack(
        { left = 19, width = 26, height = 12, damage = 12, type = "high" },
		cont
	)
end

local grab_attack_last = function(slf, cont)
	slf:checkAndAttack(
        { left = 19, width = 26, height = 12, damage = 18, type = "grabKO" },
		cont
	)
end

local shove_now = function(slf, cont) slf.can_shove_now = true end

return {
    serialization_version = 0.42, -- version
    sprite_sheet = sprite_sheet, -- path to spritesheet
    sprite_name = "satoff", -- sprite name
    delay = 0.2,	--default delay for all animations
    animations = {
        icon  = {
            { q = q(20, 9, 38, 17) } -- default 38x17
        },
        intro = {
            { q = q(2,2,68,68), ox = 36, oy = 67 }, --stand 1
            { q = q(142,4,67,66), ox = 36, oy = 65 }, --stand 3
            loop = true,
            delay = 1
        },
        stand = {
            { q = q(2,2,68,68), ox = 36, oy = 67,
                wx = -10, wy = -33, wRotate = -0.5, wAnimation = 'angle0_equipped' }, --stand 1
            { q = q(72,3,68,67), ox = 36, oy = 66,
                wx = -10, wy = -32, wRotate = -0.45, wAnimation = 'angle0_equipped' }, --stand 2
            { q = q(142,4,67,66), ox = 36, oy = 65,
                wx = -10, wy = -31, wRotate = -0.4, wAnimation = 'angle0_equipped' }, --stand 3
            { q = q(72,3,68,67), ox = 36, oy = 66,
                wx = -10, wy = -32, wRotate = -0.55, wAnimation = 'angle0_equipped' }, --stand 2
            loop = true,
            delay = 0.15
        },
        standHold = {
            { q = q(2,663,66,66), ox = 29, oy = 65 }, --stand hold 1
            { q = q(70,663,66,66), ox = 29, oy = 65 }, --stand hold 2
            { q = q(138,664,66,65), ox = 29, oy = 64 }, --stand hold 3
            { q = q(70,663,66,66), ox = 29, oy = 65 }, --stand hold 2
            loop = true,
            delay = 0.15
        },
        walk = {
            { q = q(2,72,74,68), ox = 36, oy = 67,
                wx = -6, wy = -33, wRotate = 0, wAnimation = 'angle0_equipped' }, --walk 1
            { q = q(78,72,73,68), ox = 36, oy = 67, delay = 0.15,
                wx = -9, wy = -32, wRotate = 0, wAnimation = 'angle0_equipped' }, --walk 2
            { q = q(153,73,71,67), ox = 36, oy = 66,
                wx = -10, wy = -30, wRotate = 0, wAnimation = 'angle0_equipped' }, --walk 3
            { q = q(226,72,73,68), ox = 36, oy = 67, delay = 0.15,
                wx = -9, wy = -32, wRotate = 0, wAnimation = 'angle0_equipped' }, --walk 4
            loop = true,
            delay = 0.183
        },
        walkHold = {
            { q = q(2,731,66,66), ox = 29, oy = 65 }, --walk hold 1
            { q = q(70,731,66,66), ox = 29, oy = 65, delay = 0.15 }, --walk hold 2
            { q = q(138,732,66,65), ox = 29, oy = 64 }, --walk hold 3
            { q = q(70,731,66,66), ox = 29, oy = 65, delay = 0.15 }, --walk hold 2
            loop = true,
            delay = 0.183
        },
        run = {
            { q = q(2,421,55,70), ox = 35, oy = 69 }, --jump
            { q = q(59,417,60,74), ox = 34, oy = 73 }, --jump attack forward 1 (lowered)
            { q = q(121,424,58,58), ox = 31, oy = 59 }, --jump attack forward 2 (lowered)
			{ q = q(2,809,56,43), ox = 33, oy = 40, funcCont = jump_attack }, --run 1
			{ q = q(60,806,50,46), ox = 32, oy = 43, funcCont = jump_attack }, --run 2
			{ q = q(112,809,53,43), ox = 32, oy = 40, funcCont = jump_attack }, --run 3
			{ q = q(167,799,52,53), ox = 31, oy = 50, funcCont = jump_attack }, --run 4
            loop = true,
			loopFrom = 4,
            delay = 0.1
        },
        jump = {
            { q = q(2,421,55,70), ox = 35, oy = 69 }, --jump
            delay = 5
        },
        respawn = {
            { q = q(2,421,55,70), ox = 35, oy = 69, delay = 5 }, --jump
            { q = q(206,736,66,61), ox = 33, oy = 60, delay = 0.5 }, --pickup
            { q = q(206,665,69,64), ox = 37, oy = 63 }, --duck
            delay = 0.1
        },
        duck = {
            { q = q(206,665,69,64), ox = 37, oy = 63 }, --duck
            delay = 0.06
        },
        pickup = {
            { q = q(206,665,69,64), ox = 37, oy = 63, delay = 0.03 }, --duck
            { q = q(206,736,66,61), ox = 33, oy = 60, delay = 0.2 }, --pickup
            { q = q(206,665,69,64), ox = 37, oy = 63 }, --duck
            delay = 0.05
        },
        combo1 = {
            { q = q(2,350,64,65), ox = 33, oy = 64 }, --uppercut 1
			{ q = q(68,350,51,65), ox = 23, oy = 64, func = combo_uppercut1, delay = 0.06 }, --uppercut 2
			{ q = q(121,343,60,72), ox = 25, oy = 71, func = combo_uppercut2, delay = 0.33 }, --uppercut 3
			{ q = q(68,350,51,65), ox = 23, oy = 64, delay = 0.13 }, --uppercut 2
            delay = 0.16
        },
        batAttack = {
            { q = q(1,526,56,67), ox = 31, oy = 66 }, --bat attack 1
            { q = q(59,528,95,65), ox = 24, oy = 64, delay = 0.11 }, --bat attack 2
            { q = q(156,493,86,100), ox = 25, oy = 99, delay = 0.05 }, --bat attack 3
            { q = q(244,522,50,71), ox = 25, oy = 70 }, --bat attack 4
            delay = 0.25
        },
        fall = {
            { q = q(2,284,71,57), ox = 36, oy = 56 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,284,71,57), ox = 36, oy = 56, rotate = -1.57, rx = 29, ry = -30 }, --falling
            delay = 5
        },
        getup = {
            { q = q(75,304,79,37), ox = 49, oy = 34 }, --lying down
            { q = q(156,282,69,59), ox = 36, oy = 56 }, --getting up
            { q = q(206,736,66,61), ox = 33, oy = 60 }, --pickup
            { q = q(206,665,69,64), ox = 37, oy = 63 }, --duck
            delay = 0.2
        },
        fallen = {
            { q = q(75,304,79,37), ox = 49, oy = 34 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,142,68,68), ox = 37, oy = 67, delay = 0.03 }, --hurt high 1
            { q = q(72,142,69,68), ox = 39, oy = 67 }, --hurt high 2
            { q = q(2,142,68,68), ox = 37, oy = 67, delay = 0.1 }, --hurt high 1
            delay = 0.3
        },
        hurtLow = {
            { q = q(143,143,69,67), ox = 36, oy = 66, delay = 0.03 }, --hurt low 1
            { q = q(214,146,72,64), ox = 36, oy = 63 }, --hurt low 2
            { q = q(143,143,69,67), ox = 36, oy = 66, delay = 0.1 }, --hurt low 1
            delay = 0.3
        },
        jumpAttackForward = {
            { q = q(59,417,60,74), ox = 34, oy = 75 }, --jump attack forward 1
            { q = q(121,424,58,58), ox = 31, oy = 68, funcCont = jump_attack, delay = 5 }, --jump attack forward 2
            delay = 0.12
        },
        jumpAttackStraight = {
            { q = q(59,417,60,74), ox = 34, oy = 75 }, --jump attack forward 1
            { q = q(121,424,58,58), ox = 31, oy = 68, funcCont = jump_attack, delay = 5 }, --jump attack forward 2
            delay = 0.12
        },
        jumpAttackRun = {
            { q = q(59,417,60,74), ox = 34, oy = 75 }, --jump attack forward 1
            { q = q(121,424,58,58), ox = 31, oy = 68, funcCont = jump_attack, delay = 5 }, --jump attack forward 2
            delay = 0.12
        },
        grab = {
            { q = q(68,350,51,65), ox = 23, oy = 64 }, --uppercut 2
        },
        grabAttack1 = {
            { q = q(2,595,60,66), ox = 29, oy = 65 }, --grab attack 1
            { q = q(133,600,59,61), ox = 27, oy = 60, func = grab_attack, delay = 0.18 }, --grab attack 3
            { q = q(68,350,51,65), ox = 23, oy = 64, delay = 0.07 }, --uppercut 2
            delay = 0.1
        },
        grabAttack2 = {
            { q = q(2,595,60,66), ox = 29, oy = 65 }, --grab attack 1
            { q = q(64,595,67,66), ox = 36, oy = 65, delay = 0.16 }, --grab attack 2
            { q = q(133,600,59,61), ox = 27, oy = 60, func = grab_attack_last, delay = 0.25 }, --grab attack 3
            delay = 0.03
        },
        shoveDown = {
            { q = q(2,595,60,66), ox = 29, oy = 65 }, --grab attack 1
            { q = q(64,595,67,66), ox = 36, oy = 65, delay = 0.16 }, --grab attack 2
            { q = q(133,600,59,61), ox = 27, oy = 60, func = grab_attack_last, delay = 0.25 }, --grab attack 3
            delay = 0.03
        },
        shoveBack = {
            { q = q(1,526,56,67), ox = 31, oy = 66 }, --bat attack 1
            { q = q(194,599,70,62), ox = 36, oy = 61, func = shove_now, delay = 0.5 }, --throw
            { q = q(68,350,51,65), ox = 23, oy = 64 }, --uppercut 2
            delay = 0.2
        },
        grabbedFront = {
            { q = q(2,212,68,68), ox = 37, oy = 67 }, --grabbed front 1
            { q = q(72,212,69,68), ox = 39, oy = 67 }, --grabbed front 2
            delay = 0.1
        },
        grabbedBack = {
            { q = q(143,213,69,67), ox = 36, oy = 66 }, --grabbed back 1
            { q = q(214,216,72,64), ox = 36, oy = 63 }, --grabbed back 2
            delay = 0.1
        },
    }
}
