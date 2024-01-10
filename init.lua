-- @Author: Nick Morozov
-- @License: MIT

-- Modules
require("hs.ipc")
-- Util = require("./util")

-- local terminal = require("./terminal")
-- local windows = require("./windows")
-- local mouse = require("./mouse")

-- Hammerspoon

hs.logger.defaultLogLevel = "info"

local meh = { "ctrl", "alt", "shift" }
local hyper = { "ctrl", "alt", "shift", "cmd" }

local modal = hs.hotkey.modal.new(hyper, "home")

function modal:entered()
	print("Entered mode")
end

function modal:exited()
	print("Exited mode")
end

for i = 0, 3 do
	modal:bind({}, tostring(i), function()
		hs.alert.show("Layer " .. i)
		modal:exit()
	end)
end

modal:bind({}, "escape", function()
	modal:exit()
end)

modal:bind({}, "r", function()
	hs.reload()
	modal:exit()
end)

modal:bind({}, "c", function()
	hs.toggleConsole()
	modal:exit()
end)

-- modal:bind({}, "t", function()
-- 	Terminal.toggleTerminal()
-- end)

-- Terminal Quake style visibility toggle

-- hs.hotkey.bind({"ctrl"}, "§", terminal.toggleTerminal)
-- hs.hotkey.bind({"ctrl"}, "`", terminal.toggleTerminal)

-- Set default window size and position

-- hs.hotkey.bind(meh, "z", windows.toggle)
-- hs.hotkey.bind(meh, "up", windows.full)
-- hs.hotkey.bind(meh, "left", windows.left)
-- hs.hotkey.bind(meh, "right", windows.right)

-- Set event listeners

--Mouse.startListener()

-- Fancy auto reload

local function reloadConfig(files)
	local doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end

local configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

hs.alert.show("Hammerspoon ✅")

-- TODO: show desktop/app(s) name on switch
