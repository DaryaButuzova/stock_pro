import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuration for Supabase client.
@injectable
class SupabaseConfig {
  /// The URL of the Supabase instance.
  final String url;

  /// The publishable key for the Supabase instance.
  final String publishableKey;

  const SupabaseConfig({
    @Named('supabaseUrl') required this.url,
    @Named('supabaseKey') required this.publishableKey,
  });
}

/// Service to initialize and manage the Supabase client.
@singleton
class SupabaseService {
  SupabaseService(this._config);

  final SupabaseConfig _config;

  /// Initializes the Supabase Flutter plugin before the service is used.
  @PostConstruct(preResolve: true)
  Future<SupabaseService> init() async {
    await Supabase.initialize(
      url: _config.url,
      publishableKey: _config.publishableKey,
    );
    return this;
  }

  /// Returns the current Supabase client.
  SupabaseClient get client => Supabase.instance.client;
}
