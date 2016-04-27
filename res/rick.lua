print("rick.lua loaded")

local image_w = 224 --This info can be accessed with a Love2D call
local image_h = 979 --after the image has been loaded

local function q(x,y,w,h)
	return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local step_sfx = function() TEsound.play("res/sfx/step.wav", nil, 0.5) end
local step_sfx2 = function() TEsound.play("res/sfx/step.wav", nil, 1) end
local jump_still_attack = function(self) self:checkAndAttack(28,0, 20,12, 13, "fall") end
local grabKO_attack = function(self) self:checkAndAttack(20,0, 20,12, 11, "grabKO") end
local grabLow_attack = function(self) self:checkAndAttack(10,0, 20,12, 8, "low") end
local combo_attack = function(slf)
        TEsound.play("res/sfx/attack1.wav", nil, 2) --air
		if slf.n_combo == 1 then
            slf:checkAndAttack(30,0, 22,12, 7, "high")
        elseif slf.n_combo == 2 then
            slf:checkAndAttack(30,0, 22,12, 8, "high")
        elseif slf.n_combo == 3 then
            slf:checkAndAttack(30,0, 22,12, 9, "high")
        elseif slf.n_combo == 4 then
            slf:checkAndAttack(30,0, 22,12, 7, "low")
            slf.n_combo = 5
        else -- self.n_combo == 5
            slf.victims = {}
            slf:checkAndAttack(30,0, 22,12, 8, "fall")
            slf.n_combo = 6
        end
        slf.cool_down_combo = 0.4
end
local dash_attack = function(slf) slf.permAttack = slf:checkAndAttack(20,0, 55,12, 20, "fall") end
local jump_forward_attack = function(slf) slf.permAttack = function(slf) slf:checkAndAttack(32,0, 25,12, 15, "fall") end end
local jump_weak_attack = function(slf)
	slf.permAttack = function(slf)
		if slf.z > 30 then
			slf:checkAndAttack(15,0, 22,12, 8, "high")
		elseif slf.z > 10 then
			slf:checkAndAttack(15,0, 22,12, 8, "low")
		end
	end
end

return {
	serialization_version = 0.42, -- The version of this serialization process

	sprite_sheet = "res/rick.png", -- The path to the spritesheet
	--TODO read width/height of the sheet automatically.
	sprite_name = "rick", -- The name of the sprite

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
			{ q = q(2,2,44,64), ox = 22, oy = 63 }, --stand 1
			{ q = q(48,3,45,63), ox = 22, oy = 62 }, --stand 2
			{ q = q(95,4,46,62), ox = 22, oy = 61 }, --stand 3
			{ q = q(48,3,45,63), ox = 22, oy = 62 }, --stand 2
            loop = true,
			delay = 0.167
		},
		walk = { -- 1 2 3 4 5 6
			{ q = q(2,68,35,64), ox = 17, oy = 63 }, --walk 1
			{ q = q(39,68,35,64), ox = 17, oy = 63 }, --walk 2
			{ q = q(76,69,35,63), ox = 17, oy = 62, func = step_sfx, delay = 0.25 }, --walk 3
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(150,68,35,64), ox = 17, oy = 63 }, --walk 5
			{ q = q(187,69,35,63), ox = 17, oy = 62, func = step_sfx, delay = 0.25 }, --walk 6
            loop = true,
            delay = 0.167
		},
		run = { -- 1 2 3 4 5 6
			{ q = q(2,136,44,60), ox = 14, oy = 60 }, --run 1
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
			{ q = q(100,134,48,62), ox = 17, oy = 60, func = step_sfx2 }, --run 3
			{ q = q(2,200,42,60), ox = 12, oy = 60 }, --run 4
			{ q = q(46,198,50,61), ox = 18, oy = 61 }, --run 5
			{ q = q(98,198,48,62), ox = 17, oy = 60, func = step_sfx2 }, --run 6
            loop = true,
            delay = 0.1
		},
		jump = {
			{ q = q(46,262,44,66), ox = 22, oy = 65, delay = 0.4 }, --ju
			{ q = q(92,262,45,61), ox = 22, oy = 65 }, --jd
			delay = 5
		},
		duck = {
			{ q = q(2,269,42,59), ox = 21, oy = 58 }, --duck
			delay = 0.15
		},
		pickup = {
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			{ q = q(48,398,43,58), ox = 21, oy = 57, delay = 0.2 }, --pickup 2
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			delay = 0.05
		},
		dash = {
			{ q = q(2,915,63,62), ox = 37, oy = 61 }, --dash1
			{ q = q(67,914,38,63), ox = 18, oy = 62, delay = 0.1 }, --dash2
			{ q = q(107,913,60,64), ox = 17, oy = 63, func = dash_attack }, --dash3
			{ q = q(169,916,53,61), ox = 17, oy = 60 }, --dash4
			{ q = q(117,519,40,63), ox = 17, oy = 62 }, --p2.2
			delay = 0.16
		},
		combo1 = {
			{ q = q(67,519,48,63), ox = 22, oy = 62 }, --p1.2
			{ q = q(2,519,63,63), ox = 22, oy = 62, func = combo_attack, delay = 0.06 }, --p1.1
			{ q = q(67,519,48,63), ox = 22, oy = 62 }, --p1.2
			delay = 0.01
		},
		combo2 = {
			{ q = q(117,519,40,63), ox = 17, oy = 62 }, --p2.2
			{ q = q(159,519,60,63), ox = 18, oy = 62, func = combo_attack, delay = 0.08 }, --p2.1
			{ q = q(117,519,40,63), ox = 17, oy = 62 }, --p2.2
			delay = 0.04
		},
		combo3 = {
			{ q = q(2,584,37,63), ox = 17, oy = 62 }, --p3.1
			{ q = q(41,584,57,63), ox = 17, oy = 62, func = combo_attack, delay = 0.1 }, --p3.2
			{ q = q(100,584,53,63), ox = 22, oy = 62 }, --p3.3
			delay = 0.06
		},
		combo4 = {
			{ q = q(2,649,46,62), ox = 15, oy = 62, func = combo_attack, delay = 0.15 }, --k1.1
			{ q = q(50,650,61,61), ox = 19, oy = 61, func = combo_attack, delay = 0.15 }, --k1.2
			{ q = q(113,649,49,62), ox = 14, oy = 62 }, --k1.3
			{ q = q(164,649,42,63), ox = 16, oy = 62 }, --k1.4
			delay = 0.06
		},
		fall = {
			{ q = q(2,458,60,59), ox = 30, oy = 58, delay = 0.8 },
			{ q = q(64,487,69,30), ox = 34, oy = 29, delay = 3 },
			{ q = q(135,464,56,53), ox = 28, oy = 52, delay = 1 },
			delay = 0.2
		},
		getup = {
			{ q = q(64,487,69,30), ox = 34, oy = 29, delay = 1 },
			{ q = q(135,464,56,53), ox = 28, oy = 52 },
			{ q = q(48,398,43,58), ox = 21, oy = 57 }, --pickup 2
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			delay = 0.2
		},
		dead = {
			{ q = q(135,464,56,53), ox = 28, oy = 52, delay = 1 },
			{ q = q(64,487,69,30), ox = 34, oy = 29 },
			delay = 65
		},
		hurtHigh = {
			{ q = q(2,330,45,63), ox = 24, oy = 62 }, --hh1
			{ q = q(49,331,47,62), ox = 27, oy = 61 }, --hh2
			{ q = q(2,330,45,63), ox = 24, oy = 62 }, --hh1
			delay = 0.1
		},
		hurtLow = {
			{ q = q(98,330,45,63), ox = 20, oy = 62 }, --hl1
			{ q = q(145,331,44,62), ox = 18, oy = 61 }, --hl2
			{ q = q(98,330,45,63), ox = 20, oy = 62 }, --hl1
			delay = 0.1
		},
		jumpAttackForward = {
			{ q = q(2,714,54,62), ox = 27, oy = 61, delay = 0.2 }, -- jaf1
			{ q = q(58,714,75,58), ox = 37, oy = 57, func = jump_forward_attack }, -- jaf2
			delay = 5
		},
		jumpAttackWeak = {
			{ q = q(2,844,43,67), ox = 21, oy = 66, delay = 0.2 }, -- jaw1
			{ q = q(47,844,47,63), ox = 23, oy = 62, func = jump_weak_attack }, -- jaw2
			delay = 5
		},
		jumpAttackStill = {
			{ q = q(2,778,38,63), ox = 19, oy = 62, delay = 0.4 }, -- jas1
			{ q = q(42,778,50,64), ox = 19, oy = 63, func = jump_still_attack, delay = 0.1 }, -- jas2
			{ q = q(94,778,43,62), ox = 19, oy = 61 }, -- jas3
			delay = 5
		},
		sideStepUp = {
			{ q = q(96,844,44,64), ox = 22, oy = 63 }, --ssu
		},
		sideStepDown = {
			{ q = q(142,844,45,63), ox = 22, oy = 62 }, --ssd
		},
		grab = {
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
		},
        letGo = {
            { q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
        },
        grabHit = {
			{ q = q(48,134,50,62), ox = 18, oy = 61, func = grabLow_attack }, --run 2
		},
		grabHitEnd = {
			{ q = q(48,134,50,62), ox = 18, oy = 61, func = grabKO_attack }, --run 2
		},
		grabThrow = {
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
		},
		grabSwap = {
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
		},
		grabbed = {
			{ q = q(2,330,45,63), ox = 24, oy = 62 }, --hh1
			{ q = q(49,331,47,62), ox = 27, oy = 61 }, --hh2
			delay = 0.1
		},

	} --offsets

} --return (end of file)
