--- Dialog helpers for common dialog patterns
local utils = require("/lib/sgl/src/core/utils")
local renderer = require("/lib/sgl/src/core/renderer")
local Application = require("/lib/sgl/src/core/application")
local Panel = require("/lib/sgl/src/components/panel")
local Label = require("/lib/sgl/src/components/label")
local Button = require("/lib/sgl/src/components/button")
local Input = require("/lib/sgl/src/components/input")
local List = require("/lib/sgl/src/components/list")
local ProgressBar = require("/lib/sgl/src/components/progressbar")

local Dialog = {}

--- Create a centered panel for dialogs
--- @param width number Dialog width
--- @param height number Dialog height
--- @param title string Dialog title
--- @return Panel Dialog panel
local function createDialogPanel(width, height, title)
    local screenWidth, screenHeight = renderer.getSize()
    local x = math.floor((screenWidth - width) / 2) + 1
    local y = math.floor((screenHeight - height) / 2) + 1
    
    local panel = Panel:new(x, y, width, height)
    panel:setTitle(title)
    panel:setBorder(true)
    
    return panel
end

--- Show a message dialog
--- @param title string Dialog title
--- @param message string Message to display
--- @param buttonText string Button text (default "OK")
--- @param callback function Optional callback when closed
function Dialog.message(title, message, buttonText, callback)
    buttonText = buttonText or "OK"
    
    local app = Application:new(title)
    local width = math.min(45, math.max(30, #message + 4))
    local height = 10
    
    local panel = createDialogPanel(width, height, title)
    
    -- Message label
    local messageLabel = Label:new(2, 3, message, width - 4)
    messageLabel:setAlign("center")
    panel:addChild(messageLabel)
    
    -- OK button
    local btnWidth = math.min(15, width - 4)
    local btnX = math.floor((width - btnWidth) / 2)
    local okBtn = Button:new(btnX, height - 4, btnWidth, 3, buttonText)
    okBtn.onClick = function()
        if callback then callback() end
        app:stop()
    end
    panel:addChild(okBtn)
    
    app:setRoot(panel)
    app:run()
end

--- Show a confirmation dialog
--- @param title string Dialog title
--- @param message string Message to display
--- @param callback function Callback(confirmed: boolean)
--- @param yesText string Yes button text (default "Yes")
--- @param noText string No button text (default "No")
function Dialog.confirm(title, message, callback, yesText, noText)
    yesText = yesText or "Yes"
    noText = noText or "No"
    
    local app = Application:new(title)
    local width = math.min(45, math.max(30, #message + 4))
    local height = 10
    
    local panel = createDialogPanel(width, height, title)
    
    -- Message label
    local messageLabel = Label:new(2, 3, message, width - 4)
    messageLabel:setAlign("center")
    panel:addChild(messageLabel)
    
    -- Buttons
    local btnWidth = math.floor((width - 6) / 2)
    
    local yesBtn = Button:new(2, height - 4, btnWidth, 3, yesText)
    yesBtn.style.bgColor = colors.green
    yesBtn.onClick = function()
        if callback then callback(true) end
        app:stop()
    end
    panel:addChild(yesBtn)
    
    local noBtn = Button:new(width - btnWidth, height - 4, btnWidth, 3, noText)
    noBtn.style.bgColor = colors.red
    noBtn.onClick = function()
        if callback then callback(false) end
        app:stop()
    end
    panel:addChild(noBtn)
    
    app:setRoot(panel)
    app:run()
end

--- Show an input dialog
--- @param title string Dialog title
--- @param prompt string Prompt text
--- @param defaultValue string Default input value
--- @param callback function Callback(value: string or nil)
--- @param placeholder string Optional placeholder
function Dialog.input(title, prompt, defaultValue, callback, placeholder)
    local app = Application:new(title)
    local width = 40
    local height = 11
    
    local panel = createDialogPanel(width, height, title)
    
    -- Prompt label
    local promptLabel = Label:new(2, 2, prompt, width - 4)
    panel:addChild(promptLabel)
    
    -- Input field
    local input = Input:new(2, 4, width - 4, placeholder)
    input:setText(defaultValue or "")
    input.onSubmit = function(text)
        if callback then callback(text) end
        app:stop()
    end
    panel:addChild(input)
    
    -- Buttons
    local btnWidth = math.floor((width - 6) / 2)
    
    local okBtn = Button:new(2, height - 4, btnWidth, 3, "OK")
    okBtn.style.bgColor = colors.green
    okBtn.onClick = function()
        if callback then callback(input:getText()) end
        app:stop()
    end
    panel:addChild(okBtn)
    
    local cancelBtn = Button:new(width - btnWidth, height - 4, btnWidth, 3, "Cancel")
    cancelBtn.style.bgColor = colors.red
    cancelBtn.onClick = function()
        if callback then callback(nil) end
        app:stop()
    end
    panel:addChild(cancelBtn)
    
    app:setRoot(panel)
    app:setFocus(input)
    app:run()
end

--- Show a list selection dialog
--- @param title string Dialog title
--- @param items table Array of items to choose from
--- @param callback function Callback(selectedIndex, selectedItem)
function Dialog.list(title, items, callback)
    local app = Application:new(title)
    local width = 40
    local height = 16
    
    local panel = createDialogPanel(width, height, title)
    
    -- List
    local list = List:new(2, 2, width - 4, height - 7)
    list:setItems(items)
    panel:addChild(list)
    
    -- Buttons
    local btnWidth = math.floor((width - 6) / 2)
    
    local selectBtn = Button:new(2, height - 4, btnWidth, 3, "Select")
    selectBtn.style.bgColor = colors.green
    selectBtn.onClick = function()
        local index = list:getSelectedIndex()
        if index and callback then
            callback(index, list:getSelectedItem())
        end
        app:stop()
    end
    panel:addChild(selectBtn)
    
    local cancelBtn = Button:new(width - btnWidth, height - 4, btnWidth, 3, "Cancel")
    cancelBtn.style.bgColor = colors.red
    cancelBtn.onClick = function()
        if callback then callback(nil, nil) end
        app:stop()
    end
    panel:addChild(cancelBtn)
    
    app:setRoot(panel)
    app:run()
end

--- Show a progress dialog (non-blocking, returns controller)
--- @param title string Dialog title
--- @param message string Initial message
--- @return table Controller with update(progress, message) and close() methods
function Dialog.progress(title, message)
    local app = Application:new(title)
    local width = 40
    local height = 10
    
    local panel = createDialogPanel(width, height, title)
    
    -- Message label
    local messageLabel = Label:new(2, 2, message, width - 4)
    messageLabel:setAlign("center")
    panel:addChild(messageLabel)
    
    -- Progress bar
    local progress = ProgressBar:new(2, 4, width - 4, 1)
    progress:setProgress(0)
    panel:addChild(progress)
    
    -- Percentage label
    local percentLabel = Label:new(2, 6, "0%", width - 4)
    percentLabel:setAlign("center")
    panel:addChild(percentLabel)
    
    app:setRoot(panel)
    
    -- Return controller
    return {
        update = function(self, progressValue, newMessage)
            progress:setProgress(progressValue)
            percentLabel:setText(string.format("%d%%", math.floor(progressValue * 100)))
            if newMessage then
                messageLabel:setText(newMessage)
            end
            app:draw()
        end,
        
        close = function(self)
            app:stop()
        end,
        
        app = app
    }
end

--- Show an error dialog
--- @param title string Dialog title
--- @param errorMessage string Error message
--- @param callback function Optional callback when closed
function Dialog.error(title, errorMessage, callback)
    Dialog.message(title, errorMessage, "OK", callback)
end

--- Show a warning dialog
--- @param title string Dialog title
--- @param warningMessage string Warning message
--- @param callback function Optional callback when closed
function Dialog.warning(title, warningMessage, callback)
    Dialog.message(title, warningMessage, "OK", callback)
end

--- Show an info dialog
--- @param title string Dialog title
--- @param infoMessage string Info message
--- @param callback function Optional callback when closed
function Dialog.info(title, infoMessage, callback)
    Dialog.message(title, infoMessage, "OK", callback)
end

return Dialog
