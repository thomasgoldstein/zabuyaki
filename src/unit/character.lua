local class = require "lib/middleclass"
local class = require "lib/middleclass"
local Character = class('Character', Unit)

local function nop() end
local sign = sign
local clamp = clamp

function Character:initialize(name, sprite, input, x, y, f)
    Unit.initialize(self, name, sprite, input, x, y, f)
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
    self.velocity_shove_x = 220 --my throwing speed
    self.velocity_shove_z = 200 --my throwing speed
    self.velocity_shove_horizontal = 1.3 -- +30% for horizontal throws
    self.velocity_back_off = 175 --when you ungrab someone
    self.velocity_back_off2 = 200 --when you are released
    self.velocity_bonus_on_attack_x = 30
    self.velocity_throw_x = 110 --attack speed that causes my thrown body to the victims
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    self.isMovable = true --can be moved by attacks / can be grabbed
    --Inner char vars
    self.toughness = 0 --0 slow .. 5 fast, more aggressive (for enemy AI)
    self.score = 0
    self.charged_at = 1    -- define # seconds when holdAttack is ready
    self.charge = 0    -- seconds of changing
    self.n_combo = 1    -- n of the combo hit
    self.cool_down = 0  -- can't move
    self.cool_down_combo = 0    -- can cont combo
    self.cool_down_grab = 2
    self.grab_release_after = 0.35 --sec if u hold 'back'
    self.n_grabhit = 0    -- n of the grab hits
    self.special_tolerance_delay = 0.02 -- between pressing attack & Jump
    self.player_select_mode = 0
    --Character default sfx
    self.sfx.jump = "whoosh_heavy"
    self.sfx.throw = "air"
    self.sfx.dash = "scream1"
    self.sfx.grab = "grab"
    self.sfx.jump_attack = self.sfx.jump_attack or "scream1"
    self.sfx.step = self.sfx.step or "kisa_step"
    self.sfx.dead = self.sfx.dead or "scream1"
    self.infoBar = InfoBar:new(self)
    self.victim_infoBar = nil
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
        if self.func then   -- custom function on death
            self:func(self)
            self.func = nil
        end
    end
end

function Character:addScore(score)
    self.score = self.score + score
end

-- Start of Lifebar elements
function Character:initFaceIcon(target)
    target.sprite = image_bank[self.sprite.def.sprite_sheet]
    target.q = self.sprite.def.animations["icon"][1].q  --quad
    target.qa = self.sprite.def.animations["icon"]  --quad array
    target.icon_color = self.color or { 255, 255, 255, 255 }
    target.shader = self.shader
end

function Character:drawFaceIcon(l, t)
    local s = self.qa
    local n = clamp(math.floor((#s-1) - (#s-1) * self.hp / self.max_hp)+1,
        1, #s)
    love.graphics.draw (
        self.sprite,
        self.qa[n].q, --Current frame of the current animation
        l + self.source.shake.x / 2, t
    )
end

local calcBarTransparency = calcBarTransparency
local printWithShadow = printWithShadow
function Character:drawTextInfo(l, t, transp_bg, icon_width)
    love.graphics.setColor(255, 255, 255, transp_bg)
    printWithShadow(self.name, l + self.shake.x + icon_width + 2, t + 9,
        transp_bg)
end

function Character:drawBar(l,t,w,h, icon_width, norm_color)
    love.graphics.setFont(gfx.font.arcade3)
    local transp_bg = 255 * calcBarTransparency(self.cool_down)
    self:draw_lifebar(l, t, transp_bg)
    self:drawFaceIcon(l + self.source.shake.x, t, transp_bg)
    self:draw_dead_cross(l, t, transp_bg)
    self.source:drawTextInfo(l + self.x, t + self.y, transp_bg, icon_width, norm_color)
end
-- End of Lifebar elements

function Character:updateAI(dt)
    if self.isDisabled then
        return
    end
    self:updateShake(dt)
    Unit.updateAI(self, dt)
end

function Character:isImmune()   --Immune to the attack?
    local h = self.hurt
    if h.type == "shockWave" and ( self.isDisabled or self.sprite.cur_anim == "fallen" ) then
        -- shockWave has no effect on players & obstacles
        self.hurt = nil --free hurt data
        return true
    end
    return false
end

function Character:onHurt()
    -- hurt = {source, damage, velx,vely,x,y,z}
    local h = self.hurt
    if not h then
        return
    end
    -- got Immunity?
    if self:isImmune() then
        self.hurt = nil
        return
    end
    self:onHurtDamage()
    self:afterOnHurt()
    self.hurt = nil --free hurt data
end

function Character:onHurtDamage()
    local h = self.hurt
    if not h then
        return
    end
    if h.continuous then
        h.source.victims[self] = true
    end
    self:release_grabbed()
    h.damage = h.damage or 100  --TODO debug if u forgot
    dp(h.source.name .. " damaged "..self.name.." by "..h.damage..". HP left: "..(self.hp - h.damage)..". Lives:"..self.lives)
    if h.type ~= "shockWave" then
        -- show enemy bar for other attacks
        h.source.victim_infoBar = self.infoBar:setAttacker(h.source)
        if self.id <= GLOBAL_SETTING.MAX_PLAYERS then
            self.victim_infoBar = h.source.infoBar:setAttacker(self)
        end
    end
    -- Score
    h.source:addScore( h.damage * 10 )
    self.killer_id = h.source
    self:onShake(1, 0, 0.03, 0.3)   --shake a character
    if self.id <= GLOBAL_SETTING.MAX_PLAYERS then
        mainCamera:onShake(0, 1, 0.03, 0.3)	--shake the screen for Players only
    end
    self:decreaseHp(h.damage)
    if h.type == "simple" then
        return
    end
    self:playHitSfx(h.damage)
    self.n_combo = 1	--if u get hit reset combo chain
    if h.source.velx == 0 then
        self.face = -h.source.face	--turn face to the still(pulled back) attacker
    else
        self.face = -h.source.horizontal	--turn face to the attacker
    end
end

function Character:afterOnHurt()
    local h = self.hurt
    if not h then
        return
    end
    --"simple", "blow-vertical", "blow-diagonal", "blow-horizontal", "blow-away"
    --"high", "low", "fall"(replaced by blows)
    if h.type == "high" then
        if self.hp > 0 and self.z <= 0 then
            self:showHitMarks(h.damage, 40)
            self:setState(self.hurtHigh)
            return
        end
        self.velx = h.velx --use fall speed from the agument
        --then it does to "fall dead"
    elseif h.type == "low" then
        if self.hp > 0 and self.z <= 0 then
            self:showHitMarks(h.damage, 16)
            self:setState(self.hurtLow)
            return
        end
        self.velx = h.velx --use fall speed from the agument
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
    elseif h.type == "simple" then
        return
    else
        error("OnHurt - unknown h.type = "..h.type)
    end
    dpo(self, self.state)
    --finish calcs before the fall state
    if h.type == "low" then
        self:showHitMarks(h.damage, 16)
    else
        self:showHitMarks(h.damage, 40)
    end
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
        --self.face = -h.horizontal	--turn face to the epicenter
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

function Character:applyDamage(damage, type, source, velocity, sfx1)
    self.hurt = {source = source or self, state = self.state, damage = damage,
        type = type, velx = velocity or 0,
        horizontal = self.face, isThrown = false,
        x = self.x, y = self.y, z = self.z }
    if sfx1 then
        sfx.play("sfx"..self.id,sfx1)
    end
end

function Character:checkAndAttack(f, isFuncCont)
    --f options {}: l,t,w,h, damage, type, velocity, sfx, init_victims_list
    --type = "shockWave" "high" "low" "fall" "blow-vertical" "blow-diagonal" "blow-horizontal" "blow-away"
    if not f then
        f = {}
    end
    local l,t,w,h = f.left or 20, f.top or 0, f.width or 25, f.height or 12
    local damage, type, velocity = f.damage or 1, f.type or "low", f.velocity or 0
    local face = self.face

    local items = {}
    local a = stage.world:rectangle(self.x + face*l - w/2, self.y + t - h/2, w, h)
    if type == "shockWave" then
        for other, separating_vector in pairs(stage.world:collisions(a)) do
            local o = other.obj
            if not o.isDisabled
                    and o ~= self
            then
                o.hurt = {source = self, state = self.state, damage = damage,
                    type = type, velx = velocity or self.velocity_bonus_on_attack_x,
                    horizontal = face, isThrown = false,
                    x = self.x, y = self.y, z = self.z }
                items[#items+1] = o
            end
        end
    else
        for other, separating_vector in pairs(stage.world:collisions(a)) do
            local o = other.obj
            if o.isHittable
                    and not o.isGrabbed
                    and not o.isDisabled
                    and o ~= self
                    and not self.victims[o]
                    and o.z <= self.z + o.height and o.z >= self.z - self.height
            then
                if self.isThrown then
                    o.hurt = {source = self.thrower_id, state = self.state, damage = damage,
                        type = type, velx = velocity or self.velocity_bonus_on_attack_x,
                        horizontal = self.horizontal, isThrown = true,
                        x = self.x, y = self.y, z = self.z }
                else
                    o.hurt = {source = self, state = self.state, damage = damage,
                        type = type, velx = velocity or self.velocity_bonus_on_attack_x,
                        horizontal = face, isThrown = false,
                        continuous = isFuncCont,
                        x = self.x, y = self.y, z = self.z }
                end
                items[#items+1] = o
            end
        end
    end
    stage.world:remove(a)
    a = nil
    --DEBUG collect data to show attack hitBoxes in green
    if GLOBAL_SETTING.DEBUG then
        attackHitBoxes[#attackHitBoxes+1] = {x = self.x + face*l - w/2, y = self.y + t - h/2, w = w, h = h, z = self.z, height = self.height }
    end
    if f.sfx then
        sfx.play("sfx"..self.id,f.sfx)
    end
    if not GLOBAL_SETTING.AUTO_COMBO and #items < 1 then
        -- reset combo attack N to 1
        self.n_combo = 0
    end
    items = nil
end

function Character:checkAndAttackGrabbed(f, isFuncCont)
    --f options {}: l,t,w,h, damage, type, velocity, sfx
    --type = "high" "low" "fall" "blow-vertical" "blow-diagonal" "blow-horizontal" "blow-away"
    if not f then
        f = {}
    end
    local face
    if self.isThrown then
        face = -face
    else
        face = self.face
    end
    local l,t,w,h = f.left or 10, f.top or 0, f.width or 20, f.height or 12
    local damage, type, velocity = f.damage or 1, f.type or "low", f.velocity or self.velx

    local g = self.hold
    if not g.target then --can attack only the 1 grabbed
        return
    end
    --DEBUG collect data to show attack hitBoxes in green
    if GLOBAL_SETTING.DEBUG then
        attackHitBoxes[#attackHitBoxes+1] = {x = self.x + face*l - w/2, y = self.y + t - h/2, w = w, h = h, z = self.z, height = self.height }
    end
    local a = stage.world:rectangle(self.x + face*l - w/2, self.y + t - h/2, w, h)
    if a:collidesWith(g.target.shape) then
        g.target.hurt = {source = self, state = self.state, damage = damage,
            type = type, velx = velocity or self.velocity_bonus_on_attack_x,
            horizontal = self.horizontal,
            continuous = isFuncCont,
            x = self.x, y = self.y, z = self.z }
        if f.sfx then	--TODO 2 SFX for hollow and hit
            sfx.play("sfx"..self.id, f.sfx)
        end
    end
    stage.world:remove(a)
    a = nil
end

function Character:checkForLoot(w, h)
    --got any loot near feet?
    local loot = {}
    for other, separating_vector in pairs(stage.world:collisions(self.shape)) do
        local o = other.obj
        if o.type == "loot"
                and not o.isEnabled
        then
            loot[#loot+1] = o
        end
    end

    if #loot > 0 then
        return loot[1]
    end
    return nil
end

function Character:onGetLoot(loot)
    loot:get(self)
end

function Character:stand_start()
    self.isHittable = true
    if self.sprite.cur_anim == "walk" then
        self.delay_animation_cool_down = 0.12
    else
        self:setSprite("stand")
        self.delay_animation_cool_down = 0
    end
    self.can_jump = false
    self.can_attack = false
    self.victims = {}
    self.n_grabhit = 0
end
function Character:stand_update(dt)
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
    if self.delay_animation_cool_down <= 0 then
        if self.b.attack:isDown() then
            if self.sprite.cur_anim ~= "standHold" then
                self:setSpriteIfExists("standHold")
            end
        else
            if self.sprite.cur_anim ~= "stand" then
                self:setSprite("stand")
            end
        end
    end

    if self.cool_down_combo > 0 then
        self.cool_down_combo = self.cool_down_combo - dt
    else
        self.n_combo = 1
    end

    if (self.can_jump or self.can_attack) and
            (self.b.jump:isDown() and self.b.attack:isDown()) then
        if self.b.horizontal:getValue() ~= 0 then
            self:setState(self.dashSpecial)
        else
            self:setState(self.special)
        end
        return
    elseif self.can_jump and self.b.jump:isDown() then
        self:setState(self.duck2jump)
        return
    elseif self.can_attack and self.b.attack:pressed() then
        if self:checkForLoot(9, 9) ~= nil then
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
        --can flip while you cannot move
        if self.b.horizontal:isDown(-1) then
            self.face = -1
            self.horizontal = self.face
        elseif self.b.horizontal:isDown(1) then
            self.face = 1
            self.horizontal = self.face
        end
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.stand = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw}

function Character:walk_start()
    self.isHittable = true
    self:setSprite("walk")
    self.can_attack = false
    self.can_jump = false
    self.n_combo = 1	--if u move reset combo chain
end
function Character:walk_update(dt)
    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
    end
    if self.b.attack:isDown() and self.can_attack then
        if self:checkForLoot(9, 9) ~= nil then
            self:setState(self.pickup)
        else
            self:setState(self.combo)
        end
        return
    elseif self.b.jump:isDown() and self.can_jump then
        if self.b.attack:isDown() then
            self:setState(self.dashSpecial)
        else
            self:setState(self.duck2jump)
        end
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
    if self.b.attack:isDown() then
        local grabbed = self:checkForGrab(12)
        if grabbed then
            if self:doGrab(grabbed) then
                local g = self.hold
                self.victim_infoBar = g.target.infoBar:setAttacker(self)
                return
            end
        end
        if self.sprite.cur_anim ~= "walkHold" then
            self:setSpriteIfExists("walkHold")
        end
    else
        if self.sprite.cur_anim ~= "walk" then
            self:setSprite("walk")
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
    self.delay_animation_cool_down = 0.01
    self.can_attack = false
end
function Character:run_update(dt)
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
        self:setSprite("run")
    end
    if self.b.horizontal:getValue() ~= 0 then
        self.face = self.b.horizontal:getValue() --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx = self.velocity_run
    end
    if self.b.vertical:getValue() ~= 0 then
        self.vertical = self.b.vertical:getValue()
        self.vely = self.velocity_run_y
    end
    if (self.velx == 0 and self.vely == 0)
        or (self.b.horizontal:getValue() == 0)
        or (self.b.horizontal:getValue() == -self.horizontal)
    then
        self:setState(self.stand)
        return
    end
    if self.can_jump and self.b.jump:isDown() then
        if self.b.attack:isDown() then
            self:setState(self.dashSpecial)
        else
            self:setState(self.duck2jump, true) --pass condition to block dir changing
        end
        return
    elseif self.b.attack:isDown() and self.can_attack then
        if self.b.jump:isDown() then
            self:setState(self.dashSpecial)
        else
            self:setState(self.dash)
        end
        return
    end
    --self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.run = {name = "run", start = Character.run_start, exit = nop, update = Character.run_update, draw = Character.default_draw}

function Character:jump_start()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("jump")
    self.velz = self.velocity_jump * self.velocity_jump_speed
    self.z = 0.1
    self.bounced = 0
    self.bounced_pitch = 1 + 0.05 * love.math.random(-4,4)
    if self.prev_state == "run" then
        -- jump higher from run
        self.velz = (self.velocity_jump + self.velocity_jump_z_run_boost) * self.velocity_jump_speed
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
    if self.b.attack:isDown() and self.can_attack then
        if (self.b.horizontal:getValue() == -self.face) then
            self:setState(self.jumpAttackLight)
            return
        elseif self.velx == 0 then
            self:setState(self.jumpAttackStraight)
            return
        else
            if self.velx >= self.velocity_run then
                self:setState(self.jumpAttackRun)
            elseif self.horizontal ~= self.face then
                self:setState(self.jumpAttackStraight)
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
    local loot = self:checkForLoot(9, 9)
    if loot then
        self.victim_infoBar = loot.infoBar:setPicker(self)
        --disappearing loot
        local psystem = PA_LOOT_GET:clone()
        psystem:setQuads( loot.q )
        psystem:setOffset( loot.ox, loot.oy )
        psystem:setPosition( loot.x - self.x, loot.y - self.y - 10 )
        psystem:emit(1)
        stage.objects:add(Effect:new(psystem, self.x, self.y + 10))
        self:onGetLoot(loot)
    end
    self:setSprite("pickup")
    self.z = 0
end
function Character:pickup_update(dt)
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
    self:setSprite("duck")
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
    if self.sprite.isFinished then
        if self.b.horizontal:getValue() ~= 0 then
            self:setState(self.walk)
        else
            self:setState(self.stand)
        end
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.duck = {name = "duck", start = Character.duck_start, exit = nop, update = Character.duck_update, draw = Character.default_draw}

function Character:duck2jump_start()
    self.isHittable = true
    self:setSprite("duck")
    self.z = 0
end
function Character:duck2jump_update(dt)
    if self:getStateTime() < self.special_tolerance_delay then
        --time for other move
        if self.b.attack:isDown() then
            if self.velx ~= 0 then
                self:setState(self.dashSpecial)
            else
                self:setState(self.special)
            end
            return
        end
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
    if not self.condition then
        --duck2jump can change direction of the jump
        local hv = self.b.horizontal:getValue()
        if hv ~= 0 then
            --self.face = hv --face sprite left or right
            self.horizontal = hv
            self.velx = self.velocity_walk
        end
        if self.b.vertical:getValue() ~= 0 then
            self.vertical = self.b.vertical:getValue()
            self.vely = self.velocity_walk_y
        end
    end
    --self:calcFriction(dt)
    --self:checkCollisionAndMove(dt)
end
Character.duck2jump = {name = "duck2jump", start = Character.duck2jump_start, exit = nop, update = Character.duck2jump_update, draw = Character.default_draw}

function Character:hurtHigh_start()
    self.isHittable = true
    self:setSprite("hurtHigh")
end
function Character:hurtHigh_update(dt)
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
    self:setSprite("hurtLow")
end
function Character:hurtLow_update(dt)
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
    self:setSprite("sideStepDown")
    self.velx, self.vely = 0, self.velocity_step_down
    sfx.play("sfx"..self.id, "whoosh_heavy")
end
function Character:sideStepDown_update(dt)
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
    self:setSprite("sideStepUp")
    self.velx, self.vely = 0, self.velocity_step_down
    sfx.play("sfx"..self.id, "whoosh_heavy")
end
function Character:sideStepUp_update(dt)
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
    self:setSprite("dash")
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

function Character:dashSpecial_start()
    --no move by default
    self:setState(self.stand)
end
Character.dashSpecial = {name = "dashSpecial", start = Character.dashSpecial_start, exit = nop, update = nop, draw = Character.default_draw }

function Character:jumpAttackForward_start()
    self.isHittable = true
    self.played_landing_anim = false
    self:setSprite("jumpAttackForward")
    sfx.play("voice"..self.id, self.sfx.jump_attack)
end
function Character:jumpAttackForward_update(dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
        if not self.played_landing_anim and self.velz < 0 and self.z <= 10 then
            self:setSpriteIfExists("jumpAttackForwardEnd")
            self.played_landing_anim = true
        end
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
    self.played_landing_anim = false
    self:setSprite("jumpAttackLight")
end
function Character:jumpAttackLight_update(dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
        if not self.played_landing_anim and self.velz < 0 and self.z <= 10 then
            self:setSpriteIfExists("jumpAttackLightEnd")
            self.played_landing_anim = true
        end
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
    self.played_landing_anim = false
    self:setSprite("jumpAttackStraight")
    sfx.play("voice"..self.id, self.sfx.jump_attack)
end
function Character:jumpAttackStraight_update(dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
        if not self.played_landing_anim and self.velz < 0 and self.z <= 10 then
            self:setSpriteIfExists("jumpAttackStraightEnd")
            self.played_landing_anim = true
        end
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
    self.played_landing_anim = false
    self:setSprite("jumpAttackRun")
    sfx.play("voice"..self.id, self.sfx.jump_attack)
end
function Character:jumpAttackRun_update(dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
        if not self.played_landing_anim and self.velz < 0 and self.z <= 10 then
            self:setSpriteIfExists("jumpAttackRunEnd")
            self.played_landing_anim = true
        end
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
    if self.isThrown then
        self.z = self.thrower_id.throw_start_z or 0
        self:setSprite("thrown")
        dp("is ".. self.sprite.cur_anim)
    else
        self:setSprite("fall")
    end
    if self.z <= 0 then
        self.z = 0
    end
    self.bounced = 0
    self.bounced_pitch = 1 + 0.05 * love.math.random(-4,4)
end
function Character:fall_update(dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
        if self.velz < 0 and self.sprite.cur_anim ~= "fallen" then
            if (self.isThrown and self.z < self.to_fallen_anim_z)
                or (not self.isThrown and self.z < self.to_fallen_anim_z / 4)
            then
                self:setSprite("fallen")
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
                sfx.play("sfx" .. self.id, self.sfx.onBreak or "fall", 1 - self.bounced * 0.2, self.bounced_pitch - self.bounced * 0.2)
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
            self:checkAndAttack(
                { left = 0, width = 20, height = 12, damage = self.my_thrown_body_damage, type = "fall", velocity = self.velocity_throw_x },
                false
            )

        end
    end
    self:checkCollisionAndMove(dt)
end
Character.fall = {name = "fall", start = Character.fall_start, exit = nop, update = Character.fall_update, draw = Character.default_draw}

function Character:getup_start()
    self.isHittable = false
    dpo(self, self.state)
    self.hurt = nil
    if self.z <= 0 then
        self.z = 0
    end
    self.isThrown = false
    if self.hp <= 0 then
        self:setState(self.dead)
        return
    end
    self:setSprite("getup")
end
function Character:getup_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:checkCollisionAndMove(dt)
end
Character.getup = {name = "getup", start = Character.getup_start, exit = nop, update = Character.getup_update, draw = Character.default_draw}

function Character:dead_start()
    self.isHittable = false
    self:setSprite("fallen")
    dp(self.name.." is dead.")
    self.hp = 0
    self.hurt = nil
    self:release_grabbed()
    if self.z <= 0 then
        self.z = 0
    end
    sfx.play("voice"..self.id, self.sfx.dead)
    if self.killer_id then
        self.killer_id:addScore( self.score_bonus )
    end
end
function Character:dead_update(dt)
    if self.isDisabled then
        return
    end
    if self.cool_down_death <= 0 then
        self.isDisabled = true
        self.isHittable = false
        -- dont remove dead body from the stage for proper save/load
        stage.world:remove(self.shape)  --stage.world = global collision shapes pool
        self.shape = nil
        --self.y = GLOBAL_SETTING.OFFSCREEN
        return
    else
        self.cool_down_death = self.cool_down_death - dt
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.dead = {name = "dead", start = Character.dead_start, exit = nop, update = Character.dead_update, draw = Character.default_draw}

function Character:combo_start()
    self.isHittable = true
    if self.n_combo > 4 or self.n_combo < 1 then
        self.n_combo = 1
    end
    if self.n_combo == 1 then
        self:setSprite("combo1")
    elseif self.n_combo == 2 then
        self:setSprite("combo2")
    elseif self.n_combo == 3 then
        self:setSprite("combo3")
    elseif self.n_combo == 4 then
        self:setSprite("combo4")
    end
    self.cool_down = 0.2
end
function Character:combo_update(dt)
    if self.b.jump:isDown() and self:getStateTime() < self.special_tolerance_delay then
        if self.b.horizontal:getValue() == self.horizontal then
            self:setState(self.dashSpecial)
        else
            self:setState(self.special)
        end
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
    local items = {}
    self.shape:moveTo(self.x + self.horizontal, self.y + self.vertical)
    for other, separating_vector in pairs(stage.world:collisions(self.shape)) do
        local o = other.obj
        if o.isHittable
                and not o.isGrabbed
                and o.isMovable
        then
            items[#items+1] = o
        end
    end
    if #items > 0 then
        return items[1]
    end
    return nil
end

function Character:onGrab(source)
    -- hurt = {source, damage, velx,vely,x,y,z}
    local g = self.hold
    if not self.isHittable or self.z > 0 then
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
    if self.z ~= 0 or self.velz ~= 0 then
        return false
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
            self.horizontal = -1
        else
            self.face = 1
            self.horizontal = 1
        end
        g.can_grabSwap = true   --can do 1 grabSwap
        sfx.play("voice"..self.id, target.sfx.grab)   --target's clothes ruffling sound
        self:setState(self.grab)
        return true
    end
    return false
end

function Character:grab_start()
    self.isHittable = true
    self:setSprite("grab")
    self.can_jump = false
    self.can_attack = false
    self.grab_release = 0
    self.victims = {}
end
function Character:grab_update(dt)
    local g = self.hold

    if ( self.b.horizontal:getValue() == -self.face and not self.b.attack:isDown() ) then
        self.grab_release = self.grab_release + dt
        if self.grab_release >= self.grab_release_after then
            g.target.isGrabbed = false
        end
    else
        if ( self.face == 1 and self.b.horizontal.ikp:getLast() )
            or ( self.face == -1 and self.b.horizontal.ikn:getLast() )
        then
            if g.can_grabSwap then
                self:setState(self.grabSwap)
                return
            end
        end
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
        self.y = self.y - 0.5
        g.target.y = g.target.y + 0.5
    elseif self.y < g.target.y then
        self.y = self.y + 0.5
        g.target.y = g.target.y - 0.5
    end
    --adjust both horizontally
    if self.x < g.target.x and self.x > g.target.x - 20 then
        --self.x = self.x - 1
        self.x = self.x - self.velocity_run / 2 * dt
        g.target.x = g.target.x + self.velocity_run * dt
    elseif self.x >= g.target.x and self.x < g.target.x + 20 then
        --self.x = self.x + 1
        self.x = self.x + self.velocity_run / 2 * dt
        g.target.x = g.target.x - g.target.velocity_run * dt
    end
    if self.b.attack:isDown() and self.can_jump and self.b.jump:isDown() then
        if self.b.horizontal:getValue() == self.horizontal then
            self:setState(self.dashSpecial)
        else
            self:setState(self.special)
        end
        return
    end
    if self.b.attack:isDown() and self.can_attack then
        if self.sprite.isFinished then
            if self.b.horizontal:getValue() == self.face then
                self:setState(self.shoveForward)
            elseif self.b.horizontal:getValue() == -self.face then
                self:setState(self.shoveBack)
            elseif self.b.vertical:isDown(-1) then
                self:setState(self.shoveUp)
            elseif self.face == g.target.face and g.target.type ~= "obstacle" then
                --if u grab char from behind
                self:setState(self.shoveBack)
            else
                self:setState(self.grabHit)
            end
            return
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
    self:setSprite("grabbed")
    dp(self.name.." is grabbed.")
end
function Character:grabbed_update(dt)
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
    local g = self.hold
    if self.b.vertical:isDown(1) then --press DOWN to early headbutt
        g.cool_down = 0
        self:setState(self.shoveDown)
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
    self:setSprite("grabHit")
    dp(self.name.." is grabhit someone.")
end
function Character:grabHit_update(dt)
    if self.b.jump:isDown() and self:getStateTime() < self.special_tolerance_delay then
        if self.b.horizontal:getValue() == self.horizontal then
            self:setState(self.dashSpecial)
        else
            self:setState(self.special)
        end
        return
    end
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
    self:setSprite("grabHitLast")
    dp(self.name.." is grabHitLast someone.")
end
function Character:grabHitLast_update(dt)
    if self.b.jump:isDown() and self:getStateTime() < self.special_tolerance_delay then
        if self.b.horizontal:getValue() == self.horizontal then
            self:setState(self.dashSpecial)
        else
            self:setState(self.special)
        end
        return
    end
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.grabHitLast = {name = "grabHitLast", start = Character.grabHitLast_start, exit = nop, update = Character.grabHitLast_update, draw = Character.default_draw }

function Character:shoveDown_start()
    self.isHittable = true
    self:setSprite("shoveDown")
    dp(self.name.." is shoveDown someone.")
end
function Character:shoveDown_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Character.shoveDown = {name = "shoveDown", start = Character.shoveDown_start, exit = nop, update = Character.shoveDown_update, draw = Character.default_draw}

function Character:shoveUp_start()
    self.isHittable = false
    local g = self.hold
    local t = g.target
    self:setSprite("shoveUp")
    dp(self.name.." shoveUp someone.")
end

function Character:shoveUp_update(dt)
    if self.can_shove_now then --set in the animation
        self.can_shove_now = false
        local g = self.hold
        local t = g.target
        t.isGrabbed = false
        t.isThrown = true
        t.thrower_id = self
        t.z = t.z + 1
        t.velx = self.velocity_shove_x
        t.vely = 0
        t.velz = self.velocity_shove_z
        t.victims[self] = true
        --throw up
        t.horizontal = self.horizontal
        t.velx = self.velocity_shove_x / 10
        t.velz = self.velocity_shove_z * 2
        t:setState(self.fall)
        sfx.play("sfx", "whoosh_heavy")
        sfx.play("voice"..self.id, self.sfx.throw)
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
Character.shoveUp = {name = "shoveUp", start = Character.shoveUp_start, exit = nop, update = Character.shoveUp_update, draw = Character.default_draw}

function Character:shoveForward_start()
    self.isHittable = false
    local g = self.hold
    local t = g.target
    self:setSprite("shoveForward")
    dp(self.name.." shoveForward someone.")
end

function Character:shoveForward_update(dt)
    if self.can_shove_now then --set in the animation
        self.can_shove_now = false
        local g = self.hold
        local t = g.target
        t.isGrabbed = false
        t.isThrown = true
        t.thrower_id = self
        t.z = t.z + 1
        t.velx = self.velocity_shove_x
        t.vely = 0
        t.velz = self.velocity_shove_z
        t.victims[self] = true
        t.horizontal = self.face
        t.face = self.face
        t:setState(self.fall)
        sfx.play("sfx", "whoosh_heavy")
        sfx.play("voice"..self.id, self.sfx.throw)
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
Character.shoveForward = {name = "shoveForward", start = Character.shoveForward_start, exit = nop, update = Character.shoveForward_update, draw = Character.default_draw}

function Character:shoveBack_start()
    self.isHittable = false
    local g = self.hold
    local t = g.target
    self.face = -self.face
    self:setSprite("shoveBack")
    dp(self.name.." shoveBack someone.")
end

function Character:shoveBack_update(dt)
    if self.can_shove_now then --set in the animation
        self.can_shove_now = false
        local g = self.hold
        local t = g.target
        t.isGrabbed = false
        t.isThrown = true
        t.thrower_id = self
        t.z = t.z + 1
        t.velx = self.velocity_shove_x
        t.vely = 0
        t.velz = self.velocity_shove_z
        t.victims[self] = true
        t.horizontal = self.face
        t.face = self.face
        t:setState(self.fall)
        sfx.play("sfx", "whoosh_heavy")
        sfx.play("voice"..self.id, self.sfx.throw)
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
Character.shoveBack = {name = "shoveBack", start = Character.shoveBack_start, exit = nop, update = Character.shoveBack_update, draw = Character.default_draw}

local grabSwap_frames = { 1, 2, 2, 1 }
function Character:grabSwap_start()
    self.isHittable = false
    self:setSprite("grabSwap")
    self.can_jump = false
    self.can_attack = false
    local g = self.hold
    g.cool_down = g.cool_down + 0.2
    g.can_grabSwap = false
    self.grabSwap_flipped = false
    self.grabSwap_x = self.hold.target.x + self.face * 22
    self.grabSwap_x_fin_dist = math.abs( self.x - self.grabSwap_x )
    sfx.play("sfx", "whoosh_heavy")
    dp(self.name.." is grabSwapping someone.")
end
function Character:grabSwap_update(dt)
    --dp(self.name .. " - grab update", dt)
    local g = self.hold
    --adjust both vertically
    if self.y > g.target.y + 1 then
        self.y = self.y - 0.5
        self.y = self.y - 0.5
        g.target.y = g.target.y + 0.5
    elseif self.y < g.target.y then
        self.y = self.y + 0.5
        g.target.y = g.target.y - 0.5
    end
    --adjust char horizontally
    if math.abs(self.x - self.grabSwap_x) > 2 then
        if self.x < self.grabSwap_x then
            self.x = self.x + self.velocity_run * dt
        elseif self.x >= self.grabSwap_x then
            self.x = self.x - self.velocity_run * dt
        end
        self.sprite.cur_frame = grabSwap_frames[ math.ceil((math.abs( self.x - self.grabSwap_x ) / self.grabSwap_x_fin_dist) * #grabSwap_frames ) ]
        if not self.grabSwap_flipped and math.abs(self.x - self.grabSwap_x) <= self.grabSwap_x_fin_dist / 2 then
            self.grabSwap_flipped = true
            self.face = -self.face
        end
    else
        self.horizontal = -self.horizontal
        self:setState(self.grab)
        return
    end
    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
    end
    self:calcFriction(dt)
--    self:checkCollisionAndMove(dt)
end
Character.grabSwap = {name = "grabSwap", start = Character.grabSwap_start, exit = nop, update = Character.grabSwap_update, draw = Character.default_draw}

function Character:special_start() -- Special attack plug
    self:setState(self.stand)
end
Character.special = {name = "special", start = Character.special_start, exit = nop, update = nop, draw = Character.default_draw }

return Character