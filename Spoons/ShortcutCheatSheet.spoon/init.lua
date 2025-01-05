local obj = {}
obj.__index = obj
obj.name = "ShortcutCheatSheet"
obj.version = "1.0"
obj.author = "Your Name"

-- Atalhos do ShiftIt
local shortcuts = {
    ["⌃⌥⌘ ←"] = "Mover janela para metade esquerda",
    ["⌃⌥⌘ →"] = "Mover janela para metade direita",
    ["⌃⌥⌘ ↑"] = "Mover janela para metade superior",
    ["⌃⌥⌘ ↓"] = "Mover janela para metade inferior",
    ["⌃⌥⌘ 1"] = "Mover janela para quarto superior-esquerdo",
    ["⌃⌥⌘ 2"] = "Mover janela para quarto superior-direito",
    ["⌃⌥⌘ 3"] = "Mover janela para quarto inferior-esquerdo",
    ["⌃⌥⌘ 4"] = "Mover janela para quarto inferior-direito",
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
            </style>
        </head>
        <body>
            <h2>Atalhos do ShiftIt</h2>
    ]]

    for key, description in pairs(shortcuts) do
        html = html .. string.format([[
            <div class="shortcut">
                <span class="key">%s</span>
                <span class="description">%s</span>
            </div>
        ]], key, description)
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
    
    self.webview = hs.webview.new({x = frame.x + 50, y = frame.y + 50, w = frame.w - 100, h = frame.h - 100})
    self.webview:windowStyle("utility")
    self.webview:closeOnEscape(true)
    self.webview:html(self:generateHTML())
    self.webview:show()
end

function obj:hideCheatSheet()
    if self.webview then
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