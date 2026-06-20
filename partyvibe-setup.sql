-- ══════════════════════════════════════════════════
--  PartyVibe — Supabase Database Setup
--  Paste this entire script into:
--  Supabase Dashboard → SQL Editor → New Query → Run
-- ══════════════════════════════════════════════════


-- ── 1. EVENTS ────────────────────────────────────
-- One row per party. Created by the host.
create table if not exists events (
  id              text primary key,
  party_name      text not null,
  host_name       text not null,
  vibe            text,
  welcome         text,
  emoji           text default '🎉',
  visual_theme    text default 'th-night',
  font_family     text default 'Syne',
  active          boolean default true,
  purged          boolean default false,
  purged_at       timestamptz,
  created_at      timestamptz default now()
);


-- ── 2. GUESTS ────────────────────────────────────
-- One row per guest who joins the event.
create table if not exists guests (
  id              text primary key,
  event_id        text not null references events(id) on delete cascade,
  name            text not null,
  selfie_url      text,
  color           text default '#c060ff',
  created_at      timestamptz default now()
);

-- Index for fast lookups by event
create index if not exists guests_event_id_idx on guests(event_id);


-- ── 3. QUIZ ANSWERS ──────────────────────────────
-- Stores each guest's 4 quiz answers as a JSON array.
-- e.g. answers = [2, 0, 3, 1]  (index of selected option)
create table if not exists quiz_answers (
  id              text primary key default gen_random_uuid()::text,
  event_id        text not null references events(id) on delete cascade,
  guest_id        text not null references guests(id) on delete cascade,
  answers         jsonb not null,
  created_at      timestamptz default now(),
  unique(event_id, guest_id)   -- one submission per guest per event
);

create index if not exists quiz_event_id_idx on quiz_answers(event_id);


-- ── 4. PHOTOS ────────────────────────────────────
-- Group photos taken by Memory Heroes.
-- reactions stored as a JSONB object for easy atomic updates.
create table if not exists photos (
  id              text primary key,
  event_id        text not null references events(id) on delete cascade,
  hero_name       text not null,
  theme           text not null,
  emoji           text default '📸',
  photo_url       text,
  reactions       jsonb not null default '{"heart":0,"fire":0,"laugh":0,"wow":0}',
  created_at      timestamptz default now()
);

create index if not exists photos_event_id_idx on photos(event_id);


-- ── 4b. SECRETS ──────────────────────────────────
-- "Find This Person" game: each guest's secret fun fact.
-- Others see the facts anonymously and figure out who's who.
create table if not exists secrets (
  id              text primary key default gen_random_uuid()::text,
  event_id        text not null references events(id) on delete cascade,
  guest_id        text not null references guests(id) on delete cascade,
  name            text not null,
  fact            text not null,
  created_at      timestamptz default now(),
  unique(event_id, guest_id)   -- one secret per guest per event
);

create index if not exists secrets_event_id_idx on secrets(event_id);


-- ── 5. REACTION INCREMENT FUNCTION ───────────────
-- Atomically increments a single reaction counter.
-- Called via supabase.rpc('increment_reaction', {...})
create or replace function increment_reaction(
  photo_id      text,
  reaction_type text
)
returns void
language plpgsql
as $$
begin
  update photos
  set reactions = jsonb_set(
    reactions,
    array[reaction_type],
    to_jsonb( coalesce((reactions ->> reaction_type)::int, 0) + 1 )
  )
  where id = photo_id;
end;
$$;


-- ── 6. ENABLE REALTIME ───────────────────────────
-- Allows the app to receive live updates when guests
-- join or photos are added — no polling needed.
alter publication supabase_realtime add table guests;
alter publication supabase_realtime add table photos;
alter publication supabase_realtime add table secrets;


-- ── 7. ROW LEVEL SECURITY ────────────────────────
-- Open policy for development / party use.
-- Tighten these before any production deployment.
alter table events       enable row level security;
alter table guests       enable row level security;
alter table quiz_answers enable row level security;
alter table photos       enable row level security;
alter table secrets      enable row level security;

-- Allow all reads and writes for now (party app, no auth required)
create policy "Public read events"        on events       for select using (true);
create policy "Public insert events"      on events       for insert with check (true);
create policy "Public update events"      on events       for update using (true);

create policy "Public read guests"        on guests       for select using (true);
create policy "Public insert guests"      on guests       for insert with check (true);
create policy "Public update guests"      on guests       for update using (true);

create policy "Public read quiz"          on quiz_answers for select using (true);
create policy "Public insert quiz"        on quiz_answers for insert with check (true);
create policy "Public upsert quiz"        on quiz_answers for update using (true);

create policy "Public read photos"        on photos       for select using (true);
create policy "Public insert photos"      on photos       for insert with check (true);
create policy "Public update photos"      on photos       for update using (true);

create policy "Public read secrets"       on secrets      for select using (true);
create policy "Public insert secrets"     on secrets      for insert with check (true);
create policy "Public update secrets"     on secrets      for update using (true);


-- ── 8. STORAGE BUCKET ────────────────────────────
-- Run this to create the storage bucket for selfies & photos.
-- Alternatively do it in the Supabase Dashboard:
-- Storage → New bucket → name: partyvibe → Public: ON
insert into storage.buckets (id, name, public)
values ('partyvibe', 'partyvibe', true)
on conflict (id) do nothing;

-- Allow anyone to upload and read from the partyvibe bucket
create policy "Public uploads to partyvibe"
  on storage.objects for insert
  with check (bucket_id = 'partyvibe');

create policy "Public reads from partyvibe"
  on storage.objects for select
  using (bucket_id = 'partyvibe');

create policy "Public deletes from partyvibe"
  on storage.objects for delete
  using (bucket_id = 'partyvibe');


-- ══════════════════════════════════════════════════
--  Done! Your database is ready.
--  Next: paste your URL + anon key into the HTML file.
-- ══════════════════════════════════════════════════
