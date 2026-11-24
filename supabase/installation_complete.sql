-- Installation complète de la base d'Adèle (déjà appliquée le 24/11/2026) : tous les fichiers ci-dessous dans le bon ordre.

-- =====================================================================
-- Les Carnets d'Adèle : base de données complète (à exécuter une fois)
-- 2 comptes : parents.adele@example.com (tout) et
--             grandsparents.adele@example.com (Garde et Santé)
-- =====================================================================

-- ---------- Repas (biberons et allaitements) ----------
create table public.biberons (
  id bigint generated always as identity primary key,
  type text not null default 'biberon' check (type in ('biberon', 'allaitement')),
  pris_le timestamptz not null default now(),
  quantite_ml integer check (quantite_ml is null or (quantite_ml > 0 and quantite_ml <= 500)),
  lait text check (lait in ('poudre', 'maternel')),
  cote text check (cote in ('gauche', 'droite', 'les deux')),
  duree_min integer check (duree_min is null or (duree_min > 0 and duree_min <= 120)),
  reprise_sommeil boolean not null default false,
  created_at timestamptz not null default now(),
  constraint pris_le_pas_futur check (pris_le <= created_at + interval '5 minutes')
);
create index biberons_pris_le_idx on public.biberons (pris_le desc);

-- ---------- Couches ----------
create table public.couches (
  id bigint generated always as identity primary key,
  change_le timestamptz not null default now(),
  pipi boolean not null default false,
  caca boolean not null default false,
  caca_taille text check (caca_taille in ('petit', 'moyen', 'gros')),
  created_at timestamptz not null default now(),
  constraint taille_si_caca check (caca or caca_taille is null),
  constraint change_pas_futur check (change_le <= created_at + interval '5 minutes')
);
create index couches_change_le_idx on public.couches (change_le desc);

-- ---------- Sommeil ----------
create table public.sommeils (
  id bigint generated always as identity primary key,
  debut timestamptz not null default now(),
  fin timestamptz,
  created_at timestamptz not null default now(),
  constraint fin_apres_debut check (fin is null or fin > debut),
  constraint debut_pas_futur check (debut <= created_at + interval '5 minutes')
);
create index sommeils_debut_idx on public.sommeils (debut desc);
create unique index sommeils_un_en_cours on public.sommeils ((true)) where fin is null;

-- ---------- Santé ----------
create table public.sante_profil (
  id integer primary key default 1 check (id = 1),
  date_naissance date,
  heure_naissance time,
  poids_naissance_g integer check (poids_naissance_g is null or poids_naissance_g between 300 and 7000),
  taille_naissance_cm numeric(4,1) check (taille_naissance_cm is null or taille_naissance_cm between 20 and 70),
  pc_naissance_cm numeric(4,1) check (pc_naissance_cm is null or pc_naissance_cm between 20 and 50),
  groupe_sanguin text check (groupe_sanguin is null or groupe_sanguin in ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
  allergies text check (char_length(allergies) <= 500),
  traitements text check (char_length(traitements) <= 500),
  pediatre_nom text check (char_length(pediatre_nom) <= 120),
  pediatre_tel text check (char_length(pediatre_tel) <= 30),
  pediatre_adresse text check (char_length(pediatre_adresse) <= 200),
  notes text check (char_length(notes) <= 1000),
  updated_at timestamptz not null default now()
);
insert into public.sante_profil (id) values (1);

create table public.rendez_vous (
  id bigint generated always as identity primary key,
  quand timestamptz not null,
  type text not null default 'pediatre' check (type in ('pediatre', 'vaccin', 'examen', 'specialiste', 'autre')),
  titre text check (char_length(titre) <= 120),
  lieu text check (char_length(lieu) <= 200),
  notes text check (char_length(notes) <= 1000),
  fait boolean not null default false,
  created_at timestamptz not null default now()
);
create index rendez_vous_quand_idx on public.rendez_vous (quand);

create table public.mesures (
  id bigint generated always as identity primary key,
  mesure_le date not null default current_date,
  poids_kg numeric(5,3) check (poids_kg is null or poids_kg between 0.3 and 40),
  taille_cm numeric(4,1) check (taille_cm is null or taille_cm between 20 and 130),
  pc_cm numeric(4,1) check (pc_cm is null or pc_cm between 20 and 60),
  created_at timestamptz not null default now(),
  constraint au_moins_une_mesure check (poids_kg is not null or taille_cm is not null or pc_cm is not null)
);
create index mesures_le_idx on public.mesures (mesure_le desc);

create table public.suivi_calendrier (
  cle text primary key check (char_length(cle) <= 40),
  fait_le date not null default current_date
);

create table public.medicaments_prises (
  id bigint generated always as identity primary key,
  nom text not null check (char_length(nom) between 1 and 60),
  dose text check (char_length(dose) <= 40),
  pris_le timestamptz not null default now(),
  par text check (char_length(par) <= 40),
  created_at timestamptz not null default now(),
  constraint prise_pas_futur check (pris_le <= created_at + interval '5 minutes')
);
create index medicaments_prises_le_idx on public.medicaments_prises (pris_le desc);

create table public.premieres_fois (
  id bigint generated always as identity primary key,
  quoi text not null check (char_length(quoi) between 1 and 80),
  le date not null default current_date,
  note text check (char_length(note) <= 300),
  created_at timestamptz not null default now()
);
create index premieres_fois_le_idx on public.premieres_fois (le desc);

-- ---------- Garde (grands-parents) ----------
create table public.garde_jours (
  jour date not null,
  gardien text not null check (char_length(gardien) <= 40),
  note text check (char_length(note) <= 2000),
  updated_at timestamptz not null default now(),
  primary key (jour, gardien)
);

create table public.garde_evenements (
  id bigint generated always as identity primary key,
  type text not null check (type in ('repas', 'couche', 'sommeil')),
  quand timestamptz not null default now(),
  fin timestamptz,
  ml integer check (ml is null or (ml > 0 and ml <= 500)),
  lait text check (lait in ('poudre', 'maternel')),
  pipi boolean,
  caca boolean,
  gardien text check (char_length(gardien) <= 40),
  created_at timestamptz not null default now(),
  constraint fin_sommeil check (fin is null or (type = 'sommeil' and fin > quand)),
  constraint quand_pas_futur check (quand <= created_at + interval '5 minutes')
);
create index garde_evenements_quand_idx on public.garde_evenements (quand desc);
create unique index garde_un_dodo_en_cours on public.garde_evenements ((true)) where type = 'sommeil' and fin is null;

-- =====================================================================
-- Droits : qui peut lire / écrire quoi (vérifié par le serveur)
-- =====================================================================
create or replace function public.role_carnet() returns text
language sql stable security invoker set search_path = ''
as $f$
  select case auth.jwt() ->> 'email'
    when 'parents.adele@example.com' then 'parents'
    when 'grandsparents.adele@example.com' then 'famille'
  end
$f$;

-- Personne sans connexion n'a accès à quoi que ce soit
revoke all on all tables in schema public from anon;
alter table public.biberons enable row level security;
alter table public.couches enable row level security;
alter table public.sommeils enable row level security;
alter table public.sante_profil enable row level security;
alter table public.rendez_vous enable row level security;
alter table public.mesures enable row level security;
alter table public.suivi_calendrier enable row level security;
alter table public.medicaments_prises enable row level security;
alter table public.premieres_fois enable row level security;
alter table public.garde_jours enable row level security;
alter table public.garde_evenements enable row level security;

-- Pages des parents : seuls les parents lisent et écrivent
do $d$ declare t text; begin
  foreach t in array array['biberons','couches','sommeils','rendez_vous','mesures','suivi_calendrier','premieres_fois'] loop
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
    execute format($p$create policy "lecture parents" on public.%I for select to authenticated using ((select public.role_carnet()) = 'parents')$p$, t);
    execute format($p$create policy "ajout parents" on public.%I for insert to authenticated with check ((select public.role_carnet()) = 'parents')$p$, t);
    execute format($p$create policy "modif parents" on public.%I for update to authenticated using ((select public.role_carnet()) = 'parents') with check ((select public.role_carnet()) = 'parents')$p$, t);
    execute format($p$create policy "suppression parents" on public.%I for delete to authenticated using ((select public.role_carnet()) = 'parents')$p$, t);
  end loop;
end $d$;

-- Fiche santé : les grands-parents la lisent, seuls les parents la modifient
grant select, update on public.sante_profil to authenticated;
create policy "lecture fiche" on public.sante_profil for select to authenticated using ((select public.role_carnet()) in ('parents','famille'));
create policy "modif fiche parents" on public.sante_profil for update to authenticated using ((select public.role_carnet()) = 'parents') with check ((select public.role_carnet()) = 'parents');

-- Médicaments : tout le monde lit et note une prise ; seuls les parents modifient / suppriment
grant select, insert, update, delete on public.medicaments_prises to authenticated;
create policy "lecture medicaments" on public.medicaments_prises for select to authenticated using ((select public.role_carnet()) in ('parents','famille'));
create policy "ajout medicaments" on public.medicaments_prises for insert to authenticated with check ((select public.role_carnet()) in ('parents','famille'));
create policy "modif medicaments parents" on public.medicaments_prises for update to authenticated using ((select public.role_carnet()) = 'parents') with check ((select public.role_carnet()) = 'parents');
create policy "suppression medicaments parents" on public.medicaments_prises for delete to authenticated using ((select public.role_carnet()) = 'parents');

-- Garde : grands-parents et parents lisent et écrivent
do $d$ declare t text; begin
  foreach t in array array['garde_jours','garde_evenements'] loop
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
    execute format($p$create policy "garde lecture" on public.%I for select to authenticated using ((select public.role_carnet()) in ('parents','famille'))$p$, t);
    execute format($p$create policy "garde ajout" on public.%I for insert to authenticated with check ((select public.role_carnet()) in ('parents','famille'))$p$, t);
    execute format($p$create policy "garde modif" on public.%I for update to authenticated using ((select public.role_carnet()) in ('parents','famille')) with check ((select public.role_carnet()) in ('parents','famille'))$p$, t);
    execute format($p$create policy "garde suppression" on public.%I for delete to authenticated using ((select public.role_carnet()) in ('parents','famille'))$p$, t);
  end loop;
end $d$;

-- Petit « réveil » appelé chaque semaine pour que le projet gratuit ne se mette pas en pause
create or replace function public.reveil() returns timestamptz
language sql stable security invoker set search_path = ''
as $f$ select now() $f$;
revoke all on function public.reveil() from public;
grant execute on function public.reveil() to anon, authenticated;
-- Petit résumé pour les grands-parents : seulement l'essentiel de la journée, rien d'autre.
-- La fonction lit les tables des parents à leur place (security definer) mais ne renvoie que ces quelques infos.
create or replace function public.resume_famille() returns json
language plpgsql stable security definer set search_path = ''
as $f$
declare
  debut_jour timestamptz := date_trunc('day', now() at time zone 'Europe/Paris') at time zone 'Europe/Paris';
  r json;
begin
  if (select public.role_carnet()) is null then
    raise exception 'interdit' using errcode = '42501';
  end if;
  with repas as (
    select b.pris_le as quand, b.type, b.quantite_ml as ml, b.lait, b.duree_min, 'maison' as ou from public.biberons b
    union all
    select g.quand, 'biberon', g.ml, g.lait, null, 'garde' from public.garde_evenements g where g.type = 'repas'
  ), couches as (
    select c.change_le as quand, c.pipi, c.caca, 'maison' as ou from public.couches c
    union all
    select g.quand, coalesce(g.pipi, false), coalesce(g.caca, false), 'garde' from public.garde_evenements g where g.type = 'couche'
  ), dodos as (
    select s.debut, s.fin from public.sommeils s
    union all
    select g.quand, g.fin from public.garde_evenements g where g.type = 'sommeil'
  )
  select json_build_object(
    'dernier_repas', (select row_to_json(x) from (select * from repas order by quand desc limit 1) x),
    'derniere_couche', (select row_to_json(x) from (select * from couches order by quand desc limit 1) x),
    'dernier_caca_aujourdhui', (select max(quand) from couches where caca and quand >= debut_jour),
    'sommeil_aujourdhui_min', (select coalesce(round(sum(extract(epoch from (least(coalesce(fin, now()), now()) - greatest(debut, debut_jour))) / 60)), 0)::int
                               from dodos where coalesce(fin, now()) > debut_jour and debut < now()),
    'dort_depuis', (select max(debut) from dodos where fin is null),
    'dernier_reveil', (select max(fin) from dodos where fin is not null)
  ) into r;
  return r;
end $f$;
revoke all on function public.resume_famille() from public, anon;
grant execute on function public.resume_famille() to authenticated;
-- On peut corriger l'heure d'une note après coup (même plus tard que le moment où elle a été notée) :
-- la seule règle gardée est « pas dans le futur » (5 min de marge), vérifiée au moment de l'enregistrement.
alter table public.biberons drop constraint if exists pris_le_pas_futur;
alter table public.couches drop constraint if exists change_pas_futur;
alter table public.sommeils drop constraint if exists debut_pas_futur;
alter table public.garde_evenements drop constraint if exists quand_pas_futur;
alter table public.medicaments_prises drop constraint if exists prise_pas_futur;

create or replace function public.pas_dans_le_futur() returns trigger
language plpgsql set search_path = ''
as $f$
begin
  if (to_jsonb(new) ->> tg_argv[0])::timestamptz > now() + interval '5 minutes' then
    raise exception 'Heure dans le futur' using errcode = '23514';
  end if;
  return new;
end $f$;

drop trigger if exists pas_dans_le_futur on public.biberons;
create trigger pas_dans_le_futur before insert or update on public.biberons for each row execute function public.pas_dans_le_futur('pris_le');
drop trigger if exists pas_dans_le_futur on public.couches;
create trigger pas_dans_le_futur before insert or update on public.couches for each row execute function public.pas_dans_le_futur('change_le');
drop trigger if exists pas_dans_le_futur on public.sommeils;
create trigger pas_dans_le_futur before insert or update on public.sommeils for each row execute function public.pas_dans_le_futur('debut');
drop trigger if exists pas_dans_le_futur on public.garde_evenements;
create trigger pas_dans_le_futur before insert or update on public.garde_evenements for each row execute function public.pas_dans_le_futur('quand');
drop trigger if exists pas_dans_le_futur on public.medicaments_prises;
create trigger pas_dans_le_futur before insert or update on public.medicaments_prises for each row execute function public.pas_dans_le_futur('pris_le');
-- Ce que notent les grands-parents (garde_evenements) est recopié tout seul dans le carnet des parents :
-- repas → biberons, couche → couches, dodo → sommeils. Les minuteurs, les 24 h et les courbes des parents
-- en tiennent donc compte. Une modification ou un effacement côté garde suit aussi.
-- Les grands-parents ne voient toujours pas le carnet des parents : la copie se fait sur le serveur.

alter table public.biberons add column if not exists garde_id bigint unique references public.garde_evenements (id) on delete cascade;
alter table public.biberons add column if not exists gardien text check (char_length(gardien) <= 40);
alter table public.couches add column if not exists garde_id bigint unique references public.garde_evenements (id) on delete cascade;
alter table public.couches add column if not exists gardien text check (char_length(gardien) <= 40);
alter table public.sommeils add column if not exists garde_id bigint unique references public.garde_evenements (id) on delete cascade;
alter table public.sommeils add column if not exists gardien text check (char_length(gardien) <= 40);

create or replace function public.garde_vers_parents() returns trigger
language plpgsql security definer set search_path = ''
as $f$
begin
  if new.type = 'repas' then
    insert into public.biberons (type, pris_le, quantite_ml, lait, garde_id, gardien, created_at)
    values ('biberon', new.quand, new.ml, new.lait, new.id, new.gardien, new.created_at)
    on conflict (garde_id) do update set pris_le = excluded.pris_le, quantite_ml = excluded.quantite_ml,
      lait = excluded.lait, gardien = excluded.gardien;
  elsif new.type = 'couche' then
    insert into public.couches (change_le, pipi, caca, garde_id, gardien, created_at)
    values (new.quand, coalesce(new.pipi, false), coalesce(new.caca, false), new.id, new.gardien, new.created_at)
    on conflict (garde_id) do update set change_le = excluded.change_le, pipi = excluded.pipi,
      caca = excluded.caca, caca_taille = case when excluded.caca then public.couches.caca_taille end,
      gardien = excluded.gardien;
  elsif new.type = 'sommeil' then
    begin
      insert into public.sommeils (debut, fin, garde_id, gardien, created_at)
      values (new.quand, new.fin, new.id, new.gardien, new.created_at)
      on conflict (garde_id) do update set debut = excluded.debut, fin = excluded.fin, gardien = excluded.gardien;
    exception when unique_violation then
      -- Un dodo est déjà en cours dans le carnet des parents : on ne bloque pas la note des grands-parents
      null;
    end;
  end if;
  return new;
end $f$;
revoke all on function public.garde_vers_parents() from public, anon, authenticated;

drop trigger if exists garde_vers_parents on public.garde_evenements;
create trigger garde_vers_parents after insert or update on public.garde_evenements
  for each row execute function public.garde_vers_parents();

-- Le résumé des grands-parents ne doit pas compter deux fois ce qui est recopié
create or replace function public.resume_famille() returns json
language plpgsql stable security definer set search_path = ''
as $f$
declare
  debut_jour timestamptz := date_trunc('day', now() at time zone 'Europe/Paris') at time zone 'Europe/Paris';
  r json;
begin
  if (select public.role_carnet()) is null then
    raise exception 'interdit' using errcode = '42501';
  end if;
  with repas as (
    select b.pris_le as quand, b.type, b.quantite_ml as ml, b.lait, b.duree_min, 'maison' as ou from public.biberons b where b.garde_id is null
    union all
    select g.quand, 'biberon', g.ml, g.lait, null, 'garde' from public.garde_evenements g where g.type = 'repas'
  ), couches as (
    select c.change_le as quand, c.pipi, c.caca, 'maison' as ou from public.couches c where c.garde_id is null
    union all
    select g.quand, coalesce(g.pipi, false), coalesce(g.caca, false), 'garde' from public.garde_evenements g where g.type = 'couche'
  ), dodos as (
    select s.debut, s.fin from public.sommeils s where s.garde_id is null
    union all
    select g.quand, g.fin from public.garde_evenements g where g.type = 'sommeil'
  )
  select json_build_object(
    'dernier_repas', (select row_to_json(x) from (select * from repas order by quand desc limit 1) x),
    'derniere_couche', (select row_to_json(x) from (select * from couches order by quand desc limit 1) x),
    'dernier_caca_aujourdhui', (select max(quand) from couches where caca and quand >= debut_jour),
    'sommeil_aujourdhui_min', (select coalesce(round(sum(extract(epoch from (least(coalesce(fin, now()), now()) - greatest(debut, debut_jour))) / 60)), 0)::int
                               from dodos where coalesce(fin, now()) > debut_jour and debut < now()),
    'dort_depuis', (select max(debut) from dodos where fin is null),
    'dernier_reveil', (select max(fin) from dodos where fin is not null)
  ) into r;
  return r;
end $f$;
revoke all on function public.resume_famille() from public, anon;
grant execute on function public.resume_famille() to authenticated;

-- Reprise de ce que les grands-parents ont déjà noté aujourd'hui
update public.garde_evenements set gardien = gardien
where quand >= date_trunc('day', now() at time zone 'Europe/Paris') at time zone 'Europe/Paris';
-- Couleur du caca (page Couches, parents seulement), d'après la carte des selles du carnet de santé
alter table public.couches add column if not exists caca_couleur text
  check (caca_couleur in ('jaune', 'orange', 'vert', 'marron', 'noir', 'rouge', 'blanc'));
notify pgrst, 'reload schema';
-- Consistance du caca (page Couches, parents seulement) et nouvelle taille « trace » (juste une trace dans la couche)
alter table public.couches add column if not exists caca_texture text
  check (caca_texture in ('liquide', 'molle', 'normale', 'moulee', 'dure'));

-- La taille accepte maintenant « trace » en plus de petit / moyen / gros
do $$
declare c record;
begin
  for c in
    select con.conname from pg_constraint con
    join pg_attribute a on a.attrelid = con.conrelid and a.attnum = any (con.conkey)
    where con.conrelid = 'public.couches'::regclass and con.contype = 'c' and a.attname = 'caca_taille'
  loop
    execute format('alter table public.couches drop constraint %I', c.conname);
  end loop;
end $$;
alter table public.couches add constraint couches_caca_taille_check
  check (caca_taille in ('trace', 'petit', 'moyen', 'gros'));

notify pgrst, 'reload schema';
-- Réactions des parents (❤️ 😊 😕…) sur ce que les grands-parents notent pendant la garde.
-- Une réaction par note : l'émoji, qui l'a mise et quand (pour prévenir les grands-parents).
alter table public.garde_evenements add column if not exists reaction text check (char_length(reaction) <= 16);
alter table public.garde_evenements add column if not exists reaction_par text check (char_length(reaction_par) <= 40);
alter table public.garde_evenements add column if not exists reaction_le timestamptz;

-- La recopie vers le carnet des parents ne se relance que si la note elle-même change
-- (pas quand on ajoute une réaction) : un doublon effacé par les parents ne revient donc pas.
drop trigger if exists garde_vers_parents on public.garde_evenements;
create trigger garde_vers_parents after insert or update of type, quand, fin, ml, lait, pipi, caca, gardien
  on public.garde_evenements
  for each row execute function public.garde_vers_parents();

notify pgrst, 'reload schema';
-- « Vu par les parents » : quand un parent ouvre la page Garde, les notes des grands-parents sont marquées vues
-- (heure et prénom du parent). Les grands-parents le voient en haut de leur page.
alter table public.garde_evenements add column if not exists vu_le timestamptz;
alter table public.garde_evenements add column if not exists vu_par text check (char_length(vu_par) <= 40);
notify pgrst, 'reload schema';
-- Garde-fou : un dodo ne peut pas durer plus de 16 h (sinon c'est un réveil oublié qui fausse les stats).
-- L'appli demande alors l'heure du réveil (fenêtre « Réveil oublié ? »).
-- Ancien dodo resté ouvert 4 jours (garde du 10 novembre) : voir la correction appliquée à part.
alter table public.sommeils drop constraint if exists dodo_pas_trop_long;
alter table public.sommeils add constraint dodo_pas_trop_long
  check (fin is null or fin - debut <= interval '16 hours');
alter table public.garde_evenements drop constraint if exists dodo_pas_trop_long;
alter table public.garde_evenements add constraint dodo_pas_trop_long
  check (type <> 'sommeil' or fin is null or fin - quand <= interval '16 hours');
notify pgrst, 'reload schema';
