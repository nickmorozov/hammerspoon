UserSpaces = {}
CurrentSpace = nil

Space = {}
Space.__index = Space

function Space.new(id, left, right)
	local self = setmetatable({}, Space)

	self.id = id
	self.left = left
	self.right = right

	UserSpaces[self.id] = self

	return self
end

function Space:move(spaceID)
	print("Moving to previous space with ID: " .. spaceID)
	CURRENT_SPACE = UserSpaces[spaceID]
	hs.spaces.gotoSpace(spaceID)
end

-- Move to the previous space if it exists
function Space:moveLeft()
	Util.i(self)
	if self.left then
		self:move(self.left)
	end
end

-- Move to the next space if it exists
function Space:moveRight()
	Util.i(self)
	if self.right then
		self:move(self.right)
	end
end

function Space:send(spaceID)
	Util.i(self)
	local focusedWindow = hs.window.focusedWindow()
	focusedWindow:spacesMoveTo(spaceID)
end

-- Move to the previous space if it exists
function Space:sendLeft()
	if self.left then
		print("Moving to previous space.")
		self:send(self.left)
	else
		print("No previous space.")
	end
end

-- Move to the next space if it exists
function Space:sendRight()
	if self.right then
		print("Moving to next space.")
		self:send(self.right)
	else
		print("No next space.")
	end
end

local function findCurrentSpace()
	if CURRENT_SPACE then
		return CURRENT_SPACE
	end

	local currentSpaceId = hs.spaces.focusedSpace()

	local userSpaces = {}
	for index, spaceID in ipairs(hs.spaces.spacesForScreen()) do
		if hs.spaces.spaceType(spaceID) == "user" then
			table.insert(userSpaces, spaceID)
		end
	end

	for index, spaceID in ipairs(userSpaces) do
		local prevSpaceID = index > 1 and userSpaces[index - 1] or nil
		local nextSpaceID = index < #userSpaces and userSpaces[index + 1] or nil
		local space = Space.new(spaceID, prevSpaceID, nextSpaceID)

		print("Space ID: " .. spaceID .. " Previous: " .. tostring(prevSpaceID) .. " Next: " .. tostring(nextSpaceID))

		if spaceID == currentSpaceId then
			CURRENT_SPACE = space
		end
	end

	return CURRENT_SPACE
end

local Buttons = {
	LEFT = 0,
	RIGHT = 1,
	MIDDLE = 2,
	FORWARD = 3,
	BACK = 4,
}

local function isOnlyCmdPressed()
	local modifiers = hs.eventtap.checkKeyboardModifiers()
	return modifiers.cmd and not (modifiers.alt or modifiers.shift or modifiers.ctrl or modifiers.fn)
end

local function isOnlyShiftPressed()
	local modifiers = hs.eventtap.checkKeyboardModifiers()
	return modifiers.shift and not (modifiers.alt or modifiers.cmd or modifiers.ctrl or modifiers.fn)
end

local Strokes = {
	-- MIDDLE - cmd+tab...
	[Buttons.BACK] = function()
		local space = findCurrentSpace()

		Util.i(space)

		if isOnlyShiftPressed() and space then
			print("Moving to previous space.")
			space:moveLeft()
		elseif isOnlyCmdPressed() and space then
			print("Sending window to previous space.")
			space:sendLeft()
		else
			print("Opening Mission Control.")
			hs.spaces.toggleMissionControl()
		end
	end,
	[Buttons.FORWARD] = function()
		local space = findCurrentSpace()

		Util.i(space)

		if isOnlyShiftPressed() and space then
			print("Moving to next space.")
			space:moveRight()
		elseif isOnlyCmdPressed() and space then
			print("Sending window to next space.")
			space:sendRight()
		else
			print("Opening App Expose.")
			hs.spaces.toggleAppExpose()
		end
	end,
}

local function mouseStroke(event)
	local button = event:getProperty(hs.eventtap.event.properties["mouseEventButtonNumber"])

	if button and Strokes[button] then
		Strokes[button]()
		return true -- Cancel original event
	end
end

return {
	startListener = function()
		local mouseWatcher = hs.eventtap.new({ hs.eventtap.event.types.otherMouseUp }, mouseStroke):start()

		if mouseWatcher then
			hs.alert.show("Mouse ✅")
		end
	end,
}
