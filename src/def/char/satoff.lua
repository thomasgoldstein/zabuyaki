local sprite_sheet = "res/img/char/satoff.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local combo_uppercut1 = function(slf, cont) slf:checkAndAttack(
	{ left = 15, width = 30, height = 12, damage = 12, type = "low", velocity = slf.velocity_dash_fall, sfx = "whoosh_heavy" },
	cont
) end

local combo_uppercut2 = function(slf, cont) slf:checkAndAttack(
	{ left = 21, width = 30, height = 12, damage = 16, type = "fall", velocity = slf.velocity_dash_fall },
	cont
) end

local jump_forward_attack = function(slf, cont)
    slf:checkAndAttack(
        { left = 5, width = 48, height = 12, damage = 28, type = "fall", velocity = slf.velx },
        cont
    )
end

local grabHit_attack = function(slf, cont)
	slf:checkAndAttackGrabbed(
		{ damage = 12, type = "high" },
		cont
	)
end

local grabLast_attack = function(slf, cont)
	slf:checkAndAttackGrabbed(
		{ left = 20, damage = 18, type = "grabKO" },
		cont
	)
end

local shove_now = function(slf, cont) slf.can_shove_now = true end

return {
    serialization_version = 0.42, -- version
    sprite_sheet = sprite_sheet, -- path to spritesheet
    sprite_name = "satoff", -- sprite name
    delay = 0.50,	--default delay for all animations
    animations = {
        icon  = {
            { q = q(20, 15, 38, 17) } -- default 38x17
        },
        intro = {
            { q = q(2,2,68,68), ox = 34, oy = 67 }, --stand 1
            { q = q(142,4,67,66), ox = 34, oy = 65 }, --stand 3
            loop = true,
            delay = 1
        },
        stand = {
            { q = q(2,2,68,68), ox = 34, oy = 67,
                wx = -10, wy = -33, wRotate = -0.5, wAnimation = 'angle0_equipped' }, --stand 1
            { q = q(72,3,68,67), ox = 34, oy = 66,
                wx = -10, wy = -32, wRotate = -0.45, wAnimation = 'angle0_equipped' }, --stand 2
            { q = q(142,4,67,66), ox = 34, oy = 65,
                wx = -10, wy = -31, wRotate = -0.4, wAnimation = 'angle0_equipped' }, --stand 3
            { q = q(72,3,68,67), ox = 34, oy = 66,
                wx = -10, wy = -32, wRotate = -0.55, wAnimation = 'angle0_equipped' }, --stand 2
            loop = true,
            delay = 0.15
        },
        standHold = {
            { q = q(2,598,66,66), ox = 27, oy = 65 }, --standHold 1
            { q = q(70,598,66,66), ox = 27, oy = 65 }, --standHold 2
            { q = q(138,599,66,65), ox = 27, oy = 64 }, --standHold 3
            { q = q(70,598,66,66), ox = 27, oy = 65 }, --standHold 2
            loop = true,
            delay = 0.15
        },
        walk = {
            { q = q(2,72,74,68), ox = 34, oy = 67,
                wx = -6, wy = -33, wRotate = 0, wAnimation = 'angle0_equipped' }, --walk 1
            { q = q(78,72,73,68), ox = 34, oy = 67,
                wx = -9, wy = -32, wRotate = 0, wAnimation = 'angle0_equipped' }, --walk 2
            { q = q(153,73,71,67), ox = 34, oy = 66,
                wx = -10, wy = -30, wRotate = 0, wAnimation = 'angle0_equipped' }, --walk 3
            { q = q(226,72,73,68), ox = 34, oy = 67,
                wx = -9, wy = -32, wRotate = 0, wAnimation = 'angle0_equipped' }, --walk 4
            loop = true,
            delay = 0.15
        },
        walkHold = {
            { q = q(2,666,66,66), ox = 27, oy = 65 }, --walkHold 1
            { q = q(70,666,66,66), ox = 27, oy = 65 }, --walkHold 2
            { q = q(138,667,66,65), ox = 27, oy = 64 }, --walkHold 3
            { q = q(70,666,66,66), ox = 27, oy = 65 }, --walkHold 2
            loop = true,
            delay = 0.15
        },
        run = {
            { q = q(2,356,55,70), ox = 33, oy = 69 }, --jump
            { q = q(59,352,60,74), ox = 32, oy = 73 }, --jaf1 (lowered)
            { q = q(121,359,58,58), ox = 29, oy = 59 }, --jaf2 (lowered)
			{ q = q(2,744,56,43), ox = 31, oy = 40, funcCont = jump_forward_attack }, --run 1
			{ q = q(60,741,50,46), ox = 30, oy = 43, funcCont = jump_forward_attack }, --run 2
			{ q = q(112,744,53,43), ox = 30, oy = 40, funcCont = jump_forward_attack }, --run 3
			{ q = q(167,734,52,53), ox = 29, oy = 50, funcCont = jump_forward_attack }, --run 4
            loop = true,
			loopFrom = 4,
            delay = 0.1
        },
        jump = {
            { q = q(2,356,55,70), ox = 33, oy = 69 }, --jump
            delay = 5
        },
        respawn = {
            { q = q(2,356,55,70), ox = 33, oy = 69, delay = 5 }, --jump
            { q = q(206,671,66,61), ox = 31, oy = 60, delay = 0.5 }, --pickup
            { q = q(206,600,69,64), ox = 35, oy = 63 }, --duck
            delay = 0.1
        },
        duck = {
            { q = q(206,600,69,64), ox = 35, oy = 63 }, --duck
            delay = 0.15
        },
        pickup = {
            { q = q(206,600,69,64), ox = 35, oy = 63, delay = 0.03 }, --duck
            { q = q(206,671,66,61), ox = 31, oy = 60, delay = 0.2 }, --pickup
            { q = q(206,600,69,64), ox = 35, oy = 63 }, --duck
            delay = 0.05
        },
        dash = {
            { q = q(2,2,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 0.16
        },
        combo1 = {
            { q = q(2,285,64,65), ox = 31, oy = 64 }, --c1.1
			{ q = q(68,285,51,65), ox = 21, oy = 64, func = combo_uppercut1, delay = 0.06 }, --c1.2
			{ q = q(121,278,60,72), ox = 23, oy = 71, func = combo_uppercut2, delay = 0.33 }, --c1.3
			{ q = q(68,285,51,65), ox = 21, oy = 64, delay = 0.13 }, --c1.2
            delay = 0.16
        },
        batAttack = {
            { q = q(2,461,55,67), ox = 29, oy = 66 }, --bat attack 1
            { q = q(59,463,95,65), ox = 22, oy = 64, delay = 0.11 }, --bat attack 2
            { q = q(156,428,86,100), ox = 23, oy = 99, delay = 0.05 }, --bat attack 3
            { q = q(244,457,50,71), ox = 23, oy = 70 }, --bat attack 4
            delay = 0.25
        },
        fall = {
            { q = q(2,219,71,57), ox = 34, oy = 56 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,219,71,57), ox = 34, oy = 56, rotate = -1.57, rx = 29, ry = -30 }, --falling
            delay = 5
        },
        getup = {
            { q = q(75,239,79,37), ox = 47, oy = 34 }, --lying down
            { q = q(156,214,69,62), ox = 34, oy = 59 }, --getting up
            { q = q(206,671,66,61), ox = 31, oy = 60 }, --pickup
            { q = q(206,600,69,64), ox = 35, oy = 63 }, --duck
            delay = 0.2
        },
        fallen = {
            { q = q(75,239,79,37), ox = 47, oy = 34 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,142,68,68), ox = 35, oy = 67, delay = 0.03 }, --hh1
            { q = q(72,142,69,68), ox = 37, oy = 67 }, --hh2
            { q = q(2,142,68,68), ox = 35, oy = 67, delay = 0.1 }, --hh1
            delay = 0.3
        },
        hurtLow = {
            { q = q(143,143,69,67), ox = 34, oy = 66, delay = 0.03 }, --hl1
            { q = q(214,146,72,64), ox = 34, oy = 63 }, --hl2
            { q = q(143,143,69,67), ox = 34, oy = 66, delay = 0.1 }, --hl1
            delay = 0.3
        },
        jumpAttackForward = {
            { q = q(59,352,60,74), ox = 32, oy = 75 }, --jaf1
            { q = q(121,359,58,58), ox = 29, oy = 68, funcCont = jump_forward_attack, delay = 5 }, --jaf2
            delay = 0.12
        },
        jumpAttackLight = {
            { q = q(59,352,60,74), ox = 32, oy = 75 }, --jaf1
            { q = q(121,359,58,58), ox = 29, oy = 68, funcCont = jump_forward_attack, delay = 5 }, --jaf2
            delay = 0.12
        },
        jumpAttackStraight = {
            { q = q(59,352,60,74), ox = 32, oy = 75 }, --jaf1
            { q = q(121,359,58,58), ox = 29, oy = 68, funcCont = jump_forward_attack, delay = 5 }, --jaf2
            delay = 0.12
        },
        jumpAttackRun = {
            { q = q(2,2,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 5
        },
        sideStepUp = {
            { q = q(2,2,68,68), ox = 34, oy = 67 }, --stand 1
        },
        sideStepDown = {
            { q = q(2,2,68,68), ox = 34, oy = 67 }, --stand 1
        },
        grab = {
            { q = q(68,285,51,65), ox = 21, oy = 64 }, --c1.2
        },
        grabHit = {
            { q = q(2,530,60,66), ox = 27, oy = 65 }, --grab attack 1
            { q = q(133,535,59,61), ox = 25, oy = 60, func = grabHit_attack, delay = 0.18 }, --grab attack 3
            delay = 0.015
        },
        grabHitLast = {
            { q = q(2,530,60,66), ox = 27, oy = 65 }, --grab attack 1
            { q = q(64,530,67,66), ox = 34, oy = 65, delay = 0.16 }, --grab attack 2
            { q = q(133,535,59,61), ox = 25, oy = 60, func = grabLast_attack, delay = 0.25 }, --grab attack 3
            delay = 0.03
        },
        shoveDown = {
            { q = q(2,530,60,66), ox = 27, oy = 65 }, --grab attack 1
            { q = q(64,530,67,66), ox = 34, oy = 65, delay = 0.16 }, --grab attack 2
            { q = q(133,535,59,61), ox = 25, oy = 60, func = grabLast_attack, delay = 0.25 }, --grab attack 3
            delay = 0.03
        },
        shoveForward = {
            { q = q(2,2,68,68), ox = 34, oy = 67 }, --stand 1
            delay = 0.1
        },
        shoveBack = {
            { q = q(2,461,55,67), ox = 29, oy = 66 }, --bat attack 1
            { q = q(194,534,70,62), ox = 35, oy = 61, func = shove_now, delay = 0.5 }, --throw
            { q = q(68,285,51,65), ox = 21, oy = 64 }, --c1.2
            delay = 0.2
        },
        grabSwap = {
            { q = q(2,2,68,68), ox = 34, oy = 67 }, --stand 1
        },
        grabbed = {
            { q = q(183,282,68,68), ox = 35, oy = 67 }, --grabbed 1
            { q = q(181,358,69,68), ox = 37, oy = 67 }, --grabbed 2
            delay = 0.1
        },
    }
}
