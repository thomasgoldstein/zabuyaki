local BGM = {}

local musicVolume = GLOBAL_SETTING.BGM_VOLUME
local currentMusic = nil

BGM.load = function(alias, filePath, copyright)
    BGM[alias] = filePath
    local _, fileName, _ = string.match(filePath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
    BGM[#BGM + 1] = {filePath = filePath, alias = alias, fileName = fileName, copyright = copyright or "SubspaceAudio" }
end

BGM.setVolume = function(_musicVolume)
    musicVolume = _musicVolume or GLOBAL_SETTING.BGM_VOLUME
    if currentMusic then
        currentMusic:setVolume(musicVolume)
    end
end

BGM.play = function(_music)
    currentMusic = nil
end

BGM.stop = function()
    if currentMusic and currentMusic:isPlaying() then
        currentMusic:stop()
    end
end

--BGM.level01 = BGM.test
--BGM.level00 = {"res/bgm/theme.xm","res/bgm/testtrck.xm"}

BGM.load("intro","res/bgm/introtemp.ogg","J.J")
BGM.load("test","res/bgm/zabutest.xm","Stifu")
BGM.load("title","res/bgm/theme.xm","Don Miguel")
BGM.load("level01","res/bgm/testtrck.xm")
BGM.load("zaburap","res/bgm/zaburap.xm")
BGM.load("stage1","res/bgm/stage1.xm")

return BGM
