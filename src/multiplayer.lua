-- Common multiplayer routines

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
end

function getRegisteredPlayer(id)
    print("getRegisteredPlayer id:"..id)
    return players[id]
end

function checkPlayersRespawn(stage)
    local p = SELECT_NEW_PLAYER
    if p[#p] then
        p[#p].player.player_select_mode = 3 -- Respawn mode
        if p[#p].id == 1 then
            stage.world:remove(player1.shape)
            stage.objects:remove(player1)
            player1 = p[#p].player
            player1:setOnStage(stage)
        elseif p[#p].id == 2 then
            stage.world:remove(player2.shape)
            stage.objects:remove(player2)
            player2 = p[#p].player
            player2:setOnStage(stage)
        elseif p[#p].id == 3 then
            stage.world:remove(player3.shape)
            stage.objects:remove(player3)
            player3 = p[#p].player
            player3:setOnStage(stage)
        end
        p[#p] = nil
    end
end

function allowPlayersSelect(players)
    if playerSelectState.enable_player_select_on_start then
        --Let select 3 players in the beginning of the stage for DEBUG
        if players[1] then
            player1.lives = 0
            player1:setState(player1.useCredit)
            player1.isDisabled = true
            player1.cool_down = 10
            player1.player_select_mode = 0
        end
        if players[2] then
            player2.lives = 0
            player2:setState(player2.useCredit)
            player2.isDisabled = true
            player2.cool_down = 10
            player2.player_select_mode = 0
        end
        if players[3] then
            player3.lives = 0
            player3:setState(player3.useCredit)
            player3.isDisabled = true
            player3.cool_down = 10
            player3.player_select_mode = 0
        end
    end
end

function areAllPlayersAlive()
    local is_alive = false
    if player1 then
        is_alive = is_alive or player1:isAlive()
    end
    if player2 then
        is_alive = is_alive or player2:isAlive()
    end
    if player3 then
        is_alive = is_alive or player3:isAlive()
    end
    return is_alive
end

function killAllPlayers()
    if player1 then
        if player1:isAlive() and not player1:isInUseCreditMode() then
            player1.hp = 0
            player1.face = -player1.face
            player1:applyDamage(0, "fall", nil)
        end
    end
    if player2 then
        if player2:isAlive() and not player2:isInUseCreditMode() then
            player2.hp = 0
            player2.face = -player2.face
            player2:applyDamage(0, "fall", nil)
        end
    end
    if player3 then
        if player3:isAlive() and not player3:isInUseCreditMode() then
            player3.hp = 0
            player3.face = -player3.face
            player3:applyDamage(0, "fall", nil)
        end
    end
end

function drawPlayersBars()
    if player1 then
        player1.infoBar:draw(0,0)
        if player1.victim_infoBar then
            player1.victim_infoBar:draw(0,0)
        end
    end
    if player2 then
        player2.infoBar:draw(0,0)
        if player2.victim_infoBar then
            player2.victim_infoBar:draw(0,0)
        end
    end
    if player3 then
        player3.infoBar:draw(0,0)
        if player3.victim_infoBar then
            player3.victim_infoBar:draw(0,0)
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
--    print("FIX PAL!")
    local n = player.palette
    local palettes = {}
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local p = getRegisteredPlayer(i)
        if p and p.palette then
--            print("p.palette = ", p.palette)
            if p ~= player and p.name == player.name then
                palettes[p.palette] = true
            end
        else
--            print("p.palette = nil")
        end
    end
--    print("PALS", inspect(palettes))
    if palettes[n] then --this palette is used by others already
        for i = 0, max_player_palette do
            if not palettes[i] then
                n = i
                break
            end
        end
    end
    player.palette = n
    player.shader = getShader(player.sprite.def.sprite_name:lower(), player.palette)
end

function fixPlayersPalette_(player)
    local n = player.palette
--    print("!!! "..player.name.." ",n, player1.name, player2.name, player3.name)
--    print("!! ID "..player.id.." ", player1.id, player2.id, player3.id)
    if not n or n < 0 or n > max_player_palette then
        n = 0
        player.palette = n
    end
    if player1 and player.id ~= player1.id
            and player.name == player1.name --and player1:isAlive() --and not player1:isInUseCreditMode()
            and n == player1.palette
    then
        n = shift_palette_up(n)
    end
    if player2 and player.id ~= player2.id
            and player.name == player2.name --and player2:isAlive() --and not player2:isInUseCreditMode()
            and n == player2.palette
    then
        n = shift_palette_up(n)
    end
    if player3 and player.id ~= player3.id
            and player.name == player3.name --and player3:isAlive() --and not player3:isInUseCreditMode()
            and n == player3.palette
    then
        n = shift_palette_up(n)
    end
    player.palette = n
    player.shader = getShader(player.sprite.def.sprite_name:lower(), player.palette)
end

-- Returns Center X, distance between players, minX, maxX
local old_minx, old_maxx, old_y
function getDistanceBetweenPlayers()
    local minx, maxx = nil, nil
    local p = { player1, player2, player3 }
    local n = 0
    for i = 1, #p do
        local player = p[i]
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
        end
    end
    if n < 1 then
        if not old_minx then
            old_minx = 0
            old_maxx = 0
        end
        return old_minx + (old_maxx - old_minx) / 2, old_maxx - old_minx, old_minx, old_maxx
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

function _getDistanceToClosestPlayer()
    local p = {}
    if player1 then
        p[#p +1] = {player = player1, points = 0 }
    end
    if player2 then
        p[#p +1] = {player = player2, points = 0 }
    end
    if player3 then
        p[#p +1] = {player = player3, points = 0}
    end
    for i = 1, #p do
        p[i].points = dist(self.x, self.y, p[i].player.x, p[i].player.y)
    end

    table.sort(p, function(a,b)
        return a.points < b.points
    end )

    if #p < 1 then
        return 9000
    end
    return p[1].points
end
