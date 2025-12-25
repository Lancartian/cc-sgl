--- Input field component - text input
local Component = require("/lib/sgl/src/components/base")
local renderer = require("/lib/sgl/src/core/renderer")
local utils = require("/lib/sgl/src/core/utils")

local Input = utils.class(Component)

--- Initialize an input field
--- @param x number X position
--- @param y number Y position
--- @param width number Width
--- @param placeholder string Optional placeholder text
function Input:init(x, y, width, placeholder)
    Component.init(self, x, y, width, 1)
    
    self.focusable = true
    self.text = ""
    self.placeholder = tostring(placeholder or "")
    self.cursorPos = 0
    self.scrollOffset = 0
    self.masked = false -- For password fields
    self.maxLength = nil
    self.validator = nil -- Function to validate input
    self.history = {}
    self.historyIndex = 0
    
    self.style.bgColor = colors.black
    self.style.fgColor = colors.white
    self.style.focusBgColor = colors.gray
    self.style.focusFgColor = colors.white
    self.style.placeholderColor = colors.lightGray
    self.style.cursorColor = colors.white
end

--- Set the text
--- @param text string New text
function Input:setText(text)
    self.text = tostring(text or "")
    self.cursorPos = #self.text
    self:markDirty()
    
    if self.onTextChanged then
        self:onTextChanged(self.text)
    end
end

--- Get the text
--- @return string Current text
function Input:getText()
    return self.text
end

--- Set placeholder text
--- @param placeholder string Placeholder text
function Input:setPlaceholder(placeholder)
    self.placeholder = placeholder
    self:markDirty()
end

--- Set masked mode (for passwords)
--- @param masked boolean Whether to mask text
function Input:setMasked(masked)
    self.masked = masked
    self:markDirty()
end

--- Set maximum length
--- @param maxLength number Maximum text length
function Input:setMaxLength(maxLength)
    self.maxLength = maxLength
end

--- Set validator function
--- @param validator function Function that returns true if input is valid
function Input:setValidator(validator)
    self.validator = validator
end

--- Draw the input field
function Input:draw()
    if not self.visible then
        return
    end
    
    local absX, absY = self:getAbsolutePosition()
    
    -- Draw background
    renderer.drawRect(absX, absY, self.width, self.height, self:getCurrentBgColor())
    
    -- Draw text or placeholder
    local displayText = self.text
    if #displayText == 0 and not self.focused then
        displayText = self.placeholder
        renderer.drawText(absX, absY, 
                        renderer.clipText(displayText, self.width),
                        self.style.placeholderColor, self:getCurrentBgColor())
    else
        if self.masked then
            displayText = string.rep("*", #displayText)
        end
        
        -- Handle scrolling for long text
        local visibleText = displayText:sub(self.scrollOffset + 1, self.scrollOffset + self.width)
        renderer.drawText(absX, absY, visibleText, 
                        self:getCurrentFgColor(), self:getCurrentBgColor())
    end
    
    -- Draw cursor if focused
    if self.focused then
        local cursorX = absX + self.cursorPos - self.scrollOffset
        if cursorX >= absX and cursorX < absX + self.width then
            renderer.drawText(cursorX, absY, " ", colors.white, self.style.cursorColor)
        end
    end
    
    self.dirty = false
end

--- Handle character input
--- @param char string Character
--- @return boolean True if handled
function Input:handleChar(char)
    if not self.focused or not self.enabled then
        return false
    end
    
    -- Check max length
    if self.maxLength and #self.text >= self.maxLength then
        return true
    end
    
    -- Insert character at cursor position
    self.text = self.text:sub(1, self.cursorPos) .. char .. self.text:sub(self.cursorPos + 1)
    self.cursorPos = self.cursorPos + 1
    
    -- Update scroll offset
    if self.cursorPos - self.scrollOffset >= self.width then
        self.scrollOffset = self.cursorPos - self.width + 1
    end
    
    self:markDirty()
    
    if self.onTextChanged then
        self.onTextChanged(self.text)
    end
    
    return true
end

--- Handle key press
--- @param key number Key code
--- @return boolean True if handled
function Input:handleKey(key)
    if not self.focused or not self.enabled then
        return false
    end
    
    if key == keys.backspace then
        if self.cursorPos > 0 then
            self.text = self.text:sub(1, self.cursorPos - 1) .. self.text:sub(self.cursorPos + 1)
            self.cursorPos = self.cursorPos - 1
            
            -- Update scroll offset
            if self.cursorPos < self.scrollOffset then
                self.scrollOffset = math.max(0, self.scrollOffset - 1)
            end
            
            self:markDirty()
            
            if self.onTextChanged then
                self:onTextChanged(self.text)
            end
        end
        return true
        
    elseif key == keys.delete then
        if self.cursorPos < #self.text then
            self.text = self.text:sub(1, self.cursorPos) .. self.text:sub(self.cursorPos + 2)
            self:markDirty()
            
            if self.onTextChanged then
                self:onTextChanged(self.text)
            end
        end
        return true
        
    elseif key == keys.left then
        if self.cursorPos > 0 then
            self.cursorPos = self.cursorPos - 1
            
            -- Update scroll offset
            if self.cursorPos < self.scrollOffset then
                self.scrollOffset = self.cursorPos
            end
            
            self:markDirty()
        end
        return true
        
    elseif key == keys.right then
        if self.cursorPos < #self.text then
            self.cursorPos = self.cursorPos + 1
            
            -- Update scroll offset
            if self.cursorPos - self.scrollOffset >= self.width then
                self.scrollOffset = self.cursorPos - self.width + 1
            end
            
            self:markDirty()
        end
        return true
        
    elseif key == keys.home then
        self.cursorPos = 0
        self.scrollOffset = 0
        self:markDirty()
        return true
        
    elseif key == keys["end"] then
        self.cursorPos = #self.text
        self.scrollOffset = math.max(0, self.cursorPos - self.width + 1)
        self:markDirty()
        return true
        
    elseif key == keys.enter then
        if self.onSubmit then
            self:onSubmit(self.text)
        end
        return true
    end
    
    return false
end

--- Handle click (to set cursor position)
--- @param x number Mouse X
--- @param y number Mouse Y
--- @param button number Mouse button
function Input:handleClick(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:isPointInside(x, y) then
        local absX, absY = self:getAbsolutePosition()
        local relX = x - absX
        
        -- Set cursor position based on click
        self.cursorPos = math.min(#self.text, relX + self.scrollOffset)
        self:setFocus(true)
        self:markDirty()
        
        if self.onClick then
            self.onClick(x, y, button)
        end
        
        return true
    end
    
    return false
end

--- Clear the input
function Input:clear()
    self:setText("")
end

--- Add current text to history
function Input:addToHistory()
    if #self.text > 0 then
        table.insert(self.history, self.text)
        self.historyIndex = #self.history + 1
    end
end

return Input
