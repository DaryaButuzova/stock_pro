import 'package:injectable/injectable.dart';

import 'repositories/goods_sync_repository.dart';

/// Orchestrates sync of all local reference tables.
@lazySingleton
class ReferenceSyncService {
  ReferenceSyncService(this._goodsSyncRepository);

  final GoodsSyncRepository _goodsSyncRepository;

  /// Syncs all reference tables from Supabase into local storage.
  Future<void> syncAll() async {
    await _goodsSyncRepository.syncAll();
  }
}
