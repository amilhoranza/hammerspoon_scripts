-- Carrega e configura o SpoonManager primeiro
print("Carregando SpoonManager...")
local manager = hs.loadSpoon("SpoonManager")
if manager then
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

    -- Atalho para atualização manual
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "u", function()
        manager:updateSpoons()
    end)
end

-- Carrega outros Spoons após o SpoonManager
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
