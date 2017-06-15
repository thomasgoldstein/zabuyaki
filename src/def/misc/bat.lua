local spriteSheet = "res/img/misc/loot.png"
local imageWidth, imageHeight = LoadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.42, -- The version of this serialization process
    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "bat", -- The name of the sprite
    delay = 5.2,	--default delay for all animations
    animations = {
        icon  = {
            { q = q(2,23,11,17) } -- default 38x17
        },
        stand = {
            { q = q(2,23,11,55), ox = 5, oy = 42, rotate = 1.57 } --on the ground
        },
        angle0 = {
            { q = q(2,23,11,55), ox = 5, oy = 42 }  --a0 |
        },
        angle22 = {
            { q = q(15,23,28,54), ox = 8, oy = 40 } --a22 /-
        },
        angle45 = {
            { q = q(45,23,44,44), ox = 11, oy = 32 } --a45 /+
        },
        angle0Equipped = {
            { q = q(2,80,11,55), ox = 5, oy = 42 }  --a0 eq |
        },
        angle22Equipped = {
            { q = q(15,80,28,54), ox = 8, oy = 40 } --a22 eq /-
        },
        angle45Equipped = {
            { q = q(45,80,44,44), ox = 11, oy = 32 } --a45 eq /+
        },
    }
} --return (end of file)
