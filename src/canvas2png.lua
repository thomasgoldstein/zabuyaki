-- Debug graphics output

function saveCanvas(canvas, name)
    local image = canvas:newImageData( )
    local filedata = image:encode("png",(name or "_")..".png")
end

function saveAllCanvasesToPng()
    for i = 1, 3 do
        saveCanvas(canvas[i], "canvas"..i)
    end
end
