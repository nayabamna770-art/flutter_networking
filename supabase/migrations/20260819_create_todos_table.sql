-- ============================================================
-- Migration: Create todos table
-- Run this in the Supabase SQL Editor (Dashboard -> SQL Editor)
-- ============================================================

create table if not exists public.todos (
  id           uuid          primary key default gen_random_uuid(),
  user_id      uuid          not null references auth.users (id) on delete cascade,
  title        text          not null,
  is_completed boolean       not null default false,
  created_at   timestamptz   not null default now()
);

-- Index for fast per-user queries
create index if not exists todos_user_id_idx on public.todos (user_id);

-- ============================================================
-- Row Level Security (RLS)
-- Ensures users can only access their own todos
-- ============================================================

alter table public.todos enable row level security;

-- SELECT: users can read only their own todos
create policy "Users can view their own todos"
  on public.todos
  for select
  using (auth.uid() = user_id);

-- INSERT: users can only insert todos for themselves
create policy "Users can insert their own todos"
  on public.todos
  for insert
  with check (auth.uid() = user_id);

-- UPDATE: users can only update their own todos
create policy "Users can update their own todos"
  on public.todos
  for update
  using (auth.uid() = user_id);

-- DELETE: users can only delete their own todos
create policy "Users can delete their own todos"
  on public.todos
  for delete
  using (auth.uid() = user_id);
