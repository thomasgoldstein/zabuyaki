local spriteSheet = "res/img/char/sveta-zeena.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local function f(n)
    return (n / 60) - ((n / 60) % 0.001) -- converts frames -> seconds. Usage: delay = f(4)
end
local airSfx = function(slf)
    slf:playSfx(sfx.air)
end
local comboSlap = function(slf, cont)
    slf:checkAndAttack(
        { x = 25, z = 32, width = 26, damage = 5, sfx = "air" },
        cont
    )
end
local comboKick = function(slf, cont)
    slf:checkAndAttack(
        { x = 21, z = 10, width = 25, damage = 8, type = "fell", repel_x = slf.dashAttackRepel_x },
        cont
    )
    -- move Zeena forward
    if slf.sprite.elapsedTime <= 0 then
        slf:initSlide(slf.slideSpeed_x)
    end
end
local dashAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 21, z = 10, width = 25, damage = 13, type = "fell", repel_x = slf.dashAttackRepel_x },
        cont
) end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "zeena", -- The name of the sprite

    delay = f(12), -- Default delay for all animations
    hurtBox = { width = 20, height = 50 }, -- Default hurtBox for all animations

    animations = {
        icon = {
            { q = q(389, 82, 33, 17) },
            delay = math.huge
        },
        stand = {
            { q = q(344,7,40,58), ox = 21, oy = 57 }, --stand 1
            { q = q(386,8,41,57), ox = 22, oy = 56, delay = f(11) }, --stand 2
            { q = q(429,9,41,56), ox = 22, oy = 55 }, --stand 3
            { q = q(386,8,41,57), ox = 22, oy = 56, delay = f(10) }, --stand 2
            loop = true,
            delay = f(12)
        },
        walk = {
            { q = q(344,72,40,57), ox = 21, oy = 57, delay = f(10) }, --walk 1
            { q = q(386,73,41,57), ox = 22, oy = 56 }, --walk 2
            { q = q(429,72,41,58), ox = 22, oy = 57, delay = f(10) }, --walk 3
            { q = q(386,8,41,57), ox = 22, oy = 56 }, --stand 2
            loop = true,
            delay = f(12)
        },
        squat = {
            { q = q(571,282,39,50), ox = 21, oy = 49 }, --squat
            delay = f(4)
        },
        land = {
            { q = q(571,282,39,50), ox = 21, oy = 49 }, --squat
            delay = f(4)
        },
        sideStepUp = {
            { q = q(344,203,38,60), ox = 22, oy = 59 }, --jump
            delay = math.huge
        },
        sideStepDown = {
            { q = q(344,203,38,60), ox = 22, oy = 59 }, --jump
            delay = math.huge
        },
        dropDown = {
            { q = q(344,203,38,60), ox = 22, oy = 59 }, --jump
            delay = math.huge
        },
        respawn = {
            { q = q(344,203,38,60), ox = 22, oy = 59 }, --jump
            { q = q(571,282,39,50), ox = 21, oy = 49, delay = f(36) }, --squat
            delay = math.huge
        },
        pickUp = {
            { q = q(571,282,39,50), ox = 21, oy = 49 }, --squat
            delay = f(17)
        },
        combo1 = {
            { q = q(344,138,55,57), ox = 35, oy = 56 }, --slap 1
            { q = q(401,138,54,57), ox = 16, oy = 56, func = comboSlap }, --slap 2
            { q = q(457,138,39,57), ox = 19, oy = 56 }, --slap 3
            delay = f(4)
        },
        combo2 = {
            { q = q(457,138,39,57), ox = 19, oy = 56 }, --slap 3
            { q = q(401,138,54,57), ox = 16, oy = 56, func = comboSlap }, --slap 2
            { q = q(344,138,55,57), ox = 35, oy = 56 }, --slap 1
            delay = f(4)
        },
        combo3 = {
            { q = q(344,138,55,57), ox = 35, oy = 56 }, --slap 1
            { q = q(401,138,54,57), ox = 16, oy = 56, func = comboSlap }, --slap 2
            { q = q(457,138,39,57), ox = 19, oy = 56 }, --slap 3
            delay = f(4)
        },
        combo4 = {
            { q = q(384,206,43,57), ox = 25, oy = 56 }, --jump attack 1 (shifted 5px down)
            { q = q(429,210,66,53), ox = 32, oy = 52, funcCont = comboKick, func = airSfx, delay = f(10) }, --jump attack 2 (shifted 9px down)
            { q = q(384,206,43,57), ox = 25, oy = 56, delay = f(7) }, --jump attack 1 (shifted 5px down)
            delay = f(4)
        },
        dashAttack = {
            { q = q(384,206,43,57), ox = 25, oy = 56 }, --dash attack 1
            { q = q(429,210,66,53), ox = 32, oy = 52, funcCont = dashAttack, delay = f(30) }, --dash attack 2
            { q = q(384,206,43,57), ox = 25, oy = 56 }, --dash attack 1
            delay = f(4)
        },
        hurtHighWeak = {
            { q = q(344,274,48,58), ox = 29, oy = 57, delay = f(12) }, --hurt high 1
            { q = q(394,273,44,59), ox = 25, oy = 58 }, --hurt high 2
            delay = f(2)
        },
        hurtHighMedium = {
            { q = q(344,274,48,58), ox = 29, oy = 57, delay = f(18) }, --hurt high 1
            { q = q(394,273,44,59), ox = 25, oy = 58 }, --hurt high 2
            delay = f(3)
        },
        hurtHighStrong = {
            { q = q(344,274,48,58), ox = 29, oy = 57, delay = f(24) }, --hurt high 1
            { q = q(394,273,44,59), ox = 25, oy = 58 }, --hurt high 2
            delay = f(4)
        },
        hurtLowWeak = {
            { q = q(440,276,38,56), ox = 20, oy = 55, delay = f(12) }, --hurt low 1
            { q = q(480,275,34,57), ox = 20, oy = 56 }, --hurt low 2
            delay = f(2)
        },
        hurtLowMedium = {
            { q = q(440,276,38,56), ox = 20, oy = 55, delay = f(18) }, --hurt low 1
            { q = q(480,275,34,57), ox = 20, oy = 56 }, --hurt low 2
            delay = f(3)
        },
        hurtLowStrong = {
            { q = q(440,276,38,56), ox = 20, oy = 55, delay = f(24) }, --hurt low 1
            { q = q(480,275,34,57), ox = 20, oy = 56 }, --hurt low 2
            delay = f(4)
        },
        fall = {
            { q = q(344,341,54,53), ox = 33, oy = 52, delay = f(20) }, --fall 1
            { q = q(400,350,63,44), ox = 38, oy = 43, delay = f(8) }, --fall 2
            { q = q(465,365,64,29), ox = 40, oy = 28 }, --fall 3
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(412,404,58,52), ox = 34, oy = 52 }, --fall twist 2
            { q = q(472,401,62,55), ox = 34, oy = 52 }, --fall twist 3
            { q = q(536,400,50,56), ox = 31, oy = 53 }, --fall twist 4
            { q = q(344,401,66,55), ox = 36, oy = 52, delay = math.huge }, --fall twist 1
            delay = f(8)
        },
        fallTwistStrong = {
            { q = q(344,401,66,55), ox = 36, oy = 52 }, --fall twist 1
            { q = q(412,404,58,52), ox = 34, oy = 52 }, --fall twist 2
            { q = q(472,401,62,55), ox = 34, oy = 52 }, --fall twist 3
            { q = q(536,400,50,56), ox = 31, oy = 53 }, --fall twist 4
            loop = true,
            delay = f(5)
        },
        fallBounce = {
            { q = q(531,365,66,29), ox = 41, oy = 27, delay = f(4) }, --fallen
            { q = q(465,365,64,29), ox = 40, oy = 28 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(531,365,66,29), ox = 41, oy = 27 }, --fallen
            delay = math.huge
        },
        fallOnHead = {
            { q = q(465,365,64,29), ox = 4, oy = 21, rotate = -1.57 }, --fall 3 (rotated -90°)
            { q = q(400,350,63,44), ox = 2, oy = 28, rotate = -1.57, delay = f(4) }, --fall 2 (rotated -90°)
            { q = q(344,341,54,53), ox = 4, oy = 31, rotate = -1.57 }, --fall 1 (rotated -90°)
            { q = q(465,365,64,29), ox = 40, oy = 28, delay = f(4) }, --fall 3
            delay = f(5)
        },
        getUp = {
            { q = q(531,365,66,29), ox = 41, oy = 27, delay = f(24) }, --fallen
            { q = q(516,287,53,45), ox = 30, oy = 44, delay = f(14) }, --get up
            { q = q(571,282,39,50), ox = 21, oy = 49 }, --squat
            delay = f(13)
        },
        grabbedFront = {
            { q = q(394,273,44,59), ox = 25, oy = 58 }, --hurt high 2
            { q = q(344,274,48,58), ox = 29, oy = 57 }, --hurt high 1
            delay = f(2)
        },
        grabbedBack = {
            { q = q(480,275,34,57), ox = 20, oy = 56 }, --hurt low 2
            { q = q(440,276,38,56), ox = 20, oy = 55 }, --hurt low 1
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(344,341,54,53), ox = 33, oy = 52, rotate = -1.57, rx = 16, ry = -26, delay = f(24) }, --fall 1 (rotated -90°)
            { q = q(465,365,64,29), ox = 40, oy = 28 }, --fall 3
            delay = math.huge
        },
        thrown12h = {
            { q = q(440,276,38,56), ox = 20, oy = 55 }, --hurt low 1
            delay = math.huge
        },
        thrown10h = {
            { q = q(344,341,54,53), ox = 33, oy = 52 }, --fall 1
            delay = math.huge
        },
        thrown8h = {
            { q = q(344,341,54,53), ox = 33, oy = 52, rotate = -1.57, rx = 33, ry = -26 }, --fall 1 (rotated -90°)
            delay = math.huge
        },
        thrown6h = {
            { q = q(440,276,38,56), ox = 20, oy = 55, flipH = -1, flipV = -1 }, --hurt low 1 (flipped horizontally and vertically)
            delay = math.huge
        },
    }
}
