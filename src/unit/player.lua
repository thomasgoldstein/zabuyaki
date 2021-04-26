local class = require "lib/middleclass"
local Player = class('Player', Character)

local function nop() end
local players_list = { RICK = 1, KISA = 2, CHAI = 3, YAR = 4, GOPPER = 5, NIKO = 6, SVETA = 7, ZEENA = 8, HOOCH = 9, BEATNIK = 10, SATOFF = 11, DRVOLKER = 12 }
players_list.firstPlayerCharacter = players_list.RICK
players_list.lastPlayerCharacter = players_list.YAR

function Player:initialize(name, sprite, x, y, f, input)
    if not f then
        f = {}
    end
    self.lives = GLOBAL_SETTING.MAX_LIVES
    self.hp = f.hp or self.hp or 100
    Character.initialize(self, name, sprite, x, y, f, input)
    self:initAttributes()
    self.canPassStoppers = false
    self.type = "player"
    self.canFriendlyAttack = true
    self.friendlyDamage = 1 --1 = full damage on other players
end

function Player:setOnStage(stage)
    self.pid = GLOBAL_SETTING.PLAYERS_NAMES[self.id] or "P?"
    self.showPIDDelay = 3
    Unit.setOnStage(self, stage)
    self.victimLifeBar = nil   -- remove enemy bar under yours
    self:disableGhostTrails()
    registerPlayer(self)
end

function Player:isAlive()
    if (self.playerSelectMode == 0 and credits > 0 and self:isInUseCreditMode())
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

function Player:moveStatesApply()
    local t = self.grabContext.target
    Unit.moveStatesApply(self)
    local px, py = t:penetratesObject(stage.leftStopper)
    if px ~= 0 or py ~= 0 then
        if t.x <= stage.leftStopper.x then
            px = -(stage.leftStopper.x - t.x + t:getHurtBoxWidth() / 2)
        end
        t.x, t.y = t.x - px, t.y - py
        if not t.isThrown then
            self.x, self.y = self.x - px, self.y - py -- move the grabber from the stopper along with the grabbed
        end
    else
        px, py = t:penetratesObject(stage.rightStopper)
        if px ~= 0 or py ~= 0 then
            if t.x >= stage.rightStopper.x then
                px = t.x - stage.rightStopper.x + t:getHurtBoxWidth() / 2
            end
            t.x, t.y = t.x - px, t.y - py
            if not t.isThrown then
                self.x, self.y = self.x - px, self.y - py -- move the grabber from the stopper along with the grabbed
            end
        end
    end
end

function Player:hasPlaceToStand(x, y)
    for _,o in ipairs(stage.objects.entities) do
        if ( o.type == "wall" or o.type == "stopper" )
            and o:collidesByXYWH(x, y, self:getHurtBoxWidth(), self:getHurtBoxDepth() )
        then
            return false
        end
    end
    return true
end

function Player:isImmune()   --Immune to the attack?
    local h = self:getDamageContext()
    if (h.type == "shockWave" and h.source.type ~= "enemy" ) or self.isDisabled then
        self:initDamageContext()
        return false
    end
    return Character.isImmune(self, true)
end

function Player:canGrab(target)
    if target.face == -self.face and self.state ~= "chargeDash" and target.state == "chargeDash" then
        return false
    end
    if target.type ~= "player" or (self.canFriendlyAttack and target.canFriendlyAttack) then
        return true
    end
    return false
end

function Player:onHurtDamage()
    local h = self:getDamageContext()
    if not h then
        return
    end
    self:releaseGrabbed()
    h.damage = h.damage or 100  --TODO debug if u forgot
    dp(h.source.name .. " damaged "..self.name.." by "..h.damage..". HP left: "..(self.hp - h.damage)..". Lives:"..self.lives, h.attackHash)
    self:updateAttackersLifeBar(h)
    -- Score
    h.source:addScore( h.damage * 10 )
    self.killerId = h.source
    self:onShake(1, 0, 0.03, 0.3)   --shake a character
    mainCamera:onShake(0, 1, 0.03, 0.3)	--shake the screen for Players only
    self:decreaseHp(h.damage)
    if h.type == "simple" then
        self:initDamageContext()
        return
    end
    self:playHitSfx(h.damage)
end

function Player:useCreditStart()
    self.isHittable = false
    self.lives = self.lives - 1
    if self.lives > 0 then
        dp(self.name.." used 1 life to respawn")
        self:setState(self.respawn)
        return
    end
    self.displayDelay = 10
    -- Player select
    self.playerSelectMode = 0
    self.playerSelectCur = players_list[self.name] or players_list.firstPlayerCharacter
end
function Player:useCreditUpdate(dt)
    if self.playerSelectMode == 5 then --self.isDisabled then
        return
    end
    if self.playerSelectMode == 0 then
        -- 10 seconds to choose
        self.displayDelay = self.displayDelay - dt
        if credits <= 0 or self.displayDelay <= 0 then
            -- n credits -> game over
            self.playerSelectMode = 5
            unregisterPlayer(self)
            return
        end
        -- wait press to use credit
        -- add countdown 9 .. 0 -> Game Over
        if self.b.attack:pressed() then
            dp(self.name .. " used 1 Credit to respawn")
            credits = credits - 1
            self:addScore(1) -- like CAPCM
            self:playSfx(sfx.menuSelect)
            self.displayDelay = 1 -- delay before respawn
            self.playerSelectMode = 1
        end
    elseif self.playerSelectMode == 1 then
        -- wait 1 sec before player select
        if self.displayDelay > 0 then
            -- wait before respawn / char select
            self.displayDelay = self.displayDelay - dt
            if self.displayDelay <= 0 then
                self.displayDelay = 10
                self.playerSelectMode = 2
            end
        end
    elseif self.playerSelectMode == 2 then
        -- Select Player
        -- 10 sec countdown before auto confirm
        if self.b.attack:pressed() or self.displayDelay <= 0 then
            self.displayDelay = 0
            self.playerSelectMode = 4
            self:playSfx(sfx.menuSelect)
            local player = HEROES[self.playerSelectCur].hero:new(self.name,
                HEROES[self.playerSelectCur].spriteInstance,
                self.x, self.y,
                nil, --{ shapeType = "polygon", shapeArgs = { 1, 0, 13, 0, 14, 3, 13, 6, 1, 6, 0, 3 } }
                self.b
            )
            player.playerSelectMode = 3
            player:setState(self.respawn)
            player.id = self.id
            player.palette = self.palette
            registerPlayer(player)
            fixPlayersPalette(player)
            dp(player.x, player.y, player.name, player.playerSelectMode, "Palette:", player.palette)
            SELECT_NEW_PLAYER[#SELECT_NEW_PLAYER + 1] = { id = self.id, player = player, deletePlayer = self }
            return
        else
            self.displayDelay = self.displayDelay - dt
        end
        if self.b.horizontal:pressed(-1) or self.b.vertical:pressed(-1)
            or self.b.horizontal:pressed(1) or self.b.vertical:pressed(1)
        then
            if self.b.horizontal:pressed(-1) or self.b.vertical:pressed(-1) then
                self.playerSelectCur = self.playerSelectCur - 1
            else
                self.playerSelectCur = self.playerSelectCur + 1
            end
            if isDebug() then
                if self.playerSelectCur > #HEROES then
                    self.playerSelectCur = players_list.firstPlayerCharacter
                end
                if self.playerSelectCur < players_list.firstPlayerCharacter then
                    self.playerSelectCur = #HEROES
                end
            else
                if self.playerSelectCur > players_list.lastPlayerCharacter then
                    self.playerSelectCur = players_list.firstPlayerCharacter
                end
                if self.playerSelectCur < players_list.firstPlayerCharacter then
                    self.playerSelectCur = players_list.lastPlayerCharacter
                end
            end
            self:playSfx(sfx.menuMove)
            self:onShake(1, 0, 0.03, 0.3)   --shake name + face icon
            self.name = HEROES[self.playerSelectCur][1].name
            self.sprite = getSpriteInstance(HEROES[self.playerSelectCur].spriteInstance)
            self:setSprite("stand")
            fixPlayersPalette(self)
            self.lifeBar = LifeBar:new(self)
        end
    elseif self.playerSelectMode == 3 then
        -- Spawn selected player
    elseif self.playerSelectMode == 4 then
        -- Delete on Selecting a new Character
    elseif self.playerSelectMode == 5 then
        -- Game Over
    end
end
Player.useCredit = {name = "useCredit", start = Player.useCreditStart, exit = nop, update = Player.useCreditUpdate, draw = Unit.defaultDraw}

function Player:respawnStart()
    self.isHittable = false
    self.x, self.y = stage:getSafeRespawnPosition(self)
    self:setSprite("respawn")
    self.deathDelay = 3 --seconds to remove
    if not self.condition then
        self.hp = self:getMaxHp()
        if self.lifeBar then
            self.lifeBar.lives = self.lives -- green hp filling up on player respawn
        end
    end
    self.bounced = 0
    self.speed_z = 0
    self.z = love.math.random( 235, 245 )    --TODO get Z from the Tiled
end
function Player:respawnUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
    elseif self.bounced == 0 then
        self.playerSelectMode = 0 -- remove player select text
        self.speed_z = 0
        self.z = self:getRelativeZ()
        self:playSfx(self.sfx.step)
        self.sprite.curFrame = 2    -- continue from the 2nd frame to the end (the animation may contain >2 frames)
        self.sprite.elapsedTime = 0 -- reset animation timer for the 2nd frame
        self:checkAndAttack(
            { x = 0, z = 0, width = 320 * 2, depth = 240 * 2, height = 240 * 2, damage = 0, type = "shockWave" },
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
end
Player.respawn = {name = "respawn", start = Player.respawnStart, exit = nop, update = Player.respawnUpdate, draw = Unit.defaultDraw}

function Player:deadUpdate(dt)
    if self.deathDelay <= 0 then
        self:setState(self.useCredit)
        return
    end
    Character.deadUpdate(self, dt)
end
Player.dead = {name = "dead", start = Character.deadStart, exit = nop, update = Player.deadUpdate, draw = Unit.defaultDraw}

return Player
