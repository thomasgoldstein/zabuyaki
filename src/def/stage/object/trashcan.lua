local spriteSheet = "res/img/stage/stage1/trashcan.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "trashcan", -- sprite name

    delay = math.huge,	--default delay for all
    hurtBox = { width = 15, height = 36 },
    animations = {
        icon = {
            { q = q(2, 2, 27, 17) },
            { q = q(31, 2, 27, 17) },
            { q = q(60, 5, 27, 17) },
            { q = q(89, 9, 27, 17) }
        },
        stand = {
            { q = q(2,2,27,42), ox = 13.5, oy = 41 }, --100% hp
            { q = q(31,2,27,42), ox = 13.5, oy = 41, hurtBox = { width = 15, height = 33 } },
            { q = q(60,5,27,39), ox = 13.5, oy = 38, hurtBox = { width = 15, height = 28 } },
            { q = q(89,9,27,35), ox = 13.5, oy = 34, hurtBox = { width = 15, height = 24 } } -- 0 HP
        },
    } --offsets

} --return (end of file)
