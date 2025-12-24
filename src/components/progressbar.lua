--- Progress bar component
local Component = require("src.components.base")
local renderer = require("src.core.renderer")
local utils = require("src.core.utils")

local ProgressBar = utils.class(Component)

--- Initialize a progress bar
--- @param x number X position
--- @param y number Y position
--- @param width number Width
--- @param height number Height (default 1)
function ProgressBar:init(x, y, width, height)
    Component.init(self, x, y, width, height or 1)
    
    self.progress = 0 -- 0 to 1
    self.showText = true
    self.text = nil -- Custom text (if nil, shows percentage)
    
    self.style.bgColor = colors.gray
    self.style.fgColor = colors.white
    self.style.fillColor = colors.lime
    self.style.textColor = colors.white
end

--- Set progress value
--- @param progress number Progress (0 to 1)
function ProgressBar:setProgress(progress)
    self.progress = utils.clamp(progress, 0, 1)
    self:markDirty()
    
    if self.onProgressChanged then
        self:onProgressChanged(self.progress)
    end
end

--- Get progress value
--- @return number Current progress (0 to 1)
function ProgressBar:getProgress()
    return self.progress
end

--- Set custom text
--- @param text string Custom text to display
function ProgressBar:setText(text)
    self.text = text
    self:markDirty()
end

--- Set whether to show text
--- @param show boolean Whether to show text
function ProgressBar:setShowText(show)
    self.showText = show
    self:markDirty()
end

--- Draw the progress bar
function ProgressBar:draw()
    if not self.visible then
        return
    end
    
    local absX, absY = self:getAbsolutePosition()
    
    -- Draw progress bar
    renderer.drawProgressBar(absX, absY, self.width, self.progress, 
                           self.style.fillColor, self.style.bgColor)
    
    -- Draw text
    if self.showText then
        local displayText = self.text or string.format("%d%%", math.floor(self.progress * 100))
        local textY = absY + math.floor(self.height / 2)
        renderer.drawAlignedText(absX, textY, self.width, displayText, 
                               "center", self.style.textColor, colors.black)
    end
    
    self.dirty = false
end

return ProgressBar
