-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | config/radial.lua
-- Itens declarativos do menu radial
--
-- ─── Campos por item ─────────────────────────────────────────────────────────
--   id          string    identificador único
--   icon        string    ícone FontAwesome (sem prefixo "fa-")
--   label       string    texto exibido
--   event       string?   TriggerEvent ao selecionar
--   serverEvent string?   TriggerServerEvent ao selecionar
--   args        any?      argumento enviado junto com o evento
--   onSelect    function? função direta (prioridade sobre event/serverEvent)
--   keepOpen    boolean?  mantém o radial aberto após selecionar
--   items       table?    sub-itens → cria submenu
--
-- ─── Uso externo (qualquer outro resource) ───────────────────────────────────
--   exports.pr_menu:AddRadialItem({ id='meu_item', icon='star', label='Meu Item',
--       event='meu_resource:cliente:evento' })
--   exports.pr_menu:RemoveRadialItem('meu_item')
-- ─────────────────────────────────────────────────────────────────────────────
Radial = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Itens globais — sempre visíveis (independente de emprego)
-- ─────────────────────────────────────────────────────────────────────────────
Radial.menuItems = {
    {
        id    = 'citizen',
        icon  = 'user',
        label = 'Cidadão',
        items = {
            {
                id    = 'getintrunk',
                icon  = 'car',
                label = 'Entrar no porta-mala',
                -- Chama a função de trunk centralizada em client/functions.lua
                onSelect = function()
                    TriggerEvent('pr_menu:trunk:getIn', nil)
                    lib.hideRadial()
                end,
            },
            {
                id    = 'givenum',
                icon  = 'address-book',
                label = 'Dar contato',
                event = 'qb-phone:client:GiveContactDetails',
            },
            {
                id    = 'interactions',
                icon  = 'exclamation-triangle',
                label = 'Interações',
                items = {
                    {
                        id    = 'escortPlayer',
                        icon  = 'user-group',
                        label = 'Escoltar',
                        event = 'police:client:EscortPlayer',
                    },
                    {
                        id    = 'takeHostage',
                        icon  = 'child',
                        label = 'Fazer refém',
                        event = 'police:client:TakeHostage',
                    },
                },
            },
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Itens por emprego — exibidos somente quando o jogador está on duty
-- Chave = nome exato do job
-- ─────────────────────────────────────────────────────────────────────────────
Radial.jobItems = {

    police = {
        {
            id    = 'emergencyButton',
            icon  = 'bell',
            label = 'Emergência',
            event = 'police:client:SendPoliceEmergencyAlert',
        },
        {
            id    = 'revokeDriversLicense',
            icon  = 'id-card',
            label = 'Revogar CNH',
            event = 'police:client:SeizeDriverLicense',
        },
        {
            id    = 'policeActions',
            icon  = 'list-check',
            label = 'Ações',
            items = {
                {
                    id    = 'statusCheck',
                    icon  = 'heart-pulse',
                    label = 'Verificar saúde',
                    event = 'hospital:client:CheckStatus',
                },
                {
                    id    = 'searchPlayer',
                    icon  = 'magnifying-glass',
                    label = 'Revistar',
                    event = 'police:client:SearchPlayer',
                },
                {
                    id    = 'jailPlayer',
                    icon  = 'user-lock',
                    label = 'Prender',
                    event = 'police:client:JailPlayer',
                },
            },
        },
        {
            id    = 'policeObjects',
            icon  = 'road',
            label = 'Objetos',
            items = {
                {
                    id    = 'cone',
                    icon  = 'triangle-exclamation',
                    label = 'Cone',
                    event = 'police:client:spawnPObj',
                    args  = 'cone',
                },
                {
                    id    = 'spikeStrip',
                    icon  = 'caret-up',
                    label = 'Tira-pneu',
                    event = 'police:client:SpawnSpikeStrip',
                },
                {
                    id    = 'deleteObj',
                    icon  = 'trash',
                    label = 'Deletar objeto',
                    event = 'police:client:deleteObject',
                },
            },
        },
    },

    ambulance = {
        {
            id    = 'revive',
            icon  = 'user-doctor',
            label = 'Reanimar',
            event = 'hospital:client:RevivePlayer',
        },
        {
            id    = 'treatWounds',
            icon  = 'bandage',
            label = 'Tratar ferimentos',
            event = 'hospital:client:TreatWounds',
        },
        {
            id          = 'emergencyButton',
            icon        = 'bell',
            label       = 'Emergência',
            serverEvent = 'hospital:server:emergencyAlert',
        },
    },

    mechanic = {
        {
            id    = 'towVehicle',
            icon  = 'truck-pickup',
            label = 'Rebocar veículo',
            event = 'qb-tow:client:TowVehicle',
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Itens por gang — exibidos quando o jogador pertence ao gang
-- Chave = nome exato do gang
-- ─────────────────────────────────────────────────────────────────────────────
Radial.gangItems = {
    -- Exemplo:
    -- ballas = {
    --     { id = 'gang_action', icon = 'skull', label = 'Ação do gang',
    --       event = 'meu_resource:gangAction' },
    -- },
}
