-- Load and correct objects from various Tiled export files
--to load stage1_data.lua

local function extractTable(tab, val)
    for i, value in ipairs(tab) do
        if value and value.name == val then
            return value
        end
    end
    return nil
end

local function loadCollision(items)
    print("Load collisions...")
    local t = extractTable(items.layers, "collision")
    for i, v in ipairs(t.objects) do
        if v.type == "wall" then
            if v.shape == "rectangle" then
                local wall = Wall:new(v.name, { shapeType = v.shape, shapeArgs = { v.x, v.y, v.width, v.height } })
                stage.objects:add(wall)
            elseif v.shape == "polygon" then
                local shapeArgs = {}
                for k = 1, #v.polygon do
                    shapeArgs[#shapeArgs + 1] = v.x + v.polygon[k].x
                    shapeArgs[#shapeArgs + 1] = v.y + v.polygon[k].y
                end
                local wall = Wall:new(v.name, { shapeType = v.shape, shapeArgs = shapeArgs })
                stage.objects:add(wall)
            else
                error("Wrong Tiled object shape #"..i..":"..inspect(v))
            end
        else
            error("Wrong Tiled object type #"..i..":"..inspect(v))
        end
    end
end

local loaded_images = {}
local loaded_images_quads = {}
local function cacheImage(path_to_image)
    if not loaded_images[path_to_image] then
        loaded_images[path_to_image] = love.graphics.newImage(path_to_image)
        local width, height = loaded_images[path_to_image]:getDimensions()
        loaded_images_quads[path_to_image] = love.graphics.newQuad(2, 2, width - 4, height - 4, width, height)
    end
    return loaded_images[path_to_image], loaded_images_quads[path_to_image]
end

local function loadImageLayer(items, background)
    print("Load ImageLayer...")
--    local t = extractTable(items.layers, "collision")
    for i, v in ipairs(items.layers) do
        if v.type == "imagelayer" then
            if v.visible then
                local image, quad = cacheImage(v.image)
                background:add(image, quad, v.offsetx + 2, v.offsety + 2)
            end
        end
    end
end

function loadStageData(file, background)
    local d = dofile(file)
    loadCollision(d)
    loadImageLayer(d, background)
end
