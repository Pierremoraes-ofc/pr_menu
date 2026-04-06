-- ─────────────────────────────────────────────────────────────────────────────
-- pr_menu | config/menu.lua
-- Menus ox_lib declarativos: ContextMenu, InputDialog, AlertDialog, TextUI
--
-- ─── Como funciona ───────────────────────────────────────────────────────────
--   Cada entrada em Menu.context / Menu.input / Menu.alert é registrada
--   automaticamente por client/menu.lua ao iniciar.
--   Para abrir um menu de qualquer lugar:
--       exports.pr_menu:OpenContextMenu('meu_menu_id')
--       exports.pr_menu:OpenInput('meu_input_id', cb)
--       exports.pr_menu:OpenAlert('meu_alert_id', cb)
--       exports.pr_menu:ShowTextUI('meu_textui_id')
--       exports.pr_menu:HideTextUI()
--
-- ─── Uso externo ─────────────────────────────────────────────────────────────
--   Outros resources podem abrir qualquer menu registrado aqui via exports:
--       exports.pr_menu:OpenContextMenu('veiculo_opcoes')
-- ─────────────────────────────────────────────────────────────────────────────
Menu = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Context Menus
-- Documentação: https://overextended.dev/ox_lib/Modules/Interface/Client/context
--
-- Campos do menu:
--   id       string   identificador único (usado para abrir via exports)
--   title    string   título do menu
--   options  table    lista de opções
--     { title, description?, icon?, onSelect?, event?, serverEvent?, args?,
--       disabled?, metadata?, menu? (abre sub-menu pelo id) }
-- ─────────────────────────────────────────────────────────────────────────────
Menu.context = {

    -- ── Exemplo 1: Menu de opções do veículo ─────────────────────────────────
    {
        id    = 'veiculo_opcoes',
        title = 'Opções do Veículo',
        options = {
            {
                title       = 'Virar Veículo',
                description = 'Coloca o veículo de volta nas rodas',
                icon        = 'car-burst',
                onSelect    = function()
                    TriggerEvent('pr_menu:trunk:flipVehicle')
                end,
            },
            {
                title       = 'Abrir Porta-mala',
                description = 'Abre ou fecha o porta-mala',
                icon        = 'box-open',
                onSelect    = function()
                    local veh = pr_menu.getClosestVehicle(5.0)
                    if veh then pr_menu.toggleDoor(veh, 5, true) end
                end,
            },
            {
                title       = 'Baú do Veículo',
                description = 'Acessa o inventário do porta-mala',
                icon        = 'lock',
                onSelect    = function()
                    local veh = pr_menu.getClosestVehicle(5.0)
                    if not veh then return end
                    local plate = pr_menu.getVehiclePlate(veh)
                    TriggerServerEvent('pr_menu:openTrunkInventory', plate)
                end,
            },
            {
                title       = 'Entrar no porta-mala',
                description = 'Entra dentro do porta-mala do veículo próximo',
                icon        = 'person-walking-arrow-right',
                onSelect    = function()
                    TriggerEvent('pr_menu:trunk:getIn', nil)
                end,
            },
            {
                title = 'Sub-menu de Portas',
                icon  = 'door-open',
                menu  = 'veiculo_portas',   -- abre outro context menu pelo id
            },
        },
    },

    -- ── Exemplo 2: Sub-menu de portas ────────────────────────────────────────
    {
        id    = 'veiculo_portas',
        title = 'Portas do Veículo',
        menu  = 'veiculo_opcoes',   -- botão "voltar" aponta para este id
        options = {
            {
                title    = 'Porta do Motorista',
                icon     = 'car-side',
                onSelect = function()
                    TriggerEvent('pr_menu:openDoor', 0)
                end,
            },
            {
                title    = 'Porta do Passageiro',
                icon     = 'car-side',
                onSelect = function()
                    TriggerEvent('pr_menu:openDoor', 1)
                end,
            },
            {
                title    = 'Porta Traseira Esq.',
                icon     = 'car-side',
                onSelect = function()
                    TriggerEvent('pr_menu:openDoor', 2)
                end,
            },
            {
                title    = 'Porta Traseira Dir.',
                icon     = 'car-side',
                onSelect = function()
                    TriggerEvent('pr_menu:openDoor', 3)
                end,
            },
            {
                title    = 'Capô',
                icon     = 'car-side',
                onSelect = function()
                    TriggerEvent('pr_menu:openDoor', 4)
                end,
            },
        },
    },

    -- ── Exemplo 3: Menu de interações com jogador (uso policial) ─────────────
    {
        id    = 'player_interacoes',
        title = 'Interações com Jogador',
        options = {
            {
                title       = 'Algemar',
                description = 'Coloca algemas no jogador',
                icon        = 'handcuffs',
                onSelect    = function()
                    -- Exemplo: pega o jogador mais próximo e algema
                    local coords  = GetEntityCoords(cache.ped)
                    local player  = lib.getClosestPlayer(coords, 3.0)
                    if not player then
                        pr_menu.notify({ title = 'Erro', description = 'Nenhum jogador próximo!', type = 'error' })
                        return
                    end
                    local targetId = GetPlayerServerId(player)
                    TriggerServerEvent('pr_menu:cuffPlayer', targetId, true)
                end,
            },
            {
                title       = 'Desalgemar',
                icon        = 'handcuffs',
                onSelect    = function()
                    local coords  = GetEntityCoords(cache.ped)
                    local player  = lib.getClosestPlayer(coords, 3.0)
                    if not player then return end
                    local targetId = GetPlayerServerId(player)
                    TriggerServerEvent('pr_menu:cuffPlayer', targetId, false)
                end,
            },
            {
                title       = 'Colocar no porta-mala',
                icon        = 'car',
                onSelect    = function()
                    -- Adapte para o seu resource de kidnap
                    TriggerEvent('police:client:KidnapPlayer')
                end,
            },
        },
    },

}

-- ─────────────────────────────────────────────────────────────────────────────
-- Input Dialogs
-- Documentação: https://overextended.dev/ox_lib/Modules/Interface/Client/input
--
-- Campos:
--   id      string   identificador único
--   title   string   título do dialog
--   inputs  table    campos do formulário
--     { type='input'|'number'|'checkbox'|'select'|'slider'|'date'|'color',
--       label, placeholder?, default?, required?, min?, max?, options? }
-- O callback recebe a tabela de valores ou nil se cancelado.
-- ─────────────────────────────────────────────────────────────────────────────
Menu.input = {

    -- ── Exemplo 1: Definir tempo de prisão ───────────────────────────────────
    {
        id     = 'input_tempo_prisao',
        title  = 'Tempo de Prisão',
        inputs = {
            {
                type        = 'number',
                label       = 'Minutos',
                placeholder = 'Ex: 15',
                required    = true,
                min         = 1,
                max         = 120,
                default     = 10,
            },
            {
                type        = 'input',
                label       = 'Motivo',
                placeholder = 'Motivo da prisão',
                required    = true,
            },
        },
        -- onConfirm é chamado pelo client/menu.lua após abrir via exports
        -- o valor retornado ao callback de exports.pr_menu:OpenInput(id, cb)
    },

    -- ── Exemplo 2: Configurar placa de veículo ────────────────────────────────
    {
        id     = 'input_placa',
        title  = 'Alterar Placa',
        inputs = {
            {
                type        = 'input',
                label       = 'Nova Placa',
                placeholder = 'Ex: ABC1234',
                required    = true,
                min         = 3,
                max         = 8,
            },
        },
    },

    -- ── Exemplo 3: Transferir dinheiro ───────────────────────────────────────
    {
        id     = 'input_transferencia',
        title  = 'Transferir Dinheiro',
        inputs = {
            {
                type        = 'number',
                label       = 'Valor (R$)',
                placeholder = 'Ex: 500',
                required    = true,
                min         = 1,
            },
            {
                type    = 'select',
                label   = 'Conta',
                options = {
                    { label = 'Dinheiro em Espécie', value = 'cash' },
                    { label = 'Conta Bancária',       value = 'bank' },
                },
            },
        },
    },

}

-- ─────────────────────────────────────────────────────────────────────────────
-- Alert Dialogs
-- Documentação: https://overextended.dev/ox_lib/Modules/Interface/Client/alert
--
-- Campos:
--   id      string   identificador único
--   header  string   título do alerta
--   content string   mensagem
--   centered boolean? centraliza o conteúdo
--   cancel   boolean? exibe botão cancelar
-- O callback recebe 'confirm' | 'cancel'
-- ─────────────────────────────────────────────────────────────────────────────
Menu.alert = {

    -- ── Exemplo 1: Confirmação antes de agir ─────────────────────────────────
    {
        id       = 'alert_confirmar_acao',
        header   = 'Confirmação',
        content  = 'Tem certeza que deseja realizar esta ação?',
        centered = true,
        cancel   = true,
    },

    -- ── Exemplo 2: Alerta de perigo ───────────────────────────────────────────
    {
        id       = 'alert_zona_restrita',
        header   = 'Zona Restrita',
        content  = 'Você está entrando em uma área restrita. Sair imediatamente!',
        centered = true,
        cancel   = false,
    },

}

-- ─────────────────────────────────────────────────────────────────────────────
-- TextUI
-- Documentação: https://overextended.dev/ox_lib/Modules/Interface/Client/textui
--
-- Campos:
--   id       string   identificador único (para mostrar/esconder via exports)
--   text     string   texto exibido
--   position string?  'left-center' | 'right-center' | 'top-center' (default: 'right-center')
--   icon     string?  ícone FontAwesome
--   iconColor string? cor do ícone (hex ou nome CSS)
--   style    table?   estilos CSS adicionais
-- ─────────────────────────────────────────────────────────────────────────────
Menu.textUI = {

    -- ── Exemplo 1: Instrução de interação ────────────────────────────────────
    {
        id       = 'textui_pressione_e',
        text     = '[E] Interagir',
        position = 'right-center',
        icon     = 'hand-pointer',
    },

    -- ── Exemplo 2: Zona de serviço ────────────────────────────────────────────
    {
        id       = 'textui_zona_mecanico',
        text     = '[E] Acessar serviços do mecânico',
        position = 'right-center',
        icon     = 'wrench',
        iconColor = '#f59e0b',
    },

    -- ── Exemplo 3: Aviso de área policial ─────────────────────────────────────
    {
        id        = 'textui_area_policial',
        text      = 'Área Policial — Acesso Restrito',
        position  = 'top-center',
        icon      = 'shield-halved',
        iconColor = '#3b82f6',
    },

}
