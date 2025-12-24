--- Simple Button Example
--- Demonstrates basic button usage in SGL

local sgl = require("sgl")

-- Create application
local app = sgl.createApplication("Button Example")

-- Create root panel
local root = sgl.Panel:new(1, 1, 51, 19)
root:setTitle("Button Demo")
root:setBorder(true)

-- Add title label
local titleLabel = sgl.Label:new(2, 2, "Click the buttons below!", 47)
titleLabel:setAlign("center")
titleLabel.style.fgColor = colors.yellow
root:addChild(titleLabel)

-- Add counter label
local counter = 0
local counterLabel = sgl.Label:new(2, 4, "Click count: 0", 47)
counterLabel:setAlign("center")
root:addChild(counterLabel)

-- Add buttons
local button1 = sgl.Button:new(5, 6, 20, 3, "Click Me!")
button1.onClick = function()
    counter = counter + 1
    counterLabel:setText("Click count: " .. counter)
end
root:addChild(button1)

local button2 = sgl.Button:new(27, 6, 20, 3, "Reset")
button2.onClick = function()
    counter = 0
    counterLabel:setText("Click count: 0")
end
root:addChild(button2)

-- Add themed buttons
local button3 = sgl.Button:new(5, 10, 20, 3, "Theme: Blue")
button3.style.bgColor = colors.blue
button3.style.focusBgColor = colors.lightBlue
button3.onClick = function()
    sgl.Theme.setCurrent(sgl.Theme.blue)
    sgl.Theme.applyToComponent(root, sgl.Theme.blue)
    root:markDirty()
end
root:addChild(button3)

local button4 = sgl.Button:new(27, 10, 20, 3, "Theme: Dark")
button4.style.bgColor = colors.gray
button4.onClick = function()
    sgl.Theme.setCurrent(sgl.Theme.dark)
    sgl.Theme.applyToComponent(root, sgl.Theme.dark)
    root:markDirty()
end
root:addChild(button4)

-- Add exit button
local exitButton = sgl.Button:new(16, 14, 20, 3, "Exit")
exitButton.style.bgColor = colors.red
exitButton.onClick = function()
    app:stop()
end
root:addChild(exitButton)

-- Set root and run
app:setRoot(root)
app:run()

-- Cleanup
term.clear()
term.setCursorPos(1, 1)
print("Thanks for trying CC-SGL!")
