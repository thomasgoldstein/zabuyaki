local spriteSheet = "res/img/misc/loot.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process
    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "bat", -- The name of the sprite
    delay = math.huge, -- Default delay for all animations
    hurtBox = { width = 10, height = 10 }, -- Default hurtBox for all animations
    animations = {
        icon = {
            { q = q(2,23,38,11) }
        },
        stand = {
            { q = q(2,23,55,11), ox = 27, oy = 10 } --on the ground
        },
        angle0 = {
            { q = q(2,23,55,11), ox = 12, oy = 5 }  --a0 -
        },
        angle22 = {
            { q = q(2,36,54,28), ox = 13, oy = 9 } --a22 \-
        },
        angle45 = {
            { q = q(2,66,44,44), ox = 12, oy = 13 } --a45 \+
        }
    }
} --return (end of file)
