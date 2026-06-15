/* HMG CBT Site Generator — browser-only, no paid AI API, no server upload. */
(function(){
'use strict';

const TEMPLATE_ROOT = 'templates/hmg-cbt-pro-v3.1';
const MANIFEST_URL = 'template-manifest.json';
const VERSION = '1.0.0';

const FEATURE_GROUPS = [
  {id:'core', title:'Core portals', items:[
    ['studentPortal','Student exam portal',true],['teacherDashboard','Teacher dashboard',true],['adminPanel','Admin panel',true],['landingPage','Marketing landing page',true]
  ]},
  {id:'exam', title:'Exam creation and delivery', items:[
    ['csvImport','CSV/XLSX/PDF/manual question import',true],['questionBank','Question bank editing',true],['randomisation','Question randomisation',true],['examScheduling','Start/close scheduling',true],['registeredMode','Registered-student mode',true],['negativeMarking','Negative marking',true],['heldResults','Hold/release result mode',true],['examPackages','Exam package export/import',true]
  ]},
  {id:'questions', title:'Question types', items:[
    ['mcq','Multiple choice',true],['mrq','Multiple response',true],['trueFalse','True/False',true],['shortAnswer','Short answer',true],['numeric','Numeric with tolerance',true],['matching','Matching',true],['ordering','Ordering',true],['cloze','Cloze/multi-blank',true],['essay','Keyword essay',true],['categorization','Categorization',true],['multiNumeric','Multi-numeric',true]
  ]},
  {id:'integrity', title:'Integrity and proctoring', items:[
    ['integrityPledge','Integrity pledge',true],['tabSwitchDetection','Tab/app switch detection',true],['fullscreenMonitoring','Fullscreen monitoring',true],['copyPasteBlocking','Copy/paste/right-click blocking',true],['devToolsDetection','DevTools detection',true],['cameraSnapshots','Camera snapshots',true],['audioSpikeDetection','Audio spike detection',true],['watermark','Dynamic watermark',true]
  ]},
  {id:'analytics', title:'Results and analytics', items:[
    ['instantResults','Instant result when released',true],['certificates','Certificate/submission codes',true],['csvExports','CSV exports',true],['itemAnalysis','Item analysis',true],['leaderboard','Leaderboard/percentiles',true],['ruleInsights','Rule-based insights, no AI API',true],['emergencyBackup','Student emergency backup JSON',true]
  ]},
  {id:'deployment', title:'Deployment and operations', items:[
    ['pwa','PWA/offline shell',true],['deploymentValidator','Deployment validator',true],['linkChecker','Exam link/code checker',true],['securityReports','Security reports/checklists',true],['docs','Client documentation',true],['brandKit','Brand kit JSON',true]
  ]}
];

const TEXT_EXTENSIONS = ['.html','.css','.js','.json','.md','.sql','.svg','.txt','.csv','.webmanifest'];
const TEXT_FILENAMES = ['_headers','.nojekyll','LICENSE'];

let logoFile = null;
let logoPreviewDataUrl = '';
let lastManifest = null;

const $ = sel => document.querySelector(sel);
const $$ = sel => Array.from(document.querySelectorAll(sel));

function init(){
  if('serviceWorker' in navigator){ navigator.serviceWorker.register('sw.js').catch(()=>{}); }
  renderFeatureGroups();
  bindEvents();
  updatePreview();
}

function renderFeatureGroups(){
  const box = $('#feature-groups');
  box.innerHTML = FEATURE_GROUPS.map(group => `
    <div class="feature-group">
      <h4>${escapeHtml(group.title)}</h4>
      <div class="feature-options">
        ${group.items.map(([id,label,checked]) => `
          <label class="check"><input type="checkbox" data-feature="${id}" ${checked?'checked':''}> ${escapeHtml(label)}</label>
        `).join('')}
      </div>
    </div>
  `).join('');
}

function bindEvents(){
  $('#generator-form').addEventListener('input', updatePreview);
  $('#generator-form').addEventListener('change', updatePreview);
  $('#logo-input').addEventListener('change', handleLogoUpload);
  $('#generate-btn').addEventListener('click', generateZip);
  $('#download-config-btn').addEventListener('click', downloadConfig);
  $('#load-demo-btn').addEventListener('click', loadDemo);
  $('#config-file').addEventListener('change', importConfig);
  $('#generator-form').addEventListener('reset', () => setTimeout(updatePreview, 50));
}

function handleLogoUpload(e){
  logoFile = e.target.files && e.target.files[0] ? e.target.files[0] : null;
  logoPreviewDataUrl = '';
  if(!logoFile){ updatePreview(); return; }
  const reader = new FileReader();
  reader.onload = () => { logoPreviewDataUrl = String(reader.result || ''); updatePreview(); };
  reader.readAsDataURL(logoFile);
}

function formValue(name){
  const el = document.forms['generator-form'].elements[name];
  if(!el) return '';
  if(el.type === 'checkbox') return !!el.checked;
  return String(el.value || '').trim();
}

function getConfig(){
  const features = {};
  $$('[data-feature]').forEach(cb => { features[cb.dataset.feature] = cb.checked; });
  const clientName = formValue('clientName') || 'Client Academy';
  const shortName = formValue('shortName') || clientName.split(/\s+/)[0] || 'Client';
  const siteTitle = formValue('siteTitle') || `${shortName} CBT Pro`;
  const whatsapp = formValue('whatsapp');
  return {
    generator:{name:'HMG CBT Site Generator',version:VERSION,generatedAt:new Date().toISOString(),noAiApi:true},
    client:{
      name:clientName, shortName, siteTitle,
      tagline:formValue('tagline') || 'Secure exams, instant results, and analytics.',
      institutionType:formValue('institutionType') || 'School',
      ownerName:formValue('ownerName') || 'Administrator',
      email:formValue('email') || 'info@example.com',
      phone:formValue('phone') || '',
      whatsapp,
      whatsappLink: normaliseWhatsApp(whatsapp),
      website:formValue('website') || '',
      address:formValue('address') || ''
    },
    supabase:{
      url:formValue('supabaseUrl') || 'https://YOUR_PROJECT_ID.supabase.co',
      anonKey:formValue('supabaseKey') || 'YOUR_SUPABASE_ANON_KEY',
      adminEmail:formValue('adminEmail') || 'admin@example.com'
    },
    theme:{
      primary:formValue('primary') || '#10b981',
      accent:formValue('accent') || '#3b82f6',
      secondary:formValue('secondary') || '#8b5cf6',
      background:formValue('background') || '#09090b',
      surface:formValue('surface') || '#18181b',
      text:formValue('text') || '#f8fafc',
      font:formValue('font') || 'Inter, system-ui, sans-serif',
      layout:formValue('layout') || 'enterprise',
      mode:formValue('themeMode') || 'dark',
      radius:formValue('radius') || '18px'
    },
    package:{
      includeDocs:formValue('includeDocs'),
      includeSampleCsv:formValue('includeSampleCsv'),
      includeSql:formValue('includeSql'),
      includeGeneratorCredit:formValue('includeGeneratorCredit'),
      whiteLabel:formValue('whiteLabel'),
      zipName:safeZipName(formValue('zipName') || `${shortName}-cbt-website.zip`)
    },
    features,
    logo:{
      uploaded:!!logoFile,
      fileName:logoFile ? logoFile.name : '',
      path: logoFile ? `assets/client-logo.${logoExtension(logoFile)}` : 'assets/client-logo.svg'
    }
  };
}

function updatePreview(){
  const cfg = getConfig();
  document.documentElement.style.setProperty('--primary', cfg.theme.primary);
  document.documentElement.style.setProperty('--accent', cfg.theme.accent);
  document.documentElement.style.setProperty('--secondary', cfg.theme.secondary);
  document.documentElement.style.setProperty('--bg', cfg.theme.background);
  document.documentElement.style.setProperty('--surface', cfg.theme.surface);
  document.documentElement.style.setProperty('--text', cfg.theme.text);
  document.documentElement.style.setProperty('--radius', cfg.theme.radius);
  document.documentElement.style.setProperty('--font', cfg.theme.font);
  $('#preview-name').textContent = cfg.client.siteTitle;
  $('#preview-tagline').textContent = cfg.client.tagline;
  $('#preview-type').textContent = `${cfg.client.institutionType} CBT Platform`;
  const logo = $('#preview-logo');
  if(logoPreviewDataUrl){ logo.innerHTML = `<img src="${logoPreviewDataUrl}" alt="Client logo preview">`; }
  else { logo.textContent = initials(cfg.client.shortName || cfg.client.name); }
}

function loadDemo(){
  const f = document.forms['generator-form'];
  f.clientName.value = 'HMG Partner Tutorial Centre';
  f.shortName.value = 'HMG Partner';
  f.siteTitle.value = 'HMG Partner CBT Portal';
  f.tagline.value = 'WAEC, NECO, BECE, UTME and school exam practice with instant analytics.';
  f.institutionType.value = 'Tutorial Centre';
  f.ownerName.value = 'Centre Director';
  f.email.value = 'support@partnercentre.example';
  f.phone.value = '+234 810 086 6322';
  f.whatsapp.value = '+234 810 086 6322';
  f.website.value = 'https://example.com';
  f.address.value = 'Lagos / Ogun State, Nigeria';
  f.adminEmail.value = 'admin@partnercentre.example';
  f.primary.value = '#10b981'; f.accent.value = '#f59e0b'; f.secondary.value = '#3b82f6';
  f.layout.value = 'modern';
  f.zipName.value = 'hmg-partner-cbt-website.zip';
  updatePreview();
  setStatus('Demo client loaded. You can now generate or edit the details.', 'ok');
}

async function importConfig(e){
  const file = e.target.files && e.target.files[0];
  if(!file) return;
  try{
    const cfg = JSON.parse(await file.text());
    applyConfigToForm(cfg);
    setStatus('Client config loaded successfully.', 'ok');
  }catch(err){ setStatus('Could not load config JSON: '+err.message, 'err'); }
  e.target.value = '';
}

function applyConfigToForm(cfg){
  const f = document.forms['generator-form'];
  const c = cfg.client || {}, s = cfg.supabase || {}, t = cfg.theme || {}, p = cfg.package || {};
  if(c.name) f.clientName.value = c.name;
  if(c.shortName) f.shortName.value = c.shortName;
  if(c.siteTitle) f.siteTitle.value = c.siteTitle;
  if(c.tagline) f.tagline.value = c.tagline;
  if(c.institutionType) f.institutionType.value = c.institutionType;
  if(c.ownerName) f.ownerName.value = c.ownerName;
  if(c.email) f.email.value = c.email;
  if(c.phone) f.phone.value = c.phone;
  if(c.whatsapp) f.whatsapp.value = c.whatsapp;
  if(c.website) f.website.value = c.website;
  if(c.address) f.address.value = c.address;
  if(s.url) f.supabaseUrl.value = s.url;
  if(s.anonKey) f.supabaseKey.value = s.anonKey;
  if(s.adminEmail) f.adminEmail.value = s.adminEmail;
  ['primary','accent','secondary','background','surface','text'].forEach(k => { if(t[k]) f[k].value = t[k]; });
  if(t.font) f.font.value = t.font;
  if(t.layout) f.layout.value = t.layout;
  if(t.mode) f.themeMode.value = t.mode;
  if(t.radius) f.radius.value = t.radius;
  ['includeDocs','includeSampleCsv','includeSql','includeGeneratorCredit','whiteLabel'].forEach(k => { if(typeof p[k] === 'boolean') f[k].checked = p[k]; });
  if(p.zipName) f.zipName.value = p.zipName;
  if(cfg.features){ $$('[data-feature]').forEach(cb => { if(typeof cfg.features[cb.dataset.feature] === 'boolean') cb.checked = cfg.features[cb.dataset.feature]; }); }
  updatePreview();
}

function downloadConfig(){
  const cfg = getConfig();
  downloadBlob(new Blob([JSON.stringify(cfg,null,2)], {type:'application/json'}), safeFileName(`${cfg.client.shortName}-cbt-generator-config.json`));
}

async function generateZip(){
  const btn = $('#generate-btn');
  const cfg = getConfig();
  if(!cfg.client.name || !cfg.client.shortName){ setStatus('Please enter client name and short name.', 'err'); return; }
  if(cfg.supabase.anonKey.toLowerCase().includes('service_role')){
    setStatus('Security stop: the key appears to be a service_role key. Use the anon public key only.', 'err');
    return;
  }
  btn.disabled = true;
  try{
    setStatus('Loading CBT template manifest…');
    const manifest = await loadTemplateManifest();
    const outputFiles = [];
    const skip = buildSkipSet(cfg);
    let count = 0;
    for(const rel of manifest.files){
      if(skip.has(rel)) continue;
      setStatus(`Reading template file ${++count}/${manifest.files.length}: ${rel}`);
      const bytes = await fetchTemplateBytes(rel);
      const finalPath = rel;
      if(isTextFile(rel)){
        const text = new TextDecoder().decode(bytes);
        outputFiles.push({path:finalPath, data: strToU8(applyTemplateCustomisation(rel, text, cfg))});
      }else{
        outputFiles.push({path:finalPath, data: new Uint8Array(bytes)});
      }
    }

    setStatus('Adding generated brand/config files…');
    await addGeneratedFiles(outputFiles, cfg);

    setStatus('Building ZIP in browser…');
    const zipBlob = createZip(outputFiles);
    downloadBlob(zipBlob, cfg.package.zipName);
    setStatus(`✅ ZIP generated successfully.\nFiles packaged: ${outputFiles.length}\nDownload: ${cfg.package.zipName}\n\nNext: extract the ZIP, run COMPLETE_SQL_SETUP.sql in Supabase, then upload the files to GitHub Pages/Netlify/Vercel/Cloudflare Pages.`, 'ok');
  }catch(err){
    console.error(err);
    setStatus('Generation failed: '+err.message+'\n\nIf you opened this generator directly from your computer, run it through a local/static server so the browser can read template files.', 'err');
  }finally{
    btn.disabled = false;
  }
}

function buildSkipSet(cfg){
  const skip = new Set();
  if(!cfg.package.includeDocs){
    ['README.md','DEPLOYMENT.md','DEPLOYMENT_GUIDE.md','FEATURES.md','FEATURES_GUIDE.md','SECURITY.md','CHANGELOG.md','CONTRIBUTING.md','PROMPT_TEMPLATE.md','DIAGNOSIS_REPORT.md','EXPERT_ENHANCEMENT_REPORT.md','FILE_INVENTORY.md'].forEach(f=>skip.add(f));
  }
  if(!cfg.package.includeSampleCsv) skip.add('further_maths_sample.csv');
  if(!cfg.package.includeSql) skip.add('COMPLETE_SQL_SETUP.sql');
  if(!cfg.features.deploymentValidator) skip.add('deployment_validator.html');
  if(!cfg.features.linkChecker) skip.add('link_checker.html');
  return skip;
}

async function loadTemplateManifest(){
  if(lastManifest) return lastManifest;
  const res = await fetch(MANIFEST_URL, {cache:'no-store'});
  if(!res.ok) throw new Error('Cannot load template-manifest.json');
  lastManifest = await res.json();
  if(!lastManifest.files || !Array.isArray(lastManifest.files)) throw new Error('Invalid template manifest.');
  return lastManifest;
}

async function fetchTemplateBytes(rel){
  const res = await fetch(`${TEMPLATE_ROOT}/${rel}`, {cache:'no-store'});
  if(!res.ok){
    if(rel === '.nojekyll') return new Uint8Array();
    throw new Error(`Cannot read template file: ${rel}`);
  }
  return await res.arrayBuffer();
}

function isTextFile(path){
  const lower = path.toLowerCase();
  if(TEXT_FILENAMES.includes(path)) return true;
  return TEXT_EXTENSIONS.some(ext => lower.endsWith(ext));
}

function applyTemplateCustomisation(path, text, cfg){
  const c = cfg.client, s = cfg.supabase;
  const product = c.siteTitle || `${c.shortName} CBT Pro`;
  const shortProduct = `${c.shortName} CBT`;
  let out = text;

  // Supabase and admin constants.
  out = out.replace(/const\s+SB_URL\s*=\s*['"][^'"]*['"]\s*;/g, `const SB_URL='${escapeJs(s.url)}';`);
  out = out.replace(/const\s+SB_KEY\s*=\s*['"][^'"]*['"]\s*;/g, `const SB_KEY='${escapeJs(s.anonKey)}';`);
  out = out.replace(/const\s+ADMIN_EMAIL\s*=\s*['"][^'"]*['"]\s*;/g, `const ADMIN_EMAIL='${escapeJs(s.adminEmail)}';`);

  // Brand/contact replacements.
  const replacements = [
    [/HMG Academy CBT Pro v3\.1/g, product],
    [/HMG Academy CBT Pro/g, product],
    [/HMG Academy CBT/g, shortProduct],
    [/HMG Academy/g, c.name],
    [/HMG Technologies/g, `${c.shortName} Digital Learning`],
    [/HMG Concepts/g, cfg.package.whiteLabel ? c.name : 'HMG Concepts'],
    [/Adewale Samson Adeagbo/g, c.ownerName || c.name],
    [/hismarvellousgrace@gmail\.com/g, c.email],
    [/buildingmyictcareer@gmail\.com/g, s.adminEmail || c.email],
    [/\+234 810 086 6322/g, c.whatsapp || c.phone],
    [/\+234 907 790 7677/g, c.phone || c.whatsapp],
    [/https:\/\/hmgacademy\.pages\.dev\/?/g, c.website || '#'],
    [/https:\/\/hmgconcepts\.pages\.dev\/?/g, c.website || '#'],
    [/https:\/\/wa\.me\/2348100866322/g, c.whatsappLink || '#']
  ];
  replacements.forEach(([rx,val]) => { out = out.replace(rx, String(val || '')); });

  if(path === 'manifest.webmanifest'){
    try{
      const m = JSON.parse(out);
      m.name = product;
      m.short_name = shortProduct.substring(0, 24);
      m.description = `${c.name} CBT website generated with HMG CBT Site Generator. No paid AI API required.`;
      out = JSON.stringify(m, null, 2);
    }catch(e){}
  }

  if(path.endsWith('.html')){
    out = injectClientAssets(out);
  }

  if(path.endsWith('.md')){
    out += `\n\n---\n\nGenerated client package for **${c.name}** using HMG CBT Site Generator v${VERSION}. No paid AI API is required.\n`;
  }

  return out;
}

function injectClientAssets(html){
  let out = html;
  if(!out.includes('client-theme.css')){
    out = out.replace(/<\/head>/i, '  <link rel="stylesheet" href="client-theme.css">\n</head>');
  }
  if(!out.includes('client-config.js')){
    out = out.replace(/<\/body>/i, '  <script src="client-config.js"></script>\n  <script src="client-branding.js"></script>\n</body>');
  }
  return out;
}

async function addGeneratedFiles(files, cfg){
  files.push({path:'client-config.js', data:strToU8(`window.CBT_CLIENT_CONFIG = ${JSON.stringify(cfg,null,2)};\n`)});
  files.push({path:'client-config.json', data:strToU8(JSON.stringify(cfg,null,2))});
  files.push({path:'client-theme.css', data:strToU8(buildClientThemeCss(cfg))});
  files.push({path:'client-branding.js', data:strToU8(buildClientBrandingJs())});
  files.push({path:'brand/brand-kit.json', data:strToU8(JSON.stringify(buildBrandKit(cfg),null,2))});

  if(logoFile){
    files.push({path:cfg.logo.path, data:new Uint8Array(await logoFile.arrayBuffer())});
  }else{
    files.push({path:'assets/client-logo.svg', data:strToU8(makeInitialsLogo(cfg))});
  }
  files.push({path:'assets/client-icon.svg', data:strToU8(makeInitialsLogo(cfg, true))});

  if(cfg.package.includeDocs){
    files.push({path:'CLIENT_DEPLOYMENT.md', data:strToU8(buildClientDeployment(cfg))});
    files.push({path:'CLIENT_FEATURES.md', data:strToU8(buildClientFeatures(cfg))});
    files.push({path:'CLIENT_HANDOVER.md', data:strToU8(buildClientHandover(cfg))});
    files.push({path:'SUPABASE_SETUP_NOTES.md', data:strToU8(buildSupabaseNotes(cfg))});
  }
}

function buildClientThemeCss(cfg){
  const t = cfg.theme;
  return `/* Client theme generated by HMG CBT Site Generator. */\n:root{\n  --primary:${t.primary};\n  --primary-dark:${shade(t.primary,-18)};\n  --accent:${t.accent};\n  --info:${t.accent};\n  --purple:${t.secondary};\n  --bg:${t.mode==='light'?'#f8fafc':t.background};\n  --surface:${t.mode==='light'?'#ffffff':t.surface};\n  --surface-2:${t.mode==='light'?'#f1f5f9':shade(t.surface,10)};\n  --text:${t.mode==='light'?'#0f172a':t.text};\n  --text-muted:${t.mode==='light'?'#64748b':'#a1a1aa'};\n  --border:${t.mode==='light'?'#e2e8f0':'#3f3f46'};\n}\nbody{font-family:${t.font};}\n.card,.auth-card,.modal-content,.question-card,.dashboard-card{border-radius:${t.radius}!important;}\nbutton,.btn,.btn-sm,input,select,textarea{border-radius:${t.radius}!important;}\n[data-client-layout="minimal"] .card,[data-client-layout="minimal"] .auth-card{box-shadow:none!important;}\n[data-client-layout="classic"] body{background:${t.mode==='light'?'#f8fafc':'#0b1120'}!important;}\n[data-client-layout="government"] body{background:${t.mode==='light'?'#f7f7f2':'#111827'}!important;}\n[data-client-layout="neon"] .card,[data-client-layout="neon"] .auth-card{box-shadow:0 0 0 1px ${hexToRgba(t.primary,.25)},0 0 45px ${hexToRgba(t.primary,.12)}!important;}\n.client-generated-ribbon{margin:18px auto 0;max-width:980px;text-align:center;font-size:12px;color:var(--text-muted);}\n.client-generated-ribbon a{color:var(--primary);font-weight:800;text-decoration:none;}\n`;
}

function buildClientBrandingJs(){
  return `(function(){\n  const cfg=window.CBT_CLIENT_CONFIG||{};\n  const c=cfg.client||{}, t=cfg.theme||{}, p=cfg.package||{};\n  const root=document.documentElement;\n  root.dataset.clientLayout=t.layout||'enterprise';\n  Object.entries({primary:t.primary,accent:t.accent,purple:t.secondary}).forEach(([k,v])=>{if(v)root.style.setProperty('--'+k,v)});\n  if(t.font)document.body.style.fontFamily=t.font;\n  if(c.siteTitle){document.title=document.title.replace(/HMG Academy CBT Pro|HMG Academy CBT|HMG Academy/g,c.siteTitle);}\n  const logoPath=(cfg.logo&&cfg.logo.path)||'assets/client-logo.svg';\n  document.querySelectorAll('img').forEach(img=>{\n    const src=img.getAttribute('src')||'';\n    if(/hmg-academy-logo|hmg-icon|generator-logo/i.test(src)){img.src=logoPath;img.alt=(c.name||'Client')+' logo';}\n  });\n  const repl={\n    'HMG Academy CBT Pro':c.siteTitle||((c.shortName||c.name||'Client')+' CBT Pro'),\n    'HMG Academy CBT':(c.shortName||c.name||'Client')+' CBT',\n    'HMG Academy':c.name||'Client Academy',\n    'HMG Technologies':(c.shortName||'Client')+' Digital Learning',\n    'Adewale Samson Adeagbo':c.ownerName||c.name||'Administrator',\n    'hismarvellousgrace@gmail.com':c.email||'',\n    'buildingmyictcareer@gmail.com':(cfg.supabase&&cfg.supabase.adminEmail)||c.email||'',\n    '+234 810 086 6322':c.whatsapp||c.phone||'',\n    '+234 907 790 7677':c.phone||c.whatsapp||''\n  };\n  const skip=new Set(['SCRIPT','STYLE','TEXTAREA','INPUT','CODE','PRE']);\n  const walker=document.createTreeWalker(document.body,NodeFilter.SHOW_TEXT,{acceptNode(n){return n.parentElement&&!skip.has(n.parentElement.tagName)?NodeFilter.FILTER_ACCEPT:NodeFilter.FILTER_REJECT;}});\n  const nodes=[];while(walker.nextNode())nodes.push(walker.currentNode);\n  nodes.forEach(n=>{let v=n.nodeValue;Object.entries(repl).forEach(([a,b])=>{if(b)v=v.split(a).join(b)});n.nodeValue=v;});\n  document.querySelectorAll('a[href*="hmgacademy.pages.dev"],a[href*="hmgconcepts.pages.dev"]').forEach(a=>{if(c.website)a.href=c.website;});\n  document.querySelectorAll('a[href*="wa.me/2348100866322"]').forEach(a=>{if(c.whatsappLink)a.href=c.whatsappLink;});\n  if(p.includeGeneratorCredit&&!p.whiteLabel){\n    const div=document.createElement('div');div.className='client-generated-ribbon';\n    div.innerHTML='Generated with <a href="https://hmgconcepts.pages.dev/" target="_blank" rel="noopener">HMG CBT Site Generator</a> · No paid AI API required.';\n    document.body.appendChild(div);\n  }\n})();\n`;
}

function buildBrandKit(cfg){
  return {client:cfg.client, theme:cfg.theme, logo:cfg.logo, generatedBy:cfg.generator, usage:['Use client-theme.css for colours/fonts/layout.','Use assets/client-logo.* for UI logo.','Use client-config.json as source of truth for handover.']};
}

function buildClientDeployment(cfg){
  return `# ${cfg.client.name} CBT Website — Deployment Guide\n\nGenerated by HMG CBT Site Generator v${VERSION}. No paid AI API required.\n\n## 1. Client details\n\n- Institution: ${cfg.client.name}\n- Short name: ${cfg.client.shortName}\n- Type: ${cfg.client.institutionType}\n- Admin email: ${cfg.supabase.adminEmail}\n- Support email: ${cfg.client.email}\n- Phone: ${cfg.client.phone}\n- WhatsApp: ${cfg.client.whatsapp}\n- Website: ${cfg.client.website}\n\n## 2. Deployment steps\n\n1. Extract this ZIP.\n2. Create or open the client's Supabase project.\n3. Confirm \`SB_URL\` and \`SB_KEY\` in \`teacher.html\`, \`student.html\`, \`admin.html\`, and \`link_checker.html\`.\n4. Run \`COMPLETE_SQL_SETUP.sql\` in Supabase SQL Editor.\n5. Upload all extracted files to GitHub Pages, Netlify, Vercel, Cloudflare Pages, or another static host.\n6. Open \`deployment_validator.html\`.\n7. Test teacher signup, admin approval, exam creation, student submission, and results.\n\n## 3. Important security note\n\nNever place the Supabase service_role key in frontend files. Only the anon public key is allowed.\n`;}

function featureLabelMap(){
  const map={}; FEATURE_GROUPS.forEach(g=>g.items.forEach(([id,label])=>{map[id]=label;})); return map;
}
function buildClientFeatures(cfg){
  const labels=featureLabelMap();
  const enabled = Object.entries(cfg.features).filter(([,v])=>v).map(([k])=>`- ${labels[k]||k}`).join('\n');
  const disabled = Object.entries(cfg.features).filter(([,v])=>!v).map(([k])=>`- ${labels[k]||k}`).join('\n') || '- None';
  return `# ${cfg.client.name} CBT Website — Feature Selection\n\n## Enabled features\n\n${enabled}\n\n## Hidden/disabled feature flags\n\n${disabled}\n\n## Note\n\nThe base enterprise CBT files are preserved so features can be re-enabled later without rebuilding from scratch.\n`;}

function buildClientHandover(cfg){
  return `# ${cfg.client.name} CBT Website — Handover Notes\n\n## Login/admin\n\nConfigured admin email: ${cfg.supabase.adminEmail}\n\n## Brand\n\nPrimary colour: ${cfg.theme.primary}\nAccent colour: ${cfg.theme.accent}\nLayout: ${cfg.theme.layout}\nFont: ${cfg.theme.font}\n\n## Files to know\n\n- \`teacher.html\`: teacher dashboard\n- \`student.html\`: student portal\n- \`admin.html\`: admin panel\n- \`COMPLETE_SQL_SETUP.sql\`: database setup\n- \`client-config.json\`: generated client configuration\n- \`client-theme.css\`: generated brand theme\n\n## Support\n\n${cfg.client.email} · ${cfg.client.phone} · ${cfg.client.whatsapp}\n`;}

function buildSupabaseNotes(cfg){
  return `# Supabase Setup Notes for ${cfg.client.name}\n\n1. Create Supabase project.\n2. Use Project URL: \`${cfg.supabase.url}\`.\n3. Use anon key only in frontend.\n4. Run \`COMPLETE_SQL_SETUP.sql\`.\n5. Make sure admin profile is active for: \`${cfg.supabase.adminEmail}\`.\n6. Test full workflow before production.\n\nNo paid AI API is required.\n`;}

function makeInitialsLogo(cfg, icon=false){
  const t=cfg.theme,c=cfg.client;
  const txt=initials(c.shortName||c.name);
  const r=icon?80:96;
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><rect width="512" height="512" rx="${r}" fill="${t.background}"/><rect x="54" y="54" width="404" height="404" rx="${r}" fill="${t.primary}"/><text x="256" y="292" text-anchor="middle" font-family="Arial, sans-serif" font-size="142" font-weight="900" fill="#061016">${escapeHtml(txt)}</text></svg>`;
}

function setStatus(msg, kind){
  const el=$('#status'); el.textContent=msg; el.className='status-box '+(kind||'');
}

function normaliseWhatsApp(v){
  const digits=String(v||'').replace(/\D/g,'');
  if(!digits) return '';
  return 'https://wa.me/'+(digits.startsWith('0')?'234'+digits.slice(1):digits);
}
function logoExtension(file){
  const name=(file.name||'').toLowerCase();
  if(name.endsWith('.svg'))return 'svg'; if(name.endsWith('.jpg')||name.endsWith('.jpeg'))return 'jpg'; if(name.endsWith('.webp'))return 'webp'; return 'png';
}
function initials(s){return String(s||'CBT').split(/\s+/).filter(Boolean).slice(0,2).map(x=>x[0]).join('').toUpperCase()||'CBT';}
function safeZipName(s){s=safeFileName(s||'client-cbt-website.zip');return s.toLowerCase().endsWith('.zip')?s:s+'.zip';}
function safeFileName(s){return String(s||'file').toLowerCase().replace(/[^a-z0-9._-]+/g,'-').replace(/^-+|-+$/g,'')||'file';}
function escapeHtml(s){return String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}
function escapeJs(s){return String(s??'').replace(/\\/g,'\\\\').replace(/'/g,"\\'").replace(/\n/g,'\\n').replace(/\r/g,'');}
function hexToRgba(hex,a){const [r,g,b]=hexToRgb(hex);return `rgba(${r},${g},${b},${a})`;}
function hexToRgb(hex){hex=String(hex||'#000000').replace('#','');if(hex.length===3)hex=hex.split('').map(x=>x+x).join('');const n=parseInt(hex,16);return [(n>>16)&255,(n>>8)&255,n&255];}
function shade(hex, pct){const [r,g,b]=hexToRgb(hex);const f=x=>Math.max(0,Math.min(255,Math.round(x+(pct/100)*255)));return '#'+[f(r),f(g),f(b)].map(x=>x.toString(16).padStart(2,'0')).join('');}
function strToU8(s){return new TextEncoder().encode(String(s));}
function downloadBlob(blob,name){const a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download=name;document.body.appendChild(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(a.href),1000);}

// Minimal ZIP writer (STORE/no compression) to avoid external JS libraries.
const CRC_TABLE = (()=>{const t=new Uint32Array(256);for(let n=0;n<256;n++){let c=n;for(let k=0;k<8;k++)c=(c&1)?(0xedb88320^(c>>>1)):(c>>>1);t[n]=c>>>0;}return t;})();
function crc32(data){let c=0xffffffff;for(let i=0;i<data.length;i++)c=CRC_TABLE[(c^data[i])&0xff]^(c>>>8);return (c^0xffffffff)>>>0;}
function pushU16(arr,n){arr.push(n&255,(n>>>8)&255);}function pushU32(arr,n){arr.push(n&255,(n>>>8)&255,(n>>>16)&255,(n>>>24)&255);} 
function dosTimeDate(d=new Date()){const time=((d.getHours()&31)<<11)|((d.getMinutes()&63)<<5)|((Math.floor(d.getSeconds()/2))&31);const date=(((d.getFullYear()-1980)&127)<<9)|(((d.getMonth()+1)&15)<<5)|(d.getDate()&31);return{time,date};}
function createZip(files){
  const chunks=[], central=[]; let offset=0; const now=dosTimeDate(new Date());
  for(const file of files){
    const nameBytes=strToU8(file.path.replace(/^\/+/,'')); const data=file.data instanceof Uint8Array?file.data:new Uint8Array(file.data);
    const crc=crc32(data), size=data.length;
    const local=[]; pushU32(local,0x04034b50); pushU16(local,20); pushU16(local,0x0800); pushU16(local,0); pushU16(local,now.time); pushU16(local,now.date); pushU32(local,crc); pushU32(local,size); pushU32(local,size); pushU16(local,nameBytes.length); pushU16(local,0);
    chunks.push(new Uint8Array(local), nameBytes, data);
    const cent=[]; pushU32(cent,0x02014b50); pushU16(cent,20); pushU16(cent,20); pushU16(cent,0x0800); pushU16(cent,0); pushU16(cent,now.time); pushU16(cent,now.date); pushU32(cent,crc); pushU32(cent,size); pushU32(cent,size); pushU16(cent,nameBytes.length); pushU16(cent,0); pushU16(cent,0); pushU16(cent,0); pushU16(cent,0); pushU32(cent,0); pushU32(cent,offset);
    central.push(new Uint8Array(cent), nameBytes);
    offset += local.length + nameBytes.length + size;
  }
  const centralOffset=offset; let centralSize=0; central.forEach(x=>centralSize+=x.length);
  const end=[]; pushU32(end,0x06054b50); pushU16(end,0); pushU16(end,0); pushU16(end,files.length); pushU16(end,files.length); pushU32(end,centralSize); pushU32(end,centralOffset); pushU16(end,0);
  return new Blob([...chunks,...central,new Uint8Array(end)], {type:'application/zip'});
}

document.addEventListener('DOMContentLoaded', init);
})();
