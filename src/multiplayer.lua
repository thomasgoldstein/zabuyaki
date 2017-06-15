-- Common multiplayer routines

function checkPlayersRespawn(stage)
    local p = SELECT_NEW_PLAYER
    if p[#p] then
        local deletePlayer = p[#p].deletePlayer
        p[#p].player.playerSelectMode = 3 -- Respawn mode
        stage.world:remove(deletePlayer.shape)
        stage.objects:remove(deletePlayer)
        deletePlayer = p[#p].player
        deletePlayer:setOnStage(stage)
        p[#p] = nil
    end
end

function allowPlayersSelect(players)
    if playerSelectState.enablePlayerSelectOnStart then
        --Let select 3 players in the beginning of the stage for DEBUG
        for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
            local player = getRegisteredPlayer(i)
            if player then
                player.lives = 0
                player:setState(player.useCredit)
                player.isDisabled = true
                player.cooldown = 10
                player.playerSelectMode = 0
            end
        end
    end
end

function areThereAlivePlayers()
    local is_alive = false
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player then
            is_alive = is_alive or player:isAlive()
        end
    end
    return is_alive
end

function killAllPlayers()
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and player:isAlive() and not player:isInUseCreditMode() then
            player.hp = 0
            player.face = -player.face
            player:applyDamage(0, "fall", nil)
        end
    end
end

function drawPlayersBars()
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and player:isAlive() then
            player.infoBar:draw(0,0)
            if player.victimInfoBar and player:isAlive() then
                player.victimInfoBar:draw(0,0)
            end
        end
    end
end

local max_player_palette = 6
local function shift_palette_up(n)
    local old_n = n
    if not n or n < 0 then
        n = -1
    end
    n = n + 1
    if n > max_player_palette then
        n = 0
    end
--    print(" ==> "..old_n.." shift palette to "..n)
    return n
end
function fixPlayersPalette(player)
    local n = player.palette
    local palettes = {}
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local p = getRegisteredPlayer(i)
        if p and p.palette
            and p ~= player and p.name == player.name
                --other player selecting on respawning
            and ( p.state ~= "useCredit" or ( p.playerSelectMode == 2 and p.playerSelectMode == 3 ) )
        then
            palettes[p.palette] = true
        end
    end
    if palettes[n] then --this palette is used by others already
        for i = 0, max_player_palette do
            if not palettes[i] then
                n = i
                break
            end
        end
    end
    player.palette = n
    player.shader = getShader(player.sprite.def.spriteName:lower(), player.palette)
end

-- Returns Center X, distance between players, minX, maxX
local old_minx, old_maxx, old_y
function getDistanceBetweenPlayers()
    local minx, maxx = nil, nil
    local r_x, r_y = nil, nil
    local n = 0
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and player:isAlive() then
            n = n + 1
            old_y = player.y
            if minx then
                minx = math.min(player.x, minx)
                maxx = math.max(player.x, maxx)
            else
                minx = player.x
                maxx = player.x
            end
            r_x, r_y = player.x, player.y
        end
    end
    if n < 1 then
        if not old_minx then
            old_minx = 0
            old_maxx = 0
        end
        return old_minx + (old_maxx - old_minx) / 2, old_maxx - old_minx, old_minx, old_maxx
    elseif n == 1 then
        minx, maxx = r_x, r_x
    end
    old_minx, old_maxx = minx, maxx
    return minx + (maxx - minx) / 2, maxx - minx, minx, maxx
end

function correctPlayersRespawnPos(player)
    print(player.x, player.y, " CORRECT -> ")
    if old_y then
        player.x = (old_maxx - old_minx) / 2
        player.y = old_y
        player:checkCollisionAndMove(0)
        print(" -> ",player.x, player.y)
    end
end

local players = {}
function registerPlayer(player)
    print("registerPlayer id:"..player.id)
    if not player then
        error("no player data")
    elseif player.id and player.id < 1 or player.id > GLOBAL_SETTING.MAX_PLAYERS then
        return
        --error("wrong player id:"..player.id)
    end
    players[player.id] = player
end

function unregisterPlayer(player)
    print("unregisterPlayer id:"..player.id)
    if not player then
        error("no player data")
    elseif player.id < 1 or player.id > GLOBAL_SETTING.MAX_PLAYERS then
        error("wrong player id:"..player.id)
    end
    players[player.id] = nil
end

function cleanRegisteredPlayers()
    print("cleanRegisteredPlayers")
    players = {}
    old_minx, old_maxx, old_y = nil, nil, nil
end

function getRegisteredPlayer(id)
    --print("getRegisteredPlayer id:"..id)
    return players[id]
end