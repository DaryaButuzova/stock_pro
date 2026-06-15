-- Admin stock position metadata and lifecycle RPCs.

create or replace function public.update_stock_meta(
  p_goods_id uuid,
  p_goods_addr varchar default '',
  p_min_count int default 0
)
returns public.stock
language plpgsql
security definer
set search_path = public
as $$
declare
  v_stock public.stock%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  if not public.is_admin() then
    raise exception 'Admin access required';
  end if;

  if p_min_count is null or p_min_count < 0 then
    raise exception 'min_count must be non-negative';
  end if;

  update public.stock
  set
    goods_addr = coalesce(nullif(btrim(p_goods_addr), ''), ''),
    min_count = p_min_count
  where goods_id = p_goods_id
  returning * into v_stock;

  if not found then
    raise exception 'Stock record not found for goods %', p_goods_id;
  end if;

  return v_stock;
end;
$$;

create or replace function public.create_stock_position(
  p_goods_id uuid,
  p_goods_addr varchar default '',
  p_min_count int default 0
)
returns public.stock
language plpgsql
security definer
set search_path = public
as $$
declare
  v_stock public.stock%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  if not public.is_admin() then
    raise exception 'Admin access required';
  end if;

  if p_min_count is null or p_min_count < 0 then
    raise exception 'min_count must be non-negative';
  end if;

  if not exists (
    select 1
    from public.goods
    where id = p_goods_id
  ) then
    raise exception 'Goods not found';
  end if;

  if exists (
    select 1
    from public.stock
    where goods_id = p_goods_id
  ) then
    raise exception 'Stock position already exists';
  end if;

  insert into public.stock (
    goods_id,
    goods_addr,
    count,
    min_count,
    created_at
  )
  values (
    p_goods_id,
    coalesce(nullif(btrim(p_goods_addr), ''), ''),
    0,
    p_min_count,
    now()
  )
  returning * into v_stock;

  return v_stock;
end;
$$;

create or replace function public.delete_stock_position(
  p_goods_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_stock public.stock%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  if not public.is_admin() then
    raise exception 'Admin access required';
  end if;

  select *
  into v_stock
  from public.stock
  where goods_id = p_goods_id
  for update;

  if not found then
    raise exception 'Stock record not found for goods %', p_goods_id;
  end if;

  if v_stock.count <> 0 then
    raise exception 'Stock count must be zero (current: %)', v_stock.count;
  end if;

  delete from public.stock
  where goods_id = p_goods_id;
end;
$$;

revoke all on function public.update_stock_meta(uuid, varchar, int) from public;
grant execute on function public.update_stock_meta(uuid, varchar, int) to authenticated;

revoke all on function public.create_stock_position(uuid, varchar, int) from public;
grant execute on function public.create_stock_position(uuid, varchar, int) to authenticated;

revoke all on function public.delete_stock_position(uuid) from public;
grant execute on function public.delete_stock_position(uuid) to authenticated;
