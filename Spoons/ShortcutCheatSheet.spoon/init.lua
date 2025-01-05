local obj = {}
obj.__index = obj
obj.name = "ShortcutCheatSheet"
obj.version = "1.0"
obj.author = "Your Name"

-- Atalhos do ShiftIt
local shortcuts = {
    -- Atalhos com números
    ["⌃⌥⌘ 1"] = "Mover janela para quarto superior-esquerdo",
    ["⌃⌥⌘ 2"] = "Mover janela para quarto superior-direito",
    ["⌃⌥⌘ 3"] = "Mover janela para quarto inferior-esquerdo",
    ["⌃⌥⌘ 4"] = "Mover janela para quarto inferior-direito",
    
    -- Atalhos com setas
    ["⌃⌥⌘ ←"] = "Mover janela para metade esquerda",
    ["⌃⌥⌘ →"] = "Mover janela para metade direita",
    ["⌃⌥⌘ ↑"] = "Mover janela para metade superior",
    ["⌃⌥⌘ ↓"] = "Mover janela para metade inferior",
    
    -- Outros atalhos
    ["⌃⌥⌘ M"] = "Maximizar janela",
    ["⌃⌥⌘ F"] = "Alternar tela cheia",
    ["⌃⌥⌘ Z"] = "Alternar zoom",
    ["⌃⌥⌘ C"] = "Centralizar janela",
    ["⌃⌥⌘ N"] = "Mover para próxima tela",
    ["⌃⌥⌘ P"] = "Mover para tela anterior",
    ["⌃⌥⌘ ="] = "Aumentar tamanho da janela",
    ["⌃⌥⌘ -"] = "Diminuir tamanho da janela",
    ["⌃⌥⌘ A"] = "Organizar janelas em 4 quartos",
    ["⌃⌥⌘ T"] = "Organizar janelas em 3 colunas"
}

function obj:init()
    self.webview = nil
end

function obj:generateHTML()
    local html = [[
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Helvetica";
                    background-color: rgba(0, 0, 0, 0.8);
                    color: white;
                    padding: 20px;
                }
                .shortcut {
                    margin: 10px 0;
                }
                .key {
                    background-color: rgba(255, 255, 255, 0.2);
                    padding: 5px 10px;
                    border-radius: 5px;
                    margin-right: 10px;
                    display: inline-block;
                    min-width: 100px;
                }
                .section-header {
                    margin-top: 20px;
                    margin-bottom: 10px;
                    color: #64D2FF;
                    font-size: 1.2em;
                }
            </style>
        </head>
        <body>
            <h2>Atalhos do ShiftIt</h2>
    ]]

    -- Atalhos com números
    html = html .. '<div class="section-header">Atalhos com números</div>'
    for key, description in pairs({
        ["⌃⌥⌘ 1"] = shortcuts["⌃⌥⌘ 1"],
        ["⌃⌥⌘ 2"] = shortcuts["⌃⌥⌘ 2"],
        ["⌃⌥⌘ 3"] = shortcuts["⌃⌥⌘ 3"],
        ["⌃⌥⌘ 4"] = shortcuts["⌃⌥⌘ 4"]
    }) do
        html = html .. string.format([[
            <div class="shortcut">
                <span class="key">%s</span>
                <span class="description">%s</span>
            </div>
        ]], key, description)
    end

    -- Atalhos com setas
    html = html .. '<div class="section-header">Atalhos com setas</div>'
    for key, description in pairs({
        ["⌃⌥⌘ ←"] = shortcuts["⌃⌥⌘ ←"],
        ["⌃⌥⌘ →"] = shortcuts["⌃⌥⌘ →"],
        ["⌃⌥⌘ ↑"] = shortcuts["⌃⌥⌘ ↑"],
        ["⌃⌥⌘ ↓"] = shortcuts["⌃⌥⌘ ↓"]
    }) do
        html = html .. string.format([[
            <div class="shortcut">
                <span class="key">%s</span>
                <span class="description">%s</span>
            </div>
        ]], key, description)
    end

    -- Outros atalhos
    html = html .. '<div class="section-header">Outros atalhos</div>'
    for key, description in pairs(shortcuts) do
        if not (string.match(key, "%d$") or string.match(key, "[←→↑↓]$")) then
            html = html .. string.format([[
                <div class="shortcut">
                    <span class="key">%s</span>
                    <span class="description">%s</span>
                </div>
            ]], key, description)
        end
    end

    html = html .. [[
        </body>
        </html>
    ]]

    return html
end

function obj:showCheatSheet()
    if self.webview then
        self:hideCheatSheet()
        return
    end

    local screen = hs.screen.mainScreen()
    local frame = screen:frame()
    
    -- Reduzindo o tamanho da janela para 60% da tela
    local width = frame.w * 0.6
    local height = frame.h * 0.7
    local x = frame.x + (frame.w - width) / 2
    local y = frame.y + (frame.h - height) / 2
    
    self.webview = hs.webview.new({x = x, y = y, w = width, h = height})
    self.webview:windowStyle("utility")
    self.webview:closeOnEscape(true)
    self.webview:level(hs.drawing.windowLevels.floating) -- Mantém a janela na frente
    self.webview:allowGestures(true)  -- Permite gestos e scrolling
    self.webview:html(self:generateHTML())
    self.webview:show()

    -- Adiciona handler para a tecla ESC
    self.escapeWatcher = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
        local keyCode = event:getKeyCode()
        if keyCode == 53 then -- 53 é o código da tecla ESC
            self:hideCheatSheet()
            return true
        end
        return false
    end):start()
end

function obj:hideCheatSheet()
    if self.webview then
        if self.escapeWatcher then
            self.escapeWatcher:stop()
            self.escapeWatcher = nil
        end
        self.webview:delete()
        self.webview = nil
    end
end

function obj:bindHotkeys(mapping)
    local spec = {
        show = hs.fnutils.partial(self.showCheatSheet, self)
    }
    hs.spoons.bindHotkeysToSpec(spec, mapping)
end

function obj:start()
    -- Define o atalho padrão como Control + Alt + Command + /
    self:bindHotkeys({
        show = {{ 'ctrl', 'alt', 'cmd'}, "/"}
    })
    return self
end

return obj