import 'package:injectable/injectable.dart';
import 'package:local_reference_feature/local_reference_feature.dart';
import 'package:stock_feature/stock_feature.dart';
import 'package:supabase_feature/supabase_feature.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    GoodsRepository,
    ReferenceSyncService,
    StockRepository,
    SupabaseService,
  ],
)
void initSalesMicroPackage() {}
