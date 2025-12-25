--- List component - displays a list of items
local Component = require("/lib/sgl/src/components/base")
local renderer = require("/lib/sgl/src/core/renderer")
local utils = require("/lib/sgl/src/core/utils")

local List = utils.class(Component)

--- Initialize a list
--- @param x number X position
--- @param y number Y position
--- @param width number Width
--- @param height number Height
function List:init(x, y, width, height)
    Component.init(self, x, y, width, height)
    
    self.items = {}
    self.selectedIndex = nil
    self.scrollOffset = 0
    self.multiSelect = false
    self.selectedItems = {}
    
    self.style.bgColor = colors.black
    self.style.fgColor = colors.white
    self.style.selectedBgColor = colors.blue
    self.style.selectedFgColor = colors.white
    self.style.hoverBgColor = colors.gray
end

--- Add an item to the list
--- @param item string|table Item to add
function List:addItem(item)
    table.insert(self.items, item)
    self:markDirty()
end

--- Remove an item from the list
--- @param index number Index of item to remove
function List:removeItem(index)
    table.remove(self.items, index)
    if self.selectedIndex == index then
        self.selectedIndex = nil
    elseif self.selectedIndex and self.selectedIndex > index then
        self.selectedIndex = self.selectedIndex - 1
    end
    self:markDirty()
end

--- Clear all items
function List:clear()
    self.items = {}
    self.selectedIndex = nil
    self.selectedItems = {}
    self.scrollOffset = 0
    self:markDirty()
end

--- Set items
--- @param items table Array of items
function List:setItems(items)
    self.items = items
    self.selectedIndex = nil
    self.selectedItems = {}
    self.scrollOffset = 0
    self:markDirty()
end

--- Get items
--- @return table Array of items
function List:getItems()
    return self.items
end

--- Set selected index
--- @param index number Index to select
function List:setSelectedIndex(index)
    if index and index >= 1 and index <= #self.items then
        self.selectedIndex = index
        
        -- Ensure selected item is visible
        if index < self.scrollOffset + 1 then
            self.scrollOffset = index - 1
        elseif index > self.scrollOffset + self.height then
            self.scrollOffset = index - self.height
        end
        
        self:markDirty()
        
        if self.onSelectionChanged then
            self:onSelectionChanged(index, self.items[index])
        end
    end
end

--- Get selected index
--- @return number Selected index or nil
function List:getSelectedIndex()
    return self.selectedIndex
end

--- Get selected item
--- @return any Selected item or nil
function List:getSelectedItem()
    if self.selectedIndex then
        return self.items[self.selectedIndex]
    end
    return nil
end

--- Draw the list
function List:draw()
    if not self.visible then
        return
    end
    
    local absX, absY = self:getAbsolutePosition()
    
    -- Draw background
    renderer.drawRect(absX, absY, self.width, self.height, self:getCurrentBgColor())
    
    -- Draw items
    local visibleItems = math.min(self.height, #self.items - self.scrollOffset)
    for i = 1, visibleItems do
        local itemIndex = i + self.scrollOffset
        local item = self.items[itemIndex]
        local itemY = absY + i - 1
        
        -- Determine colors
        local bgColor = self:getCurrentBgColor()
        local fgColor = self:getCurrentFgColor()
        
        if itemIndex == self.selectedIndex then
            bgColor = self.style.selectedBgColor
            fgColor = self.style.selectedFgColor
        end
        
        -- Get item text
        local itemText = type(item) == "table" and (item.text or item.label or tostring(item)) or tostring(item)
        itemText = renderer.clipText(itemText, self.width)
        
        -- Draw item
        renderer.drawRect(absX, itemY, self.width, 1, bgColor)
        renderer.drawText(absX, itemY, itemText, fgColor, bgColor)
    end
    
    -- Draw scrollbar if needed
    if #self.items > self.height then
        local scrollbarHeight = math.max(1, math.floor(self.height * self.height / #self.items))
        local scrollbarY = math.floor(self.scrollOffset / #self.items * self.height)
        
        for i = 0, scrollbarHeight - 1 do
            local y = absY + scrollbarY + i
            if y >= absY and y < absY + self.height then
                renderer.drawText(absX + self.width - 1, y, " ", colors.white, colors.lightGray)
            end
        end
    end
    
    self.dirty = false
end

--- Handle click
--- @param x number Mouse X
--- @param y number Mouse Y
--- @param button number Mouse button
function List:handleClick(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:isPointInside(x, y) then
        local absX, absY = self:getAbsolutePosition()
        local relY = y - absY
        local clickedIndex = relY + self.scrollOffset + 1
        
        if clickedIndex >= 1 and clickedIndex <= #self.items then
            self:setSelectedIndex(clickedIndex)
            
            if self.onItemClick then
                self:onItemClick(clickedIndex, self.items[clickedIndex])
            end
        end
        
        if self.onClick then
            self:onClick(x, y, button)
        end
        
        return true
    end
    
    return false
end

--- Handle scroll
--- @param direction number Scroll direction (-1 up, 1 down)
function List:handleScroll(direction)
    self.scrollOffset = utils.clamp(self.scrollOffset + direction, 
                                    0, math.max(0, #self.items - self.height))
    self:markDirty()
end

return List
