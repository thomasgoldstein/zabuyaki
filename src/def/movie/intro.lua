-- Date: 25.10.2016

-- Intro Movie
local slide1 = love.graphics.newImage("res/img/stages/stage1/building1_V.png")
local slide1q = love.graphics.newQuad(60, 70, 200, 120, slide1:getDimensions())
movie_intro = {
    {
        slide = slide1,
        q = slide1q,
        text = "Long time ago there was\na country of SD gnomes...",
        delay = 5
    },
    {
        slide = slide1,
        q = love.graphics.newQuad(120, 130, 240, 80, slide1:getDimensions()),
        text = "and here GOES other text\nand more of it\n...",
        delay = 2
    },
    {
        slide = slide1,
        q = love.graphics.newQuad(180, 170, 100, 100, slide1:getDimensions()),
        text = "This is the last\nslide here..",
        delay = 1.5
    },
}
--self.movie = Movie:new(movie_intro)
--self.mode = "movie"