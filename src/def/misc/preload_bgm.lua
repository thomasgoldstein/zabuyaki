local BGM = {}

BGM.load = function(alias, filePath, copyright)
    BGM[alias] = filePath
    local _, fileName, _ = string.match(filePath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
    BGM[#BGM + 1] = {filePath = filePath, alias = alias, fileName = fileName, copyright = copyright or "SubspaceAudio" }
end

--BGM.level01 = BGM.test
--BGM.level00 = {"res/bgm/theme.xm","res/bgm/testtrck.xm"}

BGM.load("intro","res/bgm/rockdrive.xm","J.J")
BGM.load("test","res/bgm/zabutest.xm","Stifu")
BGM.load("title","res/bgm/theme.xm","Don Miguel")
BGM.load("level01","res/bgm/testtrck.xm")

return BGM