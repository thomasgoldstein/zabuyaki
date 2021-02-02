-- Intro Movie
local scene1 = love.graphics.newImage("res/img/misc/introScene1.png")
local scene2 = love.graphics.newImage("res/img/misc/introScene2.png")
local scene3 = love.graphics.newImage("res/img/misc/introScene3.png")
local scene4 = love.graphics.newImage("res/img/misc/introScene4.png")
local scene4animate = love.graphics.newImage("res/img/misc/introScene4tempAnim.png")
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
            slide = scene2,
            q = { 0, 0, 240, 160 }, -- bg yar
            hScroll = 60, -- Scroll to the left
        },
        {
            slide = scene2,
            q = { -40, 181, 240, 160 }, -- chai kisa
            hScroll = 100, -- Scroll to the left
        },
        {
            slide = scene2,
            q = { 0, 361, 240, 160 }, -- boss
            hScroll = 170, -- Scroll to the left
        },
        noFadeOut = true,
        text = [[Viewed as inefficient,
the waste collection service
got privatized by the mayor.]]
    },
    {
        {
            slide = scene2,
            q = { 60, 0, 240, 160 }, -- bg yar
            hScroll = 20, -- Scroll to the left
        },
        {
            slide = scene2,
            q = { 60, 181, 240, 160 }, -- chai kisa
            hScroll = 40, -- Scroll to the left
        },
        noFadeIn = true,
        text = [[The garbage collectors
in charge until then took
the blame and were fired.]]
    },


    {
        {
            slide = scene3,
            q = { 0, 0, 240, 160 }, -- bg
            hScroll = 30, -- Scroll to the left
        },
        {
            slide = scene3,
            q = { 0, 181, 240, 160 }, -- gopniks
            hScroll = 30, -- Scroll to the left
        },
        {
            slide = scene3,
            q = { 20, 361+ 20, 240, 160 }, -- beer
            vScroll = -10,
            hScroll = -10,
        },
        noFadeOut = true,
        text = [[However, the situation only
got worse since then. Wild
rubbish dumps keep piling up.]]
    },
    {
        {
            slide = scene3,
            q = { 30, 0, 240, 160 }, -- bg
            hScroll = 40, -- Scroll to the left
        },
        {
            slide = scene3,
            q = { 30, 181, 240, 160 }, -- gopniks
            hScroll = 40, -- Scroll to the left
        },
        {
            slide = scene3,
            q = { 10, 361 + 10, 240, 160 }, -- beer
            vScroll = -10,
            hScroll = -10,
        },
        noFadeIn = true,
        text = [[While insecurity is on the rise,
the ex-garbage collectors saw
their city turn into a landfill.]]
    },
    {
        {
            slide = scene4,
            q = { 40, 30, 240, 160 }, -- yar chai
            vScroll = -15,
            hScroll = -5,
        },
        {
            slide = scene4,
            q = { 30, 220, 240, 160 }, -- rick
            vScroll = -15,
            hScroll = 5,
        },
        {
            slide = scene4,
            q = { 40, 410, 240, 160 }, -- kisa
            vScroll = -12,
        },
        {
            slide = scene4animate,
            q = { 0, 0, 240, 160 },
            animate = "1 1 2 0.5"
        },
        noFadeOut = true,
        text = [[Outraged and losing patience,
some of them decided to
stand up and take action.]]
    },
    {
        {
            slide = scene4,
            q = { 40 - 5, 30 - 15, 240, 160 }, -- yar chai
            vScroll = -15,
            hScroll = -4,
        },
        {
            slide = scene4,
            q = { 30 + 5, 220 - 15, 240, 160 }, -- rick
            vScroll = -15,
            hScroll = 4,
        },
        {
            slide = scene4,
            q = { 40, 410 - 12, 240, 160 }, -- kisa
            vScroll = -12,
        },
        {
            slide = scene4animate,
            q = { 0, 0, 240, 160 },
            animate = "1 0.3 2 0.3 3 0.3 2 0.3"
        },
        noFadeIn = true,
        text = [[It's now or never!
Time to hit the streets
and take out the trash!]]
    },
    bgColor = { 0, 0, 0 },
    autoSkip = true,
    delayAfterFrame = 3, -- Wait after all the text is shown
    music = bgm.intro
}

