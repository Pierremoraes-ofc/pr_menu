-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | client/target.lua
-- Registro de targets no ox_target.
-- Combina config/target.lua (declarativo) com entradas externas via exports.
--
-- Exports disponíveis:
--   exports.pr_menu:CreateTarget(targetType, entry)
--   exports.pr_menu:CreateTargetBatch(targetType, entries)
--   exports.pr_menu:RemoveTarget(optionName)
-- ─────────────────────────────────────────────────────────────────────────────

-- Mapa de tipo → função do ox_target
local OX_TARGET_FN = {
    Vehicle      = 'addGlobalVehicle',
    Player       = 'addGlobalPlayer',
    Ped          = 'addGlobalPed',
    Object       = 'addGlobalObject',
    SphereZone   = 'addSphereZone',
    BoxZone      = 'addBoxZone',
    PolyZone     = 'addPolyZone',
    GlobalOption = 'addGlobalOption',
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Helpers de build (agrupamento / submenu)
-- ─────────────────────────────────────────────────────────────────────────────
local function groupById(list)
    local groups, order = {}, {}
    for _, item in ipairs(list) do
        local id = item.id
        if not groups[id] then
            groups[id] = {}
            order[#order + 1] = id
        end
        groups[id][#groups[id] + 1] = item
    end
    return groups, order
end

local function buildOption(item, menuName, defaultDist)
    return {
        name     = ('%s_%s'):format(item.id, item.label:lower():gsub('[%s/]+', '_')),
        label    = item.label,
        icon     = item.icon,
        distance = item.distance or defaultDist or Config.Distance.default,
        bones    = item.bones,
        menuName = menuName,
        canInteract = function(entity)
            if GetEntityType(entity) == 2 and item.bones then
                local found = false
                for _, b in ipairs(item.bones) do
                    if GetEntityBoneIndexByName(entity, b) ~= -1 then found = true; break end
                end
                if not found then return false end
            end
            return hasPermission(item.duty, item.lvl)
        end,
        onSelect = item.onSelect,
    }
end

local function buildWithChildren(parent, children, defaultDist)
    local menuId = 'pr_' .. parent.id
    local result = {
        {
            name     = parent.id .. '_parent',
            label    = parent.label,
            icon     = parent.icon,
            distance = parent.distance or defaultDist or Config.Distance.default,
            bones    = parent.bones,
            openMenu = menuId,
            canInteract = function(entity)
                if GetEntityType(entity) == 2 and parent.bones then
                    for _, b in ipairs(parent.bones) do
                        if GetEntityBoneIndexByName(entity, b) ~= -1 then
                            return hasPermission(parent.duty, parent.lvl)
                        end
                    end
                    return false
                end
                return hasPermission(parent.duty, parent.lvl)
            end,
        }
    }
    for _, child in ipairs(children) do
        local opt = buildOption(child, menuId, defaultDist)
        opt.bones = parent.bones
        result[#result + 1] = opt
    end
    return result
end

local function buildMergedGroup(id, items, defaultDist)
    local menuId = 'pr_' .. id
    local first  = items[1]
    local result = {
        {
            name     = id .. '_group',
            label    = first.groupLabel or first.label,
            icon     = first.icon,
            distance = first.distance or defaultDist or Config.Distance.default,
            bones    = first.bones,
            openMenu = menuId,
            canInteract = function(entity)
                if GetEntityType(entity) == 2 and first.bones then
                    for _, b in ipairs(first.bones) do
                        if GetEntityBoneIndexByName(entity, b) ~= -1 then
                            return hasPermission(first.duty, first.lvl)
                        end
                    end
                    return false
                end
                return hasPermission(first.duty, first.lvl)
            end,
        }
    }
    for _, item in ipairs(items) do
        local opt = buildOption(item, menuId, defaultDist)
        opt.bones = first.bones
        result[#result + 1] = opt
    end
    return result
end

local function processTargetList(list, defaultDist)
    local allOptions    = {}
    local groups, order = groupById(list)
    for _, id in ipairs(order) do
        local items = groups[id]
        local first = items[1]
        local built = {}
        if #items == 1 then
            if first.children and #first.children > 0 then
                built = buildWithChildren(first, first.children, defaultDist)
            else
                built = { buildOption(first, nil, defaultDist) }
            end
        else
            built = buildMergedGroup(id, items, defaultDist)
        end
        for _, opt in ipairs(built) do allOptions[#allOptions + 1] = opt end
    end
    return allOptions
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Registro de todos os targets do config/target.lua
-- ─────────────────────────────────────────────────────────────────────────────
local function registerConfigTargets()
    local T = Target.Targets
    local registrations = {
        { type = 'Vehicle',      dist = Config.Distance.vehicle,  label = 'veículos'     },
        { type = 'Player',       dist = Config.Distance.player,   label = 'jogadores'    },
        { type = 'Ped',          dist = Config.Distance.default,  label = 'peds'         },
        { type = 'Object',       dist = Config.Distance.default,  label = 'objetos'      },
        { type = 'SphereZone',   dist = Config.Distance.default,  label = 'SphereZone'   },
        { type = 'BoxZone',      dist = Config.Distance.default,  label = 'BoxZone'      },
        { type = 'PolyZone',     dist = Config.Distance.default,  label = 'PolyZone'     },
        { type = 'GlobalOption', dist = Config.Distance.default,  label = 'GlobalOption' },
    }
    for _, reg in ipairs(registrations) do
        local list = T[reg.type]
        if list and #list > 0 then
            local opts = processTargetList(list, reg.dist)
            if #opts > 0 then
                local fn = OX_TARGET_FN[reg.type]
                exports.ox_target[fn](exports.ox_target, opts)
                lib.print.info(('[pr_menu] %d targets registrados para %s.'):format(#opts, reg.label))
            end
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT: CreateTarget
-- Registra uma ou mais entradas externas no ox_target.
-- Segue exatamente a mesma lógica de config/target.lua.
--
-- Uso:
--   exports.pr_menu:CreateTarget('Vehicle', { id = 'vehicle_capo', ... })
--   exports.pr_menu:CreateTarget('Player',  { id = 'player_busca', ... })
-- ─────────────────────────────────────────────────────────────────────────────
exports('CreateTarget', function(targetType, entry)
    assert(type(targetType) == 'string', '[pr_menu] CreateTarget: targetType deve ser string')
    assert(type(entry) == 'table',       '[pr_menu] CreateTarget: entry deve ser table')

    local fn = OX_TARGET_FN[targetType]
    assert(fn, ('[pr_menu] CreateTarget: tipo inválido "%s"'):format(targetType))

    local dist = (targetType == 'Vehicle' and Config.Distance.vehicle)
              or (targetType == 'Player'  and Config.Distance.player)
              or Config.Distance.default

    -- Permite enviar lista de entradas ou entrada única
    local list = entry[1] and entry or { entry }
    local opts = processTargetList(list, dist)

    if #opts > 0 then
        exports.ox_target[fn](exports.ox_target, opts)
        lib.print.info(('[pr_menu] CreateTarget(%s): %d opções registradas externamente.'):format(targetType, #opts))
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT: CreateTargetBatch
-- Registra múltiplas entradas de tipos diferentes de uma vez.
--
-- Uso:
--   exports.pr_menu:CreateTargetBatch({
--       { type = 'Vehicle', entry = { id = '...', ... } },
--       { type = 'Player',  entry = { id = '...', ... } },
--   })
-- ─────────────────────────────────────────────────────────────────────────────
exports('CreateTargetBatch', function(batch)
    assert(type(batch) == 'table', '[pr_menu] CreateTargetBatch: batch deve ser table')
    for _, item in ipairs(batch) do
        exports.pr_menu:CreateTarget(item.type, item.entry)
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT: RemoveTarget
-- Remove uma opção registrada por nome (name gerado automaticamente).
-- Para remover por id use:   'meu_id_meu label'  (lowercased, espaços → _)
-- Ou use o nome exato que foi retornado internamente.
--
-- Uso:
--   exports.pr_menu:RemoveTarget('vehicle_capo_capô')
-- ─────────────────────────────────────────────────────────────────────────────
exports('RemoveTarget', function(optionName)
    exports.ox_target:removeGlobalVehicle(optionName)
    exports.ox_target:removeGlobalPlayer(optionName)
    exports.ox_target:removeGlobalPed(optionName)
    exports.ox_target:removeGlobalObject(optionName)
    exports.ox_target:removeGlobalOption(optionName)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Init — aguarda ox_target estar disponível
-- ─────────────────────────────────────────────────────────────────────────────
CreateThread(function()
    while GetResourceState('ox_target') ~= 'started' do
        Wait(500)
    end
    registerConfigTargets()
end)
