
if false then -- For LuaDoc
    ---
    -- Pure Lua implementation of bitwise operations.
    -- Not suitable for time critical code. Intended as fallback
    -- for cases where a native implementation is unavailable.
    -- Further optimization may be possible.
    -- @version 0.1
    -- @author kaeza <https://github.com/kaeza>
    module "bitty"
end

-- Localize as much as possible.
local tconcat = table.concat
local floor, ceil, max, log = math.floor, math.ceil, math.max, math.log
local tonumber, assert, type = tonumber, assert, type

local function tobittable_r(x, ...)
    if (x or 0) == 0 then return ... end
    return tobittable_r(floor(x/2), x%2, ...)
end

local function tobittable(x)
    assert(type(x) == "number", "argument must be a number")
    if x == 0 then return { 0 } end
    return { tobittable_r(x) }
end

local function makeop(cond)
    local function oper(x, y, ...)
        if not y then return x end
        x, y = tobittable(x), tobittable(y)
        local xl, yl = #x, #y
        local t, tl = { }, max(xl, yl)
        for i = 0, tl-1 do
            local b1, b2 = x[xl-i], y[yl-i]
            if not (b1 or b2) then break end
            t[tl-i] = (cond((b1 or 0) ~= 0, (b2 or 0) ~= 0)
                    and 1 or 0)
        end
        return oper(tonumber(tconcat(t), 2), ...)
    end
    return oper
end

---
-- Perform bitwise AND of several numbers.
-- Truth table:
--   band(0,0) -> 0,
--   band(0,1) -> 0,
--   band(1,0) -> 0,
--   band(1,1) -> 1.
-- @class function
-- @name band
-- @param ...  Numbers.
-- @return  A number.
local band = makeop(function(a, b) return a and b end)

---
-- Perform bitwise OR of several numbers.
-- Truth table:
--   bor(0,0) -> 0,
--   bor(0,1) -> 1,
--   bor(1,0) -> 1,
--   bor(1,1) -> 1.
-- @class function
-- @name bor
-- @param ...  Numbers.
-- @return  A number.
local bor = makeop(function(a, b) return a or b end)

---
-- Perform bitwise exclusive-OR (XOR) of several numbers.
-- Truth table:
--   bxor(0,0) -> 0,
--   bxor(0,1) -> 1,
--   bxor(1,0) -> 1,
--   bxor(1,1) -> 0.
-- @class function
-- @name bxor
-- @param ...  Numbers.
-- @return  A number.
local bxor = makeop(function(a, b) return a ~= b end)

---
-- Perform bitwise negation on a number.
-- Truth table:
--    bnot(0) -> 1,
--    bnot(1) -> 0.
-- If 'bits' is given, it specifies the number of bits
-- in the result. If not given, defaults to the base 2
-- logarithm of 'x'.
-- @param x  The number to negate (number).
-- @param bits  Number of bits for result (number|nil).
-- @return  A number.
local function bnot(x, bits)
    return bxor(x, (2^(bits or floor(log(x, 2))))-1)
end

---
-- Shift a number's bits to the left.
-- Roughly equivalent to (x * (2^bits)).
-- @param x  The number to shift (number).
-- @param bits  Number of positions to shift by (number).
-- @return  A number.
local function blshift(x, bits)
    return floor(x) * (2^bits)
end

---
-- Shift a number's bits to the right.
-- Roughly equivalent to (x / (2^bits)).
-- @param x  The number to shift (number).
-- @param bits  Number of positions to shift by (number).
-- @return  A number.
local function brshift(x, bits)
    return floor(floor(x) / (2^bits))
end

---
-- Convert a number to base 2 representation.
-- @param x  The number to convert (string|number).
-- @param bits  Minimum number of bits. If resulting string's
--   is shorter than this many characters, the result will be
--   padded with zeros. If not specified, no padding is done.
-- @return  A string.
local function tobin(x, bits)
    local r = tconcat(tobittable(x))
    return ("0"):rep((bits or 1)+1-#r)..r
end

---
-- Convert a number in base 2 representation to a decimal number.
-- Roughly equivalent to 'tonumber(x, 2)'.
-- Added for symmetry with 'tobin'.
-- @param x  The number to convert (string).
-- @return  A number.
local function frombin(x)
    return tonumber(x:match("^0*(.*)"), 2)
end

---
-- Test if a bit is set.
-- @param x  A number
-- @param bit  Bit to check (number). 0 is rightmost (LSB),
--   1 is second from right, and so on.
-- @param ...  Extra bits to check.
-- @return  True if bit is set, false otherwise. If more than
--   one bit position is specified, returns a boolean for
--   every bit.
local function bisset(x, bit, ...)
    if not bit then return end
    return brshift(x, bit)%2 == 1, bisset(x, ...)
end

---
-- Set a bit.
-- @param x  A number
-- @param bit  Bit to set (number). 0 is rightmost (LSB),
--   1 is second from right, and so on.
-- @return  The number 'x' with the bit set.
local function bset(x, bit)
    return bor(x, 2^bit)
end

---
-- Unset a bit.
-- @param x  A number
-- @param bit  Bit to unset (number). 0 is rightmost (LSB),
--   1 is second from right, and so on.
-- @return  The number 'x' with the bit unset.
local function bunset(x, bit)
    return band(x, bnot(2^bit, ceil(log(x, 2))))
end

local function repr(x)
    return (type(x)=="string" and ("%q"):format(x) or tostring(x))
end

local function assert_equals(x, y)
    return x==y or error("assertion failed:"
            .." expected "..repr(y)..", got "..repr(x), 2)
end

assert_equals(tobin(0xDEADBEEF), "11011110101011011011111011101111")
assert_equals(frombin("11011110101011011011111011101111"), 0xDEADBEEF)
assert_equals(bor(0xDEADBEEF, 0xCAFEBABE), 0xDEFFBEFF)
assert_equals(band(0xDEADBEEF, 0xCAFEBABE), 0xCAACBAAE)
assert_equals(bxor(0xDEADBEEF, 0xCAFEBABE), 0x14530451)
assert_equals(blshift(0xDEAD, 16), 0xDEAD0000)
assert_equals(brshift(0xDEAD0000, 16), 0xDEAD)
assert_equals(brshift(0xDEAD, 8), 0xDE)
assert_equals(bnot(0, 8), 0xFF)
assert(bisset(0x10, 4))
assert_equals(bset(0, 4), 0x10)
assert_equals(bunset(0x12, 1), 0x10)

local a, b, c, d, e = bisset(frombin("10101"), 0, 1, 2, 3, 4)
assert(a and c and e and not (b or d))

return {
    _NAME = "bitty",
    _VERSION = "0.1",
    _LICENSE = "CC-0 Unported <?>",
    bor = bor,
    band = band,
    bxor = bxor,
    bnot = bnot,
    blshift = blshift,
    brshift = brshift,
    tobin = tobin,
    frombin = frombin,
    bset = bset,
    bunset = bunset,
    bisset = bisset,
}
