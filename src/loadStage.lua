-- Load and correct objects from various Tiled export files

--stage1_data.lua

local function extractTable(tab, val)
    for index, value in ipairs(tab) do
        -- We grab the first index of our sub-table instead
        if value and value.name == val then
            return value
        end
    end
    return nil
end

local

function loadCollision(items)
    print("Load collisions...")
--        "collision"
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

function loadStageData(file)
    local d = dofile(file)
    --print(d)
    --    print(inspect(d.layers))
    loadCollision(d)
end
