-- Corrige/garante que a segurança (RLS) está realmente ativa
-- Rode no SQL Editor do Supabase

alter table products enable row level security;
alter table product_photos enable row level security;
alter table addons enable row level security;

drop policy if exists "public read products" on products;
drop policy if exists "admin write products" on products;
drop policy if exists "public read product_photos" on product_photos;
drop policy if exists "admin write product_photos" on product_photos;
drop policy if exists "public read addons" on addons;
drop policy if exists "admin write addons" on addons;

create policy "public read products" on products for select using (true);
create policy "admin write products" on products for all
  to authenticated using (true) with check (true);

create policy "public read product_photos" on product_photos for select using (true);
create policy "admin write product_photos" on product_photos for all
  to authenticated using (true) with check (true);

create policy "public read addons" on addons for select using (true);
create policy "admin write addons" on addons for all
  to authenticated using (true) with check (true);

-- Confirma que RLS está ligado (deve retornar rowsecurity = true nas 3 linhas)
select relname, relrowsecurity from pg_class
where relname in ('products','product_photos','addons');
