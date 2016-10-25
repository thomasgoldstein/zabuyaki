-- Date: 25.10.2016

-- Intro Movie
local slide1 = love.graphics.newImage("res/img/stages/stage1/building1_V.png")
local slide1q = love.graphics.newQuad(60, 70, 200, 120, slide1:getDimensions())
movie_intro = {
    {
        slide = slide1,
        q = slide1q,
        text =
[[This city has one rule:
fight for everything...]],
        delay = 4
    },
    {
        slide = slide1,
        q = love.graphics.newQuad(160, 170, 240, 80, slide1:getDimensions()),
        text =
[[And if you have nothing
then fight for your life...]],
        delay = 4
    },
    {
        slide = slide1,
        q = love.graphics.newQuad(230, 290, 220, 100, slide1:getDimensions()),
        text = "And the last.\nDon't let down your friends!",
        delay = 4
    },
    autoSkip = true,
    delayAfterFrame = 3,
    music = "res/bgm/rockdrive.xm"
}