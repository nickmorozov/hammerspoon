-- Window Management tools
local log = hs.logger.new("windows", "debug")

-- Private

local margin = 4

-- Define the enum with readonly protection
local Positions = {
	FULL = 0,
	LEFT = 1,
	RIGHT = 2,
}

-- Add Dock offset to window frame
local function offsetFrame(frame)
	-- Add offset to coordinates
	frame.x = frame.x + margin
	frame.y = frame.y + margin
	-- Subtract offset from width and height
	frame.w = frame.w - 2 * margin
	frame.h = frame.h - 2 * margin

	return frame
end

-- Calculate maximum allowed window size based on menubar and dock visibility and position
local function getFrame(position)
	local primaryScreen = hs.screen.primaryScreen()

	local maxFrame = primaryScreen:fullFrame()
	local allowedFrame = primaryScreen:frame()
	-- If Dock and Menu are hidden - window fills the screen
	-- If Dock and Menu are hidden - window fills the screen
	local x = 0
	local y = 24 -- menubar height. can't solve for no menubar
	local w = allowedFrame.w
	local h = allowedFrame.h

	if maxFrame.w == allowedFrame.w then
		-- Dock is not on the side or hidden
		-- y = 24 -- menubar height. can't solve for no menubar
	else
		-- Dock is on the side of the screen
		x = maxFrame.w - allowedFrame.w -- dock width
	end

	w = w - 175 -- stage manager width
	local frame = offsetFrame(hs.geometry.rect(x, y, w, h))

	if position == Positions.LEFT then
		frame.w = frame.w / 2 - margin / 2
	elseif position == Positions.RIGHT then
		frame.x = frame.x + frame.w / 2 + margin / 2
		frame.w = frame.w / 2 - margin / 2
	end

	log.d(frame)

	return frame
end

local function moveUntilReady(window, frame)
	hs.timer.doUntil(function()
		return window:frame() == frame
	end, function()
		window:move(frame, nil, false, 0.0)
	end, hs.window.animationDuration)
end

-- Module

local function set(position, window)
	if not window then
		window = hs.window.focusedWindow()
	end

	moveUntilReady(window, getFrame(position))
end

-- Wrappers

local function full()
	set(Positions.FULL)
end

local function left()
	set(Positions.LEFT)
end

local function right()
	set(Positions.RIGHT)
end

local compareFrames = function(frame1, frame2)
	return math.floor(frame1.x) == math.floor(frame2.x)
		and math.floor(frame1.y) == math.floor(frame2.y)
		and math.floor(frame1.w) == math.floor(frame2.w)
		and math.floor(frame1.h) == math.floor(frame2.h)
end

local function toggle()
	local frame = hs.window.focusedWindow():frame()

	log.d(frame)

	if compareFrames(frame, getFrame(Positions.FULL)) then
		left()
	elseif compareFrames(frame, getFrame(Positions.LEFT)) then
		right()
	elseif compareFrames(frame, getFrame(Positions.RIGHT)) then
		full()
	else
		full() -- Default to full
	end
end

-- Debug

local function printFrameUnderCursor()
	local pos = hs.mouse.absolutePosition()
	local win = hs.fnutils.find(hs.window.orderedWindows(), function(w)
		return hs.geometry.isPointInRect(pos, w:frame())
	end)

	if win then
		local frame = win:frame()
		-- Can be replaced with hs.show.alert()
		print(
			string.format(
				"Window under cursor: %s\nX: %d, Y: %d, Width: %d, Height: %d",
				win:title(),
				frame.x,
				frame.y,
				frame.w,
				frame.h
			)
		)
	else
		-- Can be replaced with hs.show.alert()
		print("No window under cursor.")
	end
end

--[[
local appWatcher = nil

function checkAndCloseApp(appObject)
  -- Delay in seconds before checking the number of windows
  local delay = 1
  hs.timer.doAfter(delay, function()
    if #appObject:allWindows() == 0 then
      appObject:kill()
    end
  end)
end

function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.activated) then
    if (appName == "Preview") then
      checkAndCloseApp(appObject)
    end
  end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()
]]
--[[
local windowFilter = hs.window.filter.new()
local appName = "Preview" -- Replace with the name of your app

windowFilter:setAppFilter(appName, { visible = true, currentSpace = true })
windowFilter:subscribe(hs.window.filter.windowDestroyed, function(window)
  local app = window:application()
  if app and app:name() == appName then
    if #app:allWindows() == 0 then
      -- Perform your action here, e.g., closing the app
      app:kill()
    end
  end
end)
]]

-- TODO: this should register the window for auto resizing.
hs.application.watcher
	.new(function(appName, eventType, appObject)
		hs.notify.show(appName .. " - title", eventType .. " - subtitle", "information")
		print(appName, eventType)

		if eventType == hs.application.watcher.activated then
			-- windows.full()
		end
	end)
	:start()

return {
	Positions = Positions,
	set = set,
	toggle = toggle,
	full = full,
	left = left,
	right = right,
	printFrameUnderCursor = printFrameUnderCursor,
}
