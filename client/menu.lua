-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | client/menu.lua
-- Gerenciador de menus ox_lib (ContextMenu, InputDialog, AlertDialog, TextUI)
-- declarados em config/menu.lua.
--
-- Exports disponíveis:
--   exports.pr_menu:OpenContextMenu(id)
--   exports.pr_menu:OpenInput(id, callback)
--   exports.pr_menu:OpenAlert(id, callback)
--   exports.pr_menu:ShowTextUI(id)
--   exports.pr_menu:HideTextUI()
--   exports.pr_menu:RegisterContextMenu(menuDef)   -- registro em tempo real
--   exports.pr_menu:RegisterInput(inputDef)
--   exports.pr_menu:RegisterAlert(alertDef)
--   exports.pr_menu:RegisterTextUI(textuiDef)
-- ─────────────────────────────────────────────────────────────────────────────

-- Registros em memória (id → definição)
local _contextMenus = {}
local _inputs       = {}
local _alerts       = {}
local _textUIs      = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Indexa todos os menus do config/menu.lua
-- ─────────────────────────────────────────────────────────────────────────────
for _, m in ipairs(Menu.context or {}) do
    _contextMenus[m.id] = m
end
for _, m in ipairs(Menu.input or {}) do
    _inputs[m.id] = m
end
for _, m in ipairs(Menu.alert or {}) do
    _alerts[m.id] = m
end
for _, m in ipairs(Menu.textUI or {}) do
    _textUIs[m.id] = m
end

lib.print.info(('[pr_menu] Menus carregados: %d context | %d input | %d alert | %d textUI'):format(
    #(Menu.context or {}), #(Menu.input or {}), #(Menu.alert or {}), #(Menu.textUI or {})
))

-- ─────────────────────────────────────────────────────────────────────────────
-- ContextMenu
-- ─────────────────────────────────────────────────────────────────────────────

--- Abre um context menu registrado pelo id
---@param id string
local function openContextMenu(id)
    local def = _contextMenus[id]
    assert(def, ('[pr_menu] OpenContextMenu: menu "%s" não encontrado.'):format(id))
    lib.registerContext(def)
    lib.showContext(id)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- InputDialog
-- ─────────────────────────────────────────────────────────────────────────────

--- Abre um input dialog registrado e executa o callback com os valores
---@param id string
---@param cb fun(values: table|nil)
local function openInput(id, cb)
    local def = _inputs[id]
    assert(def, ('[pr_menu] OpenInput: input "%s" não encontrado.'):format(id))
    local values = lib.inputDialog(def.title, def.inputs)
    if cb then cb(values) end
    return values
end

-- ─────────────────────────────────────────────────────────────────────────────
-- AlertDialog
-- ─────────────────────────────────────────────────────────────────────────────

--- Abre um alert dialog e executa o callback com 'confirm' | 'cancel'
---@param id string
---@param cb fun(result: string)
local function openAlert(id, cb)
    local def = _alerts[id]
    assert(def, ('[pr_menu] OpenAlert: alert "%s" não encontrado.'):format(id))
    local result = lib.alertDialog({
        header   = def.header,
        content  = def.content,
        centered = def.centered,
        cancel   = def.cancel,
    })
    if cb then cb(result) end
    return result
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TextUI
-- ─────────────────────────────────────────────────────────────────────────────

local _activeTextUI = nil

--- Exibe um TextUI registrado pelo id
---@param id string
local function showTextUI(id)
    local def = _textUIs[id]
    assert(def, ('[pr_menu] ShowTextUI: textUI "%s" não encontrado.'):format(id))
    lib.showTextUI(def.text, {
        position  = def.position  or 'right-center',
        icon      = def.icon,
        iconColor = def.iconColor,
        style     = def.style,
    })
    _activeTextUI = id
end

--- Esconde o TextUI ativo
local function hideTextUI()
    lib.hideTextUI()
    _activeTextUI = nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORTS públicos
-- ─────────────────────────────────────────────────────────────────────────────

exports('OpenContextMenu', openContextMenu)
exports('OpenInput',       openInput)
exports('OpenAlert',       openAlert)
exports('ShowTextUI',      showTextUI)
exports('HideTextUI',      hideTextUI)

-- Registro em tempo real (outros resources podem adicionar menus)
exports('RegisterContextMenu', function(def)
    assert(type(def) == 'table' and def.id, '[pr_menu] RegisterContextMenu: def.id obrigatório')
    _contextMenus[def.id] = def
end)

exports('RegisterInput', function(def)
    assert(type(def) == 'table' and def.id, '[pr_menu] RegisterInput: def.id obrigatório')
    _inputs[def.id] = def
end)

exports('RegisterAlert', function(def)
    assert(type(def) == 'table' and def.id, '[pr_menu] RegisterAlert: def.id obrigatório')
    _alerts[def.id] = def
end)

exports('RegisterTextUI', function(def)
    assert(type(def) == 'table' and def.id, '[pr_menu] RegisterTextUI: def.id obrigatório')
    _textUIs[def.id] = def
end)
