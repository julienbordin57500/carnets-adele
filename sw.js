// Garde l'appli sur le téléphone pour qu'elle s'ouvre même sans réseau.
// Réseau d'abord (pour avoir les mises à jour), mémoire du téléphone si pas de réseau.
const CACHE = "carnets-adele-v1";
// Mémoire des sons (dossier sons/) : changer le numéro seulement si on remplace un son
const CACHE_SONS = "carnets-adele-sons-v2";
const FICHIERS = [
  "./",
  "index.html",
  "style.css?v=1",
  "scene.js?v=1",
  "config.js?v=1",
  "commun.js?v=1",
  "demo.js?v=1",
  "auth.js?v=1",
  "repas.js?v=1",
  "couches.js?v=1",
  "sommeil.js?v=1",
  "medicaments.js?v=1",
  "sante.js?v=1",
  "garde.js?v=1",
  "resume.js?v=1",
  "sons.js?v=1",
  "comptes.js?v=1",
  "tuto.js?v=1",
  "graphiques.js?v=1",
  "fetes.js?v=1",
  "notifs.js?v=1",
  "pages.js?v=1",
  "icon.svg",
  "icon-180.png",
  "manifest.webmanifest",
  "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.45.4/dist/umd/supabase.js",
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(FICHIERS)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches
      .keys()
      // On ne supprime que les anciennes mémoires d'Adèle, jamais celles d'une autre appli (ex. Noah ou Hortense)
      .then((cles) => Promise.all(cles.filter((k) => k.startsWith("carnets-adele-") && k !== CACHE && k !== CACHE_SONS).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  // Les données (Supabase) et le numéro de version ne passent jamais par la mémoire
  if (url.hostname.endsWith("supabase.co") || url.pathname.endsWith("version.txt")) return;

  // Sons pour s'endormir : gardés à part, pour ne pas les retélécharger à chaque nouvelle version
  if (url.pathname.includes("/sons/")) return e.respondWith(memoireDabord(req, CACHE_SONS));
  const versionne = url.searchParams.has("v") || url.hostname === "cdn.jsdelivr.net";
  e.respondWith(versionne ? memoireDabord(req) : reseauDabord(req));
});

// Fichiers versionnés (style.css?v=27…) : ils ne changent jamais, la mémoire du téléphone suffit
async function memoireDabord(req, nom = CACHE) {
  const cache = await caches.open(nom);
  const enCache = await cache.match(req);
  if (enCache) return enCache;
  const res = await fetch(req);
  if (res.ok) cache.put(req, res.clone());
  return res;
}

// Page principale : toujours la dernière version si le réseau répond (jusqu'à 8 s)
async function reseauDabord(req) {
  const cache = await caches.open(CACHE);
  try {
    const res = await Promise.race([
      // (une requête de navigation ne peut pas être recopiée avec des options : on repart de son adresse)
      fetch(req.mode === "navigate" ? new Request(req.url, { cache: "no-cache", credentials: "same-origin" }) : req),
      new Promise((_, rej) => setTimeout(() => rej(new Error("lent")), 8000)),
    ]);
    if (res.ok) cache.put(req, res.clone());
    return res;
  } catch (err) {
    const enCache = (await cache.match(req)) || (req.mode === "navigate" ? await cache.match("index.html") : null);
    if (enCache) return enCache;
    throw err;
  }
}
