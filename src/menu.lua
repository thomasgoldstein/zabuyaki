local screenWidth = 640
local screenHeight = 480
local menuItem_h = 40
local menuOffset_y = 200 - menuItem_h
local menuOffset_x = 0
local hintOffset_y = 80
local leftItemOffset  = 6
local topItemOffset  = 6

function fillMenu(txtItems, hintsText)
    local m = {}
    local maxItemWidth, maxItem_x = 8, 0
    if not hintsText then
        hintsText = {}
    end
    for i = 1, #txtItems do
        local w = gfx.font.arcade4:getWidth(txtItems[i])
        if w > maxItemWidth then
            maxItem_x = menuOffset_x + screenWidth / 2 - w / 2
            maxItemWidth = w
        end
    end
    for i = 1, #txtItems do
        local w = gfx.font.arcade4:getWidth(txtItems[i])
        m[#m + 1] = {
            item = txtItems[i],
            hint = hintsText[i] or "",
            x = menuOffset_x + screenWidth / 2 - w / 2,
            y = menuOffset_y + i * menuItem_h,
            rect_x = maxItem_x,
            w = maxItemWidth,
            h = gfx.font.arcade4:getHeight(txtItems[i]),
            wx = (screenWidth - gfx.font.arcade4:getWidth(hintsText[i] or "")) / 2,
            wy = screenHeight - hintOffset_y,
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
    m.wy = screenHeight - hintOffset_y
    m.x = menuOffset_x + screenWidth / 2 - m.w / 2
    m.y = menuOffset_y + i * menuItem_h
    m.rect_x = menuOffset_x + screenWidth / 2 - m.w / 2
    m.wx = (screenWidth - gfx.font.arcade4:getWidth(m.hint)) / 2
end