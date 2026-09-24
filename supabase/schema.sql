-- Schema do painel administrativo — Daniela Rodrigues Fotografia
-- Rode este script no Supabase Dashboard: SQL Editor > New query > Run

-- ========== PRODUTOS (pacotes: Newborn, Gestante, etc.) ==========
create table if not exists products (
  id text primary key,
  name text not null,
  base_photos int not null default 5,
  base_price numeric not null default 0,
  included jsonb not null default '[]'::jsonb,
  obs text not null default '',
  sort_order int not null default 0
);

-- ========== FOTOS de cada produto (galeria) ==========
create table if not exists product_photos (
  id bigint generated always as identity primary key,
  product_id text not null references products(id) on delete cascade,
  url text not null,
  position int not null default 0
);

-- ========== ADICIONAIS (foto extra, impressão, álbum, etc.) ==========
create table if not exists addons (
  id text primary key,
  name text not null,
  price numeric not null default 0,
  unit text not null default 'un',
  sort_order int not null default 0
);

-- ========== Segurança (RLS): leitura pública, escrita só logado ==========
alter table products enable row level security;
alter table product_photos enable row level security;
alter table addons enable row level security;

create policy "public read products" on products for select using (true);
create policy "public read product_photos" on product_photos for select using (true);
create policy "public read addons" on addons for select using (true);

create policy "admin write products" on products for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin write product_photos" on product_photos for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin write addons" on addons for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ========== Storage: bucket público para novas fotos enviadas pelo painel ==========
insert into storage.buckets (id, name, public)
  values ('fotos', 'fotos', true)
  on conflict (id) do nothing;

create policy "public read fotos bucket" on storage.objects
  for select using (bucket_id = 'fotos');
create policy "admin upload fotos bucket" on storage.objects
  for insert with check (bucket_id = 'fotos' and auth.role() = 'authenticated');
create policy "admin update fotos bucket" on storage.objects
  for update using (bucket_id = 'fotos' and auth.role() = 'authenticated');
create policy "admin delete fotos bucket" on storage.objects
  for delete using (bucket_id = 'fotos' and auth.role() = 'authenticated');

-- ========== Dados iniciais: produtos (mesmo conteúdo já publicado no site) ==========
insert into products (id, name, base_photos, base_price, included, obs, sort_order) values
('newborn', 'Newborn', 5, 400,
  '["5 Fotos Digitais","1 produção (cenário) com o bebê","Participação dos pais e irmãos (se tiver)"]',
  'A Cada 5 fotos adicionais, acrescentamos mais 1 produção, limite máximo de 3 produções por ensaio. Para fotos adicionais não tem limite.', 1),
('gestante', 'Gestante', 5, 300,
  '["5 Fotos Digitais","Poderá trazer para usar uma produção (roupas / acessórios)","Participação do parceiro"]',
  'A Cada 5 fotos adicionais, será permitido mais 1 produção, limite máximo de 3 produções por ensaio. Para fotos adicionais não tem limite.', 2),
('infantil', 'Infantil', 5, 250,
  '["5 Fotos Digitais","1 produção (cenário) com a criança","Participação dos pais e irmãos (se tiver)"]',
  'A Cada 5 fotos adicionais, acrescentamos mais 1 produção, limite máximo de 3 produções por ensaio. Para fotos adicionais não tem limite.', 3),
('smash', 'Smash the Cake', 5, 400,
  '["5 Fotos Digitais","1 produção (cenário com balões)","Bolo (glacê ou frutas)","Participação dos pais e irmãos (se tiver)"]',
  'no acréscimo de 5 fotos adicionais, acrescentamos mais 1 produção com o banho na banheira. Para fotos adicionais não tem limite.', 4),
('familia', 'Família', 5, 300,
  '["5 Fotos Digitais","Poderá trazer para usar uma produção (roupas / acessórios)"]',
  'A Cada 5 fotos adicionais, será permitido mais 1 produção, limite máximo de 3 produções por ensaio. Para fotos adicionais não tem limite.', 5),
('revelacao', 'Revelação de sexo', 5, 250,
  '["5 Fotos Digitais","Poderá trazer para usar uma produção (roupas / acessórios, tinta, balões, confetes, outros)","Participação do parceiro"]',
  'A Cada 5 fotos adicionais, será permitido mais 1 produção, limite máximo de 3 produções por ensaio. Para fotos adicionais não tem limite.', 6)
on conflict (id) do nothing;

-- ========== Dados iniciais: fotos (apontam para as imagens já publicadas no GitHub Pages) ==========
insert into product_photos (product_id, url, position) values
('newborn', 'https://well2415.github.io/DanielaRodrigues/fotos/newborn-1.jpg', 1),
('newborn', 'https://well2415.github.io/DanielaRodrigues/fotos/newborn-2.jpg', 2),
('newborn', 'https://well2415.github.io/DanielaRodrigues/fotos/newborn-3.jpg', 3),
('newborn', 'https://well2415.github.io/DanielaRodrigues/fotos/newborn-4.jpg', 4),
('newborn', 'https://well2415.github.io/DanielaRodrigues/fotos/newborn-5.jpg', 5),
('gestante', 'https://well2415.github.io/DanielaRodrigues/fotos/gestante-1.jpg', 1),
('gestante', 'https://well2415.github.io/DanielaRodrigues/fotos/gestante-2.jpg', 2),
('gestante', 'https://well2415.github.io/DanielaRodrigues/fotos/gestante-3.jpg', 3),
('gestante', 'https://well2415.github.io/DanielaRodrigues/fotos/gestante-4.jpg', 4),
('gestante', 'https://well2415.github.io/DanielaRodrigues/fotos/gestante-5.jpg', 5),
('infantil', 'https://well2415.github.io/DanielaRodrigues/fotos/infantil-1.jpg', 1),
('infantil', 'https://well2415.github.io/DanielaRodrigues/fotos/infantil-2.jpg', 2),
('infantil', 'https://well2415.github.io/DanielaRodrigues/fotos/infantil-3.jpg', 3),
('infantil', 'https://well2415.github.io/DanielaRodrigues/fotos/infantil-4.jpg', 4),
('infantil', 'https://well2415.github.io/DanielaRodrigues/fotos/infantil-5.jpg', 5),
('infantil', 'https://well2415.github.io/DanielaRodrigues/fotos/infantil-6.jpg', 6),
('infantil', 'https://well2415.github.io/DanielaRodrigues/fotos/infantil-7.jpg', 7),
('infantil', 'https://well2415.github.io/DanielaRodrigues/fotos/infantil-8.jpg', 8),
('smash', 'https://well2415.github.io/DanielaRodrigues/fotos/smash-1.jpg', 1),
('smash', 'https://well2415.github.io/DanielaRodrigues/fotos/smash-2.jpg', 2),
('smash', 'https://well2415.github.io/DanielaRodrigues/fotos/smash-3.jpg', 3),
('smash', 'https://well2415.github.io/DanielaRodrigues/fotos/smash-4.jpg', 4),
('smash', 'https://well2415.github.io/DanielaRodrigues/fotos/smash-5.jpg', 5),
('smash', 'https://well2415.github.io/DanielaRodrigues/fotos/smash-6.jpg', 6),
('smash', 'https://well2415.github.io/DanielaRodrigues/fotos/smash-7.jpg', 7),
('smash', 'https://well2415.github.io/DanielaRodrigues/fotos/smash-8.jpg', 8),
('familia', 'https://well2415.github.io/DanielaRodrigues/fotos/familia-1.jpg', 1),
('familia', 'https://well2415.github.io/DanielaRodrigues/fotos/familia-2.jpg', 2),
('familia', 'https://well2415.github.io/DanielaRodrigues/fotos/familia-3.jpg', 3),
('revelacao', 'https://well2415.github.io/DanielaRodrigues/fotos/revelacao-1.jpg', 1),
('revelacao', 'https://well2415.github.io/DanielaRodrigues/fotos/revelacao-2.jpg', 2);

-- ========== Dados iniciais: adicionais ==========
insert into addons (id, name, price, unit, sort_order) values
('foto', 'Foto extra digital', 40, 'foto', 1),
('impressao1015', 'Impressão 10×15', 3, 'un', 2),
('impressao1521', 'Impressão 15×21', 5, 'un', 3),
('retrato1015', 'Porta-retrato 10×15', 20, 'un', 4),
('retrato1521', 'Porta-retrato 15×21', 30, 'un', 5),
('album1521', 'Álbum 15×21 · 10 páginas', 150, 'un', 6),
('album2020', 'Álbum 20×20 · 10 páginas', 200, 'un', 7),
('caneca', 'Caneca personalizada', 45, 'un', 8)
on conflict (id) do nothing;
