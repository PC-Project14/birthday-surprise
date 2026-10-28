-- Birthday Surprise Studio: secure Supabase setup
-- Run this entire file in Supabase Dashboard -> SQL Editor -> New query.
-- This keeps project data and photos private to the signed-in owner.

create extension if not exists pgcrypto;

create table if not exists public.birthday_projects (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  sender text not null default '',
  recipient text not null default '',
  birthday text,
  content jsonb not null default '{}'::jsonb,
  photo_paths jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.birthday_projects enable row level security;

-- Owners can see and manage only their own projects.
drop policy if exists "Owners can read their birthday projects" on public.birthday_projects;
create policy "Owners can read their birthday projects"
  on public.birthday_projects for select to authenticated
  using (owner_id = (select auth.uid()));

drop policy if exists "Owners can insert their birthday projects" on public.birthday_projects;
create policy "Owners can insert their birthday projects"
  on public.birthday_projects for insert to authenticated
  with check (owner_id = (select auth.uid()));

drop policy if exists "Owners can update their birthday projects" on public.birthday_projects;
create policy "Owners can update their birthday projects"
  on public.birthday_projects for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy if exists "Owners can delete their birthday projects" on public.birthday_projects;
create policy "Owners can delete their birthday projects"
  on public.birthday_projects for delete to authenticated
  using (owner_id = (select auth.uid()));

-- Private bucket: no public read access. App rejects photos >= 5 MB.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('birthday-photos', 'birthday-photos', false, 5242880,
        array['image/jpeg','image/png','image/webp','image/gif','image/avif','image/heic','image/heif'])
on conflict (id) do update set public = false, file_size_limit = 5242880,
  allowed_mime_types = excluded.allowed_mime_types;

-- Object paths must start with the current user's auth UID: UID/project-id/filename.
drop policy if exists "Owners can upload their birthday photos" on storage.objects;
create policy "Owners can upload their birthday photos"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'birthday-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Owners can read their birthday photos" on storage.objects;
create policy "Owners can read their birthday photos"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'birthday-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Owners can update their birthday photos" on storage.objects;
create policy "Owners can update their birthday photos"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'birthday-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'birthday-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Owners can delete their birthday photos" on storage.objects;
create policy "Owners can delete their birthday photos"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'birthday-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
