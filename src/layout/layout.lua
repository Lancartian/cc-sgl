--- Layout manager system for automatic component positioning
local utils = require("src.core.utils")

local Layout = {}

--- Vertical layout - stacks components vertically
--- @param container Component Container to layout
--- @param spacing number Spacing between components
--- @param padding number Padding from edges
function Layout.vertical(container, spacing, padding)
    spacing = spacing or 1
    padding = padding or 0
    
    local currentY = padding
    
    for _, child in ipairs(container.children) do
        if child.visible then
            child:setPosition(padding, currentY)
            currentY = currentY + child.height + spacing
        end
    end
end

--- Horizontal layout - arranges components horizontally
--- @param container Component Container to layout
--- @param spacing number Spacing between components
--- @param padding number Padding from edges
function Layout.horizontal(container, spacing, padding)
    spacing = spacing or 1
    padding = padding or 0
    
    local currentX = padding
    
    for _, child in ipairs(container.children) do
        if child.visible then
            child:setPosition(currentX, padding)
            currentX = currentX + child.width + spacing
        end
    end
end

--- Grid layout - arranges components in a grid
--- @param container Component Container to layout
--- @param columns number Number of columns
--- @param spacing number Spacing between components
--- @param padding number Padding from edges
function Layout.grid(container, columns, spacing, padding)
    spacing = spacing or 1
    padding = padding or 0
    
    local row = 0
    local col = 0
    local maxRowHeight = 0
    local currentY = padding
    
    for i, child in ipairs(container.children) do
        if child.visible then
            local x = padding + col * (child.width + spacing)
            child:setPosition(x, currentY)
            
            maxRowHeight = math.max(maxRowHeight, child.height)
            
            col = col + 1
            if col >= columns then
                col = 0
                row = row + 1
                currentY = currentY + maxRowHeight + spacing
                maxRowHeight = 0
            end
        end
    end
end

--- Center a component within its container
--- @param container Component Container
--- @param child Component Child to center
--- @param horizontal boolean Center horizontally
--- @param vertical boolean Center vertically
function Layout.center(container, child, horizontal, vertical)
    if horizontal == nil then horizontal = true end
    if vertical == nil then vertical = true end
    
    local x = child.x
    local y = child.y
    
    if horizontal then
        x = math.floor((container.width - child.width) / 2) + 1
    end
    
    if vertical then
        y = math.floor((container.height - child.height) / 2) + 1
    end
    
    child:setPosition(x, y)
end

--- Anchor a component to edges of container
--- @param container Component Container
--- @param child Component Child to anchor
--- @param top boolean Anchor to top
--- @param right boolean Anchor to right
--- @param bottom boolean Anchor to bottom
--- @param left boolean Anchor to left
--- @param margin number Margin from edges
function Layout.anchor(container, child, top, right, bottom, left, margin)
    margin = margin or 0
    
    local x = child.x
    local y = child.y
    
    if left then
        x = 1 + margin
    elseif right then
        x = container.width - child.width - margin + 1
    end
    
    if top then
        y = 1 + margin
    elseif bottom then
        y = container.height - child.height - margin + 1
    end
    
    child:setPosition(x, y)
end

--- Fill container - make component fill the container
--- @param container Component Container
--- @param child Component Child to fill
--- @param margin number Margin from edges
function Layout.fill(container, child, margin)
    margin = margin or 0
    
    child:setPosition(1 + margin, 1 + margin)
    child:setSize(container.width - margin * 2, container.height - margin * 2)
end

--- Stack layout with automatic scrolling
--- @param container Component Container
--- @param spacing number Spacing between items
--- @param padding number Padding from edges
--- @return number Total content height
function Layout.stack(container, spacing, padding)
    spacing = spacing or 1
    padding = padding or 0
    
    local scrollY = container.scrollY or 0
    local currentY = padding - scrollY
    local totalHeight = padding
    
    for _, child in ipairs(container.children) do
        if child.visible then
            child:setPosition(padding, currentY)
            currentY = currentY + child.height + spacing
            totalHeight = totalHeight + child.height + spacing
        end
    end
    
    return totalHeight
end

--- Flex layout - distributes space evenly
--- @param container Component Container
--- @param direction string "horizontal" or "vertical"
--- @param spacing number Spacing between components
--- @param padding number Padding from edges
function Layout.flex(container, direction, spacing, padding)
    spacing = spacing or 1
    padding = padding or 0
    direction = direction or "horizontal"
    
    local visibleChildren = {}
    for _, child in ipairs(container.children) do
        if child.visible then
            table.insert(visibleChildren, child)
        end
    end
    
    if #visibleChildren == 0 then
        return
    end
    
    if direction == "horizontal" then
        local totalSpacing = spacing * (#visibleChildren - 1) + padding * 2
        local availableWidth = container.width - totalSpacing
        local childWidth = math.floor(availableWidth / #visibleChildren)
        
        local currentX = padding
        for _, child in ipairs(visibleChildren) do
            child:setPosition(currentX, padding)
            child:setSize(childWidth, child.height)
            currentX = currentX + childWidth + spacing
        end
    else
        local totalSpacing = spacing * (#visibleChildren - 1) + padding * 2
        local availableHeight = container.height - totalSpacing
        local childHeight = math.floor(availableHeight / #visibleChildren)
        
        local currentY = padding
        for _, child in ipairs(visibleChildren) do
            child:setPosition(padding, currentY)
            child:setSize(child.width, childHeight)
            currentY = currentY + childHeight + spacing
        end
    end
end

--- Absolute positioning helper
--- @param container Component Container
--- @param child Component Child to position
--- @param x number X position (can be percentage string like "50%")
--- @param y number Y position (can be percentage string like "50%")
function Layout.absolute(container, child, x, y)
    local posX = x
    local posY = y
    
    -- Handle percentage positioning
    if type(x) == "string" and x:match("%%$") then
        local percent = tonumber(x:match("^(.-)%%$"))
        posX = math.floor(container.width * percent / 100)
    end
    
    if type(y) == "string" and y:match("%%$") then
        local percent = tonumber(y:match("^(.-)%%$"))
        posY = math.floor(container.height * percent / 100)
    end
    
    child:setPosition(posX, posY)
end

return Layout
