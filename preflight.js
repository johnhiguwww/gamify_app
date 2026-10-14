#!/usr/bin/env node
// ## Gamify preflight — confere ambiente, .env, Supabase, login Google, API Java, banco e o app Node.
// Só faz LEITURAS. Não cria, altera nem apaga nada no Supabase, na API ou no banco.
//
// Conta de teste (automática, nesta ordem):
//   1. TEST_TOKEN                     → token de acesso já emitido
//   2. TEST_EMAIL + TEST_PASSWORD     → login por e-mail/senha
//   3. SUPABASE_SERVICE_ROLE_KEY      → lê a lista de usuários cadastrados (GET) e usa o mais recente que tenha perfil
//
// A chave de serviço é SECRETA. Guarde-a num arquivo separado, `.env.preflight`, só nesta máquina
// (não no .env do app, não no git). O script lê os dois arquivos.
//
// Uso:  node preflight.js
// Opcionais: PUBLIC_URL (URL pública, ex.: https://maquina.tailXXXX.ts.net), DATABASE_URL, APP_URL

const fs = require('fs');
const net = require('net');
const path = require('path');

// ---------- util ----------
function loadEnv(file) {
  if (!fs.existsSync(file)) return false;
  for (const line of fs.readFileSync(file, 'utf8').split(/\r?\n/)) {
    const m = line.match(/^\s*([\w.]+)\s*=\s*(.*)\s*$/);
    if (!m || line.trim().startsWith('#')) continue;
    let v = m[2];
    if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) v = v.slice(1, -1);
    if (process.env[m[1]] === undefined) process.env[m[1]] = v;
  }
  return true;
}
const hasEnvFile = loadEnv(path.join(process.cwd(), '.env'));
loadEnv(path.join(process.cwd(), '.env.preflight'));
const env = (...names) => names.map((n) => process.env[n]).find((v) => v && v.trim());
const mask = (s) => (s ? s.slice(0, 6) + '…' + s.slice(-4) : '');
const norm = (u) => (u || '').replace(/\/+$/, '');

const C = { ok: '\x1b[32m✔\x1b[0m', bad: '\x1b[31m✘\x1b[0m', warn: '\x1b[33m!\x1b[0m', skip: '\x1b[90m-\x1b[0m' };
const tally = { ok: 0, bad: 0, warn: 0, skip: 0 };
class Warn extends Error {}
class Skip extends Error {}
const warn = (m) => new Warn(m);
const skip = (m) => new Skip(m);

async function check(name, fn) {
  const t0 = Date.now();
  const ms = () => `\x1b[90m(${Date.now() - t0}ms)\x1b[0m`;
  try {
    const r = await fn();
    tally.ok++;
    console.log(`${C.ok} ${name}${r ? ' — ' + r : ''} ${ms()}`);
    return true;
  } catch (e) {
    const kind = e instanceof Warn ? 'warn' : e instanceof Skip ? 'skip' : 'bad';
    tally[kind]++;
    console.log(`${C[kind]} ${name} — ${e.message} ${ms()}`);
    return false;
  }
}
const section = (t) => console.log(`\n\x1b[1m${t}\x1b[0m`);

function netError(e, timeout) {
  if (e.name === 'AbortError') return new Error(`sem resposta em ${timeout / 1000}s (timeout)`);
  return new Error(e.cause?.code ? `${e.cause.code} (${e.cause.message || 'falha de rede'})` : e.message);
}
async function http(url, opts = {}, timeout = 8000) {
  const ctl = new AbortController();
  const h = setTimeout(() => ctl.abort(), timeout);
  try {
    const r = await fetch(url, { ...opts, signal: ctl.signal });
    const text = await r.text();
    let json = null;
    try { json = text ? JSON.parse(text) : null; } catch { /* não é JSON */ }
    return { status: r.status, ok: r.ok, text, json };
  } catch (e) {
    throw netError(e, timeout);
  } finally {
    clearTimeout(h);
  }
}
// #f GET que NÃO segue redirecionamento: devolve status e Location para inspecionarmos o OAuth
async function probe(url, headers = {}, timeout = 8000) {
  const ctl = new AbortController();
  const h = setTimeout(() => ctl.abort(), timeout);
  try {
    const r = await fetch(url, { redirect: 'manual', headers, signal: ctl.signal });
    const text = await r.text().catch(() => '');
    return { status: r.status, location: r.headers.get('location'), text };
  } catch (e) {
    throw netError(e, timeout);
  } finally {
    clearTimeout(h);
  }
}
function tcp(host, port, timeout = 5000) {
  return new Promise((resolve, reject) => {
    const s = net.connect({ host, port });
    s.setTimeout(timeout);
    s.on('connect', () => { s.destroy(); resolve(); });
    s.on('timeout', () => { s.destroy(); reject(new Error(`timeout ao conectar em ${host}:${port}`)); });
    s.on('error', (e) => reject(new Error(`${e.code || e.message} em ${host}:${port}`)));
  });
}
function jwtPayload(token) {
  try { return JSON.parse(Buffer.from(token.split('.')[1], 'base64url').toString('utf8')); } catch { return null; }
}
// #f o Supabase embute a URL de retorno efetiva no parâmetro `state` (um JWT) do redirecionamento ao Google
function referrerOf(location) {
  try {
    const st = new URL(location).searchParams.get('state');
    return st ? jwtPayload(st)?.referrer : undefined;
  } catch { return undefined; }
}
const isRedirect = (s) => s >= 300 && s < 400;

(async () => {
  const ctx = { candidates: [] };
  console.log('\x1b[1mGamify • preflight\x1b[0m  (somente leitura)');

  // ---------- 1. ambiente ----------
  section('1. Ambiente');
  await check('Node 18 ou maior', () => {
    const major = +process.versions.node.split('.')[0];
    if (major < 18) throw new Error(`versão ${process.versions.node} é antiga, instale o Node 18+`);
    return process.versions.node;
  });
  await check('package.json e dependências instaladas', () => {
    const pj = path.join(process.cwd(), 'package.json');
    if (!fs.existsSync(pj)) throw new Error('package.json não encontrado — rode o script dentro da pasta gamify-web');
    const deps = Object.keys(JSON.parse(fs.readFileSync(pj, 'utf8')).dependencies || {});
    const missing = deps.filter((d) => !fs.existsSync(path.join(process.cwd(), 'node_modules', d)));
    if (missing.length) throw new Error(`faltam pacotes (${missing.join(', ')}) — rode npm install`);
    return deps.length ? deps.join(', ') : 'sem dependências';
  });
  await check('arquivo .env', () => {
    if (!hasEnvFile) throw new Error('.env não encontrado — copie o .env.example para .env');
    return 'encontrado';
  });
  await check('pasta public/ com index.html, app.js e styles.css', () => {
    const miss = ['index.html', 'app.js', 'styles.css'].filter((f) => !fs.existsSync(path.join(process.cwd(), 'public', f)));
    if (miss.length) throw new Error('faltando: ' + miss.join(', '));
  });

  // ---------- 2. variáveis ----------
  section('2. Variáveis do .env');
  ctx.api = norm(env('API_BASE_URL', 'API_URL'));
  ctx.sbUrl = norm(env('SUPABASE_URL'));
  ctx.sbKey = env('SUPABASE_KEY', 'SUPABASE_PUBLISHABLE_KEY', 'SUPABASE_ANON_KEY');
  ctx.port = env('PORT') || '3000';
  ctx.pub = norm(env('PUBLIC_URL'));
  await check('API_BASE_URL (ou API_URL)', () => {
    if (!ctx.api) throw new Error('não definida — use API_BASE_URL=http://localhost:8080');
    if (!/^https?:\/\//.test(ctx.api)) throw new Error('precisa começar com http:// ou https://');
    return ctx.api;
  });
  await check('SUPABASE_URL', () => {
    if (!ctx.sbUrl) throw new Error('não definida');
    if (!/^https?:\/\//.test(ctx.sbUrl)) throw new Error('precisa começar com https://');
    if (!/^https:\/\/.+\.supabase\.co$/.test(ctx.sbUrl)) throw warn('domínio diferente de xxxx.supabase.co (ok só se for domínio personalizado): ' + ctx.sbUrl);
    return ctx.sbUrl;
  });
  await check('chave pública do Supabase', () => {
    if (!ctx.sbKey) throw new Error('não definida (SUPABASE_KEY ou SUPABASE_PUBLISHABLE_KEY)');
    if (/sb_secret_/.test(ctx.sbKey) || jwtPayload(ctx.sbKey)?.role === 'service_role')
      throw new Error('essa é a chave SECRETA. Use só a chave pública/anon, pois ela vai para o navegador');
    return mask(ctx.sbKey);
  });
  await check('PUBLIC_URL (URL pública do app)', () => {
    if (!ctx.pub) throw skip('não definida — defina PUBLIC_URL=https://… no .env para testar a URL pública também');
    if (!/^https?:\/\//.test(ctx.pub)) throw new Error('precisa começar com https://');
    if (!ctx.pub.startsWith('https://')) throw warn('use https:// (Tailscale Funnel e ngrok já entregam): ' + ctx.pub);
    return ctx.pub;
  });

  // ---------- 3. API Java ----------
  section('3. API Java');
  if (ctx.api) {
    const u = new URL(ctx.api);
    const port = +u.port || (u.protocol === 'https:' ? 443 : 80);
    const apiUp = await check(`porta TCP ${u.hostname}:${port}`, () => tcp(u.hostname, port));
    await check('API responde HTTP', async () => {
      if (!apiUp) throw skip('porta fechada, pulando');
      const r = await http(ctx.api + '/');
      return `HTTP ${r.status} (qualquer código significa que está de pé)`;
    });
  } else {
    await check('API Java', () => { throw skip('API_BASE_URL ausente'); });
  }

  // ---------- 4. Supabase ----------
  section('4. Supabase (Auth)');
  const sbHeaders = { apikey: ctx.sbKey || '', Authorization: `Bearer ${ctx.sbKey || ''}` };
  const sbReady = ctx.sbUrl && ctx.sbKey;
  await check('Supabase acessível e chave aceita', async () => {
    if (!sbReady) throw skip('URL ou chave ausente');
    const r = await http(ctx.sbUrl + '/auth/v1/settings', { headers: sbHeaders });
    if (r.status === 401 || r.status === 403) throw new Error('chave recusada (HTTP ' + r.status + ') — confira se é a chave do projeto certo');
    if (!r.ok) throw new Error('HTTP ' + r.status);
    ctx.settings = r.json;
    return 'ok';
  });
  await check('provedor Google habilitado no projeto', () => {
    if (!ctx.settings) throw skip('settings indisponíveis');
    if (!ctx.settings.external?.google) throw new Error('provedor Google desligado — ative em Auth → Providers → Google');
  });

  // ---------- 5. login com Google (sem entrar de verdade) ----------
  section('5. Login com Google e URLs de retorno');
  const authorizeUrl = (target) => `${ctx.sbUrl}/auth/v1/authorize?provider=google&redirect_to=${encodeURIComponent(target)}`;
  const localTarget = `http://localhost:${ctx.port}`;
  const startOk = await check('Supabase inicia o login e redireciona para o Google', async () => {
    if (!sbReady) throw skip('Supabase não configurado');
    const r = await probe(authorizeUrl(ctx.pub || localTarget), { apikey: ctx.sbKey });
    if (!isRedirect(r.status) || !r.location) {
      let msg = ''; try { const j = JSON.parse(r.text); msg = j.msg || j.error_description || j.message || ''; } catch { /* sem json */ }
      throw new Error(`HTTP ${r.status}${msg ? ' — ' + msg : ''} (Auth → Providers → Google: confira Client ID e Secret)`);
    }
    const loc = new URL(r.location);
    if (!loc.searchParams.get('client_id')) throw new Error('redirecionou sem client_id — o Client ID do Google não está configurado no Supabase');
    ctx.googleLoc = r.location;
    return `${loc.hostname} • client_id ${mask(loc.searchParams.get('client_id'))}`;
  });
  await check('Google aceita o client_id e a URI de callback', async () => {
    if (!startOk) throw skip('login não iniciou');
    const loc = new URL(ctx.googleLoc);
    const g = await probe(ctx.googleLoc, { 'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) Gecko/20100101 Firefox/120.0' });
    if (g.status === 400 || g.status === 401) {
      throw new Error(`o Google recusou (HTTP ${g.status}). Em Google Cloud → Credenciais, autorize a URI ${loc.searchParams.get('redirect_uri') || ctx.sbUrl + '/auth/v1/callback'} e confira o Client ID`);
    }
    if (g.status === 200 || isRedirect(g.status)) return 'a tela de login do Google abriria';
    throw warn(`resposta inesperada do Google (HTTP ${g.status}), confira à mão`);
  });
  const redirectAllowed = (target) => async () => {
    if (!sbReady) throw skip('Supabase não configurado');
    const r = await probe(authorizeUrl(target), { apikey: ctx.sbKey });
    if (!isRedirect(r.status) || !r.location) throw skip('login não iniciou');
    const ref = referrerOf(r.location);
    if (ref === undefined) throw warn('o Supabase respondeu, mas não deu para ler a URL de retorno; confira à mão em Auth → URL Configuration');
    if (norm(ref) !== norm(target)) throw new Error(`NÃO permitida: o Supabase ignoraria e voltaria para ${ref}. Adicione ${target} em Auth → URL Configuration → Redirect URLs`);
    return 'permitida em Redirect URLs';
  };
  await check(`Redirect URL ${localTarget}`, redirectAllowed(localTarget));
  if (ctx.pub) await check(`Redirect URL ${ctx.pub}`, redirectAllowed(ctx.pub));
  else await check('Redirect URL da URL pública', () => { throw skip('PUBLIC_URL não definida'); });

  // ---------- 6. conta de teste ----------
  section('6. Conta de teste (automática)');
  const email = env('TEST_EMAIL'), pass = env('TEST_PASSWORD'), tok = env('TEST_TOKEN');
  const svcKey = env('SUPABASE_SERVICE_ROLE_KEY', 'SUPABASE_SECRET_KEY');
  if (tok) {
    await check('token informado (TEST_TOKEN) é válido', async () => {
      const r = await http(ctx.sbUrl + '/auth/v1/user', { headers: { apikey: ctx.sbKey, Authorization: 'Bearer ' + tok } });
      if (!r.ok) throw new Error('token recusado (HTTP ' + r.status + '), pode ter expirado');
      ctx.candidates.push(r.json);
      return `${r.json.email} • ${r.json.id}`;
    });
  } else if (email && pass) {
    await check('login com e-mail e senha', async () => {
      if (!sbReady) throw skip('Supabase não configurado');
      const r = await http(ctx.sbUrl + '/auth/v1/token?grant_type=password', {
        method: 'POST', headers: { ...sbHeaders, 'Content-Type': 'application/json' }, body: JSON.stringify({ email, password: pass }),
      });
      if (!r.ok) throw new Error(r.json?.error_description || r.json?.msg || 'HTTP ' + r.status);
      ctx.candidates.push(r.json.user);
      return `${r.json.user.email} • ${r.json.user.id}`;
    });
  } else if (svcKey) {
    await check('usuários cadastrados no Supabase (leitura com a chave de serviço)', async () => {
      if (!ctx.sbUrl) throw skip('SUPABASE_URL ausente');
      if (/sb_publishable_/.test(svcKey) || (svcKey.startsWith('eyJ') && jwtPayload(svcKey)?.role !== 'service_role'))
        throw new Error('essa não é a chave de serviço (é a pública). Pegue a "secret"/"service_role" em Project Settings → API Keys');
      const h = { apikey: svcKey };
      if (svcKey.startsWith('eyJ')) h.Authorization = 'Bearer ' + svcKey;
      const r = await http(`${ctx.sbUrl}/auth/v1/admin/users?page=1&per_page=50`, { headers: h });
      if (!r.ok) throw new Error(`HTTP ${r.status}${r.json?.msg ? ' — ' + r.json.msg : ''} (chave de serviço errada ou de outro projeto?)`);
      let users = (r.json?.users || []).filter((u) => u.email);
      if (email) users = users.filter((u) => u.email.toLowerCase() === email.toLowerCase());
      if (!users.length) throw new Error('nenhum usuário com e-mail cadastrado no projeto. Entre uma vez pelo app com o Google e rode de novo');
      users.sort((a, b) => String(b.last_sign_in_at || '').localeCompare(String(a.last_sign_in_at || '')));
      ctx.candidates = users.slice(0, 5);
      return `${users.length} usuário(s); testando do mais recente para o mais antigo`;
    });
  } else {
    await check('conta de teste', () => {
      throw skip('crie o arquivo .env.preflight com SUPABASE_SERVICE_ROLE_KEY=… (Supabase → Project Settings → API Keys → secret). Ou use TEST_TOKEN, ou TEST_EMAIL e TEST_PASSWORD');
    });
  }

  // ---------- 7. API com a conta ----------
  section('7. API Java com a conta de teste');
  const need = () => { if (!ctx.candidates.length) throw skip('sem conta de teste'); if (!ctx.api) throw skip('sem API_BASE_URL'); };
  const getApi = async (base, p) => {
    const r = await http(base + p);
    if (!r.ok) throw new Error(`HTTP ${r.status}${r.json?.message ? ' — ' + r.json.message : ''}`);
    return r.json;
  };
  await check('perfil por UUID (GET /profiles/by-user-uuid)', async () => {
    need();
    let last;
    for (const u of ctx.candidates) {
      try {
        ctx.profile = await getApi(ctx.api, `/profiles/by-user-uuid/${u.id}`);
        ctx.user = u;
        return `${u.email} → ${ctx.profile.name} • nível ${ctx.profile.level} • userId ${ctx.profile.userId}`;
      } catch (e) { last = e; }
    }
    throw new Error(`nenhum dos ${ctx.candidates.length} usuário(s) tem perfil na API (último erro: ${last.message}). Entre uma vez pelo app para o perfil ser criado`);
  });
  await check('perfil por e-mail (fallback do login)', async () => {
    need();
    if (!ctx.user) throw skip('perfil não carregou');
    const p = await getApi(ctx.api, `/profiles/by-user-email/${encodeURIComponent(ctx.user.email)}`);
    if (!p?.userId) throw new Error('resposta sem userId');
    if (ctx.profile && p.userId !== ctx.profile.userId) throw warn('o e-mail e o UUID apontam para perfis diferentes');
    return 'ok';
  });
  const afterProfile = async (label, p) => {
    need();
    if (!ctx.profile) throw skip('perfil não carregou');
    const d = await getApi(ctx.api, `/profiles/${ctx.profile.userId}${p}`);
    return label(d);
  };
  await check('tarefas (GET /my_tasks)', () => afterProfile((d) => `${(d || []).length} tarefa(s)`, '/my_tasks'));
  await check('missões (GET /my_missions)', () => afterProfile((d) => `${(d || []).length} missão(ões)`, '/my_missions'));
  await check('loja (GET /mystore)', () => afterProfile((d) => `${(d?.items || []).length} item(ns)`, '/mystore'));

  // ---------- 8. banco ----------
  section('8. Banco de dados');
  const dbUrl = env('DATABASE_URL');
  if (dbUrl) {
    let u;
    try { u = new URL(dbUrl); } catch { /* tratado abaixo */ }
    const dbPort = u ? +u.port || 5432 : 0;
    const tcpOk = await check('porta TCP do banco', async () => {
      if (!u) throw new Error('DATABASE_URL inválida');
      await tcp(u.hostname, dbPort, 8000);
      return `${u.hostname}:${dbPort}`;
    });
    await check('consulta SELECT 1', async () => {
      if (!tcpOk) throw skip('porta inacessível');
      let pg;
      try { pg = require('pg'); } catch { throw warn('pacote "pg" não instalado (npm i --no-save pg); só a porta foi testada'); }
      const client = new pg.Client({ connectionString: dbUrl, ssl: { rejectUnauthorized: false }, connectionTimeoutMillis: 8000 });
      await client.connect();
      try { await client.query('select 1'); } finally { await client.end(); }
    });
  } else {
    await check('conexão direta com o banco', () => {
      if (ctx.profile) return 'sem DATABASE_URL, mas a API leu perfil, tarefas, missões e loja do banco (seção 7)';
      throw warn('DATABASE_URL não definida e a seção 7 não rodou, então o banco não foi exercitado');
    });
  }

  // ---------- 9. app Node ----------
  section('9. App web (Node/Express)');
  const app = norm(env('APP_URL') || `http://localhost:${ctx.port}`);
  const appUp = await check(`app responde em ${app}`, async () => {
    const r = await http(app + '/');
    if (!r.ok) throw new Error('HTTP ' + r.status);
    if (!/Gamify/i.test(r.text)) throw warn('respondeu, mas não parece ser o Gamify');
    return 'HTML ok';
  });
  const configOk = async (base) => {
    const r = await http(base + '/config.js');
    if (!r.ok) throw new Error('HTTP ' + r.status);
    if (!/supabaseUrl/.test(r.text) || !/supabaseKey/.test(r.text)) throw new Error('config.js sem supabaseUrl/supabaseKey');
    if (/undefined|""/.test(r.text.replace(/\s/g, '').split('supabaseUrl')[1]?.slice(0, 20) || '')) throw new Error('supabaseUrl vazio no config.js');
    return 'ok';
  };
  const proxyOk = async (base) => {
    if (!ctx.user) throw skip('sem conta de teste');
    const p = await getApi(base + '/api', `/profiles/by-user-uuid/${ctx.user.id}`);
    if (ctx.profile && p.userId !== ctx.profile.userId) throw new Error('o proxy devolveu um perfil diferente do da API direta');
    return `perfil "${p.name}" veio pelo proxy`;
  };
  await check('/config.js entrega as chaves do Supabase', async () => {
    if (!appUp) throw skip('app fora do ar — rode npm start em outro terminal');
    return configOk(app);
  });
  await check('proxy /api repassa para a API Java', async () => {
    if (!appUp) throw skip('app fora do ar');
    return proxyOk(app);
  });
  if (ctx.pub) {
    const pubUp = await check(`URL pública responde (${ctx.pub})`, async () => {
      const r = await http(ctx.pub + '/', {}, 12000);
      if (!r.ok) throw new Error('HTTP ' + r.status + ' — o túnel (Tailscale Funnel/ngrok) está ligado?');
      if (!/Gamify/i.test(r.text)) throw warn('respondeu, mas não parece ser o Gamify (túnel apontando para a porta errada?)');
      return 'HTML ok';
    });
    await check('URL pública: /config.js', async () => { if (!pubUp) throw skip('URL pública fora do ar'); return configOk(ctx.pub); });
    await check('URL pública: proxy /api', async () => { if (!pubUp) throw skip('URL pública fora do ar'); return proxyOk(ctx.pub); });
  }
  await check('CDN do supabase-js acessível', async () => {
    const r = await http('https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.45.4/dist/umd/supabase.min.js', { method: 'HEAD' });
    if (!r.ok) throw new Error('HTTP ' + r.status);
  });

  // ---------- resumo ----------
  console.log(`\n\x1b[1mResumo:\x1b[0m ${tally.ok} ok • ${tally.warn} aviso(s) • ${tally.skip} pulado(s) • ${tally.bad} falha(s)`);
  console.log('\nO que o script não cobre:');
  console.log(' • entrar de verdade com a sua conta Google (exige a tela do Google, só o navegador faz)');
  console.log(' • ações que gravam (criar/concluir tarefa, comprar item): ele só lê, para não mexer nos seus dados');
  process.exit(tally.bad ? 1 : 0);
})().catch((e) => { console.error('\nErro inesperado no preflight:', e); process.exit(2); });