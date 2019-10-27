local spriteSheet = "res/img/stage/stage1/sign.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "sign", -- The name of the sprite
    isPlatform = true,
    delay = math.huge, -- Default delay for all animations
    hurtBox = { width = 20, height = 64 }, -- Default hurtBox for all animations
    animations = {
        icon = {
            { q = q(2, 10, 34, 17) },
            { q = q(38, 11, 34, 17) },
            { q = q(74, 16, 34, 17) },
            { q = q(2, 80, 34, 17) }
        },
        stand = {
            { q = q(2,2,34,75), ox = 17, oy = 74 }, --100% hp
            { q = q(38,3,34,74), ox = 28, oy = 73, hurtBox = { x = -10, width = 20, height = 64 } },
            { q = q(74,7,42,70), ox = 39, oy = 69, hurtBox = { x = -20, width = 20, height = 60 } },
            { q = q(2,79,77,23), ox = 74, oy = 12, hurtBox = { width = 6, height = 10 } }, -- 0 HP
        },
    } --offsets

} --return (end of file)
