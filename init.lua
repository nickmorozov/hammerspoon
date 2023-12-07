--@Author: Nick Morozov
--@License: MIT

-- Modules

local alacritty = require("./alacritty")
local windows = require("./windows")

-- Hammerspoon

hs.hotkey.bind(
  {"ctrl", "alt", "shift"},
  "R",
  function()
    hs.reload()
  end
)

hs.hotkey.bind(
  {"ctrl", "alt", "shift"},
  "C",
  function()
    hs.toggleConsole()
  end
)

-- Alacritty Quake style visibility toggle

hs.hotkey.bind({"ctrl"}, "§", alacritty.toggleAlacritty)
hs.hotkey.bind({"ctrl"}, "`", alacritty.toggleAlacritty)

-- Set default window size and position

hs.hotkey.bind({"ctrl", "alt", "shift"}, "z", windows.resetWindow) -- todo: set position first, then size
