-- Reference schema (table may already exist in Supabase):
-- goods (
--   id          uuid primary key,
--   created_at  timestamptz not null,
--   name        varchar,
--   description varchar,
--   cost        float4,
--   category    varchar
-- )

alter table public.goods enable row level security;

create policy "Authenticated users can read goods"
  on public.goods
  for select
  to authenticated
  using (true);

create policy "Authenticated users can insert goods"
  on public.goods
  for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update goods"
  on public.goods
  for update
  to authenticated
  using (true);

create policy "Authenticated users can delete goods"
  on public.goods
  for delete
  to authenticated
  using (true);
