fx_version 'cerulean'
game      'gta5'
lua54     'yes'

name        'pr_menu'
author      'PierreMoraes'
version     '2.0.0'
description 'Sistema de Target + Radial Menu + ox_lib menus — multi-framework via Fivem_bridge'

-- ─────────────────────────────────────────────────────────────────────────────
-- Dependências
--   ox_lib      → radial menu, notify fallback, callbacks, progressBar
--   ox_target   → sistema de target (fixo — pr_menu é construído sobre ele)
--   Fivem_bridge → framework, notificações, inventário, chave de veículo, etc.
-- ─────────────────────────────────────────────────────────────────────────────
dependency 'ox_lib'
dependency 'ox_target'
dependency 'Fivem_bridge'

-- ─────────────────────────────────────────────────────────────────────────────
-- Shared: carregado em client E server
-- ─────────────────────────────────────────────────────────────────────────────
shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Client
--   Ordem de carregamento importa:
--     1. configs        (Target, Radial, Menu — tabelas declarativas)
--     2. functions.lua  (pr_menu.*, hasPermission, helpers, eventos de veículo)
--     3. target.lua     (lê Target.Targets + ouve exports externos)
--     4. radial.lua     (monta radial, ouve exports externos)
--     5. menu.lua       (context menu, input, alert — ox_lib menus)
-- ─────────────────────────────────────────────────────────────────────────────
client_scripts {
    'config/target.lua',
    'config/radial.lua',
    'config/menu.lua',
    'client/functions.lua',
    'client/target.lua',
    'client/radial.lua',
    'client/menu.lua',
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Server
--   1. functions.lua  (pr_menu_sv.*, validação via Bridge.framework)
--   2. target.lua     (callbacks de target: algemar, baú, etc.)
--   3. radial.lua     (callbacks de radial: trunk busy, door sync, dead)
-- ─────────────────────────────────────────────────────────────────────────────
server_scripts {
    'server/functions.lua',
    'server/target.lua',
    'server/radial.lua',
}
