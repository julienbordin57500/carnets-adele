# Les Carnets d'Adèle — repères pour Claude

> Copie des Carnets d'Hortense (novembre 2026) pour Adèle, la marraine du fils de Julien.
> Base Supabase « Carnets-Adele » (`tklffguxxoubfyrxsupd`) hébergée pour l'instant dans l'organisation
> « Clairette » (compte de Claire) ; à transférer plus tard vers un compte de la famille d'Adèle
> (Project Settings → Transfer project, après les avoir invités / avoir été invité dans leur organisation).
> **Parents seulement** : pas de profil grands-parents ni d'onglet Garde (retirés à la demande de Julien,
> `garde.js` et `resume.js` supprimés). Un seul compte : parents.adele@example.com.
> Les tables garde_* restent dans la base (vides, sans effet). Tuto animé des parents (`tuto.js`), revoyable depuis ⚙️ Réglages.
> Installation complète de la base : `supabase/installation_complete.sql` (déjà appliquée).

Appli web (PWA) pour Adèle : repas, couches, sommeil, santé, garde. Copie adaptée du carnet de Noah
(`../biberons-noah`), thème « oursons et hortensias ». Un seul profil : Parents, droits vérifiés par le serveur. Toujours répondre en français, à un utilisateur novice.

## Techno
- Site statique : HTML + CSS + JavaScript « à la main ». Pas de npm, pas de build, pas de framework.
- Données : Supabase (projet « Carnets-Adèle »), réglages dans `config.js` ; client CDN
  `@supabase/supabase-js@2.45.4` (version figée, aussi listée dans `sw.js`).
- `config.js` → `demo: true` = mode découverte sans serveur (données sur le téléphone). En ligne : `demo: false`.
- Hébergement : GitHub Pages, branche `main` → https://julienbordin57500.github.io/carnets-adele/
- Fonction serveur `supabase/functions/comptes/index.ts` (Deno, création des comptes famille).
- `.github/workflows/reveil.yml` : réveille la base gratuite deux fois par semaine.

## Commandes
- Lancer en local : outil d'aperçu, configuration `adele-bebe` (port 8768), ou
  `python3 -m http.server 8768 --directory "/Users/tch/Application bébé/carnets-adele"`
- Tests automatiques : aucun. Vérifier dans l'aperçu (format iPhone) la page modifiée + la console.
- Compiler : rien à compiler.
- Publier : nouvelle version (voir ci-dessous), puis commit + `git push` sur `main` (après accord).

## Publier une nouvelle version (à chaque changement visible)
`../outils/nouvelle-version.sh adele` fait tout (sans commit). Sinon, N + 1 partout :
1. `version.txt` → N
2. `commun.js` → `const VERSION_APPLI = "N";`
3. `index.html` → tous les `?v=N` (style.css et chaque script)
4. `sw.js` → `const CACHE = "carnets-adele-vN";` et tous les `?v=N`

## Structure
- Mêmes fichiers que Noah (`repas.js`, `couches.js`, `sommeil.js`, `sante.js`, `garde.js`, `commun.js`…)
  plus `config.js`, `demo.js` (faux serveur du mode découverte) et `comptes.js` (page comptes).
- `supabase/schema.sql` (tables + droits) et `supabase/*.sql` : changements à appliquer dans Supabase.

## Conventions
- Noms de variables, fonctions et fichiers en français, même style que le code autour.
- Toute nouveauté qui touche les données doit aussi marcher dans `demo.js` (mode découverte).
- Changement de base = nouveau fichier `supabase/nom_clair.sql`, idempotent, finissant par `notify pgrst, 'reload schema';`.
- Une amélioration faite ici est souvent à reporter dans `../biberons-noah` (demander avant).
- Messages de commit en français, une phrase qui dit ce qui change pour les parents.

## Ne pas toucher sans demander
- `config.js` (URL, clé, `demo`), `supabase/schema.sql` (droits), la fonction `comptes`, `reveil.yml`.
- Le filtre `carnets-adele-` dans `sw.js` : il évite d'effacer la mémoire des applis de Noah et d'Hortense (même adresse github.io).
- Ne jamais committer, pousser, déployer une fonction ou appliquer un SQL sans accord.
