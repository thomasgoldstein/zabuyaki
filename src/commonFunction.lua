--
-- Date: 25.11.2016
--

function printWithShadow(text, x, y, transp_bg)
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(0, 0, 0, transp_bg)
    love.graphics.print(text, x + 1, y - 1)
    love.graphics.setColor(r, g, b, a)
    love.graphics.print(text, x, y)
end
