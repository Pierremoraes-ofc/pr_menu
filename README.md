<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>pr_menu — README</title>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600;700&family=Syne:wght@400;600;700;800&display=swap" rel="stylesheet"/>
<style>
  :root {
    --bg: #0d0f14;
    --surface: #13161e;
    --border: #1e2330;
    --accent: #6ee7b7;
    --accent2: #38bdf8;
    --muted: #4a5368;
    --text: #c9d1e0;
    --heading: #edf2ff;
    --code-bg: #0a0c11;
    --tag-pt: #6ee7b7;
    --tag-en: #38bdf8;
  }

  * { box-sizing: border-box; margin: 0; padding: 0; }

  html { scroll-behavior: smooth; }

  body {
    background: var(--bg);
    color: var(--text);
    font-family: 'Syne', sans-serif;
    font-size: 15px;
    line-height: 1.7;
  }

  /* ── STICKY HEADER ── */
  header {
    position: sticky;
    top: 0;
    z-index: 100;
    background: rgba(13,15,20,0.92);
    backdrop-filter: blur(12px);
    border-bottom: 1px solid var(--border);
    padding: 14px 32px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
    flex-wrap: wrap;
  }

  .logo {
    font-size: 17px;
    font-weight: 800;
    color: var(--heading);
    letter-spacing: -0.5px;
  }
  .logo span { color: var(--accent); }

  .lang-nav {
    display: flex;
    gap: 10px;
  }

  .lang-btn {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    padding: 7px 18px;
    border-radius: 6px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 0.5px;
    text-decoration: none;
    border: 1.5px solid transparent;
    transition: all 0.18s ease;
    cursor: pointer;
  }
  .lang-btn.pt {
    color: var(--tag-pt);
    border-color: var(--tag-pt);
    background: rgba(110,231,183,0.06);
  }
  .lang-btn.pt:hover { background: rgba(110,231,183,0.14); }
  .lang-btn.en {
    color: var(--tag-en);
    border-color: var(--tag-en);
    background: rgba(56,189,248,0.06);
  }
  .lang-btn.en:hover { background: rgba(56,189,248,0.14); }

  /* ── LAYOUT ── */
  main {
    max-width: 900px;
    margin: 0 auto;
    padding: 0 24px 80px;
  }

  /* ── SECTION DIVIDER ── */
  .lang-section {
    margin-top: 64px;
  }

  .lang-tag {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 5px 14px;
    border-radius: 4px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 1px;
    text-transform: uppercase;
    margin-bottom: 28px;
  }
  .lang-tag.pt { background: rgba(110,231,183,0.1); color: var(--tag-pt); border: 1px solid rgba(110,231,183,0.25); }
  .lang-tag.en { background: rgba(56,189,248,0.1);  color: var(--tag-en); border: 1px solid rgba(56,189,248,0.25); }

  .divider {
    height: 1px;
    background: linear-gradient(90deg, var(--border) 0%, transparent 100%);
    margin: 60px 0;
  }

  /* ── TYPOGRAPHY ── */
  h1 {
    font-size: 36px;
    font-weight: 800;
    color: var(--heading);
    line-height: 1.2;
    letter-spacing: -1px;
    margin-bottom: 10px;
  }
  h1 .dim { color: var(--muted); font-weight: 400; }

  .subtitle {
    font-size: 15px;
    color: var(--muted);
    margin-bottom: 36px;
    max-width: 600px;
    line-height: 1.6;
  }

  h2 {
    font-size: 20px;
    font-weight: 700;
    color: var(--heading);
    margin: 44px 0 14px;
    letter-spacing: -0.3px;
  }
  h2::before {
    content: '// ';
    color: var(--accent);
    font-family: 'JetBrains Mono', monospace;
    font-size: 14px;
  }

  h3 {
    font-size: 15px;
    font-weight: 700;
    color: var(--accent);
    margin: 28px 0 10px;
    font-family: 'JetBrains Mono', monospace;
    letter-spacing: 0.2px;
  }

  p { margin-bottom: 12px; color: var(--text); }

  strong { color: var(--heading); font-weight: 700; }

  /* ── CALLOUT ── */
  .callout {
    border-left: 3px solid var(--accent);
    background: rgba(110,231,183,0.05);
    padding: 14px 18px;
    border-radius: 0 6px 6px 0;
    margin: 20px 0;
    font-size: 14px;
  }
  .callout.blue {
    border-color: var(--accent2);
    background: rgba(56,189,248,0.05);
  }

  /* ── CODE ── */
  pre {
    background: var(--code-bg);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 20px 22px;
    overflow-x: auto;
    margin: 16px 0 24px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 13px;
    line-height: 1.65;
  }
  code { font-family: 'JetBrains Mono', monospace; font-size: 13px; }
  p code, li code {
    background: rgba(255,255,255,0.05);
    border: 1px solid var(--border);
    padding: 1px 6px;
    border-radius: 4px;
    color: var(--accent);
    font-size: 12.5px;
  }

  .c-comment { color: #4a5368; }
  .c-key     { color: #6ee7b7; }
  .c-val     { color: #fbbf24; }
  .c-str     { color: #fb923c; }
  .c-fn      { color: #818cf8; }
  .c-kw      { color: #38bdf8; }
  .c-num     { color: #f472b6; }

  /* ── TABLE ── */
  table {
    width: 100%;
    border-collapse: collapse;
    margin: 16px 0 28px;
    font-size: 13.5px;
  }
  th {
    text-align: left;
    padding: 10px 14px;
    background: var(--surface);
    color: var(--heading);
    font-weight: 700;
    border-bottom: 2px solid var(--border);
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }
  td {
    padding: 9px 14px;
    border-bottom: 1px solid var(--border);
    vertical-align: top;
  }
  tr:last-child td { border-bottom: none; }
  td code { font-size: 12px; }
  .badge { display: inline-block; padding: 2px 8px; border-radius: 3px; font-size: 11px; font-weight: 700; font-family: 'JetBrains Mono', monospace; }
  .badge-auto   { background: rgba(110,231,183,0.12); color: var(--accent); }
  .badge-nested { background: rgba(56,189,248,0.12); color: var(--accent2); }
  .badge-direct { background: rgba(251,191,36,0.12); color: #fbbf24; }

  /* ── FLOW DIAGRAM ── */
  .flow {
    background: var(--code-bg);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 22px 24px;
    margin: 16px 0 24px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 12.5px;
    line-height: 2;
    color: var(--text);
  }
  .flow .f-label { color: var(--accent); font-weight: 700; }
  .flow .f-arrow { color: var(--muted); }
  .flow .f-node  { color: var(--heading); }
  .flow .f-cond  { color: #fbbf24; }
  .flow .f-result{ color: var(--accent2); }

  /* ── LIST ── */
  ul, ol {
    margin: 10px 0 18px 22px;
    line-height: 1.8;
  }
  li { margin-bottom: 4px; }

  /* ── DEPS GRID ── */
  .deps {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 10px;
    margin: 16px 0 28px;
  }
  .dep-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 12px 16px;
  }
  .dep-card .dep-name { font-family: 'JetBrains Mono', monospace; font-size: 13px; color: var(--heading); font-weight: 700; }
  .dep-card .dep-role { font-size: 12px; color: var(--muted); margin-top: 3px; }
  .dep-card .dep-req  { font-size: 11px; font-weight: 700; margin-top: 6px; font-family: 'JetBrains Mono', monospace; }
  .dep-card.req  { border-color: rgba(110,231,183,0.3); }
  .dep-card.req .dep-req  { color: var(--accent); }
  .dep-card.opt  { border-color: rgba(251,191,36,0.2); }
  .dep-card.opt .dep-req  { color: #fbbf24; }
</style>
</head>
<body>

<header>
  <div class="logo">pr_<span>menu</span></div>
  <nav class="lang-nav">
    <a class="lang-btn pt" href="#pt">🇧🇷 Português</a>
    <a class="lang-btn en" href="#en">🇺🇸 English</a>
  </nav>
</header>

<main>

<!-- ════════════════════════════════════════════
     PORTUGUÊS
════════════════════════════════════════════ -->
<section class="lang-section" id="pt">
  <div class="lang-tag pt">🇧🇷 Português</div>

  <h1>pr_menu <span class="dim">/ ox_target integration</span></h1>
  <p class="subtitle">Sistema declarativo de criação e gerenciamento de menus interativos via <strong>ox_target</strong>. Defina tudo no config — o sistema monta a estrutura de menus automaticamente.</p>

  <h2>Dependências</h2>
  <div class="deps">
    <div class="dep-card req"><div class="dep-name">ox_lib</div><div class="dep-role">Utilitários, notify, init</div><div class="dep-req">✅ OBRIGATÓRIO</div></div>
    <div class="dep-card req"><div class="dep-name">ox_target</div><div class="dep-role">Engine de targets interativos</div><div class="dep-req">✅ OBRIGATÓRIO</div></div>
    <div class="dep-card opt"><div class="dep-name">ox_inventory</div><div class="dep-role">Inventário (baú, etc.)</div><div class="dep-req">⚠️ OPCIONAL</div></div>
    <div class="dep-card opt"><div class="dep-name">qbx_core / ESX</div><div class="dep-role">Framework (permissões)</div><div class="dep-req">⚠️ OPCIONAL</div></div>
  </div>

  <h2>O Sistema de Menus</h2>
  <p>O coração do <code>pr_menu</code> é o campo <code>id</code>. A partir dele, o sistema decide automaticamente como montar o target — sem que você precise escrever nenhuma lógica de agrupamento.</p>

  <div class="callout">
    <strong>Regra central:</strong> o campo <code>id</code> é o identificador de intenção. Entradas com o mesmo <code>id</code> pertencem ao mesmo contexto e serão unificadas em um único target com submenu automático.
  </div>

  <h3>→ Os 3 comportamentos possíveis</h3>

  <table>
    <thead><tr><th>Situação no Config</th><th>Resultado no Target</th><th>Tipo</th></tr></thead>
    <tbody>
      <tr>
        <td><code>id</code> único, sem <code>children</code></td>
        <td>Ação direta — executa <code>onSelect</code> imediatamente</td>
        <td><span class="badge badge-direct">DIRETO</span></td>
      </tr>
      <tr>
        <td><code>id</code> único, com <code>children</code></td>
        <td>Abre submenu aninhado com as opções filhas</td>
        <td><span class="badge badge-nested">NESTED</span></td>
      </tr>
      <tr>
        <td><strong>Mesmo <code>id</code></strong> em múltiplas entradas</td>
        <td>Funde tudo em 1 target → abre submenu automático</td>
        <td><span class="badge badge-auto">AUTO-MERGE</span></td>
      </tr>
    </tbody>
  </table>

  <h2>Auto-Merge — o recurso principal</h2>
  <p>Quando duas ou mais entradas compartilham o mesmo <code>id</code>, o sistema as funde automaticamente em <strong>um único ponto de interação</strong>. O jogador vê apenas um target; ao clicar, um submenu é gerado com todas as opções do grupo.</p>

  <h3>→ Exemplo prático</h3>
  <p>Sem auto-merge, você precisaria de 2 targets separados na porta. Com auto-merge:</p>

  <pre><span class="c-comment">-- Config.Targets.Vehicle</span>
{
  <span class="c-key">id</span>         = <span class="c-str">'vehicle_door'</span>,
  <span class="c-key">groupLabel</span> = <span class="c-str">'Porta / Vidro'</span>,   <span class="c-comment">-- label do menu pai gerado</span>
  <span class="c-key">bones</span>      = { <span class="c-str">'door_dside_f'</span>, <span class="c-str">'door_pside_f'</span> },
  <span class="c-key">label</span>      = <span class="c-str">'Abrir Porta'</span>,
  <span class="c-key">icon</span>       = <span class="c-str">'fas fa-door-open'</span>,
  <span class="c-key">onSelect</span>   = <span class="c-fn">function</span>(data) <span class="c-comment">-- lógica da porta</span> <span class="c-fn">end</span>,
},
{
  <span class="c-key">id</span>       = <span class="c-str">'vehicle_door'</span>,   <span class="c-comment">-- mesmo id → será fundido</span>
  <span class="c-key">bones</span>    = { <span class="c-str">'door_dside_f'</span>, <span class="c-str">'door_pside_f'</span> },
  <span class="c-key">label</span>    = <span class="c-str">'Abrir Janela'</span>,
  <span class="c-key">icon</span>     = <span class="c-str">'fas fa-window-maximize'</span>,
  <span class="c-key">onSelect</span> = <span class="c-fn">function</span>(data) <span class="c-comment">-- lógica do vidro</span> <span class="c-fn">end</span>,
}</pre>

  <p><strong>Resultado no jogo:</strong></p>
  <div class="flow">
    <span class="f-arrow">[ Jogador mira na porta ]</span><br>
    <span class="f-arrow">  └─ </span><span class="f-node">1 target aparece: "Porta / Vidro"</span><br>
    <span class="f-arrow">       └─ clica ──→ </span><span class="f-cond">submenu abre</span><br>
    <span class="f-arrow">                     ├─ </span><span class="f-result">Abrir Porta</span><br>
    <span class="f-arrow">                     ├─ </span><span class="f-result">Abrir Janela</span><br>
    <span class="f-arrow">                     └─ </span><span class="f-result">← Voltar</span>
  </div>

  <div class="callout">
    O campo <code>groupLabel</code> define o nome do target pai gerado. Se omitido, usa o <code>label</code> da primeira entrada do grupo.
  </div>

  <h2>Submenu com <code>children</code></h2>
  <p>Quando um único target precisa abrir um submenu com opções diferentes, use o campo <code>children</code>:</p>

  <pre>{
  <span class="c-key">id</span>       = <span class="c-str">'vehicle_trunk'</span>,
  <span class="c-key">bones</span>    = { <span class="c-str">'boot'</span> },
  <span class="c-key">label</span>    = <span class="c-str">'Porta-mala'</span>,
  <span class="c-key">icon</span>     = <span class="c-str">'fas fa-box-open'</span>,
  <span class="c-key">children</span> = {
    { <span class="c-key">id</span> = <span class="c-str">'trunk_door'</span>,  <span class="c-key">label</span> = <span class="c-str">'Abrir / Fechar'</span>,  <span class="c-key">onSelect</span> = <span class="c-fn">function</span>(data) <span class="c-comment">...</span> <span class="c-fn">end</span> },
    { <span class="c-key">id</span> = <span class="c-str">'trunk_safe'</span>,  <span class="c-key">label</span> = <span class="c-str">'Baú do Veículo'</span>,  <span class="c-key">onSelect</span> = <span class="c-fn">function</span>(data) <span class="c-comment">...</span> <span class="c-fn">end</span> },
  }
}</pre>

  <h2>Campos do Config</h2>
  <table>
    <thead><tr><th>Campo</th><th>Tipo</th><th>Descrição</th></tr></thead>
    <tbody>
      <tr><td><code>id</code></td><td>string</td><td><strong>Chave de agrupamento.</strong> Mesmo valor em entradas diferentes = auto-merge</td></tr>
      <tr><td><code>groupLabel</code></td><td>string?</td><td>Label do menu pai no auto-merge. Opcional (usa <code>label</code> do 1º item)</td></tr>
      <tr><td><code>label</code></td><td>string</td><td>Texto da opção exibida ao jogador</td></tr>
      <tr><td><code>icon</code></td><td>string</td><td>Ícone Font Awesome (ex: <code>'fas fa-lock'</code>)</td></tr>
      <tr><td><code>bones</code></td><td>table?</td><td>Bones do veículo onde o target é ativo. Omitir = target global</td></tr>
      <tr><td><code>distance</code></td><td>number?</td><td>Distância de ativação em metros. Sobrescreve <code>Config.Distance</code></td></tr>
      <tr><td><code>duty</code></td><td>string?</td><td>Emprego necessário para ver a opção. <code>nil</code> = qualquer jogador</td></tr>
      <tr><td><code>lvl</code></td><td>number?</td><td>Grade mínima do emprego. <code>nil</code> = qualquer grade</td></tr>
      <tr><td><code>onSelect</code></td><td>function</td><td>Callback executado ao selecionar a opção</td></tr>
      <tr><td><code>children</code></td><td>table?</td><td>Sub-opções para criar submenu aninhado manualmente</td></tr>
    </tbody>
  </table>

  <h2>Distâncias Globais</h2>
  <pre><span class="c-key">Config</span>.Distance = {
  <span class="c-key">default</span> = <span class="c-num">2.0</span>,   <span class="c-comment">-- fallback global</span>
  <span class="c-key">vehicle</span> = <span class="c-num">2.5</span>,   <span class="c-comment">-- padrão para targets de veículo</span>
  <span class="c-key">player</span>  = <span class="c-num">2.0</span>,   <span class="c-comment">-- padrão para targets de jogador</span>
}</pre>

  <h2>Permissões por Emprego</h2>
  <p>Qualquer entrada pode ser restrita a um emprego e grade mínima. A verificação acontece <strong>no client e no servidor</strong> para segurança:</p>
  <pre>{
  <span class="c-key">id</span>    = <span class="c-str">'cuff'</span>,
  <span class="c-key">duty</span>  = <span class="c-str">'police'</span>,  <span class="c-comment">-- só policiais veem essa opção</span>
  <span class="c-key">lvl</span>   = <span class="c-num">1</span>,          <span class="c-comment">-- grade mínima 1</span>
  <span class="c-key">label</span> = <span class="c-str">'Algemar'</span>,
  <span class="c-key">icon</span>  = <span class="c-str">'fas fa-handcuffs'</span>,
  <span class="c-key">onSelect</span> = <span class="c-fn">function</span>(data) <span class="c-comment">...</span> <span class="c-fn">end</span>
}</pre>
  <div class="callout">Compatível com <strong>QBX Core</strong> e <strong>ESX</strong> — detectados automaticamente.</div>

  <h2>Fluxo de Processamento</h2>
  <div class="flow">
<span class="f-label">Config.Targets.Vehicle / Player</span>
<span class="f-arrow">  └─ </span><span class="f-node">groupById()</span>  <span class="c-comment">← agrupa entradas pelo campo id</span>
<span class="f-arrow">       └─ para cada grupo:</span>
<span class="f-arrow">            ├─ </span><span class="f-cond">1 entrada, sem children</span>  <span class="f-arrow">──→ </span><span class="f-result">buildOption()   — ação direta</span>
<span class="f-arrow">            ├─ </span><span class="f-cond">1 entrada, com children</span>  <span class="f-arrow">──→ </span><span class="f-result">buildWithChildren() — submenu manual</span>
<span class="f-arrow">            └─ </span><span class="f-cond">N entradas, mesmo id</span>    <span class="f-arrow">──→ </span><span class="f-result">buildMergedGroup()  — auto-merge</span>
<span class="f-arrow">  └─ </span><span class="f-node">ox_target:addGlobalVehicle() / addGlobalPlayer()</span>
  </div>

</section>

<div class="divider"></div>

<!-- ════════════════════════════════════════════
     ENGLISH
════════════════════════════════════════════ -->
<section class="lang-section" id="en">
  <div class="lang-tag en">🇺🇸 English</div>

  <h1>pr_menu <span class="dim">/ ox_target integration</span></h1>
  <p class="subtitle">A declarative menu creation and management system powered by <strong>ox_target</strong>. Define everything in the config — the system builds the menu structure automatically.</p>

  <h2>Dependencies</h2>
  <div class="deps">
    <div class="dep-card req"><div class="dep-name">ox_lib</div><div class="dep-role">Utilities, notify, init</div><div class="dep-req">✅ REQUIRED</div></div>
    <div class="dep-card req"><div class="dep-name">ox_target</div><div class="dep-role">Interactive target engine</div><div class="dep-req">✅ REQUIRED</div></div>
    <div class="dep-card opt"><div class="dep-name">ox_inventory</div><div class="dep-role">Inventory (trunks, etc.)</div><div class="dep-req">⚠️ OPTIONAL</div></div>
    <div class="dep-card opt"><div class="dep-name">qbx_core / ESX</div><div class="dep-role">Framework (permissions)</div><div class="dep-req">⚠️ OPTIONAL</div></div>
  </div>

  <h2>The Menu System</h2>
  <p>The core of <code>pr_menu</code> is the <code>id</code> field. From it, the system automatically decides how to build the target — no grouping logic required on your end.</p>

  <div class="callout blue">
    <strong>Core rule:</strong> the <code>id</code> field is an intent identifier. Entries sharing the same <code>id</code> belong to the same context and will be merged into a single target with an automatic submenu.
  </div>

  <h3>→ The 3 possible behaviors</h3>

  <table>
    <thead><tr><th>Config situation</th><th>Result in target</th><th>Type</th></tr></thead>
    <tbody>
      <tr>
        <td>Unique <code>id</code>, no <code>children</code></td>
        <td>Direct action — fires <code>onSelect</code> immediately</td>
        <td><span class="badge badge-direct">DIRECT</span></td>
      </tr>
      <tr>
        <td>Unique <code>id</code>, with <code>children</code></td>
        <td>Opens a nested submenu with the child options</td>
        <td><span class="badge badge-nested">NESTED</span></td>
      </tr>
      <tr>
        <td><strong>Same <code>id</code></strong> on multiple entries</td>
        <td>Merges all into 1 target → opens automatic submenu</td>
        <td><span class="badge badge-auto">AUTO-MERGE</span></td>
      </tr>
    </tbody>
  </table>

  <h2>Auto-Merge — the core feature</h2>
  <p>When two or more entries share the same <code>id</code>, the system automatically merges them into <strong>a single interaction point</strong>. The player sees only one target; clicking it generates a submenu with all grouped options.</p>

  <h3>→ Practical example</h3>
  <p>Without auto-merge, you'd need 2 separate targets on the door. With auto-merge:</p>

  <pre><span class="c-comment">-- Config.Targets.Vehicle</span>
{
  <span class="c-key">id</span>         = <span class="c-str">'vehicle_door'</span>,
  <span class="c-key">groupLabel</span> = <span class="c-str">'Door / Window'</span>,    <span class="c-comment">-- parent menu label</span>
  <span class="c-key">bones</span>      = { <span class="c-str">'door_dside_f'</span>, <span class="c-str">'door_pside_f'</span> },
  <span class="c-key">label</span>      = <span class="c-str">'Open Door'</span>,
  <span class="c-key">icon</span>       = <span class="c-str">'fas fa-door-open'</span>,
  <span class="c-key">onSelect</span>   = <span class="c-fn">function</span>(data) <span class="c-comment">-- door logic</span> <span class="c-fn">end</span>,
},
{
  <span class="c-key">id</span>       = <span class="c-str">'vehicle_door'</span>,    <span class="c-comment">-- same id → will be merged</span>
  <span class="c-key">bones</span>    = { <span class="c-str">'door_dside_f'</span>, <span class="c-str">'door_pside_f'</span> },
  <span class="c-key">label</span>    = <span class="c-str">'Roll Down Window'</span>,
  <span class="c-key">icon</span>     = <span class="c-str">'fas fa-window-maximize'</span>,
  <span class="c-key">onSelect</span> = <span class="c-fn">function</span>(data) <span class="c-comment">-- window logic</span> <span class="c-fn">end</span>,
}</pre>

  <p><strong>In-game result:</strong></p>
  <div class="flow">
    <span class="f-arrow">[ Player aims at the door ]</span><br>
    <span class="f-arrow">  └─ </span><span class="f-node">1 target appears: "Door / Window"</span><br>
    <span class="f-arrow">       └─ clicks ──→ </span><span class="f-cond">submenu opens</span><br>
    <span class="f-arrow">                     ├─ </span><span class="f-result">Open Door</span><br>
    <span class="f-arrow">                     ├─ </span><span class="f-result">Roll Down Window</span><br>
    <span class="f-arrow">                     └─ </span><span class="f-result">← Back</span>
  </div>

  <div class="callout blue">
    The <code>groupLabel</code> field sets the name of the generated parent target. If omitted, it falls back to the <code>label</code> of the first entry in the group.
  </div>

  <h2>Submenu with <code>children</code></h2>
  <p>When a single target needs to open a submenu with different options, use the <code>children</code> field:</p>

  <pre>{
  <span class="c-key">id</span>       = <span class="c-str">'vehicle_trunk'</span>,
  <span class="c-key">bones</span>    = { <span class="c-str">'boot'</span> },
  <span class="c-key">label</span>    = <span class="c-str">'Trunk'</span>,
  <span class="c-key">icon</span>     = <span class="c-str">'fas fa-box-open'</span>,
  <span class="c-key">children</span> = {
    { <span class="c-key">id</span> = <span class="c-str">'trunk_door'</span>, <span class="c-key">label</span> = <span class="c-str">'Open / Close'</span>,   <span class="c-key">onSelect</span> = <span class="c-fn">function</span>(data) <span class="c-comment">...</span> <span class="c-fn">end</span> },
    { <span class="c-key">id</span> = <span class="c-str">'trunk_safe'</span>, <span class="c-key">label</span> = <span class="c-str">'Vehicle Storage'</span>, <span class="c-key">onSelect</span> = <span class="c-fn">function</span>(data) <span class="c-comment">...</span> <span class="c-fn">end</span> },
  }
}</pre>

  <h2>Config Fields</h2>
  <table>
    <thead><tr><th>Field</th><th>Type</th><th>Description</th></tr></thead>
    <tbody>
      <tr><td><code>id</code></td><td>string</td><td><strong>Grouping key.</strong> Same value across entries = auto-merge</td></tr>
      <tr><td><code>groupLabel</code></td><td>string?</td><td>Parent menu label in auto-merge. Optional (falls back to <code>label</code> of 1st entry)</td></tr>
      <tr><td><code>label</code></td><td>string</td><td>Option text displayed to the player</td></tr>
      <tr><td><code>icon</code></td><td>string</td><td>Font Awesome icon (e.g. <code>'fas fa-lock'</code>)</td></tr>
      <tr><td><code>bones</code></td><td>table?</td><td>Vehicle bones where target is active. Omit = global target</td></tr>
      <tr><td><code>distance</code></td><td>number?</td><td>Activation distance in meters. Overrides <code>Config.Distance</code></td></tr>
      <tr><td><code>duty</code></td><td>string?</td><td>Required job to see this option. <code>nil</code> = any player</td></tr>
      <tr><td><code>lvl</code></td><td>number?</td><td>Minimum job grade. <code>nil</code> = any grade</td></tr>
      <tr><td><code>onSelect</code></td><td>function</td><td>Callback fired when the option is selected</td></tr>
      <tr><td><code>children</code></td><td>table?</td><td>Sub-options to manually create a nested submenu</td></tr>
    </tbody>
  </table>

  <h2>Global Distances</h2>
  <pre><span class="c-key">Config</span>.Distance = {
  <span class="c-key">default</span> = <span class="c-num">2.0</span>,   <span class="c-comment">-- global fallback</span>
  <span class="c-key">vehicle</span> = <span class="c-num">2.5</span>,   <span class="c-comment">-- default for vehicle targets</span>
  <span class="c-key">player</span>  = <span class="c-num">2.0</span>,   <span class="c-comment">-- default for player targets</span>
}</pre>

  <h2>Job Permissions</h2>
  <p>Any entry can be restricted to a job and minimum grade. Validation happens on <strong>both client and server</strong> for security:</p>
  <pre>{
  <span class="c-key">id</span>    = <span class="c-str">'cuff'</span>,
  <span class="c-key">duty</span>  = <span class="c-str">'police'</span>,  <span class="c-comment">-- only police see this option</span>
  <span class="c-key">lvl</span>   = <span class="c-num">1</span>,          <span class="c-comment">-- minimum grade 1</span>
  <span class="c-key">label</span> = <span class="c-str">'Handcuff'</span>,
  <span class="c-key">icon</span>  = <span class="c-str">'fas fa-handcuffs'</span>,
  <span class="c-key">onSelect</span> = <span class="c-fn">function</span>(data) <span class="c-comment">...</span> <span class="c-fn">end</span>
}</pre>
  <div class="callout blue">Compatible with <strong>QBX Core</strong> and <strong>ESX</strong> — auto-detected at runtime.</div>

  <h2>Processing Flow</h2>
  <div class="flow">
<span class="f-label">Config.Targets.Vehicle / Player</span>
<span class="f-arrow">  └─ </span><span class="f-node">groupById()</span>  <span class="c-comment">← groups entries by id field</span>
<span class="f-arrow">       └─ for each group:</span>
<span class="f-arrow">            ├─ </span><span class="f-cond">1 entry, no children</span>   <span class="f-arrow">──→ </span><span class="f-result">buildOption()       — direct action</span>
<span class="f-arrow">            ├─ </span><span class="f-cond">1 entry, with children</span> <span class="f-arrow">──→ </span><span class="f-result">buildWithChildren() — manual submenu</span>
<span class="f-arrow">            └─ </span><span class="f-cond">N entries, same id</span>    <span class="f-arrow">──→ </span><span class="f-result">buildMergedGroup()  — auto-merge</span>
<span class="f-arrow">  └─ </span><span class="f-node">ox_target:addGlobalVehicle() / addGlobalPlayer()</span>
  </div>

</section>

</main>
</body>
</html>