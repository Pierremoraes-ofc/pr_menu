

````md
# PR Menu  
### EN Integration system with the OX Overextended library  
### BR Sistema de integração com a biblioteca OX Overextended  

---

<p align="center">
  <a href="#english">🇺🇸 English</a> • 
  <a href="#portugues">🇧🇷 Português</a>
</p>

---

<a id="english"></a>
# 🇺🇸 English

## 📌 About
Declarative menu system powered by **ox_target**.  
Everything is defined in config — menus are built automatically.

---

## 🔗 Dependencies

| Name         | Role                     | Status |
|-------------|--------------------------|--------|
| ox_lib      | Utilities                | ✅ Required |
| ox_target   | Target engine            | ✅ Required |
| ox_inventory| Inventory                | ⚠️ Optional |
| qbx_core / ESX | Framework            | ⚠️ Optional |

---

## ⚙️ Menu System

Core field:

```lua
id
````

> **Core rule:**
> Same `id` = grouped automatically.

---

## 🔀 Behaviors

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
-- Config.Targets.Vehicle
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

### Result

```
Player aims →
  1 target appears: "Door / Window"
    → click →
      Open Door
      Roll Window
      Back
```

---

## 📂 Children submenu

```lua
{
  id = 'vehicle_trunk',
  bones = { 'boot' },
  label = 'Trunk',
  icon = 'fas fa-box-open',
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

---

---

<a id="portugues"></a>

# 🇧🇷 Português

## 📌 Sobre

Sistema declarativo de menus usando **ox_target**.
Tudo é definido no config — o sistema monta automaticamente.

---

## 🔗 Dependências

| Nome           | Função              | Status        |
| -------------- | ------------------- | ------------- |
| ox_lib         | Utilidades          | ✅ Obrigatório |
| ox_target      | Engine de interação | ✅ Obrigatório |
| ox_inventory   | Inventário          | ⚠️ Opcional   |
| qbx_core / ESX | Framework           | ⚠️ Opcional   |

---

## ⚙️ Sistema de Menus

Campo principal:

```lua
id
```

> **Regra central:**
> Mesmo `id` = agrupamento automático.

---

## 🔀 Comportamentos

| Situação                       | Resultado          | Tipo       |
| ------------------------------ | ------------------ | ---------- |
| id único sem children          | Ação direta        | DIRETO     |
| id único com children          | Submenu            | NESTED     |
| Mesmo id em múltiplas entradas | Submenu automático | AUTO-MERGE |

---

## 🚀 Auto-Merge

Entradas com mesmo `id` viram **um único target com submenu**.

### Exemplo

```lua
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

---

## 📂 Submenu com children

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

## 🧩 Campos

| Campo      | Tipo     | Descrição            |
| ---------- | -------- | -------------------- |
| id         | string   | Chave de agrupamento |
| groupLabel | string?  | Nome do menu pai     |
| label      | string   | Texto                |
| icon       | string   | Ícone                |
| bones      | table?   | Bones                |
| distance   | number?  | Distância            |
| duty       | string?  | Emprego              |
| lvl        | number?  | Nível                |
| onSelect   | function | Callback             |
| children   | table?   | Submenu              |

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

✔ Validação client + server
✔ Compatível com QBX e ESX

---

## 🔄 Fluxo

```
Config.Targets
   ↓
groupById()
   ↓
direto / submenu / merge
   ↓
ox_target:addGlobal*
```


