local obj = {}
obj.__index = obj

-- Metadata
obj.name = "KeyboardShortcuts"
obj.version = "1.0"
obj.author = "André Miglioranza"
obj.homepage = "https://github.com/yourusername/KeyboardShortcuts.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Inicializa o Spoon
function obj:init()
    self.shortcuts = {
        screenshot = {
            from = {mods = {"cmd", "shift"}, key = "a"},
            to = {mods = {"cmd", "shift"}, key = "9"}
        },
        screenshot2 = {
            from = {mods = {"cmd", "shift"}, key = "4"},
            to = {mods = {"cmd", "shift"}, key = "9"}
        },
    }
end

-- Inicia o Spoon e configura os atalhos
function obj:start()
    for name, shortcut in pairs(self.shortcuts) do
        hs.hotkey.bind(
            shortcut.from.mods,
            shortcut.from.key,
            function()
                hs.eventtap.keyStroke(shortcut.to.mods, shortcut.to.key)
            end
        )
    end
    return self
end

return obj