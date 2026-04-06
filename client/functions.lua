-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | client/functions.lua
--
-- HUB central de funções client-side.
-- Usa Bridge (Fivem_bridge) para framework, notificações, inventário,
-- chave de veículo e progressBar — sem dependência direta de framework.
--
-- Expõe globalmente:
--   pr_menu.*       helpers de veículo, inventário, trunk
--   LocalState      estado local de janelas
--   hasPermission() verifica duty/grade via Bridge.framework
--
-- Registra eventos de veículo (portados do qbx_radialmenu):
--   pr_menu:openDoor              qb-radialmenu:client:openDoor
--   pr_menu:toggleWindows         qbx_radialmenu:client:toggleWindows
--   pr_menu:setExtra              radialmenu:client:setExtra
--   pr_menu:trunk:flipVehicle     radialmenu:flipVehicle
--   pr_menu:changeSeat            radialmenu:client:ChangeSeat
--   pr_menu:trunk:getIn
--   pr_menu:trunk:kidnapGetIn
--   pr_menu:trunk:setKidnapping
--   pr_menu:door:sync             qb-radialmenu:trunk:client:Door
--   pr_menu:applyCuff
--   radialmenu:client:deadradial
-- ─────────────────────────────────────────────────────────────────────────────

pr_menu    = {}
LocalState = {}   -- 'pr_win_<netId>_<winIdx>' → boolean

-- ─────────────────────────────────────────────────────────────────────────────
-- Mapeamento bone → índice
-- ─────────────────────────────────────────────────────────────────────────────
local DOOR_BONE_MAP = {
    { bone = 'door_dside_f',  index = 0 },
    { bone = 'door_pside_f',  index = 1 },
    { bone = 'door_dside_r',  index = 2 },
    { bone = 'door_pside_r',  index = 3 },
    { bone = 'door_dside_r2', index = 2 },
    { bone = 'door_pside_r2', index = 3 },
}

local WINDOW_BONE_MAP = {
    { bone = 'door_dside_f', index = 0 },
    { bone = 'door_pside_f', index = 1 },
    { bone = 'door_dside_r', index = 2 },
    { bone = 'door_pside_r', index = 3 },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Helpers de bone / índice
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.getNearestDoorIndex(vehicle, coords)
    local nearest, nearestDist = 0, math.huge
    for _, e in ipairs(DOOR_BONE_MAP) do
        local boneId = GetEntityBoneIndexByName(vehicle, e.bone)
        if boneId ~= -1 then
            local dist = #(coords - GetEntityBonePosition_2(vehicle, boneId))
            if dist < nearestDist then nearest = e.index; nearestDist = dist end
        end
    end
    return nearest
end

function pr_menu.getNearestWindowIndex(vehicle, coords)
    local nearest, nearestDist = 0, math.huge
    for _, e in ipairs(WINDOW_BONE_MAP) do
        local boneId = GetEntityBoneIndexByName(vehicle, e.bone)
        if boneId ~= -1 then
            local dist = #(coords - GetEntityBonePosition_2(vehicle, boneId))
            if dist < nearestDist then nearest = e.index; nearestDist = dist end
        end
    end
    return nearest
end

function pr_menu.getVehicleDoorCount(vehicle)
    local count, checked = 0, {}
    for _, e in ipairs(DOOR_BONE_MAP) do
        if not checked[e.index] and GetEntityBoneIndexByName(vehicle, e.bone) ~= -1 then
            count = count + 1; checked[e.index] = true
        end
    end
    return count
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.getVehiclePlate(vehicle) → string
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.getVehiclePlate(vehicle)
    return GetVehicleNumberPlateText(vehicle):gsub('%s+', ''):upper()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.getClosestVehicle(maxDist?) → vehicle | nil
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.getClosestVehicle(maxDist)
    if cache and cache.vehicle and cache.vehicle ~= 0 then
        return cache.vehicle
    end
    local ped    = cache and cache.ped or PlayerPedId()
    local coords = GetEntityCoords(ped)
    local veh    = lib.getClosestVehicle(coords, maxDist or 5.0, false)
    return (veh and veh ~= 0) and veh or nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.notify(data)
-- Wrapper de notificação — usa Bridge.notify (Fivem_bridge) como primário
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.notify(data)
    -- Bridge.notify.Notify(data) — ox_lib, ESX, QB conforme ambiente detectado
    if Bridge and Bridge.notify and Bridge.notify.Notify then
        Bridge.notify.Notify(data)
    else
        lib.notify(data)    -- fallback direto ox_lib
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- hasPermission(duty, lvl) → boolean
-- Verifica emprego/grade via Bridge.framework.GetJobInfo()
-- Compatível com QBX, ESX, QB, ND, OX
-- ─────────────────────────────────────────────────────────────────────────────
function hasPermission(duty, lvl)
    if not duty then return true end
    if not Bridge or not Bridge.framework then return false end

    local ok, info = pcall(Bridge.framework.GetJobInfo)
    if not ok or not info then return false end

    if info.jobName ~= duty then return false end
    if lvl and (info.grade or 0) < lvl then return false end
    return true
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.hasCarKey(vehicle) → boolean
-- Checa chave via Bridge.vehicle_key (Fivem_bridge)
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.hasCarKey(vehicle)
    if not Config.UseVehicleKey then return true end
    if not Bridge or not Bridge.vehicle_key then return true end

    local plate = pr_menu.getVehiclePlate(vehicle)
    local vk    = Bridge.vehicle_key

    local ok, result = pcall(function()
        -- mm_carkeys, wasabi_carlock → HavePermanentKey / HaveTemporaryKey
        if vk.HavePermanentKey and vk.HaveTemporaryKey then
            return vk.HavePermanentKey(plate) or vk.HaveTemporaryKey(plate)
        end
        -- qbx_vehiclekeys / qb-vehiclekeys → GiveKeys existe mas não há HasKey
        -- fallback: libera acesso
        return true
    end)

    if not ok then
        lib.print.warn(('[pr_menu] Bridge.vehicle_key falhou para placa %s. Liberando.'):format(plate))
        return true
    end

    return result == true
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.toggleDoor(vehicle, doorIndex, requireKey?)
-- Abre ou fecha porta. requireKey = true verifica chave antes de abrir.
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.toggleDoor(vehicle, doorIndex, requireKey)
    if not DoesEntityExist(vehicle) then return end
    local isOpen = GetVehicleDoorAngleRatio(vehicle, doorIndex) > 0.1
    if isOpen then
        SetVehicleDoorShut(vehicle, doorIndex, false)
    else
        if requireKey and not pr_menu.hasCarKey(vehicle) then
            pr_menu.notify({ title = 'Veículo', description = 'Você não possui a chave!', type = 'error' })
            return
        end
        SetVehicleDoorOpen(vehicle, doorIndex, false, false)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.toggleWindow(vehicle, winIndex)
-- Abre ou fecha janela. Rastreia estado em LocalState.
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.toggleWindow(vehicle, winIndex)
    if not DoesEntityExist(vehicle) then return end
    if not IsVehicleWindowIntact(vehicle, winIndex) then
        pr_menu.notify({ title = 'Vidro', description = 'O vidro está quebrado!', type = 'error' })
        return
    end
    local key = ('pr_win_%s_%s'):format(NetworkGetNetworkIdFromEntity(vehicle), winIndex)
    if LocalState[key] then
        RollUpWindow(vehicle, winIndex)
        LocalState[key] = false
    else
        RollDownWindow(vehicle, winIndex)
        LocalState[key] = true
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.toggleExtra(vehicle, extraIndex)
-- Ativa/desativa extra. Apenas para motorista.
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.toggleExtra(vehicle, extraIndex)
    if not vehicle or vehicle == 0 then
        pr_menu.notify({ title = 'Extra', description = 'Nenhum veículo encontrado!', type = 'error' })
        return
    end
    if cache and cache.seat ~= nil and cache.seat ~= -1 then
        pr_menu.notify({ title = 'Extra', description = 'Apenas o motorista pode alterar extras!', type = 'error' })
        return
    end
    SetVehicleAutoRepairDisabled(vehicle, true)
    if not DoesExtraExist(vehicle, extraIndex) then
        pr_menu.notify({ title = 'Extra', description = ('Extra %d não existe neste veículo!'):format(extraIndex), type = 'error' })
        return
    end
    if IsVehicleExtraTurnedOn(vehicle, extraIndex) then
        SetVehicleExtra(vehicle, extraIndex, true)
        pr_menu.notify({ title = 'Extra', description = ('Extra %d desativado.'):format(extraIndex), type = 'error' })
    else
        SetVehicleExtra(vehicle, extraIndex, false)
        pr_menu.notify({ title = 'Extra', description = ('Extra %d ativado.'):format(extraIndex), type = 'success' })
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.openTrunkInventory(vehicle)
-- Abre inventário do porta-mala via Bridge.inventory (Fivem_bridge)
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.openTrunkInventory(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    local plate = pr_menu.getVehiclePlate(vehicle)
    -- Solicita ao servidor abrir — Bridge.inventory.forceOpenInventory está no server
    TriggerServerEvent('pr_menu:openTrunkInventory', plate)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.openStash(id, data?)
-- Abre stash via Bridge.inventory
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.openStash(stashId, data)
    if Bridge and Bridge.inventory and Bridge.inventory.openInventory then
        Bridge.inventory.openInventory('stash', data or { id = stashId })
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.closeInventory()
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.closeInventory()
    if Bridge and Bridge.inventory and Bridge.inventory.closeInventory then
        Bridge.inventory.closeInventory()
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.getItemCount(item, metadata?) → number
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.getItemCount(item, metadata)
    if Bridge and Bridge.inventory and Bridge.inventory.GetItemCount then
        return Bridge.inventory.GetItemCount(item, metadata) or 0
    end
    return 0
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.doProgressBar(duration, label, anim?) → boolean
-- anim = { dict, clip }
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.doProgressBar(duration, label, anim)
    if Bridge and Bridge.progress and Bridge.progress.doProgressbar then
        return Bridge.progress.doProgressbar(duration, label, anim and { anim.dict, anim.clip } or { '', '' })
    end
    -- fallback ox_lib direto
    return lib.progressBar({
        duration     = duration,
        label        = label,
        useWhileDead = false,
        canCancel    = true,
        disable      = { move = true, car = true, combat = true },
        anim         = anim,
    })
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.drawText3D(x, y, z, text)
-- Texto 3D flutuante (usado no trunk)
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.drawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = #text / 370
    DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- =============================================================================
-- EVENTOS DE VEÍCULO
-- Portados do qbx_radialmenu + aliases de retrocompatibilidade
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu:openDoor  (alias: qb-radialmenu:client:openDoor)
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('pr_menu:openDoor', function(doorIndex)
    local veh = pr_menu.getClosestVehicle(5.0)
    if not veh then
        pr_menu.notify({ title = 'Veículo', description = 'Nenhum veículo encontrado!', type = 'error' })
        return
    end

    local inVeh  = cache and cache.vehicle == veh
    local isOpen = GetVehicleDoorAngleRatio(veh, doorIndex) > 0.0

    if not inVeh and not IsVehicleSeatFree(veh, -1) then
        -- Motorista presente → sincroniza pelo servidor
        TriggerServerEvent('pr_menu:door:serverSync', not isOpen, pr_menu.getVehiclePlate(veh), doorIndex)
    else
        pr_menu.toggleDoor(veh, doorIndex)
    end
end)

RegisterNetEvent('qb-radialmenu:client:openDoor', function(id)
    TriggerEvent('pr_menu:openDoor', id)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu:toggleWindows  (alias: qbx_radialmenu:client:toggleWindows)
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('pr_menu:toggleWindows', function(winIndex)
    local veh = cache and cache.vehicle or nil
    if not veh then
        pr_menu.notify({ title = 'Veículo', description = 'Você não está em um veículo!', type = 'error' })
        return
    end
    pr_menu.toggleWindow(veh, winIndex)
end)

RegisterNetEvent('qbx_radialmenu:client:toggleWindows', function(id)
    TriggerEvent('pr_menu:toggleWindows', id)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu:setExtra  (alias: radialmenu:client:setExtra)
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('pr_menu:setExtra', function(extraIndex)
    local veh = cache and cache.vehicle or nil
    pr_menu.toggleExtra(veh, extraIndex)
end)

RegisterNetEvent('radialmenu:client:setExtra', function(id)
    TriggerEvent('pr_menu:setExtra', id)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu:door:sync  (alias: qb-radialmenu:trunk:client:Door)
-- Recebido do servidor → sincroniza porta para este cliente
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('pr_menu:door:sync', function(plate, doorIndex, open)
    local veh = cache and cache.vehicle or nil
    if not veh or pr_menu.getVehiclePlate(veh) ~= plate then return end
    if open then
        SetVehicleDoorOpen(veh, doorIndex, false, false)
    else
        SetVehicleDoorShut(veh, doorIndex, false)
    end
end)

RegisterNetEvent('qb-radialmenu:trunk:client:Door', function(plate, doorIndex, open)
    TriggerEvent('pr_menu:door:sync', plate, doorIndex, open)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu:trunk:flipVehicle  (alias: radialmenu:flipVehicle)
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('pr_menu:trunk:flipVehicle', function()
    if cache and cache.vehicle then return end  -- não vira se estiver dentro

    local veh = pr_menu.getClosestVehicle(5.0)
    if not veh then
        pr_menu.notify({ title = 'Veículo', description = 'Nenhum veículo próximo!', type = 'error' })
        return
    end

    local ok = pr_menu.doProgressBar(Config.Trunk.flipTime, 'Virando o veículo…', {
        dict = 'mini@repair', clip = 'fixing_a_ped',
    })

    if ok then
        SetVehicleOnGroundProperly(veh)
        pr_menu.notify({ title = 'Veículo', description = 'Veículo virado!', type = 'success' })
    else
        pr_menu.notify({ title = 'Veículo', description = 'Ação cancelada.', type = 'error' })
    end
end)

RegisterNetEvent('radialmenu:flipVehicle', function()
    TriggerEvent('pr_menu:trunk:flipVehicle')
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu:changeSeat  (alias: radialmenu:client:ChangeSeat)
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('pr_menu:changeSeat', function(seatIndex, seatLabel)
    if not cache or not cache.vehicle then
        pr_menu.notify({ title = 'Assento', description = 'Você não está em um veículo!', type = 'error' })
        return
    end
    local veh = cache.vehicle
    local ped = cache.ped or PlayerPedId()

    local ok, hasHarness = pcall(function()
        return exports.qbx_seatbelt and exports.qbx_seatbelt:HasHarness()
    end)
    if ok and hasHarness then
        pr_menu.notify({ title = 'Assento', description = 'Remova o arnês primeiro!', type = 'error' })
        return
    end

    if not IsVehicleSeatFree(veh, seatIndex - 2) then
        pr_menu.notify({ title = 'Assento', description = 'Assento ocupado!', type = 'error' })
        return
    end

    if GetEntitySpeed(veh) * 3.6 > 100.0 then
        pr_menu.notify({ title = 'Assento', description = 'Veículo muito rápido!', type = 'error' })
        return
    end

    SetPedIntoVehicle(ped, veh, seatIndex - 2)
    pr_menu.notify({ title = 'Assento', description = ('Sentado: %s'):format(seatLabel or 'Assento'), type = 'success' })
end)

RegisterNetEvent('radialmenu:client:ChangeSeat', function(id, label)
    TriggerEvent('pr_menu:changeSeat', id, label)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu:applyCuff  — recebido pelo cliente alvo
-- Adapte para o resource de algemas do seu servidor
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('pr_menu:applyCuff', function(cuffState)
    -- Exemplo: TriggerEvent('handcuff:cuff', cuffState)
    lib.print.info(('[pr_menu] Cuff recebido: %s'):format(tostring(cuffState)))
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- radialmenu:client:deadradial
-- Desativa/reativa radial ao morrer — usa Bridge.framework.GetJobInfo()
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('radialmenu:client:deadradial', function(isDead)
    if isDead then
        local ok, info = pcall(Bridge.framework.GetJobInfo)
        local jobType  = (ok and info and info.jobType) or nil

        if jobType ~= 'leo' and jobType ~= 'ems' then
            lib.disableRadial(true)
            return
        end

        lib.clearRadialItems()
        lib.addRadialItem({
            id       = 'dead_emergency',
            label    = 'Botão de Emergência',
            icon     = 'circle-exclamation',
            onSelect = function()
                if jobType == 'leo' then
                    TriggerEvent('police:client:SendPoliceEmergencyAlert')
                else
                    TriggerServerEvent('hospital:server:emergencyAlert')
                end
                lib.hideRadial()
            end,
        })
    else
        lib.clearRadialItems()
        TriggerEvent('pr_menu:radial:setup')
        lib.disableRadial(false)
    end
end)

-- =============================================================================
-- TRUNK — Sistema completo de entrar/sair do porta-mala
-- =============================================================================
local inTrunk   = false
local trunkCam  = 0
local isKidnapped = false

local function setTrunkCam(enable, vehicle)
    if enable then
        if DoesCamExist(trunkCam) then DestroyCam(trunkCam, false) end
        local drawPos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -5.5, 0)
        trunkCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        SetCamActive(trunkCam, true)
        SetCamCoord(trunkCam, drawPos.x, drawPos.y, drawPos.z + 2)
        SetCamRot(trunkCam, -2.5, 0.0, GetEntityHeading(vehicle), 0.0)
        RenderScriptCams(true, false, 0, true, true)
    else
        RenderScriptCams(false, false, 0, true, false)
        if DoesCamExist(trunkCam) then DestroyCam(trunkCam, false); trunkCam = 0 end
    end
end

local function enterTrunk(vehicle, kidnapMode)
    local ped      = cache and cache.ped or PlayerPedId()
    local vehClass = GetVehicleClass(vehicle)
    local plate    = pr_menu.getVehiclePlate(vehicle)
    local cls      = Config.Trunk.classes[vehClass]

    if not cls or not cls.allowed then
        pr_menu.notify({ title = 'Porta-mala', description = 'Veículo não suportado!', type = 'error' })
        return
    end
    if Config.Trunk.disabled[GetEntityModel(vehicle)] then
        pr_menu.notify({ title = 'Porta-mala', description = 'Modelo bloqueado!', type = 'error' })
        return
    end
    if inTrunk then
        pr_menu.notify({ title = 'Porta-mala', description = 'Você já está em um porta-mala!', type = 'error' })
        return
    end

    local isBusy = lib.callback.await('pr_menu:trunk:isBusy', false, plate)
    if isBusy then
        pr_menu.notify({ title = 'Porta-mala', description = 'Porta-mala ocupado!', type = 'error' })
        return
    end

    if GetVehicleDoorAngleRatio(vehicle, 5) <= 0.0 then
        pr_menu.notify({ title = 'Porta-mala', description = 'Porta-mala fechado!', type = 'error' })
        return
    end

    lib.playAnim(ped, 'fin_ext_p1-7', 'cs_devin_dual-7', 8.0, 8.0, -1, 1, 999.0, false, false, false)
    AttachEntityToEntity(ped, vehicle, 0, cls.x, cls.y, cls.z, 0, 0, 40.0, true, true, true, true, 1, true)
    TriggerServerEvent('pr_menu:trunk:setBusy', plate, true)

    inTrunk     = true
    isKidnapped = kidnapMode or false

    Wait(500)
    SetVehicleDoorShut(vehicle, 5, false)
    pr_menu.notify({ title = 'Porta-mala', description = 'Você entrou no porta-mala!', type = 'success' })
    setTrunkCam(true, vehicle)
end

RegisterNetEvent('pr_menu:trunk:getIn', function(targetVehicle)
    local veh = targetVehicle or pr_menu.getClosestVehicle(5.0)
    if not veh then
        pr_menu.notify({ title = 'Porta-mala', description = 'Nenhum veículo encontrado!', type = 'error' })
        return
    end
    enterTrunk(veh, false)
end)

RegisterNetEvent('pr_menu:trunk:kidnapGetIn', function(vehicle)
    if vehicle then enterTrunk(vehicle, true) end
end)

RegisterNetEvent('pr_menu:trunk:setKidnapping', function(state)
    -- usado pelo servidor para sinalizar modo kidnap
end)

-- Thread: atualiza câmera do trunk
CreateThread(function()
    while true do
        local sleep = 1000
        if DoesCamExist(trunkCam) then
            sleep = 0
            local ped = cache and cache.ped or PlayerPedId()
            local veh = GetEntityAttachedTo(ped)
            if DoesEntityExist(veh) then
                local drawPos = GetOffsetFromEntityInWorldCoords(veh, 0, -5.5, 0)
                SetCamRot(trunkCam, -2.5, 0.0, GetEntityHeading(veh), 0.0)
                SetCamCoord(trunkCam, drawPos.x, drawPos.y, drawPos.z + 2)
            end
        end
        Wait(sleep)
    end
end)

-- Thread: controles dentro do trunk
CreateThread(function()
    while true do
        local sleep = 1000
        if inTrunk and not isKidnapped then
            local ped = cache and cache.ped or PlayerPedId()
            local veh = GetEntityAttachedTo(ped)
            if DoesEntityExist(veh) then
                sleep = 0
                local plate   = pr_menu.getVehiclePlate(veh)
                local drawPos = GetOffsetFromEntityInWorldCoords(veh, 0, -2.5, 0)

                pr_menu.drawText3D(drawPos.x, drawPos.y, drawPos.z + 0.75, '[E] Sair do porta-mala')

                if IsControlJustPressed(0, 38) then   -- E
                    if GetVehicleDoorAngleRatio(veh, 5) > 0 then
                        local vehCoords = GetOffsetFromEntityInWorldCoords(veh, 0, -5.0, 0)
                        DetachEntity(ped, true, true)
                        ClearPedTasks(ped)
                        inTrunk = false
                        TriggerServerEvent('pr_menu:trunk:setBusy', plate, false)
                        SetEntityCoords(ped, vehCoords.x, vehCoords.y, vehCoords.z, false, false, false, false)
                        SetEntityCollision(ped, true, true)
                        setTrunkCam(false)
                    else
                        pr_menu.notify({ title = 'Porta-mala', description = 'Porta-mala fechado!', type = 'error' })
                    end
                    Wait(100)
                end

                if GetVehicleDoorAngleRatio(veh, 5) > 0 then
                    pr_menu.drawText3D(drawPos.x, drawPos.y, drawPos.z + 0.5, '[G] Fechar porta-mala')
                    if IsControlJustPressed(0, 47) then   -- G
                        if not IsVehicleSeatFree(veh, -1) then
                            TriggerServerEvent('pr_menu:door:serverSync', false, plate, 5)
                        else
                            SetVehicleDoorShut(veh, 5, false)
                        end
                        Wait(100)
                    end
                else
                    pr_menu.drawText3D(drawPos.x, drawPos.y, drawPos.z + 0.5, '[G] Abrir porta-mala')
                    if IsControlJustPressed(0, 47) then
                        if not IsVehicleSeatFree(veh, -1) then
                            TriggerServerEvent('pr_menu:door:serverSync', true, plate, 5)
                        else
                            SetVehicleDoorOpen(veh, 5, false, false)
                        end
                        Wait(100)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- =============================================================================
-- EXPORTS — acessíveis por qualquer outro resource
-- =============================================================================
exports('notify',              function(data)        pr_menu.notify(data) end)
exports('hasCarKey',           function(veh)         return pr_menu.hasCarKey(veh) end)
exports('getVehiclePlate',     function(veh)         return pr_menu.getVehiclePlate(veh) end)
exports('getClosestVehicle',   function(d)           return pr_menu.getClosestVehicle(d) end)
exports('toggleDoor',          function(veh, i, rk)  pr_menu.toggleDoor(veh, i, rk) end)
exports('toggleWindow',        function(veh, i)      pr_menu.toggleWindow(veh, i) end)
exports('toggleExtra',         function(veh, i)      pr_menu.toggleExtra(veh, i) end)
exports('openTrunkInventory',  function(veh)         pr_menu.openTrunkInventory(veh) end)
exports('openStash',           function(id, data)    pr_menu.openStash(id, data) end)
exports('closeInventory',      function()            pr_menu.closeInventory() end)
exports('getItemCount',        function(item, meta)  return pr_menu.getItemCount(item, meta) end)
exports('doProgressBar',       function(dur, lbl, a) return pr_menu.doProgressBar(dur, lbl, a) end)
exports('getNearestDoorIndex', function(veh, c)      return pr_menu.getNearestDoorIndex(veh, c) end)
exports('getNearestWindowIndex', function(veh, c)    return pr_menu.getNearestWindowIndex(veh, c) end)
exports('hasPermission',       function(duty, lvl)   return hasPermission(duty, lvl) end)
