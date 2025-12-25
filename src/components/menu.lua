--- Menu component for creating dropdown/context menus
local Component = require("/lib/sgl/src/components/base")
local renderer = require("/lib/sgl/src/core/renderer")
local utils = require("/lib/sgl/src/core/utils")

local Menu = utils.class(Component)

--- Initialize a menu
--- @param x number X position
--- @param y number Y position
--- @param width number Width
function Menu:init(x, y, width)
    Component.init(self, x, y, width, 0)
    
    self.items = {}
    self.selectedIndex = nil
    self.autoClose = true
    
    self.style.bgColor = colors.gray
    self.style.fgColor = colors.white
    self.style.selectedBgColor = colors.lightGray
    self.style.separatorColor = colors.lightGray
    self.style.disabledFgColor = colors.lightGray
end

--- Add a menu item
--- @param label string Item label
--- @param callback function Callback when clicked
--- @param enabled boolean Whether item is enabled (default true)
function Menu:addItem(label, callback, enabled)
    enabled = enabled == nil and true or enabled
    
    table.insert(self.items, {
        label = tostring(label or ""),
        callback = callback,
        enabled = enabled,
        separator = false
    })
    
    self.height = #self.items
    self:markDirty()
end

--- Add a separator
function Menu:addSeparator()
    table.insert(self.items, {
        separator = true
    })
    
    self.height = #self.items
    self:markDirty()
end

--- Remove all items
function Menu:clear()
    self.items = {}
    self.height = 0
    self.selectedIndex = nil
    self:markDirty()
end

--- Draw the menu
function Menu:draw()
    if not self.visible or #self.items == 0 then
        return
    end
    
    local absX, absY = self:getAbsolutePosition()
    
    for i, item in ipairs(self.items) do
        local itemY = absY + i - 1
        
        if item.separator then
            -- Draw separator
            renderer.drawLine(absX, itemY, absX + self.width - 1, itemY,
                            self.style.separatorColor, "-")
        else
            -- Determine colors
            local bgColor = self:getCurrentBgColor()
            local fgColor = self:getCurrentFgColor()
            
            if i == self.selectedIndex then
                bgColor = self.style.selectedBgColor
            end
            
            if not item.enabled then
                fgColor = self.style.disabledFgColor
            end
            
            -- Draw item background
            renderer.drawRect(absX, itemY, self.width, 1, bgColor)
            
            -- Draw item text
            local text = " " .. item.label
            text = renderer.clipText(text, self.width)
            renderer.drawText(absX, itemY, text, fgColor, bgColor)
        end
    end
    
    self.dirty = false
end

--- Handle click
--- @param x number Mouse X
--- @param y number Mouse Y
--- @param button number Mouse button
function Menu:handleClick(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:isPointInside(x, y) then
        local absX, absY = self:getAbsolutePosition()
        local itemIndex = y - absY + 1
        
        if itemIndex >= 1 and itemIndex <= #self.items then
            local item = self.items[itemIndex]
            
            if not item.separator and item.enabled then
                self.selectedIndex = itemIndex
                
                if item.callback then
                    item.callback(item)
                end
                
                if self.autoClose then
                    self:setVisible(false)
                end
                
                self:markDirty()
            end
        end
        
        if self.onClick then
            self.onClick(x, y, button)
        end
        
        return true
    end
    
    return false
end

--- Handle mouse movement (for hover effects)
--- @param x number Mouse X
--- @param y number Mouse Y
function Menu:handleMouseMove(x, y)
    if not self.visible then
        return
    end
    
    if self:isPointInside(x, y) then
        local absX, absY = self:getAbsolutePosition()
        local itemIndex = y - absY + 1
        
        if itemIndex >= 1 and itemIndex <= #self.items then
            local item = self.items[itemIndex]
            
            if not item.separator and item.enabled then
                if self.selectedIndex ~= itemIndex then
                    self.selectedIndex = itemIndex
                    self:markDirty()
                end
            end
        end
    else
        if self.selectedIndex then
            self.selectedIndex = nil
            self:markDirty()
        end
    end
end

--- Show the menu at a specific position
--- @param x number X position
--- @param y number Y position
function Menu:show(x, y)
    self:setPosition(x, y)
    self:setVisible(true)
    self:bringToFront()
end

--- Hide the menu
function Menu:hide()
    self:setVisible(false)
    self.selectedIndex = nil
end

return Menu
