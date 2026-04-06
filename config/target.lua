-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | config/target.lua
-- Definição declarativa de targets
--
-- ─── Campos por entrada ──────────────────────────────────────────────────────
--   id          string    identificador único (mesmo id em N entradas = submenu)
--   groupLabel  string?   label do menu pai ao agrupar (usa label do 1º item se nil)
--   bones       table?    bones do veículo onde o target é ativado
--   distance    number?   distância de ativação (sobrescreve Config.Distance)
--   duty        string?   emprego obrigatório  (nil = qualquer jogador)
--   lvl         number?   grade mínima do emprego
--   label       string    texto exibido
--   icon        string    ícone FontAwesome (ex: 'fas fa-door-open')
--   onSelect    function  callback ao selecionar
--   children    table?    sub-opções → cria submenu aninhado
--
-- ─── Tipos de target ─────────────────────────────────────────────────────────
--   Vehicle      → exports.ox_target:addGlobalVehicle
--   Player       → exports.ox_target:addGlobalPlayer
--   Ped          → exports.ox_target:addGlobalPed
--   Object       → exports.ox_target:addGlobalObject
--   SphereZone   → exports.ox_target:addSphereZone
--   BoxZone      → exports.ox_target:addBoxZone
--   PolyZone     → exports.ox_target:addPolyZone
--   GlobalOption → exports.ox_target:addGlobalOption
--
-- ─── Uso externo (qualquer outro resource) ───────────────────────────────────
--   exports.pr_menu:CreateTarget('Vehicle', { ... })
--   exports.pr_menu:CreateTarget('Player',  { ... })
--   exports.pr_menu:RemoveTarget('meu_id')
-- ─────────────────────────────────────────────────────────────────────────────
Target = {}
Target.Targets = {

    -- =========================================================================
    --  VEÍCULO
    -- =========================================================================
    Vehicle = {

        -- ── Porta + Vidro (mesmo id → submenu automático) ────────────────────
        {
            id         = 'vehicle_door',
            groupLabel = 'Porta',
            bones      = { 'door_dside_f', 'door_pside_f', 'door_dside_r', 'door_pside_r' },
            distance   = 2.5,
            label      = 'Abrir Porta',
            icon       = 'fas fa-door-open',
            onSelect   = function(data)
                if not DoesEntityExist(data.entity) then return end
                local doorIndex = pr_menu.getNearestDoorIndex(data.entity, data.coords)
                pr_menu.toggleDoor(data.entity, doorIndex)
            end,
        },
        {
            id       = 'vehicle_door',
            bones    = { 'door_dside_f', 'door_pside_f', 'door_dside_r', 'door_pside_r' },
            distance = 2.5,
            label    = 'Abrir Vidro',
            icon     = 'fas fa-window-maximize',
            onSelect = function(data)
                if not DoesEntityExist(data.entity) then return end
                local winIndex = pr_menu.getNearestWindowIndex(data.entity, data.coords)
                pr_menu.toggleWindow(data.entity, winIndex)
            end,
        },

        -- ── Capô (id único → ação direta) ────────────────────────────────────
        {
            id       = 'vehicle_capo',
            bones    = { 'bonnet', 'bonnet_dummy' },
            distance = 2.0,
            label    = 'Capô',
            icon     = 'fas fa-car-side',
            onSelect = function(data)
                if not DoesEntityExist(data.entity) then return end
                pr_menu.toggleDoor(data.entity, 4)
            end,
        },

        -- ── Porta-mala (children → submenu aninhado) ─────────────────────────
        {
            id       = 'vehicle_trunk',
            bones    = { 'boot', 'door_dside_r2' },
            distance = 2.5,
            label    = 'Porta-mala',
            icon     = 'fas fa-box-open',
            children = {
                {
                    id       = 'trunk_door',
                    label    = 'Abrir / Fechar',
                    icon     = 'fas fa-lock-open',
                    onSelect = function(data)
                        if not DoesEntityExist(data.entity) then return end
                        pr_menu.toggleDoor(data.entity, 5, true) -- true = requer chave
                    end,
                },
                {
                    id       = 'trunk_inventory',
                    label    = 'Baú do porta-mala',
                    icon     = 'fas fa-lock',
                    onSelect = function(data)
                        if not DoesEntityExist(data.entity) then return end
                        local plate = pr_menu.getVehiclePlate(data.entity)
                        TriggerServerEvent('pr_menu:openTrunkInventory', plate)
                    end,
                },
                {
                    id       = 'trunk_enter',
                    label    = 'Entrar no porta-mala',
                    icon     = 'fas fa-person-walking-arrow-right',
                    onSelect = function(data)
                        if not DoesEntityExist(data.entity) then return end
                        TriggerEvent('pr_menu:trunk:getIn', data.entity)
                    end,
                },
            },
        },

    },

    -- =========================================================================
    --  JOGADOR
    -- =========================================================================
    Player = {

        -- ── Algemar / Desalgemar (mesmo id → submenu) ────────────────────────
        {
            id         = 'player_cuff',
            groupLabel = 'Restrições',
            duty       = 'police',
            lvl        = 0,
            label      = 'Algemar',
            icon       = 'fas fa-handcuffs',
            onSelect   = function(data)
                if not DoesEntityExist(data.entity) then return end
                local targetSrv = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                TriggerServerEvent('pr_menu:cuffPlayer', targetSrv, true)
            end,
        },
        {
            id       = 'player_cuff',
            duty     = 'police',
            lvl      = 0,
            label    = 'Desalgemar',
            icon     = 'fas fa-handcuffs',
            onSelect = function(data)
                if not DoesEntityExist(data.entity) then return end
                local targetSrv = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                TriggerServerEvent('pr_menu:cuffPlayer', targetSrv, false)
            end,
        },

    },

    -- =========================================================================
    --  PEDS — adicione entradas aqui
    -- =========================================================================
    Ped = {},

    -- =========================================================================
    --  OBJECTS — adicione entradas aqui
    -- =========================================================================
    Object = {},

    -- =========================================================================
    --  ZONES — adicione entradas aqui
    -- =========================================================================
    SphereZone   = {},
    BoxZone      = {},
    PolyZone     = {},

    -- =========================================================================
    --  GLOBAL OPTION — adicione entradas aqui
    -- =========================================================================
    GlobalOption = {},
}
