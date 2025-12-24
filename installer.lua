--- CC-SGL Installer
--- Handles installation, updating, and uninstallation of CC-SGL
local installer = {}

installer.VERSION = "1.0.0"
installer.REPO_URL = "https://raw.githubusercontent.com/Lancartian/cc-sgl/main/"
installer.INSTALL_PATH = "/lib/sgl/"

-- File structure to download
installer.FILES = {
    "sgl.lua",
    "src/core/renderer.lua",
    "src/core/utils.lua",
    "src/core/application.lua",
    "src/core/dialog.lua",
    "src/events/eventManager.lua",
    "src/components/base.lua",
    "src/components/label.lua",
    "src/components/button.lua",
    "src/components/input.lua",
    "src/components/panel.lua",
    "src/components/checkbox.lua",
    "src/components/radio.lua",
    "src/components/slider.lua",
    "src/components/progressbar.lua",
    "src/components/list.lua",
    "src/components/menu.lua",
    "src/layout/layout.lua",
    "src/theme/theme.lua"
}

--- Print colored message
local function printColored(text, color)
    if term.isColor() then
        term.setTextColor(color)
    end
    print(text)
    if term.isColor() then
        term.setTextColor(colors.white)
    end
end

--- Print success message
local function printSuccess(text)
    printColored("[SUCCESS] " .. text, colors.lime)
end

--- Print error message
local function printError(text)
    printColored("[ERROR] " .. text, colors.red)
end

--- Print info message
local function printInfo(text)
    printColored("[INFO] " .. text, colors.cyan)
end

--- Print warning message
local function printWarning(text)
    printColored("[WARNING] " .. text, colors.yellow)
end

--- Download a file from URL
--- @param url string URL to download from
--- @return string Content of file or nil on error
local function downloadFile(url)
    if not http then
        printError("HTTP API is not enabled!")
        return nil
    end
    
    local response = http.get(url)
    if not response then
        return nil
    end
    
    local content = response.readAll()
    response.close()
    return content
end

--- Ensure directory exists
--- @param path string Directory path
local function ensureDirectory(path)
    if not fs.exists(path) then
        fs.makeDir(path)
    end
end

--- Write file with content
--- @param path string File path
--- @param content string File content
--- @return boolean Success
local function writeFile(path, content)
    -- Ensure parent directory exists
    local dir = fs.getDir(path)
    if dir ~= "" then
        ensureDirectory(dir)
    end
    
    local file = fs.open(path, "w")
    if not file then
        return false
    end
    
    file.write(content)
    file.close()
    return true
end

--- Check if SGL is installed
--- @return boolean True if installed
function installer.isInstalled()
    return fs.exists(installer.INSTALL_PATH .. "sgl.lua")
end

--- Get installed version
--- @return string Version string or nil if not installed
function installer.getInstalledVersion()
    if not installer.isInstalled() then
        return nil
    end
    
    -- Try to load and get version
    local oldPath = shell and shell.path() or ""
    if shell then
        shell.setPath(oldPath .. ":" .. installer.INSTALL_PATH)
    end
    
    local success, sgl = pcall(require, "sgl")
    
    if shell then
        shell.setPath(oldPath)
    end
    
    if success and sgl and sgl._VERSION then
        return sgl._VERSION
    end
    
    return "unknown"
end

--- Install SGL
--- @param customPath string Optional custom installation path
--- @return boolean Success
function installer.install(customPath)
    local installPath = customPath or installer.INSTALL_PATH
    
    printInfo("Installing SGL to " .. installPath)
    printInfo("This may take a moment...")
    
    -- Check if already installed
    if fs.exists(installPath .. "sgl.lua") then
        printWarning("SGL appears to be already installed.")
        print("Do you want to reinstall? (y/n)")
        local response = read()
        if response:lower() ~= "y" then
            printInfo("Installation cancelled.")
            return false
        end
    end
    
    -- Create base directory
    ensureDirectory(installPath)
    
    -- Download and install each file
    local successCount = 0
    local failCount = 0
    
    for i, file in ipairs(installer.FILES) do
        local url = installer.REPO_URL .. file
        local targetPath = installPath .. file
        
        printInfo(string.format("[%d/%d] Downloading %s...", i, #installer.FILES, file))
        
        local content = downloadFile(url)
        if content then
            if writeFile(targetPath, content) then
                successCount = successCount + 1
            else
                printError("Failed to write " .. file)
                failCount = failCount + 1
            end
        else
            printError("Failed to download " .. file)
            failCount = failCount + 1
        end
    end
    
    -- Summary
    print("")
    if failCount == 0 then
        printSuccess("Installation complete!")
        printSuccess(string.format("Successfully installed %d files.", successCount))
        print("")
        printInfo("To use SGL in your programs, add this line:")
        print('  local sgl = require("sgl")')
        print("")
        printInfo("Make sure your shell path includes: " .. installPath)
        return true
    else
        printError("Installation completed with errors.")
        printError(string.format("%d files succeeded, %d files failed.", successCount, failCount))
        return false
    end
end

--- Uninstall SGL
--- @return boolean Success
function installer.uninstall()
    if not installer.isInstalled() then
        printWarning("SGL is not installed.")
        return false
    end
    
    printWarning("This will remove SGL from your system.")
    print("Are you sure you want to continue? (y/n)")
    local response = read()
    
    if response:lower() ~= "y" then
        printInfo("Uninstallation cancelled.")
        return false
    end
    
    printInfo("Uninstalling SGL...")
    
    -- Remove installation directory
    if fs.exists(installer.INSTALL_PATH) then
        fs.delete(installer.INSTALL_PATH)
        printSuccess("SGL has been uninstalled successfully.")
        return true
    else
        printError("Failed to uninstall SGL.")
        return false
    end
end

--- Update SGL
--- @return boolean Success
function installer.update()
    if not installer.isInstalled() then
        printError("CC-SGL is not installed. Use 'install' instead.")
        return false
    end
    
    local currentVersion = installer.getInstalledVersion()
    printInfo("Current version: " .. (currentVersion or "unknown"))
    printInfo("Updating to latest version...")
    
    -- Backup current installation
    local backupPath = installer.INSTALL_PATH .. ".backup"
    if fs.exists(backupPath) then
        fs.delete(backupPath)
    end
    
    fs.copy(installer.INSTALL_PATH, backupPath)
    printInfo("Created backup at " .. backupPath)
    
    -- Perform installation
    local success = installer.install(installer.INSTALL_PATH)
    
    if success then
        printSuccess("Update complete!")
        -- Remove backup
        fs.delete(backupPath)
    else
        printError("Update failed! Restoring from backup...")
        fs.delete(installer.INSTALL_PATH)
        fs.move(backupPath, installer.INSTALL_PATH)
        printInfo("Backup restored.")
    end
    
    return success
end

--- Show status
function installer.status()
    print("CC-SGL Status")
    print(string.rep("-", 40))
    
    if installer.isInstalled() then
        printSuccess("Status: Installed")
        print("Version: " .. (installer.getInstalledVersion() or "unknown"))
        print("Location: " .. installer.INSTALL_PATH)
        
        -- Count installed files
        local fileCount = 0
        for _, file in ipairs(installer.FILES) do
            if fs.exists(installer.INSTALL_PATH .. file) then
                fileCount = fileCount + 1
            end
        end
        print(string.format("Files: %d/%d", fileCount, #installer.FILES))
    else
        printWarning("Status: Not Installed")
        print("Run 'sgl-installer install' to install CC-SGL")
    end
end

--- Show help
function installer.help()
    print("CC-SGL Installer v" .. installer.VERSION)
    print(string.rep("-", 40))
    print("Usage: sgl-installer <command>")
    print("")
    print("Commands:")
    print("  install  - Install CC-SGL")
    print("  update   - Update CC-SGL to latest version")
    print("  uninstall- Remove CC-SGL from system")
    print("  status   - Show installation status")
    print("  help     - Show this help message")
end

--- Main installer entry point
function installer.main(args)
    args = args or {...}
    
    if #args == 0 then
        installer.help()
        return
    end
    
    local command = args[1]:lower()
    
    if command == "install" then
        installer.install()
    elseif command == "update" then
        installer.update()
    elseif command == "uninstall" then
        installer.uninstall()
    elseif command == "status" then
        installer.status()
    elseif command == "help" then
        installer.help()
    else
        printError("Unknown command: " .. command)
        installer.help()
    end
end

-- Run if executed directly
if not ... then
    installer.main({...})
end

return installer
