-- Display resolution settings

local disp320x240 = {
    inner = {
        resolution = { width = 320, height = 240 },
        min_scale = 2,
        max_scale = 1.5,
    },
    final = {
        resolution = { width = 640, height = 480 },
    }
}

local disp640x480 = {
    inner = {
        resolution = { width = 640, height = 480 },
        min_scale = 4,
        max_scale = 3,
    },
    final = {
        resolution = { width = 640*2, height = 480*2 },
    }
}

--return disp320x240
return disp640x480