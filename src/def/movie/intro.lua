-- Date: 28.10.2016

-- Intro Movie
local slide1 = love.graphics.newImage("res/img/stage/stage1/building1.png")
movie_intro = {
    {
        slide = slide1, -- Picture
        q = { 60, 70, 200, 120 }, -- Initial quad,
        hScroll = -10,
        text =
[[Abibas City was once a nice
place, but now it's a shithole.]]
    },
    {
        slide = slide1,
        q = { 160, 170, 240, 80 },
        vScroll = 20,
        text =
[[Crime runs rampant, and the
streets are no longer safe.]]
    },
    {
        slide = slide1,
        q = { 230, 290, 220, 100 },
        hScroll = -10,
        text =
[[Corruption suspicions grow
toward mayor Hyke Magger,
accused of ties to the mafia.]]
    },
    {
        slide = slide1,
        q = { 160, 170, 240, 80 },
        vScroll = 20,
        text =
[[The public waste collection
service has even been replaced
by a shady private company.]]
    },
    {
        slide = slide1,
        q = { 60, 70, 200, 120 },
        hScroll = -10,
        text =
[[After having lost their job,
the ex-garbage collectors saw
their city turn into a landfill.]]
    },
    {
        slide = slide1,
        q = { 230, 290, 220, 100 },
        text =
[[Some of them decided
to stand up and take out
the trash once and for all.]]
    },
    bgColor = { 0, 0, 0 },
    autoSkip = true,
    delayAfterFrame = 3, -- Wait after all the text is shown
    music = bgm.intro
}