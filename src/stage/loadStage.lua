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

local function loadCollision(items, stage)
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

local y_shift = 240 / 2
local function loadCameraScrolling(items, scrolling)
    print("Load Camera Scrolling...")
    scrolling = { chunks = {} }
    local t = extractTable(items.layers, "camera")
    for i, v in ipairs(t.objects) do
        if v.type == "camera" then
            if v.shape == "polyline" then
                local shapeArgs = {}
                for k = 1, #v.polyline - 1 do
                    scrolling.chunks[#scrolling.chunks + 1] =
                    {startX = v.x + v.polyline[k].x, endX = v.x + v.polyline[k + 1].x,
                        startY = v.y + v.polyline[k].y - y_shift, endY = v.y + v.polyline[k + 1].y - y_shift }
                    if not scrolling.commonY then
                        scrolling.commonY = v.y + v.polyline[k].y - y_shift or 0
                    end
                end
            else
                error("Wrong Camera Scrolling object shape #"..i..":"..inspect(v))
            end
        else
            error("Wrong Camera Scrolling object type #"..i..":"..inspect(v))
        end
    end
    if not scrolling.chunks or #scrolling.chunks < 1 then
        print(" Camera Scrolling is missing... set to Y = 0")
        scrolling.chunks[#scrolling.chunks + 1] =
        {startX = 0, endX = 10000, startY = 0, endY = 0 }
        scrolling.commonY = 0
    end
    return scrolling
end

function loadStageData(file, stage)
    local d = dofile(file)
    loadCollision(d, stage)
    stage.scrolling = loadCameraScrolling(d)
    loadImageLayer(d, stage.background)
    if d.backgroundcolor then
        stage.bgColor = d.backgroundcolor
    end
end
