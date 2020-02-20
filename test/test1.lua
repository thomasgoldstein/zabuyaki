local lust = require 'lib.test.lust.lust'
local describe, it, expect = lust.describe, lust.it, lust.expect

ps("Start of Units Tests", "#")

describe("Collision functions", function()
    lust.before(function()
        -- This gets run before every test.
    end)
    it('CheckPointCollision', function()
        expect(CheckPointCollision(0, 0, 0, 0, 1, 1)).to.be.truthy()
        expect(CheckPointCollision(1001, 1001, 1, 1, 1000, 1000)).to_not.be.truthy()
        expect(CheckPointCollision(15, 15, 10, 10, 30, 30)).to.be.truthy()
        expect(CheckPointCollision(1, 0, 0, 0, 1, 1)).to_not.be.truthy()
        expect(CheckPointCollision(0, 1, 0, 0, 1, 1)).to_not.be.truthy()
        expect(CheckPointCollision(-5, -5, -2, -1, 100, 1000)).to_not.be.truthy()
        expect(CheckPointCollision(-5, -5, -5, -5, 1, 1)).to.be.truthy()
        expect(CheckPointCollision(-1, 11, 0, 0, 1, 1)).to_not.be.truthy()
    end)
    it('CheckLinearCollision', function()
        expect(CheckLinearCollision(0, 10, 0, 10)).to.be.truthy()
        expect(CheckLinearCollision(0, 10, 9, 10)).to.be.truthy()
        expect(CheckLinearCollision(0, 10, 10, 10)).to_not.be.truthy()
        expect(CheckLinearCollision(10, 1, 9, 2)).to.be.truthy()
        expect(CheckLinearCollision(10, 5, 1, 10)).to.be.truthy()
    end)
    it('CheckCollision (rect + rect)', function()
        local r0 = { x = 0, y = 0, w = 0, h = 0 }
        local r1 = { x = 10, y = 10, w = 100, h = 100 }
        local r2 = { x = 50, y = 50, w = 10, h = 10 }
        local ra = { x = 28, y = 30, w = 26, h = 35 }
        local rh = { x = 0, y = 0, w = 200, h = 150 }
        local rh2 = { x = 0, y = 150, w = 200, h = 150 }
        expect(CheckCollision(r1.x, r1.y, r1.w, r1.h, r0.x, r0.y, r0.w, r0.h)).to_not.be.truthy()
        expect(CheckCollision(r0.x, r0.y, r0.w, r0.h, r1.x, r1.y, r1.w, r1.h)).to_not.be.truthy()
        expect(CheckCollision(r1.x, r1.y, r1.w, r1.h, r2.x, r2.y, r2.w, r2.h)).to.be.truthy()
        expect(CheckCollision(r2.x, r2.y, r2.w, r2.h, r1.x, r1.y, r1.w, r1.h)).to.be.truthy()
        expect(CheckCollision(10, 10, 100, 100, 50, 50, 10, 10)).to.be.truthy()
        expect(CheckCollision(0, 10, 1, 10, 0, 10, 1, 10)).to.be.truthy()
        expect(CheckCollision(0, 0, 1, 1, 2, 3, 1, 1)).to_not.be.truthy()
        expect(CheckCollision(rh.x, rh.y, rh.w, rh.h, rh2.x, rh2.y, rh2.w, rh2.h)).to_not.be.truthy()
        expect(CheckCollision(rh.x, rh.y, rh.w, rh.h,   ra.x, ra.y, ra.w, ra.h)).to.be.truthy()
        expect(CheckCollision(ra.x, ra.y, ra.w, ra.h,   rh.x, rh.y, rh.w, rh.h)).to.be.truthy()
        ra.x = -26
        expect(CheckCollision(rh.x, rh.y, rh.w, rh.h,   ra.x, ra.y, ra.w, ra.h)).to_not.be.truthy()
        expect(CheckCollision(ra.x, ra.y, ra.w, ra.h,   rh.x, rh.y, rh.w, rh.h)).to_not.be.truthy()
    end)
    it('CheckCollision3D (cube + cube)', function()
        local c0 = { x = 0, y = 0, z = 0, w = 0, h = 0, d = 0 }
        local c1 = { x = 0, y = 0, z = 0, w = 1, h = 1, d = 1 }
        local c2a = { x = 10, y = 10, z = 10, w = 5, h = 5, d = 5 }
        local c2b = { x = 14, y = 14, z = 14, w = 5, h = 5, d = 5 }
        expect(CheckCollision3D(c0.x, c0.y, c0.z, c0.w, c0.h, c0.d, c0.x, c0.y, c0.z, c0.w, c0.h, c0.d)).to_not.be.truthy()
        expect(CheckCollision3D(c1.x, c1.y, c1.z, c1.w, c1.h, c1.d, c1.x, c1.y, c1.z, c1.w, c1.h, c1.d)).to.be.truthy()
        expect(CheckCollision3D(c1.x, c1.y, c1.z, c1.w, c1.h, c1.d, c0.x, c0.y, c0.z, c0.w, c0.h, c0.d)).to_not.be.truthy()
        expect(CheckCollision3D(c2a.x, c2a.y, c2a.z, c2a.w, c2a.h, c2a.d, c2b.x, c2b.y, c2b.z, c2b.w, c2b.h, c2b.d)).to.be.truthy()
        c2b.x = c2b.x + 1
        expect(CheckCollision3D(c2a.x, c2a.y, c2a.z, c2a.w, c2a.h, c2a.d, c2b.x, c2b.y, c2b.z, c2b.w, c2b.h, c2b.d)).to_not.be.truthy()
        c2b.x = 5
        c2b.y = 5
        c2b.z = 5
        expect(CheckCollision3D(c2a.x, c2a.y, c2a.z, c2a.w, c2a.h, c2a.d, c2b.x, c2b.y, c2b.z, c2b.w, c2b.h, c2b.d)).to_not.be.truthy()
        c2b.x = 6
        c2b.y = 6
        c2b.z = 6
        expect(CheckCollision3D(c2a.x, c2a.y, c2a.z, c2a.w, c2a.h, c2a.d, c2b.x, c2b.y, c2b.z, c2b.w, c2b.h, c2b.d)).to.be.truthy()
        c2b.z = 10 + 4
        expect(CheckCollision3D(c2a.x, c2a.y, c2a.z, c2a.w, c2a.h, c2a.d, c2b.x, c2b.y, c2b.z, c2b.w, c2b.h, c2b.d)).to.be.truthy()
        c2b.z = 10 + 5
        expect(CheckCollision3D(c2a.x, c2a.y, c2a.z, c2a.w, c2a.h, c2a.d, c2b.x, c2b.y, c2b.z, c2b.w, c2b.h, c2b.d)).to_not.be.truthy()
    end)
end)
