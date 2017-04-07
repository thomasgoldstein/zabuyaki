shaders = {
    kisa = {},
    rick = {},
    chai = {},
    gopper = {},
    niko = {},
    beatnick = {},
    sveta = {},
    zeena = {},
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

local function swapColors(colors_default, alternate_colors)
    local shader = love.graphics.newShader(sh_swap_colors)
    shader:send("n", #alternate_colors)
    alternate_colors[#alternate_colors+1] = {} --TODO: Remove on fix of Love2D 0.10.2 shaders send bug
    colors_default[#colors_default+1] = {} --Love2D 0.10.2 shaders send bug workaround
    shader:sendColor("colors", unpack(colors_default))
    shader:sendColor("newColors", unpack(alternate_colors))
    alternate_colors[#alternate_colors] = nil --Love2D 0.10.2 shaders send bug workaround
    colors_default[#colors_default] = nil --Love2D 0.10.2 shaders send bug workaround
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

local sh_screen = love.graphics.newShader [[
        vec4 effect(vec4 colour, Image image, vec2 local, vec2 screen)
        {
            // red and green scale with proportion of screen coordinates
            vec4 screen_colour = vec4(screen.x / 512.0,
                                      screen.y / 512.0,
                                      0.0,
                                      1.0);

            return screen_colour;
        }
    ]]

local sh_CGA_screen = love.graphics.newShader [[
extern number screenWidth;
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
    number average = (pixel.r+pixel.b+pixel.g)/3.0;
    number factor = screen_coords.x/screenWidth;
    pixel.r = pixel.r + (average-pixel.r) * factor;
    pixel.g = pixel.g + (average-pixel.g) * factor;
    pixel.b = pixel.b + (average-pixel.b) * factor;
    return pixel;
}
]]

local sh_voronoice = love.graphics.newShader [[
extern float time;

vec3 hash3( vec2 p )
{
    vec3 q = vec3( dot(p,vec2(127.1,311.7)),
				   dot(p,vec2(269.5,183.3)),
				   dot(p,vec2(419.2,371.9)) );
	return fract(sin(q)*43758.5453);
}

vec4 effect(vec4 vcolor, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
  vec2 size = vec2(800.0, 600.0); // screen size
  vec2 scaledSize = size/10.0;
	vec2 x = scaledSize * texture_coords;

  float u = 0.375*sin(time/2); // amount of 'voronoiification'
  vec2 p = floor(x);
  vec2 f = fract(x);

	float k = 64.0;

  float va = 0.0;
	float wt = 0.0;
    for( int j=-2; j<=2; j++ )
        for( int i=-2; i<=2; i++ )
        {
            vec2 g = vec2( (i+0.5),(j+0.5) );
            vec3 o = hash3( p + g )*vec3(u,u,1.0);
            vec2 r = g - f + o.xy;
            float d = dot(r,r);
            float ww = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
            va += o.z*ww;
            wt += ww;
        }

  float c = va/wt;

  vec4 txl = Texel(texture, texture_coords);


	return vec4( c, c, c, 1.0 );
}
]]

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
    { 196, 81, 15, 255 }, { 133, 55, 10, 255 }, { 60, 27, 28, 255 }, -- orange hoodie
    { 55, 55, 55, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 } } -- black pants
local rick_colors_2 = {
    { 196, 196, 196, 255 }, { 135, 135, 135, 255 }, { 76, 76, 76, 255 }, -- white hoodie
    { 37, 90, 147, 255 }, { 23, 56, 92, 255 }, { 10, 25, 41, 255 } } -- blue pants
local rick_colors_3 = {
    { 86, 142, 99, 255 }, { 46, 97, 65, 255 }, { 22, 55, 35, 255 }, -- green hoodie
    { 89, 78, 70, 255 }, { 53, 46, 41, 255 }, { 26, 22, 20, 255 } } -- gray pants
shaders.rick[2] = swapColors(rick_colors_default, rick_colors_2)
shaders.rick[3] = swapColors(rick_colors_default, rick_colors_3)

local chai_colors_default = {
    { 236, 217, 50, 255 }, { 166, 151, 23, 255 }, { 103, 74, 14, 255 }, -- yellow shirt
    { 135, 52, 140, 255 }, { 94, 8, 94, 255 }, { 36, 3, 36, 255 }, -- purple shorts
    { 230, 214, 246, 255 }, { 150, 141, 160, 255 }, { 90, 85, 95, 255 }, -- gray bandages
    { 55, 21, 27, 255 } } -- brown hair
local chai_colors_2 = {
    { 199, 216, 255, 255 }, { 128, 148, 176, 255 }, { 67, 76, 91, 255 }, -- light blue shirt
    { 52, 109, 139, 255 }, { 7, 59, 94, 255 }, { 2, 21, 35, 255 }, -- teal shorts
    { 236, 217, 50, 255 }, { 166, 151, 23, 255 }, { 103, 74, 14, 255 }, -- yellow bandages
    { 35, 30, 62, 255 } } -- purple hair
local chai_colors_3 = {
    { 217, 205, 192, 255 }, { 161, 140, 121, 255 }, { 97, 74, 54, 255 }, -- light sepia shirt
    { 53, 53, 53, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- black shorts
    { 244, 114, 114, 255 }, { 213, 41, 41, 255 }, { 123, 16, 16, 255 }, -- red bandages
    { 54, 35, 20, 255 } } -- sand hair
shaders.chai[2] = swapColors(chai_colors_default, chai_colors_2)
shaders.chai[3] = swapColors(chai_colors_default, chai_colors_3)

local kisa_colors_default = {
    { 66, 153, 140, 255 }, { 43, 101, 97, 255 }, { 20, 47, 45, 255 }, -- teal headscarf
    { 238, 213, 129, 255 }, { 182, 157, 73, 255 }, { 96, 83, 35, 255 } } -- sand shirt
local kisa_colors_2 = {
    { 219, 93, 67, 255 }, { 160, 49, 27, 255 }, { 81, 17, 4, 255 }, -- red-orange headscarf
    { 234, 198, 79, 255 }, { 193, 136, 23, 255 }, { 122, 69, 9, 255 } } -- yellow-orange shirt
local kisa_colors_3 = {
    { 175, 202, 221, 255 }, { 80, 150, 196, 255 }, { 39, 79, 107, 255 }, -- sky blue headscarf
    { 101, 105, 216, 255 }, { 59, 63, 145, 255 }, { 26, 27, 56, 255 } } -- violet-blue shirt
shaders.kisa[2] = swapColors(kisa_colors_default, kisa_colors_2)
shaders.kisa[3] = swapColors(kisa_colors_default, kisa_colors_3)

-- Enemies
local gopper_colors_default = {
    { 233, 230, 246, 255 }, { 175, 163, 199, 255 }, { 107, 100, 121, 255 }, -- white top
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue pants
    { 110, 113, 118, 255 }, { 84, 86, 90, 255 }, -- top gray stripes
    { 231, 240, 251, 255 }, { 168, 175, 182, 255 }, -- bottom white stripes
    { 55, 55, 55, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 } } -- black shoes
local gopper_colors_2 = {
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue top
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue pants
    { 231, 240, 251, 255 }, { 168, 175, 182, 255 } } -- top white stripes
local gopper_colors_3 = {
    { 57, 89, 58, 255 }, { 35, 55, 36, 255 }, { 20, 31, 20, 255 }, -- green top
    { 57, 89, 58, 255 }, { 35, 55, 36, 255 }, { 20, 31, 20, 255 }, -- green pants
    { 231, 240, 251, 255 }, { 168, 175, 182, 255 } } -- top white stripes
local gopper_colors_4 = {
    { 55, 55, 55, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- black top
    { 55, 55, 55, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- black pants
    { 231, 240, 251, 255 }, { 168, 175, 182, 255 } } -- top white stripes
local gopper_colors_5 = {
    { 122, 48, 63, 255 }, { 78, 30, 40, 255 }, { 42, 16, 22, 255 }, -- red top
    { 122, 48, 63, 255 }, { 78, 30, 40, 255 }, { 42, 16, 22, 255 }, -- red pants
    { 231, 240, 251, 255 }, { 168, 175, 182, 255 } } -- top white stripes
shaders.gopper[2] = swapColors(gopper_colors_default, gopper_colors_2)
shaders.gopper[3] = swapColors(gopper_colors_default, gopper_colors_3)
shaders.gopper[4] = swapColors(gopper_colors_default, gopper_colors_4)
shaders.gopper[5] = swapColors(gopper_colors_default, gopper_colors_5)

local niko_colors_default = gopper_colors_default
local niko_colors_2 = gopper_colors_2
local niko_colors_3 = {
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue top
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue pants
    { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- top black stripes
    { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- bottom black stripes
    { 207, 207, 207, 255 }, { 142, 142, 142, 255 }, { 87, 87, 87, 255 } } -- white shoes
shaders.niko[2] = swapColors(niko_colors_default, niko_colors_2)
shaders.niko[3] = swapColors(niko_colors_default, niko_colors_3)

local sveta_colors_default = {
    { 138, 142, 149, 255 }, { 64, 78, 120, 255 }, { 32, 43, 65, 255 }, -- blue-gray vest
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue pants
    { 165, 124, 69, 255 }, { 133, 77, 17, 255 }, { 56, 37, 29, 255 } } -- chestnut hair
local sveta_colors_2 = {
    { 138, 142, 149, 255 }, { 64, 78, 120, 255 }, { 32, 43, 65, 255 }, -- blue-gray vest
    { 55, 55, 55, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 } } -- black pants
shaders.sveta[2] = swapColors(sveta_colors_default, sveta_colors_2)

local zeena_colors_default = {
    { 138, 142, 149, 255 }, { 64, 78, 120, 255 }, { 32, 43, 65, 255 }, -- blue-gray vest
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue pants
    { 165, 124, 69, 255 }, { 133, 77, 17, 255 }, { 56, 37, 29, 255 } } -- chestnut hair
local zeena_colors_2 = {
    { 245, 171, 196, 255 }, { 176, 103, 146, 255 }, { 83, 42, 102, 255 }, -- pink vest
    { 55, 55, 55, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- black pants
    { 50, 67, 93, 255 }, { 18, 30, 80, 255 }, { 16, 12, 53, 255 } } -- dark blue hair
shaders.zeena[2] = swapColors(zeena_colors_default, zeena_colors_2)

shaders.beatnick[2] = nil

local satoff_colors_default = {
    { 199, 45, 50, 255 }, { 130, 29, 33, 255 }, { 58, 20, 21, 255 }, -- red suit
    { 102, 39, 45, 255 }, { 59, 22, 28, 255 }, { 41, 16, 19, 255 }, -- maroon shoes
    { 54, 32, 29, 255 }, { 35, 20, 17, 255 }, { 23, 13, 11, 255 }, -- brown pants
    { 181, 132, 113, 255 }} -- face scar
local satoff_colors_2 = {
    { 61, 101, 156, 255 }, { 39, 64, 98, 255 }, { 19, 31, 48, 255 }, -- blue suit
    { 50, 55, 102, 255 }, { 29, 31, 60, 255 }, { 17, 18, 35, 255 }, -- midnight blue shoes
    { 38, 38, 50, 255 }, { 23, 23, 31, 255 }, { 16, 16, 22, 255 }, -- cool gray pants
    { 239, 179, 161, 255 }} -- no face scar
local satoff_colors_3 = {
    { 250, 237, 234, 255 }, { 181, 165, 155, 255 }, { 101, 92, 86, 255 }, -- white suit
    { 70, 56, 53, 255 }, { 41, 40, 36, 255 }, { 25, 20, 19, 255 }, -- taupe shoes
    { 120, 48, 129, 255 }, { 76, 30, 82, 255 }, { 46, 22, 49, 255 }, -- purple pants
    { 239, 179, 161, 255 }} -- no face scar
local satoff_colors_4 = {
    { 45, 45, 36, 255 }, { 30, 25, 22, 255 }, { 25, 17, 10, 255 }, -- black suit
    { 45, 45, 36, 255 }, { 30, 25, 22, 255 }, { 25, 17, 10, 255 }, -- black shoes
    { 176, 29, 64, 255 }, { 114, 18, 41, 255 }, { 62, 13, 25, 255 }, -- bordeaux pants
    { 239, 179, 161, 255 }} -- no face scar
shaders.satoff[2] = swapColors(satoff_colors_default, satoff_colors_2)
shaders.satoff[3] = swapColors(satoff_colors_default, satoff_colors_3)
shaders.satoff[4] = swapColors(satoff_colors_default, satoff_colors_4)

-- Obstacles
local trashcan_colors_default = {
    { 118, 109, 100, 255 }, { 96, 81, 78, 255 }, { 73, 53, 54, 255 }, { 40, 30, 30, 255 }, -- brown metal
    { 60, 80, 99, 255 }, { 49, 51, 43, 255 }, { 29, 30, 26, 255 }} -- inner blue bag
local trashcan_colors_2 = {
    { 87, 116, 130, 255 }, { 66, 93, 104, 255 }, { 45, 66, 76, 255 }, { 27, 36, 40, 255 }, -- blue metal
    { 63, 91, 72, 255 }, { 45, 53, 43, 255 }, { 29, 33, 26, 255 }} -- inner green bag
shaders.trashcan[2] = swapColors(trashcan_colors_default, trashcan_colors_2)

-- Misc

local function load_frag_shader(file)
    --dp(".frag shader file loading: "..file)
    local s = love.filesystem.read("src/def/misc/shaders/"..file)
    return love.graphics.newShader(s)
end

--["textureSize"] = {po2xr/scale, po2yr/scale},
-- ["textureSizeReal"] = {po2xr, po2yr},
--["inputSize"] = {shaders.xres/scale, shaders.yres/scale},
--["outputSize"] = {shaders.xres, shaders.yres},
--["time"] = love.timer.getTime()

shaders.screen = {
    { name = "HDR-TV", shader = load_frag_shader("HDR-TV.frag"),
        func = nil },
    { name = "CRT-Simple", shader = load_frag_shader("CRT-Simple.frag"),
        func = function(shader)
            shader:send('inputSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
            shader:send('outputSize', {love.graphics.getWidth(), love.graphics.getHeight()})
            shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
        end },
    { name = "CRT", shader = load_frag_shader("CRT.frag"),
        func = function(shader)
            shader:send('inputSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
            shader:send('outputSize', {love.graphics.getWidth(), love.graphics.getHeight()})
            shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
        end },
    { name = "curvature", shader = load_frag_shader("curvature.frag"),
        func = function(shader)
            shader:send('inputSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
            shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
        end },
    { name = "4xBR", shader = load_frag_shader("4xBR.frag"),
        func = function(shader)
            shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
        end },
    { name = "phosphor", shader = load_frag_shader("phosphor.frag"),
        func = function(shader)
            shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
        end },
    { name = "phosphorish", shader = load_frag_shader("phosphorish.frag"),
        func = function(shader)
            shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
        end },
    { name = "scanlines2", shader = load_frag_shader("scanlines2.frag"),
        func = function(shader)
            shader:send('inputSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
            shader:send('outputSize', {love.graphics.getWidth(), love.graphics.getHeight()})
            shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
        end },
    { name = "scanline-3x", shader = load_frag_shader("scanline-3x.frag"),
        func = nil },
    { name = "scanline-4x", shader = load_frag_shader("scanline-4x.frag"),
        func = nil },
    { name = "hq4x", shader = load_frag_shader("hq4x.frag"),
        func = function(shader)
            shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
        end }
}
GLOBAL_SETTING.FILTER_N = 0
for i = #shaders.screen, 1, -1 do
    if GLOBAL_SETTING.FILTER == shaders.screen[i].name then
        GLOBAL_SETTING.FILTER_N = i
    end
end

return shaders