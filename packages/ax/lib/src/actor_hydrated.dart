import 'dart:async';

import 'package:flutter/foundation.dart';

import 'actor.dart';
import 'actor_system.dart';
import 'message_bus.dart';
import 'storage.dart';

abstract class HydratedActor<TState> extends Actor<TState> {
  final ActorStorage _storage;
  int version = 0;

  HydratedActor(MessageBus messageBus, ActorStorage storage, TState initalState)
      : _storage = storage,
        super(messageBus, initalState) {
    unawaited(hydrate());
  }

  @protected
  String getMetaKey() => 'ax.storage.$runtimeType.meta';

  @protected
  String getPersistenceKey() => 'ax.storage.$runtimeType.state';

  @override
  MessageEmitter<TState> get emit => (newState) async {
        if (state == newState) {
          return;
        }

        await super.emit(newState);
        await persist(newState);
      };

  @override
  Future<void> reload() async {
    await super.reload();
    await hydrate();
  }

  @protected
  Future<void> hydrate() async {
    try {
      final meta = await _storage.get(getMetaKey());
      version = meta != null && meta.containsKey('v') ? meta['v'] as int : 0;

      final json = await _storage.get(getPersistenceKey());
      if (json == null || json.isEmpty) {
        return;
      }

      final state = fromJson(json);
      if (state != null) {
        await emit(state);
      }
    } catch (ex, st) {
      ActorSystem.instance.onError(this, ex, st);
    }
  }

  @protected
  Future<void> persist(TState currentState) async {
    await _storage.put(getMetaKey(), <String, dynamic>{
      't': DateTime.now().toUtc().toIso8601String(),
      'v': ++version,
    });

    final json = toJson(currentState);
    if (json != null) {
      await _storage.put(getPersistenceKey(), json);
    }
  }

  @protected
  TState? fromJson(Map<String, dynamic>? json);

  @protected
  Map<String, dynamic>? toJson(TState? state);
}
