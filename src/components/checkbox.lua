--- Checkbox component
local Component = require("/lib/sgl/src/components/base")
local renderer = require("/lib/sgl/src/core/renderer")
local utils = require("/lib/sgl/src/core/utils")

local Checkbox = utils.class(Component)

--- Initialize a checkbox
--- @param x number X position
--- @param y number Y position
--- @param label string Label text
--- @param checked boolean Initial checked state
function Checkbox:init(x, y, label, checked)
    Component.init(self, x, y, #label + 4, 1)
    
    self.label = label or ""
    self.checked = checked or false
    
    self.style.bgColor = colors.black
    self.style.fgColor = colors.white
    self.style.checkColor = colors.lime
    self.style.boxColor = colors.gray
end

--- Set checked state
--- @param checked boolean Checked state
function Checkbox:setChecked(checked)
    self.checked = checked
    self:markDirty()
    
    if self.onChanged then
        self.onChanged(self.checked)
    end
end

--- Get checked state
--- @return boolean Checked state
function Checkbox:isChecked()
    return self.checked
end

--- Toggle checked state
function Checkbox:toggle()
    self:setChecked(not self.checked)
end

--- Draw the checkbox
function Checkbox:draw()
    if not self.visible then
        return
    end
    
    local absX, absY = self:getAbsolutePosition()
    
    -- Draw background
    renderer.drawRect(absX, absY, self.width, self.height, self:getCurrentBgColor())
    
    -- Draw checkbox box
    local boxChar = self.checked and "X" or " "
    renderer.drawText(absX, absY, "[", self.style.boxColor, self:getCurrentBgColor())
    renderer.drawText(absX + 1, absY, boxChar, self.style.checkColor, self:getCurrentBgColor())
    renderer.drawText(absX + 2, absY, "]", self.style.boxColor, self:getCurrentBgColor())
    
    -- Draw label
    renderer.drawText(absX + 4, absY, self.label, 
                    self:getCurrentFgColor(), self:getCurrentBgColor())
    
    self.dirty = false
end

--- Handle click
--- @param x number Mouse X
--- @param y number Mouse Y
--- @param button number Mouse button
function Checkbox:handleClick(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:isPointInside(x, y) then
        self:toggle()
        
        if self.onClick then
            self.onClick(x, y, button)
        end
        
        return true
    end
    
    return false
end

return Checkbox
