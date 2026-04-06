-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | config/config.lua
-- Configuração principal — editável sem tocar no código
-- ─────────────────────────────────────────────────────────────────────────────
Config = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Chave de veículo
-- O Fivem_bridge detecta automaticamente: mm_carkeys, mri_Qcarkeys,
-- qb-vehiclekeys, qbx_vehiclekeys, wasabi_carlock
-- true  = verifica chave antes de abrir porta/porta-mala
-- false = não verifica (qualquer um pode abrir)
-- ─────────────────────────────────────────────────────────────────────────────
Config.UseVehicleKey = true

-- ─────────────────────────────────────────────────────────────────────────────
-- Distâncias padrão de ativação de target (metros)
-- ─────────────────────────────────────────────────────────────────────────────
Config.Distance = {
    default = 2.0,
    vehicle = 2.5,
    player  = 2.0,
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Trunk (porta-mala ocupável)
-- ─────────────────────────────────────────────────────────────────────────────
Config.Trunk = {
    -- Duração do progressBar ao virar veículo (ms)
    flipTime = 15000,

    -- Veículos que NÃO aceitam pessoas no porta-mala
    disabled = {
        [`penetrator`] = true, [`vacca`]    = true, [`monroe`]   = true,
        [`turismor`]   = true, [`osiris`]   = true, [`comet`]    = true,
        [`ardent`]     = true, [`jester`]   = true, [`nero`]     = true,
        [`nero2`]      = true, [`vagner`]   = true, [`infernus`] = true,
        [`zentorno`]   = true, [`comet2`]   = true, [`comet3`]   = true,
        [`comet4`]     = true, [`bullet`]   = true,
    },

    -- Offset de posição por classe de veículo (GTA class index)
    classes = {
        [0]  = { allowed = true,  x = 0.0, y = -1.5, z = 0.0  }, -- Coupes
        [1]  = { allowed = true,  x = 0.0, y = -2.0, z = 0.0  }, -- Sedans
        [2]  = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 }, -- SUVs
        [3]  = { allowed = true,  x = 0.0, y = -1.5, z = 0.0  }, -- Coupes
        [4]  = { allowed = true,  x = 0.0, y = -2.0, z = 0.0  }, -- Muscle
        [5]  = { allowed = true,  x = 0.0, y = -2.0, z = 0.0  }, -- Sports Classics
        [6]  = { allowed = true,  x = 0.0, y = -2.0, z = 0.0  }, -- Sports
        [7]  = { allowed = true,  x = 0.0, y = -2.0, z = 0.0  }, -- Super
        [8]  = { allowed = false, x = 0.0, y = -1.0, z = 0.25 }, -- Motorcycles
        [9]  = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 }, -- Off-road
        [10] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 }, -- Industrial
        [11] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 }, -- Utility
        [12] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 }, -- Vans
        [13] = { allowed = false, x = 0.0, y = -1.0, z = 0.25 }, -- Cycles
        [14] = { allowed = false, x = 0.0, y = -1.0, z = 0.25 }, -- Boats
        [15] = { allowed = false, x = 0.0, y = -1.0, z = 0.25 }, -- Helicopters
        [16] = { allowed = false, x = 0.0, y = -1.0, z = 0.25 }, -- Planes
        [17] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 }, -- Service
        [18] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 }, -- Emergency
        [19] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 }, -- Military
        [20] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 }, -- Commercial
        [21] = { allowed = false, x = 0.0, y = -1.0, z = 0.25 }, -- Trains
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Radial Menu
-- ─────────────────────────────────────────────────────────────────────────────
Config.RadialMenu = {
    maxExtras    = 13,   -- quantos extras exibir no menu de extras do veículo
    vehicleSeats = true, -- exibir menu de assentos ao entrar no veículo
}
