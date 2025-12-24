--- Theme system for CC-SGL
--- Provides customizable color schemes and styles
local utils = require("src.core.utils")

local Theme = {}

-- Default dark theme
Theme.dark = {
    name = "Dark",
    
    -- General
    background = colors.black,
    foreground = colors.white,
    
    -- Primary colors
    primary = colors.blue,
    primaryDark = colors.blue,
    primaryLight = colors.lightBlue,
    
    -- Secondary colors
    secondary = colors.gray,
    secondaryDark = colors.gray,
    secondaryLight = colors.lightGray,
    
    -- State colors
    success = colors.lime,
    warning = colors.yellow,
    error = colors.red,
    info = colors.cyan,
    
    -- Text colors
    textPrimary = colors.white,
    textSecondary = colors.lightGray,
    textDisabled = colors.gray,
    
    -- Component-specific
    button = {
        bgColor = colors.gray,
        fgColor = colors.white,
        focusBgColor = colors.lightGray,
        pressedBgColor = colors.gray,
        disabledBgColor = colors.gray,
        disabledFgColor = colors.lightGray
    },
    
    input = {
        bgColor = colors.black,
        fgColor = colors.white,
        focusBgColor = colors.gray,
        placeholderColor = colors.lightGray,
        cursorColor = colors.white
    },
    
    panel = {
        bgColor = colors.black,
        borderColor = colors.gray,
        titleBgColor = colors.gray,
        titleFgColor = colors.white
    },
    
    list = {
        bgColor = colors.black,
        fgColor = colors.white,
        selectedBgColor = colors.blue,
        selectedFgColor = colors.white,
        hoverBgColor = colors.gray
    },
    
    checkbox = {
        bgColor = colors.black,
        fgColor = colors.white,
        checkColor = colors.lime,
        boxColor = colors.gray
    },
    
    radio = {
        bgColor = colors.black,
        fgColor = colors.white,
        selectColor = colors.lime,
        circleColor = colors.gray
    },
    
    slider = {
        bgColor = colors.gray,
        fgColor = colors.white,
        fillColor = colors.blue,
        handleColor = colors.lightBlue
    },
    
    progressBar = {
        bgColor = colors.gray,
        fillColor = colors.lime,
        textColor = colors.white
    }
}

-- Light theme
Theme.light = {
    name = "Light",
    
    -- General
    background = colors.white,
    foreground = colors.black,
    
    -- Primary colors
    primary = colors.blue,
    primaryDark = colors.blue,
    primaryLight = colors.lightBlue,
    
    -- Secondary colors
    secondary = colors.lightGray,
    secondaryDark = colors.gray,
    secondaryLight = colors.white,
    
    -- State colors
    success = colors.lime,
    warning = colors.orange,
    error = colors.red,
    info = colors.cyan,
    
    -- Text colors
    textPrimary = colors.black,
    textSecondary = colors.gray,
    textDisabled = colors.lightGray,
    
    -- Component-specific
    button = {
        bgColor = colors.lightGray,
        fgColor = colors.black,
        focusBgColor = colors.gray,
        pressedBgColor = colors.gray,
        disabledBgColor = colors.lightGray,
        disabledFgColor = colors.gray
    },
    
    input = {
        bgColor = colors.white,
        fgColor = colors.black,
        focusBgColor = colors.lightGray,
        placeholderColor = colors.gray,
        cursorColor = colors.black
    },
    
    panel = {
        bgColor = colors.white,
        borderColor = colors.gray,
        titleBgColor = colors.lightGray,
        titleFgColor = colors.black
    },
    
    list = {
        bgColor = colors.white,
        fgColor = colors.black,
        selectedBgColor = colors.blue,
        selectedFgColor = colors.white,
        hoverBgColor = colors.lightGray
    },
    
    checkbox = {
        bgColor = colors.white,
        fgColor = colors.black,
        checkColor = colors.green,
        boxColor = colors.gray
    },
    
    radio = {
        bgColor = colors.white,
        fgColor = colors.black,
        selectColor = colors.green,
        circleColor = colors.gray
    },
    
    slider = {
        bgColor = colors.lightGray,
        fgColor = colors.black,
        fillColor = colors.blue,
        handleColor = colors.lightBlue
    },
    
    progressBar = {
        bgColor = colors.lightGray,
        fillColor = colors.green,
        textColor = colors.black
    }
}

-- Blue theme
Theme.blue = {
    name = "Blue",
    
    -- General
    background = colors.black,
    foreground = colors.white,
    
    -- Primary colors
    primary = colors.blue,
    primaryDark = colors.blue,
    primaryLight = colors.lightBlue,
    
    -- Secondary colors
    secondary = colors.cyan,
    secondaryDark = colors.cyan,
    secondaryLight = colors.lightBlue,
    
    -- State colors
    success = colors.lime,
    warning = colors.yellow,
    error = colors.red,
    info = colors.lightBlue,
    
    -- Text colors
    textPrimary = colors.white,
    textSecondary = colors.lightBlue,
    textDisabled = colors.gray,
    
    -- Component-specific
    button = {
        bgColor = colors.blue,
        fgColor = colors.white,
        focusBgColor = colors.lightBlue,
        pressedBgColor = colors.blue,
        disabledBgColor = colors.gray,
        disabledFgColor = colors.lightGray
    },
    
    input = {
        bgColor = colors.black,
        fgColor = colors.white,
        focusBgColor = colors.blue,
        placeholderColor = colors.lightBlue,
        cursorColor = colors.white
    },
    
    panel = {
        bgColor = colors.black,
        borderColor = colors.blue,
        titleBgColor = colors.blue,
        titleFgColor = colors.white
    },
    
    list = {
        bgColor = colors.black,
        fgColor = colors.white,
        selectedBgColor = colors.blue,
        selectedFgColor = colors.white,
        hoverBgColor = colors.cyan
    },
    
    checkbox = {
        bgColor = colors.black,
        fgColor = colors.white,
        checkColor = colors.lightBlue,
        boxColor = colors.blue
    },
    
    radio = {
        bgColor = colors.black,
        fgColor = colors.white,
        selectColor = colors.lightBlue,
        circleColor = colors.blue
    },
    
    slider = {
        bgColor = colors.gray,
        fgColor = colors.white,
        fillColor = colors.blue,
        handleColor = colors.lightBlue
    },
    
    progressBar = {
        bgColor = colors.gray,
        fillColor = colors.blue,
        textColor = colors.white
    }
}

-- Current active theme
Theme.current = Theme.dark

--- Apply a theme to a component
--- @param component Component Component to apply theme to
--- @param theme table Theme to apply
function Theme.applyToComponent(component, theme)
    theme = theme or Theme.current
    
    -- Determine component type and apply appropriate theme
    local componentType = component.class and component.class.name or "unknown"
    
    if theme[componentType] then
        component:setStyle(theme[componentType])
    else
        -- Apply general theme colors
        if component.style then
            if theme.background then
                component.style.bgColor = theme.background
            end
            if theme.foreground then
                component.style.fgColor = theme.foreground
            end
        end
    end
    
    -- Recursively apply to children
    if component.children then
        for _, child in ipairs(component.children) do
            Theme.applyToComponent(child, theme)
        end
    end
end

--- Set the current theme
--- @param theme table Theme to set as current
function Theme.setCurrent(theme)
    Theme.current = theme
end

--- Get the current theme
--- @return table Current theme
function Theme.getCurrent()
    return Theme.current
end

--- Create a custom theme
--- @param baseTheme table Base theme to extend
--- @param overrides table Table of overrides
--- @return table New theme
function Theme.create(baseTheme, overrides)
    local newTheme = utils.deepCopy(baseTheme or Theme.dark)
    
    if overrides then
        for k, v in pairs(overrides) do
            if type(v) == "table" and type(newTheme[k]) == "table" then
                newTheme[k] = utils.merge(newTheme[k], v)
            else
                newTheme[k] = v
            end
        end
    end
    
    return newTheme
end

--- Get a list of built-in themes
--- @return table Array of theme names
function Theme.getBuiltInThemes()
    return {"dark", "light", "blue"}
end

--- Get a built-in theme by name
--- @param name string Theme name
--- @return table Theme or nil if not found
function Theme.getByName(name)
    return Theme[name]
end

return Theme
