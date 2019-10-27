-- Copyright (c) .2018 SineDie
local lust = require 'lib.test.lust.lust'
local describe, it, expect = lust.describe, lust.it, lust.expect

describe("animatedSprite Functions", function()
    lust.before(function()
        -- This gets run before every test.

        -- prepare dummy stage
        --stage:updateZStoppers(0.01)

        local n

        getSpriteInstance()
        spriteInstance = "src/def/char/rick"
        sprite = getSpriteInstance(spriteInstance)

        -- mock real lib functions
    end)
    lust.after(function(txt)
        -- This gets run after every test.
        sprite = nil
        spriteInstance = nil
        -- restore mocked lib functions
    end)
    it('Function spriteHasAnimation(spr, anim)', function()
        expect(spriteHasAnimation(sprite, "combo1")).to.equal(true)
        expect(spriteHasAnimation(sprite, "Combo1")).to.equal(false)
        expect(spriteHasAnimation(sprite, "")).to.equal(false)
    end)
end)
