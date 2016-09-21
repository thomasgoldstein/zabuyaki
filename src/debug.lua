--Debug console output
function dp(...)
    if GLOBAL_SETTING.DEBUG then
        print(...)
    end
end

dboc = {}
dboc[0] = {x = 0, y = 0, z = 0}
function dpo(o, txt)
    if not GLOBAL_SETTING.DEBUG then
        return
    end
    local ox = 0
    local oy = 0
    local oz = 0
    if dboc[o.name] then
--        print(o.x, o.y, o.z)
        ox = dboc[o.name].x or 0
        oy = dboc[o.name].y or 0
        oz = dboc[o.name].z or 0
    end
    print(o.name .."(".. o.type .. ") x:".. o.x..",y:"..o.y..",z:"..o.z.." ->"..(txt or "") )
    print("DELTA x: ".. math.abs(o.x - ox) .. " y: ".. math.abs(o.y - oy) .. " z: ".. math.abs(o.z - oz))
    dboc[o.name] = {x = o.x, y = o.y, z = o.z}
end
