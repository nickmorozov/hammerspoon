-- Alacritty Quake style visibility toggle
local module = {}
local name = "org.alacritty"

function module.toggleAlacritty()
    local app = hs.application.find(name) or hs.application.open(name, 10, true)
    local window = app and app:mainWindow()

    -- Toggle visibility after window was created
    if app and window then
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
