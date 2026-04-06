-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | server/functions.lua
-- Funções auxiliares server-side usando Bridge (Fivem_bridge)
-- ─────────────────────────────────────────────────────────────────────────────
pr_menu_sv = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu_sv.hasPermission(source, duty, lvl) → boolean
-- Verifica emprego/grade via Bridge.framework.getPlayerJob (Fivem_bridge)
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu_sv.hasPermission(source, duty, lvl)
    if not duty then return true end
    if not Bridge or not Bridge.framework then return false end

    local ok, jobName = pcall(Bridge.framework.getPlayerJob, source, 'name')
    if not ok or not jobName then return false end
    if jobName ~= duty then return false end

    if lvl then
        local ok2, grade = pcall(Bridge.framework.getPlayerJob, source, 'grade')
        if not ok2 then return false end
        if (grade or 0) < lvl then return false end
    end

    return true
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu_sv.notify(source, data)
-- Notificação server→client via Bridge.notify (Fivem_bridge)
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu_sv.notify(source, data)
    if Bridge and Bridge.notify and Bridge.notify.Notify then
        Bridge.notify.Notify(source, data)
    else
        TriggerClientEvent('ox_lib:notify', source, data)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu_sv.openInventory(source, invType, data)
-- Abre inventário via Bridge.inventory (Fivem_bridge)
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu_sv.openInventory(source, invType, data)
    if Bridge and Bridge.inventory and Bridge.inventory.forceOpenInventory then
        Bridge.inventory.forceOpenInventory(source, invType, data)
    else
        -- fallback direto ox_inventory
        exports.ox_inventory:openInventory(source, { type = invType, id = data.id or data })
    end
end
