local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ConfigReloader"
obj.version = "1.0"
obj.author = "André Miglioranza"
obj.license = "MIT"

function obj:init()
    self.watcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
        local doReload = false
        for _,file in pairs(files) do
            if file:sub(-4) == ".lua" then
                doReload = true
                break
            end
        end
        if doReload then
            hs.reload()
        end
    end)
    
    -- Setup reload hotkey
    self.hotkey = hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
        hs.reload()
    end)
    
    return self
end

function obj:start()
    self.watcher:start()
    hs.alert.show("Config reloaded")
    return self
end

function obj:stop()
    self.watcher:stop()
    self.hotkey:delete()
    return self
end

return obj 