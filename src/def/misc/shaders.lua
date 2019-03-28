shaders = {
    rick = {},
    kisa = {},
    chai = {},
    yar = {},
    gopper = {},
    niko = {},
    sveta = {},
    zeena = {},
    beatnick = {},
    satoff = {},
    trashcan = {},
    trashcan_particleColor = {},
    shadow = {}
}

getShader = function(name, n)
    --print("shaders.get",name,n)
    if shaders[name] then
        --print("ok ", shaders[name][n or 1])
        return shaders[name][n or 1]
    end
    return nil
end

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

local sh_swapColors = [[
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

local function swapColors(originalColors, alternativeColors)
    local shader = love.graphics.newShader(sh_swapColors)
    shader:send("n", #alternativeColors)
    alternativeColors[#alternativeColors+1] = {} --TODO: Remove on fix of Love2D 0.10.2 shaders send bug
    originalColors[#originalColors+1] = {} --Love2D 0.10.2 shaders send bug workaround
    shader:sendColor("colors", unpack(originalColors))
    shader:sendColor("newColors", unpack(alternativeColors))
    alternativeColors[#alternativeColors] = nil --Love2D 0.10.2 shaders send bug workaround
    originalColors[#originalColors] = nil --Love2D 0.10.2 shaders send bug workaround
    return shader
end

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

--Players
local rickColors_original = {
    { 196, 81, 15, 255 }, { 133, 55, 10, 255 }, { 60, 27, 28, 255 }, -- orange hoodie
    { 55, 55, 55, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- black pants
    { 99, 132, 168, 255 }, { 52, 78, 108, 255 }, { 20, 27, 40, 255 }, -- blue shoes
    { 217, 217, 217, 255 }, { 155, 162, 170, 255 }, { 98, 102, 107, 255 } } -- white shoe stripes
local rickColors_2 = {
    { 196, 196, 196, 255 }, { 135, 135, 135, 255 }, { 76, 76, 76, 255 }, -- white hoodie
    { 56, 91, 149, 255 }, { 29, 53, 97, 255 }, { 16, 25, 56, 255 }, -- blue pants
    { 196, 196, 196, 255 }, { 135, 135, 135, 255 }, { 76, 76, 76, 255 }, -- white shoes
    { 56, 91, 149, 255 }, { 29, 53, 97, 255 }, { 16, 25, 56, 255 } } -- blue shoe stripes
local rickColors_3 = {
    { 51, 58, 76, 255 }, { 27, 31, 40, 255 }, { 11, 13, 17, 255 }, -- black hoodie
    { 174, 183, 188, 255 }, { 96, 101, 107, 255 }, { 48, 50, 53, 255 }, -- light gray pants
    { 193, 57, 50, 255 }, { 137, 21, 15, 255 }, { 53, 8, 5, 255 } } -- red shoes

local kisaColors_original = {
    { 66, 153, 140, 255 }, { 43, 101, 97, 255 }, { 20, 47, 45, 255 }, -- teal headscarf
    { 238, 213, 129, 255 }, { 182, 157, 73, 255 }, { 96, 83, 35, 255 } } -- sand shirt
local kisaColors_2 = {
    { 219, 93, 67, 255 }, { 160, 49, 27, 255 }, { 81, 17, 4, 255 }, -- red-orange headscarf
    { 234, 198, 79, 255 }, { 193, 136, 23, 255 }, { 122, 69, 9, 255 } } -- yellow-orange shirt
local kisaColors_3 = {
    { 175, 202, 221, 255 }, { 80, 150, 196, 255 }, { 39, 79, 107, 255 }, -- sky blue headscarf
    { 101, 105, 216, 255 }, { 59, 63, 145, 255 }, { 26, 27, 56, 255 } } -- violet-blue shirt

local chaiColors_original = {
    { 236, 217, 50, 255 }, { 166, 151, 23, 255 }, { 103, 74, 14, 255 }, -- yellow shirt
    { 135, 52, 140, 255 }, { 94, 8, 94, 255 }, { 36, 3, 36, 255 }, -- purple shorts
    { 230, 214, 246, 255 }, { 150, 141, 160, 255 }, { 90, 85, 95, 255 }, -- gray bandages
    { 55, 21, 27, 255 } } -- brown hair
local chaiColors_2 = {
    { 199, 216, 255, 255 }, { 128, 148, 176, 255 }, { 67, 76, 91, 255 }, -- light blue shirt
    { 52, 109, 139, 255 }, { 7, 59, 94, 255 }, { 2, 21, 35, 255 }, -- teal shorts
    { 236, 217, 50, 255 }, { 166, 151, 23, 255 }, { 103, 74, 14, 255 }, -- yellow bandages
    { 35, 30, 62, 255 } } -- purple hair
local chaiColors_3 = {
    { 217, 205, 192, 255 }, { 161, 140, 121, 255 }, { 97, 74, 54, 255 }, -- light sepia shirt
    { 53, 53, 53, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- black shorts
    { 244, 114, 114, 255 }, { 213, 41, 41, 255 }, { 123, 16, 16, 255 }, -- red bandages
    { 54, 35, 20, 255 } } -- sand hair

local yarColors_original = {
    { 34, 72, 91, 255 }, { 30, 36, 40, 255 }, { 17, 20, 22, 255 }, -- black fur
    { 244, 238, 235, 255 }, { 206, 178, 117, 255 }, { 135, 116, 77, 255 }, -- white chest mark
    { 218, 40, 52, 255 }, { 141, 10, 12, 255 }, { 63, 4, 6, 255 } } -- red shoes
local yarColors_2 = {
    { 237, 220, 190, 255 }, { 123, 142, 153, 255 }, { 47, 70, 86, 255 }, -- white fur
    { 237, 220, 190, 255 }, { 123, 142, 153, 255 }, { 47, 70, 86, 255 }, -- white chest mark
    { 79, 145, 226, 255 }, { 29, 81, 145, 255 }, { 13, 38, 68, 255 } } -- blue shoes
local yarColors_3 = {
    { 137, 80, 30, 255 }, { 63, 35, 16, 255 }, { 29, 14, 19, 255 }, -- brown fur
    { 137, 80, 30, 255 }, { 63, 35, 16, 255 }, { 29, 14, 19, 255 }, -- brown chest mark
    { 255, 187, 43, 255 }, { 196, 97, 27, 255 }, { 91, 36, 14, 255 } } -- yellow shoes

-- Enemies
local gopperColors_original = {
    { 233, 230, 246, 255 }, { 175, 163, 199, 255 }, { 107, 100, 121, 255 }, -- white top
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue pants
    { 110, 113, 118, 255 }, { 84, 86, 90, 255 }, -- top gray stripes
    { 231, 240, 251, 255 }, { 168, 175, 182, 255 }, -- bottom white stripes
    { 55, 55, 55, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 } } -- black shoes
local gopperColors_2 = {
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue top
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue pants
    { 231, 240, 251, 255 }, { 168, 175, 182, 255 } } -- top white stripes
local gopperColors_3 = {
    { 57, 89, 58, 255 }, { 35, 55, 36, 255 }, { 20, 31, 20, 255 }, -- green top
    { 57, 89, 58, 255 }, { 35, 55, 36, 255 }, { 20, 31, 20, 255 }, -- green pants
    { 231, 240, 251, 255 }, { 168, 175, 182, 255 } } -- top white stripes
local gopperColors_4 = {
    { 55, 55, 55, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- black top
    { 55, 55, 55, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- black pants
    { 231, 240, 251, 255 }, { 168, 175, 182, 255 } } -- top white stripes
local gopperColors_5 = {
    { 122, 48, 63, 255 }, { 78, 30, 40, 255 }, { 42, 16, 22, 255 }, -- red top
    { 122, 48, 63, 255 }, { 78, 30, 40, 255 }, { 42, 16, 22, 255 }, -- red pants
    { 231, 240, 251, 255 }, { 168, 175, 182, 255 } } -- top white stripes

local nikoColors_original = gopperColors_original
local nikoColors_2 = gopperColors_2
local nikoColors_3 = {
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue top
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue pants
    { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- top black stripes
    { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- bottom black stripes
    { 207, 207, 207, 255 }, { 142, 142, 142, 255 }, { 87, 87, 87, 255 } } -- white shoes

local svetaColors_original = {
    { 138, 142, 149, 255 }, { 64, 78, 120, 255 }, { 32, 43, 65, 255 }, -- blue-gray vest
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue pants
    { 165, 124, 69, 255 }, { 133, 77, 17, 255 }, { 56, 37, 29, 255 } } -- chestnut hair
local svetaColors_2 = {
    { 138, 142, 149, 255 }, { 64, 78, 120, 255 }, { 32, 43, 65, 255 }, -- blue-gray vest
    { 55, 55, 55, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 } } -- black pants

local zeenaColors_original = {
    { 138, 142, 149, 255 }, { 64, 78, 120, 255 }, { 32, 43, 65, 255 }, -- blue-gray vest
    { 51, 65, 113, 255 }, { 31, 42, 83, 255 }, { 19, 26, 43, 255 }, -- blue pants
    { 165, 124, 69, 255 }, { 133, 77, 17, 255 }, { 56, 37, 29, 255 } } -- chestnut hair
local zeenaColors_2 = {
    { 245, 171, 196, 255 }, { 176, 103, 146, 255 }, { 83, 42, 102, 255 }, -- pink vest
    { 55, 55, 55, 255 }, { 31, 31, 31, 255 }, { 15, 15, 15, 255 }, -- black pants
    { 50, 67, 93, 255 }, { 18, 30, 80, 255 }, { 16, 12, 53, 255 } } -- dark blue hair

local satoffColors_original = {
    { 199, 45, 50, 255 }, { 130, 29, 33, 255 }, { 58, 20, 21, 255 }, -- red suit
    { 102, 39, 45, 255 }, { 59, 22, 28, 255 }, { 41, 16, 19, 255 }, -- maroon shoes
    { 54, 32, 29, 255 }, { 35, 20, 17, 255 }, { 23, 13, 11, 255 }, -- brown pants
    { 181, 132, 113, 255 }} -- face scar
local satoffColors_2 = {
    { 61, 101, 156, 255 }, { 39, 64, 98, 255 }, { 19, 31, 48, 255 }, -- blue suit
    { 50, 55, 102, 255 }, { 29, 31, 60, 255 }, { 17, 18, 35, 255 }, -- midnight blue shoes
    { 38, 38, 50, 255 }, { 23, 23, 31, 255 }, { 16, 16, 22, 255 }, -- cool gray pants
    { 239, 179, 161, 255 }} -- no face scar
local satoffColors_3 = {
    { 250, 237, 234, 255 }, { 181, 165, 155, 255 }, { 101, 92, 86, 255 }, -- white suit
    { 70, 56, 53, 255 }, { 41, 40, 36, 255 }, { 25, 20, 19, 255 }, -- taupe shoes
    { 120, 48, 129, 255 }, { 76, 30, 82, 255 }, { 46, 22, 49, 255 }, -- purple pants
    { 239, 179, 161, 255 }} -- no face scar
local satoffColors_4 = {
    { 45, 45, 36, 255 }, { 30, 25, 22, 255 }, { 25, 17, 10, 255 }, -- black suit
    { 45, 45, 36, 255 }, { 30, 25, 22, 255 }, { 25, 17, 10, 255 }, -- black shoes
    { 176, 29, 64, 255 }, { 114, 18, 41, 255 }, { 62, 13, 25, 255 }, -- bordeaux pants
    { 239, 179, 161, 255 }} -- no face scar
-- Stage Objects
local trashcanColors_original = {
    { 118, 109, 100, 255 }, { 96, 81, 78, 255 }, { 73, 53, 54, 255 }, { 40, 30, 30, 255 }, -- brown metal
    { 60, 80, 99, 255 }, { 49, 51, 43, 255 }, { 29, 30, 26, 255 }} -- inner blue bag
local trashcanColors_2 = {
    { 87, 116, 130, 255 }, { 66, 93, 104, 255 }, { 45, 66, 76, 255 }, { 27, 36, 40, 255 }, -- blue metal
    { 63, 91, 72, 255 }, { 45, 53, 43, 255 }, { 29, 33, 26, 255 }} -- inner green bag
-- Misc

local function load_frag_shader(file)
    --dp(".frag shader file loading: "..file)
    local s = love.filesystem.read("src/def/misc/shaders/"..file)
    return love.graphics.newShader(s)
end

--["textureSize"] = {po2xr/scale, po2yr/scale},
--["textureSizeReal"] = {po2xr, po2yr},
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

--local name = "Rick"
--name = name:lower()
--print(name, getShader(name, 2))

function reloadShaders()
    --print("reloadShaders")
    shaders.rick[1] = swapColors(rickColors_original, rickColors_2)
    shaders.rick[2] = swapColors(rickColors_original, rickColors_3)
    shaders.kisa[1] = swapColors(kisaColors_original, kisaColors_2)
    shaders.kisa[2] = swapColors(kisaColors_original, kisaColors_3)
    shaders.chai[1] = swapColors(chaiColors_original, chaiColors_2)
    shaders.chai[2] = swapColors(chaiColors_original, chaiColors_3)
    shaders.yar[1] = swapColors(yarColors_original, yarColors_2)
    shaders.yar[2] = swapColors(yarColors_original, yarColors_3)
    shaders.gopper[1] = swapColors(gopperColors_original, gopperColors_2)
    shaders.gopper[2] = swapColors(gopperColors_original, gopperColors_3)
    shaders.gopper[3] = swapColors(gopperColors_original, gopperColors_4)
    shaders.gopper[4] = swapColors(gopperColors_original, gopperColors_5)
    shaders.niko[1] = swapColors(nikoColors_original, nikoColors_2)
    shaders.niko[2] = swapColors(nikoColors_original, nikoColors_3)
    shaders.sveta[1] = swapColors(svetaColors_original, svetaColors_2)
    shaders.zeena[1] = swapColors(zeenaColors_original, zeenaColors_2)
    shaders.beatnick[1] = nil
    shaders.satoff[2] = swapColors(satoffColors_original, satoffColors_2)
    shaders.satoff[3] = swapColors(satoffColors_original, satoffColors_3)
    shaders.satoff[4] = swapColors(satoffColors_original, satoffColors_4)
    shaders.trashcan[1] = swapColors(trashcanColors_original, trashcanColors_2)
    shaders.trashcan_particleColor[0] = { 118, 109, 100, 255 }
    shaders.trashcan_particleColor[1] = { 87, 116, 130, 255 }
end
--reloadShaders()

return shaders
