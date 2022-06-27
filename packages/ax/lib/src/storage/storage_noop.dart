import 'storage.dart';

class NoopStorage implements ActorStorage {
  @override
  Future<Map<String, dynamic>> get(String key) => Future.value(<String, dynamic>{});

  @override
  Future<void> put(String key, Map<String, dynamic> json) => Future.value();
}
