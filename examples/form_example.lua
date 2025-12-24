--- Input Form Example
--- Demonstrates input fields and form handling

local sgl = require("sgl")

-- Create application
local app = sgl.createApplication("Form Example")

-- Create root panel
local root = sgl.Panel:new(1, 1, 51, 19)
root:setTitle("Registration Form")
root:setBorder(true)

-- Add form labels and inputs
local nameLabel = sgl.Label:new(2, 2, "Name:", 20)
root:addChild(nameLabel)

local nameInput = sgl.Input:new(2, 3, 45, "Enter your name")
root:addChild(nameInput)

local emailLabel = sgl.Label:new(2, 5, "Email:", 20)
root:addChild(emailLabel)

local emailInput = sgl.Input:new(2, 6, 45, "your@email.com")
root:addChild(emailInput)

local passwordLabel = sgl.Label:new(2, 8, "Password:", 20)
root:addChild(passwordLabel)

local passwordInput = sgl.Input:new(2, 9, 45)
passwordInput:setMasked(true)
passwordInput:setPlaceholder("Enter password")
root:addChild(passwordInput)

-- Add checkboxes
local termsCheckbox = sgl.Checkbox:new(2, 11, "I agree to the terms", false)
root:addChild(termsCheckbox)

local newsletterCheckbox = sgl.Checkbox:new(2, 12, "Subscribe to newsletter", true)
root:addChild(newsletterCheckbox)

-- Add result label
local resultLabel = sgl.Label:new(2, 14, "", 45)
resultLabel:setAlign("center")
root:addChild(resultLabel)

-- Add submit button
local submitButton = sgl.Button:new(5, 16, 20, 3, "Submit")
submitButton.style.bgColor = colors.green
submitButton.onClick = function()
    if not termsCheckbox:isChecked() then
        resultLabel:setText("Please accept the terms!")
        resultLabel.style.fgColor = colors.red
    elseif #nameInput:getText() == 0 then
        resultLabel:setText("Please enter your name!")
        resultLabel.style.fgColor = colors.red
    else
        resultLabel:setText("Form submitted successfully!")
        resultLabel.style.fgColor = colors.lime
    end
    root:markDirty()
end
root:addChild(submitButton)

-- Add cancel button
local cancelButton = sgl.Button:new(27, 16, 20, 3, "Cancel")
cancelButton.style.bgColor = colors.red
cancelButton.onClick = function()
    app:stop()
end
root:addChild(cancelButton)

-- Set initial focus
app:setRoot(root)
app:setFocus(nameInput)
app:run()

-- Cleanup
term.clear()
term.setCursorPos(1, 1)
print("Form closed!")
