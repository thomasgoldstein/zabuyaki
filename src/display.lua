-- Display resolution settings

local disp320x240 = {
    inner = {
        resolution = { width = 320, height = 240 },
        minScale = 1,
        maxScale = 0.75,
        YDivider = 2
    },
    final = {
        resolution = { width = 640, height = 480 },
        scale = 2
    }
}

local disp640x480 = {
    inner = {
        resolution = { width = 640, height = 480 },
        minScale = 2,
        maxScale = 1.5,
        YDivider = 2
    },
    final = {
        resolution = { width = 640, height = 480 },
        scale = 1
    }
}

local disp1280x960 = {
    inner = {
        resolution = { width = 1280, height = 960 },
        minScale = 4,
        maxScale = 3,
        YDivider = 2
    },
    final = {
        resolution = { width = 640, height = 480 },
        scale = 0.5
    }
}
--return disp320x240
--return disp640x480
return disp1280x960
