--- Advanced Dashboard Example
--- Demonstrates complex layouts, theming, and real-time updates

local sgl = require("sgl")

-- Create application
local app = sgl.createApplication("System Dashboard")

-- Get screen size
local width, height = sgl.renderer.getSize()

-- Create root panel
local root = sgl.Panel:new(1, 1, width, height)
root:setTitle("ComputerCraft System Dashboard")
root:setBorder(true)

-- Top bar panel
local topBar = sgl.Panel:new(2, 2, width - 4, 3)
topBar:setBorder(false)
topBar.style.bgColor = colors.blue
root:addChild(topBar)

local titleLabel = sgl.Label:new(2, 2, "SYSTEM MONITOR v1.0", width - 8)
titleLabel:setAlign("center")
titleLabel.style.fgColor = colors.white
titleLabel.style.bgColor = colors.blue
topBar:addChild(titleLabel)

-- Stats panel (left side)
local statsPanel = sgl.Panel:new(2, 5, math.floor((width - 5) / 2), height - 8)
statsPanel:setTitle("System Stats")
statsPanel:setBorder(true)
root:addChild(statsPanel)

-- CPU usage label
local cpuLabel = sgl.Label:new(2, 2, "CPU Usage:", statsPanel.width - 4)
statsPanel:addChild(cpuLabel)

local cpuProgress = sgl.ProgressBar:new(2, 3, statsPanel.width - 4, 1)
cpuProgress:setProgress(0)
cpuProgress.style.fillColor = colors.lime
statsPanel:addChild(cpuProgress)

-- Memory label
local memLabel = sgl.Label:new(2, 5, "Memory:", statsPanel.width - 4)
statsPanel:addChild(memLabel)

local memProgress = sgl.ProgressBar:new(2, 6, statsPanel.width - 4, 1)
memProgress:setProgress(0)
memProgress.style.fillColor = colors.yellow
statsPanel:addChild(memProgress)

-- Disk label
local diskLabel = sgl.Label:new(2, 8, "Disk:", statsPanel.width - 4)
statsPanel:addChild(diskLabel)

local diskProgress = sgl.ProgressBar:new(2, 9, statsPanel.width - 4, 1)
diskProgress:setProgress(0)
diskProgress.style.fillColor = colors.orange
statsPanel:addChild(diskProgress)

-- Control panel (right side)
local controlPanel = sgl.Panel:new(math.floor((width - 5) / 2) + 3, 5, 
                                   math.floor((width - 5) / 2), height - 8)
controlPanel:setTitle("Controls")
controlPanel:setBorder(true)
root:addChild(controlPanel)

-- Theme selector
local themeLabel = sgl.Label:new(2, 2, "Theme:", controlPanel.width - 4)
controlPanel:addChild(themeLabel)

local currentTheme = "dark"
local themes = {"dark", "light", "blue"}
local themeIndex = 1

local themeRadios = {}
for i, themeName in ipairs(themes) do
    local radio = sgl.Radio:new(2, 3 + i - 1, themeName:sub(1,1):upper() .. themeName:sub(2), 
                               "theme", themeName == currentTheme)
    radio.onChanged = function(selected)
        if selected then
            local theme = sgl.Theme.getByName(themeName)
            if theme then
                sgl.Theme.setCurrent(theme)
                sgl.Theme.applyToComponent(root, theme)
                root:markDirty()
            end
        end
    end
    controlPanel:addChild(radio)
    themeRadios[themeName] = radio
end

-- Auto-update checkbox
local autoUpdateCheckbox = sgl.Checkbox:new(2, 8, "Auto Update", true)
controlPanel:addChild(autoUpdateCheckbox)

-- Update interval slider
local intervalLabel = sgl.Label:new(2, 10, "Update: 1s", controlPanel.width - 4)
controlPanel:addChild(intervalLabel)

local intervalSlider = sgl.Slider:new(2, 11, controlPanel.width - 4, 1, 10, 2)
intervalSlider.onChanged = function(value)
    intervalLabel:setText(string.format("Update: %ds", math.floor(value)))
end
controlPanel:addChild(intervalSlider)

-- Action buttons
local refreshBtn = sgl.Button:new(2, 13, controlPanel.width - 4, 3, "Refresh Now")
refreshBtn.style.bgColor = colors.green
refreshBtn.onClick = function()
    -- Trigger immediate update
    updateStats()
end
controlPanel:addChild(refreshBtn)

-- Bottom status bar
local statusBar = sgl.Panel:new(2, height - 2, width - 4, 1)
statusBar:setBorder(false)
statusBar.style.bgColor = colors.gray
root:addChild(statusBar)

local statusLabel = sgl.Label:new(1, 1, "Ready", width - 4)
statusLabel.style.bgColor = colors.gray
statusBar:addChild(statusLabel)

-- Update function
local lastUpdate = os.clock()

function updateStats()
    -- Simulate CPU usage (in real app, you'd calculate actual usage)
    local cpuUsage = math.random(10, 90) / 100
    cpuProgress:setProgress(cpuUsage)
    cpuProgress.style.fillColor = cpuUsage > 0.8 and colors.red or 
                                  cpuUsage > 0.5 and colors.yellow or colors.lime
    
    -- Get real memory usage
    local freeMemory = os.getFreeMemory and os.getFreeMemory() or 100000
    local totalMemory = 1000000 -- Approximate
    local memUsage = 1 - (freeMemory / totalMemory)
    memProgress:setProgress(memUsage)
    
    -- Get real disk usage
    local diskFree = fs.getFreeSpace("/")
    local diskTotal = diskFree * 2 -- Rough estimate
    local diskUsage = 1 - (diskFree / diskTotal)
    diskProgress:setProgress(diskUsage)
    
    -- Update status
    local timeStr = textutils.formatTime(os.time(), true)
    statusLabel:setText(string.format("Last update: %s | CPU: %d%% | Mem: %d%% | Disk: %d%%",
                                     timeStr,
                                     math.floor(cpuUsage * 100),
                                     math.floor(memUsage * 100),
                                     math.floor(diskUsage * 100)))
    
    root:markDirty()
    lastUpdate = os.clock()
end

-- Initial update
updateStats()

-- Custom update loop
local updateTimer = os.startTimer(0.1)

sgl.eventManager.on(sgl.EVENT.TIMER, function(data)
    if data.timerId == updateTimer then
        -- Check if we should auto-update
        if autoUpdateCheckbox:isChecked() then
            local interval = intervalSlider:getValue()
            if os.clock() - lastUpdate >= interval then
                updateStats()
            end
        end
        
        -- Restart timer
        updateTimer = os.startTimer(0.1)
    end
end)

-- Add exit button to control panel
local exitBtn = sgl.Button:new(2, controlPanel.height - 4, controlPanel.width - 4, 3, "Exit")
exitBtn.style.bgColor = colors.red
exitBtn.onClick = function()
    os.cancelTimer(updateTimer)
    app:stop()
end
controlPanel:addChild(exitBtn)

-- Run application
app:setRoot(root)
app:run()

-- Cleanup
term.clear()
term.setCursorPos(1, 1)
print("Dashboard closed!")
