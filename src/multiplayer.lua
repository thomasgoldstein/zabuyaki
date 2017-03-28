-- Common multiplayer routines

function createSelectedPlayers(players)
    player1 = nil
    player2 = nil
    player3 = nil

    local top_floor_y = 454

    GLOBAL_UNIT_ID = 1  --recalc players IDs for proper life bar coords
    -- create players
    if players[1] then
        player1 = players[1].hero:new(players[1].name,
            GetSpriteInstance(players[1].sprite_instance),
            Control1,
            60, top_floor_y + 65,
            {
                --shapeType = "polygon", shapeArgs = { 1, 0, 13, 0, 14, 3, 13, 6, 1, 6, 0, 3 },
                shader = players[1].shader, color = {255,255,255, 255 }
            }
        )
    end
    GLOBAL_UNIT_ID = 2  --recalc players IDs for proper life bar coords
    if players[2] then
        player2 = players[2].hero:new(players[2].name,
            GetSpriteInstance(players[2].sprite_instance),
            Control2,
            90, top_floor_y + 35,
            { shader = players[2].shader }
        )
    end
    GLOBAL_UNIT_ID = 3  --recalc players IDs for proper life bar coords
    if players[3] then
        player3 = players[3].hero:new(players[3].name,
            GetSpriteInstance(players[3].sprite_instance),
            Control3,
            120, top_floor_y + 5,
            { shader = players[3].shader }
        )
    end
end

function addPlayersToStage(stage)
    if player1 then
        stage.objects:add(player1)
    end
    if player2 then
        stage.objects:add(player2)
    end
    if player3 then
        stage.objects:add(player3)
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
