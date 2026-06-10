-- Reference schema (table may already exist in Supabase):
-- stock_movement (
--   id            uuid primary key default gen_random_uuid(),
--   created_at    timestamptz not null default now(),
--   user_id       uuid references public.users(id),
--   goods_id      uuid references public.goods(id),
--   sales_id      uuid references public.sales(id),
--   count         int4 not null,          -- signed: negative = sale_out, positive = replenishment_in
--   movement_type varchar not null,       -- sale_out | replenishment_in
--   comment       varchar
-- )

alter table public.stock_movement enable row level security;

create policy "Authenticated users can read stock movements"
  on public.stock_movement
  for select
  to authenticated
  using (true);

-- Inserts for sale_out are performed by complete_sale (security definer).
-- replenishment_in will use replenish_stock RPC (next phase).

create or replace function public.complete_sale(
  p_sale_id uuid,
  p_payment_method varchar
)
returns public.sales
language plpgsql
security definer
set search_path = public
as $$
declare
  v_sale public.sales%rowtype;
  v_user_id uuid;
  v_line public.goods_in_sales%rowtype;
  v_stock_count int;
  v_total float4 := 0;
begin
  v_user_id := auth.uid();
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select *
  into v_sale
  from public.sales
  where id = p_sale_id
    and user_id = v_user_id
  for update;

  if not found then
    raise exception 'Sale not found';
  end if;

  if v_sale.status <> 'draft' then
    raise exception 'Sale is not a draft';
  end if;

  if not exists (
    select 1
    from public.goods_in_sales
    where sales_id = p_sale_id
  ) then
    raise exception 'Cart is empty';
  end if;

  for v_line in
    select *
    from public.goods_in_sales
    where sales_id = p_sale_id
  loop
    select count
    into v_stock_count
    from public.stock
    where goods_id = v_line.goods_id;

    if v_stock_count is null or v_stock_count < v_line.count then
      raise exception 'Insufficient stock for goods %', v_line.goods_id;
    end if;

    v_total := v_total + (v_line.cost * v_line.count);
  end loop;

  for v_line in
    select *
    from public.goods_in_sales
    where sales_id = p_sale_id
  loop
    insert into public.stock_movement (
      user_id,
      goods_id,
      sales_id,
      count,
      movement_type
    )
    values (
      v_user_id,
      v_line.goods_id,
      p_sale_id,
      -v_line.count,
      'sale_out'
    );

    update public.stock
    set count = count - v_line.count
    where goods_id = v_line.goods_id;
  end loop;

  update public.sales
  set
    status = 'completed',
    sum = v_total,
    payment_method = p_payment_method,
    completed_at = now(),
    updated_at = now()
  where id = p_sale_id
  returning * into v_sale;

  return v_sale;
end;
$$;

revoke all on function public.complete_sale(uuid, varchar) from public;
grant execute on function public.complete_sale(uuid, varchar) to authenticated;
