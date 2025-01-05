local obj = {}
obj.__index = obj

-- Metadata
obj.name = "FinderEnhancer"
obj.version = "1.0"
obj.author = "Your Name"
obj.license = "MIT"

function obj:init()
    self.watcher = hs.application.watcher.new(function(appName, eventType, appObject)
        if (eventType == hs.application.watcher.activated) then
            if (appName == "Finder") then
                appObject:selectMenuItem({"Window", "Bring All to Front"})
            end
        end
    end)
    return self
end

function obj:start()
    self.watcher:start()
    return self
end

function obj:stop()
    self.watcher:stop()
    return self
end

return obj