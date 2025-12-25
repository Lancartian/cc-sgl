--- CC-SGL (ComputerCraft Simple Graphics Library)
--- A comprehensive GUI library for ComputerCraft
--- @module sgl
local sgl = {
    _VERSION = "1.0.0",
    _DESCRIPTION = "Simple Graphics Library for ComputerCraft",
    _AUTHOR = "CC-SGL Team"
}

-- Core modules
sgl.renderer = require("/lib/sgl/src/core/renderer")
sgl.utils = require("/lib/sgl/src/core/utils")
sgl.Application = require("/lib/sgl/src/core/application")
sgl.Dialog = require("/lib/sgl/src/core/dialog")

-- Event system
sgl.eventManager = require("/lib/sgl/src/events/eventManager")
sgl.EVENT = sgl.eventManager.EVENT

-- Components
sgl.Component = require("/lib/sgl/src/components/base")
sgl.Label = require("/lib/sgl/src/components/label")
sgl.Button = require("/lib/sgl/src/components/button")
sgl.Input = require("/lib/sgl/src/components/input")
sgl.Panel = require("/lib/sgl/src/components/panel")
sgl.Checkbox = require("/lib/sgl/src/components/checkbox")
sgl.Radio = require("/lib/sgl/src/components/radio")
sgl.Slider = require("/lib/sgl/src/components/slider")
sgl.ProgressBar = require("/lib/sgl/src/components/progressbar")
sgl.List = require("/lib/sgl/src/components/list")
sgl.Menu = require("/lib/sgl/src/components/menu")

-- Layout system
sgl.Layout = require("/lib/sgl/src/layout/layout")

-- Theme system
sgl.Theme = require("/lib/sgl/src/theme/theme")

--- Create a new application
--- @param title string Application title
--- @return Application New application instance
function sgl.createApplication(title)
    return sgl.Application:new(title)
end

--- Create a new component by type
--- @param componentType string Type of component ("button", "label", etc.)
--- @param ... any Constructor arguments
--- @return Component New component instance
function sgl.create(componentType, ...)
    local componentMap = {
        label = sgl.Label,
        button = sgl.Button,
        input = sgl.Input,
        panel = sgl.Panel,
        checkbox = sgl.Checkbox,
        radio = sgl.Radio,
        slider = sgl.Slider,
        progressbar = sgl.ProgressBar,
        progress = sgl.ProgressBar,
        list = sgl.List,
        menu = sgl.Menu
    }
    
    local componentClass = componentMap[componentType:lower()]
    if componentClass then
        return componentClass:new(...)
    end
    
    error("Unknown component type: " .. componentType)
end

--- Initialize CC-SGL with optional configuration
--- @param config table Optional configuration
function sgl.init(config)
    config = config or {}
    
    -- Set theme if provided
    if config.theme then
        if type(config.theme) == "string" then
            local theme = sgl.Theme.getByName(config.theme)
            if theme then
                sgl.Theme.setCurrent(theme)
            end
        elseif type(config.theme) == "table" then
            sgl.Theme.setCurrent(config.theme)
        end
    end
    
    -- Initialize renderer with custom terminal if provided
    if config.terminal then
        sgl.renderer.init(config.terminal)
    end
end

--- Quick helper to create a simple dialog
--- @param title string Dialog title
--- @param message string Dialog message
--- @param buttons table Array of button labels
--- @param callback function Callback function(buttonIndex)
--- @return Application Dialog application
function sgl.dialog(title, message, buttons, callback)
    buttons = buttons or {"OK"}
    
    local app = sgl.createApplication(title)
    
    -- Calculate dimensions
    local width, height = sgl.renderer.getSize()
    local dialogWidth = math.min(width - 4, 40)
    local dialogHeight = math.min(height - 4, 15)
    
    -- Create dialog panel
    local dialog = sgl.Panel:new(
        math.floor((width - dialogWidth) / 2) + 1,
        math.floor((height - dialogHeight) / 2) + 1,
        dialogWidth,
        dialogHeight
    )
    dialog:setTitle(title)
    dialog:setBorder(true)
    
    -- Add message label
    local messageLabel = sgl.Label:new(2, 3, message, dialogWidth - 4)
    messageLabel.wrap = true
    messageLabel:setAlign("center")
    dialog:addChild(messageLabel)
    
    -- Add buttons
    local buttonWidth = math.floor((dialogWidth - 4) / #buttons)
    local buttonY = dialogHeight - 3
    
    for i, buttonLabel in ipairs(buttons) do
        local buttonX = 2 + (i - 1) * buttonWidth
        local button = sgl.Button:new(buttonX, buttonY, buttonWidth - 2, 3, buttonLabel)
        button.onClick = function()
            if callback then
                callback(i)
            end
            app:stop()
        end
        dialog:addChild(button)
    end
    
    app:setRoot(dialog)
    return app
end

--- Show a simple message box
--- @param title string Dialog title
--- @param message string Dialog message
function sgl.messageBox(title, message)
    local app = sgl.dialog(title, message, {"OK"}, nil)
    app:run()
end

--- Show a confirmation dialog
--- @param title string Dialog title
--- @param message string Dialog message
--- @param callback function Callback function(confirmed: boolean)
function sgl.confirm(title, message, callback)
    local app = sgl.dialog(title, message, {"Yes", "No"}, function(buttonIndex)
        if callback then
            callback(buttonIndex == 1)
        end
    end)
    app:run()
end

--- Show an input dialog
--- @param title string Dialog title
--- @param prompt string Prompt message
--- @param defaultValue string Default input value
--- @param callback function Callback function(value: string or nil)
function sgl.input(title, prompt, defaultValue, callback)
    local app = sgl.createApplication(title)
    
    local width, height = sgl.renderer.getSize()
    local dialogWidth = math.min(width - 4, 40)
    local dialogHeight = 10
    
    local dialog = sgl.Panel:new(
        math.floor((width - dialogWidth) / 2) + 1,
        math.floor((height - dialogHeight) / 2) + 1,
        dialogWidth,
        dialogHeight
    )
    dialog:setTitle(title)
    dialog:setBorder(true)
    
    -- Add prompt label
    local promptLabel = sgl.Label:new(2, 3, prompt, dialogWidth - 4)
    dialog:addChild(promptLabel)
    
    -- Add input field
    local input = sgl.Input:new(2, 5, dialogWidth - 4)
    input:setText(defaultValue or "")
    input.onSubmit = function(text)
        if callback then
            callback(text)
        end
        app:stop()
    end
    dialog:addChild(input)
    
    -- Add OK and Cancel buttons
    local okButton = sgl.Button:new(2, 7, 10, 3, "OK")
    okButton.onClick = function()
        if callback then
            callback(input:getText())
        end
        app:stop()
    end
    dialog:addChild(okButton)
    
    local cancelButton = sgl.Button:new(14, 7, 10, 3, "Cancel")
    cancelButton.onClick = function()
        if callback then
            callback(nil)
        end
        app:stop()
    end
    dialog:addChild(cancelButton)
    
    app:setRoot(dialog)
    app:setFocus(input)
    app:run()
end

--- Get library version
--- @return string Version string
function sgl.version()
    return sgl._VERSION
end

return sgl
