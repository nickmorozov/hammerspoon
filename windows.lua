-- Window Management tools

local this = {}
local log = hs.logger.new("windows", "debug")

-- Private

local dockMargin = 4

-- Add Dock offset to window frame
local function offsetFrame(frame)
    -- Add offset to coordinates
    frame.x = frame.x + dockMargin
    frame.y = frame.y + dockMargin
    -- Substract offset from width and height
    frame.w = frame.w - 2 * dockMargin
    frame.h = frame.h - 2 * dockMargin

    return frame
end

-- Calculate maximum allowed window size based on menubar and dock visibility and position
function this.getFrame()
    local primaryScreen = hs.screen.primaryScreen()

    local maxFrame = primaryScreen:fullFrame()
    local allowedFrame = primaryScreen:frame()

    log.d("maxFrame: " .. maxFrame.w .. "x" .. maxFrame.h .. " (" .. maxFrame.x .. "," .. maxFrame.y .. ")")
    log.d(
        "allowedFrame: " ..
            allowedFrame.w .. "x" .. allowedFrame.h .. " (" .. allowedFrame.x .. "," .. allowedFrame.y .. ")"
    )

    -- If Dock and Menu are hidden - window fills the screen
    local x = 0
    local y = 0
    local w = allowedFrame.w
    local h = allowedFrame.h

    if maxFrame.w == allowedFrame.w then
        -- Dock is not on the side or hidden
        -- Set combined dock and menubar height (both could be hidden, giving us 0 here)
        y = maxFrame.h - allowedFrame.h
    else
        -- Dock is on the side of the screen
        x = maxFrame.w - allowedFrame.w -- dock width
        y = maxFrame.h - allowedFrame.h -- menubar height or 0 if hidden
    end

    local frame = offsetFrame(hs.geometry.rect(x, y, w, h))

    log.d("frame: " .. frame.w .. "x" .. frame.h .. " (" .. frame.x .. "," .. frame.y .. ")")

    return frame
end

-- Module

function this.resetWindow()
    local frame = this.getFrame()

    hs.timer.doUntil(
        function()
            return hs.window.focusedWindow():frame() == frame
        end,
        function()
            hs.window.focusedWindow():move(frame, nil, false, 0.0)
        end,
        hs.window.animationDuration
    )
end

function this.printFrameUnderCursor()
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

return this
