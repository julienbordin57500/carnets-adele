// 📖 Petit tuto animé, affiché une fois par personne et par téléphone à la première connexion :
// - parents : 9 étapes avec une petite scène animée (le doigt montre où toucher)
// - grands-parents : 5 étapes simples sur l'onglet Garde
// On peut le revoir depuis ⚙️ Réglages → « Revoir le tuto ».
(() => {
  // Petites scènes animées (dessinées en HTML / CSS, voir « Tuto animé » dans style.css)
  const DOIGT = `<span class="td-doigt">👆</span>`;
  const ETAPES_PARENTS = () => [
    {
      emoji: "👋",
      titre: "Bienvenue dans le carnet d'Adèle",
      texte: "Tout le quotidien d'Adèle au même endroit, sur vos deux téléphones : repas, couches, sommeil, santé et garde. Glissez de gauche à droite ou touchez les onglets en bas du titre.",
      demo: `<div class="td-onglets"><span>🍼</span><span>👶</span><span>🌙</span><span>🩺</span><span>👵</span><i class="td-curseur"></i></div>`,
    },
    {
      emoji: "🍼",
      titre: "Un repas",
      texte: "Choisissez Biberon ou Allaitement, réglez les ml avec − et +, puis touchez le gros bouton. Le chrono montre depuis quand elle a mangé, et l'heure probable du prochain repas.",
      demo: `<div class="td-ml"><span class="td-rond">−</span><span class="td-val"><b class="td-v1">110 ml</b><b class="td-v2">120 ml</b></span><span class="td-rond td-plus">+${DOIGT}</span></div><div class="td-gros">🍼 Nouveau biberon<span class="td-ok">✓</span></div>`,
    },
    {
      emoji: "👶",
      titre: "Une couche",
      texte: "Touchez 💧 Pipi, 💩 Caca ou les deux, puis « Couche changée ». Pour un caca : la taille, la consistance et la couleur (à montrer au pédiatre si elle est inhabituelle).",
      demo: `<div class="td-puces"><span class="td-puce td-p1">💧 Pipi</span><span class="td-puce td-p2">💩 Caca</span></div><div class="td-gros td-couche">👶 Couche changée<span class="td-ok">✓</span></div>`,
    },
    {
      emoji: "🌙",
      titre: "Le sommeil",
      texte: "« Elle s'endort » lance le chrono, « Elle se réveille » l'arrête. Vous avez oublié ? Ajoutez la sieste après coup avec les heures. Si un dodo dure plus de 12 h, l'appli vous demande l'heure du réveil.",
      demo: `<div class="td-dodo"><span class="td-lune">🌙</span><span class="td-soleil">☀️</span><span class="td-chrono">1 h 25</span><span class="td-z">z</span><span class="td-z td-z2">z</span></div>`,
    },
    {
      emoji: "✏️",
      titre: "Une erreur ? Pas de souci",
      texte: "Juste après un ajout, « Annuler » apparaît 5 secondes. Plus tard : touchez la ligne pour changer l'heure, ou ✕ deux fois pour l'effacer. Un double appui par erreur ? L'appli vous prévient.",
      demo: `<div class="td-ligne"><span>🍼</span><b>14:30</b><span class="td-gris">120 ml</span><span class="td-x">✕</span>${DOIGT}</div><div class="td-toast">Biberon ajouté ! <u>Annuler</u></div>`,
    },
    {
      emoji: "🩺",
      titre: "Sa santé",
      texte: "Poids, taille et courbes, rendez-vous chez le pédiatre, vaccins, médicaments donnés, et le carnet de ses premières fois (premier sourire, première dent…).",
      demo: `<div class="td-barres"><i style="--h:30%"></i><i style="--h:45%"></i><i style="--h:58%"></i><i style="--h:72%"></i><i style="--h:88%"></i></div>`,
    },
    {
      emoji: "👵",
      titre: "Quand on la garde",
      texte: "Les grands-parents ont leur propre compte et notent dans l'onglet Garde : tout arrive dans votre carnet. Touchez une de leurs notes pour réagir avec un émoji ❤️ : ils le voient.",
      demo: `<div class="td-note"><span class="td-gris">👵 Grands-parents · 15:10</span><span>🍼 Biberon de 120 ml</span><span class="td-coeur">❤️</span></div>`,
    },
    {
      emoji: "🔔",
      titre: "La cloche et les sons",
      texte: "🔔 : les dernières nouvelles et le récap du mois (à copier pour la famille). 🎵 : bruit blanc, pluie, vagues et berceuses avec minuterie, pour l'aider à s'endormir.",
      demo: `<div class="td-icones"><span class="td-cloche">🔔</span><span class="td-musique">🎵<i>♪</i><i>♫</i><i>♪</i></span></div>`,
    },
    {
      emoji: "📲",
      titre: "Comme une vraie appli",
      texte: "Dans Safari : bouton Partager, puis « Sur l'écran d'accueil ». Le carnet s'ouvre alors comme une appli, et marche même sans réseau. Bienvenue Adèle !",
      demo: `<div class="td-ecran"><span></span><span></span><span></span><span class="td-appli">🧸</span></div>`,
    },
  ];
  const ETAPES_FAMILLE = () => [
    {
      emoji: "👋",
      titre: "Bienvenue !",
      texte: "Ce carnet sert à suivre la journée d'Adèle quand vous la gardez. Ça prend 30 secondes à comprendre.",
    },
    {
      emoji: "👵",
      titre: "Votre espace : l'onglet Garde",
      texte: "C'est l'onglet 👵 Garde. C'est ici que vous notez ce qui se passe pendant que vous la gardez. Les parents le voient sur leur téléphone.",
    },
    {
      emoji: "🍼",
      titre: "Un appui quand ça arrive",
      texte: "En haut, 3 gros boutons : 🍼 Biberon (vous choisissez combien elle a bu), 👶 Couche (pipi, caca ou les deux) et 🌙 Elle s'endort. Quand elle dort, un grand bandeau jaune apparaît : touchez-le à son réveil. Une erreur ? Touchez la ligne pour changer l'heure ou l'effacer.",
    },
    {
      emoji: "📝",
      titre: "La note du jour",
      texte: "« 📝 Un mot pour les parents » : écrivez ce que vous avez fait, comment elle était, puis Enregistrer. Les parents le liront sur leur téléphone.",
    },
    {
      emoji: "💊",
      titre: "Un médicament ? Notez-le",
      texte: "Dans l'onglet 🩺 Santé, « + Prise » pour noter un médicament donné (avec l'heure). Vous y trouvez aussi sa fiche santé : allergies, pédiatre… Bonne garde !",
    },
  ];

  let etapes = [];
  let i = 0;

  function rendre() {
    const e = etapes[i];
    $("tuto-emoji").textContent = e.emoji;
    $("tuto-titre").textContent = e.titre;
    $("tuto-texte").textContent = e.texte;
    $("tuto-demo").innerHTML = e.demo || "";
    $("tuto-demo").hidden = !e.demo;
    $("tuto-dots").innerHTML = etapes.map((_, j) => `<span class="${j === i ? "on" : ""}"></span>`).join("");
    $("tuto-suivant").textContent = i === etapes.length - 1 ? "C'est parti !" : "Suivant";
    $("tuto-passer").hidden = i === etapes.length - 1;
    // petite animation à chaque étape
    const box = $("tuto").querySelector(".tuto-box");
    box.classList.remove("pas");
    void box.offsetWidth;
    box.classList.add("pas");
  }

  function ouvrir() {
    if (!profil || $("tuto").open) return;
    etapes = estParent() ? ETAPES_PARENTS() : ETAPES_FAMILLE();
    i = 0;
    rendre();
    $("tuto").showModal();
  }

  $("tuto-suivant").addEventListener("click", () => {
    if (i < etapes.length - 1) {
      i++;
      rendre();
    } else {
      $("tuto").close("fin");
    }
  });
  $("tuto").addEventListener("close", () => ecrire(`tuto-vu:${profil?.nom}`, true));
  $("g-tuto").addEventListener("click", ouvrir);
  $("tuto-revoir").addEventListener("click", () => setTimeout(ouvrir, 150));

  function apresConnexion() {
    const famille = profil && !estParent();
    $("g-tuto-box").hidden = !famille;
    // Une seule fois par personne et par téléphone, juste après l'arrivée sur l'appli
    if (profil && !lire(`tuto-vu:${profil.nom}`, false, (v) => v === true) && !$("tuto").open) setTimeout(ouvrir, 900);
  }
  window.addEventListener("connecte", apresConnexion);
  if (profil) apresConnexion(); // déjà connecté avant le chargement de ce fichier
})();
