function fillMenu(txtItems, hintsText, optionalParams)
    local m = {
        params = optionalParams or {
            screenWidth = 640,
            screenHeight = 480,
            menuItem_h = 40,
            menuOffset_y = 200 - 40, -- - menuItem_h
            menuOffset_x = 0,
            hintOffset_y = 80,
            leftItemOffset = 6,
            topItemOffset = 6,
        }
    }
    local maxItemWidth, maxItem_x = 8, 0
    if not hintsText then
        hintsText = {}
    end
    for i = 1, #txtItems do
        local w = gfx.font.arcade4:getWidth(txtItems[i])
        if w > maxItemWidth then
            maxItem_x = m.params.menuOffset_x + m.params.screenWidth / 2 - w / 2
            maxItemWidth = w
        end
    end
    for i = 1, #txtItems do
        local w = gfx.font.arcade4:getWidth(txtItems[i])
        m[#m + 1] = {
            item = txtItems[i],
            hint = hintsText[i] or "",
            x = m.params.menuOffset_x + m.params.screenWidth / 2 - w / 2,
            y = m.params.menuOffset_y + i * m.params.menuItem_h,
            rect_x = maxItem_x,
            w = maxItemWidth,
            h = gfx.font.arcade4:getHeight(txtItems[i]),
            wx = (m.params.screenWidth - gfx.font.arcade4:getWidth(hintsText[i] or "")) / 2,
            wy = m.params.screenHeight - m.params.hintOffset_y,
            n = 1
        }
    end
    return m
end

function calcMenuItem(menu, i)
    local m = menu[i]
    m.w = gfx.font.arcade4:getWidth(m.item)
    m.h = gfx.font.arcade4:getHeight(m.item)
    m.wy = menu.params.screenHeight - menu.params.hintOffset_y
    m.x = menu.params.menuOffset_x + menu.params.screenWidth / 2 - m.w / 2
    m.y = menu.params.menuOffset_y + i * menu.params.menuItem_h
    m.rect_x = menu.params.menuOffset_x + menu.params.screenWidth / 2 - m.w / 2
    m.wx = (menu.params.screenWidth - gfx.font.arcade4:getWidth(m.hint)) / 2
end
