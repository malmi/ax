import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

import 'actor_stateless.dart';
import 'message_bus.dart';

typedef MessageEmitter<TState> = Future<void> Function(TState state);

abstract class Actor<TState> extends StatelessActor {
  final StateSubject<TState> _stateSubject;
  final TState _initalState;

  Actor(MessageBus messageBus, TState initalState)
      : assert(initalState != null),
        _initalState = initalState,
        _stateSubject = StateSubject<TState>(initalState),
        super(messageBus);

  TState? get state => _stateSubject.hasValue ? _stateSubject.value : null;

  Stream<TState> get states => _stateSubject.stream;

  Future<void> reload() => emit(_initalState);

  @protected
  MessageEmitter<TState> get emit =>
      (TState newState) async => _stateSubject.add(newState);
}
