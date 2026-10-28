-- Roomie / Roommate Finder database schema
-- Run this script in Supabase Dashboard > SQL Editor.
-- Public student-demo model: listings are publicly readable and writable.
-- RLS is enabled. Policies intentionally support the no-login educational UI.
-- Do NOT use this anonymous write model for a real production marketplace.
-- Production should add Supabase Auth, owner_id, and owner-scoped UPDATE/DELETE policies.

create extension if not exists pgcrypto;

create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(btrim(title)) between 5 and 100),
  location text not null check (char_length(btrim(location)) between 2 and 100),
  rent integer not null check (rent between 1 and 10000000),
  room_type text not null check (room_type in ('Private', 'Shared', 'Studio')),
  description text not null check (char_length(btrim(description)) between 20 and 1500),
  contact_name text not null check (char_length(btrim(contact_name)) between 2 and 80),
  contact_email text not null check (char_length(btrim(contact_email)) between 3 and 254),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists listings_location_idx on public.listings (lower(location));
create index if not exists listings_rent_idx on public.listings (rent);
create index if not exists listings_room_type_idx on public.listings (room_type);
create index if not exists listings_created_at_idx on public.listings (created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists listings_set_updated_at on public.listings;
create trigger listings_set_updated_at
before update on public.listings
for each row execute function public.set_updated_at();

alter table public.listings enable row level security;

drop policy if exists "Anyone can read listings for student demo" on public.listings;
create policy "Anyone can read listings for student demo"
on public.listings for select
to anon, authenticated
using (true);

drop policy if exists "Anyone can create listings for student demo" on public.listings;
create policy "Anyone can create listings for student demo"
on public.listings for insert
to anon, authenticated
with check (true);

drop policy if exists "Anyone can update listings for student demo" on public.listings;
create policy "Anyone can update listings for student demo"
on public.listings for update
to anon, authenticated
using (true)
with check (true);

drop policy if exists "Anyone can delete listings for student demo" on public.listings;
create policy "Anyone can delete listings for student demo"
on public.listings for delete
to anon, authenticated
using (true);

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.listings to anon, authenticated;
