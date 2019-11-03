-- Visuals and SFX go here

local Enemy = Enemy

function Enemy:drawLivesLeftNumber()
    return self.lifeBar.lives > 1
end
