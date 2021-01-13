-- Intro Movie
local scene1 = love.graphics.newImage("res/img/misc/introScene1.png")
local slides = love.graphics.newImage("res/img/misc/intro.png")
movie_intro = {
    {
        {
            slide = scene1,
            q = { 0, 0, 180, 135 }, -- bg city, window
        },
        noFadeOut = true,
        text = [[Adigrad is a city ravaged
by crime and corruption,
leading to a garbage crisis.]]
    },
    {
        {
            slide = scene1,
            q = { 0, 0, 180, 135 }, -- bg city, window
            hScroll = 60, -- Scroll to the left by 60px
        },
        {
            slide = scene1,
            q = { -180, 136, 180, 135 }, -- reflection
            hScroll = 180, -- Scroll to the left by 180px
        },
        {
            slide = scene1,
            q = { -190, 271, 180, 135 }, -- boss
            hScroll = 200, -- Scroll to the left by 200px
        },
        noFadeIn = true,
        text = [[The newly-elected mayor,
Hyke Magger, promised to
clean up the city.]]
    },
    {
        {
            slide = slides,
            q = { 0, 120, 200, 120 },
            hScroll = 20, -- Scroll to the left by 100px
        },
        noFadeOut = true,
        text = [[Viewed as inefficient,
the waste collection service
got privatized by the mayor.]]
    },
    {
        {
            slide = slides,
            q = { 20, 120, 200, 120 },
            hScroll = 20, -- Scroll to the left by 100px
        },
        noFadeIn = true,
        text = [[The garbage collectors
in charge until then took
the blame and were fired.]]
    },
    {
        {
            slide = slides,
            q = { 0, 240, 240, 120 },
        },
        text = [[However, the situation only
got worse since then. Wild
rubbish dumps keep piling up.]]
    },
    {
        {
            slide = slides,
            q = { 0, 240, 240, 120 },
        },
        text = [[While insecurity is on the rise,
the ex-garbage collectors saw
their city turn into a landfill.]]
    },
    {
        {
            slide = slides,
            q = { 0, 360, 240, 120 },
        },
        text = [[Outraged and losing patience,
some of them decided to
stand up and take action.]]
    },
    {
        {
            slide = slides,
            q = { 0, 360, 240, 120 },
        },
        text = [[It's now or never!
Time to hit the streets
and take out the trash!]]
    },
    bgColor = { 0, 0, 0 },
    autoSkip = true,
    delayAfterFrame = 3, -- Wait after all the text is shown
    music = bgm.intro
}

