-- Admin read access to completed sales history and seller names.

alter table public.users enable row level security;

drop policy if exists "Users can read own profile" on public.users;
create policy "Users can read own profile"
  on public.users
  for select
  to authenticated
  using (auth.uid() = id);

drop policy if exists "Admins can read all user profiles" on public.users;
create policy "Admins can read all user profiles"
  on public.users
  for select
  to authenticated
  using (public.is_admin());

drop policy if exists "Admins can read all completed sales" on public.sales;
create policy "Admins can read all completed sales"
  on public.sales
  for select
  to authenticated
  using (public.is_admin() and status = 'completed');

drop policy if exists "Admins can read completed sale items" on public.goods_in_sales;
create policy "Admins can read completed sale items"
  on public.goods_in_sales
  for select
  to authenticated
  using (
    public.is_admin()
    and exists (
      select 1
      from public.sales
      where sales.id = goods_in_sales.sales_id
        and sales.status = 'completed'
    )
  );
