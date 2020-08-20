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
function Unit:decreaseHp(damage)
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.hp = 0
        if self.func then   -- custom function on death
            self:func(self)
            self.func = nil
        end
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
                        x = self.x, y = self.y, z = self.z } )
    if sfx1 then
        self:playSfx(sfx1)
    end
end

function Unit:initDamage()
    self.isHurt = nil
end

function Unit:trackDamage(damage)

end

function Unit:getDamage(damage)

end


