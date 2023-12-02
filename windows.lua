-- Window Management tools
local module = {}

function module.setWindow()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    f.x = 70 -- x coordinate
    f.y = 40 -- y coordinate
    f.w = 1784 -- width
    f.h = 1224 -- height
    win:setFrame(f)
end

function module.sizeAtCursor()
    local pos = hs.mouse.absolutePosition()
    local win =
        hs.fnutils.find(
        hs.window.orderedWindows(),
        function(w)
            return hs.geometry.isPointInRect(pos, w:frame())
        end
    )

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

return module
