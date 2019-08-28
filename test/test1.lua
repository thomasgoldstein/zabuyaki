-- Copyright (c) .2018 SineDie
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
        expect(CheckLinearCollision(0,10,0,10)).to.be.truthy()
        expect(CheckLinearCollision(0,10,9,10)).to.be.truthy()
        expect(CheckLinearCollision(0,10,10,10)).to_not.be.truthy()
        expect(CheckLinearCollision(10,1,9,2)).to.be.truthy()
        expect(CheckLinearCollision(10,5,1,10)).to.be.truthy()
    end)
end)

