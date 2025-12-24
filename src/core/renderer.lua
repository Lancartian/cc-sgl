--- Core rendering module for CC-SGL (ComputerCraft Simple Graphics Library)
--- Provides low-level drawing primitives and screen management
local renderer = {}

-- Cache commonly used term functions for performance
local term = term
local colors = colors
local math = math

--- Initialize the renderer with a terminal object
--- @param terminal table Optional terminal object (defaults to current term)
function renderer.init(terminal)
    renderer.term = terminal or term.current()
    renderer.width, renderer.height = renderer.term.getSize()
    renderer.supportsColor = renderer.term.isColor()
end

--- Clear the screen with a specific color
--- @param color number Color to use for clearing
function renderer.clear(color)
    if color and renderer.supportsColor then
        renderer.term.setBackgroundColor(color)
    end
    renderer.term.clear()
end

--- Draw a filled rectangle
--- @param x number X position
--- @param y number Y position
--- @param width number Width of rectangle
--- @param height number Height of rectangle
--- @param color number Background color
function renderer.drawRect(x, y, width, height, color)
    if color and renderer.supportsColor then
        renderer.term.setBackgroundColor(color)
    end
    
    local line = string.rep(" ", width)
    for i = 0, height - 1 do
        renderer.term.setCursorPos(x, y + i)
        renderer.term.write(line)
    end
end

--- Draw a rectangle outline
--- @param x number X position
--- @param y number Y position
--- @param width number Width of rectangle
--- @param height number Height of rectangle
--- @param color number Text color
--- @param bgColor number Background color
function renderer.drawRectOutline(x, y, width, height, color, bgColor)
    if color and renderer.supportsColor then
        renderer.term.setTextColor(color)
    end
    if bgColor and renderer.supportsColor then
        renderer.term.setBackgroundColor(bgColor)
    end
    
    local horizontal = string.rep("-", width - 2)
    local vertical = "|" .. string.rep(" ", width - 2) .. "|"
    
    -- Top border
    renderer.term.setCursorPos(x, y)
    renderer.term.write("+" .. horizontal .. "+")
    
    -- Middle rows
    for i = 1, height - 2 do
        renderer.term.setCursorPos(x, y + i)
        renderer.term.write(vertical)
    end
    
    -- Bottom border
    renderer.term.setCursorPos(x, y + height - 1)
    renderer.term.write("+" .. horizontal .. "+")
end

--- Draw text at a specific position
--- @param x number X position
--- @param y number Y position
--- @param text string Text to draw
--- @param fgColor number Optional text color
--- @param bgColor number Optional background color
function renderer.drawText(x, y, text, fgColor, bgColor)
    if fgColor and renderer.supportsColor then
        renderer.term.setTextColor(fgColor)
    end
    if bgColor and renderer.supportsColor then
        renderer.term.setBackgroundColor(bgColor)
    end
    
    renderer.term.setCursorPos(x, y)
    renderer.term.write(text)
end

--- Draw centered text
--- @param y number Y position
--- @param text string Text to draw
--- @param fgColor number Optional text color
--- @param bgColor number Optional background color
function renderer.drawCenteredText(y, text, fgColor, bgColor)
    local x = math.floor((renderer.width - #text) / 2) + 1
    renderer.drawText(x, y, text, fgColor, bgColor)
end

--- Draw text aligned within a bounding box
--- @param x number X position of box
--- @param y number Y position of box
--- @param width number Width of box
--- @param text string Text to draw
--- @param align string Alignment: "left", "center", or "right"
--- @param fgColor number Optional text color
--- @param bgColor number Optional background color
function renderer.drawAlignedText(x, y, width, text, align, fgColor, bgColor)
    local textLen = #text
    local drawX = x
    
    if textLen > width then
        text = text:sub(1, width)
        textLen = width
    end
    
    if align == "center" then
        drawX = x + math.floor((width - textLen) / 2)
    elseif align == "right" then
        drawX = x + width - textLen
    end
    
    renderer.drawText(drawX, y, text, fgColor, bgColor)
end

--- Draw a line (horizontal or vertical)
--- @param x1 number Start X
--- @param y1 number Start Y
--- @param x2 number End X
--- @param y2 number End Y
--- @param color number Color to draw with
--- @param char string Character to use for drawing (default " ")
function renderer.drawLine(x1, y1, x2, y2, color, char)
    char = char or " "
    
    if color and renderer.supportsColor then
        renderer.term.setBackgroundColor(color)
    end
    
    -- Horizontal line
    if y1 == y2 then
        local startX = math.min(x1, x2)
        local endX = math.max(x1, x2)
        local line = string.rep(char, endX - startX + 1)
        renderer.term.setCursorPos(startX, y1)
        renderer.term.write(line)
    -- Vertical line
    elseif x1 == x2 then
        local startY = math.min(y1, y2)
        local endY = math.max(y1, y2)
        for y = startY, endY do
            renderer.term.setCursorPos(x1, y)
            renderer.term.write(char)
        end
    else
        -- Bresenham's line algorithm for diagonal lines
        local dx = math.abs(x2 - x1)
        local dy = math.abs(y2 - y1)
        local sx = x1 < x2 and 1 or -1
        local sy = y1 < y2 and 1 or -1
        local err = dx - dy
        
        while true do
            renderer.term.setCursorPos(x1, y1)
            renderer.term.write(char)
            
            if x1 == x2 and y1 == y2 then break end
            
            local e2 = 2 * err
            if e2 > -dy then
                err = err - dy
                x1 = x1 + sx
            end
            if e2 < dx then
                err = err + dx
                y1 = y1 + sy
            end
        end
    end
end

--- Draw a progress bar
--- @param x number X position
--- @param y number Y position
--- @param width number Width of bar
--- @param progress number Progress value (0-1)
--- @param color number Filled color
--- @param bgColor number Background color
function renderer.drawProgressBar(x, y, width, progress, color, bgColor)
    progress = math.max(0, math.min(1, progress))
    local filledWidth = math.floor(width * progress)
    
    -- Draw background
    if bgColor and renderer.supportsColor then
        renderer.term.setBackgroundColor(bgColor)
    end
    renderer.term.setCursorPos(x, y)
    renderer.term.write(string.rep(" ", width))
    
    -- Draw filled portion
    if filledWidth > 0 then
        if color and renderer.supportsColor then
            renderer.term.setBackgroundColor(color)
        end
        renderer.term.setCursorPos(x, y)
        renderer.term.write(string.rep(" ", filledWidth))
    end
end

--- Check if a point is within a rectangular area
--- @param px number Point X
--- @param py number Point Y
--- @param x number Rectangle X
--- @param y number Rectangle Y
--- @param width number Rectangle width
--- @param height number Rectangle height
--- @return boolean True if point is inside rectangle
function renderer.isPointInRect(px, py, x, y, width, height)
    return px >= x and px < x + width and py >= y and py < y + height
end

--- Clip text to fit within a specific width
--- @param text string Text to clip
--- @param width number Maximum width
--- @param ellipsis string Optional ellipsis string (default "...")
--- @return string Clipped text
function renderer.clipText(text, width, ellipsis)
    ellipsis = ellipsis or "..."
    if #text <= width then
        return text
    end
    return text:sub(1, width - #ellipsis) .. ellipsis
end

--- Set cursor blink state
--- @param enabled boolean Whether cursor should blink
function renderer.setCursorBlink(enabled)
    renderer.term.setCursorBlink(enabled)
end

--- Get the current screen size
--- @return number, number Width and height
function renderer.getSize()
    return renderer.term.getSize()
end

--- Restore default colors
function renderer.resetColors()
    if renderer.supportsColor then
        renderer.term.setTextColor(colors.white)
        renderer.term.setBackgroundColor(colors.black)
    end
end

--- Redirect output to a window or monitor
--- @param terminal table Terminal object to redirect to
function renderer.redirect(terminal)
    renderer.term = terminal
    renderer.width, renderer.height = renderer.term.getSize()
    renderer.supportsColor = renderer.term.isColor()
end

-- Initialize with default terminal
renderer.init()

return renderer
