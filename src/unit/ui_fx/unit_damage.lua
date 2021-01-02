local Unit = Unit

function Unit:getMaxHp( )
    return self.maxHp
end
function Unit:addHp(hp)
    local maxHp = self:getMaxHp()
    self.hp = self.hp + hp
    if self.hp > maxHp then
        self.hp = maxHp
    end
end
function Unit:callFuncOnDeath()
    if self.func and self.minPlayerCount <= countAlivePlayers(true) then   -- custom function on death (item drop, etc)
        self:func(self)
        self.func = nil
    end
end
function Unit:decreaseHp(damage)
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.hp = 0
        self:callFuncOnDeath()
    end
end
function Unit:isFriendlyAttack(target)
    if self.canFriendlyAttack and target.canFriendlyAttack then
        return true
    end
    return false
end
function Unit:onFriendlyAttack()
    local h = self:getDamageContext()
    if not h then
        return
    end
    if self:isFriendlyAttack(h.source) and self.state ~= "fall" then
        h.damage = math.floor( (h.damage or 0) / self.friendlyDamage )
    else
        h.damage = h.damage or 0
    end
end
function Unit:applyDamage(damage, type, source, repel_x, sfx1)
    self:trackDamage ( {source = source or self, state = self.state, damage = damage,
                        type = type, repel_x = repel_x or 0,
                        horizontal = self.face,
                        attackHash = self:createProjectileAttackHash(source or self),
                        x = self.x, y = self.y, z = self.z } )
    if sfx1 then
        self:playSfx(sfx1)
    end
end

function Unit:createAttackHash(attackId)
    if attackId then
        return "H" .. self.id .. self.sprite.curAnim .. "A" .. attackId .. "_" .. self.globalAttackN
    end
    return "H" .. self.id .. self.sprite.curAnim .. "_" .. self.sprite.curFrame .. "_" .. self.globalAttackN
end

function Unit:createProjectileAttackHash(source)
    if source then
        --print("PROJECTILE HASH for", source.name, "H" .. source.id .. "projectile" .. source.globalAttackN)
        return "H" .. source.id .. "projectile" .. source.globalAttackN
    end
    --print("PROJECTILE HASH for", self.name, "H" .. self.id .. "projectile" .. self.globalAttackN)
    return "H" .. self.id .. "projectile" .. self.globalAttackN
end

function Unit:initDamageContext()
    self.isHurt = nil
end

function Unit:trackDamage(damageContext)
    if self.isHurt then
        print("RESOLVE Stacked damage!")
        if damageContext.type ~= "hit" and damageContext.type ~= "simple" then
            print("  REPLACE ", self.isHurt.source.name, self.isHurt.type,"with", damageContext.type, "(", damageContext.source.name, ") +++ DMG", damageContext.damage)
            damageContext.damage = self.isHurt.damage + damageContext.damage
        else
            print("  +++ DMG", damageContext.damage,  self.isHurt.type, self.isHurt.source.name, "(", damageContext.source.name, ")")
            self.isHurt.damage = self.isHurt.damage + damageContext.damage
            return
        end
    end
    self.isHurt = damageContext
end

function Unit:hasAttackHash(attackHash)
    if attackHash and self.hashedAttacks[attackHash] then
        return true
    end
    return false
end

function Unit:storeAttackHash(attackHash)
    if attackHash then
        self.hashedAttacks[attackHash] = true
    end
end

function Unit:getDamageContext()
    return self.isHurt
end

