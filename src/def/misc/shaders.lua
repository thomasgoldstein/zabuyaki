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
    { 207, 82, 10, 255 }, { 148, 36, 35, 255 }, { 61, 10, 15, 255 }, -- orange hoodie
    { 43, 58, 75, 255 }, { 34, 26, 26, 255 }, { 15, 9, 5, 255 }, -- black pants
    { 63, 144, 229, 255 }, { 35, 75, 160, 255 }, { 5, 23, 70, 255 }, -- blue shoes
    { 240, 242, 244, 255 }, { 184, 194, 204, 255 }, { 119, 125, 139, 255 } } -- white shoe stripes
local rickColors_2 = {
    { 231, 228, 231, 255 }, { 163, 148, 163, 255 }, { 82, 82, 82, 255 }, -- white hoodie
    { 29, 86, 133, 255 }, { 12, 37, 93, 255 }, { 7, 10, 48, 255 }, -- blue pants
    { 231, 228, 231, 255 }, { 163, 148, 163, 255 }, { 82, 82, 82, 255 }, -- white shoes
    { 29, 86, 133, 255 }, { 12, 37, 93, 255 }, { 7, 10, 48, 255 } } -- blue shoe stripes
local rickColors_3 = {
    { 44, 53, 76, 255 }, { 18, 23, 35, 255 }, { 4, 5, 8, 255 }, -- black hoodie
    { 200, 212, 218, 255 }, { 104, 110, 119, 255 }, { 48, 50, 53, 255 }, -- light gray pants
    { 222, 34, 32, 255 }, { 129, 12, 11, 255 }, { 46, 3, 2, 255 } } -- red shoes

local kisaColors_original = {
    { 57, 184, 125, 255 }, { 22, 113, 106, 255 }, { 5, 47, 43, 255 }, -- teal headscarf
    { 250, 237, 153, 255 }, { 211, 172, 39, 255 }, { 107, 86, 10, 255 } } -- sand shirt
local kisaColors_2 = {
    { 231, 87, 30, 255 }, { 160, 22, 12, 255 }, { 75, 4, 1, 255 }, -- orange-red headscarf
    { 244, 218, 67, 255 }, { 210, 137, 27, 255 }, { 125, 57, 8, 255 } } -- yellow-orange shirt
local kisaColors_3 = {
    { 193, 228, 238, 255 }, { 80, 174, 227, 255 }, { 19, 84, 128, 255 }, -- sky blue headscarf
    { 74, 79, 220, 255 }, { 32, 37, 142, 255 }, { 11, 12, 49, 255 } } -- violet-blue shirt

local chaiColors_original = {
    { 249, 244, 59, 255 }, { 193, 147, 33, 255 }, { 97, 62, 9, 255 }, -- yellow shirt
    { 148, 30, 169, 255 }, { 75, 2, 149, 255 }, { 21, 0, 31, 255 }, -- purple shorts
    { 245, 238, 252, 255 }, { 158, 165, 203, 255 }, { 101, 94, 107, 255 }, -- gray bandages
    { 64, 5, 9, 255 } } -- brown hair
local chaiColors_2 = {
    { 217, 236, 255, 255 }, { 133, 159, 194, 255 }, { 65, 76, 95, 255 }, -- light blue shirt
    { 35, 112, 152, 255 }, { 27, 44, 86, 255 }, { 0, 12, 31, 255 }, -- teal shorts
    { 249, 244, 97, 255 }, { 193, 147, 33, 255 }, { 97, 62, 9, 255 }, -- yellow bandages
    { 30, 22, 77, 255 } } -- purple hair
local chaiColors_3 = {
    { 237, 231, 221, 255 }, { 180, 149, 122, 255 }, { 102, 73, 47, 255 }, -- light sepia shirt
    { 69, 53, 53, 255 }, { 20, 24, 34, 255 }, { 8, 8, 15, 255 }, -- black shorts
    { 249, 107, 92, 255 }, { 216, 23, 23, 255 }, { 109, 7, 41, 255 }, -- red bandages
    { 51, 26, 8, 255 } } -- sand hair

local yarColors_original = {
    { 19, 69, 94, 255 }, { 24, 31, 37, 255 }, { 8, 13, 15, 255 }, -- black fur
    { 247, 240, 236, 255 }, { 222, 178, 103, 255 }, { 147, 116, 67, 255 }, -- white chest mark
    { 230, 31, 36, 255 }, { 141, 4, 5, 255 }, { 56, 1, 2, 255 } } -- red shoes
local yarColors_2 = {
    { 246, 238, 216, 255 }, { 133, 157, 171, 255 }, { 38, 67, 87, 255 }, -- white fur
    { 246, 238, 216, 255 }, { 133, 157, 171, 255 }, { 38, 67, 87, 255 }, -- white chest mark
    { 48, 133, 237, 255 }, { 14, 69, 155, 255 }, { 5, 24, 62, 255 } } -- blue shoes
local yarColors_3 = {
    { 142, 71, 19, 255 }, { 60, 23, 7, 255 }, { 21, 5, 8, 255 }, -- brown fur
    { 142, 71, 19, 255 }, { 60, 23, 7, 255 }, { 21, 5, 8, 255 }, -- brown chest mark
    { 255, 196, 46, 255 }, { 219, 97, 25, 255 }, { 119, 20, 7, 255 } } -- yellow shoes

-- Enemies
local gopperColors_original = {
    { 244, 242, 249, 255 }, { 183, 178, 224, 255 }, { 114, 106, 133, 255 }, -- white top
    { 32, 69, 126, 255 }, { 13, 30, 98, 255 }, { 7, 14, 36, 255 }, -- blue pants
    { 129, 133, 139, 255 }, { 90, 93, 98, 255 }, -- top gray stripes
    { 245, 249, 253, 255 }, { 185, 194, 202, 255 }, -- bottom white stripes
    { 55, 59, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 } } -- black shoes
local gopperColors_1 = {
    { 32, 69, 126, 255 }, { 13, 30, 98, 255 }, { 7, 14, 36, 255 }, -- blue top
    { 32, 69, 126, 255 }, { 13, 30, 98, 255 }, { 7, 14, 36, 255 }, -- blue pants
    { 245, 249, 253, 255 }, { 185, 194, 202, 255 } } -- top white stripes
local gopperColors_2 = {
    { 43, 114, 70, 255 }, { 23, 58, 24, 255 }, { 8, 28, 8, 255 }, -- green top
    { 43, 114, 70, 255 }, { 23, 58, 24, 255 }, { 8, 28, 8, 255 }, -- green pants
    { 245, 249, 253, 255 }, { 185, 194, 202, 255 } } -- top white stripes
local gopperColors_3 = {
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black top
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black pants
    { 245, 249, 253, 255 }, { 185, 194, 202, 255 } } -- top white stripes
local gopperColors_4 = {
    { 160, 22, 56, 255 }, { 90, 12, 22, 255 }, { 42, 7, 9, 255 }, -- red top
    { 160, 22, 56, 255 }, { 90, 12, 22, 255 }, { 42, 7, 9, 255 }, -- red pants
    { 245, 249, 253, 255 }, { 185, 194, 202, 255 } } -- top white stripes

local nikoColors_original = gopperColors_original
local nikoColors_1 = gopperColors_1
local nikoColors_2 = gopperColors_2
local nikoColors_3 = gopperColors_3
local nikoColors_4 = gopperColors_4

local svetaColors_original = {
    { 134, 146, 169, 255 }, { 51, 69, 122, 255 }, { 20, 34, 62, 255 }, -- blue-gray vest
    { 32, 69, 126, 255 }, { 13, 30, 98, 255 }, { 7, 14, 36, 255 }, -- blue pants
    { 180, 127, 57, 255 }, { 138, 67, 13, 255 }, { 53, 30, 20, 255 } } -- chestnut hair
local svetaColors_1 = {
    { 134, 146, 169, 255 }, { 51, 69, 122, 255 }, { 20, 34, 62, 255 }, -- blue-gray vest
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 } } -- black pants
local svetaColors_2 = svetaColors_1 -- TODO
local svetaColors_3 = svetaColors_1 -- TODO

local zeenaColors_original = svetaColors_original
local zeenaColors_1 = {
    { 247, 182, 193, 255 }, { 189, 96, 151, 255 }, { 77, 24, 101, 255 }, -- pink vest
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black pants
    { 38, 61, 93, 255 }, { 7, 12, 72, 255 }, { 7, 5, 44, 255 } } -- dark blue hair
local zeenaColors_2 = {
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black vest
    { 62, 52, 56, 255 }, { 28, 28, 28, 255 }, { 8, 8, 8, 255 }, -- black pants
    { 160, 89, 32, 255 }, { 107, 41, 21, 255 }, { 40, 19, 7, 255 } } -- brown hair
local zeenaColors_3 = zeenaColors_2 -- TODO

local satoffColors_original = {
    { 228, 33, 35, 255 }, { 135, 12, 30, 255 }, { 51, 8, 9, 255 }, -- red suit
    { 107, 20, 29, 255 }, { 53, 9, 13, 255 }, { 34, 7, 7, 255 }, -- maroon shoes
    { 57, 25, 20, 255 }, { 28, 8, 7, 255 }, { 15, 5, 4, 255 }, -- brown pants
    { 199, 137, 114, 255 } } -- face scar
local satoffColors_2 = {
    { 16, 92, 203, 255 }, { 10, 53, 121, 255 }, { 4, 16, 51, 255 }, -- blue suit
    { 29, 36, 100, 255 }, { 10, 12, 52, 255 }, { 4, 4, 25, 255 }, -- midnight blue shoes
    { 30, 30, 47, 255 }, { 12, 12, 23, 255 }, { 4, 4, 13, 255 }, -- cool gray pants
    { 246, 191, 168, 255 } } -- no face scar
local satoffColors_3 = {
    { 253, 246, 244, 255 }, { 198, 180, 167, 255 }, { 115, 103, 94, 255 }, -- white suit
    { 73, 54, 50, 255 }, { 39, 38, 33, 255 }, { 17, 11, 9, 255 }, -- taupe shoes
    { 120, 22, 132, 255 }, { 70, 7, 79, 255 }, { 38, 5, 43, 255 }, -- purple pants
    { 246, 191, 168, 255 } } -- no face scar
local satoffColors_4 = {
    { 39, 39, 29, 255 }, { 24, 16, 13, 255 }, { 16, 5, 2, 255 }, -- black suit
    { 39, 39, 29, 255 }, { 24, 16, 13, 255 }, { 16, 5, 2, 255 }, -- black shoes
    { 178, 10, 53, 255 }, { 102, 4, 32, 255 }, { 54, 3, 6, 255 }, -- bordeaux pants
    { 246, 191, 168, 255 } } -- no face scar

-- Stage Objects
local trashcanColors_original = {
    { 131, 119, 108, 255 }, { 103, 84, 81, 255 }, { 73, 49, 50, 255 }, { 36, 23, 23, 255 }, -- metal brown
    { 53, 79, 102, 255 }, { 49, 51, 41, 255 }, { 24, 26, 21, 255 }} -- inner blue bag
local trashcanColors_2 = {
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

function reloadShaders()
    shaders.rick = {
        nil,
        swapColors(rickColors_original, rickColors_2),
        swapColors(rickColors_original, rickColors_3),
    }
    shaders.kisa = {
        nil,
        swapColors(kisaColors_original, kisaColors_2),
        swapColors(kisaColors_original, kisaColors_3),
    }
    shaders.chai = {
        nil,
        swapColors(chaiColors_original, chaiColors_2),
        swapColors(chaiColors_original, chaiColors_3),
    }
    shaders.yar = {
        nil,
        swapColors(yarColors_original, yarColors_2),
        swapColors(yarColors_original, yarColors_3),
    }
    shaders.gopper = {
        swapColors(gopperColors_original, gopperColors_1),
        swapColors(gopperColors_original, gopperColors_2),
        swapColors(gopperColors_original, gopperColors_3),
        swapColors(gopperColors_original, gopperColors_4),
    }
    shaders.niko = {
        swapColors(nikoColors_original, nikoColors_1),
        swapColors(nikoColors_original, nikoColors_2),
        swapColors(nikoColors_original, nikoColors_3),
        swapColors(nikoColors_original, nikoColors_4),
    }
    shaders.sveta = {
        swapColors(svetaColors_original, svetaColors_1),
        swapColors(svetaColors_original, svetaColors_2),
        swapColors(svetaColors_original, svetaColors_3),
    }
    shaders.zeena = {
        swapColors(zeenaColors_original, zeenaColors_1),
        swapColors(zeenaColors_original, zeenaColors_2),
        swapColors(zeenaColors_original, zeenaColors_3),
    }
    shaders.beatnik = {
        nil,
    }
    shaders.satoff = {
        nil,
        swapColors(satoffColors_original, satoffColors_2),
        swapColors(satoffColors_original, satoffColors_3),
        swapColors(satoffColors_original, satoffColors_4),
    }
    shaders.drVolker = {
        nil,
    }
    shaders.trashcan = {
        nil,
        swapColors(trashcanColors_original, trashcanColors_2),
    }
    shaders.trashcan_particleColor = {
        { 118, 109, 100, 255 },
        { 87, 116, 130, 255 }
    }
end

return shaders
