sh_replace_3_colors = [[
        extern vec4 colors[3];
        extern vec4 newColors[3];
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
            vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
        if (pixel == colors[0])
            return newColors[0];
        if (pixel == colors[1])
            return newColors[1];
        if (pixel == colors[2])
            return newColors[2];
        return pixel;
    }    ]]

--usage:
--local sh_player2 = love.graphics.newShader(sh_replace_3_colors)
--sh_player2:sendColor("colors", {181, 81, 23, 255},  {122, 54, 15, 255},  {56, 27, 28, 255})
--sh_player2:sendColor("newColors", {77,111,158, 255},  {49,73,130, 255},  {28,42,73, 255})

