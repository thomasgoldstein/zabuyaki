local lust = require 'lib.test.lust.lust'
local describe, it, expect = lust.describe, lust.it, lust.expect
local dt = 1/60

describe("animatedSprite.lua Functions", function()
    lust.before(function()
        -- This gets run before every test.

        -- prepare dummy stage
        --stage:updateZStoppers(0.01)

        local n

        getSpriteInstance()
        spriteInstance = "src/def/char/rick"
        sprite = getSpriteInstance(spriteInstance)
        setSpriteAnimation(sprite, "combo1")

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
    it('Function calculateSpriteAnimation()', function()
        expect(sprite.def.comboMax).to.equal(4)
        expect(sprite.def.maxGrabAttack).to.equal(3)
    end)
    it('Function getSpriteQuad(spr, frame_n)', function()
        --{ q = q(49,519,60,63), ox = 19, oy = 62, func = comboAttack1, delay = 0.06 }, --combo 1.2
        --{ q = q(2,519,45,63), ox = 19, oy = 62 }, --combo 1.1
        local q0 = getSpriteQuad(sprite)
        local x0, y0, w0, h0 = q0:getViewport( )
        local q1 = getSpriteQuad(sprite, 1)
        local x1, y1, w1, h1 = q1:getViewport( )
        local q2 = getSpriteQuad(sprite, 2)
        local x2, y2, w2, h2 = q2:getViewport( )
        expect(x0).to.equal(49)
        expect(w0).to.equal(60)
        expect(y1).to.equal(519)
        expect(h1).to.equal(63)
        expect(x2).to.equal(2)
        expect(w2).to.equal(45)
    end)
    describe("Function updateSpriteInstance(dt)", function()
        it("Not looped animation", function()
            --print(0, sprite.curAnim, sprite.curFrame, sprite.isFirst, sprite.isLast, sprite.isFinished, sprite.elapsedTime)
            for i=1, 10 do
                updateSpriteInstance(sprite, dt, nil)
                --print(i, sprite.curAnim, sprite.curFrame, sprite.isFirst, sprite.isLast, sprite.isFinished, sprite.elapsedTime)
                if i <= 3 then
                    expect(sprite.curFrame).to.equal(1)
                    expect(sprite.isFirst).to.equal(true)
                    expect(sprite.isLast).to_not.equal(true)
                    expect(sprite.isFinished).to_not.equal(true)
                end
                if i >= 4 then
                    expect(sprite.curFrame).to.equal(2)
                    expect(sprite.isFirst).to_not.equal(true)
                    expect(sprite.isLast).to.equal(true)
                end
                if i == 5 then
                    expect(sprite.isFinished).to.equal(true)
                end
                if sprite.isFinished then
                    break
                end
            end
        end)
        it("Looped animation", function()
            setSpriteAnimation(sprite, "stand")
            --print(0, sprite.curAnim, sprite.curFrame, sprite.isFirst, sprite.isLast, sprite.isFinished, sprite.elapsedTime)
            updateSpriteInstance(sprite, dt, nil)
            --print(1, sprite.curAnim, sprite.curFrame, sprite.isFirst, sprite.isLast, sprite.isFinished, sprite.elapsedTime)
            expect(sprite.isLoopFrom).to.equal(true)
            expect(sprite.curFrame).to.equal(1)
            expect(sprite.isFirst).to.equal(true)
            expect(sprite.isLast).to_not.equal(true)
            expect(sprite.isFinished).to_not.equal(true)
            sprite.curFrame = sprite.maxFrame
            updateSpriteInstance(sprite, dt, nil)
            --print(2, sprite.curAnim, sprite.curFrame, sprite.isFirst, sprite.isLast, sprite.isFinished, sprite.elapsedTime)
            expect(sprite.isLoopFrom).to.equal(false)
            expect(sprite.curFrame).to.equal(sprite.maxFrame)
            expect(sprite.isFirst).to_not.equal(true)
            expect(sprite.isLast).to.equal(true)
            expect(sprite.isFinished).to_not.equal(true)
            updateSpriteInstance(sprite, 26, nil) -- to make the sprite loop
            --print(2, sprite.curAnim, sprite.curFrame, sprite.isFirst, sprite.isLast, sprite.isFinished, sprite.elapsedTime)
            expect(sprite.isLoopFrom).to.equal(true)
            expect(sprite.curFrame).to.equal(1)
            expect(sprite.isFirst).to.equal(true)
            expect(sprite.isLast).to_not.equal(true)
            expect(sprite.isFinished).to_not.equal(true)
        end)
        it("Rick's chargeDashAttack timings (test delay rounding/truncating)", function()
            local n, n2 = 0, 0
            setSpriteAnimation(sprite, "chargeAttack")
            for i=1, 100 do
                n = n + 1
                updateSpriteInstance(sprite, dt, nil)
                --print(n, sprite.curAnim, sprite.curFrame, sprite.isFirst, sprite.isLast, sprite.isFinished, sprite.elapsedTime)
                if sprite.isFinished then
                    break
                end
            end
            setSpriteAnimation(sprite, "chargeAttack")
            local s = sprite.def.animations[sprite.curAnim]
            sprite.delay = 0.05
            s[1].delay = 0.05
            s[2].delay = 0.05
            s[4].delay = 0.05
            s[5].delay = 0.05
            s[6].delay = 0.05
            s[7].delay = 0.05
            for i=1, 100 do
                n2 = n2 + 1
                updateSpriteInstance(sprite, dt, nil)
                --print(n2, sprite.curAnim, sprite.curFrame, sprite.isFirst, sprite.isLast, sprite.isFinished, sprite.elapsedTime)
                if sprite.isFinished then
                    break
                end
            end
            expect(n).to.equal(n2)  -- the number of displayed frames should coincide
        end)
    end)
end)
