-- Closet Shuffle: database + photo storage setup
-- Paste this whole file into Supabase → SQL Editor → New query, then click Run.
-- Safe to run again if something goes wrong halfway.

-- 1. Clothing items (one row per photo)
create table if not exists public.items (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  cat         text not null check (cat in ('top','bottom','dress','shoes','extra')),
  name        text not null default '',
  path        text not null,              -- where the photo lives in the "closet" bucket
  created_at  timestamptz not null default now()
);

-- 2. Saved outfits
create table if not exists public.fits (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  mode        text not null check (mode in ('split','dress')),
  picks       jsonb not null,             -- {"top": "<item id>", "bottom": ..., ...}
  created_at  timestamptz not null default now()
);

create index if not exists items_user_idx on public.items(user_id);
create index if not exists fits_user_idx  on public.fits(user_id);

-- Signed-in people may use these tables (the rules below still limit them to their own rows)
grant select, insert, update, delete on public.items, public.fits to authenticated;

-- Tiny function the GitHub "keep awake" ping calls. It returns 1 and reads nothing.
create or replace function public.ping() returns int language sql stable as $$ select 1 $$;
revoke all on function public.ping() from public;
grant execute on function public.ping() to anon, authenticated;

-- 3. Everyone only ever sees their own rows
alter table public.items enable row level security;
alter table public.fits  enable row level security;

drop policy if exists "own items" on public.items;
create policy "own items" on public.items
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "own fits" on public.fits;
create policy "own fits" on public.fits
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- 4. Private photo bucket (max 5 MB per photo, images only)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('closet', 'closet', false, 5242880, array['image/png','image/jpeg','image/webp'])
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Photos are saved as  <user id>/<photo id>.<ext>
-- so each person can only touch files inside their own folder.
drop policy if exists "closet: read own"   on storage.objects;
drop policy if exists "closet: add own"    on storage.objects;
drop policy if exists "closet: change own" on storage.objects;
drop policy if exists "closet: delete own" on storage.objects;

create policy "closet: read own" on storage.objects
  for select to authenticated
  using (bucket_id = 'closet' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "closet: add own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'closet' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "closet: change own" on storage.objects
  for update to authenticated
  using (bucket_id = 'closet' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "closet: delete own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'closet' and (storage.foldername(name))[1] = (select auth.uid())::text);