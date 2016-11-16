shaders = {
    kisa = {},
    rick = {},
    chai = {},
    gopper = {},
    niko = {},
    satoff = {},
    trashcan = {},
    shadow = {}
}

-- use main.lua constant to disable shaders for web Love2d runtime
if not GLOBAL_SETTING.SHADERS_ENABLED then
    love.graphics.newShader = function()
        return {
            send = function() end,
            sendColor = function() end
        }
    end
    love.graphics.setShader = function() end
end

local sh_swap_colors = [[
        extern number n = 1;
        extern vec4 colors[16];
        extern vec4 newColors[16];
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
            vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
            for (int i = 0; i < n; i++) {
                if(pixel == colors[i])
                    return newColors[i] * color;
            }
            return pixel * color;
        }   ]]

--usage:
--local sh_player2 = love.graphics.newShader(sh_swap_colors)
--sh_player2:send("n", 3)
--sh_player2:sendColor("colors", {181, 81, 23, 255},  {122, 54, 15, 255},  {56, 27, 28, 255})
--sh_player2:sendColor("newColors", {77,111,158, 255},  {49,73,130, 255},  {28,42,73, 255})

local function swapColors(colors_default, alternate_colors)
    local colors_default = colors_default
    local alternate_colors = alternate_colors
    local shader = love.graphics.newShader(sh_swap_colors)
    shader:send("n", #colors_default - 1)
    shader:sendColor("colors", unpack(colors_default))
    shader:sendColor("newColors", unpack(alternate_colors))
    return shader
end

local sh_replace_3_colors = [[
        extern vec4 colors[3];
        extern vec4 newColors[3];
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
            vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
        if (pixel == colors[0])
            return newColors[0] * color;
        if (pixel == colors[1])
            return newColors[1] * color;
        if (pixel == colors[2])
            return newColors[2] * color;
        return pixel * color;
    }    ]]

--usage:
--local sh_player2 = love.graphics.newShader(sh_replace_3_colors)
--sh_player2:sendColor("colors", {181, 81, 23, 255},  {122, 54, 15, 255},  {56, 27, 28, 255})
--sh_player2:sendColor("newColors", {77,111,158, 255},  {49,73,130, 255},  {28,42,73, 255})

local sh_replace_4_colors = [[
        extern vec4 colors[4];
        extern vec4 newColors[4];
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
            vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
        if (pixel == colors[0])
            return newColors[0] * color;
        if (pixel == colors[1])
            return newColors[1] * color;
        if (pixel == colors[2])
            return newColors[2] * color;
        if (pixel == colors[3])
            return newColors[3] * color;
        return pixel * color;
    }    ]]

local sh_noise = love.graphics.newShader([[
extern float factor = 1;
extern float addPercent = 0.1;
extern float clamp = 0.85;

// from http://www.ozone3d.net/blogs/lab/20110427/glsl-random-generator/
float rand(vec2 n)
    {
        return 0.5 + 0.5 * fract(sin(dot(n.xy, vec2(12.9898, 78.233))) * 43758.5453);
    }

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc)
{
    float grey = 1 * rand(tc * factor);
    float clampedGrey = max(grey, clamp);
    vec4 noise = vec4(grey, grey, grey, 1);
    vec4 clampedNoise = vec4(clampedGrey, clampedGrey, clampedGrey, 1);
    return (Texel(tex, tc) * clampedNoise * (1 - addPercent) + noise * addPercent) * color;
}   ]])

local sh_screen = love.graphics.newShader([[
        vec4 effect(vec4 colour, Image image, vec2 local, vec2 screen)
        {
            // red and green scale with proportion of screen coordinates
            vec4 screen_colour = vec4(screen.x / 512.0,
                                      screen.y / 512.0,
                                      0.0,
                                      1.0);

            return screen_colour;
        }
    ]])

local sh_texture = love.graphics.newShader([[
        vec4 effect(vec4 colour, Image image, vec2 local, vec2 screen)
        {
            // red and green components scale with texture coordinates
            vec4 coord_colour = vec4(local.x, local.y, 0.0, 1.0);
            // use the appropriate pixel from the texture
            vec4 image_colour = Texel(image, local);
            // mix the two colours equally
            return mix(coord_colour, image_colour, 0.5);
        }
    ]])

--love_ScreenSize.x or love_ScreenSize.y
--vec4 love_ScreenSize
local sh_shadow = love.graphics.newShader([[
//        extern number id = 0;
        number y_offs = 0.5;
        number old_id = 100000;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
//            if (id != old_id) {
//                old_id = id;
//                y_offs = texture_coords.y;
            //}
            vec4 c = Texel(texture, texture_coords );
            if (c.a > 0)
               //return vec4( 0.0, 0.0, 0.0, 1 - (texture_coords.y - y_offs)/10 );
               return vec4( 0.0, 0.0, 0.0, 1.0 - screen_coords.y ) * color;
            return c;
        }
    ]])
shaders.shadow = sh_shadow

local sh_outline = love.graphics.newShader([[vec4 resultCol;
extern number stepSize;
number alpha;

vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
    {
        // get color of pixels:
alpha = texture2D( texture, texturePos + vec2(0,-stepSize)).a;
alpha -= texture2D( texture, texturePos + vec2(0,stepSize) ).a;

// calculate resulting color
resultCol = vec4( 1.0f, 1.0f, 1.0f, 0.5f*alpha );
// return color for current pixel
return resultCol;
}
]])

--sh_outline:send( "stepSize",{1/640,1/480} )

--Players
local rick_colors_default = {
    { 181, 81, 23, 255 }, { 122, 54, 15, 255 }, { 56, 27, 28, 255 }, -- orange hoodie
    { 53, 53, 53, 255 }, { 30, 30, 30, 255 }, { 15, 15, 15, 255 } } -- black pants
local rick_colors_2 = {
    { 188, 188, 188, 255 }, { 130, 130, 130, 255 }, { 73, 73, 73, 255 }, -- white hoodie
    { 39, 85, 135, 255 }, { 24, 53, 84, 255 }, { 11, 24, 38, 255 } } -- blue pants
local rick_colors_3 = {
    { 86, 135, 97, 255 }, { 47, 91, 63, 255 }, { 24, 53, 35, 255 }, -- green hoodie
    { 84, 75, 68, 255 }, { 51, 45, 41, 255 }, { 25, 22, 20, 255 } } -- gray pants
shaders.rick[2] = swapColors(rick_colors_default, rick_colors_2) --P2
shaders.rick[3] = swapColors(rick_colors_default, rick_colors_3) --P3

--Buggy START. Keep for Love2D bug report
local rick_colors_default0 = {"colors",
    { 181, 81, 23, 255 }, { 122, 54, 15, 255 }, { 56, 27, 28, 255 }, -- orange hoodie
    { 53, 53, 53, 255 }, { 30, 30, 30, 255 }, { 15, 15, 15, 255 } } -- black pants
local rick_colors_blue = { "newColors", { 77, 111, 158, 255 }, { 49, 73, 130, 255 }, { 28, 42, 73, 255 } } --Blue
local rick_colors_purple = { "newColors", { 111, 77, 158, 255 }, { 73, 49, 130, 255 }, { 42, 28, 73, 255 } } --Purple
local rick_colors_black = { "newColors", { 70, 70, 70, 255 }, { 45, 45, 45, 255 }, { 11, 11, 11, 255 } } --Black
local rick_colors_emerald = { "newColors", { 77, 158, 111, 255 }, { 49, 130, 73, 255 }, { 28, 73, 42, 255 } } --Emerald
local sh_rick4 = love.graphics.newShader(sh_replace_3_colors)
sh_rick4:sendColor(unpack(rick_colors_default0))
sh_rick4:sendColor(unpack(rick_colors_blue))
local sh_rick5 = love.graphics.newShader(sh_replace_3_colors)
sh_rick5:sendColor(unpack(rick_colors_default0))
sh_rick5:sendColor(unpack(rick_colors_purple))
local sh_rick6 = love.graphics.newShader(sh_replace_3_colors)
sh_rick6:sendColor(unpack(rick_colors_default0))
sh_rick6:sendColor(unpack(rick_colors_black))
local sh_rick7 = love.graphics.newShader(sh_replace_3_colors)
sh_rick7:sendColor(unpack(rick_colors_default0))
sh_rick7:sendColor(unpack(rick_colors_emerald))
shaders.rick[4] = sh_rick4 --Blue (3 colors)
shaders.rick[5] = sh_rick5 --Purple (3 colors)
shaders.rick[6] = sh_rick6 --Black (3 colors)
shaders.rick[7] = sh_rick7 --Emerald (3 colors)
--Buggy END

local chai_colors_default = {
    { 220, 206, 234, 255 }, { 145, 137, 153, 255 }, { 87, 82, 91, 255 }, -- gray bandages
    { 224, 208, 62, 255 }, { 158, 145, 34, 255 }, { 96, 71, 19, 255 }, -- yellow shirt
    { 126, 54, 130, 255 }, { 86, 11, 86, 255 }, { 33, 4, 33, 255 }, -- purple shorts
    { 51, 22, 27, 255 } } -- brown hair
local chai_colors_2 = {
    { 224, 208, 62, 255 }, { 158, 145, 34, 255 }, { 96, 71, 19, 255 }, -- yellow bandages
    { 193, 207, 244, 255 }, { 125, 142, 167, 255 }, { 65, 73, 86, 255 }, -- light blue shirt
    { 54, 104, 130, 255 }, { 11, 56, 86, 255 }, { 4, 21, 33, 255 }, -- teal shorts
    { 34, 29, 57, 255 } } -- purple hair
local chai_colors_3 = {
    { 226, 113, 113, 255 }, { 193, 44, 44, 255 }, { 112, 19, 19, 255 }, -- red bandages
    { 206, 196, 185, 255 }, { 154, 136, 119, 255 }, { 92, 72, 55, 255 }, -- light sepia shirt
    { 53, 53, 53, 255 }, { 30, 30, 30, 255 }, { 15, 15, 15, 255 }, -- black shorts
    { 51, 35, 22, 255 } } -- sand hair
shaders.chai[2] = swapColors(chai_colors_default, chai_colors_2)
shaders.chai[3] = swapColors(chai_colors_default, chai_colors_3)

local kisa_colors_default = {
    { 69, 145, 134, 255 }, { 45, 96, 92, 255 }, { 21, 45, 43, 255 }, -- teal hat
    { 133, 62, 65, 255 }, { 89, 39, 42, 255 }, { 41, 14, 16, 255 } } -- maroon shoes
local kisa_colors_2 = {
    { 76, 145, 55, 255 }, { 49, 91, 34, 255 }, { 19, 45, 24, 255 }, -- green hat
    { 127, 80, 53, 255 }, { 74, 52, 39, 255 }, { 35, 25, 19, 255 } } -- brown shoes
local kisa_colors_3 = {
    { 150, 90, 196, 255 }, { 92, 56, 122, 255 }, { 39, 23, 51, 255 }, -- lavander hat
    { 173, 100, 17, 255 }, { 99, 59, 9, 255 }, { 45, 26, 4, 255 } } -- orange-brown shoes
shaders.kisa[2] = swapColors(kisa_colors_default, kisa_colors_2)
shaders.kisa[3] = swapColors(kisa_colors_default, kisa_colors_3)

-- Enemy
local gopper_colors_default = {{51, 63, 105, 255 }, { 31, 41, 76, 255 }, { 19, 25, 40, 255 } }
local gopper_colors_2 = {{ 56, 84, 57, 255 }, { 35, 53, 36, 255 }, { 20, 30, 20, 255 } } --Green
local gopper_colors_3 = {{ 53, 53, 53, 255 }, { 30, 30, 30, 255 }, { 15, 15, 15, 255 } } --Black
local gopper_colors_4 = {{ 112, 48, 61, 255 }, { 73, 31, 40, 255 }, { 40, 17, 22, 255 } } --Red
shaders.gopper[2] = swapColors(gopper_colors_default, gopper_colors_2)
shaders.gopper[3] = swapColors(gopper_colors_default, gopper_colors_3)
shaders.gopper[4] = swapColors(gopper_colors_default, gopper_colors_4)

local niko_colors_default = {{ 222, 230, 239, 255 }, { 53, 53, 53, 255 }, { 30, 30, 30, 255 }, { 15, 15, 15, 255 }} --White, DarkGray, Dark
local niko_colors_2 = {{ 15, 15, 15, 255 }, { 198, 198, 198, 255 }, { 137, 137, 137, 255 }, { 84, 84, 84, 255 }} --Black, LightGray, Gray, DarkGray
shaders.niko[2] = swapColors(niko_colors_default, niko_colors_2)

local satoff_colors_default = {
    { 181, 47, 51, 255 }, { 119, 31, 34, 255 }, { 53, 20, 21, 255 }, -- red suit
    { 95, 40, 45, 255 }, { 55, 23, 28, 255 }, { 38, 16, 19, 255 }, -- maroon shoes
    { 51, 32, 29, 255 }, { 33, 20, 18, 255 }, { 22, 14, 12, 255 }, -- brown pants
    { 172, 129, 113, 255 }} -- face scar
local satoff_colors_2 = {
    { 62, 97, 145, 255 }, { 39, 61, 91, 255 }, { 19, 30, 45, 255 }, -- blue suit
    { 49, 53, 94, 255 }, { 29, 31, 56, 255 }, { 17, 18, 33, 255 }, -- midnight blue shoes
    { 37, 37, 48, 255 }, { 23, 23, 30, 255 }, { 16, 16, 21, 255 }, -- cool gray pants
    { 226, 173, 158, 255 }} -- no face scar
local satoff_colors_3 = {
    { 238, 227, 224, 255 }, { 173, 159, 150, 255 }, { 96, 88, 83, 255 }, -- white suit
    { 67, 55, 52, 255 }, { 39, 38, 35, 255 }, { 25, 21, 20, 255 }, -- taupe shoes
    { 111, 48, 119, 255 }, { 71, 31, 76, 255 }, { 43, 22, 45, 255 }, -- purple pants
    { 226, 173, 158, 255 }} -- no face scar
local satoff_colors_4 = {
    { 44, 44, 36, 255 }, { 29, 25, 22, 255 }, { 24, 17, 11, 255 }, -- black suit
    { 44, 44, 36, 255 }, { 29, 25, 22, 255 }, { 24, 17, 11, 255 }, -- black shoes
    { 160, 32, 62, 255 }, { 104, 20, 40, 255 }, { 56, 14, 24, 255 }, -- bordeaux pants
    { 226, 173, 158, 255 }} -- no face scar
shaders.satoff[2] = swapColors(satoff_colors_default, satoff_colors_2)
shaders.satoff[3] = swapColors(satoff_colors_default, satoff_colors_3)
shaders.satoff[4] = swapColors(satoff_colors_default, satoff_colors_4)

-- Obstacles
local trashcan_colors_default = {
    { 118, 109, 100, 255 }, { 89, 74, 72, 255 }, { 65, 44, 45, 255 }, { 30, 25, 23, 255 }, -- main color
    { 57, 76, 94, 255 }, { 40, 41, 35, 255 }, { 24, 25, 22, 255 }} -- inner bag color
local trashcan_colors_2 = {
    { 87, 116, 130, 255 }, { 63, 88, 99, 255 }, { 37, 55, 63, 255 }, { 20, 27, 30, 255 }, -- main color
    { 58, 91, 66, 255 }, { 37, 44, 36, 255 }, { 23, 26, 21, 255 }} -- inner bag color
shaders.trashcan[2] = swapColors(trashcan_colors_default, trashcan_colors_2)

-- Misc

return shaders