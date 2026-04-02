Aqui está seu HTML convertido para um **README.md otimizado para GitHub** (mantendo estrutura, legibilidade e sem depender de CSS):

---

# pr_menu / ox_target integration

🇧🇷 Português | 🇺🇸 English

---

## 🇧🇷 Português

### 📌 Sobre

Sistema declarativo de criação e gerenciamento de menus interativos via **ox_target**.
Defina tudo no config — o sistema monta a estrutura automaticamente.

---

## 🔗 Dependências

| Nome           | Função                    | Status        |
| -------------- | ------------------------- | ------------- |
| ox_lib         | Utilitários, notify, init | ✅ Obrigatório |
| ox_target      | Engine de interação       | ✅ Obrigatório |
| ox_inventory   | Inventário (baú etc.)     | ⚠️ Opcional   |
| qbx_core / ESX | Framework (permissões)    | ⚠️ Opcional   |

---

## ⚙️ Sistema de Menus

O coração do sistema é o campo:

```lua
id
```

> **Regra central:**
> Entradas com o mesmo `id` são agrupadas automaticamente.

---

### 🔀 Comportamentos

| Situação                         | Resultado               | Tipo       |
| -------------------------------- | ----------------------- | ---------- |
| `id` único sem `children`        | Executa direto          | DIRETO     |
| `id` único com `children`        | Abre submenu            | NESTED     |
| Mesmo `id` em múltiplas entradas | Cria submenu automático | AUTO-MERGE |

---

## 🚀 Auto-Merge (principal recurso)

Entradas com mesmo `id` viram **um único target com submenu automático**.

### Exemplo

```lua
-- Config.Targets.Vehicle
{
  id = 'vehicle_door',
  groupLabel = 'Porta / Vidro',
  bones = { 'door_dside_f', 'door_pside_f' },
  label = 'Abrir Porta',
  icon = 'fas fa-door-open',
  onSelect = function(data) end,
},
{
  id = 'vehicle_door',
  bones = { 'door_dside_f', 'door_pside_f' },
  label = 'Abrir Janela',
  icon = 'fas fa-window-maximize',
  onSelect = function(data) end,
}
```

### Resultado

```
Jogador mira →
  1 target aparece: "Porta / Vidro"
    → clique →
      Abrir Porta
      Abrir Janela
      Voltar
```

> `groupLabel` define o nome do menu pai.

---

## 📂 Submenus com `children`

```lua
{
  id = 'vehicle_trunk',
  bones = { 'boot' },
  label = 'Porta-mala',
  icon = 'fas fa-box-open',
  children = {
    { id = 'trunk_door', label = 'Abrir / Fechar', onSelect = function(data) end },
    { id = 'trunk_safe', label = 'Baú do Veículo', onSelect = function(data) end },
  }
}
```

---

## 🧩 Campos do Config

| Campo      | Tipo     | Descrição             |
| ---------- | -------- | --------------------- |
| id         | string   | Chave de agrupamento  |
| groupLabel | string?  | Nome do menu pai      |
| label      | string   | Texto exibido         |
| icon       | string   | Ícone Font Awesome    |
| bones      | table?   | Bones do veículo      |
| distance   | number?  | Distância de ativação |
| duty       | string?  | Job necessário        |
| lvl        | number?  | Nível mínimo          |
| onSelect   | function | Callback              |
| children   | table?   | Submenu               |

---

## 📏 Distâncias

```lua
Config.Distance = {
  default = 2.0,
  vehicle = 2.5,
  player  = 2.0,
}
```

---

## 🔐 Permissões

```lua
{
  id = 'cuff',
  duty = 'police',
  lvl = 1,
  label = 'Algemar',
  icon = 'fas fa-handcuffs',
  onSelect = function(data) end
}
```

✔ Verificado no client e server
✔ Compatível com QBX e ESX

---

## 🔄 Fluxo

```
Config.Targets
   ↓
groupById()
   ↓
1 item → ação direta
1 item + children → submenu
N itens mesmo id → auto-merge
   ↓
ox_target:addGlobal*
```

---

---

## 🇺🇸 English

### 📌 About

Declarative menu system powered by **ox_target**.
Everything is defined in config — menus are built automatically.

---

## 🔗 Dependencies

| Name           | Role          | Status      |
| -------------- | ------------- | ----------- |
| ox_lib         | Utilities     | ✅ Required  |
| ox_target      | Target engine | ✅ Required  |
| ox_inventory   | Inventory     | ⚠️ Optional |
| qbx_core / ESX | Framework     | ⚠️ Optional |

---

## ⚙️ Menu System

Core field:

```lua
id
```

> **Core rule:**
> Same `id` = grouped automatically.

---

### 🔀 Behaviors

| Case                     | Result        | Type       |
| ------------------------ | ------------- | ---------- |
| Unique id, no children   | Direct action | DIRECT     |
| Unique id + children     | Nested menu   | NESTED     |
| Same id multiple entries | Auto submenu  | AUTO-MERGE |

---

## 🚀 Auto-Merge

Multiple entries with same `id` become **one target with submenu**.

### Example

```lua
{
  id = 'vehicle_door',
  groupLabel = 'Door / Window',
  bones = { 'door_dside_f', 'door_pside_f' },
  label = 'Open Door',
  icon = 'fas fa-door-open',
  onSelect = function(data) end,
},
{
  id = 'vehicle_door',
  bones = { 'door_dside_f', 'door_pside_f' },
  label = 'Roll Window',
  icon = 'fas fa-window-maximize',
  onSelect = function(data) end,
}
```

---

## 📂 Children submenu

```lua
{
  id = 'vehicle_trunk',
  children = {
    { id = 'trunk_door', label = 'Open / Close', onSelect = function(data) end },
    { id = 'trunk_safe', label = 'Storage', onSelect = function(data) end },
  }
}
```

---

## 🧩 Config Fields

| Field      | Type     | Description         |
| ---------- | -------- | ------------------- |
| id         | string   | Group key           |
| groupLabel | string?  | Parent label        |
| label      | string   | Display text        |
| icon       | string   | Font Awesome        |
| bones      | table?   | Vehicle bones       |
| distance   | number?  | Activation distance |
| duty       | string?  | Required job        |
| lvl        | number?  | Minimum grade       |
| onSelect   | function | Callback            |
| children   | table?   | Nested menu         |

---

## 📏 Distances

```lua
Config.Distance = {
  default = 2.0,
  vehicle = 2.5,
  player  = 2.0,
}
```

---

## 🔐 Permissions

✔ Client + Server validation
✔ QBX & ESX compatible

---

## 🔄 Flow

```
Config.Targets
   ↓
groupById()
   ↓
direct / nested / merged
   ↓
ox_target:addGlobal*
```

