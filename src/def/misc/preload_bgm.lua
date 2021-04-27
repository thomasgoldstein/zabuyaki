local BGM = {}

local musicVolume = GLOBAL_SETTING.BGM_VOLUME
local currentMusic = nil
local currentMusicPath = ""

BGM.load = function(alias, filePath, copyright)
    local _, fileName, _ = string.match(filePath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
    BGM[alias] = {filePath = filePath, alias = alias, fileName = fileName, copyright = copyright or "???" }
    BGM[#BGM + 1] = BGM[alias]
end

BGM.setVolume = function(_musicVolume)
    musicVolume = _musicVolume or GLOBAL_SETTING.BGM_VOLUME
    if currentMusic then
        currentMusic:setVolume(musicVolume)
    end
end

BGM.getVolume = function()
    return musicVolume
end

BGM.play = function(alias)
    local musicPath
    if type(alias) == "table" then
        musicPath = alias.filePath
    else
        musicPath = BGM[alias].filePath
    end
    if not musicPath then
        error("Wrong BGM alias")
    end
    if currentMusicPath ~= musicPath then
        BGM.stop()
        currentMusicPath = musicPath
        currentMusic = love.audio.newSource(currentMusicPath, "stream")
        BGM.setVolume()
        currentMusic:setLooping(true)
        currentMusic:play()
    end
end

BGM.stop = function()
    if currentMusic and currentMusic:isPlaying() then
        currentMusic:stop()
        currentMusicPath = ""
    end
end

BGM.pause = function()
    currentMusic:pause()
end

BGM.resume = function()
    currentMusic:play()
end

BGM.load("intro","res/bgm/stage0.xm","J.J")
BGM.load("title","res/bgm/theme.xm","J.J")
BGM.load("zaburap","res/bgm/zaburap.xm", "J.J")
BGM.load("stage1","res/bgm/stage1.xm", "J.J")

return BGM
