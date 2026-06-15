-- Admin-only mutations on goods catalog.
-- create_goods RPC also seeds an empty stock row for warehouse operations.

drop policy if exists "Authenticated users can insert goods" on public.goods;
drop policy if exists "Authenticated users can update goods" on public.goods;
drop policy if exists "Authenticated users can delete goods" on public.goods;

create policy "Admins can insert goods"
  on public.goods
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update goods"
  on public.goods
  for update
  to authenticated
  using (public.is_admin());

create policy "Admins can delete goods"
  on public.goods
  for delete
  to authenticated
  using (public.is_admin());

create or replace function public.create_goods(
  p_name varchar,
  p_description varchar default null,
  p_cost float4 default null,
  p_category varchar default null
)
returns public.goods
language plpgsql
security definer
set search_path = public
as $$
declare
  v_goods public.goods%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  if not public.is_admin() then
    raise exception 'Admin access required';
  end if;

  if p_name is null or btrim(p_name) = '' then
    raise exception 'Name is required';
  end if;

  if p_cost is not null and p_cost < 0 then
    raise exception 'Cost must be non-negative';
  end if;

  insert into public.goods (
    name,
    description,
    cost,
    category
  )
  values (
    btrim(p_name),
    nullif(btrim(p_description), ''),
    p_cost,
    nullif(btrim(p_category), '')
  )
  returning * into v_goods;

  insert into public.stock (
    goods_id,
    goods_addr,
    count,
    min_count,
    created_at
  )
  values (
    v_goods.id,
    '',
    0,
    0,
    now()
  )
  on conflict (goods_id) do nothing;

  return v_goods;
end;
$$;

revoke all on function public.create_goods(varchar, varchar, float4, varchar) from public;
grant execute on function public.create_goods(varchar, varchar, float4, varchar) to authenticated;
