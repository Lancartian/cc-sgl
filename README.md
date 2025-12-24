# CC-SGL - ComputerCraft Simple Graphics Library

A comprehensive, modular GUI library for ComputerCraft that makes creating beautiful user interfaces easy. Features touchscreen compatibility, rich component library, layout management, theming, and more!

## Features

- **Rich Component Library**: Buttons, labels, input fields, checkboxes, radio buttons, sliders, progress bars, lists, and panels
- **Event Management**: Robust event handling for mouse, keyboard, and touch inputs
- **Layout System**: Automatic positioning with vertical, horizontal, grid, and flex layouts
- **Theme System**: Built-in themes (dark, light, blue) with easy customization
- **Touchscreen Compatible**: Full support for ComputerCraft monitors and touchscreens
- **Modular Architecture**: Clean separation of concerns with clear module boundaries
- **Easy to Use**: Simple API with comprehensive examples

## Installation

### Using the Installer

1. Download the installer:
```
wget https://raw.githubusercontent.com/Lancartian/cc-sgl/main/installer.lua
```

2. Run the installer:
```
installer install
```

### Manual Installation

1. Clone or download the repository
2. Copy the `sgl.lua` file and `src/` directory to your ComputerCraft computer
3. Make sure the files are accessible in your Lua path

## Quick Start

### Hello World Button

```lua
local sgl = require("sgl")

-- Create application
local app = sgl.createApplication("Hello World")

-- Create a panel
local panel = sgl.Panel:new(1, 1, 51, 19)
panel:setTitle("My First App")

-- Add a button
local button = sgl.Button:new(10, 7, 30, 3, "Click Me!")
button.onClick = function()
    print("Button clicked!")
    app:stop()
end
panel:addChild(button)

-- Run the app
app:setRoot(panel)
app:run()
```

### Simple Form

```lua
local sgl = require("sgl")

local app = sgl.createApplication("Login Form")
local root = sgl.Panel:new(1, 1, 40, 15)
root:setTitle("Login")

-- Username input
local usernameLabel = sgl.Label:new(2, 2, "Username:")
root:addChild(usernameLabel)

local usernameInput = sgl.Input:new(2, 3, 35)
root:addChild(usernameInput)

-- Password input
local passwordLabel = sgl.Label:new(2, 5, "Password:")
root:addChild(passwordLabel)

local passwordInput = sgl.Input:new(2, 6, 35)
passwordInput:setMasked(true)
root:addChild(passwordInput)

-- Submit button
local submitBtn = sgl.Button:new(10, 9, 20, 3, "Login")
submitBtn.onClick = function()
    local username = usernameInput:getText()
    local password = passwordInput:getText()
    print("Login attempt:", username)
    app:stop()
end
root:addChild(submitBtn)

app:setRoot(root)
app:setFocus(usernameInput)
app:run()
```

## Components

### Button
Clickable button with customizable text and styling.

```lua
local button = sgl.Button:new(x, y, width, height, "Button Text")
button.onClick = function()
    print("Clicked!")
end
button.style.bgColor = colors.blue
```

### Label
Text display with alignment options.

```lua
local label = sgl.Label:new(x, y, "Hello World", width)
label:setAlign("center") -- "left", "center", "right"
label.style.fgColor = colors.yellow
```

### Input
Text input field with placeholder, masking, and validation.

```lua
local input = sgl.Input:new(x, y, width, "Placeholder")
input:setMasked(true) -- For passwords
input:setMaxLength(20)
input.onTextChanged = function(text)
    print("Text:", text)
end
input.onSubmit = function(text)
    print("Submitted:", text)
end
```

### Panel
Container for organizing other components.

```lua
local panel = sgl.Panel:new(x, y, width, height)
panel:setTitle("My Panel")
panel:setBorder(true)
panel:addChild(someComponent)
```

### Checkbox
Toggle-able checkbox with label.

```lua
local checkbox = sgl.Checkbox:new(x, y, "Enable feature", false)
checkbox.onChanged = function(checked)
    print("Checked:", checked)
end
```

### Radio Button
Radio button for mutually exclusive selections.

```lua
local radio1 = sgl.Radio:new(x, y, "Option 1", "group1", true)
local radio2 = sgl.Radio:new(x, y+1, "Option 2", "group1", false)
radio1.onChanged = function(selected)
    print("Radio 1 selected:", selected)
end
```

### Slider
Draggable slider for value selection.

```lua
local slider = sgl.Slider:new(x, y, width, min, max, initialValue)
slider:setStep(1)
slider.onChanged = function(value)
    print("Value:", value)
end
```

### Progress Bar
Visual progress indicator.

```lua
local progress = sgl.ProgressBar:new(x, y, width, height)
progress:setProgress(0.5) -- 0 to 1
progress:setText("Loading...") -- Custom text
```

### List
Scrollable list of items with selection.

```lua
local list = sgl.List:new(x, y, width, height)
list:setItems({"Item 1", "Item 2", "Item 3"})
list.onSelectionChanged = function(index, item)
    print("Selected:", item)
end
list.onItemClick = function(index, item)
    print("Clicked:", item)
end
```

## Layout System

### Vertical Layout
Stack components vertically.

```lua
sgl.Layout.vertical(container, spacing, padding)
```

### Horizontal Layout
Arrange components horizontally.

```lua
sgl.Layout.horizontal(container, spacing, padding)
```

### Grid Layout
Arrange in a grid pattern.

```lua
sgl.Layout.grid(container, columns, spacing, padding)
```

### Center Layout
Center a component in its container.

```lua
sgl.Layout.center(container, child, horizontal, vertical)
```

### Flex Layout
Evenly distribute space.

```lua
sgl.Layout.flex(container, "horizontal", spacing, padding)
```

## Theme System

### Using Built-in Themes

```lua
-- Set theme
sgl.Theme.setCurrent(sgl.Theme.dark)  -- or .light, .blue

-- Apply theme to component tree
sgl.Theme.applyToComponent(rootComponent)
```

### Creating Custom Themes

```lua
local myTheme = sgl.Theme.create(sgl.Theme.dark, {
    primary = colors.purple,
    button = {
        bgColor = colors.purple,
        focusBgColor = colors.pink
    }
})

sgl.Theme.setCurrent(myTheme)
```

## Event Handling

### Using Events Directly

```lua
local eventManager = sgl.eventManager

-- Listen for mouse clicks
eventManager.on(sgl.EVENT.MOUSE_CLICK, function(data)
    print("Click at", data.x, data.y)
end)

-- Listen for key presses
eventManager.on(sgl.EVENT.KEY, function(data)
    print("Key pressed:", data.key)
end)

-- Run event loop
eventManager.run()
```

## Utilities

### Dialog Boxes

```lua
-- Message box
sgl.messageBox("Info", "This is a message")

-- Confirmation dialog
sgl.confirm("Confirm", "Are you sure?", function(confirmed)
    if confirmed then
        print("Confirmed!")
    end
end)

-- Input dialog
sgl.input("Name", "Enter your name:", "Default", function(value)
    if value then
        print("Name:", value)
    end
end)
```

## Advanced Usage

### Custom Components

```lua
local MyComponent = sgl.utils.class(sgl.Component)

function MyComponent:init(x, y)
    sgl.Component.init(self, x, y, 20, 5)
    self.customData = "Hello"
end

function MyComponent:draw()
    if not self.visible then return end
    
    local absX, absY = self:getAbsolutePosition()
    sgl.renderer.drawRect(absX, absY, self.width, self.height, colors.blue)
    sgl.renderer.drawText(absX, absY, self.customData, colors.white, colors.blue)
    
    self.dirty = false
end

-- Use it
local myComp = MyComponent:new(5, 5)
```

### Monitor Support

```lua
-- Redirect to a monitor
local monitor = peripheral.find("monitor")
if monitor then
    sgl.init({ terminal = monitor })
    -- Now create your application
end
```

### Integration with cc-vimg

```lua
-- Assuming cc-vimg is installed
local vimg = require("vimg")
local sgl = require("sgl")

-- Load and display an image in a custom component
local ImageComponent = sgl.utils.class(sgl.Component)

function ImageComponent:init(x, y, imagePath)
    sgl.Component.init(self, x, y, 20, 10)
    self.image = vimg.load(imagePath)
end

function ImageComponent:draw()
    if self.image then
        vimg.draw(self.image, self.x, self.y)
    end
end
```

## Examples

The library comes with several complete examples:

- `examples/button_example.lua` - Basic button interactions
- `examples/form_example.lua` - Form with input validation
- `examples/showcase.lua` - Complete component showcase

Run them with:
```lua
examples/button_example
```

## API Reference

### Application Methods

- `app:setRoot(component)` - Set the root component
- `app:setFocus(component)` - Set focused component
- `app:run()` - Start the application
- `app:stop()` - Stop the application
- `app:setFPS(fps)` - Set target frames per second

### Component Methods

All components inherit from base Component:

- `component:setPosition(x, y)` - Set position
- `component:setSize(width, height)` - Set size
- `component:setVisible(visible)` - Set visibility
- `component:setEnabled(enabled)` - Set enabled state
- `component:setFocus(focused)` - Set focus state
- `component:addChild(child)` - Add child component
- `component:removeChild(child)` - Remove child
- `component:setStyle(styleTable)` - Update styles
- `component:markDirty()` - Mark for redraw

## Performance Tips

1. **Minimize redraws**: Only call `markDirty()` when necessary
2. **Use panels**: Group related components in panels
3. **Batch updates**: Update multiple properties before marking dirty
4. **Event handlers**: Keep event handlers lightweight
5. **Monitor FPS**: Adjust FPS with `app:setFPS()` for your needs

## Troubleshooting

### Components not showing
- Ensure component is added to root: `root:addChild(component)`
- Check visibility: `component:setVisible(true)`
- Verify position is within screen bounds

### Events not working
- Make sure application is running: `app:run()`
- Check component is enabled: `component:setEnabled(true)`
- For input, ensure component is focused: `app:setFocus(component)`

### Styling not applying
- Use colors from ComputerCraft: `colors.red`, not `"red"`
- Call `markDirty()` after style changes
- For theme changes, use `Theme.applyToComponent()`

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

MIT License - See LICENSE file for details

## Credits

Created for the ComputerCraft community. Compatible with CC:Tweaked.

Special thanks to the ComputerCraft community for their continued support and feedback!
