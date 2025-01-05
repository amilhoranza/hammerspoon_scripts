--- === SpoonManager ===
---
--- Manages Spoons installation and updates from Git repositories
---

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SpoonManager"
obj.version = "1.0"
obj.author = "André Miglioranza"
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

function obj:createProgressWindow()
    -- Inicializa o buffer de log
    self.logBuffer = {}
    
    local html = [[
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Helvetica Neue", Arial;
                    margin: 0;
                    padding: 20px;
                    background: #1E1E1E;
                    color: #FFFFFF;
                }
                .header {
                    font-size: 18px;
                    font-weight: bold;
                    margin-bottom: 15px;
                    color: #FFFFFF;
                    background: #2D2D2D;
                    padding: 10px;
                    border-radius: 5px;
                }
                #log {
                    font-family: Monaco, monospace;
                    font-size: 13px;
                    line-height: 1.5;
                    background: #000000;
                    color: #FFFFFF;
                    padding: 15px;
                    border-radius: 5px;
                    height: 300px;
                    overflow-y: auto;
                    white-space: pre-wrap;
                    margin-top: 10px;
                    border: 1px solid #3D3D3D;
                }
                .success { color: #00FF00; }
                .error { color: #FF4444; }
                .info { color: #00BFFF; }
            </style>
        </head>
        <body>
            <div class="header">SpoonManager - Updating Spoons (Press ESC to close)</div>
            <div id="log"></div>
        </body>
        </html>
    ]]

    local screen = hs.screen.primaryScreen()
    local frame = screen:frame()
    local width = 700
    local height = 500
    local rect = hs.geometry.rect(
        frame.x + (frame.w - width) / 2,
        frame.y + (frame.h - height) / 2,
        width,
        height
    )

    if self.progressWindow then
        self.progressWindow:delete()
    end

    -- Salva o template HTML
    self.htmlTemplate = html
    
    self.progressWindow = hs.webview.new(rect)
    self.progressWindow:windowStyle("closable", "titled")
    self.progressWindow:level(hs.drawing.windowLevels.floating)
    self.progressWindow:html(html)
    
    self.escapeWatcher = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
        if event:getKeyCode() == 53 and not next(event:getFlags()) then
            self:closeProgressWindow()
            return true
        end
        return false
    end):start()
    
    self.progressWindow:show()
end

function obj:log(message, type)
    if self.progressWindow then
        -- Adiciona a mensagem ao buffer
        local time = os.date("%H:%M:%S")
        local cssClass = type or ""
        local logEntry = string.format('<div class="%s">[%s] %s</div>', 
            cssClass, 
            time, 
            message:gsub("<", "&lt;"):gsub(">", "&gt;"))
        
        table.insert(self.logBuffer, logEntry)
        
        -- Recria o HTML completo
        local logContent = table.concat(self.logBuffer, "\n")
        local fullHtml = self.htmlTemplate:gsub("</div>%s*</body>", logContent .. "</div></body>")
        
        -- Atualiza a webview
        self.progressWindow:html(fullHtml)
    end
    print(message)
end

function obj:closeProgressWindow()
    if self.escapeWatcher then
        self.escapeWatcher:stop()
        self.escapeWatcher = nil
    end
    
    if self.closeTimer then
        self.closeTimer:stop()
        self.closeTimer = nil
    end
    
    if self.progressWindow then
        self.progressWindow:delete()
        self.progressWindow = nil
    end
    
    -- Limpa o buffer de log
    self.logBuffer = {}
end

function obj:testLog()
    self:log("Teste 1", "info")
    self:log("Teste 2", "success")
    self:log("Teste 3", "error")
end

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
    local hammerspoonDir = os.getenv("HOME") .. "/.hammerspoon"
    local spoonDir = hammerspoonDir .. "/Spoons"
    local backupDir = hammerspoonDir .. "/SpoonBackups"
    
    -- Verifica se o diretório de backup existe
    if not hs.fs.attributes(backupDir) then
        print("Criando diretório de backup:", backupDir)
        if not hs.fs.mkdir(backupDir) then
            print("Erro ao criar diretório de backup")
            return false
        end
    end

    local backupFolder = string.format("%s/backup_%s", 
        backupDir, 
        os.date("%Y%m%d_%H%M%S"))
    
    -- Verifica se o diretório de Spoons existe
    if not hs.fs.attributes(spoonDir) then
        print("Diretório de Spoons não encontrado:", spoonDir)
        return false
    end
    
    -- Cria o diretório de backup específico
    if not hs.fs.mkdir(backupFolder) then
        print("Não foi possível criar pasta de backup:", backupFolder)
        return false
    end
    
    -- Copia os arquivos
    local command = string.format("cp -R '%s'/* '%s'", spoonDir, backupFolder)
    local success = os.execute(command)
    
    if success then
        print("Backup criado com sucesso em:", backupFolder)
        return true
    else
        print("Erro ao copiar arquivos para backup")
        return false
    end
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
    -- Create progress window
    self:createProgressWindow()
    
    local hammerspoonDir = os.getenv("HOME") .. "/.hammerspoon"
    local spoonDestPath = hammerspoonDir .. "/Spoons"
    
    -- Start the process
    self:log("Starting Spoons update...", "info")
    
    -- Backup
    self:log("Creating backup of existing Spoons...", "info")
    if not self:backupCurrentSpoons() then
        self:log("Failed to create backup, aborting update", "error")
        return false
    end
    self:log("Backup created successfully!", "success")
    
    local updatedSpoons = {}
    local updateCount = 0
    
    for _, repo in ipairs(self.config.repositories) do
        self:log("Processing repository: " .. (repo.name or repo.url), "info")
        
        local success, tempDir = self:cloneOrPullRepository(repo)
        
        if success then
            self:log("Repository cloned successfully", "success")
            local spoonSourcePath = tempDir .. "/" .. (repo.path or "")
            
            if not hs.fs.attributes(spoonSourcePath) then
                self:log("Source directory not found: " .. spoonSourcePath, "error")
                return false
            end
            
            self:log("Checking available Spoons...", "info")
            
            local handle = io.popen('ls "' .. spoonSourcePath .. '"')
            if handle then
                for file in handle:lines() do
                    if file:match("%.spoon$") and file ~= "SpoonManager.spoon" then
                        local sourcePath = spoonSourcePath .. "/" .. file
                        local destPath = spoonDestPath .. "/" .. file
                        
                        self:log("Updating: " .. file, "info")
                        
                        os.execute(string.format("rm -rf '%s'", destPath))
                        
                        if os.execute(string.format("cp -R '%s' '%s'", sourcePath, destPath)) then
                            updateCount = updateCount + 1
                            updatedSpoons[updateCount] = file:gsub("%.spoon$", "")
                            self:log("✓ " .. file .. " updated successfully", "success")
                        else
                            self:log("✗ Error updating " .. file, "error")
                        end
                    end
                end
                handle:close()
            end
            
            self:log("Cleaning up temporary files...", "info")
            os.execute(string.format("rm -rf '%s'", tempDir))
        else
            self:log("Failed to clone repository", "error")
        end
    end
    
    if updateCount > 0 then
        local message = string.format("Update completed! %d Spoons updated: %s", 
            updateCount, 
            table.concat(updatedSpoons, ", "))
        self:log(message, "success")
        
        if self.config.notifyOnUpdate then
            hs.notify.new({
                title = "SpoonManager",
                informativeText = message
            }):send()
        end
    else
        self:log("No Spoons were updated", "info")
    end
    
    -- Add message about auto-closing
    self:log("Window will close automatically in 30 seconds...", "info")
    
    -- Close window after 30 seconds
    if self.closeTimer then
        self.closeTimer:stop()
    end
    self.closeTimer = hs.timer.doAfter(30, function()
        self:closeProgressWindow()
    end)
    
    return true
end

function obj:start()
    -- Executa apenas a atualização manual
    self:updateSpoons()
    return self
end

function obj:stop()
    -- Mantido para compatibilidade, mas não faz mais nada
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