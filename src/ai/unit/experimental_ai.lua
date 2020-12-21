local class = require "lib/middleclass"
local eAI = class('eAI', AI)

local _settings = {
}

function eAI:initialize(unit, settings)
    AI.initialize(self, unit, settings or _settings)
    -- new or overridden AI schedules
    -- new or overridden AI tactics lists of AI schedules
    self.tacticsPassive = {
        self.SCHEDULE_STEP_BACK, self.SCHEDULE_STEP_DOWN, self.SCHEDULE_STEP_FORWARD, self.SCHEDULE_STEP_UP,
        self.SCHEDULE_WAIT_MEDIUM,
        self.SCHEDULE_WAIT_SHORT,
        self.SCHEDULE_WAIT_LONG,
        self.SCHEDULE_WALK_TO_GRAB,
        --self.SCHEDULE_WALK_RANDOM,
        self.SCHEDULE_GET_TO_BACK,
        self.SCHEDULE_WALK_AROUND,
        self.SCHEDULE_WALK_TO_MEDIUM_DISTANCE, self.SCHEDULE_WALK_TO_LONG_DISTANCE,
        self.SCHEDULE_WALK_BY_TARGET_V,
        self.SCHEDULE_SMART_ATTACK,
    }
    self.tacticsPassive.name = "passive"
    self.tacticsAggressive = {
        self.SCHEDULE_SMART_ATTACK, self.SCHEDULE_SMART_ATTACK,
        self.SCHEDULE_WALK_BY_TARGET_V,
        self.SCHEDULE_WAIT_SHORT,
        self.SCHEDULE_ESCAPE_BACK,
        self.SCHEDULE_WALK_AROUND, self.SCHEDULE_WALK_AROUND,
    }
    self.tacticsAggressive.name = "aggressive"
    self.tacticsInDanger = {
        self.SCHEDULE_WALK_BY_TARGET_V,
        self.SCHEDULE_WALK_BY_TARGET_H,
        self.SCHEDULE_ESCAPE_BACK,
        self.SCHEDULE_WALK_AROUND,
        self.SCHEDULE_GET_TO_BACK,
    }
    self.tacticsInDanger.name = "inDanger"
    self.tacticsCowardly = { self.SCHEDULE_WALK_OFF_THE_SCREEN, self.SCHEDULE_WAIT_SHORT }
    self.tacticsCowardly.name = "cowardly"
    self.tacticsHappily = { self.SCHEDULE_FACE_TO_PLAYER, self.SCHEDULE_WAIT_SHORT, self.SCHEDULE_STRAIGHT_JUMP, self.SCHEDULE_DANCE }
    self.tacticsHappily.name = "happily"
    self.tacticsShortAttacks = { self.SCHEDULE_WALK_CLOSE_TO_ATTACK, self.SCHEDULE_COMBO }
    self.tacticsShortAttacks.name = "shortAttacks"
    self.tacticsMediumAttacks = { self.SCHEDULE_WALK_CLOSE_TO_ATTACK, self.SCHEDULE_ATTACK_FROM_BACK }
    self.tacticsMediumAttacks.name = "mediumAttacks"
    self.tacticsLongAttacks = {
        self.SCHEDULE_WALK_CLOSE_TO_ATTACK, self.SCHEDULE_ATTACK_FROM_BACK,
        --self.SCHEDULE_DASH_ATTACK, self.SCHEDULE_RUN_DASH_ATTACK,
    }
    self.tacticsLongAttacks.name = "longAttacks"
    self.tactics = self.tacticsPassive
end

function eAI:selectNewAttackSchedule()
    print(self.unit.name, "selectNewAttackSchedule()")
    self.unit.b.reset()
    if self.conditions.reactShortPlayer then
        self.tactics = self.tacticsShortAttacks
    elseif self.conditions.reactMediumPlayer then
        self.tactics = self.tacticsMediumAttacks
    elseif self.conditions.reactLongPlayer then
        self.tactics = self.tacticsLongAttacks
    else
        self.unit.b.reset()
        print(self.unit.name, "CANNOT PICK BEST ATTACK")
        self.tactics = false
        return true
    end
    self:setSchedule( self.tactics[ love.math.random(1, #self.tactics ) ])
    self.tactics = false
    return true
end

function eAI:old_selectNewSchedule(conditions)
    print(self.unit.name, "selectNewSchedule")
    if self.conditions.tooCloseToPlayer then
        print(self.unit.name, "IN DANGEROUS POS. AVOID")
        self.tactics = self.tacticsInDanger
        self:setSchedule( self.tactics[ love.math.random(1, #self.tactics ) ])
        self.tactics = self.tacticsAggressive
        return true
    else
        if self.tactics == self.tacticsPassive and self.unit.hp < self.unit.maxHp then
            self.tactics = self.tacticsAggressive
            --elseif self.tactics == self.tacticsAggressive and self.unit.hp < self.unit.maxHp / 3 then
            --    self.tactics = self.tacticsCowardly
        elseif not self.tactics then
            self.tactics = self.tacticsPassive
        end
    end
    self:setSchedule( self.tactics[ love.math.random(1, #self.tactics ) ])
end

function eAI:selectNewSchedule(conditions)
    print(self.unit.name, "selectNewSchedule")
    if love.math.random() < 0.5 then
        self:setSchedule( self.SCHEDULE_KEEP_DISTANCE_PLAYER )
    else
        self:setSchedule( self.SCHEDULE_WAIT_SHORT )
    end
end

return eAI
