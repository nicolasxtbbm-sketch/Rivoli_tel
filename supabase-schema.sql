-- Run once in the Supabase SQL Editor for this private, single-user app.
create table if not exists public.app_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null,
  revision bigint not null default 1,
  updated_at timestamptz not null default now()
);

alter table public.app_data enable row level security;
drop policy if exists "Read own Rivoli data" on public.app_data;
create policy "Read own Rivoli data" on public.app_data
  for select to authenticated using (auth.uid() = user_id);
grant select on public.app_data to authenticated;
revoke insert, update, delete on public.app_data from anon, authenticated;

create or replace function public.save_app_data(p_payload jsonb, p_expected_revision bigint)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  current_revision bigint;
begin
  if auth.uid() is null then
    raise exception 'AUTH_REQUIRED';
  end if;
  perform pg_advisory_xact_lock(hashtextextended(auth.uid()::text, 0));
  select revision into current_revision
    from public.app_data where user_id = auth.uid() for update;
  if not found then
    if p_expected_revision <> 0 then raise exception 'SYNC_CONFLICT'; end if;
    insert into public.app_data(user_id, payload, revision, updated_at)
      values (auth.uid(), p_payload, 1, now());
    return jsonb_build_object('revision', 1);
  end if;
  if current_revision <> p_expected_revision then
    raise exception 'SYNC_CONFLICT';
  end if;
  update public.app_data set payload = p_payload,
      revision = current_revision + 1, updated_at = now()
    where user_id = auth.uid();
  return jsonb_build_object('revision', current_revision + 1);
end;
$$;

revoke all on function public.save_app_data(jsonb, bigint) from public, anon;
grant execute on function public.save_app_data(jsonb, bigint) to authenticated;
