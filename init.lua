-- SpoonManager
if hs.loadSpoon("SpoonManager") then
  spoon.SpoonManager:start()
end

-- FinderEnhancer
if hs.loadSpoon("FinderEnhancer") then
    spoon.FinderEnhancer:start()
end

-- CaffeineMenu
if hs.loadSpoon("CaffeineMenu") then
    spoon.CaffeineMenu:start()
end

-- ConfigReloader
if hs.loadSpoon("ConfigReloader") then
    spoon.ConfigReloader:start()
end

-- ShiftIt
if hs.loadSpoon("ShiftIt") then
    spoon.ShiftIt:bindHotkeys({})
end

-- ShortcutCheatSheet
if hs.loadSpoon("ShortcutCheatSheet") then
    spoon.ShortcutCheatSheet:start()
end
