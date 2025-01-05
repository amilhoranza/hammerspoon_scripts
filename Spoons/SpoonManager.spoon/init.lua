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

-- Inicializar config antes de qualquer uso
obj.config = {
    repositories = {
        {
            name = "Personal Spoons",
            url = "https://github.com/amilhoranza/hammerspoon_scripts",
            branch = "main",
            path = "Spoons"
        }
    },
    checkInterval = 3600 * 12, -- 12 hours
    notifyOnUpdate = true
}

function obj:createProgressWindow()
    -- Initialize log buffer
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
                    background: #1A1B1E;
                    color: #E4E5E7;
                }
                .header {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    font-size: 18px;
                    font-weight: 500;
                    margin-bottom: 20px;
                    color: #FFFFFF;
                    background: linear-gradient(90deg, #2C2D31 0%, #1A1B1E 100%);
                    padding: 15px 20px;
                    border-radius: 10px;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.2);
                }
                .header-title {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                }
                .header-icon {
                    font-size: 24px;
                }
                .esc-hint {
                    font-size: 13px;
                    color: #8B8D91;
                    padding: 5px 10px;
                    background: rgba(255,255,255,0.1);
                    border-radius: 5px;
                }
                #log {
                    font-family: "SF Mono", Monaco, Menlo, monospace;
                    font-size: 13px;
                    line-height: 1.6;
                    background: #000000;
                    color: #E4E5E7;
                    padding: 20px;
                    border-radius: 10px;
                    height: 340px;
                    overflow-y: auto;
                    white-space: pre-wrap;
                    margin-top: 10px;
                    border: 1px solid #2C2D31;
                    box-shadow: inset 0 2px 4px rgba(0,0,0,0.2);
                }
                .success { 
                    color: #4ADE80; 
                    padding: 2px 0;
                }
                .error { 
                    color: #FF5757;
                    padding: 2px 0;
                }
                .info { 
                    color: #60A5FA; 
                    padding: 2px 0;
                }
                .timestamp {
                    color: #8B8D91;
                    margin-right: 8px;
                }
                #log::-webkit-scrollbar {
                    width: 8px;
                }
                #log::-webkit-scrollbar-track {
                    background: #1A1B1E;
                    border-radius: 4px;
                }
                #log::-webkit-scrollbar-thumb {
                    background: #2C2D31;
                    border-radius: 4px;
                }
                #log::-webkit-scrollbar-thumb:hover {
                    background: #3C3D41;
                }
                .log-entry {
                    display: flex;
                    align-items: flex-start;
                    margin: 2px 0;
                }
                .log-icon {
                    margin-right: 8px;
                    font-family: -apple-system;
                }
            </style>
        </head>
        <body>
            <div class="header">
                <div class="header-title">
                    <span class="header-icon">🔄</span>
                    <span>SpoonManager</span>
                </div>
                <div class="esc-hint">ESC to close</div>
            </div>
            <div id="log"></div>
        </body>
        </html>
    ]]

    -- Cálculo preciso do centro da tela
    local screen = hs.screen.primaryScreen()
    local frame = screen:frame()
    local width = 800
    local height = 550
    
    -- Centralizar exatamente no meio da tela
    local x = frame.x + (frame.w - width) / 2
    local y = frame.y + (frame.h - height) / 2
    
    -- Arredondar as coordenadas para evitar posicionamento em meio-pixel
    x = math.floor(x)
    y = math.floor(y)
    
    local rect = hs.geometry.rect(x, y, width, height)

    if self.progressWindow then
        self.progressWindow:delete()
    end

    -- Save HTML template
    self.htmlTemplate = html
    
    -- Criar a janela já com o tamanho e posição corretos
    self.progressWindow = hs.webview.new(rect)
    self.progressWindow:windowStyle("closable", "titled", "nonactivating", "utility")
    self.progressWindow:level(hs.drawing.windowLevels.floating)
    self.progressWindow:html(html)
    
    self.escapeWatcher = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
        if event:getKeyCode() == 53 and not next(event:getFlags()) then
            self:closeProgressWindow()
            return true
        end
        return false
    end):start()
    
    -- Mostrar a janela
    self.progressWindow:show()
    
    -- Forçar a janela para frente
    self.progressWindow:bringToFront(true)
end

function obj:log(message, type)
    if self.progressWindow then
        -- Add message to buffer
        local time = os.date("%H:%M:%S")
        local cssClass = type or ""
        local icon = type == "success" and "✓" or type == "error" and "✗" or "ℹ"
        
        local logEntry = string.format(
            '<div class="log-entry %s">' ..
            '<span class="timestamp">[%s]</span>' ..
            '<span class="log-icon">%s</span>' ..
            '<span>%s</span>' ..
            '</div>', 
            cssClass, 
            time,
            icon,
            message:gsub("<", "&lt;"):gsub(">", "&gt;"))
        
        table.insert(self.logBuffer, logEntry)
        
        -- Recreate full HTML
        local logContent = table.concat(self.logBuffer, "\n")
        local fullHtml = self.htmlTemplate:gsub("</div>%s*</body>", logContent .. "</div></body>")
        
        -- Update webview
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
    
    -- Clear log buffer
    self.logBuffer = {}
end

function obj:init()
    -- Setup update hotkey
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "u", function()
        self:updateSpoons()
    end)
    return self
end

function obj:backupSpoons()
    local backupDir = os.getenv("HOME") .. "/.hammerspoon/SpoonBackups"
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local backupPath = string.format("%s/spoons_backup_%s", backupDir, timestamp)
    
    -- Criar diretório de backup se não existir
    os.execute("mkdir -p " .. backupDir)
    
    -- Remover backups antigos
    local cmd = string.format("rm -rf %s/spoons_backup_*", backupDir)
    os.execute(cmd)
    
    -- Criar novo backup
    local spoonsDir = os.getenv("HOME") .. "/.hammerspoon/Spoons"
    local cmd = string.format("cp -R %s %s", spoonsDir, backupPath)
    
    if os.execute(cmd) then
        self:log("✓ Backup criado em: " .. backupPath, "success")
    else
        self:log("✗ Erro ao criar backup", "error")
    end
    
    return true
end

-- Função auxiliar para limpar backups antigos (opcional)
function obj:cleanOldBackups()
    local backupDir = os.getenv("HOME") .. "/.hammerspoon/SpoonBackups"
    
    -- Manter apenas o backup mais recente
    local cmd = string.format([[
        cd %s &&
        ls -t spoons_backup_* 2>/dev/null |
        tail -n +2 |
        xargs rm -rf
    ]], backupDir)
    
    os.execute(cmd)
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
    if not self:backupSpoons() then
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