-- Display resolution settings

local disp320x240 = {
    inner = {
        resolution = { width = 320, height = 240 },
        min_scale = 1,
        max_scale = 0.75,
        y_divider = 2
    },
    final = {
        resolution = { width = 640, height = 480 },
        scale = 2
    }
}

local disp640x480 = {
    inner = {
        resolution = { width = 640, height = 480 },
        min_scale = 2,
        max_scale = 1.5,
        y_divider = 2
    },
    final = {
        resolution = { width = 640, height = 480 },
        scale = 1
    }
}

return disp320x240
--return disp640x480