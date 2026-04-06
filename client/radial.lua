-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | client/radial.lua
-- Menu radial via ox_lib.
-- Combina config/radial.lua (declarativo) com entradas externas via exports.
--
-- Exports disponíveis:
--   exports.pr_menu:AddRadialItem(item)
--   exports.pr_menu:RemoveRadialItem(id)
-- ─────────────────────────────────────────────────────────────────────────────

-- ─────────────────────────────────────────────────────────────────────────────
-- convert(tbl) → item formatado para ox_lib
-- ─────────────────────────────────────────────────────────────────────────────
local function convert(tbl)
    -- Sub-menu → registra no ox_lib e retorna referência
    if tbl.items then
        local items = {}
        for _, v in ipairs(tbl.items) do
            items[#items + 1] = convert(v)
        end
        lib.registerRadial({ id = tbl.id .. 'Menu', items = items })
        return { id = tbl.id, label = tbl.label, icon = tbl.icon, menu = tbl.id .. 'Menu' }
    end

    -- Monta ação
    local action = tbl.onSelect
    if not action then
        if tbl.event then
            action = function()
                TriggerEvent(tbl.event, tbl.args)
                lib.hideRadial()
            end
        elseif tbl.serverEvent then
            action = function()
                TriggerServerEvent(tbl.serverEvent, tbl.args)
                lib.hideRadial()
            end
        elseif tbl.command then
            action = function()
                ExecuteCommand(('%s %s'):format(tbl.command, tbl.args or ''))
                lib.hideRadial()
            end
        end
    end

    return { id = tbl.id, label = tbl.label, icon = tbl.icon, keepOpen = tbl.keepOpen, onSelect = action }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Menu de veículo: portas (0–5)
-- ─────────────────────────────────────────────────────────────────────────────
local DOOR_LABELS = {
    [0] = 'Porta motorista',  [1] = 'Porta passageiro',
    [2] = 'Porta tr. esq.',   [3] = 'Porta tr. dir.',
    [4] = 'Capô',             [5] = 'Porta-mala',
}

local function buildDoors()
    local items = {}
    for i = 0, 5 do
        local idx = i
        items[#items + 1] = {
            id = 'door' .. idx, label = DOOR_LABELS[idx], icon = 'car-side',
            onSelect = function() TriggerEvent('pr_menu:openDoor', idx); lib.hideRadial() end,
        }
    end
    lib.registerRadial({ id = 'vehicleDoorsMenu', items = items })
    return { id = 'vehicleDoors', label = 'Portas', icon = 'car-side', menu = 'vehicleDoorsMenu' }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Menu de veículo: janelas (0–3)
-- ─────────────────────────────────────────────────────────────────────────────
local WIN_LABELS = {
    [0] = 'Vidro motorista', [1] = 'Vidro passageiro',
    [2] = 'Vidro tr. esq.', [3] = 'Vidro tr. dir.',
}

local function buildWindows()
    local items = {}
    for i = 0, 3 do
        local idx = i
        items[#items + 1] = {
            id = 'window' .. idx, label = WIN_LABELS[idx], icon = 'car-side',
            onSelect = function() TriggerEvent('pr_menu:toggleWindows', idx); lib.hideRadial() end,
        }
    end
    lib.registerRadial({ id = 'vehicleWindowsMenu', items = items })
    return { id = 'vehicleWindows', label = 'Vidros', icon = 'car-side', menu = 'vehicleWindowsMenu' }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Menu de veículo: extras (1–maxExtras)
-- ─────────────────────────────────────────────────────────────────────────────
local function buildExtras()
    local items = {}
    for i = 1, (Config.RadialMenu.maxExtras or 13) do
        local idx = i
        items[#items + 1] = {
            id = 'extra' .. idx, label = 'Extra ' .. idx, icon = 'box-open',
            onSelect = function() TriggerEvent('pr_menu:setExtra', idx); lib.hideRadial() end,
        }
    end
    lib.registerRadial({ id = 'vehicleExtrasMenu', items = items })
    return { id = 'vehicleExtras', label = 'Extras', icon = 'plus', menu = 'vehicleExtrasMenu' }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- setupVehicleMenu(inVehicle)
-- ─────────────────────────────────────────────────────────────────────────────
function setupVehicleMenu(inVehicle)
    local items = {
        {
            id = 'vehicle-flip', label = 'Virar veículo', icon = 'car-burst',
            onSelect = function() TriggerEvent('pr_menu:trunk:flipVehicle'); lib.hideRadial() end,
        },
        buildDoors(),
        buildWindows(),
        buildExtras(),
    }

    if Config.RadialMenu.vehicleSeats and inVehicle then
        items[#items + 1] = { id = 'vehicleSeats', label = 'Assentos', icon = 'chair', menu = 'vehicleSeatsMenu' }
    end

    lib.registerRadial({ id = 'vehicleMenu', items = items })
    lib.addRadialItem({ id = 'vehicle', label = 'Veículo', icon = 'car', menu = 'vehicleMenu' })
end

-- ─────────────────────────────────────────────────────────────────────────────
-- setupSeatMenu(vehicle) — dinâmico por número de assentos
-- ─────────────────────────────────────────────────────────────────────────────
local SEAT_LABELS = { [1] = 'Motorista', [2] = 'Passageiro', [3] = 'Trás esq.', [4] = 'Trás dir.' }

local function setupSeatMenu(vehicle)
    if not Config.RadialMenu.vehicleSeats then return end
    local total = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))
    local items = {}
    for i = 1, total do
        local idx = i
        items[#items + 1] = {
            id = 'seat' .. idx, label = SEAT_LABELS[idx] or ('Assento ' .. idx), icon = 'chair',
            onSelect = function()
                TriggerEvent('pr_menu:changeSeat', idx, SEAT_LABELS[idx] or ('Assento ' .. idx))
                lib.hideRadial()
            end,
        }
    end
    lib.registerRadial({ id = 'vehicleSeatsMenu', items = items })
end

-- ─────────────────────────────────────────────────────────────────────────────
-- setupRadialMenu() — monta radial completo (vehicle + global + job + gang)
-- ─────────────────────────────────────────────────────────────────────────────
local function setupRadialMenu()
    setupVehicleMenu(false)

    -- Itens globais do config/radial.lua
    for _, v in ipairs(Radial.menuItems) do
        lib.addRadialItem(convert(v))
    end

    -- Lê job/gang via Bridge.framework (Fivem_bridge)
    local ok, info = pcall(Bridge.framework.GetJobInfo)
    if not ok or not info then return end

    -- Gang (QBX expõe QBX.PlayerData.gang)
    local gangName = (_G.QBX and QBX.PlayerData and QBX.PlayerData.gang)
                  and QBX.PlayerData.gang.name or nil

    if gangName and Radial.gangItems[gangName] and next(Radial.gangItems[gangName]) then
        lib.addRadialItem(convert({
            id = 'gangInteractions', label = 'Gang', icon = 'skull-crossbones',
            items = Radial.gangItems[gangName],
        }))
    end

    -- Job (somente on duty)
    local jobName = info.jobName
    local onduty  = not (_G.QBX and QBX.PlayerData and QBX.PlayerData.job)
                 or QBX.PlayerData.job.onduty  -- para outros frameworks assume true

    if jobName and onduty and Radial.jobItems[jobName] then
        lib.addRadialItem(convert({
            id = 'jobInteractions', label = 'Emprego', icon = 'briefcase',
            items = Radial.jobItems[jobName],
        }))
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Evento interno — permite rebuildar o radial de qualquer lugar
-- ─────────────────────────────────────────────────────────────────────────────
AddEventHandler('pr_menu:radial:setup', function()
    setupRadialMenu()
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Cache de veículo (ox_lib) — atualiza assentos e menu ao entrar/sair
-- ─────────────────────────────────────────────────────────────────────────────
lib.onCache('vehicle', function(vehicle)
    if vehicle then
        setupSeatMenu(vehicle)
        setupVehicleMenu(true)
    else
        setupVehicleMenu(false)
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Eventos de framework — atualizam job/gang no radial
-- ─────────────────────────────────────────────────────────────────────────────
AddEventHandler('QBCore:Client:OnPlayerLoaded', setupRadialMenu)
AddEventHandler('esx:playerLoaded',             setupRadialMenu)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    lib.removeRadialItem('jobInteractions')
    setupRadialMenu()
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(onDuty)
    lib.removeRadialItem('jobInteractions')
    if not onDuty then return end
    local ok, info = pcall(Bridge.framework.GetJobInfo)
    if not ok or not info then return end
    if not Radial.jobItems[info.jobName] then return end
    lib.addRadialItem(convert({
        id = 'jobInteractions', label = 'Emprego', icon = 'briefcase',
        items = Radial.jobItems[info.jobName],
    }))
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    lib.removeRadialItem('gangInteractions')
    if not gang or not Radial.gangItems[gang.name] then return end
    lib.addRadialItem(convert({
        id = 'gangInteractions', label = 'Gang', icon = 'skull-crossbones',
        items = Radial.gangItems[gang.name],
    }))
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Resource start / stop
-- ─────────────────────────────────────────────────────────────────────────────
AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res then return end
    if LocalPlayer.state.isLoggedIn then setupRadialMenu() end
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res then return end
    lib.clearRadialItems()
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORTS
-- ─────────────────────────────────────────────────────────────────────────────

-- AddRadialItem: adiciona item ao radial em tempo real
-- Uso: exports.pr_menu:AddRadialItem({ id='x', icon='star', label='Teste',
--          event='meu_resource:evento' })
exports('AddRadialItem', function(item)
    assert(type(item) == 'table' and item.id, '[pr_menu] AddRadialItem: item inválido')
    lib.addRadialItem(convert(item))
end)

-- RemoveRadialItem: remove item do radial por id
-- Uso: exports.pr_menu:RemoveRadialItem('x')
exports('RemoveRadialItem', function(id)
    lib.removeRadialItem(id)
end)

-- Aliases de retrocompatibilidade qbx_radialmenu
local function makeQBExport(name, cb)
    AddEventHandler(('__cfx_export_qb-radialmenu_%s'):format(name), function(set) set(cb) end)
end
makeQBExport('AddOption',    function(data, id)
    data.id = data.id or id
    lib.addRadialItem(convert(data))
    return data.id
end)
makeQBExport('RemoveOption', function(id) lib.removeRadialItem(id) end)
