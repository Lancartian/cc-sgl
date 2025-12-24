--- Component Showcase
--- Demonstrates all available CC-SGL components

local sgl = require("sgl")

-- Create application
local app = sgl.createApplication("CC-SGL Showcase")

-- Create main panel
local root = sgl.Panel:new(1, 1, 51, 19)
root:setTitle("CC-SGL Component Showcase")
root:setBorder(true)

-- Create tabbed interface using panels
local currentTab = 1
local tabs = {"Buttons", "Inputs", "Lists", "Sliders"}

-- Tab buttons
local tabPanel = sgl.Panel:new(2, 2, 47, 3)
tabPanel:setBorder(false)
root:addChild(tabPanel)

local function showTab(tabIndex)
    currentTab = tabIndex
    -- Hide all content panels
    for i = 1, #root.children do
        local child = root.children[i]
        if child.data and child.data.isTabContent then
            child:setVisible(false)
        end
    end
    -- Show selected tab content
    for i = 1, #root.children do
        local child = root.children[i]
        if child.data and child.data.tabIndex == tabIndex then
            child:setVisible(true)
        end
    end
    root:markDirty()
end

-- Create tab buttons
for i, tabName in ipairs(tabs) do
    local btn = sgl.Button:new(2 + (i-1) * 12, 2, 11, 1, tabName)
    btn.onClick = function() showTab(i) end
    tabPanel:addChild(btn)
end

-- Tab 1: Buttons
local tab1 = sgl.Panel:new(2, 5, 47, 12)
tab1:setBorder(false)
tab1.data = {isTabContent = true, tabIndex = 1}
root:addChild(tab1)

local regularBtn = sgl.Button:new(2, 1, 15, 3, "Regular")
tab1:addChild(regularBtn)

local colorBtn = sgl.Button:new(19, 1, 15, 3, "Colored")
colorBtn.style.bgColor = colors.blue
tab1:addChild(colorBtn)

local disabledBtn = sgl.Button:new(36, 1, 11, 3, "Disabled")
disabledBtn:setEnabled(false)
tab1:addChild(disabledBtn)

local statusLabel = sgl.Label:new(2, 5, "Click buttons above!", 43)
statusLabel:setAlign("center")
tab1:addChild(statusLabel)

regularBtn.onClick = function()
    statusLabel:setText("Regular button clicked!")
end

colorBtn.onClick = function()
    statusLabel:setText("Colored button clicked!")
end

-- Tab 2: Inputs
local tab2 = sgl.Panel:new(2, 5, 47, 12)
tab2:setBorder(false)
tab2:setVisible(false)
tab2.data = {isTabContent = true, tabIndex = 2}
root:addChild(tab2)

local input1 = sgl.Input:new(2, 1, 43, "Type something...")
tab2:addChild(input1)

local checkbox1 = sgl.Checkbox:new(2, 3, "Enable feature", true)
tab2:addChild(checkbox1)

local checkbox2 = sgl.Checkbox:new(2, 4, "Debug mode", false)
tab2:addChild(checkbox2)

local radio1 = sgl.Radio:new(2, 6, "Option A", "group1", true)
tab2:addChild(radio1)

local radio2 = sgl.Radio:new(2, 7, "Option B", "group1", false)
tab2:addChild(radio2)

local radio3 = sgl.Radio:new(2, 8, "Option C", "group1", false)
tab2:addChild(radio3)

-- Tab 3: Lists
local tab3 = sgl.Panel:new(2, 5, 47, 12)
tab3:setBorder(false)
tab3:setVisible(false)
tab3.data = {isTabContent = true, tabIndex = 3}
root:addChild(tab3)

local list = sgl.List:new(2, 1, 43, 8)
list:setItems({"Item 1", "Item 2", "Item 3", "Item 4", "Item 5", 
               "Item 6", "Item 7", "Item 8", "Item 9", "Item 10"})
tab3:addChild(list)

local selectedLabel = sgl.Label:new(2, 10, "No selection", 43)
list.onSelectionChanged = function(index, item)
    selectedLabel:setText("Selected: " .. item)
end
tab3:addChild(selectedLabel)

-- Tab 4: Sliders
local tab4 = sgl.Panel:new(2, 5, 47, 12)
tab4:setBorder(false)
tab4:setVisible(false)
tab4.data = {isTabContent = true, tabIndex = 4}
root:addChild(tab4)

local slider1 = sgl.Slider:new(2, 2, 43, 0, 100, 50)
tab4:addChild(slider1)

local sliderLabel = sgl.Label:new(2, 1, "Value: 50", 43)
sliderLabel:setAlign("center")
slider1.onChanged = function(value)
    sliderLabel:setText("Value: " .. math.floor(value))
end
tab4:addChild(sliderLabel)

local progress = sgl.ProgressBar:new(2, 4, 43, 1)
progress:setProgress(0.5)
slider1.onChanged = function(value)
    sliderLabel:setText("Value: " .. math.floor(value))
    progress:setProgress(value / 100)
end
tab4:addChild(progress)

local slider2 = sgl.Slider:new(2, 7, 43, 0, 10, 5)
slider2.style.fillColor = colors.red
tab4:addChild(slider2)

local slider2Label = sgl.Label:new(2, 6, "Red Value: 5", 43)
slider2.onChanged = function(value)
    slider2Label:setText("Red Value: " .. math.floor(value))
end
tab4:addChild(slider2Label)

-- Set root and run
app:setRoot(root)
app:run()

-- Cleanup
term.clear()
term.setCursorPos(1, 1)
print("Showcase closed!")
