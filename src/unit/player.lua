local class = require "lib/middleclass"
local Player = class('Player', Character)

local function nop() end
local CheckCollision = CheckCollision

function Player:initialize(name, sprite, input, x, y, f)
    if not f then
        f = {}
    end
    self.lives = GLOBAL_SETTING.MAX_LIVES
    self.hp = f.hp or self.hp or 100
    Character.initialize(self, name, sprite, input, x, y, f)
    self.type = "player"
    self.friendlyDamage = 1 --1 = full damage on other players
end

function Player:setOnStage(stage)
    self.pid = GLOBAL_SETTING.PLAYERS_NAMES[self.id] or "P?"
    self.showPIDCoolDown = 3
    Unit.setOnStage(self, stage)
    registerPlayer(self)
end

function Player:isAlive()
    if (self.playerSelectMode == 0 and credits > 0 and self.state == "useCredit")
            or (self.playerSelectMode >= 1 and self.playerSelectMode < 5)
    then
        return true
    elseif self.playerSelectMode >= 5 then
        -- Did not use continue
        return false
    end
    return self.hp + self.lives > 0
end

function Player:isInUseCreditMode()
    if self.state ~= "useCredit" then
        return false
    end
    return true
end

function Player:setState(state, condition)
    if state then
        self.prevStateTime = self.lastStateTime
        self.lastStateTime = love.timer.getTime()
        self.prevState = self.lastState
        self.lastState = self.state
        self.lastFace = self.face
        self.lastVertical = self.vertical
        self:exit()
        self:checkStuckButtons()
        self.state = state.name
        self.draw = state.draw
        self.update = state.update
        self.start = state.start
        self.exit = state.exit
        self.condition = condition
        self:start()
        self:updateSprite(0)
    end
end

-- Start of Lifebar elements
local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency
function Player:drawTextInfo(l, t, transp_bg, icon_width, normColor)
    love.graphics.setColor(255, 255, 255, transp_bg)
    printWithShadow(self.name, l + self.shake.x + icon_width + 2, t + 9,
        transp_bg)
    local c = GLOBAL_SETTING.PLAYERS_COLORS[self.id]
    if c then
        c[4] = transp_bg
        love.graphics.setColor(unpack( c ))
    end
    printWithShadow(self.pid, l + self.shake.x + icon_width + 2, t - 1,
        transp_bg)
    love.graphics.setColor(normColor[1], normColor[2], normColor[3], transp_bg)
    printWithShadow(string.format("%06d", self.score), l + self.shake.x + icon_width + 34, t - 1,
        transp_bg)
    if self.lives >= 1 then
        love.graphics.setColor(255, 255, 255, transp_bg)
        printWithShadow("x", l + self.shake.x + icon_width + 91, t + 9,
            transp_bg)
        love.graphics.setFont(gfx.font.arcade3x2)
        if self.lives > 10 then
            printWithShadow("9+", l + self.shake.x + icon_width + 100, t + 1,
                transp_bg)
        else
            printWithShadow(self.lives - 1, l + self.shake.x + icon_width + 100, t + 1,
                transp_bg)
        end
    end
end

function Player:drawBar(l,t,w,h, icon_width, normColor)
    love.graphics.setFont(gfx.font.arcade3)
    local transp_bg = 255 * calcBarTransparency(3)
    local playerSelectMode = self.source.playerSelectMode
    if self.source.lives > 0 then
        -- Default draw
        if self.source.state == "respawn" then
            -- Fade-in and drop down bar while player falls (respawns)
            transp_bg = 255 - self.source.z
            t = t - self.source.z / 2
        end
        self:draw_lifebar(l, t, transp_bg)
        self:drawFaceIcon(l + self.source.shake.x, t, transp_bg)
        self:draw_dead_cross(l, t, transp_bg)
        self.source:drawTextInfo(l + self.x, t + self.y, transp_bg, icon_width, normColor)
    else
        love.graphics.setColor(255, 255, 255, transp_bg)
        if playerSelectMode == 0 then
            -- wait press to use credit
            printWithShadow("CONTINUE x"..tonumber(credits), l + self.x + 2, t + self.y + 9,
                transp_bg)
            love.graphics.setColor(255,255,255, 200 + 55 * math.sin(self.coolDown*2 + 17))
            printWithShadow(self.source.pid .. " PRESS ATTACK (".. math.floor(self.source.coolDown) ..")", l + self.x + 2, t + self.y + 9 + 11,
                transp_bg)
        elseif playerSelectMode == 1 then
            -- wait 1 sec before player select
            printWithShadow("CONTINUE x"..tonumber(credits), l + self.x + 2, t + self.y + 9,
                transp_bg)
        elseif playerSelectMode == 2 then
            -- Select Player
            printWithShadow(self.source.name, l + self.x + self.source.shake.x + icon_width + 2, t + self.y + 9,
                transp_bg)
            local c = GLOBAL_SETTING.PLAYERS_COLORS[self.source.id]
            if c then
                c[4] = transp_bg
                love.graphics.setColor(unpack( c ))
            end
            printWithShadow(self.source.pid, l + self.x + self.source.shake.x + icon_width + 2, t + self.y - 1,
                transp_bg)
            --printWithShadow("<     " .. self.source.name .. "     >", l + self.x + 2 + math.floor(2 * math.sin(self.coolDown*4)), t + self.y + 9 + 11 )
            self:drawFaceIcon(l + self.source.shake.x, t, transp_bg)
            love.graphics.setColor(255,255,255, 200 + 55 * math.sin(self.coolDown*3 + 17))
            printWithShadow("SELECT PLAYER (".. math.floor(self.source.coolDown) ..")", l + self.x + 2, t + self.y + 19,
                transp_bg)
        elseif playerSelectMode == 3 then
            -- Spawn selecterd player
        elseif playerSelectMode == 4 then
            -- Replace this player with the new character
        elseif playerSelectMode == 5 then
            -- Game Over (too late)
            love.graphics.setColor(255,255,255, 200 + 55 * math.sin(self.coolDown*0.5 + 17))
            printWithShadow(self.source.pid .. " GAME OVER", l + self.x + 2, t + self.y + 9,
                transp_bg)
        end
    end
end
-- End of Lifebar elements

function Player:checkCollisionAndMove(dt)
    local success = true
    if self.move then
        self.move:update(dt) --tweening
        self.shape:moveTo(self.x, self.y)
    else
        local stepx = self.velx * dt * self.horizontal
        local stepy = self.vely * dt * self.vertical
        self.shape:moveTo(self.x + stepx, self.y + stepy)
    end
    if self.z <= 0 then
        for other, separating_vector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.type == "wall"
                    or (o.type == "obstacle" and o.z <= 0 and o.hp > 0)
                or o.type == "stopper"
            then
                self.shape:move(separating_vector.x, separating_vector.y)
                success = false
            end
        end
    else
        for other, separating_vector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.type == "wall"
                or o.type == "stopper"
            then
                self.shape:move(separating_vector.x, separating_vector.y)
                success = false
            end
        end
    end
    local cx,cy = self.shape:center()
    self.x = cx
    self.y = cy
    return success
end

function Player:isStuck()
    for other, separating_vector in pairs(stage.world:collisions(self.shape)) do
        local o = other.obj
        if o.type == "wall"
                or o.type == "stopper"
        then
--            print(self.name, self.x, "STUCK")
            return true
        end
    end
    return false
end

function Player:hasPlaceToStand(x, y)
    local test_shape = stage.test_shape
    test_shape:moveTo(x, y)
    for other, separating_vector in pairs(stage.world:collisions(test_shape)) do
        local o = other.obj
        if o.type == "wall"
                or (o.type == "obstacle" and o.z <= 0 and o.hp > 0 and o.isMovable == false)
                or o.type == "stopper" then
            return false
        end
    end
    return true
end

local states_for_holdAttack = {stand = true, walk = true, run = true}
function Player:updateAI(dt)
    if self.isDisabled then
        return
    end
    if self.holdAttack then
        if self.b.attack:isDown() and states_for_holdAttack[self.state] then
            self.charge = self.charge + dt
        else
            if self.charge >= self.charged_at then
                if states_for_holdAttack[self.state] then
                    self:setState(self.holdAttack)
                end
            end
            self.charge = 0
        end
    end
    Character.updateAI(self, dt)
end

function Player:isImmune()   --Immune to the attack?
    local h = self.harm
    if not h then
        return true
    end
    if h.type == "shockWave" or self.isDisabled then
        self.harm = nil --free hurt data
        return false
    end
    return false
end

function Player:onHurtDamage()
    local h = self.harm
    if not h then
        return
    end
    if h.continuous then
        h.source.victims[self] = true
    end
    self:releaseGrabbed()
    h.damage = h.damage or 100  --TODO debug if u forgot
    dp(h.source.name .. " damaged "..self.name.." by "..h.damage..". HP left: "..(self.hp - h.damage)..". Lives:"..self.lives)
    if h.type ~= "shockWave" then
        -- show enemy bar for other attacks
        h.source.victimInfoBar = self.infoBar:setAttacker(h.source)
        self.victimInfoBar = h.source.infoBar:setAttacker(self)
    end
    -- Score
    h.source:addScore( h.damage * 10 )
    self.killerId = h.source
    self:onShake(1, 0, 0.03, 0.3)   --shake a character

    mainCamera:onShake(0, 1, 0.03, 0.3)	--shake the screen for Players only

    self:decreaseHp(h.damage)
    if h.type == "simple" then
        self.harm = nil --free hurt data
        return
    end

    self:playHitSfx(h.damage)
    if not GLOBAL_SETTING.CONTINUE_INTERRUPTED_COMBO then
        self.n_combo = 1	--if u get hit reset combo chain
    end
    if h.source.velx == 0 then
        self.face = -h.source.face	--turn face to the still(pulled back) attacker
    else
        if h.source.horizontal ~= h.source.face then
            self.face = -h.source.face	--turn face to the back-jumping attacker
        else
            self.face = -h.source.horizontal --turn face to the attacker
        end
    end
end

function Player:afterOnHurt()
    local h = self.harm
    if not h then
        return
    end
    --"simple", "blow-vertical", "blow-diagonal", "blow-horizontal", "blow-away"
    --"high", "low", "fall"(replaced by blows)
    if h.type == "high" then
        if self.hp > 0 and self.z <= 0 then
            self:showHitMarks(h.damage, 40)
            self:setState(self.hurt)
            self:setSprite("hurtHigh")
            return
        end
        self.velx = h.velx --use fall speed from the agument
        --then it does to "fall dead"
    elseif h.type == "low" then
        if self.hp > 0 and self.z <= 0 then
            self:showHitMarks(h.damage, 16)
            self:setState(self.hurt)
            self:setSprite("hurtLow")
            return
        end
        self.velx = h.velx --use fall speed from the agument
        --then it does to "fall dead"
    elseif h.type == "grabKO" then
        --when u throw a grabbed one
        self.velx = self.velocityThrow_x
    elseif h.type == "fall" then
        --use fall speed from the agument
        self.velx = h.velx
        --it cannot be too short
        if self.velx < self.velocityFall_x / 2 then
            self.velx = self.velocityFall_x / 2 + self.velocityFall_add_x
        end
    elseif h.type == "shockWave" then
        if h.source.x < self.x then
            h.horizontal = 1
        else
            h.horizontal = -1
        end
        self.face = -h.horizontal	--turn face to the epicenter
    else
        error("OnHurt - unknown h.type = "..h.type)
    end
    dpo(self, self.state)
    --finish calcs before the fall state
    if h.damage > 0 then
        if h.type == "low" then
            self:showHitMarks(h.damage, 16)
        else
            self:showHitMarks(h.damage, 40)
        end
    end
    -- calc falling traectorym speed, direction
    self.z = self.z + 1
    self.velz = self.velocityFall_z * self.velocityJump_speed
    if self.hp <= 0 then -- dead body flies further
        if self.velx < self.velocityFall_x then
            self.velx = self.velocityFall_x + self.velocityFall_dead_add_x
        else
            self.velx = self.velx + self.velocityFall_dead_add_x
        end
    elseif self.velx < self.velocityFall_x then --alive bodies
        self.velx = self.velocityFall_x
    end
    self.horizontal = h.horizontal
    self.isGrabbed = false
    if not self.isMovable and self.hp <=0 then
        self.velx = 0
        self:setState(self.dead)
    else
        self:setState(self.fall)
    end
end

local players_list = { RICK = 1, KISA = 2, CHAI = 3, GOPPER = 4, NIKO = 5, SVETA = 6, ZEENA = 7, BEATNICK = 8, SATOFF = 9 }
function Player:useCreditStart()
    self.isHittable = false
    self.lives = self.lives - 1
    if self.lives > 0 then
        dp(self.name.." used 1 life to respawn")
        self:setState(self.respawn)
        return
    end
    self.coolDown = 10
    -- Player select
    self.playerSelectMode = 0
    self.playerSelect_cur = players_list[self.name] or 1
end
function Player:useCreditUpdate(dt)
    if self.playerSelectMode == 5 then --self.isDisabled then
        return
    end
    if not self.b.attack:isDown() then
        self.canAttack = true
    end

    if self.playerSelectMode == 0 then
        -- 10 seconds to choose
        self.coolDown = self.coolDown - dt
        if credits <= 0 or self.coolDown <= 0 then
            -- n credits -> game over
            self.playerSelectMode = 5
            unregisterPlayer(self)
            return
        end
        -- wait press to use credit
        -- add countdown 9 .. 0 -> Game Over
        if self.b.attack:isDown() and self.canAttack then
            dp(self.name.." used 1 Credit to respawn")
            credits = credits - 1
            self:addScore(1) -- like CAPCM
            sfx.play("sfx","menuSelect")
            self.coolDown = 1 -- delay before respawn
            self.playerSelectMode = 1
        end
    elseif self.playerSelectMode == 1 then
        -- wait 1 sec before player select
        if self.coolDown > 0 then
            -- wait before respawn / char select
            self.coolDown = self.coolDown - dt
            if self.coolDown <= 0 then
                self.canAttack = false
                self.coolDown = 10
                self.playerSelectMode = 2
            end
        end
    elseif self.playerSelectMode == 2 then
        -- Select Player
        -- 10 sec countdown before auto confirm
        if (self.b.attack:isDown() and self.canAttack)
                or self.coolDown <= 0
        then
            self.coolDown = 0
            self.playerSelectMode = 4
            sfx.play("sfx","menuSelect")
            local player = HEROES[self.playerSelect_cur].hero:new(self.name,
                GetSpriteInstance(HEROES[self.playerSelect_cur].sprite_instance),
                self.b,
                self.x, self.y
                --{ shapeType = "polygon", shapeArgs = { 1, 0, 13, 0, 14, 3, 13, 6, 1, 6, 0, 3 } }
            )
            player.playerSelectMode = 3
            correctPlayersRespawnPos(player)
            player:setState(self.respawn)
            player.id = self.id
            player.palette = 0 --TODO use unloclable colorse feature on implementing
            registerPlayer(player)
            fixPlayersPalette(player)
            dp(player.x, player.y, player.name, player.playerSelectMode, "Palette:", player.palette)
            SELECT_NEW_PLAYER[#SELECT_NEW_PLAYER+1] = { id = self.id, player = player}
            return
        else
            self.coolDown = self.coolDown - dt
        end
        ---
        if self.b.horizontal:pressed(-1) or self.b.vertical:pressed(-1)
                or self.b.horizontal:pressed(1) or self.b.vertical:pressed(1)
        then
            if self.b.horizontal:pressed(-1) or self.b.vertical:pressed(-1) then
                self.playerSelect_cur = self.playerSelect_cur - 1
            else
                self.playerSelect_cur = self.playerSelect_cur + 1
            end
            if GLOBAL_SETTING.DEBUG then
                if self.playerSelect_cur > players_list.SATOFF then
                    self.playerSelect_cur = 1
                end
                if self.playerSelect_cur < 1 then
                    self.playerSelect_cur = players_list.SATOFF
                end
            else
                if self.playerSelect_cur > players_list.CHAI then
                    self.playerSelect_cur = 1
                end
                if self.playerSelect_cur < 1 then
                    self.playerSelect_cur = players_list.CHAI
                end
            end
            sfx.play("sfx","menuMove")
            self:onShake(1, 0, 0.03, 0.3)   --shake name + face icon
            self.name = HEROES[self.playerSelect_cur][1].name
            self.sprite = GetSpriteInstance(HEROES[self.playerSelect_cur].sprite_instance)
            self:setSprite("stand")
            fixPlayersPalette(self)
            self.shader = getShader(self.sprite.def.sprite_name:lower(), self.palette)
            self.infoBar = InfoBar:new(self)
        end
    elseif self.playerSelectMode == 3 then
        -- Spawn selecterd player
    elseif self.playerSelectMode == 4 then
        -- Delete on Selecting a new Character
    elseif self.playerSelectMode == 5 then
        -- Game Over
    end
end
Player.useCredit = {name = "useCredit", start = Player.useCreditStart, exit = nop, update = Player.useCreditUpdate, draw = Unit.defaultDraw}

function Player:respawnStart()
    self.isHittable = false
    dpo(self, self.state)
    self:setSprite("respawn")
    self.coolDownDeath = 3 --seconds to remove
    self.hp = self.maxHp
    self.bounced = 0
    self.velz = 0
    self.z = math.random( 235, 245 )    --TODO get Z from the Tiled
    stage:resetTime()
end
function Player:respawnUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocityJump_speed
    elseif self.bounced == 0 then
        self.playerSelectMode = 0 -- remove player select text
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        if self.sprite.curFrame == 1 then
            self.sprite.elapsedTime = 10 -- seconds. skip to pickup 2 frame
        end
        self:checkAndAttack(
            { left = 0, width = 320 * 2, height = 240 * 2, damage = 0, type = "shockWave", velocity = 0 },
            false
        )
        mainCamera:onShake(0, 2, 0.03, 0.3)	--shake the screen on respawn
        if self.sprite.def.fallsOnRespawn then
            --clouds under belly
            local particles = PA_DUST_FALLING:clone()
            particles:emit(PA_DUST_FALLING_N_PARTICLES)
            stage.objects:add(Effect:new(particles, self.x, self.y+3))
        else
            --landing dust clouds by the sides
            local particles = PA_DUST_LANDING:clone()
            particles:setLinearAcceleration(150, 1, 300, -35)
            particles:setDirection( 0 )
            particles:setPosition( 20, 0 )
            particles:emit(PA_DUST_FALLING_N_PARTICLES / 2)
            particles:setLinearAcceleration(-150, 1, -300, -35)
            particles:setDirection( 3.14 )
            particles:setPosition( -20, 0 )
            particles:emit(PA_DUST_FALLING_N_PARTICLES / 2)
            stage.objects:add(Effect:new(particles, self.x, self.y+2))
        end
        self.bounced = 1
    end
    --self.victimInfoBar = nil   -- remove enemy bar under yours
    self:calcMovement(dt)
end
Player.respawn = {name = "respawn", start = Player.respawnStart, exit = nop, update = Player.respawnUpdate, draw = Unit.defaultDraw}

function Player:deadStart()
    self.isHittable = false
    self:setSprite("fallen")
    dp(self.name.." is dead.")
    self.hp = 0
    self.harm = nil
    self:releaseGrabbed()
    if self.z <= 0 then
        self.z = 0
    end
    --self:onShake(1, 0, 0.1, 0.7)
    sfx.play("voice"..self.id, self.sfx.dead)
    if self.killerId then
        self.killerId:addScore( self.scoreBonus )
    end
end
function Player:deadUpdate(dt)
    if self.isDisabled then
        return
    end
    --dp(self.name .. " - dead update", dt)
    if self.coolDownDeath <= 0 then
        self:setState(self.useCredit)
        return
    else
        self.coolDownDeath = self.coolDownDeath - dt
    end
    self:calcMovement(dt)
end
Player.dead = {name = "dead", start = Player.deadStart, exit = nop, update = Player.deadUpdate, draw = Unit.defaultDraw}

return Player