
-- Birthday Surprise Studio database setup
create extension if not exists pgcrypto;

create table if not exists public.birthday_orders (
  id uuid primary key default gen_random_uuid(),
  sender text not null,
  recipient text not null,
  birthday text,
  content jsonb not null default '{}'::jsonb,
  photo_paths jsonb not null default '{}'::jsonb,
  status text not null default 'submitted'
    check (status in ('submitted','published')),
  share_token text unique,
  published_content jsonb,
  created_at timestamptz not null default now()
);

alter table public.birthday_orders enable row level security;

grant insert on public.birthday_orders to anon;
grant select, update on public.birthday_orders to authenticated;

drop policy if exists "public can submit birthday orders"
  on public.birthday_orders;
create policy "public can submit birthday orders"
  on public.birthday_orders for insert to anon
  with check (
    status = 'submitted'
    and share_token is null
    and published_content is null
  );

drop policy if exists "admin can read birthday orders"
  on public.birthday_orders;
create policy "admin can read birthday orders"
  on public.birthday_orders for select to authenticated
  using ((auth.jwt()->>'email') = 'premkumarchouhan.1999@gmail.com');

drop policy if exists "admin can update birthday orders"
  on public.birthday_orders;
create policy "admin can update birthday orders"
  on public.birthday_orders for update to authenticated
  using ((auth.jwt()->>'email') = 'premkumarchouhan.1999@gmail.com')
  with check ((auth.jwt()->>'email') = 'premkumarchouhan.1999@gmail.com');

insert into storage.buckets
  (id, name, public, file_size_limit, allowed_mime_types)
values (
  'birthday-photos',
  'birthday-photos',
  false,
  5242880,
  array['image/jpeg','image/png','image/webp','image/gif','image/avif']
)
on conflict (id) do update set
  public = false,
  file_size_limit = 5242880,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "customers can upload birthday photos"
  on storage.objects;
create policy "customers can upload birthday photos"
  on storage.objects for insert to anon
  with check (bucket_id = 'birthday-photos');

drop policy if exists "admin can read birthday photos"
  on storage.objects;
create policy "admin can read birthday photos"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'birthday-photos'
    and (auth.jwt()->>'email') = 'premkumarchouhan.1999@gmail.com'
  );

create or replace function public.get_published_birthday_surprise(p_token text)
returns jsonb
language sql
security definer
set search_path = public
as $$
  select published_content
  from public.birthday_orders
  where share_token = p_token
    and status = 'published'
    and published_content is not null
  limit 1;
$$;

revoke all on function public.get_published_birthday_surprise(text) from public;
grant execute on function public.get_published_birthday_surprise(text)
  to anon, authenticated;
