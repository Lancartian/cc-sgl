--- Utility functions for CC-SGL
local utils = {}

--- Deep copy a table
--- @param orig table Table to copy
--- @return table Copied table
function utils.deepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[utils.deepCopy(orig_key)] = utils.deepCopy(orig_value)
        end
        setmetatable(copy, utils.deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

--- Merge two tables (shallow merge)
--- @param t1 table First table
--- @param t2 table Second table
--- @return table Merged table
function utils.merge(t1, t2)
    local result = {}
    for k, v in pairs(t1) do
        result[k] = v
    end
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

--- Clamp a value between min and max
--- @param value number Value to clamp
--- @param min number Minimum value
--- @param max number Maximum value
--- @return number Clamped value
function utils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

--- Linear interpolation
--- @param a number Start value
--- @param b number End value
--- @param t number Interpolation factor (0-1)
--- @return number Interpolated value
function utils.lerp(a, b, t)
    return a + (b - a) * t
end

--- Round a number to nearest integer
--- @param num number Number to round
--- @return number Rounded number
function utils.round(num)
    return math.floor(num + 0.5)
end

--- Split a string by delimiter
--- @param str string String to split
--- @param delimiter string Delimiter
--- @return table Array of split strings
function utils.split(str, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    for match in string.gmatch(str, pattern) do
        table.insert(result, match)
    end
    return result
end

--- Trim whitespace from string
--- @param str string String to trim
--- @return string Trimmed string
function utils.trim(str)
    return str:match("^%s*(.-)%s*$")
end

--- Wrap text to fit within a specific width
--- @param text string Text to wrap
--- @param width number Maximum width
--- @return table Array of wrapped lines
function utils.wrapText(text, width)
    local lines = {}
    local words = utils.split(text, " ")
    local currentLine = ""
    
    for _, word in ipairs(words) do
        if #currentLine + #word + 1 <= width then
            if #currentLine > 0 then
                currentLine = currentLine .. " " .. word
            else
                currentLine = word
            end
        else
            if #currentLine > 0 then
                table.insert(lines, currentLine)
            end
            currentLine = word
        end
    end
    
    if #currentLine > 0 then
        table.insert(lines, currentLine)
    end
    
    return lines
end

--- Generate a unique ID
local idCounter = 0
function utils.generateId()
    idCounter = idCounter + 1
    return "sgl_" .. idCounter
end

--- Check if a value is in a table
--- @param tbl table Table to search
--- @param value any Value to find
--- @return boolean True if value is in table
function utils.contains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

--- Get table size
--- @param tbl table Table to measure
--- @return number Size of table
function utils.tableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

--- Create a simple class system
--- @param base table Optional base class
--- @return table New class
function utils.class(base)
    local c = {}
    
    if base then
        for k, v in pairs(base) do
            c[k] = v
        end
        c._base = base
    end
    
    c.__index = c
    
    function c:new(...)
        local instance = setmetatable({}, c)
        if instance.init then
            instance:init(...)
        end
        return instance
    end
    
    return c
end

--- Safe color conversion for non-color terminals
--- @param color number Color value
--- @return number Color value or white for non-color terminals
function utils.safeColor(color)
    if term.isColor() then
        return color
    end
    return colors.white
end

--- Parse a hex color string to ComputerCraft color
--- @param hex string Hex color string (e.g., "FF0000")
--- @return number Closest ComputerCraft color
function utils.hexToColor(hex)
    -- This is a simple approximation since CC has limited colors
    -- Map common colors to CC colors
    local colorMap = {
        ["000000"] = colors.black,
        ["FFFFFF"] = colors.white,
        ["FF0000"] = colors.red,
        ["00FF00"] = colors.lime,
        ["0000FF"] = colors.blue,
        ["FFFF00"] = colors.yellow,
        ["FF00FF"] = colors.magenta,
        ["00FFFF"] = colors.cyan,
        ["FFA500"] = colors.orange,
        ["800080"] = colors.purple,
        ["808080"] = colors.gray,
        ["C0C0C0"] = colors.lightGray,
        ["008000"] = colors.green,
        ["A52A2A"] = colors.brown,
        ["FFC0CB"] = colors.pink,
        ["ADD8E6"] = colors.lightBlue,
    }
    
    hex = hex:upper():gsub("#", "")
    return colorMap[hex] or colors.white
end

--- Validate email format
--- @param email string Email to validate
--- @return boolean True if valid email format
function utils.isValidEmail(email)
    return email:match("^[%w%.%-_]+@[%w%.%-_]+%.%w+$") ~= nil
end

--- Format a number with commas
--- @param num number Number to format
--- @return string Formatted number
function utils.formatNumber(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

--- Create a timer that can be checked
--- @param duration number Duration in seconds
--- @return table Timer object
function utils.createTimer(duration)
    return {
        startTime = os.clock(),
        duration = duration,
        isExpired = function(self)
            return os.clock() - self.startTime >= self.duration
        end,
        reset = function(self)
            self.startTime = os.clock()
        end,
        getRemaining = function(self)
            return math.max(0, self.duration - (os.clock() - self.startTime))
        end
    }
end

return utils
