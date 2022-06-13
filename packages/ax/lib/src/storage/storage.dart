abstract class ActorStorage {
  Future<Map<String, dynamic>> get(String key);
  Future<void> put(String key, Map<String, dynamic> json);
}
