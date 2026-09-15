part of '../authyo_plugin.dart';

/// Loads the dialog configuration (design style, customization, channels,
/// social logins) from the Authyo backend and caches it on-device.
///
/// Precedence when the dialog is rendered:
///
///   built-in defaults  <  remote config (this service)  <  `init()` overrides
///
/// The OTP flow never blocks on this: if the network call fails the last
/// cached copy is used, and if there is none the SDK falls back to defaults.
class _ConfigService {
  _ConfigService(this._api, {required this.clientId});

  final _ApiService _api;
  final String clientId;

  static const _cachePrefix = 'authyo_widget_config_';

  AuthyoWidgetConfig? _config;
  Future<AuthyoWidgetConfig>? _inflight;

  /// Config currently in memory (may be from cache), or null before any load.
  AuthyoWidgetConfig? get current => _config;

  String get _cacheKey => '$_cachePrefix$clientId';

  /// Returns the in-memory config, else the cached one, else fetches.
  Future<AuthyoWidgetConfig> load({bool forceRefresh = false}) {
    if (!forceRefresh && _config != null) return Future.value(_config!);
    return _inflight ??= _load(forceRefresh).whenComplete(() {
      _inflight = null;
    });
  }

  Future<AuthyoWidgetConfig> _load(bool forceRefresh) async {
    if (!forceRefresh) {
      final cached = await _readCache();
      if (cached != null) {
        _config = cached;
        // Refresh quietly in the background for next time.
        unawaited(_fetchAndCache().catchError((_) => cached));
        return cached;
      }
    }
    try {
      return await _fetchAndCache();
    } catch (e) {
      debugPrint('[Authyo] config fetch failed: $e');
      return _config ??= await _readCache() ?? AuthyoWidgetConfig.empty;
    }
  }

  Future<AuthyoWidgetConfig> _fetchAndCache() async {
    final json = await _api.getRaw(
      _api.clientUrl(AuthyoEndpoints.mobileConfigPath),
    );
    if (json['success'] == false) {
      throw UnknownError(json['message']?.toString() ?? 'Config unavailable');
    }
    final cfg = AuthyoWidgetConfig.fromJson(json);
    _config = cfg;
    await _writeCache(json);
    return cfg;
  }

  Future<AuthyoWidgetConfig?> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final text = prefs.getString(_cacheKey);
      if (text == null || text.isEmpty) return null;
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        return AuthyoWidgetConfig.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      debugPrint('[Authyo] config cache read failed: $e');
    }
    return null;
  }

  Future<void> _writeCache(Map<String, dynamic> json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(json));
    } catch (e) {
      debugPrint('[Authyo] config cache write failed: $e');
    }
  }

  Future<void> clear() async {
    _config = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (_) {}
  }
}
