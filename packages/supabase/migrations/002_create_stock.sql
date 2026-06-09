-- Reference schema (table may already exist in Supabase):
-- stock (
--   created_at timestamptz,
--   goods_id   uuid primary key,
--   goods_addr varchar,
--   count      int4,
--   min_count  int4
-- )

alter table public.stock enable row level security;

create policy "Authenticated users can read stock"
  on public.stock
  for select
  to authenticated
  using (true);

create policy "Authenticated users can insert stock"
  on public.stock
  for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update stock"
  on public.stock
  for update
  to authenticated
  using (true);

create policy "Authenticated users can delete stock"
  on public.stock
  for delete
  to authenticated
  using (true);
