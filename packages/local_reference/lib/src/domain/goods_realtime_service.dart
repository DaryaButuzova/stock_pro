import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:supabase_feature/supabase_feature.dart';

import 'repositories/goods_sync_repository.dart';

/// Subscribes to Supabase Realtime changes on `public.goods`
/// and updates the local reference cache.
@lazySingleton
class GoodsRealtimeService {
  GoodsRealtimeService(this._supabaseService, this._goodsSyncRepository);

  final SupabaseService _supabaseService;
  final GoodsSyncRepository _goodsSyncRepository;

  RealtimeChannel? _channel;

  /// Starts listening to goods changes. Safe to call multiple times.
  void start() {
    if (_channel != null) return;

    _channel = _supabaseService.client
        .channel('goods-realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'goods',
          callback: _goodsSyncRepository.applyRealtimeChange,
        )
        .subscribe();
  }

  /// Stops listening to goods changes.
  Future<void> stop() async {
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      await _supabaseService.client.removeChannel(channel);
    }
  }
}
