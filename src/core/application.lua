--- Application class - manages the entire GUI application
local utils = require("src.core.utils")
local renderer = require("src.core.renderer")
local eventManager = require("src.events.eventManager")

local Application = utils.class()

--- Initialize an application
--- @param title string Application title
function Application:init(title)
    self.title = title or "CC-SGL Application"
    self.root = nil
    self.focusedComponent = nil
    self.running = false
    self.fps = 20
    self.lastUpdate = os.clock()
    
    -- Event handlers
    self.eventHandlers = {}
    
    -- Initialize renderer
    renderer.init()
end

--- Set the root component
--- @param component Component Root component
function Application:setRoot(component)
    self.root = component
    self.root:markDirty()
end

--- Get the root component
--- @return Component Root component
function Application:getRoot()
    return self.root
end

--- Set focused component
--- @param component Component Component to focus
function Application:setFocus(component)
    if self.focusedComponent then
        self.focusedComponent:setFocus(false)
    end
    
    self.focusedComponent = component
    
    if self.focusedComponent then
        self.focusedComponent:setFocus(true)
    end
end

--- Get focused component
--- @return Component Focused component or nil
function Application:getFocusedComponent()
    return self.focusedComponent
end

--- Draw the application
function Application:draw()
    if not self.root then
        return
    end
    
    -- Clear screen
    renderer.clear(colors.black)
    
    -- Draw root component
    self.root:draw()
end

--- Update the application
--- @param dt number Delta time
function Application:update(dt)
    if self.root then
        self.root:update(dt)
    end
    
    -- Redraw if anything is dirty
    if self.root and self.root.dirty then
        renderer.clear(colors.black)
        self.root:draw()
    end
end

--- Handle mouse click event
--- @param data table Event data
function Application:handleMouseClick(data)
    if not self.root then
        return
    end
    
    -- Find the clicked component
    local clickedComponent = self:findComponentAt(data.x, data.y)
    
    -- Try to handle click on components
    local handled = self.root:handleClick(data.x, data.y, data.button)
    
    -- Update focus if a focusable component was clicked
    if clickedComponent and clickedComponent.focusable then
        self:setFocus(clickedComponent)
    elseif not handled and self.focusedComponent then
        -- If not handled and we have a focused component, unfocus it
        self:setFocus(nil)
    end
end

--- Handle key press event
--- @param data table Event data
function Application:handleKey(data)
    if self.focusedComponent then
        self.focusedComponent:handleKey(data.key)
    end
end

--- Handle character input event
--- @param data table Event data
function Application:handleChar(data)
    if self.focusedComponent then
        self.focusedComponent:handleChar(data.character)
    end
end

--- Handle mouse scroll event
--- @param data table Event data
function Application:handleScroll(data)
    if self.root then
        -- Find component at mouse position and send scroll event
        local component = self:findComponentAt(data.x, data.y)
        if component and component.handleScroll then
            component:handleScroll(data.direction)
        end
    end
end

--- Handle mouse drag event
--- @param data table Event data
function Application:handleMouseDrag(data)
    if self.root then
        -- Notify all components that might be dragging
        local function notifyDrag(component)
            if component.dragging and component.handleDrag then
                component:handleDrag(data.x, data.y)
            end
            for _, child in ipairs(component.children) do
                notifyDrag(child)
            end
        end
        notifyDrag(self.root)
    end
end

--- Handle mouse up event
--- @param data table Event data
function Application:handleMouseUp(data)
    if self.root then
        -- Notify all components that might need to stop dragging
        local function notifyRelease(component)
            if component.handleRelease then
                component:handleRelease()
            end
            for _, child in ipairs(component.children) do
                notifyRelease(child)
            end
        end
        notifyRelease(self.root)
    end
end

--- Find component at a specific position
--- @param x number X coordinate
--- @param y number Y coordinate
--- @return Component Component at position or nil
function Application:findComponentAt(x, y)
    if not self.root then
        return nil
    end
    
    local function findInComponent(component)
        if not component.visible then
            return nil
        end
        
        -- Check children first (reverse order for z-index)
        for i = #component.children, 1, -1 do
            local found = findInComponent(component.children[i])
            if found then
                return found
            end
        end
        
        -- Check this component
        if component:isPointInside(x, y) then
            return component
        end
        
        return nil
    end
    
    return findInComponent(self.root)
end

--- Run the application
function Application:run()
    self.running = true
    
    -- Setup event handlers
    self.eventHandlers.click = eventManager.on(eventManager.EVENT.MOUSE_CLICK, function(data)
        self:handleMouseClick(data)
        return true
    end)
    
    self.eventHandlers.key = eventManager.on(eventManager.EVENT.KEY, function(data)
        self:handleKey(data)
        return false
    end)
    
    self.eventHandlers.char = eventManager.on(eventManager.EVENT.CHAR, function(data)
        self:handleChar(data)
        return false
    end)
    
    self.eventHandlers.scroll = eventManager.on(eventManager.EVENT.MOUSE_SCROLL, function(data)
        self:handleScroll(data)
        return false
    end)
    
    self.eventHandlers.drag = eventManager.on(eventManager.EVENT.MOUSE_DRAG, function(data)
        self:handleMouseDrag(data)
        return false
    end)
    
    self.eventHandlers.mouseUp = eventManager.on(eventManager.EVENT.MOUSE_UP, function(data)
        self:handleMouseUp(data)
        return false
    end)
    
    -- Initial draw
    self:draw()
    
    -- Start event loop
    eventManager.run(function()
        if not self.running then
            eventManager.stop()
            return
        end
        
        local currentTime = os.clock()
        local dt = currentTime - self.lastUpdate
        
        -- Update at target FPS
        if dt >= 1 / self.fps then
            self:update(dt)
            self.lastUpdate = currentTime
        end
    end)
    
    -- Cleanup
    self:cleanup()
end

--- Stop the application
function Application:stop()
    self.running = false
end

--- Cleanup resources
function Application:cleanup()
    -- Remove event handlers
    for eventType, id in pairs(self.eventHandlers) do
        eventManager.off(eventType, id)
    end
    
    -- Cleanup root component
    if self.root then
        self.root:destroy()
    end
    
    -- Reset colors
    renderer.resetColors()
    renderer.clear(colors.black)
    renderer.setCursorBlink(false)
end

--- Set target FPS
--- @param fps number Target frames per second
function Application:setFPS(fps)
    self.fps = fps
end

return Application
