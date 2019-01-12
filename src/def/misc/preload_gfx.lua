-- Preload common gfx and fonts
local gfx = {loot = {}, ui = {}, font = {}}

local imageWidth, imageHeight
local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

gfx.loot.apple = getSpriteInstance("src/def/misc/apple")
gfx.loot.chicken = getSpriteInstance("src/def/misc/chicken")
gfx.loot.beef = getSpriteInstance("src/def/misc/beef")
gfx.loot.bat = getSpriteInstance("src/def/misc/bat")
gfx.loot.image = imageBank["res/img/misc/loot.png"] --for loot particles

local ui = love.graphics.newImage("res/img/misc/ui.png")
imageWidth, imageHeight = ui:getDimensions( )
gfx.ui.deadIcon = {sprite = ui, q = q(2,20,31,21), ox = 15, oy = 20 }
gfx.ui.leftSlant = {sprite = ui, q = q(2,2,12,16), ox = 0, oy = 0 }
gfx.ui.rightSlant = {sprite = ui, q = q(11,2,12,16), ox = 0, oy = 0 }
gfx.ui.middleSlant = {sprite = ui, q = q(10,2,4,16), ox = 0, oy = 0 }
gfx.ui.image = ui

gfx.font.clock = love.graphics.newFont( "res/font/Digital Dismay.otf", 46 )
gfx.font.clock:setFilter( "nearest", "nearest" )
--title Zabu logo
gfx.font.arcade2 = love.graphics.newFont( "res/font/arcade_i.ttf", 64 )
gfx.font.arcade2:setFilter( "nearest", "nearest" )
gfx.font.arcade2x15 = love.graphics.newFont( "res/font/arcade_i.ttf", 44 )
gfx.font.kimberley = love.graphics.newFont( "res/font/kimberley bl.ttf", 64 )
gfx.font.kimberley:setFilter( "nearest", "nearest" )
--info bars
gfx.font.arcade3 = love.graphics.newFont( "res/font/arcade_n.ttf", 8 )
gfx.font.arcade3:setFilter( "nearest", "nearest" )
gfx.font.arcade3x2 = love.graphics.newFont( "res/font/arcade_n.ttf", 16 )
gfx.font.arcade3x2:setFilter( "nearest", "nearest" )
gfx.font.arcade3x3 = love.graphics.newFont( "res/font/arcade_n.ttf", 24 )
gfx.font.arcade3x3:setFilter( "nearest", "nearest" )
--title - press space
gfx.font.arcade4 = love.graphics.newFont( "res/font/arcade_n.ttf", 16 )
gfx.font.arcade4:setFilter( "nearest", "nearest" )
gfx.font.arcade5 = love.graphics.newFont( "res/font/arcade_r.ttf", 16 )
--tiny font for debug info
gfx.font.debug = love.graphics.newFont( "res/font/slkscr.ttf", 7 )
gfx.font.debug:setFilter( "linear", "linear" )
return gfx
