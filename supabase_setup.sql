-- Run this once in Supabase: SQL Editor > New query > Run
create table if not exists items (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('project','certificate')),
  title text not null,
  description text,
  image_url text,
  created_at timestamptz default now()
);
alter table items enable row level security;
create policy "anyone can read items" on items for select using (true);
create policy "admin can change items" on items for all to authenticated using (true) with check (true);
alter publication supabase_realtime add table items;

insert into storage.buckets (id, name, public) values ('images','images',true) on conflict do nothing;
create policy "anyone can view images" on storage.objects for select using (bucket_id = 'images');
create policy "admin can upload images" on storage.objects for insert to authenticated with check (bucket_id = 'images');
create policy "admin can delete images" on storage.objects for delete to authenticated using (bucket_id = 'images');
