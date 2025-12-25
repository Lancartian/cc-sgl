--- Slider component
local Component = require("/lib/sgl/src/components/base")
local renderer = require("/lib/sgl/src/core/renderer")
local utils = require("/lib/sgl/src/core/utils")

local Slider = utils.class(Component)

--- Initialize a slider
--- @param x number X position
--- @param y number Y position
--- @param width number Width
--- @param min number Minimum value
--- @param max number Maximum value
--- @param value number Initial value
function Slider:init(x, y, width, min, max, value)
    Component.init(self, x, y, width, 1)
    
    self.min = min or 0
    self.max = max or 100
    self.value = value or self.min
    self.step = 1
    self.dragging = false
    
    self.style.bgColor = colors.gray
    self.style.fgColor = colors.white
    self.style.fillColor = colors.blue
    self.style.handleColor = colors.lightBlue
end

--- Set value
--- @param value number New value
function Slider:setValue(value)
    self.value = utils.clamp(value, self.min, self.max)
    self:markDirty()
    
    if self.onChanged then
        self.onChanged(self.value)
    end
end

--- Get value
--- @return number Current value
function Slider:getValue()
    return self.value
end

--- Set range
--- @param min number Minimum value
--- @param max number Maximum value
function Slider:setRange(min, max)
    self.min = min
    self.max = max
    self.value = utils.clamp(self.value, min, max)
    self:markDirty()
end

--- Set step size
--- @param step number Step size
function Slider:setStep(step)
    self.step = step
end

--- Draw the slider
function Slider:draw()
    if not self.visible then
        return
    end
    
    local absX, absY = self:getAbsolutePosition()
    
    -- Calculate handle position
    local range = self.max - self.min
    local normalizedValue = (self.value - self.min) / range
    local handlePos = math.floor(normalizedValue * (self.width - 1))
    
    -- Draw background track
    renderer.drawRect(absX, absY, self.width, 1, self.style.bgColor)
    
    -- Draw filled portion
    if handlePos > 0 then
        renderer.drawRect(absX, absY, handlePos, 1, self.style.fillColor)
    end
    
    -- Draw handle
    renderer.drawText(absX + handlePos, absY, " ", colors.white, self.style.handleColor)
    
    self.dirty = false
end

--- Update value from mouse position
--- @param mouseX number Mouse X coordinate
function Slider:updateFromMouse(mouseX)
    local absX, _ = self:getAbsolutePosition()
    local relX = mouseX - absX
    local normalizedPos = relX / (self.width - 1)
    normalizedPos = utils.clamp(normalizedPos, 0, 1)
    
    local range = self.max - self.min
    local newValue = self.min + (normalizedPos * range)
    
    -- Snap to step
    newValue = math.floor(newValue / self.step + 0.5) * self.step
    
    self:setValue(newValue)
end

--- Handle click
--- @param x number Mouse X
--- @param y number Mouse Y
--- @param button number Mouse button
function Slider:handleClick(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:isPointInside(x, y) then
        self.dragging = true
        self:updateFromMouse(x)
        
        if self.onClick then
            self:onClick(x, y, button)
        end
        
        return true
    end
    
    return false
end

--- Handle drag event (should be called from event system)
--- @param x number Mouse X
--- @param y number Mouse Y
function Slider:handleDrag(x, y)
    if self.dragging then
        self:updateFromMouse(x)
    end
end

--- Handle release event (should be called from event system)
function Slider:handleRelease()
    self.dragging = false
end

return Slider
