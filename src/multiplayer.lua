-- Common multiplayer routines

function checkPlayersRespawn(stage)
    local p = SELECT_NEW_PLAYER
    if p[#p] then
        local deletePlayer = p[#p].deletePlayer
        p[#p].player.playerSelectMode = 3 -- Respawn mode
        stage.objects:remove(deletePlayer)
        deletePlayer = p[#p].player
        deletePlayer:setOnStage(stage)
        p[#p] = nil
    end
end

function doInstantPlayersSelect()
    if playerSelectState.enablePlayerSelectOnStart then
        --Let select players in the beginning of the stage for DEBUG
        for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
            local player = getRegisteredPlayer(i)
            if player then
                player.lives = 0
                player:setState(player.useCredit)
                player.isDisabled = true
                player.displayDelay = 10
                player.playerSelectMode = 0
            end
        end
        playerSelectState.enablePlayerSelectOnStart = false
    end
end

function countAlivePlayers(ignoreCreditState)
    local nAlive = 0
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and player:isAlive() and ( ignoreCreditState or player:isInUseCreditMode() ) then
            nAlive = nAlive + 1
        end
    end
    return nAlive
end

function killAllPlayers()
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and player:isAlive() and not player:isInUseCreditMode() then
            player.hp = 0
            player:setState(player.slide)
            player:applyDamage(0, "fell", player)
        end
    end
end

function drawPlayersBars()
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and player:isAlive() then
            if player.lifeBar then
                player.lifeBar:draw(0,0)
            end
            if player.victimLifeBar and player.lifeBarTimer >= 0 then
                player.victimLifeBar:setPositionUnderAttackersBar(player)
                player.victimLifeBar:draw(0, 0, nil, nil, player)
            end
        end
    end
end

function fixPlayersPalette(player)
    local palettes = {}
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local p = getRegisteredPlayer(i)
        if p and p.palette
            and p ~= player and p.name == player.name
                -- other player is selecting the same character on respawn
            and ( not p:isInUseCreditMode() or ( p.playerSelectMode == 2 and p.playerSelectMode == 3 ) )
        then
            palettes[p.palette] = true
        end
    end
    if palettes[player.palette] then --this palette is used by other players of the same character already
        for i = 1, GLOBAL_SETTING.MAX_PLAYERS do    -- # of palettes per player
            if not palettes[i] then
                player.palette = i
                break
            end
        end
    end
    player.shader = getShader(player.sprite.def.spriteName:lower(), player.palette)
end

-- Returns Center X, distance between players, min_x, max_x
local oldMin_x, oldMax_x, old_y
function getDistanceBetweenPlayers()
    local min_x, max_x
    local r_x, r_y
    local n = 0
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and ( player.hp > 0 or player.deathDelay > 0.5 ) then
            n = n + 1
            old_y = player.y
            if min_x then
                min_x = math.min(player.x, min_x)
                max_x = math.max(player.x, max_x)
            else
                min_x = player.x
                max_x = player.x
            end
            r_x, r_y = player.x, player.y
        end
    end
    if n < 1 then
        if not oldMin_x then
            oldMin_x = 0
            oldMax_x = 0
        end
        return oldMin_x + (oldMax_x - oldMin_x) / 2, oldMax_x - oldMin_x, oldMin_x, oldMax_x
    elseif n == 1 then
        min_x, max_x = r_x, r_x
    end
    oldMin_x, oldMax_x = min_x, max_x
    return min_x + (max_x - min_x) / 2, max_x - min_x, min_x, max_x
end

local players = {}
function registerPlayer(player)
--    print("registerPlayer id:"..player.id)
    if not player then
        error("no player data")
    elseif player.id and player.id < 1 or player.id > GLOBAL_SETTING.MAX_PLAYERS then
        return
        --error("wrong player id:"..player.id)
    end
    players[player.id] = player
end

function unregisterPlayer(player)
--    print("unregisterPlayer id:"..player.id)
    if not player then
        error("no player data")
    elseif player.id < 1 or player.id > GLOBAL_SETTING.MAX_PLAYERS then
        error("wrong player id:"..player.id)
    end
    player.isDisabled = true
    players[player.id] = nil
end

function cleanRegisteredPlayers()
--    print("cleanRegisteredPlayers")
    players = {}
    oldMin_x, oldMax_x, old_y = nil, nil, nil
end

function getRegisteredPlayer(id)
    --print("getRegisteredPlayer id:"..id)
    return players[id]
end
