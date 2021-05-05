local spriteSheet = "res/img/stage/stage1/trashcan.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "trashcan", -- The name of the sprite
    isPlatform = true,
    delay = math.huge, -- Default delay for all animations
    hurtBox = { width = 15, height = 36, depth = 1 }, -- Default hurtBox for all animations
    animations = {
        icon = {
            { q = q(2, 2, 27, 17) },
            { q = q(31, 2, 27, 17) },
            { q = q(60, 5, 27, 17) },
            { q = q(89, 9, 27, 17) }
        },
        stand = {
            { q = q(2,2,27,42), ox = 13, oy = 41 }, --100% hp
            { q = q(31,2,27,42), ox = 13, oy = 41, hurtBox = { width = 15, height = 33, depth = 1 } },
            { q = q(60,5,27,39), ox = 13, oy = 38, hurtBox = { width = 15, height = 28, depth = 1 } },
            { q = q(89,9,27,35), ox = 13, oy = 34, hurtBox = { width = 15, height = 24, depth = 1 } } -- 0 HP
        },
    } --offsets

} --return (end of file)
