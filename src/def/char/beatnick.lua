local sprite_sheet = "res/img/char/beatnick.png"
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
    local particles = PA_DUST_LANDING:clone()
    particles:setLinearAcceleration(150, 1, 300, -35)
    particles:setDirection( 0 )
    particles:setPosition( 20, 0 )
    particles:emit(5)
    particles:setLinearAcceleration(-150, 1, -300, -35)
    particles:setDirection( 3.14 )
    particles:setPosition( -20, 0 )
    particles:emit(5)
    stage.objects:add(Effect:new(particles, slf.x + 10 * slf.face, slf.y+2))
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
    sprite_name = "beatnick", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon  = {
            { q = q(19, 12, 31, 17) }
        },
        intro = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 5
        },
        stand = {
            { q = q(2,2,62,67), ox = 35, oy = 66, delay = 0.16 }, --stand 1
            { q = q(66,3,62,66), ox = 35, oy = 65, delay = 0.1 }, --stand 2
            { q = q(130,3,62,66), ox = 35, oy = 65 }, --stand 3
            { q = q(194,3,62,66), ox = 35, oy = 65 }, --stand 4
            { q = q(130,3,62,66), ox = 35, oy = 65 }, --stand 3
            { q = q(66,3,62,66), ox = 35, oy = 65, delay = 0.13 }, --stand 2
            loop = true,
            delay = 0.06
        },
        walk = {
            { q = q(2,2,62,67), ox = 35, oy = 66, delay = 0.16 }, --stand 1
            { q = q(66,3,62,66), ox = 35, oy = 65, delay = 0.1 }, --stand 2
            { q = q(130,3,62,66), ox = 35, oy = 65 }, --stand 3
            { q = q(194,3,62,66), ox = 35, oy = 65 }, --stand 4
            { q = q(130,3,62,66), ox = 35, oy = 65 }, --stand 3
            { q = q(66,3,62,66), ox = 35, oy = 65, delay = 0.13 }, --stand 2
            loop = true,
            delay = 0.06
        },
        run = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            loop = true,
            delay = 0.08
        },
        jump = { --TODO: Remove
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 5
        },
        respawn = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.3
        },
        duck = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.06
        },
        pickup = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.28
        },
        dashAttack = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.3
        },
        combo1 = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.01
        },
        combo2 = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.01
        },
        combo3 = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.01
        },
        fall = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 5
        },
        getup = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.3
        },
        fallen = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 65
        },
        hurtHigh = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.3
        },
        hurtLow = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
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
        grabAttack1 = { --TODO: Remove
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
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.1
        },

    } --offsets

} --return (end of file)