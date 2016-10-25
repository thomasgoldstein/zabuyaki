-- Date: 06.07.2016

local class = require "lib/middleclass"

local Character = class('Character', Unit)

local function nop() --[[print "nop"]] end
local function sign(x)
    return x>0 and 1 or x<0 and -1 or 0
end

function Character:initialize(name, sprite, input, x, y, shader, color)
    Unit.initialize(self, name, sprite, input, x, y, shader, color)
    self.type = "character"
    self.height = 50
    self.velocity_walk = 100
    self.velocity_walk_y = 50
    self.velocity_run = 150
    self.velocity_run_y = 25
    self.velocity_jump = 220 --Z coord
    self.velocity_jump_speed = 1.25
    self.velocity_jump_x_boost = 10
    self.velocity_jump_y_boost = 5
    self.velocity_jump_z_run_boost = 24
    self.velocity_fall_z = 220
    self.velocity_fall_x = 120
    self.velocity_fall_add_x = 5
    self.velocity_fall_dead_add_x = 20
    self.velocity_dash = 150 --speed of the character
    self.velocity_dash_fall = 180 --speed caused by dash to others fall
    self.friction_dash = self.velocity_dash
    self.throw_start_z = 20 --lift up a body to throw at this Z
    self.to_fallen_anim_z = 40
    self.velocity_step_down = 220
    self.sideStepFriction = 650 --velocity penalty for sideStepUp Down (when u slide on ground)
    self.velocity_grab_throw_x = 220 --my throwing speed
    self.velocity_grab_throw_z = 200 --my throwing speed
    self.velocity_back_off = 175 --when you ungrab someone
    self.velocity_back_off2 = 200 --when you are released
    self.velocity_bonus_on_attack_x = 30
    self.velocity_throw_x = 110 --attack speed that causes my thrown body to the victims
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Inner char vars
    self.lives = GLOBAL_SETTING.MAX_LIVES
    self.toughness = 0 --0 slow .. 5 fast, more aggressive (for enemy AI)
    self.score = 0
    self.n_combo = 1    -- n of the combo hit
    self.cool_down = 0  -- can't move
    self.cool_down_combo = 0    -- can cont combo
    self.cool_down_grab = 2
    self.grab_release_after = 0.25 --sec if u hold 'back'
    self.n_grabhit = 0    -- n of the grab hits
    self.special_tolerance_delay = 0.02 -- between pressing attack & Jump
    self.player_select_mode = 0
    --Character default sfx
    self.sfx.jump = "whoosh_heavy"
    self.sfx.throw = "air"
    self.sfx.dash = "grunt3"
    self.sfx.grab = "grab"
    self.sfx.jump_attack = "grunt1"
    self.sfx.step = "kisa_step"
    self.sfx.dead = "grunt3"
--    self.infoBar = InfoBar:new(self)
--    self.victim_infoBar = nil
end

function Character:addHp(hp)
    self.hp = self.hp + hp
    if self.hp > self.max_hp then
        self.hp = self.max_hp
    end
end
function Character:decreaseHp(damage)
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.hp = 0
    end
end

function Character:addScore(score)
    self.score = self.score + score
end

function Character:isAlive()
    -- Just used 1 credit
    if self.player_select_mode >= 1 and self.player_select_mode < 4 then
        return true
    end
    return self.hp + self.lives > 0
end

function Character:updateAI(dt)
    if self.isDisabled then
        return
    end
    Unit.updateAI(self, dt)
    self:updateShake(dt)
end

function Character:onHurt()
    -- hurt = {source, damage, velx,vely,x,y,z}
    local h = self.hurt
    if not h then
        return
    end
    if h.source.victims[self] then  -- if I had dmg from this src already
        dp("MISS + not Clear HURT due victims list of "..h.source.name)
        return
    end
--    if self.type == h.source.type then
--        -- cannot attack the same type: Players -> Players
--        self.hurt = nil --free hurt data
--        return
--    end
    if h.type == "shockWave" and self.type == "player" then
        -- shockWave has no effect on players
        self.hurt = nil --free hurt data
        return
    end
    h.source.victims[self] = true
    self:release_grabbed()
    h.damage = h.damage or 100  --TODO debug if u forgot
    dp(h.source.name .. " damaged "..self.name.." by "..h.damage)
    if h.type ~= "shockWave" then
        -- show enemy bar for other attacks
        h.source.victim_infoBar = self.infoBar:setAttacker(h.source)
        if self.id <= GLOBAL_SETTING.MAX_PLAYERS then
            self.victim_infoBar = h.source.infoBar:setAttacker(self)
        end
    end
-- Score
    h.source:addScore( h.damage * 10 )
    self:onShake(1, 0, 0.03, 0.3)   --shake a character
    if self.id <= GLOBAL_SETTING.MAX_PLAYERS then
        mainCamera:onShake(0, 1, 0.03, 0.3)	--shake the screen for Players only
    end
    self:decreaseHp(h.damage)
    if h.type == "simple" then
        self.hurt = nil --free hurt data
        return
    end

    self:playHitSfx(h.damage)
    self.n_combo = 1	--if u get hit reset combo chain

    self.face = -h.source.face	--turn face to the attacker
    --self.horizontal = h.horizontal  --

    self.hurt = nil --free hurt data

    --"simple", "blow-vertical", "blow-diagonal", "blow-horizontal", "blow-away"
    --"high", "low", "fall"(replaced by blows)
    if h.type == "high" then
        if self.hp > 0 and self.z <= 0 then
            self:showHitMarks(h.damage, 40)
            self:setState(self.hurtHigh)
            return
        end
        --then it does to "fall dead"
    elseif h.type == "low" then
        if self.hp > 0 and self.z <= 0 then
            self:showHitMarks(h.damage, 16)
            self:setState(self.hurtLow)
            return
        end
        --then it does to "fall dead"
    elseif h.type == "grabKO" then
        --when u throw a grabbed one
        self.velx = self.velocity_throw_x
    elseif h.type == "fall" then
        --use fall speed from the agument
        self.velx = h.velx
        --it cannot be too short
        if self.velx < self.velocity_fall_x / 2 then
            self.velx = self.velocity_fall_x / 2 + self.velocity_fall_add_x
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
    self:showHitMarks(h.damage, 40)
    -- calc falling traectorym speed, direction
    self.z = self.z + 1
    self.velz = self.velocity_fall_z * self.velocity_jump_speed

    if self.hp <= 0 then -- dead body flies further
        if self.velx < self.velocity_fall_x then
            self.velx = self.velocity_fall_x + self.velocity_fall_dead_add_x
        else
            self.velx = self.velx + self.velocity_fall_dead_add_x
        end
    elseif self.velx < self.velocity_fall_x then --alive bodies
        self.velx = self.velocity_fall_x
    end
    self.horizontal = h.horizontal
    self.isGrabbed = false
    self:setState(self.fall)
    return
end

function Character:applyDamage(damage, type, source, velocity, sfx1)
    self.hurt = {source = source or self, state = self.state, damage = damage,
        type = type, velx = velocity or 0,
        horizontal = self.face, isThrown = false,
        x = self.x, y = self.y, z = self.z }
    if sfx1 then
        sfx.play("sfx"..self.id,sfx1)
    end
end

function Character:checkAndAttack(l,t,w,h, damage, type, velocity, sfx1, init_victims_list)
    -- type = "high" "low" "fall" "shockWave" "simple" ""blow-vertical" "blow-diagonal" "blow-horizontal" "blow-away"
    local face = self.face

    if init_victims_list then
        self.victims = {}
    end
    local items, len = stage.world:queryRect(self.x + face*l - w/2, self.y + t - h/2, w, h,
        function(o)
            if self ~= o and o.isHittable and not self.victims[o]
                    and o.z <= self.z + o.height and o.z >= self.z - self.height
            then
                --print ("hit "..item.name)
                return true
            end
        end)
    --DEBUG collect data to show attack hitBoxes in green
    if GLOBAL_SETTING.DEBUG then
        attackHitBoxes[#attackHitBoxes+1] = {x = self.x + face*l - w/2, y = self.y + t - h/2, w = w, h = h, z = self.z, height = self.height }
    end
    for i = 1,#items do
        if self.isThrown then
            items[i].hurt = {source = self.thrower_id, state = self.state, damage = damage,
                type = type, velx = velocity or self.velocity_bonus_on_attack_x,
                horizontal = self.horizontal, isThrown = true,
                x = self.x, y = self.y, z = self.z }
        else
            items[i].hurt = {source = self, state = self.state, damage = damage,
                type = type, velx = velocity or self.velocity_bonus_on_attack_x,
                horizontal = face, isThrown = false,
                x = self.x, y = self.y, z = self.z }
        end
    end
    if sfx1 then
        sfx.play("sfx"..self.id,sfx1)
    end
    if not GLOBAL_SETTING.AUTO_COMBO and #items < 1 then
        -- reset combo attack N to 1
        self.n_combo = 0
    end
end

function Character:checkAndAttackGrabbed(l,t,w,h, damage, type, velocity, sfx1)
    -- type = "high" "low" "fall" "blow-vertical" "blow-diagonal" "blow-horizontal" "blow-away"
    local face = self.face
    local g = self.hold
    if self.isThrown then
        face = -face    --TODO proper thrown enemy hitbox?
        --TODO not needed since the hitbox is centered
    end
    if not g.target then --can attack only the 1 grabbed
    return
    end

    local items, len = stage.world:queryRect(self.x + face*l - w/2, self.y + t - h/2, w, h,
        function(obj)
            if obj == g.target then
                return true
            end
        end)
    --DEBUG collect data to show attack hitBoxes in green
    if GLOBAL_SETTING.DEBUG then
        attackHitBoxes[#attackHitBoxes+1] = {x = self.x + face*l - w/2, y = self.y + t - h/2, w = w, h = h, z = self.z, height = self.height }
    end
    for i = 1,#items do
        items[i].hurt = {source = self, state = self.state, damage = damage,
            type = type, velx = velocity or self.velocity_bonus_on_attack_x,
            horizontal = self.horizontal,
            x = self.x, y = self.y, z = self.z}
    end
    if sfx1 then	--TODO 2 SFX for holloow and hit
        sfx.play("sfx"..self.id,sfx1)
    end
end

function Character:checkForItem(w, h)
    --got any items near feet?
    local items, len = stage.world:queryRect(self.x - w/2, self.y - h/2, w, h,
        function(item)
            if item.type == "item" and not item.isEnabled then
                return true
            end
        end)
    if len > 0 then
        return items[1]
    end
    return nil
end

function Character:onGetItem(item)
    item:get(self)
end

function Character:stand_start()
    --	print (self.name.." - stand start")
    self.isHittable = true
    if self.sprite.cur_anim == "walk" then
        self.delay_animation_cool_down = 0.12
    else
        SetSpriteAnimation(self.sprite,"stand")
        self.delay_animation_cool_down = 0
    end
    self.can_jump = false
    self.can_attack = false
    self.victims = {}
    self.n_grabhit = 0
end
function Character:stand_update(dt)
    --	print (self.name," - stand update",dt)
    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
    end

    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end

    self.delay_animation_cool_down = self.delay_animation_cool_down - dt
    if self.sprite.cur_anim == "walk"
            and self.delay_animation_cool_down <= 0 then
        SetSpriteAnimation(self.sprite,"stand")
    end
    if self.cool_down_combo > 0 then
        self.cool_down_combo = self.cool_down_combo - dt
    else
        self.n_combo = 1
    end

    if (self.can_jump or self.can_attack) and
            (self.b.jump:isDown() and self.b.attack:isDown()) then
        self:setState(self.special)
        return
    elseif self.can_jump and self.b.jump:isDown() then
        self:setState(self.duck2jump)
        return
    elseif self.can_attack and self.b.attack:isDown() then
        if self:checkForItem(9, 9) ~= nil then
            self:setState(self.pickup)
            return
        end
        self:setState(self.combo)
        return
    end
    
    if self.cool_down <= 0 then
        --can move
        if self.b.horizontal:getValue() ~= 0 or
                self.b.vertical:getValue() ~= 0
        then
            self:setState(self.walk)
            return
        end
    else
        self.cool_down = self.cool_down - dt    --when <=0 u can move
        --can flip
        if self.b.horizontal:isDown(-1) then
            self.face = -1
            self.horizontal = self.face
            --dash from combo
            if self.b.horizontal.ikn:getLast()
                    and self.b.attack:isDown() and self.can_attack
            then
                self:setState(self.dash)
                return
            end
        elseif self.b.horizontal:isDown(1) then
            self.face = 1
            self.horizontal = self.face
            --dash from combo
            if self.b.horizontal.ikp:getLast()
                    and self.b.attack:isDown() and self.can_attack
            then
                self:setState(self.dash)
                return
            end
        end
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.stand = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw}

function Character:walk_start()
    self.isHittable = true
    --	print (self.name.." - walk start")
    SetSpriteAnimation(self.sprite,"walk")
    self.can_attack = false
    self.n_combo = 1	--if u move reset combo chain
end
function Character:walk_update(dt)
    --	print (self.name.." - walk update",dt)
    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
    end
    if self.b.attack:isDown() and self.can_attack then
        if self:checkForItem(9, 9) ~= nil then
            self:setState(self.pickup)
        else
            self:setState(self.combo)
        end
        return
    elseif self.b.jump:isDown() and self.can_jump then
        self:setState(self.duck2jump)
        return
    end
    self.velx = 0
    self.vely = 0
    if self.b.horizontal:isDown(-1) then
        self.face = -1 --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx = self.velocity_walk
        if self.b.horizontal.ikn:getLast() and self.face == -1 then
            self:setState(self.run)
            return
        end
    elseif self.b.horizontal:isDown(1) then
        self.face = 1 --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx = self.velocity_walk
        if self.b.horizontal.ikp:getLast() and self.face == 1 then
            self:setState(self.run)
            return
        end
    end
    if self.b.vertical:isDown(-1) then
        self.vertical = -1
        self.vely = self.velocity_walk_y
        if self.b.vertical.ikn:getLast() then
            self:setState(self.sideStepUp)
            return
        end
    elseif self.b.vertical:isDown(1) then
        self.vertical = 1
        self.vely = self.velocity_walk_y
        if self.b.vertical.ikp:getLast() then
            self:setState(self.sideStepDown)
            return
        end
    end
    local grabbed = self:checkForGrab(12)
    if grabbed then
        if self:doGrab(grabbed) then
            local g = self.hold
            self.victim_infoBar = g.target.infoBar:setAttacker(self)
            return
        end
    end
    if self.velx == 0 and self.vely == 0 then
        self:setState(self.stand)
        return
    end
    --self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.walk = {name = "walk", start = Character.walk_start, exit = nop, update = Character.walk_update, draw = Character.default_draw}

function Character:run_start()
    self.isHittable = true
    --	print (self.name.." - run start")
    self.delay_animation_cool_down = 0.01
    self.can_attack = false
end
function Character:run_update(dt)
    --	print (self.name.." - run update",dt)
    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
    end
    self.velx = 0
    self.vely = 0
    self.delay_animation_cool_down = self.delay_animation_cool_down - dt
    if self.sprite.cur_anim ~= "run"
            and self.delay_animation_cool_down <= 0 then
        SetSpriteAnimation(self.sprite,"run")
    end
    if self.b.horizontal:isDown(-1) then
        self.face = -1 --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx = self.velocity_run
    elseif self.b.horizontal:isDown(1) then
        self.face = 1 --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx = self.velocity_run
    end
    if self.b.vertical:isDown(-1) then
        self.vertical = -1
        self.vely = self.velocity_run_y
    elseif self.b.vertical:isDown(1) then
        self.vertical = 1
        self.vely = self.velocity_run_y
    end
    if (self.velx == 0 and self.vely == 0) or
        (self.b.horizontal:isDown(1) == false and self.b.horizontal:isDown(-1) == false)
        or (self.b.horizontal:isDown(1) and self.horizontal < 0)
        or (self.b.horizontal:isDown(-1) and self.horizontal > 0)
    then
        self:setState(self.stand)
        return
    end
    if self.b.attack:isDown() and self.can_attack then
        self:setState(self.dash)
        return
    elseif self.can_jump and self.b.jump:isDown() then
        --start jump dust clouds
        local psystem = PA_DUST_JUMP_START:clone()
        psystem:setAreaSpread( "uniform", 16, 4 )
        psystem:setLinearAcceleration(-30 , 10, 30, -10)
        psystem:emit(6)
        psystem:setAreaSpread( "uniform", 4, 16 )
        psystem:setPosition( 0, -16 )
        psystem:setLinearAcceleration(sign(self.face) * (self.velx + 200) , -50, sign(self.face) * (self.velx + 400), -700) -- Random movement in all directions.
        psystem:emit(5)
        stage.objects:add(Effect:new(psystem, self.x, self.y-1))
        self:setState(self.jump)
        return
    end
    --self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.run = {name = "run", start = Character.run_start, exit = nop, update = Character.run_update, draw = Character.default_draw}

function Character:jump_start()
    self.isHittable = true
    --	print (self.name.." - jump start")
    dpo(self, self.state)
    SetSpriteAnimation(self.sprite,"jump")
    self.velz = self.velocity_jump * self.velocity_jump_speed
    self.z = 0.1
    self.bounced = 0
    self.bounced_pitch = 1 + 0.05 * love.math.random(-4,4)
    if self.last_state == "run" then
        -- jump higher from run
        self.velz = (self.velocity_jump + self.velocity_jump_z_run_boost) * self.velocity_jump_speed
    end
    if self.b.vertical:isDown(-1) then
        self.vertical = -1
    elseif self.b.vertical:isDown(1) then
        self.vertical = 1
    else
        self.vertical = 0
    end
    if self.b.horizontal:isDown(-1) == false and self.b.horizontal:isDown(1) == false then
        self.velx = 0
    end
    if self.velx ~= 0 then
        self.velx = self.velx + self.velocity_jump_x_boost --make jump little faster than the walk/run speed
    end
    if self.vely ~= 0 then
        self.vely = self.vely + self.velocity_jump_y_boost --make jump little faster than the walk/run speed
    end
    sfx.play("voice"..self.id, self.sfx.jump)
end
function Character:jump_update(dt)
    --	print (self.name.." - jump update",dt)
    if self.b.attack:isDown() and self.can_attack then
        if (self.b.horizontal:isDown(-1) and self.face == 1)
                or (self.b.horizontal:isDown(1) and self.face == -1) then
            self:setState(self.jumpAttackLight)
            return
        elseif self.velx == 0 then
            self:setState(self.jumpAttackStraight)
            return
        else
            if self.velx >= self.velocity_run then
                self:setState(self.jumpAttackRun)
            else
                self:setState(self.jumpAttackForward)
            end
            return
        end
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
    else
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
    if not self.b.attack:isDown() then
        self.can_attack = true
    end
end
Character.jump = {name = "jump", start = Character.jump_start, exit = nop, update = Character.jump_update, draw = Character.default_draw}

function Character:pickup_start()
    self.isHittable = false
    --	print (self.name.." - pickup start")
    local item = self:checkForItem(9, 9)
    if item then
        self.victim_infoBar = item.infoBar:setPicker(self)
        --disappearing item
        local psystem = PA_ITEM_GET:clone()
        psystem:setQuads( item.q )
        psystem:setOffset( item.ox, item.oy )
        psystem:setPosition( item.x - self.x, item.y - self.y - 10 )
        psystem:emit(1)
        stage.objects:add(Effect:new(psystem, self.x, self.y + 10))
        self:onGetItem(item)
    end
    SetSpriteAnimation(self.sprite,"pickup")
    self.z = 0
end
function Character:pickup_update(dt)
    --	print (self.name.." - pickup update",dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.pickup = {name = "pickup", start = Character.pickup_start, exit = nop, update = Character.pickup_update, draw = Character.default_draw}

function Character:duck_start()
    self.isHittable = true
    dpo(self, self.state)
    --	print (self.name.." - duck start")
    SetSpriteAnimation(self.sprite,"duck")
    self.z = 0
    --landing dust clouds
    local psystem = PA_DUST_LANDING:clone()
    psystem:setLinearAcceleration(150, 1, 300, -35)
    psystem:setDirection( 0 )
    psystem:setPosition( 20, 0 )
    psystem:emit(5)
    psystem:setLinearAcceleration(-150, 1, -300, -35)
    psystem:setDirection( 3.14 )
    psystem:setPosition( -20, 0 )
    psystem:emit(5)
    stage.objects:add(Effect:new(psystem, self.x, self.y+2))
end
function Character:duck_update(dt)
    --	print (self.name.." - duck update",dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.duck = {name = "duck", start = Character.duck_start, exit = nop, update = Character.duck_update, draw = Character.default_draw}

function Character:duck2jump_start()
    self.isHittable = true
    --	print (self.name.." - duck2jump start")
    SetSpriteAnimation(self.sprite,"duck")
    self.z = 0
end
function Character:duck2jump_update(dt)
    --	print (self.name.." - duck2jump update",dt)
    if self.b.attack:isDown() and self:getStateTime() < self.special_tolerance_delay then
        self:setState(self.special)
        return
    end
    if self.sprite.isFinished then
        self:setState(self.jump)
        --start jump dust clouds
        local psystem = PA_DUST_JUMP_START:clone()
        psystem:setAreaSpread( "uniform", 16, 4 )
        psystem:setLinearAcceleration(-30 , 10, 30, -10)
        psystem:emit(6)
        psystem:setAreaSpread( "uniform", 4, 16 )
        psystem:setPosition( 0, -16 )
        psystem:setLinearAcceleration(sign(self.face) * (self.velx + 200) , -50, sign(self.face) * (self.velx + 400), -700) -- Random movement in all directions.
        psystem:emit(5)
        stage.objects:add(Effect:new(psystem, self.x, self.y-1))
        return
    end
    if self.b.horizontal:isDown(-1) then
        self.face = -1 --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx = self.velocity_walk
    elseif self.b.horizontal:isDown(1) then
        self.face = 1 --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx = self.velocity_walk
    end
    if self.b.vertical:isDown(-1) then
        self.vertical = -1
        self.vely = self.velocity_walk_y
    elseif self.b.vertical:isDown(1) then
        self.vertical = 1
        self.vely = self.velocity_walk_y
    end
    --self:calcFriction(dt)
    --self:checkCollisionAndMove(dt)
end
Character.duck2jump = {name = "duck2jump", start = Character.duck2jump_start, exit = nop, update = Character.duck2jump_update, draw = Character.default_draw}

function Character:hurtHigh_start()
    self.isHittable = true
    --	print (self.name.." - hurtHigh start")
    SetSpriteAnimation(self.sprite,"hurtHigh")
end
function Character:hurtHigh_update(dt)
    --	print (self.name.." - hurtHigh update",dt)
    if self.sprite.isFinished then
        if self.hp <= 0 then
            self:setState(self.getup)
            return
        end
        if self.isGrabbed then
            self:setState(self.grabbed)
        else
            self.cool_down = 0.1
            self:setState(self.stand)
        end
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.hurtHigh = {name = "hurtHigh", start = Character.hurtHigh_start, exit = nop, update = Character.hurtHigh_update, draw = Character.default_draw}

function Character:hurtLow_start()
    self.isHittable = true
    --	print (self.name.." - hurtLow start")
    SetSpriteAnimation(self.sprite,"hurtLow")
end
function Character:hurtLow_update(dt)
    --	print (self.name.." - hurtLow update",dt)
    if self.sprite.isFinished then
        if self.hp <= 0 then
            self:setState(self.getup)
            return
        end
        if self.isGrabbed then
            self:setState(self.grabbed)
        else
            self.cool_down = 0.1
            self:setState(self.stand)
        end
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.hurtLow = {name = "hurtLow", start = Character.hurtLow_start, exit = nop, update = Character.hurtHigh_update, draw = Character.default_draw}

function Character:sideStepDown_start()
    self.isHittable = false
    --	print (self.name.." - sideStepDown start")
    SetSpriteAnimation(self.sprite,"sideStepDown")
    self.velx, self.vely = 0, self.velocity_step_down
    sfx.play("sfx"..self.id, "whoosh_heavy")
end
function Character:sideStepDown_update(dt)
    --	print (self.name.." - sideStepDown update",dt)
    if self.vely > 0 then
        self.vely = self.vely - self.sideStepFriction * dt
        self.z = self.vely / 24 --to show low leap
    else
        self.vely = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step, 0.75)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
end
Character.sideStepDown = {name = "sideStepDown", start = Character.sideStepDown_start, exit = nop, update = Character.sideStepDown_update, draw = Character.default_draw}

function Character:sideStepUp_start()
    self.isHittable = false
    --	print (self.name.." - sideStepUp start")
    SetSpriteAnimation(self.sprite,"sideStepUp")
    self.velx, self.vely = 0, self.velocity_step_down
    sfx.play("sfx"..self.id, "whoosh_heavy")
end
function Character:sideStepUp_update(dt)
    --	print (self.name.." - sideStepUp update",dt)
    if self.vely > 0 then
        self.vely = self.vely - self.sideStepFriction * dt
        self.z = self.vely / 24 --to show low leap
    else
        self.vely = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step, 0.75)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
end
Character.sideStepUp = {name = "sideStepUp", start = Character.sideStepUp_start, exit = nop, update = Character.sideStepUp_update, draw = Character.default_draw}

function Character:dash_start()
    self.isHittable = true
    --	print (self.name.." - dash start")
    SetSpriteAnimation(self.sprite,"dash")
    self.velx = self.velocity_dash
    self.vely = 0
    self.velz = 0
    sfx.play("voice"..self.id, self.sfx.dash)
end
function Character:dash_update(dt)
    if self.b.jump:isDown() and self:getStateTime() < self.special_tolerance_delay then
        self:setState(self.special)
        return
    end
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt, self.friction_dash)
    self:checkCollisionAndMove(dt)
end
Character.dash = {name = "dash", start = Character.dash_start, exit = nop, update = Character.dash_update, draw = Character.default_draw}

function Character:jumpAttackForward_start()
    self.isHittable = true
    --	print (self.name.." - jumpAttackForward start")
    SetSpriteAnimation(self.sprite,"jumpAttackForward")
    sfx.play("voice"..self.id, self.sfx.jump_attack)
end
function Character:jumpAttackForward_update(dt)
    --	print (self.name.." - jumpAttackForward update",dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
    else
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
end
Character.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForward_start, exit = nop, update = Character.jumpAttackForward_update, draw = Character.default_draw}

function Character:jumpAttackLight_start()
    self.isHittable = true
    --	print (self.name.." - jumpAttackLight start")
    SetSpriteAnimation(self.sprite,"jumpAttackLight")
end
function Character:jumpAttackLight_update(dt)
    --	print (self.name.." - jumpAttackLight update",dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
    else
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
end
Character.jumpAttackLight = {name = "jumpAttackLight", start = Character.jumpAttackLight_start, exit = nop, update = Character.jumpAttackLight_update, draw = Character.default_draw}

function Character:jumpAttackStraight_start()
    self.isHittable = true
    --	print (self.name.." - jumpAttackStraight start")
    SetSpriteAnimation(self.sprite,"jumpAttackStraight")
    sfx.play("voice"..self.id, self.sfx.jump_attack)
end
function Character:jumpAttackStraight_update(dt)
    --	print (self.name.." - jumpAttackStraight update",dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
    else
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
end
Character.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraight_start, exit = nop, update = Character.jumpAttackStraight_update, draw = Character.default_draw}

function Character:jumpAttackRun_start()
    self.isHittable = true
    --	print (self.name.." - jumpAttackRun start")
    SetSpriteAnimation(self.sprite,"jumpAttackRun")
    sfx.play("voice"..self.id, self.sfx.jump_attack)
end
function Character:jumpAttackRun_update(dt)
    --	print (self.name.." - jumpAttackRun update",dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
    else
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
end
Character.jumpAttackRun = {name = "jumpAttackRun", start = Character.jumpAttackRun_start, exit = nop, update = Character.jumpAttackRun_update, draw = Character.default_draw}

function Character:fall_start()
    self.isHittable = false
    --    print (self.name.." - fall start")
    if self.isThrown then
        self.z = self.thrower_id.throw_start_z or 0
        SetSpriteAnimation(self.sprite,"thrown")
        dp("is--- ".. self.sprite.cur_anim)
    else
        SetSpriteAnimation(self.sprite,"fall")
    end
    if self.z <= 0 then
        self.z = 0
    end
    self.bounced = 0
    self.bounced_pitch = 1 + 0.05 * love.math.random(-4,4)
end
function Character:fall_update(dt)
    --dp(self.name .. " - fall update", dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
        if self.velz < 0 and self.sprite.cur_anim ~= "fallen" then
            if (self.isThrown and self.z < self.to_fallen_anim_z)
                or (not self.isThrown and self.z < self.to_fallen_anim_z / 4)
            then
                SetSpriteAnimation(self.sprite,"fallen")
            end
        end
        if self.z <= 0 then
            if self.velz < -100 and self.bounced < 1 then    --bounce up after fall (not )
                if self.velz < -300 then
                    self.velz = -300
                end
                self.z = 0.01
                self.velz = -self.velz/2
                self.velx = self.velx * 0.5

                if self.bounced == 0 then
                    mainCamera:onShake(0, 1, 0.03, 0.3)	--shake on the 1st land touch
                    if self.isThrown then
                        local src = self.thrower_id
                        --damage for throwned on landing
                        self:applyDamage(self.thrown_land_damage, "simple", src)
                    end
                end
                sfx.play("sfx"..self.id,"fall", 1 - self.bounced * 0.2, self.bounced_pitch - self.bounced * 0.2)
                self.bounced = self.bounced + 1
                --landing dust clouds
                local psystem = PA_DUST_FALLING:clone()
                psystem:emit(20)
                stage.objects:add(Effect:new(psystem, self.x + self.horizontal * 20, self.y+3))
                return
            else
                --final fall (no bouncing)
                self.z = 0
                self.velz = 0
                self.vely = 0
                self.velx = 0
                self.horizontal = self.face

                self.tx, self.ty = self.x, self.y --for enemy with AI movement

                sfx.play("sfx"..self.id,"fall", 0.5, self.bounced_pitch - self.bounced * 0.2)

                -- hold UP+JUMP to get no damage after throw (land on feet)
                if self.isThrown and self.b.vertical:isDown(-1) and self.b.jump:isDown() and self.hp >0 then
                    self:setState(self.duck)
                else
                    self:setState(self.getup)
                end
                return
            end
        end
        if self.isThrown and self.velz < 0 and self.bounced == 0 then
            --TODO dont check it on every FPS
            self:checkAndAttack(0,0, 20,12, self.my_thrown_body_damage, "fall", self.velocity_throw_x)
        end
    end
    self:checkCollisionAndMove(dt)
end
Character.fall = {name = "fall", start = Character.fall_start, exit = nop, update = Character.fall_update, draw = Character.default_draw}

function Character:getup_start()
    self.isHittable = false
    --print (self.name.." - getup start")
    dpo(self, self.state)
    if self.z <= 0 then
        self.z = 0
    end
    self.isThrown = false
    if self.hp <= 0 then
        self:setState(self.dead)
        return
    end
    SetSpriteAnimation(self.sprite,"getup")
end
function Character:getup_update(dt)
    --dp(self.name .. " - getup update", dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:checkCollisionAndMove(dt)
end
Character.getup = {name = "getup", start = Character.getup_start, exit = nop, update = Character.getup_update, draw = Character.default_draw}

function Character:dead_start()
    self.isHittable = false
    --print (self.name.." - dead start")
    SetSpriteAnimation(self.sprite,"fallen")
    dp(self.name.." is dead.")
    self.hp = 0
    self.hurt = nil
    self:release_grabbed()
    if self.z <= 0 then
        self.z = 0
    end
    --self:onShake(1, 0, 0.1, 0.7)
    sfx.play("voice"..self.id, self.sfx.dead)
    --TODO dead event
end
function Character:dead_update(dt)
    if self.isDisabled then
        return
    end
    --dp(self.name .. " - dead update", dt)
    if self.cool_down_death <= 0 then
        if self.id <= GLOBAL_SETTING.MAX_PLAYERS then
            -- Player?
            self:setState(self.useCredit)
            return
        end
        self.isDisabled = true
        self.isHittable = false
        -- dont remove dead body from the stage for proper save/load
        stage.world:remove(self)  --world = global bump var
        --self.y = GLOBAL_SETTING.OFFSCREEN
        return
    else
        self.cool_down_death = self.cool_down_death - dt
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.dead = {name = "dead", start = Character.dead_start, exit = nop, update = Character.dead_update, draw = Character.default_draw}

local players_list = {RICK = 1, KISA = 2, CHAI = 3, GOPPER = 4, NIKO = 5}
function Character:useCredit_start()
    self.isHittable = false
    self.lives = self.lives - 1
    if self.lives > 0 then
        dp(self.name.." used 1 life to respawn")
        self:setState(self.respawn)
        return
    end
    self.can_attack = false
    self.cool_down = 10
    -- Player select
    self.player_select_mode = 0
    self.player_select_cur = players_list[self.name]
    --print("self.player_select_cur",self.player_select_cur)
end
function Character:useCredit_update(dt)
    if self.isDisabled then
        return
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
    end

    if self.player_select_mode == 0 then
        -- 10 seconds to choose
        self.cool_down = self.cool_down - dt
        if credits <= 0 or self.cool_down <= 0 then
            -- n credits -> game over
            self.player_select_mode = 4
            return
        end
        -- wait press to use credit
        -- add countdown 9 .. 0 -> Game Over
        if self.b.attack:isDown() and self.can_attack then
            dp(self.name.." used 1 Credit to respawn")
            credits = credits - 1
            self:addScore(1) -- like CAPCM
            sfx.play("sfx","menu_select")
            self.cool_down = 1 -- delay before respawn
            self.player_select_mode = 1
        end
    elseif self.player_select_mode == 1 then
        -- wait 1 sec before player select
        if self.cool_down > 0 then
            -- wait before respawn / char select
            self.cool_down = self.cool_down - dt
            if self.cool_down <= 0 then
                self.can_attack = false
                self.cool_down = 100    --TODO debug. return to 10
                self.player_select_mode = 2
            end
        end
    elseif self.player_select_mode == 2 then
        -- Select Player
        -- 10 sec countdown before auto confirm
        if (self.b.attack:isDown() and self.can_attack)
                or self.cool_down <= 0
        then
            self.cool_down = 0
            self.player_select_mode = 3
            sfx.play("sfx","menu_select")
            local id = self.id
            player1 = HEROES[self.player_select_cur].hero:new(self.name,
                            GetSpriteInstance(HEROES[self.player_select_cur].sprite_instance),
                            self.b,
                            self.x, self.y,
                            self.shader,
                            {255,255,255, 255})
            player1.id = id
            return
        else
            self.cool_down = self.cool_down - dt
        end
        ---
        if self.b.horizontal:pressed(-1) or self.b.vertical:pressed(-1)
            or self.b.horizontal:pressed(1) or self.b.vertical:pressed(1)
        then
            if self.b.horizontal:pressed(-1) or self.b.vertical:pressed(-1) then
                self.player_select_cur = self.player_select_cur - 1
            else
                self.player_select_cur = self.player_select_cur + 1
            end
            if GLOBAL_SETTING.DEBUG then
                if self.player_select_cur > players_list.NIKO then
                    self.player_select_cur = 1
                end
                if self.player_select_cur < 1 then
                    self.player_select_cur = players_list.NIKO
                end
            else
                if self.player_select_cur > players_list.CHAI then
                    self.player_select_cur = 1
                end
                if self.player_select_cur < 1 then
                    self.player_select_cur = players_list.CHAI
                end
            end
            sfx.play("sfx","menu_move")
            self:onShake(1, 0, 0.03, 0.3)   --shake name + face icon
            self.name = HEROES[self.player_select_cur][1].name
            self.shader = HEROES[self.player_select_cur][1].shader
            self.sprite = GetSpriteInstance(HEROES[self.player_select_cur].sprite_instance)
            SetSpriteAnimation(self.sprite,"stand")
            self.infoBar.icon_sprite = self.sprite.def.sprite_sheet
            self.infoBar.q = self.sprite.def.animations["icon"][1].q  --face icon quad
            self.infoBar.icon_color = self.color
        end
    elseif self.player_select_mode == 3 then
        -- Spawn selecterd player
        self.lives = GLOBAL_SETTING.MAX_LIVES
        self:setState(self.respawn)
        return
    elseif self.player_select_mode == 4 then
        -- Game Over
    end
end
Character.useCredit = {name = "useCredit", start = Character.useCredit_start, exit = nop, update = Character.useCredit_update, draw = Character.default_draw}

function Character:respawn_start()
    self.isHittable = false
    dpo(self, self.state)
    SetSpriteAnimation(self.sprite,"respawn")
    self.cool_down_death = 3 --seconds to remove
    self.hp = self.max_hp
    self.bounced = 0
    self.velz = 0
    self.z = math.random( 235, 245 )
end
function Character:respawn_update(dt)
--    print (self.name.." - respawn update", self.z, self.sprite.cur_frame, self.sprite.elapsed_time)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
    elseif self.bounced == 0 then
        self.player_select_mode = 0 -- remove player select text
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        if self.sprite.cur_frame == 1 then
            self.sprite.elapsed_time = 10 -- seconds. skip to pickup 2 frame
        end
        self:checkAndAttack(0,0, 320 * 2, 240 * 2, 0, "shockWave", 0)
        self.bounced = 1
    end
    --self.victim_infoBar = nil   -- remove enemy bar under yours
    self:checkCollisionAndMove(dt)
end
Character.respawn = {name = "respawn", start = Character.respawn_start, exit = nop, update = Character.respawn_update, draw = Character.default_draw}

function Character:combo_start()
    self.isHittable = true
    --	print (self.name.." - combo start")
    if self.n_combo > 4 or self.n_combo < 1 then
        self.n_combo = 1
    end
    if self.n_combo == 1 then
        SetSpriteAnimation(self.sprite,"combo1")
    elseif self.n_combo == 2 then
        SetSpriteAnimation(self.sprite,"combo2")
    elseif self.n_combo == 3 then
        SetSpriteAnimation(self.sprite,"combo3")
    elseif self.n_combo == 4 then
        SetSpriteAnimation(self.sprite,"combo4")
    end
    self.cool_down = 0.2
end
function Character:combo_update(dt)
    if self.b.jump:isDown() and self:getStateTime() < self.special_tolerance_delay then
        self:setState(self.special)
        return
    end
    if self.sprite.isFinished then
        self.n_combo = self.n_combo + 1
        if self.n_combo > 5 then
            self.n_combo = 1
        end
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.combo = {name = "combo", start = Character.combo_start, exit = nop, update = Character.combo_update, draw = Character.default_draw}

-- GRABBING / HOLDING
function Character:checkForGrab(range)
    --got any Characters
    local items, len = stage.world:queryPoint(self.x + self.face*range, self.y,
        function(o)
            if o ~= self and o.isHittable then
                return true
            end
        end)
    if len > 0 then
        return items[1]
    end
    return nil
end

function Character:onGrab(source)
    -- hurt = {source, damage, velx,vely,x,y,z}
    local g = self.hold
    if self.isGrabbed then
        return false	-- already grabbed
    end
    if self.state ~= "stand"
            and self.state ~= "hurtHigh"
            and self.state ~= "hurtLow"
    then
        return false
    end
    self:remove_tween_move()
    dp(source.name .. " grabed me - "..self.name)
    if g.target and g.target.isGrabbed then	-- your grab targed releases one it grabs
        g.target.isGrabbed = false
    end
    g.source = source
    g.target = nil
    g.cool_down = self.cool_down_grab
    self.isGrabbed = true
    return self.isGrabbed
end

function Character:doGrab(target)
    dp(target.name .. " is grabed by me - "..self.name)
    local g = self.hold
    if self.isGrabbed then
        return false	-- i'm grabbed
    end
    if target.isGrabbed then
        self.cool_down = 0.2
        return false
    end

    if target:onGrab(self) then
        g.source = nil
        g.target = target
        g.cool_down = self.cool_down_grab + 0.1
        if g.target.x < self.x then
            self.face = -1
        else
            self.face = 1
        end
        sfx.play("voice"..self.id, target.sfx.grab)   --target's clothes ruffling sound
        self:setState(self.grab)
        return true
    end
    return false
end

function Character:grab_start()
    self.isHittable = true
    --print (self.name.." - grab start")
    SetSpriteAnimation(self.sprite,"grab")
    self.can_jump = false
    self.can_attack = false
    self.grab_release = 0
    self.victims = {}
    dp(self.name.." is grabing someone.")
end
function Character:grab_update(dt)
    --dp(self.name .. " - grab update", dt)
    local g = self.hold

    if (self.face == 1 and self.b.horizontal:isDown(-1)) or
            (self.face == -1 and self.b.horizontal:isDown(1))
    then
        self.grab_release = self.grab_release + dt
        if self.grab_release >= self.grab_release_after then
            g.target.isGrabbed = false
        end
    else
        self.grab_release = 0
    end

    if g.cool_down > 0 and g.target.isGrabbed then
        g.cool_down = g.cool_down - dt
    else
        --adjust players backoff
        if g.target.x > self.x then
            self.horizontal = -1
        else
            self.horizontal = 1
        end
        self.velx = self.velocity_back_off --move from source
        self.cool_down = 0.0
        self:release_grabbed()
        self:setState(self.stand)
        return
    end
    --adjust both vertically
    if self.y > g.target.y + 1 then
        self.y = self.y - 0.5
        g.target.y = g.target.y + 0.5
    elseif self.y < g.target.y then
        self.y = self.y + 0.5
        g.target.y = g.target.y - 0.5
    end
    --adjust both horizontally
    if self.x < g.target.x and self.x > g.target.x - 20 then
        --self.x = self.x - 1
        self.velx = 1
    elseif self.x >= g.target.x and self.x < g.target.x + 20 then
        --self.x = self.x + 1
        self.velx = 1
    end

    if self.b.attack:isDown() and self.can_attack then
        if self.sprite.isFinished then
            if self.b.horizontal:getValue() ~= 0 or self.b.horizontal:isDown(-1) or self.b.vertical:isDown(-1)
            then
                if not self.throw_direction then
                    self.throw_direction = {}
                end
                self.throw_direction.horizontal = self.b.horizontal:getValue()
                self.throw_direction.vertical = self.b.vertical:isDown(-1)
                self:setState(self.grabThrow)
                return
            else
                self:setState(self.grabHit)
                return
            end
        end
    end

    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.grab = {name = "grab", start = Character.grab_start, exit = nop, update = Character.grab_update, draw = Character.default_draw}

function Character:release_grabbed()
    local g = self.hold
    if g and g.target and g.target.isGrabbed then
        g.target.isGrabbed = false
        g.target.cool_down = 0.1
        self.hold = {source = nil, target = nil, cool_down = 0 }	--release a grabbed person
        return true
    end
    return false
end

function Character:grabbed_start()
    self.isHittable = true
    --print (self.name.." - grabbed start")
    SetSpriteAnimation(self.sprite,"grabbed")
    dp(self.name.." is grabbed.")
end
function Character:grabbed_update(dt)
    --dp(self.name .. " - grabbed update", dt)
    local g = self.hold
    if self.isGrabbed and g.cool_down > 0 then
        g.cool_down = g.cool_down - dt
    else
        if g.source.x < self.x then
            self.horizontal = 1
        else
            self.horizontal = -1
        end
        self.isGrabbed = false
        self.cool_down = 0.1	--cannot walk etc
        self.velx = self.velocity_back_off2 --move from source
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.grabbed = {name = "grabbed", start = Character.grabbed_start, exit = nop, update = Character.grabbed_update, draw = Character.default_draw}

function Character:grabHit_start()
    self.isHittable = true
    --print (self.name.." - grabhit start")
    local g = self.hold
    if self.b.vertical:isDown(1) then --press DOWN to early headbutt
        g.cool_down = 0
        self:setState(self.grabHitEnd)
        return
    else
        g.cool_down = self.cool_down_grab + 0.1
        g.target.hold.cool_down = self.cool_down_grab
    end
    self.n_grabhit = self.n_grabhit + 1
    if self.n_grabhit > 2 then
        self:setState(self.grabHitLast)
        return
    end
    SetSpriteAnimation(self.sprite,"grabHit")
    dp(self.name.." is grabhit someone.")
end
function Character:grabHit_update(dt)
    if self.b.jump:isDown() and self:getStateTime() < self.special_tolerance_delay then
        self:setState(self.special)
        return
    end
    --dp(self.name .. " - grabhit update", dt)
    if self.sprite.isFinished then
        self:setState(self.grab)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.grabHit = {name = "grabHit", start = Character.grabHit_start, exit = nop, update = Character.grabHit_update, draw = Character.default_draw}

function Character:grabHitLast_start()
    self.isHittable = true
    --print (self.name.." - grabHitLast start")
    SetSpriteAnimation(self.sprite,"grabHitLast")
    dp(self.name.." is grabHitLast someone.")
end
function Character:grabHitLast_update(dt)
    if self.b.jump:isDown() and self:getStateTime() < self.special_tolerance_delay then
        self:setState(self.special)
        return
    end
    --dp(self.name .. " - grabHitLast update", dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.grabHitLast = {name = "grabHitLast", start = Character.grabHitLast_start, exit = nop, update = Character.grabHitLast_update, draw = Character.default_draw }

function Character:grabHitEnd_start()
    self.isHittable = true
    --print (self.name.." - grabhitend start")
    SetSpriteAnimation(self.sprite,"grabHitEnd")
    dp(self.name.." is grabhitend someone.")
end
function Character:grabHitEnd_update(dt)
    --dp(self.name .. " - grabhitend update", dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.grabHitEnd = {name = "grabHitEnd", start = Character.grabHitEnd_start, exit = nop, update = Character.grabHitEnd_update, draw = Character.default_draw}

function Character:grabThrow_start()
    self.isHittable = false
    --print (self.name.." - grabThrow start")
    local g = self.hold
    local t = g.target
    self.face = -self.face
    SetSpriteAnimation(t.sprite,"hurtLow")
    SetSpriteAnimation(self.sprite,"grabThrow")
    dp(self.name.." is grabThrow someone.")
end

function Character:grabThrow_update(dt)
    --dp(self.name .. " - grabThrow update", dt)
    if self.can_throw_now then --set in the anm
        self.can_throw_now = false
        local g = self.hold
        local t = g.target
        t.isGrabbed = false
        t.isThrown = true
        t.thrower_id = self
        t.z = t.z + 1
        t.velx = self.velocity_grab_throw_x
        t.vely = 0
        t.velz = self.velocity_grab_throw_z
        t.victims[self] = true
        if self.throw_direction.horizontal ~= 0 then
            dp("throw right left", self.throw_direction.horizontal)
            self.face = self.throw_direction.horizontal
            t.horizontal = self.throw_direction.horizontal
            t.face = self.throw_direction.horizontal
            t:setState(self.fall)
            sfx.play("sfx", "whoosh_heavy")
            sfx.play("voice"..self.id, self.sfx.throw)
        elseif self.throw_direction.vertical then
            --throw up
            t.horizontal = self.horizontal
            t.velx = self.velocity_grab_throw_x / 10
            t.velz = self.velocity_grab_throw_z * 2
            t:setState(self.fall)
            sfx.play("sfx", "whoosh_heavy")
            sfx.play("voice"..self.id, self.sfx.throw)
        end
        return
    end
    if self.sprite.isFinished then
        self.cool_down = 0.2
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.grabThrow = {name = "grabThrow", start = Character.grabThrow_start, exit = nop, update = Character.grabThrow_update, draw = Character.default_draw}

function Character:special_start() -- Special attack plug
    self:setState(self.stand)
end
Character.special = {name = "special", start = Character.special_start, exit = nop, update = nop, draw = Character.default_draw }

--function Character:revive()
--    self.hp = self.max_hp
--    self.hurt = nil
--    self.z = 0
--    self.cool_down_death = 3 --seconds to remove
--    self.isDisabled = false
--    self.isThrown = false
--    self.victims = {}
--    self.infoBar = InfoBar:new(self)
--    self.victim_infoBar = nil
--    self:setState(self.stand)
--    self:showPID(3)
--end

return Character