--- Panel component - container for other components
local Component = require("/lib/sgl/src/components/base")
local renderer = require("/lib/sgl/src/core/renderer")
local utils = require("/lib/sgl/src/core/utils")

local Panel = utils.class(Component)

--- Initialize a panel
--- @param x number X position
--- @param y number Y position
--- @param width number Width
--- @param height number Height
function Panel:init(x, y, width, height)
    Component.init(self, x, y, width, height)
    
    self.border = true
    self.title = nil
    self.scrollable = false
    self.scrollY = 0
    self.contentHeight = 0
    
    self.style.bgColor = colors.black
    self.style.fgColor = colors.white
    self.style.borderColor = colors.gray
    self.style.titleBgColor = colors.gray
    self.style.titleFgColor = colors.white
end

--- Set title
--- @param title string Panel title
function Panel:setTitle(title)
    self.title = title
    self:markDirty()
end

--- Set border visibility
--- @param border boolean Whether to show border
function Panel:setBorder(border)
    self.border = border
    self:markDirty()
end

--- Set scrollable
--- @param scrollable boolean Whether panel is scrollable
function Panel:setScrollable(scrollable)
    self.scrollable = scrollable
    self:markDirty()
end

--- Draw the panel
function Panel:draw()
    if not self.visible then
        return
    end
    
    local absX, absY = self:getAbsolutePosition()
    
    -- Draw background
    renderer.drawRect(absX, absY, self.width, self.height, self:getCurrentBgColor())
    
    -- Draw border
    if self.border then
        renderer.drawRectOutline(absX, absY, self.width, self.height, 
                               self.style.borderColor, self:getCurrentBgColor())
    end
    
    -- Draw title if present
    if self.title then
        local titleY = absY
        if self.border then
            titleY = absY
        end
        
        renderer.drawRect(absX, titleY, self.width, 1, self.style.titleBgColor)
        renderer.drawAlignedText(absX, titleY, self.width, " " .. self.title, 
                               "left", self.style.titleFgColor, self.style.titleBgColor)
    end
    
    -- Draw children
    for _, child in ipairs(self.children) do
        child:draw()
    end
    
    self.dirty = false
end

--- Handle scroll event
--- @param direction number Scroll direction (-1 up, 1 down)
function Panel:handleScroll(direction)
    if not self.scrollable then
        return false
    end
    
    self.scrollY = self.scrollY + direction
    self.scrollY = utils.clamp(self.scrollY, 0, math.max(0, self.contentHeight - self.height))
    self:markDirty()
    
    return true
end

return Panel
