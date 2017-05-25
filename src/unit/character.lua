local class = require "lib/middleclass"
local class = require "lib/middleclass"
local class = require "lib/middleclass"
local Character = class('Character', Unit)

local function nop() end
local sign = sign
local clamp = clamp
local double_tap_delta = 0.25
local moves_white_list = {
    run = true, sideStep = true, pickup = true,
    jump = true, jumpAttackForward = true, jumpAttackLight = true, jumpAttackRun = true, jumpAttackStraight = true,
    grab = true, grabSwap = true, grabAttack = true,
    shoveUp = true, shoveDown = true, shoveBack = true, shoveForward = true,
    dashAttack = true, offensiveSpecial = true, defensiveSpecial = true,
    --technically present for all
    stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
}

function Character:initialize(name, sprite, input, x, y, f)
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon"
    f.shapeArgs = f.shapeArgs or { 1, 0, 13, 0, 14, 3, 13, 6, 1, 6, 0, 3 }
    self.height = self.height or 50
    Unit.initialize(self, name, sprite, input, x, y, f)
    self.type = "character"
    self.time = 0
    self.velocity_walk = 100
    self.velocity_walk_y = 50
    self.velocity_walkHold = self.velocity_walk * 0.75
    self.velocity_walkHold_y = self.velocity_walk_y * 0.75
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
    self.friendly_damage = 10 --divide friendly damage
    self.isMovable = true --can be moved by attacks / can be grabbed
    self.moves = moves_white_list --list of allowed moves
    --Inner char vars
    self.toughness = 0 --0 slow .. 5 fast, more aggressive (for enemy AI)
    self.score = 0
    self.charged_at = 1    -- define # seconds when holdAttack is ready
    self.charge = 0    -- seconds of changing
    self.n_combo = 1    -- n of the combo hit
    self.cool_down = 0  -- can't move
    self.cool_down_combo = 0    -- can cont combo
    self.cool_down_grab = 2
    self.grab_release_after = 0.25 --sec if u hold 'back'
    self.n_grabAttack = 0    -- n of the grab hits
    self.special_tolerance_delay = 0.02 -- between pressing attack & Jump
    self.player_select_mode = 0
    --Character default sfx
    self.sfx.jump = "whoosh_heavy"
    self.sfx.throw = "whoosh_heavy"
    self.sfx.dash_attack = "gopper_attack1"
    self.sfx.grab = "grab"
    self.sfx.grab_clash = "hit_weak6"
    self.sfx.jump_attack = self.sfx.jump_attack or "niko_attack1"
    self.sfx.step = self.sfx.step or "kisa_step"
    self.sfx.dead = self.sfx.dead or "gopnik_death1"
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

local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency
function Character:drawTextInfo(l, t, transp_bg, icon_width, norm_color)
    love.graphics.setColor(255, 255, 255, transp_bg)
    printWithShadow(self.name, l + self.shake.x + icon_width + 2, t + 9,
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
    self.time = self.time + dt
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

function Character:onFriendlyAttack()
    local h = self.hurt
    if not h then
        return
    end
    if self.type == h.source.type and not h.isThrown then
        --friendly attack is lower by default
        h.damage = math.floor( (h.damage or 0) / self.friendly_damage )
    else
        h.damage = h.damage or 0
    end
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
    self:remove_tween_move()
    self:onFriendlyAttack()
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

function Character:checkStuckButtons()
    if not self.b.jump:isDown() then
        self.can_jump = true
    else
        self.can_jump = false
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
    else
        self.can_attack = false
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
                    and not o.isGrabbed
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

function Character:slide_start()
    self.isHittable = false
end
function Character:slide_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true)
end
Character.slide = {name = "slide", start = Character.slide_start, exit = nop, update = Character.slide_update, draw = Character.default_draw}

function Character:stand_start()
    self.isHittable = true
    self.z = 0 --TODO add fall if z > 0
    if self.sprite.cur_anim == "walk" or self.sprite.cur_anim == "walkHold" then
        self.delay_animation_cool_down = 0.12
    else
        if not self.sprite.cur_anim then
            self:setSprite("stand")
        end
        self.delay_animation_cool_down = 0.06
    end
    self:remove_tween_move()
    self.victims = {}
    self.n_grabAttack = 0
end
function Character:stand_update(dt)
    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
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
    if (self.moves.jump and self.can_jump and self.b.jump:isDown())
        or ((self.moves.offensiveSpecial or self.moves.defensiveSpecial)
            and (self.can_jump or self.can_attack) and
            (self.b.jump:isDown() and self.b.attack:isDown()))
    then
        self:setState(self.duck2jump)
        return
    elseif self.can_attack and self.b.attack:pressed() then
        if self.moves.pickup and self:checkForLoot(9, 9) ~= nil then
            self:setState(self.pickup)
            return
        end
        self:setState(self.combo)
        return
    end
    
    if self.cool_down <= 0 then
        --can move
        if self.b.horizontal:getValue() ~=0 then
            if self.moves.run and self:getPrevStateTime() < double_tap_delta and self.last_face == self.b.horizontal:getValue()
                    and (self.last_state == "walk" or self.last_state == "run" )
            then
                self:setState(self.run)
            else
                self:setState(self.walk)
            end
            return
        end
        if self.b.vertical:getValue() ~= 0 then
            if self.moves.sideStep and self:getPrevStateTime() < double_tap_delta and self.last_vertical == self.b.vertical:getValue()
                    and (self.last_state == "walk" )
            then
                self.vertical = self.b.vertical:getValue()
                _, self.vely = self:getMovementSpeed()
                self:setState(self.sideStep)
            else
                self:setState(self.walk)
            end
            return
        end
    else
        self.cool_down = self.cool_down - dt    --when <=0 u can move
        --you can flip while you cannot move
        if self.b.horizontal:getValue() ~= 0 then
            self.face = self.b.horizontal:getValue()
            self.horizontal = self.face
        end
    end
    self:calcMovement(dt, true)
end
Character.stand = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw}

function Character:walk_start()
    self.isHittable = true
    if self.sprite.cur_anim == "standHold"
        or ( self.sprite.cur_anim == "duck" and self.b.attack:isDown() )
        then
        self:setSprite("walkHold")
    else
        self:setSprite("walk")
    end
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
        if self.moves.pickup and self:checkForLoot(9, 9) ~= nil then
            self:setState(self.pickup)
            return
        elseif self.moves.combo then
            self:setState(self.combo)
            return
        end
    elseif self.moves.jump and self.b.jump:isDown() and self.can_jump then
        self:setState(self.duck2jump)
        return
    end
    self.velx = 0
    self.vely = 0
    if self.b.horizontal:isDown(-1) then
        self.face = -1 --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx, _ = self:getMovementSpeed()
    elseif self.b.horizontal:isDown(1) then
        self.face = 1 --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx, _ = self:getMovementSpeed()
    end
    if self.b.vertical:getValue() ~= 0 then
        self.vertical = self.b.vertical:getValue()
        _, self.vely = self:getMovementSpeed()
    end
    if self.b.attack:isDown() then
        local grabbed = self:checkForGrab(6)
        if grabbed then
            if grabbed.face == -self.face and grabbed.sprite.cur_anim == "walkHold"
            then
                --back off 2 simultaneous grabbers
                if self.x < grabbed.x then
                    self.horizontal = -1
                else
                    self.horizontal = 1
                end
                grabbed.horizontal = -self.horizontal
                self:showHitMarks(22, 40, 5) --big hitmark
                self.velx = self.velocity_back_off --move from source
                self.cool_down = 0.0
                self:setSprite("hurtHigh")
                self:setState(self.slide)
                grabbed.velx = grabbed.velocity_back_off --move from source
                grabbed.cool_down = 0.0
                grabbed:setSprite("hurtHigh")
                grabbed:setState(grabbed.slide)
                sfx.play("sfx"..self.id, self.sfx.grab_clash)
                return
            end
            if self.moves.grab and self:doGrab(grabbed) then
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
    self:calcMovement(dt, false)
end
Character.walk = {name = "walk", start = Character.walk_start, exit = nop, update = Character.walk_update, draw = Character.default_draw}

function Character:run_start()
    self.isHittable = true
    self.delay_animation_cool_down = 0.01
    --can_jump & self.can_attack are set in the prev state
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
        if self.moves.offensiveSpecial and self.b.attack:isDown() then
            self:setState(self.offensiveSpecial)
            return
        elseif self.moves.jump or self.moves.offensiveSpecial or self.moves.defensiveSpecial then
            self:setState(self.duck2jump, true) --pass condition to block dir changing
            return
        end
    elseif self.b.attack:isDown() and self.can_attack then
        if self.moves.offensiveSpecial and self.b.jump:isDown() then
            self:setState(self.offensiveSpecial)
            return
        elseif self.moves.dashAttack then
            self:setState(self.dashAttack)
            return
        end
    end
    self:calcMovement(dt, false)
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
    if self.b.attack:isDown() then
        if self.moves.jumpAttackLight and self.b.horizontal:getValue() == -self.face then
            self:setState(self.jumpAttackLight)
            return
        elseif self.moves.jumpAttackStraight and self.velx == 0 then
            self:setState(self.jumpAttackStraight)
            return
        else
            if self.moves.jumpAttackRun and self.velx >= self.velocity_run then
                self:setState(self.jumpAttackRun)
                return
            elseif self.moves.jumpAttackStraight and self.horizontal ~= self.face then
                self:setState(self.jumpAttackStraight)
                return
            elseif  self.moves.jumpAttackForward then
                self:setState(self.jumpAttackForward)
                return
            end
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
    self:calcMovement(dt, false)
end
Character.jump = {name = "jump", start = Character.jump_start, exit = nop, update = Character.jump_update, draw = Character.default_draw}

function Character:pickup_start()
    self.isHittable = false
    local loot = self:checkForLoot(9, 9)
    if loot then
        self.victim_infoBar = loot.infoBar:setPicker(self)
        --disappearing loot
        local particles = PA_LOOT_GET:clone()
        particles:setQuads( loot.q )
        particles:setOffset( loot.ox, loot.oy )
        particles:setPosition( loot.x - self.x, loot.y - self.y - 10 )
        particles:emit(1)
        stage.objects:add(Effect:new(particles, self.x, self.y + 10))
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
    self:calcMovement(dt, true)
end
Character.pickup = {name = "pickup", start = Character.pickup_start, exit = nop, update = Character.pickup_update, draw = Character.default_draw}

function Character:duck_start()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("duck")
    self.z = 0
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
function Character:duck_update(dt)
    if self.sprite.isFinished then
        if self.b.horizontal:getValue() ~= 0 then
            self:setState(self.walk)
        else
            self.velx = 0
            self.vely = 0
            self:setState(self.stand)
        end
        return
    end
    self:calcMovement(dt, false, nil, true)
end
Character.duck = {name = "duck", start = Character.duck_start, exit = nop, update = Character.duck_update, draw = Character.default_draw}

function Character:duck2jump_start()
    self.isHittable = true
    self:setSprite("duck")
    self.z = 0
end
function Character:duck2jump_update(dt)
    if self:getLastStateTime() < self.special_tolerance_delay then
        --time for other move
        if self.b.attack:isDown() then
            if self.moves.offensiveSpecial and self.velx ~= 0 or self.b.horizontal:getValue() ~=0 then
                self.face = self.b.horizontal:getValue()
                self:setState(self.offensiveSpecial)
                return
            elseif self.moves.defensiveSpecial then
                self:setState(self.defensiveSpecial)
                return
            end
        end
    end
    if self.sprite.isFinished then
        if self.moves.jump then
            self:setState(self.jump)
        else
            error("Call disabled move self.jump")
        end
        --start jump dust clouds
        local particles = PA_DUST_JUMP_START:clone()
        particles:setAreaSpread( "uniform", 16, 4 )
        particles:setLinearAcceleration(-30 , 10, 30, -10)
        particles:emit(6)
        particles:setAreaSpread( "uniform", 4, 16 )
        particles:setPosition( 0, -16 )
        particles:setLinearAcceleration(sign(self.face) * (self.velx + 200) , -50, sign(self.face) * (self.velx + 400), -700) -- Random movement in all directions.
        particles:emit(5)
        stage.objects:add(Effect:new(particles, self.x, self.y-1))
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
    self:calcMovement(dt, false, nil, true)
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
        self.cool_down = 0.1
        if self.isGrabbed then
            self:setState(self.grabbed)
        else
            self:setState(self.stand)
        end
        return
    end
    self:calcMovement(dt, true, nil)
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
        self.cool_down = 0.1
        if self.isGrabbed then
            self:setState(self.grabbed)
        else
            self:setState(self.stand)
        end
        return
    end
    self:calcMovement(dt, true, nil)
end
Character.hurtLow = {name = "hurtLow", start = Character.hurtLow_start, exit = nop, update = Character.hurtHigh_update, draw = Character.default_draw}

function Character:sideStep_start()
    self.isHittable = true
    if self.vertical > 0 then
        self:setSprite("sideStepDown")
    else
        self:setSprite("sideStepUp")
    end
    self.velx, self.vely = 0, self.velocity_step_down
    sfx.play("sfx"..self.id, "whoosh_heavy")
end
function Character:sideStep_update(dt)
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
    self:calcMovement(dt, false, nil)
end
Character.sideStep = {name = "sideStep", start = Character.sideStep_start, exit = nop, update = Character.sideStep_update, draw = Character.default_draw}

function Character:dashAttack_start()
    self.isHittable = true
    self:setSprite("dashAttack")
    self.velx = self.velocity_dash
    self.vely = 0
    self.velz = 0
    sfx.play("voice"..self.id, self.sfx.dash_attack)
end
function Character:dashAttack_update(dt)
    if self.moves.defensiveSpecial and self.b.jump:isDown() and self:getLastStateTime() < self.special_tolerance_delay then
        self:setState(self.defensiveSpecial)
        return
    end
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, self.friction_dash)
end
Character.dashAttack = {name = "dashAttack", start = Character.dashAttack_start, exit = nop, update = Character.dashAttack_update, draw = Character.default_draw}

function Character:offensiveSpecial_start()
    --no move by default
    self:setState(self.stand)
end
Character.offensiveSpecial = {name = "offensiveSpecial", start = Character.offensiveSpecial_start, exit = nop, update = nop, draw = Character.default_draw }

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
    self:calcMovement(dt, false)
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
    self:calcMovement(dt, false)
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
    self:calcMovement(dt, false)
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
    self:calcMovement(dt, false)
end
Character.jumpAttackRun = {name = "jumpAttackRun", start = Character.jumpAttackRun_start, exit = nop, update = Character.jumpAttackRun_update, draw = Character.default_draw}

function Character:fall_start()
    self:remove_tween_move()
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
                local particles = PA_DUST_FALLING:clone()
                particles:emit(PA_DUST_FALLING_N_PARTICLES)
                stage.objects:add(Effect:new(particles,
                    self.type == "obstacle" and self.x or (self.x + self.horizontal * 20),
                    self.y+3))
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
    self:calcMovement(dt, false) --TODO ?
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
    self:calcMovement(dt, true)
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
        if self.shape then
            stage.world:remove(self.shape)  --stage.world = global collision shapes pool
            self.shape = nil
        end
        --self.y = GLOBAL_SETTING.OFFSCREEN
        return
    else
        self.cool_down_death = self.cool_down_death - dt
    end
    self:calcMovement(dt, true)
end
Character.dead = {name = "dead", start = Character.dead_start, exit = nop, update = Character.dead_update, draw = Character.default_draw}

function Character:combo_start()
    self.isHittable = true
    self.horizontal = self.face
    self:remove_tween_move()
    if self.n_combo > self.sprite.def.max_combo or self.n_combo < 1 then
        self.n_combo = 1
    end
    self:setSprite("combo"..self.n_combo)
    self.cool_down = 0.2
end
function Character:combo_update(dt, custom_friction)
    if self.b.jump:isDown() and self:getLastStateTime() < self.special_tolerance_delay then
        if self.moves.offensiveSpecial and self.b.horizontal:getValue() == self.horizontal then
            self:setState(self.offensiveSpecial)
            return
        elseif self.moves.defensiveSpecial then
            self:setState(self.defensiveSpecial)
            return
        end
    end
    if self.moves.dashAttack and (self.b.horizontal.ikp:getLast() or self.b.horizontal.ikn:getLast()) then
        --dashAttack from combo
        if self.b.horizontal:getValue() == self.horizontal then
            self:setState(self.dashAttack)
            return
        end
    end
    if self.sprite.isFinished then
        if self.n_combo < self.sprite.def.max_combo then
            self.n_combo = self.n_combo + 1
        else
            self.n_combo = 1
        end
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, custom_friction)
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
                and not o.isDisabled
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

function Character:doGrab(target)
    dp(target.name .. " is grabed by me - "..self.name)
    local g = self.hold
    local g_target = target.hold
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
    if not target.isHittable or target.z > 0 then
        return false
    end
    --the grabbed
    target:release_grabbed()	-- your grab targed releases one it grabs
    g_target.source = self
    g_target.target = nil
    g_target.cool_down = self.cool_down_grab
    target.isGrabbed = true
    sfx.play("voice"..target.id, target.sfx.grab)   --clothes ruffling
    -- the grabber
    g.source = nil
    g.target = target
    g.cool_down = self.cool_down_grab + 0.1
    g.can_grabSwap = true   --can do 1 grabSwap

    self:setState(self.grab)
    target:setState(target.grabbed)
    return true
end

local check_x_dist = 18
function Character:grab_start()
    self.isHittable = true
    self:setSprite("grab")
    self.grab_release = 0
    self.victims = {}
    if not self.condition then
        local g = self.hold
        local time_to_move = 0.1
        local to_common_y = math.floor((self.y + g.target.y) / 2 )
        local direction = self.x >= g.target.x and -1 or 1
        local check_forth = self:hasPlaceToStand(self.x + direction * check_x_dist, self.y)
        local check_back = self:hasPlaceToStand(self.x - direction * check_x_dist, self.y)
        local x1, x2
        if check_forth then
            x1 = self.x - direction * 4
            x2 = self.x + direction * check_x_dist
        elseif check_back then
            x1 = g.target.x - direction * (check_x_dist + 4)
            x2 = g.target.x
            time_to_move = 0.15
        else
            x1 = self.x - direction * 4
            x2 = self.x + direction * 4
        end
        self.velx = 0
        g.target.velx = 0
        self.vely = 0
        g.target.vely = 0
        self.move = tween.new(time_to_move, self, {
            x = x1,
            y = to_common_y + 0.5
        }, 'outQuad')
        g.target.move = tween.new(time_to_move, g.target, {
            x = x2,
            y = to_common_y - 0.5
        }, 'outQuad')
        self.face = direction
        self.horizontal = self.face
        g.target.horizontal = -self.face
    end
end
function Character:grab_update(dt)
    local g = self.hold
    if g and g.target then
        --controlled release
        if ( self.b.horizontal:getValue() == -self.face and not self.b.attack:isDown() ) then
            self.grab_release = self.grab_release + dt
            if self.grab_release >= self.grab_release_after then
                g.target.isGrabbed = false
            end
        else
            if ( self.face == 1 and self.b.horizontal.ikp:getLast() )
                    or ( self.face == -1 and self.b.horizontal.ikn:getLast() )
            then
                if self.moves.grabSwap and g.can_grabSwap
                    and self:hasPlaceToStand(self.hold.target.x + self.face * 18, self.y)
                then
                    self:setState(self.grabSwap)
                    return
                end
            end
            self.grab_release = 0
        end
        --auto release after time
        if g.cool_down > 0 and g.target.isGrabbed then
            g.cool_down = g.cool_down - dt
        else
            if g.target.x > self.x then --adjust players backoff
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
        --special attacks
        if self.b.attack:isDown() and self.can_jump and self.b.jump:isDown() then
            if self.moves.offensiveSpecial and self.b.horizontal:getValue() == self.horizontal then
                self:release_grabbed()
                self:setState(self.offensiveSpecial)
                return
            elseif self.moves.defensiveSpecial then
                self:release_grabbed()
                self:setState(self.defensiveSpecial)
                return
            end
        end
        --normal attacks
        if self.b.attack:isDown() and self.can_attack then
            --if self.sprite.isFinished then
            if self.moves.shoveForward and self.b.horizontal:getValue() == self.face then
                g.target:remove_tween_move()
                self:remove_tween_move()
                self:setState(self.shoveForward)
            elseif self.moves.shoveBack and self.b.horizontal:getValue() == -self.face then
                g.target:remove_tween_move()
                self:remove_tween_move()
                self:setState(self.shoveBack)
            elseif self.moves.shoveUp and self.b.vertical:isDown(-1) then
                g.target:remove_tween_move()
                self:remove_tween_move()
                self:setState(self.shoveUp)
            elseif self.moves.shoveBack and self.face == g.target.face and g.target.type ~= "obstacle" then
                --if u grab char from behind
                g.target:remove_tween_move()
                self:remove_tween_move()
                self:setState(self.shoveBack)
            elseif self.moves.grabAttack then
                g.target:remove_tween_move()
                self:remove_tween_move()
                self:setState(self.grabAttack)
            end
            return
            --end
        end
    else
        -- release (when not grabbing anything)
        self.cool_down = 0.0
        self:release_grabbed()
        self:setState(self.stand)
    end

    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
    end
    --self:calcMovement(dt, true)
    self:tweenMove(dt)
end
Character.grab = {name = "grab", start = Character.grab_start, exit = nop, update = Character.grab_update, draw = Character.default_draw}

function Character:release_grabbed()
    local g = self.hold
    if g and g.target and g.target.isGrabbed then
        g.target.isGrabbed = false
        g.target.cool_down = 0.1
        g.target:remove_tween_move()
        self:remove_tween_move()
        self.hold = {source = nil, target = nil, cool_down = 0 }	--release a grabbed person
        return true
    end
    return false
end

function Character:grabbed_start()
    local g = self.hold
    if g.source.face ~= self.face then
        self:setState(self.grabbedFront)
    else
        self:setState(self.grabbedBack)
    end
end
Character.grabbed = {name = "grabbed", start = Character.grabbed_start, exit = nop, update = nop, draw = Character.default_draw}

function Character:grabbedFront_start()
    self.isHittable = true
    self:setSprite("grabbedFront")

    dp(self.name.." is grabbedFront.")
end
function Character:grabbedFront_update(dt)
    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
    end
    local g = self.hold
    if self.isGrabbed and g.cool_down > 0 then
        g.cool_down = g.cool_down - dt
        if self.moves.defensiveSpecial
            and self.can_attack and self.b.attack:isDown()
            and self.can_jump and self.b.jump:isDown()
        then
            self:setState(self.defensiveSpecial)
            return
        end
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
    --self:calcMovement(dt, true)
    self:tweenMove(dt)
end
Character.grabbedFront = {name = "grabbedFront", start = Character.grabbedFront_start, exit = nop, update = Character.grabbedFront_update, draw = Character.default_draw}

function Character:grabbedBack_start()
    self.isHittable = true
    self:setSprite("grabbedBack")

    dp(self.name.." is grabbedBack.")
end
function Character:grabbedBack_update(dt)
    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.attack:isDown() then
        self.can_attack = true
    end
    local g = self.hold
    if self.isGrabbed and g.cool_down > 0 then
        g.cool_down = g.cool_down - dt
        if self.moves.defensiveSpecial
                and self.can_attack and self.b.attack:isDown()
                and self.can_jump and self.b.jump:isDown()
        then
            self:setState(self.defensiveSpecial)
            return
        end
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
    --self:calcMovement(dt, true)
    self:tweenMove(dt)
end
Character.grabbedBack = {name = "grabbedBack", start = Character.grabbedBack_start, exit = nop, update = Character.grabbedBack_update, draw = Character.default_draw}

function Character:grabAttack_start()
    self.isHittable = true
    local g = self.hold
    if self.moves.shoveDown and self.b.vertical:isDown(1) then --press DOWN to early headbutt
        g.cool_down = 0
        self:setState(self.shoveDown)
        return
    else
        g.cool_down = self.cool_down_grab + 0.1
        g.target.hold.cool_down = self.cool_down_grab
    end
    self.n_grabAttack = self.n_grabAttack + 1
    self:setSprite("grabAttack"..self.n_grabAttack)
    dp(self.name.." is grabAttack someone.")
end
function Character:grabAttack_update(dt)
    if self.b.jump:isDown() and self:getLastStateTime() < self.special_tolerance_delay then
        if self.moves.offensiveSpecial and self.b.horizontal:getValue() == self.horizontal then
            self:setState(self.offensiveSpecial)
            return
        elseif self.moves.defensiveSpecial then
            self:setState(self.defensiveSpecial)
            return
        end
    end
    if self.sprite.isFinished then
        local g = self.hold
        if self.n_grabAttack < self.sprite.def.max_grabAttack
            and g and g.target and g.target.hp > 0 then
            self:setState(self.grab, true) --do not adjust positions of pl
        else
            --it is the last grabAttack or killed the target
            self:setState(self.stand)
        end
        return
    end
    --self:calcMovement(dt, true)
    self:tweenMove(dt)
end
Character.grabAttack = {name = "grabAttack", start = Character.grabAttack_start, exit = nop, update = Character.grabAttack_update, draw = Character.default_draw}

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
    self:calcMovement(dt, true)
end
Character.shoveDown = {name = "shoveDown", start = Character.shoveDown_start, exit = nop, update = Character.shoveDown_update, draw = Character.default_draw}

function Character:shoveUp_start()
    self.isHittable = false
    local g = self.hold
    local t = g.target
    t.isHittable = false    --protect grabbed enemy from hits
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
    self:calcMovement(dt, true)
end
Character.shoveUp = {name = "shoveUp", start = Character.shoveUp_start, exit = nop, update = Character.shoveUp_update, draw = Character.default_draw}

function Character:shoveForward_start()
    self.isHittable = false
    local g = self.hold
    local t = g.target
    t.isHittable = false    --protect grabbed enemy from hits
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
        t.velx = self.velocity_shove_x * self.velocity_shove_horizontal
        t.vely = 0
        t.velz = self.velocity_shove_z * self.velocity_shove_horizontal
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
    self:calcMovement(dt, true)
end
Character.shoveForward = {name = "shoveForward", start = Character.shoveForward_start, exit = nop, update = Character.shoveForward_update, draw = Character.default_draw}

function Character:shoveBack_start()
    self.isHittable = false
    local g = self.hold
    local t = g.target
    t.isHittable = false    --protect grabbed enemy from hits
    self.face = -self.face
    self.horizontal = self.face
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
        t.velx = self.velocity_shove_x * self.velocity_shove_horizontal
        t.vely = 0
        t.velz = self.velocity_shove_z * self.velocity_shove_horizontal
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
    self:calcMovement(dt, true)
end
Character.shoveBack = {name = "shoveBack", start = Character.shoveBack_start, exit = nop, update = Character.shoveBack_update, draw = Character.default_draw}

local grabSwap_frames = { 1, 2, 2, 1 }
function Character:grabSwap_start()
    self.isHittable = false
    self:setSprite("grabSwap")
    local g = self.hold
    g.cool_down = g.cool_down + 0.2
    g.can_grabSwap = false
    self.grabSwap_flipped = false
    self.grabSwap_x = self.hold.target.x + self.face * 18
    self.grabSwap_x_fin_dist = math.abs( self.x - self.grabSwap_x )
    sfx.play("sfx", "whoosh_heavy")
    dp(self.name.." is grabSwapping someone.")
end
function Character:grabSwap_update(dt)
    --dp(self.name .. " - grab update", dt)
    local g = self.hold
    --adjust both vertically
--[[
    if self.y > g.target.y + 1 then
        self.y = self.y - 0.5
        self.y = self.y - 0.5
        g.target.y = g.target.y + 0.5
    elseif self.y < g.target.y then
        self.y = self.y + 0.5
        g.target.y = g.target.y - 0.5
    end
]]
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
            g.target:setSprite(g.target.sprite.cur_anim == "grabbedFront" and "grabbedBack" or "grabbedFront")
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
    self.shape:moveTo(self.x, self.y)
    if self:isStuck() then
        self:release_grabbed()
        self.cool_down = 0.1	--cannot walk etc
        --self.velx = self.velocity_back_off2 --move from source
        self:setState(self.stand)
        return
    end
end
Character.grabSwap = {name = "grabSwap", start = Character.grabSwap_start, exit = nop, update = Character.grabSwap_update, draw = Character.default_draw}

--function Character:defensiveSpecial_start() -- Special attack plug
--    self:setState(self.stand)
--end
--Character.defensiveSpecial = {name = "defensiveSpecial", start = Character.defensiveSpecial_start, exit = nop, update = nop, draw = Character.default_draw }

return Character