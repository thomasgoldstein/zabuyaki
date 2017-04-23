local sprite_sheet = "res/img/char/sveta.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end
local step_sfx = function(slf, cont)
    sfx.play("sfx", slf.sfx.step, 0.5, 1 + 0.02 * love.math.random(-2,2))
    local padust = PA_DUST_STEPS:clone()
    padust:setLinearAcceleration(-slf.face * 50, 1, -slf.face * 100, -15)
    padust:emit(3)
    stage.objects:add(Effect:new(padust, slf.x - 20 * slf.face, slf.y+2))
end
local dash_belly_clouds = function(slf, cont)
    slf.isHittable = false
    sfx.play("sfx", "fall", 1, 1 + 0.02 * love.math.random(-2,2))
    --landing dust clouds
    local psystem = PA_DUST_LANDING:clone()
    psystem:setLinearAcceleration(150, 1, 300, -35)
    psystem:setDirection( 0 )
    psystem:setPosition( 20, 0 )
    psystem:emit(5)
    psystem:setLinearAcceleration(-150, 1, -300, -35)
    psystem:setDirection( 3.14 )
    psystem:setPosition( -20, 0 )
    psystem:emit(5)
    stage.objects:add(Effect:new(psystem, slf.x + 10 * slf.face, slf.y+2))
end
local combo_punch = function(slf, cont)
    slf:checkAndAttack(
        { left = 28, width = 26, height = 12, damage = 7, type = "high", velocity = slf.velx, sfx = "air" },
        cont
    )
    slf.cool_down_combo = 0.4
end
local combo_kick = function(slf, cont)
    slf:checkAndAttack(
        { left = 30, width = 26, height = 12, damage = 9, type = "fall", velocity = slf.velx, sfx = "air" },
        cont
    )
end
local dash_attack = function(slf, cont)
    slf:checkAndAttack(
    { left = 12, width = 30, height = 12, damage = 14, type = "fall", velocity = slf.velocity_dash_fall },
    cont
) end

return {
    serialization_version = 0.42, -- The version of this serialization process

    sprite_sheet = sprite_sheet, -- The path to the spritesheet
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
        jump = { --TODO: Remove
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
            delay = 5
        },
        respawn = {
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
            delay = 0.3
        },
        duck = {
            { q = q(147,209,48,56), ox = 30, oy = 55 }, --duck
            delay = 0.06
        },
        pickup = {
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
            delay = 0.28
        },
        dashAttack = {
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
            delay = 0.3
        },
        combo1 = {
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
            delay = 0.01
        },
        combo2 = {
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
            delay = 0.01
        },
        combo3 = {
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
            delay = 0.01
        },
        fall = {
            { q = q(2,267,75,54), ox = 49, oy = 53 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
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
            { q = q(2,134,48,62), ox = 30, oy = 61, delay = 0.03 }, --hurt high 1
            { q = q(52,138,58,58), ox = 39, oy = 57 }, --hurt high 2
            { q = q(112,134,50,62), ox = 32, oy = 61, delay = 0.1 }, --hurt high 3
            delay = 0.3
        },
        hurtLow = {
            { q = q(2,200,44,65), ox = 29, oy = 64, delay = 0.03 }, --hurt low 1
            { q = q(48,198,46,67), ox = 28, oy = 66 }, --hurt low 2
            { q = q(96,199,49,66), ox = 34, oy = 65, delay = 0.1 }, --hurt low 3
            delay = 0.3
        },
        jumpAttackForward = { --TODO: Remove
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 5
        },
        jumpAttackLight = { --TODO: Remove
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 5
        },
        jumpAttackStraight = { --TODO: Remove
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 5
        },
        sideStepUp = { --TODO: Remove
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
        },
        sideStepDown = { --TODO: Remove
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
        },
        grab = { --TODO: Remove
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
        },
        grabAttack = { --TODO: Remove
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.05
        },
        grabAttackLast = { --TODO: Remove
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.05
        },
        shoveDown = { --TODO: Remove
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.1
        },
        shoveForward = { --TODO: Remove
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
        },
        grabSwap = { --TODO: Remove
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
        },
        grabbed = {
            { q = q(2,134,48,62), ox = 30, oy = 61 }, --hurt high 1
            { q = q(52,138,58,58), ox = 39, oy = 57 }, --hurt high 2
            delay = 0.1
        },

    } --offsets

} --return (end of file)