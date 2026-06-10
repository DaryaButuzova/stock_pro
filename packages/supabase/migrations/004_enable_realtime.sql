-- Enable Supabase Realtime for reference and stock tables.
-- Can also be enabled via Dashboard: Database → Replication.

alter publication supabase_realtime add table public.goods;
alter publication supabase_realtime add table public.stock;
alter publication supabase_realtime add table public.sales;
alter publication supabase_realtime add table public.goods_in_sales;
alter publication supabase_realtime add table public.stock_movement;
