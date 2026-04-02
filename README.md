# pr_menu — Sistema de Gerenciamento via ox_target

> Sistema de integração e gerenciamento para a biblioteca **OX (Overextended)** no FiveM.  
> Permite registrar targets interativos em veículos e jogadores de forma declarativa, com suporte a submenus automáticos, controle de permissões por emprego e integração com múltiplos frameworks.

---

## Dependências

| Resource        | Obrigatório | Função                                      |
|-----------------|-------------|---------------------------------------------|
| `ox_lib`        | ✅ Sim       | Utilitários (notify, print, init)           |
| `ox_target`     | ✅ Sim       | Sistema de target (interação com entidades) |
| `ox_inventory`  | ⚠️ Opcional  | Abertura do baú do veículo                  |
| `mm_carkeys`    | ⚠️ Opcional  | Verificação de chave do veículo             |
| `qbx_core`      | ⚠️ Um dos dois | Framework principal (QBX)               |
| `es_extended`   | ⚠️ Um dos dois | Framework principal (ESX)               |

---

## Estrutura do Projeto

```
pr_menu/
├── fxmanifest.lua        # Manifesto do resource (metadados e scripts)
├── config/
│   └── config.lua        # Configuração centralizada (targets, permissões, distâncias)
├── client/
│   └── target.lua        # Lógica client-side: helpers, processamento e registro dos targets
└── server/
    └── target.lua        # Lógica server-side: validação, algemas e inventário de porta-mala
```

---

## Como Funciona

### Visão Geral

O sistema funciona de forma **declarativa**: você define tudo em `config/config.lua` dentro da tabela `Config.Targets`, e o client processa automaticamente o agrupamento e registro no `ox_target`. Não é necessário chamar manualmente nenhuma função de registro — basta popular o config.

### Fluxo de Inicialização (Client)

```
CreateThread
  └── Aguarda ox_target estar 'started'
        └── registerTargets()
              ├── processTargetList(Config.Targets.Vehicle)  → exports.ox_target:addGlobalVehicle(...)
              └── processTargetList(Config.Targets.Player)   → exports.ox_target:addGlobalPlayer(...)
```

---

## Configuração (`config/config.lua`)

### `Config.Vehicle_key`
Define o nome do resource responsável pelo sistema de chaves de veículo. Se `nil`, a verificação de chave é desativada e qualquer jogador pode abrir as portas.

```lua
Config.Vehicle_key = 'mm_carkeys'  -- ou nil para desativar
```

### `Config.Admin.Permissions`
Define quais empregos têm permissão para ações com `duty`. O `min_grade` define a grade mínima do emprego necessária (`0` = qualquer grade).

```lua
Config.Admin = {
    Permissions = {
        ['admin']  = { min_grade = 0 },
        ['police'] = { min_grade = 0 },
    }
}
```

> ⚠️ Esta tabela serve como referência documental. A verificação real de permissões usa os campos `duty` e `lvl` diretamente em cada entrada de `Config.Targets`.

### `Config.Distance`
Distâncias padrão de ativação dos targets (em metros). Podem ser sobrescritas individualmente por entrada.

```lua
Config.Distance = {
    default = 2.0,   -- fallback global
    vehicle = 2.5,   -- padrão para targets de veículo
    player  = 2.0,   -- padrão para targets de jogador
}
```

### `Config.Targets`
Tabela principal com dois grupos: `Vehicle` (targets em veículos) e `Player` (targets em jogadores).

#### Campos disponíveis por entrada

| Campo        | Tipo       | Obrigatório | Descrição                                                                 |
|--------------|------------|-------------|---------------------------------------------------------------------------|
| `id`         | `string`   | ✅           | Identificador de agrupamento. Mesmo `id` em múltiplas entradas = submenu automático |
| `groupLabel` | `string`   | ❌           | Label do menu pai ao agrupar (opcional; usa label do 1º item se omitido)  |
| `bones`      | `table`    | ❌           | Bones do veículo onde o target é ativado                                  |
| `distance`   | `number`   | ❌           | Distância de ativação (sobrescreve `Config.Distance`)                     |
| `duty`       | `string`   | ❌           | Emprego necessário para ver a opção (`nil` = qualquer jogador)            |
| `lvl`        | `number`   | ❌           | Grade mínima do emprego (`nil` = qualquer grade)                          |
| `label`      | `string`   | ✅           | Texto exibido na opção do target                                          |
| `icon`       | `string`   | ✅           | Ícone Font Awesome (ex: `'fas fa-door-open'`)                             |
| `onSelect`   | `function` | ✅*          | Callback executado ao selecionar a opção (*não necessário se usar `children`) |
| `children`   | `table`    | ❌           | Sub-opções aninhadas (cria submenu a partir desta entrada)                |

---

## Lógica de Agrupamento

O sistema suporta três comportamentos diferentes, determinados automaticamente pela estrutura do config:

### 1. Ação Direta
`id` único **sem** campo `children` → aparece como opção simples no ox_target.

```lua
{ id = 'vehicle_capo', label = 'Capô', icon = '...', onSelect = function() ... end }
```

### 2. Submenu por `children`
`id` único **com** campo `children` → a entrada pai abre um submenu, e os filhos aparecem dentro dele.

```lua
{
    id       = 'vehicle_trunk',
    label    = 'Porta-mala',
    icon     = '...',
    children = {
        { id = 'door_trunk', label = 'Abrir / Fechar', icon = '...', onSelect = function() ... end },
        { id = 'vehi_safe',  label = 'Baú do porta-mala', icon = '...', onSelect = function() ... end },
    }
}
```

### 3. Submenu Automático por `id` repetido
Múltiplas entradas com o **mesmo `id`** → fundidas automaticamente em um submenu. O `groupLabel` do primeiro item define o label do menu pai.

```lua
{ id = 'vehicle_door', groupLabel = 'Porta / Vidro', label = 'Porta', ... },
{ id = 'vehicle_door',                               label = 'Vidro', ... },
-- resultado: menu pai "Porta / Vidro" → filhos: Porta, Vidro
```

---

## Targets Disponíveis

### Veículos (`Config.Targets.Vehicle`)

| ID               | Tipo            | Bones                                                  | Chave necessária | Descrição                          |
|------------------|-----------------|--------------------------------------------------------|------------------|------------------------------------|
| `vehicle_door`   | Submenu auto    | `door_dside_f`, `door_pside_f`, `door_dside_r`, `door_pside_r` | Sim (abrir) | Porta e Vidro agrupados           |
| `vehicle_capo`   | Ação direta     | `bonnet`, `bonnet_dummy`                               | Não              | Abre/fecha o capô                  |
| `vehicle_trunk`  | Submenu children| `boot`, `door_dside_r2`                                | Sim (abrir porta-mala) | Porta-mala + Baú (ox_inventory) |

#### Detalhes dos targets de veículo

**Porta** (`vehicle_door` → filho 1)
- Detecta a porta mais próxima via `getNearestDoorIndex()`
- Verifica se a porta já está aberta pelo ângulo (`GetVehicleDoorAngleRatio > 0.1`)
- Exige chave (via `hasCarKey`) para abrir; fechar é livre

**Vidro** (`vehicle_door` → filho 2)
- Detecta o vidro mais próximo via `getNearestWindowIndex()`
- Verifica se o vidro está intacto antes de operar
- Estado aberto/fechado é mantido em `LocalState` (não há native para checar)

**Capô** (`vehicle_capo`)
- Usa índice fixo `4` (padrão GTA V para capô)
- Não exige chave

**Porta-mala** (`vehicle_trunk` → submenu)
- Filho 1: abre/fecha a porta traseira (índice `5`), exige chave
- Filho 2: abre o inventário `trunk` pelo `ox_inventory`, identificado pela placa do veículo

---

### Jogadores (`Config.Targets.Player`)

| ID     | Tipo         | Emprego necessário | Descrição                            |
|--------|--------------|--------------------|--------------------------------------|
| `cuff` | Submenu auto | `police` (grade 0+) | Algemar e Desalgemar agrupados       |

**Algemar / Desalgemar** (`cuff`)
- Visível apenas para jogadores com emprego `police`
- Envia `TriggerServerEvent('pr_menu:cuffPlayer', targetServerId, true/false)`
- O servidor valida a permissão novamente antes de executar
- O evento `pr_menu:applyCuff` é disparado no cliente do alvo (adaptar para seu resource de algemas)

---

## Lógica Client (`client/target.lua`)

### Namespace Global `pr_menu`
Exposto globalmente para que os callbacks definidos em `config.lua` possam chamar os helpers:

```lua
pr_menu.getNearestDoorIndex(vehicle, coords)   -- índice da porta mais próxima
pr_menu.getNearestWindowIndex(vehicle, coords) -- índice da janela mais próxima
pr_menu.getVehicleDoorCount(vehicle)           -- quantidade de portas laterais
pr_menu.hasCarKey(vehicle)                     -- verifica chave via export
```

### `hasPermission(duty, lvl)` *(local)*
Verifica permissão do jogador local. Compatível com **QBX Core** e **ESX**:
- Tenta QBX primeiro via `exports.qbx_core.GetPlayerData`
- Cai para ESX via `exports['es_extended'].getSharedObject`
- Se nenhum framework estiver ativo, retorna `false`

### `canInteract` dinâmico
Cada opção registrada no `ox_target` possui um callback `canInteract` que:
1. Verifica se o veículo possui o bone necessário (evita opções em veículos sem aquela parte)
2. Verifica a permissão de emprego do jogador

---

## Lógica Server (`server/target.lua`)

### `serverHasPermission(src, duty, lvl)` *(local)*
Revalida no servidor a permissão do jogador que disparou o evento. Segue a mesma lógica dual (QBX / ESX) do client.

### Eventos Registrados

#### `pr_menu:cuffPlayer` *(client → server)*
```lua
TriggerServerEvent('pr_menu:cuffPlayer', targetServerId, cuffState)
```
- Valida que o `source` possui emprego `police`
- Verifica que o jogador alvo existe
- Dispara `pr_menu:applyCuff` no cliente do alvo

#### `pr_menu:openTrunkInventory` *(client → server)*
```lua
TriggerServerEvent('pr_menu:openTrunkInventory', plate)
```
- Sanitiza e normaliza a placa (uppercase, sem espaços)
- Chama `exports.ox_inventory:openInventory(src, { type = 'trunk', id = plate })`

#### `pr_menu:applyCuff` *(server → client alvo)*
Evento recebido no cliente do jogador que será algemado. Precisa ser integrado com o resource de algemas do servidor (ex: `ps-handcuffs`, `copcuff`).

---

## Adicionando Novos Targets

Basta adicionar entradas em `Config.Targets.Vehicle` ou `Config.Targets.Player` no `config.lua`. Nenhum código adicional é necessário.

**Exemplo — Ligar/Desligar motor (ação direta):**
```lua
{
    id       = 'vehicle_engine',
    bones    = { 'bonnet', 'bonnet_dummy' },
    distance = 3.0,
    label    = 'Motor',
    icon     = 'fas fa-engine',
    onSelect = function(data)
        if not DoesEntityExist(data.entity) then return end
        local isOn = GetIsVehicleEngineRunning(data.entity)
        SetVehicleEngineOn(data.entity, not isOn, false, true)
    end
}
```

**Exemplo — Ação restrita a mecânicos:**
```lua
{
    id    = 'vehicle_repair',
    label = 'Reparar',
    icon  = 'fas fa-wrench',
    duty  = 'mechanic',
    lvl   = 1,
    onSelect = function(data)
        -- só visível para mechanic grade 1+
    end
}
```

---

## Eventos de Referência

| Evento                          | Direção          | Descrição                                     |
|---------------------------------|------------------|-----------------------------------------------|
| `pr_menu:cuffPlayer`            | Client → Server  | Solicita algemar/desalgemar um jogador        |
| `pr_menu:applyCuff`             | Server → Client  | Aplica o estado de algemas no alvo            |
| `pr_menu:openTrunkInventory`    | Client → Server  | Abre o inventário do porta-mala pelo servidor |

---

## Integrações Externas

| Sistema          | Como integrar                                                                 |
|------------------|-------------------------------------------------------------------------------|
| **Chave de carro** | Implemente `exports[Config.Vehicle_key]:hasKey(plate)` no seu resource     |
| **Algemas**      | Substitua o corpo de `pr_menu:applyCuff` pela chamada do seu resource         |
| **Inventário**   | `ox_inventory` já integrado; mude o `type` se usar outro inventário de trunk  |
| **Framework**    | QBX e ESX detectados automaticamente; adicione suporte a outros em `hasPermission` |