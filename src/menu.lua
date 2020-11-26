function fillMenu(txtItems, hintsText, optionalParams)
    local m = {
        params = optionalParams or {
            center = true,
            screenWidth = 640,
            screenHeight = 480,
            menuItem_h = 40,
            menuOffset_y = 160,
            menuOffset_x = 0,
            hintOffset_y = 80,
            titleOffset_y = 14,
            leftItemOffset = 6,
            topItemOffset = 6,
            itemWidthMargin = 12,
            itemHeightMargin = 10
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
            x = m.params.center and (m.params.menuOffset_x + m.params.screenWidth / 2 - w / 2) or (m.params.menuOffset_x),
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
    m.x = menu.params.center and (menu.params.menuOffset_x + menu.params.screenWidth / 2 - m.w / 2) or (menu.params.menuOffset_x)
    m.rect_x = menu.params.center and (menu.params.menuOffset_x + menu.params.screenWidth / 2 - m.w / 2) or (menu.params.menuOffset_x)
    m.wx = (menu.params.screenWidth - gfx.font.arcade4:getWidth(m.hint)) / 2
end

function drawMenuItem(menu, i, oldMenuState, color)
    calcMenuItem(menu, i)
    local m = menu[i]
    if i == oldMenuState then
        colors:set("lightGray")
        love.graphics.print(m.hint, m.wx, m.wy)
        colors:set("black", nil, 80)
        love.graphics.rectangle("fill", m.rect_x - menu.params.leftItemOffset, m.y - menu.params.topItemOffset, m.w + menu.params.itemWidthMargin, m.h + menu.params.itemHeightMargin, 4,4,1)
        colors:set("menuOutline")
        love.graphics.rectangle("line", m.rect_x - menu.params.leftItemOffset, m.y - menu.params.topItemOffset, m.w + menu.params.itemWidthMargin, m.h + menu.params.itemHeightMargin, 4,4,1)
    end
    colors:set(color or "white")
    love.graphics.print(m.item, m.x, m.y )
end

function drawMenuTitle(menu, logo, transparency, _scale)
    local scale = _scale or 1
    colors:set("white", nil, transparency)
    love.graphics.draw(logo, (menu.params.screenWidth - logo:getWidth() * scale) / 2, menu.params.titleOffset_y, 0, scale, scale)
end
