--- === SpoonManager ===
---
--- Manages Spoons installation and updates from Git repositories
---

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SpoonManager"
obj.version = "1.0"
obj.author = "Your Name"
obj.license = "MIT"

-- Configurações padrão
obj.defaultConfig = {
    repositories = {
        {
            name = "Personal Spoons",
            url = "https://github.com/amilhoranza/hammerspoon_scripts",
            branch = "main",
            path = "Spoons"
        }
    },
    backupDir = os.getenv("HOME") .. "/.hammerspoon/SpoonBackups",
    checkInterval = 86400, -- 24 horas
    notifyOnUpdate = true
}

function obj:init()
    self.config = self.defaultConfig
    self.timer = nil
    
    -- Cria diretório de backup se não existir
    if not hs.fs.mkdir(self.config.backupDir) then
        hs.notify.new({
            title = "SpoonManager",
            informativeText = "Erro ao criar diretório de backup"
        }):send()
    end
    
    return self
end

function obj:backupCurrentSpoons()
    local backupFolder = string.format("%s/backup_%s", 
        self.config.backupDir, 
        os.date("%Y%m%d_%H%M%S"))
    
    local currentSpoonsPath = hs.spoons.scriptPath():sub(1, -2)
    local command = string.format("cp -R '%s' '%s'", currentSpoonsPath, backupFolder)
    
    if os.execute(command) then
        print("Backup created at: " .. backupFolder)
        return true
    end
    return false
end

function obj:cloneOrPullRepository(repo)
    local tempDir = "/tmp/spoon_update_" .. os.time()
    local success = false
    
    -- Clone repositório
    local cloneCmd = string.format("git clone -b %s %s %s", 
        repo.branch or "main", 
        repo.url, 
        tempDir)
    
    if os.execute(cloneCmd) then
        success = true
    end
    
    return success, tempDir
end

function obj:updateSpoons()
    -- Backup antes de atualizar
    if not self:backupCurrentSpoons() then
        print("Failed to create backup, aborting update")
        return false
    end
    
    local updatedSpoons = {}
    
    for _, repo in ipairs(self.config.repositories) do
        local success, tempDir = self:cloneOrPullRepository(repo)
        
        if success then
            -- Caminho para os Spoons no repositório clonado
            local spoonSourcePath = tempDir .. "/" .. (repo.path or "")
            
            -- Caminho destino dos Spoons
            local spoonDestPath = hs.spoons.scriptPath():sub(1, -2)
            
            -- Copia cada Spoon
            for file in hs.fs.dir(spoonSourcePath) do
                if file:match("%.spoon$") then
                    local sourcePath = spoonSourcePath .. "/" .. file
                    local destPath = spoonDestPath .. "/" .. file
                    
                    -- Remove versão antiga
                    os.execute(string.format("rm -rf '%s'", destPath))
                    
                    -- Copia nova versão
                    if os.execute(string.format("cp -R '%s' '%s'", sourcePath, destPath)) then
                        table.insert(updatedSpoons, file:gsub("%.spoon$", ""))
                    end
                end
            end
            
            -- Limpa diretório temporário
            os.execute(string.format("rm -rf '%s'", tempDir))
        end
    end
    
    -- Notifica sobre atualizações
    if #updatedSpoons > 0 and self.config.notifyOnUpdate then
        hs.notify.new({
            title = "SpoonManager",
            informativeText = string.format("Updated %d Spoons: %s", 
                #updatedSpoons, 
                table.concat(updatedSpoons, ", "))
        }):send()
    end
    
    return true
end

function obj:start()
    self:updateSpoons()
    
    -- Configura timer para atualizações periódicas
    if self.timer then
        self.timer:stop()
    end
    
    self.timer = hs.timer.doEvery(self.config.checkInterval, function()
        self:updateSpoons()
    end)
    
    return self
end

function obj:stop()
    if self.timer then
        self.timer:stop()
        self.timer = nil
    end
    return self
end

function obj:setConfig(config)
    -- Mescla as configurações manualmente
    if config then
        if config.repositories then
            self.config.repositories = config.repositories
        end
        if config.backupDir then
            self.config.backupDir = config.backupDir
        end
        if config.checkInterval then
            self.config.checkInterval = config.checkInterval
        end
        if config.notifyOnUpdate ~= nil then
            self.config.notifyOnUpdate = config.notifyOnUpdate
        end
    end
    return self
end

return obj