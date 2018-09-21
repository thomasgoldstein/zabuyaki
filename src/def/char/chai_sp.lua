local spriteSheet = "res/img/char/chai_sp.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "chai", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon = {
            { q = q(0, 0, 8, 8) }
        },
        stand = {
            { q = q(2,2,4,4), ox = 3, oy = 7 },
        },
        specialDefensive = {
            { q = q(2,2,4,4), ox = 3, oy = 7 },
        },
        specialOffensive = {
            { q = q(2,2,4,4), ox = 3, oy = 7 },
        },
        specialOffensive2 = {
            { q = q(2,2,4,4), ox = 3, oy = 7 },
        },
        specialDash = {
            { q = q(2,2,4,4), ox = 3, oy = 7 },
        },
        specialDash2 = {
            { q = q(2,2,4,4), ox = 3, oy = 7 },
        },
    }
}
