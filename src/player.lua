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

	self.isHidden = false
	self.isEnabled = true

	self.draw = nop
	self.update = nop
	self.start = nop
	self.exit = nop
	
	self:setState(Player.idle)
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

function Player:idle_start()
	print (self.name.." - idle start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "idle"
end
function Player:idle_exit()
	print (self.name.." - idle exit")
end
function Player:idle_update(dt)
--	print (self.name," - idle update",dt)
	if love.keyboard.isDown("left") or
	 love.keyboard.isDown("right") or
	 love.keyboard.isDown("up") or
	 love.keyboard.isDown("down") then
		self:setState(self.walk)
	end
	UpdateInstance(self.sprite, dt)
end
function Player:idle_draw(l,t,w,h)
--	print(self.name.." - idle draw ",l,t,w,h)
	love.graphics.setColor(255, 255, 255)
	DrawInstance(self.sprite, self.x, self.y)
end
Player.idle = {name = "idle", start = Player.idle_start, exit = Player.idle_exit, update = Player.idle_update, draw = Player.idle_draw}

function Player:walk_start()
	print (self.name.." - walk start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "walk"
--	self.sprite.curr_anim = sprite_bank[self.sprite.sprite].animations_names[3]
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
			self:setState(self.idle)
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

	UpdateInstance(self.sprite, dt)
end
function Player:walk_draw(l,t,w,h)
--	print(self.name.." - walk draw ",l,t,w,h)
	love.graphics.setColor(255, 255, 255)
	DrawInstance(self.sprite, self.x, self.y)
end
Player.walk = {name = "walk", start = Player.walk_start, exit = Player.walk_exit, update = Player.walk_update, draw = Player.walk_draw}

function Player:jump_start()
	print (self.name.." - jump start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jump"
	--	self.sprite.curr_anim = sprite_bank[self.sprite.sprite].animations_names[3]
end
function Player:jump_exit()
	print (self.name.." - jump exit")
end
function Player:jump_update(dt)
	--	print (self.name.." - jump update",dt)

	--self.stepx = 0;
	self.stepy = 0;
	self.stepx = -100 * dt * sprite.flip_h;

	local actualX, actualY, cols, len = world:move(self, self.x + self.stepx, self.y + self.stepy,
		function(player, item)
			if player ~= item then
				return "slide"
			end
		end)
	self.x = actualX
	self.y = actualY

	UpdateInstance(self.sprite, dt)
end
function Player:jump_draw(l,t,w,h)
	--	print(self.name.." - jump draw ",l,t,w,h)
	love.graphics.setColor(255, 255, 255)
	DrawInstance(self.sprite, self.x, self.y)
end
Player.jump = {name = "jump", start = Player.jump_start, exit = Player.jump_exit, update = Player.jump_update, draw = Player.jump_draw}


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

Public Functions
GetInstanceID	Returns the instance id of the object.
ToString	Returns the name of the game object.

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
