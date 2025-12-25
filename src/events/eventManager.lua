--- Event management system for CC-SGL
--- Handles mouse clicks, touches, keyboard input, and custom events
local eventManager = {}

local utils = require("/lib/sgl/src/core/utils")

-- Event listeners storage
eventManager.listeners = {}
eventManager.globalListeners = {}
eventManager.running = false
eventManager.eventQueue = {}

--- Event types
eventManager.EVENT = {
    MOUSE_CLICK = "mouse_click",
    MOUSE_UP = "mouse_up",
    MOUSE_DRAG = "mouse_drag",
    MOUSE_SCROLL = "mouse_scroll",
    KEY = "key",
    KEY_UP = "key_up",
    CHAR = "char",
    PASTE = "paste",
    TIMER = "timer",
    REDSTONE = "redstone",
    TERMINATE = "terminate",
    CUSTOM = "custom"
}

--- Register an event listener
--- @param eventType string Type of event to listen for
--- @param callback function Function to call when event occurs
--- @param id string Optional unique ID for the listener
--- @return string Listener ID
function eventManager.on(eventType, callback, id)
    id = id or utils.generateId()
    
    if not eventManager.listeners[eventType] then
        eventManager.listeners[eventType] = {}
    end
    
    eventManager.listeners[eventType][id] = callback
    return id
end

--- Remove an event listener
--- @param eventType string Type of event
--- @param id string Listener ID to remove
function eventManager.off(eventType, id)
    if eventManager.listeners[eventType] then
        eventManager.listeners[eventType][id] = nil
    end
end

--- Register a global event listener (receives all events)
--- @param callback function Function to call for any event
--- @param id string Optional unique ID
--- @return string Listener ID
function eventManager.onAny(callback, id)
    id = id or utils.generateId()
    eventManager.globalListeners[id] = callback
    return id
end

--- Remove a global event listener
--- @param id string Listener ID to remove
function eventManager.offAny(id)
    eventManager.globalListeners[id] = nil
end

--- Emit a custom event
--- @param eventType string Type of event
--- @param data table Event data
function eventManager.emit(eventType, data)
    table.insert(eventManager.eventQueue, {type = eventType, data = data})
end

--- Process an event through all registered listeners
--- @param eventType string Type of event
--- @param eventData table Event data
--- @return boolean True if event was handled
function eventManager.processEvent(eventType, eventData)
    local handled = false
    
    -- Call global listeners
    for _, callback in pairs(eventManager.globalListeners) do
        local success, result = pcall(callback, eventType, eventData)
        if not success then
            error("Error in event listener: " .. tostring(result))
        elseif result then
            handled = true
        end
    end
    
    -- Call specific event listeners
    if eventManager.listeners[eventType] then
        for _, callback in pairs(eventManager.listeners[eventType]) do
            local success, result = pcall(callback, eventData)
            if not success then
                error("Error in event listener: " .. tostring(result))
            elseif result then
                handled = true
            end
        end
    end
    
    return handled
end

--- Parse ComputerCraft event into CC-SGL event format
--- @param event table Raw CC event
--- @return string, table Event type and data
function eventManager.parseEvent(event)
    local eventType = event[1]
    local eventData = {}
    
    if eventType == "mouse_click" or eventType == "monitor_touch" then
        eventData.button = event[2]
        eventData.x = event[3]
        eventData.y = event[4]
        return eventManager.EVENT.MOUSE_CLICK, eventData
        
    elseif eventType == "mouse_up" then
        eventData.button = event[2]
        eventData.x = event[3]
        eventData.y = event[4]
        return eventManager.EVENT.MOUSE_UP, eventData
        
    elseif eventType == "mouse_drag" then
        eventData.button = event[2]
        eventData.x = event[3]
        eventData.y = event[4]
        return eventManager.EVENT.MOUSE_DRAG, eventData
        
    elseif eventType == "mouse_scroll" then
        eventData.direction = event[2]
        eventData.x = event[3]
        eventData.y = event[4]
        return eventManager.EVENT.MOUSE_SCROLL, eventData
        
    elseif eventType == "key" then
        eventData.key = event[2]
        eventData.isHeld = event[3]
        return eventManager.EVENT.KEY, eventData
        
    elseif eventType == "key_up" then
        eventData.key = event[2]
        return eventManager.EVENT.KEY_UP, eventData
        
    elseif eventType == "char" then
        eventData.character = event[2]
        return eventManager.EVENT.CHAR, eventData
        
    elseif eventType == "paste" then
        eventData.text = event[2]
        return eventManager.EVENT.PASTE, eventData
        
    elseif eventType == "timer" then
        eventData.timerId = event[2]
        return eventManager.EVENT.TIMER, eventData
        
    elseif eventType == "redstone" then
        return eventManager.EVENT.REDSTONE, eventData
        
    elseif eventType == "terminate" then
        return eventManager.EVENT.TERMINATE, eventData
    end
    
    -- Custom or unknown event
    eventData.raw = event
    return eventType, eventData
end

--- Start the event loop
--- @param updateCallback function Optional function called each iteration
function eventManager.run(updateCallback)
    eventManager.running = true
    
    while eventManager.running do
        -- Process queued events first
        while #eventManager.eventQueue > 0 do
            local queuedEvent = table.remove(eventManager.eventQueue, 1)
            eventManager.processEvent(queuedEvent.type, queuedEvent.data)
        end
        
        -- Pull next CC event
        local event = {os.pullEvent()}
        local eventType, eventData = eventManager.parseEvent(event)
        
        -- Handle terminate event
        if eventType == eventManager.EVENT.TERMINATE then
            eventManager.stop()
            break
        end
        
        -- Process the event
        eventManager.processEvent(eventType, eventData)
        
        -- Call update callback
        if updateCallback then
            local success = pcall(updateCallback)
            if not success then
                eventManager.running = false
            end
        end
    end
end

--- Stop the event loop
function eventManager.stop()
    eventManager.running = false
end

--- Wait for a single event
--- @param eventType string Optional event type to wait for
--- @param timeout number Optional timeout in seconds
--- @return string, table Event type and data, or nil if timeout
function eventManager.waitFor(eventType, timeout)
    local timer = nil
    if timeout then
        timer = os.startTimer(timeout)
    end
    
    while true do
        local event = {os.pullEvent()}
        local parsedType, parsedData = eventManager.parseEvent(event)
        
        if timer and parsedType == eventManager.EVENT.TIMER and parsedData.timerId == timer then
            return nil, nil
        end
        
        if not eventType or parsedType == eventType then
            if timer then
                os.cancelTimer(timer)
            end
            return parsedType, parsedData
        end
    end
end

--- Create a mouse event handler helper
--- @param component table Component to check bounds against
--- @param onClick function Callback when clicked
--- @param onRelease function Optional callback when released
--- @param onDrag function Optional callback when dragged
--- @return table Handler object with cleanup method
function eventManager.createMouseHandler(component, onClick, onRelease, onDrag)
    local handler = {
        clickId = nil,
        releaseId = nil,
        dragId = nil
    }
    
    if onClick then
        handler.clickId = eventManager.on(eventManager.EVENT.MOUSE_CLICK, function(data)
            if component:isPointInside(data.x, data.y) then
                onClick(data)
                return true
            end
            return false
        end)
    end
    
    if onRelease then
        handler.releaseId = eventManager.on(eventManager.EVENT.MOUSE_UP, function(data)
            if component:isPointInside(data.x, data.y) then
                onRelease(data)
                return true
            end
            return false
        end)
    end
    
    if onDrag then
        handler.dragId = eventManager.on(eventManager.EVENT.MOUSE_DRAG, function(data)
            onDrag(data)
            return false
        end)
    end
    
    function handler:cleanup()
        if self.clickId then
            eventManager.off(eventManager.EVENT.MOUSE_CLICK, self.clickId)
        end
        if self.releaseId then
            eventManager.off(eventManager.EVENT.MOUSE_UP, self.releaseId)
        end
        if self.dragId then
            eventManager.off(eventManager.EVENT.MOUSE_DRAG, self.dragId)
        end
    end
    
    return handler
end

--- Create a keyboard event handler helper
--- @param onKey function Callback for key press
--- @param onChar function Callback for character input
--- @return table Handler object with cleanup method
function eventManager.createKeyboardHandler(onKey, onChar)
    local handler = {
        keyId = nil,
        charId = nil
    }
    
    if onKey then
        handler.keyId = eventManager.on(eventManager.EVENT.KEY, function(data)
            onKey(data)
        end)
    end
    
    if onChar then
        handler.charId = eventManager.on(eventManager.EVENT.CHAR, function(data)
            onChar(data)
        end)
    end
    
    function handler:cleanup()
        if self.keyId then
            eventManager.off(eventManager.EVENT.KEY, self.keyId)
        end
        if self.charId then
            eventManager.off(eventManager.EVENT.CHAR, self.charId)
        end
    end
    
    return handler
end

--- Clear all event listeners
function eventManager.clearAll()
    eventManager.listeners = {}
    eventManager.globalListeners = {}
    eventManager.eventQueue = {}
end

return eventManager
