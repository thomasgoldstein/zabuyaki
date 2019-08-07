-- Copyright (c) .2017 SineDie
local spriteSheet = "res/img/misc/loot.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process
    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "apple", -- The name of the sprite
    delay = math.huge,	--default delay for all animations
    animations = {
        icon = {
            { q = q(2,2,18,17) } -- default 38x17
        },
        stand = {
            { q = q(2,2,18,17), ox = 9, oy = 16 }, --on the ground
            loop = true,
            delay = 1.2,
        },
    }
} --return (end of file)
