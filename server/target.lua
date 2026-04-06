-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | server/target.lua
-- ─────────────────────────────────────────────────────────────────────────────

-- Algemar / Desalgemar
RegisterNetEvent('pr_menu:cuffPlayer', function(targetId, cuffState)
    local src = source

    if not pr_menu_sv.hasPermission(src, 'police', 0) then
        lib.print.warn(('[pr_menu] %s tentou algemar sem permissão.'):format(src))
        pr_menu_sv.notify(src, { title = 'Erro', description = 'Sem permissão!', type = 'error' })
        return
    end

    if not GetPlayerPed(targetId) then
        lib.print.warn(('[pr_menu] Alvo %s não encontrado.'):format(targetId))
        return
    end

    TriggerClientEvent('pr_menu:applyCuff', targetId, cuffState)
    lib.print.info(('[pr_menu] %s %s o jogador %s.'):format(
        src, cuffState and 'algemou' or 'desalmou', targetId))
end)

-- Abrir baú do porta-mala via Bridge.inventory
RegisterNetEvent('pr_menu:openTrunkInventory', function(plate)
    local src = source

    if not plate or plate == '' then
        lib.print.warn(('[pr_menu] openTrunkInventory: placa inválida de %s.'):format(src))
        return
    end

    plate = plate:gsub('%s+', ''):upper()
    pr_menu_sv.openInventory(src, 'trunk', { id = plate })
    lib.print.info(('[pr_menu] %s abriu baú do veículo [%s].'):format(src, plate))
end)
