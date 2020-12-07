-- The End Movie
local slides = love.graphics.newImage("res/img/misc/ending.png")
movie_ending = {
    {
        {
            slide = slides,
            q = { 0, 0, 240, 120 }
        },
        text = [[line1 _ _ _ _ _ _ _ _ _ _
line2 _ _ _ _ _ _ _ _ _ _
line3 _ _ _ _ _ _ _ _ _ _]]
    },
    {
        {
            slide = slides,
            q = { 0, 120, 240, 120 }
        },
        text = [[line1 _ _ _ _ _ _ _ _ _ _
line2 _ _ _ _ _ _ _ _ _ _
line3 _ _ _ _ _ _ _ _ _ _]]
    },
    {
        {
            slide = slides,
            q = { 0, 240, 240, 120 }
        },
        text = [[line1 _ _ _ _ _ _ _ _ _ _
line2 _ _ _ _ _ _ _ _ _ _
line3 _ _ _ _ _ _ _ _ _ _]]
    },
    {
        {
            slide = slides,
            q = { 0, 360, 240, 120 }
        },
        text = [[line1 _ _ _ _ _ _ _ _ _ _
line2 _ _ _ _ _ _ _ _ _ _
line3 _ _ _ _ _ _ _ _ _ _]]
    },
    bgColor = { 0, 0, 0 },
    autoSkip = true,
    delayAfterFrame = 3, -- Wait after all the text is shown
    music = bgm.zaburap
}
