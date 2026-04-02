-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | client/target.lua
-- Sistema de target para veículos e jogadores via ox_target
--
-- Lógica de agrupamento:
--   • Mesmo 'id' em múltiplas entradas → submenu automático (openMenu/menuName)
--   • Entrada única com campo 'children' → submenu aninhado
--   • Entrada única sem 'children'       → ação direta
-- ─────────────────────────────────────────────────────────────────────────────

-- Namespace global exposto para uso nos callbacks definidos em config.lua
-- Os helpers ficam disponíveis por referência: pr_menu.getNearestDoorIndex(...)
pr_menu = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Tabela de estado local (janelas, etc.)
-- ─────────────────────────────────────────────────────────────────────────────
LocalState = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Mapeamento bone → índice de porta / janela
-- ─────────────────────────────────────────────────────────────────────────────
local DOOR_BONE_MAP = {
    { bone = 'door_dside_f',  index = 0 },  -- frente motorista
    { bone = 'door_pside_f',  index = 1 },  -- frente passageiro
    { bone = 'door_dside_r',  index = 2 },  -- trás motorista
    { bone = 'door_pside_r',  index = 3 },  -- trás passageiro
    { bone = 'door_dside_r2', index = 2 },  -- extra (vans/trucks)
    { bone = 'door_pside_r2', index = 3 },
}

local WINDOW_BONE_MAP = {
    { bone = 'door_dside_f',  index = 0 },
    { bone = 'door_pside_f',  index = 1 },
    { bone = 'door_dside_r',  index = 2 },
    { bone = 'door_pside_r',  index = 3 },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.getNearestDoorIndex(vehicle, coords)
-- Retorna o índice da porta cujo bone está mais próximo das coords apontadas
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.getNearestDoorIndex(vehicle, coords)
    local nearest, nearestDist = 0, math.huge

    for _, entry in ipairs(DOOR_BONE_MAP) do
        local boneId = GetEntityBoneIndexByName(vehicle, entry.bone)
        if boneId ~= -1 then
            local bonePos = GetEntityBonePosition_2(vehicle, boneId)
            local dist    = #(coords - bonePos)
            if dist < nearestDist then
                nearest     = entry.index
                nearestDist = dist
            end
        end
    end

    return nearest
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.getNearestWindowIndex(vehicle, coords)
-- Retorna o índice da janela cujo bone está mais próximo das coords apontadas
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.getNearestWindowIndex(vehicle, coords)
    local nearest, nearestDist = 0, math.huge

    for _, entry in ipairs(WINDOW_BONE_MAP) do
        local boneId = GetEntityBoneIndexByName(vehicle, entry.bone)
        if boneId ~= -1 then
            local bonePos = GetEntityBonePosition_2(vehicle, boneId)
            local dist    = #(coords - bonePos)
            if dist < nearestDist then
                nearest     = entry.index
                nearestDist = dist
            end
        end
    end

    return nearest
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.getVehicleDoorCount(vehicle)
-- Conta quantas portas laterais o veículo possui (verifica existência dos bones)
-- Útil para exibir no menu ou fazer canInteract condicional
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.getVehicleDoorCount(vehicle)
    local count = 0
    local checked = {}  -- evita contar o mesmo índice duas vezes (vans)

    for _, entry in ipairs(DOOR_BONE_MAP) do
        if not checked[entry.index] and GetEntityBoneIndexByName(vehicle, entry.bone) ~= -1 then
            count             = count + 1
            checked[entry.index] = true
        end
    end

    return count
end

-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu.hasCarKey(vehicle)
-- Verifica se o jogador possui a chave do veículo via resource de chaves
-- ─────────────────────────────────────────────────────────────────────────────
function pr_menu.hasCarKey(vehicle)
    if not Config.Vehicle_key then return true end
    if GetResourceState(Config.Vehicle_key) ~= 'started' then return true end

    local plate = GetVehicleNumberPlateText(vehicle):gsub('%s+', ''):upper()

    -- verifica se o jogador possui a chave da placa
    local ok, result = pcall(function()
        return exports[Config.Vehicle_key]:hasKey(plate)
    end)

    if not ok then
        -- Export não encontrado ou erro — libera por segurança e loga
        lib.print.warn(('[pr_menu] %s:hasKey falhou para placa %s. Liberando acesso.'):format(Config.Vehicle_key, plate))
        return true
    end

    return result == true
end

-- ─────────────────────────────────────────────────────────────────────────────
-- hasPermission(duty, lvl)
-- Verifica se o jogador local possui o emprego e grade mínima exigidos
-- Compatível com QBX Core e ESX
-- ─────────────────────────────────────────────────────────────────────────────
local function hasPermission(duty, lvl)
    if not duty then return true end

    -- QBX Core
    if GetResourceState('qbx_core') == 'started' then
        local ok, player = pcall(exports.qbx_core.GetPlayerData, exports.qbx_core)
        if not ok or not player then return false end
        if player.job.name ~= duty then return false end
        if lvl and player.job.grade.level < lvl then return false end
        return true
    end

    -- ESX
    if GetResourceState('es_extended') == 'started' then
        local ok, ESX = pcall(exports['es_extended'].getSharedObject, exports['es_extended'])
        if not ok or not ESX then return false end
        local job = ESX.GetPlayerData().job
        if job.name ~= duty then return false end
        if lvl and job.grade < lvl then return false end
        return true
    end

    return false
end

-- ─────────────────────────────────────────────────────────────────────────────
-- groupById(list)
-- Agrupa entradas do config pelo campo 'id', preservando ordem de inserção
-- Retorna: groups (map id → {items}), order (lista de ids na ordem original)
-- ─────────────────────────────────────────────────────────────────────────────
local function groupById(list)
    local groups, order = {}, {}

    for _, item in ipairs(list) do
        local id = item.id
        if not groups[id] then
            groups[id]     = {}
            order[#order + 1] = id
        end
        groups[id][#groups[id] + 1] = item
    end

    return groups, order
end

-- ─────────────────────────────────────────────────────────────────────────────
-- buildOption(item, menuName, defaultDist)
-- Monta uma opção simples do ox_target (ação direta ou filho de submenu)
-- ─────────────────────────────────────────────────────────────────────────────
local function buildOption(item, menuName, defaultDist)
    return {
        name     = ('%s_%s'):format(item.id, item.label:lower():gsub('[%s/]+', '_')),
        label    = item.label,
        icon     = item.icon,
        distance = item.distance or defaultDist or Config.Distance.default,
        bones    = item.bones,
        menuName = menuName,
        canInteract = function(entity)
            -- Verifica quantas portas o veículo tem (somente para veículos)
            if GetEntityType(entity) == 2 and item.bones then
                local hasBone = false
                for _, b in ipairs(item.bones) do
                    if GetEntityBoneIndexByName(entity, b) ~= -1 then
                        hasBone = true
                        break
                    end
                end
                if not hasBone then return false end
            end
            return hasPermission(item.duty, item.lvl)
        end,
        onSelect = item.onSelect,
    }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- buildWithChildren(parent, children, defaultDist)
-- Entrada única com 'children' → cria pai que abre submenu + filhos
-- ─────────────────────────────────────────────────────────────────────────────
local function buildWithChildren(parent, children, defaultDist)
    local menuId = 'pr_' .. parent.id
    local result = {}

    -- Opção pai (abre o submenu ao ser clicada)
    result[#result + 1] = {
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

    -- Filhos (visíveis somente quando menuId estiver ativo)
    for _, child in ipairs(children) do
        local opt  = buildOption(child, menuId, defaultDist)
        opt.bones  = parent.bones  -- filhos herdam bones do pai
        result[#result + 1] = opt
    end

    return result
end

-- ─────────────────────────────────────────────────────────────────────────────
-- buildMergedGroup(id, items, defaultDist)
-- Múltiplas entradas com mesmo id → cria pai automático + todos como filhos
-- ─────────────────────────────────────────────────────────────────────────────
local function buildMergedGroup(id, items, defaultDist)
    local menuId = 'pr_' .. id
    local first  = items[1]
    local result = {}

    -- Opção pai gerada automaticamente
    -- Usa 'groupLabel' se definido, senão usa o label do primeiro item
    result[#result + 1] = {
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

    -- Todos os items do grupo viram filhos do submenu
    for _, item in ipairs(items) do
        local opt = buildOption(item, menuId, defaultDist)
        opt.bones = first.bones  -- herdam bones do pai do grupo
        result[#result + 1] = opt
    end

    return result
end

-- ─────────────────────────────────────────────────────────────────────────────
-- processTargetList(list, defaultDist)
-- Processa uma lista de Config.Targets e gera a tabela de opções para ox_target
-- ─────────────────────────────────────────────────────────────────────────────
local function processTargetList(list, defaultDist)
    local allOptions    = {}
    local groups, order = groupById(list)

    for _, id in ipairs(order) do
        local items = groups[id]
        local first = items[1]
        local built = {}

        if #items == 1 then
            if first.children and #first.children > 0 then
                -- Entrada única com children → submenu aninhado
                built = buildWithChildren(first, first.children, defaultDist)
            else
                -- Entrada única sem children → ação direta
                built = { buildOption(first, nil, defaultDist) }
            end
        else
            -- Múltiplas entradas com mesmo id → fundir em submenu automático
            built = buildMergedGroup(id, items, defaultDist)
        end

        for _, opt in ipairs(built) do
            allOptions[#allOptions + 1] = opt
        end
    end

    return allOptions
end

-- ─────────────────────────────────────────────────────────────────────────────
-- registerTargets()
-- Registra todos os targets no ox_target
-- ─────────────────────────────────────────────────────────────────────────────
local function registerTargets()
    -- Veículos
    if Config.Targets.Vehicle and #Config.Targets.Vehicle > 0 then
        local opts = processTargetList(Config.Targets.Vehicle, Config.Distance.vehicle)

        if #opts > 0 then
            exports.ox_target:addGlobalVehicle(opts)
            lib.print.info(('[pr_menu] %d opções registradas para veículos.'):format(#opts))
        end
    end

    -- Jogadores
    if Config.Targets.Player and #Config.Targets.Player > 0 then
        local opts = processTargetList(Config.Targets.Player, Config.Distance.player)

        if #opts > 0 then
            exports.ox_target:addGlobalPlayer(opts)
            lib.print.info(('[pr_menu] %d opções registradas para jogadores.'):format(#opts))
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Inicialização — aguarda ox_target estar disponível
-- ─────────────────────────────────────────────────────────────────────────────
CreateThread(function()
    while GetResourceState('ox_target') ~= 'started' do
        Wait(500)
    end

    registerTargets()
end)
