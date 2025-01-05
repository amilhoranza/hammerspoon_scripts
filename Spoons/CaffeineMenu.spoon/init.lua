local obj = {}
obj.__index = obj

-- Metadata
obj.name = "CaffeineMenu"
obj.version = "1.0"
obj.author = "André Miglioranza"
obj.license = "MIT"

function obj:init()
    self.menubar = hs.menubar.new()
    if self.menubar then
        self.menubar:setClickCallback(function()
            self:toggleCaffeine()
        end)
        self:setDisplay(hs.caffeinate.get("displayIdle"))
    end
    return self
end

function obj:setDisplay(state)
    if state then
        self.menubar:setTitle("AWAKE") 
    else
        self.menubar:setTitle("SLEEPY")
    end
end

function obj:toggleCaffeine()
    self:setDisplay(hs.caffeinate.toggle("displayIdle"))
end

function obj:start()
    return self
end

function obj:stop()
    if self.menubar then
        self.menubar:delete()
        self.menubar = nil
    end
    return self
end

return obj 