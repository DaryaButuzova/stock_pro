create table if not exists public.goods_in_sales (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  goods_id    uuid not null references public.goods(id),
  sales_id    uuid not null references public.sales(id) on delete cascade,
  count       int4 not null default 0,
  cost        float4 not null default 0,
  updated_at  timestamptz
);

-- One line per goods item inside a sale/cart.
create unique index if not exists goods_in_sales_sale_goods_unique
  on public.goods_in_sales (sales_id, goods_id);

alter table public.goods_in_sales enable row level security;

create policy "Users can read own cart items"
  on public.goods_in_sales
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.sales
      where sales.id = goods_in_sales.sales_id
        and sales.user_id = auth.uid()
    )
  );

create policy "Users can insert into own draft cart"
  on public.goods_in_sales
  for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.sales
      where sales.id = goods_in_sales.sales_id
        and sales.user_id = auth.uid()
        and sales.status = 'draft'
    )
  );

create policy "Users can update own draft cart items"
  on public.goods_in_sales
  for update
  to authenticated
  using (
    exists (
      select 1
      from public.sales
      where sales.id = goods_in_sales.sales_id
        and sales.user_id = auth.uid()
        and sales.status = 'draft'
    )
  );

create policy "Users can delete own draft cart items"
  on public.goods_in_sales
  for delete
  to authenticated
  using (
    exists (
      select 1
      from public.sales
      where sales.id = goods_in_sales.sales_id
        and sales.user_id = auth.uid()
        and sales.status = 'draft'
    )
  );
