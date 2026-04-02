Config = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Integração com sistema de chaves de veículo
-- Defina o nome do resource ou nil para desativar verificação de chave
-- ─────────────────────────────────────────────────────────────────────────────
Config.Vehicle_key = 'mm_carkeys'

-- ─────────────────────────────────────────────────────────────────────────────
-- Permissões de grupos/empregos para opções com duty
-- min_grade: nível mínimo do emprego necessário (0 = qualquer nível)
-- ─────────────────────────────────────────────────────────────────────────────
Config.Admin = {
    Permissions = {
        ['admin']  = { min_grade = 0 },
        ['police'] = { min_grade = 0 },
    }
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Distâncias padrão por tipo de target (em metros)
-- Pode ser sobrescrito individualmente em cada entrada de Config.Targets
-- ─────────────────────────────────────────────────────────────────────────────
Config.Distance = {
    default = 2.0,   -- fallback global (usado quando não definido abaixo)
    vehicle = 2.5,   -- padrão para targets de veículo
    player  = 2.0,   -- padrão para targets de jogador
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Targets de Veículo e Jogador
--
-- Campos disponíveis por entrada:
--   id          (string)   identificador de agrupamento
--                          → mesmo id em múltiplas entradas = submenu automático
--   groupLabel  (string?)  label do menu PAI ao agrupar (opcional, usa label do 1° item)
--   bones       (table?)   bones do veículo onde o target é ativado
--   distance    (number?)  distância de ativação (sobrescreve Config.Distance)
--   duty        (string?)  emprego necessário (nil = qualquer jogador)
--   lvl         (number?)  grade mínima do emprego (nil = qualquer grade)
--   label       (string)   texto exibido na opção
--   icon        (string)   ícone Font Awesome (ex: 'fas fa-door-open')
--   onSelect    (function) callback ao selecionar a opção
--   children    (table?)   sub-opções aninhadas (cria submenu a partir desta entrada)
-- ─────────────────────────────────────────────────────────────────────────────
Config.Targets = {

    -- =========================================================================
    --  VEÍCULO
    -- =========================================================================
    Vehicle = {

        -- ── Porta + Vidro ────────────────────────────────────────────────────
        -- Mesmo id 'vehicle_door' → fundidos automaticamente em submenu
        {
            id         = 'vehicle_door',
            groupLabel = 'Porta / Vidro',   -- label do menu pai gerado
            bones      = { 'door_dside_f', 'door_pside_f', 'door_dside_r', 'door_pside_r' },
            distance   = 2.5,
            duty       = nil,
            lvl        = nil,
            label      = 'Porta',
            icon       = 'fas fa-door-open',
            onSelect   = function(data)
                if not DoesEntityExist(data.entity) then return end

                local doorIndex = pr_menu.getNearestDoorIndex(data.entity, data.coords)
                local isOpen    = GetVehicleDoorAngleRatio(data.entity, doorIndex) > 0.1

                if isOpen then
                    SetVehicleDoorShut(data.entity, doorIndex, false)
                else
                    -- Verifica chave antes de abrir
                    if Config.Vehicle_key and not pr_menu.hasCarKey(data.entity) then
                        lib.notify({ title = 'Veículo', description = 'Você não possui a chave!', type = 'error' })
                        return
                    end
                    SetVehicleDoorOpen(data.entity, doorIndex, false, false)
                end
            end
        },
        {
            id       = 'vehicle_door',
            bones    = { 'door_dside_f', 'door_pside_f', 'door_dside_r', 'door_pside_r' },
            distance = 2.5,
            duty     = nil,
            lvl      = nil,
            label    = 'Vidro',
            icon     = 'fas fa-window-maximize',
            onSelect = function(data)
                if not DoesEntityExist(data.entity) then return end

                local winIndex = pr_menu.getNearestWindowIndex(data.entity, data.coords)

                -- RollDownWindow / RollUpWindow requerem que o vidro esteja intacto
                if not IsVehicleWindowIntact(data.entity, winIndex) then
                    lib.notify({ title = 'Vidro', description = 'O vidro está quebrado!', type = 'error' })
                    return
                end

                -- Sem forma nativa de checar se está aberto/fechado — usa state local
                local key = ('pr_win_%s_%s'):format(NetworkGetNetworkIdFromEntity(data.entity), winIndex)
                if LocalState[key] then
                    RollUpWindow(data.entity, winIndex)
                    LocalState[key] = false
                else
                    RollDownWindow(data.entity, winIndex)
                    LocalState[key] = true
                end
            end
        },

        -- ── Capô ─────────────────────────────────────────────────────────────
        -- Id único → ação direta (sem submenu)
        {
            id       = 'vehicle_capo',
            bones    = { 'bonnet', 'bonnet_dummy' },
            distance = 2.0,
            duty     = nil,
            lvl      = nil,
            label    = 'Capô',
            icon     = 'fas fa-car-side',
            onSelect = function(data)
                if not DoesEntityExist(data.entity) then return end

                local isOpen = GetVehicleDoorAngleRatio(data.entity, 4) > 0.1
                if isOpen then
                    SetVehicleDoorShut(data.entity, 4, false)
                else
                    SetVehicleDoorOpen(data.entity, 4, false, false)
                end
            end
        },

        -- ── Porta-mala ───────────────────────────────────────────────────────
        -- Id único MAS com campo 'children' → submenu aninhado
        {
            id       = 'vehicle_trunk',
            bones    = { 'boot', 'door_dside_r2' },
            distance = 2.5,
            duty     = nil,
            lvl      = nil,
            label    = 'Porta-mala',
            icon     = 'fas fa-box-open',
            children = {
                {
                    id       = 'door_trunk',
                    label    = 'Abrir / Fechar',
                    icon     = 'fas fa-lock-open',
                    onSelect = function(data)
                        if not DoesEntityExist(data.entity) then return end

                        local isOpen = GetVehicleDoorAngleRatio(data.entity, 5) > 0.1
                        if isOpen then
                            SetVehicleDoorShut(data.entity, 5, false)
                        else
                            if Config.Vehicle_key and not pr_menu.hasCarKey(data.entity) then
                                lib.notify({ title = 'Veículo', description = 'Você não possui a chave!', type = 'error' })
                                return
                            end
                            SetVehicleDoorOpen(data.entity, 5, false, false)
                        end
                    end
                },
                {
                    id       = 'vehi_safe',
                    label    = 'Baú do porta-mala',
                    icon     = 'fas fa-lock',
                    onSelect = function(data)
                        if not DoesEntityExist(data.entity) then return end
                        -- Envia a placa (identificador usado pelo ox_inventory para o baú)
                        local plate = GetVehicleNumberPlateText(data.entity):gsub('%s+', '')
                        TriggerServerEvent('pr_menu:openTrunkInventory', plate)
                    end
                },
            }
        },

    },

    -- =========================================================================
    --  JOGADOR
    -- =========================================================================
    Player = {

        -- ── Algemar + Desalgemar ──────────────────────────────────────────────
        -- Mesmo id 'cuff' → fundidos em submenu automático com label 'groupLabel'
        {
            id         = 'cuff',
            groupLabel = 'Restrições',
            duty       = 'police',
            lvl        = 0,
            label      = 'Algemar',
            icon       = 'fas fa-handcuffs',
            onSelect   = function(data)
                if not DoesEntityExist(data.entity) then return end
                local targetSrv = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                TriggerServerEvent('pr_menu:cuffPlayer', targetSrv, true)
            end
        },
        {
            id     = 'cuff',
            duty   = 'police',
            lvl    = 0,
            label  = 'Desalgemar',
            icon   = 'fas fa-handcuffs',
            onSelect = function(data)
                if not DoesEntityExist(data.entity) then return end
                local targetSrv = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                TriggerServerEvent('pr_menu:cuffPlayer', targetSrv, false)
            end
        },

    }
}
