import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

import 'actor.dart';
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
    final meta = await _storage.get(getMetaKey());
    version = meta.containsKey('v') ? meta['v'] as int : 0;

    final json = await _storage.get(getPersistenceKey());
    if (json.isEmpty) {
      return;
    }

    final state = fromJson(json);
    if (state != null) {
      await emit(state);
    }
  }

  @protected
  Future<void> persist(TState currentState) async {
    await _storage.put(getMetaKey(), <String, dynamic>{
      't': InstantPattern.extendedIso.format(Instant.now()),
      'v': ++version,
    });
    await _storage.put(getPersistenceKey(), toJson(currentState));
  }

  @protected
  TState fromJson(Map<String, dynamic> json);

  @protected
  Map<String, dynamic> toJson(TState state);
}
