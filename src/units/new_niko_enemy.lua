local class = require "lib/middleclass"

local Niko = class('Niko', Gopper)

local function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
            x2 < x1 + w1 and
            y1 < y2 + h2 and
            y2 < y1 + h1
end
local function dist(x1, y1, x2, y2) return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5 end
local function rand1()
    if love.math.random() < 0.5 then
        return -1
    else
        return 1
    end
end
local function nop() --[[print "nop"]] end
local function sign(x)
    return x>0 and 1 or x<0 and -1 or 0
end

local function nop() --[[print "nop"]] end

function Niko:initialize(name, sprite, input, x, y, shader, color)
    self.tx, self.ty = x, y
    Gopper.initialize(self, name, sprite, input, x, y, shader, color)
    self.whichPlayerAttack = "weak" -- random far close weak healthy fast slow
    self:setState(self.intro)
end

function Niko:checkCollisionAndMove(dt)
    local stepx = self.velx * dt * self.horizontal
    local stepy = self.vely * dt * self.vertical
    local actualX, actualY, cols, len, x, y
    if self.state == "fall"
            or self.state == "jump" then
        --    if self.move then
        x = self.x
        y = self.y
    else
        x = self.tx
        y = self.ty
    end
    actualX, actualY, cols, len = stage.world:move(self, x + stepx - 8, y + stepy - 4,
        function(subj, obj)
            if subj ~= obj and obj.type == "wall" then
                return "slide"
            end
        end)
    self.x = actualX + 8
    self.y = actualY + 4
end

function Niko:updateAI(dt)
    Enemy.updateAI(self, dt)

    self.cool_down = self.cool_down - dt --when <=0 u can move

    --local complete_movement = self.move:update(dt)
    --    print("Gopper updateAI "..self.type.." "..self.name)
    self.ai_poll_1 = self.ai_poll_1 - dt
    self.ai_poll_2 = self.ai_poll_2 - dt
    self.ai_poll_3 = self.ai_poll_3 - dt
    if self.ai_poll_1 < 0 then
        self.ai_poll_1 = self.max_ai_poll_1 + math.random()
        --        print("ai poll 1", self.name)
        -- Intro -> Stand
        if self.state == "intro" then
            -- see near players?
            if self:getDistanceToClosestPlayer() < 100 then
                self.face = -self.target.face --face to player
                self:setState(self.stand)
            end
        elseif self.state == "stand" then
            if self.cool_down <= 0 then
                --can move
                local t = dist(self.target.x, self.target.y, self.x, self.y)
--                if t < 400 and t >= 100 and
--                        math.floor(self.y / 4) == math.floor(self.target.y / 4) then
--                    self:setState(self.run)
--                    return
--                end
                if t < 300 then
                    self:setState(self.walk)
                    return
                end
            end
        elseif self.state == "walk" then
            --self:pickAttackTarget()
            --self:setState(self.stand)
            --return
            local t = dist(self.target.x, self.target.y, self.x, self.y)
            if t < 100 and t >= 30
                    and math.floor(self.y / 4) == math.floor(self.target.y / 4) then
                self.velx = self.velocity_walk
                self:setState(self.jump)
                return
            end
            if self.cool_down <= 0 then
                if math.abs(self.x - self.target.x) <= 50
                        and math.abs(self.y - self.target.y) <= 6
                then
                    self:setState(self.combo)
                    return
                end
            end
        elseif self.state == "run" then
            --self:pickAttackTarget()
            --self:setState(self.stand)
            --return
        end
        -- Facing towards the target
        if self.z == 0
                and self.state ~= "run"
                and self.state ~= "dash"
        then
            if self.target.x < self.x then
                self.face = -1
                self.horizontal = self.face
            else
                self.face = 1
                self.horizontal = self.face
            end
        end
    end
    if self.ai_poll_2 < 0 then
        self.ai_poll_2 = self.max_ai_poll_2 + math.random()
        --        print("ai poll 2", self.name)
    end
    if self.ai_poll_3 < 0 then
        self.ai_poll_3 = self.max_ai_poll_3 + math.random()
        --        print("ai poll 3", self.name)

        if self.state == "walk" then
        elseif self.state == "run" then
        end

        self:pickAttackTarget()

        local t = dist(self.target.x, self.target.y, self.x, self.y)
        if t < 600 and self.state == "walk" then
            --set dest
        end
    end
end

-- Niko's JumpAttacks should end with Fall
Niko.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForward_start, exit = Unit.remove_tween_move, update = Character.fall_update, draw = Character.default_draw}
Niko.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraight_start, exit = Unit.remove_tween_move, update = Character.fall_update, draw = Character.default_draw}

return Niko