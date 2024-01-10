--[[Terminal Quake style visibility toggle]]

-- Modules

local windows = require("./windows")

-- Private

local log = hs.logger.new("Terminal", "debug")
local name = "com.apple.Terminal"

local function getApp()
	local app = hs.application.find(name)

	log.d("app: " .. hs.inspect(app))

	local firstLaunch = not app

	if firstLaunch then
		app = hs.application.open(name, 10, true)

		local window = app and app:mainWindow()

		if window then
			windows.set(windows.Positions.FULL, window)
		end
	end

	return app, firstLaunch
end

-- Module

local module = {}

function module.toggleTerminal()
	local app, firstLaunch = getApp()

	if app and not firstLaunch then
		-- Toggle visibility for existing window
		if app:isFrontmost() then
			app:activate(false)
			app:hide()
		else
			app:activate(true)
			app:unhide()
		end
	end
end

return module
