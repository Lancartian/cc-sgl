--- Label component - displays text
local Component = require("/lib/sgl/src/components/base")
local renderer = require("/lib/sgl/src/core/renderer")
local utils = require("/lib/sgl/src/core/utils")

local Label = utils.class(Component)

--- Initialize a label
--- @param x number X position
--- @param y number Y position
--- @param text string Text to display
--- @param width number Optional width (auto-sized if not provided)
function Label:init(x, y, text, width)
    Component.init(self, x, y, width or #text, 1)
    
    self.text = text or ""
    self.align = "left" -- "left", "center", "right"
    self.autoSize = width == nil
    self.wrap = false
    
    self.style.bgColor = colors.black
    self.style.fgColor = colors.white
    
    if self.autoSize then
        self.width = #self.text
    end
end

--- Set the text
--- @param text string New text
function Label:setText(text)
    self.text = text or ""
    if self.autoSize then
        self.width = #self.text
    end
    self:markDirty()
end

--- Get the text
--- @return string Current text
function Label:getText()
    return self.text
end

--- Set text alignment
--- @param align string Alignment: "left", "center", "right"
function Label:setAlign(align)
    self.align = align
    self:markDirty()
end

--- Draw the label
function Label:draw()
    if not self.visible then
        return
    end
    
    local absX, absY = self:getAbsolutePosition()
    
    -- Draw background
    renderer.drawRect(absX, absY, self.width, self.height, self:getCurrentBgColor())
    
    -- Draw text
    if self.wrap then
        local lines = utils.wrapText(self.text, self.width)
        for i, line in ipairs(lines) do
            if i <= self.height then
                renderer.drawAlignedText(absX, absY + i - 1, self.width, line, 
                                       self.align, self:getCurrentFgColor(), self:getCurrentBgColor())
            end
        end
    else
        local displayText = self.text
        if #displayText > self.width then
            displayText = renderer.clipText(displayText, self.width)
        end
        renderer.drawAlignedText(absX, absY, self.width, displayText, 
                               self.align, self:getCurrentFgColor(), self:getCurrentBgColor())
    end
    
    self.dirty = false
end

return Label
