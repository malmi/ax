import 'dart:convert';
import 'dart:io';

import 'storage.dart';

class FileStorage implements ActorStorage {
  final Directory _directory;

  FileStorage({required Directory directory}) : _directory = directory;

  File getFile(String key) {
    final filename = key.replaceAll(RegExp(r'[/\\?%*:|"<>]'), '');
    return File('${_directory.path}/$filename.json');
  }

  @override
  Future<Map<String, dynamic>> get(String key) async {
    final file = getFile(key);
    if (!file.existsSync()) {
      return {};
    }

    return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  }

  @override
  Future<void> put(String key, Map<String, dynamic> json) async {
    var file = getFile(key);
    if (!file.existsSync()) {
      file = await file.create(recursive: true);
    }

    await file.writeAsString(jsonEncode(json), flush: true);
  }
}
