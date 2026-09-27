-- KOB Musicisti — schema Supabase (progetto condiviso, prefisso kob_)
-- Eseguire una sola volta in Supabase > SQL Editor

create table if not exists kob_strumenti (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nome text not null,
  posizione double precision not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists kob_musicisti (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  strumento_id uuid not null references kob_strumenti(id) on delete cascade,
  nome text not null,
  orchestra_ruolo text,
  citta text,
  telefono text,
  email text,
  canale text,
  suggerito_da text,
  note text,
  posizione double precision not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists kob_progetti (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nome text not null,
  posizione double precision not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists kob_progetti_strumenti (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  progetto_id uuid not null references kob_progetti(id) on delete cascade,
  strumento_id uuid not null references kob_strumenti(id) on delete cascade,
  posizione double precision not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (progetto_id, strumento_id)
);

create table if not exists kob_richieste (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  progetto_id uuid not null references kob_progetti(id) on delete cascade,
  musicista_id uuid not null references kob_musicisti(id) on delete cascade,
  stato text not null check (stato in ('rifiutato','chiesto','accettato')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (progetto_id, musicista_id)
);

create index if not exists kob_musicisti_strumento_idx on kob_musicisti(strumento_id);
create index if not exists kob_ps_progetto_idx on kob_progetti_strumenti(progetto_id);
create index if not exists kob_richieste_progetto_idx on kob_richieste(progetto_id);

-- RLS: ogni utente vede e modifica solo le proprie righe
do $$
declare t text;
begin
  foreach t in array array['kob_strumenti','kob_musicisti','kob_progetti','kob_progetti_strumenti','kob_richieste'] loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists "own_rows" on %I', t);
    execute format('create policy "own_rows" on %I for all using (user_id = auth.uid()) with check (user_id = auth.uid())', t);
  end loop;
end $$;
