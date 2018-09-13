-- Copyright (c) .2017 SineDie
-- Visuals and SFX go here

local Enemy = Enemy

function Enemy:drawLivesLeftNumber()
    return self.lives > 1
end
