shaders = {
    rick = {},
    kisa = {},
    chai = {},
    yar = {},
    gopper = {},
    niko = {},
    sveta = {},
    zeena = {},
    hooch = {},
    beatnik = {},
    satoff = {},
    drVolker = {},
    trashcan = {},
    trashcan_particleColor = {},
    silhouette = {}
}

local cc = getTableOfColorFromBytes

getShader = function(name, n)
    if shaders[name] then
        if type(n) == "string" and shaders[name].aliases then
            n = shaders[name].aliases[n]
        end
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

local sh_silhouette = [[
    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        vec4 pixel = Texel(texture, texture_coords );
        if(pixel != vec4(0,0,0,0))
            return vec4(color.r, color.g, color.b, pixel.a * color.a);
        else
            return vec4(0,0,0,0);
    }
]]
local function silhouette()
    return love.graphics.newShader(sh_silhouette)
end

local sh_swapColors = [[;
        uniform vec4 origColors[origColorsN];
        uniform vec4 altColors[altColorsN];
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
            vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
            for (int i = 0; i < altColorsN; i++) {
                if(pixel == origColors[i])
                    return altColors[i] * color;
            }
            return pixel * color;
        }   ]]

local function swapColors(origColors, altColors)
    local shader = love.graphics.newShader([[const int origColorsN =]] .. tostring(#origColors) .. [[;const int altColorsN =]] .. tostring(#altColors) .. sh_swapColors)
    shader:sendColor("origColors", unpack(origColors))
    shader:sendColor("altColors", unpack(altColors))
    return shader
end

--Players
local rickColors_original = cc {
    { 207, 82, 10, 255 }, { 148, 36, 35, 255 }, { 61, 10, 15, 255 }, -- orange hoodie
    { 43, 58, 75, 255 }, { 34, 26, 26, 255 }, { 15, 9, 5, 255 }, -- black pants
    { 63, 144, 229, 255 }, { 35, 75, 160, 255 }, { 5, 23, 70, 255 }, -- blue shoes
    { 240, 242, 244, 255 }, { 184, 194, 204, 255 }, { 119, 125, 139, 255 } } -- white shoe stripes
local rickColors_2 = cc {
    { 231, 228, 231, 255 }, { 163, 148, 163, 255 }, { 82, 82, 82, 255 }, -- white hoodie
    { 29, 86, 133, 255 }, { 12, 37, 93, 255 }, { 7, 10, 48, 255 }, -- blue pants
    { 231, 228, 231, 255 }, { 163, 148, 163, 255 }, { 82, 82, 82, 255 }, -- white shoes
    { 29, 86, 133, 255 }, { 12, 37, 93, 255 }, { 7, 10, 48, 255 } } -- blue shoe stripes
local rickColors_3 = cc {
    { 44, 53, 76, 255 }, { 18, 23, 35, 255 }, { 4, 5, 8, 255 }, -- black hoodie
    { 200, 212, 218, 255 }, { 104, 110, 119, 255 }, { 48, 50, 53, 255 }, -- light gray pants
    { 222, 34, 32, 255 }, { 129, 12, 11, 255 }, { 46, 3, 2, 255 } } -- red shoes

local kisaColors_original = cc {
    { 57, 184, 125, 255 }, { 22, 113, 106, 255 }, { 5, 47, 43, 255 }, -- green hat
    { 211, 172, 39, 255 }, { 107, 86, 10, 255 } } -- yellow hi vis band
local kisaColors_2 = cc {
    { 80, 174, 227, 255 }, { 56, 90, 153, 255 }, { 25, 40, 96, 255 }, -- blue hat
    { 173, 204, 219, 255 }, { 94, 133, 153, 255 } } -- blue-gray hi vis band
local kisaColors_3 = cc {
    { 192, 192, 192, 255 }, { 128, 128, 128, 255 }, { 56, 56, 56, 255 }, -- gray hat
    { 81, 91, 102, 255 }, { 37, 39, 40, 255 } } -- dark gray hi vis band

local chaiColors_original = cc {
    { 249, 244, 59, 255 }, { 193, 147, 33, 255 }, { 97, 62, 9, 255 }, -- yellow shirt
    { 148, 30, 169, 255 }, { 75, 2, 149, 255 }, { 21, 0, 31, 255 }, -- purple shorts
    { 245, 238, 252, 255 }, { 158, 165, 203, 255 }, { 101, 94, 107, 255 }, -- gray bandages
    { 64, 5, 9, 255 } } -- brown hair
local chaiColors_2 = cc {
    { 217, 236, 255, 255 }, { 133, 159, 194, 255 }, { 65, 76, 95, 255 }, -- light blue shirt
    { 35, 112, 152, 255 }, { 27, 44, 86, 255 }, { 0, 12, 31, 255 }, -- teal shorts
    { 249, 244, 97, 255 }, { 193, 147, 33, 255 }, { 97, 62, 9, 255 }, -- yellow bandages
    { 35, 29, 76, 255 } } -- purple hair
local chaiColors_3 = cc {
    { 237, 231, 221, 255 }, { 180, 149, 122, 255 }, { 102, 73, 47, 255 }, -- light sepia shirt
    { 69, 53, 53, 255 }, { 20, 24, 34, 255 }, { 8, 8, 15, 255 }, -- black shorts
    { 249, 107, 92, 255 }, { 216, 23, 23, 255 }, { 109, 7, 41, 255 }, -- red bandages
    { 51, 26, 8, 255 } } -- sand hair

local yarColors_original = cc {
    { 19, 69, 94, 255 }, { 24, 31, 37, 255 }, { 8, 13, 15, 255 }, -- black fur
    { 247, 240, 236, 255 }, { 222, 178, 103, 255 }, { 147, 116, 67, 255 }, -- white chest mark
    { 230, 31, 36, 255 }, { 141, 4, 5, 255 }, { 56, 1, 2, 255 } } -- red shoes
local yarColors_2 = cc {
    { 246, 238, 216, 255 }, { 133, 157, 171, 255 }, { 38, 67, 87, 255 }, -- white fur
    { 246, 238, 216, 255 }, { 133, 157, 171, 255 }, { 38, 67, 87, 255 }, -- white chest mark
    { 48, 133, 237, 255 }, { 14, 69, 155, 255 }, { 5, 24, 62, 255 } } -- blue shoes
local yarColors_3 = cc {
    { 142, 71, 19, 255 }, { 60, 23, 7, 255 }, { 21, 5, 8, 255 }, -- brown fur
    { 142, 71, 19, 255 }, { 60, 23, 7, 255 }, { 21, 5, 8, 255 }, -- brown chest mark
    { 255, 196, 46, 255 }, { 219, 97, 25, 255 }, { 119, 20, 7, 255 } } -- yellow shoes

-- Enemies
local gopperColors_original = cc {
    { 244, 242, 249, 255 }, { 183, 178, 224, 255 }, { 114, 106, 133, 255 }, -- white top
    { 32, 69, 126, 255 }, { 13, 30, 98, 255 }, { 7, 14, 36, 255 }, -- blue pants
    { 129, 133, 139, 255 }, { 90, 93, 98, 255 }, -- top gray stripes
    { 245, 249, 253, 255 }, { 185, 194, 202, 255 }, -- bottom white stripes
    { 55, 59, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 } } -- black shoes
local gopperColors_blue = cc {
    { 32, 69, 126, 255 }, { 13, 30, 98, 255 }, { 7, 14, 36, 255 }, -- blue top
    { 32, 69, 126, 255 }, { 13, 30, 98, 255 }, { 7, 14, 36, 255 }, -- blue pants
    { 245, 249, 253, 255 }, { 185, 194, 202, 255 } } -- top white stripes
local gopperColors_green = cc {
    { 43, 114, 70, 255 }, { 23, 58, 24, 255 }, { 8, 28, 8, 255 }, -- green top
    { 43, 114, 70, 255 }, { 23, 58, 24, 255 }, { 8, 28, 8, 255 }, -- green pants
    { 245, 249, 253, 255 }, { 185, 194, 202, 255 } } -- top white stripes
local gopperColors_black = cc {
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black top
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black pants
    { 245, 249, 253, 255 }, { 185, 194, 202, 255 } } -- top white stripes
local gopperColors_red = cc {
    { 160, 22, 56, 255 }, { 90, 12, 22, 255 }, { 42, 7, 9, 255 }, -- red top
    { 160, 22, 56, 255 }, { 90, 12, 22, 255 }, { 42, 7, 9, 255 }, -- red pants
    { 245, 249, 253, 255 }, { 185, 194, 202, 255 } } -- top white stripes

local nikoColors_original = gopperColors_original
local nikoColors_blue = gopperColors_blue
local nikoColors_green = gopperColors_green
local nikoColors_black = gopperColors_black
local nikoColors_red = gopperColors_red

local svetaColors_original = cc {
    { 134, 146, 169, 255 }, { 51, 69, 122, 255 }, { 20, 34, 62, 255 }, -- blue-gray vest
    { 32, 69, 126, 255 }, { 13, 30, 98, 255 }, { 7, 14, 36, 255 }, -- blue pants
    { 180, 127, 57, 255 }, { 138, 67, 13, 255 }, { 53, 30, 20, 255 }, -- chestnut hair
    { 154, 15, 50, 255 }, { 93, 5, 21, 255 }, { 46, 2, 7, 255 }, -- red shirt
    { 245, 249, 253, 255 }, { 185, 194, 202, 255 }, -- white pant stripes
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 } } -- black shoes
local svetaColors_blue = cc {
    { 134, 146, 169, 255 }, { 51, 69, 122, 255 }, { 20, 34, 62, 255 }, -- blue-gray vest
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 } } -- black pants

local zeenaColors_original = svetaColors_original
local zeenaColors_pink = cc {
    { 247, 182, 193, 255 }, { 189, 96, 151, 255 }, { 77, 24, 101, 255 }, -- pink vest
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black pants
    { 38, 61, 93, 255 }, { 7, 12, 72, 255 }, { 7, 5, 44, 255 } } -- dark blue hair
local zeenaColors_black = cc {
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black vest
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black pants
    { 160, 89, 32, 255 }, { 107, 41, 21, 255 }, { 40, 19, 7, 255 }, -- brown hair
    { 32, 69, 126, 255 }, { 13, 30, 98, 255 }, { 7, 14, 36, 255 } } -- blue vest
local zeenaColors_blackred = cc {
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black vest
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black pants
    { 160, 89, 32, 255 }, { 107, 41, 21, 255 }, { 40, 19, 7, 255 }, -- brown hair
    { 154, 15, 50, 255 }, { 93, 5, 21, 255 }, { 46, 2, 7, 255 }, -- red shirt
    { 231, 23, 0, 255 }, { 121, 13, 13, 255 } } -- red pant stripes
local zeenaColors_blue = cc {
    { 134, 146, 169, 255 }, { 51, 69, 122, 255 }, { 20, 34, 62, 255 }, -- blue-gray vest
    { 32, 69, 126, 255 }, { 13, 30, 98, 255 }, { 7, 14, 36, 255 }, -- blue pants
    { 179, 60, 28, 255 }, { 87, 6, 5, 255 }, { 40, 2, 1, 255 }, -- red hair
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black shirt
    { 231, 23, 0, 255 }, { 121, 13, 13, 255 }, -- red pant stripes
    { 244, 242, 249, 255 }, { 183, 178, 224, 255 }, { 114, 106, 133, 255 } } -- white shoes

local satoffColors_original = cc {
    { 228, 33, 35, 255 }, { 135, 12, 30, 255 }, { 51, 8, 9, 255 }, -- red suit
    { 107, 20, 29, 255 }, { 53, 9, 13, 255 }, { 34, 7, 7, 255 }, -- maroon shoes
    { 57, 25, 20, 255 }, { 28, 8, 7, 255 }, { 15, 5, 4, 255 }, -- brown pants
    { 199, 137, 114, 255 } } -- face scar
local satoffColors_2 = cc {
    { 16, 92, 203, 255 }, { 10, 53, 121, 255 }, { 4, 16, 51, 255 }, -- blue suit
    { 29, 36, 100, 255 }, { 10, 12, 52, 255 }, { 4, 4, 25, 255 }, -- midnight blue shoes
    { 30, 30, 47, 255 }, { 12, 12, 23, 255 }, { 4, 4, 13, 255 }, -- cool gray pants
    { 246, 191, 168, 255 } } -- no face scar
local satoffColors_3 = cc {
    { 253, 246, 244, 255 }, { 198, 180, 167, 255 }, { 115, 103, 94, 255 }, -- white suit
    { 73, 54, 50, 255 }, { 39, 38, 33, 255 }, { 17, 11, 9, 255 }, -- taupe shoes
    { 120, 22, 132, 255 }, { 70, 7, 79, 255 }, { 38, 5, 43, 255 }, -- purple pants
    { 246, 191, 168, 255 } } -- no face scar
local satoffColors_4 = cc {
    { 39, 39, 29, 255 }, { 24, 16, 13, 255 }, { 16, 5, 2, 255 }, -- black suit
    { 39, 39, 29, 255 }, { 24, 16, 13, 255 }, { 16, 5, 2, 255 }, -- black shoes
    { 178, 10, 53, 255 }, { 102, 4, 32, 255 }, { 54, 3, 6, 255 }, -- bordeaux pants
    { 246, 191, 168, 255 } } -- no face scar

-- Stage Objects
local trashcanColors_original = cc {
    { 131, 119, 108, 255 }, { 103, 84, 81, 255 }, { 73, 49, 50, 255 }, { 36, 23, 23, 255 }, -- metal brown
    { 53, 79, 102, 255 }, { 49, 51, 41, 255 }, { 24, 26, 21, 255 }} -- inner blue bag
local trashcanColors_2 = cc {
    { 87, 124, 142, 255 }, { 63, 97, 111, 255 }, { 38, 65, 76, 255 }, { 20, 31, 37, 255 }, -- metal blue
    { 63, 97, 72, 255 }, { 43, 53, 40, 255 }, { 24, 29, 20, 255 } } -- inner green bag

-- Misc
local function load_frag_shader(file)
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
    --{ name = "CRT-Simple", shader = load_frag_shader("CRT-Simple.frag"),
    --    func = function(shader)
    --        shader:send('inputSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
    --        shader:send('outputSize', {love.graphics.getWidth(), love.graphics.getHeight()})
    --        shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
    --    end },
    --{ name = "CRT", shader = load_frag_shader("CRT.frag"),
    --    func = function(shader)
    --        shader:send('inputSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
    --        shader:send('outputSize', {love.graphics.getWidth(), love.graphics.getHeight()})
    --        shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
    --    end },
    { name = "curvature", shader = load_frag_shader("curvature.frag"),
        func = function(shader)
            shader:send('inputSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
            shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
        end },
    { name = "4xBR", shader = load_frag_shader("4xBR.frag"),
        func = function(shader)
            shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
        end },
    --{ name = "phosphor", shader = load_frag_shader("phosphor.frag"),
    --    func = function(shader)
    --        shader:send('textureSize', {love.graphics.getWidth()/push._SCALE.x, love.graphics.getHeight()/push._SCALE.y})
    --    end },
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
    --{ name = "scanline-3x", shader = load_frag_shader("scanline-3x.frag"),
    --    func = nil },
    --{ name = "scanline-4x", shader = load_frag_shader("scanline-4x.frag"),
    --    func = nil },
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

function loadUnitsShaders()
    shaders.rick = {
        false,
        swapColors(rickColors_original, rickColors_2),
        swapColors(rickColors_original, rickColors_3),
    }
    shaders.kisa = {
        false,
        swapColors(kisaColors_original, kisaColors_2),
        swapColors(kisaColors_original, kisaColors_3),
    }
    shaders.chai = {
        false,
        swapColors(chaiColors_original, chaiColors_2),
        swapColors(chaiColors_original, chaiColors_3),
    }
    shaders.yar = {
        false,
        swapColors(yarColors_original, yarColors_2),
        swapColors(yarColors_original, yarColors_3),
    }
    shaders.gopper = {
        swapColors(gopperColors_original, gopperColors_blue),
        swapColors(gopperColors_original, gopperColors_green),
        swapColors(gopperColors_original, gopperColors_black),
        swapColors(gopperColors_original, gopperColors_red),
    }
    shaders.gopper.aliases = { blue = 1, green = 2, black = 3, red = 4, }
    shaders.niko = {
        swapColors(nikoColors_original, nikoColors_blue),
        swapColors(nikoColors_original, nikoColors_green),
        swapColors(nikoColors_original, nikoColors_black),
        swapColors(nikoColors_original, nikoColors_red),
    }
    shaders.niko.aliases = { blue = 1, green = 2, black = 3, red = 4, }
    shaders.sveta = {
        swapColors(svetaColors_original, svetaColors_blue),
    }
    shaders.sveta.aliases = { blue = 1, }
    shaders.zeena = {
        swapColors(zeenaColors_original, zeenaColors_pink),
        swapColors(zeenaColors_original, zeenaColors_black),
        swapColors(zeenaColors_original, zeenaColors_blackred),
        swapColors(zeenaColors_original, zeenaColors_blue),
    }
    shaders.zeena.aliases = { pink = 1, black = 2, blackred = 3, blue = 4, }
    shaders.hooch = {
        false,
    }
    shaders.beatnik = {
        false,
    }
    shaders.satoff = {
        false,
        swapColors(satoffColors_original, satoffColors_2),
        swapColors(satoffColors_original, satoffColors_3),
        swapColors(satoffColors_original, satoffColors_4),
    }
    shaders.satoff.aliases = { red = 1, blue = 2, white = 3, black = 4, }
    shaders.drVolker = {
        false,
    }
    shaders.trashcan = {
        false,
        swapColors(trashcanColors_original, trashcanColors_2),
    }
    shaders.trashcan_particleColor = {
        { 118, 109, 100, 255 },
        { 87, 116, 130, 255 }
    }
    shaders.silhouette = silhouette()
end

return shaders
