-- Reference schema (table already exists in Supabase):
-- users (
--   id         uuid primary key,
--   created_at timestamptz,
--   creds      varchar,  -- "Фамилия Имя Отчество"
--   email      varchar,
--   password   varchar,
--   role       varchar   -- 'staff' | 'admin'
-- )

-- Optional trigger: creates a profile row when email confirmation
-- is enabled and the client has no active session yet.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (
    id,
    creds,
    email,
    role
  )
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'creds', ''),
    new.email,
    coalesce(new.raw_user_meta_data ->> 'role', 'staff')
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();
