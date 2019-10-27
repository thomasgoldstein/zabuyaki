local spriteSheet = "res/img/misc/portraits.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "portraits", -- The name of the sprite

    delay = math.huge, -- Default delay for all animations

    animations = {
        rick = {
            { q = q(2,2,70,70), ox = 0, oy = 0 }, --Rick default
            loop = true
        },
        kisa = {
            { q = q(74,2,70,70), ox = 0, oy = 0 }, --Kisa default
            loop = true
        },
        chai = {
            { q = q(146,2,70,70), ox = 0, oy = 0 }, --Chai default
            loop = true
        },
        yar = {
            { q = q(218,2,70,70), ox = 0, oy = 0 }, --Yar default
            loop = true
        },
    } --offsets

} --return (end of file)
