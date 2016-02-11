--    compoPic.lua
--    Copyright Don Miguel, 2016
--	draws a big picture that consists of many pieces

local class = require "lib/middleclass"

--local cp = {}

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
--	print(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
	x2 < x1+w1 and
	y1 < y2+h2 and
	y2 < y1+h1
end

BigPic = class('BigPic') 

function BigPic:initialize(name)
	self.name = name
	self.pics = {}
	print(name.." bp created")
end

function BigPic:add(rect, color)
	table.insert(self.pics, {x = rect.x, y = rect.y, w = rect.w, h = rect.h, color = color})
	print('rect '..self.pics[#self.pics].x ..' '..self.pics[#self.pics].y ..' '..self.pics[#self.pics].w ..' '..self.pics[#self.pics].h ..' added to '..self.name)
end

function BigPic:remove(rect, color)
--TODO add check fr w h color
	for i=1, #self.pics do 
		if self.pics[i][1].x == rect.x and 
		self.pics[i][1].y == rect.x
		then
			table.remove (self.pics, i)
		end
	end
end

function BigPic:getRect(i)
	return self.pics[i].x, self.pics[i].y, self.pics[i].w, self.pics[i].h
end

function BigPic:drawAll()
	love.graphics.setColor(200, 130, 0)
	for i=1, #self.pics do 
		love.graphics.rectangle("line", self:getRect(i) )
	end
end

function BigPic:draw(l,t,w,h)
	love.graphics.setColor(0,200, 130)
	for i=1, #self.pics do
--		print( CheckCollision( l,t,w,h, self:getRect(i) ) )
		if CheckCollision( l,t,w,h, self:getRect(i) ) then
			love.graphics.rectangle("fill", self:getRect(i) )
			--print('ok, i draw ',self:getRect(i))
		end
	end
end

--local lemon = Lemon:new()

--local bp = BigPic:new("pic_big_1");
--local bp2 = BigPic:new("pic_big_2");
--bp:add({x=0,y=0,w=1,h=1},mil)
--bp:draw(0,0, 5, 6)
---------
--return BigPic