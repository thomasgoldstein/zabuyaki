-- Date: 28.10.2016

-- Intro Movie
local slide1 = love.graphics.newImage("res/img/stages/stage1/building1.png")
movie_intro = {
    {
        slide = slide1, -- Picture
        q = { 60, 70, 200, 120 }, -- Initial quad
        text =
        [[This city has one rule:
fight for everything...]],
        hScroll = -10,
        delay = 4 -- How long to type th text
    },
    {
        slide = slide1,
        q = { 160, 170, 240, 80 },
        vScroll = 20,
        text =
        [[And if you have nothing
then fight for your life...]],
        delay = 4
    },
    {
        slide = slide1,
        q = { 230, 290, 220, 100 },
        text = "And the last.\nDon't let down your friends!",
        delay = 4
    },
    bgColor = { 0, 0, 0 },
    autoSkip = true,
    delayAfterFrame = 3, -- Wait after all the text is shown
    music = bgm.intro
}