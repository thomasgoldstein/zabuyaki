--
-- User: bmv
-- Date: 16.02.2016
-- To change this template use File | Settings | File Templates.
--

local class = require "lib/middleclass"

local Player = class("Player")

local function nop() print "nop" end

function Player:initialize(name, sprite, x, y, color)
	self.sprite = sprite --GetInstance("res/man_template.lua")
	self.isConnected = false
	self.name = name or "Player 1"
	self.x, self.y, self.z = x, y, 0
	self.stepx, self.stepy = 0, 0
	self.velx, self.vely, self.velz, self.gravity = 0, 0, 0
	self.gravity = 450
	self.state = "nop"
	if color then
		self.color = { r = color[1], g = color[2], b = color[3], a = color[4] }
	else
		self.color = { r= 255, g = 255, b = 255, a = 255 }
	end

	self.anim_repeated = 0

	self.isHidden = false
	self.isEnabled = true

	self.draw = nop
	self.update = nop
	self.start = nop
	self.exit = nop
	
	self:setState(Player.stand)
end

function Player:setState(state)
--	print (self.name.." -> Set state try...")
	assert(type(state) == "table", "setState expects a table")
	if state and state.name ~= self.state then
--	--	print (self.name.." -> Switching from ",self.state,"to",state.name)
		self:exit()
		self.state = state.name
		self.draw = state.draw
		self.update = state.update
		self.start = state.start
		self.exit = state.exit

		self:start()
	end
end

function Player:drawShadow()
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.ellipse("fill", self.x, self.y, 18 - self.z/16, 6 - self.z/32)
end


function Player:stand_start()
--	print (self.name.." - stand start")
	self.sprite.curr_frame = 1
	self.stepx, self.stepy = 0, 0
	if not self.sprite.curr_anim then
		self.sprite.curr_anim = "stand"
	end
	self.velx = 0
end
function Player:stand_exit()
--	print (self.name.." - stand exit")
end
function Player:stand_update(dt)
--	print (self.name," - stand update",dt)
	if love.keyboard.isDown("left") or
	 love.keyboard.isDown("right") or
	 love.keyboard.isDown("up") or
	 love.keyboard.isDown("down") then
		self:setState(self.walk)
	elseif love.keyboard.isDown("space") then
		self:setState(self.jumpUp)
	else
		self.sprite.curr_anim = "stand"	-- to prevent flashing frame after duck
	end
	UpdateInstance(self.sprite, dt, self)
end
function Player:stand_draw(l,t,w,h)
--	print(self.name.." - stand draw ",l,t,w,h)
    self:drawShadow()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	DrawInstance(self.sprite, self.x, self.y - self.z)
end
Player.stand = {name = "stand", start = Player.stand_start, exit = Player.stand_exit, update = Player.stand_update, draw = Player.stand_draw}


function Player:walk_start()
--	print (self.name.." - walk start")
	self.sprite.curr_frame = 1
	self.sprite.loop_count = 0

	self.velx, self.vely = 100, 75

	if not self.sprite.curr_anim then
		self.sprite.curr_anim = "walk"
		-- to prevent flashing 1 frame transition (when u instantly enter another stite)
	end
end
function Player:walk_exit()
--	print (self.name.." - walk exit")
end
function Player:walk_update(dt)
--	print (self.name.." - walk update",dt)

	self.stepx = 0;
	self.stepy = 0;
	if love.keyboard.isDown("left") then
		self.stepx = -self.velx * dt;
		self.sprite.flip_h = -1 --face sprite left or right
	elseif love.keyboard.isDown("right") then
		self.sprite.flip_h = 1
		self.stepx = self.velx * dt;
	end
	if love.keyboard.isDown("up") then
		self.stepy = -self.vely * dt;
	elseif love.keyboard.isDown("down") then
		self.stepy = self.vely * dt;
	end
	if love.keyboard.isDown("space") then
		self:setState(self.jumpUp)
		return
	end

	if self.stepx == 0 and self.stepy == 0 then
		self:setState(self.stand)
		return
	else
		self.sprite.curr_anim = "walk"	-- to prevent flashing frame after duck and instand jump
	end
	-- switch to run - for testing
	if self.sprite.loop_count > 1 then
		self:setState(self.run)
		return
	end

	local actualX, actualY, cols, len = world:move(self, self.x + self.stepx, self.y + self.stepy,
		function(player, item)
			if player ~= item then
				return "slide"
			end
		end)
	self.x = actualX
	self.y = actualY

	UpdateInstance(self.sprite, dt, self)
end
function Player:walk_draw(l,t,w,h)
--	print(self.name.." - walk draw ",l,t,w,h)
    self:drawShadow()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    DrawInstance(self.sprite, self.x, self.y - self.z)
end
Player.walk = {name = "walk", start = Player.walk_start, exit = Player.walk_exit, update = Player.walk_update, draw = Player.walk_draw}


function Player:run_start()
--	print (self.name.." - run start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "run"
	self.sprite.loop_count = 0

	self.velx, self.vely = 150, 25
end
function Player:run_exit()
--	print (self.name.." - run exit")
end
function Player:run_update(dt)
	--	print (self.name.." - run update",dt)

	self.stepx = 0;
	self.stepy = 0;
	if love.keyboard.isDown("left") then
		self.sprite.flip_h = -1 --face sprite left or right
		self.stepx = -self.velx * dt;
	elseif love.keyboard.isDown("right") then
		self.sprite.flip_h = 1
		self.stepx = self.velx * dt;
	end
	if love.keyboard.isDown("up") then
		self.stepy = -self.vely * dt;
	elseif love.keyboard.isDown("down") then
		self.stepy = self.vely * dt;
	end

	if love.keyboard.isDown("space") then
		self:setState(self.jumpUp)
		return
	end

	if self.stepx == 0 and self.stepy == 0 then
		self:setState(self.stand)
		return
	end

	local actualX, actualY, cols, len = world:move(self, self.x + self.stepx, self.y + self.stepy,
		function(player, item)
			if player ~= item then
				return "slide"
			end
		end)
	self.x = actualX
	self.y = actualY

	UpdateInstance(self.sprite, dt, self)
end
function Player:run_draw(l,t,w,h)
	--	print(self.name.." - run draw ",l,t,w,h)
    self:drawShadow()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    DrawInstance(self.sprite, self.x, self.y - self.z)
end
Player.run = {name = "run", start = Player.run_start, exit = Player.run_exit, update = Player.run_update, draw = Player.run_draw}


function Player:jumpUp_start()
--	print (self.name.." - jumpUp start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jumpUp"
	self.velz = 170;
	if self.velx ~= 0 then
		self.velx = self.velx + 10 --make jump little faster than the walk/run speed
	end
end
function Player:jumpUp_exit()
--	print (self.name.." - jumpUp exit")
end

function Player:jumpUp_update(dt)
	--	print (self.name.." - jumpUp update",dt)
	if self.sprite.curr_frame > 1 then -- should make duck before jumping
		if self.z < 30 then
			self.z = self.z + dt * self.velz
			self.velz = self.velz - self.gravity * dt;
		else
			self:setState(self.jumpDown)
			return
		end
		self.stepx = self.velx * dt * self.sprite.flip_h;

		local actualX, actualY, cols, len = world:move(self, self.x + self.stepx, self.y + self.stepy,
			function(player, item)
				if player ~= item then
					return "slide"
				end
			end)
		self.x = actualX
		self.y = actualY
	end
	UpdateInstance(self.sprite, dt, self)
end

function Player:jumpUp_draw(l,t,w,h)
	--	print(self.name.." - jumpUp draw ",l,t,w,h)
    self:drawShadow()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    DrawInstance(self.sprite, self.x, self.y - self.z)
end
Player.jumpUp = {name = "jumpUp", start = Player.jumpUp_start, exit = Player.jumpUp_exit, update = Player.jumpUp_update, draw = Player.jumpUp_draw}


function Player:jumpDown_start()
--	print (self.name.." - jumpDown start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jumpDown"

	--self.velz = 170;
end
function Player:jumpDown_exit()
--	print (self.name.." - jumpDown exit")
end
function Player:jumpDown_update(dt)
	--	print (self.name.." - jumpDown update",dt)
	if self.z > 0 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt;
	else
		self.z = 0
		self:setState(self.duck)
		return
	end
	self.stepx = self.velx * dt * self.sprite.flip_h;


	local actualX, actualY, cols, len = world:move(self, self.x + self.stepx, self.y + self.stepy,
		function(player, item)
			if player ~= item then
				return "slide"
			end
		end)
	self.x = actualX
	self.y = actualY

	UpdateInstance(self.sprite, dt, self)
end
function Player:jumpDown_draw(l,t,w,h)
	--	print(self.name.." - jumpDown draw ",l,t,w,h)
    self:drawShadow()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    DrawInstance(self.sprite, self.x, self.y - self.z)
end
Player.jumpDown = {name = "jumpDown", start = Player.jumpDown_start, exit = Player.jumpDown_exit, update = Player.jumpDown_update, draw = Player.jumpDown_draw}


function Player:duck_start()
--	print (self.name.." - duck start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "duck"
	self.sprite.loop_count = 0

	self.z = 0;
end
function Player:duck_exit()
--	print (self.name.." - duck exit")
end
function Player:duck_update(dt)
	--	print (self.name.." - duck update",dt)
	if self.sprite.loop_count > 0 then
		self:setState(self.stand)
		return
	end
	UpdateInstance(self.sprite, dt, self)
end
function Player:duck_draw(l,t,w,h)
	--	print(self.name.." - duck draw ",l,t,w,h)
    self:drawShadow()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    DrawInstance(self.sprite, self.x, self.y - self.z)
end
Player.duck = {name = "duck", start = Player.duck_start, exit = Player.duck_exit, update = Player.duck_update, draw = Player.duck_draw}

return Player

--anim transitions
--Play sounds as states are entered or exited
--Perform certain tests (eg, ground detection) only when in appropriate states
--Activate and control special effects associated with specific states

--[[
Public Functions
OnStateMachineEnter	Called on the first Update frame when making a transition to a StateMachine. This is not called when making a transition into a StateMachine sub-state.
OnStateMachineExit	Called on the last Update frame when making a transition out of a StateMachine. This is not called when making a transition into a StateMachine sub-state.

Messages
OnStateEnter	Called on the first Update frame when a statemachine evaluate this state.
OnStateExit	Called on the last update frame when a statemachine evaluate this state.
OnStateIK	Called right after MonoBehaviour.OnAnimatorIK.
OnStateMove	Called right after MonoBehaviour.OnAnimatorMove.
OnStateUpdate	Called at each Update frame except for the first and last frame.

Inherited members
Variables
hideFlags	Should the object be hidden, saved with the scene or modifiable by the user?
name	The name of the object.

Static Functions
Destroy	Removes a gameobject, component or asset.
DestroyImmediate	Destroys the object obj immediately. You are strongly recommended to use Destroy instead.
DontDestroyOnLoad	Makes the object target not be destroyed automatically when loading a new scene.
FindObjectOfType	Returns the first active loaded object of Type type.
FindObjectsOfType	Returns a list of all active loaded objects of Type type.
Instantiate	Clones the object original and returns the clone.
CreateInstance	Creates an instance of a scriptable object.

Operators
bool	Does the object exist?
operator !=	Compares if two objects refer to a different object.
operator ==	Compares two object references to see if they refer to the same object.
Messages
OnDestroy	This function is called when the scriptable object will be destroyed.
OnDisable	This function is called when the scriptable object goes out of scope.
OnEnable	This function is called when the object is loaded.]]
