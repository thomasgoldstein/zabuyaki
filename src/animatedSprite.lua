--[[
    animatedSprite.lua

    Copyright Dejaime Antonio de Oliveira Neto, 2014
    Mikhail Bratus, 2016-2021

    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]

local ManagerVersion = 0.43

spriteBank = {} --Map with all the sprite definitions
imageBank = {} --Contains all images that were already loaded
missingFilesList = {} -- Missing files to prevent future file operations. eg for _sp.lua defs

local function loadSprite (spriteDef)
    if spriteDef == nil or type(spriteDef) ~= "string" then return nil end
    if missingFilesList[spriteDef] then return nil end
    local definitionFile, errorMsg
    if love.filesystem.getInfo( spriteDef .. '.lua', "file" ) then
        definitionFile, errorMsg = love.filesystem.load( spriteDef .. '.lua' )
        if errorMsg and type(errorMsg) == "string" then
            dp("Error LOADING from existing file loadSprite: "..errorMsg)
        end
    else
        dp("Just Warning loadSprite: missing "..spriteDef..'.lua')
        missingFilesList[spriteDef] = true
        return nil
    end
    local oldSprite = spriteBank [spriteDef]
    spriteBank [spriteDef] = definitionFile()
    --Check the version to verify if it is compatible with this one.
    if spriteBank[spriteDef].serializationVersion ~= ManagerVersion then
        dp("Attempt to load file with incompatible versions: "..spriteDef)
        dp("Expected version "..ManagerVersion..", got version "
            ..spriteBank[spriteDef].serializationVersion.." .")
        spriteBank[spriteDef] = oldSprite -- Undo the changes due to error
        -- Return old value (nil if not previously loaded)
        return spriteBank[spriteDef]
    end
    --Storing the path to the image in a variable (to add readability)
    local spriteSheet = spriteBank[spriteDef].spriteSheet
    imageBank [spriteSheet] = love.graphics.newImage(spriteSheet)
    return spriteBank [spriteDef]
end

function loadSpriteSheet(spriteSheet)
    --Load the image into image bank.
    --returns width, height
    imageBank[spriteSheet] = love.graphics.newImage(spriteSheet)
    return imageBank[spriteSheet]:getDimensions()
end

function removeSpriteFromImageBank(spriteDef)
    if type(spriteDef) == "table" and spriteDef.def then
        spriteDef.def = nil
        spriteDef = nil
    else
        spriteBank[spriteDef] = nil
    end
end

---Returns instance of the defined sprite
---@param spriteDef string Path to the sprite definition file
function getSpriteInstance (spriteDef)
    if spriteDef == nil then return nil end -- invalid use
    if type(spriteDef) == "table" and spriteDef.def then
        return spriteDef -- return pre-loaded sprite instance (used for loot w/o animation or icons)
    end
    if spriteBank[spriteDef] == nil then
        --Sprite not loaded attempting to load; abort on failure.
        if loadSprite (spriteDef) == nil then return nil end
    end
    local s = {
        def = spriteBank[spriteDef], --Sprite reference
        curAnim = nil,
        curFrame = 1,
        maxFrame = 1,
        duration = 0, -- of the whole animation (ignoring the looping). Portraits and _sp animations get 0 duration.
        isThrow = false,
        isFirst = true, -- if the 1st frame
        isLast = false, -- if the last frame
        isFinished = false, -- last frame played till the end and the animation is not a loop
        comboEnd = false, -- stare next combo from 1
        loopCount = 0, -- loop played times
        elapsedTime = 0,
        sizeScale = 1,
        timeScale = 1,
        rotation = 0,
        flipH = 1, -- 1 normal, -1 mirrored
        flipV = 1,	-- same
        isPlatform = spriteBank[spriteDef].isPlatform or false,
        funcCalledOnFrame = -1,
        funcContCalledOnFrame = -1,
    }
    calculateSpriteAnimation(s)
    return s
end

---Set current animation of the current sprite
---@param spr table
---@param anim string
function setSpriteAnimation(spr, anim)
    spr.curFrame = 1
    spr.loopCount = 0
    spr.curAnim = anim
    spr.isFinished = false
    spr.funcCalledOnFrame = -1
    spr.funcContCalledOnFrame = -1
    spr.elapsedTime = 0
    spr.isThrow = spr.def.animations[spr.curAnim].isThrow or false
    spr.comboEnd = spr.def.animations[spr.curAnim].comboEnd or false
    spr.maxFrame = #spr.def.animations[spr.curAnim]
end

---Does the sprite have 'anim' animation?
---@param spr table
---@param anim string
---@return boolean
function spriteHasAnimation(spr, anim)
    if spr.def.animations[anim] then
        return true
    end
    return false
end

local dummyHurtBox = { x = 0, y = 0, width = 0, height = 0, depth = 0 }
function getSpriteHurtBox(spr, frame)
    if not spr then
        return dummyHurtBox
    end
    local sc = spr.def.animations[spr.curAnim][frame or spr.curFrame or 1]
    return sc.hurtBox
end

function fixHurtBox(h)
    assert(h, "Cannot fix an empty hurtBox table.")
    assert(h.width, "HurtBox should contain width key.")
    assert(h.height, "HurtBox should contain height key.")
    if not h.depth then
        h.depth = 7
    end
    if not h.x then
        h.x = 0
    end
    if not h.y then
        h.y = h.height/2
    end
end

function getSpriteQuad(spr, frame_n)
    local sc = spr.def.animations[spr.curAnim][frame_n or spr.curFrame]
    return sc.q
end

function getSpriteAnimationDuration(spr)
    local sc = spr.def.animations[spr.curAnim]
    return sc.duration
end

function getSpriteFrame(spr, frame_n)
    return spr.def.animations[spr.curAnim][frame_n or spr.curFrame]
end

-- get the max animations of the same type: combo4 -> 4
function getMaxSpriteAnimation(spr, anim)
    for i = 1, 10 do
        if not spr.def.animations[anim..i] then
            return i - 1
        end
    end
    return 0
end

function initSpriteAnimationDelaysAndHurtBoxes(spr)
    local animations = spr.def.animations
    if not spr.def.hurtBox then
        --TODO remove default hurtBox on the end
        spr.def.hurtBox = { x = 0, y = 10, width = 10, height = 20 }
    else
        fixHurtBox(spr.def.hurtBox)
    end
    for _, a in pairs(animations) do
        if not a.delay then
            a.delay = spr.def.delay or 0 -- is there default delay for frames of 1 animation or _sp def?
        end
        if not a.hurtBox then
            a.hurtBox = spr.def.hurtBox
            fixHurtBox(a.hurtBox)
        end
        local duration = 0
        for n = 1, #a do
            local sc = a[n]
            if not sc.delay then
                sc.delay = a.delay -- is there delay for this frame?
            end
            duration = duration + sc.delay
            if not sc.hurtBox then
                sc.hurtBox = a.hurtBox
            end
            fixHurtBox(sc.hurtBox)
        end
        a.duration = duration
    end
end

function calculateSpriteAnimation(spr)
    spr.def.comboMax = getMaxSpriteAnimation(spr, "combo")
    spr.def.maxGrabAttack = getMaxSpriteAnimation(spr, "grabFrontAttack")
    initSpriteAnimationDelaysAndHurtBoxes(spr)
end

function updateSpriteInstance(spr, dt, slf)
    local s = spr.def.animations[spr.curAnim]
    local sc = s[spr.curFrame]
    assert(sc, "Missing frame #"..spr.curFrame.." in "..spr.curAnim.." animation")
    -- call custom frame func once per the frame
    if sc.func and spr.funcCalledOnFrame ~= (spr.curFrame + spr.loopCount) and slf then
        spr.funcCalledOnFrame = spr.curFrame + spr.loopCount
        sc.func(slf, false, false) --isfuncCont = false
    end
    -- call the custom frame func on every frame
    if sc.funcCont and slf then
        sc.funcCont(slf, true, sc.attackId) --isfuncCont = true
        spr.funcContCalledOnFrame = spr.curFrame -- do not move before funcCont call
    end
    --Increment the internal counter.
    if dt > 0 then
        spr.elapsedTime = spr.elapsedTime + dt + 0.001
    end
    --We check we need to change the current frame.
    if spr.elapsedTime > sc.delay * spr.timeScale then
        --Check if we are at the last frame.
        if spr.curFrame < #s then
            -- Not on last frame, increment.
            spr.curFrame = spr.curFrame + 1
        else
            -- Last frame, loop back to 1.
            if s.loop then	--if cycled animation
                spr.curFrame = s.loopFrom or 1
                spr.loopCount = spr.loopCount + 1 --loop played times++
            else
                spr.isFinished = true
            end
        end
        -- Reset internal counter on frame change.
        spr.elapsedTime = 0
    end
    -- First or Last frames or the 1st start frame after the loop?
    spr.isFirst = (spr.curFrame == 1)
    spr.isLast = (spr.curFrame == #s)
    spr.isLoopFrom = (spr.curFrame == (s.loopFrom or 1))
end

function drawSpriteInstance (spr, x, y, frame)
    local sc = spr.def.animations[spr.curAnim][frame or spr.curFrame or 1]
    local scale_h, scale_v, flipH, flipV = sc.scale_h or 1, sc.scale_v or 1, sc.flipH or 1, sc.flipV or 1
    local rotate, rx, ry = sc.rotate or 0, sc.rx or 0, sc.ry or 0 --due to rotation we have to adjust spr pos
    local y_shift = y
    if flipV == -1 then
        y_shift = y - sc.oy * spr.sizeScale
    end
    love.graphics.draw (
        imageBank[spr.def.spriteSheet], --The image
        sc.q, --Current frame of the current animation
        math.floor(x + rx * spr.flipH * flipH), math.floor(y_shift + ry),
        (spr.rotation + rotate) * spr.flipH * flipH,
        spr.sizeScale * spr.flipH * scale_h * flipH,
        spr.sizeScale * spr.flipV * scale_v * flipV,
        sc.ox, sc.oy
    )
end

function drawSpriteCustomInstance(spr, x, y, curAnim, frame)
    local sc = spr.def.animations[curAnim][frame]
    assert(sc, "Animation '"..curAnim.."' is missing frame #"..(frame or -1))
    local scale_h, scale_v, flipH, flipV = sc.scale_h or 1, sc.scale_v or 1, sc.flipH or 1, sc.flipV or 1
    local rotate, rx, ry = sc.rotate or 0, sc.rx or 0, sc.ry or 0 --due to rotation we have to adjust spr pos
    local y_shift = y
    if flipV == -1 then
        y_shift = y - sc.oy * spr.sizeScale
    end
    love.graphics.draw (
        imageBank[spr.def.spriteSheet], --The image
        sc.q, --Current frame of the current animation
        math.floor(x + rx * spr.flipH * flipH), math.floor(y_shift + ry),
        (spr.rotation + rotate) * spr.flipH * flipH,
        spr.sizeScale * spr.flipH * scale_h * flipH,
        spr.sizeScale * spr.flipV * scale_v * flipV,
        sc.ox, sc.oy
    )
end

function parseSpriteAnimation(spr, curAnim)
    if (curAnim or spr.curAnim) == "icon" then
        return "Cannot parse icons"
    end
    local o = (curAnim or spr.curAnim).." = {\n"

    local animations = spr.def.animations[curAnim or spr.curAnim]
    local sc
    local scale_h, scale_v, flipH, flipV, func, funcCont, attackId
    local ox, oy, delay
    local x, y, w, h
    local rotate, rx, ry

    for i = 1, #animations do
        sc = animations[i]
        delay = sc.delay or 100
        scale_h, scale_v, flipH, flipV = sc.scale_h or 1, sc.scale_v or 1, sc.flipH or 1, sc.flipV or 1
        rotate, rx, ry = sc.rotate or 0, sc.rx or 0, sc.ry or 0
        ox, oy = sc.ox or 0, sc.oy or 0
        x, y, w, h = sc.q:getViewport( )
        func, funcCont = sc.func, sc.funcCont
        attackId = sc.attackId

        o = o .. "    { q = q("..x..","..y..","..w..","..h.."), ox = "..ox..", oy = "..oy
        if delay ~= animations.delay then
            o = o .. ", delay = "..delay
        end
        if rotate ~= 0 then
            o = o .. ", rotate = "..rotate
        end
        if rx ~= 0 then
            o = o .. ", rx = "..rx
        end
        if ry ~= 0 then
            o = o .. ", ry = "..ry
        end
        if flipH ~= 1 then
            o = o .. ", flipH = "..flipH
        end
        if flipV ~= 1 then
            o = o .. ", flipV = "..flipV
        end
        if func then
            o = o .. ", func = FUNC0"
        end
        if funcCont then
            o = o .. ", funcCont = FUNC1"
        end
        if attackId then
            o = o .. ", attackId = "..attackId
        end
        o = o .. " },\n"
    end
    if animations.loop then
        o = o .. "    loop = true,\n"
    end
    if animations.loopFrom then
        o = o .. "    loopFrom = "..animations.loopFrom..",\n"
    end
    if animations.delay then
        o = o .. "    delay = "..animations.delay..",\n"
    end
    o = o .. "},\n"
    return o
end
