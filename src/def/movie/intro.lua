-- Date: 28.10.2016

-- Intro Movie
local slides = love.graphics.newImage("res/img/misc/intro.png")
movie_intro = {
    {
        {
            slide = slides,
            q = { 0, 0, 240, 120 }
        },
        text = [[Adigrad is a city ravaged
by crime and corruption,
leading to a garbage crisis.]]
    },
    {
        {
            slide = slides,
            q = { 0, 0, 240, 120 }
        },
        text = [[The newly-elected mayor,
Hyke Magger, promised to
clean up the city.]]
    },
    {
        {
            slide = slides,
            q = { 0, 120, 240, 120 }
        },
        text = [[Viewed as inefficient,
the waste collection service
got privatized by the mayor.]]
    },
    {
        {
            slide = slides,
            q = { 0, 120, 240, 120 },
        },
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

