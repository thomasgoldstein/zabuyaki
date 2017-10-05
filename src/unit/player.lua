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
    self:initAttributes()
    self.type = "player"
    self.friendlyDamage = 1 --1 = full damage on other players
end

--function Player:initAttributes()
--end

function Player:setOnStage(stage)
    self.pid = GLOBAL_SETTING.PLAYERS_NAMES[self.id] or "P?"
    self.showPIDCooldown = 3
    Unit.setOnStage(self, stage)
    registerPlayer(self)
    logPlayer:reset(self.id)
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

function Player:checkCollisionAndMove(dt)
    local success = true
    if self.move then
        self.move:update(dt) --tweening
        self.shape:moveTo(self.x, self.y)
    else
        local stepx = self.vel_x * dt * self.horizontal
        local stepy = self.vel_y * dt * self.vertical
        self.shape:moveTo(self.x + stepx, self.y + stepy)
    end
    if self.z <= 0 then
        for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.type == "wall"
                    or (o.type == "obstacle" and o.z <= 0 and o.hp > 0)
                or o.type == "stopper"
            then
                self.shape:move(separatingVector.x, separatingVector.y)
                success = false
            end
        end
    else
        for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.type == "wall"
                or o.type == "stopper"
            then
                self.shape:move(separatingVector.x, separatingVector.y)
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
    for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
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
    local testShape = stage.testShape
    testShape:moveTo(x, y)
    for other, separatingVector in pairs(stage.world:collisions(testShape)) do
        local o = other.obj
        if o.type == "wall"
                or (o.type == "obstacle" and o.z <= 0 and o.hp > 0 and o.isMovable == false)
                or o.type == "stopper" then
            return false
        end
    end
    return true
end

function Player:updateAI(dt)
    if self.isDisabled then
        return
    end
    if self.moves.holdAttack then
        if self.b.attack:isDown() and self.statesForHoldAttack[self.state] then
            self.charge = self.charge + dt
        else
            if self.charge >= self.chargedAt then
                if self.statesForHoldAttack[self.state] then
                    self:setState(self.holdAttack)
                end
            end
            self.charge = 0
        end
    end
    Character.updateAI(self, dt)
end

function Player:isImmune()   --Immune to the attack?
    local h = self.isHurt
    if not h then
        return true
    end
    if h.type == "shockWave" or self.isDisabled then
        self.isHurt = nil --free hurt data
        return false
    end
    return false
end

function Player:onHurtDamage()
    local h = self.isHurt
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
        logPlayer:logDamage(self)
        logPlayer:printDamageInfo(self.id)
    end
    -- Score
    h.source:addScore( h.damage * 10 )
    self.killerId = h.source
    self:onShake(1, 0, 0.03, 0.3)   --shake a character
    mainCamera:onShake(0, 1, 0.03, 0.3)	--shake the screen for Players only

    self:decreaseHp(h.damage)
    if h.type == "simple" then
        self.isHurt = nil --free hurt data
        return
    end

    self:playHitSfx(h.damage)
    if not GLOBAL_SETTING.CONTINUE_INTERRUPTED_COMBO then
        self.ComboN = 1	--if u get hit reset combo chain
    end
    if h.source.vel_x == 0 then
        self.face = -h.source.face	--turn face to the still(pulled back) attacker
    else
        if h.source.horizontal ~= h.source.face then
            self.face = -h.source.face	--turn face to the back-jumping attacker
        else
            self.face = -h.source.horizontal --turn face to the attacker
        end
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
    self.cooldown = 10
    -- Player select
    self.playerSelectMode = 0
    self.playerSelectCur = players_list[self.name] or 1
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
        self.cooldown = self.cooldown - dt
        if credits <= 0 or self.cooldown <= 0 then
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
            self.cooldown = 1 -- delay before respawn
            self.playerSelectMode = 1
        end
    elseif self.playerSelectMode == 1 then
        -- wait 1 sec before player select
        if self.cooldown > 0 then
            -- wait before respawn / char select
            self.cooldown = self.cooldown - dt
            if self.cooldown <= 0 then
                self.canAttack = false
                self.cooldown = 10
                self.playerSelectMode = 2
            end
        end
    elseif self.playerSelectMode == 2 then
        -- Select Player
        -- 10 sec countdown before auto confirm
        if (self.b.attack:isDown() and self.canAttack)
                or self.cooldown <= 0
        then
            self.cooldown = 0
            self.playerSelectMode = 4
            sfx.play("sfx","menuSelect")
            local player = HEROES[self.playerSelectCur].hero:new(self.name,
                GetSpriteInstance(HEROES[self.playerSelectCur].spriteInstance),
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
            SELECT_NEW_PLAYER[#SELECT_NEW_PLAYER+1] = { id = self.id, player = player, deletePlayer = self}
            return
        else
            self.cooldown = self.cooldown - dt
        end
        ---
        if self.b.horizontal:pressed(-1) or self.b.vertical:pressed(-1)
                or self.b.horizontal:pressed(1) or self.b.vertical:pressed(1)
        then
            if self.b.horizontal:pressed(-1) or self.b.vertical:pressed(-1) then
                self.playerSelectCur = self.playerSelectCur - 1
            else
                self.playerSelectCur = self.playerSelectCur + 1
            end
            if GLOBAL_SETTING.DEBUG then
                if self.playerSelectCur > players_list.SATOFF then
                    self.playerSelectCur = 1
                end
                if self.playerSelectCur < 1 then
                    self.playerSelectCur = players_list.SATOFF
                end
            else
                if self.playerSelectCur > players_list.CHAI then
                    self.playerSelectCur = 1
                end
                if self.playerSelectCur < 1 then
                    self.playerSelectCur = players_list.CHAI
                end
            end
            sfx.play("sfx","menuMove")
            self:onShake(1, 0, 0.03, 0.3)   --shake name + face icon
            self.name = HEROES[self.playerSelectCur][1].name
            self.sprite = GetSpriteInstance(HEROES[self.playerSelectCur].spriteInstance)
            self:setSprite("stand")
            fixPlayersPalette(self)
            self.shader = getShader(self.sprite.def.spriteName:lower(), self.palette)
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
    self.cooldownDeath = 3 --seconds to remove
    self.hp = self.maxHp
    self.bounced = 0
    self.vel_z = 0
    self.z = math.random( 235, 245 )    --TODO get Z from the Tiled
    stage:resetTime()
end
function Player:respawnUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self:calcFreeFall(dt)
    elseif self.bounced == 0 then
        self.playerSelectMode = 0 -- remove player select text
        self.vel_z = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        if self.sprite.curFrame == 1 then
            self.sprite.elapsedTime = 10 -- seconds. skip to pickup 2 frame
        end
        self:checkAndAttack(
            { x = 0, y = 0, width = 320 * 2, depth = 240 * 2, height = 240 * 2, damage = 0, type = "shockWave", velocity = 0 },
            false
        )
        mainCamera:onShake(0, 2, 0.03, 0.3)	--shake the screen on respawn
        if self.sprite.def.fallsOnRespawn then
            --clouds under belly
            self:showEffect("bellyLanding")
        else
            --landing dust clouds by the sides
            self:showEffect("jumpLanding")
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
    self.isHurt = nil
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
    if self.cooldownDeath <= 0 then
        self:setState(self.useCredit)
        return
    else
        self.cooldownDeath = self.cooldownDeath - dt
    end
    self:calcMovement(dt)
end
Player.dead = {name = "dead", start = Player.deadStart, exit = nop, update = Player.deadUpdate, draw = Unit.defaultDraw}

return Player