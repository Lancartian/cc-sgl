--- Button component - clickable button
local Component = require("/lib/sgl/src/components/base")
local renderer = require("/lib/sgl/src/core/renderer")
local utils = require("/lib/sgl/src/core/utils")

local Button = utils.class(Component)

--- Initialize a button
--- @param x number X position
--- @param y number Y position
--- @param width number Width
--- @param height number Height
--- @param text string Button text
function Button:init(x, y, width, height, text)
    Component.init(self, x, y, width, height)
    
    self.text = text or "Button"
    self.align = "center"
    self.pressed = false
    
    self.style.bgColor = colors.gray
    self.style.fgColor = colors.white
    self.style.focusBgColor = colors.lightGray
    self.style.pressedBgColor = colors.gray
    self.style.hoverBgColor = colors.lightGray
end

--- Set button text
--- @param text string New text
function Button:setText(text)
    self.text = text
    self:markDirty()
end

--- Get button text
--- @return string Current text
function Button:getText()
    return self.text
end

--- Draw the button
function Button:draw()
    if not self.visible then
        return
    end
    
    local absX, absY = self:getAbsolutePosition()
    
    -- Determine background color
    local bgColor = self:getCurrentBgColor()
    if self.pressed then
        bgColor = self.style.pressedBgColor or colors.gray
    end
    
    -- Draw button background
    renderer.drawRect(absX, absY, self.width, self.height, bgColor)
    
    -- Draw button text (centered vertically)
    local textY = absY + math.floor(self.height / 2)
    renderer.drawAlignedText(absX, textY, self.width, self.text, 
                           self.align, self:getCurrentFgColor(), bgColor)
    
    self.dirty = false
end

--- Handle mouse click
--- @param x number Mouse X
--- @param y number Mouse Y
--- @param button number Mouse button
function Button:handleClick(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:isPointInside(x, y) then
        self.pressed = true
        self:markDirty()
        
        if self.onClick then
            self.onClick(x, y, button)
        end
        
        return true
    end
    
    return false
end

--- Handle mouse release (should be called from event manager)
--- @param x number Mouse X
--- @param y number Mouse Y
function Button:handleRelease(x, y)
    if self.pressed then
        self.pressed = false
        self:markDirty()
        
        if self:isPointInside(x, y) and self.onRelease then
            self.onRelease()
        end
    end
end

return Button
