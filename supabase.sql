-- =====================================================================
-- ZOCA PORTAL - SQL PARA SUPABASE
-- Pegar completo en: SQL Editor > New query > Run
-- =====================================================================

-- 1. Tabla de clientes (una fila por licencia)
create table if not exists public.clientes (
  id            uuid primary key references auth.users(id) on delete cascade,
  licencia      text unique not null,          -- ej. ZCA-2026-01847
  nombre        text not null,
  finca         text,
  departamento  text,
  telefono      text,
  kit           text default 'Kit Estandar',   -- Kit S, Kit M, Kit Estandar, Kit L
  paneles       int  default 51,
  plan          text default 'Pro',            -- Basico, Pro, Cooperativa
  producto      text default 'Mora',
  modulo        text default 'ZCA-ESP32-01',
  firmware      text default 'v2.3.1',
  emitida       date default current_date,
  vence         date default (current_date + interval '1 year'),
  notificaciones jsonb default '{"app":true,"sms":true,"diario":true,"mensual":false,"etileno":true,"puerta":true}'::jsonb,
  creado        timestamptz default now()
);

-- 2. Seguridad: cada cliente solo ve y edita su propia fila
alter table public.clientes enable row level security;

drop policy if exists "cliente ve su fila" on public.clientes;
create policy "cliente ve su fila" on public.clientes
  for select using (auth.uid() = id);

drop policy if exists "cliente edita su fila" on public.clientes;
create policy "cliente edita su fila" on public.clientes
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- 3. Tabla de lecturas (lista para cuando el ESP32 mande datos reales)
create table if not exists public.lecturas (
  id          bigint generated always as identity primary key,
  cliente_id  uuid references public.clientes(id) on delete cascade,
  temp        numeric,   -- grados C
  humedad     numeric,   -- %
  co2         numeric,   -- ppm
  etileno     numeric,   -- ppb
  puerta      boolean,   -- true = abierta
  creado      timestamptz default now()
);

alter table public.lecturas enable row level security;

drop policy if exists "cliente ve sus lecturas" on public.lecturas;
create policy "cliente ve sus lecturas" on public.lecturas
  for select using (auth.uid() = cliente_id);

-- =====================================================================
-- 4. CREAR UN CLIENTE (repetir por cada kit vendido)
--
-- Paso A (en el panel, no aqui):
--   Authentication > Users > Add user > Create new user
--   Email:    zca-2026-01847@clientes.zoca.app   (la licencia en minuscula)
--   Password: la que le vas a dar al cliente
--   Marca "Auto Confirm User"
--
-- Paso B: correr esto en un New query (cambia los datos):
-- =====================================================================

insert into public.clientes (id, licencia, nombre, finca, departamento, telefono, kit, paneles, plan, producto)
select id, 'ZCA-2026-01847', 'Carlos Hernandez', 'Finca La Esperanza', 'Boyaca, Colombia',
       '+57 310 000 0000', 'Kit Estandar', 51, 'Pro', 'Mora'
from auth.users
where email = 'zca-2026-01847@clientes.zoca.app'
on conflict (id) do nothing;
