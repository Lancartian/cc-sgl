--- Base component class for all UI elements
--- Provides common functionality for positioning, sizing, visibility, and event handling
local utils = require("src.core.utils")
local renderer = require("src.core.renderer")

local Component = utils.class()

--- Initialize a new component
--- @param x number X position
--- @param y number Y position
--- @param width number Width
--- @param height number Height
function Component:init(x, y, width, height)
    self.id = utils.generateId()
    self.x = x or 1
    self.y = y or 1
    self.width = width or 10
    self.height = height or 3
    self.visible = true
    self.enabled = true
    self.focused = false
    self.children = {}
    self.parent = nil
    self.eventHandlers = {}
    
    -- Styling
    self.style = {
        bgColor = colors.gray,
        fgColor = colors.white,
        borderColor = colors.lightGray,
        focusBgColor = colors.lightGray,
        focusFgColor = colors.white,
        disabledBgColor = colors.gray,
        disabledFgColor = colors.lightGray
    }
    
    -- Layout properties
    self.margin = {top = 0, right = 0, bottom = 0, left = 0}
    self.padding = {top = 0, right = 0, bottom = 0, left = 0}
    
    -- State
    self.dirty = true
    self.data = {}
end

--- Add a child component
--- @param child Component Child component to add
function Component:addChild(child)
    table.insert(self.children, child)
    child.parent = self
    self:markDirty()
end

--- Remove a child component
--- @param child Component Child to remove
function Component:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            child.parent = nil
            self:markDirty()
            break
        end
    end
end

--- Get absolute position (considering parent positions)
--- @return number, number Absolute X and Y
function Component:getAbsolutePosition()
    local absX, absY = self.x, self.y
    
    if self.parent then
        local parentX, parentY = self.parent:getAbsolutePosition()
        absX = absX + parentX - 1
        absY = absY + parentY - 1
    end
    
    return absX, absY
end

--- Check if a point is inside this component
--- @param x number X coordinate
--- @param y number Y coordinate
--- @return boolean True if point is inside
function Component:isPointInside(x, y)
    if not self.visible then
        return false
    end
    
    local absX, absY = self:getAbsolutePosition()
    return renderer.isPointInRect(x, y, absX, absY, self.width, self.height)
end

--- Set position
--- @param x number New X position
--- @param y number New Y position
function Component:setPosition(x, y)
    self.x = x
    self.y = y
    self:markDirty()
end

--- Set size
--- @param width number New width
--- @param height number New height
function Component:setSize(width, height)
    self.width = width
    self.height = height
    self:markDirty()
end

--- Set visibility
--- @param visible boolean Visibility state
function Component:setVisible(visible)
    self.visible = visible
    self:markDirty()
end

--- Set enabled state
--- @param enabled boolean Enabled state
function Component:setEnabled(enabled)
    self.enabled = enabled
    self:markDirty()
end

--- Set focus state
--- @param focused boolean Focus state
function Component:setFocus(focused)
    self.focused = focused
    self:markDirty()
    if self.onFocusChanged then
        self:onFocusChanged(focused)
    end
end

--- Mark this component as needing redraw
function Component:markDirty()
    self.dirty = true
    if self.parent then
        self.parent:markDirty()
    end
end

--- Get the current background color based on state
--- @return number Background color
function Component:getCurrentBgColor()
    if not self.enabled then
        return self.style.disabledBgColor
    elseif self.focused then
        return self.style.focusBgColor
    else
        return self.style.bgColor
    end
end

--- Get the current foreground color based on state
--- @return number Foreground color
function Component:getCurrentFgColor()
    if not self.enabled then
        return self.style.disabledFgColor
    elseif self.focused then
        return self.style.focusFgColor
    else
        return self.style.fgColor
    end
end

--- Set style properties
--- @param styleProps table Table of style properties
function Component:setStyle(styleProps)
    for k, v in pairs(styleProps) do
        self.style[k] = v
    end
    self:markDirty()
end

--- Set margin
--- @param top number Top margin
--- @param right number Right margin
--- @param bottom number Bottom margin
--- @param left number Left margin
function Component:setMargin(top, right, bottom, left)
    self.margin.top = top or self.margin.top
    self.margin.right = right or self.margin.right
    self.margin.bottom = bottom or self.margin.bottom
    self.margin.left = left or self.margin.left
    self:markDirty()
end

--- Set padding
--- @param top number Top padding
--- @param right number Right padding
--- @param bottom number Bottom padding
--- @param left number Left padding
function Component:setPadding(top, right, bottom, left)
    self.padding.top = top or self.padding.top
    self.padding.right = right or self.padding.right
    self.padding.bottom = bottom or self.padding.bottom
    self.padding.left = left or self.padding.left
    self:markDirty()
end

--- Draw the component (to be overridden by subclasses)
function Component:draw()
    if not self.visible then
        return
    end
    
    local absX, absY = self:getAbsolutePosition()
    renderer.drawRect(absX, absY, self.width, self.height, self:getCurrentBgColor())
    
    -- Draw children
    for _, child in ipairs(self.children) do
        child:draw()
    end
    
    self.dirty = false
end

--- Update the component (called each frame)
--- @param dt number Delta time
function Component:update(dt)
    if not self.visible then
        return
    end
    
    -- Update children
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

--- Handle mouse click event
--- @param x number Mouse X
--- @param y number Mouse Y
--- @param button number Mouse button
--- @return boolean True if event was handled
function Component:handleClick(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    -- Check children first (in reverse order for proper z-ordering)
    for i = #self.children, 1, -1 do
        if self.children[i]:handleClick(x, y, button) then
            return true
        end
    end
    
    -- Check if click is on this component
    if self:isPointInside(x, y) then
        if self.onClick then
            self:onClick(x, y, button)
        end
        return true
    end
    
    return false
end

--- Handle key press event
--- @param key number Key code
--- @return boolean True if event was handled
function Component:handleKey(key)
    if not self.visible or not self.enabled or not self.focused then
        return false
    end
    
    if self.onKey then
        return self:onKey(key)
    end
    
    return false
end

--- Handle character input event
--- @param char string Character
--- @return boolean True if event was handled
function Component:handleChar(char)
    if not self.visible or not self.enabled or not self.focused then
        return false
    end
    
    if self.onChar then
        return self:onChar(char)
    end
    
    return false
end

--- Cleanup resources
function Component:destroy()
    -- Cleanup children
    for _, child in ipairs(self.children) do
        child:destroy()
    end
    
    -- Clear references
    self.children = {}
    self.parent = nil
    self.eventHandlers = {}
    
    if self.onDestroy then
        self:onDestroy()
    end
end

--- Find a child component by ID
--- @param id string Component ID
--- @return Component Component with matching ID or nil
function Component:findById(id)
    if self.id == id then
        return self
    end
    
    for _, child in ipairs(self.children) do
        local found = child:findById(id)
        if found then
            return found
        end
    end
    
    return nil
end

--- Get all children recursively
--- @return table Array of all descendant components
function Component:getAllChildren()
    local all = {}
    
    for _, child in ipairs(self.children) do
        table.insert(all, child)
        local subChildren = child:getAllChildren()
        for _, subChild in ipairs(subChildren) do
            table.insert(all, subChild)
        end
    end
    
    return all
end

--- Bring this component to front (among siblings)
function Component:bringToFront()
    if not self.parent then
        return
    end
    
    local siblings = self.parent.children
    for i, child in ipairs(siblings) do
        if child == self then
            table.remove(siblings, i)
            table.insert(siblings, self)
            self.parent:markDirty()
            break
        end
    end
end

--- Send this component to back (among siblings)
function Component:sendToBack()
    if not self.parent then
        return
    end
    
    local siblings = self.parent.children
    for i, child in ipairs(siblings) do
        if child == self then
            table.remove(siblings, i)
            table.insert(siblings, 1, self)
            self.parent:markDirty()
            break
        end
    end
end

return Component
