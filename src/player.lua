--
-- User: bmv
-- Date: 16.02.2016
-- To change this template use File | Settings | File Templates.
--

local class = require "lib/middleclass"

local Player = class("Player")

local function nop() print "nop" end

function Player:initialize(name, sprite, x, y)
	self.sprite = sprite --GetInstance("res/man_template.lua")
	self.isConnected = false
	self.name = name or "Player 1"
	self.x, self.y, self.z = x, y, 0
	self.stepx, self.stepy = 0, 0
	self.state = "nop"

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
--		print (self.name.." -> Switching from ",self.state,"to",state.name)
		self:exit()
		self.state = state.name
		self.draw = state.draw
		self.update = state.update
		self.start = state.start
		self.exit = state.exit

		self:start()
	end
end


function Player:stand_start()
	print (self.name.." - stand start")
	self.sprite.curr_frame = 1
	if not self.sprite.curr_anim then
		self.sprite.curr_anim = "stand"
	end
end
function Player:stand_exit()
	print (self.name.." - stand exit")
end
function Player:stand_update(dt)
--	print (self.name," - stand update",dt)
	if love.keyboard.isDown("left") or
	 love.keyboard.isDown("right") or
	 love.keyboard.isDown("up") or
	 love.keyboard.isDown("down") then
		self:setState(self.walk)
	else
		self.sprite.curr_anim = "stand"	-- to prevent flashing frame after duck
	end
	UpdateInstance(self.sprite, dt, self)
end
function Player:stand_draw(l,t,w,h)
--	print(self.name.." - stand draw ",l,t,w,h)
	love.graphics.setColor(255, 255, 255)
	DrawInstance(self.sprite, self.x, self.y)
end
Player.stand = {name = "stand", start = Player.stand_start, exit = Player.stand_exit, update = Player.stand_update, draw = Player.stand_draw}


function Player:walk_start()
	print (self.name.." - walk start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "walk"
	self.sprite.loop_count = 0

	--self.anim_repeated = 0
end
function Player:walk_exit()
	print (self.name.." - walk exit")
end
function Player:walk_update(dt)
--	print (self.name.." - walk update",dt)

	self.stepx = 0;
	self.stepy = 0;
	if love.keyboard.isDown("left") then
		self.stepx = -100 * dt;
	end
	if love.keyboard.isDown("right") then
		self.stepx = 100 * dt;
	end
	if love.keyboard.isDown("up") then
		self.stepy = -75 * dt;
	end
	if love.keyboard.isDown("down") then
		self.stepy = 75 * dt;
	end
	--face sprite left or right
	if self.stepx < 0 then
		self.sprite.flip_h = -1
	elseif self.stepx > 0 then
		self.sprite.flip_h = 1
	end

	if self.stepx == 0 and self.stepy == 0 then
			self:setState(self.stand)
			return
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
	love.graphics.setColor(255, 255, 255)
	DrawInstance(self.sprite, self.x, self.y)
end
Player.walk = {name = "walk", start = Player.walk_start, exit = Player.walk_exit, update = Player.walk_update, draw = Player.walk_draw}


function Player:run_start()
	print (self.name.." - run start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "run"
	self.sprite.loop_count = 0
end
function Player:run_exit()
	print (self.name.." - run exit")
end
function Player:run_update(dt)
	--	print (self.name.." - run update",dt)

	self.stepx = 0;
	self.stepy = 0;
	if love.keyboard.isDown("left") then
		self.stepx = -150 * dt;
	end
	if love.keyboard.isDown("right") then
		self.stepx = 150 * dt;
	end
	if love.keyboard.isDown("up") then
		self.stepy = -25 * dt;
	end
	if love.keyboard.isDown("down") then
		self.stepy = 25 * dt;
	end
	--face sprite left or right
	if self.stepx < 0 then
		self.sprite.flip_h = -1
	elseif self.stepx > 0 then
		self.sprite.flip_h = 1
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
	love.graphics.setColor(255, 255, 255)
	DrawInstance(self.sprite, self.x, self.y)
end
Player.run = {name = "run", start = Player.run_start, exit = Player.run_exit, update = Player.run_update, draw = Player.run_draw}


function Player:jumpUp_start()
	print (self.name.." - jumpUp start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jumpUp"

	self.stepx = 0;
	self.stepy = 0;
	self.stepz = 170;
end
function Player:jumpUp_exit()
	print (self.name.." - jumpUp exit")
end
function Player:jumpUp_update(dt)
	--	print (self.name.." - jumpUp update",dt)

	if self.sprite.curr_frame > 1 then -- should make duck before jumping
		self.stepx = 170 * dt * self.sprite.flip_h;

		if self.z < 40 then
			self.z = self.z + dt * self.stepz
		else
			self:setState(self.jumpDown)
			return
		end
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
function Player:jumpUp_draw(l,t,w,h)
	--	print(self.name.." - jumpUp draw ",l,t,w,h)
	love.graphics.setColor(255, 255, 255)
	DrawInstance(self.sprite, self.x, self.y - self.z)
end
Player.jumpUp = {name = "jumpUp", start = Player.jumpUp_start, exit = Player.jumpUp_exit, update = Player.jumpUp_update, draw = Player.jumpUp_draw}


function Player:jumpDown_start()
	print (self.name.." - jumpDown start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jumpDown"

	--self.stepx = 0;
	self.stepy = 0;
end
function Player:jumpDown_exit()
	print (self.name.." - jumpDown exit")
end
function Player:jumpDown_update(dt)
	--	print (self.name.." - jumpDown update",dt)

	if self.z > 0 then
		self.z = self.z - dt * self.stepz
	else
		self.z = 0
		self:setState(self.duck)
		return
	end
	self.stepx = 170 * dt * self.sprite.flip_h;

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
	love.graphics.setColor(255, 255, 255)
	DrawInstance(self.sprite, self.x, self.y - self.z)
end
Player.jumpDown = {name = "jumpDown", start = Player.jumpDown_start, exit = Player.jumpDown_exit, update = Player.jumpDown_update, draw = Player.jumpDown_draw}


function Player:duck_start()
	print (self.name.." - duck start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "duck"
	self.sprite.loop_count = 0

	self.z = 0;
end
function Player:duck_exit()
	print (self.name.." - duck exit")
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
	love.graphics.setColor(255, 255, 255)
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
