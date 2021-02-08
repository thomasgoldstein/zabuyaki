-- Display resolution, inner canvas, zooming settings
return {
    inner = {
        resolution = { width = 1280, height = 960 },
    },
    final = {
        resolution = { width = 640, height = 480 },
        scale = 0.5
    },
    zoom = {
        minScale = 4, -- zoom in. default value
        maxScale = 3.2, -- zoom out. default value
        zoomSpeed = 2, -- speed of zoom-in-out transition
        maxDistanceNoZoom = 200, -- between players
        minDistanceToKeepZoom = 190, -- between players
    }
}
