--- Radio button component
local Component = require("/lib/sgl/src/components/base")
local renderer = require("/lib/sgl/src/core/renderer")
local utils = require("/lib/sgl/src/core/utils")

local Radio = utils.class(Component)

--- Initialize a radio button
--- @param x number X position
--- @param y number Y position
--- @param label string Label text
--- @param group string Group name
--- @param selected boolean Initial selected state
function Radio:init(x, y, label, group, selected)
    Component.init(self, x, y, #label + 4, 1)
    
    self.label = label or ""
    self.group = group or "default"
    self.selected = selected or false
    
    self.style.bgColor = colors.black
    self.style.fgColor = colors.white
    self.style.selectColor = colors.lime
    self.style.circleColor = colors.gray
end

--- Set selected state
--- @param selected boolean Selected state
function Radio:setSelected(selected)
    self.selected = selected
    self:markDirty()
    
    if self.onChanged then
        self.onChanged(self.selected)
    end
end

--- Get selected state
--- @return boolean Selected state
function Radio:isSelected()
    return self.selected
end

--- Draw the radio button
function Radio:draw()
    if not self.visible then
        return
    end
    
    local absX, absY = self:getAbsolutePosition()
    
    -- Draw background
    renderer.drawRect(absX, absY, self.width, self.height, self:getCurrentBgColor())
    
    -- Draw radio circle
    local circleChar = self.selected and "O" or " "
    renderer.drawText(absX, absY, "(", self.style.circleColor, self:getCurrentBgColor())
    renderer.drawText(absX + 1, absY, circleChar, self.style.selectColor, self:getCurrentBgColor())
    renderer.drawText(absX + 2, absY, ")", self.style.circleColor, self:getCurrentBgColor())
    
    -- Draw label
    renderer.drawText(absX + 4, absY, self.label, 
                    self:getCurrentFgColor(), self:getCurrentBgColor())
    
    self.dirty = false
end

--- Handle click
--- @param x number Mouse X
--- @param y number Mouse Y
--- @param button number Mouse button
function Radio:handleClick(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:isPointInside(x, y) then
        -- Deselect other radio buttons in the same group
        if self.parent then
            for _, child in ipairs(self.parent:getAllChildren()) do
                if child ~= self and child.group == self.group then
                    if child.setSelected then
                        child:setSelected(false)
                    end
                end
            end
        end
        
        self:setSelected(true)
        
        if self.onClick then
            self.onClick(x, y, button)
        end
        
        return true
    end
    
    return false
end

return Radio
