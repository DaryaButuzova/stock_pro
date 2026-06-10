-- Cart operations (draft sales) are staff-only.
-- complete_sale is left unchanged: admin has no cart UI and the RPC
-- already requires an owned non-empty draft.

create or replace function public.is_staff()
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
      and role = 'staff'
  );
$$;

revoke all on function public.is_staff() from public;
grant execute on function public.is_staff() to authenticated;

-- sales: draft mutations for staff only
drop policy if exists "Users can insert own sales" on public.sales;
drop policy if exists "Staff can insert own draft sales" on public.sales;
create policy "Staff can insert own draft sales"
  on public.sales
  for insert
  to authenticated
  with check (
    public.is_staff()
    and auth.uid() = user_id
    and status = 'draft'
  );

drop policy if exists "Users can update own sales" on public.sales;
drop policy if exists "Staff can update own draft sales" on public.sales;
create policy "Staff can update own draft sales"
  on public.sales
  for update
  to authenticated
  using (
    public.is_staff()
    and auth.uid() = user_id
    and status = 'draft'
  )
  with check (
    public.is_staff()
    and auth.uid() = user_id
    and status = 'draft'
  );

drop policy if exists "Users can delete own draft sales" on public.sales;
drop policy if exists "Staff can delete own draft sales" on public.sales;
create policy "Staff can delete own draft sales"
  on public.sales
  for delete
  to authenticated
  using (
    public.is_staff()
    and auth.uid() = user_id
    and status = 'draft'
  );

-- goods_in_sales: cart line mutations for staff only
drop policy if exists "Users can insert into own draft cart" on public.goods_in_sales;
drop policy if exists "Staff can insert into own draft cart" on public.goods_in_sales;
create policy "Staff can insert into own draft cart"
  on public.goods_in_sales
  for insert
  to authenticated
  with check (
    public.is_staff()
    and exists (
      select 1
      from public.sales
      where sales.id = goods_in_sales.sales_id
        and sales.user_id = auth.uid()
        and sales.status = 'draft'
    )
  );

drop policy if exists "Users can update own draft cart items" on public.goods_in_sales;
drop policy if exists "Staff can update own draft cart items" on public.goods_in_sales;
create policy "Staff can update own draft cart items"
  on public.goods_in_sales
  for update
  to authenticated
  using (
    public.is_staff()
    and exists (
      select 1
      from public.sales
      where sales.id = goods_in_sales.sales_id
        and sales.user_id = auth.uid()
        and sales.status = 'draft'
    )
  );

drop policy if exists "Users can delete own draft cart items" on public.goods_in_sales;
drop policy if exists "Staff can delete own draft cart items" on public.goods_in_sales;
create policy "Staff can delete own draft cart items"
  on public.goods_in_sales
  for delete
  to authenticated
  using (
    public.is_staff()
    and exists (
      select 1
      from public.sales
      where sales.id = goods_in_sales.sales_id
        and sales.user_id = auth.uid()
        and sales.status = 'draft'
    )
  );
