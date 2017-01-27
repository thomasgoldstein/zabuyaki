local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 200 - menu_item_h
local menu_x_offset = 0
local hint_y_offset = 80
local left_item_offset  = 6
local top_item_offset  = 6

function fillMenu(txt_items, txt_hints)
    local m = {}
    local max_item_width, max_item_x = 8, 0
    if not txt_hints then
        txt_hints = {}
    end
    for i = 1, #txt_items do
        local w = gfx.font.arcade4:getWidth(txt_items[i])
        if w > max_item_width then
            max_item_x = menu_x_offset + screen_width / 2 - w / 2
            max_item_width = w
        end
    end
    for i = 1, #txt_items do
        local w = gfx.font.arcade4:getWidth(txt_items[i])
        m[#m + 1] = {
            item = txt_items[i],
            hint = txt_hints[i] or "",
            x = menu_x_offset + screen_width / 2 - w / 2,
            y = menu_y_offset + i * menu_item_h,
            rect_x = max_item_x,
            w = max_item_width,
            h = gfx.font.arcade4:getHeight(txt_items[i]),
            wx = (screen_width - gfx.font.arcade4:getWidth(txt_hints[i] or "")) / 2,
            wy = screen_height - hint_y_offset,
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
    m.wy = screen_height - hint_y_offset
    m.x = menu_x_offset + screen_width / 2 - m.w / 2
    m.y = menu_y_offset + i * menu_item_h
    m.rect_x = menu_x_offset + screen_width / 2 - m.w / 2
    m.wx = (screen_width - gfx.font.arcade4:getWidth(m.hint)) / 2
end