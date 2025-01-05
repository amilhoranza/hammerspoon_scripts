-- Carrega e configura o SpoonManager
local manager = hs.loadSpoon("SpoonManager")
manager:setConfig({
    repositories = {
        {
            name = "Personal Spoons",
            url = "https://github.com/amilhoranza/hammerspoon_scripts",
            branch = "main",
            path = "Spoons"
        }
    },
    checkInterval = 3600 * 12, -- 12 horas
    notifyOnUpdate = true
}):start()

-- Opcional: Adicionar atalho para atualização manual
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "u", function()
    manager:updateSpoons()
end)


-- FinderEnhancer: Brings all Finder windows to front when switching to Finder
-- When you activate Finder, all its windows will automatically come to front
hs.loadSpoon("FinderEnhancer"):start()

-- CaffeineMenu: Prevents your Mac from going to sleep
-- Adds a AWAKE/SLEEPY item to the menu bar that you can click to toggle
hs.loadSpoon("CaffeineMenu"):start()

-- ConfigReloader: Automatically reloads Hammerspoon config when changes are detected
-- No shortcuts - works automatically in the background
hs.loadSpoon("ConfigReloader"):start()

-- ShiftIt: Window management with keyboard shortcuts
-- Default shortcuts (ctrl + alt + cmd):
--   left:  Move window to left half
--   right: Move window to right half
--   up:    Move window to top half
--   down:  Move window to bottom half
--   1:     Move window to top-left quarter
--   2:     Move window to top-right quarter
--   3:     Move window to bottom-left quarter
--   4:     Move window to bottom-right quarter
--   m:     Maximize window
--   f:     Toggle full screen
--   z:     Toggle zoom
--   c:     Center window
--   n:     Move to next screen
--   p:     Move to previous screen
--   =:     Resize window out
--   -:     Resize window in
--   a:     Arrange windows in 4 quarters
--   t:     Arrange windows in 3 columns
hs.loadSpoon("ShiftIt")

-- ShortcutCheatSheet: Displays a cheat sheet of keyboard shortcuts
-- Shows a web view with all the shortcuts when you press Control + Alt + Command + /
hs.loadSpoon("ShortcutCheatSheet"):start()

spoon.ShiftIt:bindHotkeys({})
