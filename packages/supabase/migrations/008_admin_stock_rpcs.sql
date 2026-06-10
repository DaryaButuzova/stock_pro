-- Admin-only stock adjustments via RPC. Direct stock mutations are revoked.

create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.users
    where id = auth.uid()
      and role = 'admin'
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

drop policy if exists "Authenticated users can insert stock" on public.stock;
drop policy if exists "Authenticated users can update stock" on public.stock;
drop policy if exists "Authenticated users can delete stock" on public.stock;

create or replace function public.replenish_stock(
  p_goods_id uuid,
  p_count int,
  p_comment varchar default null
)
returns public.stock
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_stock public.stock%rowtype;
begin
  v_user_id := auth.uid();
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if not public.is_admin() then
    raise exception 'Admin access required';
  end if;

  if p_count is null or p_count <= 0 then
    raise exception 'Count must be positive';
  end if;

  select *
  into v_stock
  from public.stock
  where goods_id = p_goods_id
  for update;

  if not found then
    raise exception 'Stock record not found for goods %', p_goods_id;
  end if;

  update public.stock
  set count = count + p_count
  where goods_id = p_goods_id
  returning * into v_stock;

  insert into public.stock_movement (
    user_id,
    goods_id,
    count,
    movement_type,
    comment
  )
  values (
    v_user_id,
    p_goods_id,
    p_count,
    'replenishment_in',
    p_comment
  );

  return v_stock;
end;
$$;

create or replace function public.write_off_stock(
  p_goods_id uuid,
  p_count int,
  p_comment varchar default null
)
returns public.stock
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_stock public.stock%rowtype;
begin
  v_user_id := auth.uid();
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if not public.is_admin() then
    raise exception 'Admin access required';
  end if;

  if p_count is null or p_count <= 0 then
    raise exception 'Count must be positive';
  end if;

  select *
  into v_stock
  from public.stock
  where goods_id = p_goods_id
  for update;

  if not found then
    raise exception 'Stock record not found for goods %', p_goods_id;
  end if;

  if v_stock.count < p_count then
    raise exception 'Insufficient stock (available: %)', v_stock.count;
  end if;

  update public.stock
  set count = count - p_count
  where goods_id = p_goods_id
  returning * into v_stock;

  insert into public.stock_movement (
    user_id,
    goods_id,
    count,
    movement_type,
    comment
  )
  values (
    v_user_id,
    p_goods_id,
    -p_count,
    'write_off',
    p_comment
  );

  return v_stock;
end;
$$;

revoke all on function public.replenish_stock(uuid, int, varchar) from public;
grant execute on function public.replenish_stock(uuid, int, varchar) to authenticated;

revoke all on function public.write_off_stock(uuid, int, varchar) from public;
grant execute on function public.write_off_stock(uuid, int, varchar) to authenticated;
