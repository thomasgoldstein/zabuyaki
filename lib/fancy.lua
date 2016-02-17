local gr = love.graphics
local mo = love.mouse
local kb = love.keyboard
fancy = {}
fancy.__index = fancy
fancy.items = {}
fancy.pressed = false
fancy.font = gr.newFont((gr.getWidth() + gr.getHeight()) / 2 / 70)
fancy.maxRows = 6
fancy.padding = fancy.font:getHeight() * 0.2
fancy.rowHeight = fancy.font:getHeight() + fancy.padding * 2
fancy.indexRowDisplacement = 1
fancy.w = gr.getWidth() / 3
fancy.h = 0
fancy.x = 8
fancy.y = gr.getHeight() - fancy.maxRows*fancy.rowHeight - 8
fancy.alpha = 140
fancy.alphaScroll = 0

function fancy.setAlpha(alpha)
	colors = {
		[1] = {255, 0, 0, alpha}, -- High priority.
		[2] = {255, 255, 0, alpha}, -- Medium.
		[3] = {41, 170, 226, alpha} -- Normal.
	}
end
fancy.setAlpha(fancy.alpha)

local function overQuad(mx, my)
	return not (
		mx < fancy.x or
		mx > fancy.x + fancy.w or
		my < fancy.y or
		my > fancy.y + fancy.h
	)
end

function fancy.getIndex(tagId)
	local index = -1
	for i = 1, #fancy.items do
		if fancy.items[i].label == tagId then index = i end
	end
	return index
end

function fancy.watch(tagId, value, priority)
	if fancy.getIndex(tagId) == -1 then
		table.insert(fancy.items, {
			label = tagId,
			value = value,
			priority = priority or 3
		})
		fancy.h = fancy.maxRows * fancy.font:getHeight()
	else
		fancy.items[fancy.getIndex(tagId)].value = value
	end
end

function fancy.draw()
	local prevFont = gr.getFont()
	gr.setFont(fancy.font)
	gr.setLineStyle("rough")
	local maxWidth = 0
	local rowStep = 0
	for i = fancy.indexRowDisplacement, fancy.indexRowDisplacement + fancy.maxRows - 1 do
		local item = fancy.items[i]
		if item then
			local t = item.label..": "..item.value
			gr.setColor(colors[item.priority])
			if fancy.pressed and mo.isDown(3) then -- Middle btn.
				fancy.x = mo.getX() - fancy.dx
				fancy.y = mo.getY() - fancy.dy
			end
			gr.rectangle("fill", fancy.x, fancy.y + rowStep, fancy.w, fancy.rowHeight)
			gr.setColor(255, 255, 255)
			if item.priority == 2 then gr.setColor(0, 0, 0) end
			gr.print(t,
				math.floor(fancy.x + fancy.padding),
				math.floor(fancy.y + rowStep + fancy.padding))
			rowStep = rowStep + fancy.rowHeight
		end
		fancy.h = rowStep
	end
	gr.setFont(prevFont)
	if #fancy.items > fancy.maxRows then
		gr.setColor(255, 255, 255, fancy.alphaScroll)
		local fancyWidth = fancy.maxRows * fancy.rowHeight
		local barHeight = (fancy.maxRows / #fancy.items) * fancyWidth
		local barWidth = 7
		if barHeight < 1 then barHeight = 1 end
		local barX = fancy.x + fancy.w - barWidth
		local barY = fancy.y + ((fancy.indexRowDisplacement - 1) / #fancy.items) * fancyWidth
		if fancy.x + fancy.w > gr.getWidth() then barX = fancy.x - barWidth end
		gr.rectangle("fill", barX, barY, barWidth, barHeight)
	end
	gr.setColor(255, 255, 255)
	--gr.rectangle("line", fancy.x, fancy.y, fancy.w, fancy.h)
	gr.setLineStyle("smooth")
	fancy.alphaScroll = fancy.alphaScroll - love.timer.getDelta() * 200
	if fancy.alphaScroll <= 0 then
		fancy.alphaScroll = 0
	end
end

function fancy.wheel(y)
	if y < 0 then -- Up:
		if kb.isDown("lctrl") or kb.isDown("rctrl") then
			if fancy.maxRows < #fancy.items then
				fancy.maxRows = fancy.maxRows + 1
				fancy.alphaScroll = 0
			end
		elseif (fancy.indexRowDisplacement - 1) + fancy.maxRows < #fancy.items then
			fancy.indexRowDisplacement = fancy.indexRowDisplacement + 1
			fancy.alphaScroll = 255
		end
	elseif y > 0 then -- Down:
		if kb.isDown("lctrl") or kb.isDown("rctrl") then
			if fancy.maxRows > 1 then
				fancy.maxRows = fancy.maxRows - 1
				fancy.alphaScroll = 0
			end
		elseif fancy.indexRowDisplacement > 1 then
			fancy.indexRowDisplacement = fancy.indexRowDisplacement - 1
			fancy.alphaScroll = 255
		end
	end
end

function fancy.mouse(btn)
	if overQuad(mo.getX(), mo.getY()) then
		local alphaStep = 20
		if btn == 3 then -- Middle click.
			fancy.pressed = true
			fancy.dx, fancy.dy = mo.getX() - fancy.x, mo.getY() - fancy.y
		end
	else
		fancy.pressed = false
	end
end

return fancy
