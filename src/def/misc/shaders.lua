shaders = {
    rick = {},
    kisa = {},
    chai = {},
    yar = {},
    gopper = {},
    niko = {},
    sveta = {},
    zeena = {},
    beatnik = {},
    satoff = {},
    drVolker = {},
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
    { 216, 84, 8, 255 }, { 160, 25, 52, 255 }, { 63, 1, 9, 255 }, -- orange-red hoodie
    { 40, 60, 84, 255 }, { 36, 25, 25, 255 }, { 16, 8, 2, 255 }, -- black pants
    { 50, 150, 252, 255 }, { 30, 75, 180, 255 }, { 0, 22, 82, 255 }, -- blue shoes
    { 250, 252, 255, 255 }, { 196, 206, 218, 255 }, { 128, 134, 151, 255 } } -- white shoe stripes
local rickColors_2 = {
    { 245, 240, 245, 255 }, { 174, 154, 174, 255 }, { 86, 86, 86, 255 }, -- white hoodie
    { 20, 85, 128, 255 }, { 7, 32, 92, 255 }, { 4, 6, 46, 255 }, -- blue pants
    { 245, 240, 245, 255 }, { 174, 154, 174, 255 }, { 86, 86, 86, 255 }, -- white shoes
    { 20, 85, 128, 255 }, { 7, 32, 92, 255 }, { 4, 6, 46, 255 } } -- blue shoe stripes
local rickColors_3 = {
    { 42, 52, 77, 255 }, { 15, 21, 34, 255 }, { 2, 3, 6, 255 }, -- black hoodie
    { 211, 223, 230, 255 }, { 108, 115, 124, 255 }, { 48, 50, 54, 255 }, -- light gray pants
    { 234, 26, 26, 255 }, { 127, 10, 10, 255 }, { 44, 2, 1, 255 } } -- red shoes

local kisaColors_original = {
    { 57, 185, 125, 255 }, { 31, 110, 105, 255 }, { 6, 44, 41, 255 }, -- teal headscarf
    { 250, 244, 136, 255 }, { 212, 177, 62, 255 }, { 105, 87, 21, 255 } } -- sand shirt
local kisaColors_2 = {
    { 236, 85, 17, 255 }, { 161, 13, 8, 255 }, { 73, 0, 0, 255 }, -- orange-red headscarf
    { 249, 226, 63, 255 }, { 217, 139, 30, 255 }, { 127, 54, 8, 255 } } -- yellow-orange shirt
local kisaColors_3 = {
    { 201, 238, 246, 255 }, { 81, 184, 239, 255 }, { 12, 87, 137, 255 }, -- sky blue headscarf
    { 65, 71, 223, 255 }, { 23, 29, 142, 255 }, { 6, 7, 47, 255 } } -- violet-blue shirt

local chaiColors_original = {
    { 255, 255, 63, 255 }, { 204, 146, 38, 255 }, { 96, 58, 8, 255 }, -- yellow shirt
    { 157, 20, 188, 255 }, { 66, 0, 181, 255 }, { 20, 0, 30, 255 }, -- purple shorts
    { 252, 248, 255, 255 }, { 162, 175, 220, 255 }, { 106, 98, 113, 255 }, -- gray bandages
    { 68, 0, 4, 255 } } -- brown hair
local chaiColors_2 = {
    { 225, 245, 255, 255 }, { 136, 164, 202, 255 }, { 65, 76, 98, 255 }, -- light blue shirt
    { 30, 115, 158, 255 }, { 36, 40, 84, 255 }, { 0, 10, 30, 255 }, -- teal shorts
    { 255, 255, 116, 255 }, { 204, 146, 38, 255 }, { 96, 58, 8, 255 }, -- yellow bandages
    { 29, 20, 84, 255 } } -- purple hair
local chaiColors_3 = {
    { 245, 242, 233, 255 }, { 188, 154, 124, 255 }, { 105, 73, 45, 255 }, -- light sepia shirt
    { 76, 55, 55, 255 }, { 17, 27, 37, 255 }, { 6, 6, 16, 255 }, -- black shorts
    { 252, 105, 85, 255 }, { 219, 17, 17, 255 }, { 105, 4, 51, 255 }, -- red bandages
    { 50, 24, 5, 255 } } -- sand hair

local yarColors_original = {
    { 14, 69, 96, 255 }, { 22, 30, 36, 255 }, { 6, 11, 13, 255 }, -- black fur
    { 250, 242, 238, 255 }, { 229, 180, 99, 255 }, { 152, 118, 64, 255 }, -- white chest mark
    { 235, 28, 31, 255 }, { 141, 2, 3, 255 }, { 54, 1, 1, 255 } } -- red shoes
local yarColors_2 = {
    { 250, 246, 226, 255 }, { 138, 164, 179, 255 }, { 36, 67, 89, 255 }, -- white fur
    { 250, 246, 226, 255 }, { 138, 164, 179, 255 }, { 36, 67, 89, 255 }, -- white chest mark
    { 38, 130, 242, 255 }, { 9, 65, 160, 255 }, { 3, 20, 61, 255 } } -- blue shoes
local yarColors_3 = {
    { 145, 68, 16, 255 }, { 59, 20, 4, 255 }, { 19, 3, 5, 255 }, -- brown fur
    { 145, 68, 16, 255 }, { 59, 20, 4, 255 }, { 19, 3, 5, 255 }, -- brown chest mark
    { 255, 200, 49, 255 }, { 229, 97, 25, 255 }, { 130, 15, 5, 255 } } -- yellow shoes

-- Enemies
local gopperColors_original = {
    { 249, 248, 252, 255 }, { 201, 185, 234, 255 }, { 118, 109, 138, 255 }, -- white top
    { 26, 72, 132, 255 }, { 7, 27, 104, 255 }, { 4, 11, 34, 255 }, -- blue pants
    { 137, 141, 148, 255 }, { 94, 97, 102, 255 }, -- top gray stripes
    { 251, 253, 255, 255 }, { 192, 202, 211, 255 }, -- bottom white stripes
    { 55, 62, 58, 255 }, { 27, 27, 27, 255 }, { 6, 6, 6, 255 } } -- black shoes
local gopperColors_2 = {
    { 26, 72, 132, 255 }, { 7, 27, 104, 255 }, { 4, 11, 34, 255 }, -- blue top
    { 26, 72, 132, 255 }, { 7, 27, 104, 255 }, { 4, 11, 34, 255 }, -- blue pants
    { 251, 253, 255, 255 }, { 192, 202, 211, 255 } } -- top white stripes
local gopperColors_3 = {
    { 39, 124, 75, 255 }, { 20, 60, 21, 255 }, { 5, 28, 5, 255 }, -- green top
    { 39, 124, 75, 255 }, { 20, 60, 21, 255 }, { 5, 28, 5, 255 }, -- green pants
    { 251, 253, 255, 255 }, { 192, 202, 211, 255 } } -- top white stripes
local gopperColors_4 = {
    { 66, 51, 58, 255 }, { 27, 27, 27, 255 }, { 6, 6, 6, 255 }, -- black top
    { 66, 51, 58, 255 }, { 27, 27, 27, 255 }, { 6, 6, 6, 255 }, -- black pants
    { 251, 253, 255, 255 }, { 192, 202, 211, 255 } } -- top white stripes
local gopperColors_5 = {
    { 175, 14, 54, 255 }, { 95, 7, 17, 255 }, { 43, 4, 5, 255 }, -- red top
    { 175, 14, 54, 255 }, { 95, 7, 17, 255 }, { 43, 4, 5, 255 }, -- red pants
    { 251, 253, 255, 255 }, { 192, 202, 211, 255 } } -- top white stripes

local nikoColors_original = gopperColors_original
local nikoColors_2 = gopperColors_2

local svetaColors_original = {
    { 133, 149, 178, 255 }, { 47, 66, 124, 255 }, { 16, 31, 61, 255 }, -- blue-gray vest
    { 26, 72, 132, 255 }, { 7, 27, 104, 255 }, { 4, 11, 34, 255 }, -- blue pants
    { 186, 130, 54, 255 }, { 141, 64, 12, 255 }, { 53, 28, 17, 255 } } -- chestnut hair
local svetaColors_2 = {
    { 133, 149, 178, 255 }, { 47, 66, 124, 255 }, { 16, 31, 61, 255 }, -- blue-gray vest
    { 66, 51, 58, 255 }, { 27, 27, 27, 255 }, { 6, 6, 6, 255 } } -- black pants

local zeenaColors_original = svetaColors_original
local zeenaColors_2 = {
    { 249, 187, 193, 255 }, { 195, 94, 154, 255 }, { 75, 18, 101, 255 }, -- pink vest
    { 66, 51, 58, 255 }, { 27, 27, 27, 255 }, { 6, 6, 6, 255 }, -- black pants
    { 35, 59, 95, 255 }, { 4, 7, 70, 255 }, { 4, 3, 41, 255 } } -- dark blue hair

local satoffColors_original = {
    { 240, 30, 31, 255 }, { 138, 7, 29, 255 }, { 49, 5, 5, 255 }, -- red suit
    { 110, 14, 24, 255 }, { 52, 5, 9, 255 }, { 32, 4, 4, 255 }, -- maroon shoes
    { 60, 23, 17, 255 }, { 26, 5, 4, 255 }, { 13, 3, 2, 255 }, -- brown pants
    { 207, 140, 113, 255 }} -- face scar
local satoffColors_2 = {
    { 0, 89, 221, 255 }, { 0, 50, 131, 255 }, { 0, 12, 54, 255 }, -- blue suit
    { 22, 30, 100, 255 }, { 4, 6, 50, 255 }, { 0, 0, 22, 255 }, -- midnight blue shoes
    { 28, 28, 46, 255 }, { 9, 9, 21, 255 }, { 1, 1, 10, 255 }, -- cool gray pants
    { 250, 197, 172, 255 }} -- no face scar
local satoffColors_3 = {
    { 255, 250, 249, 255 }, { 206, 186, 173, 255 }, { 121, 108, 98, 255 }, -- white suit
    { 75, 54, 49, 255 }, { 39, 38, 32, 255 }, { 15, 8, 6, 255 }, -- taupe shoes
    { 121, 13, 134, 255 }, { 69, 0, 78, 255 }, { 36, 0, 41, 255 }, -- purple pants
    { 250, 197, 172, 255 }} -- no face scar
local satoffColors_4 = {
    { 38, 38, 27, 255 }, { 22, 14, 10, 255 }, { 13, 1, 0, 255 }, -- black suit
    { 38, 38, 27, 255 }, { 22, 14, 10, 255 }, { 13, 1, 0, 255 }, -- black shoes
    { 180, 4, 50, 255 }, { 99, 0, 30, 255 }, { 52, 0, 0, 255 }, -- bordeaux pants
    { 250, 197, 172, 255 }} -- no face scar
-- Stage Objects
local trashcanColors_original = {
    { 137, 124, 112, 255 }, { 107, 87, 83, 255 }, { 75, 48, 49, 255 }, { 35, 21, 21, 255 }, -- brown metal
    { 51, 79, 105, 255 }, { 49, 52, 41, 255 }, { 23, 25, 20, 255 }} -- inner blue bag
local trashcanColors_2 = {
    { 89, 128, 147, 255 }, { 63, 100, 115, 255 }, { 36, 65, 78, 255 }, { 18, 30, 36, 255 }, -- blue metal
    { 63, 101, 74, 255 }, { 43, 54, 40, 255 }, { 23, 28, 18, 255 }} -- inner green bag
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
    shaders.rick[1] = nil
    shaders.rick[2] = swapColors(rickColors_original, rickColors_2)
    shaders.rick[3] = swapColors(rickColors_original, rickColors_3)
    shaders.kisa[1] = nil
    shaders.kisa[2] = swapColors(kisaColors_original, kisaColors_2)
    shaders.kisa[3] = swapColors(kisaColors_original, kisaColors_3)
    shaders.chai[1] = nil
    shaders.chai[2] = swapColors(chaiColors_original, chaiColors_2)
    shaders.chai[3] = swapColors(chaiColors_original, chaiColors_3)
    shaders.yar[1] = nil
    shaders.yar[2] = swapColors(yarColors_original, yarColors_2)
    shaders.yar[3] = swapColors(yarColors_original, yarColors_3)
    shaders.gopper[1] = swapColors(gopperColors_original, gopperColors_2)
    shaders.gopper[2] = swapColors(gopperColors_original, gopperColors_3)
    shaders.gopper[3] = swapColors(gopperColors_original, gopperColors_4)
    shaders.gopper[4] = swapColors(gopperColors_original, gopperColors_5)
    shaders.niko[1] = swapColors(nikoColors_original, nikoColors_2)
    shaders.niko[2] = swapColors(nikoColors_original, nikoColors_2)
    shaders.niko[3] = swapColors(nikoColors_original, nikoColors_2)
    shaders.sveta[1] = swapColors(svetaColors_original, svetaColors_2)
    shaders.sveta[2] = swapColors(svetaColors_original, svetaColors_2)
    shaders.sveta[3] = swapColors(svetaColors_original, svetaColors_2)
    shaders.zeena[1] = swapColors(zeenaColors_original, zeenaColors_2)
    shaders.zeena[2] = swapColors(zeenaColors_original, zeenaColors_2)
    shaders.zeena[3] = swapColors(zeenaColors_original, zeenaColors_2)
    shaders.beatnik[1] = nil
    shaders.satoff[1] = nil
    shaders.satoff[2] = swapColors(satoffColors_original, satoffColors_2)
    shaders.satoff[3] = swapColors(satoffColors_original, satoffColors_3)
    shaders.satoff[4] = swapColors(satoffColors_original, satoffColors_4)
    shaders.drVolker[1] = nil
    shaders.trashcan[1] = nil
    shaders.trashcan[2] = swapColors(trashcanColors_original, trashcanColors_2)
    shaders.trashcan_particleColor[1] = { 118, 109, 100, 255 }
    shaders.trashcan_particleColor[2] = { 87, 116, 130, 255 }
end
--reloadShaders()

return shaders
