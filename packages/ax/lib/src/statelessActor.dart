import 'dart:async';

import 'package:flutter/foundation.dart';

import 'actorSystem.dart';
import 'messageBus.dart';

typedef MessageHandler<TEvent> = Future<void> Function(TEvent event);

abstract class IActor {
  @protected
  void onMessage<TMessage extends Message>(MessageHandler<TMessage> handler);

  @protected
  Future<void> dispatch<TMessage extends Message>(TMessage msg);

  @mustCallSuper
  Future<void> close();
}

abstract class StatelessActor implements IActor {
  final _handlers = <_Handler>[];
  final _subscriptions = <StreamSubscription<Message>>[];
  final MessageBus _messageBus;

  StatelessActor(MessageBus messageBus)
      : assert(messageBus != null),
        _messageBus = messageBus {
    ActorSystem.instance.add(this);
  }

  @override
  void onMessage<TMessage extends Message>(
    MessageHandler<TMessage> handler, {
    void Function(dynamic err, StackTrace stackTrace) onError,
  }) {
    final handlerExists = _handlers.any((h) => h.type == TMessage);
    if (handlerExists) {
      throw StateError(
        'on<$TMessage> was called multiple times. There should only be a single message handler per type.',
      );
    }

    _handlers.add(_Handler(isType: (dynamic e) => e is TMessage, type: TMessage));

    final subscription = _messageBus.stream
        .where((event) => event is TMessage)
        .cast<TMessage>()
        .listen((event) async {
      try {
        await handler(event);
      } catch (ex, st) {
        if (onError != null) {
          onError(ex, st);
        }
        if (ActorSystem.instance.onError != null) {
          ActorSystem.instance.onError(this, ex, st);
        }
      }
    });
    _subscriptions.add(subscription);
  }

  @override
  Future<void> dispatch<TMessage extends Message>(TMessage msg) =>
      _messageBus.dispatch(msg);

  @override
  @mustCallSuper
  Future<void> close() async {
    ActorSystem.instance.remove(this);

    _handlers.clear();
    await Future.wait<void>(_subscriptions.map((s) => s.cancel()));
  }
}

class _Handler {
  const _Handler({@required this.isType, @required this.type});
  final bool Function(dynamic value) isType;
  final Type type;
}
