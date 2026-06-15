// HMG CBT Site Generator service worker — app shell cache only.
const CACHE_NAME = 'hmg-cbt-generator-v1';
const ASSETS = [
  './', './index.html', './styles.css', './generator.js', './manifest.webmanifest', './offline.html', './generator_validator.html', './assets/generator-logo.svg', './template-manifest.json'
];
self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE_NAME).then(cache => Promise.allSettled(ASSETS.map(a => cache.add(a)))).then(() => self.skipWaiting()));
});
self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', event => {
  const req = event.request;
  if(req.method !== 'GET') return;
  const url = new URL(req.url);
  if(url.origin !== location.origin) return;
  event.respondWith(fetch(req).then(res => {
    if(res.ok && !url.pathname.includes('/templates/')) caches.open(CACHE_NAME).then(cache => cache.put(req, res.clone())).catch(()=>{});
    return res;
  }).catch(() => caches.match(req).then(cached => cached || (req.mode === 'navigate' ? caches.match('./offline.html') : new Response('Offline', {status:503})))));
});
