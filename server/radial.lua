-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | server/radial.lua
-- ─────────────────────────────────────────────────────────────────────────────

-- ─────────────────────────────────────────────────────────────────────────────
-- Trunk busy — quem está no porta-mala (indexado por placa)
-- ─────────────────────────────────────────────────────────────────────────────
local trunkBusy = {}

RegisterNetEvent('pr_menu:trunk:setBusy', function(plate, busy)
    trunkBusy[plate] = busy or nil
end)

lib.callback.register('pr_menu:trunk:isBusy', function(_, plate)
    return trunkBusy[plate] == true
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Door sync — sincroniza abertura de porta para todos (quando há motorista)
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('pr_menu:door:serverSync', function(open, plate, doorIndex)
    TriggerClientEvent('pr_menu:door:sync', -1, plate, doorIndex, open)
end)

-- Alias retrocompatibilidade qb-radialmenu
RegisterNetEvent('qb-radialmenu:trunk:server:Door', function(open, plate, door)
    TriggerClientEvent('pr_menu:door:sync', -1, plate, door, open)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Trunk kidnap — força alvo no porta-mala
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('pr_menu:trunk:kidnap', function(targetId, vehicle)
    local src = source
    if not pr_menu_sv.hasPermission(src, 'police', 0) then
        pr_menu_sv.notify(src, { title = 'Erro', description = 'Sem permissão!', type = 'error' })
        return
    end
    if not GetPlayerPed(targetId) then return end
    TriggerClientEvent('pr_menu:trunk:kidnapGetIn', targetId, vehicle)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Dead radial — state bag qbx_medical
-- ─────────────────────────────────────────────────────────────────────────────
AddStateBagChangeHandler('qbx_medical:deathState', nil, function(bagName, _, value)
    local playerId = GetPlayerFromStateBagName(bagName)
    if not playerId then return end
    TriggerClientEvent('radialmenu:client:deadradial', playerId, value == 2 or value == 3)
end)

-- Compatibilidade qb-ambulancejob
RegisterNetEvent('hospital:server:SetDeathStatus', function(isDead)
    TriggerClientEvent('radialmenu:client:deadradial', source, isDead)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Comandos de servidor
-- ─────────────────────────────────────────────────────────────────────────────
lib.addCommand('getintrunk', {
    help = 'Entrar no porta-mala do veículo mais próximo',
}, function(src)
    TriggerClientEvent('pr_menu:trunk:getIn', src, nil)
end)

lib.addCommand('putintrunk', {
    help    = 'Colocar jogador no porta-mala (polícia)',
    params  = { { name = 'id', type = 'number', help = 'ID do servidor do alvo' } },
}, function(src, args)
    if not pr_menu_sv.hasPermission(src, 'police', 0) then
        pr_menu_sv.notify(src, { title = 'Erro', description = 'Sem permissão!', type = 'error' })
        return
    end
    local targetId = args.id
    if not GetPlayerPed(targetId) then
        pr_menu_sv.notify(src, { title = 'Erro', description = 'Jogador não encontrado!', type = 'error' })
        return
    end
    TriggerClientEvent('pr_menu:trunk:setKidnapping', src, true)
    TriggerClientEvent('pr_menu:trunk:kidnapGetIn', targetId, nil)
end)
