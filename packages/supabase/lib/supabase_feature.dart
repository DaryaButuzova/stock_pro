library supabase_feature;

// Supabase Service
export 'src/core/supabase_client.dart';

// DI Module
export 'src/di/injection.module.dart';

// Realtime types used by feature packages
export 'package:supabase_flutter/supabase_flutter.dart'
    show PostgresChangeEvent, PostgresChangePayload, RealtimeChannel;
