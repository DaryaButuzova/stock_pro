create table if not exists public.sales (
  id              uuid primary key default gen_random_uuid(),
  created_at      timestamptz not null default now(),
  user_id         uuid not null references public.users(id),
  sum             float4,
  payment_method  varchar,
  status          varchar not null,  -- draft | completed | cancelled
  completed_at    timestamptz,
  updated_at      timestamptz
);

-- One active cart (draft) per user.
create unique index if not exists sales_one_draft_per_user
  on public.sales (user_id)
  where status = 'draft';

alter table public.sales enable row level security;

create policy "Users can read own sales"
  on public.sales
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert own sales"
  on public.sales
  for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can update own sales"
  on public.sales
  for update
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can delete own draft sales"
  on public.sales
  for delete
  to authenticated
  using (auth.uid() = user_id and status = 'draft');
