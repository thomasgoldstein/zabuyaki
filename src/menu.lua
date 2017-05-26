local screenWidth = 640
local screenHeight = 480
local menuItem_h = 40
local menu_yOffset = 200 - menuItem_h
local menu_xOffset = 0
local hint_yOffset = 80
local leftItemOffset  = 6
local topItemOffset  = 6

function fillMenu(txtItems, txt_hints)
    local m = {}
    local maxItemWidth, maxItem_x = 8, 0
    if not txt_hints then
        txt_hints = {}
    end
    for i = 1, #txtItems do
        local w = gfx.font.arcade4:getWidth(txtItems[i])
        if w > maxItemWidth then
            maxItem_x = menu_xOffset + screenWidth / 2 - w / 2
            maxItemWidth = w
        end
    end
    for i = 1, #txtItems do
        local w = gfx.font.arcade4:getWidth(txtItems[i])
        m[#m + 1] = {
            item = txtItems[i],
            hint = txt_hints[i] or "",
            x = menu_xOffset + screenWidth / 2 - w / 2,
            y = menu_yOffset + i * menuItem_h,
            rect_x = maxItem_x,
            w = maxItemWidth,
            h = gfx.font.arcade4:getHeight(txtItems[i]),
            wx = (screenWidth - gfx.font.arcade4:getWidth(txt_hints[i] or "")) / 2,
            wy = screenHeight - hint_yOffset,
            n = 1
        }
    end
    return m
end

function calcMenuItem(menu, i)
    assert(menu and menu[i], "menu item error")
    local m = menu[i]
    m.w = gfx.font.arcade4:getWidth(m.item)
    m.h = gfx.font.arcade4:getHeight(m.item)
    m.wy = screenHeight - hint_yOffset
    m.x = menu_xOffset + screenWidth / 2 - m.w / 2
    m.y = menu_yOffset + i * menuItem_h
    m.rect_x = menu_xOffset + screenWidth / 2 - m.w / 2
    m.wx = (screenWidth - gfx.font.arcade4:getWidth(m.hint)) / 2
end