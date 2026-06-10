import 'package:injectable/injectable.dart';

import 'repositories/goods_sync_repository.dart';

/// Orchestrates sync of all local reference tables.
@lazySingleton
class ReferenceSyncService {
  ReferenceSyncService(this._goodsSyncRepository);

  final GoodsSyncRepository _goodsSyncRepository;

  Future<void>? _inFlightSync;

  /// Syncs all reference tables from Supabase into local storage.
  ///
  /// Concurrent calls share the same in-flight request to avoid duplicate
  /// network/DB work when multiple features load at once.
  Future<void> syncAll() {
    return _inFlightSync ??= _goodsSyncRepository.syncAll().whenComplete(() {
      _inFlightSync = null;
    });
  }
}
