-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | server/target.lua
-- Callbacks server-side para operações que exigem validação no servidor
-- ─────────────────────────────────────────────────────────────────────────────

-- ─────────────────────────────────────────────────────────────────────────────
-- Utilitário: verifica se o jogador tem permissão para uma ação com duty
-- ─────────────────────────────────────────────────────────────────────────────
local function serverHasPermission(src, duty, lvl)
    if not duty then return true end

    -- QBX Core
    if GetResourceState('qbx_core') == 'started' then
        local ok, player = pcall(exports.qbx_core.GetPlayer, exports.qbx_core, src)
        if not ok or not player then return false end
        local job = player.PlayerData.job
        if job.name ~= duty then return false end
        if lvl and job.grade.level < lvl then return false end
        return true
    end

    -- ESX
    if GetResourceState('es_extended') == 'started' then
        local ok, ESX = pcall(exports['es_extended'].getSharedObject, exports['es_extended'])
        if not ok or not ESX then return false end
        local player = ESX.GetPlayerFromId(src)
        if not player then return false end
        local job = player.getJob()
        if job.name ~= duty then return false end
        if lvl and job.grade < lvl then return false end
        return true
    end

    return false
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Algemar / Desalgemar jogador
-- Adapte para o seu resource de algemas
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('pr_menu:cuffPlayer', function(targetServerId, cuffState)
    local src = source

    if not serverHasPermission(src, 'police', 0) then
        lib.print.warn(('[pr_menu] Jogador %s tentou algemar sem permissão.'):format(src))
        return
    end

    if not GetPlayerPed(targetServerId) then
        lib.print.warn(('[pr_menu] Jogador alvo %s não encontrado.'):format(targetServerId))
        return
    end

    -- Dispara no cliente do alvo (integre com seu resource de algemas)
    TriggerClientEvent('pr_menu:applyCuff', targetServerId, cuffState)

    lib.print.info(('[pr_menu] Jogador %s %s jogador %s.'):format(
        src,
        cuffState and 'algemou' or 'desalmou',
        targetServerId
    ))
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Abre o baú do porta-mala via ox_inventory
-- Recebe a placa (plate) do veículo como identificador do inventário
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('pr_menu:openTrunkInventory', function(plate)
    local src = source

    if not plate or plate == '' then
        lib.print.warn(('[pr_menu] openTrunkInventory: placa inválida recebida de %s.'):format(src))
        return
    end

    -- Sanitiza a placa (remove espaços residuais)
    plate = plate:gsub('%s+', ''):upper()

    -- ox_inventory — abre o inventário do tipo 'trunk' identificado pela placa
    exports.ox_inventory:openInventory(src, { type = 'trunk', id = plate })

    lib.print.info(('[pr_menu] Jogador %s abriu baú do veículo [%s].'):format(src, plate))
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Callback recebido no cliente alvo para aplicar algemas
-- Adapte para o seu resource (ex: ps-handcuffs, copcuff, etc.)
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('pr_menu:applyCuff', function(cuffState)
    -- Este evento chega no cliente do jogador que será algemado
    -- Exemplo: TriggerEvent('handcuff:cuff', cuffState)
    lib.print.info(('[pr_menu] Recebendo cuff: %s'):format(tostring(cuffState)))
end)
